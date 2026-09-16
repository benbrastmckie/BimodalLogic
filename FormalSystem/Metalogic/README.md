# TM Bimodal Logic Metalogic

Soundness, completeness, and decidability for the bimodal logic TM, combining S5
modality with linear temporal logic.

This directory is the largest thing in the repository, and `WeakCanonical/` alone is the
largest thing in it. Every file and line count on this page is generated from the tree by
`bash scripts/check-module-invariants.sh --emit-inventory` — the
[Directory Inventory](#directory-inventory) is the rollup, and no number is restated in prose.
Every count excludes the archive — see [Counting Live Files](#counting-live-files).

## Counting Live Files

Archived code lives in exactly one place, [`FormalSystem/Boneyard/`](../Boneyard/README.md),
which is also the single place its counts are stated — this page does not restate them. Check B0
asserts the archive-directory count is exactly 1 and every traversal excludes it by directory
**name**, not by path prefix; [ADR-005](../../docs/architecture/ADR-005-Single-Boneyard.md)
records why. Use the invariant script rather than an ad-hoc `find`:

```bash
bash scripts/check-module-invariants.sh              # C7 prints the live inventory
bash scripts/check-module-invariants.sh --no-build   # structural checks only, no build
```

## The Three Completeness Routes

This is the central organizing question of the directory: there are **three**
distinct routes to completeness, and they are siblings rather than layers.

| Route | Directory | Approach |
|-------|-----------|----------|
| Chronicle | `BXCanonical/` | Chronicle construction over a canonical chain; carries the flagship theorems |
| Kamp/Reynolds | `WeakCanonical/` | Reflexive canonical model, separation, and the Kamp/Reynolds machinery |
| Algebraic | `Algebraic/` | Lindenbaum–Tarski quotient algebra, the ultrafilter/MCS correspondence, and the flow-frame countermodel engine |
| Independence (support) | `Independence/` | Axiom-independence models; not a completeness route, listed here so the inventory is exhaustive |

Sizes for these four directories are in the [Directory Inventory](#directory-inventory), which
is generated; they are deliberately not restated here.

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
                 Core/
                   ▲
                   │ 9 import lines, one way only
                   │
                Bundle/
                   ▲
        ┌──────────┼──────────┐
        │          │          │
   Algebraic/  BXCanonical/  WeakCanonical/
                   ▲   │
                   │   ▼
              (mutual — see below)

   arrows point from importer to imported
```

## Why There Is No Physical Regroup

The three completeness routes are **not** nested under a `Completeness/` parent, and none is
nested inside another. There is exactly one directory-level cycle in `Metalogic/`
(`BXCanonical` <-> `WeakCanonical`), and directory structure cannot express a mutual dependency.
The decision, the edge-by-edge cycle enumeration and the costing that declined the regroup are in
[ADR-006](../../docs/architecture/ADR-006-Metalogic-No-Physical-Regroup.md). Regenerate the edge
list with `bash scripts/check-metalogic-cycles.sh`, which also asserts the cycle count is 1.

## Aggregator Convention

Every subdirectory has exactly one **sibling** aggregator: `X.lean` sits *beside*
`X/`, never inside it as `X/X.lean`.

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic rows=loose filter=aggregators -->
| Aggregator | Lines | Aggregates |
|------------|------:|-----------|
| `Algebraic.lean` | 40 | `Algebraic/` |
| `BXCanonical.lean` | 43 | `BXCanonical/` |
| `Bundle.lean` | 47 | `Bundle/` |
| `Conservativity.lean` | 375 | `Conservativity/` |
| `Core.lean` | 37 | `Core/` |
| `Decidability.lean` | 168 | `Decidability/` |
| `Deterministic.lean` | 25 | <!-- TODO: add description --> |
| `Independence.lean` | 96 | `Independence/` |
| `SoundnessLemmas.lean` | 35 | `SoundnessLemmas/` |
| `WeakCanonical.lean` | 144 | `WeakCanonical/` |
<!-- END GENERATED -->

The remaining loose files in `Metalogic/` are not aggregators — they have no same-named
sibling directory. The list is generated, so a file that moves out (four of them moved into
`Conservativity/`) leaves it automatically:

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic rows=loose filter=non-aggregators -->
| Loose non-aggregator | Lines | Role |
|----------------------|------:|------|
| `Conservativity.lean` | 375 | Conservativity of the extension |
| `Compactness.lean` | 232 | Compactness and strong completeness for Base and Dense, by ultraproduct model existence |
| `DedekindNonCompactness.lean` | 535 | Non-compactness of the Dedekind frame class — the `{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤}` witness, finitely satisfiable over `ℝ` and unsatisfiable over every Dedekind-complete carrier, refuting `CompactDedekind` and `StrongCompletenessDedekind` |
| `DiscreteNonCompactness.lean` | 329 | Non-compactness of the discrete frame class |
| `SetConsequence.lean` | 615 | Set-indexed consequence relation, and the `FrameClass`-indexed satisfiability / model-existence / compactness / strong-completeness family, instantiated at all four class tags including the `.Dedekind` row (`CompactDedekind`, `StrongCompletenessDedekind`, `SatisfiableDedekindSet`, `ModelExistenceDedekind`) |
| `Soundness.lean` | 1,656 | The soundness theorem itself |
| `StrongCompleteness.lean` | 1,147 | Strong/consequence completeness, including `completeness_dedekind`, and the two `FrameClass`-generic compactness reductions `strongCompleteness_of_compact` and `compact_of_modelExistence` |
<!-- END GENERATED -->

Plus the directory's own root `Metalogic.lean`, which sits one level up, beside `Metalogic/`;
its size is a row in [`FormalSystem/README.md`](../README.md)'s generated root-module table.

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
`lean_lib FormalSystem` sets `srcDir := "."` and ``roots := #[`FormalSystem]`` (`lakefile.lean`),
so module `FormalSystem` resolves to the **repository-root** `FormalSystem.lean`, which
in turn imports module `FormalSystem.FormalSystem` — the file `FormalSystem/FormalSystem.lean`.
Both are rows in [`FormalSystem/README.md`](../README.md)'s generated root-module table.
That self-named indirection is load-bearing, not a convention violation. The
invariant check allowlists it by name (check C8; the allowlist entry is the inner file).

## Directory Inventory

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic rows=subdirs cols=files-lines link=yes -->
| Directory | Files | Lines | Role |
|-----------|------:|------:|------|
| [`Algebraic/`](Algebraic/README.md) | 5 | 2,448 | Quotient algebra, ultrafilter/MCS correspondence, flow-frame countermodel engine |
| [`BXCanonical/`](BXCanonical/README.md) | 28 | 23,160 | Chronicle completeness route; the wired entry point |
| [`Bundle/`](Bundle/README.md) | 9 | 2,856 | Bundled families of MCSs and their coherence conditions |
| [`Conservativity/`](Conservativity/README.md) | 21 | 5,976 | Conservativity of TM over the base language L⁻: the translation, the backward direction, and the CEB/CEF/CED/CEC status record |
| [`Core/`](Core/README.md) | 4 | 1,838 | MCS machinery shared by all three routes |
| [`Decidability/`](Decidability/README.md) | 80 | 53,408 | Tableau decision procedure and countermodel extraction |
| [`Deterministic/`](Deterministic/README.md) | 7 | 1,621 | The deterministic metatheory of TM⁺: validity narrowed to `TaskFrame.Deterministic`, the narrowed completeness engines, the `⊡`-erasure, the extended system TM⁺ + *Determined*, and its soundness and completeness |
| [`Independence/`](Independence/README.md) | 18 | 5,086 | Axiom-independence models |
| [`SoundnessLemmas/`](SoundnessLemmas/README.md) | 4 | 1,456 | Per-axiom validity lemmas feeding `Soundness.lean` |
| [`WeakCanonical/`](WeakCanonical/README.md) | 179 | 132,163 | Kamp/Reynolds route, including all of `Kamp/` |
<!-- END GENERATED -->

C7's `Metalogic` rollup is larger than the sum of the table above, because it also counts the
loose modules sitting directly in `Metalogic/` — the sibling aggregators plus `Soundness.lean`,
`Compactness.lean`, `StrongCompleteness.lean` and the rest, both listed above. Run
`bash scripts/check-module-invariants.sh --no-build` for the rollup; it is not restated here.

### Inside `BXCanonical/`

Loose modules:

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/BXCanonical rows=loose desc=no -->
| Module | Lines |
|--------|------:|
| `CanonicalChain.lean` | 115 |
| `CanonicalModel.lean` | 846 |
| `Completeness.lean` | 462 |
| `CompletenessDedekind.lean` | 619 |
| `DiscreteCarrierProbe.lean` | 96 |
| `Frame.lean` | 718 |
| `OrderedSeedConsistency.lean` | 257 |
| `TruthLemma.lean` | 298 |
<!-- END GENERATED -->

Subdirectories:

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/BXCanonical rows=subdirs cols=files-lines desc=no sort=lines-desc -->
| Subdirectory | Files | Lines |
|--------------|------:|------:|
| `Chronicle/` | 14 | 17,930 |
| `Quasimodel/` | 5 | 1,685 |
| `Filtration/` | 1 | 134 |
<!-- END GENERATED -->

### Inside `WeakCanonical/`, and the `Kamp/` subtree

`WeakCanonical/` holds its loose modules plus the subdirectories below. One of them
dominates everything else in the repository:

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/WeakCanonical rows=subdirs cols=files-lines desc=no sort=lines-desc -->
| Subdirectory | Files | Lines |
|--------------|------:|------:|
| `Kamp/` | 116 | 77,626 |
| `EFGames/` | 8 | 11,872 |
| `Expressiveness/` | 5 | 9,501 |
| `DenseModelSurgery/` | 9 | 7,571 |
| `RealModel/` | 7 | 6,650 |
| `IntegerModel/` | 6 | 5,682 |
| `GroupModel/` | 6 | 3,365 |
| `Separation/` | 3 | 926 |
<!-- END GENERATED -->

`GroupModel/` is where `theorem countermodel_discrete` — the Base-frame discrete branch of
`completeness` — is proved, in `WeakCanonical/GroupModel/CountermodelBase.lean`. See
[Sorry Status](#sorry-status).

`Kamp/` is the Kamp/Reynolds separation machinery: a large body of loose modules plus the
sub-subtrees below. It no longer carries a local `Boneyard/`; its archived work is in
[`FormalSystem/Boneyard/Kamp/`](../Boneyard/Kamp/README.md).

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/WeakCanonical/Kamp rows=subdirs cols=files-lines desc=no sort=lines-desc -->
| Under `Kamp/` | Files | Lines |
|---------------|------:|------:|
| `NfMultiAnchorBridge/` | 47 | 41,345 |
| `EANegationFix/` | 7 | 3,227 |
| `EANegationFixFaithful/` | 5 | 2,661 |
<!-- END GENERATED -->

`Kamp/` alone is larger than every other directory in `Metalogic/` combined. Any
description of this repository's shape that omits it is wrong about the repository.

## Main Results

Per-theorem status — statement, Lean name, file, frame class and machine-pinned axiom set — is
in [`docs/theorem-index.md`](../../docs/theorem-index.md), the repository's single ledger. What
follows is orientation, not a second ledger.

### Soundness — `Soundness.lean`

Every derivable formula is valid on the corresponding frame class. The per-axiom
validity lemmas live in `SoundnessLemmas/`, so `Soundness.lean` assembles them
rather than restating them.

Time-shift homogeneity is consumed by one schema of the TM block — MF — across two declarations,
`modal_future_valid` here and `mf_swap_valid` in `SoundnessLemmas/FrameClassVariants.lean`; the
`Soundness.lean` module docstring's *The time-shift consumer set* section is the authority on
that enumeration and on what it costs a language extension.

### Completeness — `BXCanonical/Completeness.lean`

- `completeness` — the general Base-frame result
- `completeness_dense` — dense frame class
- `completeness_ztime` — the ℤ-time frame class
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

### The TM⁺ metatheory rows — `Conservativity/Plus/`, `Deterministic/`, `Independence/`

TM⁺ is L plus the stability modal `⊡` (`FormalSystem/Syntax/PlusLanguage/`). Its metatheory splits into
what is landed and what is open, and the split is load-bearing enough to record here:

| Row | Status |
|-----|--------|
| soundness at all four classes | **landed** — `Conservativity/Plus/PlusSoundness.lean` |
| conservativity over TM, both directions, all four classes | **landed** — `Conservativity/Plus/Forward.lean` |
| completeness of TM⁺ + *Determined* over the **deterministic** frames, all four classes | **landed** — `Deterministic/Completeness.lean` |
| the logic of the deterministic frames coincides with the logic of the *Determined*-valid frames | **landed** — `Deterministic/Completeness.lean` |
| `⊡` is not definable in L | **landed** — `Independence/StabUndefinable.lean` |
| the two pasting schemata are not derivable from the naive `⊡`-set | **landed** — `Independence/PastingIndependence.lean` |
| **general (nondeterministic) TM⁺ completeness, at any class** | **OPEN** |
| **TM⁺ decidability** | **OPEN** |

The two open rows are stated nowhere in the tree and are never discharged with `sorry`. The
nearest results in the literature are Reynolds (2003) on until/since completeness over the reals
and Zanardo (1991) on branching-time logics under an Ockhamist reading; neither settles the
all-histories semantics used here.

The deterministic row is an **axiomatization, not a characterization**. *Determined* (`φ → ⊡φ`)
is valid on a class strictly larger than the deterministic frames, and no L⁺ formula set defines
the deterministic frames at all (`Independence/DeterminismUndefinable.lean`). What holds — and is
what a paper can use — is that the two classes have the same logic.

### The TM⋆ metatheory rows — `Conservativity/Star/`

TM⋆ is L⁺ plus the manuscript's time registers `↑ⁱ`/`↓ⁱ` (`FormalSystem/Syntax/StarLanguage/`). Its
axiom set re-declares the TM⁺ schemata directly over `StarFormula` rather than embedding them,
with `modal_future` alone under a `RecallFree` (`↓ⁱ`-free) side condition — it is *refuted* at
arbitrary `φ` (`Semantics/StarNonValidities.lean`, `refute_modal_future`).

| Row | Status |
|-----|--------|
| soundness at all four classes | **landed** — `Conservativity/Star/StarSoundness.lean` |
| consistency at `.Base` | **landed** — `Conservativity/Star/StarSoundness.lean` |
| every TM⁺ theorem is a TM⋆ theorem at its embedding | **landed** — `StarLanguage/Embedding.lean` |
| conservativity over **TM**, both directions, all four classes | **landed** — `Conservativity/Star/Forward.lean` |
| conservativity over **TM⁺** | **CONDITIONAL** on general TM⁺ completeness, with an unconditional contrapositive — `Conservativity/Star/Forward.lean` |
| **TM⋆ completeness, at any class** | **OPEN** |

The TM⋆ conservativity split is not an asymmetry of effort. Over TM the composition ends in a TM
completeness engine and there are four of them; over TM⁺ it ends in a TM⁺ engine and there are
none. Given TM⋆ soundness, a separating witness for non-conservativity over TM⁺ *is* a witness of
TM⁺ incompleteness (`plusIncomplete_of_starNonconservative`), so that row cannot be settled
either way without settling the open row above it.

The TM⋆ completeness row is stated nowhere in the tree and is never discharged with `sorry`. Two
obstructions are recorded in `Conservativity/Star/README.md`: the four TM engines build
*deterministic* countermodels and every deterministic frame validates `sent:det`, which is not
`StarValid` — and, unlike the L⁺ case, narrowing to the deterministic class is no escape, because
the registers do not collapse there; and the standard hybrid pure-axiom/PASTE completeness route
needs nominals, which L⋆ has none of.

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

The separate theorem `completeness_ztime` calls remains
`countermodel_discrete_reynolds_v2` in `WeakCanonical/IntegerModel/ReynoldsBridge.lean`, which
is also `sorryAx`-free. Do not conflate the two: `countermodel_discrete` is `completeness`'s
branch, `countermodel_discrete_reynolds_v2` is `completeness_ztime`'s.

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
`FormalSystem.Metalogic.Decidability.*`. The decision procedure reuses the proof-search
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

*Last verified: 2026-09-08*
