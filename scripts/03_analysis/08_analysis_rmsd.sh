#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

require_commands gmx awk grep
prepare_workspace

for temp in "${TEMPERATURES[@]}"; do
    cd "$WORKDIR/md_${temp}"
    log "Calculating RMSD for ${temp}K"
    echo "4 4" | gmx rms -s "md_${temp}.tpr" -f "md_${temp}.xtc" -o "rmsd_${temp}.xvg" -tu ns

    read -r mean std <<< "$(calc_mean_std_last_window "rmsd_${temp}.xvg" "$ANALYSIS_START_NS")"
    log "${temp}K RMSD (${ANALYSIS_START_NS}-50 ns): mean=${mean} nm, std=${std} nm"
    cd "$WORKDIR"
done
