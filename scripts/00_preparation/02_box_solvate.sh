#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

require_commands gmx
prepare_workspace

log "Defining cubic box with ${BOX_DISTANCE_NM} nm margin"
gmx editconf -f complex.gro -o box.gro -c -d "$BOX_DISTANCE_NM" -bt cubic

log "Adding solvent"
gmx solvate -cp box.gro -cs spc216.gro -o solv.gro -p topol.top
