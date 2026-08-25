#!/usr/bin/env python3
"""c4 spot-check gate for the c7 labeling-bug fix.

Replaces a stale exact-record-count gate (== 806). That baseline was generated on
2026-06-08 and predates ~525 commits to FormalSystem/, including a new
`structural_invalid_prefilter` and this fix's own adaptive-fuel change -- so the record
count legitimately moved (806 -> 3087) for reasons unrelated to the timeout fix.

What actually must hold is soundness and coverage, not an equal count:

  1. No soundness flip.   No formula common to both runs may change between `valid` and
                          `invalid`. Only timeout<->decided movement is permitted, since
                          fuel and prefilters changed.
  2. Coverage retained.   At least 99% of baseline formulas must reappear in the new run.
  3. No decisiveness loss. The new timeout *rate* must not exceed the baseline's.

Exit 0 = pass.
"""
import json
import sys
from collections import Counter

COVERAGE_MIN = 0.99


def load(path):
    out = {}
    with open(path) as fh:
        for line in fh:
            line = line.strip()
            if line:
                rec = json.loads(line)
                out[rec["formula_str"]] = rec.get("label")
    return out


def main(baseline_path, new_path):
    base, new = load(baseline_path), load(new_path)
    if not new:
        print("FAIL: new c4 run produced no records")
        return 1

    common = base.keys() & new.keys()
    flips = [f for f in common if {base[f], new[f]} == {"valid", "invalid"}]
    moves = Counter((base[f], new[f]) for f in common if base[f] != new[f])
    coverage = len(common) / len(base) if base else 1.0
    base_rate = sum(v == "timeout" for v in base.values()) / len(base)
    new_rate = sum(v == "timeout" for v in new.values()) / len(new)

    print(f"baseline={len(base)} new={len(new)} common={len(common)}")
    print(f"coverage={coverage:.4f} (min {COVERAGE_MIN})")
    print(f"timeout rate: baseline={base_rate:.4f} new={new_rate:.4f}")
    print(f"label movement: {dict(moves)}")

    failures = []
    if flips:
        failures.append(f"{len(flips)} valid<->invalid soundness flips, e.g. {flips[:3]}")
    if coverage < COVERAGE_MIN:
        missing = sorted(base.keys() - new.keys())[:5]
        failures.append(f"coverage {coverage:.4f} below {COVERAGE_MIN}; missing e.g. {missing}")
    if new_rate > base_rate:
        failures.append(f"timeout rate rose {base_rate:.4f} -> {new_rate:.4f}")

    for f in failures:
        print(f"FAIL: {f}")
    if failures:
        return 1
    print("PASS: c4 spot-check sound (no valid<->invalid flips, coverage and decisiveness held)")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1], sys.argv[2]))
