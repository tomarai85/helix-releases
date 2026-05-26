#!/usr/bin/env bash
# cut-release.sh — Phase 9 release-cut automation.
# Usage: ./scripts/cut-release.sh <version> [<dmg-path>]
#   e.g. ./scripts/cut-release.sh 0.1.0 ~/Direct/helix/ios/landing-page/Helix-0.1.0.dmg
#
# Pre-condition: gh auth must be tomarai85.
# Effect:
#   1. SHA-256 of DMG
#   2. gh release create <vX.Y.Z> with DMG + sha256
#   3. Prints public URL for LP CTA wiring

set -euo pipefail

VERSION="${1:?usage: $0 <version> [<dmg-path>]}"

# Codex fix MEDIUM #13: validate VERSION format first (= prevent shell-injection
# via $() in DMG path expansion + cleaner error)
if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-z0-9.]+)?$ ]]; then
    echo "ERROR: VERSION must match X.Y.Z[-suffix], got: $VERSION" >&2
    exit 1
fi

DMG="${2:-$HOME/Direct/helix/ios/landing-page/Helix-${VERSION}.dmg}"

if [[ ! -f "$DMG" ]]; then
    echo "ERROR: DMG not found: $DMG" >&2
    exit 1
fi

REPO="tomarai85/helix-releases"
TAG="v${VERSION}"

# Verify gh auth account
ACTIVE_ACCOUNT=$(gh api /user --jq .login 2>/dev/null || echo "")
if [[ "$ACTIVE_ACCOUNT" != "tomarai85" ]]; then
    echo "ERROR: gh auth account is '$ACTIVE_ACCOUNT', expected 'tomarai85'." >&2
    echo "Run: gh auth switch -u tomarai85" >&2
    exit 1
fi

# Codex fix MEDIUM #12: refuse if tag already exists (= prevent partial-release orphans)
if gh release view "$TAG" --repo "$REPO" &>/dev/null; then
    echo "ERROR: release $TAG already exists in $REPO. Delete it first or bump VERSION." >&2
    exit 1
fi

# SHA-256 next to DMG
# Codex fix MEDIUM #11: portable construction tolerating spaces in filename
SHA256_FILE="${DMG}.sha256"
SHA256_HEX="$(shasum -a 256 "$DMG" | awk '{print $1}')"
printf '%s  %s\n' "$SHA256_HEX" "$(basename "$DMG")" > "$SHA256_FILE"
echo "SHA-256: $(cat "$SHA256_FILE")"

DMG_SIZE_BYTES="$(stat -f%z "$DMG")"
DMG_SIZE_MB="$(awk -v b="$DMG_SIZE_BYTES" 'BEGIN { printf "%.1f", b/1024/1024 }')"

# Optional changelog file at ./CHANGELOG-<version>.md (= source of "What's new")
CHANGELOG_PATH="$(dirname "$0")/../CHANGELOG-${VERSION}.md"
if [[ -f "$CHANGELOG_PATH" ]]; then
    WHATS_NEW_SECTION="$(cat "$CHANGELOG_PATH")"
else
    WHATS_NEW_SECTION="(See commit log; no changelog file at CHANGELOG-${VERSION}.md.)"
fi

# Release notes
# Codex fix MEDIUM #13: HEREDOC quoted to suppress shell injection of $();
# specific substitutions inlined via sed.
NOTES_TEMPLATE=$(cat <<'EOF'
# Helix β __VERSION__

Mac multi-pane terminal IDE. Free during early access.

## Download

- File: `__BASENAME__` (__SIZE_MB__ MB)
- SHA-256:
  ```
  __SHA__
  ```

Verify after download:
```sh
shasum -a 256 __BASENAME__
```

## What's new

__WHATS_NEW__

## Install

1. Open the DMG.
2. Drag **Helix.app** to `/Applications`.
3. First launch: macOS may show a Gatekeeper warning since β is not yet notarized → right-click **Open** → **Open**.

## System requirements

- macOS 14 (Sonoma) or later
- Apple Silicon recommended

## Support / feedback

- Issue: open one in this repo.
- LP / privacy / refund: https://landing-page-mu-azure.vercel.app/
EOF
)
NOTES="${NOTES_TEMPLATE//__VERSION__/$VERSION}"
NOTES="${NOTES//__BASENAME__/$(basename "$DMG")}"
NOTES="${NOTES//__SIZE_MB__/$DMG_SIZE_MB}"
NOTES="${NOTES//__SHA__/$SHA256_HEX}"
# bash parameter expansion can't do multiline-safe; use python for the last
PY="$(/usr/bin/env python3 -c "
import sys
template = sys.stdin.read()
whats_new = '''$(printf '%s' "$WHATS_NEW_SECTION" | sed "s/'/'\\\\\\\\''/g")'''
print(template.replace('__WHATS_NEW__', whats_new))
" <<<"$NOTES")"
NOTES="$PY"

echo "=== Creating release ${TAG} on ${REPO} ==="
gh release create "$TAG" "$DMG" "$SHA256_FILE" \
    --repo "$REPO" \
    --title "Helix β ${VERSION}" \
    --notes "$NOTES"

# Print the public download URL
RELEASE_URL=$(gh release view "$TAG" --repo "$REPO" --json url --jq .url)
DMG_URL="https://github.com/${REPO}/releases/download/${TAG}/$(basename "$DMG")"

echo ""
echo "✅ Release published."
echo "Release page: $RELEASE_URL"
echo "Direct DMG download URL (wire into LP CTA):"
echo "  $DMG_URL"
