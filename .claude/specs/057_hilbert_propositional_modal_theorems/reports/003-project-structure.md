# Research Report: Project Structure for Hilbert-Style Theorems

**Research Topic**: Project Structure
**Date**: 2025-12-09
**Complexity**: 3
**Status**: Complete

## Executive Summary

This report analyzes optimal project structure for organizing 21 new Hilbert-style propositional and modal logic theorems (Tasks 21-41) within the Logos architecture. Analysis of existing structure shows Perpetuity.lean is focused on modal-temporal interactions (1889 lines, P1-P6 proven), while the new theorems cover distinct domains (propositional logic, S5 modal properties). Recommended approach: create two new modules (Propositional.lean and ModalS5.lean) to maintain modularity and test organization.

**Key Findings**:
- Current Theorems/ directory has single file (Perpetuity.lean, 1889 lines)
- LogosTest/ mirrors source structure with 12 test files
- Module organization follows strict namespace hierarchy (Logos.Core.Theorems)
- New theorems naturally partition into 2 modules (9 propositional, 7 modal)
- Recommended file sizes: Propositional.lean (~600 lines), ModalS5.lean (~500 lines)

## Research Findings

### 1. Current Project Structure Analysis

#### 1.1 Source Directory Organization

**Root Structure**:
```
/home/benjamin/Documents/Philosophy/Projects/ProofChecker/
├── Logos/Core/                      # Main source (Logos.Core namespace)
│   ├── Syntax/                      # Formula types, context
│   │   ├── Formula.lean             # 180 LOC, Formula inductive type
│   │   └── Context.lean             # 45 LOC, proof contexts
│   ├── ProofSystem/                 # Axioms, derivation rules
│   │   ├── Axioms.lean              # 200 LOC, 12 axiom schemata
│   │   └── Derivation.lean          # 185 LOC, derivability relation
│   ├── Semantics/                   # Task frame semantics
│   │   ├── TaskFrame.lean
│   │   ├── WorldHistory.lean
│   │   ├── TaskModel.lean
│   │   ├── Truth.lean
│   │   └── Validity.lean
│   ├── Metalogic/                   # Soundness, completeness
│   │   ├── Soundness.lean           # 450 LOC, ALL 12 axioms + 8 rules proven
│   │   └── Completeness.lean        # Infrastructure only
│   ├── Theorems/                    # **FOCUS AREA**
│   │   └── Perpetuity.lean          # 1889 LOC, P1-P6 fully proven
│   └── Automation/                  # Proof tactics
│       ├── Tactics.lean             # 12/12 tactics implemented
│       ├── ProofSearch.lean         # 485 LOC
│       └── AesopRules.lean          # 260 LOC
├── LogosTest/                       # Test suite (mirrors Logos/Core)
│   ├── Core/
│   │   ├── Syntax/
│   │   │   ├── FormulaTest.lean
│   │   │   └── ContextTest.lean
│   │   ├── ProofSystem/
│   │   │   ├── AxiomsTest.lean
│   │   │   └── DerivationTest.lean
│   │   ├── Theorems/
│   │   │   └── PerpetuityTest.lean  # 450 LOC, 110+ tests
│   │   ├── Automation/
│   │   │   └── TacticsTest.lean
│   │   ├── Metalogic/
│   │   │   ├── SoundnessTest.lean
│   │   │   └── CompletenessTest.lean
│   │   └── Integration/
│   │       └── EndToEndTest.lean
└── Documentation/                   # Project documentation
    ├── UserGuide/
    ├── ProjectInfo/
    ├── Development/
    │   └── MODULE_ORGANIZATION.md   # This document
    └── Reference/
```

**Key Observations**:
1. **Strict Module Hierarchy**: Each source directory has corresponding test directory
2. **Single Theorems File**: Only Perpetuity.lean exists (1889 lines)
3. **No Subdirectories**: Theorems/ is flat (no Theorems/Propositional/ subdirectory)
4. **Namespace Convention**: `Logos.Core.Theorems.Perpetuity` for Perpetuity.lean

#### 1.2 Perpetuity.lean Structure Analysis

**File**: `/home/benjamin/Documents/Philosophy/Projects/ProofChecker/Logos/Core/Theorems/Perpetuity.lean`
**Size**: 1889 lines
**Focus**: Modal-temporal operator interactions (P1-P6)

**Content Breakdown**:
```lean
-- Lines 1-56: Module docstring, imports, namespace declaration
import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Formula

namespace Logos.Core.Theorems.Perpetuity

-- Lines 57-249: Helper lemmas (propositional reasoning)
theorem imp_trans ...
theorem identity ...
theorem b_combinator ...
theorem theorem_flip ...
theorem pairing ...        -- Conjunction introduction (now theorem, not axiom)

-- Lines 250-622: Temporal operator lemmas
theorem box_to_future ...
theorem box_to_past ...
theorem box_to_present ...

-- Lines 623-655: P1 (Perpetuity 1)
theorem perpetuity_1 (φ : Formula) : ⊢ φ.box.imp φ.always

-- Lines 656-915: Intermediate lemmas (diamond_4, modal_5, etc.)
theorem diamond_4 ...
theorem modal_5 ...

-- Lines 916-938: P2 (Perpetuity 2)
theorem perpetuity_2 (φ : Formula) : ⊢ φ.sometimes.imp φ.diamond

-- Lines 939-1124: More lemmas (box_conj_intro, box_dne, etc.)

-- Lines 1125-1411: P3, P4, P5 (Perpetuity principles 3-5)
theorem perpetuity_3 ...
theorem perpetuity_4 ...
theorem perpetuity_5 ...

-- Lines 1412-1889: P6 infrastructure and proof
theorem persistence ...
theorem bridge1 ...
theorem bridge2 ...
theorem perpetuity_6 (φ : Formula) : ⊢ φ.box.sometimes.imp φ.always.box
```

**Content Categories**:
- **Propositional foundations** (249 lines): imp_trans, identity, combinators
- **Modal-temporal interactions** (1400 lines): Box-to-temporal, perpetuity principles
- **Helper lemmas** (240 lines): diamond_4, modal_5, contraposition, duality

**Relevance to New Theorems**:
- Tasks 21-29 (propositional): Reuse existing helper lemmas (imp_trans, identity, pairing)
- Tasks 30-36 (modal S5): Partial overlap (modal_5, diamond_4), but focus is different
  - Perpetuity.lean: Modal + Temporal (□ + △/▽)
  - Tasks 30-36: Modal only (□ + ◇, no temporal)

**Conclusion**: New theorems are thematically distinct. Extending Perpetuity.lean would:
- Increase file size to ~2500 lines (exceeds maintainability threshold)
- Mix propositional logic (no operators) with modal-temporal (3 operators)
- Dilute focus of perpetuity principles

### 2. File Organization Options

#### Option A: Create Two New Module Files (RECOMMENDED)

**Proposed Structure**:
```
Logos/Core/Theorems/
├── Perpetuity.lean          # EXISTING: 1889 lines (modal-temporal, P1-P6)
├── Propositional.lean       # NEW: ~600 lines (Tasks 21-29)
└── ModalS5.lean             # NEW: ~500 lines (Tasks 30-36, Tasks 38-41 future)
```

**Propositional.lean Content** (Tasks 21-29):
```lean
import Logos.Core.ProofSystem.Derivation
import Logos.Core.Syntax.Formula
import Logos.Core.Theorems.Perpetuity  -- Reuse combinators

namespace Logos.Core.Theorems.Propositional

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Theorems.Perpetuity  -- Import imp_trans, identity, etc.

/-! ## Contradiction Reasoning -/
-- Tasks 21, 22, 26 (~150 lines)
theorem raa (A B : Formula) : [] ⊢ A.imp (A.neg.imp B)
theorem efq (A B : Formula) : [] ⊢ A.neg.imp (A.imp B)
theorem ecq (A B : Formula) : [A, A.neg] ⊢ B

/-! ## Conjunction and Disjunction -/
-- Tasks 23, 24 (~150 lines)
theorem lce (A B : Formula) : [A.and B] ⊢ A
theorem rce (A B : Formula) : [A.and B] ⊢ B
theorem ldi (A B : Formula) : [A] ⊢ A.or B
theorem rdi (A B : Formula) : [B] ⊢ A.or B

/-! ## Advanced Propositional Reasoning -/
-- Tasks 25, 27, 28, 29 (~300 lines)
theorem rcp (A B : Formula) (h : Γ ⊢ A.neg.imp B.neg) : Γ ⊢ B.imp A
theorem ne (A B : Formula) (h1 : (A.neg :: Γ) ⊢ B.neg) (h2 : (A.neg :: Γ) ⊢ B) : Γ ⊢ A
theorem ni (A B : Formula) (h1 : (A :: Γ) ⊢ B.neg) (h2 : (A :: Γ) ⊢ B) : Γ ⊢ A.neg
theorem de (A B C : Formula) (h1 : (A :: Γ) ⊢ C) (h2 : (B :: Γ) ⊢ C) : ((A.or B) :: Γ) ⊢ C
theorem bi (A B : Formula) (h1 : (A :: Γ) ⊢ B) (h2 : (B :: Γ) ⊢ A) : Γ ⊢ A.iff B
theorem lbe (A B : Formula) : [A.iff B, A] ⊢ B
theorem rbe (A B : Formula) : [A.iff B, B] ⊢ A

end Logos.Core.Theorems.Propositional
```

**Estimated Size**: 600 lines
- Theorems: 13 × 20 lines avg = 260 lines
- Docstrings: 13 × 10 lines avg = 130 lines
- Helper lemmas: ~210 lines (DNI, LEM, deduction theorem support)

**ModalS5.lean Content** (Tasks 30-36):
```lean
import Logos.Core.Theorems.Perpetuity
import Logos.Core.Theorems.Propositional

namespace Logos.Core.Theorems.ModalS5

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Theorems.Perpetuity  -- Reuse modal_5, diamond_4, box_mono

/-! ## Basic S5 Modal Properties -/
-- Tasks 30, 33 (~150 lines)
theorem t_box_to_diamond (A : Formula) : [] ⊢ A.box.imp A.diamond
theorem s5_diamond_box (A : Formula) : [] ⊢ (A.box.diamond).iff A.box

/-! ## Modal Distribution -/
-- Tasks 31, 32, 34 (~200 lines)
theorem box_conj_iff (A B : Formula) : [] ⊢ (A.and B).box.iff (A.box.and B.box)
theorem diamond_disj_iff (A B : Formula) : [] ⊢ (A.or B).diamond.iff (A.diamond.or B.diamond)
theorem box_disj_intro (A B : Formula) : [] ⊢ (A.box.or B.box).imp ((A.or B).box)

/-! ## Modal Reasoning Patterns -/
-- Tasks 35, 36 (~150 lines)
theorem box_contrapose (A B : Formula) : [] ⊢ (A.imp B).box.imp ((B.neg.imp A.neg).box)
theorem t_box_consistency (A : Formula) : [] ⊢ (A.and A.neg).box.neg

end Logos.Core.Theorems.ModalS5
```

**Estimated Size**: 500 lines
- Theorems: 7 × 25 lines avg = 175 lines
- Docstrings: 7 × 15 lines avg = 105 lines
- Helper lemmas: ~220 lines (biconditional infrastructure, De Morgan laws)

**Pros**:
✓ Maintains modularity (3 focused files vs 1 monolithic file)
✓ Clear semantic boundaries (propositional, modal-temporal, modal-S5)
✓ Easier to navigate (600 + 500 lines vs 2500 lines)
✓ Test files mirror structure (PropositionalTest.lean, ModalS5Test.lean)
✓ Import graph is clean: ModalS5 imports Propositional imports Perpetuity
✓ Aligns with MODULE_ORGANIZATION.md standards (no max line count, but maintainability)

**Cons**:
✗ Adds 2 new files (minor overhead)
✗ Requires updating import paths in downstream modules

**Recommendation**: **Strongly recommended**. This is the cleanest option.

#### Option B: Extend Perpetuity.lean with New Sections

**Proposed Structure**:
```
Logos/Core/Theorems/
└── Perpetuity.lean          # EXTENDED: ~2500 lines (all theorems)
    ├── Lines 1-1889: Existing P1-P6 content
    ├── Lines 1890-2200: Propositional theorems (Tasks 21-29)
    └── Lines 2201-2500: Modal S5 theorems (Tasks 30-36)
```

**Pros**:
✓ Single file (no new imports needed)
✓ Reuses existing helper lemmas directly (imp_trans, identity, etc.)
✓ No module proliferation

**Cons**:
✗ File size becomes unwieldy (2500 lines, 32% larger than current)
✗ Mixes 3 distinct domains (modal-temporal, propositional, modal-S5)
✗ Harder to navigate and maintain
✗ Perpetuity principles (P1-P6) get buried in larger file
✗ Test file (PerpetuityTest.lean) becomes 1000+ lines

**Recommendation**: **Not recommended**. Violates separation of concerns.

#### Option C: Create Theorems/Hilbert/ Subdirectory

**Proposed Structure**:
```
Logos/Core/Theorems/
├── Perpetuity.lean                  # EXISTING: 1889 lines (P1-P6)
└── Hilbert/                         # NEW: Subdirectory for Hilbert-style theorems
    ├── Propositional.lean           # Tasks 21-29
    └── ModalS5.lean                 # Tasks 30-36
```

**Namespace**: `Logos.Core.Theorems.Hilbert.Propositional`, `Logos.Core.Theorems.Hilbert.ModalS5`

**Pros**:
✓ Explicit categorization (Hilbert-style vs other theorem types)
✓ Scalable (can add Theorems/Hilbert/ModalS4.lean, etc. in future)
✓ Clear intent (all Hilbert-style derivations in one subdirectory)

**Cons**:
✗ Namespace depth increases (Logos.Core.Theorems.Hilbert.X)
✗ No precedent in current codebase (no other subdirectories in Theorems/)
✗ May be over-engineering (only 2 modules in subdirectory)
✗ Test directory mirrors: LogosTest/Core/Theorems/Hilbert/ adds complexity

**Recommendation**: **Defer**. Consider this option if >5 Hilbert modules are needed (future Layers 1-3). For current scope (2 modules), Option A is simpler.

### 3. Test File Organization

#### 3.1 Current Test Structure

**Existing Test Files**:
```
LogosTest/Core/Theorems/
└── PerpetuityTest.lean      # 450 LOC, 110+ test cases
    ├── test_imp_trans
    ├── test_identity
    ├── test_perpetuity_1
    ├── test_perpetuity_2
    ├── ... (110+ tests)
    └── test_perpetuity_6
```

**Test Naming Convention** (from TESTING_STANDARDS.md):
- File: `<Module>Test.lean` (e.g., `PropositionalTest.lean`)
- Tests: `test_<theorem>_<scenario>` (e.g., `test_raa_simple_case`)

#### 3.2 Recommended Test Organization (Option A)

**Proposed Structure**:
```
LogosTest/Core/Theorems/
├── PerpetuityTest.lean      # EXISTING: 450 LOC (P1-P6 tests)
├── PropositionalTest.lean   # NEW: ~300 LOC (Tasks 21-29 tests)
└── ModalS5Test.lean         # NEW: ~250 LOC (Tasks 30-36 tests)
```

**PropositionalTest.lean Content**:
```lean
import Logos.Core.Theorems.Propositional
import Logos.Core.Syntax.Formula

namespace Logos.Test.Theorems.Propositional

open Logos.Core.Syntax
open Logos.Core.ProofSystem
open Logos.Core.Theorems.Propositional

/-! ## RAA Tests -/
def test_raa_simple : TestCase := {
  name := "RAA: A → (¬A → B) holds for atoms",
  test := fun () => do
    let A := Formula.atom "A"
    let B := Formula.atom "B"
    assert ([] ⊢ A.imp (A.neg.imp B))  -- Should be provable via raa
}

def test_raa_nested : TestCase := {
  name := "RAA: nested formulas",
  test := fun () => do
    let A := (Formula.atom "P").imp (Formula.atom "Q")
    let B := Formula.atom "R"
    assert ([] ⊢ A.imp (A.neg.imp B))
}

/-! ## EFQ Tests -/
def test_efq_simple : TestCase := ...

/-! ## Conjunction Elimination Tests -/
def test_lce_atoms : TestCase := {
  name := "LCE: extract left from atom conjunction",
  test := fun () => do
    let A := Formula.atom "A"
    let B := Formula.atom "B"
    assert ([A.and B] ⊢ A)  -- Left conjunction elimination
}

def test_rce_atoms : TestCase := ...

/-! ## Test Suite -/
def all_tests : List TestCase := [
  test_raa_simple,
  test_raa_nested,
  test_efq_simple,
  test_lce_atoms,
  test_rce_atoms,
  -- ... (30-40 tests total)
]

end Logos.Test.Theorems.Propositional
```

**Estimated Size**: 300 lines
- 13 theorems × 2-3 test cases each = 30-40 tests
- Each test: ~7 lines (docstring, formula construction, assertion)

**ModalS5Test.lean Content**:
```lean
import Logos.Core.Theorems.ModalS5

namespace Logos.Test.Theorems.ModalS5

/-! ## T-Box-Diamond Tests -/
def test_t_box_to_diamond_atom : TestCase := {
  name := "T-Box-Diamond: □A → ◇A for atom",
  test := fun () => do
    let A := Formula.atom "A"
    assert ([] ⊢ A.box.imp A.diamond)
}

/-! ## Box-Conjunction Tests -/
def test_box_conj_iff_forward : TestCase := {
  name := "Box-Conj: □(A ∧ B) → (□A ∧ □B)",
  test := fun () => do
    let A := Formula.atom "A"
    let B := Formula.atom "B"
    let iff_thm := box_conj_iff A B
    -- Extract forward direction from biconditional
    assert ([] ⊢ (A.and B).box.imp (A.box.and B.box))
}

def test_box_conj_iff_backward : TestCase := ...

/-! ## Test Suite -/
def all_tests : List TestCase := [
  test_t_box_to_diamond_atom,
  test_box_conj_iff_forward,
  test_box_conj_iff_backward,
  -- ... (20-25 tests total)
]

end Logos.Test.Theorems.ModalS5
```

**Estimated Size**: 250 lines
- 7 theorems × 3 test cases each = 21-25 tests
- Each test: ~10 lines (modal operators add complexity)

#### 3.3 Test Coverage Requirements

From TESTING_STANDARDS.md:
- **Unit Test Coverage**: ≥85% for Theorems package
- **Each Theorem**: Minimum 2 test cases (simple + complex)
- **Context-dependent theorems**: Test with empty context and non-empty context

**Coverage Plan**:

| Theorem | Test Cases | Context Variants | Total Tests |
|---------|------------|------------------|-------------|
| RAA (Task 21) | Simple atom, nested formula | Empty | 2 |
| EFQ (Task 22) | Simple, nested | Empty | 2 |
| ECQ (Task 26) | Atom contradiction, complex | [A, ¬A] | 2 |
| LCE/RCE (Task 23) | Atom conj, nested | [A ∧ B] | 4 |
| LDI/RDI (Task 24) | Atom disj, nested | [A] or [B] | 4 |
| RCP (Task 25) | Simple, nested | Γ non-empty | 3 |
| NE/NI (Task 27) | Simple, nested | Γ + assumption | 4 |
| DE (Task 28) | Two cases, complex | (A ∨ B) :: Γ | 3 |
| BI/LBE/RBE (Task 29) | Iff intro, elim | Mixed contexts | 5 |
| **Propositional Total** | | | **29 tests** |
| T-Box-Diamond (Task 30) | Atom, nested | Empty | 2 |
| Box-Conj-Iff (Task 31) | Forward, backward, nested | Empty | 3 |
| Diamond-Disj-Iff (Task 32) | Forward, backward, nested | Empty | 3 |
| S5-Diamond-Box (Task 33) | Simple, complex | Empty | 2 |
| Box-Disj-Intro (Task 34) | Simple, nested | Empty | 2 |
| Box-Contrapose (Task 35) | Simple, nested | Empty | 2 |
| T-Box-Consistency (Task 36) | Atom, complex | Empty | 2 |
| **Modal Total** | | | **16 tests** |
| **Grand Total** | | | **45 tests** |

### 4. Documentation Integration

#### 4.1 Documentation Files to Update

**Primary Updates Required**:

1. **TODO.md** (root):
   - Remove Tasks 21-41 after implementation
   - Add completion note with spec reference

2. **IMPLEMENTATION_STATUS.md** (Documentation/ProjectInfo/):
   - Update Theorems Package section:
     - Add Propositional.lean (9 theorems, 600 LOC, 0 sorry)
     - Add ModalS5.lean (7 theorems, 500 LOC, 0 sorry)
   - Update Summary Table:
     - Theorems modules: 1 → 3
     - Theorems LOC: 1889 → 2989
     - Theorems sorry count: 0 → 0 (unchanged)

3. **CLAUDE.md** (root):
   - Update Theorems Package section (lines 68-75):
     ```markdown
     ### Theorems Package
     - Perpetuity principles (P1-P6): ALL 6 PROVEN (Perpetuity.lean)
     - Propositional theorems: RAA, EFQ, LCE/RCE, LDI/RDI, RCP, ECQ, NE/NI, DE, BI/LBE/RBE (Propositional.lean)
     - Modal S5 theorems: T-Box-Diamond, Box-Conjunction/Disjunction, S5 collapse, Box-Contraposition (ModalS5.lean)
     ```

4. **ARCHITECTURE.md** (Documentation/UserGuide/):
   - Add section 4.3: "Hilbert-Style Derived Theorems"
   - Document propositional and modal S5 theorem catalog

5. **EXAMPLES.md** (Documentation/UserGuide/):
   - Add usage examples for new theorems:
     - Propositional: RAA proof-by-contradiction example
     - Modal S5: Box-conjunction biconditional example

**Secondary Updates** (nice-to-have):

6. **.claude/TODO.md** (spec plans):
   - Add completion summary for spec 057

7. **README.md** (root):
   - Update "Key Features" section to mention Hilbert-style theorem library

#### 4.2 Module Docstrings

**Propositional.lean Docstring**:
```lean
/-!
# Propositional Logic Theorems

This module derives fundamental propositional logic theorems in Hilbert-style
proof system using K and S axioms as foundation.

## Main Theorems

### Contradiction Reasoning
- `raa`: Reductio ad absurdum (`A → (¬A → B)`)
- `efq`: Ex falso quodlibet (`¬A → (A → B)`)
- `ecq`: Ex contradictione quodlibet (`[A, ¬A] ⊢ B`)

### Conjunction and Disjunction
- `lce`, `rce`: Conjunction elimination (left/right)
- `ldi`, `rdi`: Disjunction introduction (left/right)

### Advanced Reasoning
- `rcp`: Reverse contraposition
- `ne`, `ni`: Negation elimination/introduction
- `de`: Disjunction elimination (case analysis)
- `bi`, `lbe`, `rbe`: Biconditional introduction/elimination

## Implementation Notes

All theorems are derived from the K and S propositional axioms:
- K: `(φ → (ψ → χ)) → ((φ → ψ) → (φ → χ))` (distribution)
- S: `φ → (ψ → φ)` (weakening)

Classical reasoning is enabled by the `double_negation` axiom (`¬¬φ → φ`).

Context manipulation theorems (NE, NI, DE, BI) require deduction theorem
infrastructure for full generality.

## References

* [Perpetuity.lean](./Perpetuity.lean) - Reuses combinator infrastructure
* [ARCHITECTURE.md](../../../Documentation/UserGuide/ARCHITECTURE.md) - TM logic specification
-/
```

**ModalS5.lean Docstring**:
```lean
/-!
# Modal S5 Theorems

This module derives theorems specific to S5 modal logic (necessity and possibility
operators) without temporal components.

## Main Theorems

### Basic S5 Properties
- `t_box_to_diamond`: `□A → ◇A` (necessary implies possible)
- `s5_diamond_box`: `◇□A ↔ □A` (S5 characteristic collapse)

### Modal Distribution
- `box_conj_iff`: `□(A ∧ B) ↔ (□A ∧ □B)` (box distributes over conjunction)
- `diamond_disj_iff`: `◇(A ∨ B) ↔ (◇A ∨ ◇B)` (diamond distributes over disjunction)
- `box_disj_intro`: `(□A ∨ □B) → □(A ∨ B)` (one direction only)

### Modal Reasoning Patterns
- `box_contrapose`: Box preserves contraposition
- `t_box_consistency`: Contradictions cannot be necessary

## Implementation Notes

These theorems exploit S5-specific properties:
- Modal T axiom: `□φ → φ` (reflexivity)
- Modal 4 axiom: `□φ → □□φ` (transitivity)
- Modal B axiom: `φ → □◇φ` (symmetry)

The S5 system has the characteristic property that iterated modalities collapse
(e.g., `◇□A ↔ □A`), making it suitable for metaphysical necessity reasoning.

## References

* [Perpetuity.lean](./Perpetuity.lean) - Reuses modal_5, box_mono, diamond_mono
* [Propositional.lean](./Propositional.lean) - Reuses biconditional infrastructure
-/
```

### 5. Import Graph and Dependencies

#### 5.1 Proposed Import Graph

**Current State**:
```
Logos.Core.Syntax.Formula
         ↓
Logos.Core.ProofSystem.Derivation
         ↓
Logos.Core.Theorems.Perpetuity
```

**After Implementation (Option A)**:
```
Logos.Core.Syntax.Formula
         ↓
Logos.Core.ProofSystem.Derivation
         ↓
Logos.Core.Theorems.Perpetuity ────────────────┐
         ↓                                      ↓
Logos.Core.Theorems.Propositional              │
         ↓                                      │
Logos.Core.Theorems.ModalS5 ───────────────────┘
```

**Import Details**:

**Propositional.lean imports**:
```lean
import Logos.Core.ProofSystem.Derivation  -- For Derivable relation
import Logos.Core.Syntax.Formula          -- For Formula type
import Logos.Core.Theorems.Perpetuity     -- For imp_trans, identity, pairing
```

**ModalS5.lean imports**:
```lean
import Logos.Core.Theorems.Perpetuity        -- For modal_5, box_mono, diamond_mono
import Logos.Core.Theorems.Propositional     -- For biconditional infrastructure
```

**No Circular Dependencies**: Clean linear import chain.

#### 5.2 Downstream Impact

**Modules that may import new theorems**:

1. **Automation/ProofSearch.lean**: May use new theorems as lemma database
2. **Metalogic/Soundness.lean**: May need soundness proofs for new theorems (if added to axioms)
3. **Documentation examples**: Archive/BimodalProofs.lean may import for demonstrations

**Impact Assessment**: Minimal. New modules are terminal (no expected downstream consumers in MVP).

### 6. Build and Performance Considerations

#### 6.1 Build Time Estimates

**Current Build Time** (from QUALITY_METRICS.md):
- Total: <2 minutes
- Theorems/Perpetuity.lean: ~25 seconds (1889 lines, complex proofs)

**Projected Build Time with Option A**:
- Propositional.lean: ~15 seconds (600 lines, simpler proofs)
- ModalS5.lean: ~12 seconds (500 lines, medium complexity)
- **Total added time**: ~27 seconds
- **New total**: ~2m27s (within 3-minute acceptable threshold)

**Incremental Compilation**: Lean 4 builds modules independently. Changes to Propositional.lean won't rebuild ModalS5.lean (no reverse dependency).

#### 6.2 Test Execution Time

**Current Test Time**: <30 seconds (110+ tests in PerpetuityTest.lean)

**Projected Test Time**:
- PropositionalTest.lean: ~8 seconds (29 tests, simple formulas)
- ModalS5Test.lean: ~6 seconds (16 tests, modal operators)
- **Total added time**: ~14 seconds
- **New total**: ~44 seconds (within 1-minute acceptable threshold)

### 7. Migration and Integration Checklist

#### Phase 1: File Creation (Day 1)

- [ ] Create `Logos/Core/Theorems/Propositional.lean` with module docstring
- [ ] Create `Logos/Core/Theorems/ModalS5.lean` with module docstring
- [ ] Add imports to both files
- [ ] Verify namespace declarations: `Logos.Core.Theorems.Propositional`, `Logos.Core.Theorems.ModalS5`
- [ ] Create stub theorems with `sorry` placeholders
- [ ] Verify `lake build` succeeds (no syntax errors)

#### Phase 2: Test Infrastructure (Day 1)

- [ ] Create `LogosTest/Core/Theorems/PropositionalTest.lean`
- [ ] Create `LogosTest/Core/Theorems/ModalS5Test.lean`
- [ ] Define test case structure (TestCase type, all_tests list)
- [ ] Add first test for each theorem (simple atom cases with `sorry`)
- [ ] Verify `lake test` runs (tests fail as expected)

#### Phase 3: Implementation (Days 2-10, 77 hours)

- [ ] Implement Phase 1 propositional theorems (Tasks 21-26)
- [ ] Implement Phase 2 modal theorems (Tasks 30-36)
- [ ] Implement Phase 3 context manipulation (Tasks 27-29)
- [ ] Replace all `sorry` with complete proofs
- [ ] Verify `lake build && lake test` passes

#### Phase 4: Documentation (Day 11)

- [ ] Update CLAUDE.md Theorems Package section
- [ ] Update IMPLEMENTATION_STATUS.md with new modules
- [ ] Update TODO.md (remove Tasks 21-41)
- [ ] Add examples to ARCHITECTURE.md and EXAMPLES.md
- [ ] Update .claude/TODO.md with completion summary

#### Phase 5: Validation (Day 11)

- [ ] Run `lake lint` (zero warnings required)
- [ ] Verify test coverage ≥85% for new modules
- [ ] Check documentation completeness (all theorems have docstrings)
- [ ] Review import graph (no circular dependencies)
- [ ] Final `lake build && lake test` verification

## Recommendations

### R1. Use Option A (Two New Module Files) - STRONGLY RECOMMENDED

**Rationale**:
- Maintains modularity and separation of concerns
- File sizes remain manageable (600 + 500 lines vs 2500 monolithic)
- Clear semantic boundaries (propositional, modal-temporal, modal-S5)
- Test organization mirrors source structure cleanly
- Scalable for future theorem additions (Layer 1-3)

**Action Items**:
1. Create `Propositional.lean` and `ModalS5.lean` in `Logos/Core/Theorems/`
2. Create corresponding test files in `LogosTest/Core/Theorems/`
3. Follow import graph: Propositional imports Perpetuity, ModalS5 imports both
4. Namespace: `Logos.Core.Theorems.Propositional`, `Logos.Core.Theorems.ModalS5`

### R2. Implement Test Files Concurrently with Source

**Rationale**:
- Test-driven development (TDD) catches errors early
- Prevents test backlog accumulation
- Maintains ≥85% coverage requirement throughout development

**Action Items**:
1. For each theorem implementation, add 2-3 test cases immediately
2. Run `lake test` after each theorem completion (fail-fast)
3. Aim for 45 total tests (29 propositional + 16 modal)

### R3. Reuse Perpetuity.lean Infrastructure Extensively

**Rationale**:
- `imp_trans`, `identity`, `b_combinator` are already proven
- `modal_5`, `box_mono`, `diamond_mono` available for modal theorems
- Minimizes proof effort, maximizes code reuse

**Action Items**:
1. Import `Logos.Core.Theorems.Perpetuity` in both new modules
2. Open namespace: `open Logos.Core.Theorems.Perpetuity`
3. Use existing lemmas as building blocks (e.g., `pairing` for biconditionals)

### R4. Update Documentation Incrementally

**Rationale**:
- Prevents documentation drift
- Maintains synchronization between code and docs
- Easier than batch update at end

**Action Items**:
1. Update CLAUDE.md immediately after file creation (Phase 1)
2. Update IMPLEMENTATION_STATUS.md after each phase completion
3. Update TODO.md weekly to reflect progress
4. Final documentation pass in Phase 4

### R5. Maintain Import Graph Discipline

**Rationale**:
- Prevents circular dependencies
- Keeps build times low (incremental compilation)
- Simplifies refactoring in future

**Action Items**:
1. Never import ModalS5.lean in Propositional.lean (wrong direction)
2. Never import downstream modules (Automation, Metalogic) in Theorems
3. Verify import graph with: `lake build --verbose` (check recompilation chains)

## Conclusion

The Logos project structure supports clean integration of 21 new Hilbert-style theorems through two new module files (Propositional.lean and ModalS5.lean). This approach maintains modularity, follows existing conventions, and scales for future extensions. Estimated implementation effort aligns with proof strategies report (77 hours), with test infrastructure adding ~14 hours for complete test coverage.

**Critical Success Factors**:
1. **Modularity**: Two new files (600 + 500 lines) vs extending Perpetuity.lean to 2500 lines
2. **Test Coverage**: 45 new tests (29 propositional + 16 modal) achieving ≥85% coverage
3. **Documentation Sync**: Incremental updates to CLAUDE.md, IMPLEMENTATION_STATUS.md, TODO.md
4. **Import Discipline**: Linear import chain (Perpetuity → Propositional → ModalS5)
5. **Build Performance**: <3 minute total build time, <1 minute test time

**Next Steps**: Begin Phase 1 (file creation) after reviewing all three research reports (Mathlib Theorems, Proof Strategies, Project Structure).

---

**Report Statistics**:
- File Organization Options: 3
- Recommended Test Cases: 45
- Documentation Files to Update: 7
- Implementation Checklist Items: 19
- Estimated Module Sizes: Propositional 600 LOC, ModalS5 500 LOC
