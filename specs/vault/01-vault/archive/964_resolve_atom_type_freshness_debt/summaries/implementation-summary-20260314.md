# Implementation Summary: Resolve Atom Type Freshness Debt

- **Task**: 964 - resolve_atom_type_freshness_debt
- **Status**: BLOCKED (5/8 phases completed, Phase 6 mathematically blocked)
- **Date**: 2026-03-14
- **Sessions**: sess_1773513290_ngiqpj, sess_1773516266_87af15

## Overview

This task introduced a structured Atom type to replace String atoms, providing freshness
infrastructure (`Atom.exists_fresh`). Phases 1-5 completed successfully, establishing
the Atom type throughout the codebase. **Phase 6 is mathematically blocked**: the
`canonicalR_irreflexive` theorem CANNOT be proven without the T-axiom, which is NOT
valid in TM logic's strict temporal semantics.

**Critical Finding (research-003.md)**: The standard Gabbay IRR proof requires
`H(phi) -> phi` (T-axiom) to derive the contradiction, but TM uses strict G/H operators
where this is not valid. Freshness alone does not resolve this gap.

## Completed Phases

### Phase 1: Define Atom Type [COMPLETED]
- Created `Theories/Bimodal/Syntax/Atom.lean`
- Defined `structure Atom` with `base : String` and `fresh_index : Option Nat`
- Proved `Countable Atom` and `Infinite Atom` instances
- Added `Atom.exists_fresh : forall (S : Finset Atom), exists a, a notin S`
- Added `ReflBEq` and `LawfulBEq` instances

### Phase 2: Update Formula.lean [COMPLETED]
- Changed `| atom : String -> Formula` to `| atom : Atom -> Formula`
- Changed `Formula.atoms : Formula -> Finset String` to `Finset Atom`
- Added `Formula.atom_s : String -> Formula` for backward compatibility
- Updated BEq reflexivity proof

### Phase 3: Update Core Syntax Files [COMPLETED]
- Subformulas.lean and SubformulaClosure.lean compile without changes
- Type propagates automatically through imports

### Phase 4: Update Semantics [COMPLETED]
- Changed `TaskModel.valuation : WorldState -> String -> Prop` to use Atom
- Updated Truth.lean theorem signatures (atom_iff_of_domain, atom_false_of_not_domain)
- Updated from_list helper for backward compatibility

### Phase 5: Update Proof System and Examples [COMPLETED]
- Changed IRR rule in Derivation.lean from `p : String` to `p : Atom`
- Updated all `Formula.atom "..."` to `Formula.atom_s "..."`
- Updated CountermodelExtraction.lean (SimpleCountermodel, extractTrueAtoms, etc.)
- Updated files: ProofSearch, Tactics, Demo, all Proofs files, Context

### Phase 6: Complete CanonicalIrreflexivity Proof [BLOCKED - MATHEMATICALLY]

**Blocking Issue**: The standard Gabbay IRR proof requires the T-axiom (`H(phi) -> phi`)
to derive `neg(atom p) in M'` from `H(neg(atom p)) in M'`. In TM logic:

1. G/H use **strict** semantics: `G(phi)` means "phi at all t > now", NOT including now
2. The T-axiom is NOT valid because strict operators exclude the present time
3. Without T-axiom, we cannot get `neg(atom p) in M'` to contradict `atom p in M'`
4. `neg(atom p).atoms = {p}`, so it's NEVER p-free and cannot be in atomFreeSubset

**Conclusion**: In strict temporal semantics, irreflexivity is a **frame property**
(semantic assumption), not a syntactically derivable theorem from the axiom system.

### Phases 7-8: Not Started (blocked by Phase 6)

## Key Artifacts

### New Files
- `Theories/Bimodal/Syntax/Atom.lean` - Atom type with freshness support

### Modified Files (16 total)
- `Theories/Bimodal/Syntax/Formula.lean` - Core formula type change
- `Theories/Bimodal/Semantics/TaskModel.lean` - Valuation type change
- `Theories/Bimodal/Semantics/Truth.lean` - Theorem signatures
- `Theories/Bimodal/ProofSystem/Derivation.lean` - IRR rule type
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean`
- All Example files
- Various automation files

## Verification

- Full project builds: `lake build` succeeds (743 jobs)
- No new sorries introduced in modified files
- Pre-existing sorries remain in Examples (unrelated to this task)
- Axiom `canonicalR_irreflexive` remains in place

## Technical Debt Status

| Item | Before | After |
|------|--------|-------|
| Axiom in CanonicalIrreflexivityAxiom.lean | Present | Present (REQUIRED) |
| Sorries in CanonicalIrreflexivity.lean | 2 | 2 (not resolvable) |
| Atom type supports freshness | No | Yes |
| Proof theoretically possible with freshness | No (String) | **No** (T-axiom missing) |

## Recommended Next Steps

1. **Accept axiom as valid frame property** (Recommended):
   - The `canonicalR_irreflexive` axiom is mathematically sound for strict semantics
   - It captures the frame property that strict temporal operators are irreflexive
   - Update axiom docstring to clarify this is a semantic assumption, not derivable

2. **Alternative: Add T-axiom to system** (Major change):
   - Would require switching from strict to reflexive G/H semantics
   - Changes the meaning of temporal operators throughout the system
   - NOT recommended unless specifically required

3. **Alternative: Semantic proof approach**:
   - Prove irreflexivity directly from frame construction
   - Would require showing canonical model is built on strict frame
   - Significant effort with unclear benefit over keeping axiom

## Commits

1. `0494f7cc` - task 964 phase 1: define Atom type with freshness support
2. `f0d49375` - task 964 phase 2: update Formula.lean to use Atom type
3. `8d3d56ab` - task 964 phase 3: verify core Syntax files compile
4. `4177a90e` - task 964 phase 4: update Semantics to use Atom type
5. `e85e2d9a` - task 964 phase 5: update ProofSystem and Examples for Atom type
6. `ec13348a` - task 964 phase 5: update CountermodelExtraction for Atom type
