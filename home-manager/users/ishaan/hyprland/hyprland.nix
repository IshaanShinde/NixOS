{ theme, ... }:

{
  xdg.portal.config.common.default = [ "hyprland" "gtk" ];
  
  wayland.windowManager.hyprland = {
    enable = true;
    package = null;  # Use package from NixOS module
    systemd.enable = true;
    systemd.variables = ["--all"];
    xwayland.enable = true;
    settings.xwayland.force_zero_scaling = true;
    
    settings = {
      # Monitors
      # DP-4 (4k) at scale 1.6 => 2400x1350 logical, anchored at origin.
      # HDMI-A-2 sits to its left, so it starts at -1920.
      monitor = [
        "DP-4, 3840x2160@59.99700, 0x0, 1.6"
        "HDMI-A-2, 1920x1080@165, -1920x0, 1"
      ];

      # Workspaces 1-10 all live on the 4k (super+number switches between them).
      # HDMI-A-2 owns workspace 11 permanently; nothing switches it away.
      workspace = [
        "1, monitor:DP-4, default:true"
        "2, monitor:DP-4"
        "3, monitor:DP-4"
        "4, monitor:DP-4"
        "5, monitor:DP-4"
        "6, monitor:DP-4"
        "7, monitor:DP-4"
        "8, monitor:DP-4"
        "9, monitor:DP-4"
        "10, monitor:DP-4"
        "11, monitor:HDMI-A-2, default:true, persistent:true"
      ];
      
      # Programs
      "$terminal" = "foot";
      "$fileManager" = "thunar";
      "$menu" = "rofi -show drun";
      "$mainMod" = "SUPER";
      
      # Environment variables
      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      # NVIDIA cursor fix (replaces deprecated WLR_NO_HARDWARE_CURSORS)
      cursor = {
        no_hardware_cursors = true;
      };
      
      # General
      general = {
        gaps_in = theme.gaps_in;
        gaps_out = theme.gaps_out;
        border_size = theme.border_size;
        "col.active_border" = "rgba(${theme.accent}${theme.opacityMax}) rgba(${theme.accent2}${theme.opacityMax}) 180deg";
        "col.inactive_border" = "rgba(${theme.sbg}${theme.opacityHex})";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };
      
      # Decoration
      decoration = {
        rounding = theme.border_radius;
        rounding_power = 2;
        active_opacity = 1.0;
        inactive_opacity = 1.0;
        
        shadow.enabled = false;
        blur.enabled = false;
      };
      
      # Animations
      animations = {
        enabled = true;
        
        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0.05, 0.36, 1"
          "linear, 0, 0, 1, 1"
          "almostLinear, 0.5, 0.5, 0.75, 1"
          "quick, 0.15, 0, 0.1, 1"
        ];
        
        animation = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
          "zoomFactor, 1, 7, quick"
        ];
      };
      
      # Layouts
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Misc
      misc = {
        force_default_wallpaper = -1;
        disable_hyprland_logo = true;
      };
      
      # Input
      input = {
        kb_layout = "us";
        follow_mouse = 2;
        sensitivity = 0;
        
        touchpad = {
          natural_scroll = false;
        };
      };
      
     
      # Keybinds
      bind = [
        "$mainMod, Q, exec, $terminal"
        "$mainMod, C, killactive,"
        "$mainMod, M, exit,"
        "$mainMod, E, exec, $fileManager"
        "$mainMod, V, togglefloating,"
        "$mainMod, R, exec, $menu"
        "$mainMod, i, pseudo,"
        "$mainMod, u, togglesplit,"
        
        # Move focus
        "$mainMod, h, movefocus, l"
        "$mainMod, j, movefocus, d"
        "$mainMod, k, movefocus, u"
        "$mainMod, l, movefocus, r"
        
        # Switch workspaces
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"
        
        # Move window to workspace
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"
        
        # Scratchpad
        "$mainMod, S, togglespecialworkspace, magic"
        "$mainMod SHIFT, S, movetoworkspace, special:magic"
        
        # Scroll workspaces (r = wrap within 1-10, so scrolling never
        # lands on the HDMI-A-2 workspace)
        "$mainMod, mouse_down, workspace, r+1"
        "$mainMod, mouse_up, workspace, r-1"
      ];
      
      # Mouse binds
      bindm = [
        "$mainMod, mouse:272, movewindow"
        "$mainMod, mouse:273, resizewindow"
      ];
      
      # Media keys
      bindel = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+"
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
      ];
      
      bindl = [
        ",XF86AudioNext, exec, playerctl next"
        ",XF86AudioPause, exec, playerctl play-pause"
        ",XF86AudioPlay, exec, playerctl play-pause"
        ",XF86AudioPrev, exec, playerctl previous"
      ];
      
      # Window rules
      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0"
      ];
      
      # Startup
      exec-once = [];
    };
  };
}
