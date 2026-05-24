# M_r Architecture Analysis: ExtendedCarrier vs GHR93 M_r

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-24
**Focus**: Does the Lean formalization's ExtendedCarrier correctly implement GHR93's M_r?
         Where does the M_r vs M distinction cause the remaining sorries?

---

## 1. The Formalization's ExtendedCarrier IS M_r

### GHR93 Definition 8.3 (p.109)

> M_r = M union {r-definable gaps of M}, with the induced ordering.

An r-definable gap is a Dedekind cut definable on the left or right by a formula of rank at most r.

### Lean Implementation (EFGames.lean lines 341-358)

```lean
abbrev RDefinableGap (M : OrderedMonadicStructure sig) (atomMap : ...) (r : Nat) :=
  { g : Gap M.carrier // r_definable_gap M atomMap g r }

def ExtendedCarrier (M : OrderedMonadicStructure sig)
    (atomMap : ...) (r : Nat) : Type :=
  M.carrier ⊕ RDefinableGap M atomMap r
```

The `Gap` structure (lines 257-269) is a Dedekind cut: a downward-closed proper subset of the carrier with no supremum in the cut and no minimum in the complement. `r_definable_gap` requires definability by a `StaviFormula` of depth at most r (lines 334-339).

**Verdict**: `ExtendedCarrier M atomMap r` is precisely M_r. The sum type `M.carrier ⊕ RDefinableGap M atomMap r` is exactly M union {r-definable gaps of M}. The linear order on ExtendedCarrier (lines 363-447) interleaves points and gaps correctly: a point x is below a gap gamma iff x is in gamma's cut.

### IsPoint and IsGap (lines 451-469)

```lean
def IsPoint (e : ExtendedCarrier M atomMap r) : Prop := ∃ x : M.carrier, e = Sum.inl x
def IsGap (e : ExtendedCarrier M atomMap r) : Prop := ∃ g : RDefinableGap M atomMap r, e = Sum.inr g
```

The formalization correctly distinguishes points (elements of M) from gaps (Dedekind cuts). Every element is one or the other (`isPoint_or_isGap`). This matches GHR93 exactly.

---

## 2. The mu-Relativization IS Correct

### GHR93 Definition 8.4 (p.110)

The mu-relativized connectives restrict quantification to actual points (mu-points = elements of M within M_r). Since and Until quantify only over mu-points.

### Lean Implementation (EFGames.lean lines 793-864)

```lean
def mu_holds (e : ExtendedCarrier M atomMap r) : Prop := IsPoint e

-- Since mu-relativized:
| .std_snce A B =>
    ∃ s : ExtendedCarrier M atomMap r, s < t ∧ mu_holds s ∧
      stavi_temporal_truth_mu M atomMap r s A ∧
      ∀ u : ExtendedCarrier M atomMap r, s < u → u < t → mu_holds u →
        stavi_temporal_truth_mu M atomMap r u B
```

The witness s must be a mu-point (carrier point), and the universal guard ranges only over mu-points in the open interval (s, t). This exactly matches GHR93's mu-relativization.

**Verdict**: The mu-relativized semantics are correctly implemented. `mu_holds` = `IsPoint` = "element of M in M_r". The open-interval strict semantics match GHR93's definitions.

---

## 3. c_inf Lives in M_r (ExtendedCarrier), Not M

### How c_inf is constructed (ExpressivenessGeneral.lean lines 2404-2633)

```lean
obtain ⟨c_inf, hc_inf_interval, hc_inf_glb, hc_inf_is_inf⟩ :
    ∃ c_inf : ExtendedCarrier M atomMap r, ...
```

c_inf is an element of `ExtendedCarrier M atomMap r` -- that is, M_r. The 3-way case split (lines 2410-2633) constructs c_inf as:

1. **Case 1**: A carrier-point minimum of S_C_M. Here c_inf = `extendPoint p` (a point of M).
2. **Case 2**: A carrier-point GLB that is NOT in S_C_M. Here c_inf = `extendPoint p` (a point of M not in the continuation set).
3. **Case 3**: No carrier-point GLB exists. Here c_inf is constructed as a gap: `Sum.inr ⟨gamma_M, h_rdef⟩` (an r-definable gap of M).

**Verdict**: c_inf is correctly computed in M_r, not in M. It can be either a point of M or an r-definable gap. This matches GHR93 exactly.

---

## 4. cont_holds_cross Operates Cross-Structure (M-side truth, N-side interval)

### Definition (ExpressivenessGeneral.lean lines 127-135)

```lean
private def cont_holds_cross (a_n_N y'_N : ExtendedCarrier N atomMap r)
    (t_M : ExtendedCarrier M atomMap r) : Prop :=
  ∀ A : StaviFormula, stavi_depth A ≤ r →
    (∀ v : ExtendedCarrier N atomMap r,
      a_n_N < v → v < y'_N → mu_holds v →
      stavi_temporal_truth_mu N atomMap r v A) →
    stavi_temporal_truth_mu M atomMap r t_M A
```

This says: t_M in M_r satisfies every rank-r formula that holds at all mu-points of the interval (a_n_N, y'_N) in N_r. The hypothesis checks truth in N, the conclusion checks truth in M. This is a Prop-level encoding of the interval type X_{(a_n, y')} from GHR93 Definition 8.8.

**Key distinction from GHR93**: GHR93 defines C = X_{(a_n, y')} as a CONCRETE temporal formula (a finite conjunction of rank-r formulas). The Lean code uses a UNIVERSALLY QUANTIFIED predicate instead. This is the root cause of the formula materialization blocker.

---

## 5. Where Exactly the Architecture Diverges from GHR93

### The core difference: Predicate vs Formula

GHR93 Claim 1 uses:
```
C_1 = ¬C ∨ K⁻(¬C)
```
where C is a SINGLE temporal formula of rank r. Then:
- C_1 has rank r + 1
- M_r |= C_1(c) is provable because c = inf(S_C) and either ¬C(c) or K⁻(¬C)(c)
- Formula agreement transfers C_1 from c to d

The Lean formalization cannot construct C_1 because `cont_holds_cross` is a predicate over ALL formulas of depth ≤ r, not a single formula. The pigeonhole argument (pigeonhole_definable_formula_cross_strict) extracts a SINGLE formula D_M of depth ≤ r from the infinitely many formulas, but this introduces complications:
- D_M may differ from the "canonical" C of GHR93
- The K⁻(¬D_M) argument requires strict cofinal failure of D_M below c_inf
- When c_inf is a carrier point in a discrete order, strict cofinal failure may not hold

### The 9 sorry sites and their M_r relationship

| # | Line | Category | M_r issue? | Root cause |
|---|------|----------|------------|------------|
| 1 | 2835 | h_d_unique (d < t') | No | Formula materialization: need K⁻(¬D) to separate d from t' |
| 2 | 2859 | h_d_unique (t' < d) | No | Same: need K⁻(¬D) to separate d from t' |
| 3 | 3759 | neg_h_cont_c boundary | Partially | c_inf = y boundary case. A_fail fails at r2_resp = rank_embed(y'), but A_fail holds on OPEN interval (a_n, y'), excluding y' itself |
| 4 | 3793 | neg_h_cont_c gap r2_resp | Yes | When r2_resp is a gap in M_r at rank r+2, need to evaluate A_fail at a gap. The predicate encoding does not support this |
| 5 | 5651 | same_order_type | No | Blocked on h_d_unique. Order pivoting needs d uniqueness |
| 6 | 5751 | same_order_type | No | Same blocker |
| 7 | 5804 | same_order_type | No | Same blocker |
| 8 | 6734 | cases_III_IV | No | Gap case construction. Lemma 9 is proved; needs assembly |
| 9 | 6989 | rank_varying | No | Rank transport infrastructure. No M_r issue |

### Analysis by category

**Category A: Formula materialization (sorries 1-2, 3-4)**

The predicate-vs-formula distinction is the fundamental blocker. GHR93's C is a finite conjunction, making C_1 = ¬C ∨ K⁻(¬C) a formula of rank r+1. The Lean code's `cont_holds_cross` is an infinite universal quantification, which cannot be materialized as a single formula without:
1. Enumerating all formulas of rank ≤ r (requires a finiteness result)
2. Taking their conjunction (requires the conjunction to be a StaviFormula)
3. Proving equivalence between the predicate and the formula

Report 39 identifies this as "circular at this proof stage" because the enumeration requires `stavi_expressive_completeness`, which is what we are trying to prove.

**Category B: Order/boundary (sorries 3, 5-7)**

Sorry 3 (line 3759) is a boundary edge case where c_inf = y and r2_resp = rank_embed(y'). The A_fail formula fails at y' (the boundary), but cont_holds guarantees A_fail on the OPEN interval (a_n, y'), which excludes y'. This is a genuine gap between the open-interval predicate and the boundary behavior. It is NOT about M_r vs M -- it is about open vs closed intervals.

Sorries 5-7 are blocked on h_d_unique (sorries 1-2).

**Category C: Independent (sorries 8-9)**

Sorry 8 (cases_III_IV) is about constructing Duplicator's response when a_n is a gap. This requires Lemma 9 infrastructure (which is sorry-free) but needs assembly code. Not related to M_r.

Sorry 9 (rank_varying) is about transporting strategies across ranks. Needs infrastructure but no M_r issue.

---

## 6. The K⁻ Argument in the Formalization vs GHR93

### GHR93 Claim 1 (p.116)

GHR93's argument is succinct:

1. C is a concrete formula of rank r.
2. C_1 = ¬C ∨ K⁻(¬C) has rank r+1.
3. M_r |= C_1(c) because c = inf{t : C holds on (t, y)}, so either ¬C(c) or ¬C is cofinal below c (making K⁻(¬C) true).
4. By formula agreement (rank r+1 ≤ r'), N_r |= C_1(d).
5. So d ≤ d_bar. The reverse follows by a Round 2 argument.

Key insight: GHR93's step 3 works because c is in M_r (either a point or an r-definable gap). At a gap, K⁻(¬C) is automatically true because ¬C is cofinal below the gap (that is what makes it a gap defined on the right by C). At a point where C holds, ¬C is cofinal below it (from the infimum property). At a point where ¬C holds, ¬C(c) is true and the first disjunct suffices.

### The formalization's implementation (lines 3253-3793)

The formalization implements a case split:

**(A) x = c_inf**: Direct order argument (sorry-free).

**(B) x < c_inf, cont_holds_cross holds at c_inf**: Full K⁻ argument:
1. h_strict_failure: strict cofinal failure below c_inf (sorry-free, using contradiction when v = c_inf).
2. Pigeonhole extraction: gets D_M of depth ≤ r (sorry-free).
3. h_since_false_c: Since(T, D_M) FALSE at c_inf (sorry-free).
4. K⁻(¬D_M) transfer via rank_embed + formula agreement (sorry-free).
5. Since(T, D_M) TRUE at r2_resp: carrier-point d case (sorry-free), gap d case (sorry-free).

**This entire case (A) is sorry-free.** The K⁻ argument works correctly when cont_holds_cross holds at c_inf.

**(C) x < c_inf, cont_holds_cross FAILS at c_inf**: Direct formula argument:
1. Extract A_fail from ¬cont_holds_cross.
2. Transfer A_fail failure from c_inf to r2_resp.
3. Show A_fail holds at r2_resp: carrier-point case (sorry-free when r2_resp < rank_embed(y')), but TWO edge cases remain:
   - Sorry at line 3759: r2_resp = rank_embed(y'). Forces c_inf = y, boundary issue.
   - Sorry at line 3793: r2_resp is a gap. Formula evaluation at gaps requires materialization.

---

## 7. Does the Formalization Need to Operate on a Different Structure?

**No.** The formalization's `ExtendedCarrier` is exactly M_r. The architecture is correct. The remaining issues are:

1. **Formula materialization**: The predicate `cont_holds_cross` needs to be convertible to a single formula C for the GHR93 argument. This is the "circularity" blocker identified in report 39.

2. **Boundary cases**: The open-interval semantics create edge cases at boundaries (y' is excluded from the interval hypothesis).

3. **Gap formula evaluation**: When r2_resp is a gap, showing a rank-r formula holds/fails requires understanding mu-relativized evaluation at gaps.

None of these are about M_r vs M. The formalization correctly operates on M_r throughout.

---

## 8. Can the Remaining Sorries Be Closed?

### Sorries 1-2 (h_d_unique, lines 2835, 2859): BLOCKED

These require constructing K⁻(¬D) from a pigeonhole formula D and proving its semantics at d vs t'. The formula wiring is substantial but theoretically sound. The blocker is the same formula materialization issue: the pigeonhole D extracts ONE formula, but h_d_unique needs the argument to work for ALL possible game responses t' with the same rank-r type as d.

**Assessment**: Could be closed with 200-400 lines of additional proof per direction. The mathematical argument is valid (GHR93 Claim 1). The implementation gap is connecting the pigeonhole formula to the Since/K⁻ semantics at t' (which has a specific position relative to d and the continuation set).

### Sorry 3 (boundary, line 3759): LIKELY CLOSABLE

When c_inf = y and r2_resp = rank_embed(y'), the argument needs to show that this configuration leads to contradiction. Key facts:
- c_inf = y means S_C_M = {y}, so cont_holds_cross fails everywhere in (x, y).
- But we are in the neg_h_cont_c case, so cont_holds_cross fails at c_inf = y.
- r2_resp = rank_embed(y') and rank_embed(d) < r2_resp = rank_embed(y'), so d < y'.
- The order agreement at (1,3): rank_embed(c_inf) < rank_embed(y) iff r2_resp < rank_embed(y'). Since r2_resp = rank_embed(y'), the RHS is false, so c_inf >= y. Since c_inf <= y, we get c_inf = y.

The contradiction should come from the game's order consistency: if c_inf = y and cont_holds_cross fails at y, then the entire interval (x, y) has failures, meaning d should equal y' (symmetric argument). But d < y' (from rank_embed(d) < r2_resp = rank_embed(y')). This should contradict the parallel construction of d.

**Assessment**: Needs careful boundary case analysis. Likely 50-100 lines.

### Sorry 4 (gap r2_resp, line 3793): STRUCTURALLY BLOCKED

When r2_resp is a gap at rank r+2, showing A_fail holds at r2_resp requires evaluating a StaviFormula at a gap position. At gaps, the mu-relativized semantics skip the gap itself (quantifiers range only over mu-points). Whether A_fail holds at a gap depends on the specific formula structure.

The blocker: A_fail was extracted from neg_cont_holds_cross, which says "exists A of depth <= r such that A holds on all mu of (a_n, y') in N but fails at c_inf in M." To show A_fail holds at gap r2_resp in N, we would need to evaluate A_fail at a gap. Since mu_holds is false at gaps, atomic formulas are false at gaps, and temporal connectives quantify only over mu-points. The truth value at a gap depends entirely on the formula structure.

**Assessment**: This is a deep edge case. The GHR93 proof avoids it because C is a CONCRETE formula and the game's winning condition at gaps explicitly checks A^mu(gamma) for all rank-r formulas A. In the Lean code, the gap case requires knowing the specific formula structure. Likely needs 100+ lines and possibly new lemmas about StaviFormula evaluation at gaps.

### Sorries 5-7 (same_order_type, lines 5651, 5751, 5804): BLOCKED on 1-2

These are downstream of h_d_unique. Once sorries 1-2 are closed, these become tractable (the ordering proofs need d-consistency, which needs h_d_unique).

### Sorry 8 (cases_III_IV, line 6734): INDEPENDENT, CLOSABLE

Lemma 9 infrastructure is sorry-free. The gap case construction needs:
1. Detect whether a_n is left-defined or right-defined.
2. Use Lemma 9 to find a matching gap in M.
3. Construct the response tuple.
4. Verify the winning condition.

**Assessment**: 200-400 lines of assembly code. Mathematically straightforward.

### Sorry 9 (rank_varying, line 6989): INDEPENDENT, CLOSABLE

Needs rank_embed game transport infrastructure. The argument is: use the uniform-rank theorem at rank r+4n, then project back to rank r.

**Assessment**: 100-200 lines of infrastructure.

---

## 9. Recommendations

### Short-term (within current task)

1. **Sorry 3 (boundary)**: Attempt to close by showing the c_inf = y configuration forces d = y', contradicting d < y'. This requires carefully applying the game's order agreement at multiple indices.

2. **Sorries 8-9 (independent)**: These are self-contained and do not require formula materialization. They can be implemented with existing infrastructure.

### Medium-term (follow-up tasks)

3. **Sorries 1-2 (h_d_unique)**: These require the full K⁻(¬D) wiring for the d-uniqueness argument. The mathematical argument is valid but the implementation is substantial. This is the main blocker for the complete GHR93 pipeline.

4. **Sorry 4 (gap r2_resp)**: This edge case may require a dedicated lemma about StaviFormula evaluation at gaps in the neg_cont_holds_cross scenario.

### Long-term (architectural)

5. **Formula materialization**: The fundamental tension between the predicate encoding (cont_holds_cross) and GHR93's formula encoding (C = X_{(a_n,y')}) affects multiple sorry sites. Resolving this requires either:
   - (a) Proving that the set of rank-r StaviFormulas is finite up to logical equivalence (which it is, since L is finite), then materializing C as their conjunction.
   - (b) Restructuring the proof to avoid materializing C, using the predicate encoding throughout.

   Option (a) is the correct approach per GHR93 but requires substantial infrastructure (finitely many rank-r formulas). Option (b) is what the current code attempts but hits the edge cases identified above.

---

## 10. Summary

1. **ExtendedCarrier IS M_r**: The formalization correctly implements GHR93's M_r as `M.carrier ⊕ RDefinableGap M atomMap r`. No mismatch.

2. **c_inf lives in M_r**: Correctly constructed as either a carrier point or an r-definable gap. No mismatch.

3. **cont_holds_cross operates on M_r**: Quantifies over `ExtendedCarrier`, checks formulas at mu-points. No mismatch with the structure.

4. **The K⁻ argument is sorry-free in the main case**: When cont_holds_cross holds at c_inf (case A), the full pigeonhole + K⁻ + Since + transfer argument is complete.

5. **The remaining sorries are NOT about M_r vs M**: They are about:
   - Formula materialization (predicate vs concrete formula C)
   - Boundary cases (open interval excluding y')
   - Gap evaluation (formula truth at gap positions)
   - Assembly of existing infrastructure (cases III/IV, rank_varying)

6. **No structural change to ExtendedCarrier or the game architecture is needed**: The fixes are localized to specific sorry sites within the existing framework.
