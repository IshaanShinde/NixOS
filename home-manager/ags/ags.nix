{ ... }:

let
  theme = import ../theme.nix;
in
{
  # AGS config directory
  xdg.configFile."ags" = {
    source = ./config;
    recursive = true;
  };

  # Generate CSS from theme.nix
  xdg.configFile."ags/style.css".text = ''
    * {
      all: unset;
      font-family: monospace;
      font-size: ${theme.fontsize}px;
    }

    .panel {
      background-color: rgba(0, 0, 0, ${toString theme.opacity});
      border: ${toString theme.border_size}px solid #${theme.accent};
      border-radius: ${toString theme.border_radius}px;
      padding: ${theme.padding}px;
      margin: ${theme.margin}px;
    }

    .master {
      min-width: 400px;
      margin-right: ${theme.padding}px;
    }

    .widgets {
      min-width: 200px;
    }

    .widget-button {
      background-color: #${theme.surface};
      color: #${theme.fg};
      padding: 12px;
      margin: 4px;
      border-radius: ${toString theme.border_radius}px;
    }

    .widget-button:hover {
      background-color: #${theme.accent};
      color: #${theme.bg};
    }

    .widget-button:active {
      background-color: #${theme.accent2};
    }

    .widget-button.active {
      background-color: #${theme.accent};
      color: #${theme.bg};
    }

    .search-entry {
      background-color: #${theme.surface};
      color: #${theme.fg};
      padding: 12px;
      margin-bottom: 8px;
      border: ${toString theme.border_size}px solid #${theme.secondary};
      border-radius: ${toString theme.border_radius}px;
    }

    .search-entry:focus {
      border-color: #${theme.accent};
    }

    .app-list {
      background-color: transparent;
    }

    .app-item {
      padding: 8px 12px;
      color: #${theme.fg};
    }

    .app-item:hover {
      background-color: #${theme.surface};
    }

    .app-item:selected,
    .app-item.selected {
      background-color: #${theme.accent};
      color: #${theme.bg};
    }

    .section-label {
      color: #${theme.secondary};
      font-size: 12px;
      padding: 8px;
    }

    .urgent {
      background-color: #${theme.urgent};
    }
  '';
}
