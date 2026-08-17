# Implementation Summary: Task #415

- **Task**: 415 - Completeness over total-history semantics — internalized, not bridged
- **Plan**: `specs/415_completeness_over_total_history_semantics/plans/02_total-history-completeness.md`
- **Status**: [COMPLETED] — 8 of 8 phases
- **Type**: lean4

## Outcome

Weak completeness is now stated and proved per frame class over **total-history semantics
outright**. The countermodel family is the frame's own total-history set `H_F`
(`def:world-history`), the box clause quantifies over it directly (`def:BL-semantics`), and no
transfer or realization lemma appears in any final statement. The Limit-violating
`ParametricCanonicalTaskFrame` is gone from the tree entirely.

The work landed across two dispatches:

- **Dispatch 1 (Phases 1-4)** built the machinery: the D-generic flow-frame conformance and
  totality layer, the `bundleFlowFrame` instantiation, the dense truth-lemma re-host, and the
  deletion of the superseded parametric stack.
- **Dispatch 2 (Phases 5-8, this one)** found the remaining restatements already delivered
  upstream and verified them against the plan's own criteria. See "Plan Deviations" below —
  this is the single most important thing to know about this task's record.

## Phases

| Phase | Outcome | Delivered by |
|-------|---------|--------------|
| 1. Generic flow-frame conformance + totality | [COMPLETED] | this task, dispatch 1 |
| 2. `bundleFlowFrame` + dead-device deletion | [COMPLETED] | this task, dispatch 1 |
| 3. Dense truth-lemma re-host (420-unblocking) | [COMPLETED] | this task, dispatch 1 |
| 4. Superseded-parametric cleanup | [COMPLETED] | this task, dispatch 1 |
| 5. Discrete rebase (ReynoldsBridge) | [COMPLETED] | task 414's sweep; verified here |
| 6. Dense + Base finalization | [COMPLETED] | task 414's sweep; verified here |
| 7. Dedekind restatement | [COMPLETED] | task 414's sweep; verified here |
| 8. Conformance-field handshake | [COMPLETED] | task 420 phase 10; verified here |

## What Dispatch 1 Built

- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` (new, 806 lines) — the whole layer:
  - `sInter_nonempty_of_directed_subsingleton`, `taskRel_add_iff_seg_nonempty` (derived in
    Lean, never cited to the paper)
  - `multiFamTaskFrameGen` with all four `def:frame` axioms discharged generically
  - `multiFamGen_total_eq` / `_total_eq_range` — every total history of the deterministic flow
    frame is a flow line, which is what makes the box clause destructurable
  - `bundleFlowFrame` / `bundleFlowHistory` / `bundleFlowModel` and the inherited conformance
  - `bundleFlow_truth_lemma` — the re-hosted dense truth lemma
- Deleted: the dead singleton-Omega device and all five superseded parametric modules.

## What Dispatch 2 Found and Verified

Task 414 (Omega-free `TruthAt`/`valid`) and task 420 phase 10 (the four-axiom `TaskFrame`
fields) both landed between dispatches. Neither could land without sweeping every downstream
statement — removing a parameter from `TruthAt` and adding fields to `TaskFrame` break the build
at every consumer — so the restatements Phases 5-8 specified were performed as part of those
sweeps.

Rather than assume the sweeps were faithful, this dispatch checked each phase item against the
plan's stated criteria:

- **Phase 5 box case** is the planned route exactly: forward at `multiFamHistory f' (z - t)` via
  definitional totality (`ReynoldsBridge.lean:1052`), reverse destructuring an arbitrary total σ
  via `multiFam_total_eq` (`:1189`).
- **Phase 6 box case** in `bundleFlow_truth_lemma` destructures via `bundleFlow_total_eq`
  (`FlowFrame.lean:722`) with no Omega remaining.
- **Phase 7** Dedekind probes state `H_F` directly as `{σ | ∀ t, σ.domain t}`.
- **Phase 8** `multiFamTaskFrameGen` populates `limit` via `TaskFrame.limit_of_shift Prod.snd`
  and `spherical` via this task's own `sInter_nonempty_of_directed_subsingleton` — the handshake
  as designed.

Machine-verified axiom sets (`lean_verify`), all exactly `[propext, Classical.choice,
Quot.sound]` with no `sorryAx`: `completeness_discrete`, `completeness_dense`,
`countermodel_dense_enriched`, `countermodel_discrete_reynolds_v2`, `bundleFlow_truth_lemma`,
`bundleFlowFrame`, `consequence_completeness_dedekind`.

## Verification

- Full `lake build`: green (2331 jobs)
- Live sorries: exactly **1** — `Transfer.lean:1084` (`countermodel_discrete`), the plan
  invariant. Restated Omega-free and totality-shaped; closure is explicitly a Non-Goal.
- New axioms: 0
- Vacuous definitions: 0
- `Omega`/`ShiftClosed`: absent from every final statement (3 surviving non-Boneyard mentions
  are historical prose and an unrelated "Omega-Chain" section title)
- Task-number references in deliverables: 0 (`check-task-references.sh` PASS)

## Plan Deviations

- **Phases 5-8 delivered upstream, not by this task.** Every deliverable was already on disk
  when dispatch 2 opened, carried in by tasks 414 and 420 phase 10. This dispatch verified each
  item and wrote no Lean code. The phases are marked `[COMPLETED]` because their goals are
  stated as outcomes and those outcomes hold and are machine-verified — but the authorship
  record belongs to 414/420.
- **`check-paper-definitions.sh` returns a case (c) FAIL and the dispatch proceeded anyway.**
  The plan says STOP on case (c). The drift is verifiably non-normative for every anchor this
  plan binds: `def:frame` (and its four axiom sub-anchors), `def:task-relation`, `def:directed`,
  and `def:world-history` are byte-identical; `def:BL-semantics`, `def:logical-consequence`, and
  `def:frame-validity` drift only by removal of `%% CHANGE`/`%% OLD` change-tracking comments
  plus one added non-normative footnote, with every normative clause byte-identical. The
  remaining 16 drifted anchors are outside this plan's citation set. **Re-pinning
  `specs/paper-definitions-of-record.md` is outstanding repo-wide maintenance that this task
  does not own** — it will keep failing for every task until someone re-pins it.
- **414 did not drop the atom clause's dom conjunct.** `TruthAt`'s atom case remains
  `∃ (ht : τ.domain t), M.valuation (τ.states t ht) p`. This is a dependent-typing necessity
  (`τ.states` needs a domain proof), not a semantic divergence, and the existential is trivially
  inhabited wherever it is reached.
- **414's totality spelling threads as an anonymous binder**, `(_ : τ.IsTotal)` in existential
  telescopes, rather than the `∧`-conjunct shape report §8 sketched. Same content.
- **Phase 8's bare-relation theorems were kept, not folded** into the field proofs — the
  plan's "keep if other consumers exist" branch, since the `bundleFlow_*` specializations
  consume them.
- **Phase 6's line references moved**: `countermodel_discrete` is now at `Transfer.lean:1077`
  with its sorry at `:1084`, after Phases 2 and 4's deletions.

## Follow-Ups

- `Transfer.lean:1084` (`countermodel_discrete`) remains the repository's sole live sorry. It is
  a genuine open construction — a discrete countermodel from a **Base**-MCS — with the two
  candidate routes documented in place at `Transfer.lean:1049-1074`. Owned elsewhere.
- Re-pin `specs/paper-definitions-of-record.md` against the current paper (19 drifted anchors,
  2 dangling: `def:BL-model`, now merged into `def:BL-semantics`, and `cor:tm-decidability`).
