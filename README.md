# IpaA-Vinculin MD Pipeline

This folder contains the GitHub-ready code for the CMML ICA1 mini-project:
temperature-dependent molecular dynamics analysis of the IpaA-vinculin complex.

## What changed

The original `code/` directory contained 12 flat scripts. They worked, but they
were hard to browse, reuse, or extend. The code is now reorganized into:

- `config/`: shared pipeline parameters and reusable `.mdp` files
- `scripts/00_preparation/`: structure setup, solvation, ion addition
- `scripts/01_equilibration/`: energy minimization, NVT, NPT
- `scripts/02_production/`: 50 ns production MD at 280 K, 300 K, and 320 K
- `scripts/03_analysis/`: RMSD, Rg, hydrogen bonds, DSSP, final structure export,
  and a computed summary table
- `utils/`: common shell helpers shared by all scripts
- `docs/`: manual steps that were part of the report but not fully scripted

This structure keeps the pipeline order obvious while making it easier to
maintain.

## Directory layout

```text
code/
  README.md
  run_all.sh
  config/
    defaults.sh
    mdp/
      ions.mdp
      em.mdp
      nvt.mdp
      npt.mdp
      md.template.mdp
  docs/
    manual_steps.md
  scripts/
    00_preparation/
      00_fix_structure_with_pdbfixer.py
      01_setup_pdb.sh
      02_box_solvate.sh
      03_add_ions.sh
    01_equilibration/
      04_energy_minimization.sh
      05_nvt_equilibration.sh
      06_npt_equilibration.sh
    02_production/
      07_production_md.sh
    03_analysis/
      08_analysis_rmsd.sh
      09_analysis_gyrate.sh
      10_analysis_hbond.sh
      11_analysis_dssp.sh
      12_extract_final_structure.sh
      13_collect_metrics.sh
  utils/
    common.sh
```

## Requirements

- `bash`
- `gmx` from GROMACS
- `wget`
- DSSP support for `gmx dssp`
- optional: `pdbfixer` and `openmm` if you want to repair the input PDB first
- A Linux or HPC environment is recommended for production runs

## Default pipeline settings

The shared settings live in `config/defaults.sh`.

Key defaults:

- working directory: `~/ICA_3RF3`
- PDB ID: `3RF3`
- force field: `amber99sb-ildn`
- water model: `tip3p`
- box distance: `1.0 nm`
- ion concentration: `0.15 M`
- production temperatures: `280 300 320`
- production length: `50 ns`
- analysis window: `40-50 ns`

Important note:

- the hydrogen-bond script still uses atom-index ranges to separate the two
  chains
- if you change the input structure or repair it with PDBFixer, re-check
  `CHAIN_A_RANGE` and `CHAIN_B_RANGE` in `config/defaults.sh`

You can override settings at runtime, for example:

```bash
export WORKDIR="$HOME/my_md_run"
export INPUT_PDB="3RF3_clean.pdb"
export PRODUCTION_THREADS=8
export MDRUN_NB=cpu
```

## Run order

Run the full pipeline:

```bash
bash run_all.sh
```

Or run stage by stage:

```bash
python scripts/00_preparation/00_fix_structure_with_pdbfixer.py \
  --input 3RF3.pdb \
  --output 3RF3_clean.pdb

export INPUT_PDB="3RF3_clean.pdb"
bash scripts/00_preparation/01_setup_pdb.sh
bash scripts/00_preparation/02_box_solvate.sh
bash scripts/00_preparation/03_add_ions.sh

bash scripts/01_equilibration/04_energy_minimization.sh
bash scripts/01_equilibration/05_nvt_equilibration.sh
bash scripts/01_equilibration/06_npt_equilibration.sh

bash scripts/02_production/07_production_md.sh

bash scripts/03_analysis/08_analysis_rmsd.sh
bash scripts/03_analysis/09_analysis_gyrate.sh
bash scripts/03_analysis/10_analysis_hbond.sh
bash scripts/03_analysis/11_analysis_dssp.sh
bash scripts/03_analysis/12_extract_final_structure.sh
bash scripts/03_analysis/13_collect_metrics.sh
```

## Outputs

The scripts write the MD outputs into `WORKDIR` and place the final exported
artifacts under:

```text
$WORKDIR/analysis_artifacts/
  final_structures/
  summaries/
```

`13_collect_metrics.sh` creates:

- `summary_table_computed.csv`

This file includes the metrics that are directly computed from the scripted
pipeline:

- RMSD mean and standard deviation
- radius of gyration
- inter-chain hydrogen bonds
- DSSP secondary-structure percentages

## What is intentionally documented but not fully scripted

Some results in the final report came from tools that are partly manual or
web-based, such as:

- PROCHECK Ramachandran outliers
- PISA interface area and binding free energy
- AlphaFold structure comparison and alignment

These steps are described in [docs/manual_steps.md](docs/manual_steps.md).

## Figure export note

For structure figures, use the outputs from `12_extract_final_structure.sh`
instead of extracting directly from the raw trajectory in PyMOL.

- `final_*_protein_whole.pdb`: protein-only final frame after PBC correction
- `final_*_protein_noH.pdb`: the same structure with hydrogens removed for
  cleaner visualization

This avoids floating bond lines caused by periodic boundary wrapping and usually
produces cleaner overlay figures.

## Optional structure-repair step

There was also a separate `PDBFixer` helper in the original project directory.
It is now included as `scripts/00_preparation/00_fix_structure_with_pdbfixer.py`
so structure repair is tracked together with the main pipeline instead of living
as an unrelated file elsewhere in the project tree.

## Why this split is better

- Repeated `.mdp` content is no longer embedded in multiple scripts.
- Shared parameters are defined once in `config/defaults.sh`.
- The numbered workflow is still preserved for traceability.
- Analysis is separated from simulation, so reruns are easier.
- The repository now makes clear which parts are automated and which parts are
  report-side manual checks.
