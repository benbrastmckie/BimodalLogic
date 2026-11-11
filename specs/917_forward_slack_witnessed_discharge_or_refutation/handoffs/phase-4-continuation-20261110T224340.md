# Phase 4 continuation handoff -- task 917

- **Immediate next action**: implement Phase 4. The plan revision the prior handoff asked for has
  landed, so the phase is dispatchable as written -- no further authoring step stands in front of
  it.
- **What the revision changed**: Phase 4's pinned `## Lean Challenge Statements` signature for
  `exists_deleted_ladderPath_of_next_region_nxt` now carries
  `hnz : (nxtAt g z : ℤ) ≤ (cntAt g z : ℤ)` on one line between `hza` and `hpast`, in the minimal
  cast form (not the stronger pending-forever gap). `hpast` is retained -- the proof uses it to
  prove `habove`. The plan records the admission at its Phase 4 **ADMITTED HYPOTHESIS, `hnz`**
  section and in Decision 3.
- **Why the deficit was real**: `delCnt` lowers by exactly `l` the VALUE of the pin that starts
  the region CONTAINING the deleted block. That pin's POSITION is undisplaced, so it sits below
  `a`, outside `hanch`'s `a ≤ v` range, and must be discharged internally. Reducing its anchor
  obligation through `cntAt_ge_of_reaches`, `hcl` and `hza` leaves precisely
  `nxtAt g z ≤ cntAt g z`. `hpast` cannot supply it: `Drift n n' := n' = n ∨ n' = n + 1 ∨ n' + 1 = n`
  admits free ±1 register drift, so a pending-forever past leaves the register unconstrained
  against the countdown in either direction.
- **Why it is free downstream**: Phase 6 is the only consumer. It instantiates at
  `⟨(q, C, N), h⟩` at `z`, where `cntAt g z = C` and `nxtAt g z = N`, and already carries
  `hgap : N + 2 ≤ C`, which gives `(N : ℤ) ≤ (C : ℤ)` outright. Phase 6's own signature is
  unchanged and `hnz` is not propagated into it; its checklist carries the discharge step.
- **Route for the implementer**: lift the proof from
  `evidence/phase-4-pinned-signature-deficit.lean` verbatim rather than re-deriving it. It is
  already green against the real tree under this exact signature -- both pull lemmas
  (`probe_low`/`probe_high`), the four pin-compatibility cases, and the anchor clause at every
  pin. `hnz` is named in no tactic; a single `omega` consumes it, so admitting it changes no
  proof text.
- **Guard that still binds**: land the signature AS PINNED, `hnz` included and nothing further.
  Adding any hypothesis beyond `hnz`, or editing the recorded Challenge statement again to match
  what compiles, is the laundering `.claude/rules/plan-compliance.md`'s Statement Fidelity
  section exists to catch. If a second deficit appears, STOP and report it rather than widening
  the statement.
- **State**: Phases 1-3 COMPLETED and committed, each on a green full `lake build` (2973 jobs,
  0 errors, 0 warnings). Phase 4 dispatchable. Phases 5-9 NOT STARTED, each depending on Phase 4.
- **Gate residuals owed to Phase 9**: three stale generated inventory blocks (`README.md`,
  `FormalSystem/Metalogic/README.md`,
  `FormalSystem/Metalogic/Decidability/RaySummary/README.md`) from this task's line-count changes.
  Not regressions.
