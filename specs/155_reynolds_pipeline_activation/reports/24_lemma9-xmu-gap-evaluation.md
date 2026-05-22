# Research Report: GHR93 Lemma 9 -- The X^mu(gamma) Evaluation Problem

**Task**: 155 (Reynolds Pipeline Activation)
**Focus**: How does GHR93 evaluate formulas at gaps in M_r?
**Date**: 2026-05-21

## 1. Executive Summary

The `stavi_untl_gap_detection` theorem has a structural mismatch between what the forward direction can prove (X holds at complement points near the gap) and what its conclusion demands (X^mu evaluated AT the gap). This report traces the problem to a specific design decision in the Lean encoding and identifies the correct fix based on what GHR93 actually requires.

**Key finding**: GHR93 Lemma 9 does NOT require `stavi_untl_gap_detection` to produce `X^mu(gamma)` for arbitrary X. Lemma 9 only ever invokes the U'-gap-detection equivalence with specific X values, and the A^mu(gamma) obligation in Lemma 9 is at the OUTER induction level -- not at the X level of the helper. The correct fix is to weaken `stavi_untl_gap_detection` to provide X at complement points, and let `left_formula_gap_detection` construct `A^mu(gamma)` from those complement-point witnesses directly.

## 2. What GHR93 Says Precisely

### 2.1 Definition 8.4 (Relativised Connectives) -- PDF p.109-110

The paper defines M_r = M union {r-definable gaps}, with a new predicate mu where h'(mu) = M (actual points). For any temporal formula A built from {U, S, U', S'}, A^mu is obtained by replacing each U by U^mu, S by S^mu, U' by U'^mu, S' by S'^mu. The relativised connectives restrict quantification to mu-points.

Key passage (Remark 2, p.110):
> "If t in M then M |= A(t) iff M_r |= A^mu(t)."

This states that at actual points, mu-relativized truth equals standard truth. The Lean code's `stavi_truth_mu_at_point` proves exactly this.

**Crucially, there is no analogous remark for gaps.** The paper does not claim any simplification of A^mu(gamma) when gamma is a gap. At a gap, A^mu(gamma) is evaluated using the full mu-relativized semantics: atoms are false (since h'(q) = h(q) subset M for atoms q, and gamma not in M), but temporal connectives can "reach through" to actual points.

### 2.2 Definition 8.5 (left formula) -- PDF p.110

```
left(p, D)         = bot                    (for atomic p)
left(neg A, D)     = U'(top, D) AND neg left(A, D)
left(A AND B, D)   = left(A, D) AND left(B, D)
left(U(A,B), D)    = U'(B AND U(A,B), D)
left(U'(A,B), D)   = U'(B AND U'(A,B), D)
left(S(A,B), D)    = U(D AND B AND S(A,B) AND U'(top, B AND D) AND neg U'(D, B AND D), D)
left(S'(A,B), D)   = U(D AND B AND S'(A,B) AND U'(top, B AND D) AND neg U'(D, B AND D), D)
```

### 2.3 Lemma 9 -- PDF p.111

> LEMMA 9. Let A, D be temporal formulas with D of rank at most r. Let m in M_r. Then the following are equivalent:
> 1. M_r |= left(A, D)^mu(m);
> 2. There is gamma in M_r - (M union {+-oo}), gamma a gap of M defined by D to the left, with (a) gamma > m, (b) D holds in M on (m, gamma), and (c) M_r |= A^mu(gamma).
>
> PROOF. Clear.

### 2.4 The U'(A,B) FO Table -- PDF p.95

```
U'(p,q) ≡
  exists s,  t < s
    AND  forall u (t < u < s ->
           ([ exists v(u < v AND forall w(t < w < v -> q(w))) ]
            V [ forall v(u < v < s -> p(v))
                AND exists v(t < v < u AND neg q(v))     ]))
    AND  exists u[t < u < s AND neg q(u)]
    AND  exists u[t < u < s AND forall v(t < v < u -> q(v))]
```

## 3. How A^mu(gamma) Works for Temporal A

### 3.1 Atoms at Gaps: Always False

For atomic p, p^mu(gamma) = h'(p)(gamma) = False, since h'(p) = h(p) subset M and gamma not in M. This is correctly encoded in the Lean code:

```lean
noncomputable def extendedStructure ... where
  interp := fun p e => match e with
    | .inl x => M.interp p x
    | .inr _ => False  -- gaps have no predicate values
```

### 3.2 Temporal Connectives at Gaps: Can Be True

For U'(A,B)^mu(gamma), the evaluation proceeds as:

```
exists s > gamma in M_r such that:
  (1) forall mu-point u in (gamma, s): [first disjunct OR second disjunct]
  (2) exists mu-point u in (gamma, s) with neg B^mu(u)
  (3) exists mu-point u in (gamma, s) with B^mu on (gamma, u)
```

The mu-points in (gamma, s) are precisely the actual points (elements of M) that lie in the complement of the gap's cut. These are the points immediately above the gap. So U'(A,B)^mu(gamma) talks about the behavior of A and B at actual points near gamma -- it CAN be true even though atoms at gamma itself are false.

This is correctly encoded in the Lean `stavi_temporal_truth_mu` (EFGames.lean:823-882).

### 3.3 Conjunction at Gaps

For (A AND B)^mu(gamma):
```
stavi_temporal_truth_mu ... (Sum.inr gamma) (.conj A B) =
  stavi_temporal_truth_mu ... (Sum.inr gamma) A AND
  stavi_temporal_truth_mu ... (Sum.inr gamma) B
```

This means (B AND U'(A,B))^mu(gamma) = B^mu(gamma) AND U'(A,B)^mu(gamma).

**Here is the crux of the problem**: If B is an atom, then B^mu(gamma) = False, so (B AND U'(A,B))^mu(gamma) = False regardless of whether U'(A,B)^mu(gamma) is True.

## 4. Analysis of the Blocker

### 4.1 The stavi_untl_gap_detection Theorem

The current theorem (EFGames.lean:2413-2425) has this structure:

```
U'(X, D)^mu(extendPoint m) <->
  exists gamma, s_bound:
    m < gamma AND
    gap_definable_on_left gamma D AND
    D-between(m, gamma) AND
    X at complement points below s_bound
```

**Note**: The conclusion provides "X at complement points" (last conjunct), NOT "X^mu(gamma)". This was a deliberate design choice (see docstring at line 2409-2411).

### 4.2 The left_formula_gap_detection Theorem

The statement (EFGames.lean:2717-2727) requires:

```
left_formula(A, D)^mu(extendPoint m) <->
  exists gamma:
    m < gamma AND
    gap_definable_on_left gamma D AND
    D-between(m, gamma) AND
    A^mu(Sum.inr gamma)        <--- THIS is the RHS obligation
```

### 4.3 The Gap Between Helper and Main Theorem

For the `stavi_untl` case where A = U'(A0, B0):
- `left_formula(U'(A0,B0), D) = U'(B0 AND U'(A0,B0), D)`
- The helper `stavi_untl_gap_detection` with X = B0 AND U'(A0,B0) gives: X at complement points
- The main theorem needs: U'(A0,B0)^mu(gamma)
- From X at complement points, we can extract U'(A0,B0) at complement points
- From U'(A0,B0) at complement points near gamma, we need U'(A0,B0)^mu(gamma)

**This last step IS valid**: U'(A0,B0)^mu(gamma) talks about actual points above gamma (condition 1-3 quantify over mu-points). If U'(A0,B0) holds at some complement point u0, then the FO table witnesses for U'(A0,B0)(u0) can be lifted to witnesses for U'(A0,B0)^mu(gamma), because the points in (u0, s0) that witness the FO table at u0 are also above gamma and are mu-points.

**The issue is NOT that U'(A0,B0)^mu(gamma) cannot be proved.** The issue is that the current code tries to go through X^mu(gamma) = (B0 AND U'(A0,B0))^mu(gamma), which requires B0^mu(gamma), which is False for atomic B0. But Lemma 9 only needs the U'(A0,B0) component, not the full conjunction.

### 4.4 Does GHR93 Need B^mu(gamma)?

**No.** The paper says "Clear" for the proof, meaning the induction should go through smoothly. For the case A = U'(A0, B0):

- LHS: left(U'(A0,B0), D)(m) = U'(B0 AND U'(A0,B0), D)(m)
- RHS: exists gamma, conditions AND U'(A0,B0)^mu(gamma)

The paper's proof by "Clear" means: the U' on the LHS detects a gap where B0 AND U'(A0,B0) holds at nearby actual points, and from those points' truth of U'(A0,B0), we construct U'(A0,B0)^mu(gamma). The B0 component is needed for the U' FO table structure (condition 3 needs B0 to hold initially), not for evaluation at the gap.

In other words: The paper evaluates A = U'(A0,B0) at the gap, NOT X = B0 AND U'(A0,B0). The X in left(A,D) is an artifact of the gap-detection formula's construction, not the formula being evaluated at the gap.

## 5. The Correct Proof Architecture

### 5.1 What stavi_untl_gap_detection Should Provide

The helper should provide X-truth at complement points (as it already does), NOT X^mu(gamma). The current code already has this right in the statement -- the issue is that `left_formula_gap_detection` tries to get A^mu(gamma) from the helper's output, and the way it does this for the `stavi_untl` case needs adjustment.

### 5.2 How left_formula_gap_detection Should Work (stavi_untl Case)

For A = U'(A0, B0), D:

**Forward**: From left_formula(U'(A0,B0), D)(m) = U'(B0 AND U'(A0,B0), D)(m):
1. Apply stavi_untl_gap_detection with X = conj B0 (stavi_untl A0 B0) to get:
   - Gap gamma, D-between(m, gamma), gap_definable_on_left
   - (B0 AND U'(A0,B0)) at complement points near gamma
2. Extract U'(A0,B0) at complement points: for each complement point u, we have stavi_temporal_truth M atomMap u (.stavi_untl A0 B0)
3. From U'(A0,B0)(u0) at some complement point u0 near gamma, construct U'(A0,B0)^mu(gamma):
   - U'(A0,B0)(u0) unfolds to the FO table at u0: exists s > u0, conditions 1-3
   - Since u0 is above gamma, the FO table witnesses at u0 are all above gamma
   - Re-package these witnesses as FO table witnesses at gamma (with mu-restriction)
   - The s witness stays the same, conditions 1-3 transfer because every point in (u0, s) is also in (gamma, s) and is a mu-point

**This is the key mathematical step**: The FO table of U'(A0,B0) at a complement point u0 provides witnesses that also work for U'(A0,B0)^mu(gamma), because:
- (gamma, s) contains (u0, s) (since u0 > gamma)
- Points in (u0, s) are all complement points (above u0 which is in complement, and complement is upward-closed)
- Mu-points in (gamma, s) include all complement points in (gamma, s)
- Condition 3 (B holds initially above gamma): B holds at complement points below some bound from the original FO table at u0, AND B might also hold at complement points between gamma and u0. This needs B at complement points, which stavi_untl_gap_detection provides.
- Condition 2 (B fails somewhere): a B-failure witness from the FO table at u0 works at gamma too
- Condition 1 (main body): transfers from u0's FO table to gamma's mu-table

Actually, it is even simpler. Since `stavi_truth_mu_at_point` tells us:
```
stavi_temporal_truth_mu M atomMap r (extendPoint u0) (.stavi_untl A0 B0) <->
stavi_temporal_truth M atomMap u0 (.stavi_untl A0 B0)
```

And we have the latter from the helper. So we have `stavi_temporal_truth_mu` at `extendPoint u0`. But we need it at `Sum.inr gamma`, not `extendPoint u0`.

The transfer from `extendPoint u0` to `Sum.inr gamma` requires showing the FO table witnesses at u0 also work at gamma. Specifically:

For U'(A0,B0)^mu(gamma), we need:
```
exists s > gamma:
  (1) forall mu-point u in (gamma, s): disjunction
  (2) exists mu-point u in (gamma, s): neg B^mu(u)
  (3) exists mu-point u in (gamma, s): B^mu on (gamma, u)
```

From U'(A0,B0)(u0) at complement point u0 > gamma, we have:
```
exists s1 > u0:
  (1') forall u in (u0, s1): disjunction
  (2') exists u in (u0, s1): neg B(u)
  (3') exists u in (u0, s1): B on (u0, u)
```

But we also have B at complement points from the helper: B holds at complement points below s_bound. Combined with (3'), we can extend B-holding to the interval (gamma, some_bound).

So the construction is:
- Use s1 (from u0's FO table) as the upper bound s for gamma's FO table
- For condition (3): B holds at complement points between gamma and u0 (from helper), and B holds between u0 and some bound (from 3'). Combine.
- For condition (2): reuse the witness from (2')
- For condition (1): for mu-points in (gamma, s1):
  - If between gamma and u0: use B-cofinality from the helper (left disjunct)
  - If between u0 and s1: transfer from (1')

**This is exactly what the current forward-direction code at lines 2870-3005 already does.** The code correctly avoids X^mu(gamma) and instead directly constructs U'(A0,B0)^mu(gamma) from complement-point witnesses. The forward direction for the `stavi_untl` case is essentially complete in the codebase.

### 5.3 Backward Direction

For the backward: given gamma with U'(A0,B0)^mu(gamma), need U'(B0 AND U'(A0,B0), D)(m).

From U'(A0,B0)^mu(gamma):
- Condition (3) gives B at mu-points initially above gamma
- The FO table structure gives U'(A0,B0) at complement points (need to verify this -- it requires showing that the FO table "shifts" to give truth at nearby complement points)

The key claim for the backward direction: if U'(A0,B0)^mu(gamma) holds with FO witness s, then for any complement point u in (gamma, s), U'(A0,B0) holds at u. This is because:
- The FO table conditions at gamma restricted to mu-points give conditions at u restricted to points, since all mu-points in (gamma, s) are actual points (complement of cut)
- u is a mu-point in (gamma, s), so the conditions hold "around" u

This is the same "complement-point transfer" argument, run in reverse. The sorry at line 3032 is this step.

## 6. Comparison: GHR93 vs Lean Encoding

| Aspect | GHR93 Paper | Lean Encoding | Mismatch? |
|--------|-------------|---------------|-----------|
| A^mu(gamma) definition | Standard mu-relativized evaluation on M_r | `stavi_temporal_truth_mu M atomMap r (Sum.inr gamma) A` | NO |
| Atoms at gaps | False (h'(q) subset M) | `extendedStructure.interp ... (.inr _) => False` | NO |
| Temporal at gaps | Quantify over mu-points | Quantify with `mu_holds` guard | NO |
| Lemma 9 RHS | A^mu(gamma) | `stavi_temporal_truth_mu ... (Sum.inr gamma) A` | NO |
| stavi_untl_gap_detection | Not an explicit lemma in the paper | Extracted as helper; provides X at complement points | N/A -- reasonable factoring |
| left(U'(A,B), D) case | "Clear" -- induction step | Needs X^mu(gamma) -> A^mu(gamma) bridge | YES -- **this is the gap** |

The mismatch is NOT in the mathematical content. It is in how the proof is organized. The paper says "Clear" because the induction on A directly matches: for A = U'(A0,B0), the LHS unfolds to U'(B0 AND U'(A0,B0), D)(m), and the RHS asks for U'(A0,B0)^mu(gamma). The gap detection formula's X = B0 AND U'(A0,B0) contains A = U'(A0,B0) as a subformula, so complement-point truth of X yields complement-point truth of A, which transfers to A^mu(gamma).

## 7. Recommended Fix

### Option A: Keep stavi_untl_gap_detection as-is, fix left_formula_gap_detection (RECOMMENDED)

The helper `stavi_untl_gap_detection` already has the right statement. It provides X at complement points. The fix is in `left_formula_gap_detection`, specifically:

**Forward direction** (stavi_untl case, lines 2870-3005):
- From stavi_untl_gap_detection, get (B AND U'(A,B)) at complement points
- Extract U'(A,B) at complement points (projection)
- Construct U'(A,B)^mu(gamma) directly from complement-point witnesses
- This is what lines 2870-3005 already do. The code is essentially correct and just needs the sorry at line 3032 removed (backward direction).

**Backward direction** (stavi_untl case, line 3032):
- Given gamma with U'(A,B)^mu(gamma)
- Need U'(B AND U'(A,B), D)(m), which by stavi_untl_gap_detection.mpr needs:
  - Gap gamma (given)
  - (B AND U'(A,B)) at complement points near gamma
- From U'(A,B)^mu(gamma), extract:
  - B at complement points (from condition 3 of the mu-FO-table)
  - U'(A,B) at complement points (from the FO-table "shift" lemma below)
- Combine to get (B AND U'(A,B)) at complement points

**New lemma needed** ("FO-table shift at gap"):
```lean
theorem stavi_untl_mu_at_gap_gives_complement_truth
    {gamma : RDefinableGap M atomMap r} (A B : StaviFormula)
    (h : stavi_temporal_truth_mu M atomMap r (Sum.inr gamma) (.stavi_untl A B)) :
    -- For complement points u near gamma, U'(A,B)(u)
    exists s_bound : M.carrier,
      s_bound not-in gamma.val.cut AND
      forall u : M.carrier, u not-in gamma.val.cut -> u < s_bound ->
        stavi_temporal_truth M atomMap u (.stavi_untl A B)
```

This lemma says: if U'(A,B)^mu holds at a gap, then U'(A,B) holds at complement points near the gap. The proof unfolds U'(A,B)^mu(gamma) to its FO table form, gets s and conditions (1)(2)(3) over mu-points, and for a complement point u in (gamma, s), constructs the standard FO table at u by restricting to points in (u, s).

Similarly, B at complement points comes from condition (3) of U'(A,B)^mu(gamma), combined with stavi_truth_mu_at_point.

### Option B: Refactor into two-layer architecture (ALTERNATIVE)

Split `left_formula_gap_detection` into:
1. "Complement-point detection": left_formula(A,D)(m) <-> exists gamma, conditions, A at complement points
2. "Complement-to-gap transfer": A at complement points near gamma -> A^mu(gamma)

This makes the architecture cleaner but requires proving (2) for all StaviFormula constructors.

### Recommendation

**Option A** is recommended because:
- The forward direction for stavi_untl is already nearly complete (lines 2870-3005)
- Only the backward sorry (line 3032) and a small transfer lemma are needed
- The stavi_snce, std_untl, std_snce cases follow the same pattern
- Less refactoring of existing proved code

## 8. Specific Sorry Inventory and Required Actions

| Location | Sorry | What's Needed | Difficulty |
|----------|-------|---------------|------------|
| EFGames.lean:2759 | base(.imp) case | Expand to neg/conj pattern | Medium |
| EFGames.lean:2763 | base(.untl) case | Same as stavi_untl outer case | Medium |
| EFGames.lean:2767 | base(.snce) case | Same as std_snce outer case | Medium |
| EFGames.lean:3032 | stavi_untl backward | FO-table shift lemma + B from condition 3 | Hard |
| EFGames.lean:3036 | stavi_snce case | Standard-Until variant | Hard |
| EFGames.lean:3083 | std_untl backward | Same pattern as stavi_untl backward | Hard |
| EFGames.lean:3087 | std_snce case | Standard-Until variant | Hard |
| EFGames.lean:2682 | std_untl_gap_detection | Analogous to stavi_untl_gap_detection | Hard |
| EFGames.lean:3109 | stavi_snce_gap_detection | Dual of stavi_untl | Hard |
| EFGames.lean:3124 | std_snce_gap_detection | Dual of std_untl | Hard |
| EFGames.lean:3137 | right_formula_gap_detection | Dual of left | Hard |

## 9. Summary of Key Findings

1. **GHR93 evaluates A^mu(gamma) at gaps using the standard mu-relativized semantics**: atoms are False at gaps, temporal connectives quantify over mu-points. This is correctly encoded in `stavi_temporal_truth_mu`.

2. **The paper does NOT have a special mechanism for evaluating formulas at gaps.** It relies on the fact that temporal formulas' truth at a gap is determined by actual-point behavior near the gap (through the mu-restricted quantifiers).

3. **The X^mu(gamma) problem is a proof architecture issue, not a mathematical one.** The paper's "Clear" proof works because the induction on A directly gives A^mu(gamma) from complement-point witnesses of the left_formula. The Lean factoring through `stavi_untl_gap_detection` (which provides X at complement points for X != A) creates an intermediate step that needs a transfer lemma.

4. **B^mu(gamma) for atomic B IS False**, and the paper's proof does not require it. The conjunction B AND U'(A,B) appears inside left(U'(A,B), D) = U'(B AND U'(A,B), D) as the X for gap detection, but the Lemma 9 RHS only needs U'(A,B)^mu(gamma), not (B AND U'(A,B))^mu(gamma).

5. **The correct fix** is to keep `stavi_untl_gap_detection` as-is (providing X at complement points) and add a "FO-table shift" lemma that transfers temporal truth from complement points to mu-relativized truth at the gap, specifically for the backward direction of the stavi_untl case.
