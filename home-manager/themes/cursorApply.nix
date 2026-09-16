{ lib, theme, ... }:

# applies the active theme's mouse pointer
# (`cursor`/`cursorH` in a theme file are colors for the text caret, unrelated)
#
# a pointer has no single place to be set, so this is its own module rather than
# part of any one app's: home.pointerCursor writes ~/.icons/default/index.theme
# (wayland compositors, most toolkits), exports XCURSOR_THEME/XCURSOR_SIZE
# (xwayland, qt), and with gtk.enable the gtk setting, which ignores the env vars

{
  # a theme that names no pointer leaves the system on its default
  home.pointerCursor = lib.mkIf (theme ? cursor_theme) {
    inherit (theme.cursor_theme) name package size;
    gtk.enable = true;
  };
}
