{ ... }:

{
  flake.modules.nixos."default" = { ... }: {
    clan.core.vars.generators."github" = {
      share = true;

      prompts."key" = {
        description = "GitHub ssh key";
        type = "multiline-hidden";
        persist = true;
      };
    };

    clan.core.vars.generators."azure" = {
      share = true;

      prompts."key" = {
        description = "Azure ssh key";
        type = "multiline-hidden";
        persist = true;
      };
    };
  };

  flake.modules.homeManager."default" = { nixosConfig, ... }: {
    programs.git = {
      enable = true;
      userName = "Elliott Farrall";
      userEmail = "dev@elliott-farrall.phd";
    };

    programs.gh = {
      enable = true;
    };

    programs.ssh.matchBlocks = {
      "github.com".identityFile = nixosConfig.clan.core.vars.generators."github".files."key".path;
      "dev.azure.com".identityFile = nixosConfig.clan.core.vars.generators."azure".files."key".path;
    };
  };
}
