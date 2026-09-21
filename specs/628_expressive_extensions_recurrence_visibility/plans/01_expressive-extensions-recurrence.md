# Implementation Plan: Task #628

- **Task**: 628 - Expressive extensions that make recurrence and transposition visible (state nominals, state registers, propositional quantifiers)
- **Status**: [IMPLEMENTING]
- **Effort**: 15 hours
- **Dependencies**: Task 625 (completed; supplies the root-level language-component pattern and `paste`'s consumer precedent). Related, not blocking: 645 (translation-product port), 559, 624.
- **Research Inputs**: specs/628_expressive_extensions_recurrence_visibility/reports/01_expressive-extensions-recurrence.md; compiled probe specs/628_expressive_extensions_recurrence_visibility/probes/01_nominals-registers-quantifiers.lean
- **Artifacts**: plans/01_expressive-extensions-recurrence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research round answered Q1-Q5 with a sorry-free probe (856 lines, 92 declarations). This plan
ports that probe into the library as durable, gated code: one language-independent module
(`FormalSystem/Semantics/HistoryMorphism.lean`), one theorem in `Semantics/Truth.lean` (the
universal modality is definable in L), and two root-level object-language components,
`FormalSystem/HybridLanguage/` (L⁺ plus `[≡]`, state registers and the binder `↓`) and
`FormalSystem/QuantLanguage/` (L plus propositional quantifiers relative to an admissible family).
Definition of done: all 24 challenge statements below hold with the pinned signatures, zero
`sorry`, no new axiom, every repository gate green, and every uncompiled claim of the report
either compiled here or listed as "not formalized" in the component READMEs.

### Research Integration

- **Q1 (negative)** becomes `regFree_invariance` and `lifted_invariance`, stated against the
  abstract `HistMorphism` exactly as the probe does (report Decision 2).
- **Q2 (positive)** becomes `recF_defines`, `bindRec_defines`, `transF_valid`,
  `transF_refuted_distinct`, and the class-level refutations. Report Appendix B item 4 (the
  single `Iff` for `transF`) is upgraded from UNVERIFIED to a challenge statement,
  `transF_defines`; both directions are already compiled in the probe.
- **Q3** becomes `box_always_iff`, `isAtom_iff`, `qRec_defines`, `standard_not_invariant`.
- **Q4, Q5** are literature and design assessments; they produce no Lean. The component READMEs
  carry the "nominal for the quotient, not for points" caveat and the two blindness results, as
  report Recommendation 1 prescribes.

### Planning-time findings that change the research's siting (read before Phase 1)

1. **The probe no longer compiles against the source tree.** It imports
   `FormalSystem.Semantics.PlusLanguage.PlusValidity`, a path the language-directory merge
   removed two days after the research round. `lake env lean` on the probe still exits 0, but only
   because a stale `.olean` for the old path survives under `.lake/build`. The probe is a
   **mirror record of proofs**, never an import target; every statement below was re-typed
   against the live modules (`FormalSystem.PlusLanguage.*`) and type-checked at plan time.
2. **Siting.** The report proposed `Semantics/Extension/{HybridState,PropQuant}.lean`. That
   directory is the Extension Theorem for partial histories, and since the merge "every object
   language of this library is a self-contained directory at the library root under a flat
   namespace" (`FormalSystem/OpenLanguage.lean`). The two languages therefore land as
   `FormalSystem/HybridLanguage/` and `FormalSystem/QuantLanguage/`, modelled on
   `FormalSystem/OpenLanguage/`. **The task's declared `file_scope` in `specs/state.json` still
   names the `Semantics/Extension/` paths and should be refreshed from this plan's "Artifacts &
   Outputs" before implementation is dispatched** (lock-overlap detection reads it).
3. **`exists_splice` already exists.** It is `paste` with `paste_agreeUpTo` / `paste_agreeFrom`
   in `FormalSystem/PlusLanguage/PlusPasting.lean`. It is not ported; `transF_valid` consumes
   `paste`.
4. **`permZ` / `permHist` / `zSucc` / `zNoMax` already exist in better form.** `NF` and `natHist`
   of `FormalSystem/PlusLanguage/PlusNonValidities.lean` make every `ℤ → ℕ` a history. The
   distinct-state refutation is restated over `NF`; the instance-opacity workaround of report
   Appendix A is then needed only in `exists_sat_not_recurrenceFree`.
5. **Hand-rolled clause lemmas are not ported.** Both languages instantiate the abstract clause
   tiers of `Semantics/TruthClauses.lean` (`StabClauses` for the hybrid language with
   `Env F := ℕ → F.WorldState`, `UntlClauses` for the quantifier language with
   `Env F := Set (Set F.WorldState)`) and inherit `neg_iff`, `and_iff`, `or_iff`, `someFuture_iff`,
   `allFuture_iff`, `always_iff_tri` and the rest. Only the new-operator clauses and
   `univ_iff` / `exist_iff` are written by hand.
6. **The quantifier language is restated over `TaskModel`.** The probe evaluates against
   `V : ℕ → Set W`; the library's truth relations all take `M : TaskModel F` with
   `valuation : WorldState → Atom → Prop`. Letters become `Atom`, `∀p` re-interprets `p` through
   `TaskModel.updateAtom`, the fresh variable of `isAtom` becomes an explicit second atom with a
   hypothesis `p ≠ q`, and the admissible family is the inert environment. This is what lets
   `lifted_invariance` use the same `HistMap.pullM` as `regFree_invariance`, and what makes
   conservativity over L (`quantTruthAt_ofFormula`) statable. The probe's proofs transfer clause
   for clause (`pullV_update` becomes `pullM_updateAtom`, `fun _ => ∅` becomes
   `⟨fun _ _ => False⟩`).
7. **`box_always_iff` is two lines.** `Formula.always` is already `Hφ ∧ (φ ∧ Gφ)` and
   `Truth.always_iff` already collects it to `∀ s`; the probe's `fand_iff`, `fallFuture_iff`,
   `fallPast_iff` are not ported.

### Prior Plan Reference

No prior plan for this task. Effort and phase shape are calibrated against the completed
OpenLanguage plan (eight phases, 12.5 hours, about 1,700 lines), used as a reference for the
registration and gate mechanics only; no phase is copied from it.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch; no ROADMAP.md consulted.

## Goals & Non-Goals

**Goals**:
- The universal modality is definable in L: `box_always_iff`.
- Every frame class contains a frame with recurrence: `trivialFrame_not_recurrenceFree`,
  `exists_sat_not_recurrenceFree`.
- The hybrid state language extends L⁺ conservatively: `hybridTruthAt_ofPlus`,
  `hybridValidIn_ofPlus_iff`.
- Q1, first half, the same-state modality is invisible: `regFree_invariance`.
- Q2, recurrence is definable by one state register, free or bound: `recF_valid`,
  `recF_defines`, `bindRec_defines`, `recF_not_validIn`, `recF_validOnFrames_recurrenceFree`.
- Q2, transposition forces recurrence and is definable: `recurrenceFree_not_transposed`,
  `transF_valid`, `transF_refuted_of_recur`, `transF_defines`, `transF_refuted_distinct`,
  `transF_not_validIn`.
- The quantifier language extends L conservatively: `quantTruthAt_ofFormula`.
- Q1, second half, quantifiers over lifted propositions are invisible: `pullM_updateAtom`,
  `lifted_invariance`.
- Q3, the atom formula names a state and standard quantification sees recurrence: `isAtom_iff`,
  `qRec_valid`, `qRec_defines`, `standard_not_invariant`.

**Supporting declarations (delivered, but not challenge identifiers)**:
- Carriers, written out in full in the challenge preamble: `HistMap`, `HistMorphism`,
  `HistMap.mapH`, `HistMap.pullM`, `TaskFrame.RecurrenceFree`, `TaskModel.updateAtom`;
  `HybridFormula` with its derived operators, `univ`, `exist`, `recF`, `transF`, `RegFree`,
  `ofPlus`; `HybridTruthAt`; `TaskFrame.HybridValidOn`, `HybridValidOnFrames`, `HybridValidIn`,
  `HybridValid`; `QuantFormula` with its derived operators, `isAtom`, `qRec`, `ofFormula`;
  `QuantTruthAt`; `pulledBack`.
- Machinery: `HistMap.mapH_state`; the `TruthEnv`, `StabClauses` / `UntlClauses` and `PointTruth`
  instances; the `HybridTruth.*` clause lemmas (`same_iff`, `reg_iff`, `bind_iff`, `univ_iff`,
  `exist_iff`) and the `QuantTruth.*` ones (`all_iff`, `univ_iff`, `exist_iff`);
  `ofPlus_injective`; `bindRec_valid`; the `updateAtom` simp lemmas.
- Registration: layer-table rows, generated root, aggregators, READMEs, C14 axiom pins, `rfl`
  coincidence pins, two axiom-profile tests, the listing sweep.

**Non-Goals**:
- Any proof system, soundness or completeness claim for either language; any NAME or PASTE rule.
  Report §4-5 stay paper assessments.
- The class-level corollary "L⁺ + `[≡]` class validity equals validity over recurrence-free
  members" (report Appendix B item 1). It needs the translation product, which a separate port
  lands in `Semantics/Frames/TranslationProduct.lean`; it is recorded as "not formalized" with
  that reason.
- World registers, the strong-transposition formula, definability of `[≡]` and `↓` from
  quantifiers (report Appendix B items 2, 3, 5): listed as "not formalized", not proved.
- A validity layer for the quantifier language. Its results are frame-level; no theorem here
  quantifies over a frame class of quantifier models.
- Any edit to `FormalSystem/PlusLanguage/**`, `FormalSystem/OpenLanguage/**` (beyond one README
  row), `Syntax/`, `ProofSystem/`, or `Semantics/TruthClauses.lean`.
- Any manuscript edit (the manuscript lives outside this repository), any edit to the artifacts of
  the completeness research, and any prose edit to `typst/chapters/**`.
- New `references.bib` entries for works the literature corpus does not hold.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `Semantics/Truth.lean` edit forces a near-full rebuild while other sessions hold the build lock | M | H | The edit is one theorem appended inside the `Truth` namespace, committed alone as the first sub-step of Phase 1 with a 3600 s guarded build; every later phase builds leaf modules only |
| Stale `.olean` files make a wrong import path look green | H | M | Every phase gate is `lake build` of named targets through the guard (which resolves imports from source), never `lake env lean` on a file; Phase 1 greps the new modules for `Semantics.PlusLanguage` |
| The `TaskModel`-based restatement of the quantifier language breaks a probe proof | M | L | Statements type-checked at plan time; `pullM_updateAtom` is definitional; `isAtom_iff` needs `p ≠ q` exactly where the probe needed `n ≠ n + 1`. If a statement proves false as written, mark the phase `[BLOCKED]` per plan-compliance; do not weaken it |
| Instance search does not see through `TemporalOrder.of` carriers (report Appendix A) | L | H | Only `exists_sat_not_recurrenceFree` is affected; copy the probe's explicit `inferInstanceAs` arguments and import `Mathlib.Data.Int.SuccPred` |
| `simp` cannot match clause lemmas whose binder is typed at `NF.Duration` against a goal at `ℤ` | L | M | `transF_refuted_distinct` chains the `Iff` lemmas by hand, as the probe does |
| Registration files (`FormalSystem.lean`, the layer table, README inventories, root `README.md`) carry other sessions' uncommitted hunks | M | H | Stage explicit file lists only; under-stage rather than over-stage; a file carrying foreign hunks is left unstaged and named in the phase handoff |
| Readers import hybrid-logic results for point nominals wholesale | M | M | The quotient caveat, the non-duality of `A(i → ·)` and `E(i ∧ ·)`, and the two blindness results are mandatory docstring content (Phases 2, 5, 9) |
| A separate translation-product port lands its own recurrence predicate first | L | M | Phase 1 Scope Hypothesis: if one exists at implementation time, reuse it and make `TaskFrame.RecurrenceFree` an `abbrev` of it or drop the duplicate, recording the choice |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

Phases within the same wave can execute in parallel. The plan is fully sequential on purpose:
Phases 7-8 depend logically on Phase 1 only, but every module-adding phase edits the same
registration files (an aggregator, the per-file layer table, the generated root, a README
inventory), so two of them in one working tree would collide.

**Gate that closes every phase** (tiering governs in-phase granularity only; run detached with
`run_in_background`, and read the exit status from the guard itself, never from a pipeline):

```bash
bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem
grep -rn "sorry" FormalSystem/Semantics/HistoryMorphism.lean FormalSystem/HybridLanguage* FormalSystem/QuantLanguage*   # must print nothing
lake exe mk_all --lib FormalSystem --check
bash scripts/check-metalogic-cycles.sh
```

then one commit per phase, `task 628 phase {P}: {name}`, staging an explicit file list. Green
sub-steps inside a phase are committed as they happen.

**Conventions that bind every phase**: module docstring is the first command after the imports;
no broad `import Mathlib` / `import Lean`; no `def` or `abbrev` with an underscore in its own name
(C26); no task number and no manuscript line number in any file outside `specs/`; the manuscript
is cited by `\label` or quotable phrase; every `def:`/`thm:`/`lem:`/`cor:`/`app:` anchor cited
must resolve in `docs/reference/paper-definitions-of-record.md` (C15); `## References` blocks in
the normal form of `docs/development/REFERENCE_NORMAL_FORM.md` with keys resolving in
`references.bib` (`blackburn2002` is present; do not cite a work the corpus does not hold). Proofs
are transcribed from the probe and adapted, not rediscovered.

### Phase 1: The frame-level layer and the universal modality in L [COMPLETED]

**Goal**: Land everything language-independent: the theorem in `Truth.lean`, history-lifting
morphisms, recurrence-freeness and its class witnesses.

**Tasks**:
- [x] `FormalSystem/Semantics/Truth.lean`: inside `namespace Truth`, after `always_iff`, add
  `box_always_iff` with the pinned signature; proof is `box_iff` followed by
  `forall_congr'` over `always_iff`. **Untagged**: neither `@[simp]` nor `@[truth_norm]` (the
  simp set of the whole library must not change). Add its row to the module docstring's clause
  table. Docstring: the universal modality `A φ := □△φ` ranges over all (history, time) pairs,
  using only that `WorldHistory` is total; with a `Paper: —` line giving the reason. Build
  with `--timeout 3600`, commit alone as sub-step 1.1.
- [x] Create `FormalSystem/Semantics/HistoryMorphism.lean` (`namespace FormalSystem.Semantics`):
  `HistMap`, `HistMorphism` (`extends HistMap`), `HistMap.mapH` via `WorldHistory.ofTotal`,
  `@[simp] HistMap.mapH_state := rfl`, `HistMap.pullM`, `TaskFrame.RecurrenceFree`,
  `trivialFrame_not_recurrenceFree` (probe lines 425-436, with the constant history inlined or
  kept as a `private def`), `exists_sat_not_recurrenceFree` (probe lines 444-457 verbatim,
  including the explicit `inferInstanceAs` arguments). Library carriers are `def`, not `abbrev`.
- [x] Module docstring: a history-lifting morphism preserves pulled-back valuations, the
  history/time structure and the same-state relation, but **not state identity** (report §2.4);
  recurrence-freeness is the frame property that distinction is about; the translation
  projection is the intended instance and lives with the translation product, not here.
- [x] Register: import the module from `FormalSystem/Semantics.lean` and add it to that
  aggregator's submodule list; regenerate the root with `lake exe mk_all --lib FormalSystem`;
  `bash scripts/check-module-invariants.sh --emit-inventory` and fill the new description cell in
  `FormalSystem/Semantics/README.md`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: (a) No module under `FormalSystem/` already declares `HistMap`,
`HistMorphism` or a recurrence-freeness predicate; confirm with
`grep -rn "RecurrenceFree\|no_recurrence\|structure HistM" FormalSystem --include=*.lean`. A hit
means the translation-product port landed first: reuse its predicate and record the choice.
(b) A new file directly under `Semantics/` needs no per-file row in
`scripts/measure-refactor-partitions.py` (the directory row `"Semantics": 1` covers it); confirm
by `bash scripts/check-metalogic-cycles.sh` raising no `UnlayeredModuleError`.

**Files to modify**:
- `FormalSystem/Semantics/Truth.lean` - one theorem and one docstring-table row
- `FormalSystem/Semantics/HistoryMorphism.lean` - new
- `FormalSystem/Semantics.lean` - import and submodule-list entry
- `FormalSystem.lean` - regenerated, never hand-edited
- `FormalSystem/Semantics/README.md` - generated inventory row, description filled in

**Verification**:
- `grep -n "Semantics.PlusLanguage" FormalSystem/Semantics/HistoryMorphism.lean` prints nothing
- `lean_verify` on `FormalSystem.Semantics.Truth.box_always_iff` and
  `FormalSystem.Semantics.exists_sat_not_recurrenceFree`: standard axioms only, no `sorryAx`
- The phase-closing gate

---

### Phase 2: HybridLanguage scaffold and syntax [COMPLETED]

**Goal**: The component exists, is layered, aggregated and in the root closure from its first
commit, with `HybridFormula` as a layer-0 syntax file.

**Tasks**:
- [x] Create `FormalSystem/HybridLanguage/Formula.lean` (`namespace FormalSystem.HybridLanguage`),
  importing `FormalSystem.PlusLanguage.Formula` only: the ten-constructor inductive
  `HybridFormula` (`deriving DecidableEq`, and `Countable` as the sibling languages do); derived
  operators with **`PlusFormula`'s right-hand sides** (`top`, `neg`, `someFuture`, `somePast`,
  `allFuture`, `allPast`, `and`, `or`, `iff`, `diamond`, `always`, `sometimes`, `dstab`); then
  `univ`, `exist`, `recF`, `transF`, `RegFree`, `ofPlus` with the bodies fixed in the challenge
  preamble; `ofPlus_injective`; `regFree_ofPlus : (ofPlus φ).RegFree`.
- [x] Create the aggregator `FormalSystem/HybridLanguage.lean` with the component docstring:
  grammar; module list; design decisions in durable wording (a nominal is a **free register**, so
  nominals and registers are one language; an extension language, not semantic operators; a
  root-level component; semantic only); the caveat that a state nominal names a point of the
  quotient by same-state, not a point, so `A(i → ·)` and `E(i ∧ ·)` are not dual and hybrid-logic
  results for point nominals do not transfer; a "Not formalized" list.
- [x] Create `FormalSystem/HybridLanguage/README.md` modelled on
  `FormalSystem/OpenLanguage/README.md`, with a
  `<!-- BEGIN GENERATED: inventory dir=FormalSystem/HybridLanguage -->` block and a paper-label
  correspondence table started with the syntax rows (`sub:Extension` for the manuscript's
  registers, which store times and worlds, not states).
- [x] Add `"HybridLanguage": {"Formula": 0}` to `LANGUAGE_FILE_LAYERS` in
  `scripts/measure-refactor-partitions.py`; regenerate the root; emit the inventory and fill the
  description cells.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: The only mechanical consumers of the language-directory list are
`LANGUAGE_FILE_LAYERS` and C8's parent walk. Confirm with
`grep -n "LANGUAGE_FILE_LAYERS\|OpenLanguage" scripts/*.sh scripts/*.py scripts/lib/*.py`; any
other hard-coded tuple of the language directory names is extended in this phase.

**Files to modify**:
- `FormalSystem/HybridLanguage/Formula.lean`, `FormalSystem/HybridLanguage.lean`,
  `FormalSystem/HybridLanguage/README.md` - new
- `scripts/measure-refactor-partitions.py` - layer-table row
- `FormalSystem.lean` - regenerated; `FormalSystem/README.md` - generated inventory rows

**Verification**:
- `bash scripts/check-metalogic-cycles.sh` exits 0 with `HybridLanguage/Formula.lean` at layer 0
  (it imports nothing from `FormalSystem/Semantics/`)
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- The phase-closing gate

---

### Phase 3: Hybrid truth, validity and conservativity over L⁺ [COMPLETED]

**Goal**: The truth recursion with a register vector, the validity layer, and the theorem that
makes "extends L⁺" checkable.

**Tasks**:
- [x] `FormalSystem/HybridLanguage/HybridTruth.lean` (layer 1): `HybridTruthAt` with the ten
  clauses of the challenge preamble (the seven L⁺ clauses are `PlusTruthAt`'s verbatim). Instances
  `TruthEnv HybridFormula` with `Env F := ℕ → F.WorldState` and `StabClauses HybridFormula`, every
  clause `Iff.rfl`. `namespace HybridTruth`: `atom_iff`, `stab_iff`, `same_iff`, `reg_iff`,
  `bind_iff` by `Iff.rfl`; the derived-operator lemmas as one-line instantiations of
  `TruthClauses.*`; `univ_iff` (`□△φ` iff `φ` at every history and time; from the box clause,
  `always_iff_tri` and `lt_trichotomy`, as probe lines 225-237) and `exist_iff`.
- [x] `hybridTruthAt_ofPlus` by induction on `φ`; the register vector is inert because `ofPlus`
  produces no `reg`, `bind` or `same`.
- [x] `FormalSystem/HybridLanguage/HybridValidity.lean`: `instance : PointTruth HybridFormula`
  with `sat M τ t φ := ∀ r, HybridTruthAt M τ t r φ` (the L⋆ pattern);
  `TaskFrame.HybridValidOn`, `HybridValidOnFrames`, `HybridValidIn`, `HybridValid` with `mono`,
  `of_forall`, `apply`; `hybridValidOn_ofPlus_iff`, `hybridValidIn_ofPlus_iff`. The `←` direction
  of conservativity needs an inhabitant of `ℕ → G.WorldState`: use `fun _ => τ.state t`.
- [x] Layer rows `"HybridTruth": 1, "HybridValidity": 1`; aggregator imports; root; inventory.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/HybridLanguage/HybridTruth.lean`, `FormalSystem/HybridLanguage/HybridValidity.lean` - new
- `FormalSystem/HybridLanguage.lean`, `FormalSystem/HybridLanguage/README.md`,
  `scripts/measure-refactor-partitions.py`, `FormalSystem.lean`

**Verification**:
- `hybridTruthAt_ofPlus` and `hybridValidIn_ofPlus_iff` match the pinned signatures
- The phase-closing gate

---

### Phase 4: Q1 - the same-state modality is invisible [NOT STARTED]

**Goal**: `regFree_invariance`.

**Tasks**:
- [ ] `FormalSystem/HybridLanguage/HybridInvariance.lean`, importing `HybridTruth` and
  `Semantics.HistoryMorphism`: `regFree_invariance` by induction on `φ`, transcribed from probe
  lines 258-309. The `box` case uses `g.onto` and `WorldHistory.ext_state`; `stab` uses `g.lift`
  at the present time; `same` uses `g.lift` at the freed time `s`; `reg` and `bind` are
  `False.elim`.
- [ ] Corollary (one line, not a challenge identifier): invariance for `ofPlus φ` via
  `regFree_ofPlus`.
- [ ] Docstring: why `[≡]` tests state identity across times and still cannot see recurrence (it
  cannot tell `(τ, s)` from `(σ, s)` for another history through the same state; report §1.1);
  the class-level corollary is "not formalized" pending the translation product.
- [ ] Layer row, aggregator import, root, inventory, README correspondence row.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/HybridLanguage/HybridInvariance.lean` - new
- `FormalSystem/HybridLanguage.lean`, `FormalSystem/HybridLanguage/README.md`,
  `scripts/measure-refactor-partitions.py`, `FormalSystem.lean`

**Verification**:
- `lean_verify` on `regFree_invariance`: `[propext, Quot.sound]` expected (report Appendix A);
  record the measured profile for Phase 9's pin
- The phase-closing gate

---

### Phase 5: Q2 - recurrence is definable by one state register [NOT STARTED]

**Goal**: The recurrence formula defines recurrence-freeness, free or bound, and separates every
frame class from its recurrence-free members.

**Tasks**:
- [ ] `FormalSystem/HybridLanguage/HybridRecurrence.lean`: `recF_valid`, `bindRec_valid`,
  `recF_defines`, `bindRec_defines` (probe lines 318-361; the refuting assignment is
  `fun _ => τ.state s` and the model `⟨fun _ _ => False⟩`), stated through
  `TaskFrame.HybridValidOn`.
- [ ] `recF_not_validIn` from `exists_sat_not_recurrenceFree` and `recF_defines`;
  `recF_validOnFrames_recurrenceFree`.
- [ ] Docstring: **the minimal resource** is a state-identity test across two times of one
  history (report §2.4); every other clause tests state identity only up to the kernel of a
  history-lifting morphism. `Paper:` lines cite the manuscript's recurrence passage in
  `sec:Construction` by quotable phrase.
- [ ] Layer row, aggregator import, root, inventory, README correspondence rows.

**Timing**: 1.25 hours

**Depends on**: 4

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/HybridLanguage/HybridRecurrence.lean` - new
- `FormalSystem/HybridLanguage.lean`, `FormalSystem/HybridLanguage/README.md`,
  `scripts/measure-refactor-partitions.py`, `FormalSystem.lean`

**Verification**:
- The five challenge statements of this phase match the pinned signatures
- The phase-closing gate

---

### Phase 6: Q2 - transposition forces recurrence [NOT STARTED]

**Goal**: The transposition formula, its frame-level core, and the refutation with two distinct
named states.

**Tasks**:
- [ ] `FormalSystem/HybridLanguage/HybridTransposition.lean`, importing
  `FormalSystem.PlusLanguage.PlusPasting` and `FormalSystem.PlusLanguage.PlusNonValidities`.
  First the frame-level lemma `recurrenceFree_not_transposed`: time-shift `τ₂` by `s₂ - t₁`,
  `paste τ₁ (τ₂.timeShift (s₂ - t₁)) t₁`, read the shared state off at `s₁` (through
  `paste_agreeUpTo`) and at `t₁ + (t₂ - s₂)` (through `paste_agreeFrom`), contradict `hG` - the
  arithmetic of probe lines 410-420 with `paste` in place of `exists_splice`.
- [ ] `transF_valid` from that lemma after unfolding with `and_iff`, `exist_iff`,
  `someFuture_iff`, `reg_iff`. Follow this decomposition; do not inline the frame-level lemma.
- [ ] `transF_refuted_of_recur` (probe 474-480), `transF_defines` (`→` from
  `transF_refuted_of_recur` and `lt_or_gt_of_ne`, as the body of the probe's
  `transF_not_validIn`; `←` from `transF_valid`), `transF_not_validIn` from `transF_defines`.
- [ ] `transF_refuted_distinct` over `NF`: histories `natHist (fun x => if x = 0 then 1 else 0)`
  and `natHist (fun x => if x = 1 then 1 else 0)`, registers `fun n => if n = 0 then 1 else 0`,
  time `0`. Chain the clause `Iff`s by hand (probe lines 523-530); `simp` does not match across
  the `NF.Duration` / `ℤ` carrier.
- [ ] Docstring: any transposition, of equal or distinct states, forces a recurrence, so
  recurrence-free frames are transposition-free and the converse fails on the one-state frame;
  cite the manuscript's "chess games which transpose move order" passage and `app:gluing`.
- [ ] Layer row, aggregator import, root, inventory, README correspondence rows.

**Timing**: 1.75 hours

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/HybridLanguage/HybridTransposition.lean` - new
- `FormalSystem/HybridLanguage.lean`, `FormalSystem/HybridLanguage/README.md`,
  `scripts/measure-refactor-partitions.py`, `FormalSystem.lean`

**Verification**:
- The six challenge statements of this phase match the pinned signatures
- `git diff --stat` shows no edit under `FormalSystem/PlusLanguage/`
- The phase-closing gate

---

### Phase 7: QuantLanguage scaffold, syntax and truth [NOT STARTED]

**Goal**: The second component, registered from its first commit, with truth relative to an
admissible family and conservativity over L.

**Tasks**:
- [ ] `FormalSystem/QuantLanguage/Formula.lean` (layer 0, imports `FormalSystem.Syntax.Formula`
  only): seven-constructor `QuantFormula` with `all : Atom → QuantFormula → QuantFormula`;
  derived operators with `Formula`'s right-hand sides; `univ`, `exist`, `isAtom p q`, `qRec p q`,
  `ofFormula`, `ofFormula_injective`.
- [ ] `FormalSystem/QuantLanguage/QuantTruth.lean` (layer 1): `TaskModel.updateAtom` (in
  `namespace FormalSystem.Semantics`, housed here because this component is its only consumer)
  with `@[simp]` lemmas `updateAtom_valuation_self` and `updateAtom_valuation_of_ne`;
  `QuantTruthAt M τ t Adm`; instances `TruthEnv QuantFormula` with
  `Env F := Set (Set F.WorldState)` and `UntlClauses QuantFormula`; `namespace QuantTruth`:
  `atom_iff`, `all_iff`, `univ_iff`, `exist_iff`; `quantTruthAt_ofFormula` by induction (no `all`
  in the image, so `Adm` and `updateAtom` never fire).
- [ ] Aggregator `FormalSystem/QuantLanguage.lean` and `FormalSystem/QuantLanguage/README.md`:
  grammar; **the admissible family is the design** - `Set.univ` is the standard semantics, the
  preimage family along a morphism is the clock-independent one, and both are one recursion at
  two arguments; letters denote sets of world states (`def:BL-semantics`); semantic only; no
  validity layer, and why; "Not formalized" list.
- [ ] Layer rows `"QuantLanguage": {"Formula": 0, "QuantTruth": 1}`; root; inventory.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/QuantLanguage/Formula.lean`, `FormalSystem/QuantLanguage/QuantTruth.lean`,
  `FormalSystem/QuantLanguage.lean`, `FormalSystem/QuantLanguage/README.md` - new
- `scripts/measure-refactor-partitions.py`, `FormalSystem.lean`, `FormalSystem/README.md`

**Verification**:
- `quantTruthAt_ofFormula` matches the pinned signature
- `bash scripts/check-metalogic-cycles.sh` exits 0 with `QuantLanguage/Formula.lean` at layer 0
- The phase-closing gate

---

### Phase 8: Q1 and Q3 for quantifiers - lifted invariance, the atom formula, recurrence [NOT STARTED]

**Goal**: Quantifiers over lifted propositions are invisible; standard quantifiers manufacture a
state nominal and so see recurrence.

**Tasks**:
- [ ] `FormalSystem/QuantLanguage/QuantInvariance.lean`: `pulledBack`, `pullM_updateAtom`
  (`TaskModel` extensionality then `rfl`, or `rfl` outright), `lifted_invariance` by induction
  (probe lines 692-729 with `pullM_updateAtom` for `pullV_update`).
- [ ] `FormalSystem/QuantLanguage/QuantRecurrence.lean`, importing
  `FormalSystem.Semantics.Extension.Extension` for `PartialHistory.occurrence`: `isAtom_iff`
  (probe 781-799; `→` instantiates the quantifier at the singleton of the witness state, `←` gets
  `E p` from `cor:occurrence` and chooses the disjunct by `w ∈ S`; `hpq` is used exactly where the
  probe used `n ≠ n + 1`), `qRec_valid`, `qRec_defines`, `standard_not_invariant` (probe 802-852).
- [ ] Docstrings: `isAtom_iff` is the world-proposition construction read over sets of world
  states, so it names a **world state**, not an instant, and thereby exhibits what an instant
  cannot - recurrence; cite the manuscript's discussion in `sub:WorldStates` by quotable phrase
  rather than any work the corpus does not hold. `lifted_invariance` versus
  `standard_not_invariant` is the contrast the admissible family exists to state.
- [ ] Layer rows, aggregator imports, root, inventory, README correspondence rows.

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/QuantLanguage/QuantInvariance.lean`, `FormalSystem/QuantLanguage/QuantRecurrence.lean` - new
- `FormalSystem/QuantLanguage.lean`, `FormalSystem/QuantLanguage/README.md`,
  `scripts/measure-refactor-partitions.py`, `FormalSystem.lean`

**Verification**:
- The six challenge statements of this phase match the pinned signatures
- `lean_verify` on `lifted_invariance` (expected `[propext, Quot.sound]`), `qRec_defines`,
  `standard_not_invariant`; record the profiles
- The phase-closing gate

---

### Phase 9: Pins, tests, documentation sweep and the full gate [NOT STARTED]

**Goal**: Make the results durable and run every repository gate once.

**Tasks**:
- [ ] C14: append `regFree_invariance`, `recF_defines`, `transF_defines`, `lifted_invariance`,
  `qRec_defines`, `standard_not_invariant` (fully qualified) to **both** parallel lists in
  `scripts/check-module-invariants.sh` - the `#print axioms` block and the `C14_BASELINE`
  heredoc - in the same order, with the measured profiles.
- [ ] `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`: `section LHybrid` with the four
  `… = Generic… := rfl` validity pins and `LHybridOperators` / `LQuantOperators` sections with the
  derived-operator pins against `TruthClauses.*`, following `LOpen` / `LOpenOperators`.
- [ ] New `Tests/BimodalTest/Semantics/HybridLanguageAxiomTest.lean` and
  `QuantLanguageAxiomTest.lean` with `#guard_msgs in #print axioms` blocks for the pinned
  theorems; import both from `Tests/BimodalTest.lean`; rows in
  `Tests/BimodalTest/Semantics/README.md`.
- [ ] `docs/theorem-index.md`: a section per new language with one row per pinned theorem, and
  the `Paper: — (reason)` docstring line that index obliges.
- [ ] `docs/reference/paper-definitions-of-record.md`: `KNOWN-ANCHORS` rows for any anchor the
  new docstrings cite that has none yet.
- [ ] `FormalSystem/StarLanguage/README.md` and `FormalSystem/OpenLanguage/README.md`: the rows
  that record the manuscript's registers of `sub:Extension` as excluded gain one sentence - state
  registers, which the manuscript does not have, are formalized in `FormalSystem/HybridLanguage/`;
  the world registers stay excluded.
- [ ] Listing sweep: every prose listing of the object-language components gains the two new ones
  (root `README.md` tree, the "five object languages" heading and table, `ORGANISATION.md`,
  `docs/ARCHITECTURE.md`, `docs/development/MODULE_ORGANIZATION.md`,
  `docs/development/MODULE_INVARIANTS.md`, the docstring and comments of
  `scripts/measure-refactor-partitions.py` and `scripts/check-metalogic-cycles.sh`,
  `FormalSystem/README.md`, `FormalSystem/Semantics/README.md`). Re-measure any layer figure
  before restating it; do not restate a figure that was not re-measured.
- [ ] Each component README gets its final "Not formalized" table: report Appendix B items 1-7,
  each with its reason; nothing uncompiled is stated as a result.
- [ ] `bash scripts/typst-sync-check.sh`: if Check 2 reports count drift caused by the new
  modules, regenerate `typst/generated/status.typ` with its generator; leave
  `typst/chapters/**` untouched.
- [ ] Full gates: `bash scripts/check-module-invariants.sh` (with build),
  `bash scripts/check-metalogic-cycles.sh`, guarded `lake build FormalSystem BimodalTest`,
  `lake exe mk_all --lib FormalSystem --check`.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: The listing sweep touches the documents named above. Confirm with
`grep -rln "OpenLanguage" --include="*.md" --include="*.py" --include="*.sh" . | grep -v "^./specs/\|^./.lake\|^./.claude\|^./agent-system"`;
a hit that lists the language components and is not named above is added, a hit that merely cites
one Open module is left alone, and `typst/chapters/ax-lean-appendix.typ` is left alone whatever it
says (it carries another task's uncommitted edits). The layer figures after this task are
hypothesized as 16 files at layer 0 and 29 at layer 1; confirm against the final
`LANGUAGE_FILE_LAYERS`.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C14 pins, both lists
- `Tests/BimodalTest/Semantics/ValidityLayerTest.lean`,
  `Tests/BimodalTest/Semantics/HybridLanguageAxiomTest.lean` (new),
  `Tests/BimodalTest/Semantics/QuantLanguageAxiomTest.lean` (new), `Tests/BimodalTest.lean`,
  `Tests/BimodalTest/Semantics/README.md`
- `docs/theorem-index.md`, `docs/reference/paper-definitions-of-record.md`,
  `FormalSystem/StarLanguage/README.md`, `FormalSystem/OpenLanguage/README.md`
- `README.md`, `ORGANISATION.md`, `docs/ARCHITECTURE.md`,
  `docs/development/MODULE_ORGANIZATION.md`, `docs/development/MODULE_INVARIANTS.md`,
  `scripts/measure-refactor-partitions.py` (docstring), `scripts/check-metalogic-cycles.sh`
  (comments), `FormalSystem/README.md`, `FormalSystem/Semantics/README.md`,
  `FormalSystem/HybridLanguage/README.md`, `FormalSystem/QuantLanguage/README.md`
- `typst/generated/status.typ` - only if Check 2 drifts

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0, the six new C14 rows echoed as matched
- Guarded `lake build FormalSystem BimodalTest` green
- `grep -rn "task 628\|Task 628\|#628" FormalSystem Tests docs scripts README.md ORGANISATION.md`
  prints nothing
- The phase-closing gate

## Lean Challenge Statements

**Authoring note.** The snapshot tool's declaration matcher recognizes
`theorem|lemma|def|instance` followed by a *simple* name, forces that declaration's body to
`sorry`, and discards everything between the `:=` and the next matched declaration. The block is
shaped so that nothing is lost: every carrier sits in the preamble as `structure`, `inductive` or
`abbrev` (none is matched, so the bodies survive and stay out of the identifier set), no theorem
name is dotted, and no `namespace` / `end` follows the first theorem - the final namespace is left
open on purpose. Consequences for the implementer: **the library declares the carriers with
`def`**, not `abbrev`; the library's frame-level validity is `TaskFrame.HybridValidOn` in
`FormalSystem.Semantics` for dot notation, where the challenge writes the undotted
`HybridValidOn`; and the theorems live in their components' namespaces
(`FormalSystem.Semantics.Truth`, `FormalSystem.Semantics`, `FormalSystem.HybridLanguage`,
`FormalSystem.QuantLanguage`), where the challenge states them flat in one. The block was
type-checked standalone against the live source modules at plan time (`lake env lean`, exit 0, 24
`sorry` warnings, no error).

```lean
import Mathlib.Algebra.Order.Archimedean.Real.Basic
import Mathlib.Data.Int.SuccPred
import FormalSystem.PlusLanguage.PlusPasting
import FormalSystem.PlusLanguage.PlusNonValidities
import FormalSystem.Semantics.Extension.Extension

namespace FormalSystem.Semantics

/-- A history-lifting map between two task frames over one temporal order. -/
structure HistMap {D : TemporalOrder} (F' F : FrameOver D) where
  toFun : F'.WorldState → F.WorldState
  forth : ∀ a x b, F'.TaskRel a x b → F.TaskRel (toFun a) x (toFun b)
  lift : ∀ (τ : WorldHistory F.toTaskFrame) (a : F'.WorldState) (t : ↑D),
    toFun a = τ.state t →
      ∃ τ' : WorldHistory F'.toTaskFrame, τ'.state t = a ∧ ∀ s, toFun (τ'.state s) = τ.state s

/-- A history-lifting morphism: a history-lifting map that is onto histories. -/
structure HistMorphism {D : TemporalOrder} (F' F : FrameOver D) extends HistMap F' F where
  onto : ∀ τ : WorldHistory F.toTaskFrame,
    ∃ τ' : WorldHistory F'.toTaskFrame, ∀ s, toFun (τ'.state s) = τ.state s

abbrev HistMap.mapH {D : TemporalOrder} {F' F : FrameOver D} (g : HistMap F' F)
    (τ' : WorldHistory F'.toTaskFrame) : WorldHistory F.toTaskFrame :=
  WorldHistory.ofTotal _ (fun t => g.toFun (τ'.state t))
    (fun s t => g.forth _ _ _ (τ'.respects_task s t))

abbrev HistMap.pullM {D : TemporalOrder} {F' F : FrameOver D} (g : HistMap F' F)
    (M : TaskModel F.toTaskFrame) : TaskModel F'.toTaskFrame :=
  ⟨fun a p => M.valuation (g.toFun a) p⟩

/-- No world history visits a world state twice. -/
abbrev TaskFrame.RecurrenceFree (G : TaskFrame) : Prop :=
  ∀ (τ : WorldHistory G) (s t : G.Duration), τ.state s = τ.state t → s = t

/-- Replace the truth set of one sentence letter by a set of world states. -/
abbrev TaskModel.updateAtom {G : TaskFrame} (M : TaskModel G) (p : Syntax.Atom)
    (S : Set G.WorldState) : TaskModel G :=
  ⟨fun w q => if q = p then w ∈ S else M.valuation w q⟩

end FormalSystem.Semantics

namespace FormalSystem.HybridLanguage

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

/-- L⁺ plus the same-state modality `[≡]`, state registers and the state binder `↓`. -/
inductive HybridFormula : Type where
  | atom : Atom → HybridFormula
  | bot : HybridFormula
  | imp : HybridFormula → HybridFormula → HybridFormula
  | box : HybridFormula → HybridFormula
  | untl : HybridFormula → HybridFormula → HybridFormula
  | snce : HybridFormula → HybridFormula → HybridFormula
  | stab : HybridFormula → HybridFormula
  | same : HybridFormula → HybridFormula
  | reg : ℕ → HybridFormula
  | bind : ℕ → HybridFormula → HybridFormula

namespace HybridFormula

abbrev top : HybridFormula := HybridFormula.bot.imp HybridFormula.bot
abbrev neg (φ : HybridFormula) : HybridFormula := φ.imp bot
abbrev someFuture (φ : HybridFormula) : HybridFormula := HybridFormula.untl HybridFormula.top φ
abbrev somePast (φ : HybridFormula) : HybridFormula := HybridFormula.snce HybridFormula.top φ
abbrev allFuture (φ : HybridFormula) : HybridFormula := (someFuture φ.neg).neg
abbrev allPast (φ : HybridFormula) : HybridFormula := (somePast φ.neg).neg
abbrev and (φ ψ : HybridFormula) : HybridFormula := (φ.imp ψ.neg).neg
abbrev or (φ ψ : HybridFormula) : HybridFormula := φ.neg.imp ψ
abbrev always (φ : HybridFormula) : HybridFormula := φ.allPast.and (φ.and φ.allFuture)
/-- The universal modality `A φ := □△φ`. -/
abbrev univ (φ : HybridFormula) : HybridFormula := φ.always.box
/-- `E φ := ¬A¬φ`. -/
abbrev exist (φ : HybridFormula) : HybridFormula := (univ φ.neg).neg
/-- `¬(i ∧ (P i ∨ F i))`. -/
abbrev recF (i : ℕ) : HybridFormula :=
  ((reg i).and ((somePast (reg i)).or (someFuture (reg i)))).neg
/-- `¬(E(i ∧ F j) ∧ E(j ∧ F i))`. -/
abbrev transF (i j : ℕ) : HybridFormula :=
  ((exist ((reg i).and (someFuture (reg j)))).and
    (exist ((reg j).and (someFuture (reg i))))).neg

/-- The register-free fragment: L⁺ plus `[≡]`. -/
abbrev RegFree : HybridFormula → Prop
  | atom _ => True
  | bot => True
  | imp a b => RegFree a ∧ RegFree b
  | box a => RegFree a
  | untl a b => RegFree a ∧ RegFree b
  | snce a b => RegFree a ∧ RegFree b
  | stab a => RegFree a
  | same a => RegFree a
  | reg _ => False
  | bind _ _ => False

abbrev ofPlus : PlusFormula → HybridFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (ofPlus φ) (ofPlus ψ)
  | .box φ => .box (ofPlus φ)
  | .untl ψ φ => .untl (ofPlus ψ) (ofPlus φ)
  | .snce ψ φ => .snce (ofPlus ψ) (ofPlus φ)
  | .stab φ => .stab (ofPlus φ)

end HybridFormula

abbrev HybridTruthAt {G : TaskFrame} (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration)
    (r : ℕ → G.WorldState) : HybridFormula → Prop
  | .atom p => M.valuation (τ.state t) p
  | .bot => False
  | .imp φ ψ => HybridTruthAt M τ t r φ → HybridTruthAt M τ t r ψ
  | .box φ => ∀ σ : WorldHistory G, HybridTruthAt M σ t r φ
  | .untl ψ φ => ∃ s : G.Duration, t < s ∧ HybridTruthAt M τ s r φ ∧
      ∀ u : G.Duration, t < u → u < s → HybridTruthAt M τ u r ψ
  | .snce ψ φ => ∃ s : G.Duration, s < t ∧ HybridTruthAt M τ s r φ ∧
      ∀ u : G.Duration, s < u → u < t → HybridTruthAt M τ u r ψ
  | .stab φ => ∀ σ : WorldHistory G, τ.state t = σ.state t → HybridTruthAt M σ t r φ
  | .same φ => ∀ (σ : WorldHistory G) (s : G.Duration), σ.state s = τ.state t →
      HybridTruthAt M σ s r φ
  | .reg i => τ.state t = r i
  | .bind i φ => HybridTruthAt M τ t (Function.update r i (τ.state t)) φ

abbrev HybridValidOn (G : TaskFrame) (φ : HybridFormula) : Prop :=
  ∀ (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration) (r : ℕ → G.WorldState),
    HybridTruthAt M τ t r φ
abbrev HybridValidOnFrames (P : TaskFrame → Prop) (φ : HybridFormula) : Prop :=
  ∀ G : TaskFrame, P G → HybridValidOn G φ
abbrev HybridValidIn (fc : ProofSystem.FrameClass) (φ : HybridFormula) : Prop :=
  HybridValidOnFrames fc.Sat φ

end FormalSystem.HybridLanguage

namespace FormalSystem.QuantLanguage

open FormalSystem.Syntax FormalSystem.Semantics

/-- L plus propositional quantifiers `∀p`. -/
inductive QuantFormula : Type where
  | atom : Atom → QuantFormula
  | bot : QuantFormula
  | imp : QuantFormula → QuantFormula → QuantFormula
  | box : QuantFormula → QuantFormula
  | untl : QuantFormula → QuantFormula → QuantFormula
  | snce : QuantFormula → QuantFormula → QuantFormula
  | all : Atom → QuantFormula → QuantFormula

namespace QuantFormula

abbrev top : QuantFormula := QuantFormula.bot.imp QuantFormula.bot
abbrev neg (φ : QuantFormula) : QuantFormula := φ.imp bot
abbrev someFuture (φ : QuantFormula) : QuantFormula := QuantFormula.untl QuantFormula.top φ
abbrev somePast (φ : QuantFormula) : QuantFormula := QuantFormula.snce QuantFormula.top φ
abbrev allFuture (φ : QuantFormula) : QuantFormula := (someFuture φ.neg).neg
abbrev allPast (φ : QuantFormula) : QuantFormula := (somePast φ.neg).neg
abbrev and (φ ψ : QuantFormula) : QuantFormula := (φ.imp ψ.neg).neg
abbrev or (φ ψ : QuantFormula) : QuantFormula := φ.neg.imp ψ
abbrev always (φ : QuantFormula) : QuantFormula := φ.allPast.and (φ.and φ.allFuture)
abbrev univ (φ : QuantFormula) : QuantFormula := φ.always.box
abbrev exist (φ : QuantFormula) : QuantFormula := (univ φ.neg).neg
/-- `Atom(p) := E p ∧ ∀q (A(p → q) ∨ A(p → ¬q))`. -/
abbrev isAtom (p q : Atom) : QuantFormula :=
  (exist (atom p)).and (all q ((univ ((atom p).imp (atom q))).or
    (univ ((atom p).imp (atom q).neg))))
/-- `∀p (Atom(p) → ¬(p ∧ (P p ∨ F p)))`. -/
abbrev qRec (p q : Atom) : QuantFormula :=
  all p ((isAtom p q).imp ((atom p).and ((somePast (atom p)).or (someFuture (atom p)))).neg)

abbrev ofFormula : Formula → QuantFormula
  | .atom p => .atom p
  | .bot => .bot
  | .imp φ ψ => .imp (ofFormula φ) (ofFormula ψ)
  | .box φ => .box (ofFormula φ)
  | .untl ψ φ => .untl (ofFormula ψ) (ofFormula φ)
  | .snce ψ φ => .snce (ofFormula ψ) (ofFormula φ)

end QuantFormula

/-- Truth relative to a family `Adm` of admissible propositions (sets of world states). -/
abbrev QuantTruthAt {G : TaskFrame} (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration)
    (Adm : Set (Set G.WorldState)) : QuantFormula → Prop
  | .atom p => M.valuation (τ.state t) p
  | .bot => False
  | .imp φ ψ => QuantTruthAt M τ t Adm φ → QuantTruthAt M τ t Adm ψ
  | .box φ => ∀ σ : WorldHistory G, QuantTruthAt M σ t Adm φ
  | .untl ψ φ => ∃ s : G.Duration, t < s ∧ QuantTruthAt M τ s Adm φ ∧
      ∀ u : G.Duration, t < u → u < s → QuantTruthAt M τ u Adm ψ
  | .snce ψ φ => ∃ s : G.Duration, s < t ∧ QuantTruthAt M τ s Adm φ ∧
      ∀ u : G.Duration, s < u → u < t → QuantTruthAt M τ u Adm ψ
  | .all p φ => ∀ S, S ∈ Adm → QuantTruthAt (M.updateAtom p S) τ t Adm φ

/-- The lifted (clock-independent along `g`) propositions: preimages of state sets. -/
abbrev pulledBack {D : TemporalOrder} {F' F : FrameOver D} (g : HistMap F' F) :
    Set (Set F'.WorldState) :=
  {S | ∃ T : Set F.WorldState, S = g.toFun ⁻¹' T}

end FormalSystem.QuantLanguage

namespace FormalSystem.Challenge

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.HybridLanguage FormalSystem.QuantLanguage

/-! The universal modality in the base language. -/

theorem box_always_iff {F : TaskFrame} {M : TaskModel F} {τ : WorldHistory F} {t : F.Duration}
    (φ : Formula) :
    TruthAt M τ t φ.always.box ↔ ∀ (σ : WorldHistory F) (s : F.Duration), TruthAt M σ s φ := sorry

/-! Frames with recurrence at every class tag. -/

theorem trivialFrame_not_recurrenceFree {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] :
    ¬ (FrameOver.trivialFrame (D := D)).toTaskFrame.RecurrenceFree := sorry

theorem exists_sat_not_recurrenceFree (fc : ProofSystem.FrameClass) :
    ∃ G : TaskFrame, fc.Sat G ∧ ¬ G.RecurrenceFree := sorry

/-! The hybrid state language: conservativity, invariance, definability. -/

theorem hybridTruthAt_ofPlus {G : TaskFrame} (M : TaskModel G) (τ : WorldHistory G)
    (t : G.Duration) (r : ℕ → G.WorldState) (φ : PlusFormula) :
    HybridTruthAt M τ t r (HybridFormula.ofPlus φ) ↔ PlusTruthAt M τ t φ := sorry

theorem hybridValidIn_ofPlus_iff (fc : ProofSystem.FrameClass) (φ : PlusFormula) :
    HybridValidIn fc (HybridFormula.ofPlus φ) ↔ PlusValidIn fc φ := sorry

theorem regFree_invariance {D : TemporalOrder} {F' F : FrameOver D} (g : HistMorphism F' F)
    (M : TaskModel F.toTaskFrame) :
    ∀ (φ : HybridFormula), φ.RegFree → ∀ (τ' : WorldHistory F'.toTaskFrame) (t : ↑D)
      (r' : ℕ → F'.WorldState) (r : ℕ → F.WorldState),
      HybridTruthAt (g.pullM M) τ' t r' φ ↔ HybridTruthAt M (g.mapH τ') t r φ := sorry

theorem recF_valid {G : TaskFrame} (hG : G.RecurrenceFree) (M : TaskModel G)
    (τ : WorldHistory G) (t : G.Duration) (r : ℕ → G.WorldState) (i : ℕ) :
    HybridTruthAt M τ t r (HybridFormula.recF i) := sorry

theorem recF_defines (G : TaskFrame) (i : ℕ) :
    HybridValidOn G (HybridFormula.recF i) ↔ G.RecurrenceFree := sorry

theorem bindRec_defines (G : TaskFrame) (i : ℕ) :
    HybridValidOn G (HybridFormula.bind i (HybridFormula.recF i)) ↔ G.RecurrenceFree := sorry

theorem recurrenceFree_not_transposed {G : TaskFrame} (hG : G.RecurrenceFree)
    (τ₁ τ₂ : WorldHistory G) {s₁ t₁ s₂ t₂ : G.Duration} (h₁ : s₁ < t₁) (h₂ : s₂ < t₂)
    (hi : τ₁.state s₁ = τ₂.state t₂) (hj : τ₁.state t₁ = τ₂.state s₂) : False := sorry

theorem transF_valid {G : TaskFrame} (hG : G.RecurrenceFree) (M : TaskModel G)
    (τ : WorldHistory G) (t : G.Duration) (r : ℕ → G.WorldState) (i j : ℕ) :
    HybridTruthAt M τ t r (HybridFormula.transF i j) := sorry

theorem transF_refuted_of_recur {G : TaskFrame} (τ : WorldHistory G) {s t : G.Duration}
    (hst : s < t) (h : τ.state s = τ.state t) :
    ∃ (M : TaskModel G) (r : ℕ → G.WorldState),
      ¬ HybridTruthAt M τ s r (HybridFormula.transF 0 1) := sorry

theorem transF_defines (G : TaskFrame) :
    HybridValidOn G (HybridFormula.transF 0 1) ↔ G.RecurrenceFree := sorry

theorem transF_refuted_distinct :
    ∃ (M : TaskModel NF) (τ : WorldHistory NF) (t : NF.Duration) (r : ℕ → NF.WorldState),
      r 0 ≠ r 1 ∧ ¬ HybridTruthAt M τ t r (HybridFormula.transF 0 1) := sorry

theorem recF_not_validIn (fc : ProofSystem.FrameClass) (i : ℕ) :
    ¬ HybridValidIn fc (HybridFormula.recF i) := sorry

theorem recF_validOnFrames_recurrenceFree (fc : ProofSystem.FrameClass) (i : ℕ) :
    HybridValidOnFrames (fun G => fc.Sat G ∧ G.RecurrenceFree) (HybridFormula.recF i) := sorry

theorem transF_not_validIn (fc : ProofSystem.FrameClass) :
    ¬ HybridValidIn fc (HybridFormula.transF 0 1) := sorry

/-! The propositional-quantifier language. -/

theorem quantTruthAt_ofFormula {G : TaskFrame} (M : TaskModel G) (τ : WorldHistory G)
    (t : G.Duration) (Adm : Set (Set G.WorldState)) (φ : Formula) :
    QuantTruthAt M τ t Adm (QuantFormula.ofFormula φ) ↔ TruthAt M τ t φ := sorry

theorem pullM_updateAtom {D : TemporalOrder} {F' F : FrameOver D} (g : HistMap F' F)
    (M : TaskModel F.toTaskFrame) (p : Atom) (T : Set F.WorldState) :
    g.pullM (M.updateAtom p T) = (g.pullM M).updateAtom p (g.toFun ⁻¹' T) := sorry

theorem lifted_invariance {D : TemporalOrder} {F' F : FrameOver D} (g : HistMorphism F' F) :
    ∀ (φ : QuantFormula) (M : TaskModel F.toTaskFrame) (τ' : WorldHistory F'.toTaskFrame)
      (t : ↑D),
      QuantTruthAt (g.pullM M) τ' t (pulledBack g.toHistMap) φ ↔
        QuantTruthAt M (g.mapH τ') t Set.univ φ := sorry

theorem isAtom_iff {G : TaskFrame} (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration)
    {p q : Atom} (hpq : p ≠ q) :
    QuantTruthAt M τ t Set.univ (QuantFormula.isAtom p q) ↔
      ∃ w, M.valuation w p ∧
        ∀ (ρ : WorldHistory G) (s : G.Duration), M.valuation (ρ.state s) p → ρ.state s = w :=
  sorry

theorem qRec_valid {G : TaskFrame} (hG : G.RecurrenceFree) (M : TaskModel G)
    (τ : WorldHistory G) (t : G.Duration) {p q : Atom} (hpq : p ≠ q) :
    QuantTruthAt M τ t Set.univ (QuantFormula.qRec p q) := sorry

theorem qRec_defines (G : TaskFrame) {p q : Atom} (hpq : p ≠ q) :
    (∀ (M : TaskModel G) (τ : WorldHistory G) (t : G.Duration),
      QuantTruthAt M τ t Set.univ (QuantFormula.qRec p q)) ↔ G.RecurrenceFree := sorry

theorem standard_not_invariant {D : TemporalOrder} {F' F : FrameOver D}
    (g : HistMorphism F' F) (hF' : F'.toTaskFrame.RecurrenceFree)
    (hF : ¬ F.toTaskFrame.RecurrenceFree) :
    ¬ ∀ (φ : QuantFormula) (M : TaskModel F.toTaskFrame) (τ' : WorldHistory F'.toTaskFrame)
        (t : ↑D),
      QuantTruthAt (g.pullM M) τ' t Set.univ φ ↔ QuantTruthAt M (g.mapH τ') t Set.univ φ :=
  sorry
```

## Testing & Validation

- [ ] Guarded `lake build FormalSystem` green and zero `sorry` under the three new locations at
  the end of **every** phase
- [ ] All 24 challenge identifiers exist with the pinned statements (modulo the `abbrev`/`def`,
  dotted-validity and namespace differences the authoring note records)
- [ ] `lean_verify` on every pinned theorem: standard axioms only (`propext`, `Classical.choice`,
  `Quot.sound`), no `sorryAx`, no new axiom
- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0: the upward allowlist unchanged, both new
  `Formula.lean` files at layer 0
- [ ] `lake exe mk_all --lib FormalSystem --check` exits 0
- [ ] `bash scripts/check-module-invariants.sh` exits 0, including the six new C14 pins
- [ ] Guarded `lake build BimodalTest` green, including the `LHybrid` `rfl` pins and the two
  axiom-profile tests
- [ ] No task number and no manuscript line number in any file outside `specs/`
- [ ] No new module imports a `FormalSystem.Semantics.PlusLanguage.*` path
- [ ] `git diff --stat` over the task shows no edit to a pre-existing Lean module other than
  `Semantics/Truth.lean`, `Semantics.lean`, the generated root and the planned test files

## Artifacts & Outputs

New Lean modules:
- `FormalSystem/Semantics/HistoryMorphism.lean`
- `FormalSystem/HybridLanguage.lean`, `FormalSystem/HybridLanguage/{Formula,HybridTruth,HybridValidity,HybridInvariance,HybridRecurrence,HybridTransposition}.lean`
- `FormalSystem/QuantLanguage.lean`, `FormalSystem/QuantLanguage/{Formula,QuantTruth,QuantInvariance,QuantRecurrence}.lean`
- `Tests/BimodalTest/Semantics/{HybridLanguageAxiomTest,QuantLanguageAxiomTest}.lean`

New documents: `FormalSystem/HybridLanguage/README.md`, `FormalSystem/QuantLanguage/README.md`.

Edited: `FormalSystem/Semantics/Truth.lean`, `FormalSystem/Semantics.lean`, `FormalSystem.lean`
(generated), `scripts/measure-refactor-partitions.py`, `scripts/check-module-invariants.sh`,
`scripts/check-metalogic-cycles.sh`, `Tests/BimodalTest.lean`,
`Tests/BimodalTest/Semantics/ValidityLayerTest.lean`, `Tests/BimodalTest/Semantics/README.md`,
`README.md`, `ORGANISATION.md`, `FormalSystem/README.md`, `FormalSystem/Semantics/README.md`,
`FormalSystem/StarLanguage/README.md`, `FormalSystem/OpenLanguage/README.md`,
`docs/ARCHITECTURE.md`, `docs/theorem-index.md`, `docs/development/MODULE_ORGANIZATION.md`,
`docs/development/MODULE_INVARIANTS.md`, `docs/reference/paper-definitions-of-record.md`, and
`typst/generated/status.typ` only on count drift.

**Not touched, although the task's declared `file_scope` names them**:
`FormalSystem/Semantics/Extension.lean`, `FormalSystem/Semantics/Extension/README.md`,
`FormalSystem/Semantics/Extension/HybridState.lean`,
`FormalSystem/Semantics/Extension/PropQuant.lean`.

Task artifacts: this plan; `summaries/01_expressive-extensions-recurrence-summary.md`.

## Rollback/Contingency

Every phase is one or more self-contained commits that add leaf modules and registration rows, so
a committed phase is undone with `git revert` of its commits, newest first; reverting Phase 1's
`Truth.lean` commit is safe at any time because nothing else in this plan consumes
`box_always_iff`. If the quantifier component stalls, Phases 1-6 stand on their own: close the
hybrid component with Phase 9's tasks restricted to it and leave Phases 7-8 `[PARTIAL]` or
`[BLOCKED]` with the goal state recorded. A challenge statement that turns out unprovable as
written is a `[BLOCKED]` phase raised to the user, never a silently weakened signature. On a build
error, fix forward; never discard uncommitted work to reach a green build. If a genuine rollback
of uncommitted work is ever required, follow the snapshot-then-rollback rung of
`.claude/context/contracts/recovery.md`, including its out-of-scope override for the whole-tree
case; a routine defensive checkpoint before risky work uses the `--no-revert` form instead.
