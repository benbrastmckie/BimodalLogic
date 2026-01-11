# Research Report: Task #365

**Task**: Complete BimodalTest sorries
**Date**: 2026-01-11
**Focus**: Analyze sorry placeholders in BimodalTest files and determine implementation path

## Summary

The BimodalTest directory contains 5 actual sorry placeholders across 3 files (CompletenessTest.lean, PerpetuityTest.lean, PropositionalTest.lean). The ModalS4Test.lean file mentioned in the task description has **no sorries** - its tests are commented out but the implementation is complete. The sorries fall into three categories: infrastructure-pending proofs, impossible-without-premises tests, and context manipulation gaps.

## Findings

### 1. CompletenessTest.lean (3 sorries)

**Location**: Lines 51, 65, 83

**Nature**: Consistency proof examples that test the `Consistent` definition.

| Line | Test | Description |
|------|------|-------------|
| 51 | `Consistent []` | Prove empty context is consistent |
| 65 | `Consistent [p]` | Prove single atom context is consistent |
| 83 | `¬Consistent [p, ¬p]` | Prove contradiction is inconsistent |

**Analysis**: These test consistency properties defined in `Bimodal/Metalogic/Completeness.lean`. The proofs require showing:
- Line 51/65: No derivation of `⊥` exists from the given context
- Line 83: A derivation of `⊥` *can* be constructed from `[p, ¬p]`

**Implementation Path**:
- Line 83 (inconsistency): **Implementable now** - can derive `⊥` from `[p, ¬p]` using:
  1. `assumption` to get `p`
  2. `assumption` to get `¬p`
  3. Apply negation elimination (¬p is p → ⊥)
  4. Modus ponens gives `⊥`

- Lines 51/65 (consistency): **Requires meta-reasoning** about non-existence of derivations. These genuinely require completeness infrastructure (non-provability implies consistency via completeness). Could be marked as documentation-only tests.

### 2. PerpetuityTest.lean (1 sorry)

**Location**: Line 76

**Test**: `⊢ ((Formula.atom "p").and (Formula.atom "q")).box`

**Analysis**: This test attempts to derive `□(p ∧ q)` from an empty context. This is **logically impossible** - you cannot prove that atomic propositions are necessary without additional axioms or premises.

**Implementation Path**:
- **Option A**: Remove the example (it's testing an impossible goal)
- **Option B**: Change to parametric example with hypotheses:
  ```lean
  example (hp : ⊢ p.box) (hq : ⊢ q.box) : ⊢ (p.and q).box := box_conj_intro hp hq
  ```
- The type signature test directly above (line 60-61) already verifies `box_conj_intro` works correctly.

### 3. PropositionalTest.lean (1 sorry)

**Location**: Line 193

**Test**: `[(Formula.atom "p").and (Formula.atom "q")] ⊢ (Formula.atom "p").or (Formula.atom "r")`

**Analysis**: The goal is to derive `p ∨ r` from `[p ∧ q]`. We have:
- `lce (p) (q)` gives `[p ∧ q] ⊢ p`
- `ldi p r` gives `[p] ⊢ p ∨ r`

The gap is transitioning from context `[p ∧ q]` to applying `ldi` which expects `[p]` as context.

**Implementation Path**:
- The `DerivationTree.weakening` constructor exists and can extend contexts
- Need either:
  - A "cut" or substitution lemma that composes derivations with different contexts
  - Use deduction theorem: `[p ∧ q] ⊢ p → p ∨ r` combined with `[p ∧ q] ⊢ p`

**Approach**: Use `ldi_imp` if available, or construct via:
```lean
have hp : [p ∧ q] ⊢ p := lce p q
have himp : ⊢ p.imp (p.or r) := ldi_imp p r  -- Need this helper
-- Then apply modus ponens in context
```

### 4. ModalS4Test.lean (NO sorries)

**Analysis**: Despite the task description, ModalS4Test.lean has **no sorry placeholders**. The tests are commented out with `--` but the actual implementation in `Bimodal/Theorems/ModalS4.lean` is complete:

| Theorem | Status |
|---------|--------|
| `s4_diamond_box_conj` | Fully proven (lines 64-141) |
| `s4_box_diamond_box` | Fully proven (lines 143-164) |
| `s4_diamond_box_diamond` | Fully proven (lines 166-297) |
| `s5_diamond_conj_diamond` | Fully proven (lines 299-466) |

**Compilation Issue**: ModalS4.lean has 2 errors:
- `s4_diamond_box_conj` depends on noncomputable `rce_imp`
- `s5_diamond_conj_diamond` depends on noncomputable `lce_imp`

**Fix**: Add `noncomputable` to these definitions or mark the entire section as noncomputable.

### 5. Additional: Completeness.lean (1 sorry)

**Location**: `provable_iff_valid` at line 369

**Nature**: Converts from `semantic_consequence [] φ` to `valid φ`. This should be definitionally equal or require a simple lemma.

## Recommendations

### Priority 1: Quick Wins (30 min)
1. **PerpetuityTest.lean line 76**: Remove impossible test or convert to parametric form
2. **ModalS4Test.lean**: Uncomment tests after fixing `noncomputable` in ModalS4.lean
3. **ModalS4.lean compilation**: Add `noncomputable` markers to fix dependency errors

### Priority 2: Moderate Effort (1-2 hours)
4. **CompletenessTest.lean line 83**: Implement inconsistency proof for `[p, ¬p]`
5. **PropositionalTest.lean line 193**: Implement context composition using deduction theorem helpers

### Priority 3: docs/Defer (optional)
6. **CompletenessTest.lean lines 51, 65**: Mark as documentation-only tests (consistency proofs require meta-level reasoning about non-derivability)

## References

- `BimodalTest/Metalogic/CompletenessTest.lean` - Consistency tests
- `BimodalTest/Theorems/PerpetuityTest.lean` - Perpetuity principle tests
- `BimodalTest/Theorems/PropositionalTest.lean` - Propositional theorem tests
- `BimodalTest/Theorems/ModalS4Test.lean` - S4 theorem tests (commented out)
- `Bimodal/Theorems/ModalS4.lean` - S4 implementation (complete, compilation issues)
- `Bimodal/Metalogic/Completeness.lean` - Completeness definitions and theorems
- `Bimodal/ProofSystem/Derivation.lean` - DerivationTree with weakening constructor

## Next Steps

1. Create implementation plan with three phases:
   - Phase 1: Fix ModalS4.lean compilation and uncomment ModalS4Test.lean tests
   - Phase 2: Resolve impossible/documentation-only tests (PerpetuityTest, CompletenessTest 51/65)
   - Phase 3: Implement remaining proofs (CompletenessTest 83, PropositionalTest 193)

2. Verify with `lake build` after each fix to ensure no regressions.
