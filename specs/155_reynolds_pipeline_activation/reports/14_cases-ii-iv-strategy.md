# Cases II, III, IV Strategy for GHR93 Theorem 6

**Task**: 155 | **Date**: 2026-05-20 | **Scope**: Closing the inductive step of ghr93_forward_to_backward

---

## 1. Current State

The sorry is at `ghr93_cases_II_III_IV` (ExpressivenessGeneral.lean:324).

**Goal context** (from lean_goal):
```
props : SplitPointProps n x y x' y' c d a_bwd
ha_bwd : forall i, inClosedInterval x' y' (a_bwd i)
h_no_split : forall i : Fin (n + 1), d <= a_bwd i
|- exists a'_resp, (forall i, inClosedInterval x y (a'_resp i)) /\
     forall b_sp, inClosedInterval x y (extendPoint b_sp) ->
       exists b_resp, inClosedInterval x' y' (extendPoint b_resp) /\
         ghr93_winning_condition (n+1) (game_tuple x' y' a_bwd b_resp)
                                       (game_tuple x y a'_resp b_sp)
```

**Key hypothesis from `SplitPointProps`**:
- `props.tau : ghr93_duplicator_wins N M atomMap n r d y' c y`
  -- an n-round backward strategy on [d,y']/[c,y]

**The central pattern**: All three cases use tau for a_0,...,a_{n-1} (the first n selections), then handle a_n (the last selection) differently depending on whether it is a point, a left-defined gap, or a non-left-defined gap.

---

## 2. The tau Sub-Sequence Extraction

All three cases share a common first step: extract the "init" sub-sequence `a_init : Fin n -> ExtendedCarrier N atomMap r` from `a_bwd : Fin (n+1) -> ExtendedCarrier N atomMap r`, defined by:

```lean
let a_init : Fin n -> ExtendedCarrier N atomMap r :=
  fun i => a_bwd (Fin.castSucc i)  -- or: a_bwd <i.val, by omega>
```

Then apply tau to a_init to get `e_init : Fin n -> ExtendedCarrier M atomMap r` and a Round-2 handler. The selections a_init are all in [d,y'] (from h_no_split), so they satisfy tau's precondition.

**Infrastructure needed**: A helper lemma showing that `Fin.castSucc` embeds `Fin n` into `Fin (n+1)` and that `a_bwd circ Fin.castSucc` maps into `[d,y']`. This is straightforward from `h_no_split` and `ha_bwd`.

**Estimated lines**: 15-20 for the helper + application.

---

## 3. Case II: a_n is a Point (U(B, A))

### 3.1 Proof Structure

When `a_n = a_bwd (Fin.last n)` is an actual point (IsPoint), say `a_n = extendPoint p_n` for some `p_n : N.carrier`:

1. **Construct B = rank_type at a_n**: `B` is the conjunction of all StaviFormulas of depth <= r true at a_n in N_r. Formally, B is an element of `Set StaviFormula` via `rank_type N atomMap r a_n`.

2. **Apply tau to a_0,...,a_{n-1}**: Get `e_init : Fin n -> ExtendedCarrier M atomMap r` in [c,y] with Round-2 handler.

3. **Find witness z in M**: Since the forward strategy preserves rank-(r+1) formulas and U(B,A) has rank r+1, we know M_r |= U(B,A)^mu at the position corresponding to a_{n-1}. Find z > e_{n-1} where B holds and A holds on (e_{n-1}, z).

4. **Set e_n = extendPoint z**: The point z in M satisfies the same rank-r type as a_n in N (both satisfy B = X_{a_n}).

5. **Construct a'_resp**: `a'_resp i = e_init i` for i < n, `a'_resp (Fin.last n) = e_n`.

6. **Round-2 handler**: For b_sp in [x,y], if b_sp is in [c,y], use tau's Round-2 handler. The winning condition combines tau's winning condition for the first n+2 indices with e_n's type match for the last index.

### 3.2 Infrastructure Gaps

**Gap 1: Rank-type as a StaviFormula**. The `rank_type` is defined as `Set StaviFormula` (the set of formulas true at a position). To use it as the formula B in U(B,A), we need to conjoin finitely many formulas. This requires:
- A lemma that the set of rank-r types is finite (follows from NormalForm finiteness)
- A function `rank_type_formula : ExtendedCarrier -> StaviFormula` that produces the conjunction
- A correctness lemma: `stavi_temporal_truth_mu M atomMap r t (rank_type_formula s) <-> rank_type M atomMap r t = rank_type M atomMap r s`

This is non-trivial (~40-60 lines) but foundational for all three cases.

**Gap 2: Until witness extraction**. We need: if `stavi_temporal_truth_mu M atomMap r e (base (untl B_flat A_flat))` holds at some position e (an actual point), then there exists an actual point z > e with B_flat at z and A_flat between e and z. This is essentially unfolding the definition of `temporal_truth_mu` for the `.untl` case. Should be ~10 lines.

**Gap 3: game_tuple merging**. Combining tau's winning condition on n+2 indices with the new e_n value at index n requires showing that `game_tuple` with the merged response equals tau's game_tuple at the embedded indices. Similar to the `base_case_emb` pattern already in the file. ~30-40 lines.

### 3.3 Estimate

- Rank-type formula construction: 50 lines (shared with Cases III/IV)
- Tau application and init extraction: 20 lines (shared)
- Until witness extraction: 15 lines
- Response construction and merging: 40 lines
- Winning condition verification: 40 lines
- **Total Case II: ~100-120 lines** (plus ~70 shared infrastructure)

---

## 4. Case III: a_n is a Left-Defined Gap (U' via left(B,D))

### 4.1 Proof Structure

When `a_n = Sum.inr g_n` for some `g_n : RDefinableGap N atomMap r`, and g_n is left-defined by some D:

1. **Extract D**: From `g_n.prop : r_definable_gap N atomMap g_n.val r`, we get `D : StaviFormula` with `stavi_depth D <= r` and `gap_definable_on_left N atomMap g_n.val D`.

2. **Construct B = rank_type formula at a_n**: Same as Case II.

3. **Construct delta = left(B, D)**: The gap detection formula. By `stavi_depth_left_formula`, `stavi_depth delta <= max(stavi_depth B)(stavi_depth D) + 4 <= r + 4`.

4. **Apply tau to a_0,...,a_{n-1}**: Get e_init in [c,y].

5. **Apply Lemma 9 (left_formula_gap_detection)**: From the fact that left(B,D) holds at some point near e_{n-1}, deduce that there exists a gap gamma in M_r that is D-defined on the left, with B^mu(gamma). Set e_n = Sum.inr gamma.

6. **Verify**: gamma and g_n have the same rank-r type (both satisfy B).

### 4.2 Dependency on Lemma 9

**Critical**: `left_formula_gap_detection` is sorry'd (EFGames.lean:1423). Case III CANNOT be completed without it.

**Can we assume Lemma 9 and prove Case III?** Yes. The proof structure of Case III uses Lemma 9 as a black box. We can write Case III with a call to `left_formula_gap_detection` and it will compile with Lemma 9's sorry propagating through. This is structurally sound -- the sorry is isolated in Lemma 9, not in the case logic.

**Lemma 9 complexity**: The full proof of `left_formula_gap_detection` requires structural induction on A with 7 cases (atom, bot, imp, box, untl, snce for base; neg, conj, stavi_untl, stavi_snce for StaviFormula). Each case connects the syntactic left_formula definition with the semantic gap properties. Estimated at 150-250 lines. This is a separate workstream.

### 4.3 Infrastructure Gap: Deciding Left-Definability

**The problem**: `RDefinableGap` only records that a gap is r-definable (left OR right). For Cases III vs IV, we need to case-split on whether a specific gap is left-defined.

**Solution**: Add a decidability predicate:

```lean
def gap_is_left_defined {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula -> sig.preds)
    (g : RDefinableGap M atomMap r) : Prop :=
  exists D : StaviFormula, stavi_depth D <= r /\
    gap_definable_on_left M atomMap g.val D
```

Then Case III assumes `gap_is_left_defined N atomMap g_n` and Case IV assumes its negation. The case split in the main theorem uses `Classical.em`.

**Lines**: ~10 for the definition, ~5 for the case split.

### 4.4 Estimate

- gap_is_left_defined definition: 10 lines (shared with Case IV)
- D extraction from left-definability: 10 lines
- delta = left(B, D) construction: 10 lines
- Lemma 9 application: 15 lines
- Gap matching and response construction: 30 lines
- Winning condition verification: 40 lines
- **Total Case III: ~115-130 lines** (assuming Lemma 9 is available)

---

## 5. Case IV: a_n is a Gap Not Left-Defined (U' via right(B,D))

### 5.1 Proof Structure

When a_n is a gap that is NOT left-defined, it must be right-defined (since it is r-definable). Then:

1. **Extract D for right**: From `g_n.prop` and `not (gap_is_left_defined ...)`, conclude that there exists D with `gap_definable_on_right N atomMap g_n.val D`.

2. **Construct B = rank_type formula at a_n**.

3. **Construct delta = A /\ neg D /\ U(right(B,D), A)**: More complex than Case III. rank(delta) <= r+3 (within the r+4 budget from the forward game's extra rank).

4. **Apply tau to a_0,...,a_{n-1}**: Get e_init in [c,y].

5. **Apply Lemma 9 (right_formula_gap_detection)**: From right(B,D) holding at some point, deduce existence of a matching gap gamma in M that is D-defined on the right.

6. **Verify**: Same rank-r type matching as Case III.

### 5.2 Extracting Right-Definability from Non-Left-Definability

**The key inference**: Given `r_definable_gap N atomMap g.val r` (exists D, left or right) and `not (gap_is_left_defined ...)`, we need to derive `exists D, gap_definable_on_right N atomMap g.val D`.

This requires a small lemma:

```lean
theorem gap_right_defined_of_not_left {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula -> sig.preds}
    {r : Nat} (g : RDefinableGap M atomMap r)
    (h : not (gap_is_left_defined M atomMap g)) :
    exists D, stavi_depth D <= r /\ gap_definable_on_right M atomMap g.val D
```

Proof: unfold `r_definable_gap` from `g.prop`, get `D` with `left or right`. The `left` case contradicts `h`. So `right` holds. ~10 lines.

### 5.3 Symmetry with Case III

Case IV is structurally parallel to Case III with these swaps:
- `left_formula` -> `right_formula`
- `left_formula_gap_detection` -> `right_formula_gap_detection`
- `gap_definable_on_left` -> `gap_definable_on_right`
- The delta construction is slightly more complex (involves A /\ neg D /\ U(right(B,D), A) rather than just left(B,D))

**Code sharing**: About 60-70% of Case III's code can be shared. The tau application, init extraction, and winning condition verification are identical. Only the gap detection formula construction and Lemma 9 application differ.

### 5.4 Estimate

- Right-definability extraction: 15 lines
- delta construction (more complex formula): 15 lines
- Lemma 9 (right) application: 15 lines
- Gap matching and response construction: 30 lines
- Winning condition verification: 40 lines
- **Total Case IV: ~115-130 lines** (assuming Lemma 9 right is available)

---

## 6. Shared Infrastructure Summary

| Component | Lines | Used By |
|-----------|-------|---------|
| a_init extraction (Fin n from Fin (n+1)) | 20 | II, III, IV |
| rank_type_formula construction | 50 | II, III, IV |
| gap_is_left_defined definition | 10 | III, IV |
| gap_right_defined_of_not_left | 10 | IV |
| game_tuple init-merge embedding | 35 | II, III, IV |
| **Total shared** | **~125** | |

---

## 7. Dependency Analysis

### Dependency Graph

```
rank_type_formula (new, ~50 lines)
  |
  v
Case II (a_n point, ~100 lines)
  - uses: tau, rank_type_formula, Until witness
  - depends on: nothing sorry'd beyond obtain_split_point_props

left_formula_gap_detection (sorry'd, ~200 lines to prove)
right_formula_gap_detection (sorry'd, ~200 lines to prove)
  |
  v
Case III (left gap, ~115 lines)           Case IV (right gap, ~115 lines)
  - uses: tau, rank_type_formula,           - uses: tau, rank_type_formula,
    left_formula_gap_detection                right_formula_gap_detection
  - depends on: Lemma 9 (left)              - depends on: Lemma 9 (right)
```

### Can Cases be Proved Independently?

- **Case II**: YES. No dependency on Lemma 9. Can be completed now. Its sorry comes only from `obtain_split_point_props` (which provides tau/sigma).
- **Case III**: Structurally yes, but the sorry from `left_formula_gap_detection` propagates. The case logic itself can be written correctly; the sorry is isolated in Lemma 9.
- **Case IV**: Same as Case III but with `right_formula_gap_detection`.

---

## 8. The ghr93_cases_II_III_IV Refactoring

The current sorry should be split into three sub-theorems:

```lean
private theorem ghr93_case_II {sig : MonadicSignature} ...
    (h_no_split : forall i, d <= a_bwd i)
    (h_point : IsPoint (a_bwd (Fin.last n))) :
    exists a'_resp, ... := by
  sorry  -- ~100 lines when filled

private theorem ghr93_case_III {sig : MonadicSignature} ...
    (h_no_split : forall i, d <= a_bwd i)
    (h_gap : IsGap (a_bwd (Fin.last n)))
    (h_left : gap_is_left_defined N atomMap
       (gap_of_isGap (a_bwd (Fin.last n)) h_gap)) :
    exists a'_resp, ... := by
  sorry  -- ~115 lines when filled

private theorem ghr93_case_IV {sig : MonadicSignature} ...
    (h_no_split : forall i, d <= a_bwd i)
    (h_gap : IsGap (a_bwd (Fin.last n)))
    (h_not_left : not (gap_is_left_defined N atomMap
       (gap_of_isGap (a_bwd (Fin.last n)) h_gap))) :
    exists a'_resp, ... := by
  sorry  -- ~115 lines when filled
```

The assembly:

```lean
private theorem ghr93_cases_II_III_IV ... := by
  rcases isPoint_or_isGap (a_bwd (Fin.last n)) with h_pt | h_gp
  . exact ghr93_case_II props ha_bwd h_no_split h_pt
  . by_cases h_left : gap_is_left_defined N atomMap (gap_of_isGap _ h_gp)
    . exact ghr93_case_III props ha_bwd h_no_split h_gp h_left
    . exact ghr93_case_IV props ha_bwd h_no_split h_gp h_left
```

**Helper needed**: `gap_of_isGap` to extract the `RDefinableGap` from an `IsGap` proof:

```lean
noncomputable def gap_of_isGap {e : ExtendedCarrier M atomMap r}
    (h : IsGap e) : RDefinableGap M atomMap r :=
  h.choose
```

---

## 9. Recommended Implementation Order

1. **Shared infrastructure** (~125 lines)
   - a_init extraction helper
   - rank_type_formula and correctness
   - gap_is_left_defined, gap_of_isGap
   - game_tuple init-merge embedding

2. **Case II** (~100 lines) -- simplest, no Lemma 9 dependency
   - This provides a template for Cases III/IV
   - Tests the tau application pattern

3. **Case III** (~115 lines) -- uses sorry'd Lemma 9 (left)
   - Write the case logic with left_formula_gap_detection call
   - Sorry propagates from Lemma 9 only

4. **Case IV** (~115 lines) -- mirror of Case III
   - Write the case logic with right_formula_gap_detection call
   - Mostly copied from Case III with left<->right swap

5. **Assembly** (~15 lines)
   - The isPoint_or_isGap + by_cases split

6. **(Later) Lemma 9** (~200-250 lines each direction)
   - Independent workstream, can be done in parallel
   - Once proved, Cases III/IV become sorry-free

---

## 10. Total Estimates

| Component | Lines | Sorries Added | Sorries Closed |
|-----------|-------|---------------|----------------|
| Shared infrastructure | 125 | 0 | 0 |
| Case II | 100 | 0 | partial (from obtain_split_point_props) |
| Case III | 115 | 0 | partial (Lemma 9 sorry propagates) |
| Case IV | 115 | 0 | partial (Lemma 9 sorry propagates) |
| Assembly | 15 | 0 | 1 (ghr93_cases_II_III_IV) |
| **Subtotal** | **~470** | **0** | **1** |
| Lemma 9 (left) | 200 | 0 | 1 |
| Lemma 9 (right) | 200 | 0 | 1 |
| **Grand total** | **~870** | **0** | **3** |

**Risk assessment**: The main risk is in Lemma 9, which involves 7 structural induction cases with complex mu-relativized temporal reasoning. Cases II-IV themselves are structurally straightforward once the infrastructure is in place. The Fin manipulation for game_tuple merging is tedious but follows the established pattern from `base_case_emb`.

---

## 11. Key Observations

1. **Case II is significantly simpler than III/IV**: It uses standard Until (already well-understood in the codebase) rather than Stavi Until with gap detection. It should be implemented first as a template.

2. **Cases III and IV are symmetric**: Approximately 70% code sharing is possible via a common helper parameterized by left/right.

3. **Lemma 9 is the true bottleneck**: Without Lemma 9, Cases III/IV compile but carry sorry. Lemma 9 is the single hardest remaining piece (~400 lines for both directions).

4. **No new axioms needed**: All constructions use existing Lean/Mathlib infrastructure (Classical.em, Classical.choice for extracting witnesses from existentials).

5. **The obtain_split_point_props sorry is upstream**: Even if all four cases are proved, the overall theorem still has sorries from `obtain_split_point_props` (split point construction). This is a separate workstream involving infimum computation on ExtendedCarrier.
