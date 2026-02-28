/-!
# Boneyard: Syntactic Approach (DEPRECATED)

This file documents the deprecated syntactic approach to completeness that exists in
`Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`.

## Status: DEPRECATED

**DO NOT USE** for new development. Use the semantic approach instead.

## Why This Approach Was Deprecated

The syntactic approach attempted to prove completeness using `FiniteWorldState` structures
with `IsLocallyConsistent` consistency predicates. This approach failed because:

1. **IsLocallyConsistent captures only soundness**: The predicate ensures that truth
   assignments respect basic logical laws (bot is false, implications are material,
   modal T axiom holds), but it does NOT ensure negation-completeness.

2. **Truth lemma backward directions require maximality**: To prove that semantic truth
   implies syntactic membership (the "completeness" direction), we need world states to be
   negation-complete: for every formula phi in the closure, either phi or ~phi is true.
   `IsLocallyConsistent` doesn't guarantee this.

3. **6+ sorry gaps in finite_truth_lemma**: The backward directions for imp, box,
   all_past, and all_future cases all require negation-completeness properties that
   the syntactic approach cannot provide.

## Location of Deprecated Code

The deprecated code is in `Bimodal/Metalogic/Completeness/FiniteCanonicalModel.lean`:

### Deprecated Proofs (with sorries)

| Definition/Theorem | Line | Status |
|-------------------|------|--------|
| `finite_truth_lemma` | ~3365 | 6 sorries in backward directions |
| `finite_weak_completeness` | ~3561 | Has bridge sorry |
| `finite_strong_completeness` | ~3583 | Has sorry |

### Infrastructure (Still Used by Semantic Approach)

The following are NOT deprecated as they're used by the working semantic approach:

| Definition | Line | Status |
|------------|------|--------|
| `IsLocallyConsistent` | ~758 | Used by FiniteWorldState |
| `FiniteWorldState` | ~831 | Used by SemanticWorldState.toFiniteWorldState |
| `finite_task_rel` | ~1110 | Used by semantic task relation |
| `FiniteTaskRel.nullity` | ~1150 | Proven, no sorries |
| `FiniteTaskRel.compositionality` | ~1178 | Partial (7 sorries) |

## Replacement: Semantic Approach

The working approach is in the same file (Phase 5-7):

- **SemanticWorldState**: Quotient of (FiniteHistory, FiniteTime) pairs
- **semantic_task_rel_v2**: Task relation via history/time existence
- **semantic_truth_lemma_v2**: Proven, no sorries
- **semantic_weak_completeness**: Core completeness result (proven)
- **main_weak_completeness**: Full validity -> provability (proven)
- **main_provable_iff_valid**: If and only if characterization (proven)

## Key Insight

The semantic approach works because truth is evaluated on histories, not abstract world
states. The negation-completeness issue is bypassed because:

1. SemanticWorldState is defined as equivalence classes of (history, time) pairs
2. Truth at a SemanticWorldState is definitionally equal to truth at the underlying history
3. The truth lemma becomes trivial by construction
4. Compositionality is automatic (histories already satisfy it)

## Historical Context

- **Task 446**: Original Duration construction (deprecated, see DurationConstruction.lean)
- **Task 458**: Research identifying the gaps
- **Task 473**: SemanticWorldState architecture (the fix)
- **Task 487**: This Boneyard documentation

## References

See the module documentation in `FiniteCanonicalModel.lean` (lines 13-95) for full details
on both approaches and their relationship.
-/

-- This file is documentation only - no executable code
-- The deprecated code remains in FiniteCanonicalModel.lean for reference
-- and because some infrastructure is still used by the semantic approach
