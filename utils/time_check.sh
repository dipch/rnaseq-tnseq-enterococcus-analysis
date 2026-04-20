# time utility functions sourced by pipeline scripts.
# source "${HOME}/rnaseq-tnseq-enterococcus-analysis/utils/time_check.sh"

current_time() { date '+%Y-%m-%d %H:%M:%S'; }

elapsed_time() {
    local secs=$(( $(date +%s) - $1 ))
    printf '%dh %dm %ds' $(( secs/3600 )) $(( (secs%3600)/60 )) $(( secs%60 ))
}
