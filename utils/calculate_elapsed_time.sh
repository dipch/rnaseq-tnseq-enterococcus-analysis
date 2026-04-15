#!/bin/bash
# Shared shell functions sourced by pipeline scripts.

elapsed() {
    local secs=$(( $(date +%s) - $1 ))
    printf '%dh %dm %ds' $(( secs/3600 )) $(( (secs%3600)/60 )) $(( secs%60 ))
}
