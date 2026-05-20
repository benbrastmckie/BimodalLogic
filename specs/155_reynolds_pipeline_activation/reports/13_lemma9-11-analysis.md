# Lemma 9 and Lemma 11 Sorry Analysis

## 1. Complete Sorry Inventory in EFGames.lean + ExpressivenessGeneral.lean

| # | Sorry | Location | Statement |
|---|-------|----------|-----------|
| S1 | `left_formula_gap_detection` | EFGames.lean:1423 | left(A,D)(m) iff gap exists |
| S2 | `right_formula_gap_detection` | EFGames.lean:1442 | right(A,D)(m) iff gap exists |
| S3 | `ghr93_game_implies_decomposition` | EFGames.lean:1803 | game winning -> decomposition agreement |
| S4 | `ghr93_decomposition_implies_game` | EFGames.lean:1824 | decomposition agreement -> game winning |
| S5 | `stavi_expressive_completeness` | EFGames.lean:1891 | main theorem (Corollary 5) |
| S6 | `obtain_split_point_props` (3 fields) | ExpGen.lean:203-209 | split point c,d + strategies sigma,tau |
| S7 | `ghr93_case_I` | ExpGen.lean:277 | Case I of Theorem 6 |
| S8 | `ghr93_cases_II_III_IV` | ExpGen.lean:324 | Cases II-IV of Theorem 6 |
| S9 | `ghr93_forward_to_backward_rank_varying` | ExpGen.lean:495 | Theorem 6 rank-varying version |

## 2. Dependency Graph

```
stavi_expressive_completeness (S5)
  |
  +-- Proposition 6 (not yet written)
  |     +-- decomposition formulas
  |     +-- type formulas X_t
  |
  +-- Proposition 7 (not yet written)
  |     +-- ghr93_forward_to_backward (Theorem 6)
  |     |     +-- base case: DONE (zero sorry)
  |     |     +-- inductive step:
  |     |           +-- obtain_split_point_props (S6)
  |     |           +-- ghr93_case_I (S7)
  |     |           +-- ghr93_cases_II_III_IV (S8)
  |     |                 +-- Case II: uses Until (no gap machinery)
  |     |                 +-- Case III: uses left_formula_gap_detection (S1)
  |     |                 +-- Case IV: uses right_formula_gap_detection (S2)
  |     |
  |     +-- ghr93_game_iff_decomposition (Lemma 11)
  |           +-- ghr93_game_implies_decomposition (S3)
  |           +-- ghr93_decomposition_implies_game (S4)
  |
  +-- ghr93_forward_to_backward_rank_varying (S9)
        (derived from uniform-rank version + rank embedding)
```

## 3. Question-by-Question Analysis

### 3.1 Are Lemma 9 proofs needed for Phase 4C?

**YES**, directly. Cases III and IV of Theorem 6 (in `ghr93_cases_II_III_IV`, S8) explicitly invoke Lemma 9:

- **Case III** (a_n is left-defined gap): Constructs delta = left(B, D). After finding t where delta(t) holds, applies `left_formula_gap_detection` (S1) to extract the matching gap e_n in M.
- **Case IV** (a_n is gap not left-defined): Constructs delta involving right(B,D). Applies `right_formula_gap_detection` (S2) to extract matching gap.

Lemma 9 cannot be deferred past Cases III-IV. However, Case II does NOT use Lemma 9 (it deals with actual points, not gaps), and Case I also does not use it.

### 3.2 What does Lemma 9 require?

The proof is by structural induction on `A : StaviFormula` with 5 constructors:

| Constructor | left_formula definition | Difficulty |
|-------------|------------------------|------------|
| `.base phi` | Delegates to `left_formula_base` (5 sub-cases) | Medium |
| `.neg A` | `U'(top, D) and neg left(A, D)` | Easy (uses IH + negation) |
| `.conj A B` | `left(A, D) and left(B, D)` | Easy (uses IH + conjunction) |
| `.stavi_untl A B` | `U'(B and U'(A,B), D)` | Medium (unfold Stavi Until) |
| `.stavi_snce A B` | `U(compound, D)` via flatten_stavi | **Hard** |

The `.base phi` case further splits into:
- `atom`: trivially false on both sides
- `bot`: trivially false on both sides
- `imp phi psi`: medium (negation + conjunction encoding)
- `box`: trivially false (treated as atom at gaps)
- `untl phi psi`: medium (`U'(psi and U(phi,psi), D)`)
- `snce phi psi`: **hard** (uses flatten_stavi, compound formula)

### 3.3 The flatten_stavi complication

The `.snce` and `.stavi_snce` cases of `left_formula` use `flatten_stavi` to wrap compound Stavi-enriched formulas into standard base formulas. For example:

```lean
-- left(S(A,B), D) = U(flatten_stavi compound, flatten_stavi D)
.base (.untl (flatten_stavi compound) (flatten_stavi D))
```

This means the proof must show that evaluating `flatten_stavi(compound)` via `temporal_truth_mu` at actual points is equivalent to evaluating the compound StaviFormula via `stavi_temporal_truth_mu`. However:

- `flatten_stavi_correct` (already proved) works for **discrete orders** and uses `stavi_temporal_truth` (non-mu-relativized), not `stavi_temporal_truth_mu`.
- In general M_r (which has gaps), the order is NOT discrete. So `flatten_stavi_correct` does not directly apply.
- What is needed is a `flatten_stavi_correct_mu` variant that works for mu-relativized truth on extended carriers. This is the genuine hard part.

**Key insight**: The left_formula is evaluated at `extendPoint m` (an actual point). At actual points, `temporal_truth_mu` restricted to mu-points behaves like standard temporal truth restricted to the original structure M. This may provide a bridge, but the proof requires showing that the flatten_stavi encoding correctly commutes with mu-relativization at actual points.

**Estimated effort for Lemma 9**: 200-350 lines. The `.neg`, `.conj` cases are routine (30 lines). The `.base .atom`, `.base .bot`, `.base .box` cases are trivial (10 lines). The `.stavi_untl` case is medium (40 lines). The `.base .untl` and `.base .snce` cases plus `.stavi_snce` are the hard ones (120-250 lines), primarily due to the flatten_stavi-mu interaction.

### 3.4 Can Lemma 9 be deferred?

Only until Cases III-IV are attempted. If the implementation strategy processes cases in order (Case I -> Case II -> Case III -> Case IV), then Lemma 9 can be deferred until after Cases I-II are complete. Since Case II is a substantial proof on its own (200-300 lines), this deferral buys meaningful progress.

**Recommended order**: Case I -> Case II -> Lemma 9 -> Case III -> Case IV.

### 3.5 Is Lemma 11 used in Theorem 6 or Props 6/7?

Looking at the GHR93 paper structure:

- **Theorem 6**: Does NOT directly use Lemma 11. It uses the game definition and the four cases.
- **Proposition 7** (composition): Uses Lemma 11 explicitly. The proof says "by Lemma 11, the decomposition formulas transfer" when constructing Duplicator's strategy for sub-intervals.
- **Proposition 6** (formula agreement -> games): May use Lemma 11 implicitly via decomposition formula construction.
- **Corollary 5** (final assembly): Uses Props 5, 6, 7.

So Lemma 11 is needed for Proposition 7, which comes AFTER Theorem 6. It can be deferred until Phase 4C.8-4C.9.

### 3.6 Is Lemma 11 essentially definitional?

**No.** The definitions differ structurally:

| Aspect | `ghr93_duplicator_wins` | `decomposition_agreement` |
|--------|-------------------------|--------------------------|
| Direction | One-directional (M->N) | Symmetric (both directions) |
| Round 2 | Has point challenge (b' from N) | No point challenge |
| Agreement type | `formula_agreement` (depth-r formulas) | `rank_type` equality |
| Boundary | Implicit (in game_tuple) | Explicit boundary type agreement |

**Forward (S3, game -> decomposition)**: Must show that the game's winning condition (which includes order type + gap/point + formula agreement) implies rank_type equality. Since `rank_type` is defined as the set of depth-r formulas that hold, and `formula_agreement` asserts agreement on all depth-r formulas, rank_type equality follows from `formula_agreement` at the corresponding game_tuple indices. The point challenge must be dropped (decomposition doesn't use it). The symmetry direction must be obtained by swapping M and N in the game (this may need Theorem 6 itself or additional structure).

**Backward (S4, decomposition -> game)**: Must reconstruct the point challenge response from decomposition data. Given any actual point b' in [x',y'] from N, need to find a matching actual point b in [x,y] from M with the same rank_type. This requires showing that decomposition agreement's element-matching property, combined with rank_type equality, is enough to find the Round 2 response. This is non-trivial because decomposition agreement matches elements from the extended carrier (including gaps), but Round 2 demands an actual point.

**Estimated effort for Lemma 11**: 100-200 lines total.
- Forward (S3): ~50-80 lines. Extract from game_tuple index correspondence.
- Backward (S4): ~60-120 lines. Construct point challenge response from decomposition matching.

### 3.7 Can Lemma 11 be bypassed?

In principle, the proof could be reorganized to avoid Lemma 11 by directly working with games rather than decomposition formulas. However:

1. Proposition 7 (composition) is defined in terms of decomposition formulas in GHR93.
2. The plan (Phase 4C.9) follows GHR93 faithfully per the literature fidelity policy.
3. The user rejected all shortcuts in the strategy review (report 07).

**Conclusion**: Lemma 11 cannot be bypassed within the current plan constraints.

### 3.8 Dependency chain from stavi_expressive_completeness

```
stavi_expressive_completeness (S5)
  requires: Corollary 5 logic
    requires: Proposition 5 (standard EF -- may already exist or be easy)
    requires: Proposition 6 (4C.8) -- formula agreement -> game strategies
      requires: type formulas, decomposition formulas (done)
    requires: Proposition 7 (4C.9) -- composition lemma
      requires: ghr93_forward_to_backward (Theorem 6)
        requires: S6 (split points), S7 (Case I), S8 (Cases II-IV)
          Case III requires: S1 (left_formula_gap_detection)
          Case IV requires: S2 (right_formula_gap_detection)
      requires: ghr93_game_iff_decomposition (Lemma 11)
        requires: S3 and S4
```

### 3.9 Can stavi_expressive_completeness be closed without Props 6/7?

Not easily. The standard proof of expressive completeness via EF games goes:
1. Theorem 6 converts forward to backward games
2. Prop 6 converts formula agreement into initial game positions
3. Prop 7 composes games across intervals
4. Corollary 5 chains them together

There is no known shortcut that avoids Props 6/7 while still going through the game route. The alternative (algebraic/model-theoretic) would be a completely different proof strategy, which was explicitly rejected.

## 4. Recommended Proof Order

Based on dependency analysis and estimated difficulty:

| Order | Sorry | Task | Lines | Difficulty | Blocked by |
|-------|-------|------|-------|------------|------------|
| 1 | S6 | obtain_split_point_props | 80-120 | Medium | -- |
| 2 | S7 | Case I (split) | 150-250 | Medium-Hard | S6 |
| 3 | S8a | Case II (point) | 200-300 | Hard | S6 |
| 4 | S1 | left_formula_gap_detection | 200-350 | Hard | -- |
| 5 | S2 | right_formula_gap_detection | 200-350 | Hard | -- (dual of S1) |
| 6 | S8b | Case III (left gap) | 250-350 | Very Hard | S6, S1 |
| 7 | S8c | Case IV (right gap) | 250-350 | Very Hard | S6, S2 |
| 8 | S3 | game -> decomposition | 50-80 | Medium | -- |
| 9 | S4 | decomposition -> game | 60-120 | Medium | -- |
| 10 | S9 | rank-varying Thm 6 | 30-50 | Easy | S7, S8 |
| 11 | -- | Proposition 6 (4C.8) | 100-150 | Medium | S3, S4 |
| 12 | -- | Proposition 7 (4C.9) | 150-250 | Hard | Thm 6, S3/S4 |
| 13 | S5 | Corollary 5 assembly | 80-120 | Medium | Props 6, 7 |

**Total estimated**: 1570-2830 lines across 13 work items.

**Parallelization opportunities**:
- S1/S2 (Lemma 9 left/right) are independent of S6/S7 (split points / Case I) and can be done in parallel.
- S3/S4 (Lemma 11) are independent of S7/S8 (Theorem 6 cases) and can be done in parallel.
- S1 and S2 are duals; once S1 is done, S2 is mechanical.

## 5. Which Sorries are Blocking vs Deferrable

### Critical path (blocking stavi_expressive_completeness):
All of S1-S9 plus Props 6/7 and Corollary 5 are on the critical path. None can be permanently avoided.

### Deferrable within the phase:
- **S1, S2** (Lemma 9): Deferrable until Cases III/IV. Cases I and II can proceed without them.
- **S3, S4** (Lemma 11): Deferrable until Proposition 7. All of Theorem 6 can proceed without them.
- **S9** (rank-varying Thm 6): Deferrable until Props 6/7 need it.

### Not deferrable:
- **S6** (split point props): Needed immediately for any Theorem 6 case.
- **S7, S8** (Cases I-IV): These ARE the main proof.
- **S5** (final theorem): Terminal goal.

## 6. Key Risk: flatten_stavi in mu-relativized Setting

The single highest-risk proof obligation is the interaction between `flatten_stavi` and `stavi_temporal_truth_mu` in the S/S' cases of Lemma 9. The existing `flatten_stavi_correct` assumes a discrete order and uses non-relativized truth. The extended carrier M_r is not discrete when gaps are present.

**Mitigation**: At actual points (where left_formula is evaluated), mu-relativized truth restricted to actual points may reduce to standard truth on M. If this can be shown (a "mu-elimination at actual points" lemma), then `flatten_stavi_correct` or its proof techniques can be adapted. This helper lemma should be developed early as a prerequisite for the hard cases of Lemma 9.

## 7. Relationship to broader pipeline

The EFGames.lean sorries feed into the expressive completeness chain:

```
stavi_expressive_completeness -> Phase 5' (Theorem 5) -> Phase 6 (Gap Elimination)
  -> Phase 8 (no_gaps_discrete) -> Phase 9 (chronicle_is_good)
  -> Phase 11 (final wiring) -> countermodel_discrete sorry-free
```

The `h_truth_corr` sorry (Transfer.lean:574) is on a separate, independent path (Phase 10). Both paths must be closed for sorry-free `countermodel_discrete`.
