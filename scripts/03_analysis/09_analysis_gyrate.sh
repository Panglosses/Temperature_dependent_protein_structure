#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

require_commands gmx awk grep
prepare_workspace

for temp in "${TEMPERATURES[@]}"; do
    cd "$WORKDIR/md_${temp}"
    log "Calculating radius of gyration for ${temp}K"
    echo "1" | gmx gyrate -s "md_${temp}.tpr" -f "md_${temp}.xtc" -o "gyrate_${temp}.xvg" -tu ns

    mean="$(calc_mean_last_window "gyrate_${temp}.xvg" "$ANALYSIS_START_NS")"
    log "${temp}K Rg (${ANALYSIS_START_NS}-50 ns): mean=${mean} nm"
    cd "$WORKDIR"
done
