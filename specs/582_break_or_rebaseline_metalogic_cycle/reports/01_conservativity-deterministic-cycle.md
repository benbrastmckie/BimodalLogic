# Sweep Evidence Report: Task #582

**Task**: 582 — Break or re-baseline the Conservativity ↔ Deterministic directory cycle in `Metalogic/`
**Produced**: 2026-09-16 (repository hygiene sweep)
**Status**: Pre-research evidence. The decision this task turns on is architectural and belongs to the user.
**Effort**: Small if broken mechanically (two import lines); Medium if re-baselined (needs a costed decision record)
**Dependencies**: None
**Sources/Inputs**:
- `scripts/check-metalogic-cycles.sh` (the assertion), its full output
- `FormalSystem/Metalogic/Conservativity/Plus/Corollaries.lean`, `FormalSystem/Metalogic/Deterministic/Soundness.lean`
- `FormalSystem/Metalogic/README.md:73`
- `docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md`
- Commit `5bd08ce1a` (2026-09-08), where both import lines landed
- `specs/reviews/review-2026-09-16.md`, Finding H1

## Executive Summary

- **`scripts/check-metalogic-cycles.sh` exits 1 today**: it asserts exactly one directory-level
  cycle in `Metalogic/` and finds two.
- **The new cycle is `Conservativity ↔ Deterministic`, and its entire surface is two import
  lines.** That is the smallest possible cycle and the reason this is worth fixing rather than
  accepting by default.
- **It has been present for 99 commits**, since `5bd08ce1a` (2026-09-08), undetected because the
  script is not in CI (see task 583).
- **`FormalSystem/Metalogic/README.md:73` currently states something false**: "There is exactly
  one directory-level cycle in `Metalogic/`", citing this script as the thing that establishes
  it. The sweep deliberately did **not** edit that line, because changing it to "two" would
  pre-judge this task's decision. Whichever way the decision goes, that line is updated in the
  same change.
- **This is a decision, not a defect to be silently patched.** Bumping the script's expected
  count from 1 to 2 would make it green in one character and is exactly what the script exists to
  prevent.

## The measurement

```
CYCLE  BXCanonical <-> WeakCanonical          (the documented, accepted one)
         BXCanonical -> WeakCanonical  (9 import lines)
         WeakCanonical -> BXCanonical  (5 import lines)
CYCLE  Conservativity <-> Deterministic       (the new one)
         Conservativity -> Deterministic  (1 import line)
           Conservativity/Plus/Corollaries.lean -> FormalSystem.Metalogic.Deterministic.Completeness
         Deterministic -> Conservativity  (1 import line)
           Deterministic/Soundness.lean -> FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness
FAIL  expected exactly 1 directory-level import cycle in FormalSystem/Metalogic/, found 2
```

Both offending files were last touched by the same commit:

```
$ git log --oneline -1 -- FormalSystem/Metalogic/Conservativity/Plus/Corollaries.lean
5bd08ce1a task 537: complete implementation
$ git log --oneline -1 -- FormalSystem/Metalogic/Deterministic/Soundness.lean
5bd08ce1a task 537: complete implementation
```

`Corollaries.lean` imports, in full:

```lean
import FormalSystem.Metalogic.Conservativity.Plus.Forward
import FormalSystem.Metalogic.Deterministic.Completeness   -- the outbound edge
import FormalSystem.Theorems.TemporalDerived
```

`Soundness.lean` imports, in full:

```lean
import FormalSystem.Metalogic.Deterministic.System
import FormalSystem.Metalogic.Deterministic.Validity
import FormalSystem.Metalogic.Conservativity.Plus.PlusSoundness   -- the return edge
```

## What "directory-level edge" means here

From the script's own header, reproduced so the decision is made against the right notion: for
every live `.lean` file at `Metalogic/<Src>/…`, every `import FormalSystem.Metalogic.<Dst>…`
where `<Dst>` names a real subdirectory of `Metalogic/` and `<Dst> ≠ <Src>` contributes the edge
`<Src> → <Dst>`. A cycle is a pair `{A, B}` with both edges present. Sibling aggregators
(`Metalogic/<X>.lean`) are excluded as edge *sources* but not as *targets*. This is the same
notion `Metalogic/README.md` documents.

Note what this means for the fix: moving either import to a different *file* within the same
directory does not break the cycle. Only changing which *directory* is imported does.

## The two options

### Option A — break the cycle

The usual move is to lift whatever both sides need into a third directory both may import.
Research should determine:

1. **What `Corollaries.lean` actually consumes from `Deterministic.Completeness`.** If it is one
   or two declarations, they may be liftable, or the corollary may belong in `Deterministic/`.
2. **What `Soundness.lean` actually consumes from `Conservativity.Plus.PlusSoundness`.** The
   PlusSoundness module's docstring records that "TD is discharged semantically, never
   proof-theoretically", and `Deterministic/Soundness.lean:30` says the same thing about its own
   `temporal_duality` case — which suggests the two files share a soundness argument that might
   have a natural home below both.
3. Whether either direction is a genuine layering inversion (soundness depending on completeness,
   or vice versa) rather than an incidental reuse.

Cost is bounded: two import lines, and whatever lifting they imply.

### Option B — accept and re-baseline

Legitimate, but it must be a *recorded* decision with the same costing ADR-006 applied to the
`BXCanonical ↔ WeakCanonical` pair, not a threshold bump. If chosen, the change set is:

- `scripts/check-metalogic-cycles.sh`: expected count 1 → 2, **and** its header rewritten to name
  both accepted cycles, so a third one still fails.
- `FormalSystem/Metalogic/README.md:73` and the surrounding paragraph.
- A new ADR (or an amendment to ADR-006) recording why this cycle is accepted.

The bar for Option B should be high. ADR-006 declined a `Metalogic/` regroup in part *because* of
how expensive the one existing cycle makes any future move; a second cycle raises that cost
again, and this one was acquired without anyone deciding to acquire it.

## Recommended approach

Research Option A first and cost it concretely (which declarations, which direction, what lifts
where). Only if that cost is disproportionate to two import lines should Option B be put to the
user. Either way, present the choice — do not pick silently.

## Verification

- `bash scripts/check-metalogic-cycles.sh` exits 0.
- `lake build` exits 0 and `bash scripts/check-module-invariants.sh` passes in full (C4 import
  resolution, C6 unreachable-module manifest, C24 Init closure all move if modules are relocated).
- `FormalSystem/Metalogic/README.md`'s cycle claim matches what the script now asserts.
- If Option B: a decision record exists and names both cycles.
