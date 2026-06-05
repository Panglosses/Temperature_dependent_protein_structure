#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

require_commands gmx awk tail
prepare_workspace

for temp in "${TEMPERATURES[@]}"; do
    cd "$WORKDIR/md_${temp}"
    log "Running DSSP for ${temp}K"
    gmx dssp -s "md_${temp}.tpr" -f "md_${temp}.xtc" -o "ss_${temp}.dat" -tu ns

    tail -n "$DSSP_TAIL_LINES" "ss_${temp}.dat" | awk -v temp="$temp" '
        {
            h = gsub(/H/, "H")
            e = gsub(/E/, "E")
            t = gsub(/T/, "T") + gsub(/S/, "S")
            len = length($0)
            total_h += h
            total_e += e
            total_t += t
            total_len += len
        }
        END {
            printf "%sK DSSP: Helix=%.1f%% Sheet=%.1f%% Turn=%.1f%% Coil=%.1f%%\n",
                temp,
                total_h * 100 / total_len,
                total_e * 100 / total_len,
                total_t * 100 / total_len,
                (total_len - total_h - total_e - total_t) * 100 / total_len
        }
    '
    cd "$WORKDIR"
done
