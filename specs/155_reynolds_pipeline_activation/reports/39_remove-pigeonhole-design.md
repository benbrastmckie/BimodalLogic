# Design Report: Pigeonhole Removal Analysis

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-23
**Purpose**: Determine whether pigeonhole can be removed and replaced with GHR93's construction

---

## 1. Circularity Claim: Partially True

Report 38 claimed building `NormalForm -> StaviFormula` is circular. Analysis:

**Non-circular part:** `nf_char_formula : NormalForm sig k n -> MonadicFormula sig n` is constructible. Standard Hintikka formula: at depth 0, conjoin atom literals per the Boolean assignment; at depth k+1, add `ex(char sub_nf)` / `not(ex(char sub_nf))` for each sub-NF using `Fintype` instances (lines 177, 93). This produces `MonadicFormula` of quantifier depth `<= k`. No inversion needed.

**Circular part:** Converting `MonadicFormula (muSig sig) 1` of depth `2*r` back to `StaviFormula` of depth `<= r` IS circular. This conversion is exactly `stavi_table_mu` inversion, which is the expressive completeness theorem being proved. The depth gap makes this unavoidable: `stavi_fo_depth <= 2 * stavi_depth` (line 8294), so a depth-`2*r` MonadicFormula maps to at most `stavi_depth r`. But constructing the preimage is the theorem itself.

**Why it matters:** The separator `D` in Claim 1 must be a `StaviFormula` with `stavi_depth D <= r`. This is because `K^-(neg D)` has `stavi_depth = D.stavi_depth + 2`, and the rank-(r+2) game budget from `h_fwd_r1` (line 1496) accommodates exactly `stavi_depth <= r + 2`. A `MonadicFormula` of depth `2*r` cannot serve as `D` because there is no depth-budget-compatible way to lift it to a StaviFormula without the theorem being proved.

**Bottom line:** `nf_char_formula` and `interval_type_formula` can be built as `MonadicFormula (muSig sig) 1`, but they cannot replace the pigeonhole's role of extracting a `StaviFormula` separator `D`.

---

## 2. What GHR93 Does That We Cannot Directly Replicate

GHR93 Definition 8.8 constructs `C = X_{(a_n, y')}` as a conjunction of temporal L-formulas (StaviFormulas) of rank `<= r`. The conjunction is "effectively finite" because there are finitely many equivalence classes at rank `r`. GHR93 takes one representative from each class.

In our codebase, the equivalence classes at rank `r` correspond to NormalForms at depth `2*r` (via `nf_determines_stavi_truth_depth`, line 631). There are `Fintype.card (NormalForm (muSig sig) (2*r) 1)` such classes. But we have no function `NormalForm (muSig sig) (2*r) 1 -> StaviFormula` that produces a representative of stavi_depth `<= r`.

Building such a function requires either:
- (a) Inverting `stavi_table_mu` (circular), or
- (b) Enumeration of all StaviFormulas up to depth `r`, evaluation against each NF, and selection of representatives. This needs a decision procedure for "does formula A hold at NF nf?" which requires model-checking `nf_eval_nf` against `stavi_table_mu A` -- constructible but ~500+ lines of new infrastructure.

---

## 3. What CAN Be Built (Infrastructure for Both Approaches)

### `nf_char_formula` (NormalForm.lean, ~160 lines total)

```lean
noncomputable def nf_char_formula {sig : MonadicSignature} :
    (k : Nat) -> (n : Nat) -> NormalForm sig k n -> MonadicFormula sig n

theorem nf_char_formula_correct :
    eval M env (nf_char_formula k n nf) <-> nf_eval_nf M k n env nf

theorem nf_char_formula_depth :
    (nf_char_formula k n nf).quantifier_depth <= k
```

Requires auxiliary `bigAnd : List (MonadicFormula sig n) -> MonadicFormula sig n` (~40 lines in MonadicFO.lean).

This is useful INDEPENDENTLY of the pigeonhole question: it materializes NFs as formulas for other proofs (e.g., Doets Lemma 1.1 corollaries, definability results).

### `interval_type_formula` (ExpressivenessGeneral.lean, ~80 lines)

```lean
noncomputable def interval_type_formula
    (a_n y' : ExtendedCarrier N atomMap r) : MonadicFormula (muSig sig) 1 :=
  bigOr [...nf_char_formula (2*r) 1 nf | nf realized in (a_n, y')...]

theorem interval_type_implies_cont_holds :
    eval ... (interval_type_formula a_n y') -> cont_holds a_n y' t
```

This materializes GHR93's `X_{(a_n, y')}` as a `MonadicFormula`, but at depth `2*r + 1` (one `ex` wrapper per disjunct, though actually the `nf_char_formula` already handles quantifiers, so it is depth `2*r`). Useful for the continuation set definition but CANNOT serve as the separator `D`.

---

## 4. Recommended Path: Case-Split (Report 38 Option 3)

The pigeonhole cannot be fully removed without ~500+ lines of StaviFormula enumeration/model-checking infrastructure. The case-split approach from Report 38 Section 3 is the correct, minimal fix:

### Implementation

At `h_d_unique` (line 2236), insert:

```lean
by_cases h_cont_d : cont_holds (a_bwd ⟨n, by omega⟩) y' d
```

**Case A: `cont_holds` HOLDS at `d`.** Every witness `u` from `h_cofinal_failure_below_d` satisfies `u < d` strictly (if `u = d`, cont_holds at `u = d` contradicts `not cont_holds u`). The existing `pigeonhole_definable_formula` runs with strict bounds. No boundary edge case.

**Case B: `cont_holds` FAILS at `d`.** Then `d` is a mu-point (otherwise `cont_holds` is vacuous). Unwinding `not cont_holds`: exists `A : StaviFormula` with `stavi_depth A <= r`, `A` holds on all mu-points in `(a_bwd(n), y')`, and `not stavi_temporal_truth_mu N atomMap r d A`. This `A` directly serves as the formula `D`. No pigeonhole needed for this case.

### Line estimates for case split

| Component | Lines |
|-----------|-------|
| Case split at h_d_unique (N-side, 2 sorries) | ~80 |
| Case split at h_r2_resp_le_d (M-side, 3 sorries) | ~100 |
| K^-(neg D) construction + semantics helper | ~60 |
| **Total** | **~240** |

### What stays vs. what changes

**KEEP:** `pigeonhole_definable_formula` (line 680, ~178 lines) -- used in Case A.
**KEEP:** `cont_holds`, `continuation_set`, infimum infrastructure -- structurally sound.
**REMOVE:** `pigeonhole_definable_formula_cross_strict` (line 1040, ~161 lines) -- replaced by case split in Case A making the strict precondition trivial.
**ADD:** Case-split logic + K^-(neg D) helper (~240 lines).

Net: remove ~161, add ~240, close 5 sorries.

---

## 5. K^-(neg D) Construction and Semantics

The separator formula for each direction of `le_antisymm`:

**`t' <= d` direction (line 2261, Case `d < t'`):**
- `d in S_C`, so cont_holds holds at all mu-points in `(d, y')`
- `D` holds at all mu-points in `(d, y')` (from cont_holds + D holding on interval)
- In particular, D holds on `(d, t')` for all mu-points
- `Since(top, D)(t')` is TRUE (witness: any mu-point in `(d, t')`)
- `D` fails cofinally below `d`, so there's no final segment below `d` where `D` holds everywhere... but we need `Since(top, D)(d)` to be FALSE
- `Since(top, D)(d)` = exists mu-point `s < d` with `D(s)`. This might be TRUE if D holds at SOME points below d
- **Correction:** Use `neg(stavi_untl(neg(base .bot), D))(d)` -- "NOT Until(top, D)" at d. This is `not(exists s > d with D(s) ...)` which is wrong direction.

The correct separator for `d < t'`:
- Build `F = neg(std_snce(base (.imp .bot .bot), neg D))` where `base (.imp .bot .bot)` = `top`
- `F(t) = not(exists s < t, not D(s) and forall u in (s,t), true)` = `not(exists s < t with not D(s))` = `D holds everywhere below t (among mu-points)`
- At `d`: `D` fails cofinally below d, so F(d) = FALSE
- At `t'` with `d < t'` and `d in S_C`: Does `D` hold everywhere below `t'`? No -- `D` fails below `d < t'`. So `F(t')` = FALSE too.

This doesn't work either. The correct approach from GHR93 uses the gap structure:

**GHR93's actual argument (p.116):** The gap `c` (= infimum of S_C) is r-definable by `D`. Gap definability means: `D` holds at all carrier points above the gap AND `D` does not hold on any final segment below the gap. Then `K^-(neg D)` = the formula capturing "below the gap" behavior. The gap structure itself (not just `d`) is what separates points.

**The proof does not separate `d` from `t'` by formula value at those two points.** Instead, it uses the rank-(r+2) forward strategy `h_fwd_r1` to show that Spoiler can force the response to match `d`. The `K^-(neg D)` formula of depth `r+2` distinguishes positions relative to the gap, and the game at rank `r+2` uses this to pin down the response.

This is already sketched in the comments at lines 2276-2306. The missing piece is the formula construction and its semantic properties. The case split makes this construction possible by providing the formula `D` (in Case B directly, in Case A via strict pigeonhole).

---

## 6. Why Complete Pigeonhole Removal Is Not Worth It

| Approach | New lines | Removes | Closes sorries | Risk |
|----------|-----------|---------|----------------|------|
| Case split (Report 38 Option 3) | ~240 | ~161 | All 5 | Low |
| Full formula materialization | ~700+ | ~540 | All 5 | High (untested infrastructure) |

The case-split approach:
- Follows GHR93's implicit case split (C(c) true or false)
- Keeps battle-tested pigeonhole for the one case that needs it
- Adds minimal new code
- Has no circularity concerns
- Closes all blocked sorries

Full materialization would build `nf_char_formula` + `stavi_enum` + model-checking + representative selection -- substantial infrastructure used exactly once. The effort-to-value ratio strongly favors the case split.

**Recommendation:** Implement the case split. Build `nf_char_formula` separately as independently useful infrastructure. Do NOT attempt full formula materialization.
