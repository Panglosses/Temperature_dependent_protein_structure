#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

require_commands gmx awk grep
prepare_workspace

for temp in "${TEMPERATURES[@]}"; do
    cd "$WORKDIR/md_${temp}"

    log "Building index for inter-chain hydrogen bonds at ${temp}K"
    gmx make_ndx -f "md_${temp}.tpr" -o index.ndx << EOF
keep 0
del 1-14
a ${CHAIN_A_RANGE}
name 1 ${CHAIN_A_NAME}
a ${CHAIN_B_RANGE}
name 2 ${CHAIN_B_NAME}
q
EOF

    log "Calculating inter-chain hydrogen bonds at ${temp}K"
    echo -e "1\n2" | gmx hbond \
        -s "md_${temp}.tpr" \
        -f "md_${temp}.xtc" \
        -n index.ndx \
        -num "hbond_inter_${temp}.xvg" \
        -tu ns

    mean="$(calc_mean_last_window "hbond_inter_${temp}.xvg" "$ANALYSIS_START_NS")"
    log "${temp}K Hbonds (${ANALYSIS_START_NS}-50 ns): mean=${mean}"
    cd "$WORKDIR"
done
