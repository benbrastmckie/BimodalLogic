# Implementation Plan: Task #48 - Algebraic STSA Approach (v14)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None (existing algebraic infrastructure ~80% complete)
- **Research Inputs**: reports/30_algebraic-stsa-path.md
- **Artifacts**: plans/14_algebraic-stsa.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan implements the algebraic bypass approach via Shift-Closed Tense S5 Algebras (STSA). After 13 failed plan versions that all hit the same fundamental obstacle (restricted_single_step_forcing is FALSE for boundary cases due to closureWithNeg lacking closure under negation), the algebraic approach avoids this entirely by using ultrafilters which have FULL negation completeness by definition.

The key insight is that the MF+TF axioms become assets at the algebraic level (ensuring Im(Box) is G/H-invariant), rather than obstacles requiring chain-local proofs. The `construct_bfmcs` function required by `ParametricRepresentation.lean` can be satisfied via ultrafilter extension chains (Jonsson-Tarski representation pattern).

### Research Integration

Report 30 identifies:
1. `sigma_quot` (temporal duality) can be defined by lifting `swap_temporal` using `temporal_duality` inference rule
2. STSA structure achievable with ~355 lines of new code
3. Ultrafilters bypass boundary problems: no "boundary vs interior" distinction
4. Chain construction uses Zorn's lemma (standard Mathlib pattern)

## Goals & Non-Goals

**Goals**:
- Define `sigma_quot` (temporal duality) on `LindenbaumAlg`
- Define `STSA` typeclass capturing TM algebraic structure
- Prove `LindenbaumAlg` is an STSA instance
- Implement `construct_bfmcs_algebraic` via ultrafilter extension
- Wire `construct_bfmcs` in `ParametricRepresentation.lean`
- Achieve zero sorries in the algebraic completeness path

**Non-Goals**:
- Do not modify the existing `deferralClosure` / `succ_chain` infrastructure (deprecated by this approach)
- Do not attempt to fix the FALSE `restricted_single_step_forcing` lemma
- Do not refactor `SuccChainFMCS.lean` (it becomes obsolete for completeness)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Zorn's lemma chain construction complex | Medium | Medium | Follow standard Mathlib patterns from Order.Zorn |
| STSA axiom lifting tedious | Low | High | Each axiom lifts mechanically via Quotient.ind |
| Linearity axiom complex in algebraic form | Medium | Low | Research provides exact algebraic statement |
| R_G totality proof challenging | Medium | Medium | Use linearity + ultrafilter extension pattern |
| Missing helper lemmas in MCS infrastructure | Medium | Low | UltrafilterMCS.lean already has most pieces |

## Implementation Phases

### Phase 1: sigma_quot Definition and Properties [NOT STARTED]

**Goal**: Define temporal duality on LindenbaumAlg and prove its core properties.

**Tasks**:
- [ ] Add `swap_temporal_derives` theorem: `Derives phi psi -> Derives phi.swap_temporal psi.swap_temporal`
- [ ] Add `provEquiv_swap_temporal_congr`: `phi ≈ₚ psi -> phi.swap_temporal ≈ₚ psi.swap_temporal`
- [ ] Define `sigma_quot : LindenbaumAlg -> LindenbaumAlg` via Quotient.lift
- [ ] Prove `sigma_quot_involution`: `sigma_quot (sigma_quot a) = a`
- [ ] Prove `sigma_quot_neg`: `sigma_quot (neg_quot a) = neg_quot (sigma_quot a)`
- [ ] Prove `sigma_quot_sup`: `sigma_quot (or_quot a b) = or_quot (sigma_quot a) (sigma_quot b)`
- [ ] Prove `sigma_quot_G_H`: `sigma_quot (G_quot a) = H_quot (sigma_quot a)`
- [ ] Prove `sigma_quot_H_G`: `sigma_quot (H_quot a) = G_quot (sigma_quot a)`
- [ ] Prove `sigma_quot_box`: `sigma_quot (box_quot a) = box_quot (sigma_quot a)`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/LindenbaumQuotient.lean` (~95 lines added)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Algebraic.LindenbaumQuotient` compiles
- All sigma_quot theorems proven without sorry

---

### Phase 2: STSA Typeclass Definition [NOT STARTED]

**Goal**: Define the STSA (Shift-Closed Tense S5 Algebra) typeclass.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean`
- [ ] Define `class STSA (alpha : Type*) extends BooleanAlgebra alpha` with:
  - Operators: `box`, `G`, `H`, `sigma`
  - Box S5 axioms: deflationary, monotone, idempotent, s5 partition
  - G/H monotonicity
  - Sigma properties: involution, Boolean automorphism
  - Sigma-G-H duality
  - TM interaction axioms: MF, TF, TA, TL, linearity
- [ ] Add basic derived lemmas (sigma_bot, sigma_top, sigma_inf)
- [ ] Add import to `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean`

**Timing**: 1 hour

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` (~50 lines)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` (add import)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Algebraic.TenseS5Algebra` compiles
- STSA class well-formed

---

### Phase 3: STSA Instance for LindenbaumAlg [NOT STARTED]

**Goal**: Prove LindenbaumAlg satisfies all STSA axioms.

**Tasks**:
- [ ] Prove `box_s5_quot`: `or_quot (box_quot a) (box_quot (neg_quot a)) = top_quot`
  - Uses S5 axioms: modal_s5_neg (¬□φ → □¬□φ) and disjunction completeness
- [ ] Prove `MF_quot`: `box_quot a <= box_quot (G_quot a)` (from MF axiom)
- [ ] Prove `TF_quot`: `box_quot a <= G_quot (box_quot a)` (from TF axiom)
- [ ] Prove `TA_quot`: `a <= G_quot (neg_quot (H_quot (neg_quot a)))` (from TA axiom)
- [ ] Prove `TL_quot`: `and_quot (H_quot a) (G_quot a) <= G_quot (H_quot a)` (from TL axiom)
- [ ] Prove `linearity_quot`: algebraic form of temporal linearity
- [ ] Instantiate `instance : STSA LindenbaumAlg`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` (~80 lines added)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Algebraic.TenseS5Algebra` compiles
- `STSA LindenbaumAlg` instance proven without sorry

---

### Phase 4: Ultrafilter Chain Construction [NOT STARTED]

**Goal**: Implement construct_bfmcs_algebraic using ultrafilter extension chains.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Algebraic/AlgebraicConstruction.lean`
- [ ] Define `R_G_ultrafilter (U V : Ultrafilter LindenbaumAlg) : Prop` as canonical temporal relation
- [ ] Define `R_Box_ultrafilter (U V : Ultrafilter LindenbaumAlg) : Prop` as canonical modal relation
- [ ] Prove `R_G_total`: linearity ensures R_G is a total order on ultrafilters
- [ ] Prove `R_G_chain_exists`: Zorn's lemma gives maximal R_G chains
- [ ] Define `chain_to_fmcs`: convert ultrafilter chain to FMCS D
- [ ] Define `fmcs_box_saturation`: build BFMCS by R_Box saturation
- [ ] Prove `chain_bfmcs_temporally_coherent`: MF+TF ensure temporal coherence

**Timing**: 2 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicConstruction.lean` (~100 lines)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Algebraic.AlgebraicConstruction` compiles
- `construct_bfmcs_algebraic` defined without sorry

---

### Phase 5: Wire to ParametricRepresentation [NOT STARTED]

**Goal**: Connect algebraic construction to the representation theorem.

**Tasks**:
- [ ] Define `construct_bfmcs` in terms of `construct_bfmcs_algebraic`
- [ ] Verify type signatures match `ParametricRepresentation` requirements:
  ```lean
  construct_bfmcs : (M : Set Formula) -> SetMaximalConsistent M ->
    Sigma' (B : BFMCS D) (h_tc : B.temporally_coherent)
           (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
           M = fam.mcs t
  ```
- [ ] Add import chain to `ParametricRepresentation.lean`
- [ ] Test with `parametric_algebraic_representation_conditional`

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicConstruction.lean` (~30 lines)
- `Theories/Bimodal/Metalogic/Algebraic/ParametricRepresentation.lean` (imports)

**Verification**:
- `lake build Theories.Bimodal.Metalogic.Algebraic.ParametricRepresentation` compiles
- Representation theorem instantiable with `construct_bfmcs`

---

### Phase 6: Full Build Verification [NOT STARTED]

**Goal**: Ensure full project builds and no regressions.

**Tasks**:
- [ ] Run `lake build` for full project
- [ ] Check for any new sorries introduced
- [ ] Verify algebraic completeness path is complete
- [ ] Document deprecation status of `SuccChainFMCS.lean` sorries

**Timing**: 30 minutes

**Files to verify**:
- All files in `Theories/Bimodal/Metalogic/Algebraic/`
- `Theories/Bimodal/Metalogic/Algebraic/Algebraic.lean` import graph

**Verification**:
- `lake build` passes with no errors
- Zero sorries in algebraic completeness path
- `SuccChainFMCS.lean` sorries documented as obsolete (not blocking completeness)

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.Algebraic.LindenbaumQuotient` - sigma_quot
- [ ] `lake build Theories.Bimodal.Metalogic.Algebraic.TenseS5Algebra` - STSA class + instance
- [ ] `lake build Theories.Bimodal.Metalogic.Algebraic.AlgebraicConstruction` - construct_bfmcs
- [ ] `lake build Theories.Bimodal.Metalogic.Algebraic.ParametricRepresentation` - full path
- [ ] `lake build` - full project compilation
- [ ] Manual: verify `parametric_algebraic_representation_conditional` is instantiable

## Artifacts & Outputs

- `plans/14_algebraic-stsa.md` (this plan)
- `Theories/Bimodal/Metalogic/Algebraic/TenseS5Algebra.lean` (new file)
- `Theories/Bimodal/Metalogic/Algebraic/AlgebraicConstruction.lean` (new file)
- Modified `LindenbaumQuotient.lean` (sigma_quot addition)
- Modified `ParametricRepresentation.lean` (wiring)
- `summaries/15_algebraic-stsa-summary.md` (execution summary)

## Rollback/Contingency

**If Phase 4 (Zorn's lemma chain) proves difficult**:
1. Use a simplified direct construction with Int as D
2. Build explicit ascending chain from MCS using natural number indexing
3. This trades generality for simplicity

**If STSA axiom lifting fails unexpectedly**:
1. Add explicit proof terms instead of automation
2. Each axiom can be proven by unfolding Quotient.lift + using inference rule

**Full rollback**:
- `git checkout -- Theories/Bimodal/Metalogic/Algebraic/`
- Task 48 sorries remain in SuccChainFMCS.lean (but completeness path uses algebraic approach)

## Historical Context

This is plan version 14. Key insight from 13 failures:

**The relational approach is fundamentally blocked**:
- `closureWithNeg` has ONE-LAYER negation only
- When `FF(psi) in closureWithNeg \ subformulaClosure`, `neg(FF(psi)) not in deferralClosure`
- `restricted_single_step_forcing` is FALSE for boundary cases
- No amount of hypothesis weakening or restructuring can fix this

**The algebraic approach bypasses this entirely**:
- Ultrafilters have FULL negation completeness by definition
- No "boundary" vs "interior" distinction exists
- MF+TF become assets (ensure box-persistence) not obstacles
- Standard Jonsson-Tarski representation pattern applies

## Line Count Summary

| Component | New Lines | Modified Lines |
|-----------|-----------|----------------|
| sigma_quot (LindenbaumQuotient) | 95 | 0 |
| STSA class (TenseS5Algebra) | 50 | 0 |
| STSA instance (TenseS5Algebra) | 80 | 0 |
| construct_bfmcs (AlgebraicConstruction) | 100 | 0 |
| Wiring (ParametricRepresentation) | 0 | 30 |
| **Total** | **325** | **30** |
