## v0.1.0 — initial public β (2026-05-27)

First public release of Helix β.

**What is Helix**: a multi-pane terminal IDE for macOS. 4 terminals + a browser-preview canvas in one window, optimized for Claude Code / SSH / build / test parallel workflows.

### Highlights

- **Multi-pane layout** — 4 terminals side by side, plus a Preview canvas for iOS simulator / localhost / arbitrary URL
- **WKWebView browser backend** — crash-stable, ~80% adblock coverage via curated tracker list
- **SSH-first workflows** — connect to remote Macs (e.g. mac mini) without leaving the editor
- **Local-first** — no account, no cloud sync, no telemetry beyond opt-in crash reports
- **Free during β**

### Known limitations (β)

- DMG is not yet notarized — first launch requires right-click → Open → Open to bypass Gatekeeper
- Intel Macs are best-effort; Apple Silicon recommended
- Some UI density values still tuned for 14"+ screens

### Verify your download

```sh
shasum -a 256 Helix-0.1.0.dmg
# expected: 144092816c864ddb5febfba33836a27d490b2081942a1f1176be9f4083b89f3f
```
