# Teammate A Findings: Burgess's Actual Construction Mechanism

**Task**: 107 - g_content_chain_property blocker
**Angle**: Primary -- Burgess 1982's actual construction mechanism
**Date**: 2026-04-24

---

## Key Findings

### 1. Burgess Maintains (f, g) Pairs at EVERY Finite Stage -- Not Just in the Limit

The most critical finding from analyzing the codebase against Burgess's published method is this: **the g_content_chain_property is not a property that needs to be proved about the limit -- it is an INVARIANT maintained at every finite stage of the omega-chain**. The current codebase attempts to prove it about the limit after the fact, which is architecturally backwards.

In Burgess's construction, each finite chronicle chi_n = (dom_n, f_n, g_n) satisfies:
- C0: f_n(x) is MCS for all x in dom_n
- C1: g_n(x,y) is DCS for all adjacent x < y in dom_n
- C2: rRelation(f_n(x), g_n(x,y)) for adjacent x < y
- C3: g_content(f_n(x)) subset g_n(x,y) for adjacent x < y

These conditions hold at stage 0 (trivially, singleton domain has no adjacent pairs) and are PRESERVED by each elimination step. The limit inherits them because the domain grows monotonically, f agrees on old points, and g is defined for each adjacent pair at the stage it first becomes adjacent.

The current codebase violates this pattern: `eliminate_potential_counterexample` returns a new chronicle with `g := chi.g` (the g function is simply copied unchanged). The new g never accounts for the newly inserted point. This is the architectural root cause.

### 2. How Burgess Ensures g_content(f(x)) subset f(y) for x < y

The chain property follows from a sequence of local steps through adjacent pairs:

**Step 1**: G(phi) in f(x) means phi in g_content(f(x)).

**Step 2**: By C3, g_content(f(x)) subset g(x, x1) where x1 is the immediate successor of x in the domain.

**Step 3**: The r-relation R(f(x), g(x, x1)) combined with the DCS property of g(x, x1) implies that g(x, x1) subset f(x1) is NOT automatic. However, the key is that g(x, x1) is an R-maximal DCS: it contains as much as possible while maintaining R(f(x), g(x, x1)).

**Step 4**: The propagation works via temp_4 (BX4 for temporal transitivity): G(phi) in f(x) implies G(G(phi)) in f(x) (by temp_4). So G(phi) in g_content(f(x)) subset g(x, x1). By the R-relation structure and DCS closure, G(phi) in g(x, x1). Now g(x, x1) subset f(x1) is the KEY missing step. Let me analyze this more carefully.

**The crucial mechanism**: g(x, x1) is NOT required to be a subset of f(x1). Rather, the relationship is mediated by the R-relation. The R-relation R(f(x), g(x, x1)) says: for all gamma U delta in f(x), either delta in g(x, x1) or (gamma in g(x, x1) AND gamma U delta in g(x, x1)). This is about Until formulas, not about arbitrary formulas.

For the G-propagation specifically, the mechanism is:
- G(phi) in f(x)
- By C3: phi in g(x, x1) (since phi in g_content(f(x)) subset g(x, x1))
- By the construction of f(x1): f(x1) is built with a seed that includes g_content from the triggering point

**This is where the codebase diverges from Burgess.** In Burgess, when x1 is inserted as a C5 witness after x, the seed for f(x1) is not just {eta} union g_content(f(trigger)); it is constructed through Lemma 2.4 which produces an MCS C with:
- eta in C (the Until witness)
- g_content(f(x)) subset C (temporal coherence with the LEFT endpoint)

And then g(x, x1) is constructed as an R-maximal DCS between f(x) and f(x1). The R-maximal extension theorem (`rMaximal_extension_exists` in the codebase) produces a g(x, x1) that is as large as possible.

### 3. When Inserting z Between x and y: The g-Splitting Mechanism

This is the hardest part. When a new point z is inserted between adjacent x and y at stage n, Burgess:

**a) Constructs f(z)** via PointInsertion (Lemma 2.4 for C5, Lemma 2.6 for C4). The seed for f(z) includes g_content(f(x)), ensuring g_content(f(x)) subset f(z).

**b) Splits g(x, y) into g(x, z) and g(z, y)**:
- g(x, z) is constructed as an R-maximal DCS satisfying R(f(x), g(x, z))
- g(z, y) is constructed as an R-maximal DCS satisfying R(f(z), g(z, y))
- The seed for g(x, z) includes g_content(f(x)) (by C3 for the new pair)
- The seed for g(z, y) includes g_content(f(z)) (by C3 for the new pair)

**c) The decomposition C3 for non-adjacent triples**: For any x < w < z (where w was already in the domain before z), the old g(x, w) remains unchanged. For x < z < y, the new g values satisfy: anything in the old g(x, y) that is also in f(z) will appear in both g(x, z) and g(z, y) through the R-maximal construction.

The key insight is that Burgess does NOT define g(x, z) = g(x, y) intersect Something. Instead, g(x, z) is INDEPENDENTLY constructed as an R-maximal DCS, with a seed that includes g_content(f(x)). The R-maximality theorem (Zorn's lemma via `rMaximal_extension_exists`) handles the existence.

### 4. C4 vs C5 Insertions: No Fundamental Difference in g-Handling

Both C4 and C5 counterexample elimination follow the same pattern for the g function:

**C5 (Until witness, Lemma 2.10)**: Insert y after x (or between x and its successor).
- f(y) gets g_content(f(x)) via the seed (Lemma 2.4 ensures this)
- g(x, y) constructed as R-maximal DCS with seed including g_content(f(x))
- If y was inserted between x and x', then g(x, x') is replaced by g(x, y) and g(y, x')

**C4 (negation of Until, Lemma 2.9)**: Insert z between x and y.
- f(z) gets neg(delta) via the seed (Lemma 2.6 ensures this)
- f(z) ALSO gets g_content(f(x)) via the seed
- g(x, z) and g(z, y) constructed as R-maximal DCS extensions

The difference is only in WHAT goes into the seed for f(z) (eta for C5 vs neg(delta) for C4), not in how g is handled. The g-splitting mechanism is identical.

### 5. Burgess Does NOT Use C3 as g(x,z) = g(x,y) intersect f(y) intersect g(y,z)

Report 17 and plan v7 state that Burgess uses C3 as a decomposition identity: g(x,z) = g(x,y) intersect f(y) intersect g(y,z). After careful analysis, this characterization is misleading.

What Burgess actually requires is:
- **C3 (weak form)**: g_content(f(x)) subset g(x, y) for adjacent x < y

This is the property that g_content of the left endpoint is included in the interval DCS. The "decomposition identity" is a CONSEQUENCE of the construction (when all adjacent pairs have been processed), not an axiom maintained at each step.

The codebase already has this as `Chronicle.c3` in ChronicleTypes.lean (line 222-223):
```
def Chronicle.c3 (chi : Chronicle) : Prop :=
  forall x y : Rat, Adjacent chi.dom x y -> g_content (chi.f x) subset chi.g x y
```

This IS the right definition. The problem is that the omega-chain construction does not maintain it.

### 6. The Lindenbaum Extension Does Give Enough Control

The handoff document (phase1-v7-handoff.md) states that "Lindenbaum extensions are opaque -- we cannot control what extra formulas they add." This is true but misleading. The key point is:

**We do not need to control what extra formulas Lindenbaum adds to f(z).** We only need:
1. g_content(f(x)) subset f(z) -- guaranteed by the seed design
2. The specific formula (eta for C5, neg(delta) for C4) is in f(z) -- guaranteed by the seed design
3. g(x, z) is an R-maximal DCS with g_content(f(x)) subset g(x, z) -- constructed independently via Zorn's lemma

The "opacity" of Lindenbaum is irrelevant because:
- We never need g_content(f(z)) subset f(y) for EXISTING y after z. This is the backwards direction.
- For the FORWARD direction (g_content(f(z)) subset f(w) for w inserted AFTER z), the seed for f(w) will include g_content(f(z)) by the same mechanism.
- For EXISTING y BEFORE z, we need g_content(f(y)) subset f(z), which is guaranteed because the seed for f(z) includes g_content(f(x)) and x < z, so by temp_4 transitivity, g_content of any predecessor of x also propagates.

**Wait** -- this is the critical subtlety. Does g_content(f(y)) subset f(z) hold for y that is NOT the immediate predecessor x? It does, by temp_4 (lemma_2_5b): if g_content(f(y)) subset f(x) (already established) and g_content(f(x)) subset f(z) (by seed), then g_content(f(y)) subset f(z) by transitivity.

So the chain property IS maintained inductively -- but only if we actually include g_content(f(x)) in the seed for EVERY new point f(z) where x is the immediate predecessor. The current codebase does this for C5 witnesses (lemma_2_4 includes g_content(f(x))), but NOT for C4 witnesses where the seed is just {neg(delta)} or copies of f(x)/f(y).

### 7. The C4 Sub-Case 1a Sorry: Why delta in f(x) AND delta in f(y) Is Actually Handleable

The two sorry sites in CounterexampleElimination.lean are the sub-case where delta in f(x) AND delta in f(y). The comment says this "requires g_content(f(x)) subset f(y)."

With the binary g maintained through the construction, this becomes provable:
- neg(gamma U delta) in f(x) and delta in f(x) gives a contradiction only if gamma U delta is derivable from delta, which is not generally true
- BUT: with R(f(x), g(x,y)) and the R-maximal structure of g(x,y), we can derive that neg(delta) is in g(x,y) (from neg(gamma U delta) in f(x) and the R-relation analysis)
- This then gives neg(delta) in f(y) via g(x,y) subset f(y) (which follows from the maintained C3 invariant once binary g is in place)

Actually, let me be more careful. The R-relation says: for gamma U delta in f(x), either delta in g(x,y) or (gamma in g(x,y) AND gamma U delta in g(x,y)). But we have NEG(gamma U delta) in f(x), not gamma U delta. So the R-relation does not directly apply.

The actual argument for sub-case 1a requires: if neg(gamma U delta) in f(x) and g_content(f(x)) subset f(y), then by contrapositive: if gamma U delta were derivable from g_content(f(x)), then gamma U delta would be in f(x), contradicting neg(gamma U delta) in f(x) (by MCS consistency). Since delta is in f(y) and g_content(f(x)) subset f(y), we need to show that delta alone does not force gamma U delta into f(x).

This sub-case actually requires using Lemma 2.6 (negative insertion): since neg(gamma U delta) in f(x) and g_content(f(x)) subset f(y), and if delta in f(y), then G(delta) might or might not be in f(x). If G(delta) in f(x), that is consistent with neg(gamma U delta) in f(x) -- delta being always true in the future does not mean gamma U delta holds (because the guard gamma might fail). So this sub-case may need a different argument: use the R-maximal g(x,y) to derive that neg(delta) must appear somewhere in the interval.

**This remains the most subtle point of the construction and may require careful paper-proving before implementation.**

---

## Recommended Approach

### Phase 1 Implementation Strategy

1. **Modify omega-chain step to update g alongside f**: When `eliminate_potential_counterexample` inserts a new point z, it must also:
   - Construct g(x, z) as an R-maximal DCS with seed = deductiveClosure(g_content(f(x)))
   - Construct g(z, y) as an R-maximal DCS with seed = deductiveClosure(g_content(f(z))) (only if y exists as z's successor)
   - Update g for all pairs affected by the insertion

2. **Prove C3 preservation inductively**: At each step, show that g_content(f_n(x)) subset g_n(x, x1) for all adjacent pairs. The base case is trivial (singleton domain). The inductive step uses:
   - For unchanged pairs: C3 holds by induction
   - For new pairs involving the inserted point: C3 holds by seed construction
   - For split pairs: C3 holds because the new g values are R-maximal extensions of seeds that include g_content

3. **Derive g_content_chain_property from C3 + temp_4**: For x < y in limit_dom, chain through adjacent pairs x = x0 < x1 < ... < xk = y. At each step: G(phi) in f(xi) implies G(G(phi)) in f(xi) by temp_4, hence G(phi) in g(xi, xi+1) by C3, hence G(phi) in f(xi+1) by... wait, this requires g(xi, xi+1) subset f(xi+1), which is NOT C3.

**This is the core gap.** C3 says g_content(f(x)) subset g(x,y), NOT g(x,y) subset f(y). The containment g(x,y) subset f(y) would require the T-axiom (G(phi) -> phi) which is NOT available under strict semantics.

### The Real Mechanism for g_content(f(x)) subset f(y)

After deeper analysis, the propagation through adjacent pairs works as follows:

For adjacent x < y in the chronicle:
1. G(phi) in f(x)
2. phi in g_content(f(x)) subset g(x, y) (by C3)
3. phi in f(y) because: **f(y) was constructed with g_content(f(x)) in its seed**

Step 3 is the key: g_content propagation to f(y) does NOT go through g(x,y). It goes DIRECTLY through the seed construction. When y was inserted (at whatever stage), the Lindenbaum seed for f(y) included g_content(f(x)) where x was y's predecessor AT THAT TIME.

But what about later insertions that change the adjacency? If z is inserted between x and y later, making x adjacent to z and z adjacent to y:
- g_content(f(x)) subset f(z) (by z's seed)
- g_content(f(z)) subset f(y)? NO -- f(y) was fixed BEFORE z was inserted!

**This is the exact obstruction described in the handoff.** And this is where the binary g helps:
- We need g_content(f(z)) subset f(y) for the propagation chain
- f(y) was fixed before z existed
- BUT: g_content(f(x)) subset f(y) (f(y)'s seed included g_content(f(x)) when y was first inserted)
- By temp_4: G(phi) in f(z) and g_content(f(x)) subset f(z) does NOT imply G(phi) in f(x)

**Conclusion**: The binary g does NOT solve the backwards propagation problem through direct containment. The propagation must use a different path.

### The Correct Resolution: Direct Induction on Formula, Not on Domain Points

After this deep analysis, I believe the correct approach is what Burgess actually does in Claim 2.11: the truth lemma is proved by **induction on formula complexity**, not by establishing g_content_chain_property as a standalone lemma.

For the G case of the truth lemma:
- Forward: G(phi) in f(x), need phi true at all y > x. By induction hypothesis, phi in f(y) iff phi true at y. So need phi in f(y) for all y > x in the domain.
- This is proved by: G(phi) in f(x) implies F(phi) in f(x) (by G_implies_F_mcs), implies there exists z > x with phi in f(z) (by C5). Then G(phi) in f(z) (by... actually G(phi) may not be in f(z)).

**The real argument**: The truth lemma G case uses the INTERVAL function:
- G(phi) in f(x) implies phi in g(x, x1) for adjacent x < x1 (by C3 and DCS closure)
- phi in g(x, x1) and the DCS structure of g(x, x1) gives phi true throughout (x, x1)
- phi in f(x1) because... this needs justification

**I now believe the g(x,y) subset f(y) issue is handled by the R-MAXIMAL construction combined with the MCS structure of f(y).** The R-maximal DCS g(x,y) is the largest DCS satisfying R(f(x), g(x,y)). Since f(y) is an MCS (hence also a DCS) and satisfies R(f(x), f(y)) (because g_content(f(x)) subset f(y) by seed construction), f(y) is a candidate for the R-relation. The R-maximal g(x,y) contains everything that any R-satisfying DCS can contain. If phi is in g(x,y), and phi is consistent with f(y) (which it is, since f(y) is an MCS), then phi MUST be in f(y) -- otherwise g(x,y) union {phi} would be a DCS satisfying R that extends g(x,y), contradicting R-maximality... wait, that is backwards. phi IS in g(x,y) but we need it in f(y).

**Let me reconsider.** The relationship between g(x,y) and f(y) is:
- Both satisfy R(f(x), -)
- g(x,y) is R-maximal (no proper DCS extension satisfies R)
- f(y) is an MCS (which is a DCS)
- g(x,y) subset f(y)? Not necessarily! g(x,y) might contain formulas not in f(y).

Actually, the R-maximal DCS between f(x) and f(y) is contained in f(y) IF we ALSO require that g(x,y) subset f(y) as an additional constraint. But that IS the chain property we are trying to prove!

### Final Assessment

After this thorough analysis, I conclude:

**The g_content_chain_property (g_content(f(x)) subset f(y) for all x < y in the domain) CANNOT be established from the R-relation and R-maximality alone under strict semantics.** It requires a specific construction choice: the seed for f(y) must include g_content from ALL predecessors of y, not just the triggering point.

The fix that actually works is:

**When inserting any new point z into the domain, the seed for f(z) must include g_content(f(w)) for ALL existing domain points w < z.** By temp_4 transitivity (lemma_2_5b), this reduces to including g_content(f(max_predecessor)) where max_predecessor is the largest existing domain point less than z. This is exactly what the current C5 construction does for the triggering point. The issue arises when z is inserted NOT immediately after the triggering point but somewhere else.

For C5 insertions (currently placed beyond all points): the max_predecessor IS the triggering point (or the current max of the domain), and the seed already includes g_content(f(triggering_point)). By temp_4, g_content of all earlier predecessors propagates. **This works.**

For C4 insertions (placed between adjacent x and y): f(z) needs g_content(f(x)) in its seed. The current implementation in sub-cases 2 and 1b uses f(x) or f(y) directly as f(z), which does NOT guarantee g_content(f(x)) subset f(z) when f(z) = f(y).

**The fix for C4**: Always construct f(z) via a Lindenbaum extension of a seed that includes both {neg(delta)} and g_content(f(x)). The seed consistency follows from: neg(delta) and g_content(f(x)) are consistent because neg(gamma U delta) in f(x) means gamma U delta is not provable from g_content(f(x)) (otherwise gamma U delta would be in f(x) by DCS closure under MCS, contradiction).

Wait -- that argument is not quite right. g_content(f(x)) is a subset of f(x). neg(gamma U delta) in f(x). We need {neg(delta)} union g_content(f(x)) to be consistent. This means we need: delta is NOT derivable from g_content(f(x)). If delta WERE derivable from g_content(f(x)), then delta in f(x) (since f(x) is an MCS containing g_content(f(x))). But delta in f(x) is exactly sub-case 1. So in sub-case 2 (neg(delta) in f(x)), delta is NOT in f(x), hence NOT derivable from g_content(f(x)) (since g_content(f(x)) subset f(x)), hence the seed is consistent.

For sub-case 1a (delta in f(x) AND delta in f(y)): we need {neg(delta)} union g_content(f(x)) consistent, but delta might be derivable from g_content(f(x)) if G(delta) in f(x). If G(delta) in f(x), then delta in g_content(f(x)), so {neg(delta)} union g_content(f(x)) is inconsistent. This is exactly why sub-case 1a is hard.

**Sub-case 1a resolution**: If G(delta) in f(x), then by the already-established chain property (inductively from earlier stages), delta in f(y). Since neg(gamma U delta) in f(x), and gamma in f(y), we need neg(delta) between x and y. But delta in f(y) by assumption. The counterexample is: gamma holds at y but delta also holds at y, which means the gamma U delta could potentially be satisfied at x with witness y. The neg(gamma U delta) in f(x) means this is NOT the case -- the guard gamma must fail somewhere. So we actually need the full inductive argument from Burgess's Lemma 2.9 which proceeds by induction on the number of intermediate domain points.

---

## Evidence/Examples

### Codebase Evidence

1. **eliminate_C5_counterexample** (CounterexampleElimination.lean, line 121-155): Places new point beyond ALL domain points using `exists_rat_gt_finset`. The g function is not updated (`chi.g` is copied as-is). This is the primary architectural failure.

2. **eliminate_C4_counterexample** (CounterexampleElimination.lean, line 252-323): Sub-cases 2 and 1b assign f(z) = f(x) or f(z) = f(y) without constructing a new MCS via Lindenbaum. This means g_content(f(x)) is NOT guaranteed in f(z) when f(z) = f(y).

3. **singleton_chronicle** (ChronicleConstruction.lean, line 67-70): Correctly initializes g = fun _ _ => empty. No adjacent pairs exist, so C1-C3 are vacuous. This is correct.

4. **limit_g** (ChronicleConstruction.lean, line 579-581): Defined as `deductiveClosure(g_content(limit_f(x)))` -- a UNARY function of x only. This should be the binary g from the construction stages.

5. **lemma_2_4** (PointInsertion.lean, line 152-176): Correctly includes g_content(f(x)) in the seed for the new MCS. This IS the right Burgess construction for C5 witnesses.

6. **rMaximal_extension_exists** (RRelation.lean, line 243-283): Proves existence of R-maximal DCS extensions via Zorn's lemma. This infrastructure IS available for constructing the binary g(x,y) values.

### Mathematical Evidence

The codebase already has the key building blocks:
- `g_propagation_seed_consistent`: {alpha} union g_content(A) is consistent when G(alpha) in A
- `forward_temporal_witness_seed_consistent`: {beta} union g_content(A) is consistent when F(beta) in A
- `lemma_2_5b`: g_content ordering is transitive (temp_4)
- `g_content_sub_imp_h_content_sub`: g_content(A) subset B iff h_content(B) subset A (duality bridge)
- `rMaximal_extension_exists`: R-maximal DCS extensions exist (Zorn's lemma)

---

## Confidence Level

**High confidence (85%)** on the diagnosis: the binary g must be maintained through the omega-chain, not reconstructed in the limit.

**Medium confidence (60%)** on the propagation mechanism: the exact pathway from g_content(f(x)) to f(y) goes through the SEED construction (f(y) was Lindenbaum-extended from a seed including g_content), NOT through g(x,y) subset f(y). This means the binary g is necessary for the truth lemma's interval conditions but the chain property itself follows from seed design + temp_4 transitivity.

**Low confidence (40%)** on sub-case 1a: the delta-in-both-endpoints case remains the deepest mathematical subtlety. It may require Burgess's full Lemma 2.9 induction on intermediate point count, which is significantly more complex than the current case-split approach.

**Key uncertainty**: Whether the chain property can be proved WITHOUT the binary g (just using the seed construction and temp_4), or whether the binary g is strictly necessary. My analysis suggests the seed-based approach suffices for the chain property, but the binary g is needed for the truth lemma's Until case (interval guard conditions).

---

## Sources

- [Burgess 1982 Part I - Project Euclid](https://projecteuclid.org/euclid.ndjfl/1093870149)
- [Burgess 1982 Part II - Project Euclid](https://projecteuclid.org/euclid.ndjfl/1093870150)
- [Burgess 1984 Basic Tense Logic - Springer](https://link.springer.com/chapter/10.1007/978-94-009-6259-0_2)
- [Verbrugge et al. - Completeness by Construction](https://festschriften.illc.uva.nl/D65/verbrugge.pdf)
- [SEP - Temporal Logic](https://plato.stanford.edu/entries/logic-temporal/)
- Report 08 (08_verbrugge-step-by-step.md) in this task
- Report 17 (17_team-research.md) in this task
- Phase 1 v7 handoff (handoffs/phase1-v7-handoff.md)
