# D-Consistency Implementation Strategy

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-21
**Session**: sess_1779410199_833717
**Focus**: How to implement `d_consistency_left` and `d_consistency_right` (lines 1103, 1136 of ExpressivenessGeneral.lean)

---

## 1. What GHR93 Claim 1 Actually Says

### Source

GHR93 (Gabbay, Hodkinson, Reynolds, 1993), p.116 (Section 8, Theorem 6 proof).
GHR94 (same authors, 1994), Chapter 12, p.442 (Theorem 12.8.15 proof).

### Statement

> **Claim 1.** Consider a play of the game G_{m;r'}(M, xy; N, x'y') for arbitrary r' > r, m >= 1 in which Duplicator uses a winning strategy. Let Spoiler begin by choosing c plus m-1 other points, and let Duplicator's response to c be d (plus m-1 other points). Then d = d-bar.

Where:
- `c = inf { t in [x,y] : M |= C(u) for all u in (t, y) }` (infimum in M_r)
- `d-bar = inf { t in [x',y'] : N |= C(u) for all u in (t, y') }` (infimum in N_r)
- `C = X_{(a_n, y')}` is the rank-r formula characterizing the interval type of (a_n, y')

### Proof in GHR93 (3 lines)

1. **d <= d-bar**: The rank-(r+1) formula C' = not-C or K^-(not-C) satisfies M_r |= C'(c). By formula transfer (winning condition), N_r |= C'(d). This forces d <= d-bar.

2. **d-bar <= d**: If d < d-bar, then there exists d' in (d, y') with N |= not-C(d'). Spoiler challenges at d'. Duplicator has no winning response (she needs b in [x,y] with M |= not-C(b), but C holds on (c, y) in M). Contradiction.

3. **Conclusion**: d = d-bar.

---

## 2. How d Is Characterized in the Lean Codebase

### Current State

In ExpressivenessGeneral.lean:
- **d** is defined as `a_bwd(n)` -- Spoiler's last backward selection (line 1254)
- `hd_eq_an : d = a_bwd ⟨n, by omega⟩ := rfl` (line 1256)
- The forward game (Round 2) gives c as a matching point (lines 1511-1587)

### Available Infrastructure (lines 107-1036, all sorry-free)

| Component | Lines | Purpose |
|-----------|-------|---------|
| `cont_holds` | 128-136 | Continuation predicate C(t) |
| `continuation_set` | 142-148 | S_C = {t in [x',y'] : C holds on (t,y')} |
| `continuation_set_nonempty` | 162-169 | y' is in S_C |
| `continuation_set_upward_closed` | 174-183 | S_C is upward-closed |
| `a_n_in_continuation_set` | 192-204 | a_n is in S_C |
| `inf_carrier_cut` | 153-156 | Cut definition for infimum |
| `infimum_gap` | 377-397 | Gap construction from cut |
| `infimum_gap_r_definable` | 904-1036 | The constructed gap is r-definable |
| `pigeonhole_definable_formula` | 624-801 | Extracts defining formula D from cofinal failures |
| `nf_determines_stavi_truth_depth` | 575-610 | NF at depth 2*r determines Stavi truth |

### What Is Sorry'd

| Location | Theorem | Purpose |
|----------|---------|---------|
| Line 1103 | `d_consistency_left` | Response at position n = d (c at last position) |
| Line 1136 | `d_consistency_right` | Response at position 0 = d (c at first position) |
| Line 1466 | `h_pt_xc_w` degenerate | Point in [x,c] when x=c and c is gap |
| Line 1483 | `h_pt_cy_w` degenerate | Point in [c,y] when c=y and c is gap |
| Line 1587 | Gap case of c | Finding c when d is a gap (requires Lemma 9) |

---

## 3. Exact Type Signature of `d_consistency_left`

```lean
private theorem d_consistency_left {sig : MonadicSignature}
    {atomMap : Formula → sig.preds} {n r : Nat}
    {M N : OrderedMonadicStructure sig}
    {x y : ExtendedCarrier M atomMap r}
    {x' y' : ExtendedCarrier N atomMap r}
    {c : ExtendedCarrier M atomMap r}
    {d : ExtendedCarrier N atomMap r}
    (hxy : x ≤ y) (hx'y' : x' ≤ y')
    (hc_interval : inClosedInterval x y c)
    (hd_interval : inClosedInterval x' y' d)
    (hcd_form : ∀ (A : StaviFormula), stavi_depth A ≤ r →
      (stavi_temporal_truth_mu M atomMap r c A ↔
       stavi_temporal_truth_mu N atomMap r d A))
    (hcd_gp : (IsPoint c ↔ IsPoint d) ∧ (IsGap c ↔ IsGap d))
    (hcd_boundary : (x = c ↔ x' = d) ∧ (c = y ↔ d = y'))
    (h_fwd : ghr93_duplicator_wins M N atomMap (n + 1) r x y x' y')
    (h_pt : ∃ (p : N.carrier), inClosedInterval x' y' (extendPoint p)) :
    ∀ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
      (∀ i, inClosedInterval x y (a_pad i)) →
      a_pad ⟨n, by omega⟩ = c →
      ∀ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
        (∀ i, inClosedInterval x' y' (a'_full i)) →
        (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
          ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
            ghr93_winning_condition (n + 1)
              (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) →
        a'_full ⟨n, by omega⟩ = d
```

The `d_consistency_right` theorem is identical except:
- The boundary position is `⟨0, by omega⟩` instead of `⟨n, by omega⟩`
- c is placed at position 0 instead of position n

---

## 4. Available Hypotheses at the Call Site

When `d_consistency_left` is invoked (line 1339), the following have been established:

- `h_fwd : ghr93_duplicator_wins M N atomMap (4 + 3 * n) r x y x' y'`
- `h_mono_left : ghr93_duplicator_wins M N atomMap (1 + 3 * n + 1) r x y x' y'` (via round_mono)
- `d = a_bwd ⟨n, by omega⟩` (definitional)
- `hc_interval : inClosedInterval x y c`
- `hd_interval : inClosedInterval x' y' d`
- `hcd_form` : formula agreement between c and d
- `hcd_gp` : gap/point agreement
- `hcd_boundary` : boundary order correspondence
- `h_pt` : existence of actual N-point in [x',y']
- `ha_bwd : ∀ i, inClosedInterval x' y' (a_bwd i)` (Spoiler's backward selections)
- `a_n_in_continuation_set` gives `d ∈ continuation_set x' y' d` (since d = a_bwd(n))

### How `d_consistency_left` Is Consumed

In `ghr93_strategy_restrict_left` (EFGames.lean:2929), the theorem is called with a SPECIFIC `a_pad` of the form:
```
a_pad(i) = a(i)  for i < n     (elements from [x,c])
a_pad(n) = c                    (the boundary)
```

So ALL elements of a_pad are in [x,c] (subset of [x,y]), and the last element is c.

---

## 5. Implementation Strategy Assessment

### Option I: Direct Uniqueness Argument (RECOMMENDED)

**Key Insight**: The statement does NOT require computing an infimum. It requires showing that if a'_full satisfies the winning condition with c at position n, then a'_full(n) = d.

**Available facts at the conclusion of a play where a_pad(n) = c**:
1. `a'_full(n) ∈ [x', y']` (from ha'_full)
2. Formula agreement: for all A with depth <= r, `stavi_temporal_truth_mu M atomMap r c A ↔ stavi_temporal_truth_mu N atomMap r (a'_full n) A` (from winning condition's formula_agreement at position n+1)
3. Gap/point agreement: `IsPoint c ↔ IsPoint (a'_full n)` (from winning condition's gap_point_agreement at position n+1)
4. Same order relative to x', y': `(x = c ↔ x' = a'_full n)` and `(c = y ↔ a'_full n = y')` (from same_order_type at indices 0/n+1 and n+1/n+2)

**Compare with d's properties** (from hcd_form, hcd_gp, hcd_boundary):
1. `d ∈ [x', y']`
2. Formula agreement: for all A with depth <= r, `stavi_temporal_truth_mu M atomMap r c A ↔ stavi_temporal_truth_mu N atomMap r d A`
3. Gap/point agreement: `IsPoint c ↔ IsPoint d`
4. Boundary correspondence: `x = c ↔ x' = d` and `c = y ↔ d = y'`

**Both d and a'_full(n) have**:
- The same formula-type as c (hence the same formula-type as each other)
- The same gap/point status as c
- The same boundary order correspondence with x', y'

**To conclude d = a'_full(n)**, we need: two elements of ExtendedCarrier with the same rank_type, same gap/point status, and same position relative to endpoints x', y' must be equal.

**This is the core lemma needed**: uniqueness of elements with identical rank-r profile and identical boundary position within [x', y'].

### The Uniqueness Lemma

```lean
private theorem extended_carrier_element_unique
    {d t : ExtendedCarrier N atomMap r}
    (hd : inClosedInterval x' y' d)
    (ht : inClosedInterval x' y' t)
    (hform : ∀ A, stavi_depth A ≤ r →
      (stavi_temporal_truth_mu N atomMap r d A ↔
       stavi_temporal_truth_mu N atomMap r t A))
    (hgp : (IsPoint d ↔ IsPoint t) ∧ (IsGap d ↔ IsGap t))
    (hbdry : (x' = d ↔ x' = t) ∧ (d = y' ↔ t = y')) :
    d = t
```

**Why this should be true**: In ExtendedCarrier, elements are either points (from N.carrier) or r-definable gaps. Two elements with the same rank_type and same position relative to all other elements are distinguishable ONLY if there is a formula of rank <= r that separates them. If they agree on all rank-r formulas AND have the same position relative to x' and y', they must be equal.

**Proof approach (by cases)**:

**Case 1: Both are points** (d = extendPoint p, t = extendPoint q).
- Same formula truth means same `stavi_temporal_truth` for all depth-r formulas.
- Same NF characteristic at depth 2*r (by nf_determines_stavi_truth_depth).
- Position argument: if p != q, WLOG p < q, then there is a formula distinguishing them (the formula "there exists something between x' and me" could differ). But actually, two points with the same rank_type CAN be distinct in ExtendedCarrier -- they can have the same type but occupy different positions.

**Problem**: Same formula-type does NOT imply equality for points. Two points can have the same rank_type but be distinct (e.g., all points in a dense order with no definable structure have the same type).

### Why Direct Uniqueness Fails for Points

If [x', y'] contains two points p < q with identical rank_type (same truth values for all depth-r formulas), then:
- Both satisfy formula agreement with c
- Both are points (same gap/point status)
- But d = p and a'_full(n) = q (different!)

**This means the uniqueness approach needs something beyond rank_type**.

### What GHR93 Actually Uses: The Infimum Argument

The paper's proof works precisely because d is the infimum of S_C, and this gives an ASYMMETRIC characterization: d is the leftmost element satisfying C' = not-C or K^-(not-C). Any other element with the same formula-type that is further right would violate the infimum property.

**Critical realization**: The existing hypotheses `hcd_form` + `hcd_gp` + `hcd_boundary` are NOT sufficient to prove d_consistency in isolation. We need the additional fact that d is the INFIMUM of continuation_set.

### Revised Strategy: Use the Infimum Property of d

Since `d = a_bwd(n)` and `a_n_in_continuation_set` gives `a_bwd(n) ∈ continuation_set x' y' (a_bwd n)`, the question becomes: is d = a_bwd(n) the infimum of this set?

**Answer**: Not necessarily. The continuation set for `a_n = a_bwd(n)` has d = a_bwd(n) as a MEMBER (by `a_n_in_continuation_set`), but the infimum could be strictly below a_bwd(n). In the paper, d-bar (the infimum) can be different from a_n.

**However**, in the current architecture where d := a_bwd(n), we need to prove a'_full(n) = a_bwd(n). Since a_bwd(n) is just some element of [x', y'], and a'_full(n) is some response to c, there is no reason they should be equal.

### Option I is NOT directly viable without the infimum.

---

## 6. Correct Implementation Path: Restricted D-Consistency

### Key Insight from Report 18 (Section 8, "Backup")

The `ghr93_strategy_restrict_left` theorem constructs a SPECIFIC `a_pad`:
```
a_pad(i) = a(i)  for i < n     (from [x,c])
a_pad(n) = c                    (boundary)
```

It then feeds this to the (n+1)-round strategy `h` (which is `ghr93_duplicator_wins M N atomMap (n+1) r x y x' y'`). The strategy responds with `a'_full`, and d-consistency asserts `a'_full(n) = d`.

**The same strategy `h` was used in `obtain_split_point_props` to define d in the first place** (through the chain: `h_fwd` -> `h1` -> play with x -> get response). But d is currently defined as `a_bwd(n)`, NOT from the forward strategy.

### The Fix: Redefine d from the Forward Strategy

**The correct approach (matching GHR93)** is:

1. Define `continuation_set_d := continuation_set x' y' (a_bwd n)` -- uses existing infrastructure
2. Show `a_bwd(n) ∈ continuation_set_d` -- already proved (`a_n_in_continuation_set`)
3. Define d as the INFIMUM of continuation_set_d -- case split on whether infimum is a point or gap
4. Show `d ≤ a_bwd(n)` -- because a_bwd(n) is in the set
5. Show `d_consistency` using the infimum property

**But this requires changing d away from a_bwd(n)**, breaking `hd_eq_an : d = a_bwd ⟨n, by omega⟩` which is used in ~30 locations in Case II.

### Option C: Classical.choice Canonical Strategy (from Report 18, Section 4)

Define d as the response of a canonical (deterministically chosen) forward strategy to c. This makes d-consistency trivial for THAT strategy. But then:
- We need `d = a_bwd(n)` for Case II (which uses hd_eq_an at 22 locations)
- Proving d = a_bwd(n) IS the Claim 1 argument again

### THE ACTUALLY CORRECT APPROACH: Keep d = a_bwd(n), Add Infimum Hypothesis

Report 18 Section 4 (Option I) recommends: prove `claim1_d_consistency` as a standalone theorem, keep d = a_bwd(n), and close the sorries by invoking it.

**The key is**: d = a_bwd(n), and a_bwd(n) came from some SPECIFIC play of the backward game. The Claim 1 argument shows that for ANY winning forward play with c at boundary, the response equals the infimum of continuation_set. Since a_bwd(n) is in continuation_set and the infimum is <= a_bwd(n), we need to show infimum = a_bwd(n), i.e., a_bwd(n) is ITSELF the infimum.

**But a_bwd(n) is arbitrary** -- it's Spoiler's choice. It need not be the infimum.

### THE REAL RESOLUTION

Looking back at the proof structure:

1. Spoiler picks a_bwd(0), ..., a_bwd(n) in (x', y')
2. We set d = a_bwd(n) and find c by playing the forward strategy
3. D-consistency asks: for any forward play with c at boundary, the response at boundary = d = a_bwd(n)

But in GHR93, d-bar (the infimum) is a FIXED element determined by M, N, and the formula C. It does NOT depend on Spoiler's choices. The proof then shows:
- d-bar <= a_n (because a_n is in S_C)
- Cases I-IV use d-bar (not a_n) as the split point

**The current code conflates d (the split point) with a_bwd(n) (Spoiler's last pick).** In GHR93 these are DIFFERENT: d-bar <= a_n always, but d-bar = a_n only when a_n happens to be the infimum.

**However**, the current SplitPointProps architecture (used by Cases I and II at 22+ locations) depends on `hd_eq_an : d = a_bwd(n)`. Changing this would require rewriting Case II.

### THE PRAGMATIC SOLUTION

**Reframe d-consistency**: Instead of proving "every response = a_bwd(n)", prove "every response = every other response" (uniqueness of responses), AND "the specific response that defined d in obtain_split_point_props equals a_bwd(n)" (which is trivially true since d IS defined as a_bwd(n)).

But the call site at line 1339 feeds `d_consistency_left` into `ghr93_strategy_restrict_left`, which uses it with an ARBITRARY `a_pad` satisfying `a_pad(n) = c` and all in [x,y]. The strategy gives some a'_full, and we need a'_full(n) = d = a_bwd(n). This is the full Claim 1.

---

## 7. RECOMMENDED IMPLEMENTATION (Option I from Report 18)

After extensive analysis, Report 18's Option I remains the ONLY viable approach that avoids rewriting Case II:

### Step 1: Prove all achievable responses are equal (the core of Claim 1)

Define:
```lean
private def achievable_response_set
    (h_fwd : ghr93_duplicator_wins M N atomMap (n + 1) r x y x' y')
    (c : ExtendedCarrier M atomMap r) (hc : inClosedInterval x y c)
    (boundary_pos : Fin (n + 1))  -- which position c occupies
    : Set (ExtendedCarrier N atomMap r) :=
  { t | ∃ (a_pad : Fin (n + 1) → ExtendedCarrier M atomMap r),
    (∀ i, inClosedInterval x y (a_pad i)) ∧
    a_pad boundary_pos = c ∧
    ∃ (a'_full : Fin (n + 1) → ExtendedCarrier N atomMap r),
      (∀ i, inClosedInterval x' y' (a'_full i)) ∧
      (∀ (b' : N.carrier), inClosedInterval x' y' (extendPoint b') →
        ∃ (b : M.carrier), inClosedInterval x y (extendPoint b) ∧
          ghr93_winning_condition (n + 1)
            (game_tuple x y a_pad b) (game_tuple x' y' a'_full b')) ∧
      a'_full boundary_pos = t }
```

### Step 2: Show d is achievable

Since d = a_bwd(n) and the forward strategy h_fwd produces SOME response when we feed it a_pad with a_pad(n) = c, we need d to be one such response. But d comes from a_bwd (Spoiler's backward choice), not from a forward play.

**Critical gap**: d = a_bwd(n) is chosen by Spoiler, not by the forward strategy. There is no direct connection between a_bwd(n) and any forward strategy response.

### Step 3: The Real Fix

**The d in SplitPointProps should be defined from the forward strategy's response, not from a_bwd(n).**

But changing this breaks hd_eq_an which is used 22 times in Case II.

**The bridge**: Instead of d = a_bwd(n) directly, we need:
1. Define d' from the forward strategy (play with c, get response d')
2. PROVE d' = a_bwd(n) (this IS Claim 1 applied to the specific play)
3. Set d = d' (= a_bwd(n) by step 2)

But step 2 is circular: proving d' = a_bwd(n) IS the d-consistency theorem itself.

---

## 8. FINAL RESOLUTION: The Infimum Route

After careful analysis, the ONLY sound approach is:

### Architecture Change

1. **Redefine d as the infimum of continuation_set** (not a_bwd(n))
2. **Prove d <= a_bwd(n)** (because a_bwd(n) is in the set)
3. **Replace hd_eq_an with hd_le_an** in SplitPointProps
4. **Prove d = a_bwd(n) in Case II's specific context** (where all selections > d, so the infimum argument gives equality)
5. **Update Case II** to use this conditional equality

### Why This Works

In Case II, the hypothesis is "all a_i >= d" (h_no_split) AND "a_n is a point". When all a_i > d and d is the infimum of S_C:
- d <= a_n (from infimum <= member)
- In fact d < a_n (since d is the infimum and all points are strictly above d in Case II)

Case II does NOT actually need d = a_n. It needs:
- `d ∈ [x', y']` (from hd_interval)
- `IsPoint d` or the ability to derive properties from d's gap/point status
- Ordering of a_bwd(i) relative to d (from h_no_split: d <= a_bwd(i))

Looking at the 22 usage sites of `hd_eq_an` in Case II: they use `rw [← hd_eq_an]` to replace `a_bwd(n)` with `d` in game_tuple expressions. This rewriting is needed because sigma/tau use `d` as endpoint, and the game tuples use `a_bwd` for selections. If d = a_bwd(n), then at position n in the game tuple, the selection equals the endpoint d.

**In the GHR93 paper's Case II**: all selections a_0, ..., a_n lie in (d, y'). In particular a_n > d. The proof uses tau on [d, y'] and the selections lie IN [d, y']. The fact that a_n > d (strictly) means a_bwd(n) != d in this case.

**However**, the current Case II code uses `hd_eq_an : d = a_bwd(n)` at line 1699 to derive `IsPoint d` from `IsPoint (a_bwd n)`. If d is the infimum and d < a_n, then d might be a gap even when a_n is a point.

### Estimated Impact

| Change | Lines | Difficulty |
|--------|-------|------------|
| Redefine d as infimum in obtain_split_point_props | 60-100 | Medium |
| D-consistency proof (trivial: infimum IS the response) | 30-50 | Low |
| SplitPointProps: hd_eq_an -> hd_le_an + hd_eq_an_case2 | 20 | Low |
| Case I fixes (2 sites: replace hd_eq_an with hd_le_an) | 10 | Low |
| Case II: add hypothesis `hd_eq_an_case2` or restructure | 50-150 | High |
| Total | 170-330 | Medium-High |

---

## 9. PRAGMATIC ALTERNATIVE: Sorry-Barrier Acceptance

Given the analysis above, Option I from Report 18 (keep d = a_bwd(n), prove uniqueness of responses) remains the recommended path IF the uniqueness argument can be made to work. The key question is whether uniqueness holds.

### Why Uniqueness Actually Works Here

Re-reading the d_consistency_left hypotheses more carefully:

```
hcd_form : ∀ A, stavi_depth A ≤ r →
  (stavi_temporal_truth_mu M atomMap r c A ↔ stavi_temporal_truth_mu N atomMap r d A)
hcd_boundary : (x = c ↔ x' = d) ∧ (c = y ↔ d = y')
```

These say: c and d have the SAME formula-type AND the same boundary position. Now consider any response t = a'_full(n):

From the winning condition at position n (which is game_tuple index n+1):
```
∀ A, stavi_depth A ≤ r →
  (stavi_temporal_truth_mu M atomMap r c A ↔ stavi_temporal_truth_mu N atomMap r t A)
```
And from same_order_type at indices 0/(n+1) and (n+1)/(n+2):
```
(x = c ↔ x' = t) ∧ (c = y ↔ t = y')
```
And gap/point: `IsPoint c ↔ IsPoint t`.

So BOTH d and t satisfy:
1. Same formula-type as c
2. Same boundary position as c (relative to x', y')
3. Same gap/point status as c

Now: d and t have the same formula-type (transitively through c), same boundary position relative to x' and y', same gap/point status. The question is: does this force d = t?

**The answer depends on the structure of [x', y']**:

- If d is at the boundary (d = x' or d = y'): then t must also be at the boundary (from boundary correspondence), so t = d.
- If d is a point in the interior: then t is also a point in the interior with the same formula-type. Two interior points with the same rank_type need NOT be equal.
- If d is a gap in the interior: then t is also a gap with the same formula-type. Two gaps with the same formula-type but at different positions differ in their cuts, hence differ in some formula (the defining formula has a different truth value above vs. below each gap).

**For gaps**: Two r-definable gaps with identical formula truth values for ALL depth-r formulas must have identical cuts (because the cut IS determined by the formulas). Therefore identical gaps.

**For points**: Two points with identical formula truth values for all depth-r formulas could be distinct -- the formula language at rank r might not separate them. This is the problem case.

**However**, the same_order_type from the winning condition gives MORE than just boundary position. It gives the position relative to ALL other elements in the game tuple (x', a'_full(0), ..., a'_full(n-1), t, b', y'). In particular:
- t's position relative to b' (for EVERY point challenge b') matches c's position relative to the corresponding M-side point b.

This additional constraint (for all possible b') is extremely strong and essentially determines t's position in the linear order uniquely among elements with the same formula-type.

### The Proof Outline for D-Consistency (Direct Approach)

```
d_consistency_left proof:
1. Let t := a'_full ⟨n, by omega⟩ (the response at boundary)
2. From winning condition, extract:
   - formula_agreement: stavi_truth_mu M r c A ↔ stavi_truth_mu N r t A
   - gap_point: IsPoint c ↔ IsPoint t  
   - same_order_type at indices 0/(n+1): (x < c ↔ x' < t) ∧ (x = c ↔ x' = t)
   - same_order_type at indices (n+1)/(n+2): (c < y ↔ t < y') ∧ (c = y ↔ t = y')
3. From hcd_form, we have: stavi_truth_mu N r d A ↔ stavi_truth_mu N r t A (for all A)
4. From hcd_boundary and step 2: (x' = d ↔ x' = t) ∧ (d = y' ↔ t = y')
5. Case split:
   a. d = x': then t = x' = d. Done.
   b. d = y': then t = y' = d. Done.
   c. d is a gap in (x', y'): t must also be a gap with same formula-type.
      Both gaps have the same cut (proved via formula-definability). Hence d = t.
   d. d is a point in (x', y'): t must also be a point with same formula-type.
      HARD CASE. Need: same formula-type + same boundary position => same point.
      Use: for EVERY b' in [x', y'] ∩ N, the winning condition gives
        (c < extendPoint b ↔ t < extendPoint b') and (c > extendPoint b ↔ t > extendPoint b')
      Compare with d: for EVERY b' in [x', y'] ∩ N, there exists a play where d appears
      as the response to c and the same ordering constraints hold for d vs b'.
      Therefore: for every actual N-point b' in [x', y'], (d < extendPoint b' ↔ t < extendPoint b').
      This means d and t have the same position in the linear order relative to ALL actual points.
      In a linear order, an element is determined by its position relative to all other elements.
      Hence d = t.
```

### Step 5d Detail: Points with Same Relative Position

If d and t are both points (d = extendPoint p_d, t = extendPoint p_t) and for every actual N-point b' in [x', y']:
```
extendPoint p_d < extendPoint b'  ↔  extendPoint p_t < extendPoint b'
extendPoint p_d = extendPoint b'  ↔  extendPoint p_t = extendPoint b'
```

Taking b' = p_d: `p_d < p_d ↔ p_t < p_d` gives `False ↔ p_t < p_d`, so NOT (p_t < p_d).
Taking b' = p_t: `p_d < p_t ↔ p_t < p_t` gives `p_d < p_t ↔ False`, so NOT (p_d < p_t).

From NOT (p_t < p_d) and NOT (p_d < p_t): p_d = p_t (by linear order trichotomy).
Hence d = extendPoint p_d = extendPoint p_t = t.

### Step 5c Detail: Gaps with Same Formula-Type

If d and t are both gaps with the same formula truth values (for all A with depth <= r), then their cuts must agree. In ExtendedCarrier, a gap g has g.cut which determines its position. Two gaps with the same cut are equal (by gap extensionality in `Gap`).

The cut of an r-definable gap is determined by its defining formula. If two gaps agree on all formulas of depth <= r, they have the same definability profile, hence the same cut. Formally: for any carrier point p, `p ∈ g_d.cut ↔ p ∈ g_t.cut` follows from the formula truth agreement (since membership in the cut corresponds to being below the gap, which is characterizable by formulas of appropriate depth).

**This needs**: a lemma connecting gap cut membership to formula truth. The key is:
- `extendPoint p ≤ Sum.inr g` iff `p ∈ g.cut` (from the ExtendedCarrier order definition)
- `extendPoint p ≤ d` can be characterized by formulas (since ordering in ExtendedCarrier is formula-characterizable at the right depth)

Actually, the simpler argument is: in the winning condition, same_order_type gives:
```
∀ b' : N.carrier, inClosedInterval x' y' (extendPoint b') →
  (game_tuple ... b at index n+1) < (game_tuple ... b' at index n+2)
  ↔ (game_tuple' ... at corresponding indices)
```

Wait, the Round 2 challenge with b' directly gives the ordering. Taking b' = p (any carrier point in [x', y']):
- `extendPoint p < d ↔ extendPoint p_response < c` (from some play witnessing d)
- `extendPoint p < t ↔ extendPoint p < t` (tautology, from the CURRENT play's same_order_type)

The key is: from the current play's winning condition with b' = p, we get:
```
c < extendPoint b ↔ t < extendPoint p
```
(where b is Duplicator's response to b' = p in M).

From the play witnessing d (when d was constructed from the forward strategy in obtain_split_point_props), we similarly get constraints. But since d = a_bwd(n) and was NOT constructed from the forward strategy, we don't have a corresponding play.

**The actual proof uses h_pt directly**: h_pt gives `∃ p, inClosedInterval x' y' (extendPoint p)`. We instantiate the winning condition with this p to get:
```
∃ b, inClosedInterval x y (extendPoint b) ∧
  ghr93_winning_condition (n+1) (game_tuple x y a_pad b) (game_tuple x' y' a'_full p)
```

From same_order_type in this play: `a_pad(n) < extendPoint b ↔ a'_full(n) < extendPoint p`
i.e., `c < extendPoint b ↔ t < extendPoint p`.

For d: from hcd_boundary, `c < y ↔ d < y'` and `x < c ↔ x' < d`. But we need `d < extendPoint p ↔ t < extendPoint p` for EVERY p.

**This is achievable via the formula characterization**: For any carrier point p in [x', y'], "x < extendPoint p" is characterizable by some rank-r formula (via the Stavi formula infrastructure). Since d and t agree on all rank-r formulas, they agree on ordering with p.

**Actually simpler**: Just use the winning condition. The winning condition for the current play gives same_order_type for ALL indices. At the Round 2 stage with b' = p_d (the carrier point that IS d, if d is a point):
```
hwin (p_d) (inClosedInterval from hd_interval) gives:
  ∃ b, ... ∧ game_tuple ordering at (n+1, n+2):
  a_pad(n) < extendPoint b ↔ a'_full(n) < extendPoint p_d
  i.e., c < extendPoint b ↔ t < d   [since d = extendPoint p_d]
```

This gives us the ordering relationship between t and d from the CURRENT play. Combined with the symmetric argument (play Round 2 with p_t if t = extendPoint p_t), we get d = t.

---

## 10. Concrete Implementation Plan

### Phase 1: Auxiliary Lemma (~30-40 lines)

```lean
-- When d is a point, use Round 2 with p_d to derive ordering of t vs d
private lemma d_consistency_point_case ...
```

### Phase 2: Gap Case Auxiliary (~30-40 lines)

```lean
-- When d is a gap, use formula agreement to show t = d
-- (Two gaps with same formula-type and same boundary position are equal)
private lemma d_consistency_gap_case ...
```

### Phase 3: Main d_consistency_left (~40-60 lines)

```lean
private theorem d_consistency_left ... := by
  intro a_pad ha_pad hc_last a'_full ha'_full hwin
  -- Extract properties of t = a'_full(n) from winning condition
  obtain ⟨p, hp⟩ := h_pt
  obtain ⟨b, hb, hcond⟩ := hwin p hp
  obtain ⟨hord, hgp_cond, hform_cond⟩ := hcond
  -- Case split on IsPoint d vs IsGap d
  rcases isPoint_or_isGap d with ⟨p_d, hp_d⟩ | ⟨g_d, hg_d⟩
  · -- Point case: play Round 2 with p_d to get ordering
    exact d_consistency_point_case ...
  · -- Gap case: formula agreement forces same cut
    exact d_consistency_gap_case ...
```

### Phase 4: d_consistency_right (~10 lines)

The right version is symmetric (c at position 0 instead of n). Either prove by symmetry or duplicate with the position flipped.

### Total Estimate: 110-150 lines

### Key Dependencies

1. **For the point case**: Need to play Round 2 with the specific point p_d (which IS d when d is a point). This requires `inClosedInterval x' y' (extendPoint p_d)` which follows from `hd_interval` and `hp_d : d = extendPoint p_d`.

2. **For the gap case**: Need a lemma that two gaps with identical formula truth and same boundary position are equal. This requires connecting formula truth to gap cut membership.

### Risk Assessment

- **Point case**: Low risk. The proof is clean: play Round 2 with p_d to get the ordering constraint, derive p_d = p_t via linear order trichotomy.
- **Gap case**: Medium risk. Requires connecting formula truth to cut membership. May need ~30 additional lines for the bridge lemma.
- **Overall**: 80% confidence this can be completed in 110-200 lines.

---

## 11. Summary Recommendation

**Strategy**: Direct uniqueness proof using Round 2 point challenges.

**Core insight**: The winning condition's Round 2 lets us probe the ordering of t = a'_full(n) against ANY actual point in [x', y']. When d is a point, probing with d itself forces t = d. When d is a gap, formula agreement forces same cut hence same gap.

**Advantages over infimum approach**:
- No changes to SplitPointProps or Case II (keeps hd_eq_an intact)
- No infimum computation infrastructure needed (already have it but don't need to USE it for d-consistency)
- Proof is self-contained (~150 lines)
- The continuation_set infrastructure (lines 107-1036) was needed for the GAP case of finding c (line 1587), not for d-consistency itself

**Disadvantages**:
- The gap case bridge lemma (formula truth -> cut equality) needs verification
- If the gap case fails, falls back to the full infimum route (~300 lines with Case II changes)

**Next implementation step**: Write `d_consistency_left` with the point case (trivial via Round 2) and the gap case (formula-to-cut bridge).
