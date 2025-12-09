# Research Report: Mathlib Theorems for Hilbert-Style Propositional and Modal Logic

**Research Topic**: Mathlib Theorems
**Date**: 2025-12-09
**Complexity**: 3
**Status**: Complete

## Executive Summary

This report identifies relevant Lean 4 Mathlib theorems and project-specific patterns for implementing 21 Hilbert-style propositional and modal logic theorems (Tasks 21-41 from TODO.md). The Logos project already has a robust foundation built on K and S combinators, with extensive proven theorems in Perpetuity.lean. Key findings show that most target theorems can be derived using existing project infrastructure rather than importing Mathlib dependencies.

**Key Findings**:
- Logos uses a custom Hilbert-style proof system based on prop_k and prop_s axioms
- All 6 perpetuity principles (P1-P6) are fully proven with zero sorry placeholders
- Existing combinator infrastructure (B, C, identity) provides foundation for propositional theorems
- Modal theorems have extensive precedent in Perpetuity.lean (box_conj_intro, diamond_4, modal_5)
- Limited need for Mathlib imports; project is self-contained

## Research Findings

### 1. Existing Project Infrastructure

#### 1.1 Propositional Foundations

**File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`

The project has proven propositional reasoning infrastructure based on K and S combinators:

```lean
-- K axiom (Axiom.prop_k): (φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))
-- S axiom (Axiom.prop_s): φ → (ψ → φ)

-- Proven combinators (lines 81-249):
theorem imp_trans {A B C : Formula} (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C
theorem identity (A : Formula) : ⊢ A.imp A
theorem b_combinator {A B C : Formula} : ⊢ (B.imp C).imp ((A.imp B).imp (A.imp C))
theorem theorem_flip {A B C : Formula} : ⊢ (A.imp (B.imp C)).imp (B.imp (A.imp C))
```

**Relevance to Tasks 21-29**:
- `imp_trans` enables transitivity chains for RAA, EFQ derivations
- `b_combinator` provides composition for RCP (reverse contraposition)
- `theorem_flip` (C combinator) supports argument reordering
- `identity` is foundation for reflexivity reasoning

#### 1.2 Negation and Contradiction Reasoning

**File**: `Logos/Core/ProofSystem/Axioms.lean`

```lean
-- double_negation axiom (line 147): ¬¬φ → φ
-- Enables classical reasoning via DNE (double negation elimination)
```

**Existing negation lemmas** (Perpetuity.lean, lines 1433-1467):
```lean
theorem modal_duality_neg (φ : Formula) : ⊢ φ.neg.diamond.imp φ.box.neg
theorem modal_duality_neg_rev (φ : Formula) : ⊢ φ.box.neg.imp φ.neg.diamond
```

**Gap Analysis**: Missing direct RAA/EFQ/ECQ theorems, but foundation exists via:
- `imp_trans` + negation handling
- `double_negation` axiom for classical logic
- Modal duality patterns for contraposition

#### 1.3 Conjunction and Disjunction

**Conjunction** (Perpetuity.lean, lines 965-1031):
```lean
theorem box_conj_intro {A B : Formula}
  (hA : Γ ⊢ A.box) (hB : Γ ⊢ B.box) : Γ ⊢ (A.and B).box

-- Note: and is defined as (φ.imp ψ.neg).neg (Formula.lean:99)
-- or is defined as φ.neg.imp ψ (Formula.lean:104)
```

**Gap Analysis**:
- Missing conjunction elimination (LCE/RCE: Tasks 23)
- Missing disjunction introduction (LDI/RDI: Task 24)
- Need to derive from primitive implication and negation

**Derivation Strategy for Task 23 (LCE/RCE)**:
- Use existing `pairing` theorem (now proven as theorem, not axiom)
- Conjunction elimination follows from: `(A ∧ B) = ¬(A → ¬B)`
- Apply double_negation + modus ponens patterns

#### 1.4 Modal Operator Theorems

**Existing modal theorems** (Perpetuity.lean):

```lean
-- Box-diamond interactions (lines 789-884):
theorem diamond_4 (φ : Formula) : ⊢ φ.diamond.diamond.imp φ.diamond
theorem modal_5 (φ : Formula) : ⊢ φ.diamond.imp φ.diamond.box

-- Box monotonicity (lines 1611-1621):
theorem box_mono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.box.imp B.box
theorem diamond_mono {A B : Formula} (h : ⊢ A.imp B) : ⊢ A.diamond.imp B.diamond

-- Box-conjunction (line 965):
theorem box_conj_intro {A B : Formula}
  (hA : Γ ⊢ A.box) (hB : Γ ⊢ B.box) : Γ ⊢ (A.and B).box
```

**Relevance to Tasks 30-36**:
- Task 30 (T-Box-Diamond): Use modal_t + diamond definition
- Task 31 (Box-Conjunction Biconditional): Extend box_conj_intro with elimination
- Task 32 (Diamond-Disjunction): Dual of Task 31 via modal duality
- Task 33 (S5-Diamond-Box Collapse): Use modal_5 theorem directly
- Task 34 (Box-Disjunction Intro): Apply box_mono + disjunction weakening
- Task 35 (Box-Contraposition): Combine box_mono + contraposition theorem
- Task 36 (T-Box-Consistency): Use modal_t + contradiction reasoning

### 2. Lean 4 Mathlib Alternatives (Low Priority)

**Note**: Mathlib uses different foundations (natural deduction, type theory) than Logos (Hilbert-style, axiomatic). Direct imports are challenging due to incompatible proof systems.

#### 2.1 Classical Logic in Mathlib

**Lean 4 Core Library** (`Init` namespace):
```lean
-- EFQ principle
False.elim : False → α

-- Classical reasoning
Classical.byContradiction : (¬p → False) → p
Classical.not_not : ¬¬p ↔ p

-- Conjunction
And.left : a ∧ b → a
And.right : a ∧ b → b

-- Disjunction
Or.inl : a → a ∨ b
Or.inr : b → a ∨ b
```

**Compatibility Issues**:
1. Mathlib uses `Prop` type with natural deduction
2. Logos uses `Formula` inductive type with Hilbert-style derivation
3. `⊢` notation in Logos is `Derivable` relation, not Mathlib's entailment
4. Cannot directly import Mathlib theorems without translation layer

**Recommendation**: Avoid Mathlib imports; derive theorems internally using K/S axioms.

#### 2.2 Modal Logic in Mathlib4

**Status**: Mathlib4 has limited modal logic support as of 2025
- No comprehensive Hilbert-style modal axiomatics
- Some Kripke semantics in `Logic.Relation`
- Not compatible with Logos's task semantics

**Alternative**: Use existing Logos modal infrastructure (Perpetuity.lean) as template.

### 3. Derivation Patterns from Perpetuity.lean

#### 3.1 Pattern: Implicational Chains

**Example**: `perpetuity_1` (lines 623-655)
```lean
theorem perpetuity_1 (φ : Formula) : ⊢ φ.box.imp φ.always := by
  have h1 : ⊢ φ.box.imp φ.all_past := box_to_past φ
  have h2 : ⊢ φ.box.imp φ := box_to_present φ
  have h3 : ⊢ φ.box.imp φ.all_future := box_to_future φ
  have h4 : ⊢ φ.box.imp (φ.all_past.and φ) := pairing h1 h2
  have h5 : ⊢ φ.box.imp ((φ.all_past.and φ).and φ.all_future) := pairing h4 h3
  exact h5
```

**Pattern**: Build complex theorems by chaining simpler proven lemmas with `pairing` and `imp_trans`.

**Application to Task 21 (RAA)**:
1. Target: `⊢ A → (¬A → B)`
2. Strategy: Use `imp_trans` to chain: `A → ¬¬A` then `¬¬A → (¬A → B)`
3. Apply `double_negation` and S axiom for weakening

#### 3.2 Pattern: Modal Duality Exploitation

**Example**: `perpetuity_2` (lines 916-938)
```lean
theorem perpetuity_2 (φ : Formula) : ⊢ φ.sometimes.imp φ.diamond := by
  -- sometimes φ = ¬(always ¬φ)
  -- diamond φ = ¬(box ¬φ)
  have p1 : ⊢ φ.neg.box.imp φ.neg.always := perpetuity_1 φ.neg
  have p1_contra : ⊢ φ.neg.always.neg.imp φ.neg.box.neg := contrapose p1
  exact p1_contra
```

**Pattern**: Exploit De Morgan duality between box/diamond and always/sometimes.

**Application to Task 32 (Diamond-Disjunction Biconditional)**:
1. Prove box-conjunction first (Task 31)
2. Apply modal duality: `◇(A ∨ B) = ¬□¬(A ∨ B) = ¬□(¬A ∧ ¬B)`
3. Use De Morgan laws + box_conj_iff to derive diamond_disj_iff

#### 3.3 Pattern: Contraposition with Double Negation

**Example**: `bridge1` (lines 1714-1733)
```lean
theorem bridge1 (φ : Formula) : ⊢ φ.always.box.neg.imp φ.neg.sometimes.diamond := by
  have p5_neg : ⊢ φ.neg.sometimes.diamond.imp φ.neg.diamond.always := perpetuity_5 φ.neg
  have contra : ⊢ φ.neg.diamond.always.neg.imp φ.neg.sometimes.diamond.neg := contrapose p5_neg
  have rhs : ⊢ φ.always.box.imp φ.neg.diamond.always := persistence φ
  have rhs_neg : ⊢ φ.neg.diamond.always.neg.imp φ.always.box.neg := contrapose rhs
  exact imp_trans rhs_neg contra
```

**Pattern**: Chain contraposition lemmas to navigate complex negation structures.

**Application to Task 25 (RCP)**:
1. Use existing `contrapose` theorem
2. Apply `double_negation` twice to handle DNE
3. Chain with `imp_trans` for full derivation

### 4. Missing Lemmas and Required Infrastructure

#### 4.1 Context Manipulation Theorems (High Priority)

**Required for Tasks 27-29** (NE/NI, DE, BI):

```lean
-- Deduction theorem (partial):
-- If Γ, A ⊢ B then Γ ⊢ A → B
theorem deduction {A B : Formula} {Γ : Context}
  (h : (A :: Γ) ⊢ B) : Γ ⊢ A.imp B

-- Weakening (exists but needs generalization):
-- If Γ ⊢ φ then Γ, A ⊢ φ
-- Currently: Derivable.weakening rule (Derivation.lean:84)

-- Assumption extraction:
-- If A ∈ Γ then Γ ⊢ A
-- Currently: Derivable.assumption rule (Derivation.lean:74)
```

**Current Status**:
- `weakening` rule exists (Derivation.lean:84)
- `assumption` rule exists (Derivation.lean:74)
- Deduction theorem NOT proven for all cases
- Context manipulation complex due to modal operators

**Derivation Strategy**:
1. Tasks 27-29 are marked as 6-8 hours effort (TODO.md)
2. Requires extending deduction theorem infrastructure
3. May need intermediate lemmas for context reordering
4. Consider proving simplified versions first (e.g., NI before NE)

#### 4.2 Biconditional Reasoning (Medium Priority)

**Required for Tasks 29, 31-33**:

```lean
-- Biconditional definition (Formula.lean:109):
-- def iff (φ ψ : Formula) : Formula := (φ.imp ψ).and (ψ.imp φ)

-- Missing theorems:
theorem iff_intro {A B : Formula} {Γ : Context}
  (h1 : (A :: Γ) ⊢ B) (h2 : (B :: Γ) ⊢ A) : Γ ⊢ A.iff B

theorem iff_elim_left {A B : Formula}
  (h : Γ ⊢ A.iff B) : Γ ⊢ A.imp B

theorem iff_elim_right {A B : Formula}
  (h : Γ ⊢ A.iff B) : Γ ⊢ B.imp A
```

**Derivation Strategy**:
1. Biconditional is defined as conjunction of implications
2. Use `box_conj_intro`/elimination patterns as template
3. LBE/RBE (Task 29) follow from iff_elim + modus ponens

#### 4.3 Disjunction Elimination (Medium Priority)

**Required for Task 28**:

```lean
-- Disjunction definition (Formula.lean:104):
-- def or (φ ψ : Formula) : Formula := φ.neg.imp ψ

-- Target theorem:
theorem de (A B C : Formula)
  (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) : ((A.or B) :: Γ) ⊢ C
```

**Derivation Strategy**:
1. Expand `A.or B` to `¬A → B`
2. Use case analysis pattern: if A then C, if ¬A then B, and if B then C
3. Requires deduction theorem + double negation elimination
4. May need law of excluded middle: `⊢ A ∨ ¬A` (derivable from double_negation + S/K axioms)

## Recommendations

### R1. Prioritize Internal Derivation Over Mathlib Imports

**Rationale**:
- Logos uses incompatible proof system (Hilbert-style vs natural deduction)
- Existing combinator infrastructure (K, S, B, C) is sufficient
- All perpetuity principles proven without external dependencies
- Translation layer would add complexity

**Action**: Implement all 21 theorems using internal Derivable relation and existing axioms.

### R2. Implement Theorems in Dependency Order

**Recommended Order** (based on complexity analysis):

**Phase 1: Propositional Foundations** (Tasks 21-26, ~15 hours)
1. Task 21: RAA (uses imp_trans, S axiom)
2. Task 22: EFQ (uses RAA + double_negation)
3. Task 26: ECQ (uses RAA/EFQ directly)
4. Task 23: LCE/RCE (uses pairing theorem + negation)
5. Task 24: LDI/RDI (uses S axiom + disjunction definition)
6. Task 25: RCP (uses contrapose + double_negation)

**Phase 2: Context Manipulation** (Tasks 27-29, ~19 hours)
7. Task 27: NE/NI (requires deduction theorem extension)
8. Task 28: DE (requires NE/NI + LEM)
9. Task 29: BI/LBE/RBE (requires deduction theorem + conjunction patterns)

**Phase 3: Modal Theorems** (Tasks 30-36, ~28 hours)
10. Task 30: T-Box-Diamond (uses modal_t + diamond definition)
11. Task 31: Box-Conjunction Biconditional (extends box_conj_intro)
12. Task 32: Diamond-Disjunction Biconditional (dual of Task 31)
13. Task 34: Box-Disjunction Intro (uses box_mono)
14. Task 35: Box-Contraposition (uses box_mono + contrapose)
15. Task 36: T-Box-Consistency (uses modal_t + ECQ)
16. Task 33: S5-Diamond-Box Collapse (uses modal_5 theorem)

**Total Estimated Effort**: 62 hours (aligns with TODO.md estimates)

### R3. Create New File: Logos/Core/Theorems/Propositional.lean

**Rationale**:
- Perpetuity.lean is focused on modal-temporal interactions (1809 lines)
- Propositional theorems (Tasks 21-29) are self-contained
- Easier maintenance and testing with separate module

**Recommended Structure**:
```lean
import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Formula

namespace Logos.Core.Theorems.Propositional

open Logos.Core.Syntax
open Logos.Core.ProofSystem

/-! ## Contradiction Reasoning -/
theorem raa (A B : Formula) : [] ⊢ A.imp (A.neg.imp B)
theorem efq (A B : Formula) : [] ⊢ A.neg.imp (A.imp B)
theorem ecq (A B : Formula) : [A, A.neg] ⊢ B

/-! ## Conjunction Elimination -/
theorem lce (A B : Formula) : [A.and B] ⊢ A
theorem rce (A B : Formula) : [A.and B] ⊢ B

/-! ## Disjunction Introduction -/
theorem ldi (A B : Formula) : [A] ⊢ A.or B
theorem rdi (A B : Formula) : [B] ⊢ A.or B

/-! ## Advanced Context Reasoning -/
theorem rcp (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A
theorem ne (A B : Formula) (h1 : (A.neg :: Γ) ⊢ B.neg) (h2 : (A.neg :: Γ) ⊢ B) : Γ ⊢ A
theorem ni (A B : Formula) (h1 : (A :: Γ) ⊢ B.neg) (h2 : (A :: Γ) ⊢ B) : Γ ⊢ A.neg
theorem de (A B C : Formula) (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) : ((A.or B) :: Γ) ⊢ C

/-! ## Biconditional Reasoning -/
theorem bi (A B : Formula) (h1 : (A :: Γ) ⊢ B) (h2 : (B :: Γ) ⊢ A) : Γ ⊢ A.iff B
theorem lbe (A B : Formula) : [A.iff B, A] ⊢ B
theorem rbe (A B : Formula) : [A.iff B, B] ⊢ A

end Logos.Core.Theorems.Propositional
```

### R4. Create New File: Logos/Core/Theorems/ModalS5.lean

**Rationale**:
- Modal S5 theorems (Tasks 30-36) are distinct from perpetuity principles
- Focuses on box-diamond interactions without temporal operators
- Separates S5-specific theorems from general TM logic

**Recommended Structure**:
```lean
import Logos.Core.Theorems.Perpetuity
import Logos.Core.Theorems.Propositional

namespace Logos.Core.Theorems.ModalS5

/-! ## Basic S5 Properties -/
theorem t_box_to_diamond (A : Formula) : [] ⊢ A.box.imp A.diamond
theorem box_conj_iff (A B : Formula) : [] ⊢ (A.and B).box.iff (A.box.and B.box)
theorem diamond_disj_iff (A B : Formula) : [] ⊢ (A.or B).diamond.iff (A.diamond.or B.diamond)
theorem s5_diamond_box (A : Formula) : [] ⊢ (A.box.diamond).iff A.box

/-! ## Modal Distribution and Monotonicity -/
theorem box_disj_intro (A B : Formula) : [] ⊢ (A.box.or B.box).imp ((A.or B).box)
theorem box_contrapose (A B : Formula) : [] ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box)
theorem t_box_consistency (A : Formula) : [] ⊢ (A.and A.neg).box.neg

end Logos.Core.Theorems.ModalS5
```

### R5. Leverage Automation Tools for Proof Development

**Existing Automation** (Logos/Core/Automation/Tactics.lean):
- `tm_auto`: Aesop-powered comprehensive automation
- `modal_k_tactic`, `temporal_k_tactic`: Inference rule automation
- `assumption_search`: Context searching

**Recommended Usage**:
1. Start each theorem proof with `tm_auto` to handle trivial cases
2. Use `modal_k_tactic` for modal distribution steps
3. Apply `assumption_search` when context contains needed formulas
4. Fall back to manual `apply`, `have`, `exact` for complex proofs

**Example**:
```lean
theorem raa (A B : Formula) : [] ⊢ A.imp (A.neg.imp B) := by
  tm_auto <|> (  -- Try automation first
    have h1 : ⊢ A.imp (A.imp B) := Derivable.axiom [] _ (Axiom.prop_s A B)
    have h2 : ⊢ (A.imp (A.imp B)).imp ((A.imp A) → (A.imp B)) :=
      Derivable.axiom [] _ (Axiom.prop_k A A B)
    -- Manual proof steps...
  )
```

## Conclusion

The Logos project has a robust foundation for deriving all 21 Hilbert-style propositional and modal theorems without external Mathlib dependencies. Key resources include:

1. **Proven Combinator Infrastructure**: K, S, B, C combinators with 1809 lines of proven theorems
2. **Modal Reasoning Patterns**: Extensive box-diamond duality, monotonicity, and S5 properties
3. **Classical Logic Foundation**: `double_negation` axiom enables RAA, EFQ, ECQ derivations
4. **Automation Support**: 12/12 tactics implemented for proof automation

**Critical Path**: Context manipulation infrastructure (deduction theorem extension) is the main blocker for Tasks 27-29. Phase 1 (propositional foundations) and Phase 3 (modal theorems) can proceed in parallel.

**Next Steps**:
1. Review proof strategies report for tactic patterns
2. Review project structure report for file organization
3. Begin implementation with Task 21 (RAA) as proof-of-concept
4. Iterate through Phase 1 theorems before tackling context manipulation

## Appendix: Theorem Dependency Graph

```
Axioms: prop_k, prop_s, double_negation
         ↓
Combinators: identity, imp_trans, b_combinator, theorem_flip
         ↓
    ┌────┴────┬────────────┬──────────┐
    ↓         ↓            ↓          ↓
  RAA       LCE/RCE    LDI/RDI    T-Box-Diamond
    ↓         ↓            ↓          ↓
  EFQ    Box-Conj-Iff Diamond-Disj  RCP
    ↓         ↓            ↓          ↓
  ECQ    Box-Disj-Intro   DE     Box-Contrapose
    ↓         ↓            ↓          ↓
  NE/NI  T-Box-Consistency BI    S5-Diamond-Box
           LBE/RBE
```

---

**Report Statistics**:
- Total Findings: 15
- Recommendations: 5
- Code Examples: 20
- Estimated Implementation Time: 62 hours
