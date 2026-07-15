# Summary: Gap B Adjudication and Branch (task 374)

- **Task**: 374 - retire_kampprior_519_522_residual_arms
- **Date**: 2026-07-15
- **Plan**: specs/374_retire_kampprior_519_522_residual_arms/plans/01_gap-b-adjudication-and-branch.md
- **Outcome**: Phase 1 verdict **R (REFUTED)** — Phase 2 (REFUTED branch) executed; Phase 3 (NOT-REFUTED contingency) skipped as branch-not-taken.

## Phase 1 Verdict: Gap B machine-refuted

The seam pair `hcharFib` (ExteriorGateAssembleK.lean:574-578) + `hcharFibSoundP` (:579-581) is
**jointly refutable**: assuming both hypothesis signatures simultaneously derives `False`.

- **Probe artifact**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SeamPairRefutationProbe.lean`
  - `seamPair_joint_refutation : … → False` (line 47) — sorry-free
  - `seamPair_joint_refutation_int` (line 145) — concrete (ℤ, <) non-vacuity instance
    (`spQnf_render`, `spQnf_order_atoms`)
- **Verification**: full `lake build` green (1761 jobs); `lean_verify` on both theorems reports
  axioms exactly `{propext, Classical.choice, Quot.sound}`, no `sorryAx`.
- **Commit**: `01ddc0f8a`.

Consequence: the `:519` general-k arm cannot be discharged against the seams as currently
signed. The refutation refutes the *hypothesis signatures*, not any completed proof — the seams
must be re-signed (anchor-contextual, zone-decomposed), which is out of scope for this task per
its directive: if the adjudication refutes, STOP and spawn a narrowly-scoped follow-up rather
than re-opening the carrier design.

## Preserved Assets (all five untouched, no regression)

No Lean file outside the new probe was modified by this task. The five preserved assets from
the plan's Preserved Assets table remain exactly as verified (`lean_verify` clean, axioms
`{propext, Classical.choice, Quot.sound}`, no sorryAx, 2026-07-15):

| Component | File |
|-----------|------|
| `kampPrior_hreal_supply` (row-5 interior realizer, seven zones) | NfMultiAnchorBridge/InteriorHrealSupplyK.lean:61 |
| `bracketEndChar_kvExtFib_correct_prior` (per-qnf gate certificate) | NfMultiAnchorBridge/ExteriorGateAssembleK.lean:559 |
| `kvE_hsliceFut_supply` / `kvE_hslicePast_supply` (rows 8-9) | NfMultiAnchorBridge/ExteriorDeepSliceSupplyK.lean:131/161 |
| `kvE_hexclDeepFut_supply` / `kvE_hexclDeepPast_supply` (rows 12-13) | NfMultiAnchorBridge/ExteriorDeepExclSupplyK.lean:77/107 |
| `kampPrior_site_rungKFib_gate_match` (conditional gate theorem) | KampPrior.lean:1058 |

These certificates are sorry-free but uninstantiable at the `:519` site as signed (that was
Gap B). The follow-up task re-signs the seams and re-consumes these assets; no follow-up scoping
language proposes deleting or rewriting them.

## Definition-of-Done Transfer

**The definition of done — zero sorries in KampPrior.lean, full lake build green, no new
axioms — is transferred to spawned follow-up task 376**
(`arity_general_zone_decomposed_char_engine`, task_type lean4, effort large, no dependencies).
Task 376 was created with the plan's spawn payload verbatim: ONE arity-general, zone-decomposed
char/provider engine for the M2 de-folded carrier discharging `:519` (n=1 instance) and `:522`
(n>=2 instances) together by Rabinovich 2014 Lemma 5.3's induction on n, with sibling-level
(NOT file-level) frozen boundaries, the route (b) prohibition, and the `:522` non-deferrability
constraint carried in the task description.

Wiring is successor-style: task 374 completes now and does NOT depend on task 376; task 376 has
`parent_task: 374` and empty dependencies.

## Residual Sorries (owned by task 376)

**`KampPrior.lean:519` and `KampPrior.lean:522` remain as sorries.** They are pre-existing
(present at this task's dispatch start), were deliberately NOT attempted here per the Phase 2
directive (proof construction stops at the refutation), and are now owned by follow-up task 376,
which inherits the definition of done above.

## Phases Executed

| Phase | Status | Result |
|-------|--------|--------|
| 1 — Gap B refutation probe | [COMPLETED] | Outcome R; probe compiled sorry-free; commit `01ddc0f8a` |
| 2 — REFUTED branch: spawn + closeout | [COMPLETED] | Task 376 spawned (payload verbatim); summary + handoff written; task 374 closed |
| 3 — NOT-REFUTED contingency | [COMPLETED] (skipped) | Branch not taken (precondition "Outcome S" false) |

No Lean output in Phase 2 (by design); no plan deviations beyond the pre-annotated Phase 3 skip.
