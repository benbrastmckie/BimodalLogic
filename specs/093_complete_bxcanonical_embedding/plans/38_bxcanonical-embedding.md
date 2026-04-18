# Implementation Plan: Direct Coherence Proofs for dd_bfmcs (v38)

- **Task**: 93 - Complete BXCanonical embedding
- **Status**: [IMPLEMENTING]
- **Effort**: 6 hours
- **Dependencies**: Task 92 (truth lemma sorry-free)
- **Research Inputs**: reports/38_team-research.md, reports/37_team-research.md
- **Artifacts**: plans/38_bxcanonical-embedding.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This plan closes the 3 sorry sites reachable from `bx_completeness` (lines 1517, 1522, 1527 in RootScopedChain.lean): `dd_bfmcs_restricted_tc`, `dd_bfmcs_restricted_buc`, and `dd_bfmcs_restricted_fuc`. Unlike Plan v37 which attempted to replace `dd_bfmcs` with a new quasimodel-backed construction (blocked by extended seed consistency and Until propagation through bx_le), this plan proves the coherence properties directly on the existing `dd_bfmcs` structure by working at the MCS level using already sorry-free primitives. The key insight from round 38 research is that `self_resolving_fwd_step` (lines 1961-1996, sorry-free) directly resolves F-eventualities without BX11 fold, and BX8/BX9/BX10 axioms at MCS level give Until/Since coherence without requiring chain-level propagation. Definition of done: `lake build` succeeds and `#print axioms bx_completeness` lists only `propext`, `Classical.choice`, `Quot.sound`.

### Research Integration

- **Report 38** (team, 4 teammates): Unanimous -- do not change language or semantics. BX11 fold is the root cause. `self_resolving_fwd_step` and `defect_bwd_step` are sorry-free primitives that bypass BX11. Priority ordering: tc first (quick win), then coherence.
- **Report 37** (team, 4 teammates): Oracle + quasimodel architecture is correct but proved harder than expected to implement. Extended seed consistency proof blocked on G-lift failing for Until formulas.

### Prior Plan Reference

Plan v37 attempted to replace `dd_bfmcs` entirely with a quasimodel-backed construction. Phase 1 (oracle construction) was blocked by two fundamental issues: (1) extended seed consistency fails because `alpha U beta in MCS` does NOT imply `G(alpha U beta) in MCS`, breaking the G-lift argument; (2) Until formulas do not propagate through `bx_le` (g_content subset), so `hintikka_step` Until clause is unsatisfied at intermediate points. Key lesson: avoid chain-construction replacement altogether; instead prove coherence on the existing `dd_bfmcs` families directly using MCS-level reasoning. Effort recalibrated from 8h to 6h by eliminating the oracle/quasimodel construction phases.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Prove `dd_bfmcs_restricted_tc` using `self_resolving_fwd_step` / `self_resolving_bwd_step` for F/P eventuality discharge
- Prove `dd_bfmcs_restricted_fuc` using BX9 (Until elimination) + BX10 (Until implies F) + `self_resolving_fwd_step` to find Until witnesses in the existing chain
- Prove `dd_bfmcs_restricted_buc` using BX8 (reflexive intro) + BX5 (self-accumulation) + BX6 (absorption) for backward Until/Since induction
- Achieve sorry-free `bx_completeness`

**Non-Goals**:
- Replacing `dd_bfmcs` with a new construction (learned from v37: unnecessary)
- Closing the 5 dead-code sorry sites (lines 1413, 1457, 1464, 2196, 2289)
- Building oracle or quasimodel infrastructure (not needed for this approach)
- Dense completeness (separate task 68)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Direct restricted_tc proof harder than expected: self_resolving_fwd_step gives witness in NEW MCS, not necessarily in dd_chain | H | M (35%) | The new MCS has g_content(M) subset, so it IS accessible from dd_chain. Prove that dd_chain at future time equals or is reachable from self_resolving_fwd_step result via chain stepping. Fallback: redefine dd_chain to use self_resolving_fwd_step directly. |
| Backward Until coherence (buc) requires induction on chain distance that may not terminate cleanly | M | M (30%) | Use well-founded induction on witness distance `s - t` (Int). BX5+BX9 give the step, BX8 gives the base case. If chain structure interferes, prove full backward coherence abstractly at MCS level first, then instantiate. |
| Forward Until coherence (fuc) requires witness at specific chain position, not just ANY future MCS | H | L (20%) | BX10 gives `F(psi)` from `phi U psi`, then self_resolving_fwd_step gives witness at dd_chain successor. Need to show witness is at a chain-accessible time. Use dd_chain stepping + g_content propagation. |
| BX9 guard at intermediate times: need phi at all r in [t,s), which requires tracking through round-robin schedule | M | M (25%) | Use g_content propagation: if phi U psi in mcs(t) and psi not in mcs(t), then phi in mcs(t) by BX9. At each successor step, either psi appears (done) or phi U psi persists (by BX5+BX10+chain construction), giving phi by BX9. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Restricted Temporal Coherence (restricted_tc) [BLOCKED]

**Goal**: Prove `dd_bfmcs_restricted_tc` -- that for every family in `dd_bfmcs` and every `phi in deferralClosure(root)`, if `F(phi) in fam.mcs(t)` then there exists `s > t` with `phi in fam.mcs(s)` (and symmetrically for P).

**Tasks**:
- [ ] Prove forward F-eventuality discharge for `dd_chain`: given `F(psi) in dd_chain(M0, sigma, t)`, construct witness `s > t` with `psi in dd_chain(M0, sigma, s)`. Strategy: use `self_resolving_fwd_step` on `dd_chain(t)` to get MCS M' with `psi in M'` and `g_content(dd_chain(t)) subset M'`. Then show `psi in dd_chain(t+1)` by establishing that either (a) `dd_chain(t+1)` already contains `psi` (if the round-robin schedule visits `psi`'s F-defect at step t), or (b) F(psi) persists through g_content to dd_chain(t+1), so iterate.
- [ ] Alternative approach if direct chain tracking is hard: prove `dd_fmcs_forward_F_via_self_resolving` that constructs a new FMCS by replacing dd_chain from time t+1 onward with a self-resolving chain starting from dd_chain(t). Show this new FMCS satisfies dd_bfmcs family membership (same Box content).
- [ ] Prove backward P-eventuality discharge symmetrically using `self_resolving_bwd_step`
- [ ] Prove `dd_bfmcs_restricted_tc` for shifted families: lift from unshifted via the shift-equivariance of dd_chain
- [ ] Close the sorry at line 1517

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- forward F/backward P discharge, restricted_tc proof

**Verification**:
- `dd_bfmcs_restricted_tc` compiles without sorry
- `lake build` succeeds

---

### Phase 2: Forward Until/Since Coherence (restricted_fuc) [NOT STARTED]

**Goal**: Prove `dd_bfmcs_restricted_fuc` -- that for every family, if `phi U psi in fam.mcs(t)` (with `phi U psi in subformulaClosure(root)`), then there exists `s >= t` with `psi in fam.mcs(s)` and `phi in fam.mcs(r)` for all `r in [t, s)`.

**Tasks**:
- [ ] Prove Until witness existence: `phi U psi in mcs(t)` implies by BX10 that `F(psi) in mcs(t)`. By Phase 1's forward F discharge, there exists `s > t` with `psi in mcs(s)`. The case `s = t` is handled by BX9: if `psi in mcs(t)`, take `s = t` (reflexive Until semantics, `t <= s`).
- [ ] Prove Until guard at intermediate times: need `phi in mcs(r)` for all `r in [t, s)`. Strategy: strong induction on `s - t`. At time `t`: either `psi in mcs(t)` (take s=t, no guard needed) or by BX9, `phi in mcs(t)` (guard holds at t). For the step: by BX5 (self-accumulation), `(phi and (phi U psi)) U psi in mcs(t)`, so the guard includes `phi U psi`. Since g_content propagates `phi U psi` is NOT guaranteed, but BX10 gives `F(psi) in mcs(t+1)` whenever `phi U psi in mcs(t+1)`. Use minimal witness: find the SMALLEST s with `psi in mcs(s)` and prove guard by BX9 at each intermediate point where `phi U psi` still holds.
- [ ] Alternative approach: use `dd_chain` structure directly. At each step t where `phi U psi in mcs(t)` and `psi not in mcs(t)`, BX9 gives `phi in mcs(t)`. The round-robin schedule visits all defects within `sigma_list.length` steps. Use BX10: `F(psi)` persists through g_content (since `G(F(psi))` may not hold, this needs care). Instead use: at each step, `phi U psi in mcs(t)` -> BX9 gives `phi or psi in mcs(t)` -> if `psi`, done; if `phi`, check next step.
- [ ] Prove Until persistence through g_content: if `phi U psi in mcs(t)` and `psi not in mcs(t)`, then by BX5+BX10, `F(phi U psi) in mcs(t)` (since `F(psi) in mcs(t)` by BX10, and `phi in mcs(t)` by BX9, use BX5 self-accumulation to get `(phi and (phi U psi)) U psi`, then BX10 gives `F(psi)`, but we need `F(phi U psi)` specifically). Actually: `phi U psi in mcs(t)` and `psi not in mcs(t)` gives by BX9 `phi in mcs(t)`, by BX5 `(phi and (phi U psi)) U psi in mcs(t)`, by BX10 `F(psi) in mcs(t)`. The key: we need `G(phi U psi) in mcs(t)` which is NOT guaranteed. Instead, use the fact that `(phi and (phi U psi)) U psi in mcs(t)` implies by BX10 that `F(psi) in mcs(t)`, which by the tc proof (Phase 1) gives witness. But for guard, need induction.
- [ ] Implement the guard proof via backward induction from witness: given smallest `s` with `psi in mcs(s)`, for each `r in [t, s)`: `psi not in mcs(r)` (by minimality). If `phi U psi in mcs(r)`, then BX9 gives `phi or psi in mcs(r)`, so `phi in mcs(r)` (guard at r). Show `phi U psi in mcs(r)` by forward induction from t: at t it holds by assumption; at r+1, it holds if g_content carries it, OR we re-derive it. Actually use backward induction from s: at s-1, since `psi in mcs(s)` and g_content(mcs(s-1)) subset mcs(s), we have... this requires showing `phi U psi in mcs(s-1)` which is what we want. Use forward induction instead with the explicit persistence argument.
- [ ] Prove Since coherence symmetrically
- [ ] Close the sorry at line 1527

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- Until/Since forward coherence

**Verification**:
- `dd_bfmcs_restricted_fuc` compiles without sorry
- `lake build` succeeds

---

### Phase 3: Backward Until/Since Coherence (restricted_buc) [NOT STARTED]

**Goal**: Prove `dd_bfmcs_restricted_buc` -- that for every family, if there exists `s >= t` with `psi in fam.mcs(s)` and `phi in fam.mcs(r)` for all `r in [t, s)`, then `phi U psi in fam.mcs(t)` (and symmetrically for Since).

**Tasks**:
- [ ] Prove backward Until by induction on distance `s - t`. Base case (`s = t`): `psi in mcs(t)`, so by BX8, `phi U psi in mcs(t)`. Inductive case (`s > t`): `phi in mcs(t)` (guard at t), and by IH `phi U psi in mcs(t+1)` (witnesses from t+1 to s exist with guard). Need: `phi in mcs(t)` and `phi U psi in mcs(t+1)` imply `phi U psi in mcs(t)`.
- [ ] Prove the key step lemma: `phi in mcs(t)` and `phi U psi in mcs(t+1)` and `g_content(mcs(t)) subset mcs(t+1)` imply `phi U psi in mcs(t)`. Strategy: by BX10, `phi U psi in mcs(t+1)` gives `F(psi) in mcs(t+1)`. Since `g_content(mcs(t)) subset mcs(t+1)` does NOT directly help (we need backward direction). Instead: `phi U psi in mcs(t+1)` means (semantically) witness exists at s >= t+1. We have `phi in mcs(t)` and witnesses from t+1. By BX8, `psi in mcs(t)` would give `phi U psi in mcs(t)`. If `psi not in mcs(t)`, need F(psi) in mcs(t): from `phi U psi in mcs(t+1)` -> `F(psi) in mcs(t+1)` by BX10 -> need `F(psi) in mcs(t)` but this goes backward. Use BX4': `F(psi) in mcs(t+1)` -> `H(F(F(psi))) in mcs(t+1)` (BX4 connect_past) -> since h_content(mcs(t+1)) subset mcs(t) (dd_chain backward H-propagation), `F(F(psi)) in mcs(t)` -> `F(psi) in mcs(t)` by transitivity of F (derived from BX axioms). Then `F(psi) in mcs(t)` combined with `phi in mcs(t)` gives by BX12+BX2: `top U psi in mcs(t)`, and by left_mono_until with G(top -> phi) (which needs phi at ALL future times, NOT just t), this fails.
- [ ] Revised strategy: use the SuccRelation infrastructure. The `until_intro_mcs` lemma (if it exists) or construct it: Given `phi in mcs(t)`, `F(phi U psi) in mcs(t)` (derived from `phi U psi in mcs(t+1)` and dd_chain backward g_content), and the BX axiom for Until introduction: `psi or (phi and F(phi U psi)) -> phi U psi` (derivable from BX8 + BX5 + BX6 + BX9). This is the crucial lemma. If `psi not in mcs(t)`, then need `phi and F(phi U psi) in mcs(t)`: `phi in mcs(t)` from guard, `F(phi U psi) in mcs(t)` from backward F-propagation of `phi U psi in mcs(t+1)`.
- [ ] Prove `F(phi U psi) in mcs(t)` from `phi U psi in mcs(t+1)`: since `phi U psi in mcs(t+1)` and `t+1 > t`, by h_content/BX4 connect_past: `H(F(phi U psi)) in mcs(t+1)` from `phi U psi in mcs(t+1)` via connect_past (phi -> H(F(phi))). Then h_content(mcs(t+1)) subset mcs(t) gives `F(phi U psi) in mcs(t)`.
- [ ] Prove the Until introduction derived rule at MCS level: `psi or (phi and F(phi U psi)) -> phi U psi`. Derivation: From BX8, `psi -> phi U psi`. From BX5, `phi U psi -> (phi and (phi U psi)) U psi`, so contrapositively with BX9: if `phi U psi in M` and `psi not in M` then `phi and (phi U psi) in M`, giving `F(psi) in M` and `F(phi U psi) in M` by BX10. For the introduction direction: `phi and F(phi U psi) in M` means `phi in M` and `F(phi U psi) in M`. `F(phi U psi) in M` gives by BX12 `top U (phi U psi) in M`. Combined with `phi in M` and BX9 (current time: `top U (phi U psi)` gives `top or (phi U psi)` at current time), then... This approach is getting complex. Alternative: use the existing `SuccRelation.until_intro_succ` if available.
- [ ] Check for existing `until_intro` infrastructure in SuccRelation.lean and use it
- [ ] Prove Since backward coherence symmetrically
- [ ] Close the sorry at line 1522

**Timing**: 1.5 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- backward Until/Since coherence
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- Until introduction derived rule (if not already present)

**Verification**:
- `dd_bfmcs_restricted_buc` compiles without sorry
- `lake build` succeeds

---

### Phase 4: Integration, Cleanup, and Verification [NOT STARTED]

**Goal**: Verify `dd_countermodel` and `bx_completeness` are sorry-free. Annotate dead code. Final build.

**Tasks**:
- [ ] Verify `dd_countermodel` compiles without sorry (should follow automatically from Phases 1-3)
- [ ] Verify `bx_completeness` compiles without sorry
- [ ] Run `#print axioms bx_completeness` and confirm only `propext`, `Classical.choice`, `Quot.sound`
- [ ] Annotate the 5 dead-code sorry sites (1413, 1457, 1464, 2196, 2289) with comments explaining they are unreachable from `bx_completeness`
- [ ] Mark BX11-based `enriched_fwd_step` / `resolving_enriched_fwd_exists` and `rr_fwd_chain_forward_F` as dead code
- [ ] Add docstrings to new theorems
- [ ] Run full `lake build`
- [ ] Grep for remaining sorry in BXCanonical files; verify none reachable from `bx_completeness`

**Timing**: 0.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- annotations, docstrings

**Verification**:
- `lake build` succeeds
- `#print axioms bx_completeness` shows only `propext`, `Classical.choice`, `Quot.sound`
- No reachable sorry from `bx_completeness`

---

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] `lean_verify` on `dd_bfmcs_restricted_tc` after Phase 1 -- no sorry dependency
- [ ] `lean_verify` on `dd_bfmcs_restricted_fuc` after Phase 2 -- no sorry dependency
- [ ] `lean_verify` on `dd_bfmcs_restricted_buc` after Phase 3 -- no sorry dependency
- [ ] `lean_verify` on `dd_countermodel` after Phase 3 -- no sorry dependency
- [ ] `lean_verify` on `bx_completeness` after Phase 4 -- only `propext`, `Classical.choice`, `Quot.sound`
- [ ] All new theorems have docstrings after Phase 4

## Artifacts & Outputs

- `specs/093_complete_bxcanonical_embedding/plans/38_bxcanonical-embedding.md` -- this plan
- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` -- coherence proofs (Phases 1-4)
- `Theories/Bimodal/Metalogic/BXCanonical/CanonicalChain.lean` -- Until introduction derived rule (Phase 3, if needed)

## Rollback/Contingency

1. **Full success**: `bx_completeness` sorry-free. No rollback needed.

2. **restricted_tc blocked (~35%)**: If `self_resolving_fwd_step` witness cannot be connected to `dd_chain` position, redefine `dd_chain` to use `self_resolving_fwd_step` as the chain-stepping function instead of `rr_fwd_chain`. This replaces the round-robin schedule with target-specific resolution. The BFMCS structure (modal coherence) is unaffected since it depends only on Box stability, which `self_resolving_fwd_step` preserves (Box content is in g_content).

3. **Forward Until coherence blocked (~20%)**: If guard proof at intermediate times is too hard, weaken the approach: prove `restricted_fuc` for formulas of the form `top U psi` only (which covers the BX12 bridge from F to Until). Then `restricted_tc` + weakened `restricted_fuc` may suffice for the truth lemma cases actually reached by `bx_completeness`. Check which Until subformulas actually appear in `subformulaClosure(root)`.

4. **Backward Until coherence blocked (~30%)**: If the Until introduction derived rule is not derivable from BX1-BX12 in the required form, fall back to Plan v37's oracle approach for `restricted_buc` only, accepting the extended seed consistency as a focused sub-problem. Or: check if `restricted_buc` is needed at all for `bx_completeness` -- the truth lemma backward Until case might reduce to a simpler statement.

5. **Full rollback**: `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/` restores current state.
