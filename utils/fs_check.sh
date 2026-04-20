# check for file/dir/symlink existence
# fatal=exit 1, non fatal=return 1 to skip

require_file() {
    local path="$1" label="${2:-file}"
    [[ -f "$path" ]] || {
        echo "[$(current_time)] ERROR: ${label} not found: ${path}"
        exit 1
    }
}

require_dir() {
    local path="$1" label="${2:-directory}"
    [[ -d "$path" ]] || {
        echo "[$(current_time)] ERROR: ${label} not found: ${path}"
        exit 1
    }
}

require_dir_nonempty() {
    local path="$1" label="${2:-directory}"
    require_dir "$path" "$label"
    [[ -n "$(ls -A "$path" 2>/dev/null)" ]] || {
        echo "[$(current_time)] ERROR: ${label} is empty: ${path}"
        exit 1
    }
}

require_files_in_array() {
    local array_name="$1" label="${2:-files}"
    local -n _arr="$array_name"
    [[ ${#_arr[@]} -gt 0 ]] || {
        echo "[$(current_time)] ERROR: no ${label} found"
        exit 1
    }
}

check_file() {
    local path="$1" label="${2:-}"
    if [[ ! -f "$path" ]]; then
        echo "[$(current_time)] ${label:+${label}: }file not found: ${path}"
        return 1
    fi
}

ensure_nobackup_symlink() {
    local link="$1" target="$2"
    if [[ -d "$link" && ! -L "$link" ]]; then
        rmdir "$link" 2>/dev/null || {
            echo "[$(current_time)] ERROR: $link exists as a non-empty directory, cannot replace with symlink"
            exit 1
        }
    fi
    if [[ ! -L "$link" ]]; then
        ln -s "$target" "$link"
    fi
}
