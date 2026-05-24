# S2 Gap Case: Elimination Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-24
**Focus**: Can S2 be eliminated or closed with the same K⁻ pattern as S1?

---

## 1. Game Responses CAN Be Gaps (Type-Level)

From `EFGames.lean:6924`:
```lean
def ghr93_duplicator_wins ... : Prop :=
  ∀ (a : Fin n → ExtendedCarrier M atomMap r), ... →
    ∃ (a' : Fin n → ExtendedCarrier N atomMap r), ...
```

Round 1 responses `a'` are `ExtendedCarrier` (Sum of carrier points + gaps). Gaps ARE allowed as Round 1 responses. Round 2 `b'` is `N.carrier` (carrier points only). **Approach 1 fails — gap responses cannot be eliminated by type.**

GHR93's paper doesn't explicitly address this because in the paper's metalogic, all elements participate uniformly. The Lean formalization's `ExtendedCarrier` adds gaps as formal elements between carrier points; the game definition quantifies over all of them.

---

## 2. `h_cofinal_failure_below_c_inf` Works for Generic c_inf

The lemma (line 3080) gives: for any `s < c_inf`, ∃ mu u with `s < u ≤ c_inf`, `u < y`, `mu_holds u`, and `¬cont_holds_cross u`. The bound is `u ≤ c_inf` (non-strict).

In Case A (`cont_holds_cross` HOLDS at c_inf), the code (line 3656) case-splits:
- `u < c_inf`: strict, done
- `u = c_inf`: contradicts `h_cont_c` (Case A hypothesis)

In Case B (`¬cont_holds_cross` at c_inf), `u = c_inf` is CONSISTENT (not contradictory). So direct strict failure is not guaranteed.

---

## 3. HOWEVER: Strict Failures Below c_inf ALWAYS Exist in Case B

**Key argument** (by contradiction):

Suppose NO strict failures exist below c_inf. Then for all mu u with `x < u < c_inf`, `cont_holds_cross u` holds. This means every such u is in S_C_M. But c_inf = inf(S_C_M) is the greatest lower bound, so c_inf ≤ u for all u ∈ S_C_M. Combined with u < c_inf, we get c_inf ≤ u < c_inf — **contradiction**.

Therefore: strict failures below c_inf always exist (at least one carrier point q with `extendPoint q < c_inf` and `¬cont_holds_cross q`). Once we have ONE strict failure point, we can bootstrap the pigeonhole argument identically to Case A.

**Formalization**: This argument uses the density of carrier points in the interval (there exist mu-points between x and c_inf) and the infimum property. Both are available in the current code.

---

## 4. S1's Proof Pattern Applies to S2 Identically

The S1 proof (commit d20541402, lines ~4094-4241) uses:
1. Derive `h_strict_failure` (strict cofinal failures below c_inf)
2. Apply `pigeonhole_definable_formula_cross_strict` to extract D_M
3. Form K_minus = ¬Since(⊤, D_M) of depth r+2
4. Prove K_minus holds at c_inf via `h_since_false_c`
5. Transfer K_minus to r2_resp via formula agreement at rank r+2
6. Show Since(⊤, D_M) holds at r2_resp using rank_embed(d) as witness
7. Contradiction

**None of these steps depend on r2_resp being a carrier point.** Steps 5-6 work for gaps because:
- K_minus is a temporal formula — its truth at a gap is well-defined
- Formula agreement at rank r+2 applies to ALL elements (points and gaps)
- The Since witness uses rank_embed(d) which is below r2_resp; the ∀-quantifier in Since ranges over mu-points between rank_embed(d) and r2_resp

The S1 proof works because `c_inf = y` gives `u < y = c_inf` (automatic strict). For S2 (generic c_inf), we need the argument from Section 3 above to establish strict failures.

---

## 5. Verdict: S2 is SAME AS S1

**S2 closes with the same K⁻(¬D) pigeonhole argument as S1.** The steps:

1. **Establish strict failures** (new, ~30 lines): Prove by contradiction that strict failures below c_inf exist in Case B. Use density of carrier points + infimum property.
2. **Apply pigeonhole** (existing infrastructure): `pigeonhole_definable_formula_cross_strict` gives D_M
3. **K⁻ argument** (same as S1): K_minus at c_inf → transfer → Since contradiction at r2_resp

The only addition beyond S1's proof is the ~30-line strict-failure derivation for Case B. After that, the K⁻ argument is IDENTICAL (copy-paste from S1).

**Both share the same sub-sorry**: The "d is a gap" Since witness issue (line 4241) applies to both S1 and S2. Once that 30-line sub-sorry is resolved (using complement_no_min to find a carrier point between rank_embed(d) and r2_resp), BOTH S1 and S2 are fully closed.

---

## 6. Implementation Path

1. Factor the K⁻ argument from S1 into a shared lemma (~5 lines of refactoring)
2. Add the Case B strict-failure proof (~30 lines, using contradiction + density + infimum)
3. Call the shared K⁻ lemma from S2 (~10 lines)
4. Close the "d is a gap" sub-sorry in the shared lemma (~30 lines, using complement_no_min pattern already proved at lines 3858-3932)

**Total new code**: ~70 lines. **Net effect**: Closes S1 sub-sorry + S2 entirely.

**Confidence**: HIGH — all building blocks exist sorry-free in the codebase. The strict-failure-in-Case-B argument is a standard density/infimum argument. The gap Since witness uses complement_no_min (already proved at line 3873).
