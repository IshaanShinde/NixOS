import { App } from "astal/gtk3";
import style from "./style.css";
import Panel from "./widgets/Panel";

App.start({
  css: style,
  main() {
    Panel();
  },
});
