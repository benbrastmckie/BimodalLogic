# Implementation Plan: Task #696

- **Task**: 696 - stability_modal_substrate_design
- **Status**: [IMPLEMENTING]
- **Effort**: 21.5 hours
- **Dependencies**: 700 (complete)
- **Research Inputs**: specs/696_stability_modal_substrate_design/reports/01_stability-modal-substrate-design.md, specs/696_stability_modal_substrate_design/reports/02_trans-redesign-gate-verification.md
- **Artifacts**: plans/02_trans-arrival-substrate-refactor.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Both research rounds converge on one design, and round 2 converted the open half of it from
argument to machine-checked construction. This plan implements **T-arrival**: the branching
witness skeleton gains a fourth periodic datum `trans`, pruned by arrival renaming
(`trans u i j := transRaw u i j = true ∧ share (u+1) i j`), plus a `lift` well-formedness field
carrying the thread-lifting closure the histories characterization needs. `Thread.step` moves
from `share (u+1)` to `trans u`, and (C1')'s `untl` and `snce` clauses re-quantify over
`trans t` and `trans (t-1)` instead of over the whole `share`-class. `share`, `Step`, the frame,
(C0), (C2'), (C3), (C4) and (C5) keep their current statements; so do `plusTruth_iff_mem`,
`plusRefutes_of_certifies` and `total_eq_thread`.

The work is sequenced so every phase ends with a green tree. The two genuinely atomic edits (the
structure-field addition, and the `Thread.step` flip) are pre-declared `atomic-batch` phases; all
others are ordinary per-substep phases. The four `Incompleteness.lean` theorems that record the
present defect are expected to become unprovable, and their removal plus the arrival of the two
gate families is the evidence the refactor worked — the C2 axiom baseline and `docs/theorem-index.md`
are rewritten in the same phases that change the declarations, never lagging behind them.

### Research Integration

- Round 2's probe (`probes/03_trans_redesign_gate_probe.lean`, 892 lines, elaborates clean,
  no `sorryAx`) supplies reference signatures for every generic definition and both gate
  families. Phases 2, 3, 6, 9 and 10 port from it rather than re-deriving.
- `famA_tCertifies` / `famB_tCertifies` prove the redesigned six conditions are satisfiable at
  non-trivial sharing on both temporal sides; `famA_refutes_snce_share_congr` /
  `famB_refutes_untl_shift_congr` prove the redesigned (C1') does not re-derive the congruences.
  The post-refactor flip of the `not_plusCertifies_*` rows is therefore guaranteed by existing
  terms, not hoped for.
- `stabFamily_not_liftable` proves the `lift` field is necessary rather than defensive: the
  landed (C5) witness admits a frame `Step`-path that no hop-free thread traces.
- Candidates B (re-time `snce` to `t-1`) and C (`share` indexed by formula class) are closed by
  research decision and are not re-opened here. B is refuted at `plusSnce_thread_step`
  (`PlusWitnessFamily/Fulfil.lean` 344-350); C forces `succ(i,u) = pred(j,u+1)` as index sets,
  which the history-type product structure does not permit.
- Round 1's Q4 verdict on (C2')'s (C1')-relative limitation is inherited, documented as
  re-examined: the propagation lemmas consume exactly `θ.step` forward and
  `plusThread_share_pred` backward, both of which become `trans`-facts in lockstep.

### Prior Plan Reference

No prior plan. This is the first plan artifact for this task; `plans/` did not exist.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so `specs/ROADMAP.md` was not consulted
and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- Add the `trans` datum (three periodic Boolean-matrix lists, their length equalities, and
  `trans_refl`) and the `lift` closure field to `SharingSkeleton`, arrival-pruned so the frame
  section of `Skeleton.lean` is re-proved rather than rewritten.
- Move `Thread.step` to `trans` and re-quantify (C1')'s `untl` and `snce` clauses over `trans t`
  and `trans (t-1)`, on both the Formula and the PlusFormula sides.
- Land the `untl`-side incompleteness result, which corrects the present record before the
  redesign removes the ability to state it.
- Land Families A and B as in-tree certificates and replace the emptied incompleteness theorems
  with the positive results they license.
- Keep the C2 axiom baseline and `docs/theorem-index.md` exactly in step with the tree at every
  phase boundary, and make the intended row transitions visible rather than silent.
- Finish with zero sorries, no new axioms, and `plusTruth_iff_mem` / `plusRefutes_of_certifies` /
  `total_eq_thread` statements literally unchanged.

**Non-Goals**:

- The exact thread-lifting closure (`LiftWindow` by subset construction plus compactness, and
  its `Decidable` instance). `liftable_of_full` and `liftable_of_spliceClosed` cover every
  producer in the tree and both gate families; the exact closure is a separate follow-up.
- The left-wrap-edge refinement of the (C2') window reduction. Round 1 scoped it as optional and
  independent of the substrate datum.
- Any change to soundness or to the model checker's own code. The export contract gains three
  optional list fields and stays additive; the accepting branch's codomain is unchanged.
- Task 695's L-plus carrier normalization, deliberately out of scope.
- Changing another task's status. The fold-in recommendation for task 694 is surfaced as a
  non-blocking decision for the user, not executed here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Adding structure fields breaks every producer at once, so the tree is red mid-edit | M | H | Phase 3 is a pre-declared `atomic-batch`; the hard `lift` lemmas land free-standing in Phase 2 first, so Phase 3 only wires them in |
| The `Thread.step` flip breaks `Window.lean` and both `Fulfil.lean` files simultaneously | H | H | Phases 4 and 5 insulate every consumer behind `thread_share_succ` while `Thread.step` still means `share`; Phase 6's flip then touches only the definition sites |
| C2 fails between a declaration change and the baseline rewrite | M | H | Every phase that adds, removes or renames a pinned declaration rewrites the C2 baseline, the `#print axioms` scratch block, its pass-message count, and the matching `theorem-index.md` rows in the same phase |
| `simp`/`decide` behave differently in-tree than in the probe, because `trans` is field-derived rather than an external parameter | M | M | The probe's per-condition proofs mention only decoding lemmas and `Finset` literal membership; the `trans = eq` reduction is one `change`/`subst`. Expect a near-verbatim port; if a goal resists, fall back to the probe's explicit `split_ifs <;> simp [labels, PlusFormula.top]` form |
| `simp [PlusFormula.subformulas, PlusFormula.top]` hits the 200000-heartbeat `whnf` limit on closure membership | M | H | Use the form round 2 verified: `rw [mem_plusClosureOf]; simp only [List.mem_*]; rw [plusSubformulaClosure, List.mem_toFinset]; simp only [...]; tauto` |
| Hidden `share`-as-succession uses beyond the 36 catalogued sites | M | M | After Phases 4, 5 and 6, re-run `grep -n "share (.*+ 1)\|share_refl (.*+ 1)"` across both directories as the checklist; treat any new hit as in-scope for the phase that surfaced it |
| The round-2 probe stops compiling once the structure gains fields, taking its obstruction record with it, and is then lost entirely when `/todo` archives this task under the gitignored `specs/archive/` | M | H | Phase 11 ports the closure-necessity obstruction into `specs/evidence/` and wires it into `check-evidence-probes.sh` |
| A sibling task edits a shared file on this working tree during a phase | M | L | Re-read each file immediately before editing, stage only this task's own hunks by explicit path, never use a directory or glob `git add`, and stop and report any foreign commit or uncommitted modification |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4, 5 | 3 |
| 4 | 6 | 4, 5 |
| 5 | 7 | 6 |
| 6 | 8 | 7 |
| 7 | 9 | 8 |
| 8 | 10 | 9 |
| 9 | 11 | 10 |
| 10 | 12 | 11 |

Phases within the same wave can execute in parallel. Phases 4 and 5 are the only genuine
parallel pair in the code phases: they touch disjoint directories. Phases 1 and 2 are
independent of each other but both touch the repository root's scripts or the skeleton, so
running them sequentially is also fine.

### Phase 1: Land the `untl`-side incompleteness [COMPLETED]

**Goal**: Put the `untl`-side of the present defect on the record, from the two archived
round-1 probes, before the redesign removes the ability to state it. This also corrects the two
READMEs' rule of thumb, which currently says the wrong thing about why the defect occurs.

**Tasks**:

- [x] Port `untl_shift_share_congr` from `probes/01_untl_shift_congr_probe.lean` into
      `PlusWitnessFamily/Incompleteness.lean`, beside `snce_share_congr`, with a docstring
      naming it the `untl`-side twin.
- [x] Port `stabUntlTarget`, `not_plusCertifies_stabUntl` (probe 01) and
      `not_plusValidZTime_stabUntl` (probe 02) into the same module.
- [x] Add the three new theorems to the C2 axiom baseline in `scripts/check-module-invariants.sh`:
      a `BASELINE` line and a `#print axioms` line each, and update the `pass C2` message's
      spelled-out count.
- [x] Add three matching rows to `docs/theorem-index.md`'s certificate-stack block, each tagged
      `pcq pinned:C2`.
- [x] Extend the C2 block's explanatory comment so it names the `untl` side too, and keep its
      existing note that a successful substrate redesign must make these rows FAIL.
- [x] Replace the "a condition quantifying over the class at the label's *own* time collapses"
      rule of thumb in both READMEs with the correct rule: a condition quantifying over the
      one-step reach of a position collapses whenever that reach is a whole `share`-class, at
      either time. Correct the claims that the `untl` half is a genuine repair and is
      defect-free by inspection.
- [x] Add the "position = history type" paragraph under `Sharing/README.md`'s
      `### Correction: (C1') is only half a repair`, so the residual neighbour-agreement
      constraints read as semantically forced rather than as a relapse.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: This phase assumes the two round-1 probes still elaborate against the
current oleans (round 2 recorded them as not re-run, with the tree at `e25e0bddb`). Confirm by
running `lake env lean` on each probe before porting; if either has drifted, repair it against
the current API rather than weakening its statement.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` - add the four
  `untl`-side declarations
- `scripts/check-module-invariants.sh` - three C2 baseline rows, three `#print axioms` lines,
  updated count in the pass message, extended block comment
- `docs/theorem-index.md` - three new pinned rows
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` - corrected rule of
  thumb, new "position = history type" paragraph
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` - corrected rule of thumb,
  `untl`-side added to `## What this certificate cannot refute`
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - module docstring mentions the
  `untl` side alongside the `snce` side

**Verification**:

- `lake build` is green and `grep -rn "sorry" FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` finds none.
- `bash scripts/check-module-invariants.sh` passes, with C2 reporting the new, larger count.
- `bash scripts/readme-lint.sh` passes on both edited READMEs.

---

### Phase 2: Free-standing `LiftableRaw` and its two sufficient lemmas [COMPLETED]

**Goal**: Land the thread-lifting closure predicate and both sufficiency lemmas as ordinary
definitions over explicitly-passed raw data, before any structure changes. This is what keeps
Phase 3 small enough to be a single atomic batch.

**Tasks**:

- [x] Define `LiftableRaw n repBack repMid repFwd transBack transMid transFwd` in
      `Sharing/Skeleton.lean`, as a `Prop` over the decoded functions, taking the probe's
      `Liftable` as the reference shape: every `StepRaw`-path is `share`-tracked by some
      index path whose consecutive pairs are `transRaw`-related and arrival-consistent.
- [x] Prove `liftable_of_full`: `LiftableRaw` holds whenever every `trans` matrix is the full
      relation. The proof is the gluing half of today's `total_eq_thread`
      (`Skeleton.lean` roughly 930-946), lifted out verbatim. *(Scope Hypothesis confirmed: the
      gluing step depends only on the raw `Step`-path's own intermediates, not on `Thread`, so
      it restated over raw paths in three lines with no new mathematics.)*
- [x] Prove `liftable_of_spliceClosed`: `LiftableRaw` holds for a splice-closed lasso set, by
      pigeonhole on the finite index type.
- [x] Add a constant-path corollary covering the two gate families' situation (a family whose
      `Step`-paths are constant outside one shared half-line), so Phases 9 and 10 can discharge
      `lift` without reaching for splice-closure.
- [x] Docstring each of the three, naming which producer class it is for.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase assumes `liftable_of_full`'s proof is a lift-out of the second
half of the existing `total_eq_thread` and needs no new mathematics. Confirm by reading
`Skeleton.lean` 905-946 before writing; if the gluing step turns out to depend on `Thread`
rather than on raw paths, restate it over raw paths first and record the extra work here.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` - `LiftableRaw`,
  `liftable_of_full`, `liftable_of_spliceClosed`, constant-path corollary

**Verification**:

- `lake build` is green; no other module changed, so a single-module build suffices during the
  phase and the full build closes it.
- `#print axioms` on all three new declarations shows `[propext, Classical.choice, Quot.sound]`.
- No existing declaration's statement changed: `git diff` touches only added lines plus the
  extraction of the gluing lemma.

---

### Phase 3: `trans` and `lift` as skeleton fields, and every producer [COMPLETED]

**Goal**: Add the fourth periodic datum and the closure field to `SharingSkeleton`, wire the
derived arrival-pruned relation `S.trans`, and update every producer in the same atomic edit.
`Thread.step` is untouched, so all statements and all downstream proofs are unchanged.

**Tasks**:

- [x] Add `transBack transMid transFwd : List (Fin n → Fin n → Bool)` to `SharingSkeleton`, with
      `transBack_len`, `transMid_len`, `transFwd_len` against the corresponding `rep` lists.
- [x] Add `trans_refl : ∀ r ∈ transBack ++ transMid ++ transFwd, ∀ i, r i i = true`.
- [x] Add `lift : LiftableRaw n repBack repMid repFwd transBack transMid transFwd`.
- [x] Decode with `Periodic.unrollOf` at an `Inhabited` default of `fun i j => decide (i = j)`,
      mirroring `repIdInhabited`; add the periodicity twins alongside the existing `rep` ones.
- [x] Define the derived relation `S.trans u i j := transRaw u i j = true ∧ share (u+1) i j` and
      prove `trans_refl'` (reflexivity of `S.trans` from the field plus `share_refl`) and
      `share_succ_of_trans` (the arrival-pruning projection).
- [x] Re-export the new fields and the derived relation through `Sharing/Basic.lean` and
      `PlusWitnessFamily/Basic.lean`.
- [x] Update every producer to supply the new fields, discharging `lift` with `liftable_of_full`
      at `transRaw := full`: `Sharing/Specialize.lean`'s `toSharing`,
      `PlusWitnessFamily/Examples.lean`'s `stabFamily`, and the three smoke families in
      `Sharing/Fulfil.lean`, `PlusWitnessFamily/Fulfil.lean` and `PlusWitnessFamily/Decide.lean`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: CONFIRMED at implementation time — the compiler reported missing-field
errors at exactly the five producer sites and two `skeleton` projections round 2's F6 named, and
at no others. This phase asserts five producer sites and two `skeleton` projections, from
round 2's F6. Confirm at implementation time by building after the field addition and treating
the compiler's own list of missing-field errors as authoritative; add any producer the error list
names that this plan does not.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` - three list fields,
  three length equalities, `trans_refl`, `lift`, decoding, periodicity twins, derived `trans`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Basic.lean` - re-exports and the
  `skeleton` projection
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Basic.lean` - re-exports and the
  `skeleton` projection
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Specialize.lean` - `toSharing`
  supplies the new fields
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` - `stabFamily` supplies
  the new fields
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean` - smoke family
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Fulfil.lean` - smoke family
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean` - smoke family

**Verification**:

- `lake build` is green at the end of the batch.
- `bash scripts/check-module-invariants.sh` passes unchanged, C2 included: no pinned statement
  moved, so the baseline needs no edit in this phase.
- `git diff` shows no change to any theorem statement.

---

### Phase 4: Insulate the Formula-side thread-step consumers [COMPLETED]

**Goal**: Introduce `thread_share_succ` and rewrite every Formula-side site that reads
`θ.step u` as a `share (u+1)` fact to go through it instead. While `Thread.step` still means
`share (u+1)`, this lemma is definitionally `θ.step u`, so the phase is behaviour-preserving and
green throughout.

**Tasks**:

- [x] Add `thread_share_succ (θ : S.Thread) (u) : S.share (u+1) (θ.idx u) (θ.idx (u+1))` to
      `Sharing/Skeleton.lean`, currently `θ.step u`.
- [x] Rewrite the `Sharing/Thread.lean` delegations (`Thread.step`, `step_of_share_succ`,
      `step_congr_right`) to state and consume `thread_share_succ`.
- [x] Rewrite `Sharing/Window.lean`'s `FwdWalk.share_succ`, `BwdWalk.share_succ` and the four
      `walkIdx_step` sites. *(No edit required, and the reason is load-bearing rather than an
      omission: the walks PRODUCE threads rather than consuming them. `walkIdx_step`'s only
      consumer is the `step :=` field of the thread it builds, confirmed by grep across the
      tree, so there is nothing to route through `thread_share_succ`. These four sites change
      in Phase 6, where `succF`/`predF` start filtering on `trans` and `walkIdx_step`'s own
      statement becomes a `trans` fact — the definition-site change Phase 6 is scoped to.)*
- [x] Rewrite `Sharing/Fulfil.lean`'s `untl_thread_step`, `thread_share_pred`,
      `snce_thread_step` and the `share_refl (z.2 + 1)` default escape edge in
      `window_of_threadFulfilling`.
- [x] Rewrite the along-thread lemmas in `Sharing/Agreement.lean`.
- [x] Touch `Sharing/Frame.lean` and `Sharing/Histories.lean` for their one-line restatements.
      *(`Frame.lean` needed none — it never mentions a thread's step. `Histories.lean`'s
      `## Why the tight Thread.step suffices` heading and its opening sentence now read the
      step through `thread_share_succ`.)*
- [x] Re-run the checklist grep and confirm no Formula-side `θ.step`-as-`share` reading remains
      outside the lemma itself.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Scope Hypothesis**: CONFIRMED with a corrected count. The checklist grep run at implementation
time returns 42 hits, not 36 — 34 on the Formula side and 8 on the Plus side — but the excess is
entirely the Phase 2 and Phase 3 additions' own occurrences (`transOf`, `trans`, `trans_def`,
`share_succ_of_trans` and the raw `stepOf`), not uncatalogued consumers. The thread-step readings
themselves are exactly the sites F6 named. Round 2's F6 catalogues 36 `share`-as-succession grep
hits across 9 files for both sides together. Confirm the Formula-side share of that list at implementation time with
`grep -n "share (.*+ 1)\|share_refl (.*+ 1)"` over
`FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/`, and record the actual count in the
phase's commit message.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` - `thread_share_succ`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Thread.lean` - delegations
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Window.lean` - walk share facts
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean` - propagation lemmas
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Agreement.lean` - along-thread lemmas
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Frame.lean` - restatement
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Histories.lean` - restatement

**Verification**:

- `lake build` is green; statements unchanged, so `bash scripts/check-module-invariants.sh`
  still passes including C2.
- The checklist grep returns no Formula-side hit outside `thread_share_succ`'s own statement.

---

### Phase 5: Insulate the Plus-side thread-step consumers [COMPLETED]

**Goal**: The same insulation on the PlusFormula side. Disjoint from Phase 4's file set, so the
two can run concurrently.

**Tasks**:

- [x] Restate `Thread.step` and `Thread.const` in `PlusWitnessFamily/Basic.lean` through
      `thread_share_succ`.
- [x] Rewrite `PlusWitnessFamily/Fulfil.lean`'s `plusUntl_thread_step` (328-334),
      `plusThread_share_pred` (337-341), `plusSnce_thread_step` (344-350) and the default escape
      edge in its `window_of_threadFulfilling` analogue.
- [x] Rewrite the along-thread lemmas in `PlusWitnessFamily/Agreement.lean`, leaving
      `plusTruth_iff_mem` and `plusRefutes_of_certifies` statements untouched.
- [x] Re-run the checklist grep over `PlusWitnessFamily/` and confirm nothing remains.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: interface

**Scope Hypothesis**: Assumes the Plus-side sites are the four `Fulfil.lean` sites plus the two
`Basic.lean` restatements named in F6. Confirm with the same grep over
`FormalSystem/Metalogic/Decidability/PlusWitnessFamily/` and extend the edit to whatever it names.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Basic.lean` - `Thread.step`,
  `Thread.const` restatements
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Fulfil.lean` - propagation lemmas
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` - along-thread lemmas

**Verification**:

- `lake build` is green; `bash scripts/check-module-invariants.sh` passes including C2.
- `#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.plusTruth_iff_mem`
  and the same for `plusRefutes_of_certifies` are unchanged, and so are their statements.

---

### Phase 6: Flip `Thread.step` to `trans` [COMPLETED]

**Goal**: The substrate switch itself. `Thread.step` becomes `trans u (idx u) (idx (u+1))`,
`Thread.const` is rebuilt from `trans_refl`, and `total_eq_thread` is proved from the `lift`
field. Because Phases 4 and 5 insulated every consumer, this phase touches only definition sites
and the two proofs that genuinely change.

**Tasks**:

- [x] Change `Thread.step` to `∀ u, K.trans u (idx u) (idx (u+1))`.
- [x] Rebuild `Thread.const` from `trans_refl'` (and `share_refl` via arrival pruning).
- [x] Redefine `thread_share_succ` as `(θ.step u).2`, so every Phase 4 and 5 consumer keeps
      working with no further edit.
- [x] Reprove `total_eq_thread`: keep today's extraction half (the `Step`-path and its `a`,
      `hstep`, roughly `Skeleton.lean` 905-930) and replace the gluing half with an application
      of `K.lift`. Round 2's `total_eq_tthread_of_liftable` is the six-line template. The
      statement does not change.
- [x] Confirm `thread_is_history` and `conn_thread` / `Thread.reachN` / `step'` still hold, now
      routed through arrival pruning. *(confirmed: unchanged; the `Step` definition and every
      frame lemma are untouched in the diff, so the Scope Hypothesis held)*
- [x] Update `Sharing/Window.lean`'s `succF` and `predF` to filter on `trans` rather than on
      `share`, and carry a `trans_succ` field on the walk structures; `succF_nonempty` and
      `predF_nonempty` go through `trans_refl'`. *(deviation: altered — the filter carries the
      `transRaw` Bool row beside the existing `share` row rather than the bundled `trans`, so
      `Finset.filter`'s decidability instance stays syntactic; `transRaw_succ` is a walk lemma
      rather than a structure field, since the walk's step is already a `mem_succF` fact)*
- [x] Mirror the `Thread.step`/`Thread.const` restatements on the Plus side. *(deviation: altered — also required the Plus-side `mem_succF`/`mem_predF` delegations, two `foldRel_transRaw` delegations and four proof sites in `PlusWitnessFamily/Fulfil.lean`, a file this phase's "Files to modify" list omitted)*

**Timing**: 2 hours

**Depends on**: 4, 5

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase assumes the frame section of `Skeleton.lean` needs no re-proof,
because arrival pruning keeps `Step := ∃ i', share u i i' ∧ share (u+1) i' j` byte-identical.
Confirm by checking that `git diff` on `Skeleton.lean` leaves the `Step` definition and every
frame lemma untouched; if any frame lemma breaks, the arrival-pruning invariant has been
mis-stated and the `trans` definition, not the frame, is what to fix.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` - `Thread.step`,
  `Thread.const`, `thread_share_succ`, `total_eq_thread`, `thread_is_history`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Thread.lean` - delegations follow
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Window.lean` - `succF`, `predF`,
  `mem_succF`, `mem_predF`, nonemptiness, walk `trans_succ`
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Basic.lean` - `Thread.step`,
  `Thread.const` restatements

**Verification**:

- `lake build` is green at the end of the batch.
- `git diff` shows `total_eq_thread`'s statement unchanged, and
  `bash scripts/check-module-invariants.sh` passes with its C2 row intact.
- The `Step` definition and the frame lemmas in `Skeleton.lean` are untouched in the diff.

---

### Phase 7: Re-quantify (C1') over `trans`, Formula side [COMPLETED]

**Goal**: Change the `untl` and `snce` clauses of `LocalCoherentShare` to quantify over
`trans t` and `trans (t-1)` respectively, and carry that change through the decision data and
the propagation proofs on the Formula side. The three one-position clauses are verbatim.

**Tasks**:

- [x] Rewrite the `untl` clause (`Sharing/Predicates.lean` around 154) as
      `∀ j, S.trans t i j → ...` and the `snce` clause (around 158) as
      `∀ k, S.trans (t-1) k i → ...`.
- [x] Re-derive `untl_self_of_share`, `snce_self_of_share` and `localCoherentLab_of_share` from
      `trans_refl'` instead of `share_refl`.
- [x] Give `shareClauseAt` in `Sharing/Decide.lean` the `trans t` and `trans (t-1)` rows as data
      alongside the `rep` tests; extend `data_congr_back` (236) and `data_congr_fwd` (245) with
      `trans` components at the same periods. *(deviation: altered — `data_congr_back` and
      `data_congr_fwd` keep their two-component statements; the succession periodicity is carried
      by the `transRaw_congr_NB`/`transRaw_congr_NF` lemmas Phase 6 already landed, which
      `exists_window_repr` consumes directly as two further `first` alternatives. Extending the
      pairs would have renumbered every `.1`/`.2` projection at their call sites for no gain)*
- [x] Update `Sharing/Fulfil.lean`'s propagation lemmas to feed the clauses `θ.step` directly;
      `thread_share_pred` becomes an instance of `θ.step (t-1)` and loses its `share_symm`
      rewrite. *(deviation: altered — `thread_share_pred` is retained unchanged, since the `predF`
      edge filter still carries a `share` row that consumes it; the clause's new side condition is
      a separate lemma, `thread_trans_pred`, stated at the succession's own argument order)*
- [x] Update the along-thread lemmas in `Sharing/Agreement.lean` and the reductions in
      `Sharing/Specialize.lean`.
- [x] Record `snce_pred_congr` and `untl_succ_congr` as named lemmas, with docstrings saying the
      residual agreement is semantically forced (a position is a history type) and is not a
      relapse into the repaired defect.

**Timing**: 2 hours

**Depends on**: 6

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Assumes the (C2') window-reduction argument transfers verbatim, because
its propagation lemmas consume exactly the relation `θ.step` now supplies on both sides. Confirm
by checking that `threadFulfilling_of_window`'s far-left and far-right cases need no new
hypothesis; if either does, the change belongs to this phase, not to a later one.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean` - `untl` and
  `snce` clauses, self-instantiation lemmas
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Decide.lean` - `shareClauseAt` data,
  `data_congr_back`, `data_congr_fwd`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean` - propagation lemmas
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Agreement.lean` - along-thread
  lemmas, `snce_pred_congr`, `untl_succ_congr`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Specialize.lean` - reductions

**Verification**:

- `lake build` is green.
- `bash scripts/check-module-invariants.sh` passes; no pinned Formula-side declaration changed
  name or statement.
- The decision instance for the Formula-side conjunction still elaborates, so the window
  reduction survived the re-quantification.

---

### Phase 8: Re-quantify (C1') over `trans`, Plus side, and empty the defect record [COMPLETED]

**Goal**: The same re-quantification on the PlusFormula side, which by construction makes
`snce_share_congr`, `untl_shift_share_congr` and the three `not_plusCertifies_*` theorems
unprovable. Remove them and their pinned rows in the same phase, so the tree and the baselines
never disagree. The two `not_plusValidZTime_*` non-validities survive untouched.

**Tasks**:

- [x] Rewrite `PlusWitnessFamily/Predicates.lean`'s `untl` and `snce` clauses over `S.trans t`
      and `S.trans (t-1)`; re-derive `plusUntl_self_of_share`, `plusSnce_self_of_share`,
      `plusLocalCoherentLab_of_share` from `trans_refl'`.
- [x] Extend `PlusWitnessFamily/Decide.lean`'s `shareClauseAt` (the `rp i = rp j` test at 524
      and the `rt i = rt k` test at 526) with `trans` rows, and `data_congr_back` (272) /
      `data_congr_fwd` (281) with `trans` components. *(deviation: altered — the two `data_congr_*`
      pairs keep their statements; succession periodicity is supplied by two new
      `transRaw_congr_NB`/`transRaw_congr_NF` lemmas delegating through the window projection,
      mirroring the Formula-side choice in Phase 7)*
- [x] Update `PlusWitnessFamily/Fulfil.lean`'s propagation lemmas and
      `PlusWitnessFamily/Agreement.lean`'s along-thread lemmas. Confirm
      `plusTruth_iff_mem` and `plusRefutes_of_certifies` keep their exact statements.
- [x] Remove `snce_share_congr`, `untl_shift_share_congr`, `not_plusCertifies_stabSnce`,
      `not_plusCertifies_stabSnce_premise` and `not_plusCertifies_stabUntl` from
      `Incompleteness.lean`. Keep `stabSnceTarget`, `notStabSnceTarget`, `stabUntlTarget`,
      `not_plusValidZTime_stabSnce` and `not_plusValidZTime_stabUntl`.
- [x] Rewrite the module docstring to say what the module now records: the targets, their
      genuine non-validity, and a forward pointer to the certificates that arrive in Phases 9
      and 10.
- [x] Remove the corresponding C2 baseline rows and `#print axioms` lines from
      `scripts/check-module-invariants.sh`, update the pass-message count, and rewrite the block
      comment so it states that the redesign landed and the rows were retired as the intended
      signal rather than silently dropped.
- [x] Remove the corresponding rows from `docs/theorem-index.md`.
- [x] Confirm `PlusWitnessFamily.lean`'s aggregator docstring no longer promises the removed
      declarations. *(also updated: the stale defect narratives in
      `PlusWitnessFamily/README.md` and `WitnessFamily/Sharing/README.md` now carry a SUPERSEDED
      status banner; their full rewrite belongs to Phase 12)* *(also updated: the stale defect narratives in
      `PlusWitnessFamily/README.md` and `WitnessFamily/Sharing/README.md` carry a SUPERSEDED
      status banner; their full rewrite belongs to Phase 12)*

**Timing**: 2 hours

**Depends on**: 7

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts that exactly five pinned declarations become
unprovable and that the two `not_plusValidZTime_*` theorems survive. Confirm at implementation
time by attempting the build before removing anything: the compiler's error list on
`Incompleteness.lean` is the authoritative set. If a theorem this plan expects to fail still
elaborates, stop and report it — that would mean the redesign did not actually repair the defect.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Predicates.lean` - `untl` and `snce`
  clauses, self-instantiation lemmas
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Decide.lean` - `shareClauseAt` data,
  `data_congr_back`, `data_congr_fwd`
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Fulfil.lean` - propagation lemmas
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Agreement.lean` - along-thread lemmas
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` - remove five
  theorems, rewrite the module docstring
- `scripts/check-module-invariants.sh` - retire five C2 rows and their `#print axioms` lines,
  update the count and the block comment
- `docs/theorem-index.md` - retire five rows
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - aggregator docstring

**Verification**:

- `lake build` is green and `Incompleteness.lean` is sorry-free.
- `bash scripts/check-module-invariants.sh` passes with the reduced C2 count; every remaining row
  still matches `[propext, Classical.choice, Quot.sound]`.
- `plusTruth_iff_mem` and `plusRefutes_of_certifies` are byte-identical in the diff.

---

### Phase 9: Family A in the tree — the `snce`-side certificate [COMPLETED]

**Goal**: Port round 2's Family A into `PlusWitnessFamily/Examples.lean` and land the two
positive theorems it licenses: a six-condition certificate for `Pp → ⊡Pp` at non-trivial
sharing, and the refutation of the old congruence statement.

**Tasks**:

- [x] Port `famA` and its decoding lemmas (`famA_L`, `famA_rep`, `famA_share_neg`,
      `famA_share_nonneg`) from `probes/03_trans_redesign_gate_probe.lean`, translating the
      probe's external `trans` parameter into the structure field and `TThread` into `Thread`. *(deviation: altered — the probe's names collide with `Incompleteness.lean`'s
      own, so `Pp`/`SPp`/`TA`/`c0` were renamed `snceP`/`stabSnceP`/`targetA`/`cA`; the
      external `transEq` parameter became the no-hopping bundle `transIdOf`, added to
      `Sharing/Skeleton.lean` alongside `transId`, `transIdOf_refl` and `transMatOf_id`)*
- [x] Discharge `lift` with Phase 2's constant-path corollary (the probe's `famA_liftable`
      argument: every `Step`-path is constant on `(-∞, -1]`). *(also needed
      `unrollOf_singletons`/`repOf_singletons` in `Sharing/Skeleton.lean`, since `lift` is
      discharged inside the producer's own structure literal where no family-level decoding
      lemma exists yet)*
- [x] Port the six per-condition proofs (`famA_atomCoherent`, `famA_plusLocalCoherentShare`,
      `famA_threadFulfilling`, `famA_boxFaithful`, `famA_target`, `famA_stabFaithful`) and bundle
      them as `plusCertifies_stabSnce_example : (famA p).PlusCertifies 0`.
- [x] Add `not_snce_share_congr` to `Incompleteness.lean`: the redesigned (C1') holds of `famA`
      while `share 0 0 1` with `Pp ∈ L 0 0` and `Pp ∉ L 1 0`, so the old congruence statement is
      refuted rather than merely unproved. *(deviation: altered — `Incompleteness.lean` now imports
      `Examples.lean` rather than `Agreement.lean` directly, and `Examples.lean` imports
      `Agreement.lean` for `PlusCertifies`; no cycle, since neither is imported by `Agreement`)*
- [x] Add two C2 baseline rows and two `#print axioms` lines for the new theorems, update the
      pass-message count, and add the two matching `theorem-index.md` rows.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: The probe's per-condition proofs are each under 40 lines and use only
decoding lemmas, `split_ifs` and `simp` over `Finset` literals, with no `decide` over closures.
Confirm by porting one condition first and checking elaboration time before porting the rest; if
a goal blows past the heartbeat limit, switch to the `simp only` + `List.mem_toFinset` closure
form recorded in round 2's tactic table.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` - `famA`, decoding
  lemmas, six condition proofs, `plusCertifies_stabSnce_example`
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` -
  `not_snce_share_congr`
- `scripts/check-module-invariants.sh` - two C2 rows, two `#print axioms` lines, updated count
- `docs/theorem-index.md` - two new pinned rows

**Verification**:

- `lake build` is green; `grep -c sorry` on both edited Lean files is 0.
- `#print axioms` on `plusCertifies_stabSnce_example` and `not_snce_share_congr` shows
  `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/check-module-invariants.sh` passes with the new count.
- The certificate's sharing is non-trivial: `famA_share_nonneg` gives `share 0 0 1` with the two
  labels differing, which the assertion in `not_snce_share_congr` makes explicit.

---

### Phase 10: Family B in the tree — the `untl`-side certificate [NOT STARTED]

**Goal**: The same for the `untl` side, closing the second temporal direction and completing the
non-vacuity demonstration the task demands.

**Tasks**:

- [ ] Port `famB` and its decoding lemmas (`famB_L`, `famB_rep`, `famB_share_pos`,
      `famB_share_nonpos`) into `Examples.lean`.
- [ ] Discharge `lift` with the constant-path corollary, as for Family A.
- [ ] Port the six per-condition proofs and bundle them as
      `plusCertifies_stabUntl_example : (famB p).PlusCertifies 0`.
- [ ] Add `not_untl_shift_share_congr` to `Incompleteness.lean`.
- [ ] Add two C2 baseline rows and two `#print axioms` lines, update the count, and add two
      `theorem-index.md` rows.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: full

**Scope Hypothesis**: Assumes Family B ports at the same cost as Family A, since its structure is
the mirror image. Confirm by comparing the actual elaboration time against Phase 9's; a large
divergence means the `untl` clause's `t+1` quantification needs a different decoding split
(`t ≤ 0` versus `t ≥ 1` rather than the `snce` side's three-way sign split) and should be
recorded.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Examples.lean` - `famB`, decoding
  lemmas, six condition proofs, `plusCertifies_stabUntl_example`
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` -
  `not_untl_shift_share_congr`
- `scripts/check-module-invariants.sh` - two C2 rows, two `#print axioms` lines, updated count
- `docs/theorem-index.md` - two new pinned rows

**Verification**:

- `lake build` is green; both edited Lean files are sorry-free.
- `#print axioms` on both new theorems shows `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/check-module-invariants.sh` passes; the C2 block now records certificates where
  it previously recorded emptiness, on both temporal sides.

---

### Phase 11: Preserve the closure-necessity obstruction as a wired evidence probe [NOT STARTED]

**Goal**: Round 2's probe stops compiling the moment the skeleton gains fields, and it lives
under a task directory that `/todo` will move into the gitignored `specs/archive/`. Its
load-bearing negative result — that the `lift` field is necessary and not defensive — must
survive that, in the place this repository has designated for design obstructions.

**Tasks**:

- [ ] Create `specs/evidence/stability-modal-substrate/closure-field-is-necessary.lean`, holding
      the `crossPath` / `crossPath_step` / `stabFamily_not_liftable` argument rewritten against
      the landed structure: the (C5) witness admits a frame `Step`-path that no thread with
      `trans = eq` traces, so the histories characterization is not automatic under any
      free-succession design.
- [ ] Wire it into `scripts/check-evidence-probes.sh`'s `WIRED` array, with a table entry in the
      header comment naming the decision it holds in place, in the style of the existing five.
- [ ] Confirm it is `sorry`-free and elaborates via `lake env lean`.

**Timing**: 1.5 hours

**Depends on**: 10

**Verification Tier**: local

**Scope Hypothesis**: Assumes the obstruction argument survives the redesign unchanged, since it
is about `stabFamily`'s frame rather than about (C1'). Confirm by re-elaborating it against the
post-Phase-10 tree; if `stabFamily` now carries a non-trivial `trans`, restate the obstruction at
`trans = eq` explicitly rather than weakening it.

**Files to modify**:

- `specs/evidence/stability-modal-substrate/closure-field-is-necessary.lean` - new probe
- `scripts/check-evidence-probes.sh` - `WIRED` entry and header table row

**Verification**:

- `bash scripts/check-evidence-probes.sh` passes and reports one more wired probe than before.
- `grep -c sorry` on the new probe is 0.
- The probe's theorem is a refutation, not a restatement: it concludes `¬ Liftable` for a named
  family, matching the no-weakening rule in `check-evidence-probes.sh`'s header.

---

### Phase 12: Documentation, hand-off contract, and the full gate set [NOT STARTED]

**Goal**: Bring every prose account of the substrate into line with what now exists, record the
export contract's additive extension, and run the complete gate set as the task's closing
evidence.

**Tasks**:

- [ ] Rewrite `Sharing/README.md`'s `### Correction: (C1') is only half a repair` and
      `### (c) What a follow-up needs` to describe the landed design rather than a proposal, and
      keep the "position = history type" paragraph added in Phase 1.
- [ ] Update `## The substrate is label-free, and lives on SharingSkeleton` and
      `## The thread characterization replaces the orbit characterization` for the fourth datum
      and the `lift` field.
- [ ] Update `## Hand-off to the consuming model checker` with `transBack` / `transMid` /
      `transFwd` as three optional lists of Boolean matrices whose lengths equal the
      corresponding `rep` lists, defaulting to the full relation when absent, and state
      explicitly that the change is additive and the accepting branch's `Refutes Γ Del` codomain
      is unchanged.
- [ ] Update `PlusWitnessFamily/README.md`'s `## The six conditions` and
      `## What this certificate cannot refute` — the latter now records what the certificate
      *can* refute, with both gate families named.
- [ ] Record the (C2') limitation as re-examined and inherited, with the reason: the propagation
      lemmas consume exactly the relation `θ.step` supplies, so the argument transfers verbatim
      and the limitation is about the backward region being a path, not about the substrate datum.
- [ ] Note the deferred exact closure (`LiftWindow`, `liftable_of_liftWindow`,
      `Decidable LiftWindow`) as named follow-up work.
- [ ] Run the full gate set and record the results.

**Timing**: 1.5 hours

**Depends on**: 11

**Verification Tier**: full

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` - substrate, thread
  characterization, (C1') correction, follow-up section, export contract
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` - six conditions, what the
  certificate refutes, (C2') limitation
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily.lean` - aggregator docstring
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` - module docstring
  for the fourth datum and the `lift` field

**Verification**:

- `lake build` green from clean.
- `bash scripts/check-module-invariants.sh` passes, all checks.
- `bash scripts/check-evidence-probes.sh` passes.
- `bash scripts/readme-lint.sh` passes on both READMEs.
- `bash scripts/check-copyright-headers.sh` passes on the new files.
- `grep -rn "sorry" FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/ FormalSystem/Metalogic/Decidability/PlusWitnessFamily/`
  returns nothing.

## Testing & Validation

- [ ] `lake build` green at every phase boundary, and from clean at the end.
- [ ] Zero sorries across both touched directories, and no new axioms: every pinned declaration
      reports `[propext, Classical.choice, Quot.sound]`.
- [ ] `plusTruth_iff_mem`, `plusRefutes_of_certifies` and `total_eq_thread` statements are
      byte-identical to their pre-refactor form.
- [ ] Non-vacuity by construction, both temporal sides: `plusCertifies_stabSnce_example` and
      `plusCertifies_stabUntl_example` are six-condition certificates at non-trivial sharing.
- [ ] No re-derivation of the defect: `not_snce_share_congr` and `not_untl_shift_share_congr`
      show the redesigned (C1') is satisfied by families on which the congruences fail.
- [ ] `bash scripts/check-module-invariants.sh` passes at every phase boundary, with the C2 row
      set changing only in the phase that changes the corresponding declarations.
- [ ] `bash scripts/check-evidence-probes.sh` passes with the new obstruction probe wired.
- [ ] `docs/theorem-index.md` rows match the tree exactly: no row names a declaration that no
      longer exists, and every new pinned declaration has a row.

## Artifacts & Outputs

- The refactored substrate across `WitnessFamily/Sharing/` and `PlusWitnessFamily/`.
- Two in-tree gate families and the four positive theorems replacing the four incompleteness
  theorems, in `Examples.lean` and `Incompleteness.lean`.
- A rewritten C2 axiom baseline and matching `docs/theorem-index.md` rows, with the intended
  row transitions visible in the diff.
- `specs/evidence/stability-modal-substrate/closure-field-is-necessary.lean`, wired into
  `scripts/check-evidence-probes.sh`.
- Updated `Sharing/README.md` and `PlusWitnessFamily/README.md`, including the additive export
  contract for the consuming model checker.
- An execution summary at `specs/696_stability_modal_substrate_design/summaries/02_*-summary.md`.

## Rollback/Contingency

Each phase ends green and is committed separately, so the rollback unit is a phase. To revert,
`git revert` the phase's commit or commits in reverse order; no phase depends on a later one's
state.

The two `atomic-batch` phases (3 and 6) are the only ones with an expected-red interior. If
either cannot be brought green, revert the whole batch rather than committing a partial substrate
change — a tree with `trans` fields but a `share`-based `Thread.step`, or the reverse, is
coherent only as a transient.

Before any rollback that would discard uncommitted work, take a durable checkpoint first:
`bash .claude/scripts/git-snapshot.sh 696 --no-revert` for an ordinary defensive checkpoint, and
the default reverting mode only for a genuine rollback.

The contingency that matters most is Phase 8's: if a `not_plusCertifies_*` theorem still
elaborates after the Plus-side re-quantification, the redesign did not repair the defect. Stop
there and report rather than removing the theorem to make the phase pass.
