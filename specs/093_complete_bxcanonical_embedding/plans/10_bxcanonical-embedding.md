# Implementation Plan: Close BXCanonical Embedding (v10 -- Closure Extension + BX12 Reduction)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: None (tasks 90, 92, 98, 102 already completed)
- **Research Inputs**: reports/10_team-research.md, reports/09_team-research.md, handoffs/08_analysis-handoff.md
- **Artifacts**: plans/10_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Plan v8 is DEAD: both its core mechanisms are refuted. Phase 2 (resolving seed consistency with untilCarry) fails due to a verified counterexample (`{psi, neg(alpha), (alpha U neg(psi))}` is inconsistent via BX9), and Phase 5 (BX12 reduction) fails because `(top U psi)` is not in `deferralClosure(root)`. This plan (v10) takes a fundamentally different approach based on research round 10's consensus recommendation: extend `deferralClosure` to include `(top U phi)` for every `F(phi)` target (Reynolds-style enrichment, ~20 lines), then reduce forward_F entirely to forward Until via BX12, and prove forward Until + backward Until + step transfer using a modified chain construction with Until/Since carry in the non-resolving seed (which is consistent because it is a subset of M). The resolving seed is NOT enriched with Until carry, avoiding the fatal counterexample. Instead, backward Until coherence is proved via a BX axiom argument using `connect_past` (BX4') and `F_until_equiv` (BX12). Definition of done: `lake build` succeeds with zero sorry on the active completeness path, and `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

Report 10 (team research, 4 teammates) provides the definitive analysis:

1. **Plan v8 has a "double fatality"**: Phase 2 (untilCarry consistency) is refuted by a concrete counterexample verified by 3 independent teammates. Phase 5 (BX12 reduction) is blocked by `(top U psi)` not being in closures. Both core mechanisms are broken.

2. **BX12 closure extension is the standard technique**: Reynolds 1996/2003 defines enriched closures that include `(top U phi)` for each `F(phi)` target. The codebase already has BX12 (`F(phi) -> (top U phi)`) as an axiom. Only the closure definitions need updating (~20 lines).

3. **Non-resolving seed enrichment with Until carry is safe**: `g_content(M) union f_carry(M) union untilCarry(M)` is a subset of M (since g_content subset M by BX1, f_carry subset M by definition, untilCarry subset M by definition), hence consistent. This avoids the counterexample which only applies to the resolving seed.

4. **Step transfer via BX4' + BX12**: For `(phi U psi) in chain(r+1)` and `phi in chain(r)`, derive `F(phi U psi) in chain(r)` via `connect_past` (BX4' gives `alpha -> H(F(alpha))`), then `(top U (phi U psi)) in chain(r)` via BX12, then `(phi U psi) in chain(r)` via `phi in chain(r)` and BX axiom reasoning. The key derivation: `phi and F(phi U psi) -> (phi U psi)` holds because `phi and (phi U psi) -> (phi U psi)` (BX-valid) and BX12 gives `F(phi U psi) -> (top U (phi U psi))`, so the Until witness transfers.

5. **Strict vs non-strict inequality resolved**: Forward_F needs `s > t` (strict), BX12 gives `s >= t` (non-strict). When `s = t`, `phi in fam.mcs(t)` directly, so `F(phi) in fam.mcs(t)` persists and the chain resolves `phi` at some `s' > t`.

### Prior Plan Reference

Plan v8 had 6 phases built around untilCarry in the resolving seed + BX12 reduction. Phase 1 was BLOCKED: the closure gap for BX12 was confirmed, and the resolving seed consistency (Phase 2) was refuted by a concrete counterexample. Key lessons: (a) never enrich the resolving seed with Until formulas -- the BX9 counterexample is definitive; (b) the scheduling chain's non-resolving seed CAN be enriched because it is a subset of M; (c) `deferralClosure` must be extended for BX12 to work; (d) step transfer requires a BX axiom argument, not chain structure alone. Effort calibration: v8 estimated 14 hours but was blocked at Phase 1; this plan estimates 16 hours to account for the closure extension engineering and the novel step-transfer proof.

### Roadmap Alignment

- Closes the sole remaining active-path sorry blocking `bx_completeness`
- Advances roadmap item: "TaskModel embedding (final step)" from OPEN to DONE
- Once complete, `completeness_over_Int` becomes sorry-free via BXCanonical
- Unblocks task 95 (`#print axioms` audit)

## Goals & Non-Goals

**Goals**:
- Extend `deferralClosure` to include `(top U phi)` for each `F(phi)` target (Reynolds enrichment)
- Verify downstream lemmas compile after closure extension
- Enrich the non-resolving seed of `fwd_succ`/`bwd_pred` with Until/Since carry (subset of M, hence consistent)
- Prove Until formulas persist forward through non-resolving chain steps
- Prove step transfer: `(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)` via BX4' + BX12 axiom argument
- Close `bx_bfmcs_restricted_tc` (restricted forward_F/backward_P) via BX12 reduction to forward Until
- Close `bx_bfmcs_restricted_buc` (backward Until/Since coherence) using `backward_until_from_step` with the step transfer proof
- Close `bx_bfmcs_restricted_fuc` (forward Until/Since coherence) using restricted forward_F + Until persistence
- Achieve `lake build` with zero active-path sorry
- Verify `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

**Non-Goals**:
- Proving unrestricted forward_F/backward_P (dead code at lines 497, 503)
- Closing unrestricted coherence (dead code at lines 586-591)
- Full quasimodel chain replacement (Architecture C)
- Dense time completeness (task 68)
- Modifying the resolving seed (explicitly avoided due to counterexample)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Closure extension breaks downstream lemmas (chain seed must stay in closure) | H | M (30%) | Run `lake build` immediately after closure extension. The extension is purely additive, so existing membership proofs should hold. If breakage occurs, trace specific lemma and fix. |
| Step transfer BX derivation is unprovable (`phi and F(phi U psi) -> (phi U psi)`) | H | M (35%) | This is the critical novel proof. Fallback 1: use BX5 self-accumulation + BX6 absorption to derive the step. Fallback 2: prove step transfer from the chain structure directly (non-resolving seed includes Until carry, so `(phi U psi) in chain(r)` when `(phi U psi) in chain(r+1)` and the step is non-resolving for other formulas). |
| Until carry in non-resolving seed interacts badly with f_carry or g_content | M | L (15%) | The seed `g_content(M) union f_carry(M) union untilCarry(M)` is provably subset of M. No interaction issues since subset consistency is unconditional. |
| BX12 strict inequality gap is harder than expected | M | M (25%) | When `(top U phi) in chain(t)` gives witness at `s = t`, we have `phi in chain(t)` directly. Need to show `F(phi) in chain(t)` and find `s' > t` via schedule resolution. The schedule surjectivity (`schedule_surjective_above`) guarantees eventual resolution. |
| Root parameterization of chain construction cascading changes | M | L (20%) | The root parameter only affects seed composition, not the chain mechanics. Downstream lemmas (g_content propagation, box stability) depend only on `g_content subset seed`, which is preserved. |
| Forward Until proof complexity exceeds estimate | M | M (30%) | Forward Until uses: BX9 for current-time case, BX10 for F-extraction, restricted forward_F for witness, Until persistence for guard. Each step is well-understood. If guard argument is difficult, use `UntilSinceCoherence` parameterized infrastructure. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Extend Deferral Closure with Reynolds Enrichment [BLOCKED]

**Goal**: Add `(top U phi)` to `deferralClosure(root)` for every `F(phi)` that appears as a deferral target, enabling the BX12 reduction `F(phi) -> (top U phi)` to land within the closure. Also add `(top S phi)` symmetrically for `P(phi)`.

**Tasks**:
- [ ] In `SubformulaClosure.lean`, define `untilEnrichmentSet (phi : Formula) : Finset Formula` containing `Formula.untl Formula.top chi` for each `F(chi)` in `deferralDisjunctionSet(phi)` or `closureWithNeg(phi)`, and symmetrically `Formula.snce Formula.top chi` for each `P(chi)`
- [ ] Modify `deferralClosure` (or create an enriched variant `enrichedDeferralClosure`) to include `untilEnrichmentSet phi`
- [ ] If modifying `deferralClosure` directly, update `baseDeferralClosure` and verify `baseDeferralClosure_eq_deferralClosure` still holds or adjust
- [ ] Prove `until_enrichment_mem`: if `F(chi) in deferralClosure(root)` then `(top U chi) in deferralClosure(root)` (key lemma for BX12 reduction)
- [ ] Prove symmetric `since_enrichment_mem`: if `P(chi) in deferralClosure(root)` then `(top S chi) in deferralClosure(root)`
- [ ] Verify `subformulaClosure` membership: `(top U psi) in subformulaClosure(root)` when `(phi U psi) in subformulaClosure(root)` -- check if this holds or if enrichment is needed there too
- [ ] Run `lake build` to verify all downstream modules compile (CanonicalModel.lean, Completeness.lean, RestrictedParametricTruthLemma.lean, etc.)

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Syntax/SubformulaClosure.lean` -- New definitions (~40 lines): `untilEnrichmentSet`, modified `deferralClosure`
- Possibly `Theories/Bimodal/Metalogic/Algebraic/RestrictedParametricTruthLemma.lean` -- If closure changes affect truth lemma hypotheses

**Verification**:
- `until_enrichment_mem` compiles without sorry
- `lake build` passes (downstream modules still compile)
- The enrichment is finite (Finset operations)

---

### Phase 2: Enrich Non-Resolving Seed with Until/Since Carry [NOT STARTED]

**Goal**: Modify `fwd_succ` and `bwd_pred` to include Until/Since carry in the non-resolving seed. This is safe because the enriched seed remains a subset of M. The resolving seed is NOT modified (avoiding the counterexample). Propagate any necessary root parameter through the chain construction.

**Tasks**:
- [ ] Define `until_carry (M : Set Formula) : Set Formula := {phi in M | exists a b, phi = Formula.untl a b}` in `CanonicalModel.lean`
- [ ] Define `since_carry (M : Set Formula) : Set Formula := {phi in M | exists a b, phi = Formula.snce a b}` symmetrically
- [ ] Prove `until_carry_subset : until_carry M subset M` and `since_carry_subset`
- [ ] Modify the non-resolving branch of `fwd_succ`: change seed from `g_content M union f_carry M` to `g_content M union f_carry M union until_carry M`
- [ ] Prove `enriched_seed_with_until_consistent`: `g_content M union f_carry M union until_carry M` is consistent (subset of M, since g_content subset M by BX1 T-axiom, f_carry subset M, until_carry subset M)
- [ ] Modify the non-resolving branch of `bwd_pred` symmetrically: add `since_carry M`
- [ ] Prove `enriched_past_seed_with_since_consistent` symmetrically
- [ ] Re-prove `fwd_succ_mcs`, `fwd_succ_g_content`, `fwd_succ_resolves`, `fwd_succ_f_carry` for modified seeds (straightforward -- seed is enlarged, old inclusions hold)
- [ ] Prove new lemma `fwd_succ_until_carry`: `until_carry M subset fwd_succ M h_mcs psi` when `F(psi) not in M` (non-resolving branch)
- [ ] Prove `bwd_pred_since_carry` symmetrically
- [ ] Verify `int_chain_forward_G`, `int_chain_backward_H`, `box_stable_in_int_chain` still hold (these depend only on g_content inclusion, which is unchanged)
- [ ] Run `lake build` -- critical build check

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Modify seed definitions and re-prove existing lemmas (~100 lines changed, ~40 lines new)

**Verification**:
- `fwd_succ_until_carry` compiles without sorry
- All existing G/H propagation and box stability lemmas compile unchanged
- `lake build` passes

---

### Phase 3: Prove Until Persistence and Step Transfer [NOT STARTED]

**Goal**: Prove that Until formulas persist forward through non-resolving chain steps, and derive step transfer via BX4' + BX12 axiom argument. This is the critical novel proof.

**Tasks**:
- [ ] Prove `until_persists_nonresolving`: for `(phi U psi) in chain(n)` and the step at `n` is non-resolving for `schedule(n)` (i.e., `F(schedule(n)) not in chain(n)`), then `(phi U psi) in chain(n+1)`. Proof: `(phi U psi) in until_carry(chain(n))`, which is in the non-resolving seed, hence in `chain(n+1)` by `fwd_succ_until_carry`.
- [ ] Prove the BX-derived step transfer lemma: `phi_and_F_until_imp_until`: `|- (phi and F(phi U psi)) -> (phi U psi)`. Derivation path:
  1. BX12: `F(phi U psi) -> (top U (phi U psi))`
  2. BX9 on `(top U (phi U psi))`: `top v (phi U psi)`, so `(phi U psi)` holds at current time OR `top` holds and `(phi U psi)` holds later
  3. More precisely: from `(top U (phi U psi))` get a witness s >= t with `(phi U psi) at s` and `top` on guard. Combined with `phi at t`: use BX8 + BX5 reasoning. Actually: `(top U (phi U psi)) at t` means exists s >= t with `(phi U psi) at s`. If s = t, done. If s > t, `phi at t` and `(phi U psi)` at s gives `(phi U psi) at t` by self-accumulation semantics.
  4. Formal derivation: `phi and (top U (phi U psi)) -> (phi U psi)`. Use BX left-strengthening: `G(top -> phi) -> ((top U (phi U psi)) -> (phi U (phi U psi)))` (BX2). Since `top -> phi` when `phi` is given, this gives `(phi U (phi U psi))`. Then BX6 absorption: `(phi U (phi and (phi U psi))) -> (phi U psi)`. The path needs careful BX axiom composition.
  5. Alternative simpler path: from `phi at t` and `F(phi U psi) at t`, derive `(phi U psi) at t` directly. Since `F(phi U psi)` means exists `s > t` with `(phi U psi) at s`. By BX9 on that: `phi v psi` at s. The guard [t, s) has `phi` at t. Use backward Until: witness at s, guard on [t, s). This gives `(phi U psi) at t`.
- [ ] If the BX derivation is too complex, use the chain structure alternative: at a non-resolving step, `(phi U psi)` persists by until_carry. At a resolving step for `schedule(n)`, if `schedule(n) = psi_target` and `F(psi_target) in chain(n)`, then `psi_target in chain(n+1)`. But `(phi U psi)` with `phi != psi_target` is NOT in the resolving seed. Need: show that the Lindenbaum extension MAY include `(phi U psi)`. This is not guaranteed. So the BX derivation path is essential.
- [ ] Prove `step_transfer_until`: for the scheduling chain over Int, `(phi U psi) in chain(r+1) and phi in chain(r) -> (phi U psi) in chain(r)`. Proof outline:
  1. `(phi U psi) in chain(r+1)` means `(phi U psi)` was produced by the seed or Lindenbaum
  2. By `connect_past` (BX4'): if `alpha in chain(r+1)`, then `H(F(alpha)) in chain(r+1)`, so `F(alpha) in chain(r)` by h_content propagation (since h_content(chain(r+1)) subset chain(r) for the backward direction)
  3. Wait -- h_content goes backward in the chain. For forward chain: h_content(chain(n+1)) subset chain(n)? No. g_content(chain(n)) subset chain(n+1) (forward). h_content(chain(n+1)) subset chain(n) follows from the duality (proved as `fwd_chain_reverse_h`).
  4. So: `(phi U psi) in chain(r+1)` -> `H(F(phi U psi)) in chain(r+1)` by BX4' -> `F(phi U psi) in chain(r)` by h_content reverse.
  5. Then `phi in chain(r)` and `F(phi U psi) in chain(r)`: apply `phi_and_F_until_imp_until` to get `(phi U psi) in chain(r)`.
- [ ] Prove `step_transfer_since` symmetrically
- [ ] Run `lake build`

**Timing**: 4 hours (hard cutoff at 6 hours; if the BX derivation does not close, document the gap and evaluate fallback)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Until persistence, step transfer (~120-180 lines)
- Possibly `Theories/Bimodal/Theorems/TemporalDerived.lean` -- New BX derivation `phi_and_F_until_imp_until` (~40-60 lines)

**Verification**:
- `step_transfer_until` compiles without sorry
- `step_transfer_since` compiles without sorry
- `lake build` passes

---

### Phase 4: Close Restricted Coherence Sorry Sites [NOT STARTED]

**Goal**: Close all 3 active-path sorry sites using the infrastructure from Phases 1-3.

**Tasks**:
- [ ] **Restricted forward_F** (part of `bx_bfmcs_restricted_tc`, line 603):
  - Rewrite the proof to NOT delegate to unrestricted `bx_fmcs_forward_F` (fixing the architectural blind spot from Report 09)
  - Proof: `F(psi) in chain(t)` and `psi in deferralClosure(root)`. By Phase 1: `(top U psi) in deferralClosure(root)`. By BX12: `(top U psi) in chain(t)`. By forward Until coherence (proved below or simultaneously): exists `s >= t` with `psi in chain(s)` and `top` on guard. If `s = t`, done (but need `s > t`). If `s > t`, done. For the `s = t` case: `psi in chain(t)` directly, so `F(psi)` resolved at `t`. But the obligation is `exists s > t, psi in chain(s)`. If `psi in chain(t)`, then `F(psi) in chain(t)` (since `F(psi)` was already there). The schedule eventually targets `psi`: exists `n > t` with `schedule(n) = psi`. If `F(psi) in chain(n)`, then `psi in chain(n+1)`, giving `s = n+1 > t`. F(psi) persistence through non-resolving steps (via f_carry in the non-resolving seed) ensures F(psi) survives until the resolving step.
  - Implement using well-founded induction on the schedule or direct bounded argument
- [ ] **Restricted backward_P** (part of `bx_bfmcs_restricted_tc`):
  - Symmetric to forward_F using Since/P direction
- [ ] **Restricted backward Until** (`bx_bfmcs_restricted_buc`, line 621):
  - Until conjunct: Use `backward_until_from_step` from `UntilSinceCoherence.lean` with `step_transfer_until` from Phase 3.
  - The API matches: `step_transfer_until` provides `(phi U psi) in fam.mcs(r+1) and phi in fam.mcs(r) -> (phi U psi) in fam.mcs(r)`, which is exactly what `backward_until_from_step` requires.
  - Since conjunct: Use `backward_since_from_step` with `step_transfer_since`.
- [ ] **Restricted forward Until** (`bx_bfmcs_restricted_fuc`, line 627):
  - Given `(phi U psi) in chain(t)` with `(phi U psi) in subformulaClosure(root)`:
    1. By BX9: `phi v psi in chain(t)`
    2. Case `psi in chain(t)`: witness s = t, guard vacuous. Done.
    3. Case `phi in chain(t)`: By BX10: `F(psi) in chain(t)`. By restricted forward_F (proved above): exists `s > t` with `psi in chain(s)`. Take minimal such s. For guard: at each q in [t, s), `(phi U psi) in chain(q)` by Until persistence (from Phase 3 -- until_carry ensures persistence through non-resolving steps; at resolving steps, use step transfer backward from chain(q+1)). Then BX9 gives `phi v psi in chain(q)`. Since q < s (minimal), `psi not in chain(q)`, hence `phi in chain(q)`.
  - Since conjunct: Symmetric.
- [ ] Run `lake build` to verify all 3 restricted sorry sites are closed

**Timing**: 5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Close 3 sorry sites (~200-300 lines of proof)

**Verification**:
- `bx_bfmcs_restricted_tc` has no sorry
- `bx_bfmcs_restricted_buc` has no sorry
- `bx_bfmcs_restricted_fuc` has no sorry
- `lake build` passes with zero sorry on active path

---

### Phase 5: Cleanup and Final Verification [NOT STARTED]

**Goal**: Clean up dead code, verify the full build, and confirm axiom purity.

**Tasks**:
- [ ] Mark the unrestricted sorry-bearing theorems (`bx_fmcs_forward_F` at line 497, `bx_fmcs_backward_P` at line 503, `bx_bfmcs_buc`/`bx_bfmcs_fuc`/`bx_bfmcs_tc` at lines 570-591) with comments indicating they are dead code not on the active completeness path
- [ ] Delete or comment out `bx_bfmcs_tc`, `bx_bfmcs_buc`, `bx_bfmcs_fuc` (unrestricted versions) if they are truly unused -- check references first with grep
- [ ] Run `lake build` and verify zero errors
- [ ] Run `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` and verify no sorry on active path (the only remaining sorries should be in dead code, if any)
- [ ] Add `#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness` and verify output shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Run full `lake build` for regression testing
- [ ] If unrestricted sorry sites are still present as dead code, add `-- DEAD CODE: not on active completeness path` annotations

**Timing**: 2 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Dead code annotations/removal (~50 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Add `#print axioms` verification

**Verification**:
- `lake build` succeeds with zero errors
- `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns only dead-code sorry or no matches
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

## Testing & Validation

- [ ] `lake build` completes with zero errors after each phase
- [ ] Phase 1: `until_enrichment_mem` and `since_enrichment_mem` compile without sorry
- [ ] Phase 2: `fwd_succ_until_carry` compiles without sorry; all existing chain lemmas still compile
- [ ] Phase 3: `step_transfer_until` and `step_transfer_since` compile without sorry (GO/NO-GO decision point -- if step transfer fails after 6 hours, document and evaluate fallback)
- [ ] Phase 4: All 3 restricted sorry sites (`bx_bfmcs_restricted_tc`, `bx_bfmcs_restricted_buc`, `bx_bfmcs_restricted_fuc`) have no sorry
- [ ] `grep -r "sorry" Theories/Bimodal/Metalogic/BXCanonical/` returns no active-path matches
- [ ] `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`

## Artifacts & Outputs

- `Theories/Bimodal/Syntax/SubformulaClosure.lean` -- Closure extension (~40 lines): `untilEnrichmentSet`, modified `deferralClosure`
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` -- Major changes (~400-500 lines): Until/Since carry definitions, modified seeds, persistence proofs, step transfer, restricted coherence proofs, dead code cleanup
- Possibly `Theories/Bimodal/Theorems/TemporalDerived.lean` -- New BX derivation (~40-60 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- Add `#print axioms` verification
- `specs/093_complete_bxcanonical_embedding/summaries/10_bxcanonical-embedding-summary.md` -- Implementation summary (created after completion)

## Rollback/Contingency

**Phase 1 breakage (closure extension cascading failures)**:
- If modifying `deferralClosure` breaks downstream, create `enrichedDeferralClosure` as a separate definition and modify only `restricted_temporally_coherent` to use it. This isolates the change from existing infrastructure.
- Git revert of `SubformulaClosure.lean` is straightforward.

**Phase 3 failure (step transfer unprovable)**:
- If `phi_and_F_until_imp_until` cannot be derived from BX axioms within 6 hours:
  - **Fallback A**: Use the chain structure directly. At non-resolving steps, Until persists via until_carry. At resolving steps for `schedule(n)`, if `(phi U psi)` is in `chain(n)` and the step resolves `schedule(n)`, then `(phi U psi)` may or may not be in chain(n+1). If it IS (by Lindenbaum), step transfer works. If not, use BX axiom reasoning to show it must be (from g_content + BX1 + BX5 self-accumulation).
  - **Fallback B**: Switch to root-parameterized chain (Teammate B's approach from Report 10). Modify chain construction with finite round-robin schedule over `deferralClosure(root)`, ensuring all formulas in the restricted set are resolved. Estimated +8 hours.
  - Document the exact failure point for future research.

**Phase 4 failure (forward Until guard argument)**:
- The guard argument for forward Until (showing `phi in chain(q)` for all `q in [t, s)`) requires Until persistence through ALL chain steps, not just non-resolving ones. If persistence through resolving steps is not achievable, use the `UntilSinceCoherence` module's parameterized approach with a modified step hypothesis.

**General rollback**:
- All Phase 1 changes are in `SubformulaClosure.lean`. All Phase 2-5 changes are in `CanonicalModel.lean` (and possibly `TemporalDerived.lean`). Git revert is straightforward.
- Dead code deletion (Phase 5) can be deferred indefinitely without blocking the definition of done.
