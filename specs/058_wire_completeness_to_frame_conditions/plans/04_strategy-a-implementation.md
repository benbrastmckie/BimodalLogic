# Implementation Plan: Task #58 - Strategy A (Ultrafilter F-Witness)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (all prerequisite infrastructure is sorry-free)
- **Research Inputs**: reports/05_elegant-approach-analysis.md, reports/06_team-research.md
- **Artifacts**: plans/04_strategy-a-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Implement the ultrafilter F-witness approach (Strategy A) to construct a sorry-free `construct_bfmcs` function, then wire it to completeness theorems in a new `FrameConditions/Completeness.lean` file. This approach leverages ~5,300 lines of existing sorry-free algebraic infrastructure (STSA, ultrafilter-MCS bijection, R_G preorder, boxClassFamilies) and avoids the blocked Strategy C seed consistency proofs.

### Research Integration

- **Report 05** (elegant-approach-analysis.md): Recommends abandoning Strategy C due to unprovable `neg_not_in_boundary_resolution_set` lemma; confirms Strategy A's mathematical elegance via standard Jonsson-Tarski ultrafilter chain construction
- **Report 06** (team-research.md): Both teammates confirm `construct_bfmcs` is the single bottleneck; provides F-witness filter extension argument; confirms FrameConditions/Completeness.lean does not exist yet

## Goals & Non-Goals

**Goals**:
- Prove `ultrafilter_F_witness`: if F(psi) in U, exists V with R_G(U,V) and psi in V
- Derive `ultrafilter_P_witness` via sigma_quot temporal duality
- Build Int-indexed ultrafilter chain from a single ultrafilter
- Convert ultrafilter chain to temporally coherent FMCS via ultrafilterToMcs
- Provide sorry-free `construct_bfmcs_ultrafilter` function
- Author `FrameConditions/Completeness.lean` with 3 completeness theorems
- Eliminate all 3 target sorries: dense_completeness_fc, discrete_completeness_fc, completeness_over_Int

**Non-Goals**:
- Fixing Strategy C's `boundary_resolution_set` consistency proofs
- Providing exact duration encoding (only existence is needed for completeness)
- Generalizing beyond Int-indexed chains

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Filter extension lemma needs additional Mathlib imports | M | M | Use `Ultrafilter.ofProperFilter` or explicit construction |
| R_H relation not explicitly defined | L | L | Either define via R_G duality or use sigma_quot directly |
| boxClassFamilies integration complexity | M | L | Existing boxClassFamilies_modal_backward is sorry-free; reuse infrastructure |
| FrameConditions directory structure issues | L | L | Create directory with `mkdir -p` before writing |

## Implementation Phases

### Phase 1: F-Witness Existence [NOT STARTED]

**Goal**: Prove that if F(psi) is in ultrafilter U, there exists an R_G-successor V containing psi.

**Tasks**:
- [ ] Define filter base B = {a | G(a) in U} union {psi}
- [ ] Prove `filter_base_closed_finite_inf`: B generates a proper filter (via G monotonicity + TA axiom)
- [ ] Prove `filter_base_proper`: B does not collapse to bot (from F(psi) in U contradiction argument)
- [ ] Prove `ultrafilter_F_witness`: exists V with R_G(U,V) and psi in V

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add new section after R_G/R_Box properties

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `lean_verify` on `ultrafilter_F_witness`
- No sorry in proof

---

### Phase 2: P-Witness via Sigma Duality [NOT STARTED]

**Goal**: Derive backward witness existence from F-witness using proven sigma_quot automorphism.

**Tasks**:
- [ ] Define `R_H` relation: R_H(U,V) iff R_G(sigma(U), sigma(V)) or equivalently by H-preimage containment
- [ ] Prove `R_H_sigma_G`: R_H(U,V) iff R_G(sigma(U), sigma(V))
- [ ] Prove `ultrafilter_P_witness`: if P(psi) in U, exists V with R_H(U,V) and psi in V

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add after Phase 1 section

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `lean_verify` on `ultrafilter_P_witness`
- No sorry in proof

---

### Phase 3: Ultrafilter Chain Construction [NOT STARTED]

**Goal**: Build Int-indexed chain of ultrafilters with R_G/R_H connectivity.

**Tasks**:
- [ ] Define `UltrafilterChain` structure with Int-indexed ultrafilters
- [ ] Define `build_forward_chain`: Nat -> Ultrafilter via iterated F-witness (noncomputable)
- [ ] Define `build_backward_chain`: negated Nat -> Ultrafilter via iterated P-witness
- [ ] Define `build_ultrafilter_chain`: combine forward/backward into Int-indexed chain
- [ ] Prove `ultrafilter_chain_forward_connected`: for all n, R_G (chain n) (chain (n+1))
- [ ] Prove `ultrafilter_chain_backward_connected`: for all n, R_H (chain n) (chain (n-1))

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - New section "Ultrafilter Chain Construction"

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `lean_verify` on `build_ultrafilter_chain`
- `lean_verify` on connectivity theorems
- No sorry in any proof

---

### Phase 4: Convert to FMCS + BFMCS [NOT STARTED]

**Goal**: Convert ultrafilter chain to FMCS via ultrafilterToMcs, prove temporal coherence, assemble BFMCS.

**Tasks**:
- [ ] Define `ultrafilterChainToFMCS`: convert chain to FMCS via ultrafilterToMcs bijection
- [ ] Prove `ultrafilterChainToFMCS_is_mcs`: each time point is an MCS
- [ ] Prove `ultrafilterChainToFMCS_forward_F`: F-witness property transfers to FMCS
- [ ] Prove `ultrafilterChainToFMCS_backward_P`: P-witness property transfers to FMCS
- [ ] Prove `ultrafilterChainToFMCS_temporally_coherent`: combines forward_F and backward_P
- [ ] Define `construct_bfmcs_ultrafilter`: main construction function
- [ ] Prove `construct_bfmcs_ultrafilter_correct`: satisfies parametric_algebraic_representation_conditional signature

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Replace deprecated construct_bfmcs

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `lean_verify` on `construct_bfmcs_ultrafilter`
- `#print axioms construct_bfmcs_ultrafilter` shows no `sorryAx`

---

### Phase 5: Author FrameConditions/Completeness.lean [NOT STARTED]

**Goal**: Create the completeness file and wire to parametric_algebraic_representation_conditional.

**Tasks**:
- [ ] Create directory `Theories/Bimodal/Metalogic/FrameConditions/` if not exists
- [ ] Author `Completeness.lean` with module docstring
- [ ] Import UltrafilterChain and ParametricRepresentation
- [ ] Define `dense_completeness_fc`: completeness over dense frame conditions
- [ ] Define `discrete_completeness_fc`: completeness over discrete frame conditions
- [ ] Define `completeness_over_Int`: main completeness theorem over Int
- [ ] Add file to lakefile.lean imports if needed

**Timing**: 1 hour

**Files to create**:
- `Theories/Bimodal/Metalogic/FrameConditions/Completeness.lean` - New file (~100 LOC)

**Files to modify**:
- `lakefile.lean` - Add module to build if needed (may be auto-detected)

**Verification**:
- `lake build Bimodal.Metalogic.FrameConditions.Completeness`
- `#print axioms dense_completeness_fc` shows no `sorryAx`
- `#print axioms discrete_completeness_fc` shows no `sorryAx`
- `#print axioms completeness_over_Int` shows no `sorryAx`
- Full `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `#print axioms construct_bfmcs_ultrafilter` shows no `sorryAx`
- [ ] `#print axioms dense_completeness_fc` shows no `sorryAx`
- [ ] `#print axioms discrete_completeness_fc` shows no `sorryAx`
- [ ] `#print axioms completeness_over_Int` shows no `sorryAx`
- [ ] All new theorems verified with `lean_verify`
- [ ] No regressions in existing sorry-free infrastructure

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Extended with F/P-witness, chain construction, sorry-free construct_bfmcs_ultrafilter
- `Theories/Bimodal/Metalogic/FrameConditions/Completeness.lean` - New file with 3 completeness theorems
- `specs/058_wire_completeness_to_frame_conditions/summaries/05_strategy-a-summary.md` - Execution summary (after completion)

## Rollback/Contingency

If implementation fails:
1. Keep deprecated `construct_bfmcs` in place (it still compiles, just has sorry chain)
2. Preserve all new definitions but mark with sorry and deprecation notes
3. Document specific blockers in summaries directory
4. Consider hybrid approach: use Strategy A for F-witness but reuse existing boxClassFamilies infrastructure where possible

**Alternative approach if Phase 1 blocks**: If filter extension in Phase 1 encounters unexpected Mathlib issues, fall back to explicit ultrafilter construction using `Ultrafilter.ofComplFilter` or similar. The mathematical argument remains sound.
