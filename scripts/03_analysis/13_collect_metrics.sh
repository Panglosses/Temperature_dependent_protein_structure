#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

require_commands awk grep tail
prepare_workspace

output_csv="$SUMMARY_DIR/summary_table_computed.csv"
printf "Group,RMSD_mean(nm),RMSD_std(nm),Rg(nm),Hbonds,Helix(%%),Sheet(%%),Turn(%%),Coil(%%)\n" > "$output_csv"

for temp in "${TEMPERATURES[@]}"; do
    md_dir="$WORKDIR/md_${temp}"

    read -r rmsd_mean rmsd_std <<< "$(calc_mean_std_last_window "$md_dir/rmsd_${temp}.xvg" "$ANALYSIS_START_NS")"
    rg_mean="$(calc_mean_last_window "$md_dir/gyrate_${temp}.xvg" "$ANALYSIS_START_NS")"
    hbond_mean="$(calc_mean_last_window "$md_dir/hbond_inter_${temp}.xvg" "$ANALYSIS_START_NS")"

    read -r helix_pct sheet_pct turn_pct coil_pct <<< "$(
        tail -n "$DSSP_TAIL_LINES" "$md_dir/ss_${temp}.dat" | awk '
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
                printf "%.1f %.1f %.1f %.1f\n",
                    total_h * 100 / total_len,
                    total_e * 100 / total_len,
                    total_t * 100 / total_len,
                    (total_len - total_h - total_e - total_t) * 100 / total_len
            }
        '
    )"

    printf "%sK,%s,%s,%s,%s,%s,%s,%s,%s\n" \
        "$temp" \
        "$rmsd_mean" \
        "$rmsd_std" \
        "$rg_mean" \
        "$hbond_mean" \
        "$helix_pct" \
        "$sheet_pct" \
        "$turn_pct" \
        "$coil_pct" >> "$output_csv"
done

log "Wrote computed summary table to $output_csv"
