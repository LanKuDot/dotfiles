#!/bin/bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
CONFIG="$DOTFILES_DIR/paths.ini"
HOME_DIR="$HOME"

if [[ ! -f "$CONFIG" ]]; then
    echo "Error: paths.ini not found in $DOTFILES_DIR"
    exit 1
fi

create_symlink() {
    local src="$1"
    local dest="$2"

    if [[ ! -e "$src" ]]; then
        echo "  SKIP (source missing): $src"
        return
    fi

    local dest_dir
    dest_dir="$(dirname "$dest")"
    if [[ ! -d "$dest_dir" ]]; then
        mkdir -p "$dest_dir"
        echo "  MKDIR $dest_dir"
    fi

    if [[ -L "$dest" ]]; then
        local current_target
        current_target="$(readlink "$dest")"
        if [[ "$current_target" == "$src" ]]; then
            echo "  OK (already linked): $dest"
            return
        fi
        rm "$dest"
        echo "  REMOVE (old symlink): $dest"
    elif [[ -e "$dest" ]]; then
        local backup="${dest}.bak"
        mv "$dest" "$backup"
        echo "  BACKUP $dest -> $backup"
    fi

    ln -s "$src" "$dest"
    echo "  LINK $dest -> $src"
}

install_section() {
    local section="$1"
    local in_section=0

    echo "[$section]"

    while IFS= read -r line || [[ -n "$line" ]]; do
        # Strip carriage return
        line="${line%$'\r'}"
        # Skip comments and empty lines
        [[ -z "$line" || "$line" == \#* ]] && continue

        # Check for section headers
        if [[ "$line" =~ ^\[([^]]+)\]$ ]]; then
            if [[ "${BASH_REMATCH[1]}" == "$section" ]]; then
                in_section=1
            else
                in_section=0
            fi
            continue
        fi

        [[ "$in_section" -eq 0 ]] && continue

        # Parse "source = destination"
        local src_rel dest_rel
        src_rel="$(echo "${line%%=*}" | xargs)"
        dest_rel="$(echo "${line#*=}" | xargs)"

        create_symlink "$DOTFILES_DIR/$section/$src_rel" "$HOME_DIR/$dest_rel"
    done < "$CONFIG"
}

get_sections() {
    grep -oP '(?<=^\[)[^]]+(?=\])' "$CONFIG"
}

if [[ $# -ge 1 ]]; then
    sections=("$@")
else
    mapfile -t sections < <(get_sections)
fi

for section in "${sections[@]}"; do
    if ! grep -q "^\[$section\]" "$CONFIG"; then
        echo "Error: section [$section] not found in paths.ini"
        exit 1
    fi
    install_section "$section"
done

echo "Done."
