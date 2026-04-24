# Teammate B Findings: Alternative Approaches for extended_limit_f

**Artifact**: 10 | **Role**: Teammate B (Alternative Approaches)
**Task**: 107 -- Chain design diagnostics for representation theorem
**Focus**: Evaluate Approaches B (subtype-indexed model), C (bypass extended_limit_f), and D (smarter non-domain assignment)

---

## Key Findings

### 1. The FMCS/BFMCS Interface Only Requires `[Preorder D]`

Critical discovery: `FMCS D` and `BFMCS D` only require `[Preorder D]` on the type parameter D. They do NOT require `AddCommGroup`, `LinearOrder`, or `IsOrderedAddMonoid`. These heavier constraints only appear at the `TaskFrame D` level (used by `ParametricCanonicalTaskFrame`) and the `RestrictedParametricTruthLemma` (variable declaration at line 37).

The full constraint chain is:
- `FMCS D` needs `[Preorder D]` (FMCSDef.lean:77)
- `BFMCS D` needs `[Preorder D]` (BFMCS.lean:52)
- `ParametricCanonicalTaskFrame D` needs `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` (ParametricCanonical.lean:198)
- `fully_restricted_parametric_representation_from_neg_membership` needs `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` (RestrictedParametricTruthLemma.lean:37)
- `dd_countermodel_chronicle` instantiates all of this with `D = Rat`

**Implication for Approach B**: A subtype `{ x : Rat // x in limit_dom A h_mcs }` would need to satisfy ALL of `AddCommGroup`, `LinearOrder`, and `IsOrderedAddMonoid` to plug into the parametric representation theorem. This is the central obstacle for Approach B.

### 2. Approach B (Subtype-Indexed Model) Is Impractical

**Problem**: `limit_dom A h_mcs` is a countably infinite subset of Rat obtained as the union of all finite chronicle domains. It is NOT closed under addition (each step adds at most one new point via midpoint or +1 construction). For `AddCommGroup` on the subtype, we need:
- Closure under addition: `x in dom, y in dom => x + y in dom` -- FALSE in general
- Closure under negation: `x in dom => -x in dom` -- FALSE in general (singleton starts at {0})
- An additive identity: 0 in dom -- TRUE (guaranteed by `zero_mem_limit_dom`)

The domain starts as {0} and grows by midpoint insertions (z = (x+y)/2) and successor insertions (y = x+1). After one step we might have {0, 1}. After another, {0, 0.5, 1}. Then {0, 0.25, 0.5, 1}. The sum 0.5 + 1 = 1.5 is NOT in the domain until explicitly inserted. And -0.5 is never inserted unless needed by a Since counterexample.

**Workaround via order-isomorphism to Q**: In principle, any countable dense linear order without endpoints is order-isomorphic to Q (Cantor's back-and-forth theorem). But `limit_dom` may have endpoints (it starts at {0} and may be bounded), and it may not be dense (only finitely many points are inserted between any given pair). Even if we could get an order-isomorphism, transferring `AddCommGroup` through an order-isomorphism requires the isomorphism to respect the group structure -- but order-isomorphisms do not preserve additive structure in general.

**Workaround via closing under addition**: We could modify the omega-chain construction to ensure the domain is closed under addition at each step. This would require inserting O(n^2) points per step instead of O(1), fundamentally changing the construction. The chronicle conditions (C0-C5) would need to be maintained for all these extra points, requiring additional MCS constructions for each. This is a massive redesign.

**Verdict**: Approach B is impractical. The AddCommGroup requirement on D is a hard constraint from the parametric representation theorem, and there is no lightweight way to satisfy it on a subtype of Rat.

### 3. Approach C (Bypass extended_limit_f, Use Subtype Directly) Is Also Impractical

Approach C proposes building `chronicle_fmcs` on `{ x : Rat // x in limit_dom A h_mcs }` directly, avoiding the non-domain extension entirely. The `forward_G` obligation would then only quantify over domain points, where the chronicle's g-content structure provides the answer.

This has the same fatal problem as Approach B: the parametric representation theorem requires `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` on D. A subtype of Rat that isn't closed under addition cannot satisfy `AddCommGroup`.

Additionally, `dd_countermodel_chronicle` explicitly instantiates `D = Rat`:
```lean
refine ⟨Rat, inferInstance, inferInstance, inferInstance, inferInstance,
    ParametricCanonicalTaskFrame Rat, ParametricCanonicalTaskModel Rat, ...⟩
```

Changing D to a subtype would require modifying this instantiation AND proving all the instances, which is not feasible without the group closure property.

**Verdict**: Approach C fails for the same AddCommGroup reason as Approach B.

### 4. Approach D (Smarter Non-Domain Assignment) Is the Most Promising

Approach D keeps `FMCS Rat` and `BFMCS Rat` but changes what `extended_limit_f` assigns to non-domain points. Currently it assigns the root MCS A to all non-domain points, which breaks `forward_G` because `G(phi) in A` does not imply `phi in A` under strict semantics.

**Why the current assignment fails**: Consider non-domain rationals t < t'. Both map to A. The `forward_G` obligation requires: `G(phi) in A => phi in A`. Under strict semantics, G(phi) means "phi at all strictly future times", which does NOT include the current time. So `G(phi) in A` says nothing about `phi in A`.

**Key insight**: The `forward_G` and `backward_H` fields of FMCS are NOT actually needed for the correctness of the completeness theorem via the *restricted* truth lemma pathway. Let me explain:

The completeness theorem goes through `fully_restricted_parametric_representation_from_neg_membership`, which needs:
1. `restricted_temporally_coherent` -- F/P witness existence (uses C5/C5')
2. `restricted_backward_until_since_coherent` -- backward Until/Since
3. `restricted_forward_until_since_coherent` -- forward Until/Since

None of these three conditions directly reference `forward_G` or `backward_H`. They are about F/P witnesses and Until/Since witnesses.

However, `forward_G` and `backward_H` ARE required by the FMCS structure itself. They are used inside the restricted truth lemma to handle the G/H inductive cases. Specifically, the G case of the truth lemma says: `G(phi) in fam.mcs(t) iff forall t' > t, phi in fam.mcs(t')`. The forward direction uses `forward_G`, and the backward direction uses `backward_P` (from temporal coherence).

**So forward_G IS load-bearing.** We cannot simply remove it.

**Approach D strategy**: For a non-domain rational r, find the "context" from surrounding domain points and assign an MCS that is consistent with the temporal propagation. Several sub-variants:

**D1: Assign g_content-extended MCS**. For r between domain points x < r < y, compute `g_content(limit_f(x))` and extend it to an MCS via Lindenbaum. This ensures `G(phi) in limit_f(x) => phi in ext_mcs(r)` because `g_content(limit_f(x)) <= ext_mcs(r)` by construction. For r above all domain points, extend `g_content(limit_f(max_dom))`. For r below all domain points, extend `h_content(limit_f(min_dom))`.

**Problem with D1**: The domain has no maximum or minimum (points extend in both directions via C5 witnesses). But more critically, for `forward_G` we need: if `G(phi) in ext_mcs(r)` for non-domain r, then `phi in ext_mcs(r')` for all r' > r. If both r and r' are non-domain, we need transitivity of g_content extension, which is not guaranteed.

**D2: Assign the same MCS as the nearest domain point below**. For non-domain r, let x be the supremum of domain points below r, and set `extended_limit_f(r) = limit_f(x)`. For `forward_G`: if `G(phi) in limit_f(x)` and r < r', we need `phi in extended_limit_f(r')`. If r' is in the domain, this follows from `forward_G` of the chronicle (since x < r < r' and x is in domain). If r' maps to domain point x' >= x, we need `phi in limit_f(x')`, which follows from `forward_G` of the original chronicle.

**Problem with D2**: "Nearest domain point below" may not exist (limit_dom could be bounded below but 0 is the minimum). Also, defining this requires a well-defined supremum operation on the countable set, which exists classically but is messy to formalize.

**D3: Keep assignment to A, but prove forward_G differently**. This is actually the approach sketched in the existing code comments. The claim is that the evaluation only ever happens at domain points (specifically at 0), and the G/H coherence at non-domain points is only used transitively through domain points.

**Problem with D3**: The FMCS structure requires forward_G for ALL t < t', not just domain points. There is no way to restrict it.

### 5. The Real Solution: Prove forward_G for the Existing Construction

After careful analysis, I believe the existing `extended_limit_f` with root-MCS assignment CAN satisfy `forward_G`, but the proof requires using properties of the chronicle that aren't immediately obvious.

**Claim**: If `G(phi) in A` (root MCS), then `phi in A`.

**Proof sketch**: By the BX axiom system, `G(phi) -> F(phi)` is a theorem (derivable from `G(phi) -> phi U phi` via the Until-G relationship, or from specific axioms). Wait -- this is NOT correct under strict semantics. Under strict semantics, `G(phi)` means "phi at all strictly future times" and does NOT imply `phi` at the current time (no T-axiom for G).

However: `G(phi) -> G(phi)` is trivially true. And `G(phi) -> GG(phi)` is the 4-axiom for G (temp_4). So `G(phi) in A => GG(phi) in A => G(phi) in A` (circular, unhelpful).

The real question: does `G(phi) in A` imply `phi in A`? In strict semantics, NO. Consider a model with a single point (no strict future). Then `G(phi)` is vacuously true but `phi` can be false.

**This confirms the fundamental problem**: `forward_G` is unprovable for non-domain-to-non-domain transitions under the current construction.

### 6. Recommended Approach: Interval-Based Non-Domain Assignment (Refined D1)

The most promising fix is a refined version of D1 that handles the transitivity issue:

For each non-domain rational r, define:
```
extended_limit_f(r) = Lindenbaum_extend(g_content(A) ∪ h_content(A) ∪ {phi | G(phi) in A} ∪ {phi | H(phi) in A})
```

This "propagation closure" ensures:
- `G(phi) in A => phi in extended_limit_f(r)` (because `{phi | G(phi) in A} <= seed`)
- `H(phi) in A => phi in extended_limit_f(r)` (because `{phi | H(phi) in A} <= seed`)
- Consistency of the seed needs to be verified

**Consistency of the seed**: `g_content(A) ∪ h_content(A) ∪ {phi | G(phi) in A} ∪ {phi | H(phi) in A}` is consistent if A is an MCS. This follows from:
- `g_content(A) = {phi | G(phi) in A}` by definition (they are the SAME set)
- `h_content(A) = {phi | H(phi) in A}` by definition
- So the seed is just `g_content(A) ∪ h_content(A)`
- This is consistent because A is an MCS and contains both `G(phi) -> G(phi)` tautologically

Wait -- `g_content(A) ∪ h_content(A)` needs a consistency proof. If `phi in g_content(A)` and `neg(phi) in h_content(A)`, that means `G(phi) in A` and `H(neg(phi)) in A`. Is this consistent? Yes, because A is an MCS: `G(phi) in A` and `H(neg(phi)) in A` can coexist (phi holds in the future, neg(phi) held in the past).

But the Lindenbaum extension of `g_content(A) ∪ h_content(A)` gives an MCS where:
- For non-domain t < t': `G(phi) in ext(t) => phi in ext(t')` becomes `G(phi) in ext => phi in ext`, which requires `G(phi) => phi` in the extension, which is the T-axiom -- and this IS available if we include `G(phi) -> phi` instances. But T for G is NOT a BX axiom under strict semantics!

**This approach also fails.** The fundamental issue is inescapable: under strict semantics, G does not have the T-axiom, so no single MCS can serve as the uniform assignment for all non-domain points while satisfying forward_G.

### 7. The Actual Solution: Restrict FMCS to Use DenselyOrdered, or Accept Sorry

After exhaustive analysis, I see three genuinely viable paths:

**Path 1: Make the domain dense (modify construction)**. Modify the omega-chain to insert density witnesses at every step (Verbrugge's odd-stage insertion). This makes `limit_dom` dense in Rat. Then there are no non-domain points to worry about -- every rational is in the domain (or can be approximated). With `DenselyOrdered` on the domain, every pair t < t' has a domain point between them, and the chronicle's g-content structure handles forward_G through that intermediate point.

However, this requires the density axiom `GGp -> Gp` to be available in the proof system, which contradicts research finding #9 (density axioms are NOT needed for general completeness).

**Path 2: Use a different FMCS construction that avoids non-domain issues**. Instead of extending `limit_f` to all of Rat, construct the FMCS such that `forward_G` is provable by construction. For example:

Define `extended_limit_f(r)` for non-domain r as the MCS obtained by Lindenbaum-extending `{phi | forall x in dom, x > r -> phi in limit_f(x)}` (the "future intersection"). This set is deductively closed and consistent (intersection of consistent theories). Then `G(phi) in extended_limit_f(r) => phi in extended_limit_f(r')` for r < r' follows because the future intersection at r' is a subset of the future intersection at r.

**Problem**: The "future intersection" `{phi | forall x in dom, x > r -> phi in limit_f(x)}` may not be an MCS (it's an intersection of MCS, which gives a consistent theory but not necessarily maximal). It IS consistent (any finite subset is contained in some limit_f(x), which is consistent). But maximality fails -- we'd need Lindenbaum extension, which might add formulas that break the forward_G property.

**Path 3: Accept the sorry in forward_G, prove everything else**. The `forward_G` and `backward_H` sorrys in `chronicle_fmcs` are 2 of the 17 sorry sites. The other 15 are more tractable. Closing the other 15 while leaving these 2 would still represent significant progress. The eventual fix likely requires a more careful non-domain extension -- possibly the "future intersection" approach with a careful Lindenbaum extension that preserves forward_G.

## Recommended Approach

**Path 2 (future-intersection based non-domain assignment)** is the most mathematically sound.

Define for non-domain r:
```
seed(r) = { phi | forall x in limit_dom, x > r -> phi in limit_f(x) }
              ∩ { phi | forall x in limit_dom, x < r -> phi in limit_f(x) }
```

Actually, the simpler version: for non-domain r, define `extended_limit_f(r) = Lindenbaum_extend(g_inter(r))` where `g_inter(r) = { phi | forall x in limit_dom with x > r, phi in limit_f(x) }`.

Then forward_G: if `G(phi) in extended_limit_f(t)` and t < t':
- If t is in domain: `phi in limit_f(x)` for all domain x > t, so `phi in g_inter(t')`, so `phi in extended_limit_f(t')`.
- If t is non-domain: `G(phi) in Lindenbaum_extend(g_inter(t))`. Need `phi in Lindenbaum_extend(g_inter(t'))`. Since `g_inter(t') >= g_inter(t)` (more domain points above t' means fewer constraints, so... wait, FEWER domain points above t' means the intersection is LARGER). Actually `t < t'` means `{x in dom | x > t'} subset {x in dom | x > t}`, so `g_inter(t') superset g_inter(t)`. So `phi in g_inter(t')` might NOT follow from `G(phi) in ext(t)`.

This is getting circular. The fundamental mathematical difficulty is that forward_G requires a monotonicity property that is hard to guarantee through Lindenbaum extension.

**Final recommendation**: The most practical path forward is to restructure the construction so that `extended_limit_f` at non-domain points uses a deterministic procedure that guarantees forward_G by construction. This likely requires the "G-type" content of the root MCS to propagate uniformly. The cleanest version may be:

For non-domain r, set `extended_limit_f(r) = Lindenbaum_extend(g_content(A))` where the Lindenbaum extension is done deterministically (e.g., using an enumeration of formulas). With a FIXED deterministic Lindenbaum extension, ALL non-domain points get the SAME MCS (call it A_g). Then `forward_G` for non-domain-to-non-domain reduces to: `G(phi) in A_g => phi in A_g`. Since `g_content(A) <= A_g` (by construction), we have `G(phi) in A => phi in A_g`. But we need `G(phi) in A_g => phi in A_g`, which requires `G(phi) in A_g => G(phi) in A` -- i.e., that A_g doesn't contain "extra" G-formulas beyond what A has.

If A_g is the Lindenbaum extension of g_content(A), then A_g is an MCS containing g_content(A). It may contain G(psi) for formulas psi not in g_content(A). Then `phi` (from G(phi)) would need to be in A_g, but there's no guarantee.

**Ultimate verdict**: All non-trivial approaches to fixing the non-domain assignment have the same core difficulty. The cleanest solution is likely **Path 1 with a twist**: make the chronicle construction produce a dense domain (by inserting midpoints at every step), which eliminates non-domain points entirely. This does NOT require adding density axioms to the proof system -- it only requires the construction to produce enough points. The Burgess construction already inserts midpoints (Lemma 2.9), so ensuring density is a matter of systematically inserting midpoints between all adjacent pairs at each step.

## Evidence/Examples

### Concrete counterexample showing forward_G failure with root-MCS assignment

Let A be an MCS with `G(p) in A` but `p not_in A` (valid under strict semantics -- G(p) says "p at all strictly future times", compatible with p being false now).

Let t = 0.3 and t' = 0.7, both non-domain. Then:
- `extended_limit_f(0.3) = A` (non-domain)
- `extended_limit_f(0.7) = A` (non-domain)
- `G(p) in extended_limit_f(0.3)` (since G(p) in A)
- Need: `p in extended_limit_f(0.7) = A`
- But: `p not_in A`
- Contradiction: forward_G fails.

### Type constraint evidence

From FMCSDef.lean line 77: `variable (D : Type*) [Preorder D]`
From BFMCS.lean line 52: `variable (D : Type*) [Preorder D]`
From TaskFrame.lean line 93: `structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`
From RestrictedParametricTruthLemma.lean line 37: `variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`

### Files using FMCS Rat / BFMCS Rat (non-Boneyard)

Only `ChronicleToCountermodel.lean` uses `FMCS Rat` and `BFMCS Rat`. All other live code uses `FMCS Int` / `BFMCS Int`. Switching the type parameter would only affect this one file.

## Confidence Level

**HIGH** confidence on the analysis of why Approaches B and C fail (AddCommGroup constraint is load-bearing and subtype cannot satisfy it).

**HIGH** confidence on why the current root-MCS assignment breaks forward_G (concrete counterexample above).

**MEDIUM** confidence on the recommendation. The "make domain dense" approach is mathematically sound but requires non-trivial construction changes. The exact implementation complexity is hard to estimate without attempting it.

## Critical Verification: forward_G IS Load-Bearing

Verified by grep: `forward_G` is called directly in the restricted truth lemma at line 196 of `RestrictedParametricTruthLemma.lean`:

```lean
-- Line 196: G case, forward direction
have h_psi_mcs : ψ ∈ fam.mcs s := fam.forward_G t s ψ hts h_G
```

And in the unrestricted truth lemma at line 309 of `ParametricTruthLemma.lean`. It is also used in `box_in_family_stable` (ParametricTruthLemma.lean:193) for proving Box stability.

The backward direction of the G case (lines 198-209) uses `restricted_temporal_backward_G_strict` which goes through F-witnesses and does NOT use forward_G. But the forward direction has no alternative -- it directly extracts `phi` from `G(phi)` using the `forward_G` field.

**This confirms forward_G cannot be removed from FMCS without restructuring the truth lemma.**

## Open Questions

1. **Can the G case forward direction be restructured?** Currently: `G(phi) in mcs(t), t < s => phi in mcs(s)` uses forward_G directly. Could we instead go through the model: `G(phi) in mcs(t) => [by backward direction already proven for smaller formulas] => truth_at(G(phi), t) => [by semantics] phi true at s => [by IH backward] phi in mcs(s)`? This circular argument doesn't work because the forward and backward directions are proven together in the constructor.

2. **Could we split the truth lemma into forward-only and backward-only?** Prove `phi in mcs(t) => truth_at(phi, t)` separately from the converse. The forward direction needs forward_G. The backward direction does not. If we only need one direction for completeness (we need `neg(phi) in M => not truth_at(phi, ...)`, which is the forward direction), then we still need forward_G.

3. **Is there a standard reference for handling non-domain extensions in chronicle constructions?** Burgess 1982's model IS the limit domain (a subset of Rat), not all of Rat. The correct formalization may need to avoid extending to all of Rat entirely, finding instead a way to satisfy the AddCommGroup constraint on the limit domain or restructuring the parametric infrastructure.

4. **Could we weaken FMCS.forward_G to a restricted version?** Add a parameter `relevant : Set D` and only require forward_G for t, t' in `relevant`. The truth lemma would then need the evaluation point to be in `relevant`. This is invasive but targeted.

5. **Making the domain dense by construction**: If the omega-chain is modified to insert midpoints between ALL adjacent domain pairs at each step (not just counterexample-driven insertions), the limit domain becomes dense in some interval. Then non-domain points exist only outside this interval. If the interval is all of Rat (unbounded in both directions), there are no non-domain points. The chronicle C5/C5' witnesses already extend the domain in both directions, so with systematic midpoint insertion, limit_dom might become dense. This does NOT require density axioms in the proof system -- it's a construction choice.
