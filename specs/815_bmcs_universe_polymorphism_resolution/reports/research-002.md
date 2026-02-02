# Research Report: BMCS Universe Polymorphism Resolution (Follow-up)

- **Task**: 815 - BMCS Universe Polymorphism Resolution
- **Started**: 2026-02-02T21:41:12Z
- **Completed**: 2026-02-02T21:50:00Z
- **Effort**: 15 minutes
- **Dependencies**: research-001.md (initial analysis), implementation-001.md (Solution A plan)
- **Sources/Inputs**:
  - Completeness.lean (proof structure and strategy)
  - BMCSTruth.lean (validity definitions)
  - Validity.lean (standard semantics)
  - Codebase grep for API usage
- **Artifacts**: specs/815_bmcs_universe_polymorphism_resolution/reports/research-002.md
- **Standards**: report-format.md, artifact-management.md

## Project Context
- **Upstream Dependencies**: `bmcs_truth_at`, `bmcs_representation`, BMCS construction
- **Downstream Dependents**: `bmcs_weak_completeness`, `bmcs_strong_completeness` (the main completeness theorems)
- **Alternative Paths**: Standard validity in Semantics/Validity.lean (already uses `Type`, not `Type*`)
- **Potential Extensions**: Eventually connect BMCS validity to standard validity via soundness

## Executive Summary

- The polymorphic API (`bmcs_valid` and `bmcs_consequence` with `Type*`) is used ONLY internally by the two completeness theorems; there are no external callers
- Completeness requires constructing ONE countermodel when `¬derivable φ`; Int provides all necessary structure (AddCommGroup, LinearOrder, IsOrderedAddMonoid)
- **Standard validity** (Semantics/Validity.lean) already uses `Type` (not `Type*`), establishing precedent for universe-monomorphic definitions
- **Solution A is strongly recommended**: Change `Type*` → `Type` in both definitions
- **Solution B (eliminate API entirely)** is technically viable but offers no advantage over Solution A

## Context & Scope

This follow-up research compares Solution A (keep API with `Type`) vs Solution B (eliminate polymorphic API) for Task 815, which aims to resolve 2 universe polymorphism sorries in BMCS completeness.

**Key questions addressed**:
1. Is Int sufficient for completeness?
2. What does the polymorphic API buy us?
3. Who uses `bmcs_valid` and `bmcs_consequence`?
4. What are the architectural implications?

## Findings

### Completeness Proof Strategy (from Completeness.lean)

The completeness theorems use **contraposition**:

1. **Weak Completeness** (`bmcs_weak_completeness`): `bmcs_valid φ → ⊢ φ`
   - Proof: If `⊬ φ`, then `[¬φ]` is consistent (line 171-186)
   - By representation, ∃ BMCS where `¬φ` is true at Int (line 215)
   - Therefore `φ` is not valid (line 217-223)
   - Contrapositive: if valid, then derivable

2. **Strong Completeness** (`bmcs_strong_completeness`): `bmcs_consequence Γ φ → Γ ⊢ φ`
   - Proof: If `Γ ⊬ φ`, then `Γ ∪ {¬φ}` is consistent (line 312-346)
   - By context representation, ∃ BMCS where Γ is satisfied but φ is false (line 363-381)
   - Therefore φ is not a consequence of Γ
   - Contrapositive: if consequence, then derivable

**Critical observation**: Both proofs construct countermodels at `Int` specifically (line 100, 119). The polymorphic quantification over all types is never exploited.

### Is Int Sufficient?

**Yes, Int provides all required structure for completeness**:

| Type Class | Instance | Verification |
|------------|----------|--------------|
| `AddCommGroup Int` | Verified in research-001.md | ✓ Mathlib |
| `LinearOrder Int` | Verified in research-001.md | ✓ Mathlib |
| `IsOrderedAddMonoid Int` | Verified in research-001.md | ✓ Mathlib |

**Why Int suffices**:
- Completeness is existential: "if consistent, then ∃ model"
- The BMCS construction at Int provides exactly ONE satisfying model
- We never need models at higher universes (Type 1, Type 2, etc.)

### Polymorphic API Usage Analysis

**grep results for `bmcs_valid`**:
- **Defined at**: BMCSTruth.lean:108 (polymorphic: `Type*`)
- **Used at**: Completeness.lean:153, 234, 247 (only these 3 locations)
  - Line 153: `bmcs_valid_implies_valid_Int` lemma (sorry)
  - Line 234: `bmcs_not_valid_of_not_derivable` internal helper
  - Line 247: `bmcs_weak_completeness` theorem (the main export)
- **External callers**: NONE (only Metalogic.lean, which is a documentation file)

**grep results for `bmcs_consequence`**:
- **Defined at**: Completeness.lean:267 (polymorphic: `Type*`)
- **Used at**: Completeness.lean:289, 392, 406 (only these 3 locations)
  - Line 289: `bmcs_consequence_implies_consequence_Int` lemma (sorry)
  - Line 392: `bmcs_not_consequence_of_not_derivable` internal helper
  - Line 406: `bmcs_strong_completeness` theorem (the main export)
- **External callers**: NONE (only Metalogic.lean, which is documentation)

**Conclusion**: The polymorphic API is used purely as an internal abstraction layer between:
1. The Int-specific countermodel construction (`bmcs_representation`)
2. The exported completeness theorems

### Standard Validity Definition Precedent

The standard validity definition in `Semantics/Validity.lean` uses **`Type` (not `Type*`)**:

```lean
-- Validity.lean:61 (with comment at line 59)
-- Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs.
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (τ : WorldHistory F) (t : D),
    truth_at M τ t φ
```

**Significance**: The codebase already has a precedent for using `Type` in validity definitions to avoid universe issues. The `bmcs_valid` definition is the outlier.

### Architectural Alignment

| Aspect | bmcs_valid (current) | valid (standard) | Alignment |
|--------|---------------------|------------------|-----------|
| Universe level | `Type*` | `Type` | ✗ Misaligned |
| Quantification | All types | All types (at Type 0) | ✓ Both universal |
| Type classes | Same | Same | ✓ Same requirements |
| Purpose | Completeness | Soundness | ✓ Complementary |

**Design issue**: The two validity notions should eventually connect via soundness theorems:
```
⊢ φ  ↔  bmcs_valid φ  →  valid φ
      (completeness)    (soundness)
```

Currently, the universe mismatch (`Type*` vs `Type`) makes this connection awkward.

## Solution Comparison

### Solution A: Type* → Type (RECOMMENDED)

**Changes**:
1. BMCSTruth.lean:109: `(D : Type*)` → `(D : Type)`
2. Completeness.lean:268: `(D : Type*)` → `(D : Type)`
3. Completeness.lean:160, 292: Replace `sorry` with `exact h Int B fam hfam t ...`

**Pros**:
- Minimal change (3 characters in 2 locations + 2 proof completions)
- Aligns with standard `valid` definition precedent
- Makes sorries trivially provable
- Preserves API surface (backward compatible)
- Enables future soundness connection

**Cons**:
- Technically "loses" polymorphism over Type 1, Type 2, etc.
- But these higher universes are never used in completeness

**Impact**:
- Files modified: 2 (BMCSTruth.lean, Completeness.lean)
- External API: Unchanged (no external callers exist)
- Build: Expected to succeed cleanly (research-001 verified)

### Solution B: Eliminate Polymorphic API

**Changes**:
1. Remove `bmcs_valid` definition from BMCSTruth.lean
2. Remove `bmcs_consequence` definition from Completeness.lean
3. Remove `bmcs_valid_implies_valid_Int` lemma (line 153-160)
4. Remove `bmcs_consequence_implies_consequence_Int` lemma (line 288-292)
5. Rewrite `bmcs_weak_completeness` to use `bmcs_valid_Int` directly
6. Rewrite `bmcs_strong_completeness` to use `bmcs_consequence_Int` directly

**Pros**:
- Removes the problematic lemmas entirely
- Clearer that completeness is Int-specific
- Fewer lines of code overall

**Cons**:
- More invasive change (6 distinct modifications)
- Loses the conceptual abstraction layer
- Makes the API surface less general (though no external users exist)
- Breaks symmetry with `valid` definition in Semantics
- Harder to document soundness theorems ("bmcs_valid_Int → valid" is less elegant)

**Impact**:
- Files modified: 2 (same as Solution A)
- External API: Technically breaks API, but no callers exist
- Future soundness connection: Awkward (`bmcs_valid_Int` vs `valid`)

### Decision Matrix

| Criterion | Solution A | Solution B |
|-----------|-----------|-----------|
| Lines changed | 4 (2 defs + 2 proofs) | ~20 (remove defs + rewrite theorems) |
| Backward compatible | Yes | No (but no external users) |
| Aligns with Validity.lean | Yes | No (breaks symmetry) |
| Proof complexity | Trivial | Moderate (rewrite theorems) |
| Future extensibility | High | Low |
| Conceptual clarity | Preserves abstraction | More explicit |

## Decisions

1. **Recommend Solution A** based on:
   - Minimal change principle
   - Alignment with existing `valid` definition
   - Preservation of API abstraction for future soundness work
   - Backward compatibility (even though no external users exist today)

2. **Reject Solution B** because:
   - More invasive with no compensating advantage
   - Breaks architectural symmetry with standard semantics
   - Makes future soundness theorems less elegant

## Recommendations

### Primary Recommendation: Implement Solution A

**Action**: Execute implementation-001.md as written (already based on Solution A)

**Rationale**:
1. The `Type*` → `Type` change has precedent in the codebase (Validity.lean)
2. Int provides all necessary structure for completeness
3. Polymorphism over Type 1+ is mathematically unnecessary
4. Preserves symmetry with standard validity definition
5. Enables clean future work on soundness theorems

**Estimated effort**: 1 hour (as planned)

### Secondary Recommendation: Add Documentation

After implementing Solution A, add a comment to BMCSTruth.lean explaining the universe choice:

```lean
/--
BMCS validity: a formula is valid iff true everywhere in every BMCS.

Note: Uses `Type` (not `Type*`) to avoid universe level issues in proofs,
following the precedent of `valid` in Semantics/Validity.lean. Since
completeness constructs countermodels at Int : Type, polymorphism over
higher universes (Type 1, Type 2, ...) is mathematically unnecessary.
-/
def bmcs_valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D],
  ∀ (B : BMCS D), ∀ fam ∈ B.families, ∀ t : D, bmcs_truth_at B fam t φ
```

## Risks & Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Other code depends on Type* | Very Low | Medium | Verified via grep: no external callers |
| Type change breaks other proofs | Very Low | High | Research-001 verified Int instances exist |
| Future needs Type 1+ models | Low | Low | Can revert if needed; documented decision |

## Appendix

### Files Analyzed

1. **Completeness.lean** (477 lines)
   - Lines 143-160: `bmcs_valid_Int` definition and sorry
   - Lines 267-292: `bmcs_consequence` definitions and sorry
   - Lines 247-252: `bmcs_weak_completeness` theorem
   - Lines 405-411: `bmcs_strong_completeness` theorem

2. **BMCSTruth.lean** (336 lines)
   - Lines 108-110: `bmcs_valid` definition with `Type*`

3. **Validity.lean** (lines 50-130)
   - Line 61-64: `valid` definition with `Type` (precedent)
   - Line 59 comment: Explicitly notes avoiding `Type*`

### Search Queries Used

```bash
# Usage of bmcs_valid
grep -rn "bmcs_valid" Theories/Bimodal/Metalogic/

# Usage of bmcs_consequence
grep -rn "bmcs_consequence" Theories/Bimodal/Metalogic/

# Standard validity definition
grep -n "def valid" Theories/Bimodal/Semantics/Validity.lean
```

### References

- Initial research: specs/815_bmcs_universe_polymorphism_resolution/reports/research-001.md
- Implementation plan: specs/815_bmcs_universe_polymorphism_resolution/plans/implementation-001.md
- Lean 4 documentation: Universe polymorphism
- Project architecture: Theories/Bimodal/Metalogic/Metalogic.lean

### Key Insights

1. **Completeness is existential**: We only need ONE countermodel (at Int) to refute validity
2. **Polymorphism is overkill**: Quantifying over all universes adds complexity without benefit
3. **Precedent exists**: The standard `valid` definition already uses `Type` successfully
4. **No external dependencies**: The API is purely internal to completeness proofs
5. **Soundness connection matters**: Future work will connect bmcs_valid → valid, and universe alignment helps
