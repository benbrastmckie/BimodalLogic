# Critical Review: Case-Split Completeness Approach

**Task**: 117 - Remove Cantor isomorphism and build countermodel on limit domain
**Date**: 2026-05-08
**Role**: Adversarial Critic
**Scope**: Evaluate the proposal to case-split completeness by dense/discrete on AddCommGroup D

---

## Proposal Summary

The proposal adds an axiom `U(T,bot) <-> S(T,bot)` ("forward-discrete iff backward-discrete") and splits the completeness proof:

- **Dense case**: `neg(phi) /\ F'T /\ P'T` consistent -> chronicle domain dense -> Cantor iso -> D = Rat
- **Discrete case**: `neg(phi) /\ G'bot /\ H'bot` consistent -> domain iso Z -> D = Int

The uniformity axiom is claimed valid over all `AddCommGroup D`.

---

## Issue 1: Is the Uniformity Claim Correct?

**Concern**: The claim that in an ordered abelian group, if `a < b` are adjacent (no element between them), then `x < x + (b - a)` are adjacent for all x.

**Analysis**: This IS correct for `AddCommGroup D` with `IsOrderedAddMonoid D`. Translation by a constant is an order-automorphism: the map `y -> y + c` is a bijection `D -> D` preserving `<` (by `add_lt_add_right`). Therefore `Set.Ioo a b` is empty iff `Set.Ioo (a+c) (b+c)` is empty. In particular, if `a` and `b` are adjacent, then `a + c` and `b + c` are adjacent, and `b - a` is the uniform "step size."

Mathlib confirms this via `Set.image_const_add_Ioo` and `Set.preimage_add_const_Ioo` -- translation bijects open intervals.

**But there is a critical caveat**: the Mathlib theorem `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` requires `[Archimedean G]`:

```lean
theorem LinearOrderedAddCommGroup.discrete_or_denselyOrdered
    (G : Type) [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [Archimedean G] :
    Nonempty (G ≃+o Z) ∨ DenselyOrdered G
```

The codebase's `valid` does NOT require `Archimedean D`. This means there exist ordered abelian groups (like `Z x Z` with lexicographic order) that are neither dense nor isomorphic to Z, and yet are valid model domains under the current `valid` definition.

**Example**: `Z x Z` lex is an ordered abelian group where:
- `(0,0) < (0,1)` are adjacent (no element between them)
- `(0,1) < (1,0)` are NOT adjacent (`(0,2)` is between them)
- It has immediate successors at some points but not others in a NON-UNIFORM way

Wait -- actually in Z x Z lex, the order is: `(a,b) < (c,d)` iff `a < c` or (`a = c` and `b < d`). So:
- `(0,0)` and `(0,1)` are adjacent (no `(0,z)` with `0 < z < 1` in Z)
- `(0,1)` and `(0,2)` are also adjacent
- Between `(0,n)` and `(1,m)` there are infinitely many points `(0,n+1), (0,n+2), ...`

So in Z x Z lex, EVERY point has an immediate successor (add `(0,1)`). And every point has an immediate predecessor (subtract `(0,1)`). So U(T,bot) and S(T,bot) are both always true. The uniformity axiom U(T,bot) <-> S(T,bot) holds vacuously.

But Z x Z lex is NOT Archimedean (no finite multiple of `(0,1)` exceeds `(1,0)`), so the Mathlib theorem doesn't apply to factor it as "iso to Z or dense." It IS discrete (every point has immediate successor/predecessor), but it is NOT isomorphic to Z as an ordered group.

**Verdict**: The uniformity claim (adjacent implies uniformly adjacent) IS correct. Translation invariance of adjacency holds in any ordered abelian group. The proposed axiom `U(T,bot) <-> S(T,bot)` IS valid over all `AddCommGroup D` with `IsOrderedAddMonoid D`.

However, the CASE SPLIT "either dense or iso to Z" requires `Archimedean D`, which `valid` does not assume. See Issue 7 for the consequences.

**Severity**: MAJOR (see Issue 7 for the full impact)

---

## Issue 2: Does truth_at Handle bot Correctly?

**Concern**: What is `truth_at M Omega tau r Formula.bot`? Must be `False` for the argument to work.

**Analysis**: From `Truth.lean` line 122:
```lean
| Formula.bot => False
```

`truth_at M Omega tau r Formula.bot = False` definitionally. This is confirmed by `Truth.bot_false`.

So `U(T, bot)` at t evaluates to:
```
exists s > t, True /\ forall r, t < r -> r < s -> False
```
which simplifies to "exists s > t such that (t,s) is empty in D" -- i.e., s is the immediate successor of t.

**Verdict**: NON-ISSUE. `truth_at ... bot` is definitionally `False`. The argument is correct.

---

## Issue 3: Does C4 Give Density in the Correct Sense?

**Concern**: The claim that C4 with gamma=T, delta=bot gives a domain point between any two domain points.

**Analysis**: The codebase's C4 (from ChronicleTypes.lean line 443):

```lean
def Chronicle.c4 (chi : Chronicle) : Prop :=
  forall x y : Rat, x in chi.dom -> y in chi.dom -> x < y ->
    forall (gamma delta : Formula),
      (Formula.untl delta gamma).neg in chi.f x ->
      delta in chi.f y ->
      exists z in chi.dom, x < z /\ z < y /\ gamma.neg in chi.f z
```

Note the naming convention carefully. In the codebase's `untl(event, guard)` = Burgess's `U(event, guard)`, C4 says:

For `(untl delta gamma).neg in f(x)` and `delta in f(y)` with `x < y`, there exists `z` in dom between them with `gamma.neg in f(z)`.

This is: `neg(U(delta, gamma)) in f(x)` and `delta (the EVENT) in f(y)`.

For the density argument, we want gamma = bot, delta = T:
- Need: `neg(U(T, bot)) in f(x)` = `neg(next(T)) in f(x)` = "x does NOT have an immediate successor in the chronicle's sense" -- i.e., F'T in f(x) (there's always something between x and any future point).
- Need: `T in f(y)` -- always true (T is in every MCS).
- Conclusion: exists z between x and y with `bot.neg in f(z)` = `T in f(z)` -- which is trivially true.

So C4 does guarantee a domain point z between x and y, provided `neg(untl T bot) in f(x)`.

But `neg(untl T bot)` is NOT the same as `F'T`. Let me compute:
- `F'T = neg(G'(neg(T))) = neg(weak_future(neg(T)))` -- this is the Burgess notation
- Actually, from the Burgess paper p.368: `F'alpha = neg(G'(neg(alpha)))` where `G'alpha = U(T, alpha)` = `untl(T, alpha)` in the codebase (event=T, guard=alpha).

Wait, I need to be more careful. Burgess defines (p.367):
- `G'alpha` for `U(T, alpha)` = "for some time going to be uninterruptedly alpha"

In the codebase convention: `G'(alpha) = untl(T, alpha)` where T = `bot.imp bot`.

So `neg(G'(bot))` = `neg(untl(T, bot))` = `neg(next(T))`.

And `F'T = neg(G'(neg(T)))` = `neg(untl(T, neg(T)))`.

These are DIFFERENT formulas:
- `neg(untl(T, bot))` = "no immediate successor exists" 
- `neg(untl(T, neg(T)))` = `neg(untl(T, bot))` -- wait, `neg(T) = (bot.imp bot).imp bot = bot`, so actually `neg(T) = T.neg = (bot.imp bot).imp bot`.

Hmm, `T = bot.imp bot` and `neg(T) = T.imp bot = (bot.imp bot).imp bot`. Is this logically equivalent to `bot`? In classical logic, `neg(T)` IS `bot`. And in an MCS, `neg(T) in M iff T notin M`, but T is always in an MCS (it's a theorem). So `neg(T) notin M` for any MCS M. So `neg(T)` is equivalent to `bot` at the MCS level.

So `F'T = neg(G'(neg(T)))` = `neg(untl(T, neg(T)))`. Since `neg(T)` behaves like `bot`:
- `untl(T, neg(T))` at t = exists s > t such that T(s) and neg(T) on (t,s) = exists s > t with False on (t,s) = exists immediate successor. 
- This is the same as `untl(T, bot)` = `next(T)`.

Wait, that's not right either. `untl(T, neg(T))`: event = T, guard = neg(T). Truth: exists s > t with T(s) [always true] and neg(T)(r) for all r in (t,s). Since neg(T) is never true in any model (T is always true), this requires (t,s) empty. So `untl(T, neg(T))` is semantically equivalent to `next(T)` = `untl(T, bot)`.

Actually, `neg(T)` is NOT `bot` syntactically -- they are different formulas. But in any MCS, `neg(T) in M` iff `T notin M`, which never happens. And under truth_at, `truth_at ... neg(T) = truth_at ... (T.imp bot) = (truth_at ... T -> False) = (True -> False) = False`.

So semantically `neg(T)` and `bot` agree. And `neg(untl T neg(T))` is semantically the same as `neg(untl T bot)`.

But they are SYNTACTICALLY different formulas. In the MCS world, `neg(T) in f(x)` is impossible (since T is in every MCS). So `untl(T, neg(T)) in f(x)` iff there exist witnesses in the MCS sense. The MCS-level equivalence between `neg(T)` and `bot` would need to be established through the proof system (it's derivable: from T derive neg(neg(T)), etc.).

For the density argument via C4, we need `neg(untl(T, bot)) in f(x)` (which is `neg(next(T)) in f(x)`, meaning x has no immediate successor in the "modal" sense). If we're in the dense case where `F'T in f(x)`, then `F'T` = `neg(G'(neg(T)))` which is semantically equivalent to `neg(next(T))` but syntactically different. The MCS f(x) would need to contain exactly `neg(untl delta gamma)` for the right delta, gamma to trigger C4.

**Key question**: Is `F'T` equivalent to `neg(next(T))` in the BX proof system?

`F'T = neg(G'(neg(T)))`. And `G'alpha = untl(T, alpha)`. So `G'(neg(T)) = untl(T, neg(T))`.

Now `next(T) = untl(T, bot)`. We need: `untl(T, neg(T)) <-> untl(T, bot)` in BX.

Forward: `untl(T, neg(T)) -> untl(T, bot)`. Use BX2G (left_mono_until_G): `G(neg(T) -> bot) -> (untl(T, neg(T)) -> untl(T, bot))`. We need `G(neg(T) -> bot)`. Since `neg(T) -> bot` is a theorem (`neg(T) = T -> bot`, so `(T -> bot) -> bot` is double negation, which IS a theorem by Peirce), we get `G(neg(T) -> bot)` by temporal generalization. So this direction works.

Backward: `untl(T, bot) -> untl(T, neg(T))`. Use BX2G: `G(bot -> neg(T)) -> (untl(T, bot) -> untl(T, neg(T)))`. We need `G(bot -> neg(T))`. Since `bot -> neg(T)` is ex falso (a theorem), `G(bot -> neg(T))` holds by temporal generalization. So this direction works too.

Therefore `F'T` and `neg(next(T))` are BX-equivalent, and in any MCS, `F'T in M iff neg(next(T)) in M`. C4 applies correctly.

**Verdict**: NON-ISSUE after careful analysis. C4 does give density in the correct sense when `F'T` (equivalently `neg(next(T))`) is in every domain MCS.

---

## Issue 4: Can F'T Be Propagated to ALL Domain Points?

**Concern**: If the dense case adds `F'T` to A0, can we ensure `F'T` is in f(x) for ALL domain points x, not just the root?

**Analysis**: This is a CRITICAL issue. The proposal says "add F'T as axiom" so that `G(F'T)` and `H(F'T)` are theorems. But:

1. We are NOT adding F'T to the BX axiom system permanently. We are using it only in the dense case of the completeness proof.

2. The dense case starts with: `neg(phi)` is consistent, and we want to show `neg(phi)` is satisfiable. The case split is based on whether `neg(phi) /\ F'T /\ P'T` is consistent OR `neg(phi) /\ G'bot /\ H'bot` is consistent.

3. If `neg(phi) /\ F'T /\ P'T` is consistent, we extend to an MCS A0 containing all three. Then `F'T in A0`.

4. But the chronicle construction starts from A0 and builds domain points. At those points, f(x) are new MCSs constructed by the chronicle. We need `F'T in f(x)` for ALL x.

5. Having `F'T in A0` does NOT give `F'T in f(x)` for arbitrary domain x. The chronicle's `limit_forward_G` gives: if `G(psi) in f(x)` and `y > x` is in domain, then `psi in f(y)`. But this propagates FROM f(x) TO f(y), not backwards.

6. To get `F'T` at ALL domain points, we would need `G(F'T) /\ H(F'T) in A0`. Is `neg(phi) /\ G(F'T) /\ H(F'T)` consistent?

**Critical flaw**: `G(F'T)` says "at all future times, there's no immediate successor." But this is NOT a theorem of BX -- it's a frame condition of dense orders. Adding it to A0 requires proving consistency with `neg(phi)`.

Consider `phi = G'bot` (= "I have an immediate successor"). Then `neg(phi) = neg(G'bot) = F'T` ("no immediate successor"). So `neg(phi) = F'T`, and `neg(phi) /\ G(F'T) = F'T /\ G(F'T)`. Is this consistent?

`F'T /\ G(F'T)` says: "no immediate successor now, and at all future times, no immediate successor." This IS consistent (satisfied by Rat, for example). And `H(F'T)` adds "at all past times, no immediate successor" -- also consistent (again, Rat).

But what about `phi = F'T -> G(G'bot)`? Then `neg(phi) = F'T /\ neg(G(G'bot)) = F'T /\ F(F'T)`. Now `neg(phi) /\ G(F'T)`: is `F'T /\ F(F'T) /\ G(F'T)` consistent? `G(F'T)` says "all future times have no immediate successor." `F(F'T)` = `F(neg(next(T)))` says "there exists a future time with no immediate successor." Since `G(F'T)` implies `F(F'T)` (by seriality), this is just `F'T /\ G(F'T)`, which is consistent.

Actually, the real risk is more subtle. What if `neg(phi)` is consistent but `neg(phi) /\ G(F'T)` is NOT? This would happen if `neg(phi)` implies `F(G'bot)` -- "eventually there IS an immediate successor." Then `G(F'T)` (no immediate successors ever) would contradict this.

Example: `phi = neg(F(next(T)))`. Then `neg(phi) = F(next(T))` = "eventually there's a point with an immediate successor." Now `neg(phi) /\ G(F'T) = F(next(T)) /\ G(F'T)`. But `G(F'T)` means "at all future times, no immediate successor" which contradicts `F(next(T))` ("at some future time, there IS an immediate successor"). So `neg(phi) /\ G(F'T)` is INCONSISTENT.

BUT: in this case, `neg(phi) /\ G'bot /\ H'bot` should be consistent (the discrete case). The question is whether the case split is EXHAUSTIVE.

**The real question**: For any consistent `neg(phi)`, is it the case that EITHER `neg(phi) /\ F'T /\ P'T` is consistent OR `neg(phi) /\ G'bot /\ H'bot` is consistent?

Equivalently: does `neg(phi)` imply `neg(F'T /\ P'T) \/ neg(G'bot /\ H'bot)`? No -- that's not right either. The case split needs to be exhaustive: every consistent formula falls into one case or the other.

Actually, the proposal might be: first check if `neg(phi) /\ G'bot` is consistent. If yes, use discrete case. If not, `neg(phi)` implies `neg(G'bot) = F'T` (in any MCS containing neg(phi)). Then use the dense case.

But this only gives `F'T in A0`, not `G(F'T) in A0`. And we showed above that `neg(phi) /\ G(F'T)` can be inconsistent even when `neg(phi) /\ F'T` is consistent.

**However**: maybe we don't NEED `F'T` at all domain points. Maybe we only need it at the root, and C4 together with the chronicle construction handles the rest. Let me reconsider.

The density of limit_dom is used in the ORIGINAL construction to prove `DenselyOrdered LimitDomSubtype`, which is needed for the Cantor isomorphism. If we DON'T use Cantor iso (which is the whole point of task 117), then we DON'T need global density.

For the natural inclusion approach (X subset Q), we need `F'T` to trigger C4 insertions that make the domain dense enough. But C4 only fires at points where `neg(untl delta gamma) in f(x)`. If `F'T in f(x)`, then `neg(next(T)) in f(x)`, and C4 can insert a point between x and any y > x in the domain with `T in f(y)` (always true). So having `F'T` at EVERY domain point means C4 inserts midpoints between ALL adjacent domain pairs, making the domain dense.

But the point is: we DON'T need the domain to be dense for the natural inclusion approach. The natural inclusion works for ANY countable sub-order of Q. The only reason to force density is if we want to use the Cantor isomorphism.

**Verdict**: MAJOR concern, but it may be a non-issue depending on how the case split is actually used. If the dense case requires `G(F'T)` in the root MCS (and this may be inconsistent with `neg(phi)`), then the case split has a gap. But if the dense case only needs `F'T` at the root and handles propagation through the chronicle construction, the gap might be fillable.

The deeper question is: WHY case-split at all? The natural inclusion approach (current plan) avoids this entirely.

---

## Issue 5: AddCommGroup Uniformity vs Formula-Level Uniformity

**Concern**: The uniformity argument is about the SEMANTIC MODEL (D is uniformly dense or discrete), but the chronicle is built BEFORE the truth lemma. Can we use semantic properties at the MCS level?

**Analysis**: This concern is actually less severe than it appears. The key insight from Mathlib is:

```lean
theorem LinearOrderedAddCommGroup.discrete_or_denselyOrdered
    (G : Type) [AddCommGroup G] [LinearOrder G] [IsOrderedAddMonoid G] [Archimedean G] :
    Nonempty (G ≃+o Z) ∨ DenselyOrdered G
```

This is a SEMANTIC fact about the model domain D, not a formula-level fact. The case split would happen at the META level of the completeness proof:

1. Given D with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`, `Archimedean D`:
2. Either D is isomorphic to Z (discrete case) or D is densely ordered (dense case).
3. In each case, construct the countermodel differently.

This is NOT about propagating formulas through MCSs. It's about choosing the right construction strategy based on properties of D.

But there's a problem: the completeness proof must work for ALL D satisfying the typeclass constraints. The current `valid` quantifies over `D : Type` with `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`. It does NOT include `[Archimedean D]`.

So the case split `D ≃+o Z ∨ DenselyOrdered D` is NOT available without adding `Archimedean D` to the validity definition or proving it from the existing constraints.

**Verdict**: The formula-level concern is a NON-ISSUE (the case split is semantic, not syntactic). But the missing `Archimedean` hypothesis is a REAL PROBLEM -- see Issue 7.

---

## Issue 6: Does the Discrete Case Actually Work?

**Concern**: In the discrete case (D iso Z or G'bot /\ H'bot in all MCSs), is the domain really order-isomorphic to Z? Can there be gaps?

**Analysis**: If the approach uses `D ≃+o Z` from Mathlib (the semantic case split), then D IS Z (up to ordered group isomorphism) and the countermodel is built over Z directly. The chronicle construction on Rat with D = Z would use Z's integer structure. This is clean.

If the approach uses the formula-level case split (G'bot /\ H'bot in MCSs), then the argument is more delicate. Having "immediate successor/predecessor" at every MCS point means the chronicle domain X has immediate successors/predecessors at every point. Combined with no endpoints (from seriality), X would need to be order-isomorphic to Z. This requires X to be:
1. Countable (yes, X subset Q)
2. Linearly ordered (yes)
3. No endpoints (yes, from seriality)
4. Every point has immediate successor and predecessor (from G'bot /\ H'bot in all MCSs)

A linear order with properties 2-4 and also CONNECTED (no gaps) is indeed isomorphic to Z. But could X have gaps? For example, could X = {..., -2, -1, 0, 1, 2, ...} union {..., 100, 101, 102, ...} with a gap between 2 and 100?

If there's a gap, then the interval (2, 100) in X is empty. But the seriality axioms give F(T) and P(T) at every point, so there exist future and past points in the domain from any point. The C5 construction ensures Until-witnesses exist. Could there be a "leap" where 2's successor is 100?

Actually no. If G'bot is in f(2), then `next(T) in f(2)`, meaning `untl(T, bot) in f(2)`. C5 then gives: there exists y > 2 in dom with T in f(y) (always true) and bot holds on all intermediate domain points in (2, y). Since bot is never in an MCS, this means there are NO intermediate domain points between 2 and y. So y is 2's immediate successor in the domain.

But C5 doesn't prevent y from being 100. The key question is whether the chronicle ensures that y is "close" to 2. In the Burgess construction over Rat, y is chosen to be 2 + 1 or similar. But the specific rational doesn't matter for the isomorphism to Z -- what matters is the ORDER structure.

If X = {..., -2, -1, 0, 1, 2, 100, 101, 102, ...}, this IS isomorphic to Z as an order (just relabel). The "gap" in the rational coordinates doesn't affect the order type. So the discrete case works regardless of the specific rational values in X.

**Verdict**: NON-ISSUE. The discrete case works. A countable linear order with no endpoints where every point has an immediate successor and predecessor is order-isomorphic to Z, regardless of gaps in the rational coordinates.

---

## Issue 7: The Archimedean Gap

**Concern**: Does adding `U(T,bot) <-> S(T,bot)` as axiom change what's provable? Is it sound?

**Analysis**: The axiom `U(T,bot) <-> S(T,bot)` says: "having an immediate successor iff having an immediate predecessor."

**Soundness**: In any `AddCommGroup D` with `IsOrderedAddMonoid D`:
- If t has an immediate successor s (i.e., (t,s) empty), then t has an immediate predecessor t - (s - t), since (t - (s-t), t) is the image of (t, s) under the translation y -> y - (s-t), and translations preserve emptiness of intervals. 
- The converse follows symmetrically.

So the axiom IS valid over all `AddCommGroup D` with `IsOrderedAddMonoid D`. Soundness is preserved.

**But**: the real concern is not the axiom itself, but the CASE SPLIT it enables. The proposal uses `U(T,bot) <-> S(T,bot)` to argue that D is UNIFORMLY discrete or UNIFORMLY dense. But "uniformly discrete" means `forall t, U(T,bot)(t)` -- every point has an immediate successor. And "uniformly dense" means `forall t, neg(U(T,bot))(t)` -- no point has an immediate successor.

The argument that "either every point has an immediate successor or no point does" is the REAL uniformity claim. This follows from:
- If some t has an immediate successor s, then s - t > 0 and (t, s) is empty.
- By translation, for any x, (x, x + (s-t)) is empty. So x has an immediate successor x + (s-t).
- Therefore if ANY point has an immediate successor, EVERY point does.

This is valid for ALL `AddCommGroup D` with `IsOrderedAddMonoid D`, regardless of Archimedean.

However, the next step -- "discrete implies D iso Z" -- DOES require Archimedean. Without Archimedean, D could be Z x Z lex, which has immediate successors everywhere but is NOT isomorphic to Z.

**CRITICAL**: The completeness proof for the discrete case needs `D ≃+o Z` to use the existing Int chain construction. If D is Z x Z lex:
- Every point has an immediate successor
- D is NOT isomorphic to Z
- The truth lemma for Until/Since may fail because witnesses exist at "infinitely far" successors

Wait -- does the current BX axiom system distinguish between Z and Z x Z lex? Is there a formula valid over Z but not over Z x Z lex (or vice versa)?

Actually, BX does NOT include discrete-specific axioms. The base BX system is sound over ALL linear orders. The discrete case of the completeness proof would be for a SEPARATE theorem `valid -> derivable` restricted to discrete frames or with additional axioms.

But the proposal seems to be about the BASE completeness theorem, not a discrete-specific one. The base theorem says: valid over ALL `AddCommGroup D` implies derivable in BX. The case split would be at the meta-level of the proof.

**The actual strategy would be**:

Given `neg(phi)` consistent in BX, build a countermodel over SOME D:
- If D can be chosen as Rat (dense): use Cantor iso approach
- If D can be chosen as Int (discrete): use Int chain approach

The base completeness theorem says: if phi is not BX-derivable, then phi is not valid (exists SOME D where phi fails). We only need ONE countermodel. So we choose D = Rat or D = Int based on the formula.

This works WITHOUT the uniformity axiom. The case split is: can we build a countermodel over Rat, or do we need Int? The uniformity axiom `U(T,bot) <-> S(T,bot)` is ALWAYS valid (over all D), so adding it doesn't change the valid formulas. But it also doesn't HELP with the case split, because the case split is about CHOOSING D, not about properties of a fixed D.

**Wait**: I think I misunderstood the proposal. Let me reconsider.

The proposal might be: for the base completeness proof, instead of extending limit_f to all of Q (the blocked approach), case-split on the root MCS A0:

Case 1: `F'T in A0` (= `neg(next(T)) in A0`). Then A0 "believes" there's no immediate successor. Use this to build a dense countermodel.

Case 2: `next(T) in A0` (= `G'bot in A0`). Then A0 "believes" there IS an immediate successor. Use this to build a discrete countermodel.

Since A0 is an MCS, exactly one of `F'T` or `next(T)` is in A0. This is exhaustive.

But the issue remains: in Case 1, does `F'T in A0` propagate to ALL domain points? And in Case 2, does `next(T) in A0` propagate to all domain points?

For Case 2: `next(T) in A0`. By BX4 (connect_future): `phi -> G(P(phi))`. So `next(T) -> G(P(next(T)))`. This means at all future times, P(next(T)) holds. But P(next(T)) means "at some past time, there was an immediate successor" -- NOT "at this time, there's an immediate successor."

To get `next(T)` at ALL future times, we'd need `G(next(T)) in A0`. But `G(next(T))` is NOT derivable from `next(T)` in BX (G doesn't distribute over arbitrary formulas without necessitation, and next(T) is not a theorem).

So the propagation issue affects BOTH cases.

**Verdict**: BLOCKING. The formula-level case split (F'T vs G'bot in A0) does not propagate to all domain points without additional work. The semantic-level case split (D dense or discrete) requires Archimedean, which `valid` doesn't assume. Either way, there's a gap.

**Suggested mitigation**: 
1. Add `[Archimedean D]` to the `valid` definition. This is arguably correct (all "natural" temporal orders -- Z, Q, R -- are Archimedean, and non-Archimedean groups like Z x Z lex are arguably not natural temporal domains). However, this would require re-proving all soundness results and is a significant change.
2. Alternatively, prove that any formula valid over all Archimedean ordered abelian groups is also valid over all ordered abelian groups (this would follow if every ordered abelian group embeds into an Archimedean one, which is FALSE -- Z x Z lex doesn't embed into R while preserving the group structure).
3. Or abandon the case split entirely and find a uniform approach.

---

## Issue 8: Modal Interaction with the Case Split

**Concern**: Does the modal part (Box, ShiftClosed) interact with the temporal case split?

**Analysis**: The ShiftClosed condition says: if sigma in Omega and Delta in D, then time_shift(sigma, Delta) in Omega. This is a condition on the SET of histories, not on individual histories.

The case split (dense vs discrete) is about the temporal order D. The modal box quantifies over all histories in Omega at the SAME time. Time-shift preservation (used for MF/TF soundness) uses the group structure (addition, subtraction) but does not depend on density or discreteness.

The modal axioms MF (`Box(phi) -> Box(G(phi))`) and TF (`Box(phi) -> G(Box(phi))`) are valid regardless of dense/discrete. Their soundness proofs use time_shift_preserves_truth, which works for any D with AddCommGroup + IsOrderedAddMonoid.

The case split does not interact with the modal axioms. The countermodel construction in both cases needs to produce a ShiftClosed Omega, but this is straightforward (use Set.univ, which is trivially ShiftClosed).

**Verdict**: NON-ISSUE. The modal part is orthogonal to the dense/discrete case split.

---

## Summary Table

| Issue | Concern | Verdict | Severity |
|-------|---------|---------|----------|
| 1 | Uniformity claim correct? | Correct, but Archimedean needed for case split | MAJOR |
| 2 | truth_at handles bot? | Yes, definitionally False | Non-issue |
| 3 | C4 gives density? | Yes, correctly | Non-issue |
| 4 | F'T propagates to all domain points? | NO -- G(F'T) may be inconsistent with neg(phi) | MAJOR |
| 5 | Semantic vs formula-level confusion? | Semantic case split is fine; formula-level is problematic | Minor |
| 6 | Discrete case works? | Yes, domain iso Z works | Non-issue |
| 7 | Archimedean gap | valid doesn't assume Archimedean; case split needs it | BLOCKING |
| 8 | Modal interaction? | None -- orthogonal | Non-issue |

---

## Critical Assessment

The case-split approach has TWO BLOCKING problems:

### Blocker A: The Archimedean Gap (Issue 7)

The Mathlib theorem `LinearOrderedAddCommGroup.discrete_or_denselyOrdered` requires `[Archimedean G]`, but the codebase's `valid` definition does not include this constraint. Non-Archimedean ordered abelian groups (like Z x Z lex) are neither isomorphic to Z nor densely ordered, yet are valid model domains.

**Impact**: The semantic-level case split "D iso Z or DenselyOrdered D" is not available without Archimedean. Adding Archimedean to `valid` is a significant architectural change touching soundness, validity, and all downstream proofs.

**Note**: For PRACTICAL purposes, all "natural" temporal orders are Archimedean (Z, Q, R are all Archimedean). And the BX axiom system is arguably complete for Archimedean ordered groups specifically. But FORMALLY, the current `valid` definition is broader, and the case split doesn't cover the full generality.

### Blocker B: Formula Propagation (Issue 4)

Even if the case split is valid, propagating `F'T` (dense case) or `G'bot` (discrete case) from the root MCS to ALL domain points requires `G(F'T)` or `G(G'bot)` in the root MCS. These are not BX theorems and may be inconsistent with `neg(phi)` for specific phi.

**Impact**: The chronicle construction builds MCSs at new domain points that may not inherit the density/discreteness property from the root. Without propagation, C4 may not trigger at all domain points, and the desired order structure of the domain is not guaranteed.

### Comparison to Current Plan (Natural Inclusion)

The current plan (natural inclusion X subset Q, extend limit_f to all of Q via Lindenbaum) avoids BOTH blockers:
- No Archimedean assumption needed (D = Q is Archimedean, but this is a CHOICE, not an assumption on validity)
- No formula propagation needed (the construction works for any order structure of X)

The current plan's blocker (forward_G at non-domain rationals) is a DIFFERENT problem, but it's a more tractable one that doesn't require architectural changes.

### Recommendation

**Do NOT pursue the case-split approach for the base completeness theorem.** The two blockers are fundamental, not implementational. Instead:

1. Continue with the natural inclusion approach (current plan Phase 4)
2. If the forward_G extension problem remains intractable, consider:
   a. Adding `[Archimedean D]` to `valid` (enables case split cleanly via Mathlib)
   b. Domain-restricted truth (Approach D1 from the extension research)
   c. Proving the Int chain coherence properties directly
3. Save the case-split approach for VARIANT completeness theorems (valid_dense, valid_discrete) where the frame conditions are explicit
