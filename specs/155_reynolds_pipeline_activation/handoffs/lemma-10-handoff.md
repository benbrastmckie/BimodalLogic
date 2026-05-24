# Handoff: GHR93 Lemma 10 Gap Transfer Infrastructure

**Task**: 155 (reynolds_pipeline_activation)
**Session**: sess_1779565373_9bf0c5
**Date**: 2026-05-23
**Status**: Partial -- gap characterization infrastructure built, Lemma 10 theorem not yet stated

---

## 1. What Was Built

### 1.1 Sorry-Free Infrastructure (EFGames.lean, +446 lines)

All additions are in `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean`.
Build passes, zero new sorries, zero new axioms.

**K+/K- Operators** (lines ~7304-7407):
- `sf_verum`: Top (verum) as StaviFormula (.neg (.base .bot))
- `sf_K_plus(A)`: K+(A) = neg(std_untl(verum, neg A)) -- "A cofinal above"
- `sf_K_minus(A)`: K-(A) = neg(std_snce(verum, neg A)) -- "A cofinal below"
- `stavi_depth_sf_verum`: depth 0
- `stavi_depth_sf_K_plus/minus`: depth A + 2
- `sf_K_plus_iff/sf_K_minus_iff`: semantic characterization as "no interval where negA is universal"

**Gap Characterization Formula** (lines ~7408-7450):
- `gap_char_formula D = (S(T,D) AND NOT U(T,D)) OR (U(T,D) AND NOT S(T,D))`
  - Left disjunct: D holds in final cut segment AND D NOT in initial complement segment
  - Right disjunct: D holds in initial complement segment AND D NOT in final cut segment
- `stavi_depth_gap_char_formula`: depth D + 2
- `stavi_depth_gap_char_formula_le`: if depth D <= r then depth D' <= r+2

**Key Discovery**: The GHR93 OCR'd formula `D' = (K+D AND NOT K-D) OR (NOT D AND NOT K+D)` does NOT work because K+D and K-D (cofinality operators) do not correspond exactly to gap_definable_on_left/right conditions (which are about UNIFORM truth on intervals, not cofinality). The correct formula uses S(T,D) (Since with Top) and U(T,D) (Until with Top) which directly encode the gap definability conditions.

**Gap/Point Ordering Helpers** (lines ~7444-7475):
- `extendPoint_lt_gap`: x in cut implies extendPoint x < Sum.inr g
- `lt_gap_mem_cut`: extendPoint x < Sum.inr g implies x in cut
- `gap_lt_not_cut`: Sum.inr g < extendPoint x implies x not in cut
- `gap_lt_extendPoint`: x not in cut implies Sum.inr g < extendPoint x
- `gap_cut_no_max`: cut has no maximum element
- `gap_complement_no_min`: complement has no minimum (via Gap.complement_no_min)

**Forward Direction** (lines ~7507-7639):
- `gap_char_formula_left`: gap defined by D on LEFT implies gap_char_formula D holds
- `gap_char_formula_right`: gap defined by D on RIGHT implies gap_char_formula D holds
- `gap_char_formula_holds`: combined -- r_definable_gap implies gap_char_formula holds

**Reverse Direction** (lines ~7644-7727):
- `gap_char_formula_implies_definable`: gap_char_formula D at gap g implies g is definable by D (left or right)

**Range Membership** (lines ~7730-7760):
- `in_rank_embed_range`: predicate for elements in range of rank_embed
- `in_rank_embed_range_point`: carrier points always in range
- `in_rank_embed_range_embed`: rank-embedded elements always in range

### 1.2 Technical Note: LT Instance on ExtendedCarrier

`ExtendedCarrier M atomMap r` is a `def` (type alias for `M.carrier + RDefinableGap M atomMap r`). When `Sum.inr g` appears as the LEFT operand of `<`, Lean's elaborator unfolds `ExtendedCarrier` and fails to find the `LT` instance from `extendedLinearOrder`. 

**Workaround**: When `Sum.inr g` is on the LEFT of `<`, either:
1. Use `> (Sum.inr g : ExtendedCarrier M atomMap r)` with the gap on the RIGHT
2. Use helper theorems (`gap_lt_extendPoint`, `gap_lt_not_cut`) that return `@LT.lt (ExtendedCarrier ...) _` 
3. Use `lt_of_not_le` with `extendPoint_le_gap_iff`

When `Sum.inr g` is on the RIGHT of `<` (as in `extendPoint x < Sum.inr g`), Lean resolves the instance from the LEFT operand's type. No workaround needed.

---

## 2. What Was NOT Built

### 2.1 GHR93 Lemma 10 Theorem Statement

The full Lemma 10 theorem was NOT stated or proved. The infrastructure (gap_char_formula and its semantic properties) is the prerequisite.

The theorem statement would be:

```
theorem ghr93_duplicator_wins_rank_down {sig : MonadicSignature}
    {M N : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    {m r r' : Nat} (hle : r' ≤ r) (hr2 : r' + 2 ≤ r)
    {x y : ExtendedCarrier M atomMap r'}
    {x' y' : ExtendedCarrier N atomMap r'}
    (h : ghr93_duplicator_wins M N atomMap m r
           (rank_embed (le_of_lt (lt_of_le_of_lt hle (Nat.lt_succ_of_lt (Nat.lt_succ_of_le hr2)))) x)
           (rank_embed ... y)
           (rank_embed ... x')
           (rank_embed ... y')) :
    ghr93_duplicator_wins M N atomMap m r' x y x' y'
```

### 2.2 The Existing Sorry in ExpressivenessGeneral.lean

The `ghr93_duplicator_wins_rank_down` at line 6999 of ExpressivenessGeneral.lean is sorry'd and can now be filled using this infrastructure. The proof outline:
1. Embed Spoiler's rank-r' selections to rank r via rank_embed
2. Apply the rank-r strategy
3. For each response: if carrier point, stays carrier point (gap_point_agreement). If gap, use gap_char_formula to transfer definability (formula agreement at depth <= r covers D' of depth <= r'+2 <= r)
4. Project responses back to rank r' via rank_embed injectivity

### 2.3 d_consistency Restructure

Not started. Depends on completing Lemma 10.

---

## 3. Immediate Next Steps

1. **State and prove ghr93_duplicator_wins_rank_down** using:
   - gap_char_formula_holds (forward: gap defined by D implies D' holds at gap)
   - gap_char_formula_implies_definable (reverse: D' at gap implies definable by D)
   - formula_agreement (transfers D' between M and N sides)
   - rank_embed_stavi_truth_mu (relates truth at rank-embedded positions)

2. **Close the sorry at ExpressivenessGeneral.lean:6999** with the proved theorem

3. **Restructure d_consistency_left/right** to use h_fwd_r1 + Lemma 10

---

## 4. Files Modified

- `Theories/Bimodal/Metalogic/WeakCanonical/EFGames.lean` (+446 lines, 0 new sorries)

## 5. Current State

- **Build**: Passes (lake build succeeds)
- **Sorry count in EFGames.lean**: 1 (unchanged, at nf_characterizable_by_stavi)
- **New theorems**: 20+ (all sorry-free)
- **Key achievement**: Gap characterization formula infrastructure complete with full forward and reverse semantic proofs
