{ ... }:

{
  flake.modules.homeManager."programs/libreoffice" = { lib, pkgs, config, ... }: {
    home.packages = [
      # TODO - Move to overlay
      (pkgs.symlinkJoin {
        name = "libreoffice";
        paths = [ pkgs.libreoffice-qt-still ];
        postBuild = ''
          install -v ${pkgs.libreoffice-qt-still}/share/applications/base.desktop $out/share/applications/base.desktop
          rm $out/share/applications/base.desktop
          install -v ${pkgs.libreoffice-qt-still}/share/applications/calc.desktop $out/share/applications/calc.desktop
          rm $out/share/applications/calc.desktop
          install -v ${pkgs.libreoffice-qt-still}/share/applications/draw.desktop $out/share/applications/draw.desktop
          rm $out/share/applications/draw.desktop
          install -v ${pkgs.libreoffice-qt-still}/share/applications/impress.desktop $out/share/applications/impress.desktop
          rm $out/share/applications/impress.desktop
          install -v ${pkgs.libreoffice-qt-still}/share/applications/math.desktop $out/share/applications/math.desktop
          rm $out/share/applications/math.desktop
          install -v ${pkgs.libreoffice-qt-still}/share/applications/writer.desktop $out/share/applications/writer.desktop
          rm $out/share/applications/writer.desktop
          install -v ${pkgs.libreoffice-qt-still}/share/applications/xsltfilter.desktop $out/share/applications/xsltfilter.desktop
          rm $out/share/applications/xsltfilter.desktop
        '';
      })
    ];

    xdg.configFile."libreoffice/4/user/registrymodifications.xcu" = {
      text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <oor:items xmlns:oor="http://openoffice.org/2001/registry" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">

        <item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="FirstRun" oor:op="fuse"><value>false</value></prop></item>
        <item oor:path="/org.openoffice.Office.Common/Misc"><prop oor:name="ShowTipOfTheDay" oor:op="fuse"><value>false</value></prop></item>

        <item oor:path="/org.openoffice.Office.UI.ToolbarMode"><prop oor:name="ActiveCalc" oor:op="fuse"><value>notebookbar.ui</value></prop></item>
        <item oor:path="/org.openoffice.Office.UI.ToolbarMode"><prop oor:name="ActiveDraw" oor:op="fuse"><value>notebookbar.ui</value></prop></item>
        <item oor:path="/org.openoffice.Office.UI.ToolbarMode"><prop oor:name="ActiveImpress" oor:op="fuse"><value>notebookbar.ui</value></prop></item>
        <item oor:path="/org.openoffice.Office.UI.ToolbarMode"><prop oor:name="ActiveWriter" oor:op="fuse"><value>notebookbar.ui</value></prop></item>
        <item oor:path="/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Calc']"><prop oor:name="Active" oor:op="fuse"><value>notebookbar.ui</value></prop></item>
        <item oor:path="/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Draw']"><prop oor:name="Active" oor:op="fuse"><value>notebookbar.ui</value></prop></item>
        <item oor:path="/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Impress']"><prop oor:name="Active" oor:op="fuse"><value>notebookbar.ui</value></prop></item>
        <item oor:path="/org.openoffice.Office.UI.ToolbarMode/Applications/org.openoffice.Office.UI.ToolbarMode:Application['Writer']"><prop oor:name="Active" oor:op="fuse"><value>notebookbar.ui</value></prop></item>

        </oor:items>
      '';
      force = true;
    };

    programs.waybar.settings.mainBar."hyprland/workspaces".window-rewrite = lib.mkIf config.programs.waybar.enable {
      "libreoffice" = "󱇧";
    };
  };
}
