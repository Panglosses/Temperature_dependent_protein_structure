#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../utils/common.sh"

require_commands gmx wget
prepare_workspace

if [ ! -f "$INPUT_PDB" ]; then
    if [ "$DOWNLOAD_PDB" = "1" ]; then
        log "Downloading ${PDB_ID}.pdb from RCSB"
        wget "https://files.rcsb.org/download/${PDB_ID}.pdb" -O "$PDB_FILE"
    else
        echo "Input PDB not found: $INPUT_PDB" >&2
        exit 1
    fi
fi

log "Running pdb2gmx with force field ${FORCE_FIELD} and water model ${WATER_MODEL}"
gmx pdb2gmx \
    -f "$INPUT_PDB" \
    -o complex.gro \
    -p topol.top \
    -ff "$FORCE_FIELD" \
    -water "$WATER_MODEL" \
    -ignh
