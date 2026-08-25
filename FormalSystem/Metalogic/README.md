# TM Bimodal Logic Metalogic

Soundness, completeness, and decidability for the bimodal logic TM, combining S5
modality with linear temporal logic.

This directory is the largest thing in the repository: **210 live `.lean` files**,
of which 135 sit under `WeakCanonical/` alone. Every count below excludes the archive — see
[Counting Live Files](#counting-live-files).

## Counting Live Files

Archived code lives in exactly one place, [`FormalSystem/Boneyard/`](../Boneyard/README.md),
which is also the single place its counts are stated — this page does not restate them. There
used to be a second archive nested at `WeakCanonical/Kamp/Boneyard/`, and a `find` filter naming
only the top-level directory silently counted it as live. The two were consolidated, and B0 now
asserts the archive-directory count is exactly 1. Use the invariant script rather than an ad-hoc
`find`:

```bash
bash scripts/check-module-invariants.sh              # C7 prints the live inventory
bash scripts/check-module-invariants.sh --no-build   # structural checks only, no build
```

## The Three Completeness Routes

This is the central organizing question of the directory: there are **three**
distinct routes to completeness, and they are siblings rather than layers.

| Route | Directory | Files | Lines | Approach |
|-------|-----------|------:|------:|----------|
| Chronicle | `BXCanonical/` | 20 | 18,527 | Chronicle construction over a canonical chain; carries the flagship theorems |
| Kamp/Reynolds | `WeakCanonical/` | 135 | 106,253 | Reflexive canonical model, separation, and the Kamp/Reynolds machinery |
| Parametric/algebraic | `Algebraic/` | 9 | 3,748 | Lindenbaum–Tarski quotient algebra and a parametric canonical model |

**`BXCanonical` is the wired entry point.** The flagship results — `completeness`,
`completeness_dense` and `completeness_discrete` (`BXCanonical/Completeness.lean`),
and `countermodel_dense` (`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`)
— live on this route.

The other two are **not** dead alternatives. `BXCanonical` imports from both of them,
so all three participate in the live proof:

- `BXCanonical → WeakCanonical` — 2 import lines
- `BXCanonical → Algebraic` — 2 import lines

Beneath all three sits a genuinely layered core:

```
        Core/  ──18 edges──►  Bundle/
          ▲                      │
          └────── 1 edge ────────┘

                Bundle/
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
   Algebraic/  BXCanonical/  WeakCanonical/
                   ▲   │
                   │   ▼
              (mutual — see below)
```

## Why There Is No Physical Regroup

A natural instinct is to nest the three routes under a `Completeness/` parent, or to
nest one inside another. **Measurement rules both out.** This is a decision, not an
oversight.

There are exactly **two** directory-level cycles in `Metalogic/`. Both are enumerated
edge-by-edge, file-and-line, in the measurement output this document is drawn from —
regenerated from the tree rather than copied from any report.

### Cycle 1: `BXCanonical` ↔ `WeakCanonical`

```
BXCanonical → WeakCanonical  (2 import lines)
  BXCanonical/Chronicle/ChronicleToCountermodel.lean
      → FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructuresModelSurgery
  BXCanonical/Completeness.lean
      → FormalSystem.Metalogic.WeakCanonical

WeakCanonical → BXCanonical  (4 import lines)
  WeakCanonical/ChronicleExtraction.lean
      → FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleConstruction
      → FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
  WeakCanonical/ReflexiveCanonical.lean
      → FormalSystem.Metalogic.BXCanonical.OrderedSeedConsistency
  WeakCanonical/Transfer.lean
      → FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
```

### Cycle 2: `Bundle` ↔ `Core`

```
Bundle → Core  (18 import lines across 10 files)
Core  → Bundle (1 import line)
  Core/RestrictedMCS/Basic.lean → FormalSystem.Metalogic.Bundle.CanonicalTaskRelation
```

Nesting either pair produces a directory whose contents import upward out of it —
which is not a hierarchy. Lean permits these cycles because they exist only at
*directory* granularity; the module-level dependency graph is acyclic, which is why
the build works at all. Directory structure simply cannot express a mutual dependency.

### The declined regroup, and its evidence

Physically regrouping the three routes was **considered and declined**. Beyond the
cycle argument: `WeakCanonical` is 339 import lines across 137 live files, roughly
five times the next-largest subtree. That makes it the single largest partial-move
risk in the repository, and a half-updated move leaving dangling imports is worse
than no move at all. The deliverable is therefore a correct map plus a standardized
aggregator convention, not a physical relocation.

Breaking cycle 2 was also measured, not assumed: relocating the sole `Core → Bundle`
edge (`Core/RestrictedMCS/Basic.lean`) needs only 2 import-line edits, but touches
9 files, 5 of them markdown. That exceeded the agreed file-count threshold, so it was
skipped and recorded rather than half-done.

## Aggregator Convention

Every subdirectory has exactly one **sibling** aggregator: `X.lean` sits *beside*
`X/`, never inside it as `X/X.lean`.

| Aggregator | Lines | Aggregates |
|------------|------:|-----------|
| `Algebraic.lean` | 41 | `Algebraic/` |
| `Bundle.lean` | 43 | `Bundle/` |
| `BXCanonical.lean` | 34 | `BXCanonical/` |
| `Core.lean` | 37 | `Core/` |
| `Decidability.lean` | 52 | `Decidability/` |
| `SoundnessLemmas.lean` | 31 | `SoundnessLemmas/` |
| `WeakCanonical.lean` | 80 | `WeakCanonical/` |

Two loose files are not aggregators: `Soundness.lean` (1,394 lines — the soundness
theorem itself) and the directory's own root `Metalogic.lean`, which sits one level
up, beside `Metalogic/`.

Two rules keep this safe:

1. **Aggregators import concrete leaf modules only.** No existing file is edited to
   import an aggregator — that is how a genuine module-level cycle would appear.
2. Consequently `Core.lean`, `Bundle.lean`, `Algebraic.lean` and
   `SoundnessLemmas.lean` have no importer and lie outside every Lake target's
   import closure. They are listed in `scripts/module-invariants-manifest.txt`, which
   compile-checks them, so an unreachable aggregator cannot rot unnoticed.

The one deliberate exception to the sibling rule is the Lake library root pair
`FormalSystem.lean` + `FormalSystem/Bimodal.lean`. `lean_lib FormalSystem` sets
`srcDir := "FormalSystem"` and `roots := #[`Bimodal]`, so that indirection is
load-bearing. The invariant check allowlists it by name.

## Directory Inventory

| Directory | Files | Lines | Role |
|-----------|------:|------:|------|
| [`Algebraic/`](Algebraic/README.md) | 9 | 3,748 | Parametric/algebraic completeness route |
| [`Bundle/`](Bundle/README.md) | 12 | 4,650 | Canonical frame from bundled families of MCSs |
| [`BXCanonical/`](BXCanonical/README.md) | 20 | 18,527 | Chronicle completeness route; the wired entry point |
| [`Core/`](Core/README.md) | 4 | 2,048 | MCS machinery shared by all three routes |
| [`Decidability/`](Decidability/README.md) | 19 | 9,263 | Tableau decision procedure and countermodel extraction |
| [`SoundnessLemmas/`](SoundnessLemmas/README.md) | 3 | 2,461 | Per-axiom validity lemmas feeding `Soundness.lean` |
| [`WeakCanonical/`](WeakCanonical/README.md) | 135 | 106,253 | Kamp/Reynolds route, including all of `Kamp/` |

### Inside `BXCanonical/`

Loose modules: `CanonicalChain.lean`, `CanonicalModel.lean`, `Completeness.lean`,
`Frame.lean`, `OrderedSeedConsistency.lean`, `TruthLemma.lean`.
Subdirectories: `Chronicle/` (8 files), `Quasimodel/` (5), `Filtration/` (1).

### Inside `WeakCanonical/`, and the `Kamp/` subtree

`WeakCanonical/` holds 14 loose modules plus five subdirectories. One of them
dominates everything else in the repository:

| Subdirectory | Files | Lines |
|--------------|------:|------:|
| `Kamp/` | 99 | 71,246 |
| `EFGames/` | 8 | 11,872 |
| `Expressiveness/` | 5 | 9,503 |
| `IntegerModel/` | 6 | 5,503 |
| `Separation/` | 3 | 926 |

`Kamp/` is the Kamp/Reynolds separation machinery: 49 loose modules plus two large
sub-subtrees. It no longer carries a local `Boneyard/`; its archived work is in
[`FormalSystem/Boneyard/Kamp/`](../Boneyard/Kamp/README.md).

| Under `Kamp/` | Files | Lines |
|---------------|------:|------:|
| `NfMultiAnchorBridge/` | 43 | 41,859 |
| `EANegationFix/` | 7 | 3,227 |

`Kamp/` alone is larger than every other directory in `Metalogic/` combined. Any
description of this repository's shape that omits it is wrong about the repository.

## Main Results

### Soundness — `Soundness.lean`

Every derivable formula is valid on the corresponding frame class. The per-axiom
validity lemmas live in `SoundnessLemmas/`, so `Soundness.lean` assembles them
rather than restating them.

### Completeness — `BXCanonical/Completeness.lean`

- `completeness` — the general Base-frame result
- `completeness_dense` — dense frame class
- `completeness_discrete` — discrete frame class
- `countermodel_dense` — in `BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`

These four are the repository's axiom-set invariant. Their `#print axioms` results
are asserted by the invariant script:

```
completeness            [propext, sorryAx, Classical.choice, Quot.sound]
completeness_dense      [propext, Classical.choice, Quot.sound]
completeness_discrete   [propext, Classical.choice, Quot.sound]
countermodel_dense      [propext, Classical.choice, Quot.sound]
```

A change to any of these means a proof was silently rerouted through different
dependencies — detectable even when the build stays green and the sorry count is
unchanged. It is a hard stop, not a new baseline.

### Decidability — `Decidability/`

A tableau-based decision procedure with countermodel extraction, plus a separate
propositional fragment under `Decidability/Propositional/`.

```lean
import FormalSystem.Metalogic.Decidability   -- decide, isValid, isSatisfiable
```

## Sorry Status

The live tree carries exactly **one** structural `sorry`:

- `WeakCanonical/Transfer.lean`, inside `theorem countermodel_discrete`

This is why `completeness` depends on `sorryAx` while `completeness_dense` and
`completeness_discrete` do not: the sorry-free discrete result routes through
`countermodel_discrete_reynolds_v2` in
`WeakCanonical/IntegerModel/ReynoldsBridge.lean` instead.

Locate this sorry **by content** — the enclosing theorem name — never by line
number. The invariant check does exactly that, so the assertion survives edits above
it in the file.

Sorries inside the archive are archived dead ends, not open obligations.

## Position of `FrameConditions/`

`FrameConditions/` is a sibling of `Metalogic/`, not part of it, and this is settled
on measured evidence rather than preference: **zero** files under `Metalogic/` import
`Bimodal.FrameConditions`, while `FrameConditions/` imports
`Bimodal.Metalogic.Soundness`. It is a typeclass API layer sitting strictly *above*
Metalogic; merging it inward would invert the dependency direction and manufacture a
new cycle. See [`../FrameConditions/README.md`](../FrameConditions/README.md).

## A Known Layering Wrinkle

Four files under `Decidability/` import from `Automation/`:

```
Decidability/Closure.lean            → FormalSystem.Automation.ProofSearch.Core
Decidability/DecisionProcedure.lean  → FormalSystem.Automation.ProofSearch.Strategies
Decidability/DecisionProcedure.lean  → FormalSystem.Automation.Normalization
Decidability/TraceExport.lean        → FormalSystem.Automation.DataExport
```

These are upward edges: `Automation/` is a consumer layer that itself imports
`Bimodal.Metalogic.Decidability.*`. The decision procedure reuses the proof-search
engine, so the boundary between the two is genuinely blurred. Recorded here as a
known wrinkle rather than silently tolerated; resolving it means relocating the
proof-search / decision-procedure boundary, which is separate work.

## Verification

```bash
lake build                                 # library
lake build BimodalTest                     # test suite
bash scripts/check-module-invariants.sh    # all structural invariants
```

The invariant script checks the build, the four flagship axiom sets, the structural-sorry
inventory (asserted at zero, by content), dangling imports across every live `.lean`, dangling module paths in
markdown, compile-checks known-unreachable modules, and the aggregator convention.
It is the correct way to answer "did the reorganization break anything" — and the
correct way to re-derive any count in this document.

## Related Documentation

- [Parent README](../README.md) — library overview and the archive-exclusion notice
- [Core](Core/README.md) · [Bundle](Bundle/README.md) · [BXCanonical](BXCanonical/README.md)
- [WeakCanonical](WeakCanonical/README.md) · [Algebraic](Algebraic/README.md)
- [Decidability](Decidability/README.md) · [SoundnessLemmas](SoundnessLemmas/README.md)

## References

- Burgess 1982 — chronicle construction for temporal completeness
- Reynolds 1994, Theorems 14–18 — the discrete completeness route
- Doets 1989, Section 1 — k-types, ordered sums (Lemmas 1.4, 1.5)
- Kamp 1968 — separation and expressive completeness
- Blackburn et al., *Modal Logic*, Chapters 4–5
