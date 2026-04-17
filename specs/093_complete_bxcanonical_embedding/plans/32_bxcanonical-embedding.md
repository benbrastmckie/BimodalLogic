# Implementation Plan: Quasimodel-Derived Chain for BXCanonical Completeness (v32)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [IMPLEMENTING]
- **Effort**: 10 hours
- **Dependencies**: None (task 102 completed; truth lemma sorry-free)
- **Research Inputs**: reports/32_team-research.md
- **Artifacts**: plans/32_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v30 Phase 1 (archive dead approaches) is complete. This plan picks up from that foundation and addresses the remaining 6 sorry sites in `RootScopedChain.lean` using a quasimodel-derived chain construction. Report 32's team research (4 teammates, 99% consensus) definitively establishes that forward_F is unprovable on the existing round-robin chain and that the quasimodel-derived chain is the only viable path. This plan incorporates three critical new findings from Report 32: (1) sorry 5 is an independent blocker requiring its own solution, not low-hanging fruit; (2) sorry 3 (backward_P) is strictly harder than sorry 1 because the backward chain has no enrichment; (3) the sorry dependency graph is a diamond (not circular), with sorries 1 and 3 as independent roots. Definition of done: `lake build` succeeds with zero sorry in `RootScopedChain.lean` and `#print axioms` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 32** (team research, 4 teammates): Definitively confirms forward_F is unprovable on round-robin chain (99% consensus). Corrects sorry dependency graph to diamond structure (sorries 1 and 3 are independent roots). Identifies sorry 5 as independent blocker requiring step transfer property. Confirms sorry 3 is harder than sorry 1 (backward chain lacks enrichment). All 4 teammates converge on quasimodel-derived chain (70% synthesized confidence). Key resolution: `hintikka_step` maps to `fwd_succ` which guarantees g_content inclusion by construction. Estimated 500-800 new LOC.

### Prior Plan Reference

Plan v30 reached [PARTIAL] status: Phase 1 (archive dead approaches, update ROAD_MAP.md) completed successfully. Phase 2 (build quasimodel-derived forward chain) was marked [BLOCKED] pending the forward_F obstruction analysis that Report 32 now provides. Lessons learned: (a) the plan correctly identified that forward_F must be built INTO the construction; (b) effort estimate of 10 hours was reasonable; (c) the fully sequential phase dependency was appropriate given mathematical dependencies. This plan preserves the same architecture but restructures phases to reflect the corrected sorry dependency graph (diamond, not chain) and the additional blockers identified in Report 32.

### Roadmap Alignment

- Advances: Close all 6 `RootScopedChain.lean` sorries (ROAD_MAP "Active-Path Sorry Inventory")
- Advances: Make `dd_countermodel` sorry-free, resolving `Completeness.lean:154`
- Unblocks: Task 95 (`#print axioms` audit on `bx_completeness`)

## Goals & Non-Goals

**Goals**:
- Replace `rr_fwd_chain` with a defect-driven forward chain (`defect_fwd_chain`) where forward_F is definitional
- Replace `rr_bwd_chain` with a defect-driven backward chain (`defect_bwd_chain`) where backward_P is definitional
- Close all 6 sorry sites in `RootScopedChain.lean` (lines 1413, 1457, 1464, 1517, 1522, 1527)
- Achieve `lake build` with zero sorry in active BXCanonical path
- Address sorry 5's step transfer property through the chain construction itself

**Non-Goals**:
- Proving `rr_fwd_chain_forward_F` for the existing round-robin chain (definitively blocked per 32 rounds of research)
- Modifying the truth lemma or quasimodel infrastructure (sorry-free, proven correct)
- Dense completeness (independent task 68)
- Game-theoretic approach (3000+ LOC, not justified)
- Modifying `Frame.lean`, `CanonicalModel.lean`, or `Quasimodel/` (all sorry-free)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| F-formula survival through witness chaining: `F(psi)` must survive in `v_{i-1}` for cascading resolution to work | H | M (35%) | Use single-formula seed protection: at each resolving step, include `{target, F(next_defect)}` in seed. Each step protects exactly the next defect in queue, giving cascading resolution (Report 32 Recommendation 3). |
| Backward chain has NO enrichment: `bwd_pred`/`p_carry` do not support P-formula preservation | H | M (40%) | Build symmetric defect-driven backward chain using `bwd_pred` with targeted P-defect discharge. The backward direction needs its own enrichment parallel to the forward direction. |
| Sorry 5 step transfer requires `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)` | H | M (40%) | In the defect-driven chain, Until formulas are tracked as defects. The chain construction can ensure Until-formula presence at each step by including them in the seed (they are subformulas of the closure, hence consistent with any MCS containing their guard). |
| g_content chaining gap: `bx_forward_witness` gives `g_content(M) subset v` but chaining needs `g_content(v_{i-1}) subset v_i` | M | L (20%) | `fwd_succ` guarantees `g_content(input) subset output` by construction. Using `v_{i-1}` as the input MCS (not `M0`) resolves this directly. The real question is F-formula survival (addressed in risk 1). |
| Finite defect-discharge to infinite chain extension | M | L (20%) | Beyond the finite defect-discharge region (bounded by formula count), extend with non-resolving `fwd_succ` steps. Forward_F only needs the finite prefix. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel (though this plan is fully sequential due to mathematical dependencies between the sorry sites).

---

### Phase 1: Build Defect-Driven Forward Chain [BLOCKED]

**Goal**: Replace `rr_fwd_chain` with a new `defect_fwd_chain` that resolves F-obligations one per step using defect-driven scheduling (not round-robin). Forward_F is definitional: each F-defect is targeted in order, and the cascading seed protection ensures subsequent defects survive each resolving step.

**Tasks**:
- [ ] Study the key extraction points in quasimodel infrastructure:
  - `Quasimodel/Construction.lean`: `hintikka_step`, `defect_count` (strict decrease)
  - `CanonicalModel.lean:66`: `fwd_succ` (gives MCS with g_content inclusion)
  - `Frame.lean:164`: `bx_forward_witness` (gives MCS resolving a single F-obligation)
- [ ] Define `defect_fwd_chain : MCS -> List Formula -> Nat -> MCS`:
  - Input: root MCS `M0`, ordered list of F-defects `[F(psi_1), ..., F(psi_k)]` from `deferralClosure(M0)`
  - At step `n` (where `n <= k`): use `fwd_succ` with seed `{psi_n} union g_content(chain(n-1))` to resolve defect `n`, while g_content propagation preserves all G-obligations and the next defect `F(psi_{n+1})` survives via g_content or explicit seed inclusion
  - At step `n > k`: use `fwd_succ` with any target (non-resolving, pure g_content propagation)
- [ ] Prove `defect_fwd_chain_forward_F`: If `F(psi) in chain(n)` and `psi in deferralClosure(root)`, then `exists s > n, psi in chain(s)`. Proof sketch: `F(psi)` appears in the defect list at some index `j`. At step `j`, the chain resolves `F(psi_j) = F(psi)`, placing `psi` in `chain(j)`. If `n >= j`, the defect was already resolved and `psi` is accessible via g_content. If `n < j`, the defect will be resolved at step `j > n`.
- [ ] Prove `defect_fwd_chain_g_content`: `g_content(chain(n)) subset chain(n+1)` -- follows from `fwd_succ` specification
- [ ] Prove `defect_fwd_chain_mcs`: each element is MCS -- follows from `fwd_succ` giving MCS
- [ ] Prove `defect_fwd_chain_box_stable`: box formulas stable across chain -- follows from g_content propagation (Box(phi) in MCS implies G(Box(phi)) by S5+BX interaction, hence Box(phi) in g_content)
- [ ] Run `lake build` to verify compilation of new forward chain

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add `defect_fwd_chain` and its properties alongside existing code

**Verification**:
- `defect_fwd_chain_forward_F` compiles without sorry
- `defect_fwd_chain_g_content`, `defect_fwd_chain_mcs`, `defect_fwd_chain_box_stable` compile without sorry
- `lake build` succeeds

---

### Phase 2: Build Defect-Driven Backward Chain and Assemble Int-Chain [BLOCKED]

**Goal**: Build the symmetric backward chain for P-obligations and assemble the full Int-indexed chain. This addresses sorry 3's difficulty (backward chain lacks enrichment) by giving it the same defect-driven treatment as the forward chain. Also address sorry 5's step transfer property by ensuring Until formulas are tracked and preserved.

**Tasks**:
- [ ] Define `defect_bwd_chain : MCS -> List Formula -> Nat -> MCS`:
  - Symmetric to `defect_fwd_chain` but using `bwd_pred` and targeting P-defects `[P(psi_1), ..., P(psi_m)]`
  - At each step, resolve one P-obligation while h_content propagation preserves H-obligations
  - Seed includes `{psi_n} union h_content(chain(n-1))` for targeted resolution
- [ ] Prove `defect_bwd_chain_backward_P`: If `P(psi) in chain(n)` then `exists s > n, psi in chain(s)` (reading the backward chain in reverse temporal direction). This is the symmetric proof to forward_F.
- [ ] Prove `defect_bwd_chain_h_content`: `h_content(chain(n)) subset chain(n+1)` -- from `bwd_pred` specification
- [ ] Prove `defect_bwd_chain_mcs`: each element is MCS
- [ ] Assemble `defect_dd_chain : Int -> MCS`:
  - For `t >= 0`: `defect_fwd_chain(M0, fwd_defects, t)`
  - For `t < 0`: `defect_bwd_chain(M0, bwd_defects, |t|)`
  - Prove continuity at `t = 0`: both directions agree at `M0`
- [ ] Address Until formula preservation in chain construction:
  - Ensure that `(phi U psi)` formulas present in the root MCS are tracked through the chain via g_content/h_content propagation
  - If `(phi U psi) in chain(n)` and the chain resolves `F(psi)` at step `m > n`, then `(phi U psi)` persists from step `n` to step `m` via g_content (since `G(phi U psi)` follows from BX5 self_accum_until in a consistent MCS)
  - This addresses sorry 5's step transfer: the defect-driven chain explicitly tracks Until defects
- [ ] Run `lake build` to verify compilation

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- add `defect_bwd_chain`, `defect_dd_chain`, and properties

**Verification**:
- `defect_bwd_chain_backward_P` compiles without sorry
- `defect_dd_chain` assembles correctly at `t = 0` boundary
- Until formula preservation lemma compiles
- `lake build` succeeds

---

### Phase 3: Wire Into FMCS/BFMCS and Close Sorries 1-4 [BLOCKED]

**Goal**: Replace `dd_fmcs`/`dd_bfmcs` internals to use `defect_dd_chain` and close sorry sites 1 (forward_F, line 1413), 2 (forward_F for t<0, line 1457), 3 (backward_P, line 1464), and 4 (restricted_tc, line 1517). This exploits the diamond dependency structure: sorries 1 and 3 are independent roots, and sorry 4 depends on both.

**Tasks**:
- [ ] Redefine `dd_fmcs` to use `defect_dd_chain` instead of the round-robin `dd_chain`. Preserve the same `FMCS Int` signature.
- [ ] Reprove `dd_fmcs` structural properties (`dd_fmcs_mcs`, `dd_chain_g_content`, `dd_chain_h_content`, etc.) using `defect_fwd_chain`/`defect_bwd_chain` properties
- [ ] Close sorry 1 (line 1413, `rr_fwd_chain_forward_F`): Wire `defect_fwd_chain_forward_F` through. This is now definitional -- the chain construction guarantees it.
- [ ] Close sorry 2 (line 1457, `dd_fmcs_forward_F` for t<0): For `F(psi) in dd_chain(t)` with `t < 0`, the backward chain element at `t` has `F(psi)`. Since `g_content` propagates forward from the backward chain through `M0` to the forward chain, `F(psi) in g_content(chain(t)) subset chain(t+1)`, and chaining through to `t = 0` gives `F(psi) in M0`. Then `defect_fwd_chain_forward_F` gives `psi in chain(s)` for some `s > 0`.
- [ ] Close sorry 3 (line 1464, `dd_fmcs_backward_P`): Wire `defect_bwd_chain_backward_P` through. Symmetric to sorry 1 using the backward chain.
- [ ] Close sorry 4 (line 1517, `dd_bfmcs_restricted_tc`): For each family in `dd_bfmcs.families`, temporal coherence follows from both forward_F and backward_P being structural in every family's chain (each family uses the same defect-driven construction with a different root and shift).
- [ ] Run `lake build` and verify sorry count reduced to 2 (sites 5-6)

**Timing**: 3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- redefine `dd_fmcs`, close sorry sites 1-4

**Verification**:
- Sorry sites at lines 1413, 1457, 1464, 1517 are closed
- `lake build` succeeds
- `grep -n sorry RootScopedChain.lean` shows at most 2 remaining (sites 5-6 at lines 1522, 1527)

---

### Phase 4: Close Until/Since Coherence and Final Verification [BLOCKED]

**Goal**: Close sorry sites 5 (line 1522, `dd_bfmcs_restricted_buc`) and 6 (line 1527, `dd_bfmcs_restricted_fuc`). Then perform final verification that `bx_completeness` is sorry-free.

**Tasks**:
- [ ] Close sorry 6 (line 1527, `dd_bfmcs_restricted_fuc`, forward Until/Since coherence):
  - **Forward Until** `(phi U psi)`: Given `(phi U psi) in fam.mcs(t)`:
    1. By BX10 (`until_F`): `F(psi) in fam.mcs(t)`
    2. By `restricted_tc` (now proved via sorry 4): `exists s > t, psi in fam.mcs(s)`
    3. Guard propagation: BX5 (`self_accum_until`) gives `(phi AND (phi U psi)) U psi`, so `phi U psi` persists at intermediate points via g_content
    4. Minimum witness argument: at each `r in [t,s)`, `phi U psi in fam.mcs(r)` (g_content), `psi not in fam.mcs(r)` (minimality), so by BX9 (`until_elim`): `phi in fam.mcs(r)`
  - **Forward Since** `(phi S psi)`: Symmetric using backward_P
- [ ] Close sorry 5 (line 1522, `dd_bfmcs_restricted_buc`, backward Until/Since coherence):
  - Given semantic witnesses (psi at s, phi on guard), derive `(phi U psi) in fam.mcs(t)`:
    1. By BX8 (`refl_intro_until`): `psi -> (phi U psi)` gives `(phi U psi) in fam.mcs(s)`
    2. Propagate backward from `s` to `t`: the defect-driven chain's Until-formula tracking (Phase 2) ensures `(phi U psi)` persists backward via h_content or the chain's explicit Until defect management
    3. If the direct chain-level argument is insufficient, use the restricted parametric truth lemma to convert semantic truth to MCS membership
  - **Backward Since**: Symmetric
- [ ] Run `grep -n sorry RootScopedChain.lean` to verify zero executable sorry
- [ ] Run `lake build` to verify compilation
- [ ] Use `lean_verify` on `bx_completeness` to confirm axioms are exactly `{propext, Classical.choice, Quot.sound}`
- [ ] Update ROAD_MAP.md sorry inventory to show 0 active-path sorries
- [ ] Verify no new sorry introduced in any active-path file

**Timing**: 2 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- close sorry sites 5-6
- `specs/ROAD_MAP.md` -- update sorry inventory to 0

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `grep -n sorry RootScopedChain.lean` returns only comment-embedded occurrences
- `lake build` succeeds
- `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -n sorry Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` returns zero executable sorry (after Phase 4)
- [ ] `lean_verify` on `dd_countermodel` shows no sorry-dependent axioms
- [ ] `lean_verify` on `bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- [ ] No new sorry introduced in any active-path file
- [ ] ROAD_MAP.md sorry inventory shows 0 active-path sorries (after Phase 4)

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- 6 sorry sites closed, defect-driven chain replaces round-robin chain
- `specs/ROAD_MAP.md` -- updated sorry inventory to 0
- `specs/093_complete_bxcanonical_embedding/plans/32_bxcanonical-embedding.md` -- this plan

## Rollback/Contingency

1. **Full success (all 6 sorries closed via defect-driven chain)**: Target outcome. No rollback needed.

2. **Forward chain works but backward chain blocked (~20%)**: Keep forward_F proof (closes sorries 1, 2, 4 partially). Spawn focused task for backward chain enrichment. Sorry count reduces from 6 to 3-4.

3. **Forward_F and backward_P work but Until/Since coherence blocked (~25%)**: Keep temporal coherence proofs (closes sorries 1-4). Reduces sorry count from 6 to 2. Spawn focused task for Until/Since using restricted truth lemma approach.

4. **F-formula survival through cascading resolution fails (~15%)**: Fall back to single-defect resolution per chain segment. Build `k` separate chain segments (one per defect), each resolving one F-obligation. Stitch segments via `fwd_succ` at boundaries. More LOC but sidesteps the cascading survival problem.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` restores current state. Phase 1 archival from plan v30 is independently valuable and already committed.
