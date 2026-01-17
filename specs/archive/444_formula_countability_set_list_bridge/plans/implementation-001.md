# Implementation Plan: Task #444

- **Task**: 444 - Formula Countability and Set-List Bridge
- **Status**: [COMPLETED]
- **Effort**: 6-8 hours
- **Priority**: Low
- **Dependencies**: None (first phase of Task 257)
- **Research Inputs**: specs/444_formula_countability_set_list_bridge/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task establishes the foundation for completeness proofs by adding Formula countability and refactoring the canonical model construction from list-based to set-based contexts. The research identified that the list-based `lindenbaum` theorem is fundamentally unprovable because maximal consistent sets are infinite while lists are finite. The solution is to refactor `CanonicalWorldState` and related definitions to use `Set Formula` throughout, leveraging the already-proven `set_lindenbaum` theorem.

### Research Integration

Key findings from research-001.md integrated into this plan:
- `Countable Formula` can be derived after providing `Countable Char` and `Countable String` instances
- The list-based `lindenbaum` cannot be proven as maximal consistent sets are infinite
- `set_lindenbaum` is already proven using Zorn's lemma (lines 342-391 of Completeness.lean)
- Recommended approach: Refactor to use `Set Formula` throughout canonical model construction

## Goals & Non-Goals

**Goals**:
- Add `Countable Formula` instance via `deriving Countable`
- Provide prerequisite instances: `Countable Char`, `Countable String`
- Refactor `CanonicalWorldState` from `{Γ : Context // MaximalConsistent Γ}` to `{S : Set Formula // SetMaximalConsistent S}`
- Update `canonical_valuation`, `canonical_task_rel`, `truth_lemma` signatures for set-based types
- Remove the unprovable list-based `lindenbaum` theorem (keep `set_lindenbaum`)
- Ensure all axioms and theorem signatures are internally consistent

**Non-Goals**:
- Proving the axioms (they remain as axioms for now)
- Full implementation of the truth lemma (separate task)
- Removing list-based `Consistent` and `MaximalConsistent` definitions (they may be useful for finite reasoning)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `deriving Countable` fails for Formula | Medium | Low | Fall back to manual construction via `instCountableSigma` pattern |
| Refactoring breaks downstream imports | Medium | Low | Only Completeness.lean uses these types; check for other importers |
| Set-based signatures harder to work with | Low | Medium | Sets are mathematically correct; better foundation for future proofs |
| Missing Mathlib imports | Low | Low | Verify imports via lean_diagnostic_messages after edits |

## Implementation Phases

### Phase 1: Add Countability Instances [COMPLETED]

**Goal**: Establish `Countable Formula` instance with all prerequisites.

**Tasks**:
- [ ] Add `import Mathlib.Tactic.DeriveCountable` to Syntax/Formula.lean
- [ ] Add `import Mathlib.Data.Countable.Basic` to Syntax/Formula.lean
- [ ] Add `Countable Char` instance using `Char.toNat` injection
- [ ] Add `Countable String` instance using `String.toList` injection
- [ ] Add `deriving Countable` to Formula inductive definition
- [ ] Verify no compilation errors with lean_diagnostic_messages

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Syntax/Formula.lean` - Add imports and countability instances

**Verification**:
- `lake build Bimodal.Syntax.Formula` succeeds
- No errors in lean_diagnostic_messages

---

### Phase 2: Create Set-Based CanonicalWorldState [COMPLETED]

**Goal**: Refactor CanonicalWorldState to use SetMaximalConsistent instead of MaximalConsistent.

**Tasks**:
- [ ] Modify `CanonicalWorldState` definition from `{Γ : Context // MaximalConsistent Γ}` to `{S : Set Formula // SetMaximalConsistent S}`
- [ ] Update documentation to reflect the set-based approach
- [ ] Verify the type change compiles

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Line 478

**Verification**:
- Type definition compiles without errors

---

### Phase 3: Update Canonical Valuation Signature [COMPLETED]

**Goal**: Update canonical_valuation to work with set-based world states.

**Tasks**:
- [ ] Update `canonical_valuation` axiom signature: change `CanonicalWorldState → String → Bool` to work with sets
- [ ] Update the docstring to reflect set-based semantics: `canonical_val S p ↔ (Formula.atom p) ∈ S.val`
- [ ] Verify axiom compiles

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Lines 536-542

**Verification**:
- Axiom compiles without errors

---

### Phase 4: Update Task Relation and Frame [COMPLETED]

**Goal**: Update canonical_task_rel to use set-based CanonicalWorldState.

**Tasks**:
- [ ] Update `canonical_task_rel` axiom signature to use new `CanonicalWorldState` type
- [ ] Update documentation explaining the modal/temporal transfer properties
- [ ] Verify `canonical_frame` axiom remains consistent with changes

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Lines 488-524

**Verification**:
- All related axioms compile without errors

---

### Phase 5: Update Truth Lemma and History [COMPLETED]

**Goal**: Update truth_lemma and canonical_history signatures for set-based world states.

**Tasks**:
- [ ] Update `canonical_history` axiom signature to take set-based `CanonicalWorldState`
- [ ] Update `truth_lemma` axiom signature: change `Γ.val` references to work with `S.val` (set membership)
- [ ] Update associated documentation

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Lines 560-605

**Verification**:
- All axioms compile without errors
- Documentation accurately reflects set-based semantics

---

### Phase 6: Remove Unprovable Lindenbaum and Final Cleanup [COMPLETED]

**Goal**: Remove the unprovable list-based lindenbaum theorem and ensure file consistency.

**Tasks**:
- [ ] Delete the `lindenbaum` theorem (lines 413-424) that has `sorry`
- [ ] Update module docstring to remove reference to list-based lindenbaum
- [ ] Update "Main Results" section to reference `set_lindenbaum` only
- [ ] Verify `provable_iff_valid` theorem still compiles (it uses `weak_completeness` axiom)
- [ ] Run full `lake build` to verify no regressions

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Completeness.lean` - Multiple sections

**Verification**:
- `lake build Bimodal.Metalogic.Completeness` succeeds
- No `sorry` statements remain except in `provable_iff_valid` (which is expected)
- All axioms have consistent signatures

---

### Phase 7: Documentation Update [COMPLETED]

**Goal**: Update ARCHITECTURE.md documentation to reflect the set-based canonical model.

**Tasks**:
- [ ] Update canonical model documentation in `Theories/Bimodal/docs/user-guide/ARCHITECTURE.md`
- [ ] Update code examples showing set-based world states
- [ ] Ensure truth_lemma documentation matches implementation

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/docs/user-guide/ARCHITECTURE.md` - Canonical model sections (lines 606-811)

**Verification**:
- Documentation accurately reflects the implemented types
- Code examples are consistent with actual signatures

## Testing & Validation

- [ ] `lake build Bimodal.Syntax.Formula` succeeds after Phase 1
- [ ] `lake build Bimodal.Metalogic.Completeness` succeeds after Phase 6
- [ ] No new `sorry` statements introduced (existing ones in axioms expected)
- [ ] `lean_diagnostic_messages` shows no errors for modified files
- [ ] Grep for `MaximalConsistent Γ` confirms no remaining list-based canonical world state usages
- [ ] Grep for `lindenbaum` confirms only `set_lindenbaum` remains

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/Formula.lean` - Updated with Countable instances
- `Theories/Bimodal/Metalogic/Completeness.lean` - Refactored to set-based canonical model
- `Theories/Bimodal/docs/user-guide/ARCHITECTURE.md` - Updated documentation
- `specs/444_formula_countability_set_list_bridge/summaries/implementation-summary-YYYYMMDD.md` - Completion summary

## Rollback/Contingency

If the refactoring causes unforeseen issues:
1. Git revert to pre-implementation commit
2. Consider alternative: Keep list-based definitions but add separate set-based completeness module
3. If `deriving Countable` fails, implement manually using `Countable.of_equiv` or `instCountableSigma`

The changes are localized to three files, making rollback straightforward. The `set_lindenbaum` theorem is already proven and will not be affected by rollback.
