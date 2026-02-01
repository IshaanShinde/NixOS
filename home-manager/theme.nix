let
  toHex = d:
    let
      hexDigits = "0123456789abcdef";
      i = builtins.floor (d * 255);
      high = i / 16;
      low = i - (high * 16);
    in
      "${builtins.substring high 1 hexDigits}${builtins.substring low 1 hexDigits}";

  opacity = 0.5;
  opacity_max = 1.0;
in
{
  inherit opacity;
  opacityHex = toHex opacity;
  opacityMax = toHex opacity_max;

  fontsize = "14";
  
  border_size = 0;
  border_radius = 0;

  gaps_in = 4;
  gaps_out = 12;

  padding = "10";
  margin = "10";

  bg = "000000";
  surface = "1a1c1a";
  fg = "e8d5a3";
  secondary = "8a7a5a";
  accent = "d4a524";
  accent2 = "c97b1a";
  urgent = "a63d1a";

  ansi = {
    black = "000000";
    red = "a63d1a";
    green = "5a7a3d";
    yellow = "d4a524";
    blue = "4a5a6a";
    magenta = "8a5a4a";
    cyan = "6a7a5a";
    white = "8a7a5a";
    brightBlack = "1a1c1a";
    brightRed = "c94d24";
    brightGreen = "7a9a5a";
    brightYellow = "e6b830";
    brightBlue = "6a7a8a";
    brightMagenta = "a67a6a";
    brightCyan = "8a9a7a";
    brightWhite = "e8d5a3";
  };
}
