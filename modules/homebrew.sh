# Sourced by setup.sh — do not run directly.
# ==============================================================================
# homebrew.sh — Install Homebrew (macOS package manager)
#
# Why second? Homebrew is the de-facto package manager for macOS and is used
# to install Git, Node.js, and most other developer tools in later steps.
# Requires Xcode Command Line Tools (installed in Step 1).
# ==============================================================================

source "${MODULES_DIR}/utils.sh"

install_homebrew() {
    header "Step 2 · Homebrew"

    # ── Already installed? ────────────────────────────────────────────────
    if command -v brew &>/dev/null; then
        local brew_version
        brew_version="$(brew --version | head -1)"
        success "Homebrew is already installed ($brew_version)."

        info "Updating Homebrew to the latest version..."
        if brew update &>/dev/null; then
            success "Homebrew is up to date."
        else
            warn "Homebrew update failed — this is non-critical, continuing."
        fi
        HOMEBREW_RESULT="already_installed"
        return 0
    fi

    # ── Explain what's about to happen ────────────────────────────────────
    info "Homebrew is not installed."
    info "Homebrew is a package manager that lets you install developer tools"
    info "with a single command — like an App Store for the terminal."
    echo ""
    info "What will happen next:"
    info "  1. The official Homebrew installer will run."
    info "  2. You may be asked to enter your ${BOLD}Mac password${RESET}."
    info "     (The cursor won't move while you type — that's normal!)"
    info "  3. The download and install takes about ${BOLD}2–5 minutes${RESET}."
    echo ""
    warn "Do NOT close Terminal while the installation is running."
    echo ""

    wait_for_user "Press Enter to start the Homebrew installation..."

    # ── Download installer to a temp file ────────────────────────────────
    # Using a temp file (rather than `bash -c "$(curl ...)"`) ensures that a
    # network failure is caught explicitly before anything tries to run.
    local _brew_installer
    _brew_installer=$(mktemp)

    info "Downloading the Homebrew installer..."
    if ! curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
            -o "$_brew_installer"; then
        rm -f "$_brew_installer"
        fail "Could not download the Homebrew installer."
        echo ""
        info "Troubleshooting tips:"
        info "  • Check your internet connection."
        info "  • Try running this setup script again."
        echo ""
        abort "Homebrew installer download failed."
    fi

    # Validate that the download is non-empty and looks like the real installer
    if [[ ! -s "$_brew_installer" ]] || ! grep -q "HOMEBREW" "$_brew_installer" 2>/dev/null; then
        rm -f "$_brew_installer"
        abort "Downloaded Homebrew installer appears corrupted or truncated."
    fi

    # ── Run the official installer ────────────────────────────────────────
    echo ""
    info "Running the Homebrew installer..."
    echo ""
    info "────────────────────────────────────────────────────"
    info "A lot of text will appear below — this is normal."
    info "Just wait until you see the green checkmark."
    info "────────────────────────────────────────────────────"
    echo ""

    if ! /bin/bash "$_brew_installer"; then
        rm -f "$_brew_installer"
        echo ""
        fail "The Homebrew installer exited with an error."
        echo ""
        info "Troubleshooting tips:"
        info "  • Make sure you entered your Mac password correctly."
        info "  • Check that you have enough disk space (at least 5 GB free)."
        info "  • Try running this setup script again."
        echo ""
        abort "Homebrew installation failed."
    fi

    rm -f "$_brew_installer"

    # ── Ensure brew is on PATH for Apple Silicon Macs ─────────────────────
    # On Apple Silicon (M1/M2/M3), Homebrew installs to /opt/homebrew.
    # On Intel Macs it installs to /usr/local. The installer usually
    # configures PATH, but we add it here as a safety net for this session.

    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [[ -f "/usr/local/bin/brew" ]]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
    hash -r 2>/dev/null || true

    # ── Verify installation ───────────────────────────────────────────────
    if command -v brew &>/dev/null; then
        echo ""
        info "────────────────────────────────────────────────────"
        echo ""
        success "Homebrew installed successfully!"
        success "Version: $(brew --version | head -1)"
        HOMEBREW_RESULT="installed_fresh"
    else
        echo ""
        fail "Homebrew was installed but the 'brew' command is not available."
        echo ""
        info "This usually means your shell PATH needs updating."
        info "Try closing and reopening Terminal, then run this script again."
        echo ""
        abort "Could not verify Homebrew installation."
    fi
}
