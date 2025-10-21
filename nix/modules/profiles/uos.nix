{ ... }:

{
  flake.modules.nixos."profiles/uos" = { lib, pkgs, config, ... }: {
    networking.networkmanager.ensureProfiles = lib.mkIf config.networking.networkmanager.enable {
      environmentFiles = [ config.clan.core.vars.generators."uos".files."env".path ];
      profiles.eduroam = {
        connection = {
          id = "eduroam";
          uuid = "6f750d2a-845d-45e9-aa65-17a23736aff4";
          type = "wifi";
          permissions = "user:elliott:;";
        };
        wifi = {
          ssid = "eduroam";
        };
        wifi-security = {
          key-mgmt = "wpa-eap";
        };
        ipv4 = {
          method = "auto";
        };
        ipv6 = {
          addr-gen-mode = "default";
          method = "auto";
        };
        "802-1x" = {
          eap = "peap";
          identity = "$UOS_USERNAME";
          password = "$UOS_PASSWORD";
          phase2-auth = "mschapv2";
        };
      };
    };

    services.printing.drivers = [
      (pkgs.writeTextDir "share/cups/model/Samsung_X7600_Series.ppd" (pkgs.fetchurl {
        url = "https://www.openprinting.org/ppd-o-matic.php?driver=Postscript-Samsung&printer=Samsung-X7600";
        hash = "sha256-0+858L5cQTm/5phGQpttUfkIHGSInX/iWgjXnKC6kWQ=";
      }))
    ];

    hardware.printers.ensurePrinters = [
      {
        name = "SurreyPrint";
        description = "Surrey Print Service (Old)";
        location = "University of Surrey";

        deviceUri = "lpd://es00569@printservice.surrey.ac.uk/surreyprint";
        model = "Samsung_X7600_Series.ppd";
        ppdOptions = {
          Option1 = "True"; # Duplexer
          Duplex = "DuplexNoTumble";
          PageSize = "A4";
        };
      }
      {
        name = "PrintSurrey";
        description = "Surrey Print Service (New)";
        location = "University of Surrey";

        deviceUri = "lpd://es00569@printservice.surrey.ac.uk/printsurrey";
        model = "Samsung_X7600_Series.ppd";
        ppdOptions = {
          Option1 = "True"; # Duplexer
          Duplex = "DuplexNoTumble";
          PageSize = "A4";
        };
      }
    ];

    clan.core.vars.generators."uos" = {
      share = true;

      files."env" = { };

      prompts."email" = {
        description = "UoS email address";
      };
      prompts."password" = {
        description = "UoS password";
        type = "hidden";
      };
      prompts."key" = {
        description = "UoS private key";
        type = "multiline-hidden";
        persist = true;
      };

      script = ''
        cat <<EOF > $out/env
        UOS_USERNAME=$(cat $prompts/email)
        UOS_PASSWORD=$(cat $prompts/password)
        EOF
      '';
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

    wayland.windowManager.hyprland.settings.monitor = [
      "desc:Crestron Electronics Inc. Crestron, preferred, auto, auto, mirror, ${nixosConfig.display.output}"
      "desc:Crestron Electronics Inc. Crestron 420, preferred, auto, auto, mirror, ${nixosConfig.display.output}"
      "desc: Sony SONY TV, preferred, auto, auto, mirror, ${nixosConfig.display.output}"
    ];
  };
}
