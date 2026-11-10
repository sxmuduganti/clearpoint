#!/usr/bin/env python3
"""Sort a fixed-length record file on DFSORT-style CH keys."""

import argparse
from pathlib import Path


def parse_key(text):
    start, length = (int(part) for part in text.split(","))
    if start < 1 or length < 1:
        raise argparse.ArgumentTypeError(f"invalid key {text}")
    return start - 1, start - 1 + length


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--lrecl", type=int, required=True)
    parser.add_argument("--key", type=parse_key, action="append",
                        required=True)
    parser.add_argument("input", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    data = args.input.read_bytes()
    if len(data) % args.lrecl:
        parser.error(f"{args.input} is not a multiple of LRECL {args.lrecl}")

    records = [data[i:i + args.lrecl]
               for i in range(0, len(data), args.lrecl)]
    records.sort(key=lambda r: b"".join(r[a:b] for a, b in args.key))
    args.output.write_bytes(b"".join(records))
    print(f"fsort: {len(records)} records sorted from {args.input.name}"
          f" to {args.output.name}")


if __name__ == "__main__":
    main()
