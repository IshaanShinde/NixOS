{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        kamikillerto.vscode-colorize
        tomoki1207.pdf
        ms-python.python
        ms-python.debugpy
        ms-python.vscode-pylance
      ];

      userSettings = {

        # UI
        "workbench.activityBar.location" = "hidden";
        "workbench.statusBar.visible" = false;
        "workbench.tips.enabled" = false;
        "workbench.editor.enablePreview" = false;
        "workbench.sideBar.location" = "right";
        "workbench.editor.tabActionCloseVisibility" = false;
        "workbench.editor.tabActionUnpinVisibility" = false;

        # Window
        "window.titleBarStyle" = "native";
        "window.customTitleBarVisibility" = "never";
        "window.customMenuBarAltFocus" = false;
        "window.enableMenuBarMnemonics" = false;
        "window.menuBarVisibility" = "hidden";
        "window.density.editorTabHeight" = "compact";

        # Editor
        "editor.minimap.enabled" = false;
        "editor.wordWrap" = "on";
        "editor.wrapOnEscapedLineFeeds" = true;

        # Misc
        "notebook.output.wordWrap" = true;
        "chat.editor.wordWrap" = "on";
        "explorer.confirmDelete" = false;

        # Colorize
        "colorize.hide_current_line_decorations" = false;
        "colorize.colorized_variables" = [ "LESS" "CSS" ];
        "colorize.languages" = [
          "nix" "css" "sass" "scss" "less"
          "postcss" "sss" "stylus" "xml" "svg"
        ];
      };
    };
  };
}
