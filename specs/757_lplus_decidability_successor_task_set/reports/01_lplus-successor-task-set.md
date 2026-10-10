# Research Report: Task #757

**Task**: 757 - Research, design, and file the successor task set that carries L+ decidability — the unfiled frontier after the (C)/(S)/(W) partial landings
**Started**: 2026-10-10T22:52:29Z
**Completed**: 2026-10-10T23:07:14Z
**Effort**: ~15 minutes wall clock (one research dispatch)
**Dependencies**: None
**Sources/Inputs**:
- Codebase: `FormalSystem/Metalogic/Decidability/RaySummary/{README.md,RunLayer.lean,Realize.lean,Trace.lean,AnchorLayer.lean}`, `PlusSlicedCertificate/Limits/{NoFiniteWidth,FiniteCarrier}.lean`, `specs/evidence/seam-gluing-ray-product/*.lean`, `specs/ROADMAP.md`, `specs/state.json`
- Precedent records: `specs/archive/721_decidability_programme_review_l_and_lplus/followup-scope-spec.md` (format of record), `specs/archive/718_.../followup-scope-spec.md`, `specs/750_w_run_layer_closure_wide_lift/{summaries,reports}/01_*.md`, `specs/749_c_bound_half_model_a_presentation_size/summaries/01_*.md`
- Compile record: `lake env lean` on a scratch file importing `FormalSystem` (Section 0.1 below); `bash scripts/check-evidence-probes.sh` (Section 0.3)
- Agent-system contracts: `multi-task-creation-standard.md` (Components 0, 4a), `file-footprint-overlap.md`, `commands/task.md` Create Task Mode, `update-task-status.sh` header, `return-metadata-file.md`
- Literature index entries (context only, not sources for any claim): `hodkinson_wolter_zakharyaschev_2000_decidable_fragments_fotl`, `gabbay_kurucz_wolter_zakharyaschev_2003_many_dimensional_modal_logics`
**Artifacts**: - specs/757_lplus_decidability_successor_task_set/reports/01_lplus-successor-task-set.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **Every anchor the task description cites is re-verified against the tree this round** (Section 0): the compile record resolves 55 `#check`/`#print axioms` lines with exit 0, every headline at `[propext, Classical.choice, Quot.sound]`; the wired-probe gate passes 27 of 27 with one recorded SKIP; `Decidable (PlusValidZTime` has zero statement-level occurrences anywhere (14 hits, all prose denials). The description's reading of the three obligations is confirmed by the RaySummary README's "The verdict" table, with one sharpening (below).
- **Obligation (1), run-layer phase 2 (soundness half)**: OPEN, nothing in the tree states or approaches the stabilization lemma (`grep -i stabiliz` over `RaySummary/*.lean` hits only `iterate_stabilizes`, an unrelated bounded-iterate lemma). **Sharpening found by this round**: a ladder state is `(q, c, n)` with TWO counters, and the realized cell at an idle state depends on the next-deadline counter `n` (a region that starts at the next step has length `n`), so the first statement must quantify stabilization over the pair `(c, n)`, not `c` alone. The README's "cells indexed by `(q, deadline class)`" is correct read as the class of the pair; "in the deadline counter `c`" is a shorthand that under-specifies it.
- **Obligation (2), run-layer phase 3 = (C)'s general row**: OPEN mathematics, one positive fixture (`Probe745.hitPresented_modelA`, model A, `φ := Fp`, `box`/`stab`-free, finite-width slice `Fin 3`), no Hit-level negative anywhere, no general argument. The untested corner on BOTH axes is a `⊡`-bearing formula on an infinite-width fixture; the `Node` model of `Limits/NoFiniteWidth.lean` (a library declaration, `NoFiniteWidth.M`, regular by `F_isRegular`) is exactly that fixture and is the one-region special case of the ladder.
- **Obligation (3), (S) beyond its landed corner**: by the README's own assignment ("The limitation is therefore assigned to (W), not left as a gap in (S)") and the machine-checked WIDTH/COLLAPSE pair (`Probe747.modelOf_incomplete`, `stab_iff_of_presented_nowUnique`), extending `modelOf`/`Cons` to `box`/`stab`-bearing `φ` on `ofSlicedStep` is a finite-width shape and is ruled out by guardrail (b); the obligation has **no standalone (S) record**. Its `box`/`stab` half is an acceptance clause of the ladder realization theorem; its "every seam but the one" half IS (W)'s composition theorem.
- **Decomposition: six records, two of them costable now** — two probes on the `Node` fixture (cell stabilization; `HitPresented` for a `⊡`-bearing formula), then the ladder stabilization lemma, the ladder realization theorem, (C)'s general row, and the composition biconditional. Each has a statement shape, a fixed depth, a declared `file_scope`, and typed dependency edges (logical vs. serialization). The four library records serialize through `RaySummary/README.md`, `docs/theorem-index.md`, `KTypeSummaryAxiomTest.lean` and `check-module-invariants.sh`; per CLAUDE.md's batching rule the overlap is made an explicit edge rather than left to the admission gate.
- **Not costable, and why**: the stabilization lemma (its bound shape is fixed only by the probe's verdict), the realization theorem (sized by the lemma), (C)'s general row (no argument exists), and the lift (statement fixed by its two predecessors). Figures with a stated basis are given only for the two probes.
- **Recommended approach for the implementation phase**: write the followup-scope-spec in the 721 format (Section 0 re-verification; one section per obligation; Section H with the six records), then FILE the six tasks through the `/task` Create Task Mode `state-write.sh` pattern with `dependencies`, `file_scope` and `topic: "decidability"` set in the creation object, in Kahn order, and hand-edit `specs/ROADMAP.md` Stage 1 (authored layout). No Stage 0 task is moved; no `FormalSystem/` or `docs/` file is edited.

## Context & Scope

The task converts the three OPEN frontier obligations named by `RaySummary/README.md`'s "The verdict" table into filed, costable task records. Constraints carried from the description and `specs/ROADMAP.md` Stage 1: R1 (gluing) alone, no fallback; R2 a consumer, R4 closed by `no_finite_carrier_sat`/`not_finite_width_fmp`, R5 low; guardrails (a)-(e); zero debt (no external Büchi/MSO lemma, no cslib `require`); no upper bound claimed anywhere; no Stage 0 transition (712, 713, 734, 709); no edit to the sliced-certificate tasks 716/714. Research only: nothing is proved, filed, or revised in this dispatch. Every status claim below is re-derived (Section 0); figures copied from other records are marked `CARRIED-UNVERIFIED` with their source.

## Findings

### Section 0 — Verification record (this round, 2026-10-10)

#### 0.1 Compile record

`timeout 300 lake env lean <scratchpad>/Verify757.lean` (import `FormalSystem`; `.olean` tree fresh — no `FormalSystem/**/*.lean` newer than `FormalSystem.olean`, `lake-build-guard.sh status` reports no holder). **Exit 0, 182 output lines, no `Unknown identifier`.** Abbreviated (full types in the scratch output; every `#print axioms` below reads `[propext, Classical.choice, Quot.sound]`):

```
Compression.decidableValidZTime : (φ : Syntax.Formula) → Decidable (ValidZTime φ)        -- L only
PlusValidZTime : PlusFormula → Prop ; plusValidZTime_iff_plusValidInt : ∀ φ, PlusValidZTime φ ↔ PlusValidInt φ
PlusSharingWitnessFamily.StabFaithful : {Γ Del : PlusContext} → PlusSharingWitnessFamily Γ Del → Prop
PlusSlicedCertificate.StabFaithful     : {Γ Del : PlusContext} → PlusSlicedCertificate Γ Del → Prop
presented_modelOf : … φ.BoxStabFree → (hC : Cons φ lab step) → … → Presented (modelOf φ lab step hC) τ t φ lab …
hitCl_modelOf_eq_hitOf : … → 1 ≤ k → HitCl (modelOf φ lab step hC) τ t φ k = ↑(hitOf lab … (clNow φ) k)
HitPresented : {F : FrameOver intOrder} → [F.IsRegular] → … → (φ : PlusFormula) → (Q → (clSig φ).preds → Bool) → (Q → Q → Bool) → ℕ → Prop
hitPresented_of_presented ; hit_eq_hitOf_of_presented ; mem_hitOf_iff (all under 1 ≤ k)
kTypeOf_listSeg_replicate_eventually_periodic_bounded : … ∃ m₀ p, 0 < p ∧ m₀ + p ≤ Nat.card (KType sig k) ∧ …
inFamily_of_shrink_run ; segZ_const_of_kTypeOf_eq_replicate (1 ≤ k)
anchorCons_anchorCells : ∀ {F : FrameOver intOrder} (M) (φ), AnchorCons φ (anchorCells M φ)
anchorCells_ncard_le : … (anchorCells M φ).ncard ≤ 2 ^ 2 ^ (plusSubformulaClosure φ).card
cellAt : … → F.WorldState → ℤ → Set (Finset PlusFormula) ; cellAt_eq_cellAt ; tpOf ; AnchorCons ; decidableAnchorConsFin
box_time_invariant ; stab_state_only ; plusStateLocal_stab_iff
ofSlicedStepFinBranch ; ofSlicedStepFinBranch_isRegular ; ofSlicedStepFinBranch_mem_HF_iff ; saturation_of_finBranch
Rlad : {Q} → (Q → Q → Bool) → (Q → Bool) → ℤ → Q × ℕ × ℕ → Q × ℕ × ℕ → Prop ; Rlad_fwd ; Rlad_bwd ; Rlad_slice_infinite
ladderFrame : {Q} → [Finite Q] → [Nonempty Q] → (step) → (pend) → (fwd) → (bwd) → FrameOver intOrder
ladderFrame_isRegular ; ladderFrame_step
decidableStabOfPresented : … → Presented M τ t φ lab step → Decidable (PlusTruthAt M τ t φ.stab)
no_finite_carrier_sat : ∀ {F} [F.IsRegular] [Finite F.WorldState] (M τ t), ¬PlusTruthAt M τ t θ
not_finite_width_fmp : ¬∀ φ, ¬PlusValidZTime φ → ∃ W, ∃ (_ : Finite W) (_ : Nonempty W), ∃ R fwd bwd M τ t, ¬PlusTruthAt M τ t φ
not_plusValidZTime_neg_Φ ; no_finite_width_sat ; plusStab_iff_forall_hitCl (1 ≤ k)
```

Reading: (i) `Compression.decidableValidZTime` is L only, confirming the perimeter; (ii) both `StabFaithful` predicates are predicates on L⁺ objects over `PlusContext`, so (C5) is structurally not stateable over `Formula`; (iii) every bridge the run layer consumes carries `1 ≤ k`, confirming `k = 1`; (iv) `cellAt` is the per-state type-set the stabilization lemma must speak about, and it is already time-independent (`cellAt_eq_cellAt`).

#### 0.2 Declaration anchors (grep, this round)

| # | Anchor | Path:line | Result |
|---|---|---|---|
| 1 | `Compression.decidableValidZTime` | `WitnessFamily/Compression/Assembly.lean:147` | `def`, `φ : Formula`; a second, hypothesis-taking `BiLasso.decidableValidZTime` at `BiLasso/Assembly.lean:100` is a different declaration |
| 2 | `PlusValidZTime` | `PlusLanguage/PlusValidity.lean:111` | `def PlusValidZTime (φ : PlusFormula) : Prop := PlusValidIn FrameClass.ZTime φ` |
| 3 | `StabFaithful` (two) | `PlusWitnessFamily/Predicates.lean:283`; `PlusSlicedCertificate/Check.lean:480` | both over `PlusContext` (0.1) |
| 4 | `presented_modelOf`, `hitCl_modelOf_eq_hitOf`, `Cons` (11 fields) | `RaySummary/Realize.lean:916, 992, 573` | fields `serialFwd serialBwd botFalse impEq ucoh ulive scoh slive nowOnce nowUnique boxStabFree` at lines 576-628 |
| 5 | `Probe745.hitPresented_modelA`, `presentationSize` | `specs/evidence/seam-gluing-ray-product/hit-presented-model-a.lean:1526` (namespace line 154) | `(t : ℤ) (k : ℕ) (hk : 1 ≤ k) : HitPresented MA stayA t Fp (labOf (presentationSize k)) (stepOf (presentationSize k)) k` — explicit window, no `∃ L` |
| 6 | `Probe735.not_presented` | `.../presented-not-complete.lean:230` (namespace line 67) | `(t : ℤ) {Q} [Fintype Q] [DecidableEq Q] (lab) (step) : ¬ Presented MA stayA t Fp lab step` |
| 7 | `Probe747.modelOf_incomplete`, `stab_iff_of_presented_nowUnique` | `.../w-soundness-shape-refuted.lean:131, 188` (namespace line 104) | WIDTH and COLLAPSE headlines; the header's "Consequence for (W)" paragraph: realization hypothesis must be Hit-level per cell, frame must have infinite-width slices |
| 8 | `Probe719Backward.pastStab_iff_allBwdPathsMeet` | `.../backward-dual-asymmetric-fixture.lean:577` (namespace line 81); a mirror in `backward-dual-mirror-fixture.lean:622` under `Probe733Mirror` | the only backward result; guardrail (e) stands |
| 9 | `Probe750.ladder_fwd/ladder_bwd/ladder_slice_infinite/ladder_isRegular/capped_carrier_finite` | `.../deadline-ladder-branching.lean:63-93` | the ninth wired probe; `capped_carrier_finite` refutes the capped variant |
| 10 | `anchorCells_ncard_le`, `anchorCons_anchorCells`, `cellAt` | `RaySummary/AnchorLayer.lean:324, 276, 132` | `cellAt M φ w z := {T | ∃ σ, σ.state z = w ∧ tpOf M φ σ z = T}` |
| 11 | `ladderFrame`, `ladderFrame_isRegular`, `Rlad`, `Count`, `Drift` | `RaySummary/RunLayer.lean:342, 358, 251-290` | `Count`: `if py then (if px then c' + 1 = c else c' = n) else (c' = 0 ∧ (px = true → c = 0))` — a region starting at the next step takes length `n` (the `n`-dependence in Finding 1) |
| 12 | `Node`, `Step`, `F`, `F_isRegular`, `M` | `PlusSlicedCertificate/Limits/NoFiniteWidth.lean:132, 141, 253, 282, 292` | `def M : TaskModel F.toTaskFrame := ⟨fun w _ => ∃ k, w = Node.x k⟩`; `pre k → pre (k-1) ∣ x k`, `x k → post k 0`, `post k j → post k (j+1)`; every node exactly one predecessor |
| 13 | `no_finite_carrier_sat`, `not_finite_width_fmp` | `Limits/FiniteCarrier.lean:248`; `Limits/NoFiniteWidth.lean:1280` | library names (R4 closed); `not_plusValidZTime_neg_Φ` at `:588` |
| 14 | `exists_tailStable_repr` | `PlusSlicedCertificate/FixtureStable.lean:14, 87, 291`; `Stable.lean:67, 722`; `Fixture.lean:788, 796` | never declared; recorded as false at the fixture ("no member is tail-stable") — a prose-level refutation record, not a theorem named `exists_tailStable_repr` |
| 15 | `Decidable (PlusValidZTime` | tree-wide | 14 hits in `FormalSystem/ Tests/ specs/evidence/`, **0** at statement level (`theorem|def|instance|#check|example` prefix) — all are denials in docstrings/headers |
| 16 | stabilization lemma | `grep -i stabiliz RaySummary/*.lean` | only `Present.lean`'s `iterate_stabilizes` (bounded-iterate stationarity for `pathClosure`), unrelated to realized cells; **obligation (1)'s first statement does not exist in any form** |
| 17 | admissibility `Adm` | `RunLayer.lean:59`, `README.md:391-392` | named ("`c ∈ Adm q`"), not defined, not costed — `ladderFrame` takes `fwd`/`bwd` as hypotheses |
| 18 | `docs/theorem-index.md` rows | lines 197-210 | Conditional rows for the `Presented`-gated statements; (S) rows (202-203); (W) anchor rows (205-206); (C) count rows (207-208); the `ladderFrame_isRegular` row (210) |
| 19 | C14 baseline | `scripts/check-module-invariants.sh:2316-2331, 2543-2552` | `hit_eq_hitOf_of_presented`, `presented_modelOf`, `anchorCells_ncard_le`, `inFamily_of_shrink_run`, `ladderFrame_isRegular` all pinned |

#### 0.3 Gate anchors

- `bash scripts/check-evidence-probes.sh` (run detached, log in scratchpad): **`PASS all 27 wired probe(s) compile`, exit 0**; the twenty `seam-gluing-ray-product/*` probes all PASS; one `SKIP (deferred: frame-class uniformity work)` on `bi-lasso-decision-layer/spike-untl-unfolding-and-fwd-obstruction`; the `WIRED_REPO` archive probe `476_.../fmp-hypothesis-is-false.lean` PASS. `WIRED` array: 26 quoted entries, 20 of them `seam-gluing-ray-product/`. (Task 749's summary says "28/28" and 750's "27/27" [CARRIED-UNVERIFIED: both summaries]; this round measured 27 PASS + 1 SKIP.)
- `specs/evidence/seam-gluing-ray-product/` holds 20 `.lean` files (listed in Appendix A).
- `lake-build-guard.sh status`: no holder; `.olean` frontier fresh (`FormalSystem.olean` 2026-10-10 01:56, `RunLayer.olean` 01:48; no `FormalSystem/**/*.lean` newer).

#### 0.4 Task-record anchors (`specs/state.json`, read-only)

| Task | Status | Deps | Declared `file_scope` (relevant entries) |
|---|---|---|---|
| 757 (this) | `researching` | — | **none declared** (see `proposed_file_scope`) |
| 749 | `completed` | — | `RaySummary/{Compose,Trace,Transport}.lean`, `RaySummary.lean`, `RaySummary/README.md`, `KTypeSummaryAxiomTest.lean`, `docs/theorem-index.md`, `check-evidence-probes.sh`, `check-module-invariants.sh`, two probe files |
| 750 | `completed` | — | `RaySummary/RunLayer.lean`, `RaySummary.lean`, `FormalSystem.lean`, `RaySummary/README.md`, pins, index, both scripts, `specs/evidence/seam-gluing-ray-product/` (directory root), `deadline-ladder-branching.lean` |
| 720 | `completed` | `[706, 710]` | `check-evidence-probes.sh`, `specs/evidence/seam-gluing-ray-product/`, two READMEs |
| 744 | `not_started` (markdown) | — | **`RaySummary/README.md`**, `check-module-invariants.sh`, `readme-inventory.sh` — collides with every library successor below |
| 734 | `partial` (Stage 0, R2) | `[733]` | `check-evidence-probes.sh`, `mosaic-stab-saturated.lean` — collides with both probe successors on the script |
| 751 | `not_started` (meta) | — | `specs/state.json`, `validate-state.sh` — collides with 757's own filing writes |
| 752 | `not_started` (meta) | — | `roadmap-integration.sh`, **`specs/ROADMAP.md`** — collides with 757's ROADMAP edit; its description records that `--regenerate` is inoperative on the Stage-layout ROADMAP, so the Stage 1 edit is hand-authored |
| 410 | `planned` | `[429]` | `typst/generated/status.typ` (the pre-commit hook regenerates it; 749/750 both had to stage it) |
| 712 / 713 / 709 | `blocked` / `hold` / `not_started` | `[703,710]` / `[]` / `[703,710,719]` | Stage 0 — described, never moved |
| 716 / 714 | `not_started` | `[]` / `[]` | `PlusSlicedCertificate/{Live,Check,Examples,Stable}.lean` — disjoint from every successor |

Open tasks: 52. Completed-but-unarchived in `active_projects`: `[750, 749, 731, 720, 754, 755]`. `next_project_number`: 758 (may shift before filing; the implementation phase re-reads it). `active_topics` contains `decidability` (757's own topic). HEAD at research start: `bb8c1c4fa` (`task 757: create …`).

#### 0.5 Differences from the task description

- No claim in the description is contradicted. One sharpening: "stabilization of realized type sets in the deadline counter `c`" is stated below over the pair `(c, n)` (Finding 1, mechanism in row 11).
- `exists_tailStable_repr` "refuted by `FixtureStable.lean`" is a prose-and-fixture refutation record, not a theorem of that name (row 14); the description's wording stands in substance.
- `Probe745.hitPresented_modelA` (row 5) is stated at **every** `k ≥ 1` with the window `presentationSize k`, so (C)'s probe half and bound half ON THE FIXTURE are one statement, as the description says.

### Finding 1 — Obligation (1): run-layer phase 2, soundness half

**Status**: OPEN; no statement in the tree (0.2 rows 16-17). Authority: README "(W): what landed and what did not", item 1 of "Open: obligation (ii)".

**What the statement must be about.** `cellAt M φ w z` is the set of closure types of histories through world state `w` (row 10), time-independent. On the ladder model, `w = (q, c, n)`; histories through it are exactly the `Rlad` paths through it (`ofSlicedStepFinBranch_mem_HF_iff`). Two sources of `(c, n)`-dependence:
1. `c` (current deadline): while pending, the region ends in exactly `c` steps (`Count`, `c' + 1 = c`); a letter whose truth needs the region to last `d` more steps is absent at `c < d`. `Node` exhibits it: `pre 0` reads `⊡Xp`, `pre (k+1)` reads `¬⊡Xp` [CARRIED-UNVERIFIED: `specs/750_.../reports/01_w-run-layer-design.md` F6 — the `Node` step relation (row 12) makes it immediate: from `pre 0` the only successor is `x 0`].
2. `n` (next deadline): at an idle state (`pend q = false`, `c = 0`) a region starting at the next step receives `c' = n` (row 11), so the next region's length is `n`; a letter looking `d` steps into that region depends on `n` for `n < d`. The README's "in `c`" omits this; its "cells indexed by `(q, deadline class)`" covers it if "deadline class" is the class of the pair.

**First statement (proposed shape, library, over a general object)** — a model is needed first, since `ladderFrame` is a frame:

```
def ladderModel (lab : Q → Atom → Bool) … : TaskModel (ladderFrame step pend fwd bwd).toTaskFrame
  -- valuation reads the object component: ⟨fun w a => lab w.2.1 a = true⟩
theorem ladderCell_stabilizes (φ : PlusFormula) :
    ∃ B : ℕ, ∀ (q : Q) (c c' n n' : ℕ) (z : ℤ),
      B ≤ c → B ≤ c' → B ≤ n → B ≤ n' →
      cellAt (ladderModel …) φ (q, c, n) z = cellAt (ladderModel …) φ (q, c', n') z
```

Preferred stronger form: `B` exhibited syntactically, `B := (plusSubformulaClosure φ).card`, written into the statement (a count of closure formulas, never a complexity bound — the `AnchorLayer.lean` disclaimer applies verbatim). The `∃ B` form is the fallback if the exhibited bound fails. Either form gives finitely many deadline classes `{0, …, B} ∪ {≥ B}` per counter, hence a finite cell index `Q × Fin (B+1) × Fin (B+1)`, which is what the realization theorem's finite presentation is built on. No `k` occurs: cells are type sets, not `k`-types.

**Why a fixture probe first.** The 750 record's own mitigation R-A: prove or refute stabilization on `Node` first, where the expected cells are `pre 0`, `pre (≥ 1)`, `x`, `post`. `Node` is the one-region special case of the ladder (`RunLayer.lean` header) and is a LIBRARY model (`NoFiniteWidth.M`, row 12), so the probe imports it and re-proves nothing. Probe statement, for the fixture's own `⊡`-bearing witness (no general `φ`, by design — the general-`φ` induction is the library lemma's content):

```
theorem preCell_stable (k k' : ℕ) (hk : 1 ≤ k) (hk' : 1 ≤ k') (z : ℤ) :
    cellAt M Φ (.pre k) z = cellAt M Φ (.pre k') z
theorem preCell_zero_ne (z : ℤ) : cellAt M Φ (.pre 0) z ≠ cellAt M Φ (.pre 1) z      -- the index is real
theorem postCell_stable (k k' j j' : ℕ) (hj : 1 ≤ j) (hj' : 1 ≤ j') (z : ℤ) :
    cellAt M Φ (.post k j) z = cellAt M Φ (.post k' j') z                                -- thread index invisible
```

with `Φ := NoFiniteWidth.Φ` (`(A' ∧ C') ∧ D`, `D = □(⊡Fp → ¬⊡¬Xp)`); if `Φ`'s closure makes the type computations unwieldy, `D` alone keeps the `⊡Xp` letter that separates `pre 0` from `pre 1` and is the recorded fallback. Either outcome is the deliverable: stabilization at bound 1 confirms the mechanism (branch-time saturation); a failure is the obstruction the README names as the `[BLOCKED]` outcome, recorded in the probe header, never a finite-fibre retreat.

**Consistency conditions and `Adm`.** The realization theorem needs `LadderCons φ lab step pend`, analogous to `Cons` with `ulive`/`slive` replaced by the ladder's structural liveness (`c` strictly decreases while pending) and with the `box`/`stab` letters pinned per cell by the anchor layer's equations (`box_mem_tpOf_iff`: one global bit; `stab_mem_tpOf_iff`: one bit per cell) — this is where obligation (3)'s `box`/`stab` half lands (Finding 3). Seriality (`fwd`/`bwd`) is the object's own; the admissibility set `Adm` (row 17) is defined in the lemma record, since the stabilization statement is over the carrier `ladderFrame` already has.

### Finding 2 — Obligation (2): run-layer phase 3, (C)'s general row

**Status**: OPEN mathematics; one positive fixture, no negative, no argument (README (C) row; (W) item 2). Statement shape, verbatim from the README: for every regular `ℤ`-model `M`, seam `(τ, t)`, formula `φ` and depth `1 ≤ k`, a finite labelled presentation `(Q, lab, step)` with `Fintype.card Q` below a computable bound in `φ`, such that `HitCl M τ t φ k = ↑(hitOf lab step (clNow φ) k)`:

```
theorem exists_hitPresented (M : TaskModel F.toTaskFrame) [F.IsRegular] (τ) (t) (φ) (k) (hk : 1 ≤ k) :
    ∃ (Q : Type) (_ : Fintype Q) (_ : DecidableEq Q) (lab : Q → (clSig φ).preds → Bool) (step : Q → Q → Bool),
      Fintype.card Q ≤ sizeBound φ k ∧ HitPresented M τ t φ lab step k
```

with `sizeBound φ k` a COUNT exhibited in the statement (the fixture's was `Nat.card (KType (clSig Fp) k) + 6`, `card_QA_presentationSize`), never an `∃ L`, never a complexity bound.

**Where the evidence is thin.** Model A is `box`/`stab`-free (`Fp`) with a finite-width slice (`Fin 3`); every landed (C)/(S) statement is forward-only (`Fp`). The general row ranges over `⊡`-bearing `φ` and infinite-width models — the two axes along which the refutations live (`not_finite_width_fmp` is `⊡`-bearing, infinite width is forced). Nothing in the tree tests `HitPresented` on either axis. The cheapest falsifier is therefore a probe on the `Node` model with a `⊡`-bearing formula at a seam `(t, pre k)`:

```
-- either headline is the deliverable; the probe records which
theorem hitPresented_node (t : ℤ) (k : ℕ) (hk : 1 ≤ k) :
    HitPresented NoFiniteWidth.M τ t Φ' (labN L) (stepN L) k          -- positive: a presentation of size L exhibited as a count
theorem not_hitPresented_node (t : ℤ) (k : ℕ) (hk : 1 ≤ k) {Q} [Fintype Q] [DecidableEq Q] (lab) (step) :
    ¬ HitPresented NoFiniteWidth.M τ t Φ' lab step k                   -- negative: (C)'s general row is FALSE, route R1 blocked at (C)
```

with `τ` the canonical history through `pre k` (`canon`, `path_eq_canon`) and `Φ'` the fixture witness `Φ` (fallback `D`, then `⊡Xp`, recorded in that order). A Hit-level negative would be the first in the tree and would block R1 — there is no fallback route — so this probe carries the highest information per line of anything on the frontier; a positive extends `Probe745`'s truncation argument to infinite width and `⊡` letters and gives the general row its second fixture.

**Dependencies on the landed substrate.** `Transport.lean`'s `inFamily_of_shrink_run` is shrink-direction only under a single-segment containment; on `Node` the pre-run is one constant block before the seam and the post-run one after, so the containment is again a fixture fact (as `run_subset_middle` was on model A). The unconditioned transport `↔` (threshold `3·(m₀ + p)`, recorded as a non-goal by 749) may be needed by the GENERAL row and is not needed by the probe.

### Finding 3 — Obligation (3): (S) beyond its landed corner

**Status**: assigned to (W) by the README itself; no standalone (S) record is warranted. Two machine-checked facts fix this:
- **WIDTH** (`Probe747.modelOf_incomplete`): for every `Cons` presentation on any `[Fintype Q]`, `modelOf` validates `Φ.neg` while `¬ PlusValidZTime Φ.neg` — "whatever clauses are added to `Cons`", because the width is a property of `ofSlicedStep`. Any (S)-extension on `modelOf` to `box`/`stab`-bearing `φ` is therefore a finite-width object class that cannot be the soundness half of a complete lift — guardrail (b) names exactly this shape.
- **COLLAPSE** (`stab_iff_of_presented_nowUnique`): at a trace-level `Presented` seam with `nowUnique`, `ψ ↔ ⊡ψ` for every closure formula — so (S)'s own realization hypothesis cannot witness any `⊡`-refutation; the realization hypothesis of the lift must be Hit-level per cell.

Consequence for the design: the `box`/`stab` half becomes an **acceptance clause of the ladder realization theorem** (Finding 1: `LadderCons` pins `lab q (box ψ)` to one global bit and `lab (q,c,n) (stab ψ)` to the cell's bit, with `anchorCons_anchorCells` the completeness side of exactly those equations), and the "every seam but the one" half **is** the composition theorem (Finding 4). The standalone theorem `presented_modelOf` is untouched; nothing is retired. A record titled "(S) for `box`-bearing `φ`" would be filed against the README's own assignment and is not proposed.

### Finding 4 — The lift, named in the tree and filed nowhere

The (W) row's statement shape: one presentation-level object witnesses `¬ PlusValidZTime φ` for some regular `ℤ`-model, history and time. With both halves of obligation (ii) and the anchor layer:

```
theorem not_plusValidZTime_iff_ladderRefutes (φ : PlusFormula) :
    ¬ PlusValidZTime φ ↔
      ∃ (Q : Type) (_ : Fintype Q) (_ : DecidableEq Q) (lab) (step) (pend) (hA : Adm …),
        Fintype.card Q ≤ objBound φ ∧ LadderCons φ lab step pend ∧ LadderRefutes φ lab step pend
```

(→) is the completeness half (anchor layer + (C)'s general row + the stabilization bound); (←) is the ladder realization theorem at the refuting cell. `objBound φ` is a count (cells times deadline classes), never a running time; `Decidable (PlusValidZTime φ)` would then follow by finite enumeration over objects of bounded size, and that corollary — the AIM — is stated only in this record, never earlier. Depth `k = 1` throughout. It is not costable until both predecessors have a shape, and its research phase re-derives the statement from them.

### Finding 5 — Decomposition, dependency edges, `file_scope`, depth, costability

Applying Component 0 (consolidate unless (a) disjoint scope, (b) different type/domain, (c) real dependency ordering, (d) size) and CLAUDE.md's batching rule (an unordered overlap becomes an edge, not an exclusion):

| # | Record (statement, not prose) | Type | Depth | Logical deps | Serialization deps | `file_scope` (narrowest known) | Costable? |
|---|---|---|---|---|---|---|---|
| T1 | `preCell_stable` / `preCell_zero_ne` / `postCell_stable` on `NoFiniteWidth.M` for `Φ` (fallback `D`) — a wired probe | lean4 | none (cells) | — | — | `specs/evidence/seam-gluing-ray-product/node-cell-stabilization.lean` (new), `scripts/check-evidence-probes.sh`, `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (Evidence paragraph) | **Yes**: 400-800 lines, 1-2 implement dispatches. Basis: `backward-dual-asymmetric-fixture.lean` (619 lines, same fixture, one operator) and `deadline-ladder-branching.lean` (~100 lines) — both measured this round by `wc -l`-equivalent line references in 0.2 |
| T2 | `hitPresented_node` or `not_hitPresented_node` on `NoFiniteWidth.M`, seam `(t, pre k)`, `Φ` (fallbacks `D`, `⊡Xp`), every `k ≥ 1` — a wired probe | lean4 | `1 ≤ k` | — (reuses T1's history characterization of `pre k`, an efficiency not a logical need) | T1 (script + README overlap) | `specs/evidence/seam-gluing-ray-product/hit-presented-node.lean` (new), `scripts/check-evidence-probes.sh`, `RaySummary/README.md` | **Yes, with a wide band**: basis `hit-presented-model-a.lean` 1526 lines, two implement dispatches under `--hard` [CARRIED-UNVERIFIED: `specs/749_.../summaries/01_*.md` Effort line]; a negative is cheaper than a positive |
| T3 | `ladderModel`, `Adm`, `ladderCell_stabilizes` (both counters; exhibited `B`, fallback `∃ B`) — library | lean4 | none | T1 (verdict fixes the bound shape) | T2 (README overlap) | `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` (new), `RaySummary.lean`, `FormalSystem.lean`, `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`, `scripts/check-module-invariants.sh`, `docs/theorem-index.md`, `RaySummary/README.md`, `typst/generated/status.typ` | **No** — the statement's bound shape and the admissibility set are fixed by T1's verdict; no comparable in the tree (the anchor layer, 406 lines, is a different kind of statement) |
| T4 | `LadderCons`, `ladderCons_localRun`, `ladderRealized : HitCl (ladderModel …) τ t φ k = ↑(hitOf (truncate B …) …)` per ladder cell, for ALL `φ` including `box`/`stab` letters (obligation (3)'s first half as an acceptance clause) — library | lean4 | `1 ≤ k`, consumer depth `k = 1` | T3 | — | `RaySummary/LadderRealize.lean` (new) + the T3 shared set | **No** — sized by T3's bound and by how much of `Realize.lean`'s 1004 lines transfers; the README records it has no figure |
| T5 | `exists_hitPresented` with `sizeBound φ k` a count — (C)'s general row — library | lean4 | `1 ≤ k` | T2 (a negative there blocks this; a positive supplies the second fixture) | T4 (shared set) | `RaySummary/HitComplete.lean` (new) + shared set | **No** — open mathematics, no general argument in the tree; research-first; `[BLOCKED]` is an honest outcome |
| T6 | `not_plusValidZTime_iff_ladderRefutes` and its `Decidable (PlusValidZTime φ)` corollary by bounded enumeration — the lift, obligation (3)'s second half — library | lean4 | `k = 1` | T4, T5 | — | `RaySummary/Lift.lean` (new) + shared set | **No** — statement fixed by T4/T5; research-first |

Order (Kahn): T1 → T2 → T3 → T4 → T5 → T6; every edge above is recorded in `dependencies[]` (the serialization edges annotated as such in the descriptions, as the 721 spec did for its collisions). Why six and not fewer: T1/T2 vs T3-T6 divide by (a) (evidence vs library territory) and (c); T1 vs T2 by (d) and different statements; T3 vs T4 by (c) and the costability boundary the README itself draws ("no cost figure until that lemma"); T5 by (c) against T2 and by being the one open-mathematics item; T6 by (c) against both chains. Why not more: no (S)-extension record (Finding 3); no record for `Adm` alone (it is T3's definition); no second-fixture record beyond `Node` until T2 reports.

Cross-task collisions outside the set (0.4): 744 (`RaySummary/README.md`, `check-module-invariants.sh`) collides with all six and is `not_started` — idle at dispatch time admits with an advisory; 734 (`check-evidence-probes.sh`, Stage 0 `[PARTIAL]`) collides with T1/T2 and is never moved by this record; 410 (`typst/generated/status.typ`, `planned`) collides with T3-T6 through the generated file. None of these is given an edge: edges are for the successor set's own ordering; cross-set overlaps are the admission gate's to serialize, as the ROADMAP note on 749/750 already describes.

### Finding 6 — Filing mechanics (for the implementation phase)

- Creation is the `/task` Create Task Mode write (`commands/task.md` Step 6): one `state-write.sh` call per task with the creation object carrying `dependencies` and `file_scope` directly (both are plain schema fields, `state-management-schema.md` rows 130-131/300/374), `topic: "decidability"` (already in `active_topics`), `task_type: "lean4"`, `--regen-todo`; then `manage-topics.sh set N decidability`. `next_project_number` is re-read before each write; the numbers T1-T6 receive are not predictable now (758 at research time).
- `--depends-on-add` is for edges between ALREADY-EXISTING tasks and is restricted to a status-no-op call; it is not needed when the edges are written at creation. `--file-scope-add` is a research/plan-postflight consumer and likewise not needed at creation.
- After filing: `bash .claude/scripts/validate-state.sh specs/state.json` (Checks 8/9 are the coarse-scope and duplicate detectors); the `file_scope` entries above are files, not directory roots, except that 750's precedent of declaring `specs/evidence/seam-gluing-ray-product/` as a root is NOT repeated (it manufactures false collisions).
- `specs/ROADMAP.md` Stage 1: hand-authored edit adding the six `/orchestrate` lines (dependency-inclusive batches: `T1,T2` then `T3,T4` then `T5,T6`, `--hard --lit` for the library records since HWZ 2000 / GKWZ 2003 are indexed) and the Stage 1 bullets; 752 records that `--regenerate` is inoperative on this layout, so no generator is relied on. Task numbers are permitted in `specs/**`.
- Deliverable hygiene: the only file outside `specs/**` a filed record would plausibly touch at filing time is `RaySummary/README.md`'s "Successor" paragraph, which already says "their own records"; this record recommends NOT editing it (nothing durable to add, and task numbers are forbidden there). `check-task-references.sh` is run on any non-`specs/**` file touched regardless.
- Commit: `task 757: complete implementation` style per `git-workflow.md`, scoped staging of the spec, `state.json`, `TODO.md`, `ROADMAP.md` only.

### Codebase Patterns

- Statement-shaped records are the house style: 750's plan carried a `## Lean Challenge Statements` section whose signatures were pinned; the six records above are written so that their first statement can be pinned the same way at planning.
- Every quantity in `RaySummary/` is a count with the `AnchorLayer.lean` disclaimer quoted verbatim where it appears (`theorem-index.md` rows 206-208); T3's `B`, T5's `sizeBound`, T6's `objBound` inherit the same sentence.
- Probes cite the library and re-prove nothing (`deadline-ladder-branching.lean`'s header rule); T1/T2 import `NoFiniteWidth.M` and `canon` rather than rebuilding `Node`.

### External Resources

- HWZ 2000 Def. 12 / Rem. 13 / Thm 14 and GKWZ 2003 Thm 13.6 are indexed (`specs/literature-index.json`) and are the literature description of the obstruction the README records (the run set is not free here); they orient T4/T6's shape and source no claim. `--lit` is recommended for T3-T6.
- No Mathlib search was needed: every anchor is a project declaration, verified by compile (0.1) rather than by `lean_leansearch`/`lean_loogle`.

### Recommendations

1. Implementation phase writes `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` in the 721 format: Section 0 = this report's 0.1-0.5 re-run (not copied — the compile scratch and gate are cheap), Sections A-C = Findings 1-3 with the statement shapes, Section D = Finding 4, Section H = the six records with the numbers they receive, a State-write disclosure, and a "Stage 0 described, not moved" section naming 712/713/734/709.
2. File T1-T6 as in Finding 6, in Kahn order, with the typed edges and `file_scope` above; record in each description the costability status verbatim from Finding 5 and the `[BLOCKED]` contingency where it applies.
3. Edit `specs/ROADMAP.md` Stage 1 by hand (three `/orchestrate` lines; bullets for the six; a sentence that T2 is the highest-information probe and that a Hit-level negative there is a Stage 0 ruling, not an agent transition).
4. Do not edit any `FormalSystem/`, `docs/`, `scripts/` or `Tests/` file in 757; do not touch 712/713/734/709/716/714.
5. A sorry-free path exists for every deliverable of 757 (it proves nothing); for T1-T6 the zero-debt posture is in their descriptions: a failed stabilization or a Hit-level negative is recorded as the obstruction and the task marked `[BLOCKED]`, never a `sorry`, an axiom, or a finite-fibre retreat.

## Decisions

- **D1**: Obligation (3) gets no standalone (S) record; its halves are an acceptance clause of T4 and the statement of T6 (Finding 3). Grounds: the README's own assignment and the WIDTH/COLLAPSE pair. Re-openable by `/revise`; not a user ruling.
- **D2**: The stabilization statement is over both counters `(c, n)` (Finding 1), exhibited bound `B := |cl φ|` first, `∃ B` as fallback.
- **D3**: Run-layer phase 2 is two records (T3 lemma, T4 theorem), deviating from the README's "its own record" singular by splitting at the costability boundary the README itself names; recorded so the user can fold them back with one `/revise`.
- **D4**: `Node` (`NoFiniteWidth.M`) is the fixture for both probes — a library model, infinite width, `⊡`-bearing witness, one-region special case of the ladder.
- **D5**: Serialization overlaps inside the successor set become explicit edges (CLAUDE.md batching rule); overlaps with 744/734/410 outside the set are left to the admission gate and named in the descriptions.
- **D6**: T5 and T6 are filed despite having no cost figure, because filing is in scope by user instruction and both have a statement shape and a `file_scope`; their first phase is research, and `[BLOCKED]` is the honest outcome if the mathematics does not close.

## Risks & Mitigations

- **T2 returns a Hit-level negative** → (C)'s general row is false and R1 has no fallback. Mitigation: the probe header records it as such; T5/T6 are then user-ruled (Stage 0), never transitioned by an agent; T3/T4 keep standalone value as the HWZ Thm 14 (⇐) formalization for the ladder.
- **T1 refutes stabilization even at the fixture** → infinitely many cells. Mitigation: T3's `∃ B` fallback is also false then; T3 is marked `[BLOCKED]` with the obstruction; no finite-fibre retreat.
- **`Φ`'s closure makes probe type computations unwieldy** → fallbacks `D`, then `⊡Xp`, recorded in that order in the probe header; the chosen formula is written into the statement.
- **Collision churn with 744** (README/invariants) → 744 is a markdown task; either run it first in isolation or accept the gate's serialization; no edge is added across sets.
- **`typst/generated/status.typ`** regenerated by the pre-commit hook (749/750 precedent) → declared in T3-T6's `file_scope` so the gate sees it.
- **Filing order vs. renumbering** → numbers assigned at filing; the followup-scope-spec records them after the fact; `specs/**` may cite them.

## Tactic Survey Results

- Not applicable (no tactic survey performed): this dispatch proves nothing and investigates no proof goal; every verification is a `#check`/`#print axioms` compile record and a gate run.

## Context Extension Recommendations

- **Topic**: The two-counter ladder state and where the `n`-dependence enters cells
  **Gap**: `.claude/context/project/lean4/` has no note on the `RaySummary` run layer; the README's "(q, deadline class)" shorthand cost this round a re-derivation from `Count`'s definition.
  **Recommendation**: a short `context/project/logic/domain/ladder-run-layer.md` stating the carrier `Q × ℕ × ℕ`, `Count`/`Drift`, and the two sources of counter-dependence, once T3 fixes the statement.

## Appendix

### A. `specs/evidence/seam-gluing-ray-product/` (20 files, this round)

`b2b-frame-constructor-branching`, `backward-dual-asymmetric-fixture`, `backward-dual-mirror-fixture`, `cslib-ramsey-port-feasibility`, `deadline-ladder-branching`, `device-selection-probe`, `finite-graph-stab-summary`, `hit-presented-model-a`, `ktype-summary-substrate-probe`, `mosaic-germ-amalgamation`, `mosaic-stab-saturated`, `path-quantifier-alternation`, `presented-not-complete`, `presents-is-seam-decidedness`, `quasistate-does-not-determine-hit`, `stab-depth-stratification`, `stab-depth-two-probe`, `stab-depth-two-shared-stratum`, `stab-fibre-is-ray-product`, `w-soundness-shape-refuted` (all `.lean`).

### B. Commands run (verification)

- `lake env lean <scratchpad>/Verify757.lean` (55 check/print lines; exit 0)
- `bash scripts/check-evidence-probes.sh` (detached; exit 0; 27 PASS, 1 SKIP)
- `bash .claude/scripts/lake-build-guard.sh status`; `find FormalSystem -name '*.lean' -newer .lake/build/lib/lean/FormalSystem.olean`
- `grep -rn 'Decidable (PlusValidZTime' FormalSystem/ Tests/ specs/evidence/ --include=*.lean` (14 hits, 0 statement-level)
- `grep -i stabiliz FormalSystem/Metalogic/Decidability/RaySummary/*.lean`
- `jq` over `specs/state.json` for rows in 0.4

### C. Precedent format elements reused

721 spec: Section 0 (compile record, declaration anchors, script/index anchors, task-record anchors, differences), per-task sections with "Current record / What the tree says / Scope change / What this task must NOT do / Action required", Section H "New tasks to file" with title / type / deps / `file_scope` / description, State-write disclosure. The one deliberate departure: Section H's "file with `/task`, by the orchestrator or the user" becomes "filed by this task's implementation phase".
