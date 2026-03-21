# Research Report: Metalogic FMP Zero-Sorry Refactoring

**Task**: 776 - Refactor Metalogic to zero sorry
**Session**: sess_1769737988_5f5595
**Date**: 2026-01-30
**Focus**: Analyze 3 remaining sorries in Metalogic FMP code and determine elimination strategies

## Executive Summary

The Metalogic FMP directory contains exactly **3 sorry statements**, all of which have been thoroughly analyzed in previous tasks (750, 769). These sorries represent:

1. **Mathematical impossibilities** - Code that is provably false for the intended domain
2. **Architectural limitations** - Gaps that cannot be bridged without changing fundamental assumptions
3. **Deprecated code paths** - Theorems that are NOT required for the main completeness result

**Key Finding**: The main completeness theorem `semantic_weak_completeness` is **completely sorry-free**. The 3 sorries exist in deprecated code paths that provide alternative (but blocked) routes to completeness.

**Recommendation**: Archive the deprecated code to `Boneyard/` with clear documentation, leaving only the sorry-free `semantic_weak_completeness` as the canonical completeness proof.

---

## Sorry Analysis

### Sorry #1: SemanticCanonicalFrame.compositionality (Line 233)

**Location**: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean:233`

```lean
compositionality := fun _ _ _ _ _ => sorry
```

**Purpose**: Proves that the task relation composes: if `w R(d1) v` and `v R(d2) u`, then `w R(d1+d2) u`.

**Why it's sorry'd**: **Mathematically false** for unbounded durations in finite time domain `[-k, k]`.

**Mathematical Analysis**:
- The time domain is bounded: `BoundedTime k = Fin (2*k+1)` representing `[-k, k]`
- The task relation uses Int duration: `t2.toInt - t1.toInt = d`
- When composing, `d1 + d2` can exceed `[-2k, 2k]` - the representable range
- Example: If `k = 3`, we can have `d1 = 6` and `d2 = 6` but `d1 + d2 = 12` is unrepresentable

**Elimination Strategy**: This sorry is in the definition of `SemanticCanonicalFrame`, which is marked `-- DEPRECATED (Task 769, 2026-01-30)`. The deprecation note states:

> Use `semantic_weak_completeness` which avoids this frame entirely.

The frame is only needed for the deprecated `sorry_free_weak_completeness` path. Archiving this code removes the sorry.

**Recommendation**: Archive `SemanticCanonicalFrame` to `Boneyard/Metalogic_v4/FMP/` with documentation explaining:
1. Why compositionality is mathematically false
2. Why it's not needed for completeness
3. Pointer to `semantic_weak_completeness`

---

### Sorry #2: truth_at_implies_semantic_truth (Line 695)

**Location**: `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean:695`

```lean
theorem truth_at_implies_semantic_truth (phi : Formula)
    (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0)
    (h_truth : truth_at (SemanticCanonicalModel phi) tau 0 phi) :
    semantic_truth_at_v2 phi (tau.states 0 ht)
      (BoundedTime.origin (temporalBound phi)) phi := by
  sorry
```

**Purpose**: The "forward truth lemma" - proves that if a formula is true under recursive `truth_at` evaluation, then the finite model's assignment marks it true.

**Why it's sorry'd**: **Architectural impossibility** due to S5-style Box semantics.

**Architectural Analysis** (from Task 750 research):

1. **Box Quantifies Over ALL Histories**: In TM semantics, `truth_at M tau t (box psi)` requires `psi` to be true at ALL world states accessible from `tau.states t _`. This is universal quantification over the entire frame.

2. **MCS Construction Has One State**: A ClosureMaximalConsistent set describes ONE world state's truth values. It has no information about other histories.

3. **The Gap**: For the forward direction, we need:
   - Given: `truth_at M tau t phi` (recursive evaluation)
   - Show: The assignment at `tau.states t ht` has `phi` marked true

   For compound formulas (especially Box), this requires the assignment to MATCH recursive evaluation. But arbitrary `FiniteWorldState`s have arbitrary locally-consistent assignments - they don't necessarily match recursive truth.

4. **For MCS-derived states**: The backward direction works because MCS membership DEFINES what's true. But the forward direction would require knowing the formula is in the MCS, which requires completeness - circular!

**Elimination Strategy**: This sorry is in `truth_at_implies_semantic_truth`, which is marked `-- DEPRECATED (Task 769, 2026-01-30)`. The deprecation note explicitly states:

> Use `semantic_weak_completeness` instead for sorry-free completeness.

The theorem is only needed by `valid_implies_semantic_truth` and `sorry_free_weak_completeness`. These are alternative (deprecated) completeness paths.

**Recommendation**: Archive `truth_at_implies_semantic_truth`, `valid_implies_semantic_truth`, and `sorry_free_weak_completeness` to `Boneyard/Metalogic_v4/FMP/`. Include documentation from the extensive docstrings already present.

---

### Sorry #3: finite_model_property_constructive (Line 233)

**Location**: `Theories/Bimodal/Metalogic/FMP/FiniteModelProperty.lean:233`

```lean
theorem finite_model_property_constructive (φ : Formula) (h_sat : formula_satisfiable φ) :
    ∃ (F : TaskFrame Int) (M : TaskModel F) (τ : WorldHistory F) (t : Int)
      (_h_finite : Finite F.WorldState)
      (_h_fintype : Fintype F.WorldState),
      truth_at M τ t φ ∧
      Fintype.card F.WorldState ≤ 2 ^ (closureSize φ) := by
  ...
    sorry  -- truth bridge gap
```

**Purpose**: Constructive FMP with explicit model and cardinality bounds. The sorry is the "truth bridge" - proving `truth_at (SemanticCanonicalModel φ) tau 0 φ`.

**Why it's sorry'd**: This requires proving the forward truth lemma (`truth_at_implies_semantic_truth`), which is architecturally impossible (see Sorry #2).

**Mathematical Analysis**:
The proof constructs:
1. A ClosureMaximalConsistent set S containing φ
2. A FiniteWorldState from S
3. A FiniteHistory and WorldHistory
4. A SemanticWorldState

But then it needs to show `truth_at M τ 0 φ`. This is the exact same gap as Sorry #2 - connecting recursive truth evaluation to assignment truth.

**Elimination Strategy**: The theorem is marked `-- DEPRECATED (Task 769, 2026-01-30)`:

> Use `semantic_weak_completeness` for sorry-free completeness.

The module docstring also states:

> **Known Sorry**: The truth bridge connecting finite model truth to general `truth_at`
> is sorry'd. The core completeness is provided by `semantic_weak_completeness`.

**Recommendation**: Archive `finite_model_property_constructive` to `Boneyard/Metalogic_v4/FMP/`. Keep `finite_model_property` (non-constructive, trivially true) and `semanticWorldState_card_bound` (cardinality bound, sorry-free).

---

## Dependency Analysis

### What Uses the Deprecated Code

| Deprecated Theorem | Used By | Can Archive? |
|--------------------|---------|--------------|
| `SemanticCanonicalFrame` | `SemanticCanonicalModel`, `finiteHistoryToWorldHistory`, `semantic_world_state_has_world_history`, `sorry_free_weak_completeness` | YES - all deprecated |
| `truth_at_implies_semantic_truth` | `valid_implies_semantic_truth` | YES |
| `valid_implies_semantic_truth` | `sorry_free_weak_completeness` | YES |
| `sorry_free_weak_completeness` | `weak_completeness` in WeakCompleteness.lean | NEEDS REFACTORING |
| `finite_model_property_constructive` | None (standalone theorem) | YES |

### Critical Dependency: weak_completeness

The file `Theories/Bimodal/Metalogic/Completeness/WeakCompleteness.lean` contains:

```lean
theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ := by
  intro h_valid
  have h_deriv := sorry_free_weak_completeness φ h_valid
  exact ⟨h_deriv⟩
```

This uses `sorry_free_weak_completeness`, which has the sorry chain. However, the **true** sorry-free theorem is `semantic_weak_completeness`, which has a different signature:

```lean
def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi), semantic_truth_at_v2 phi w origin phi) → ⊢ phi
```

**Refactoring Required**: To achieve zero-sorry, we need to either:

1. **Option A**: Remove `weak_completeness` and document that `semantic_weak_completeness` is the canonical completeness result (with its own validity notion)

2. **Option B**: Prove a direct bridge from `valid phi` to `∀ w, semantic_truth_at_v2 phi w origin phi` without going through `truth_at_implies_semantic_truth`

3. **Option C**: Accept that the public `valid phi → provable phi` theorem will remain sorry-dependent, while the internal metalogic is sorry-free

### Recommended Approach: Option A

The fundamental issue is that `valid phi` quantifies over ALL models (universal over D, F, M, τ, t), while `semantic_weak_completeness` only needs truth at SemanticWorldStates.

The gap between "valid in all models" and "true at all SemanticWorldStates" IS the truth lemma gap. There's no avoiding it without the forward truth lemma.

**Recommended Resolution**:

1. Archive all deprecated code
2. Keep `semantic_weak_completeness` as THE completeness theorem
3. Update `WeakCompleteness.lean` to document:
   - The `valid → provable` equivalence inherits the architectural sorry
   - The `semantic_weak_completeness` provides the core result
   - Users needing completeness should use the semantic formulation

---

## Complete Archival Plan

### Files to Modify in SemanticCanonicalModel.lean

**Archive to Boneyard** (with deprecation headers):
1. `SemanticCanonicalFrame` (lines 226-233)
2. `SemanticCanonicalModel` (lines 246-248)
3. `finiteHistoryToWorldHistory` (lines 279-302)
4. `semantic_world_state_has_world_history` (lines 317-332)
5. `truth_at_atom_iff_semantic` (lines 561-575)
6. `truth_at_bot_iff_semantic` (lines 580-595)
7. `truth_at_implies_semantic_truth` (lines 664-695)
8. `valid_implies_semantic_truth` (lines 702-715)
9. `valid_implies_neg_unsatisfiable` (lines 744-753)
10. `set_mcs_neg_excludes_helper` (lines 758-760)
11. `sorry_free_weak_completeness` (lines 797-801)

**Keep** (sorry-free and used):
- `HistoryTimePair`, `htEquiv`, `htSetoid`
- `SemanticWorldState` and all its lemmas
- `semantic_task_rel`, `semantic_task_rel_nullity` (used internally)
- `semantic_valuation` (used by semantic_truth_at_v2)
- `semantic_truth_at`, `semantic_truth_at_v2`
- `semantic_truth_lemma_v2`, `semantic_truth_lemma`
- `neg_set_consistent_of_not_provable`, `phi_consistent_of_not_refutable`
- **`semantic_weak_completeness`** (THE key theorem)
- `semanticWorldState_card_bound`

### Files to Modify in FiniteModelProperty.lean

**Archive to Boneyard**:
1. `finite_model_property_constructive` (lines 161-235)

**Keep** (sorry-free):
- `finite_model_property` (trivially true)
- `satisfiability_decidable`
- `consistent_implies_satisfiable`
- `validity_decidable_via_fmp`

### Files to Modify in WeakCompleteness.lean

**Modify** `weak_completeness` to document the architectural limitation:

```lean
/--
**Weak Completeness**: Valid formulas are provable from the empty context.

**ARCHITECTURAL NOTE**: This theorem depends on `sorry_free_weak_completeness` which
has an architectural sorry in the truth bridge. For a truly sorry-free completeness
result, use `semantic_weak_completeness` from FMP/SemanticCanonicalModel.lean which
proves: `(∀ w : SemanticWorldState φ, semantic_truth_at_v2 φ w t φ) → ⊢ φ`

The gap is fundamental: `valid φ` quantifies over ALL models, while
`semantic_truth_at_v2` only refers to SemanticWorldStates. Bridging this
requires the forward truth lemma, which is impossible due to Box semantics.
-/
theorem weak_completeness (φ : Formula) : valid φ → ContextDerivable [] φ := by
  intro h_valid
  -- NOTE: Uses sorry_free_weak_completeness which has architectural sorry.
  -- The sorry-free core is semantic_weak_completeness.
  have h_deriv := sorry_free_weak_completeness φ h_valid
  exact ⟨h_deriv⟩
```

---

## Alternative: Pure Refactoring (No Archival)

If archiving is undesirable, an alternative is:

1. **Mark all deprecated theorems with `@[deprecated]` attribute** (Lean 4 style)
2. **Add linter exception comments** to allow sorries in deprecated code
3. **Update documentation** to clearly state the sorry-free path

This preserves the code for reference while making the architecture clear.

---

## Conclusion

The 3 sorries in Metalogic FMP are:

| # | Location | Type | Recommended Action |
|---|----------|------|-------------------|
| 1 | compositionality | Mathematical impossibility | Archive to Boneyard |
| 2 | truth_at_implies_semantic_truth | Architectural limitation | Archive to Boneyard |
| 3 | finite_model_property_constructive | Depends on #2 | Archive to Boneyard |

**The main completeness theorem `semantic_weak_completeness` is already sorry-free.**

To achieve zero-sorry in Metalogic/:
1. Archive deprecated code to `Boneyard/Metalogic_v4/FMP/`
2. Update documentation to point to sorry-free alternatives
3. Accept that `valid → provable` in full generality inherits the sorry (or document it as an architectural limitation)

**Estimated Effort**: 2-4 hours for archival and documentation updates.

---

## References

- Task 750: Original research on truth bridge gap
- Task 769: Sorry audit and deprecation marking
- Task 772: Refactoring to sorry-free architecture
- `Boneyard/Metalogic_v3/FailedTruthLemma/` - Previous failed attempts
