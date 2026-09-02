# Implementation Plan: Task #518

- **Task**: 518 - Wave 0 hotfix: simp loop, unbuilt modules, drifted documentation
- **Status**: [IMPLEMENTING]
- **Effort**: 5.25 hours
- **Dependencies**: None (this task is the blocker for 517, 519, 520, 521, 522, 523, 529)
- **Research Inputs**: specs/518_metalogic_hotfix_simp_loop_unbuilt_modules/reports/01_wave-0-hotfix-verification.md
- **Artifacts**: plans/01_wave-0-hotfix-execution.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Seven independent, small defects blocking the metalogic consolidation programme: a global `simp`
loop that makes plain `simp` unusable on `Formula` goals, four live-but-unreachable modules that
fail invariant check C6, a directory-level import cycle carried by a single orphan declaration,
and four drifted documentation sites (README strong-completeness status, typst `sorryAx` claims,
`Formula` constructor tables, and an undeclared Aesop rule set). Every claim was measured against
`HEAD` (`92b154ab2`) during research; this plan is built on the corrected findings, not on the
original task description. The baseline is green: `lake build` exits 0 and
`scripts/check-module-invariants.sh` passes everything except C6, so any failure during execution
is attributable to the change that produced it.

Definition of done: `lake build` and `lake build BimodalTest` at exit 0;
`bash scripts/check-module-invariants.sh` with **C6 flipped FAIL -> PASS** and no other check
regressing; the `simp` regression `example` compiling; `grep` confirming every corrected doc site.

### Research Integration

Findings from `reports/01_wave-0-hotfix-verification.md` that materially shape this plan:

- **`register_simp_attr` cannot be declared and used in the same compilation unit** (measured:
  `Unknown attribute` / `Unknown identifier`). A two-module probe compiles clean. Phase 6 therefore
  creates `FormalSystem/Automation/NormalizationAttr.lean`.
- **Stripping all 31 `@[simp]` tags leaves `lake build` and `lake build BimodalTest` at exit 0.**
  Nothing in the tree or the test suite depends on these lemmas being in the global simp set. This
  removes the principal risk from Phase 6.
- **`modalFold` uses `← *_unfold`, not the `*_fold` family.** Rewriting it to
  `simp only [formula_fold]` would be a genuine behavioural change (six of the reversed unfold
  lemmas have no `_fold` counterpart). Phase 6 keeps `modalFold` on the `←`-form.
- **The regression example needs `open FormalSystem.Syntax`**, not `open FormalSystem` —
  `Formula` lives in `namespace FormalSystem.Syntax`.
- **`BLSchemaValidity` is already reachable** via `Metalogic/BaseLanguageSoundness.lean:10` and is
  **not** one of C6's four failures. Adding it to `Semantics.lean` is separable hygiene, excluded
  here (see Non-Goals).
- **Two imports in `Metalogic.lean` clear all four C6 entries transitively** (`Z1Countermodel` pulls
  `TMCompletenessReduction` and `LexCarrier`). No manifest edit needed.
- **`README.md:239-240` is a second drifted Dedekind site** the description did not name.
- **Six typst regions need correction, not five** — `:1007-1010` was unlisted.
- **The constructor tables use dead snake_case identifiers**; the real names are camelCase
  (`allPast`, `allFuture`, `somePast`, `someFuture`). `Syntax/README.md:19` gets a corrected inline
  six-constructor list rather than a link, because top-level `README.md:32` says "5 primitive
  connectives" and omits `atom`.
- **`Metalogic/README.md` needs no edit at all** — it already says "exactly two" cycles at `:70`
  (the description's `:88` had drifted), and deleting the orphan makes that statement true.
- **`AesopRules.lean` carries 21 attributes, not 18**, and documents its own defect at `:50-53`,
  which must be rewritten in the same change. The `register_simp_attr` import-boundary caveat may
  apply to `declare_aesop_rule_sets` too and must be checked empirically before committing to a
  layout.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` was not supplied as `roadmap_path` in the delegation context, so no roadmap
phases are added and no roadmap item is claimed. The roadmap's stated discipline — that every
status claim be grounded in a named `scripts/check-module-invariants.sh` check — is nevertheless
what Phase 5 and Phase 8 enforce (C6), and what Phases 1-3 restore on the prose side by deleting
status claims the code contradicts.

## Goals & Non-Goals

**Goals**:
- Remove the 31 unfold/fold lemmas from the global simp set so plain `simp` terminates on
  `Formula` goals, without changing any macro's behaviour.
- Flip invariant check C6 from FAIL to PASS by making the four live-but-unreachable modules
  reachable from `FormalSystem.Metalogic`.
- Break the `Bundle <-> Algebraic` directory cycle by deleting its sole carrier declaration.
- Correct four classes of drifted documentation so no prose claim contradicts machine-checked
  fact.
- Declare a dedicated Aesop rule set so `AesopRules`' 21 rules stop polluting the default set for
  every consumer, and rewrite the module docstring that documents the defect.
- Leave `lake build`, `lake build BimodalTest`, and every non-C6 invariant check exactly as green
  as they are at `HEAD`.

**Non-Goals**:
- Adding `FormalSystem.Semantics.LexCarrier` or `FormalSystem.Semantics.BLSchemaValidity` to
  `FormalSystem/Semantics.lean`. Both are layering hygiene, neither is required for C6, and the
  `LexCarrier` addition carries real risk (it puts `SuccOrder`/`PredOrder` instances on `ℚ ×ₗ ℤ`
  plus four Mathlib order/algebra imports into the aggregator essentially every module imports,
  widening instance search tree-wide). Track separately.
- Fixing the two `push_neg` deprecation warnings at `Z1Countermodel.lean:101` and `:148` that will
  become visible once the module is wired in. Non-fatal, unrelated.
- Editing `FormalSystem/Metalogic/README.md`. It already reads "exactly two" cycles; the Phase 4
  deletion makes that true.
- Adding a `check-module-invariants.sh` check that enumerates directory cycles from the import
  graph instead of asserting a hand-counted number. Correct follow-up, out of hotfix scope.
- Adding the six missing `_fold` lemmas (`weak_future`, `weak_past`, `always`, `sometimes`,
  `strong_release`, `strong_trigger`) to make `modalFold` symmetric.
- Touching `normalizeFormula_id` (`Normalization.lean:1218`), the 32nd `@[simp]`, which is not part
  of the loop.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `declare_aesop_rule_sets` hits the same import-boundary restriction as `register_simp_attr` | M | M | Phase 7 probes in-file usage empirically **before** committing to a layout; the phase pre-declares a conditional second module in its file set so the fallback needs no re-scoping |
| Retagging `modalFold` to `simp only [formula_fold]` silently changes tactic behaviour | H | L | Explicitly ruled out: Phase 6 keeps `modalFold` on the `←`-form and tags the `*_fold` family only to evict it from the global set |
| Wiring `Z1Countermodel`/`SpWitness` into `Metalogic.lean` surfaces new elaboration or instance-search cost tree-wide | M | L | All four modules already compile clean standalone (measured, exit 0); Phase 5 runs a full `lake build` and compares against the green `HEAD` baseline |
| Deleting the `LimitMCS` import breaks a consumer that was reaching `FlowFrame` transitively through it | M | L | Phase 4 runs a full `lake build`, not a single-module build; `grep` for `bundleFlow*` confirms occurrences are confined to the deleted declaration and its docstring |
| A doc edit breaks a markdown cross-reference | L | M | Phases 1-3 run `check-module-invariants.sh` C12/C13 (markdown link checks) in addition to `grep` |
| Parallel execution of the four Lean phases interleaves `lake build` runs, making a failure unattributable | M | M | The four Lean phases are serialized on the build resource despite carrying no logical dependency — see the note under the Dependency Analysis table |
| Phase 6's intermediate per-file state is red (tags reference an attribute whose module does not yet exist) and gets committed | L | M | Phase 6 declares `Commit Mode: atomic-batch` with a pre-declared file set |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4, 5, 6, 7 | -- |
| 2 | 8 | 1, 2, 3, 4, 5, 6, 7 |

Phases within the same wave can execute in parallel.

**Build-resource serialization note** (execution guidance, not a dependency): Phases 1-3 touch no
Lean source and are genuinely parallel with everything. Phases 4, 5, 6, and 7 touch **disjoint**
Lean files and have no logical ordering dependency among themselves, but each requires its own
`lake build`, a serialized resource. Run them one at a time, in the order 4 -> 5 -> 6 -> 7
(smallest blast radius first), so that any build failure is attributable to a single phase's diff
against a known-green predecessor. Do not model this as a `Depends on` chain — it is a resource
constraint, and recording it as a dependency would misstate what actually blocks what.

---

### Phase 1: Correct README Dedekind strong-completeness status [COMPLETED]

**Goal**: `README.md` stops describing Dedekind strong completeness as "not stated" / "open" when
`Metalogic/DedekindNonCompactness.lean` refutes it sorry-free.

**Tasks**:
- [x] Rewrite `README.md:167` — replace "**not stated**, and unavailable on the primary source's
      own terms … so the class is *unproved* rather than refuted" with a **refuted** claim naming
      `strongCompletenessDedekind_refuted` (`DedekindNonCompactness.lean:459`) and
      `dedekind_consequence_not_compact` (`:431`), matching the pattern of the Discrete bullet
      immediately above it (`:165`). Preserve the Reynolds 1992 weak-only observation if it is
      still accurate as a separate remark; drop only the "no `CompactDedekind` definition and no
      refuting theorem" assertion, which is false — `SetConsequence.lean` defines
      `StrongCompletenessDedekind` (`:601`) and `CompactDedekind` (`:609`), both with docstrings
      already saying "This statement is false".
- [x] Rewrite `README.md:239-240` — "a different property from Dedekind strong completeness (open
      — see the strong-completeness discussion above…)" becomes "refuted", keeping the
      forward-reference intact now that it points at a corrected paragraph.
- [x] Cross-check the corrected wording against `FormalSystem/Metalogic.lean:116-120`, which is
      already right ("`FrameClass.Dedekind` — **refuted**, like Discrete"), and do not introduce a
      third phrasing.

**Timing**: 0.25 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: Exactly two sites in `README.md` (`:167` and `:239-240`) assert the wrong
status. Confirm at implementation time with
`grep -n -iE 'dedekind' README.md` and re-read every hit, not just the two named line ranges —
line numbers drift, and the research pass found `:239-240` only because it read beyond the site
the description named.

**Files to modify**:
- `README.md` - two prose sites: `:167` (Dedekind bullet in the strong-completeness list) and
  `:239-240` (Galois-closure paragraph)

**Verification**:
- `grep -n -iE 'not stated|unproved rather than refuted' README.md` returns no Dedekind hit
- `grep -n -iE 'dedekind.*open|open.*dedekind' README.md` returns no hit
- `bash scripts/check-module-invariants.sh` C12/C13 (markdown link checks) still pass

---

### Phase 2: Correct the Formula constructor tables [COMPLETED]

**Goal**: The two `FormalSystem/README.md` operator tables and the `Syntax/README.md` primitives
bullet name `Formula`'s six actual constructors, using identifiers that exist.

**Tasks**:
- [x] Confirm ground truth from `FormalSystem/Syntax/Formula.lean:76-105`: `atom`, `bot`, `imp`,
      `box`, `untl`, `snce`.
- [x] `FormalSystem/README.md:49-58` ("Primitive Operators") — remove `Hφ | all_past φ` (`:57`)
      and `Gφ | all_future φ` (`:58`), which are derived, not primitive; add `untl` and `snce`,
      which are absent entirely. Per the research recommendation, replace the table with a link to
      the top-level `README.md:33-69` tables, which are correct on `untl`/`snce` and on the
      derived operators.
- [x] `FormalSystem/README.md:60-72` ("Derived Operators") — same treatment; note the snake_case
      names `some_past` (`:68`) and `some_future` (`:69`) are **dead identifiers**, not merely
      misclassified. The live names are camelCase: `allPast`, `allFuture`, `somePast`,
      `someFuture` (see `Normalization.lean:99-111`).
- [x] `FormalSystem/Syntax/README.md:19` — write the **corrected six-constructor list inline**
      (`atom`, `bot`, `imp`, `box`, `untl`, `snce`), do **not** link. Top-level `README.md:32` says
      "The logic uses 5 primitive connectives" and its table omits `atom` — a defensible reading
      (`atom` is not a connective) that nevertheless conflicts with the six-constructor list this
      bullet is specifically about.
- [x] *(deviation: added — `FormalSystem/Metalogic/Core/README.md:114,118` was a **third** drifted
      site the Scope Hypothesis missed, citing dead `Formula.all_future` / `Formula.all_past` in a
      `lean` code block. Corrected to `Formula.allFuture` / `Formula.allPast`, matching
      `Core/MCSProperties.lean:251,313`.)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: **REFUTED at implementation time.** The names occur outside `specs/` in
**seven** files, not two. Three are genuine documentation drift and were all fixed:
`FormalSystem/README.md`, `FormalSystem/Syntax/README.md`, and — not predicted —
`FormalSystem/Metalogic/Core/README.md`. The other four are not documentation drift and are
deliberately untouched: `FormalSystem/Automation/Normalization.lean` (37 hits) are **live**
constructors of a *different* type, `EnrichedFormula` (`:344-350`), not `Formula`;
`Tests/BimodalTest/Semantics/SemanticBenchmark.lean` and
`Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` are the two modules already manifested
as known-broken / not compile-checked under C6, and repairing them is a code change outside this
hotfix; `Tests/BimodalTest/Syntax/FormulaTest.lean:99,104` are comments with no identifier use.
The E-03 **documentation** scope is closed. Original hypothesis, for the record: the identifiers
occur outside `specs/` in exactly two files, closing E-03's scope. Confirm at implementation time with
`grep -rn -E 'all_past|all_future|some_past|some_future' --include='*.md' --include='*.lean' . | grep -v '^./specs/'`
before editing, and re-run it after to prove the set is empty.

**Files to modify**:
- `FormalSystem/README.md` - two operator tables (`:49-58`, `:60-72`)
- `FormalSystem/Syntax/README.md` - primitives bullet (`:19`)

**Verification**:
- The post-edit `grep` above returns zero hits outside `specs/`
- `grep -n 'untl' FormalSystem/Syntax/README.md` and `grep -n 'snce' FormalSystem/Syntax/README.md`
  each return a hit
- `bash scripts/check-module-invariants.sh` C12/C13 still pass (the new link in
  `FormalSystem/README.md` must resolve)

---

### Phase 3: Correct the typst sorryAx claims [COMPLETED]

**Goal**: `typst/FormalFoundations.typ` stops asserting that `completeness` carries `sorryAx` and
stops calling the live theorem `countermodel_discrete` dead code in the wrong file.

**Tasks**:
- [x] Re-establish ground truth before editing: `lean_verify` on
      `FormalSystem.Metalogic.BXCanonical.completeness` returns
      `["propext","Classical.choice","Quot.sound"]` — no `sorryAx`. This baseline is already pinned
      under C14 at `scripts/check-module-invariants.sh:145,155`, and C14 passes.
- [x] `:697` (footnote) — delete/rewrite "The `sorryAx` traces to a single dependency,
      `countermodel_discrete`, which is dead code".
- [x] `:699-703` — `#theorem("Base-class completeness (outstanding)")` must lose "(outstanding)",
      "with one proof obligation outstanding", "Its axiom report contains `sorryAx`", and "It is
      not an established theorem and is not used below". It **is** established and it **is** used:
      `BXCanonical/Completeness.lean:228` calls `countermodel_discrete`.
- [x] `:993` — table row `[`completeness`], …, [same, plus `sorryAx`], [*yes*]` corrected.
- [x] `:999-1005` — "exactly one structural `sorry` … `countermodel_discrete` in
      `WeakCanonical/Transfer.lean`. It is dead code." Wrong on the count (a tree-wide scan finds
      no live structural `sorry` outside `FormalSystem/Boneyard/`, consistent with C3), wrong on
      the file (`countermodel_discrete` is at
      `WeakCanonical/GroupModel/CountermodelBase.lean:143`), and wrong on "dead".
- [x] `:1007-1010` — "what carries the base class's `sorryAx` is the model-existence step of the
      Representation theorem's proof, via `completeness` alone". No `sorryAx` is carried.
- [x] `:1543` — summary table row `[Model existence (base class)], [`completeness`, one `sorryAx`]`
      corrected.
- [x] Leave `:704-705`'s `#leansrc` references untouched — verified correct.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: **CONFIRMED at implementation time.** `grep -n 'sorryAx'` and
`grep -n 'countermodel_discrete'` over `typst/FormalFoundations.typ` found no seventh region:
`:681`, `:688`, `:695` were already-correct "no `sorryAx`" lines, `:705` (now `:704`) is the
`#leansrc` block the plan says to leave alone, `:945` correctly describes
`countermodel_discrete_reynolds_v2`, and `:987` is a table header. Exactly the six named regions
needed correction. Original hypothesis: **Six** regions require correction (`:697`, `:699-703`,
`:993`, `:999-1005`, `:1007-1010`, `:1543`), not the five the task description named. Confirm at implementation time
with `grep -n 'sorryAx' typst/FormalFoundations.typ` and
`grep -n 'countermodel_discrete' typst/FormalFoundations.typ`, and treat every hit not on the list
above as a seventh region needing judgment rather than assuming the list is closed.

**Files to modify**:
- `typst/FormalFoundations.typ` - six regions

**Verification**:
- `grep -n 'sorryAx' typst/FormalFoundations.typ` returns no hit that attributes `sorryAx` to
  `completeness` or to the base class
- `grep -n 'dead code' typst/FormalFoundations.typ` returns no hit referring to
  `countermodel_discrete`
- `typst compile typst/FormalFoundations.typ` succeeds if the document is wired for compilation;
  if it is not, record that fact explicitly rather than silently skipping the check
  — **RESULT**: `typst` is installed and the document compiles at exit 0 (pre-existing font
  warnings only). `bash scripts/typst-sync-check.sh` additionally PASSES all three checks
  (backtick name resolution over 575 candidates, `generated/status.typ` count freshness,
  machine-appendix freshness).

---

### Phase 4: Delete the Bundle -> Algebraic orphan and its import [NOT STARTED]

**Goal**: The `Bundle <-> Algebraic` directory-level import cycle is gone, restoring
`Metalogic/README.md:70`'s "exactly two cycles" statement and the `Algebraic/`-below-`Bundle/`
layering diagram to accuracy.

**Tasks**:
- [ ] Confirm `fc_theorem_true_in_bundle_flow_model` (`Bundle/LimitMCS.lean:461-473`) still has
      zero consumers: `grep -rn 'fc_theorem_true_in_bundle_flow_model' --include='*.lean' .`
      must return only its own declaration site.
- [ ] Confirm it is still the only declaration in the file touching `FlowFrame`:
      `grep -n 'bundleFlow' FormalSystem/Metalogic/Bundle/LimitMCS.lean` must return only `:452`,
      `:470`, `:471` — all inside that declaration and its docstring.
- [ ] Delete the declaration (and its docstring).
- [ ] Delete `import FormalSystem.Metalogic.Algebraic.FlowFrame` at `LimitMCS.lean:8`.
- [ ] Do **not** edit `FormalSystem/Metalogic/README.md` — it already reads "exactly two", and this
      deletion is what makes that true.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: This is a clean **two-hunk** change (one declaration, one import) in one
file, with **zero** consumers of the deleted symbol. Confirm both counts with the two `grep`s in
the first two tasks above **before** deleting; if either returns more than expected, stop and
re-scope rather than deleting.

**Files to modify**:
- `FormalSystem/Metalogic/Bundle/LimitMCS.lean` - remove `:8` import and the `:461-473`
  declaration

**Verification**:
- `lake build` exits 0 (full build, not a single-module build — `LimitMCS` is reachable via
  `BXCanonical/Chronicle/*` -> `Bundle/RealExtensionBundle` -> `RealExtension` ->
  `LimitMCSCoherence` -> `LimitMCS`, so downstream modules could have been reaching `FlowFrame`
  transitively through it)
- `grep -n 'Algebraic.FlowFrame' FormalSystem/Metalogic/Bundle/LimitMCS.lean` returns no hit
- `bash scripts/check-module-invariants.sh` shows no check regressing from the
  all-pass-except-C6 baseline

---

### Phase 5: Wire the four unreachable modules into the build graph [NOT STARTED]

**Goal**: Invariant check C6 flips from FAIL to PASS. `Metalogic/Conservativity.lean:158-162`'s
claim that `tmCompleteDiscrete_refuted` and `not_bl_derivable_z1` are "now landed … machine-checked,
not merely documented" becomes true of code `lake build` actually compiles.

**Tasks**:
- [ ] Record the pre-change C6 failure text from `bash scripts/check-module-invariants.sh` so the
      flip is demonstrable, not asserted.
- [ ] Add `import FormalSystem.Metalogic.Z1Countermodel` and
      `import FormalSystem.Metalogic.SpWitness` to `FormalSystem/Metalogic.lean` (the re-export
      block currently spans `:8-19`).
- [ ] Do **not** edit `scripts/module-invariants-manifest.txt`. The two imports pull
      `TMCompletenessReduction` (via `Z1Countermodel.lean:8`) and `LexCarrier` (via
      `Z1Countermodel.lean:10`) in transitively, clearing all four C6 entries with no manifest
      change.
- [ ] Do **not** add `LexCarrier` or `BLSchemaValidity` to `FormalSystem/Semantics.lean` — see
      Non-Goals.
- [ ] Note but do not fix the two `push_neg` deprecation warnings at `Z1Countermodel.lean:101`
      and `:148` that become visible in the main build once wired in.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: A **two-line** diff to one file clears **all four** C6 entries
(`SpWitness`, `Z1Countermodel`, `TMCompletenessReduction`, `LexCarrier`) with **zero** manifest
edits. Confirm by diffing the C6 section of `check-module-invariants.sh` output before and after:
the count of unmanifested unreachable modules must go 4 -> 0. If it goes 4 -> 1 or 4 -> 2, the
transitive-pull assumption is wrong and the remaining modules need explicit imports — add them
rather than reaching for a manifest edit.

**Files to modify**:
- `FormalSystem/Metalogic.lean` - two added imports in the re-export block

**Verification**:
- `bash scripts/check-module-invariants.sh` reports **C6 PASS** (the acceptance criterion)
- `lake build` exits 0
- No other invariant check regresses from the all-pass-except-C6 baseline

---

### Phase 6: Move the 31 normalization lemmas out of the global simp set [NOT STARTED]

**Goal**: Plain `simp` terminates on `Formula` goals. `example (a : Formula) : a.neg = a.neg := by
simp` compiles instead of failing with `maximum recursion depth has been reached`.

**Tasks**:
- [ ] Create `FormalSystem/Automation/NormalizationAttr.lean` containing **only** the standard
      copyright header, `import Lean`, and two `register_simp_attr` declarations for
      `formula_unfold` and `formula_fold`. This separate module is **required**, not stylistic:
      `register_simp_attr` parses in `Normalization.lean` but the attribute it declares is not
      usable in the same compilation unit (measured: `Unknown attribute [formula_unfold]` /
      `Unknown identifier formula_unfold`). A two-module probe compiles clean and both
      `simp only [formula_unfold]` and `simp only [formula_fold]` work. `register_simp_attr`
      appears nowhere in this repo or in the pinned Mathlib, so there is no in-tree precedent —
      re-probe if the two-module form does not compile first try.
- [ ] Add `import FormalSystem.Automation.NormalizationAttr` to
      `FormalSystem/Automation/Normalization.lean`.
- [ ] Retag the 21 unfold lemmas (`@[simp]` -> `@[formula_unfold]`) at `:69, 72, 75, 78, 83, 87,
      91, 95, 99, 105, 109, 115, 120, 127, 133, 139, 143, 149, 153, 157, 161`, section
      `UnfoldLemmas` (`:67`-`:164`).
- [ ] Retag the 10 fold lemmas (`@[simp]` -> `@[formula_fold]`) at `:800, 803, 806, 810, 814, 818,
      822, 826, 830, 834`, section `FoldLemmas` (`:798`-`:837`).
- [ ] Leave `normalizeFormula_id`'s `@[simp]` at `:1218` **untouched** — it is the 32nd `@[simp]`
      and is not part of the loop.
- [ ] Rewrite `modalNorm` (`:178`), `modalNormAt` (`:206`), and `modalNormAll` (`:220`): each
      enumerates the same 21 unfold lemmas by name; replace the whole list with `[formula_unfold]`.
- [ ] **Keep `modalFold` (`:845`) on the `←`-form.** It uses `← *_unfold` (reverse rewriting), not
      the `*_fold` family. Replacing it with `simp only [formula_fold]` is a real behavioural
      change: six of its entries (`weak_future`, `weak_past`, `always`, `sometimes`,
      `strong_release`, `strong_trigger`) have `← _unfold` forms but no `_fold` lemma. Tagging the
      `*_fold` family is purely to evict it from the global simp set.
- [ ] Leave `propNorm` (`:188`), `modalOpNorm` (`:192`), and `temporalNorm` (`:198`) unchanged —
      they use explicit sub-lists and must keep naming lemmas individually.
- [ ] Add the regression `example` to the existing
      `Tests/BimodalTest/Automation/NormalizationTest.lean` (255 lines, already imports
      `FormalSystem.Automation.Normalization` and is already wired into `Tests/BimodalTest.lean`).
      Do not create a new test file. The example must `open FormalSystem.Syntax` — `open
      FormalSystem` does not bring `Formula` into scope (`Formula` is declared in
      `namespace FormalSystem.Syntax`, `Formula.lean:55`/`:127`).

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

Pre-declared file set for the batch: `FormalSystem/Automation/NormalizationAttr.lean` (new),
`FormalSystem/Automation/Normalization.lean`,
`Tests/BimodalTest/Automation/NormalizationTest.lean`. Intermediate per-file states are expected
red — retagged lemmas reference an attribute whose declaring module is not yet imported — and MUST
NOT be committed. The batch lands as one green commit.

**Scope Hypothesis**: **31** tags move (21 unfold + 10 fold), **1** `@[simp]`
(`normalizeFormula_id`) stays, **3** macros are rewritten to `[formula_unfold]`, **1** macro
(`modalFold`) is retagged-around but not rewritten, and **3** macros are untouched. Confirm the
tag count at implementation time with `grep -c '@\[simp\]'
FormalSystem/Automation/Normalization.lean` before (expect 32) and after (expect 1). If the before
count is not 32, re-enumerate the sections rather than trusting the line list above.

**Files to modify**:
- `FormalSystem/Automation/NormalizationAttr.lean` - **new**; `import Lean` plus two
  `register_simp_attr` declarations
- `FormalSystem/Automation/Normalization.lean` - one added import, 31 retags, 3 macro rewrites
- `Tests/BimodalTest/Automation/NormalizationTest.lean` - regression `example` appended

**Verification**:
- `lake build` exits 0 **and** `lake build BimodalTest` exits 0. Both are already green at `HEAD`,
  and a measured probe confirmed that stripping all 31 tags leaves both at exit 0 with zero
  downstream breakage — so any failure here is attributable to the retag wiring, not to lost simp
  coverage.
- The regression `example (a : Formula) : a.neg = a.neg := by simp` compiles (with
  `open FormalSystem.Syntax`) where it previously failed with `maximum recursion depth`.
- `simp only [formula_unfold]` and `simp only [formula_fold]` each resolve (they exercise the
  cross-module attribute wiring; a silent `Unknown attribute` here means the module split did not
  take).
- Blast-radius spot check: `Normalization.lean` has 5 live importers (`FormalSystem/Automation.lean:15`,
  `Metalogic/Decidability/DecisionProcedure.lean`, `Automation/DatasetExport.lean`,
  `Automation/ProofStepExtractor.lean`, `Tests/BimodalTest/Automation/NormalizationTest.lean`), and
  `Automation.lean` is reached from `FormalSystem/FormalSystem.lean:14`, so the full build is the
  real check.

---

### Phase 7: Declare a dedicated Aesop rule set for AesopRules [NOT STARTED]

**Goal**: `AesopRules`' 21 rules stop being registered in Aesop's **default** rule set, where they
are picked up by plain `aesop` for every consumer of `FormalSystem.Automation`, and the module
docstring stops documenting a defect that no longer exists.

**Tasks**:
- [ ] **Probe first.** `declare_aesop_rule_sets` is available in the pinned Mathlib
      (`Mathlib/CategoryTheory/Category/Init.lean:21`, `Mathlib/Tactic/SetLike.lean:22`), but
      Mathlib places it in dedicated `Init.lean`-style modules — the same import-boundary caveat
      that bit `register_simp_attr` may apply. Empirically test whether
      `declare_aesop_rule_sets [TMLogic]` can be declared and used in the same file **before**
      committing to a layout. If it cannot, create a small separate module (mirroring Phase 6's
      `NormalizationAttr.lean` shape) and import it.
- [ ] Retag the 21 attributes in `FormalSystem/Automation/AesopRules.lean` (285 lines) into the
      `TMLogic` rule set: `@[aesop safe apply]` x10 (`:78, 84, 90, 96, 102, 108, 115, 222, 232,
      242`), `@[aesop safe forward]` x7 (`:132, 144, 156, 168, 181, 192, 204`),
      `@[aesop norm unfold]` x4 (`:258, 266, 274, 282`).
- [ ] **Rewrite the module docstring at `:50-53` in the same change.** It currently documents the
      defect verbatim: "the rules below are registered in Aesop's DEFAULT rule set via
      `@[aesop safe apply]`; there is no separate `TMLogic` rule set declared
      (`declare_aesop_rule_sets [TMLogic]` is absent), so plain `aesop` picks them up." Leaving it
      in place after the fix would make the file self-contradicting.
- [ ] Leave the deprecation notice at `:16-22` alone unless the retag makes it inaccurate; if it
      does, correct it in the same change.
- [ ] Check the two known consumers still build: `FormalSystem/Automation.lean:12` and
      `Automation/Tactics/Helpers.lean:8`. Any call site relying on plain `aesop` picking these
      rules up from the default set will now need `aesop (rule_sets := [TMLogic])`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

Pre-declared file set for the batch: `FormalSystem/Automation/AesopRules.lean` and — conditional on
the probe in the first task — one new small rule-set-declaring module under
`FormalSystem/Automation/`. Both are declared now, before the probe, so the fallback layout needs
no retroactive widening of the batch. Intermediate states (rules retagged into a rule set that is
not yet declared in an imported module) are expected red and MUST NOT be committed.

**Scope Hypothesis**: **21** attributes require retagging (10 + 7 + 4), not the 18 the task
description asserted. Confirm at implementation time with
`grep -c '@\[aesop' FormalSystem/Automation/AesopRules.lean` (expect 21) before editing. The
line list above is a hypothesis about **where** they are; the count is the check.

**Files to modify**:
- `FormalSystem/Automation/AesopRules.lean` - 21 attribute retags plus the `:50-53` docstring
  rewrite
- (conditional, probe-dependent) a new `FormalSystem/Automation/` module carrying
  `declare_aesop_rule_sets [TMLogic]`

**Verification**:
- `lake build` exits 0 and `lake build BimodalTest` exits 0
- `grep -n 'DEFAULT rule set' FormalSystem/Automation/AesopRules.lean` returns no hit (the
  docstring defect statement is gone)
- `grep -c 'rule_sets' FormalSystem/Automation/AesopRules.lean` is non-zero, or the separate
  declaring module exists and is imported
- No consumer of `FormalSystem.Automation` regresses

---

### Phase 8: Final acceptance gate [NOT STARTED]

**Goal**: Prove the whole hotfix against the stated acceptance criteria in one pass, on the
combined tree rather than seven times on seven partial trees.

**Tasks**:
- [ ] `lake build` — exit 0.
- [ ] `lake build BimodalTest` — exit 0.
- [ ] `bash scripts/check-module-invariants.sh` — **C6 PASS**, and every other check still passing.
      Compare explicitly against the recorded `HEAD` baseline (all-pass except C6); a check that
      was passing and now fails is a regression this hotfix caused, not pre-existing noise.
- [ ] The `simp` regression `example` in
      `Tests/BimodalTest/Automation/NormalizationTest.lean` compiles.
- [ ] `grep` confirmation sweep across all four doc fronts: the two `README.md` Dedekind sites, the
      three constructor-table sites, the six typst regions, and the `AesopRules.lean` docstring.
- [ ] Record which Non-Goals were deliberately left undone (the two `Semantics.lean` hygiene
      additions, the two `push_neg` deprecations, the cycle-enumerating invariant check) so the
      downstream tasks in the programme inherit an accurate picture.

**Timing**: 0.5 hours

**Depends on**: 1, 2, 3, 4, 5, 6, 7

**Verification Tier**: full

**Files to modify**:
- None (verification only)

**Verification**:
- All five acceptance checks above pass simultaneously on one tree

---

## Testing & Validation

- [ ] `lake build` exits 0 (green at `HEAD`, so any failure is attributable)
- [ ] `lake build BimodalTest` exits 0 (green at `HEAD`)
- [ ] `bash scripts/check-module-invariants.sh`: C6 flips FAIL -> PASS; C3, C12, C13, C14 and every
      other check remain PASS
- [ ] `example (a : Formula) : a.neg = a.neg := by simp` compiles in
      `Tests/BimodalTest/Automation/NormalizationTest.lean` with `open FormalSystem.Syntax`
- [ ] `simp only [formula_unfold]` and `simp only [formula_fold]` both resolve
- [ ] `grep -rn -E 'all_past|all_future|some_past|some_future' --include='*.md' --include='*.lean' . | grep -v '^./specs/'`
      returns nothing
- [ ] `grep -n 'sorryAx' typst/FormalFoundations.typ` attributes no `sorryAx` to `completeness`
- [ ] `grep -n -iE 'dedekind.*(open|not stated)' README.md` returns nothing
- [ ] `grep -n 'fc_theorem_true_in_bundle_flow_model' -r --include='*.lean' .` returns nothing
- [ ] `grep -n 'DEFAULT rule set' FormalSystem/Automation/AesopRules.lean` returns nothing

## Artifacts & Outputs

- `FormalSystem/Automation/NormalizationAttr.lean` (new module: two `register_simp_attr`
  declarations)
- Modified: `README.md`, `FormalSystem/README.md`, `FormalSystem/Syntax/README.md`,
  `typst/FormalFoundations.typ`, `FormalSystem/Metalogic/Bundle/LimitMCS.lean`,
  `FormalSystem/Metalogic.lean`, `FormalSystem/Automation/Normalization.lean`,
  `FormalSystem/Automation/AesopRules.lean`,
  `Tests/BimodalTest/Automation/NormalizationTest.lean`
- Conditionally new (probe-dependent): a small `FormalSystem/Automation/` module carrying
  `declare_aesop_rule_sets [TMLogic]`
- `specs/518_metalogic_hotfix_simp_loop_unbuilt_modules/summaries/01_wave-0-hotfix-summary.md`

## Rollback/Contingency

Every phase is an independent, small diff on a disjoint file set, and each lands as its own commit
(Phases 6 and 7 as pre-declared atomic batches). Reverting any single phase's commit restores the
green `HEAD` baseline for that front without disturbing the others — this is the specific reason
the four Lean phases are kept separate rather than merged into one build-and-commit.

Per-phase contingency:
- **Phase 6** — if the two-module `register_simp_attr` layout does not compile despite the measured
  probe, fall back to plain removal of the 31 `@[simp]` tags with no replacement attribute, and
  keep the three macros enumerating lemmas by name. A measured probe confirmed this leaves both
  `lake build` and `lake build BimodalTest` at exit 0 with zero downstream breakage, so the simp
  loop is fixed either way; only the macro-list ergonomics are lost. Record the fallback in the
  summary.
- **Phase 7** — if `declare_aesop_rule_sets` cannot be made to work in either layout, revert the
  retag entirely and leave the `:50-53` docstring documenting the defect as it does today. Do not
  land a half-retagged file, and do not rewrite the docstring without the fix.
- **Phase 5** — if wiring the modules in surfaces build errors, revert the two imports; C6 stays
  FAIL and the blocker is escalated rather than worked around by editing
  `scripts/module-invariants-manifest.txt`, which would suppress the signal instead of fixing it.
- **Phases 1-3** — pure prose; `git checkout` of the single file restores it.

No `sorry` is introduced by any phase, and none of the approaches considered requires one.
