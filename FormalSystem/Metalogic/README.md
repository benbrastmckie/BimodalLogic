# TM Bimodal Logic Metalogic

Soundness, completeness, and decidability for the bimodal logic TM, combining S5
modality with linear temporal logic.

This directory is the largest thing in the repository: **314 live `.lean` files**
(227,081 lines), of which 179 sit under `WeakCanonical/` alone. Every count below excludes the
archive — see [Counting Live Files](#counting-live-files).

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
| Chronicle | `BXCanonical/` | 28 | 23,256 | Chronicle construction over a canonical chain; carries the flagship theorems |
| Kamp/Reynolds | `WeakCanonical/` | 179 | 132,177 | Reflexive canonical model, separation, and the Kamp/Reynolds machinery |
| Algebraic | `Algebraic/` | 5 | 2,887 | Lindenbaum–Tarski quotient algebra, the ultrafilter/MCS correspondence, and the flow-frame countermodel engine |
| Independence (support) | `Independence/` | 3 | 1,097 | Axiom-independence models; not a completeness route, listed here so the inventory is exhaustive |

**`BXCanonical` is the wired entry point.** The flagship results — `completeness`,
`completeness_dense` and `completeness_discrete` (`BXCanonical/Completeness.lean`),
and `countermodel_dense` (`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`)
— live on this route.

The other two are **not** dead alternatives. `BXCanonical` imports from both of them,
so all three participate in the live proof:

- `BXCanonical → WeakCanonical` — 9 import lines
- `BXCanonical → Algebraic` — 4 import lines

Beneath all three sits a genuinely layered core:

```
        Core/  ──18 edges──►  Bundle/

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

There is exactly **one** directory-level cycle in `Metalogic/`. It is enumerated
edge-by-edge, file-and-line, in the measurement output this document is drawn from —
regenerated from the tree rather than copied from any report, and
`scripts/check-metalogic-cycles.sh` asserts the count mechanically.

There used to be a second, `Bundle` ↔ `Core`. It is gone: `Core/RestrictedMCS/Basic.lean` was
the sole reverse edge, and it now reaches the iterated-temporal syntax it needed through
`Syntax/SubformulaClosure/IteratedTemporal.lean` instead of through
`Bundle/CanonicalTaskRelation.lean`. `Bundle → Core` remains, one-directionally.

### The cycle: `BXCanonical` ↔ `WeakCanonical`

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

Nesting either of that pair inside the other produces a directory whose contents import upward
out of it — which is not a hierarchy. Lean permits the cycle because it exists only at
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
| `Algebraic.lean` | 40 | `Algebraic/` |
| `Bundle.lean` | 52 | `Bundle/` |
| `BXCanonical.lean` | 43 | `BXCanonical/` |
| `Core.lean` | 37 | `Core/` |
| `Decidability.lean` | 168 | `Decidability/` |
| `Independence.lean` | 46 | `Independence/` |
| `SoundnessLemmas.lean` | 34 | `SoundnessLemmas/` |
| `WeakCanonical.lean` | 144 | `WeakCanonical/` |

**Ten** loose files in `Metalogic/` are not aggregators — they have no same-named
sibling directory:

| Loose non-aggregator | Lines | Role |
|----------------------|------:|------|
| `Soundness.lean` | 2,108 | The soundness theorem itself |
| `StrongCompleteness.lean` | 1,002 | Strong/consequence completeness, including `completeness_dedekind`, and the two `FrameClass`-generic compactness reductions `strongCompleteness_of_compact` and `compact_of_modelExistence` |
| `SetConsequence.lean` | 638 | Set-indexed consequence relation, and the `FrameClass`-indexed satisfiability / model-existence / compactness / strong-completeness family, instantiated at all four class tags including the `.Dedekind` row (`CompactDedekind`, `StrongCompletenessDedekind`, `SatisfiableDedekindSet`, `ModelExistenceDedekind`) |
| `DiscreteNonCompactness.lean` | 331 | Non-compactness of the discrete frame class |
| `DedekindNonCompactness.lean` | 516 | Non-compactness of the Dedekind frame class — the `{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤}` witness, finitely satisfiable over `ℝ` and unsatisfiable over every Dedekind-complete carrier, refuting `CompactDedekind` and `StrongCompletenessDedekind` |
| `BaseLanguageSoundness.lean` | 482 | Soundness for the base language BL, by composing `Conservativity.translate` with `Soundness.lean` across the truth-transfer bridge `truthAt_tr`; also `bl_soundness_discrete_succ`, the binder-weakened discrete soundness theorem proved directly by induction rather than by composition |
| `Conservativity.lean` | 382 | Conservativity of the extension |
| `Compactness.lean` | 179 | Compactness and strong completeness for Base and Dense, by ultraproduct model existence |
| `TMCompletenessReduction.lean` | 155 | `TMCompleteBase ↔ ForwardBase` and its `.Discrete` mirror — an equivalence between two unasserted `Prop`s pinning "TM complete over task frames" and "forward conservativity" as the same claim |
| `SpWitness.lean` | 128 | The `(Sp)` validity witness and its TM⁺ translation, the CEB row's TM⁺ half |
| `Z1Countermodel.lean` | 194 | The `Z1` countermodel over `ℚ ×ₗ ℤ`, closing CEF with both halves machine-checked and refuting `TM_f`'s weak completeness over ℤ-time |

Plus the directory's own root `Metalogic.lean` (227 lines), which sits one level up,
beside `Metalogic/`.

Two rules keep this safe:

1. **Aggregators import concrete leaf modules only**, and no file imports an
   aggregator whose own contents already reach that file — *that* is the shape a
   genuine module-level cycle takes. Importing an aggregator per se is fine and
   routine: `Metalogic.lean` already imports `Decidability`, `Independence`,
   `BXCanonical`, `WeakCanonical` and `Algebraic`.
2. `Core.lean`, `Bundle.lean` and `SoundnessLemmas.lean` have no importer and lie
   outside every Lake target's import closure. They are listed in
   `scripts/module-invariants-manifest.txt`, which compile-checks them, so an
   unreachable aggregator cannot rot unnoticed. `Algebraic.lean` is no longer among
   them: `Metalogic.lean` imports it, so it and its four otherwise-orphaned children
   are compiled by `lake build` itself rather than by the C6 manifest.

The one deliberate exception to the sibling rule is the Lake library root pair
`FormalSystem.lean` + `FormalSystem/FormalSystem.lean` — *both* files, not one of them.
`lean_lib FormalSystem` sets `srcDir := "."` and ``roots := #[`FormalSystem]`` (`lakefile.lean:15-19`),
so module `FormalSystem` resolves to the **repository-root** `FormalSystem.lean` (50 lines), which
in turn imports module `FormalSystem.FormalSystem` — the file `FormalSystem/FormalSystem.lean`
(107 lines). That self-named indirection is load-bearing, not a convention violation. The
invariant check allowlists it by name (check C8; the allowlist entry is the inner file).

## Directory Inventory

| Directory | Files | Lines | Role |
|-----------|------:|------:|------|
| [`Algebraic/`](Algebraic/README.md) | 5 | 2,887 | Quotient algebra, ultrafilter/MCS correspondence, flow-frame countermodel engine |
| [`Bundle/`](Bundle/README.md) | 15 | 6,106 | Canonical frame from bundled families of MCSs |
| [`BXCanonical/`](BXCanonical/README.md) | 28 | 23,256 | Chronicle completeness route; the wired entry point |
| [`Core/`](Core/README.md) | 4 | 2,050 | MCS machinery shared by all three routes |
| [`Decidability/`](Decidability/README.md) | 62 | 52,132 | Tableau decision procedure and countermodel extraction |
| `Independence/` | 3 | 1,097 | Axiom-independence models |
| [`SoundnessLemmas/`](SoundnessLemmas/README.md) | 5 | 3,016 | Per-axiom validity lemmas feeding `Soundness.lean` |
| [`WeakCanonical/`](WeakCanonical/README.md) | 179 | 132,177 | Kamp/Reynolds route, including all of `Kamp/` |

The eight directories total 314 files, matching C7's `Metalogic 314` rollup.

### Inside `BXCanonical/`

Eight loose modules: `CanonicalChain.lean`, `CanonicalModel.lean`, `Completeness.lean`,
`CompletenessDedekind.lean`, `DiscreteCarrierProbe.lean`, `Frame.lean`,
`OrderedSeedConsistency.lean`, `TruthLemma.lean`.
Subdirectories: `Chronicle/` (14 files), `Quasimodel/` (5), `Filtration/` (1).

### Inside `WeakCanonical/`, and the `Kamp/` subtree

`WeakCanonical/` holds 19 loose modules plus **eight** subdirectories. One of them
dominates everything else in the repository:

| Subdirectory | Files | Lines |
|--------------|------:|------:|
| `Kamp/` | 116 | 77,619 |
| `EFGames/` | 8 | 11,872 |
| `Expressiveness/` | 5 | 9,503 |
| `DenseModelSurgery/` | 9 | 7,568 |
| `RealModel/` | 7 | 6,643 |
| `IntegerModel/` | 6 | 5,700 |
| `GroupModel/` | 6 | 3,357 |
| `Separation/` | 3 | 926 |

`GroupModel/` is where `theorem countermodel_discrete` — the Base-frame discrete branch of
`completeness` — is proved, in `WeakCanonical/GroupModel/CountermodelBase.lean`. See
[Sorry Status](#sorry-status).

`Kamp/` is the Kamp/Reynolds separation machinery: 57 loose modules plus **three** large
sub-subtrees. It no longer carries a local `Boneyard/`; its archived work is in
[`FormalSystem/Boneyard/Kamp/`](../Boneyard/Kamp/README.md).

| Under `Kamp/` | Files | Lines |
|---------------|------:|------:|
| `NfMultiAnchorBridge/` | 47 | 41,345 |
| `EANegationFix/` | 7 | 3,227 |
| `EANegationFixFaithful/` | 5 | 2,661 |

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

These four are the repository's axiom-set invariant. Their `#print axioms` results are
asserted by check **C2** of `scripts/check-module-invariants.sh`, which holds the baseline and
compiles a scratch file against the built library to compare against it. Run that script for the
current sets rather than reading them here — a set re-typed into this README is a set that will
drift, and this block previously did drift. C2 is the authority; the script is cited by path and
check name, deliberately without a line number.

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

The live tree carries **zero** structural `sorry`s. Check **C3** of
`scripts/check-module-invariants.sh` asserts the structural sorry inventory is ZERO across
`FormalSystem/`, with `Boneyard/` excluded, and it currently passes.

`theorem countermodel_discrete` — the Base-frame discrete branch of `completeness` — is the
former sole live sorry. It is now proved, at `WeakCanonical/GroupModel/CountermodelBase.lean`,
on the non-Archimedean discrete carrier `ℚ ×ₗ ℤ` off `companionChronicle`, and it is SORRY-FREE
(sorryAx-free; axioms: exactly `propext`, `Classical.choice`, `Quot.sound`). It no longer lives
in `WeakCanonical/Transfer.lean`; that file now documents the move near the top of its module
docstring. The `sorry` occurrences still greppable in `Transfer.lean` are all inside prose
describing sorry-*freeness* — they are not structural sorries.

The separate theorem `completeness_discrete` calls remains
`countermodel_discrete_reynolds_v2` in `WeakCanonical/IntegerModel/ReynoldsBridge.lean`, which
is also `sorryAx`-free. Do not conflate the two: `countermodel_discrete` is `completeness`'s
branch, `countermodel_discrete_reynolds_v2` is `completeness_discrete`'s.

Should a structural sorry ever reappear, locate it **by content** — the enclosing theorem name —
never by line number. The invariant check does exactly that, so the assertion survives edits above
it in the file.

Sorries inside the archive are archived dead ends, not open obligations.

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

---

*Last verified: 2026-08-26*
