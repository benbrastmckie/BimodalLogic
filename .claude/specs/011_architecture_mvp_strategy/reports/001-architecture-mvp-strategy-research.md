# Architecture MVP Strategy Research Report

**Research Topic**: Strategic Task List for Logos MVP Development
**Research Date**: 2025-12-01
**Complexity Level**: 3
**Source Document**: `/home/benjamin/Documents/Philosophy/Projects/Logos/docs/ARCHITECTURE.md`

---

## Executive Summary

This report analyzes the ARCHITECTURE.md specification (1294 lines) to develop a strategic task list for building a Minimum Viable Product (MVP) of the Logos LEAN 4 library. The project implements bimodal logic TM (Tense and Modality) with task semantics.

**Current Project State**:
- Directory structure fully created (6 module directories)
- All source files are EMPTY STUBS
- 4 library roots exist with documentation stubs
- Zero implemented functionality

**MVP Definition**:
A working Layer 0 (Core TM) proof system with:
1. Basic formula syntax (propositional + modal + temporal operators)
2. TM axiom system (8 axiom schemata)
3. Core inference rules (MP, MK, TK, TD)
4. Task frame semantics with truth evaluation
5. ONE proven axiom soundness (demonstrating metalogic pathway)
6. Basic test infrastructure

**Path to Completion**:
The report identifies 4 development phases from MVP to complete Layer 0, with clear dependencies and incremental validation strategy.

---

## 1. Architecture Analysis

### 1.1 Layer 0 (Core TM) Components

The ARCHITECTURE.md defines a **layered operator architecture**:

- **Layer 0 (Core)**: Boolean + Modal (S5) + Temporal (LTL) operators
- **Layer 1 (Future)**: Counterfactual, constitutive, causal operators
- **Layer 2+ (Future)**: Epistemic and normative extensions

**Focus**: This research concentrates exclusively on **Layer 0 (Core TM)** as the MVP target.

#### 1.1.1 Syntax Components (Section 1.1)

**Formula Inductive Type** (`Logos/Syntax/Formula.lean`):
```lean
inductive Formula : Type
  | atom : String → Formula        -- Sentence letters
  | bot : Formula                  -- Falsity ⊥
  | imp : Formula → Formula → Formula  -- Implication →
  | box : Formula → Formula        -- Necessity □
  | past : Formula → Formula       -- Universal past
  | future : Formula → Formula     -- Universal future
```

**Derived Operators** (defined functions, not constructors):
- `neg`: Negation (`φ → ⊥`)
- `and`, `or`: Conjunction/disjunction
- `diamond`: Possibility (`¬□¬φ`)
- `sometime_past`, `sometime_future`: Existential temporal
- `always`, `sometimes`: Combined temporal quantifiers
- `swap_past_future`: Temporal duality transformation

**Supporting Definitions**:
- `DecidableEq Formula`: Decidable equality instance
- `Formula.complexity`: Structural measure for induction
- Context type: `List Formula` (proof contexts)

**Dependencies**: NONE (pure syntax)

**Complexity**: LOW (standard inductive type definition)

#### 1.1.2 Proof System Components (Section 1.2)

**TM Axiom Schemata** (`Logos/ProofSystem/Axioms.lean`):

| Axiom | Schema | Category | Semantic Property |
|-------|--------|----------|-------------------|
| MT | `□φ → φ` | S5 Modal | Reflexivity |
| M4 | `□φ → □□φ` | S5 Modal | Transitivity |
| MB | `φ → □◇φ` | S5 Modal | Symmetry |
| T4 | `Future φ → Future Future φ` | Temporal | Future transitivity |
| TA | `φ → Future past φ` | Temporal | Temporal connectedness |
| TL | `always φ → Future Past φ` | Temporal | Perpetuity |
| MF | `□φ → □Future φ` | Bimodal | Modal-future interaction |
| TF | `□φ → Future □φ` | Bimodal | Temporal-modal interaction |

**NOTE**: Architecture assumes classical propositional tautologies as base system.

**Inference Rules** (`Logos/ProofSystem/Derivation.lean`):

```lean
inductive Derivable : Context → Formula → Prop
  | axiom : Axiom φ → Derivable Γ φ
  | assumption : φ ∈ Γ → Derivable Γ φ
  | modus_ponens : Derivable Γ (φ → ψ) → Derivable Γ φ → Derivable Γ ψ
  | modal_k : Derivable (Γ.map box) φ → Derivable Γ (box φ)
  | temporal_k : Derivable (Γ.map future) φ → Derivable Γ (future φ)
  | temporal_duality : Derivable [] φ → Derivable [] (swap_past_future φ)
  | weakening : Derivable Γ φ → Γ ⊆ Δ → Derivable Δ φ
```

**Dependencies**:
- Requires `Formula` type from Syntax
- Requires `Context` type from Syntax
- Requires `Axiom` type from Axioms

**Complexity**: MEDIUM (requires understanding of Hilbert-style proof systems)

#### 1.1.3 Semantics Components (Section 3.1)

**Task Frame Structure** (`Logos/Semantics/TaskFrame.lean`):

```lean
structure TaskFrame where
  WorldState : Type                           -- W
  Time : Type                                 -- T
  time_group : OrderedAddCommGroup Time       -- T is ordered abelian group
  task_rel : WorldState → Time → WorldState → Prop  -- ⇒

  -- Constraints
  nullity : ∀ w, task_rel w 0 w              -- w ⇒₀ w
  compositionality : ∀ w u v x y,
    task_rel w x u → task_rel u y v →
    task_rel w (x + y) v                      -- w ⇒ₓ u ∧ u ⇒ᵧ v → w ⇒ₓ₊ᵧ v
```

**World History** (`Logos/Semantics/WorldHistory.lean`):

```lean
structure WorldHistory (F : TaskFrame) where
  domain : Set F.Time                         -- Convex set X ⊆ T
  convex : IsConvex F domain                  -- Convexity predicate
  states : (t : F.Time) → t ∈ domain → F.WorldState  -- τ : X → W
  respects_task : ∀ x y (hx : x ∈ domain) (hxy : x + y ∈ domain),
    F.task_rel (states x hx) y (states (x + y) hxy)  -- τ(x) ⇒ᵧ τ(x+y)
```

**Task Model** (`Logos/Semantics/TaskModel.lean`):

```lean
structure TaskModel (F : TaskFrame) where
  valuation : String → Set F.WorldState      -- |p| ⊆ W
```

**Truth Evaluation** (`Logos/Semantics/Truth.lean`):

```lean
def truth_at (M : TaskModel F) (τ : WorldHistory F) (t : F.Time) : Formula → Prop
  | Formula.atom p => t ∈ τ.domain ∧ τ(t) ∈ M.valuation p
  | Formula.bot => False
  | Formula.imp φ ψ => truth_at M τ t φ → truth_at M τ t ψ
  | Formula.box φ => ∀ σ : WorldHistory F, truth_at M σ t φ
  | Formula.past φ => ∀ s < t, truth_at M τ s φ
  | Formula.future φ => ∀ s > t, truth_at M τ s φ
```

**Validity** (`Logos/Semantics/Validity.lean`):

```lean
def valid (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Time),
    M, τ, t ⊨ φ

def semantic_consequence (Γ : Context) (φ : Formula) : Prop :=
  ∀ (F : TaskFrame) (M : TaskModel F) (τ : WorldHistory F) (t : F.Time),
    (∀ ψ ∈ Γ, M, τ, t ⊨ ψ) → M, τ, t ⊨ φ
```

**Dependencies**:
- TaskFrame: None (foundational)
- WorldHistory: Requires TaskFrame, Set operations, convexity
- TaskModel: Requires TaskFrame
- Truth: Requires all above + Formula type
- Validity: Requires Truth evaluation

**Complexity**: HIGH (requires dependent types, Set theory, algebraic structures)

#### 1.1.4 Metalogic Components (Section 4)

**Soundness Theorem** (`Logos/Metalogic/Soundness.lean`):

```lean
theorem soundness (Γ : Context) (φ : Formula) :
  Γ ⊢ φ → Γ ⊨ φ
```

**Structure**: Proof by induction on derivation, requires 8 axiom validity lemmas:
- `modal_t_valid`: Prove `⊨ (□φ → φ)`
- `modal_4_valid`: Prove `⊨ (□φ → □□φ)`
- `modal_b_valid`: Prove `⊨ (φ → □◇φ)`
- `temp_4_valid`: Prove `⊨ (Future φ → Future Future φ)`
- `temp_a_valid`: Prove `⊨ (φ → Future past φ)`
- `temp_l_valid`: Prove `⊨ (always φ → Future Past φ)`
- `modal_future_valid`: Prove `⊨ (□φ → □Future φ)`
- `temp_future_valid`: Prove `⊨ (□φ → Future □φ)`

**Dependencies**:
- Requires complete Syntax module
- Requires complete ProofSystem module
- Requires complete Semantics module

**Complexity**: VERY HIGH (core metalogic proof)

**Completeness Theorem** (`Logos/Metalogic/Completeness.lean`):

```lean
theorem weak_completeness (φ : Formula) : ⊨ φ → ⊢ φ
theorem strong_completeness (Γ : Context) (φ : Formula) : Γ ⊨ φ → Γ ⊢ φ
```

**Structure**: Requires canonical model construction:
- Maximal consistent sets as world states
- Integers as times
- Lindenbaum's lemma (Zorn's lemma)
- Truth lemma (mutual induction)

**Dependencies**: Same as Soundness + additional theory

**Complexity**: VERY HIGH (most complex component)

#### 1.1.5 Theorems Components (Section 1.2)

**Perpetuity Principles** (`Logos/Theorems/Perpetuity.lean`):

Six derived theorems connecting modal and temporal operators:

| Principle | Statement | Meaning |
|-----------|-----------|---------|
| P1 | `□φ → always φ` | Necessary implies always |
| P2 | `sometimes φ → ◇φ` | Sometimes implies possible |
| P3 | `□φ → □always φ` | Necessity of perpetuity |
| P4 | `◇sometimes φ → ◇φ` | Possibility of occurrence |
| P5 | `◇sometimes φ → always ◇φ` | Persistent possibility |
| P6 | `sometimes □φ → □always φ` | Occurrent necessity perpetual |

**Dependencies**: Requires ProofSystem (derive from TM axioms)

**Complexity**: HIGH (requires proof automation or detailed manual proofs)

#### 1.1.6 Automation Components (Section 2)

**Custom Tactics** (`Logos/Automation/Tactics.lean`):
- `modal_reasoning`: Automate S5 modal proofs
- `propositional_reasoning`: Automate propositional steps
- `temporal_reasoning`: Automate temporal steps

**Proof Search** (`Logos/Automation/ProofSearch.lean`):
- `auto_prove`: Bounded depth-first search
- Proof caching mechanisms

**Dependencies**: Requires ProofSystem

**Complexity**: MEDIUM-HIGH (tactical programming in LEAN 4)

---

## 2. Dependency Analysis

### 2.1 Module Dependency Graph

```
Level 0 (Foundation):
  Syntax/Formula.lean (no dependencies)
  Syntax/Context.lean (depends on Formula)

Level 1 (Semantics Foundation):
  Semantics/TaskFrame.lean (no dependencies)

Level 2 (Proof System):
  ProofSystem/Axioms.lean (depends on Formula)

Level 3 (Extended Semantics):
  Semantics/WorldHistory.lean (depends on TaskFrame, Formula)
  Semantics/TaskModel.lean (depends on TaskFrame)

Level 4 (Core Functionality):
  ProofSystem/Derivation.lean (depends on Axioms, Context, Formula)
  Semantics/Truth.lean (depends on TaskModel, WorldHistory, Formula)

Level 5 (High-Level Semantics):
  Semantics/Validity.lean (depends on Truth)

Level 6 (Theorems):
  Theorems/Perpetuity.lean (depends on Derivation)
  Automation/Tactics.lean (depends on Derivation)

Level 7 (Metalogic):
  Metalogic/Soundness.lean (depends on Derivation, Validity)
  Automation/ProofSearch.lean (depends on Derivation, Tactics)

Level 8 (Advanced Metalogic):
  Metalogic/Completeness.lean (depends on Soundness)
  Metalogic/Decidability.lean (depends on Completeness)
```

### 2.2 Critical Path Identification

**Mandatory for MVP** (in order):
1. `Syntax/Formula.lean` - Core data type
2. `Syntax/Context.lean` - Proof contexts
3. `ProofSystem/Axioms.lean` - Axiom schemata
4. `ProofSystem/Derivation.lean` - Inference rules
5. `Semantics/TaskFrame.lean` - Semantic foundation
6. `Semantics/WorldHistory.lean` - Possible worlds
7. `Semantics/TaskModel.lean` - Models with valuation
8. `Semantics/Truth.lean` - Truth evaluation
9. `Semantics/Validity.lean` - Validity relation
10. `Metalogic/Soundness.lean` - ONE axiom validity proof (demonstration)

**Post-MVP (ordered by value)**:
1. Complete soundness proof (all 8 axiom validity lemmas)
2. `Theorems/Perpetuity.lean` - Derive P1-P6
3. `Automation/Tactics.lean` - Proof automation
4. `Metalogic/Completeness.lean` - Completeness theorem
5. `Automation/ProofSearch.lean` - Automated search
6. `Metalogic/Decidability.lean` - Decision procedures

---

## 3. MVP Definition and Scope

### 3.1 MVP Success Criteria

A **Minimum Viable Product** must demonstrate:

1. **Syntax Works**: Can construct TM formulas programmatically
2. **Proof System Works**: Can derive theorems using TM rules
3. **Semantics Works**: Can evaluate truth in task models
4. **Metalogic Pathway**: ONE proven axiom validity (e.g., MT soundness)
5. **Testing Infrastructure**: Basic tests validate each component
6. **Build Success**: `lake build` compiles without errors
7. **Documentation**: Each module has docstrings

**What MVP EXCLUDES**:
- Complete soundness proof (all 8 axioms) - POST-MVP
- Completeness theorem - POST-MVP
- Perpetuity principles P1-P6 - POST-MVP
- Proof automation - POST-MVP
- Decision procedures - POST-MVP
- DSL syntax extensions - POST-MVP

### 3.2 MVP Module Implementation Order

**Phase 1: Foundation** (Est. 20% of total effort)
```
Logos/Syntax/Formula.lean         [~150 lines]
Logos/Syntax/Context.lean         [~50 lines]
LogosTest/Syntax/FormulaTest.lean [~100 lines]
```

**Phase 2: Proof System** (Est. 15% of total effort)
```
Logos/ProofSystem/Axioms.lean           [~100 lines]
Logos/ProofSystem/Derivation.lean       [~150 lines]
LogosTest/ProofSystem/AxiomsTest.lean   [~80 lines]
LogosTest/ProofSystem/DerivationTest.lean [~120 lines]
```

**Phase 3: Semantics** (Est. 40% of total effort)
```
Logos/Semantics/TaskFrame.lean          [~120 lines]
Logos/Semantics/WorldHistory.lean       [~180 lines]
Logos/Semantics/TaskModel.lean          [~80 lines]
Logos/Semantics/Truth.lean              [~150 lines]
Logos/Semantics/Validity.lean           [~100 lines]
LogosTest/Semantics/TaskFrameTest.lean  [~100 lines]
LogosTest/Semantics/TruthTest.lean      [~150 lines]
LogosTest/Semantics/ValidityTest.lean   [~100 lines]
```

**Phase 4: MVP Metalogic** (Est. 25% of total effort)
```
Logos/Metalogic/Soundness.lean          [~200 lines - ONE axiom proof]
LogosTest/Metalogic/SoundnessTest.lean  [~80 lines]
```

**Total MVP Estimate**: ~1,910 lines of code (implementation + tests)

### 3.3 Recommended First Axiom for Soundness

**Choice: MT (Modal T)** - `□φ → φ`

**Rationale**:
1. **Simplest S5 axiom** - Reflexivity is most intuitive
2. **Semantic clarity** - Straightforward to prove: if φ true at all histories, true at current history
3. **No complex interactions** - Pure modal operator, no temporal complexity
4. **Builds confidence** - Success establishes pattern for remaining 7 axioms

**Proof Sketch**:
```lean
lemma modal_t_valid (φ : Formula) : valid (φ.box.imp φ) := by
  intro F M τ t
  intro h_box
  -- h_box : ∀ σ : WorldHistory F, truth_at M σ t φ
  -- Goal: truth_at M τ t φ
  apply h_box τ  -- Instantiate with current history τ
```

**Alternative: TF (Temporal Future)** - `□φ → Future □φ`
More complex but demonstrates bimodal interaction.

---

## 4. Post-MVP Development Phases

### Phase 5: Complete Soundness (Est. 30% of Phase 4 effort)

**Goal**: Prove validity for remaining 7 axioms

**Order by increasing difficulty**:
1. `modal_4_valid` - Transitivity (moderate)
2. `modal_b_valid` - Symmetry (moderate)
3. `temp_4_valid` - Temporal transitivity (moderate)
4. `modal_future_valid` - Modal-future interaction (moderate-hard)
5. `temp_future_valid` - Temporal-modal interaction (hard)
6. `temp_a_valid` - Temporal connectedness (hard)
7. `temp_l_valid` - Perpetuity (very hard)

**Deliverable**: Complete `soundness` theorem with all cases proven.

### Phase 6: Perpetuity Principles (Est. 25% of total effort)

**Goal**: Derive P1-P6 as theorems in TM proof system

**Dependencies**: Complete proof system, partial automation helpful

**Order**:
1. P1: `□φ → always φ` (foundational, used by others)
2. P2: `sometimes φ → ◇φ` (dual of P1)
3. P3: `□φ → □always φ` (builds on P1)
4. P4: `◇sometimes φ → ◇φ` (builds on P2)
5. P5: `◇sometimes φ → always ◇φ` (complex, builds on P2)
6. P6: `sometimes □φ → □always φ` (most complex)

**File**: `Logos/Theorems/Perpetuity.lean`

**Challenge**: Manual proofs will be lengthy; basic automation would help significantly.

### Phase 7: Basic Automation (Est. 20% of total effort)

**Goal**: Implement basic proof tactics to assist theorem proving

**Components**:
1. `Logos/Automation/Tactics.lean`:
   - `modal_k_tactic`: Apply modal K rule automatically
   - `temporal_k_tactic`: Apply temporal K rule automatically
   - `mp_chain`: Chain modus ponens applications
   - `assumption_search`: Find assumptions in context

2. Basic proof search (`Logos/Automation/ProofSearch.lean`):
   - Bounded depth-first search (depth ≤ 5)
   - Simple heuristics (prefer axioms over complex rules)

**Value**: Significantly accelerates perpetuity proofs and user examples.

### Phase 8: Completeness (Est. 40% of total effort)

**Goal**: Prove TM is complete (valid formulas are derivable)

**Major Components**:

1. **Canonical Model Construction**:
   - Define maximal consistent sets
   - Prove Lindenbaum's lemma (extend to maximal consistent)
   - Define canonical frame (integers as times, max consistent sets as states)
   - Define canonical model and histories

2. **Key Lemmas**:
   - Modal saturation lemma
   - Temporal consistency lemma
   - Truth lemma (by mutual induction on formulas)

3. **Main Theorems**:
   - Weak completeness: `⊨ φ → ⊢ φ`
   - Strong completeness: `Γ ⊨ φ → Γ ⊢ φ`

**File**: `Logos/Metalogic/Completeness.lean` (~500-700 lines)

**Challenge**: Most mathematically complex component; requires advanced LEAN skills.

---

## 5. Testing Strategy

### 5.1 Test-First Development (TDD) Approach

Per CLAUDE.md standards, follow strict TDD:

1. **Write failing test** - Define expected behavior
2. **Minimal implementation** - Make test pass
3. **Refactor** - Clean up while maintaining tests

### 5.2 Test Organization by Phase

**Phase 1 Tests** (Syntax):
```lean
-- LogosTest/Syntax/FormulaTest.lean

-- Test formula construction
def test_atom_construction : Formula := Formula.atom "p"
#check test_atom_construction  -- Should compile

-- Test derived operators
def test_negation : Formula := neg (Formula.atom "p")
example : test_negation = (Formula.atom "p").imp Formula.bot := rfl

-- Test complexity measure
example : (Formula.atom "p").complexity = 1 := rfl
example : (Formula.bot).complexity = 1 := rfl
example : ((Formula.atom "p").imp (Formula.atom "q")).complexity = 3 := rfl

-- Test decidable equality
example : (Formula.atom "p") = (Formula.atom "p") := rfl
example : (Formula.atom "p") ≠ (Formula.atom "q") := by decide
```

**Phase 2 Tests** (Proof System):
```lean
-- LogosTest/ProofSystem/DerivationTest.lean

-- Test axiom application
example : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) := by
  apply Derivable.axiom
  apply Axiom.modal_t

-- Test modus ponens
example (p q : Formula) : [p.imp q, p] ⊢ q := by
  apply Derivable.modus_ponens
  · apply Derivable.assumption; simp
  · apply Derivable.assumption; simp

-- Test modal K rule
example (p : Formula) : [p.box] ⊢ p.box.box := by
  apply Derivable.modal_k
  apply Derivable.assumption
  simp
```

**Phase 3 Tests** (Semantics):
```lean
-- LogosTest/Semantics/TaskFrameTest.lean

-- Test task frame construction
def test_frame : TaskFrame := {
  WorldState := Nat,
  Time := ℤ,
  time_group := Int.orderedAddCommGroup,
  task_rel := λ w x v => v = w + x.toNat,
  nullity := by intro w; simp,
  compositionality := by intros; simp [add_assoc]
}

-- LogosTest/Semantics/TruthTest.lean

-- Test truth evaluation for atoms
example (M : TaskModel test_frame) (τ : WorldHistory test_frame) (t : ℤ) :
  truth_at M τ t (Formula.atom "p") ↔
  (t ∈ τ.domain ∧ τ.states t _ ∈ M.valuation "p") := by rfl

-- Test truth for bot
example (M : TaskModel test_frame) (τ : WorldHistory test_frame) (t : ℤ) :
  ¬truth_at M τ t Formula.bot := by
  intro h
  exact h
```

**Phase 4 Tests** (Soundness):
```lean
-- LogosTest/Metalogic/SoundnessTest.lean

-- Test modal T soundness
example : valid ((Formula.atom "p").box.imp (Formula.atom "p")) :=
  modal_t_valid (Formula.atom "p")

-- Test soundness theorem application
example (p : Formula) (h : ⊢ p) : ⊨ p :=
  soundness [] p h
```

### 5.3 Integration Testing

**Post-MVP**: Create integration tests combining multiple modules:

```lean
-- LogosTest/Integration/EndToEndTest.lean

-- Test: Derive theorem, verify it's valid, check soundness
example : True := by
  -- 1. Prove theorem
  let proof : ⊢ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    Derivable.axiom _ (Axiom.modal_t _)

  -- 2. Apply soundness
  let valid_proof : ⊨ ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    soundness [] _ proof

  -- 3. Verify semantic validity directly
  have direct_validity : valid ((Formula.atom "p").box.imp (Formula.atom "p")) :=
    modal_t_valid (Formula.atom "p")

  trivial
```

### 5.4 Test Coverage Targets

Per Testing Protocols standards:

- **Overall Coverage**: ≥85%
- **Metalogic Coverage**: ≥90% (Soundness module critical)
- **Semantics Coverage**: ≥85% (Core functionality)
- **Proof System Coverage**: ≥85% (Core functionality)
- **Syntax Coverage**: ≥80% (Simpler module)

**Measurement**: Use LEAN 4's built-in coverage tools (if available) or manual tracking.

---

## 6. Risk Analysis and Mitigation

### 6.1 Technical Risks

**Risk 1: Task Semantics Complexity**
- **Probability**: HIGH
- **Impact**: HIGH
- **Description**: WorldHistory with convexity and task relation constraints is mathematically complex
- **Mitigation**:
  - Start with simplest task frame (integers as times, trivial task relation)
  - Create helper lemmas for convexity proofs
  - Use `sorry` placeholders during MVP, complete proofs post-MVP
  - Add extensive documentation and examples

**Risk 2: Dependent Types Challenges**
- **Probability**: MEDIUM
- **Impact**: MEDIUM
- **Description**: `WorldHistory.states` uses dependent types `(t : F.Time) → t ∈ domain → F.WorldState`
- **Mitigation**:
  - Study LEAN 4 dependent types documentation thoroughly
  - Create simpler examples before full implementation
  - Consult LEAN Zulip community if stuck
  - Consider simplified signature initially, refine later

**Risk 3: Axiom Validity Proofs**
- **Probability**: MEDIUM
- **Impact**: HIGH
- **Description**: Some axiom validity proofs (especially TL, TA, TF) may be very complex
- **Mitigation**:
  - MVP only requires ONE axiom proof (MT - simplest)
  - Post-MVP: Tackle in order of difficulty
  - Use `sorry` for hard proofs initially, mark as technical debt
  - Seek community examples of similar proofs

**Risk 4: Time Estimates Inaccurate**
- **Probability**: HIGH
- **Impact**: MEDIUM
- **Description**: First LEAN 4 project may take longer than estimated
- **Mitigation**:
  - Build in 50% time buffer for each phase
  - Celebrate incremental milestones
  - Don't rush - quality over speed
  - Iterate based on actual progress

### 6.2 Scope Creep Risks

**Risk 5: Feature Expansion**
- **Probability**: MEDIUM
- **Impact**: MEDIUM
- **Description**: Temptation to add DSL, proof builder, Layer 1 operators before MVP complete
- **Mitigation**:
  - **Strict MVP definition**: Only 10 core files for MVP
  - Document post-MVP features in TODO.md, don't implement
  - Complete each phase fully before starting next
  - Regular check against MVP success criteria

**Risk 6: Over-Engineering**
- **Probability**: MEDIUM
- **Impact**: LOW
- **Description**: Adding unnecessary abstractions or optimizations
- **Mitigation**:
  - Follow "simplest thing that works" principle
  - No optimization before working code
  - No abstractions until pattern appears 3+ times
  - LEAN 4 best practices favor simplicity

---

## 7. Development Workflow Recommendations

### 7.1 Session-Based Development

**Recommended workflow per coding session**:

1. **Start** (5 min):
   - Review TODO.md for current task
   - Check previous session's git commit
   - Ensure `lake build` succeeds before changes

2. **Code** (50 min):
   - Write failing test first (TDD)
   - Implement minimal code to pass test
   - Run `lake build` and `lake test` frequently
   - Use `#check` and `#reduce` liberally

3. **Verify** (10 min):
   - Full `lake build` and `lake test`
   - Check for `#lint` warnings
   - Review changes with `git diff`

4. **Document** (10 min):
   - Add docstrings to new definitions
   - Update TODO.md with progress
   - Commit with descriptive message

5. **Reflect** (5 min):
   - Note any blockers or questions
   - Plan next session's task
   - Update time estimates if needed

### 7.2 Git Commit Strategy

**Commit granularity**:
- One commit per completed test + implementation pair
- One commit per module completion
- One commit per phase completion

**Commit message format**:
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Examples**:
```
feat(syntax): Add Formula inductive type and derived operators
test(syntax): Add comprehensive Formula construction tests
docs(syntax): Add module docstrings for Formula and Context
fix(semantics): Correct WorldHistory convexity constraint
refactor(proof-system): Simplify Derivable.modal_k implementation
```

**Types**: `feat`, `fix`, `docs`, `test`, `refactor`, `perf`, `chore`

### 7.3 Documentation Standards

Per Documentation Standards, every public definition requires:

**Docstring template**:
```lean
/-!
Brief one-line summary.

Detailed description explaining purpose, usage, and key properties.

## Main Definitions

- `TypeName`: Description
- `functionName`: Description

## Main Results

- `theoremName`: Statement in natural language

## Implementation Notes

Any important implementation details, limitations, or design decisions.

## References

* [Citation] for relevant papers or external resources
-/
```

**Example**:
```lean
/-!
# Formula Syntax for Bimodal Logic TM

This module defines the syntax for the bimodal logic TM (Tense and Modality),
combining S5 modal logic with linear temporal logic in a layered architecture.

## Main Definitions

- `Formula`: Inductive type representing TM formulas with primitive operators:
  atom, bot, imp, box, past, future
- `neg`, `and`, `or`: Derived Boolean operators
- `diamond`: Derived possibility operator (¬□¬φ)
- `always`, `sometimes`: Derived temporal quantifiers
- `swap_past_future`: Temporal duality transformation

## Main Results

- `Formula.complexity`: Structural measure for induction
- `DecidableEq Formula`: Decidable equality instance

## Implementation Notes

- We use `imp` and `bot` as primitives following standard Hilbert-style
  formulation to minimize axiom count
- Modal `box` and temporal `past`/`future` are primitive; `diamond` and
  existential temporal operators are derived
- Temporal duality `swap_past_future` enables symmetric temporal reasoning

## References

* "Possible Worlds" paper (source for TM logic and task semantics)
-/
```

---

## 8. Strategic Task List for TODO.md

### 8.1 Phase Structure

The TODO.md should organize tasks into clear phases with:
- **Phase number and name**
- **Success criteria** (when to move to next phase)
- **Estimated effort** (as percentage of total)
- **Ordered task list** with dependencies
- **Testing checklist** per phase

### 8.2 Recommended Task Granularity

**Per task**:
- Completable in 1-3 coding sessions (2-6 hours)
- Single file or tightly coupled file pair
- Clear acceptance criteria
- Testable outcome

**Too granular**: "Define atom constructor" (sub-task of defining Formula)
**Too broad**: "Implement semantics" (should be 5 separate tasks)
**Just right**: "Implement Formula type with decidable equality and complexity measure"

### 8.3 MVP Task List (Phases 1-4)

#### Phase 1: Foundation (20% effort, ~2-3 weeks)

**Success Criteria**:
- Formula type fully defined
- All derived operators working
- Context type defined
- 100% test coverage for syntax
- `lake build` succeeds with zero warnings

**Tasks**:

1. **Setup Syntax Directory Structure**
   - Create `Logos/Syntax.lean` (module root)
   - Files: `Formula.lean`, `Context.lean`
   - Test directory: `LogosTest/Syntax/`

2. **Implement Formula Inductive Type** [`Syntax/Formula.lean`]
   - Define `Formula` with 6 constructors
   - Add `DecidableEq` instance
   - Implement `Formula.complexity` function
   - Add module docstrings
   - **Test**: `FormulaTest.lean` - construction and equality tests

3. **Implement Derived Boolean Operators** [`Syntax/Formula.lean`]
   - Define `neg`, `and`, `or` functions
   - Prove basic equivalences (e.g., double negation)
   - **Test**: `FormulaTest.lean` - derived operator tests

4. **Implement Derived Modal/Temporal Operators** [`Syntax/Formula.lean`]
   - Define `diamond`, `sometime_past`, `sometime_future`
   - Define `always`, `sometimes`
   - Implement `swap_past_future` with recursion
   - **Test**: `FormulaTest.lean` - modal/temporal operator tests

5. **Implement Context Type** [`Syntax/Context.lean`]
   - Define `Context := List Formula`
   - Add helper functions (membership, subset, map)
   - **Test**: `ContextTest.lean` - context operations

6. **Phase 1 Integration**
   - Update `Logos.lean` to export Syntax module
   - Verify full module builds
   - Run all Syntax tests
   - Update TODO.md with Phase 1 completion

#### Phase 2: Proof System (15% effort, ~1-2 weeks)

**Success Criteria**:
- All 8 TM axiom schemata defined
- Derivable relation with 7 rules implemented
- Can construct simple proofs (MT axiom, MP)
- 100% test coverage for proof system
- `lake build` succeeds

**Tasks**:

1. **Implement Axiom Schemata** [`ProofSystem/Axioms.lean`]
   - Define `Axiom : Formula → Prop` inductive type
   - Implement 8 constructors (MT, M4, MB, T4, TA, TL, MF, TF)
   - Add comprehensive docstrings explaining each axiom
   - **Test**: `AxiomsTest.lean` - axiom instantiation tests

2. **Implement Derivable Relation** [`ProofSystem/Derivation.lean`]
   - Define `Derivable : Context → Formula → Prop`
   - Implement 7 inference rule constructors
   - Add notation `Γ ⊢ φ` and `⊢ φ`
   - **Test**: `DerivationTest.lean` - basic derivation tests

3. **Implement Derivation Examples** [`ProofSystem/Derivation.lean`]
   - Example: Derive using MT axiom
   - Example: Modus ponens with assumptions
   - Example: Modal K rule application
   - **Test**: `DerivationTest.lean` - example proofs as tests

4. **Phase 2 Integration**
   - Update `Logos.lean` to export ProofSystem module
   - Verify proof system builds
   - Run all ProofSystem tests
   - Update TODO.md

#### Phase 3: Semantics (40% effort, ~4-5 weeks)

**Success Criteria**:
- Task frame structure defined with constraints
- World histories fully implemented
- Task models with valuation
- Truth evaluation for all 6 formula types
- Validity and semantic consequence defined
- One example task model with truth evaluation
- 85%+ test coverage for semantics
- `lake build` succeeds

**Tasks**:

1. **Implement Task Frame Structure** [`Semantics/TaskFrame.lean`]
   - Define `TaskFrame` structure with 4 fields
   - Add `nullity` and `compositionality` constraint proofs
   - Create example: Simple integer-based task frame
   - Add comprehensive docstrings
   - **Test**: `TaskFrameTest.lean` - frame construction and constraints

2. **Implement Convexity Predicate** [`Semantics/WorldHistory.lean`]
   - Define `IsConvex` predicate for time sets
   - Prove basic convexity lemmas (empty, singleton, interval)
   - **Test**: `WorldHistoryTest.lean` - convexity tests

3. **Implement World History Structure** [`Semantics/WorldHistory.lean`]
   - Define `WorldHistory` structure with 4 fields
   - Implement `respects_task` constraint
   - Create example: Simple constant world history
   - **Test**: `WorldHistoryTest.lean` - history construction

4. **Implement Task Model** [`Semantics/TaskModel.lean`]
   - Define `TaskModel` structure with valuation
   - Create example: Model for propositional variables {p, q}
   - **Test**: `TaskModelTest.lean` - model construction

5. **Implement Truth Evaluation** [`Semantics/Truth.lean`]
   - Define `truth_at` recursive function (6 cases)
   - Add notation `M, τ, t ⊨ φ`
   - Prove basic truth lemmas (e.g., bot never true)
   - **Test**: `TruthTest.lean` - truth evaluation for each formula type

6. **Implement Validity Relations** [`Semantics/Validity.lean`]
   - Define `valid : Formula → Prop`
   - Define `semantic_consequence : Context → Formula → Prop`
   - Add notation `⊨ φ` and `Γ ⊨ φ`
   - Define `satisfiable : Context → Prop`
   - **Test**: `ValidityTest.lean` - validity and consequence tests

7. **Create Concrete Semantic Example** [`Semantics/Validity.lean`]
   - Build complete example: Frame + Model + History
   - Evaluate truth for sample formulas
   - Verify some formulas valid, others invalid
   - **Test**: Integration test using example

8. **Phase 3 Integration**
   - Update `Logos.lean` to export Semantics module
   - Verify semantics builds
   - Run all Semantics tests
   - Update TODO.md

#### Phase 4: MVP Metalogic (25% effort, ~3-4 weeks)

**Success Criteria**:
- Soundness theorem stated
- ONE axiom validity proven (MT recommended)
- Soundness theorem proven for that axiom case
- Integration test: derive → apply soundness → verify validity
- 90%+ test coverage for soundness module
- **MVP COMPLETE**: All success criteria from Section 3.1 met

**Tasks**:

1. **State Soundness Theorem** [`Metalogic/Soundness.lean`]
   - Define theorem signature: `soundness (Γ : Context) (φ : Formula) : Γ ⊢ φ → Γ ⊨ φ`
   - Add comprehensive docstring explaining theorem
   - Outline proof structure with `sorry` for all cases
   - **Test**: Type-check only (no tests yet)

2. **Prove Modal T Validity** [`Metalogic/Soundness.lean`]
   - State lemma: `modal_t_valid (φ : Formula) : valid (φ.box.imp φ)`
   - Prove by unfolding definitions
   - Add detailed proof comments explaining each step
   - **Test**: `SoundnessTest.lean` - validate MT soundness

3. **Prove Soundness for MT Case** [`Metalogic/Soundness.lean`]
   - Fill in `axiom` case for MT in soundness proof
   - Use `modal_t_valid` lemma
   - Leave other axiom cases as `sorry`
   - **Test**: `SoundnessTest.lean` - soundness applies to MT derivations

4. **Complete Remaining Soundness Cases** [`Metalogic/Soundness.lean`]
   - Prove cases: `assumption`, `modus_ponens`, `weakening`
   - Leave inference rule cases (modal_k, temporal_k, temporal_duality) as `sorry`
   - **Test**: Expand `SoundnessTest.lean` for proven cases

5. **Create End-to-End Integration Test** [`LogosTest/Integration/`]
   - Test: Derive theorem using MT
   - Test: Apply soundness to get validity
   - Test: Verify validity directly in semantics
   - Test: Confirm both paths agree
   - **Test**: `EndToEndTest.lean`

6. **MVP Documentation and Cleanup**
   - Verify all public definitions have docstrings
   - Run `#lint` on all modules, fix warnings
   - Update `Logos.lean` with all exports
   - Write MVP completion summary in TODO.md
   - Tag git commit: `v0.1.0-mvp`

### 8.4 Post-MVP Task List (Phases 5-8)

#### Phase 5: Complete Soundness (15% effort, ~2 weeks)

**Success Criteria**:
- All 8 axiom validity lemmas proven
- All inference rule cases proven
- Full soundness theorem proven (no `sorry`)
- 100% metalogic test coverage

**Tasks**:

1. Prove `modal_4_valid` (□φ → □□φ)
2. Prove `modal_b_valid` (φ → □◇φ)
3. Prove `temp_4_valid` (Future φ → Future Future φ)
4. Prove `modal_future_valid` (□φ → □Future φ)
5. Prove `temp_future_valid` (□φ → Future □φ)
6. Prove `temp_a_valid` (φ → Future past φ)
7. Prove `temp_l_valid` (always φ → Future Past φ)
8. Complete `modal_k` soundness case
9. Complete `temporal_k` soundness case
10. Complete `temporal_duality` soundness case
11. Final soundness integration tests

#### Phase 6: Perpetuity Principles (20% effort, ~2-3 weeks)

**Success Criteria**:
- P1-P6 all proven as derivable theorems
- Examples showing usage
- 85%+ test coverage

**Tasks**:

1. Derive P1: □φ → always φ
2. Derive P2: sometimes φ → ◇φ
3. Derive P3: □φ → □always φ
4. Derive P4: ◇sometimes φ → ◇φ
5. Derive P5: ◇sometimes φ → always ◇φ
6. Derive P6: sometimes □φ → □always φ
7. Create examples using perpetuity principles
8. Integration tests for perpetuity

#### Phase 7: Basic Automation (15% effort, ~2 weeks)

**Success Criteria**:
- Modal K, Temporal K tactics working
- Simple MP chaining tactic
- Bounded proof search (depth 5)
- 80%+ automation test coverage

**Tasks**:

1. Implement `modal_k_tactic`
2. Implement `temporal_k_tactic`
3. Implement `mp_chain` tactic
4. Implement `assumption_search`
5. Implement bounded proof search
6. Refactor perpetuity proofs using tactics
7. Add automation tests and examples

#### Phase 8: Completeness (30% effort, ~4-5 weeks)

**Success Criteria**:
- Weak completeness proven
- Strong completeness proven
- Canonical model fully constructed
- 90%+ completeness test coverage

**Tasks**:

1. Define maximal consistent sets
2. Prove Lindenbaum's lemma
3. Construct canonical frame
4. Construct canonical model
5. Construct canonical histories
6. Prove modal saturation lemma
7. Prove temporal consistency lemma
8. Prove truth lemma (mutual induction)
9. Prove weak completeness
10. Prove strong completeness
11. Integration tests for completeness

---

## 9. Example File Templates

### 9.1 Module Template (Formula.lean)

```lean
/-!
# Formula Syntax for Bimodal Logic TM

This module defines the core formula type for the bimodal logic TM,
combining S5 modal operators with linear temporal operators.

## Main Definitions

- `Formula`: Inductive type with 6 primitive constructors
- `neg`, `and`, `or`: Derived Boolean operators
- `diamond`: Derived possibility operator
- `always`, `sometimes`: Derived temporal quantifiers
- `swap_past_future`: Temporal duality transformation

## Main Results

- `Formula.complexity`: Structural complexity measure
- `DecidableEq Formula`: Decidable equality instance

## Implementation Notes

We use `bot` and `imp` as primitive Boolean operators following
standard Hilbert-style formulation. Modal `box` and temporal
`past`/`future` are primitive; derived operators are defined functions.

## References

* "Possible Worlds" paper - Source for TM logic specification
-/

namespace Logos.Syntax

/-! ### Formula Definition -/

/--
Formula type for bimodal logic TM (Tense and Modality).

Primitive constructors: atom, bot, imp, box, past, future.
Derived operators (neg, and, or, diamond, etc.) are defined as functions.
-/
inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | past : Formula → Formula
  | future : Formula → Formula
  deriving Repr

/-! ### Derived Boolean Operators -/

/-- Negation: `¬φ := φ → ⊥` -/
def neg (φ : Formula) : Formula := φ.imp Formula.bot

/-- Conjunction: `φ ∧ ψ := ¬(φ → ¬ψ)` -/
def and (φ ψ : Formula) : Formula := neg (φ.imp (neg ψ))

/-- Disjunction: `φ ∨ ψ := ¬φ → ψ` -/
def or (φ ψ : Formula) : Formula := (neg φ).imp ψ

/-! ### Derived Modal Operators -/

/-- Possibility: `◇φ := ¬□¬φ` -/
def diamond (φ : Formula) : Formula := neg (Formula.box (neg φ))

/-! ### Derived Temporal Operators -/

/-- Existential past: `past φ := ¬Past ¬φ` -/
def sometime_past (φ : Formula) : Formula := neg (Formula.past (neg φ))

/-- Existential future: `future φ := ¬Future ¬φ` -/
def sometime_future (φ : Formula) : Formula := neg (Formula.future (neg φ))

/-- Always: `always φ := Past φ ∧ φ ∧ Future φ` -/
def always (φ : Formula) : Formula :=
  and (and (Formula.past φ) φ) (Formula.future φ)

/-- Sometimes: `sometimes φ := past φ ∨ φ ∨ future φ` -/
def sometimes (φ : Formula) : Formula :=
  or (or (sometime_past φ) φ) (sometime_future φ)

/-! ### Temporal Duality -/

/--
Swap Past and Future operators throughout a formula.
Used for temporal duality theorem: `⊢ φ → ⊢ swap_past_future φ`
-/
def swap_past_future : Formula → Formula
  | Formula.atom p => Formula.atom p
  | Formula.bot => Formula.bot
  | Formula.imp φ ψ => (swap_past_future φ).imp (swap_past_future ψ)
  | Formula.box φ => (swap_past_future φ).box
  | Formula.past φ => (swap_past_future φ).future
  | Formula.future φ => (swap_past_future φ).past

/-! ### Formula Properties -/

/--
Structural complexity measure for formulas.
Used for well-founded induction and proof search bounds.
-/
def Formula.complexity : Formula → Nat
  | Formula.atom _ => 1
  | Formula.bot => 1
  | Formula.imp φ ψ => φ.complexity + ψ.complexity + 1
  | Formula.box φ => φ.complexity + 1
  | Formula.past φ => φ.complexity + 1
  | Formula.future φ => φ.complexity + 1

/-! ### Decidable Equality -/

/-- Decidable equality for formulas enables decision procedures. -/
instance : DecidableEq Formula := by
  intro φ ψ
  cases φ <;> cases ψ
  all_goals { try { apply isFalse; intro h; cases h } }
  all_goals { try { apply isTrue; rfl } }
  -- Handle recursive cases
  case atom.atom p q =>
    if h : p = q then
      subst h
      apply isTrue; rfl
    else
      apply isFalse
      intro heq
      cases heq
      contradiction
  -- Similar for other cases...
  sorry  -- Complete remaining cases

end Logos.Syntax
```

### 9.2 Test Template (FormulaTest.lean)

```lean
/-!
# Tests for Formula Module

Comprehensive tests for formula construction, derived operators,
and formula properties.

## Test Coverage

- Formula construction (all 6 constructors)
- Derived Boolean operators
- Derived modal operators
- Derived temporal operators
- Temporal duality transformation
- Complexity measure
- Decidable equality
-/

import Logos.Syntax.Formula

namespace LogosTest.Syntax

open Logos.Syntax

/-! ### Constructor Tests -/

/-- Test: Atomic formula construction -/
def test_atom : Formula := Formula.atom "p"
#check test_atom  -- Should type-check

/-- Test: Bottom formula construction -/
def test_bot : Formula := Formula.bot
#check test_bot

/-- Test: Implication construction -/
def test_imp : Formula :=
  (Formula.atom "p").imp (Formula.atom "q")
#check test_imp

/-- Test: Box (necessity) construction -/
def test_box : Formula :=
  Formula.box (Formula.atom "p")
#check test_box

/-- Test: Past operator construction -/
def test_past : Formula :=
  Formula.past (Formula.atom "p")
#check test_past

/-- Test: Future operator construction -/
def test_future : Formula :=
  Formula.future (Formula.atom "p")
#check test_future

/-! ### Derived Operator Tests -/

/-- Test: Negation equals implication to bot -/
example (p : Formula) :
  neg p = p.imp Formula.bot := rfl

/-- Test: Double negation -/
example (p : Formula) :
  neg (neg p) = (p.imp Formula.bot).imp Formula.bot := rfl

/-- Test: Conjunction definition -/
example (p q : Formula) :
  and p q = neg (p.imp (neg q)) := rfl

/-- Test: Disjunction definition -/
example (p q : Formula) :
  or p q = (neg p).imp q := rfl

/-- Test: Diamond definition -/
example (p : Formula) :
  diamond p = neg (Formula.box (neg p)) := rfl

/-! ### Complexity Tests -/

/-- Test: Atomic formula has complexity 1 -/
example : (Formula.atom "p").complexity = 1 := rfl

/-- Test: Bot has complexity 1 -/
example : Formula.bot.complexity = 1 := rfl

/-- Test: Implication complexity is sum + 1 -/
example :
  ((Formula.atom "p").imp (Formula.atom "q")).complexity = 3 := rfl

/-- Test: Box complexity is subformula + 1 -/
example :
  (Formula.box (Formula.atom "p")).complexity = 2 := rfl

/-- Test: Complex formula complexity -/
example :
  (Formula.box ((Formula.atom "p").imp (Formula.atom "q"))).complexity = 4 := rfl

/-! ### Decidable Equality Tests -/

/-- Test: Same atoms are equal -/
example : (Formula.atom "p") = (Formula.atom "p") := rfl

/-- Test: Different atoms are unequal -/
example : (Formula.atom "p") ≠ (Formula.atom "q") := by decide

/-- Test: Bot equals bot -/
example : Formula.bot = Formula.bot := rfl

/-- Test: Structural equality -/
example :
  ((Formula.atom "p").imp (Formula.atom "q")) =
  ((Formula.atom "p").imp (Formula.atom "q")) := rfl

/-! ### Temporal Duality Tests -/

/-- Test: swap_past_future preserves atoms -/
example (p : String) :
  swap_past_future (Formula.atom p) = Formula.atom p := rfl

/-- Test: swap_past_future swaps Past to Future -/
example (φ : Formula) :
  swap_past_future (Formula.past φ) =
  Formula.future (swap_past_future φ) := rfl

/-- Test: swap_past_future swaps Future to Past -/
example (φ : Formula) :
  swap_past_future (Formula.future φ) =
  Formula.past (swap_past_future φ) := rfl

/-- Test: swap_past_future is involutive (applying twice is identity) -/
example (φ : Formula) :
  swap_past_future (swap_past_future φ) = φ := by
  induction φ <;> simp [swap_past_future, *]

end LogosTest.Syntax
```

---

## 10. Success Metrics and Monitoring

### 10.1 Phase Completion Checklist

**Per phase completion, verify**:

- [ ] All module files created with complete implementations
- [ ] All test files created with comprehensive coverage
- [ ] `lake build` succeeds with zero errors
- [ ] `lake test` passes all tests
- [ ] `#lint` produces zero warnings
- [ ] All public definitions have docstrings
- [ ] Module exported in `Logos.lean`
- [ ] TODO.md updated with completion status
- [ ] Git commit tagged with phase name
- [ ] Phase retrospective notes added to project log

### 10.2 MVP Completion Criteria (Revisited)

**Before declaring MVP complete**:

1. ✅ **Syntax Works**:
   - Can construct formulas: `Formula.atom "p"`, `(Formula.atom "p").box`
   - Derived operators work: `neg`, `and`, `diamond`, `always`
   - Tests pass for all constructors and derived operators

2. ✅ **Proof System Works**:
   - Can instantiate axioms: `Axiom.modal_t (Formula.atom "p")`
   - Can derive theorems: `⊢ (p.box.imp p)` using MT
   - Can apply modus ponens and other inference rules
   - Tests pass for axioms and derivations

3. ✅ **Semantics Works**:
   - Can construct task frames with constraints proven
   - Can construct world histories respecting convexity and task relation
   - Can evaluate truth: `truth_at M τ t φ` for all formula types
   - Can define validity: `valid φ` and `Γ ⊨ φ`
   - Tests pass for all semantic components

4. ✅ **Metalogic Pathway**:
   - Modal T validity proven: `modal_t_valid : valid (φ.box.imp φ)`
   - Soundness stated and proven for MT case
   - Can apply soundness: derive MT → get validity via soundness
   - Integration test confirms: derivation → soundness → validity

5. ✅ **Testing Infrastructure**:
   - Test suite mirrors library structure
   - Unit tests for each module
   - Integration test combining all modules
   - Test coverage ≥85% overall, ≥90% for metalogic
   - All tests pass

6. ✅ **Build Success**:
   - `lake build` completes in <2 minutes
   - Zero compilation errors
   - Zero #lint warnings
   - All imports resolve correctly

7. ✅ **Documentation**:
   - Every module has file-level docstring
   - Every public definition has docstring
   - README.md updated with MVP status
   - ARCHITECTURE.md references align with implementation
   - TODO.md reflects current state

### 10.3 Progress Tracking Metrics

**Track weekly**:

| Metric | Target | Current | Trend |
|--------|--------|---------|-------|
| Total LOC implemented | 1,910 (MVP) | 0 | ↑ |
| Total LOC tested | ~800 (MVP) | 0 | ↑ |
| Modules completed | 10 (MVP) | 0 | ↑ |
| Tests passing | 100% | - | → |
| Build time | <2 min | - | → |
| Test time | <30 sec | - | → |
| Lint warnings | 0 | - | → |
| Docstring coverage | 100% | - | → |
| Phase progress | Phase 1-4 | Pre-Phase 1 | ↑ |

**Update TODO.md with weekly metrics snapshot.**

---

## 11. Conclusion and Recommendations

### 11.1 Strategic Summary

**Recommendation**: Pursue **4-phase MVP approach** with laser focus on Layer 0 Core TM.

**Rationale**:
1. **Clear scope**: 10 core files, ~1,910 LOC total, well-defined success criteria
2. **Incremental validation**: Each phase delivers testable functionality
3. **Manageable complexity**: Start simple (syntax), build to complex (semantics, metalogic)
4. **Demonstrable value**: MVP proves soundness pathway, establishes project viability
5. **Expansion path**: Post-MVP phases clearly defined (Phases 5-8)

### 11.2 Critical Success Factors

**For MVP success**:

1. **Strict TDD discipline**: Write tests BEFORE implementation, no exceptions
2. **Phase discipline**: Complete each phase fully before moving to next
3. **Simplicity first**: Simplest implementation that works, refactor later
4. **Community engagement**: Use LEAN Zulip for blockers, especially task semantics
5. **Documentation rigor**: Docstrings from day 1, not retrofitted
6. **Regular commits**: Small, frequent commits with descriptive messages
7. **Time realism**: Build in 50% buffer, celebrate incremental wins

### 11.3 Next Immediate Actions

**To begin MVP development**:

1. **Create TODO.md** from Section 8 task lists (Phases 1-4 for MVP)
2. **Set up development environment**:
   - Verify `lake build` works on empty stubs
   - Configure editor (VS Code with LEAN extension recommended)
   - Set up git hooks for pre-commit lint checks
3. **Start Phase 1, Task 1**: Setup Syntax directory structure
4. **Begin TDD cycle**: Write first test in `FormulaTest.lean`
5. **Track progress**: Update TODO.md after each task completion

### 11.4 Long-Term Vision

**Beyond MVP** (Phases 5-8):

- **Phase 5** (Complete Soundness): Prove all 8 axiom validity lemmas → full soundness theorem
- **Phase 6** (Perpetuity): Derive P1-P6 as TM theorems → demonstrate proof system power
- **Phase 7** (Automation): Basic tactics and proof search → improve usability
- **Phase 8** (Completeness): Canonical model construction → complete metalogic

**Timeline estimate** (with buffer):
- MVP (Phases 1-4): 10-14 weeks
- Full Layer 0 (Phases 1-8): 18-24 weeks

**Post-Layer 0 extensions** (deferred):
- DSL syntax extensions (Section 1.1 in ARCHITECTURE.md)
- Proof builder framework (Section 2.1)
- Layer 1 operators (counterfactual, constitutive, causal)
- Integration with model-checker (Section 6.2)

### 11.5 Final Recommendation

**Begin Phase 1 immediately** with:
- Conservative time estimates
- Strict TDD adherence
- Regular progress tracking
- Focus on MVP scope only

**Success will be achieved when**:
- `lake build && lake test` succeeds
- Can derive `⊢ (p.box.imp p)` using MT axiom
- Can prove `modal_t_valid` showing MT is valid
- Can apply `soundness` to connect derivation and validity
- All 7 MVP success criteria met (Section 3.1)

**This report provides the strategic foundation for systematic Logos development from empty stubs to working MVP and beyond.**

---

## Appendix A: File-by-File Implementation Estimates

| File Path | Category | Est. Lines | Complexity | Dependencies | Priority |
|-----------|----------|------------|------------|--------------|----------|
| `Logos/Syntax/Formula.lean` | Syntax | 150 | LOW | None | P1 (MVP) |
| `Logos/Syntax/Context.lean` | Syntax | 50 | LOW | Formula | P1 (MVP) |
| `Logos/ProofSystem/Axioms.lean` | Proof | 100 | LOW | Formula | P2 (MVP) |
| `Logos/ProofSystem/Derivation.lean` | Proof | 150 | MEDIUM | Axioms, Context | P2 (MVP) |
| `Logos/Semantics/TaskFrame.lean` | Semantics | 120 | MEDIUM | None | P3 (MVP) |
| `Logos/Semantics/WorldHistory.lean` | Semantics | 180 | HIGH | TaskFrame | P3 (MVP) |
| `Logos/Semantics/TaskModel.lean` | Semantics | 80 | MEDIUM | TaskFrame | P3 (MVP) |
| `Logos/Semantics/Truth.lean` | Semantics | 150 | HIGH | TaskModel, WorldHistory, Formula | P3 (MVP) |
| `Logos/Semantics/Validity.lean` | Semantics | 100 | MEDIUM | Truth | P3 (MVP) |
| `Logos/Metalogic/Soundness.lean` | Metalogic | 200 | VERY HIGH | Derivation, Validity | P4 (MVP) |
| `Logos/Theorems/Perpetuity.lean` | Theorems | 300 | HIGH | Derivation | P6 (Post) |
| `Logos/Automation/Tactics.lean` | Automation | 200 | MEDIUM-HIGH | Derivation | P7 (Post) |
| `Logos/Automation/ProofSearch.lean` | Automation | 250 | HIGH | Tactics | P7 (Post) |
| `Logos/Metalogic/Completeness.lean` | Metalogic | 600 | VERY HIGH | Soundness | P8 (Post) |
| `Logos/Metalogic/Decidability.lean` | Metalogic | 300 | HIGH | Completeness | P8 (Post) |

**MVP Total**: ~1,280 implementation lines + ~630 test lines = 1,910 lines

**Post-MVP Total**: ~1,650 implementation lines + ~800 test lines = 2,450 lines

**Complete Layer 0**: ~2,930 implementation lines + ~1,430 test lines = **4,360 total lines**

---

## Appendix B: LEAN 4 Resource References

### Official Documentation
- LEAN 4 Manual: https://lean-lang.org/lean4/doc/
- Theorem Proving in LEAN 4: https://lean-lang.org/theorem_proving_in_lean4/
- Functional Programming in LEAN: https://lean-lang.org/functional_programming_in_lean/

### Community Resources
- LEAN Zulip Chat: https://leanprover.zulipchat.com/
- Mathlib4 Documentation: https://leanprover-community.github.io/mathlib4_docs/
- LEAN 4 Examples: https://github.com/leanprover/lean4/tree/master/tests

### Relevant Mathlib4 Modules for Logos
- `Mathlib.Data.Set.Basic`: Set operations for WorldHistory domains
- `Mathlib.Algebra.Group.Defs`: OrderedAddCommGroup for Time structure
- `Mathlib.Order.Basic`: Order relations for temporal operators
- `Mathlib.Logic.Basic`: Classical logic foundations
- `Mathlib.Tactic`: Tactic library for automation

### Modal/Temporal Logic in LEAN
- Search Zulip for "modal logic" implementations
- Look for S5 and LTL formalizations
- Study completeness proofs for similar systems

---

**END OF REPORT**
