# Report: Tactic Needs Beyond Task 195 for Closing Task 155

## Context

Task 155 has 9 remaining sorries. Task 195 (EF game automation: `game_tuple_simp`, `solve_same_order_type`, `pivot_order`, `winning_condition_tac`) addresses the 2 Phase 1 same_order_type blockers at lines ~3199 and ~3403. This report analyzes the other 7 sorry sites and all future phases (3-11) to identify additional tactic opportunities beyond task 195.

---

## Part 1: Per-Sorry Analysis (7 Non-Same-Order-Type Sorries)

### Sorry 1: `h_d_unique` (Line 1708, Phase 1)

**Goal state**:
```
forall (t' : ExtendedCarrier N atomMap r),
  inClosedInterval x' y' t' ->
  (forall A, stavi_depth A <= r -> (truth t' A <-> truth d A)) ->
  (IsPoint t' <-> IsPoint d) -> (IsGap t' <-> IsGap d) ->
  (x' = t' <-> x' = d) -> (t' = y' <-> d = y') -> t' = d
```

**Pattern**: Uniqueness of infimum response. Given an element t' that agrees with d on all rank-r formulas, gap/point status, and boundary position, prove t' = d. This is GHR93 Claim 1.

**Available context**: `hd_glb` (d is GLB of S_C), `hd_is_inf` (infimum property), `h_mono_left_r1` (rank r+1 forward game), continuation_set infrastructure.

**Proof approach**: This is the core Claim 1 argument from GHR93 pp.117-118. It requires a 2-step contradiction argument: (1) d <= t' via rank r+1 formula transfer showing continuation fails below d, (2) t' <= d symmetrically. The proof is fundamentally mathematical, not pattern-based.

**Tactic benefit**: NONE. This is a one-off mathematical argument (~80-120 lines). The rank r+1 game play and continuation_set properties are specific to this lemma. No other sorry site has a similar shape.

---

### Sorry 2: Case 3 infimum gap construction (Line 1613, Phase 3)

**Goal state**:
```
exists d, inClosedInterval x' y' d /\
  (forall s in S_C, d <= s) /\ d <= a_bwd(n) /\
  forall e, (forall s in S_C, e <= s) -> e <= d
```

**Context**: `h_has_glb` negated (no carrier-point GLB), `h_ne` (S_C nonempty), `h_pt_below` (carrier-point lower bound exists).

**Pattern**: Precondition assembly for `infimum_gap_r_definable`. The sorry needs to:
1. Show h_above condition: exists q above an element of S_C
2. Show hx'_bound condition: exists p0 in inf_carrier_cut with x' <= p0
3. Show h_above_gap_below_y' condition: exists q0 not in cut, below y', above x'
4. Call `infimum_gap` + `infimum_gap_r_definable`
5. Prove the 4-part existential

**Tactic benefit**: LOW. This is precondition assembly -- gathering 3 witnesses from the context. The `infimum_gap_r_definable` signature has specific preconditions (`hx'_bound`, `h_above_gap_below_y'`) that require case-specific reasoning about which carrier points exist above/below the gap. Not a repeating pattern.

**Estimated effort**: ~50-80 lines of manual proof.

---

### Sorry 3: `h_pt_xc` degenerate gap (Line 1803, Phase 3)

**Goal state**:
```
exists p, inClosedInterval x c (extendPoint p)
```

**Context**: `hxc_eq : x = c`, `hg_c : c = Sum.inr g_c` (c is a gap).

**Pattern**: Degenerate interval point witness. When x = c and c is a gap, we need a point in [x, c] = [gap, gap]. This is impossible -- a degenerate interval at a gap contains no points.

**What's actually needed**: The plan (Task 3.1) says to restructure `SplitPointProps.h_pt_xc` to conditional form `x < c -> exists p, ...`. With the conditional form, this sorry disappears because x = c means the condition `x < c` is false.

**Tactic benefit**: NONE directly. This sorry is eliminated by a structural refactoring (making h_pt_xc conditional), not by a tactic.

---

### Sorry 4: `h_pt_cy` degenerate gap (Line 1820, Phase 3)

**Goal state**:
```
exists p, inClosedInterval c y (extendPoint p)
```

**Context**: `hcy_eq : c = y`, `hg_c : c = Sum.inr g_c`.

**Pattern**: Identical to Sorry 3. When c = y and c is a gap, [c, y] is degenerate at a gap.

**Tactic benefit**: NONE. Same structural fix as Sorry 3.

---

### Sorry 5: n=0 gap case c construction (Line 1918, Phase 3)

**Goal state**:
```
exists c, inClosedInterval x y c /\
  (forall A, stavi_depth A <= r -> (truth_M c A <-> truth_N d A)) /\
  ((IsPoint c <-> IsPoint d) /\ (IsGap c <-> IsGap d)) /\
  (x = c <-> x' = d) /\ (c = y <-> d = y')
```

**Context**: `hn : n = 0`, `hg' : d = Sum.inr g'` (d is a gap), `h_bwd_n` (0-round backward game), `h_pt_M` (point witness in [x,y]).

**Pattern**: Gap c-construction for the degenerate n=0 case. When n=0, the backward game has 0 rounds and cannot be played to find c via the standard backward-game mechanism (which requires n >= 1). Instead, c must be found via Lemma 9 gap detection.

**Proof approach**: Apply `left_formula_gap_detection` or `right_formula_gap_detection` to d's defining formula D. The forward game gives formula agreement between (x,y) and (x',y'), which transfers the gap detection formula to M, yielding a matching gap c.

**Tactic benefit**: LOW-MEDIUM. The pattern of "use Lemma 9 to transfer a gap from N to M" appears here AND in Cases III/IV (Sorry 7). A helper lemma `transfer_gap_via_lemma9` could factor out the common Lemma 9 invocation pattern. However, Cases III/IV have additional structure (ordering within the backward game's selections) that makes them more complex. The shared part is maybe 30-40 lines.

---

### Sorry 6: `ghr93_cases_III_IV` (Line 4404, Phase 3)

**Goal state**:
```
exists a'_resp, (forall i, inClosedInterval x y (a'_resp i)) /\
  forall b_sp, inClosedInterval x y (extendPoint b_sp) ->
    exists b_resp, inClosedInterval x' y' (extendPoint b_resp) /\
      ghr93_winning_condition (n+1) (game_tuple x' y' a_bwd b_resp)
                                     (game_tuple x y a'_resp b_sp)
```

**Context**: `props : SplitPointProps`, `h_no_split` (all selections >= d), `h_gap` (a_bwd(n) is a gap).

**Pattern**: Full backward game construction for Cases III and IV. This is the largest remaining sorry (~240-360 lines estimated). It requires:
1. Case split on left-definable vs not-left-definable
2. Gap detection formula construction (left(B,D) or right(B,D))
3. Lemma 9 application to find matching gap e_n
4. Sub-interval strategy derivation
5. Full winning condition assembly (same_order_type + gap_point + formula)

**Tactic benefit**: MEDIUM-HIGH (for the winning condition assembly sub-problem). The winning condition assembly within Cases III/IV will have the SAME 16-goal structure as Case I and Case II. If task 195's `solve_same_order_type` tactic works, it directly helps here. Beyond same_order_type:
- `gap_point_agreement` follows the same `split_ifs` + index dispatch pattern seen in Case II (lines 3304-3336)
- `formula_agreement` follows the same pattern (lines 3337-3369)

A `solve_winning_condition` tactic that handles all three components (same_order_type + gap_point + formula) at once would be the ideal tool. But this is essentially an extension of task 195's scope.

---

### Sorry 7: `ghr93_forward_to_backward_rank_varying` (Line 4659, Phase 4)

**Goal state**:
```
ghr93_duplicator_wins N M atomMap n r x' y' x y
```

**Context**: `h : ghr93_duplicator_wins M N atomMap (1+3*n) (r+4*n) (rank_embed _ x) (rank_embed _ y) (rank_embed _ x') (rank_embed _ y')`.

**Pattern**: Rank transport. Apply the uniform-rank theorem at rank r+4n, then transport back to rank r using rank_embed properties.

**Proof approach**: 
1. Apply `ghr93_forward_to_backward` at rank r+4n (needs h_r1_univ at rank r+4n+1)
2. Transport the backward strategy from rank r+4n to rank r
3. Need: if `ghr93_duplicator_wins N M atomMap n (r+4n) (rank_embed _ x') (rank_embed _ y') (rank_embed _ x) (rank_embed _ y)`, then `ghr93_duplicator_wins N M atomMap n r x' y' x y`

The key missing piece is a `ghr93_duplicator_wins_rank_down` lemma: game wins at higher rank imply wins at lower rank (since rank-r formulas are a subset of rank-(r+4n) formulas).

**Tactic benefit**: LOW. This is a one-off structural theorem (~80-150 lines). The rank_embed properties are specific to this proof. No tactic would help -- this needs a carefully constructed `ghr93_duplicator_wins_rank_down` helper lemma.

---

## Part 2: Future Phase Analysis (Phases 3-11)

### Phase 3: c-Gap-Case + M-Side Degenerate + Cases III/IV

**Patterns needed**:
1. **SplitPointProps conditional restructuring** (Tasks 3.1-3.2): Mechanical refactoring. No tactic.
2. **Infimum gap precondition assembly** (Task 3.3): One-off. No tactic.
3. **Lemma 9 gap transfer** (Tasks 3.6-3.7): Used 2-3 times (n=0 case + Case III + Case IV). A helper lemma is sufficient; a tactic is overkill.
4. **Winning condition assembly** (Tasks 3.6-3.7): Same 16-goal structure as Cases I/II. DIRECTLY benefits from task 195's `solve_same_order_type`. The gap_point and formula components follow the same `split_ifs` + index dispatch pattern.

**Tactic verdict**: Task 195 directly helps. No additional tactic needed beyond what 195 provides.

### Phase 4: Assembly Chain (Rank-Varying, Lemma 11 Backward, Props 6-7, Corollary 5)

**Patterns needed**:
1. **Rank transport** (Task 4.1): One-off rank_down lemma. No tactic.
2. **Decomposition implies game** (Task 4.2): Game construction from formula agreement. The Round 1 response comes from decomposition formulas; Round 2 uses type-matching. This is a one-off proof.
3. **Proposition 6** (Task 4.3): Formula chain C_i construction. New infrastructure, not a pattern.
4. **Proposition 7** (Task 4.4): Composition of interval strategies. Induction on n using Lemma 10 + 11 + Theorem 6. The induction structure is unique to this proposition.
5. **Corollary 5** (Task 4.5): Assembly from Props 5-7. Short wiring proof.

**Tactic verdict**: Phase 4 is mostly unique mathematical arguments. No tactic opportunity.

### Phase 5: Reynolds Theorem 5

**Pattern**: Composition of `stavi_expressive_completeness` with `flatten_stavi_correct`. Short (~60-100 lines). No tactic needed.

### Phases 6A-6B: Gap Elimination (Reynolds Lemmas 6-14)

**Patterns needed**:
1. **Model surgery** (Lemma 12): 14 sub-cases for formula preservation under restriction. The S cases are dual to U cases (6 or 7 cases each).
2. **Formula induction** pattern: Induction on formula structure (base/neg/conj/untl/snce) appears repeatedly in Lemmas 6-12.

**Tactic opportunity**: **`formula_induction_tac`** -- a tactic that handles the common formula induction boilerplate:
- Sets up the 5-case split (base/neg/conj/untl/snce or the StaviFormula constructors)
- For each case, unfolds the truth definition one level
- For neg/conj, applies the IH automatically
- Leaves untl/snce cases (which require real work) as goals

This would save ~20-40 lines per formula induction lemma. With ~8 lemmas in Phase 6 using formula induction, that is 160-320 lines saved.

However, the untl/snce cases are where ALL the difficulty lies (model surgery boundary reasoning). The tactic only automates the easy cases.

**Verdict**: MARGINAL. The boilerplate savings are real but modest. The hard work (untl/snce cases in Lemma 12) cannot be automated.

### Phase 8: Wire no_gaps_discrete

**Pattern**: Simple wiring (~20-40 lines). No tactic needed.

### Phase 11: Final Wiring

**Pattern**: Verification commands only. No tactic needed.

---

## Part 3: Tactic Recommendations

### Recommended Tactics (Ranked by Impact)

#### 1. `solve_same_order_type` (ALREADY in Task 195)

- **What it does**: Automates the 16-goal grid for `same_order_type` after `intro i j; simp only [game_tuple]; split_ifs`
- **Sorries it helps**: Lines 3199, 3403 (Phase 1), Cases III/IV (Phase 3), Case I already proved but manually
- **Impact**: HIGH -- each same_order_type proof is 80-200 lines manually
- **Status**: Being built in task 195

#### 2. `game_tuple_simp` (ALREADY in Task 195)

- **What it does**: Normalizes `game_tuple` expressions to their value-level form using the `game_tuple_zero_eq`/`_b_eq`/`_y_eq`/`_sel_eq` lemmas
- **Impact**: HIGH -- used 75+ times in the codebase currently as manual `simp only [game_tuple_*_eq]` calls
- **Status**: Being built in task 195

#### 3. `winning_condition_tac` (ALREADY in Task 195)

- **What it does**: Combines `solve_same_order_type` + `gap_point_dispatch` + `formula_dispatch`
- **Impact**: HIGH for Phase 3 Cases III/IV
- **Status**: Being built in task 195

#### 4. `point_witness_interval` -- NEW Recommendation

- **What it does**: Given `h : x <= y`, `hp : IsPoint x` or `hp : IsPoint y` or `hp : exists p, x < extendPoint p < y`, prove `exists p, inClosedInterval x y (extendPoint p)`.
- **Pattern frequency**: This exact pattern appears at lines 1737-1738, 1752-1760, 1768-1769, 1787-1796, 1799-1815, 1816-1832, plus will recur in every future proof that constructs `SplitPointProps` or uses `h_pt_xc`/`h_pt_cy`.
- **What it automates**: The 3-way case analysis (is x a point? is y a point? use point_between_strict_gaps) that currently takes 5-15 lines each time.
- **Estimated implementation**: 30-50 lines
- **Which sorries it helps**: Indirectly helps Sorries 3-4 (after conditional restructuring, downstream sites still need point witnesses). Helps future SplitPointProps construction.
- **Priority**: LOW-MEDIUM. Saves 5-15 lines per usage, with ~6-10 usages total. Net savings: ~50-100 lines. Not blocking any sorry directly.

#### 5. `interval_bound_transfer` -- NEW Recommendation

- **What it does**: Given `inClosedInterval a b x` and `a <= c <= b`, derive `inClosedInterval a b c` or related sub-interval facts automatically.
- **Pattern frequency**: 82 occurrences of `inClosedInterval` in ExpressivenessGeneral.lean, many with manual `le_trans`, `le_of_lt`, etc.
- **Estimated implementation**: 20-30 lines
- **Priority**: LOW. The manual proofs are short (1-3 lines each). The tactic saves a few characters per usage but is not blocking anything.

### NOT Recommended (Evaluated and Rejected)

#### `infimum_gap_assembly_tac`
- **Rationale for rejection**: The precondition assembly for `infimum_gap_r_definable` (Sorry 2) is a one-off. The 3 witness conditions (`hx'_bound`, `h_above`, `h_above_gap_below_y'`) require case-specific reasoning. A tactic would need to understand the continuation_set structure, which is too specialized.

#### `rank_transport_tac`
- **Rationale for rejection**: Sorry 7 (`ghr93_forward_to_backward_rank_varying`) is a one-off theorem. The rank_embed properties are used in a unique way. A helper lemma (`ghr93_duplicator_wins_rank_down`) is the right abstraction, not a tactic.

#### `formula_induction_tac`
- **Rationale for rejection**: While formula induction appears in ~8 lemmas in Phases 6A-6B, the boilerplate (base/neg/conj) is ~20 lines per lemma and is straightforward. The hard cases (untl/snce) cannot be automated. Net savings are marginal (~160 lines) for significant implementation effort.

#### `claim1_tac` (for h_d_unique)
- **Rationale for rejection**: GHR93 Claim 1 is a unique mathematical argument. It requires rank r+1 game play, continuation_set semantics, and a 2-step contradiction. No other proof in the pipeline has a similar structure.

---

## Part 4: Summary

### What task 195 already covers
Task 195's 4 tactics (`game_tuple_simp`, `solve_same_order_type`, `pivot_order`, `winning_condition_tac`) directly address:
- The 2 Phase 1 same_order_type sorries (lines 3199, 3403)
- The winning condition assembly in Phase 3 Cases III/IV (the largest component of Sorry 6)
- Future winning condition assemblies if any appear in Phases 4-6

### What NO tactic can help with (requires manual proof)
- Sorry 1 (`h_d_unique`): Unique mathematical argument (Claim 1). ~80-120 lines.
- Sorry 2 (Case 3 infimum gap): Precondition assembly. ~50-80 lines.
- Sorries 3-4 (degenerate gaps): Eliminated by structural refactoring, not tactics.
- Sorry 5 (n=0 gap case): Lemma 9 application. ~60-100 lines.
- Sorry 7 (rank-varying): Rank transport. ~80-150 lines.

### The one new tactic worth considering
`point_witness_interval` would save 50-100 lines across the project by automating the 3-way case split (x is point? y is point? use `point_between_strict_gaps`). Implementation cost: ~30-50 lines. It is NOT blocking any sorry and is NOT urgently needed, but it would reduce proof clutter in future phases.

### Bottom line
Task 195 is the right and sufficient tactic investment for closing task 155. The remaining 7 sorries (excluding the 2 same_order_type ones) are each unique mathematical arguments that cannot be profitably automated. The only marginal additional tactic (`point_witness_interval`) saves lines but blocks nothing.
