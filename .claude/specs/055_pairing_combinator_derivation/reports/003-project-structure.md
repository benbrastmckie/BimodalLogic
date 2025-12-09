# Research Report: Project Structure for Pairing Combinator Implementation

## Executive Summary

This report documents the relevant project structure, existing code patterns, and implementation conventions for adding the pairing combinator derivation to the Logos project. The derivation should be added to `Perpetuity.lean` where the `pairing` axiom is currently defined.

## Research Context

### Task Overview

**From TODO.md, Task 21**:
> Derive the `pairing` axiom (`⊢ A.imp (B.imp (A.and B))`) from K and S propositional axioms using combinator calculus. Strategy: Build S(S(KS)(S(KK)I))(KI) where I=SKK.

**Current Status**: SKIPPED (per plan recommendation)
**Priority**: Low (optional, adds no mathematical insight)

## Finding 1: Current Axiom Location

### File Location

The `pairing` axiom is defined in:
```
/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean
```

### Current Definition (Line ~171)

```lean
/--
Pairing combinator: `⊢ A → B → A ∧ B`.

This is the internal form of conjunction introduction. Given values of types
A and B, we can construct a value of type A ∧ B.

**Semantic Justification**: In task semantics, if A holds at (M,τ,t) and B holds
at (M,τ,t), then A ∧ B = ¬(A → ¬B) holds because assuming (A → ¬B) with A gives ¬B,
contradicting B.

**Implementation Note**: This can be constructed from K and S combinators
(λa.λb.λf. f a b = S (S (K S) (S (K K) I)) (K I) where I = SKK), but the
construction is complex (~50+ lines of combinator manipulation) and would obscure
the proof. We axiomatize it with semantic justification for MVP. The derivation
is straightforward in principle but tedious in practice.

**Future Work**: Derive fully from S and K axioms using combinator calculus.
The pattern requires building the application combinator step-by-step through
nested S and K applications.
-/
axiom pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B))
```

## Finding 2: Related Code Patterns

### Existing Combinator Derivations

The project already has several combinator-style proofs:

**Identity Combinator (SKK)** (Lines ~106-112):
```lean
theorem identity (A : Formula) : ⊢ A.imp A := by
  have k1 : ⊢ A.imp ((A.imp A).imp A) := Derivable.axiom [] _ (Axiom.prop_s A (A.imp A))
  have k2 : ⊢ A.imp (A.imp A) := Derivable.axiom [] _ (Axiom.prop_s A A)
  have s : ⊢ (A.imp ((A.imp A).imp A)).imp ((A.imp (A.imp A)).imp (A.imp A)) :=
    Derivable.axiom [] _ (Axiom.prop_k A (A.imp A) A)
  have h1 : ⊢ (A.imp (A.imp A)).imp (A.imp A) := Derivable.modus_ponens [] _ _ s k1
  exact Derivable.modus_ponens [] _ _ h1 k2
```

**B Combinator (Composition)** (Lines ~125-135):
```lean
theorem b_combinator {A B C : Formula} : ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C)) := by
  have s_axiom : ⊢ (B.imp C).imp (A.imp (B.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_s (B.imp C) A)
  have k_axiom : ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_k A B C)
  exact imp_trans s_axiom k_axiom
```

**Contraposition** (Lines ~338-420+):
```lean
theorem contraposition {A B : Formula}
    (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := by
  -- Uses B combinator with detailed construction
  -- ~80 lines of proof
```

### Pattern Analysis

All combinator derivations follow a consistent pattern:
1. Instantiate axioms with appropriate formula substitutions
2. Use `imp_trans` to chain implications
3. Apply `Derivable.modus_ponens` to eliminate implications
4. Build up to the target formula step by step

## Finding 3: Test Infrastructure

### Test File Location

Tests for Perpetuity theorems are in:
```
/home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Theorems/PerpetuityTest.lean
```

### Existing Test Patterns

From PerpetuityTest.lean (expected patterns):
```lean
-- Example instantiations
example (p : String) : ⊢ (Formula.atom p).box.imp (Formula.atom p).always :=
  perpetuity_1 (Formula.atom p)

-- Compound formula tests
example (p q : Formula) : ⊢ (p.and q).box.imp (p.and q).always :=
  perpetuity_1 (p.and q)
```

### Required Tests for Pairing

When deriving pairing, add tests:
```lean
-- Basic instantiation
example (p q : String) : ⊢ (Formula.atom p).imp ((Formula.atom q).imp ((Formula.atom p).and (Formula.atom q))) :=
  pairing (Formula.atom p) (Formula.atom q)

-- Compound formulas
example (p q r : Formula) : ⊢ p.imp (q.imp (p.and q)) :=
  pairing p q

-- Nested conjunctions
example (p q r : Formula) : ⊢ p.imp ((q.and r).imp (p.and (q.and r))) :=
  pairing p (q.and r)
```

## Finding 4: Documentation Requirements

### Code Documentation Standards

From LEAN_STYLE_GUIDE.md, each theorem requires:
1. Short description line
2. Mathematical statement in backticks
3. Proof sketch or strategy
4. Implementation notes (if non-obvious)
5. References to related lemmas/axioms

### Documentation Template for Pairing

```lean
/--
Pairing combinator derived from K and S axioms: `⊢ A → B → A ∧ B`.

This theorem replaces the previous `pairing` axiom with a syntactic derivation
using only the propositional axioms K (weakening) and S (distribution).

**Derivation Strategy**:
1. Build flip combinator (C): `(A → B → C) → B → A → C`
2. Build single application: `A → (A → B) → B`
3. Build double application: `A → B → (A → B → C) → C`
4. Specialize to C = ⊥: `A → B → (A → B → ⊥) → ⊥ = A → B → A ∧ B`

**Combinator Correspondence**:
- Flip (C) = S(BBS)(KK) where B = S(KS)K
- The proof structure mirrors the SKI derivation of V = λx.λy.λf.(f x y)

**References**:
- `b_combinator`: Used for composition in flip derivation
- `identity`: The I combinator (SKK) used in intermediate steps
-/
theorem pairing (A B : Formula) : ⊢ A.imp (B.imp (A.and B)) := by
  -- implementation
```

## Finding 5: Build and Lint Requirements

### Build Commands

```bash
# Full build
lake build

# Type-check specific file
lake env lean Logos/Core/Theorems/Perpetuity.lean

# Run tests
lake test

# Run linter
lake lint
```

### Lint Requirements

From QUALITY_METRICS.md:
- Zero `#lint` warnings required
- 100% docBlame/docBlameThm coverage
- No unused imports or definitions

### Pre-commit Checklist

Before committing pairing derivation:
1. `lake build` succeeds
2. `lake test` passes
3. `lake lint` has no warnings
4. All helper lemmas have docstrings
5. Test coverage added to PerpetuityTest.lean

## Finding 6: Dependencies and Imports

### Current Imports in Perpetuity.lean

```lean
import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Formula
```

### No Additional Imports Needed

The derivation uses only:
- `Axiom.prop_k` (S combinator) - from Derivation.lean
- `Axiom.prop_s` (K combinator) - from Derivation.lean
- `Derivable` type and constructors - from Derivation.lean
- `Formula` type - from Formula.lean

All required infrastructure is already imported.

## Finding 7: Risk Assessment

### Low Risk

- **Type errors**: The target type is clear, Lean will catch mismatches
- **Test failures**: Existing tests independent of pairing implementation
- **Breaking changes**: Replacing axiom with theorem preserves API

### Medium Risk

- **Proof complexity**: May exceed estimated 40-55 lines
- **Readability**: Complex combinator proofs can be opaque
- **Time overrun**: Intricate derivations prone to subtle errors

### Mitigation

1. Build incrementally with small PRs
2. Test each helper lemma before proceeding
3. Add extensive comments explaining each step
4. Set time-box of 4 hours; fall back to axiom if exceeded

## Recommendations

### Recommendation 1: Implementation Location

Place all new lemmas in Perpetuity.lean after the `identity` and `b_combinator` lemmas, before the `pairing` axiom. When complete, replace the axiom with the theorem.

### Recommendation 2: Naming Convention

Follow existing patterns:
- `flip` or `c_combinator` for the C combinator
- `app1` or `apply_single` for single application
- `app2` or `apply_double` for double application
- Keep `pairing` as the main theorem name (API compatibility)

### Recommendation 3: Incremental Commits

1. Commit 1: Add `flip` lemma with tests
2. Commit 2: Add `app1` lemma with tests
3. Commit 3: Add `app2` lemma with tests
4. Commit 4: Replace `axiom pairing` with `theorem pairing`
5. Commit 5: Update documentation

### Recommendation 4: Time-Box Decision

If after 4 hours the derivation is incomplete:
1. Keep axiom with enhanced documentation
2. Document attempted approach and blocking issues
3. Mark as future work with clear specification

## References

### Project Files

- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean` - Main implementation file
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Theorems/PerpetuityTest.lean` - Test file
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean` - Axiom definitions
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Development/LEAN_STYLE_GUIDE.md` - Style conventions

### Documentation Files

- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md` - Task tracking
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md` - Status tracking
- `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/.claude/specs/047_remove_derivable_axioms_perpetuity/plans/001-remove-derivable-axioms-perpetuity-plan.md` - Prior analysis
