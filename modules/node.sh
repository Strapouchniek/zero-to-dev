# Sourced by setup.sh — do not run directly.
# ==============================================================================
# node.sh — Install Node.js (JavaScript / TypeScript runtime)
#
# Why fourth? Node.js is needed to run JavaScript tooling, linting, and many
# Cursor extensions. We install it via Homebrew for simplicity — this gives a
# single, system-wide version that's easy to update with `brew upgrade node`.
# Note: `brew install node` installs the latest stable release, not a pinned
# LTS version. This is fine for Cursor usage and keeps the install simple.
# Requires Homebrew (installed in Step 2).
# ==============================================================================

source "${MODULES_DIR}/utils.sh"

install_node() {
    header "Step 4 · Node.js"

    # ── Already installed via Homebrew? ────────────────────────────────────
    if brew list node &>/dev/null 2>&1; then
        local node_version npm_version
        node_version="$(node --version)"
        npm_version="$(npm --version)"
        success "Node.js is already installed via Homebrew (Node $node_version, npm $npm_version)."

        start_spinner "Checking for updates…"
        if brew upgrade node >> "${LOG_FILE:-/tmp/zero-to-dev.log}" 2>&1; then
            stop_spinner
            hash -r 2>/dev/null || true
            local new_version
            new_version="$(node --version)"
            if [[ "$new_version" != "$node_version" ]]; then
                success "Node.js updated to $new_version (npm $(npm --version))."
                NODE_RESULT="upgraded"
            else
                success "Already on the latest version."
                NODE_RESULT="already_installed"
            fi
        else
            stop_spinner
            warn "Could not check for updates — this is non-critical, continuing."
            NODE_RESULT="already_installed"
        fi

        return 0
    fi

    # ── Fall-back: any node on PATH? ──────────────────────────────────────
    if command -v node &>/dev/null; then
        local node_version
        node_version="$(node --version)"
        info "Found an existing Node.js installation ($node_version)."
        info "Installing the latest stable version through Homebrew..."
        NODE_RESULT="upgraded"
    else
        NODE_RESULT="installed_fresh"
        info "Node.js is not installed."
        info "Node.js is the engine that runs JavaScript outside the browser."
        info "Many developer tools (linters, formatters, Cursor extensions) depend on it."
    fi

    echo ""
    info "What will happen next:"
    info "  1. Homebrew will download and install the latest Node.js."
    info "  2. npm (Node's package manager) will be included automatically."
    info "  3. This usually takes about ${BOLD}1–3 minutes${RESET}."
    echo ""

    # ── Install via Homebrew ───────────────────────────────────────────────
    start_spinner "Installing Node.js — this may take a few minutes"

    if ! brew install node >> "${LOG_FILE:-/tmp/zero-to-dev.log}" 2>&1; then
        stop_spinner
        echo ""
        fail "Homebrew could not install Node.js."
        echo ""
        info "Troubleshooting tips:"
        info "  • Make sure you have enough disk space."
        info "  • Try running this setup script again."
        echo ""
        abort "Node.js installation failed."
    fi

    stop_spinner

    # ── Verify installation ────────────────────────────────────────────────
    [[ -f /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
    hash -r 2>/dev/null || true

    if command -v node &>/dev/null && command -v npm &>/dev/null; then
        success "Node.js installed successfully!"
        success "Node version: $(node --version)"
        success "npm version:  $(npm --version)"
    else
        echo ""
        fail "Node.js was installed but the 'node' or 'npm' command is not available."
        echo ""
        info "Try closing and reopening Terminal, then run this script again."
        echo ""
        abort "Could not verify Node.js installation."
    fi
}
