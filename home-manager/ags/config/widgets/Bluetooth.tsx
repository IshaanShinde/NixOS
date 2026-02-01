import { bind } from "astal";
import Bluetooth from "gi://AstalBluetooth";

const bluetooth = Bluetooth.get_default();

export default function BluetoothWidget() {
  return (
    <button
      className={bind(bluetooth, "isPowered").as((p) =>
        p ? "widget-button active" : "widget-button"
      )}
      onClicked={() => {
        bluetooth.toggle();
      }}
    >
      <box>
        <icon
          icon={bind(bluetooth, "isPowered").as((p) =>
            p ? "bluetooth-active-symbolic" : "bluetooth-disabled-symbolic"
          )}
        />
        <box vertical>
          <label label="Bluetooth" />
          <label
            className="section-label"
            label={bind(bluetooth, "isPowered").as((p) => (p ? "On" : "Off"))}
          />
        </box>
      </box>
    </button>
  );
}
