# Research Report: Task #606

**Task**: 606 - fix_metalogic_v2_readme_accuracy
**Started**: 2026-01-18T00:00:00Z
**Completed**: 2026-01-18T00:30:00Z
**Effort**: Low
**Priority**: Medium
**Dependencies**: None
**Sources/Inputs**: Codebase analysis (grep, read)
**Artifacts**: specs/606_fix_metalogic_v2_readme_accuracy/reports/research-001.md
**Standards**: report-format.md

## Executive Summary

- README incorrectly claims "All theorems in Metalogic_v2 are fully proven with no sorry statements"
- Found **5 active sorries** in the semantic bridge infrastructure across 3 files
- All sorries are in the `Representation/` subdirectory, specifically in the semantic canonical model approach
- The completeness theorems in `Completeness/` are technically "sorry-free" at their level, but they **transitively depend on sorried lemmas**
- Impact: The core completeness results (`weak_completeness`, `strong_completeness`) are proven correct modulo the 5 sorries in semantic bridge infrastructure

## Context & Scope

The task requires finding all sorry statements in Metalogic_v2, documenting their exact locations, and determining how to accurately update the README.

**Scope**: All `.lean` files in `Theories/Bimodal/Metalogic_v2/`

## Findings

### Sorry Inventory

| # | File | Line | Theorem/Lemma | Status |
|---|------|------|---------------|--------|
| 1 | Representation/Closure.lean | 484 | `closure_mcs_neg_complete` | Active sorry |
| 2 | Representation/SemanticCanonicalModel.lean | 207 | `semantic_task_rel_compositionality` | Active sorry |
| 3 | Representation/SemanticCanonicalModel.lean | 419 | `semantic_truth_implies_truth_at` | Active sorry |
| 4 | Representation/SemanticCanonicalModel.lean | 569 | `main_weak_completeness_v2` | Active sorry |
| 5 | Representation/FiniteWorldState.lean | 321 | `closure_mcs_implies_locally_consistent` | Active sorry |

### Detailed Sorry Analysis

#### 1. `closure_mcs_neg_complete` (Closure.lean:484)

**Location**: `Theories/Bimodal/Metalogic_v2/Representation/Closure.lean:266-484`

**Purpose**: Proves that in a closure MCS, either psi or psi.neg is in the set (for psi in closureWithNeg).

**Context**: The sorry occurs in Case 2 (psi = chi.neg for some chi in closure). The proof handles a double-negation escape issue where `chi.neg.neg` escapes `closureWithNeg`.

**Known Issue (documented in code)**:
```
KNOWN ISSUE: When psi = chi.neg (chi ∈ closure), psi.neg = chi.neg.neg
escapes closureWithNeg. This means the maximality condition doesn't
directly apply to psi.neg.
```

**Used by**:
- `closure_mcs_neg_complete` is called by several downstream lemmas in Closure.lean (lines 798, 834, 844)

#### 2. `semantic_task_rel_compositionality` (SemanticCanonicalModel.lean:207)

**Location**: `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean:196-207`

**Purpose**: Proves compositionality of the semantic task relation - if w relates to u by d1 and u relates to v by d2, then w relates to v by d1+d2.

**Context**: Requires "history gluing infrastructure" to combine two histories witnessing the individual relations.

**Impact**: Used directly to construct `SemanticCanonicalFrame` (line 220), which is the frame underlying `SemanticCanonicalModel`.

#### 3. `semantic_truth_implies_truth_at` (SemanticCanonicalModel.lean:419)

**Location**: `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean:410-419`

**Purpose**: Key bridge theorem showing that semantic truth in SemanticCanonicalModel implies truth_at.

**Context**: Requires induction on formula structure and careful handling of correspondence between finite world state truth and model truth.

**Documentation in code**:
```
**Note**: This theorem has a sorry inherited from the old Metalogic implementation.
The proof requires induction on formula structure and careful handling of the
correspondence between finite world state truth and model truth.
```

**Impact**: Called by:
- `finite_model_property_full` in FiniteModelProperty.lean (line 480)
- Critical for connecting semantic truth to model truth

#### 4. `main_weak_completeness_v2` (SemanticCanonicalModel.lean:569)

**Location**: `Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean:510-569`

**Purpose**: Main completeness theorem - if phi is valid, then phi is provable.

**Context**: The sorry occurs at Step 13, which requires bridging from `truth_at` to `w.models`. This requires the full semantic truth lemma that hasn't been fully proven.

**Documentation in code**:
```
**Status**: This requires the full truth correspondence lemma
and correct model construction. Currently has sorry.
```

**Impact**:
- Called by `main_provable_iff_valid_v2` (line 583)
- `main_provable_iff_valid_v2` is the cornerstone used by `representation_theorem_backward_empty`
- This transitively affects `weak_completeness` and `strong_completeness`

#### 5. `closure_mcs_implies_locally_consistent` (FiniteWorldState.lean:321)

**Location**: `Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean:316-321`

**Purpose**: Proves that a closure MCS induces a locally consistent truth assignment.

**Context**: Requires temporal reflexivity axioms (H phi -> phi, G phi -> phi) which are NOT valid in TM logic's strict temporal semantics.

**Documentation in code**:
```
NOTE: This requires the MCS to satisfy temporal reflexivity axioms (H phi -> phi, G phi -> phi).
The TM logic uses strict temporal semantics, so these are NOT valid axioms.
This is an architectural limitation - the semantic approach bypasses this issue.
```

**Impact**: Used to construct `worldStateFromClosureMCS` (line 328), which is part of the semantic canonical model construction.

### Dependency Analysis

```
weak_completeness (WeakCompleteness.lean)
    └── representation_theorem_backward_empty (ContextProvability.lean)
        └── main_provable_iff_valid_v2 (SemanticCanonicalModel.lean)
            └── main_weak_completeness_v2 [SORRY]
                ├── semantic_truth_implies_truth_at [SORRY]
                └── SemanticCanonicalModel
                    └── SemanticCanonicalFrame
                        └── semantic_task_rel_compositionality [SORRY]

strong_completeness (StrongCompleteness.lean)
    └── weak_completeness (see above)

finite_model_property_full (FiniteModelProperty.lean)
    └── semantic_truth_implies_truth_at [SORRY]

closure_mcs_neg_complete [SORRY]
    └── (used internally in Closure.lean for MCS properties)

closure_mcs_implies_locally_consistent [SORRY]
    └── worldStateFromClosureMCS
        └── (used in semantic canonical model construction)
```

### Current README Claims vs Reality

**README Line 73**: "### Proven (no sorry)"

This section lists 14 theorems as "proven (no sorry)". Analysis:

| Theorem | Direct Sorry? | Transitive Sorry? |
|---------|---------------|-------------------|
| `soundness` | No | No |
| `deduction_theorem` | No | No |
| `set_lindenbaum` | No | No |
| `maximal_consistent_closed` | No | No |
| `maximal_negation_complete` | No | No |
| `representation_theorem` | No | Yes (via SemanticCanonicalModel) |
| `mcs_contains_or_neg` | No | No |
| `mcs_modus_ponens` | No | No |
| `representation_theorem_backward_empty` | No | Yes (via main_provable_iff_valid_v2) |
| `weak_completeness` | No | Yes |
| `strong_completeness` | No | Yes |
| `necessitation_lemma` | No | No |
| `finite_model_property` | No | Yes |
| `satisfiability_decidable` | No | Yes |
| `validity_decidable_via_fmp` | No | Yes |

**README Line 93**: "All theorems in Metalogic_v2 are fully proven with no sorry statements."

**Verdict**: This claim is **FALSE**. There are 5 active sorries.

## Recommendations

### Option A: Conservative Documentation (Recommended)

Update README to accurately document the sorry status:

1. Change "### Proven (no sorry)" to "### Key Theorems"
2. Add a new section "### Theorems with Sorries" listing the 5 sorried lemmas
3. Replace line 93 with accurate status:
   ```
   **Status**: Most core theorems are proven. The completeness theorems depend on 5 sorries
   in the semantic bridge infrastructure (SemanticCanonicalModel and related lemmas).
   ```

### Option B: Detailed Documentation

Add a "## Proof Status" section with:
1. Categorization: "Fully Proven", "Proven with Transitive Sorries", "Contains Sorry"
2. Dependency diagram showing sorry propagation
3. Impact assessment for each sorry

### Suggested README Edits

1. **Line 73**: Change "### Proven (no sorry)" to "### Core Theorems"

2. **Add new section after line 91**:
   ```markdown
   ### Theorems with Sorries (5 total)

   | Location | Theorem | Issue |
   |----------|---------|-------|
   | Closure.lean:484 | `closure_mcs_neg_complete` | Double-negation escape |
   | SemanticCanonicalModel.lean:207 | `semantic_task_rel_compositionality` | History gluing |
   | SemanticCanonicalModel.lean:419 | `semantic_truth_implies_truth_at` | Formula induction |
   | SemanticCanonicalModel.lean:569 | `main_weak_completeness_v2` | Truth bridge |
   | FiniteWorldState.lean:321 | `closure_mcs_implies_locally_consistent` | Temporal axioms |

   **Impact**: The completeness theorems (`weak_completeness`, `strong_completeness`) and
   FMP-related theorems transitively depend on these sorries through `main_provable_iff_valid_v2`.
   ```

3. **Line 93**: Replace with:
   ```markdown
   The Metalogic_v2 infrastructure has **5 active sorries** in the semantic bridge layer.
   Core theorems like soundness, deduction theorem, and MCS properties are fully proven.
   Completeness theorems are structurally correct but rely on the semantic bridge sorries.
   ```

## Decisions

- Document exact file:line locations for all sorries
- Distinguish between "direct sorry" and "transitive dependency on sorry"
- Preserve the README's structure but add accuracy

## Risks & Mitigations

| Risk | Mitigation |
|------|------------|
| Users may think entire module is broken | Clarify that soundness and many core theorems ARE fully proven |
| Confusion about "transitive sorry" | Add clear dependency diagram |
| Overly pessimistic assessment | Highlight that the proof STRUCTURE is correct, only bridges need completion |

## Appendix

### Search Commands Used
```bash
grep -rn "sorry" Theories/Bimodal/Metalogic_v2/
```

### Files Examined
- Theories/Bimodal/Metalogic_v2/README.md
- Theories/Bimodal/Metalogic_v2/Representation/Closure.lean
- Theories/Bimodal/Metalogic_v2/Representation/SemanticCanonicalModel.lean
- Theories/Bimodal/Metalogic_v2/Representation/FiniteWorldState.lean
- Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean
- Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean
- Theories/Bimodal/Metalogic_v2/Completeness/WeakCompleteness.lean
- Theories/Bimodal/Metalogic_v2/Completeness/StrongCompleteness.lean
