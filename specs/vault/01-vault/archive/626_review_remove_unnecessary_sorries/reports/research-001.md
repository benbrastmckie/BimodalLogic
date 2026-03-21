# Research Report: Task #626

**Task**: 626 - Review and remove unnecessary theorems/lemmas with sorries
**Started**: 2026-01-19
**Completed**: 2026-01-19
**Effort**: Medium
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Metalogic_v2 codebase, lean_diagnostic_messages, grep searches
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Found **8 sorries** in `Theories/Bimodal/Metalogic_v2/` across 3 files
- **5 sorries are UNNECESSARY** - can be safely deleted or relocated to Boneyard
- **3 sorries are USEFUL** - could be proven with moderate effort, but not critical
- **0 sorries are CRITICAL** - the main proof chain (completeness via `semantic_weak_completeness`) is already sorry-free
- Recommended actions: DELETE 2, RELOCATE 3, optionally PROVE 3

## Context & Scope

This research systematically reviews all `sorry` occurrences in `Theories/Bimodal/Metalogic_v2/` to determine:
1. Which theorems/lemmas with sorries are needed for the main proof chain
2. Which can be removed entirely
3. Which should be moved to `Bimodal/Boneyard/` for future reference

The policy is: **only include theorems and lemmas that are needed AND provable** - no sorries should be accepted as permanent.

## Findings

### Complete Sorry Inventory

| # | File | Line | Theorem | Sorry Description |
|---|------|------|---------|-------------------|
| 1 | BranchClosure.lean | 201 | `closed_extend_closed` | findSome? monotonicity |
| 2 | BranchClosure.lean | 226 | `add_neg_causes_closure` | hasPos/hasNeg unfolding |
| 3 | Correctness.lean | 153 | `tableau_complete` | FMP-tableau connection |
| 4 | Correctness.lean | 192 | `decide_complete` | Proof extraction |
| 5 | Correctness.lean | 319 | `decide_axiom_valid` | matchAxiom completeness |
| 6 | SemanticCanonicalModel.lean | 236 | `semantic_task_rel_compositionality` | History gluing in finite model |
| 7 | SemanticCanonicalModel.lean | 523 | `semantic_truth_implies_truth_at` | Formula induction bridge |
| 8 | SemanticCanonicalModel.lean | 768 | `main_weak_completeness_v2` | Truth bridge |

### Classification

#### UNNECESSARY (Safe to Delete)

**#3 `tableau_complete`** (Correctness.lean:153)
- **Status**: UNNECESSARY - DELETE
- **Reason**: This theorem is part of the decidability procedure completeness, but:
  - The FMP already provides `validity_decidable_via_fmp` which establishes decidability via the finite model property
  - The semantic completeness (`semantic_weak_completeness`) is proven without this
  - This is an alternative approach that was never completed
- **Dependencies**: `decide_complete` depends on this, but both can be removed together
- **Action**: Delete both `tableau_complete` and its dependent code

**#4 `decide_complete`** (Correctness.lean:192)
- **Status**: UNNECESSARY - DELETE
- **Reason**: Depends on `tableau_complete` which has a sorry. The decision procedure soundness (`decide_sound`) is proven and that's the important direction. Completeness for the decision procedure is nice-to-have but not essential since `validity_decidable_via_fmp` already gives decidability.
- **Dependencies**: None downstream
- **Action**: Delete

#### USEFUL (Relocate to Boneyard)

**#6 `semantic_task_rel_compositionality`** (SemanticCanonicalModel.lean:236)
- **Status**: USEFUL but mathematically false for unbounded durations - RELOCATE
- **Reason**: The documentation explains this is **mathematically impossible** to prove without additional hypotheses. The compositionality axiom requires `|d1 + d2| <= 2k` but the theorem allows arbitrary integers. This is a known limitation documented extensively in the source.
- **Impact**: Used to construct `SemanticCanonicalFrame`. However, the frame is only used to instantiate validity quantifiers, and the actual truth evaluation doesn't call compositionality directly.
- **Why Keep**: Documents an interesting mathematical limitation and design decision
- **Action**: Move to Boneyard with explanation

**#7 `semantic_truth_implies_truth_at`** (SemanticCanonicalModel.lean:523)
- **Status**: USEFUL but deprecated approach - RELOCATE
- **Reason**: This is the "truth bridge" that would connect finite model truth to general `truth_at`. The documentation explains why this is hard (requires formula induction with problematic modal/temporal cases).
- **Impact**: Used by `main_weak_completeness_v2` and `valid_implies_not_satisfiable_neg` in FiniteModelProperty.lean
- **Why Keep**: Documents the attempted bridge approach
- **Action**: Move to Boneyard along with `main_weak_completeness_v2`

**#8 `main_weak_completeness_v2`** (SemanticCanonicalModel.lean:768)
- **Status**: USEFUL but deprecated - RELOCATE
- **Reason**: This is an alternative completeness proof via general validity. The sorry-free version `semantic_weak_completeness` is the recommended approach (documented in README).
- **Dependencies**: Used by `main_provable_iff_valid_v2`
- **Why Keep**: Documents the attempted general validity approach
- **Action**: Move to Boneyard. Update `main_provable_iff_valid_v2` to use `semantic_weak_completeness` instead

#### PROVABLE (Could be proven with effort)

**#1 `closed_extend_closed`** (BranchClosure.lean:201)
- **Status**: PROVABLE - Low difficulty
- **What it states**: A closed branch remains closed when extended
- **Proof strategy**: Case analysis on the `ClosureReason`, showing each check (botPos, contradiction, axiomNeg) is preserved under list extension
- **Estimated effort**: 30-60 minutes
- **Impact**: Not used anywhere currently - this is a standalone property
- **Recommendation**: Either prove or delete since it's unused

**#2 `add_neg_causes_closure`** (BranchClosure.lean:226)
- **Status**: PROVABLE - Low difficulty
- **What it states**: Adding F(phi) to a branch with T(phi) causes closure
- **Proof strategy**: Unfold `hasPos`, `hasNeg`, show `checkContradiction` finds the pair
- **Estimated effort**: 30-60 minutes
- **Impact**: Not used anywhere currently - standalone property
- **Recommendation**: Either prove or delete since it's unused

**#5 `decide_axiom_valid`** (Correctness.lean:319)
- **Status**: PROVABLE - Medium difficulty
- **What it states**: Decision procedure returns valid for axiom instances
- **Proof strategy**: Show `matchAxiom` recognizes all `Axiom phi` patterns, then show `tryAxiomProof` succeeds
- **Estimated effort**: 1-2 hours (depends on matchAxiom implementation)
- **Impact**: Nice-to-have for decision procedure, but soundness already proven
- **Recommendation**: Either prove or delete

### Dependency Analysis

```
Main Proof Chain (SORRY-FREE):
soundness
    |
    v
semantic_weak_completeness (PROVEN - no sorry!)
    |
    v
weak_completeness / strong_completeness (PROVEN via semantic_weak_completeness)
    |
    v
compactness (PROVEN)

Alternative Chain (HAS SORRIES - can be removed):
semantic_truth_implies_truth_at [sorry]
    |
    v
main_weak_completeness_v2 [sorry]
    |
    v
main_provable_iff_valid_v2 (uses main_weak_completeness_v2)

Decision Procedure Chain (PARTIAL - soundness proven, completeness has sorries):
decide_sound (PROVEN)
tableau_complete [sorry]
    |
    v
decide_complete [sorry]
```

### Impact Summary

| Chain | Status | Impact of Removing Sorries |
|-------|--------|---------------------------|
| Main completeness | SORRY-FREE | No impact - already clean |
| Alternative validity | HAS SORRIES | Can be deleted/relocated - not used by main chain |
| Decision procedure | PARTIAL | Soundness proven (important), completeness optional |
| BranchClosure | HAS SORRIES | Unused theorems - can be deleted |

## Decisions

1. **Main completeness via `semantic_weak_completeness`**: Keep as-is (sorry-free)
2. **Alternative validity approach**: Relocate to Boneyard (documents attempted approach)
3. **Decision procedure**: Keep soundness, delete completeness theorems with sorries
4. **Unused BranchClosure theorems**: Delete (they serve no purpose if unused)

## Recommendations

### Priority 1: DELETE (Unnecessary)

| Theorem | File | Action | Justification |
|---------|------|--------|---------------|
| `tableau_complete` | Correctness.lean | DELETE | Never completed, alternative decidability exists |
| `decide_complete` | Correctness.lean | DELETE | Depends on sorry, decidability via FMP exists |
| `closed_extend_closed` | BranchClosure.lean | DELETE | Unused, simple enough to reprove if needed |
| `add_neg_causes_closure` | BranchClosure.lean | DELETE | Unused, simple enough to reprove if needed |

### Priority 2: RELOCATE to Boneyard (Useful for reference)

| Theorem | File | Action | Justification |
|---------|------|--------|---------------|
| `semantic_task_rel_compositionality` | SemanticCanonicalModel.lean | RELOCATE | Mathematically impossible, documents limitation |
| `semantic_truth_implies_truth_at` | SemanticCanonicalModel.lean | RELOCATE | Deprecated approach, documents attempt |
| `main_weak_completeness_v2` | SemanticCanonicalModel.lean | RELOCATE | Deprecated approach, semantic version is better |

### Priority 3: UPDATE dependent code

| Item | Action | Details |
|------|--------|---------|
| `main_provable_iff_valid_v2` | UPDATE | Route through `semantic_weak_completeness` instead |
| `valid_implies_not_satisfiable_neg` | UPDATE | Remove dependency on `semantic_truth_implies_truth_at` |
| README.md | UPDATE | Update sorry count and documentation |

### Priority 4: OPTIONAL PROVE

If time permits, these could be proven:
| Theorem | Difficulty | Estimated Time |
|---------|------------|----------------|
| `decide_axiom_valid` | Medium | 1-2 hours |

## Risks & Mitigations

### Risk 1: Breaking downstream code
- **Mitigation**: The main proof chain is sorry-free and unaffected
- **Check**: Run `lake build` after each change to verify

### Risk 2: Losing useful documentation
- **Mitigation**: Move deprecated theorems to Boneyard with full documentation
- **Pattern**: Follow existing Boneyard pattern (see SyntacticApproach.lean, DurationConstruction.lean)

### Risk 3: Missing hidden dependencies
- **Mitigation**: Grep for all theorem names before deletion
- **Check**: Verified in this research - no hidden dependencies found

## Appendix

### Search Queries Used

1. `grep -n "sorry" Theories/Bimodal/Metalogic_v2/` - Find all sorries
2. `lean_diagnostic_messages` on each file - Verify sorry warnings
3. `grep` for each sorry-containing theorem name - Find dependencies
4. `mcp__lean-lsp__lean_file_outline` - Understand file structure

### Files Examined

- Theories/Bimodal/Metalogic_v2/Decidability/BranchClosure.lean
- Theories/Bimodal/Metalogic_v2/Decidability/Correctness.lean
- Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean
- Theories/Bimodal/Metalogic_v2/Decidability/CountermodelExtraction.lean
- Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean
- Theories/Bimodal/Metalogic_v2/README.md
- Theories/Bimodal/Boneyard/README.md

### References

- Metalogic_v2 README (architecture documentation)
- Boneyard README (relocation pattern)
- Task 554 Research Report (Metalogic_v2 reorganization)
