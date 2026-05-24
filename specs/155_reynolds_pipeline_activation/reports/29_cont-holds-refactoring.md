# Research Report: cont_holds → Formula C Refactoring

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-24
**Focus**: Feasibility and plan for replacing cont_holds predicate with GHR93's formula C

---

## 1. Current Architecture

### cont_holds Definition (line 112)

```lean
private def cont_holds (a_n y' t : ExtendedCarrier N atomMap r) : Prop :=
  ∀ A : StaviFormula, stavi_depth A ≤ r →
    (∀ v, a_n < v → v < y' → mu_holds v → stavi_temporal_truth_mu N atomMap r v A) →
    stavi_temporal_truth_mu N atomMap r t A
```

Semantics: "every depth-≤-r formula that holds at all mu-points in (a_n, y') also holds at t."

### cont_holds_cross Definition (line 127)

Same but evaluates truth in M while checking the interval in N (cross-structure).

### Usage Scale

- **112 references** to `cont_holds` / `cont_holds_cross` in ExpressivenessGeneral.lean
- Key dependents: `continuation_set`, `continuation_set_cross`, `pigeonhole_definable_formula`, `pigeonhole_definable_formula_cross`, `pigeonhole_definable_formula_cross_strict`, `h_cofinal_failure_below_c_inf`, `cont_holds_above_gap`, `cont_fails_below_gap`
- All sorry sites S1, S2, S4, S7-right trace back to the inability to form C' = ¬C ∨ K⁻(¬C)

### The Core Problem

`cont_holds` quantifies over ALL StaviFormulas of depth ≤ r — an INFINITE set (because Formula atoms are infinite). It cannot be materialized as a single StaviFormula. Therefore:
- C' = ¬C ∨ K⁻(¬C) cannot be formed as a StaviFormula
- The K⁻ argument requires a SINGLE formula that fails cofinally — but ¬cont_holds yields different formulas at each failure point
- The pigeonhole machinery (lines 663-850, ~190 lines) exists solely to work around this limitation

---

## 2. Target Architecture (Following GHR93)

### GHR93's Construction

C = X_{(a_n, y')} = "the interval-type formula" = conjunction of all rank-r formulas true at every mu-point in (a_n, y').

Since there are finitely many NormalForm equivalence classes, and each class determines truth of all depth-r formulas, C is effectively:
- For each NF class realized in (a_n, y'): take any representative point v, get its "type formula" (conjunction of depth-r formulas true at v)
- C = disjunction over these type formulas

### The Desired Lean Structure

```lean
-- continuation_formula : single StaviFormula capturing the interval type
noncomputable def continuation_formula (a_n y' : ExtendedCarrier N atomMap r) : StaviFormula := ...

-- Equivalence with cont_holds
theorem continuation_formula_iff :
  cont_holds a_n y' t ↔ stavi_temporal_truth_mu N atomMap r t (continuation_formula a_n y')

-- C' as a concrete formula
def C_prime (a_n y') := sf_disj (sf_neg (continuation_formula a_n y'))
                                (sf_K_minus (sf_neg (continuation_formula a_n y')))

-- Claim 1 in 5 lines
theorem claim_1 (h_fwd : ...) : response = d_bar := by
  have hC'_c := C_prime_holds_at_infimum c ...   -- by K⁻ semantics
  have hC'_d := formula_agreement_transfer hC'_c -- by game at rank r+2
  have hd_le := C_prime_implies_le hC'_d         -- by K⁻ semantics
  have hd_ge := direction_2 ...                  -- by contradiction
  linarith
```

---

## 3. The Circularity Question (KEY)

### The Chain of Dependencies

To construct `continuation_formula a_n y' : StaviFormula`, we need:
1. A StaviFormula for each NF class realized in (a_n, y')
2. This requires `nf_characterizable_by_stavi` — "for each NF at depth k, there exists a StaviFormula characterizing it"
3. `nf_characterizable_by_stavi` at depth k+1 requires the GHR93 game argument (line 10086 — sorry S13)
4. The GHR93 game argument (specifically Claim 1 in `obtain_split_point_props`) is WHERE we need the formula
5. **CIRCULAR**: We need the formula to prove the theorem, but constructing the formula requires the theorem

### Is There a Non-Circular Path?

**At depth 0**: `nf_base_sf` constructs StaviFormulas for depth-0 NFs directly from atom literals. This is non-circular and sorry-free. But Claim 1 operates at arbitrary depth r, not just 0.

**At arbitrary depth r**: `nf_characterizable_by_stavi` at depth r requires the full inductive step (sorry S13). There is NO non-circular path from NormalForm → StaviFormula at arbitrary depth.

**The GHR93 paper's implicit assumption**: GHR93 asserts "there are finitely many rank-r formulas up to equivalence" as a BACKGROUND FACT. In GHR93's metalogic, this is trivially true because the language is finite at each rank (finite atoms, finite connectives, bounded depth → finitely many formulas). In Lean, this fails because `Atom` is infinite — there are infinitely many StaviFormulas at each depth.

### Verdict on Full Refactoring

**The full refactoring (replacing cont_holds with a StaviFormula) is CIRCULAR for r > 0.** You cannot construct `continuation_formula` without `nf_characterizable_by_stavi`, which requires the theorem being proved.

---

## 4. Alternative: The Pigeonhole Bridge (Non-Circular)

The existing `pigeonhole_definable_formula` extracts a SINGLE formula D that:
- Has depth ≤ r
- Holds at all mu-points in (a_n, y')
- Fails COFINALLY below the infimum (at infinitely many points approaching the infimum)

This D is NOT the full C (which would be the conjunction characterizing ALL types in the interval). It is a SINGLE separating formula — the one that pigeonhole selects from the chain of NF-type failures.

**Key insight**: For the K⁻ argument, we don't need the FULL formula C. We need ANY single formula D with depth ≤ r that:
1. Holds on the interval (a_n, y')
2. Fails cofinally below the infimum

If such D exists, then K⁻(¬D) holds at the infimum, K⁻(¬D) can be transferred through the game (depth ≤ r+2), and the GHR93 argument proceeds.

**The pigeonhole ALREADY provides this D** — it proves exactly the cofinal failure property. The issue is that the CURRENT code doesn't USE the pigeonhole output in the K⁻ argument. Instead, it tries to use `cont_holds` directly and fails at the gap/boundary cases.

---

## 5. Refactoring Plan: Pigeonhole + K⁻ Integration

### The Non-Circular Resolution

Instead of materializing C as a formula (circular), USE THE PIGEONHOLE OUTPUT D in the K⁻ argument:

1. `pigeonhole_definable_formula` gives D with depth ≤ r, D holds on interval, D fails cofinally below infimum
2. Form K⁻(¬D) — a single StaviFormula of depth r+2
3. K⁻(¬D)(c_inf) holds in M (from the cofinal failure of D below c_inf)
4. Transfer K⁻(¬D) through game agreement at rank r+2 (available from h_fwd_r1)
5. K⁻(¬D)(response) holds in N → derive response ≤ d (by K⁻ semantics + D holds above d in N)

### What Changes

| Component | Action | Lines |
|-----------|--------|-------|
| **Keep** cont_holds, continuation_set | No change — still used to define S_C and infimum | 0 |
| **Keep** pigeonhole_definable_formula_cross | It provides the crucial D | 0 |
| **Keep** h_cofinal_failure_below_c_inf | It proves D fails cofinally (premise of pigeonhole) | 0 |
| **ADD** `K_minus_from_cofinal_D` lemma | "If D fails cofinally below t, then K⁻(¬D)(t)" | ~40 lines |
| **ADD** `K_minus_transfer` lemma | "If K⁻(¬D)(t) in M and formula agreement at r+2, then K⁻(¬D)(response) in N" | ~30 lines |
| **ADD** `K_minus_implies_le_infimum` lemma | "If K⁻(¬D)(s) and D holds above infimum, then s ≤ infimum" | ~50 lines |
| **REWRITE** the sorry sites S1, S2, S4, S7-right | Replace current approach with K⁻(¬D) argument | ~200 lines (replacing sorry + surrounding dead code) |
| **REMOVE** Case A/Case B split at the sorry sites | The K⁻ approach works uniformly | ~ -150 lines |
| **REMOVE** unused `cont_holds_cross`-specific workarounds | Dead code after K⁻ approach | ~ -100 lines |

**Net change**: ~+120 lines new infrastructure, ~-250 lines removed workarounds = ~-130 net

### Step-by-Step Implementation

**Step 1** (~40 lines): Prove `K_minus_from_cofinal_failure`:
```lean
theorem K_minus_from_cofinal_failure
    (D : StaviFormula) (hD_depth : stavi_depth D ≤ r)
    (h_cofinal : ∀ s < t, mu_holds s → ∃ u, s < u ∧ u < t ∧ mu_holds u ∧ ¬stavi_temporal_truth_mu M atomMap r u D) :
    stavi_temporal_truth_mu M atomMap (r+2) (rank_embed t) (sf_K_minus (.neg D))
```

This follows from `sf_K_minus_iff`: K⁻(¬D)(t) ↔ ¬∃ s < t, ∀ mu u ∈ (s,t), D(u). The cofinal failure of D gives: for any s, there exists u where ¬D(u), so no s witnesses the "D holds on (s,t)" condition.

**Step 2** (~30 lines): Transfer K⁻(¬D) through formula agreement:
The formula sf_K_minus (.neg D) has stavi_depth = stavi_depth D + 2 ≤ r+2. The game at rank r+2 (h_fwd_r1) gives formula agreement at depth ≤ r+2. Direct application.

**Step 3** (~50 lines): Prove `K_minus_implies_le`:
```lean
theorem K_minus_implies_le_infimum
    (D : StaviFormula) (hD_depth : stavi_depth D ≤ r)
    (h_D_above : ∀ v, d < v → v < y' → mu_holds v → stavi_temporal_truth_mu N atomMap r v D)
    (h_K : stavi_temporal_truth_mu N atomMap (r+2) response (sf_K_minus (.neg D))) :
    response ≤ rank_embed d
```

Proof: If response > rank_embed(d), take any mu s between rank_embed(d) and response. All mu u in (s, response) with u > d satisfy D (from h_D_above). So ∃ s with ∀ mu u ∈ (s, response), D(u). This means ¬K⁻(¬D)(response) — contradiction.

**Step 4** (~200 lines): Rewrite sorry sites using the three lemmas. The argument becomes:
1. Get D from pigeonhole (already done in current code at line ~1350)
2. Apply K_minus_from_cofinal_failure to get K⁻(¬D) at rank_embed(c_inf)
3. Transfer via formula agreement to get K⁻(¬D) at r2_resp
4. Apply K_minus_implies_le to get r2_resp ≤ rank_embed(d)
5. Combined with h_not_le (rank_embed(d) < r2_resp), get contradiction

**This works uniformly for both carrier-point and gap responses** because:
- K⁻(¬D) is a formula of depth r+2 — its truth at a gap is well-defined via temporal connective semantics
- The transfer via formula agreement works at rank r+2 regardless of whether response is a point or gap
- No case split on point vs gap is needed

---

## 6. Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Pigeonhole gives D that fails cofinally below c_inf (M-side) but we need cofinality in a cross-structure context | MEDIUM | HIGH | Verify that `pigeonhole_definable_formula_cross` provides cross-structure cofinal failure |
| K⁻(¬D) truth at gaps in N: does the transfer work when response is a gap? | LOW | MEDIUM | sf_K_minus_iff works for all elements including gaps — verified by semantics |
| The "D holds above d" premise: pigeonhole gives D on (a_n, y') in N, but we need D above d specifically | LOW | LOW | d ≤ a_n (from hd_le_an), so (d, y') ⊇ (a_n, y') — D holds on the larger interval |
| The cofinal failure from pigeonhole is below the INFIMUM (cut points), but K⁻ needs cofinality below a SPECIFIC point (c_inf) | MEDIUM | HIGH | The pigeonhole outputs failures in `inf_carrier_cut` which ARE below the infimum. c_inf is derived from this infimum. Need to verify the chain connects. |

### Critical Verification Needed

The pigeonhole (`pigeonhole_definable_formula_cross`, line 856) provides:
- D fails cofinally in `inf_carrier_cut(continuation_set_cross ...)` — points below the infimum

But we need: D fails cofinally below c_inf among mu-points (for sf_K_minus_iff).

The connection: `inf_carrier_cut` points ARE carrier points (= mu-points) below the infimum. So "D fails cofinally in inf_carrier_cut" IS "D fails at mu-points cofinally approaching the infimum from below."

**This should work.** The gap between the pigeonhole output and the K⁻ input is bridgeable.

---

## 7. Verdict

### The Full cont_holds → Formula Refactoring is CIRCULAR and NOT FEASIBLE

You cannot construct `continuation_formula : StaviFormula` non-circularly at arbitrary depth r. The construction requires `nf_characterizable_by_stavi` (sorry S13) which IS the theorem being proved.

### The Pigeonhole + K⁻ Integration IS Feasible and Non-Circular

The pigeonhole already extracts a single formula D non-circularly (using NormalForm's Fintype + nf_determines_stavi_truth). The missing piece is connecting D's cofinal failure to the K⁻ formula and using game transfer. This requires ~120 lines of new lemmas and ~200 lines of sorry-site rewrites.

### Recommended Path

1. **Do NOT remove cont_holds** — it correctly defines the continuation set and its properties
2. **Do NOT attempt to materialize C** — it's circular
3. **ADD the K⁻(¬D) bridge** — 3 new lemmas (~120 lines) connecting pigeonhole output to K⁻ transfer
4. **REWRITE sorry sites** to use K⁻(¬D) argument — uniform for points and gaps, no case split needed
5. **REMOVE dead workaround code** — the Case A/Case B split and boundary-specific handling become unnecessary

### Why This Follows GHR93

GHR93 uses C' = ¬C ∨ K⁻(¬C) where C is the full interval-type formula. We use K⁻(¬D) where D is a single formula extracted by pigeonhole. The K⁻ argument structure is IDENTICAL:
- GHR93: C fails cofinally below infimum → K⁻(¬C) holds at infimum → transfer → response ≤ d
- Ours: D fails cofinally below infimum → K⁻(¬D) holds at infimum → transfer → response ≤ d

The difference: GHR93's C captures the FULL interval type (overkill for this argument). Our D is a single separating formula (sufficient). Both enable the same 5-line Claim 1 proof structure.

---

## 8. Immediate Next Steps

1. Verify that `pigeonhole_definable_formula_cross` output connects to K⁻ input (check types and premises)
2. Implement `K_minus_from_cofinal_failure` (~40 lines)
3. Implement `K_minus_transfer` (may be trivial — just depth check + formula agreement application)
4. Implement `K_minus_implies_le_infimum` (~50 lines)
5. Apply to S1, S2 (the test cases)
6. If S1+S2 close: apply to S4 and S7-right (same pattern)
