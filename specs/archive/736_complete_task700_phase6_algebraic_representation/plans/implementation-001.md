# Implementation Plan: Task #736

- **Task**: 736 - Complete phase 6 of task 700: Algebraic Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Priority**: Medium
- **Dependencies**: Task 700 phases 1-5 (completed)
- **Research Inputs**: specs/736_complete_task700_phase6_algebraic_representation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Complete the final phase of the algebraic representation theorem by filling in two `sorry` placeholders: `consistent_implies_satisfiable` in `AlgebraicRepresentation.lean` and `mcs_ultrafilter_correspondence` in `UltrafilterMCS.lean`. The approach uses existing MCS infrastructure: for the first proof, leverage `set_lindenbaum` to extend a consistent singleton to an MCS, then construct an ultrafilter from it; for the bijection, define `mcsToUltrafilter` using helper lemmas about `mcsToSet` preserving ultrafilter properties.

### Research Integration

Key findings from research-001.md integrated into this plan:
- Custom `Ultrafilter` structure already defined in `UltrafilterMCS.lean` (Boolean algebra ultrafilter, not Mathlib's filter-theoretic version)
- `ultrafilterToSet_mcs` already proven: converts ultrafilter to MCS
- `set_lindenbaum`, `theorem_in_mcs`, `maximal_negation_complete` available via re-exports
- `fold_le_of_derives` lemma available for relating derivations to quotient ordering

## Goals and Non-Goals

**Goals**:
- Prove `consistent_implies_satisfiable`: If formula is consistent, there exists an ultrafilter containing its equivalence class
- Complete `mcs_ultrafilter_correspondence`: Establish bijection between MCS and ultrafilters via `mcsToUltrafilter` and `ultrafilterToSet`
- Ensure `algebraic_representation_theorem` compiles without `sorry`

**Non-Goals**:
- Modifying the `Ultrafilter` structure definition
- Changing the existing `ultrafilterToSet_mcs` proof
- General Mathlib ultrafilter integration (custom structure is appropriate)

## Risks and Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Quotient reasoning complexity | Medium | Medium | Use `Quotient.ind`, `Quotient.sound` systematically; leverage existing patterns in file |
| MCS property proofs require derivation theory | Medium | Low | Leverage existing `maximal_negation_complete`, `theorem_in_mcs`, `maximal_consistent_closed` |
| Set equality proofs tedious | Low | Medium | Use `Set.ext` and membership reasoning; many patterns exist in `ultrafilterToSet_mcs` |

## Implementation Phases

### Phase 1: MCS-to-Ultrafilter Helper Lemmas [COMPLETED]

**Goal**: Prove that `mcsToSet` preserves all ultrafilter properties when applied to an MCS.

**Tasks**:
- [ ] Prove `mcsToSet_bot_not_mem`: `⊥ ∉ mcsToSet Γ` for MCS Γ (from MCS consistency: Formula.bot not in consistent set)
- [ ] Prove `mcsToSet_mem_of_le`: If `a ∈ mcsToSet Γ` and `a ≤ b`, then `b ∈ mcsToSet Γ` (from deductive closure: `a ≤ b` means derivability, and MCS is closed under derivation)
- [ ] Prove `mcsToSet_inf_mem`: If `a, b ∈ mcsToSet Γ`, then `a ⊓ b ∈ mcsToSet Γ` (from closure under conjunction)
- [ ] Prove `mcsToSet_compl_or`: For all `a`, either `a ∈ mcsToSet Γ` or `aᶜ ∈ mcsToSet Γ` (from `maximal_negation_complete`)
- [ ] Prove `mcsToSet_compl_not`: If `a ∈ mcsToSet Γ`, then `aᶜ ∉ mcsToSet Γ` (from MCS consistency: cannot have both formula and negation)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - Add helper lemmas after `mcsToSet_top`

**Verification**:
- Each lemma compiles without `sorry`
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterMCS` succeeds

---

### Phase 2: Define mcsToUltrafilter [COMPLETED]

**Goal**: Construct the `mcsToUltrafilter` function using the helper lemmas.

**Tasks**:
- [ ] Define `mcsToUltrafilter : {Γ : Set Formula // SetMaximalConsistent Γ} -> Ultrafilter LindenbaumAlg`
- [ ] Use `mcsToSet Γ.val` as carrier
- [ ] Plug in the five helper lemmas for the five ultrafilter properties
- [ ] Add basic accessor lemmas (e.g., `mcsToUltrafilter_carrier`, `mem_mcsToUltrafilter_iff`)

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - Add definition after helper lemmas

**Verification**:
- Definition compiles without `sorry`
- `lean_goal` confirms structure fields satisfied

---

### Phase 3: Complete Bijection Proof [COMPLETED]

**Goal**: Fill in `mcs_ultrafilter_correspondence` using `mcsToUltrafilter` and `ultrafilterToSet`.

**Tasks**:
- [ ] Define `f := fun Gamma => mcsToUltrafilter Gamma`
- [ ] Define `g := fun U => Subtype.mk (ultrafilterToSet U) (ultrafilterToSet_mcs U)`
- [ ] Prove `Function.LeftInverse g f`: Show `ultrafilterToSet (mcsToUltrafilter Gamma) = Gamma.val` using set extensionality and quotient properties
- [ ] Prove `Function.RightInverse g f`: Show `mcsToUltrafilter (g U) = U` by proving carrier equality using `Set.ext`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean` - Replace `sorry` in `mcs_ultrafilter_correspondence`

**Verification**:
- `mcs_ultrafilter_correspondence` compiles without `sorry`
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterMCS` succeeds

---

### Phase 4: Complete consistent_implies_satisfiable [COMPLETED]

**Goal**: Fill in the `sorry` in `consistent_implies_satisfiable` using the MCS-ultrafilter machinery.

**Tasks**:
- [ ] Use hypothesis `h : AlgConsistent phi` (i.e., `not Nonempty (deriv [] phi.neg)`)
- [ ] Show `{phi}` is consistent: If `deriv [] phi.neg`, then `phi.neg` is a theorem, but we have `not deriv [] phi.neg`
- [ ] Apply `set_lindenbaum {phi} h_cons` to get MCS `Gamma` containing `phi`
- [ ] Apply `mcsToUltrafilter` to `Gamma` to get ultrafilter `U`
- [ ] Show `toQuot phi in U.carrier` from `phi in Gamma` and definition of `mcsToSet`
- [ ] Witness `AlgSatisfiable phi` with `U`

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean` - Replace `sorry` in `consistent_implies_satisfiable`

**Verification**:
- `consistent_implies_satisfiable` compiles without `sorry`
- `algebraic_representation_theorem` compiles without `sorry`
- `lake build Bimodal.Metalogic.Algebraic.AlgebraicRepresentation` succeeds

## Testing and Validation

- [ ] `lake build` passes with no errors in algebraic modules
- [ ] No remaining `sorry` in `AlgebraicRepresentation.lean`
- [ ] No remaining `sorry` in `UltrafilterMCS.lean` (the target theorems)
- [ ] `algebraic_representation_theorem` can be applied in downstream proofs (if any)

## Artifacts and Outputs

- `specs/736_complete_task700_phase6_algebraic_representation/plans/implementation-001.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterMCS.lean`
- Modified: `Theories/Bimodal/Metalogic/Algebraic/AlgebraicRepresentation.lean`
- `specs/736_complete_task700_phase6_algebraic_representation/summaries/implementation-summary-YYYYMMDD.md` (on completion)

## Rollback/Contingency

If implementation reveals missing prerequisites:
1. Revert changes with `git checkout -- Theories/Bimodal/Metalogic/Algebraic/`
2. Document missing lemmas in error report
3. Create follow-up task for the prerequisites

If quotient reasoning proves too complex:
1. Focus on `consistent_implies_satisfiable` first (direct use of `set_lindenbaum`)
2. Leave bijection proof as follow-up task if needed
