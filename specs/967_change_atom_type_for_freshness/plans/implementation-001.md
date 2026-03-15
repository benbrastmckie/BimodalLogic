# Implementation Plan: Task #967

- **Task**: 967 - Change atom type from String to freshness-supporting type
- **Status**: [NOT STARTED]
- **Effort**: 5.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/967_change_atom_type_for_freshness/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task eliminates the `canonicalR_irreflexive` axiom by completing the Gabbay IRR proof. Research (research-001.md) confirms that Phases 1-3 (Atom type definition, Formula refactoring, Semantics update) are ALREADY COMPLETE. The remaining work is to fix type mismatches in `CanonicalIrreflexivity.lean` where `String` is used instead of `Atom`, add finiteness infrastructure for GContent atoms, complete the 2 sorries using `Atom.exists_fresh`, and delete the axiom.

### Research Integration

- **research-001.md**: Verified that `Theories/Bimodal/Syntax/Atom.lean` is complete with `Countable`, `Infinite`, and `exists_fresh` instances
- `Formula.lean` already uses `Atom` type; backward compatibility via `Formula.atom_s`
- `CanonicalIrreflexivity.lean` contains ~10 occurrences of `(p : String)` that need conversion
- 2 sorries at lines 1273 and 1356 are blocked on freshness - solvable with Atom type

## Goals & Non-Goals

**Goals**:
- Convert all `(p : String)` parameters in `CanonicalIrreflexivity.lean` to `(p : Atom)`
- Define helper lemmas for finiteness of atoms in GContent(M)
- Complete the 2 sorries using `Atom.exists_fresh`
- Delete the `canonicalR_irreflexive` axiom from `CanonicalIrreflexivityAxiom.lean`
- Ensure `lake build` passes with zero sorries in modified files

**Non-Goals**:
- Refactor `ConservativeExtension/Lifting.lean` (uses different `ExtAtom` pattern)
- Change other usages of `atom_s` throughout the codebase (backward compatibility)
- Add new features beyond eliminating this specific axiom

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| GContent atoms finiteness proof complex | M | M | Use finite formula structure - atoms come from G-formulas in M |
| Proof restructuring needed beyond type fix | H | L | Research confirms type fix is the core blocker; proof strategy is sound |
| Type inference issues after String -> Atom | L | M | Explicit type annotations where needed |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `CanonicalIrreflexivity.lean` at lines 1273 and 1356
- Both blocked on inability to get fresh atom for MCS M

### Expected Resolution
- Phase 2 provides finiteness infrastructure to collect atoms from GContent(M)
- Phase 3 uses `Atom.exists_fresh gc_atoms` to obtain fresh atom p
- Phase 3 completes both sorries using the fresh atom

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach

### Remaining Debt
After this implementation:
- 0 sorries expected in `CanonicalIrreflexivity.lean`
- 0 axioms expected in `CanonicalIrreflexivityAxiom.lean` (axiom deleted)
- `canonicalR_irreflexive` becomes a theorem, not an axiom

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in `CanonicalIrreflexivityAxiom.lean`: `canonicalR_irreflexive` (formalization artifact)

### Expected Resolution
- Phase 4 deletes the axiom after proof is complete
- Theorem moves to `CanonicalIrreflexivity.lean` or replaces axiom in-place

### New Axioms
- None. The entire point of this task is axiom elimination.

### Remaining Debt
After this implementation:
- 0 axioms in irreflexivity module
- Downstream theorems (`canonicalR_antisymmetric_strict`, `canonicalR_strict`) become axiom-free

## Implementation Phases

### Phase 1: Type Fixes in CanonicalIrreflexivity.lean [NOT STARTED]

- **Dependencies:** None
- **Goal:** Convert all String parameters to Atom type

**Tasks:**
- [ ] Change `atomFreeSubset (M : Set Formula) (p : String)` to `(p : Atom)`
- [ ] Change `namingSet (M : Set Formula) (p : String)` to `(p : Atom)`
- [ ] Change `atomFreeSubset_subset` type signature
- [ ] Change `atoms_imp_not_mem` type signature (String -> Atom)
- [ ] Change `not_mem_atoms_bot` type signature
- [ ] Update `Finset_String_not_univ` to use `Atom.exists_fresh` or delete if unused
- [ ] Change `exists_fresh_for_finite_list` to return Atom
- [ ] Change `not_mem_atoms_iterated_imp` type signature
- [ ] Update all `Formula.atom p` occurrences (p is now Atom, Formula.atom expects Atom)
- [ ] Fix any remaining type errors from String -> Atom conversion
- [ ] Verify `lake build` for this file (sorries still present, but no type errors)

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Convert String to Atom throughout

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.CanonicalIrreflexivity` succeeds (with 2 sorry warnings)
- No type errors related to String/Atom mismatch

---

### Phase 2: Atoms Finiteness Infrastructure [NOT STARTED]

- **Dependencies:** Phase 1
- **Goal:** Prove that GContent(M) has finitely many atoms

**Tasks:**
- [ ] Define `Formula.atoms` finiteness (already exists in Formula.lean, verify)
- [ ] Add lemma: for any single formula, `phi.atoms` is finite (Finset)
- [ ] Add lemma: for finite list of formulas, union of atoms is finite
- [ ] Add helper to collect atoms from a Finset of formulas
- [ ] Add lemma: if we have finitely many G-formulas in M contributing to GContent, atoms are finite
- [ ] Consider: may not need full GContent finiteness if proof uses fresh atom for specific finite subset
- [ ] If proof needs only local finiteness (atoms in formulas mentioned in proof), simplify

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Add finiteness helper lemmas

**Verification:**
- New lemmas compile with no errors
- Lemmas usable in Phase 3 sorry resolution

---

### Phase 3: Complete the 2 Sorries [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2
- **Goal:** Resolve both sorries using `Atom.exists_fresh`

**Tasks:**
- [ ] Analyze sorry at line 1273: identify what fresh atom enables
- [ ] For line 1273: collect relevant atoms, apply `Atom.exists_fresh`, complete proof
- [ ] Analyze sorry at line 1356: understand contradiction derivation
- [ ] For line 1356: use fresh atom to ensure `atomFreeSubset M p = M` for relevant formulas
- [ ] The key insight: with fresh p, neg(atom p) is in atomFreeSubset M p, hence in M'
- [ ] Complete proof: atom p in M' (naming set) AND neg(atom p) in M' (from freshness) -> contradiction
- [ ] Remove both `sorry` keywords
- [ ] Verify proof compiles and `lake build` passes with no sorries

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Complete sorries

**Verification:**
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` returns empty
- `lake build Bimodal.Metalogic.Bundle.CanonicalIrreflexivity` passes with no warnings
- Proof verified with `lean_goal` showing "no goals"

**Escape Valve:**
- If proof blocked after substantial effort (>3 hours), mark [BLOCKED] with requires_user_review
- Document exactly which step fails and why

---

### Phase 4: Axiom Removal and Verification [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Delete axiom and verify full build

**Tasks:**
- [ ] In `CanonicalIrreflexivityAxiom.lean`: delete `axiom canonicalR_irreflexive`
- [ ] Keep the theorem `canonicalR_irreflexive` (now provable, import from CanonicalIrreflexivity.lean)
- [ ] Update imports if needed: axiom file may import proof file or vice versa
- [ ] Update docstrings to reflect axiom -> theorem transition
- [ ] Run full `lake build` to verify no downstream breakage
- [ ] Verify `canonicalR_antisymmetric_strict` and `canonicalR_strict` still work

**Timing:** 0.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` - Delete axiom, adjust imports
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` - Export theorem if needed

**Verification:**
- `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` returns empty
- `lake build` passes with no errors
- All downstream uses of `canonicalR_irreflexive` still compile

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` returns empty (zero-debt gate)
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` shows no axioms
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Downstream theorems `canonicalR_antisymmetric_strict`, `canonicalR_strict` compile
- [ ] No regression in other modules importing these files

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-YYYYMMDD.md` (after completion)
- Modified Lean files with completed proofs and deleted axiom

## Rollback/Contingency

If proof cannot be completed:
1. Revert all changes to `CanonicalIrreflexivity.lean`
2. Keep axiom in place
3. Mark task [BLOCKED] with analysis of why proof strategy fails
4. User review required to determine next steps

If partial progress:
1. Commit type fixes (Phase 1) separately
2. Commit finiteness infrastructure (Phase 2) separately
3. Mark Phase 3 [PARTIAL] with clear resume point
