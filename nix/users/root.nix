{ ... }:

{
  #TODO - root-password clanModule gets auto-imported by admin clanService
  # flake.clan.inventory.instances."root-password" = {
  #   module = {
  #     name = "users";
  #     input = "clan-core";
  #   };
  #   roles.default.tags."nodes" = {};

  #   roles.default.settings.user = "root";
  # };

  flake.clan.inventory.instances."root-ssh" = {
    module = {
      name = "admin";
      input = "clan-core";
    };
    roles.default.tags."nodes" = { };

    roles.default.settings.allowedKeys = {
      "ed25519" = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKUjxl1444qMm7/Xp2MTZIoU31m1j/UsThn5a3ql1lD2";
      "rsa" = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCN/Yz6cpeYKkinW0eVRZxMKwYWkgtGGCM5XTg3MonpTwnsFWloib90GdYnidFfRtRo14tLc166FJ657oPeomgmnpkTWqd0kCuezL4775gpse/1o8AVwgEAYMMACnYqmo+hFls5Y7ZiZ+GYO34W2UUjrZFu9V/OuFOooydcSSNFmobakhxdCyJhurJ5x77xhnBqo3+tgvsHJjv5l4m2SLB5ea5ds/luGequJaXbVn9p5rjMsej0dPF7a46u6RkyQD98442gKzCSGOW0fW/mKaNPtsks57BuPiVeJT2lMHqMRxpYIxx4SeG48jTfdZICkXk9el0V9DLciYS+2vG+kSaAUX8FdbRIblxLJYuWBWL6joFF+sKqJJS/2y9JdJ3qYWOxOjFpqTaZvHzKo9t6XQhB4PD1N7EbvEwq6+XtVde2RB3TOAUAhkiBlbw/svql6U//IVDq6mgwIAhfIRbi9X2BMfiPhOrhsz9TPa047EjoSJHjb9Kr1ItEkcVRwfe8AeSTDb0fs5leMP/aFrKS1D1hqaocABkq4+TuqwtwSpkRzt5v21cZ4gaAG61Qq3Jhe8QETZjGPrGdq1R8AZxo9lT4Rx9OQyixj6tYJ6HfFlgKLq8Z4xfWmmEgn251ySOORGBiNSYBpF2ne/rwzdtZnxAZd/cwI1LtuNw1vb1JC0Gilw==";
    };
  };
}
