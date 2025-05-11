{ ... }:

{
  flake.modules.homeManager."default" = { nixosConfig, ... }: {
    programs.git = {
      enable = true;
      userName = "elliott-farrall";
      userEmail = "108588212+elliott-farrall@users.noreply.github.com";
    };

    programs.gh = {
      enable = true;
    };

    programs.ssh.matchBlocks = {
      "github.com".identityFile = nixosConfig.sops.secrets."ssh_github".path;
      "dev.azure.com".identityFile = nixosConfig.sops.secrets."ssh_azure".path;
    };
  };
}
