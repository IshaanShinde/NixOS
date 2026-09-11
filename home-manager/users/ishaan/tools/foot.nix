{ theme, ... }:

{
  programs.foot = {
    enable = true;
    settings = {
      main = {
        font = "${theme.fontMono}:size=${theme.fontsize}";
        pad  = "${theme.padding}x0";
      };
      colors = {
        alpha = theme.opacity;

        background = theme.bg;
        foreground = theme.fg;
        
        regular0 = theme.ansi.b00;
        regular1 = theme.ansi.b01;
        regular2 = theme.ansi.b02;
        regular3 = theme.ansi.b03;
        regular4 = theme.ansi.b04;
        regular5 = theme.ansi.b05;
        regular6 = theme.ansi.b06;
        regular7 = theme.ansi.b07;
        bright0  = theme.ansi.b08;
        bright1  = theme.ansi.b09;
        bright2  = theme.ansi.b10;
        bright3  = theme.ansi.b11;
        bright4  = theme.ansi.b12;
        bright5  = theme.ansi.b13;
        bright6  = theme.ansi.b14;
        bright7  = theme.ansi.b15;
      };
    };
  };
}
