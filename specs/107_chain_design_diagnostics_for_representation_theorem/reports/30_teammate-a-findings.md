# Research Report: Task 107 -- Burgess r-relation vs Codebase rRelation

**Task**: 107 - Precise mathematical analysis of r-relation correspondence
**Date**: 2026-04-26
**Confidence Level**: HIGH (definitions are fully available; analysis is complete)

---

## Key Findings

1. **Burgess's r and the codebase's rRelation are genuinely different relations** -- they are NOT equivalent restatements. The codebase's rRelation is strictly weaker (monotone in B), while Burgess's r is non-monotone.

2. **R3Maximal does NOT imply burgessR3** in general. However, the codebase already contains `burgessR`, `burgessRSet`, `burgessR3`, and the Lemma 2.5 absorption proofs, meaning the infrastructure to bridge the gap exists.

3. **The C4 hard case sorry (line 334 of CounterexampleElimination.lean) requires burgessR3**, not just R3Maximal. The handoff analysis (report 29) correctly identifies this as the blocker.

4. **The fix path is clear**: the ChronicleInvariant must track burgessR3 alongside R3Maximal, or the r-relation definitions must be strengthened to combine both properties.

---

## 1. What Exactly is Burgess's r(A, B, C)?

### Notation Convention (CRITICAL)

Burgess writes `U(alpha, beta)` where:
- **alpha = EVENT** (the thing that eventually happens)
- **beta = GUARD** (the thing that holds throughout the interval)

The codebase writes `Formula.untl phi psi` where:
- **phi = GUARD** (first argument)
- **psi = EVENT** (second argument)

Semantics confirm this:
- Burgess: `V(U(alpha, beta)) = {x : exists y > x, y in V(alpha), forall z(x < z < y => z in V(beta))}`
- Codebase: `untl phi psi at t = exists s > t, psi(s) AND forall r in [t,s), phi(r)`

**Translation**: Burgess's `U(alpha, beta)` = codebase's `Formula.untl beta alpha`.

### Lemma 2.3 Definition

Burgess defines `r(A, beta, C)` for MCS A, C and formula beta as:

**(a)** For all gamma in C, `U(gamma, beta)` in A.

**(b)** For all alpha in A, `S(alpha, beta)` in C.

These are proved equivalent (Lemma 2.3). Translating (a) to codebase notation:

> **r(A, beta, C)**: For all gamma in C, `Formula.untl beta gamma` in A.

That is: beta serves as a valid guard for the interval between A and C. Any formula gamma holding at endpoint C can be paired with guard beta into an Until formula `beta U gamma` that holds at A.

### Set-level r(A, B, C)

Burgess writes `r(A, B, C)` to mean: B is a DCS, and `r(A, beta, C)` holds for all beta in B.

### R-maximality R(A, B, C)

`R(A, B, C)`: B is maximal w.r.t. the property `r(A, ---, C)`. That is, `r(A, B, C)` holds, but for no proper DCS extension B' of B does `r(A, B', C)` hold.

**Crucial consequence of Burgess's R-maximality**: If `R(A, B, C)` and `delta not in B`, then there exists `beta in B` and `gamma in C` such that `U(gamma, beta AND delta) not in A` (equivalently, `Formula.untl (beta AND delta) gamma not in A`). This is because adding delta to B would have to break `r(A, ---, C)` for some witness.

---

## 2. What Exactly is the Codebase's rRelation(A, B)?

### Definition (ChronicleTypes.lean, line 134)

```lean
def rRelation (A B : Set Formula) : Prop :=
  forall (gamma delta : Formula),
    Formula.untl gamma delta in A ->
    delta in B or (gamma in B and Formula.untl gamma delta in B)
```

In words: for every Until formula `gamma U delta` in A, the interval set B either:
- **resolves** the Until (delta, the event, is in B), or
- **continues** the Until (the guard gamma is in B, and the Until itself persists in B).

### r3Relation(A, B, C)

```lean
def r3Relation (A B C : Set Formula) : Prop :=
  rRelation A B and rRelationSince C B
```

Combines forward propagation (Until from A) with backward propagation (Since from C).

### R3Maximal(A, B, C)

```lean
def R3Maximal (A B C : Set Formula) : Prop :=
  SetDeductivelyClosed B and
  r3Relation A B C and
  forall D, SetDeductivelyClosed D -> B subset D -> not (r3Relation A D C)
```

B is a maximal DCS satisfying r3Relation(A, -, C).

### The Codebase's burgessR (RRelation.lean, line 534)

The codebase already defines the Burgess relation:

```lean
def burgessR (A : Set Formula) (beta : Formula) (C : Set Formula) : Prop :=
  forall gamma in C, Formula.untl beta gamma in A
```

And the set-level version `burgessRSet`, `burgessR3`, plus Lemma 2.5 absorption (`burgessR_absorption`, `burgessR3_absorption`).

---

## 3. Direction Comparison: Are They the Same?

### Short answer: NO. They are genuinely different.

### Burgess r(A, beta, C): direction C x {beta} -> A

> "For all gamma in C, (beta U gamma) in A."

This says: the **endpoint C determines what goes into A**. Every formula at C, combined with guard beta, produces an Until in A.

### Codebase rRelation(A, B): direction A -> B

> "For all (gamma U delta) in A, delta in B or (gamma in B and gamma U delta in B)."

This says: **A determines what goes into B**. Every Until formula in A must be either resolved or continued in B.

### Why They Are Not Equivalent

**rRelation(A, B) does NOT imply burgessR(A, beta, C) for any beta in B, gamma in C.**

Example: Let A be an MCS containing `p U q` and `r U s` but NOT `p U t` (for some unrelated formula t in C). Then rRelation(A, B) only constrains B w.r.t. the Until formulas already in A. It says nothing about `p U t` because `p U t` is not in A. But burgessR(A, p, C) would require `p U t` in A for every t in C.

**burgessR(A, beta, C) does NOT imply rRelation(A, B) where beta in B.**

Example: burgessR(A, beta, C) tells us about formulas of the form `beta U gamma` in A. But rRelation(A, B) requires constraints on ALL Until formulas in A, not just those with guard beta.

### Does Burgess's (a) <=> (b) Equivalence Help?

Burgess's equivalence `(a) <=> (b)` relates two FORMS of the SAME relation:
- (a) For all gamma in C, U(gamma, beta) in A [events from C, guard beta, result in A]
- (b) For all alpha in A, S(alpha, beta) in C [formulas from A, guard beta, reflected as Since in C]

This is an equivalence about a single relation r(A, beta, C). It does NOT connect Burgess's r to the codebase's rRelation, which has a completely different structure.

---

## 4. Does R3Maximal Imply Burgess's r(A, B, C)?

### NO.

**R3Maximal forces B to be an MCS** (see `R3Maximal_is_mcs` in PointInsertion.lean, line 763). This is because `r3Relation` is monotone in B: if B subset B' then `r3Relation(A, B, C)` implies `r3Relation(A, B', C)`. So maximality forces B to have no proper DCS extension, which means B is an MCS.

But being an MCS satisfying `r3Relation(A, B, C)` does NOT mean `burgessRSet(A, B, C)`.

**Concrete counterexample construction**: Let A, B, C be MCS with:
- `p in B` (some propositional variable)
- `q in C` (some unrelated variable)
- `p U q not in A` (A simply does not contain this formula)

Then `rRelation(A, B)` can still hold (it only constrains B based on Until formulas ALREADY in A). But `burgessR(A, p, C)` fails because `p U q not in A`.

### The Gap is Real

The handoff document (report 29) correctly states:

> The property "gamma in B + delta in C implies untl(gamma, delta) in A" is Burgess's r-relation. The codebase's rRelation encodes a DIFFERENT property. These are NOT equivalent.

---

## 5. Key Test: R3Maximal + neg(untl(gamma,delta)) in A + delta in C

### Setup

Given:
- R3Maximal(A, B, C) (so B is an MCS by R3Maximal_is_mcs)
- neg(untl(gamma, delta)) in A (the negated Until, where gamma = guard, delta = event)
- delta in C

### Question: Is gamma NOT in B?

### Under Burgess's Definition (r(A, B, C) in Burgess sense)

Burgess R(A, B, C) means: for all beta in B and all alpha in C, `U(alpha, beta)` in A (translating: `Formula.untl beta alpha` in A).

If gamma in B, then for delta in C, Burgess's condition gives `Formula.untl gamma delta` in A. But `neg(Formula.untl gamma delta)` is also in A (given). Since A is an MCS, this is a contradiction. Therefore **gamma NOT in B**.

This is the "bridging argument" the handoff document describes: with Burgess's r-relation, gamma in B immediately contradicts neg(untl(gamma, delta)) in A via delta in C.

### Under the Codebase's Definition (r3Relation + R3Maximal)

R3Maximal(A, B, C) with the codebase's `r3Relation` gives:
- `rRelation(A, B)`: for untl(phi, psi) in A, psi in B or (phi in B and untl(phi, psi) in B)
- `rRelationSince(C, B)`: for snce(phi, psi) in C, psi in B or (phi in B and snce(phi, psi) in B)

Now, `neg(untl(gamma, delta)) in A` means `untl(gamma, delta) NOT in A` (MCS property). So rRelation(A, B) says nothing about the pair (gamma, delta) -- the antecedent `untl(gamma, delta) in A` is false.

Can gamma be in B? **YES, it can**. The codebase's r3Relation provides no constraint that would force gamma out of B. The Until formula is NEGATED in A, so rRelation's antecedent never fires for it.

### Where They Diverge

| Property | Burgess r(A,B,C) | Codebase r3Relation(A,B,C) |
|----------|-------------------|---------------------------|
| gamma in B, delta in C | Forces untl(gamma,delta) in A | No constraint (antecedent-free) |
| neg(untl(gamma,delta)) in A | Contradicts gamma in B (via delta in C) | Compatible with gamma in B |
| Direction | B x C -> A (constructive) | A -> B (propagative) |
| Monotonicity in B | NOT monotone | Monotone |
| R-maximality forces | Genuinely maximal DCS (may not be MCS) | MCS (by monotonicity collapse) |

---

## Recommended Approach

### Option 1 (Preferred): Strengthen ChronicleInvariant with burgessR3

The codebase already has:
- `burgessR`, `burgessRSet`, `burgessR3` definitions (RRelation.lean lines 534-569)
- `burgessR_absorption`, `burgessR3_absorption` (Lemma 2.5 proofs, RRelation.lean lines 604-722)

What is needed:
1. **Define BurgessR3Maximal**: `R3Maximal(A, B, C) AND burgessR3(A, B, C)`
2. **Prove existence**: Show that when constructing B via the Zorn/Lindenbaum process, the seed satisfies burgessR3 and the property is preserved by chain unions
3. **Add to ChronicleInvariant**: Replace `hc2'` with BurgessR3Maximal or add a separate field
4. **Close C4 hard case**: Use burgessR3 to derive the contradiction (gamma in B contradicts neg(untl(gamma, delta)) in A via delta in C)

### Why This Works

The C4 hard case at line 334 of CounterexampleElimination.lean is:
- G(gamma) in f(x), H(gamma) in f(y)
- neg(untl(gamma, delta)) in f(x)
- delta in f(y)

With burgessR3(f(x), g(x,y), f(y)):
- If gamma in g(x,y), then for delta in f(y): `untl(gamma, delta)` in f(x) (by burgessRSet)
- But neg(untl(gamma, delta)) in f(x) -- contradiction
- Therefore gamma NOT in g(x,y)
- Since g(x,y) is an MCS (by R3Maximal_is_mcs): neg(gamma) in g(x,y)
- By C3, g(x,y) subset f(z) for any z between x and y
- Therefore neg(gamma) in f(z) -- the counterexample witness exists

### Key Risk: Proving burgessR3 Existence

The hardest step is proving that the Zorn-constructed R3-maximal B also satisfies `burgessR3(A, B, C)`. This requires showing:

1. **Seed satisfies burgessR3**: The initial DCS seed from which Zorn extends must have the Burgess property. For Lemma 2.4 (Until witness construction), the seed is `{beta} union g_content(A)`. For Lemma 2.6 (point insertion), the seed depends on the construction.

2. **Chain union preserves burgessR3**: If every element of a chain satisfies burgessRSet(A, -, C), the union does too. This is straightforward: burgessRSet(A, B, C) says "for all beta in B, for all gamma in C, untl(beta, gamma) in A". For beta in the union, beta is in some chain element, and the property is inherited.

3. **Maximality under combined constraint**: The Zorn extension must be maximal w.r.t. BOTH r3Relation AND burgessR3. This means defining a combined extension set and proving the chain condition.

**Risk assessment**: Steps 2 and 3 are straightforward. Step 1 requires careful seed construction -- the seed must include enough formulas that the Burgess property holds for all seed elements. For the Lemma 2.3(b) direction, this means: for beta in the seed and gamma in C, we need `untl(beta, gamma) in A`. This is where the construction must be deliberate.

### Option 2 (Alternative): Replace r3Relation with Burgess's r-relation entirely

Redefine `r3Relation` as `burgessR3` (content-based). This makes the codebase match Burgess exactly. However:
- The r-relation becomes non-monotone in B
- R3Maximal no longer collapses to MCS
- Zorn's lemma proof structure changes (chain union needs different argument)
- Many existing theorems (rRelation_subset, R3Maximal_is_mcs, lemma_2_6_full) would need rewriting

This is a higher-risk, higher-reward approach. It aligns with Burgess perfectly but requires significant refactoring.

### Option 3: Prove the Bridge Directly

Show that for the specific B constructed by `r3Maximal_extension_exists`, burgessR3 holds. This avoids changing the definitions but requires intricate analysis of the Zorn construction.

**Assessment**: Likely the hardest option. The Zorn construction is abstract (it picks an arbitrary maximal element), so proving properties of the specific B requires adding constraints to the extension set, which is effectively Option 1.

---

## Evidence/Examples

### The Sorry Site (CounterexampleElimination.lean:334)

```lean
-- G(gamma) in f(x) and H(gamma) in f(y). Genuinely hard sub-case.
-- Requires guard-strengthening for Until (not available in BX without A4a).
sorry
```

This sorry requires proving: there exists z between x and y with neg(gamma) in f(z). The only viable path is through g(x,y): show gamma NOT in g(x,y), hence neg(gamma) in g(x,y) (MCS), hence neg(gamma) in f(z) for intermediate z (by C3).

### Monotonicity Proof (PointInsertion.lean:763)

```lean
theorem R3Maximal_is_mcs {A B C : Set Formula}
    (h_R3 : R3Maximal A B C) : SetMaximalConsistent B
```

This theorem is valid and useful but confirms the monotonicity collapse: the codebase's R3Maximal is a stronger condition than Burgess's R-maximality (it forces MCS), yet paradoxically weaker in content (it lacks the Burgess r-relation property).

### Existing burgessR3 Infrastructure (RRelation.lean:568)

```lean
def burgessR3 (A B C : Set Formula) : Prop :=
  burgessRSet A B C and burgessRSetSince C B A
```

This definition and its absorption lemma (`burgessR3_absorption`) are already proved sorry-free. The infrastructure for Option 1 is largely in place.

---

## Confidence Level

**HIGH** for the analysis. The definitions are fully readable, the divergence is clear and demonstrable, and the fix path (Option 1) has existing infrastructure support. The remaining work is:

1. Defining `BurgessR3Maximal` (trivial)
2. Proving existence of BurgessR3Maximal extensions (moderate -- requires careful seed construction)
3. Threading burgessR3 through ChronicleInvariant (moderate -- plumbing work)
4. Closing the C4 sorry using burgessR3 (straightforward once the invariant is available)
