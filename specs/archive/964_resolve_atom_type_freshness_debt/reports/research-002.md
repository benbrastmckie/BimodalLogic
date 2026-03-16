# Research 002: Deep Atom Type Freshness Analysis

## Date: 2026-03-14
## Session: sess_1773512635_0iynyl

## Executive Summary

This research provides a detailed implementation plan for changing the atom type from
`String` to a structured type that supports freshness, enabling the proof of
`canonicalR_irreflexive` as a theorem rather than an axiom. The change is well-scoped
and follows an existing pattern in the codebase (`ConservativeExtension/ExtFormula.lean`).

## Problem Analysis

### The Freshness Requirement

The proof of `canonicalR_irreflexive` follows the Gabbay Irreflexivity Rule (IRR)
contrapositively:

1. Assume `CanonicalR M M` for contradiction
2. Pick a **fresh** atom `p` not appearing in any formula of `GContent(M)`
3. Construct naming set: `atomFreeSubset M p + {atom p, H(neg p)}`
4. Show naming set is consistent via IRR contrapositive
5. Extend to MCS M' and derive contradiction

**Step 2 fails with String atoms** because for every string `s`:
- The tautology `G(s + " OR NOT " + s)` is in any MCS M
- Hence `s + " OR NOT " + s` is in `GContent(M)`
- The atom `s` appears in this formula
- No string is fresh for `GContent(M)`

### Current State

- **Axiom**: `canonicalR_irreflexive` in `Canonical/CanonicalIrreflexivityAxiom.lean`
- **Failed proof**: `Bundle/CanonicalIrreflexivity.lean` with 2 sorries (lines 1273, 1356)
- **Documentation**: Full analysis in docstring and research-001.md

## Mathlib Freshness Infrastructure

### Key Lemmas Discovered

```lean
-- From Mathlib.Data.Fintype.EquivFin
theorem Infinite.exists_notMem_finset {alpha : Type} [Infinite alpha] (s : Finset alpha) :
  exists x, x not-in s

-- Alternative forms
theorem Finset.exists_notMem {alpha : Type} [Infinite alpha] (s : Finset alpha) :
  exists a, a not-in s

-- Instance
instance : Infinite Nat
```

### Key Insight

Any type with an `Infinite` instance automatically gets freshness via
`Infinite.exists_notMem_finset`. We need:
1. An `Infinite Atom` instance, AND
2. `Countable Atom` (for enumeration in completeness)

Both are achievable with `Nat x Nat` or a structured `Atom` type.

## Implementation Options Analysis

### Option A: Structured Atom Type (RECOMMENDED)

```lean
structure Atom where
  base : String
  fresh_index : Option Nat
  deriving Repr, DecidableEq, BEq, Hashable
```

**Advantages:**
- Backward compatible: `Formula.atom "p"` becomes `Formula.atom { base := "p", fresh_index := none }`
- Human-readable: examples keep semantic meaning
- Clear fresh atom generation: `{ base := "", fresh_index := some n }` for any n not yet used

**Countable proof:**
```lean
instance : Countable Atom := by
  have h : Function.Injective (fun a : Atom => (a.base, a.fresh_index)) := by
    intro a b heq; cases a; cases b; simp_all
  exact Function.Injective.countable h
```

**Infinite proof:**
```lean
instance : Infinite Atom := by
  apply Infinite.of_injective (fun n : Nat => Atom.mk "" (some n))
  intro m n hmn
  simp [Atom.mk.injEq] at hmn
  exact hmn
```

### Option B: Nat x Nat Atoms

```lean
abbrev Atom := Nat x Nat
```

**Advantages:**
- Extremely simple
- Already has `Infinite` and `Countable` instances in Mathlib
- No new structure definition needed

**Disadvantages:**
- Loses human readability in examples
- Requires defining a mapping from semantic names to number pairs
- Examples become `Formula.atom (0, 0)` instead of `Formula.atom "p"`

### Option C: Typeclass-Based Freshness (COMPLEX)

```lean
class HasFreshness (alpha : Type) where
  fresh : Finset alpha -> alpha
  fresh_not_mem : forall S, fresh S not-in S
```

**Disadvantages:**
- Requires propagating typeclass through ALL formula/proof/semantics code
- Massive refactoring scope
- Unnecessary complexity when simpler solutions exist

## Existing Pattern: ConservativeExtension

The codebase already implements a similar pattern in `ConservativeExtension/ExtFormula.lean`:

```lean
-- Extended atom type with one fresh element
abbrev ExtAtom := String + Unit

def freshAtom : ExtAtom := Sum.inr ()

inductive ExtFormula : Type where
  | atom : ExtAtom -> ExtFormula
  | bot : ExtFormula
  | imp : ExtFormula -> ExtFormula -> ExtFormula
  | box : ExtFormula -> ExtFormula
  | all_past : ExtFormula -> ExtFormula
  | all_future : ExtFormula -> ExtFormula
  deriving Repr, DecidableEq, BEq, Hashable, Countable
```

**Key theorem:**
```lean
theorem fresh_not_in_embedFormula_atoms :
    freshAtom not-in (embedFormula phi).atoms
```

This pattern proves the approach works. However, it only provides ONE fresh atom.
The irreflexivity proof needs arbitrary freshness for any finite set, which
requires `Infinite`.

## Refactoring Scope

### Files Requiring Changes (by category)

**1. Core Syntax (3 files)**
- `Syntax/Formula.lean`: Change `String -> Formula` to `Atom -> Formula`
- `Syntax/Subformulas.lean`: Update atom handling
- `Syntax/SubformulaClosure.lean`: Update atom handling

**2. Semantics (3 files)**
- `Semantics/TaskModel.lean`: Change `valuation : WorldState -> String -> Prop`
  to `valuation : WorldState -> Atom -> Prop`
- `Semantics/Truth.lean`: Update pattern matching
- `Semantics/Validity.lean`: Minor updates

**3. Proof System (2 files)**
- `ProofSystem/Derivation.lean`: Update IRR rule freshness condition
- `ProofSystem/Axioms.lean`: No changes needed (axioms are parametric)

**4. Metalogic Core (8 files)**
- `Metalogic/IRRSoundness.lean`: Update freshness handling
- `Metalogic/Bundle/CanonicalIrreflexivity.lean`: MAIN PROOF - complete with freshness
- `Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`: DELETE axiom, add theorem
- `Metalogic/Core/MaximalConsistent.lean`: Update atom references
- Plus 4 more files with minor updates

**5. Conservative Extension (4 files)**
- May need updates if ExtFormula pattern changes
- Or can remain as-is (orthogonal approach)

**6. Examples (15+ files)**
- Mechanical: `Formula.atom "p"` -> `Formula.atom { base := "p", fresh_index := none }`
- Can use abbreviation: `def p : Atom := { base := "p", fresh_index := none }`

### Estimated Line Changes

| Category | Files | Lines Changed |
|----------|-------|--------------|
| Syntax | 3 | ~100 |
| Semantics | 3 | ~50 |
| Proof System | 2 | ~30 |
| Metalogic | 8 | ~300 |
| Examples | 15+ | ~500 (mechanical) |
| **Total** | **31+** | **~980** |

## Implementation Plan

### Phase 1: Atom Type Definition (1-2 hours)

1. Create new file `Syntax/Atom.lean`:
   ```lean
   structure Atom where
     base : String
     fresh_index : Option Nat
     deriving Repr, DecidableEq, BEq, Hashable

   namespace Atom
   def mk_base (s : String) : Atom := { base := s, fresh_index := none }
   def mk_fresh (n : Nat) : Atom := { base := "", fresh_index := some n }

   instance : Countable Atom := ...
   instance : Infinite Atom := ...

   theorem exists_fresh (S : Finset Atom) : exists a, a not-in S :=
     Infinite.exists_notMem_finset S
   end Atom
   ```

2. Add convenient notation: `#a"p"` expands to `Atom.mk_base "p"`

### Phase 2: Formula Refactoring (2-3 hours)

1. Update `Syntax/Formula.lean`:
   - Import `Syntax/Atom`
   - Change `atom : String -> Formula` to `atom : Atom -> Formula`
   - Update `atoms : Formula -> Finset String` to `atoms : Formula -> Finset Atom`
   - Add compatibility: `def atom_s (s : String) := atom (Atom.mk_base s)`

2. Update downstream syntax files

### Phase 3: Semantics Update (1-2 hours)

1. Update `TaskModel.valuation` signature
2. Update `Truth.truth_at` atom case
3. Verify all semantic lemmas still typecheck

### Phase 4: Proof System Update (1-2 hours)

1. Update IRR rule in `Derivation.lean`
2. Verify freshness condition uses `Finset Atom`

### Phase 5: Metalogic Completion (4-6 hours)

1. Update `Bundle/CanonicalIrreflexivity.lean`:
   - Replace `Finset_String_not_univ` with `Atom.exists_fresh`
   - Complete the two sorries using actual freshness

2. Delete axiom from `Canonical/CanonicalIrreflexivityAxiom.lean`
3. Add theorem `canonicalR_irreflexive` to appropriate module
4. Verify downstream theorems still compile

### Phase 6: Examples Update (2-3 hours)

1. Create helper abbreviations in a shared file:
   ```lean
   def p := Atom.mk_base "p"
   def q := Atom.mk_base "q"
   def r := Atom.mk_base "r"
   ```
2. Update example files mechanically

## Risk Assessment

### Low Risk
- Countable/Infinite instances are standard Mathlib patterns
- The proof structure is already implemented (just blocked by freshness)
- Similar pattern exists in ConservativeExtension

### Medium Risk
- Large number of files to update (scope management)
- Potential for subtle breakages in metalogic proofs

### Mitigation
- Implement in phases with `lake build` verification at each step
- Use version control branches for safe rollback
- Consider adding `atom_s` backward-compatibility abbreviation

## Downstream Impact

Once `canonicalR_irreflexive` becomes a theorem, these results are FULLY PROVEN:

1. **Dense timeline quotient:**
   - `NoMaxOrder` (proven)
   - `NoMinOrder` (proven)
   - `DenselyOrdered` (proven)

2. **Discrete timeline quotient:**
   - `NoMaxOrder` (proven)
   - `NoMinOrder` (proven)

3. **Strictness properties:**
   - `canonicalR_strict` (proven)
   - `canonicalR_antisymmetric_strict` (proven)

## Recommendation

**Proceed with Option A (Structured Atom Type)** for the following reasons:

1. **Preserves readability**: Examples remain meaningful
2. **Minimal Mathlib dependency**: Only needs `Infinite` typeclass
3. **Clean semantics**: Fresh atoms are explicitly tagged
4. **Proven pattern**: Similar to ExtFormula approach
5. **Manageable scope**: ~1000 lines across 31 files

**Estimated total effort**: 12-18 hours of focused implementation work.

The task should be marked as **ready for planning** with this research as the basis.

## References

- `Syntax/Formula.lean`: Current atom type definition
- `Metalogic/Bundle/CanonicalIrreflexivity.lean`: Failed proof with sorries
- `Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`: Current axiom
- `Metalogic/ConservativeExtension/ExtFormula.lean`: Existing fresh atom pattern
- `Mathlib.Data.Fintype.EquivFin`: `Infinite.exists_notMem_finset`
- Goldblatt (1992), *Logics of Time and Computation*, Ch. 6
- Blackburn, de Rijke, Venema (2001), *Modal Logic*, Ch. 4.8
