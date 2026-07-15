# Task 374 Phase 1 Progress

- **Phase**: 1 — Compile the Gap B seam-pair refutation probe
- **Status**: done
- **Session**: sess_1784133475_d9e662
- **Date**: 2026-07-15

## Verdict

**Outcome R (REFUTED).** The seam pair {`hcharFib`, `hcharFibSoundP`} is jointly refuted by a
compiled, sorry-free probe. Next phase per the mechanical branch condition: **Phase 2**
(REFUTED branch — spawn follow-up, close out task 374). Phase 3 marked skipped.

## Objectives

- [done] Probe file created (additive-only, no existing file edited):
  `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SeamPairRefutationProbe.lean`
- [done] `seamPair_joint_refutation : … → False` — generic joint refutation, binders
  byte-faithful to `ExteriorGateAssembleK.lean:574-581` (cross-checks `KampPrior.lean:1073-1082`,
  `InteriorGateGeneralK.lean:2115-2117` quoted in docstring)
- [done] `seamPair_joint_refutation_int` — concrete `(ℤ, <)` non-vacuity instance
  (`x = 0 < w0 = 1 < t = 2`, `w' = 3`), with `spQnf_render` (realized render) and
  `spQnf_order_atoms` (six gate order-atom hypotheses hold)
- [done] Full `lake build` green (1761 jobs)
- [done] `lean_verify` both theorems: axioms exactly `{propext, Classical.choice, Quot.sound}`,
  no sorryAx, no warnings
- [done] Invariants: KampPrior sorry census unchanged (exactly `:519`/`:522`); zero sorries in
  probe; no new axioms; no vacuous defs; preserved assets
  (`kampPrior_hreal_supply`, `kampPrior_site_rungKFib_gate_match`) `lean_verify` clean

## files_touched

- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SeamPairRefutationProbe.lean (new)
- specs/374_retire_kampprior_519_522_residual_arms/plans/01_gap-b-adjudication-and-branch.md (verdict + heading flips)

## Sorry Inventory

Task-wide inventory (inherited, NOT owned by this phase; definition of done transfers to the
Phase 2 spawned follow-up):

| File | Line | Statement | Strategic | Owner |
|------|------|-----------|-----------|-------|
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 519 | `nf_nvar_exist_all_depths` n=1, k>=2 arm | yes (pre-existing) | Phase 2 follow-up task |
| Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean | 522 | `nf_nvar_exist_all_depths` n>=2 arm | yes (pre-existing) | Phase 2 follow-up task |

No sorries introduced by this dispatch.
