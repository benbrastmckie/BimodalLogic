# Handoff: BXCanonical Deferral Chain Modification

## Session: sess_1776102641_0aa6a9
## Date: 2026-04-13
## Agent: lean-implementation-agent

## What Was Accomplished

### Phase 1: Expansion Axiom Prerequisites (COMPLETED)

Added 4 new derived theorems to `Theories/Bimodal/Theorems/TemporalDerived.lean`:

1. `refl_F : alpha -> F(alpha)` -- Any formula implies its own future eventuality (from BX1 contrapositive + DNI)
2. `refl_P : alpha -> P(alpha)` -- Dual for past direction
3. `until_F_expansion : (phi U psi) -> psi v (phi ^ F(phi U psi))` -- Strengthening of `until_unfold_thm` with F-wrapped Until
4. `since_P_expansion : (phi S psi) -> psi v (phi ^ P(phi S psi))` -- Dual for Since

All 4 theorems are sorry-free and `lake build` passes.

### Phase 2: Deferral Chain Modification (PARTIAL -- reverted)

Attempted to modify `fwd_succ` and `bwd_pred` in `CanonicalModel.lean` to use deferral disjunction seeds. The modification was:
- Resolving seed: `{psi} U g_content(M) U deferralDisjunctions(M)` (was `{psi} U g_content(M)`)
- Non-resolving seed: `g_content(M) U deferralDisjunctions(M)` (was `g_content(M) U f_carry(M)`)

The modification was REVERTED because the consistency proof for the augmented resolving seed is non-trivial:
- `{psi} U g_content(M)` is proved consistent by `forward_temporal_witness_seed_consistent` using a sophisticated generalized temporal K argument
- `deferralDisjunctions(M) ⊆ M` is provable (each `chi v F(chi)` is in M when `F(chi) in M`)
- BUT adding `deferralDisjunctions(M)` to `{psi} U g_content(M)` requires re-proving consistency since superset of a consistent set can be inconsistent
- The proof needs to extend the generalized temporal K argument to handle deferral disjunction formulas mixed with g_content formulas

## Critical Finding: Backward Until Step Transfer Gap

The plan's Phase 3 (backward Until via contrapositive) has a FUNDAMENTAL gap:

### The Plan's Proposed Argument
1. Assume `neg(phi U psi) in chain(t)` (contradiction)
2. `phi in chain(t)` (from guard)
3. Derive `G(neg(phi U psi)) in chain(t)` via expansion axiom
4. Propagate to `neg(phi U psi) in chain(r)` via forward G
5. Contradicts `psi in chain(r)` + BX8

### The Gap
Step 3 requires: `neg(phi U psi) ^ phi -> G(neg(phi U psi))` in MCS.

This would follow from the BICONDITIONAL: `(phi U psi) <-> psi v (phi ^ F(phi U psi))`.

The FORWARD direction is proved: `(phi U psi) -> psi v (phi ^ F(phi U psi))` (my `until_F_expansion`).

The REVERSE direction `psi v (phi ^ F(phi U psi)) -> (phi U psi)` is NOT a BX theorem:
- The `psi` branch: OK via BX8
- The `phi ^ F(phi U psi)` branch: requires `phi ^ F(phi U psi) -> (phi U psi)` which says "phi now and phi U psi at some future time implies phi U psi now" -- this is false when phi doesn't hold at intermediate times

Without the biconditional, we cannot derive `G(neg(phi U psi))` from `neg(phi U psi)` and `phi` in an MCS. The contrapositive of the forward direction gives `neg(conclusion) -> neg(premise)`, not `neg(premise) -> neg(conclusion)`.

The research report (05_team-research.md) at line 181 acknowledges this: "the contrapositive argument IS the step transfer in disguise."

### Consequence
Backward Until coherence (`bx_bfmcs_restricted_buc`) CANNOT be proved without chain modification. The chain must provide step transfer: `(phi U psi) in chain(r+1) ^ phi in chain(r) -> (phi U psi) in chain(r)`.

The deferral disjunction modification (Phase 2) helps ONLY with forward_F, NOT with backward Until step transfer. Forward Until defect propagation (adding `psi v (phi ^ (phi U psi))` to seeds) helps with forward Until but not backward.

## What's Needed Next

### For Phase 2 (Deferral Seeds)
1. Prove `augmented_resolving_seed_consistent`: need to extend the generalized temporal K argument from `forward_temporal_witness_seed_consistent` to handle deferral disjunctions. The approach: replicate the proof from `WitnessSeed.lean` but partition `L` into g_content formulas, deferral formulas, and the resolving formula `psi`.
2. Update `bwd_pred` symmetrically using `pastDeferralDisjunctions`.
3. Verify that all downstream lemmas (`fwd_chain_g_content_step`, `int_chain_forward_G`, `box_stable_in_int_chain`) still hold.

### For Phase 3 (Backward Until)
Three options, in order of preference:
1. **P-step approach**: Use `constrained_successor_from_seed` (from SuccExistence.lean) which gives Succ with P-step property. Then `P(phi U psi) in chain(r+1)` gives `(phi U psi) in chain(r) v P(phi U psi) in chain(r)`. Iterate backward. Issue: infinite regress for P(phi U psi) propagation -- needs a bounded witness or termination argument.
2. **Until-induction axiom**: Add a BX-derivable Until induction axiom to the proof system. This would directly give the biconditional. But requires extending the axiom set.
3. **Chain reconstruction**: Build the chain using a different constructor that preserves Until formulas backward. E.g., use the Hintikka point construction from `Quasimodel/Construction.lean` instead of the dovetailed Lindenbaum chain.

### For Phase 4 (Forward Until)
Depends on Phase 2 (restricted forward_F) + the backward Until argument for the guard condition. The guard proof uses the same structure as backward Until.

## Files Modified
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- Added refl_F, refl_P, until_F_expansion, since_P_expansion (~100 lines)

## Files NOT Modified (reverted)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Deferral seed modification reverted

## Key API Inventory
- `deferralDisjunctions` (SuccExistence.lean) -- Future deferral disjunctions
- `pastDeferralDisjunctions` (SuccExistence.lean) -- Past deferral disjunctions
- `deferral_disjunction_from_F` (SuccExistence.lean) -- F(phi) derives phi v F(phi)
- `backward_until_from_step` (UntilSinceCoherence.lean) -- Backward Until given step transfer
- `constrained_successor_from_seed` (SuccExistence.lean) -- Successor with Succ properties
- `refl_F` (TemporalDerived.lean, NEW) -- alpha -> F(alpha)
- `until_F_expansion` (TemporalDerived.lean, NEW) -- (phi U psi) -> psi v (phi ^ F(phi U psi))
