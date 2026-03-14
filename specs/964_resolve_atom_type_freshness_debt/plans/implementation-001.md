# Implementation Plan: Resolve Atom Type Freshness Debt

- **Task**: 964 - resolve_atom_type_freshness_debt
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None
- **Research Inputs**: specs/964_resolve_atom_type_freshness_debt/reports/research-001.md, research-002.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This implementation changes the atom type from `String` to a structured `Atom` type that supports freshness, enabling the proof of `canonicalR_irreflexive` as a theorem rather than an axiom. The structured atom type provides infinitely many fresh atoms via an optional natural number index, while preserving backward compatibility through base string atoms.

### Research Integration

- **research-001.md**: Identified the freshness requirement and recommended Option A (structured Atom type)
- **research-002.md**: Provided deep analysis of Mathlib infrastructure (`Infinite.exists_notMem_finset`), existing codebase patterns (`ConservativeExtension/ExtFormula.lean`), and detailed refactoring scope (31 files, ~980 lines)

## Goals & Non-Goals

**Goals**:
- Define `structure Atom` with `base : String` and `fresh_index : Option Nat`
- Prove `Infinite Atom` and `Countable Atom` instances
- Update `Formula.lean` to use `Atom` instead of `String`
- Refactor all pattern matching and atom references throughout codebase
- Complete the `canonicalR_irreflexive` proof using `Infinite.exists_notMem_finset`
- Remove the axiom declaration, replacing it with a theorem
- Verify all downstream theorems compile without sorries

**Non-Goals**:
- Changing the fundamental proof structure (Gabbay IRR contrapositive is already implemented)
- Adding notation macros for atoms (can be done in a follow-up task)
- Refactoring ConservativeExtension to use the new Atom type (orthogonal work)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Large refactoring scope (31 files) | H | M | Incremental phases with `lake build` after each; commit at checkpoints |
| Pattern matching changes cause subtle type errors | M | M | Use `lean_goal` to inspect state at each update |
| Infinite/Countable instances fail to derive | M | L | research-002.md provides explicit proof patterns; Mathlib has many examples |
| ConservativeExtension compatibility issues | M | L | Keep it unchanged; ExtAtom remains independent |
| Proof of canonicalR_irreflexive blocked by other issues | H | L | Mark [BLOCKED] with user review if stuck; research identified path |

## Sorry Characterization

### Pre-existing Sorries
- 2 sorries in `Bundle/CanonicalIrreflexivity.lean` at lines 1273, 1356 (blocked by String atoms)

### Expected Resolution
- Phase 6 resolves both sorries by using `Infinite.exists_notMem_finset` to obtain fresh atoms

### New Sorries
- None. NEVER introduce new sorries. If proof cannot be completed:
  - Mark phase [BLOCKED] with requires_user_review: true
  - User decides: revise plan, split task, or change approach
  - DO NOT use sorry and mark task complete

### Remaining Debt
After this implementation:
- 0 sorries expected in `CanonicalIrreflexivity.lean`
- 0 axioms in the canonicalR irreflexivity module
- Downstream theorems (NoMaxOrder, NoMinOrder, DenselyOrdered) fully proven

## Axiom Characterization

### Pre-existing Axioms
- 1 axiom in `Canonical/CanonicalIrreflexivityAxiom.lean`: `canonicalR_irreflexive`

### Expected Resolution
- Phase 7 eliminates axiom by replacing it with a theorem using the freshness property
- Structural proof approach: `Infinite.exists_notMem_finset` provides fresh atoms for Gabbay IRR

### New Axioms
- None. NEVER introduce new axioms.

### Remaining Debt
After this implementation:
- 0 axioms in canonicalR irreflexivity module
- Downstream theorems (NoMaxOrder, NoMinOrder, DenselyOrdered) no longer inherit axiom dependency
- Publication no longer blocked by this axiom

## Implementation Phases

### Phase 1: Define Atom Type [COMPLETED]

- **Dependencies:** None
- **Goal:** Create the structured Atom type with all required instances

**Tasks:**
- [ ] Create `Theories/Bimodal/Syntax/Atom.lean`
- [ ] Define `structure Atom where base : String; fresh_index : Option Nat`
- [ ] Add `deriving Repr, DecidableEq, BEq, Hashable`
- [ ] Prove `instance : Countable Atom` using injection into `String x Option Nat`
- [ ] Prove `instance : Infinite Atom` using injection from `Nat`
- [ ] Add helper functions: `Atom.mk_base`, `Atom.mk_fresh`
- [ ] Add convenience theorem: `Atom.exists_fresh : forall (S : Finset Atom), exists a, a notin S`
- [ ] Run `lake build Bimodal.Syntax.Atom` to verify

**Timing:** 1.5 hours

**Files to create:**
- `Theories/Bimodal/Syntax/Atom.lean` - new file

**Verification:**
- `lake build Bimodal.Syntax.Atom` succeeds
- `grep -n "\bsorry\b" Theories/Bimodal/Syntax/Atom.lean` returns empty

---

### Phase 2: Update Formula.lean [COMPLETED]

- **Dependencies:** Phase 1
- **Goal:** Change Formula to use Atom instead of String

**Tasks:**
- [ ] Import `Bimodal.Syntax.Atom` in `Formula.lean`
- [ ] Change `| atom : String -> Formula` to `| atom : Atom -> Formula`
- [ ] Update `Formula.atoms : Formula -> Finset String` to `Formula.atoms : Formula -> Finset Atom`
- [ ] Update pattern matching in `atoms` function
- [ ] Add backward-compatibility helper: `def atom_s (s : String) := atom (Atom.mk_base s)`
- [ ] Update all theorem proofs that reference `atom` constructor
- [ ] Run `lake build Bimodal.Syntax.Formula` to verify

**Timing:** 2 hours

**Files to modify:**
- `Theories/Bimodal/Syntax/Formula.lean` - change atom type

**Verification:**
- `lake build Bimodal.Syntax.Formula` succeeds
- `grep -n "\bsorry\b" Theories/Bimodal/Syntax/Formula.lean` returns empty

---

### Phase 3: Update Core Syntax Files [COMPLETED]

- **Dependencies:** Phase 2
- **Goal:** Update Subformulas.lean, SubformulaClosure.lean, and related files

**Tasks:**
- [ ] Update `Theories/Bimodal/Syntax/Subformulas.lean` - atom pattern matching
- [ ] Update `Theories/Bimodal/Syntax/SubformulaClosure.lean` - atom handling
- [ ] Update any other files in Syntax/ that reference atoms
- [ ] Run `lake build Bimodal.Syntax` to verify all syntax modules

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Syntax/Subformulas.lean`
- `Theories/Bimodal/Syntax/SubformulaClosure.lean`

**Verification:**
- `lake build Bimodal.Syntax` succeeds
- No sorries in modified files

---

### Phase 4: Update Semantics [COMPLETED]

- **Dependencies:** Phase 3
- **Goal:** Update semantic modules to use Atom type

**Tasks:**
- [ ] Update `Theories/Bimodal/Semantics/TaskModel.lean`:
  - Change `valuation : WorldState -> String -> Prop` to `valuation : WorldState -> Atom -> Prop`
- [ ] Update `Theories/Bimodal/Semantics/Truth.lean`:
  - Update atom case in `truth_at` pattern matching
- [ ] Update `Theories/Bimodal/Semantics/Validity.lean` if needed
- [ ] Run `lake build Bimodal.Semantics` to verify

**Timing:** 1.5 hours

**Files to modify:**
- `Theories/Bimodal/Semantics/TaskModel.lean`
- `Theories/Bimodal/Semantics/Truth.lean`
- `Theories/Bimodal/Semantics/Validity.lean`

**Verification:**
- `lake build Bimodal.Semantics` succeeds
- No sorries in modified files

---

### Phase 5: Update Proof System and Examples [COMPLETED]

- **Dependencies:** Phase 4
- **Goal:** Update proof system modules and example files

**Tasks:**
- [ ] Update `Theories/Bimodal/ProofSystem/Derivation.lean`:
  - IRR rule freshness condition uses `Finset Atom`
- [ ] Update `Theories/Bimodal/ProofSystem/Axioms.lean` if needed
- [ ] Update all example files in `Theories/Bimodal/Examples/`:
  - Change `Formula.atom "p"` to `Formula.atom (Atom.mk_base "p")` or use `atom_s "p"`
- [ ] Run `lake build Bimodal.ProofSystem` and `lake build Bimodal.Examples` to verify

**Timing:** 2.5 hours

**Files to modify:**
- `Theories/Bimodal/ProofSystem/Derivation.lean`
- `Theories/Bimodal/ProofSystem/Axioms.lean`
- `Theories/Bimodal/Examples/*.lean` (multiple files)

**Verification:**
- `lake build Bimodal.ProofSystem` succeeds
- `lake build Bimodal.Examples` succeeds
- No sorries in modified files

---

### Phase 6: Complete CanonicalIrreflexivity Proof [IN PROGRESS]

- **Dependencies:** Phase 5
- **Goal:** Complete the sorried proof using freshness

**Tasks:**
- [ ] Open `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`
- [ ] Locate the 2 sorries (lines 1273, 1356 per research)
- [ ] Replace `Finset_String_not_univ` assumption with `Atom.exists_fresh`
- [ ] Use `Infinite.exists_notMem_finset` to obtain fresh atom for `GContent(M)`
- [ ] Complete the Gabbay IRR contrapositive argument
- [ ] Run `lake build` to verify no errors
- [ ] Grep for sorries to confirm resolution

**Timing:** 2.5 hours

**Files to modify:**
- `Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Bundle.CanonicalIrreflexivity` succeeds
- `grep -n "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` returns empty

---

### Phase 7: Replace Axiom with Theorem [NOT STARTED]

- **Dependencies:** Phase 6
- **Goal:** Remove the axiom declaration and export as theorem

**Tasks:**
- [ ] In `Canonical/CanonicalIrreflexivityAxiom.lean`:
  - Remove `axiom canonicalR_irreflexive`
  - Replace with `theorem canonicalR_irreflexive` using the proof from Phase 6
  - Or import the theorem from the completed proof module
- [ ] Update any imports that depend on the axiom location
- [ ] Verify all downstream theorems still compile:
  - `canonicalR_strict`
  - `canonicalR_antisymmetric_strict`
- [ ] Run `lake build` on full metalogic module

**Timing:** 1 hour

**Files to modify:**
- `Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean`

**Verification:**
- `lake build Bimodal.Metalogic.Canonical` succeeds
- `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` returns empty
- Downstream theorems compile without changes

---

### Phase 8: Final Verification and Cleanup [NOT STARTED]

- **Dependencies:** Phase 7
- **Goal:** Verify entire codebase builds and all downstream theorems are proven

**Tasks:**
- [ ] Run `lake build` on entire project
- [ ] Verify downstream theorems are fully proven (no sorries):
  - `NoMaxOrder` on dense timeline quotient
  - `NoMinOrder` on dense timeline quotient
  - `DenselyOrdered` on dense timeline quotient
  - `NoMaxOrder` on discrete timeline
  - `NoMinOrder` on discrete timeline
- [ ] Run comprehensive sorry check: `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/`
- [ ] Run comprehensive axiom check: `grep -rn "^axiom " Theories/Bimodal/Metalogic/`
- [ ] Clean up any TODOs or temporary comments

**Timing:** 1.5 hours

**Files to verify:**
- `Theories/Bimodal/Metalogic/StagedConstruction/CantorApplication.lean` (NoMaxOrder, NoMinOrder, DenselyOrdered)
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (NoMaxOrder, NoMinOrder)

**Verification:**
- `lake build` succeeds with no errors
- `grep -rn "\bsorry\b" Theories/Bimodal/` shows no new sorries
- `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` returns empty
- All downstream theorems verified by `lean_goal` at their declaration sites

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Syntax/Atom.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Bundle/CanonicalIrreflexivity.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Canonical/CanonicalIrreflexivityAxiom.lean` returns empty
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] Each phase commits successfully before proceeding to next
- [ ] No regressions in existing functionality
- [ ] ConservativeExtension module unchanged and still compiles

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (upon completion)
- Modified files across 31+ locations (syntax, semantics, proof system, metalogic, examples)

## Rollback/Contingency

- Each phase creates a git commit; rollback via `git revert` to any checkpoint
- If Phase 6 proof is blocked:
  - Mark [BLOCKED] with `requires_user_review: true`
  - User may revise approach (e.g., alternative atom type, skip to Nat x Nat)
- If scope expands significantly, split into sub-tasks:
  - Task A: Atom type and core syntax changes
  - Task B: Metalogic completion and axiom removal
