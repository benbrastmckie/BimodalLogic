# Research Report: Countermodel Semantic Correctness (Task 240)

## Session
- **Session ID**: sess_1780346226_d5e721
- **Date**: 2026-06-01
- **Task**: Replace vacuous `branchTruthLemma` with genuine truth lemma; extend `SimpleCountermodel` to `SemanticCountermodel`

---

## 1. Current State Analysis

### 1.1 The Vacuous branchTruthLemma

Located at `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean:149`:

```lean
theorem branchTruthLemma (b : Branch) (_hSat : findUnexpanded b = none)
    (fc : FrameClass := .Base) (_hOpen : findClosure b fc = none) :
    ∀ sf ∈ b, True := by
  intro _ _
  trivial
```

This theorem states `∀ sf ∈ b, True` -- a tautology with zero semantic content. The docstring describes what the real theorem should say:

1. If `T(phi)` is in branch, then `phi` is true in the extracted model
2. If `F(phi)` is in branch, then `phi` is false in the extracted model

### 1.2 SimpleCountermodel

```lean
structure SimpleCountermodel where
  trueAtoms : List Atom
  falseAtoms : List Atom
  formula : Formula
```

This only records which atoms are true/false. It has no world states, no temporal structure, no task relation, and no valuation function compatible with the semantic machinery in `Semantics/`.

### 1.3 Gap Summary

The current code extracts atom truth values from saturated branches but provides no formal connection to the semantic model (`TaskFrame`, `TaskModel`, `WorldHistory`, `truth_at`). The `branchTruthLemma` is vacuous and the `SimpleCountermodel` lacks the structure needed for semantic correctness.

---

## 2. Codebase Architecture

### 2.1 Semantic Types (Theories/Bimodal/Semantics/)

| Type | Location | Purpose |
|------|----------|---------|
| `TaskFrame D` | TaskFrame.lean | Frame with WorldState type, task_rel, nullity/compositionality/converse |
| `TaskModel F` | TaskModel.lean | Frame + valuation (WorldState -> Atom -> Prop) |
| `WorldHistory F` | WorldHistory.lean | Domain predicate, convex, states function, respects_task |
| `truth_at M Omega tau t phi` | Truth.lean | Recursive truth evaluation at model-history-time |
| `valid phi` | Validity.lean | Quantifies over all D, F, M, Omega, tau, t |

### 2.2 Tableau Types (Theories/Bimodal/Metalogic/Decidability/)

| Type | Location | Purpose |
|------|----------|---------|
| `SignedFormula` | SignedFormula.lean | Sign (.pos/.neg) + Formula + Label (world, time) |
| `Branch` | SignedFormula.lean | `List SignedFormula` |
| `Label` | SignedFormula.lean | WorldIndex (Nat) x TimeIndex (Nat) |
| `findUnexpanded b` | Tableau.lean | Returns `none` when branch is saturated |
| `findClosure b fc` | Closure.lean | Returns `none` when branch is open (no contradiction) |
| `ExpandedTableau` | Saturation.lean | `allClosed` or `hasOpen openBranch hSaturated` |
| `TimeOrdering` | SignedFormula.lean | Abstract temporal ordering constraints |

### 2.3 Key Observations

1. **Labels carry world and time indices**: Each `SignedFormula` has a `Label` with `.world : WorldIndex` and `.time : TimeIndex`. A saturated branch may contain formulas at multiple worlds and times.

2. **TimeOrdering tracks abstract temporal order**: The `TimeOrdering` structure maintains constraints like `(t1, t2)` meaning `t1 < t2`. This is crucial for building the temporal order in the countermodel.

3. **S5 modal logic**: All worlds are mutually accessible (universal equivalence class). The box rule propagates to all known worlds.

4. **Strict temporal semantics**: G and H use strict `<` (not `<=`). Until uses strict witness (`s > t`) with open guard `(t, s)`.

5. **The FMP module has a parallel MCS-based truth definition**: `mcsTruth` defines truth as set membership in `ClosureMCSBundle`. Our branch-truth lemma is analogous but works directly with tableau branches.

---

## 3. SemanticCountermodel Design

### 3.1 Structure

The `SemanticCountermodel` must package a full semantic model that the `truth_at` function can evaluate against. Given a saturated open branch `b`, we construct:

```lean
structure SemanticCountermodel where
  /-- The temporal duration type (Int for discrete countermodels) -/
  D : Type  -- Int
  /-- The task frame -/
  frame : TaskFrame Int
  /-- The task model (frame + valuation) -/
  model : TaskModel frame
  /-- The set of admissible histories -/
  Omega : Set (WorldHistory frame)
  /-- A distinguished history -/
  history : WorldHistory frame
  /-- The distinguished history is in Omega -/
  history_mem : history ∈ Omega
  /-- The evaluation time -/
  time : Int
  /-- The formula being refuted -/
  formula : Formula
```

### 3.2 Construction from Branch

Given a saturated open branch `b` (with `findUnexpanded b = none` and `findClosure b fc = none`), we build:

**World States**: Extract distinct world indices from the branch: `b.knownWorlds`. Each world index `w` becomes a world state.

**Time Domain**: Extract distinct time indices from the branch: `b.knownTimes`. Each time index becomes a point in the temporal order. The `TimeOrdering` constraints give the abstract ordering.

**Temporal Ordering**: The `TimeOrdering` stored during branch expansion records explicit `(t1, t2)` pairs meaning `t1 < t2`. We can embed time indices into `Int` respecting this ordering. A simple approach: use the time indices directly as integers, defining a total order consistent with the TimeOrdering constraints.

**Task Relation**: Since TM uses S5 for the modal component, all worlds are mutually accessible. For the temporal component, `task_rel w d u` should hold when the world transition is consistent with the branch. The simplest approach: define WorldState as (WorldIndex x TimeIndex)-indexed states, with the task relation matching the branch's temporal structure.

**Valuation**: For each world state and atom, check if `T(atom)` is on the branch at the corresponding label. If `T(atom)` at label `(w, t)` is in the branch, then `valuation(state_at(w,t), atom) = True`.

### 3.3 Design Choice: Int-Based vs Polymorphic

The semantics are polymorphic over temporal type `D`. For countermodels from finite tableau branches, `Int` is the natural choice because:
- Time indices are natural numbers (embedded in Int)
- The temporal ordering is a finite partial order on these indices
- Int satisfies all required typeclasses (`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`)

We use `Int` as the concrete temporal type for countermodel construction.

### 3.4 Handling the TimeOrdering Gap

**Problem**: The `branchTruthLemma` needs the `TimeOrdering` to determine which time indices are "future" or "past" of each other. However, `findUnexpanded` and `expandBranchWithFuel` thread the `TimeOrdering` through computation but the `ExpandedTableau.hasOpen` constructor only stores the branch, not the ordering.

**Solution Options**:
1. **Extend ExpandedTableau**: Add `TimeOrdering` to the `hasOpen` constructor
2. **Reconstruct from branch**: Infer temporal ordering from the signed formulas (e.g., if T(GA) at time t and T(A) at time t', then t' is future of t)
3. **Use Nat ordering**: Since time indices are Nat values allocated sequentially, use the allocation pattern to infer ordering

**Recommended**: Option 1 (extend ExpandedTableau with TimeOrdering). This is the cleanest approach and requires a small refactor. The TimeOrdering is already computed during expansion; we just need to preserve it.

---

## 4. Truth Lemma Proof Structure

### 4.1 Statement

The genuine truth lemma has two parts:

```lean
theorem branchTruthLemma_pos (b : Branch) (hSat : findUnexpanded b = none)
    (hOpen : findClosure b fc = none) (phi : Formula) (l : Label)
    (h : SignedFormula.pos phi l ∈ b) :
    truth_at M Omega tau l.time phi

theorem branchTruthLemma_neg (b : Branch) (hSat : findUnexpanded b = none)
    (hOpen : findClosure b fc = none) (phi : Formula) (l : Label)
    (h : SignedFormula.neg phi l ∈ b) :
    ¬ truth_at M Omega tau l.time phi
```

where `M`, `Omega`, `tau` are the extracted semantic model, history set, and history from `b`.

### 4.2 Proof by Induction on Formula Structure

The proof proceeds by induction on `phi`:

**Base: `phi = atom p`**
- **Pos**: `T(p)` at `(w,t)` in branch. By construction, `valuation(state_at(w,t), p) = True`. So `truth_at M Omega tau t (atom p)` holds.
- **Neg**: `F(p)` at `(w,t)` in branch. Since branch is open (no contradiction), we cannot have both `T(p)` and `F(p)` at the same label. By construction, `valuation` assigns False. So `¬ truth_at M Omega tau t (atom p)`.

**Base: `phi = bot`**
- **Pos**: `T(bot)` at `(w,t)` in branch. But this means `findClosure b` would return `botPos`, contradicting `hOpen`. Vacuously true.
- **Neg**: `F(bot)` at `(w,t)` in branch. Need `¬ truth_at M Omega tau t bot` which is `¬ False` -- trivially true.

**Inductive: `phi = psi -> chi` (Implication)**
- **Pos case** (`T(psi -> chi)` in branch): Since the branch is saturated, the impPos rule was applied, creating two sub-branches: one with `F(psi)` and one with `T(chi)`. In the open branch, at least one of these must hold. By IH, either `¬ truth_at ... psi` or `truth_at ... chi`. Either way, the implication holds.
- **Neg case** (`F(psi -> chi)` in branch): Since the branch is saturated, the impNeg rule was applied, so `T(psi)` and `F(chi)` are both in the branch. By IH, `truth_at ... psi` and `¬ truth_at ... chi`, so the implication fails.

**Inductive: `phi = box psi` (Modal Necessity)**
- **Pos case** (`T(box psi)` at `(w,t)` in branch): Since branch is saturated, the boxPos rule propagated `T(psi)` to all known worlds at time `t`. By construction, Omega contains exactly the histories corresponding to known worlds. By IH, `truth_at M Omega sigma t psi` for all sigma in Omega.
- **Neg case** (`F(box psi)` at `(w,t)` in branch): Since branch is saturated, boxNeg created a fresh world `w'` with `F(psi)` at `(w', t)`. By IH, there exists `sigma ∈ Omega` where `¬ truth_at M Omega sigma t psi`, so box fails.

**Inductive: `phi = untl event guard` (Until)**
- **Pos case** (`T(U(event, guard))` at `(w,t)` in branch): Since branch is saturated, untlPos created two sub-branches: event-witness at fresh time `t'` or guard+continue. In the open branch, one path succeeded. By IH, either the event was witnessed (giving the existential witness for Until semantics) or the guard held and Until continued (eventually terminating by blocking/saturation). This is the most complex case and requires careful tracking of the temporal witness chain.
- **Neg case** (`F(U(event, guard))` at `(w,t)` in branch): Since branch is saturated, untlNeg decomposed at all known future times. For each future time `t'`, either `F(event)` or `F(guard) + F(U(event,guard))` at `t'`. By IH at each future time, the Until condition fails.

**Inductive: `phi = snce event guard` (Since)**
- Symmetric to Until, with past times instead of future times.

### 4.3 Key Saturation Properties Needed

The truth lemma proof relies on saturation properties of the form:

```lean
-- If T(A -> B) is saturated in branch, then F(A) or T(B) is in branch
theorem sat_impPos (b : Branch) (hSat : findUnexpanded b = none) (l : Label)
    (h : SignedFormula.pos (Formula.imp A B) l ∈ b) :
    SignedFormula.neg A l ∈ b ∨ SignedFormula.pos B l ∈ b

-- If F(A -> B) is saturated in branch, then T(A) and F(B) are in branch
theorem sat_impNeg (b : Branch) (hSat : findUnexpanded b = none) (l : Label)
    (h : SignedFormula.neg (Formula.imp A B) l ∈ b) :
    SignedFormula.pos A l ∈ b ∧ SignedFormula.neg B l ∈ b

-- If T(box A) is saturated and world w exists, then T(A) at (w, t) is in branch
theorem sat_boxPos (b : Branch) (hSat : findUnexpanded b = none) (l : Label)
    (h : SignedFormula.pos (Formula.box A) l ∈ b) (w : WorldIndex)
    (hw : w ∈ b.knownWorlds) :
    SignedFormula.pos A { world := w, time := l.time } ∈ b
```

These saturation lemmas are straightforward consequences of `findUnexpanded b = none`:
- If a formula is in the branch and a rule applies to it, then `findUnexpanded` would return `some sf`, contradicting `hSat`.
- Therefore, if a formula is unexpandable (no rule applies), its consequences are already in the branch.
- The key technical challenge is showing that `isExpanded sf b = true` implies the rule's conclusions are present.

### 4.4 Open Questions and Complications

1. **Branching rules (impPos, andNeg, orPos, untlPos, sncePos)**: These create multiple sub-branches. In a saturated branch, the formula was expanded and the branch we're looking at is one of the resulting branches. We need to know which branch we're on, which is determined by which of the rule's conclusions are present.

   **Resolution**: For branching rules, `isExpanded` checks that the rule is `notApplicable` for the formula. For `impPos`, the rule applies to `T(A -> B)`. After expansion, `T(A -> B)` is removed from the branch (linear expansion removes the source). So if `T(A -> B)` is still in the branch and the branch is saturated, it means we're in a branch where the impPos result's consequences are already present. The key insight: in the current implementation, branching rules remove the source formula. If the source formula is still present in a saturated branch, it means no rule applies to it (either already expanded or the rule result is `notApplicable`).

   **Complication**: The `expandOnce` function removes consumed formulas (`let remaining := b.filter (· != sf)`). So after expansion, `T(A -> B)` is no longer in the branch. But the branch we receive in `ExpandedTableau.hasOpen` is the final saturated branch, which may no longer contain the original compound formulas.

   **Key realization**: The truth lemma must work with the final saturated branch, which contains the leaves after all expansions. Compound formulas like `T(A -> B)` are consumed during expansion and replaced by their conclusions. So the induction is on the formula structure of what's in the final branch, not the original formula.

   **BUT**: Persistent rules (boxPos, allFuturePos, etc.) keep the source formula. And the branch truth lemma should cover ALL formulas in the branch, not just atomic ones. So we need to handle both consumed and persistent formulas.

   **Refined approach**: The truth lemma proves that the branch describes a consistent model. For the saturated branch, compound formulas remaining are those from persistent rules (universal modals/temporals). The key insight is that saturation ensures all consequences of these persistent formulas are already present.

2. **TimeOrdering availability**: As noted above, the TimeOrdering is not preserved in `ExpandedTableau.hasOpen`. We need to either extend the datatype or reconstruct the ordering.

3. **Universe level issues**: The semantics uses `Type*` for world states and temporal types. The countermodel construction uses concrete `Nat` indices. This should work fine since `Nat : Type` and `Int : Type`.

---

## 5. Recommended Implementation Approach

### 5.1 Phase Structure

**Phase 1: Infrastructure** -- Extend types to support semantic countermodels
- Extend `ExpandedTableau.hasOpen` to carry `TimeOrdering`
- Thread `TimeOrdering` through `expandBranchesWithFuel`, `buildTableau`
- Define `SemanticCountermodel` structure

**Phase 2: Model Extraction** -- Build semantic model from saturated branch
- `extractWorldStates : Branch -> List WorldIndex` (already exists as `knownWorlds`)
- `extractTimeIndices : Branch -> List TimeIndex` (already exists as `knownTimes`)
- `extractTemporalOrder : TimeOrdering -> TimeIndex -> TimeIndex -> Prop`
- `extractValuation : Branch -> (WorldIndex x TimeIndex) -> Atom -> Prop`
- `buildSemanticCountermodel : Branch -> TimeOrdering -> Formula -> SemanticCountermodel`

**Phase 3: Saturation Lemmas** -- Prove that saturation implies specific structural properties
- One lemma per tableau rule: if the rule's source is in a saturated branch, then the rule's conclusions are also present
- These are the workhorse lemmas for the truth lemma

**Phase 4: Truth Lemma** -- Prove the truth lemma by induction on formula structure
- Base cases: atom, bot
- Propositional cases: imp (handles neg, and, or as derived)
- Modal case: box (handles diamond as derived)
- Temporal cases: untl, snce (handles G, H, F, P as derived)

**Phase 5: Integration** -- Connect to decision procedure
- Replace `SimpleCountermodel` usage in `DecisionResult` with `SemanticCountermodel`
- Update `findCountermodel` to produce `SemanticCountermodel`
- Prove countermodel correctness: extracted model falsifies the input formula

### 5.2 Key Technical Decisions

1. **Concrete temporal type**: Use `Int` for countermodel construction. This avoids polymorphic universe complications.

2. **WorldState representation**: Use `Fin n` or a custom finite type indexed by the known world-time pairs on the branch.

3. **WorldHistory construction**: Build a single canonical history for each world index. The history's domain covers exactly the time indices present on the branch for that world.

4. **Omega construction**: The set of admissible histories is exactly the set of canonical histories for each world index.

5. **Task relation**: Since S5, all world transitions are allowed. Define `task_rel w d u` as `True` for a trivial frame, or as `d != 0 ∨ w = u` for the nat_frame pattern. The simplest approach is a task frame where the WorldState is a function from time to Atom -> Prop (the valuation is baked into the state).

### 5.3 Simplification: Propositional-First Approach

For the initial implementation, consider proving the truth lemma for the propositional fragment first (no box, no untl, no snce), then extending to modal, then temporal. This allows incremental progress:

- **Propositional**: atom, bot, imp -- requires only contradiction/openness lemmas
- **Modal**: box -- requires S5 propagation saturation lemmas
- **Temporal**: untl, snce, all_future, all_past, some_future, some_past -- requires TimeOrdering and temporal saturation lemmas

---

## 6. Risk Assessment

### 6.1 High Risk: Temporal Until/Since Cases

The Until truth lemma case requires showing that a finite saturated branch with T(U(event, guard)) at time t has either:
- T(event) at some future time t' (direct witness), or
- An infinite chain of guard-holding times that is blocked

With blocking, the branch is finite. The truth lemma must connect the finite branch structure to the semantic Until condition (which existentially quantifies over a real time domain). This requires showing that the branch's time points are sufficient witnesses.

**Mitigation**: The blocking strategy guarantees that if T(U(event, guard)) is in the branch, either the event was witnessed or the branch would have continued expanding (contradicting saturation). This is where the three `sorry` theorems in Saturation.lean (`subformula_property`, `blocking_terminates`, `blocking_sound`) become relevant.

### 6.2 Medium Risk: TimeOrdering Threading

Extending `ExpandedTableau` to carry `TimeOrdering` requires updating all call sites. The refactor is mechanical but touches: `buildTableau`, `buildTableauAuto`, `extractCountermodelFromTableau`, `findCountermodel`, `DecisionResult`, and downstream consumers in `DataExport`, `DatasetGenerator`, `FormulaMutator`, `EnrichedCountermodel`.

**Mitigation**: The `TimeOrdering` can be added as an optional field or reconstructed from the branch for backward compatibility.

### 6.3 Medium Risk: WorldHistory Construction

Building a valid `WorldHistory` requires proving convexity and respects_task. For a finite set of time points, the domain predicate needs to be convex on the relevant range, and the task relation needs to hold between consecutive states.

**Mitigation**: Use the `trivial_frame` approach where `task_rel` is always `True`, making respects_task trivial. This suffices for countermodel construction since we only need to show the formula is false in *some* model, not that the model is realistic.

### 6.4 Low Risk: Sorry Dependencies

The existing `sorry` in `subformula_property`, `blocking_terminates`, and `blocking_sound` (Saturation.lean) are about blocking correctness, which is tangential to the truth lemma. The truth lemma assumes we have a saturated open branch and proves properties about it -- it doesn't need to know how the branch was produced.

---

## 7. Existing Patterns to Reuse

1. **FMP TruthPreservation module**: The `mcsTruth` definition and `filteredMcsTruth` pattern show how to define truth as set membership and lift it through quotient constructions. Our branch-truth is analogous: truth as signed-formula membership.

2. **EnrichedCountermodel**: Already extracts the full branch, modal formulas, and temporal formulas. The `SemanticCountermodel` extends this with actual semantic structure.

3. **TaskFrame examples**: `trivial_frame` and `nat_frame` provide templates for constructing task frames with simple properties.

4. **WorldHistory.universal**: Shows how to construct a world history with full domain where the task relation is trivially satisfied.

5. **Closure monotonicity lemmas**: `closed_extend_closed`, `hasNeg_mono`, etc. show the pattern for proving structural properties of branches.

---

## 8. Dependencies and Blockers

- **No blocking dependencies**: Task 240 has no listed dependencies in state.json. Tasks 237 (blocking) and 238 (frame class gating) are completed.
- **Downstream dependents**: Task 164 (tableau correctness) depends on 240. Tasks 241 (DatasetGenerator) and 242 (proof step pipeline) depend on 240 via 164.
- **Sorry dependencies**: The three `sorry` theorems in Saturation.lean are not blocking for this task (they concern blocking correctness, not branch truth).
