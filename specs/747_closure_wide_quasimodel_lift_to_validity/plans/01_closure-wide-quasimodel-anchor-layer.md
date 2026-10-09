# Implementation Plan: Task #747

- **Task**: 747 - Requirement (W) of the ray-product verdict: a closure-wide quasimodel over all seams and times, lifting per-seam results to validity
- **Status**: [IMPLEMENTING]
- **Effort**: 8.5 hours (5 phases; lean4, each phase sized to one agent run)
- **Dependencies**: 745 (C) `[COMPLETED]` — `HitPresented` holds on model A non-constructively, no bound; 746 (S) `[COMPLETED]` — `presented_modelOf` for `box`/`stab`-free `φ` at one seam under `Cons`. Both outcomes were checked before this plan was written (see Overview); neither refutes, so the record is planned rather than closed.
- **Research Inputs**: specs/747_closure_wide_quasimodel_lift_to_validity/reports/01_closure-wide-quasimodel-characterization.md
- **Artifacts**: plans/01_closure-wide-quasimodel-anchor-layer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, reference-grounding.md (lean4 override, Tier 1), anti-analysis.md (lean4 override), wrap-up.md, plan-compliance.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The record asks for ONE finite object that witnesses `¬ PlusValidZTime φ` for some regular
ℤ-model, history and time — carrying the `box` anchor "for every time, across the whole slice"
and the `stab` anchor "for every state", nested under `untl`/`snce` — and it asks that the
object's SHAPE be characterized and costed before anything is built. The research dispatch did
the characterization with three compiled scratch files, and the shape it found is a **two-layer
object**, not the single object the record imagined:

- An **anchor layer**: by `box_time_invariant` (compiled, research F1) `□ψ` has ONE truth value
  per model on every `TaskFrame`, and by `stab_state_only` (in tree) `⊡ψ` is a function of the
  world state alone. So the "for every time" quantifier the record names does not exist in this
  semantics; the anchor layer is a set of **cells** (the closure types realized at a world
  state), a subset of `𝒫(𝒫(cl φ))` with a syntactic bound `2^(2^|cl φ|)`, satisfying two
  fixpoint equations (`box`, `stab`) and the Hintikka clauses — all of them direct unfoldings of
  truth clauses, decidable on a concrete finite object, and non-vacuous.
- A **run layer**: the `untl`/`snce` nesting, which lives in type sequences over ℤ. Here the
  semantics parts from HWZ 2000 Def. 12: HWZ chooses the run set `R` freely and builds the model
  ON `R`, whereas this semantics fixes the histories as ALL bi-infinite step paths of a frame
  (`mem_HF_iff_adjacent`), closed under splicing (`seamOmegaEquiv`) and under limits of chains
  (`blc_plusValid`). The run layer is therefore the path set of a yet-to-be-constructed
  infinite-width, finitely branching regular frame — and the research proved, on two independent
  axes, that (S)'s construction cannot be it: `modelOf_incomplete` (finite width; every `Cons`
  model validates the ℤ-time non-validity `Φ.neg` of `NoFiniteWidth.lean`) and
  `stab_iff_of_presented_nowUnique` (trace-level `Presented` with (S)'s necessary `nowUnique`
  collapses `ψ ↔ ⊡ψ` at the seam, so no `⊡`-refutation such as `Fp → ⊡Fp` is ever witnessed).

This plan lands the anchor layer and the machine-checked verdict on the run layer, which is the
record's second acceptance branch and the one it names as "a complete outcome for a first
round". Phase 1 lands the quantifier collapse in the library; Phase 2 wires the two obstruction
theorems as a probe; Phases 3-4 build the closure-wide anchor layer as a new module
`RaySummary/AnchorLayer.lean` — closure types, cells, the fixpoint equations, the finite object
`AnchorCons` with its completeness theorem for EVERY model (no presentation hypothesis), its
`2^(2^|cl φ|)` bound and a decidable `Finset`-level checker with a non-vacuous `#guard` witness;
Phase 5 records the run layer as blocked on three NAMED obligations and runs the full gate.

**No run-layer construction phase is planned** (research R5): the three obligations — (i) a
frame-scheme constructor producing infinite-width, finitely branching regular frames from a
finite object; (ii) the Hit-level product summary per cell, never `Presented`; (iii) the
presentation-size bound `kTypeOf_listSeg_replicate_eventually_periodic`, stated in the README and
unproved — have no measured cost anywhere in the tree, and the record forbids inheriting a figure
from (C) or (S). Planning them would be exactly the "figure from nowhere" the record forbids.

**Definition of done**: Phases 1-5 compile sorry-free on the standard profile
`[propext, Classical.choice, Quot.sound]`, every Goal pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`; the `AnchorConsFin` witness and its
negative control pass as `#guard`s; the new probe is green under
`scripts/check-evidence-probes.sh`; the theorem index, the `RaySummary/` README, the aggregator
and the ROADMAP say exactly what landed and what did not. `Decidable (PlusValidZTime φ)` is NEVER
stated in any form: without a bound on the run layer, "∃ finite object refuting `φ`" is at best
semi-decidable, and the only `Decidable` instance this plan lands is on a concrete `Finset`
object (`AnchorConsFin`), which is a statement about a finite set and not about L⁺.

### Research Integration

From `reports/01_closure-wide-quasimodel-characterization.md`. Every substrate declaration this
plan cites was re-resolved BY NAME during planning (`grep -n` on the source tree): `box_iff`,
`stab_iff`, `imp_iff`, `atom_iff`, `neg_iff` (`PlusTruth.lean`, `namespace PlusTruth`),
`plusTruthAt_timeShift` and `stab_state_only` (`PlusTruth.lean`, top-level namespace
`FormalSystem.PlusLanguage`), `WorldHistory.timeShift_state` (`Semantics/PartialHistory.lean`,
`rfl`), `plusSubformulaClosure : PlusFormula → Finset PlusFormula` with `plusClosure_box`,
`plusClosure_stab`, `plusClosure_imp_left/right` (`Subformulas.lean`), `PlusFormula` deriving
`DecidableEq` (`PlusLanguage/Formula.lean`), `Anchored` (`Closure.lean`), `Presented`
(`Trace.lean`), `Cons`/`frameOf`/`modelOf` (`Realize.lean`), `NoFiniteWidth.Φ`,
`no_finite_width_sat`, `not_plusValidZTime_neg_Φ`, `not_finite_width_fmp`
(`Limits/NoFiniteWidth.lean`), `PlusValidZTime`, `PlusValidInt`, `plusValidZTime_iff_plusValidInt`
(`PlusValidity.lean`, `PlusIntTransfer.lean`), `seamOmegaEquiv`, `SeqPair`, `spliced`. Zero
drift found; no line number from the report or the dispatch is carried into this plan. Mathlib
helpers for Phase 4 were resolved against the pinned checkout: `Set.Finite.powerset`,
`Set.ncard_powerset`, `Set.ncard_coe_finset`, `Finset.coe_powerset`, `Finset.card_powerset`.

- **F1 (compiled): `box` is a per-model datum.** `box_time_invariant` / `box_global` compile
  against `PlusTruth.lean` in 20 lines on the standard profile. Phase 1 lands them beside
  `stab_state_only`. Consequence carried into the module docstrings: `Anchored.box`'s `∀ z` is
  redundant, and the record's "for every time" quantifier is dropped on the strength of a
  theorem, not an argument.
- **F2/F3 (in tree + unfolding): the anchor layer's equations.** Cells are time-independent by
  `plusTruthAt_timeShift`; `box`/`stab` membership in a closure type is a fixpoint over the cells
  by `box_iff`+F1 and `stab_iff`+`stab_state_only`. Phases 3-4 state these on `Finset`-valued
  closure types (`tpOf := (plusSubformulaClosure φ).filter (PlusTruthAt M σ z ·)` under
  classical decidability), which keeps the cardinality bound a two-step `Finset.card_powerset`
  computation (the research's named `Set`/`Finset` plumbing risk, pre-empted by the choice of
  carrier).
- **F4/F5 (compiled): (S) is not the soundness half of (W).** Both theorems compile against the
  landed `Realize.lean`/`Trace.lean` with no new lemma; Phase 2 wires them verbatim. Their
  headers must say (S) is untouched — `presented_modelOf` is a correct soundness statement for
  `box`/`stab`-free `φ` at one seam — and that nothing here is a negative decidability result.
- **F6/F7/F8: the run layer is blocked, not open-ended.** Phase 5 rewrites the README (W) row from
  "nothing in the tree composes" to "anchor layer landed and bounded; run layer blocked on three
  named obligations", each with its source: (i) successor of the 746 probe
  `b2b-frame-constructor-branching.lean` (`Rbad`/`Rok` refuted; the `Node` thread-unfolding
  shape of `NoFiniteWidth.lean` is neither refuted nor built; the ~120-160 line figure for the
  REGULARITY part is CARRIED-UNVERIFIED from the README's "(S): what landed and what did not"
  and scoped to that part only); (ii) the per-cell Hit-level summary — (C)'s realization
  hypothesis at every cell (`HitPresented`, family-triple SETS), never `Presented` (F5);
  (iii) the bound, `kTypeOf_listSeg_replicate_eventually_periodic`, stated in the README under
  "The bound: blocked" and not proved.
- **R6: state nothing decidable.** Honoured by every phase's verification criteria (a targeted
  grep over every touched file, read hit by hit).

### Prior Plan Reference

No prior plan. The sibling plan `specs/746_*/plans/01_hit-level-soundness-b2b.md` was consulted
for calibration only: its probe-wiring phase (predicted 175-200 lines, measured 283; gate-script
catalogue entry predicted 12-18 lines, measured 57) says probe headers and catalogue entries run
~1.5-3x longer than a first estimate, and its Phase 8 says the final gate set includes
`scripts/check-module-invariants.sh` (red in six groups on entry there) and a separate
`BimodalTest` build, because `defaultTargets = ["FormalSystem"]` never elaborates the test
library's `#guard`s. Both lessons are applied below (Phase 2's band is widened; Phase 5 names the
test build and `check-module-invariants.sh` explicitly).

### Roadmap Alignment

`specs/ROADMAP.md` names this record under "`/orchestrate 747 --hard --lit` — (W), gated on 745
and 746 … its phase 1 is characterization". This plan is that characterization's output. Phase 5
rewrites the (W) bullet: anchor layer landed and bounded; run layer blocked on three named
obligations; no decidability statement; and a note that the record's "for every time" quantifier
was dropped by theorem (F1). No roadmap phases are mandated for this dispatch (no `roadmap_flag`);
the ROADMAP edit is one task of the records phase, as it was for (S).

## Goals & Non-Goals

- **Goals**: `box_time_invariant`, `box_global`, `tpOf`, `mem_tpOf_iff`, `tpOf_timeShift`,
  `cellAt`, `cellAt_eq_cellAt`, `bot_not_mem_tpOf`, `imp_mem_tpOf_iff`, `box_mem_tpOf_iff`,
  `stab_mem_tpOf_iff`, `anchorCells`, `AnchorCons`, `anchorCons_anchorCells`,
  `anchorCells_finite`, `anchorCells_ncard_le`, `AnchorConsFin`, `decidableAnchorConsFin`,
  `anchorConsFin_iff`
- Goals, stated in prose (not Challenge-pinned): the wired verdict probe
  `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean` holding
  `modelOf_not_sat_Φ`, `modelOf_sat_neg_Φ`, `modelOf_incomplete`, `exists_spliced_eq`,
  `presented_letter_at_seam`, `stab_of_presented_nowUnique`, `stab_iff_of_presented_nowUnique`
  with its house header and registry entry; the `AnchorConsFin` non-vacuity `#guard` witness
  (a cell carrying TWO types at one state, the shape `Presented`+`nowUnique` can never produce)
  and its negative control; axiom pins for every Goal; theorem-index rows; the `RaySummary/`
  README (W) row and section rewrite plus the `Closure.lean` row note on F1 and the refreshed
  line-count table; the `RaySummary.lean` aggregator import and bullet; the ROADMAP (W) bullet.
- **Non-Goals**:
  - **The run layer**, in any form: no frame-scheme constructor, no per-cell Hit-level summary,
    no presentation-size bound, no `untl`/`snce` composition theorem across seams. These are
    recorded as the three named obligations (Phase 5), each with its source and, where one
    exists, its carried figure; none is costed here, because none has a measured cost anywhere
    (research R5, the record's "do not inherit a figure from (C) or (S)").
  - **`Decidable (PlusValidZTime φ)` in any form**, any `Decidable` instance about a MODEL, any
    search over anchor objects presented as a decision procedure, any "L⁺ is decidable" sentence.
    The one `Decidable` instance landed (`decidableAnchorConsFin`) is on a concrete
    `Finset (Finset (Finset PlusFormula))` and says nothing about L⁺.
  - **Any complexity bound**, upper or lower. `anchorCells_ncard_le` is a cardinality bound on
    a SET OF CELLS, syntactic in `|cl φ|`; it is not a bound on any procedure's running time and
    the records must not describe it as one. The ARGUED CTL⋆ 2EXPTIME ceiling is never quoted
    except with its ARGUED qualifier.
  - **Any negative decidability result.** Every record states that THIS presentation / THIS
    object does not deliver the decision procedure, never that none exists.
  - **Requirements (C) and (S)** (tasks 745, 746 — both complete, neither re-opened); the mosaic
    route (734), the backward mirror falsifier (733), the three-state E2 falsifier (739); task
    742's landed device; task 735's verdict and both wired probes. Nothing landed is retired,
    weakened or re-proved: `Presented`, `presented_modelOf`, `hitCl_modelOf_eq_hitOf`, `Cons`,
    `frameOf`/`modelOf`, `no_finite_width_sat`, `not_plusValidZTime_neg_Φ`, `seamOmegaEquiv`,
    `spliced`, `stab_state_only` are cited by name, none re-proved.
  - **A backward Bool-fixture bridge.** None exists; every header says the fixtures are
    forward-only and `⊡(Pp)` is fixed only by the asymmetric fixture
    (`Probe719Backward.pastStab_iff_allBwdPathsMeet`).
  - **Any finite-fibre or finite-width assumption** on a model. `AnchorCons` is a property of a
    finite set of cells; `anchorCons_anchorCells` holds for EVERY model (it is the completeness
    direction of the anchor layer and carries no presentation, no `[Finite W]`, no
    `[Fintype Q]`). `not_finite_width_fmp` is not contradicted and is cited in the README text.
  - **Any cslib `require` edge or copied declaration.**
  - **Modifying `Anchored`** in `Closure.lean`. F1 shows its `box` field's `∀ z` is redundant,
    but the structure is pinned and consumed by `Trace.lean`'s uniqueness theorem; the redundancy
    is recorded in the README's `Closure.lean` row, not repaired.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The `Set`/`Finset` plumbing for `anchorCells_ncard_le` costs more than estimated (research's named risk) — classical decidability of `PlusTruthAt`, nested powersets | M | M | Closure types are `Finset`-valued from the start (`tpOf` as `Finset.filter` under `open Classical in`), so a cell is a `Set (Finset PlusFormula)` and the bound is `Set.ncard_le_ncard` into `𝒫 ↑(cl.powerset)` followed by `Set.ncard_powerset`, `Set.ncard_coe_finset`, `Finset.card_powerset` — five named Mathlib lemmas, all resolved in the pinned checkout. If `ncard_powerset`'s `toFinite_tac` autoparam does not fire, pass `(Finset.finite_toSet _).powerset` explicitly. If the bound still resists, land `anchorCells_finite` green, commit, and close Phase 4 `[PARTIAL]` with the bound as the one open item — the completeness theorem does not depend on it |
| `decidableAnchorConsFin` is not found by instance search for the nested bounded quantifiers (`∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ cl φ, … → (… ↔ ∀ T' ∈ C, …)`) | M | M | Every quantifier in `AnchorConsFin` is bounded by a `Finset` (`Finset.decidableDforallFinset`) and every atom is a `Finset` membership on `PlusFormula` with derived `DecidableEq`; the instance is `decidable_of_iff` on the five-field conjunction, the pattern `Realize.lean` uses for `UCoh`/`ULive`. If search stalls on one field, give that field its own named `instance` first |
| The `#guard` witness does not reduce (`decide` over `Finset`-of-`Finset` literals on `PlusFormula`) | M | L | `KTypeFinEvalTest.lean` already `#guard`s `(hitOf …).card = 2` and `live` over a closure-signature presentation, so kernel evaluation of `Finset` operations on this formula type is established. The witness is tiny (`φ := ⊡p`, closure `{⊡p, p}`, three cells). If it still stalls, state it as `example : AnchorConsFin … := by decide` with a raised `maxRecDepth`; if THAT fails, record it in the issue log and keep the positive witness as a term-mode proof — the negative control must still be an evaluated refutation |
| Shared-file contention: `scripts/check-evidence-probes.sh` with task 734 (`[PARTIAL]`, an implementer live this cycle) and `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` / `docs/theorem-index.md` / `RaySummary/README.md` with any sibling records | M | M | `file_scope` is declared (Artifacts & Outputs). The gate script is touched in Phase 2 only and the axiom test in Phase 5 only, both append-only; re-read each file immediately before editing and stage only this task's own hunks — never a directory or glob `git add`. No edit to `mosaic-stab-saturated.lean` or `backward-dual-mirror-fixture.lean` |
| A reader takes `modelOf_incomplete` as retiring (S), or F8 as a negative decidability result | H | M | The probe header, the README (W) section and the theorem-index rows each carry the two sentences verbatim: "(S) is untouched — `presented_modelOf` is a correct soundness statement for `box`/`stab`-free `φ` at one seam; F4 says only that its frame SHAPE cannot be the whole soundness half of a lift for `box`/`stab`-bearing L⁺" and "this presentation/object does not deliver the decision procedure; nothing here says none exists". Phase 5's verification greps for `Decidable`, `decidable`, `EXPSPACE`, `PSPACE`, `complexity` over every touched file and reads every hit |
| A same-named weaker statement lands under a true-looking name (`anchorCons_anchorCells` with a hidden presentation hypothesis; `anchorConsFin_iff` with the image on the wrong side) | H | L | `## Lean Challenge Statements` pins every Goal's signature; `plan-compliance.md`'s Statement Fidelity section governs. `anchorCons_anchorCells` quantifies over `(M : TaskModel F.toTaskFrame)` with NO further hypothesis, and that absence is the point of the theorem |
| `AnchorLayer.lean` imports pull `PlusTruth`'s new theorems before Phase 1 is committed, or the aggregator import creates a cycle | L | L | Phase 3 depends on Phase 1 (wave order enforces it). The module imports only `RaySummary.Closure` (for the closure alphabet's neighbours and the `FrameOver intOrder` conventions) and `PlusLanguage.PlusTruth`; nothing under `RaySummary/` imports `AnchorLayer` until Phase 5's aggregator edit, so a cycle is impossible before the final phase and surfaces in the full build there |
| README line counts drift again (table says Realize 953 / Compose 298; `wc -l` at research time gave 1004 / 297) | L | H | Phase 5 refreshes the whole table from `wc -l` at implementation time and marks the change as a documentation correction; no count from this plan is written into the README |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 3 |
| 4 | 5 | 2, 4 |

Phases within the same wave can execute in parallel. Phase 5 is the final phase: it is the only
terminal node and depends, directly or transitively, on every other phase.

### Phase 1: Land the quantifier collapse — `box` is a per-model datum [COMPLETED]

**Goal**: Put research F1 in the library beside `stab_state_only`, so the record's "for every
time, across the whole slice" quantifier is dropped by a theorem every later module can cite.

**Tasks**:
- [x] Append to `FormalSystem/PlusLanguage/PlusTruth.lean`, immediately after `stab_state_only`
      and before `end FormalSystem.PlusLanguage`, the two theorems pinned below:
      `box_time_invariant` (`□ψ` has the same truth value at any two times along one history)
      and `box_global` (along any two histories at any two times). Proofs as compiled in
      `specs/747_closure_wide_quasimodel_lift_to_validity/evidence/01_box-time-invariant.lean`:
      `PlusTruth.box_iff` twice, then `plusTruthAt_timeShift` on `σ.timeShift (s - t)` and
      `add_sub_cancel`; `box_global` is `box_time_invariant` followed by `Iff.rfl`.
- [x] Docstrings in the house voice of `stab_state_only`'s: state that this holds on EVERY
      `TaskFrame` because the history set is shift-closed by construction (not only on regular
      ℤ-frames), and state the consequence for the ray-product device — `Anchored.box`'s `∀ z`
      (`RaySummary/Closure.lean`) is redundant, the `box`-letters of any closure-wide object are
      `|{box ψ ∈ cl φ}|` global bits, and the "for every time" quantification of requirement (W)
      does not exist in this semantics.
- [x] Confirm no existing declaration is named `box_time_invariant` or `box_global` anywhere
      under `FormalSystem/` or `Tests/` (planning-time grep: none), so no downstream `open`
      becomes ambiguous.
- [x] Build the module and its test consumer:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- build FormalSystem.PlusLanguage.PlusTruth`
      exits 0; `#print axioms` on both shows exactly `[propext, Classical.choice, Quot.sound]`.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The edit appends two theorems to one module without changing any
existing signature, so `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- build
FormalSystem.PlusLanguage.PlusTruth` plus the name-collision grep covers its whole blast radius;
downstream modules see only two new names that nothing yet references.

**Scope Hypothesis**: ~25-40 lines appended (20 lines of Lean as compiled plus docstrings).
Confirm by `git diff --stat` on `PlusTruth.lean` at phase end; a diff touching any line above
`stab_state_only` means an existing declaration was edited, which this phase forbids.

**Files to modify**:
- `FormalSystem/PlusLanguage/PlusTruth.lean` - append `box_time_invariant`, `box_global` with docstrings

**Verification**:
- The scoped build of `FormalSystem.PlusLanguage.PlusTruth` exits 0.
- `#print axioms FormalSystem.PlusLanguage.box_time_invariant` and `… box_global` are exactly
  `[propext, Classical.choice, Quot.sound]`.
- `bash .claude/scripts/lean-sorry-census.sh` reports zero sorries in `PlusTruth.lean`.
- The diff is append-only below `stab_state_only`.

---

### Phase 2: Wire the (W) verdict probe — (S)'s shape cannot be the soundness half [COMPLETED]

**Goal**: Preserve research F4 and F5 as a wired, rotting-protected probe, so the record's
acceptance clause ("the obstruction MACHINE-CHECKED as a theorem or a wired probe rather than
argued in prose") is met by an artifact the gate compiles on every run.

**Tasks**:
- [x] Create `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean` in
      `namespace Probe747`, holding verbatim the declarations of
      `specs/747_closure_wide_quasimodel_lift_to_validity/evidence/02_modelOf-finite-width-incomplete.lean`
      (`modelOf_not_sat_Φ`, `modelOf_sat_neg_Φ`, `modelOf_incomplete`) and of
      `…/evidence/03_stab-collapse-presented-nowUnique.lean` (`exists_spliced_eq`,
      `presented_letter_at_seam`, `stab_of_presented_nowUnique`,
      `stab_iff_of_presented_nowUnique`), with both import lines
      (`RaySummary.Realize`, `PlusSlicedCertificate.Limits.NoFiniteWidth`, `RaySummary.Trace`)
      and a `#print axioms` foot for every declaration. Keep the compiled tactic shapes recorded
      in the research report's Tactic Survey (the explicit section-variable arguments to
      `no_finite_width_sat`; the `StabFibre` ascription in `exists_spliced_eq`).
- [x] Write the house probe header (model: `presented-not-complete.lean` — paragraphs "The
      fixture / The argument / What is established / What is NOT established / The decision held
      in place"), stating: (i) VERDICT — requirement (S)'s construction `modelOf` cannot be the
      soundness half of (W) for `box`/`stab`-bearing L⁺, on two independent axes; (ii) WIDTH —
      `frameOf` is `ofSlicedStep` on a finite `Q`, so `no_finite_width_sat` applies verbatim and
      every `Cons` model VALIDATES `Φ.neg`, a ℤ-time non-validity
      (`not_plusValidZTime_neg_Φ`), whatever clauses are added to `Cons`; (iii) COLLAPSE — at any
      `Presented` seam whose presentation marks at most one `now` state (exactly
      `Cons.nowUnique`, which (S) found necessary), every closure formula satisfies `ψ ↔ ⊡ψ`, so
      no `⊡`-refutation such as `Fp → ⊡Fp` (refuted on model A and, as `refute_determined`, on
      `natFrame`) is ever witnessed — independent of width; (iv) WHAT IS NOT ESTABLISHED — (S) is
      UNTOUCHED (`presented_modelOf` is a correct soundness statement for `box`/`stab`-free `φ`
      at one seam); nothing is a negative decidability result; nothing about `⊡(Pp)` (forward-only,
      no backward Bool-fixture bridge); nothing about `HitPresented`, which holds on model A
      non-constructively (`Probe745.hitPresented_modelA`) and remains the realization hypothesis
      (W) may use; no complexity bound; (v) THE DECISION — the (W) realization hypothesis must be
      Hit-level or product-level per cell, never trace-level `Presented`, and the (W) frame must
      have infinite-width slices (the `Node` shape of `NoFiniteWidth.lean`, which `ofSlicedStep`
      cannot build).
- [x] Register `"seam-gluing-ray-product/w-soundness-shape-refuted"` in
      `scripts/check-evidence-probes.sh`'s `WIRED` array, append-only at the end, and add the
      matching catalogue comment block beside the `hit-presented-model-a` and
      `b2b-frame-constructor-branching` entries, in the same 38-character-column house format
      (verdict label, what it shows, what it does not). Re-read the script immediately before
      editing (task 734 shares it) and stage only this hunk.
- [x] Run `bash scripts/check-evidence-probes.sh`; confirm exit 0 and the new probe green along
      with every pre-existing one, and confirm append-only editing from the diff (insertions
      only, zero deletions) rather than from a predicted count.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The edit is one new probe file plus an append-only registry entry, and
`bash scripts/check-evidence-probes.sh` compiles every registered probe with `lake env lean` and
exits non-zero on any failure — that one command is the complete covering check; nothing under
`FormalSystem/` is touched, so no library build can regress.

**Scope Hypothesis**: ~230-320 lines in the probe (116 carried from the two scratch files, a
house header of 80-120 lines by the measured precedent of 746's Phase 1 — 91 lines — plus the
axiom foot) and ~45-65 lines of catalogue plus the one `WIRED` entry in the gate script (746's
measured 57, not its predicted 12-18). The `WIRED` array held 25 entries at planning time
(`grep -c '"seam-gluing-ray-product/'` = 18 of them in this group) — a hypothesis; confirm by the
script's own count line and by `git diff --stat` showing zero deletions.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean` - new probe
- `scripts/check-evidence-probes.sh` - append the registry entry and the catalogue comment block

**Verification**:
- `bash scripts/check-evidence-probes.sh` exits 0 and reports the new probe green.
- `#print axioms` for `Probe747.modelOf_incomplete` and `Probe747.stab_iff_of_presented_nowUnique`
  show exactly `[propext, Classical.choice, Quot.sound]`.
- `grep -c sorry` = 0 in the new probe (comments excluded by reading the hits).
- The header contains, legibly inside the artifact, the sentences that (S) is untouched and that
  nothing here is a negative decidability result; `grep -n "Decidable\|decidable"` over the probe
  returns only those negative statements.
- `git diff --stat` shows no modification to any other probe.

---

### Phase 3: `AnchorLayer.lean` — closure types, cells, and the fixpoint equations [NOT STARTED]

**Goal**: Read the anchor layer off a model: the closure type of a point, the cell of a world
state, their time-independence, and the four equations (`bot`, `imp`, `box`, `stab`) a closure
type satisfies by the truth clauses alone — the closure-wide counterpart of `Anchored` and
`LocalRun.bot/imp`, stated on types rather than on one seam's colouring.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean` with the house
      copyright header, imports `FormalSystem.Metalogic.Decidability.RaySummary.Closure` and
      `FormalSystem.PlusLanguage.PlusTruth`, `namespace FormalSystem.Metalogic.Decidability.RaySummary`,
      the `open` lines of `Closure.lean`, and `variable {F : FrameOver intOrder}`. State in the
      module header that nothing in this module uses `[F.IsRegular]` (the anchor layer is a
      consequence of shift-closure and the truth clauses on every ℤ-frame; the regular case is an
      instance, and the record's `[F.IsRegular]` is the minimum hypothesis a CLAIM about validity
      must carry, not a hypothesis these definitions need), and that the module states nothing
      about `PlusValidZTime` and nothing decidable about a model.
- [ ] Define `tpOf` (pinned below): `open Classical in noncomputable def tpOf (M) (φ) (σ) (z : ℤ)
      : Finset PlusFormula := (plusSubformulaClosure φ).filter (fun ψ => PlusTruthAt M σ z ψ)`,
      with `mem_tpOf_iff` (`Finset.mem_filter`) and the subset lemma
      `tpOf M φ σ z ⊆ plusSubformulaClosure φ` (`Finset.filter_subset`; a plain `theorem`, not a
      Goal).
- [ ] Prove `tpOf_timeShift` (pinned): `tpOf M φ (σ.timeShift Δ) z = tpOf M φ σ (z + Δ)`, by
      `Finset.ext` + `mem_tpOf_iff` + `plusTruthAt_timeShift`.
- [ ] Define `cellAt` (pinned): the set of closure types realized at world state `w` at time `z`,
      `{T | ∃ σ, σ.state z = w ∧ tpOf M φ σ z = T}`, and prove `cellAt_eq_cellAt` (pinned): for
      all `z z'`, `cellAt M φ w z = cellAt M φ w z'` — both inclusions by `σ ↦ σ.timeShift (z - z')`
      with `WorldHistory.timeShift_state` (`rfl`) and `tpOf_timeShift`. This is research F2's
      time-independence and the reason a cell is a per-STATE datum.
- [ ] Prove the four equations (pinned): `bot_not_mem_tpOf` (`PlusFormula.bot ∉ tpOf M φ σ z`,
      from the definitional `bot` clause); `imp_mem_tpOf_iff` (for `h : .imp ψ χ ∈ cl φ`,
      `.imp ψ χ ∈ tpOf ↔ (ψ ∈ tpOf → χ ∈ tpOf)`, from `PlusTruth.imp_iff` with
      `plusClosure_imp_left/right`); `box_mem_tpOf_iff` (for `h : .box ψ ∈ cl φ`,
      `.box ψ ∈ tpOf M φ σ z ↔ ∀ σ' z', ψ ∈ tpOf M φ σ' z'`, from `PlusTruth.box_iff`,
      `box_time_invariant` and `plusClosure_box` — the closure-wide `Anchored.box` with the
      per-time quantifier gone); `stab_mem_tpOf_iff` (for `h : .stab ψ ∈ cl φ`,
      `.stab ψ ∈ tpOf M φ σ z ↔ ∀ σ', σ.state z = σ'.state z → ψ ∈ tpOf M φ σ' z`, from
      `PlusTruth.stab_iff` and `plusClosure_stab` — the closure-wide `Anchored.stab`).
- [ ] Scoped build: `bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- build
      FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer` exits 0; `#print axioms` on
      every theorem of the module is the standard profile.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: This phase creates one new module that nothing imports until Phase 5's
aggregator edit, so the scoped build `bash .claude/scripts/lake-build-guard.sh build --timeout
900 -- build FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer` is the complete covering
check; no existing signature changes and no consumer can regress.

**Scope Hypothesis**: ~150-220 lines (module header 40-60, nine declarations with docstrings
90-140, following the research's "every clause is an unfolding of a truth clause" estimate of
300-450 for Phases 3-4 together). Confirm by `wc -l` at phase end; a module over ~280 lines means
an equation needed an induction the research did not predict, which must be recorded in the
issue log before continuing.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean` - new module: `tpOf`, `mem_tpOf_iff`, `tpOf_timeShift`, `cellAt`, `cellAt_eq_cellAt`, `bot_not_mem_tpOf`, `imp_mem_tpOf_iff`, `box_mem_tpOf_iff`, `stab_mem_tpOf_iff`

**Verification**:
- The scoped build of `RaySummary.AnchorLayer` exits 0 with zero sorries
  (`bash .claude/scripts/lean-sorry-census.sh`).
- Every declaration's `#print axioms` is exactly `[propext, Classical.choice, Quot.sound]`.
- `grep -n "IsRegular\|Fintype\|Finite W\|PlusValidZTime\|Decidable" AnchorLayer.lean` returns
  only header prose saying these are absent, read hit by hit.
- No definition has a vacuous body (`:= True`, `:= Unit`, `:= trivial`).

---

### Phase 4: The finite anchor object — `AnchorCons`, completeness for every model, the bound, and the decidable checker [NOT STARTED]

**Goal**: The bounded, non-vacuous half of (W): a finite object (a set of cells) with the
box/stab/Hintikka equations as its consistency conditions; the theorem that EVERY model's cells
satisfy them, with no presentation and no finiteness hypothesis on the model; the one bound (W)
can state honestly, `|cells| ≤ 2^(2^|cl φ|)`; and a `Finset`-level checker with a `Decidable`
instance, a non-vacuous witness and a negative control.

**Tasks**:
- [ ] Define `anchorCells` (pinned): `Set.range (fun w : F.WorldState => cellAt M φ w 0)`, the
      set of cells of a model (time `0` by `cellAt_eq_cellAt`), with a membership lemma.
- [ ] Define the `Prop`-structure `AnchorCons φ (𝒞 : Set (Set (Finset PlusFormula)))` (pinned)
      with five fields, each quantifying over `cl φ` so that the `Finset` twin below is decidable
      field-for-field: `closure` (every type in every cell is `⊆ cl φ`); `bot` (`bot ∉ T`);
      `imp` (`∀ ψ ∈ cl φ, ∀ χ ∈ cl φ, .imp ψ χ ∈ cl φ → (.imp ψ χ ∈ T ↔ (ψ ∈ T → χ ∈ T))`);
      `box` (`∀ ψ ∈ cl φ, .box ψ ∈ cl φ → (.box ψ ∈ T ↔ ∀ C' ∈ 𝒞, ∀ T' ∈ C', ψ ∈ T')` — the
      global bit); `stab` (`∀ ψ ∈ cl φ, .stab ψ ∈ cl φ → (.stab ψ ∈ T ↔ ∀ T' ∈ C, ψ ∈ T')` —
      the per-cell bit). Docstring: these are `Anchored.box`/`Anchored.stab`/`LocalRun.bot`/
      `LocalRun.imp` on types instead of one seam's colouring; the `untl`/`snce` nesting is NOT
      here — it is the run layer, blocked (README).
- [ ] Prove `anchorCons_anchorCells` (pinned): `AnchorCons φ (anchorCells M φ)` for EVERY
      `M : TaskModel F.toTaskFrame` — field by field from Phase 3's four equations plus
      `tpOf`'s subset lemma; the `box` field routes `∀ C' ∈ anchorCells, ∀ T' ∈ C'` through
      `cellAt`'s membership and `box_mem_tpOf_iff`'s `∀ σ' z'` (a history at time `z'` shifts to
      time `0`); the `stab` field is `stab_mem_tpOf_iff` with `σ.state 0 = w = σ'.state 0`. No
      new induction.
- [ ] Prove `anchorCells_finite` and `anchorCells_ncard_le` (pinned): `anchorCells M φ ⊆
      𝒫 (↑(plusSubformulaClosure φ).powerset)` (a cell is a set of subsets of `cl φ`), so it is
      finite by `Set.Finite.powerset (Finset.finite_toSet _)`, and
      `(anchorCells M φ).ncard ≤ 2 ^ (2 ^ (plusSubformulaClosure φ).card)` by
      `Set.ncard_le_ncard`, `Set.ncard_powerset`, `Set.ncard_coe_finset`, `Finset.card_powerset`.
      Docstring: this is a cardinality bound on a SET OF CELLS, syntactic in `|cl φ|`; it is not
      a complexity bound of any kind and must not be described as one.
- [ ] Define the `Finset` twin `AnchorConsFin φ (𝒞 : Finset (Finset (Finset PlusFormula)))`
      (pinned) with the same five fields over `Finset` membership, its instance
      `decidableAnchorConsFin` (pinned; `decidable_of_iff` on the conjunction of the five fields,
      each decided by `Finset.decidableDforallFinset` and `PlusFormula`'s derived `DecidableEq`),
      and the bridge `anchorConsFin_iff` (pinned): `AnchorConsFin φ 𝒞 ↔ AnchorCons φ
      ((fun C : Finset (Finset PlusFormula) => (↑C : Set (Finset PlusFormula))) '' ↑𝒞)` —
      `Set.mem_image`/`Finset.mem_coe` rewriting on each field, no content.
- [ ] Append to `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` (import `AnchorLayer`
      directly, re-read the file before editing) a `#guard` block in the file's existing style:
      POSITIVE witness with `φ := .stab (.atom pa)` (closure `{⊡p, p}`), `𝒞 := {{{⊡p, p}}, {∅},
      {{p}, ∅}}` — the third cell carries TWO types at one world state, which is exactly the shape
      `Presented`+`nowUnique` can never present (Phase 2's collapse), so the witness is
      non-vacuous in the sense the record requires; NEGATIVE control `𝒞 := {{{p}}}`, which
      violates the `stab` equation (`⊡p ∉ {p}` while every type of the cell contains `p`), so
      `decide` returns `false`. Both as `#guard (decide (AnchorConsFin …)) = true/false`, with a
      comment stating what each witnesses and that neither says anything about a model.
- [ ] Scoped builds: `AnchorLayer` and `BimodalTest.Metalogic.KTypeFinEvalTest` (the test library
      is not a default target — build it by name), both exit 0.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: The edit appends to the still-importerless `AnchorLayer.lean` and to one
test module that imports it directly, so the two scoped builds
`bash .claude/scripts/lake-build-guard.sh build --timeout 900 -- build
FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer BimodalTest.Metalogic.KTypeFinEvalTest`
cover the whole blast radius — the `#guard`s elaborate only in the second, which is why it is
named rather than left to the default target.

**Scope Hypothesis**: ~180-260 lines in `AnchorLayer.lean` (two structures 40-60, three theorems
60-100, the instance and bridge 40-70) and ~30-50 lines of `#guard` witnesses with comments in
the test module; the `anchorConsFin_iff` bridge is the least certain figure and may run to 80
lines of membership rewriting. Confirm by `wc -l` and `git diff --stat` at phase end; if the
bridge exceeds ~100 lines, record it and consider stating `AnchorConsFin`'s fields through a
shared helper predicate on an arbitrary `Membership` carrier instead of duplicating them.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean` - append `anchorCells`, `AnchorCons`, `anchorCons_anchorCells`, `anchorCells_finite`, `anchorCells_ncard_le`, `AnchorConsFin`, `decidableAnchorConsFin`, `anchorConsFin_iff`
- `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` - the `AnchorConsFin` witness and negative-control `#guard`s

**Verification**:
- Both scoped builds exit 0 with zero sorries; every new theorem's `#print axioms` is exactly
  `[propext, Classical.choice, Quot.sound]`.
- `anchorCons_anchorCells`'s statement, read in the file, carries no hypothesis beyond
  `(M : TaskModel F.toTaskFrame) (φ : PlusFormula)` — no `Presented`, no `Cons`, no `[Finite _]`,
  no `[Fintype _]`, no `[F.IsRegular]`.
- The positive `#guard` passes and the negative control `#guard` passes (i.e. `decide` returns
  `false` on the control) — the conditions must be shown to exclude something.
- `grep -n "complexity\|EXPTIME\|EXPSPACE\|PSPACE\|running time" AnchorLayer.lean` returns only
  the docstring sentence saying the bound is not one, read hit by hit.

---

### Phase 5: Records — the (W) verdict, the three named obligations, pins, index, READMEs, ROADMAP, full gate [NOT STARTED]

**Goal**: Wire the module into the aggregator and make every record say exactly what landed and
what did not: anchor layer landed and bounded for every model; run layer BLOCKED on three named
obligations with their sources; (S) untouched; no decidability statement; no complexity bound;
forward-only. Then run the complete gate set.

**Tasks**:
- [ ] Add `import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer` to
      `FormalSystem/Metalogic/Decidability/RaySummary.lean` and a `* RaySummary.AnchorLayer — …`
      bullet to its `## Modules` list; update the header paragraph's sentence "the `box`/`stab`-
      bearing fragment and the lift from one seam to validity both remain open (the README's
      requirement (W))" to say precisely: the anchor layer of (W) is landed (`AnchorLayer`), the
      run layer is blocked on three named obligations (README), and nothing states
      `PlusValidZTime` in any form.
- [ ] Rewrite `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: (a) the (W) row of "The
      verdict" table — from "nothing in the tree composes per-seam checks into a model-wide
      witness" to the two-layer characterization: anchor layer landed (`AnchorCons`,
      `anchorCons_anchorCells` for every model, `anchorCells_ncard_le`, `decidableAnchorConsFin`
      on a concrete finite object), the record's "for every time" quantifier dropped by
      `box_time_invariant`, and the run layer blocked; (b) a new subsection "(W): what landed and
      what did not" beside "(S): what landed and what did not", naming the three obligations with
      sources — (i) the frame-scheme constructor (successor of
      `b2b-frame-constructor-branching.lean`; `Rbad`/`Rok` refuted; the `Node` thread-unfolding
      shape unrefuted and unbuilt; the ~120-160 line regularity figure CARRIED from the (S)
      subsection and scoped to the regularity part; the unfolding design unmeasured); (ii) the
      Hit-level per-cell summary (never `Presented`, by `w-soundness-shape-refuted.lean`'s
      collapse theorem); (iii) the bound `kTypeOf_listSeg_replicate_eventually_periodic` (stated
      under "The bound: blocked", unproved) — and stating that without (iii) even a landed
      composition theorem would deliver `¬ PlusValidZTime φ ↔ ∃ object, …` and NOT
      `Decidable (PlusValidZTime φ)`; that (S) is untouched; that nothing here is a negative
      decidability result; that the fixtures are forward-only; and that `not_finite_width_fmp`
      forces the run layer's frame to have infinite-width slices; (c) the `Closure.lean` row:
      note after "`box` per time" that `box_time_invariant` (`PlusTruth.lean`) shows the `∀ z`
      is redundant on every `TaskFrame`; (d) a `AnchorLayer.lean` row in the module table; (e)
      the whole line-count table refreshed from `wc -l` at implementation time (documentation
      correction; the table was stale by the (S) Phase 8 edits); (f) the "Evidence" section entry
      for the new probe.
- [ ] Add theorem-index rows to `docs/theorem-index.md` beside the 197-203 band (re-locate by
      the `hitCl_modelOf_eq_hitOf` row, not by line): `box_global` (every `TaskFrame`; `□ψ` is a
      per-model datum); `anchorCons_anchorCells` (regular ℤ-frames as the instance the record
      names, though the statement needs no regularity; L⁺; `cl φ`; NO presentation hypothesis;
      the completeness direction of the anchor layer; the run layer blocked; nothing about
      `PlusValidZTime`); `anchorCells_ncard_le` (a cardinality bound on cells, syntactic in
      `|cl φ|`, not a complexity bound); `anchorConsFin_iff` (the decidable checker is on a
      concrete finite object and decides nothing about a model). If
      `scripts/check-module-invariants.sh`'s C14/C21 baseline pair must be extended for the
      `pinned:C14` cells to be asserted rather than claimed (as (S)'s Phase 8 found), edit that
      script's baseline in the same phase and record the out-of-list file in the summary.
- [ ] Append axiom pins for all nineteen Goals to
      `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, append-only, in the file's
      `#guard_msgs in #print axioms` form, with a comment block stating what the pins do and do
      not certify (they certify the standard profile; they do not certify any claim about
      `PlusValidZTime`). Add the `AnchorLayer` import if the aggregator import does not already
      carry it. Re-read the file immediately before editing.
- [ ] Rewrite `specs/ROADMAP.md`'s **(W)** bullet under `/orchestrate 747 --hard --lit`: the
      characterization round is complete; anchor layer landed and bounded; run layer blocked on
      three named obligations with no cost figure (the record's "costs it at nothing" is now
      "three obligations, one of them with a carried partial figure"); if the run layer is to be
      attempted, it is filed as its own record with F7's design question (thread-indexed
      unfolding vs. a bounded-deadline encoding) as ITS phase 1, after this round lands.
- [ ] The complete gate set, each exiting 0: the full-project guarded build
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`; the test library
      by name (`… -- build BimodalTest`) so every `#guard_msgs` and `#guard` elaborates;
      `bash scripts/check-evidence-probes.sh`; `bash scripts/check-module-invariants.sh`;
      `bash .claude/scripts/lean-sorry-census.sh`;
      `bash .claude/scripts/validate-artifact.sh specs/747_closure_wide_quasimodel_lift_to_validity/plans/01_closure-wide-quasimodel-anchor-layer.md plan`;
      and `bash .claude/scripts/verify-deploy.sh` (the repository's aggregated gate set).

**Timing**: 2.5 hours

**Depends on**: 2, 4

**Verification Tier**: full

**Scope Hypothesis**: nineteen axiom pins (one per Goal), four new theorem-index rows, one new
README subsection plus one row plus one row-note plus the refreshed table, one aggregator import
and bullet, one ROADMAP bullet, and seven files touched as enumerated below (eight if the
invariants baseline must be extended) — all hypotheses. Confirm at phase end by counting
`#print axioms` additions in the axiom-pin diff (a count other than nineteen means a Goal was
dropped or added relative to `## Lean Challenge Statements`), counting new index rows, and
`git diff --stat`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - the import, the module bullet, the header-paragraph rewrite
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - the (W) row and subsection, the `Closure.lean` row note, the `AnchorLayer.lean` row, the refreshed table, the Evidence entry
- `docs/theorem-index.md` - four new rows
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - axiom pins, append-only
- `specs/ROADMAP.md` - the (W) bullet rewrite
- `scripts/check-module-invariants.sh` - only if the C14/C21 baseline must be extended for the new `pinned:C14` cells; otherwise untouched

**Verification**:
- The complete gate set runs and is green: `bash .claude/scripts/lake-build-guard.sh build
  --timeout 1800 -- build` exits 0; the `BimodalTest` library builds with every `#guard_msgs` and
  `#guard` passing; `bash scripts/check-evidence-probes.sh` exits 0 with the new probe among the
  green ones; `bash scripts/check-module-invariants.sh` reports all checks passed;
  `bash .claude/scripts/lean-sorry-census.sh` reports zero sorries across every module this plan
  touched; `bash .claude/scripts/validate-artifact.sh … plan` exits 0;
  `bash .claude/scripts/verify-deploy.sh` exits 0.
- All nineteen Goals are pinned with axiom profile exactly `[propext, Classical.choice, Quot.sound]`.
- `grep -rn "PlusValidZTime"` over every file this plan touched returns only negative statements
  ("nothing here states…", "¬ PlusValidZTime Φ.neg" as the probe's cited non-validity), never a
  `Decidable` claim — checked by reading each hit.
- `grep -rni "EXPSPACE\|PSPACE\|2EXPTIME\|exponential time\|complexity bound"` over the touched
  files returns nothing asserting a bound (the ARGUED ceiling, if mentioned, carries ARGUED).
- The README (W) subsection, the aggregator header, the probe header and the index rows each say
  (S) is untouched, the run layer is blocked (not refuted, not open-ended), and the fixtures are
  forward-only.
- `git diff --stat` shows no modification to `Closure.lean`, `Trace.lean`, `Realize.lean`,
  `SlicedFrame.lean`, `NoFiniteWidth.lean`, `presented-not-complete.lean`,
  `hit-presented-model-a.lean`, `b2b-frame-constructor-branching.lean`,
  `mosaic-stab-saturated.lean`, or `backward-dual-mirror-fixture.lean`.

---

## Literature Proof Structure

**Source**: Hodkinson–Wolter–Zakharyaschev 2000, *Decidable fragments of first-order temporal
logics*, §3 (Defs. 10-12, Thm. 14) and §4 (Thm. 15); GKWZ 2003 Thm. 1.28 as the MSO fact Thm. 15
rests on. Provenance: `unverified_summary` / `no_source_pdf` — context only, per the task's
zero-debt constraint; a guide to SHAPE, never a source for any claim. In-tree analogue per step,
and where this plan lands or blocks it:

1. Types over `sub_x φ`; state candidates (sets of types) — HWZ Def. 10. In tree: `clSig φ`.
   **(W) change**: the quasistate is a set of CELLS (sets of types), not a set of types
   (`quasistate_does_not_determine_hit`). → Phase 3 (`tpOf`, `cellAt`), Phase 4 (`anchorCells`).
2. State function `f` and runs with the `U`/`S` clauses — HWZ Def. 11. In tree: `LocalRun`.
   **(W) change**: `f` is CONSTANT in the `box` component (F1, Phase 1) and per cell in the
   `stab` component (F2, Phase 3's `stab_mem_tpOf_iff`).
3. Quasimodel `⟨f, R⟩`, `R` chosen freely, saturation — HWZ Def. 12. **(W) change**: `R` cannot be
   chosen; it must be the path set of a frame, closed under splicing and limits
   (`blc_plusValid`). → BLOCKED; recorded as obligations (i)-(ii) in Phase 5.
4. Thm. 14 (⇒): read types off a model. In tree at one seam: `clTrace_localRun`,
   `eq_clTrace_of_localRun_anchored`. → Phase 4's `anchorCons_anchorCells` is the closure-wide
   anchor-layer instance, for every model.
5. Thm. 14 (⇐): build a model on `R × κ`. In tree: `presented_modelOf` (finite width,
   `box`/`stab`-free). → BLOCKED for (W) by F4 (width) and F5 (collapse); Phase 2 wires the
   obstruction.
6. Thm. 15: existence of a quasimodel is MSO-expressible, decided by Büchi/Rabin (= GKWZ
   Thm. 1.28). Forbidden as a citation; the in-tree search must enumerate a BOUNDED object, which
   the anchor layer is (`anchorCells_ncard_le`) and the run layer is not (obligation (iii)).
   → Nothing decidable is stated.

## Lean Challenge Statements

```lean
import FormalSystem.PlusLanguage.PlusTruth
import FormalSystem.Metalogic.Decidability.RaySummary.Closure

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics

namespace FormalSystem.PlusLanguage

variable {F : TaskFrame}

/-- `□ψ` has the same truth value at every pair of times, along any history — the history set of
a task frame is shift-closed, so the "for every time" quantifier of requirement (W) does not
exist in this semantics. Holds on every `TaskFrame`. -/
theorem box_time_invariant (M : TaskModel F) (τ : WorldHistory F) (t s : F.Duration)
    (ψ : PlusFormula) :
    PlusTruthAt M τ t (.box ψ) ↔ PlusTruthAt M τ s (.box ψ) := sorry

/-- `□ψ` depends on the model alone: along any two histories at any two times. -/
theorem box_global (M : TaskModel F) (τ σ : WorldHistory F) (t s : F.Duration)
    (ψ : PlusFormula) :
    PlusTruthAt M τ t (.box ψ) ↔ PlusTruthAt M σ s (.box ψ) := sorry

end FormalSystem.PlusLanguage

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics

variable {F : FrameOver intOrder}

/-- The closure type of the point `(σ, z)`: the subformulas of `φ` true there. Classical in
`PlusTruthAt`, hence noncomputable. -/
noncomputable def tpOf (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) : Finset PlusFormula := sorry

theorem mem_tpOf_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) (ψ : PlusFormula) :
    ψ ∈ tpOf M φ σ z ↔ ψ ∈ plusSubformulaClosure φ ∧ PlusTruthAt M σ z ψ := sorry

theorem tpOf_timeShift (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z Δ : ℤ) :
    tpOf M φ (σ.timeShift Δ) z = tpOf M φ σ (z + Δ) := sorry

/-- The cell of a world state at a time: the closure types realized at that state by histories
through it at that time. Time-independent (`cellAt_eq_cellAt`). -/
def cellAt (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (w : F.WorldState) (z : ℤ) :
    Set (Finset PlusFormula) := sorry

theorem cellAt_eq_cellAt (M : TaskModel F.toTaskFrame) (φ : PlusFormula) (w : F.WorldState)
    (z z' : ℤ) : cellAt M φ w z = cellAt M φ w z' := sorry

theorem bot_not_mem_tpOf (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) : PlusFormula.bot ∉ tpOf M φ σ z := sorry

theorem imp_mem_tpOf_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) {ψ χ : PlusFormula}
    (h : PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ) :
    PlusFormula.imp ψ χ ∈ tpOf M φ σ z ↔ (ψ ∈ tpOf M φ σ z → χ ∈ tpOf M φ σ z) := sorry

/-- The closure-wide `box` equation: one global bit per `box`-subformula, with no per-time
quantifier (`box_time_invariant`). -/
theorem box_mem_tpOf_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) {ψ : PlusFormula}
    (h : PlusFormula.box ψ ∈ plusSubformulaClosure φ) :
    PlusFormula.box ψ ∈ tpOf M φ σ z ↔
      ∀ (σ' : WorldHistory F.toTaskFrame) (z' : ℤ), ψ ∈ tpOf M φ σ' z' := sorry

/-- The closure-wide `stab` equation: one bit per (`stab`-subformula, world state). -/
theorem stab_mem_tpOf_iff (M : TaskModel F.toTaskFrame) (φ : PlusFormula)
    (σ : WorldHistory F.toTaskFrame) (z : ℤ) {ψ : PlusFormula}
    (h : PlusFormula.stab ψ ∈ plusSubformulaClosure φ) :
    PlusFormula.stab ψ ∈ tpOf M φ σ z ↔
      ∀ σ' : WorldHistory F.toTaskFrame, σ.state z = σ'.state z → ψ ∈ tpOf M φ σ' z := sorry

/-- The cells of a model: one per world state (at time `0`, without loss by `cellAt_eq_cellAt`). -/
def anchorCells (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    Set (Set (Finset PlusFormula)) := sorry

/-- **The closure-wide anchor object**: a set of cells satisfying the Hintikka clauses and the
`box`/`stab` fixpoint equations. `Anchored.box`/`Anchored.stab`/`LocalRun.bot`/`LocalRun.imp` on
types rather than on one seam's colouring. The `untl`/`snce` nesting is NOT here — it is the run
layer, blocked (README). Every quantifier is bounded by `plusSubformulaClosure φ` so that the
`Finset` twin `AnchorConsFin` is decidable field for field. -/
structure AnchorCons (φ : PlusFormula) (𝒞 : Set (Set (Finset PlusFormula))) : Prop where
  closure : ∀ C ∈ 𝒞, ∀ T ∈ C, T ⊆ plusSubformulaClosure φ
  bot : ∀ C ∈ 𝒞, ∀ T ∈ C, PlusFormula.bot ∉ T
  imp : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ, ∀ χ ∈ plusSubformulaClosure φ,
    PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ →
      (PlusFormula.imp ψ χ ∈ T ↔ (ψ ∈ T → χ ∈ T))
  box : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ,
    PlusFormula.box ψ ∈ plusSubformulaClosure φ →
      (PlusFormula.box ψ ∈ T ↔ ∀ C' ∈ 𝒞, ∀ T' ∈ C', ψ ∈ T')
  stab : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ,
    PlusFormula.stab ψ ∈ plusSubformulaClosure φ →
      (PlusFormula.stab ψ ∈ T ↔ ∀ T' ∈ C, ψ ∈ T')

/-- **Completeness of the anchor layer, for EVERY model**: the cells of any `TaskModel` on a
ℤ-frame form an anchor object. No presentation, no `Presented`, no finiteness hypothesis on the
model, no regularity — the absence of hypotheses is the content. -/
theorem anchorCons_anchorCells (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    AnchorCons φ (anchorCells M φ) := sorry

theorem anchorCells_finite (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    (anchorCells M φ).Finite := sorry

/-- The one bound (W) can state honestly: a cardinality bound on the SET OF CELLS, syntactic in
`|cl φ|`. It is not a complexity bound of any kind. -/
theorem anchorCells_ncard_le (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    (anchorCells M φ).ncard ≤ 2 ^ (2 ^ (plusSubformulaClosure φ).card) := sorry

/-- The `Finset` twin of `AnchorCons`: the same five equations on a concrete finite object. -/
structure AnchorConsFin (φ : PlusFormula) (𝒞 : Finset (Finset (Finset PlusFormula))) :
    Prop where
  closure : ∀ C ∈ 𝒞, ∀ T ∈ C, T ⊆ plusSubformulaClosure φ
  bot : ∀ C ∈ 𝒞, ∀ T ∈ C, PlusFormula.bot ∉ T
  imp : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ, ∀ χ ∈ plusSubformulaClosure φ,
    PlusFormula.imp ψ χ ∈ plusSubformulaClosure φ →
      (PlusFormula.imp ψ χ ∈ T ↔ (ψ ∈ T → χ ∈ T))
  box : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ,
    PlusFormula.box ψ ∈ plusSubformulaClosure φ →
      (PlusFormula.box ψ ∈ T ↔ ∀ C' ∈ 𝒞, ∀ T' ∈ C', ψ ∈ T')
  stab : ∀ C ∈ 𝒞, ∀ T ∈ C, ∀ ψ ∈ plusSubformulaClosure φ,
    PlusFormula.stab ψ ∈ plusSubformulaClosure φ →
      (PlusFormula.stab ψ ∈ T ↔ ∀ T' ∈ C, ψ ∈ T')

/-- Decidable on a concrete finite object — a statement about a finite set, not about L⁺, and
not about any model. -/
instance decidableAnchorConsFin (φ : PlusFormula) (𝒞 : Finset (Finset (Finset PlusFormula))) :
    Decidable (AnchorConsFin φ 𝒞) := sorry

/-- The `Finset` twin agrees with `AnchorCons` on the image of the object under coercion. -/
theorem anchorConsFin_iff (φ : PlusFormula) (𝒞 : Finset (Finset (Finset PlusFormula))) :
    AnchorConsFin φ 𝒞 ↔
      AnchorCons φ ((fun C : Finset (Finset PlusFormula) => (↑C : Set (Finset PlusFormula))) '' ↑𝒞) :=
  sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [ ] Full-project guarded build green: `bash .claude/scripts/lake-build-guard.sh build --timeout
      1800 -- build` exits 0 (detached, never foreground, never bare `lake`); the `BimodalTest`
      library built by name with every `#guard_msgs` and `#guard` passing.
- [ ] Zero sorries across every module this plan touches, confirmed by
      `bash .claude/scripts/lean-sorry-census.sh`.
- [ ] All nineteen Goals pinned in `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` with
      axiom profile exactly `[propext, Classical.choice, Quot.sound]`.
- [ ] The `AnchorConsFin` positive witness (a cell with two types at one state) and the negative
      control (the `stab` equation violated) both pass as `#guard`s in
      `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` — the conditions must be shown to
      exclude something.
- [ ] `bash scripts/check-evidence-probes.sh` exits 0 with `w-soundness-shape-refuted` green and
      every pre-existing probe unmodified.
- [ ] `bash scripts/check-module-invariants.sh` reports all checks passed (including C14/C21 on
      the new theorem-index rows).
- [ ] `bash .claude/scripts/validate-artifact.sh specs/747_closure_wide_quasimodel_lift_to_validity/plans/01_closure-wide-quasimodel-anchor-layer.md plan` exits 0.
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0.
- [ ] No file touched by this plan states `Decidable (PlusValidZTime φ)` in any form, says "L⁺ is
      decidable" unqualified, asserts any complexity bound (the ARGUED CTL⋆ ceiling only with its
      qualifier), introduces a finite-fibre or finite-width assumption on a model, adds a cslib
      `require` edge or copies a cslib declaration, implies a backward Bool-fixture bridge, or
      describes (S) as retired or the run layer as refuted. Each checked by reading the hits of a
      targeted grep, not by assuming.
- [ ] No vacuous definition anywhere (`:= True`, `:= Unit`, `:= trivial` bodies), per
      `lean4.md`'s prohibition; `anchorCons_anchorCells` carries no hypothesis beyond `M` and `φ`.

## Artifacts & Outputs

**file_scope** (set at plan time, as the record required; it matches the research's proposed
scope plus the two test/gate files the sibling plan's measured deviations showed are needed):

- `FormalSystem/PlusLanguage/PlusTruth.lean` (Phase 1)
- `specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean` (new; Phase 2)
- `scripts/check-evidence-probes.sh` (Phase 2; shared with task 734 — append-only, re-read
  immediately before editing)
- `FormalSystem/Metalogic/Decidability/RaySummary/AnchorLayer.lean` (new; Phases 3, 4)
- `Tests/BimodalTest/Metalogic/KTypeFinEvalTest.lean` (Phase 4)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` (Phase 5)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (Phase 5)
- `docs/theorem-index.md` (Phase 5)
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (Phase 5; append-only, re-read
  immediately before editing)
- `specs/ROADMAP.md` (Phase 5)
- `scripts/check-module-invariants.sh` (Phase 5, conditional — only if the C14/C21 baseline must
  be extended)

Expected outputs: ~25-40 lines appended to `PlusTruth.lean`; the new wired probe (~230-320
lines) and its ~45-65 line registry/catalogue entry; the new `AnchorLayer.lean` module (~330-480
lines across Phases 3-4); ~30-50 lines of `#guard` witnesses and ~90-120 lines of axiom pins in
the two test modules; four theorem-index rows; the README (W) subsection, row, row-note, module
row and refreshed table; the aggregator import, bullet and header rewrite; the ROADMAP (W)
bullet rewrite; and an execution summary at
`specs/747_closure_wide_quasimodel_lift_to_validity/summaries/01_closure-wide-quasimodel-anchor-layer-summary.md`
stating, in its own words, that the anchor layer landed, the run layer is blocked on three named
obligations, and nothing decidable was stated.

## Rollback/Contingency

- **Per-phase**: every phase commits only when its own verification is green, one commit per
  green sub-step (`git-workflow.md`'s commit-per-green-substep mandate), with targeted file-list
  staging only — never `git add -A`, never a directory or glob pathspec, never `git commit -am`.
  Sibling implementers are live on this working tree this cycle (task 734 shares
  `check-evidence-probes.sh`), so re-read each file immediately before editing and stage only
  this task's own hunks. Reverting a phase is `git revert` of its commits; no phase depends on
  uncommitted state from another.
- **Never run `git-snapshot.sh` in its reverting default form** during this plan. An ordinary
  defensive checkpoint before a risky edit (Phase 4's bound and bridge) uses
  `bash .claude/scripts/git-snapshot.sh 747 --no-revert`.
- **If Phase 4's bound (`anchorCells_ncard_le`) resists**: land `anchorCons_anchorCells` and
  `anchorCells_finite` green, commit them, close Phase 4 `[PARTIAL]` with the bound's goal state
  recorded, and let Phase 5 state the anchor layer as landed WITHOUT the numeric bound (finite,
  not yet counted). Do not weaken the statement to `Set.Finite` under the bound's name
  (`plan-compliance.md` Statement Fidelity).
- **If the `Finset` bridge (`anchorConsFin_iff`) resists**: land `AnchorConsFin` and its
  `Decidable` instance with the `#guard` witnesses, commit, and close the bridge as the one open
  item; the checker is still an honest decidable check on a finite object, and the records say
  the two structures are stated in parallel and not yet proved to agree.
- **If the `#guard` witness does not reduce**: see Risks; a term-mode positive witness is
  acceptable, an un-evaluated negative control is not — record the issue and keep the control
  as the blocking item of the phase.
- **If Phase 2's probe does not compile under the gate's `lake env lean`** (it compiled under
  the same command at research time against the same oleans): the cause is drift in
  `Realize.lean` or `NoFiniteWidth.lean` since research, not in the probe; re-resolve the named
  declarations, repair the citation, and record the drift in the issue log. Never re-prove
  `no_finite_width_sat` or `seamOmegaEquiv` inside the probe.
- **Nothing landed is removed under any contingency**: `Presented`, `presented_modelOf`,
  `hitCl_modelOf_eq_hitOf`, `Cons`, `frameOf`/`modelOf`, `Anchored`, `no_finite_width_sat`,
  `not_finite_width_fmp`, task 735's verdict, and every wired probe stay exactly as they are.
