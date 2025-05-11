{ inputs, ... }:

{
  imports = with inputs; [ make-shell.flakeModules.default ];
}
