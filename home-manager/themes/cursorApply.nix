{ lib, theme, ... }:

# applies the active theme's mouse pointer
# (`cursor`/`cursorH` in a theme file are text caret colors, unrelated)
#
# its own module because a pointer has no single place to be set: home.pointerCursor writes
# ~/.icons/default/index.theme, exports XCURSOR_THEME/XCURSOR_SIZE, and with gtk.enable the gtk setting

{
  # unset leaves the system on its default
  home.pointerCursor = lib.mkIf (theme ? cursor_theme) {
    inherit (theme.cursor_theme) name package size;
    gtk.enable = true;
  };
}
