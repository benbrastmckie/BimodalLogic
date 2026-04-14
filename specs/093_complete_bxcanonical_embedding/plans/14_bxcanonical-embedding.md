# Implementation Plan: Close BXCanonical Embedding (v14 -- Ordered Defect-Discharge Chain)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 22 hours
- **Dependencies**: None (OrderedSeedConsistency.lean completed, all infrastructure proved)
- **Research Inputs**: reports/14_team-research.md, reports/13_long-term-solution.md
- **Artifacts**: plans/14_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4

## Overview

Six sorry sites remain in `RootScopedChain.lean` (lines 790, 816, 823, 876, 881, 886), all downstream of a single architectural blocker: the round-robin chain (`rr_fwd_chain`) cannot prove `forward_F` because `enriched_fwd_exists` returns a disjunction (`target in M' OR F(target) in M'`). Report 14 (4-teammate consensus) identifies the solution: replace the round-robin chain with an ordered defect-discharge chain that picks the BX11-earliest defect as target, using `enriched_resolving_seed_consistent` to guarantee the target is DIRECTLY in the Lindenbaum seed (not via disjunction). Lines 1-684 (library lemmas, FMCS/BFMCS structure definitions, `g_content`/`box_stable` proofs) are fully proved and remain unchanged. Definition of done: `lake build` succeeds with zero sorry in RootScopedChain.lean, and `dd_countermodel` compiles without sorry-dependent theorems.

### Research Integration

- **Report 14** (team-research.md): All 4 teammates converge on ordered defect-discharge chain. Key finding: when the fold target has the earliest BX11 witness, only cases 1 or 2 fire (never case 3), guaranteeing the target is DIRECT in the compound. Three gaps identified: (1) BX11 compound construction -- resolved via `enriched_fwd_fold` with earliest-witness ordering; (2) defect count non-monotonicity -- resolved via fixed-length chain with |sigma| steps; (3) backward Until step transfer -- identified as FATAL for `restricted_buc`, recommended deferral or seed enrichment.
- **Report 13** (long-term-solution.md): Original architecture definition. OrderedSeedConsistency theorem, F-defect monotonicity, chain construction. All foundational lemmas now proved in OrderedSeedConsistency.lean.

### Prior Plan Reference

Plan v13 (50 hours, 5 phases) was the first plan for this approach. Phase 1 (OrderedSeedConsistency) is COMPLETED with 0 sorry. Phase 2 (forward chain) is IN PROGRESS but blocked on the forward_F restructuring. Key lessons: (a) the round-robin chain approach is a dead end for forward_F; (b) 50 hours was overestimated for Phase 1 but the chain restructuring was underestimated; (c) backward Until coherence is the highest-risk item (report 14 gives 50% confidence). This plan focuses exclusively on the 6 remaining sorry sites with phases sized at 2-4 hours each, informed by report 14's refined strategy.

### Roadmap Alignment

- Closes the sole remaining active-path sorry blocking `bx_completeness` at Completeness.lean:154
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Unblocks task 95 (`#print axioms` audit on `bx_completeness`)

## Goals & Non-Goals

**Goals**:
- Replace `rr_fwd_chain` with an ordered defect-discharge forward chain that guarantees target resolution
- Prove `rr_fwd_chain_forward_F` (line 790) via defect discharge + identity tail
- Prove `dd_fmcs_forward_F` negative-t case (line 816) via g_content propagation to forward chain
- Prove `dd_fmcs_backward_P` (line 823) symmetrically via h_content and backward chain
- Prove `dd_bfmcs_restricted_tc` (line 876) via forward_F + backward_P + forward_G + backward_H
- Prove `dd_bfmcs_restricted_fuc` (line 886) via forward_F + BX9/BX10 Until extraction
- Prove `dd_bfmcs_restricted_buc` (line 881) via seed enrichment or architectural fallback
- Achieve `lake build` with zero sorry in RootScopedChain.lean

**Non-Goals**:
- Modifying OrderedSeedConsistency.lean (completed, 0 sorry)
- Modifying lines 1-684 of RootScopedChain.lean (fully proved infrastructure)
- Modifying the existing round-robin chain definitions (keep as dead code or remove in cleanup)
- Proving unrestricted coherence properties (restricted suffices for completeness)
- Dense time completeness (separate task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BX11 fold with ordered target: proving case 3 never fires requires formalizing earliest-witness argument in Lean | H | M (25%) | The semantic argument is sound (linear order on witnesses via `temp_linearity_mcs`). Reuse existing `enriched_fwd_fold` structure; add ordered-target guarantee as wrapper lemma. |
| Defect count termination: non-monotonicity across steps complicates well-founded recursion | M | M (20%) | Use fixed-length chain (|sigma_list| steps) with Nat.rec. Avoid well-founded recursion entirely. Defect-free terminal proved by counting argument after |sigma| steps. |
| Backward Until step transfer (`restricted_buc`) has no known syntactic proof from chain structure | H | H (50%) | Primary: extend seed consistency to include Until formulas (Path C from report 14). Fallback: prove with `sorry` and spawn a sub-task for architectural investigation. The other 5 sorries are independent of this one. |
| Lean formalization of compound extraction (chi in compound -> chi in Lindenbaum extension) involves technical MCS machinery | M | L (15%) | The existing `enriched_resolving_seed_consistent` already handles this pattern. Reuse its proof structure for the ordered variant. |
| Backward chain construction for `backward_P` mirrors forward chain but may have asymmetric obstacles | M | L (10%) | Forward and backward are structurally symmetric (G/g_content vs H/h_content, F vs P, BX11 vs BX11'). Implement forward first, then copy the pattern. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Ordered Defect-Discharge Forward Chain [NOT STARTED]

**Goal**: Replace `rr_fwd_chain` with a finite ordered defect-discharge chain that resolves the BX11-earliest defect at each step, using `enriched_resolving_seed_consistent` for guaranteed target resolution.

**Tasks**:
- [ ] Define `discharge_fwd_step`: given MCS M with F-defects in sigma_list, find BX11-earliest defect via `find_earliest_witness`, build resolving seed with target directly included (not via disjunction), Lindenbaum-extend to MCS M'
- [ ] Prove `discharge_fwd_step_target_in`: the resolved target psi_j is directly in M' (from seed inclusion, not from `enriched_fwd_exists` disjunction)
- [ ] Prove `discharge_fwd_step_g_content`: g_content(M) subset M' (from seed construction)
- [ ] Prove `discharge_fwd_step_f_carry`: for each chi in sigma_list with F(chi) in M, either chi in M' or F(chi) in M' (from compound extraction)
- [ ] Define `discharge_fwd_chain`: iterate `discharge_fwd_step` for sigma_list.length steps using `Nat.rec`, then identity tail (repeat terminal for all indices beyond chain length)
- [ ] Prove `discharge_fwd_chain_g_content`: g_content propagation holds at each step and in identity tail

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add new definitions and lemmas after line 684, before the sorry block

**Verification**:
- `lake build` succeeds (existing sorry sites unchanged)
- New chain definitions compile without sorry
- `discharge_fwd_step_target_in` has no sorry

---

### Phase 2: Prove forward_F (Close Lines 790 and 816) [NOT STARTED]

**Goal**: Prove that F(psi) in chain(n) implies psi in chain(s) for some s > n, closing `rr_fwd_chain_forward_F` and the negative-t case of `dd_fmcs_forward_F`.

**Tasks**:
- [ ] Prove `discharge_fwd_chain_forward_F`: F(psi) in chain(n) implies psi in chain(s) for some s > n. Two cases: (a) n < sigma_list.length: psi is a defect, eventually becomes BX11-earliest target at some step m >= n, psi in chain(m+1); (b) n >= sigma_list.length (identity tail): chain(n) is defect-free terminal, F(psi) in terminal with psi in sigma implies psi in terminal
- [ ] Prove terminal is defect-free: after sigma_list.length discharge steps, all F-defects in sigma_list have been resolved at least once. Use counting argument: each step resolves the earliest defect; after |sigma| steps every formula in sigma_list has been the target at least once
- [ ] Replace `rr_fwd_chain_forward_F` sorry (line 790) with proof delegating to `discharge_fwd_chain_forward_F` (may require wiring the new chain into the existing `rr_fwd_chain` signature, or replacing the signature)
- [ ] Close `dd_fmcs_forward_F` negative-t sorry (line 816): F(psi) in backward chain at t < 0. Propagate via g_content to M_0, then use forward chain forward_F

**Timing**: 4 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at lines 790 and 816

**Verification**:
- `rr_fwd_chain_forward_F` has no sorry
- `dd_fmcs_forward_F` has no sorry
- `lake build` succeeds

---

### Phase 3: Prove backward_P (Close Line 823) [NOT STARTED]

**Goal**: Prove `dd_fmcs_backward_P` symmetrically to forward_F, using h_content propagation and backward defect-discharge chain.

**Tasks**:
- [ ] Define `discharge_bwd_step` and `discharge_bwd_chain`: symmetric to forward using h_content, P-formulas, BX11' (past linearity), `enriched_bwd_exists`/`enriched_resolving_seed_consistent` past variant
- [ ] Prove `discharge_bwd_chain_backward_P`: P(psi) in chain(n) implies psi in chain(s) for some s < n
- [ ] Close `dd_fmcs_backward_P` sorry (line 823): delegate to backward chain result for t <= 0, propagate via h_content for t > 0

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add backward chain, replace sorry at line 823

**Verification**:
- `dd_fmcs_backward_P` has no sorry
- `lake build` succeeds

---

### Phase 4: Prove Restricted Temporal Coherence and Forward Until (Close Lines 876, 886) [NOT STARTED]

**Goal**: Prove `dd_bfmcs_restricted_tc` and `dd_bfmcs_restricted_fuc` using the proved forward_F and backward_P.

**Tasks**:
- [ ] Prove `dd_bfmcs_restricted_tc` (line 876): restricted temporal coherence follows from forward_G (g_content propagation), backward_H (h_content propagation), forward_F (Phase 2), and backward_P (Phase 3). For each formula in deferralClosure(root): if G(phi) in chain(t) then phi in chain(t+1) (g_content); if F(phi) in chain(t) then phi in chain(s) for s > t (forward_F); symmetric for H and P
- [ ] Prove `dd_bfmcs_restricted_fuc` (line 886): forward Until coherence. Given (phi U psi) in fam.mcs t with phi, psi in subformulaClosure(root): (a) F(psi) in chain(t) by BX10; (b) psi in chain(s) for some s > t by forward_F; (c) (phi U psi) persists through [t, s) by BX5 (self_accum) + BX9 (at each step where psi absent, phi holds); (d) phi holds on [t, s) by BX9 extraction from the persisted (phi U psi)

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at lines 876 and 886

**Verification**:
- `dd_bfmcs_restricted_tc` has no sorry
- `dd_bfmcs_restricted_fuc` has no sorry
- `lake build` succeeds

---

### Phase 5: Prove Restricted Backward Until Coherence (Close Line 881) [NOT STARTED]

**Goal**: Prove `dd_bfmcs_restricted_buc` or identify the precise remaining obstacle.

**Tasks**:
- [ ] Attempt primary approach (seed enrichment, Path C from report 14): extend the resolving seed to include Until formulas from M, prove the enriched seed is consistent using BX10 (`(phi U psi) -> F(psi)`) to subsume Until-witnesses under the F-ordering argument
- [ ] If seed enrichment succeeds: prove backward Until step transfer -- `(phi U psi) in chain(r+1)` and `phi in chain(r)` implies `(phi U psi) in chain(r)` from Until-carry in seed
- [ ] If seed enrichment fails: attempt Path B (inductive descent) -- derive (phi U psi) in chain(r) from (phi U psi) in chain(r+1) via h_content propagation + BX axioms
- [ ] If both fail: mark with sorry and detailed obstacle description; the other 5 sorry sites are independent and fully closed. Spawn a sub-task for architectural investigation

**Timing**: 4 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace sorry at line 881

**Verification**:
- `dd_bfmcs_restricted_buc` has no sorry (or documented sorry with obstacle analysis)
- `lake build` succeeds

---

### Phase 6: Verification and Cleanup [NOT STARTED]

**Goal**: Full verification that all sorry sites are closed, axiom audit, and cleanup of dead code.

**Tasks**:
- [ ] Run `lake build` from clean state
- [ ] Run `grep -n sorry RootScopedChain.lean` and verify zero matches (or only the documented backward Until sorry if Phase 5 used fallback)
- [ ] Run `#print axioms dd_countermodel` and verify no sorry-dependent axioms
- [ ] If all 6 sorries closed: run `#print axioms bx_completeness` and verify only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Remove or clearly mark dead code (old `rr_fwd_chain` if replaced, unused lemmas)
- [ ] Add docstrings to new definitions referencing Burgess 1984 / Goldblatt 1992

**Timing**: 3 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- cleanup and documentation

**Verification**:
- `lake build` succeeds with zero errors
- Sorry count is 0 (or 1 if backward Until fallback)
- Axiom audit clean

## Testing & Validation

- [ ] `lake build` succeeds with zero errors
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero matches (or only the documented backward Until sorry)
- [ ] `#print axioms dd_countermodel` shows no sorry-dependent axioms
- [ ] `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound` (if all 6 closed)
- [ ] No new sorry introduced in any file
- [ ] `dd_countermodel` theorem compiles end-to-end

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- modified (sorry sites replaced with proofs)
- `specs/093_complete_bxcanonical_embedding/plans/14_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

The changes are confined to `RootScopedChain.lean` lines 686-886. Lines 1-684 are untouched.

1. **Partial success (5 of 6 sorries closed)**: Keep all proved theorems. The backward Until sorry (line 881) is independent of the other 5. Document the obstacle and spawn a focused sub-task.

2. **Forward_F approach fails**: If the ordered defect-discharge chain cannot prove forward_F in Lean (despite the mathematical argument being sound), revert to the round-robin chain with sorry and document the specific Lean formalization obstacle.

3. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores the 6-sorry state from commit `ad0aed4f8`.
