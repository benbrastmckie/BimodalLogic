# Research Report: Teammate A Findings -- g_content_chain_property Obstacle

**Task**: 107 - Chain Design Diagnostics for Representation Theorem
**Date**: 2026-04-24
**Focus**: Deep analysis of g_content_chain_property sorry and solution approaches

## Executive Summary

- The g_content_chain_property sorry is the single deepest obstacle in the chronicle construction. All other forward/backward temporal properties (limit_forward_G, limit_backward_H) and 2 of the 9 ChronicleToCountermodel sorries depend on it.
- The "enlarged seed" approach and "temp_4 + inductive invariant" argument in the handoff are **circular** -- they assume the very property being proved.
- The Int chain (CanonicalModel.lean) succeeds because it builds chain(n+1) FROM chain(n), making g_content inclusion hold **by construction**. The chronicle inserts points at arbitrary positions, creating backward dependencies that break this pattern.
- The cleanest solution is a **g_content propagation pass** integrated into each omega-chain step: after C5 elimination inserts a new point y, extend ALL existing domain points' MCS to absorb g_content from their predecessors. This maintains the invariant step-by-step.
- An alternative "limit-level" approach avoids modifying the omega-chain entirely by proving the property directly from the limit structure using temp_4 and the F-resolution theorem.

## 1. The Two-Pass Approach: Detailed Analysis

### What it proposes

After C5-forward elimination inserts witness y beyond all domain points with seed `{eta} union g_content(f(t))`:
- **Pass 1**: f(y) is an MCS containing eta and g_content(f(t)) (current behavior, via lemma_2_4)
- **Pass 2**: Replace f(y) with a new MCS that extends `f(y) union g_content(f(x))` for all x < y in dom

### Consistency question: Is g_content(f(x)) union f(y) consistent?

This is the **critical question**. Could there be phi such that G(phi) in f(x) (so phi in g_content(f(x))) but neg(phi) in f(y)?

**Analysis**: Yes, this CAN happen, BUT it does not create inconsistency of the **union** -- it creates inconsistency of **extending f(y)** with g_content(f(x)). Specifically:

- f(y) was constructed via Lindenbaum extension of `{eta} union g_content(f(t))`
- For x != t, g_content(f(x)) may contain formulas whose negations are in f(y)
- The union `g_content(f(x)) union f(y)` could be inconsistent

**Concrete scenario**: Let t < x < y (all in dom after insertion). f(t) has U(xi, eta). f(x) has G(psi) for some psi. The new f(y) was built from g_content(f(t)), which does NOT include psi. During Lindenbaum extension, neg(psi) could have been added to f(y). Then g_content(f(x)) contains psi, and f(y) contains neg(psi): the union is inconsistent.

**Verdict**: The two-pass approach as stated is **unsound** for arbitrary predecessor points x. It only works safely when g_content of all predecessors is already contained in g_content of the triggering point t. The handoff claims this follows from temp_4, but as shown below, that argument is circular.

### Could we use a larger seed from the start?

Instead of two passes, use seed `{eta} union g_content(f(m))` where m = max(dom). This requires F(eta) in f(m), which the handoff correctly identifies as blocked: F(eta) = neg(G(neg(eta))) does not propagate forward through g_content.

## 2. The temp_4 Circularity

### The claim

The handoff states: "By temp_4 and the inductive invariant, the union of all g_content(f(x)) for x in dom equals g_content(f(m)) where m = max(dom)."

### The circularity

Let's trace the argument carefully:

1. Want: for all x in dom, g_content(f(x)) subset g_content(f(m))
2. This means: for all x, if G(phi) in f(x), then G(phi) in f(m)
3. By temp_4: G(phi) in f(x) implies G(G(phi)) in f(x), so G(phi) in g_content(f(x))
4. **If** g_content(f(x)) subset f(x1) for adjacent x < x1 (the chain property), then G(phi) in f(x1)
5. Repeating: G(phi) in f(x1) => G(phi) in g_content(f(x1)) subset f(x2) => ... => G(phi) in f(m)

Step 4 uses `g_content(f(x)) subset f(x1)` for adjacent x < x1, which is **exactly the g_content_chain_property we are trying to prove**. The argument is circular.

### What temp_4 actually gives us

temp_4 (G(phi) -> G(G(phi))) gives us: if g_content(f(x)) subset f(x1) for ONE step (x to x1), then g_content(f(x)) subset f(x2) for TWO steps, etc. This is `lemma_2_5b` (transitivity of g_content ordering). But it requires the **base case** -- the single-step property -- which is the open sorry.

## 3. How the Int Chain Handles This

### The CanonicalModel.lean pattern

```
fwd_chain(0) = M0
fwd_chain(n+1) = fwd_succ(fwd_chain(n), schedule(n))
```

where `fwd_succ(M, psi)` uses Lindenbaum extension of `{psi} union g_content(M)` (when F(psi) in M) or just `g_content(M)` (otherwise).

### Why g_content inclusion holds trivially

`fwd_chain_g_content_step` proves:
```
g_content(fwd_chain(n)) subset fwd_chain(n+1)
```

This is immediate from the construction: `fwd_chain(n+1)` is a Lindenbaum extension of a set that **includes** `g_content(fwd_chain(n))`. Every superset of the seed contains the seed, so the result MCS contains g_content of the predecessor.

### The key insight

The Int chain has a **strictly linear** structure:
- chain(n+1) is built FROM chain(n)
- g_content(chain(n)) is literally part of the seed
- The inclusion is definitional

The transitive property `fwd_chain_g_content_trans` (m < n => g_content(chain(m)) subset chain(n)) then follows by induction using temp_4 (lemma_2_5b pattern).

## 4. What's Different About the Chronicle

### The insertion asymmetry

The chronicle omega-chain processes potential counterexamples in enumeration order. When processing counterexample (x, xi, eta, c5_forward):

1. Find fresh y > max(dom) via `exists_rat_gt_finset`
2. Build C via `lemma_2_4`: C contains eta and g_content(f(x))
3. Set f'(y) = C, f' agrees with f on old domain

After insertion, the domain ordering might be: ..., a, b, x, c, d, y where a < b < x < c < d < y.

**The problem**: g_content(f(c)) subset f(y) is NOT guaranteed because:
- f(y) was built from g_content(f(x)), not g_content(f(c))
- c was already in dom before y was inserted
- f(c) may contain G(phi) where phi is not in f(y)

**In contrast**: g_content(f(x)) subset f(y) IS guaranteed (by construction, since g_content(f(x)) is in the seed).

### The backward dependency

When a new point z is inserted BETWEEN existing points x and y (as in C4 elimination, using midpoint):
- f(z) is set to f(x) or f(y) (copying an existing MCS)
- g_content(f(x)) subset f(z) holds when f(z) = f(x) (g_content(M) subset M fails under strict semantics!)
- Actually: g_content(f(x)) subset f(x) requires the T-axiom (G(phi) -> phi), which does NOT hold under strict/irreflexive semantics

This means even the C4 midpoint insertion can break the chain property. If f(z) = f(x), we need g_content(f(x)) subset f(x), which is false under strict semantics.

### Summary of the fundamental mismatch

| Feature | Int Chain | Chronicle |
|---------|-----------|-----------|
| Index set | Nat (linear) | Rat (dense) |
| Point addition | Always at n+1 (successor) | Arbitrary position (midpoint, beyond max) |
| Seed for new MCS | Always includes g_content(predecessor) | Includes g_content of triggering point only |
| g_content step | By construction (seed includes it) | Not guaranteed for non-triggering predecessors |
| Strict semantics | g_content(M) not subset M is fine (strict chain) | g_content(M) not subset M breaks midpoint insertions |

## 5. Proposed Solutions

### Solution A: Limit-Level Proof (No Omega-Chain Modification)

**Key insight**: In the LIMIT, g_content(limit_f(x)) subset limit_f(y) for x < y might be provable WITHOUT maintaining it as an invariant of finite chronicles.

**Argument sketch**:
1. Let G(phi) in limit_f(x). Need: phi in limit_f(y).
2. G(phi) in limit_f(x) means G(phi) in f_n(x) for some n with x in dom(n).
3. By temp_4: G(G(phi)) in f_n(x), so G(phi) in g_content(f_n(x)).
4. By `limit_F_resolution`: F(phi) in limit_f(x) implies exists z > x with phi in limit_f(z). But we have G(phi), not F(phi).
5. **G(phi) in limit_f(x) and y > x**: We need phi at EVERY future point, not just one.
6. Suppose phi not in limit_f(y). Then neg(phi) in limit_f(y) (MCS). By connect_past (BX4'): neg(phi) -> H(F(neg(phi))), so H(F(neg(phi))) in limit_f(y). Then F(neg(phi)) in h_content(limit_f(y)).
7. **If** we had h_content(limit_f(y)) subset limit_f(x), then F(neg(phi)) in limit_f(x). But F(neg(phi)) = neg(G(phi.neg.neg)). Under DNE: phi.neg.neg equiv phi, so this gives neg(G(phi)) in limit_f(x) (modulo double negation), contradicting G(phi) in limit_f(x).

**Problem**: Step 7 uses h_content(limit_f(y)) subset limit_f(x), which IS the dual of g_content_chain_property (by the already-proved duality bridge). So this is also circular.

**Alternative limit-level idea**: Use the density of limit_dom. For any x < y in limit_dom, there are infinitely many domain points between them (by repeated C5 elimination). Each inserted point's MCS contains g_content of its triggering point. Can we chain these together?

Not directly -- the inserted points form a forward chain from their respective triggering points, not from x to y.

### Solution B: Interleaved G-Content Propagation Steps

After each C5/C4 elimination step, add a "propagation sweep": for each pair (a, b) in dom with a < b, if g_content(f(a)) is not subset f(b), replace f(b) with a Lindenbaum extension of `f(b) union g_content(f(a))`.

**Consistency argument**: g_content(f(a)) union f(b) must be consistent. Suppose not: there exist phi_1, ..., phi_k in g_content(f(a)) and psi_1, ..., psi_m in f(b) with `phi_1, ..., phi_k, psi_1, ..., psi_m |- bot`. Since f(b) is an MCS, this means `phi_1, ..., phi_k |- neg(psi_1 and ... and psi_m)`. So `neg(psi_1 and ... and psi_m) in deductiveClosure(g_content(f(a)))`. Hmm, this doesn't immediately give a contradiction.

**Actually**: We need g_content(f(a)) union f(b) to be consistent. This is NOT obvious. Consider: G(phi) in f(a), so phi in g_content(f(a)). And neg(phi) in f(b). These are both in the union. Can this happen? Yes -- there's no a priori reason why a formula guaranteed at all future points of a would have to hold at an arbitrary domain point b > a. The inclusion g_content(f(a)) subset f(b) is exactly what we're trying to establish.

**This means the propagation sweep has a consistency gap too.**

### Solution C: Rebuild the Omega-Chain with G-Content in the Seed

Modify `eliminate_C5_counterexample` to use seed `{eta} union g_content(f(m))` where m = max(dom), instead of `{eta} union g_content(f(t))`.

**Requirement**: F(eta) in f(m). We have F(eta) in f(t) (from U(xi, eta) in f(t) and BX10). Does F(eta) propagate to f(m)?

F(eta) = neg(G(neg(eta))). G(neg(eta)) not in f(t). Does G(neg(eta)) stay absent at f(m)? No guarantee -- G(neg(eta)) could be added to f(m) without contradiction (it would mean eta fails at all future points of m, which is consistent).

**This approach is blocked**, as the handoff correctly noted.

### Solution D: Modify Insertion to Place Points Adjacent to Triggering Point

Instead of placing y beyond ALL domain points, place y just beyond the triggering point x. Specifically, if x is in dom and the next domain point above x is z, place y = (x + z) / 2.

**Advantages**:
- g_content(f(x)) subset f(y) by construction (seed includes it)
- For all w < x in dom: g_content(f(w)) subset f(x) by inductive hypothesis, g_content(f(x)) subset f(y) by construction, so g_content(f(w)) subset f(y) by lemma_2_5b (transitivity via temp_4)

**Disadvantages**:
- For domain points w > y: we need g_content(f(y)) subset f(w). But f(w) was constructed BEFORE y existed and its seed did not include g_content(f(y)).
- This is the exact same problem, mirrored.

### Solution E: Use the FMCS Int Chain Directly

The most radical approach: **abandon the chronicle construction** for the g_content property and use the existing Int chain (CanonicalModel.lean) which already has `fwd_chain_g_content_trans` proved sorry-free.

The chronicle construction adds value only for Until/Since witnesses (C5/C5'). The Int chain already resolves F/P formulas via the schedule. The key question is: does the Int chain resolve Until formulas?

**Answer**: Not directly. The Int chain resolves F(phi) -> phi at some future step (via the schedule), but `U(xi, eta)` requires a specific witness structure: eta at the witness and xi at all intermediate points. The chronicle construction is needed precisely for this.

**Hybrid approach**: Use the Int chain for g_content/h_content propagation (which it handles correctly), and layer the chronicle's Until/Since witness machinery on top. This would require:
1. Building the Int chain from the root MCS
2. Using the chronicle to identify where Until/Since witnesses are needed
3. Proving that the Int chain eventually contains witnesses (via the schedule resolving F(eta) from U(xi, eta))

This is essentially what `chronicle_bfmcs_restricted_fuc` needs to prove, and the existing `limit_satisfies_c5_weak` already gives the witness existence. The gap is the guard condition and the g_content coherence.

### Solution F (RECOMMENDED): Direct Proof via Serial Witness Chains

**Key mathematical insight**: For x < y both in limit_dom, we can prove g_content(limit_f(x)) subset limit_f(y) without any omega-chain invariant.

**Proof**:
1. Let G(phi) in limit_f(x). Need phi in limit_f(y).
2. Suppose phi not in limit_f(y). Then neg(phi) in limit_f(y) (MCS).
3. Since y in limit_dom: F(neg(phi)) in limit_f(y)? No, we need to work from x's side.
4. G(phi) in limit_f(x). By temp_4: G(G(phi)) in limit_f(x). So F(phi) in limit_f(x)? No, G gives universal, not existential.
5. Actually: G(phi) in limit_f(x) means phi holds at ALL future points of x. But "all future points" in the semantics means all points strictly after x. In the limit_dom, y is one such point. So the conclusion phi in limit_f(y) is exactly what G(phi) MEANS semantically.

**BUT WAIT**: The semantic meaning of G(phi) requires a model. We are CONSTRUCTING the model. G(phi) in limit_f(x) is a syntactic membership, not a semantic truth. The g_content_chain_property is the bridge from syntactic membership to semantic truth for G.

This means there is no shortcut: we cannot use the "semantic meaning" of G until after we prove the chain property.

### Solution G (ACTUALLY RECOMMENDED): Strengthen the Omega-Chain to Track G-Content

The correct approach modifies the omega-chain to maintain `g_content(f(x)) subset f(y)` for all x < y in dom as an **explicit invariant**.

**Mechanism**: After each elimination step, if a new point p is inserted into dom:
1. For existing points y > p: we need g_content(f(p)) subset f(y). Since f(y) was constructed before p existed, we must REPLACE f(y) with a Lindenbaum extension of `f(y) union g_content(f(p))`.
2. For existing points x < p: g_content(f(x)) subset f(p) by construction (if p is inserted with seed including g_content of max predecessor), or by the existing invariant + transitivity.

**Critical consistency check for step 1**: Is `f(y) union g_content(f(p))` consistent?

YES, here is why: f(p) was constructed to contain g_content(f(x)) for some x <= p. If G(psi) in f(p), then psi in g_content(f(p)). Suppose neg(psi) in f(y). Since y > p > x, by the existing invariant (before insertion), g_content(f(x)) subset f(y). So we need: is it possible that G(psi) in f(p) but neg(psi) in f(y)?

f(p) contains g_content(f(x)), so G(psi) in f(p) could come from two sources:
- G(psi) was already in the seed (from g_content(f(x)) or {eta}): then G(psi) in f(x) by temp_4 gives G(G(psi)) in f(x), so G(psi) in g_content(f(x)) subset f(y). Then psi in g_content(f(y)) -- wait, that's G(psi) in f(y), not psi in f(y). We need psi in f(y), not G(psi).

Hmm. G(psi) in f(y) does NOT give psi in f(y) under strict semantics (no T-axiom for G).

**This consistency check FAILS for strict semantics.** The union g_content(f(p)) union f(y) can be inconsistent.

### Revised Assessment

After exhaustive analysis, every approach that tries to maintain g_content inclusion as an invariant of the finite chronicle faces the same fundamental issue: **under strict (irreflexive) temporal semantics, g_content(M) is not a subset of M**, so inserting a point p between x and y and then trying to extend f(y) to include g_content(f(p)) can create inconsistencies.

The Int chain avoids this because chain(n+1) is freshly constructed FROM g_content(chain(n)) -- it never needs to extend an EXISTING MCS to include NEW g_content. The chronicle, by inserting points between existing points, creates exactly this need.

### Solution H (FINAL RECOMMENDATION): Reformulate as a Limit Property Using Density

The g_content_chain_property can potentially be proved as a property of the LIMIT using the density and completeness of the chronicle construction, without maintaining it as a finite invariant.

**Approach**: For x < y in limit_dom, G(phi) in limit_f(x):

1. G(phi) in limit_f(x) means G(phi) in f_n(x) for some step n.
2. By temp_4: G(G(phi)) in f_n(x), so F(G(phi)) in f_n(x) -- NO, G does not imply F.
3. Actually: G(phi) in f_n(x). The formula G(phi) -> G(phi) U phi is not a theorem.
4. BUT: G(phi) -> phi U phi IS derivable? No, phi U phi requires a witness where phi holds, but G(phi) only says phi holds at future points.

**Alternative density argument**: G(phi) in limit_f(x). Consider any z with x < z < y, z in limit_dom. If phi in limit_f(z) for all such z, and the limit_dom is dense between x and y (which it IS, by repeated C5 elimination with midpoints and fresh rationals), then... we still need phi in limit_f(y) specifically.

**Key realization**: The problem reduces to: G(phi) in limit_f(x) and y in limit_dom with y > x. In the omega-chain, y entered at some step m. At step m, y was inserted with some seed. The seed included g_content(f(t)) for some triggering point t. If t >= x and g_content(f(x)) subset f(t) (by inductive assumption at step m), then G(phi) in f(x) => G(G(phi)) in f(x) => G(phi) in g_content(f(x)) subset f(t) => phi in g_content(f(t)) subset f(y).

**This works IF** we can establish g_content(f(x)) subset f(t) at the time y is inserted, where t is the triggering point. But t is the point from the counterexample being eliminated, which could be ANYWHERE in the domain -- it could be less than x, greater than x, etc.

The argument chain requires: x < t (or x = t), and g_content(f(x)) subset f(t) already holds. If t > x and the invariant holds for all pairs before insertion, then yes. If t < x, then we need g_content(f(x)) subset f(t) which goes the WRONG direction.

**This exposes the core issue**: the triggering point t can be on EITHER side of x. When t < x and the new point y > x, we have g_content(f(t)) subset f(y) by construction, but not g_content(f(x)) subset f(y).

## 6. Final Recommendation

After thorough analysis, I recommend **pursuing a two-track approach**:

### Track 1: Weaken the property needed

Investigate whether `g_content_chain_property` can be replaced by a weaker property that is actually provable. Specifically:

- The property is used for `limit_forward_G` and (via duality) `limit_backward_H`
- These are used in `chronicle_fmcs` for the FMCS's forward_G and backward_H fields
- Check whether the restricted parametric representation theorem needs full forward_G/backward_H, or whether a restricted version (only for formulas in deferralClosure(root)) suffices

If a restricted version suffices, we may be able to prove it using the chronicle's C5 properties and the schedule, without needing the full g_content chain property.

### Track 2: Modify the construction to maintain the invariant

If the full property is needed, modify `eliminate_potential_counterexample` to:

1. For C5-forward with triggering point t: insert y with seed `{eta} union g_content(f(t))`
2. **Additionally**: for each existing domain point w > t that is NOT the new point y, the existing invariant (before this step) already gives g_content(f(t)) subset f(w). For w that PRECEDES t, the invariant gives g_content(f(w)) subset f(t), and transitivity gives g_content(f(w)) subset f(y). So the only problematic direction is g_content(f(y)) subset f(w) for existing w > y -- but y is inserted BEYOND all domain points, so there are no such w.

**WAIT**: In the current code, C5-forward inserts y BEYOND all domain points (`exists_rat_gt_finset`). So there are NO existing w > y. The only pairs that need checking after insertion are (x, y) for all x in the old dom. For these:
- g_content(f(x)) subset f(y): need this
- The seed for f(y) is `{eta} union g_content(f(t))`
- If x = t: holds by construction
- If x < t: g_content(f(x)) subset f(t) by prior invariant, g_content(f(t)) subset f(y) by construction, transitivity (lemma_2_5b) gives g_content(f(x)) subset f(y)
- If x > t: g_content(f(x)) is NOT necessarily subset f(y)

**Critical sub-case**: x > t. We need g_content(f(x)) subset f(y). The seed for f(y) is `{eta} union g_content(f(t))`. f(y) contains g_content(f(t)) but potentially not g_content(f(x)).

Since y is beyond all domain points, the pairs (x, y) with x > t are exactly the problematic ones. The handoff's "enlarged seed" approach fails because F(eta) doesn't propagate to f(x) for x > t.

**Resolution for Track 2**: Instead of inserting y beyond ALL domain points, insert y between t and the next domain point after t. This ensures t is the maximum predecessor of y, so:
- For all x < y = all x <= t: g_content(f(x)) subset f(t) subset f(y) by transitivity
- No domain points exist beyond y (within [t, next_after_t])

Wait -- we need y > x for ALL x in dom (for C5: the witness is BEYOND x). But x might equal max(dom). So the witness must be beyond max(dom). This forces the current design of y > max(dom).

**Alternative**: Place y just above t (between t and next domain point above t). Then for the Until witness requirement: we need x < y. If x = t: done. If x < t: x < t < y, done. But if x > t... we don't need x < y for the witness -- the C5 condition is about a SPECIFIC x (the triggering point). The witness y only needs to satisfy t < y for the counterexample (t, xi, eta, c5_forward).

**BREAKTHROUGH**: The C5 counterexample specifies a SPECIFIC point x = t. The witness y only needs y > t, not y > max(dom). The current code uses `exists_rat_gt_finset` to place y beyond ALL domain points, but this is UNNECESSARY. We can place y anywhere above t.

If we place y between t and the next domain point above t (or just above max if t = max):
- Case 1: t < max(dom). Place y = (t + next_above_t) / 2. Now y is between t and some existing point w. For all x <= t: g_content(f(x)) subset f(y) by transitivity. For x > y (existing points above y): g_content(f(y)) subset f(x) is NOT needed immediately -- it's the OTHER direction. We need g_content(f(x)) subset f(y) for... wait, x > y means we need g_content(f(y)) subset f(x), not the other way.

Actually: g_content_chain_property says g_content(limit_f(x)) subset limit_f(y) for x < y. So for x < y in dom: g_content(f(x)) subset f(y). If y is between t and w: for x <= t < y: g_content(f(x)) subset f(y) by transitivity through t. For x >= y: not relevant (x > y is the opposite direction). So THIS WORKS for the forward direction.

But we also need the backward direction (the dual): for x > y, g_content(f(y)) subset f(x). This requires g_content of the newly inserted y to be subset of all existing points above y. g_content(f(y)) includes formulas whose G-versions are in f(y). f(y) was built from `{eta} union g_content(f(t))`, and is a Lindenbaum extension. We have no control over what G-formulas ended up in f(y), so g_content(f(y)) subset f(w) is not guaranteed.

**However**: by the duality bridge, g_content(f(y)) subset f(x) for y < x is equivalent to h_content(f(x)) subset f(y) (which is the backward/H direction). So the property is symmetric: proving one direction gives both.

**So**: if we place y just above t, we get g_content(f(x)) subset f(y) for all x < y (the forward direction) but NOT g_content(f(y)) subset f(x) for x > y.

The forward direction is exactly g_content_chain_property. The backward direction (g_content(f(y)) subset f(x) for y < x) is a different property -- it's what we'd need if we swap the roles.

Actually, re-reading the statement: `g_content_chain_property` says for ALL x < y in limit_dom, g_content(limit_f(x)) subset limit_f(y). This is a UNIVERSAL statement. We need it for EVERY pair with x < y.

With the modified insertion (y between t and next domain point), for the step where y is inserted:
- For all existing x < y: g_content(f(x)) subset f(y) -- PROVED (via transitivity through t)
- For existing w > y: g_content(f(y)) subset f(w) -- NOT proved

The second line IS part of the universal quantification (with y playing the role of x and w playing the role of y in the property statement).

**So the modified insertion helps only HALF the problem.**

### Definitive Analysis

The g_content_chain_property fundamentally requires, for EVERY pair x < y in the limit domain, that g_content(f(x)) subset f(y). The chronicle inserts points in arbitrary positions, and for EVERY insertion, the new point creates obligations in BOTH directions:
1. Forward: g_content of old predecessors must be in the new point's MCS (satisfiable by seed design)
2. Backward: g_content of the new point must be in old successors' MCS (NOT satisfiable without modifying old successors)

The Int chain avoids problem (2) because it only adds points at the END (successor position), so there are no "old successors." The chronicle cannot adopt this strategy because C4 elimination requires inserting BETWEEN existing points.

**However**: C5 elimination (which is the most common operation) CAN adopt this strategy -- it already inserts beyond all domain points. The issue is only with C4 elimination (midpoint insertion).

**Key question**: Do C4 counterexamples actually need elimination? The current code has C4 sorries (the hard sub-case). Are C4 counterexamples needed for the completeness theorem, or is C5 sufficient?

Looking at ChronicleToCountermodel.lean: it uses `limit_satisfies_c5_weak` which only needs C5 witnesses (eta at some future point), not the full guard condition. The restricted forward Until/Since coherence (`chronicle_bfmcs_restricted_fuc`) needs the guard condition, but perhaps this can be derived differently.

**If C4 elimination is not needed**, then all insertions are at the end (beyond max(dom)), and g_content(f(x)) subset f(y) for x < y can be maintained by always using seed `g_content(f(max(dom)))` (which subsumes g_content of all predecessors by transitivity + the invariant). The only issue is getting eta into the seed while maintaining consistency with g_content(f(max(dom))).

This reduces the problem to: is `{eta} union g_content(f(max(dom)))` consistent? This requires F(eta) in f(max(dom)), which fails as noted.

### Final Synthesis

The problem appears to be genuinely hard under strict semantics. I recommend the following path forward:

1. **Verify whether restricted forward_G suffices** for the parametric representation theorem. If only formulas in deferralClosure(root) need G-propagation, the property might be provable for that restricted set.

2. **If full g_content_chain_property is needed**: Consider an entirely different construction strategy where the chronicle is built by an "expanding outward" process (like the Int chain) rather than "filling inward" (like the current midpoint/beyond insertions). Specifically, build a forward chain from any MCS, resolve Until/Since by choosing the witness as the NEXT chain element, and use the Int chain's structure to get g_content inclusion for free.

3. **Immediate tactical step**: Prove that C4 elimination is not needed for the completeness theorem (the `sorry` in the hard C4 sub-case and the `sorry` in g_content_chain_property may be independent). If the completeness theorem only needs C5 + g_content propagation (no C4), then a simpler construction suffices.

## Appendix: Search Queries and References

### Codebase files examined
- `ChronicleConstruction.lean` -- omega_chain, limit_f, g_content_chain_property sorry
- `CounterexampleElimination.lean` -- C5/C4 elimination, EliminationResult
- `PointInsertion.lean` -- lemma_2_4, lemma_2_6, lemma_2_5b
- `ChronicleTypes.lean` -- Chronicle structure, conditions C0-C5
- `CanonicalModel.lean` -- Int chain, fwd_chain_g_content_step/trans
- `ChronicleToCountermodel.lean` -- chronicle_fmcs, extended_limit_f, 9 sorry sites

### Key theorems referenced
- `fwd_chain_g_content_step`: g_content(chain(n)) subset chain(n+1) -- sorry-free
- `fwd_chain_g_content_trans`: m < n => g_content(chain(m)) subset chain(n) -- sorry-free
- `lemma_2_5b`: g_content ordering transitivity via temp_4 -- sorry-free
- `g_content_sub_imp_h_content_sub`: g_content(A) subset B => h_content(B) subset A -- sorry-free
- `g_content_set_consistent`: g_content of MCS is consistent -- sorry-free
- `forward_temporal_witness_seed_consistent`: {psi} union g_content(M) consistent when F(psi) in M -- sorry-free
