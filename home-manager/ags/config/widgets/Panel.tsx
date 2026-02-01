import { App, Astal, Gdk } from "astal/gtk3";
import { Variable } from "astal";
import AppLauncher from "./AppLauncher";
import NetworkWidget from "./Network";
import BluetoothWidget from "./Bluetooth";
import AudioWidget from "./Audio";
import PowerMenu from "./PowerMenu";

const visible = Variable(false);

export function togglePanel() {
  visible.set(!visible.get());
}

export default function Panel() {
  return (
    <window
      name="panel"
      className="panel"
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.BOTTOM}
      exclusivity={Astal.Exclusivity.NORMAL}
      keymode={Astal.Keymode.ON_DEMAND}
      visible={visible()}
      application={App}
      onKeyPressEvent={(self, event) => {
        if (event.get_keyval()[1] === Gdk.KEY_Escape) {
          visible.set(false);
        }
      }}
    >
      <box className="panel-container" vertical={false}>
        {/* Master - App Launcher */}
        <box className="master" vertical>
          <AppLauncher />
        </box>

        {/* Widgets Grid */}
        <box className="widgets" vertical>
          <label className="section-label" label="Quick Settings" />
          <box className="widget-grid" vertical>
            <NetworkWidget />
            <BluetoothWidget />
            <AudioWidget />
          </box>
          <box className="spacer" vexpand />
          <PowerMenu />
        </box>
      </box>
    </window>
  );
}
