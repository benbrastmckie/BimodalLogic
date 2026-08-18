# Implementation Summary: Task 417 — the annotated bi-lasso decision layer (plan 05)

- **Plan**: `plans/05_annotated-bi-lasso-decision-layer.md`
- **Dispatch**: 6
- **Status**: PARTIAL — Phases 4–9 complete and sorry-free; Phase 10 `[BLOCKED]`; Phases 11–12
  not started, per the plan's stop-on-blocked instruction
- **Session**: sess_1787007762_7d00d6

## Outcome

Six phases landed, all sorry-free, all green, with `BiLasso/Basic.lean` byte-identical to its
committed state at every phase close (`git diff --exit-code`, as the plan's freeze requires).
Phase 10 is blocked on a machine-checked obstruction, and Phases 11–12 were deliberately not
started because they consume it.

| Phase | Status | Deliverable |
|---|---|---|
| 1, 2 | `[COMPLETED]` (inherited) | Preserved, not rebuilt |
| 3 | `[COMPLETED WITH EXCLUSIONS]` (inherited) | Preserved |
| 4 | `[COMPLETED]` | `BiLasso/Unfold.lean` |
| 5 | `[COMPLETED]` | `BiLasso/Periodic.lean`, `BiLasso/Annotation.lean` |
| 6 | `[COMPLETED]` | The three predicates; `BiLasso/Examples.lean` |
| 7 | `[COMPLETED]` | `BiLasso/TruthLemma.lean` — the first declared crux |
| 8 | `[COMPLETED]` | `BiLasso/Decide.lean` |
| 9 | `[COMPLETED]` | `BiLasso/Enumerate.lean` |
| 10 | `[BLOCKED]` | `BiLasso/SmallModel.lean` (groundwork only) |
| 11, 12 | `[NOT STARTED]` | Not started — they consume Phase 10 |

## What was built

**Phase 4 — the exact ℤ one-step unfolding.** `truth_untl_succ` and `truth_snce_pred`, stated as
biconditionals over every `TaskModel` on ℤ, every history, time and formula pair — no closure
restriction, no lasso. The `snce` mirror is proved directly; `temporal_duality` is a statement
about derivability, not `TruthAt`, so it does not transport. Mathlib's ℤ-induction recursors are
`Int.leInduction` / `Int.leInductionDown` (the plan's `Int.le_induction` names are deprecated
aliases); they are wrapped at `Prop` as `Int.rightInduction` / `Int.leftInduction`.

**Phase 5 — periodic decoding and the `Annot` datatype.** The duplication grep found only
`Basic.lean`'s own `structure BiLasso`, so the generic `Periodic.lean` was written as planned
rather than reusing anything. Alignment between labels and states is carried by a single
`Annot.readIndex` plus `Annot.label_unroll_aligned`, which proves the two decodings read the same
segment at the same offset in all three regimes — the three length-agreement fields are genuinely
consumed there.

**Phase 6 — the three predicates, with non-vacuity.** `LocalCoherent` (six clauses, all
biconditional), `Fulfilling`, `BoxOracleSound`. Witnesses: `posAnnot` satisfies both predicates;
`negAnnot` satisfies `LocalCoherent` and **fails** `Fulfilling`, carrying `p U q` around a loop
where `q` never holds. `fulfilling_not_implied_by_localCoherent` records the separation.
`boxOracle_false_not_sound` was added beyond the plan's task list to discharge the phase's own
criterion that `BoxOracleSound` not be unconditional.

**Phase 7 — `truth_along_annot`.** The first declared crux, compiled on the first attempt. The
two nested inductions are kept textually separate: `untl_mem_label_of_witness` /
`snce_mem_label_of_witness` isolate the inner induction on witness distance, and the outer
induction on formula structure is generalised over the time, which is what the inner recursion at
`t ± 1` requires. The statement covers the whole closure — no temporal-nesting-free fragment, no
modal-depth bound, no frame-class side condition.

**Phase 8 — decidability, and the corrected scan bound.** `scan_forward` / `scan_backward`
recover the refuted Phase 3 sentence with "property of the state sequence" replaced by "property
of the label", which is true because the annotation is periodic *by construction*. Both
predicates then collapse to one finite window. `Fulfilling`'s reduction needed the two hard
position shifts (`untlObl_shift_back`, `snceObl_shift_fwd`), each requiring a second period of
headroom so that the guard is known across a **complete residue system** and hence across the
whole periodic region (`mem_all_neg_of_period` / `mem_all_fwd_of_period`).

The window was **derived, not guessed**: `[-2|back|, |mid| + 2|fwd|)`, size
`2|back| + |mid| + 2|fwd|` — exactly the order the plan's Scope Hypothesis asserted. It is exposed
as `fulWindowLo`/`fulWindowHi` and `cohWindowLo`/`cohWindowHi` for consumers to read off.
No `open Classical`, no `Classical.dec` anywhere the decision procedure can reach; the `#guard`
smoke tests confirm the instances compute and discriminate (`true, true, true, false` on the two
witnesses).

**Phase 9 — bounded enumeration.** `boundedBiLassos` and `boundedAnnots`, with completeness and
soundness both ways. `boundedBiLassos flipPresentation 2 = 6`, hand-checkable: over the two-state
flip presentation the path is fixed by its value at the origin (2 choices) and the only remaining
freedom is `|mid| ∈ {0,1,2}`.

**Phase 10 — groundwork only.** `typeAt` and the proofs that a genuine history's type sequence is
locally coherent (consuming Phase 4's unfolding lemmas, exactly where the plan predicted) and
fulfilling. Both land sorry-free and are consumed by either repair of the blocker.

## The Phase 10 blocker

Two independent obstructions, both to the *extraction*:

1. **Origin anchoring.** A `BiLasso` has no left prefix, so the extraction's origin is forced to
   the backward repeat `c₂`, putting the point of interest at lasso position `-c₂`. Phase 12's
   specified `check` reads position `0` only. Demanding `c₂ = 0` demands a recurrence of the type
   at the point of interest, and `evidence/phase10-origin-anchoring-obstruction.lean` exhibits a
   total history and a closure formula whose truth set along it is exactly `{0}` — so no such
   recurrence exists there. Sorry-free, `lake env lean` exits 0, four `#print axioms` clean.
2. **No explicit bound.** The good-cycle condition follows from a recurrence argument that gives
   existence with no bound on the cycle length. The plan's asserted `P.card · 2^k · 2^k` needs the
   Büchi degeneralisation with a real `pending` component; only the pair `(state, type)` landed.

Neither is repairable inside the phase without changing a deliverable, which
`.claude/rules/plan-compliance.md` requires be raised as a blocker rather than substituted. The
recommended repair is cheap: let `check` range over a position in the already-derived finite
window instead of only `0`. Full detail is in the plan's Phase 10 blocker record.

## Plan Deviations

- **Phase 9, `boundedAnnots` signature** *(altered)*: takes the box oracle `bx` as an explicit
  parameter, because `LocalCoherent` is stated relative to one and the filter cannot be applied
  without it.
- **Phase 9, subset universe** *(altered)*: built from `List.sublists` of the closure's underlying
  list rather than `Finset.powerset`, because `Finset.toList` is **noncomputable** and would have
  made the whole enumeration noncomputable. `mem_closureSubsets` / `closureSubsets_sub` prove the
  two agree.
- **Phase 10** *(blocked)*: tasks 4–8 not completed; see the blocker record.
- Phases 11 and 12 not started, as the plan directs when Phase 10 blocks.

## Verification

- `lake build` exits 0.
- Zero `sorry`, zero vacuous definitions, zero new axioms under `BiLasso/`.
- `#print axioms` on `truth_untl_succ`, `truth_snce_pred`, `Annot.label_unroll_aligned`,
  `posAnnot_fulfilling`, `negAnnot_not_fulfilling`, `truth_along_annot`,
  `instDecidableLocalCoherent`, `instDecidableFulfilling`: `[propext, Classical.choice,
  Quot.sound]` in every case — no `sorryAx`.
- `BiLasso/Basic.lean` byte-identical to its committed state (`git diff --exit-code`).
- No `FormalSystem.Metalogic.BXCanonical.*` import anywhere under `BiLasso/`.
- `check-module-invariants.sh`: the same three groups fail as at the Phase 4 baseline — C1
  (`lake build BimodalTest`), C6 (7 unreachable), C9 (1 task-number citation). C6 was held at the
  baseline count of 7 by manifesting the eight new modules, the mechanism the previous dispatch
  already used for `Basic.lean`; all 16 manifested modules compile in isolation.
- `lake build BimodalTest` fails at exactly `BoxSpreadProbe`, `RegionGateProbe`,
  `TableauConformance` and no others — identical to baseline, not repaired here.
- `check-task-references.sh`: PASS. `readme-lint.sh`: clean for `BiLasso/`.

## Reported for a separate task (not fixed here, per plan instruction)

The argument roles in `Metalogic/BXCanonical/Quasimodel/Construction.lean` are stale against the
guard-first migration. `:57` reads
`Formula.untl ψ φ ∈ h1.formulas → ψ ∉ h1.formulas → φ ∈ h1.formulas ∧ Formula.untl ψ φ ∈ h2.formulas`
— "guard absent → event present", where guard-first semantics require the transpose, "event
absent → guard present". `UntilDefect` (`:64`) and `SinceDefect` (`:68`) carry the same
transposition, defining the defect by the *guard* being absent rather than the *event*. The
surrounding docstrings still use the retired event-first naming, which is how it survived. Left
untouched, as plan 05's Research Integration finding 4 directs.
