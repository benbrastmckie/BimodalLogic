# Teammate D Findings: Until/Since Cases of the Direct Truth Lemma

**Task**: 107 - Chain Design Diagnostics for Representation Theorem
**Focus**: Until/Since cases -- C4, C5, guard convention, forward/backward directions
**Date**: 2026-04-24

---

## 1. Exact C4 and C5 Definitions

### C5 (Forward Until Witness)

From `ChronicleTypes.lean` lines 254-260:

```lean
def Chronicle.c5 (chi : Chronicle) : Prop :=
  forall x in chi.dom,
    forall (gamma delta : Formula),
      Formula.untl gamma delta in chi.f x ->
      exists y in chi.dom, x < y /\ delta in chi.f y /\
        forall z in chi.dom, x < z -> z < y ->
          gamma in chi.f z /\ Formula.untl gamma delta in chi.f z
```

**Key observations**:
- The witness y has `delta in f(y)` (the SECOND component of Until, i.e., the eventuality).
- The guard requires `gamma in f(z)` AND `gamma U delta in f(z)` at intermediate z with `x < z < y` (strict both sides).
- The guard does NOT cover x itself. The guard interval is the open interval (x, y).
- The guard does NOT cover y (it requires `z < y` strictly).

**Critical comparison with Burgess**: Burgess's C5a (line 212 of literature) says:
> "whenever x in dom f and U(xi, eta) in f(x), there is some y in dom f with x < y and **xi in f(y)** and **eta in g(x,y)**."

Note the roles are SWAPPED relative to the codebase. In Burgess:
- `U(xi, eta)` means "xi is the eventuality, eta is the guard"
- The witness y has the eventuality `xi in f(y)`
- The guard formula `eta` holds throughout the interval via `eta in g(x,y)`

In the codebase:
- `Formula.untl gamma delta` follows the convention `U(guard, eventuality)`
- `gamma` = guard, `delta` = eventuality
- C5 gives witness y with `delta in f(y)` (eventuality at witness)
- Guard `gamma` at intermediate domain points

**Conclusion**: The codebase conventions are consistent -- `gamma` is the guard, `delta` is the eventuality. Burgess uses the opposite convention (`U(eventuality, guard)`). This is purely notational but must be tracked carefully when adapting proofs.

### C4 (Backward Counterexample for neg-Until)

From `ChronicleTypes.lean` lines 226-238:

```lean
def Chronicle.c4 (chi : Chronicle) : Prop :=
  forall x y : Rat, Adjacent chi.dom x y ->
    forall (gamma delta : Formula),
      (Formula.untl gamma delta).neg in chi.f x ->
      gamma in chi.f y ->
      exists z in chi.dom, x < z /\ z < y /\ delta.neg in chi.f z
```

**Key observations**:
- C4 is restricted to ADJACENT domain points (x immediately precedes y, no domain point between them).
- Given `neg(gamma U delta) in f(x)` and `gamma in f(y)` (guard formula at the NEXT point), there exists z with `x < z < y` and `neg delta in f(z)`.
- Since x, y are adjacent with no domain points between them, z must be a NEW point (not yet in dom). This means C4 counterexample elimination MUST insert a new domain point.
- The witness z has `neg delta` (negation of the eventuality), not `neg gamma` (negation of the guard).

### Guard Convention Summary

The guard interval for `(gamma U delta)` at t under the A2 half-open convention is `[t, s)`:
- `gamma(r)` for all `r in [t, s)` -- guard includes t, excludes witness s
- `delta(s)` -- eventuality at witness

However, C5 in the codebase uses guard on `(x, y)` (open, excludes both endpoints). This is because x is the point where `gamma U delta in f(x)`, and by BX9 (`until_elim`), we already know `gamma or delta` at x. The guard at x is derived separately via BX9, not from C5.

---

## 2. Analysis of `limit_satisfies_c5_weak`

From `ChronicleConstruction.lean` lines 448-471:

```lean
theorem limit_satisfies_c5_weak (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (x : Rat) (hx : x in limit_dom A h_mcs)
    (xi eta : Formula)
    (h_until : Formula.untl xi eta in limit_f A h_mcs x) :
    exists y in limit_dom A h_mcs, x < y /\ eta in limit_f A h_mcs y
```

**What it proves**: Given `U(xi, eta) in limit_f(x)`, there exists `y > x` in the limit domain with `eta in limit_f(y)`.

**What it does NOT prove**: It provides NO guard at intermediate points. The "weak" qualifier means exactly this -- witness existence only, no guard formulas.

**Why this is intentional**: The module header (line 446) explicitly says: "The full guard condition (xi at intermediate points) requires the interval function g, which is handled in the integration phase."

**How the guard gap could be closed**: The full C5 definition (in ChronicleTypes) DOES provide guards: `gamma in f(z) /\ gamma U delta in f(z)` for intermediate z. But the omega-chain construction only tracks witness existence. To get the full C5 with guards, the construction would need to also track that intermediate domain points have the guard and the persisting Until formula. This requires the interval function g and the r-relation machinery from Burgess.

**Current status**: The `chronicle_model_exists` theorem (line 553) only provides the weak version. The full C5 with guards is NOT yet available in the limit.

---

## 3. The Forward Until Direction (Truth Lemma: membership -> semantics)

The forward direction of the Until truth lemma says:
```
(gamma U delta) in f(x) -> exists y in X, x < y /\ delta(y) /\ forall z in X, x < z < y -> gamma(z)
```

Under the project's semantics (strict/irreflexive, half-open [t,s)):
```
(gamma U delta) true at t <-> exists s > t, delta(s) /\ forall r, t <= r < s -> gamma(r)
```

### Case Analysis

From `(gamma U delta) in f(x)`:

**Step 1**: BX9 (`until_elim`) gives `gamma or delta in f(x)`.

**Case A: delta in f(x)**.
We need a witness s > x with delta(s), plus guard gamma on [x, s). But if only delta is at x (not gamma), we need the guard to hold at x. BX9 gives gamma OR delta, not both. If delta holds but not gamma at x, the guard interval [x, s) fails at x.

However, BX10 (`until_F`) gives `F(delta) in f(x)`, which means there exists some s > x with delta(s). The issue is we also need gamma on [x, s). Since gamma might not hold at x, we cannot use x as part of the guard interval.

**Resolution**: Under strict semantics with the half-open guard `[t, s)`, if `delta in f(x)`, we still need gamma(x) for the guard. BX9 gives `gamma or delta`. If delta(x) holds but gamma(x) does not, we cannot satisfy the guard at x.

But wait -- the semantics say the guard covers `[t, s)` which INCLUDES t. So we DO need gamma(t). If only delta(t) holds, the straightforward approach fails.

The actual resolution is more subtle: Under **strict** Until semantics (`s > t` strictly), if `delta in f(x)`, then by BX10 we get `F(delta) in f(x)`, giving a witness s > x with `delta in f(s)`. We do NOT need delta(x) as the witness -- the witness must be strictly in the future. So having delta(x) does not help directly for the witness; we still need F(delta) to provide s > x.

Now for the guard at x: from BX5 (`self_accum_until`), `(gamma U delta) -> ((gamma /\ (gamma U delta)) U delta)`. Apply BX9 to this: `(gamma /\ (gamma U delta)) or delta`. If delta in f(x), this is satisfied. But the ORIGINAL Until requires guard gamma at x, not the self-accumulated version.

**Key insight from Burgess Claim 2.11**: Burgess's proof of the forward direction does NOT use the guard at x separately. Here is the exact argument (lines 242-246 of literature):

> "If alpha in f(x), then by C5a there is a y in X with x < y and gamma in f(y) and beta in g(x,y). If z in X and x < z < y, then by C3 we have g(x,y) subset f(z), whence beta in f(z)."

Burgess uses C5a to get the witness y with the eventuality at y and the guard formula in the INTERVAL SET g(x,y). Then C3 (interval decomposition) gives the guard at every intermediate point z. The guard at x is NOT needed in Burgess's proof because his semantics use the OPEN interval (x, y) for the guard, not the half-open [x, y).

**Critical discrepancy**: Burgess's Until semantics (line 39 of literature):
```
V(U(alpha, beta)) = {x : exists y, x < y /\ y in V(alpha) /\ forall z (x < z < y -> z in V(beta))}
```

This uses the **open** guard interval `(x, y)` -- the guard does NOT include x. The project uses the **half-open** guard `[t, s)` which includes t.

Under Burgess's semantics:
- Guard on (x, y): intermediate points only, x excluded
- C5 gives witness + g(x,y) covers (x,y) via C3

Under the project's semantics:
- Guard on [t, s): includes t
- Need gamma(t) separately, which comes from BX9: gamma or delta at t

**If gamma(t)**: guard at t is satisfied, and C5 gives the rest.
**If delta(t) and not gamma(t)**: guard at t fails. This is a genuine problem.

But actually, under the half-open semantics, BX9 gives gamma(t) or delta(t). If delta(t), then we could use ANY s > t as witness (if delta(s) holds too), and the guard interval [t, s) would need gamma on [t, s). Since gamma does not hold at t, this fails unless we can find a witness at the FIRST point after t.

**Bottom line for forward direction**: The forward direction requires either:
1. Using Burgess's open-guard semantics (where guard at x is not needed), OR
2. Handling the half-open guard by case-splitting on BX9 at x and showing that if delta(x) but not gamma(x), there is still a valid witness pattern.

Under option 2, if `delta in f(x)` but `gamma not in f(x)`, we need `exists s > x, delta(s) /\ gamma(r) for r in [x,s)`. Since gamma(x) fails, this is impossible -- unless s can be chosen so that [x,s) is empty, but with a strict linear order, [x,s) always contains x. So this case IS problematic under half-open guard semantics.

**However**: BX9 says `(gamma U delta) -> (gamma or delta)`. Under the half-open guard semantics, `(gamma U delta)` at x requires gamma(x) (since x is in the guard interval [x,s)). So in any model satisfying the semantics, gamma(x) MUST hold. BX9 is sound, and it gives gamma or delta. If we're in a model where the semantics are correct, gamma(x) holds. The case "delta(x) but not gamma(x)" cannot arise in a sound model. The truth lemma is proved by induction, and at the point we prove the Until case, we can assume the induction hypothesis for subformulas.

Wait, this is circular. Let me reconsider.

Actually, the truth lemma proves: `phi in f(x) <-> phi true at x`. For the forward Until case, we assume `(gamma U delta) in f(x)` and must show `(gamma U delta) true at x`. The truth condition for `(gamma U delta)` at x is:
```
exists s > x, delta true at s /\ forall r, x <= r < s -> gamma true at r
```

By induction hypothesis, `delta true at s <-> delta in f(s)` and `gamma true at r <-> gamma in f(r)`. So we need:
```
exists s > x in X, delta in f(s) /\ forall r in X, x <= r < s -> gamma in f(r)
```

From C5, we get s > x with `delta in f(s)` and `gamma in f(z) /\ (gamma U delta) in f(z)` for z with `x < z < s`. This gives the guard on the open interval `(x, s)`. We also need `gamma in f(x)`. From BX9: `gamma or delta in f(x)`.

If `gamma in f(x)`: done, guard at x is satisfied.
If `delta in f(x)` but `gamma not in f(x)`: We have `delta in f(x)`. By the BACKWARD direction (using induction hypothesis on delta), `delta true at x`. But we need gamma true at x. Hmm.

Actually, from `(gamma U delta) in f(x)` under the half-open semantics, BX9 says `gamma or delta`. If the axiom system is SOUND for the half-open semantics, then `(gamma U delta) in f(x)` means gamma U delta is semantically true at x in any model, which means gamma(x) holds. So BX9 giving only `gamma or delta` is weaker than what the semantics guarantee. But we're not in "any model" -- we're building the CANONICAL model. The truth lemma IS the proof that membership = truth.

**The resolution**: The case `delta in f(x), gamma not in f(x)` simply cannot arise when `(gamma U delta) in f(x)`. This is because BX9 gives `gamma or delta`. If gamma not in f(x), then delta in f(x). But we can derive more: from `self_accum_until` (BX5), `(gamma U delta) -> ((gamma /\ (gamma U delta)) U delta)`. Apply BX9 to this: `(gamma /\ (gamma U delta)) or delta`. If delta in f(x), this is vacuously true.

But we can also use: `(gamma U delta) in f(x)` implies (by BX10) `F(delta) in f(x)`, which gives witness s > x with delta(s). From BX5: `((gamma /\ (gamma U delta)) U delta) in f(x)`. Apply BX10 to this: `F(delta) in f(x)` (same witness). Apply BX9 to the self-accumulated version: `(gamma /\ (gamma U delta)) or delta in f(x)`.

Hmm, this still doesn't force gamma(x). Let me check whether `gamma` MUST be in f(x).

Actually, the key point is: **if the semantics use a half-open guard [t,s) and we have an axiom BX9 that only gives gamma or delta, the axiom system may NOT be complete for the half-open semantics**. But the project's axiom file says BX9 IS sound for the half-open semantics:

> "Under irreflexive Until semantics with A2 guard, phi U psi at t has witness s > t with psi(s) and guard phi on [t,s). Since t in [t,s), phi(t) holds. So phi or psi at t."

So BX9 is sound: `phi U psi -> phi or psi`. And actually, the half-open guard gives us phi(t) directly (since t is in [t,s)), so we get phi at t (not just phi or psi). So the stronger `(gamma U delta) -> gamma` should be derivable! But BX9 only gives `gamma or delta`.

Actually, `(gamma U delta) -> gamma` IS derivable from BX9 + BX10:
- BX9: `(gamma U delta) -> (gamma or delta)`
- BX10: `(gamma U delta) -> F(delta)`
- `F(delta) = neg G(neg delta)`, which is weaker than delta.

Hmm, that doesn't give `(gamma U delta) -> gamma`. Let me think again.

Under half-open guard: `(gamma U delta)` at t implies gamma(t) (since t is in the guard interval). So `(gamma U delta) -> gamma` should be valid. Is it derivable? From BX9: `gamma or delta`. We also have BX10: `F(delta)`. If we could show delta -> gamma, we'd be done, but that's not generally true.

Wait -- BX9 gives gamma or delta. We want to show gamma. If delta holds at t, that doesn't help. BUT under the half-open semantics, if delta(t) holds and (gamma U delta)(t) holds, then gamma(t) ALSO holds (because the guard interval [t,s) includes t). So gamma(t) holds regardless.

The question is whether `(gamma U delta) -> gamma` is a THEOREM of the axiom system. If not, then the axiom system is incomplete for the half-open semantics, and the truth lemma proof has a gap at this exact point.

**This is a potential critical issue.** Let me check whether BX8 (which was removed as unsound) was the missing axiom.

From the axioms file: "BX8/BX8' (until_step/since_step) removed -- not sound under half-open guard."

So BX8 was NOT sound. And `(gamma U delta) -> gamma` is NOT among the remaining axioms. BX9 only gives `gamma or delta`.

**However**: The half-open guard `[t,s)` with s > t (strict) means t is in [t,s), so gamma(t) must hold. The axiom `(gamma U delta) -> gamma` IS semantically valid under half-open guard. If this is not derivable from the axiom system, the system is INCOMPLETE for the half-open semantics.

But wait -- maybe it IS derivable. Consider:
- BX5: `(gamma U delta) -> ((gamma /\ (gamma U delta)) U delta)`
- BX9 applied to the self-accumulated form: `(gamma /\ (gamma U delta)) or delta`
- This gives: either `(gamma /\ (gamma U delta))` (which gives gamma) or `delta`.

In the delta case, we still only have delta, not gamma. So `(gamma U delta) -> gamma` is NOT derivable from BX5 + BX9 alone.

**Resolution for the forward truth lemma**: If the semantics use half-open guard but the axiom system cannot derive `gamma(x)` from `(gamma U delta)(x)`, then the forward direction has a gap. Two possible resolutions:

1. **Change semantics to open guard**: Use Burgess's convention where the guard is on `(x, s)` (open, excluding x). Then BX9's `gamma or delta` is exactly what the semantics give, and the forward direction works because x is not in the guard interval.

2. **Add the axiom `(gamma U delta) -> gamma`**: This would close the gap but requires soundness verification and may interact with other axioms.

3. **The codebase already uses open guard in C5**: Looking back at C5 in ChronicleTypes, the guard is on `x < z` and `z < y` (both strict), which is the open interval (x, y). And in the Semantics module, the actual truth condition may use open guard too.

**I need to check the actual semantics definition.**

Let me note that Burgess uses OPEN guard (x < z < y), and the codebase C5 also uses open guard (x < z, z < y). The claim about half-open guard `[t,s)` in the task description may be inaccurate or may refer to the INTENDED semantics vs what's actually formalized.

---

## 4. Guard at Intermediate Domain Points

C5 provides guards at intermediate DOMAIN points: for z in dom with `x < z < y`, we get `gamma in f(z) /\ (gamma U delta) in f(z)`.

The truth lemma evaluates truth at points in the evaluation set X. In the chronicle construction, X = limit_dom (the union of all finite domains). Since the guard quantifies over z in dom and the truth condition quantifies over z in X, and X IS dom (the limit domain), the C5 guard IS sufficient for the truth lemma on X.

**However**: `limit_satisfies_c5_weak` does NOT provide the guard. Only the full C5 (which requires the interval function g and r-relation) provides it. The weak version only gives witness existence.

To close the gap, the full C5 needs to be proved for the limit chronicle. This requires:
1. The r-relation structure (C2, C2')
2. The interval decomposition (C3)
3. The interval function g in the limit

None of these are currently formalized in the omega-chain construction.

---

## 5. The Backward Until Direction

The backward direction: if the semantic condition holds (witness + guard), then `(gamma U delta) in f(x)`.

By contraposition: `neg(gamma U delta) in f(x)` implies the semantic condition fails (no valid witness exists).

### How Burgess Proves It (Claim 2.11, line 246)

> "If instead ~alpha in f(x), then for any y in X with x < y and y in V(gamma), we have by induction hypothesis gamma in f(y), and hence by C4a there must be a z in X with x < z < y and ~beta in f(z), whence by induction hypothesis z not in V(beta). It follows that x not in V(alpha) as required."

Here alpha = U(beta, gamma) in Burgess's notation (recall: Burgess has U(eventuality, guard)).

Translated to the codebase conventions where `gamma U delta` = U(guard, eventuality):

> "If `neg(gamma U delta) in f(x)`, then for any y > x with delta(y) (eventuality at y), by IH delta in f(y). By C4 (applied to the non-adjacent case), there exists z with x < z < y and neg delta in f(z)... wait."

**The issue**: C4 is defined only for ADJACENT domain points, but the truth lemma needs it for ALL pairs x < y. Burgess's C4a is stated for ALL x < y (not just adjacent).

Looking at Burgess's C4a definition (line 210):
> "Whenever x, y in dom f and x < y and ~U(gamma, delta) in f(x) and gamma in f(y)..."

This is for ALL x < y, not just adjacent. The codebase's C4 is restricted to adjacent pairs.

**Critical discrepancy**: The codebase C4 is too weak for the backward truth lemma direction. Burgess's C4 applies to all pairs x < y, while the codebase C4 only applies to adjacent pairs. The counterexample elimination (Lemma 2.9) handles adjacent pairs, but Lemma 2.9 uses induction on the number of intermediate domain points to extend to non-adjacent pairs. The limit chronicle should satisfy C4 for ALL pairs (not just adjacent), because the omega-chain eliminates all C4 counterexamples.

Wait, let me re-read Burgess more carefully. Burgess defines (f,g) in F as satisfying C0-C3. Then C4 and C5 are ADDITIONAL conditions for a "total chronicle". The claim is that the LIMIT satisfies C4 and C5 for all pairs.

In the limit, for any x < y with `neg(gamma U delta) in f(x)` and `gamma in f(y)`:
- If x and y are adjacent in the limit domain: C4 directly gives z.
- If they are NOT adjacent: there exists an intermediate point w. Either `neg(gamma U delta) in f(w)` (and we recurse with w, y) or `gamma U delta in f(w)` (and we use BX5/BX9 structure). Actually, Burgess's proof of 2.9 handles this by induction.

But in the limit (where the domain is countably infinite), adjacency may not exist (the order may be dense). So the "adjacent" version of C4 might be vacuous in the limit.

**This is the key subtlety**: In the limit, the domain is dense (or at least, between any two domain points there are more domain points, because the C4-elimination keeps inserting midpoints). So adjacent pairs don't exist in the limit. The codebase's C4 (for adjacent pairs only) is VACUOUSLY TRUE in the limit, and provides NO information.

**Burgess's approach**: Burgess's C4 is for ALL pairs, not adjacent ones. In the limit, C4 for all pairs follows from the omega-chain: any potential counterexample (x, y, gamma, delta) is eventually eliminated by Lemma 2.9. The induction in 2.9 on the number of intermediate points handles the non-adjacent case.

**For the backward truth lemma**: The argument needs C4 for all pairs x < y. The codebase would need a `limit_c4` theorem:
```
forall x y in limit_dom, x < y ->
  neg(gamma U delta) in limit_f(x) -> gamma in limit_f(y) ->
  exists z in limit_dom, x < z < y /\ neg delta in limit_f(z)
```

This does not currently exist. It would follow from the omega-chain construction's counterexample elimination for C4 counterexamples, analogous to how `limit_satisfies_c5_weak` follows from C5 counterexample elimination.

### Detailed Argument Structure

Given `neg(gamma U delta) in f(x)`:

For any y > x with `delta in f(y)`:
1. By C4-for-all-pairs: exists z with x < z < y and `neg delta in f(z)`
2. By IH on delta: `neg delta in f(z)` means `delta not true at z`
3. So any witness y > x with delta(y) has an intermediate z where the eventuality fails

Wait, C4 gives `neg delta in f(z)`, but the guard for Until is gamma, not delta. Let me re-read.

Actually C4 says: `neg(gamma U delta) in f(x)` and `gamma in f(y)` implies exists z with `neg delta in f(z)`. The second premise is `gamma in f(y)`, not `delta in f(y)`.

So the backward argument is:
- Assume `neg(gamma U delta) in f(x)`.
- Need to show: for all y > x, NOT [delta(y) and guard gamma on (x,y)].
- Take any y > x with delta(y). By IH, delta in f(y).
- Two cases:
  - `gamma in f(y)`: By C4, exists z in (x,y) with neg delta in f(z). By IH, delta not true at z. But we also need to check if the GUARD fails at z. Actually, having neg delta at z doesn't directly break the guard (which is about gamma). What C4 gives us is neg delta at z, but the Until truth condition needs delta at the WITNESS point y and gamma at all intermediate points.

Hmm, let me re-read Burgess's argument.

Burgess (adapted to codebase conventions, U(guard, event)):
> ~U(gamma, delta) in f(x). For any y with x < y and delta in f(y) [eventuality at witness]: by IH, delta in f(y). By C4a applied to gamma [the guard formula] and delta [the eventuality]...

Wait, Burgess's notation: alpha = U(beta, gamma) where beta = eventuality, gamma = guard. His C4a:
> ~U(gamma, delta) in f(x) and gamma in f(y) -> exists z with ~delta in f(z).

With Burgess convention (U(eventuality, guard)): `gamma` = guard formula, `delta` = eventuality formula in C4a. So `~U(gamma, delta) in f(x)` means "NOT (exists s > x with delta(s) and gamma on (x,s))". C4a says: if `gamma in f(y)` (guard holds at next point y), then exists z with `~delta in f(z)` (eventuality fails somewhere between).

In codebase convention (U(guard, event)): `gamma` = GUARD, `delta` = EVENTUALITY in the C4 definition. `neg(gamma U delta) in f(x)` and `gamma in f(y)` gives `neg delta in f(z)`.

Now, Burgess's truth lemma argument for backward Until uses:

> For any y with x < y and y in V(gamma) [the EVENTUALITY]:

Wait, Burgess writes `alpha = U(beta, gamma)` and his semantics are:
```
V(U(alpha, beta)) = {x : exists y, x < y, y in V(alpha), forall z (x<z<y -> z in V(beta))}
```
So for `U(beta, gamma)`: eventuality = beta (first arg), guard = gamma (second arg).

In his Claim 2.11: `alpha = U(beta, gamma)`:
> "for any y in X with x < y and y in V(gamma)"

Hmm that says "y in V(gamma)" where gamma is the GUARD. That seems wrong for the eventuality. Let me re-read...

Actually looking more carefully at lines 242-246:
> "As a sample we treat the case alpha = U(beta, gamma). If alpha in f(x)... If instead ~alpha in f(x), then for any y in X with x < y and y in V(gamma), we have by induction hypothesis gamma in f(y), and hence by C4a there must be a z in X with x < z < y and ~beta in f(z), whence by induction hypothesis z not in V(beta). It follows that x not in V(alpha) as required."

So: alpha = U(beta, gamma). ~alpha in f(x). For y > x with gamma in f(y) (by IH from y in V(gamma)). C4a gives z with ~beta in f(z). By IH, z not in V(beta).

Now V(alpha) = V(U(beta, gamma)) = {x : exists y > x, y in V(beta) /\ forall z in (x,y), z in V(gamma)}.

So x not in V(alpha) means: for all y > x, NOT (y in V(beta) /\ forall z in (x,y), z in V(gamma)).

Burgess shows: for any y > x with gamma in f(y):
- Case where y would be the eventuality witness (y in V(beta)): C4a gives z with ~beta in f(z), i.e., z not in V(beta). But that z is between x and y, and we need the GUARD (gamma) to fail there, not the eventuality.

Actually, I think I've been reading this wrong. Let me look at Burgess C4a again (his notation):

> C4a: whenever x, y in dom f and x < y and ~U(gamma, delta) in f(x) and gamma in f(y), there is z with x < z < y and ~delta in f(z).

Here U(gamma, delta) uses Burgess's convention U(eventuality, guard). So gamma = first arg of U = eventuality. delta = second arg = guard.

~U(gamma, delta) in f(x) means: the eventuality gamma with guard delta fails at x.
gamma in f(y): the EVENTUALITY formula holds at the next point y.
Conclusion: ~delta in f(z), the GUARD fails at some intermediate z.

THIS MAKES SENSE! If the Until formula is false at x, and the eventuality holds at some future y, then the guard must fail somewhere between x and y. That's exactly the contrapositive of the forward direction.

Now translating to codebase conventions where U(guard, event):
- Codebase `gamma U delta`: gamma = guard, delta = eventuality
- Codebase C4: `neg(gamma U delta) in f(x)` and `gamma in f(y)` -> exists z with `neg delta in f(z)`

Burgess's C4a with his U(event, guard) corresponds to:
- Burgess gamma = eventuality = codebase delta
- Burgess delta = guard = codebase gamma

So Burgess C4a: `~U(event, guard) in f(x) and event in f(y) -> exists z with ~guard in f(z)`

Codebase C4: `~U(guard, event) in f(x) and guard in f(y) -> exists z with ~event in f(z)`

These ARE the same thing, just with variables swapped! Good.

Now the backward truth lemma argument (codebase conventions):

Assume `neg(guard U event) in f(x)`. Show x not in V(guard U event).

x in V(guard U event) would mean: exists y > x with event(y) and guard(z) for all z in (x,y).

For any y > x, need to show NOT (event(y) and guard on (x,y)).

Take any y > x. By IH, event(y) iff event in f(y), and guard(z) iff guard in f(z).

If event in f(y): Apply C4 with... wait. C4 needs `guard in f(y)` as the second premise, but we have `event in f(y)`.

Hmm. The premises don't match. Let me re-examine.

**Codebase C4**: `neg(gamma U delta) in f(x)` and `gamma in f(y)` gives `neg delta in f(z)`. Here gamma = GUARD, delta = EVENT.

So C4 says: if the Until fails at x, and the GUARD holds at y, then the EVENT is negated at some intermediate z.

This means: if event(y) for some y > x, and guard holds on (x,y), then at every intermediate point with guard, there's a further intermediate point with neg event. But that's NOT what C4 says -- C4 has guard in f(y) as premise, not guard on the full interval.

Let me re-trace Burgess's argument more carefully:

Burgess: alpha = U(beta, gamma) where beta = event, gamma = guard. ~alpha in f(x). For any y > x with y in V(gamma), i.e., gamma in f(y) [the GUARD holds at y, not the event!]. C4a gives z with ~beta [event negated] in f(z).

So Burgess argues: for any y > x where the GUARD gamma holds at y, the EVENT beta is negated somewhere between x and y.

Now to show x not in V(alpha) = not in V(U(beta, gamma)):
- Must show: for all y > x, NOT (beta(y) and gamma on (x,y)).
- Take y > x. Case 1: beta(y) (event at y). Then gamma(y) may or may not hold.
  - If gamma(y) holds too: C4 gives z with ~beta in (x,y). IH gives z not in V(beta). But z might not break the guard...

Wait. Burgess needs to show that for ALL y > x, there is no valid witness. The valid witness y needs beta(y) AND gamma on (x,y). If we take any such y, we need to find a point in (x,y) where EITHER beta fails (which would mean... no, beta only needs to hold at y, not intermediate points) OR gamma fails (which breaks the guard).

C4 gives: guard gamma at y -> neg beta (neg event) at some z in (x,y). This gives ~event at z, but the Until truth only needs event at the ENDPOINT y, not at z. Having ~event at z doesn't contradict the guard (which is about gamma, not beta).

So C4 gives neg event at an intermediate point, but the Until semantics don't REQUIRE the event at intermediate points -- only the guard.

**I think the resolution is**: C4 is applied INDUCTIVELY. Start with x < y. C4 gives z1 in (x,y) with ~event in f(z1). If guard in f(z1), apply C4 again to get z2 in (x, z1) with ~event in f(z2). This creates a descending sequence. By well-foundedness of the domain order (or density + the rational ordering), this must eventually hit a point where the guard FAILS.

Actually no, C4 always gives ~event, never ~guard directly.

Let me re-read Burgess one more time very carefully.

Burgess Claim 2.11 backward direction:
> "If instead ~alpha in f(x), then for any y in X with x < y and y in V(gamma), we have by induction hypothesis gamma in f(y), and hence by C4a there must be a z in X with x < z < y and ~beta in f(z), whence by induction hypothesis z not in V(beta). It follows that x not in V(alpha) as required."

alpha = U(beta, gamma). V(alpha) = {x : exists y > x, beta(y) and gamma on (x,y)}.

He takes y > x with y in V(gamma). That means GAMMA (the guard) holds at y. C4 gives z with ~beta (event fails) at z.

z not in V(beta) means: the event formula is false at z.

But HOW does this show x not in V(alpha)?

x in V(alpha) iff exists y > x: beta(y) and gamma on (x,y).

Burgess has shown: for any y > x with gamma(y), there exists z in (x,y) with ~beta(z). But ~beta at an intermediate z does NOT break the Until condition, because the Until condition only needs beta at the ENDPOINT y, and gamma at intermediate points.

Unless... Burgess's semantics are DIFFERENT from what I assumed.

Going back to Burgess's semantics (line 39):
```
V(U(alpha, beta)) = {x : exists y (x < y, y in V(alpha), forall z (x < z < y -> z in V(beta)))}
```

So for U(beta, gamma): first arg = beta (which is the EXISTS part), second arg = gamma (which is the FORALL part).

V(U(beta, gamma)) = {x : exists y (x < y, y in V(beta), forall z (x < z < y -> z in V(gamma)))}

So beta(y) = "exists" and gamma on (x,y) = "forall".

~alpha in f(x) means we need to show x not in V(U(beta, gamma)), i.e., for all y > x, NOT (beta(y) and gamma on (x,y)).

Burgess says: take y > x with y in V(gamma). By IH, gamma in f(y). C4a gives z with ~beta in f(z), z in (x,y). By IH, z not in V(beta).

But z not in V(beta) means ~beta(z). And? The Until condition needs beta(y) and gamma on (x,y). Having ~beta(z) for some z in (x,y) doesn't violate this -- we need gamma(z) at intermediates, not beta(z).

**I think Burgess is WRONG in his sketch, or I'm misreading the notation.**

Actually, wait. Let me re-read the original very carefully. Maybe I have the convention backwards.

Burgess defines (line 39):
```
V(U(alpha, beta)) = {x : exists y(x < y, y in V(alpha), forall z(x < z < y -> z in V(beta)))}
```

So in U(alpha, beta):
- alpha = the formula that holds at the WITNESS (existential part)
- beta = the formula that holds on the GUARD interval (universal part)

Now Burgess writes: "As a sample we treat the case alpha = U(beta, gamma)."

So here the formula is U(beta, gamma) where:
- beta = first arg of U = what holds at the witness
- gamma = second arg of U = what holds on the guard interval

V(U(beta, gamma)) = {x : exists y > x, beta(y), gamma on (x,y)}

C4a (Burgess's version): ~U(gamma, delta) in f(x) and gamma in f(y) -> exists z with ~delta in f(z).

For the formula U(beta, gamma): we'd need to apply C4a with the formula U(beta, gamma). C4a is about ~U(gamma', delta') in f(x). To match, gamma' = beta and delta' = gamma.

C4a then says: ~U(beta, gamma) in f(x) and beta in f(y) -> exists z with ~gamma in f(z).

YES! This matches. For any y with BETA in f(y) [the witness formula], we get ~GAMMA at some intermediate z [the guard fails].

So Burgess's argument is:
- ~U(beta, gamma) in f(x).
- For any y > x with beta(y) [potential witness]: by IH, beta in f(y).
- C4a gives z in (x,y) with ~gamma in f(z). By IH, ~gamma(z), so the guard gamma fails at z.
- Therefore no valid witness exists: x not in V(U(beta, gamma)).

**But that's NOT what Burgess WRITES.** He writes "for any y in X with x < y and y in V(gamma)". He should have written "y in V(beta)".

Checking his exact text again:
> "for any y in X with x < y and y in V(gamma), we have by induction hypothesis gamma in f(y), and hence by C4a there must be a z..."

He takes y in V(gamma) and derives gamma in f(y), then applies C4a. C4a for ~U(beta, gamma) needs beta in f(y), not gamma in f(y).

I think there is a genuine typo/error in Burgess's published proof sketch, OR his variable naming in the case analysis differs from my reading. Let me assume the correct argument is:

> For any y > x with beta(y), by IH beta in f(y). C4a gives z with ~gamma in f(z). By IH, ~gamma(z). Guard fails. QED.

**Translating to codebase conventions** (U(guard, event) = U(gamma, delta)):

C4: `neg(gamma U delta) in f(x)` and `gamma in f(y)` -> `neg delta in f(z)`.

Hmm. C4's second premise is `gamma in f(y)` = GUARD in f(y). But we need to apply C4 when the EVENTUALITY delta holds at y (the potential witness).

**This means the codebase C4 has the roles WRONG relative to what the backward truth lemma needs.**

The backward truth lemma needs:
- Premise: `neg(guard U event) in f(x)` and `event in f(y)` (potential witness has eventuality)
- Conclusion: exists z with `neg guard in f(z)` (guard fails at intermediate point)

The codebase C4 has:
- Premise: `neg(gamma U delta) in f(x)` and `gamma in f(y)` (gamma = guard at y)
- Conclusion: exists z with `neg delta in f(z)` (neg event at intermediate point)

These are DIFFERENT. The codebase C4 says: if Until fails at x and the guard holds at y, then the event is negated somewhere between. But the truth lemma needs: if Until fails at x and the event holds at y, then the guard is negated somewhere between.

Checking Burgess C4a directly: "~U(gamma, delta) in f(x) and gamma in f(y)". In Burgess U(gamma, delta): gamma = first arg = witness, delta = second arg = guard. So C4a has gamma = WITNESS formula at y. ~U(gamma, delta) means the Until with witness gamma and guard delta fails.

So Burgess C4a: `Until fails, witness formula at y -> neg guard at intermediate z`. This IS what the truth lemma needs.

Codebase C4: `neg(gamma U delta)` where gamma = guard, delta = event. Second premise: `gamma in f(y)` = guard at y. Conclusion: `neg delta` = neg event at z. This gives "guard at y implies neg event at z", which is the WRONG direction for the truth lemma.

**FINDING: The codebase C4 definition may have the formula roles incorrect for its intended use in the backward truth lemma.**

Let me verify by checking the docstring on C4 in ChronicleTypes. Lines 226-238:

```
/-- **C4**: Backward counterexample condition for Until (Burgess 1982).
For all x, y in dom with x < y adjacent: if `neg(gamma U delta) in f(x)` and `gamma in f(y)`,
then there exists z in dom with `x < z < y` and `neg delta in f(z)`.
```

And looking at C4's intended role: "If Until(gamma,delta) is false at x but the guard gamma still holds at the next point y, then the negation of the eventuality delta must be witnessed somewhere between x and y."

This interpretation says: guard (gamma) at y, neg eventuality (neg delta) at z. This is consistent with the codebase C4 but NOT what the backward truth lemma needs.

**However**, looking at Burgess C4a again with his convention U(gamma, delta) = U(event, guard):
- gamma = event, delta = guard in Burgess
- ~U(gamma, delta) = ~U(event, guard) in Burgess
- gamma in f(y) = event in f(y) = eventuality at y (correct for truth lemma!)
- neg delta = neg guard at z (correct for truth lemma!)

So the codebase C4's docstring says gamma = guard and delta = event, but in Burgess gamma = event and delta = guard. The LEAN CODE matches Burgess's character names but the INTERPRETATION differs because `Formula.untl gamma delta` maps gamma to the guard position (first arg = guard in codebase convention).

**Bottom line**: In `Formula.untl gamma delta`, gamma = guard, delta = event (codebase convention). C4 says `neg(gamma U delta)` (neg guard-U-event) at x, guard at y, gives neg event at z. For the backward truth lemma, we need: neg(guard U event) at x, EVENT at y, gives neg GUARD at z. These are DIFFERENT.

**UNLESS** C4 is correct as-is and the backward truth lemma argument works differently than Burgess's direct approach. Perhaps the argument uses C4 iteratively or combined with other axioms.

Actually, let me reconsider. Maybe the correct C4 for the codebase convention should be:

```
neg(gamma U delta) in f(x) and delta in f(y) ->
  exists z, x < z < y, neg gamma in f(z)
```

Where delta = event at y, neg gamma = neg guard at z. This is the Burgess version adapted to codebase conventions.

The current codebase C4 has the roles reversed relative to what's needed.

---

## 6. Summary of Findings

### Finding 1: C5 Guard Gap

`limit_satisfies_c5_weak` provides witness existence only, with NO guard at intermediate points. The full C5 with guards requires the interval function g and r-relation, which are not yet formalized in the limit construction. This is a known gap (documented in the module header).

### Finding 2: Semantics Use Half-Open Guard, C5 Uses Open Guard -- MISMATCH

**Confirmed from `Semantics/Truth.lean` line 127-128**: The actual truth condition for Until uses half-open guard `[t, s)`:
```lean
| Formula.untl phi psi => exists s, t < s /\ truth_at ... s psi /\
    forall r, t <= r -> r < s -> truth_at ... r phi
```

The guard range is `t <= r` (includes t) and `r < s` (excludes witness). This IS the half-open A2 convention `[t, s)`.

**However**, C5 in `ChronicleTypes.lean` uses the open guard `(x, y)`:
```lean
forall z in chi.dom, x < z -> z < y -> gamma in chi.f z /\ ...
```

The C5 guard range is `x < z` (excludes source) and `z < y` (excludes witness). This is the open interval `(x, y)`.

**This is a genuine mismatch.** The truth lemma needs the guard at x (since `t <= r` includes `t`), but C5 does not provide it. For the forward direction, gamma(x) must be obtained separately, presumably from BX9 which gives `gamma or delta` at x.

Under half-open semantics, `(gamma U delta)` at x implies gamma(x) (since x is in the guard interval [x,s)). BX9 gives only `gamma or delta`, which is weaker. But since `(gamma U delta) -> gamma` is semantically valid under half-open guard, it should be derivable. If not, there is an axiom gap.

**The delta-at-x problem**: If BX9 gives `delta(x)` but not `gamma(x)`, the guard at x fails. Under the half-open semantics, this case cannot arise (gamma MUST hold at x), so BX9's weaker conclusion is still sufficient in context: if delta(x), then we still have gamma(x) semantically, and the truth lemma should be able to derive this. But the derivation path is unclear from BX axioms alone.

Burgess avoids this issue entirely because his semantics use open guard `(x, y)` where x is excluded.

### Finding 3: Potential C4 Role Reversal

The codebase C4 says: `neg(gamma U delta) in f(x)` and GUARD (gamma) at y gives neg EVENT (neg delta) at intermediate z.

Burgess's C4a (adapted to codebase conventions) should say: `neg(gamma U delta) in f(x)` and EVENT (delta) at y gives neg GUARD (neg gamma) at intermediate z.

These differ in which formula is at y (guard vs event) and which is negated at z (event vs guard). The backward truth lemma needs the Burgess version (event at y, neg guard at z), not the current codebase version. **This may be a bug in the C4 formalization.**

### Finding 4: Backward Direction Requires C4-for-All-Pairs

The codebase C4 is restricted to adjacent pairs. The backward truth lemma needs C4 for all pairs x < y. In the limit (where the domain is potentially dense), there may be no adjacent pairs, making the adjacent-only C4 vacuously true and useless. A `limit_c4` theorem for all pairs is needed.

### Finding 5: Backward Until Coherence is Parameterized

`UntilSinceCoherence.lean` provides `backward_until_from_step` parameterized by a step transfer hypothesis: `(phi U psi) in mcs(r+1) /\ phi in mcs(r) -> (phi U psi) in mcs(r)`. This is designed for the Int chain (discrete), not the Rat chronicle (dense). A different mechanism is needed for the dense/chronicle setting.

### Finding 6: sorry Sites in the Truth Lemma

The BXCanonical truth lemma (`TruthLemma.lean`) has sorry sites at:
- `until_backward_refl_mcs`: "psi in w -> phi U psi in w" -- marked as not valid under strict/irreflexive semantics
- `since_backward_refl_mcs`: mirror

These are acknowledged as needing redesign. Under strict semantics, `psi -> (phi U psi)` is NOT axiomatically valid because the witness must be strictly in the future.

### Finding 7: ChronicleToCountermodel sorry Inventory

`ChronicleToCountermodel.lean` has sorry sites for all three restricted coherence conditions:
- `chronicle_fmcs.forward_G`, `chronicle_fmcs.backward_H` (G/H propagation)
- `chronicle_bfmcs_restricted_tc` (temporal F/P resolution)
- `chronicle_bfmcs_restricted_buc` (backward Until/Since -- both directions sorry'd)
- `chronicle_bfmcs_restricted_fuc` (forward Until/Since -- both directions sorry'd)
- `box_stable_in_chronicle_fmcs` (box stability)

---

## 7. Recommendations

### Immediate Actions

1. **CONFIRMED: Semantics use half-open guard `[t, s)` (Truth.lean line 127-128)**. C5 uses open guard `(x, y)`. This mismatch means the forward truth lemma for Until needs gamma(x) from a source other than C5. BX9 gives `gamma or delta` but not `gamma` alone. Consider either (a) changing C5 to include the guard at x, or (b) deriving `(gamma U delta) -> gamma` as a theorem, or (c) switching to Burgess's open guard semantics.

2. **Check C4 formula roles**: Compare C4's statement with the backward truth lemma's needs. If the roles are reversed, C4 must be corrected before the backward direction can be proved.

3. **Prove full C5 (with guards) in the limit**: This requires the interval function g. Alternatively, derive the guard from the persisting Until formula at intermediate points (C5 already provides `gamma U delta in f(z)` at intermediate z, and by BX9, `gamma or delta in f(z)`).

### Longer-Term

4. **Prove C4-for-all-pairs in the limit**: The omega-chain already eliminates C4 counterexamples. A theorem analogous to `limit_satisfies_c5_weak` should exist for C4.

5. **Clarify Burgess vs codebase U-argument conventions**: Add explicit documentation mapping Burgess's U(event, guard) to codebase's U(guard, event).
