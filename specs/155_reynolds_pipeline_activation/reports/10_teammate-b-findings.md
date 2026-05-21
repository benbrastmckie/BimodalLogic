# Task 155 Phase 4C: Alternative Approaches Research (Teammate B)

**Date**: 2026-05-20
**Focus**: Alternative mathematical approaches and proof strategies for the 13 remaining sorry sites
**Files examined**:
- `specs/155_reynolds_pipeline_activation/plans/07_reynolds-pipeline-plan.md`
- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` (2498 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressivenessGeneral.lean` (2574 lines)
- `Theories/Bimodal/Metalogic/WeakCanonical/StaviConnectives.lean`
- All handoff documents (phase-4C1, phase-4C2)
- Prior research reports 11–14

---

## Key Findings

### 1. The Sorry Map (Current State)

**EFGames.lean** (4 source-level sorries):
- Line 1423: `left_formula_gap_detection` (Lemma 9 left)
- Line 1442: `right_formula_gap_detection` (Lemma 9 right)
- Line 2423: `ghr93_decomposition_implies_game` (Lemma 11 backward)
- Line 2495: `stavi_expressive_completeness` (Corollary 5)

**ExpressivenessGeneral.lean** (9 source-level sorries):
- Line 297: d-consistency left hypothesis in `obtain_split_point_props`
- Line 307: d-consistency right hypothesis in `obtain_split_point_props`
- Lines 336, 345: N-side sub-interval point witnesses (gap case) in `obtain_split_point_props`
- Lines 351, 356: M-side sub-interval point witnesses (gap case) in `obtain_split_point_props`
- Line 446: Gap case of `obtain_split_point_props` (c existence when d is a gap)
- Line 2350: `ghr93_cases_III_IV` (both gap cases)
- Line 2571: rank-varying Theorem 6 version

The plan's sorry count of 13 matches: 4 + 9 = 13.

### 2. D-Consistency Sorries (Lines 297, 307): Restructuring Approach

**The problem**: `h_d_consistent_left/right` requires that for any padded selection with `c` at position `n` (resp. `0`), the strategy's N-side response at that position must equal `d`. This is the weakest link in the current architecture.

**Why the current approach cannot be proved without structural change**: The proof would require showing that the (4+3n)-round game strategy is *deterministic in the boundary response* — that placing `c` at the last selection position always forces the N-side response to be `d`. This is false for an arbitrary winning strategy (strategies can respond differently to different histories that all end with `c`).

**Alternative A: Redefine d as the strategy's canonical response (Recommended)**

Instead of setting `d = a_bwd(n)` and then needing `h_d_consistent`, define `d` by playing the forward game's Round 1 with a *canonical* selection sequence. Specifically:
1. Play the forward game with 1 selection `x` (via round_mono down to 1 round): get response `a'_full_1(0)` in `[x',y']`.
2. Set `d := a'_full_1(0)`.

Now `d` is by definition the strategy's response to a canonical play. The consistency condition `h_d_consistent` becomes `rfl` for that specific play.

**Trade-off**: This definition of `d` is not equal to `a_bwd(n)`. Instead, `hd_eq_an` becomes a separate lemma requiring proof that `d ≤ a_bwd(n)` (not equality). Case analysis in `ghr93_case_I` and `ghr93_case_II` would need adjustment. However, the h_d_consistent sorries (lines 297, 307) are fully eliminated — saving ~100 lines of currently-unprovable code, at the cost of ~30 lines to reprove the `d ≤ a_n` relationship.

**Net savings**: 2 sorries closed, architecture becomes provable.

**Alternative B: Add ConditionallyCompleteLattice instance on ExtendedCarrier (Expensive)**

This is the full GHR93 approach: define `d = inf{ response to padded plays with boundary c }`. The consistency property becomes trivially true because `d` is the infimum. However, `ExtendedCarrier M atomMap r` is a `Sum` type and building a `ConditionallyCompleteLattice` instance requires proving that bounded sets of extended elements always have a supremum. This is non-trivial (~200-300 lines) and may require additional axioms or classical arguments about the order topology of the extended structure.

**Alternative C: Parameterize the inductive hypothesis differently (Low risk)**

Observe that `h_d_consistent` is used only inside `obtain_split_point_props` to call `ghr93_strategy_restrict_left/right`. The strategy restriction lemmas themselves are sorry-free once `h_d_consistent` is given. One approach: change `ghr93_strategy_restrict_left` to take `d` as the *output* (not input) by having it compute `d` internally as the response to the canonical play with `c` at the last position. This absorbs `h_d_consistent` into the restriction lemma itself.

**Recommended**: Alternative A or C. Both eliminate the d-consistency sorries without requiring new axioms or ConditionallyCompleteLattice.

### 3. Sub-Interval Point Witnesses (Lines 336, 345, 351, 356)

**The problem**: When split point `d` is a *gap* (not a point), we need to prove that the intervals `[x',d]` and `[d,y']` each contain an actual N-point. Similarly for the M-side split `c`.

**Current code**: The proof correctly handles the case where `d` is a point (takes `d` itself as the witness). The gap cases at lines 336, 345, 351, 356 are sorry'd with the comment "density within [x',d]."

**Why the current sorry is structurally necessary**: If `d = Sum.inr g` for a gap `g`, then `d` is not a point and cannot witness itself. The interval `[x',d]` has points in its interior only if the gap's cut is non-empty and has elements with lower bound `x'`. This is not guaranteed in general without a density argument.

**Alternative A: Add density hypothesis to the theorem chain (Recommended)**

Add `h_dense : ∀ (a b : ExtendedCarrier M atomMap r), a < b → ∃ p : M.carrier, a < extendPoint p ∧ extendPoint p < b` to `ghr93_forward_to_backward`. This is true for ordered monadic structures that arise in the GHR93 setting (structures are always non-empty and have enough points). Adding the hypothesis eliminates 4 sorries immediately.

**Trade-off**: The hypothesis must propagate to callers. `stavi_expressive_completeness` would need to verify density for the particular structures it uses. However, since all structures in the GHR93 proof are actual temporal models (with carrier = some carrier type), density of actual points in any open interval should follow from the hypotheses already present (e.g., `h_pt`).

**Alternative B: Derive point existence from gap structure properties**

A gap `g : Gap T` has a non-empty cut. For any point `p ∈ g.cut`, `extendPoint p < Sum.inr g` (by definition of the extended ordering: `x ∈ g.cut ↔ extendPoint x < Sum.inr g`). So if we also know `x' ≤ extendPoint p` (i.e., `p` is above the lower bound), this witnesses `[x',d]`.

**Key question**: Is there always a point `p ∈ g.cut` with `p ≥ x'`? This requires that `x'` is strictly below the gap (which follows from `x' ≤ d = Sum.inr g`). The ordering `x' ≤ Sum.inr g` means either `x' = Sum.inr g` (impossible since `x'` could be a gap too) or `x' < Sum.inr g`. When `x'` is a point `extendPoint q`, then `q ∈ g.cut` (by definition). But `g.cut` is non-empty, so by downward-closure, *any* element `p` with `q ≤ p` and `p ∈ g.cut` works. The gap's cut has no supremum (by definition), so there exist points in `g.cut` arbitrarily large — in particular, there exists `p ∈ g.cut` with `p ≥ q`.

**Concretely**: When `x' = extendPoint q` and `d = Sum.inr g`:
- `q ∈ g.cut` (since `extendPoint q < Sum.inr g` means `q ∈ g.cut`)
- `g.cut` has no supremum, so `∃ p ∈ g.cut, p ≥ q` follows from classical choice
- `extendPoint p` witnesses `[x', d]`

This argument closes lines 336 and 345 when `x'` is a point. When `x'` is itself a gap `Sum.inr g'`, then `g'.cut ⊆ g.cut` (since `Sum.inr g' ≤ Sum.inr g` means `g'.cut ⊆ g.cut`). Pick any `p ∈ g.cut \setminus g'.cut` (exists since `g.cut` properly contains `g'.cut` by the no-supremum condition). Then `extendPoint p` lies in `(x', d)`.

**Savings**: 4 sorries closed without adding new hypotheses. Requires ~30-50 lines of classical argument per case. **This is the recommended approach** for lines 336, 345. Lines 351, 356 are the M-side versions and follow symmetrically.

### 4. Obtain_split_point_props Gap Case (Line 446)

**The problem**: When `d` is a gap (not a point), the code needs to find `c : ExtendedCarrier M atomMap r` with matching rank-type. This is done by applying Lemma 9 and requires the gap detection formulas to be proved.

**Current state**: Sorry'd with comment "requires Lemma 9 to be fully proved (~400-500 lines) plus ~100 lines of case analysis here."

**Alternative: Restructure to always produce a point `c`**

In the GHR93 paper, `c` is always a *point* (not a gap) in `M`. The paper sets `c = extendPoint b_c` where `b_c` is the Round-2 response when Round-2 is triggered with the point corresponding to the gap's "right endpoint" (the infimum of the complement of the gap's cut). This approach requires:
1. Extracting a canonical M-point that is "compatible" with the gap `d` in N
2. Using formula agreement (from the forward game's winning condition) to ensure the M-side point has matching rank-r type

**Concretely**: The forward (4+3n)-round game guarantees formula agreement at all positions. Playing it with 1 round (via round_mono), we can query it with `d` as the "spoiler challenge" in some sense. For a gap `d = Sum.inr g_d`, the Round-2 challenge must be an actual point. The protocol: play Round 1 with any 1 element, then play Round 2 with an actual point in `[x', y']` — the response `c` is a point in `[x, y]`.

The key insight from GHR93: the forward game at Round 2 always responds to actual points with actual points (since Round 2's challenge is an actual point and the response preserves IsPoint/IsGap by the winning condition). So `c = extendPoint b_c` for some `b_c : M.carrier`.

**Trade-off**: This approach changes `SplitPointProps` to require `IsPoint c` explicitly. Cases III-IV of the main theorem are unaffected (they deal with the *N-side* gap `a_n`, not with `c`). Cases I-II should still work since `c` being a point is not contradicted.

**Savings**: Line 446 (gap case of c-finding) gets closed by the restructuring, saving ~100 lines of Lemma-9-dependent code and removing one sorry at line 446.

### 5. Lemma 9 (EFGames.lean Lines 1423, 1442)

**The problem**: `left_formula_gap_detection` and `right_formula_gap_detection` require proving that the syntactic `left_formula A D` semantically detects gap properties via `stavi_temporal_truth_mu`. The proof is by structural induction on `A` with 5 StaviFormula constructors (neg, conj, stavi_untl, stavi_snce) and 5 base Formula constructors (atom, bot, imp, box, untl, snce).

**The flatten_stavi bottleneck**: The `.snce` and `.stavi_snce` cases use `flatten_stavi` to encode standard Until/Since of Stavi-enriched subformulas as base Formulas. The existing `flatten_stavi_correct` theorem works for discrete orders with non-mu-relativized truth. For Lemma 9, we need a `flatten_stavi_correct_mu` variant that:
1. Works on the extended carrier `M_r` (which has gaps, not discrete)
2. Uses `temporal_truth_mu` (mu-relativized, restricts to actual points)
3. Is evaluated at actual points `extendPoint m`

**Alternative A: Prove flatten_stavi_correct_mu as a new lemma (~100 lines)**

The key insight: at an actual point `extendPoint m`, `temporal_truth_mu` for standard Until/Since reduces to `stavi_temporal_truth_mu` when the formula is in the image of `flatten_stavi`. Specifically:
- `flatten_stavi (stavi_untl A B)` = a standard `untl` formula
- Evaluating via `temporal_truth_mu` at an actual point: all temporal quantifiers range over mu-points (actual points), which precisely matches what `stavi_temporal_truth_mu` does for the `stavi_untl` case
- The translation commutes at actual points

This would require proving one master lemma: `∀ A, stavi_depth A ≤ r → ∀ m : M.carrier, temporal_truth_mu M atomMap r (extendPoint m) (flatten_stavi A) ↔ stavi_temporal_truth_mu M atomMap r (extendPoint m) A`.

Then the `.snce` and `.stavi_snce` cases of Lemma 9 reduce to applying this master lemma. **This is the key missing piece for Lemma 9**.

**Estimated effort**: flatten_stavi_correct_mu (~100 lines) + Lemma 9 proper (~200-250 lines = 300-350 total for both directions). This matches the plan estimate.

**Alternative B: Restructure left_formula to avoid flatten_stavi entirely**

The `.snce` case of `left_formula_base` uses `flatten_stavi` because `StaviFormula` has no "standard Until of StaviFormulas" constructor. An alternative: introduce a new `StaviFormula` constructor `stavi_base_untl (A B : StaviFormula) : StaviFormula` with semantics "standard Until but arguments are StaviFormulas." Then:
- `left(S(A,B), D)` becomes `stavi_base_untl compound D` directly
- No flatten_stavi needed in the definition
- `stavi_depth (stavi_base_untl A B) = max (stavi_depth A) (stavi_depth B) + 2`
- Lemma 9 for this case becomes: unfolding `stavi_base_untl` semantics directly

**Trade-off**: Adding a new constructor to `StaviFormula` requires modifying all match statements (stavi_temporal_truth, stavi_depth, flatten_stavi, left_formula, right_formula, etc.). This is a large refactor (~50-100 lines changed across multiple files). However, it makes Lemma 9 cleaner.

**Verdict**: Alternative A is much lower risk. Alternative B is a significant refactor with uncertain benefit.

### 6. Lemma 11 Backward (EFGames.lean Line 2423)

**The problem**: `ghr93_decomposition_implies_game` requires constructing a Duplicator strategy from decomposition agreement. Round-1 response is given by the forward direction of decomposition_agreement. Round-2 requires: for any actual point `b' : N.carrier` in `[x',y']`, find an actual point `b : M.carrier` in `[x,y]` with matching rank-type and formula agreement.

**Alternative: Prove it as a consequence of `ghr93_forward_to_backward` rather than directly**

Observation: `ghr93_game_iff_decomposition` is stated as an iff. If we have:
1. Decomposition agreement `h` (M_r and N_r agree on all (n;r)-decomposition formulas)
2. A backward game `h_bwd : ghr93_duplicator_wins N M atomMap n r x' y' x y`

Then `ghr93_game_implies_decomposition h_bwd` (already proved) gives that the backward game implies decomposition agreement in the other direction. But we need the forward game.

**Key question**: Is `ghr93_decomposition_implies_game` actually needed for `stavi_expressive_completeness`? Looking at the dependency chain:
- `stavi_expressive_completeness` at line 2495 is currently `sorry`
- `Proposition 6` (not yet written) uses `decomposition_agreement` to get game wins
- `Proposition 7` (not yet written) uses `ghr93_game_iff_decomposition`

If Proposition 7 can be stated using only the forward direction of Lemma 11 (already proved), then `ghr93_decomposition_implies_game` might not be needed until a later stage. **This is worth verifying before implementing.**

**Alternative: Use ghr93_forward_to_backward directly in the assembly**

The assembly plan (Propositions 6, 7, Corollary 5) could potentially bypass Lemma 11's backward direction by appealing directly to `ghr93_forward_to_backward`. The decomposition formulas serve as an intermediate: they let us transfer "formula agreement" (a semantic condition) into "game wins" (a game-theoretic condition). If we can express this transfer directly using `ghr93_forward_to_backward`, we save one sorry.

**Verdict**: This needs careful analysis of the GHR93 paper's Section 8 (Proposition 7 specifically). If Proposition 7 uses only the forward direction of Lemma 11, line 2423 can be deferred. ~20 lines of analysis to determine. **Potentially 1 sorry saved with no new proof work.**

### 7. Assembly: Propositions 6-7 and Corollary 5

**Could we skip Proposition 7 (composition) and prove Corollary 5 more directly?**

Corollary 5 = `stavi_expressive_completeness` asserts: for any MonadicFormula ψ of quantifier depth n, there exists a StaviFormula A such that M |= A(t) ↔ M |= ψ(t) for all M, t.

**Standard GHR93 route**: Use Proposition 7 (composition + Theorem 6) to show that n-equivalence (agreement on all rank-n StaviFormulas) implies same satisfaction of all monadic FO sentences of depth n. Then pick A as the conjunction of all rank-n StaviFormulas true at t in some canonical model.

**Alternative direct route**: 
1. Fix ψ of quantifier depth n.
2. For each possible "n-type" τ (element of `NormalForm sig n 1`), define A_τ = the conjunction of all StaviFormulas of depth ≤ game_depth(n) that characterize τ.
3. The set of types realized in structures satisfying ψ is finite (since NormalForm is finite). Let A = disjunction of A_τ for all τ in this set.
4. Show: M |= A(t) ↔ (the n-type of (M,t) is in the set) ↔ M |= ψ(t).

This route requires:
- A lemma: if two pointed structures (M,t) and (N,s) have the same n-type, then Duplicator wins the game G_{n; game_depth(n)}. This is essentially Proposition 6 but stated differently.
- A lemma: if Duplicator wins G_{n; game_depth(n)}(M,t; N,s), then (M,t) and (N,s) satisfy the same MonadicFormulas of depth n. This uses Theorem 6 (forward-to-backward) plus the EF game characterization.

**Assessment**: This direct route is essentially equivalent to the standard route but reorganized. It does not save any sorry-closing work — the same mathematical content is needed. However, it may allow a cleaner Lean encoding that avoids some of the intermediate Proposition 7 infrastructure.

**Verdict**: The direct route is worth attempting if Proposition 7's composition argument proves unwieldy. Estimated effort is comparable.

---

## Recommended Approach

**Priority order for sorry elimination, by bang-per-buck:**

1. **Sub-interval point witnesses via gap structure (lines 336, 345, 351, 356)** — 4 sorries, ~40-60 lines total. Use the argument that `g.cut` has no supremum so contains points above any given lower bound. No new infrastructure needed. Classical choice suffices.

2. **Restructure c-finding for gap case (line 446)** — 1 sorry, ~50 lines. Change `obtain_split_point_props` to always produce `c = extendPoint b_c` by playing Round 2 of the forward game. This makes `SplitPointProps.hc_is_point : IsPoint c` available and eliminates the gap case.

3. **Restructure d-consistency (lines 297, 307)** — 2 sorries, ~30 lines restructuring + ~30 lines reproof. Change d to be the strategy's canonical response (Alternative A from Finding 2). This makes d-consistency `rfl` by definition. The trade-off is that `hd_eq_an` becomes `d ≤ a_bwd(n)` rather than equality; Case II proof needs adjustment.

4. **Prove flatten_stavi_correct_mu (new lemma, ~100 lines)** — unblocks Lemma 9. The master lemma `temporal_truth_mu M r (extendPoint m) (flatten_stavi A) ↔ stavi_temporal_truth_mu M r (extendPoint m) A` is the key missing piece for all of Lemma 9's hard cases.

5. **Prove Lemma 9 left + right (lines 1423, 1442)** — 2 sorries, ~200-250 lines total given flatten_stavi_correct_mu. Proof is by structural induction; easy cases (neg, conj, stavi_untl, atom, bot, box) can be dispatched quickly; hard cases (untl, snce, stavi_snce) use flatten_stavi_correct_mu.

6. **Cases III/IV (line 2350)** — 1 sorry, ~230 lines. Depends on Lemma 9 (step 5). Once Lemma 9 is proved, Cases III/IV follow the strategy outlined in report 14.

7. **Lemma 11 backward (line 2423)** — 1 sorry, ~80-120 lines. Verify whether Proposition 7 can use forward Lemma 11 only (potentially saves this sorry entirely).

8. **Propositions 6-7 and Corollary 5 (line 2495)** — 1 sorry, ~350-450 lines. Assembly once everything above is done.

**Unchanged from plan**: Cases I-IV structure, the rank-varying version (line 2571), and all downstream phases (5', 6, 7, 8, 9) remain as planned.

---

## Evidence/Examples

### Evidence for Gap Witness Approach (Finding 3)

The `Gap` structure in EFGames.lean defines (lines 263-268):
```lean
no_sup : ¬∃ s, IsLUB cut s ∧ s ∈ cut
complement_no_min : ¬∃ m, m ∉ cut ∧ ∀ y, y ∉ cut → m ≤ y
```

The `no_sup` field directly implies: for any `q ∈ g.cut`, there exists `p ∈ g.cut` with `p > q` (otherwise `q` would be a supremum). By classical choice, we extract such `p`. The extended ordering gives `extendPoint q ≤ extendPoint p < Sum.inr g = d`. So `extendPoint p ∈ [x', d]` when `q ≥ x'` as a point.

### Evidence for flatten_stavi_correct_mu (Finding 5)

`flatten_stavi_correct` in StaviConnectives.lean is proved for discrete orders using `stavi_U_discrete_equiv`. The mu-relativized version replaces "quantify over all M.carrier points" with "quantify over mu-holds elements." At actual points `extendPoint m`, the mu-holds predicate is exactly "is a point" = "is an `inl` element." Since `temporal_truth_mu` already restricts Until/Since to `mu_holds s` witnesses, evaluating `flatten_stavi A` via `temporal_truth_mu` at `extendPoint m` is equivalent to evaluating `A` via `stavi_temporal_truth_mu` at `extendPoint m`. The induction mirrors `flatten_stavi_correct` but uses `temporal_truth_mu` throughout.

### Evidence for d-Consistency Restructuring (Finding 2)

The handoff document (phase-4C2) explains: "Root cause: d (N-side split point) was taken as a parameter with type/gap-point agreement, but the strategy's response to c (a'_full(n)) may differ from d." This confirms that Alternative A (define d FROM the strategy response) is the correct fix. The current sorry at lines 297, 307 is not a proof gap but an architectural mismatch that requires restructuring.

---

## Confidence Level

| Finding | Confidence | Basis |
|---------|-----------|-------|
| Sub-interval point witnesses via gap.no_sup | **High** | Direct mathematical argument, Gap structure definition confirmed in code |
| d-consistency restructuring | **High** | Handoff analysis confirms architectural mismatch; Alternative A is well-motivated |
| flatten_stavi_correct_mu as key lemma | **High** | The connection between flatten_stavi and mu-relativized truth is well-understood; the induction mirrors existing proof |
| Lemma 9 difficulty and effort | **High** | Structural analysis complete, flatten_stavi bottleneck identified |
| Lemma 11 backward may be avoidable | **Medium** | Requires verifying Proposition 7 structure in GHR93 paper; mathematical content not yet fully analyzed |
| Direct Corollary 5 route comparable effort | **Medium** | The route exists but whether it saves lines depends on implementation details |

**Overall assessment**: The 13 sorries can be closed without any new axioms, sorry deferral, or shortcuts. The recommended sequence saves approximately 3-4 sorries relative to the current plan's approach by exploiting gap structure properties and restructuring the d-consistency architecture. The biggest single investment remains Lemma 9 (~300-350 lines), which is unavoidable for Cases III/IV.
