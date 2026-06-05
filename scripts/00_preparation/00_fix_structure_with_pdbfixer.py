#!/usr/bin/env python3
"""Repair a PDB structure with PDBFixer before the GROMACS workflow."""

from __future__ import annotations

import argparse
from pathlib import Path

from openmm.app import PDBFile
from pdbfixer import PDBFixer


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Repair missing atoms and hydrogens in a PDB file with PDBFixer."
    )
    parser.add_argument("--input", required=True, help="Input PDB file path.")
    parser.add_argument("--output", required=True, help="Output repaired PDB file path.")
    parser.add_argument(
        "--ph",
        type=float,
        default=7.0,
        help="pH used for adding hydrogens. Default: 7.0",
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    input_path = Path(args.input)
    output_path = Path(args.output)

    if not input_path.exists():
        raise FileNotFoundError(f"Input PDB not found: {input_path}")

    fixer = PDBFixer(filename=str(input_path))
    fixer.findMissingResidues()
    fixer.findMissingAtoms()
    fixer.addMissingAtoms()
    fixer.addMissingHydrogens(args.ph)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    with output_path.open("w") as handle:
        PDBFile.writeFile(fixer.topology, fixer.positions, handle)

    print(f"Repaired structure written to: {output_path}")


if __name__ == "__main__":
    main()
