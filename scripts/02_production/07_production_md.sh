#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

require_commands gmx sed
prepare_workspace

for temp in "${TEMPERATURES[@]}"; do
    run_dir="md_${temp}"
    mkdir -p "$run_dir"
    cp npt.gro npt.cpt topol.top "$run_dir/"

    render_production_mdp "$temp" "$run_dir/md_${temp}.mdp"

    cd "$run_dir"
    log "Preparing production MD at ${temp}K"
    gmx grompp \
        -f "md_${temp}.mdp" \
        -c npt.gro \
        -t npt.cpt \
        -p topol.top \
        -o "md_${temp}.tpr" \
        -maxwarn 1

    log "Running production MD at ${temp}K with ${PRODUCTION_THREADS} threads"
    gmx mdrun -v -deffnm "md_${temp}" -ntomp "$PRODUCTION_THREADS" -nb "$MDRUN_NB"
    cd "$WORKDIR"
done
