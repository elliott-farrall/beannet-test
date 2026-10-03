{ config, ... }:

{
  flake.modules.nixos.default = { config, pkgs, ... }: {
    clan.core.vars.generators."github" = {
      share = true;

      prompts."ssh" = {
        description = "GitHub SSH key";
        type = "multiline-hidden";
        persist = true;
      };
    };
    clan.core.vars.generators."azure-devops" = {
      share = true;

      prompts."ssh" = {
        description = "Azure DevOps ssh key";
        type = "multiline-hidden";
        persist = true;
      };
    };

    clan.core.vars.generators."git-host-keys" = {
      share = true;

      files."github-ed25519".secret = false;
      files."github-ecdsa".secret = false;
      files."github-rsa".secret = false;
      files."azure-devops".secret = false;

      runtimeInputs = with pkgs; [ curl gawk jq openssh ];

      script = ''
        mkdir -p $out

        curl -fsSL https://api.github.com/meta \
          | jq -r '.ssh_keys[]' \
          | while read -r key; do
              case "$key" in
                ssh-ed25519*) echo "$key" > $out/github-ed25519 ;;
                ecdsa-sha2-nistp256*) echo "$key" > $out/github-ecdsa ;;
                ssh-rsa*) echo "$key" > $out/github-rsa ;;
              esac
            done

        if [[ ! -s $out/github-ed25519 || ! -s $out/github-ecdsa || ! -s $out/github-rsa ]]; then
          echo "Failed to fetch one or more GitHub SSH host keys" >&2
          exit 1
        fi

        ssh-keyscan -t rsa ssh.dev.azure.com 2>/dev/null \
          | awk '$2 ~ /^(ssh-rsa|ssh-ed25519|ecdsa-sha2-nistp256)$/ { print $2 " " $3 }' > $out/azure-devops

        if [[ ! -s $out/azure-devops ]]; then
          echo "Failed to fetch Azure DevOps SSH host key" >&2
          exit 1
        fi
      '';
    };

    programs.ssh.knownHosts = {
      github-ed25519 = {
        hostNames = [ "github.com" ];
        publicKeyFile = config.clan.core.vars.generators."git-host-keys".files."github-ed25519".path;
      };
      github-ecdsa = {
        hostNames = [ "github.com" ];
        publicKeyFile = config.clan.core.vars.generators."git-host-keys".files."github-ecdsa".path;
      };
      github-rsa = {
        hostNames = [ "github.com" ];
        publicKeyFile = config.clan.core.vars.generators."git-host-keys".files."github-rsa".path;
      };
      azure-devops = {
        hostNames = [ "ssh.dev.azure.com" ];
        publicKeyFile = config.clan.core.vars.generators."git-host-keys".files."azure-devops".path;
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

    programs.ssh.settings = {
      "github.com" = {
        user = "git";
        identityFile = "~/.ssh/credentials/services/github";
      };
      "ssh.dev.azure.com" = {
        user = "git";
        identityFile = "~/.ssh/credentials/services/azure";
      };
    };

    sops.secrets = {
      "github" = {
        sopsFile = "${config.flake.clan.directory}/vars/shared/github/ssh/secret";
        path = ".ssh/credentials/services/github";
        format = "binary";
      };
      "azure" = {
        sopsFile = "${config.flake.clan.directory}/vars/shared/azure-devops/ssh/secret";
        path = ".ssh/credentials/services/azure";
        format = "binary";
      };
    };
  };
}
