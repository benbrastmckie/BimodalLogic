# Teammate C: Mathematical Resolution of Until Witness Containment

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Purpose**: Evaluate mathematical paths for resolving the Until witness containment issue in GHR93 Case II, and separately analyze sel_pn_ord derivation.

---

## Executive Summary

The core blocker: `untl_extract_witness` returns a witness z in the full `ExtendedCarrier M atomMap r`, not guaranteed in `[x, y]`. Five resolution paths are evaluated. Path 3 (Hybrid Approach) is the most feasible and already partially implemented. Path 1 (First-Witness-In-Range) is mathematically sound but requires significant infrastructure. Path 5 (SplitPointProps Extension) is the cleanest structural fix. Paths 2 and 4 are infeasible or inapplicable.

For `sel_pn_ord`, the current implementation already resolves this via `hord_left_sel_pn` from `tau_left`, making the GHR93 U(B,A)-based derivation unnecessary.

---

## Path 1: First-Witness-In-Range

**Verdict**: FEASIBLE (with significant effort)

### Mathematical Analysis

The claim is: if U(B, A) holds at ref_M (in [c, y]), then the Until witness z can be chosen in [c, y].

Let us examine what B = x_t_formula and A = x_interval_formula characterize:

- **B = X_{a_n}**: `stavi_temporal_truth_mu M atomMap r z B` iff `rank_type M atomMap r z = rank_type M atomMap r (resp_tau_e_n)` where resp_tau_e_n is the M-side image of a_n. This says z has the same rank-r type as resp_tau_e_n.

- **A = X_{(ref_N, a_n)}**: `stavi_temporal_truth_mu M atomMap r w A` iff there exists a mu-point v in the OPEN interval (ref_N, a_n) in N such that `rank_type M atomMap r w = rank_type N atomMap r v`. This characterizes M-points whose type matches some N-point in the interval.

**Key observation**: The characteristic formulas B and A are defined in terms of **rank_type**, which is a property of points in the extended carrier of whichever structure they live in. However, B(z) does NOT force z to be in [c, y]. B(z) only says z has the same rank-r type as some point -- this is a formula-level property, not a spatial/ordering constraint.

**The first-witness argument**: Consider S = {z in ExtendedCarrier M : z > ref_M, mu_holds z, B(z), and A holds on (ref_M, z)}. S is nonempty (by U(B,A)(ref_M)). If S has a minimum, call it z_0. Can we show z_0 is in [c, y]?

Unfortunately, no -- ExtendedCarrier M is generally not well-ordered (it is a dense linear order extended with gaps). There is no general "first witness" principle. Even with Zorn's lemma, the infimum of S need not be in S (it could be a gap point where B fails because gap points are not mu-points).

**Alternative first-witness argument for mu-points only**: Since B(z) requires mu_holds z (i.e., z is an actual carrier point), we could consider the set of carrier points p with extendPoint p > ref_M and B(extendPoint p). But carrier points are not necessarily well-ordered either (the carrier could be Q or R).

**Verdict on first-witness**: Not directly feasible without additional assumptions on the order structure (e.g., discreteness, well-foundedness). In the general case of arbitrary linear orders (which GHR93 covers), there is no first-witness principle.

### What x_t_correct and x_interval_correct Actually Guarantee

From CharacteristicFormula.lean (lines 384-390, 510-518):

```
x_t_correct u :
    stavi_temporal_truth_mu M atomMap r u (x_t_formula M atomMap r t) <->
    rank_type M atomMap r u = rank_type M atomMap r t

x_interval_correct w :
    stavi_temporal_truth_mu M atomMap r w (x_interval_formula M atomMap r t u) <->
    exists v, mu_holds v /\ t < v /\ v < u /\
      rank_type M atomMap r w = rank_type M atomMap r v
```

These are purely type-theoretic properties -- they characterize **what a point looks like** (its rank-type), not **where a point is** (its position in the order). A point outside [x, y] could have the same rank-type as a point inside [x, y].

### Could x_t_correct Force Containment?

Only if the formulas B and A themselves encode spatial information about [x, y]. Since B = X_{a_n} characterizes the rank-type of a_n (in N), and A = X_{(ref_N, a_n)} characterizes types realized in the interval (ref_N, a_n) (in N), these formulas encode information about N's type structure, NOT about M's spatial interval [c, y].

After transfer through tau (which maps N-side [d, y'] to M-side [c, y]), U(B, A) holds at ref_M in M. But the Until semantics quantify over ALL of ExtendedCarrier M -- not just [c, y].

**Conclusion for Path 1**: A first-witness-in-range argument cannot be constructed from the formula semantics alone. The formulas characterize types, not positions. The witness z could be anywhere above ref_M in M's extended carrier where a point with the right type exists.

---

## Path 2: Restricted Until Semantics

**Verdict**: INFEASIBLE (definitional mismatch)

### Analysis

The idea is to define a restricted Until: U_{[a,b]}(B,A)(t) means "exists z in [a,b] with z > t, B(z), and A on (t,z)."

**Does this exist in the codebase?** No. The Until semantics in `temporal_truth_mu` (TypeFormulas.lean:274-286) and `stavi_temporal_truth_mu` (TypeFormulas.lean:304-328) quantify over ALL of ExtendedCarrier, not a restricted interval:

```
| .untl phi psi =>
    exists s, t < s /\ mu_holds s /\
      temporal_truth_mu M atomMap r s phi /\
      forall u, t < u -> u < s -> mu_holds u ->
        temporal_truth_mu M atomMap r u psi
```

**Could it be derived from global Until + interval containment?** Not easily. The issue is fundamental: U(B,A)(t) guarantees a witness somewhere above t in the entire structure. To restrict to [a,b], you would need either:
1. A proof that no witness exists outside [a,b] (which is the containment problem itself), or
2. A reformulation where the Until semantics are parametrized by an interval bound.

Option 2 would require modifying the core temporal semantics, which is deep infrastructure change affecting hundreds of lines.

**What about deriving from global Until + type-interval containment?** The argument would be: "every type realized above ref_M in M is also realized in [c, y]." This is actually the key claim -- but proving it requires understanding the type structure of M relative to [c, y], which is exactly what the forward game provides (not the Until formula).

**Depth bound issue**: Even if we defined a restricted Until, the depth would likely be higher than r+2 because the restriction predicate would add quantifier depth.

**Conclusion for Path 2**: Definitionally incompatible with the existing infrastructure. Would require fundamental changes to temporal semantics that affect the entire formalization.

---

## Path 3: Hybrid Approach (Current Structure + GHR93 Properties)

**Verdict**: FEASIBLE (lowest implementation effort, already partially implemented)

### Analysis

This is what the current CaseAnalysis.lean already does (after Tasks 5.5-5.7):

1. **Use the forward game `h_fwd_n1` or `h_d_compat_left` for e_n construction** -- this guarantees e_n is in [x, y] because the forward game maps [x, y] to [x', y'] and the response is constrained to [x, y].

2. **Use U(B,A) transfer (or direct formula transfer through tau) for formula properties** -- tau's winning condition gives formula agreement at depth r between the N-side and M-side selections.

### What the Current Implementation Does (Post-Task 5.5-5.7)

Looking at CaseAnalysis.lean lines 1257-1414:

- `a_pad_big` and `h_d_compat_left` construct e_n via the forward game (lines 1269-1288)
- `hform_en_an` extracts formula agreement from the forward game (lines 1290-1296)
- `hord_cd_en_pn` extracts ordering from the forward game (lines 1297-1321)
- `tau_left` and `tau_right` provide backward games on sub-intervals (lines 1368-1378)
- `hord_left_sel_pn` provides sel_pn_ord (lines 1409-1414)

### What U(B,A) Would Add

In the hybrid approach, U(B,A) does NOT replace the forward game for e_n construction. Instead, it could potentially simplify:

1. **Formula agreement**: Instead of extracting hform_en_an from the forward game's game_tuple indices (which requires careful index arithmetic at lines 1290-1296), use x_t_correct directly: B(e_n) implies rank_type agreement, which implies formula agreement via rank_type_eq_iff. BUT: we still need to know that B holds at e_n, which requires either the forward game or some other mechanism.

2. **Round 2 interval case**: When b_sp is between ref_M and e_n, A holds at b_sp (from the Until witness property). By x_interval_correct, this means b_sp's rank-type matches some mu-point in (ref_N, a_n) in N. This gives a natural candidate for b_resp. BUT: the current implementation handles this through tau_left's winning condition, which already provides the needed correspondence.

### Assessment

The hybrid approach does NOT simplify the current proof structure significantly because:

- The forward game already provides e_n with containment, formula agreement, and ordering
- tau_left already provides the ordering correspondence (sel_pn_ord)
- The Round 2 dispatch already works through sub-game composition

**The current proof IS the hybrid approach**, and it works. The question is whether a "purer" GHR93 approach (using U(B,A) instead of the forward game for e_n) would be shorter or cleaner. The answer is: not meaningfully, because the containment issue forces the forward game back in anyway.

### Recommendation

Keep the current hybrid structure. The remaining sorries (line 434 in the Case I sub-case, and line 3146 in Cases III-IV) are in different parts of the proof and are not related to the Until witness containment issue.

---

## Path 4: Interval Closure Property

**Verdict**: INFEASIBLE (general linear orders do not have this property)

### Analysis

The question is whether the EF game or rank_type machinery guarantees that witnesses with matching types must be in the interval [x, y].

**For discrete orders (integers)**: If the carrier is Z with the standard ordering, ExtendedCarrier has no gaps (proved in Defs.lean, `gap_cut_succ_closed` + `no_gap_in_succ_archimedean`). All points between two integers are integers. But this does NOT help with containment: a point with the same rank-type as some point in [x, y] can still exist outside [x, y] in Z.

**For general linear orders**: The interval [x, y] in ExtendedCarrier is a set of points and gaps between x and y. There is no "closure" property that forces witnesses of a particular rank-type to be in range. Consider: if M's carrier is R and [x, y] = [0, 1], a point at position 2 could have the same rank-type as a point at position 0.5 (if the predicate structure is periodic or constant).

**rank_type argument**: rank_type M atomMap r t depends on the GLOBAL structure of M (including points arbitrarily far from t), because temporal formulas like U(B,A) quantify over the entire carrier. Two points at different locations can have the same rank-type if the local temporal structure around them is identical up to rank r. This is exactly the point of EF games: type agreement is about local indistinguishability, and local structure can be replicated at different locations.

**Conclusion for Path 4**: No interval closure property exists for general linear orders. The rank_type of a point depends on its neighborhood structure, and identical neighborhood structures can appear at multiple locations in the order.

---

## Path 5: SplitPointProps Extension

**Verdict**: FEASIBLE (cleanest structural fix if the pure GHR93 approach is desired)

### Current SplitPointProps Fields (from SplitPoint.lean lines 43-121)

```lean
structure SplitPointProps ... where
  hc_interval : inClosedInterval x y c
  hd_interval : inClosedInterval x' y' d
  hd_le_an : d <= a_bwd (n, ...)
  hxc / hcy / hx'd / hdy' : sub-interval bounds
  h_pt_xc / h_pt_cy : point existence in sub-intervals
  hcd_form : formula agreement c <-> d at rank r
  hcd_gp : gap/point correspondence c <-> d
  sigma : backward strategy on [x', d] / [x, c]
  tau : backward strategy on [d, y'] / [c, y]
  h_fwd_n1 : (n+1)-round forward strategy on full interval
  h_d_compat_left : d-compatible forward strategy
```

### Does SplitPointProps Already Imply Containment?

**tau maps [d, y'] in N to [c, y] in M**: This is exactly what tau provides. Playing tau with selections from [d, y'] gives responses in [c, y]. So if we use tau for constructing e_n (via playing tau with a_init), the responses resp_tau are guaranteed in [c, y], and hence in [x, y].

**But the Until witness z is extracted from M's global Until semantics, not from tau's response.** The mismatch is that U(B,A) transfer gives us a formula-level fact (U(B,A) holds at ref_M) from which we extract a witness z. This z comes from the existential quantifier in Until's semantics, which ranges over ALL of M's ExtendedCarrier.

### What Would Need to Be Added?

To make the pure GHR93 approach work, we would need one of:

**Option A: Add a "Until witness in range" hypothesis**:
```lean
h_untl_containment : forall (B A : StaviFormula),
    stavi_temporal_truth_mu M atomMap r ref_M (sf_untl B A) ->
    exists z, inClosedInterval c y z /\ z > ref_M /\ mu_holds z /\
      stavi_temporal_truth_mu M atomMap r z B /\
      forall w, ref_M < w -> w < z -> mu_holds w ->
        stavi_temporal_truth_mu M atomMap r w A
```

This is essentially asserting that Until witnesses can be found in [c, y] whenever U(B,A) holds at ref_M. This is NOT generally true and cannot be added as a hypothesis.

**Option B: Add a "type realization in range" hypothesis**:
```lean
h_type_realized : forall (t : ExtendedCarrier N atomMap r),
    inClosedInterval d y' t -> mu_holds t ->
    exists (s : ExtendedCarrier M atomMap r),
      inClosedInterval c y s /\ mu_holds s /\
      rank_type M atomMap r s = rank_type N atomMap r t
```

This says: every rank-type realized in [d, y'] (N-side) is also realized in [c, y] (M-side). This IS what the forward game `h_fwd_n1` guarantees (by playing elements from [d, y'] and getting responses in [c, y] that have the same rank-type). So this is derivable from existing SplitPointProps fields.

**But deriving it requires proving**: Playing h_fwd_n1 with a single carrier point t from [d, y'] gives a response s in [x, y] with rank_type agreement. We need s in [c, y] specifically. The forward game maps [x, y] to [x', y'], not [c, y] to [d, y']. So the response s could be anywhere in [x, y].

**This is again the containment problem**, just relocated. The forward game does not guarantee the response is in [c, y] -- it only guarantees the response is in [x, y].

### The Real Resolution

The current approach avoids the containment problem entirely by using the **d-compatible forward strategy** `h_d_compat_left`. This is a forward strategy where the last selection is forced to be c, and the last N-response is forced to be d. The challenge with p_n then gives e_n in [x, y]. The ordering c < e_n (when d < p_n) is extracted from the forward game's winning condition, giving e_n in [c, y] implicitly.

In other words, **the containment of e_n in [c, y] is a consequence of the forward game's ordering data**: since c corresponds to d, and d < p_n, we get c < e_n. Since e_n is in [x, y] (from the forward game), and c < e_n <= y, we have e_n in [c, y]. This is exactly what lines 1361-1364 of CaseAnalysis.lean establish.

**Conclusion for Path 5**: SplitPointProps does not need extension. The existing fields already provide what is needed. The "Until witness containment" problem is an artifact of trying to extract e_n from the Until formula rather than from the forward game. The current implementation correctly uses the forward game for construction and gets containment for free.

---

## sel_pn_ord Resolution

### Current Implementation

sel_pn_ord is currently derived at lines 1409-1414 of CaseAnalysis.lean:

```lean
have hord_left_sel_pn : forall (k : Fin n),
    (a_init k < extendPoint p_n <-> resp_left k < e_n) /\
    (a_init k = extendPoint p_n <-> resp_left k = e_n) := by
  intro k
  have h := hord_left (1 + k.val, ...) (n + 2, ...)
  simp_game_tuple at h; exact h
```

This comes from `tau_left`'s winning condition, which provides ordering correspondence between all pairs of game positions.

### GHR93's Claim

GHR93 says sel_pn_ord is "trivial from monotonicity + Until witness ordering." The argument would be:

For all k < n:
- `a_init k <= a_bwd(n-1) = ref_N` (from monotonicity h_mono)
- `ref_N < z_N` (from Until witness)
- Transfer through tau: `resp_tau k <= ref_M < z = e_n`
- Therefore `resp_tau k < e_n`

This chain requires:
1. That resp_tau preserves the ordering of a_init (i.e., resp_tau is order-preserving when a_init is monotone). This follows from tau's same_order_type winning condition.
2. That ref_M < e_n, which is the Until witness ordering after transfer.

### Without tau_left

If we don't have tau_left (as in the pure GHR93 U(B,A) approach), we would need:

1. Play tau_r with a_init to get resp_tau (already done, line 1255)
2. Define ref_M = resp_tau(n-1) when n > 0 (the M-side image of ref_N = a_bwd(n-1))
3. From tau's ordering: resp_tau(k) <= resp_tau(n-1) = ref_M for k < n-1 (by monotonicity of a_init + tau's order preservation)
4. From U(B,A) witness: ref_M < z = e_n
5. Chain: resp_tau(k) <= ref_M < e_n

This works BUT requires e_n to come from the Until witness (which has the containment problem). If e_n comes from the forward game instead (hybrid approach), we need tau_left to establish the ordering, which is what the current implementation does.

### Assessment

The current implementation's approach (using tau_left's hord_left_sel_pn) is cleaner and avoids the containment issue entirely. The comment at line 1418 correctly identifies this:

```
-- sel_pn_ord is just hord_left_sel_pn.
```

No change needed for sel_pn_ord. It is resolved.

---

## Path Rankings

| Rank | Path | Verdict | Effort | Mathematical Soundness |
|------|------|---------|--------|----------------------|
| 1 | **Path 3: Hybrid** | FEASIBLE | Lowest (already implemented) | Sound -- forward game guarantees containment |
| 2 | **Path 5: SplitPointProps** | FEASIBLE (unnecessary) | Medium | Sound -- but analysis shows existing fields suffice |
| 3 | **Path 1: First-Witness** | FEASIBLE (with caveats) | High | Requires well-ordering assumption not available for general linear orders |
| 4 | **Path 4: Interval Closure** | INFEASIBLE | N/A | Mathematically false for general linear orders |
| 5 | **Path 2: Restricted Until** | INFEASIBLE | Very high | Would require fundamental changes to temporal semantics |

---

## Recommendations

### Primary Recommendation: Keep the Hybrid (Path 3)

The current CaseAnalysis.lean implementation IS the correct resolution. It uses:
- Forward game (`h_d_compat_left`) for e_n construction (guarantees containment)
- tau/tau_left for ordering correspondence (gives sel_pn_ord via hord_left_sel_pn)
- Forward game winning condition for formula agreement (hform_en_an)
- Forward game + ordering for endpoint data

This is mathematically sound and already implemented (after Tasks 5.5-5.7).

### What GHR93 Actually Does (Clarification)

Re-reading GHR93 carefully, the argument works in the paper because GHR93 operates at the level of the **original structure M** (not ExtendedCarrier M_r). In the paper's setting:
- The game is played on M directly (no gaps)
- The Until witness exists in M's carrier
- The interval [x, y] contains all carrier points between x and y
- Since tau maps [d, y'] to [c, y], and the Until witness is a carrier point, it is automatically in the right range

In the Lean formalization, ExtendedCarrier adds gap points, which creates the possibility of witnesses outside the interval even when the formula is satisfied at a point in the interval. The hybrid approach is the correct adaptation of GHR93's argument to the extended carrier setting.

### Remaining Sorries (Not Related to Until Containment)

The three remaining sorries in CaseAnalysis.lean are:
1. **Line 434**: Case I sub-case ordering (same_order_type via index mapping) -- pure proof engineering, no mathematical issue
2. **Line 3146**: Cases III-IV assembly (sorry'd pending Lemma 9 gap detection) -- separate mathematical content
3. **(Implicit)**: Cases III-IV gap detection formulas -- dependent on GapDetection.lean infrastructure

None of these are related to the Until witness containment issue.

---

## Technical Appendix: Why the Forward Game Gives Containment

The forward game `h_d_compat_left` has type:

```lean
h_d_compat_left :
    forall (a_pad : Fin (1 + 3 * n + 1) -> ExtendedCarrier M atomMap r),
      (forall i, inClosedInterval x y (a_pad i)) ->
      a_pad (1 + 3 * n, ...) = c ->
      exists (a'_full : Fin (1 + 3 * n + 1) -> ExtendedCarrier N atomMap r),
        (forall i, inClosedInterval x' y' (a'_full i)) /\
        (forall (b' : N.carrier), inClosedInterval x' y' (extendPoint b') ->
          exists (b : M.carrier), inClosedInterval x y (extendPoint b) /\
            ghr93_winning_condition (...)) /\
        a'_full (1 + 3 * n, ...) = d
```

When challenged with p_n (a carrier point in [x', y']), it produces e_n_pt (a carrier point in [x, y]) and the winning condition. The key constraint is `inClosedInterval x y (extendPoint b)` -- the response e_n_pt is guaranteed to be in [x, y].

Then hord_cd_en_pn extracts: c < e_n iff d < p_n (from the forward game's order type). Since d <= p_n (from h_no_split), and d < p_n in the non-degenerate case (from hd_le_an + strict inequality), we get c < e_n. Combined with e_n <= y (from containment), this gives e_n in [c, y].

This is exactly the construction at lines 1359-1366 of CaseAnalysis.lean, and it is sorry-free.
