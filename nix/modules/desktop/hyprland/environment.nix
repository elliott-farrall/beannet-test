{ ... }:

{
  flake.modules.homeManager."desktop/hyprland" = { pkgs, nixosConfig, ... }: {
    assertions = [
      {
        assertion = nixosConfig.services.pipewire.enable or true;
        message = "Hyprland requires PipeWire to be enabled for screensharing";
      }
      {
        assertion = nixosConfig.services.pipewire.wireplumber.enable or true;
        message = "Hyprland requires WirePlumber to be enabled for screensharing";
      }
    ];

    home.sessionVariables.NIXOS_OZONE_WL = 1;

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [ xdg-desktop-portal-hyprland xdg-desktop-portal-gtk ];
      configPackages = with pkgs; [ hyprland ];
    };
  };
}
