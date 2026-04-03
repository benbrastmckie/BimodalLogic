# Implementation Summary: Strict Semantics Refactor (Partial)

- **Task**: 83 - Close Restricted Coherence Sorries
- **Plan**: plans/11_strict-semantics-refactor.md
- **Status**: PARTIAL

## Completed Phases

### Phase 1: Syntax and Axiom Foundation [COMPLETED - prior commit]
### Phase 2: Semantic Truth Definition [COMPLETED - prior commit]

### Phase 3: Soundness -- Core Axiom Validity [COMPLETED]
- Soundness.lean compiles with zero sorry on the soundness path
- Fixed Mathlib API changes: Order.le_pred_of_lt, Order.le_of_lt_succ
- Fixed Succ.rec/Pred.rec usage (refine pattern instead of induction ... using)
- Discovered and fixed two unsound axioms:
  - **until_induction**: Added G() around premises for universal quantification
  - **until_linearity**: Added third disjunct F(psi AND psi') for coinciding witnesses
- Mirror fixes for since_induction (H-quantified) and since_linearity (P-disjunct)

### Phase 4: Soundness Lemmas and Algebraic Layer [COMPLETED]
- STSA TL axiom changed to include present moment
- TL_quot proof rewritten without temp_t_future
- SoundnessLemmas.lean, LinearityDerivedFacts.lean docs updated

### Phase 5: Canonical Model -- FMCS and Chain Infrastructure [BLOCKED]
- FMCS structure changed from reflexive (<=) to strict (<)
- TemporalCoherentFamily changed: forward_F/backward_P use strict <
- BFMCS.temporally_coherent changed to strict <
- temporal_backward_G/H signatures changed to strict <
- Removed existsTask_reflexive/past_reflexive from CanonicalIrreflexivity
- Removed succ_chain_forward_G_le/backward_H_le from SuccChainFMCS
- All temp_t_future/temp_t_past references replaced with sorry across 8 files
- until_unfold_in_mcs/since_unfold_in_mcs rewritten for X/Y-based axiom shapes

## Blocking Issues

### 1. g_content(u) subset u (T-axiom dependency)
Under strict semantics, `G(phi) in M -> phi in M` is NOT derivable.
Multiple theorems in SuccExistence.lean, SuccChainFMCS.lean, UltrafilterChain.lean,
DovetailedChain.lean depend on this property. Needs proof-theoretic restructuring
(e.g., routing through seed construction or temporal_theory_witness_exists).

Affected files: SuccExistence.lean (3 sites), SuccChainFMCS.lean (4 sites),
UltrafilterChain.lean (9 sites), DovetailedChain.lean (10 sites),
MCSWitnessSuccessor.lean (2 sites), TargetedChain.lean (4 sites)

### 2. until_unfold_in_mcs return type changed
Old: `psi in M OR (phi in M AND G(phi U psi) in M)` (disjunction at current time)
New: `X(psi OR (phi AND (phi U psi))) in M` (next-step projection)
Downstream code in DovetailedChain and CanonicalConstruction.lean depends on the
old return type to "peel off" Until layers at the current time.

### 3. WitnessSeed.lean axiom shape mismatch
until/since_induction now have G/H-quantified premises. The WitnessSeed proofs
that use these axioms need updating for the new formula shapes.

### 4. CanonicalConstruction.lean cascade (~30 errors)
Multiple <= to < type mismatches throughout the canonical truth lemma and
restricted truth lemma. Each needs trichotomy split instead of le_or_lt.

## Files Modified

| File | Status |
|------|--------|
| Theories/Bimodal/ProofSystem/Axioms.lean | Updated (all axioms correct) |
| Theories/Bimodal/ProofSystem/Substitution.lean | Updated |
| Theories/Bimodal/Metalogic/Soundness.lean | Compiles (zero sorry on main path) |
| Theories/Bimodal/Metalogic/SoundnessLemmas.lean | Compiles |
| Theories/Bimodal/Semantics/Truth.lean | Updated (prior phase) |
| Theories/Bimodal/Semantics/Validity.lean | Updated |
| Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean | Compiles |
| Theories/Bimodal/Metalogic/Algebraic/InteriorOperators.lean | Compiles |
| Theories/Bimodal/Metalogic/Algebraic/ParametricHistory.lean | Updated |
| Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean | Partially updated |
| Theories/Bimodal/Metalogic/Bundle/FMCSDef.lean | Updated (strict <) |
| Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean | Updated |
| Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean | Partially updated (4 sorry) |
| Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean | Partially updated (1 sorry) |
| Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean | Updated (strict <) |
| Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean | Partially updated (3 sorry) |
| Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean | Partially updated (2 sorry) |
| Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean | Partially updated |
| Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean | temp_t removed (sorry) |
| Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean | temp_t removed (sorry) |
| Theories/Bimodal/Metalogic/Bundle/MCSWitnessSuccessor.lean | temp_t removed (sorry) |
| Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean | temp_t removed (sorry) |

## Axiom Changes (Critical)

| Axiom | Change | Reason |
|-------|--------|--------|
| until_induction | Added G() around premises | Unsound without universal quantification |
| since_induction | Added H() around premises | Mirror of until_induction |
| until_linearity | Added F(psi AND psi') disjunct | Unsound when witnesses coincide |
| since_linearity | Added P(psi AND psi') disjunct | Mirror of until_linearity |
| temp_t_future | REMOVED (Phase 1) | Invalid under strict G |
| temp_t_past | REMOVED (Phase 1) | Invalid under strict H |

## Build Status

Build fails with ~30 errors in CanonicalConstruction.lean (type mismatches from <= to < cascade).
All other files compile (some with sorry for T-axiom dependencies).
