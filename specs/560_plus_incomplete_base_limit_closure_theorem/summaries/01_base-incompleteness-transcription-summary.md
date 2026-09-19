# Implementation Summary: Task #560

- **Task**: 560 - plus_incomplete_base_limit_closure_theorem
- **Status**: [COMPLETED]
- **Started**: 2026-09-19T01:21:56Z
- **Completed**: 2026-09-19T02:30:00Z
- **Effort**: ~1.2 hours wall clock (plan estimate 9 hours; the probes were transcription-ready)
- **Dependencies**: None
- **Artifacts**: plans/01_base-incompleteness-transcription.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Landed the machine-checked theorem that the current TM+ axiom set is incomplete over the
all-histories task semantics at Base: `plus_incomplete_base (p) : PlusValid (blc p) ∧ ¬ PlusDerivable
FrameClass.Base [] (blc p)`, with `blc p := (⟐Fp ∧ ⊡G(p → ⟐Fp)) → ⟐(Fp ∧ G(p → Fp))`, plus the
corollary `not_plus_complete_base` (the hypothesis of `starConservative_of_plusComplete` at Base,
refuted). Five new library modules transcribe the two probes against the live definitions; the
headline is pinned in the C14 baseline pair, and every README row and docstring that said general
TM+ completeness is open now carries the three-part status. All six plan phases completed; no
completeness theorem is stated anywhere.

## What Changed

- `FormalSystem/Metalogic/Independence/PastedCoarseModels.lean` — new. `CoarseModel.PasteClosed`
  (a `def`, not a structure field; `CoarseModel` and `CoarsenedModels.lean` untouched),
  `c_truth_congr_from`, `c_truth_congr_upTo`, `c_paste`, `c_paste'`, `c_untl_paste`,
  `c_snce_paste`, `PCValid`, `plusAxiom_pcValid`, `plus_pcValid_and_reflect_time`,
  `not_plusDerivable_of_pcRefuted` (11 declarations, as hypothesised).
- `FormalSystem/Semantics/PlusLanguage/PlusLimitClosure.lean` — new.
  `PartialHistory.exists_maximal_of_chainClosed` (general Zorn-plus-extension lemma),
  `restrictIic`, `LCProp`, `lcProp_restrictIic`, `lcProp_chainSup`, `limit_history`, `blc`,
  `blc_plusValid` (8 declarations, as hypothesised).
- `FormalSystem/Metalogic/Independence/LimitClosureFrame.lean` — new. `EW`, `eR`, `eπ`,
  `eR_trans`, `eR_dense`, `eR_succ`, `eRel` and its six lemmas, `eRel_limit`,
  `sInter_nonempty_of_directed_of_finite_mem`, `eR_fwd_finite`, `eRel_fib_hub_or_finite`,
  `eRel_seg_hub_or_finite`, `eRel_saturation`, `eFrameOver`, `EF`, `ef_taskRel_iff`,
  `isWalk_state`, `walk_lt`, `histOfWalk`. Every `FrameOver` field discharged, Saturation included.
- `FormalSystem/Metalogic/Independence/LimitClosureCountermodel.lean` — new. `evFalse`,
  `eR_budget`, `eR_evFalse_aux`, `eR_image_mem`, `mem_eR_image`, `hist_image_mem`,
  `exists_hist_of_evFalse`, `eK`, `eK_pasteClosed_aux`, `eK_pasteClosed`, `blc_cRefuted`,
  `blc_not_plusDerivable_base` (12 declarations, as hypothesised).
- `FormalSystem/Metalogic/Independence/PlusIncompleteness.lean` — new. `plus_incomplete_base`,
  `not_plus_complete_base`; module docstring carries the statement, what is and is not shown, the
  consistency check (under stability = identity the formula is a tautology, hence a theorem of
  TM+ + Determined; the countermodel is necessarily nondeterministic), and the one-line reading.
- `FormalSystem/Metalogic/Independence.lean`, `FormalSystem/Semantics/PlusLanguage.lean` —
  imports, contents bullets, and result 5 in the Independence aggregator's results list.
- `scripts/check-module-invariants.sh` — C14 pin, one line in each of `C14BASE` and `C14LEAN`,
  same position (after `deterministic_not_plusDefinable`).
- `docs/theorem-index.md` — one row (Base, `pcq pinned:C14`) and two corrected passages.
- Status sweep (prose and docstrings only): `Metalogic/Conservativity/Plus/README.md`,
  `Metalogic/README.md`, `Metalogic/Independence/README.md`, `Metalogic/Deterministic/README.md`,
  `Metalogic/Conservativity/README.md`, `Metalogic/Conservativity/Star/README.md`,
  `Syntax/StarLanguage/README.md`, root `README.md`; docstrings in `Metalogic.lean`,
  `Metalogic/Conservativity.lean`, `Metalogic/Deterministic.lean`, `Conservativity/Plus.lean`,
  `Conservativity/Plus/Forward.lean`, `Conservativity/Star.lean`, `Conservativity/Star/Forward.lean`,
  `Deterministic/Completeness.lean`.
- Generated inventory blocks regenerated in each file-adding phase (`--emit-inventory`), with the
  description cells filled by hand.

## Decisions

- Proofs were copied verbatim from the probes; only headers, docstrings, namespaces and the items
  below differ.
- `PasteClosed` lives in the `CoarseModel` namespace (`K.PasteClosed`). This is the only rename
  relative to the probe.
- The wildcard arm of `plusAxiom_pcValid` became two `case` arms followed by
  `all_goals exact absurd trivial hn`; the `by_cases` on `IsNaive` is kept, so a future naive
  constructor lands in the first branch.
- `FormalSystem.Semantics.Walk.IsWalk` was reused at `eR` (the plan's default); no local
  abbreviation was needed. The frame module imports `Semantics/Correspondence/FwdRecPeriodicity`
  for it and does not import `CoarsenedModels`.
- Six tactic-mode `show` calls in the countermodel became `change`: the `show` style linter would
  otherwise count against the zero warning budget (C28) for a new file.
- `not_plus_complete_base` instantiates the headline at the atom `⟨"p", none⟩`.
- Attribution was checked against the corpus rather than taken from the task text: Thomason 1984,
  section 4, formulas (19) (Burgess, 1977) and (20) (Thomason, 1978).
- The conditional-row wording everywhere says: hypothesis refuted at Base, conditional vacuous
  there, conservativity at Base NOT decided (no separating witness), open at the other three
  classes. Two pre-existing sentences that overclaimed ("the two questions coincide", "equivalent
  modulo TM-star soundness") were corrected to the one-directional link that is actually proved.

## Plan Deviations

- **Phase 5, theorem-index sentence** altered: besides the one sentence the plan names, the closing
  "Completeness for TM-star" bullet of `docs/theorem-index.md` also asserted TM+ completeness open
  at every class; it was corrected in the same phase because the plan assigns that file to Phase 5.
- **Phase 6, census file list** altered: a wider grep (`TM⁺ completeness|completeness of TM⁺|...`)
  found stale statements outside the plan's list. All were edited, comments/prose only:
  `Metalogic/Deterministic.lean`, `Metalogic/Conservativity.lean`,
  `Conservativity/Plus/Forward.lean`, a second passage each in `Deterministic/Completeness.lean`
  and `Star/Forward.lean`, the root `README.md` open-problems bullet, and the conditional row of
  `Syntax/StarLanguage/README.md`. Census classification: every hit about TM+ completeness of the
  current axioms was edited; hits about TM-star completeness, TM/TM+ decidability, and "needs no
  TM+ completeness" remarks were left alone.
- No deviation touched a Lean statement or proof. `PlusAxiom`, `PlusDerivationTree`,
  `plus_soundness_validIn`, `forward_plus`, `plusDerivable_ofFormula_iff`, `CoarseModel` and
  `CoarsenedModels.lean` are unchanged; a mechanical check confirmed that every changed hunk in the
  eight swept `.lean` files lies inside a comment block.

## Verification

- Build: Success — guarded, detached `lake build` (2666 jobs) and `lake build BimodalTest`
  (2725 jobs), run after the last edit.
- `bash scripts/check-module-invariants.sh`: ALL CHECKS PASSED at the close of Phase 5 and again at
  the close of Phase 6 (C2, C3, C14 both halves, C21, C24, C27, C28 at 0 warnings, inventory).
  One intermediate run failed on C1/C2/C14/C16/C24 because a concurrent session had a file
  (`WeakCanonical/DenseModelSurgery/Lemma5.lean`) transiently broken mid-edit; it passed unchanged
  once that session's edit settled.
- Sorry count: 0 in the five new modules; C3 reports zero structural `sorry` across live
  `FormalSystem/` (the census hits are all under `FormalSystem/Boneyard/`, pre-existing, excluded).
- Vacuous count: 0.
- Axiom count: 15 `axiom` declarations, unchanged from the pre-task commit.
- Measured `#print axioms` (scratch files, nothing left in-tree): `plus_incomplete_base`,
  `not_plus_complete_base`, `blc_plusValid`, `blc_not_plusDerivable_base`,
  `not_plusDerivable_of_pcRefuted`, `EF`, `histOfWalk` — all `[propext, Classical.choice, Quot.sound]`.
- Plan compliance spot-check: `plus_incomplete_base` and `not_plus_complete_base` found; passed.
- `bash scripts/readme-lint.sh`: PASS. `.claude/scripts/check-task-references.sh`: PASS, 0 occurrences.
- Both probes still compile against the landed oleans.
- Tests: `BimodalTest` builds. Files verified: Yes.
- Challenge snapshot: no manifest exists for this task, so `--check` was not applicable. The
  landed `plus_incomplete_base` is stated through `blc`, definitionally equal to the challenge text
  by unfolding; `not_plus_complete_base` matches the challenge text verbatim.

## Impacts

- The TM+ status tables now read: completeness of the current axioms FALSE at Base; completeness
  of any extension OPEN at every class; decidability OPEN; the TM-star-over-TM+ conditional's
  hypothesis REFUTED at Base, conservativity there undecided.
- `not_plusDerivable_of_pcRefuted` is a reusable non-derivability tool for all of TM+ at Base: any
  formula refuted in one paste-closed coarse model is not a Base theorem.
- `PartialHistory.exists_maximal_of_chainClosed` is a reusable Zorn-plus-extension lemma for any
  chain-closed property of partial histories.
- Concurrency note: another session had uncommitted edits in the tree throughout. Generated line
  counts committed here in `FormalSystem/Metalogic/README.md` and the root `README.md` reflect the
  working tree at commit time, including a few lines from that session's files;
  `FormalSystem/Syntax/README.md` and `FormalSystem/Semantics/Ultraproduct/README.md` were rewritten
  by the generator for that session's files and were deliberately NOT staged.

## Follow-ups

- Recommended follow-up task: the ZTime corollary `plus_incomplete_ztime`. Validity at ZTime is
  immediate from Base. Non-derivability needs two ingredients: (a) a class-indexed `CValidIn fc`
  soundness recursion generalising `cValid_of_tm` and both dispatch lemmas in
  `CoarsenedModels.lean`, with the three ZTime arms (`prior_UZ`, `prior_SZ`, `z1`), threaded
  through `plusAxiom_pcValid`; (b) `FrameClass.ZTime.Sat EF` for the landed frame, which already
  lives over integer time. `lcPlus` could be added there as a second witness.
- Optional cleanup: move `sInter_nonempty_of_directed_of_finite_mem` beside
  `sInter_nonempty_of_directed_of_minimal` in `Semantics/TaskFrame.lean` (deferred for rebuild
  fan-out).
- Out of scope and still open: Dense and RTime non-derivability; the limit-closure schema LC_n at
  Base; completeness of any extension of TM+.
- Two `<!-- TODO: add description -->` cells in generated tables (`Deterministic.lean`,
  `Conservativity/Plus.lean`) pre-date this task and were left alone.

## References

- `specs/560_plus_incomplete_base_limit_closure_theorem/plans/01_base-incompleteness-transcription.md`
- `specs/560_plus_incomplete_base_limit_closure_theorem/reports/01_base-incompleteness-transcription.md`
- `specs/560_plus_incomplete_base_limit_closure_theorem/probes/01_blc-base-validity.lean`
- `specs/560_plus_incomplete_base_limit_closure_theorem/probes/02_blc-base-nonderivability.lean`
- `specs/560_plus_incomplete_base_limit_closure_theorem/handoffs/` (one per phase)
- Thomason, *Combinations of Tense and Modality* (1984), section 4, formulas (19) and (20)
