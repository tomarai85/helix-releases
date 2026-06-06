# Helix — Free Beta

Multi-pane terminal IDE for macOS: 4 terminals + browser preview in one window.

> **β release.** Free during early access. Sign up at [the landing page](https://landing-page-mu-azure.vercel.app/) for release notes.

## What is Helix

A single-window workspace for Mac devs who run multiple things in parallel — Claude Code in one pane, SSH to a remote host in another, build/test output in a third, and a live browser preview alongside. No constant ⌘-tab between apps; the workflow stays in one window.

Built primarily for the Claude Code + Mac mini SSH workflow but the panes are generic — any shell, any preview URL.

## Download

Latest release: see [Releases](https://github.com/tomarai85/helix-releases/releases/latest).

After download, verify the SHA-256 against the `*.sha256` file on the release page:

```sh
shasum -a 256 Helix-<version>.dmg
```

## Installation

1. Open the DMG.
2. Drag **Helix.app** to `/Applications`.
3. On first launch macOS may show a Gatekeeper warning since the beta DMG is not yet notarized. Right-click → **Open** → **Open** to bypass.
4. Settings → SSH host setup is in the in-app **Help** menu.

## Uninstall

1. Quit Helix.
2. Move **Helix.app** from `/Applications` to the Trash.
3. (Optional, full cleanup) remove any Helix-related files from `~/Library/Application Support`, `~/Library/Caches`, `~/Library/Preferences`, and `~/Library/Saved Application State`.

## System requirements

- macOS 14 (Sonoma) or later
- Apple Silicon recommended (Intel: best-effort)
- ~150 MB disk

## Roadmap (= tentative β scope)

- **v0.1.x** — stability + crash fixes (current)
- **v0.2** — multi-window + project tabs
- **v0.3** — snippet library + session bookmarks
- **v1.0** — paid release with App Store distribution

Roadmap is best-effort, single-developer studio. β feedback shapes priority — open an issue if something matters.

## Support

- Bug reports / feature requests: open an issue in this repo (templates available).
- Privacy / refund / legal: see [landing-page/legal](https://landing-page-mu-azure.vercel.app/legal/).

## License

Beta binaries are distributed under the proprietary license shown in the DMG (`LICENSE.txt` inside the app bundle).
This repository is licensed under the MIT License for the surrounding metadata files only — see [LICENSE](./LICENSE).
