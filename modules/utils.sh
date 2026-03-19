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
        kill "$_SPINNER_PID" 2>/dev/null
        wait "$_SPINNER_PID" 2>/dev/null
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
        kill "$_SPINNER_PID" 2>/dev/null
        wait "$_SPINNER_PID" 2>/dev/null
        _SPINNER_PID=""
    fi
    printf "\r\033[K"
}

# ── Animations ───────────────────────────────────────────────────────────────

confetti() {
    local cols lines
    cols=$(tput cols 2>/dev/null)  || { printf "\n🎉  ${BOLD}${GREEN}Setup Complete!${RESET}  🎉\n\n"; return 0; }
    lines=$(tput lines 2>/dev/null) || lines=24

    local -a particles=("✦" "•" "✶" "◆" "★" "●" "✸" "◇" "♦" "✺" "❖" "✧" "⬥" "⬦")
    local -a emojis=("🎉" "🎊" "✨" "🌟" "⭐" "💫" "🥳" "🪅" "🎆" "🎇")
    local -a colors=(
        '\033[1;31m' '\033[1;32m' '\033[1;33m'
        '\033[1;34m' '\033[1;35m' '\033[1;36m'
        '\033[0;31m' '\033[0;32m' '\033[0;33m'
        '\033[0;34m' '\033[0;35m' '\033[0;36m'
    )
    local n_particles=${#particles[@]}
    local n_emojis=${#emojis[@]}
    local n_colors=${#colors[@]}
    local center_row=$((lines / 2))
    local center_col=$((cols / 2))

    tput civis 2>/dev/null
    clear

    # ── Phase 1: Rocket launch ────────────────────────────────────────────
    local rocket_col=$((center_col - 1))
    local r
    for r in $(seq $((lines - 1)) -1 $((center_row + 2))); do
        tput cup "$r" "$rocket_col" 2>/dev/null
        printf "🚀"
        sleep 0.03
        tput cup "$r" "$rocket_col" 2>/dev/null
        printf "  "
    done

    # ── Phase 2: Explosion burst from center ──────────────────────────────
    local ring radius angle row col pidx cidx
    for radius in 2 4 6 8 11 14; do
        for angle in $(seq 0 30 330); do
            row=$(( center_row + (radius * (angle % 180 < 90 ? 1 : -1)) / 3 ))
            col=$(( center_col + (radius * (angle < 180 ? 1 : -1)) ))
            row=$(( row + (RANDOM % 3) - 1 ))
            col=$(( col + (RANDOM % 3) - 1 ))
            [[ $row -lt 0 || $row -ge $lines ]] && continue
            [[ $col -lt 0 || $col -ge $cols ]] && continue
            pidx=$((RANDOM % n_particles + 1))
            cidx=$((RANDOM % n_colors + 1))
            tput cup "$row" "$col" 2>/dev/null
            printf "${colors[$cidx]}%s${RESET}" "${particles[$pidx]}"
        done
        sleep 0.06
    done

    # ── Phase 3: Center message with border ───────────────────────────────
    local box_w=40
    local box_h=5
    local box_top=$(( center_row - box_h / 2 ))
    local box_left=$(( center_col - box_w / 2 ))
    [[ $box_left -lt 0 ]] && box_left=0

    local line_i
    for line_i in $(seq 0 $((box_h - 1))); do
        tput cup $((box_top + line_i)) $box_left 2>/dev/null
        printf "%${box_w}s" " "
    done

    tput cup $box_top $box_left 2>/dev/null
    printf "${BOLD}${GREEN}╔══════════════════════════════════════╗${RESET}"
    tput cup $((box_top + 1)) $box_left 2>/dev/null
    printf "${BOLD}${GREEN}║                                      ║${RESET}"
    tput cup $((box_top + 2)) $box_left 2>/dev/null
    printf "${BOLD}${GREEN}║      🎉  Setup Complete!  🎉        ║${RESET}"
    tput cup $((box_top + 3)) $box_left 2>/dev/null
    printf "${BOLD}${GREEN}║                                      ║${RESET}"
    tput cup $((box_top + 4)) $box_left 2>/dev/null
    printf "${BOLD}${GREEN}╚══════════════════════════════════════╝${RESET}"

    # ── Phase 4: Dense confetti rain + emojis ─────────────────────────────
    local i eidx
    for i in $(seq 1 200); do
        row=$((RANDOM % lines))
        col=$((RANDOM % (cols - 1)))
        # Skip the center message area
        if [[ $row -ge $box_top && $row -le $((box_top + box_h)) \
            && $col -ge $box_left && $col -le $((box_left + box_w)) ]]; then
            continue
        fi
        if (( i % 8 == 0 )); then
            eidx=$((RANDOM % n_emojis + 1))
            tput cup "$row" "$col" 2>/dev/null
            printf "%s" "${emojis[$eidx]}"
        else
            pidx=$((RANDOM % n_particles + 1))
            cidx=$((RANDOM % n_colors + 1))
            tput cup "$row" "$col" 2>/dev/null
            printf "${colors[$cidx]}%s${RESET}" "${particles[$pidx]}"
        fi
        sleep 0.012
    done

    sleep 1.5
    tput cnorm 2>/dev/null
    clear
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
