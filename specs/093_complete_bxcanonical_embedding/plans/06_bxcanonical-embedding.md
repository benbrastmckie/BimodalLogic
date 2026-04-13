# Implementation Plan: Close Remaining BXCanonical Sorries (v6)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (tasks 92, 94 already completed)
- **Research Inputs**: reports/06_team-research.md, reports/05_team-research.md
- **Artifacts**: plans/06_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the 4 remaining active-path sorry sites in `CanonicalModel.lean` that block `bx_completeness` from being sorry-free: `bx_bfmcs_restricted_tc` (lines 603-615, restricted forward_F/backward_P), `bx_bfmcs_restricted_buc` (line 621, backward Until/Since coherence), `bx_bfmcs_restricted_fuc` (line 627, forward Until/Since coherence), plus the 2 unrestricted sorry sites at lines 497 and 503 that `bx_bfmcs_restricted_tc` currently delegates to. The approach has three pillars: (1) add `until_neg_carry` / `since_neg_carry` to chain seeds for backward Until/Since step transfer via forward stability of negated Until, (2) add deferral disjunctions to seeds for restricted forward_F/backward_P, (3) combine restricted forward_F with until_neg_carry-based step transfer for forward Until/Since. Definition of done: `lake build` succeeds with zero sorry on the active completeness path, and `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

Six rounds of research (Reports 01-06) established the following key findings integrated into this plan:

- **Plan 05 Phase 3 contrapositive argument DEFINITIVELY REFUTED** (unanimous, all 4 teammates in R06). The biconditional reverse direction `psi v (phi ^ F(phi U psi)) -> (phi U psi)` is semantically invalid, and the derivation `neg(phi U psi) ^ phi -> G(neg(phi U psi))` fails.
- **The solution is `until_neg_carry`** (Teammate D, confirmed by B and C in R06). Adding `until_neg_carry(M) = {neg(phi U psi) | neg(phi U psi) in M}` to the `fwd_succ` seed gives forward stability of negated Until formulas. The contrapositive gives backward Until step transfer unconditionally (no guard condition needed). Consistency is trivial: `until_neg_carry(M) subset M`.
- **Symmetric fix for Since**: `since_neg_carry(M) = {neg(phi S psi) | neg(phi S psi) in M}` added to `bwd_pred` seeds.
- **Deferral seed work for forward_F/backward_P is independent** and still needed. The consistency proof remains the same (deferral disjunctions are tautological consequences of MCS membership, so the augmented seed is a subset of M).
- **Forward Until coherence** = restricted forward_F (via deferral seeds) + backward Until step transfer (via until_neg_carry) for the guard argument.

### Prior Plan Reference

Plan 05 had 5 phases. Phase 1 (Port F(top)/P(top) and verify expansion axioms) is COMPLETED. Phase 2 (deferral chain modification) was PARTIAL then reverted because the consistency proof approach was unclear. Phases 3-5 were BLOCKED/NOT STARTED. Key lessons: (a) the contrapositive argument from Phase 3 is fundamentally flawed and must be replaced with until_neg_carry, (b) F(top)/P(top) are already ported and available, (c) deferral seed consistency uses the subset-of-M argument which is straightforward, (d) the Plan 05 effort estimate of 9 hours was reasonable but phases 2-3 need complete restructuring.

### Roadmap Alignment

- Closes the sole remaining active-path sorry (1 of 1) blocking `bx_completeness`
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Once complete, `completeness_over_Int` becomes sorry-free via BXCanonical

## Goals & Non-Goals

**Goals**:
- Define `until_neg_carry` and `since_neg_carry` and add them to chain seeds
- Prove forward stability of negated Until/Since formulas
- Derive backward Until/Since step transfer as contrapositive of stability
- Close `bx_bfmcs_restricted_buc` using `backward_until_from_step` with the step transfer
- Add deferral disjunctions to `fwd_succ`/`bwd_pred` seeds for restricted forward_F/backward_P
- Rewrite `bx_bfmcs_restricted_tc` to prove restricted forward_F/backward_P directly
- Close `bx_bfmcs_restricted_fuc` using restricted forward_F + until_neg_carry step transfer for guard
- Achieve `lake build` with zero active-path sorry
- Verify `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

**Non-Goals**:
- Dense time completeness (`D = Rat`), which is a separate task (68)
- Proving full (unrestricted) `temporally_coherent` for the dovetailed chain
- Closing sorries in unrestricted dead code (`bx_bfmcs_buc`/`bx_bfmcs_fuc`/`bx_bfmcs_tc` at lines 586-591)
- Closing unrestricted `bx_fmcs_forward_F`/`bx_fmcs_backward_P` (lines 497, 503)
- Performance optimization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `until_neg_carry` consistency when combined with existing seed | H | L | Trivial: `until_neg_carry(M) subset M`, and any subset of a consistent MCS is consistent. The union of multiple subsets of M is still a subset of M. |
| Forward stability induction fails due to Lindenbaum non-determinism | H | L | Lindenbaum extends a consistent seed to an MCS. If `neg(phi U psi)` is in the seed, it must be in the resulting MCS. The induction is over chain position, not Lindenbaum internals. |
| Deferral seed consistency proof is non-trivial | M | M | Deferral disjunctions `chi v F(chi)` are in M when `F(chi) in M` (by MCS disjunction properties). So the augmented seed is a subset of M. If the MCS disjunction property is not directly available, derive it from `SetMaximalConsistent.or_membership`. |
| `backward_until_from_step` API requires guard condition but until_neg_carry gives unconditional step transfer | M | L | `backward_until_from_step` requires `h_step : forall r, (phi U psi) in fam.mcs (r+1) -> phi in fam.mcs r -> (phi U psi) in fam.mcs r`. With until_neg_carry, we get the stronger: `(phi U psi) in fam.mcs (r+1) -> (phi U psi) in fam.mcs r` (no guard needed). This satisfies the weaker API by ignoring the `phi in fam.mcs r` hypothesis. |
| `bounded_witness` API does not match restricted forward_F proof structure | M | M | Verified: `bx_bfmcs_restricted_tc` currently delegates to `bx_fmcs_forward_F`. The new approach proves restricted forward_F directly using deferral seeds and well-founded induction on F-nesting depth. If `bounded_witness` API mismatch, implement termination inline. |
| Forward Until guard argument at intermediate times | M | L | With until_neg_carry, step transfer is unconditional: `(phi U psi) in chain(r+1) -> (phi U psi) in chain(r)`. So if `(phi U psi) in chain(t)` and `psi in chain(s)` with `s > t`, then `(phi U psi) in chain(q)` for all `q in [t, s]` by backward step transfer from `s`. BX9 gives `phi v psi` at each such `q`, and for `q < s` where `psi` may not hold, we get `phi`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Add until_neg_carry / since_neg_carry to Chain Seeds [NOT STARTED]

**Goal**: Define `until_neg_carry(M)` and `since_neg_carry(M)`, add them to the `fwd_succ` and `bwd_pred` seeds respectively, and prove the consistency of the augmented seeds. Prove forward stability of negated Until formulas and derive backward Until step transfer.

**Tasks**:
- [ ] Define `until_neg_carry (M : Set Formula) : Set Formula := {phi in M | exists a b, phi = Formula.neg (Formula.untl a b)}` in `CanonicalModel.lean`
- [ ] Prove `until_neg_carry_subset : until_neg_carry M subset M`
- [ ] Define `since_neg_carry (M : Set Formula) : Set Formula := {phi in M | exists a b, phi = Formula.neg (Formula.snce a b)}` in `CanonicalModel.lean`
- [ ] Prove `since_neg_carry_subset : since_neg_carry M subset M`
- [ ] Modify `fwd_succ` resolving branch: change seed from `forward_temporal_witness_seed M psi` to `forward_temporal_witness_seed M psi union until_neg_carry M`; prove consistency (both parts subset M)
- [ ] Modify `fwd_succ` non-resolving branch: change seed from `g_content M union f_carry M` to `g_content M union f_carry M union until_neg_carry M`; prove consistency (all parts subset M)
- [ ] Modify `bwd_pred` resolving branch: change seed from `past_temporal_witness_seed M psi` to `past_temporal_witness_seed M psi union since_neg_carry M`; prove consistency
- [ ] Modify `bwd_pred` non-resolving branch: change seed from `h_content M union p_carry M` to `h_content M union p_carry M union since_neg_carry M`; prove consistency
- [ ] Prove `fwd_succ_until_neg_carry : until_neg_carry M subset fwd_succ M h_mcs psi` (follows from seed inclusion in both branches)
- [ ] Prove `bwd_pred_since_neg_carry : since_neg_carry M subset bwd_pred M h_mcs psi` (symmetric)
- [ ] Verify that existing theorems `fwd_succ_g_content`, `fwd_succ_resolves`, `fwd_succ_f_carry`, `bwd_pred_h_content`, `bwd_pred_resolves`, `bwd_pred_p_carry` still hold (they reference a subset of the enlarged seed, so inclusion is preserved)
- [ ] Prove `neg_until_forward_stable : neg(phi U psi) in int_chain M0 h0 t -> neg(phi U psi) in int_chain M0 h0 (t+1)` by showing neg(phi U psi) is in `until_neg_carry(int_chain M0 h0 t)` which is in the seed of `fwd_succ`, hence in `int_chain M0 h0 (t+1)` by Lindenbaum
- [ ] Prove `neg_until_forward_stable_le : neg(phi U psi) in int_chain M0 h0 t -> t <= s -> neg(phi U psi) in int_chain M0 h0 s` by induction on `s - t`
- [ ] Derive `until_backward_step_transfer : (phi U psi) in (bx_fmcs M0 h0).mcs (r+1) -> (phi U psi) in (bx_fmcs M0 h0).mcs r` as contrapositive of `neg_until_forward_stable`
- [ ] Prove symmetric results for Since: `neg_since_backward_stable`, `neg_since_backward_stable_le`, `since_forward_step_transfer`
- [ ] Verify `int_chain_forward_G`, `int_chain_backward_H`, `box_stable_in_int_chain` still hold (these depend only on g_content/h_content inclusion)
- [ ] `lake build` to verify compilation (sorry count should not increase)

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Add until_neg_carry/since_neg_carry definitions, modify fwd_succ/bwd_pred seeds, prove stability and step transfer (~100 lines added/modified)

**Verification**:
- `lake build` compiles (sorry count unchanged or decreased)
- `neg_until_forward_stable_le` and `until_backward_step_transfer` have no sorry
- Existing `int_chain_forward_G`, `int_chain_backward_H` still compile

---

### Phase 2: Close Backward Until/Since Coherence [NOT STARTED]

**Goal**: Close `bx_bfmcs_restricted_buc` (line 621) by plugging `until_backward_step_transfer` into `backward_until_from_step`, and the symmetric Since result into `backward_since_from_step`.

**Tasks**:
- [ ] Close the Until conjunct of `bx_bfmcs_restricted_buc`: unpack the shifted family, construct the step transfer hypothesis for `shifted_bx_fmcs`, then apply `backward_until_from_step` with the step transfer, the given witness `r`, and the given guard
- [ ] The step transfer for shifted families: `(phi U psi) in (shifted_bx_fmcs N h_N s).mcs (r+1) -> (phi U psi) in (shifted_bx_fmcs N h_N s).mcs r`. This follows from `until_backward_step_transfer` after adjusting indices (shifted family at time `t` = int_chain at time `t - s`)
- [ ] Close the Since conjunct symmetrically using `backward_since_from_step` with `since_forward_step_transfer`
- [ ] `lake build` to verify the sorry at line 621 is closed

**Timing**: 1 hour

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Close `bx_bfmcs_restricted_buc` sorry (~30 lines)

**Verification**:
- `bx_bfmcs_restricted_buc` has no sorry
- `lake build` compiles

---

### Phase 3: Add Deferral Disjunctions to Seeds for Restricted forward_F/backward_P [NOT STARTED]

**Goal**: Augment `fwd_succ` and `bwd_pred` seeds with deferral disjunctions to enable restricted forward_F/backward_P to be proved directly, without delegating to the unprovable unrestricted versions.

**Tasks**:
- [ ] Define `deferral_disjunctions (M : Set Formula) : Set Formula := {phi | exists chi, Formula.some_future chi in M and phi = (chi.or (Formula.some_future chi))}` -- for each `F(chi) in M`, include `chi v F(chi)`
- [ ] Prove `deferral_disjunctions_subset : deferral_disjunctions M subset M` -- if `F(chi) in M` then `chi v F(chi) in M` by MCS property (from `F(chi)` derive `chi v F(chi)` via the tautology `F(chi) -> chi v F(chi)` which follows from `G(chi -> chi)` and BX1)
- [ ] Note: The correct MCS argument is simpler -- `F(chi) in M` implies `chi v F(chi) in M` because `chi v F(chi)` is a weakening of `F(chi)` (provable: `F(chi) -> chi v F(chi)` by propositional logic from `x -> y v x`). Verify this derivation path exists in the codebase.
- [ ] Define symmetric `past_deferral_disjunctions (M : Set Formula) : Set Formula` for `P(chi)` formulas
- [ ] Prove `past_deferral_disjunctions_subset : past_deferral_disjunctions M subset M`
- [ ] Modify `fwd_succ` resolving branch: add `deferral_disjunctions M` to seed (now: `forward_temporal_witness_seed M psi union until_neg_carry M union deferral_disjunctions M`)
- [ ] Modify `fwd_succ` non-resolving branch: add `deferral_disjunctions M` to seed
- [ ] Modify `bwd_pred` branches: add `past_deferral_disjunctions M` symmetrically
- [ ] Prove `fwd_succ_deferral : F(chi) in M -> chi in fwd_succ M h_mcs psi or F(chi) in fwd_succ M h_mcs psi` -- `chi v F(chi)` is in the seed, so in the resulting MCS; by MCS disjunction property, one disjunct holds
- [ ] Prove `bwd_pred_deferral` symmetrically for `P(chi)`
- [ ] Verify all existing theorems still hold (the seed is only enlarged, so inclusion proofs are preserved)
- [ ] `lake build` to check compilation

**Timing**: 2 hours

**Depends on**: 1 (builds on the modified seeds from Phase 1)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Add deferral definitions, further modify seeds, prove deferral properties (~80 lines added/modified)

**Verification**:
- `lake build` compiles (sorry count unchanged or decreased)
- `fwd_succ_deferral` and `bwd_pred_deferral` have no sorry
- Existing properties still hold

---

### Phase 4: Close Restricted Temporal Coherence and Forward Until/Since Coherence [NOT STARTED]

**Goal**: Rewrite `bx_bfmcs_restricted_tc` (lines 603-615) to prove restricted forward_F/backward_P directly using deferral seeds (not delegating to unrestricted versions). Close `bx_bfmcs_restricted_fuc` (line 627) using restricted forward_F + until_neg_carry step transfer for the guard.

**Tasks**:
- [ ] **Restricted forward_F**: Rewrite the forward_F branch of `bx_bfmcs_restricted_tc`. For `phi in deferralClosure(root)` with `F(phi) in chain(t)`: by `fwd_succ_deferral`, at each step the chain either resolves `phi` (done) or defers `F(phi)`. By well-founded induction on F-nesting depth within `deferralClosure(root)` (which is finite), infinite deferral is impossible. Use `bounded_witness` or implement the termination argument inline.
- [ ] **Restricted backward_P**: Symmetric argument using `bwd_pred_deferral` and past bounded witness
- [ ] Wire restricted forward_F/backward_P into `bx_bfmcs_restricted_tc` replacing the current delegation to `bx_fmcs_forward_F`/`bx_fmcs_backward_P`
- [ ] **Forward Until coherence** -- close `bx_bfmcs_restricted_fuc`. For `(phi U psi) in chain(t)`:
  1. By BX9 (`until_elim`): `phi v psi in chain(t)`
  2. Case `psi in chain(t)`: witness `s = t`, guard is vacuous. Done.
  3. Case `phi in chain(t)`, `neg psi in chain(t)`: By BX10 (`until_F`): `F(psi) in chain(t)`. By restricted forward_F (verifying `psi in deferralClosure(root)`): exists `s > t` with `psi in chain(s)`.
  4. Guard: need `phi in chain(q)` for all `q in [t, s)`. By `until_backward_step_transfer` (from Phase 1), `(phi U psi) in chain(r+1) -> (phi U psi) in chain(r)` unconditionally. Since `psi in chain(s)` implies `(phi U psi) in chain(s)` by BX8, backward step transfer gives `(phi U psi) in chain(q)` for all `q in [t, s]`. Then BX9 gives `phi v psi in chain(q)`. For `q < s`, if `psi not in chain(q)`, then `phi in chain(q)`.
  5. However, we need `phi in chain(q)` even when `psi in chain(q)` at intermediate `q`. The guard requires `phi` at all intermediate points, not just where `psi` fails. Re-examine: `backward_until_from_step` requires `phi in fam.mcs r` for `t <= r < s`. At each such `r`, we have `(phi U psi) in chain(r)` (by step transfer from `s`). BX9 gives `phi v psi`. If `psi in chain(r)` at some `r < s`, use `r` as the witness instead (smaller). Take `s` to be the FIRST time `psi` holds in `[t, infinity)`. Then for `q in [t, s)`, `psi not in chain(q)`, so BX9 gives `phi in chain(q)`.
  6. So the proof structure: given `F(psi) in chain(t)`, restricted forward_F gives `s > t` with `psi in chain(s)`. Take the minimal such `s` (or equivalently, just argue that at any `q in [t, s)`, `psi not in chain(q)` would give `phi` via BX9, and if `psi in chain(q)` for some `q < s`, use `q` as the witness with vacuous guard).
- [ ] **Forward Since coherence**: Symmetric argument using backward_P and since step transfer
- [ ] `lake build` to verify all sorry sites are closed

**Timing**: 2 hours

**Depends on**: 2 (needs step transfer for guard argument), 3 (needs deferral seeds for restricted forward_F)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Rewrite `bx_bfmcs_restricted_tc`, close `bx_bfmcs_restricted_fuc` (~100 lines)

**Verification**:
- `bx_bfmcs_restricted_tc` has no sorry
- `bx_bfmcs_restricted_fuc` has no sorry
- `lake build` compiles with zero sorry on active path

---

### Phase 5: Cleanup and Final Verification [NOT STARTED]

**Goal**: Clean up dead code, verify the full build, and confirm axiom purity of `bx_completeness`.

**Tasks**:
- [ ] Mark or delete the unrestricted sorry-bearing theorems (`bx_fmcs_forward_F` at line 497, `bx_fmcs_backward_P` at line 503, `bx_bfmcs_buc`/`bx_bfmcs_fuc`/`bx_bfmcs_tc` at lines 586-591) -- these are now dead code
- [ ] Delete or mark `f_carry`, `p_carry`, `enriched_seed_consistent`, `enriched_past_seed_consistent` if no longer used after seed changes (check references first)
- [ ] Run `lake build` and verify zero errors
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` and verify no sorry on active path (dead code marked with comments is acceptable)
- [ ] Add `#print axioms bx_completeness` check and verify output shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Run full `lake build` for regression testing

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Remove dead code (~80 lines removed)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Add `#print axioms` check

**Verification**:
- `lake build` succeeds with zero errors
- `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no matches on active path
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

## Testing & Validation

- [ ] `lake build` completes with zero errors after each phase
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no active-path matches
- [ ] `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No regressions: full `lake build` succeeds for the entire project
- [ ] `neg_until_forward_stable_le` and `until_backward_step_transfer` are sorry-free
- [ ] `fwd_succ_deferral` and `bwd_pred_deferral` are sorry-free
- [ ] Restricted forward_F terminates via bounded_witness / well-founded induction argument

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Major changes (~300 lines modified): until_neg_carry/since_neg_carry definitions, modified seeds with deferral disjunctions, stability proofs, step transfer, restricted temporal coherence, backward/forward Until/Since coherence, dead code cleanup
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Add `#print axioms` verification
- `specs/093_complete_bxcanonical_embedding/summaries/06_bxcanonical-embedding-summary.md` -- Implementation summary (created after completion)

## Rollback/Contingency

- Phase 1 seed modifications can be reverted with `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` since all changes are in one file.
- If `until_neg_carry` approach fails (extremely unlikely given the mathematical proof and 4 teammate confirmation), fall back to x_content enrichment from Boneyard `DeterministicChain.lean` (Teammate B's finding), which requires more infrastructure but is proven to work.
- If deferral seed consistency (Phase 3) proves harder than expected, the seed can be simplified to only include deferral disjunctions for formulas in `deferralClosure(root)` (a finite set), making the subset-of-M argument even more straightforward.
- If restricted forward_F termination argument (Phase 4) is difficult with `bounded_witness` API, implement the well-founded induction on F-nesting depth inline using `Nat.lt_wfRel`.
- Dead code deletion (Phase 5) can be deferred without blocking the definition of done.
