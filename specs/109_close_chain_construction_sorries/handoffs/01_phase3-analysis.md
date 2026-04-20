# Phase 3-5 Analysis: Chain Construction Sorries

## Summary

Deep analysis of the 5 remaining sorry sites in RootScopedChain.lean reveals
fundamental proof-theoretic obstacles that require a chain redesign, not just
tactical proof filling. This document captures the analysis for future work.

## Sorry Sites

| # | Location | Goal |
|---|----------|------|
| 1 | `fwd_chain_forward_F` (L1079) | F(phi) in chain(n) => exists m > n, phi in chain(m) |
| 2 | `dd_bfmcs_restricted_tc` forward t-s<0 (L1106) | F(phi) in backward chain => phi at some later time |
| 3 | `dd_bfmcs_restricted_tc` backward (L1113) | P(phi) in chain(t) => phi at some earlier time |
| 4 | `dd_bfmcs_restricted_buc` (L1121) | Backward Until/Since coherence |
| 5 | `dd_bfmcs_restricted_fuc` (L1128) | Forward Until/Since coherence |

## Fundamental Obstacle: F-Defect Resolution

### The Problem

`fwd_chain_forward_F` (sorry #1) is the keystone. It needs: given F(phi) in chain(n)
and phi in sigma_list, prove phi appears at some later chain step.

The current chain uses `preserving_fwd_step` which internally calls
`resolving_enriched_fwd_exists` (BX11 fold). This guarantees:
- g_content(chain(n)) subset chain(n+1)
- SOME defect w is resolved (w in chain(n+1))
- ALL defects are preserved (chi in chain(n+1) or F(chi) in chain(n+1))

The resolved w is nondeterministic (chosen by BX11 fold + Lindenbaum axiom of choice).
We cannot control WHICH defect gets resolved.

### Why BX11 Alone Is Insufficient

BX11 (temp_linearity): F(A) /\ F(B) -> F(A /\ B) \/ F(A /\ F(B)) \/ F(F(A) /\ B)

Applied to target phi and compound alpha of other defects:
- Case 1: F(phi /\ alpha) => seed {phi, alpha} U g_content => phi in M' (RESOLVED)
- Case 2: F(phi /\ F(alpha)) => seed {phi, F(alpha)} U g_content => phi in M' (RESOLVED)
- Case 3: F(F(phi) /\ alpha) => seed {F(phi), alpha} U g_content => F(phi) in M' only (NOT RESOLVED)

Case 3 prevents direct resolution. The BX11 outcome depends on the MCS state,
not on our choice. Case 3 can fire at every round-robin step for phi indefinitely --
there is no BX axiom that prevents perpetual case-3 deferral.

### Why g_content Doesn't Preserve F-Defects

F(phi) = neg(G(neg(phi))). For F(phi) to be in g_content(M), we need G(F(phi)) in M,
i.e., G(neg(G(neg(phi)))) in M ("always eventually phi"). This is MUCH stronger than
F(phi) in M. So F-defects do NOT propagate through g_content alone.

### Why Round-Robin Targeting Fails

The Boneyard's `targeted_forward_chain` uses `fwd_succ` with round-robin targeting.
`fwd_succ_resolves` guarantees the target is resolved when F(target) in M.
BUT: at intervening steps (when other targets are scheduled), F(phi) may vanish
because the Lindenbaum extension (axiom of choice) might include G(neg(phi))
instead of F(phi). Once G(neg(phi)) enters the chain, it propagates forward
via g_content (temp_4: G(A) -> G(G(A))), killing phi forever.

### Prior Attempts in Boneyard

1. **FiniteDeferral.lean**: Pigeonhole on restricted theories. Uses X-operator
   (`x_mem_chain_general`) which requires discreteness axiom NOT in BX.
   Step 5 (cycle contradiction) was itself sorry'd.

2. **TargetedChain.lean**: Round-robin with `canonical_forward_F`. Has
   g_content propagation and resolution proofs, but no F-defect preservation.

3. **DRMChain.lean**: Uses `temp_t_future` (G(phi) -> phi) which is NOT
   valid under irreflexive strict semantics.

4. **RoundRobinChain.lean**: Confirmed dead after 40 research rounds due to
   "BX11 perpetual deferral obstruction."

## Until Coherence Obstacles

### Step Transfer (needed for sorry #4)

Backward Until coherence needs: (phi U psi) in chain(r+1) and phi in chain(r)
implies (phi U psi) in chain(r).

Under strict semantics, the standard approach via G-unwrapping is blocked:
- G(phi U psi) in chain(r) does NOT give (phi U psi) in chain(r) because
  temp_t (G(A) -> A, reflexivity) is not available
- h_content reverse: h_content(chain(r+1)) subset chain(r), but
  (phi U psi) is not an H-formula
- BX4' (connect_past) gives F(phi U psi) in chain(r) (from chain(r+1)),
  but F(phi U psi) does not simplify to (phi U psi)

The UntilSinceCoherence.lean docstring explicitly states: "This step is NOT
derivable from the bare FMCS structure (forward_G, backward_H)."

### Forward Until (sorry #5)

Forward Until coherence requires: (phi U psi) in chain(t) gives witness
s > t with psi in chain(s) and phi on [t,s). This depends on temporal
coherence (F(psi) resolution), creating a circular dependency with sorry #1.

## Recommended Path Forward

### Option A: BX11 Fold Strengthening

Prove that BX11 case 3 cannot fire indefinitely for a fixed target.
This would require a deep structural argument about MCS sequences,
possibly using the finiteness of deferralClosure or a well-ordering
argument on BX11 compounds. No clear proof strategy identified.

### Option B: Two-Phase Chain Construction

Replace `preserving_fwd_step` with a two-phase step:
1. Phase A: BX11 fold to preserve ALL defects (current approach)
2. Phase B: If target was not resolved (case 3), immediately do a second
   step using `discharge_single_step` for the target

Show that g_content(M) subset g_content(M') subset M'' across both phases.
The concern: other defects are NOT preserved across phase B. But this
might be acceptable if we can show defects are "eventually" resolved
using a separate argument.

### Option C: Enriched Seed Chain

Build a chain step that includes BOTH the BX11 fold compound AND the target
in the Lindenbaum seed. Specifically:
- In BX11 cases 1,2: seed = {phi, alpha} U g_content (phi resolved)
- In BX11 case 3: seed = {F(phi), beta} U g_content (F(phi) preserved)
  Then immediately retry with a NEW BX11 application to the result MCS.

The key insight: after case 3, the MCS M' has both F(phi) and beta (direct).
A second BX11 application in M' might give a different outcome because M'
is a different MCS from M.

### Option D: Fundamental Redesign

Use a completely different chain construction:
- X/Y deterministic chain (requires adding discreteness to BX)
- Quasimodel-based construction (already partly explored in Boneyard)
- Conservative extension to a system with stronger temporal primitives

### Recommended: Option C, falling back to Option D

Option C is the most promising near-term approach. If BX11 case 3 persists
after the retry in M', the analysis suggests the issue is fundamental and
Option D (system extension) may be needed.

## Key Infrastructure Already Available

- `enriched_fwd_fold` / `enriched_fwd_fold_with_witness`: BX11 fold with tracking
- `resolving_enriched_fwd_exists`: Fold + Lindenbaum + at-least-one-resolved
- `target_stays_direct_in_fold`: Targeted resolution when bx11_earliest
- `discharge_single_step`: Single-target resolution with g_content
- `backward_until_from_step`: Parameterized backward Until (needs step transfer)
- `defect_fwd_step` / `defect_resolving_seed_consistent`: Enriched seed infrastructure

## Files Analyzed

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (1501 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`
- `Theories/Bimodal/Metalogic/Bundle/UntilSinceCoherence.lean`
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean`
- `Theories/Bimodal/ProofSystem/Axioms.lean`
- `Theories/Bimodal/Boneyard/ChainCompleteness/Algebraic/FiniteDeferral.lean`
- `Theories/Bimodal/Boneyard/ChainCompleteness/Bundle/TargetedChain.lean`
- `Theories/Bimodal/Boneyard/RoundRobinChain/DRMChain.lean`
