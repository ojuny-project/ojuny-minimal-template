{ ... }:

{
  flake.modules.nixos.system-hardware =
    { lib, ... }:
    {
      fileSystems."/" = lib.mkDefault {
        device = "/dev/sda1";
        fsType = "ext4";
      };
    };

  flake.modules.nixos.system-bootloader =
    { lib, ... }:
    {
      boot.loader.grub.enable = lib.mkDefault true;
      boot.loader.grub.devices = lib.mkDefault [ "/dev/sda" ];
    };
}
