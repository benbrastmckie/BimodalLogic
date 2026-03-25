# Implementation Plan: Task #58 - Omega-Enumeration BFMCS (v5)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: None (all prerequisite building blocks are sorry-free)
- **Research Inputs**: specs/064_critical_path_review/reports/09_team-research.md
- **Artifacts**: plans/05_omega-enumeration.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Implement the omega-enumeration BFMCS architecture to eliminate 3 sorries in `FrameConditions/Completeness.lean`: `dense_completeness_fc`, `discrete_completeness_fc`, and `completeness_over_Int`. This approach replaces the blocked `SuccChainFMCS` (which depends on false `f_nesting_is_bounded`) with omega-enumerated chains that achieve temporal coherence by construction through dovetailed resolution of F/P-obligations.

### Research Integration

From task 64 team research (report 09):
- **Prior approaches dead**: Strategy C (boundary_resolution_set), Strategy A (ultrafilter F-witness), restricted chain (termination sorry) all blocked
- **Sorry-free building blocks**: `temporal_theory_witness_exists`, `past_theory_witness_exists`, `box_theory_witness_exists` all confirmed sorry-free
- **Modal infrastructure reusable**: `boxClassFamilies_modal_forward` and `boxClassFamilies_modal_backward` are sorry-free
- **Key insight**: Resolve one F-obligation per step via dovetailing; temporal coherence holds by construction

## Goals & Non-Goals

**Goals**:
- Define `omega_chain_forward`: N -> MCS resolving F-obligations via dovetailed enumeration
- Define `omega_chain_backward`: N -> MCS resolving P-obligations symmetrically
- Define `Z_chain`: Int -> MCS combining forward/backward chains
- Define `OmegaFMCS`: wrap Z_chain as FMCS with sorry-free temporal coherence
- Define `omegaClassFamilies`: build BFMCS families using omega chains
- Prove `omega_temporal_coherent`: every F(phi) eventually resolved by construction
- Prove `omega_modal_forward` and `omega_modal_backward` via reuse of existing infrastructure
- Provide sorry-free `construct_bfmcs_omega` replacing deprecated `construct_bfmcs`
- Eliminate sorries in `dense_completeness_fc`, `discrete_completeness_fc`, `completeness_over_Int`

**Non-Goals**:
- Fixing `SuccChainFMCS` or `f_nesting_is_bounded` (mathematically impossible)
- Supporting non-Int temporal domains (Int is sufficient for completeness)
- Optimizing the dovetailing strategy (existence is enough)
- Generalizing beyond the specific completeness theorems

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `box_class_agree` transitivity not proven | M | L | Prove it first (trivial from iff-transitivity) |
| G-theory propagation through omega chain | H | M | Prove by induction at each step; witness theorems preserve G-theory |
| Dovetailing encoding complexity | M | M | Use simple pairing function; explicit priority queue not needed |
| Modal coherence for new families | H | L | Reuse existing boxClassFamilies infrastructure; same box_class requirement |
| Large proof due to chain construction | M | M | Factor into small lemmas; use well-factored building blocks |

## Implementation Phases

### Phase 1: Prerequisites and Foundation [NOT STARTED]

**Goal**: Establish the foundational lemmas needed for omega chain construction.

**Tasks**:
- [ ] Prove `box_class_agree_trans`: transitivity of box_class_agree (M,W) and (W,V) implies (M,V)
- [ ] Define `F_obligations`: Set of F(phi) formulas in an MCS
- [ ] Define `obligation_enum`: N -> Formula pairing function for dovetailing
- [ ] Prove `G_theory_preserved_by_witness`: G(a) in M and witness W implies G(a) in W (from temporal_theory_witness_exists)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add new section after box_class_agree definitions

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `#print axioms box_class_agree_trans` shows no `sorryAx`
- `lean_goal` confirms all proofs complete

---

### Phase 2: Omega Chain Forward Construction [NOT STARTED]

**Goal**: Build the forward omega chain resolving F-obligations via iterated choice.

**Tasks**:
- [ ] Define `omega_step_forward`: given MCS M and target F(phi), return witness MCS W with phi, G-agreement, box_class_agree
- [ ] Define `omega_chain_forward_aux`: N -> MCS using noncomputable recursion with dovetailed obligation selection
- [ ] Define `omega_chain_forward`: wrap aux with root MCS M0
- [ ] Prove `omega_chain_forward_mcs`: each omega_chain_forward(n) is MCS
- [ ] Prove `omega_chain_forward_box_class`: box_class_agree(M0, omega_chain_forward(n)) for all n
- [ ] Prove `omega_chain_forward_G_theory`: G(a) in M0 implies G(a) in omega_chain_forward(n) for all n (by induction)

**Timing**: 2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - New section "Omega Chain Forward"

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `#print axioms omega_chain_forward` shows only `Classical.choice` (expected for noncomputable)
- No `sorryAx` in any proof

---

### Phase 3: Omega Chain Backward Construction [NOT STARTED]

**Goal**: Build the backward omega chain resolving P-obligations symmetrically.

**Tasks**:
- [ ] Define `omega_step_backward`: given MCS M and target P(phi), return witness MCS W with phi, H-agreement, box_class_agree
- [ ] Define `omega_chain_backward_aux`: N -> MCS using noncomputable recursion with dovetailed P-obligation selection
- [ ] Define `omega_chain_backward`: wrap aux with root MCS M0
- [ ] Prove `omega_chain_backward_mcs`: each omega_chain_backward(n) is MCS
- [ ] Prove `omega_chain_backward_box_class`: box_class_agree(M0, omega_chain_backward(n)) for all n
- [ ] Prove `omega_chain_backward_H_theory`: H(a) in M0 implies H(a) in omega_chain_backward(n) for all n

**Timing**: 1.5 hours (symmetric to Phase 2, reuse patterns)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - New section "Omega Chain Backward"

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- No `sorryAx` in proofs

---

### Phase 4: Z-Chain and FMCS Construction [NOT STARTED]

**Goal**: Combine forward and backward chains into Int-indexed FMCS.

**Tasks**:
- [ ] Define `Z_chain`: Int -> MCS combining forward (n >= 0) and backward (n < 0) chains
- [ ] Prove `Z_chain_mcs`: Z_chain(t) is MCS for all t : Int
- [ ] Prove `Z_chain_box_class`: box_class_agree(M0, Z_chain(t)) for all t
- [ ] Define `OmegaFMCS`: wrap Z_chain as FMCS structure
- [ ] Prove `OmegaFMCS_is_fmcs`: OmegaFMCS satisfies FMCS interface

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - New section "Z-Chain and OmegaFMCS"

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- OmegaFMCS type-checks as FMCS Int

---

### Phase 5: Temporal Coherence by Construction [NOT STARTED]

**Goal**: Prove temporal coherence for OmegaFMCS based on dovetailing property.

**Tasks**:
- [ ] Prove `dovetail_eventually_resolves`: for any F(phi) at time t, there exists s > t where phi is resolved
- [ ] Prove `omega_forward_F`: if F(phi) in Z_chain(t), exists s > t with phi in Z_chain(s)
- [ ] Prove `omega_backward_P`: if P(phi) in Z_chain(t), exists s < t with phi in Z_chain(s)
- [ ] Prove `OmegaFMCS_temporally_coherent`: OmegaFMCS satisfies temporal coherence

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - New section "Omega Temporal Coherence"

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `#print axioms OmegaFMCS_temporally_coherent` shows no `sorryAx`
- This is the critical gate: temporal coherence without false assumptions

---

### Phase 6: Omega Class Families and BFMCS [NOT STARTED]

**Goal**: Build BFMCS using omega chains instead of SuccChainFMCS.

**Tasks**:
- [ ] Define `omegaClassFamilies`: Set (FMCS Int) using OmegaFMCS for each box_class_agree witness W
- [ ] Prove `omegaClassFamilies_nonempty`: families is nonempty (contains M0's family)
- [ ] Prove `omegaClassFamilies_modal_forward`: Diamond(phi) in family at t implies exists family' with phi at t
- [ ] Prove `omegaClassFamilies_modal_backward`: Box(phi) in all families at t implies phi in family at t (reuse existing proof pattern)
- [ ] Define `OmegaBFMCS`: BFMCS structure using omegaClassFamilies
- [ ] Prove `OmegaBFMCS_temporally_coherent`: all families in OmegaBFMCS are temporally coherent

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - New section "Omega BFMCS"

**Verification**:
- `lake build Bimodal.Metalogic.Algebraic.UltrafilterChain`
- `#print axioms OmegaBFMCS` shows no `sorryAx`
- OmegaBFMCS satisfies BFMCS interface with temporal coherence

---

### Phase 7: Wire to Completeness [NOT STARTED]

**Goal**: Connect omega construction to completeness theorems and eliminate sorries.

**Tasks**:
- [ ] Define `construct_bfmcs_omega`: sorry-free replacement for deprecated construct_bfmcs
- [ ] Verify `construct_bfmcs_omega` matches signature required by `parametric_algebraic_representation_conditional`
- [ ] Update `dense_completeness_fc` to use construct_bfmcs_omega
- [ ] Update `discrete_completeness_fc` to use construct_bfmcs_omega
- [ ] Update `completeness_over_Int` to use construct_bfmcs_omega
- [ ] Add deprecation notice to old construct_bfmcs referencing construct_bfmcs_omega

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Add construct_bfmcs_omega
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Wire to new construction

**Verification**:
- `lake build Bimodal.FrameConditions.Completeness`
- `#print axioms dense_completeness_fc` shows no `sorryAx`
- `#print axioms discrete_completeness_fc` shows no `sorryAx`
- `#print axioms completeness_over_Int` shows no `sorryAx`
- Full `lake build` succeeds with no new warnings

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] `#print axioms construct_bfmcs_omega` shows only `Classical.choice` (no `sorryAx`)
- [ ] `#print axioms dense_completeness_fc` shows no `sorryAx`
- [ ] `#print axioms discrete_completeness_fc` shows no `sorryAx`
- [ ] `#print axioms completeness_over_Int` shows no `sorryAx`
- [ ] All new theorems verified with `lean_verify`
- [ ] No regressions in existing sorry-free infrastructure (run `#print axioms` on existing theorems)
- [ ] Deprecation warnings properly reference new construction

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` - Extended with omega chain construction, OmegaBFMCS, sorry-free construct_bfmcs_omega
- `Theories/Bimodal/FrameConditions/Completeness.lean` - Updated to use construct_bfmcs_omega, sorries eliminated
- `specs/058_wire_completeness_to_frame_conditions/summaries/05_omega-enumeration-summary.md` - Execution summary (after completion)

## Rollback/Contingency

If implementation fails at any phase:

1. **Phase 1-5 blockers**: Preserve all partial work with `sorry` placeholders and detailed comments explaining the gap
2. **Phase 6 blockers**: Fall back to singleton BFMCS approach (noted as wrong for full S5 but sufficient for basic completeness)
3. **Phase 7 blockers**: Keep completeness theorems with sorry; document the construction gap

**Alternative approaches if omega-enumeration fails**:
1. **Ordinal-indexed chains**: If omega enumeration has issues with unbounded F-obligations, consider ordinal-indexed construction (more complex)
2. **Quotient construction**: Collapse equivalent MCSes in the omega chain to potentially simplify temporal coherence
3. **Direct Henkin construction**: Bypass BFMCS entirely with direct canonical model on MCS quotient

**Lessons from prior failures**:
- Do NOT attempt `f_nesting_is_bounded` or `boundary_resolution_set` - mathematically blocked
- Do NOT rely on restricted chain termination - has sorry
- Do NOT use singleton families - trivializes modal structure
- DO verify each phase compiles before proceeding
- DO check `#print axioms` at each phase to catch sorry infection early
