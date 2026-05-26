#!/usr/bin/env bash
# cut-and-publish.sh — single-command release: cut GH release + swap LP CTAs +
# deploy LP to Vercel.
#
# Usage:
#   ./scripts/cut-and-publish.sh <version> [<dmg-path>]
#     e.g. ./scripts/cut-and-publish.sh 0.2.0
#
# Pre-condition:
#   - DMG built at ~/Direct/helix/ios/landing-page/Helix-${VERSION}.dmg
#   - gh auth = tomarai85
#   - vercel CLI installed + project linked
#
# Effect (= all-or-nothing best-effort):
#   1. Cut GH release via cut-release.sh
#   2. sed-replace the 4 LP CTA hrefs to new version
#   3. vercel --prod deploy
#   4. Verify live LP returns new URL
#
# Rollback: if step 3 fails, git diff landing-page/index.html shows pending
# changes; reset with `git restore` then re-run.

set -euo pipefail

VERSION="${1:?usage: $0 <version> [<dmg-path>]}"

if [[ ! "$VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-z0-9.]+)?$ ]]; then
    echo "ERROR: VERSION must match X.Y.Z[-suffix], got: $VERSION" >&2
    exit 1
fi

DMG="${2:-$HOME/Direct/helix/ios/landing-page/Helix-${VERSION}.dmg}"
if [[ ! -f "$DMG" ]]; then
    echo "ERROR: DMG not found: $DMG" >&2
    exit 1
fi

LP_DIR="$HOME/Direct/helix/ios/landing-page"
LP_HTML="$LP_DIR/index.html"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Detect current LP version (= the one currently hrefed in CTAs)
CURRENT_VERSION="$(grep -oE 'releases/download/v[0-9]+\.[0-9]+\.[0-9]+/Helix-[0-9]+\.[0-9]+\.[0-9]+\.dmg' "$LP_HTML" | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/^v//' || echo "")"
if [[ -z "$CURRENT_VERSION" ]]; then
    echo "WARN: could not detect current LP version. Skipping pre-flight version diff."
elif [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
    echo "ERROR: LP already points to v${VERSION}. Bump VERSION or rollback LP first." >&2
    exit 1
else
    echo "LP current version: v${CURRENT_VERSION} → swap to v${VERSION}"
fi

echo
echo "=== Step 1/3: cut GH release ==="
"$SCRIPT_DIR/cut-release.sh" "$VERSION" "$DMG"

echo
echo "=== Step 2/3: swap LP CTAs ($CURRENT_VERSION → $VERSION) ==="
if [[ -n "$CURRENT_VERSION" ]]; then
    # macOS sed needs '' after -i; BSD-portable form
    sed -i.bak \
        -e "s|releases/download/v${CURRENT_VERSION}/Helix-${CURRENT_VERSION}\.dmg|releases/download/v${VERSION}/Helix-${VERSION}.dmg|g" \
        "$LP_HTML"
    rm -f "${LP_HTML}.bak"
    SWAP_COUNT="$(grep -cE "releases/download/v${VERSION}/Helix-${VERSION}\.dmg" "$LP_HTML")"
    echo "swapped: ${SWAP_COUNT} CTA href(s)"
    if [[ "$SWAP_COUNT" -lt 1 ]]; then
        echo "ERROR: 0 swaps applied. Aborting before Vercel deploy." >&2
        exit 1
    fi
else
    echo "(no current version detected; LP file may be hand-edited — skipping sed swap.)"
fi

echo
echo "=== Step 3/3: Vercel --prod deploy ==="
cd "$LP_DIR"
vercel --prod --yes 2>&1 | tail -8

echo
echo "=== Verify live LP CTA ==="
sleep 5
LIVE_HREFS="$(curl -fsSL https://landing-page-mu-azure.vercel.app/ 2>&1 | grep -oE "releases/download/v${VERSION}/Helix-${VERSION}\.dmg" | head -1)"
if [[ -n "$LIVE_HREFS" ]]; then
    echo "✅ LP live CTA = v${VERSION}"
else
    echo "⚠️  LP live CTA not yet showing v${VERSION} (= Vercel propagation lag, retry in 30-60s)"
fi

echo
echo "Release pipeline complete: v${VERSION} live on https://github.com/tomarai85/helix-releases/releases/tag/v${VERSION}"
