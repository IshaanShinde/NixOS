import { bind } from "astal";
import Network from "gi://AstalNetwork";

const network = Network.get_default();

export default function NetworkWidget() {
  const wifi = network.wifi;

  if (!wifi) {
    return (
      <button className="widget-button">
        <box>
          <icon icon="network-wired-symbolic" />
          <label label="Wired" />
        </box>
      </button>
    );
  }

  return (
    <button
      className="widget-button"
      onClicked={() => {
        wifi.set_enabled(!wifi.enabled);
      }}
    >
      <box>
        <icon icon={bind(wifi, "iconName")} />
        <box vertical>
          <label
            label={bind(wifi, "ssid").as((ssid) => ssid || "Wi-Fi")}
          />
          <label
            className="section-label"
            label={bind(wifi, "enabled").as((e) => (e ? "On" : "Off"))}
          />
        </box>
      </box>
    </button>
  );
}
