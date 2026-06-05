# Manual and Semi-Manual Steps

This project report included several checks that are important scientifically
but are not fully automated in the shell pipeline.

## 1. PROCHECK Ramachandran analysis

Purpose:

- assess stereochemical quality
- report the percentage of residues in disallowed regions

Typical manual workflow:

1. export the final protein-only PDB for each temperature
2. upload the structure to the PROCHECK or PDBsum service
3. record the outlier percentage for the summary table

## 2. PISA interface analysis

Purpose:

- calculate interface area
- estimate solvation free energy and binding-related terms

Typical manual workflow:

1. upload the final protein-only PDB
2. select the relevant chains for the IpaA-vinculin interface
3. record interface area and Delta G values

## 3. AlphaFold or ColabFold structure comparison

Purpose:

- compare the MD-derived complex with a static predicted model

Typical workflow:

1. generate the AlphaFold multimer model outside this pipeline
2. align the predicted model and the MD final frame in PyMOL
3. compute or record the alignment RMSD

## 4. What is scripted vs not scripted

Scripted in this repository:

- GROMACS preparation
- equilibration
- production MD
- RMSD
- radius of gyration
- inter-chain hydrogen bonds
- DSSP summary
- final frame export
- computed summary table

Not fully scripted here:

- PROCHECK web output
- PISA web output
- AlphaFold generation and PyMOL alignment

This split is intentional so the repository stays reproducible without claiming
that all report figures came from a single local script.
