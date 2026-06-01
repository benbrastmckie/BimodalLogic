# Task 240: Countermodel Semantic Correctness — Research Report

Session: sess_1780346171_c40116

## Current State

### The Vacuous branchTruthLemma

**File**: `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean`, lines 149-153

```lean
theorem branchTruthLemma (b : Branch) (_hSat : findUnexpanded b = none)
    (fc : FrameClass := .Base) (_hOpen : findClosure b fc = none) :
    ∀ sf ∈ b, True := by
  intro _ _
  trivial
```

This is a placeholder. The conclusion `∀ sf ∈ b, True` says nothing about the relationship between signed formulas in the branch and truth in any model. The task is to replace this with a genuine truth lemma connecting branch membership to semantic truth.

### SimpleCountermodel (current)

**File**: `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean`, lines 47-54

```lean
structure SimpleCountermodel where
  trueAtoms : List Atom
  falseAtoms : List Atom
  formula : Formula
  deriving Repr
```

This only tracks which atoms are true/false. It has no world states, no time domain, no temporal ordering, and no valuation — making it impossible to evaluate truth of modal/temporal formulas. The `extractTrueAtoms` and `extractFalseAtoms` functions (lines 64-78) only look at atoms at any label, collapsing all worlds and times.

### EnrichedCountermodel (partial extension)

**File**: `Theories/Bimodal/Automation/EnrichedCountermodel.lean`

The `EnrichedCountermodel` structure stores the full branch content, modal formulas, and temporal formulas, but purely for JSON serialization and training data export. It has no semantic model and no truth lemma.

## Codebase Analysis

### Core Type Hierarchy

1. **Formula** (`Theories/Bimodal/Syntax/Formula.lean`): 6 constructors — `atom`, `bot`, `imp`, `box`, `untl`, `snce`. Derived operators: `neg`, `top`, `some_future` (= `untl phi top`), `some_past` (= `snce phi top`), `all_future` (= `neg (some_future (neg phi))`), `all_past` (= `neg (some_past (neg phi))`).

2. **SignedFormula** (`Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean`, line 155): Structure with `sign : Sign`, `formula : Formula`, `label : Label`. Labels have `world : WorldIndex` (Nat) and `time : TimeIndex` (Nat).

3. **Branch** (line 233): `abbrev Branch := List SignedFormula`.

4. **TimeOrdering** (line 638): Tracks abstract temporal constraints as `List (TimeIndex × TimeIndex)` where `(a, b)` means `a < b`.

5. **TaskFrame** (`Theories/Bimodal/Semantics/TaskFrame.lean`, line 93): Parameterized by duration type `D` with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`. Has `WorldState : Type`, `task_rel : WorldState → D → WorldState → Prop`, plus `nullity_identity`, `forward_comp`, and `converse` axioms.

6. **WorldHistory** (`Theories/Bimodal/Semantics/WorldHistory.lean`, line 69): Has `domain : D → Prop` (convex), `states : (t : D) → domain t → F.WorldState`, and `respects_task`.

7. **TaskModel** (`Theories/Bimodal/Semantics/TaskModel.lean`, line 43): Has `valuation : F.WorldState → Atom → Prop`.

8. **truth_at** (`Theories/Bimodal/Semantics/Truth.lean`, line 122): `truth_at M Omega τ t : Formula → Prop` — evaluates truth of a formula at model `M`, history set `Omega`, history `τ`, time `t`.

### Saturation and Expansion

- **findUnexpanded** (`Tableau.lean`, line 943): Returns `some sf` if an unexpanded formula exists, `none` if branch is saturated.
- **isExpanded** (`Tableau.lean`, line 934): A signed formula is expanded when no `findApplicableRule` returns a match.
- **findClosure** (`Closure.lean`, line 116): Checks `botPos`, `contradiction`, and `axiomNeg` — returns `none` for open branches.
- **ExpandedTableau** (`Saturation.lean`, line 43): Either `allClosed` or `hasOpen openBranch (saturated : findUnexpanded openBranch = none)`.

### Existing Truth Lemma Patterns

The codebase has two existing truth lemma proofs for different purposes:

1. **BXCanonical TruthLemma** (`Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean`): Proves MCS membership corresponds to truth in a canonical model. Uses structural induction on formulas. Cases: atom (by canonical valuation), bot (trivial), imp (MCS implication property), box (modal witness construction), G/H (temporal forward/backward), U/S (eventuality resolution).

2. **FMP TruthPreservation** (`Theories/Bimodal/Metalogic/Decidability/FMP/TruthPreservation.lean`): Infrastructure for filtration lemma. Defines `mcsTruth` as MCS membership, with basic bot/negation lemmas. Incomplete for all formula cases.

Both follow the same fundamental pattern: define "truth" as membership in a maximal consistent set, then prove by structural induction on formulas that membership = semantic truth.

### Labeled Tableau Structure

The tableau uses labeled signed formulas. Each `SignedFormula` carries a `Label` with `world : WorldIndex` and `time : TimeIndex`. The tableau rules:

- **Modal rules** (S5): `boxPos` propagates `T(□A)` to all known worlds. `boxNeg` creates fresh witness world with `F(A)`. S5 = universal accessibility.
- **Temporal rules**: `allFuturePos`/`allPastPos` propagate to known future/past times. `allFutureNeg`/`allPastNeg` create fresh witness times. `untlPos`/`sncePos` branch: event-witness OR guard+continue. `untlNeg`/`snceNeg` use Reynolds co-decomposition.
- **TimeOrdering** tracks `(a, b)` pairs meaning `a < b` in abstract temporal order.
- **Subset blocking** prevents infinite temporal chains via `isSubsetBlocked`.

## Semantic Requirements

The `SemanticCountermodel` must bridge the gap between the tableau's labeled branch and the project's existing semantic types (`TaskFrame`, `WorldHistory`, `TaskModel`, `truth_at`).

### World States

From a saturated open branch, the set of world indices appearing in labels defines the world states:

```
WorldState = { w : WorldIndex | w ∈ b.knownWorlds }
```

Since `Branch.knownWorlds` returns `List WorldIndex`, this is a finite set of `Nat` values. We can use `Fin n` or a subtype `{ w : Nat // w ∈ b.knownWorlds }`, but for simplicity, using `Nat` directly (with the worlds being a subset) is practical.

### Time Domain

The time domain comes from the `TimeOrdering` constraints on the branch. The `TimeIndex` values (natural numbers) together with the ordering constraints `(a, b)` form a finite partial order. For a countermodel, we need:

- A type `D` with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`
- A mapping from `TimeIndex` to `D`

**Option A: Use `Int` as time domain.** Topologically sort the `TimeOrdering` constraints and assign integers. This satisfies all typeclass requirements and is the simplest approach.

**Option B: Use `Rat` as time domain.** Needed only if dense frame countermodels are required.

For `FrameClass.Base`, `Int` suffices.

### Temporal Ordering

The `TimeOrdering` tracks abstract temporal constraints. We need to:

1. Extract the transitive closure of the ordering.
2. Assign concrete `Int` values to `TimeIndex` values respecting the ordering.
3. Prove the assignment is consistent (if `(a, b)` then `assignment a < assignment b`).

### Valuation

The valuation is extracted from the branch content:

```
valuation w p := branch.hasPosAt (Formula.atom p) { world := w, time := t }
```

However, for a TaskModel valuation `F.WorldState → Atom → Prop`, we need `valuation` to be world-state-level, not (world, time)-level. In the existing semantics, atoms are evaluated at world states via the valuation, and world histories map times to world states.

**Key insight**: In the S5 component, all worlds are mutually accessible. The `box` modality quantifies over all world histories. For the extracted countermodel, each (world, time) pair defines a world state, and the valuation at that state is determined by which atoms appear positively at that label.

### Proposed SemanticCountermodel Structure

```lean
structure SemanticCountermodel where
  /-- The formula being refuted -/
  formula : Formula
  /-- The saturated open branch -/
  branch : Branch
  /-- World indices present -/
  worlds : List WorldIndex
  /-- Time indices present -/
  times : List TimeIndex
  /-- Temporal ordering constraints from tableau -/
  timeOrdering : TimeOrdering
  /-- Assignment of time indices to integer positions -/
  timeAssignment : TimeIndex → Int
  /-- Assignment respects ordering -/
  timeAssignment_mono : ∀ a b, (a, b) ∈ timeOrdering.constraints →
    timeAssignment a < timeAssignment b
  /-- Atom valuation at each (world, time) pair -/
  atomValuation : WorldIndex → TimeIndex → Atom → Bool
  /-- Valuation matches branch content -/
  valuation_pos : ∀ w t p, branch.hasPosAt (Formula.atom p) ⟨w, t⟩ →
    atomValuation w t p = true
  valuation_neg : ∀ w t p, branch.hasNegAt (Formula.atom p) ⟨w, t⟩ →
    atomValuation w t p = false
```

**Alternative (simpler, avoiding TaskFrame)**: Since the truth lemma is about the relationship between branch membership and a valuation, we can define an intermediate "branch model" that directly interprets formulas without constructing a full `TaskFrame`/`WorldHistory` pair. This avoids universe level issues (mentioned in the existing code comments on line 27 of CountermodelExtraction.lean).

## Truth Lemma Strategy

### Statement

```lean
theorem branchTruthLemma (b : Branch) (hSat : findUnexpanded b = none)
    (fc : FrameClass := .Base) (hOpen : findClosure b fc = none)
    (cm : SemanticCountermodel) (hCm : cm.branch = b) :
    ∀ sf ∈ b,
      (sf.sign = .pos → truthInModel cm sf.label sf.formula) ∧
      (sf.sign = .neg → ¬ truthInModel cm sf.label sf.formula)
```

Or equivalently with a single predicate:

```lean
    ∀ sf ∈ b, signedTruthInModel cm sf
```

where `signedTruthInModel cm sf` means: if `sf.sign = .pos` then `sf.formula` is true in the model at `sf.label`, and if `sf.sign = .neg` then `sf.formula` is false.

### Proof by Induction on Formula Structure

The proof proceeds by well-founded induction on `sf.formula.complexity`. For each formula case:

**Case: atom p**
- If `T(p)` at `(w, t)` is in the branch, then `atomValuation w t p = true` by construction of the countermodel.
- If `F(p)` at `(w, t)` is in the branch, then `atomValuation w t p = false` by construction (open branch has no contradiction, so both cannot hold simultaneously).

**Case: bot**
- `T(⊥)` cannot be in an open branch (findClosure detects `botPos`).
- `F(⊥)` is vacuously correct (⊥ is indeed false in any model).

**Case: imp ψ χ**
- `T(ψ → χ)`: Saturation means `impPos` was applied, producing either `F(ψ)` or `T(χ)` (branching rule). But wait — this is a branching rule, so we don't know which branch we're on. We need to be more careful.

  **Key subtlety**: For branching rules, saturation means the rule was applied, which produced branches. The branch we're examining is one of those branches (or a descendant). If `T(ψ → χ)` is in a saturated branch, then either `F(ψ)` is in the branch or `T(χ)` is in the branch (because the `impPos` rule was applied and removed the source formula, extending with one of the two options).

  Actually, the expansion model here uses `expandOnce` which for branching rules creates `split` results and removes the source formula. So if `T(ψ → χ)` is still in the branch and the branch is saturated, then `isExpanded` returned true for it. Looking at `isExpanded` (line 934), it checks `findApplicableRule` — for `impPos`, this always applies to `T(imp ψ χ)`. So `T(ψ → χ)` should NOT be in a saturated branch (it would have been expanded and removed).

  Wait — let me re-examine. The `expandOnce` function (line 965) removes `sf` from the remaining branch via `b.filter (· != sf)` for linear/branching results. So after expansion, `T(ψ → χ)` is removed. Therefore, in a saturated branch, compound formulas should NOT appear as unexpanded items.

  Actually, the complication is that `isExpanded` checks `findApplicableRule sf branch`, which for persistent rules returns `notApplicable` if all propagations are already present. But for non-persistent rules like `impPos`, it always returns applicable. So compound propositional formulas should indeed be removed during expansion.

  **Revised understanding**: In a saturated branch, the only formulas present are:
  1. Atoms (positive or negative) — truly atomic
  2. Modal/temporal formulas that are "persistent" and have been fully propagated
  3. Formulas produced by expansion but not themselves expandable

  This means `T(ψ → χ)` would have been consumed by `impPos`. The branch should contain the results of its expansion. So the truth lemma's induction step for `imp` relies on: the branch doesn't contain unexpanded `T(ψ → χ)` directly; rather, it contains either `F(ψ)` or `T(χ)`.

  **But wait**: The truth lemma is supposed to apply to ALL `sf ∈ b`, and the branch may contain formulas that are "expanded" (persistent and fully propagated). For `T(□A)`, the formula stays in the branch (persistent rule). So the truth lemma needs to handle persistent formulas.

  For the truth lemma, we need: for `T(□A)` at `(w, t)` in the branch, show `□A` is true at `(w, t)` in the model. This means `A` is true at all worlds at time `t`. Saturation of `boxPos` means `T(A)` has been propagated to all known worlds. By induction, `A` is true at all known worlds, and the model only has worlds from `knownWorlds`.

**Case: box ψ**
- `T(□ψ)`: By saturation (`boxPos` applied), `T(ψ)` is at all known worlds at the same time. By IH, `ψ` is true at all worlds. Since the model only contains known worlds, `□ψ` is true.
- `F(□ψ)`: By saturation (`boxNeg` applied), there exists a witness world with `F(ψ)`. By IH, `ψ` is false at that world. So `□ψ` is false.

**Case: untl (Until)**
- `T(U(event, guard))`: This is a consumable branching rule. After expansion, the branch contains either the event-witness branch or the guard+continue branch. The induction follows the branch structure.
- `F(U(event, guard))`: Reynolds co-decomposition was applied at known future times (persistent). At each future time, either `F(event)` or `F(guard) ∧ F(U(event, guard))` at that time.

**Case: snce (Since)**: Mirror of Until.

**Case: all_future / all_past / some_future / some_past**: These are `def` abbreviations. They reduce to combinations of `untl`, `snce`, `imp`, `neg`, and `top`. However, the tableau rules handle them as distinct patterns (matching `all_future`, `some_future`, etc.). The truth lemma proof needs to handle these as they appear in the branch.

### Two-Layer Approach

A cleaner approach separates the concerns:

**Layer 1: Branch Model** — Define a simple evaluation function directly on the branch:

```lean
def branchTruth (b : Branch) (w : WorldIndex) (t : TimeIndex) : Formula → Prop
```

This function is defined by:
- `branchTruth b w t (atom p) := b.hasPosAt (atom p) ⟨w, t⟩`
- Other cases defined recursively using the branch's world/time structure

**Layer 2: Correspondence** — Prove that for saturated open branches, `branchTruth` corresponds to the branch content:

```lean
∀ sf ∈ b, (sf.sign = .pos → branchTruth b sf.label.world sf.label.time sf.formula) ∧
          (sf.sign = .neg → ¬ branchTruth b sf.label.world sf.label.time sf.formula)
```

Then optionally, a **Layer 3** connects `branchTruth` to the full `truth_at` semantics.

## Key Challenges

### 1. Handling Persistent Formulas

Persistent formulas (e.g., `T(□A)`, `F(◇A)`, `T(GA)`, `F(FA)`) remain in the branch after expansion. They are "expanded" in the sense that `isExpanded` returns true (all propagations are present), but they are still in the branch. The truth lemma must handle these: show that the semantic meaning of the persistent formula is entailed by the propagated instances.

### 2. TimeOrdering Recovery

The `expandBranchWithFuel` function threads `TimeOrdering` internally but the final `ExpandedTableau.hasOpen` only stores the branch, not the time ordering. The `SemanticCountermodel` needs the time ordering to construct the temporal domain. **This is a significant gap**: the current `ExpandedTableau` type discards the `TimeOrdering`.

**Solutions**:
(a) Modify `ExpandedTableau.hasOpen` to carry the `TimeOrdering` alongside the branch.
(b) Reconstruct the time ordering from the branch labels (possible but fragile).
(c) Define the countermodel's temporal ordering purely from branch membership properties (e.g., if `T(GA)` at time `t` and `T(A)` at time `t'`, then `t < t'` in the intended ordering).

Option (a) is cleanest and should be done as a prerequisite.

### 3. Branching Rule Residues

After a branching rule like `impPos` is applied, the source formula `T(ψ → χ)` is removed from the branch. However, the branch we're examining is just one of the branches from the split. We need to reason about which formulas ended up on this particular branch. The saturation property (`findUnexpanded b = none`) guarantees all expandable formulas have been processed, but we need to track what was added.

### 4. Universe Level Issues

The existing code comments (CountermodelExtraction.lean, line 27) mention: "This avoids universe level issues with the full semantic machinery." The full `TaskFrame`/`WorldHistory`/`TaskModel` stack is parameterized over an ordered additive group `D`, which introduces universe polymorphism. Constructing a `TaskFrame Int` with the branch's world states and a `WorldHistory` for each world requires careful handling of the domain predicate and convexity proof.

### 5. Modal-Temporal Interaction

The `boxTemporal` rule derives `T(GA)` and `T(HA)` from `T(□A)`. The truth lemma for `box` needs to account for this: in the model, `□A` being true implies `A` is true at all worlds AND all times (via the perpetuity property). This is a property of the S5+linear temporal combination.

### 6. Subset Blocking and Open Guards

Subset blocking can cause a branch to be declared "saturated" before all until/since eventualities are resolved. The truth lemma needs to account for blocked time points: the blocked time point's formulas are subsumed by an ancestor, so the model can identify the blocked time with its ancestor without loss of information.

## Recommendations

### Approach: Two-Phase Implementation

**Phase 1: SemanticCountermodel Structure + Branch Model**

1. Modify `ExpandedTableau.hasOpen` to carry `TimeOrdering` (small, prerequisite change).
2. Define `SemanticCountermodel` extending `SimpleCountermodel` with:
   - World states (from `knownWorlds`)
   - Time points (from `knownTimes`)
   - Time ordering (from `TimeOrdering`)
   - Valuation at `(world, time, atom)` triples
3. Define `branchTruth : SemanticCountermodel → WorldIndex → TimeIndex → Formula → Prop` recursively on formula structure, using the countermodel's worlds/times/ordering/valuation.
4. Prove `extractSemanticCountermodel` produces a well-formed countermodel from a saturated open branch.

**Phase 2: Truth Lemma**

5. State the truth lemma: for all `sf ∈ b`, if `sf.sign = .pos` then `branchTruth cm sf.label.world sf.label.time sf.formula`, and if `sf.sign = .neg` then `¬ branchTruth cm ...`.
6. Prove by well-founded induction on `sf.formula.complexity`:
   - `atom`: by construction of valuation
   - `bot`: by openness (no `T(⊥)`)
   - `imp`: by saturation (impPos/impNeg were applied; analyze resulting branch content)
   - `box`: by saturation of boxPos/boxNeg + IH on subformula
   - `untl`/`snce`: by saturation of until/since rules + IH
7. For persistent formulas, prove that full propagation entails the universal quantifier.

**Phase 3 (Optional): Connection to TaskModel Semantics**

8. Construct a `TaskFrame Int` from the countermodel.
9. Construct `WorldHistory` instances.
10. Prove `branchTruth` corresponds to `truth_at` in the constructed model.

### Key Design Decisions

1. **Avoid full TaskModel construction initially.** Define `branchTruth` directly on the countermodel structure. This avoids universe issues and keeps the proof self-contained within the Decidability module.

2. **Require TimeOrdering in ExpandedTableau.** This is a small refactor but essential for Phase 1.

3. **Use Int for time domain** (when connecting to TaskModel in Phase 3). Topological sort of `TimeOrdering` constraints maps naturally to `Int`.

4. **Track expansion history** (optional but helpful). Currently, we can only infer what happened during expansion from the final saturated branch + saturation property. If this proves insufficient, we may need to add a "branch provenance" type that records which rules were applied.

### Estimated Complexity

- Phase 1 (SemanticCountermodel + branchTruth): Medium. Mostly structural definitions. ~200-300 lines.
- Phase 2 (Truth Lemma proof): Hard. The induction requires careful case analysis for each formula constructor, and persistent/branching rules need separate treatment. ~500-800 lines.
- Phase 3 (TaskModel connection): Medium. Mostly plumbing. ~200-300 lines.

### Dependencies

- No external task dependencies (task 240 has `dependencies: []` in state.json).
- Internal dependencies: Requires understanding of saturation guarantees (what `findUnexpanded b = none` actually implies about branch content). May benefit from helper lemmas like "if T(ψ→χ) was in the initial branch and the branch is saturated, then either F(ψ) or T(χ) is in the branch."
- The `sorry` stubs at `Saturation.lean` lines 632-667 (`subformula_property`, `blocking_terminates`, `blocking_sound`) are related but not strictly required for the truth lemma — the truth lemma assumes we already have a saturated open branch.

### Saturation Invariants Needed

The truth lemma proof will need the following properties of saturated branches, which should be proved as separate lemmas:

1. **Propositional saturation**: If `T(ψ → χ)` was consumed, then `F(ψ) ∈ b` or `T(χ) ∈ b`.
2. **Modal saturation (S5)**: If `T(□ψ)` at `(w, t) ∈ b`, then `T(ψ)` at `(w', t) ∈ b` for all `w' ∈ knownWorlds`.
3. **Temporal saturation (future)**: If `T(Gψ)` at `(w, t) ∈ b` and `t'` is a future time of `t` in the ordering, then `T(ψ)` at `(w, t') ∈ b`.
4. **Until decomposition**: If `T(U(event, guard))` at `(w, t)` was consumed, then at the fresh time `t'`: either `T(event)` at `(w, t')` (event branch) or `T(guard) ∧ T(U(event, guard))` at `(w, t')` (continue branch).
5. **Closure absence**: No `T(⊥)`, no complementary pair `T(φ)` and `F(φ)` at the same label, no negated axiom instance.

These saturation invariants are the core "what saturation means" properties that the truth lemma needs. They can be derived from `findUnexpanded b = none` and `findClosure b fc = none` by analyzing the rule application structure.
