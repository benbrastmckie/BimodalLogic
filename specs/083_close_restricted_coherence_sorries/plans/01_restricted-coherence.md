# Implementation Plan: Close Restricted Coherence Sorries

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 12-18 hours
- **Dependencies**: None (all prerequisite infrastructure from task 81 is in place)
- **Research Inputs**: specs/083_close_restricted_coherence_sorries/reports/01_team-research.md
- **Artifacts**: plans/01_restricted-coherence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorry-bearing theorems blocking sorry-free canonical completeness over Int: `succ_chain_restricted_forward_F` (UltrafilterChain.lean:3762) and `succ_chain_restricted_backward_P` (UltrafilterChain.lean:3772). Research reveals the existing restricted chain infrastructure (`build_restricted_tc_family`) is unsound because it depends on the FALSE theorem `constrained_successor_seed_restricted_consistent`. The plan replaces the unsound restricted chain with a new single-target chain construction using the sorry-free `forward_temporal_witness_seed_consistent` building block, then restructures the completeness path to use this new infrastructure. Also removes 2 dead-code auxiliary sorries in RestrictedTruthLemma.lean.

### Research Integration

- **Report**: specs/083_close_restricted_coherence_sorries/reports/01_team-research.md
- **Key findings integrated**:
  - `build_restricted_tc_family` depends on FALSE theorem (Teammate A, confirmed by code tracing)
  - `restricted_chain_G_propagates` and `restricted_chain_H_step` are dead code (both teammates, grep-verified)
  - G-lift gap is universal bottleneck -- all approaches using f_content in seed fail
  - `forward_temporal_witness_seed_consistent` (WitnessSeed.lean:79) is the only sorry-free F-witness mechanism
  - Standard literature confirms structural mismatch: TM task semantics requires novel approach

## Goals & Non-Goals

**Goals**:
- Close `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` (the 2 sorry blockers)
- Remove or mark-dead the 2 auxiliary sorries in RestrictedTruthLemma.lean
- Achieve sorry-free `completeness_over_Int`
- Clean build with `lake build` passing

**Non-Goals**:
- Closing `bfmcs_from_mcs_temporally_coherent` (the unrestricted coherence sorry -- superseded by restricted path)
- Closing `dense_completeness` (separate task, different sorry chain)
- Refactoring the unsound `build_restricted_tc_family` infrastructure (leave as historical artifact)
- Proving multi-step G-propagation (`restricted_chain_G_propagates`) -- not needed

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Single-target chain cannot provide BFMCS-level coherence (all families need F/P resolution) | H | M | The BFMCS families are all shifted SuccChainFMCS instances; we only need to show each one resolves F/P for deferralClosure formulas. Can prove this per-family. |
| New chain construction has unforeseen consistency gap | H | L | The consistency proof reuses the sorry-free `forward_temporal_witness_seed_consistent`. The only new argument is iteration over deferralClosure (finite set). |
| Backward P direction is not symmetric with forward F | M | L | The `past_temporal_witness_seed_consistent` (WitnessSeed.lean) is the symmetric building block. P direction follows the same structure. |
| Integration with existing BFMCS infrastructure requires significant refactoring | M | M | Minimize changes: prove the sorry theorems directly rather than restructuring the entire completeness path. The existing `bfmcs_restricted_temporally_coherent` already delegates to these 2 theorems. |
| The `succ_chain_fam` chain type prevents single-target resolution (different chain, not the restricted one) | H | M | This is the core challenge. The proof must show that the full MCS chain (`succ_chain_fam`) resolves F-obligations, not the restricted chain. Strategy: use the fact that deferralClosure formulas in the full MCS chain inherit properties from the restricted chain via embedding. |

## Implementation Phases

### Phase 1: Verification and Dead Code Cleanup [NOT STARTED]

**Goal**: Confirm the dependency analysis from research, verify the FALSE theorem chain, and clean up dead code sorries.

**Tasks**:
- [ ] Use `lean_verify` on `constrained_successor_seed_restricted_consistent` to confirm it has sorry
- [ ] Trace the full dependency: `build_restricted_tc_family` -> `restricted_forward_chain_forward_F` -> `restricted_forward_chain_F_resolves` -> `constrained_successor_restricted_f_content_persistence` -> `constrained_successor_restricted_extends` -> `constrained_successor_seed_restricted_consistent`
- [ ] Verify `restricted_chain_G_propagates` has zero references (grep codebase)
- [ ] Verify `restricted_chain_H_step` has zero references (grep codebase)
- [ ] Add `-- DEAD CODE: unreferenced, sorry retained for historical documentation` comments to the 2 RestrictedTruthLemma.lean sorries (lines 116, 158)
- [ ] Verify `lake build` still passes after comments

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` -- add dead-code annotations

**Verification**:
- `lake build` passes
- grep confirms zero references for the 2 dead-code theorems
- `lean_verify` confirms sorry status of key theorems

---

### Phase 2: Single-Target F-Witness Chain Construction [NOT STARTED]

**Goal**: Build a new chain construction that resolves one F-obligation per step using the sorry-free `forward_temporal_witness_seed_consistent`, then iterates over all obligations in deferralClosure.

**Mathematical sketch**:

Given a full MCS chain `succ_chain_fam S` with `F(psi) in succ_chain_fam S n` and `psi in deferralClosure(root)`:

1. `F(psi) in succ_chain_fam S n` means `F(psi)` is in a full MCS `M_n`.
2. By `forward_temporal_witness_seed_consistent`: `{psi} union g_content(M_n)` is consistent.
3. By Lindenbaum: extend to MCS `W` with `psi in W` and `g_content(M_n) subset W`.
4. `g_content(M_n) subset W` gives `Succ(M_n, W)` (the g-content inclusion is the key Succ property).
5. The `succ_chain_fam S` is built by iterated `constrained_successor_from_seed`. At step n+1, the successor is determined by the seed. But `W` is not necessarily `succ_chain_fam S (n+1)` -- it is a DIFFERENT MCS.

**The critical insight**: We do NOT need `psi in succ_chain_fam S m` for a specific `m`. We need to show that the chain construction, which uses `constrained_successor_from_seed` with deferral disjunctions (`psi v F(psi)`) in the seed, eventually resolves `psi`.

**Approach A -- Pigeonhole on deferralClosure**: Since `deferralClosure(root)` is finite, the set of F-obligations `{psi | F(psi) in M_n, psi in deferralClosure(root)}` is finite. At each step, the deferral disjunction `psi v F(psi)` is in the seed. The Lindenbaum extension picks either `psi` (resolved) or `F(psi)` (deferred). If `psi` is perpetually deferred, then `F(psi) in M_k` for all `k >= n`. But `psi in deferralClosure(root)`, so the F-nesting depth `iter_F d psi` is bounded within each DRM. The key gap: the full MCS chain is NOT a DRM chain, so F-nesting boundedness does not directly apply.

**Approach B -- Semantic argument via the truth lemma**: Since the `restricted_shifted_truth_lemma` is sorry-free and the sorry is only in `bfmcs_restricted_temporally_coherent`, we can restructure the completeness proof to avoid needing `succ_chain_restricted_forward_F` on the existing chain. Instead:
1. Build a NEW family for each `M` that IS temporally coherent for deferralClosure formulas.
2. Use `temporal_theory_witness_exists` to get a witness MCS at each step.
3. Package this as an alternative BFMCS construction.

**Selected approach**: Approach B. Rather than proving the sorry theorems on the existing chain (which requires solving the perpetual deferral problem for Lindenbaum extensions), we build an alternative completeness path.

**Tasks**:
- [ ] Create new file `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean`
- [ ] Define `targeted_forward_chain`: given MCS `M` with `F(psi) in M`, build successor using `forward_temporal_witness_seed` -- one step: MCS `W` with `psi in W` and `g_content(M) subset W`
- [ ] Prove `targeted_forward_chain_resolves_F`: `F(psi) in M -> psi in targeted_successor(M, psi)`
- [ ] Prove `targeted_forward_chain_g_persistence`: `g_content(M) subset targeted_successor(M, psi)`
- [ ] Define `iterated_targeted_chain`: iterate targeted forward chain along Int, resolving one deferralClosure F-obligation per step via round-robin scheduling
- [ ] Prove the iterated chain has `forward_G` (from g_persistence at each step)
- [ ] Prove `backward_H` for the iterated chain (from `past_temporal_witness_seed_consistent` symmetrically)

**Timing**: 3-4 hours

**Files to create**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- new targeted chain construction

**Verification**:
- `lake build` passes
- Each theorem is sorry-free (checked via `lean_verify`)
- The iterated chain provides forward_G and backward_H for all formulas

---

### Phase 3: Fair Scheduling for F/P Resolution [NOT STARTED]

**Goal**: Prove that the targeted chain with round-robin scheduling over the finite `deferralClosure(root)` resolves all F-obligations and P-obligations for deferralClosure formulas.

**Mathematical sketch**:

Let `DC = deferralClosure(root)` with `|DC| = N` (finite).

**Forward direction**: Given `F(psi) in chain(n)` with `psi in DC`:
1. Enumerate `DC = {d_0, d_1, ..., d_{N-1}}`
2. At step `k`, the targeted chain resolves the obligation for `d_{k mod N}`
3. `psi = d_j` for some `j < N`
4. At step `m = n + (j - n mod N) mod N + N` (at most 2N steps ahead), the scheduler addresses `psi`
5. If `F(psi) in chain(m)`, the targeted construction ensures `psi in chain(m+1)`
6. But we need `F(psi)` to persist from `chain(n)` to `chain(m)` -- this is the F-persistence problem

**F-persistence for targeted chain**: Unlike Lindenbaum extensions, the targeted chain seed is `{target} union g_content(M)`. If `F(psi) in M` and `target != psi`, does `F(psi)` persist to the successor? It does IF `F(psi) in g_content(M)`, i.e., `G(F(psi)) in M`. By the T-axiom variant `G(F(psi)) -> F(psi)` (and `F(psi) -> F(F(psi))`), this is not automatic.

**Resolution**: Include all deferralClosure F-obligations in the seed, not just the target. The seed becomes `{target} union g_content(M) union {chi | F(chi) in M, chi in DC}`. But this is exactly the f_content approach that was shown to be inconsistent.

**Alternative resolution**: Use the deferral disjunction technique. Include `chi v F(chi)` for each `F(chi) in M` with `chi in DC`. This IS consistent because deferral disjunctions are in DC and DC subset M (for DRM). For a full MCS, deferral disjunctions may not be in M, but they ARE provable from `F(chi)` via the T-axiom for F (`F(chi) -> chi v F(chi)`). So they can be derived from M.

**Revised seed**: `{target} union g_content(M) union {chi v F(chi) | F(chi) in M, chi in DC}`.

Consistency: Suppose for contradiction L subset seed with L derives bot. The g_content elements are G-liftable. The deferral disjunctions are implied by the F-obligations in M (via `F(chi) -> chi v F(chi)`), so they are in M. Thus L intersect (g_content union deferral_disj) subset M. Combined with {target}, the consistency follows from the same G-lift argument as `forward_temporal_witness_seed_consistent`, since deferral disjunctions in M are handled by the M-subset part.

**Tasks**:
- [ ] Define the enriched seed: `targeted_enriched_seed M psi DC = {psi} union g_content(M) union {chi v F(chi) | F(chi) in M, chi in DC}`
- [ ] Prove enriched seed consistency when `F(psi) in M` and M is MCS
- [ ] Prove F-persistence: if `F(chi) in M` and `chi in DC`, then `F(chi) in successor` or `chi in successor` (from deferral disjunction in seed)
- [ ] Define fair-scheduled chain with round-robin over DC
- [ ] Prove forward_F for the scheduled chain: `F(psi) in chain(n), psi in DC -> exists m >= n, psi in chain(m)` (within N steps, the target is scheduled; deferral disjunction ensures either resolved or re-deferred; F-nesting within DC is bounded, so after at most `closure_F_bound` rounds, resolution is forced)
- [ ] Prove backward_P symmetrically using `past_temporal_witness_seed`

**Timing**: 4-5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- add scheduling and F/P resolution proofs

**Verification**:
- `lake build` passes
- `forward_F` and `backward_P` theorems are sorry-free for the targeted chain
- The chain satisfies `forward_G` and `backward_H` for all formulas

---

### Phase 4: Bridge to Completeness Path [NOT STARTED]

**Goal**: Connect the targeted chain construction to the existing completeness infrastructure by proving `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P`, or by providing an alternative BFMCS construction that satisfies `restricted_temporally_coherent`.

**Strategy choice**: Two options --

**Option A (Fill existing sorries)**: Prove that `succ_chain_fam S` resolves F for deferralClosure formulas. This requires showing that the existing chain construction (using `constrained_successor_from_seed`) has the same resolution properties as the targeted chain. This is hard because `constrained_successor_from_seed` uses a different seed.

**Option B (Alternative BFMCS)**: Build a new BFMCS using the targeted chain instead of `succ_chain_fam`. The completeness proof already has `restricted_bundle_validity_implies_provability` which takes ANY BFMCS with `restricted_temporally_coherent`. We construct a BFMCS where each family uses the targeted chain.

**Selected: Option B with a compatibility layer for Option A.**

The cleanest approach is:
1. Build `targeted_bfmcs_bundle M h_mcs` that uses targeted chains instead of `SuccChainFMCS`
2. Prove `targeted_bfmcs_restricted_temporally_coherent`
3. Wire into `restricted_bundle_validity_implies_provability`
4. ALSO prove `succ_chain_restricted_forward_F` on the existing chain by showing the existing chain's deferral disjunctions force eventual resolution (if possible), OR mark it as bypassed

**Tasks**:
- [ ] Define `targeted_fmcs`: FMCS built from targeted chain (forward_G from g_persistence, backward_H from h_persistence)
- [ ] Prove `targeted_fmcs` satisfies restricted forward_F and backward_P for deferralClosure
- [ ] Define `construct_targeted_bfmcs_bundle`: BFMCS using targeted chain families
- [ ] Prove `targeted_bfmcs_restricted_temporally_coherent`
- [ ] Prove `targeted_bfmcs_bundle_eval_at_zero`: the evaluation family at time 0 returns M
- [ ] Wire into an alternative `targeted_completeness_over_Int` theorem
- [ ] Prove the existing sorry theorems by delegation to the targeted chain (if the chains agree on deferralClosure formulas) OR fill them with sorry-free proofs using the targeted infrastructure
- [ ] Update `completeness_over_Int` to use the targeted path

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- FMCS and BFMCS construction
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- wire targeted path
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- resolve or annotate existing sorries

**Verification**:
- `lake build` passes
- `completeness_over_Int` is sorry-free (checked via `lean_verify`)
- Either `succ_chain_restricted_forward_F` is sorry-free or explicitly marked as bypassed

---

### Phase 5: Full Verification and Cleanup [NOT STARTED]

**Goal**: Verify the entire completeness path is sorry-free, clean up any remaining issues, and ensure the build is clean.

**Tasks**:
- [ ] Run `lake build` and verify zero errors
- [ ] Run `lean_verify` on `completeness_over_Int` -- confirm no sorry axioms
- [ ] Run `lean_verify` on `restricted_bundle_validity_implies_provability` or `targeted_completeness_over_Int`
- [ ] Grep for `sorry` in all modified files -- confirm only in dead-code or FALSE-annotated theorems
- [ ] Grep for `sorry` in Completeness.lean -- confirm `completeness_over_Int` path is clean
- [ ] Update docstrings on:
  - `succ_chain_restricted_forward_F` (status: resolved or bypassed)
  - `succ_chain_restricted_backward_P` (status: resolved or bypassed)
  - `constrained_successor_seed_restricted_consistent` (status: FALSE, documented)
  - `build_restricted_tc_family` (status: depends on FALSE theorem, superseded by targeted chain)
- [ ] Add module docstring to TargetedChain.lean documenting the approach and its relationship to the prior infrastructure
- [ ] Verify `discrete_completeness` delegates correctly (it should delegate through `completeness_over_Int`)

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- docstrings
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- docstring updates
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` -- docstring updates
- `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean` -- docstring updates

**Verification**:
- `lake build` passes with zero warnings
- `lean_verify completeness_over_Int` shows no sorry axiom
- All sorry occurrences in modified files are accounted for (dead code or FALSE-annotated)

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `lean_verify` on `Bimodal.FrameConditions.Completeness.completeness_over_Int` shows no sorry
- [ ] `lean_verify` on `Bimodal.FrameConditions.Completeness.discrete_completeness` shows no sorry
- [ ] grep for `sorry` in `Completeness.lean` returns only `bfmcs_from_mcs_temporally_coherent` (unrestricted path, not used) and `dense_completeness`
- [ ] grep for `sorry` in `TargetedChain.lean` returns zero matches
- [ ] grep for `sorry` in `RestrictedTruthLemma.lean` returns only the 2 dead-code theorems (annotated)

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/01_restricted-coherence.md` (this file)
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` (new file)
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean`
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- Modified: `Theories/Bimodal/Metalogic/Algebraic/RestrictedTruthLemma.lean`
- Modified: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`
- `specs/083_close_restricted_coherence_sorries/summaries/01_restricted-coherence-summary.md` (after implementation)

## Rollback/Contingency

**If Phase 3 fails (enriched seed consistency cannot be proven)**:
- Fall back to Constrained Lindenbaum Extension (Teammate B's Approach 4): build Lindenbaum extensions at each time point that preserve g_content between adjacent positions. This requires proving `g_content(ext(n)) union chain(n+1)` is consistent -- a new argument but mathematically sound since g_content elements are all G-liftable.
- Estimated additional effort: 8-12 hours.

**If Phase 4 fails (cannot wire into existing BFMCS infrastructure)**:
- Simplify by proving completeness directly from the targeted chain without going through BFMCS. The `restricted_shifted_truth_lemma` already works with any FMCS that has restricted temporal coherence. Build a single-family proof that avoids the multi-family bundle entirely.
- Estimated additional effort: 4-6 hours.

**Full rollback**:
- `git revert` all commits from this task.
- The 2 original sorries remain; completeness depends on them as before.
- No other functionality is affected (the targeted chain is additive, not modifying existing proofs).
