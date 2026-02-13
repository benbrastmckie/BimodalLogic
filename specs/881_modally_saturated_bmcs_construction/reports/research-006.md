# Research Report: Task #881

**Task**: Construct modally saturated BMCS to eliminate `fully_saturated_bmcs_exists` axiom
**Date**: 2026-02-13
**Focus**: Analyze blocking issue and evaluate resolution paths toward sorry-free and axiom-free result

## Summary

The blocking issue is the fundamental incompatibility between modal saturation (Zorn's lemma, constant families) and temporal coherence (F/P witness placement). Modal saturation creates constant witness families, but constant families require temporally saturated MCS (where F psi -> psi holds internally). Creating temporally saturated MCS via Henkin-style construction has a proven counterexample. After analyzing three resolution paths, **Path 3 (Truth Lemma Restructuring)** emerges as the most promising because it avoids the fundamental mathematical problem rather than fighting it.

## Finding 1: Precise Characterization of the Blocking Issue

### What Modal Saturation Requires

`exists_fullySaturated_extension` (SaturatedConstruction.lean:873-1128, now sorry-free) provides:
- For every Diamond psi in any family, a witness family containing psi exists
- Witness families are constant (`constantWitnessFamily`)
- All families satisfy `box_coherence_pred` (S5 modal axioms propagate)

### What Temporal Coherence Requires

`BMCS.temporally_coherent` (TemporalCoherentConstruction.lean:298-301) requires:
- `forward_F`: F phi at time t implies exists s > t with phi at time s
- `backward_P`: P phi at time t implies exists s < t with phi at time s

### Why They Conflict

For **constant families** (same MCS at all times):
- `forward_F`: F phi in MCS -> exists s > t, phi in MCS at s = phi in MCS (same MCS)
- This means: **F phi -> phi must hold within the single MCS**

This is the property `TemporalForwardSaturated` (line 317):
```lean
def TemporalForwardSaturated (M : Set Formula) : Prop :=
  ∀ psi : Formula, Formula.some_future psi ∈ M → psi ∈ M
```

**The problem**: When modal saturation adds a witness family for Diamond psi, that witness MCS is constructed via Lindenbaum extension of `{psi} ∪ BoxContent(existing families)`. The Lindenbaum process may add F-formulas (from maximality), and those F-formulas need their witnesses in the same MCS.

**Henkin counterexample** (research-004.md): Consider building a temporally saturated MCS via Henkin construction starting from `{F(p), neg p}`:
- This set is consistent (F(p) just says p holds at SOME future time)
- But Henkin would try to add p as a witness for F(p)
- This conflicts with neg p already being in the base

The base `{F(p), neg p}` is consistent, but no temporally saturated MCS can extend it (any extension containing F(p) needs p, which conflicts with neg p).

## Finding 2: DovetailingChain Analysis (4 Sorries)

DovetailingChain.lean (lines 588-665) has exactly 4 sorries:

| Sorry | Location | Nature | Root Cause |
|-------|----------|--------|------------|
| `forward_G` cross-sign | Line 606 | t < 0 | Forward chain doesn't propagate G to backward chain |
| `backward_H` cross-sign | Line 617 | t >= 0 | Backward chain doesn't propagate H to forward chain |
| `forward_F` | Line 633 | Witness placement | No F-witness enumeration in seed construction |
| `backward_P` | Line 640 | Witness placement | No P-witness enumeration in seed construction |

### Cross-Sign Sorries (2)

The construction builds two chains emanating from time 0:
- Forward chain: M_0, M_1, M_2, ... (GContent propagation)
- Backward chain: M_0, M_{-1}, M_{-2}, ... (HContent propagation)

G phi in M_{-2} should imply phi in M_5, but:
- M_{-2} is built from backward chain
- M_5 is built from forward chain
- They share M_0, but G phi at M_{-2} doesn't affect M_0's GContent

**Fix approach**: Include GContent from ALL previously constructed MCS in each seed, not just the immediate predecessor chain. The dovetailing order (0, 1, -1, 2, -2, ...) ensures earlier times are constructed first.

### F/P Witness Sorries (2)

The construction lacks witness enumeration for F/P formulas. When F psi appears in M_t (added by Lindenbaum), we need some s > t with psi in M_s.

**Fix approach**: Dovetailing enumeration of (time, formula) pairs. At step n, check if F(psi_k) is in M_{t_j} for previously constructed times. If so, include psi_k in the current seed.

### Assessment: Fixable but Non-Trivial

The cross-sign sorries are fixable with careful bookkeeping. The F/P witness sorries require implementing the dovetailing enumeration, which is conceptually straightforward but implementation-heavy.

**However**: Fixing DovetailingChain only gives us a temporally coherent eval_family. The witness families added by modal saturation would still be constant and face the Henkin problem.

## Finding 3: InterleaveConstruction Evaluation

InterleaveConstruction (proposed in implementation-002.md) aims to unify temporal and modal construction:

1. Enumerate all obligations: (t, G phi), (t, H phi), (t, F phi), (t, P phi) pairs
2. At each step, extend partial assignment to satisfy next obligation
3. Take limit and apply Lindenbaum to each time point

### Advantages
- Unified construction avoids separate temporal/modal phases
- Construction trace preserved for F/P witness verification

### Problems
- **Still faces Henkin problem**: When Lindenbaum extends at a time point, it may add F-formulas that weren't enumerated
- **Doesn't help witness families**: Modal saturation's witness families are still constant, still need temporal saturation

### Assessment: Does Not Solve Fundamental Problem

InterleaveConstruction addresses DovetailingChain's sorries but doesn't solve the core conflict. The witness families from modal saturation remain problematic.

## Finding 4: Truth Lemma Restructuring (Path 3)

The key insight comes from analyzing `bmcs_truth_lemma` (TruthLemma.lean:291-429):

```lean
theorem bmcs_truth_lemma (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : IndexedMCSFamily D) (hfam : fam ∈ B.families)
    (t : D) (phi : Formula) :
    phi ∈ fam.mcs t <-> bmcs_truth_at B fam t phi
```

The truth lemma is proved by structural induction on formulas. The temporal cases (G, H at lines 378-429) use:
1. `forward_F` and `backward_P` from `h_tc fam hfam` (the family's temporal coherence)
2. `temporal_backward_G` and `temporal_backward_H` which require a `TemporalCoherentFamily`

### Critical Observation

The truth lemma recurses on `fam` through the box case (lines 353-377). When evaluating Box phi:
- Forward: Box phi in fam.mcs t -> for all fam', phi in fam'.mcs t (modal_forward)
- Backward: for all fam', phi in fam'.mcs t -> Box phi in fam.mcs t (modal_backward)

The IH is applied to ALL families in the BMCS, not just eval_family. This is why the current design requires temporal coherence for all families.

### Restructuring Approach

**Question**: Can we restructure the truth lemma to only require temporal coherence for eval_family?

For the completeness theorem, we only need:
```lean
phi in eval_family.mcs 0 <-> bmcs_truth_at B eval_family 0 phi
```

The box case recurses to other families, but **for what formulas?** The recursion depth is bounded by formula structure. If phi = Box psi, we recurse on psi at all families.

**Key insight**: The temporal cases only arise for formulas of the form G chi or H chi. The recursion through Box doesn't change the formula structure - it just changes which family we evaluate at.

So the question becomes: **Do we ever need temporal coherence at witness families?**

### Analysis of Recursion Path

Starting from phi at eval_family:
1. If phi = Box psi: recurse on psi at ALL families (including witnesses)
2. If psi at witness family has form G chi: need forward_F/backward_P at witness family

This DOES require temporal coherence at witness families if the original formula contains Box (G chi) or Box (H chi) patterns.

**However**: If we can prove that witness families for Diamond formulas don't affect temporal formula evaluation, we can weaken the requirement.

### Alternative: Eval-Only Temporal Semantics

Redefine bmcs_truth_at to use eval_family for temporal operators:
```lean
def bmcs_truth_at (B : BMCS D) (fam : IndexedMCSFamily D) (t : D) : Formula -> Prop
| .all_future phi => ∀ s, t ≤ s → bmcs_truth_at B B.eval_family s phi  -- Always use eval_family
```

This would break the clean structural induction but might work if we prove:
- Box phi truth at any family implies Box phi truth at eval_family (by modal coherence)
- Temporal formulas should be evaluated at eval_family regardless of current family

### Assessment: Most Promising but Requires Careful Design

This approach requires:
1. Mathematical proof that the semantics remain correct
2. Careful Lean implementation of the modified truth lemma
3. Verification that completeness still holds

## Finding 5: Other Approaches Considered

### Approach A: Full Canonical Model
Build the full canonical model with ALL MCS as worlds. This is mathematically sound but:
- Requires uncountable family collection
- Lean implementation very complex
- Overkill for completeness (we just need one satisfying model)

### Approach B: Formula-Specific Saturation
Only saturate for formulas in subformula closure of target formula. This is partially implemented (`is_saturated_for_closure` at SaturatedConstruction.lean:70) but:
- Doesn't help with temporal coherence
- Witness families still face same problem

### Approach C: Accept Sorry as Structural
The sorry in `fully_saturated_bmcs_exists_int` (line 842) could be accepted as "construction assumption" per proof-debt-policy.md. This is **not** a solution but a fallback if resolution paths fail.

## Recommendation

**Primary Path: Truth Lemma Restructuring**

The fundamental mathematical problem is that constant families require temporal saturation, which Henkin construction cannot provide. Rather than fighting this:

1. **Modify temporal semantics** to evaluate G/H formulas at eval_family regardless of current family
2. **Prove this preserves completeness** by showing modal coherence propagates truth appropriately
3. **Simplify BMCS structure** to only require temporal coherence for eval_family

This approach:
- Avoids the Henkin counterexample entirely (witness families don't need temporal coherence)
- Leverages existing infrastructure (modal saturation is sorry-free, DovetailingChain gives temporal eval_family)
- Is mathematically cleaner than interleaving constructions

**Fallback Path: Fix DovetailingChain + Accept Limited Scope**

If truth lemma restructuring proves infeasible:
1. Fix DovetailingChain's 4 sorries (cross-sign propagation + F/P enumeration)
2. Accept that completeness proof is limited to formulas without Box(G/H) nesting
3. Document this limitation clearly

This is less satisfying but may be necessary if the semantics cannot be restructured.

## Next Steps

1. **Investigate truth lemma restructuring feasibility**:
   - Trace all paths through Box case that lead to temporal formulas
   - Determine if eval_family evaluation is semantically correct
   - Sketch modified `bmcs_truth_lemma` proof

2. **If feasible, implement**:
   - Modify `BMCS.temporally_coherent` to only require eval_family coherence
   - Update `bmcs_truth_lemma` proof
   - Verify completeness theorems still hold

3. **If not feasible, implement DovetailingChain fixes**:
   - Cross-sign GContent/HContent propagation
   - F/P witness enumeration via dovetailing

4. **Document the sorry** (regardless of path):
   - Update SORRY_REGISTRY.md with current status
   - Mark as "construction assumption - tolerated during development"

## References

### Prior Reports
- research-004.md: Henkin counterexample proof
- research-003.md: Modal saturation completion
- implementation-summary-20260213.md: Current phase status

### Key Code Files
- `TemporalCoherentConstruction.lean`: Axiom and sorry location
- `SaturatedConstruction.lean`: Modal saturation (sorry-free)
- `DovetailingChain.lean`: 4 sorries for temporal coherence
- `TruthLemma.lean`: Key theorem requiring analysis

### External Resources
- Standard modal logic texts: Combining S5 with temporal logic typically uses product frames
- Henkin completeness: Standard reference for MCS construction pitfalls
