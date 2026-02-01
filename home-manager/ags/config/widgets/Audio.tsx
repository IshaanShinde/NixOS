import { bind } from "astal";
import Wp from "gi://AstalWp";

const audio = Wp.get_default()?.audio;

export default function AudioWidget() {
  if (!audio) {
    return (
      <button className="widget-button">
        <box>
          <icon icon="audio-volume-muted-symbolic" />
          <label label="No Audio" />
        </box>
      </button>
    );
  }

  const speaker = audio.defaultSpeaker;

  return (
    <button
      className="widget-button"
      onClicked={() => {
        speaker.mute = !speaker.mute;
      }}
    >
      <box>
        <icon icon={bind(speaker, "volumeIcon")} />
        <box vertical>
          <label label="Audio" />
          <label
            className="section-label"
            label={bind(speaker, "volume").as((v) => `${Math.round(v * 100)}%`)}
          />
        </box>
      </box>
    </button>
  );
}
