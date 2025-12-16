# Phase 2 Implementation Summary: Derive P4 from P3 (PARTIAL - Iteration 2)

## Metadata

- **Date**: 2025-12-08
- **Phase**: 2 of 7
- **Status**: BLOCKED - Requires `A → ¬¬A` derivation
- **Lean File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`
- **Iteration**: 2
- **Lines Modified**: 585-747

## Objective

Replace `axiom perpetuity_4` with a complete `theorem perpetuity_4` by deriving P4 from contraposition of P3.

## Target Theorem

**P4**: `⊢ φ.sometimes.diamond → φ.diamond` (◇▽φ → ◇φ)

**Derivation Strategy** (from paper §3.2):
1. Apply P3 to `¬φ`: `⊢ □(¬φ) → □△(¬φ)`
2. Contrapose: `⊢ ¬□△(¬φ) → ¬□(¬φ)`
3. Simplify using formula definitions and double negation elimination
4. Result: `⊢ ◇▽φ → ◇φ`

## Changes Made

### 1. Added `box_dne` Helper Lemma (Lines 585-613)

**Theorem Signature**:
```lean
theorem box_dne {A : Formula}
    (h : ⊢ A.neg.neg.box) : ⊢ A.box
```

**Purpose**: Lift double negation elimination (DNE) into the modal box operator.

**Proof Strategy**:
1. DNE axiom: `⊢ ¬¬A → A`
2. Necessitation: `⊢ □(¬¬A → A)`
3. Modal K distribution: `⊢ □(¬¬A → A) → (□¬¬A → □A)`
4. Modus ponens chain

**Status**: ✓ COMPLETE (verified compiles)

### 2. Started `perpetuity_4` Derivation (Lines 615-747)

**Current Progress**:
- P3 for `¬φ` instantiated: `⊢ φ.neg.box → φ.neg.always.box`
- Contraposition applied: `⊢ φ.neg.always.box.neg → φ.neg.box.neg`
- DNE for always built: `⊢ φ.neg.always.neg.neg.box → φ.neg.always.box`

**Blocking Issue**: Formula Structure Mismatch

The goal is: `⊢ φ.sometimes.diamond → φ.diamond`

Expanding definitions:
- `φ.sometimes` = `φ.neg.always.neg`
- `φ.sometimes.diamond` = `(φ.neg.always.neg).neg.box.neg`
- `φ.diamond` = `φ.neg.box.neg`

We have:
1. `contraposed`: `⊢ φ.neg.always.box.neg → φ.neg.box.neg`
2. `box_dne_imp`: `⊢ φ.neg.always.neg.neg.box → φ.neg.always.box`

We need: `⊢ φ.neg.always.neg.neg.box.neg → φ.neg.always.box.neg`

But `contraposition box_dne_imp` gives us:
`⊢ φ.neg.always.box.neg → φ.neg.always.neg.neg.box.neg` (backwards!)

##  Root Cause Analysis

The fundamental issue is needing to derive:
**`⊢ φ.neg.always.neg.neg.box.neg → φ.neg.always.box.neg`**

This is equivalent to showing:
**`⊢ ¬□¬¬△¬φ → ¬□△¬φ`**

Which, by contraposition, requires:
**`⊢ □△¬φ → □¬¬△¬φ`**

Which, by modal K and necessitation, requires:
**`⊢ △¬φ → ¬¬△¬φ`**

This is the **double negation introduction** principle: **`A → ¬¬A`**

### Why `A → ¬¬A` is Non-Trivial

In Hilbert-style proof systems with only K and S axioms, deriving `A → ¬¬A` requires:
- `⊢ A → ((A → ⊥) → ⊥)`
- This is the **C combinator** (flip): λa.λn. n a
- Standard construction: `C = S (S (K S) K) (K K)` or similar complex combinator patterns

**Attempted Approaches** (all incomplete):
1. Direct S/K combinator construction (complex, ~100+ lines estimated)
2. Using existing `identity` and `b_combinator` (circular dependencies)
3. Leveraging `contraposition` lemma (requires `A → ¬¬A` itself!)

### Alternative Strategies Considered

1. **Axiomatize `A → ¬¬A`**:
   - Pro: Simple, semantically valid
   - Con: Adds axiom footprint

2. **Use `simp` tactics with DNE**:
   - Pro: Lean might automatically simplify
   - Con: Requires definitional equality, not just logical equivalence

3. **Restructure formula definitions**:
   - Pro: Could make DNE transparent
   - Con: Breaking change to core types

4. **Add excluded middle axiom**:
   - Pro: `A → ¬¬A` derivable from excluded middle
   - Con: Stronger axiom than needed

## Technical Debt

**Current State**:
- `perpetuity_4` has `sorry` at line 747
- `box_dne` helper lemma is complete and working
- Infrastructure for P4 derivation is 90% complete

**Missing Piece**: Single lemma `dni` (double negation introduction):
```lean
theorem dni (A : Formula) : ⊢ A.imp A.neg.neg
```

If this lemma is completed, the rest of the P4 proof can be finished in ~10-20 lines.

## Recommendations

### Option 1: Axiomatize DNI (RECOMMENDED for MVP)

**Justification**:
- `A → ¬¬A` is semantically valid in classical logic (TM uses classical semantics)
- The paper states P4 "follows from definitions and classical logic" (§3.2 lines 1070-1081)
- Adds minimal axiomatic footprint (1 axiom)
- Unblocks P4, P5, P6 derivations

**Implementation**:
```lean
/--
Double negation introduction: `A → ¬¬A` is valid in classical logic.

This principle is derivable from excluded middle but requires complex combinator
constructions in pure K/S systems. We axiomatize it with semantic justification.
-/
axiom dni (A : Formula) : ⊢ A.imp A.neg.neg
```

### Option 2: Complete C Combinator Derivation (Future Work)

**Estimated Effort**: 4-6 hours
**Complexity**: Very High
**Priority**: Low (no mathematical insight gained)

**Approach**:
- Build flip combinator: `S (S (K S) K) (K K)` or equivalent
- Verify it produces `A → (A → B) → B` pattern
- Instantiate with B = ⊥ to get `A → ¬¬A`

### Option 3: Keep P4 Axiomatized (Fallback)

If DNI derivation proves intractable and axiomatization is undesirable:
- Revert to `axiom perpetuity_4`
- Document attempted derivation approach
- Note as future work in IMPLEMENTATION_STATUS.md

## Build Verification

```bash
$ lake build Logos.Core.Theorems.Perpetuity
⚠ Warning: declaration uses 'sorry' (line 634)
✔ Build succeeded (with warnings)
```

**Status**: Compiles successfully, one expected sorry

## Impact Assessment

### Theorems Blocked

**Direct**:
- P4: `◇▽φ → ◇φ` (this theorem)

**Indirect** (if P4 remains incomplete):
- P5: `◇▽φ → △◇φ` (requires P4 as component)
- P6: `▽□φ → □△φ` (requires P5 via equivalence)

### Workaround for Downstream Phases

If P4 remains axiomatized/incomplete:
- Phases 3-4 (P5, P6) can still proceed using `axiom perpetuity_4`
- No blocking impact on other theorems
- Test suite can use axiomatized version

## Lessons Learned

1. **Syntactic vs. Semantic Equality**: Lean distinguishes definitional equality from logical equivalence. DNE is logical, not definitional.

2. **Combinator Complexity**: Pure K/S derivations of seemingly simple principles (like `A → ¬¬A`) can require intricate combinator constructions.

3. **Classical Logic Axioms**: TM's classical semantics justify axiomatizing classical principles even if syntactic derivation is complex.

4. **MVP Scoping**: For MVP completion, strategic axiomatization (with semantic justification) is preferable to spending excessive time on combinator derivations.

## Next Steps

### Immediate (Iteration 3)

1. **Decision Point**: Choose Option 1 (axiomatize DNI) or Option 3 (keep P4 axiomatized)
2. If Option 1: Add `dni` axiom, complete P4 proof (~10 lines)
3. If Option 3: Revert changes, document rationale, proceed to Phase 3

### Future Work

- Research standard Hilbert system derivations of `A → ¬¬A` from K/S
- Consider adding excluded middle axiom (stronger but cleaner)
- Explore simp lemmas for automatic DNE application

## References

### Source Files Modified
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean` (lines 585-747)

### Axioms Available
- `Axiom.double_negation`: `¬¬A → A` (DNE - opposite direction!)
- `Axiom.prop_k`: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))`
- `Axiom.prop_s`: `φ → (ψ → φ)`

### Helper Theorems Created
- `box_dne`: Apply DNE inside modal box (✓ complete)
- `contraposition`: Classical contraposition (✓ complete from Phase 1)
- `b_combinator`: Function composition (✓ complete from Phase 1)

---

**Phase 2 Status**: BLOCKED
**Blocking Issue**: Need `dni` lemma (double negation introduction)
**Recommended Action**: Axiomatize DNI with semantic justification (MVP path)
**Alternative**: Keep P4 axiomatized, document attempt, move to Phase 3
