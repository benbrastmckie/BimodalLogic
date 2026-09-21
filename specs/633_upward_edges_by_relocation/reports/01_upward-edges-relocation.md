# Research Report: Task #633

**Task**: 633 - Remove the upward edges by relocation
**Started**: 2026-09-20T21:45:00Z
**Completed**: 2026-09-20T22:20:00Z
**Effort**: Medium-Large (5 phases; 4 mechanical relocations + 1 documentation/tooling phase)
**Dependencies**: 630 (archive relocation), 632 (BimodalTools split) — both landed at HEAD `b1ab4bf3a`
**Sources/Inputs**:
- Codebase (live measurement at HEAD `b1ab4bf3a`)
- `scripts/measure-refactor-partitions.py` upward-edges / namespace-audit
- `scripts/check-module-invariants.sh --no-build`, `scripts/check-metalogic-cycles.sh`,
  `scripts/readme-lint.sh`, `scripts/typst-sync-check.sh`
- lean-lsp `lean_run_code` (attribute-command availability probe)
- Literature source: `docs/development/PUBLICATION_REFACTOR.md` Phase 4 (lines 344-365)
- Predecessor decision: `specs/632_bimodaltools_split/reports/01_bimodaltools-library-split.md`

**Artifacts**:
- `specs/633_upward_edges_by_relocation/reports/01_upward-edges-relocation.md`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The task description's counts are stale; HEAD measures 70 upward import lines, 15 into
  `Automation/`.** Of those 15, exactly **11 are the attribute edges** the `Tactic/Attr.lean`
  merge deletes (Syntax 1, Semantics 1, ProofSystem 1, Theorems 8) and 4 are
  `Metalogic -> Automation`. The acceptance criterion targets exactly those 11 minus the
  Metalogic rows — i.e. all 10 non-Metalogic lines plus the 4 `Theorems -> Metalogic` lines.
- **The whole programme reduces to 7 residual upward lines, and they are all one file.** A
  simulation of every described relocation against the live import graph leaves exactly
  `Syntax/MinusLanguage/AxiomDischarge.lean -> Theorems/*` (7 lines). PUBLICATION_REFACTOR
  **Phase 5** already owns that file ("`MinusLanguage/AxiomDischarge.lean`'s imports of Theorems
  and Metalogic become ordinary downward edges"). The layer-order assertion must therefore be
  written as *"the upward set equals this recorded allowlist"*, exactly mirroring
  `check-metalogic-cycles.sh`'s existing "exactly 1 cycle" shape — never as "zero upward edges".
- **The corrected layer order is `Syntax/ProofSystem/ForMathlib/Init/Tactic (0) -> Semantics (1)
  -> Theorems (2) -> Metalogic (3) + Automation (3) -> Examples (4)`.** Two independent facts
  force the Theorems/Metalogic swap: 29 Metalogic files import `Theorems/` across 47 lines while
  only 4 Theorems files import Metalogic (all four via `DeductionTheorem`). `Automation` must sit
  *beside* Metalogic rather than beside Theorems — placing it at Theorems' layer would make
  `Theorems -> Automation` invisible to the very measurement the acceptance criterion reads, so
  one quarter of the criterion would pass by renumbering instead of by relocation.
- **`Tactic/Attr.lean` can import `Lean` alone** — verified by running `register_simp_attr` and
  `register_label_attr` under a bare `import Lean` — so `Init.lean` importing it closes no cycle.
  After the merge, **only `ForMathlib/Order/PFilter.lean` loses its transitive path to
  `FormalSystem.Init`, and that is already the recorded C24 exception**; `FormalSystem.Tactic.Attr`
  becomes the second entry in `scripts/CheckInitImportsMain.lean`'s `exceptions` list.
- **`Automation/Tactics/Meta.lean` must move with `PropDecide`, or the relocation buys nothing.**
  `PropDecide` calls `extractDerivationGoal` and `isNilContext` from `Meta.lean`; relocating
  `PropDecide` alone trades one `Metalogic -> Automation` line for another. PUBLICATION_REFACTOR
  anticipates this ("and `Tactics/Meta` if it needs it"). Recommended target: `Tactic/Meta.lean`,
  beside `Tactic/Attr.lean`.
- **The `cut ProofSearch.Core -> SuccessPatterns` item is a no-op and must be struck, not done.**
  The BimodalTools-split research decided `SuccessPatterns` stays whole in the library and
  recorded that "Phase 4's bullet is a no-op and should be corrected when Phase 4 is planned".
  Both endpoints are inside `Automation/`, so the edge is intra-directory and contributes zero
  upward lines under any layer assignment.
- **The one under-appreciated breakage is Typst, not Lean.**
  `typst/chapters/p4-proof-automation.typ` carries `#assert(roles.len() ==
  automation-module-map.len())` and a `#module-lines("Tactics/PropDecide.lean")`-shaped lookup
  that errors on a missing row. Moving `Meta.lean` and `PropDecide.lean` out of the generator's
  glob fails the chapter's compile unless the two `roles` entries and the prose path are edited
  in the same commit.

## Context & Scope

Researched: how to delete the upward edges in `FormalSystem/`'s import graph by relocation, which
layer order the tree actually measures, what a layer-order assertion can honestly assert, and
every gate, generated artifact and document that observes the moved paths.

Measured against HEAD `b1ab4bf3a` (post-630, post-632), not against the task description, per the
dispatch instruction to re-derive every count.

Out of scope (later PUBLICATION_REFACTOR phases): the `XLanguage/` merges that fix
`AxiomDischarge.lean` (Phase 5), the `Metalogic/Expressiveness/` extraction (Phase 6), and
`mk_all --check` adoption (Phase 8).

## Literature Proof Structure

**Source**: `docs/development/PUBLICATION_REFACTOR.md`, "Phase 4: Remove the upward edges by
relocation" (lines 344-365), with the Phase-3 `SuccessPatterns` decision it consumes
(line 358) and the Phase-5 hand-off for `AxiomDischarge.lean` (line 371).

**Strategy**: direct construction — relocate dependency-first, then correct the layer table and
turn the corrected order into a mechanical assertion.

### Step Map

1. Create `Tactic/Attr.lean` from the three `register_*_attr` files; import it from `Init.lean`;
   delete the 11 attribute edges — Phase 4 bullet 1.
2. Move `PropDecide` (and `Tactics/Meta`, "if it needs it" — it does) so that
   `Algebraic -> Decidability` becomes a same-directory-tree edge — Phase 4 bullet 2.
3. Move `Metalogic/Core/DeductionTheorem.lean` to `Theorems/DeductionTheorem.lean`, keeping its
   namespace as a recorded ancestor-style exception; removes the 4 `Theorems -> Metalogic` lines
   — Phase 4 bullet 3.
4. Move `Metalogic/Decidability/FMP/Periodicity.lean` to `Semantics/Periodicity.lean` — Phase 4
   bullet 4.
5. Re-document `Decidability -> ProofSearch/Normalization` as legitimate, placing library
   automation *below* Decidability; **strike** the `ProofSearch.Core -> SuccessPatterns` cut —
   Phase 4 bullet 5, as corrected by the BimodalTools-split decision.
6. Rewrite ORGANISATION.md's layer table to the measured order and extend
   `check-metalogic-cycles.sh` into a layer-order assertion — Phase 4 bullet 6.

### Dependencies

- Step 2 depends on Step 1 only for tidiness (both create/populate `Tactic/`); the `Tactic/`
  directory, its sibling aggregator and its README must exist before Step 2 lands `Tactic/Meta.lean`.
- Steps 3 and 4 are independent of Steps 1-2 and of each other.
- Step 6 depends on Steps 1-4 all having landed: the assertion it installs is false until they have.
- Step 5's `SuccessPatterns` half depends on nothing — it is a documentation correction.

### Potential Formalization Challenges

- **Step 1**: `Tactic/Attr.lean` cannot import `FormalSystem.Init` (that would be the cycle
  `Init -> Attr -> Init`), yet the three source files all do today. Resolved: the attribute
  commands come from core Lean, so `import Lean` alone suffices (verified below).
- **Step 3**: 51 fully-qualified `FormalSystem.Metalogic.Core.deductionTheorem` call sites across
  13 files depend on reaching the declaration *transitively*; several of those files never import
  `DeductionTheorem` directly. Only `lake build` can confirm the transitive paths survive.
- **Step 6**: the honest assertion is not "zero upward edges" — `AxiomDischarge.lean`'s 7 lines
  are Phase 5's work — so the assertion needs an in-script allowlist with a stated expiry.

## Findings

### Codebase Patterns

#### Live measurement at HEAD (`python3 scripts/measure-refactor-partitions.py upward-edges`)

Total upward import lines: **70**, of which **15** run into `Automation/`.

| Class | Lines | Detail |
|---|---|---|
| `Metalogic -> Theorems` | 47 | 29 distinct Metalogic files |
| `Theorems -> Automation` | 8 | all `Automation.LemmaDB` |
| `Syntax -> Theorems` | 6 | all `Syntax/MinusLanguage/AxiomDischarge.lean` |
| `Metalogic -> Automation` | 4 | `PropDecide`, `ProofSearch.Core`, `Normalization`, `ProofSearch.Strategies` |
| `ProofSystem -> Automation` | 1 | `DerivedAxioms -> LemmaDB` |
| `Semantics -> Automation` | 1 | `Truth -> TruthNormAttr` |
| `Syntax -> Automation` | 1 | `Formula -> TruthNormAttr` |
| `Semantics -> Metalogic` | 1 | `Extension/PeriodicExtension -> FMP.Periodicity` |
| `Syntax -> Metalogic` | 1 | `AxiomDischarge -> Core.DeductionTheorem` |

`Theorems <-> Metalogic`: 4 Theorems files import Metalogic (**all four import exactly
`FormalSystem.Metalogic.Core.DeductionTheorem` and nothing else**: `DedekindDerived`,
`DiscreteUnfolding`, `GeneralizedNecessitation`, `Propositional/Core`); 29 Metalogic files import
Theorems.

`docs/development/PUBLICATION_REFACTOR.md:271` records "16 lines (11 attribute-only)". The
attribute figure of 11 is still exact; the total is now **15**, one `Metalogic -> Automation`
line having left with the BimodalTools split.

#### The three attribute modules are a clean, tiny merge

| File | Lines | Imports | Content |
|---|---|---|---|
| `Automation/TruthNormAttr.lean` | 58 | `Lean`, `FormalSystem.Init` | `register_simp_attr truth_norm`, `reflect_time_norm` |
| `Automation/NormalizationAttr.lean` | 44 | `Lean`, `FormalSystem.Init` | `register_simp_attr formula_unfold`, `formula_fold` |
| `Automation/LemmaDB.lean` | 48 | `Lean`, `FormalSystem.Init` | `register_label_attr tmLemma` |

Five declarations total, zero lemmas, zero definitions. `LemmaDB.lean`'s `namespace
FormalSystem.Automation.LemmaDB` wrapper is inert — attribute and simp-set identifiers are global,
and **zero call sites anywhere reference a `LemmaDB.`-qualified name**, so the namespace can be
dropped or renamed freely.

**Verified with `lean_run_code`**: `import Lean` alone elaborates both `register_simp_attr` and
`register_label_attr` (both commands are core Lean —
`Lean/Meta/Tactic/Simp/RegisterCommand.lean` and `Lean.LabelAttribute`). The `FormalSystem.Init`
import in all three files is therefore **not load-bearing**, and `Tactic/Attr.lean` importing only
`Lean` closes no cycle with `Init.lean`.

#### C24 (`checkInitImports`) survives with one new exception

Simulating the removal of all `TruthNormAttr` / `NormalizationAttr` / `LemmaDB` import lines from
the live graph and recomputing every module's transitive closure:

```
modules that would LOSE the transitive Init path: 1
   FormalSystem.ForMathlib.Order.PFilter
```

`PFilter` is already `exceptions[1]` in `scripts/CheckInitImportsMain.lean`. Everything else keeps
a path (e.g. `Syntax/Formula.lean -> Syntax/Atom.lean -> Init`). The single required edit is
adding `FormalSystem.Tactic.Attr` to that `exceptions` list — which is precisely the
"circular-dependency exception" the script's own header says CSLib has (`Cslib.Foundations.Lint.Basic`)
and this repo does not yet. Both that header and `Init.lean`'s docstring say "the eleven minimal
elements of the internal import DAG"; the three attribute modules are three of those eleven, so
**both prose counts become eight** (plus `Tactic/Attr.lean` as the non-Init-importing ninth).

#### `PropDecide` genuinely needs `Meta.lean`

`Automation/Tactics/PropDecide.lean` (158 lines) imports
`Metalogic.Decidability.Propositional.Kalmar` and `Automation.Tactics.Meta`, and calls
`extractDerivationGoal` and `isNilContext` from the latter. `Meta.lean` (99 lines) imports
`FormalSystem.ProofSystem` + `Lean` and is also used by `Automation/Tactics/Commands.lean` and
`Automation/Tactics/Search.lean`, which stay put. Merging `Meta.lean` into the relocated
`Metalogic/.../Tactic.lean` would therefore make two Automation tactic modules import Metalogic;
relocating it to `Tactic/Meta.lean` (layer 0) keeps every consumer's edge downward.

#### `Periodicity.lean` is already a Semantics module misfiled

`Metalogic/Decidability/FMP/Periodicity.lean` (239 lines) imports only
`FormalSystem.Semantics.IntNormalForm` plus two Mathlib modules, and **already declares
`namespace FormalSystem.Semantics`**. The namespace audit lists it in the `unrelated` bucket for
exactly that reason. Moving it to `Semantics/Periodicity.lean` requires **no in-file edit at all**
and converts the row to `equal-or-descendant`. Its four importers (`FMP/FMP.lean`,
`BiLasso/GoodCycle.lean`, `Decidability/IntPresentation.lean`,
`Semantics/Extension/PeriodicExtension.lean`) need only an import-line rewrite.

Note the directory already contains `Semantics/Correspondence/FwdRecPeriodicity.lean`, so the
bare name `Semantics/Periodicity.lean` is distinguishable but worth a one-line README note.

#### `DeductionTheorem.lean`: keeping the namespace is correct, and costs one audit row

`Metalogic/Core/DeductionTheorem.lean` (472 lines) imports `ProofSystem.Derivation`,
`ProofSystem.Derivable` and `Theorems.Combinators` — all at or below the Theorems layer, so the
move creates no cycle (`Combinators` itself imports only ProofSystem, Syntax and `LemmaDB`, and
the latter edge is deleted by Step 1).

**51 fully-qualified `FormalSystem.Metalogic.Core.deductionTheorem*` references across 13 files**
justify "keeping its namespace":

| File | Refs | | File | Refs |
|---|---|---|---|---|
| `Theorems/Propositional/Core.lean` | 8 | | `Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` | 4 |
| `Metalogic/Algebraic/UltrafilterMCS.lean` | 7 | | `Metalogic/Decidability/Propositional/Kalmar.lean` | 4 |
| `Theorems/Propositional/Connectives.lean` | 7 | | `Theorems/Propositional/Reasoning.lean` | 5 |
| `Automation/Tactics/Deduction.lean` | 4 | | `Metalogic/Core/MCSProperties.lean` | 2 |
| `Metalogic/Algebraic/FlowFrame.lean` | 4 | | `Theorems/Perpetuity/Principles.lean` | 2 |
| | | | `Theorems/TemporalDerived.lean` | 2 |
| | | | `Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` | 1 |
| | | | `Tests/BimodalTest/Theorems/PropositionalTest.lean` | 1 |

Cost: the namespace audit's `unrelated` bucket gains one row (module `FormalSystem.Theorems.DeductionTheorem`,
namespace `FormalSystem.Metalogic.Core`) while losing two (`PropDecide`, `Periodicity`) — **net
24 -> 23**. The bucket is informational, never gated, and PUBLICATION_REFACTOR Phase 5's
acceptance already speaks of "the recorded exceptions", so the row must be *recorded*, not left
to be rediscovered.

#### Simulated post-move measurement

Applying every relocation to the live graph and re-measuring under four candidate layer
assignments:

| Layer assignment | Residual upward lines |
|---|---|
| **A — `Automation` at 3 (beside Metalogic)** | **7** |
| B — `Automation` at 2 (beside Theorems, below Metalogic) | 9 (7 AxiomDischarge + 2 sibling-aggregator) → 7 with the aggregator-source exclusion |
| C — order swapped, `Automation` left at 4 | 10 (7 + 3 `Metalogic -> Automation`) |
| D — today's order, post-move (control) | 61 |

The residual 7 under A and B are identical and are all one file:

```
Syntax.MinusLanguage.AxiomDischarge -> Theorems.{Combinators, DedekindDerived, DeductionTheorem,
                                                DiscreteUnfolding, GeneralizedNecessitation,
                                                Propositional.Core, TemporalDerived}
```

The 2 extra lines under B are both sourced at `FormalSystem/Automation.lean` — the sibling
aggregator of `FormalSystem/Automation/` — importing `Metalogic.WeakCanonical.EFGameTactics` and
the relocated `Metalogic.Decidability.Propositional.Tactic`. `check-metalogic-cycles.sh` already
documents and implements exactly that exclusion ("Sibling aggregators … are excluded as edge
SOURCES. An aggregator's whole job is to import its own directory's contents"). **Verified: after
`PropDecide` and `Tactics/Deduction`'s import are re-pointed, no non-aggregator file under
`Automation/` imports `Metalogic/` at all.**

#### Harness and check baseline (recorded, re-derived at HEAD)

| Check | Status at HEAD | Attributable to this task? |
|---|---|---|
| `check-module-invariants.sh --no-build` | **ALL CHECKS PASSED** (0 FAIL) | baseline — any new failure is this task's |
| `check-metalogic-cycles.sh` | **PASS** — exactly 1 cycle (`BXCanonical <-> WeakCanonical`, 9 + 5 lines) | baseline |
| `readme-lint.sh` | **FAIL** — 21 broken references, **all** `../Boneyard/` links one `../` short | **No** — pre-existing fallout of the archive relocation |
| `typst-sync-check.sh` | **FAIL** — `sorry-total: committed=4 live=0` and the `WeakCanonical/ (archived, Boneyard/Kamp/)` row; plus 9 `docs/training/PIPELINE.md:NNN` line-range violations | **No** — pre-existing |

Both red checks remain red for reasons unrelated to this task's file set. Two of readme-lint's 21
rows (`FormalSystem/Automation/README.md` and `FormalSystem/Automation/Tactics/README.md`) sit in
files this task must edit anyway; fixing the `../` depth there is a zero-cost opportunistic
improvement, but it is **not** this task's acceptance and should be labelled as such if taken.

#### Everything that observes the moved paths

| Artifact | Required change |
|---|---|
| `scripts/CheckInitImportsMain.lean` | add `FormalSystem.Tactic.Attr` to `exceptions`; "eleven minimal elements" → eight |
| `FormalSystem/Init.lean` | add `import FormalSystem.Tactic.Attr`; same "eleven" correction; the docstring's claim that "this repo has no local lint/tactic-attribute module to pin alongside `Mathlib.Init`" becomes false |
| `scripts/measure-refactor-partitions.py` | `LAYERS` renumber + `Tactic: 0`; the `into_automation` source tuple and the "five lower layers" wording; the "Measured on commit 220e94ea4" narrative |
| `scripts/check-metalogic-cycles.sh` | new layer-order assertion (see Recommendations) |
| `FormalSystem/Tactic.lean` | **new** sibling aggregator — **C8 is enforced** (`ENFORCE_C8=1`) and walks `FormalSystem/` |
| `FormalSystem/Tactic/README.md` | **new** — readme-lint Check 1 is gated: every directory with `.lean` files needs one |
| `FormalSystem/FormalSystem.lean` | add `import FormalSystem.Tactic` so the new aggregator is in the build closure (else C6 flags it as unreachable) |
| `FormalSystem/Theorems.lean` | add `import FormalSystem.Theorems.DeductionTheorem` |
| `FormalSystem/Metalogic/Core.lean` | drop the `DeductionTheorem` import (this aggregator is on the C6 manifest) |
| `FormalSystem/Semantics.lean` | optional `import FormalSystem.Semantics.Periodicity` (all four importers already reach it) |
| `FormalSystem/Automation.lean` | `Tactics.PropDecide` → `Metalogic.Decidability.Propositional.Tactic` (keeps the user-facing tactic surface intact) |
| `typst/generated/automation-module-map.typ` | **regenerate** via `scripts/typst-module-map.sh` — loses `Tactics/Meta.lean` (99) and `Tactics/PropDecide.lean` (158); total 3577 → 3320 |
| `typst/chapters/p4-proof-automation.typ` | **remove the two `roles` entries** or `#assert(roles.len() == automation-module-map.len())` fails the compile; re-path the `Tactics/PropDecide.lean` prose at line 48 |
| `scripts/typst-module-map.sh` | header documents the `Automation/{Tactics,ProofSearch}/*.lean` globs — narrate the two departures the way the chapter already narrates `EFGameTactics.lean` |
| `Tests/BimodalTest/Metalogic/PropDecideTest.lean` | import rewrite only (already under `Tests/.../Metalogic/`) |
| `Tests/BimodalTest/Automation/LemmaDBTest.lean` | **no change** — it imports `Tactics/Commands`, not `LemmaDB` |
| `ORGANISATION.md` | layer table rewrite (see Decisions) |
| `docs/ARCHITECTURE.md` | diagram + both "upward edge" sections (see Risks) |
| `docs/development/PUBLICATION_REFACTOR.md` | strike the `SuccessPatterns` cut; refresh line 271's counts |
| `docs/project-info/tactic-registry.md`, `docs/reference/tactic-reference.md`, `docs/reference/API_REFERENCE.md`, `docs/development/MODULE_ORGANIZATION.md`, `docs/development/NAMING_CONVENTION_DEVIATION.md`, `docs/project-info/FEATURE_REGISTRY.md`, `docs/project-info/implementation-status.md`, `FormalSystem/Metalogic/Algebraic/README.md`, `FormalSystem/Automation/README.md`, `FormalSystem/Automation/Tactics/README.md` | path/module citations — C5 (module-shaped paths in non-specs markdown) and C12/C13 gate these |

### External Resources

- **Mathlib/CSLib precedent for `Tactic/Attr.lean`**: `Mathlib/Init.lean` pins repository-wide
  tactic and linter material that every module inherits; CSLib's `Cslib/Init.lean` imports
  `Cslib/Foundations/Lint/Basic.lean` and records it as a circular-dependency exception in its own
  `CheckInitImports.lean`. `FormalSystem/Init.lean`'s docstring says this repo is "modeled on
  CSLib's `Cslib/Init.lean`" and explicitly notes the missing local module. This task supplies it,
  so the two files converge on the upstream shape rather than diverging from it.
- **`register_simp_attr` / `register_label_attr` are core Lean**, not Mathlib: `Lean.Meta.Tactic.Simp.RegisterCommand`
  and `Lean.LabelAttribute` (the latter confirmed via
  `.lake/packages/batteries/BatteriesTest/Internal/DummyLabelAttr.lean`, which imports
  `Lean.LabelAttribute` for exactly this command). Probe run under lean-lsp `lean_run_code`:
  `import Lean` + both commands elaborates with zero diagnostics.
- **The same-compilation-unit constraint** the three source files document at length
  (`register_simp_attr` expands to an `initialize` block, so neither the attribute nor the
  simp-set identifier is usable in the file that declares it) is *preserved and strengthened* by
  the merge: `Init.lean` is by construction upstream of every module, which C24 asserts
  mechanically.

### Recommendations

**R1 — Adopt layer assignment A.** Set `LAYERS` to:

```python
"Syntax": 0, "ProofSystem": 0, "ForMathlib": 0, "Init": 0, "Tactic": 0,
"Semantics": 1,
"Theorems": 2,
"Metalogic": 3, "Automation": 3,
"Examples": 4,
```

This is ORGANISATION.md's stated target verbatim — "Syntax / ProofSystem / ForMathlib ->
Semantics -> Theorems -> Metalogic -> Examples, **with library automation beside Metalogic**" —
and it is the only candidate that reaches the 7-line minimum *without* weakening the acceptance
criterion.

The decisive argument is R-8. `measure_upward_edges` derives `into_automation` from `edges`,
which contains only edges the layer comparison already judged upward. Under assignment B
(`Automation: 2`) `Theorems` and `Automation` share a layer, so **every `Theorems -> Automation`
line becomes invisible to the measurement** — one quarter of the acceptance criterion would then
read zero by renumbering rather than by relocation. Under A, `Theorems (2) < Automation (3)`, so
all four acceptance source directories (Syntax 0, ProofSystem 0, Semantics 1, Theorems 2) stay
strictly below Automation and the criterion remains a real assertion. The 11 attribute edges are
genuinely deleted, and the measurement genuinely sees that.

What A gives up is representing `Decidability -> {ProofSearch, Normalization}` as a strict
downward edge: under A those 3 lines are intra-layer and invisible. That is acceptable — the
Phase-4 spec's instruction for them is to "re-document [them] as a legitimate … edge", i.e. to
stop counting them as violations, and a beside-pair says exactly that. It must be said in
ORGANISATION.md prose rather than left to be inferred from the absence of a table row.

Assignment B remains defensible if the implementer additionally rewrites `into_automation` to
enumerate its five source directories independently of `LAYERS` (see R-8); without that rewrite,
B is not.

**R2 — Write the layer assertion as an allowlist equality, not a zero-check.** Extend
`scripts/check-metalogic-cycles.sh` (keeping its single-file, own-exit-code character) so that it:

1. computes the upward set over the whole library using the same `LAYERS` table, reusing
   `scripts/lib/import_graph.py` rather than the script's own regex for the new pass;
2. excludes sibling aggregators as edge sources, citing the reason already in its header (under
   assignment A this changes nothing — `FormalSystem/Automation.lean`'s two Metalogic imports are
   already intra-layer — but it keeps the new pass consistent with the cycle pass beside it, and
   it is what makes the assertion robust to a future directory joining at a lower layer);
3. asserts the set **equals** a recorded allowlist of the 7 `AxiomDischarge -> Theorems.*` lines,
   with an in-script comment naming PUBLICATION_REFACTOR Phase 5 as the work that empties it;
4. **fails on a surplus and on a shortfall alike** — a shortfall means Phase 5 landed and the
   allowlist is stale, which is a finding, exactly as the existing "zero cycles is a finding, not
   a pass" branch already argues.

Keep the existing cycle assertion intact and unchanged; the script then makes two independent
assertions with one exit code, which its header should say.

**R3 — Sequence the work dependency-first, five green commits.**

| Phase | Work | Green gate |
|---|---|---|
| 1 | `Tactic/` + `Attr.lean` + `Tactic.lean` + README; `Init.lean` import; delete 11 attribute edges; C24 exception; root aggregator import | `lake build`; harness with build; `upward-edges` shows 0 into Automation from Syntax/Semantics/ProofSystem/Theorems |
| 2 | `Tactics/Meta.lean` → `Tactic/Meta.lean`; `Tactics/PropDecide.lean` → `Metalogic/Decidability/Propositional/Tactic.lean`; regenerate the module map; fix the `roles` dict and the chapter prose | `lake build`; `typst-sync-check.sh` module-map sub-check; typst chapter compiles |
| 3 | `Metalogic/Core/DeductionTheorem.lean` → `Theorems/DeductionTheorem.lean`; aggregator edits | `lake build` (the 51 FQN sites are the risk); `upward-edges` shows 0 `Theorems -> Metalogic` |
| 4 | `Metalogic/Decidability/FMP/Periodicity.lean` → `Semantics/Periodicity.lean` | `lake build`; `namespace-audit` unrelated bucket down |
| 5 | `LAYERS` renumber; ORGANISATION.md + ARCHITECTURE.md rewrite; the new layer assertion; PUBLICATION_REFACTOR corrections | full harness; `check-metalogic-cycles.sh`; `readme-lint.sh` no *new* rows |

**R4 — Drive phases 2-4 with `scripts/move-modules.py`, but `--dry-run` first and read the prose
hunks.** The tool's `resolve_move()` fix (landed during the BimodalTools split) means
file-granular map rows now actually move their file instead of silently reporting citation
rewrites against nothing — all four moves here are file-granular, so this fix is load-bearing.
Two residual limitations apply directly to this task's documents: the tool cannot distinguish a
*current-location* citation from a *historical statement about an old location*, and it collapses
"from X to Y" prose into "from Y to Y". `docs/ARCHITECTURE.md`, `FormalSystem/Automation/README.md`
and `docs/development/PUBLICATION_REFACTOR.md` all contain exactly that historical shape, so the
dry-run diff must be read by hand before the real run. Phase 1's merge (three modules → one file,
imports *deleted* rather than rewritten) is not a mapping the tool models and should be done by
hand.

**R5 — Strike the `SuccessPatterns` cut explicitly rather than silently.** Edit
`docs/development/PUBLICATION_REFACTOR.md` line 358 to record that Phase 3 decided
`SuccessPatterns` stays whole in the library, citing the reason (pure data, two library call
sites in `ProofSearch/{Core,Strategies}`, tooling importers use only `PatternKey` /
`GoalCategory` / `goalCategory`), so the no-op is not rediscovered as an unfinished item. No Lean
file changes.

**R6 — Give `Tactic/` a README that states its constraint.** `FormalSystem/Tactic/README.md` must
say what `NormalizationAttr.lean`'s docstring says today — **attribute and simp-set declarations
only, no lemmas and no definitions**, because `Init.lean` imports it and anything heavier would
be forced upstream of the entire library. `Meta.lean` joining the directory makes this constraint
*per-file* rather than per-directory; the README should say `Attr.lean` carries it and `Meta.lean`
is ordinary (`ProofSystem`-importing) metaprogramming that merely has no natural home above
`Automation/`.

## Decisions

1. **Corrected layer order is `{Syntax, ProofSystem, ForMathlib, Init, Tactic} -> Semantics ->
   Theorems -> {Metalogic, Automation} -> Examples`** (assignment A). Driven by measurement:
   47 `Metalogic -> Theorems` lines vs. 4 in the reverse direction (all `DeductionTheorem`), and
   zero non-aggregator `Automation -> Metalogic` edges post-move. Chosen over the
   `Automation`-at-2 variant because that variant would make `Theorems -> Automation` invisible to
   the very measurement the acceptance criterion reads (see R-8).
2. **`Tactic/Attr.lean` imports `Lean` only** and is added to `CheckInitImportsMain.lean`'s
   `exceptions`. Verified: no module other than the already-excepted `ForMathlib/Order/PFilter`
   loses its transitive `Init` path.
3. **`Automation/Tactics/Meta.lean` moves to `Tactic/Meta.lean`**, not into the relocated
   `PropDecide` file. `Commands.lean` and `Search.lean` also consume it and stay in `Automation/`.
4. **`DeductionTheorem.lean` keeps `namespace FormalSystem.Metalogic.Core`**, and the resulting
   `unrelated` namespace-audit row is *recorded* in the file's docstring and in the Phase-5
   exception list, not left implicit. 51 FQN call sites make any alternative disproportionate.
5. **The layer-order assertion is an allowlist equality with 7 recorded `AxiomDischarge` lines**,
   failing on surplus and shortfall alike, not a zero-upward-edges check.
6. **The `ProofSearch.Core -> SuccessPatterns` cut is struck as a no-op** per the BimodalTools-split
   decision, and PUBLICATION_REFACTOR line 358 is corrected in the same commit.
7. **The two pre-existing red checks are recorded, not fixed**: `readme-lint.sh` (21 `../Boneyard/`
   links one `../` short) and `typst-sync-check.sh` (`sorry-total committed=4 live=0`). Neither is
   caused by, nor cured by, this task.

## Risks & Mitigations

| # | Risk | Likelihood | Mitigation |
|---|---|---|---|
| R-1 | **Typst chapter compile breaks** on the `#assert(roles.len() == automation-module-map.len())` when the generated map loses two rows | High — it is a hard assert | Edit `roles` and regenerate the map in the *same* commit as the Phase-2 move; run the typst compile, not just `typst-sync-check.sh` |
| R-2 | **`deductionTheorem` unreachable at some of the 51 FQN sites** after the move, because several consumers rely on a transitive path through `Metalogic/Core/` | Medium | Phase 3 is its own commit gated on a full `lake build`; if a site breaks, add the direct `import FormalSystem.Theorems.DeductionTheorem` rather than re-parenting the file |
| R-3 | **`move-modules.py` corrupts historical prose** ("moved from X to Y" → "from Y to Y") in ARCHITECTURE.md / PUBLICATION_REFACTOR.md / Automation READMEs | Medium — the shape is present | Mandatory `--dry-run` + hand review of every non-`.lean` hunk before the real run; the tool's own header documents the bare-token audit line to check |
| R-4 | **ORGANISATION.md and docs/ARCHITECTURE.md contradict each other** if only the former is rewritten — ORGANISATION.md explicitly defers the layer graph to ARCHITECTURE.md, and ARCHITECTURE.md is independently stale (calls `Semantics -> ProofSystem` "upward" though its own diagram puts ProofSystem *below* Semantics; names `DataExport.lean`, `TraceExporterMain.lean`, `TableauProofStepsMain.lean` as `Automation/` modules — all three now live in `BimodalTools/`; lists a top-level `PlusLanguage/` that is now `Syntax/PlusLanguage/`; describes `Automation/` as holding "the ML dataset pipeline") | High | Rewrite both in Phase 5. No mechanical check catches the contradiction — C5/C12/C13 verify paths and links, never consistency of claims |
| R-5 | **C8 fails** because `FormalSystem/Tactic/` has no sibling aggregator (`ENFORCE_C8=1`, and `FormalSystem/` is a walked parent) | High if forgotten | Create `FormalSystem/Tactic.lean` in the same commit that creates the directory |
| R-6 | **readme-lint Check 1 fails** — `FormalSystem/Tactic/` has `.lean` files and no README (Check 1 *is* gated) | High if forgotten | Create `FormalSystem/Tactic/README.md` in the same commit |
| R-7 | **C6 flags `FormalSystem.Tactic` as unreachable** — the new aggregator is in no import closure | Medium | Add `import FormalSystem.Tactic` to `FormalSystem/FormalSystem.lean`; do **not** add a C6 manifest row for something trivially reachable |
| R-8 | **A renumber silently satisfies the acceptance criterion instead of the relocation doing so.** `into_automation` is derived from `edges`, which holds only edges the layer comparison already called upward; any source directory placed at or above `Automation`'s layer drops out of the acceptance measurement entirely | High if assignment B is chosen | Choose assignment A, which keeps all four acceptance sources (Syntax 0, ProofSystem 0, Semantics 1, Theorems 2) strictly below `Automation` at 3. If assignment B is chosen instead, `measure_upward_edges` **must** first be rewritten so `into_automation` enumerates its five source directories independently of `LAYERS` |
| R-9 | **Attribute unavailable at a tag site** if some module tags `@[tmLemma]`/`@[truth_norm]` without reaching `Init` | Low | Already measured: the only module losing its `Init` path is the pre-excepted `ForMathlib/Order/PFilter`, which tags nothing. C24 re-run in build mode is the gate |
| R-10 | **`Semantics/Periodicity.lean` confused with `Semantics/Correspondence/FwdRecPeriodicity.lean`** | Low | One-line disambiguation in `FormalSystem/Semantics/README.md` |

R-8 deserves emphasis because it is the one way this task can report success without having done
the work. `measure_upward_edges` builds `edges` from the layer comparison and *then* filters it
into `into_automation`; the explicit five-directory tuple at
`scripts/measure-refactor-partitions.py:155-156` therefore narrows an already-filtered set rather
than scanning independently. Renumbering `Automation` down to `Theorems`' layer would empty the
`Theorems -> Automation` rows whether or not the 8 `LemmaDB` lines were ever deleted. Assignment A
avoids this entirely; any deviation from A must be accompanied by making `into_automation` scan
the import graph directly.

## Tactic Survey Results

- Not applicable (no proof goals; this task is a module-relocation and documentation task with
  zero new Lean proofs). The one lean-lsp probe run was an elaboration availability check
  (`import Lean` + `register_simp_attr` + `register_label_attr`), reported under External
  Resources.

## Context Extension Recommendations

- **Topic**: Generated-artifact coupling in this repository.
  **Gap**: `typst/generated/automation-module-map.typ` is regenerated from a *glob*, and
  `typst/chapters/p4-proof-automation.typ` hard-asserts row-count agreement with a hand-written
  `roles` dictionary. Any module relocation out of `Automation/{Tactics,ProofSearch}/` breaks the
  chapter compile in a way no Lean gate reports. Nothing in `context/project/lean4/` records this
  coupling.
  **Recommendation**: add `context/project/lean4/operations/generated-artifact-coupling.md`
  listing each generated artifact, its generator, its consumers and the assert that binds them
  (`automation-module-map.typ` / `typst-module-map.sh` / `p4-proof-automation.typ` `#assert`;
  `machine-appendix.*` / `typst-machine-appendix.sh`; `generated/status.typ` /
  `typst-status-counts.sh`).

- **Topic**: The distinction between a gated and a reported check in this repo's harness.
  **Gap**: `readme-lint.sh` and `typst-sync-check.sh` both print `FAIL` and both **exit 0 through
  a pipe**, which invites an agent to read "FAIL" and stop, or to read `exit=0` and call it green.
  The per-check gated/reported split is documented inside each script's header and nowhere an
  agent reads first.
  **Recommendation**: extend `context/project/lean4/operations/` with a one-page table of every
  repository check, its command, whether its exit code gates, and its known-red baseline.

## Appendix

### Commands run (all re-derived at HEAD `b1ab4bf3a`)

```bash
python3 scripts/measure-refactor-partitions.py upward-edges
python3 scripts/measure-refactor-partitions.py namespace-audit
bash scripts/check-module-invariants.sh --no-build          # ALL CHECKS PASSED
bash scripts/check-metalogic-cycles.sh                      # PASS, exactly 1 cycle
bash scripts/readme-lint.sh                                 # FAIL, 21 broken refs (pre-existing)
bash scripts/typst-sync-check.sh                            # FAIL, sorry-total 4 vs 0 (pre-existing)
```

Simulation (scratchpad, not committed): rebuild `ImportGraph.edges` with the seven module renames
applied and every `Tactic.Attr` import dropped, then recount upward edges under four candidate
`LAYERS` tables. Results in "Simulated post-move measurement" above.

Init-reachability simulation: rebuild `edges` with the three attribute modules removed as import
targets, recompute every module's transitive closure, report modules losing
`FormalSystem.Init`. Result: 1 (`FormalSystem.ForMathlib.Order.PFilter`, already excepted).

### Key file references

- `scripts/measure-refactor-partitions.py:78-85` — the `LAYERS` table to renumber
- `scripts/measure-refactor-partitions.py:155-156` — `into_automation`'s explicit source tuple (see R-8)
- `scripts/check-metalogic-cycles.sh:11-31` — the exclusions and the "not wired into the harness"
  rationale the new assertion must preserve
- `scripts/CheckInitImportsMain.lean:33-44` — the `exceptions` list
- `scripts/check-module-invariants.sh:1209-1240` — C8, `ENFORCE_C8=1`
- `scripts/move-modules.py:383-404` — `resolve_move`, the file-granular fix
- `typst/chapters/p4-proof-automation.typ:107-127` — the `roles` dictionary and the `#assert`
- `docs/development/PUBLICATION_REFACTOR.md:344-365` — Phase 4, the authoritative spec
- `specs/632_bimodaltools_split/reports/01_bimodaltools-library-split.md:30-34,94-96` — the
  `SuccessPatterns` decision and its explicit instruction to correct Phase 4's bullet

### Tags

layering · import-graph · relocation · attributes · Init · publication-refactor
