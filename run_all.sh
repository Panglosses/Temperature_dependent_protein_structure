#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

bash "$SCRIPT_DIR/scripts/00_preparation/01_setup_pdb.sh"
bash "$SCRIPT_DIR/scripts/00_preparation/02_box_solvate.sh"
bash "$SCRIPT_DIR/scripts/00_preparation/03_add_ions.sh"

bash "$SCRIPT_DIR/scripts/01_equilibration/04_energy_minimization.sh"
bash "$SCRIPT_DIR/scripts/01_equilibration/05_nvt_equilibration.sh"
bash "$SCRIPT_DIR/scripts/01_equilibration/06_npt_equilibration.sh"

bash "$SCRIPT_DIR/scripts/02_production/07_production_md.sh"

bash "$SCRIPT_DIR/scripts/03_analysis/08_analysis_rmsd.sh"
bash "$SCRIPT_DIR/scripts/03_analysis/09_analysis_gyrate.sh"
bash "$SCRIPT_DIR/scripts/03_analysis/10_analysis_hbond.sh"
bash "$SCRIPT_DIR/scripts/03_analysis/11_analysis_dssp.sh"
bash "$SCRIPT_DIR/scripts/03_analysis/12_extract_final_structure.sh"
bash "$SCRIPT_DIR/scripts/03_analysis/13_collect_metrics.sh"
