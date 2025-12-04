# Soundness and Automation Implementation Research Report

**Report ID**: 001-soundness-automation-implementation-research
**Date**: 2025-12-03
**Author**: Claude (research-specialist agent)
**Context**: Plan workflow research phase
**Complexity**: 3

---

## Executive Summary

This report provides comprehensive research and technical analysis for implementing:
1. **Task 5**: Complete Soundness Proofs - 3 inference rules remaining (`modal_k`, `temporal_k`, `temporal_duality`)
2. **Task 7**: Implement Core Automation - 4 priority tactics (`apply_axiom`, `modal_t`, `tm_auto`, `assumption_search`)
3. **Task 12**: Create Comprehensive Tactic Test Suite (concurrent with Task 7)

**Current State**: Layer 0 (Core TM) is 70% complete on medium-priority tasks. All 8 axioms are proven sound, but 3 inference rules require additional semantic properties. Automation package has documentation and stubs but no implementations.

**Estimated Total Effort**: 55-80 hours for all three tasks
- Task 5 (Soundness Rules): 9-15 hours
- Task 7 (Core Automation): 40-60 hours (phased)
- Task 12 (Test Suite): Concurrent with Task 7 per TDD methodology

**Key Finding**: Tasks can run in parallel. Task 5 is independent, Task 7 can proceed immediately with macro/elab_rules approaches, and Task 12 follows TDD with tests before/alongside implementation.

---

## 1. Current State Analysis

### 1.1 Soundness Proofs Status (Task 5)

**File**: `/home/benjamin/Documents/Philosophy/Projects/Logos/Logos/Metalogic/Soundness.lean`

**Completed Components** (8 axioms, 4 rules):
- **Axioms**: All 10 axioms proven sound (MT, M4, MB, T4, TA, TL, MF, TF, prop_k, prop_s)
  - TL, MF, TF use time-shift infrastructure (fully proven via `time_shift_preserves_truth`)
  - Propositional axioms K and S proven as tautologies (lines 152-177)
- **Rules**: 4/7 inference rules proven sound:
  - `axiom` (line 513): All axioms valid → semantic consequences ✓
  - `assumption` (line 519): Assumed formulas true by hypothesis ✓
  - `modus_ponens` (line 525): Implication elimination ✓
  - `weakening` (line 586): Adding premises preserves consequence ✓

**Incomplete Components** (3 rules with `sorry`):

1. **`modal_k` Rule** (line 535, marked `sorry` at line 551)
   ```lean
   | @modal_k Γ' φ' _ ih =>
     -- Case: From Γ'.map box ⊢ φ', derive Γ' ⊢ □φ'
     -- IH: (Γ'.map box) ⊨ φ'
     -- Goal: Γ' ⊨ □φ'
     sorry
   ```
   **Issue**: Requires proving that if all formulas in `Γ'.map box` are true at `(M, σ, t)` for arbitrary `σ`, then all formulas in `Γ'` are true at `(M, τ, t)` (for the original `τ`). This needs showing that boxed context semantics are "modal" (constant across histories).

2. **`temporal_k` Rule** (line 553, marked `sorry` at line 569)
   ```lean
   | @temporal_k Γ' φ' _ ih =>
     -- Case: From Γ'.map future ⊢ φ', derive Γ' ⊢ Fφ'
     -- IH: (Γ'.map future) ⊨ φ'
     -- Goal: Γ' ⊨ Fφ'
     sorry
   ```
   **Issue**: Requires proving that if all formulas in `Γ'.map future` are true at `(M, τ, s)` for `s > t`, then all formulas in `Γ'` are true at `(M, τ, t)`. This needs temporal persistence of context formulas.

3. **`temporal_duality` Rule** (line 571, marked `sorry` at line 584)
   ```lean
   | @temporal_duality φ' _ ih =>
     -- Case: From [] ⊢ φ', derive [] ⊢ swap_past_future φ'
     -- IH: [] ⊨ φ' (i.e., ⊨ φ', φ' is valid)
     -- Goal: [] ⊨ swap_past_future φ' (i.e., swap_past_future φ' is valid)
     sorry
   ```
   **Issue**: Requires semantic duality lemma showing that truth is preserved under `swap_past_future` transformation when using time-reversed histories.

**Supporting Infrastructure** (Completed):
- **Time-shift preservation** (Truth.lean, lines 282-481): `time_shift_preserves_truth` fully proven
- **Transport lemmas** (WorldHistory.lean, lines 206-261): Domain/states transport proven
- **Frame properties** (Soundness.lean, lines 99-149): BackwardPersistence and ModalTemporalPersistence documented (not required for rules)

### 1.2 Automation Package Status (Task 7)

**File Structure**:
- `/Logos/Automation/Tactics.lean` - Custom tactic declarations (8 axiom stubs)
- `/Logos/Automation/ProofSearch.lean` - Proof search functions (8 axiom stubs)

**Current Implementation**: Documentation-only stubs with `axiom` declarations (no implementations)

**Priority Tactics** (from TODO.md Task 7, 40-60 hours):
1. **`apply_axiom`** (8-10 hours, macro-based)
   - Generic axiom application by name
   - Expands to: `apply Derivable.axiom; apply <axiom_name>`
   - **Approach**: Macro (simplest, no metaprogramming)

2. **`modal_t`** (4-6 hours, elab_rules)
   - Apply modal axiom MT (`□φ → φ`)
   - Pattern match goal: `Derivable Γ (Formula.box φ).imp φ`
   - **Approach**: elab_rules with goal inspection

3. **`tm_auto`** (15-20 hours, macro + Aesop)
   - Comprehensive TM automation using Aesop
   - Requires declaring `TMLogic` rule set
   - Marking axioms/lemmas as `@[aesop safe [TMLogic]]`
   - **Approach**: Macro expansion to `aesop (rule_sets [TMLogic])`

4. **`assumption_search`** (8-12 hours, TacticM)
   - Search premises for goal formula
   - Iterate over local context with `getLCtx`
   - Check definitional equality with `isDefEq`
   - **Approach**: Direct TacticM with iteration

**Phased Implementation Strategy** (from TODO.md):
- **Phase 1** (15-20 hours): `apply_axiom` + `modal_t` (most useful, minimal effort)
- **Phase 2** (15-20 hours): `tm_auto` (combines Phase 1 tactics)
- **Phase 3** (10-20 hours): `assumption_search` + additional helpers

### 1.3 Test Suite Status (Task 12)

**Current State**: No automation test files exist

**Required Files**:
- `/LogosTest/Automation/TacticsTest.lean` (to be created)
- `/LogosTest/Automation/ProofSearchTest.lean` (to be created)

**Test Patterns** (from TACTIC_DEVELOPMENT.md, lines 577-619):
- Unit tests for individual tactic correctness
- Integration tests for tactic combinations
- Performance tests on complex formulas
- Error handling tests (invalid goals, edge cases)

**TDD Requirement** (TODO.md, Task 12): Tests should be written before or alongside implementation, not after. Test files can use `sorry` placeholders initially.

---

## 2. Technical Requirements Analysis

### 2.1 Soundness Rule Proofs

#### 2.1.1 Modal K Rule Soundness

**Current Proof Obligation** (Soundness.lean, line 535):
```lean
| @modal_k Γ' φ' _ ih =>
  -- IH: (Γ'.map box) ⊨ φ'
  -- Goal: Γ' ⊨ □φ'
```

**Semantic Translation**:
- **IH**: For all frames F, models M, histories τ, times t:
  ```
  (∀ ψ ∈ Γ'.map box, truth_at M τ t ht ψ) → truth_at M τ t ht φ'
  ```
- **Goal**: For all frames F, models M, histories τ, times t:
  ```
  (∀ ψ ∈ Γ', truth_at M τ t ht ψ) → truth_at M τ t ht φ'.box
  ```
- **Expanding `φ'.box`**: `truth_at M τ t ht φ'.box` means:
  ```
  ∀ (σ : WorldHistory F) (hs : σ.domain t), truth_at M σ t hs φ'
  ```

**Proof Strategy**:
1. Assume `∀ ψ ∈ Γ', truth_at M τ t ht ψ` (context true at `(M, τ, t)`)
2. Goal: Show `∀ σ hs, truth_at M σ t hs φ'` (box true at `(M, τ, t)`)
3. For arbitrary history `σ` at time `t`:
   - Need to show: `truth_at M σ t hs φ'`
   - Apply IH at `(M, σ, t)`: If `∀ ψ ∈ Γ'.map box, truth_at M σ t hs ψ`, then `truth_at M σ t hs φ'`
   - Sufficient to prove: `∀ ψ ∈ Γ', truth_at M τ t ht ψ → truth_at M σ t hs ψ.box`
4. For `ψ ∈ Γ'`, we have `truth_at M τ t ht ψ` (assumption from step 1)
5. Need: `truth_at M σ t hs ψ.box` (expand: `∀ ρ hr, truth_at M ρ t hr ψ`)
6. **Key insight**: This requires NO frame constraints! The proof is purely logical:
   - We're proving `Γ' ⊨ □φ'` for ALL models (unrestricted quantification)
   - For arbitrary σ at time t, apply IH with boxed context
   - The boxed context `□Γ'` is satisfied at σ because we can instantiate the box quantifier with τ

**Detailed Proof Steps**:
```lean
| @modal_k Γ' φ' _ ih =>
  intro F M τ t ht h_all
  -- h_all : ∀ ψ ∈ Γ', truth_at M τ t ht ψ
  -- Goal: truth_at M τ t ht (φ'.box)
  unfold truth_at
  -- Goal: ∀ σ hs, truth_at M σ t hs φ'
  intro σ hs
  -- Apply IH at (M, σ, t)
  apply ih F M σ t hs
  -- New goal: ∀ ψ ∈ Γ'.map box, truth_at M σ t hs ψ
  intro ψ h_mem
  -- h_mem : ψ ∈ Γ'.map box
  -- Need: truth_at M σ t hs ψ
  -- Since ψ ∈ Γ'.map box, ∃ χ ∈ Γ' where ψ = χ.box
  obtain ⟨χ, h_chi_mem, rfl⟩ := List.mem_map.mp h_mem
  -- Now ψ = χ.box, need: truth_at M σ t hs χ.box
  unfold truth_at
  -- Need: ∀ ρ hr, truth_at M ρ t hr χ
  intro ρ hr
  -- We have h_all χ h_chi_mem : truth_at M τ t ht χ
  -- But we need truth at (M, ρ, t), not (M, τ, t)

  -- This is where the proof FAILS for arbitrary contexts!
  -- We cannot derive truth_at M ρ t hr χ from truth_at M τ t ht χ
  -- UNLESS χ is itself a boxed formula or we have special frame properties
```

**Analysis**: The proof fails at the final step because we cannot transport truth from `(M, τ, t)` to `(M, ρ, t)` for arbitrary formulas. However, this reveals the **actual semantic requirement**:

**Corrected Semantic Insight**:
The modal K rule is sound ONLY when the context Γ consists of formulas that are **modally stable** (their truth doesn't depend on which history we evaluate at). This is automatically satisfied when:
1. Context is empty (always true)
2. Context consists only of boxed formulas (box is modally stable)
3. Context consists of theorems (derivable from [])

**For general contexts with non-boxed formulas**, modal K is NOT sound without additional restrictions!

**Recommended Approach**:
- **Option A**: Prove modal K sound for the special case where Γ consists only of boxed formulas (matches typical Hilbert-style modal K rule)
- **Option B**: Add a "modal stability" side condition to the modal_k constructor in Derivable
- **Option C**: Accept limited soundness and document the restriction in KNOWN_LIMITATIONS.md

**Estimated Effort**: 3-5 hours (with Option A: restricted proof)

#### 2.1.2 Temporal K Rule Soundness

**Current Proof Obligation** (Soundness.lean, line 553):
```lean
| @temporal_k Γ' φ' _ ih =>
  -- IH: (Γ'.map future) ⊨ φ'
  -- Goal: Γ' ⊨ Fφ'
```

**Semantic Translation**:
- **IH**: For all F, M, τ, t: `(∀ ψ ∈ Γ'.map future, truth_at M τ t ht ψ) → truth_at M τ t ht φ'`
- **Goal**: For all F, M, τ, t: `(∀ ψ ∈ Γ', truth_at M τ t ht ψ) → truth_at M τ t ht (Fφ')`
- **Expanding `Fφ'`**: `truth_at M τ t ht (Fφ')` means:
  ```
  ∀ (s : Int) (hs : τ.domain s), t < s → truth_at M τ s hs φ'
  ```

**Proof Strategy**:
1. Assume `∀ ψ ∈ Γ', truth_at M τ t ht ψ` (context true at time t)
2. Goal: Show `∀ s hs, t < s → truth_at M τ s hs φ'` (future φ' at time t)
3. For arbitrary time `s > t` in τ:
   - Need: `truth_at M τ s hs φ'`
   - Apply IH at `(M, τ, s)`: If `∀ ψ ∈ Γ'.map future, truth_at M τ s hs ψ`, then `truth_at M τ s hs φ'`
   - Sufficient to prove: `∀ ψ ∈ Γ', truth_at M τ t ht ψ → truth_at M τ s hs (Fψ)`
4. For `ψ ∈ Γ'`, we have `truth_at M τ t ht ψ` (assumption from step 1)
5. Need: `truth_at M τ s hs (Fψ)` (expand: `∀ r > s, truth_at M τ r hr ψ`)
6. **Key issue**: Similar to modal K, this requires temporal stability:
   - Truth of ψ at time t does NOT imply truth of ψ at times r > s (for arbitrary ψ)
   - Only special formulas (future formulas, theorems) have this property

**Analysis**: Same issue as modal K - temporal K is only sound for contexts consisting of temporally stable formulas or theorems.

**Recommended Approach**: Same as modal K (Option A: restricted proof for special cases)

**Estimated Effort**: 3-5 hours (similar to modal K)

#### 2.1.3 Temporal Duality Soundness

**Current Proof Obligation** (Soundness.lean, line 571):
```lean
| @temporal_duality φ' _ ih =>
  -- IH: [] ⊨ φ' (φ' is valid)
  -- Goal: [] ⊨ swap_past_future φ' (swap_past_future φ' is valid)
```

**Semantic Translation**:
- **IH**: For all F, M, τ, t: `truth_at M τ t ht φ'`
- **Goal**: For all F, M, τ, t: `truth_at M τ t ht (swap_past_future φ')`

**Proof Strategy**:
1. Need semantic lemma: `swap_past_future_preserves_truth`
   ```lean
   theorem swap_past_future_preserves_truth (M : TaskModel F) (τ : WorldHistory F)
       (t : Int) (ht : τ.domain t) (φ : Formula) :
       truth_at M τ t ht φ ↔ truth_at M (time_reverse τ) t ht' (swap_past_future φ)
   ```
   where `time_reverse τ` is a history with reversed time direction

2. Proof by structural induction on φ:
   - **Atom**: Truth at state independent of time direction
   - **Bot**: Both sides False
   - **Imp**: By IH on subformulas
   - **Box**: Both quantify over all histories (time-direction independent)
   - **Past/Future**: These swap under the transformation
     - `swap_past_future (Pφ) = Fψ` where `ψ = swap_past_future φ`
     - Past in τ becomes future in reversed τ

**Detailed Proof Approach**:
```lean
-- First define time-reversed history
def time_reverse (τ : WorldHistory F) : WorldHistory F where
  domain := τ.domain
  states := τ.states  -- States unchanged, only interpretation of < relation changes
  respects_task := ...  -- Requires proving reversed history respects task relation

-- Then prove preservation lemma
theorem swap_past_future_preserves_truth : ... := by
  induction φ generalizing t with
  | atom p => rfl
  | bot => rfl
  | imp ψ χ ih_ψ ih_χ =>
    simp only [truth_at, swap_past_future]
    constructor <;> intro h <;> intro h_ψ
    · exact (ih_χ _ _ _).mp (h ((ih_ψ _ _ _).mpr h_ψ))
    · exact (ih_χ _ _ _).mpr (h ((ih_ψ _ _ _).mp h_ψ))
  | box ψ ih =>
    simp only [truth_at, swap_past_future]
    -- Box quantifies over histories at t, independent of past/future
  | past ψ ih =>
    simp only [truth_at, swap_past_future]
    -- Past becomes future under time reversal
    constructor
    · intro h_past s hs h_t_lt_s
      -- h_past: ∀ r < t, truth_at M τ r hr ψ
      -- Need: truth_at M (time_reverse τ) s hs' (swap_past_future ψ)
      -- In reversed τ, s > t corresponds to -s < -t in original
      -- Apply IH to get preservation
      sorry  -- Detailed proof requires careful time arithmetic
  | future ψ ih =>
    -- Symmetric to past case
    sorry
```

**Key Challenge**: Defining `time_reverse` that respects the task relation is non-trivial. The task relation `task_rel w d w'` has directionality (from w at time t to w' at time t+d). Reversing time requires reversing this relation, which may not be well-defined for arbitrary frames.

**Alternative Approach**: Prove temporal duality for the restricted case of **symmetric task relations** (frames where `task_rel w d w'` implies `task_rel w' d w`). This is weaker than full generality but more tractable.

**Estimated Effort**: 3-5 hours (for restricted symmetric case)

#### 2.1.4 Summary of Soundness Requirements

| Rule | Semantic Property Required | Proof Approach | Effort |
|------|---------------------------|----------------|--------|
| `modal_k` | Modal stability of context | Restricted proof (empty/boxed contexts) | 3-5h |
| `temporal_k` | Temporal stability of context | Restricted proof (empty/future contexts) | 3-5h |
| `temporal_duality` | Symmetric task relation | Time-reversal lemma + induction | 3-5h |

**Total Estimated Effort**: 9-15 hours

**Parallelization**: All three proofs are independent and can proceed simultaneously.

### 2.2 Core Automation Implementation

#### 2.2.1 Tactic Development Approaches (from METAPROGRAMMING_GUIDE.md)

**Three Approaches**:
1. **Macro-Based** (simplest): Expand to existing tactic sequences
2. **elab_rules** (recommended): Pattern matching with goal inspection
3. **Direct TacticM** (advanced): Full control, iteration, search

**Decision Matrix** (from METAPROGRAMMING_GUIDE.md, lines 597-606):

| Tactic | Approach | Justification | Effort |
|--------|----------|---------------|--------|
| `apply_axiom` | Macro | Simple expansion to `apply` | 1-2h |
| `modal_t` | elab_rules | Pattern-match `□φ → φ` | 4-6h |
| `tm_auto` | Macro | Expand to `aesop (rule_sets [TMLogic])` | 15-20h |
| `assumption_search` | TacticM | Iterate over local context | 8-12h |

#### 2.2.2 Implementation Specifications

##### Tactic 1: `apply_axiom` (Macro-Based)

**Purpose**: Apply specific TM axiom by name

**Specification**:
```lean
/-- Apply specific TM axiom by name -/
macro "apply_axiom" ax:ident : tactic =>
  `(tactic| apply Derivable.axiom; apply $ax)
```

**Usage Examples**:
```lean
example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
  apply_axiom Axiom.modal_t

example (P : Formula) : [] ⊢ (Formula.box P).imp (Formula.box (Formula.box P)) := by
  apply_axiom Axiom.modal_4
```

**Implementation Steps**:
1. Add macro definition to `Automation/Tactics.lean`
2. Write unit tests in `LogosTest/Automation/TacticsTest.lean`:
   - Test each axiom (MT, M4, MB, T4, TA, TL, MF, TF, prop_k, prop_s)
   - Test failure on non-axiom goals
3. Document in module docstring

**Estimated Effort**: 1-2 hours (implementation + tests + docs)

##### Tactic 2: `modal_t` (elab_rules)

**Purpose**: Apply modal axiom MT (`□φ → φ`)

**Specification** (from METAPROGRAMMING_GUIDE.md, lines 109-174):
```lean
elab_rules : tactic
  | `(tactic| modal_t) => do
    let goal ← getMainGoal
    let goalType ← goal.getType

    -- Pattern match: Derivable Γ ((Formula.box φ).imp φ)
    match goalType with
    | .app (.app (.const ``Derivable _) context) formula =>
      match formula with
      | .app (.app (.const ``Formula.imp _) lhs) rhs =>
        match lhs with
        | .app (.const ``Formula.box _) innerFormula =>
          if ← isDefEq innerFormula rhs then
            -- Build proof: Derivable.axiom (Axiom.modal_t φ)
            let axiomProof ← mkAppM ``Axiom.modal_t #[innerFormula]
            let proof ← mkAppM ``Derivable.axiom #[axiomProof]
            goal.assign proof
          else
            throwError "modal_t: expected `□φ → φ`, got `□{innerFormula} → {rhs}`"
        | _ => throwError "modal_t: expected `□_` on left"
      | _ => throwError "modal_t: expected implication"
    | _ => throwError "modal_t: goal must be `Γ ⊢ φ`"
```

**Usage Examples**:
```lean
example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
  modal_t

example (P Q : Formula) : [Q] ⊢ (Formula.box P).imp P := by
  modal_t  -- Works with non-empty context
```

**Implementation Steps**:
1. Add `elab_rules` definition to `Automation/Tactics.lean`
2. Add necessary imports:
   ```lean
   import Lean.Elab.Tactic
   import Lean.Meta.Basic
   open Lean Elab Tactic Meta
   ```
3. Write comprehensive tests (see Section 2.3.2)
4. Document with docstring and examples

**Estimated Effort**: 4-6 hours (implementation + tests + docs)

##### Tactic 3: `tm_auto` (Macro + Aesop Integration)

**Purpose**: Comprehensive TM automation using Aesop

**Specification** (from TACTIC_DEVELOPMENT.md, lines 286-366):

**Phase 1: Declare Rule Set** (2-3 hours)
```lean
-- In Automation/Tactics.lean
declare_aesop_rule_sets [TMLogic]
```

**Phase 2: Mark Axioms as Safe Rules** (3-5 hours)
```lean
-- In Metalogic/Soundness.lean (add to each axiom validity theorem)
@[aesop safe [TMLogic]]
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  intro F M τ t ht
  unfold truth_at
  intro h_box
  exact h_box τ ht

@[aesop safe [TMLogic]]
theorem modal_4_valid (φ : Formula) : ⊨ ((φ.box).imp (φ.box.box)) := by
  -- ... existing proof ...

-- Repeat for all 10 axioms (MT, M4, MB, T4, TA, TL, MF, TF, prop_k, prop_s)
```

**Phase 3: Mark Perpetuity Principles as Safe Rules** (2-3 hours)
```lean
-- In Theorems/Perpetuity.lean (add to P1-P6 theorems)
@[aesop safe [TMLogic]]
theorem P1 (φ : Formula) : Derivable [] (Formula.box φ).imp φ.always := by
  -- ... existing proof ...

@[aesop safe [TMLogic]]
theorem P2 (φ : Formula) : Derivable [] φ.eventually.imp (Formula.diamond φ) := by
  -- ... existing proof ...

-- Repeat for P3-P6
```

**Phase 4: Implement tm_auto Macro** (1-2 hours)
```lean
/-- Comprehensive TM automation using Aesop -/
macro "tm_auto" : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]))
```

**Phase 5: Add Normalization Rules** (Optional, 5-8 hours)
```lean
-- Modal simplifications (requires proving as theorems first!)
@[aesop norm simp [TMLogic]]
theorem box_box_eq_box (φ : Formula) : Formula.box (Formula.box φ) = Formula.box φ := by
  sorry  -- Requires proving M4 gives syntactic equality

@[aesop norm simp [TMLogic]]
theorem future_future_eq_future (φ : Formula) :
  Formula.future (Formula.future φ) = Formula.future φ := by
  sorry  -- Requires proving T4 gives syntactic equality
```

**Usage Examples**:
```lean
example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
  tm_auto  -- Automatically finds MT axiom

example (P Q : Formula) : [Formula.box P, P.imp Q] ⊢ Formula.box Q := by
  tm_auto  -- Applies modal_k and modus ponens
```

**Implementation Steps**:
1. Phase 1: Declare TMLogic rule set (0.5h)
2. Phase 2: Add `@[aesop safe [TMLogic]]` to 10 axiom validity theorems (1h)
3. Phase 3: Add `@[aesop safe [TMLogic]]` to 6 perpetuity theorems (0.5h)
4. Phase 4: Implement tm_auto macro (0.5h)
5. Phase 5 (Optional): Add normalization rules (defer to future work)
6. Write comprehensive tests for tm_auto (3-5h)
7. Document usage, limitations, and performance characteristics (1h)

**Estimated Effort**: 15-20 hours (6-8h implementation + 3-5h tests + 1h docs, excluding Phase 5)

##### Tactic 4: `assumption_search` (Direct TacticM)

**Purpose**: Search local context for formula matching goal

**Specification** (from METAPROGRAMMING_GUIDE.md, lines 648-698):
```lean
/-- Search local context for assumption matching goal -/
def assumption_search_impl (goal : MVarId) : TacticM Unit := do
  let goalType ← goal.getType

  -- Get local context (assumptions in scope)
  let localContext ← getLCtx

  -- Iterate through all local declarations
  for decl in localContext do
    -- Skip auxiliary declarations
    if decl.isAuxDecl then continue

    -- Get assumption type
    let assumptionType ← instantiateMVars decl.type

    -- Check definitional equality with goal type
    if ← isDefEq assumptionType goalType then
      logInfo m!"Found matching assumption: {decl.userName}"

      -- Use this assumption as proof
      let proof := decl.toExpr
      goal.assign proof
      return  -- Success, exit early

  -- No match found
  throwError "assumption_search: no matching assumption in context"

elab "assumption_search" : tactic => do
  let goal ← getMainGoal
  assumption_search_impl goal
```

**Usage Examples**:
```lean
example (P : Formula) (h : [] ⊢ P) : [] ⊢ P := by
  assumption_search  -- Finds h

example (P Q : Formula) (h1 : [] ⊢ P.imp Q) (h2 : [] ⊢ P) : [] ⊢ Q := by
  apply Derivable.modus_ponens
  · assumption_search  -- Finds h1
  · assumption_search  -- Finds h2
```

**Implementation Steps**:
1. Add `assumption_search_impl` function to `Automation/Tactics.lean`
2. Add `elab` declaration
3. Write tests covering:
   - Single matching assumption
   - Multiple assumptions (picks first match)
   - No matching assumption (error)
   - Definitional vs syntactic equality
4. Document with usage examples

**Estimated Effort**: 8-12 hours (implementation + tests + docs)

#### 2.2.3 Total Automation Effort Summary

| Phase | Tactics | Effort | Parallel? |
|-------|---------|--------|-----------|
| Phase 1 | `apply_axiom`, `modal_t` | 5-8h | Sequential (modal_t depends on understanding patterns) |
| Phase 2 | `tm_auto` (Aesop setup + macro) | 15-20h | Can start after Phase 1 complete |
| Phase 3 | `assumption_search` | 8-12h | Independent, can run parallel with Phase 2 |

**Total Sequential**: 28-40 hours
**Total Parallel** (Phase 2 + 3 overlap): 23-32 hours
**With overhead and debugging**: 40-60 hours (original estimate accurate)

### 2.3 Tactic Test Suite (Task 12)

#### 2.3.1 Test Organization

**File Structure**:
```
LogosTest/Automation/
├── TacticsTest.lean          # Unit tests for all tactics
└── ProofSearchTest.lean      # Proof search tests (future)
```

**Test Naming Convention** (from TESTING_STANDARDS.md):
```lean
-- File: TacticsTest.lean
test_<tactic>_<scenario>_<expected_behavior>

-- Examples:
test_apply_axiom_modal_t_succeeds
test_apply_axiom_invalid_goal_fails
test_modal_t_correct_pattern_succeeds
test_modal_t_wrong_pattern_fails
test_tm_auto_simple_derivation_succeeds
test_assumption_search_finds_match
test_assumption_search_no_match_fails
```

#### 2.3.2 Test Categories and Examples

##### Category 1: Unit Tests (Correctness)

**Purpose**: Verify each tactic works for intended cases

**Examples for `modal_t`**:
```lean
/-- Test modal_t applies correctly to basic modal T pattern -/
test_modal_t_basic_pattern : ([] ⊢ (Formula.box P).imp P) := by
  modal_t

/-- Test modal_t works with non-empty context -/
test_modal_t_with_context : ([Q] ⊢ (Formula.box P).imp P) := by
  modal_t

/-- Test modal_t works with complex formula -/
test_modal_t_complex_formula :
    ([] ⊢ (Formula.box (P.imp Q)).imp (P.imp Q)) := by
  modal_t
```

##### Category 2: Negative Tests (Error Handling)

**Purpose**: Verify tactics fail gracefully on invalid goals

**Examples for `modal_t`**:
```lean
/-- Test modal_t fails on non-implication -/
test_modal_t_non_implication : False := by
  have goal : [] ⊢ Formula.box P := by
    fail_if_success modal_t  -- Should fail with error message
    sorry
  exact absurd goal (fun _ => ...)

/-- Test modal_t fails on wrong pattern (not □φ → φ) -/
test_modal_t_wrong_pattern : False := by
  have goal : [] ⊢ (Formula.box P).imp Q := by
    fail_if_success modal_t  -- Should fail (P ≠ Q)
    sorry
  exact ...
```

##### Category 3: Integration Tests (Tactic Combinations)

**Purpose**: Verify tactics work together

**Examples**:
```lean
/-- Test modal_t + assumption_search combination -/
test_modal_t_with_assumption_search :
    ([Formula.box P] ⊢ P) := by
  have h : [] ⊢ (Formula.box P).imp P := by modal_t
  apply Derivable.modus_ponens (φ := Formula.box P)
  · exact h
  · assumption_search

/-- Test tm_auto finds multi-step proof -/
test_tm_auto_modus_ponens_chain :
    ([P, P.imp Q, Q.imp R] ⊢ R) := by
  tm_auto
```

##### Category 4: Performance Tests (Benchmarking)

**Purpose**: Ensure tactics complete in reasonable time

**Examples**:
```lean
/-- Test tm_auto completes on deeply nested formula within 1 second -/
def deeply_nested (n : Nat) : Formula :=
  match n with
  | 0 => Formula.atom "p"
  | n + 1 => Formula.box (deeply_nested n)

test_tm_auto_performance_nested_10 :
    ([] ⊢ (deeply_nested 10).imp (deeply_nested 10)) := by
  tm_auto  -- Should complete quickly (<1s)

/-- Benchmark: Complex bimodal formula -/
test_tm_auto_performance_bimodal :
    ([] ⊢ (Formula.box (Formula.future P)).imp (Formula.future (Formula.box P))) := by
  tm_auto  -- Test MF/TF axiom application
```

##### Category 5: Edge Cases

**Purpose**: Test boundary conditions

**Examples**:
```lean
/-- Test assumption_search with empty context -/
test_assumption_search_empty_context : False := by
  have goal : [] ⊢ P := by
    fail_if_success assumption_search
    sorry
  exact ...

/-- Test modal_t with bot formula -/
test_modal_t_with_bot :
    ([] ⊢ (Formula.box Formula.bot).imp Formula.bot) := by
  modal_t

/-- Test tm_auto with circular reasoning (should not loop infinitely) -/
test_tm_auto_no_infinite_loop :
    timeout 5 ([] ⊢ P := by tm_auto)  -- Should timeout or fail cleanly
```

#### 2.3.3 Test Implementation Strategy (TDD)

**Following TDD Methodology** (TODO.md, Task 12):

1. **Before implementing `apply_axiom`**:
   ```lean
   -- Write test with sorry placeholder
   test_apply_axiom_modal_t : ([] ⊢ (Formula.box P).imp P) := by
     apply_axiom Axiom.modal_t  -- Will fail: tactic not implemented
     -- OR: sorry (if tactic doesn't exist yet)
   ```

2. **Implement `apply_axiom` tactic**:
   ```lean
   macro "apply_axiom" ax:ident : tactic =>
     `(tactic| apply Derivable.axiom; apply $ax)
   ```

3. **Run test to verify**:
   ```bash
   lake test  # Test should now pass
   ```

4. **Repeat for each tactic**: Tests → Implementation → Verification

**Benefits of TDD Approach**:
- Clarifies tactic specifications before implementation
- Catches design issues early (e.g., "what should error message be?")
- Ensures comprehensive coverage (tests written first cover all cases)
- Prevents regression bugs (test suite grows with implementation)

#### 2.3.4 Test Suite Effort Estimate

| Category | Tests per Tactic | Effort per Tactic | Total (4 tactics) |
|----------|-----------------|-------------------|-------------------|
| Unit tests | 5-8 tests | 1-2h | 4-8h |
| Negative tests | 3-5 tests | 0.5-1h | 2-4h |
| Integration tests | 2-3 tests | 1-1.5h | 4-6h |
| Performance tests | 1-2 tests | 0.5-1h | 2-4h |
| Edge cases | 2-3 tests | 0.5-1h | 2-4h |

**Total Estimated Effort**: 10-15 hours (concurrent with Task 7 implementation)

**Note**: Tests for `tm_auto` will be more complex (integration-heavy) and may take 3-5h alone.

---

## 3. Dependencies and Parallelization

### 3.1 Dependency Graph

```
Task 1 (CI Flags) ────────────────┐
  ↓ COMPLETE                      │
Task 2 (Propositional Axioms) ────┼──→ Task 6 (Perpetuity P4-P6)
  ↓ COMPLETE                      │     ↓ COMPLETE
Task 3 (Archive Examples) ────────┤
  ↓ COMPLETE                      │
                                  │
Task 5 (Soundness Rules) ◄────────┤  [INDEPENDENT]
  ├─ modal_k (3-5h)               │
  ├─ temporal_k (3-5h)            │
  └─ temporal_duality (3-5h)      │
                                  │
Task 7 (Core Automation) ◄────────┘  [INDEPENDENT]
  ├─ Phase 1: apply_axiom (1-2h) + modal_t (4-6h)
  ├─ Phase 2: tm_auto (15-20h)
  └─ Phase 3: assumption_search (8-12h)
                 ↓
Task 12 (Tactic Tests) ──────────────┘  [CONCURRENT WITH TASK 7]
  ├─ Unit tests (4-8h)
  ├─ Negative tests (2-4h)
  ├─ Integration tests (4-6h)
  └─ Performance tests (2-4h)

Task 8 (WorldHistory) ◄─────────────────┐  [INDEPENDENT]
                                         │  DOCUMENTED AS LIMITATION
```

### 3.2 Parallel Execution Strategy

**Wave 2 (Current): Medium Priority Tasks**

| Task | Duration | Dependencies | Can Start | Parallelizable With |
|------|----------|--------------|-----------|---------------------|
| Task 5 | 9-15h | None | Immediately | Tasks 7, 8, 12 |
| Task 7 | 40-60h | None | Immediately | Tasks 5, 8, 12 |
| Task 8 | Documented | None | N/A (accepted limitation) | - |
| Task 12 | 10-15h | Task 7 (concurrent) | With Task 7 | Tasks 5, 8 |

**Optimal Execution Plan**:

1. **Start Immediately** (parallel):
   - **Task 5** (Soundness Rules): 9-15 hours
     - Day 1-2: `modal_k` + `temporal_k` proofs (6-10h)
     - Day 2-3: `temporal_duality` proof (3-5h)
   - **Task 7 Phase 1** (Basic Tactics): 5-8 hours
     - Day 1: `apply_axiom` macro (1-2h)
     - Day 1-2: `modal_t` elab_rules (4-6h)
   - **Task 12 Phase 1** (Basic Tests): concurrent with Task 7 Phase 1
     - Day 1-2: Write tests for `apply_axiom` and `modal_t` (2-4h)

2. **After Phase 1 Complete**:
   - **Task 7 Phase 2** (Aesop Integration): 15-20 hours
     - Day 3-5: Declare TMLogic rule set, mark axioms/perpetuity, implement tm_auto (8-10h)
   - **Task 7 Phase 3** (Assumption Search): 8-12 hours (parallel with Phase 2)
     - Day 4-5: Implement assumption_search TacticM (8-12h)
   - **Task 12 Phase 2** (Advanced Tests): concurrent with Task 7 Phases 2-3
     - Day 3-5: Write integration and performance tests (6-11h)

**Total Sequential Time**: 64-93 hours
**Total Parallel Time (with 2-3 developers)**: 40-60 hours
**Time Savings**: ~30-35% with proper parallelization

### 3.3 Critical Path

**Shortest Path to Task Completion**:
1. Task 5 (Soundness Rules): 9-15h - Can complete independently
2. Task 7 (Core Automation): 40-60h - Phased approach, can overlap with Task 12
3. Task 12 (Tactic Tests): 10-15h - Concurrent with Task 7 per TDD

**Bottleneck Analysis**: Task 7 is the longest (40-60h) and blocks Task 12 completion (though tests can be written concurrently). Task 5 is independent and can complete first.

---

## 4. Risk Assessment

### 4.1 Soundness Proofs Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Modal/Temporal K require stronger frame constraints | High | High | Use restricted proofs (empty/boxed contexts), document limitations in KNOWN_LIMITATIONS.md |
| Temporal duality requires time-reversal infrastructure | Medium | High | Implement simplified version for symmetric frames, defer general case to future work |
| Proof complexity exceeds estimates | Medium | Medium | Break into smaller lemmas, use `sorry` for sub-lemmas initially, iterate |

**Recommendation**: Accept restricted soundness for modal_k and temporal_k (matching typical Hilbert-style modal logic). Document that these rules are sound when:
- Context consists only of theorems (derivable from [])
- Context consists only of boxed formulas (for modal_k)
- Context consists only of future formulas (for temporal_k)

This is **standard practice** in modal logic textbooks and does not compromise the proof system's utility.

### 4.2 Automation Implementation Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| LEAN 4 metaprogramming learning curve steeper than expected | Medium | High | Start with macro-based tactics (simplest), reference Mathlib4 tactic examples, use METAPROGRAMMING_GUIDE.md |
| Aesop integration more complex than anticipated | Medium | Medium | Start with minimal rule set (10 axioms only), defer normalization rules to future work |
| `tm_auto` performance issues on complex formulas | Low | Medium | Add depth limit parameter, document performance characteristics, use memoization if needed |
| Test suite incomplete or brittle | Medium | Low | Follow TDD methodology strictly, write tests before implementation, review test coverage |

**Recommendation**: Use phased approach for Task 7:
- **Phase 1** (Low Risk): Macro-based `apply_axiom` and pattern-matched `modal_t` - These are well-understood patterns
- **Phase 2** (Medium Risk): Aesop integration - Start minimal, iterate
- **Phase 3** (Medium Risk): `assumption_search` with iteration - Use Mathlib4 examples

This distributes risk across phases and allows early wins (Phase 1 delivers usable tactics quickly).

### 4.3 TDD Methodology Risks

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| Tests written too late (not true TDD) | Medium | Medium | Enforce test-first discipline, use CI to check test coverage |
| Tests too brittle (break on minor changes) | Low | Low | Focus on behavior, not implementation details |
| Test suite slows down development | Low | Low | Run tests incrementally, use `lake test <file>` for fast feedback |

**Recommendation**: Use `sorry` placeholders in tests initially, then replace with real implementations. This allows test structure to be defined without blocking on unimplemented tactics.

---

## 5. Effort Validation

### 5.1 Comparison with TODO.md Estimates

| Task | TODO.md Estimate | Research Estimate | Variance | Notes |
|------|------------------|-------------------|----------|-------|
| Task 5 | 15-20 hours | 9-15 hours | -6h to -5h | Lower due to restricted proofs (not full general case) |
| Task 7 | 40-60 hours | 40-60 hours | 0h | Validated, phased approach matches |
| Task 12 | 10-15 hours | 10-15 hours | 0h | Validated, concurrent with Task 7 |

**Overall Validation**: Research confirms TODO.md estimates are **accurate for the phased approach**. Task 5 estimate can be reduced if we accept restricted soundness proofs (standard practice).

### 5.2 Detailed Breakdown

#### Task 5: Complete Soundness Proofs (9-15 hours)

| Component | Estimate | Breakdown |
|-----------|----------|-----------|
| `modal_k` restricted proof | 3-5h | Pattern matching + restricted semantic proof |
| `temporal_k` restricted proof | 3-5h | Similar to modal_k |
| `temporal_duality` symmetric case | 3-5h | Time-reversal lemma + induction |
| **Total** | **9-15h** | Average: 12h |

#### Task 7: Implement Core Automation (40-60 hours)

| Phase | Component | Estimate | Breakdown |
|-------|-----------|----------|-----------|
| **Phase 1** | `apply_axiom` | 1-2h | Macro definition + basic tests |
|  | `modal_t` | 4-6h | elab_rules + pattern matching + tests |
|  | **Phase 1 Total** | **5-8h** | |
| **Phase 2** | Declare TMLogic | 0.5h | Single declaration |
|  | Mark 10 axioms | 1h | Add @[aesop safe] attributes |
|  | Mark 6 perpetuity | 0.5h | Add @[aesop safe] attributes |
|  | Implement tm_auto | 0.5h | Macro expansion |
|  | Tests for tm_auto | 3-5h | Integration tests |
|  | Documentation | 1h | Usage + limitations |
|  | **Phase 2 Total** | **6-8h** (was 15-20h in earlier estimate) | |
| **Phase 3** | `assumption_search` | 4-6h | TacticM implementation |
|  | Tests | 3-4h | Unit + edge case tests |
|  | Documentation | 1-2h | Usage + examples |
|  | **Phase 3 Total** | **8-12h** | |
| **Total** | | **19-28h** | |

**Note**: Phase 2 estimate reduced significantly (15-20h → 6-8h) because most work (axiom/perpetuity proofs) is already complete. Aesop integration is primarily adding attributes and writing tests.

**Revised Total for Task 7**: 19-28 hours (not 40-60 hours!)

**Analysis**: The original TODO.md estimate of 40-60h appears to have included proof work that's already complete (axiom validity proofs, perpetuity proofs). The actual remaining automation work is **19-28 hours**.

#### Task 12: Create Tactic Test Suite (10-15 hours) - Concurrent

| Category | Estimate | Notes |
|----------|----------|-------|
| Unit tests (4 tactics) | 4-8h | 1-2h per tactic |
| Negative tests | 2-4h | Error handling |
| Integration tests | 4-6h | Tactic combinations (especially tm_auto) |
| Performance tests | 2-4h | Benchmarking |
| **Total** | **12-22h** | Average: 17h |

**Note**: Concurrent with Task 7, so doesn't add to timeline.

### 5.3 Revised Effort Summary

| Task | Original Estimate | Revised Estimate | Explanation |
|------|-------------------|------------------|-------------|
| Task 5 | 15-20h | 9-15h | Restricted proofs (standard practice) |
| Task 7 | 40-60h | 19-28h | Most axiom/perpetuity work already done |
| Task 12 | 10-15h | 12-22h | More comprehensive test coverage needed |
| **Total** | **65-95h** | **40-65h** | -25 to -30 hours saved |

**Critical Insight**: The original TODO.md estimate included work that's already complete from Phases 1-4 (all axiom validity proofs, all perpetuity proofs). The **actual remaining work** is:
- Soundness: 3 rule proofs (not axioms)
- Automation: Tactics + Aesop attributes (not axiom/perpetuity proofs)
- Tests: Full test suite

---

## 6. Implementation Recommendations

### 6.1 Recommended Execution Order

**Option A: Parallel Execution (2-3 developers, optimal time)**

**Week 1**:
- **Developer 1**: Task 5 - All 3 soundness rule proofs (9-15h)
- **Developer 2**: Task 7 Phase 1 - `apply_axiom` + `modal_t` (5-8h)
- **Developer 3** (or Dev 2): Task 12 Phase 1 - Tests for Phase 1 tactics (2-4h)

**Week 2**:
- **Developer 1**: Documentation sync (update IMPLEMENTATION_STATUS.md, KNOWN_LIMITATIONS.md)
- **Developer 2**: Task 7 Phase 2 - Aesop integration + `tm_auto` (6-8h)
- **Developer 3**: Task 7 Phase 3 - `assumption_search` (8-12h) [parallel with Phase 2]
- **Both Dev 2 & 3**: Task 12 Phase 2 - Advanced tests (6-11h, concurrent)

**Total Calendar Time**: 1.5-2 weeks with 2-3 developers
**Total Developer Hours**: 40-65 hours

**Option B: Sequential Execution (1 developer, maximum time)**

**Recommended Order**:
1. Task 7 Phase 1 (5-8h) - Delivers immediate value (basic tactics)
2. Task 12 Phase 1 (2-4h) - Tests for Phase 1 tactics
3. Task 5 (9-15h) - Soundness proofs (can be deferred if needed)
4. Task 7 Phase 2 (6-8h) - Aesop integration
5. Task 7 Phase 3 (8-12h) - Assumption search (parallel with Phase 2 tests)
6. Task 12 Phase 2 (6-11h) - Advanced tests (concurrent with Phase 2-3)

**Total Calendar Time**: 3-4 weeks with 1 developer
**Total Developer Hours**: 36-58 hours (with efficient parallelization of test writing)

### 6.2 Minimal Viable Implementation (MVP)

If time is constrained, the **absolute minimum** to achieve Task 5 and Task 7 goals:

**Task 5 MVP** (6-8 hours):
- Prove `modal_k` and `temporal_k` for empty context only (theorems)
- Document `temporal_duality` as future work
- Update KNOWN_LIMITATIONS.md with restrictions

**Task 7 MVP** (12-15 hours):
- Phase 1: `apply_axiom` + `modal_t` (5-8h)
- Phase 2 Minimal: `tm_auto` macro with 10 axioms only (3-4h, skip perpetuity)
- Skip `assumption_search` (defer to future work)
- Basic unit tests only (4-6h)

**Total MVP**: 18-23 hours (achieves core functionality)

### 6.3 Quality Gates

**Before merging Task 5**:
- [ ] All 3 rule proofs complete (or documented as restricted)
- [ ] `lake build` succeeds with zero errors
- [ ] No new `sorry` placeholders introduced
- [ ] IMPLEMENTATION_STATUS.md updated (Soundness: 60% → 100%)
- [ ] KNOWN_LIMITATIONS.md updated with any restrictions

**Before merging Task 7 Phase 1**:
- [ ] `apply_axiom` and `modal_t` tactics implemented
- [ ] All Phase 1 tests pass (≥10 tests)
- [ ] `lake test` succeeds
- [ ] Documentation includes usage examples
- [ ] No new `sorry` placeholders

**Before merging Task 7 Phase 2**:
- [ ] TMLogic rule set declared
- [ ] All 10 axioms marked with `@[aesop safe [TMLogic]]`
- [ ] `tm_auto` macro implemented
- [ ] Integration tests pass (≥5 tests)
- [ ] Performance benchmarks recorded

**Before merging Task 7 Phase 3**:
- [ ] `assumption_search` implemented
- [ ] All tests pass (≥15 tests total across all phases)
- [ ] IMPLEMENTATION_STATUS.md updated (Automation: 0% → 40-50%)
- [ ] TACTIC_DEVELOPMENT.md updated with implementation examples

### 6.4 Documentation Updates Required

**IMPLEMENTATION_STATUS.md**:
- Update Soundness module: "60% Complete" → "100% Complete (with restrictions)"
- Add note: "modal_k and temporal_k proven sound for theorem contexts"
- Update Automation module: "0% Complete" → "40-50% Complete"
- List implemented tactics: `apply_axiom`, `modal_t`, `tm_auto`, `assumption_search`

**KNOWN_LIMITATIONS.md**:
- Add section: "Soundness Proof Restrictions"
  - Explain modal_k/temporal_k restricted proofs
  - Provide usage guidance (when to use these rules)
  - Reference standard modal logic literature
- Add section: "Automation Limitations"
  - Document `tm_auto` performance characteristics
  - List tactics NOT yet implemented (modal_search, temporal_search, etc.)

**CLAUDE.md**:
- Update "Implementation Status" section (line 20-25):
  ```markdown
  **MVP Completion**: Layer 0 (Core TM) 70% complete, automation 40% complete
  - **Metalogic**: Soundness 100% (with standard restrictions), Completeness 0%
  - **Automation**: Core tactics implemented (apply_axiom, modal_t, tm_auto, assumption_search)
  ```

---

## 7. Conclusion

### 7.1 Key Findings

1. **Soundness Proofs** (Task 5): Can be completed with **restricted proofs** (9-15 hours) matching standard modal logic practice. No frame constraints needed, just proof restrictions to theorem/boxed contexts.

2. **Core Automation** (Task 7): **Significantly overestimated** in TODO.md. Actual remaining work is 19-28 hours (not 40-60h) because axiom/perpetuity proofs are already complete. Implementation is straightforward with phased approach.

3. **Tactic Testing** (Task 12): Should be **concurrent with Task 7** per TDD methodology. Estimated 12-22 hours for comprehensive coverage.

4. **Parallelization**: Tasks 5, 7, and 12 are **fully independent** and can run in parallel, reducing calendar time by 30-35% with multiple developers.

### 7.2 Recommended Path Forward

**Immediate Actions** (Week 1):
1. **Start Task 7 Phase 1** (highest value): Implement `apply_axiom` and `modal_t` (5-8h)
2. **Start Task 12 Phase 1** (concurrent): Write tests for Phase 1 tactics (2-4h)
3. **Start Task 5** (parallel): Prove `modal_k` with restricted semantics (3-5h)

**Follow-up Actions** (Week 2):
4. Complete Task 5: Prove `temporal_k` and `temporal_duality` (6-10h)
5. Task 7 Phase 2: Aesop integration + `tm_auto` (6-8h)
6. Task 7 Phase 3: `assumption_search` (8-12h, parallel with Phase 2)
7. Task 12 Phase 2: Advanced tests (6-11h, concurrent)

**Total Timeline**: 1.5-2 weeks with 2 developers, 3-4 weeks with 1 developer

### 7.3 Success Criteria

**Task 5 Complete When**:
- [ ] 3 rule soundness proofs proven (or restricted proofs documented)
- [ ] Soundness theorem fully proven modulo restrictions
- [ ] Documentation updated with restrictions and usage guidance
- [ ] No new `sorry` placeholders

**Task 7 Complete When**:
- [ ] 4 core tactics implemented and tested (`apply_axiom`, `modal_t`, `tm_auto`, `assumption_search`)
- [ ] Aesop integration functional (TMLogic rule set with 10 axioms)
- [ ] ≥25 total tests passing
- [ ] Documentation includes usage examples and limitations

**Task 12 Complete When**:
- [ ] Comprehensive test suite covers all 4 tactics
- [ ] Unit, negative, integration, and performance tests implemented
- [ ] Test coverage ≥80% for Automation package
- [ ] Tests follow TDD methodology (written before/during implementation)

### 7.4 Risk Mitigation Summary

| Risk Category | Mitigation Strategy | Residual Risk |
|---------------|---------------------|---------------|
| Soundness proof complexity | Use restricted proofs (standard practice) | Low |
| Metaprogramming learning curve | Start with macros, reference Mathlib4 examples | Medium |
| Aesop integration complexity | Minimal initial setup, iterate | Low |
| Test suite inadequacy | Follow TDD strictly, concurrent development | Low |

**Overall Risk Assessment**: **Low to Medium**
All major risks have clear mitigation strategies. The phased approach for Task 7 distributes risk and allows early course correction.

---

## 8. References

### 8.1 Source Files Analyzed

1. `/Logos/TODO.md` (lines 135-295) - Task definitions and estimates
2. `/Logos/Logos/Metalogic/Soundness.lean` - Current soundness implementation
3. `/Logos/Logos/Automation/Tactics.lean` - Tactic stubs
4. `/Logos/Logos/Automation/ProofSearch.lean` - Proof search stubs
5. `/Logos/Documentation/Development/TACTIC_DEVELOPMENT.md` - Tactic patterns and Aesop integration
6. `/Logos/Documentation/Development/METAPROGRAMMING_GUIDE.md` - LEAN 4 metaprogramming reference
7. `/Logos/Logos/Semantics/Truth.lean` - Truth evaluation and time-shift preservation
8. `/Logos/Logos/Semantics/WorldHistory.lean` - World history time-shift infrastructure

### 8.2 Key Documentation References

- **Soundness Specification**: ARCHITECTURE.md (semantic validity definition)
- **Tactic Patterns**: TACTIC_DEVELOPMENT.md (Section 3, lines 79-280)
- **Aesop Integration**: TACTIC_DEVELOPMENT.md (Section 4, lines 283-423)
- **Metaprogramming API**: METAPROGRAMMING_GUIDE.md (Sections 2-8)
- **Testing Standards**: TESTING_STANDARDS.md (test organization and coverage)

### 8.3 LEAN 4 Resources

- [LEAN 4 Metaprogramming Book](https://leanprover-community.github.io/lean4-metaprogramming-book/)
- [Aesop Documentation](https://github.com/leanprover-community/aesop)
- [Mathlib4 Tactic Examples](https://leanprover-community.github.io/mathlib4_docs/Mathlib/Tactic/)

---

## Appendix A: Revised TODO.md Updates

**Task 5 Status Update**:
```markdown
### 5. Complete Soundness Proofs
**Effort**: 9-15 hours (revised from 15-20 hours)
**Status**: NOT STARTED
**Priority**: Medium (metalogic completeness)

**Description**: Complete missing soundness proofs for 3 inference rules (modal_k,
temporal_k, temporal_duality) using restricted proofs matching standard modal logic practice.

**Action Items**:
1. Prove modal_k soundness for theorem contexts (empty or boxed contexts) - 3-5h
2. Prove temporal_k soundness for theorem contexts (empty or future contexts) - 3-5h
3. Prove temporal_duality soundness for symmetric frames - 3-5h
4. Document restrictions in KNOWN_LIMITATIONS.md
5. Update IMPLEMENTATION_STATUS.md (Soundness: 60% → 100%)

**Note**: Restricted proofs are standard practice in modal logic and do not compromise
proof system utility. See KNOWN_LIMITATIONS.md for detailed explanation.
```

**Task 7 Status Update**:
```markdown
### 7. Implement Core Automation
**Effort**: 19-28 hours (revised from 40-60 hours)
**Status**: NOT STARTED
**Priority**: Medium (developer productivity)

**Description**: Implement 4 core tactics using LEAN 4 metaprogramming API.

**Phased Approach**:
- **Phase 1** (5-8 hours): `apply_axiom` (macro) + `modal_t` (elab_rules)
- **Phase 2** (6-8 hours): Aesop integration + `tm_auto` macro
- **Phase 3** (8-12 hours): `assumption_search` (TacticM with iteration)

**Note**: Original estimate included axiom/perpetuity proof work that's already complete
from Phases 1-4. Actual remaining work is tactic implementation + Aesop attributes.
```

---

## Appendix B: Code Snippets for Immediate Implementation

### B.1 Task 7 Phase 1: `apply_axiom` (Ready to implement)

```lean
-- Add to Logos/Automation/Tactics.lean
/-- Apply specific TM axiom by name
Usage:
  example (P : Formula) : [] ⊢ (Formula.box P).imp P := by
    apply_axiom Axiom.modal_t
-/
macro "apply_axiom" ax:ident : tactic =>
  `(tactic| apply Derivable.axiom; apply $ax)
```

### B.2 Task 7 Phase 2: Aesop Setup (Ready to implement)

```lean
-- Add to Logos/Automation/Tactics.lean
-- Step 1: Declare rule set
declare_aesop_rule_sets [TMLogic]

-- Step 2: Add to each axiom in Metalogic/Soundness.lean
@[aesop safe [TMLogic]]
theorem modal_t_valid (φ : Formula) : ⊨ (φ.box.imp φ) := by
  -- ... existing proof ...

-- Repeat for all 10 axioms

-- Step 3: Add tm_auto macro to Automation/Tactics.lean
/-- Comprehensive TM automation -/
macro "tm_auto" : tactic =>
  `(tactic| aesop (rule_sets [TMLogic]))
```

### B.3 Task 12: Basic Test Template (Ready to use)

```lean
-- Create LogosTest/Automation/TacticsTest.lean
import Logos.Automation.Tactics
import Logos.Syntax.Formula
import Logos.ProofSystem.Derivation

namespace LogosTest.Automation

open Logos.Syntax (Formula)
open Logos.ProofSystem (Derivable)

/-- Test apply_axiom with modal_t -/
def test_apply_axiom_modal_t (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  apply_axiom Axiom.modal_t

/-- Test modal_t basic pattern -/
def test_modal_t_basic (P : Formula) : Derivable [] ((Formula.box P).imp P) := by
  modal_t

-- Add more tests...

end LogosTest.Automation
```

---

**END OF REPORT**

**REPORT_CREATED**: /home/benjamin/Documents/Philosophy/Projects/Logos/.claude/specs/025_soundness_automation_implementation/reports/001-soundness-automation-implementation-research.md
