# Phase 1 Handoff: K=0 Sorry Chain Discovery

## Immediate Next Action
New research dispatch needed to resolve the zone-3 existential transfer. The mathematical argument needs to be identified before implementation can proceed. Key question: how does Rabinovich's original proof handle the "between-zone" witness placement at the base case?

## Current State
- Phase 1: BLOCKED -- sorry chain analysis revealed 3 additional critical-path sorries beyond the 2 identified in the plan
- Build status: unchanged (clean, existing sorries remain)
- No Lean files modified (reverted incomplete implementation attempt)
- Plan file updated with BLOCKED status and detailed blocker documentation

## Key Decisions
None made -- all approaches were analyzed but none proved viable.

## Critical Discovery: Extended Sorry Chain at K=0

The plan (v18) identifies lines 869 and 964 as the SOLE critical-path sorry sites. Implementation analysis reveals this is INCORRECT. The full sorry chain at K=0 is:

### Sorry Chain
```
prior_nonconstenv_2var_agree_until (K=0)
  -> h_agree_env (line 869/1102) [SORRY #1]
  -> prior_exist_transfer_bidir (d=1, r=2)
    -> zone_compatible_witness (d=1, r=2, line 647) [SORRY #2]
      -> nf_eval_from_lower_agree (d=0, line 507) [SORRY #3]
```

All three sorries reduce to the same fundamental problem: depth-0 existential transfer in the "between" zone.

### Why the sorry at line 1102 alone is insufficient
Even if h_agree_env at K=0 is proved (removing sorry #1), the subsequent code calls `prior_exist_transfer_bidir` at d=1, which calls `zone_compatible_witness` at d=1 (sorry #2), which calls `nf_eval_from_lower_agree` at d=0 (sorry #3).

## Analysis of Approaches Tried

### Approach 1: Direct Zone Decomposition
- Zones 1,2,4,5 (w not between t and x): transfer via `exist_transfer_from_full_agree` from h_x or h_t. Works correctly.
- Zone 3 (t < w < x): requires finding w' in (t', x') in N. The 2-var transfers from h_t and h_x give y_t > t' and y_x < x' with matching predicates, but y_t may be >= x' and y_x may be <= t'.
- Result: Zone 3 not resolved.

### Approach 2: Prior-UZ/SZ Squeeze
- From h_t transfer: y_t > t' with preds(w). Prior-UZ gives first occ r0 > t' of preds(w).
- From h_x transfer: y_x < x' with preds(w). Prior-SZ gives last occ r1 < x' of preds(w).
- Need: r0 < x' or r1 > t'.
- Counter-scenario: r0 >= x' AND r1 <= t' -- no preds(w) point in (t', x'). This scenario is consistent with the 2-var transfers (y_t can be above x', y_x can be below t').
- Result: Cannot prove r0 < x' or r1 > t' from the available hypotheses alone.

### Approach 3: VecEA Bracket Translation
- Encode zone-3 existential as VecEA2 holdsLeft.
- Translate to temporal formula A.
- Show A holds at t in M (from the zone-3 witness w).
- Show A holds at t' in N (from the depth-1 2-var transfer via h_t).
- But VecEA2.holdsLeft finds a z1 > t' with preds(x) anywhere, not at x'. The bracket witness is in (t', z1), not (t', x').
- Result: Gives a witness with correct predicates but NOT in the correct interval relative to x'.

### Approach 4: Depth-1 2-var Transfer
- Transfer depth-1 2-var NF at [w,t] via h_t at d=1: get z' > t' with matching depth-1 NF.
- From depth-1 NF's 3-var quantifier: exists v' > z' with preds(x).
- If z' < x': done. If z' >= x': stuck (same as approach 2).
- Result: Same fundamental limitation -- no way to guarantee z' < x'.

### Approach 5: Restructure K=0 Proof to Bypass h_agree_env
- Bypass h_agree_env + prior_exist_transfer_bidir entirely.
- Prove depth-2 2-var agreement directly from h_x, h_t at depth 2.
- Requires depth-1 3-var existential transfer, which needs 2-var env agreement at depth 1, which is h_agree_env. CIRCULAR.
- Result: Same circularity as the original approach.

## Root Cause Analysis

The fundamental issue is that the "between" constraint t < w < x is a 3-VARIABLE condition involving w, x, and t simultaneously. The NF framework only provides 2-variable projections: [w,t] and [w,x]. The 2-variable projections cannot encode the joint constraint because w, x, and t are three separate points.

The Prior-UZ/SZ axioms provide first/last occurrence localization, but this localization is relative to a SINGLE endpoint (t' or x'), not to both simultaneously. There is no Prior axiom that directly constrains the structure of the INTERVAL (t', x') -- only the future/past structure from each endpoint.

## Recommendations for Next Dispatch

### Option A: Fix the Mathematical Argument (Research)
Research Rabinovich's original paper more carefully. The zone-3 case at the base level must use a different argument. Possible leads:
1. The paper may use an induction on the NUMBER of predicate types for the base case
2. The paper may use a density/discreteness argument specific to the Reynolds construction
3. The paper may handle the base case using the full EF-game argument rather than NF transfer
4. The Kamp-style "saturation" argument may provide the missing piece

### Option B: Restructure the Proof Architecture
Instead of filling the sorry at the current location, restructure PriorComposition.lean so that:
1. The K=0 case uses a SEPARATE theorem with a different proof strategy
2. This theorem proves depth-2 2-var agreement directly
3. The proof uses a mechanism that doesn't route through zone_compatible_witness
4. Potentially: merge the 3 sorry sites into a single "depth-0 base case" lemma

### Option C: Fix All Three Sorries Bottom-Up
If the zone-3 transfer can be proved at depth 0, then:
1. Fix nf_eval_from_lower_agree at d=0 (line 507) -- the root cause
2. Fix zone_compatible_witness at d=0 AND d=1 (lines 642, 647) -- uses (1)
3. Fix h_agree_env at K=0 (lines 869, 964) -- the existing sorry sites
This is the most invasive but most complete approach.

## Sorry Inventory
| File | Line | Statement | Assumption | Why Deferred | Next Dispatch |
|------|------|-----------|------------|--------------|---------------|
| PriorComposition.lean | 507 | nf_eval_from_lower_agree d=0 | Depth-0 existential transfer | Zone-3 between-endpoint transfer not proved | Research zone-3 argument |
| PriorComposition.lean | 555 | nf_eval_from_lower_agree n=0 | Degenerate n=0 case | Not on K=0 critical path | Low priority |
| PriorComposition.lean | 642 | zone_compatible_witness d=0 | Depth-0 witness placement | Zone-3 same problem | Same as line 507 |
| PriorComposition.lean | 647 | zone_compatible_witness d=1 | Depth-1 witness + d=0 upgrade | Needs nf_eval_from_lower_agree d=0 | Same as line 507 |
| PriorComposition.lean | 658 | zone_compatible_witness d>=2 r=0 | r=0 degenerate case | Not on K=0 critical path | Low priority |
| PriorComposition.lean | 869 | h_agree_env K=0 Until | Depth-1 2-var agreement | Zone-3 same problem | Same as line 507 |
| PriorComposition.lean | 964 | h_agree_env K=0 Since | Depth-1 2-var agreement | Mirror of line 869 | Same as line 507 |
