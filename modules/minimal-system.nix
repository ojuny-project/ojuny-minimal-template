{ self, ... }:

{
  flake.modules.nixos.host-imports = {
    imports = [
      self.modules.nixos.system-configuration
      self.modules.nixos.system-networking
      self.modules.nixos.system-hardware
      self.modules.nixos.system-bootloader
      self.modules.nixos.users
    ];
  };

  flake.modules.nixos.system-configuration =
    { lib, ... }:
    {
      options.ojuny.repoPath = lib.mkOption {
        type = lib.types.str;
        default = "repos/nix-flake";
        description = "Path to the installed flake, relative to the primary user's home or absolute.";
      };

      config = {
        networking.hostName = "ojuny";
        system.stateVersion = "26.11";
        time.timeZone = "UTC";
        i18n.defaultLocale = "en_US.UTF-8";
        console.keyMap = "us";

        nix.settings.experimental-features = [
          "nix-command"
          "flakes"
        ];

        ojuny.repoPath = "repos/nix-flake";
      };
    };

  flake.modules.nixos.system-networking = {
    networking.networkmanager.enable = true;
  };
}
