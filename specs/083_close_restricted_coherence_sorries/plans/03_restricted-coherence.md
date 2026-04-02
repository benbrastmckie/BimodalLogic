# Implementation Plan: Close Restricted Coherence Sorries (v3)

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 14-18 hours
- **Dependencies**: None (TargetedChain.lean from v1 phases 1-2 in place)
- **Research Inputs**: specs/083_close_restricted_coherence_sorries/reports/03_team-research.md, specs/083_close_restricted_coherence_sorries/reports/02_blocker-analysis.md
- **Artifacts**: plans/03_restricted-coherence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorries (`succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P`) blocking sorry-free `completeness_over_Int`. Previous plans failed on: (v1) multi-target F-persistence gap; (v2) enriched deferral seed inconsistency when target is a G-formula. This v3 plan uses a **finite resolving prefix** with **filtered compatible F-formulas** and **topological resolution ordering** on the acyclic blocking DAG over `deferralClosure(root)`. The chain processes DC obligations one at a time in topological order; at each step, the seed includes the target plus F-formulas for obligations not blocked by the target, preserving them through to their own resolution steps. After N resolution steps (one per DC formula), the chain continues with standard constrained successors.

### Research Integration

- **Round 3** (03_team-research.md): Blocking relation is acyclic (via TM linearity axiom); compatible F-preservation with topological ordering is the recommended approach; joint consistency of filtered F-formulas is the critical lemma.
- **Round 2** (02_blocker-analysis.md): Enriched seed with deferral disjunctions has concrete counterexample; all alternative approaches analyzed.
- **v1/v2 summaries**: TargetedChain.lean exists with sorry-free forward_G/backward_H. Enriched seeds fail for G-formula targets. Existing SuccChainFMCS f_step allows perpetual deferral.

## Goals & Non-Goals

**Goals**:
- Sorry-free `completeness_over_Int` and `discrete_completeness_fc`
- New `ResolvingFMCS` with restricted forward_F/backward_P for deferralClosure formulas
- New `resolvingBoxClassFamilies` bundle replacing `boxClassFamilies` in completeness path
- Clean `lake build`

**Non-Goals**:
- Proving original `succ_chain_restricted_forward_F` on `succ_chain_fam` (confirmed unprovable)
- Closing `bfmcs_from_mcs_temporally_coherent` or `dense_completeness`

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Joint consistency of filtered F-formulas fails | H | M | Fall back to single-F-formula seed (always consistent, proven by forward_temporal_witness_seed_consistent extended with one F-formula). Process DC with N^2 steps instead of N. |
| Acyclicity proof harder than sketched | M | L | Building blocks (linearity axiom, T-axiom, G-persistence) already formalized. Core argument is 4-5 derivation steps. |
| Topological ordering on Finset requires missing infrastructure | M | M | Use well-founded recursion directly via `Finite.wellFounded_of_trans_of_irrefl` (Mathlib). Avoid explicit topological sort. |
| F(chi) lost at blocker resolution steps despite filtered seed | H | M | By topological ordering, blockers processed first. After blockers done, F(chi) is compatible with all remaining targets. F(chi) persists from last blocker step to chi's step via seed inclusion. |
| Bundle property porting is complex | M | L | Bundle-level properties (modal_forward/backward, bundle_forward_F/P) depend on box_class_agree and temporal_theory_witness_exists -- MCS-level, not chain-specific. Direct port. |

## Implementation Phases

### Phase 1: Blocking Relation and Well-Foundedness [NOT STARTED]

**Goal**: Define the blocking relation on `deferralClosure(root)` and prove it is well-founded using TM linearity axiom.

The blocking relation: `blocks M chi psi := not SetConsistent ({chi} union g_content(M) union {F(psi)})`. Informally: resolving chi (putting chi in the successor) is incompatible with preserving F(psi).

**Tasks**:
- [ ] Define `blocks (M : Set Formula) (chi psi : Formula) : Prop`
- [ ] Prove `blocks_irrefl`: `F(chi) in M -> not (blocks M chi chi)` (from `forward_temporal_witness_seed_consistent`: `{chi} union g_content(M)` consistent, and `F(chi) in M` means `{chi} union g_content(M) union {F(chi)}` adds an M-element to a consistent subset of M extended with chi)
- [ ] Prove `blocks_asymmetric_on_DC`: if `F(chi) in M`, `F(psi) in M`, `chi in DC`, `psi in DC`, and `blocks M chi psi`, then `not (blocks M psi chi)` -- using TM linearity axiom: mutual blocking gives `F(G(neg(psi))) in M` and `F(G(neg(chi))) in M`; linearity collapses to `F(G(neg(psi) AND neg(chi)))` which with `F(psi)` and `F(chi)` derives contradiction
- [ ] Prove `blocks_acyclic`: `blocks` restricted to `{chi in DC | F(chi) in M}` is acyclic
- [ ] Derive `blocks_wellFounded`: well-founded relation on the relevant subset of DC, using `Finite.wellFounded_of_trans_of_irrefl` or direct construction

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean`

**Verification**:
- `lake build` passes
- `lean_verify` on `blocks_wellFounded` shows no sorry

---

### Phase 2: Filtered Seed Consistency [NOT STARTED]

**Goal**: Define the filtered seed that includes only F-formulas compatible with the current target, and prove its consistency.

Filtered seed: `{psi} union g_content(M) union {F(chi) | F(chi) in M, chi in DC, not (blocks M psi chi)}`.

Compatible F-formulas are those whose future obligation is not contradicted by resolving the target.

**Tasks**:
- [ ] Define `filtered_forward_seed M psi DC` collecting compatible F-formulas
- [ ] Prove individual compatibility: for each chi with `not (blocks M psi chi)`, `SetConsistent ({psi} union g_content(M) union {F(chi)})` (definition of non-blocking)
- [ ] Prove joint consistency: `filtered_forward_seed` is consistent
  - Primary approach: all non-target elements are in M (F(chi) in M), so `g_content(M) union {F(chi_1),...,F(chi_k)} subset M`, hence consistent. Adding psi: suppose inconsistent, then `g_content(M) union {F(chi_1),...,F(chi_k)} |- neg(psi)`. G-lift the g_content part, apply T-axiom. Derive `neg(psi) in M`. Since `{psi} union g_content(M)` is consistent by `forward_temporal_witness_seed_consistent`, the F-formulas are necessary. Show this contradicts individual compatibility.
  - Fallback: sequential construction adding one F(chi) at a time, proving each addition preserves consistency
- [ ] Define symmetric `filtered_backward_seed` and prove consistency
- [ ] Prove seed properties: target in seed, g_content subset seed, compatible F-formulas in seed

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean`

**Verification**:
- `lake build` passes
- `lean_verify` on `filtered_forward_seed_consistent` shows no sorry

---

### Phase 3: Resolving Chain and F-Resolution Proof [NOT STARTED]

**Goal**: Build the resolving chain that processes DC obligations in topological order of blocking relation using filtered seeds, and prove all F-obligations for DC formulas are resolved.

**Construction**: Given base MCS M0 and DC = deferralClosure(root):
1. Order DC elements `chi_1, ..., chi_N` so that if `chi_i` blocks `chi_j` then `i < j` (topological order of blocking DAG computed at M0).
2. For i = 1 to N: if `F(chi_i) in chain(i-1)`, build `chain(i) = Lindenbaum(filtered_forward_seed(chain(i-1), chi_i, DC))`. Otherwise `chain(i) = constrained_successor(chain(i-1))`.
3. For i > N: `chain(i) = constrained_successor(chain(i-1))`.
4. Backward chain built symmetrically.

**Key properties to prove**:
- `chi_i in chain(i)` when `F(chi_i) in chain(i-1)` (target in seed, seed subset extension)
- `g_content(chain(i-1)) subset chain(i)` (g_content in seed)
- `F(chi_j) in chain(i)` for `j > i` when chi_i does not block chi_j at chain(i-1) (F(chi_j) in filtered seed)
- F-persistence for unblocked obligations: if no formula in {chi_1,...,chi_{i-1}} blocks chi_j, then F(chi_j) persists through steps 1 to j-1
- F-persistence for blocked obligations: chi_j's blockers are processed before step j. After the last blocker step, F(chi_j) is compatible with all remaining targets and persists to step j.
- Overall: every chi in DC with F(chi) in M0 is resolved by step N

**Tasks**:
- [ ] Define `resolving_forward_chain M0 h_mcs DC_ordered` using well-founded recursion on blocking relation or explicit finite iteration
- [ ] Prove `resolving_chain_mcs` (each step is MCS)
- [ ] Prove `resolving_chain_g_step` (g_content propagation)
- [ ] Prove `resolving_chain_target_resolved` (chi_i resolved at step i)
- [ ] Prove `resolving_chain_compatible_F_preserved` (F(chi_j) preserved when compatible)
- [ ] Prove `resolving_chain_F_persistence` (by well-founded induction on blocking DAG): F(chi) in M0 with chi in DC implies chi in chain(j) for some j <= N
- [ ] Define `resolving_backward_chain` symmetrically
- [ ] Define `resolving_fam` combining forward/backward as Int-indexed family
- [ ] Prove `resolving_fam_forward_G` and `resolving_fam_backward_H`
- [ ] Prove `resolving_fam_restricted_forward_F` and `resolving_fam_restricted_backward_P`
- [ ] Construct `ResolvingFMCS` with all coherence properties

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean`

**Verification**:
- `lake build` passes
- `lean_verify` on `resolving_fam_restricted_forward_F` shows no sorry
- `lean_verify` on `ResolvingFMCS` shows no sorry

---

### Phase 4: Replace Bundle and Rewire Completeness [NOT STARTED]

**Goal**: Define `resolvingBoxClassFamilies` using `ResolvingFMCS`, prove all BFMCS_Bundle properties, and rewire `completeness_over_Int`.

**Tasks**:
- [ ] Define `resolvingBoxClassFamilies M0 h_mcs root` (same structure as `boxClassFamilies` but with `ResolvingFMCS` instead of `SuccChainFMCS`)
- [ ] Prove `resolvingBoxClassFamilies_nonempty`
- [ ] Prove `resolvingBoxClassFamilies_modal_forward` (port from existing: same box_class_agree argument)
- [ ] Prove `resolvingBoxClassFamilies_modal_backward`
- [ ] Prove `resolvingBoxClassFamilies_bundle_forward_F` (use `temporal_theory_witness_exists` to get witness W, build `ResolvingFMCS` from W, same pattern as existing proof)
- [ ] Prove `resolvingBoxClassFamilies_bundle_backward_P`
- [ ] Define `construct_resolving_bfmcs_bundle`
- [ ] Prove `construct_resolving_bfmcs_bundle_eval_at_zero`
- [ ] Prove `resolving_bfmcs_restricted_temporally_coherent` (delegates to Phase 3 forward_F/backward_P)
- [ ] Define `resolving_bundle_validity_implies_provability` using the new bundle + `restricted_shifted_truth_lemma`
- [ ] Update `completeness_over_Int` to delegate to the resolving path
- [ ] Mark `succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P` as BYPASSED in docstrings

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- bundle construction
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- rewire completeness
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- BYPASSED annotations

**Verification**:
- `lake build` passes
- `lean_verify` on `completeness_over_Int` shows no sorry
- `lean_verify` on `discrete_completeness_fc` shows no sorry

---

### Phase 5: Verification and Cleanup [NOT STARTED]

**Goal**: Full verification, documentation, cleanup.

**Tasks**:
- [ ] Run `lake build` -- zero errors
- [ ] Run `lean_verify` on `completeness_over_Int` -- no sorry
- [ ] Run `lean_verify` on `discrete_completeness_fc` -- no sorry
- [ ] Run `lean_verify` on `resolving_bfmcs_restricted_temporally_coherent` -- no sorry
- [ ] Grep `sorry` in Completeness.lean -- only `bfmcs_from_mcs_temporally_coherent` and `dense_completeness`
- [ ] Grep `sorry` in TargetedChain.lean -- zero matches
- [ ] Update docstrings: BYPASSED on original sorry theorems, sorry-free on completeness_over_Int
- [ ] Add module docs for resolving chain section in TargetedChain.lean
- [ ] Verify discrete_completeness_fc delegates through completeness_over_Int

**Timing**: 1-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean` -- documentation
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` -- BYPASSED annotations
- `Theories/Bimodal/FrameConditions/Completeness.lean` -- docstrings

**Verification**:
- `lake build` passes
- `lean_verify completeness_over_Int` shows no sorry axiom

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `lean_verify` on `Bimodal.FrameConditions.Completeness.completeness_over_Int` shows no sorry
- [ ] `lean_verify` on `Bimodal.FrameConditions.Completeness.discrete_completeness_fc` shows no sorry
- [ ] grep `sorry` in Completeness.lean returns only unrestricted and dense paths
- [ ] grep `sorry` in TargetedChain.lean returns zero

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/03_restricted-coherence.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Bundle/TargetedChain.lean`
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean`
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `specs/083_close_restricted_coherence_sorries/summaries/03_restricted-coherence-summary.md` (after implementation)

## Rollback/Contingency

**If Phase 2 fails (joint consistency)**:
- Fall back to single-F-formula seed (include only one compatible F(chi) at a time). Always consistent by forward_temporal_witness_seed_consistent. Process DC with O(N^2) steps. +4-6 hours.

**If Phase 3 fails (F-persistence through blocker steps)**:
- Fall back to frame path extraction from the canonical frame (where forward_F is trivially true via the frame's accessibility relation). Requires new infrastructure. +12-18 hours.

**If Phase 4 fails (bundle porting)**:
- Prove completeness directly from single resolving family without BFMCS bundle. Adapt restricted truth lemma. +4-6 hours.

**Full rollback**: `git revert` all v3 commits. Original sorries remain.
