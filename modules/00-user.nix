{ ... }:

{
  flake.modules.nixos.users =
    { pkgs, ... }:
    {
      users.users.user = {
        isNormalUser = true;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        hashedPassword = "!";
        openssh.authorizedKeys.keys = [ ];
        shell = pkgs.bash;
      };
    };
}
