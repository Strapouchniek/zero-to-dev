#!/bin/zsh
# ==============================================================================
#
#   Mac Dev Ready
#   One-command setup for non-technical team members.
#
#   Usage (local):   zsh setup.sh
#   Usage (remote):  Clone the repo first, then run:
#                    MAC_DEV_READY_DIR=/path/to/mac-dev-ready zsh setup.sh
#
# ==============================================================================

set -euo pipefail

# ── Resolve script location ──────────────────────────────────────────────────
# When run locally, ${0:a:h} gives the script's directory.
# When piped from curl, $0 is "-zsh" so we fall back to MAC_DEV_READY_DIR or pwd.

if [[ -f "${0:a}" ]]; then
    SCRIPT_DIR="${0:a:h}"
elif [[ -n "${MAC_DEV_READY_DIR:-}" ]]; then
    SCRIPT_DIR="$MAC_DEV_READY_DIR"
else
    SCRIPT_DIR="$(pwd)"
fi

MODULES_DIR="$SCRIPT_DIR/modules"

# ── Source shared utilities ───────────────────────────────────────────────────
if [[ ! -f "$MODULES_DIR/utils.sh" ]]; then
    echo "Error: Could not find modules/utils.sh"
    echo "Make sure you run this script from the mac-dev-ready/ directory,"
    echo "or that the modules/ folder is next to setup.sh."
    exit 1
fi

source "$MODULES_DIR/utils.sh"

# ── Log file ──────────────────────────────────────────────────────────────────
# Installer output is redirected here so non-technical users don't see a wall
# of text. On failure, users are asked to share this file with their team.
LOG_FILE="/tmp/mac-dev-ready.log"
export LOG_FILE
: > "$LOG_FILE"
chmod 600 "$LOG_FILE"

# ── Welcome ───────────────────────────────────────────────────────────────────

clear
echo ""
printf "${BOLD}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║                                                  ║"
echo "  ║                  Mac Dev Ready                   ║"
echo "  ║                                                  ║"
echo "  ║   This script will install the tools you need    ║"
echo "  ║   to work with Cursor and create Pull Requests   ║"
echo "  ║   on GitHub.                                     ║"
echo "  ║                                                  ║"
printf "  ║              made with ${RED}<3${RESET}${BOLD} by nicochat            ║\n"
echo "  ╚══════════════════════════════════════════════════╝"
printf "${RESET}"
echo ""

info "Tools that will be installed:"
echo "    1. Xcode Command Line Tools  (Apple developer essentials)"
echo "    2. Homebrew                  (package manager)"
echo "    3. Git                       (version control)"
echo "    4. Node.js                   (JavaScript runtime)"
echo "    5. Oh My Zsh                 (better terminal)"
echo ""
info "Estimated time: 15–40 minutes (depending on your internet speed)"
echo ""

# ── Pre-flight checks ────────────────────────────────────────────────────────

require_macos
success "Running on macOS — good."

require_macos_version
success "macOS version — good."

require_internet
success "Internet connection — good."

source "$MODULES_DIR/admin.sh"
require_admin_or_migrate

echo ""

wait_for_user "Press Enter to start the setup..."

# ── Step 1: Xcode Command Line Tools ─────────────────────────────────────────

source "$MODULES_DIR/xcode.sh"
install_xcode_clt

# ── Step 2: Homebrew ──────────────────────────────────────────────────────────

source "$MODULES_DIR/homebrew.sh"
install_homebrew

# ── Step 3: Git ──────────────────────────────────────────────────────────────

source "$MODULES_DIR/git.sh"
install_git

# ── Step 4: Node.js ──────────────────────────────────────────────────────────

source "$MODULES_DIR/node.sh"
install_node

# ── Step 5: Oh My Zsh ────────────────────────────────────────────────────────

source "$MODULES_DIR/omz.sh"
install_omz

# ── Summary ───────────────────────────────────────────────────────────────────

header "Setup Complete"

success "All available steps finished successfully!"
echo ""
info "Here is what happened:"
echo "    ✓  Xcode Command Line Tools   — $(_result_label "${XCODE_RESULT:-}")"
echo "    ✓  Homebrew                   — $(_result_label "${HOMEBREW_RESULT:-}")"
echo "    ✓  Git                        — $(_result_label "${GIT_RESULT:-}")"
echo "    ✓  Node.js                    — $(_result_label "${NODE_RESULT:-}")"
echo "    ✓  Oh My Zsh                  — $(_result_label "${OMZ_RESULT:-}")"
echo ""
printf "${BOLD}${YELLOW}"
echo "  ╔══════════════════════════════════════════════════╗"
echo "  ║                                                  ║"
echo "  ║   ⚠  ACTION REQUIRED: Restart Terminal           ║"
echo "  ║                                                  ║"
echo "  ║   Close this window and open a new Terminal      ║"
echo "  ║   tab for all changes to take effect.            ║"
echo "  ║                                                  ║"
echo "  ╚══════════════════════════════════════════════════╝"
printf "${RESET}"
echo ""
info "If you hit any issues, share the following file with your team:"
info "  ${LOG_FILE}"
echo ""
