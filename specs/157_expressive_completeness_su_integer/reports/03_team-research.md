# Research Report: Task #157 -- Overcoming Phase 6 and Phase 7 Blockers

**Task**: 157 - Formalize expressive completeness of {S,U} over integer time
**Date**: 2026-05-17
**Mode**: Team Research (4 teammates)
**Session**: sess_1779038455_213d4f

## Summary

Team research identified a **critical error in prior approaches** and a **breakthrough strategy** for Phase 6. The key insight: GHR94's junction-depth induction assumes G/H are DERIVED operators (G = neg U(neg,top), H = neg S(neg,top)), but our formalization has them as PRIMITIVE constructors. This causes `junction_depth = 0` to NOT imply syntactically separated, invalidating all previous proof attempts.

The fix: preprocess with `expand_temporal` to eliminate `all_past`/`all_future` before induction, reducing to the pure `{atom, bot, imp, snce, untl}` fragment where GHR94's proof applies directly.

## Key Findings

### 1. The JD=0 Base Case Bug (Critical -- from Teammate C)

**Machine-verified**: `junction_depth (.all_past (.untl a b))` = 0, but `is_syntactically_separated (.all_past (.untl a b))` = false.

All prior Phase 6 attempts assumed "JD ≤ 1 implies easily separable." This is FALSE because `all_past`/`all_future` are transparent to `junction_depth` but NOT transparent to `is_syntactically_separated`. Reports 09 and 10 both inherited this error from the assumption that GHR94's framework applies directly.

### 2. The expand_temporal Preprocessing Fix (from Teammates A + C)

**Strategy**: Before applying junction-depth induction, rewrite:
- `all_past phi` → `neg (snce (neg phi) top)` (H(phi) ↔ neg S(neg phi, top) on Z)
- `all_future phi` → `neg (untl (neg phi) top)` (G(phi) ↔ neg U(neg phi, top) on Z)

After expansion, the formula contains only `{atom, bot, imp, snce, untl, box}`. In this fragment:
- `junction_depth = 0` genuinely implies `is_syntactically_separated = true`
- The junction-depth induction proceeds exactly as in GHR94
- No circularity: `snce` cases use U-elimination (Cases 1-8), `untl` cases use duality

**Prerequisite**: Prove the two semantic equivalences on integer time (~50-80 LOC each):
```lean
theorem all_past_equiv_neg_snce (phi : Formula) :
    int_equiv (.all_past phi) (.neg (.snce (.neg phi) (.neg .bot)))

theorem all_future_equiv_neg_untl (phi : Formula) :
    int_equiv (.all_future phi) (.neg (.untl (.neg phi) (.neg .bot)))
```

(Note: `neg .bot` = `top` in our encoding where `neg phi = imp phi bot`)

### 3. Duality Halves Phase 6 Work (from Teammate B)

`swap_temporal` preserves `junction_depth` and `is_separable`. The full chain:
1. Prove `snce_separable` (U-out-of-S direction) using expand_temporal + JD induction
2. Derive `untl_separable` via: `is_separable (.untl phi psi)` ← `is_separable (swap (.untl phi psi))` = `is_separable (.snce (swap phi) (swap psi))` ← `snce_separable`
3. Similarly derive `all_future_separable` from `all_past_separable`

This means we only need ~250 LOC for the primary direction (snce + all_past) and ~100 LOC for duality derivation.

### 4. Phase 7 is Independent and Well-Scoped (from Teammates C + D)

Phase 7's blocker is:
- The quantifier cases need **well-founded induction on qdepth** (not structural recursion, which can't handle the type-changing recursive call to `extSignature`)
- The atom-elimination pipeline is mechanical given existing infrastructure
- `.all` derives from `.ex` via negation (halving work)
- All prerequisite theorems (`past_only_subst_correct`, `future_only_subst_correct`, `reduceElimLast_correct`) are proved

### 5. Strategic Assessment (from Teammate D)

- Task 155 (Reynolds pipeline) is **unblocked NOW** -- it needs `all_separable` as a callable function, not zero-axiom purity
- The 8 axioms are Lean `axiom` (trusted assertions), NOT `sorry` (gaps)
- Recommended: complete Phase 6 + 7, or declare substantially done and spawn sub-tasks

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|------------|
| Report 09 said "JD=0 implies separated" | FALSE per machine check (Teammate C). Fixed by expand_temporal |
| Report 10 said "no special handling for base case" | WRONG for our formalization (primitive G/H). Correct after expansion |
| Prior estimate "800-1200 LOC" for Phase 6 | Revised to **400-500 LOC** with expand_temporal + duality |

### Recommended Implementation Order

**Phase 6** (400-500 LOC, with expand_temporal):
1. Prove `all_past_equiv_neg_snce` and `all_future_equiv_neg_untl` on Z (~100 LOC)
2. Define `expand_temporal : Formula → Formula` that recursively replaces all_past/all_future (~30 LOC)
3. Prove `expand_temporal_equiv : int_equiv phi (expand_temporal phi)` (~50 LOC)
4. Prove `expand_jd_zero_separated : junction_depth (expand_temporal phi) = 0 → is_syntactically_separated (expand_temporal phi) = true` (~80 LOC)
5. Prove `snce_separable` by: get separated subresults, expand them, form snce, apply JD induction on expanded formula using Cases 1-8 (~150 LOC)
6. Derive `untl_separable`, `all_past_separable`, `all_future_separable` via duality + expand (~100 LOC)
7. Remove axioms, reprove all_separable (~20 LOC)

**Phase 7** (500 LOC, independent):
1. Restructure `expressiveness_fixed_atomMap` to use WF induction on qdepth (~80 LOC)
2. Implement case-split over `sig.preds → Bool` for const_at_ref elimination (~150 LOC)
3. Implement level-aware lt_ref/gt_ref substitution using purity lemmas (~150 LOC)
4. Assembly: connect reduce + IH + case-split + purity substitution (~120 LOC)

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | GHR94 junction-depth proof architecture | completed | high |
| B | Duality and encoding alternatives | completed | high |
| C | Critic: gaps and false assumptions | completed | high |
| D | Strategic direction | completed | high |

## References

- GHR94 Chapter 10, Lemma 10.2.8 (junction-depth induction)
- `literature/ghr94_ch10_separation.md` (project-local)
- Reports 08, 09, 10 (prior research, partially corrected by this report)
- Lean source: Defs.lean (junction_depth definition), TemporalClosure.lean (existing JD infrastructure)
