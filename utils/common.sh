#!/bin/bash
set -euo pipefail

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODE_DIR="$(cd "$COMMON_DIR/.." && pwd)"
CONFIG_DIR="$CODE_DIR/config"
MDP_DIR="$CONFIG_DIR/mdp"

source "$CONFIG_DIR/defaults.sh"

log() {
    printf '[%s] %s\n' "$(date '+%F %T')" "$*"
}

require_commands() {
    local missing=0
    for cmd in "$@"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            echo "Missing required command: $cmd" >&2
            missing=1
        fi
    done
    if [ "$missing" -ne 0 ]; then
        exit 1
    fi
}

prepare_workspace() {
    mkdir -p "$WORKDIR" "$SUMMARY_DIR" "$FINAL_STRUCTURES_DIR"
    cd "$WORKDIR"
}

render_production_mdp() {
    local temp="$1"
    local output_file="$2"
    sed "s/__TEMP__/${temp}/g" "$MDP_DIR/md.template.mdp" > "$output_file"
}

calc_mean_last_window() {
    local xvg_file="$1"
    local start_ns="$2"
    grep -v '^[@#]' "$xvg_file" | awk -v start_ns="$start_ns" '
        $1 >= start_ns {sum += $2; count += 1}
        END {
            if (count == 0) {
                exit 1
            }
            printf "%.4f\n", sum / count
        }
    '
}

calc_mean_std_last_window() {
    local xvg_file="$1"
    local start_ns="$2"
    grep -v '^[@#]' "$xvg_file" | awk -v start_ns="$start_ns" '
        $1 >= start_ns {
            sum += $2
            sumsq += $2 * $2
            count += 1
        }
        END {
            if (count == 0) {
                exit 1
            }
            mean = sum / count
            std = sqrt((sumsq / count) - (mean * mean))
            printf "%.4f %.4f\n", mean, std
        }
    '
}
