# Research Report: Direct Approach Feasibility (Post-Phase-2 Refactoring)

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-24
**Focus**: Can the K⁻(¬D) bridge be eliminated via a more direct approach?

---

## Verdict: Bridge-then-refactor (optional cleanup after S13)

The K⁻(¬D) bridge is **necessary now** and **cannot be avoided** before S13 (nf_characterizable_by_stavi) is proved. After S13, a cleanup refactoring to the direct GHR93 approach becomes available but is optional.

---

## 1. Why No Direct Approach Avoids the Bridge (Before S13)

### The Game Gives Formula Agreement, Not NormalForm Agreement

The winning condition (`ghr93_winning_condition`, EFGames.lean:6901) provides:
```
formula_agreement n tM tN :=
  ∀ (i : Fin (n + 3)) (A : StaviFormula), stavi_depth A ≤ r →
    (stavi_temporal_truth_mu M atomMap r (tM i) A ↔
     stavi_temporal_truth_mu N atomMap r (tN i) A)
```

At rank r+2 (h_fwd_r1), this gives: all StaviFormulas of depth ≤ r+2 agree between corresponding tuple positions.

### The Direct NF Approach Is Circular

To avoid naming a specific formula (like the bridge's D), you'd want:
1. Formula agreement at depth r+2 → same NormalForm at depth 2(r+2)
2. Same NF → same position relative to d-bar

But **Step 1 is the converse of `nf_determines_stavi_truth_depth`**:
- `nf_determines_stavi_truth_depth`: same NF at depth 2r → same formula truth at depth r ✓ (proved)
- Converse: same formula truth at depth r → same NF at depth 2r ← THIS IS EXPRESSIVE COMPLETENESS

Going from formula agreement to NF agreement requires showing every NF class is distinguished by some formula — which IS `nf_characterizable_by_stavi` (sorry S13). Circular.

### The Bridge Is the Minimal Non-Circular Path

The K⁻(¬D) bridge works because:
1. It doesn't require NF agreement (avoids circularity)
2. It uses formula agreement on ONE SPECIFIC formula (K⁻(¬D), depth r+2)
3. The pigeonhole provides D non-circularly (from NF Fintype + nf_determines_stavi_truth)
4. K⁻(¬D) discriminates the infimum without needing the full interval-type formula

There is no simpler non-circular path. The bridge is the minimum machinery needed.

---

## 2. After S13: The Direct GHR93 Approach Becomes Available

Once `nf_characterizable_by_stavi` (S13) is proved:
- `nf_characterizable_by_stavi` gives: for every NF class at depth k, a StaviFormula characterizing it
- This allows constructing `continuation_formula : StaviFormula` (the full C from GHR93)
- C' = ¬C ∨ K⁻(¬C) becomes a concrete StaviFormula
- The 5-line GHR93 proof works directly

### Post-S13 Refactoring Would Look Like:

```lean
-- After S13 is proved:
noncomputable def continuation_formula (a_n y' : ExtendedCarrier N atomMap r) : StaviFormula :=
  -- Use nf_characterizable_by_stavi to get a formula for each NF class
  -- Take conjunction over those holding at all mu-points in (a_n, y')
  sf_conjList (... nf_characterizable_by_stavi ...)

-- Then Claim 1 becomes:
theorem claim_1_direct : response = d_bar := by
  let C := continuation_formula a_n y'
  let C' := sf_disj (sf_neg C) (sf_K_minus (sf_neg C))
  have hC'_c : stavi_truth M (r+2) c_inf C' := ...  -- by infimum property
  have hC'_r : stavi_truth N (r+2) response C' :=    -- by formula_agreement
    (hform_w _ C' (by linarith)).mp hC'_c
  have h_le := K_minus_implies_le C' hC'_r ...       -- by K⁻ semantics
  exact le_antisymm h_le h_ge
```

This eliminates: pigeonhole, h_cofinal_failure_below_c_inf, the bridge lemmas, and ~400 lines of machinery. But it REQUIRES S13, which requires the bridge to prove.

---

## 3. Can the Induction Be Restructured to Avoid the Bridge?

**No.** The circularity is structural:
- C at rank r needs a StaviFormula for each NF class at depth 2r
- Getting StaviFormulas from NF classes IS `nf_characterizable_by_stavi` (the theorem being proved)
- The induction is on n (game rounds), not on r (formula depth)
- C depends on r (formula depth), not on n
- No restructuring of the n-induction helps with the r-dependency

GHR93 avoids this because in the paper's metalogic, "there are finitely many rank-r formulas" is a background fact (finite atoms). In Lean with infinite atoms, this finiteness fails, forcing the bridge.

---

## 4. Summary

| Approach | Feasible? | When? | Lines |
|----------|-----------|-------|-------|
| K⁻(¬D) bridge (pigeonhole + 3 lemmas) | YES | Now | ~120 new |
| Direct NF argument | NO | Requires S13 (circular) | — |
| Full GHR93 direct (cont_formula) | YES | After S13 | ~200 (replaces ~600) |
| Restructure induction | NO | Structural impossibility | — |

### Recommended Strategy

1. **Now**: Build the K⁻(¬D) bridge (~120 lines). Close S1/S2/S4/S7-right.
2. **Phases 3-6**: Close remaining sorries using the bridge as foundation.
3. **After S13**: OPTIONAL cleanup — replace cont_holds + pigeonhole + bridge with `continuation_formula` + 5-line proof. Net ~-400 lines, much cleaner.
4. **The cleanup is low-priority** — the bridge is mathematically correct and the code compiles. Do it only if the task continues beyond sorry-free completeness.

---

## 5. Confidence

- **HIGH**: Bridge is necessary before S13 (proven circular otherwise)
- **HIGH**: Direct approach works after S13 (all ingredients available)
- **MEDIUM**: Post-S13 cleanup effort estimate (~200 lines replacing ~600)
- **HIGH**: No alternative avoids the bridge without circularity
