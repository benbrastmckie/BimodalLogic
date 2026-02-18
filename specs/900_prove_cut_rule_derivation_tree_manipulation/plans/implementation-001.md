# Implementation Plan: Task #900

- **Task**: 900 - Prove cut rule / derivation tree manipulation for RecursiveSeed consistency
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Task 864 (parent task, Phase 4)
- **Research Inputs**: specs/900_prove_cut_rule_derivation_tree_manipulation/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task resolves 22 sorries in `RecursiveSeed.lean` (lines ~7000-7250) related to consistency preservation in the worklist algorithm. The "cut rule" mentioned in the parent task's plan refers to derivation composition via the deduction theorem - infrastructure that already exists in the codebase (`imp_trans`, `double_negation`, deduction theorem). The implementation applies these existing tools systematically to prove subformula consistency lemmas, then uses those lemmas to complete the `processWorkItem` cases.

### Research Integration

From research-001.md:
- The deduction theorem infrastructure exists in `DeductionTheorem.lean`
- `imp_trans` (implication chaining) exists in `Combinators.lean`
- `double_negation` (DNE) exists in `Propositional.lean`
- T-axiom and necessitation rules exist in `Axioms.lean` and `Derivation.lean`
- Proof patterns for all 6 subformula consistency lemmas are sketched in the research report

## Goals & Non-Goals

**Goals**:
- Resolve all 22 sorries in RecursiveSeed.lean Phase 4 (consistency proofs)
- Prove 6 subformula consistency lemmas using T-axiom and derivation composition
- Complete `processWorkItem_preserves_consistent` cases using subformula lemmas
- Complete `processWorkItem_newWork_consistent` cases using subformula lemmas
- Build succeeds with no new sorries or axioms

**Non-Goals**:
- Modifying the worklist algorithm structure
- Adding new axioms (only use existing proof infrastructure)
- Proving Phase 5 closure properties (separate concern)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Propositional helpers insufficient | High | Low | Research confirms `imp_trans`, `double_negation` exist; may need small wrapper lemmas |
| Complex case analysis in processWorkItem | Medium | Medium | Follow pattern established in first case, leverage existing `addFormula_seed_preserves_consistent` |
| classifyFormula extraction needed | Medium | Medium | May need lemmas proving `classifyFormula item.formula = boxPositive psi -> item.formula = Box psi` |

## Sorry Characterization

### Pre-existing Sorries
- 22 sorries in `RecursiveSeed.lean` at lines 7018-7170:
  - 6 subformula consistency lemmas (box, future, past, neg_box, neg_future, neg_past)
  - 10 `processWorkItem_preserves_consistent` cases
  - 6 `processWorkItem_newWork_consistent` cases

### Expected Resolution
- Phase 1: Resolve 3 positive modal/temporal subformula lemmas via T-axiom + imp_trans
- Phase 2: Resolve 3 negative modal/temporal subformula lemmas via necessitation + DNE
- Phase 3: Resolve 10 processWorkItem cases using subformula lemmas
- Phase 4: Resolve 6 processWorkItem_newWork cases using subformula lemmas

### New Sorries
- None expected. All proofs use existing infrastructure.

### Remaining Debt
After this implementation:
- 0 sorries in RecursiveSeed.lean Phase 4 section
- Phase 5 (closure properties) sorries remain separate

## Implementation Phases

### Phase 1: Positive Subformula Consistency Lemmas [NOT STARTED]

- **Dependencies:** None
- **Goal:** Prove `box_inner_consistent`, `all_future_inner_consistent`, `all_past_inner_consistent`

**Tasks**:
- [ ] Prove `box_inner_consistent` using T-axiom and `imp_trans`:
  - If `[psi] |- bot`, apply deduction theorem to get `[] |- psi -> bot`
  - T-axiom gives `[] |- Box psi -> psi`
  - Chain via `imp_trans`: `[] |- Box psi -> bot`
  - Derive `[Box psi] |- bot` contradicting hypothesis
- [ ] Prove `all_future_inner_consistent` (same pattern with `Axiom.temp_t_future`)
- [ ] Prove `all_past_inner_consistent` (same pattern with `Axiom.temp_t_past`)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (lines 7018-7038)

**Proof Sketch for `box_inner_consistent`**:
```lean
theorem box_inner_consistent (psi : Formula) (h : FormulaConsistent (Formula.box psi)) :
    FormulaConsistent psi := by
  intro h_incons  -- Assume [psi] |- bot
  apply h         -- Show [Box psi] |- bot contradicts h
  -- 1. Get psi -> bot from deduction theorem
  have h_psi_bot : ⊢ psi.imp Formula.bot :=
    deduction_theorem [] psi Formula.bot h_incons.choose
  -- 2. T-axiom: Box psi -> psi
  have h_t : ⊢ (Formula.box psi).imp psi :=
    DerivationTree.axiom [] _ (Axiom.modal_t psi)
  -- 3. Chain: Box psi -> psi -> bot
  have h_chain : ⊢ (Formula.box psi).imp Formula.bot :=
    imp_trans h_t h_psi_bot
  -- 4. Apply modus ponens with weakened h_chain
  constructor
  exact DerivationTree.modus_ponens [Formula.box psi] _ _
    (DerivationTree.weakening [] _ _ h_chain (List.nil_subset _))
    (DerivationTree.assumption _ _ (by simp))
```

**Verification**:
- `lake build` succeeds
- Lines 7018-7038 have no sorries

---

### Phase 2: Negative Subformula Consistency Lemmas [NOT STARTED]

- **Dependencies:** Phase 1 (uses similar techniques)
- **Goal:** Prove `neg_box_neg_inner_consistent`, `neg_future_neg_inner_consistent`, `neg_past_neg_inner_consistent`

**Tasks**:
- [ ] Prove `neg_box_neg_inner_consistent`:
  - If `neg psi` inconsistent, then `[neg psi] |- bot`
  - Deduction theorem: `[] |- neg psi -> bot` = `[] |- neg(neg psi)`
  - DNE: `[] |- psi`
  - Necessitation: `[] |- Box psi`
  - Theorem is consistent with anything, but `neg(Box psi) + Box psi |- bot`
- [ ] Prove `neg_future_neg_inner_consistent` (same pattern with temporal necessitation)
- [ ] Prove `neg_past_neg_inner_consistent` (same pattern with temporal duality)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (lines 7048-7064)

**Proof Sketch for `neg_box_neg_inner_consistent`**:
```lean
theorem neg_box_neg_inner_consistent (psi : Formula)
    (h : FormulaConsistent (Formula.neg (Formula.box psi))) :
    FormulaConsistent (Formula.neg psi) := by
  intro h_incons  -- Assume [neg psi] |- bot
  apply h         -- Show [neg(Box psi)] |- bot contradicts h
  -- 1. neg psi inconsistent means [neg psi] |- bot
  -- 2. Deduction theorem: |- neg psi -> bot = |- neg(neg psi)
  have h_neg_neg : ⊢ psi.neg.neg :=
    deduction_theorem [] psi.neg Formula.bot h_incons.choose
  -- 3. DNE: |- psi
  have h_psi : ⊢ psi := mp h_neg_neg (double_negation psi)
  -- 4. Necessitation: |- Box psi
  have h_box_psi : ⊢ Formula.box psi :=
    DerivationTree.necessitation psi h_psi
  -- 5. neg(Box psi) + Box psi |- bot
  constructor
  exact derives_bot_from_phi_neg_phi [Formula.neg (Formula.box psi)]
    (Formula.box psi) h_box_psi (by simp)
```

**Verification**:
- `lake build` succeeds
- Lines 7048-7064 have no sorries

---

### Phase 3: processWorkItem Consistency Cases [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2 (uses subformula consistency lemmas)
- **Goal:** Complete all 10 cases in `processWorkItem_preserves_consistent`

**Tasks**:
- [ ] Complete `atomic` case (atoms are always compatible)
- [ ] Complete `bottom` case (vacuously true - bottom is never in consistent seed)
- [ ] Complete `implication` case (implications added directly)
- [ ] Complete `negation` case (negations added directly)
- [ ] Complete `boxPositive` case (uses `addFormula_seed_preserves_consistent` + `box_inner_consistent`)
- [ ] Complete `boxNegative` case (uses `createNewFamily_preserves_seedConsistent` + `neg_box_neg_inner_consistent`)
- [ ] Complete `futurePositive` case (similar to boxPositive)
- [ ] Complete `futureNegative` case (uses `createNewTime_preserves_seedConsistent`)
- [ ] Complete `pastPositive` case (similar to boxPositive)
- [ ] Complete `pastNegative` case (uses `createNewTime_preserves_seedConsistent`)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (lines 7073-7128)

**Proof Pattern for Modal Cases**:
The key insight is that each case follows the pattern:
1. Apply the appropriate seed modification lemma (`addFormula_seed_preserves_consistent`, etc.)
2. Prove the compatibility condition using subformula consistency

**Verification**:
- `lake build` succeeds
- Lines 7073-7128 have no sorries

---

### Phase 4: processWorkItem_newWork Consistency [NOT STARTED]

- **Dependencies:** Phase 1, Phase 2 (uses subformula consistency lemmas)
- **Goal:** Complete all 6 cases in `processWorkItem_newWork_consistent`

**Tasks**:
- [ ] Prove `boxPositive` case: new work has formula `psi`, consistent by `box_inner_consistent`
- [ ] Prove `boxNegative` case: new work has formula `neg psi`, consistent by `neg_box_neg_inner_consistent`
- [ ] Prove `futurePositive` case: consistent by `all_future_inner_consistent`
- [ ] Prove `futureNegative` case: consistent by `neg_future_neg_inner_consistent`
- [ ] Prove `pastPositive` case: consistent by `all_past_inner_consistent`
- [ ] Prove `pastNegative` case: consistent by `neg_past_neg_inner_consistent`

**Key Challenge**: Need to extract that `classifyFormula item.formula = boxPositive psi` implies `item.formula = Box psi`. This may require:
- Inspecting `classifyFormula` definition
- Adding lemmas like `classifyFormula_boxPositive_eq`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` (lines 7138-7170)

**Verification**:
- `lake build` succeeds
- Lines 7138-7170 have no sorries
- `processWorklistAux_preserves_invariant` compiles without sorry

---

## Testing & Validation

- [ ] `lake build` completes with no errors
- [ ] No new sorries introduced in RecursiveSeed.lean
- [ ] No new axioms introduced
- [ ] `buildSeedComplete_consistent` theorem compiles (uses all the infrastructure)
- [ ] Grep for `sorry` in RecursiveSeed.lean Phase 4 section returns no matches

## Artifacts & Outputs

- `plans/implementation-001.md` (this file)
- `summaries/implementation-summary-{DATE}.md` (post-implementation)
- Modified: `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean`

## Rollback/Contingency

If proofs become intractable:
1. Save working partial proofs (any resolved sorries)
2. Document specific blocking lemmas needed
3. Mark phase as [PARTIAL] with details
4. Consider alternative proof approaches (direct term proofs vs tactic proofs)

If `classifyFormula` extraction is complex:
1. Add helper lemmas in a section above the theorems
2. Use `simp` with `classifyFormula` definition unfolded
3. Consider `native_decide` for computational cases if formula structure is decidable
