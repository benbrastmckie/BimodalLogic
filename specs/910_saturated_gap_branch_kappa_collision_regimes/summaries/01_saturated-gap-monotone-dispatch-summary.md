# Implementation Summary: Task #910

- **Task**: 910 - Dispatch or explicitly exclude the SATURATED-GAP third branch of `kappa_collision_regimes`, which neither landed cell inclusion addresses in either direction
- **Status**: [COMPLETED]
- **Started**: 2026-11-10T16:05:00Z
- **Completed**: 2026-11-10T16:35:00Z
- **Effort**: ~30 minutes
- **Dependencies**: 909 (landed: `exists_ladderPath_through_deleted_exact_lowered_upfirst_of_pend_past`)
- **Artifacts**: plans/01_saturated-gap-monotone-dispatch.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Branch 3 of `kappa_collision_regimes` — the saturated-gap residue — is split into a DISPATCHED
monotone slice and an EXPLICITLY EXCLUDED antitone one, with nothing left tacit. Eleven new
declarations in `LadderCell.lean` close the monotone slice as cell EQUALITY in both directions and
carry the exclusion as a named hypothesis in the new schema's own quantifier, backed by three
compiled records: an exhaustive dichotomy, a non-vacuity witness for the excluded slice, and a
non-vacuity witness showing the dispatched slice genuinely reaches branch 3. The reserved name
`cellLE_zero_const_of_kappa_eq` is still claimed by nothing, anywhere.

The task's two admissible outcomes are therefore BOTH discharged, each on its own half of the
branch: the monotone half by a genuine argument, the antitone half by an exclusion stated in the
signature.

## What Changed

`FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean` — eleven new declarations,
a new `section FreeRegister`, and a module docstring amended from three parts to four. No landed
declaration's signature, body, or position was altered.

**The free-register raise and its necessity record** (`section FreeRegister`):

- `exists_ladderPath_through_free_register_shifted_of_pend_past` — the landed regime-A assembly
  with the anchor VALUE left free: countdown raised by exactly `m · (P + 1)`, object state and
  realized stab-free type held, register delivered at any prescribed `n₀` with
  `nxtAt g z ≤ n₀ ≤ cntAt g z + m · (P + 1)`. Exactly one step differs from the landed
  common-shift assembly: the anchor passed to `exists_ladderPath_of_walk_nxt_at`. The anchor
  clause closes by `omega` from the six facts the plan measured at plan time.
- `free_register_anchor_clause_monotone_required` — the lower bound `nxtAt g z ≤ n₀` is
  NON-REMOVABLE, at the arithmetic witness `X = 19`, `nz = 8`, `cz = 10`, `mP = 0`, `n₀ = 0`,
  `d = 11`. This is the compiled reason the raise reaches the monotone side and no further.
- `cellAt_subset_of_free_register_shift_of_pend_past` — the UPWARD cell inclusion, consuming NO
  forward slack: the widened window pays for the anchor.

**The downward half** (`section ForwardSlack`, beside its landed counterparts):

- `mem_cellAt_of_free_register_shift_of_hasForwardSlack_exact` — the downward cell membership on
  the witnessing path, resting on 909's register-lowering deletion at `n₀ := n`, `k := n' − n`,
  at the amount `m · (P + 1) + (n' − n)` with the room bound `n' + (n' − n) ≤ c`.
- `cellAt_subset_of_free_register_shift_of_pend_past_rev` — its state-level form under
  `ForwardSlackWitnessed` of the higher pair.

**The displacement dichotomy and its two non-vacuity records** (`section Collision`):

- `MonotoneCollisionDisplacement` — the dispatched shape: countdown and register displaced in the
  same direction.
- `kappa_collision_monotone_or_antitone` — every collision is monotone or antitone, no third
  case. Consumes the countdown residue alone; no `2 ≤ B` binder was added, confirmed at
  implementation time rather than assumed.
- `kappa_collision_monotone_saturated_gap_nonvacuous` — the dispatched slice reaches branch 3, at
  `(2, 0)` against `(4, 1)` with `Tc = Tn = P = 0`, `B = 2`: the exact pair the task description
  and `kappa_collision_two_regimes_refuted_of_pend_gap` pin as reached by no landed inclusion.
- `kappa_collision_antitone_residue_nonvacuous` — the excluded slice is non-empty inside the
  pending-forever regime above the threshold, at `(4, 2)` against `(6, 0)`.

**The monotone schema** (`section ForwardSlack`):

- `CellLEZeroConstOfKappaEqMonotoneForwardSlack` — the depth-`0` cell-equality schema carrying
  NEITHER the equal-register restriction NOR the common-shift displacement, with the monotone
  hypothesis in their place and the antitone exclusion therefore visible in the quantifier.
- `cellLE_zero_const_of_kappa_eq_monotone_of_forwardSlack` — that schema is a theorem at every
  parameter tuple `ParamsOk` admits, by `Set.Subset.antisymm` on the two free-register
  inclusions. The remaining bound `n' ≤ c + m · (P + 1)` is derived inside the proof from the
  higher pair's gap, so it stays out of the quantifier.

`FormalSystem/Metalogic/Decidability/RaySummary/README.md` — the `LadderCell.lean` Description
cell extended; the saturated-residue and "what it buys" paragraphs amended so that neither still
asserts the residue is reached by nothing; a new free-register layer record added, with the
antitone exclusion stated and the route it would need NAMED and claimed in neither direction.

`README.md`, `FormalSystem/Metalogic/README.md` — regenerated inventory blocks.
`typst/generated/status.typ` — regenerated line counts, once per Lean-touching phase.

`FormalSystem/README.md` was declared as a possible generated surface and came back unchanged;
`--emit-inventory` rewrote three files, not four.

## Decisions

- **Both admissible outcomes are discharged on their own halves.** The monotone slice gets a
  genuine argument; the antitone slice gets an exclusion in the signature. The dichotomy record
  is what makes the second half an exclusion rather than a gap: the excluded set is exactly the
  other side of an exhaustive alternative, not an unexamined remainder.
- **The two bounds on the free anchor pay for opposite directions of the one anchor clause.** The
  lower bound serves the register's Lipschitz bound, the upper the pin distance. Recording which
  bound buys which direction is what makes the necessity record informative rather than a bare
  counterexample.
- **The higher pair's gap `n' + 2 ≤ c + m · (P + 1)` is carried as a named hypothesis** on both
  downward statements. With the register free, the derivation the common-shift statement gets for
  free fails at `m = 0`, so it cannot be derived there.
- **Section placement follows Lean's declaration order, not the plan's section labels.** Two
  phases' declared sections were unsatisfiable as written; see Plan Deviations.
- **Every phase end was gated on a FULL-library `lake build`**, not the plan's scoped module
  build. The warm full build is ~22s here, so the stronger gate cost essentially nothing and
  catches cross-module breakage in the phase that introduces it.

## Plan Deviations

- **Phase 2 closed `[COMPLETED WITH EXCLUSIONS]`** with a `#### Reasoned Exclusions` record. The
  `n₀ := nxtAt g z + m · (P + 1)` instance reduces the landed common-shift raise EXACTLY —
  compiled out of tree with zero diagnostics, restating the landed signature byte-for-byte — but
  it cannot be applied in place: Phase 1 pins `section FreeRegister` immediately AFTER
  `end CommonShift`, so the landed theorem citing the free-register assembly would be a forward
  reference. Applying it would require re-ordering a module whose placement the plan pinned, for
  a change the plan itself classifies as a diff-reduction rather than a deliverable. The landed
  declaration is left byte-for-byte as it stands, which is the plan's own stated fallback.
  Nothing depends on Phase 2.
- **Phase 4's declared section was altered** from `section FreeRegister` to `section ForwardSlack`.
  `cellAt_subset_of_free_register_shift_of_pend_past_rev` consumes `ForwardSlackWitnessed`, which
  is DEFINED inside `section ForwardSlack` — after `end FreeRegister` — so the plan's placement is
  a forward reference and unsatisfiable as written. Both declarations land beside their landed
  counterparts instead. Names, signatures, argument order and proof routes are exactly as pinned;
  nothing mathematical changed.
- Both deviations share one root cause: the plan pinned `section FreeRegister` after
  `end CommonShift` and then assigned to it declarations that consume definitions appearing later
  in the file. Neither deviation weakens, specializes, or renames any recorded Challenge
  statement, and no landed signature drifted.

## Verification

- Build: **Success**. `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  (FULL project) exits 0, 2971 jobs, zero `error:` lines, zero warnings in `LadderCell.lean`. Run
  at every one of Phases 1, 3, 4, 5, 6 and 7, not only at the end.
- Sorry count: **0** (`lean-sorry-census.sh` over all eight resolved source roots).
- Vacuous count: **0** (no `:= True`/`Unit`/`trivial` definition shape anywhere in the new
  material; every new declaration's body consumes its hypotheses).
- Axiom count: **unchanged**. `lean_verify` on all eleven new names reports only
  `propext`, `Classical.choice`, `Quot.sound` — the module's own recorded profile — with no
  `sorryAx` and no custom axiom. The three purely arithmetic records need only
  `propext`/`Quot.sound`.
- Both witness pairs **re-run inside the declarations themselves** by `decide`, not taken from the
  plan's note.
- `bash scripts/check-module-invariants.sh`: **ALL CHECKS PASSED**, and
  `--emit-inventory --check` exits 0.
- `bash scripts/typst-sync-check.sh`: **PASS (all 4 checks green)**.
- `bash .claude/scripts/check-task-references.sh`: PASS, 0 unexempted occurrences.
- The reserved name: `grep -rnE "^\s*(noncomputable )?(theorem|def|lemma|abbrev|instance) cellLE_zero_const_of_kappa_eq\b" FormalSystem/`
  returns NOTHING. The name occurs in docstrings and README prose only.
- Files verified: Yes.

**Batch-gate deferral (recorded, not forgiven).** This dispatch is one `implement` phase inside a
multi-task `/orchestrate` batch. The final phase's `**Verification Tier**: full` was discharged
against a SCOPED tier: the full `lake build`, `check-module-invariants.sh`, `typst-sync-check.sh`,
the sorry census and the task-reference lint — the checks that actually cover this phase's touched
paths. No shell suite in `.claude/scripts/tests/run-all.sh` covers a `.lean`, generated-`typst`, or
`FormalSystem/**` markdown path (`suite_selection_select` returns `__FULL_SWEEP__` for them), and
`verify-deploy.sh` scopes to the `.claude/` deploy tree, which this task does not touch. The
complete gate set runs once for the whole batch at the end of the invocation; its result is
attributable to this task by `modified_files`.

**Pre-existing baseline, not this task's.** The dispatch context reports the deployed `.claude/`
tree STALE for the core, lean, literature, memory and typst extensions. That is unchanged by this
task and nothing under `.claude/**` was hand-patched.

**Advisory check unavailable.** `lean-challenge-snapshot.sh --check 910` exits 71 — no
`challenge/manifest.json` was taken at plan time. Advisory only per `plan-compliance.md`;
recorded, never treated as a failure. The Challenge statements were instead honoured by direct
comparison: every one of the eleven declarations carries the pinned signature verbatim.

## Impacts

- Branch 3 of `kappa_collision_regimes` is split rather than open. Every collision — branch 1,
  branch 2 and branch 3 alike — is either dispatched by
  `CellLEZeroConstOfKappaEqMonotoneForwardSlack` or falls in one named, compiled, non-empty
  excluded set. The "never leave it tacit" requirement is discharged structurally, by the
  dichotomy record, rather than by prose.
- The new schema's hypotheses SPECIALIZE to both landed schemas' at `n' = n` and
  `n' = n + m · (P + 1)`, which is the evidence that the monotone shape is the right
  generalization rather than a third sibling. Neither landed schema is retired and neither
  signature is touched.
- The free-register raise is available to any later consumer needing the countdown raised and the
  register delivered at a prescribed value, with its admissible anchor window stated and its
  lower bound's necessity compiled.
- `cellLE_zero_const_of_kappa_eq` remains reserved and unclaimed; all three forward-slack schemas
  are strictly stronger in hypotheses than the reserved statement and bear on its truth value in
  neither direction.

## Follow-ups

- The ANTITONE residue is excluded, not refuted. The route it would need is named and claimed in
  neither direction, in both
  `free_register_anchor_clause_monotone_required`'s docstring and `RaySummary/README.md`:
  forward-slack witnessing at the LOWER pair, to pay the upper direction of the anchor clause the
  necessity record compiles as failing once the lower bound on the free anchor is dropped. Whether
  such a hypothesis is satisfiable at any state the induction one layer up reaches is open.
- Retiring `exists_ladderPath_through_common_shifted_of_pend_past`'s body to the free-register
  instance remains available as a pure diff-reduction, and would require moving
  `section FreeRegister` above `section CommonShift`. The reduction itself is compiled; only the
  placement blocks it.
- No `challenge/manifest.json` exists for this task, so the mechanical statement-fidelity check
  cannot run. A snapshot taken at plan time would make it available for a later revision round.

## References

- `specs/910_saturated_gap_branch_kappa_collision_regimes/plans/01_saturated-gap-monotone-dispatch.md`
- `specs/910_saturated_gap_branch_kappa_collision_regimes/handoffs/` — one handoff per phase
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderCell.lean`
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean` — the landed raise, the
  freed-anchor lift, and the register-lowering deletion every construction here reads
