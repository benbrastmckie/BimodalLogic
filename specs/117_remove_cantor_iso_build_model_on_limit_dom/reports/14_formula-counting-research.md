# Formula-Counting Path to IsSuccArchimedean: Research Report

- **Task**: 117
- **Focus**: Can finite DC-types (pigeonhole) prove IsSuccArchimedean or bypass it?
- **Date**: 2026-05-09

## Executive Summary

The formula-counting approach (pigeonhole on deferral closure types) does NOT provide a path to prove IsSuccArchimedean, nor does it enable bypassing the Z-isomorphism entirely. The user's Q8 insight about the G backward direction being self-proving (without explicit restricted_tc) is mathematically correct but does NOT extend to the Until/Since cases, which constitute the actual hard problem. The three coherence conditions (restricted_tc, restricted_buc, restricted_fuc) are all genuinely required by the truth lemma, and cannot be eliminated.

## Q1: Does the truth lemma for G/H follow from forward_G/backward_H alone?

**Answer: YES for the forward direction, NO for the backward direction without restricted_tc.**

### Forward direction (G(psi) in MCS -> truth at all future times)

This uses only `fam.forward_G` (an FMCS field, not a coherence condition). At line 394 of `RestrictedParametricTruthLemma.lean`:

```lean
intro h_G s hts
have h_psi_mcs : ψ ∈ fam.mcs s := fam.forward_G t s ψ hts h_G
exact (ih h_ψ_sub fam hfam s).mp h_psi_mcs
```

No coherence conditions used -- only `forward_G` from the FMCS structure.

### Backward direction (truth at all future times -> G(psi) in MCS)

This REQUIRES `restricted_temporal_backward_G_strict`, which in turn requires `h_forward_F` from `h_rtc` (restricted temporal coherence). At lines 397-404:

```lean
obtain ⟨h_forward_F, h_backward_P⟩ := h_rtc fam hfam
...
exact restricted_temporal_backward_G_strict fam root h_forward_F
    t ψ h_neg_ψ_dc h_all_mcs
```

The backward G proof uses a contrapositive argument:
1. Assume G(psi) is NOT in fam.mcs(t)
2. Then neg(G(psi)) = F(neg(psi)) is in fam.mcs(t)
3. By `h_forward_F`: exists s > t with neg(psi) in fam.mcs(s)
4. But by hypothesis, psi is in fam.mcs(s) -- contradiction

Step 3 is the critical use of `forward_F` (from restricted_tc). Without it, the proof fails.

### User's insight about the "self-proving" backward G

The user proposed that if the G truth lemma is proved first (by induction), then F(phi) in MCS <-> exists m > t, phi at m follows from the G truth lemma's contrapositive. This is correct in SEMANTICS -- once you have the truth lemma for G, you get F for free since F(phi) = neg(G(neg(phi))). But the issue is that **you need forward_F to PROVE the G truth lemma's backward direction in the first place**. The argument is:

- To prove G backward, you need forward_F (restricted_tc)
- Once G backward is proved, F truth lemma follows
- But F truth lemma is what forward_F provides

This is **circular**. Forward_F (restricted_tc) is a PRECONDITION for the G backward proof, not a CONSEQUENCE of it.

### Why the circularity cannot be broken

The truth lemma is proved by induction on formula complexity. The G case invokes the IH on psi (a strictly simpler formula). But the backward G case needs forward_F for `neg(psi)`, which is a formula of complexity equal to psi + 1. The forward_F for neg(psi) cannot come from the induction hypothesis -- it must come from the restricted_tc hypothesis.

**One potential escape**: If the FMCS structure itself guaranteed forward_F for all formulas in the deferral closure (as a field, like forward_G), then no separate coherence condition would be needed. But the FMCS structure only has forward_G and backward_H, not forward_F/backward_P.

## Q2: Does the truth lemma for Until/Since NEED restricted_fuc/buc?

**Answer: YES, absolutely. Both forward and backward Until/Since coherence are essential.**

### Forward Until (U(phi,psi) in MCS -> exists witness with guard)

At lines 425-432 of the fully restricted truth lemma:

```lean
obtain ⟨h_fwd_U, _⟩ := h_fuc fam hfam
...
obtain ⟨s, h_ts, h_phi_s, h_psi_guard⟩ := h_fwd_U t phi psi h_sub h_U
```

This directly uses `restricted_forward_until_since_coherent`. Without it, there is no way to extract a witness s > t with phi at s and psi on guard. The FMCS structure provides NOTHING about Until/Since -- only G/H propagation.

### Backward Until (witness with guard -> U(phi,psi) in MCS)

At lines 433-436:

```lean
obtain ⟨h_bwd_U, _⟩ := h_buc fam hfam
...
exact h_bwd_U t phi psi h_sub ⟨s, h_ts, ...⟩
```

This directly uses `restricted_backward_until_since_coherent`. The backward direction converts a semantic witness pattern into MCS membership of U(phi,psi).

### Can backward Until be derived from G/H truth lemma + MCS properties?

**No.** The key obstacle: knowing phi is true at some s > t and psi is true at all r in (t,s) does NOT give U(phi,psi) in fam.mcs(t) from the G/H truth lemma alone. The Until formula is syntactically independent from G/H. There is no axiom or theorem of the form "phi at s and psi on (t,s) implies U(phi,psi) at t" that works purely at the MCS level without additional chain structure.

In Burgess's framework, the backward direction uses C4 (counterexample elimination): if neg(U(phi,psi)) were in f(t), then for any y > t with phi in f(y), C4 gives z in (t,y) with neg(psi) in f(z), contradicting the guard. This is a proof by contradiction using C4, not derivable from G/H alone.

## Q3: What EXACTLY does each coherence condition require?

### restricted_temporally_coherent (restricted_tc)

**Definition** (TemporalCoherence.lean:295-300):
```
∀ fam ∈ B.families,
  (∀ t φ, φ ∈ deferralClosure root →
    F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s) ∧
  (∀ t φ, φ ∈ deferralClosure root →
    P(φ) ∈ fam.mcs t → ∃ s < t, φ ∈ fam.mcs s)
```

**Used by**: Backward G and backward H cases of the truth lemma.
**Scope**: Only formulas in `deferralClosure(root)` -- a finite set.

### restricted_forward_until_since_coherent (restricted_fuc)

**Definition** (TemporalCoherence.lean:535-544):
```
∀ fam ∈ B.families,
  (∀ t φ ψ, U(φ,ψ) ∈ subformulaClosure root →
    U(φ,ψ) ∈ fam.mcs t →
    ∃ s > t, φ ∈ fam.mcs s ∧ ∀ r ∈ (t,s), ψ ∈ fam.mcs r) ∧
  (symmetric for S)
```

**Used by**: Forward Until and forward Since cases of the truth lemma.
**Scope**: Only Until/Since formulas in `subformulaClosure(root)`.

### restricted_backward_until_since_coherent (restricted_buc)

**Definition** (TemporalCoherence.lean:565-574):
```
∀ fam ∈ B.families,
  (∀ t φ ψ, U(φ,ψ) ∈ subformulaClosure root →
    (∃ s > t, φ ∈ fam.mcs s ∧ ∀ r ∈ (t,s), ψ ∈ fam.mcs r) →
    U(φ,ψ) ∈ fam.mcs t) ∧
  (symmetric for S)
```

**Used by**: Backward Until and backward Since cases of the truth lemma.
**Scope**: Only Until/Since formulas in `subformulaClosure(root)`.

## Q4: Can the direct Int chain (forward_G/backward_H only, no C4/C5) satisfy the truth lemma?

**Answer: NO.** The direct Int chain from `RootScopedChain.lean` (the `bx_bfmcs` construction) provides:
- forward_G: YES (from the R relation and g_content)
- backward_H: YES (from the R relation and h_content)
- restricted_tc: SORRY (line 186) -- cannot prove F-resolution
- restricted_buc: SORRY (line 193) -- cannot prove backward Until
- restricted_fuc: SORRY (line 198) -- cannot prove forward Until

Without these three coherence conditions, the truth lemma cannot be proved for G backward, Until forward, or Until backward. The direct Int chain is mathematically incapable of satisfying these conditions because:

1. **restricted_tc failure**: The schedule-based chain resolves ONE formula per step. F(phi) obligations can be permanently lost if they leave the chain before being resolved (proven in `fwd_chain_F_not_return`, lines 113-143). Once F(phi) is not in chain(n), it is never in chain(m) for m > n, so the F-witness can never appear.

2. **restricted_fuc failure**: Until(phi,psi) requires finding a witness s with phi at s AND psi at all intermediate points. The Lindenbaum-based chain construction does not control which formulas appear at each step -- it only resolves one counterexample at a time.

3. **restricted_buc failure**: The backward Until requires a step transfer property: U(phi,psi) at chain(n+1) and psi at chain(n) implies U(phi,psi) at chain(n). This requires additional chain structure (bot-Until content, enriched seeds) that the schedule-based chain does not have.

## Q5: Can pigeonhole on DC-types prove IsSuccArchimedean?

**Answer: NO.** The pigeonhole argument observes that there are at most 2^n distinct DC-types (truth assignments of deferralClosure formulas), so in a succ chain of length > 2^n, two elements must share the same DC-type. However:

1. **DC-type repetition does not constrain order geometry.** Having the same DC-type at positions succ^i(0) and succ^j(0) means the same formulas from DC are true at both positions, but the POSITIONS in Rat are different. This says nothing about whether the succ chain reaches any particular target element b.

2. **IsSuccArchimedean is about ORDER structure, not logical content.** The property states: for any a <= b, there exists n such that succ^n(a) >= b. This is about the monotonic progression of the succ function through the ordered set. The logical content of the MCS at each position is irrelevant.

3. **The succ function is defined by C5 witnesses in limit_dom.** Each succ step goes from x to the C5 witness y (the least domain point > x). The question is whether iterating this process reaches any target b. This depends on the DISTRIBUTION of limit_dom points in Rat, not on their DC-types.

## Q6: Can formula-counting avoid IsSuccArchimedean by working with a finite chronicle?

**Answer: NO, not in a way that bypasses the Z-isomorphism.**

### The finite model approach

One could try to build a finite model on Int directly using the pigeonhole periodicity: find a periodic pattern of DC-types and extend it to all of Int. However:

1. **truth_at on Int quantifies over ALL integers.** For G(phi) at n, truth requires phi at ALL m > n, not just within a finite window. A periodic pattern handles this, but...

2. **Until coherence on the periodic model is unproved.** The user's analysis in Q2 of the prompt correctly identifies that the C4-based argument for the periodic chain is circular: it uses the truth lemma (being proved) to derive C4 satisfaction. The C4/C5 properties are NOT inherited by sub-patterns extracted from the chronicle.

3. **The chronicle's coherence is for the FULL limit_dom.** The C5 witness for U(phi,psi) at position x might be at an arbitrary position y in limit_dom. There is no guarantee that y is in the succ-reachable part.

### The critical issue (Q7-Q8 synthesis)

The user's Q7 asks whether F-resolution witnesses are always in the succ-reachable part R = {succ^k(0) | k in Z}. The answer:

- If IsSuccArchimedean holds: R = limit_dom, so yes.
- If IsSuccArchimedean fails: R is a PROPER subset of limit_dom. There exist limit_dom elements above R's supremum (twin accumulation scenario). F-resolution witnesses can be in the "upper" part, inaccessible from R.

## Q7: What IS the real path forward?

### Assessment of current approaches

**Approach A (current plan Phase 4): Prove IsSuccArchimedean directly.**
- Status: sorry, with detailed analysis showing difficulty
- The gap lemma argument is mathematically sound but hard to formalize
- Blocking on: well-founded termination measure for the pred-descent

**Approach B: Build countermodel on LimitDomSubtype (bypass Z-iso).**
- Requires: AddCommGroup on LimitDomSubtype -- IMPOSSIBLE (LimitDomSubtype is a countable subset of Rat with no group structure)
- The completeness theorem existentially quantifies over D with [AddCommGroup D], so D must have this structure
- LimitDomSubtype has no addition operation (sum of two limit_dom elements is generally not in limit_dom)

**Approach C: Use the chronicle case-split (current plan Phases 5-7).**
- Dense case: D = Rat via Cantor iso. Compiles modulo the density g-value consistency sorry in CounterexampleElimination.lean.
- Discrete case: D = Int via Z-iso. Requires IsSuccArchimedean (the blocker).
- This is the current plan. The IsSuccArchimedean sorry is the only remaining blocker for the discrete case.

### The formula-counting idea applied to the GAP LEMMA

While formula-counting cannot prove IsSuccArchimedean directly, it CAN help with the **gap lemma** (the sub-problem blocking IsSuccArchimedean):

**Gap lemma**: For consecutive dom_N elements q < r (no other dom_N elements between them), show succ^k(q) = pred(r) for some k (equivalently, limit_dom intersect [q,r] is finite in the discrete case).

**Formula-counting argument for the gap lemma**:
- In the discrete case, U(T,bot) is in every domain MCS
- Between q and r, there are no dom_N elements
- But there CAN be limit_dom elements (from later stages N' > N)
- Each such element z has an MCS f(z) with U(T,bot) in it
- The DC-type of z is determined by finitely many formulas
- By pigeonhole, if there were infinitely many limit_dom elements in (q,r), two would share a DC-type
- Since succ(z) is the unique immediate successor (by discreteness), the succ chain from z is deterministic
- Two elements with the same DC-type, connected by succ, would form a cycle -- impossible in a linear order

This argument MIGHT work for the gap lemma, but it requires careful formalization. The key step is showing that DC-type repetition + deterministic succ chain implies a cycle, which contradicts linearity.

**However**: this argument requires the succ chain to connect two elements with the same DC-type, which is exactly what the gap lemma is trying to prove. There is a subtle circularity.

### Recommended path

The formula-counting approach does NOT provide a shortcut around the fundamental difficulties. The recommended path remains:

1. **Continue with the gap lemma approach** for IsSuccArchimedean (as in the current plan)
2. **OR** find a different well-founded measure for the pred-descent argument
3. **OR** reformulate IsSuccArchimedean as a consequence of the chronicle's omega chain structure (each limit_dom element appears at some stage N, and stages are well-ordered)

The most promising concrete idea: each limit_dom element first appears at some stage N. For elements in (q,r) where q,r are dom_N elements, any element z in (q,r) must first appear at stage N' > N. At stage N', z is added via C4 or C5 resolution. This resolution process is well-ordered by N', and at each stage only finitely many elements are added. So limit_dom intersect (q,r) is countable and well-ordered by "stage of first appearance." If it were infinite, the stages would form an infinite ascending sequence, but the elements accumulate in the BOUNDED interval (q,r) in Rat, and their values must be monotonically ordered by stage in some way that contradicts the well-ordering of the rationals.

This is the "gap lemma via stage induction" approach from earlier reports, and it remains the most viable path.

## Summary of Findings

| Question | Answer |
|----------|--------|
| Q1: G/H truth lemma from forward_G/backward_H alone? | Forward: YES. Backward: NO (needs forward_F from restricted_tc) |
| Q2: Until/Since truth lemma without fuc/buc? | NO. Both are essential |
| Q3: What does each coherence condition require? | restricted_tc: F/P resolution for deferralClosure. fuc: Until/Since witness extraction. buc: Until/Since witness introduction |
| Q4: Direct Int chain satisfies truth lemma? | NO. Missing all three coherence conditions (3 sorries in RootScopedChain) |
| Q5: Pigeonhole proves IsSuccArchimedean? | NO. DC-types constrain logical content, not order geometry |
| Q6: Finite sub-chronicle avoids IsSuccArchimedean? | NO. truth_at quantifies over all D, and AddCommGroup is required on D |
| Q7: F-resolution witnesses always in succ-reachable part? | Only if IsSuccArchimedean holds |
| Q8: Can formula-counting help at all? | Marginally -- might help with the gap lemma sub-problem, but with subtle circularity |

## Key Architectural Insight

The user's analysis in the prompt contains a deep mathematical error at Q8. The argument goes:

> "If phi not in chain(k) for ALL k > n: then neg(phi) in chain(k) for all k > n (MCS). Then G(neg(phi)) should be 'true' at n. By the truth lemma (being proved): G(neg(phi)) in chain(n). But F(phi) = neg(G(neg(phi))) in chain(n). Contradiction."

This reasoning is correct as a SEMANTIC argument once the truth lemma is established. But it is CIRCULAR when used to PROVE the truth lemma, because:

1. The truth lemma for G(neg(phi)) requires the backward G direction
2. The backward G direction requires forward_F (restricted_tc)
3. Forward_F is exactly the property being "proved" by this argument

The truth lemma proof is by induction on formula complexity. At the G case, the IH gives the truth lemma for psi (strictly simpler than G(psi)). The backward direction needs forward_F for neg(psi), which has the SAME complexity as G(psi) if psi is atomic, or HIGHER complexity otherwise. The IH cannot provide forward_F -- it must come from restricted_tc.

This circularity is fundamental and cannot be broken by any reformulation of the induction.
