# Research Report: Lemma 9 Gap Detection Correctness -- Correct Proof Strategy

**Task**: 155 (Reynolds Pipeline Activation)
**Phase**: 4C-W2 blocker resolution
**Session**: sess_1779410200_3599b4
**Date**: 2026-05-21

## 1. What GHR93 Actually Says

### Lemma 9 Statement (GHR93 p.111)

> LEMMA 9. Let A, D be temporal formulas with D of rank at most r. Let m in M_r. Then the following are equivalent:
> 1. M_r |= left(A, D)^mu(m)
> 2. There is gamma in M_r - (M u {+-oo}), gamma a gap of M defined by D to the left, with (a) gamma > m, (b) D holds in M on (m, gamma), and (c) M_r |= A^mu(gamma).
>
> PROOF. Clear. A corresponding result holds for right(A, D).

### Definition 8.5 (left formula, GHR93 p.110)

```
left(p, D)         = bot                    (for atomic p)
left(neg A, D)     = U'(top, D) AND neg left(A, D)
left(A AND B, D)   = left(A, D) AND left(B, D)
left(U(A,B), D)    = U'(B AND U(A,B), D)
left(U'(A,B), D)   = U'(B AND U'(A,B), D)
left(S(A,B), D)    = U(D AND B AND S(A,B) AND U'(top, B AND D) AND neg U'(D, B AND D), D)
left(S'(A,B), D)   = U(D AND B AND S'(A,B) AND U'(top, B AND D) AND neg U'(D, B AND D), D)
```

### Remark 2 (GHR93 p.110)

> If t in M then M |= A(t) iff M_r |= A^mu(t).

This is critical: at actual points, mu-relativized truth in M_r equals standard truth in M. The Lean code's `stavi_truth_mu_at_point` proves exactly this.

## 2. The "Counterexample" Is Invalid

### Previous Analysis Was Wrong

The handoff `phase-4CW2-counterexample-20260521.md` claimed that `left_formula_gap_detection` is mathematically false, using a counterexample on Q with D = atom(a) interpreted as "x < sqrt(2)". The analysis claimed U'(top, D)(0) is False because "U(top,D)(0) is True, so condition 2 of U' fails."

**This analysis confused U' with a simplified characterization.** The handoff treated U'(A,B) as equivalent to "B cofinal AND NOT U(A,B)". This is NOT the correct definition. U'(A,B) is defined by its own independent FO table (the Stavi connective table from GHR93 Section 3), which is:

```
U'(p,q)(t) = exists s > t:
  (1) forall u in (t,s): [exists v > u, q on (t,v)] OR [p on (u,s), exists v' in (t,u), neg q(v')]
  (2) exists u in (t,s), neg q(u)
  (3) exists u in (t,s), q on (t,u)
```

### Verification That the "Counterexample" Actually Satisfies LHS = RHS = True

For M = Q, D = atom(a) with interp(a, x) = (x < sqrt(2)), m = 0, A = neg(base bot):

**LHS**: `stavi_temporal_truth_mu Q atomMap 0 (extendPoint 0) (left_formula A D)` = U'(top, D)(0) in Q.

Using the full FO table with witness s = 2 (a rational):
- **(3)**: Take u = 1. D(w) for all w in (0,1): all rationals in (0,1) are < sqrt(2). TRUE.
- **(2)**: Take u = 1.5. D(1.5) = (1.5 < sqrt(2)) = False. TRUE.
- **(1)**: For each rational u in (0,2):
  - If u < sqrt(2): First disjunct. Take v = any rational between u and sqrt(2). Then D(w) for all w in (0,v) since v < sqrt(2). TRUE.
  - If u > sqrt(2): Second disjunct. top(v) for v in (u,2): trivially TRUE. exists v' in (0,u) with neg D(v'): take v' = any rational between sqrt(2) and u (exists by density). neg D(v') since v' > sqrt(2). TRUE.

**LHS = TRUE.**

**RHS**: Gap gamma at sqrt(2) with D-def-left, D-between(0, gamma), (neg bot)^mu(gamma) = True.

**RHS = TRUE.**

**LHS iff RHS: TRUE iff TRUE = TRUE.** The "counterexample" is not a counterexample at all.

### Root Cause of the Error

The `phase-4CW2-counterexample` and `phase-4CW2-mr-fix-disproved` handoffs both assumed U'(A,B) can be characterized as "B cofinal AND NOT U(A,B)". This conflation likely arose because in some simplified settings (e.g., Dedekind-complete orders), U' degenerates to something simpler. But the full FO table is the correct definition, and it gives U'(top, D)(0) = True in the Q example.

## 3. Exact Lean Statement vs Paper

### Current Lean Statement (EFGames.lean:2421-2432)

```lean
theorem left_formula_gap_detection
    (A D : StaviFormula) (hD : stavi_depth D <= r) (m : M.carrier) :
    stavi_temporal_truth_mu M atomMap r (extendPoint m) (left_formula A D) <->
    (exists (gamma : RDefinableGap M atomMap r),
      extendPoint m < Sum.inr gamma /\
      gap_definable_on_left M atomMap gamma.val D /\
      (forall u : M.carrier, m < u -> u in gamma.val.cut ->
        stavi_temporal_truth_mu M atomMap r (extendPoint u) D) /\
      stavi_temporal_truth_mu M atomMap r (Sum.inr gamma) A)
```

### Comparison with GHR93

| Aspect | GHR93 | Lean Code | Match? |
|--------|-------|-----------|--------|
| LHS evaluation | M_r |= left(A,D)^mu(m), which by Remark 2 = M |= left(A,D)(m) | `stavi_temporal_truth_mu ... (extendPoint m) (left_formula A D)`, which by `stavi_truth_mu_at_point` = `stavi_temporal_truth M atomMap m (left_formula A D)` | YES |
| gamma > m | gamma > m in M_r | `extendPoint m < Sum.inr gamma` | YES |
| D-defined on left | "gap defined by D to the left" | `gap_definable_on_left M atomMap gamma.val D` | YES |
| D holds between | "D holds in M on (m, gamma)" | `forall u, m < u -> u in gamma.cut -> D^mu(extendPoint u)` | YES |
| A^mu at gamma | M_r |= A^mu(gamma) | `stavi_temporal_truth_mu ... (Sum.inr gamma) A` | YES |
| D rank bound | "D of rank at most r" | `hD : stavi_depth D <= r` | YES |

**The Lean statement matches GHR93 precisely.** The `hD` hypothesis was correctly added (GHR93 implicitly requires it to produce an r-definable gap). No modifications to the theorem statement are needed.

## 4. Correct Proof Strategy

### Overview

The proof proceeds by structural induction on A. By `stavi_truth_mu_at_point`, the LHS equals standard evaluation in M. Each case of A determines the structure of `left_formula A D` and the proof obligation.

### Core Helper Lemma (U'-Gap Detection)

The majority of temporal cases reduce to proving:

```
U'(X, D)(m) in M  <->  exists gap gamma (D-left-defined), D-between(m, gamma), X^mu(gamma)
```

This should be extracted as a standalone lemma:

```lean
theorem stavi_untl_gap_detection
    (X D : StaviFormula) (hD : stavi_depth D <= r) (m : M.carrier) :
    stavi_temporal_truth M atomMap m (.stavi_untl X D) <->
    (exists (gamma : RDefinableGap M atomMap r),
      m in gamma.val.cut /\
      gap_definable_on_left M atomMap gamma.val D /\
      (forall u, m < u -> u in gamma.val.cut -> stavi_temporal_truth M atomMap u D) /\
      stavi_temporal_truth_mu M atomMap r (Sum.inr gamma) X)
```

**Forward direction** (U' -> gap exists):
1. From U'(X, D)(m) with FO-table witness s, extract the gap structure.
2. The gap gamma is defined as the Dedekind cut: `gamma.cut = {x | D is cofinal above x among points in (m, s)}` or equivalently from the transition point where D goes from "holding" to "failing".
3. Concretely: from condition (3), D holds initially. From condition (2), D fails eventually. The transition defines the gap.
4. Construction: `gamma.cut = {x in M | x < s AND forall u, m < u -> u <= x -> D(u)}` (the largest initial segment of (m,s) where D holds continuously from m).
5. Verify Gap axioms: nonempty (from condition 3), proper (from condition 2), downward_closed (by definition), no_sup (D holds at all cut points, so if there were a sup in cut, D would hold at it, but complement has ¬D arbitrarily close), complement_no_min (from condition 1's second disjunct structure).
6. Verify gap_definable_on_left from D's behavior at the boundary.
7. Extract X^mu(gamma) from condition (1)'s second disjunct applied to points in the complement near gamma.

**Backward direction** (gap -> U'):
1. Given gamma with the gap conditions, construct the FO-table witness s.
2. Choose s = any mu-point above gamma where D fails (exists by `gap_definable_on_left`'s second condition + `complement_no_min`).
3. Verify condition (3): D holds at mu-points initially above m. By D-between, D holds at all u with m < u and u in gamma.cut. The cut is non-empty and contains points above m. Take u = any such point.
4. Verify condition (2): D fails at some mu-point in (m, s). By complement_no_min, there are points in the complement below s. By gap_definable_on_left (neg condition), D fails at some such point.
5. Verify condition (1): For each mu-point u in (m, s):
   - If u in gamma.cut: First disjunct. D holds on (m, v) for some v > u in the cut. Use no_sup to find such v.
   - If u not in gamma.cut: Second disjunct. Need X at mu-points between u and s, plus ¬D at some v' < u. The ¬D witness comes from gap_definable_on_left. X^mu at points above gamma is derived from the FO-table structure of X^mu(gamma).

### Case Analysis for Structural Induction

| Case | left_formula A D | Reduces to | Difficulty |
|------|-----------------|------------|------------|
| `.base (.atom _)` | `.base .bot` | Both sides False | Trivial (done) |
| `.base .bot` | `.base .bot` | Both sides False | Trivial (done) |
| `.base (.box _)` | `.base .bot` | Both sides False | Trivial (done) |
| `.base (.imp phi psi)` | Complex neg/conj expansion | IH + neg/conj cases | Medium |
| `.neg A` | `conj (stavi_untl (base top) D) (neg (left_formula A D))` | U'-gap-detection for X=top, plus IH + gap_detection_unique | Medium |
| `.conj A B` | `conj (left_formula A D) (left_formula B D)` | IH + gap_detection_unique + Subtype.ext | Medium (done per handoff) |
| `.stavi_untl A B` | `stavi_untl (conj B (stavi_untl A B)) D` | U'-gap-detection for X = B AND U'(A,B) | Hard |
| `.stavi_snce A B` | `std_untl compound D` | Standard-Until-gap-detection variant | Hard |
| `.std_untl A B` | `stavi_untl (conj B (std_untl A B)) D` | U'-gap-detection for X = B AND U(A,B) | Hard |
| `.std_snce A B` | `std_untl compound D` | Standard-Until-gap-detection variant | Hard |

### The X^mu(gamma) Backward Direction for Compound X

The hardest part of the backward direction is showing X^mu(gamma) for compound X like `B AND U'(A,B)`.

Given that we're told U'(A,B)^mu(gamma) holds (this is the RHS condition), we need (B AND U'(A,B))^mu(gamma). This requires B^mu(gamma).

**Key insight**: B^mu(gamma) at a gap gamma is NOT about B holding at gamma itself (atoms are False at gaps). It is about the FO-table-relativized evaluation. For B = a StaviFormula, B^mu(gamma) depends on B's structure:
- If B = base(atom a): B^mu(gamma) = interp(a, gamma) = False. So (B AND U'(A,B))^mu(gamma) = False.
- If B = base(bot): B^mu(gamma) = False.
- If B contains temporal operators: B^mu(gamma) may be True (the temporal quantifiers reach mu-points).

But this means for atomic B, the backward direction of `left_formula (.stavi_untl A B) D` when B is atomic would require (base(atom a))^mu(gamma) = True, which is False. So the RHS would require U'(A, atom_a)^mu(gamma) where (atom_a)^mu(gamma) = False. But then U'(A, atom_a)^mu(gamma) requires condition (3): exists mu-point u above gamma with atom_a holding at all mu-points between gamma and u. If atom_a is False at points immediately above gamma, condition (3) may fail.

Wait -- but if U'(A,B)^mu(gamma) holds, then B holds at some mu-points near gamma (by condition 3). The issue is whether B^mu(gamma) (evaluation AT the gap) captures this. It doesn't for atoms.

**However**: this is not a problem for the backward direction of Lemma 9 itself. The backward direction says: given gamma with U'(A,B)^mu(gamma) (this is A_formula = U'(A,B) in Lemma 9), we need left_formula(U'(A,B), D)(m) = U'(B AND U'(A,B), D)(m). We do NOT need (B AND U'(A,B))^mu(gamma). Instead, we need U'(B AND U'(A,B), D)(m), which involves constructing the FO-table witness at m.

The FO table at m quantifies over mu-points between m and s. For points above gamma but in (gamma, s), we need X = B AND U'(A,B) to hold. From U'(A,B)^mu(gamma), condition (3) gives B at mu-points initially above gamma. And U'(A,B) holds at those same points (since the gap is still "ahead" from their perspective -- actually this needs careful argument).

**The correct approach**: Rather than trying to show X^mu(gamma) and then transferring, directly construct the FO-table witnesses for U'(X, D)(m) from the FO-table witnesses for U'(A,B)^mu(gamma) and the gap conditions. This avoids needing X^mu(gamma) entirely.

Specifically, from U'(A,B)^mu(gamma) with FO-table witness s_gamma:
- Condition (3) of U'(A,B) at gamma: B holds at mu-points initially above gamma (up to some u_init).
- Choose s for U'(X, D)(m) to be u_init (or close to it, adjusted for D-failure).
- For mu-points between gamma and u_init: B holds (by condition 3) and U'(A,B) holds at these points (can be shown from the FO-table structure). So X = B AND U'(A,B) holds.
- For mu-points between m and gamma: D holds (by D-between), and the first disjunct of condition (1) applies.

This is the correct approach to the backward direction.

### Standard-Until-Gap-Detection (S/S' Cases)

For the S/S' cases, left_formula produces a `std_untl` (standard Until of StaviFormula arguments). A separate helper is needed:

```lean
theorem std_untl_gap_detection
    (X D : StaviFormula) (hD : stavi_depth D <= r) (m : M.carrier) :
    stavi_temporal_truth M atomMap m (.std_untl X D) <->
    ... -- gap conditions with appropriate modifications
```

The S(A,B) case is more complex because left(S(A,B), D) involves a compound formula `D AND B AND S(A,B) AND U'(top, B AND D) AND neg U'(D, B AND D)` inside a standard Until. The intuition: this formula detects a gap by looking for the point where the "since" pattern transitions, witnessed by the Until pattern.

## 5. Estimated Lines of Code

| Component | Lines | Notes |
|-----------|-------|-------|
| `stavi_untl_gap_detection` (forward) | 120-160 | Gap construction from FO table |
| `stavi_untl_gap_detection` (backward) | 100-140 | FO table construction from gap |
| neg case | 30-40 | Uses U'-gap-detection + IH + gap_detection_unique |
| conj case | 30-40 | Uses IH + gap_detection_unique |
| imp case | 40-60 | Expands to neg/conj pattern |
| stavi_untl case | 40-60 | Direct application of U'-gap-detection |
| std_untl case | 40-60 | Same pattern as stavi_untl |
| stavi_snce case | 80-120 | Standard-Until variant + compound formula |
| std_snce case | 80-120 | Same pattern as stavi_snce |
| right_formula_gap_detection | 60-80 | Symmetric to left, with S'/S instead of U'/U |
| **Total** | **620-880** | |

## 6. Recommended Implementation Plan

### Phase 1: Core Helper (stavi_untl_gap_detection)
- Extract the U'-gap-detection equivalence as a standalone lemma
- This is the linchpin -- all temporal cases reduce to it
- Forward direction: construct gap from FO table
- Backward direction: construct FO table from gap

### Phase 2: Easy Cases
- atom, bot, box: already done (both sides False)
- neg: U'-gap-detection for X=top, plus IH, plus gap_detection_unique
- conj: IH + gap_detection_unique + Subtype.ext

### Phase 3: Temporal Cases  
- stavi_untl, std_untl: direct application of U'-gap-detection
- stavi_snce, std_snce: standard-Until variant (may need its own helper)
- imp: reduces to neg + conj pattern

### Phase 4: Dual (right_formula)
- Symmetric proof with S'/S in place of U'/U
- May share infrastructure via a `Direction` parameter or manual duplication

## 7. Summary of Key Findings

1. **The theorem statement is CORRECT as-is.** No modifications needed. The "counterexample" from prior sessions was based on an incorrect simplification of the U' FO table.

2. **The U' FO table is the full Stavi FO table**, not "cofinal AND NOT U". The handoffs confused U'(A,B) with a simpler characterization, leading to false counterexample claims.

3. **The proof strategy is structural induction on A**, with a core helper lemma (`stavi_untl_gap_detection`) that connects the FO table of U'(X, D) at a point to gap existence. Most temporal cases reduce directly to this helper.

4. **The backward direction's main challenge** is constructing FO-table witnesses for U'(X, D)(m) from the gap conditions and the hypothesized A^mu(gamma). The key technique is: use the FO-table witnesses from A^mu(gamma) (when A itself is a temporal formula) to provide X-witnesses at points above gamma, while the D-between condition provides D-witnesses at points below gamma.

5. **Estimated effort**: 620-880 lines of new Lean code, primarily in the core helper lemma and the S/S' cases.

6. **The `stavi_truth_mu_at_point` bridge is correct and sufficient.** At actual points, mu-relativized truth equals standard truth in M, which matches GHR93's Remark 2. No alternative evaluation regime is needed.
