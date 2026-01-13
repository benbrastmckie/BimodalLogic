# Research Report: Task #444

**Task**: 444 - Formula Countability and Set-List Bridge
**Started**: 2026-01-12
**Completed**: 2026-01-12
**Effort**: 8-10 hours estimated
**Priority**: Low
**Dependencies**: None (first phase of Task 257)
**Sources/Inputs**: Mathlib (Countable, Encodable, Set.enumerateCountable), lean-lsp tools
**Artifacts**: This report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Formula countability can be achieved via `deriving Countable` after providing `Countable String` and `Countable Char` instances
- The fundamental issue with `lindenbaum` is NOT about converting infinite sets to lists - maximal consistent sets ARE typically infinite and cannot be represented as finite lists
- **Recommended approach**: Refactor completeness to use sets throughout (`Set Formula`) rather than trying to bridge to `List Formula`
- Alternative approach: Accept that `MaximalConsistent` for lists represents *finite approximations* to maximal consistent sets

## Context & Scope

### The Problem

The `lindenbaum` theorem at line 413 of `Completeness.lean` has a `sorry`:

```lean
theorem lindenbaum (Γ : Context) (h : Consistent Γ) :
    ∃ Δ : Context, (∀ φ, φ ∈ Γ → φ ∈ Δ) ∧ MaximalConsistent Δ := by
  sorry
```

The issue: `Context` is `List Formula` (finite), but maximal consistent sets are typically infinite.

### Current Definitions

```lean
-- List-based (Context = List Formula)
def Consistent (Γ : Context) : Prop := ¬Nonempty (DerivationTree Γ Formula.bot)
def MaximalConsistent (Γ : Context) : Prop :=
  Consistent Γ ∧ ∀ φ : Formula, φ ∉ Γ → ¬Consistent (φ :: Γ)

-- Set-based (already implemented)
def SetConsistent (S : Set Formula) : Prop :=
  ∀ L : List Formula, (∀ φ ∈ L, φ ∈ S) → Consistent L
def SetMaximalConsistent (S : Set Formula) : Prop :=
  SetConsistent S ∧ ∀ φ : Formula, φ ∉ S → ¬SetConsistent (insert φ S)
```

The set-based `set_lindenbaum` is already proven using Zorn's lemma (lines 342-391).

## Findings

### 1. Formula Countability

**Finding**: Formula can derive `Countable` after establishing prerequisites.

**Required Instances** (in order):
1. `Countable Char` - via injection `Char.toNat : Char → Nat`
2. `Countable String` - via injection `String.toList : String → List Char`
3. `Countable Formula` - via `deriving Countable` with `Mathlib.Tactic.DeriveCountable`

**Verified Code Pattern**:
```lean
import Mathlib.Tactic.DeriveCountable

-- Char → Nat is injective
instance : Countable Char := by
  have h : Function.Injective Char.toNat := by
    intro c1 c2 heq
    have h1 : Char.ofNat c1.toNat = c1 := Char.ofNat_toNat c1
    have h2 : Char.ofNat c2.toNat = c2 := Char.ofNat_toNat c2
    rw [← h1, ← h2, heq]
  exact Function.Injective.countable h

-- String → List Char is injective
instance : Countable String := by
  have h : Function.Injective String.toList := by
    intro s1 s2 heq
    rw [← String.toList_inj]
    exact heq
  exact Function.Injective.countable h

-- Formula derives Countable (after Countable String available)
inductive Formula : Type where
  | atom : String → Formula
  | bot : Formula
  | imp : Formula → Formula → Formula
  | box : Formula → Formula
  | all_past : Formula → Formula
  | all_future : Formula → Formula
  deriving Repr, DecidableEq, Countable
```

**Mathlib Tools Used**:
- `Mathlib.Tactic.DeriveCountable` - automatic derivation for inductive types
- `Function.Injective.countable` - countability via injection

### 2. Set-to-List Conversion for Countable Sets

**Finding**: Mathlib provides `Set.enumerateCountable` for enumeration.

**Key Lemmas**:
```lean
-- From Mathlib.Data.Set.Countable
def Set.enumerateCountable {s : Set α} (h : s.Countable) (default : α) : ℕ → α

theorem Set.enumerateCountable_mem (h : s.Countable) {default : α}
  (hd : default ∈ s) (n : Nat) : s.enumerateCountable h default n ∈ s

theorem Set.range_enumerateCountable_of_mem (h : s.Countable) {default : α}
  (hd : default ∈ s) : Set.range (s.enumerateCountable h default) = s

theorem Set.Countable.toEncodable {s : Set α} (h : s.Countable) : Encodable s
```

**Issue**: `Set.enumerateCountable` gives `Nat → α`, not `List α`. The range equals the full set only when the set is nonempty. For infinite sets, you cannot produce a finite `List` containing all elements.

### 3. The Fundamental Problem

**Finding**: The list-based lindenbaum cannot be proven because maximal consistent sets are infinite.

**Analysis**:
- `MaximalConsistent Δ` requires `∀ φ : Formula, φ ∉ Δ → ¬Consistent (φ :: Δ)`
- For a maximal consistent SET `M`, for every formula φ, either φ ∈ M or ¬φ ∈ M
- Since there are infinitely many formulas, a maximal consistent SET is infinite
- `List Formula` is finite, so no list can be maximally consistent in the set-theoretic sense

**The list-based definition is fundamentally misaligned with the mathematical concept.**

### 4. Three Approaches

#### Approach A: Refactor to Sets Throughout (RECOMMENDED)

Refactor the entire completeness proof to use `Set Formula` instead of `List Formula`:

```lean
-- Replace CanonicalWorldState
def CanonicalWorldState : Type := {S : Set Formula // SetMaximalConsistent S}

-- Use set_lindenbaum (already proven)
-- Remove list-based lindenbaum entirely
```

**Pros**:
- Mathematically correct
- `set_lindenbaum` already proven
- Cleaner theory

**Cons**:
- Requires changes to `CanonicalWorldState`, `canonical_valuation`, etc.
- May affect downstream code that expects lists

**Effort**: 4-6 hours to refactor

#### Approach B: Reinterpret MaximalConsistent

Reinterpret list-based `MaximalConsistent` as "maximal among finite extensions":

```lean
-- Current definition actually means:
-- "Consistent and cannot be finitely extended while remaining consistent"
-- NOT: "Contains all formulas it should"
```

This interpretation is useful for **finite approximations** but NOT for canonical model construction, which requires true maximality.

**Assessment**: Not suitable for completeness proof.

#### Approach C: Use Countable Enumeration (Complex)

Use `Set.enumerateCountable` to enumerate formulas, then show consistency is preserved under enumeration:

```lean
-- Define: A list is "co-finite maximal" if it represents a maximal consistent set
def CofiniteMaximalConsistent (Γ : Context) (M : Set Formula) : Prop :=
  SetMaximalConsistent M ∧ ∀ φ ∈ Γ, φ ∈ M

-- lindenbaum would produce a set M and an (infinite) enumeration
-- But we cannot actually return an infinite List Formula
```

**Assessment**: Does not solve the fundamental issue that lists are finite.

## Decisions

1. **Formula Countability**: Implement `Countable Char`, `Countable String`, and `deriving Countable` for Formula. This is straightforward and useful regardless of approach.

2. **Lindenbaum Approach**: Recommend **Approach A** (refactor to sets throughout).

3. **Fallback**: If Approach A is too invasive, delete the list-based `lindenbaum` theorem entirely and only use `set_lindenbaum`. The rest of the completeness proof should use `Set Formula`.

## Recommendations

### Immediate Actions (Phase 1 Implementation)

1. **Add Countability Instances** (30 min)
   - Add `instance : Countable Char` using `Char.toNat` injection
   - Add `instance : Countable String` using `String.toList` injection
   - Add `import Mathlib.Tactic.DeriveCountable`
   - Add `deriving Countable` to Formula inductive definition in `Syntax/Formula.lean`

2. **Refactor CanonicalWorldState** (2-3 hours)
   - Change from `{Γ : Context // MaximalConsistent Γ}` to `{S : Set Formula // SetMaximalConsistent S}`
   - Update `canonical_valuation` to work with sets
   - Update `truth_lemma` signature
   - Delete list-based `lindenbaum` (keep `set_lindenbaum`)

3. **Update Definitions** (1-2 hours)
   - Remove list-based `Consistent` and `MaximalConsistent` definitions if no longer needed
   - OR keep them for finite reasoning but not for canonical model construction

4. **Update Test Files** (1 hour)
   - Update `CompletenessTest.lean` to use set-based definitions

### Required Mathlib Imports

```lean
import Mathlib.Tactic.DeriveCountable      -- For deriving Countable
import Mathlib.Data.Countable.Basic        -- For Countable type class
import Mathlib.Data.Set.Countable          -- For Set.Countable, enumerateCountable
import Mathlib.Logic.Equiv.List            -- For List.countable instance
```

### Code Template for Countability

```lean
-- In Syntax/Formula.lean or a new Syntax/Countable.lean
import Mathlib.Tactic.DeriveCountable
import Mathlib.Data.Countable.Basic

-- Prerequisites
instance : Countable Char := by
  have h : Function.Injective Char.toNat := by
    intro c1 c2 heq
    rw [← Char.ofNat_toNat c1, ← Char.ofNat_toNat c2, heq]
  exact Function.Injective.countable h

instance : Countable String := by
  exact Function.Injective.countable String.toList_inj

-- Formula derives Countable automatically
-- (add to Formula inductive definition)
```

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Refactoring CanonicalWorldState breaks downstream | Medium | Review all usages, update incrementally |
| Set-based truth lemma more complex | Medium | Sets are the mathematically correct representation |
| `deriving Countable` fails for Formula | Low | Fall back to manual construction via `instCountableSigma` |

## Appendix

### Search Queries Used

1. `lean_leansearch`: "derive Countable instance for inductive type"
2. `lean_loogle`: "Encodable, List"
3. `lean_leansearch`: "convert countable set to list enumeration"
4. `lean_leanfinder`: "enumerate elements of countable set as function from nat"
5. `lean_local_search`: "enumerateCountable", "Countable"

### Key Mathlib Locations

- `Mathlib.Tactic.DeriveCountable` - Countable derivation handler
- `Mathlib.Data.Countable.Basic` - Core countable definitions
- `Mathlib.Data.Set.Countable` - Set.enumerateCountable
- `Mathlib.Logic.Equiv.List` - List.countable instance

### References

- Mathlib Countable docs: Countable type class for injective maps to Nat
- Mathlib Encodable docs: Constructive countability with encode/decode
- Existing `set_lindenbaum` proof in Completeness.lean (lines 342-391)
