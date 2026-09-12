{ utils }:

# maps a theme's colors onto the gtk named-color set (@define-color), verbatim: no mixing, alpha, or shading
# a name with no source color aliases one that has it, so every color traces back to a literal in the theme file
# a theme's `gtk = { ... }` block overrides any name and is freeform, not an allowlist

theme:

let
  # "f5e0dc" -> "#f5e0dc"; leaves css values (@other_color, rgba(...)) alone
  css = v:
    let s = toString v;
    in if builtins.match "[0-9a-fA-F]{6}" s != null
       || builtins.match "[0-9a-fA-F]{8}" s != null
       then "#${s}"
       else s;

  # a theme key if set, else a fallback
  or' = key: fallback: if theme ? ${key} then theme.${key} else fallback;

  base = {
    # --- core surfaces -------------------------------------------------
    window_bg_color = css theme.bg;
    window_fg_color = css theme.fg;

    view_bg_color = "@window_bg_color";
    view_fg_color = "@window_fg_color";

    headerbar_bg_color = "@window_bg_color";
    headerbar_fg_color = "@window_fg_color";

    sidebar_bg_color = "@window_bg_color";
    sidebar_fg_color = "@window_fg_color";

    dialog_bg_color  = "@window_bg_color";
    dialog_fg_color  = "@window_fg_color";
    popover_bg_color = "@window_bg_color";
    popover_fg_color = "@window_fg_color";

    card_bg_color = "@window_bg_color";
    card_fg_color = "@window_fg_color";

    # --- accent / selection --------------------------------------------
    accent_bg_color = css theme.accent;
    accent_fg_color = css theme.bg;
    accent_color    = css theme.accent;

    theme_selected_bg_color = css (or' "sbg" theme.accent);
    theme_selected_fg_color = css (or' "sfg" theme.fg);

    # --- state ---------------------------------------------------------
    error_bg_color       = css (or' "urgent" theme.ansi.b01);
    error_fg_color       = css theme.fg;
    error_color          = "@error_bg_color";
    destructive_bg_color = "@error_bg_color";
    destructive_fg_color = "@error_fg_color";
    destructive_color    = "@error_bg_color";
    warning_bg_color     = css theme.ansi.b03;
    warning_fg_color     = css theme.bg;
    warning_color        = css theme.ansi.b11;
    success_bg_color     = css theme.ansi.b02;
    success_fg_color     = css theme.bg;
    success_color        = css theme.ansi.b10;

    # --- chrome --------------------------------------------------------
    borders                 = css theme.fg;
    unfocused_borders       = "@borders";
    shade_color             = css theme.bg;
    scrollbar_outline_color = "@window_bg_color";

    insensitive_fg_color   = css theme.ansi.b00;
    insensitive_bg_color   = "@window_bg_color";
    insensitive_base_color = "@window_bg_color";

    # --- gtk3-era aliases ----------------------------------------------
    # older apps (thunar, nemo, gtk2-era dialogs) still ask for these
    theme_bg_color   = "@window_bg_color";
    theme_fg_color   = "@window_fg_color";
    theme_base_color = "@view_bg_color";
    theme_text_color = "@view_fg_color";

    theme_unfocused_bg_color          = "@window_bg_color";
    theme_unfocused_fg_color          = "@window_fg_color";
    theme_unfocused_base_color        = "@view_bg_color";
    theme_unfocused_text_color        = "@view_fg_color";
    theme_unfocused_selected_bg_color = "@theme_selected_bg_color";
    theme_unfocused_selected_fg_color = "@theme_selected_fg_color";

    # --- window manager chrome -----------------------------------------
    wm_bg_a            = "@headerbar_bg_color";
    wm_bg_b            = "@headerbar_bg_color";
    wm_title           = "@headerbar_fg_color";
    wm_unfocused_title = "@headerbar_fg_color";
    wm_border          = "@borders";
    wm_shadow          = "@shade_color";

    # --- thumbnails (icon/grid views) -----------------------------------
    thumbnail_bg_color = "@view_bg_color";
    thumbnail_fg_color = "@view_fg_color";
  };

  # a theme's own gtk block wins; unknown names pass through unchanged
  overrides = builtins.mapAttrs (_: css) (or' "gtk" { });

  colors = base // overrides;

  block = builtins.concatStringsSep "\n"
    (map (n: "@define-color ${n} ${toString colors.${n}};")
      (builtins.attrNames colors));

  # selector that scopes a rule to one app; verify with GTK_DEBUG=interactive <app>
  appScope = {
    thunar = ".thunar";
  };

  # in a css selector list each part stands alone, so every part gets the scope
  # and the suffix (":backdrop"), which must land on the part, not the list
  scopeSel = scope: suffix: sel:
    let
      parts = builtins.filter builtins.isString (builtins.split "," sel);
      trim = s: let m = builtins.match "[[:space:]]*([^[:space:]].*[^[:space:]]|[^[:space:]]?)[[:space:]]*" s;
                in if m == null then s else builtins.head m;
      one = p: let t = trim p;
               in if t == "" then "${scope}${suffix}" else "${scope} ${t}${suffix}";
    in builtins.concatStringsSep ", " (map one parts);

  # an app block in a theme file: { thunar = { ".sidebar" = "background: @window_bg_color;"; }; }
  # gtk styles an unfocused window apart (:backdrop); emitting both keeps the
  # look static, so a rule here means the same focused or not
  appRules = app:
    let
      sels = theme.${app};
      scope = appScope.${app};
      rule = s: "${scopeSel scope "" s}, ${scopeSel scope ":backdrop" s} { ${toString sels.${s}} }";
    in builtins.concatStringsSep "\n" (map rule (builtins.attrNames sels));

  # app blocks the theme actually set
  themed = builtins.filter (app: theme ? ${app}) (builtins.attrNames appScope);

  appBlock = builtins.concatStringsSep "\n\n"
    (map (app: "/* ${app} */\n${appRules app}") themed);
in
{
  # the resolved name -> value map, for anything needing the colors directly
  inherit colors;

  # user gtk.css: loads after the theme's own, so these redefinitions win
  # app rules come after the colors, so they win over both
  css = ''
    /* generated from the active theme; edits here are overwritten */
    ${block}
  '' + (if themed == [ ] then "" else "\n${appBlock}\n");
}
