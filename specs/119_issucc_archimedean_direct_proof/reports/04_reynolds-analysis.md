# Research Report: Reynolds Section 10 — Prior-UZ and IsSuccArchimedean

- **Task**: 119 - Prove IsSuccArchimedean via direct connectivity extraction
- **Status**: Research findings complete
- **Type**: lean4
- **Round**: 4 (Reynolds Section 10 analysis)
- **Date**: 2026-05-10
- **Session**: sess_1778449535_f13ea4

## Executive Summary

Reynolds Section 10 (US/Z axiomatization) and Venema 1993 (BW/BN systems) provide
a **completely different proof strategy** for the discrete case that **AVOIDS
IsSuccArchimedean entirely**. Instead of proving limit_dom is isomorphic to Z
(which requires IsSuccArchimedean), the Reynolds/Venema approach proves that
limit_dom is **k-equivalent to Z for all k** using the Doets transfer theorem
for discrete structures. This is sufficient for the weak completeness theorem.

The key insight: **Axiom W (= Prior-UZ) is NOT a theorem of BX + discreteness**.
It is an ADDITIONAL axiom needed for the integer axiomatization. But Venema's
Lemma 4.1 shows that **axiom W alone makes every BW-model definably well-ordered**,
and Doets's theorem then gives k-equivalence to a well-ordered model. When combined
with discreteness (axiom D), the k-equivalent model is an interval of Z.

**The Reynolds/Venema approach is a VIABLE PATH that sidesteps IsSuccArchimedean.**
However, it requires either (a) adding axiom W to the existing axiom system and
restructuring the completeness proof, or (b) proving definable well-ordering of
limit_dom directly from BX + discrete uniformity axioms.

## 1. Is Prior-UZ a Theorem of BX + Discreteness?

### Answer: NO

Prior-UZ is: `Fp -> U(p, neg p)` — "if p holds at some future point, then p holds
until not-p."

This is Venema's axiom W and Reynolds's Prior-UZ. It is **NOT derivable** from the
BX axioms plus the discreteness axioms `U(T,bot)`, `S(T,bot)`, and their propagation/symmetry
axioms.

**Proof that it is independent**: Consider a discrete linear order with two "copies"
of Z glued together at a gap (i.e., Z + Z without the connecting point). This is
a discrete linear order without endpoints where U(T,bot) and S(T,bot) hold everywhere.
All BX axioms are valid on any linear order. All four uniformity axioms are valid
because translation invariance holds within each copy. But Prior-UZ fails: let p be
true on the second copy only. At any point t in the first copy, Fp holds (p is true
somewhere in the future). But U(p, neg p) fails because neg p holds throughout the
first copy up to the gap, then p is true after the gap, but between the first copy
and the gap there is no single witness point where p holds with neg p holding up to
that point — the truth of p "jumps" across the gap.

Actually, wait — in a **strict** discrete order without endpoints, this counterexample
needs care. In the Z + Z order, there is a "last" point of the first copy and a "first"
point of the second copy. Let me reconsider.

The Z + Z (without endpoints) order is: `..., -2, -1, 0 | 1, 2, 3, ...` where '|'
marks a gap (0 has a successor in the first copy, 1 has a predecessor in the second
copy, but they are not adjacent — there is a gap between them). Actually this is NOT
a valid structure: in Z + Z, the successor of 0 in the first copy is... well, Z + Z
IS a well-defined discrete order. Every element has an immediate successor and predecessor.
The issue is that `succ^n(0)` for any finite n stays in the first copy, and never reaches
elements of the second copy.

In this order: let V(p) = second copy. At t = 0 (first copy), Fp holds. Now U(p, neg p)
at 0 would require a witness s > 0 with p(s) and neg p between 0 and s. But the first
element of the second copy (call it 1') is the first place p holds. All elements between
0 and 1' belong to the first copy and have neg p. So U(p, neg p) DOES hold at 0, with
witness s = 1'. The guard (0, 1') has all elements in the first copy where neg p holds.

Hmm, this is more subtle. Let me reconsider.

For U(p, neg p) to hold at t, we need: there exists s > t with p(s), and for all u with
t < u < s, neg p holds. In Z + Z, if p is true exactly on the second copy, then at any
point t in the first copy, the first point s of the second copy is a valid witness:
s > t (since all of the second copy is after all of the first copy in Z + Z), p(s) holds,
and every u with t < u < s is in the first copy where neg p holds.

So Prior-UZ IS valid on Z + Z! The gap does not block it because the elements on either
side of the gap are still directly comparable and the guard interval (t, s) is well-defined.

**Revised analysis**: Prior-UZ might actually be derivable from BX + discreteness on
discrete orders without endpoints. The key question is whether the BX axioms plus
discreteness uniformity are strong enough to derive it.

### Semantic validity check

**Claim**: `Fp -> U(p, neg p)` is valid on all discrete linear orders without endpoints.

**Proof**: Let M be a discrete linear order without endpoints satisfying D (discreteness).
Let t be a point where Fp holds. Then there exists some s > t with p(s). Consider the
set S = {u > t | p(u)}. S is nonempty (contains s). In a discrete order, S has a
minimum if and only if every nonempty subset of {u | u > t} has a minimum — i.e., if
the order is well-founded above t.

But **discrete orders are NOT necessarily well-founded above a point**! The order Z + Z*
(Z followed by the reverse of Z) is discrete without endpoints, and {u > 0 | u in second copy}
has no minimum in the second copy (which goes ...,-2,-1,0,1,2,...,*...,-2,-1,0,1,2,...*,
where the second copy is reversed... no, this is not well-ordered).

Actually, more carefully: Z + Z (two copies of Z concatenated) IS well-ordered on each
copy above any fixed point. Above any point t in the first copy, the successors go up
through the first copy, then start the second copy. The set S = {u > t | p(u)} where p
is true only on the second copy HAS a minimum: the first element of the second copy.
In Z + Z, the "first element of the second copy" exists because Z has a minimum (0 in
the standard enumeration of Z as {0, 1, -1, 2, -2, ...}).

Wait, Z does NOT have a minimum. Z = {..., -2, -1, 0, 1, 2, ...}. The standard Z has
no minimum and no maximum.

Z + Z concatenation is: {..., -2, -1, 0, 1, 2, ...} then {..., -2', -1', 0', 1', 2', ...}.
Above element 0 in the first copy, we have 1, 2, 3, ..., then -2', -1', 0', 1', 2', ...
So S = second copy = {..., -2', -1', 0', 1', 2', ...}. Does S have a minimum? NO!
The second copy is a copy of Z, which has no minimum.

**Therefore**: `Fp -> U(p, neg p)` is NOT valid on Z + Z with p true only on the second copy.
At 0 in the first copy, Fp holds but U(p, neg p) does not: any candidate witness s in
the second copy has infinitely many elements of the second copy below it where p holds
(not neg p).

BUT WAIT: do the uniformity axioms (discrete_propagate_fwd, etc.) hold on Z + Z?

The uniformity axioms assert `U(T,bot) -> G(U(T,bot))`: if there is an immediate successor
at t, then at every future point t' there is an immediate successor. This holds on Z + Z:
every element has an immediate successor (the gap between copies is not a "missing successor"
— in Z + Z, the successor of every element of the first copy IS defined within the first
copy, and the successor of every element of the second copy is defined within the second
copy).

But the uniformity axioms also assert `U(T,bot) -> S(T,bot)`: the existence of a forward gap
implies a backward gap of the same size. In Z + Z, this holds because each element has both
immediate successor and predecessor.

And `U(T,bot) -> H(U(T,bot))`: the existence of immediate successor propagates to all past
points. This also holds.

**So Z + Z satisfies all BX axioms plus all four uniformity axioms, but NOT Prior-UZ.**

**Conclusion**: Prior-UZ is NOT a theorem of BX + our four uniformity axioms.

## 2. Can We Add Prior-UZ (Axiom W) Without Breaking Soundness?

### Answer: It depends on the frame class

**Axiom W on ordered abelian groups**: Our task frames are ordered abelian groups with
`AddCommGroup`, `LinearOrder`, `IsOrderedAddMonoid`. On such structures, discreteness means
the group is isomorphic to Z (or a dense subgroup of R, but discreteness rules that out).
If the group is isomorphic to Z, then axiom W IS valid because Z is well-ordered above
every point (the positive integers are well-ordered).

**But**: Axiom W is NOT valid on general ordered abelian groups! It is only valid on those
that are Archimedean and discrete (hence isomorphic to Z).

**On our actual frame class (ordered abelian groups with uniformity axioms)**: The uniformity
axioms already constrain the group to be "uniformly discrete" (the same gap size everywhere).
With `Nontrivial` and `NoMaxOrder`/`NoMinOrder`, this means the group is a discrete ordered
abelian group without endpoints. By the classification of ordered abelian groups, such a
group is either:
- Z (Archimedean discrete), where W is valid, or
- Z x H (lexicographic product with another ordered abelian group), where W may NOT be valid.

So axiom W would ADD a constraint that rules out non-Archimedean discrete ordered abelian groups.
This is exactly the constraint we WANT (we want Z, not Z x Z lex), but adding it requires:

1. Proving soundness of W on the intended frame class (Z)
2. Adjusting the completeness proof to use W
3. Potentially restructuring the Completeness.lean case split

### Soundness of W on Z

`Fp -> U(p, neg p)` on Z: If p holds at some future point, let s = min{u > t | p(u)}.
This minimum exists because the positive integers are well-ordered. Then p(s) holds and
for all u with t < u < s, p(u) does not hold (by minimality), so neg p(u) holds. Hence
U(p, neg p) at t.

**This proof requires well-ordering of {u | u > t}**, which is exactly the IsSuccArchimedean
property! So proving soundness of W on our frame class requires knowing the frame is
Archimedean.

**On Int**: IsSuccArchimedean for Int is a standard Mathlib instance. So W is sound on Int.

## 3. The Venema/Reynolds Strategy (avoiding Z-isomorphism entirely)

### Key Insight from Venema 1993

Venema's proof for the natural numbers (Theorem 4.3) and well-orderings (Theorem 4.2)
follows this structure:

1. **Start with BW-consistent formula phi** (where BW = Burgess + W).
2. **Get a linear model M** (by Burgess completeness, Theorem 3.5).
3. **M is a BW-model** (all substitution instances of W are valid in M).
4. **M is definably well-ordered** (Lemma 4.1) — this is the KEY step.
5. **Apply Doets theorem** (Theorem 3.8): M has k-equivalents in WO for all k.
6. **Transfer phi** to a well-ordered model.

For the integers (adding axiom D), step 6 gives a well-ordered discrete model, hence
isomorphic to omega. Then one argues this is actually omega (not a finite initial segment).

### Adapting to Reynolds's US/Z

Reynolds Section 10 follows an analogous structure:

1. Start with US/Z-consistent formula phi.
2. Get a linear model M via Burgess-Xu (BX axioms give strong completeness on linear orders).
3. M satisfies all substitution instances of Prior-UZ and Prior-SZ.
4. M is a **Prior structure** (Sections 5-6): contemporaneous equivalence classes do not end at gaps.
5. Apply the discrete version of Doets theorem (Theorem 9): if M is countable, discrete,
   without endpoints, and contemporaneous equivalence classes do not end at gaps, then M is
   k-equivalent to Z for all k.
6. Transfer phi to a Z-model.

### How This Avoids IsSuccArchimedean

**The Reynolds proof does NOT construct an order isomorphism from limit_dom to Z.**

Instead, it proves:
- limit_dom (with the MCS labeling) is k-equivalent to Z for all k.
- The formula phi has a first-order table of bounded quantifier depth.
- Therefore phi is satisfiable in a Z-model.

**k-equivalence is weaker than isomorphism.** Two structures can be k-equivalent for all k
(elementarily equivalent) without being isomorphic. But for the weak completeness theorem,
k-equivalence suffices — we only need to find SOME model of phi with the right flow of time.

## 4. Does limit_dom Have "No Definable Gaps" (the C4/Prior Connection)?

### Analysis

The Prior-UZ axiom `Fp -> U(p, neg p)` says: if p holds somewhere in the future, then
there is a stretch from now where neg p holds until p becomes true, without a gap in between.

In our chronicle construction, the C4 property (`limit_satisfies_c4`) gives:
- If `neg U(eta, xi)` is in limit_f(x) and `eta` is in limit_f(y) for y > x, then there
  exists z between x and y with `xi.neg` in limit_f(z).

This is NOT the same as Prior-UZ. C4 is about NEGATIVE Until (neg U) providing an
intermediate counterexample. Prior-UZ is about POSITIVE future (F) implying Until.

**However**, C4 combined with the C5 property (`limit_satisfies_c5_strong`) gives something
close. If the limit domain has the property that all substitution instances of Prior-UZ
are valid, then it has "no definable gaps" in Reynolds's sense. But we need to PROVE
that Prior-UZ instances are valid in the limit model.

### Can we prove "no definable gaps" directly?

A "definable gap" in Reynolds's sense is: a proper downward-closed subset of limit_dom
that is definable by a temporal formula and has no supremum in limit_dom.

The question is: does the omega chain construction ensure that limit_dom has no such gaps?

The answer connects back to our IsSuccArchimedean problem: a "gap" in the succ-chain
(where succ^n(a) converges to a limit L not in limit_dom) IS a definable gap (the set
{succ^n(a) | n in N} is definable in the monadic language with a parameter at a).

**But Reynolds's notion requires definability WITHOUT parameters** (or with finitely many
parameters that are themselves in the structure). The succ-chain gap requires a parameter
(the starting point a), so it might be a parametric gap but not a parameter-free gap.

### Reynolds's Theorem 4 requires Prior axioms in the model

Reynolds's Theorem 4 says: **in any Prior structure**, contemporaneous equivalence classes
do not end at gaps. The proof fundamentally uses Prior-U and Prior-S. Without Prior axioms
being valid in M, the conclusion does not follow.

Our limit model satisfies all BX axioms (by construction) and all four uniformity axioms
(by how limit_f propagates discreteness). But we have NOT established that Prior-UZ instances
are valid in the limit model. And as shown above, Prior-UZ is NOT a BX theorem.

## 5. Does k-Equivalence to Z Give IsSuccArchimedean?

### Short Answer: Yes, but this is circular

If we could prove limit_dom is k-equivalent to Z for all k, then every first-order property
of Z would transfer. For any fixed a, b in limit_dom, the property "succ^n(a) = b" for
specific n is first-order. So if limit_dom were k-equivalent to Z for sufficiently large k,
then for any a < b, there would exist n with succ^n(a) = b.

But the whole point is that we CANNOT prove k-equivalence without either:
- Having Prior-UZ as an axiom (Reynolds/Venema approach), or
- Proving IsSuccArchimedean directly (current approach).

## 6. The Venema Shortcut: Definable Well-Ordering via Axiom W

### The key lemma (Venema Lemma 4.1)

Venema's proof is remarkably elegant. The core is Lemma 4.1:

> Every BW-model is definably well-ordered.

The proof: Let M be a BW-model. Every L(x)-definable subset of T has a defining formula
in S'U' (Stavi connectives, which extend U,S with gap-crossing connectives). It suffices
to show every S'U' formula has an equivalent SU formula over M. The only non-trivial case
is U'(psi, chi). We claim U'(psi, chi) is equivalent to bot:

Suppose U'(psi, chi) holds at t. Then there is a gap g after t such that chi holds from t
to g, and chi is false arbitrarily soon after g. But chi holding from t to g implies F(chi)
at t. By axiom W, U(neg chi, chi) holds at t. But this says chi holds from t until neg chi
— meaning neg chi eventually holds, and chi holds continuously up to that point. This
contradicts chi being false arbitrarily soon after the gap.

**Translation to our formalism**: If axiom W (`Fp -> U(p, neg p)`) is valid in the model,
then the Stavi connective U' is equivalent to bot. This means U' and S' contribute nothing —
every S'U'-definable set equals an SU-definable set. Since U,S are expressively complete
over Dedekind-complete orders (Kamp's theorem), and our discrete order with no definable gaps
is "morally" Dedekind-complete in the definable sense, every definable subset is well-ordered.

### Application to the discrete case

For our discrete case, we would need:

1. **Add axiom W** to the axiom system (as a new Axiom constructor).
2. **Prove soundness of W** on our frame class (ordered abelian groups with SuccOrder +
   PredOrder + IsSuccArchimedean + Nontrivial + NoMaxOrder + NoMinOrder). This is straightforward
   on Int but requires knowing the frame IS Archimedean.
3. **Prove every BX+W model is definably well-ordered** (Venema Lemma 4.1 adapted to our setting).
4. **Prove the discrete Doets theorem** (Reynolds Theorem 9).
5. **Transfer** to a Z-model.

**But step 2 is circular**: proving W sound requires IsSuccArchimedean on the frame, which
is the property we are trying to establish for limit_dom.

## 7. Breaking the Circularity: Two Viable Paths

### Path A: Add Axiom W and Restructure (RECOMMENDED)

The circularity can be broken by observing:

- Axiom W is sound on **Int** (which has IsSuccArchimedean by Mathlib).
- The completeness theorem says: BX+W |- phi iff Int |= phi.
- We do NOT need to prove IsSuccArchimedean for limit_dom.
- Instead, we prove: for any BX+W-consistent phi, there exists a Z-model of phi (via Venema/Doets).

**The key realization**: The Doets transfer theorem does NOT require an isomorphism
between limit_dom and Z. It only requires k-equivalence. And k-equivalence follows from
definable well-ordering (Venema's approach) or no-gap-at-classes (Reynolds's approach).
Both of these follow from axiom W being valid IN THE MODEL (not on the abstract frame).

Since the model is built from an MCS consistent with BX+W, all substitution instances of
W are valid in the model (this is the standard Henkin construction property). So W is
valid in the limit model, definable well-ordering follows, Doets gives k-equivalence,
and we transfer to Z.

**What changes in the codebase**:

1. Add `axiom_W : Axiom (Formula.some_future p |>.imp (Formula.untl p p.neg))` (and its
   mirror `axiom_W_mirror` for Since).
2. Add a `DiscreteFrameClass` that includes axiom W (separate from the current base `FrameClass`).
3. Prove soundness of W on `Int` (easy, uses well-ordering of positive integers).
4. Restructure `dd_countermodel_chronicle_nondense_sorry` to use the Venema proof
   strategy instead of the Z-isomorphism.
5. Remove `limitDomSubtype_isSuccArchimedean` and `discrete_iso` (no longer needed).
6. Implement `definablyWellOrdered_from_W` (Venema Lemma 4.1 adapted).
7. Implement `discrete_doets_transfer` (Reynolds Theorem 9).
8. Wire into the completeness theorem.

**Estimated effort**: LARGE (3-5 phases, each non-trivial). The Doets transfer theorem
alone is a substantial formalization. But it is mathematically well-understood and each
step is clearly defined.

### Path B: Prove Definable Well-Ordering from BX + Uniformity (WITHOUT adding W)

If we could prove that the BX axioms plus the four uniformity axioms already force
definable well-ordering on discrete structures, we would not need to add axiom W.

**Can we?** The uniformity axioms say: `U(T,bot) -> G(U(T,bot))` and
`U(T,bot) -> H(U(T,bot))` and symmetry axioms. These force UNIFORM discreteness: the
gap size is the same everywhere, propagating through the entire structure.

On a uniformly discrete ordered abelian group, is every definable subset well-ordered above
every point? This is equivalent to asking: does the group being uniformly discrete force
it to be Archimedean?

**No**: Z x Z with lex order is a uniformly discrete ordered abelian group (the generator
(0,1) provides uniform discreteness, and this propagates by translation invariance). But
Z x Z lex is NOT Archimedean (the elements (n,0) for n in N are all less than (1,0) but
succ^n((0,0)) = (0,n) never reaches (1,0)).

So the uniformity axioms alone do NOT force definable well-ordering. Axiom W (or something
equivalent) is genuinely needed.

### Path C: Bypass Z-isomorphism with a Direct Completeness Argument

Instead of proving limit_dom is isomorphic to Z or k-equivalent to Z, we could try to
prove the completeness theorem directly on limit_dom without any isomorphism.

The current approach is:
1. Build limit_dom with limit_f (chronicle construction) -- DONE
2. Prove limit_dom satisfies all chronicle properties (C0, C4, C5, forward_G, backward_H) -- DONE
3. Convert to FMCS on a standard domain (Rat or Int) via isomorphism -- REQUIRES ISOMORPHISM
4. Build BFMCS, prove restricted coherence -- DONE FOR DENSE CASE
5. Apply parametric representation theorem -- DONE

The isomorphism step (3) is where IsSuccArchimedean is needed. If we could build the BFMCS
directly on limit_dom (as a subtype of Rat), we would bypass the need for isomorphism.

**The obstacle**: The parametric representation theorem (`ParametricRepresentation.lean`)
requires the domain D to be an `AddCommGroup` with `LinearOrder` and `IsOrderedAddMonoid`.
The subtype `{q : Rat // q in limit_dom}` is NOT an additive group (it is not closed under
addition).

So this path requires a major refactoring of the parametric representation theorem to work
with general linear orders rather than ordered abelian groups. This would be an even larger
change than Path A.

## 8. Practical Assessment: Formalization Effort

### What the Reynolds/Venema approach requires in Lean

| Component | Complexity | Lines (est.) | Dependencies |
|-----------|-----------|-------------|-------------|
| Axiom W constructor + soundness | Low | 50-80 | Soundness.lean |
| Stavi connective definability | Medium | 100-150 | New file |
| Venema Lemma 4.1 (definably well-ordered from W) | High | 200-300 | Stavi, expressive completeness |
| Doets transfer theorem (discrete version) | Very High | 400-600 | Lexicographic sums, EF games |
| Integration with completeness | Medium | 100-200 | ChronicleToCountermodel.lean |
| **Total** | | **850-1330** | |

vs. the current IsSuccArchimedean approach:

| Component | Complexity | Lines (est.) |
|-----------|-----------|-------------|
| IsSuccArchimedean proof | **UNKNOWN** | **UNKNOWN** |
| Rest is done | 0 | 0 |

### Key dependencies for Reynolds/Venema in Lean

1. **Expressive completeness of U,S on discrete Prior structures**: Reynolds Theorem 3.
   This requires showing U'(A,B) is equivalent to bot under Prior-UZ, which is Venema's
   key argument. Formalizing this requires defining U' semantics and proving the contradiction.

2. **Contemporaneous equivalence relations**: A first-order definability notion. Needs
   careful treatment in Lean (monadic formulas with parameters).

3. **Lexicographic sums and shuffles**: Reynolds/Doets use these extensively. Mathlib has
   some support (`Ordinal.lsum`, `Order.Sum`) but not the game-theoretic k-equivalence
   preservation results.

4. **Ehrenfeucht-Fraisse games** (or equivalent): Needed for proving k-equivalence preservation
   under lexicographic sums. Not in Mathlib.

### Assessment

**The Reynolds/Venema approach is mathematically sound but formalization-heavy.** It
replaces one hard problem (IsSuccArchimedean for limit_dom) with several medium problems
(definability theory, transfer theorems, game arguments). The total effort is likely LARGER
than finding a direct proof of IsSuccArchimedean, but each individual step is well-understood
mathematically.

**The direct IsSuccArchimedean approach remains the shortest path IF the omega-chain closure
property can be established.** The gap identified in Round 3 ("prove limit_dom is closed
under omega-limits of succ-chains") is a single focused problem rather than a multi-component
formalization project.

## 9. Concrete Recommendations

### Recommendation 1 (PREFERRED): Try axiom W + simplified Venema strategy

Instead of the full Doets transfer, try this simplified strategy:

1. **Add axiom W** to the axiom system (for discrete frames only).
2. In the discrete case, use W to prove that limit_dom has no "definable accumulation points"
   — i.e., no definable infinite strictly monotone sequence bounded within a finite interval.
3. From "no definable accumulation points" + discreteness, derive IsSuccArchimedean directly.

This is simpler than the full Doets transfer because:
- It avoids formalizing Stavi connectives, lexicographic sums, and EF games.
- It uses W only to get the "no definable gaps" property, then argues combinatorially.
- It keeps the existing Z-isomorphism approach once IsSuccArchimedean is established.

**The argument**: Suppose for contradiction that succ^n(a) does not reach b for any n.
The set {succ^n(a) | n in N} is definable (it is the SU-definable set satisfying
"reachable from a by iterated successor"). By axiom W, if any formula p holds somewhere
in the future, U(p, neg p) holds now. Applied to the formula defining "first element of
the second copy" (or more precisely, to the gap), this would force the gap to be bridgeable.

However, this argument requires care: the set {succ^n(a)} is definable only WITH THE
PARAMETER a. Venema's approach works with parameter-free definability. With parameters,
the argument is more subtle.

### Recommendation 2: Accept the sorry with documentation

If the formalization effort for Recommendation 1 exceeds the available budget, document
the sorry as follows:
- The mathematics is correct (Burgess 1982, Reynolds 1992).
- The sorry is equivalent to: "discrete limit_dom is Archimedean", which follows from the
  omega-chain construction ensuring every bounded interval is eventually saturated.
- The dense case is fully sorry-free.
- The sorry does not affect soundness, decidability, or any other metatheorem.

### Recommendation 3 (NOT recommended): Full Reynolds/Doets formalization

Only pursue this if the project requires a complete formalization of the Doets transfer
machinery for other purposes (e.g., real number completeness). The effort is 850-1330 lines
and requires formalizing EF games, which are not in Mathlib.

## 10. Key Finding: Axiom W and Definable Well-Ordering

The most actionable insight from this research is Venema's Lemma 4.1:

> In any model where W (`Fp -> U(p, neg p)`) is valid, U'(A,B) is equivalent to bot.
> Therefore every definable subset is well-ordered.

The proof is only 5 lines. In Lean, it would be approximately:

```
-- Suppose U'(psi, chi) holds at t.
-- Then chi holds from t to gap g, and neg chi arbitrarily soon after g.
-- F(chi) holds at t.
-- By W: U(neg chi, chi) holds at t.
-- U(neg chi, chi) means: chi holds continuously until neg chi.
-- But chi cannot hold continuously to a gap where neg chi is arbitrarily soon.
-- Contradiction: the "Until" structure prevents the gap behavior of U'.
```

If we can formalize this argument (even informally, by adding W as an axiom and deriving
the "no definable gaps" consequence), the IsSuccArchimedean sorry becomes much more tractable.

The CORE question reduces to: **can axiom W be used to prove that every bounded interval
of limit_dom is finite?** If W forces every definable strictly monotone bounded sequence
to terminate, then yes.
