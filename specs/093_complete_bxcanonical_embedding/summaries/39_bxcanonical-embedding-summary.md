# Implementation Summary: BXCanonical Embedding (v39)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: BLOCKED (Phase 1)
- **Plan**: plans/39_bxcanonical-embedding.md
- **Session**: sess_1776541086_6523e9

## Outcome

Phase 1 (backward Until/Since coherence) is **blocked by a definitive mathematical obstacle**. The plan's proposed "Until introduction derived rule" (`phi /\ F(phi U psi) -> phi U psi`) is **semantically invalid** and therefore not derivable from BX1-BX12. This invalidates the entire Phase 1 approach.

## Root Cause Analysis

### The Obstacle

Backward Until coherence says: if `psi in fam.mcs(s)` and `phi in fam.mcs(r)` for all `t <= r < s`, then `phi U psi in fam.mcs(t)`.

The dd_chain families have g_content/h_content propagation:
- `G(alpha) in chain(t) => alpha in chain(t+1)` (g_content forward)
- `H(alpha) in chain(t+1) => alpha in chain(t)` (h_content backward)

For the inductive step (s > t): By IH, `phi U psi in chain(t+1)`. And `phi in chain(t)` (guard). Need `phi U psi in chain(t)`.

From `phi U psi in chain(t+1)`:
- By BX4' (`connect_past`): `H(F(phi U psi)) in chain(t+1)`
- By h_content backward: `F(phi U psi) in chain(t)`

So we have `phi in chain(t)` AND `F(phi U psi) in chain(t)`. The plan proposes deriving `phi U psi in chain(t)` from these.

**However, `phi /\ F(phi U psi) -> phi U psi` is semantically INVALID:**

Counter-model: phi holds at t=0, F(phi U psi) holds at t=0 (with phi U psi at t=2, psi at t=2), but NOT phi at t=1. Then phi U psi fails at t=0 because phi doesn't hold on [0, 2).

### BX4 vs BX3 Confusion

The plan mentions using `G(H(...))` forward propagation (BX3 = `connect_future`: `alpha -> G(P(alpha))`). However:
- BX3 gives `G(P(alpha))`, NOT `G(H(alpha))`. P = some_past (existential), H = all_past (universal).
- So from `neg(phi U psi) in chain(t)`, BX3 gives `G(P(neg(phi U psi))) in chain(t)`, which propagates forward to give `P(neg(phi U psi)) in chain(t+1)`. This is "neg(phi U psi) held at SOME past time" -- compatible with `phi U psi in chain(t+1)`. No contradiction.

### Why g_content/h_content Is Insufficient

The g_content/h_content propagation can only transfer formulas that are G-wrapped or H-wrapped. From `phi U psi in chain(t+1)`, backward propagation gives `F(phi U psi) in chain(t)` (strictly weaker than `phi U psi in chain(t)`). Forward propagation of `neg(phi U psi) in chain(t)` gives `P(neg(phi U psi)) in chain(t+1)` (compatible with `phi U psi in chain(t+1)`).

There is no BX axiom sequence that bridges the gap from `{phi, F(phi U psi)}` to `phi U psi`.

### Why the Boneyard Proof Works (and Doesn't Apply)

The Boneyard's `backward_until_chain` proof (DeterministicFMCS.lean) uses `x_mem_chain_general`: `phi in chain(t+1) <=> X(phi) in chain(t)` where `X(phi) = bot U phi`. Under reflexive Until (BX8), `bot U phi <-> phi`, so x_content(M) = M and the deterministic chain is CONSTANT (chain(t) = M_0 for all t). Backward Until then reduces to BX8 at the base case.

The dd_chain is NOT constant (enriched_fwd_step changes the MCS at each step to resolve F-defects), so the Boneyard proof doesn't apply.

### Seed Augmentation Fails

Attempts to augment the enriched_fwd_step seed with Until formulas from the current MCS (to force Until persistence) fail because:
1. The augmented seed `{target} U g_content(M) U UntilFormulas(M)` is NOT provably consistent when F(target) in M.
2. The G-necessitation argument (used by enriched_resolving_seed_consistent) requires all seed elements to be G-wrapped in M. Until formulas in M don't have `G(phi U psi) in M` (semantically, phi U psi doesn't persist forever).

## Definitive Diagnostic Questions (Answered)

1. **Does `bx_le w v` give `h_content(v) ⊆ w`?** — NOT ASSESSED (Phase 2 not reached).
2. **Does `phi /\ F(phi U psi) -> phi U psi` follow from BX1-BX12?** — **NO. Semantically invalid.**
3. **Does the extended seed consistency argument work?** — NOT ASSESSED (Phase 2 not reached).

## Viable Path Forward

The fundamental tension is:
- **Forward F resolution** (restricted_tc) requires the chain to CHANGE between steps (enriched_fwd_step).
- **Backward Until coherence** (restricted_buc) is trivial for CONSTANT chains (BX8) but non-trivial for changing chains.

A potential approach (not yet attempted):
1. Build a TWO-PASS chain: first build dd_chain for F-resolution, then overlay Until formulas backward.
2. Or: construct a new BFMCS where each family uses a SINGLE MCS (constant chain) enriched with a separate mechanism for F-witnesses (e.g., quasimodel approach).
3. Or: prove all three restricted coherence conditions simultaneously for a new BFMCS construction that addresses F-resolution, backward Until, and forward Until in a unified framework.

## Files Examined

- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — main target (sorry sites at lines 1517, 1522, 1527)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean` — coherence definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` — BX1-BX12 axiom definitions
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Theorems/TemporalDerived.lean` — derived theorems (until_intro, or_until_imp, etc.)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicFMCS.lean` — Boneyard backward Until proof
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/DeterministicChain.lean` — deterministic chain (constant under reflexive Until)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` — truth lemma using buc
