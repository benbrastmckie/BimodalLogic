# Bimodal Metalogic Infrastructure

## Overview

This directory contains the universal parametric canonical model construction for proving completeness of TM bimodal logic.
The approach uses indexed families of maximal consistent sets (MCS) with temporal coherence conditions, avoiding the T-axiom requirement that blocked earlier approaches.

## Architecture

### IndexedMCSFamily Approach

The key insight: Build a family of maximal consistent sets indexed by time, where each time point has its own MCS connected via temporal coherence conditions.

**Why not the same MCS at all times?**
- TM logic has IRREFLEXIVE temporal operators (G/H exclude the present)
- T-axiom (`G phi -> phi`) is NOT valid in TM
- Same-MCS approach would require T-axiom for truth lemma

**Solution**:
- `IndexedMCSFamily D`: Maps each time `t : D` to an MCS
- Coherence conditions: `G phi in mcs(t)` implies `phi in mcs(t')` for `t' > t` (strictly future)
- Matches irreflexive semantics perfectly

### Temporal Coherence Conditions

The four coherence conditions are critical for correctness:

1. **forward_G**: G formulas at t propagate to all strictly future t' > t
   - Semantic justification: If `G phi` means "phi at all strictly future times", and `G phi` is in mcs(t), then phi must be in mcs(t') for any t' > t

2. **backward_H**: H formulas at t propagate to all strictly past t' < t
   - Symmetric to forward_G for past direction

3. **forward_H**: H formulas at future times connect to past
   - Looking back from the future: If at some future time t' > t we have "phi was always true in the past", then phi must have been true at t

4. **backward_G**: G formulas at past times connect to present
   - Looking forward from the past: If at some past time t' < t we have "phi will always be true in the future", then phi must be true at t

**Key**: All conditions use STRICT inequality (< not <=), matching TM's irreflexive operators.

### Main Components

| File | Purpose |
|------|---------|
| `Core/MaximalConsistent.lean` | Re-exports MCS infrastructure from Boneyard |
| `Representation/IndexedMCSFamily.lean` | MCS family with temporal coherence |
| `Representation/CanonicalWorld.lean` | World state construction from MCS |
| `Representation/CanonicalHistory.lean` | History construction from family |
| `Representation/TaskRelation.lean` | Task relation definition |
| `Representation/TruthLemma.lean` | Truth correspondence (MCS membership <-> semantic truth) |
| `Representation/UniversalCanonicalModel.lean` | Representation theorem (consistent -> satisfiable) |

### Duration Parametricity

All constructions are parametric over the duration type `D`:
- `D` must be a totally ordered abelian group (`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`)
- Examples: Int, Rat, Real, custom bounded groups
- Matches JPL paper specification exactly

This parametricity means the completeness result holds for any compatible time domain, not just integers.

## Key Theorems

### Representation Theorem
```lean
theorem representation_theorem (phi : Formula) (h_cons : SetConsistent {phi}) :
    exists (family : IndexedMCSFamily D) (t : D),
      phi in family.mcs t /\
      truth_at (canonical_model D family) (canonical_history_family D family) t phi
```

Every consistent formula is satisfiable in the canonical model.

### Truth Lemma
```lean
theorem truth_lemma (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    phi in family.mcs t <-> truth_at (canonical_model D family) (canonical_history_family D family) t phi
```

MCS membership corresponds exactly to semantic truth.

## Relation to Boneyard Code

The `Boneyard/Metalogic_v2/` directory contains deprecated code using:
- `SemanticCanonicalFrame`: Formula-specific finite canonical frame
- `SemanticWorldState`: Quotient-based world states
- Fixed time bounds: FiniteTime with domain [-k, k]

**Why deprecated**:
1. `semantic_task_rel_compositionality` has a sorry (mathematically impossible for unbounded durations in finite domain)
2. Formula-dependence (not universally parametric)
3. Truth bridge complexity between finite and general models

The current IndexedMCSFamily approach avoids these issues by:
- Using formula-independent MCS families
- Parametric duration type
- Direct truth lemma without truth bridge

## Related Files

- `Boneyard/README.md`: Explains why previous approaches were deprecated
- `Semantics/TaskFrame.lean`: Base TaskFrame structure
- `latex/subfiles/04-Metalogic.tex`: LaTeX documentation

## References

- JPL Paper "The Perpetuity Calculus of Agency" (task frame definition)
- Blackburn et al. "Modal Logic" Chapter 4 (canonical models, compactness)
- Research report: specs/654_.../reports/research-004.md (indexed family approach)

---

*Last updated: 2026-01-25*
*Architecture: IndexedMCSFamily universal parametric canonical model*
