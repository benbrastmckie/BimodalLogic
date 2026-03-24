# Task 55: Prove SuccChain Temporal Coherence Directly

## Research Report

### 1. Sorry Chain Trace

The sorry chain for temporal coherence flows as follows:

```
f_nesting_is_bounded (line 731, SuccChainFMCS.lean)     -- sorry: FALSE for arbitrary MCS
  |
  v
f_nesting_boundary (line 755)                           -- calls f_nesting_is_bounded
  |
  +-- succ_chain_forward_F (line 811)                   -- calls f_nesting_boundary
  |     |
  |     v
  +-- succ_chain_forward_F_neg (line 767)               -- calls f_nesting_boundary
        |
        v
SuccChainTemporalCoherent (line 1156)                   -- uses succ_chain_forward_F
  |
  v
temporal_backward_G / temporal_backward_H               -- uses SuccChainTemporalCoherent
  |
  v
succ_chain_truth_lemma (all_future/all_past backward)   -- uses temporal_backward_G/H
  |
  v
succ_chain_truth_forward                                -- key for completeness
  |
  v
succ_chain_completeness                                 -- final theorem
```

Symmetric chain for past direction:
```
p_nesting_is_bounded (line 966) -> p_nesting_boundary (line 978)
  -> succ_chain_backward_P (line 1083) -> SuccChainTemporalCoherent
```

**Root cause**: `f_nesting_is_bounded` and `p_nesting_is_bounded` claim that for ANY SetMaximalConsistent M, the sequence F^n(phi) eventually leaves M. This is FALSE -- an arbitrary MCS built by Lindenbaum can consistently contain all F-iterations {F^n(p) | n in Nat}.

### 2. What SuccChainTemporalCoherent Requires

The `TemporalCoherentFamily Int` structure (TemporalCoherence.lean, line 146) needs:

```lean
structure TemporalCoherentFamily (D : Type*) [Preorder D] [Zero D] extends FMCS D where
  forward_F : forall t phi, F(phi) in mcs t -> exists s > t, phi in mcs s
  backward_P : forall t phi, P(phi) in mcs t -> exists s < t, phi in mcs s
```

These are used in TemporalCoherence.lean to derive:
- `temporal_backward_G`: If phi in mcs s for all s > t, then G(phi) in mcs t (by contraposition using forward_F)
- `temporal_backward_H`: If phi in mcs s for all s < t, then H(phi) in mcs t (by contraposition using backward_P)

The backward lemmas are needed for the all_future/all_past backward cases of the truth lemma.

### 3. Analysis of SuccChain Construction

The succ_chain_fam is built from a SerialMCS M0:

- **forward_chain M0 n**: Built by iterating `constrained_successor_from_seed`, which extends `g_content(u) union deferralDisjunctions(u)` to a full MCS via Lindenbaum. Adjacent elements satisfy `Succ u v` (g_persistence + f_step).

- **backward_chain M0 n**: Built by iterating `predecessor_from_deferral_seed`, symmetric construction. Adjacent elements satisfy `Succ (chain n+1) (chain n)`.

- **Succ relation**: `Succ u v` means (1) g_content(u) subset v, and (2) f_content(u) subset v union f_content(v). Condition (2) is the F-step: each F-obligation is either resolved (phi in v) or deferred (F(phi) in v).

The key mechanism for F-obligation resolution is `bounded_witness` (CanonicalTaskRelation.lean, line 650):
- If iter_F d phi in u and iter_F (d+1) phi not in u, and we have a chain of d Succ-steps from u to v, then phi in v.
- Proof is by induction on d, using `single_step_forcing` at each step.

### 4. The Core Mathematical Argument

**Why temporal coherence holds directly**: The argument needs to show that F(phi) in succ_chain_fam M0 n implies exists m > n with phi in succ_chain_fam M0 m.

The current proof strategy (via f_nesting_boundary + bounded_witness) is sound for RESTRICTED MCS but fails for arbitrary MCS. Two approaches exist:

#### Approach A: Lindenbaum Extension Transfer (RECOMMENDED)

The restricted chain infrastructure is largely in place:
- `restricted_forward_chain` builds a chain within deferralClosure(phi)
- `restricted_forward_chain_F_bounded` proves F-iterations are bounded (no sorry)
- `restricted_forward_chain_forward_F` proves forward_F for the restricted chain

The remaining sorries (4-6 total) are ALL in the same boundary case pattern: when `FF(psi) is outside deferralClosure` but `F(psi)` is inside. The issue is that `neg(FF(psi))` cannot be derived in the restricted MCS because `FF(psi)` is outside the closure, so negation completeness doesn't apply.

**The fix**: Use the Lindenbaum extension approach. Each restricted chain element can be extended to a full MCS via `extendToMCS`. The key insight:

1. Let u_R = restricted_forward_chain(phi, M0, k) and v_R = restricted_forward_chain(phi, M0, k+1)
2. Let u_E = extendToMCS(u_R) and v_E = extendToMCS(v_R) -- full MCS
3. u_E is a full SetMaximalConsistent, so neg(FF(psi)) in u_E (by negation completeness)
4. Therefore GG(neg(psi)) in u_E (by neg_FF_implies_GG_neg_in_mcs)
5. However, G(neg(psi)) is in g_content(u_E), not necessarily g_content(u_R)

**Problem with naive extension**: The Succ relation between u_R and v_R does NOT automatically lift to Succ between u_E and v_E. The extension adds arbitrary formulas outside deferralClosure. So bounded_witness cannot be applied directly to the extended chain.

**Alternative fix within Approach A**: Instead of lifting the whole chain, use the extension locally:
1. F(psi) in u_R implies F(psi) in u_E (since u_R subset u_E)
2. In u_E (full MCS), f_nesting_is_bounded is FALSE, so this doesn't help directly
3. But in u_R (restricted), F-nesting IS bounded by restricted_forward_chain_F_bounded

The actual fix is to handle the boundary case directly without needing neg(FF(psi)):

#### Approach B: Direct F-Step Resolution Without GG (RECOMMENDED)

The boundary case occurs when:
- F(psi) in restricted chain(k)
- FF(psi) NOT in restricted chain(k) (specifically, not even in deferralClosure)
- We need to show psi in restricted chain(k+1)

Since FF(psi) is outside deferralClosure, it is also outside chain(k). So we have:
- F(psi) in chain(k) -- i.e., psi in f_content(chain(k))
- FF(psi) not in chain(k) -- i.e., F(psi) not in f_content(chain(k))

By the Succ f_step property: f_content(chain(k)) subset chain(k+1) union f_content(chain(k+1))
- psi in f_content(chain(k)) means F(psi) in chain(k)
- So psi in chain(k+1) union f_content(chain(k+1))
- f_content(chain(k+1)) means F(psi) in chain(k+1)
- But F(psi) in chain(k+1) means F(psi) in deferralClosure (since chain subset deferralClosure)

Now, we need to show F(psi) NOT in chain(k+1). This is where the current code uses the GG argument (which needs negation completeness for FF(psi)).

**Key insight**: If FF(psi) is outside deferralClosure, and chain(k+1) subset deferralClosure, we CANNOT conclude FF(psi) not in chain(k+1) directly... wait, we CAN: chain(k+1) subset deferralClosure and FF(psi) not in deferralClosure implies FF(psi) not in chain(k+1).

So actually: FF(psi) not in chain(k+1) because FF(psi) not in deferralClosure and chain(k+1) subset deferralClosure.

This means F(psi) not in f_content(chain(k+1)) (since f_content(S) = {phi | F(phi) in S}, and F(psi) in f_content means FF(psi) in S, but FF(psi) not in chain(k+1)).

Wait -- f_content(chain(k+1)) = {chi | F(chi) in chain(k+1)}, so psi in f_content(chain(k+1)) iff F(psi) in chain(k+1), not FF(psi).

Let me re-trace. The f_step says: f_content(u) subset v union f_content(v). Here f_content(u) = {chi | F(chi) in u}. So psi in f_content(u) iff F(psi) in u.

For single_step_forcing, we have:
- F(psi) in u (given)
- FF(psi) not in u (given)
- psi in f_content(u) because F(psi) in u
- By f_step: psi in v union f_content(v)
- psi in f_content(v) means F(psi) in v
- We need F(psi) NOT in v to conclude psi in v

To show F(psi) not in v: The original proof uses GG(neg(psi)) in v which blocks F(psi). But we need a different argument.

**The problem**: Even when FF(psi) not in u, the successor v might independently contain F(psi) through the deferral seed construction. Specifically, F(psi) can enter v via:
1. f_content path: FF(psi) in u and deferred -- blocked because FF(psi) not in u
2. g_content path: GF(psi) in u -- this IS possible even when FF(psi) not in u!

So F(psi) in v is possible via g_content if GF(psi) in u. The strengthened version `restricted_succ_propagates_F_not'` adds h_GF_not as a hypothesis, but then needs to prove GF(psi) not in chain(k) when using bounded_witness.

#### Approach C: Bypass Restricted Chain Entirely (CLEANEST)

**Observation**: The completeness theorem actually does NOT use restricted chains at all. It uses the unrestricted `succ_chain_fam` via `succ_chain_truth_forward`. The sorry chain is:

```
succ_chain_forward_F -> f_nesting_boundary -> f_nesting_is_bounded (sorry)
```

Instead of trying to fix f_nesting_is_bounded for arbitrary MCS (impossible) or migrating to restricted chains (complex), we can:

1. **Restructure the completeness proof** to use restricted chains from the start
2. Build a DeferralRestrictedSerialMCS from the target formula's closure
3. Use the restricted chain's forward_F (which IS provable modulo the boundary sorries)
4. Then transfer results back via the Lindenbaum extension

**Concrete plan**:

Step 1: Prove the boundary case sorries (lines 3072, 3104, 3118, 3189) by tracking that when FF(psi) is outside deferralClosure, the f_step directly forces resolution because deferral is impossible.

Step 2: This requires showing that when FF(psi) not in deferralClosure:
- F(psi) not in f_content(chain(k+1)) because F(psi) in f_content means FF(psi) in chain(k+1) which is impossible (chain subset deferralClosure)

Wait, I made an error above. Let me re-check:
- psi in f_content(S) iff F(psi) in S -- YES
- So F(psi) in f_content(S) iff FF(psi) in S -- YES

For single_step_forcing boundary case:
- F(psi) in u (given, psi = original phi in the bounded_witness sense)
- FF(psi) not in u (given)
- Need: psi in v
- By f_step: psi in v union f_content(v) (since F(psi) in u means psi in f_content(u))
- psi in f_content(v) means F(psi) in v
- Need to rule out F(psi) in v

Here's the key: We CANNOT rule out F(psi) in v without the GG argument, because F(psi) CAN enter v via g_content even when FF(psi) not in u.

### 5. Recommended Proof Strategy

After thorough analysis, the cleanest approach is the **Lindenbaum Extension Argument** applied to the EXISTING unrestricted chain, not the restricted chain. Here is the strategy:

#### Strategy: Direct Proof of succ_chain_forward_F Without f_nesting_is_bounded

**Key idea**: Instead of using f_nesting_boundary to find the exact boundary d, prove forward_F directly using the Succ f_step property and well-founded induction on formula complexity within deferralClosure.

**New theorem**: `succ_chain_forward_F_direct`

```
theorem succ_chain_forward_F_direct (M0 : SerialMCS) (n : Int) (phi : Formula)
    (h_F : Formula.some_future phi in succ_chain_fam M0 n) :
    exists m > n, phi in succ_chain_fam M0 m
```

**Proof sketch using well-founded measure**:

Define measure(n, psi) = number of formulas chi in deferralClosure(psi) such that chi is a temporal subformula of F(psi) and chi in succ_chain_fam M0 n. This is bounded by |deferralClosure(psi)| which is finite.

Actually, this doesn't work because succ_chain_fam uses arbitrary MCS and the measure would need to decrease.

#### REVISED Strategy: Prove f_nesting_is_bounded for the Specific MCS in the Chain

**Key insight that was missed**: While `f_nesting_is_bounded` is FALSE for ARBITRARY MCS, it may be PROVABLE for MCS that arise from the succ_chain construction, because these MCS are built by the constrained_successor_from_seed construction which only extends specific seeds.

However, this is also problematic -- the Lindenbaum extension in the seed construction can add arbitrary formulas.

#### FINAL Strategy (Best approach): Fix the Restricted Chain Boundary Sorries

After extensive analysis, the most tractable approach is:

**Step 1**: Fix `restricted_single_step_forcing` boundary case (line 3072)

The boundary case has: F(psi) in chain(k), FF(psi) not in chain(k) (because FF(psi) not in deferralClosure).

By f_step: psi in chain(k+1) OR F(psi) in chain(k+1).

If F(psi) in chain(k+1), then since chain(k+1) subset deferralClosure, F(psi) in deferralClosure. Now:
- FF(psi) not in deferralClosure (given)
- F(psi) in chain(k+1) and chain(k+1) subset deferralClosure
- Apply f_step of Succ(chain(k+1), chain(k+2)): psi in chain(k+2) OR F(psi) in chain(k+2)
- If F(psi) in chain(k+2), apply again...

This gives an infinite descent argument: at each step, either psi appears (done) or F(psi) persists. But F(psi) persisting forever would mean F(psi) in ALL chain(m) for m > k. Then by temporal_backward_G (which we're trying to prove...), G(F(psi)) in chain(k), so F(psi) in chain(k) (by T-axiom G(A)->A). Then FF(psi) in chain(k) -- contradiction!

Wait, but temporal_backward_G itself depends on forward_F, which is what we're proving. This is circular.

**Step 2**: Break the circularity by proving forward_F and backward_G simultaneously via strong induction on formula size.

Actually, the truth lemma is already proved by induction on formula structure (succ_chain_truth_lemma). The issue is that the forward_F and backward_P are used as INPUTS to this induction, not derived from it.

**Step 3 (ACTUAL RECOMMENDED APPROACH)**: Inline the forward_F argument into the truth lemma induction.

Currently the truth lemma is structured as:
1. First prove forward_F (needs f_nesting_boundary -- blocked)
2. Then use forward_F to prove backward_G (via contraposition)
3. Then prove truth lemma using forward_G and backward_G

**Restructured approach**: Prove the truth lemma biconditional by induction on formula structure, where the all_future backward case is handled by contraposition INLINE, using the semantic truth of the model (not forward_F on MCS membership).

For the all_future backward case:
- Need: if truth_at(all_future phi, t) then G(phi) in mcs(t)
- By contraposition: assume G(phi) not in mcs(t)
- Then neg(G(phi)) in mcs(t) (negation completeness)
- So F(neg(phi)) in mcs(t) (by temporal duality)
- By IH forward on F: truth_at(F(neg(phi)), t) -- need some_future IH!

This still requires forward_F for the some_future subformula. The some_future case needs forward_F which needs f_nesting_boundary.

**Step 4**: The ACTUAL solution -- prove forward_F for the truth lemma's specific needs.

The truth lemma only needs forward_F at formula `neg(phi)` when proving the all_future backward case for `phi`. The formula `neg(phi)` is STRICTLY SMALLER in structural terms than `all_future phi`.

But forward_F is about MCS membership, not truth. We need:
- F(neg(phi)) in mcs(t) implies exists s > t with neg(phi) in mcs(s)

This is the full forward_F statement. We cannot avoid it.

### 6. Definitive Recommended Approach

After exhaustive analysis of all approaches, the recommended path is:

**Approach: Prove the boundary-case sorries in the restricted chain, then wire the restricted chain into the completeness proof.**

The boundary case (FF(psi) outside deferralClosure) has a clean resolution:

When FF(psi) not in deferralClosure:
1. FF(psi) not in chain(k) (since chain subset deferralClosure) -- this is the HYPOTHESIS
2. F(psi) may or may not be in deferralClosure

Case 2a: F(psi) not in deferralClosure -> F(psi) not in chain(k+1) -> psi in chain(k+1) by f_step. DONE.

Case 2b: F(psi) in deferralClosure but FF(psi) not in deferralClosure.
- By f_step: psi in chain(k+1) OR psi in f_content(chain(k+1)) i.e. F(psi) in chain(k+1)
- If psi in chain(k+1): DONE
- If F(psi) in chain(k+1): need to show this leads to contradiction or resolution

The f_content membership F(psi) in chain(k+1) can itself be resolved: apply f_step of Succ(chain(k+1), chain(k+2)):
- psi in chain(k+2) OR F(psi) in chain(k+2)
- If F(psi) keeps deferring: it enters an infinite loop
- But the chain is well-defined for all n, so we need a termination argument

**Key lemma needed**: If F(psi) in chain(k) and F(psi) in chain(k+1) and ... and F(psi) in chain(k+N) for all N, then the MCS at every position contains F(psi). This is consistent (F(psi) can be in every MCS). The issue is that we WANT psi to eventually appear, not F(psi).

This is precisely what f_nesting_is_bounded was supposed to guarantee, and it's FALSE for arbitrary MCS.

**THE SOLUTION**: For the restricted chain, this IS provable! The restricted chain elements are within deferralClosure(phi). If F(psi) keeps appearing in chain elements (all within deferralClosure), then psi is in the f_content at every step. But deferralClosure is FINITE, and the deferral disjunction construction (chi OR F(chi) for F(chi) in u) ensures progress.

The actual proof:
1. F(psi) in chain(k) where chain(k) subset deferralClosure(phi)
2. restricted_forward_chain_F_bounded gives d >= 1 with iter_F d psi in chain(k) and iter_F(d+1) psi not in chain(k)
3. d >= 1 means iter_F 1 psi = F(psi) in chain(k) (we already know this)
4. If d = 1: F(psi) in chain(k) and FF(psi) not in chain(k). This IS the boundary case.
5. Apply single_step_forcing for restricted chain to get psi in chain(k+1)
6. Step 5 IS the boundary sorry we're trying to resolve!

**RESOLUTION**: The boundary case sorry CAN be resolved using the `restricted_succ_propagates_F_not'` strengthened version WITH an additional lemma proving that GF(psi) not in chain(k) when FF(psi) not in deferralClosure.

Lemma: If FF(psi) not in deferralClosure(phi), then GF(psi) not in deferralClosure(phi), therefore GF(psi) not in chain(k).

**Proof of the lemma**: GF(psi) = G(F(psi)) = (F(psi).neg.all_future.neg).neg... wait. G(chi) = all_future(chi). If G(F(psi)) in deferralClosure, then by deferralClosure_all_future, F(psi) is a subformula of something in closureWithNeg(phi). And if F(psi) in deferralClosure (which it is, since F(psi) in chain(k) subset deferralClosure), then:

Actually, the deferralClosure contains:
- closureWithNeg(phi)
- For each F(chi) in closureWithNeg: chi OR F(chi) (the deferral disjunction)

G(F(psi)) = all_future(some_future(psi)). This is in deferralClosure only if all_future(some_future(psi)) is in closureWithNeg(phi) -- i.e., GF(psi) is a subformula of phi (or its negation).

**This is NOT guaranteed.** GF(psi) may or may not be in deferralClosure depending on the specific phi.

However, GF(psi) being in chain(k) IMPLIES GF(psi) in deferralClosure (since chain subset deferralClosure). So either:
- GF(psi) in deferralClosure: then it might be in chain(k)
- GF(psi) not in deferralClosure: then GF(psi) not in chain(k), and the strengthened theorem applies!

For the case GF(psi) IN deferralClosure:
- We have both F(psi) in deferralClosure and GF(psi) in deferralClosure
- FF(psi) NOT in deferralClosure
- By deferralClosure construction: if GF(psi) in closureWithNeg, then...

Actually, let me check: does GF(psi) in deferralClosure imply FF(psi) in deferralClosure?

No! GF(psi) = all_future(some_future(psi)) and FF(psi) = some_future(some_future(psi)). These are different formulas. GF could be a subformula of phi while FF is not.

**So the case split is**:
1. GF(psi) NOT in deferralClosure -> GF(psi) not in chain(k) -> use strengthened theorem (no sorry)
2. GF(psi) IN deferralClosure -> negation completeness applies to GF(psi) -> either GF(psi) or neg(GF(psi)) in chain(k)
   - If neg(GF(psi)) in chain(k): Then F(psi) not in g_content(chain(k)), and we can proceed
   - If GF(psi) in chain(k): F(psi) in chain(k+1) via g_content. But we also know by f_step that psi is either in chain(k+1) or deferred...

Case 2 with GF(psi) in chain(k) is the hard case. Here F(psi) enters chain(k+1) via g_content. Then by G's T-axiom, GF(psi) -> F(psi), so F(psi) in chain(k) too. Which we already know. And GF(psi) in chain(k) means by g_persistence, F(psi) in chain(k+1). Then GF(psi) propagates: by temp_4 axiom G(A) -> GG(A), GF(psi) -> G(GF(psi)), so GF(psi) in g_content(chain(k)), hence GF(psi) in chain(k+1). By induction, F(psi) in ALL chain(m) for m >= k.

But we need psi to APPEAR. The key is: GF(psi) in chain(k) means "at every future time, there exists a further future time with psi". This is semantically satisfied by the construction (psi is in f_content at every step, and by the deferral disjunction, psi OR F(psi) is in the seed).

**The deferral disjunction is the key**: The successor seed includes `psi OR F(psi)` for each F(psi) in u. In a full MCS, either psi or F(psi) is chosen. If F(psi) is always chosen, we never get psi. This is the essence of why f_nesting_is_bounded is false.

However, for RESTRICTED MCS, the deferralClosure is FINITE. Each chain element is within deferralClosure. The F-bounded theorem says iter_F iterations eventually leave the chain element. But this gives bounds WITHIN a single MCS, not across the chain.

### 7. Final Recommended Strategy

**Priority 1: Fix restricted_succ_propagates_F_not for the case FF(psi) in deferralClosure (line 3104)**

This sorry has the hypothesis: FF(psi) in deferralClosure, FF(psi) not in chain(k). By DeferralRestrictedMCS negation completeness (since FF(psi) in deferralClosure), neg(FF(psi)) in chain(k). Then apply `neg_FF_implies_GG_neg_in_mcs`... but wait, that theorem requires SetMaximalConsistent, not DeferralRestrictedMCS.

**ACTION ITEM**: Prove a DeferralRestrictedMCS version of `neg_FF_implies_GG_neg_in_mcs`. This requires:
1. neg(FF(psi)) in the restricted MCS
2. The derivation GG(neg(psi)) from neg(FF(psi)) only uses proof-theoretic steps (no additional membership assumptions)
3. Since the restricted MCS is closed under derivation for formulas in deferralClosure, we need GG(neg(psi)) in deferralClosure
4. GG(neg(psi)) = all_future(all_future(neg(psi))) -- this needs to be in deferralClosure

**CHECK**: Is all_future(all_future(neg(psi))) in deferralClosure when some_future(some_future(psi)) is?

If FF(psi) in deferralClosure and FF(psi) in closureWithNeg(phi), then some_future(psi) is a subformula, so all_future(neg(psi)) = neg(some_future(psi)).neg = ... Actually this is getting into formula encoding details.

The core formula identity: F(A) = neg(G(neg(A))). So neg(F(F(A))) = neg(neg(G(neg(F(A))))) by expanding the outer F. By DNE, this gives G(neg(F(A))). Then neg(F(A)) = neg(neg(G(neg(A)))) which by DNE gives G(neg(A)). So neg(FF(A)) gives G(G(neg(A))).

The derivation uses: neg(FF(A)) -> G(neg(F(A))) -> G(G(neg(A))). The intermediate formulas are G(neg(F(A))) and G(G(neg(A))).

For these to be in deferralClosure: need neg(F(A)) and G(neg(A)) in the closure. Since F(A) is in deferralClosure (F(A) = some_future(A) in closureWithNeg from FF(A) being there), neg(F(A)) = G(neg(A)).neg.neg... this is getting complex.

**The actual encoding**: In this system, F(phi) = phi.neg.all_future.neg (i.e., neg(G(neg(phi)))). So:
- neg(F(A)) = (A.neg.all_future.neg).imp bot = G(neg(A)).neg.imp bot
- which is G(neg(A)).neg.neg by formula encoding

The derivation doesn't require the intermediate formulas to be IN the MCS's closure -- it only requires that the CONCLUSION (GG(neg(A))) is in the closure so that the MCS can "contain" it.

For a DeferralRestrictedMCS, closure under derivation means: if premises are in the MCS and the conclusion is in deferralClosure, then the conclusion is in the MCS. We need:
- neg(FF(A)) in DRM (hypothesis)
- GG(neg(A)) in deferralClosure (need to verify)

If FF(A) = some_future(some_future(A)) in deferralClosure, we need all_future(all_future(A.neg)) in deferralClosure. By the closure construction, if all_future(A.neg) is in closureWithNeg (which it should be since some_future(A) = A.neg.all_future.neg is in closureWithNeg and all_future(A.neg) is a subformula), then all_future(all_future(A.neg)) should also be in closureWithNeg if it's a subformula of phi.

This is not guaranteed in general! The deferralClosure may contain FF(psi) but not GG(neg(psi)).

**Priority 2: Alternative approach -- prove neg_FF_implies_GG_neg for DRM using "closed under provable consequence within deferralClosure"**

The DRM is closed under provable consequence for formulas in deferralClosure. The question is whether GG(neg(psi)) is in deferralClosure when FF(psi) is.

**Lemma to prove**: If some_future(some_future(psi)) in deferralClosure(phi), then all_future(all_future(psi.neg)) in deferralClosure(phi).

This likely holds because of the structure of closureWithNeg: it contains both a formula and its negation form, and subformulas. F(A) = neg(G(neg(A))), so if FF(A) is a subformula/closure member, then G(neg(A)) should be too (as an intermediate subformula).

**This is the key lemma to verify in the implementation phase.**

### 8. Implementation Plan Summary

**Phase 1**: Verify the formula membership lemma
- Prove: FF(psi) in closureWithNeg(phi) implies GG(neg(psi)) in closureWithNeg(phi)
- This should follow from the subformula closure properties
- Key file: Theories/Bimodal/Syntax/SubformulaClosure.lean

**Phase 2**: Prove DRM version of neg_FF_implies_GG_neg
- Adapt neg_FF_implies_GG_neg_in_mcs for DeferralRestrictedMCS
- Use DRM closure under derivation + the Phase 1 membership lemma
- Key file: Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean

**Phase 3**: Fix boundary case sorries
- Fix restricted_single_step_forcing (line 3072)
- Fix restricted_succ_propagates_F_not (lines 3104, 3118)
- Fix restricted_succ_propagates_F_not' (line 3189)
- Key file: Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean

**Phase 4**: Wire restricted chain into completeness
- Replace succ_chain_forward_F (which calls f_nesting_boundary) with a version using restricted chains
- Option A: Build restricted chain from M0, prove forward_F, then transfer to unrestricted chain
- Option B: Restructure completeness to use restricted chain directly
- Key files: SuccChainFMCS.lean, SuccChainCompleteness.lean

**Phase 5**: Remove deprecated sorries
- Delete f_nesting_is_bounded and p_nesting_is_bounded (marked deprecated)
- Update callers to use restricted versions
- Clean up backward compatibility shims

### 9. Risk Assessment

- **Phase 1** (formula membership): LOW risk -- mechanical verification of closure properties
- **Phase 2** (DRM neg_FF_implies_GG_neg): MEDIUM risk -- needs careful formula encoding
- **Phase 3** (boundary sorries): MEDIUM risk -- the main technical content
- **Phase 4** (wiring): MEDIUM risk -- structural refactoring, may affect other modules
- **Phase 5** (cleanup): LOW risk -- removing dead code

**Blocking risk**: If the formula membership lemma (Phase 1) fails (GG(neg psi) NOT in deferralClosure when FF(psi) is), then the restricted approach needs a fundamentally different argument. In that case, consider:
- Enlarging deferralClosure to include GG(neg) forms
- Using a different closure definition
- Proving forward_F by a completely different method (e.g., semantic argument via model construction)

### 10. Relevant Mathlib Lemmas

- `Nat.find` / `Nat.find_spec` / `Nat.find_le` -- used in f_nesting_boundary_of_bounded for finding minimal witnesses
- `Nat.decreasingInduction` -- could help with well-founded arguments on formula depth
- `Set.Finite` -- for bounding iterations within finite closures
- `Finset.card_lt_card` -- for strict decrease arguments on finite sets

### 11. Files Involved

| File | Role | Modification Needed |
|------|------|-------------------|
| `Theories/Bimodal/Syntax/SubformulaClosure.lean` | Closure definitions | Add GG-from-FF membership lemma |
| `Theories/Bimodal/Metalogic/Core/RestrictedMCS.lean` | DRM definitions | Add DRM neg_FF_implies_GG_neg |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` | Main sorry chain | Fix boundary sorries, wire restricted chain |
| `Theories/Bimodal/Metalogic/Bundle/SuccChainTruth.lean` | Truth lemma | May need adjustment |
| `Theories/Bimodal/Metalogic/Completeness/SuccChainCompleteness.lean` | Completeness | Wire to restricted chain |
