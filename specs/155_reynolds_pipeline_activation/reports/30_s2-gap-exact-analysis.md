# S2 Gap Sorry: Exact Analysis

**Task**: 155
**Date**: 2026-05-24
**Focus**: Whether the S2 gap case is vacuous or genuine, and how GHR93 handles it

---

## 1. GHR93's M_r Includes Gaps — Gap Responses Are GENUINE

**ExtendedCarrier** (EFGames.lean) = `M.carrier ⊕ {gaps}`. The game `ghr93_duplicator_wins` plays on `ExtendedCarrier M atomMap r` — both carrier points and gaps.

Round 1 selections (lines 6928-6931): `a : Fin n → ExtendedCarrier M atomMap r` — can include gaps.
Duplicator responses: `a' : Fin n → ExtendedCarrier N atomMap r` — can include gaps.

GHR93 Definition 8.5: M_r includes all rank-r Dedekind gaps. The game plays on M_r. **Gap responses are genuine, not vacuous.**

## 2. Formula Agreement Holds at ALL Positions (Including Gaps)

`formula_agreement` (line 6883): quantifies over `∀ (i : Fin (n + 3))` unconditionally. No filter for carrier-points-only. Formula truth at gaps is well-defined via temporal connective semantics (atoms are False at gaps, temporal connectives quantify over other elements).

## 3. The Gap Case IS Provable — Sorry-Free Proof Exists in Same File

Lines 3933-4038 contain a **sorry-free proof** of the gap-r2_resp sub-case using the K⁻ argument. The proof:
1. Finds carrier point q_w between rank_embed(d) and gap r2_resp via `complement_no_min` on the gap's cut
2. Transfers K⁻(¬D_M) to r2_resp via formula_agreement (works for gaps)
3. Shows Since(⊤, D_M) would be true at r2_resp (the carrier point q_w serves as Since witness)
4. Derives contradiction

This proof exists in the d-is-gap + c_inf = y sub-case (where strict failures are available).

## 4. S2 Sorry (line 4293) Is in a DIFFERENT Context

S2 is in **Case B** (cont_holds_cross FAILS at c_inf), NOT in the c_inf = y sub-case. The structure:

```
obtain_split_point_props
  → by_cases h_cont : cont_holds_cross ... c_inf
    → Case A (holds): K⁻/pigeonhole argument → sorry-free for both carrier+gap r2_resp
    → Case B (fails): direct A_fail argument
      → carrier-point r2_resp: A_fail holds (from hd_in_SC.2) → contradicts hA_fail_r2 ✓
      → gap r2_resp: Can't derive "A_fail holds at gap" → SORRY (S2)
```

## 5. Why Case B Fails for Gaps (A_fail Cannot Hold at Gaps)

In Case B: we have `hA_fail_r2 : ¬A_fail at r2_resp` (transferred via formula_agreement). For carrier-point r2_resp, we derive A_fail HOLDS (from hd_in_SC.2 + projection). Contradiction.

For gap r2_resp: A_fail's truth at a gap depends on its temporal structure. If A_fail involves positive atoms, it's automatically FALSE at gaps. We can't derive "A_fail holds at gap r2_resp" because we only know A_fail holds at carrier points in (d, y').

## 6. The Fix: Apply K⁻ Argument in Case B's Gap Sub-Case

**The K⁻ argument does NOT depend on A_fail holding at r2_resp.** It uses a DIFFERENT formula (D_M from pigeonhole) and K⁻ semantics. The K⁻ argument needs:
1. D_M fails cofinally below c_inf (from pigeonhole)
2. K⁻(¬D_M) transfers via formula_agreement to r2_resp (works for gaps)
3. Since(⊤, D_M) is true at r2_resp (carrier witness below gap, D_M holds on interval above d)

All three work regardless of whether r2_resp is a gap or carrier point.

**The prerequisite**: Cofinal strict failures below c_inf for the pigeonhole. In Case B, `h_cofinal_failure_below_c_inf` gives v ≤ c_inf (non-strict). Since cont_holds_cross fails AT c_inf (Case B hypothesis), c_inf itself is always a valid failure witness. But the pigeonhole needs failures in `inf_carrier_cut` (carrier points BELOW c_inf).

**Resolution**: In Case B, cont_holds_cross fails at c_inf. Combined with the infimum properties, this should yield strict failures below c_inf (points approaching c_inf from below that also fail). The existing `h_strict_failure_s1` pattern (used in the c_inf = y sub-case) can be adapted.

## 7. Concrete Implementation Path

At line 4293 (Case B, gap r2_resp), instead of trying to show A_fail holds at the gap:
1. Apply the pigeonhole to get D_M with cofinal failures below c_inf
2. Construct K_minus = ¬Since(⊤, D_M) of depth r+2
3. Show Since(⊤, D_M) false at c_inf (from D_M cofinal failure)
4. Transfer K_minus to r2_resp via hform_w (formula_agreement works for gaps)
5. Show Since(⊤, D_M) true at r2_resp using carrier point witness from complement_no_min on the gap (same as lines 3933-4038)
6. Contradiction

This is exactly the sorry-free proof at lines 3933-4038, duplicated into Case B.

## 8. Remaining Question

Can the pigeonhole be applied in Case B? It needs:
- `h_cut_start`: carrier point in inf_carrier_cut — derivable from x < c_inf + existence of mu-points
- `h_cofinal_failure`: for each p in cut, ∃ u ≥ p in cut with some formula failing — derivable from h_cofinal_failure_below_c_inf

The only subtlety: h_cofinal_failure_below_c_inf gives v ≤ c_inf (could be = c_inf). If c_inf is a carrier point in inf_carrier_cut, this works. If c_inf is a gap, carrier points approach it from below, and the cofinal failure gives v < c_inf (since v is mu_holds, hence a carrier point, and can't equal a gap).

**If c_inf is a gap**: v ≤ c_inf with mu_holds(v) forces v < c_inf (gaps aren't mu-points). STRICT below c_inf. Pigeonhole applies directly.

**If c_inf is a carrier point**: v ≤ c_inf could mean v = c_inf. But then c_inf ∈ inf_carrier_cut (it's a carrier point below or at the infimum boundary). And ¬cont_holds_cross at c_inf gives the formula failure. The pigeonhole might need the BRIDGE version (h_strict_bridge) that guarantees further failures above each p.

## Verdict

**S2 IS closable.** The K⁻ argument from Case A (lines 3933-4038) can be applied in Case B's gap sub-case. The key insight: the K⁻ approach is INDEPENDENT of which case (A or B) we're in — it only needs cofinal failures below c_inf, which are available from h_cofinal_failure_below_c_inf.

The fix is ~150-200 lines duplicating the K⁻ argument into Case B's gap sub-case, with the strict-failure derivation adapted for the general case (not just c_inf = y).

**Confidence**: HIGH that the K⁻ argument works for gaps (sorry-free proof exists at lines 3933-4038). MEDIUM on whether the strict-failure prerequisite needs a new lemma in the general Case B.
