# Teammate D Findings: Critical Validation of g_content Blocker Solutions

**Task**: 83 - Close Restricted Coherence Sorries
**Role**: Critic / Devil's Advocate
**Date**: 2026-04-03

## 1. Independent Mathematical Analysis

### Is `g_content(M) ⊆ successor(M)` semantically true under strict semantics?

Yes, unambiguously. In the canonical model with MCS's indexed by Z:
- `G(a) in MCS(t)` means `a` holds at all s > t under strict semantics
- In particular, `a` holds at `t+1`
- So `a in MCS(t+1)`, i.e., `a in g_content(MCS(t))` implies `a in MCS(t+1)`

The property is semantically correct. The question is purely proof-theoretic: can we derive `G(a) -> a` from the axiom system WITHOUT the T-axiom?

**Answer: No, we cannot derive `G(a) -> a` from the axiom system.** This is the entire point of strict semantics -- `G(a) -> a` is NOT valid when G quantifies over strictly future times. The property `g_content(M) ⊆ successor(M)` must be established through a DIFFERENT proof-theoretic route.

### The core confusion

There is a subtle but critical confusion in how the problem is framed. The semantic fact is:

> If `G(a) in MCS(t)` in a Z-indexed canonical model, then `a in MCS(t+1)`.

But this is a property of the CANONICAL MODEL CONSTRUCTION, not a general theorem about arbitrary MCS's. When we build the successor chain, we are not deriving `G(a) -> a` as a theorem -- we are using the CONSTRUCTION to ensure that the successor MCS contains `a` whenever the predecessor contains `G(a)`.

The chain construction (DovetailedChain, SuccChainFMCS) builds each successor MCS via Lindenbaum extension of a SEED that includes g_content. The key question is: **does the seed include `a` (the unwrapped formula) or `G(a)` (the wrapped formula)?**

Looking at the code:
- `forward_step` uses `temporal_theory_witness_exists` which builds a witness W from a seed
- The seed includes G-content via G-agreement: `G(a) in M -> G(a) in W`
- But getting `a in W` from `G(a) in W` previously required `temp_t_future` (the T-axiom)

## 2. Critical Evaluation of `G(a) -> X(a)` Approach

### Proposed derivation chain

The proposed route is: `G(a) -> a U a -> X(a v (a & (a U a))) -> X(a)`

**OBJECTION 1: `G(a) -> a U a` is NOT obviously derivable.**

Under strict semantics, `a U a` at t means: there exists s > t with a(s) and for all r with t < r < s, a(r). Semantically this follows from G(a) (take s = t+1, the guard interval (t, t+1) is empty on Z). But the derivation requires:

1. From `G(a)`, derive that a holds at t+1 (needs X(a) or discreteness)
2. X(a) = bot U a, which is what we're trying to derive

This is **circular**: to derive `G(a) -> X(a)`, we need `G(a) -> a U a`, which essentially requires `G(a) -> X(a)` already.

**OBJECTION 2: Alternative route through Until axioms.**

Could we derive `G(a) -> a U a` using `until_intro`? The `until_intro` axiom says:
```
X(psi v (phi & (phi U psi))) -> phi U psi
```
Instantiate with phi = a, psi = a:
```
X(a v (a & (a U a))) -> a U a
```
So we need `G(a) -> X(a v (a & (a U a)))`. This requires getting X(something) from G(a), which again requires the bridge between G and X.

**OBJECTION 3: The bridge between G and X.**

The key missing link is: **how does G(a) relate to X(a) in the proof system?**

Looking at the axiom system:
- `seriality_future`: `G(phi) -> F(phi)` (G implies F)
- `disc_next`: `F(top) -> X(top)` (F(top) implies X(top))
- `F_until_equiv`: `F(psi) -> top U psi` (F equals top U)

So: `G(a) -> F(a)` by seriality. Then `F(a) -> top U a` by F_until_equiv.

But `top U a` is NOT `X(a)`. `top U a` means: there exists s > t with a(s) and top at all r with t < r < s. This is just F(a). `X(a)` = `bot U a` means: there exists s > t with a(s) and bot at all r with t < r < s, which on Z means a(t+1) (because (t, t+1) is empty).

Can we get from `top U a` to `bot U a`? Not directly -- `top U a` says a holds at SOME future time, while `bot U a` says a holds at the NEXT time. These are different claims.

### The REAL derivation route: G(a) -> X(a) via discrete axioms

Let me try a different approach:

1. `G(a)` gives us `a` at ALL strictly future times
2. By `seriality_future`: `G(a) -> F(a)`, so `F(a)` holds
3. By `F(top)` (which follows from seriality: `G(top) -> F(top)`, and `G(top)` is a theorem by temporal necessitation of `top`): there is a future time
4. By `disc_next`: `F(top) -> X(top)`, so `X(top)` holds, meaning top at t+1
5. But we need `a` at t+1, not just `top` at t+1

The disc_next axiom only gives us `X(top)`, not `X(a)`. We need to combine:
- G(a): a at ALL future times
- X(top): there IS a next time

To conclude X(a): a at the next time.

**This requires a derivation that G(a) & X(top) -> X(a).**

Can this be derived? Let me think carefully:
- `G(a)` means `a` at all s > t
- `X(top)` means `top` at t+1 (i.e., t+1 exists)
- We want `X(a)` meaning `a` at t+1

Semantically, this is trivially true. But proof-theoretically, we need to show that from `G(a)`, we can derive `bot U a`.

**Key insight**: Try using `until_induction` in reverse. The `until_induction` axiom is:
```
G(psi -> chi) & G(phi & X(chi) -> chi) -> (phi U psi -> X(chi))
```

This is for deriving things FROM Until formulas, not for building Until formulas.

**Alternative**: Use `until_intro` directly:
```
until_intro: X(psi v (phi & (phi U psi))) -> phi U psi
```
Instantiate phi = bot, psi = a:
```
X(a v (bot & (bot U a))) -> bot U a
```
Simplify: `bot & anything = bot`, so `a v bot = a`, giving:
```
X(a) -> bot U a = X(a)
```
This is trivially `X(a) -> X(a)`, useless.

Let me try instantiating until_intro with phi = bot, psi = a more carefully.

Actually, `until_intro` says: `X(psi v (phi & (phi U psi))) -> phi U psi`.
With phi = bot, psi = a: `X(a v (bot & (bot U a))) -> bot U a`.

Now `bot & (bot U a)` simplifies to `bot` (since bot & anything = bot). So we need:
`X(a v bot) -> X(a)`, i.e., `X(a) -> X(a)`. Circular.

**Let me try a completely different approach.** Can we prove `G(a) -> bot U a` using the fact that `G(a) -> a U a` combined with `a U a -> X(a v (a & (a U a)))` (by until_unfold)?

Wait, this is the same circle. We need `G(a) -> a U a` first.

### The actual viable route

After careful analysis, I believe the correct route is:

**Step 1**: Derive `G(a) -> G(a) U a`.

This uses the fact that `G(a)` implies: there exists s > t with a(s) (by seriality), and at all r with t < r < s, G(a)(r) (by temp_4: G -> GG, so G(a) at all future times, hence G(a) at all r > t). So semantically, `G(a) U a` holds with any witness s > t.

But we need this proof-theoretically. The `until_intro` axiom gives:
```
X(a v (G(a) & (G(a) U a))) -> G(a) U a
```

We still need X of something from G(a). This is still circular.

**CRITICAL FINDING**: I believe `G(a) -> X(a)` is NOT derivable from the current axiom system without an additional axiom or rule.

The axiom system has:
- `G(a) -> F(a)` (seriality) -- gets us SOME future witness
- `F(top) -> X(top)` (disc_next) -- gets us the EXISTENCE of a next moment
- `G(a) -> G(G(a))` (temp_4) -- G persists

But none of these axioms connect G to X in a way that transfers the CONTENT of G to the next moment. The disc_next axiom only handles `top`, not arbitrary formulas.

### What axiom is actually needed?

The missing link is something like:
```
G(a) -> X(a)    -- "if a holds at all future times, it holds at the next time"
```

This is semantically valid on Z under strict semantics. But it is NOT derivable from the current axioms. The reason: the current axiom system can talk about X(top) via disc_next, and about G(a) -> F(a) via seriality, but there is no axiom that says "if a holds at all times in some interval containing t+1, then a holds at t+1."

**The fix**: Either:
1. Add `G(a) -> X(a)` as a new axiom (most direct)
2. Derive it from a strengthened disc_next: `F(a) & G(a) -> X(a)` or similar
3. Use the fact that `G(a) -> G(a) & F(a)`, and discreteness gives F(a) -> X(a) when the guard is always satisfied

### Wait -- can we derive `G(a) -> X(a)` from discreteness_forward?

The `discreteness_forward` axiom is:
```
(F(top) & a & H(a)) -> F(H(a))
```

This says: if there's a future, and a holds now and at all past times, then H(a) holds at some future time (the immediate successor). This is about the PAST operator H, not the future operator G.

The temporal dual would be: `(P(top) & a & G(a)) -> P(G(a))`, which says if a holds now and at all future times, then G(a) holds at some past time. This is not helpful either.

## 3. Circularity Check

The concern about circularity was:
> If G(a) -> X(a) derivation uses the successor construction, and the successor construction uses g_content(M) ⊆ successor(M), we have circularity.

This concern is VALID but somewhat moot because `G(a) -> X(a)` appears to be non-derivable from the current axiom system regardless.

However, if `G(a) -> X(a)` is added as a new axiom:
- The axiom is a purely proof-theoretic statement (a derivation rule)
- The successor construction uses the axiom via MCS closure
- There is no circularity because the axiom's soundness is proved semantically (against Z-frames), independently of the canonical construction

## 4. Analysis of ALL 14 Sorry Sites

### Pattern Classification

All 14 sorry sites follow exactly ONE pattern: they need `[] |- G(a) -> a` for some formula `a`. Specifically:

**Pattern A: Direct G(a) -> a for g_content inclusion (9 sites)**
- DovetailedChain.lean:142 -- `forward_step_g_content`
- DovetailedChain.lean:224 -- `forward_dovetailed_forward_G`
- DovetailedChain.lean:891 -- `backward_dovetailed_forward_G` base case
- DovetailedChain.lean:896 -- `backward_dovetailed_forward_G` inductive case
- MCSWitnessSuccessor.lean:259 -- `temporal_witness_g_persistence`
- TargetedChain.lean:242 -- `targeted_forward_chain_forward_G`
- TargetedChain.lean:478 -- another targeted chain G coherence
- UltrafilterChain.lean:2591 -- `temporal_witness_g_persistence` (algebraic)

**Pattern B: G(a) -> a for Lindenbaumm consistency arguments (3 sites)**
- SuccChainFMCS.lean:1244 -- g_content membership proof in DeferralRestrictedMCS
- SuccChainFMCS.lean:4276 -- deferral disjunction consistency
- SuccChainFMCS.lean:4419 -- G(neg_neg_bot) -> neg_neg_bot

**Pattern C: G(a) <= a in lattice/algebra (3 sites)**
- UltrafilterChain.lean:97 -- R_G reflexivity
- UltrafilterChain.lean:520 -- forward_G lemma
- UltrafilterChain.lean:1009 -- G(bot) <= bot

### Key observation

All 14 sites need the SAME thing: `G(a) -> a`. If we can provide a derivation of `G(a) -> X(a)` plus `X(a) -> a` (which is also not valid!), this won't work.

**Wait -- this changes the analysis entirely.** The sorry sites don't just need `G(a) -> X(a)`. They need `G(a) -> a` IN THE SAME MCS. That is, if `G(a) in W` where W is an MCS, they need `a in W`.

Under strict semantics, `G(a) -> a` is NOT valid. So `G(a)` being in an MCS does NOT guarantee `a` is in the same MCS. This is the FUNDAMENTAL issue.

The approach of deriving `G(a) -> X(a)` would give us `X(a) in W` (if `G(a) in W`), which means `a in successor(W)` -- the formula `a` is in the NEXT MCS, not the current one. This is exactly what's needed for `g_content(W) ⊆ successor(W)`, but it does NOT help with the Pattern B sites (SuccChainFMCS) which need `a` in the SAME MCS.

### Re-analysis of Pattern B sites

Let me re-read the Pattern B sites more carefully.

**SuccChainFMCS.lean:1244**: This is proving that g_content(u) ⊆ u for a DeferralRestrictedMCS u. The argument is: assume chi not in u, G(chi) in u, derive contradiction. It uses T-axiom to get chi from G(chi) in the SAME set u.

But wait -- g_content(u) ⊆ u means: if G(a) in u, then a in u. Under strict semantics, this is NOT guaranteed for arbitrary MCS. An MCS can contain G(a) without containing a (because G(a) -> a is not a theorem).

**This means the DeferralRestrictedMCS construction FUNDAMENTALLY assumes reflexive semantics.** Under strict semantics, g_content(u) ⊆ u is FALSE for some MCS u.

**SuccChainFMCS.lean:4276**: Similar -- proves chi in u from G(chi) in u. Same issue.

**SuccChainFMCS.lean:4419**: Proves neg_neg_bot in u from G(neg_neg_bot) in u. Same issue.

### Critical distinction: g_content(M) ⊆ M vs g_content(M) ⊆ successor(M)

Under strict semantics:
- `g_content(M) ⊆ M` is FALSE in general (G(a) does not imply a)
- `g_content(M) ⊆ successor(M)` is the correct property (G(a) implies a at the next time)

The Pattern A sites need `g_content(M) ⊆ successor(M)` -- this is what we WANT to prove for the chain construction.

The Pattern B sites need `g_content(u) ⊆ u` -- this is a DIFFERENT and STRONGER property that is NOT semantically valid under strict semantics.

**This is a major gap.** The SuccChainFMCS construction assumes a property that is invalid under strict semantics.

### UltrafilterChain Pattern C sites

- `R_G_refl`: Proves R_G is reflexive. R_G U U means: if G(a) in U then a in U. This is exactly `g_content(U) ⊆ U`, which is FALSE under strict semantics.

Under strict semantics, R_G is NOT reflexive! G quantifies over strictly future times, so R_G relates U to its successor, not to itself.

- `forward_G`: Uses `G(a) <= a` in the lattice. This ordering corresponds to derivability: `G(a) -> a`. Under strict semantics, this does NOT hold.

- `G(bot) <= bot`: `G(bot) -> bot` means "if bot holds at all future times, then bot holds now." Semantically, bot is false everywhere, so G(bot) is vacuously true (universal over empty-ish set) -- wait, on Z there IS always a future time, so G(bot) is FALSE (there exists s > t where bot should hold, but bot is always false). So G(bot) = false, and false -> false = true. But proof-theoretically, `G(bot) -> bot` requires `G(bot) -> F(bot)` (by seriality) and `F(bot) -> bot` (because F(bot) = exists s > t, false, which is false). So `F(bot) -> bot` is derivable (it's a propositional tautology about F(bot) = ~G~bot = ~G(top) -- hmm, this needs more care).

Actually: `F(bot)` = `~G(~bot)` = `~G(top)`. And `G(top)` is derivable (temporal necessitation of top). So `~G(top)` is FALSE in all MCS. Hence `F(bot)` is not in any MCS. And `G(bot) -> F(bot)` by seriality. If `G(bot)` were in an MCS, then `F(bot)` would be too, contradiction. So `G(bot)` is not in any MCS. Therefore `G(bot) -> bot` is vacuously true in all MCS, and derivable.

So the UltrafilterChain.lean:1009 site (`G(bot) <= bot`) is actually still derivable under strict semantics, just through a different route (seriality + F(bot) impossible).

## 5. FMCS Structure Analysis

The current FMCS definition (FMCSDef.lean:99-117):
```
structure FMCS where
  mcs : D -> Set Formula
  is_mcs : forall t, SetMaximalConsistent (mcs t)
  forward_G : forall t t' phi, t < t' -> Formula.all_future phi in mcs t -> phi in mcs t'
  backward_H : forall t t' phi, t' < t -> Formula.all_past phi in mcs t -> phi in mcs t'
```

The `forward_G` field says: G(phi) at time t implies phi at all strictly future times t'. This IS semantically correct under strict semantics -- it says that if G(phi) is in the MCS at time t, then phi should be in the MCS at any time t' > t. This is correct because G(phi) at t means phi at all s > t.

**This field does NOT require `G(phi) -> phi` (the T-axiom).** It requires `G(phi) at t -> phi at t'` for t' > t, which is a property of the CHAIN, not of individual MCS.

So the FMCS structure is correctly defined for strict semantics. The question is whether the chain constructions can PROVE this field.

## 6. Review of Past Research Warnings

From report 10 (team research), section on "The Real Hardest Problems":
- Problem #1 was identified as "X truth lemma backward direction" -- this is about `chi in mcs(t+1) -> X(chi) in mcs(t)`, a different issue
- Problem #3 was "T-axiom removal cascade" at 67+ call sites -- this was identified as HIGH effort but LOW conceptual risk

The past research DID warn about the T-axiom cascade but classified it as a mechanical refactoring problem. **It missed the deeper issue**: some of the sorry sites (Pattern B in SuccChainFMCS) are not just "replace T-axiom with alternative derivation" -- they assume a PROPERTY (`g_content(u) ⊆ u`) that is semantically invalid under strict semantics.

From report 11 (strict refactor specification), section on the SuccChainFMCS:
- The spec focused on replacing temp_t_future calls with `G(a) -> X(a)` derivations
- But the SuccChainFMCS Pattern B sites cannot be fixed this way

## 7. Alternative Approaches

### Approach 1: Modify the chain seed to include a directly

Instead of relying on `G(a) -> a` inside an MCS, modify the chain construction so that when building successor MCS, the SEED explicitly includes `{a : G(a) in predecessor}`.

Current seed: includes G-content via G-agreement (`G(a) in M -> G(a) in W`).
Proposed seed: includes both G-content AND unwrapped g_content (`G(a) in M -> G(a) in W AND a in W`).

This means the Lindenbaum extension starts with a larger seed. The key question is whether this larger seed is CONSISTENT.

**Consistency of the enlarged seed**: We need `{a : G(a) in M} ∪ {G(a) : G(a) in M} ∪ other_seed` to be consistent. Since M is an MCS containing G(a), and G(a) -> F(a) by seriality, there exists a future time where a holds. The temporal witness construction already produces a W where a holds. So the seed IS consistent.

This approach works for Pattern A sites but may need adaptation for Pattern B.

### Approach 2: Restructure SuccChainFMCS to not need g_content(u) ⊆ u

The Pattern B sites in SuccChainFMCS assume g_content(u) ⊆ u for the DeferralRestrictedMCS u. Under strict semantics, this property fails. The DeferralRestrictedMCS construction needs to be redesigned.

Possible redesign: instead of requiring g_content(u) ⊆ u (which gives "G formulas in u are unwrapped in u"), require only that g_content(u) ⊆ successor(u). The DeferralRestrictedMCS consistency arguments would then need to account for the fact that G(a) in u does not give a in u.

### Approach 3: Add `G(a) -> X(a)` as an axiom

If `G(a) -> X(a)` is added as an axiom, then:
- Pattern A sites: `G(a) in M -> X(a) in M -> a in successor(M)`. This works.
- Pattern B sites: `G(a) in u -> X(a) in u`. But we need `a in u`, not `X(a) in u`. So this does NOT fix Pattern B.
- Pattern C sites: `G(a) -> X(a)` gives `G(a) <= X(a)` in the lattice, but we need `G(a) <= a`. `X(a) <= a` is not valid either (X(a) means a at the next time, not at the current time).

**Approach 3 does NOT solve Pattern B and C sites.**

### Approach 4: Accept that R_G is not reflexive, redesign the algebraic approach

Under strict semantics, R_G (defined as G(a) in U implies a in U) is NOT reflexive. Instead, R_G relates an ultrafilter to its "successor" in the temporal order. The UltrafilterChain needs to be restructured to use R_G as a successor relation rather than a preorder.

## 8. Recommended Approach

**My recommendation differs from the other teammates.** I believe the problem is deeper than "replace T-axiom uses with G(a) -> X(a) derivation." The real issue has three layers:

### Layer 1: Chain construction g_content propagation (Pattern A -- 9 sites)
**Solution**: Modify chain seed construction to explicitly include unwrapped g_content.
**Difficulty**: MEDIUM. The seed consistency proof needs updating but follows from temporal witness existence.
**Confidence**: HIGH that this works.

### Layer 2: DeferralRestrictedMCS assumes g_content(u) ⊆ u (Pattern B -- 3 sites)
**Solution**: Redesign DeferralRestrictedMCS for strict semantics. The property g_content(u) ⊆ u is not needed if the construction is modified to only require g_content(u) ⊆ successor(u).
**Difficulty**: HIGH. This may require significant restructuring of the SuccChainFMCS construction.
**Confidence**: MEDIUM. The restructuring is non-trivial and may reveal further dependencies.

### Layer 3: Algebraic R_G reflexivity (Pattern C -- 3 sites)
**Solution**: R_G is not reflexive under strict semantics. The UltrafilterChain needs a fundamentally different structure where R_G is a successor relation on an ordered set of ultrafilters, not a reflexive preorder.
**Difficulty**: HIGH. This is an architectural change to the algebraic approach.
**Confidence**: MEDIUM. The algebraic approach was always the secondary track; the MCS-based approach (Patterns A and B) is primary.

### Overall recommendation

1. **First priority**: Fix Pattern A (9 sites) by modifying the chain seed. This is the most impactful change.
2. **Second priority**: Analyze Pattern B (3 sites in SuccChainFMCS) to determine if the DeferralRestrictedMCS construction can be adapted or needs to be replaced.
3. **Third priority**: Decide whether to fix or abandon the algebraic UltrafilterChain approach (Pattern C, 3 sites).

**The `G(a) -> X(a)` approach is necessary but NOT sufficient.** It solves Pattern A but leaves Patterns B and C unresolved.

## 9. Derivability of G(a) -> X(a)

Despite my objections in section 2, let me reconsider whether `G(a) -> X(a)` can be derived.

**Attempt using until_intro + G properties:**

1. From `G(a)`, derive `G(a) & G(G(a))` (by temp_4: G(a) -> G(G(a)))
2. We want to show `bot U a`, i.e., X(a)
3. By `until_intro` (with phi=bot, psi=a): `X(a v (bot & X(a))) -> X(a)`, which simplifies to `X(a) -> X(a)`. Useless.

**Attempt using seriality + discreteness:**

1. `G(a) -> F(a)` by seriality
2. `F(a) = ~G(~a)` -- there exists s > t with a(s)
3. Need: a(t+1). F(a) only gives existence, not at t+1 specifically.
4. `disc_next`: `F(top) -> X(top)`. This says the successor exists but says nothing about a.

**Key gap**: disc_next is `F(top) -> X(top)`, which is `F(top) -> bot U top`. There is no axiom that generalizes this to `F(a) & G(a) -> X(a)` or even `G(a) -> X(a)`.

**Could we use until_induction?**

`until_induction`: `G(psi -> chi) & G(phi & X(chi) -> chi) -> (phi U psi -> X(chi))`

We don't have `phi U psi` to start from, so this is not directly applicable.

**Verdict: G(a) -> X(a) requires a new axiom or a derivable connection between G and X that I cannot find in the current 33-axiom system.**

If this cannot be derived, it MUST be added as axiom #34. This is semantically sound on Z: G(a) at t means a at all s > t, so a at t+1, so X(a) at t.

## 10. Confidence Assessment

| Claim | Confidence |
|-------|-----------|
| g_content(M) ⊆ successor(M) is semantically correct under strict Z | HIGH (100%) |
| G(a) -> a is not derivable without T-axiom | HIGH (100%) |
| G(a) -> X(a) is not derivable from current 33 axioms | MEDIUM-HIGH (85%) -- I may be missing a derivation route |
| Pattern A sites are fixable by seed modification | HIGH (90%) |
| Pattern B sites require DeferralRestrictedMCS redesign | HIGH (85%) |
| Pattern C sites require algebraic architecture change | HIGH (85%) |
| G(a) -> X(a) as new axiom is sound on Z | HIGH (100%) |
| Overall strategy of "just derive G(a) -> X(a) and replace" is INSUFFICIENT | HIGH (90%) |

## 11. Key Blind Spots to Investigate

1. **Is there a derivation of G(a) -> X(a) I'm missing?** Specifically, can the combination of `disc_next`, `until_intro`, `until_unfold`, `seriality_future`, and `temp_4` yield this? I've tried several routes and failed, but a more creative combination might work.

2. **How many of the Pattern B sites are actually reachable?** If the SuccChainFMCS construction is not used in the primary completeness proof path (only the DovetailedChain is), then Pattern B might be deferrable.

3. **Can `g_content(u) ⊆ u` be weakened to a usable property in the SuccChainFMCS context?** For example, could we use `G(a) in u -> G(a) in u` (trivially true) combined with `G(a) -> X(a)` (new axiom) to get `X(a) in u`, then use some other property of the DeferralRestrictedMCS?

4. **What is the relationship between DeferralRestrictedMCS and the successor chain?** If DeferralRestrictedMCS is used to construct the successor in the chain, then needing g_content(u) ⊆ u might be replaceable with g_content(u) ⊆ successor_of(u).
