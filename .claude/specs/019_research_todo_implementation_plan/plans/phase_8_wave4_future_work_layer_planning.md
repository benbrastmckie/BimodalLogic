# Phase 8: Wave 4 - Future Work and Layer Planning - Detailed Expansion

## Metadata
- **Date**: 2025-12-02
- **Feature**: Decidability module implementation and Layer 1/2/3 architecture planning
- **Status**: [NOT STARTED]
- **Estimated Hours**: 60-100 hours (40-60 hours Phase 8a + 20-40 hours Phase 8b)
- **Standards File**: /home/benjamin/Documents/Philosophy/Projects/Logos/CLAUDE.md
- **Parent Plan**: [001-research-todo-implementation-plan.md](./001-research-todo-implementation-plan.md)
- **Research Reports**:
  - [TODO Implementation Systematic Plan](../reports/001-todo-implementation-systematic-plan.md)

## Overview

Phase 8 represents the culmination of Layer 0 (Core TM) development and the strategic planning for future extensions. This phase splits into two independently executable sub-phases:

**Phase 8a (Decidability Module)**: Implements a tableau-based decision procedure for TM logic satisfiability with formal complexity analysis (Task 10 from TODO.md)

**Phase 8b (Layer Extension Planning)**: Designs architectural extensions for counterfactual, epistemic, and normative operators across three planned layers (Task 11 from TODO.md)

**Critical Dependencies**:
- Phase 8a REQUIRES completion of Phase 7 (completeness proofs) for decidability correctness proofs
- Phase 8b is INDEPENDENT and can begin earlier if needed for architectural planning

**Final Deliverable**: Fully complete Layer 0 with zero `sorry` placeholders and comprehensive architectural roadmap for Layers 1-3

---

## Sub-Phase Structure

### Phase 8a: Decidability Module Implementation [NOT STARTED]
dependencies: [7]

**Objective**: Create comprehensive decidability module with tableau method, satisfiability checking, and complexity analysis

**Complexity**: High

**Estimated Duration**: 40-60 hours

**See**: [Phase 8a Detailed Plan](#phase-8a-decidability-module-detailed-plan)

---

### Phase 8b: Layer 1/2/3 Extension Planning [NOT STARTED]
dependencies: []

**Objective**: Design architectural roadmap for counterfactual (Layer 1), epistemic (Layer 2), and normative (Layer 3) operator extensions

**Complexity**: Medium

**Estimated Duration**: 20-40 hours

**See**: [Phase 8b Detailed Plan](#phase-8b-layer-extension-planning-detailed-plan)

---

## Phase 8a: Decidability Module - Detailed Plan

### Overview

Decidability is the final metalogic property for Layer 0 completion. This sub-phase implements a systematic tableau method for TM logic satisfiability checking with formal complexity analysis.

**Theoretical Foundation**:
- S5 modal logic: EXPTIME-complete (exponential time)
- Linear Temporal Logic (LTL): PSPACE-complete (polynomial space)
- TM bimodal combination: Expected EXPTIME (upper bound analysis required)

**Implementation Strategy**:
1. Design tableau expansion rules for all TM operators
2. Implement systematic tableau construction with closure detection
3. Prove tableau method sound and complete (uses Phase 7 completeness results)
4. Analyze and document time/space complexity bounds

### Task 8a.1: Design Decidability Architecture (8-12 hours) [NOT STARTED]

**Objective**: Design comprehensive tableau-based decision procedure architecture with complexity analysis framework

**Files to Create**:
- `Logos/Metalogic/Decidability.lean` (new module, ~800-1000 lines estimated)

**Research Requirements**:
1. Review S5 modal tableau methods (Fitting, Goré)
2. Review LTL tableau/automata methods (Vardi-Wolper)
3. Analyze bimodal combination complexity (frame-based approach)
4. Design TM-specific tableau expansion rules

**Design Decisions**:

**Decision 1: Tableau Expansion Strategy**
- **Option A**: Prefixed tableau (modal worlds as explicit labels)
- **Option B**: Sequent tableau (context-based approach)
- **Recommendation**: Option A (prefixed tableau) - more natural for modal operators, clearer world structure

**Decision 2: Temporal Handling**
- **Option A**: Explicit time labels with ordering constraints
- **Option B**: Automata-based LTL translation
- **Recommendation**: Option A (explicit time labels) - integrates better with modal prefixes, simpler to prove correct

**Decision 3: Closure Detection**
- **Option A**: Local closure (contradiction at each node)
- **Option B**: Global closure (unsatisfiability across all branches)
- **Recommendation**: Both (local closure for efficiency, global for completeness proof)

**Deliverables**:
```lean
-- File: Logos/Metalogic/Decidability.lean

/-!
# Decidability Module

Tableau-based decision procedure for TM logic satisfiability.

## Contents
1. Tableau data structures (nodes, branches, trees)
2. Expansion rules for each TM operator
3. Closure detection (local and global)
4. Satisfiability checking algorithm
5. Soundness and completeness proofs
6. Complexity analysis (time and space bounds)

## Theoretical Foundation
- S5 modal logic: EXPTIME-complete
- Linear Temporal Logic: PSPACE-complete
- TM combination: EXPTIME (upper bound proven in this module)

## References
- Fitting's modal tableaux (S5 prefixed tableau)
- Vardi-Wolper LTL decision procedures
- Task semantics integration (Logos-specific)
-/

namespace Logos.Metalogic

-- Tableau node: represents a formula at a world-time pair
structure TableauNode where
  world : ℕ  -- Modal world index (S5 accessibility)
  time : ℕ   -- Temporal time index (linear ordering)
  formula : Formula
  deriving Repr, DecidableEq

-- Tableau branch: sequence of nodes with closure status
structure TableauBranch where
  nodes : List TableauNode
  isClosed : Bool  -- Local closure detection
  deriving Repr

-- Tableau tree: branching structure with global closure
structure TableauTree where
  root : Formula  -- Initial formula to check satisfiability
  branches : List TableauBranch
  isGloballyClosed : Bool
  deriving Repr

-- Expansion rules for TM operators (to be implemented in Task 8a.2)
def expand_imp : TableauNode → List TableauNode := sorry
def expand_box : TableauNode → List TableauNode := sorry
def expand_diamond : TableauNode → List TableauNode := sorry
def expand_past : TableauNode → List TableauNode := sorry
def expand_future : TableauNode → List TableauNode := sorry

-- Closure detection (to be implemented in Task 8a.2)
def is_locally_closed : TableauBranch → Bool := sorry
def is_globally_closed : TableauTree → Bool := sorry

-- Satisfiability checking (to be implemented in Task 8a.2)
def is_satisfiable : Formula → Bool := sorry

-- Soundness: if tableau is open, formula is satisfiable
axiom tableau_soundness : ∀ φ : Formula,
  is_satisfiable φ = true → ∃ M : TaskModel, truth_at M h t φ

-- Completeness: if formula is satisfiable, tableau is open
axiom tableau_completeness : ∀ φ : Formula,
  (∃ M : TaskModel, truth_at M h t φ) → is_satisfiable φ = true

-- Complexity bounds (to be proven in Task 8a.3)
axiom time_complexity : ∀ φ : Formula,
  tableau_time φ ≤ 2^(exponential (formula_size φ))

axiom space_complexity : ∀ φ : Formula,
  tableau_space φ ≤ polynomial (formula_size φ)

end Logos.Metalogic
```

**Architecture Documentation**:
- Create `Documentation/Reference/DECIDABILITY.md`:
  - Tableau expansion rules specification
  - Closure detection algorithm
  - Complexity analysis methodology
  - Example tableau constructions

**Testing Strategy**:
```bash
# Verify architecture compiles
lake build Logos.Metalogic.Decidability

# Verify all axioms declared (not yet proven)
grep -c "axiom" Logos/Metalogic/Decidability.lean  # Expected: 4
```

**Expected Duration**: 8-12 hours

---

### Task 8a.2: Implement Tableau Method (20-30 hours) [NOT STARTED]

**Objective**: Implement systematic tableau construction with expansion rules and closure detection for all TM operators

**Implementation Phases**:

**Phase 1: Core Data Structures (4-6 hours)**

```lean
-- Tableau node with provenance tracking
structure TableauNode where
  world : ℕ
  time : ℕ
  formula : Formula
  parent : Option ℕ  -- Parent node index for proof reconstruction
  rule : String       -- Expansion rule that created this node
  deriving Repr, DecidableEq

-- Tableau branch with closure evidence
structure TableauBranch where
  nodes : List TableauNode
  isClosed : Bool
  closureWitness : Option (ℕ × ℕ)  -- Indices of contradictory nodes (φ, ¬φ)
  deriving Repr

-- Tableau tree with construction history
structure TableauTree where
  root : Formula
  branches : List TableauBranch
  isGloballyClosed : Bool
  constructionSteps : ℕ  -- For complexity tracking
  deriving Repr

-- Tableau construction state
structure TableauState where
  tree : TableauTree
  unexpandedNodes : List (ℕ × ℕ)  -- (branch_index, node_index) pairs
  worldCount : ℕ                   -- Current world count
  timeCount : ℕ                    -- Current time count
  deriving Repr
```

**Phase 2: Propositional Expansion Rules (3-5 hours)**

```lean
-- Expand implication: φ → ψ at (w, t)
-- Rule: Either expand to ¬φ or ψ at (w, t) (branching)
def expand_imp (w : ℕ) (t : ℕ) (φ ψ : Formula) : List (List TableauNode) :=
  [ [TableauNode.mk w t (neg φ) none "imp_left"],
    [TableauNode.mk w t ψ none "imp_right"] ]

-- Expand bottom: ⊥ at (w, t)
-- Rule: Close branch (contradiction)
def expand_bot (w : ℕ) (t : ℕ) : List (List TableauNode) :=
  []  -- Empty list indicates closure

-- Expand double negation: ¬¬φ at (w, t)
-- Rule: Expand to φ at (w, t) (linear)
def expand_double_neg (w : ℕ) (t : ℕ) (φ : Formula) : List (List TableauNode) :=
  [ [TableauNode.mk w t φ none "double_neg"] ]

-- Expand negated implication: ¬(φ → ψ) at (w, t)
-- Rule: Expand to φ and ¬ψ at (w, t) (conjunction)
def expand_neg_imp (w : ℕ) (t : ℕ) (φ ψ : Formula) : List (List TableauNode) :=
  [ [TableauNode.mk w t φ none "neg_imp_left",
     TableauNode.mk w t (neg ψ) none "neg_imp_right"] ]
```

**Phase 3: Modal Expansion Rules (4-6 hours)**

```lean
-- Expand box: □φ at (w, t)
-- S5 Rule: Add φ at (w', t) for ALL worlds w' (including new worlds)
-- Implementation: Mark for propagation to all current and future worlds
def expand_box (w : ℕ) (t : ℕ) (φ : Formula) (allWorlds : List ℕ) : List (List TableauNode) :=
  [ allWorlds.map (λ w' => TableauNode.mk w' t φ none "box") ]

-- Expand diamond: ◇φ at (w, t)
-- S5 Rule: Add φ at (w', t) for SOME world w' (create new world or choose existing)
-- Implementation: Create new world for witness
def expand_diamond (w : ℕ) (t : ℕ) (φ : Formula) (newWorld : ℕ) : List (List TableauNode) :=
  [ [TableauNode.mk newWorld t φ none "diamond"] ]

-- Expand negated box: ¬□φ at (w, t)
-- S5 Rule: Equivalent to ◇¬φ (create witness world)
def expand_neg_box (w : ℕ) (t : ℕ) (φ : Formula) (newWorld : ℕ) : List (List TableauNode) :=
  [ [TableauNode.mk newWorld t (neg φ) none "neg_box"] ]

-- Expand negated diamond: ¬◇φ at (w, t)
-- S5 Rule: Equivalent to □¬φ (propagate to all worlds)
def expand_neg_diamond (w : ℕ) (t : ℕ) (φ : Formula) (allWorlds : List ℕ) : List (List TableauNode) :=
  [ allWorlds.map (λ w' => TableauNode.mk w' t (neg φ) none "neg_diamond") ]
```

**Phase 4: Temporal Expansion Rules (4-6 hours)**

```lean
-- Expand past: Pφ at (w, t)
-- LTL Rule: Add φ at (w, t-1) if t > 0, otherwise close branch
def expand_past (w : ℕ) (t : ℕ) (φ : Formula) : List (List TableauNode) :=
  if t > 0 then
    [ [TableauNode.mk w (t - 1) φ none "past"] ]
  else
    []  -- Closure: no time before t=0

-- Expand future: Fφ at (w, t)
-- LTL Rule: Add φ at (w, t+1) or later (unbounded future)
-- Implementation: Create successor time t+1
def expand_future (w : ℕ) (t : ℕ) (φ : Formula) : List (List TableauNode) :=
  [ [TableauNode.mk w (t + 1) φ none "future"] ]

-- Expand negated past: ¬Pφ at (w, t)
-- LTL Rule: Add ¬φ at (w, t-1) if t > 0, otherwise satisfiable
def expand_neg_past (w : ℕ) (t : ℕ) (φ : Formula) : List (List TableauNode) :=
  if t > 0 then
    [ [TableauNode.mk w (t - 1) (neg φ) none "neg_past"] ]
  else
    [ [] ]  -- Satisfiable: no past to violate

-- Expand negated future: ¬Fφ at (w, t)
-- LTL Rule: Add ¬φ at (w, t+1) or create loop (eventuality detection)
-- Implementation: Bounded model checking approach (limit future depth)
def expand_neg_future (w : ℕ) (t : ℕ) (φ : Formula) (maxDepth : ℕ) : List (List TableauNode) :=
  if t < maxDepth then
    [ [TableauNode.mk w (t + 1) (neg φ) none "neg_future"] ]
  else
    [ [] ]  -- Loop: assume cyclic satisfaction
```

**Phase 5: Closure Detection (3-5 hours)**

```lean
-- Local closure: branch contains both φ and ¬φ at same (w, t)
def is_locally_closed (branch : TableauBranch) : Bool :=
  branch.nodes.any (λ n1 =>
    branch.nodes.any (λ n2 =>
      n1.world = n2.world ∧
      n1.time = n2.time ∧
      n1.formula = neg n2.formula))

-- Update closure witness when contradiction found
def find_closure_witness (branch : TableauBranch) : Option (ℕ × ℕ) :=
  branch.nodes.findIdx? (λ n1 =>
    branch.nodes.findIdx? (λ n2 =>
      n1.world = n2.world ∧ n1.time = n2.time ∧ n1.formula = neg n2.formula))

-- Global closure: all branches are locally closed
def is_globally_closed (tree : TableauTree) : Bool :=
  tree.branches.all (λ b => b.isClosed)

-- Satisfiability: tree construction terminates with open branch
def is_satisfiable (φ : Formula) : Bool :=
  let tree := construct_tableau φ max_depth
  ¬ tree.isGloballyClosed
```

**Phase 6: Systematic Tableau Construction (6-8 hours)**

```lean
-- Systematic expansion: apply rules until no unexpanded nodes or closure
partial def construct_tableau_step (state : TableauState) : TableauState :=
  match state.unexpandedNodes with
  | [] => state  -- Termination: no more nodes to expand
  | (branchIdx, nodeIdx) :: rest =>
      let branch := state.tree.branches[branchIdx]
      let node := branch.nodes[nodeIdx]

      -- Apply expansion rule based on formula structure
      let expansions := match node.formula with
        | Formula.imp φ ψ => expand_imp node.world node.time φ ψ
        | Formula.box φ => expand_box node.world node.time φ (List.range state.worldCount)
        | Formula.past φ => expand_past node.world node.time φ
        | Formula.future φ => expand_future node.world node.time φ
        | _ => [ [] ]  -- Literal or already expanded

      -- Create new branches for each expansion
      let newBranches := expansions.map (λ newNodes =>
        { branch with nodes := branch.nodes ++ newNodes })

      -- Check closure for each new branch
      let closedBranches := newBranches.map (λ b =>
        { b with isClosed := is_locally_closed b })

      -- Update state with new branches and unexpanded nodes
      let newUnexpanded := collect_unexpanded_nodes closedBranches
      construct_tableau_step {
        tree := { state.tree with branches := closedBranches },
        unexpandedNodes := rest ++ newUnexpanded,
        worldCount := state.worldCount + 1,  -- Increment for diamond expansion
        timeCount := state.timeCount + 1,    -- Increment for future expansion
      }

-- Main tableau construction with depth bound (for termination)
def construct_tableau (φ : Formula) (maxDepth : ℕ) : TableauTree :=
  let initialState : TableauState := {
    tree := { root := φ, branches := [ { nodes := [TableauNode.mk 0 0 φ none "root"], isClosed := false, closureWitness := none } ], isGloballyClosed := false, constructionSteps := 0 },
    unexpandedNodes := [(0, 0)],
    worldCount := 1,
    timeCount := 1
  }
  (construct_tableau_step initialState).tree
```

**Testing Strategy**:
```bash
# Test propositional tableau
lake test LogosTest.Metalogic.DecidabilityTest  -- Test: p → (q → p) satisfiable

# Test modal tableau
lake test LogosTest.Metalogic.DecidabilityTest  -- Test: □p → p satisfiable (modal T)

# Test temporal tableau
lake test LogosTest.Metalogic.DecidabilityTest  -- Test: Fp ∨ ¬Fp satisfiable

# Test closure detection
lake test LogosTest.Metalogic.DecidabilityTest  -- Test: p ∧ ¬p unsatisfiable
```

**Expected Duration**: 20-30 hours

---

### Task 8a.3: Prove Correctness and Analyze Complexity (8-12 hours) [NOT STARTED]

**Objective**: Prove tableau method sound and complete using Phase 7 completeness results, analyze time/space complexity bounds

**Proof Strategy**:

**Soundness Proof (4-6 hours)**:

```lean
-- Soundness: if tableau is open, formula is satisfiable
theorem tableau_soundness (φ : Formula) :
  is_satisfiable φ = true → ∃ M : TaskModel, ∃ h : WorldHistory, ∃ t : Time, truth_at M h t φ := by
  intro h_sat
  -- Strategy: construct model from open tableau branch
  unfold is_satisfiable at h_sat

  -- Step 1: Extract open branch from tableau
  have open_branch : ∃ b : TableauBranch, b ∈ (construct_tableau φ max_depth).branches ∧ ¬b.isClosed := by
    sorry  -- Use global closure negation

  obtain ⟨branch, _, h_open⟩ := open_branch

  -- Step 2: Construct canonical model from branch nodes
  let worlds := branch.nodes.map (λ n => n.world) |>.dedup
  let times := branch.nodes.map (λ n => n.time) |>.dedup

  -- Define task relation from modal accessibility (S5: universal)
  let task_rel : WorldState → WorldState → Prop := λ _ _ => True

  -- Define valuation from branch literals
  let valuation : Atom → WorldState → Prop := λ a w =>
    branch.nodes.any (λ n => n.world = w ∧ n.formula = Formula.atom a)

  -- Step 3: Prove constructed model satisfies φ
  -- Uses completeness results from Phase 7 (canonical model construction)
  sorry  -- Detailed proof using Phase 7 lemmas
```

**Completeness Proof (4-6 hours)**:

```lean
-- Completeness: if formula is satisfiable, tableau is open
theorem tableau_completeness (φ : Formula) :
  (∃ M : TaskModel, ∃ h : WorldHistory, ∃ t : Time, truth_at M h t φ) → is_satisfiable φ = true := by
  intro ⟨M, h, t, h_sat⟩
  unfold is_satisfiable

  -- Strategy: prove tableau expansion preserves satisfiability

  -- Step 1: Show each expansion rule preserves satisfiability
  have exp_preserves_sat : ∀ node : TableauNode, ∀ expansions : List (List TableauNode),
    (∃ M h t, truth_at M h t node.formula) →
    (∃ expansion ∈ expansions, ∃ M h t, ∀ n ∈ expansion, truth_at M h t n.formula) := by
    sorry  -- Case analysis on expansion rules

  -- Step 2: Show systematic construction explores all satisfying branches
  have systematic_explores_all : ∀ M h t, truth_at M h t φ →
    ∃ branch ∈ (construct_tableau φ max_depth).branches,
      ∀ n ∈ branch.nodes, truth_at M h t n.formula := by
    sorry  -- Induction on construction steps

  -- Step 3: Show satisfying branches cannot be closed
  have sat_branch_open : ∀ branch : TableauBranch,
    (∃ M h t, ∀ n ∈ branch.nodes, truth_at M h t n.formula) →
    ¬branch.isClosed := by
    intro branch ⟨M, h, t, h_all_sat⟩ h_closed
    unfold is_locally_closed at h_closed
    -- Contradiction: both φ and ¬φ satisfied at (w, t)
    sorry

  -- Combine steps: if φ satisfiable, some branch is open
  sorry  -- Use Phase 7 completeness for canonical model
```

**Complexity Analysis Documentation**:

Create `Documentation/Reference/DECIDABILITY.md` complexity section:

```markdown
## Complexity Analysis

### Time Complexity

**Upper Bound**: EXPTIME (exponential time in formula size)

**Proof Sketch**:
1. Modal depth d = maximum nesting of □/◇ operators
2. S5 requires at most 2^d worlds (exponential in modal depth)
3. Temporal depth t = maximum nesting of P/F operators
4. LTL requires at most |φ| time points (linear in formula size)
5. Each tableau node expansion: O(|φ|) time
6. Total nodes: O(2^d × |φ| × |φ|) = O(2^d × |φ|^2)
7. Total time: O(|φ| × 2^d × |φ|^2) = O(2^d × |φ|^3)

**Tighter Bound**: Since modal depth d ≤ |φ|, we have O(2^|φ| × |φ|^3) = EXPTIME

### Space Complexity

**Upper Bound**: PSPACE (polynomial space in formula size)

**Proof Sketch**:
1. Tableau branch depth: at most |φ| (one expansion per subformula)
2. Each node: O(|φ|) space (store formula and indices)
3. Branch space: O(|φ|^2) (depth × node size)
4. Number of branches stored at once: O(1) (depth-first search)
5. Total space: O(|φ|^2) = PSPACE

**Note**: Space-efficient algorithm uses iterative deepening DFS

### Comparison with Known Results

| Logic        | Time Complexity | Space Complexity | Reference |
|--------------|-----------------|------------------|-----------|
| S5 Modal     | EXPTIME         | PSPACE           | Ladner 1977 |
| LTL          | PSPACE          | PSPACE           | Sistla-Clarke 1985 |
| **TM (This work)** | **EXPTIME** | **PSPACE**   | Logos |

**Conclusion**: TM logic decidability inherits S5 time complexity (dominant factor) while maintaining LTL space efficiency.
```

**Formalization in LEAN**:

```lean
-- Time complexity bound
def tableau_time (φ : Formula) : ℕ :=
  2^(modal_depth φ) * (formula_size φ)^3

theorem time_complexity (φ : Formula) :
  tableau_steps φ ≤ tableau_time φ := by
  sorry  -- Prove by induction on construct_tableau_step

-- Space complexity bound
def tableau_space (φ : Formula) : ℕ :=
  (formula_size φ)^2

theorem space_complexity (φ : Formula) :
  max_branch_size φ ≤ tableau_space φ := by
  sorry  -- Prove by induction on tableau depth
```

**Testing Strategy**:
```bash
# Verify complexity bounds on small examples
lake test LogosTest.Metalogic.DecidabilityTest  -- Test: time_complexity_small
lake test LogosTest.Metalogic.DecidabilityTest  -- Test: space_complexity_small

# Verify soundness theorem proven
grep "theorem tableau_soundness" Logos/Metalogic/Decidability.lean

# Verify completeness theorem proven
grep "theorem tableau_completeness" Logos/Metalogic/Decidability.lean
```

**Expected Duration**: 8-12 hours

---

### Task 8a.4: Write Decidability Tests (4-6 hours) [NOT STARTED]

**Objective**: Comprehensive test suite for tableau construction, satisfiability checking, and complexity bounds

**Test File Structure**:

```lean
-- File: LogosTest/Metalogic/DecidabilityTest.lean

import Logos.Metalogic.Decidability
import LogosTest.TestFramework

namespace LogosTest.Metalogic

/-!
# Decidability Module Tests

Tests for tableau method, satisfiability checking, and complexity analysis.

## Test Categories
1. Propositional tableau tests
2. Modal tableau tests (S5)
3. Temporal tableau tests (LTL)
4. Bimodal interaction tests (TM)
5. Satisfiability checking tests
6. Closure detection tests
7. Complexity bound tests
-/

-- Test 1: Propositional tautology is satisfiable
def test_prop_tautology_sat : TestCase := {
  name := "Propositional tautology p → (q → p) is satisfiable"
  run := λ () => do
    let φ := Formula.imp (Formula.atom "p") (Formula.imp (Formula.atom "q") (Formula.atom "p"))
    assert (is_satisfiable φ = true)
}

-- Test 2: Propositional contradiction is unsatisfiable
def test_prop_contradiction_unsat : TestCase := {
  name := "Propositional contradiction p ∧ ¬p is unsatisfiable"
  run := λ () => do
    let φ := Formula.imp (Formula.atom "p") (Formula.imp (neg (Formula.atom "p")) bot)
    assert (is_satisfiable φ = false)
}

-- Test 3: Modal T axiom satisfiability
def test_modal_t_sat : TestCase := {
  name := "Modal T axiom □p → p is satisfiable"
  run := λ () => do
    let φ := Formula.imp (box (Formula.atom "p")) (Formula.atom "p")
    assert (is_satisfiable φ = true)
}

-- Test 4: Modal 4 axiom satisfiability
def test_modal_4_sat : TestCase := {
  name := "Modal 4 axiom □p → □□p is satisfiable"
  run := λ () => do
    let φ := Formula.imp (box (Formula.atom "p")) (box (box (Formula.atom "p")))
    assert (is_satisfiable φ = true)
}

-- Test 5: Modal B axiom satisfiability
def test_modal_b_sat : TestCase := {
  name := "Modal B axiom p → □◇p is satisfiable"
  run := λ () => do
    let φ := Formula.imp (Formula.atom "p") (box (diamond (Formula.atom "p")))
    assert (is_satisfiable φ = true)
}

-- Test 6: Temporal past consistency
def test_temporal_past_sat : TestCase := {
  name := "Temporal formula Pp → p is satisfiable (not valid)"
  run := λ () => do
    let φ := Formula.imp (past (Formula.atom "p")) (Formula.atom "p")
    assert (is_satisfiable φ = true)
    -- Note: Pp → p is NOT valid (past doesn't imply present)
}

-- Test 7: Temporal future consistency
def test_temporal_future_sat : TestCase := {
  name := "Temporal formula Fp is satisfiable"
  run := λ () => do
    let φ := future (Formula.atom "p")
    assert (is_satisfiable φ = true)
}

-- Test 8: Bimodal perpetuity P1
def test_bimodal_p1_sat : TestCase := {
  name := "Perpetuity P1: □p → always(p) is satisfiable"
  run := λ () => do
    let always_p := neg (future (neg (Formula.atom "p")))  -- △p = ¬F¬p
    let φ := Formula.imp (box (Formula.atom "p")) always_p
    assert (is_satisfiable φ = true)
}

-- Test 9: Closure detection on contradiction
def test_closure_detection : TestCase := {
  name := "Closure detection finds p ∧ ¬p contradiction"
  run := λ () => do
    let φ := Formula.imp (Formula.atom "p") (Formula.imp (neg (Formula.atom "p")) bot)
    let tree := construct_tableau φ 10
    assert (tree.isGloballyClosed = true)
}

-- Test 10: Time complexity bound verification (small formula)
def test_time_complexity_small : TestCase := {
  name := "Time complexity: □p has bounded tableau construction steps"
  run := λ () => do
    let φ := box (Formula.atom "p")
    let steps := (construct_tableau φ 10).constructionSteps
    let bound := tableau_time φ
    assert (steps ≤ bound)
}

-- Test 11: Space complexity bound verification (small formula)
def test_space_complexity_small : TestCase := {
  name := "Space complexity: □Fp has bounded max branch size"
  run := λ () => do
    let φ := box (future (Formula.atom "p"))
    let maxBranch := (construct_tableau φ 10).branches.map (λ b => b.nodes.length) |>.foldl max 0
    let bound := tableau_space φ
    assert (maxBranch ≤ bound)
}

-- Test 12: Satisfiability agrees with validity (valid formulas)
def test_satisfiability_validity_agree : TestCase := {
  name := "Satisfiability: ¬φ unsatisfiable iff φ valid (tested on □p → p)"
  run := λ () => do
    let φ := Formula.imp (box (Formula.atom "p")) (Formula.atom "p")  -- Modal T (valid in S5)
    assert (is_satisfiable (neg φ) = false)  -- ¬φ unsatisfiable implies φ valid
}

-- Run all tests
def all_decidability_tests : List TestCase := [
  test_prop_tautology_sat,
  test_prop_contradiction_unsat,
  test_modal_t_sat,
  test_modal_4_sat,
  test_modal_b_sat,
  test_temporal_past_sat,
  test_temporal_future_sat,
  test_bimodal_p1_sat,
  test_closure_detection,
  test_time_complexity_small,
  test_space_complexity_small,
  test_satisfiability_validity_agree
]

end LogosTest.Metalogic
```

**Test Execution**:
```bash
# Run decidability test suite
lake test LogosTest.Metalogic.DecidabilityTest

# Verify all tests pass
echo "Expected: 12/12 tests passing"

# Run with verbose output for debugging
lake test LogosTest.Metalogic.DecidabilityTest --verbose
```

**Expected Duration**: 4-6 hours

---

### Phase 8a Documentation and Integration (2-4 hours) [NOT STARTED]

**Objective**: Update all documentation to reflect decidability module completion and Layer 0 finalization

**Documentation Updates**:

**1. TODO.md Updates**:
```markdown
## Low Priority Tasks

### 10. Create Decidability Module
**Effort**: 40-60 hours
**Status**: COMPLETE (2025-12-XX)
**Priority**: Low (future work, Layer 0 theoretical completion)

**Completion Summary**:
- Created Logos/Metalogic/Decidability.lean (~1000 lines)
- Implemented tableau method with 12 expansion rules
- Proved soundness and completeness theorems
- Analyzed EXPTIME time complexity, PSPACE space complexity
- Created comprehensive test suite (12 tests, all passing)
- Updated IMPLEMENTATION_STATUS.md and KNOWN_LIMITATIONS.md

**Files Created**:
- Logos/Metalogic/Decidability.lean
- LogosTest/Metalogic/DecidabilityTest.lean
- Documentation/Reference/DECIDABILITY.md
```

**2. IMPLEMENTATION_STATUS.md Updates**:
```markdown
### Metalogic Package

**Overall Status**: 100% Complete ✓

| Module | Status | Sorry Count | Notes |
|--------|--------|-------------|-------|
| Soundness.lean | ✓ Complete | 0 | All axioms and rules proven sound |
| Completeness.lean | ✓ Complete | 0 | Weak and strong completeness proven |
| **Decidability.lean** | **✓ Complete** | **0** | **Tableau method, EXPTIME complexity proven** |

**Recent Updates**:
- 2025-12-XX: Decidability module completed with tableau-based decision procedure
- Complexity analysis: EXPTIME time, PSPACE space (matches theoretical bounds)
- All 11 metalogic axiom declarations replaced with proofs across Completeness module
- Layer 0 metalogic fully complete (Soundness + Completeness + Decidability)
```

**3. KNOWN_LIMITATIONS.md Updates**:
```markdown
## Section 5: Decidability Gaps (RESOLVED)

~~**Status**: Missing decidability module (Decidability.lean does not exist)~~

**RESOLVED**: 2025-12-XX - Decidability module fully implemented

**Resolution Summary**:
- Tableau-based decision procedure implemented for TM logic
- Satisfiability checking algorithm with systematic expansion
- Soundness and completeness proven using Phase 7 results
- Complexity bounds proven: EXPTIME time, PSPACE space
- Comprehensive test suite (12 tests) verifying correctness

**Remaining Optimizations** (future work, not Layer 0 blocking):
- Implement optimized tableau pruning strategies
- Add caching for repeated subformula checking
- Explore SAT-solver integration for propositional fragments
- Investigate BDD-based modal decision procedures
```

**4. ARCHITECTURE.md Updates**:
Add Decidability section to Metalogic architecture:

```markdown
### Decidability Module

**Purpose**: Systematic decision procedure for TM logic satisfiability checking

**Architecture**:
- **Tableau Data Structures**: Nodes (world-time-formula triples), branches (node sequences), trees (branching structures)
- **Expansion Rules**: 12 rules covering propositional, modal (S5), and temporal (LTL) operators
- **Closure Detection**: Local (contradictions at nodes) and global (all branches closed)
- **Satisfiability Algorithm**: Systematic tableau construction with depth bounds

**Theoretical Results**:
- **Soundness**: Open tableau ⇒ satisfiable (model construction from branch)
- **Completeness**: Satisfiable ⇒ open tableau (expansion preserves satisfiability)
- **Time Complexity**: O(2^|φ| × |φ|^3) = EXPTIME (exponential in formula size)
- **Space Complexity**: O(|φ|^2) = PSPACE (polynomial in formula size)

**Integration**:
- Uses Phase 7 completeness results (canonical model construction) for soundness proof
- Enables automated theorem proving via satisfiability checking
- Foundation for future optimization (SAT solvers, BDDs, etc.)
```

**5. CLAUDE.md Updates**:
```markdown
## 6. Key Packages

### Metalogic Package
- `soundness`: `Γ ⊢ φ → Γ ⊨ φ` **(Complete: 8/8 axioms, 7/7 rules proven)**
- `weak_completeness`: `⊨ φ → ⊢ φ` **(Complete: Proven using canonical model)**
- `strong_completeness`: `Γ ⊨ φ → Γ ⊢ φ` **(Complete: Proven using weak completeness)**
- **`decidability`: Tableau-based satisfiability checking **(Complete: EXPTIME time, PSPACE space proven)****
- Canonical model construction fully proven (11/11 axiom declarations replaced)
```

**Testing Strategy**:
```bash
# Verify decidability module complete
lake build Logos.Metalogic.Decidability
lake test LogosTest.Metalogic.DecidabilityTest

# Verify zero sorry in Decidability.lean
grep -c "sorry" Logos/Metalogic/Decidability.lean  # Expected: 0

# Verify zero axiom in Decidability.lean (soundness/completeness should be theorems)
grep -c "axiom" Logos/Metalogic/Decidability.lean  # Expected: 0

# Verify documentation updated
grep "Decidability" Documentation/ProjectInfo/IMPLEMENTATION_STATUS.md
grep "Decidability" Documentation/UserGuide/ARCHITECTURE.md
grep "Decidability" CLAUDE.md
```

**Expected Duration**: 2-4 hours

---

## Phase 8b: Layer Extension Planning - Detailed Plan

### Overview

Phase 8b represents strategic architectural planning for Logos's future development beyond Layer 0 (Core TM). This sub-phase designs three planned operator extensions:

**Layer 1 (Counterfactuals)**: Would-counterfactuals (`□c`) and might-counterfactuals (`◇m`) with task-relative evaluation semantics

**Layer 2 (Epistemic)**: Knowledge (`K`) and belief (`B`) operators with multi-agent epistemic semantics

**Layer 3 (Normative)**: Obligation (`O`) and permission (`P`) operators with normative task semantics

**Independence**: Phase 8b does NOT require Phase 8a completion and can be executed in parallel or earlier if architectural planning is needed

**Deliverables**: Comprehensive architectural design documents for each layer, integration strategy, and implementation roadmaps

---

### Task 8b.1: Layer 1 (Counterfactuals) Research and Planning (6-10 hours) [NOT STARTED]

**Objective**: Design counterfactual operator semantics compatible with TM logic and task frame architecture

**Research Topics**:

1. **Counterfactual Logic Foundations**:
   - Lewis's conditional logic (possible worlds semantics)
   - Stalnaker's selection function approach
   - Comparative similarity relations
   - Limit assumption vs variably strict conditionals

2. **Task-Relative Counterfactuals**:
   - How do tasks constrain counterfactual evaluation?
   - Counterfactual antecedents as task modifications
   - Closest task-compatible worlds

3. **Integration with TM**:
   - Interaction with necessity (`□`) and temporal operators (`P`, `F`)
   - Counterfactual persistence across time
   - Modal-counterfactual collapse conditions

**Design Decisions**:

**Decision 1: Counterfactual Operator Syntax**

**Option A**: Single operator `□→` (would-conditional)
```lean
| box_if : Formula → Formula → Formula  -- φ □→ ψ  ("if φ were true, ψ would be true")
```

**Option B**: Dual operators `□c` (would) and `◇m` (might)
```lean
| would : Formula → Formula → Formula   -- φ □c ψ  ("if φ were true, ψ would be true")
| might : Formula → Formula → Formula   -- φ ◇m ψ  ("if φ were true, ψ might be true")
```

**Recommendation**: Option B (dual operators) - more expressive, allows weak vs strong counterfactuals

**Decision 2: Counterfactual Semantics**

**Option A**: Lewis-style comparative similarity
```lean
structure LewisFrame extends TaskFrame where
  similarity : WorldState → WorldState → WorldState → Prop  -- w ≤v w' (w at least as similar to v as w')
  -- Axioms: reflexive, transitive, total ordering
```

**Option B**: Stalnaker-style selection function
```lean
structure StalnalkerFrame extends TaskFrame where
  selection : Formula → WorldState → Option WorldState  -- f(φ, w) = closest φ-world to w
  -- Axiom: if f(φ, w) exists, φ is true at f(φ, w)
```

**Option C**: Task-relative counterfactuals
```lean
structure TaskCounterfactualFrame extends TaskFrame where
  task_modification : WorldState → Formula → Set WorldState  -- modify task at w to satisfy φ
  -- Axiom: all worlds in task_modification(w, φ) satisfy φ and are task-accessible from w
```

**Recommendation**: Option C (task-relative) - integrates naturally with existing task semantics, philosophically novel

**Architectural Design**:

**File: `Documentation/Architecture/LAYER_1_COUNTERFACTUALS.md`**

```markdown
# Layer 1: Counterfactual Operators

## Syntax Extension

Extend `Formula` inductive type with counterfactual operators:

```lean
inductive Formula where
  -- Layer 0 (Core TM) constructors
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | past : Formula → Formula
  | future : Formula → Formula

  -- Layer 1 (Counterfactuals) constructors
  | would : Formula → Formula → Formula   -- φ □c ψ
  | might : Formula → Formula → Formula   -- φ ◇m ψ
```

**Notation**:
- `φ □c ψ` ("if φ were true, ψ would be true") - would-counterfactual
- `φ ◇m ψ` ("if φ were true, ψ might be true") - might-counterfactual

**Abbreviations**:
- `φ ◇m ψ := ¬(φ □c ¬ψ)` (might is dual of would)

## Semantics

### Task-Relative Counterfactual Frames

Extend `TaskFrame` with task modification function:

```lean
structure TaskCounterfactualFrame extends TaskFrame where
  task_modification : WorldState → Formula → Time → Set WorldState

  -- Axiom: Modified worlds satisfy antecedent
  modification_satisfies : ∀ w φ t w',
    w' ∈ task_modification w φ t → truth_at M (history w') t φ

  -- Axiom: Modified worlds preserve task relation
  modification_task_preserving : ∀ w φ t w',
    w' ∈ task_modification w φ t → task_rel w w'

  -- Axiom: Minimality (closest φ-satisfying task-compatible worlds)
  modification_minimal : ∀ w φ t w' w'',
    w' ∈ task_modification w φ t →
    truth_at M (history w'') t φ →
    task_rel w w'' →
    similarity w w' ≤ similarity w w''
```

### Truth Conditions

```lean
-- Would-counterfactual: φ □c ψ is true at (M, h, t) iff
-- in all closest φ-satisfying task-compatible worlds, ψ holds
def truth_at : TaskModel → WorldHistory → Time → Formula → Prop
| M, h, t, Formula.would φ ψ =>
    ∀ w' ∈ M.frame.task_modification (h.current_world) φ t,
      truth_at M (history w') t ψ

-- Might-counterfactual: φ ◇m ψ is true at (M, h, t) iff
-- in some closest φ-satisfying task-compatible world, ψ holds
| M, h, t, Formula.might φ ψ =>
    ∃ w' ∈ M.frame.task_modification (h.current_world) φ t,
      truth_at M (history w') t ψ
```

## Axiom Schemata

### CF1: Counterfactual Modus Ponens
```lean
axiom cf_mp : ∀ φ ψ, Derivable [] ((φ □c ψ) → (φ → ψ))
-- "If φ would imply ψ, and φ is actually true, then ψ is true"
```

### CF2: Counterfactual Strengthening
```lean
axiom cf_strengthen : ∀ φ ψ χ, Derivable [] ((φ □c χ) → ((φ ∧ ψ) □c χ))
-- "Strengthening antecedent preserves consequent (under minimality)"
```

### CF3: Counterfactual Transitivity
```lean
axiom cf_trans : ∀ φ ψ χ, Derivable [] (((φ □c ψ) ∧ (ψ □c χ)) → (φ □c χ))
-- "Counterfactual conditionals are transitive"
```

### CF4: Modal-Counterfactual Interaction
```lean
axiom modal_cf : ∀ φ ψ, Derivable [] (□(φ → ψ) → (φ □c ψ))
-- "Necessary implications are counterfactually robust"
```

### CF5: Temporal-Counterfactual Persistence
```lean
axiom temporal_cf : ∀ φ ψ, Derivable [] ((φ □c ψ) → F(φ □c ψ))
-- "Counterfactual conditionals persist into the future"
```

## Integration with Layer 0

### Derived Theorems

**Theorem CF-T1**: Counterfactual collapse under necessity
```lean
theorem cf_collapse_necessity : ∀ φ ψ,
  Derivable [] (□φ → ((φ □c ψ) ↔ □ψ))
-- "If φ is necessarily true, φ-counterfactuals collapse to necessity"
```

**Theorem CF-T2**: Counterfactual temporal shift
```lean
theorem cf_temporal_shift : ∀ φ ψ,
  Derivable [] ((φ □c Fψ) ↔ F(φ □c ψ))
-- "Counterfactuals distribute over future operator"
```

## Implementation Roadmap

### Phase CF-1: Syntax and Parsing (3-5 hours)
- Extend `Formula` inductive type with `would` and `might` constructors
- Add Unicode notation (`□c`, `◇m`)
- Update parser to handle counterfactual syntax
- Write syntax tests

### Phase CF-2: Semantics (5-8 hours)
- Define `TaskCounterfactualFrame` structure
- Implement `task_modification` function
- Define truth conditions for `would` and `might`
- Write semantic tests

### Phase CF-3: Axioms and Derivability (4-6 hours)
- Add CF1-CF5 axiom schemata to `Axioms.lean`
- Update `Derivable` inductive type
- Write axiom tests

### Phase CF-4: Soundness (8-12 hours)
- Prove CF1-CF5 axioms sound (valid in all task counterfactual frames)
- Prove derived theorems CF-T1, CF-T2
- Write soundness tests

### Phase CF-5: Examples and Documentation (3-5 hours)
- Create `Archive/CounterfactualProofs.lean` with examples
- Update ARCHITECTURE.md with Layer 1 design
- Update IMPLEMENTATION_STATUS.md

**Total Estimated Effort**: 23-36 hours
```

**Deliverables**:
- `Documentation/Architecture/LAYER_1_COUNTERFACTUALS.md` (comprehensive design document)
- Operator syntax specification (would `□c`, might `◇m`)
- Task-relative semantics with modification function
- 5 axiom schemata (CF1-CF5)
- Integration theorems with Layer 0
- 5-phase implementation roadmap (23-36 hours estimated)

**Expected Duration**: 6-10 hours

---

### Task 8b.2: Layer 2 (Epistemic) Research and Planning (6-10 hours) [NOT STARTED]

**Objective**: Design multi-agent epistemic operators compatible with TM logic and task semantics

**Research Topics**:

1. **Epistemic Logic Foundations**:
   - S4/S5 epistemic logic (knowledge as necessity)
   - KD45 doxastic logic (belief as weaker modality)
   - Common knowledge and distributed knowledge
   - Multi-agent epistemic frames

2. **Task-Relative Epistemics**:
   - Agent knowledge relative to task context
   - Belief updates under task progression
   - Knowledge preservation across temporal transitions

3. **Integration with TM and Counterfactuals**:
   - Modal knowledge vs metaphysical necessity
   - Epistemic-temporal interaction (learning over time)
   - Counterfactual knowledge ("if I knew φ, I would know ψ")

**Design Decisions**:

**Decision 1: Epistemic Operator Syntax**

**Option A**: Single-agent operators (K for knowledge, B for belief)
```lean
| knows : Formula → Formula           -- Kφ ("agent knows φ")
| believes : Formula → Formula        -- Bφ ("agent believes φ")
```

**Option B**: Multi-agent indexed operators
```lean
| knows : Agent → Formula → Formula   -- K_i φ ("agent i knows φ")
| believes : Agent → Formula → Formula -- B_i φ ("agent i believes φ")
```

**Recommendation**: Option B (multi-agent) - enables common knowledge, agent interaction analysis

**Decision 2: Epistemic Frame Architecture**

**Option A**: Separate epistemic accessibility relations
```lean
structure EpistemicFrame extends TaskFrame where
  epistemic_rel : Agent → WorldState → WorldState → Prop  -- R_i(w, w') (agent i considers w' possible from w)
  -- Axioms: reflexive, transitive (S4), symmetric (S5)
```

**Option B**: Task-integrated epistemic frames
```lean
structure TaskEpistemicFrame extends TaskFrame where
  knowledge_constraints : Agent → WorldState → Set WorldState
  -- Axiom: epistemic accessibility respects task relation
  epistemic_task_coherence : ∀ i w w',
    w' ∈ knowledge_constraints i w → task_rel w w'
```

**Recommendation**: Option B (task-integrated) - maintains architectural consistency with TM task semantics

**Architectural Design**:

**File: `Documentation/Architecture/LAYER_2_EPISTEMICS.md`**

```markdown
# Layer 2: Epistemic Operators

## Syntax Extension

Extend `Formula` with multi-agent epistemic operators:

```lean
-- Agent type
inductive Agent where
  | agent : String → Agent
  deriving Repr, DecidableEq

inductive Formula where
  -- Layer 0 + Layer 1 constructors (omitted)

  -- Layer 2 (Epistemics) constructors
  | knows : Agent → Formula → Formula      -- K_i φ
  | believes : Agent → Formula → Formula   -- B_i φ

  -- Derived operators
  | common_knows : List Agent → Formula → Formula  -- CK_{i,j,...} φ
  | distributed_knows : List Agent → Formula → Formula  -- DK_{i,j,...} φ
```

**Notation**:
- `K_i φ` ("agent i knows φ") - individual knowledge
- `B_i φ` ("agent i believes φ") - individual belief
- `CK_{i,j} φ` ("i and j commonly know φ") - common knowledge
- `DK_{i,j} φ` ("i and j distributively know φ") - distributed knowledge

**Abbreviations**:
- `CK_{i,j} φ := K_i φ ∧ K_j φ ∧ K_i (K_j φ) ∧ K_j (K_i φ) ∧ ...` (infinite conjunction, approximate)
- `DK_{i,j} φ := K_i φ ∨ K_j φ` (someone knows φ)

## Semantics

### Task-Integrated Epistemic Frames

```lean
structure TaskEpistemicFrame extends TaskFrame where
  -- Agent knowledge constraints (epistemic accessibility)
  knowledge_constraints : Agent → WorldState → Set WorldState

  -- Axiom: Knowledge respects task relation (epistemic possibilities are task-accessible)
  epistemic_task_coherence : ∀ i w w',
    w' ∈ knowledge_constraints i w → task_rel w w'

  -- Axiom: Knowledge is reflexive (agents know actual world is possible)
  knowledge_reflexive : ∀ i w, w ∈ knowledge_constraints i w

  -- Axiom: Knowledge is transitive (S4: K K φ → K φ)
  knowledge_transitive : ∀ i w w' w'',
    w' ∈ knowledge_constraints i w →
    w'' ∈ knowledge_constraints i w' →
    w'' ∈ knowledge_constraints i w

  -- Axiom: Knowledge is euclidean (S5: ◇K φ → K φ)
  knowledge_euclidean : ∀ i w w' w'',
    w' ∈ knowledge_constraints i w →
    w'' ∈ knowledge_constraints i w →
    (w'' ∈ knowledge_constraints i w' ∨ w' ∈ knowledge_constraints i w'')

  -- Belief constraints (weaker than knowledge)
  belief_constraints : Agent → WorldState → Set WorldState

  -- Axiom: Beliefs are serial (KD: consistent belief, not knowledge)
  belief_serial : ∀ i w, ∃ w', w' ∈ belief_constraints i w

  -- Axiom: Beliefs are transitive (D4: B B φ → B φ)
  belief_transitive : ∀ i w w' w'',
    w' ∈ belief_constraints i w →
    w'' ∈ belief_constraints i w' →
    w'' ∈ belief_constraints i w

  -- Axiom: Beliefs are euclidean (D45: ◇B φ → B φ)
  belief_euclidean : ∀ i w w' w'',
    w' ∈ belief_constraints i w →
    w'' ∈ belief_constraints i w →
    (w'' ∈ belief_constraints i w' ∨ w' ∈ belief_constraints i w'')
```

### Truth Conditions

```lean
-- Knowledge: K_i φ is true at (M, h, t) iff φ is true in all epistemically possible worlds
def truth_at : TaskModel → WorldHistory → Time → Formula → Prop
| M, h, t, Formula.knows i φ =>
    ∀ w' ∈ M.frame.knowledge_constraints i (h.current_world),
      truth_at M (history w') t φ

-- Belief: B_i φ is true at (M, h, t) iff φ is true in all doxastically accessible worlds
| M, h, t, Formula.believes i φ =>
    ∀ w' ∈ M.frame.belief_constraints i (h.current_world),
      truth_at M (history w') t φ
```

## Axiom Schemata

### EP1: Knowledge Axiom (K)
```lean
axiom knowledge_k : ∀ i φ ψ, Derivable [] (K_i (φ → ψ) → (K_i φ → K_i ψ))
-- "Knowledge distributes over implication"
```

### EP2: Truth Axiom (T)
```lean
axiom knowledge_t : ∀ i φ, Derivable [] (K_i φ → φ)
-- "Knowledge implies truth (only true things can be known)"
```

### EP3: Positive Introspection (4)
```lean
axiom knowledge_4 : ∀ i φ, Derivable [] (K_i φ → K_i (K_i φ))
-- "Agents know what they know"
```

### EP4: Negative Introspection (5)
```lean
axiom knowledge_5 : ∀ i φ, Derivable [] (¬K_i φ → K_i (¬K_i φ))
-- "Agents know what they don't know"
```

### EP5: Belief Consistency (D)
```lean
axiom belief_d : ∀ i φ, Derivable [] (B_i φ → ¬B_i (¬φ))
-- "Beliefs are consistent (no contradictory beliefs)"
```

### EP6: Epistemic-Modal Interaction
```lean
axiom epistemic_modal : ∀ i φ, Derivable [] (□φ → K_i φ)
-- "Necessary truths are known (ideal reasoners)"
```

### EP7: Epistemic-Temporal Learning
```lean
axiom epistemic_learning : ∀ i φ, Derivable [] (φ → F(K_i φ))
-- "True facts are eventually learned"
```

## Integration with Layers 0-1

### Derived Theorems

**Theorem EP-T1**: Epistemic necessity weaker than metaphysical
```lean
theorem epistemic_weaker : ∀ i φ,
  Derivable [] (□φ → K_i φ)
-- "Metaphysical necessity implies epistemic necessity"
```

**Theorem EP-T2**: Counterfactual knowledge
```lean
theorem cf_knowledge : ∀ i φ ψ,
  Derivable [] ((φ □c ψ) → (K_i φ □c K_i ψ))
-- "Counterfactual knowledge: if knowing φ, would know ψ"
```

## Implementation Roadmap

### Phase EP-1: Syntax and Multi-Agent Support (4-6 hours)
- Define `Agent` inductive type
- Extend `Formula` with `knows` and `believes` constructors
- Add Unicode notation (`K_i`, `B_i`)
- Write syntax tests

### Phase EP-2: Epistemic Frames (6-10 hours)
- Define `TaskEpistemicFrame` extending `TaskFrame`
- Implement `knowledge_constraints` and `belief_constraints`
- Prove frame axioms (reflexive, transitive, euclidean, serial)
- Write frame tests

### Phase EP-3: Truth Semantics (5-8 hours)
- Extend `truth_at` function with epistemic cases
- Implement common knowledge approximation
- Write semantic tests

### Phase EP-4: Axioms and Derivability (6-10 hours)
- Add EP1-EP7 axiom schemata to `Axioms.lean`
- Update `Derivable` inductive type
- Write axiom tests

### Phase EP-5: Soundness (10-15 hours)
- Prove EP1-EP7 axioms sound
- Prove derived theorems EP-T1, EP-T2
- Write soundness tests

### Phase EP-6: Examples and Documentation (4-6 hours)
- Create `Archive/EpistemicProofs.lean` with examples
- Update ARCHITECTURE.md with Layer 2 design
- Update IMPLEMENTATION_STATUS.md

**Total Estimated Effort**: 35-55 hours
```

**Deliverables**:
- `Documentation/Architecture/LAYER_2_EPISTEMICS.md` (comprehensive design document)
- Multi-agent operator syntax (K_i knowledge, B_i belief)
- Task-integrated epistemic frames with S4/KD45 axioms
- 7 axiom schemata (EP1-EP7)
- Integration theorems with Layers 0-1
- 6-phase implementation roadmap (35-55 hours estimated)

**Expected Duration**: 6-10 hours

---

### Task 8b.3: Layer 3 (Normative) Research and Planning (6-10 hours) [NOT STARTED]

**Objective**: Design deontic operators for obligation and permission compatible with TM, counterfactual, and epistemic logics

**Research Topics**:

1. **Deontic Logic Foundations**:
   - Standard deontic logic (SDL: obligation as necessity)
   - Dyadic deontic logic (conditional obligations)
   - Von Wright's deontic squares
   - Contrary-to-duty paradoxes and resolutions

2. **Task-Relative Normative Operators**:
   - Obligations relative to task context
   - Permissions as task-compatible options
   - Normative conflicts and resolution strategies

3. **Integration with Layers 0-2**:
   - Normative-modal interaction (necessary obligations)
   - Normative-temporal persistence (obligations over time)
   - Normative-epistemic interaction (knowledge of obligations)
   - Normative-counterfactual reasoning (obligations in counterfactual scenarios)

**Design Decisions**:

**Decision 1: Deontic Operator Syntax**

**Option A**: Monadic operators (absolute obligations)
```lean
| obligatory : Formula → Formula      -- Oφ ("φ is obligatory")
| permitted : Formula → Formula       -- Pφ ("φ is permitted")
```

**Option B**: Dyadic operators (conditional obligations)
```lean
| obligatory : Formula → Formula → Formula   -- O(φ|ψ) ("φ is obligatory given ψ")
| permitted : Formula → Formula → Formula    -- P(φ|ψ) ("φ is permitted given ψ")
```

**Recommendation**: Option B (dyadic) - more expressive, handles contrary-to-duty cases naturally

**Decision 2: Normative Frame Architecture**

**Option A**: Separate deontic accessibility (ideal worlds)
```lean
structure DeonticFrame extends TaskFrame where
  deontic_rel : WorldState → WorldState → Prop  -- R_D(w, w') (w' is deontically ideal from w)
  -- Axiom: serial (no impossible obligations)
```

**Option B**: Task-integrated normative constraints
```lean
structure TaskNormativeFrame extends TaskEpistemicFrame where
  normative_constraints : Formula → WorldState → Set WorldState
  -- Axiom: normative ideals respect task and epistemic constraints
  normative_coherence : ∀ φ w w',
    w' ∈ normative_constraints φ w →
    task_rel w w' ∧ (∀ i, w' ∈ knowledge_constraints i w)
```

**Recommendation**: Option B (task-integrated) - maintains architectural consistency, enables task-epistemic-normative interaction

**Architectural Design**:

**File: `Documentation/Architecture/LAYER_3_NORMATIVES.md`**

```markdown
# Layer 3: Normative Operators

## Syntax Extension

Extend `Formula` with dyadic deontic operators:

```lean
inductive Formula where
  -- Layer 0 + Layer 1 + Layer 2 constructors (omitted)

  -- Layer 3 (Normatives) constructors
  | obligatory : Formula → Formula → Formula   -- O(φ|ψ) ("φ is obligatory given ψ")
  | permitted : Formula → Formula → Formula    -- P(φ|ψ) ("φ is permitted given ψ")

  -- Derived operators
  | forbidden : Formula → Formula → Formula    -- F(φ|ψ) := O(¬φ|ψ)
  | optional : Formula → Formula → Formula     -- Op(φ|ψ) := P(φ|ψ) ∧ P(¬φ|ψ)
```

**Notation**:
- `O(φ|ψ)` ("φ is obligatory given ψ") - conditional obligation
- `P(φ|ψ)` ("φ is permitted given ψ") - conditional permission
- `Oφ := O(φ|⊤)` - absolute obligation (abbreviation)
- `Pφ := P(φ|⊤)` - absolute permission (abbreviation)

**Abbreviations**:
- `F(φ|ψ) := O(¬φ|ψ)` - conditional forbiddance
- `Op(φ|ψ) := P(φ|ψ) ∧ P(¬φ|ψ)` - optionality (neither obligatory nor forbidden)

## Semantics

### Task-Integrated Normative Frames

```lean
structure TaskNormativeFrame extends TaskEpistemicFrame where
  -- Normative constraints (deontically ideal worlds given condition)
  normative_constraints : Formula → WorldState → Set WorldState

  -- Axiom: Normative ideals respect task relation
  normative_task_coherence : ∀ φ w w',
    w' ∈ normative_constraints φ w → task_rel w w'

  -- Axiom: Normative ideals respect epistemic constraints (ought implies can know)
  normative_epistemic_coherence : ∀ φ w w' i,
    w' ∈ normative_constraints φ w →
    w' ∈ knowledge_constraints i w

  -- Axiom: Normative constraints are serial (no impossible obligations)
  normative_serial : ∀ φ w, ∃ w', w' ∈ normative_constraints φ w

  -- Axiom: Normative constraints strengthen under antecedent strengthening
  normative_monotone : ∀ φ ψ w,
    (∀ w', truth_at M (history w') t φ → truth_at M (history w') t ψ) →
    normative_constraints ψ w ⊆ normative_constraints φ w
```

### Truth Conditions

```lean
-- Conditional obligation: O(φ|ψ) is true at (M, h, t) iff
-- in all ψ-satisfying normatively ideal worlds, φ holds
def truth_at : TaskModel → WorldHistory → Time → Formula → Prop
| M, h, t, Formula.obligatory φ ψ =>
    ∀ w' ∈ M.frame.normative_constraints ψ (h.current_world),
      truth_at M (history w') t φ

-- Conditional permission: P(φ|ψ) is true at (M, h, t) iff
-- in some ψ-satisfying normatively ideal world, φ holds
| M, h, t, Formula.permitted φ ψ =>
    ∃ w' ∈ M.frame.normative_constraints ψ (h.current_world),
      truth_at M (history w') t φ
```

## Axiom Schemata

### NM1: Deontic Inheritance (K)
```lean
axiom deontic_k : ∀ φ ψ χ, Derivable [] (O(φ → ψ | χ) → (O(φ|χ) → O(ψ|χ)))
-- "Obligations distribute over implication"
```

### NM2: Ought-Implies-Can (D)
```lean
axiom ought_implies_can : ∀ φ ψ, Derivable [] (O(φ|ψ) → P(φ|ψ))
-- "Obligation implies permission (no impossible obligations)"
```

### NM3: Deontic Detachment
```lean
axiom deontic_detachment : ∀ φ ψ, Derivable [] ((O(φ|ψ) ∧ ψ) → Oφ)
-- "Conditional obligations become absolute when condition holds"
```

### NM4: Normative-Modal Interaction
```lean
axiom normative_modal : ∀ φ ψ, Derivable [] (□φ → O(φ|ψ))
-- "Necessary truths are obligatory (trivial obligations)"
```

### NM5: Normative-Temporal Persistence
```lean
axiom normative_persistence : ∀ φ ψ, Derivable [] (O(φ|ψ) → F(O(φ|ψ)))
-- "Obligations persist into the future"
```

### NM6: Normative-Epistemic Awareness
```lean
axiom normative_awareness : ∀ i φ ψ, Derivable [] (O(φ|ψ) → K_i (O(φ|ψ)))
-- "Agents know their obligations (ideal epistemic agents)"
```

### NM7: Normative-Counterfactual Robustness
```lean
axiom normative_cf_robust : ∀ φ ψ χ, Derivable [] (O(φ|ψ) → (χ □c O(φ|ψ)))
-- "Obligations are counterfactually robust"
```

## Integration with Layers 0-2

### Derived Theorems

**Theorem NM-T1**: Permission is dual of obligation
```lean
theorem permission_dual : ∀ φ ψ,
  Derivable [] (P(φ|ψ) ↔ ¬O(¬φ|ψ))
-- "Permission is negation of obligation to refrain"
```

**Theorem NM-T2**: Contrary-to-duty resolution
```lean
theorem contrary_to_duty : ∀ φ ψ χ,
  Derivable [] ((O(φ|ψ) ∧ ¬φ ∧ O(χ|ψ ∧ ¬φ)) → O(χ|ψ))
-- "Secondary obligations activate when primary obligations violated"
```

**Theorem NM-T3**: Epistemic-normative coherence
```lean
theorem epistemic_normative_coherence : ∀ i φ ψ,
  Derivable [] ((K_i ψ ∧ O(φ|ψ)) → K_i (O(φ|ψ)))
-- "Knowing the condition and obligation implies knowing the obligation"
```

## Implementation Roadmap

### Phase NM-1: Syntax and Dyadic Operators (4-6 hours)
- Extend `Formula` with `obligatory` and `permitted` constructors
- Add Unicode notation (`O(·|·)`, `P(·|·)`)
- Implement dyadic operator parsing
- Write syntax tests

### Phase NM-2: Normative Frames (6-10 hours)
- Define `TaskNormativeFrame` extending `TaskEpistemicFrame`
- Implement `normative_constraints` function
- Prove frame axioms (serial, monotone, task-coherent, epistemic-coherent)
- Write frame tests

### Phase NM-3: Truth Semantics (5-8 hours)
- Extend `truth_at` function with normative cases
- Implement conditional obligation/permission evaluation
- Write semantic tests

### Phase NM-4: Axioms and Derivability (6-10 hours)
- Add NM1-NM7 axiom schemata to `Axioms.lean`
- Update `Derivable` inductive type
- Write axiom tests

### Phase NM-5: Soundness (12-18 hours)
- Prove NM1-NM7 axioms sound
- Prove derived theorems NM-T1, NM-T2, NM-T3
- Write soundness tests

### Phase NM-6: Contrary-to-Duty Handling (8-12 hours)
- Implement contrary-to-duty obligation resolution
- Add reasoning patterns for normative conflicts
- Write conflict resolution tests

### Phase NM-7: Examples and Documentation (4-6 hours)
- Create `Archive/NormativeProofs.lean` with examples
- Update ARCHITECTURE.md with Layer 3 design
- Update IMPLEMENTATION_STATUS.md

**Total Estimated Effort**: 45-70 hours
```

**Deliverables**:
- `Documentation/Architecture/LAYER_3_NORMATIVES.md` (comprehensive design document)
- Dyadic deontic operator syntax (O(φ|ψ) obligation, P(φ|ψ) permission)
- Task-integrated normative frames with SDL axioms
- 7 axiom schemata (NM1-NM7)
- Integration theorems with Layers 0-2
- 7-phase implementation roadmap (45-70 hours estimated)

**Expected Duration**: 6-10 hours

---

### Task 8b.4: Create Implementation Plans for Each Layer (2-4 hours) [NOT STARTED]

**Objective**: Consolidate architectural designs into actionable implementation plans for future development

**Deliverables**:

**1. Layer 1 Implementation Plan**:
```markdown
# Layer 1 (Counterfactuals) Implementation Plan

## Overview
- **Estimated Total Effort**: 23-36 hours
- **Phases**: 5 (CF-1 through CF-5)
- **Dependencies**: Layer 0 complete (Soundness, Completeness, Decidability)
- **Key Innovations**: Task-relative counterfactual semantics

## Implementation Order
1. Phase CF-1: Syntax and Parsing (3-5 hours)
2. Phase CF-2: Semantics (5-8 hours)
3. Phase CF-3: Axioms and Derivability (4-6 hours)
4. Phase CF-4: Soundness (8-12 hours)
5. Phase CF-5: Examples and Documentation (3-5 hours)

## Success Criteria
- [ ] Counterfactual operators (`would`, `might`) fully functional
- [ ] Task modification function implemented and tested
- [ ] CF1-CF5 axioms proven sound
- [ ] Derived theorems CF-T1, CF-T2 proven
- [ ] Archive examples demonstrate counterfactual reasoning
- [ ] Zero `sorry` placeholders in Layer 1 modules
- [ ] Full test coverage (≥85% overall, ≥90% soundness)

## Risk Mitigation
- **Risk**: Task modification function complexity
  - **Mitigation**: Start with simple cases (propositional antecedents), extend incrementally
- **Risk**: Soundness proofs for temporal-counterfactual interaction
  - **Mitigation**: Use Phase 7 completeness lemmas as foundation
```

**2. Layer 2 Implementation Plan**:
```markdown
# Layer 2 (Epistemics) Implementation Plan

## Overview
- **Estimated Total Effort**: 35-55 hours
- **Phases**: 6 (EP-1 through EP-6)
- **Dependencies**: Layer 0 complete, Layer 1 recommended (for epistemic-counterfactual interaction)
- **Key Innovations**: Multi-agent task-integrated epistemic frames

## Implementation Order
1. Phase EP-1: Syntax and Multi-Agent Support (4-6 hours)
2. Phase EP-2: Epistemic Frames (6-10 hours)
3. Phase EP-3: Truth Semantics (5-8 hours)
4. Phase EP-4: Axioms and Derivability (6-10 hours)
5. Phase EP-5: Soundness (10-15 hours)
6. Phase EP-6: Examples and Documentation (4-6 hours)

## Success Criteria
- [ ] Multi-agent knowledge operators (K_i, B_i) fully functional
- [ ] S4/KD45 epistemic frames implemented and tested
- [ ] EP1-EP7 axioms proven sound
- [ ] Derived theorems EP-T1, EP-T2 proven
- [ ] Common knowledge approximation working
- [ ] Archive examples demonstrate epistemic reasoning
- [ ] Zero `sorry` placeholders in Layer 2 modules
- [ ] Full test coverage (≥85% overall, ≥90% soundness)

## Risk Mitigation
- **Risk**: Multi-agent complexity (agent indexing, common knowledge)
  - **Mitigation**: Start with single-agent cases, extend to multi-agent incrementally
- **Risk**: Epistemic-task coherence axiom complexity
  - **Mitigation**: Document as axiom initially, prove if time allows
```

**3. Layer 3 Implementation Plan**:
```markdown
# Layer 3 (Normatives) Implementation Plan

## Overview
- **Estimated Total Effort**: 45-70 hours
- **Phases**: 7 (NM-1 through NM-7)
- **Dependencies**: Layer 0 complete, Layer 1 recommended, Layer 2 REQUIRED (for normative-epistemic interaction)
- **Key Innovations**: Dyadic deontic logic with task-epistemic-normative integration

## Implementation Order
1. Phase NM-1: Syntax and Dyadic Operators (4-6 hours)
2. Phase NM-2: Normative Frames (6-10 hours)
3. Phase NM-3: Truth Semantics (5-8 hours)
4. Phase NM-4: Axioms and Derivability (6-10 hours)
5. Phase NM-5: Soundness (12-18 hours)
6. Phase NM-6: Contrary-to-Duty Handling (8-12 hours)
7. Phase NM-7: Examples and Documentation (4-6 hours)

## Success Criteria
- [ ] Dyadic deontic operators (O(·|·), P(·|·)) fully functional
- [ ] Task-integrated normative frames implemented and tested
- [ ] NM1-NM7 axioms proven sound
- [ ] Derived theorems NM-T1, NM-T2, NM-T3 proven
- [ ] Contrary-to-duty reasoning patterns working
- [ ] Archive examples demonstrate normative reasoning
- [ ] Zero `sorry` placeholders in Layer 3 modules
- [ ] Full test coverage (≥85% overall, ≥90% soundness)

## Risk Mitigation
- **Risk**: Contrary-to-duty paradoxes (Chisholm, Forrester)
  - **Mitigation**: Use dyadic operators to avoid paradoxes, document resolution strategies
- **Risk**: Normative-epistemic-counterfactual interaction complexity
  - **Mitigation**: Phase implementation (start with normative-modal, add epistemic, then counterfactual)
```

**4. ARCHITECTURE.md Master Update**:
Update `Documentation/UserGuide/ARCHITECTURE.md` with full layer roadmap:

```markdown
## Layer Architecture Roadmap

Logos is designed as a layered logic system with incremental operator extensions:

### Layer 0: Core TM (COMPLETE)
- **Operators**: Metaphysical modality (`□`, `◇`), Temporal operators (`P`, `F`)
- **Semantics**: Task frame semantics with nullity and compositionality
- **Metalogic**: Soundness ✓, Completeness ✓, Decidability ✓
- **Status**: Fully complete, zero `sorry` placeholders

### Layer 1: Counterfactuals (PLANNED)
- **Operators**: Would-counterfactual (`□c`), Might-counterfactual (`◇m`)
- **Semantics**: Task-relative modification function with minimality
- **Effort**: 23-36 hours estimated
- **Status**: Architectural design complete, implementation pending

### Layer 2: Epistemics (PLANNED)
- **Operators**: Multi-agent knowledge (`K_i`), Belief (`B_i`)
- **Semantics**: S4/KD45 epistemic frames with task integration
- **Effort**: 35-55 hours estimated
- **Status**: Architectural design complete, implementation pending
- **Dependencies**: Layer 0 complete, Layer 1 recommended

### Layer 3: Normatives (PLANNED)
- **Operators**: Dyadic obligation (`O(·|·)`), Permission (`P(·|·)`)
- **Semantics**: SDL deontic frames with task-epistemic integration
- **Effort**: 45-70 hours estimated
- **Status**: Architectural design complete, implementation pending
- **Dependencies**: Layer 0 complete, Layer 1 recommended, Layer 2 REQUIRED

### Total Layer 1-3 Effort: 103-161 hours
```

**Testing Strategy**:
```bash
# Verify architectural design documents created
ls -lh Documentation/Architecture/LAYER_1_COUNTERFACTUALS.md
ls -lh Documentation/Architecture/LAYER_2_EPISTEMICS.md
ls -lh Documentation/Architecture/LAYER_3_NORMATIVES.md

# Verify ARCHITECTURE.md updated with layer roadmap
grep "Layer Architecture Roadmap" Documentation/UserGuide/ARCHITECTURE.md
```

**Expected Duration**: 2-4 hours

---

## Phase 8 Final Documentation and Verification (2-4 hours) [NOT STARTED]

**Objective**: Update all documentation to reflect Wave 4 completion, Layer 0 finalization, and Layer 1-3 roadmap establishment

**Documentation Updates**:

**1. TODO.md Updates**:
```markdown
## Low Priority Tasks

### 10. Create Decidability Module
**Status**: COMPLETE (2025-12-XX)

### 11. Plan Layer 1/2/3 Extensions
**Effort**: 20-40 hours
**Status**: COMPLETE (2025-12-XX)
**Priority**: Low (future planning)

**Completion Summary**:
- Created Layer 1 (Counterfactuals) architectural design (23-36 hours estimated)
- Created Layer 2 (Epistemics) architectural design (35-55 hours estimated)
- Created Layer 3 (Normatives) architectural design (45-70 hours estimated)
- Total Layer 1-3 implementation effort: 103-161 hours estimated
- Updated ARCHITECTURE.md with complete layer roadmap

---

## Status Summary (2025-12-XX)

**Overall Progress**: 11/11 tasks complete (100%)

**By Priority**:
- High Priority: 4/4 tasks complete (100%)
- Medium Priority: 4/4 tasks complete (100%)
- Low Priority: 3/3 tasks complete (100%)

**Sorry Placeholder Resolution**: 41 → 0 (100% resolved)

**Layer 0 (Core TM) Status**: COMPLETE ✓
- All axioms and rules proven sound
- Weak and strong completeness proven
- Decidability with tableau method implemented
- Zero `sorry` placeholders remaining
- Full test coverage achieved

**Future Work**: Layer 1-3 extensions ready for implementation (103-161 hours estimated)
```

**2. IMPLEMENTATION_STATUS.md Updates**:
Add Layer Planning section:

```markdown
## Future Layer Extensions (Architectural Design Complete)

### Layer 1: Counterfactuals
**Status**: Architectural design complete, implementation pending
**Estimated Effort**: 23-36 hours
**Operators**: Would-counterfactual (`□c`), Might-counterfactual (`◇m`)
**Key Innovation**: Task-relative modification function

### Layer 2: Epistemics
**Status**: Architectural design complete, implementation pending
**Estimated Effort**: 35-55 hours
**Operators**: Multi-agent knowledge (`K_i`), Belief (`B_i`)
**Key Innovation**: Task-integrated S4/KD45 epistemic frames

### Layer 3: Normatives
**Status**: Architectural design complete, implementation pending
**Estimated Effort**: 45-70 hours
**Operators**: Dyadic obligation (`O(·|·)`), Permission (`P(·|·)`)
**Key Innovation**: Task-epistemic-normative integration with contrary-to-duty handling

**Total Future Effort**: 103-161 hours for full Layer 1-3 implementation
```

**3. CLAUDE.md Updates**:
```markdown
## 1. Project Overview

Logos is a LEAN 4 implementation of an axiomatic proof system for the bimodal logic TM (Tense and Modality) with task semantics. It provides:

- **Bimodal Logic TM**: Combining S5 modal logic (metaphysical necessity/possibility) with linear temporal logic (past/future operators)
- **Task Semantics**: Possible worlds as functions from times to world states constrained by task relations
- **Layer 0 (Core TM)**: COMPLETE ✓ - Fully proven soundness, completeness, and decidability
- **Layered Architecture**: Architectural designs ready for Layer 1 (Counterfactual), Layer 2 (Epistemic), Layer 3 (Normative) extensions

## Implementation Status

**Layer 0 Completion**: COMPLETE ✓ (100% proven, zero `sorry` placeholders)

**Future Layers**: Architectural designs complete, ready for implementation
- Layer 1 (Counterfactuals): 23-36 hours estimated
- Layer 2 (Epistemics): 35-55 hours estimated
- Layer 3 (Normatives): 45-70 hours estimated

**For detailed layer roadmap**: See [Documentation/UserGuide/ARCHITECTURE.md](Documentation/UserGuide/ARCHITECTURE.md#layer-architecture-roadmap)
```

**4. README.md Updates**:
Add Layer 0 completion milestone and future roadmap:

```markdown
## Project Status

**Layer 0 (Core TM): COMPLETE ✓**

Logos has achieved full Layer 0 implementation with zero `sorry` placeholders:
- ✓ All 10 TM axioms proven sound
- ✓ All 7 inference rules proven sound
- ✓ Weak and strong completeness proven (canonical model construction)
- ✓ Decidability implemented (tableau method, EXPTIME complexity)
- ✓ All 6 perpetuity principles (P1-P6) fully proven
- ✓ Comprehensive test suite with ≥85% coverage

**Future Roadmap**:

Architectural designs complete for three planned layer extensions:
- **Layer 1 (Counterfactuals)**: Would/might-counterfactuals with task-relative semantics
- **Layer 2 (Epistemics)**: Multi-agent knowledge and belief operators
- **Layer 3 (Normatives)**: Dyadic deontic logic for obligations and permissions

See [ARCHITECTURE.md](Documentation/UserGuide/ARCHITECTURE.md) for complete layer roadmap.
```

**Final Verification Commands**:
```bash
# Verify Layer 0 complete (zero sorry)
grep -r "sorry" Logos/ --include="*.lean" | wc -l  # Expected: 0

# Verify all 11 TODO.md tasks complete
grep "Status Summary" TODO.md  # Should show 11/11 (100%)

# Verify layer architecture documents exist
ls -lh Documentation/Architecture/LAYER_*.md | wc -l  # Expected: 3

# Verify full test suite passes
lake test

# Verify lint clean
lake lint

# Verify build success
lake build

# Generate final documentation
lake build :docs
```

**Expected Duration**: 2-4 hours

---

## Phase 8 Success Criteria

**Phase 8a (Decidability Module) Complete**:
- [ ] `Logos/Metalogic/Decidability.lean` created (~1000 lines)
- [ ] Tableau method implemented with 12 expansion rules
- [ ] Soundness theorem proven (open tableau ⇒ satisfiable)
- [ ] Completeness theorem proven (satisfiable ⇒ open tableau)
- [ ] Complexity bounds proven (EXPTIME time, PSPACE space)
- [ ] Test suite passing (12 tests, all green)
- [ ] Documentation complete (`Documentation/Reference/DECIDABILITY.md`)
- [ ] Zero `sorry` in Decidability.lean
- [ ] TODO.md Task 10 marked complete

**Phase 8b (Layer Extension Planning) Complete**:
- [ ] Layer 1 architectural design complete (`LAYER_1_COUNTERFACTUALS.md`)
- [ ] Layer 2 architectural design complete (`LAYER_2_EPISTEMICS.md`)
- [ ] Layer 3 architectural design complete (`LAYER_3_NORMATIVES.md`)
- [ ] Implementation roadmaps created for all three layers
- [ ] ARCHITECTURE.md updated with layer roadmap
- [ ] TODO.md Task 11 marked complete

**Layer 0 Full Completion Verified**:
- [ ] TODO.md shows 11/11 tasks complete (100%)
- [ ] Zero `sorry` placeholders in all Logos/ modules
- [ ] `lake test` passes with zero failures
- [ ] `lake lint` returns zero warnings
- [ ] `lake build` succeeds cleanly
- [ ] All documentation synchronized (TODO.md, IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md, CLAUDE.md, README.md)

**Total Phase 8 Estimated Duration**: 60-100 hours (40-60 hours Phase 8a + 20-40 hours Phase 8b)

---

## Notes

**Sub-Phase Independence**: Phase 8a and Phase 8b are independently executable. Phase 8b can begin earlier if architectural planning is prioritized, or Phase 8a can be completed first for full Layer 0 theoretical closure.

**Decidability Complexity**: EXPTIME time complexity is expected for TM logic (inherits S5 modal complexity), but PSPACE space complexity demonstrates efficiency achievable with depth-first tableau search.

**Layer Roadmap Utility**: Even if Layer 1-3 implementation is deferred, having comprehensive architectural designs:
- Documents design decisions and rationale
- Enables incremental feature discussion
- Guides future contributors
- Demonstrates theoretical extensibility of task semantics

**Post-Phase 8 Completion**: Logos will have:
- Complete Layer 0 implementation (zero technical debt)
- Comprehensive architectural roadmap for three future layers
- Total estimated future effort: 103-161 hours for full Layer 1-3 implementation
- Publication-ready theoretical foundation

---

## Testing Strategy

### Phase 8a Testing
```bash
# Unit tests for tableau components
lake test LogosTest.Metalogic.DecidabilityTest

# Integration tests with Layer 0
lake test LogosTest.Integration.DecidabilityIntegrationTest

# Complexity verification tests
lake test LogosTest.Metalogic.DecidabilityComplexityTest
```

### Phase 8b Testing
```bash
# Verify architectural documents parseable (markdown lint)
markdownlint Documentation/Architecture/LAYER_*.md

# Verify implementation roadmaps have required sections
grep "Implementation Roadmap" Documentation/Architecture/LAYER_*.md | wc -l  # Expected: 3

# Verify effort estimates sum correctly
grep "Total Estimated Effort" Documentation/Architecture/LAYER_*.md
```

### Final Verification
```bash
# Comprehensive Layer 0 completion check
bash .claude/scripts/verify-layer0-complete.sh

# Expected output:
# ✓ Zero sorry placeholders (0 found)
# ✓ All tests passing (lake test exit 0)
# ✓ Lint clean (lake lint exit 0)
# ✓ Build successful (lake build exit 0)
# ✓ TODO.md shows 11/11 complete
# ✓ Documentation synchronized
# ✓ Layer 1-3 architectural designs present
# LAYER 0 COMPLETE - Ready for future extensions
```

---

PHASE_EXPANDED
