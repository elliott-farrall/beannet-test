{ inputs, ... }:

{
  flake.modules.nixos."default" = { lib, ... }: {
    imports = with inputs; [ clan-core.clanModules.sshd ];

    services.openssh.settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = lib.mkForce true;
    };
  };

  flake.modules.homeManager."default" = { lib, nixosConfig, ... }:
    let
      mkMatchBlock = { hostname, user, port ? 22, identityFile, extraOptions ? { } }:
        {
          "${user}@${hostname}.local" = {
            inherit user port identityFile extraOptions;
            hostname = "localhost";
            match = ''
              user ${user} host ${hostname} exec "nc -z localhost %p"
            '';
          };
          "${user}@${hostname}.tailnet" = {
            inherit hostname user port extraOptions;
            match = ''
              user ${user} host ${hostname} exec "nc -z localhost %p"
            '';
          };
        };
    in
    {
      services.ssh-agent.enable = true;

      programs.ssh = {
        enable = true;

        matchBlocks = lib.mkMerge [

          /* --------------------------------- BeanNet -------------------------------- */

          (mkMatchBlock {
            hostname = "broad";
            user = "root";
            identityFile = nixosConfig.sops.secrets."ssh_root".path;
            port = 2222;
            extraOptions = {
              StrictHostKeyChecking = "no";
              UserKnownHostsFile = "/dev/null";
            };
          })
          (mkMatchBlock {
            hostname = "broad";
            user = "elliott";
            identityFile = nixosConfig.sops.secrets."ssh_elliott".path;
            port = 2222;
            extraOptions = {
              StrictHostKeyChecking = "no";
              UserKnownHostsFile = "/dev/null";
            };
          })
          (mkMatchBlock { hostname = "lima"; user = "root"; identityFile = nixosConfig.sops.secrets."ssh_root".path; })
          (mkMatchBlock { hostname = "lima"; user = "elliott"; identityFile = nixosConfig.sops.secrets."ssh_elliott".path; })

          /* ----------------------------- PythonAnywhere ----------------------------- */

          {
            "ssh.eu.pythonanywhere.com" = {
              user = "ElliottSF";
              identityFile = nixosConfig.sops.secrets."ssh_python-anywhere".path;
            };
          }

          /* ----------------------------------- UoS ---------------------------------- */

          {
            AccessEPS = {
              hostname = "access.eps.surrey.ac.uk";
              user = "es00569";
              identityFile = nixosConfig.sops.secrets."ssh_uos".path;
              forwardX11 = true;
              forwardX11Trusted = true;
            };
            MathsCompute01 = {
              hostname = "maths-compute01";
              user = "es00569";
              identityFile = nixosConfig.sops.secrets."ssh_uos".path;
              forwardX11 = true;
              forwardX11Trusted = true;
              proxyJump = "AccessEPS";
            };
          }

        ];
      };
    };
}
