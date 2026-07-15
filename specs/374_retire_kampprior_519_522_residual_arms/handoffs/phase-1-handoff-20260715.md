# Task 374 Phase 1 Handoff — Outcome R (REFUTED)

## Immediate Next Action

Dispatch **Phase 2** (REFUTED branch): spawn the `arity_general_zone_decomposed_char_engine`
follow-up task using the payload fixed verbatim in the plan's Phase 2 section, verify
successor-style wiring, write the adjudication summary, and close out task 374. The spawn
payload may append the probe path and final line numbers:
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SeamPairRefutationProbe.lean`
(`seamPair_joint_refutation` at :47, `seamPair_joint_refutation_int` at :145).

## Current State

- Phase 1 of 3 completed; verdict **R** recorded in the plan under the Phase 1 heading.
- Phase 3 flipped to `[COMPLETED]` with "skipped — branch not taken: Phase 1 outcome R".
  Exactly one live phase remains: Phase 2.
- Full `lake build` green (1761 jobs). Probe sorry-free; `lean_verify` on both probe theorems:
  axioms exactly `{propext, Classical.choice, Quot.sound}`, no sorryAx.
- KampPrior.lean sorry census unchanged: exactly `:519`/`:522` (owned by the Phase 2 follow-up).
- No existing file was edited (probe is additive-only); preserved assets spot-checked clean.

## Key Decisions

- Probe shape: one generic theorem `seamPair_joint_refutation` (binders byte-faithful to
  `ExteriorGateAssembleK.lean:574-581`) + one concrete `(ℤ, <)` corollary establishing
  non-vacuity (realized render + six gate order-atom hypotheses, `spQnf_order_atoms`).
- Report 01 Gap B transcribed verbatim (3 steps): characteristic fiber σ* of `(w0,w0,x,t)` via
  `nf_characteristic_satisfies`; `hcharFib.mpr` at `w := u := w0`; `hcharFibSoundP` at
  `w' ≠ w0`; contradiction on the `(0<1)`/`(1<0)` order atoms via `lt_or_gt_of_ne`.
- Atom-layer extraction via `nf_eval_nf_atom_layer` (`NfEFold.lean:593`); characteristic atom
  bits via `@decide_eq_true _ (Classical.dec _)` (RefutationF2.lean:809 precedent).
- One elaboration fix during the dispatch: raw `⟨1, by omega⟩` Fin mk literals in the branch
  closers left postponed metavars that blocked defeq reduction of `atom_eval` over the abstract
  carrier; replaced with OfNat literals `(1 : Fin 4)` + `simp [atom_eval, Fin.cons_zero,
  Fin.cons_one]` (idiom precedent `ExteriorAmbientDeepAnchorK.lean:176`).

## Sorry Inventory

- `KampPrior.lean:519` — n=1, k>=2 arm of `nf_nvar_exist_all_depths` — pre-existing strategic
  sorry, NOT touched by this phase; definition of done transfers to the Phase 2 follow-up.
- `KampPrior.lean:522` — n>=2 arm — same status.
- No sorries introduced by this dispatch; probe is sorry-free.

## References

- Plan: `specs/374_retire_kampprior_519_522_residual_arms/plans/01_gap-b-adjudication-and-branch.md`
  (Phase 2 section contains the verbatim spawn payload — read it before dispatching Phase 2).
- Research: `specs/374_retire_kampprior_519_522_residual_arms/reports/01_m2-asset-sufficiency-adjudication.md`
  (Gap B argument, §Q1 follow-up target).
