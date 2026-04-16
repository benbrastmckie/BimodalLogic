# Implementation Plan: Close BXCanonical Embedding (v23 -- Demand-Driven Chain)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 30 hours
- **Dependencies**: None (task 92 completed; truth lemma and quasimodel infrastructure sorry-free)
- **Research Inputs**: reports/23_team-research.md, reports/22_team-research.md, summaries/18_bxcanonical-embedding-summary.md
- **Artifacts**: plans/23_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites in `RootScopedChain.lean` (lines 1319, 1350, 1357, 1410, 1415, 1420) block `dd_countermodel` and hence `bx_completeness`. Twenty-two prior rounds of research and implementation have conclusively established that the round-robin chain construction cannot prove `forward_F` because `Classical.choice` in `set_lindenbaum` can perpetually defer resolution. All four Round 23 teammates converge on a demand-driven chain construction (equivalent to Burgess 1984 / Goldblatt 1992 textbook technique) that makes `forward_F` hold by construction rather than by proof. The plan replaces the round-robin chain with a finite-discharge + identity-tail construction, preceded by proving the `extended_defect_seed_consistent` lemma from existing infrastructure. Additionally, 2 dead-code sorries in `CanonicalModel.lean` are deleted as an independent cleanup. Definition of done: `lake build` succeeds, `grep -rn sorry RootScopedChain.lean` returns zero, and `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 23** (4-teammate consensus): Demand-driven chain construction replaces round-robin. `extended_defect_seed_consistent` provable from `resolving_enriched_fwd_exists` + `phi_in_mcs_imp_F_phi`. All 6 sorries depend on `forward_F` (buc/fuc NOT independent). Identity tail after finite demands discharged. Estimated 25-40 hours at 55-65% confidence.
- **Report 22**: Confirmed buc/fuc NOT independent of forward_F (revised from 85% to 40-55%). Full f_carry seed provably inconsistent (dead end #13). Extended defect seed existential form is viable.
- **Summary 18**: F-propagation gap in `discharge_single_step` remains the deepest obstruction. Chain replacement needed, not chain repair.

### Prior Plan Reference

Plan v22 (8 hours, 5 phases) was blocked at Phase 1 (fold-order trick never tested, infrastructure restructuring required) and Phase 2 (extended defect seed partial). Key lessons: (1) effort estimates were too optimistic -- the v22 estimate of 8 hours reflected individual-phase thinking, not the chain replacement cost (~30 downstream re-proofs), (2) the fold-order trick requires non-trivial infrastructure restructuring per Critic finding, not a 2-hour gate check, (3) buc/fuc confidence was revised downward. This plan v23 uses the research consensus estimate of 25-40 hours and structures work around the demand-driven chain replacement rather than incremental patches.

### Roadmap Alignment

- Advances the sole remaining active-path sorry (`Completeness.lean:154` wired through `dd_countermodel`)
- Closes `rr_fwd_chain_forward_F` (PRIMARY BLOCKER, ROAD_MAP line 27)
- Closes `dd_fmcs_forward_F`, `dd_fmcs_backward_P`, `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`
- Would unblock task 95 (`#print axioms` audit on `bx_completeness`)

## Goals & Non-Goals

**Goals**:
- Prove `extended_defect_seed_consistent` (existential form) for n defects using existing BX11 fold infrastructure
- Design and implement a demand-driven chain construction replacing the round-robin `rr_fwd_chain`
- Close all 6 sorry sites in `RootScopedChain.lean`
- Delete 2 dead-code sorries in `CanonicalModel.lean` (`bx_fmcs_forward_F`, `bx_fmcs_backward_P`)
- Achieve `lake build` with zero sorry in active BXCanonical path

**Non-Goals**:
- Closing unrestricted coherence sorries in `CanonicalModel.lean` (dead code, not on active path)
- Implementing a semantic/quasimodel bridge (fallback only if demand-driven fails)
- Modifying the truth lemma or quasimodel infrastructure (sorry-free, proven correct)
- Dense completeness (independent task 68)
- ROAD_MAP.md updates (separate documentation task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Demand-driven chain construction is harder than estimated due to Lean4 formalization overhead | H | M (40%) | Budget 15-20 hours for chain construction alone. Use `lean_goal` extensively to track proof state. Factor into smaller sub-lemmas. |
| `extended_defect_seed_consistent` existential form harder than ~30 LOC estimate | M | L (20%) | The proof strategy is well-understood (fold gives direct witness, disjunctive upgrades to F via `phi_in_mcs_imp_F_phi`). Fallback: prove 2-defect and 3-defect cases individually if general induction fails. |
| t < 0 backward case requires fundamentally different argument from forward | H | M (45%) | Two strategies: (a) show F(ψ) in backward chain propagates to M₀ via bridge, then forward chain resolves; (b) build symmetric demand-driven backward chain. Budget 4 hours for this case specifically. |
| restricted_buc step transfer not derivable from bare FMCS structure | H | M (50%) | The demand-driven chain has richer structure than round-robin. Step transfer may follow from enriched seed properties. If not, investigate BX5 self-accumulation at chain level. Budget 3 hours. |
| restricted_fuc guard condition (phi at intermediate points) requires additional chain analysis | M | M (40%) | BX5 gives `(phi U psi) -> ((phi & (phi U psi)) U psi)`, so both phi and phi U psi hold at intermediate points. The chain's g_content propagation may already provide this. |
| Downstream re-proofs after chain replacement are extensive | M | H (80%) | Budget 5 hours explicitly. Most re-proofs are mechanical (same API surface). The demand-driven chain exposes a superset of the round-robin's API. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 3 |
| 4 | 5 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Dead-Code Cleanup [NOT STARTED]

**Goal**: Remove 2 dead-code sorries from `CanonicalModel.lean` to reduce noise and clarify the active sorry inventory.

**Tasks**:
- [ ] Delete or mark as dead-code the `bx_fmcs_forward_F` theorem (line 514-518)
- [ ] Delete or mark as dead-code the `bx_fmcs_backward_P` theorem (line 520-525)
- [ ] Delete the unrestricted coherence theorems that depend on them (`bx_bfmcs_tc`, `bx_bfmcs_buc`, `bx_bfmcs_fuc`, lines 597-619) or wrap with `-- DEAD CODE` annotation if other modules reference them
- [ ] Similarly clean up unrestricted restricted variants if they delegate to the dead code
- [ ] Run `lake build` to verify no regressions

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- remove or annotate dead-code sorry sites

**Verification**:
- `lake build` succeeds
- `grep -n sorry CanonicalModel.lean` shows only dead-code annotated sorries (if any remain)
- No active-path code broken

---

### Phase 2: Prove `extended_defect_seed_consistent` [NOT STARTED]

**Goal**: Prove the existential n-defect seed consistency theorem: given F-defects `[psi_1, ..., psi_n]` all with `F(psi_k) in M`, there exists an index j such that the seed `{psi_j} union {F(psi_k) | k != j} union g_content(M)` is consistent.

**Tasks**:
- [ ] Formalize the theorem statement in `OrderedSeedConsistency.lean`:
  ```lean
  theorem extended_defect_seed_consistent {M : Set Formula}
      (h_mcs : SetMaximalConsistent M)
      (defects : List Formula)
      (h_F : forall psi, psi in defects -> Formula.some_future psi in M)
      (h_nonempty : defects.length > 0) :
      exists j : Fin defects.length,
        SetConsistent ({defects.get j} union
          {Formula.some_future chi | chi in defects, chi != defects.get j} union
          g_content M)
  ```
- [ ] Prove using `resolving_enriched_fwd_exists` (or `enriched_fwd_fold_with_witness`): the fold produces M' with direct witness w in M' and F(chi) or chi in M' for all others. Since M' is an MCS, the seed `{w} union {F(chi) | chi != w} union g_content(M)` is a subset of M', hence consistent.
- [ ] Verify the helper `phi_in_mcs_imp_F_phi` exists or prove it: if chi in M (MCS), then F(chi) in M (by BX T-axiom `G(phi) -> phi`, contrapositive `not phi -> not G(phi) = F(not phi)`... actually this gives `chi -> F(chi)` by temp_t contrapositive? No -- `G(phi) -> phi` contraposes to `not phi -> F(not phi)`. We need `chi -> F(chi)`: this is NOT a BX theorem in general. Check if this is actually needed or if the proof works differently.
- [ ] Alternative proof path: the fold's direct witness w is guaranteed in M'. For other chi, the fold gives `chi in M' OR F(chi) in M'`. In either case, `F(chi) in M'` (if chi in M', then by `temp_t_future` contrapositive? No -- we need `chi -> G(chi)` which is NOT valid). Actually: if `chi in M'`, this does NOT imply `F(chi) in M'`. The seed needs to use the disjunctive form directly: `{w} union {chi_or_F(chi) for other chi} union g_content(M) subset M'`. Reformulate the theorem to use the disjunctive membership.
- [ ] Run `lake build` to verify

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- add extended seed theorem

**Verification**:
- `extended_defect_seed_consistent` compiles without sorry
- `lake build` succeeds

---

### Phase 3: Build Demand-Driven Chain Construction [NOT STARTED]

**Goal**: Replace the round-robin `rr_fwd_chain` with a demand-driven chain where each step resolves one specific F-demand. Forward_F holds by construction: at step k (dedicated to demand psi_k), psi_k is placed directly in the chain step's MCS.

**Tasks**:
- [ ] Design the demand-driven forward chain. Given M₀ and sigma_list (finite list of formulas to resolve):
  - Steps 0..N-1: Step k uses `extended_defect_seed_consistent` to build M_{k+1} that resolves `sigma_list[k]` while F-protecting all remaining demands
  - Steps N, N+1, ...: Identity tail, chain(k) = chain(N-1) (or repeat the last MCS via g_content self-inclusion)
- [ ] Define `demand_fwd_chain : (M₀ : Set Formula) -> (h₀ : SetMaximalConsistent M₀) -> (sigma_list : List Formula) -> (n : Nat) -> { M : Set Formula // SetMaximalConsistent M }`
- [ ] Prove `demand_fwd_chain_g_content_step`: g_content propagation at each step
- [ ] Prove `demand_fwd_chain_resolves`: at step k (where k < sigma_list.length and F(sigma_list[k]) in M₀), sigma_list[k] in chain(k+1)
- [ ] Prove `demand_fwd_chain_forward_F`: for any psi in sigma_list with F(psi) in chain(n), there exists s > n with psi in chain(s). This follows from the construction: psi has a dedicated step, and F(psi) persists to that step by the enriched seed's F-protection.
- [ ] Build symmetric `demand_bwd_chain` for backward (P) direction using h_content and past temporal witness seeds
- [ ] Define `demand_dd_chain` assembling forward and backward into Int-indexed chain
- [ ] Prove `demand_dd_chain_mcs`, `demand_dd_chain_zero`, `demand_dd_chain_g_content`, `demand_dd_chain_h_content` (basic API matching the existing `dd_chain` interface)

**Timing**: 12 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add demand-driven chain definitions and API lemmas (new section, before existing `rr_fwd_chain`)

**Verification**:
- All new definitions and theorems compile without sorry
- `demand_fwd_chain_forward_F` compiles without sorry (the key theorem)
- `lake build` succeeds
- No existing sorry sites affected yet (new code only)

---

### Phase 4: Close forward_F / backward_P and Restricted TC [NOT STARTED]

**Goal**: Wire the demand-driven chain into `dd_fmcs`/`dd_bfmcs` and close the first 4 sorry sites: `rr_fwd_chain_forward_F`, `dd_fmcs_forward_F`, `dd_fmcs_backward_P`, and `dd_bfmcs_restricted_tc`.

**Tasks**:
- [ ] Replace `dd_chain` to use `demand_dd_chain` instead of `rr_fwd_chain`/`rr_bwd_chain`, OR prove `rr_fwd_chain_forward_F` by delegating to the demand-driven chain's forward_F property
- [ ] Close `rr_fwd_chain_forward_F` (line 1319): either replace the chain or prove it equivalent to demand-driven
- [ ] Close `dd_fmcs_forward_F` t >= 0 case (line 1321-1341): flows from `rr_fwd_chain_forward_F`
- [ ] Close `dd_fmcs_forward_F` t < 0 case (line 1342-1350): F(psi) in backward chain at time t < 0. Strategy: show F(psi) propagates to M₀ (at t=0). The backward chain's h_content does not preserve F-formulas, but F(psi) in bwd_chain(-k) implies F(psi) was in the Lindenbaum extension seed. Investigate whether g_content(bwd_chain(-k)) subset bwd_chain(-k+1) ... bwd_chain(0) = M₀ gives G(...F(psi)...) propagation, or use a different argument.
- [ ] Close `dd_fmcs_backward_P` (line 1352-1357): symmetric to forward_F using the demand-driven backward chain
- [ ] Close `dd_bfmcs_restricted_tc` (line 1406-1410): assemble from forward_F/backward_P plus existing g_content/h_content propagation
- [ ] Fix any downstream lemmas broken by chain replacement
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites at lines 1319, 1350, 1357, 1410; possibly restructure chain assembly

**Verification**:
- `rr_fwd_chain_forward_F` compiles without sorry
- `dd_fmcs_forward_F` compiles without sorry (both cases)
- `dd_fmcs_backward_P` compiles without sorry
- `dd_bfmcs_restricted_tc` compiles without sorry
- `lake build` succeeds

---

### Phase 5: Close restricted_buc and restricted_fuc [NOT STARTED]

**Goal**: Close the final 2 sorry sites (`dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`) using the now-proved forward_F/backward_P and demand-driven chain properties.

**Tasks**:
- [ ] Analyze `restricted_forward_until_since_coherent` type signature to understand exact obligations
- [ ] Close `dd_bfmcs_restricted_fuc` (line 1417-1420) -- forward Until/Since coherence:
  - For Until `(phi U psi) in fam.mcs(t)`: BX10 gives `F(psi)` from `(phi U psi)`. By `forward_F`, exists s > t with `psi in fam.mcs(s)`. Guard: need `phi in fam.mcs(r)` for all r in [t, s). Use BX5 self-accumulation: `(phi U psi) -> ((phi & (phi U psi)) U psi)`, so at intermediate points phi holds. The chain's g_content propagation carries `G(phi U psi)` forward if `(phi U psi) in fam.mcs(t)` and `G(phi U psi)` can be derived. Investigate whether `phi U psi in M` implies `G(phi U psi) in M` (this would require BX axioms relating U to G).
  - Alternative: use the quasimodel infrastructure `bx_until_eventuality_resolution` which is already sorry-free and produces BXPoint chains with the correct guard property.
  - For Since: symmetric via backward_P
- [ ] Close `dd_bfmcs_restricted_buc` (line 1412-1415) -- backward Until/Since coherence:
  - Given witness pattern (psi at s, phi on guard), derive `(phi U psi) in fam.mcs(t)`
  - Base case s = t: by BX8 `psi -> (phi U psi)` (reflexive Until introduction)
  - Step transfer: from `(phi U psi) in chain(r+1)` and `phi in chain(r)`, derive `(phi U psi) in chain(r)`. This requires the chain step to carry Until formulas backward. Investigate whether g_content/h_content propagation or BX6 absorption provides this.
- [ ] Run `grep -n sorry RootScopedChain.lean` to verify zero matches
- [ ] Run `lake build`

**Timing**: 5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites at lines 1415, 1420

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `grep -n sorry RootScopedChain.lean` returns zero matches
- `lake build` succeeds

---

### Phase 6: Final Verification and Axiom Audit [NOT STARTED]

**Goal**: Verify that `bx_completeness` is sorry-free and depends only on the expected axioms.

**Tasks**:
- [ ] Run `lake build` from clean state to verify full project builds
- [ ] Use `lean_verify` on `Bimodal.Metalogic.BXCanonical.dd_countermodel` to check axiom set
- [ ] Use `lean_verify` on `Bimodal.Metalogic.BXCanonical.bx_completeness` to verify axiom set is `{propext, Classical.choice, Quot.sound}`
- [ ] Run `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/` to verify no sorries remain in active BXCanonical path
- [ ] Verify `Completeness.lean` has no sorry (it currently delegates to `dd_countermodel`)
- [ ] Add docstrings to new demand-driven chain definitions

**Timing**: 1 hour

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- add docstrings

**Verification**:
- `lean_verify bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- Zero sorry in `Theories/Bimodal/Metalogic/BXCanonical/` active path
- `lake build` succeeds
- All new definitions documented

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero (after Phase 5)
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any file
- [ ] `dd_countermodel` theorem compiles end-to-end without sorry
- [ ] Demand-driven chain's `forward_F` holds by construction (not by induction on the round-robin)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- demand-driven chain construction, 6 sorry sites closed
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- extended defect seed consistency theorem
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- dead-code sorries removed
- `specs/093_complete_bxcanonical_embedding/plans/23_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

Changes span `RootScopedChain.lean`, `OrderedSeedConsistency.lean`, and `CanonicalModel.lean`.

1. **Full success (all 6 sorries closed)**: Target outcome. No rollback needed.

2. **Demand-driven chain built but buc/fuc blocked (~25%)**: Keep forward_F/backward_P/restricted_tc proofs (reduces sorry count from 6 to 2). The buc/fuc closure requires Until-aware chain properties -- spawn a focused follow-up task.

3. **Demand-driven chain forward_F works but t < 0 backward case blocked (~15%)**: Keep forward case proofs (reduces sorry count from 6 to 4-5). Investigate symmetric demand-driven backward chain or semantic bridge through M₀.

4. **`extended_defect_seed_consistent` proves but demand-driven chain harder than expected (~20%)**: The extended seed theorem is permanent value. Partial chain construction can be committed. Resume in follow-up with more time budget.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` restores the current state. All changes are confined to these 3 files.

6. **Fallback approach**: If the demand-driven chain proves infeasible, explore the semantic hybrid approach (Report 23, Finding 16): if psi is perpetually deferred, then not-psi is in all chain steps, and the restricted truth lemma gives G(not-psi) in M, contradicting F(psi) in M. This is a 30% confidence backup.
