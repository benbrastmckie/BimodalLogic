# Research Report: Task #69 - Z_chain_forward_F Blocker Analysis

**Task**: 69 - Close Z_chain_forward_F' via dovetailed omega construction
**Date**: 2026-03-30
**Mode**: Team Research (2 teammates)
**Session**: sess_1774902784_b5f64e

## Summary

Both teammates converge on the same core strategy: **replace `omega_chain_forward` with `omega_chain_F_preserving_forward` in Z_chain's definition** for the forward (t >= 0) half. The F-preserving chain already has `omega_F_preserving_forward_F_resolution` fully closed, which directly solves the forward F-obligation sorries. However, `f_preserving_seed_consistent` must be closed first (it's the deepest dependency), and the backward direction requires a symmetric P-preserving construction that doesn't yet exist.

## Key Findings

### 1. Root Cause (Confirmed by Both Teammates)

`Z_chain` at line 2557 uses `omega_chain_forward` for t >= 0, which always resolves `F_top` (neg bot) at each step — providing **no guarantee** that arbitrary `F(phi)` is ever resolved. All three sorries (Z_chain_forward_F line 2797, Z_chain_backward_P line 2814, Z_chain_forward_F' line 3976) fail in the `phi not in chain(t)` branch for exactly this reason.

### 2. The Fix Exists and Is Closed (High Confidence)

`omega_chain_F_preserving_forward` (line 4185) with `omega_F_preserving_forward_F_resolution` (line 4303) is **fully closed**. It guarantees `F(phi) in chain(t) -> exists s >= t, phi in chain(s)` via Cantor pairing + F-persistence invariant.

All required supporting theorems exist:
- `omega_chain_F_preserving_forward_mcs` (exists)
- `omega_chain_F_preserving_forward_zero` (exists)
- `omega_chain_F_preserving_forward_G_theory` (exists)
- `omega_chain_F_preserving_forward_box_class` (exists)

### 3. Dependency Graph (Critical Path)

```
f_preserving_seed_consistent          <-- DEEPEST BLOCKER (sorry)
  └─> temporal_theory_witness_F_preserving
        └─> omega_chain_F_preserving_forward construction
              └─> omega_F_preserving_forward_F_resolution (CLOSED)
                    └─> Z_chain_forward_F (t >= 0 case)  <-- TARGET
```

Closing `f_preserving_seed_consistent` transitively closes the dovetailed chain sorry at line 4561 and enables the full Z_chain fix.

### 4. Missing Infrastructure

| Item | Status | Impact |
|------|--------|--------|
| `omega_chain_F_preserving_forward_G_monotone` | Does not exist | Needed for `Z_chain_forward_G` |
| P-preserving backward chain | Does not exist | Needed for `Z_chain_backward_P` |
| Cross-chain bridge (backward to forward) | Not proven | Needed for `Z_chain_forward_F'` t < 0 case |

### 5. Backward Direction Gap

When t < 0, F(phi) is in the backward chain. Resolving it requires either:
- Finding phi in the backward chain at some k <= (-t).toNat
- Connecting F(phi) through M0 to the forward chain
- Building a P-preserving backward chain (symmetric to F-preserving forward)

If Z_chain uses F-preserving forward chain AND F(phi) in M0, then the forward chain resolves it. If F(phi) not in M0, this case remains genuinely blocked.

## Synthesis

### Conflicts Resolved

No direct conflicts — both teammates recommend the same primary strategy (replace Z_chain forward direction). They differ on emphasis:
- Teammate A: Detailed downstream impact analysis (5 property lemmas need updating)
- Teammate B: Deeper dependency analysis showing f_preserving_seed_consistent as the true root blocker

### Gaps Identified

1. **f_preserving_seed_consistent** (the iterated F-extraction induction) has not been attempted in code yet. Teammate B provides a concrete proof sketch using `List.countP`-based strong induction
2. The `t < 0` case in `Z_chain_forward_F'` may remain blocked even after the forward fix
3. `Z_chain_forward_G` cross-chain cases (lines 2696, 2718) are independent sorries not addressed by this fix

### Recommendations

**Implementation Order** (both teammates agree):

1. **Close `f_preserving_seed_consistent`** (~60-80 lines, iterated F-extraction):
   - Strong induction on `List.countP` of F-formulas in context
   - Uses: `G_lift_from_context` (line 1066), `G_of_disjunction_in_mcs_elim` (line 1255), `some_future_excludes_all_future_neg` (line 1090)
   - This transitively closes the sorry at line 4561

2. **Redefine Z_chain** to use `omega_chain_F_preserving_forward` for t >= 0 (one-line change at line 2561):
   - Update 5 property lemmas: `Z_chain_mcs`, `Z_chain_box_class`, `Z_chain_zero`, `Z_chain_forward_G`, `Z_chain_forward_F`
   - Add `omega_chain_F_preserving_forward_G_monotone` lemma

3. **Close Z_chain_forward_F** t >= 0 case using `omega_F_preserving_forward_F_resolution` directly

4. **Assess backward direction**: Determine if P-preserving backward chain is needed or if bridge through M0 suffices

**What NOT to do**:
- Don't try to prove `omega_forward_F_bounded_persistence` for `omega_chain_forward` — it's likely unprovable without the F-preserving invariant
- Don't try shortcutting `f_preserving_seed_consistent` with direct containment — the G-lift step fails on F-formulas (teammate B confirmed)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | F-preserving chain approach | completed | High (t>=0), Low-Med (t<0) |
| B | Alternative approaches & prior art | completed | High (dependency graph), Medium (backward) |

## References

**Code locations**:
- Z_chain definition: UltrafilterChain.lean:2557
- omega_chain_forward: UltrafilterChain.lean:2387
- omega_chain_F_preserving_forward: UltrafilterChain.lean:4185
- omega_F_preserving_forward_F_resolution: UltrafilterChain.lean:4303
- f_preserving_seed_consistent: UltrafilterChain.lean (sorry)
- G_lift_from_context: UltrafilterChain.lean:1066
- G_of_disjunction_in_mcs_elim: UltrafilterChain.lean:1255

**Prior research**:
- Report 01: Initial research on Z_chain_forward_F
- Report 02: Team research on F-preserving seeds strategy
- Report 03: Sorry closure research with code snippets
- Report 04: Team research on semantic mismatch and f_preserving_seed_consistent validity
- Summary 07: Semantic fix implementation (partial)

**Literature**:
- Verbrugge (1992): Completeness for tense logics via diagonalization
- Goldblatt (1992): Canonical model construction with F-persistence
- Blackburn, de Rijke, Venema (2001): Modal Logic completeness methods
