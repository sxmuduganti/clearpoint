#!/usr/bin/env python3
"""Render a RECFM=FBA print file (ASA carriage control) as plain text."""

import argparse
import sys
from pathlib import Path

SPACING = {" ": 0, "0": 1, "-": 2, "+": 0}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lrecl", type=int, default=133)
    parser.add_argument("input", type=Path)
    args = parser.parse_args()

    data = args.input.read_bytes()
    out = sys.stdout
    for i in range(0, len(data), args.lrecl):
        record = data[i:i + args.lrecl].decode("ascii", errors="replace")
        control, text = record[0], record[1:].rstrip()
        if control == "1":
            out.write("\n" + "=" * 132 + "\n")
        else:
            out.write("\n" * SPACING.get(control, 0))
        out.write(text + "\n")


if __name__ == "__main__":
    main()
