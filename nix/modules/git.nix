{ config, ... }:

{
  flake.modules.nixos.default = { ... }: {
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
        description = "Azure DevOps ssh key";
        type = "multiline-hidden";
        persist = true;
      };
    };
  };

  flake.modules.homeManager.default = { ... }: {
    programs.git = {
      enable = true;
      settings.user.name = "Elliott Farrall";
      settings.user.email = "dev@elliott-farrall.phd";
    };

    programs.gh = {
      enable = true;
    };

    programs.ssh.matchBlocks = {
      "github.com".identityFile = "~/.ssh/credentials/services/github";
      "ssh.dev.azure.com".identityFile = "~/.ssh/credentials/services/azure";
    };

    sops.secrets = {
      "github" = {
        sopsFile = "${config.flake.clan.directory}/vars/shared/github/key/secret";
        path = ".ssh/credentials/services/github";
        format = "binary";
      };
      "azure" = {
        sopsFile = "${config.flake.clan.directory}/vars/shared/azure/key/secret";
        path = ".ssh/credentials/services/azure";
        format = "binary";
      };
    };
  };
}
