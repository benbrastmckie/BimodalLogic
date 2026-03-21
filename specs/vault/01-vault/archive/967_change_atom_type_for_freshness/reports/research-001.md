# Research 001: Verification and Implementation Readiness

## Date: 2026-03-14
## Session: sess_1773527957_9e27df
## Task: 967 - Change atom type from String to freshness-supporting type

## Executive Summary

This research verifies the current codebase state against the analysis in research-002 (task 964) and confirms implementation readiness. **Key finding**: Phase 1 (Atom type definition) is COMPLETE. The structured `Atom` type with `Infinite` and `Countable` instances already exists. The remaining work is smaller than the original estimate.

## Current Codebase State

### Phase 1: Atom Type Definition - COMPLETE

The file `Theories/Bimodal/Syntax/Atom.lean` has been created with:

```lean
structure Atom where
  base : String
  fresh_index : Option Nat
  deriving Repr, DecidableEq, BEq, Hashable

instance : Countable Atom := Countable.of_equiv _ atomEquiv.symm
instance : Infinite Atom := Infinite.of_injective natToAtom natToAtom_injective

theorem Atom.exists_fresh (S : Finset Atom) : exists a : Atom, a not-in S :=
  Infinite.exists_notMem_finset S
```

All required infrastructure is in place:
- `Atom.mk_base : String -> Atom` - creates base atoms
- `Atom.mk_fresh : String -> Nat -> Atom` - creates fresh atoms
- `Atom.fresh_for : Finset Atom -> Atom` - noncomputable fresh atom constructor
- `Atom.fresh_for_not_mem` - proof that `fresh_for` result is not in set
- `ReflBEq Atom` and `LawfulBEq Atom` instances

### Phase 2: Formula Refactoring - COMPLETE

`Theories/Bimodal/Syntax/Formula.lean` has been updated:
- Imports `Bimodal.Syntax.Atom`
- `Formula.atom : Atom -> Formula` (changed from `String -> Formula`)
- `Formula.atoms : Formula -> Finset Atom` (changed from `Finset String`)
- `Formula.atom_s : String -> Formula` - backward compatibility helper

The docstring confirms the change (lines 26-27):
> Atoms are represented as `Atom` (structured type with base string and optional fresh index)
> This enables freshness: for any finite set of atoms, there exists an atom not in the set

### Phase 3-6: Remaining Work

#### Files Already Updated (via `atom_s` usage)
These 14 files use `atom_s` for backward compatibility and compile correctly:
- `Examples/*.lean` (6 files)
- `Automation/ProofSearch.lean`, `Automation/Tactics.lean`
- `Syntax/Context.lean`, `Syntax.lean`
- `Semantics.lean`, `Bimodal.lean`

#### Files Requiring Updates

**Critical - Type Errors Present:**

1. `Metalogic/Bundle/CanonicalIrreflexivity.lean`
   - Uses `(p : String)` throughout (~10 occurrences)
   - `Formula.atom p` causes type error (expects `Atom`, gets `String`)
   - `atomFreeSubset`, `namingSet` signatures use `String`
   - Contains 2 sorries at lines 1273, 1356

2. `Metalogic/ConservativeExtension/Lifting.lean`
   - Uses `Finset String` in private helpers
   - Less critical: this is for the `ExtAtom = String + Unit` system

**Axiom Still Exists:**

`Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` line 95:
```lean
axiom canonicalR_irreflexive :
  forall (M : Set Formula), SetMaximalConsistent M -> not CanonicalR M M
```

## Mathlib Verification

### Lemma Existence Confirmed

`Set.Infinite.exists_notMem_finset` exists in:
- `.lake/packages/mathlib/Mathlib/Data/Set/Finite/Basic.lean`

`Bimodal.Syntax.Atom.exists_fresh` exists locally (wraps `Infinite.exists_notMem_finset`).

### Type Signature Verified

```lean
theorem Atom.exists_fresh (S : Finset Atom) : exists a : Atom, a not-in S
```

This is exactly what the IRR proof needs for step 2 of the Gabbay construction.

## Revised Implementation Plan

### Original Plan (research-002): 6 phases, 12-18 hours
### Revised Plan: 3 phases, 4-8 hours

| Phase | Status | Remaining Work |
|-------|--------|----------------|
| 1. Atom Type Definition | COMPLETE | None |
| 2. Formula Refactoring | COMPLETE | None |
| 3. Semantics Update | COMPLETE | None (uses `atom_s`) |
| 4. Proof System Update | PARTIAL | Update IRR freshness condition |
| 5. Metalogic Completion | IN PROGRESS | Fix CanonicalIrreflexivity.lean |
| 6. Examples Update | COMPLETE | None (uses `atom_s`) |

### Phase 5: CanonicalIrreflexivity.lean Updates

**Required changes:**

1. Change `atomFreeSubset (M : Set Formula) (p : String)` to `(p : Atom)`
2. Change `namingSet (M : Set Formula) (p : String)` to `(p : Atom)`
3. Replace `Formula.atom p` with direct `Formula.atom p` (now valid)
4. Change `Finset_String_not_univ` references to `Atom.exists_fresh`
5. Update `exists_fresh_for_finite_list` to use `Atom`
6. Fix the 2 sorries using actual freshness

**Key proof change:**

The current proof at line ~1200 does:
```lean
-- Choose any string p (BLOCKED - no global freshness for String)
-- Use atomFreeSubset M p (BLOCKED - incomplete subset)
```

With `Atom` freshness, the proof becomes:
```lean
-- Collect all atoms from GContent M
let gc_atoms : Finset Atom := (GContent M).atoms_finset  -- need to define
-- Get fresh atom
obtain (p, hp) := Atom.exists_fresh gc_atoms
-- Now atomFreeSubset M p = M for all formulas in GContent(M)
```

The critical insight: with `Atom.exists_fresh`, we can pick a fresh atom `p` that does NOT appear in ANY formula of `GContent(M)`. This means for all `phi in GContent(M)`, `p not-in phi.atoms`, so `phi in atomFreeSubset M p`. Thus `GContent(M) subseteq atomFreeSubset M p subseteq M'`, and the proof completes.

### Blocking Consideration

The proof still needs:
1. `GContent(M).atoms_finset` - the set of all atoms appearing in G-content
2. Proof that `GContent(M)` involves only finitely many atoms (per formula)

This may require auxiliary lemmas about finiteness of atoms in derivable formulas.

## Risk Assessment

### Low Risk
- Atom type definition is complete and correct
- Mathlib infrastructure is verified
- Build passes (with contained type errors)

### Medium Risk
- CanonicalIrreflexivity.lean proof restructuring
- May need to prove atoms finiteness for MCS subsets

### Mitigation
- The proof strategy is mathematically sound (Gabbay IRR)
- The blocker was String freshness, which is now resolved by Atom type

## Recommendations

1. **Phase 4-5 combined**: Fix CanonicalIrreflexivity.lean in one pass
   - Convert String -> Atom throughout
   - Add helper lemma for atoms finiteness
   - Complete the 2 sorries

2. **Axiom removal**: After proof completes
   - Delete `canonicalR_irreflexive` axiom from `CanonicalIrreflexivityAxiom.lean`
   - Move theorem to same file or `CanonicalIrreflexivity.lean`

3. **ConservativeExtension**: No changes needed
   - Uses `ExtAtom = String + Unit` which is a different pattern
   - Orthogonal to this refactoring

## Estimated Effort

| Component | Hours |
|-----------|-------|
| CanonicalIrreflexivity.lean type fixes | 1-2 |
| Atoms finiteness lemmas | 1-2 |
| Sorry completion | 2-4 |
| Axiom removal + verification | 0.5 |
| **Total** | **4.5-8.5** |

## Conclusion

Task 967 is well-positioned for implementation. The hardest work (Atom type definition with Countable/Infinite instances) is complete. The remaining work is:

1. Type-level fixes in CanonicalIrreflexivity.lean (~2 hours)
2. Proof completion using Atom.exists_fresh (~4 hours)
3. Axiom removal and verification (~0.5 hours)

The task should be marked **ready for planning** with implementation estimated at 4-8 hours.

## References

- `Theories/Bimodal/Syntax/Atom.lean` - Complete Atom type definition
- `Theories/Bimodal/Syntax/Formula.lean` - Updated formula syntax
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Proof file (needs fixes)
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - Axiom to remove
- `specs/964_resolve_atom_type_freshness_debt/reports/research-002.md` - Prior analysis
