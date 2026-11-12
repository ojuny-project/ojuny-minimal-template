{
  description = "Ojuny minimal template - the smallest installable and bootable template";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
  };

  outputs =
    inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        (inputs.import-tree ./modules)
        inputs.flake-parts.flakeModules.modules
      ];

      systems = [ "x86_64-linux" ];

      perSystem =
        { pkgs, ... }:
        let
          generate-hw = pkgs.writeShellApplication {
            name = "generate-hw";
            runtimeInputs = [
              pkgs.python3
              pkgs.nixos-install-tools
              pkgs.nixos-facter
              pkgs.coreutils
              pkgs.gnused
              pkgs.gnugrep
              pkgs.util-linux
              pkgs.sudo
            ];
            text = builtins.readFile ./scripts/generate-hw.sh;
          };

          generate-user = pkgs.writeShellApplication {
            name = "generate-user";
            runtimeInputs = [
              pkgs.python3
              pkgs.mkpasswd
              pkgs.coreutils
            ];
            text = builtins.readFile ./scripts/generate-user.sh;
          };

          create-new-system = pkgs.writeShellApplication {
            name = "create-new-system";
            runtimeInputs = [
              pkgs.python3
              pkgs.coreutils
            ];
            text = builtins.readFile ./scripts/create-new-system.sh;
          };

          check-src = pkgs.runCommand "ojuny-check-src" { } ''
            mkdir -p $out
            cp ${./scripts/check-template.py} $out/check-template.py
            cp ${./scripts/flake_structure.py} $out/flake_structure.py
          '';

          check-template = pkgs.writeShellApplication {
            name = "check-template";
            runtimeInputs = [
              pkgs.python3
              pkgs.nix
            ];
            text = ''
              export TEMPLATE_ROOT=${./.}
              exec python3 ${check-src}/check-template.py --root "$TEMPLATE_ROOT" "$@"
            '';
          };
        in
        {
          apps = {
            generate-hw = {
              type = "app";
              program = "${generate-hw}/bin/generate-hw";
            };
            generate-user = {
              type = "app";
              program = "${generate-user}/bin/generate-user";
            };
            create-new-system = {
              type = "app";
              program = "${create-new-system}/bin/create-new-system";
            };
            check = {
              type = "app";
              program = "${check-template}/bin/check-template";
            };
            setup = {
              type = "app";
              program = "${
                pkgs.writeShellApplication {
                  name = "setup";
                  runtimeInputs = [
                    pkgs.python3
                    pkgs.nixos-install-tools
                    pkgs.nix
                    pkgs.git
                    pkgs.coreutils
                    pkgs.gnused
                    pkgs.gnugrep
                    pkgs.systemd
                    pkgs.sudo
                    generate-hw
                    generate-user
                    create-new-system
                  ];
                  text = builtins.readFile ./scripts/setup.sh;
                }
              }/bin/setup";
            };
          };

          checks.template =
            pkgs.runCommand "check-template-static"
              {
                nativeBuildInputs = [ pkgs.python3 ];
              }
              ''
                python3 ${check-src}/check-template.py --root ${./.} --static
                touch $out
              '';
        };
    };
}
