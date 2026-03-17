#!/bin/zsh
# ==============================================================================
# Mac Dev Ready — Bootstrap installer
# Run this on a fresh Mac with nothing installed. Uses only curl + zsh (default).
#
#   zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Strapouchniek/mac-dev-ready/main/install.sh)"
# ==============================================================================

set -euo pipefail

BASE_URL="https://raw.githubusercontent.com/Strapouchniek/mac-dev-ready/main"
TMP_DIR="${TMPDIR:-/tmp}/mac-dev-ready-$$"
MODULES="utils admin xcode homebrew git node omz"

echo "Downloading Mac Dev Ready..."
mkdir -p "$TMP_DIR/modules"

curl -fsSL -o "$TMP_DIR/setup.sh" "$BASE_URL/setup.sh"
for m in $=MODULES; do
  curl -fsSL -o "$TMP_DIR/modules/${m}.sh" "$BASE_URL/modules/${m}.sh"
done

chmod +x "$TMP_DIR/setup.sh"
MAC_DEV_READY_DIR="$TMP_DIR" zsh "$TMP_DIR/setup.sh"

rm -rf "$TMP_DIR"
