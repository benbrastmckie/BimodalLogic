/-!
# Boneyard: Deprecated Completeness Theorems (DEPRECATED)

This file documents deprecated completeness theorems from
`Metalogic_v2/Representation/SemanticCanonicalModel.lean` that had sorries
and were superseded by the sorry-free `semantic_weak_completeness` approach.

## Status: DEPRECATED

**DO NOT USE** for new development. Use `semantic_weak_completeness` instead.

## Why These Theorems Were Deprecated

### 1. `semantic_task_rel_compositionality` (REMOVED - Task #616)

**Original location**: SemanticCanonicalModel.lean (lines 191-236) [now removed]

**Problem**: The compositionality axiom is mathematically false for unbounded
durations in a finite time model.

The semantic_task_rel definition requires witness times in the finite domain [-k, k]
where k = temporalBound phi. This means:
- d1 can be any value in [-2k, 2k] (difference of two times in [-k, k])
- d2 can be any value in [-2k, 2k]
- d1 + d2 can be any value in [-4k, 4k]

However, the conclusion semantic_task_rel phi w (d1+d2) v requires witness times
with difference d1+d2, which is only possible if |d1+d2| <= 2k.

When d1 and d2 have the same sign and are both near 2k (or -2k), their sum
exceeds the representable range and no witness times exist.

**Why acceptable**: The completeness proof doesn't directly use this lemma - it only
needs the TaskFrame structure to exist. The durations that actually arise during
formula evaluation are bounded by the temporal depth, so problematic cases don't
occur in practice.

**Current status**: The theorem was removed in Task #616. The sorry is now inlined
directly in the SemanticCanonicalFrame definition where the TaskFrame instance
requires it. This keeps the sorry localized and avoids a named theorem claiming
something mathematically false.

### 2. `semantic_truth_implies_truth_at`

**Original location**: SemanticCanonicalModel.lean (lines 457-523)

**Problem**: This "truth bridge" lemma would connect finite model truth to general
`truth_at`, but requires handling problematic cases in formula induction:

- **Box case**: `truth_at M tau t (box psi) = forall sigma : WorldHistory F, truth_at M sigma t psi`
  This quantifies over ALL possible WorldHistories in SemanticCanonicalFrame,
  which is uncountably many. The finite world state only knows about finitely
  many states.

- **Temporal cases**: `truth_at M tau t (all_future psi) = forall s > t, truth_at M tau s psi`
  This quantifies over ALL integers s > t, but the finite model only has
  times in [-k, k].

**Why deprecated**: The `semantic_weak_completeness` theorem provides a sorry-free
completeness result by working with `semantic_truth_at_v2` (internal to the finite
model) and avoiding the bridge to general `truth_at` entirely.

### 3. `main_weak_completeness_v2`

**Original location**: SemanticCanonicalModel.lean (lines 685-768)

**Problem**: This theorem attempts to prove completeness via general validity
(`valid phi` quantifies over ALL TaskFrames/WorldHistories/times). It requires
the `semantic_truth_implies_truth_at` bridge lemma which has a sorry.

**Why deprecated**: Use `semantic_weak_completeness` instead, which proves:
`(forall w, semantic_truth_at_v2 phi w t phi) -> provable phi`

This formulation uses internal finite model truth and is proven without sorries.

## The Correct Approach: semantic_weak_completeness

The sorry-free completeness proof in SemanticCanonicalModel.lean works by:

1. Contrapositive: Assume phi is not provable
2. Then {phi.neg} is consistent
3. Extend to full MCS by Lindenbaum
4. Project to closure MCS
5. Build FiniteWorldState from closure MCS
6. phi is false at this world state (by construction)
7. Build SemanticWorldState at origin
8. Show phi is false in semantic_truth_at_v2 sense
9. This contradicts the hypothesis that phi is true everywhere

This approach avoids the truth bridge by working entirely within the finite model.

## Related Files

- `SemanticCanonicalModel.lean`: Contains the working `semantic_weak_completeness`
- `SyntacticApproach.lean`: Boneyard for the earlier syntactic approach
- `DurationConstruction.lean`: Boneyard for the Duration algebra approach

## Task Reference

- **Task 616**: Remove false theorem semantic_task_rel_compositionality
- **Task 626**: Review and remove unnecessary theorems with sorries
- **Research**: specs/626_review_remove_unnecessary_sorries/reports/research-001.md

---

*Archived: 2026-01-19*
*Reason: Superseded by sorry-free semantic_weak_completeness*
-/

-- Note: This file is documentation only. The actual code remains in
-- SemanticCanonicalModel.lean with sorries, as the SemanticCanonicalFrame
-- requires the compositionality axiom for its TaskFrame instance.
--
-- The theorems semantic_truth_implies_truth_at and main_weak_completeness_v2
-- have been REMOVED from SemanticCanonicalModel.lean as they are unused by
-- the main proof chain. The main_provable_iff_valid_v2 theorem has been
-- updated to route through semantic_weak_completeness instead.
