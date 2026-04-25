# Teammate C Findings: Non-Domain Extension Problem

**Task**: 107 - Burgess chronicle representation theorem
**Focus**: Solve the non-domain extension problem for `extended_limit_f`
**Date**: 2026-04-24

## Executive Summary

**Option 3 (nearest-domain-point assignment) is the recommended approach**, but only as a stepping stone to **Option 4 (direct truth lemma over limit_dom)**, which is the correct long-term solution. Option 1 (restrict to limit_dom subtype) fails because `Subtype limit_dom_mem` is not an `AddCommGroup`. Option 2 (interpolation) is mathematically incoherent. Here is the detailed analysis.

## The Core Problem

The `FMCS Rat` structure requires `mcs : Rat -> Set Formula` for ALL rationals, with:
- `forward_G : t < t' -> G(phi) in mcs(t) -> phi in mcs(t')` (for ALL t, t')
- `backward_H : t' < t -> H(phi) in mcs(t) -> phi in mcs(t')`

The chronicle construction produces `limit_f : Rat -> Set Formula` which is meaningful only at `limit_dom` points. The current `extended_limit_f` assigns the root MCS `A` to non-domain points. This breaks `forward_G` because:

- Take non-domain point `q` with `G(phi) in A` and domain point `d > q`
- Need `phi in limit_f(d)`, but `G(phi) in A` does NOT imply `phi in limit_f(d)` unless `g_content(A) subset limit_f(d)`, which is only true when `d` is reachable from 0 via the chronicle's g_content chain
- Worse: take domain point `d` with `G(phi) in limit_f(d)` and non-domain `q > d`
- Need `phi in A`, but `g_content(limit_f(d)) subset A` requires `H(phi) in A` (T-axiom direction), which is NOT generally true under irreflexive strict-`<` semantics

## Option 1: Restrict to limit_dom Subtype

**Idea**: Define `FMCS (Subtype limit_dom_mem)` where the timeline type is the subtype of rationals in limit_dom.

### Assessment: BLOCKED

The `FMCS` structure requires `[Preorder D]`, and more importantly, the `ParametricCanonicalTaskFrame D` requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`.

**limit_dom is NOT closed under addition.** If `x, y in limit_dom`, there is no reason `x + y in limit_dom`. The chronicle inserts points at specific rationals to satisfy C5/C5' counterexamples; these insertions are driven by formula content, not algebraic structure. Therefore `Subtype limit_dom_mem` does NOT carry an `AddCommGroup` instance.

**Cantor's theorem variant**: Mathlib has `Order.iso_of_countable_dense` which states that any two countable dense linear orders without endpoints are order-isomorphic. If `limit_dom` were proven to be countable, dense, and without endpoints, we could get `limit_dom ≃o Rat`. But this order isomorphism does NOT preserve the additive group structure -- `Rat` has `AddCommGroup` but the order isomorphism is only an `OrderIso`, not a group isomorphism.

The `TaskFrame` definition fundamentally requires:
```
forward_comp : task_rel M x U -> task_rel U y V -> 0 <= x -> 0 <= y -> task_rel M (x+y) V
converse : task_rel M d N <-> task_rel N (-d) M
```

Both require `+` and `-` on the duration type `D`. An order isomorphism from `limit_dom` to `Rat` gives us a `LinearOrder` but NOT `AddCommGroup`.

**Could we TRANSPORT the group structure?** Given `e : limit_dom ≃o Rat`, define `x + y := e.symm (e x + e y)`. This gives an `AddCommGroup` on `limit_dom`, but it is NOT the inherited addition from `Rat`. More critically, `0` in this transported structure would be `e.symm 0`, which is some point in `limit_dom` that is NOT the rational `0`. The chronicle needs `limit_f(0) = A`, but the `0` of the transported group structure is an arbitrary domain point.

**Verdict**: Dead end. The algebraic structure requirements of `TaskFrame` are incompatible with the arbitrary combinatorial structure of `limit_dom`.

## Option 2: Interpolation-based Extension

**Idea**: For non-domain `q`, define `extended_limit_f(q)` via interpolation from neighboring domain points.

### Assessment: MATHEMATICALLY INCOHERENT

**Attempt 2a: Intersection of neighbors**
- `extended_limit_f(q) = limit_f(x) inter limit_f(y)` where `x = sup{d in limit_dom : d < q}` and `y = inf{d in limit_dom : d > q}`
- Problem: Intersection of two MCS is NOT an MCS (it is not maximal, only consistent). This fails the `is_mcs` requirement.

**Attempt 2b: Lindenbaum extension of g_content union h_content**
- `extended_limit_f(q) = Lindenbaum(g_content(limit_f(x)) union h_content(limit_f(y)))`
- Problem 1: Need to prove `g_content(limit_f(x)) union h_content(limit_f(y))` is consistent. This requires showing no formula `phi` has both `G(phi) in limit_f(x)` and `H(phi.neg) in limit_f(y)`. This is related to three-way C3 but requires NEW arguments about the limit construction.
- Problem 2: Even if consistent, the Lindenbaum extension is non-constructive (Classical.choice). The resulting MCS is essentially arbitrary among extensions, giving us no control over which formulas end up in `extended_limit_f(q)`.
- Problem 3: `forward_G` for `(q, q')` where both are non-domain: `G(phi) in Lindenbaum(...)` -> `phi in Lindenbaum'(...)`. Since Lindenbaum extensions are independent, this has no reason to hold.

**Verdict**: Fundamentally unworkable. Any interpolation scheme that uses Lindenbaum loses control over the extension's contents.

## Option 3: Nearest-Domain-Point Assignment

**Idea**: For non-domain `q`, define `extended_limit_f(q) = limit_f(nearest domain point below q)`.

### Assessment: PARTIALLY WORKABLE (with caveats)

Define: `extended_limit_f(q) = limit_f(sup{d in limit_dom : d <= q})`.

Since `limit_dom` contains 0 and points both above and below any bound (from C5/C5' satisfaction), this supremum exists for any `q`.

**Case analysis for forward_G (G(phi) in extended_limit_f(t), t < t', need phi in extended_limit_f(t'))**:

Let `d = nearest_below(t)` and `d' = nearest_below(t')`.

**Case 1**: Both `t, t'` are domain points. Then `d = t`, `d' = t'`, and `forward_G` follows from `g_content_chain_property` (the existing sorry, but this is the SAME sorry as before -- it is the core obligation).

**Case 2**: `t` is non-domain, `t'` is domain. Then `extended_limit_f(t) = limit_f(d)` where `d <= t < t'`. Since `d < t'` and both are domain points, `g_content_chain_property` gives `g_content(limit_f(d)) subset limit_f(t')`. So `G(phi) in limit_f(d) -> phi in limit_f(t')`.

**Case 3**: `t` is domain, `t'` is non-domain. Then `extended_limit_f(t) = limit_f(t)` and `extended_limit_f(t') = limit_f(d')` where `d' <= t'`. We need `d' >= t` (otherwise `d' < t` and forward_G goes the wrong way). If `d' >= t`, then `g_content_chain_property` applies. But what if `d' < t`? This happens when there is no domain point in `[t, t']`, meaning `t'` lies in a "gap" before the next domain point after `t`. In this case, `nearest_below(t') = d' < t`, and we would need `G(phi) in limit_f(t) -> phi in limit_f(d')` where `d' < t`. This requires **backward_H-like** behavior from forward_G -- clearly wrong.

**The fix**: Use `nearest_below_or_equal` with the convention that for non-domain `q`, we use the nearest domain point ABOVE (not below). Or more carefully: for `t < t'` where `t'` is non-domain, we need `nearest(t') >= t`. Using `ceil` (nearest above) for the assignment would give `extended_limit_f(t') = limit_f(nearest_above(t'))` with `nearest_above(t') > t' > t`, so `g_content_chain_property` applies. But then backward_H cases get the symmetric problem.

**The fundamental tension**: No monotone assignment `q -> d(q)` where `d(q) in limit_dom` can simultaneously satisfy:
- `t < t' -> d(t) < d(t')` (needed for forward_G: both map to domain points with correct ordering)
- Without density of `limit_dom` in `Rat`, there exist intervals `(a, b)` with no domain point, and any `t, t'` in such an interval must map to the SAME domain point, violating strict ordering.

**However**: Density of `limit_dom` IS plausible. The C5/C5' elimination process inserts points to satisfy `F(phi)` and `P(phi)` formulas. For any domain point `x`, `F(top) in limit_f(x)` (where top is provable) means there exists `y > x` in the domain. Similarly `P(top)` gives points below. Between any two domain points `x < y`, `F(top) in limit_f(x)` gives a point between (or above, depending on insertion strategy). **If the counterexample elimination inserts witness points BETWEEN existing points** (not just beyond the current max), then limit_dom would be dense.

**Current status**: The counterexample elimination (CounterexampleElimination.lean) uses `exists_rat_gt_finset` to find fresh rationals -- this places new points ABOVE the existing domain. This means limit_dom is NOT dense. It is essentially an increasing sequence {0, q1, q2, ...} with gaps between consecutive points.

**Verdict**: Nearest-domain-point works IF limit_dom is dense, but the current construction does NOT produce a dense domain. Modifying the construction to insert between points is a significant refactor (and complicates the inductive invariants).

## Option 4: Direct Truth Lemma over limit_dom

**Idea**: Build the countermodel directly over `limit_dom` without the parametric infrastructure, proving truth only for domain points.

### Assessment: THIS IS THE CORRECT APPROACH

The key observation is that `dd_countermodel_chronicle` has an EXISTENTIAL return type:
```lean
∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) ...
  (F : TaskFrame D) (TM : TaskModel F) ...
  ¬truth_at TM Omega τ t φ
```

The completeness theorem `bx_completeness` only needs to produce SOME countermodel. It does not require `D = Rat`. We can choose `D = Rat` and build a `TaskFrame Rat` where the model is defined everywhere, but the truth lemma only needs to hold at `limit_dom` points.

**The actual truth lemma requirement**: We need `phi.neg in limit_f(0) -> not (truth_at TM Omega tau 0 phi)`. This requires showing truth_at is controlled by MCS membership **at point 0 only**. But the truth lemma is proved by induction on formula structure, and the G/H/U/S cases require the truth lemma at OTHER points too.

**More precisely**: The induction on `phi` at point `t=0` requires:
- For `G(psi)`: truth_at at all `s > 0`, which means truth_at at domain points `s > 0` (since those are the only points where we have semantic witnesses)
- For `U(psi, chi)`: existence of witness `s > 0` with truth_at at `s` and guard at intermediate points

This means we need the truth lemma at ALL domain points, but ONLY at domain points. Non-domain points are irrelevant because:
1. The evaluation point is `0 in limit_dom`
2. G/H quantify over ALL `s > t` / `s < t`, but the SEMANTIC side (truth_at) is determined by the MODEL, which we control
3. If we build the model so that every history passes through domain-point world-states, then truth_at at non-domain times is determined by the model's trajectory, not by `extended_limit_f`

**The concrete approach**:

### Step A: Build the model over limit_dom directly

Define a `TaskFrame Rat` where:
- `WorldState = ParametricCanonicalWorldState` (same as before)
- `task_rel` uses `ExistsTask` (same as before)

This part is unchanged -- the parametric TaskFrame works for any D = Rat.

### Step B: Build FMCS that is correct on limit_dom

The `FMCS Rat` needs `forward_G` and `backward_H` for ALL rational pairs. The solution is:

**Make limit_dom dense by construction.** Modify the chronicle omega-chain to also eliminate "density counterexamples": for each pair `(x, y)` of adjacent domain points, insert a fresh point between them. This ensures limit_dom is dense in itself. Combined with C5/C5' guaranteeing no endpoints, limit_dom becomes a countable dense linear order without endpoints.

Then: since limit_dom is order-isomorphic to Rat (Cantor), and we only need the truth lemma at limit_dom points, the extension to non-domain points becomes irrelevant. ANY extension to non-domain points suffices for forward_G/backward_H because:
- For domain `t` and domain `t'` with `t < t'`: g_content_chain_property (the existing blocker, but this is the REAL mathematical content)
- For domain `t` and non-domain `t'` with `t < t'`: there exists domain `d` with `t < d < t'` (by density). Then by density there are domain points everywhere, so the chain condition propagates.
- For non-domain `t` and any `t'`: by density, there exists domain `d` arbitrarily close to `t`.

Actually, with density, the argument simplifies to: **for any `t < t'`, there exist domain points `d, d'` with `t <= d < d' <= t'`, and g_content_chain_property on `d, d'` gives the result.**

Wait, this still requires the non-domain extension to be CONTROLLED. Let me be more precise.

### Step C: The correct non-domain extension (with density)

If limit_dom is dense in Rat, then for non-domain `q`, define:
```
extended_limit_f(q) = limit_f(nearest domain point below q)
```

For `forward_G` with `t < t'`:
- If both domain: g_content_chain_property
- If `t` non-domain, `t'` domain: `nearest_below(t) < t < t'`, and `nearest_below(t)` is a domain point. By density, there is a domain point `d` with `nearest_below(t) < d <= t`. Actually, `nearest_below(t)` is the sup of domain points below `t`, and since domain is dense, `nearest_below(t) = t` ... no. If `t` is NOT in the domain, then the sup of `{d in limit_dom : d < t}` is some value `d_0 <= t`. But `d_0` might not be in limit_dom (limit_dom is countable, not closed).

**This reveals the fundamental issue**: with a countable dense domain, the "nearest below" supremum may not exist in the domain. Countable dense sets are not order-complete.

### Step D: The REAL solution -- don't extend at all

**The cleanest approach is to NOT use FMCS Rat at all.** Instead:

1. Prove limit_dom is countable, dense, and without endpoints
2. By `Order.iso_of_countable_dense`, get `e : Subtype limit_dom ≃o Rat`
3. Define `FMCS Rat` by `mcs(q) = limit_f(e.symm q)` -- this maps EVERY rational to a domain point via the order isomorphism
4. `forward_G`: for `t < t'`, `e.symm t < e.symm t'` (order isomorphism preserves ordering), and both `e.symm t, e.symm t'` are in limit_dom, so g_content_chain_property applies
5. `backward_H`: symmetric

This completely eliminates the non-domain extension problem. Every rational maps to a domain point via the Cantor isomorphism.

**The cost**: We need to prove three properties of limit_dom:
1. **Countable**: Yes, limit_dom = union of finite sets, so countable
2. **Dense**: Requires modifying the chronicle construction to ensure density (insert intermediate points)
3. **No endpoints**: Follows from C5/C5' -- for any domain point x, there exist domain points both above and below x

**Regarding density**: This is the key new requirement. The current construction inserts points ABOVE the domain max. To get density, we need to also insert points BETWEEN existing adjacent domain points. This can be done by adding "density counterexamples" to the enumeration: for each adjacent pair (x, y) in the current domain, enumerate a request to insert a point between them.

### Mathlib availability

- `Order.iso_of_countable_dense` (Mathlib.Order.CountableDenseLinearOrder): The core Cantor theorem
- `Rat.instDenumerable` (Mathlib): Rat is countable
- Standard Mathlib has `Countable` for unions of countable sets

## Recommended Approach

### Phase 1: Make limit_dom dense (modify ChronicleConstruction.lean)

Add "density counterexamples" to the counterexample enumeration. For each pair of adjacent domain points `(x, y)`, enumerate a request to insert a point `z` with `x < z < y`. The point `z` gets `f(z) = Lindenbaum(g_content(f(x)) union h_content(f(y)))`, which is consistent by the chronicle's interval structure.

This is a localized change to the counterexample enumeration, not a restructuring of the construction.

### Phase 2: Prove limit_dom properties

- `limit_dom_countable`: limit_dom is countable (union of finite domains)
- `limit_dom_dense`: limit_dom is dense in itself (from Phase 1 modification)
- `limit_dom_no_min`: no minimum (from C5' -- always a point below)
- `limit_dom_no_max`: no maximum (from C5 -- always a point above)
- `limit_dom_nonempty`: contains 0

### Phase 3: Apply Cantor isomorphism

```lean
-- Cantor isomorphism: limit_dom ≃o Rat
noncomputable def cantor_iso (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Subtype (limit_dom_mem A h_mcs) ≃o Rat :=
  (Order.iso_of_countable_dense (Subtype (limit_dom_mem A h_mcs)) Rat).some
```

### Phase 4: Redefine extended_limit_f using Cantor

```lean
noncomputable def extended_limit_f (A : Set Formula) (h_mcs : SetMaximalConsistent A) :
    Rat -> Set Formula :=
  fun q => limit_f A h_mcs ((cantor_iso A h_mcs).symm q).val
```

Now `extended_limit_f` maps EVERY rational to a domain point's MCS. The `forward_G` proof becomes:

```lean
-- G(phi) in extended_limit_f(t), t < t'
-- = G(phi) in limit_f(e.symm(t))
-- e.symm preserves order: e.symm(t) < e.symm(t'), both in limit_dom
-- By g_content_chain_property: phi in limit_f(e.symm(t'))
-- = phi in extended_limit_f(t')
```

### Phase 5: Adjust chronicle_fmcs and downstream

The `chronicle_fmcs` definition changes to use the new `extended_limit_f`. The `extended_limit_f_zero` theorem changes: now `extended_limit_f(0) = limit_f(e.symm(0))`, and we need `e.symm(0)` to correspond to the original `0 in limit_dom`. This is NOT automatically true -- the Cantor isomorphism is non-constructive and maps `0 : Rat` to some arbitrary domain point.

**Fix**: Use a POINTED version of the Cantor isomorphism. We need `e : Subtype limit_dom ≃o Rat` with `e(0) = 0`. This is achievable: the standard Cantor back-and-forth argument can be initialized with the pair `(0_dom, 0_rat)`. However, Mathlib's `Order.iso_of_countable_dense` does NOT provide a pointed version.

**Alternative fix**: Instead of requiring `e(0) = 0`, define the shifted FMCS. The evaluation point shifts from `0` to `e(0)`:
```lean
-- extended_limit_f(e(0)) = limit_f(e.symm(e(0))) = limit_f(0) = A
```
So `phi.neg in A = extended_limit_f(e(0))`. The countermodel evaluates truth at time `e(0)` instead of time `0`. Since `dd_countermodel_chronicle` existentially quantifies over the evaluation time `t`, this is fine.

## Summary of Recommendation

| Option | Feasible? | Effort | Risk |
|--------|-----------|--------|------|
| 1. Subtype limit_dom | NO | - | AddCommGroup missing |
| 2. Interpolation | NO | - | Mathematically incoherent |
| 3. Nearest-point | PARTIAL | Medium | Fails without density |
| 4. Direct via Cantor | YES | High | Requires density proof |

**Recommended**: Option 4 with the following implementation order:

1. **Immediate**: Modify counterexample enumeration to include density requests
2. **Then**: Prove limit_dom is countable dense without endpoints
3. **Then**: Apply `Order.iso_of_countable_dense` for Cantor isomorphism
4. **Then**: Redefine `extended_limit_f` via Cantor isomorphism
5. **Then**: Prove `forward_G`/`backward_H` using `g_content_chain_property` (the existing core blocker)

**Key insight**: The non-domain extension problem REDUCES to g_content_chain_property once the Cantor isomorphism is in place. It does not introduce new mathematical obligations -- it only introduces proof engineering (density of limit_dom, Cantor application).

## Alternative: Minimal Fix (if density modification is too invasive)

If modifying the chronicle construction for density is too disruptive, there is a simpler but less clean approach:

**Augment limit_dom post-hoc.** After the omega-chain produces limit_dom, define:
```
augmented_dom = DenseCompletion(limit_dom)
```
where for each gap `(x, y)` in limit_dom, we insert countably many points. At each inserted point `z`, define `limit_f(z) = Lindenbaum(g_content(limit_f(x)))` where `x` is the nearest domain point below `z`. This preserves `forward_G` at the cost of one more Lindenbaum application per gap, and the consistency proof uses `g_content_set_consistent`.

This avoids modifying the omega-chain construction and localizes the density work to a post-processing step.
