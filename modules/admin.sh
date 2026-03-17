# Sourced by setup.sh — do not run directly.
# ==============================================================================
# admin.sh — Admin rights check for MDM-enrolled Macs
#
# On corporate Macs (Jamf, Intune + CyberArk / BeyondTrust), Terminal.app
# closes automatically when the user elevates privileges, killing any running
# script. This module:
#   1. Checks if the user already has admin rights.
#   2. If not, pre-installs iTerm2 (no admin required — ~/Applications).
#   3. Guides the user to elevate, then relaunch the script in iTerm2.
# ==============================================================================

source "${MODULES_DIR}/utils.sh"

_has_admin_rights() {
    id -Gn 2>/dev/null | grep -qw admin
}

_iterm_is_installed() {
    [[ -d "/Applications/iTerm.app" || -d "$HOME/Applications/iTerm.app" ]]
}

_install_iterm_no_admin() {
    local tmpdir zip
    tmpdir=$(mktemp -d)
    zip="$tmpdir/iTerm2.zip"

    if ! curl -fsSL "https://iterm2.com/downloads/stable/latest" \
            -o "$zip" 2>>"${LOG_FILE:-/dev/null}"; then
        rm -rf "$tmpdir"
        return 1
    fi

    mkdir -p "$HOME/Applications"
    if ! unzip -q "$zip" -d "$HOME/Applications/" 2>>"${LOG_FILE:-/dev/null}"; then
        rm -rf "$tmpdir"
        return 1
    fi

    rm -rf "$tmpdir"

    # Verify Apple code signature before trusting the downloaded app
    if ! codesign --verify --deep --strict "$HOME/Applications/iTerm.app" 2>/dev/null; then
        rm -rf "$HOME/Applications/iTerm.app"
        return 1
    fi

    xattr -dr com.apple.quarantine "$HOME/Applications/iTerm.app" 2>/dev/null || true
    return 0
}

require_admin_or_migrate() {
    if _has_admin_rights; then
        success "Admin rights — good."
        return 0
    fi

    # ── Not admin: prepare iTerm2 BEFORE the user elevates ────────────────
    # Terminal.app will close the moment elevation happens, so we install
    # iTerm2 now (no admin needed) and give the user clear next steps.

    echo ""
    printf "${BOLD}${YELLOW}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║                                                  ║"
    echo "  ║        ⚠  Admin privileges are required           ║"
    echo "  ║                                                  ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    printf "${RESET}"
    echo ""
    info "The setup needs admin rights to install developer tools."
    info "On your Mac, Terminal closes automatically when you elevate"
    info "your privileges — which would interrupt the setup mid-way."
    echo ""
    info "To avoid this, we'll install iTerm2 right now (no password"
    info "needed). iTerm2 stays open during privilege changes."
    echo ""

    if _iterm_is_installed; then
        success "iTerm2 is already installed."
    else
        info "Downloading and installing iTerm2..."
        echo ""

        if _install_iterm_no_admin; then
            success "iTerm2 installed to ~/Applications."
        else
            echo ""
            warn "Could not install iTerm2 automatically."
            warn "Please download it from https://iterm2.com before continuing."
            echo ""
            abort "Could not ensure a stable terminal environment."
        fi
    fi

    echo ""
    printf "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "${BOLD}  Follow these 3 steps${RESET}\n"
    printf "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    echo ""
    printf "  ${BOLD}1.${RESET}  Elevate your privileges using your company tool\n"
    printf "      ${YELLOW}(e.g. your company App Store…)${RESET}\n"
    echo ""
    printf "      This Terminal window will close — ${BOLD}that's normal.${RESET}\n"
    echo ""
    printf "  ${BOLD}2.${RESET}  Open ${BOLD}iTerm2${RESET}\n"
    printf "      Spotlight: ${BOLD}Cmd + Space${RESET} → type ${BOLD}iTerm${RESET} → press Enter\n"
    echo ""
    printf "  ${BOLD}3.${RESET}  Paste this command in iTerm2 and press Enter:\n"
    echo ""
    printf "      ${BOLD}${GREEN}zsh \"${SCRIPT_DIR}/setup.sh\"${RESET}\n"
    echo ""
    printf "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    echo ""
    info "See you in iTerm2!"
    echo ""
    # Exit code 10 signals "admin migration" so install.sh preserves the temp dir
    exit 10
}
