# Definitive Analysis: GHR93 Claim 1 vs Our Formalization

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-23
**Purpose**: Decision document -- resolve the Claim 1 formalization strategy

---

## 1. What GHR93 Actually Says

### C is a SINGLE FORMULA, not a predicate

GHR93 Definition 8.8 (p.112):

> "Define X_t to be the conjunction of all temporal L-formulas X of rank <= r
> with M_r |= X^mu(t). This conjunction is effectively finite... Hence X_t
> can be taken to be a temporal formula of rank r."

> "If t < u in M_r, define X_{(t,u)} to be the disjunction over non-gap points
> v in (t,u) of X_v. Again the disjunction is effectively finite, so that
> X_{(t,u)} can be taken to be a formula of rank r."

Then on p.115:

> "Define the following rank r temporal formulas: A = X_{(a_{n-1}, a_n)},
> C = X_{(a_n, y')}."

**C is a single temporal formula of rank r.** It is a finite disjunction of
finite conjunctions. GHR93 does NOT use a predicate -- C is materialized as a
formula object.

### The Claim 1 proof is genuinely simple

The proof on p.116 is five lines:

1. C' = not-C or K^-(not-C) has rank r+1. (K^- adds one nesting level.)
2. M_r |= C'(c) holds by the infimum definition of c.
3. Since r' > r >= r+1, formula transfer gives N_r |= C'(d).
4. Analyzing C'(d): either not-C(d) or K^-(not-C)(d), either way d <= d-bar.
5. If d < d-bar, Spoiler picks d' in (d-bar, y') with N |= not-C(d'). Duplicator has no response because C holds above c in M. Contradiction.

There is NO pigeonhole. There is NO carrier-point vs gap case split. There are
NO edge cases. The argument works uniformly because C is a single formula.

### Rank arithmetic

GHR93 Definition 8.2: "rank = maximum depth of nesting of temporal connectives."
Example: rank(not-U(p, not-S'(not-q, q))) = 2. Each U/S/U'/S' adds +1.

Our `stavi_depth`: `std_snce A B = max(depth A, depth B) + 2`. Each temporal
connective adds +2, not +1.

So K^-(not-C) = neg(std_snce(T, not-C)):
- GHR93 rank: max(0, r) + 1 = r + 1
- Our stavi_depth: max(0, r) + 2 = r + 2

This is why h_fwd_r1 uses rank r+2 in our code. The mismatch is harmless --
the game budget r+4(n+1) exceeds r+2 -- but it explains the +2 everywhere.

---

## 2. Where We Deviated and Why It Hurts

### The core deviation: cont_holds is a predicate, not a formula

Our `cont_holds` (line 129):

```lean
private def cont_holds ... (t : ExtendedCarrier N atomMap r) : Prop :=
  forall A : StaviFormula, stavi_depth A <= r ->
    (forall v, a_n < v -> v < y' -> mu_holds v ->
      stavi_temporal_truth_mu N atomMap r v A) ->
    stavi_temporal_truth_mu N atomMap r t A
```

This says "t satisfies every rank-r formula that holds throughout the mu-points
of (a_n, y')." It is a **second-order predicate** -- it quantifies over all
formulas. It is NOT a single formula.

### Why the predicate encoding forces the pigeonhole

Because cont_holds is a predicate (not a formula), we cannot directly construct
C' = not-C or K^-(not-C) as a StaviFormula. The predicate-level negation
"not(cont_holds t)" means "there EXISTS a formula A that fails at t," which is
existential over formulas. To use the game transfer mechanism (which works on
individual formulas), we need to extract a SINGLE witnessing formula.

This extraction is exactly the pigeonhole argument: among the finitely many
normal forms at depth 2*r, some single formula D must fail cofinally below the
infimum. The pigeonhole adds ~180 lines and creates preconditions (h_cut_start,
h_cofinal_failure) that introduce the carrier-point vs gap edge cases.

### The cascade of edge cases

1. **Pigeonhole preconditions**: Need a carrier point in the cut with x <= p.
   Fails when c_inf is a carrier point with cont_holds_cross = TRUE.

2. **Direction 2 gap case**: When r2_resp is a gap strictly below rank_embed(d),
   the carrier-point contradiction approach doesn't apply. Need K^- pipeline.

3. **Cross-structure transfer**: cont_holds_cross uses N-side interval but M-side
   truth, requiring a separate pigeonhole (pigeonhole_definable_formula_cross).

4. **Four sub-cases in d-consistency**: d point/gap x r2_resp point/gap.

None of these exist in GHR93 because GHR93 has C as a single formula.

---

## 3. The Right Encoding

### Option (b): Materialize C as a single StaviFormula

The correct fix is to define C as GHR93 does: a finite disjunction/conjunction.

**Definition 8.8 gives us the recipe**:
- X_t = conjunction of all rank-r formulas true at t (finite, by normal forms)
- X_{(a_n, y')} = disjunction of X_v for non-gap v in (a_n, y')

We already have the infrastructure:
- `NormalForm` at depth 2*r determines truth at depth r
  (via `nf_determines_stavi_truth_depth`)
- Finitely many normal forms (Fintype instance)
- `StaviFormula` supports conjunction, disjunction, negation

**What to build** (~100-150 lines total):

1. `interval_type_formula (a_n y' : ExtendedCarrier N atomMap r) : StaviFormula`
   -- the disjunction of point-type formulas for mu-points in (a_n, y').
   Depth: r.

2. `interval_type_formula_correct`: semantics match -- for any mu-point t,
   `stavi_temporal_truth_mu N atomMap r t (interval_type_formula a_n y')` iff
   t has the same rank-r type as some mu-point in (a_n, y').

3. `cprime_formula := StaviFormula.neg C ||| K_neg_formula C` where
   `K_neg_formula C = StaviFormula.neg (StaviFormula.std_snce T C)`.
   Depth: r + 2 (in our encoding).

4. `cprime_holds_at_c_inf`: M_r |= C'(c_inf). Two cases by infimum property --
   same structure as existing cont_holds_above_gap / cont_fails_below_gap, but
   now targeting a single formula.

5. Transfer via game and analysis of C'(d): three lines.

6. Contradiction if d < d-bar: Spoiler picks witness, C holds above c in M,
   done.

### Semantic subtlety: cont_holds vs C

Our `cont_holds a_n y' t` means: "t satisfies every rank-r formula that holds
at ALL mu-points of (a_n, y')." This is the conjunction of universally-true
formulas on the interval.

GHR93's C = X_{(a_n, y')} = disjunction of X_v for mu-points v in (a_n, y').
C(t) means: "t has the same rank-r type as SOME mu-point in (a_n, y')."

These differ when the interval contains points of different types. However,
for Claim 1 the key property is: c = inf{t : M |= C(u) for all u in (t,y)}.
With either definition, the continuation set is upward-closed and has a
well-defined infimum, and the K^-(not-C) argument works the same way.

The materialized formula approach should use GHR93's definition (disjunction
of point types) for faithfulness. But even our conjunctive encoding would work
for Claim 1 IF we could materialize it as a formula -- the issue is purely
that cont_holds is a Prop-level predicate, not a StaviFormula.

### Why this eliminates ALL the edge cases

- No pigeonhole: C is already a single formula.
- No carrier-point vs gap distinction in Claim 1: C' is a formula, transfer
  works uniformly at rank r+2.
- No cross-structure pigeonhole: C is defined in N, transferred to M via game.
- No four sub-cases: the proof has exactly two directions (d <= d-bar and
  d-bar <= d), each ~20 lines.

### What about the existing pigeonhole infrastructure?

The existing `pigeonhole_definable_formula` and `pigeonhole_definable_formula_cross`
(~360 lines combined) were built to compensate for cont_holds being a predicate.
With C materialized as a formula, these become unnecessary for Claim 1.

They may still be useful for `infimum_gap_r_definable` (showing the gap is
r-definable), which is a separate concern from Claim 1. But even there, the
formula C itself serves as the defining formula: the gap at c is definable on
the right by C (GHR93 p.116: "c is a gap definable on the right by C").

---

## 4. Do Carrier-Point/Gap Edge Cases Arise in GHR93?

**No.** GHR93 handles carrier points vs gaps in exactly two places:

1. **Defining c**: "If c is not in M then either c = x (in M_r already) or c is a
   gap definable on the right by C. Hence c in M_r." (p.116) This is a one-line
   observation, not a case split in the proof.

2. **Cases I-IV**: The case split on alpha_n being a point/left-gap/right-gap
   (p.117-119). This is about alpha_n (Spoiler's choice), not about c or d.

Claim 1 itself has NO carrier/gap case analysis. The formula C' works at both
points and gaps via the mu-relativized semantics (Definition 8.4, p.110).

The carrier-point/gap edge cases in our code are **artifacts of the predicate
encoding**. They arise because:
- Pigeonhole needs carrier points in the cut (not gaps)
- The infimum might be a carrier point (no gap to define)
- Cross-structure transfer needs carrier-level witnesses

All of these disappear with formula materialization.

---

## 5. Decision: Recommended Proof Structure

### Phase 1: Build interval_type_formula (~100 lines)

Define C = X_{(a_n, y')} as a StaviFormula. Prove its semantics correct.
This is the foundation that makes everything else simple.

### Phase 2: Prove Claim 1 with formula C (~80 lines)

Follow GHR93 verbatim:
1. Define C' = not-C or K^-(not-C). Prove depth <= r+2.
2. Prove C'(c_inf) in M. (Two sub-cases by infimum property, ~30 lines each.)
3. Transfer via game at rank r+2. (~5 lines.)
4. Analyze C'(d) to get d <= d-bar. (~10 lines.)
5. Contradiction argument for d-bar <= d. (~15 lines.)

### Phase 3: Simplify obtain_split_point_props (~net reduction)

Replace the sorry'd interior cases in d_consistency_left/right with the new
Claim 1 proof. Remove or bypass the pigeonhole-based approach for Claim 1
(keep it only for infimum_gap_r_definable if needed).

### Estimated total: ~180 new lines, ~300 lines of sorry eliminated

The key insight: **build the formula first, then the proof writes itself.**

---

## 6. What About Rabinovich (2017)?

Rabinovich's "A Proof of Stavi's Theorem" (arXiv 1711.03876) takes an entirely
different approach: constructive translation via partition formulas, no games at
all. It does not have a Claim 1 equivalent and is not useful for our
formalization.

The Hodkinson-Reynolds "Separation" survey discusses expressive completeness
but defers the gap case to GHR93/GHR94. No alternative Claim 1 proof.

**GHR93 is the right source. We just need to follow it faithfully.**
