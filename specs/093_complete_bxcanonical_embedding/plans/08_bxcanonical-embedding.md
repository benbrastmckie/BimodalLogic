# Implementation Plan: Close TaskModel Embedding Sorry (v8 -- Quasimodel-Guided Approach)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: None (tasks 90, 92, 98, 102 already completed; all Until/Since/Box sorries closed)
- **Research Inputs**: reports/08_quasimodel-approach.md
- **Artifacts**: plans/08_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the sole remaining active-path sorry blocking `bx_completeness`: the 6 sorry sites in `CanonicalModel.lean` (lines 497, 503, 586, 591, 621, 627) that provide temporal coherence and Until/Since coherence for the BFMCS. Only the 3 restricted variants (lines 603-627) are on the active path consumed by `bx_countermodel`. The approach follows Report 08's recommended "Approach A": parameterize `fwd_succ`/`bwd_pred` by a root formula, add `restrictedUntilCarry(M, root)` to both seed branches, prove consistency via a novel argument combining temporal K with BX11 linearity, then derive Until persistence, step transfer, and forward_F (via BX12 reduction to forward Until). Definition of done: `lake build` succeeds with zero sorry on the active completeness path, and `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

Report 08 (1073 lines) provides an exhaustive analysis of 10 construction approaches. Key findings:

1. **Plan 06's `until_neg_carry` approach is mathematically flawed** (Handoff 02): forward stability of negated Until is semantically invalid (counterexample provided), and `{psi} union until_neg_carry(M)` is inconsistent via BX8 contrapositive.
2. **The scheduling chain CANNOT prove unrestricted forward_F** -- confirmed across 8 research rounds. F-formulas are lost at resolving steps for other formulas, and no seed enrichment fixes this for unrestricted forward_F.
3. **Restricted forward_F reduces to restricted forward Until via BX12**: `F(psi) -> (top U psi)`. This avoids the need for independent F-formula persistence. However, `(top U psi)` must be in `subformulaClosure(root)` for this reduction to apply, requiring verification of closure properties.
4. **`restrictedUntilCarry(M, root)` in the non-resolving seed is safe**: the seed `g_content(M) union f_carry(M) union untilCarry(M, root)` is a subset of M, hence consistent. This provides Until persistence through non-resolving steps.
5. **The resolving-branch consistency of `{psi} union g_content(M) union untilCarry(M, root)` is the critical unknown** (estimated 60% probability of success). The temporal K argument extends partially but `G(u_j)` for Until formula `u_j` is not guaranteed. A novel BX11/BX7 linearity argument is needed.
6. **Step transfer for backward Until** follows from Until persistence: if `(phi U psi) in chain(r+1)` (by construction from seed containing untilCarry), then `(phi U psi)` was already in the seed, hence in `chain(r)` if it was in the chain at time `r`.

### Prior Plan Reference

Plan 06 had 5 phases built around `until_neg_carry` + deferral disjunctions. Phase 1 was BLOCKED after Handoff 02 proved the approach invalid. Key lessons learned: (a) forward stability of negated Until is semantically invalid -- never carry negated formulas for backward transfer, (b) consistency of the resolving seed requires careful analysis -- `{psi} union S` where `S subset M` is only consistent when `neg(psi)` is not derivable from S, (c) the BX8 contrapositive (`neg(phi U psi) -> neg(psi)`) means Until-related formulas can conflict with the resolving target, (d) deferral disjunctions (`chi v F(chi)`) are provably in M but adding them to the resolving seed has the same consistency gap. Effort calibration: Plan 06 estimated 8 hours but was blocked at Phase 1 -- the approach was fundamentally flawed, not just difficult. This plan increases the estimate to 14 hours to account for the novel consistency proof.

### Roadmap Alignment

- Closes the sole remaining active-path sorry (1 of 1) blocking `bx_completeness`
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Once complete, `completeness_over_Int` becomes sorry-free via BXCanonical
- Unblocks task 95 (`#print axioms` audit)

## Goals & Non-Goals

**Goals**:
- Define `restrictedUntilCarry(M, root)` and `restrictedSinceCarry(M, root)` for Until/Since formulas in `subformulaClosure(root)` that are present in M
- Parameterize `fwd_succ` and `bwd_pred` by `root : Formula` to scope seed enrichment
- Add `restrictedUntilCarry` to BOTH branches of `fwd_succ` (resolving and non-resolving)
- Prove consistency of the resolving seed `{psi} union g_content(M) union restrictedUntilCarry(M, root)` via temporal K + BX11 linearity argument
- Prove Until formulas from `subformulaClosure(root)` persist forward through all chain steps
- Derive backward Until step transfer: `(phi U psi) in chain(r+1) -> (phi U psi) in chain(r)` (when `(phi U psi) in subformulaClosure(root)`)
- Close `bx_bfmcs_restricted_buc` (backward Until/Since coherence) using step transfer + `backward_until_from_step`
- Close `bx_bfmcs_restricted_tc` (restricted forward_F/backward_P) via BX12 reduction to forward Until
- Close `bx_bfmcs_restricted_fuc` (forward Until/Since coherence) using restricted forward_F + step transfer for guard
- Achieve `lake build` with zero active-path sorry
- Verify `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

**Non-Goals**:
- Proving unrestricted forward_F/backward_P (`bx_fmcs_forward_F`/`bx_fmcs_backward_P` at lines 497, 503)
- Closing unrestricted `bx_bfmcs_buc`/`bx_bfmcs_fuc`/`bx_bfmcs_tc` (lines 586-591) -- these are dead code
- Dense time completeness (`D = Rat`), which is task 68
- Performance optimization of the chain construction
- Full quasimodel infrastructure (Approach C from Report 08)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Resolving-branch consistency proof fails (BX11/BX7 argument does not close) | H | M (40%) | Fall back to Approach B: build a parallel `quasimodel_chain` that uses untilCarry only in the non-resolving seed and proves restricted coherence via a separate mechanism. Estimated +8 hours. |
| `(top U psi)` not in `subformulaClosure(root)` when `F(psi)` is, blocking BX12 reduction | H | H | Verify closure properties early in Phase 1. If `(top U psi)` is not included, either extend the closure definition or prove restricted forward_F directly via the existing deferral seed approach (the non-resolving branch preserves F-formulas via f_carry, and the bounded deferral argument from Plan 06 Phase 4 applies). |
| Root parameterization breaks downstream lemmas (g_content propagation, box stability) | M | L | These lemmas depend only on `g_content` inclusion in the seed, which is unchanged. The root parameter is additive. Run `lake build` after each phase. |
| `backward_until_from_step` API mismatch with available step transfer | M | L | The API requires `(phi U psi) in fam.mcs (r+1) and phi in fam.mcs r -> (phi U psi) in fam.mcs r`. Our step transfer gives the stronger unconditional version (no guard needed). Satisfies the API by ignoring the `phi` hypothesis. |
| Until formulas conflict with resolving target psi in the seed via BX9 | M | M | BX9 gives `(phi U psi') -> phi v psi'`. If `psi' = neg(psi)`, then `neg(psi)` is derivable from the Until formula. Combined with `psi` in the resolving seed, this is inconsistent. The BX11 linearity argument must handle this case. If this specific case arises, restrict untilCarry to exclude Until formulas whose right operand is `neg(psi)`. |
| Well-founded induction for forward_F termination is difficult in Lean 4 | M | M | Use `Nat.lt_wfRel` or `WellFoundedRelation` instances. The deferralClosure is finite and computable, providing a natural termination measure. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Define Restricted Carry Sets and Verify Closure Properties [BLOCKED]

**Goal**: Define `restrictedUntilCarry` and `restrictedSinceCarry`, verify that `subformulaClosure(root)` has the necessary closure properties for the BX12 reduction, and establish the mathematical prerequisites.

**Tasks**:
- [ ] Define `restrictedUntilCarry (M : Set Formula) (root : Formula) : Set Formula := {phi in M | exists a b, phi = Formula.untl a b and phi in subformulaClosure root}` in a new section of `CanonicalModel.lean` or a new file `RestrictedSeed.lean`
- [ ] Prove `restrictedUntilCarry_subset : restrictedUntilCarry M root subset M`
- [ ] Prove `restrictedUntilCarry_finite : Set.Finite (restrictedUntilCarry M root)` (bounded by `|subformulaClosure root|`)
- [ ] Define `restrictedSinceCarry (M : Set Formula) (root : Formula) : Set Formula` symmetrically for Since formulas
- [ ] Prove `restrictedSinceCarry_subset` and `restrictedSinceCarry_finite`
- [ ] Verify `subformulaClosure` properties: does `F(psi) in subformulaClosure(root)` imply `(top U psi) in subformulaClosure(root)`? Check `SubformulaClosure.lean` or `EnrichedClosure.lean`. If not, determine whether `deferralClosure(root)` provides this.
- [ ] If the BX12 reduction path is blocked (closure gap), document the finding and note the fallback: prove restricted forward_F directly via bounded deferral
- [ ] `lake build` to verify compilation

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- New definitions section (~50 lines)
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/RestrictedSeed.lean` (new) -- If definitions warrant a separate file

**Verification**:
- All new definitions compile without sorry
- Closure property verification documented (go/no-go for BX12 reduction)
- `lake build` passes

---

### Phase 2: Prove Resolving-Branch Seed Consistency [NOT STARTED]

**Goal**: Prove that `{psi} union g_content(M) union restrictedUntilCarry(M, root)` is consistent when `F(psi) in M`. This is the critical novel proof -- the go/no-go decision point for Approach A.

**Tasks**:
- [ ] Attempt the main consistency proof combining temporal K with BX11 linearity:
  1. From `L subset seed` with `L derives bot`, partition `L = L_psi union L_g union L_u`
  2. By deduction: `L_g union L_u derives neg(psi)`
  3. Apply iterated deduction on `L_u` to get `L_g derives u_1 -> ... -> u_m -> neg(psi)`
  4. Apply temporal K: `G(u_1 -> ... -> u_m -> neg(psi)) in M`
  5. Use BX11/BX7 linearity to show `G(u_j) in M` or derive `G(neg(psi)) in M` by other means
  6. Derive `G(neg(psi)) in M`, contradicting `F(psi) in M`
- [ ] If the full BX11/BX7 argument is too complex, try the alternative: prove consistency by showing that any derivation `L_g union L_u derives neg(psi)` with `L_u` consisting of Until formulas implies `neg(psi) in M` (by MCS closure), and then check whether this leads to contradiction via properties of Until formulas and `F(psi) in M`
- [ ] If the consistency proof fails after 4 hours: STOP. Document the failure and the exact point where the proof breaks. Switch to Approach B (Phase 2B below).
- [ ] `lake build` to verify

**Timing**: 4 hours (hard cutoff)

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` or `RestrictedSeed.lean` -- Consistency proof (~100-200 lines)

**Verification**:
- `restricted_resolving_seed_consistent` compiles without sorry, OR
- Clear documentation of failure point and switch to Approach B

---

### Phase 3: Modify Chain Construction with Root Parameter [NOT STARTED]

**Goal**: Parameterize `fwd_succ`/`bwd_pred` by `root : Formula`, add `restrictedUntilCarry`/`restrictedSinceCarry` to seeds, propagate the root parameter through `fwd_chain`, `bwd_chain`, `int_chain`, `bx_fmcs`, `shifted_bx_fmcs`, `bx_bfmcs`, and `bx_countermodel`. Verify all existing lemmas still hold.

**Tasks**:
- [ ] Modify `fwd_succ` signature to take `root : Formula` parameter
- [ ] Modify resolving branch seed: `forward_temporal_witness_seed M psi` becomes `forward_temporal_witness_seed M psi union restrictedUntilCarry M root` (using Phase 2 consistency proof)
- [ ] Modify non-resolving branch seed: `g_content M union f_carry M` becomes `g_content M union f_carry M union restrictedUntilCarry M root` (consistent because subset of M)
- [ ] Modify `bwd_pred` symmetrically with `restrictedSinceCarry`
- [ ] Re-prove `fwd_succ_mcs`, `fwd_succ_g_content`, `fwd_succ_resolves`, `fwd_succ_f_carry` for the modified seeds (should be straightforward -- seed is enlarged, so old inclusions hold)
- [ ] Prove `fwd_succ_until_carry : restrictedUntilCarry M root subset fwd_succ M h_mcs psi root` (follows from seed inclusion in both branches)
- [ ] Propagate `root` parameter through `fwd_chain`, `bwd_chain`, `int_chain`
- [ ] Propagate through `bx_fmcs`, `shifted_bx_fmcs`, `bx_bfmcs`
- [ ] Update `bx_countermodel` to pass `root = phi` to the chain construction
- [ ] Verify `int_chain_forward_G`, `int_chain_backward_H`, `box_stable_in_int_chain` still hold (these depend on g_content/h_content inclusion, which is unchanged)
- [ ] `lake build` -- this is the most critical build check, as many downstream lemmas reference the chain

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Modify ~15 definitions and ~20 lemmas to propagate root parameter (~200 lines changed)

**Verification**:
- `lake build` passes (sorry count unchanged or decreased)
- `fwd_succ_until_carry` and `bwd_pred_since_carry` compile without sorry
- All existing G/H propagation and box stability lemmas still compile

---

### Phase 4: Prove Until Persistence and Step Transfer [NOT STARTED]

**Goal**: Prove that Until formulas from `subformulaClosure(root)` persist forward through all chain steps, and derive backward step transfer.

**Tasks**:
- [ ] Prove `until_persists_forward`: for `(phi U psi) in subformulaClosure(root)`, if `(phi U psi) in int_chain M0 h0 root t`, then `(phi U psi) in int_chain M0 h0 root (t+1)`. Proof: `(phi U psi) in restrictedUntilCarry(int_chain t, root)`, which is in the seed of `fwd_succ`, hence in `int_chain(t+1)`.
- [ ] Prove `until_persists_forward_le`: extend to `t <= s` by induction on `s - t`
- [ ] Prove `since_persists_backward` and `since_persists_backward_le` symmetrically
- [ ] Derive `restricted_until_step_transfer`: `(phi U psi) in subformulaClosure(root) -> (phi U psi) in (bx_fmcs M0 h0 root).mcs (r+1) -> (phi U psi) in (bx_fmcs M0 h0 root).mcs r`. Proof: by contrapositive of forward persistence? No -- forward persistence goes forward, not backward. The step transfer requires: if `(phi U psi) in chain(r+1)` and `(phi U psi) in subformulaClosure(root)`, then `(phi U psi) in chain(r)`. This is NOT a direct consequence of forward persistence. Instead: at time r, the seed includes `restrictedUntilCarry(chain(r), root)`. For `(phi U psi) in chain(r+1)`, we need `(phi U psi) in chain(r)`. This is NOT guaranteed -- `chain(r+1)` is built FROM `chain(r)`, but formulas can enter `chain(r+1)` via Lindenbaum that were not in `chain(r)`. REVISED approach: use `or_until_in_mcs` -- if `psi in chain(r)` OR `(phi and (phi U psi)) in chain(r)`, then `(phi U psi) in chain(r)`. Since `(phi U psi) in chain(r+1)` and `(phi U psi)` persists forward, actually we need backward direction. Think more carefully.
- [ ] ALTERNATIVE step transfer approach: Use `backward_until_from_step` directly. The step transfer hypothesis for `backward_until_from_step` requires: `(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)`. Since `(phi U psi)` is in `restrictedUntilCarry(chain(r), root)` only if `(phi U psi) in chain(r)` (circular). Instead: for the backward Until proof, we can avoid step transfer entirely if we prove backward Until coherence by a different route (direct BX axiom argument on the chain).
- [ ] If step transfer is not provable directly, use the FORWARD persistence argument: given the witness pattern `(exists s >= t, psi in chain(s), phi on guard)`, prove `(phi U psi) in chain(t)` by: `psi in chain(s) -> (phi U psi) in chain(s)` (BX8), then `(phi U psi) in chain(s) -> (phi U psi) in chain(s-1) -> ... -> chain(t)` via forward persistence applied BACKWARD. But forward persistence goes t -> t+1, not t+1 -> t. This is still the step transfer problem.
- [ ] FINAL approach for step transfer: If `(phi U psi) in subformulaClosure(root)` and `phi in chain(r)` and `(phi U psi) in chain(r+1)`, then in chain(r): `phi in chain(r)` and `F(phi U psi) in chain(r)` (by BX4' connect_past on chain(r+1) + backward H propagation). Then by BX12: `(top U (phi U psi)) in chain(r)`. Then use BX left strengthening or direct MCS reasoning to get `(phi U psi) in chain(r)` from `phi in chain(r)` and `F(phi U psi) in chain(r)`. Specifically: `phi and F(phi U psi) -> (phi U psi)` is derivable via BX5 (self-accumulation) + BX axioms. Verify this derivation path exists.
- [ ] `lake build`

**Timing**: 3 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Until persistence proofs, step transfer (~80-120 lines)

**Verification**:
- `until_persists_forward_le` compiles without sorry
- Step transfer or alternative backward Until mechanism compiles
- `lake build` passes

---

### Phase 5: Close Restricted Temporal Coherence and Until/Since Coherence [NOT STARTED]

**Goal**: Close the 3 active-path sorry sites: `bx_bfmcs_restricted_tc` (restricted forward_F/backward_P), `bx_bfmcs_restricted_buc` (backward Until/Since), `bx_bfmcs_restricted_fuc` (forward Until/Since).

**Tasks**:
- [ ] **Restricted backward Until/Since** (`bx_bfmcs_restricted_buc`, line 621):
  - Until conjunct: Given witness pattern `(s >= t, psi in chain(s), phi on guard [t, s))`, prove `(phi U psi) in chain(t)`. Use step transfer from Phase 4 with `backward_until_from_step` API. If step transfer was not available, use the alternative BX4'/BX12 argument from Phase 4.
  - Since conjunct: Symmetric using `backward_since_from_step`.
- [ ] **Restricted forward_F** (part of `bx_bfmcs_restricted_tc`, line 603):
  - If BX12 reduction works (Phase 1 verified closure): `F(psi) in chain(t) -> (top U psi) in chain(t)` by BX12. Then by restricted forward Until (which we prove below), `psi` appears at some future step. Done.
  - If BX12 reduction is blocked: use the bounded deferral argument. F-formulas persist through non-resolving steps (via f_carry). The schedule ensures every formula is targeted infinitely often. At a resolving step for psi, if `F(psi) in chain(n)`, then `psi in chain(n+1)`. Implement via well-founded induction on formula complexity within `deferralClosure(root)`.
- [ ] **Restricted backward_P** (part of `bx_bfmcs_restricted_tc`): Symmetric to forward_F.
- [ ] **Restricted forward Until/Since** (`bx_bfmcs_restricted_fuc`, line 627):
  - Given `(phi U psi) in chain(t)`:
    1. By BX9: `phi v psi in chain(t)`
    2. Case `psi in chain(t)`: witness s = t, guard vacuous. Done.
    3. Case `phi in chain(t)`: By BX10: `F(psi) in chain(t)`. By restricted forward_F: exists `s > t` with `psi in chain(s)`. Take minimal such s. For guard: at each q in [t, s), `(phi U psi) in chain(q)` (by Until persistence from Phase 4), so BX9 gives `phi v psi in chain(q)`. Since q < s (minimal witness), `psi not in chain(q)`, hence `phi in chain(q)`.
  - Since conjunct: Symmetric.
- [ ] `lake build` to verify all 3 restricted sorry sites are closed

**Timing**: 2.5 hours

**Depends on**: 4 (needs step transfer and Until persistence)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Close 3 sorry sites (~120 lines)

**Verification**:
- `bx_bfmcs_restricted_tc` has no sorry
- `bx_bfmcs_restricted_buc` has no sorry
- `bx_bfmcs_restricted_fuc` has no sorry
- `lake build` passes with zero sorry on active path

---

### Phase 6: Cleanup and Final Verification [NOT STARTED]

**Goal**: Clean up dead code, verify the full build, and confirm axiom purity.

**Tasks**:
- [ ] Mark the unrestricted sorry-bearing theorems (`bx_fmcs_forward_F` at line 497, `bx_fmcs_backward_P` at line 503, `bx_bfmcs_buc`/`bx_bfmcs_fuc`/`bx_bfmcs_tc` at lines 570-591) with comments indicating they are dead code
- [ ] Delete or mark `f_carry`, `p_carry`, `enriched_seed_consistent`, `enriched_past_seed_consistent` if no longer used (check references first)
- [ ] Run `lake build` and verify zero errors
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` and verify no sorry on active path
- [ ] Add `#print axioms bx_completeness` check and verify output shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Run full `lake build` for regression testing

**Timing**: 0.5 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Remove/mark dead code (~80 lines removed)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Add `#print axioms` verification

**Verification**:
- `lake build` succeeds with zero errors
- `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no matches on active path
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

## Testing & Validation

- [ ] `lake build` completes with zero errors after each phase
- [ ] Phase 2 go/no-go: resolving-branch consistency proof closes within 4 hours, OR failure documented with Approach B fallback
- [ ] `until_persists_forward_le` and corresponding Since lemma compile without sorry
- [ ] Backward step transfer (or alternative BX4'/BX12 mechanism) compiles without sorry
- [ ] All 3 restricted sorry sites (`bx_bfmcs_restricted_tc`, `bx_bfmcs_restricted_buc`, `bx_bfmcs_restricted_fuc`) have no sorry
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no active-path matches
- [ ] `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Full `lake build` succeeds for regression testing

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Major changes (~400 lines modified): restrictedUntilCarry/restrictedSinceCarry definitions, modified seeds with root parameter, consistency proof, Until persistence, step transfer, restricted temporal coherence, backward/forward Until/Since coherence, dead code cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Add `#print axioms` verification
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/RestrictedSeed.lean` (new) -- If restricted seed definitions and consistency proof warrant a separate file
- `specs/093_complete_bxcanonical_embedding/summaries/08_bxcanonical-embedding-summary.md` -- Implementation summary (created after completion)

## Rollback/Contingency

**Phase 2 failure (resolving-branch consistency)**:
- If the BX11/BX7 consistency proof does not close within 4 hours, switch to Approach B.
- Approach B: Build a parallel `quasimodel_chain` that uses `restrictedUntilCarry` only in the non-resolving seed (consistency trivial). For the resolving branch, keep the existing `{psi} union g_content(M)` seed. The non-resolving branch preserves Until formulas, which provides partial persistence. The forward_F proof then uses the bounded deferral argument: F-formulas persist through non-resolving steps (via f_carry), and the schedule ensures every formula is targeted. The step transfer argument uses BX4' (connect_past) + backward H propagation to derive `F(phi U psi) in chain(r)` from `(phi U psi) in chain(r+1)`, then a BX axiom chain to get `(phi U psi) in chain(r)` when `phi in chain(r)`.
- Estimated additional effort for Approach B: +8 hours.

**Phase 3 refactoring breaks downstream**:
- Root parameterization can be reverted with `git checkout -- CanonicalModel.lean`.
- If partial, save the modified file as `CanonicalModel_v8.lean` and work in parallel.

**BX12 closure gap (Phase 1)**:
- If `(top U psi)` is not in `subformulaClosure(root)`, prove restricted forward_F directly using bounded deferral. The deferral seed approach from Plan 06 Phase 3 (deferral disjunctions) can be combined with the non-resolving branch f_carry to achieve F-formula persistence through non-resolving steps.

**General rollback**:
- All changes are in `CanonicalModel.lean` (and possibly one new file). Git revert is straightforward.
- Dead code deletion (Phase 6) can be deferred indefinitely without blocking the definition of done.
