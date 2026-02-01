import { execAsync } from "astal";

function powerAction(action: string) {
  switch (action) {
    case "lock":
      execAsync(["hyprlock"]);
      break;
    case "suspend":
      execAsync(["systemctl", "suspend"]);
      break;
    case "reboot":
      execAsync(["systemctl", "reboot"]);
      break;
    case "shutdown":
      execAsync(["systemctl", "poweroff"]);
      break;
  }
}

export default function PowerMenu() {
  return (
    <box className="power-menu" homogeneous>
      <button
        className="widget-button"
        tooltipText="Lock"
        onClicked={() => powerAction("lock")}
      >
        <icon icon="system-lock-screen-symbolic" />
      </button>
      <button
        className="widget-button"
        tooltipText="Suspend"
        onClicked={() => powerAction("suspend")}
      >
        <icon icon="system-suspend-symbolic" />
      </button>
      <button
        className="widget-button"
        tooltipText="Reboot"
        onClicked={() => powerAction("reboot")}
      >
        <icon icon="system-reboot-symbolic" />
      </button>
      <button
        className="widget-button urgent"
        tooltipText="Shutdown"
        onClicked={() => powerAction("shutdown")}
      >
        <icon icon="system-shutdown-symbolic" />
      </button>
    </box>
  );
}
