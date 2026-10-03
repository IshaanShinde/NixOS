import { App } from "astal/gtk4"
import theme from "./theme.css"
import Menu, { css } from "./Menu"

// runs as a service, hidden; `menu show` / `menu hide` (see default.nix) arrive here
App.start({
  instanceName: "menu",
  css: theme + css,
  main: Menu,
  requestHandler(request, res) {
    for (const window of App.get_windows()) {
      if (request === "show") window.show()
      if (request === "hide") window.hide()
    }
    res("ok")
  },
})
