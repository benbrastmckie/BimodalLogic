# Implementation Summary: Task #495

- **Task**: 495 - Determine TM completeness status over task frames
- **Status**: [COMPLETED]
- **Started**: 2026-09-01T10:18:00Z
- **Completed**: 2026-09-01T11:05:00Z
- **Effort**: ~2.5 hours
- **Dependencies**: None
- **Artifacts**: plans/01_tm-completeness-formalization.md (this round)
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Landed all nine phases of the plan: the machine-checkable portion of the finding that TM is not
complete over task frames. The reduction pinning "TM complete over task frames" and "forward
conservativity at `.Base`" as the same unasserted proposition, the `(Sp)` validity witness (CEB's
TM⁺ half), a binder-weakened discrete BL soundness theorem, and the `Z1` countermodel over
`ℚ ×ₗ ℤ` closing CEF with both halves machine-checked. `Conservativity.lean`'s docstring was
corrected to be row-dependent rather than claiming a single shared "countermodels alone" gap.

## What Changed

- `FormalSystem/Semantics/DurationClassification.lean` — added `duration_dense_or_least_pos`,
  the Archimedean-free order dichotomy (Lemma A)
- `FormalSystem/Semantics/LexCarrier.lean` (new) — `SuccOrder`/`PredOrder` instances for
  `ℚ ×ₗ ℤ`, plus non-Archimedean documentation examples
- `FormalSystem/Semantics/BLSchemaValidity.lean` (new) — DF/DN semantic lemmas (Lemmas B/C) and
  DF's `PredOrder` past-dual
- `FormalSystem/Semantics/BLValidity.lean` — added `BLValidDiscreteSucc` and its weakening lemma
- `FormalSystem/Metalogic/TMCompletenessReduction.lean` (new) — `TMCompleteBase ↔ ForwardBase`
  and the `.Discrete` mirror, as equivalences between unasserted `Prop`s
- `FormalSystem/Metalogic/BaseLanguageSoundness.lean` — added
  `blValidDiscrete_iff_validDiscrete_tr` and `bl_soundness_discrete_succ` (+ empty-context form),
  the binder-weakened discrete BL soundness theorem proved directly by induction
- `FormalSystem/Metalogic/SpWitness.lean` (new) — `Sp`, `blValid_df_or_dn`, `blValid_sp`,
  `sp_translate` — the CEB witness's TM⁺ half, with no appeal to TMP-NB/M5
- `FormalSystem/Metalogic/Z1Countermodel.lean` (new) — the countermodel over `ℚ ×ₗ ℤ`,
  `not_bl_derivable_z1` and `blValidDiscrete_z1` (both CEF deliverables), and
  `tmCompleteDiscrete_refuted`
- `FormalSystem/Metalogic/Conservativity.lean` — module docstring corrected: CEF now records
  both halves as machine-checked (and the carrier corrected from `ℤ ×_lex ℤ` to `ℚ ×_lex ℤ`);
  CEB records the TM⁺ half as machine-checked and the TM half as unavailable in principle (not
  merely unbuilt); added the Kripke-level answer (report §5(i)) and the two live-paper facts
  (`def:TMplus-f`'s Hölder pin, the commented line 4614 author's-position note); cross-referenced
  `TMCompletenessReduction.lean` from the "why it must not be sorry-ed" section
- `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/README.md` — new module entries

## Decisions

- Used `ℚ ×ₗ ℤ` (not `ℤ ×_lex ℤ`, the report's original suggestion) as the CEF countermodel
  carrier, since it is the carrier `BXCanonical/DiscreteCarrierProbe.lean` already probes for the
  `FrameClass.Base` layer, and `Semantics/LexCarrier.lean`'s `SuccOrder`/`PredOrder` instances
  are needed regardless.
- The twelve `.Base`-classed BL axioms' swap-validity (needed by `bl_soundness_discrete_succ`'s
  `temporal_duality` case) is obtained proof-theoretically — composing `bl_soundness_valid` with
  the TD proof rule itself — rather than via a semantic swap-validity development, avoiding a
  BL⁺-sized (1300+ line) parallel `SoundnessLemmas`-style file.
- `exact`/`show`-based defeq closing was used throughout `Z1Countermodel.lean`'s numeric goals in
  preference to `rw`/`simp only [single lemma]`, after discovering the latter does not reliably
  fire through `ofLex (toLex …)` on concrete `ℚ ×ₗ ℤ` literals at reducible transparency, while
  `exact`'s full-defeq unification does.

## Plan Deviations

- None (implementation followed plan)

## Verification

- Build: Success (full tree, 0 errors, 2284 jobs)
- Tests: N/A (no test suite for this artifact type)
- Files verified: Yes — every new top-level declaration checked via `lean_verify`:
  `duration_dense_or_least_pos`, `df_valid_of_isLeast_pos`, `df_valid_of_succOrder`,
  `dn_valid_of_denselyOrdered`, `swapBL_df_valid_of_predOrder`, `tmCompleteBase_iff_forwardBase`,
  `tmCompleteDiscrete_iff_forwardDiscrete`, `blValidDiscrete_iff_validDiscrete_tr`,
  `bl_soundness_discrete_succ`, `bl_soundness_discrete_succ_valid`, `blValid_sp`, `sp_translate`,
  `not_bl_derivable_z1`, `blValidDiscrete_z1`, `tmCompleteDiscrete_refuted` — each shows exactly
  `[propext, Classical.choice, Quot.sound]`, no `sorryAx`.
- Hard-constraint audit: `grep sorry` across all touched files returns only prose/comment
  mentions; the only occurrences of the forbidden `forward` theorem shape are inside quoted
  docstring code fences in `Conservativity.lean` and `TMCompletenessReduction.lean`, never as an
  actual declaration.
- `check-paper-definitions.sh`: reports drift on `thm:extension`, `def:BLplus-defined`,
  `def:time-shift-histories`, plus two dangling anchors (`def:frame#Spherical`,
  `cor:spherical-finite`) — none of these anchors are referenced by this task's new files;
  the drift is attributable to concurrent sibling tasks' work on the frame-fibration layer.

## Impacts

- CEF (`FrameClass.Discrete`) is now refuted with both halves machine-checked; the tree can cite
  `Z1Countermodel.not_bl_derivable_z1` / `Conservativity.z1_translate` together as a closed
  result rather than "documented, not machine-checked."
- The completeness/conservativity identity (`TMCompletenessReduction.lean`) closes a second
  avenue by which a future dispatch might attempt the forbidden forward-conservativity claim
  under the "TM completeness" name.
- CEB's TM⁺ half is now available (`SpWitness.sp_translate`) as a citable in-tree fact,
  independent of the paper's now-deleted TMP-NB/M5 derivation.

## Follow-ups

- **Proposed, not created**: a CEB task for the native BL soundness layer — a frame notion
  outside `TaskFrame`, a native (non-`TaskFrame`-bound) BL truth definition, a native BL
  soundness theorem verifying all 11 TM axiom schemata directly (plus MP/MN/temporal
  necessitation/TD via swap-strengthened induction), then the two-fibre instance and the `(Sp)`
  evaluation. Sized roughly as `SoundnessLemmas/` on the BL⁺ side, simpler because BL has no
  `untl`/`snce`.
- The Sahlqvist-canonicity characterization of TM's Kripke class (S5 ⊗ Kt4.3 + MF, report §5(i))
  remains unformalized and is recorded in `Conservativity.lean`'s docstring as the principled
  answer's provenance, not as a repository result.

## References

- `specs/495_determine_tm_completeness_status_over_task_frames/plans/01_tm-completeness-formalization.md`
- `specs/495_determine_tm_completeness_status_over_task_frames/reports/01_tm-completeness-status.md`
