{ ... }:

{
  flake.clan.machines."runner" = { lib, config, ... }: {
    config.beannet.domain = "beannet.io";

    options.beannet = let config' = config.beannet; in {
      domain = lib.mkOption {
        type = lib.types.str;
        description = "Domain name for the BeanNet services";
      };
      href = lib.mkOption {
        type = lib.types.str;
        default = "https://${config'.domain}";
        description = "External URL for the BeanNet services";
        readOnly = true;
      };

      ports = {
        http = lib.mkOption {
          type = lib.types.int;
          default = 80;
          description = "HTTP port for Beannet services";
        };
        https = lib.mkOption {
          type = lib.types.int;
          default = 443;
          description = "HTTPS port for Beannet services";
        };
        auth = lib.mkOption {
          type = lib.types.int;
          default = 8443;
          description = "Port for authentication services";
        };
        ldap = lib.mkOption {
          type = lib.types.int;
          default = 3890;
          description = "Port for LDAP services";
        };
      };

      services = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule ({ name, config, ... }: {
          options = {
            name = lib.mkOption {
              type = lib.types.str;
              default = name;
              description = "Name of the service";
              readOnly = true;
            };
            hostname = lib.mkOption {
              type = lib.types.str;
              default = "localhost";
              description = "Hostname of the service";
            };
            port = lib.mkOption {
              type = lib.types.int;
              default = 8080;
              description = "Port on which the service listens";
            };
            url = lib.mkOption {
              type = lib.types.str;
              default = "http://${config.hostname}:${toString config.port}";
              description = "Internal URL for the service";
              readOnly = true;
            };
            domain = lib.mkOption {
              type = lib.types.str;
              default = "${name}.${config'.domain}";
              description = "Domain name for the service";
              readOnly = true;
            };
            href = lib.mkOption {
              type = lib.types.str;
              default = "https://${config.domain}";
              description = "External URL for the service";
              readOnly = true;
            };
            traefikConfig = lib.mkOption {
              default = {
                http.routers.${name} = {
                  rule = "Host(`${config.domain}`)";
                  service = name;
                };
                http.services.${name}.loadBalancer.servers = [
                  { inherit (config) url; }
                ];
              };
              readOnly = true;
            };
            gatusConfig = lib.mkOption {
              default = {
                inherit name;
                inherit (config) url;
                conditions = [ "[STATUS] == 200" ];
              };
              readOnly = true;
            };
          };
        }));
      };
    };
  };
}
