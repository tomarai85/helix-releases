#!/usr/bin/env bash
# cut-release.sh — Phase 9 release-cut automation.
# Usage: ./scripts/cut-release.sh <version> [<dmg-path>]
#   e.g. ./scripts/cut-release.sh 0.1.0 ~/Direct/helix/ios/landing-page/Helix-0.1.0.dmg
#
# Pre-condition: gh auth must be tomonoriarai2020-lgtm.
# Effect:
#   1. SHA-256 of DMG
#   2. gh release create <vX.Y.Z> with DMG + sha256
#   3. Prints public URL for LP CTA wiring

set -euo pipefail

VERSION="${1:?usage: $0 <version> [<dmg-path>]}"
DMG="${2:-$HOME/Direct/helix/ios/landing-page/Helix-${VERSION}.dmg}"

if [[ ! -f "$DMG" ]]; then
    echo "ERROR: DMG not found: $DMG" >&2
    exit 1
fi

REPO="tomonoriarai2020-lgtm/helix-releases"
TAG="v${VERSION}"

# Verify gh auth account
ACTIVE_ACCOUNT=$(gh api /user --jq .login 2>/dev/null || echo "")
if [[ "$ACTIVE_ACCOUNT" != "tomonoriarai2020-lgtm" ]]; then
    echo "ERROR: gh auth account is '$ACTIVE_ACCOUNT', expected 'tomonoriarai2020-lgtm'." >&2
    echo "Run: gh auth switch -u tomonoriarai2020-lgtm" >&2
    exit 1
fi

# SHA-256 next to DMG
SHA256_FILE="${DMG}.sha256"
shasum -a 256 "$DMG" | awk '{print $1"  '"$(basename "$DMG")"'"}' > "$SHA256_FILE"
echo "SHA-256: $(cat "$SHA256_FILE")"

# Release notes
NOTES=$(cat <<EOF
Helix β ${VERSION}.

\`\`\`
$(cat "$SHA256_FILE")
\`\`\`

Verify the download:
\`\`\`
shasum -a 256 $(basename "$DMG")
\`\`\`

Free during beta. Sign up at https://landing-page-mu-azure.vercel.app/
EOF
)

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
