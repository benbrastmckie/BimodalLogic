# Execution Summary: Task 86 - USF Completeness Implementation Attempt

**Task**: 86 - Close BXCanonical completeness sorries
**Session**: sess_1775751021_effac8
**Status**: BLOCKED - Mathematical obstruction in the implementation plan
**Phases Completed**: 0 of 4

## What Was Attempted

Thorough investigation of the implementation plan for closing the sorry at
`CanonicalEmbedding.lean:418` (imp Case B of `usf_completeness`).

## Findings: Three Mathematical Obstructions

### Obstruction 1: Combined F-Seed Consistency is FALSE

The plan (Phase 1) claims that `{psi | F(psi) in w} union g_content(w)` is consistent.
This is **FALSE** in general.

**Counterexample**: Let w be an MCS with G(psi -> neg psi') in w, F(psi) in w, and F(psi') in w.
Then:
- `(psi -> neg psi')` is in g_content(w) (since G(psi -> neg psi') in w)
- psi and psi' are in `{psi | F(psi) in w}`
- The seed `{psi, psi', psi -> neg psi'}` derives bot

Such w can exist: F(psi) and F(psi') say psi and psi' each hold at SOME future time
(not necessarily the same time), while G(psi -> neg psi') says whenever psi holds, psi'
fails. This is temporally consistent (psi at t1, psi' at t2 != t1) but the combined seed
tries to put them in the SAME MCS (same time point), which is inconsistent.

### Obstruction 2: One-at-a-Time Chain Does Not Guarantee forward_F

The alternative approach (resolve one F-obligation per step using the single-target
`forward_temporal_witness_seed_consistent`) fails to prove the key `forward_F` property:

> F(psi) in chain(t) -> exists r > t, psi in chain(r)

The obstruction: F-formulas do NOT persist along the bx_le-monotone chain.
F(psi) = neg(G(neg psi)) in chain(t) means G(neg psi) not-in chain(t).
But G(neg psi) might enter chain(n) for n > t through the non-deterministic
Lindenbaum extension at some step, even though it was absent at step t.
Once G(neg psi) enters the chain, F(psi) is killed, and the dovetail step
for psi cannot trigger.

This is NOT fixable by constraining the Lindenbaum extension: adding F-formulas
from previous chain points to the seed creates the same inconsistency as Obstruction 1.

The deprecated `Algebraic/DovetailedChain.lean` confirms this obstruction exists
(6 unsolved sorries related to forward_F propagation).

### Obstruction 3: Constant History Backward Truth Lemma Fails for G

On constant histories, truth_at G(alpha) = truth_at alpha (reflexive semantics).
The backward direction (truth_at alpha -> G(alpha) in w) fails because:
- truth_at alpha on constant_history w gives alpha in w (by IH)
- But G(alpha) in w requires alpha in v for ALL v >= w, not just w

No alternative model construction (flattening, proof-theoretic reduction) was found
to circumvent this.

## Plan's Proof Sketch Error

The plan's report 06 (Section 3.2, step 4) claims: "by generalized_temporal_k get
G(neg psi_1) or ... or G(neg psi_k) in w". This step is **mathematically incorrect**.
From L_g derives neg(psi_1 and ... and psi_k), generalized_temporal_k gives
G(neg(psi_1 and ... and psi_k)) in w. But G does NOT distribute over disjunction:
G(A or B) does NOT imply G(A) or G(B). So the multi-target compactness argument fails.

## Alternative Approaches Investigated

1. **Flattening/temporal-free reduction**: Define flatten(G(a)) = flatten(a). Then
   valid(phi) -> valid(flatten(phi)) -> derive flatten(phi) by fragment_completeness.
   But unflatten fails: derive flatten(chi) -> chi requires alpha -> G(alpha), which
   is only valid for theorems (temporal_necessitation).

2. **Proof-theoretic approach**: Use IH on sub-formulas to avoid model construction.
   The structural induction only gives IH for immediate sub-formulas psi and chi,
   not for arbitrary smaller formulas like neg psi. And Case B (neg valid psi) gives
   no useful information from the IH.

3. **Different omega set**: Various omega constructions (constant histories, sparse
   histories, tagged histories) all fail because the backward direction of the
   truth lemma for G requires witnesses WITHIN the model's temporal domain.

## Recommendations

The correct approach likely requires ONE of:

1. **Kripke-to-TaskFrame embedding**: Prove that TaskFrame validity implies Kripke validity
   for USF formulas. Then use Kripke completeness (which works directly with G_iff_mcs).
   This avoids building a TaskFrame model entirely.

2. **Restricted Lindenbaum extension**: Develop a version of set_lindenbaum that takes
   "preservation constraints" (formulas whose negation must be excluded). This would
   allow building chains where F-formulas persist by construction.

3. **Omega-saturated chain**: Use a transfinite construction (ordinal-indexed chain)
   that resolves ALL F-obligations, not just countably many. This is the standard
   approach in model theory but requires significant infrastructure.

4. **Frame conditions bridge**: Use the existing FrameConditions/Completeness.lean
   infrastructure if it provides a completeness result that can be transferred.

## Files Modified

None. The original `CanonicalEmbedding.lean` was restored to its pre-implementation state.

## Verification

- `lake build` was not run (no code changes)
- The sorry at CanonicalEmbedding.lean:418 remains
