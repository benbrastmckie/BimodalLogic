# Handoff: Task 93 Forward_F Deep Analysis

## Session: sess_1776180711_c675a9
## Date: 2026-04-14

## Status: PARTIAL (mathematical gap identified, architectural solution designed)

### Key Finding: The Enriched Chain Cannot Prove forward_F

After extensive analysis, I've identified a fundamental gap in the current chain
construction that PREVENTS proving `rr_fwd_chain_forward_F`.

**The Problem**: `enriched_fwd_step` uses `enriched_fwd_exists` which returns
`target in M' OR F(target) in M'` via BX11 fold. The BX11 fold can always
F-wrap the target (case 3 of BX11), so `target in M'` is NOT guaranteed.
The set S = {chi in sigma_list | F(chi) in chain(m)} is completely stable
(all F-formulas preserved at every step by the enriched step), which means
the "defect count decreases" argument in the plan comments is incorrect.

**Why It Fails**: At each step, the BX11 fold produces a compound where each
formula is either "direct" (chi in M') or "F-protected" (F(chi) in M').
Which formulas are direct vs F-protected depends on BX11 outcomes, which
are properties of the MCS (not controllable). The target might always be
F-protected if other formulas consistently have earlier witnesses.

### Root Cause Analysis

1. **BX11 fold gives disjunction, not conjunction**: `enriched_fwd_exists`
   returns `chi in M' OR F(chi) in M'`. We need `chi in M'` (no disjunction).

2. **enriched_resolving_seed_consistent guarantees both components**:
   If `F(A and B) in M`, then `{A, B} union g_content(M)` is consistent.
   Lindenbaum gives A IN M' AND B IN M'. This is the key tool that the
   current chain does NOT use at the step level.

3. **BX11 case 3 prevents guaranteed resolution**: When BX11 between
   F(target) and F(compound) gives case 3 (F(F(target) and compound)),
   the enriched_resolving_seed gives {F(target), compound} union g_content(M).
   Target is only F-protected, not direct.

4. **S is stable for the enriched chain**: Since all F-formulas are preserved
   at every step (either direct or F-protected), |S| never decreases.
   There is no monotone measure to use for well-founded recursion.

### Correct Approach: Ordered Defect-Discharge Chain

The chain must use `enriched_resolving_seed_consistent` (not `enriched_fwd_exists`)
at each step. This requires:

1. **find_earliest_witness**: Given F-defects in an MCS, use iterated BX11
   to find the formula whose witness comes earliest. For this formula,
   BX11 always gives case 1 or 2 (not case 3) against all other formulas.

2. **Guaranteed resolution**: Use enriched_resolving_seed_consistent with the
   earliest-witness formula as the first component. It's guaranteed to be
   in M' (since cases 1 and 2 put it as the first argument).

3. **F-protection for others**: The compound (second component) captures
   all other F-formulas. From compound in M': each other formula has
   F(chi) in M' (either direct or F-protected).

4. **Termination**: The key unsolved problem. The defect count might not
   strictly decrease because:
   - Non-defect formulas (chi in M, F(chi) in M) can become defects at M'
     (chi might not be in M', but F(chi) in M' from compound extraction)
   - The resolved formula can re-emerge as a defect at later steps

   Possible termination measures:
   a) |{chi in sigma_list | F(chi) in M, G(neg(chi)) not_in M}| -- but this equals |S| which is stable
   b) Lexicographic: (|D|, |{chi in D | chi has been resolved before}|)
   c) The "never-resolved" count: |{chi in S | chi has never appeared directly in any chain step}|
      This strictly decreases if at each step, a NEWLY resolved formula is chosen.

### Proposed Implementation Steps

1. Define `find_earliest_witness`:
   ```
   Given defects = [psi_1, ..., psi_k] with F(psi_i) in M for MCS M:
   Iterate BX11 pairwise. Track the "current earliest" candidate.
   Result: index j such that for all i != j, either
     F(psi_j and psi_i) in M (case 1) or
     F(psi_j and F(psi_i)) in M (case 2)
   ```

2. Define `discharge_fwd_step`:
   ```
   Given MCS M and sigma_list:
   defects = [chi in sigma_list | F(chi) in M, chi not_in M]
   if defects = []:
     M  (identity step)
   elif defects = [psi]:
     Lindenbaum({psi} union g_content(M))  (single defect, simple seed)
   else:
     j = find_earliest_witness(defects, M)
     compound = BX11 fold of all OTHER F-formulas (defects + non-defects)
     seed = {defects[j], compound} union g_content(M)
     Lindenbaum(seed)
   ```

3. Prove: at each step, the earliest-witness defect IS resolved (not F-wrapped)

4. Prove termination (this is the hard part)

5. Define identity tail after defects reach zero

6. Prove forward_F using: F(psi) in chain(t) -> psi in chain(s) for some s > t
   - Discharge region: F(psi) persists (compound preserves F-formulas).
     At some step, psi becomes the earliest witness and is resolved.
   - Identity tail: terminal is defect-free. F(psi) in terminal -> psi in terminal.
     chain(t+1) = terminal. s = t+1.

### Current File State

- `OrderedSeedConsistency.lean`: 0 sorry (complete)
- `RootScopedChain.lean`: 6 sorry
  - Line 790: `rr_fwd_chain_forward_F` -- THE MAIN BLOCKER
  - Line 816: `dd_fmcs_forward_F` (t < 0 case) -- depends on forward_F
  - Line 823: `dd_fmcs_backward_P` -- symmetric to forward_F
  - Line 876: `dd_bfmcs_restricted_tc` -- depends on forward_F + backward_P
  - Line 881: `dd_bfmcs_restricted_buc` -- requires step transfer (separate issue)
  - Line 886: `dd_bfmcs_restricted_fuc` -- requires step transfer (separate issue)

### Build Status

`lake build` succeeds. All sorry are in RootScopedChain.lean.

### Changes Made This Session

1. Added `h_nonempty` parameter to `dd_fmcs_forward_F` signature
2. Proved the t >= 0 case of `dd_fmcs_forward_F` (using `rr_fwd_chain_forward_F`)
3. Added detailed FIX comment explaining the mathematical gap
4. Extensive analysis documented in this handoff

### Dependency Graph of Sorries

```
rr_fwd_chain_forward_F (Nat chain)
  |
  v
dd_fmcs_forward_F (Int chain, t >= 0 case closed, t < 0 case open)
  |
  v
dd_bfmcs_restricted_tc (needs forward_F + backward_P for all families)
  |
  v
dd_countermodel -> bx_completeness

dd_fmcs_backward_P (symmetric, independent)
  |
  v
dd_bfmcs_restricted_tc

dd_bfmcs_restricted_buc (independent, needs step transfer)
dd_bfmcs_restricted_fuc (independent, needs step transfer)
```

### Mathematical References

- Burgess 1984: "Basic tense logic" -- original BX completeness
- Goldblatt 1992: "Logics of Time and Computation" -- chain construction
- Task 93 Research Report v13: Section 2.1-2.4
- OrderedSeedConsistency.lean: enriched_resolving_seed_consistent, temp_linearity_mcs
