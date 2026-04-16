# Implementation Plan: Close BXCanonical Embedding (v22 -- Extended Defect Seed)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (task 92 dependency removed -- truth lemma already flows through restricted parametric representation)
- **Research Inputs**: reports/22_team-research.md, reports/21_team-research.md, summaries/18_bxcanonical-embedding-summary.md
- **Artifacts**: plans/22_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Six sorry sites remain in `RootScopedChain.lean` (lines 1295, 1306, 1313, 1366, 1371, 1376), all blocking `dd_countermodel` and hence `bx_completeness`. Round 22 research (4 teammates) converges on a unified diagnosis: the non-deterministic Lindenbaum extension in `enriched_fwd_step` is the single root cause -- `enriched_fwd_step_preserves` gives only a DISJUNCTIVE guarantee (`psi in M' OR F(psi) in M'`), and `Classical.choice` can systematically defer resolution. The recommended path is: (1) gate-check the fold-order trick (never actually tested despite 21 rounds), (2) if it fails, prove `extended_defect_seed_consistent` for n defects and replace the chain step. The buc/fuc sorries are NOT independent of forward_F (revised from 85% to 40-55% confidence). Definition of done: `lake build` succeeds with zero sorry in RootScopedChain.lean, and `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 22** (4-teammate consensus): All 6 sorries depend on forward_F (buc/fuc NOT independent, revised to 40-55%). Full f_carry seed is provably inconsistent (dead end). Restricted sigma_list seed may be consistent (55-65%). The `extended_defect_seed_consistent` lemma is the key mathematical crux. Fold-order trick was never tested (worth 2 hours as gate check). 6,400+ lines of sorry-free infrastructure validates the BXCanonical architecture.
- **Report 21**: Previously claimed buc/fuc independent at 85% -- contradicted by Report 22 and the implementation attempt in Summary 21. The quasimodel BXPoint-to-integer bridge does not exist.
- **Summary 18**: Chain replacement has a fatal F-propagation gap -- `discharge_single_step` gives target in M' and g_content(M) in M', but F(chi) may be permanently killed.

### Prior Plan Reference

Plan v21 (12 hours, 5 phases) was blocked at all phases. Key lessons: (1) buc/fuc are NOT independent of forward_F -- the 85% confidence estimate was wrong, (2) the fold-order trick was never actually tested despite being the cheapest gate check, (3) the F-propagation gap in `discharge_single_step` remains the deepest obstruction, (4) effort estimates for chain replacement should account for ~30 downstream re-proofs. Plan v21 correctly identified the fold-order trick as a gate check but never executed it.

### Roadmap Alignment

- Advances `rr_fwd_chain_forward_F` (PRIMARY BLOCKER) from OPEN toward DONE
- Advances `dd_fmcs_forward_F`, `dd_fmcs_backward_P`, `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc` from OPEN toward DONE
- Closes sorry sites blocking `dd_countermodel` and `bx_completeness`
- Would unblock task 95 (`#print axioms` audit)

## Goals & Non-Goals

**Goals**:
- Gate-check the fold-order trick by concrete implementation and testing (2 hours)
- If fold-order fails: prove `extended_defect_seed_consistent` for n defects, generalizing the 2-defect case already in `OrderedSeedConsistency.lean`
- Replace `enriched_fwd_step` with a target-resolving step that deterministically places target in M' while F-protecting all other sigma_list obligations
- Close all 6 sorry sites in RootScopedChain.lean
- Achieve `lake build` with zero sorry in RootScopedChain.lean

**Non-Goals**:
- Modifying CanonicalModel.lean (dead code, not on active completeness path)
- Implementing a semantic/quasimodel bridge (only needed if `extended_defect_seed_consistent` fails)
- Cleaning up dead code in CanonicalModel.lean (low priority, separate task)
- Proving unrestricted coherence properties (restricted suffices for the truth lemma)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Fold-order trick fails at Case 2 (F(beta and F(target)) deferral) | M | H (65%) | Expected failure. Phase 1 is a 2-hour gate check that provides concrete data. Failure triggers Phase 2 (extended seed approach). |
| `extended_defect_seed_consistent` for n > 2 defects fails due to BX11 3-cycles | H | M (35-45%) | The 2-defect case is already proved. The running-compound iteration approach (Teammate A, Report 22) may avoid the 3-cycle obstruction. If n-defect fails, investigate whether the chain only needs to handle bounded defect counts. |
| Downstream re-proofs after chain replacement are extensive (~30 theorems) | M | H (90%) | Budget explicit time in Phase 4. Most re-proofs are mechanical (same API, stronger postcondition). Use `lean_goal` to identify exact proof state changes. |
| backward_P has symmetric obstruction to forward_F | H | H (60%) | Same fix applies symmetrically. Budget time in Phase 3 for the backward chain variant. |
| Step transfer for buc/fuc requires Until-aware chain seeds beyond forward_F | M | M (40%) | Once forward_F is solved with deterministic resolution, the same seed enrichment technique applies to Until eventuality. BX9/BX10 reduction to F-obligations makes this a corollary. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 (only if Phase 1 fails) |
| 3 | 3 | 1 or 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Gate Check -- Fold-Order Trick [NOT STARTED]

**Goal**: Concretely test whether processing target LAST in the BX11 fold eliminates the non-deterministic deferral that blocks `rr_fwd_chain_forward_F`. This is the cheapest possible test (2 hours) and has never been attempted despite 21 research rounds.

**Tasks**:
- [ ] Read `enriched_fwd_fold_with_witness` (RootScopedChain.lean ~line 257) and understand the fold order
- [ ] Create a variant `target_last_enriched_fwd_exists` that processes target as the LAST formula in the BX11 fold (all other sigma_list formulas processed first)
- [ ] Attempt to prove: when F(target) in M, target in M' deterministically (not disjunctive)
- [ ] If Case 2 fires (`F(beta and F(target))` gives `F(target) in M'` only): capture the exact `lean_goal` output at the obstruction point
- [ ] If Case 2 does NOT fire (target always resolved): proceed directly to use this for `rr_fwd_chain_forward_F`
- [ ] Document results: whether fold-order works, where it fails, exact proof state

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add variant definitions, attempt proof

**Verification**:
- If fold-order succeeds: `target_last_enriched_fwd_exists` compiles with target deterministically in M'
- If fold-order fails: concrete `lean_goal` output documenting where Case 2 blocks
- `lake build` succeeds (no regressions from variant definitions)

---

### Phase 2: Prove `extended_defect_seed_consistent` for n Defects [NOT STARTED]

**Goal**: Generalize the 2-defect case in `OrderedSeedConsistency.lean` to n defects. This is the KEY mathematical lemma: given F-defects `[psi_1, ..., psi_n]` all with `F(psi_k) in M`, there exists an index j such that `{psi_j} union {F(psi_k) | k != j} union g_content(M)` is consistent.

**Tasks**:
- [ ] If Phase 1 succeeded: SKIP this phase (fold-order trick suffices)
- [ ] Formalize the n-defect theorem statement in `OrderedSeedConsistency.lean`:
  ```
  theorem extended_defect_seed_consistent {M : Set Formula}
      (h_mcs : SetMaximalConsistent M)
      (defects : List Formula)
      (h_F : forall psi in defects, Formula.some_future psi in M) :
      defects.length > 0 ->
      exists j : Fin defects.length,
        SetConsistent ({defects.get j} union
          (defects.toFinset.erase (defects.get j)).image Formula.some_future union
          g_content M)
  ```
- [ ] Prove base case (length 1): trivial from `forward_temporal_witness_seed_consistent`
- [ ] Prove inductive step using BX11 iteration:
  - Apply `temp_linearity_mcs` to pair the new defect with a running compound
  - In each BX11 case, use `enriched_resolving_seed_consistent` to extract the consistent seed
  - Handle the 3-cycle obstruction: the running-compound approach accumulates F-protected formulas rather than requiring a global BX11-minimum
- [ ] Verify the lemma compiles and `lake build` succeeds

**Timing**: 2 hours

**Depends on**: 1 (only if Phase 1 fails; if Phase 1 succeeds, skip this phase)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- add n-defect theorem

**Verification**:
- `extended_defect_seed_consistent` compiles without sorry
- `lake build` succeeds
- Proof handles all three BX11 cases correctly

---

### Phase 3: Replace Chain Step and Close forward_F / backward_P [NOT STARTED]

**Goal**: Use the result from Phase 1 (fold-order trick) or Phase 2 (extended defect seed) to build a chain step that deterministically resolves the target formula. Close `rr_fwd_chain_forward_F`, `dd_fmcs_forward_F`, and `dd_fmcs_backward_P`.

**Tasks**:
- [ ] **If Phase 1 succeeded (fold-order)**:
  - Replace `enriched_fwd_step` with `target_last_enriched_fwd_step` (or prove equivalent API)
  - Close `rr_fwd_chain_forward_F` (line 1295): at psi's visit step, F(psi) in chain(m) and target=psi gives psi in chain(m+1) deterministically
- [ ] **If Phase 2 succeeded (extended defect seed)**:
  - Define `target_resolving_fwd_step` using `extended_defect_seed_consistent`: given target and sigma_list with F-obligations, the seed `{target} union {F(others)} union g_content(M)` is consistent, so Lindenbaum extension gives M' with target in M' AND F(others) in M'
  - Prove `target_resolving_fwd_step_target_in`: target in M' (deterministic)
  - Prove `target_resolving_fwd_step_preserves`: for all chi in sigma_list with F(chi) in M, chi in M' or F(chi) in M' (inherited from Lindenbaum)
  - Replace `enriched_fwd_step` references in `rr_fwd_chain` with new step
  - Close `rr_fwd_chain_forward_F` via: at psi's visit step (round-robin schedule), F(psi) persists by `_preserves`, then target=psi gives psi in chain(m+1)
- [ ] Close `dd_fmcs_forward_F` t >= 0 case (lines 1306-1317): flows directly from `rr_fwd_chain_forward_F` (already partially proved)
- [ ] Close `dd_fmcs_forward_F` t < 0 case (line 1306): F(psi) in backward chain; propagate to M0 via g_content or use symmetric backward argument
- [ ] Close `dd_fmcs_backward_P` (line 1313): symmetric backward chain construction using h_content and P-obligations
- [ ] Re-prove any downstream lemmas broken by the chain step replacement (~30 theorems; most are mechanical API-compatible changes)

**Timing**: 2 hours

**Depends on**: 1 or 2 (whichever succeeds)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- replace chain step, close sorry sites at lines 1295, 1306, 1313
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- possibly add helper lemmas

**Verification**:
- `rr_fwd_chain_forward_F` compiles without sorry
- `dd_fmcs_forward_F` compiles without sorry (both t >= 0 and t < 0 cases)
- `dd_fmcs_backward_P` compiles without sorry
- `lake build` succeeds
- No new sorry introduced

---

### Phase 4: Close restricted_tc, buc, fuc and Final Assembly [NOT STARTED]

**Goal**: Close the remaining 3 sorry sites (`dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, `dd_bfmcs_restricted_fuc`) using the now-proved forward_F/backward_P results, then verify complete sorry-free state.

**Tasks**:
- [ ] Close `dd_bfmcs_restricted_tc` (line 1366): assemble four sub-cases:
  - G(phi) forward: by `dd_chain_g_content` (already proved)
  - H(phi) backward: by `dd_chain_h_content` (already proved)
  - F(phi) forward: by `dd_fmcs_forward_F` (from Phase 3)
  - P(phi) backward: by `dd_fmcs_backward_P` (from Phase 3)
- [ ] Close `dd_bfmcs_restricted_fuc` (line 1376): forward Until/Since coherence
  - For Until `(phi U psi) in fam.mcs(t)`: BX10 gives `F(psi)` from `(phi U psi)`, then forward_F gives witness s > t with psi in fam.mcs(s); guard phi on [t,s) from BX5 self-accumulation and chain structure
  - For Since: symmetric via backward_P and H-content
  - Use `deferralClosure` membership to scope the restricted quantifier
- [ ] Close `dd_bfmcs_restricted_buc` (line 1371): backward Until/Since coherence
  - Given witness pattern (psi at s >= t, phi on [t,s)), derive `(phi U psi) in fam.mcs(t)`
  - Base case s = t: `backward_until_reflexive` from UntilSinceCoherence.lean
  - Inductive case s > t: requires step transfer -- `(phi U psi) in fam.mcs(r+1)` and `phi in fam.mcs(r)` implies `(phi U psi) in fam.mcs(r)` -- use `backward_until_from_step` with chain-specific step transfer proof
  - Step transfer proof: from chain construction, `g_content(chain(r)) subset chain(r+1)`, so if we can derive `G(phi imp (phi U psi))` or use BX5/BX9 in the chain MCS, the step transfers
- [ ] Run `grep -n sorry RootScopedChain.lean` to verify zero matches
- [ ] Run `lake build` from clean state
- [ ] Use `lean_verify` on `dd_countermodel` to check axiom set
- [ ] Use `lean_verify` on `bx_completeness` to verify axiom set is `{propext, Classical.choice, Quot.sound}`

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites at lines 1366, 1371, 1376

**Verification**:
- All 6 sorry sites closed
- `grep -n sorry RootScopedChain.lean` returns zero matches
- `lake build` succeeds with zero errors
- `lean_verify` on `dd_countermodel` shows clean axiom set
- `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

---

### Phase 5: Documentation and ROAD_MAP Update [NOT STARTED]

**Goal**: Update ROAD_MAP.md with final results, document the successful approach, and add docstrings.

**Tasks**:
- [ ] Update ROAD_MAP.md active-path sorry inventory: change count from 6 to 0, mark all as DONE
- [ ] Add a "How the Sorries Were Closed" section documenting which approach succeeded (fold-order trick vs extended defect seed) and key infrastructure that enabled the proofs
- [ ] Update dead end list with fold-order trick results (whether it worked or not)
- [ ] Add docstrings to new definitions and proof variants
- [ ] Update task 93 cross-reference with completion status

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `specs/ROAD_MAP.md` -- update sorry inventory, add documentation
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add docstrings
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- add docstrings (if Phase 2 was executed)

**Verification**:
- ROAD_MAP.md accurately reflects zero sorry state
- All new definitions have docstrings
- `lake build` still succeeds

## Testing & Validation

- [ ] `lake build` succeeds with zero errors at each phase boundary
- [ ] `grep -rn sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero matches (after Phase 4)
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any file
- [ ] `dd_countermodel` theorem compiles end-to-end
- [ ] ROAD_MAP.md sorry inventory accurately reflects current state

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- modified (sorry sites replaced, possibly new chain step definitions)
- `Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` -- modified (n-defect theorem, if Phase 2 executed)
- `specs/ROAD_MAP.md` -- updated (sorry inventory, documentation)
- `specs/093_complete_bxcanonical_embedding/plans/22_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

Changes are confined to `RootScopedChain.lean`, `OrderedSeedConsistency.lean`, and `specs/ROAD_MAP.md`.

1. **Full success (all 6 sorries closed)**: No rollback needed. This is the target outcome.

2. **Fold-order succeeds, but buc/fuc step transfer blocked (~15%)**: Keep forward_F/backward_P proofs (reduces sorry count from 6 to 3). The buc/fuc step transfer requires a focused follow-up on Until-aware chain seeds.

3. **Both fold-order and extended defect seed fail (~20%)**: The concrete test results from Phase 1 and the formalization attempt in Phase 2 provide precise obstruction data. Consider the semantic/quasimodel bridge as the next approach. All infrastructure added is preserved.

4. **Extended defect seed proves but downstream re-proofs are extensive (~10%)**: Mark Phase 3 as PARTIAL, continue in a follow-up plan. The n-defect theorem is permanent value regardless.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean Theories/Bimodal/Metalogic/BXCanonical/OrderedSeedConsistency.lean` restores the 6-sorry state. ROAD_MAP.md changes should be committed independently.
