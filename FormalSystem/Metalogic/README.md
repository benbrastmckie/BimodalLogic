# TM Bimodal Logic Metalogic

Soundness, completeness, and decidability for the bimodal logic TM, combining S5
modality with linear temporal logic.

This directory is the largest thing in the repository, and `Expressiveness/` alone is the
largest thing in it. Every file and line count on this page is generated from the tree by
`bash scripts/check-module-invariants.sh --emit-inventory` — the
[Directory Inventory](#directory-inventory) is the rollup, and no number is restated in prose.
Every count excludes the archive — see [Counting Live Files](#counting-live-files).

## Counting Live Files

Archived code lives in exactly one place, [`Boneyard/`](../../Boneyard/README.md),
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
| Kamp/Reynolds | `WeakCanonical/` | Reflexive canonical model, chronicle extraction and transfer, and the integer/real/group model constructions |
| Algebraic | `Algebraic/` | Lindenbaum–Tarski quotient algebra, the ultrafilter/MCS correspondence, and the flow-frame countermodel engine |
| Independence (support) | `Independence/` | Axiom-independence models; not a completeness route, listed here so the inventory is exhaustive |
| Expressiveness (support) | `Expressiveness/` | Kamp/Stavi expressive completeness — monadic FO, EF games, normal forms, separation. Not a completeness route either: it answers which first-order properties a temporal formula can define. It was extracted from `WeakCanonical/` by [ADR-011](../../docs/architecture/ADR-011-Extract-Expressiveness.md) and imports nothing from `WeakCanonical/` or `BXCanonical/` |

Sizes for these four directories are in the [Directory Inventory](#directory-inventory), which
is generated; they are deliberately not restated here.

**`BXCanonical` is the wired entry point.** The flagship results — `completeness`,
`completeness_dense` and `completeness_discrete` (`BXCanonical/Completeness.lean`),
and `countermodel_dense` (`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`)
— live on this route.

The other two are **not** dead alternatives. `BXCanonical` imports from both of them,
so all three participate in the live proof:

- `BXCanonical → WeakCanonical` — 5 import lines
- `BXCanonical → Expressiveness` — 4 import lines
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
| `Conservativity.lean` | 411 | `Conservativity/` |
| `ConvexConsequence.lean` | 44 | Aggregator for the metatheory of the convex-index consequence relations C3 and C4; holds no declarations |
| `Core.lean` | 40 | `Core/` |
| `Decidability.lean` | 167 | `Decidability/` |
| `Deterministic.lean` | 30 | <!-- TODO: add description --> |
| `Expressiveness.lean` | 77 | `Expressiveness/` |
| `Independence.lean` | 122 | `Independence/` |
| `SoundnessLemmas.lean` | 35 | `SoundnessLemmas/` |
| `WeakCanonical.lean` | 131 | `WeakCanonical/` |
<!-- END GENERATED -->

The remaining loose files in `Metalogic/` are not aggregators — they have no same-named
sibling directory. The list is generated, so a file that moves out (four of them moved into
`Conservativity/`) leaves it automatically:

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic rows=loose filter=non-aggregators -->
| Loose non-aggregator | Lines | Role |
|----------------------|------:|------|
| `Conservativity.lean` | 411 | Conservativity of the extension |
| `Compactness.lean` | 229 | Compactness and strong completeness for Base and Dense, by ultraproduct model existence |
| `DedekindNonCompactness.lean` | 532 | Non-compactness of the Dedekind frame class — the `{G(⊤ S ¬q), F(G ¬q)} ∪ {Xqⁿ⊤}` witness, finitely satisfiable over `ℝ` and unsatisfiable over every Dedekind-complete carrier, refuting `CompactDedekind` and `StrongCompletenessDedekind` |
| `DiscreteNonCompactness.lean` | 322 | Non-compactness of the discrete frame class |
| `QTime.lean` | 59 | ℚ-time validity equals dense validity: `validQTime_iff_validDense`, from ℚ-time completeness and dense soundness |
| `SetConsequence.lean` | 588 | Set-indexed consequence relation, and the `FrameClass`-indexed satisfiability / model-existence / compactness / strong-completeness family, instantiated at all four class tags including the `.Dedekind` row (`CompactDedekind`, `StrongCompletenessDedekind`, `SatisfiableDedekindSet`, `ModelExistenceDedekind`) |
| `Soundness.lean` | 1,654 | The soundness theorem itself |
| `StrongCompleteness.lean` | 1,142 | Strong/consequence completeness, including `completeness_dedekind`, and the two `FrameClass`-generic compactness reductions `strongCompleteness_of_compact` and `compact_of_modelExistence` |
<!-- END GENERATED -->

Plus the directory's own root `Metalogic.lean`, which sits one level up, beside `Metalogic/`;
its size is a row in [`FormalSystem/README.md`](../README.md)'s generated root-module table.

Two rules keep this safe:

1. **Aggregators import concrete leaf modules only**, and no file imports an
   aggregator whose own contents already reach that file — *that* is the shape a
   genuine module-level cycle takes. Importing an aggregator per se is fine and
   routine: `Metalogic.lean` already imports `Decidability`, `Independence`,
   `BXCanonical`, `WeakCanonical` and `Algebraic`.
2. `Core.lean`, `Bundle.lean` and `SoundnessLemmas.lean` have exactly one importer: the
   generated library root `FormalSystem.lean`, which imports every module under
   `FormalSystem/`. No *content* module imports them, which is what rule 1 needs, and
   `lake build` compiles them through the root, so an importer-less aggregator cannot
   rot unnoticed and none needs an entry in `scripts/module-invariants-manifest.txt`.

The Lake library root is not an exception to the sibling rule: it is the single
repository-root file `FormalSystem.lean`, the sibling of the `FormalSystem/` directory.
`lean_lib FormalSystem` takes Lake's defaults `srcDir = "."` and `roots = ["FormalSystem"]` (`lakefile.toml`),
so module `FormalSystem` resolves to that file. It is generated by
`lake exe mk_all --lib FormalSystem` and imports every module under `FormalSystem/` directly;
it is a row in [`FormalSystem/README.md`](../README.md)'s generated root-module table. The
self-named inner root it once delegated to has been absorbed into it.

## Directory Inventory

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic rows=subdirs cols=files-lines link=yes -->
| Directory | Files | Lines | Role |
|-----------|------:|------:|------|
| [`Algebraic/`](Algebraic/README.md) | 5 | 2,403 | Quotient algebra, ultrafilter/MCS correspondence, flow-frame countermodel engine |
| [`BXCanonical/`](BXCanonical/README.md) | 28 | 23,158 | Chronicle completeness route; the wired entry point |
| [`Bundle/`](Bundle/README.md) | 9 | 2,863 | Bundled families of MCSs and their coherence conditions |
| [`Conservativity/`](Conservativity/README.md) | 23 | 6,361 | Conservativity of TM over the base language L⁻: the translation, the backward direction, and the CEB/CEF/CED/CEC status record |
| [`ConvexConsequence/`](ConvexConsequence/README.md) | 6 | 1,405 | The metatheory of the convex-index consequence relations C3 and C4 of `Semantics/ConvexTruth.lean`: the separations from C1 and from each other, and the axiom-survival table as one theorem per row |
| [`Core/`](Core/README.md) | 3 | 1,345 | MCS machinery shared by all three routes |
| [`Decidability/`](Decidability/README.md) | 79 | 51,952 | Tableau decision procedure and countermodel extraction |
| [`Deterministic/`](Deterministic/README.md) | 8 | 1,747 | The deterministic metatheory of TM⁺: validity narrowed to `TaskFrame.Deterministic`, the narrowed completeness engines, the `⊡`-erasure, the extended system TM⁺ + *Determined*, and its soundness and completeness |
| [`Expressiveness/`](Expressiveness/README.md) | 143 | 104,211 | Kamp/Stavi expressive completeness: monadic FO, EF games, normal forms, separation |
| [`Independence/`](Independence/README.md) | 23 | 6,106 | Axiom-independence models |
| [`SoundnessLemmas/`](SoundnessLemmas/README.md) | 4 | 1,434 | Per-axiom validity lemmas feeding `Soundness.lean` |
| [`WeakCanonical/`](WeakCanonical/README.md) | 38 | 28,537 | Kamp/Reynolds route, including all of `Kamp/` |
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
| `CanonicalChain.lean` | 116 |
| `CanonicalModel.lean` | 844 |
| `Completeness.lean` | 499 |
| `CompletenessDedekind.lean` | 618 |
| `DiscreteCarrierProbe.lean` | 96 |
| `Frame.lean` | 720 |
| `OrderedSeedConsistency.lean` | 257 |
| `TruthLemma.lean` | 294 |
<!-- END GENERATED -->

Subdirectories:

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/BXCanonical rows=subdirs cols=files-lines desc=no sort=lines-desc -->
| Subdirectory | Files | Lines |
|--------------|------:|------:|
| `Chronicle/` | 14 | 17,913 |
| `Quasimodel/` | 5 | 1,681 |
| `Filtration/` | 1 | 120 |
<!-- END GENERATED -->

### Inside `WeakCanonical/`, and the `Kamp/` subtree

`WeakCanonical/` holds its loose modules plus the subdirectories below. One of them
dominates everything else in the repository:

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/WeakCanonical rows=subdirs cols=files-lines desc=no sort=lines-desc -->
| Subdirectory | Files | Lines |
|--------------|------:|------:|
| `DenseModelSurgery/` | 9 | 7,935 |
| `RealModel/` | 7 | 6,790 |
| `IntegerModel/` | 6 | 5,616 |
| `GroupModel/` | 6 | 3,379 |
<!-- END GENERATED -->

`GroupModel/` is where `theorem countermodel_discrete` — the Base-frame discrete branch of
`completeness` — is proved, in `WeakCanonical/GroupModel/CountermodelBase.lean`. See
[Sorry Status](#sorry-status).

`Kamp/` is the Kamp/Reynolds separation machinery: a large body of loose modules plus the
sub-subtrees below. It no longer carries a local `Boneyard/`; its archived work is in
[`Boneyard/Kamp/`](../../Boneyard/Kamp/README.md).

<!-- BEGIN GENERATED: inventory dir=FormalSystem/Metalogic/Expressiveness/Kamp rows=subdirs cols=files-lines desc=no sort=lines-desc -->
| Under `Kamp/` | Files | Lines |
|---------------|------:|------:|
| `NfMultiAnchorBridge/` | 47 | 41,403 |
| `EANegationFix/` | 7 | 3,231 |
| `EANegationFixFaithful/` | 5 | 2,664 |
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
`modal_future_valid` here and `mf_reflect_time_valid` in `SoundnessLemmas/FrameClassVariants.lean`;
the `Soundness.lean` module docstring's *The time-shift consumer set* section is the authority on
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

TM⁺ is L plus the stability modal `⊡` (`FormalSystem/PlusLanguage/`). Its metatheory splits into
what is landed and what is open, and the split is load-bearing enough to record here:

| Row | Status |
|-----|--------|
| soundness at all four classes | **landed** — `Conservativity/Plus/PlusSoundness.lean` |
| conservativity over TM, both directions, all four classes | **landed** — `Conservativity/Plus/Forward.lean` |
| completeness of TM⁺ + *Determined* over the **deterministic** frames, all four classes | **landed** — `Deterministic/Completeness.lean` |
| the logic of the deterministic frames coincides with the logic of the *Determined*-valid frames | **landed** — `Deterministic/Completeness.lean` |
| the logic of the deterministic frames coincides with the logic of all task frames (for L, at every class) | **landed** — `Deterministic/SameLogic.lean` |
| `⊡` is not definable in L | **landed** — `Independence/StabUndefinable.lean` |
| the two pasting schemata are not derivable from the naive `⊡`-set | **landed** — `Independence/PastingIndependence.lean` |
| **completeness of the current TM⁺ axiom set at `.Base`** | **FALSE** — `Independence/PlusIncompleteness.lean`, `plus_incomplete_base` |
| **completeness of any extension of the TM⁺ axiom set, at any class** | **OPEN** |
| **TM⁺ decidability** | **OPEN** |

The FALSE row is a theorem: the limit-closure formula `(⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))`
is valid over every task frame (`PlusLanguage/PlusLimitClosure.lean`) and is refuted in a
paste-closed coarsened-state model for which TM⁺ is sound
(`Independence/PastedCoarseModels.lean`, `Independence/LimitClosureCountermodel.lean`). The
one-line reading: the coarsened countermodel is a dense, non-closed bundle — PS and US say
paste-closed, MF says translation-closed, nothing says closed. It concerns the axiom set as it
stands, at `.Base`, and says nothing about any extension or any other class.

The two open rows are stated nowhere in the tree and are never discharged with `sorry`. The
nearest results in the literature are Reynolds (2003) on until/since completeness over the reals
and Zanardo (1991) on branching-time logics under an Ockhamist reading; neither settles the
all-histories semantics used here.

The deterministic row is an **axiomatization, not a characterization**. *Determined* (`φ → ⊡φ`)
is valid on a class strictly larger than the deterministic frames, and no L⁺ formula set defines
the deterministic frames at all (`Independence/DeterminismUndefinable.lean`). What holds — and is
what a paper can use — is that the two classes have the same logic.

### The TM⋆ metatheory rows — `Conservativity/Star/`

TM⋆ is L⁺ plus the manuscript's time registers `↑ⁱ`/`↓ⁱ` (`FormalSystem/StarLanguage/`). Its
axiom set re-declares the TM⁺ schemata directly over `StarFormula` rather than embedding them,
with `modal_future` alone under a `RecallFree` (`↓ⁱ`-free) side condition — it is *refuted* at
arbitrary `φ` (`StarLanguage/StarNonValidities.lean`, `refute_modal_future`).

| Row | Status |
|-----|--------|
| soundness at all four classes | **landed** — `Conservativity/Star/StarSoundness.lean` |
| consistency at `.Base` | **landed** — `Conservativity/Star/StarSoundness.lean` |
| every TM⁺ theorem is a TM⋆ theorem at its embedding | **landed** — `StarLanguage/Embedding.lean` |
| conservativity over **TM**, both directions, all four classes | **landed** — `Conservativity/Star/Forward.lean` |
| conservativity over **TM⁺** | **CONDITIONAL** on general TM⁺ completeness, with an unconditional contrapositive — `Conservativity/Star/Forward.lean`. The hypothesis is **REFUTED at `.Base`** (`Independence/PlusIncompleteness.lean`, `not_plus_complete_base`), so the conditional is vacuous there and conservativity at `.Base` is undecided by this route; at the other three classes the hypothesis is open |
| **TM⋆ completeness, at any class** | **OPEN** |

The TM⋆ conservativity split is not an asymmetry of effort. Over TM the composition ends in a TM
completeness engine and there are four of them; over TM⁺ it ends in a TM⁺ engine and there are
none. Given TM⋆ soundness, a separating witness for non-conservativity over TM⁺ *is* a witness of
TM⁺ incompleteness (`plusIncomplete_of_starNonconservative`). The converse fails to help:
TM⁺ *is* incomplete at `.Base`, and that refutes the conditional's hypothesis without producing a
separating witness, so conservativity of TM⋆ over TM⁺ at `.Base` remains undecided.

The TM⋆ completeness row is stated nowhere in the tree and is never discharged with `sorry`. Two
obstructions are recorded in `Conservativity/Star/README.md`: the four TM engines build
*deterministic* countermodels and every deterministic frame validates `sent:det`, which is not
`StarValid` — and, unlike the L⁺ case, narrowing to the deterministic class is no escape, because
the registers do not collapse there; and the standard hybrid pure-axiom/PASTE completeness route
needs nominals, which L⋆ has none of.

### The convex-index consequence relations — `ConvexConsequence/`

The paper's footnoted alternative to `def:logical-consequence` — evaluate at a convex history
`τ` and a time in `dom τ`, box over the convex histories through that time, tenses restricted to
`dom τ` — is defined beside the library's own truth relation in `Semantics/ConvexTruth.lean` as
C3, with C4 its restriction to closed bounded interval indices. `ConvexConsequence/` determines
what they validate. Nothing here touches C1, the library's own consequence relation.

- **Separations**: `F⊤` is C1-valid and refuted under C3 and C4; `F⊤ → F G⊥` is C4-valid and
  refuted under C3, so C3 ⊊ C4 (`validC3_imp_validC4`, `validC4_lastPoint`,
  `refute_C3_lastPoint`).
- **The survival table**, one theorem per row and once over all 29 constructors
  (`c3_survival_table`, `c3_failure_table`): four constructors fail — `serial_future`,
  `discrete_symm_fwd`, `discrete_propagate_fwd`, `discrete_box_necessity` — together with the two
  derived mirrors `serial_past` and `discrete_symm_bwd`. Every failure is an existence assertion
  about the temporal order. Everything else survives, including all six frame-class axioms on
  their own classes and every other past mirror.
- **The germ theorem**: under the primary box range every boxed `U`/`S`-formula is
  unsatisfiable (`c3_box_untl_unsat`), since one-point histories are in the box's range. The
  cut-back range is the named alternative `TruthAtConvexCut`.

No completeness theorem for C3 is stated, and none of this identifies the C3 validities with a
known axiomatic system.

```lean
import FormalSystem.Metalogic.ConvexConsequence   -- c3_survival_table, c3_failure_table
```

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
Decidability/TraceExport.lean        → BimodalTools.DataExport
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

*Last verified: 2026-09-21*
