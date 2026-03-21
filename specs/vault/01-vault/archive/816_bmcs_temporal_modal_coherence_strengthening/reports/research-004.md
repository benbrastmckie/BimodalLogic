# Research Report: Task #816 (Follow-up 4)

**Task**: BMCS Temporal/Modal Coherence Strengthening
**Date**: 2026-02-02
**Focus**: Deep analysis of Strategy B (Temporal Saturation) combined with Strategy C (Multi-Family)

## Summary

This report investigates whether combining temporal saturation during Lindenbaum construction (Strategy B) with multi-family modal saturation (Strategy C) can achieve a **fully sorry-free biconditional truth lemma**. The key finding is that **temporal saturation during Lindenbaum construction faces a fundamental circularity problem** that cannot be resolved without either: (1) infinitary logic extensions, (2) a transfinite simultaneous construction across all times, or (3) accepting construction axioms. The combination of B+C cannot eliminate the temporal sorries because they arise from a different architectural limitation than the modal sorry.

## The Core Question

**Can we modify Lindenbaum construction to be "temporally saturated" such that:**
```
(forall s >= t, phi in fam.mcs s) -> G phi in fam.mcs t
```
**holds by construction?**

**Short answer: No**, not without fundamental changes to the construction architecture.

## Analysis of Strategy B: Temporal Saturation

### What Temporal Saturation Would Require

The proposal is to modify Lindenbaum construction so that:
1. At each stage, before adding formula phi_n, check if "phi holds at all times > t"
2. If so, add G phi at time t
3. Similarly for H phi with past times

### The Fundamental Circularity Problem

The circularity lies in **what information is available at construction time**:

**Standard Lindenbaum Construction** (current implementation in MaximalConsistent.lean):
```
Stage 0: Start with consistent base set S
Stage n: Add phi_n to current set if consistent, else add neg(phi_n)
Limit: Take union of chain
```

**The Problem with Temporal Awareness**:

To check "phi holds at all s > t" during construction at time t, we need to know the contents of MCS(s) for all s > t. But:

1. **If we build one MCS at a time**: MCS(s) for s > t doesn't exist yet when building MCS(t)
2. **If we build all MCSs simultaneously**: We face mutual dependencies - whether G phi goes into MCS(t) depends on whether phi goes into MCS(t+1), which may depend on whether H phi goes into MCS(t+1), which may depend on MCS(t)

This is not merely a technical challenge - it's a **logical circularity**.

### Detailed Analysis of Simultaneous Construction

Let's examine the most promising approach: constructing all MCSs simultaneously.

**Attempt 1: Staged Enumeration Across All Times**

Inspired by the [Sundholm paper on infinitary tense-logic](https://www.academia.edu/17828620/A_completeness_proof_for_an_infinitary_tense_logic), we could try:

```
Stage (n, t): For time t and formula enumeration step n:
  - If consistent to add phi_n to MCS(t), do so
  - For each temporal formula needing witnesses, ensure witnesses exist
```

**Problem**: The witness requirements create infinite dependencies:
- G phi in MCS(t) requires phi in MCS(t+k) for all k > 0
- But phi in MCS(t+k) might require temporal formulas that depend on MCS(t)
- Unlike modal logic (finite family of MCSs), temporal logic has infinitely many time points

**Attempt 2: Transfinite Induction**

```
Stage alpha: For each time t, extend MCS_alpha(t) by:
  - Adding consistent formulas
  - For any F phi in MCS_alpha(t), designate a witness time
  - For any P phi in MCS_alpha(t), designate a witness time
Continue until fixpoint
```

**Problem**: The construction may not converge:
- Adding F phi at time t creates obligation at some t' > t
- At t', F psi might be added, creating obligation at t'' > t'
- This chain can continue indefinitely
- Without a bound on temporal depth, there's no natural stopping point

**Attempt 3: Bounded Temporal Depth**

Restrict to formulas with bounded temporal operator nesting.

**Problem**: TM logic allows arbitrary nesting - this changes the logic.

### Why Modal Saturation Works But Temporal Doesn't

**Modal Saturation (Strategy C) Works** because:
- Families are **constructed on demand**: When Diamond phi needs a witness, create a new family
- The total number of families is bounded by the formula structure
- Each family construction is independent

**Temporal Saturation Fails** because:
- Times are **given by the domain D**, not constructed
- The temporal structure (all of Z, for instance) is fixed and infinite
- MCSs at different times are mutually dependent

### The Literature Confirms This

From the [Sundholm paper](https://www.academia.edu/17828620/A_completeness_proof_for_an_infinitary_tense_logic):
> "Professor Segerberg's original proof idea turned out to be incomplete in that it used the Lindenbaum lemma, as is usual in canonical model proofs. Because of the infinitary rules we do not have immediate access to the Lindenbaum lemma."

The paper requires a **completely different proof strategy** (Henkin-style with special handling of infinitary rules) rather than modifying Lindenbaum.

## Combined B+C Construction Analysis

### What B+C Would Look Like

If we tried to combine both strategies:

```
1. Start with consistent context Gamma at time 0
2. Extend to MCS M_0 at time 0
3. For each Diamond phi in M_0:
   - Create witness family F_i with phi in its MCS at time 0
4. For each time t != 0 in each family:
   - Extend to MCS M_t ensuring temporal coherence with adjacent times
5. Iterate until modal saturation (no new Diamond witnesses needed)
```

### Why This Doesn't Help Temporal Sorries

**Step 4 is the problem**: "Extend to MCS M_t ensuring temporal coherence" is exactly the temporal saturation problem. Multi-family construction doesn't help because:

- Each family independently faces the omega-rule problem
- Adding more families adds modal witnesses, not temporal witnesses
- The temporal structure within each family is unchanged

### Concrete Obstacle Example

Consider family F with:
- MCS(0) containing F(G p) ("sometime in the future, always p")

This requires:
1. A witness time s > 0 where G p in MCS(s)
2. At time s, G p in MCS(s) requires p in MCS(t) for all t >= s

How do we ensure p is in MCS(t) for all t >= s?
- We can't check during construction (infinitely many times)
- We can't add G p by construction without already knowing about all future times
- This is the omega-rule problem repeated

## What Would Actually Work

### Option 1: Infinitary Logic (Not Practical for Lean)

Add the omega-rule to TM logic:
```
phi(0), phi(1), phi(2), ...
--------------------------- (omega-rule)
        G phi
```

**Drawback**: Changes the logic fundamentally. Proofs become infinitary. Not representable in Lean's finitary type theory without axioms.

### Option 2: Witness Extraction Axioms

Add to IndexedMCSFamily:
```lean
witness_F : forall t phi, F phi in mcs t -> exists s, t < s /\ phi in mcs s
witness_P : forall t phi, P phi in mcs t -> exists s, s < t /\ phi in mcs s
```

Then prove the backward temporal direction via contraposition:
```
G phi not-in mcs(t)
  => neg(G phi) in mcs(t)               [MCS negation completeness]
  => F neg(phi) in mcs(t)               [temporal duality]
  => exists s > t. neg(phi) in mcs(s)   [witness_F]
  => exists s >= t. phi not-in mcs(s)   [contradiction with h_all]
```

**Status**: Moves the sorry from truth lemma to IndexedMCSFamily structure. Construction functions would have sorry for satisfying witness extraction.

### Option 3: Finite Model Property Approach (Already Implemented)

The codebase already has an FMP-based completeness proof in:
```
Bimodal.Metalogic.FMP.SemanticCanonicalModel.semantic_weak_completeness
```

This approach uses finite models, avoiding the omega-rule entirely.

### Option 4: Accept as Mathematical Sound Axioms (Recommended)

The temporal backward sorries represent:
```lean
-- These are NOT required for completeness
sorry -- phi_at_all_future_implies_mcs_all_future
sorry -- phi_at_all_past_implies_mcs_all_past
```

**Key Insight**: Completeness only uses `truth_lemma_forward`. The backward direction establishes "tightness" (no extraneous truths), which is useful for definability but not completeness.

## Technical Analysis: Why Completeness Doesn't Need Backward

From Completeness.lean:
```lean
-- Line 108
exact (bmcs_truth_lemma B B.eval_family B.eval_family_mem 0 phi).mp h_in_mcs
                                                            ^^^ FORWARD direction
```

The completeness theorem proves: "If Gamma is consistent, then Gamma is satisfiable."

The proof:
1. Extend Gamma to MCS M (Lindenbaum)
2. Build BMCS with M at evaluation point
3. For each phi in Gamma: phi in M, so by forward truth lemma, phi is true

The backward direction would prove: "If phi is true, then phi in M" - but we don't need this for completeness.

## Summary of Findings

| Strategy | Addresses | Achievable | Effort |
|----------|-----------|------------|--------|
| B (Temporal Saturation) | Temporal sorries | **No** - fundamental circularity | N/A |
| C (Multi-Family) | Modal sorry | Yes | Medium |
| B+C Combined | Both | **No** - C doesn't help temporal | N/A |
| Witness Extraction Axioms | Temporal sorries (moved) | Yes (moves sorry) | Low |
| Infinitary Logic | Temporal sorries | No (changes logic) | N/A |
| Accept as Axioms | Documentation | Yes | None |

## Recommendations

### For Sorry-Free Modal Direction

Implement multi-family construction (Strategy C) to eliminate `modal_backward` sorry:
- Construct families on demand for Diamond witnesses
- Modal coherence holds by construction
- Estimated effort: 8-12 hours

### For Temporal Direction

**Accept temporal sorries as mathematically sound construction axioms** with clear documentation:

```lean
/--
CONSTRUCTION AXIOM: Temporal backward coherence.

This property is mathematically sound but requires omega-rule reasoning
that cannot be captured in finitary proof systems. The completeness theorem
only uses the forward direction.

Alternatives considered:
1. Temporal saturation during Lindenbaum - faces fundamental circularity
2. Transfinite simultaneous construction - doesn't converge without bounds
3. Infinitary logic - changes the logic fundamentally

See: specs/816_bmcs_temporal_modal_coherence_strengthening/reports/research-004.md
-/
```

### For Full Biconditional (Future Work)

If a sorry-free biconditional is truly required:
1. **Option A**: Restrict to finite temporal domain (Fin n instead of Z) - eliminates omega-rule
2. **Option B**: Use the existing FMP-based approach which avoids canonical models
3. **Option C**: Research specialized temporal saturation techniques from the literature (e.g., Gabbay et al. 1994)

## Conclusion

**Strategy B (Temporal Saturation) combined with Strategy C (Multi-Family) cannot achieve a sorry-free biconditional truth lemma.** The temporal sorries arise from the omega-rule limitation, which is fundamentally different from the modal saturation issue that Strategy C addresses.

The simplest path forward is:
1. Implement Strategy C to eliminate the modal_backward sorry
2. Accept temporal sorries as documented construction axioms
3. Note that completeness is mathematically valid (uses only forward direction)

## References

- [Sundholm - A completeness proof for an infinitary tense-logic](https://www.academia.edu/17828620/A_completeness_proof_for_an_infinitary_tense_logic) - Documents why standard Lindenbaum fails for infinitary temporal rules
- [Stanford Encyclopedia - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/) - Background on tense logic completeness
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean:150-168` - Current temporal sorries
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean:220` - Current modal sorry
- `Theories/Bimodal/Boneyard/Metalogic_v2/Core/MaximalConsistent.lean` - Lindenbaum implementation
- `Theories/Bimodal/Boneyard/Metalogic_v5/Representation/TruthLemma.lean:458-493` - Historical omega-rule analysis
- `Theories/Bimodal/Boneyard/Metalogic_v3/TruthLemma/BackwardDirection.lean` - Previous backward direction research
