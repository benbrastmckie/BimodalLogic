# Boneyard: Deprecated Completeness Code

This directory contains deprecated code from the TM bimodal logic completeness project. The code is preserved for historical reference and potential future exploration but is **not part of the active development**.

## Why This Code Was Deprecated

### Overview

Two alternative approaches to proving completeness were explored before the successful semantic approach was developed. Both approaches encountered fundamental obstacles that made them unsuitable for a complete proof.

## Contents

### 1. SyntacticApproach.lean

**Source**: Extracted from `Metalogic/Completeness/FiniteCanonicalModel.lean`

**What it contains**:
- `IsLocallyConsistent` - Consistency predicate for world states
- `FiniteWorldState` - Syntactic world states based on local consistency
- `FiniteTaskRel` namespace - Task relation via transfer conditions
- `finite_task_rel` - Original task relation definition
- `finite_truth_lemma` - Truth lemma (has 6+ sorries)
- `finite_weak_completeness` - Weak completeness (axiom, never proven)

**Why deprecated**:
- The `IsLocallyConsistent` definition only captures **soundness** (one direction), not the **negation-completeness** (maximality) needed for the backward directions of the truth lemma
- 6+ sorry gaps remain in the backward directions of `finite_truth_lemma`
- The gaps are fundamental to the approach, not fixable without changing the definition
- Task 473 introduced the semantic approach which bypasses these issues entirely

**Key insight**: For the truth lemma to work backwards (if phi is true in the model, then phi is in the set), we need world states to be negation-complete: for all phi in the closure, either phi or ~phi is in the state. `IsLocallyConsistent` only ensures soundness (derivable formulas are consistent), not this stronger property.

### 2. DurationConstruction.lean

**Source**: Extracted from `Metalogic/Completeness.lean`

**What it contains**:
- `TemporalChain` - Maximal linear suborders of MCS accessibility
- `ChainSegment` - Convex subsets of temporal chains
- `orderTypeEquiv` - Equivalence relation on segments
- `PositiveDuration` - Quotient of segments under order-type equivalence
- `Duration` - Grothendieck group completion (linear ordered add comm group)
- `canonical_task_rel` - Task relation using Duration as time domain
- `canonical_frame` - Canonical frame with Duration time

**Why deprecated**:
- The approach attempted to be "agnostic" about temporal structure (discrete/dense/continuous)
- However, the Duration algebra has ~15 sorry gaps in basic properties:
  - `PositiveDuration.zero_add`, `add_zero`, `add_assoc`, `add_comm` - all have sorries
  - `Duration.le_antisymm`, `le_total` - have sorries
  - Compositionality has gaps for mixed-sign duration cases
- The finite model approach (using `FiniteTime k`) proved more tractable
- The semantic approach with bounded time domains successfully achieved completeness

**Key insight**: The Duration construction was mathematically interesting but overcomplicated. The finite model property shows we only need bounded time domains, making the general Duration construction unnecessary.

### 3. DeprecatedCompleteness.lean

**Source**: Documents deprecated theorems from `Metalogic_v2/Representation/SemanticCanonicalModel.lean`

**What it documents**:
- `semantic_task_rel_compositionality` - Compositionality axiom (mathematically false for unbounded durations)
- `semantic_truth_implies_truth_at` - Truth bridge lemma (formula induction issues)
- `main_weak_completeness_v2` - Alternative completeness via general validity

**Why deprecated**:
- `semantic_task_rel_compositionality` is mathematically impossible to prove without bounding the duration sum
- `semantic_truth_implies_truth_at` requires formula induction with problematic modal/temporal cases
- `main_weak_completeness_v2` depends on the truth bridge which has a sorry
- The sorry-free `semantic_weak_completeness` provides the same result via a different approach

**Key insight**: The `semantic_weak_completeness` theorem works by using `semantic_truth_at_v2` (internal finite model truth) and avoiding the bridge to general `truth_at` entirely. This bypasses the need for both the compositionality proof and the truth bridge.

**Note**: The `semantic_task_rel_compositionality` theorem was removed in Task #616. The sorry is now inlined directly in the `SemanticCanonicalFrame` definition where the TaskFrame instance requires it. This keeps the sorry localized and avoids a named theorem claiming something mathematically false.

## Replacement: Semantic Approach (Task 473)

The successful approach is in `Metalogic/Completeness/FiniteCanonicalModel.lean`:

- **SemanticWorldState**: World states as quotients of (FiniteHistory, FiniteTime) pairs
- **semantic_task_rel_v2**: Task relation via history/time existence
- **semantic_truth_lemma_v2**: Proven without sorries
- **semantic_weak_completeness**: Core completeness result (proven)

This approach works because:
1. Truth is evaluated on histories, not abstract world states
2. Compositionality is trivial by construction (histories already satisfy it)
3. The negation-completeness issue is bypassed entirely

## Related Tasks

- **Task 446**: Original Duration construction
- **Task 458**: Completeness research identifying the gaps
- **Task 473**: SemanticWorldState architecture (the fix)
- **Task 481**: finite_history_from_state
- **Task 482**: History gluing lemma
- **Task 487**: Boneyard creation (SyntacticApproach, DurationConstruction)
- **Task 616**: Remove false theorem semantic_task_rel_compositionality
- **Task 626**: Review and remove unnecessary sorries (DeprecatedCompleteness)

## Status

**DO NOT USE** for active development. These files may not build cleanly and contain fundamental gaps.

For completeness proofs, use the semantic approach in `FiniteCanonicalModel.lean` (Phase 5-7 sections).

---

*Last updated: 2026-01-19*
*Reason: Superseded by SemanticWorldState approach*
