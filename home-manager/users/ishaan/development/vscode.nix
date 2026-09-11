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
        anthropic.claude-code
      ];

      userSettings = {

        # UI
        "workbench.colorTheme" = "Bearded Theme Black & Amethyst";
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
        # "window.density.editorTabHeight" = "compact";
        "workbench.editor.showTabs" = "none";

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

        # Claude Code
        "claudeCode.selectedModel" = "us.anthropic.claude-opus-4-6-v1";

        #"claudeCode.selectedModel" = "arn:aws:bedrock:us-east-1:420032682984:inference-profile/us.anthropic.claude-opus-4-6-v1";
        "claudeCode.preferredLocation" = "panel";
        "claudeCode.environmentVariables" = [
          {
            "name" = "AWS_PROFILE";
            "value" = "claudeAgentTest";
          }
          {
            "name" = "AWS_REGION";
            "value" = "us-east-1";
          }
          {
            "name" = "BEDROCK_MODEL_ID";
            "value" = "arn:aws:bedrock:us-east-1:420032682984:inference-profile/us.anthropic.claude-opus-4-6-v1";
          }
          {
            "name" = "CLAUDE_CODE_USE_BEDROCK";
            "value" = "1";
          }
        ];
      };
    };
  };
}
