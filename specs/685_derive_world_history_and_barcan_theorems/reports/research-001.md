# Research Report: Task #685

**Task**: 685 - Derive world-history and Barcan theorems
**Date**: 2026-01-29
**Focus**: World-history to world-state mapping theorem and Barcan formulas for various quantifiers
**Session**: sess_1769647223_f805de

## Executive Summary

- The task involves two theorem groups in the Logos Dynamics system
- **Theorem Group 1**: Prove that an evolution is a world-history iff all its values are world-states (Containment theorem)
- **Theorem Group 2**: Prove Barcan formulas for unrestricted/possibly-actual quantifiers and temporal analogs for sometimes-actual quantifier
- Both theorem groups can be implemented using the existing infrastructure in `Theories/Logos/SubTheories/Dynamics/`

## Findings

### 1. World-History / World-State Mapping Theorem (Containment Theorem)

**LaTeX Specification** (03-DynamicsFoundation.tex:232-234):
```latex
\begin{theorem}[Containment]\label{thm:containment}
An evolution τ is a world-history iff WorldState(τ(x)) for all x in its domain.
\end{theorem}
```

**Current Lean Implementation Analysis**:

The relevant definitions are in `Theories/Logos/SubTheories/Dynamics/Frame.lean`:

| Definition | Location | Description |
|------------|----------|-------------|
| `CoreFrame` | Line 42 | Frame with task relation and constraints |
| `possible` | Line 80 | `taskRel s 0 s` |
| `maximal` | Line 119 | All compatible states are parts |
| `world_state` | Line 125 | `possible w ∧ maximal w` |
| `WorldHistory` | Line 179 | Function from convex domain to states with task constraint |

**Key Insight**: The current `WorldHistory` structure already requires `world_states` at line 187:
```lean
world_states : ∀ t (ht : t ∈ domain), CoreFrame.world_state (states t ht)
```

This means the current implementation conflates "evolution" and "world-history". To prove the Containment theorem properly, we need to:

1. **Define Evolution** (missing): A function `τ : X → State` from convex domain that respects the task relation, but does NOT require each value to be a world-state
2. **Define Possible Evolution**: An evolution where `possible(τ(x))` for all x
3. **Define Maximal Evolution**: A possible evolution with no strictly larger possible evolution (under pointwise parthood)
4. **Define World-History** (alternative): A maximal possible evolution
5. **Prove Containment**: `IsWorldHistory τ ↔ ∀ x ∈ domain, world_state (τ x)`

**Containment Constraints Role**:

The Containment constraints (lines 188-189 of the LaTeX, lines 58-69 of Frame.lean) are crucial:
- **L-Contained**: If s ∈ P, d ⊑ s, and d ⇒_x r, then s ⇒_x (t ⊔ r) for some t
- **R-Contained**: If t ∈ P, r ⊑ t, and d ⇒_x r, then (s ⊔ d) ⇒_x t for some s

These ensure that tasks between parts of possible states can be extended to tasks between the states themselves. This is essential for proving:
- If an evolution has all world-state values, it cannot be extended (hence maximal)
- Conversely, a maximal possible evolution must have world-state values (otherwise it could be extended using containment)

**Proof Strategy for Containment Theorem**:

Forward direction (world-history → all world-states):
- This follows by definition if we use the maximal-possible-evolution definition
- A maximal possible evolution must have maximal states at each point, otherwise we could extend using containment

Backward direction (all world-states → world-history):
- If τ(x) is a world-state for all x, then τ is possible (world-states are possible)
- To show maximality: suppose σ ⊒ τ pointwise with σ possible
- For each x, σ(x) ⊒ τ(x) and σ(x) is possible, hence compatible with τ(x)
- Since τ(x) is maximal, σ(x) ⊑ τ(x), so σ(x) = τ(x)
- Therefore σ = τ, proving maximality

### 2. Barcan Formulas

**LaTeX Specification** (03-DynamicsFoundation.tex:364, 371, 374):

The Barcan formulas are:
- **BF**: `∀x□A → □∀xA` (Barcan formula)
- **CBF**: `□∀xA → ∀x□A` (Converse Barcan formula)

The temporal analogs are:
- **TBF-G**: `∀xGA → G∀xA` (Always future)
- **TBF-H**: `∀xHA → H∀xA` (Always past)
- And their converses

**Which Quantifiers Validate What**:

| Quantifier | Validates BF | Validates CBF | Validates Temporal BF |
|------------|--------------|---------------|----------------------|
| Unrestricted `∀x` | Yes | Yes | Yes |
| Possibly actual `∀y(◇A(y) → ...)` | Yes | Yes | No |
| Actually existing `∀y(A(y) → ...)` | No | No | No |
| Sometimes actual `∀y(▽A(y) → ...)` | No | No | Yes |

**Current Semantics Analysis**:

From `Theories/Logos/SubTheories/Dynamics/Truth.lean`:

```lean
-- Universal quantifier (line 185-186):
| Formula.all x φ =>
    ∀ s : M.frame.State, truthAt M τ t ht (σ.update x s) idx φ

-- Box operator (line 118-121):
| Formula.box φ =>
    ∀ (α : WorldHistory M.frame) (hα : t ∈ α.domain),
      truthAt M α t hα σ idx φ
```

The unrestricted quantifier ranges over ALL states `s : M.frame.State`, which is a fixed domain across all world-histories. This is the classic "fixed-domain" semantics that validates both Barcan formulas.

**Proof Strategy for Barcan Formulas (Unrestricted Quantifier)**:

For BF (`∀x□A → □∀xA`):
```
Assume ∀s. ∀α. truthAt M α t hα (σ.update x s) idx A
Need: ∀α. ∀s. truthAt M α t hα (σ.update x s) idx A
This is just quantifier swap (forall_swap from Mathlib)
```

For CBF (`□∀xA → ∀x□A`):
```
Assume ∀α. ∀s. truthAt M α t hα (σ.update x s) idx A
Need: ∀s. ∀α. truthAt M α t hα (σ.update x s) idx A
Again, quantifier swap
```

**Proof Strategy for Possibly Actual Quantifier**:

Define the "possibly actual" restriction:
```lean
def possiblyActual (M : CoreModel D) (s : M.frame.State) : Prop :=
  ∃ (τ : WorldHistory M.frame) (t : D) (ht : t ∈ τ.domain),
    M.frame.toConstitutiveFrame.parthood s (τ.states t ht)
```

The "all possibly actual" quantifier: `∀y(◇A(y) → B)` where `A(y)` is the actuality predicate.

Since a state is possibly actual iff it exists as a part of some world-state in some world-history, and the domain of states is fixed, this quantifier also validates Barcan formulas (the possibly actual states form a fixed set).

**Proof Strategy for Temporal Barcan (Sometimes Actual Quantifier)**:

The "all sometimes actual" quantifier: `∀y(▽A(y) → B)` where `▽` = sometimes (P ∨ A ∨ F).

This validates the temporal Barcan formulas because:
- The domain of "sometimes actual" states is fixed relative to a given history
- The temporal operators (H, G, P, F) quantify over times in the SAME history
- So `∀y(▽A(y) → GA)` and `G∀y(▽A(y) → A)` are equivalent by quantifier swap over fixed domain

### 3. Key Mathlib Theorems to Use

| Theorem | Type | Use Case |
|---------|------|----------|
| `forall_swap` | `(∀ x y, p x y) ↔ ∀ y x, p x y` | Barcan formula proofs |
| `forall₂_swap` | `(∀ i₁ j₁ i₂ j₂, p ...) ↔ ∀ i₂ j₂ i₁ j₁, p ...` | Multi-parameter swaps |
| `Set.forall_in_swap` | `(∀ a ∈ s, ∀ b, p a b) ↔ ∀ b, ∀ a ∈ s, p a b` | Restricted quantifiers |
| `zorn_le` | Existence of maximal elements | Proving evolution maximality |
| `Maximal` (definition) | `P x ∧ ∀ y, P y → x ≤ y → y ≤ x` | World-state maximality |

### 4. Required New Definitions

For a complete implementation, we need:

```lean
/-- An Evolution is a task-respecting function from a convex domain to states (not necessarily world-states) -/
structure Evolution (F : CoreFrame D) where
  domain : Set D
  domain_convex : Convex domain
  states : (t : D) → t ∈ domain → F.State
  task_respecting : ∀ x y (hx : x ∈ domain) (hy : y ∈ domain),
    x ≤ y → F.taskRel (states x hx) (y - x) (states y hy)

/-- An evolution is possible if all its states are possible -/
def Evolution.isPossible (τ : Evolution F) : Prop :=
  ∀ t (ht : t ∈ τ.domain), CoreFrame.possible (τ.states t ht)

/-- Pointwise parthood ordering on evolutions -/
def Evolution.le (τ σ : Evolution F) : Prop :=
  τ.domain = σ.domain ∧
  ∀ t (hτ : t ∈ τ.domain) (hσ : t ∈ σ.domain),
    F.toConstitutiveFrame.parthood (τ.states t hτ) (σ.states t hσ)

/-- An evolution is maximal among possible evolutions -/
def Evolution.isMaximal (τ : Evolution F) : Prop :=
  τ.isPossible ∧
  ∀ σ : Evolution F, σ.isPossible → τ.le σ → σ.le τ

/-- A world-history is a maximal possible evolution -/
def Evolution.isWorldHistory (τ : Evolution F) : Prop :=
  τ.isMaximal
```

### 5. File Organization

Recommended structure:

| File | Content |
|------|---------|
| `Frame.lean` | Add `Evolution` structure, `isPossible`, `isMaximal`, `isWorldHistory` |
| `Frame.lean` | Add `Containment` theorem |
| `Truth.lean` | Add `possiblyActual`, `sometimesActual` predicates |
| New: `Barcan.lean` | Barcan formula theorems |

## Recommendations

1. **Phase 1: Evolution Infrastructure**
   - Define `Evolution` structure in Frame.lean
   - Define `isPossible`, `isMaximal`, `isWorldHistory`
   - Prove that current `WorldHistory` embeds into `Evolution.isWorldHistory`

2. **Phase 2: Containment Theorem**
   - Prove forward direction using containment constraints
   - Prove backward direction using maximality of world-states
   - Add remarks discussing which constraints are used

3. **Phase 3: Barcan Formulas**
   - Define restricted quantifier predicates (`possiblyActual`, `sometimesActual`)
   - Prove unrestricted Barcan formulas (straightforward quantifier swap)
   - Prove possibly-actual Barcan formulas
   - Prove temporal Barcan formulas for sometimes-actual quantifier

4. **Phase 4: Documentation**
   - Add docstrings with references to LaTeX specification
   - Include proof strategy comments per task requirements

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Evolution definition requires refactoring WorldHistory | Keep WorldHistory as-is, prove equivalence |
| Containment constraint proof may be non-trivial | Use the existing frame axioms carefully |
| Restricted quantifier semantics not yet implemented | Add as formula constructors or derived operators |

## Dependencies

- Current Dynamics module infrastructure is sufficient
- No new Mathlib imports required beyond existing ones
- `forall_swap` from `Mathlib.Logic.Basic` (already available)

## Next Steps

1. Create implementation plan with phased approach
2. Prioritize Phase 1 (Evolution) and Phase 2 (Containment) first
3. Phase 3 (Barcan formulas) can follow once infrastructure is in place

## References

- LaTeX specification: `Theories/Logos/latex/subfiles/03-DynamicsFoundation.tex`
  - Evolution definition: lines 208-226
  - Containment theorem: lines 232-234
  - Barcan formulas discussion: lines 359-374
- Lean implementation: `Theories/Logos/SubTheories/Dynamics/Frame.lean`
- Truth semantics: `Theories/Logos/SubTheories/Dynamics/Truth.lean`
- Mathlib: `forall_swap`, `forall₂_swap`, `Set.forall_in_swap`
