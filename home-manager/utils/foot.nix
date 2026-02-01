{ ... }:

let
  theme = import ../theme.nix;
in
{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "monospace:size=14";
      };
      colors = {
        alpha = theme.opacity;
        background = theme.ansi.black;
        foreground = theme.ansi.brightWhite;
        
        regular0 = theme.ansi.black;
        regular1 = theme.ansi.red;
        regular2 = theme.ansi.green;
        regular3 = theme.ansi.yellow;
        regular4 = theme.ansi.blue;
        regular5 = theme.ansi.magenta;
        regular6 = theme.ansi.cyan;
        regular7 = theme.ansi.white;
      
        bright0 = theme.ansi.brightBlack;
        bright1 = theme.ansi.brightRed;
        bright2 = theme.ansi.brightGreen;
        bright3 = theme.ansi.brightYellow;
        bright4 = theme.ansi.brightBlue;
        bright5 = theme.ansi.brightMagenta;
        bright6 = theme.ansi.brightCyan;
        bright7 = theme.ansi.brightWhite;
      };
    };
  };
}
