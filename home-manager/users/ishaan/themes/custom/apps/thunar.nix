# selector -> declarations; themes/gtk.nix scopes each to `.thunar` and emits
# it for both states, so a rule here means the same focused or not

{
  # the window tints at the theme opacity; inner surfaces clear so it shows
  "" = "background: alpha(@window_bg_color, 0.67);";
  ".background" = "background: transparent;";
  "headerbar, .titlebar" = "background: transparent;";
  "menubar, menubar > menuitem" = "background: transparent;";
  "toolbar, .toolbar" = "background: transparent;";
  # the path bar is a box of buttons; clear the strip, keep the buttons
  "box.horizontal, .linked" = "background: transparent;";
  ".sidebar, placessidebar, placessidebar list" = "background: transparent;";
  "scrolledwindow, treeview.view, .view" = "background: transparent;";
  "notebook, notebook stack" = "background: transparent;";
  # the paned separator is the divider; drop the sidebar's own edge so the
  # two do not stack into a double line
  ".sidebar:not(separator)" = "border-right-style: none; border-left-style: none;";
}
