import { Variable } from "astal";
import { Gtk } from "astal/gtk3";
import Apps from "gi://AstalApps";

const apps = new Apps.Apps();
const query = Variable("");

export default function AppLauncher() {
  const filteredApps = Variable.derive([query], (q) => {
    if (!q) return apps.get_list().slice(0, 20);
    return apps.fuzzy_query(q).slice(0, 20);
  });

  return (
    <box vertical className="app-launcher">
      <entry
        className="search-entry"
        placeholderText="Search applications..."
        onChanged={(self) => query.set(self.text)}
        onActivate={() => {
          const results = filteredApps.get();
          if (results.length > 0) {
            results[0].launch();
          }
        }}
      />
      <scrollable
        vexpand
        hscroll={Gtk.PolicyType.NEVER}
        vscroll={Gtk.PolicyType.AUTOMATIC}
      >
        <box vertical className="app-list">
          {filteredApps().as((list) =>
            list.map((app) => (
              <button
                className="app-item"
                onClicked={() => app.launch()}
              >
                <box>
                  <icon icon={app.iconName || "application-x-executable"} />
                  <label label={app.name} />
                </box>
              </button>
            ))
          )}
        </box>
      </scrollable>
    </box>
  );
}
