{ lib, inputs, ... }:

let
  editorconfig = {
    root = true;

    "*" = {
      end_of_line = "lf";
      insert_final_newline = true;
      trim_trailing_whitespace = true;
      charset = "utf-8";
    };

    "*.{json,nix,toml,yaml,yml}" = {
      indent_style = "space";
      indent_size = 2;
    };

    "*.sh" = {
      indent_style = "space";
      indent_size = 2;
    };

    "*.{diff,patch}" = {
      trim_trailing_whitespace = false;
    };
  };
in
{
  perSystem = { system, ... }: {
    make-shells.default.shellHook = lib.concatLines [
      (inputs.nixago.lib.${system}.make { data = editorconfig; output = ".editorconfig"; format = "toml"; }).shellHook
    ];
  };
}
