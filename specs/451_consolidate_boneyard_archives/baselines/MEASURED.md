# Phase 1 measured baseline (task 451)

Measured at HEAD `b7bbd6e0f`. **Concurrency note**: other agents were actively editing
`FormalSystem/` and `Tests/` during this window, so live-file counts are a moving target and are
recorded as informational, never asserted.

## Gate baselines (`baselines/*.txt`)

| Gate | Baseline result |
|---|---|
| `lake build` | exit 0, "Build completed successfully (2458 jobs)" |
| `lake build BimodalTest` | exit 0, "Build completed successfully (2508 jobs)" |
| `check-module-invariants.sh` | exit 0, ALL CHECKS PASSED |
| `readme-lint.sh` | **exit 1, RESULT: FAIL (7 missing READMEs, 5 broken references)** |
| `typst-status-counts.sh` | exit 0; content identical apart from the commit/date stamp |

### Divergence D1: `readme-lint.sh` is RED at baseline, not green

The plan (Research Integration item 4) asserts `readme-lint.sh` is currently GREEN. It is not.
Two separate problems:

1. **Latent script bug.** `readme-lint.sh` runs under `set -euo pipefail`. Checks 3 and the
   summary's broken-link count pipe `grep -oP ... | while read`. When a README contains **zero**
   markdown links, `grep` exits 1, `pipefail` propagates it, and `set -e` aborts the whole script
   mid-Check-3 with exit 1 and no summary at all. `FormalSystem/Metalogic/Decidability/Verified/README.md`
   has zero links, so the script never reached its own summary. Fixed in this task by wrapping both
   `grep -oP` calls as `{ grep ... || true; }` — semantics unchanged, only the spurious abort
   removed. `scripts/readme-lint.sh` is inside the declared `file_scope`.
2. **Genuine pre-existing RED.** With the abort fixed, the script reports its real verdict:
   7 missing READMEs and 5 broken references, none of them Boneyard-related.

Pre-existing broken references (must not increase):

- `FormalSystem/Metalogic/WeakCanonical/EFGames/README.md -> ../ExpressiveCompleteness/README.md`
- `FormalSystem/Metalogic/WeakCanonical/Expressiveness/README.md -> ../ExpressiveCompleteness/README.md`
- `FormalSystem/Metalogic/WeakCanonical/Separation/README.md -> DedekindZ/README.md`
- `FormalSystem/Metalogic/WeakCanonical/Separation/README.md -> Hierarchy/README.md`
- `FormalSystem/Theorems/Perpetuity/README.md -> Bridge.lean`

Pre-existing missing READMEs (7): `Decidability/Verified/Bridge/`, `Decidability/Verified/Termination/`,
`Metalogic/Independence/`, `WeakCanonical/DenseModelSurgery/`, `WeakCanonical/Kamp/EANegationFixFaithful/`,
`WeakCanonical/RealModel/`, `Semantics/Extension/`.

**Consequence for later phases**: every phase whose verification says "`readme-lint.sh` PASS" is
downgraded to **"no worse than this baseline"** — same 7 missing, no more than 5 broken. A PASS is
not reachable without fixing 7 live-side READMEs, which the plan's own non-goals put out of scope.

## File counts

| Quantity | Plan hypothesis | Measured |
|---|---|---|
| total `FormalSystem/**/*.lean` | 550 | **553** |
| live `FormalSystem` `.lean` | 394 | **397** |
| `Tests` `.lean` | 53 | 53 |
| live total | 448 | **450** (script's own C7 line read 448 mid-run; concurrent edits) |
| archived `.lean` (both Boneyards) | 156 | 156 |
| Boneyard directories | 2 | 2 |
| `FormalSystem/Boneyard/` | 93 lean / 59,019 lines | 93 lean (123 files) / **59,019 lines** |
| `.../Kamp/Boneyard/` | 63 lean / 29,256 lines | 63 lean (67 files) / **29,256 lines** |
| Kamp archive flat root `.lean` | 35 | 35 |

### Divergence D2: total/live counts are 3 higher than the plan

`553 / 397` rather than `550 / 394`. Cause: three live `.lean` files added by concurrently
running tasks between the research measurement and this one. Archive counts (156, 93, 63) and all
line counts match exactly, so nothing archive-side moved.

## Dangling-import census

65 unresolvable import lines across the two archives (63 in `FormalSystem/Boneyard/`, 2 in the
Kamp archive), spanning 29 distinct modules. **Matches the plan's 65 exactly.**

### Divergence D3: the A/B split is 47/18, not 48/17

| Category | Lines | Modules |
|---|---|---|
| A — repairable, exactly one target file on disk | **47** | 23 |
| B — waived | **18** | 6 |

Category B detail:

| Module | Lines | Reason |
|---|---|---|
| `FormalSystem.Metalogic.Algebraic.ParametricTruthLemma` | 5 | deleted in `6c3419a4f` |
| `FormalSystem.Metalogic.Algebraic.ParametricCompleteness` | 5 | deleted in `6c3419a4f` |
| `FormalSystem.Metalogic.Algebraic.RestrictedParametricTruthLemma` | 4 | deleted in `6c3419a4f` |
| `FormalSystem.Metalogic.Algebraic.ParametricHistory` | 2 | deleted in `6c3419a4f` |
| `FormalSystem.Metalogic.Algebraic.ParametricCanonical` | 1 | deleted in `6c3419a4f` |
| `FormalSystem.Metalogic.Completeness` | 1 | ambiguous: 4 files named `Completeness.lean` on disk |

The plan predicted 17 waived lines across 6 modules. The five deleted `Algebraic.Parametric*`
modules account for exactly 17; `FormalSystem.Metalogic.Completeness` is the 6th module and adds
a **18th** waived line. The plan implicitly counted it inside its 48 Category A while also naming
it as a waiver-file entry. The invariant that matters — "0 unwaived danglers" — is unaffected.

## Move-broken import set

| Quantity | Plan hypothesis | Measured |
|---|---|---|
| `^import FormalSystem.Metalogic.WeakCanonical.Kamp.Boneyard.*` lines, repo-wide | 55 | **55** |
| ... inside the Kamp archive | 52 | 52 |
| ... inside `FormalSystem/Boneyard/RabinovichPath/` | 3 | 3 |
| ... in any live `.lean` | 0 | 0 |

## Real vs naive import-line counts

### Divergence D4: real import-line totals are 349 / 148, not 364 / 149

| Archive | Plan (real) | Measured (real) | Naive `^import` |
|---|---|---|---|
| `FormalSystem/Boneyard/` | 364 | **349** | 366 |
| `.../Kamp/Boneyard/` | 149 | **148** | 162 |

The plan's *point* holds — the strict `(FormalSystem|BimodalTest)`-prefixed regex must be used, and
the naive count is inflated by block-comment continuation lines and fenced code. Only the plan's
recorded real numbers were off. Phase 5's C11 must report 349 + 148 = **497** scanned import lines.

## Option B safety grep

```
grep -rhoE "^import FormalSystem\.Boneyard\.(KampBypassArchive|KampNegationClosure|RabinovichPath|VecEADecomposition)(\.[A-Za-z0-9_]+)*" --include=*.lean FormalSystem/ Tests/
```

**0 hits.** Confirmed: moving those four directories under `Kamp/` breaks no resolving import.

## Move set

| Group | Files | `.lean` |
|---|---|---|
| Kamp archive -> `Boneyard/Kamp/KampWeakCanonical/` | 67 | 63 |
| 4 top-level dirs -> `Boneyard/Kamp/` | 23 | 22 |
| **Total** | **90** | **85** |

The plan's "85 files move" counts `.lean` only; 5 `README.md` files ride along, so
`git status --find-renames` will show **90** renames, not 85.
