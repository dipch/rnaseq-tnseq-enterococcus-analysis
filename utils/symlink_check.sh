# Shared shell functions sourced by pipeline scripts.
# Usage: source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/symlink_check.sh"

# Safely replace a plain directory with a symlink to a nobackup target.
# Usage: ensure_nobackup_symlink <link_path> <target_path>
ensure_nobackup_symlink() {
    local link="$1" target="$2"
    if [[ -d "$link" && ! -L "$link" ]]; then
        rmdir "$link" 2>/dev/null || {
            echo "ERROR: $link exists as a non-empty directory, cannot replace with symlink"
            exit 1
        }
    fi
    if [[ ! -L "$link" ]]; then
        ln -s "$target" "$link"
    fi
}
