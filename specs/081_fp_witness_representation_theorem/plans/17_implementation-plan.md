# Implementation Plan: Task #81

- **Task**: 81 - F/P Witness Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None
- **Research Inputs**: reports/17_standard-completeness-approach.md
- **Artifacts**: plans/17_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the sole remaining sorry in `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237) by proving that fuel exhaustion is unreachable in the restricted bounded witness functions. The approach uses an F-nesting depth argument within the finite deferralClosure: obligations at the maximum nesting depth MUST resolve in one step (by single_step_forcing, since FF at that depth is outside the closure), and obligations at lower depths resolve by induction. This avoids all previously-failed approaches (fair scheduling, targeted seeds, omega-branching) by working entirely within the existing restricted chain infrastructure, where the only gap is proving the `fuel = 0` branches at SuccChainFMCS.lean lines 5619, 5777, and 5973 are unreachable.

### Research Integration

Report 17 identifies Path A (close fuel exhaustion sorry) as the most promising concrete path. The key mathematical argument (Section 8) shows that within deferralClosure, F-nesting depth is bounded by B = closure_F_bound. At the maximum depth, single_step_forcing applies because FF is outside the closure. By downward induction on depth, all obligations resolve within bounded steps. The report notes a subtlety around perpetual re-introduction of obligations (Section "Revised Analysis"), which this plan addresses by replacing the fuel parameter with a well-founded recursion on a lexicographic measure (depth, chain position) that strictly decreases.

## Goals & Non-Goals

**Goals**:
- Close all `sorry` in the fuel=0 branches of `restricted_bounded_witness_fueled`, `restricted_combined_bounded_witness_fueled`, and `restricted_backward_bounded_witness_fueled`
- Prove `bfmcs_from_mcs_temporally_coherent` sorry-free
- Maintain all existing sorry-free theorems

**Non-Goals**:
- Changing the semantics or proof system of TM
- Refactoring the BFMCS bundle construction
- Proving completeness through an alternative path (e.g., FMP)
- Addressing the Box backward sorry in SuccChainTruth.lean (separate issue)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Perpetual re-introduction of F-obligations defeats naive depth induction | H | M | Use well-founded measure (depth + chain position) instead of fuel; the key is that each recursive call either decreases depth or advances the chain position |
| single_step_forcing may not apply in restricted MCS (requires FF not in M) | H | L | Already confirmed: if F-depth is maximal in closure, FF is outside closure and cannot be in restricted MCS; `deferral_restricted_mcs_F_bounded` proves this |
| The restricted forward_F does not lift to the full BFMCS temporal coherence | H | M | The restricted truth lemma path (RestrictedTruthLemma.lean) may need to be connected; alternatively, show each boxClassFamily is itself a restricted chain |
| Lean type-checking or termination checker rejects the well-founded recursion | M | M | Fall back to explicit fuel with a refined bound (2^B instead of B*B+1) and prove the fuel=0 case by contradiction using the depth argument |
| P-direction is not perfectly symmetric with F-direction | L | L | P infrastructure mirrors F infrastructure in SuccChainFMCS.lean; same argument applies with iter_P and p_content |

## Implementation Phases

### Phase 1: F-Nesting Depth Infrastructure [PARTIAL]

**Goal**: Formalize the F-nesting depth function and prove key properties within deferralClosure needed for the fuel-exhaustion argument.

**Tasks**:
- [ ] Define `f_nesting_depth` function for formulas relative to deferralClosure (or verify `closure_F_bound` and existing `iter_F` infrastructure suffice)
- [ ] Prove: if `iter_F d psi` is in a DeferralRestrictedMCS with `d >= closure_F_bound phi`, then `iter_F d psi` is NOT in the MCS (verify `deferral_restricted_mcs_F_bounded` covers this)
- [ ] Prove: for maximal-depth F-obligations in restricted MCS, `F(F(psi))` is NOT in the MCS (follows from the above)
- [ ] Prove analogous `p_nesting_depth` properties for the P-direction
- [ ] Build with `lake build` to verify no regressions

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- add depth lemmas near existing `deferral_restricted_mcs_F_bounded` (around line 3100)

**Verification**:
- `lake build` succeeds
- New lemmas type-check without sorry
- Existing theorems unaffected

---

### Phase 2: Base Case -- Max-Depth Obligations Resolve in One Step [BLOCKED]

**Goal**: Prove that F-obligations at the maximum nesting depth in a restricted Succ-chain resolve at the very next step, using single_step_forcing.

**Tasks**:
- [ ] Prove `restricted_max_depth_resolves`: if `F(psi)` is in restricted chain at time n, and the F-depth of `F(psi)` equals `closure_F_bound phi - 1` (maximum), then `psi` is in the chain at time n+1
- [ ] The proof should invoke `single_step_forcing` after establishing that `F(F(psi))` cannot be in the restricted MCS (from Phase 1)
- [ ] Prove the symmetric P-direction: max-depth P-obligations resolve in one backward step
- [ ] Build with `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- add base case theorems

**Verification**:
- The new theorems compile without sorry
- They correctly invoke `single_step_forcing` (for F) and its P-analog

---

### Phase 3: Inductive Step -- Prove Fuel Exhaustion Unreachable [BLOCKED]

**Goal**: Replace or close the `sorry` in the fuel=0 branches by proving that the recursion terminates before fuel runs out.

**Tasks**:
- [ ] Define a well-founded measure for the recursive calls: `(closure_F_bound phi - current_depth, fuel)` lexicographic, or prove a standalone lemma that the fuel=0 case leads to contradiction
- [ ] For `restricted_bounded_witness_fueled` (line 5619): prove that if `d >= 1` and `iter_F d theta` is in the chain with boundary, then fuel B*B+1 suffices by showing the recursion depth is bounded by B (using Phase 1-2 results)
- [ ] For `restricted_combined_bounded_witness_fueled` (line 5777): same argument for the Int-indexed combined chain
- [ ] For `restricted_combined_bounded_witness_P_fueled` (line 5973): symmetric P-direction argument
- [ ] Build with `lake build` to verify all three sorries are closed

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- modify the three `_fueled` functions to close fuel=0 branches

**Verification**:
- `lake build` succeeds
- `grep -r sorry Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` shows NO sorry in the three fueled functions
- The `restricted_forward_chain_forward_F`, `restricted_combined_bounded_witness`, and `restricted_backward_chain_backward_P` theorems are now sorry-free

---

### Phase 4: Wire to Completeness Sorry [BLOCKED]

**Goal**: Connect the sorry-free restricted chain coherence to `bfmcs_from_mcs_temporally_coherent` in Completeness.lean.

**Tasks**:
- [ ] Identify how `construct_bfmcs_bundle` builds its families from boxClassFamilies (in UltrafilterChain.lean)
- [ ] Prove that each family in the BFMCS is either directly a restricted Succ-chain or can be shown to satisfy forward_F/backward_P via the restricted chain argument
- [ ] If the boxClassFamilies use a different chain construction than the restricted one, prove an adapter lemma that translates the restricted forward_F to the family-level forward_F
- [ ] Close the sorry in `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237)
- [ ] Build with `lake build`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- close the sorry at line 237
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- possibly add bridge lemmas connecting boxClassFamilies to restricted chain properties

**Verification**:
- `bfmcs_from_mcs_temporally_coherent` compiles without sorry
- `lake build` succeeds with no regressions
- `grep -r sorry Theories/Bimodal/FrameConditions/Completeness.lean` returns no results

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `grep -rn sorry Theories/Bimodal/FrameConditions/Completeness.lean` shows no sorry
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` shows only non-critical sorries (if any remain in deprecated code)
- [ ] The three `_fueled` functions have no sorry in their fuel=0 branches
- [ ] `bfmcs_from_mcs_temporally_coherent` is sorry-free
- [ ] No existing sorry-free theorems have been broken

## Artifacts & Outputs

- Modified `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- F-nesting depth lemmas, base case, and fuel=0 closure
- Modified `Theories/Bimodal/FrameConditions/Completeness.lean` -- sorry closed
- Possibly modified `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- bridge lemmas
- Execution summary at `specs/081_fp_witness_representation_theorem/summaries/17_execution-summary.md`

## Rollback/Contingency

If the depth argument cannot be formalized cleanly in Lean:

1. **Immediate fallback**: Keep the fuel parameter but increase the bound to `2^(closure_F_bound phi)` and prove the fuel=0 case by contradiction using a finitary pigeonhole argument on the restricted state space (which is finite since deferralClosure is finite).

2. **Alternative path**: If the boxClassFamilies-to-restricted-chain bridge (Phase 4) proves intractable, restructure completeness to use the restricted truth lemma path directly (RestrictedTruthLemma.lean + SuccChainCompleteness.lean) instead of going through the BFMCS bundle.

3. **Nuclear option**: If all approaches fail, mark the sorry as an explicit axiom with documentation explaining the mathematical argument informally, and record the precise formalization gap for future work. This preserves the rest of the completeness infrastructure.

4. **Git revert**: All changes are in at most 3 files. `git checkout main -- Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean Theories/Bimodal/FrameConditions/Completeness.lean Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` restores the pre-implementation state.
