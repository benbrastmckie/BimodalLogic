# D-Consistency Architecture: Fundamental Issue and Resolution

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Focus**: Why d_consistency is unprovable AND why infimum redefinition IS necessary

---

## Finding: d_consistency is UNPROVABLE for d = a_bwd(n)

### The argument

1. GHR93 Claim 1 (p.116): In any play of G_{m;r'} with r' > r, m ≥ 1, if Duplicator uses a winning strategy, her response to c **must equal d̄** (the infimum of continuation_set).

2. d̄ is the UNIQUE valid response at position n. No other element can appear at position n in a winning tuple.

3. d_consistency says: for any d with matching rank-r type, ∃ response with position n = d.

4. If d ≠ d̄: no such response exists → d_consistency is FALSE.

5. Since d = a_bwd(n) is Spoiler's arbitrary pick in the backward game, d can differ from d̄.

### Why previous approaches failed

- **Direct uniqueness (round 1)**: Tried t = d at rank r. Failed because rank-r type doesn't pin identity.
- **Rank embedding without infimum (handoff-b)**: Added h_fwd_r1 parameter. But the sorry is still at "t = d", and this is FALSE when d ≠ d̄.
- **Infimum redefinition dismissed as wasted**: Handoff-b claimed infimum "moves the sorry." This was WRONG — with d = d̄, d_consistency becomes a corollary of Claim 1 (the response IS d̄ by Claim 1, and d = d̄ by definition).

### The correction

The Phase 1 handoff-b's claim that infimum redefinition is "wasted effort" was incorrect. The analysis confused two things:

- With d = a_bwd(n): need "t = a_bwd(n)" which is FALSE for some a_bwd(n) values
- With d = d̄: need "t = d̄" which IS Claim 1 and IS provable with rank r+1

The infimum redefinition ELIMINATES the d_consistency sorry entirely. Claim 1 becomes the new obligation, and IS provable.

---

## Resolution: Infimum Redefinition IS Necessary

### Architecture change

```
CURRENT (broken):
  d := a_bwd(n)                    -- arbitrary, may ≠ d̄
  hd_eq_an : d = a_bwd(n) := rfl  -- used at 25 sites in Case II
  d_consistency: ∃ resp, resp(n) = d  -- UNPROVABLE when d ≠ d̄

TARGET (correct):
  d := infimum(continuation_set)   -- equals d̄ by definition
  hd_le_an : d ≤ a_bwd(n)         -- infimum ≤ member
  d_consistency: ∃ resp, resp(n) = d  -- TRUE by Claim 1
```

### Why Case II must change

Case II uses hd_eq_an at 25 sites to rewrite a_bwd(n) to d in game tuples. With d = d̄ ≠ a_bwd(n), these rewrites are invalid. Case II must be restructured to:

1. Work with d = d̄ (not a_bwd(n)) as the split point
2. Show a_bwd(i) > d for all i (since d is the infimum and a_bwd(i) are in the continuation set)
3. Use τ for positions 0..n-1, construct e_n fresh (matching GHR93 exactly)

This IS the GHR93-faithful approach. The current code's shortcut (d = a_bwd(n)) was architecturally incorrect.

### Effort estimate

| Component | Lines |
|-----------|-------|
| Redefine d as infimum | 60-100 |
| SplitPointProps: hd_eq_an → hd_le_an | 10 |
| Case I fixes | 10-20 |
| Strategy restrict rewrite | 80-120 |
| Remove d_consistency (now trivial) | -160 |
| Case II restructure | 300-500 |
| Claim 1 proof (with rank r+1) | 60-100 |
| **Total net** | **~360-690** |

### Dependency on rank embedding

The Claim 1 proof STILL needs rank r+1 (to prove the response = d̄). The rank embedding infrastructure already exists. The h_fwd_r1 parameter propagation (done in commit edee7e956) is still needed.

So the correct path is: infimum redefinition + rank embedding (BOTH), not either/or.

---

## Summary

| Statement | Status |
|-----------|--------|
| d_consistency with d = a_bwd(n) | UNPROVABLE (d may ≠ d̄) |
| d_consistency with d = d̄ | PROVABLE via Claim 1 |
| Infimum redefinition is "wasted effort" | WRONG (it's necessary) |
| Rank embedding alone suffices | WRONG (also need infimum) |
| Case II restructure is needed | CORRECT (~300-500 lines) |
