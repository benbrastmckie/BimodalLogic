# Literature Alignment: Tracing GHR93's Formula C and the Formalization's Divergence

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-23
**Focus**: Line-by-line trace of GHR93 Section 8 formula C; identification of where and why the Lean formalization diverges

---

## 1. GHR93's Formula C: Precise Definition

### 1.1 Definition 8.8, part 1 (GHR93 p.112 / GHR94 Definition 12.8.13)

> "Let r < omega and t in M_r be given. Define X_t to be the **conjunction** of all temporal L-formulas X of rank <= r with M_r |= X^mu(t). This conjunction is **effectively finite**, as because L is finite there are up to logical equivalence only finitely many distinct formulas of any rank. Hence X_t can be taken to be a temporal formula of rank r."

**X_t is a single temporal formula.** It is a conjunction of rank-r formulas. It is finite because L (the atom set) is finite, which makes the set of inequivalent rank-r formulas finite. X_t has rank exactly r.

**Semantics**: X_t(u) holds iff u satisfies every rank-r formula that t satisfies. In other words, u has the same rank-r type as t (or a stronger type if X_t is not a complete type; but since X_t includes every true rank-r formula and their negations are the false ones, X_t IS the complete rank-r type of t).

### 1.2 Definition 8.8, part 2 (GHR93 p.112 / GHR94 Definition 12.8.13)

> "If t < u in M_r, define X_{(t,u)} to be the **disjunction** over non-gap points v in (t,u) of X_v. Again the disjunction is effectively finite, so that X_{(t,u)} can be taken to be a formula of rank r. Note that only points (non-gaps) contribute to the disjunction."

**X_{(t,u)} is a single temporal formula.** It is a finite disjunction of point-type formulas X_v for mu-points v in the open interval (t,u). Rank: r. Note that only carrier points (non-gaps) contribute disjuncts. This is the "interval type formula."

**Semantics**: X_{(t,u)}(w) holds iff w has the same rank-r type as some mu-point v in (t,u).

### 1.3 How C is defined in the Theorem 6 proof (GHR93 p.115, GHR94 p.748-750)

In the proof of (*)_{n+1}, after Spoiler chooses a_0 < ... < a_n:

> "Define the following rank r temporal formulas:
>   A = X_{(a_{n-1}, a_n)},  C = X_{(a_n, y')}"

**C = X_{(a_n, y')} is the interval type formula for (a_n, y') in N_r.** It is a single rank-r StaviFormula (temporal formula built from U, S, U', S'). It is a finite disjunction of finitely many point-type conjunctions.

### 1.4 Key properties of C

1. **C is a single formula**, not a predicate or schema.
2. **rank(C) = r** (in GHR93's convention; `stavi_depth(C) = r` in our convention, or equivalently `stavi_depth(C) <= r`).
3. **C holds at mu-points of (a_n, y')**: for any mu-point v with a_n < v < y', C(v) is true (v's type X_v is one of the disjuncts of C).
4. **C may or may not hold at gaps or at the endpoints** a_n, y'.
5. **C is defined entirely within N_r** -- it is a formula about the structure N. But being a formula, it can be evaluated in any structure, including M.

---

## 2. How C is Used in Claim 1: Line-by-Line Trace

### The setup (GHR93 p.115-116, GHR94 p.748-756)

The infimum c is defined in M:

> "c = inf{t in [x, y] : M |= C(u) for all u in (t, y)}."

Because C is a concrete formula, C(u) is a well-defined truth value at every point u. The set S_C = {t in [x,y] : C holds at all (carrier) points in (t,y)} is upward-closed (if C holds on (t,y), it holds on (t',y) for t' > t). The infimum c exists in M_r: either c is a point of M, or c is a gap definable on the right by C (C holds above c but not on every tail below c). In the gap case, c is r-definable, so c in M_r.

Similarly, c' = inf{...} in N_r.

### Claim 1 (GHR93 p.116, GHR94 p.762-766)

> **Claim 1.** Consider a play of G_{m,r'}(M, xy; N, x'y') for arbitrary r' >= r, m >= 1 in which Duplicator uses a winning strategy. Let Spoiler begin by choosing c plus m-1 other points, and let Duplicator's response to c be d (plus m-1 other points). Then d = c'.

**Proof of Claim 1** (GHR93 p.116, verbatim):

> "As the strategy is winning, any rank r' temporal formula satisfied by one of Spoiler's choices must also be satisfied by the corresponding choice of Duplicator."

This is the game's winning condition: formulas of rank <= r' are preserved between paired elements.

> "Now the rank r+1 formula C' = ~C or K^-(~C) satisfies M_r |= C'(c)."

Here C' = neg(C) \/ K^-(neg(C)). Since K^- X = neg(S(top, neg(X))), C' has rank r+1 in GHR93 convention. (In Lean's stavi_depth convention, this is r+2.)

**Why does C'(c) hold in M_r?** The infimum c has two sub-cases:
- If ~C(c) holds: the first disjunct is true.
- If C(c) holds: then c = inf(S_C), so ~C is cofinal below c (there exist points arbitrarily close below c where ~C holds). K^-(~C) = "~C holds cofinally in the past" is true at c. The second disjunct is true.

(At a gap: ~C is automatically cofinal below the gap because C fails somewhere below the gap -- that is what makes the gap the infimum. At a carrier point: c = inf(S_C) with C(c) true means c itself is the minimum of S_C, and ~C must be cofinal below c by the infimum property.)

> "Hence also N_r |= C'(d), so d <= c'."

Since r' >= r >= r+1 (GHR93 rank) and the game preserves formulas of rank <= r', C' is preserved. N_r |= C'(d). Analyzing: either ~C(d) or K^-(~C)(d). Either way, d is at or below the infimum c' (either C fails at d, so d is not in S_C, hence d <= c'; or ~C is cofinal below d, which means d cannot be above c' where C holds on a tail).

> "If d < c' then Spoiler can choose d' in (d, y') with N |= ~C(d'). Duplicator now has no winning response, a contradiction."

If d < c', there exists d' between d and y' where C fails in N (since d < c' and c' = inf(S_C^N)). Spoiler plays d' in Round 2 of the game. Since C(d') fails in N, Duplicator must respond with some e in M where C(e) also fails (by formula agreement). But e must be in (c, y) (by order preservation, since d' > d corresponds to e > c). All mu-points in (c, y) satisfy C (by definition of c). Contradiction.

> "Hence d = c'. This proves the claim."

**Total proof: 5 lines.** No pigeonhole. No carrier-point vs gap case split. No edge cases. The entire argument rests on C being a concrete formula.

---

## 3. The Induction Structure: Is There Circularity?

### 3.1 What the induction provides

Theorem 6 / 12.8.15 proves (*)_n by induction on n:

> (*)_n: For all r, if Duplicator wins G_{1+3n, r+4n}(M, xy; N, x'y'), then she wins G_{n,r}(N, x'y'; M, xy).

At step n+1, the induction hypothesis gives (*)_n. The proof assumes a winning strategy for G_{4+3n, r+4(n+1)}(M, xy; N, x'y').

### 3.2 When is C constructed, and does it require expressive completeness?

C = X_{(a_n, y')} is constructed at the BEGINNING of the inductive step (GHR93 p.115, after Spoiler makes his choices). It is a rank-r formula built from Definition 8.8.

**Does C's construction require expressive completeness?** NO. C is defined purely semantically from the structure N_r:

1. Enumerate all temporal L-formulas of rank <= r (finitely many up to equivalence, because L is finite).
2. For each mu-point v in (a_n, y'), take the conjunction X_v of those that hold at v.
3. Take the disjunction over all such v (finitely many types, so finitely many distinct X_v).

This construction uses ONLY:
- Finiteness of L
- Finiteness of the set of inequivalent rank-r formulas (follows from L being finite)
- Boolean operations on formulas (conjunction, disjunction)
- Evaluation of formulas at points

**It does NOT use**:
- The induction hypothesis (*)_n
- The expressive completeness theorem being proved
- Any inversion of the temporal-to-monadic translation
- Any result about normal forms or Hintikka formulas

### 3.3 Verdict: NO circularity in GHR93

The construction of C is entirely independent of the theorem being proved. C is a syntactic object built from the finite set of rank-r formulas and their truth values in N_r. The finiteness of rank-r formulas is a basic combinatorial fact that does not depend on expressive completeness.

The induction hypothesis (*)_n is used LATER in the proof -- for Claim 2 (deriving backward games on sub-intervals from forward games) and for the case analysis. It is NOT used to construct C.

---

## 4. Where the Lean Formalization Diverges

### 4.1 The core divergence: cont_holds is a predicate, not a formula

The Lean code (ExpressivenessGeneral.lean, line 112-120) defines:

```lean
private def cont_holds ... (t : ExtendedCarrier N atomMap r) : Prop :=
  forall A : StaviFormula, stavi_depth A <= r ->
    (forall v : ExtendedCarrier N atomMap r,
      a_n < v -> v < y' -> mu_holds v ->
      stavi_temporal_truth_mu N atomMap r v A) ->
    stavi_temporal_truth_mu N atomMap r t A
```

This is a second-order predicate: it quantifies over ALL StaviFormulas of depth <= r. It captures the same semantic content as "t satisfies C" -- but it is not a single formula. It is a Prop-level universal quantification over the syntax.

### 4.2 Why this deviation was made

The natural Lean encoding of "t has a type that matches some mu-point in the interval" requires constructing the finite set of rank-r formulas as a Lean object. The developer apparently chose to bypass this construction by using a universal quantification instead: instead of "t satisfies the specific formula C," say "t satisfies ALL formulas that hold on the interval." This is logically equivalent for mu-points in the interval but avoids materializing C.

### 4.3 The cascade of consequences

Because cont_holds is a predicate rather than a formula:

1. **Cannot construct C'**: The formula C' = ~C \/ K^-(~C) requires C to be a StaviFormula. A Prop-level predicate cannot be negated within the formula syntax. The negation "not(cont_holds t)" is "there EXISTS a formula A that fails at t" -- an existential over formulas, not a formula itself.

2. **Pigeonhole workaround**: To extract a single witnessing formula from the existential, the formalization uses a pigeonhole argument: among finitely many NormalForm types, at least one formula must witness the failure cofinally below the infimum. This adds ~360 lines and introduces strict-inequality preconditions.

3. **Edge cases proliferate**: The pigeonhole requires carrier points (mu-points) with strict ordering relative to the infimum. When the infimum IS a carrier point, or when the cofinal witnesses land ON the infimum, the strict inequality fails. This produces the sorry sites at lines 2835, 2859, 3759, 3793.

4. **Cross-structure complications**: The GHR93 proof evaluates C in M (a formula defined from N's interval). With a predicate, the cross-structure version (cont_holds_cross) requires its own pigeonhole (pigeonhole_definable_formula_cross), adding another ~160 lines and more edge cases.

### 4.4 The circularity claim: is it real?

Reports 38 and 39 identify a "circularity" in materializing C as a StaviFormula:

> "Building NormalForm -> StaviFormula requires inverting stavi_table_mu, which IS the expressive completeness theorem being proved."

**This circularity claim is PARTIALLY CORRECT but MISLEADING.** Let me be precise:

**What IS circular**: Converting a MonadicFormula of depth 2*r back to a StaviFormula of depth r. This conversion is literally the expressive completeness theorem.

**What is NOT circular**: Constructing C = X_{(a_n, y')} as a StaviFormula. C does not require inverting stavi_table_mu. C is built DIRECTLY as a conjunction/disjunction of rank-r StaviFormulas:

1. **Enumerate StaviFormulas of depth <= r**: This is a finite set because the signature is finite and each formula has bounded depth. StaviFormula is an inductive type; one can enumerate all terms up to depth r. This does NOT require expressive completeness.

2. **Evaluate each at mu-points of (a_n, y')**: For each StaviFormula A with stavi_depth(A) <= r, check whether stavi_temporal_truth_mu N atomMap r v A holds for all mu-points v in (a_n, y'). (This is decidable in principle given the structure, though in Lean it may require Decidable instances or classical reasoning.)

3. **Take the conjunction**: C = conjunction of all such A. This is a StaviFormula of depth <= r (conjunction preserves depth in our encoding since `conj A B = neg(disj(neg A, neg B))` has the same depth as max(A,B)).

**The key insight**: GHR93 does NOT need to "invert stavi_table_mu." It constructs C directly in the temporal language. The NormalForm detour (going through MonadicFormula and back) is unnecessary and is what introduces the circularity.

However, there is a practical obstacle: Step 1 requires enumerating all StaviFormulas of depth <= r, which needs a `Fintype (StaviFormula_up_to_depth r)` instance or equivalent. This is non-trivial Lean infrastructure (~200-300 lines) but is NOT circular.

---

## 5. Comparison with GHR94 (Textbook Version)

GHR94 Chapter 12, Section 12.8, Theorem 12.8.15 is the textbook version of the same proof. The presentation is cleaner but structurally identical.

### Definition 12.8.13 (= Definition 8.8 in GHR93)

The textbook defines X_t and X_{(t,u)} identically. C = X_{(a_n, y')} is the same rank-r formula.

### Claim 1 (GHR94 p.762-766)

Identical to GHR93. The formula C' = ~C \/ K^-(~C), the infimum argument, and the Round 2 contradiction are all the same.

### Cases II-IV (GHR94 p.790-847)

The textbook presents Cases II-IV more clearly. In Case II (a_n is a non-gap point), the proof defines B = X_{a_n} (the point type of a_n) and uses U(B, A) to locate a matching point e_n in M. This is formula-level: B and A are both rank-r StaviFormulas, and U(B, A) has rank r+1. The key step:

> "N_r |= U(B, A)^#(a_{n-1}); a_n is a witness to this."

Then by formula transfer (the backward game strategy tau preserves formulas up to rank r+4):

> "M_r |= U(B, A)^#(e_{n-1})."

This gives a point z > e_{n-1} in M with B(z) true and A holding on (e_{n-1}, z). The response e_n = z satisfies B, so e_n has the same rank-r type as a_n.

**The continuation formula C is used for the "tail" response**: If Spoiler plays t > e_n in Round 2, then t > c, so M |= C(t). By definition of C there exists t' > a_n with X_t(t') true. Duplicator plays t'.

**No predicate-level argument appears anywhere.** Every step operates on concrete formulas.

---

## 6. The Fix: Materialize C as a StaviFormula

### 6.1 What needs to be built

The fix requires constructing C = X_{(a_n, y')} as a `StaviFormula` in Lean. There are two approaches:

**Approach A: Direct StaviFormula enumeration** (~200-300 lines)

1. Define `StaviFormula_bounded (L : Finset atom) (r : Nat)` -- the finite set of StaviFormulas over atoms L with depth <= r.
2. Prove this set is finite (by structural induction on the depth bound).
3. For each formula A in this set, classically decide whether A holds at all mu-points of (a_n, y').
4. Take the conjunction of all such A. This is C.
5. Prove: cont_holds a_n y' t <-> stavi_temporal_truth_mu N atomMap r t C.

Advantage: follows GHR93 exactly. No circularity.
Disadvantage: requires `Fintype` instance for bounded-depth StaviFormulas.

**Approach B: NormalForm-mediated construction** (~150-200 lines)

1. Use existing `Fintype (NormalForm (muSig sig) (2*r) 1)`.
2. For each NF, build a characteristic MonadicFormula of depth <= 2*r (nf_char_formula, ~80 lines).
3. Check which NFs are realized at mu-points of (a_n, y').
4. C_FO = disjunction of characteristic formulas for realized NFs. This is a MonadicFormula of depth <= 2*r.
5. **This C_FO cannot be converted to a StaviFormula without circularity.**

So Approach B hits the circularity wall. It produces a MonadicFormula, not a StaviFormula.

**Approach C: Case-split workaround** (~240 lines, from Reports 38-39)

Instead of materializing C, case-split on whether cont_holds (resp. cont_holds_cross) holds at the infimum itself:

- Case A: cont_holds FAILS at c_inf. Then neg(cont_holds) gives a specific formula A directly. No pigeonhole needed. Build K^-(~A) and proceed.
- Case B: cont_holds HOLDS at c_inf. Then all cofinal witnesses below c_inf satisfy u < c_inf strictly (if u = c_inf, cont_holds would hold, contradiction). The existing pigeonhole works with strict bounds.

Advantage: minimal code change, no new Fintype infrastructure.
Disadvantage: does not fully align with GHR93; keeps pigeonhole machinery.

### 6.2 Assessment of the circularity

The circularity is REAL but NARROW:

- **Circular**: Converting `MonadicFormula (muSig sig) 1` of depth 2*r to `StaviFormula` of depth r. This is exactly expressive completeness.
- **Not circular**: Enumerating StaviFormulas of depth <= r and taking their conjunction. This is a combinatorial fact about the inductive type `StaviFormula`.

Approach A avoids the circularity entirely by staying within the StaviFormula type. Approach B hits the circularity because it detours through MonadicFormula. Approach C avoids both by not materializing C at all.

### 6.3 Recommendation

**Approach A (direct StaviFormula enumeration) is the mathematically correct fix.** It follows GHR93 exactly. The circularity is an artifact of the Approach B detour, not of the mathematical structure.

However, Approach A requires ~200-300 lines of new infrastructure (Fintype for bounded-depth StaviFormulas). If this infrastructure is useful elsewhere (and it likely is -- bounded-depth finiteness is a standard fact), it is worth building.

**Approach C (case-split) is the pragmatic fix.** It closes all sorry sites with ~240 lines and minimal risk. It does not require new Fintype infrastructure. It is mathematically valid (the case split is implicit in GHR93).

If time is limited, implement Approach C first, then build Approach A infrastructure in a follow-up task.

---

## 7. Summary

### Is the circularity real or an artifact?

**The circularity is an artifact of the formalization's encoding choice.** GHR93 constructs C as a rank-r temporal formula using only the finiteness of rank-r formulas -- a basic combinatorial fact. The formalization replaces C with a predicate (universal quantification over all formulas), which prevents constructing C' = ~C \/ K^-(~C) as a formula. The pigeonhole workaround attempts to extract a single formula from the predicate but introduces edge cases that GHR93 never encounters.

The specific circularity identified in Reports 38-39 ("inverting stavi_table_mu") is real but irrelevant: it arises only in Approach B (NormalForm -> MonadicFormula -> StaviFormula). GHR93's construction (Approach A) never makes this detour.

### The precise formula C

C = X_{(a_n, y')} = finite disjunction of X_v for mu-points v in (a_n, y'), where X_v = conjunction of all rank-r StaviFormulas true at v. Rank: r. Type: StaviFormula.

### How it is constructed from the induction

C is constructed at the BEGINNING of the inductive step, BEFORE any appeal to the induction hypothesis. The IH is used for Claim 2 and the case analysis, not for C. There is no circularity in the induction.

### What changes to the Lean code are needed

1. **Minimal fix (Approach C)**: Case-split on cont_holds at the infimum. ~240 lines. Closes 5 sorry sites. No new infrastructure. Does not eliminate the predicate encoding.

2. **Full fix (Approach A)**: Build `Fintype (BoundedStaviFormula r)`. Construct C = X_{(a_n, y')} as a StaviFormula. Replace cont_holds-based Claim 1 with GHR93's 5-line formula argument. ~300 lines of new infrastructure + ~100 lines of Claim 1 proof. Eliminates ~360 lines of pigeonhole code. Net: cleaner, shorter, and faithful to GHR93.
