let
  activeTheme = "test";

  themes = {
    test = import ./themes/test.nix;
  };

  selected = themes.${activeTheme};

  toHex = d:
    let
      hexDigits = "0123456789abcdef";
      i = builtins.floor (d * 255);
      high = i / 16;
      low = i - (high * 16);
    in
      "${builtins.substring high 1 hexDigits}${builtins.substring low 1 hexDigits}";
in
  selected // {
    opacityHex = toHex selected.opacity;
    opacityMin = toHex 0.0;
    opacityMax = toHex 1.0;
  }
