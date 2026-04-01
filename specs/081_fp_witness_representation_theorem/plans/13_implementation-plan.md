# Implementation Plan: Close Completeness Sorry via Fuel Sufficiency

- **Task**: 81 - F/P Witness Representation Theorem
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (builds on sorry-free infrastructure from v11/v12)
- **Research Inputs**: reports/13_blocker-analysis.md, summaries/11_execution-summary.md, summaries/12_execution-summary.md
- **Artifacts**: plans/13_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the single sorry blocking `completeness_over_Int` and `discrete_completeness_fc` in Completeness.lean. The sorry chain is: `bfmcs_from_mcs_temporally_coherent` -> family-level `forward_F`/`backward_P` -> the fuel=0 branches in `restricted_combined_bounded_witness_fueled` and `restricted_backward_bounded_witness_fueled` (SuccChainFMCS.lean lines 5619, 5777, 5969). This plan closes those fuel=0 sorries by proving that fuel `B*B+1` is always sufficient, then wires the result through to `bfmcs_from_mcs_temporally_coherent`.

### Research Integration

Report 13 (blocker analysis) identified three paths. The enriched-seed approach (Path D/F) is blocked by the provably FALSE `constrained_successor_seed_restricted_consistent`. The Lindenbaum-freedom approach (Path C) cannot prevent G(neg(psi)) entry. This plan takes a fourth path: **prove the existing bounded-fuel argument terminates** by showing the recursion depth is bounded by `closure_F_bound`. The existing infrastructure already has:
- Sorry-free f_step (deferralDisjunction mechanism)
- Sorry-free F-bounded nesting (`deferral_restricted_mcs_F_bounded`)
- Sorry-free upper bound on boundary depth (`deferral_restricted_mcs_F_bounded_upper`: d < closure_F_bound)
- The recursive structure that either reduces depth d or advances chain position

The fuel=0 branch is claimed "semantically unreachable" in comments. The task is to prove it.

## Goals & Non-Goals

**Goals**:
- Close the fuel=0 sorry in `restricted_combined_bounded_witness_fueled` (F-direction)
- Close the fuel=0 sorry in `restricted_backward_bounded_witness_fueled` (P-direction)
- Close the fuel=0 sorry in the cross-chain combined witness (line 5969)
- Wire through to `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:237)
- Achieve sorry-free `completeness_over_Int` and `discrete_completeness_fc`

**Non-Goals**:
- Dense completeness (`dense_completeness_fc` -- separate sorry, needs dense canonical model)
- Refactoring the chain architecture (SuccChainFMCS is mature, not broken)
- Closing sorries in deprecated/unused code paths
- Restructuring the truth lemma or TemporalCoherentFamily definition

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fuel bound B*B+1 is actually insufficient | H | L | Analyze recursion: each call either decreases d (bounded by B) or advances position while resetting d. Total calls bounded by B*d_max <= B*B. The +1 covers the initial call. If wrong, increase to B^3 or use well-founded recursion. |
| The recursion structure has hidden dependencies that prevent proving fuel sufficiency | H | M | Alternative: replace fuel-based termination with well-founded recursion on (depth, chain_position) lexicographic order. This is a refactor but uses the same mathematical argument. |
| Cross-chain sorry (line 5969) has different structure than single-direction sorries | M | M | Read the cross-chain proof carefully. It likely has the same fuel=0 pattern. If it uses a different mechanism, handle in Phase 3. |
| Wiring from forward_F/backward_P to `bfmcs_from_mcs_temporally_coherent` has gaps | M | L | The wiring through `boxClassFamilies` and `shifted_fmcs` is documented in Completeness.lean. Previous plans (v10/v11) mapped this path. If gaps exist, they are structural (not mathematical) and can be bridged. |

## Implementation Phases

### Phase 1: Analyze Fuel Recursion Structure [NOT STARTED]

**Goal**: Understand exactly how fuel is consumed in the bounded witness proofs, and determine whether B*B+1 is provably sufficient or whether a different termination argument is needed.

**Tasks**:
- [ ] Read `restricted_combined_bounded_witness_fueled` (lines 5763-5831) in detail
- [ ] Read `restricted_backward_bounded_witness_fueled` (lines 5605-5672) in detail
- [ ] Trace the recursion: at each recursive call, identify how fuel, depth d, and chain position n change
- [ ] Verify that `deferral_restricted_mcs_F_bounded_upper` gives d < B at every recursive entry
- [ ] Determine: does each recursive call STRICTLY decrease either d or fuel? If so, prove the lexicographic termination
- [ ] Decide between two approaches: (A) prove fuel B*B+1 suffices, or (B) replace fuel with well-founded recursion on a decreasing measure
- [ ] Document the recursion invariant: at each call, `fuel >= f(d, n_remaining)` for some function f

**Timing**: 1 hour

**Files to read**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (lines 5600-5850) -- bounded witness infrastructure
- `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` -- closure_F_bound, deferral_restricted_mcs_F_bounded_upper

**Verification**:
- Clear understanding of recursion structure documented as comments
- Decision on approach (A) vs (B) with justification

---

### Phase 2: Close Fuel=0 Sorry for Forward F Direction [NOT STARTED]

**Goal**: Prove the fuel=0 branch is unreachable in `restricted_combined_bounded_witness_fueled`, eliminating the sorry at line 5777.

**Tasks**:
- [ ] If approach (A): Add a precondition or auxiliary lemma showing that at each recursive call, the new depth d' satisfies d' < d (or d' = d but chain position advanced), and total recursion depth is bounded by B*B
- [ ] If approach (A): Prove that when fuel = 0 and d >= 1, the hypotheses (h_iter_in, h_iter_not) are contradictory given that d < B and all prior calls consumed at most B*B fuel
- [ ] If approach (B): Replace the `match fuel` structure with a well-founded recursion using `Prod.Lex` on `(steps_remaining, depth)` or a custom measure
- [ ] Prove the sorry-free version of `restricted_combined_bounded_witness_fueled`
- [ ] Verify via `lean_verify` that the theorem is sorry-free
- [ ] Verify `restricted_combined_bounded_witness` (the wrapper, line 5839) is now sorry-free

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- bounded witness proofs

**Verification**:
- `lean_verify` on `restricted_combined_bounded_witness_fueled`: sorry-free
- `lean_verify` on `restricted_combined_bounded_witness`: sorry-free
- `lake build` succeeds

---

### Phase 3: Close Fuel=0 Sorry for Backward P Direction [NOT STARTED]

**Goal**: Prove the fuel=0 branch is unreachable in `restricted_backward_bounded_witness_fueled` (line 5619) and the cross-chain variant (line 5969).

**Tasks**:
- [ ] Apply the same technique from Phase 2 to `restricted_backward_bounded_witness_fueled`
- [ ] Close the sorry at line 5619
- [ ] Identify and close the cross-chain sorry at line 5969
- [ ] Verify all three backward/cross-chain bounded witness theorems are sorry-free
- [ ] Verify that `restricted_backward_to_combined_P_witness` (P-direction cross-chain) is sorry-free

**Timing**: 1 hour (symmetric to Phase 2, reuses the same technique)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- backward bounded witness proofs

**Verification**:
- `lean_verify` on backward bounded witness theorems: sorry-free
- `lean_verify` on cross-chain P-witness: sorry-free
- `lake build` succeeds

---

### Phase 4: Wire Forward_F and Backward_P to FMCS Temporal Coherence [NOT STARTED]

**Goal**: Connect the sorry-free bounded witness results to the `TemporalCoherentFamily` structure needed by the truth lemma.

**Tasks**:
- [ ] Verify that `restricted_forward_chain_forward_F` (line 3163) and its backward analog are now sorry-free (they depend on the bounded witness chain)
- [ ] Trace the path from `restricted_forward_chain_forward_F` to `succ_chain_forward_F` for the SuccChainFMCS
- [ ] If `succ_chain_forward_F` exists and depends only on the bounded witness: verify it's now sorry-free
- [ ] If additional wiring is needed: build the connection from `restricted_succ_chain_fam` forward_F to the FMCS `forward_F` field
- [ ] Verify that `Z_chain_forward_F` and `Z_chain_backward_P` in UltrafilterChain.lean (referenced by Completeness.lean) are connected to the restricted chain results
- [ ] If the wiring goes through DovetailedChain.lean or a different path, map that path and close any intermediate sorries

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- FMCS coherence wiring
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- Z_chain temporal coherence (if needed)
- `Theories/Bimodal/Metalogic/Algebraic/DovetailedChain.lean` -- dovetailed FMCS (if wiring goes through here)

**Verification**:
- `lean_verify` on the FMCS forward_F and backward_P fields: sorry-free
- `lake build` succeeds

---

### Phase 5: Close `bfmcs_from_mcs_temporally_coherent` [NOT STARTED]

**Goal**: Prove the isolated sorry at Completeness.lean:237 using the sorry-free temporal coherence from Phase 4.

**Tasks**:
- [ ] Read `bfmcs_from_mcs_temporally_coherent` (Completeness.lean:231-237) and its proof outline
- [ ] The proof must show: for each family in `boxClassFamilies`, the family satisfies `forward_F` and `backward_P`
- [ ] Each family is a `shifted_fmcs (SuccChainFMCS S) delta` for some `SerialMCS S` -- verify this structure
- [ ] Connect the Phase 4 results: the SuccChainFMCS has sorry-free temporal coherence, and shifting preserves it
- [ ] Write the proof body replacing `sorry`
- [ ] Verify via `lean_verify` that `bfmcs_from_mcs_temporally_coherent` is sorry-free

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- the isolated sorry

**Verification**:
- `lean_verify` on `bfmcs_from_mcs_temporally_coherent`: sorry-free
- `lean_verify` on `completeness_over_Int`: sorry-free
- `lean_verify` on `discrete_completeness_fc`: sorry-free
- `lake build` succeeds with no new sorry warnings in Completeness.lean

---

### Phase 6: Verification and Cleanup [NOT STARTED]

**Goal**: Full verification that the completeness theorems are sorry-free, and cleanup of any dead code.

**Tasks**:
- [ ] Run `lake build` and verify clean build
- [ ] Run `lean_verify` on all key theorems:
  - `bfmcs_from_mcs_temporally_coherent`
  - `bundle_validity_implies_provability`
  - `completeness_over_Int`
  - `discrete_completeness_fc`
- [ ] Grep for remaining sorries in SuccChainFMCS.lean -- document which are in deprecated/unused paths vs active paths
- [ ] Update docstrings in Completeness.lean to reflect sorry-free status
- [ ] Update module-level documentation in SuccChainFMCS.lean

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- documentation updates
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- documentation updates

**Verification**:
- All `lean_verify` checks pass (sorry-free)
- `lake build` clean
- No regressions in other modules

## Testing & Validation

- [ ] `lake build` succeeds with no regressions
- [ ] `lean_verify` confirms `completeness_over_Int` is sorry-free (no axioms beyond standard Lean axioms)
- [ ] `lean_verify` confirms `discrete_completeness_fc` is sorry-free
- [ ] Grep for `sorry` in Completeness.lean shows only `dense_completeness_fc` (expected, separate issue)
- [ ] All theorems in the dependency chain verified individually: bounded_witness -> forward_F -> temporal_coherence -> bfmcs_temporally_coherent -> bundle_validity -> completeness_over_Int

## Artifacts & Outputs

- Sorry-free `completeness_over_Int` theorem
- Sorry-free `discrete_completeness_fc` theorem
- Sorry-free bounded witness infrastructure in SuccChainFMCS.lean
- Updated documentation reflecting sorry-free completeness status

## Rollback/Contingency

**If fuel sufficiency cannot be proven** (Phase 1 determines approach is wrong):
- Fallback to well-founded recursion on a custom measure (approach B)
- If the mathematical argument is flawed (fuel is genuinely insufficient), increase fuel bound and re-analyze
- Last resort: use `Decidable.em` on whether F(psi) is resolved before the scheduler reaches it, combined with the dovetailed chain from DovetailedChain.lean

**If wiring gaps exist** (Phase 4/5):
- The SuccChainFMCS -> boxClassFamilies -> BFMCS path may have structural gaps
- Map the exact dependency chain using `lean_verify` on intermediate theorems
- Build bridge lemmas as needed (these are structural, not mathematical)

**Partial progress preservation**:
- Each phase commits independently
- If Phase 2 succeeds but Phase 3 fails, the F-direction is still sorry-free
- If Phases 2-3 succeed but Phase 4 fails, the bounded witness results are sorry-free even if completeness isn't wired
