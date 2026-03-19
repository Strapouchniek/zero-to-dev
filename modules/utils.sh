# Sourced by setup.sh — do not run directly.
# ==============================================================================
# utils.sh — Shared helpers: colors, logging, error handling
# ==============================================================================

# Guard against double-sourcing
[[ -n "${__UTILS_LOADED:-}" ]] && return 0
__UTILS_LOADED=1

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
RESET='\033[0m'

# ── Logging ───────────────────────────────────────────────────────────────────

info()    { printf "${BLUE}ℹ${RESET}  %s\n" "$1"; }
success() { printf "${GREEN}✓${RESET}  %s\n" "$1"; }
warn()    { printf "${YELLOW}⚠${RESET}  %s\n" "$1"; }
fail()    { printf "${RED}✗  %s${RESET}\n" "$1"; }

header() {
    echo ""
    printf "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    printf "${BOLD}  %s${RESET}\n" "$1"
    printf "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
    echo ""
}

# ── Error handling ────────────────────────────────────────────────────────────

abort() {
    echo ""
    fail "$1"
    echo ""
    fail "Setup did not complete. Please share the error above with your team."
    if [[ -n "${LOG_FILE:-}" && -f "${LOG_FILE:-}" ]]; then
        fail "Also share the log file: ${LOG_FILE}"
    fi
    echo ""
    exit 1
}

# Used by setup.sh summary to display what each step did.
_result_label() {
    case "${1:-}" in
        installed_fresh)   echo "freshly installed" ;;
        already_installed) echo "was already set up" ;;
        upgraded)          echo "upgraded to latest" ;;
        *)                 echo "done" ;;
    esac
}

# ── Prompts ───────────────────────────────────────────────────────────────────

wait_for_user() {
    local message="${1:-Press Enter to continue...}"
    echo ""
    printf "${YELLOW}▸${RESET}  ${BOLD}%s${RESET}" "$message"
    read -r
}

# ── Spinner ───────────────────────────────────────────────────────────────────

_SPINNER_PID=""

_cleanup_spinner() {
    if [[ -n "$_SPINNER_PID" ]]; then
        kill "$_SPINNER_PID" 2>/dev/null || true
        wait "$_SPINNER_PID" 2>/dev/null || true
        _SPINNER_PID=""
        printf "\r\033[K"
    fi
}
trap '_cleanup_spinner' EXIT

start_spinner() {
    local msg="$1"
    _cleanup_spinner
    (
        local frames=(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
        local i=1
        local start=$SECONDS
        while true; do
            local elapsed=$(( SECONDS - start ))
            printf "\r\033[K${BLUE}%s${RESET}  %s ${BOLD}(%ds)${RESET}" "${frames[$i]}" "$msg" "$elapsed"
            i=$(( i % ${#frames[@]} + 1 ))
            sleep 0.08
        done
    ) &
    _SPINNER_PID=$!
}

stop_spinner() {
    if [[ -n "$_SPINNER_PID" ]]; then
        kill "$_SPINNER_PID" 2>/dev/null || true
        wait "$_SPINNER_PID" 2>/dev/null || true
        _SPINNER_PID=""
    fi
    printf "\r\033[K"
}

# ── Animations ───────────────────────────────────────────────────────────────

confetti() {
    local -a wave=("·" "∙" "•" "●" "•" "∙" "·")
    local wlen=${#wave[@]}
    local width=20
    local steps=$(( width + wlen ))
    local step pos wi

    echo ""
    for step in $(seq 1 $steps); do
        printf "\r\033[K  "
        for pos in $(seq 1 $width); do
            wi=$(( pos - step + wlen ))
            if (( wi >= 1 && wi <= wlen )); then
                printf "%s" "${wave[$wi]}"
            else
                printf " "
            fi
        done
        sleep 0.03
    done
    printf "\r\033[K  ${BOLD}${GREEN}✓ Done!${RESET}\n"
    sleep 0.5
}

# ── Requirement checks ───────────────────────────────────────────────────────

require_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        abort "This script only works on macOS. You appear to be on $(uname)."
    fi
}

require_macos_version() {
    local version major_version
    version=$(sw_vers -productVersion)
    major_version=$(echo "$version" | cut -d. -f1)

    if [[ "$major_version" -lt 14 ]]; then
        abort "Your macOS version ($version) is not supported.
       Homebrew — which this script depends on — requires macOS Sonoma (14) or later.
       Please update your Mac: System Settings → General → Software Update."
    fi
}

require_internet() {
    if ! curl --silent --head --max-time 5 https://www.apple.com >/dev/null 2>&1; then
        abort "No internet connection detected. Please connect to the internet and try again."
    fi
}
