# Research Report: Task #857 - Zero-Sorry Path Analysis for Temporal Backward

**Task**: Add temporal_backward_G and temporal_backward_H properties to IndexedMCSFamily
**Date**: 2026-02-04
**Focus**: Finding the minimal path to eliminate ALL sorries without ANY axioms

## Summary

The two sorries at TruthLemma.lean lines 402 and 418 are in the **backward direction** (.mpr) of the temporal truth lemma. They require proving:
- `(all s >= t, phi in fam.mcs s) -> G phi in fam.mcs t` (line 402)
- `(all s <= t, phi in fam.mcs s) -> H phi in fam.mcs t` (line 418)

The existing partial implementation created `TemporalCoherentConstruction.lean` with infrastructure (`TemporalCoherentFamily`, `temporal_backward_G/H` theorems) that proves these directions **IF** the family has `forward_F` and `backward_P` properties. However, these properties are NOT part of the current IndexedMCSFamily structure.

**Key Finding**: The sorries CAN be eliminated by following the EvalCoherentBundle pattern from Task 856. This is a ZERO-AXIOM path.

## Findings

### What the Sorries Require

At line 402 (`all_future` backward):
```lean
-- Need to prove: (all s >= t, bmcs_truth_at B fam s phi) -> G phi in fam.mcs t
-- By IH: (all s >= t, phi in fam.mcs s)
-- Required: forward_F property to enable contraposition argument
```

At line 418 (`all_past` backward):
```lean
-- Need to prove: (all s <= t, bmcs_truth_at B fam s phi) -> H phi in fam.mcs t
-- By IH: (all s <= t, phi in fam.mcs s)
-- Required: backward_P property to enable contraposition argument
```

The proof strategy (already documented in `TemporalCoherentConstruction.lean` lines 211-245) is:
1. Assume G phi NOT in fam.mcs t
2. By MCS maximality: neg(G phi) in fam.mcs t
3. By temporal duality: F(neg phi) in fam.mcs t
4. By **forward_F** coherence: exists s > t with neg phi in fam.mcs s
5. But hypothesis says phi in fam.mcs s (since s >= t)
6. Contradiction: fam.mcs s contains both phi and neg(phi)

### Why Current Implementation Has Sorries

The IndexedMCSFamily structure does NOT have `forward_F` or `backward_P` properties. These are the **existential duals** of the existing `forward_G` and `backward_H`:

| Existing Property | What It Does | Missing Dual | What It Would Do |
|-------------------|--------------|--------------|------------------|
| `forward_G` | G phi at t, t < s -> phi at s | `forward_F` | F phi at t -> exists s > t, phi at s |
| `backward_H` | H phi at t, s < t -> phi at s | `backward_P` | P phi at t -> exists s < t, phi at s |

For a **constant family** (same MCS at all times), `forward_F` and `backward_P` CANNOT be satisfied unless the MCS is specially constructed (saturated for temporal existentials).

### The EvalCoherent Pattern (From Task 856)

Task 856 solved the analogous problem for modal logic (Box/Diamond) using the **EvalCoherentBundle** pattern. The key insight was:

1. **Don't require all families to be mutually coherent** - that's too strong
2. **Only require coherence with respect to the eval_family** - sufficient for completeness
3. **Build witnesses for eval_family's Diamond formulas** - enough for the truth lemma

The analogous pattern for temporal operators would be:

1. Define `TemporalEvalCoherent`: All families contain "GContent(eval_family)" at all times
2. Define `TemporalEvalSaturated`: Every F(phi) in eval_family has a witness time with phi
3. Convert to a structure with `forward_F_eval` and `backward_P_eval` for the eval_family

### Proposed Solution: TemporalEvalCoherentBundle

**Pattern**: Follow the `EvalCoherentBundle` approach from `CoherentConstruction.lean`.

**New Structure**:
```lean
structure TemporalEvalCoherentFamily (D : Type*) ... extends IndexedMCSFamily D where
  forward_F : forall t phi, F phi in mcs t -> exists s > t, phi in mcs s
  backward_P : forall t phi, P phi in mcs t -> exists s < t, phi in mcs s
```

**Construction**: For a constant family from MCS M:
- If F(phi) in M at time t, construct a **time-varying extension** where phi is added at some time s > t
- The extension maintains MCS properties via Lindenbaum

**Key Difference from Modal Case**: In the modal case, we add new **families** (worlds) as witnesses. In the temporal case, we need to vary the MCS **over time** within a single family.

### Alternative: Single-Time Evaluation

A simpler approach recognizes that the completeness proof evaluates formulas **only at time 0** at the eval_family. The temporal operators G and H quantify over ALL times, but:

- **G phi at 0**: All times s >= 0, phi holds at s
- **H phi at 0**: All times s <= 0, phi holds at s

For a constant family (same MCS at all times), the truth of G phi and H phi at time 0 reduces to whether G phi / H phi are in the single MCS.

**Insight**: If we're only proving truth at time 0, and the family is constant, then:
- `G phi in MCS <-> phi in MCS` (by T-axiom: G phi -> phi, and constancy)
- `H phi in MCS <-> phi in MCS` (by T-axiom: H phi -> phi, and constancy)

Wait - this is NOT correct for the backward direction. The T-axiom gives `G phi -> phi`, not `phi -> G phi`.

### Correct Analysis: Why Backward Direction is Hard

For a constant family with MCS M:
- **Forward**: G phi in M -> phi in M (T-axiom: G phi -> phi)
- **Backward**: phi in M -> ??? G phi in M (NOT provable without additional structure)

The backward direction requires that **if phi is in M, then G phi is in M**. This is NOT a theorem of temporal logic. It would require a special property of M.

**In modal logic**, Task 856 solved this for Box by:
1. Proving that eval_family's MCS contains all chi where Box chi appears (by mutual coherence)
2. Using saturation to provide witnesses for Diamond formulas
3. The contraposition argument then works

**For temporal logic**, we need:
1. Prove that eval_family's MCS contains all chi where G chi appears (?)
2. Use temporal saturation to provide witnesses for F formulas
3. The contraposition argument then works

### The Saturation Requirement

For the contraposition to work:
- If G phi NOT in M, then neg(G phi) = F(neg phi) in M
- Need: F(neg phi) in M -> exists time s > t with neg phi in M at s
- This is the **forward_F** property

For a constant family, "neg phi in M at s" is the same as "neg phi in M" (constant).
So: F(neg phi) in M -> neg phi in M (for constant family with forward_F)

But wait - this means the F formula is **satisfied immediately** at the current time!

**Key Realization**: For a **constant family**, if F(psi) is in M, and M is the same at all times, then we need psi to be in M (at some future time s, but that's the same M). So F(psi) in M should imply psi in M.

Actually, that's NOT necessarily true. F(psi) in M means "eventually psi" is in M. For a constant family where M is the same at all times, if we interpret it semantically, F(psi) holds iff psi holds at some future time. But if psi is NOT in M, then psi doesn't hold at any time, so F(psi) shouldn't hold.

**BUT**: We're dealing with MCS (syntactic), not semantic satisfaction. The MCS M could contain F(psi) without containing psi, as long as that's consistent. Whether it's consistent depends on the axioms.

### The Temporal T-Axiom Issue

The temporal T-axiom is: G phi -> phi (and H phi -> phi).

There is NO axiom: phi -> G phi (that would be unsound - just because phi holds now doesn't mean it always will).

Similarly, there is NO axiom: F phi -> phi (eventual truth doesn't imply current truth).

So for a constant family, even though semantically "eventually phi" should be equivalent to "phi" (since all times have the same valuation), syntactically the MCS M could contain F(phi) without containing phi.

### Resolution: Time-Varying Families

The only way to eliminate the sorries **without axioms** is to use **time-varying families** for temporal operators, analogous to how the modal case uses **multiple families** for Box/Diamond.

**Proposed Construction**:
1. Start with base MCS M at time 0
2. For each F(psi) in M: construct a witness time s > 0 with psi at that time
3. For each P(psi) in M: construct a witness time s < 0 with psi at that time
4. The resulting IndexedMCSFamily has:
   - mcs(0) = M (extended to include witnessed formulas from future/past)
   - mcs(s) for s > 0 contains witnessed formulas for F
   - mcs(s) for s < 0 contains witnessed formulas for P

**Technical Challenge**: The witness construction for temporal operators requires:
- At witness time s, the MCS must contain psi AND satisfy G/H coherence
- This creates interdependencies between different times

### Simplest Zero-Sorry Path

After analysis, the **simplest zero-sorry path** is:

**Option A: Use TemporalCoherentFamily for Completeness**

1. Define `TemporalCoherentFamily` as an IndexedMCSFamily with `forward_F` and `backward_P` (DONE in TemporalCoherentConstruction.lean)
2. Prove `temporal_backward_G` and `temporal_backward_H` for TemporalCoherentFamily (DONE)
3. Construct a TemporalCoherentFamily from consistent context via saturation
4. Update TruthLemma to use TemporalCoherentFamily instead of IndexedMCSFamily

**Gap**: Step 3 requires constructing a temporally saturated family. This is analogous to the modal saturation but for time instead of worlds.

**Option B: One-Directional Truth Lemma**

1. Change the truth lemma statement to only prove the forward direction
2. The completeness proof only uses the forward direction
3. Remove the backward direction from the iff

**Concern**: This changes the mathematical statement of the truth lemma, weakening it.

**Option C: Axiom-Based (NOT Zero-Sorry)**

Add an axiom asserting temporal saturation exists. This is what was partially done but violates the zero-axiom requirement.

### Recommended Path: Option A with Temporal Saturation

The EvalCoherentBundle pattern from Task 856 can be adapted for temporal operators:

1. **Define TemporalEvalCoherent predicate** (analogous to EvalCoherent)
2. **Define TemporalEvalSaturated predicate** (analogous to EvalSaturated)
3. **Prove temporal saturation construction** using enumeration + witness construction
4. **Convert to TemporalCoherentFamily** for use in truth lemma

**Estimated Effort**: 2-3 phases (8-12 hours)
- Phase 1: Define temporal saturation structures
- Phase 2: Prove witness construction preserves coherence
- Phase 3: Integrate with TruthLemma

## Recommendations

1. **Primary Recommendation**: Follow Option A - adapt the EvalCoherentBundle pattern for temporal operators. This provides a principled, zero-axiom solution.

2. **Alternative**: If zero-sorry is not strictly required, the current state (sorries in backward direction that don't affect completeness) could be documented as technical debt with the understanding that:
   - The sorries do NOT block the completeness theorem
   - The sorries are in a direction not used by the proof
   - Remediation path is known (temporal saturation construction)

3. **Quick Win**: If only "publication quality" for the completeness theorem is needed, verify that completeness does not transitively depend on the backward direction of the temporal truth lemma. If confirmed, document this and consider the main theorem sorry-free.

## Technical Details

### Files to Modify

1. **TemporalCoherentConstruction.lean**: Add temporal saturation structures
2. **TruthLemma.lean**: Update to use TemporalCoherentFamily or add temporal saturation hypothesis
3. **Construction.lean**: Add temporal saturation construction

### Key Lemmas Needed

1. `temporal_witness_consistent`: If F(psi) in M, then {psi} union "GContent(M)" is consistent
2. `temporal_witness_construction`: Construct MCS at witness time containing psi
3. `temporal_saturation_exists`: For any MCS M, construct temporally saturated family

### Verification Steps

1. Confirm that `bmcs_truth_lemma.mp` does not use the backward direction
2. Confirm that `completeness_theorem` only uses `.mp` of the truth lemma
3. Check that all G/H cases in completeness use forward direction only

## Next Steps

1. Verify that completeness theorem truly doesn't need the backward direction (quick check)
2. If zero-sorry is required: implement temporal saturation following EvalCoherentBundle pattern
3. If zero-sorry not strictly required: document the current state with clear remediation path

## References

- TemporalCoherentConstruction.lean - existing temporal duality infrastructure
- CoherentConstruction.lean - EvalCoherentBundle pattern for modal case
- TruthLemma.lean lines 380-420 - the sorry locations
- Implementation summary from partial implementation (20260204)
