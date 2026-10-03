{ config, lib, pkgs, theme, ... }:

# columns of panels (clock, wifi, bluetooth, audio) in two layer-shell windows; any user can enable it
let
  cfg = config.menu;

  # the user's theme as GTK named colors and css variables; each panel's own file decides how to use them
  themeCss = pkgs.writeText "menu-theme.css" ''
    @define-color fg #${theme.fg};
    @define-color bg #${theme.bg};
    @define-color fgt alpha(#${theme.fg}, ${toString theme.opacity});
    @define-color bgt alpha(#${theme.bg}, ${toString theme.opacity});
    @define-color accent #${theme.accent};
    @define-color urgent #${theme.urgent};

    .menu {
      font-family: "${theme.fontMono}";
      font-size: ${theme.fontsize}pt;
      --border: ${toString theme.border_size}px;
      --radius: ${toString theme.border_radius}px;
      /* hyprland draws its border outside the rounded window, so the outer corner is rounding plus border */
      --window-radius: ${toString (theme.border_radius + theme.border_size)}px;
    }
  '';

  # Menu.tsx imports it for the window's size and place, and for the border ring CSS can't draw
  layoutJson = pkgs.writeText "menu-layout.json" (builtins.toJSON {
    inherit (cfg) width height offset onEscape;
    border = {
      size = theme.border_size;
      radius = theme.border_radius;
      # hyprland's col.active_border, left to right
      colors = [ "#${theme.accent2 or theme.accent}" "#${theme.accent}" ];
    };
    # the window's background, drawn with the border so the two meet without a seam
    background = { color = "#${theme.bg}"; alpha = theme.opacity; };
  });

  menu = pkgs.ags.bundle {
    pname = "menu";
    version = "0";
    src = ./.;
    enableGtk4 = true;
    # networkmanager: AstalNetwork loads its NM typelib but does not carry it
    dependencies = with pkgs.astal; [ network bluetooth wireplumber pkgs.networkmanager ];
    # generated per user; they only exist inside the build
    postPatch = ''
      cp ${themeCss} theme.css
      cp ${layoutJson} layout.json
    '';
  };

  # what a bind runs; hands "show" or "hide" to the running service in a few ms
  show = pkgs.writeShellScriptBin "menu" ''exec ${pkgs.astal.io}/bin/astal -i menu "$@"'';
in
{
  options.menu = {
    enable = lib.mkEnableOption "the menu panel; `menu show` / `menu hide` open and close it";

    # logical pixels; fixed, so the window always opens in the same place
    width = lib.mkOption { type = lib.types.int; default = 360; };
    height = lib.mkOption { type = lib.types.int; default = 920; };
    offset = lib.mkOption {
      type = lib.types.int;
      default = 0;
      description = "How far left and right of the screen's center the two menu windows' centers sit.";
    };
    onEscape = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Shell command Escape runs while the menu has the keyboard (after a click on it), e.g. closing the launcher it opens with. Empty just hides the menu.";
    };
  };

  # a service: already running when the bind fires, restarted on crash, and onto the new build after a rebuild
  config = lib.mkIf cfg.enable {
    home.packages = [ show ];

    systemd.user.services.menu = {
      Unit = {
        Description = "menu panel";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${menu}/bin/menu";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
