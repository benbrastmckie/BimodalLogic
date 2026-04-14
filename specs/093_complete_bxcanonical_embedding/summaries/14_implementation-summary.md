# Implementation Summary: Task #93 — Close BXCanonical Embedding

**Completed**: 2026-04-14
**Mode**: Team Implementation (2 max concurrent teammates)
**Status**: PARTIAL — blocked on forward_F proof

## Wave Execution

### Wave 1 (Phase 1: Ordered Defect-Discharge Infrastructure) — COMPLETED
- Added BX11 ordering infrastructure (sorry-free):
  - `conj_comm_imp`, `F_conj_comm_mcs`: conjunction commutativity under F
  - `bx11_earlier`, `bx11_earlier_total`: BX11 temporal ordering on F-defects (total preorder)
  - `bx11_earlier_resolving_seed`: compound extraction for earliest defect
  - `discharge_single_step`: guaranteed target resolution with g_content
  - `discharge_two_step`: two-target resolution via BX11 ordering
  - `discharge_multi_step`: multi-target wrapper around enriched_fwd_exists
  - `activeDefects`, `activeDefects_F_mem`, `activeDefects_mem_sigma`: defect tracking
  - `discharge_fwd_chain` with g_content propagation

### Wave 2 (Phase 2: Prove forward_F) — PARTIAL
- Added strengthened BX11 fold infrastructure (sorry-free):
  - `enriched_fwd_fold_with_witness`: tracks a "direct witness" formula through the fold
  - `resolving_enriched_fwd_exists`: guarantees at least one F-defect is directly resolved
  - `enriched_fwd_step_resolves_one`: resolution guarantee at each chain step
  - `rrSchedule_mem`: schedule returns elements of the list
  - Upgraded `enriched_fwd_step` to use `resolving_enriched_fwd_exists`
- **BLOCKED**: `rr_fwd_chain_forward_F` (line 1139) remains sorry

### Waves 3-5 (Phases 3-6) — NOT STARTED
- Blocked by Phase 2 (forward_F is prerequisite for all downstream sorries)

## Sorry Sites (7 total, was 6 at start)

| Line | Theorem | Blocker |
|------|---------|---------|
| 1139 | `rr_fwd_chain_forward_F` | **Primary blocker** — forward_F for the Nat chain |
| 1170 | `dd_fmcs_forward_F` (t<0 case) | Depends on line 1139 |
| 1177 | `dd_fmcs_backward_P` | Symmetric to forward_F |
| 1230 | `dd_bfmcs_restricted_tc` | Depends on forward_F + backward_P |
| 1235 | `dd_bfmcs_restricted_buc` | Backward Until coherence (independent high-risk) |
| 1240 | `dd_bfmcs_restricted_fuc` | Forward Until coherence (depends on forward_F) |

Note: the extra sorry (7 vs original 6) is from the dd_fmcs_forward_F negative-t case being split out as a separate sorry during Wave 2 investigation.

## Root Cause Analysis: forward_F Blocker

The core obstacle is proving `F(ψ) ∈ chain(n) → ∃ s > n, ψ ∈ chain(s)` for the enriched round-robin chain.

### Why it's hard

1. **Disjunctive resolution**: `enriched_fwd_step` gives `ψ ∈ M' ∨ F(ψ) ∈ M'` at each step (not guaranteed direct resolution). The BX11 fold can F-wrap the target (case 3), so `ψ ∈ M'` is not assured.

2. **Extended seed inconsistency**: The natural fix — using `{target} ∪ g_content(M) ∪ f_carry(M)` as the seed — fails because this set can be INCONSISTENT. Concrete counterexample: if `G(ψ → G(¬χ)) ∈ M` and `F(χ) ∈ M`, then `{ψ} ∪ g_content(M) ∪ {F(χ)}` derives ⊥ (ψ + G(ψ→G(¬χ)) gives G(¬χ), contradicting F(χ)).

3. **Stable F-obligation set**: The set `{χ ∈ sigma_list | F(χ) ∈ chain(m)}` is stable (never grows by `no_new_f_defects`, never shrinks because `χ ∈ M → F(χ) ∈ M` in any MCS by temp_t contrapositive). The "defect set" (F-defects not yet resolved) can fluctuate, so defect count is not a valid well-founded measure.

4. **Circular backward G**: Proving F(ψ) persists forever leads to ¬ψ everywhere, but proving G(¬ψ) from this requires backward G, which itself requires forward_F. Circular.

### Viable approaches not yet attempted

1. **Replace chain construction entirely**: Define a new chain using `discharge_single_step` at each step (guaranteeing target ∈ M'). Accept that F-formulas are not preserved via f_carry. Instead, prove F(ψ) cannot be PERMANENTLY lost: G(¬ψ) ∈ chain(n) would require G(G(¬ψ)) ∈ chain(0) = M₀, but F(ψ) ∈ M₀ contradicts G(¬ψ) ∈ M₀. So G(¬ψ) never enters the chain, meaning ¬G(¬ψ) = F(ψ) is "possible" at every step. Then argue by classical reasoning that ψ must appear somewhere.

2. **Dovetailing construction** (Goldblatt 1992): Use an ω²-indexed chain that resolves each formula at infinitely many steps, with an auxiliary argument that F-formulas from M₀ eventually get their witness.

3. **Quasimodel approach**: Route through the existing BXPoint-based quasimodel infrastructure (Frame.lean) which already has a complete forward_F proof for the BXPoint canonical model, then bridge to the parametric (Int-indexed) model.

## Files Modified

- `Theories/Bimodal/Metalogic/BXCanonical/RootScopedChain.lean` — +354 lines of new sorry-free infrastructure, original sorry sites unchanged

## Build Status

`lake build` succeeds with 7 sorry warnings (no errors).

## Team Metrics

| Metric | Value |
|--------|-------|
| Waves attempted | 2 of 5 |
| Phases completed | 1 (Phase 1 fully sorry-free) |
| Phases partial | 1 (Phase 2 — infrastructure added, core sorry remains) |
| Teammates spawned | 2 |
| Debugger invocations | 0 |
| New sorry-free lemmas | 16 |

## Recommendation

The forward_F blocker requires a fundamentally different chain construction. The current enriched round-robin chain cannot prove forward_F due to the disjunctive resolution problem. A new `/research 93` round focused specifically on the "discharge_single_step chain + G(¬ψ) impossibility" approach (item 1 above) is recommended before the next `/implement` attempt.
