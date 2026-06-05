#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

require_commands gmx grep cp
prepare_workspace

for temp in "${TEMPERATURES[@]}"; do
    cd "$WORKDIR/md_${temp}"
    log "Extracting final frame for ${temp}K"
    printf "Protein\nProtein\n" | gmx trjconv \
        -s "md_${temp}.tpr" \
        -f "md_${temp}.xtc" \
        -o "final_${temp}_protein_whole.pdb" \
        -pbc mol \
        -center \
        -ur compact \
        -dump "$FINAL_FRAME_PS"

    awk '
        ($1 == "ATOM" && substr($0, 77, 1) != "H") || $1 == "TER" || $1 == "END" {
            print
        }
    ' "final_${temp}_protein_whole.pdb" > "final_${temp}_protein_noH.pdb"

    cp "final_${temp}_protein_whole.pdb" "$FINAL_STRUCTURES_DIR/final_${temp}K_protein_whole.pdb"
    cp "final_${temp}_protein_noH.pdb" "$FINAL_STRUCTURES_DIR/final_${temp}K_protein_noH.pdb"
    cd "$WORKDIR"
done
