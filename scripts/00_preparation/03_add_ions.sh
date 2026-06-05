#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

require_commands gmx
prepare_workspace

cp "$MDP_DIR/ions.mdp" ions.mdp

log "Preparing ion placement input"
gmx grompp -f ions.mdp -c solv.gro -p topol.top -o ions.tpr

log "Adding ions at ${ION_CONCENTRATION_M} M"
echo "SOL" | gmx genion \
    -s ions.tpr \
    -o solv_ions.gro \
    -p topol.top \
    -pname NA \
    -nname CL \
    -neutral \
    -conc "$ION_CONCENTRATION_M"
