# Lean Formalization Research Report

## Metadata
- **Date**: 2025-12-08
- **Agent**: lean-research-specialist
- **Topic**: Fix Perpetuity Theorem Logic Errors (Task 16)
- **Lean Project**: /home/benjamin/Documents/Philosophy/Projects/ProofChecker
- **Report Type**: Lean 4 formalization research
- **Research Complexity**: 3 (Deep)

## Executive Summary

This research identifies three core axiom gaps preventing syntactic proof of perpetuity theorems P3-P6:

1. **Modal K Distribution Axiom** (`□(A → B) → (□A → □B)`): Required for P3 to combine `□Hφ ∧ □φ ∧ □Gφ` into `□(Hφ ∧ φ ∧ Gφ)`. The TM system has modal_k RULE but not the AXIOM.

2. **Classical Logic Axioms** (excluded middle or double negation elimination): Required for P2 (contraposition) and P4 (double negation in formula structure). Lean 4 provides these via `open Classical`.

3. **Modal/Temporal Necessitation**: Required for P5-P6 to derive modal-temporal interactions. Standard in normal modal logics but not formalized in TM yet.

**Key Finding**: The FormalizedFormalLogic/Foundation project in Lean 4 provides working examples of modal K axiom, classical reasoning, and necessitation patterns directly applicable to Logos.

## Mathlib Theorem Discovery

### Relevant Theorems from Lean 4 Ecosystem

#### Classical Logic (Mathlib4)

1. **`Classical.em`**: Law of excluded middle `P ∨ ¬P`
   - Module: `Mathlib.Logic.Basic`
   - Usage: Enable via `open Classical` before use
   - Type: `∀ (p : Prop), p ∨ ¬p`
   - Reference: [Mathlib4 Logic.Basic](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Logic/Basic.html)

2. **`Classical.byContradiction`**: Proof by contradiction `¬¬A → A`
   - Module: `Mathlib.Logic.Basic`
   - Usage: Requires `open Classical`
   - Type: `∀ {p : Prop}, (¬p → False) → p`
   - Note: Equivalent to double negation elimination

3. **`And.intro`**: Conjunction introduction combinator
   - Module: Built-in Lean 4 Core
   - Type: `∀ {a b : Prop}, a → b → a ∧ b`
   - Usage: `And.intro ha hb` or `⟨ha, hb⟩`
   - Reference: [Propositions and Proofs](https://lean-lang.org/theorem_proving_in_lean4/propositions_and_proofs.html)

#### Modal Logic Patterns (FormalizedFormalLogic/Foundation)

4. **Modal K Distribution**: `□(A → B) → (□A → □B)`
   - Project: [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation)
   - Context: Fundamental axiom in normal modal logics
   - Book: [Lean4 Logic Formalization](https://formalizedformallogic.github.io/Book/)
   - Status: Formalized in Foundation with Kripke semantics

5. **Necessitation Rule**: If `⊢ A` then `⊢ □A`
   - Standard in modal logics K, T, S4, S5
   - Pattern: Apply to propositional tautologies
   - Used to derive: `□(A → (B → A∧B))` from `A → (B → A∧B)`

6. **Box Conjunction Distribution**: `□A ∧ □B → □(A∧B)`
   - Derivation: Necessitate `A → (B → A∧B)`, apply K twice
   - Reference: [Natural Deduction for Modal Logic](https://www.umsu.de/courses/logic2/ml-nd.pdf)
   - Status: Proven pattern in normal modal logics

### Tactic Recommendations

#### For P3 (Modal K Distribution Gap)

**Goal Type**: `⊢ φ.box.imp (φ.always.box)` where `always φ = Hφ ∧ φ ∧ Gφ`

**Recommended Approach**:
```lean
-- Option 1: Add modal K axiom to Axiom type
axiom modal_k_dist (A B : Formula) :
  ⊢ (A.imp B).box.imp (A.box.imp B.box)

-- Option 2: Add necessitation as inference rule
rule necessitation (φ : Formula) :
  (⊢ φ) → (⊢ φ.box)

-- Then combine with And.intro pattern
theorem box_conj_intro {A B : Formula}
  (hA : ⊢ A.box) (hB : ⊢ B.box) : ⊢ (A.and B).box
```

**Tactics**: `apply`, `exact`, custom `modal_dist` tactic

#### For P2 and P4 (Classical Logic)

**Goal Type**: Contraposition and double negation

**Recommended Approach**:
```lean
-- Enable classical logic
open Classical

-- Use em (excluded middle) or byContradiction
theorem contraposition_classical {A B : Formula}
  (h : ⊢ A.imp B) : ⊢ B.neg.imp A.neg := by
  -- Use byContradiction or em to derive
  ...
```

**Tactics**: `byContradiction`, `em`, `Classical.not_not`

#### For P5 and P6 (Modal/Temporal Interaction)

**Goal Type**: Composition of modal and temporal operators

**Recommended Approach**:
```lean
-- Add necessitation for temporal operators
axiom temporal_necessitation (φ : Formula) :
  (⊢ φ) → (⊢ φ.all_future)

-- Derive persistence lemma
theorem modal_temporal_persistence :
  ⊢ φ.diamond.imp φ.diamond.always := by
  -- Use MB, TF, MT composition
  ...
```

**Tactics**: `imp_trans`, `mp`, custom `modal_temporal` tactic

## Proof Pattern Analysis

### Common Patterns in Logos Project

#### Pattern 1: Implication Transitivity Chain (P1 helper lemmas)

**Source**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean:76-93`

```lean
theorem imp_trans {A B C : Formula}
    (h1 : ⊢ A.imp B) (h2 : ⊢ B.imp C) : ⊢ A.imp C := by
  have s_axiom : ⊢ (B.imp C).imp (A.imp (B.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_s (B.imp C) A)
  have h3 : ⊢ A.imp (B.imp C) :=
    Derivable.modus_ponens [] (B.imp C) (A.imp (B.imp C)) s_axiom h2
  have k_axiom : ⊢ (A.imp (B.imp C)).imp ((A.imp B).imp (A.imp C)) :=
    Derivable.axiom [] _ (Axiom.prop_k A B C)
  have h4 : ⊢ (A.imp B).imp (A.imp C) :=
    Derivable.modus_ponens [] (A.imp (B.imp C)) ((A.imp B).imp (A.imp C)) k_axiom h3
  exact Derivable.modus_ponens [] (A.imp B) (A.imp C) h4 h1
```

**Usage**: Compose multiple axioms to build longer implication chains (e.g., `□φ → □Gφ → Gφ`)

**Tactic Sequence**: `have` (intermediate steps) → `Derivable.axiom` → `Derivable.modus_ponens` → `exact`

#### Pattern 2: Temporal Duality Transformation (P1 box_to_past)

**Source**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean:214-219`

```lean
theorem box_to_past (φ : Formula) : ⊢ φ.box.imp φ.all_past := by
  have h1 : ⊢ φ.swap_temporal.box.imp φ.swap_temporal.all_future := box_to_future φ.swap_temporal
  have h2 : ⊢ (φ.swap_temporal.box.imp φ.swap_temporal.all_future).swap_temporal :=
    Derivable.temporal_duality (φ.swap_temporal.box.imp φ.swap_temporal.all_future) h1
  simp only [Formula.swap_temporal, Formula.swap_temporal_involution] at h2
  exact h2
```

**Usage**: Derive past-oriented theorems from future-oriented ones using temporal duality

**Tactic Sequence**: Prove for `swap_temporal` → apply `temporal_duality` → `simp` to normalize → `exact`

#### Pattern 3: Conjunction Introduction from Implications (P1)

**Source**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean:159-167`

```lean
theorem combine_imp_conj {P A B : Formula}
    (hA : ⊢ P.imp A) (hB : ⊢ P.imp B) : ⊢ P.imp (A.and B) := by
  have pair_ab : ⊢ A.imp (B.imp (A.and B)) := pairing A B
  have h1 : ⊢ P.imp (B.imp (A.and B)) := imp_trans hA pair_ab
  have s : ⊢ (P.imp (B.imp (A.and B))).imp ((P.imp B).imp (P.imp (A.and B))) :=
    Derivable.axiom [] _ (Axiom.prop_k P B (A.and B))
  have h2 : ⊢ (P.imp B).imp (P.imp (A.and B)) :=
    Derivable.modus_ponens [] (P.imp (B.imp (A.and B))) ((P.imp B).imp (P.imp (A.and B))) s h1
  exact Derivable.modus_ponens [] (P.imp B) (P.imp (A.and B)) h2 hB
```

**Usage**: Combine separate implications into conjunction (e.g., `□φ → Hφ` and `□φ → Gφ` into `□φ → Hφ ∧ Gφ`)

**Tactic Sequence**: Apply `pairing` → `imp_trans` → K axiom → double `modus_ponens`

**Note**: Requires `pairing` axiom; analogous to `And.intro` in Lean's Prop

#### Pattern 4: Modal Operator Composition (P1 box_to_future)

**Source**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean:198-201`

```lean
theorem box_to_future (φ : Formula) : ⊢ φ.box.imp φ.all_future := by
  have mf : ⊢ φ.box.imp (φ.all_future.box) := Derivable.axiom [] _ (Axiom.modal_future φ)
  have mt : ⊢ φ.all_future.box.imp φ.all_future := Derivable.axiom [] _ (Axiom.modal_t φ.all_future)
  exact imp_trans mf mt
```

**Usage**: Compose modal and temporal axioms (MF + MT → conclusion)

**Tactic Sequence**: State both axioms → apply `imp_trans` → `exact`

### Complexity Assessment

#### Simple (1-2 hours implementation)

**P1 Components** (`box_to_past`, `box_to_future`, `box_to_present`):
- Complexity: LOW
- Pattern: Direct axiom application + transitivity
- Status: ✓ COMPLETE
- Lines of proof: 3-8 per lemma

**P2 via Contraposition**:
- Complexity: LOW (with contraposition axiom)
- Pattern: Apply contraposition to P1 for `¬φ`
- Status: ✓ COMPLETE (axiomatized contraposition)
- Lines of proof: 5-6

#### Medium (3-6 hours implementation)

**P3 with Modal K Axiom**:
- Complexity: MEDIUM
- Pattern: Prove `□Hφ ∧ □φ ∧ □Gφ` (done), add modal K distribution, combine via necessitation
- Current status: PARTIAL (missing modal K axiom)
- Estimated lines: 20-30 with modal K

**Contraposition Derivation from Classical Logic**:
- Complexity: MEDIUM
- Pattern: Use `Classical.em` or `Classical.byContradiction` to derive `(A → B) → (¬B → ¬A)`
- Estimated lines: 15-25
- Requires: Translating Prop-level classical tactics to Formula-level derivability

#### Complex (6-12 hours implementation)

**P4 with Double Negation**:
- Complexity: HIGH
- Challenge: Formula structure has nested `.neg.neg` that doesn't syntactically reduce
- Pattern: Need to either (a) add DNE axiom for Formula type, or (b) restructure `sometimes`/`diamond` definitions
- Estimated lines: 30-50

**P5 Modal/Temporal Persistence**:
- Complexity: HIGH
- Challenge: Requires proving `◇φ → △◇φ` from `φ → F◇φ` (modal reasoning not in system)
- Pattern: Add modal necessitation + temporal interaction lemmas
- Estimated lines: 40-60

**P6 Temporal Necessitation**:
- Complexity: HIGH
- Challenge: Proving `▽□φ → □△φ` requires temporal necessitation rule
- Pattern: Either derive from P5 equivalence or add temporal necessitation
- Estimated lines: 35-55

## Project Architecture Review

### Module Structure

**Perpetuity Theorems Module**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean` (566 lines)

**Organization**:
```
Perpetuity.lean
├── Helper Lemmas: Propositional Reasoning (lines 67-115)
│   ├── imp_trans: Implication transitivity
│   ├── mp: Modus ponens restatement
│   └── identity: A → A combinator
├── Helper Lemmas: Conjunction Introduction (lines 117-179)
│   ├── pairing: A → B → A∧B (axiomatized)
│   ├── combine_imp_conj: Two-way conjunction combinator
│   └── combine_imp_conj_3: Three-way conjunction combinator
├── Helper Lemmas: Temporal Components (lines 181-225)
│   ├── box_to_future: □φ → Gφ
│   ├── box_to_past: □φ → Hφ (via temporal duality)
│   ├── box_to_present: □φ → φ (MT axiom)
│   └── box_to_box_past: □φ → □Hφ
├── P1: Necessary Implies Always (lines 227-251)
│   └── perpetuity_1: □φ → △φ (FULLY PROVEN)
├── P2: Sometimes Implies Possible (lines 253-305)
│   ├── contraposition: (A → B) → (¬B → ¬A) (axiomatized)
│   └── perpetuity_2: ▽φ → ◇φ (PROVEN via contraposition)
├── P3: Necessity of Perpetuity (lines 307-366)
│   └── perpetuity_3: □φ → □△φ (PARTIAL - sorry)
├── P4-P6: Axiomatized (lines 368-485)
│   ├── perpetuity_4: ◇▽φ → ◇φ (axiomatized)
│   ├── perpetuity_5: ◇▽φ → △◇φ (axiomatized)
│   └── perpetuity_6: ▽□φ → □△φ (axiomatized)
└── Summary and Examples (lines 487-565)
```

**Dependencies**:
- `Logos.Core.ProofSystem.Derivation` - Derivability relation, inference rules
- `Logos.Core.Syntax.Formula` - Formula type, derived operators

**Axiom System**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean`

**Current Axioms** (10 total):
1. `prop_k`: Propositional K (distribution)
2. `prop_s`: Propositional S (weakening)
3. `modal_t`: □φ → φ (reflexivity)
4. `modal_4`: □φ → □□φ (transitivity)
5. `modal_b`: φ → □◇φ (symmetry)
6. `temp_4`: Fφ → FFφ (temporal transitivity)
7. `temp_a`: φ → F(Pφ) (temporal connectedness)
8. `temp_l`: △φ → F(Pφ) (temporal introspection)
9. `modal_future`: □φ → □Fφ (modal-future interaction)
10. `temp_future`: □φ → F□φ (temporal-future interaction)

**Inference Rules**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Derivation.lean`

**Current Rules** (7 total):
1. `axiom`: Any axiom schema instance derivable
2. `assumption`: Formulas in context derivable
3. `modus_ponens`: (Γ ⊢ φ → ψ) → (Γ ⊢ φ) → (Γ ⊢ ψ)
4. `modal_k`: (Γ ⊢ φ) → (□Γ ⊢ □φ) — **RULE, not axiom**
5. `temporal_k`: (Γ ⊢ φ) → (FΓ ⊢ Fφ)
6. `temporal_duality`: (⊢ φ) → (⊢ swap_temporal φ)
7. `weakening`: (Γ ⊢ φ) → (Γ ⊆ Δ) → (Δ ⊢ φ)

**Key Distinction**: `modal_k` is an inference RULE (`Γ ⊢ φ` implies `□Γ ⊢ □φ`), NOT the modal K AXIOM (`□(A → B) → (□A → □B)`). The rule transforms contexts; the axiom distributes box over implication internally.

### Naming Conventions

**From LEAN_STYLE_GUIDE.md** and observed patterns:

#### Theorems and Lemmas
- **Perpetuity principles**: `perpetuity_N` where N ∈ {1,2,3,4,5,6}
- **Helper lemmas**: Descriptive names (`imp_trans`, `box_to_future`, `combine_imp_conj`)
- **Axioms**: Subject_property pattern (`modal_t`, `temp_4`, `prop_k`)

#### Variables
- **Formulas**: φ, ψ, χ (phi, psi, chi)
- **Contexts**: Γ, Δ (Gamma, Delta)
- **Generic types**: A, B, C for formula metavariables

#### Module Names
- **PascalCase** for types: `Formula`, `Axiom`, `Derivable`
- **snake_case** for functions/theorems: `perpetuity_1`, `imp_trans`, `truth_at`

#### Notation
- **Triangle operators**: `△` (always), `▽` (sometimes)
- **Modal operators**: `□` (box/necessity), `◇` (diamond/possibility)
- **Temporal operators**: `H`/`all_past`, `G`/`all_future`, `P`/`some_past`, `F`/`some_future`
- **Derivability**: `⊢` (turnstile)

### Import Patterns

**Standard Import Chain for Perpetuity Work**:

```lean
-- Core dependencies (always required)
import Logos.Core.Syntax.Formula         -- Formula type, operators
import Logos.Core.ProofSystem.Derivation -- Derivability, inference rules

-- If using axioms directly
import Logos.Core.ProofSystem.Axioms     -- Axiom schemata

-- If testing
import Logos.Core.Theorems.Perpetuity    -- Perpetuity theorems

-- If semantic validation
import Logos.Core.Semantics.Validity     -- Valid, consequence relations
import Logos.Core.Metalogic.Soundness    -- Soundness theorem
```

**Namespace Opening Pattern**:

```lean
namespace Logos.Core.Theorems.Perpetuity

open Logos.Core.Syntax        -- Formula, operators
open Logos.Core.ProofSystem   -- Derivable, Axiom

-- Theorem definitions here

end Logos.Core.Theorems.Perpetuity
```

**No Classical Logic Imports Found**: The project does NOT currently use `open Classical` anywhere. This confirms that classical reasoning (contraposition, double negation) must be added to the Formula-level proof system, not borrowed from Lean's Prop.

## Formalization Strategy

### Recommended Approach

#### Option A: Minimal Extension (Recommended for MVP)

**Philosophy**: Add only necessary axioms/rules to complete P3-P6, maintaining semantic justification for each addition.

**Implementation Plan**:

1. **Add Modal K Distribution Axiom** (for P3):
   ```lean
   | modal_k_dist (φ ψ : Formula) :
       Axiom ((φ.imp ψ).box.imp (φ.box.imp ψ.box))
   ```
   - **Soundness**: Proven valid in all Kripke frames (standard modal logic result)
   - **Impact**: Enables P3 proof via necessitation of `A → (B → A∧B)` + K distribution
   - **Estimated effort**: 3-4 hours (add axiom, prove P3, update soundness proof)

2. **Add Necessitation as Inference Rule** (for P3, P5, P6):
   ```lean
   | necessitation (φ : Formula) :
       (h : Derivable [] φ) → Derivable [] (Formula.box φ)
   ```
   - **Soundness**: Standard in normal modal logics (theorems remain theorems under □)
   - **Impact**: Enables deriving `□(A → (B → A∧B))` from `⊢ A → (B → A∧B)`
   - **Estimated effort**: 2-3 hours (add rule, update soundness, add tests)

3. **Add Classical Logic Axioms** (for P2 contraposition derivation, P4 DNE):
   ```lean
   | excluded_middle (φ : Formula) : Axiom (φ.or φ.neg)
   -- OR equivalently:
   | double_negation (φ : Formula) : Axiom (φ.neg.neg.imp φ)
   ```
   - **Soundness**: Valid in classical semantics (TM uses classical logic, not intuitionistic)
   - **Impact**: Enables deriving contraposition, fixing P2 and P4
   - **Estimated effort**: 4-6 hours (add axiom, derive contraposition, prove P2/P4, soundness)

4. **Derive P5 and P6** from extended system:
   - P5: Use necessitation + modal/temporal K rules + MB/TF composition
   - P6: Either derive from P5 equivalence or add temporal necessitation
   - **Estimated effort**: 6-8 hours per theorem

**Total Effort**: 15-25 hours for complete syntactic proofs

**Pros**:
- Maintains semantic justification for all additions
- Aligns with standard modal logic systems (K + necessitation = normal modal logic)
- Minimal impact on existing codebase
- All additions are sound

**Cons**:
- Increases axiom/rule count (12 axioms, 8 rules after additions)
- May require updating soundness proofs for new axioms

#### Option B: Semantic Justification (Current MVP Approach)

**Philosophy**: Keep current axiomatizations with semantic justification, document gaps for future work.

**Status**: P3-P6 are axiomatized with detailed semantic justification (Corollary 2.11 from paper). This is pragmatic for MVP.

**Pros**:
- No additional implementation work
- All theorems available for use
- Semantic soundness documented

**Cons**:
- Syntactic incompleteness (gap between semantics and syntax)
- Less satisfying from proof theory perspective
- Doesn't address "logic errors" interpretation of Task 16

**Recommendation**: Use Option B for MVP release, transition to Option A for completeness work (post-MVP).

### Dependency Structure

**Theorem Dependency Graph** (for Option A):

```
Classical Logic Axiom (EM or DNE)
  ↓
contraposition lemma ────→ P2: ▽φ → ◇φ
  │                          ↑
  │                          │
  └──────────────────────→ P4: ◇▽φ → ◇φ (via contraposition of P3)
                             ↑
Modal K Axiom + Necessitation
  ↓
box_conj_intro lemma
  ↓
P3: □φ → □△φ ────────────→ P4 (contraposition)
  ↓
P5: ◇▽φ → △◇φ (requires P3 + modal/temporal interaction)
  ↓
P6: ▽□φ → □△φ (from P5 equivalence or temporal necessitation)
```

**Implementation Order** (prioritized by dependency and difficulty):

1. **Phase 1** (foundational axioms): Add modal K, necessitation, classical logic axiom (6-8 hours)
2. **Phase 2** (derive helper lemmas): `contraposition`, `box_conj_intro` (4-6 hours)
3. **Phase 3** (prove P3): Complete P3 using new axioms (2-3 hours)
4. **Phase 4** (prove P2 and P4): Derive from contraposition (3-4 hours)
5. **Phase 5** (prove P5 and P6): Modal/temporal interaction (8-12 hours)
6. **Phase 6** (soundness): Update soundness proofs for new axioms (6-8 hours)
7. **Phase 7** (testing): Comprehensive test suite (4-6 hours)

**Total**: 33-47 hours for complete implementation

### Risk Assessment

#### High-Risk Items

1. **Soundness Proof Updates** (Risk: HIGH, Impact: HIGH)
   - **Challenge**: Each new axiom requires semantic validity proof in task semantics
   - **Mitigation**: Modal K and necessitation are standard; reuse proofs from modal logic literature
   - **Contingency**: If soundness proof too complex, document semantic justification (current approach)

2. **P5 and P6 Complexity** (Risk: MEDIUM, Impact: MEDIUM)
   - **Challenge**: Require complex modal/temporal interaction not yet formalized
   - **Mitigation**: Follow paper's proof sketches closely; consult FormalizedFormalLogic/Foundation for patterns
   - **Contingency**: Keep axiomatized if derivation exceeds time budget

3. **Classical Logic Integration** (Risk: LOW, Impact: MEDIUM)
   - **Challenge**: Classical axioms at Formula level, not Prop level (can't use `open Classical`)
   - **Mitigation**: Add excluded middle or DNE as axiom schema, derive contraposition
   - **Contingency**: Axiomatize contraposition directly (current approach)

#### Medium-Risk Items

4. **Double Negation in P4** (Risk: MEDIUM, Impact: LOW)
   - **Challenge**: Formula structure `φ.sometimes.diamond` has nested `.neg.neg` that doesn't reduce
   - **Mitigation**: DNE axiom should handle this; may need simp lemma
   - **Contingency**: Restructure `sometimes`/`diamond` definitions to avoid nested negation

5. **Test Coverage for New Axioms** (Risk: LOW, Impact: MEDIUM)
   - **Challenge**: Ensuring new axioms don't break existing proofs
   - **Mitigation**: Comprehensive regression testing before merging
   - **Contingency**: Run `lake test` after each axiom addition

#### Low-Risk Items

6. **Naming and Documentation** (Risk: LOW, Impact: LOW)
   - **Challenge**: Maintaining consistent naming for new axioms/rules
   - **Mitigation**: Follow LEAN_STYLE_GUIDE.md conventions
   - **Contingency**: Refactor names in separate PR if inconsistencies found

**Overall Risk Level**: MEDIUM

**Critical Success Factors**:
1. Sound semantic justification for all new axioms (aligns with standard modal logic)
2. Incremental implementation with testing after each phase
3. Clear documentation of proof strategies in code comments

## References

### Mathlib Documentation

1. [Mathlib4 Logic.Basic](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Logic/Basic.html) - Classical logic theorems (em, byContradiction, DNE)
2. [Theorem Proving in Lean 4 - Propositions and Proofs](https://lean-lang.org/theorem_proving_in_lean4/propositions_and_proofs.html) - And.intro, conjunction patterns
3. [Theorem Proving in Lean 4 - Classical Reasoning](https://leanprover-community.github.io/logic_and_proof/classical_reasoning.html) - Contraposition, excluded middle
4. [Logic and Proof - Propositional Logic in Lean](https://leanprover-community.github.io/logic_and_proof/propositional_logic_in_lean.html) - Tactic patterns

### Modal Logic Formalizations

5. [FormalizedFormalLogic/Foundation](https://github.com/FormalizedFormalLogic/Foundation) - Lean 4 modal logic formalization with K axiom, Kripke semantics
6. [Lean4 Logic Formalization Book](https://formalizedformallogic.github.io/Book/) - Documentation for Foundation project
7. [ljt12138/Formalization-PAL](https://github.com/ljt12138/Formalization-PAL) - S5 modal logic in Lean 3 with completeness
8. [SnO2WMaN/lean4-modallogic](https://github.com/SnO2WMaN/lean4-modallogic) - Modal logic formalization in Lean 4

### Modal Logic Theory

9. [Stanford Encyclopedia - Modal Logic](https://plato.stanford.edu/entries/logic-modal/) - K axiom definition, necessitation rule
10. [Natural Deduction for Modal Logic](https://www.umsu.de/courses/logic2/ml-nd.pdf) - Box conjunction distribution proof
11. [Boxes and Diamonds - Open Logic](https://builds.openlogicproject.org/courses/boxes-and-diamonds/bd-screen.pdf) - Modal logic axiom systems
12. [The 5 Axioms of Modal Logic Explained](https://www.numberanalytics.com/blog/5-axioms-of-modal-logic-explained) - K, T, S4, S5 axioms

### Local Files (Logos Project)

#### Primary Source Files

13. `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean` (566 lines)
    - P1-P6 theorem statements
    - Helper lemmas (imp_trans, box_to_future, combine_imp_conj)
    - Current axiomatizations (pairing, contraposition)
    - Status: P1 FULLY PROVEN, P2 via contraposition, P3 PARTIAL (sorry), P4-P6 axiomatized

14. `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Axioms.lean` (150 lines)
    - TM axiom schemata (10 total)
    - prop_k, prop_s (propositional)
    - modal_t, modal_4, modal_b (S5 modal)
    - temp_4, temp_a, temp_l (temporal)
    - modal_future, temp_future (interaction)

15. `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/ProofSystem/Derivation.lean` (189 lines)
    - Derivability relation definition
    - Inference rules (7 total): axiom, assumption, modus_ponens, modal_k (RULE), temporal_k, temporal_duality, weakening

16. `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Syntax/Formula.lean` (400+ lines)
    - Formula inductive type (6 constructors)
    - Derived operators (neg, and, or, diamond, always, sometimes)
    - swap_temporal duality transformation

#### Documentation Files

17. `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/Development/LEAN_STYLE_GUIDE.md`
    - Naming conventions (perpetuity_N, imp_trans patterns)
    - Variable naming (φ, ψ, χ for formulas; Γ, Δ for contexts)
    - Formatting standards (100-char line limit, 2-space indent)

18. `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md`
    - Task 16 status: "Prove P3-P6 or properly justify axiomatization"
    - Known limitations: modal K distribution gap, classical logic requirements
    - Sorry count tracking for perpetuity theorems

19. `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/TODO.md`
    - Task 16: "Complete remaining perpetuity theorem work (P3-P6)"
    - Blocked by: modal K axiom, classical logic axioms, necessitation

#### Test Files

20. `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/LogosTest/Core/Theorems/PerpetuityTest.lean`
    - P1-P6 test coverage
    - Helper lemma tests (imp_trans, identity, combine_imp_conj)
    - Example usage patterns

### Research Papers

21. JPL Paper (referenced in Perpetuity.lean comments)
    - Section sec:Appendix: Temporal axiom validity proofs
    - Line 427: `△φ := Hφ ∧ φ ∧ Gφ` definition
    - Lines 1070-1093: Perpetuity principles derivation sketches
    - Corollary 2.11 (line 2373): Semantic validity of P1-P6
    - Theorem 2.8, 2.9: Soundness of MF, TF axioms
    - Lemma A.4: Time-shift invariance

### External Resources

22. [Curry-Howard Correspondence](https://people.cs.nott.ac.uk/psztxa/comp2009.21.ifr-notes/_build/html/propositional_logic.html) - K and S combinators as tautologies
23. [Wikipedia - Modal Logic](https://en.wikipedia.org/wiki/Modal_logic) - Distribution axiom, necessitation rule
24. [Wikipedia - Double Negation](https://en.wikipedia.org/wiki/Double_negation) - DNE in classical vs intuitionistic logic
25. [nLab - Modal Logic](https://ncatlab.org/nlab/show/modal+logic) - Category-theoretic perspective
