# Teammate A Findings: Deep Dive into the Cycle Approach

**Task**: 83 -- Close Restricted Coherence Sorries
**Date**: 2026-04-07
**Role**: Primary analysis of the Cycle Approach from Report 28
**Artifact**: 29 (teammate-a-findings)

---

## 1. Complete Inventory of FiniteDeferral.lean

### 1.1 Definitions

| Name | Type | Status |
|------|------|--------|
| `restrictedTheory M₀ root n` | `Finset Formula` | Complete (noncomputable, classical) |

`restrictedTheory` filters `deferralClosure root` by membership in `deterministic_chain M₀ n`. This is the "fingerprint" of position n within the deferral closure.

### 1.2 Theorems (Sorry-Free)

| Theorem | Signature | Lines | Notes |
|---------|-----------|-------|-------|
| `F_to_until_in_mcs` | `F(psi) in M_mcs -> (top U psi) in M` | 44-49 | Uses `F_until_equiv` axiom |
| `F_to_until_in_chain` | `F(psi) in chain(t) -> (top U psi) in chain(t)` | 52-55 | Lifts above to chain |
| `until_persists_chain_general` | `(phi U psi) in chain(n), psi not in chain(n+1) -> phi in chain(n+1) AND (phi U psi) in chain(n+1)` | 63-80 | General Int positions. Uses `until_unfold_in_mcs`, `x_mem_chain_general`, `mcs_or_elim` |
| `until_persists_forward_steps` | `(top U psi) in chain(t), psi absent for n steps -> (top U psi) in chain(t+n)` | 83-97 | Induction on n. Core persistence engine. |
| `restrictedTheory_subset` | `restrictedTheory <= deferralClosure` | 117-119 | Trivial filter subset |
| `restrictedTheory_mem_powerset` | `restrictedTheory in powerset(deferralClosure)` | 122-124 | Direct corollary |
| `restricted_theory_count` | `|powerset(deferralClosure)| = 2^|deferralClosure|` | 127-129 | Mathlib `Finset.card_powerset` |
| `pigeonhole_restricted_theories` | `exists i < j <= 2^|dc|, restrictedTheory(t+i) = restrictedTheory(t+j)` | 133-153 | Uses `Finset.exists_ne_map_eq_of_card_lt_of_maps_to`. Clean pigeonhole application. |
| `G_neg_kills_until` | `G(neg psi) in chain(t) -> (top U psi) not in chain(t)` | 164-333 | **Large proof** (170 lines). Uses `until_induction` axiom with chi=bot. Key contribution: derives `step_formula = (neg bot AND (bot U bot)) -> bot` as a theorem, then applies temporal necessitation for `G(step)`, combines with `G(neg psi)`, applies `until_induction` to get `(top U psi) -> (bot U bot)`, then `X_bot_absurd` for contradiction. |

### 1.3 Theorems with Sorry

| Theorem | Signature | Lines |
|---------|-----------|-------|
| `forward_F_via_deferral` | `F(psi) in chain(t) -> exists s > t, psi in chain(s)` | 378-381 |

This is the **sole sorry** in the file. The docstring (lines 351-377) documents four approaches considered and recommends the quasimodel approach.

### 1.4 Key Observation about G_neg_kills_until

This theorem is the "contradiction engine." It establishes: if we can get `G(neg psi)` into the chain at position t, then `(top U psi)` cannot coexist there. The proof is entirely sorry-free and self-contained.

The gap is: how to derive `G(neg psi) in chain(t)` from the assumption that psi never appears at any future position. This is where the circularity lives.

---

## 2. DeterministicChain.lean Key Infrastructure

### 2.1 Chain Definition

```
chain(n)     = iterate_x_content(M0, n)     for n >= 0
chain(-(n+1)) = iterate_y_content(M0, n+1)  for n >= 0
```

where `x_content(M) = {phi | X(phi) in M}` and `y_content(M) = {phi | Y(phi) in M}`.

### 2.2 Critical Sorry-Free Results

- `deterministic_chain_mcs`: Every chain position is MCS
- `chain_succ_eq_x_content_nat`: `chain(n+1) = x_content(chain(n))` for naturals
- `x_mem_chain_general` (in DeterministicFMCS): `phi in chain(n+1) iff X(phi) in chain(n)` for ALL integers
- `until_persists_chain`: Until persistence for nat positions
- `forward_G_int`: `G(phi) in chain(n), n <= m -> phi in chain(m)` (sorry-free)
- `backward_H_int`: Symmetric for H (sorry-free)
- `backward_until_chain` (in DeterministicFMCS): Given witness at s with guard on (t,s), derive `(phi U psi) in chain(t)`
- `backward_since_chain` (in DeterministicFMCS): Symmetric

### 2.3 What x_content Linkage Gives Us

The deterministic chain has **exact** x_content linkage: `chain(n+1) = x_content(chain(n))`. This means `until_unfold` in chain(n) directly transfers to chain(n+1), giving sorry-free Until persistence. This is the key architectural advantage over the dovetailed chain.

---

## 3. DeterministicFMCS.lean Sorry Structure

### 3.1 Leaf Sorries (2)

1. `deterministic_forward_F` (line 64): `F(psi) in chain(t) -> exists s > t, psi in chain(s)`
2. `deterministic_backward_P` (line 71): `P(psi) in chain(t) -> exists s < t, psi in chain(s)`

### 3.2 Dependent Sorries (2)

3. `usc` forward Until case (line 483): `sorry` -- needs forward_F + until persistence
4. `usc` forward Since case (line 495): `sorry` -- needs backward_P + since persistence

### 3.3 Sorry-Free Components

Everything else is sorry-free: FMCS construction, BFMCS bundle, modal coherence (forward and backward), temporal coherence (modulo forward_F/backward_P), backward Until/Since, and `deterministic_representation` wiring.

---

## 4. Detailed Walkthrough of the Cycle Approach

### Step 1: Setup

**Given**: `F(psi) in chain(t)`, want to show `exists s > t, psi in chain(s)`.

**Assume for contradiction**: psi never appears at any `s > t`.

By `F_to_until_in_chain`: `(top U psi) in chain(t)`.

### Step 2: Persistence

By `until_persists_forward_steps`: for any n, since psi is absent at positions t+1 through t+n, we have `(top U psi) in chain(t+n)`.

Also, since psi not in chain(s) for s > t, and each chain position is MCS, we have `neg(psi) in chain(s)` for all s > t (by negation completeness of MCS).

### Step 3: Pigeonhole

Let `bound = 2^|deferralClosure(psi)|`. By `pigeonhole_restricted_theories`, there exist `i < j <= bound` such that:

```
restrictedTheory(M0, psi, t+i) = restrictedTheory(M0, psi, t+j)
```

Let `period = j - i`. The cycle is: positions `t+i, t+i+1, ..., t+j-1` map to a periodic restricted theory with period `period`.

### Step 4: Build the Periodic Restricted Model

**Definition**: The periodic model `P` is a structure over `ZMod period` (or equivalently, the integers with positions identified modulo period):

```
P.world = {0, 1, ..., period-1}  (= ZMod period, or Fin period)
P.mcs(k) = restrictedTheory(M0, psi, t+i+k)  for k in {0, ..., period-1}
P.successor(k) = k+1 mod period
```

**Key properties**:
- `P.mcs(k)` are all subsets of `deferralClosure(psi)` (by definition of restrictedTheory)
- `(top U psi) in P.mcs(k)` for all k (from Step 2, since top U psi persists forever)
- `psi not in P.mcs(k)` for all k (by assumption)
- `neg(psi) in P.mcs(k)` for all k (by MCS negation completeness)
- The restricted theories at `t+i` and `t+j` are identical (pigeonhole)

### Step 5: The Restricted Truth Lemma (Critical Analysis)

This is the heart of the argument and the hardest step. We need to show that for formulas `phi' in deferralClosure(psi)`:

```
phi' in P.mcs(k)  iff  P, k |= phi'
```

where `P, k |= phi'` is truth in the periodic model with its natural semantics.

#### Case-by-case analysis for the truth lemma:

**Propositional connectives** (neg, imp/or/and): These follow from MCS properties restricted to the deferral closure. Since `deferralClosure(psi)` includes `closureWithNeg(psi)`, for any subformula phi' of psi, both phi' and neg(phi') are in the closure. The restricted truth lemma for propositional cases follows from:
- Negation completeness of MCS (for formulas in the closure)
- Implication property (for formulas where the implication is in the closure)

**Caveat**: We need `phi'.neg in deferralClosure` whenever `phi' in deferralClosure`. This holds for subformulas of psi (via `closureWithNeg`) but may NOT hold for all elements of deferralClosure (the deferral disjunctions and seriality formulas have neg-closure only if explicitly included). This means the truth lemma may only work for formulas in `closureWithNeg(psi)`, not all of `deferralClosure(psi)`.

**X (Next)**: `X(phi') in P.mcs(k) iff phi' in P.mcs(k+1 mod period)`.
- Forward: `X(phi') in chain(t+i+k)` means `phi' in x_content(chain(t+i+k)) = chain(t+i+k+1)`. If `k < period-1`, this is `phi' in P.mcs(k+1)` directly. If `k = period-1`, we need `phi' in chain(t+j) = chain(t+i+period)`. But `restrictedTheory(t+i) = restrictedTheory(t+j)`, so if `phi' in deferralClosure` and `phi' in chain(t+j)`, then `phi' in restrictedTheory(t+j) = restrictedTheory(t+i) = P.mcs(0)`. This works.
- **PROBLEM**: The x_content linkage gives `phi' in chain(t+i+k+1)`, but to get `phi' in P.mcs(k+1 mod period)`, we need `phi' in restrictedTheory(t+i+(k+1 mod period))`. When `k = period-1`, we need `phi' in restrictedTheory(t+i)` which equals `restrictedTheory(t+j)`. Since `phi' in chain(t+j)` and `phi' in deferralClosure`, yes, `phi' in restrictedTheory(t+j) = restrictedTheory(t+i) = P.mcs(0)`. This direction works.
- Backward: Need `phi' in P.mcs((k+1) mod period) -> X(phi') in P.mcs(k)`. This says: if `phi' in chain(t+i+((k+1) mod period))`, then `X(phi') in chain(t+i+k)`. But this does NOT follow from x_content linkage! The x_content linkage gives `phi' in chain(n+1) iff X(phi') in chain(n)`, connecting ADJACENT chain positions. But `P.mcs(k)` and `P.mcs(k+1 mod period)` are adjacent in the periodic model but NOT necessarily adjacent in the original chain when `k = period-1`. **This is a gap**.

**Resolution for X**: The backward direction of X at the wrap-around point requires: `phi' in chain(t+i) -> X(phi') in chain(t+j-1)`. We know `X(phi') in chain(t+i-1)` from x_content linkage. But `chain(t+j-1)` is a different position. However, `restrictedTheory(t+i) = restrictedTheory(t+j)`, so `phi' in restrictedTheory(t+i) iff phi' in restrictedTheory(t+j)`. If `X(phi') in deferralClosure`, then `X(phi') in restrictedTheory(t+j-1)` would need to follow from `phi' in restrictedTheory(t+j)` via x_content. But `chain(t+j) = x_content(chain(t+j-1))` in the original chain, so `phi' in chain(t+j) iff X(phi') in chain(t+j-1)`. Therefore `X(phi') in chain(t+j-1)`. And if `X(phi') in deferralClosure`, then `X(phi') in restrictedTheory(t+j-1) = P.mcs(period-1)`. **This works, provided X(phi') in deferralClosure**.

**Subformula closure requirement for X**: We need that if `phi' in deferralClosure(psi)`, then `X(phi') = (bot U phi') in deferralClosure(psi)`. This is NOT generally true. The deferral closure includes `closureWithNeg(psi)` plus deferral disjunctions plus seriality formulas. `X(phi')` is in `closureWithNeg(psi)` only if `X(phi')` is a subformula of psi (or its negation). So the truth lemma for X only works for formulas where the X-successor is also in the closure.

**G (Always Future)**: `G(phi') in P.mcs(k) iff forall k', P, k' |= phi'` (in the periodic model, G means phi' at ALL positions, since the model is finite and periodic).
- Forward: `G(phi') in chain(t+i+k)` implies by `forward_G_int` that `phi' in chain(t+i+k+m)` for all m >= 0. In particular, `phi' in chain(t+i+k')` for all k' in 0..period-1 (by choosing appropriate m). So `phi' in P.mcs(k')` for all k'. Combined with the truth lemma for phi' (by induction on formula complexity), `P, k' |= phi'` for all k'.
- Backward: If `phi' in P.mcs(k')` for all k', want `G(phi') in P.mcs(k)`. This is the HARD direction. To get `G(phi') in chain(t+i+k)`, we would need to show that `phi' in chain(s)` for ALL `s > t+i+k`, not just for the finitely many positions in the cycle. But we only know `phi'` at positions within the cycle. **This direction FAILS for the periodic model** -- knowing phi' at finitely many positions does not give G(phi') in an MCS.

**CRITICAL**: The backward G direction does not hold in the periodic model. However, **we do not need the full truth lemma for G**. We only need the forward direction: `G(phi') in P.mcs(k) -> phi' at all positions in P`. The backward direction would require a form of "backward G" which is exactly the circularity we are trying to break.

**H (Always Past)**: Symmetric to G. Forward direction works, backward direction has the same issue.

**F (Some Future)**: `F(phi') in P.mcs(k) iff exists k', P, k' |= phi'`.
- Forward: `F(phi') in chain(t+i+k)` means `neg(G(neg(phi'))) in chain(t+i+k)`. By the forward direction of the G truth lemma, if `G(neg(phi'))` were in the chain, then `neg(phi')` would be at all positions. So if there exists some position where `phi'` holds, `G(neg(phi'))` cannot be in the chain. But this does NOT directly give us a witness in the periodic model. We need `exists k', phi' in P.mcs(k')`.
- **THIS IS THE CRITICAL CASE**: F(phi') in the chain means "there is a future witness for phi' somewhere in the infinite chain." But it could be OUTSIDE the cycle. If all witnesses are beyond position t+j, the periodic model cannot see them. So the forward direction of F may fail.

**U (Until)**: `(phi' U psi') in P.mcs(k) iff exists k' > k (in periodic order), psi' at k' and phi' at all positions between`.
- Forward: `(phi' U psi') in chain(t+i+k)` means there exists `s > t+i+k` with `psi' in chain(s)` and `phi' in chain(r)` for `t+i+k < r < s`. The witness s could be outside the cycle.
- **Same problem as F**: The witness might be beyond the cycle.

### Step 6 and 7: The Semantic Contradiction

The idea is: `(top U psi) in P.mcs(k)` for all k, but psi is never in any P.mcs(k). So semantically in P, `top U psi` should be false everywhere. If we had a truth lemma saying "member of restricted theory iff semantically true in P", we'd have a contradiction.

But as analyzed above, the truth lemma does NOT hold in the forward direction for Until/F. The fact that `(top U psi) in P.mcs(k)` does NOT mean `P, k |= top U psi`, because the witness might be outside the cycle.

---

## 5. The Circularity Question: Can It Be Broken?

### 5.1 Why the Direct Cycle Approach Has a Gap

The restricted truth lemma fails for Until and F in the forward direction. The membership `(top U psi) in chain(t+i+k)` guarantees a witness EXISTS in the infinite chain, but does not place it within the periodic cycle. So we cannot conclude that `(top U psi)` is semantically true in the periodic model, nor can we conclude it is semantically false (we can conclude the latter, since psi is never at any cycle position).

The gap: membership in the restricted theory does not entail semantic truth in the periodic model for temporal existential connectives.

### 5.2 The Recursive Deferral Idea

Report 28 suggests: for any `F(chi)` in the cycle with `chi in deferralClosure(psi)`, if chi never appears in the cycle, apply the same finite deferral argument recursively. Since deferralClosure is finite, the recursion terminates.

**Analysis**: This is more promising but has subtleties.

Consider `F(chi) in P.mcs(k)` for some `chi in deferralClosure(psi)`. This means `F(chi) in chain(t+i+k)`. If chi appears at some position in the cycle, the F-obligation is resolved within the cycle. If chi NEVER appears at any cycle position, then by the same argument as the original:
- `(top U chi) in chain(t+i+k)` (by F_to_until)
- `(top U chi)` persists through the entire cycle and beyond
- A sub-pigeonhole on `deferralClosure(chi) subset deferralClosure(psi)` gives a sub-cycle
- But this does not directly help...

The problem: the recursive argument does not produce `G(neg(chi))`. It produces another cycle where (top U chi) persists. We still need to derive a contradiction, and the same circularity applies at each level.

### 5.3 An Alternative: Until Induction Directly on the Cycle

Rather than building a semantic model, we can try to use `until_induction` axiom directly within the chain's proof theory.

`until_induction` says:
```
G(psi -> chi) AND G(phi AND X(chi) -> chi) -> ((phi U psi) -> X(chi))
```

Instantiate with `phi = top = neg bot`, `psi = psi`, `chi = bot`:
```
G(psi -> bot) AND G((top AND X(bot)) -> bot) -> ((top U psi) -> X(bot))
```

Simplify: `G(neg psi) AND G(step) -> ((top U psi) -> X(bot))`.

The second conjunct `G(step)` where `step = (top AND X(bot)) -> bot = (neg bot AND (bot U bot)) -> bot` is derivable as a theorem (proven in `G_neg_kills_until`).

So we need: **`G(neg psi) in chain(t)`**.

This brings us back to the original circularity. The until_induction approach ALREADY works (it is exactly what `G_neg_kills_until` does), but it requires G(neg psi) as a premise.

### 5.4 A More Nuanced Approach: G Restricted to the Cycle

We do not need `G(neg psi) in chain(t)` in the sense of the full infinite chain. We only need it to derive a contradiction. Consider:

**Claim**: If `neg(psi) in chain(s)` for ALL `s >= t+i` (positions from the cycle start onward), and the chain is MCS at each position, then we can derive `G(neg psi) in chain(t+i)`.

**Why this might work without forward_F**: The claim is about backward G derivation: from "neg(psi) at all future positions" derive "G(neg psi) at position t+i." In the standard approach, `temporal_backward_G_with_fwd_F` needs forward_F as a hypothesis. But CAN we prove backward_G without forward_F?

The derivation `temporal_backward_G_with_fwd_F` works as follows: suppose `G(neg psi) not in chain(t)`. Then `F(psi) in chain(t)` (by MCS negation: `neg(G(neg psi)) = F(neg(neg psi))` ... wait, this is not exactly F(psi)). Let me be precise.

`G(neg psi) not in chain(t)` implies `neg(G(neg psi)) in chain(t)` by MCS completeness. Now `neg(G(neg psi)) = F(neg(neg psi))` which by DNE is equivalent to `F(psi)` (in the proof system). So `F(psi) in chain(t)`. By forward_F, there exists s > t with psi in chain(s). But we assumed neg(psi) at all s > t. Contradiction.

So: backward_G for neg(psi) requires forward_F for psi. And forward_F for psi is EXACTLY what we are trying to prove. **The circularity is tight**.

### 5.5 Breaking Circularity via Well-Founded Induction

Can we do well-founded induction on SOMETHING? The dependency is:

```
forward_F(psi) requires backward_G(neg(psi)) requires forward_F(psi)
```

This is a direct cycle -- the same formula psi appears at both ends. The formula complexity does NOT decrease.

**What about induction on the number of unresolved F-obligations in the restricted theory?**

At the cycle, we have finitely many formulas in `deferralClosure(psi)`. Among these, some are F-formulas. Some of these F-obligations may be resolvable within the cycle, others not.

Let `U = {F(chi) in restrictedTheory(t+i) | chi not in restrictedTheory(t+i+k) for any k in 0..period-1}` be the set of unresolved F-obligations.

We know `F(psi)` (or equivalently `top U psi`) is in U.

**Idea**: Show that U must be empty, by showing that any element of U leads to a contradiction independent of forward_F.

But to show F(chi) leads to a contradiction for chi in U, we need... `G(neg chi)` in the chain. Which requires forward_F(chi). The same circularity.

### 5.6 The Genuine Resolution: Direct Proof via Until Induction on the Cycle

Here is the key insight that I believe resolves the circularity. We do NOT need `G(neg psi) in chain(t)`. Instead, we can derive the contradiction DIRECTLY from the cycle structure using until_induction with a DIFFERENT instantiation.

Consider: at the cycle positions `t+i, t+i+1, ..., t+j-1`, the restricted theories repeat. We have `(top U psi) in chain(t+i+k)` for all k >= 0. In particular, at position `t+i` and position `t+j`, we have the same restricted theory.

Now consider instantiating `until_induction` not with `chi = bot`, but with `chi` chosen to encode "we are past position t+j" or some related formula. This does not work directly because until_induction is a schema over formulas, not over positions.

**Alternative insight**: Can we use `until_induction` with `chi = neg(top U psi)`? Then:
```
G(psi -> neg(top U psi)) AND G(top AND X(neg(top U psi)) -> neg(top U psi)) -> ((top U psi) -> X(neg(top U psi)))
```

The first premise requires `G(psi -> neg(top U psi))`. If psi never holds (our assumption for contradiction), then `psi -> neg(top U psi)` is vacuously true at every MCS (since neg(psi) in M makes psi -> anything true). And this IS derivable: from `neg(psi) in M`, we get `psi.imp anything in M`. But we need this under G, i.e., `G(psi -> neg(top U psi)) in chain(t)`. For this, we need `psi -> neg(top U psi) in chain(s)` for all s > t. At each s > t, neg(psi) is in chain(s), so psi -> anything is in chain(s). Good.

But to get `G(psi -> neg(top U psi)) in chain(t)`, we STILL need backward G, which requires forward_F. Circularity again.

### 5.7 The Real Resolution: Semantic Argument on the FULL Chain (Not the Cycle)

The existing infrastructure already provides:
1. `(top U psi) in chain(t+n)` for all n (via `until_persists_forward_steps`)
2. `psi not in chain(s)` for all s > t (assumption)
3. `neg(psi) in chain(s)` for all s > t (MCS completeness)
4. Pigeonhole gives a cycle in the restricted theory

The contradiction should come from the AXIOMS OF THE PROOF SYSTEM, specifically `until_induction`, applied WITHIN the chain's MCS.

**The actual argument in the literature (Gabbay, Hodkinson, Reynolds 1994)**: The finite deferral argument does NOT build a separate periodic model. Instead, it argues as follows:

Since the restricted theories cycle with period `period = j - i`, for every formula `f in deferralClosure(psi)`:
```
f in chain(t+i+k) iff f in chain(t+i+k+period)   (for all k >= 0)
```

This means the chain ITSELF is eventually periodic (restricted to deferralClosure). Now:
- `(top U psi) in chain(t+i+k)` for all k >= 0
- `psi not in chain(t+i+k)` for all k >= 0
- The restricted chain is periodic with period `period`

Now apply `until_induction` at position `t+i` with phi = top, psi = psi, chi to be determined.

The key is: `until_induction` gives `(top U psi) -> X(chi)` from `G(psi -> chi) AND G(top AND X(chi) -> chi)`. The conclusion is `X(chi)`, not `chi`. And we need this for ALL future positions (to propagate the Until) -- but we only get it at position `t+i`.

Actually, re-reading the `G_neg_kills_until` proof more carefully: it instantiates `until_induction` with `chi = bot` and gets `(top U psi) -> X(bot) = (top U psi) -> (bot U bot)`. Then `(bot U bot) -> bot` (X_bot_absurd). The conclusion: `(top U psi) -> bot`, i.e., `(top U psi) not in chain(t)`.

For this to work at chain(t), we need `G(neg psi) in chain(t)` and `G(step) in chain(t)`. The G(step) is derivable by temporal necessitation (step is a theorem). But G(neg psi) requires backward G.

**This confirms**: the cycle approach as described in report 28 does NOT directly give a proof. The circularity is genuine and unbroken by the cycle argument alone.

---

## 6. Honest Assessment: What Would Actually Work

### 6.1 The Fundamental Obstacle

The circularity `forward_F(psi) <-> backward_G(neg psi)` cannot be broken by any argument that stays within the single MCS chain and tries to derive G-formulas. The problem is that `G(neg psi) in chain(t)` is a statement about the PROOF THEORY (membership in an MCS), and it cannot be derived from the SEMANTIC fact that neg(psi) holds at all future positions -- unless you have forward_F to close the gap.

### 6.2 What the Cycle Gives Us (and What It Does Not)

The cycle gives us:
- The restricted theory is eventually periodic
- `(top U psi)` persists forever with psi absent
- There are finitely many distinct restricted states

The cycle does NOT give us:
- `G(neg psi) in chain(t)` (backward G derivation)
- A periodic model with a sound truth lemma for Until/F
- A direct contradiction without backward G

### 6.3 Approaches That Could Work

**Approach A: Quasimodel (GHR 1994)**

Build an explicit quasimodel (a finite collection of "types" with successor/predecessor relations satisfying local coherence conditions). The quasimodel approach works because:
1. Types are finite sets of formulas (subformula closure)
2. The F-resolution condition is BUILT INTO the quasimodel definition
3. Quasimodels are constructed by starting from the MCS and "extracting" a finite consistent set of types
4. The extraction process does not need backward G

**Estimated effort**: 800-1200 lines. Requires new definitions (quasimodel, type, defect), new lemmas (type extraction, quasimodel validity, quasimodel-to-model), and wiring to the completeness framework.

**Approach B: Mutual Induction on Formula Complexity**

Instead of proving `forward_F(psi)` in isolation, prove ALL temporal coherence properties simultaneously by mutual induction on the maximum modal/temporal depth of formulas involved. Define:

```
forward_F_depth(d): for all psi with depth(psi) <= d, if F(psi) in chain(t) then exists s > t with psi in chain(s)
backward_G_depth(d): for all psi with depth(psi) <= d, if neg(psi) at all s > t then G(neg psi) in chain(t)
```

Then: `forward_F_depth(d)` uses `backward_G_depth(d)` for neg(psi) which has depth(neg psi) = depth(psi) + 1. So this does NOT decrease depth. **This approach fails.**

**Approach C: Ordinal Analysis / Impredicative Argument**

Use the fact that `deferralClosure(psi)` is finite and the chain is omega-indexed to build a well-ordering argument. The number of "defects" (positions where an F-formula is present but its content is absent) must decrease over any sufficiently long segment of the chain. Since there are finitely many F-formulas in the closure...

Actually, the defect count does NOT decrease -- that is exactly the problem. (top U psi) persists forever, creating the same defect at every position.

**Approach D: Direct Semantic Construction (Bypass Chain Entirely)**

Instead of using the deterministic chain, build the countermodel directly:
1. Start from MCS M0
2. Build a tree of MCS's using x_content for successor
3. At each node, choose which F-obligation to satisfy
4. Use Konig's lemma to extract an infinite path

This is essentially a variant of the quasimodel approach and has similar effort estimates.

### 6.4 The Most Viable Path

**Approach A (Quasimodel)** is the most viable. It is the standard textbook approach for discrete temporal completeness and has been formalized in other proof assistants (e.g., Isabelle). The key insight: instead of building a chain and then proving it has F-witnesses, build a structure that has F-witnesses BY CONSTRUCTION.

However, this requires significant new infrastructure (800-1200 lines) and a partial redesign of the completeness architecture.

### 6.5 A Possible Shortcut: Direct Proof via Axiom Instantiation

There may be a shorter path using a clever instantiation of `until_induction` that I have not identified. The until_induction axiom is quite powerful:

```
G(psi -> chi) AND G(phi AND X(chi) -> chi) -> ((phi U psi) -> X(chi))
```

If we could find a chi such that:
1. `G(psi -> chi) in chain(t)` can be established without backward G
2. `G(phi AND X(chi) -> chi) in chain(t)` can be established without backward G
3. `X(chi) in chain(t)` leads to a contradiction (combined with other facts)

Then we could close forward_F without the circularity. The search space for chi is large (any formula). The G-prefixed premises are the challenge -- they require that the implication holds at ALL future positions, and deriving this normally requires backward G.

One idea: if chi is a THEOREM (derivable from the empty context), then `G(chi)` follows from temporal necessitation. So if `psi -> chi` and `(phi AND X(chi)) -> chi` are both theorems...

`psi -> chi` being a theorem means chi is derivable from psi alone. If chi = psi, then psi -> psi is a theorem. And we'd need `(top AND X(psi)) -> psi` to be a theorem, which is NOT generally true.

If chi = top (= neg bot), then psi -> top is a theorem (always). And `(top AND X(top)) -> top` is a theorem (always). So G(psi -> top) and G((top AND X(top)) -> top) are both in any MCS. The conclusion: `(top U psi) -> X(top)`, i.e., `(top U psi) -> (bot U neg bot)`. But `bot U neg bot = X(neg bot)`, and neg bot is always in any MCS. So X(neg bot) is always in any MCS (by x_content and MCS properties). This gives us nothing useful -- the conclusion is trivially true.

If chi = neg(psi), then we need `G(psi -> neg(psi))`, which is `G(neg(psi) OR neg(psi)) = G(neg(psi))`. This requires G(neg psi) -- circular again.

I believe there is no "cheap" instantiation that avoids the circularity.

---

## 7. Concrete Lean Code Sketches

### 7.1 What the Cycle Argument Can Formalize (Without Closing forward_F)

```lean
/-- If F(psi) in chain(t) and psi never appears after t, there exists a cycle
    in the restricted theory. -/
theorem F_deferral_gives_cycle (M₀ : Set Formula) (h_mcs : SetMaximalConsistent M₀)
    (t : ℤ) (ψ : Formula)
    (h_F : Formula.some_future ψ ∈ deterministic_chain M₀ t)
    (h_no_psi : ∀ s : ℤ, t < s → ψ ∉ deterministic_chain M₀ s) :
    ∃ i j : ℕ, i < j ∧ j ≤ 2 ^ (deferralClosure ψ).card ∧
      restrictedTheory M₀ ψ (t + ↑i) = restrictedTheory M₀ ψ (t + ↑j) ∧
      (∀ k : ℕ, Formula.untl (Formula.neg Formula.bot) ψ ∈
        deterministic_chain M₀ (t + ↑k)) ∧
      (∀ k : ℕ, ψ ∉ deterministic_chain M₀ (t + ↑k + 1)) := by
  -- Combine until_persists_forward_steps with pigeonhole_restricted_theories
  sorry -- Straightforward combination of existing lemmas
```

This is provable with existing infrastructure but does not close forward_F.

### 7.2 What Would Be Needed for Quasimodel Approach

```lean
/-- A quasimodel type: a subset of deferralClosure that is locally consistent. -/
structure QType (root : Formula) where
  formulas : Finset Formula
  subset : formulas ⊆ deferralClosure root
  consistent : SetConsistent (formulas : Set Formula)
  neg_complete : ∀ f ∈ subformulaClosure root, f ∈ formulas ∨ f.neg ∈ formulas

/-- A quasimodel: finite set of types with successor relation. -/
structure Quasimodel (root : Formula) where
  types : Finset (QType root)
  succ : QType root → QType root
  -- X-coherence
  x_coherent : ∀ q ∈ types, succ q ∈ types
  x_content : ∀ q ∈ types, ∀ f, f ∈ (succ q).formulas ↔
    Formula.untl Formula.bot f ∈ q.formulas
  -- F-resolution: every F-obligation is eventually resolved
  f_resolved : ∀ q ∈ types, ∀ chi,
    Formula.some_future chi ∈ q.formulas →
    ∃ n : ℕ, chi ∈ (Nat.iterate succ n q).formulas
  -- Until coherence (derived from F-resolution + until_unfold)
  ...
```

This would require 800+ lines of new code.

---

## 8. Summary

### What Exists (Sorry-Free)

1. `F(psi) -> (top U psi)` conversion
2. Until persistence for arbitrary steps
3. Pigeonhole on restricted theories
4. `G(neg psi)` kills `(top U psi)` via until_induction
5. Full G/H coherence for the deterministic chain
6. Backward Until/Since introduction
7. Complete BFMCS bundle construction and completeness wiring

### The Gap

To go from "psi absent at all future positions" to "G(neg psi) in chain(t)" requires backward G derivation, which requires forward_F -- creating a tight circular dependency on the SAME formula psi.

### The Cycle Approach: Partial Success

The cycle approach successfully reduces the infinite chain to a finite periodic structure. However, it does NOT resolve the circularity because:
- The restricted truth lemma fails for Until/F in the periodic model (witnesses may lie outside the cycle)
- The until_induction axiom still requires G-prefixed premises, which need backward G
- Recursive deferral on deferralClosure elements hits the same circularity at each level

### The Honest Estimate

Closing `deterministic_forward_F` via the cycle approach ALONE is not feasible. The circularity is genuine. The most viable resolution is the quasimodel approach (Approach A), estimated at 800-1200 lines of new Lean 4 code, which builds F-resolution INTO the model construction rather than trying to derive it after the fact.

A less invasive alternative: find a clever formula instantiation for until_induction that avoids G-premises. I have not identified such an instantiation, but the search space is large and a human logician may see something I have missed.
