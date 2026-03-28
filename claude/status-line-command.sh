#!/bin/bash
input=$(cat)

# Parse JSON fields
model_name=$(echo "$input" | jq -r '.model.display_name // "Unknown Model"')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')

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
printf "${CYAN}[%s]${RESET} ${YELLOW}ctx: %s${RESET} | %s" "$model_name" "$ctx_display" "$cwd"
