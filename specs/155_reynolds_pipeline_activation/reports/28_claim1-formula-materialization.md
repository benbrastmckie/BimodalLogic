# GHR93 Claim 1: Formula Materialization Analysis for h_d_unique

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-22
**Session**: sess_1779485383_cbe939
**Focus**: Construct rank-(r+1) formula C' in Lean to close h_d_unique (2 remaining sorries)

---

## Section 1: Exact Definitions

### 1.1 cont_holds (line 129)

```lean
private def cont_holds {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (a_n y' : ExtendedCarrier N atomMap r)
    (t : ExtendedCarrier N atomMap r) : Prop :=
  ∀ A : StaviFormula, stavi_depth A ≤ r →
    (∀ v : ExtendedCarrier N atomMap r,
      a_n < v → v < y' → mu_holds v →
      stavi_temporal_truth_mu N atomMap r v A) →
    stavi_temporal_truth_mu N atomMap r t A
```

**Semantics**: `cont_holds a_n y' t` says t satisfies every rank-r formula that holds throughout the mu-points of (a_n, y'). This is the predicate-level encoding of the GHR93 interval type formula C = X_{(a_n, y')}.

### 1.2 continuation_set (line 143)

```lean
private def continuation_set {sig : MonadicSignature}
    {N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {r : Nat} (x' y' a_n : ExtendedCarrier N atomMap r) :
    Set (ExtendedCarrier N atomMap r) :=
  { t | inClosedInterval x' y' t ∧
    ∀ u : ExtendedCarrier N atomMap r,
      t < u → u < y' → mu_holds u → cont_holds a_n y' u }
```

**Semantics**: S_C = {t in [x',y'] : C holds at all mu-points in (t, y')}.

### 1.3 Supporting Infrastructure

- `continuation_set_nonempty` (line 163): y' is in S_C (vacuously)
- `continuation_set_upward_closed` (line 175): S_C is upward-closed in [x',y']
- `a_n_in_continuation_set` (line 193): a_n is in S_C
- `cont_holds_above_gap` (line 425): above the infimum gap, cont_holds holds for all formulas
- `cont_fails_below_gap` (line 469): below the infimum gap, cont_holds fails at some mu-point
- `pigeonhole_definable_formula` (line 625): extracts a single formula D from cofinal failure (sorry-free)
- `infimum_gap_r_definable` (line 905): the infimum gap is r-definable (sorry-free)

### 1.4 Infimum Construction (line 1466)

```lean
obtain ⟨d, hd_interval, hd_glb, hd_le_an_proof, hd_is_inf⟩ : ...
```

Where:
- `hd_glb : ∀ s ∈ S_C, d ≤ s` (d is a lower bound)
- `hd_is_inf : ∀ e, (∀ s ∈ S_C, e ≤ s) → e ≤ d` (d is the greatest lower bound)

---

## Section 2: Rank Arithmetic Problem (CRITICAL FINDING)

### 2.1 The Depth Convention Mismatch

The Lean code uses `stavi_depth` which adds **+2** per temporal connective (matching the FO quantifier depth of the translation):

```lean
def stavi_depth : StaviFormula → Nat
  | .std_snce A B => max (stavi_depth A) (stavi_depth B) + 2  -- +2, not +1
  | .std_untl A B => max (stavi_depth A) (stavi_depth B) + 2
```

The GHR93 paper uses "rank" which adds **+1** per temporal connective (Definition 8.2, p.113):

> "The rank of a temporal formula A is defined to be the maximum depth of nesting of temporal connectives in A."

**Example**: GHR93 says rank(U(p, neg-S'(neg-q, q))) = 2. In Lean, this same formula has stavi_depth 4.

**Ratio**: `stavi_depth = 2 * (GHR93 rank)` for temporal connectives.

### 2.2 Impact on C' Construction

GHR93 says C' = not-C or K^-(not-C) has "rank r+1". In Lean terms:

- C has `stavi_depth r` (conjunction of depth-r formulas)
- `neg(C)` has `stavi_depth r`
- K^-(not-C) = `neg(std_snce(neg(.base .bot), C))`:
  - `std_snce(top, C)` has `stavi_depth = max(0, r) + 2 = r + 2`
  - `neg(std_snce(top, C))` has `stavi_depth = r + 2`
- C' = not-C or K^-(not-C) has `stavi_depth = max(r, r+2) = r + 2`

### 2.3 The Gap

The forward game hypothesis provides:
```lean
h_fwd_r1 : ghr93_duplicator_wins M N atomMap (4 + 3 * n) (r + 1) ...
```

This gives formula agreement for `stavi_depth A ≤ r + 1`.

But C' has `stavi_depth = r + 2`. **C' is 1 unit beyond h_fwd_r1's range.**

This is not a bug in C' -- it reflects the systematic difference between GHR93's "+1 per temporal connective" rank and Lean's "+2 per temporal connective" stavi_depth. In GHR93 terms, the paper's "rank r+1 formula C'" needs Lean rank r+2.

---

## Section 3: Assessment of Approaches

### 3.1 Option A: Increase h_fwd_r1 to rank r+2

**Change**: Replace `(r + 1)` with `(r + 2)` in `h_fwd_r1` throughout:
- `obtain_split_point_props` (line 1445)
- `d_consistency_left` (line 1097)
- `d_consistency_right` (line 1232)
- `ghr93_inductive_step` (line 4431)
- `ghr93_forward_to_backward_core` (line 4468)
- `ghr93_forward_to_backward` (line 4589)

**Impact**: The main theorem's hypothesis changes from requiring a game at rank r+1 to rank r+2. This is mathematically correct -- the GHR93 paper's forward game uses rank r+4(n+1), which exceeds r+2 by a large margin. The downstream proofs that SUPPLY h_fwd_r1 (currently sorry'd in `ghr93_forward_to_backward_rank_varying`) would need to provide rank r+2 instead of r+1, which is trivially satisfiable from rank r+4(n+1).

**Proof of C'**: With h_fwd_r1 at rank r+2, the C' construction becomes:
1. Materialize C as the (finite) conjunction of all NormalForm-representatives of depth-r formulas holding on (a_n, y')
2. Construct K^-(not-C) = neg(std_snce(top, C)) with stavi_depth r+2
3. C' = neg(conj(C, neg(neg(std_snce(top, C))))) with stavi_depth r+2
4. Prove M_r |= C'(c) using infimum properties (cont_fails_below_gap for case 2)
5. Transfer via h_fwd_r1 at rank r+2 to get N_r |= C'(d)
6. Analyze C'(d) to derive d <= d-bar

**Risk**: Low. The rank r+2 parameter is well within the available rank budget. The change is purely a strengthening of the hypothesis with no structural impact.

**Estimated effort**: ~30 lines to change r+1 to r+2 across signatures + ~100-150 lines for the C' proof itself.

### 3.2 Option B: Direct Game Argument (Round 2 at rank r)

**Approach**: Avoid C' entirely. Use the game's Round 2 point challenge at rank r.

**d-bar <= d direction** (sorry 2, line 1796): This direction WORKS at rank r.

The argument:
1. Assume t' < d. Then t' is not in S_C.
2. There exists mu-point u with t' < u < y' and not-cont_holds at u.
3. If u > d: proven (line 1797-1804).
4. If u <= d: we have u a mu-point (carrier point) with cont_holds failing. So there exists formula A with depth <= r, A holds on (a_n, y'), A fails at u.
5. Play h_fwd at rank r: Spoiler selects c in M. In Round 2, challenge with u in N. Duplicator responds with b in M.
6. Order correspondence: u is in [x', y'], so b is in [x, y]. The order type matching gives us: u relative to d (the response at position n) determines b relative to c.
7. If u < d: b < c (by order correspondence since the game response at position n is c, corresponding to d). But b < c means b is below the M-side infimum. Since cont_holds fails at u in N, by formula agreement at rank r, the SAME formula A fails at b in M. This is consistent -- b below c can have formula failures.

**Problem**: At step 7, we don't get a contradiction. Both b (below c in M) and u (below d in N) can have the same formula failure. There's no structural reason why b below c should satisfy all interval-type formulas.

**Conclusion**: Round 2 at rank r is INSUFFICIENT for the d-bar <= d direction because the failure is consistent on both sides.

**t' <= d direction** (sorry 1, line 1759): This direction also needs rank > r.

The argument:
1. d < t'. Both in S_C. d = inf(S_C).
2. t' and d agree on all rank-r formulas.
3. Need to find a formula they DISAGREE on (contradiction).
4. At rank r, they agree by hypothesis. Need rank r+1 or higher formula to distinguish them.

**Conclusion**: Round 2 at rank r alone CANNOT close either sorry. The GHR93 rank r+1 formula C' (Lean depth r+2) is necessary.

### 3.3 Option C: Predicate-Level Argument Without Explicit C'

**Approach**: Instead of constructing C' as a StaviFormula, work at the predicate level using the game at rank r+2 (Option A's change) but avoid the formula materialization step.

**Key insight**: The rank-(r+2) game gives agreement for ALL formulas of stavi_depth <= r+2. We don't need to NAME a specific formula C'. We can argue:

1. Play h_fwd_r1 (at rank r+2) with Spoiler selecting `rank_embed(c)`.
2. Get response t_resp in ExtendedCarrier N (r+2).
3. Formula agreement at rank r+2 gives: for ALL A with stavi_depth <= r+2, A agrees at rank_embed(c) and t_resp.
4. In particular, the formula `neg(std_snce(top, C_specific))` where C_specific is any specific depth-r formula, its truth value matches.
5. By rank_embed_stavi_truth_mu, truth at rank_embed(c) at depth r+2 equals truth at c at depth r.
6. Use the infimum properties of c to establish the truth of specific depth-(r+2) formulas at c, then transfer to t_resp.

**Problem**: This still requires identifying WHICH formulas distinguish positions (essentially constructing C' implicitly). And we still need rank r+2 in the hypothesis.

**Conclusion**: Options A and C both require `h_fwd_r1` at rank r+2. Option A is cleaner since it makes the formula explicit.

### 3.4 Option D: Reformulate stavi_depth to Use +1 per Temporal Connective

**Approach**: Change `stavi_depth(.std_snce A B)` from `max + 2` to `max + 1`, matching GHR93 rank directly.

**Impact**: This would require:
- Changing `stavi_depth` definition
- Updating `stavi_fo_depth` and `stavi_fo_depth_le_twice_depth`
- Updating all lemmas that depend on stavi_depth arithmetic
- Potentially breaking `stavi_table_mu_depth` and `nf_determines_stavi_truth_depth`

**Risk**: Very high. The entire NormalForm finiteness bridge relies on stavi_depth matching the FO quantifier depth via `stavi_table_mu_depth`. Changing stavi_depth would break this bridge.

**Conclusion**: Not viable. The +2 convention is fundamental to the NF bridge.

---

## Section 4: Recommended Approach

**Recommendation: Option A (increase h_fwd_r1 to rank r+2) + explicit C' construction.**

### 4.1 Step-by-Step Proof Outline for h_d_unique

#### Phase 1: Parameter Change (r+1 -> r+2)

Change in 6 locations (signatures only, no proof changes needed since existing proofs are either boundary-case-proved or sorry'd at the same points):
1. `obtain_split_point_props` line 1445: `(r + 1)` -> `(r + 2)`
2. `d_consistency_left` line 1097: `(r + 1)` -> `(r + 2)`
3. `d_consistency_right` line 1232: `(r + 1)` -> `(r + 2)`
4. `ghr93_inductive_step` line 4431: `(r + 1)` -> `(r + 2)`
5. `ghr93_forward_to_backward_core` line 4468: `(r + 1)` -> `(r + 2)`
6. `ghr93_forward_to_backward` line 4589: `(r + 1)` -> `(r + 2)`

Also update `rank_embed (Nat.le_succ r)` to `rank_embed (by omega : r ≤ r + 2)` in the same locations.

#### Phase 2: Sorry 1 (line 1759) -- t' <= d direction, d < t' contradiction

**Context**: We have d < t', both in [x',y'], same rank-r type, same gap/point. t' in S_C by upward-closedness. d = inf(S_C).

**Proof sketch** (~50 lines):

1. Since d is the infimum of S_C and d < t', the gap/point at d has specific structural properties.

2. **Case d is a gap (r-definable)**: The infimum gap is r-definable by some formula D of depth <= r (via `infimum_gap_r_definable`). D holds above the gap (cont_holds_above_gap applied to D) and fails cofinally below the gap.

   Construct C_single: the specific formula D from the pigeonhole extraction. D has stavi_depth <= r.

   Now construct: `F := neg(std_snce (neg (base .bot)) (neg (.neg D)))` -- this encodes "not-S(top, D)" = "D fails cofinally below current position" = K^-(not-D).

   `stavi_depth(F) = stavi_depth(std_snce(top, D)) = max(0, stavi_depth D) + 2 <= r + 2`.

   Show F holds at c (M-side infimum): since D fails cofinally below c in M (by the gap definability property), S(top, D) is false at c (D does NOT hold on any final segment below c), so not-S(top, D) = F is true at c.

   Transfer via h_fwd_r1 (at rank r+2): F holds at d (or the response corresponding to c) in N.

   But F at t' (which is strictly above d): D holds at t' (since t' is above the gap and t' is a mu-point or a position where D holds by cont_holds_above_gap). And D holds on a final segment below t' (since between d and t', D holds at all mu-points above d). So S(top, D) is true at t' (take the final segment (d, t')). Hence F = not-S(top, D) is FALSE at t'.

   But t' and d agree on rank-r formulas, and they have the same gap/point status. The rank-(r+2) formula F distinguishes them (F at d but not-F at t'). This contradicts the rank-(r+2) formula agreement between d and the response to c. Wait -- this doesn't directly work because the game's response may not be t'.

   **Better approach**: Play h_fwd_r1 with Spoiler selecting rank_embed(c). Get response t_resp. The winning condition gives rank-(r+2) formula agreement between rank_embed(c) and t_resp.

   F(rank_embed(c)) = F(c) by rank_embed_stavi_truth_mu (since stavi_depth F <= r+2, and we're embedding from rank r to rank r+2).

   F(c) = true (from infimum properties).

   So F(t_resp) = true.

   Now, t_resp at rank r+2 projects to some element at rank r. If this projection is t', then F(t') should be true. But we showed F(t') = false (D holds on a final segment below t'). Contradiction, so the projection cannot be t'. Therefore the projection must be d.

   This requires a lemma connecting the rank-(r+2) game response to the rank-r response.

3. **Case d is a mu-point (carrier point)**: d achieves the infimum of S_C. Then d is in S_C, so cont_holds at all mu-points above d in (d, y'). But for t < d, t is NOT in S_C, so cont_holds fails cofinally below d. Use the same F construction with the pigeonhole formula D.

**Note**: The proof needs careful handling of the rank embedding and projection. The core argument is sound but requires ~50-80 lines of Lean code.

#### Phase 3: Sorry 2 (line 1796) -- d <= t' direction, u <= d case

**Context**: t' < d, mu-point u with t' < u <= d and not-cont_holds at u. Case u > d is proved (lines 1797-1804). Case u <= d is sorry'd.

**Proof sketch** (~50 lines):

1. u <= d and u is a mu-point where cont_holds fails. So there exists formula A with depth <= r, A holds on (a_n, y') but A fails at u (i.e., not-A(u)).

2. Since u < d (strict, since u is a mu-point and d is the infimum: if d is a gap, u < d; if d is a point, u <= d but the cont_holds failure gives u outside S_C, so u < d by infimum property).

   Actually, we need u < d strictly. If u = d and d is a mu-point: d is in S_C (it achieves the infimum), so cont_holds holds at d. But cont_holds fails at u = d. Contradiction. So u < d.

3. Now use h_fwd_r1 (at rank r+2) with a similar construction:

   Consider the formula G := `std_snce (neg (.base .bot)) A` -- this encodes S(top, A) = "A held at some point in the past and top held between" = "there exists s < t with A(s)."

   `stavi_depth(G) = max(0, stavi_depth A) + 2 <= r + 2`.

   G(d) in N: Does there exist s < d with A(s)? A holds on (a_n, y') at all mu-points. If there's a mu-point s with s < d and a_n < s < y', then A(s) holds (since s is in (a_n, y')). But we need a_n < s. Since d <= a_n (from hd_le_an) and s < d, we have s < a_n. So A(s) is not guaranteed by the interval hypothesis.

   Hmm, this approach hits a wall. The formula A only holds on (a_n, y'), and witnesses below d could be below a_n.

4. **Alternative for sorry 2**: Use the same K^- / cofinality argument.

   Since t' < d and we have u <= d with not-cont_holds at u, we know that between t' and d, the continuation condition is violated. The GHR93 argument for this direction is: "If d < d-bar then V can choose d' in (d, d-bar) with not-C(d')."

   But in our context, d IS d-bar (we proved d = inf(S_C)). And t' < d. The issue is showing t' cannot be below d while having the same rank-r type.

   The argument: t' < d, same rank-r type as d. Play the game with c corresponding to d. The rank-r game response to selections involving c should give d. If the response gave t' instead, the rank-(r+2) formula F (from Phase 2) would distinguish them -- F holds at d (infimum property) but not at t' (t' is below the infimum, so D holds cofinally below t' would require D to fail below t', but D fails cofinally below d, and t' < d, so the cofinality picture below t' is different from below d).

   Actually, for t' < d: D fails cofinally below d. For t' < d, D should hold or fail below t' depending on where t' is. If t' is well below d, D could hold everywhere below t' (since D fails only between t' and d, not below t'). Then K^-(not-D) at t' might be false, while K^-(not-D) at d is true. So F = K^-(not-D) distinguishes d from t'.

   This works symmetrically to Phase 2.

---

## Section 5: Missing Lemmas

### 5.1 Required for C' Construction

1. **Materialization of C as a StaviFormula** (or specific depth-r formula D):
   Already available via `pigeonhole_definable_formula` which extracts D with stavi_depth <= r.

2. **stavi_depth bound for C'**:
   `stavi_depth (neg (std_snce (neg (base .bot)) (neg D))) <= r + 2`
   when `stavi_depth D <= r`. This follows from the stavi_depth definition: trivial arithmetic.

3. **K^-(not-D) semantics at the infimum**:
   Lemma: If d = inf(S_C) and D defines the gap on the right (D holds above, not-D cofinally below), then `stavi_temporal_truth_mu N atomMap r d (neg (std_snce top (neg (neg D))))` holds.
   Proof: S(top, D) at d means "D holds on some final segment below d." But D fails cofinally below d (gap definability). So S(top, D) is false at d, hence neg(S(top, D)) = K^-(not-D) is true at d.

4. **K^-(not-D) fails above the gap**:
   Lemma: If t' > d and D holds on (d, t'), then K^-(not-D) is false at t'.
   Proof: S(top, D) at t' is true -- take s = d, D holds on (s, t'). So neg(S(top, D)) is false.

5. **rank_embed_stavi_truth_mu at depth r+2**:
   Already exists as `rank_embed_stavi_truth_mu` (works for any r <= r').

### 5.2 Required for Game Integration

6. **Game response projection lemma**:
   If the rank-(r+2) game response is rank_embed(d), then the rank-r projection of the game gives d as the response.
   This follows from `rank_embed` being injective and the game's order/formula agreement.

7. **rank_embed injectivity**:
   `rank_embed h a = rank_embed h b -> a = b`. Needed for uniqueness.
   This should follow from `Sum.map id f` being injective when f is injective.

---

## Section 6: Summary and Recommendation

### The Core Issue

The Lean code's `stavi_depth` adds +2 per temporal connective (matching FO quantifier depth), while GHR93's "rank" adds +1. The formula C' from GHR93 Claim 1 has GHR93 rank r+1 but Lean stavi_depth r+2. The current `h_fwd_r1` parameter uses rank r+1 (stavi_depth bound r+1), which is 1 unit too low for C'.

### The Fix

1. **Change h_fwd_r1 from rank r+1 to rank r+2** across 6 theorem signatures. This is a clean, low-risk change that aligns the Lean encoding with GHR93's rank arithmetic.

2. **Construct C' proof** using the pigeonhole formula D (already extracted by `pigeonhole_definable_formula`) and the K^-(not-D) encoding via std_snce. The proof uses `cont_holds_above_gap`, `cont_fails_below_gap`, and the game at rank r+2.

3. **Estimated total effort**: ~30 lines for parameter changes + ~100-150 lines for the two sorry closures = ~130-180 lines.

### Dependencies

- `rank_embed_stavi_truth_mu` (exists, sorry-free)
- `pigeonhole_definable_formula` (exists, sorry-free)
- `infimum_gap_r_definable` (exists, sorry-free)
- `stavi_table_mu_correct` (exists, sorry-free)
- `cont_holds_above_gap` and `cont_fails_below_gap` (exist, sorry-free)

### Alternative If Rank Change Is Unacceptable

If changing h_fwd_r1 from r+1 to r+2 is unacceptable (e.g., for calibration reasons), the only other viable path is to redefine `stavi_depth` to use +1 per temporal connective and re-engineer the NormalForm bridge. This would be a much larger change (~500+ lines) and is NOT recommended.
