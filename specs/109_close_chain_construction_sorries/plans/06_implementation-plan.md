# Implementation Plan: Close Chain Construction Sorries (v5)

- **Task**: 109 - Close chain construction sorries
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: Task 93 (irreflexive semantics switch, completed)
- **Research Inputs**: specs/109_close_chain_construction_sorries/reports/06_team-research.md
- **Artifacts**: plans/06_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 5 sorry sites in `RootScopedChain.lean` (lines 1134, 1161, 1168, 1176, 1183) that block sorry-free `bx_completeness`. Plan v4 pursued Path D (quasimodel run-composition with Realization.lean rearchitecture); research rounds 5-6 have invalidated that approach and identified a better one. This plan (v5) uses the **BX12 bridge** as the primary strategy: since BX12 gives `F(phi) -> (T U phi)`, F-eventuality reduces to Until-eventuality, which the sorry-free `bx_until_eventuality_resolution` infrastructure already handles. Sorry #4 (backward Until/Since coherence) is deferred to a follow-up task. Definition of done: `#print axioms bx_completeness` shows only `{propext, Classical.choice, Quot.sound}`, or 4 of 5 critical-path sorries closed with sorry #4 documented for follow-up.

### Research Integration

Team research report (06_team-research.md, 4 teammates + late-arriving deep analysis) established:
- `fwd_chain_forward_F` is UNPROVABLE for the current `preserving_fwd_step` chain without either redesigning the chain or reducing the problem to an already-solved one (universal agreement)
- BX12 bridge is the highest-priority path: `F(phi) -> (T U phi)` by BX12, then apply existing Until-eventuality machinery (Teammate D, confirmed by all)
- `active_defects` correction is WRONG under irreflexive semantics: `chi in M` and `F(chi) in M` coexist without contradiction (Teammate C)
- Realization.lean 4 sorry sites are DEAD CODE not on the critical path (confirmed by all)
- Constructive discharge with neg-F guard is FATALLY FLAWED: requires `F(phi and G(neg phi)) in M` not derivable from BX (Teammate B deep analysis)
- Extended discharge with explicit F-protection is the backup (Teammate B): seed `{phi} union {F(chi) | chi in active_defects, chi neq phi} union g_content(M)`, requires multi-formula seed consistency lemma (8-14 hours)
- Standard references (GHR 1994, Reynolds 1996) handle F-formulas exactly this way: reducing to Until within a finite Sigma closure

### Prior Plan Reference

Plan v4 (04_implementation-plan.md) estimated 18 hours across 7 phases (0-6). Key lessons learned:
- Phase 0 (active_defects correction) is WRONG per research round 6 -- must be dropped entirely
- Phase 1 (Realization.lean rearchitecture) targeted dead code -- must be dropped
- Phase 2 (run-composition layer) was the right instinct (bridge between canonical model and chain) but overengineered; the BX12 bridge is a much thinner bridge
- Phase 5 (forward Until/Since coherence) approach was sound and carries forward to this plan
- Effort calibration: v4 estimated 4 hours for the run-composition layer, which was optimistic; this plan allocates comparable effort for the BX12 bridge but with higher confidence due to research validation

### Roadmap Alignment

- Advances ROADMAP item: "Task 109: Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence)"
- Clears the `fwd_chain_forward_F -> restricted_tc -> restricted_buc -> restricted_fuc` dependency chain
- Prerequisite for Task 95: `#print axioms` audit on `bx_completeness`
- Directly advances the Representation Theorem goal

## Goals & Non-Goals

**Goals**:
- Close sorry #1 (`fwd_chain_forward_F`) via BX12 bridge reducing F-eventuality to Until-eventuality
- Close sorry #2 (F in backward chain region of `dd_bfmcs_restricted_tc`) via bridge to forward chain
- Close sorry #3 (backward P-resolution in `dd_bfmcs_restricted_tc`) via symmetric backward argument using `bx_backward_witness`
- Close sorry #5 (`dd_bfmcs_restricted_fuc`, forward Until/Since coherence) via BX10 + sorry #1 + Until guard persistence
- Achieve `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}` if sorry #4 is not on the critical path, or close sorry #4 if feasible within time budget

**Non-Goals**:
- Modifying the `active_defects` definition (confirmed WRONG under irreflexive semantics)
- Closing Realization.lean sorry sites (dead code, not on critical path)
- Closing non-critical-path sorries (Frame.lean `bx_le_refl`, TruthLemma backward_refl_mcs, SigmaOrdering reflexivity, Construction.lean `refl_intro_until/since_mcs`)
- Changing the BX axiom system
- Dense completeness (task 68) or FMP truth preservation (task 82)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| BX12 bridge blocked: `bx_until_eventuality_resolution` produces abstract BXPoints not chain indices | H | M | The bridge must show chain points ARE BXPoints in the canonical model; if this fails, pivot to extended discharge (Approach 5, backup) |
| `(T U phi)` not in `deferralClosure(root)`, blocking sigma_list membership precondition | H | M | Check if `deferralClosure` includes Until-formulas generated by BX12; if not, extend `sigma_list` or use direct BX axiom argument bypassing sigma_list |
| Backward chain F-resolution (sorry #2) requires infrastructure not yet built | M | M | Use `P(F(phi)) -> P(phi) v F(phi)` derivation to bridge backward F to forward F or direct P-witness |
| Sorry #4 (backward Until/Since) blocks `bx_completeness` and cannot be closed in time budget | H | H | Defer to follow-up task; document gap precisely. Check `#print axioms` to confirm it is actually on the critical path |
| Extended discharge backup (Approach 5) requires multi-formula seed consistency lemma that is too complex | M | L | Only relevant if BX12 bridge fails; the BX11 fold already builds such conjunctions, providing the required `F(phi and F(chi_1) and ... and F(chi_{k-1})) in M` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: BX12 Bridge for Sorry #1 (fwd_chain_forward_F) [NOT STARTED]

**Goal**: Close the keystone sorry at RootScopedChain.lean:1134 by reducing F-eventuality to Until-eventuality via BX12, then applying the sorry-free `bx_until_eventuality_resolution` infrastructure.

**Tasks**:
- [ ] Verify BX12 bridge preconditions: check that `F_imp_top_until_mcs` (CanonicalChain.lean:49) gives `F(phi) in chain(n) -> (T U phi) in chain(n)` at the MCS level
- [ ] Check whether `bx_until_eventuality_resolution` can be applied to `chain(n)` as a BXPoint. The chain produces `Set Formula` values via `fwd_chain_of_sigma`, which have `SetMaximalConsistent` proofs. Verify that a BXPoint can be constructed from `chain(n)`
- [ ] If direct application works: prove `fwd_chain_forward_F` by (1) BX12 to get `(T U phi) in chain(n)`, (2) apply `bx_until_eventuality_resolution` to get BXPoint `v` with `bx_le chain(n) v` and `phi in v`, (3) show `v` corresponds to some chain index `m > n`
- [ ] The step (3) bridge is the crux: `bx_le chain(n) v` means `g_content(chain(n)) subset v.formulas`. The chain has `g_content(chain(k)) subset chain(k+1)` (proved in `sigma_fwd_g_content_step`). Need to show that the abstract BXPoint `v` from `bx_forward_witness` either IS a chain point or can be related to one
- [ ] Alternative if direct bridging fails: instead of using `bx_until_eventuality_resolution` (which works over arbitrary BXPoints), construct a chain-local argument: `(T U phi) in chain(n)` means by BX10 `F(phi) in chain(n)` (circular!), so instead use `bx_forward_witness` directly on `chain(n)` as a BXPoint to get `v` with `phi in v` and `g_content(chain(n)) subset v`. Then show this `v` can be embedded into the chain by g_content transitivity
- [ ] If the bridge requires showing chain points are part of the canonical model's BXPoint space, build a `chain_as_bxpoint` coercion: `chain(n)` already has `SetMaximalConsistent`, so `BXPoint.mk chain(n).val chain(n).property` is immediate
- [ ] Use `lean_goal` extensively to track proof state at each step
- [ ] Run `lake build` after closing the sorry to verify

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close `fwd_chain_forward_F` at line 1134

**Verification**:
- `fwd_chain_forward_F` compiles without sorry
- `lean_verify` on `fwd_chain_forward_F` shows no sorry axiom
- `lake build` succeeds

---

### Phase 2: Close Sorry #2 (F in Backward Chain) and Forward Case Completion [NOT STARTED]

**Goal**: Close sorry #2 at RootScopedChain.lean:1161 -- the case where `F(phi) in chain(t)` with `t - s < 0` (i.e., `t` is in the backward chain region).

**Tasks**:
- [ ] Analyze the backward chain structure: `bwd_chain_of_sigma` iterates `bwd_pred`, which preserves `h_content` (not `g_content`). The backward chain has `h_content(chain(n)) subset chain(n+1)` via `sigma_bwd_h_content_step`
- [ ] Derive `P(F(phi)) -> P(phi) v F(phi)` at the MCS level. Strategy: BX4 gives `F(phi) -> G(P(F(phi)))`, and BX12 gives `F(phi) -> (T U phi)`. From `P(F(phi)) in M`, we know `F(phi)` held at some past point. Use BX11' (temp_linearity_past) to compare: either `F(phi) in M` directly, or `P(phi) in M` (giving a past witness via `bx_backward_witness`)
- [ ] Alternative approach for sorry #2: if `F(phi) in chain(t)` with `t` in backward region, show `F(phi)` propagates forward to the origin `chain(0) = M_0`. The backward chain preserves h_content, not g_content, so `F(phi) in chain(t)` does NOT directly propagate to `chain(0)`. Instead, use `BX4': phi -> H(F(phi))`: since `chain(0)` is reachable from `chain(t)` via the backward chain's h_content propagation, check if `F(phi)` can be shown to persist to the origin
- [ ] Build the connection: if `F(phi) in chain(t)` with `t < 0` in backward region, use the fact that `chain(0) = M_0` and the backward chain's g_content relationship. Key: `g_content(bwd_chain(k)) subset bwd_chain(k+1)` may NOT hold (backward chain preserves h_content). So we need a different route
- [ ] Most promising: construct a BXPoint from `chain(t)` (backward chain point), apply `bx_forward_witness` to get BXPoint `v` with `phi in v` and `bx_le chain(t) v`, then show `v` corresponds to some chain point `u > t` (possibly in the forward region)
- [ ] Use `lean_goal` to verify proof states at each step
- [ ] Run `lake build` after closing

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close the `sorry` at line 1161 in `dd_bfmcs_restricted_tc`

**Verification**:
- The backward-chain F-case in `dd_bfmcs_restricted_tc` compiles without sorry
- `lake build` succeeds

---

### Phase 3: Close Sorry #3 (Backward P-Resolution) [NOT STARTED]

**Goal**: Close sorry #3 at RootScopedChain.lean:1168 -- the backward direction `P(phi) in fam.mcs t -> exists u < t, phi in fam.mcs u`.

**Tasks**:
- [ ] Analyze the structure: this is symmetric to the forward F-resolution. `P(phi) in chain(t)` requires `phi` at some `u < t`
- [ ] Case split on `t - s >= 0` vs `t - s < 0`:
  - If `t` is in the backward region (`t - s < 0`): `P(phi) in bwd_chain(|t-s|)`. The backward chain preserves `h_content(chain(k)) subset chain(k+1)`. Use BX12' (`P(phi) -> (T S phi)`) + `bx_since_eventuality_resolution` (sorry-free) to get a BXPoint `v` with `bx_le v chain(t)` and `phi in v`. Bridge `v` to a chain index
  - If `t` is in the forward region (`t - s >= 0`): `P(phi) in fwd_chain(t-s)`. Need to find `u < t` with `phi in chain(u)`. Use `bx_backward_witness` on `chain(t)` as a BXPoint to get `v` with `bx_le v chain(t)` and `phi in v`. Bridge to chain index
- [ ] Build symmetric `bwd_chain_backward_P`: given `P(phi) in bwd_chain(n)`, find `m > n` with `phi in bwd_chain(m)`. This is the backward dual of `fwd_chain_forward_F`
- [ ] Use BX12' (`P_since_equiv`): `P(phi) -> (T S phi)`. Apply `bx_since_eventuality_resolution` to get backward witness. Bridge to chain index using the same technique as Phase 1
- [ ] Handle the cross-region case: `P(phi) in fwd_chain(k)` needs `phi` at some earlier time, possibly in the backward chain region or at the origin
- [ ] Use `lean_goal` at each step

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close the `sorry` at line 1168 in `dd_bfmcs_restricted_tc`

**Verification**:
- `dd_bfmcs_restricted_tc` compiles entirely without sorry
- `lean_verify` on `dd_bfmcs_restricted_tc` shows no sorry axiom
- `lake build` succeeds

---

### Phase 4: Close Sorry #5 (Forward Until/Since Coherence) [NOT STARTED]

**Goal**: Close sorry #5 at RootScopedChain.lean:1183 (`dd_bfmcs_restricted_fuc`) -- forward Until/Since coherence.

**Tasks**:
- [ ] Prove forward Until coherence: if `(phi U psi) in chain(t)`, then `exists s > t, psi in chain(s) AND forall r in (t,s), phi in chain(r)`
- [ ] Step 1: By BX10 (`until_F`), `F(psi) in chain(t)`. By Phase 1's `fwd_chain_forward_F` (or its generalization to dd_chain via `dd_bfmcs_restricted_tc`), exists `s > t` with `psi in chain(s)`
- [ ] Step 2: Choose minimal such `s`. Use `Nat.find` or well-ordering on the chain index set to get the first witness
- [ ] Step 3: Guard persistence. For `r` in `(t, s)`, show `phi in chain(r)`:
  - By BX5 (`self_accum_until`): `(phi U psi) in chain(t)` implies `((phi and (phi U psi)) U psi) in chain(t)`. This means `phi` AND `phi U psi` hold at all guard points
  - The Until formula itself persists before the witness: at any point `r` where `psi not-in chain(r)`, `phi U psi` must still hold (by BX9 `until_elim`: `phi U psi -> phi v psi`, and `psi not-in chain(r)` forces `phi in chain(r)`)
  - Need to show `phi U psi` persists through the chain from `t` to `s-1`. This follows from g_content propagation: `G(phi U psi) in chain(t)` is NOT guaranteed, but we can use the forward chain's structure
  - Alternative: use `BX5` to get `((phi and (phi U psi)) U psi)`, then by induction on chain steps: at each step before `s`, either `psi in chain(r)` (contradicting minimality of `s`) or `phi and (phi U psi) in chain(r)` (giving `phi in chain(r)` and continuing)
- [ ] Build helper lemma `until_guard_before_witness`: by strong induction on `s - r`, show `phi in chain(r)` for all `r in (t, s)` where `s` is the minimal psi-witness
- [ ] Close Since coherence symmetrically using BX5', BX9', BX10' and backward chain P-resolution from Phase 3
- [ ] Replace the sorry at line 1183

**Timing**: 2.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close `dd_bfmcs_restricted_fuc`

**Verification**:
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `lake build` succeeds

---

### Phase 5: Sorry #4 Assessment and Final Verification [NOT STARTED]

**Goal**: Determine if sorry #4 (`dd_bfmcs_restricted_buc`, backward Until/Since coherence) is on the critical path for `bx_completeness`. If yes, attempt closure. Run `#print axioms` audit.

**Tasks**:
- [ ] Run `lean_verify` on `bx_completeness` to check if `sorry` still appears after Phases 1-4
- [ ] Run `lean_verify` on `dd_countermodel` to identify which sorry sites remain
- [ ] If sorry #4 blocks `bx_completeness`:
  - Analyze `restricted_backward_until_since_coherent`: if `(phi U psi) in chain(t)`, need `exists s > t, psi in chain(s) AND forall r in (t,s), phi in chain(r)` for the BACKWARD direction (i.e., the coherence property looking at chains going backward in time)
  - This requires the Until step transfer: `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)`. This is blocked for Lindenbaum-based chains (dead end #36b)
  - If the step transfer is genuinely blocked: document precisely, create follow-up task, mark task 109 [PARTIAL]
  - Alternative: if backward Until/Since coherence can be reformulated using the BX12 bridge (reducing Until to F, then using temporal coherence from Phases 1-3), attempt this
- [ ] If sorry #4 does NOT block `bx_completeness` (i.e., `dd_countermodel` does not depend on `dd_bfmcs_restricted_buc`): proceed directly to axiom audit
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness` via `lean_run_code`
- [ ] Verify output is exactly `{propext, Classical.choice, Quot.sound}` or document remaining sorries
- [ ] Run full `lake build` to confirm no regressions
- [ ] Update sorry counts in code comments if applicable

**Timing**: 2 hours

**Depends on**: 1, 2, 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Possibly close `dd_bfmcs_restricted_buc`, update comments
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` - Verify axioms

**Verification**:
- `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}` (target)
- `lake build` succeeds with no sorry on the critical path
- All phase outcomes documented

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on each closed sorry confirms no sorry axiom leaks
- [ ] `#print axioms bx_completeness` checked at Phase 5
- [ ] Grep for `sorry` in `RootScopedChain.lean` shows monotonic decrease across phases
- [ ] Forward temporal coherence (`dd_bfmcs_restricted_tc`) is fully sorry-free after Phases 1-3
- [ ] Forward Until/Since coherence (`dd_bfmcs_restricted_fuc`) is sorry-free after Phase 4

## Artifacts & Outputs

- `specs/109_close_chain_construction_sorries/plans/06_implementation-plan.md` (this file)
- Modified source file: `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (primary)
- Potentially new follow-up task for sorry #4 if not closed
- Implementation summary upon completion

## Rollback/Contingency

- Each phase is independently committable; rollback to previous phase's commit if a phase fails
- **Phase 1 fallback (BACKUP: Extended Discharge, Approach 5)**: If the BX12 bridge cannot connect abstract BXPoint witnesses to chain indices, pivot to extended discharge: redesign `preserving_fwd_step` to use seed `{phi} union {F(chi) | chi in active_defects, chi neq phi} union g_content(M)`. This requires a multi-formula seed consistency lemma (the BX11 fold builds the necessary conjunctions). Estimated additional effort: 8-14 hours. The fallback is well-researched (Teammate B deep analysis) but significantly more work
- **Phase 2/3 fallback**: If backward chain F/P-resolution is too complex, use a weaker argument: show that any formula present at a backward chain point is also derivable from the root MCS (via h_content transitivity to the origin), then use the forward chain from the origin
- **Phase 4 fallback**: If Until guard persistence is blocked (BX5 self-accumulation does not persist through Lindenbaum steps), use a direct counting argument on the number of steps where `psi not-in chain(r)` combined with the BX12 bridge showing `phi U psi` at each such step
- **Phase 5 fallback**: If sorry #4 remains, mark task [PARTIAL] with 4 of 5 sorries closed and create a follow-up task specifically for backward Until/Since coherence
- If any phase stalls beyond 1.5x estimated time, create a handoff document and mark [PARTIAL] for next session
