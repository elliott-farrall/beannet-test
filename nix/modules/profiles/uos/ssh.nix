{ ... }:

{
  flake.modules.nixos."profiles/uos" = { ... }: {
    clan.core.vars.generators."uos" = {
      share = true;

      prompts."key" = {
        description = "UoS private key";
        type = "multiline-hidden";
        persist = true;
      };
    };
  };

  flake.modules.homeManager."profiles/uos" = { nixosConfig, ... }: {
    programs.ssh.matchBlocks = {
      AccessEPS = {
        hostname = "access.eps.surrey.ac.uk";
        user = "es00569";
        identityFile = nixosConfig.clan.core.vars.generators."uos".files."key".path;
        forwardX11 = true;
        forwardX11Trusted = true;
      };
      MathsCompute01 = {
        hostname = "maths-compute01";
        user = "es00569";
        identityFile = nixosConfig.clan.core.vars.generators."uos".files."key".path;
        forwardX11 = true;
        forwardX11Trusted = true;
        proxyJump = "AccessEPS";
      };
    };
  };
}
