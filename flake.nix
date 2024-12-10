{
  inputs = {
    nixpkgs.url = "git+ssh://git@github.com/NixOS/nixpkgs?ref=nixos-unstable&shallow=1";
    flake-utils.url = "git+ssh://git@github.com/poscat0x04/flake-utils?shallow=1";
    nix-filter.url = "git+ssh://git@github.com/numtide/nix-filter?shallow=1";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-filter,
      ...
    }:
    with flake-utils;
    eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        };
      in
      with pkgs;
      {
        devShell = mkShell {
          nativeBuildInputs = [ ];
        };
        defaultPackage = {{ project-name }};
      }
    )
    // {
      overlay =
        self: super:
        let
          cargo-toml = builtins.fromTOML (builtins.readFile ./Cargo.toml);
        in
        with final.rustPlatform;
        {
          {{ project-name }} = builtRustPackage {
            pname = cargo-toml.package.name;
            version = cargo-toml.package.version;

            src = nix-filter.lib {
              root = ./.;
              include = [
                ./src
                {% if exe %}
                ./app
                {% endif %}
                {% if test %}
                ./test
                {% endif %}
                {% if example %}
                ./examples
                {% endif %}
                {% if bench %}
                ./bench
                {% endif %}
                ./Cargo.toml
                ./Cargo.lock
              ];
            };

            cargoLock.lockFile = ./Cargo.lock;

            nativeBuildInputs = [ ];
            buildInputs = [ ];
          };
        };
    };
}
