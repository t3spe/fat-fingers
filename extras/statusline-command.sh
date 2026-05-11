#!/usr/bin/env bash
# Claude Code status line - custom dynamic colors

input=$(cat)

# --- Colors ---
C_RESET='\033[0m'
C_BLUE='\033[34m'
C_CYAN='\033[36m'
C_YELLOW='\033[33m'
C_GREEN='\033[32m'
C_RED='\033[31m'
C_DIM='\033[38;5;240m'
C_GRAY='\033[38;5;250m'
C_ORANGE='\033[38;5;208m'

M_OPUS='\033[38;5;183m'
M_SONNET='\033[38;5;110m'
M_HAIKU='\033[38;5;151m'

EF_MAX='\033[38;5;78m'
EF_XHIGH='\033[38;5;214m'
EF_REST='\033[38;5;160m'

# --- Glyphs (UTF-8 byte escapes) ---
G_FOLDER=$(printf '\xef\x81\xbb')   # U+F07B
G_BRANCH=$(printf '\xef\x84\xa6')   # U+F126
G_CLOCK=$(printf  '\xef\x8b\xb2')   # U+F2F2 stopwatch
G_HISTORY=$(printf '\xef\x87\x9a')  # U+F1DA history
G_DIFF=$(printf   '\xef\x83\xac')   # U+F0EC exchange
G_THINK=$(printf  '\xef\x8b\x9b')   # U+F2DB microchip/synapse
G_PULSE=$(printf  '\xef\x88\x81')   # U+F201 line-chart
DOT=$(printf '\xe2\x97\x8f')        # U+25CF black circle

# --- Parse JSON ---
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
model_display=$(echo "$input" | jq -r '.model.display_name // empty')
ctx_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
ctx_remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')
cost_usd=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
wall_ms=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')
api_ms=$(echo "$input" | jq -r '.cost.total_api_duration_ms // 0')
lines_added=$(echo "$input" | jq -r '.cost.total_lines_added // 0')
lines_removed=$(echo "$input" | jq -r '.cost.total_lines_removed // 0')
effort_level=$(echo "$input" | jq -r '.effort.level // empty')
thinking_on=$(echo "$input" | jq -r '.thinking.enabled // false')

# --- Directory (basename or ~) ---
if [[ "$cwd" == "$HOME" ]]; then
    dir="~"
else
    dir=$(basename "$cwd" 2>/dev/null)
    [[ -z "$dir" ]] && dir="?"
fi

# --- Branch + dirty ---
branch=""
dirty=""
if [[ -n "$cwd" && -d "$cwd" ]]; then
    branch=$(git -C "$cwd" branch --show-current 2>/dev/null)
    if [[ -n "$branch" ]]; then
        first_change=$(git -C "$cwd" --no-optional-locks status --porcelain -uall 2>/dev/null | head -c 1)
        [[ -n "$first_change" ]] && dirty="1"
    fi
fi

# --- Model compressed (o47_1m / s46_200k / h45_200k) ---
model_short=""
model_color="$C_GRAY"
if [[ -n "$model_display" ]]; then
    family_letter=$(printf '%s' "$model_display" | head -c 1 | tr '[:upper:]' '[:lower:]')
    version=$(printf '%s' "$model_display" | grep -oE '[0-9]+\.[0-9]+' | head -1 | tr -d '.')
    ctx_k=$((ctx_size / 1000))
    if [[ $ctx_k -ge 1000 ]]; then
        ctx_disp="$((ctx_k / 1000))m"
    else
        ctx_disp="${ctx_k}k"
    fi
    model_short="${family_letter}${version}_${ctx_disp}"
    case "$family_letter" in
        o) model_color="$M_OPUS" ;;
        s) model_color="$M_SONNET" ;;
        h) model_color="$M_HAIKU" ;;
    esac
fi

# --- Compact duration formatter ---
fmt_dur() {
    local ms="$1"
    local s=$((ms / 1000))
    if [[ $s -ge 3600 ]]; then
        printf "%dh%02dm" "$((s / 3600))" "$(((s % 3600) / 60))"
    elif [[ $s -ge 60 ]]; then
        printf "%dm" "$((s / 60))"
    else
        printf "%ds" "$s"
    fi
}

wall_str=$(fmt_dur "$wall_ms")
api_str=$(fmt_dur "$api_ms")

# --- Time tier (driven by API ms) ---
if   [[ $api_ms -lt 300000 ]];  then time_color="$C_GRAY"
elif [[ $api_ms -lt 900000 ]];  then time_color="$C_GREEN"
elif [[ $api_ms -lt 1800000 ]]; then time_color="$C_YELLOW"
elif [[ $api_ms -lt 3600000 ]]; then time_color="$C_ORANGE"
else                                 time_color="$C_RED"
fi

# --- Cost in cents ---
cost_cents=$(awk -v u="$cost_usd" 'BEGIN { printf "%d", u * 100 + 0.5 }')
if   [[ $cost_cents -lt 10 ]];  then cost_color="$C_GRAY"
elif [[ $cost_cents -lt 50 ]];  then cost_color="$C_GREEN"
elif [[ $cost_cents -lt 150 ]]; then cost_color="$C_YELLOW"
elif [[ $cost_cents -lt 500 ]]; then cost_color="$C_ORANGE"
else                                 cost_color="$C_RED"
fi

# --- Context % used (from remaining_percentage) ---
ctx_used=""
ctx_color="$C_GREEN"
if [[ -n "$ctx_remaining" ]]; then
    ctx_used=$(awk -v r="$ctx_remaining" 'BEGIN { printf "%d", 100 - r + 0.5 }')
    if   [[ $ctx_used -lt 30 ]]; then ctx_color="$C_GREEN"
    elif [[ $ctx_used -lt 45 ]]; then ctx_color="$C_ORANGE"
    else                              ctx_color="$C_RED"
    fi
fi

# --- Effort ---
effort_short=""
effort_color="$EF_MAX"
case "$effort_level" in
    low)    effort_short="l";   effort_color="$EF_REST" ;;
    medium) effort_short="m";   effort_color="$EF_REST" ;;
    high)   effort_short="h";   effort_color="$EF_REST" ;;
    xhigh)  effort_short="x";   effort_color="$EF_XHIGH" ;;
    max)    effort_short="max"; effort_color="$EF_MAX" ;;
esac

# --- Compose output ---
out=""

# Section 1: directory + branch
out+="${C_BLUE}${G_FOLDER} ${dir}${C_RESET} "
if [[ -n "$branch" ]]; then
    out+="${C_CYAN}${G_BRANCH} ${branch}"
    [[ -n "$dirty" ]] && out+="${C_YELLOW}${DOT}"
    out+="${C_RESET} "
fi

out+="${C_DIM}|${C_RESET} "

# Section 2: wall + api + lines + cost
out+="${time_color}${G_CLOCK} ${wall_str}${C_RESET} "
out+="${time_color}${G_HISTORY} ${api_str}${C_RESET} "
out+="${C_GRAY}${G_DIFF} ${C_GREEN}${lines_added}${C_GRAY}/${C_RED}${lines_removed}${C_RESET} "
out+="${cost_color}${cost_cents}${C_RESET} "

out+="${C_DIM}|${C_RESET} "

# Section 3: ctx + model + thinking + effort
[[ -n "$ctx_used" ]] && out+="${ctx_color}${ctx_used}%${C_RESET} "
out+="${model_color}${model_short}${C_RESET}"
[[ "$thinking_on" == "true" ]] && out+=" ${effort_color}${G_THINK}${C_RESET}"
[[ -n "$effort_short" ]] && out+=" ${effort_color}${G_PULSE} ${effort_short}${C_RESET}"

printf '%b' "$out"
