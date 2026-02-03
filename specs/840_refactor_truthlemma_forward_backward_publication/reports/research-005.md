# Research Report: Task #840

**Task**: Refactor TruthLemma Forward/Backward for Publication
**Date**: 2026-02-03
**Focus**: DEEP INVESTIGATION - Can Temporal Backward Sorries Be Completed?

## Executive Summary

This research conducts a thorough investigation into whether the temporal backward direction sorries in `TruthLemma.lean` (lines 383, 395) can be completed, inspired by the successful modal saturation approach in task 842. After detailed analysis of both the modal and temporal cases, the fundamental structural differences, and multiple potential strategies, the conclusion is:

**The temporal backward direction CANNOT be completed using techniques analogous to modal saturation.** The fundamental obstacle is structural: modal saturation adds NEW witness families, while temporal backward requires truth at ALL times within the SAME family - times that are already fixed by the MCS construction.

## Mathematical Problem Setup

### The Goal

We need to prove the backward direction of the truth lemma for temporal operators:

**For G (all_future):**
```
(forall s >= t, bmcs_truth_at B fam s phi) -> Formula.all_future phi in fam.mcs t
```

**For H (all_past):**
```
(forall s <= t, bmcs_truth_at B fam s phi) -> Formula.all_past phi in fam.mcs t
```

### The Available Hypotheses

At the sorry location (line 383), we have:
- `B : BMCS D` - the bundle of maximal consistent sets
- `fam : IndexedMCSFamily D` - the current family
- `hfam : fam in B.families` - membership proof
- `t : D` - the current time
- `phi : Formula` - the formula
- `ih : forall fam' in B.families, forall t, (phi in fam'.mcs t <-> bmcs_truth_at B fam' t phi)` - induction hypothesis
- `_h_all : forall s >= t, bmcs_truth_at B fam s phi` - the semantic truth hypothesis

We need to prove: `Formula.all_future phi in fam.mcs t`

### The Gap

The gap is fundamental: **we cannot derive syntactic MCS membership from semantic truth**.

Using the IH, from `_h_all` we can derive:
```
forall s >= t, phi in fam.mcs s
```

But we need `G phi in fam.mcs t`, which requires:
- Either directly proving `G phi in fam.mcs t` from individual `phi in fam.mcs s` facts
- Or showing a contradiction if `G phi not-in fam.mcs t`

Neither is achievable with finitary proof systems.

## Analysis: Why Modal Saturation Worked

### Modal Solution Structure (Task 842)

The modal backward direction has the form:
```
(forall fam' in B.families, bmcs_truth_at B fam' t phi) -> Box phi in fam.mcs t
```

The proof via saturation works by **contraposition**:

1. Assume `Box phi not-in fam.mcs t`
2. By MCS maximality: `neg (Box phi) = Diamond (neg phi) in fam.mcs t`
3. By modal saturation: exists `fam'` in families where `neg phi in fam'.mcs t`
4. By IH: `bmcs_truth_at B fam' t (neg phi)`, so NOT `bmcs_truth_at B fam' t phi`
5. This contradicts the hypothesis (phi is true at ALL families)

**Why This Works:**
- The witness `fam'` is a DIFFERENT family from `fam`
- Modal saturation can ADD families to the bundle
- The saturation construction via Zorn's lemma adds exactly the witnesses needed
- Each unsatisfied `Diamond psi` gets a NEW witness family

### Key Structural Property

Modal backward involves quantification **across families** (different entities in the bundle).
The saturation process can **extend the bundle** by adding new families.

## Analysis: Why Temporal Cannot Follow Modal Pattern

### Temporal Backward Structure

The temporal backward direction has the form:
```
(forall s >= t, bmcs_truth_at B fam s phi) -> G phi in fam.mcs t
```

Attempting contraposition:

1. Assume `G phi not-in fam.mcs t`
2. By MCS maximality: `neg (G phi) = F (neg phi) in fam.mcs t`
3. This means: "eventually, neg phi will be true"
4. We need to extract a SPECIFIC time witness s where `neg phi` is true

**The Witness Extraction Problem:**

`F (neg phi) in fam.mcs t` tells us semantically that SOME future time has `neg phi`.
But we cannot extract WHICH time from syntactic MCS membership.

The MCS was constructed via Lindenbaum extension WITHOUT knowing:
- Which times would later be semantically relevant
- What formulas would hold at those times
- Any connection between syntactic construction and semantic truth at specific times

### Key Structural Difference

| Aspect | Modal | Temporal |
|--------|-------|----------|
| Quantification | Over FAMILIES (different entities) | Over TIMES (within same family) |
| Witness type | A different family `fam'` | A specific time `s` |
| Can add witnesses? | YES - add families via Zorn | NO - times are FIXED |
| Saturation approach | Extend bundle with new families | Cannot extend time domain |

**The fundamental issue:** Modal saturation works because we can ADD NEW FAMILIES to provide witnesses. For temporal, the times are not separate entities we can add - they are indices into a FIXED family structure. The `IndexedMCSFamily` assigns an MCS to EACH time, and this assignment is fixed during the Lindenbaum construction.

## Strategy Evaluation

### Strategy A: Temporal Saturation via Zorn

**Concept:** Construct "temporally-saturated" families analogously to modal saturation.

**Analysis:** This would require ensuring that for every `F (neg phi)` in the MCS at time t, there exists some time s >= t where `neg phi` is in the MCS.

**Why It Fails:**
- The IndexedMCSFamily construction assigns `mcs : D -> Set Formula`
- This is a FUNCTION - each time has exactly one MCS
- We cannot "add" new times or modify existing MCS assignments
- The construction must work for ALL formulas simultaneously

Modal saturation adds new families as needed. Temporal saturation would need to "add new times" which is incoherent - time is a fixed domain `D`.

**Verdict: NOT VIABLE**

### Strategy B: Finite Subformula Closure

**Concept:** Temporal depth is bounded, so only finitely many relevant times exist.

**Analysis:** Every formula has finite `temporalDepth`. For formula phi, only times within distance `temporalDepth phi` from t are semantically relevant.

**Why It Fails:**
- Even with finite depth, we still have the witness extraction problem
- Knowing phi is true at finitely many times t, t+1, ..., t+k doesn't help derive `G phi in MCS`
- The omega-rule applies even to finite instances: from P(1), P(2), ..., P(k), derive `forall n <= k, P(n)`
- This is a "finite omega-rule" which is still NOT a finitary inference rule

**Verdict: NOT VIABLE**

### Strategy C: Contrapositive Approach

**Concept:** Prove `neg (G phi) in MCS -> exists s >= t, neg (bmcs_truth_at B fam s phi)`

**Analysis:** This restates the problem. `neg (G phi) = F (neg phi)` in MCS tells us "eventually neg phi" syntactically, but we need to extract a SPECIFIC witness time.

**Why It Fails:**
- The MCS knows "some time exists" but not WHICH time
- Witness extraction from syntactic membership is exactly the omega-rule problem
- Prior research (task 839) confirmed contrapositive doesn't resolve the gap

**Verdict: NOT VIABLE**

### Strategy D: Proof by Cases on Formula Structure

**Concept:** Induct on temporal depth of phi.

**Analysis:** For depth 0, phi has no temporal operators. For depth n+1, phi = G psi where psi has depth n.

**Why It Fails:**
- The base case (depth 0) still has the same gap: prove `phi in MCS` from `phi true semantically`
- This is the representation lemma, which already uses the forward direction
- Induction doesn't help because each step has the same fundamental gap

**Verdict: NOT VIABLE**

### Strategy E: Exploit the Frame Structure

**Concept:** BMCS has specific frame structure. Maybe frame conditions help.

**Analysis:** BMCS provides:
- `modal_forward`: Box phi implies phi at all families
- `modal_backward`: phi at all families implies Box phi
- But no analogous temporal properties are available (and can't be added)

**Why It Fails:**
- Temporal operators quantify over TIMES, not families
- The frame structure doesn't constrain time relationships
- The IndexedMCSFamily coherence conditions (forward_G, backward_H, etc.) are about PROPAGATION within a family, not about deriving G from instances

**Verdict: NOT VIABLE**

### Strategy F: Index Domain Properties

**Concept:** D has `LinearOrder` structure. Can we exploit ordering properties?

**Analysis:** D has `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`. This gives us:
- Totality of ordering
- Transitivity
- Compatibility with addition

**Why It Fails:**
- These are SEMANTIC properties of the time domain
- The gap is about SYNTACTIC derivability in the proof system
- No ordering property of D bridges syntax to semantics

**Verdict: NOT VIABLE**

## The Fundamental Obstruction

### Mathematical Statement

The backward direction requires:
```
forall s >= t, phi in fam.mcs s  ->  G phi in fam.mcs t
```

This is an instance of the **infinitary inference rule** (omega-rule):
```
From: phi holds at t, phi holds at t+1, phi holds at t+2, ...
Derive: G phi holds at t
```

### Why Finitary Proof Systems Cannot Capture This

1. **Finitary proofs have finite premises:** Any derivation can only use finitely many assumptions
2. **Omega-rule has infinitely many premises:** We need phi at ALL times >= t
3. **No finitary encoding:** There's no finite way to encode "phi at all times"
4. **Lindenbaum construction is blind:** MCS is built formula-by-formula without knowing which times will semantically satisfy phi

### Comparison to Omega-Consistency in Arithmetic

This is analogous to Godel's omega-consistency:
- In Peano Arithmetic, we cannot derive `forall n, P(n)` from `P(0), P(1), P(2), ...`
- Adding the omega-rule makes the system omega-complete but non-finitary
- The omega-rule is an INFINITARY rule outside standard proof theory

## Conclusion: Completion is NOT Feasible

The temporal backward direction sorries CANNOT be completed using any technique analogous to modal saturation or other finitary methods because:

1. **Structural mismatch:** Modal saturation adds NEW families; temporal cannot add new times
2. **Witness extraction:** Cannot extract specific time witness from syntactic MCS membership
3. **Omega-rule limitation:** Deriving universal from instances is infinitary
4. **Direction mismatch:** Semantic truth -> syntactic membership is the wrong direction

### Mathematical Classification

The temporal backward direction represents a **fundamental limitation of finitary proof theory**, not a proof engineering gap. This is consistent with:
- The omega-rule in arithmetic
- Incompleteness phenomena in general
- Standard treatments in temporal logic literature

### Implications

1. **Sorries are NOT fixable** with current proof system
2. **Current architecture is CORRECT:** Forward-only truth lemma suffices for completeness
3. **Archival is the right approach:** Document limitation, remove backward direction
4. **No innovation possible:** This is a mathematical impossibility, not a technique gap

## Recommendations

### Recommended Action: Archive Backward Direction

1. Restructure TruthLemma to forward-direction-only
2. Document omega-rule limitation in module docstring
3. Move backward conjecture to Boneyard with documentation
4. Verify completeness theorems remain transitively sorry-free

### Why This is Mathematically Honest

The completeness theorem states:
> If Gamma is consistent, then there exists a model satisfying Gamma.

This is an EXISTENTIAL statement. We construct ONE satisfying model (the BMCS). We do NOT need to characterize all models. The forward direction suffices for this construction.

Claiming a biconditional with unfillable sorries would be dishonest. Claiming only what we can prove (forward direction) is correct.

## References

### Prior Research (This Project)
- Task 828: FMP approach - confirmed omega-rule limitation
- Task 839: Contrapositive approach - confirmed witness extraction problem
- Task 842: Modal saturation via Zorn - demonstrated why modal works differently

### Codebase Files
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Sorries at lines 383, 395
- `Theories/Bimodal/Metalogic/Bundle/ModalSaturation.lean` - Modal saturation that DOES work
- `Theories/Bimodal/Metalogic/Bundle/SaturatedConstruction.lean` - Zorn's lemma for modal
- `Theories/Bimodal/Metalogic/Bundle/IndexedMCSFamily.lean` - Temporal coherence structure

### Academic References
- Sundholm: "A survey of the omega-rule" (omega-rule limitation)
- Godel: Omega-consistency and incompleteness
- Standard textbooks on temporal logic completeness

## Summary

**Can the temporal backward sorries be completed?**

NO. The fundamental obstacle is structural:

| Aspect | Modal (WORKS) | Temporal (IMPOSSIBLE) |
|--------|---------------|----------------------|
| Quantification | Over families | Over times |
| Witness type | Add new family | Extract time from MCS |
| Saturation | Add families via Zorn | Times are fixed |
| Inference | Finitary (contraposition) | Infinitary (omega-rule) |

The current forward-direction-only architecture is the mathematically correct design. Proceeding with archival restructuring is recommended.
