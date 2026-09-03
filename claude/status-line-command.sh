#!/bin/bash
input=$(cat)

# Parse JSON fields
model_name=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
effort=$(echo "$input" | jq -r '.effort.level // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

# Format effort level, e.g. "high" -> " (High)"
case "$effort" in
    low)    effort_display=" (Low)" ;;
    medium) effort_display=" (Medium)" ;;
    high)   effort_display=" (High)" ;;
    xhigh)  effort_display=" (XHigh)" ;;
    max)    effort_display=" (Max)" ;;
    "")     effort_display="" ;;
    *)      effort_display=" ($effort)" ;;
esac

# Format context percentage
if [ -n "$used" ]; then
    ctx_display=$(printf "%.0f%%" "$used")
else
    ctx_display="-"
fi

# ANSI color codes (cyan for model name, yellow for context)
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Output formatted status line
printf "${CYAN}[%s%s]${RESET} ${YELLOW}ctx: %s${RESET} | %s" "$model_name" "$effort_display" "$ctx_display" "$cwd"
