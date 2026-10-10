.pragma library

// Speaker icon file (in assets/icons) for an output volume of 0..1.
function speakerIcon(volume, muted) {
  if (muted || volume <= 0)
    return "volume_off_black.svg"
  if (volume < 0.25)
    return "volume_mute_black.svg"
  if (volume < 0.50)
    return "volume_down_black.svg"
  return "volume_up_black.svg"
}

// Mic icon file (in assets/icons).
function micIcon(muted) {
  return muted ? "mic_off_black.svg" : "mic_black.svg"
}

// Short display name for a PipeWire device. An exact match in `overrides`
// (full name -> short name) wins; otherwise PipeWire's profile suffixes are
// stripped, e.g. "Foo Analog Stereo" -> "Foo", "Easy Effects Sink" -> "Easy Effects".
function deviceName(node, overrides) {
  if (!node)
    return "None"
  const full = node.description || node.nickname || node.name || "Unknown"
  if (overrides && overrides[full])
    return overrides[full]
  const short = full
      .replace(/\s+(Analog|Digital|Pro)?\s*(Stereo|Mono|Surround\s+[\d.]+)$/i, "")
      .replace(/\s+(Sink|Source)$/i, "")
      .trim()
  return short || full
}
