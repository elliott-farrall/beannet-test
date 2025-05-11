{ inputs, ... }:

{
  imports = with inputs; [ terranix.flakeModule ];

  perSystem = { ... }: {
    terranix.exportDevShells = false;
  };
}
