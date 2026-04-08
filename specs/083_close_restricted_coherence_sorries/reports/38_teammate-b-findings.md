# Teammate B: Canonical World Histories -- Chain Characterization and Omega Design

- **Task**: 83 - Close Restricted Coherence Sorries
- **Focus**: Mathematical correspondence between MCS chains and canonical world histories; Omega design for the truth lemma
- **Date**: 2026-04-07
- **Session**: sess_1775625087_9b0bc5
- **Sources**: TaskFrame.lean, WorldHistory.lean, Truth.lean, CanonicalConstruction.lean, CanonicalFrame.lean, SuccRelation.lean, SuccChainFMCS.lean, TemporalContent.lean, WitnessSeed.lean, BXCanonical/Frame.lean, BXCanonical/TruthLemma.lean, Boneyard/ChainCompleteness/Bundle/*

---

## Part 1: The Canonical TaskFrame and Its World Histories

### 1.1 The Canonical TaskFrame (Review)

The canonical TaskFrame (defined in `CanonicalConstruction.lean`) has:

- **WorldState** = `CanonicalWorldState` = `{ M : Set Formula // SetMaximalConsistent M }`
- **D** = `Int` (discrete integer time)
- **task_rel** = `canonical_task_rel`, defined as:
  - `d > 0`: `ExistsTask M.val N.val` (i.e., `g_content(M) SUBSET N`)
  - `d = 0`: `M = N`
  - `d < 0`: `ExistsTask N.val M.val` (i.e., `g_content(N) SUBSET M`)

Compositionality for non-negative durations holds via `existsTask_transitive`, which uses the axiom `G(phi) -> G(G(phi))` (temp_4).

### 1.2 What Is a World History in the Canonical Frame?

A `WorldHistory CanonicalTaskFrame` is a structure with:
- `domain : Int -> Prop` (convex subset of Z)
- `states : (t : Int) -> domain t -> CanonicalWorldState`
- `respects_task`: for all s, t in domain with s <= t, `canonical_task_rel (states s) (t - s) (states t)`

Since `respects_task` only uses `s <= t` (so `d = t - s >= 0`), we have two cases:
- **d > 0** (s < t): requires `ExistsTask (states s).val (states t).val`, i.e., `g_content(w_s) SUBSET w_t`
- **d = 0** (s = t): requires `states s = states t`, which is trivially true

**Conclusion**: A world history is a function `tau : dom -> CanonicalWorldState` on a convex subset `dom SUBSET Z` such that for all s < t in dom:

```
g_content(tau(s).val) SUBSET tau(t).val
```

### 1.3 Characterization: World Histories = g_content-Chains

**Definition (g_content-chain)**: A sequence of MCS `(..., w_{-1}, w_0, w_1, ...)` indexed over a convex `dom SUBSET Z` such that for all i < j in dom, `g_content(w_i) SUBSET w_j`.

**Proposition 1.3.1**: The world histories of the canonical TaskFrame are exactly the g_content-chains.

**Proof**: The forward direction follows from the definition of `canonical_task_rel`. For the converse, given a g_content-chain, define `states(t) = w_t`. For s <= t:
- If s = t: `canonical_task_rel` at `d = 0` requires `states s = states t`, which holds.
- If s < t: `canonical_task_rel` at `d = t - s > 0` requires `g_content(w_s) SUBSET w_t`, which holds by hypothesis.

### 1.4 Consecutive Steps Suffice

**Proposition 1.4.1**: A sequence `(w_i)_{i in dom}` with `dom` convex is a g_content-chain if and only if `g_content(w_i) SUBSET w_{i+1}` for all consecutive `i, i+1 in dom`.

**Proof**:
- **Forward**: Take j = i + 1.
- **Backward** (induction on j - i): For j - i = 1, direct. For j - i = k + 1 > 1, by the induction hypothesis `g_content(w_i) SUBSET w_{i+k}`. We also have `g_content(w_{i+k}) SUBSET w_j`. We need `g_content(w_i) SUBSET w_j`.

  Take phi in g_content(w_i), i.e., G(phi) in w_i. By temp_4 (`G(phi) -> G(G(phi))`), G(G(phi)) in w_i. So G(phi) in g_content(w_i). By induction hypothesis, G(phi) in w_{i+k}. Then phi in g_content(w_{i+k}) SUBSET w_j.

  This establishes `g_content(w_i) SUBSET w_j` by chaining through `existsTask_transitive`.

### 1.5 Relationship Between World Histories and Succ-Chains

The existing `Succ` relation (SuccRelation.lean) requires TWO conditions:
1. **g_content persistence**: `g_content(u) SUBSET v`
2. **f_content step**: `f_content(u) SUBSET v UNION f_content(v)`

A world history only requires condition (1). Condition (2) is NOT part of the definition of a world history -- it is additional structure needed to resolve F-obligations (and hence Until obligations) along the chain.

**Key insight**: Every Succ-chain is a world history, but not every world history is a Succ-chain. Succ-chains are a STRICT SUBSET of world histories, with the f_content step providing the extra structure needed for the truth lemma.

For the truth lemma, we need histories that are MORE than just g_content-chains. The f_content condition (or some analog for Until) is what enables eventuality resolution. This distinction is crucial for Omega design.

---

## Part 2: Omega Design -- Which Histories Go Into Omega?

### 2.1 The Truth Lemma Requirements on Omega

The truth lemma states: for a history tau in Omega and time t,

```
phi in tau(t).val  iff  truth_at CanonicalTaskModel Omega tau t phi
```

The critical cases that constrain Omega are:

**Box case**: `Box(phi) in w_0 iff (for all sigma in Omega, truth_at ... sigma 0 phi)`

- **Forward**: `Box(phi) in w_0` and `sigma in Omega` implies `phi` true at `sigma` at time 0. By IH, this means `phi in sigma(0).val`. So we need: **for all sigma in Omega, Box(phi) in w_0 implies phi in sigma(0).val**. This means all histories in Omega at time 0 must have their MCS in the same S5 modal equivalence class as w_0.

- **Backward**: If `Box(phi) not_in w_0`, there must exist `sigma in Omega` with `phi not_in sigma(0).val`. So Omega must be rich enough to witness modal non-memberships.

**Until case (forward)**: `phi U psi in w_0` implies `exists j >= 0, psi in w_j AND for all i in [0, j), phi in w_i`.

This is a statement about the SAME history tau. No Omega constraint here -- it's about the internal structure of tau.

**G case (forward)**: `G(phi) in w_0` implies `for all s >= 0, phi in w_s`. This holds by the g_content-chain property of the history.

### 2.2 Three Candidate Omega Designs

#### Option A: Omega = All World Histories

**Definition**: `Omega_A = { tau : WorldHistory CanonicalTaskFrame | True }`

**Problems**:
- **Box forward fails**: We need: Box(phi) in w_0 implies phi in sigma(0).val for ALL sigma in Omega_A. But there exist world histories where sigma(0) contains arbitrary MCS. This COMPLETELY BREAKS the box case.

**Verdict**: REJECTED.

#### Option B: Omega = All Succ-Chains from a Single BFMCS Bundle

**Definition** (existing): `CanonicalOmega B = { tau | exists fam in B.families, tau = to_history fam }`

**Advantages**:
- Box forward works: Box(phi) in fam.mcs(t) implies phi in fam'.mcs(t) for all fam' in B, by modal_forward.
- Box backward works: phi in fam'.mcs(t) for all fam' implies Box(phi) in fam.mcs(t), by modal_backward.

**Problems**:
- **Until/Since forward fails**: Given phi U psi in fam.mcs(0), we need to find j >= 0 with psi in fam.mcs(j). But the FMCS family `fam` was constructed BEFORE we knew which Until formulas needed resolution. The family may not resolve this particular Until.

**Verdict**: PARTIALLY WORKS. Box is fine, but Until/Since require additional structure.

#### Option C: Targeted Chain Bundle (New Proposal)

See Part 3 for the construction.

### 2.3 The Critical Observation

**Theorem 2.3.1**: The truth lemma does NOT require a single global Omega. The Until case is a statement about the INTERNAL structure of tau, not about Omega.

Re-reading the truth definition:

```
truth_at M Omega tau t (untl phi psi) =
  exists s >= t, truth_at M Omega tau s psi AND
    for all r in [t, s), truth_at M Omega tau r phi
```

The Until quantification is over times in the SAME history tau. It does NOT quantify over Omega. Therefore:

- The box truth lemma constrains Omega (must have modal coherence).
- The Until truth lemma constrains the individual histories (must be built to resolve eventualities).
- The G/H truth lemma constrains the individual histories (must be g_content/h_content chains).

### 2.4 Refined Omega Design

Given the analysis in 2.3:

```
Omega = ShiftClosed({ to_history(fam) | fam in B.families })
```

where B is a BFMCS bundle in which each family fam is an FMCS built via FAIR-RESOLUTION chain construction. The key requirement is that **each FMCS family in B must be built using the fair-resolution chain construction**, so that every Until obligation in fam.mcs(t) is eventually resolved at some fam.mcs(t') with t' > t.

---

## Part 3: The Until/Since Truth Lemma via Chain Construction

### 3.1 Forward Direction: phi U psi in w_0 Implies Semantic Witness

Given a history tau = (..., w_{-1}, w_0, w_1, ...) as a g_content-chain, and phi U psi in w_0:

We need: exists j >= 0, psi in w_j AND for all i in [0, j), phi in w_i.

**Case 1**: psi in w_0. Take j = 0. The guard is vacuous. Done.

**Case 2**: psi not_in w_0. Then by BX9 (`phi U psi -> phi OR psi`), phi in w_0. The chain must resolve the Until.

### 3.2 The Targeted Chain Construction (Burgess's Method)

**Input**: MCS w_0 with phi U psi in w_0 and psi not_in w_0.

**Construction of w_1**:

Seed_1 = g_content(w_0) UNION {phi U psi}

**Consistency of Seed_1**: Suppose L SUBSET Seed_1 with L |- bot.

- If phi U psi not_in L: L SUBSET g_content(w_0), contradicting g_content_set_consistent (proved in Frame.lean).
- If phi U psi in L: L' UNION {phi U psi} |- bot where L' SUBSET g_content(w_0). By deduction theorem, L' |- neg(phi U psi). By g_content_closed_derivation, G(neg(phi U psi)) in w_0. By BX1 (temp_t_future: G(alpha) -> alpha), neg(phi U psi) in w_0. But phi U psi in w_0. Contradiction.

So Seed_1 is consistent. Extend to MCS w_1 via Lindenbaum.

**Properties of w_1**:
1. g_content(w_0) SUBSET w_1 (history coherence)
2. phi U psi in w_1 (from the seed)

**Now at w_1**: phi U psi in w_1. Either psi in w_1 (done, j = 1) or psi not_in w_1 (continue).

### 3.3 One-Step Resolution via until_witness_seed_consistent

**Proposition 3.3.1**: Given phi U psi in w_0, there exists a SINGLE-STEP chain w_0, w_1 such that:
1. g_content(w_0) SUBSET w_1
2. psi in w_1
3. phi in w_0 (the guard)

**Proof**: By `canonical_forward_U` (CanonicalFrame.lean): phi U psi in w_0 implies there exists W (MCS) with g_content(w_0) SUBSET W and psi in W. Take w_1 = W.

The guard: phi in w_0 follows from BX9 when psi not_in w_0.

**This resolves the Until in ONE step.** No infinite chain needed for a single Until.

### 3.4 The Core Problem: The History Is Already Fixed

The truth lemma is proved by structural induction on formulas. At the Until case, the history tau is ALREADY FIXED. We cannot modify tau to include the one-step resolution. The chain was built before we encounter this particular Until.

**THIS IS THE CORE PROBLEM.** The resolution: build tau to PRE-RESOLVE ALL Untils.

### 3.5 Persistence of Until Obligations Through Seeds

**Critical observation**: phi U psi is NOT in g_content(w) unless G(phi U psi) in w. So Until obligations do NOT automatically persist through g_content seeds.

This was the failure mode of the Boneyard approaches (TargetedChain.lean, ResolvingChain.lean).

### 3.6 Solution: Enriched Seeds with Until Persistence

**Key Lemma (Seed Consistency for Enriched Seeds)**:

For any MCS w, the set `g_content(w) UNION T` is consistent whenever T is a FINITE set of formulas all belonging to w.

**Proof**: g_content(w) SUBSET w (by BX1: G(phi) in w implies phi in w, so phi in g_content(w) implies G(phi) in w implies phi in w). Therefore g_content(w) UNION T SUBSET w when T SUBSET w. Since w is consistent and consistency is inherited by subsets, g_content(w) UNION T is consistent. QED.

**Corollary**: The seed `g_content(w) UNION {phi_1 U psi_1, ..., phi_m U psi_m} UNION {psi_target}` is consistent when each phi_k U psi_k in w and phi_target U psi_target in w (using until_witness_seed_consistent for the psi_target part).

### 3.7 The Fair-Resolution Chain Construction

**Construction**: We build a Z-indexed chain (..., w_{-1}, w_0, w_1, ...) as follows.

**Forward direction (i >= 0)**:

Let `pending(i)` = { (phi, psi) | phi U psi in w_i AND psi not_in w_i }.

- If pending(i) is empty: Seed_{i+1} = g_content(w_i). (Any Lindenbaum extension.)
- If pending(i) is nonempty: Pick the "least" (by some fixed well-ordering of Formula x Formula) unresolved pair (phi_target, psi_target).

```
Seed_{i+1} = g_content(w_i)
             UNION { phi U psi | (phi, psi) in pending(i), (phi, psi) != (phi_target, psi_target) }
             UNION { psi_target }
```

**Properties**:
1. g_content(w_i) SUBSET w_{i+1} (from the seed).
2. psi_target in w_{i+1} (from the seed -- resolves the target Until).
3. phi U psi in w_{i+1} for all non-target Until formulas (from the seed -- persistence).
4. phi_target in w_i (by BX9, since phi_target U psi_target in w_i and psi_target not_in w_i).

**Consistency**: The seed is a subset of w_i UNION {psi_target}. By until_witness_seed_consistent (applied to the target Until), g_content(w_i) UNION {psi_target} is consistent. The remaining Until formulas are all in w_i, and by the enriched seed lemma (Section 3.6), adding formulas from w_i to a consistent seed containing g_content(w_i) preserves consistency.

### 3.8 Verifying the Truth Lemma for Until

Given the chain from 3.7, and phi U psi in w_t:

- If psi in w_t: take s = t, guard is vacuous. Done.
- If psi not_in w_t: The chain resolves phi U psi at some step t' > t:
  - psi in w_{t'} (resolved by the targeted step)
  - For all r in [t, t'): phi U psi in w_r (persistence of unresolved Untils through enriched seeds) and psi not_in w_r (else it would have been resolved earlier)
  - By BX9: phi in w_r for all r in [t, t')
  - Take s = t'. The guard holds by BX9 at each intermediate step.

### 3.9 Reflexive Until Semantics and X Degeneracy

From `Truth.lean`, Until uses reflexive semantics:

```
truth_at M Omega tau t (untl phi psi) =
  exists s, t <= s AND truth_at ... tau s psi AND
    for all r, t <= r -> r < s -> truth_at ... tau r phi
```

Under this semantics, X(alpha) = bot U alpha is equivalent to alpha (taking s = t, guard vacuous). The X/Y "next/previous" operators DEGENERATE under reflexive Until.

This means the chain construction does NOT rely on X for stepping. Instead, it uses Until directly with the fair-resolution mechanism.

### 3.10 The Backward Direction for Until

**Backward Until**: Suppose exists s >= t, psi in w_s AND for all r in [t, s), phi in w_r. We need phi U psi in w_t.

**Case s = t**: psi in w_t. By BX8 (`psi -> phi U psi`): phi U psi in w_t.

**Case s > t**: We have phi in w_t, ..., phi in w_{s-1}, psi in w_s.

**Backward induction from s to t**:

**Base**: At time s: psi in w_s. By BX8: phi U psi in w_s.

**Step** (from time k+1 to time k, where t <= k < s): We have phi U psi in w_{k+1} and phi in w_k. We need phi U psi in w_k.

This requires: phi AND "phi U psi holds at the next time" implies phi U psi now.

**The derivable unfolding**: `phi U psi <-> psi OR (phi AND F(phi U psi))`

Right-to-left: phi AND F(phi U psi) -> phi U psi. This is derivable in standard Until logic.

We need F(phi U psi) in w_k. Since phi U psi in w_{k+1} and g_content(w_k) SUBSET w_{k+1}, we do NOT directly get F(phi U psi) in w_k from the forward direction.

**However**: We can use the CHAIN CONSTRUCTION'S backward coherence. If the chain also satisfies h_content backward coherence (h_content(w_{k+1}) SUBSET w_k), then H(phi U psi) in w_{k+1} would give phi U psi in w_k. But H(phi U psi) in w_{k+1} is not guaranteed.

**Alternative approach using BX4**: `phi U psi -> G(P(phi U psi))`. If phi U psi in w_s, then G(P(phi U psi)) in w_s. For any k >= s: P(phi U psi) in w_k. But we need to go BACKWARD from s to k < s, which requires g_content from s forward.

**The correct approach for backward Until on a chain**: We argue by CONTRADICTION.

Suppose phi U psi not_in w_t. Then neg(phi U psi) in w_t (by maximality). We derive a contradiction:

1. neg(phi U psi) in w_t.
2. By BX4-like connectedness: G(P(neg(phi U psi))) in w_t (from `neg(alpha U beta) -> G(P(neg(alpha U beta)))`). Actually, the correct BX axiom is BX4: `alpha -> G(P(alpha))` for the "always past" direction. Applying to neg(phi U psi): `neg(phi U psi) -> G(P(neg(phi U psi)))`.

   Wait -- BX4 as stated in the BX system might be different. Let me check: BX4 is typically the connectedness axiom `phi U psi -> G(P(phi U psi))`. The negative version needs to be derived.

   Instead, use the general theorem derivable in tense logic: `alpha in w AND g_content(w) SUBSET w' implies alpha in w'` requires G(alpha) in w, NOT just alpha in w. So neg(phi U psi) does NOT propagate forward through g_content.

3. **Key insight for the chain-based backward proof**: On the chain w_t, w_{t+1}, ..., w_s, we can define a NEW function:

   Let chi(k) = (phi U psi in w_k) for k in [t, s].

   We know chi(s) = true (from base case). We want chi(t) = true.

   At each k in [t, s-1]: we have phi in w_k (from hypothesis). We constructed the chain so that g_content(w_k) SUBSET w_{k+1}.

   **The missing piece**: From phi in w_k and phi U psi in w_{k+1}, derive phi U psi in w_k.

   This requires an axiom or derivable theorem. The standard one is:

   **Unfolding**: `phi U psi <-> psi OR (phi AND X(phi U psi))`

   where X is the "next time" operator. But under reflexive Until semantics, X degenerates (as shown in 3.9). So this unfolding does NOT help directly.

   **The alternative**: Use `until_witness_seed_consistent` in reverse. We need to show that g_content(w_k) UNION {phi U psi} is consistent... wait, that's for building w_{k+1}. The backward direction is different.

   **The most promising approach**: Use the fact that on the chain, we can build a semantic argument without needing to derive phi U psi syntactically at w_k. Instead, recognize that the truth lemma's backward direction should use the following key AXIOM:

   **BX Induction for Until**: The Until induction principle (derivable from BX5 + BX6 + BX7 in the BX system) states:

   `(alpha U beta) AND G(beta -> gamma) AND G(alpha AND gamma -> gamma) -> gamma`

   Setting alpha = phi, beta = psi, gamma = phi U psi:

   `(phi U psi) AND G(psi -> phi U psi) AND G(phi AND (phi U psi) -> phi U psi) -> phi U psi`

   By BX8: `psi -> phi U psi` is a theorem. So G(psi -> phi U psi) holds universally.
   By BX5/standard: `phi AND (phi U psi) -> phi U psi` is a theorem (weakening).
   So the induction gives: `phi U psi -> phi U psi` (tautological).

   This does not help directly. The Until induction needs to be applied differently.

4. **Final approach**: The backward Until proof on a chain uses the SEMANTIC definition directly, without needing syntactic derivation at intermediate steps. The truth lemma at the Until case states:

   `phi U psi in w_t iff exists s >= t, psi in w_s AND for all r in [t, s), phi in w_r`

   The backward direction can be proved by showing that if the right-hand side holds and phi U psi not_in w_t, we reach a contradiction. This is the approach used in the standard Burgess/Goldblatt proof, and it relies on being able to propagate neg(phi U psi) along the chain.

   **On a linear chain**: neg(phi U psi) in w_t. We need to show this leads to a contradiction with psi in w_s and phi in w_r for r in [t, s).

   By BX10-negated: `neg(phi U psi) -> G(neg(psi))` is NOT valid. (BX10 is `phi U psi -> F(psi)`; its contrapositive is `neg(F(psi)) -> neg(phi U psi)`, i.e., `G(neg(psi)) -> neg(phi U psi)`.)

   So from neg(phi U psi) alone, we cannot derive G(neg(psi)).

   However, from neg(phi U psi) we can derive: `neg(psi) AND (neg(phi) OR G(neg(phi U psi)))` (this is the standard dual of the Until unfolding).

   Iterating: neg(phi U psi) in w_t implies neg(psi) in w_t (but we DON'T know if psi in w_t, since s might be t). If s = t, we have psi in w_t, contradicting neg(psi) in w_t. Done for this case.

   If s > t: neg(phi U psi) in w_t implies neg(psi) AND (neg(phi) OR G(neg(phi U psi))) in w_t. Since phi in w_t (guard), neg(phi) not_in w_t. So G(neg(phi U psi)) in w_t. Then neg(phi U psi) in w_{t+1} (by g_content propagation). By induction: this propagates neg(phi U psi) through the chain to w_{s-1}. At w_{s-1}: neg(phi U psi), which gives neg(psi) in w_{s-1}. But we also need this at w_s...

   At w_{s-1}: G(neg(phi U psi)) in w_{t} SUBSET (by iterated g_content propagation) implies neg(phi U psi) at all future times including w_s. So neg(phi U psi) in w_s. Then neg(psi) in w_s (from the dual unfolding). But psi in w_s. Contradiction!

   **THIS WORKS.** The key derivation is:

   **Dual Until Unfolding**: `neg(phi U psi) -> neg(psi) AND (neg(phi) OR G(neg(phi U psi)))`

   This needs to be derivable from the BX axioms. It is the contrapositive of the standard Until unfolding:

   `psi OR (phi AND F(phi U psi)) -> phi U psi`

   Under the BX system, this should be derivable from BX5 (self-accumulation), BX8 (basis), and propositional reasoning.

### 3.11 Summary of the Backward Until Argument

Given: neg(phi U psi) in w_t, psi in w_s (s > t), phi in w_r for r in [t, s).

1. From neg(phi U psi) and the dual unfolding: neg(psi) AND (neg(phi) OR G(neg(phi U psi))) in w_t.
2. Since phi in w_t: neg(phi) not_in w_t. So G(neg(phi U psi)) in w_t.
3. neg(phi U psi) in g_content(w_t) SUBSET w_{t+1}. And G(neg(phi U psi)) in g_content(w_t) SUBSET w_{t+1}. Wait: we need G(G(neg(phi U psi))) in w_t, which gives G(neg(phi U psi)) in w_{t+1}. By temp_4, this holds.
4. By induction: G(neg(phi U psi)) propagates through the entire chain. In particular, neg(phi U psi) in w_s.
5. From neg(phi U psi) in w_s and the dual unfolding: neg(psi) in w_s. But psi in w_s. Contradiction.

**Required derivation**: `neg(phi U psi) -> neg(psi) AND (neg(phi) OR G(neg(phi U psi)))`.

This is equivalent to: `(psi OR (phi AND F(phi U psi))) -> phi U psi` (by contraposition and De Morgan).

This equivalence is the standard UNFOLDING of Until, and should be derivable from the BX axioms (specifically BX5, BX8, and possibly BX7/BX9).

---

## Part 4: The BXCanonical to Chain Bridge

### 4.1 Option A: Replace BXCanonical Entirely

**Approach**: Build new `ChainCanonical/` module.

**Advantage**: Avoids the linearity gap.
**Disadvantage**: Requires significant new code, does not reuse BXCanonical.

### 4.2 Option B: Prove the 4 Sorries Within BXCanonical

**Problem**: The 4 sorries quantify over ALL BXPoints u with bx_le w u and bx_le u v. An arbitrary such u is NOT constrained to lie on the chain. Without linearity of bx_le on intervals, we cannot prove phi in u for arbitrary u.

**Verdict**: BLOCKED by the linearity gap.

### 4.3 Option C: Hybrid Approach (RECOMMENDED)

**Approach**:
1. Keep BXCanonical for Box/G/H cases (already proved).
2. For Until/Since: Build chain-based canonical model that composes with BXCanonical's infrastructure.

The key change: bypass the 4 sorry stubs entirely. Instead of proving them, prove the truth lemma for Until/Since directly at the `truth_at` level for chain-based histories.

**Implementation**:

1. **ChainCanonical/FairResolutionChain.lean**: Fair-resolution FMCS construction (Section 3.7).
2. **ChainCanonical/ChainBundle.lean**: Bundle fair-resolution chains into BFMCS.
3. **ChainCanonical/TruthLemma.lean**: Full truth lemma (reuse atom/bot/imp/box/G/H; new Until/Since).
4. **ChainCanonical/Completeness.lean**: Completeness theorem.

---

## Part 5: Relationship to Existing Infrastructure

### 5.1 TargetedChain.lean (Boneyard)

**Approach**: Round-robin scheduling of F/P obligations using `canonical_forward_F`.

**Why it failed**: Does not preserve Until obligations. The seed `g_content(w_i) UNION {psi_target}` does not include Until formulas, so they may not persist.

**Salvageable**: The `targeted_forward_successor` pattern and scheduling idea.

### 5.2 ResolvingChain.lean (Boneyard)

**Approach**: DRM chains with simplified_restricted_seed.

**Why it failed**: Depends on RestrictedMCS (subformula closure), limiting completeness.

**Salvageable**: The consistency argument pattern.

### 5.3 SuccChainTruth.lean (Boneyard)

**Approach**: Singleton Omega truth lemma.

**Why it failed**: Box backward requires bundling (modal coherence).

**Salvageable**: The truth lemma induction structure.

### 5.4 Reuse Summary

| Component | Source | Reuse? |
|-----------|--------|--------|
| CanonicalTaskFrame | CanonicalConstruction.lean | YES |
| CanonicalTaskModel | CanonicalConstruction.lean | YES |
| to_history | CanonicalConstruction.lean | YES |
| until_witness_seed_consistent | WitnessSeed.lean | YES |
| g_content_closed_derivation | BXCanonical/Frame.lean | YES |
| BFMCS structure | BFMCS.lean | YES |
| targeted_forward_successor | TargetedChain (Boneyard) | ADAPT |
| Truth lemma structure | BXCanonical/TruthLemma.lean | REUSE for non-Until cases |

---

## Part 6: Dense and Discrete Extensions

### 6.1 Discrete Case (D = Z)

Native to the chain construction. Each step is a single integer increment. Between consecutive integers i and i+1, there are no intermediate times, so the guard for Until at time i with witness at time i+1 only covers {i}.

### 6.2 Dense Case (D = Q)

**Approach 1 (Constant segments)**: Define tau(q) = w_i for q in [i, i+1). This works because:
- For s, t in same segment: tau(s) = tau(t), d > 0 requires g_content(w_i) SUBSET w_i. This holds by BX1 (reflexivity).
- For s in [i, i+1), t in [j, j+1) with i < j: g_content(w_i) SUBSET w_j by chain transitivity.

Under reflexive Until semantics, phi U psi at time 0 with constant segments resolves if psi in w_0 (s = 0) or psi in some later segment.

**Approach 2 (Dense chain construction)**: Full back-and-forth construction for Q. Significantly more complex. Should be a separate task.

### 6.3 Recommendation

Keep D = Int for the completeness proof. Dense completeness requires separate infrastructure and should be a follow-up task.

---

## Part 7: Summary and Recommendations

### 7.1 Key Mathematical Findings

1. **World histories = g_content-chains** (1.3). Consecutive g_content inclusion suffices (1.4).

2. **Omega cannot be all world histories** (2.2). Box truth lemma requires modal coherence.

3. **Until truth lemma constrains individual histories, not Omega** (2.3).

4. **The fair-resolution chain** (3.7) resolves all Until obligations via enriched seeds containing both the resolution target AND persistent Until obligations.

5. **Seed consistency for enriched seeds** follows from g_content(w) SUBSET w (BX1) (3.6).

6. **Backward Until** works by contradiction: neg(phi U psi) propagates forward via G(neg(phi U psi)) (from the dual unfolding), reaching w_s where it contradicts psi in w_s (3.10-3.11).

7. **The 4 BXCanonical sorry stubs cannot be proved within BXCanonical** (4.2) because they quantify over all BXPoints, not just chain members.

8. **Recommended approach**: Hybrid -- keep BXCanonical for Box/G/H, build ChainCanonical for Until/Since (4.3).

### 7.2 Critical Derivation Needed

The backward Until proof requires the derivable theorem:

```
neg(phi U psi) -> neg(psi) AND (neg(phi) OR G(neg(phi U psi)))
```

This is the dual of the Until unfolding and must be shown derivable from the BX axioms (BX5, BX8, propositional reasoning). This derivation is the single most important blocking item for the chain-based completeness proof.

### 7.3 Implementation Phases

1. **Phase 1**: Fair-resolution FMCS construction (`ChainCanonical/FairResolutionChain.lean`)
2. **Phase 2**: Bundle into BFMCS (`ChainCanonical/ChainBundle.lean`)
3. **Phase 3**: Truth lemma for Until/Since (`ChainCanonical/TruthLemma.lean`)
4. **Phase 4**: Completeness theorem (`ChainCanonical/Completeness.lean`)

### 7.4 Remaining Blocking Issues

1. **existsTask_transitive** has a sorry on temp_4 derivation.
2. **Dual Until Unfolding** derivation from BX axioms.
3. **BFMCS construction** adapted for fair-resolution chains.
4. **Shift-closure** of the final Omega.
