# Implementation Plan: Close Remaining BXCanonical Sorries

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 9 hours
- **Dependencies**: None (tasks 92, 94 already completed)
- **Research Inputs**: reports/05_team-research.md, reports/04_team-research.md
- **Artifacts**: plans/05_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the 3 remaining active-path sorry sites in `CanonicalModel.lean` that block `bx_completeness` from being sorry-free. The sorry sites are: `bx_bfmcs_restricted_tc` (lines 603-615, delegates to unprovable unrestricted forward_F/backward_P), `bx_bfmcs_restricted_buc` (line 621, backward Until/Since coherence), and `bx_bfmcs_restricted_fuc` (line 627, forward Until/Since coherence). The approach has three pillars: (1) modify the chain seed to use deferral disjunctions so restricted forward_F/backward_P become provable, (2) use a novel contrapositive argument via `until_unfold_thm` and `g_content` propagation for backward Until (bypassing the unprovable step transfer), and (3) combine restricted forward_F with the contrapositive argument for forward Until. Definition of done: `lake build` succeeds with zero sorry on the active completeness path, and `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

Five rounds of research (Reports 01-05) established the following key findings integrated into this plan:

- **Unrestricted forward_F is unprovable** for the current dovetailed chain (unanimous, all 4 teammates in R05). The chain's resolving-step seed `{psi} union g_content(M)` can destroy other F-obligations during Lindenbaum extension.
- **Restricted forward_F IS provable** via deferral seeds: augmenting the seed with `phi v F(phi)` for each `F(phi) in M` gives resolve-or-defer semantics, and `bounded_witness` from `CanonicalTaskRelation.lean` provides the termination argument.
- **Backward Until step transfer is unprovable** with the current chain, but a **novel contrapositive argument** works: from `neg(phi U psi) in chain(t)` and `phi in chain(t)`, derive `G(neg(phi U psi)) in chain(t)` via `until_unfold_thm` + MCS properties, then propagate to chain(r) via `g_content` to contradict `psi in chain(r)` + BX8.
- **Forward Until coherence** reduces to restricted forward_F (for finding the psi-witness) + the contrapositive argument (for the phi-guard at intermediate times).
- **F(top) must be ported** from Boneyard (`SuccChainFMCS.lean`) as a prerequisite for `successor_deferral_seed_consistent`.
- **Chain modification should augment, not replace**: keep the resolving seed for target formula, add deferral disjunctions to both resolving and non-resolving seeds.

### Prior Plan Reference

Plan 04 had 4 phases: Phase 1 (Restricted Truth Lemma) and Phase 4 (Wire Restricted Infrastructure) are COMPLETED. Phases 2 (Chain Modification for Deferral Seeds) and 3 (Prove Restricted Forward_F/Backward_P/Until/Since) were BLOCKED. Effort calibration from Plan 04: chain construction changes took ~2 hours, BFMCS packaging ~1.5 hours (both matched estimates). The forward_F blocker added ~4 hours of additional research. This plan restructures the blocked phases using the novel contrapositive approach from Research Report 05, separating prerequisites, chain modification, and coherence proofs into independent phases where possible.

### Roadmap Alignment

- Closes the sole remaining active-path sorry (1 of 1) blocking `bx_completeness`
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Once complete, `completeness_over_Int` becomes sorry-free via BXCanonical

## Goals & Non-Goals

**Goals**:
- Port F(top)/P(top) theorems from Boneyard to main codebase
- Verify availability of `until_unfold_thm` for the contrapositive backward Until argument
- Modify `fwd_succ`/`bwd_pred` chain seeds to use deferral disjunctions (augmenting, not replacing)
- Rewrite `bx_bfmcs_restricted_tc` to prove restricted forward_F/backward_P directly (not via unrestricted delegation)
- Close `bx_bfmcs_restricted_buc` using contrapositive argument
- Close `bx_bfmcs_restricted_fuc` using restricted forward_F + contrapositive guard argument
- Achieve `lake build` with zero active-path sorry
- Verify `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

**Non-Goals**:
- Dense time completeness (`D = Rat`), which is a separate task (68)
- Proving full (unrestricted) `temporally_coherent` for the dovetailed chain
- Closing sorries in the unrestricted `bx_bfmcs_buc`/`bx_bfmcs_fuc` (dead code)
- Closing the unrestricted `bx_fmcs_forward_F`/`bx_fmcs_backward_P` (dead code)
- Performance optimization

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BX expansion axiom gap: `until_unfold_thm` gives `(phi U psi) -> psi v (phi ^ (phi U psi))` but we need `neg(phi U psi) ^ phi -> G(neg(phi U psi))` for the contrapositive | H | M | Verify the derivation chain: `neg(phi U psi)` in MCS implies `neg(psi v (phi ^ F(phi U psi)))` by contrapositive of an expansion-like theorem. Since `phi` in MCS, this forces `neg F(phi U psi) = G(neg(phi U psi))`. If the full expansion biconditional is missing, derive the needed contrapositive from `until_unfold_thm` + BX10 + MCS disjunction properties. |
| Deferral seed consistency when augmenting resolving seed with deferral disjunctions | H | L | The resolving seed `{psi} union g_content(M)` is already consistent. Deferral disjunctions `chi v F(chi)` are tautological consequences of MCS membership (if `F(chi) in M` then `chi v F(chi) in M`). The augmented seed is a subset of M, hence consistent. |
| F(top) port reveals unexpected dependencies | L | L | The Boneyard proof is self-contained: `F_top_theorem` uses only `temp_t_future` (BX1 variant) and propositional reasoning. Port is mechanical (~15 lines). |
| `bounded_witness` API does not match restricted forward_F proof structure | M | M | Verified signature: `bounded_witness` takes `iter_F n phi in u`, `iter_F (n+1) phi not in u`, returns witness. Chain satisfies required relation via `g_content` inclusion. If API mismatch, implement the termination argument inline using well-founded induction on F-nesting depth within `deferralClosure(root)`. |
| Forward Until guard argument fails at intermediate times | M | M | The contrapositive argument is symmetric: if `neg(phi U psi) in chain(q)` for some intermediate `q in [t, s)` with `phi in chain(q)`, then `G(neg(phi U psi)) in chain(q)`, so `neg(phi U psi) in chain(s)`, contradicting `psi in chain(s)` + BX8. This reuses the same machinery as backward Until. |

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

### Phase 1: Prerequisites -- Port F(top)/P(top) and Verify Expansion Axiom [NOT STARTED]

**Goal**: Port `F_top_theorem`, `P_top_theorem`, `SetMaximalConsistent.contains_F_top`, and `SetMaximalConsistent.contains_P_top` from the Boneyard to the main `CanonicalChain.lean` file. Verify that the contrapositive argument for backward Until is derivable from available BX axioms.

**Tasks**:
- [ ] Port `F_top_theorem` from `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean` (lines 120-131) to `CanonicalChain.lean`
- [ ] Port `P_top_theorem` from `Boneyard/StrictSemanticsLegacy/Bundle/SuccChainFMCS.lean` (lines 134-145) to `CanonicalChain.lean`
- [ ] Port `SetMaximalConsistent.contains_F_top` and `contains_P_top` (lines 148-156) to `CanonicalChain.lean`
- [ ] Verify `until_unfold_thm` gives `(phi U psi) -> psi v (phi ^ (phi U psi))` (already confirmed in `TemporalDerived.lean:373`)
- [ ] Derive or locate the needed contrapositive lemma: `neg(phi U psi) ^ phi -> neg F(phi U psi)` (equivalently `G(neg(phi U psi))`). This follows from `until_unfold_thm` contrapositive: `neg(psi v (phi ^ (phi U psi))) -> neg(phi U psi)`, so `neg(phi U psi) -> neg psi ^ (neg phi v neg(phi U psi))`. Since `phi in MCS`, we get `neg(phi U psi) in MCS`, which after eliminating `neg phi` (contradicts `phi`) gives us a weaker statement. The stronger derivation: from `neg(phi U psi)` and `phi`, derive `neg psi` (by BX8 contrapositive) and need `neg F(phi U psi)`. Use BX10 contrapositive: `neg F(psi) -> neg(phi U psi)`. But we need the converse direction for `F(phi U psi)`, not `F(psi)`. Alternative: derive `neg(phi U psi) ^ phi -> neg F(phi U psi)` directly by noting that `F(phi U psi) ^ phi -> phi U psi` is not a BX theorem. Instead, work at the MCS level: if `neg(phi U psi) in MCS` and `phi in MCS`, then `neg psi in MCS` (BX8 contra). From `until_unfold_thm` applied to `phi U psi`: `phi U psi -> psi v (phi ^ (phi U psi))`. Contrapositive in MCS: `neg(psi v (phi ^ (phi U psi))) in MCS`, i.e., `neg psi ^ (neg phi v neg(phi U psi)) in MCS`. Since `phi in MCS`, `neg phi not in MCS`, so by MCS disjunction: `neg(phi U psi) in MCS` (we already knew this). This is circular. The KEY insight: we need `(phi U psi) -> psi v (phi ^ F(phi U psi))` (with F, not bare). Check if this is derivable from BX5 (self-accumulation) + BX10 (until_F).
- [ ] If the expansion with F is not directly available, create a new derived theorem: `until_F_expansion : (phi U psi) -> psi v (phi ^ F(phi U psi))`. Derivation: from `(phi U psi)`, by BX9 get `phi v psi`. Case `psi`: done. Case `phi`: have `phi ^ (phi U psi)`. By BX10: `F(psi)` from `(phi U psi)`. By BX5 (self_accum_until): `(phi U psi) -> ((phi ^ (phi U psi)) U psi)`. By BX10 on this: `F(psi)`. But we need `F(phi U psi)`, not `F(psi)`. Use BX4 (connect_future): `(phi U psi) -> G(P(phi U psi))`. This gives `P(phi U psi)` at all future times, but not `F(phi U psi)` at current time. Alternative approach: from `(phi U psi)`, by `until_unfold_wrapped`: `(bot U (psi v (phi ^ (phi U psi)))) in MCS`, which is the X-stepped version. Under reflexive semantics, `(bot U alpha) -> alpha` (by BX9: `bot v alpha`, and `bot` is impossible, so `alpha`). So `psi v (phi ^ (phi U psi)) in MCS`. This is what `until_unfold_thm` already gives (without the X/bot-U wrapper). The issue is getting F(phi U psi) rather than just (phi U psi) in the disjunct.
- [ ] **Fallback verification**: If the F-expansion form is not derivable, verify that the simpler argument works: `neg(phi U psi) in MCS` and `phi in MCS` implies (by exhaustive case analysis on `psi v neg psi`): Case `psi in MCS`: contradiction with `neg(phi U psi)` via BX8. Case `neg psi in MCS`: by BX11 (temp_linearity) or similar, derive that `neg(phi U psi)` persists. Specifically: from `neg(phi U psi) in chain(t)`, use the g_content approach. We need `G(neg(phi U psi)) in chain(t)`. This requires showing `neg(phi U psi) -> neg F(phi U psi)`. Under reflexive semantics, `F(phi U psi) -> phi U psi` (by BX1: `G(alpha) -> alpha`, so `neg(alpha) -> neg G(alpha) = F(neg alpha)` -- no, F and G have different directions). Actually under reflexive semantics with `F(alpha) = neg G(neg alpha)`: `G(neg(phi U psi)) -> neg(phi U psi)` by BX1. But we need the reverse: `neg(phi U psi) -> G(neg(phi U psi))`. This is NOT a BX theorem in general. So we DO need the expansion axiom with F.
- [ ] `lake build` to verify all ported theorems compile

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- Add ported F_top/P_top theorems (~20 lines)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- Potentially add `until_F_expansion` derived theorem (~15 lines)

**Verification**:
- `lake build` compiles with no new errors
- Ported theorems have no sorry
- Expansion-related derived theorem (if needed) has no sorry

---

### Phase 2: Modify Chain Seeds for Deferral Disjunctions [NOT STARTED]

**Goal**: Augment `fwd_succ` and `bwd_pred` in `CanonicalModel.lean` to include deferral disjunctions in their seeds, enabling restricted forward_F/backward_P to be proved. The key change: at resolving steps, the seed becomes `{psi} union g_content(M) union deferralDisjunctions(M)` (was `{psi} union g_content(M)`); at non-resolving steps, the seed becomes `g_content(M) union deferralDisjunctions(M)` (was `g_content(M) union f_carry(M)`).

**Tasks**:
- [ ] Define `augmented_resolving_seed M psi := {psi} union g_content(M) union deferralDisjunctions(M)` and prove it consistent (deferral disjunctions `chi v F(chi)` are in M when `F(chi) in M`, and `{psi} union g_content(M) subset M` at resolving steps, so augmented seed is a subset of M)
- [ ] Define `augmented_nonresolving_seed M := g_content(M) union deferralDisjunctions(M)` and prove it consistent (subset of M)
- [ ] Modify `fwd_succ` to use `augmented_resolving_seed` at resolving steps and `augmented_nonresolving_seed` at non-resolving steps
- [ ] Prove `fwd_succ_deferral`: for each `F(chi) in M` where `chi in deferralClosure(root)`, the successor MCS contains either `chi` (resolved) or `F(chi)` (deferred via `chi v F(chi)` in seed and Lindenbaum choosing one disjunct)
- [ ] Symmetrically modify `bwd_pred` using past deferral disjunctions and `h_content`
- [ ] Prove `bwd_pred_deferral`: symmetric property for `P(chi)` obligations
- [ ] Verify `fwd_succ_g_content`, `fwd_succ_resolves`, and `fwd_succ_f_carry` equivalents still hold (g_content inclusion follows from seed inclusion; resolves follows from `{psi}` still in seed; f_carry may be dropped in favor of deferral disjunctions)
- [ ] Verify `int_chain_forward_G`, `int_chain_backward_H`, and `box_stable_in_int_chain` still hold (these depend only on g_content/h_content inclusion, which is preserved)
- [ ] `lake build` to check compilation (sorry count should not increase)

**Timing**: 2.5 hours

**Depends on**: 1 (needs F_top for `successor_deferral_seed_consistent` if used directly, and needs the expansion theorem for later phases)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Modify `fwd_succ`, `bwd_pred`, add deferral properties (~120 lines changed/added)

**Verification**:
- `lake build` compiles (sorry count unchanged or decreased)
- `fwd_succ_deferral` and `bwd_pred_deferral` have no sorry
- Existing `int_chain_forward_G`, `int_chain_backward_H` still hold

---

### Phase 3: Prove Backward Until/Since Coherence via Contrapositive [NOT STARTED]

**Goal**: Close `bx_bfmcs_restricted_buc` (line 621) using the novel contrapositive argument from Research Report 05. This does NOT require chain modification -- it works with the existing `g_content` propagation.

**Tasks**:
- [ ] Implement the backward Until contrapositive proof: Given `psi in chain(r)`, `phi in chain(q)` for all `q in [t, r)`, prove `(phi U psi) in chain(t)`:
  1. By contradiction: assume `neg(phi U psi) in chain(t)` (MCS negation completeness)
  2. `phi in chain(t)` (given by guard at `q = t`)
  3. From `neg(phi U psi)` and `phi`, derive `G(neg(phi U psi)) in chain(t)` using the expansion axiom contrapositive from Phase 1
  4. By `int_chain_forward_G`: `neg(phi U psi) in chain(s)` for all `s >= t`, in particular `neg(phi U psi) in chain(r)`
  5. But `psi in chain(r)` and BX8 (`refl_intro_until`): `(phi U psi) in chain(r)`. Contradiction with `neg(phi U psi) in chain(r)`.
- [ ] Implement the backward Since contrapositive proof (symmetric, using `int_chain_backward_H` and BX8' `refl_intro_since`)
- [ ] Wire the proofs into `bx_bfmcs_restricted_buc`, handling the shifted family unpacking (`obtain ... := hfam`)
- [ ] `lake build` to verify the sorry at line 621 is closed

**Timing**: 2 hours

**Depends on**: 1 (needs the expansion axiom contrapositive from Phase 1)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Close `bx_bfmcs_restricted_buc` sorry (~40 lines)

**Verification**:
- `bx_bfmcs_restricted_buc` has no sorry
- `lake build` compiles

---

### Phase 4: Prove Restricted Temporal Coherence and Forward Until/Since Coherence [NOT STARTED]

**Goal**: Close `bx_bfmcs_restricted_tc` (lines 603-615) by proving restricted forward_F/backward_P directly using the deferral chain, and close `bx_bfmcs_restricted_fuc` (line 627) using restricted forward_F + the contrapositive guard argument.

**Tasks**:
- [ ] **Restricted forward_F**: Rewrite `bx_bfmcs_restricted_tc` to not delegate to unrestricted `bx_fmcs_forward_F`. Instead, prove directly: For `phi in deferralClosure(root)`, if `F(phi) in chain(t)`, then `phi in chain(s)` for some `s > t`. Proof: by `fwd_succ_deferral`, at each step the chain either resolves `phi` (done) or defers `F(phi)`. By `bounded_witness`, the F-nesting depth within `deferralClosure(root)` is finite, so infinite deferral is impossible. Use well-founded induction on `closure_F_bound(root) - current_nesting_depth`.
- [ ] **Restricted backward_P**: Symmetric argument for the past direction using `bwd_pred_deferral` and past bounded witness.
- [ ] Wire restricted forward_F/backward_P into `bx_bfmcs_restricted_tc`, handling the shifted family unpacking
- [ ] **Forward Until coherence**: Close `bx_bfmcs_restricted_fuc`. For `(phi U psi) in chain(t)`:
  1. By BX9 (`until_elim`): `phi v psi in chain(t)`
  2. Case `psi in chain(t)`: witness `s = t`, guard vacuous (reflexive semantics, `t <= t`). Done.
  3. Case `phi in chain(t)`, `neg psi in chain(t)`: By BX10 (`until_F`): `F(psi) in chain(t)`. By restricted forward_F (checking `psi in deferralClosure(root)` -- this follows from `(phi U psi) in subformulaClosure(root)` and closure properties): exists `s > t` with `psi in chain(s)`.
  4. Guard: need `phi in chain(q)` for all `q in [t, s)`. Use the contrapositive argument: if `neg phi in chain(q)` for some `q`, then by BX9 applied to `(phi U psi) in chain(q)` (which we need to show persists)... Actually, the guard follows from: at each `q in [t, s)`, either `(phi U psi) in chain(q)` (then BX9 gives `phi v psi`, and if `psi not in chain(q)` then `phi in chain(q)`) or `neg(phi U psi) in chain(q)`. The latter leads to contradiction via the contrapositive argument: `neg(phi U psi) ^ phi_at_t -> G(neg(phi U psi))` propagates to chain(s), contradicting `psi in chain(s)` + BX8. But this requires `(phi U psi) or neg(phi U psi)` at intermediate `q`, AND we need `phi in chain(q)` to apply the contrapositive... This is the inductive structure. Alternatively: prove `(phi U psi) in chain(q)` for all `q in [t, s)` by backward induction from `s-1` to `t`, using the contrapositive argument at each step.
  5. More precisely: prove by contradiction that `phi in chain(q)` for all `q in [t, s)`. Assume not, let `q0` be the first time in `[t, s)` where `neg phi in chain(q0)`. Then `phi in chain(q)` for `q in [t, q0)` and `psi not in chain(q)` for `q in [t, s)` (since `s` is the first witness). So `(phi U psi) in chain(t)` (given), and at `q0`: `neg phi in chain(q0)` and `neg psi in chain(q0)`. But what is `(phi U psi)` at `q0`? We cannot directly conclude. The proof requires a different approach. Use the full contrapositive: if `neg(phi U psi) in chain(q)` for any `q in [t, s)` with `phi in chain(q)`, derive contradiction. If `neg(phi U psi) in chain(q)` with `neg phi in chain(q)`, then `neg(phi U psi) in chain(q)` is possible. So we need `phi in chain(q)` at the point where `neg(phi U psi)` first appears. This requires forward propagation of `(phi U psi)` using a chain property. The correct approach: prove by strong induction that `(phi U psi) in chain(q)` for all `q in [t, s)`, using the expansion axiom and `g_content` propagation at each step.
- [ ] **Forward Since coherence**: Symmetric argument for `(phi S psi) in chain(t)` using backward_P and past-direction contrapositive.
- [ ] `lake build` to verify all sorry sites are closed

**Timing**: 2.5 hours

**Depends on**: 2 (needs deferral chain for restricted forward_F), 3 (needs contrapositive argument for forward Until guard)

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Rewrite `bx_bfmcs_restricted_tc`, close `bx_bfmcs_restricted_fuc` (~100 lines)

**Verification**:
- `bx_bfmcs_restricted_tc` has no sorry
- `bx_bfmcs_restricted_fuc` has no sorry
- `lake build` compiles with zero sorry on active path

---

### Phase 5: Cleanup and Final Verification [NOT STARTED]

**Goal**: Delete unrestricted dead code, verify the full build, and confirm axiom purity of `bx_completeness`.

**Tasks**:
- [ ] Mark or delete the unrestricted sorry-bearing theorems (`bx_fmcs_forward_F`, `bx_fmcs_backward_P`, `bx_bfmcs_buc`, `bx_bfmcs_fuc`, `bx_bfmcs_tc`) as they are now dead code not called by the active completeness path
- [ ] Delete or mark `f_carry`, `p_carry`, `enriched_seed_consistent`, `enriched_past_seed_consistent` if they are no longer used after deferral seed changes
- [ ] Run `lake build` and verify zero errors
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` and verify no matches on active path
- [ ] Add `#print axioms bx_completeness` check and verify output shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Run full `lake build` for regression testing

**Timing**: 0.5 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Remove dead code (~80 lines removed)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Add `#print axioms` check

**Verification**:
- `lake build` succeeds with zero errors
- `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no matches (or only in dead code clearly marked)
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

## Testing & Validation

- [ ] `lake build` completes with zero errors after each phase
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no active-path matches
- [ ] `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No regressions: full `lake build` succeeds for the entire project
- [ ] Ported F_top/P_top theorems are sorry-free
- [ ] The contrapositive backward Until argument compiles without sorry
- [ ] Restricted forward_F terminates via bounded_witness argument

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- Extended with F_top/P_top theorems (~20 lines added)
- `Theories/Bimodal/Theorems/TemporalDerived.lean` -- Potentially extended with `until_F_expansion` (~15 lines added)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Major changes (~250 lines modified): deferral seeds, restricted temporal coherence, backward/forward Until coherence, dead code cleanup
- `specs/093_complete_bxcanonical_embedding/summaries/05_bxcanonical-embedding-summary.md` -- Implementation summary (created after completion)

## Rollback/Contingency

- Phase 1 changes (F_top port) are additive and can be reverted independently.
- Phase 2 chain seed changes can be reverted with `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean`.
- If the contrapositive argument (Phase 3) fails due to the expansion axiom gap, fall back to enriching the chain seed with Until-deferral formulas and proving step transfer directly (~3 additional hours per Research Report 05 estimate).
- If restricted forward_F (Phase 4) proves harder than expected, the existing `bounded_witness` termination argument can be implemented inline using well-founded induction rather than calling the API directly.
- Dead code deletion (Phase 5) can be deferred without blocking the definition of done.
