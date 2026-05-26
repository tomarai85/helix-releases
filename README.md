# Helix — Free Beta

Multi-pane terminal IDE for macOS: 4 terminals + browser preview in one window.

> **β release.** Free during early access. Sign up at [the landing page](https://landing-page-mu-azure.vercel.app/) for release notes.

## Download

Latest release: see [Releases](https://github.com/tomonoriarai2020-lgtm/helix-releases/releases/latest).

After download, verify the SHA-256 against the `*.sha256` file on the release page:

```sh
shasum -a 256 Helix-<version>.dmg
```

## Installation

1. Open the DMG.
2. Drag **Helix.app** to `/Applications`.
3. On first launch macOS may show a Gatekeeper warning since the beta DMG is not yet notarized. Right-click → **Open** → **Open** to bypass.
4. Settings → SSH host setup is in the in-app **Help** menu.

## System requirements

- macOS 14 (Sonoma) or later
- Apple Silicon recommended (Intel: best-effort)
- ~150 MB disk

## Support

- Bug reports: open an issue in this repo.
- Privacy / refund / legal: see [landing-page/legal](https://landing-page-mu-azure.vercel.app/legal/).

## License

Beta binaries are distributed under the proprietary license shown in the DMG (`LICENSE.txt` inside the app bundle).
This repository is licensed under the MIT License for the surrounding metadata files only — see [LICENSE](./LICENSE).
