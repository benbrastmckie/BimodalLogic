# Teammate A Findings: Sorry Inventory and Optimal Proof Strategy

**Task**: 155 — reynolds_pipeline_activation
**Date**: 2026-05-20
**Scope**: Phase 4C exact sorry sites, mathematical content, and optimal ordering

---

## Key Findings

### 1. Verified Current Sorry Count: 13 Across 2 Files

The plan's stated count of 13 sorries is accurate. The exact source-level sorry locations are:

**EFGames.lean** (4 sorries):
| Line | Name | Role |
|------|------|------|
| 1423 | `left_formula_gap_detection` | Lemma 9 left (gap detection correctness) |
| 1442 | `right_formula_gap_detection` | Lemma 9 right (dual) |
| 2423 | `ghr93_decomposition_implies_game` | Lemma 11 backward direction |
| 2495 | `stavi_expressive_completeness` | Main theorem shell (Corollary 5) |

**ExpressivenessGeneral.lean** (9 sorries):
| Line | Name/Context | Role |
|------|------|------|
| 297 | d-consistency left (`obtain_split_point_props`) | `h_d_consistent_left` |
| 307 | d-consistency right (`obtain_split_point_props`) | `h_d_consistent_right` |
| 336 | h_pt_left gap case | Point in `[x',d]` when d is a gap |
| 345 | h_pt_right gap case | Point in `[d,y']` when d is a gap |
| 351 | h_pt_xc_w gap case | Point in `[x,c]` when c is a gap |
| 356 | h_pt_cy_w gap case | Point in `[c,y]` when c is a gap |
| 446 | c construction gap case | When d is a gap, find compatible c in M |
| 2350 | `ghr93_cases_III_IV` | Cases III-IV of Theorem 6 |
| 2571 | `ghr93_forward_to_backward_rank_varying` | Rank-varying version of Theorem 6 |

### 2. Cases I and II Are Completely Proved

The git log and source confirm:
- `ghr93_case_I` (line 573–1539): sorry-free, 966 lines of proof code
- `ghr93_case_II` (line 1566–2319): sorry-free, 753 lines of proof code
- `ghr93_inductive_step` assembly (lines 2385–2414): sorry-free
- `ghr93_game_implies_decomposition` (S3): sorry-free
- Both strategy restriction theorems (`ghr93_strategy_restrict_left` and `_right`): sorry-free

### 3. The 9 Sorries in `obtain_split_point_props` Fall Into 3 Categories

**Category A — D-consistency (lines 297, 307)**: These assert that for any padded selection where c (resp. c at position 0) is placed at index n (resp. 0), the strategy's response at that position equals d. Mathematical content: since d = `a_bwd(n)` (set explicitly), and c is obtained from the forward game's Round 2 mechanism as a match for d (same rank_type and gap/point status), the d-consistency follows from the winning condition's `formula_agreement` + `gap_point_agreement` at the boundary index. The key insight is that c is CHOSEN as the Round 2 response when d is a point — so the strategy deterministically produces d in response to c by definition of how c was extracted. When d is a gap (line 446 sorry), the extraction of c is more complex.

**Category B — Sub-interval point witnesses (lines 336, 345, 351, 356)**: These are of the form "when d (or c) is a gap, find an actual point in the sub-interval [x',d] (or [d,y'], [x,c], [c,y])". The gap case is:
- Line 336: `p_N > d` (a gap) → need a point in `[x',d]`. The gap `g_d` has a nonempty cut, giving points < d; but bounding below by `x'` requires knowing the cut contains a point in `[x', d)`.
- Line 345: symmetric for `[d,y']`.
- Lines 351/356: same issue for c (M-side).

The mathematical content: when d is a gap, its cut `g_d.val.cut` is non-empty and contained in `(x', d)` (by gap's downward-closure property), so any element of the cut is a point in `[x',d]`. However, `g_d.val.cut` contains elements of `M.carrier` (not `ExtendedCarrier`), so the witness would be `extendPoint (cut element)`. The bound `x' ≤ extendPoint (cut element)` follows from `hd_interval.1 : x' ≤ d` and the fact that cut elements are strictly below d.

**Category C — c construction when d is a gap (line 446)**: The gap case of finding c in M that has the same rank_type and gap/point status as d (a gap). The comment correctly identifies that this requires Lemma 9 (gap detection formulas) to locate a compatible gap in M from a formula-theoretic perspective. This is the genuine hard case.

### 4. Lemma 9 Is the Central Blocker

`left_formula_gap_detection` (line 1423) and `right_formula_gap_detection` (line 1442) are the most critical outstanding proofs. They are:

**Type signature** (left version):
```lean
theorem left_formula_gap_detection {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds} {r : Nat}
    (A D : StaviFormula) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula A D) ↔
    (∃ (γ : RDefinableGap M atomMap r),
      extendPoint m < Sum.inr γ ∧
      gap_definable_on_left M atomMap γ.val D ∧
      (∀ u : M.carrier, m < u → u ∈ γ.val.cut →
        stavi_temporal_truth_mu M atomMap r (extendPoint u) D) ∧
      stavi_temporal_truth_mu M atomMap r (Sum.inr γ) A)
```

**What the proof needs** (structural induction on A):

| A constructor | left_formula(A,D) | Proof strategy |
|---|---|---|
| `.base .atom _` | `.base .bot` | Trivial: both sides false |
| `.base .bot` | `.base .bot` | Trivial: both sides false |
| `.base (.imp φ ψ)` | complex U'/conj | IH for atom+neg composition |
| `.base .box _` | `.base .bot` | Trivial: box=atom at gaps |
| `.base (.untl φ ψ)` | `.stavi_untl (B ∧ U(A,B)) D` | Unfold U'^mu, use U definition |
| `.base (.snce φ ψ)` | `.base (.untl (flatten ...) (flatten D))` | Hard: mu-relativized flatten_stavi |
| `.neg A` | `U'(⊤,D) ∧ ¬left(A,D)` | IH + negation |
| `.conj A B` | `left(A,D) ∧ left(B,D)` | IH + conjunction |
| `.stavi_untl A B` | `U'(B ∧ U'(A,B), D)` | Unfold U'^mu definition |
| `.stavi_snce A B` | `.base (.untl (flatten ...) (flatten D))` | Hard: mu-relativized flatten_stavi |

**The hard cases** are `.base (.snce φ ψ)` and `.stavi_snce A B`. These use `flatten_stavi` to encode standard Until of Stavi-enriched subformulas. The proof requires:
1. Showing `temporal_truth_mu M atomMap r (extendPoint m) (flatten_stavi compound)` is equivalent to the gap existence condition.
2. At actual points `extendPoint m`, mu-relativization restricts all temporal operators to act only over actual points. This means evaluation of `flatten_stavi compound` at `extendPoint m` reduces to evaluation of `compound` (a `StaviFormula`) at `extendPoint m` restricted to actual points, which is exactly `stavi_temporal_truth_mu M atomMap r (extendPoint m) compound`.
3. A "mu-elimination at actual points" lemma: `temporal_truth_mu M atomMap r (extendPoint m) (flatten_stavi A) ↔ stavi_temporal_truth_mu M atomMap r (extendPoint m) A`. This bridges the `.snce` cases and would be the most valuable helper to develop first.

### 5. The `ghr93_cases_III_IV` Sorry Structure

At line 2350, the sorry is inside `ghr93_cases_III_IV`, which has already been refactored from the original `ghr93_cases_II_III_IV`. The current code dispatches:
```lean
rcases isPoint_or_isGap (a_bwd ⟨n, by omega⟩) with h_pt | h_gap
· exact ghr93_case_II props ha_bwd h_no_split h_pt
· exact ghr93_cases_III_IV props ha_bwd h_no_split h_gap
```

So `ghr93_cases_III_IV` already takes `h_gap : IsGap (a_bwd ⟨n, by omega⟩)` and the body is entirely `sorry`. According to report 14, this should be further split into Case III (left-defined gap) and Case IV (right-defined gap). The current sorry needs to be replaced by this further case split + the two sub-case proofs.

### 6. Lemma 11 Backward (line 2423) Is Tractable

`ghr93_decomposition_implies_game` requires: given `decomposition_agreement M N atomMap n r x y x' y'`, construct Duplicator's winning strategy. The key insight from report 13 is:
- Round 1: For any selection `a` from M, the decomposition agreement guarantees a matching selection `a'` from N with the same rank_types and gap/point status.
- Round 2: For any actual point `b'` from N, need actual point `b` from M with matching rank_type. The backward direction of decomposition_agreement provides this: decomposition agreement at n+1 elements (including `extendPoint b'`) gives a forward match, extracting an actual point.

The forward direction (already proved) did this by playing with an actual point as Round 2 challenge.

### 7. `stavi_expressive_completeness` (line 2495) Remains a Shell

The current definition is just `sorry`. The full proof (Propositions 6, 7, Corollary 5) requires:
- Proposition 6: formula agreement → game wins
- Proposition 7 (composition): combining Theorem 6 with decomposition formulas
- Corollary 5: the final assembly

These are not yet written. Estimated 250–400 lines.

### 8. `ghr93_forward_to_backward_rank_varying` (line 2571)

This needs to transport the uniform-rank Theorem 6 result from rank r+4n to rank r using `rank_embed`. The uniform-rank version (`ghr93_forward_to_backward`) uses the same rank for both games. The rank-varying version is needed for Props 6/7 which may use the rank-varying statement directly. Since `rank_embed` is monotone (already proved), this should be derivable via: apply uniform-rank Theorem 6 at rank r+4n using round monotonicity, then use `rank_embed_preserves` to transport the backward strategy to rank r.

---

## Recommended Approach

### Optimal Ordering (Dependency-Aware)

The 13 sorries form 4 dependency groups:

**Group A — d-consistency (EXP lines 297, 307)**: These are inside `obtain_split_point_props` and block the IH application. They are provable by observing that c is obtained as the Round 2 response to d (for the point case), so the consistency follows from the winning condition at the boundary index. Estimated 20–40 lines each.

**Group B — Sub-interval point witnesses (EXP lines 336, 345, 351, 356)**: These 4 sorries are also inside `obtain_split_point_props`. The gap case needs the fact that a gap's cut contains actual points. The `Gap` type in EFGames.lean stores `g.val.cut : Set M.carrier` (the left set of the Dedekind cut). Any element of this set is an actual M-carrier point ≤ g. Bound below by x' using `hd_interval.1`. Estimated 10–15 lines each.

**Group C — c construction when d is a gap (EXP line 446)**: The most complex sorry in obtain_split_point_props. Requires Lemma 9 to find a compatible gap c in M. This is blocked by Lemma 9.

**Recommended attack order**:
1. **Groups A+B** (EXP lines 297, 307, 336, 345, 351, 356) — 6 sorries in `obtain_split_point_props`. These are independent of Lemma 9 and can be closed now, making `obtain_split_point_props` have only 1 sorry (line 446, the gap case of c construction).

2. **Lemma 9 left** (EFG line 1423) — prerequisite for line 446 (c in gap case) and Case III. Develop the "mu-elimination at actual points" helper first (~20–30 lines), then do the structural induction (~150–200 lines total).

3. **Lemma 9 right** (EFG line 1442) — dual of left, mostly symmetric copy (~50 lines after left is done).

4. **Line 446** (c construction gap case) — Now provable using Lemma 9 left. (~50–80 lines)

5. **Cases III+IV** (EXP line 2350) — Now provable using lines 297, 307 (d-consistency, closed in step 1), Lemma 9 (closed in steps 2–3). (~300–400 lines total for both cases)

6. **Lemma 11 backward** (EFG line 2423) — ~80–120 lines, independent of steps 1–5.

7. **rank-varying Theorem 6** (EXP line 2571) — ~30–50 lines once uniform-rank is fully closed.

8. **Proposition 6** (not yet written) — ~100–150 lines.

9. **Proposition 7** (not yet written) — ~150–200 lines, uses Lemma 11.

10. **Corollary 5 / stavi_expressive_completeness** (EFG line 2495) — ~80–100 lines.

### Priority Assessment

The **highest ROI action** right now is to close Groups A+B in `obtain_split_point_props` (EXP lines 297, 307, 336, 345, 351, 356). These 6 sorries block the h_pt witnesses needed for `sigma` and `tau`. Once closed, `obtain_split_point_props` will have only 1 sorry remaining (line 446, which requires Lemma 9). This unlocks Case I (already proved) and Case II (already proved) to be fully sorry-free through the IH, once those d-consistency hypotheses are established.

The **hardest single blocker** is Lemma 9 (EFG lines 1423, 1442). It is 200–350 lines of structural induction. The single most important prerequisite to develop is the mu-elimination-at-actual-points lemma. Without Lemma 9, Cases III and IV cannot be closed, and c cannot be found when d is a gap (line 446).

---

## Evidence and Examples

### Evidence 1: Groups A+B Are Tractable

For the d-consistency sorries (lines 297, 307), the mathematical argument is:

When d is a point (`d = extendPoint p'`), the code at lines 372–420 already establishes c by playing the forward game's Round 2 with `p'` as the spoiler challenge, getting `b` as the response, and setting `c = extendPoint b`. The d-consistency in this case is: if we play the forward game with `extendPoint b` at position n (the last slot), the response at position n is `d = extendPoint p'`. This follows from the winning condition's `formula_agreement` and `gap_point_agreement` at the boundary index, combined with the fact that c was chosen to match d's type.

The code structure at lines 260–370 shows that `suffices h_exists : ∃ c, inClosedInterval x y c ∧ formula-agreement(c,d) ∧ gap/point-agreement(c,d)` is the actual obligation, from which `sigma` and `tau` are derived. The d-consistency hypothesis `h_d_consistent_left` states:

> If `a_pad ⟨n, _⟩ = c` and the forward strategy's winning condition holds, then `a'_full ⟨n, _⟩ = d`.

This is a consequence of `hcd_form` (formula agreement between c and d) passed to `ghr93_strategy_restrict_left`. The strategy restriction lemma uses d-consistency to ensure response containment. Inside the `obtain_split_point_props` proof, this is circular without the infimum approach — but it can be proved directly when c is the Round 2 response, because in that case c and d are DEFINED as matching Round 2 responses.

Specifically: when c is obtained as the Round 2 response to d=`extendPoint p'`, the forward strategy maps (any selection from [x,y] with c at position n) to (some response from [x',y'] with d at position n) by the `formula_agreement` at the boundary. This is precisely what `h_d_consistent` requires.

### Evidence 2: Sub-Interval Point Witnesses

For lines 336/345 (N-side gap case), the `Gap` type in EFGames.lean has:

```lean
structure Gap (M : OrderedMonadicStructure sig) where
  cut : Set M.carrier  -- the left set of the Dedekind cut
  cut_nonempty : ∃ x, x ∈ cut
  cut_downward : ...
  cut_proper : ...
  no_max : ∀ x ∈ cut, ∃ y ∈ cut, x < y
```

When `d = Sum.inr g_d` (a gap), `g_d.val.cut` is nonempty. Let `u ∈ g_d.val.cut`. Then `extendPoint u < Sum.inr g_d = d`. Also `x' ≤ d` (from `hd_interval.1`), and `extendPoint u < d ≤ y'`. But we need `x' ≤ extendPoint u`. This requires: in the ExtendedCarrier order, if `x' ≤ Sum.inr g_d` and `extendPoint u < Sum.inr g_d`, does `x' ≤ extendPoint u` follow? Only if `x'` is also a point or a gap below u. This is NOT guaranteed in general — x' could be a gap between `extendPoint u` and `d`.

However, in the context of `obtain_split_point_props`, `x'` is the lower bound of the interval `[x',y']` and `h_pt : ∃ p, inClosedInterval x' y' (extendPoint p)` provides a point in `[x',y']`. If this point is ≤ d, it is a witness in `[x',d]`. If > d, we need a point below d.

The cut elements provide points below d. The gap assumption in the GHR93 framework ensures that in M_r, the interval `(x', d)` contains actual points when d is a gap — this is the "density" property of the extended carrier at gaps. This may require an additional helper lemma about the structure of ExtendedCarrier near gaps.

**Alternative approach**: Avoid the gap case entirely by strengthening `SplitPointProps` to require `h_pt_left` and `h_pt_right` as given hypotheses rather than derived facts. These would be provided by the caller with appropriate proofs. This is a structural refactoring that may be simpler than proving the density lemma.

### Evidence 3: Lemma 9 Core Difficulty

The `.base (.snce φ ψ)` case of Lemma 9 left. `left_formula_base D (.snce φ ψ)` is defined as:
```lean
.base (.untl (flatten_stavi compound) (flatten_stavi D))
```
where `compound = D ∧ B ∧ S(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D)`.

The LHS of Lemma 9 becomes:
```
temporal_truth_mu M atomMap r (extendPoint m) (.untl (flatten_stavi compound) (flatten_stavi D))
```

This is a standard Until formula in `temporal_truth_mu`. Unfolding: there exists `s > m` (actual point, mu-holds s) with `flatten_stavi D` at s, and `flatten_stavi compound` at all actual points between m and s.

The RHS requires a gap γ > m defined on the left by D with S(A,B) at γ.

The bridge is the mu-elimination: `temporal_truth_mu M atomMap r (extendPoint u) (flatten_stavi X) ↔ stavi_temporal_truth_mu M atomMap r (extendPoint u) X` for actual points u. If this holds, then:
- The Until-of-flatten_stavi at actual points reduces to Until-of-StaviFormula at actual points
- The compound `D ∧ B ∧ S(A,B) ∧ U'(⊤, B∧D) ∧ ¬U'(D, B∧D)` being satisfied at all actual points in (m,s) means D, B, S(A,B), U'(⊤,B∧D), ¬U'(D,B∧D) all hold at all actual points in (m,s)
- This is precisely the condition for a gap definable on the left by D to exist above m with S'(A,B) holding at the gap

The mu-elimination helper would be:
```lean
theorem flatten_stavi_eq_stavi_truth_mu (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) (r : Nat)
    (m : M.carrier) (A : StaviFormula) :
    temporal_truth_mu M atomMap r (extendPoint m) (flatten_stavi A) ↔
    stavi_temporal_truth_mu M atomMap r (extendPoint m) A
```

If provable (~50–80 lines by induction on A), this would unlock both the `.base (.snce)` and `.stavi_snce` cases.

---

## Confidence Level

**High confidence** on:
- The exact sorry count and locations (verified by grep, source reading, and consistency with handoff files)
- Cases I and II being sorry-free (verified by source inspection: no sorry in their bodies)
- The d-consistency sorries being derivable from the winning condition structure (mathematical argument traced through the code)
- Lemma 9 being the central bottleneck (~350–400 lines total for both directions)

**Medium confidence** on:
- The mu-elimination helper being provable by structural induction on `flatten_stavi` (~50–80 lines). The induction structure of `flatten_stavi` is:
  - `.base φ`: `flatten_stavi (.base φ) = φ`, so `temporal_truth_mu` of φ vs `stavi_temporal_truth_mu` of `.base φ` = `temporal_truth_mu` of φ — tautological.
  - `.neg A`: `flatten_stavi (.neg A) = Formula.neg (flatten_stavi A)`, matches `.neg` case.
  - `.conj A B`: `flatten_stavi (.conj A B) = Formula.and (flatten_stavi A) (flatten_stavi B)`, matches.
  - `.stavi_untl A B` and `.stavi_snce A B`: these use `until`/`since` operators in `temporal_truth_mu` vs `stavi_temporal_truth_mu` -- should align since at actual points, the mu-restricted and standard temporal connectives agree.
  The key concern is whether `temporal_truth_mu` for `.untl`/`.snce` and `stavi_temporal_truth_mu` for `.stavi_untl`/`.stavi_snce` have the same unfolding at actual points.
- The sub-interval point witnesses in the gap case requiring a density lemma about ExtendedCarrier.

**Lower confidence** on:
- The exact formulation of the SplitPointProps refactoring as an alternative to closing lines 336/345/351/356. A structural refactoring could break the Cases I and II proofs which already use SplitPointProps.
- The rank-varying Theorem 6 being straightforward (~30–50 lines). The type-level complexity of rank_embed may cause issues.

---

## Summary Table: All 13 Sorries

| # | File | Line | Sorry | Difficulty | Blocks | Can Start Now |
|---|------|------|-------|------------|--------|---------------|
| S1 | EFG | 1423 | Lemma 9 left | Hard (200+) | Case III, line 446 | Yes |
| S2 | EFG | 1442 | Lemma 9 right | Medium (50+) | Case IV | After S1 |
| S3 | EFG | 2423 | Lemma 11 bwd | Medium (80-120) | Prop 7 | Yes |
| S4 | EFG | 2495 | stavi_expressive | Medium (80-100) | — (final) | After Props 6,7 |
| S5 | EXP | 297 | d-consistency left | Medium (30-50) | sigma/tau derivation | Yes |
| S6 | EXP | 307 | d-consistency right | Medium (30-50) | sigma/tau derivation | Yes |
| S7 | EXP | 336 | h_pt_left gap | Medium (20-30) | sigma derivation | Yes |
| S8 | EXP | 345 | h_pt_right gap | Medium (20-30) | tau derivation | Yes |
| S9 | EXP | 351 | h_pt_xc_w gap | Medium (20-30) | SplitPointProps.h_pt_xc | Yes |
| S10 | EXP | 356 | h_pt_cy_w gap | Medium (20-30) | SplitPointProps.h_pt_cy | Yes |
| S11 | EXP | 446 | c construction gap | Hard (50-80) | sigma/tau | After S1 |
| S12 | EXP | 2350 | Cases III-IV | Very Hard (350+) | main theorem | After S1-2, S5-11 |
| S13 | EXP | 2571 | rank-varying Thm 6 | Easy (30-50) | Prop 6/7 | After S12 |

**Critical path**: S5→S6→S7→S8→S9→S10→S1→S2→S11→S12→S13→Props 6,7→S4
**Parallel**: S3 (Lemma 11 bwd) can proceed concurrently with S1 work.

---

## Recommended Immediate Next Steps

1. **Close S5, S6, S7, S8, S9, S10** — all inside `obtain_split_point_props`. These 6 sorries are mathematically tractable given the current infrastructure. Closing them reduces `obtain_split_point_props` to 1 sorry (S11, the gap case of c construction). This makes the entire inductive step correct except when d is a gap.

2. **Develop the mu-elimination helper** — `flatten_stavi_eq_stavi_truth_mu`. This is the key prerequisite for Lemma 9's hard cases and should be developed before attempting the full Lemma 9 proof.

3. **Prove Lemma 9 left (S1)** — using the mu-elimination helper. Proceed case by case, deferring the `.base (.snce)` and `.stavi_snce` cases until the helper is established.

4. **Prove Lemma 9 right (S2)** — mechanically dual to S1.

5. **Close S11** (c in gap case of `obtain_split_point_props`) — using Lemma 9.

6. **Write Cases III and IV (S12)** — using Lemma 9 and the now-proved split point infrastructure.

7. **Close S3** (Lemma 11 backward) — tractable independently, can be done in parallel with steps 1-6.

8. **Write Propositions 6, 7, Corollary 5** — completing the chain to `stavi_expressive_completeness`.

9. **Close S13** (rank-varying Theorem 6) — straightforward transport once S12 is done.
