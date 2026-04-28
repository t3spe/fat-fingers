#!/usr/bin/env python3
"""Sample slop fixtures from downloaded corpora into tests/samples/.

Idempotent. Deterministic by default (seed=42). HC3 sidecars include the
human reference answer as `.human.md` so the runner can do paired
comparisons later.

Usage:
  ./sample-corpora.py                    # default: 2 HC3/domain (10 total) + 10 RAID
  ./sample-corpora.py --hc3 5 --raid 30  # bigger sample
  ./sample-corpora.py --seed 123         # different draw
  ./sample-corpora.py --clean            # wipe samples/ before sampling

Requires ./download-corpora.sh to have run first.
"""

import argparse
import csv
import json
import random
import shutil
import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
CORPORA_DIR = SCRIPT_DIR / "corpora"
SAMPLES_DIR = SCRIPT_DIR / "samples"

HC3_DOMAINS = ["finance", "medicine", "open_qa", "reddit_eli5", "wiki_csai"]


def slugify(text: str, maxlen: int = 40) -> str:
    """Filesystem-safe slug. Lowercases and collapses non-alnum to single dashes."""
    safe = "".join(c.lower() if c.isalnum() else "-" for c in text)
    safe = "-".join(filter(None, safe.split("-")))
    return safe[:maxlen].strip("-") or "untitled"


def sample_hc3(per_domain: int, rng: random.Random) -> int:
    src = CORPORA_DIR / "hc3"
    if not src.exists():
        print(f"  ✗ {src} missing — run ./download-corpora.sh first", file=sys.stderr)
        return 0

    out_dir = SAMPLES_DIR / "hc3"
    out_dir.mkdir(parents=True, exist_ok=True)
    written = 0

    for dom in HC3_DOMAINS:
        path = src / f"{dom}.jsonl"
        if not path.exists():
            print(f"  skip {dom}: file not found", file=sys.stderr)
            continue

        with open(path) as f:
            records = [json.loads(line) for line in f if line.strip()]

        # Need both AI and human answers, and non-trivial length on each.
        records = [
            r for r in records
            if r.get("chatgpt_answers") and r["chatgpt_answers"][0].strip()
            and r.get("human_answers") and r["human_answers"][0].strip()
            and 200 <= len(r["chatgpt_answers"][0]) <= 3000
        ]

        n = min(per_domain, len(records))
        sample = rng.sample(records, n)

        for i, rec in enumerate(sample, 1):
            slug = slugify(rec.get("question", ""))
            stem = out_dir / f"{dom}-{i:02d}-{slug}"
            stem.with_suffix(".md").write_text(rec["chatgpt_answers"][0].strip() + "\n")
            stem.with_suffix(".human.md").write_text(rec["human_answers"][0].strip() + "\n")
            written += 1

        print(f"  hc3/{dom:<14} {n} samples (filtered from {len(records)} usable records)")

    return written


def sample_raid(count: int, rng: random.Random) -> int:
    src = CORPORA_DIR / "raid" / "test.csv"
    if not src.exists():
        print(f"  ✗ {src} missing — run ./download-corpora.sh first", file=sys.stderr)
        return 0

    out_dir = SAMPLES_DIR / "raid"
    out_dir.mkdir(parents=True, exist_ok=True)

    csv.field_size_limit(sys.maxsize)

    # Reservoir sampling — RAID test is 8.6M rows, can't load all in memory.
    # Filter as we go: skip too-short or too-long generations.
    reservoir: list[str] = []
    seen = 0
    with open(src, newline="") as f:
        reader = csv.reader(f)
        header = next(reader)
        gen_idx = header.index("generation")

        for row in reader:
            try:
                text = row[gen_idx].strip()
            except IndexError:
                continue
            if not (200 <= len(text) <= 3000):
                continue
            seen += 1
            if len(reservoir) < count:
                reservoir.append(text)
            else:
                j = rng.randrange(seen)
                if j < count:
                    reservoir[j] = text

    for i, text in enumerate(reservoir, 1):
        (out_dir / f"raid-{i:03d}.md").write_text(text + "\n")

    print(f"  raid/{'test':<14} {len(reservoir)} samples (reservoir from {seen:,} usable rows)")
    return len(reservoir)


def main() -> int:
    p = argparse.ArgumentParser(description=__doc__.split("\n", 1)[0])
    p.add_argument("--hc3", type=int, default=2, help="HC3 records per domain (default: 2)")
    p.add_argument("--raid", type=int, default=10, help="RAID records (default: 10)")
    p.add_argument("--seed", type=int, default=42, help="random seed (default: 42)")
    p.add_argument("--clean", action="store_true", help="wipe samples/ before sampling")
    args = p.parse_args()

    if args.clean and SAMPLES_DIR.exists():
        shutil.rmtree(SAMPLES_DIR)
        print(f"  cleaned {SAMPLES_DIR}")

    rng = random.Random(args.seed)
    print(f"Sampling with seed={args.seed}:")
    n_hc3 = sample_hc3(args.hc3, rng)
    n_raid = sample_raid(args.raid, rng)

    print()
    print(f"=== Summary ===")
    print(f"  HC3:  {n_hc3} fixtures (each with .human.md sidecar)")
    print(f"  RAID: {n_raid} fixtures")
    print(f"  Total: {n_hc3 + n_raid} fixtures in {SAMPLES_DIR}/")
    return 0


if __name__ == "__main__":
    sys.exit(main())
