# Research Report: Bimodal/Metalogic Source Comment Quality

**Task**: 746 - Improve Bimodal/Metalogic source comments
**Date**: 2026-01-29
**Session**: sess_1769697897_a93d54

## Executive Summary

This report surveys the 29 Lean source files in `Theories/Bimodal/Metalogic/` to identify comment patterns requiring improvement. The main issues are:

1. **Temporal/historical language** - "now", "we tried", "previously", etc.
2. **Informal proof narration** - "we need", "we have", "we get"
3. **Meta-commentary about development history** - superseded approaches, task references
4. **Inconsistent documentation styles** across files

## File Inventory

### Core/ (4 files)
| File | Lines | Comment Quality | Priority |
|------|-------|-----------------|----------|
| Core.lean | 3 | Minimal - just imports | Low |
| MaximalConsistent.lean | 2 | Minimal header | Low |
| DeductionTheorem.lean | ~500 | Good structure, some proof narration | Medium |
| MCSProperties.lean | ~350 | Good, some temporal language | Medium |

### Algebraic/ (6 files)
| File | Lines | Comment Quality | Priority |
|------|-------|-----------------|----------|
| Algebraic.lean | 2 | Minimal | Low |
| LindenbaumQuotient.lean | ~300 | Good headers, "now" at L276 | Medium |
| BooleanStructure.lean | ~450 | Extensive proof comments with "now", "for now" | High |
| InteriorOperators.lean | ~200 | Good structure | Low |
| UltrafilterMCS.lean | ~900 | Good headers, many proof narration comments | High |
| AlgebraicRepresentation.lean | ~200 | Good headers | Low |

### Representation/ (8 files)
| File | Lines | Comment Quality | Priority |
|------|-------|-----------------|----------|
| IndexedMCSFamily.lean | ~700 | Excellent documentation, but "Design Evolution" with history | High |
| TaskRelation.lean | ~200 | Good | Low |
| CanonicalWorld.lean | ~200 | "For now" comments, TODO markers | Medium |
| CanonicalHistory.lean | ~250 | Good | Low |
| UniversalCanonicalModel.lean | ~150 | "For now" at L82, TODO at L81 | Medium |
| CoherentConstruction.lean | ~800 | "Key Insight", "NOTE: previously", SUPERSEDED sections | High |
| TruthLemma.lean | ~450 | Good structure | Low |

### Completeness/ (4 files)
| File | Lines | Comment Quality | Priority |
|------|-------|-----------------|----------|
| Completeness.lean | 3 | Minimal | Low |
| WeakCompleteness.lean | ~250 | Good | Low |
| FiniteStrongCompleteness.lean | ~200 | Good | Low |
| InfinitaryStrongCompleteness.lean | ~500 | Extensive proof narration, "at this point" | High |

### Compactness/ (1 file)
| File | Lines | Comment Quality | Priority |
|------|-------|-----------------|----------|
| Compactness.lean | ~150 | "at this point" at L100 | Medium |

### FMP/ (6 files)
| File | Lines | Comment Quality | Priority |
|------|-------|-----------------|----------|
| FMP.lean | 2 | Minimal | Low |
| Closure.lean | ~700 | Good headers, "Known Issue" section | Medium |
| BoundedTime.lean | ~200 | Good | Low |
| FiniteWorldState.lean | ~250 | NOTE marker at L81 | Medium |
| SemanticCanonicalModel.lean | ~500 | "Known Sorries" section, "KNOWN GAP" | High |
| FiniteModelProperty.lean | ~250 | "Known Sorries" section | Medium |

### Top-level (1 file)
| File | Lines | Comment Quality | Priority |
|------|-------|-----------------|----------|
| Metalogic.lean | ~70 | Good overview documentation | Low |

## Problematic Comment Patterns

### 1. Temporal/Historical Language (HIGH priority)

**Pattern**: "now", "currently", "previously", "at this point"

**Examples**:
```lean
-- LindenbaumQuotient.lean:276
We now lift the logical operations to the quotient type.

-- BooleanStructure.lean:85
We now establish the lattice operations (sup = or, inf = and).

-- BooleanStructure.lean:101
For now, we provide the structure with sorries for the proofs.

-- InfinitaryStrongCompleteness.lean:252
-- We need to show that all of Gamma is true at this point to get contradiction
```

**Recommended Fix**: Remove temporal framing, use direct declarative statements.
- "We now lift..." -> "The logical operations lift..."
- "For now, we provide..." -> "The structure includes sorries..."

### 2. Proof Narration Commentary (MEDIUM priority)

**Pattern**: "we need", "we have", "we get", "we know"

**Examples**:
```lean
-- BooleanStructure.lean:149
-- phi or psi = not phi -> psi, so we need vdash phi -> (not phi -> psi)

-- UltrafilterMCS.lean:157
-- We need [phi] vdash psi to show psi in Gamma

-- CoherentConstruction.lean:205
-- We need to show L is consistent
```

**Recommended Fix**: Reframe as goals or assertions.
- "we need X" -> "Goal: X" or "Must show: X"
- "we have X" -> "By hypothesis: X" or simply remove

### 3. Development History References (HIGH priority)

**Pattern**: Task references, "previously", "superseded", "originally"

**Examples**:
```lean
-- IndexedMCSFamily.lean:18-19
**Design Evolution**: Originally, TM logic used irreflexive temporal operators...
As of Task #658, we switched to REFLEXIVE temporal operators

-- CoherentConstruction.lean:73
-- NOTE: MCSProperties provides helper lemmas (previously from Boneyard).

-- CoherentConstruction.lean:112
**Key Insight**: Unlike the original `construct_indexed_family` which tried to prove
```

**Recommended Fix**: Remove evolution narrative, state current design directly.
- Remove "Design Evolution" section, state current design only
- Remove "previously from Boneyard" reference
- Remove comparisons to superseded approaches

### 4. Known Issue/Gap Documentation (KEEP but standardize)

**Pattern**: "Known Issue", "Known Sorry", "KNOWN GAP", "TODO"

**Examples**:
```lean
-- Closure.lean:32
## Known Issue: Double-Negation Escape

-- SemanticCanonicalModel.lean:223
-- KNOWN GAP: Compositionality is mathematically false for unbounded durations

-- CanonicalWorld.lean:116
sorry -- TODO: Complete this proof using set-based MCS properties
```

**Recommended Fix**: Standardize format but keep content.
- Use consistent `## Known Limitations` or `## Open Problems` heading
- Format inline TODOs consistently as `-- TODO(#N): description`

### 5. Inconsistent Header Documentation (MEDIUM priority)

Some files have excellent headers (IndexedMCSFamily, CoherentConstruction) while others have minimal or no module documentation (Core.lean, Completeness.lean).

**Recommended Fix**: Add standardized headers to sparse files:
- `## Overview` - what the module provides
- `## Main Definitions` - key constructs
- `## References` - related files/external refs

## Priority File List for Improvement

### High Priority (extensive changes needed)
1. **CoherentConstruction.lean** - "SUPERSEDED" sections, "previously", extensive historical notes
2. **IndexedMCSFamily.lean** - "Design Evolution" section, task references
3. **InfinitaryStrongCompleteness.lean** - extensive proof narration
4. **BooleanStructure.lean** - many "now", "For now" comments
5. **UltrafilterMCS.lean** - extensive proof narration
6. **SemanticCanonicalModel.lean** - "KNOWN GAP" formatting

### Medium Priority (targeted fixes)
7. **LindenbaumQuotient.lean** - single "now" instance
8. **CanonicalWorld.lean** - "For now", TODOs
9. **UniversalCanonicalModel.lean** - "For now", TODO
10. **MCSProperties.lean** - some proof narration
11. **DeductionTheorem.lean** - some proof narration
12. **Compactness.lean** - "at this point"
13. **Closure.lean** - standardize "Known Issue"
14. **FiniteModelProperty.lean** - standardize "Known Sorries"
15. **FiniteWorldState.lean** - NOTE marker

### Low Priority (minimal changes or good as-is)
- Core.lean, Algebraic.lean, Completeness.lean, FMP.lean, Metalogic.lean (import files)
- TaskRelation.lean, CanonicalHistory.lean, TruthLemma.lean, AlgebraicRepresentation.lean
- WeakCompleteness.lean, FiniteStrongCompleteness.lean, BoundedTime.lean, InteriorOperators.lean

## Specific Examples with Suggested Revisions

### Example 1: IndexedMCSFamily.lean Lines 18-45

**Current**:
```lean
## Overview

**Design Evolution**: Originally, TM logic used irreflexive temporal operators (G = "strictly future",
H = "strictly past") without T-axioms. As of Task #658, we switched to REFLEXIVE temporal operators
with T-axioms (`G phi -> phi`, `H phi -> phi`) to enable coherence proofs.

**Solution**: Build a family of MCS indexed by time, where each time point has its own
MCS connected to adjacent times via temporal coherence conditions.
```

**Suggested**:
```lean
## Overview

This module constructs families of maximal consistent sets (MCS) indexed by time,
where each time point has its own MCS connected to adjacent times via temporal
coherence conditions.

The construction uses REFLEXIVE temporal operators with T-axioms (`G phi -> phi`,
`H phi -> phi`), which enable coherence proofs.
```

### Example 2: CoherentConstruction.lean Lines 582-606

**Current**:
```lean
/-!
## SUPERSEDED CONSTRUCTION

**Note**: The `construct_indexed_family` function below uses an independent Lindenbaum
extension approach that cannot prove the required coherence conditions. This approach
has been superseded by `CoherentConstruction.lean`.

**Why this approach fails**:
...
```

**Suggested**: Remove the entire SUPERSEDED section. If the old function is kept for reference,
add a simple deprecation note:
```lean
/--
@[deprecated "Use construct_coherent_family instead"]
...
-/
```

### Example 3: BooleanStructure.lean Lines 205-210

**Current**:
```lean
  -- Now compose: (not phi -> psi) -> (not phi -> chi) with (not phi -> chi) -> chi
  have b2 : vdash ((phi.neg.imp chi).imp chi).imp (((phi.neg.imp psi).imp (phi.neg.imp chi)).imp ((phi.neg.imp psi).imp chi)) :=
    Bimodal.Theorems.Combinators.b_combinator
```

**Suggested**:
```lean
  -- Compose the implications using b_combinator
  have b2 : vdash ((phi.neg.imp chi).imp chi).imp (((phi.neg.imp psi).imp (phi.neg.imp chi)).imp ((phi.neg.imp psi).imp chi)) :=
    Bimodal.Theorems.Combinators.b_combinator
```

## Comment Patterns to Preserve

The following patterns are clear and should be kept:

1. **Section headers** with `/-! ## Section Name -/`
2. **Docstrings** with `/-! ... -/` and `/-- ... -/`
3. **Proof strategy comments** that explain the mathematical approach
4. **Reference sections** pointing to related modules
5. **Type parameter documentation** in structure definitions

## Summary of Changes Required

| Category | Count | Action |
|----------|-------|--------|
| Remove temporal language | ~60 instances | Replace with direct statements |
| Standardize proof narration | ~80 instances | Use "Goal:", "By:", or remove |
| Remove development history | ~15 sections | State current design only |
| Standardize issue markers | ~10 instances | Consistent "Known Limitation" format |
| Add missing headers | ~10 files | Add Overview/Definitions/References |

## Implementation Approach

1. Process High Priority files first (6 files)
2. Then Medium Priority (9 files)
3. Low Priority files need minimal or no changes (14 files)

Each file should be reviewed for:
- Module header completeness
- Temporal/historical language removal
- Proof narration standardization
- Issue marker consistency

Total estimated changes: ~150 comment blocks across 15 files requiring modification.
