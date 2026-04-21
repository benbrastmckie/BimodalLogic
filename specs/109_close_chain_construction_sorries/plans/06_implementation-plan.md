# Implementation Plan: Close Chain Construction Sorries (v6)

- **Task**: 109 - Close chain construction sorries
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: Task 93 (irreflexive semantics switch, completed)
- **Research Inputs**: specs/109_close_chain_construction_sorries/reports/06_team-research.md, specs/109_close_chain_construction_sorries/handoffs/01_chain-redesign-handoff.md
- **Artifacts**: plans/06_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 5 sorry sites in `RootScopedChain.lean` (lines 1134, 1161, 1168, 1176, 1183) that block sorry-free `bx_completeness`. Plan v5 pursued the BX12 bridge as primary strategy and extended discharge as backup; implementation confirmed BOTH are blocked (BXPoints cannot be mapped to chain indices; extended discharge seed is inconsistent). This plan (v6) redesigns the chain construction itself: replace `preserving_fwd_step` with a **hybrid step** that uses `discharge_single_step` at round-robin target slots and `preserving_fwd_step` elsewhere. The BX11 case analysis proves `discharge_single_step` ALWAYS resolves the target formula. Definition of done: `#print axioms bx_completeness` shows only `{propext, Classical.choice, Quot.sound}`, or 4 of 5 critical-path sorries closed with sorry #4 documented for follow-up.

### Research Integration

- Team research report (06_team-research.md): Established `fwd_chain_forward_F` is unprovable for the current chain; identified BX12 bridge and extended discharge as candidates
- Chain redesign handoff (01_chain-redesign-handoff.md): Confirmed BX12 bridge and extended discharge are BOTH blocked; identified the hybrid chain construction as the viable path forward; provided BX11 case analysis proving `discharge_single_step` always resolves the target

### Prior Plan Reference

Plan v5 (this file, previous version) estimated 14 hours across 5 phases. Key lessons learned:
- Phase 1 (BX12 bridge) is BLOCKED: abstract BXPoints cannot be mapped to chain indices
- Extended discharge backup is BLOCKED: seed inconsistency when `G(phi -> G(neg chi_i)) in M`
- The core mathematical insight from v5's implementation attempt: BX11 on F(phi) with F(G(neg phi)) yields only two feasible cases, both guaranteeing phi in M'. Case 3 is impossible.
- This insight validates `discharge_single_step` as the correct primitive for guaranteed target resolution

### Roadmap Alignment

- Advances ROADMAP item: "Task 109: Close 23 BXCanonical sorries (5 critical-path + 18 irreflexive-consequence)"
- Clears the `fwd_chain_forward_F -> restricted_tc -> restricted_buc -> restricted_fuc` dependency chain
- Prerequisite for Task 95: `#print axioms` audit on `bx_completeness`
- Directly advances the Representation Theorem goal

## Goals & Non-Goals

**Goals**:
- Redesign forward chain construction to use hybrid preserving/discharge steps with round-robin scheduling
- Close sorry #1 (`fwd_chain_forward_F`) via the round-robin discharge argument
- Close sorry #2 (F in backward chain region of `dd_bfmcs_restricted_tc`) via symmetric backward hybrid chain
- Close sorry #3 (backward P-resolution in `dd_bfmcs_restricted_tc`) via backward hybrid chain
- Close sorry #5 (`dd_bfmcs_restricted_fuc`, forward Until/Since coherence) via Phase 2's `fwd_chain_forward_F` + Until guard persistence
- Achieve `#print axioms bx_completeness` = `{propext, Classical.choice, Quot.sound}` if sorry #4 is not on the critical path, or close sorry #4 if feasible within time budget

**Non-Goals**:
- Modifying the `active_defects` definition (confirmed wrong under irreflexive semantics in v5 research)
- Closing Realization.lean sorry sites (dead code, not on critical path)
- Closing non-critical-path sorries (Frame.lean `bx_le_refl`, TruthLemma backward_refl_mcs, SigmaOrdering reflexivity, Construction.lean `refl_intro_until/since_mcs`)
- Changing the BX axiom system
- Dense completeness (task 68) or FMP truth preservation (task 82)
- Keeping the old `fwd_chain_of_sigma` / `preserving_fwd_step` chain (it will be replaced)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F-obligation destruction at discharge steps for non-target formulas: when `discharge_single_step` fires for target psi, F(phi) for other phi may be lost | H | H | This is the CRITICAL gap. Two strategies: (A) prove that `discharge_single_step` preserves F(phi) when phi is not the target (may follow from g_content propagation), or (B) accept F-obligation loss and prove re-acquisition within one round-robin cycle via BX4 (`F(phi) -> G(P(F(phi)))`) implying F(phi) reappears. Phase 1 must resolve this before proceeding. |
| `discharge_single_step` not available or has wrong signature for direct use in chain | M | L | Inspect `CanonicalModel.lean` for exact signature; wrap if needed. The handoff confirms this primitive exists and works. |
| Round-robin scheduling requires chain length to be a multiple of `sigma_list.length`, breaking existing infrastructure | M | M | Use modular arithmetic (`n % len`) for round-robin index. Chain length is already omega (Nat-indexed). No length constraint needed. |
| Backward chain has different structure (h_content vs g_content), making symmetric argument harder | M | M | Phase 3 analyzes backward chain separately. If symmetric argument fails, use bridge through origin: backward chain point -> origin -> forward chain. |
| Sorry #4 (backward Until/Since coherence) on critical path and cannot be closed | H | H | Same mitigation as v5: defer to follow-up task, mark [PARTIAL]. The hybrid chain may actually make this easier since backward chain now also resolves P-obligations. |
| Large refactor scope causes regressions in existing sorry-free proofs | M | M | Build incrementally: define new chain alongside old one, prove properties, then swap references. Run `lake build` after each sub-step. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 2 |
| 5 | 5 | 3, 4 |

---

### Phase 1: Hybrid Forward Chain Construction [NOT STARTED]

**Goal**: Replace `fwd_chain_of_sigma` with a hybrid chain that uses `discharge_single_step` at round-robin target slots and `preserving_fwd_step` elsewhere. Prove g_content propagation and F-obligation behavior.

**Tasks**:
- [ ] Inspect current chain infrastructure: read `fwd_chain_of_sigma`, `preserving_fwd_step`, `defect_step_choice_early`, `discharge_single_step` signatures and properties in `RootScopedChain.lean` and `CanonicalModel.lean`
- [ ] Define `hybrid_fwd_step`: given chain point M, sigma_list, and step index n, dispatch:
  - If `n % sigma_list.length == target_index` AND `F(target) in M`: use `discharge_single_step` with target
  - Otherwise: use `preserving_fwd_step` (existing behavior)
- [ ] Define `hybrid_fwd_chain_of_sigma`: iterate `hybrid_fwd_step` from M0, producing the new forward chain
- [ ] Prove `hybrid_fwd_g_content_step`: `g_content(chain(n)) subset chain(n+1)` for the hybrid chain. For preserving steps this follows from existing `sigma_fwd_g_content_step`. For discharge steps, `discharge_single_step` uses seed `{target} union g_content(M)`, so g_content(M) subset Lindenbaum extension is immediate
- [ ] CRITICAL: Resolve the F-obligation destruction problem. Analyze what happens to F(phi) at a discharge step for a DIFFERENT target psi:
  - Inspect `discharge_single_step`'s seed: `{psi} union g_content(M)`. Since `F(phi) in M` implies `G(F(phi)) in M` or `G(F(phi)) not-in M`:
    - If `G(F(phi)) in M`: then `F(phi) in g_content(M)` subset seed, so `F(phi) in M'` by Lindenbaum extension. PRESERVED.
    - If `G(F(phi)) not-in M`: F(phi) may be lost. But `neg G(F(phi)) in M` means `F(neg F(phi)) in M` means `F(G(neg phi)) in M`. So phi will eventually be falsified. But we need phi RESOLVED, not falsified.
  - Strategy A: Show that for the round-robin to work, we only need F(phi) to persist until phi's own discharge slot. Between two consecutive phi-slots (at most `len` steps apart), count how many discharge-for-others steps occur. At each such step, either F(phi) survives (G(F(phi)) in M case) or F(phi) is lost but phi was already resolved at that step (check if discharge_single_step for psi also resolves phi).
  - Strategy B (fallback): If F-obligations CAN be lost, use a different chain: ALL steps use `preserving_fwd_step`, but at phi's round-robin slot, ALSO apply `discharge_single_step` as a separate reasoning step (not in the chain, but as a proof argument). Show: if F(phi) persists to slot, discharge resolves it; if F(phi) is lost before slot, then phi was resolved at the step where it was lost (by MCS: neg F(phi) in M' means either phi was already seen, or G(neg phi) in M').
  - Strategy C (simplest): Keep `preserving_fwd_step` for ALL chain steps (no change to chain construction). Instead, prove `fwd_chain_forward_F` by showing the defect count MUST decrease. Use the BX11 case analysis: at each step, the BX11 fold's witness resolution combined with the Case 1/Case 2 analysis guarantees that within at most `len` steps, at least one defect is permanently resolved (Case 1 kills F(phi)). Since there are finitely many defects, all are eventually resolved.
- [ ] Choose the winning strategy based on analysis. If Strategy C works, no chain redesign is needed (major simplification).
- [ ] Prove `hybrid_fwd_F_obligation_step` (or equivalent for chosen strategy): the key lemma about F-obligation behavior at each step type
- [ ] Run `lake build` to verify the new chain compiles

**Timing**: 6 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - New hybrid chain or modified proof strategy
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` - Possibly new lemmas about `discharge_single_step`

**Verification**:
- New chain (or modified proof strategy) compiles without sorry
- g_content propagation lemma proved
- F-obligation behavior lemma proved
- `lake build` succeeds

---

### Phase 2: Close Sorry #1 (fwd_chain_forward_F) [NOT STARTED]

**Goal**: Using the hybrid chain from Phase 1, prove `fwd_chain_forward_F`: given `F(phi) in chain(n)`, there exists `m > n` with `phi in chain(m)`.

**Tasks**:
- [ ] Structure the proof based on Phase 1's chosen strategy:
  - **If hybrid chain (Strategy A/B)**: F(phi) persists through preserving steps (by `fwd_chain_F_obligation_monotone` or its hybrid analogue). Within at most `len` steps, phi's round-robin slot arrives. At phi's slot, `discharge_single_step` guarantees `phi in chain(slot)`. Handle early exit: if phi is resolved at a preserving step before the slot, done immediately.
  - **If defect-count strategy (Strategy C)**: Show the defect set `D(k) = sigma_list.filter(chi => F(chi) in chain(k))` strictly decreases within bounded intervals. BX11 Case 1 produces `F(phi and G(neg phi))` seed which yields `phi in M'` AND `G(neg phi) in M'`, so `F(phi) not-in M'` (since `G(neg phi)` and `F(phi)` are contradictory under irreflexive semantics). Therefore BX11 Case 1 PERMANENTLY removes phi from D. Since |D| is finite and bounded by |sigma_list|, after at most |sigma_list| * len steps, D = empty, meaning all F-obligations resolved.
- [ ] Handle the `G(F(phi)) in M` case separately: if `G(F(phi)) in chain(n)`, then `F(phi) in g_content(chain(n))`, so `F(phi) in chain(n+1)`, and the obligation persists. But `G(F(phi)) in M` and M is MCS, so by BX4 inverse, `F(phi)` holds at all future times. We need phi to APPEAR, not just F(phi) to persist. Use: `G(F(phi)) in M` implies `F(phi) in M` at all future chain points. The BX11 fold at each step still provides `phi in M' OR F(phi) in M'`. The key: when does the BX11 fold choose to resolve phi? This is the Exists.choose non-constructiveness issue.
- [ ] If `G(F(phi)) in M` case blocks the proof: check if `G(F(phi)) in M` is actually consistent with M being in a chain generated by `sigma_list`. If sigma_list contains phi and F(phi), the chain construction targets phi for resolution. The BX11 fold MIGHT resolve phi at some step (non-constructive choice), but we cannot PROVE it does.
- [ ] CRITICAL INSIGHT from handoff: `discharge_single_step` avoids the Exists.choose problem because it uses a SPECIFIC seed `{phi} union g_content(M)` rather than relying on the BX11 fold's non-constructive witness selection. This is why the hybrid chain is necessary.
- [ ] Close the sorry at line 1134 with the completed proof
- [ ] Run `lake build` to verify

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close `fwd_chain_forward_F` at line 1134

**Verification**:
- `fwd_chain_forward_F` compiles without sorry
- `lean_verify` on `fwd_chain_forward_F` shows no sorry axiom
- `lake build` succeeds

---

### Phase 3: Close Sorries #2, #3 (Backward Chain F/P-Resolution) [NOT STARTED]

**Goal**: Close sorry #2 (line 1161, F in backward chain region) and sorry #3 (line 1168, backward P-resolution) in `dd_bfmcs_restricted_tc`.

**Tasks**:
- [ ] Analyze backward chain structure: `bwd_chain_of_sigma` uses `bwd_pred` which preserves `h_content`. The backward chain has `h_content(chain(n)) subset chain(n+1)` via `sigma_bwd_h_content_step`
- [ ] Determine if backward chain needs the same hybrid redesign:
  - Sorry #3 requires: `P(phi) in chain(t)` implies `exists u < t, phi in chain(u)`. This is the backward dual of `fwd_chain_forward_F`. The same defect-count / round-robin argument applies symmetrically.
  - Sorry #2 requires: `F(phi) in chain(t)` for `t` in backward region implies `exists u > t, phi in chain(u)`. This needs F-resolution in the backward region, which propagates forward toward the origin and then into the forward chain.
- [ ] For sorry #3 (backward P-resolution): Build `bwd_chain_backward_P` as the dual of `fwd_chain_forward_F`. Apply the same hybrid strategy (preserving + discharge) to the backward chain, using `discharge_single_bwd_step` (or its equivalent) for P-obligations. BX12' gives `P(phi) -> (T S phi)`, and the same BX11 case analysis applies symmetrically.
- [ ] For sorry #2 (F in backward region): Case split:
  - If `F(phi) in chain(t)` and `t` is near the origin: bridge to the forward chain. The origin `chain(0) = M0` connects both chains. If `F(phi) in M0`, Phase 2's `fwd_chain_forward_F` gives the witness.
  - If `F(phi) in chain(t)` far from origin: show `F(phi)` propagates through h_content to the origin. `h_content` of a backward chain point may not contain F(phi) directly. Use BX4: `F(phi) -> G(P(F(phi)))`, so `G(P(F(phi))) in chain(t)`. Then `P(F(phi))` propagates backward. But we need forward propagation.
  - Alternative: `F(phi) in chain(t)` in backward region means `F(phi) in bwd_chain(k)` for some k. Since `g_content(bwd_chain(k))` may include `F(phi)` (if `G(F(phi)) in bwd_chain(k)`), check if g_content propagation holds in the backward chain direction.
  - Simplest approach: extend the forward chain's scope. The dd_chain is `bwd_chain ++ [M0] ++ fwd_chain`. If F(phi) appears anywhere in the backward chain, and the forward chain resolves F-obligations, then we need to show F(phi) reaches M0. This holds if `F(phi) in bwd_chain(k)` implies `F(phi) in bwd_chain(k-1)` (propagation toward origin). By `sigma_bwd_h_content_step`, `h_content(bwd_chain(k)) subset bwd_chain(k-1)`. Does `F(phi) in h_content(M)`? Only if `H(F(phi)) in M`, which is not guaranteed.
  - Fall back to: construct a BXPoint argument local to the chain, or use the forward chain directly from M0 after establishing `F(phi) in M0`.
- [ ] Close sorries at lines 1161 and 1168
- [ ] Run `lake build` to verify

**Timing**: 4 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` - Close sorries #2 and #3 in `dd_bfmcs_restricted_tc`

**Verification**:
- `dd_bfmcs_restricted_tc` compiles without sorry for the F-case and P-case
- `lake build` succeeds

---

### Phase 4: Close Sorry #5 (Forward Until/Since Coherence) [NOT STARTED]

**Goal**: Close sorry #5 at RootScopedChain.lean:1183 (`dd_bfmcs_restricted_fuc`) -- forward Until/Since coherence.

**Tasks**:
- [ ] Prove forward Until coherence: if `(phi U psi) in chain(t)`, then `exists s > t, psi in chain(s) AND forall r in (t,s), phi in chain(r)`
- [ ] Step 1: By BX10 (`until_F`), `F(psi) in chain(t)`. By Phase 2's `fwd_chain_forward_F`, exists `s > t` with `psi in chain(s)`
- [ ] Step 2: Choose minimal such `s`. Use `Nat.find` or well-ordering on the chain index set to get the first witness
- [ ] Step 3: Guard persistence. For `r` in `(t, s)`, show `phi in chain(r)`:
  - By BX5 (`self_accum_until`): `(phi U psi) in chain(t)` implies `((phi and (phi U psi)) U psi) in chain(t)`. This means `phi` AND `phi U psi` hold at all guard points
  - By BX9 (`until_elim`): `phi U psi -> phi v psi`. At any point `r` where `psi not-in chain(r)`, `phi U psi in chain(r)` forces `phi in chain(r)`
  - Need to show `phi U psi` persists from `t` to `s-1`. Use the chain's g_content propagation: if `G(phi U psi) in chain(t)`, it persists. If not, use `BX5` to get `((phi and (phi U psi)) U psi)`, then argue by induction: at each step before `s`, either `psi in chain(r)` (contradicting minimality of `s`) or `phi and (phi U psi) in chain(r)` (giving `phi in chain(r)` and persisting the Until formula)
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
  - Analyze `restricted_backward_until_since_coherent`: the hybrid backward chain from Phase 3 may now support this. If the backward chain resolves P-obligations via round-robin discharge, Until/Since coherence in the backward direction follows the same pattern as Phase 4 (forward Until/Since coherence)
  - If the backward chain's hybrid construction enables the same argument: close sorry #4 using the symmetric proof
  - If backward Until/Since coherence requires Until step transfer (`(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)`), which is blocked for Lindenbaum chains: document precisely, create follow-up task, mark task 109 [PARTIAL]
- [ ] If sorry #4 does NOT block `bx_completeness`: proceed directly to axiom audit
- [ ] Run `#print axioms Bimodal.Metalogic.BXCanonical.bx_completeness` via `lean_run_code`
- [ ] Verify output is exactly `{propext, Classical.choice, Quot.sound}` or document remaining sorries
- [ ] Run full `lake build` to confirm no regressions
- [ ] Update sorry counts in code comments if applicable

**Timing**: 2.5 hours

**Depends on**: 3, 4

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
- [ ] Forward temporal coherence (`dd_bfmcs_restricted_tc`) is fully sorry-free after Phases 2-3
- [ ] Forward Until/Since coherence (`dd_bfmcs_restricted_fuc`) is sorry-free after Phase 4

## Artifacts & Outputs

- `specs/109_close_chain_construction_sorries/plans/06_implementation-plan.md` (this file)
- Modified source files:
  - `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` (primary)
  - `Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` (possibly)
- Potentially new follow-up task for sorry #4 if not closed
- Implementation summary upon completion

## Rollback/Contingency

- Each phase is independently committable; rollback to previous phase's commit if a phase fails
- **Phase 1 fallback (Strategy pivot)**: If the hybrid chain approach (Strategy A/B) has insurmountable F-obligation destruction issues, pivot to Strategy C (defect-count argument on the existing chain). If Strategy C also fails due to the `G(F(phi))` persistence case, explore a combined approach: hybrid chain where discharge steps use a RICHER seed that includes F-obligations for all other defects (a restricted form of extended discharge where only the needed F-terms are included, avoiding the inconsistency by excluding phi from the F-protection set)
- **Phase 2 fallback**: If `fwd_chain_forward_F` proof stalls, try the weaker statement first: prove it for the special case where `|sigma_list| = 1` (single defect), then generalize
- **Phase 3 fallback**: If backward chain is too different from forward chain, use the bridge-through-origin approach: for F in backward region, propagate to origin via backward chain properties, then use forward chain's `fwd_chain_forward_F`
- **Phase 4 fallback**: If Until guard persistence is blocked (BX5 self-accumulation does not persist through Lindenbaum steps), use a direct counting argument on the number of steps where `psi not-in chain(r)` combined with the chain's temporal properties
- **Phase 5 fallback**: If sorry #4 remains, mark task [PARTIAL] with 4 of 5 sorries closed and create a follow-up task specifically for backward Until/Since coherence
- If any phase stalls beyond 1.5x estimated time, create a handoff document and mark [PARTIAL] for next session
