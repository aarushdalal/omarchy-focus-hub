# Focus Hub (`omarchy-focus-hub`)

> **Unofficial / Community Project**: An independent open-source study and focus assistant for Omarchy.

A focused productivity dashboard, Pomodoro session controller, ambient audio player, and optional distraction limiter for Omarchy Quickshell.

---

## Status / Experimental Warning

**Focus restrictions are productivity tools, NOT a security boundary.** The distraction limiter operates at the user session level to assist in habit building. It does **never silently terminate user applications without notice** and all domain/process blocking is strictly **opt-in**.

---

## Features

- **Pomodoro Timer**: Configurable focus, short break, and long break intervals with notifications and progress ring.
- **Ambient Sound Generator**: Built-in audio tracks (rain, white noise, cafe) for concentration.
- **Session Statistics & Rewards**: Streak tracking, completed session counts, and celebration animations.
- **Optional App & Website Distraction Controls**:
  - Restrict specified application launches during focus intervals.
  - Tab-level website notice when navigating to configured distraction domains.
  - Quick "allow for 5 minutes" bypass for urgent tasks.

---

## Requirements

- **Operating System**: Arch Linux (rolling release, x86_64)
- **Desktop Shell**: Omarchy (`dev (13f18b2c) / 4.0.2`) with Quickshell (`0.3.1`)
- **Core Dependencies**: `python3`, `bash`, `jq`
- **Optional Dependencies**: `mpv` or `paplay` (for ambient sound and celebration chimes)

---

## Compatibility

| Component | Tested Version | Compatibility Status |
|---|---|---|
| Omarchy | `dev (13f18b2c) / 4.0.2` | Fully compatible |
| Quickshell | `0.3.1` | Fully compatible |
| Hyprland | `0.56.2` | Fully compatible |

---

## Installation

### Method 1: Using Omarchy Plugin Manager

```bash
omarchy plugin add https://github.com/YOUR-USERNAME/omarchy-focus-hub.git --enable
```

### Method 2: Using the Safe User Installer

```bash
git clone https://github.com/YOUR-USERNAME/omarchy-focus-hub.git
cd omarchy-focus-hub

./install.sh check
./install.sh install --dry-run
./install.sh install
```

---

## System Setup Before Installation

1. Copy the example configuration template if desired:
   ```bash
   mkdir -p ~/.config/omarchy
   cp examples/study-mode.example.json ~/.config/omarchy/study-mode.json
   ```
2. Check that user notification daemons (`dunst`, `mako`, or Omarchy notification service) are running.

---

## Usage

- **Bar Widget**: Shows active timer and session status.
- **CLI Commands**:
  ```bash
  omarchy-focus-hub start 25 "Deep Work"   # Start 25-minute focus interval
  omarchy-focus-hub break 5               # Start 5-minute break
  omarchy-focus-hub stop                  # End session
  omarchy-focus-hub status                # Check active timer
  ```

---

## Configuration

Stored in `~/.config/omarchy/study-mode.json`:

```json
{
  "timer": {
    "focus_minutes": 25,
    "short_break_minutes": 5,
    "long_break_minutes": 15
  },
  "restrictions": {
    "block_distractions": false,
    "blocked_binaries": ["steam", "discord"]
  }
}
```

---

## Update

```bash
omarchy plugin update daemon0.focus-hub
```

---

## Uninstall / Rollback

```bash
./install.sh uninstall
```

---

## Security and Privacy

- No personal browsing history or site databases are collected, stored, or sent anywhere.
- Whitelists and blacklists are stored purely locally in plain JSON.

---

## Showcase

> Visual previews, UI screenshots, and recordings for documentation and release verification.

### Main experience

<!-- Future image: assets/showcase/focus_focus.png -->
<!-- ![Main desktop experience](assets/showcase/focus_focus.png) -->

### Feature gallery

<!-- Future image: assets/showcase/focus_focus.png -->
<!-- ![focus_focus.png](assets/showcase/focus_focus.png) -->

<!-- Future image: assets/showcase/focus_ambience.png -->
<!-- ![focus_ambience.png](assets/showcase/focus_ambience.png) -->

<!-- Future image: assets/showcase/focus_apps.png -->
<!-- ![focus_apps.png](assets/showcase/focus_apps.png) -->

<!-- Future image: assets/showcase/focus_stats.png -->
<!-- ![focus_stats.png](assets/showcase/focus_stats.png) -->

<!-- Future image: assets/showcase/focus_websites.png -->
<!-- ![focus_websites.png](assets/showcase/focus_websites.png) -->

<!-- Future image: assets/showcase/feature-06.png -->
<!-- ![Feature preview 6](assets/showcase/feature-06.png) -->

<!-- Future image: assets/showcase/feature-07.png -->
<!-- ![Feature preview 7](assets/showcase/feature-07.png) -->

<!-- Future image: assets/showcase/feature-08.png -->
<!-- ![Feature preview 8](assets/showcase/feature-08.png) -->

<!-- Future image: assets/showcase/feature-09.png -->
<!-- ![Feature preview 9](assets/showcase/feature-09.png) -->

<!-- Future image: assets/showcase/feature-10.png -->
<!-- ![Feature preview 10](assets/showcase/feature-10.png) -->

### Motion and interaction

<!-- Future GIF: assets/showcase/interaction-01.gif -->
<!-- ![Interaction preview](assets/showcase/interaction-01.gif) -->

<!-- Future GIF: assets/showcase/interaction-02.gif -->
<!-- ![Transition preview](assets/showcase/interaction-02.gif) -->

### Video demonstrations

<!-- Future thumbnail: assets/showcase/video-01-thumbnail.png -->
<!-- [![Watch demo video](assets/showcase/video-01-thumbnail.png)](https://github.com/YOUR-USERNAME/PROJECT-NAME/releases) -->


---

## Contributing

Pull requests are welcome!

---

## License

[MIT License](LICENSE).
