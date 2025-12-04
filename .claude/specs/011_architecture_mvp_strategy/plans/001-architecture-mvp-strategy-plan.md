# Logos MVP Development Plan

## Metadata
- **Date**: 2025-12-01
- **Feature**: Strategic MVP Development for Logos LEAN 4 Library
- **Scope**: Build working Layer 0 (Core TM) proof system from empty stubs to functional MVP
- **Estimated Phases**: 4 (MVP) + 5 (Post-MVP, including Phase 6.5)
- **Estimated Hours**: 280-360 hours (MVP: 180-220 hours, Post-MVP: 100-140 hours)
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Status**: [COMPLETE]
- **Structure Level**: 0
- **Complexity Score**: 156.5
- **Research Reports**:
  - [Architecture MVP Strategy Research](/home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/011_architecture_mvp_strategy/reports/001-architecture-mvp-strategy-research.md)

## Overview

This plan transforms the Logos project from empty stub files to a working Minimum Viable Product (MVP) implementing bimodal logic TM (Tense and Modality) with task semantics in LEAN 4.

**Current State**:
- Complete directory structure exists (6 module directories)
- All 15 source files are EMPTY STUBS
- 4 library roots with documentation stubs
- Zero implemented functionality

**MVP Goal**:
A working Layer 0 proof system demonstrating:
1. Formula syntax (propositional + modal + temporal)
2. Complete TM axiom system (8 axiom schemata)
3. Inference rules (MP, MK, TK, TD)
4. Task frame semantics with truth evaluation
5. ONE proven axiom soundness (MT: `□φ → φ`)
6. Comprehensive test infrastructure

**Success Criteria**: `lake build && lake test` succeeds, can derive and validate theorems, metalogic pathway proven.

## Research Summary

Based on ARCHITECTURE.md analysis (1294 lines), the research identified:

- **Layer 0 Components**: 6 modules (Syntax, ProofSystem, Semantics, Metalogic, Theorems, Automation)
- **Dependency Graph**: 8-level hierarchy from foundation (Formula) to advanced metalogic (Completeness)
- **Critical Path**: 10 core files mandatory for MVP (~1,910 LOC)
- **MVP Definition**: Syntax + ProofSystem + Semantics + ONE axiom soundness proof
- **Post-MVP Path**: 4 phases to complete Layer 0 (soundness, perpetuity, automation, completeness)
- **Risk Factors**: Task semantics complexity (HIGH), dependent types challenges (MEDIUM), time estimate accuracy (HIGH)
- **Mitigation Strategy**: TDD, simplest implementations, 50% time buffer, community engagement

**Recommended First Axiom**: MT (Modal T) - `□φ → φ` - simplest S5 axiom, straightforward validity proof.

## Success Criteria

**MVP Completion** (all required):
- [ ] Formula type fully defined with derived operators
- [ ] All 8 TM axiom schemata implemented
- [ ] Derivable relation with 7 inference rules working
- [ ] Task frame structure with nullity/compositionality constraints proven
- [ ] World history with convexity and task relation respect
- [ ] Truth evaluation for all 6 formula types
- [ ] Validity and semantic consequence defined
- [ ] Modal T validity proven (`modal_t_valid`)
- [ ] Soundness theorem stated and proven for MT case
- [ ] Integration test: derive → soundness → validity works
- [ ] Test coverage ≥85% overall, ≥90% metalogic
- [ ] `lake build` succeeds in <2 minutes
- [ ] `lake test` passes all tests
- [ ] Zero `#lint` warnings
- [ ] Every public definition has docstring
- [ ] TODO.md reflects MVP completion

**Post-MVP Milestones**:
- [ ] All 8 axiom validity lemmas proven (Phase 5)
- [ ] P1-P6 perpetuity principles derived (Phase 6)
- [ ] Triangle notation (`△`, `▽`) migrated to perpetuity principles (Phase 6.5)
- [ ] Basic proof automation tactics (Phase 7)
- [ ] Weak and strong completeness proven (Phase 8)

## Technical Design

### Architecture Overview

**Layered Dependency Structure**:
```
Level 0: Syntax/Formula.lean (foundation - no dependencies)
Level 1: Syntax/Context.lean, Semantics/TaskFrame.lean
Level 2: ProofSystem/Axioms.lean
Level 3: Semantics/WorldHistory.lean, Semantics/TaskModel.lean
Level 4: ProofSystem/Derivation.lean, Semantics/Truth.lean
Level 5: Semantics/Validity.lean
Level 6: [MVP boundary]
Level 7: Metalogic/Soundness.lean (MT case only for MVP)
```

**Core Types**:
```lean
-- Syntax
inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | past : Formula → Formula
  | future : Formula → Formula

-- Proof System
inductive Derivable : Context → Formula → Prop where
  | axiom : Axiom φ → Derivable Γ φ
  | assumption : φ ∈ Γ → Derivable Γ φ
  | modus_ponens : Derivable Γ (φ → ψ) → Derivable Γ φ → Derivable Γ ψ
  | modal_k : Derivable (Γ.map box) φ → Derivable Γ (box φ)
  | temporal_k : Derivable (Γ.map future) φ → Derivable Γ (future φ)
  | temporal_duality : Derivable [] φ → Derivable [] (swap_past_future φ)
  | weakening : Derivable Γ φ → Γ ⊆ Δ → Derivable Δ φ

-- Semantics
structure TaskFrame where
  WorldState : Type
  Time : Type
  time_group : OrderedAddCommGroup Time
  task_rel : WorldState → Time → WorldState → Prop
  nullity : ∀ w, task_rel w 0 w
  compositionality : ∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v

def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : F.Time) : Formula → Prop
  | Formula.box φ => ∀ σ : WorldHistory F, truth_at M σ t φ
  | Formula.past φ => ∀ s < t, truth_at M τ s φ
  | Formula.future φ => ∀ s > t, truth_at M τ s φ
  -- ... (6 cases total)
```

### Module Interaction

**Data Flow**:
1. **Formula Construction** (Syntax) → **Derivation** (ProofSystem) → **Soundness** (Metalogic)
2. **Formula Construction** (Syntax) → **Truth Evaluation** (Semantics) → **Validity** (Semantics)
3. **Derivation + Validity** → **Soundness Theorem** (Metalogic)

**Critical Integration Point**: Soundness theorem connects syntactic derivability (`⊢`) with semantic validity (`⊨`).

### Design Decisions

**Decision 1: MT as First Axiom**
- **Rationale**: Simplest S5 axiom, proves reflexivity is most intuitive
- **Alternative**: TF (demonstrates bimodal interaction) - more complex
- **Choice**: MT for MVP, TF for Phase 5

**Decision 2: Minimal Soundness for MVP**
- **Rationale**: Full soundness proof requires 8 complex axiom validity lemmas (~40 hours)
- **Alternative**: Complete all axioms before declaring MVP
- **Choice**: ONE axiom (MT) demonstrates pathway, complete in Phase 5

**Decision 3: Dependent Types for WorldHistory**
- **Rationale**: `states : (t : F.Time) → t ∈ domain → F.WorldState` required by ARCHITECTURE.md
- **Alternative**: Simpler non-dependent signature
- **Choice**: Use dependent types, create helper lemmas, consult Zulip if stuck

**Decision 4: TDD Strict Adherence**
- **Rationale**: CLAUDE.md requires fail-fast, test-first development
- **Alternative**: Implementation-first approach
- **Choice**: Write failing test before ANY implementation code

## Implementation Phases

### Phase 1: Foundation (Syntax Module) [COMPLETE]
dependencies: []

**Objective**: Implement complete formula syntax with derived operators, context type, decidable equality, and comprehensive tests.

**Complexity**: Low

**Tasks**:
- [x] Create `Logos/Syntax.lean` module root (file: `Logos/Syntax.lean`)
- [x] Write failing tests for Formula construction in `LogosTest/Syntax/FormulaTest.lean`
- [x] Implement `Formula` inductive type with 6 constructors (file: `Logos/Syntax/Formula.lean`)
- [x] Implement `DecidableEq Formula` instance (file: `Logos/Syntax/Formula.lean`)
- [x] Implement `Formula.complexity` structural measure (file: `Logos/Syntax/Formula.lean`)
- [x] Write tests for derived Boolean operators (`neg`, `and`, `or`)
- [x] Implement derived Boolean operators (file: `Logos/Syntax/Formula.lean`)
- [x] Write tests for derived modal operators (`diamond`)
- [x] Implement derived modal operators (file: `Logos/Syntax/Formula.lean`)
- [x] Write tests for derived temporal operators (`always`, `sometimes`, `sometime_past`, `sometime_future`)
- [x] Implement derived temporal operators (file: `Logos/Syntax/Formula.lean`)
- [x] Write tests for `swap_past_future` temporal duality
- [x] Implement `swap_past_future` with recursion (file: `Logos/Syntax/Formula.lean`)
- [x] Add comprehensive module docstrings to Formula.lean
- [x] Write failing tests for Context operations in `LogosTest/Syntax/ContextTest.lean`
- [x] Implement `Context` type as `List Formula` (file: `Logos/Syntax/Context.lean`)
- [x] Implement Context helper functions (membership, subset, map) (file: `Logos/Syntax/Context.lean`)
- [x] Add module docstrings to Context.lean
- [x] Update `Logos.lean` to export Syntax module
- [x] Verify `lake build` succeeds with zero warnings
- [x] Verify all Syntax tests pass
- [x] Run `#lint` on Syntax module, fix all warnings
- [x] Update TODO.md with Phase 1 completion

**Testing**:
```bash
# Run syntax tests
lake test LogosTest.Syntax

# Verify decidable equality
#eval (Formula.atom "p") = (Formula.atom "p")  -- true
#eval (Formula.atom "p") = (Formula.atom "q")  -- false

# Verify complexity
#eval (Formula.atom "p").complexity  -- 1
#eval ((Formula.atom "p").imp (Formula.atom "q")).complexity  -- 3
```

**Expected Duration**: 30-40 hours (20% of MVP effort)

### Phase 2: Proof System [COMPLETE]
dependencies: [1]

**Objective**: Implement all 8 TM axiom schemata and Derivable relation with 7 inference rules, enabling theorem derivation.

**Complexity**: Medium

**Tasks**:
- [x] Create `Logos/ProofSystem.lean` module root (file: `Logos/ProofSystem.lean`)
- [x] Write failing tests for axiom instantiation in `LogosTest/ProofSystem/AxiomsTest.lean`
- [x] Implement `Axiom : Formula → Prop` inductive type (file: `Logos/ProofSystem/Axioms.lean`)
- [x] Implement 8 axiom constructors: MT, M4, MB, T4, TA, TL, MF, TF (file: `Logos/ProofSystem/Axioms.lean`)
- [x] Add detailed docstrings explaining each axiom's semantic meaning
- [x] Write tests for each axiom schema instantiation
- [x] Write failing tests for derivation rules in `LogosTest/ProofSystem/DerivationTest.lean`
- [x] Implement `Derivable : Context → Formula → Prop` inductive type (file: `Logos/ProofSystem/Derivation.lean`)
- [x] Implement 7 inference rule constructors (axiom, assumption, modus_ponens, modal_k, temporal_k, temporal_duality, weakening)
- [x] Add notation `Γ ⊢ φ` for `Derivable Γ φ` (file: `Logos/ProofSystem/Derivation.lean`)
- [x] Add notation `⊢ φ` for `Derivable [] φ` (file: `Logos/ProofSystem/Derivation.lean`)
- [x] Write test: Derive theorem using MT axiom
- [x] Write test: Apply modus ponens with assumptions
- [x] Write test: Apply modal K rule
- [x] Create example derivations as inline examples (file: `Logos/ProofSystem/Derivation.lean`)
- [x] Add comprehensive module docstrings to Axioms.lean and Derivation.lean
- [x] Update `Logos.lean` to export ProofSystem module
- [x] Verify `lake build` succeeds
- [x] Verify all ProofSystem tests pass
- [x] Run `#lint` on ProofSystem module, fix warnings
- [x] Update TODO.md with Phase 2 completion

**Testing**:
```bash
# Run proof system tests
lake test LogosTest.ProofSystem

# Example derivations
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  apply Derivable.axiom
  apply Axiom.modal_t

example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply Derivable.modus_ponens
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp
```

**Expected Duration**: 25-30 hours (15% of MVP effort)

### Phase 3: Semantics [COMPLETE]
dependencies: [1]

**Objective**: Implement task frame semantics with world histories, truth evaluation for all formula types, and validity definitions.

**Complexity**: High

**Tasks**:
- [x] Create `Logos/Semantics.lean` module root (file: `Logos/Semantics.lean`)
- [x] Write failing tests for TaskFrame construction in `LogosTest/Semantics/TaskFrameTest.lean`
- [x] Implement `TaskFrame` structure with 4 fields (file: `Logos/Semantics/TaskFrame.lean`)
- [x] Prove `nullity` constraint: `∀ w, task_rel w 0 w`
- [x] Prove `compositionality` constraint: `∀ w u v x y, task_rel w x u → task_rel u y v → task_rel w (x + y) v`
- [x] Create example: Simple integer-based task frame (file: `Logos/Semantics/TaskFrame.lean`)
- [x] Add module docstrings explaining task semantics
- [x] Write tests for TaskFrame constraints and examples
- [x] Write failing tests for convexity in `LogosTest/Semantics/WorldHistoryTest.lean`
- [x] Implement `IsConvex` predicate for time sets (file: `Logos/Semantics/WorldHistory.lean`)
- [x] Prove basic convexity lemmas (empty, singleton, interval convex)
- [x] Write tests for convexity predicate
- [x] Write failing tests for WorldHistory construction
- [x] Implement `WorldHistory` structure with 4 fields (file: `Logos/Semantics/WorldHistory.lean`)
- [x] Implement `respects_task` constraint proof
- [x] Create example: Simple constant world history
- [x] Add module docstrings explaining world histories
- [x] Write tests for WorldHistory construction and constraints
- [x] Write failing tests for TaskModel in `LogosTest/Semantics/TaskModelTest.lean`
- [x] Implement `TaskModel` structure with valuation (file: `Logos/Semantics/TaskModel.lean`)
- [x] Create example: Model for propositional variables {p, q}
- [x] Add module docstrings
- [x] Write tests for TaskModel construction
- [x] Write failing tests for truth evaluation in `LogosTest/Semantics/TruthTest.lean`
- [x] Implement `truth_at` recursive function with 6 cases (file: `Logos/Semantics/Truth.lean`)
- [x] Add notation `M, τ, t ⊨ φ` for `truth_at M τ t φ`
- [x] Prove basic truth lemmas (e.g., `¬(M, τ, t ⊨ Formula.bot)`)
- [x] Write tests for truth evaluation of each formula type (atom, bot, imp, box, past, future)
- [x] Add comprehensive module docstrings
- [x] Write failing tests for validity in `LogosTest/Semantics/ValidityTest.lean`
- [x] Implement `valid : Formula → Prop` (file: `Logos/Semantics/Validity.lean`)
- [x] Implement `semantic_consequence : Context → Formula → Prop`
- [x] Add notation `⊨ φ` for `valid φ` (file: `Logos/Semantics/Validity.lean`)
- [x] Add notation `Γ ⊨ φ` for `semantic_consequence Γ φ`
- [x] Implement `satisfiable : Context → Prop` (file: `Logos/Semantics/Validity.lean`)
- [x] Create concrete example: Frame + Model + History with truth evaluation
- [x] Write integration test using complete semantic example
- [x] Add module docstrings
- [x] Update `Logos.lean` to export Semantics module
- [x] Verify `lake build` succeeds
- [x] Verify all Semantics tests pass (target ≥85% coverage)
- [x] Run `#lint` on Semantics module, fix warnings
- [x] Update TODO.md with Phase 3 completion

**Testing**:
```bash
# Run semantics tests
lake test LogosTest.Semantics

# Example task frame
def test_frame : TaskFrame := {
  WorldState := Nat,
  Time := ℤ,
  time_group := Int.orderedAddCommGroup,
  task_rel := λ w x v => v = w + x.toNat,
  nullity := by intro w; simp,
  compositionality := by intros; simp [add_assoc]
}

# Test truth evaluation
example (M : TaskModel test_frame) (τ : WorldHistory test_frame) (t : ℤ) :
  ¬truth_at M τ t Formula.bot := by intro h; exact h
```

**Expected Duration**: 70-90 hours (40% of MVP effort)

### Phase 4: MVP Metalogic (Modal T Soundness) [COMPLETE]
dependencies: [2, 3]

**Objective**: Prove Modal T axiom validity, state soundness theorem, prove soundness for MT case, and create end-to-end integration test demonstrating metalogic pathway.

**Complexity**: Very High

**Tasks**:
- [x] Create `Logos/Metalogic.lean` module root (file: `Logos/Metalogic.lean`)
- [x] Write type-check test for soundness theorem signature in `LogosTest/Metalogic/SoundnessTest.lean`
- [x] State soundness theorem: `soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ` (file: `Logos/Metalogic/Soundness.lean`)
- [x] Add comprehensive docstring explaining soundness theorem
- [x] Outline proof structure with `sorry` for all cases (axiom, assumption, modus_ponens, modal_k, temporal_k, temporal_duality, weakening)
- [x] Write failing test for Modal T validity in `LogosTest/Metalogic/SoundnessTest.lean`
- [x] State lemma: `modal_t_valid (φ : Formula) : valid (φ.box.imp φ)` (file: `Logos/Metalogic/Soundness.lean`)
- [x] Prove `modal_t_valid` by unfolding definitions and applying reflexivity
- [x] Add detailed proof comments explaining each step
- [x] Write test validating MT soundness works
- [x] Fill in `axiom` case for MT in soundness proof (file: `Logos/Metalogic/Soundness.lean`)
- [x] Use `modal_t_valid` lemma in axiom case
- [x] Leave other axiom cases (M4, MB, T4, TA, TL, MF, TF) as `sorry` with TODO comments
- [x] Write test for soundness applying to MT derivations
- [x] Prove `assumption` case of soundness theorem (file: `Logos/Metalogic/Soundness.lean`)
- [x] Prove `modus_ponens` case of soundness theorem
- [x] Prove `weakening` case of soundness theorem
- [x] Leave inference rule cases (modal_k, temporal_k, temporal_duality) as `sorry`
- [x] Write tests for proven soundness cases (assumption, MP, weakening)
- [x] Create `LogosTest/Integration/EndToEndTest.lean` file
- [x] Write integration test: Derive theorem using MT axiom
- [x] Write integration test: Apply soundness to get validity
- [x] Write integration test: Verify validity directly in semantics
- [x] Write integration test: Confirm derivation path and semantic path agree
- [x] Add comprehensive module docstrings to Soundness.lean
- [x] Update `Logos.lean` to export Metalogic module
- [x] Verify `lake build` succeeds in <2 minutes
- [x] Verify all Metalogic tests pass (target ≥90% coverage)
- [x] Run `#lint` on all modules, fix ALL warnings to zero
- [x] Verify all public definitions have docstrings (100% docBlame coverage)
- [x] Run full test suite: `lake test`
- [x] Verify MVP success criteria met (all 15 criteria from Success Criteria section)
- [x] Write MVP completion summary in TODO.md
- [x] Tag git commit: `v0.1.0-mvp`
- [x] Update TODO.md with Phase 4 completion and MVP COMPLETE status

**Testing**:
```bash
# Run metalogic tests
lake test LogosTest.Metalogic

# Run integration tests
lake test LogosTest.Integration

# End-to-end test
example : True := by
  let proof : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    Derivable.axiom _ (Axiom.modal_t _)
  let valid_proof : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    soundness [] _ proof
  have direct : valid ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    modal_t_valid (Formula.atom "p")
  trivial
```

**Expected Duration**: 55-70 hours (25% of MVP effort)

**MVP COMPLETION CHECKPOINT**: After Phase 4, verify all MVP success criteria met before proceeding to Post-MVP phases.

---

## Post-MVP Implementation Phases

### Phase 5: Complete Soundness [COMPLETE]
dependencies: [4]

**Objective**: Prove validity for all 8 TM axioms and complete all inference rule cases in soundness theorem, achieving full soundness proof with no `sorry`.

**Complexity**: Very High

**Tasks**:
- [x] Prove `modal_4_valid` (□φ → □□φ) - transitivity (file: `Logos/Metalogic/Soundness.lean`)
- [x] Write tests for modal_4_valid
- [x] Prove `modal_b_valid` (φ → □◇φ) - symmetry (file: `Logos/Metalogic/Soundness.lean`)
- [x] Write tests for modal_b_valid
- [x] Prove `temp_4_valid` (Future φ → Future Future φ) - temporal transitivity (file: `Logos/Metalogic/Soundness.lean`)
- [x] Write tests for temp_4_valid
- [x] Prove `modal_future_valid` (□φ → □Future φ) - modal-future interaction (file: `Logos/Metalogic/Soundness.lean`)
- [x] Write tests for modal_future_valid
- [x] Prove `temp_future_valid` (□φ → Future □φ) - temporal-modal interaction (file: `Logos/Metalogic/Soundness.lean`)
- [x] Write tests for temp_future_valid
- [x] Prove `temp_a_valid` (φ → Future past φ) - temporal connectedness (file: `Logos/Metalogic/Soundness.lean`)
- [x] Write tests for temp_a_valid
- [x] Prove `temp_l_valid` (always φ → Future Past φ) - perpetuity (file: `Logos/Metalogic/Soundness.lean`)
- [x] Write tests for temp_l_valid
- [x] Complete `modal_k` soundness case (file: `Logos/Metalogic/Soundness.lean`)
- [x] Write tests for modal_k soundness
- [x] Complete `temporal_k` soundness case (file: `Logos/Metalogic/Soundness.lean`)
- [x] Write tests for temporal_k soundness
- [x] Complete `temporal_duality` soundness case (file: `Logos/Metalogic/Soundness.lean`)
- [x] Write tests for temporal_duality soundness
- [x] Verify soundness theorem has NO `sorry` remaining
- [x] Run full soundness integration tests
- [x] Update documentation with complete soundness proof
- [x] Verify `lake build` succeeds
- [x] Verify all tests pass (100% metalogic coverage)
- [x] Run `#lint`, fix warnings
- [x] Tag git commit: `v0.2.0-full-soundness`
- [x] Update TODO.md with Phase 5 completion

**Testing**:
```bash
# Test each axiom validity
example : valid ((Formula.atom "p").box.imp (Formula.atom "p").box.box) :=
  modal_4_valid (Formula.atom "p")

# Verify soundness applies to all axioms
example (φ : Formula) (h : ⊢ φ) : ⊨ φ := soundness [] φ h
```

**Expected Duration**: 40-50 hours (15% of post-MVP effort)

### Phase 6: Perpetuity Principles [COMPLETE]
dependencies: [5]

**Objective**: Derive all six perpetuity principles (P1-P6) as theorems in the TM proof system, demonstrating deep bimodal connections.

**Complexity**: High

**Tasks**:
- [x] Create `Logos/Theorems.lean` module root (file: `Logos/Theorems.lean`)
- [x] Write failing test for P1 in `LogosTest/Theorems/PerpetuityTest.lean`
- [x] Derive P1: `□φ → always φ` (necessary implies always) (file: `Logos/Theorems/Perpetuity.lean`)
- [x] Add detailed proof comments for P1
- [x] Write test validating P1 derivation
- [x] Write failing test for P2
- [x] Derive P2: `sometimes φ → ◇φ` (sometimes implies possible) (file: `Logos/Theorems/Perpetuity.lean`)
- [x] Write test validating P2
- [x] Write failing test for P3
- [x] Derive P3: `□φ → □always φ` (necessity of perpetuity) (file: `Logos/Theorems/Perpetuity.lean`)
- [x] Write test validating P3
- [x] Write failing test for P4
- [x] Derive P4: `◇sometimes φ → ◇φ` (possibility of occurrence) (file: `Logos/Theorems/Perpetuity.lean`)
- [x] Write test validating P4
- [x] Write failing test for P5
- [x] Derive P5: `◇sometimes φ → always ◇φ` (persistent possibility) (file: `Logos/Theorems/Perpetuity.lean`)
- [x] Write test validating P5
- [x] Write failing test for P6
- [x] Derive P6: `sometimes □φ → □always φ` (occurrent necessity perpetual) (file: `Logos/Theorems/Perpetuity.lean`)
- [x] Write test validating P6
- [x] Create example usage file: `Archive/BimodalProofs.lean` demonstrating P1-P6
- [x] Add comprehensive module docstrings
- [x] Update `Logos.lean` to export Theorems module
- [x] Verify `lake build` succeeds
- [x] Verify all Theorems tests pass (≥85% coverage)
- [x] Run `#lint`, fix warnings
- [x] Tag git commit: `v0.3.0-perpetuity`
- [x] Update TODO.md with Phase 6 completion

**Testing**:
```bash
# Run theorems tests
lake test LogosTest.Theorems

# Example P1 usage
example (p : Formula) : ⊢ (p.box.imp (always p)) := perpetuity_1 p
```

**Expected Duration**: 35-45 hours (20% of post-MVP effort)

### Phase 6.5: Triangle Notation Migration [COMPLETE]
dependencies: [6]

**Objective**: Update perpetuity principles and related code to use Unicode triangle notation (`△` for `always`, `▽` for `sometimes`) where it improves readability.

**Complexity**: Low

**Tasks**:
- [x] Update `Logos/Theorems/Perpetuity.lean` to use `△` and `▽` notation in docstrings and examples (file: `Logos/Theorems/Perpetuity.lean`)
  - P1: `□φ → △φ` (necessary implies always)
  - P2: `▽φ → ◇φ` (sometimes implies possible)
  - P3: `□φ → □△φ` (necessity of perpetuity)
  - P4: `◇▽φ → ◇φ` (possibility of occurrence)
  - P5: `◇▽φ → △◇φ` (persistent possibility)
  - P6: `▽□φ → □△φ` (occurrent necessity perpetual)
- [x] Update example derivations in Perpetuity.lean to demonstrate triangle notation
- [x] Update `Archive/BimodalProofs.lean` to show both notations side-by-side (file: `Archive/BimodalProofs.lean`)
- [x] Update `LogosTest/Theorems/PerpetuityTest.lean` to add triangle notation tests (file: `LogosTest/Theorems/PerpetuityTest.lean`)
  - Test: `example (p : Formula) : ⊢ (p.box.imp (△p)) := perpetuity_1 p`
  - Test: `example (p : Formula) : ⊢ ((▽p).imp p.diamond) := perpetuity_2 p`
- [x] Verify all triangle notation uses backticks in documentation (per documentation-standards.md)
- [x] Update module docstrings in Perpetuity.lean to reference both notations
- [x] Add examples showing triangle notation with modal operators: `□△p`, `◇▽p`
- [x] Verify `lake build` succeeds
- [x] Verify all tests pass
- [x] Run `#lint`, fix warnings
- [x] Update TODO.md with Phase 6.5 completion

**Testing**:
```bash
# Run theorems tests with triangle notation
lake test LogosTest.Theorems

# Verify notation equivalence
example (p : Formula) : △p = p.always := rfl
example (p : Formula) : ▽p = p.sometimes := rfl

# Example P1 with triangle notation
example (p : Formula) : ⊢ (p.box.imp (△p)) := perpetuity_1 p
```

**Expected Duration**: 4-6 hours (2% of post-MVP effort)

### Phase 7: Basic Automation [COMPLETE]
dependencies: [5]

**Objective**: Implement custom tactics for modal/temporal reasoning and basic proof search to automate common proof patterns.

**Complexity**: Medium-High

**Tasks**:
- [x] Create `Logos/Automation.lean` module root (file: `Logos/Automation.lean`)
- [x] Write failing tests for modal_k_tactic in `LogosTest/Automation/TacticsTest.lean`
- [x] Implement `modal_k_tactic` to apply modal K rule automatically (file: `Logos/Automation/Tactics.lean`)
- [x] Write tests validating modal_k_tactic
- [x] Write failing tests for temporal_k_tactic
- [x] Implement `temporal_k_tactic` to apply temporal K rule automatically (file: `Logos/Automation/Tactics.lean`)
- [x] Write tests validating temporal_k_tactic
- [x] Write failing tests for mp_chain tactic
- [x] Implement `mp_chain` tactic to chain modus ponens applications (file: `Logos/Automation/Tactics.lean`)
- [x] Write tests validating mp_chain
- [x] Write failing tests for assumption_search
- [x] Implement `assumption_search` to find assumptions in context (file: `Logos/Automation/Tactics.lean`)
- [x] Write tests validating assumption_search
- [x] Add comprehensive module docstrings to Tactics.lean
- [x] Write failing tests for proof search in `LogosTest/Automation/ProofSearchTest.lean`
- [x] Implement bounded depth-first search (depth ≤ 5) (file: `Logos/Automation/ProofSearch.lean`)
- [x] Implement simple heuristics (prefer axioms over complex rules)
- [x] Implement proof caching mechanism
- [x] Write tests for proof search on simple formulas
- [x] Add module docstrings to ProofSearch.lean
- [x] Refactor perpetuity proofs (Phase 6) using new tactics
- [x] Create automation examples in `Archive/BimodalProofs.lean`
- [x] Update `Logos.lean` to export Automation module
- [x] Verify `lake build` succeeds
- [x] Verify all Automation tests pass (≥80% coverage)
- [x] Run `#lint`, fix warnings
- [x] Tag git commit: `v0.4.0-automation`
- [x] Update TODO.md with Phase 7 completion

**Testing**:
```bash
# Run automation tests
lake test LogosTest.Automation

# Example tactic usage
example (p : Formula) : [p.box] ⊢ p.box.box := by
  modal_k_tactic
  assumption_search
```

**Expected Duration**: 30-40 hours (15% of post-MVP effort)

### Phase 8: Completeness [COMPLETE]
dependencies: [5]

**Objective**: Prove weak and strong completeness theorems via canonical model construction, achieving full metalogic for Layer 0.

**Complexity**: Very High

**Tasks**:
- [x] Write failing test for maximal consistent sets in `LogosTest/Metalogic/CompletenessTest.lean`
- [x] Define maximal consistent sets (file: `Logos/Metalogic/Completeness.lean`)
- [x] Prove basic properties of consistent sets
- [x] Write failing test for Lindenbaum's lemma
- [x] Prove Lindenbaum's lemma using Zorn's lemma (file: `Logos/Metalogic/Completeness.lean`)
- [x] Write test validating Lindenbaum's lemma
- [x] Define canonical frame (integers as times, maximal consistent sets as states) (file: `Logos/Metalogic/Completeness.lean`)
- [x] Prove canonical frame is a valid TaskFrame
- [x] Define canonical model with valuation (file: `Logos/Metalogic/Completeness.lean`)
- [x] Define canonical histories (file: `Logos/Metalogic/Completeness.lean`)
- [x] Prove canonical histories respect task relation
- [x] Write failing test for modal saturation lemma
- [x] Prove modal saturation lemma (file: `Logos/Metalogic/Completeness.lean`)
- [x] Write test validating modal saturation
- [x] Write failing test for temporal consistency lemma
- [x] Prove temporal consistency lemma (file: `Logos/Metalogic/Completeness.lean`)
- [x] Write test validating temporal consistency
- [x] Write failing test for truth lemma
- [x] Prove truth lemma by mutual induction on formulas (file: `Logos/Metalogic/Completeness.lean`)
- [x] Write test validating truth lemma
- [x] Write failing test for weak completeness
- [x] Prove weak completeness: `⊨ φ → ⊢ φ` (file: `Logos/Metalogic/Completeness.lean`)
- [x] Write test validating weak completeness
- [x] Write failing test for strong completeness
- [x] Prove strong completeness: `Γ ⊨ φ → Γ ⊢ φ` (file: `Logos/Metalogic/Completeness.lean`)
- [x] Write test validating strong completeness
- [x] Create integration tests combining soundness and completeness
- [x] Add comprehensive module docstrings
- [x] Update `Logos.lean` to export updated Metalogic module
- [x] Verify `lake build` succeeds
- [x] Verify all Completeness tests pass (≥90% coverage)
- [x] Run `#lint`, fix warnings
- [x] Tag git commit: `v1.0.0-layer0-complete`
- [x] Update TODO.md with Phase 8 completion
- [x] Update README.md with Layer 0 completion announcement
- [x] Write Layer 0 completion summary

**Testing**:
```bash
# Run completeness tests
lake test LogosTest.Metalogic

# Test soundness + completeness
example (φ : Formula) : (⊨ φ) ↔ (⊢ φ) := by
  constructor
  · exact weak_completeness φ
  · exact soundness [] φ
```

**Expected Duration**: 70-90 hours (50% of post-MVP effort)

**LAYER 0 COMPLETION CHECKPOINT**: After Phase 8, Logos Layer 0 (Core TM) is complete with full soundness, completeness, and automation.

## Testing Strategy

### Test-Driven Development (TDD) Approach

Per CLAUDE.md standards, **strict TDD** is mandatory:

1. **Write Failing Test**: Define expected behavior before implementation
2. **Minimal Implementation**: Write simplest code to make test pass
3. **Refactor**: Clean up while maintaining green tests
4. **Never Skip Tests**: No implementation without corresponding tests

### Test Organization

**Test Directory Structure** (mirrors source structure):
```
LogosTest/
├── Syntax/
│   ├── FormulaTest.lean
│   └── ContextTest.lean
├── ProofSystem/
│   ├── AxiomsTest.lean
│   └── DerivationTest.lean
├── Semantics/
│   ├── TaskFrameTest.lean
│   ├── WorldHistoryTest.lean
│   ├── TaskModelTest.lean
│   ├── TruthTest.lean
│   └── ValidityTest.lean
├── Metalogic/
│   ├── SoundnessTest.lean
│   └── CompletenessTest.lean (Phase 8)
├── Theorems/
│   └── PerpetuityTest.lean (Phase 6)
├── Automation/
│   ├── TacticsTest.lean (Phase 7)
│   └── ProofSearchTest.lean (Phase 7)
└── Integration/
    └── EndToEndTest.lean
```

### Test Coverage Targets

Per Testing Protocols standards:

- **Overall Coverage**: ≥85%
- **Metalogic Coverage**: ≥90% (critical module)
- **Semantics Coverage**: ≥85%
- **Proof System Coverage**: ≥85%
- **Syntax Coverage**: ≥80%
- **Automation Coverage**: ≥80%

### Test Types

**Unit Tests**: Test individual functions/definitions
```lean
-- Example: Formula complexity
example : (Formula.atom "p").complexity = 1 := rfl
example : ((Formula.atom "p").imp (Formula.atom "q")).complexity = 3 := rfl
```

**Integration Tests**: Test module interactions
```lean
-- Example: End-to-end derivation → soundness → validity
example : True := by
  let proof : ⊢ (p.box.imp p) := Derivable.axiom _ (Axiom.modal_t _)
  let valid_proof : ⊨ (p.box.imp p) := soundness [] _ proof
  trivial
```

**Property Tests**: Test general properties
```lean
-- Example: swap_past_future involution
example (φ : Formula) : swap_past_future (swap_past_future φ) = φ := by
  induction φ <;> simp [swap_past_future, *]
```

### Test Execution

```bash
# Run all tests
lake test

# Run specific module tests
lake test LogosTest.Syntax
lake test LogosTest.ProofSystem
lake test LogosTest.Semantics
lake test LogosTest.Metalogic

# Run with verbose output
lake test --verbose

# Build before testing
lake build && lake test
```

### Continuous Integration

**Pre-commit checks**:
1. `lake build` succeeds (zero errors)
2. `lake test` passes (100% pass rate)
3. `#lint` produces zero warnings
4. Test coverage meets targets

**Git hooks**: Configure pre-commit hook to run `lake build && lake test && lake lint`

## Documentation Requirements

### Module-Level Documentation

**Every module file MUST include**:
```lean
/-!
# Module Title

Brief module description (1-2 sentences).

## Main Definitions

- `TypeName`: Description
- `functionName`: Description

## Main Results

- `theoremName`: Natural language statement

## Implementation Notes

Design decisions, limitations, assumptions.

## References

* [Citation] for papers or external resources
-/
```

### Definition-Level Documentation

**Every public definition MUST have docstring**:
```lean
/--
Brief one-line summary.

Detailed explanation of purpose, parameters, return values.
Include usage examples if non-obvious.
-/
def functionName ...
```

### Documentation Standards Compliance

Per Documentation Standards:
- **100% docBlame coverage** required (every public definition)
- **100% docBlameThm coverage** required (every theorem)
- **Module organization** follows standards (see Module Organization doc)
- **Cross-references** use relative paths
- **Code examples** in docstrings must type-check

### Documentation Updates

**Files requiring updates after MVP**:
- [x] `README.md` - Update with MVP completion status
- [x] `docs/ARCHITECTURE.md` - Validate alignment with implementation
- [x] `docs/TUTORIAL.md` - Add getting started examples
- [x] `docs/EXAMPLES.md` - Add MVP examples (MT derivation, truth evaluation)
- [x] `TODO.md` - Reflect current development state

### Lint Compliance

**Zero warnings required**:
```bash
# Run lint on all modules
lake lint

# Run lint on specific file
lake lint Logos/Syntax/Formula.lean

# Fix common lint issues
# - Missing docstrings → Add /-! or /-- comments
# - Unused variables → Remove or prefix with _
# - Naming conventions → Follow LEAN 4 style (camelCase for definitions)
```

## Dependencies

### External LEAN 4 Dependencies

**From lakefile.toml** (assumed based on ARCHITECTURE.md):
```toml
[[require]]
name = "mathlib"
version = "v4.x.x"
```

**Mathlib4 Modules Used**:
- `Mathlib.Data.Set.Basic` - Set operations for WorldHistory domains
- `Mathlib.Algebra.Group.Defs` - OrderedAddCommGroup for Time structure
- `Mathlib.Order.Basic` - Order relations for temporal operators
- `Mathlib.Logic.Basic` - Classical logic foundations
- `Mathlib.Tactic` - Tactic library for proof automation (Phase 7)

### Development Tool Dependencies

**Required tools**:
- LEAN 4 (version specified in `lean-toolchain`)
- Lake (LEAN build tool)
- VS Code with LEAN 4 extension (recommended IDE)
- Git (version control)

**Optional tools**:
- `lean4-mode` for Emacs
- LEAN Zulip account for community support

### Internal Module Dependencies

**Critical dependency paths** (must be built in order):

1. **Foundation**: `Syntax/Formula.lean` (no dependencies)
2. **Level 1**: `Syntax/Context.lean`, `Semantics/TaskFrame.lean`
3. **Level 2**: `ProofSystem/Axioms.lean`
4. **Level 3**: `Semantics/WorldHistory.lean`, `Semantics/TaskModel.lean`
5. **Level 4**: `ProofSystem/Derivation.lean`, `Semantics/Truth.lean`
6. **Level 5**: `Semantics/Validity.lean`
7. **Level 7**: `Metalogic/Soundness.lean` (depends on Derivation + Validity)

**Build order enforced by**: Lake's automatic dependency resolution based on `import` statements.

### Risk: Circular Dependencies

**Mitigation**: Follow dependency graph strictly, never import from higher levels to lower levels.

## Appendix: Development Workflow

### Session-Based Development

**Recommended 90-minute coding session**:

1. **Start** (5 min):
   - Review TODO.md current task
   - Check previous git commit
   - Run `lake build` to ensure clean state

2. **Code** (70 min):
   - Write failing test (TDD)
   - Implement minimal code to pass test
   - Run `lake build && lake test` frequently
   - Use `#check`, `#eval`, `#reduce` for debugging

3. **Verify** (10 min):
   - Full `lake build && lake test`
   - Run `#lint` on modified files
   - Review changes with `git diff`

4. **Document** (10 min):
   - Add/update docstrings
   - Update TODO.md with progress
   - Commit with descriptive message

5. **Reflect** (5 min):
   - Note blockers or questions
   - Plan next session's task
   - Update time estimates if needed

### Git Commit Strategy

**Commit message format**:
```
<type>(<scope>): <description>

[optional body explaining why, not what]

[optional footer with references]
```

**Types**: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `chore`

**Examples**:
```
feat(syntax): Add Formula inductive type and derived operators
test(syntax): Add comprehensive Formula construction tests
docs(syntax): Add module docstrings for Formula and Context
fix(semantics): Correct WorldHistory convexity constraint
refactor(proof-system): Simplify Derivable.modal_k implementation
```

**Commit granularity**:
- One commit per test + implementation pair
- One commit per module completion
- One commit per phase completion with tag

### Progress Tracking

**Update TODO.md weekly** with:
- Completed tasks (mark with [x])
- Current task (highlight)
- Blockers or risks
- Time estimate adjustments
- Phase progress summary

**Track metrics**:
- LOC implemented vs. target
- Tests passing
- Modules completed
- Build/test time
- Lint warnings (target: 0)

### Community Engagement

**When to use LEAN Zulip**:
- Stuck on dependent types (WorldHistory)
- Complex proof strategies (soundness, completeness)
- LEAN 4 syntax questions
- Performance optimization
- Mathlib4 usage questions

**How to ask**:
1. Provide minimal reproducible example
2. Show what you tried
3. Explain expected vs. actual behavior
4. Link to relevant code (GitHub/Gist)

### Risk Management

**Technical Risks** (from research):

1. **Task Semantics Complexity** (HIGH impact):
   - **Mitigation**: Start with simplest task frame (integers, trivial relation), use `sorry` for complex proofs initially, consult Zulip

2. **Dependent Types Challenges** (MEDIUM impact):
   - **Mitigation**: Study LEAN 4 docs, create simpler examples first, helper lemmas for common patterns

3. **Time Estimate Accuracy** (MEDIUM impact):
   - **Mitigation**: 50% time buffer, celebrate incremental wins, adjust estimates based on actual progress

**Scope Risks**:

1. **Feature Expansion** (MEDIUM probability):
   - **Mitigation**: Strict MVP definition, defer post-MVP features to phases 5-8, regular check against success criteria

2. **Over-Engineering** (MEDIUM probability):
   - **Mitigation**: "Simplest thing that works" principle, no optimization before working code, no abstraction until 3+ uses

### Success Metrics

**Weekly check** (update TODO.md):
- [ ] Phase progress on track (compare actual vs. estimated hours)
- [ ] All new code has tests (TDD compliance)
- [ ] `lake build` succeeds
- [ ] `lake test` passes 100%
- [ ] `#lint` warnings = 0
- [ ] Docstring coverage = 100%
- [ ] No blockers >3 days old (escalate to Zulip)

**Phase completion criteria** (all required):
- [ ] All tasks in phase completed
- [ ] All tests passing
- [ ] Module exported in `Logos.lean`
- [ ] `#lint` zero warnings
- [ ] 100% docstring coverage
- [ ] TODO.md updated
- [ ] Git commit tagged with phase name
- [ ] Phase retrospective notes added

## Conclusion

This plan provides a systematic path from empty stubs to a complete Layer 0 Logos implementation. The 4-phase MVP (180-220 hours) delivers a working proof system with demonstrated soundness, while 4 post-MVP phases (100-140 hours) complete the metalogic framework.

**Critical Success Factors**:
1. **TDD Discipline**: Tests before implementation, no exceptions
2. **Phase Completion**: Finish each phase fully before advancing
3. **Simplicity**: Simplest working implementation, refactor later
4. **Community**: Use LEAN Zulip for blockers
5. **Documentation**: Docstrings from day 1
6. **Time Realism**: 50% buffer, adjust based on actuals

**Next Immediate Action**: Create TODO.md from this plan's task lists (Phases 1-4 for MVP), then begin Phase 1, Task 1.
