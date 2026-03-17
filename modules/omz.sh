# Sourced by setup.sh — do not run directly.
# ==============================================================================
# omz.sh — Install Oh My Zsh
#
# Why fifth? Oh My Zsh modifies ~/.zshrc and should be installed last so it
# doesn't interfere with PATH changes made by earlier steps (Homebrew, Node).
# Requires Git (installed in Step 3) to clone the Oh My Zsh repository.
# ==============================================================================

source "${MODULES_DIR}/utils.sh"

install_omz() {
    header "Step 5 · Oh My Zsh"

    # ── Already installed? ────────────────────────────────────────────────
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        success "Oh My Zsh is already installed."
        OMZ_RESULT="already_installed"
        return 0
    fi

    # ── Explain what's about to happen ────────────────────────────────────
    info "Oh My Zsh makes your terminal smarter and nicer-looking."
    info "It adds colorful output, helpful command suggestions, and a"
    info "cleaner prompt that shows your current folder at a glance."
    echo ""
    info "What will happen next:"
    info "  1. Oh My Zsh will be downloaded from the internet."
    info "  2. Your terminal settings file (.zshrc) will be updated."
    info "     If you had one before, it will be saved as .zshrc.pre-oh-my-zsh."
    info "  3. This usually takes about ${BOLD}1–2 minutes${RESET}."
    echo ""
    warn "You will need to restart Terminal after this step to see the new look."
    echo ""

    # ── Download installer to a temp file ────────────────────────────────
    # Using a temp file (rather than `sh -c "$(curl ...)"`) ensures that a
    # network failure is caught explicitly before anything tries to run.
    local _omz_installer
    _omz_installer=$(mktemp)

    info "Downloading the Oh My Zsh installer..."
    if ! curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
            -o "$_omz_installer"; then
        rm -f "$_omz_installer"
        fail "Could not download the Oh My Zsh installer."
        echo ""
        info "Troubleshooting tips:"
        info "  • Check your internet connection."
        info "  • Try running this setup script again."
        echo ""
        abort "Oh My Zsh installer download failed."
    fi

    # Validate that the download is non-empty and looks like the real installer
    if [[ ! -s "$_omz_installer" ]] || ! grep -q "oh-my-zsh" "$_omz_installer" 2>/dev/null; then
        rm -f "$_omz_installer"
        abort "Downloaded Oh My Zsh installer appears corrupted or truncated."
    fi

    # ── Install ───────────────────────────────────────────────────────────
    info "Installing Oh My Zsh... (this may take a minute)"
    echo ""

    # RUNZSH=no  — don't start a new zsh session mid-script (would hang)
    # CHSH=no    — don't change the default shell (already zsh on macOS)
    if ! RUNZSH=no CHSH=no sh "$_omz_installer" \
            >> "${LOG_FILE:-/tmp/mac-dev-ready.log}" 2>&1; then
        rm -f "$_omz_installer"
        echo ""
        fail "The Oh My Zsh installer exited with an error."
        echo ""
        info "Troubleshooting tips:"
        info "  • Make sure you have an internet connection."
        info "  • Make sure Git is installed (it was in Step 3)."
        info "  • Try running this setup script again."
        echo ""
        abort "Oh My Zsh installation failed."
    fi

    rm -f "$_omz_installer"

    # ── Verify installation ───────────────────────────────────────────────
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        success "Oh My Zsh installed successfully!"
        OMZ_RESULT="installed_fresh"
    else
        echo ""
        fail "Oh My Zsh was installed but could not be verified."
        echo ""
        info "Try closing and reopening Terminal, then run this script again."
        echo ""
        abort "Could not verify Oh My Zsh installation."
    fi
}
