# Handoff: Gap-at-L Analysis for limitDomSubtype_isSuccArchimedean

**Session**: sess_1778562933_6e9ed4
**Task**: 123
**Phase**: 2 (MCS Periodicity / Gap-at-L Contradiction)
**Status**: BLOCKED - formalization barrier identified

## Current State of the Sorry

File: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean`
Line: 1402

The proof context at the sorry site has:
- `a b : LimitDomSubtype A h_mcs` with `a <= b`
- `h_not_cofinal : forall n, s^[n] a < b` (orbit never reaches b)
- `s := limitDomSubtype_succ`, `p := limitDomSubtype_pred`
- `L := iSup f_up` where `f_up n = (s^[n] a).val` cast to R
- Three helper lemmas that handle two of three cases by trichotomy on `(p c).val` vs `L`:
  - `h_pred_below_L_contradiction`: c above orbit and (p c).val < L => False
  - `h_pred_at_L_contradiction`: c above orbit and (p c).val = L => False
  - `h_below_L_is_orbit`: domain point w with a <= w and w.val < L => w is orbit element

**Goal**: `False`

**Remaining case**: The "gap-at-L" scenario where ALL domain points c above the orbit have `(p c).val > L`. In this scenario, the orbit (below L) and above-orbit region (above L) are separated by a gap.

## Mathematical Analysis

### Why the gap scenario is impossible

The gap scenario is impossible because of how the omega-chain construction places C5 witnesses. Specifically:

1. **Each orbit element s^[n+1] a is the C5 witness for U(T,bot) at s^[n] a.** The strong C5 property (`limit_satisfies_c5_strong`) with guard xi = bot means no domain points exist between s^[n] a and the witness y. So y is the immediate successor = s^[n+1] a.

2. **The C5 walk for U(T,bot) always uses the split case** (inserts at midpoint). This is because condition (i) of the C5 forward walk requires `bot /\ U(top, bot) in f(x')` which needs `bot in f(x')` -- impossible since bot is never in any MCS. So the witness is always at `(s^[n] a.val + x'_N) / 2` where x'_N is the next domain point above s^[n] a at the processing stage.

3. **The ceiling values x'_N converge to L.** Since `s^[n+1] a.val = (s^[n] a.val + x'_N) / 2`, we get `x'_N = 2 * s^[n+1] a.val - s^[n] a.val`. As n -> infinity, both s^[n] and s^[n+1] approach L, so x'_N -> 2L - L = L.

4. **Ceiling values are domain points.** Each x'_N is in dom(N) subset limit_dom. If x'_N > L for infinitely many n (which happens in the gap scenario when the ceiling is an above-orbit element), then there are domain points with values converging to L from above.

5. **Domain points approaching L from above have predecessors approaching L.** For each such domain point d with d.val close to L from above, pred(d).val < d.val. In the gap scenario, pred(d).val > L. But pred(d).val < d.val, so pred(d).val is between L and d.val. As d.val -> L, pred(d).val -> L too.

6. **Eventually, a predecessor drops below L.** The pred-chain from each ceiling point generates a strictly decreasing sequence of rationals bounded below by L. If the ceiling values converge to L, then eventually the predecessor of a ceiling point must have value <= L, giving a contradiction via `h_pred_below_L_contradiction` or `h_pred_at_L_contradiction`.

### Why formalization is blocked

The argument in step 2-3 above requires knowledge of the **midpoint placement** from the C5 forward walk in `CounterexampleElimination.lean`. Specifically, it needs:

- **The witness value formula**: `y = (pt + x') / 2` in the split case of `c5_forward_walk` (line 1058 of CounterexampleElimination.lean).
- **That condition (i) never fires for xi = bot**: because `bot /\ U(top, bot) in f(x')` requires `bot in f(x')`, which is impossible.

The current API does NOT expose these facts. The available lemmas (`limit_satisfies_c5_weak`, `limit_satisfies_c5_strong`, `omega_chain_c5_witness`) provide existential witnesses but not the specific rational values or the midpoint relationship.

### What's needed to close the sorry

**Option A: New API lemma (recommended, ~100-150 lines)**

Add a new lemma to `ChronicleConstruction.lean`:

```lean
theorem omega_chain_c5_witness_value_bot (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (n : Nat) (x : Rat)
    (hx : x ∈ (omega_chain_val A h_mcs n).dom)
    (h_next : Formula.untl top_formula Formula.bot ∈ (omega_chain_val A h_mcs n).f x)
    (hn_eq : counterexample_enum (Nat.unpair n).2 = ⟨x, 0, Formula.bot, top_formula, .c5_forward⟩)
    -- The witness is NOT already resolved (which is always true for xi=bot)
    (h_not_resolved : ¬∃ y ∈ (omega_chain_val A h_mcs n).dom, x < y ∧
      top_formula ∈ (omega_chain_val A h_mcs n).f y ∧
      (∀ a b, Adjacent (omega_chain_val A h_mcs n).dom a b →
        x ≤ a → b ≤ y → Formula.bot ∈ (omega_chain_val A h_mcs n).g a b) ∧
      (∀ w ∈ (omega_chain_val A h_mcs n).dom,
        x < w → w < y → Formula.bot ∈ (omega_chain_val A h_mcs n).f w)) :
    -- The witness y satisfies: there exists x' (next point above x in dom(n))
    -- such that y = (x + x') / 2, OR x = max(dom(n)) and y > max(dom(n))
    ∃ y ∈ (omega_chain_val A h_mcs (n + 1)).dom,
      x < y ∧ y ∉ (omega_chain_val A h_mcs n).dom ∧
      (∃ x' ∈ (omega_chain_val A h_mcs n).dom, x < x' ∧
        (∀ w ∈ (omega_chain_val A h_mcs n).dom, x < w → x' ≤ w) ∧
        y = (x + x') / 2) ∨
      (∀ w ∈ (omega_chain_val A h_mcs n).dom, w ≤ x)
```

This lemma exposes the midpoint relationship for U(T,bot) witnesses. With this, the gap-at-L proof becomes:

1. For large n, the ceiling x'_N converges to L (from the formula x'_N = 2*s^[n+1] - s^[n])
2. The ceiling x'_N is a domain point in limit_dom
3. For large n, x'_N is close to L from above (in gap scenario, x'_N > L)
4. pred(x'_N) has value between L and x'_N (gap scenario) or <= L (contradiction)
5. As x'_N -> L, pred(x'_N) is squeezed -> L, eventually hitting <= L

**Option B: Icc finiteness (alternative, ~200-300 lines)**

Prove `Set.Finite (Set.Icc a b)` for any a, b in LimitDomSubtype, using the subformula closure to bound the number of domain points. Then derive IsSuccArchimedean by induction on |Icc a b|. This avoids the gap analysis entirely but requires substantial new infrastructure.

**Option C: Direct first_stage induction (alternative, ~150-200 lines)**

Prove the stronger claim `forall c, a <= c -> exists n, s^[n] a = c` by well-founded induction on `Nat.find c.property` (first stage at which c enters the domain). The step case works when c was placed between two existing points (the upper point has smaller first_stage). The base case (c.val = 0, a < c) requires separate treatment but can be handled by noting that a was also inserted at some stage, between points that include 0.

The issue with this approach is that when c is placed "beyond max(dom)", there's no point above c with smaller first_stage. However, this case can be handled by using the point BELOW c (which has smaller first_stage) and then showing succ reaches c through the limit structure.

## Recommendation

**Option A** is recommended as it directly addresses the mathematical gap with minimal new code. It requires adding one new theorem to `ChronicleConstruction.lean` that exposes the midpoint placement for U(T,bot) witnesses, then using this theorem in the gap-at-L proof.

**Plan revision** should be run (`/revise 123`) to incorporate the new API lemma approach.

## Files Involved

- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (sorry at line 1402)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (new API lemma)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (source of midpoint facts, lines 1058 and 684-686)

## Context Budget

This handoff is being written because the agent has spent significant context on analysis without achieving a compilable proof. A fresh agent should:
1. Read this handoff
2. Read the plan at `specs/123_fix_c5_witness_bot_and_prove_icc_finite/plans/07_mcs-periodicity.md`
3. Implement Option A (or whichever option the revised plan specifies)
