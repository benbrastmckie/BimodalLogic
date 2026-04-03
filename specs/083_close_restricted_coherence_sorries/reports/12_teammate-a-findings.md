# Teammate A Findings: Root Cause Analysis of g_content Blocker

**Task**: 83 - Close Restricted Coherence Sorries
**Role**: Teammate A - Deep root cause analysis
**Date**: 2026-04-03

## Executive Summary

The `g_content(M) ⊆ successor(M)` property is **semantically valid** under strict semantics. The blocker is purely proof-theoretic: the old derivation route via `G(a) -> a` (T-axiom) is unsound, but a new derivation route via `G(a) -> X(a)` exists and is both sound and provable from the current axiom system. The fix requires replacing each sorry site with a derivation of `G(a) -> X(a)` (or the past dual `H(a) -> Y(a)`) instead of the deleted `G(a) -> a`.

## Key Findings

### Finding 1: The Property Is Semantically Valid (HIGH confidence)

Under strict semantics on Z, `G(phi)` true at time t means `phi(s)` for all s > t. The successor represents time t+1. Since t+1 > t, `phi(t+1)` holds, which means `X(phi)` at t. Therefore `g_content(M) ⊆ successor(M)` is correct: if `G(a) in M` at time t, then `a` should be in the successor MCS at time t+1.

The issue is NOT that the property is false. The issue is that we previously derived it via the T-axiom `G(a) -> a` applied in the successor MCS, and that axiom no longer exists.

### Finding 2: Root Cause - The T-Axiom Extraction Pattern (HIGH confidence)

Every sorry site follows the same pattern. The old proof worked as:

1. `G(a) in M` (hypothesis)
2. `G(a) in successor(M)` (by G-agreement/G-propagation - this step is FINE)
3. `a in successor(M)` (by T-axiom `G(a) -> a` in the successor MCS - THIS STEP IS BROKEN)

The T-axiom `G(a) -> a` says "if phi holds at all future times, it holds now." Under strict semantics, G quantifies over strictly future times only, so this inference is invalid. Step 3 is the sole failure point. Steps 1 and 2 remain correct.

There are exactly **three patterns** of sorry usage across the codebase:

**Pattern A: g_content inclusion** (most common, ~15 sites)
```
-- G(a) in M, G(a) in W (by G-agreement), need a in W
-- Old: G(a) -> a via T-axiom in W
-- Files: DovetailedChain.lean (lines 142, 224), UltrafilterChain.lean (line 2591),
--   MCSWitnessSuccessor.lean (line 259), TargetedChain.lean (lines 242, 478)
```

**Pattern B: R_G reflexivity / G-extraction at same point** (~8 sites)
```
-- G(a) in U (ultrafilter), need a in U
-- Old: G(a) <= a via T-axiom ordering
-- Files: UltrafilterChain.lean (lines 97, 520, 1009)
```

**Pattern C: H-direction duals** (~9 sites)
```
-- H(a) in M at time n, need a at time n (or H(a) -> a)
-- Old: H(a) -> a via temp_t_past
-- Files: DovetailedChain.lean (lines 277, 282, 762, 912, 917),
--   MCSWitnessSuccessor.lean (line 319), TargetedChain.lean (lines 346, 512),
--   SuccChainFMCS.lean (line 4009)
```

### Finding 3: Derivation of G(a) -> X(a) From Current Axioms (HIGH confidence)

The derivation `G(a) -> X(a)` IS provable from the current axiom system. Here is the proof:

**Claim**: `|- G(a) -> X(a)`, where `X(a) = bot U a`.

**Proof**:
1. `G(a) -> F(a)` (seriality_future axiom)
2. `F(a) -> top U a` (F_until_equiv axiom, instantiated with psi = a; noting top = neg bot)
3. From `top U a` at time t: there exists s > t with a(s) and top at all r with t < r < s.
4. `G(a) -> G(G(a))` (temp_4 axiom)
5. From G(a) at t: G(a) at t+1 (by temp_4 + successor), so a at t+1 (by seriality + F_until).

Wait -- this is circular. Let me be more careful.

**Correct derivation via Until Induction**:

We want `G(a) -> bot U a`, i.e., `G(a) -> X(a)`.

Use the until_induction axiom:
```
G(psi -> chi) /\ G(phi /\ X(chi) -> chi) -> (phi U psi -> X(chi))
```

We need to show `G(a) -> X(a)`. Note that `X(a) = bot U a`.

Strategy: From `G(a)`, derive `F(a)` (by seriality), then `top U a` (by F_until_equiv), then extract `X(a)` from `top U a`.

Actually, `top U a` and `bot U a` (= X(a)) are different formulas. `top U a` means: there exists s > t with a(s) and top at all r in (t,s). `bot U a` means: there exists s > t with a(s) and bot at all r in (t,s), i.e., there are NO r in (t,s) -- meaning s = t+1.

So the key question is: can we derive `top U a -> bot U a` given `G(a)`?

**Yes.** Here is how:

From `G(a)` at time t:
- `F(a)` by seriality: there exists some s > t with a(s).
- `top U a` by F_until_equiv.
- By until_unfold on `top U a`: `X(a \/ (top /\ top U a))`, i.e., at t+1 either a holds, or top U a continues.
- But we also have `G(a)` at t, so by temp_4, `G(G(a))` at t, meaning `G(a)` at t+1.
- So at t+1, we again have `G(a)`, giving `top U a` at t+1.
- We can unfold again: at t+2 either a holds or it continues...

This approach does not terminate syntactically. We need a different strategy.

**Better derivation using the discreteness axiom disc_next directly**:

`disc_next` states: `F(top) -> X(top)`, i.e., `F(neg bot) -> bot U (neg bot)`.

From `G(a)`:
1. `G(a) -> F(a)` (seriality_future)
2. So `F(a)` holds. But we need `X(a)`, not `X(top)`.

**The correct derivation uses Until introduction**:

From `G(a)` at time t:
1. `G(a)` at t. By temp_4: `G(G(a))` at t, so `G(a)` at all s > t.
2. In particular, `a` at t+1 (... but this is what we're trying to prove).

**Hmm.** The fundamental issue is that we need to establish `a` at the next time point t+1, given only that `a` holds at all times strictly after t. Semantically this is trivial (t+1 > t), but proof-theoretically we need the axioms to bridge the gap.

**The correct derivation IS possible but uses a combination of axioms**:

From `G(a)`:
1. `G(a) -> F(a)` by seriality_future. So `F(a)`.
2. `F(a) -> top U a` by F_until_equiv. So `top U a`.
3. `top U a -> X(a \/ (top /\ (top U a)))` by until_unfold. So `X(a \/ (top /\ (top U a)))`.
4. From `G(a)`: `G(a) -> G(G(a))` by temp_4. So `G(G(a))`.
5. Consider: at the next time point (where X evaluates), we have `G(a)` (by step 4, G(a) propagates).
6. At the next time point, either `a` holds directly (and we have `X(a)`), or `top /\ (top U a)` holds, meaning `top U a` continues from t+1 with some witness s > t+1 where a(s).
7. But at t+1, `G(a)` also holds (from step 4-5). By the same argument, `a` holds at t+2, t+3, etc.
8. In particular, at the witness s, `a(s)` holds. So we know `a` holds at the witness.

Wait -- `top U a` ALREADY tells us `a` holds at the witness. The issue is extracting `X(a)` from `top U a`. We need `bot U a`, which requires the witness to be at t+1 exactly (no intermediate points).

**Key insight**: On Z (integers), there are NO integers strictly between t and t+1. So `top U a` at t with witness s can have s = t+1 (in which case `X(a)` holds), or s > t+1 (in which case `top` at t+1 is satisfied, but we also know `G(a)` at t+1, giving us `top U a` at t+1 with the same witness, and eventually we reach the witness).

But this is an infinite descent argument, not a finite derivation. The axiom system needs to capture this.

**The actual derivation uses until_induction**:

We want to show: `G(a) -> X(a)`.

Equivalently: `G(a) /\ (top U a) -> X(a)`.

We already have `G(a) -> top U a` (seriality + F_until_equiv), so it suffices to show `(top U a) -> X(a)` under the hypothesis `G(a)`.

Use until_induction with phi = top, psi = a, chi = a:
```
G(a -> a) /\ G(top /\ X(a) -> a) -> (top U a -> X(a))
```

- First conjunct: `G(a -> a)` is `G(taut)`, which is derivable by temporal necessitation.
- Second conjunct: `G(top /\ X(a) -> a)`. This says: at all future times s, if X(a) at s then a at s. But X(a) at s means a at s+1, not a at s. So this does NOT simplify to a tautology.

This is problematic. Let me try chi = top:
```
G(a -> top) /\ G(top /\ X(top) -> top) -> (top U a -> X(top))
```
Both conjuncts are tautological under G. But the conclusion is `X(top)`, not `X(a)`.

**Alternative approach using disc_next more directly**:

`disc_next`: `F(top) -> X(top)`.

From `G(a)`:
1. By seriality: `F(a)`.
2. `F(a) -> F(top)` (from `a -> top` by temporal K distribution: `G(a -> top) -> (F(a) -> F(top))`, and `a -> top` is a theorem, so by necessitation `G(a -> top)` is a theorem, giving `F(a) -> F(top)`).

Actually wait, F is the existential dual, not the universal. `G(a -> top) -> (G(a) -> G(top))` is temp_k_dist. For F: `F(a) -> F(top)` follows from the propositional content: if there exists s > t with a(s), then there exists s > t with top(s) (same witness).

3. `F(top) -> X(top)` by disc_next. So `X(top)`.
4. Now: `X(top)` means `bot U top`, which means there exists s = t+1 with top(t+1). This tells us t+1 exists as a time point.
5. `G(a)` at t means a(s) for all s > t. In particular, a(t+1).
6. So `X(a)` should hold: `bot U a` with witness s = t+1, and no intermediate points (vacuous on Z).

The derivation combining steps 4-6 proof-theoretically:

From `G(a)` and `X(top)`:
- `X(top)` is `bot U top`. By until_unfold: `X(top \/ (bot /\ bot U top))` = `X(top)` (simplifies).
- We need to use `G(a)` to "strengthen" `X(top)` to `X(a)`.

**Derivation of X(top) /\ G(a) -> X(a)**:

`X(top) = bot U (neg bot)` and `X(a) = bot U a`.

We need: from `bot U (neg bot)` and `G(a)`, derive `bot U a`.

`bot U (neg bot)` at t means: there exists s > t with neg_bot(s) (i.e., true) and bot at all r in (t,s). On Z, this means s = t+1 (no intermediate points have bot, vacuously satisfied since there are no intermediate points).

So we know t+1 exists. And from `G(a)`: a(t+1). So `bot U a` at t holds (witness s = t+1, guard is vacuous).

Proof-theoretically, this requires:
1. `bot U (neg bot)` -- from X(top)
2. Using until_unfold on `bot U (neg bot)`: `X((neg bot) \/ (bot /\ bot U (neg bot)))` = `X(neg bot)` (since `bot /\ anything` is bot).

Hmm, this is getting complex. Let me try a direct approach.

**Direct derivation via until_intro**:

`until_intro`: `X(psi \/ (phi /\ phi U psi)) -> phi U psi`

To get `X(a) = bot U a`, use until_intro with phi = bot, psi = a:
`X(a \/ (bot /\ bot U a)) -> bot U a`
Since `bot /\ bot U a` is equivalent to `bot`, this simplifies to:
`X(a \/ bot) -> bot U a`
i.e., `X(a) -> X(a)` (tautology, using `a \/ bot <-> a`).

This is a tautology and does not help.

**To get X(a), we need to produce `bot U a` from the axioms.**

**Final correct derivation**:

The key is that `G(a)` lets us derive `X(a)` by combining disc_next with temporal K reasoning:

1. `|- a -> (neg bot)` (propositional tautology: a implies top)
2. By contrapositive: `|- neg(neg bot) -> neg a`, i.e., `|- bot -> neg a`. This is ex_falso.
   Actually we want the other direction. Let's think differently.

3. `|- a -> neg bot` (a implies top, propositional tautology derivable from prop_s and ex_falso)
4. By temporal necessitation: `|- G(a -> neg bot)`
5. By temp_k_dist: `|- G(a -> neg bot) -> (G(a) -> G(neg bot))`
6. So `G(a) -> G(neg bot)`, i.e., `G(a) -> G(top)`.
7. By seriality_future on `G(top)`: `G(top) -> F(top)`.
8. By disc_next: `F(top) -> X(top)`.
9. Chain: `G(a) -> X(top)`.

Now we need to go from `G(a) /\ X(top)` to `X(a)`.

10. `G(a) -> G(G(a))` by temp_4.
11. `G(G(a))` means at all s > t, `G(a)` holds at s. In particular at t+1.
12. At t+1, `G(a)` holds, so by seriality, `F(a)` at t+1, so `a` at some s' > t+1.

This still doesn't directly give us `a` at t+1.

**The crucial realization**: We cannot derive `G(a) -> X(a)` from the base temporal axioms alone. We need the interaction between `G` and `U` (Until) to express the "next step" property. The correct route is:

**Using F_until_equiv + until_unfold + temporal 4 + structural reasoning**:

From `G(a)`:
1. `G(a) -> G(G(a))` by temp_4.
2. `G(G(a)) -> G(F(a))` by (from `G(a) -> F(a)` (seriality), necessitate to get `G(G(a) -> F(a))`, then K-dist to get `G(G(a)) -> G(F(a))`).
3. So `G(a) -> G(F(a))`.
4. `G(F(a))` means: at all future times s > t, `F(a)` holds at s.
5. `G(a) -> F(a)` by seriality. So `F(a)`.
6. `F(a) -> top U a` by F_until_equiv.
7. `top U a` at t with witness s1 > t where a(s1), and top at all r in (t, s1).
8. By until_unfold: `top U a -> X(a \/ (top /\ top U a))`.
9. So `X(a \/ (top /\ top U a))`: at t+1, either a or (top and top U a continues).

If we're in the `a` case at t+1, done: `a` at t+1 means `X(a)` at t.

If we're in the `top /\ top U a` case at t+1: this means `top U a` at t+1 with some further witness s2 > t+1. But we also have `G(a)` at t+1 (from temp_4 in step 1). So we can unfold again...

This is an infinite descent. The axiom system MUST have a way to handle this. The answer is **until_induction**.

**Correct derivation using until_induction with the right instantiation**:

We want: `G(a) |- top U a -> X(a)`.

until_induction with phi = top, psi = a, chi = a:
```
G(a -> a) /\ G(top /\ X(a) -> a) -> (top U a -> X(a))
```

First premise: `G(a -> a)` -- trivially derivable (necessitate the tautology `a -> a`).

Second premise: `G(top /\ X(a) -> a)`. This says: at all strictly future times, if `X(a)` holds then `a` holds. But `X(a)` at time s means `a` at s+1, which does NOT imply `a` at s. So this premise is NOT derivable in general.

UNLESS we have `G(a)` as a hypothesis. Under `G(a)`, at all future times s > t, `a(s)` holds. So in particular `a` at s. The premise `top /\ X(a) -> a` becomes `... -> a`, and `a` holds unconditionally at all future times.

So: from `G(a)`, derive `G(a)` (trivially), then derive `G(top /\ X(a) -> a)` because `G(a)` implies that at all future times, `a` holds, so the implication is satisfied.

More precisely:
- `G(a)` at t.
- `G(G(a))` at t by temp_4.
- `G(a)` at all s > t.
- At each such s: `a` at s (by... wait, this is what we're trying to prove).

**WE HAVE A CIRCULARITY**: To derive `G(top /\ X(a) -> a)` from `G(a)`, we need `a` at each future time s, but `a` at s only follows from `G(a)` via the T-axiom `G(a) -> a`, which is exactly what we've removed.

**THIS IS THE FUNDAMENTAL INSIGHT**: Under strict semantics without the T-axiom, `G(a)` in an MCS does NOT syntactically imply `a` in the same MCS. The formula `G(a)` lives in the MCS at time t, and it tells us about times s > t, but it says nothing about time t itself.

However, when we consider the SUCCESSOR MCS at time t+1, `G(a)` at t does tell us `a` at t+1 (since t+1 > t). But extracting this requires `G(a) -> X(a)`, which is what we're trying to derive.

### Finding 4: The Derivation G(a) -> X(a) Requires a New Axiom or Derived Theorem (HIGH confidence)

After careful analysis, `G(a) -> X(a)` is NOT directly derivable from the existing axioms without using the T-axiom. The problem is:

- `until_induction` has the right shape but its second premise requires `G(a)` to imply things at the same time point, creating circularity.
- `disc_next` gives `F(top) -> X(top)` but cannot be strengthened to `X(a)` without the T-axiom.
- The seriality + F_until_equiv route gives `top U a` but extracting `bot U a` (= `X(a)`) from it requires knowing there are no gaps, which is the T-axiom content.

**However**, `G(a) -> X(a)` IS semantically valid on all discrete linear orders with no maximum element. It says: if a holds at all strictly future times, then a holds at the next time. This is clearly true because the next time IS a strictly future time.

**The resolution**: `G(a) -> X(a)` should be derivable using the following strategy that avoids circularity:

From `G(a)`:
1. `G(a) -> F(a)` (seriality)
2. `F(a) -> top U a` (F_until_equiv)
3. `G(a) -> G(G(a))` (temp_4), so `G(G(a))`
4. From 2: `top U a`. Apply until_unfold: `X(a \/ (top /\ top U a))`.
5. We need to show that `X(a \/ (top /\ top U a)) -> X(a)` given `G(a)`.

Consider: at time t+1 (where X evaluates), either:
- Case (i): `a` at t+1. Done.
- Case (ii): `top /\ top U a` at t+1. This means `top U a` at t+1 with witness s > t+1.

But from step 3, `G(G(a))` at t means `G(a)` at t+1. So at t+1, `G(a)` also holds. From `G(a)` at t+1, we get `F(a)` at t+1, meaning some s' > t+1 with `a(s')`. Coupled with `top U a` at t+1, the witness s might be s' or some other point.

The problem is that case (ii) does not directly give `a` at t+1. It only gives `a` at some point strictly after t+1.

**WAIT. I was wrong above.** Let me re-examine:

`G(a)` at time t means `a(s)` for ALL `s > t`. So `a(t+1)` holds, period. The formula `G(a)` INCLUDES `a` at t+1 in its semantic content. The issue is purely proof-theoretic.

The reason the proof-theoretic derivation is hard: `G` is a primitive operator defined by `all_future`, and `X` is a derived operator `bot U`. The axiom system needs to connect these two.

**Key derivation that DOES work**:

Consider the until_induction axiom more carefully:
```
G(psi -> chi) /\ G(phi /\ X(chi) -> chi) -> (phi U psi -> X(chi))
```

Set phi = top, psi = a, chi = a:
```
G(a -> a) /\ G(top /\ X(a) -> a) -> (top U a -> X(a))
```

Second premise `G(top /\ X(a) -> a)`: We need to derive this from `G(a)`.

From `G(a)`: at all future times s > t, `a(s)`. In particular, any future time satisfies `a`. So `anything -> a` at future times. So `G(anything -> a)` holds, in particular `G(top /\ X(a) -> a)`.

Proof-theoretically: from `G(a)`, derive `G(a)` (trivial). Then `a -> (top /\ X(a) -> a)` by prop_s (weakening: `a -> (B -> a)` for any B). So `G(a -> (top /\ X(a) -> a))` by temporal necessitation of the propositional tautology... wait, we can't necessitate a non-theorem; `a -> (B -> a)` IS a theorem (prop_s), so `G(a -> (B -> a))` is derivable by temporal necessitation. Then by temp_k_dist: `G(a -> (B -> a)) -> (G(a) -> G(B -> a))`. So from `G(a)`: `G(B -> a)` where `B = top /\ X(a)`.

**YES! This works!**

Complete derivation of `G(a) -> X(a)`:

1. `|- a -> ((top /\ X(a)) -> a)` by prop_s (instance: `a -> (B -> a)` where B = `top /\ X(a)`)
2. `|- G(a -> ((top /\ X(a)) -> a))` by temporal necessitation of step 1
3. `|- G(a -> ((top /\ X(a)) -> a)) -> (G(a) -> G((top /\ X(a)) -> a))` by temp_k_dist
4. From `G(a)`: `G((top /\ X(a)) -> a)` by modus ponens on steps 2-3
5. `|- a -> a` by propositional tautology
6. `|- G(a -> a)` by temporal necessitation
7. Steps 4 and 6 give us: `G(a -> a) /\ G(top /\ X(a) -> a)`
8. By until_induction (phi=top, psi=a, chi=a): `(top U a) -> X(a)`
9. `|- G(a) -> F(a)` by seriality_future
10. `|- F(a) -> top U a` by F_until_equiv
11. Chain: `G(a) -> F(a) -> top U a -> X(a)`

**Therefore: `G(a) -> X(a)` is derivable from the current axiom system!**

The key insight is using prop_s (weakening) to derive `G(a) -> G(B -> a)` for arbitrary B, which satisfies the second premise of until_induction without circularity.

### Finding 5: Dual Derivation H(a) -> Y(a) (HIGH confidence)

By symmetric reasoning using the Since versions of the axioms:
- `since_induction` (past direction until_induction)
- `seriality_past` (H(a) -> P(a))
- `P_since_equiv` (P(a) -> top S a)

We get `H(a) -> Y(a)` where `Y(a) = bot S a`.

### Finding 6: What g_content(M) subset successor(M) Is Used For (HIGH confidence)

Tracing through the proof chain, `g_content(M) ⊆ successor(M)` serves these roles:

1. **Succ relation condition 1**: The Succ relation (SuccRelation.lean:59) is defined as `g_content u ⊆ v /\ f_content u ⊆ v ∪ f_content v`. The g_content inclusion IS the first condition. Without it, the chain construction cannot establish Succ links.

2. **ExistsTask relation**: `ExistsTask M N = g_content M ⊆ N` (SuccRelation.lean:87-88). This is the canonical temporal relation.

3. **Temporal coherence**: The dovetailed chain uses g_content propagation to establish that `G(phi)` at time n implies `phi` at all times m > n. This is the "forward G coherence" property (DovetailedChain.lean:213-224).

4. **Truth lemma for G**: In the completeness proof, showing `G(phi) in MCS(t) iff phi at all s > t` requires g_content inclusion to get the forward direction.

If we dropped g_content inclusion entirely, the canonical model would fail to validate `G(phi)` at the time point where the MCS contains `G(phi)`. The entire completeness proof would collapse.

### Finding 7: The Successor Seed Already Includes g_content (HIGH confidence)

Looking at SuccExistence.lean (line 87):
```lean
def successor_deferral_seed (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u
```

The successor seed explicitly includes `g_content u` as a subset. So when this seed is extended to an MCS by Lindenbaum's lemma, the resulting MCS `v` satisfies `g_content u ⊆ v` by construction.

**But wait** -- there's a subtlety. The sorry sites are NOT in the seed construction. They are in the PROOF that `g_content M ⊆ W` where W is obtained from `temporal_theory_witness_exists`. That function builds the seed `{psi} ∪ g_content(M)` (WitnessSeed.lean:48), so g_content IS in the seed, and the extension DOES contain g_content.

The sorry sites arise in a DIFFERENT context: they try to show that individual elements `a` of g_content are in the witness MCS, using the path `G(a) in W -> a in W` via the T-axiom. But since g_content(M) ⊆ seed ⊆ W, we actually have `a in W` DIRECTLY from the seed inclusion, without needing `G(a) -> a`!

**CRITICAL FINDING**: Many of the sorry sites may be provable WITHOUT the derivation of `G(a) -> X(a)`, simply by using the fact that `g_content(M) ⊆ seed ⊆ W`.

Let me verify: in `forward_step_g_content` (DovetailedChain.lean:132-142), the proof goes:
1. `G(a) in M` (from g_content definition)
2. `G(a) in W` (by G_agree)
3. `a in W` (by T-axiom) -- THIS IS THE SORRY

But `W = temporal_theory_witness_exists(M, phi, ...)`. The seed is `{phi} ∪ g_content(M)`. Since `a in g_content(M)`, `a in seed`, so `a in W` (since W extends the seed).

**Wait, that's wrong.** `g_content(M)` is `{a | G(a) in M}`. The seed is `{phi} ∪ g_content(M)`. So `a` IS in the seed directly. The Lindenbaum extension W satisfies `seed ⊆ W`. Therefore `a in W` follows from `a in g_content(M) ⊆ seed ⊆ W`.

**The T-axiom route was an UNNECESSARY detour!** The proof went through G(a) -> G(a) in W -> a in W, when it should have gone through a in g_content(M) -> a in seed -> a in W.

BUT: this only works for `temporal_theory_witness_exists` specifically, because its seed includes g_content. For OTHER constructions (the deferral seed in SuccExistence.lean), the seed is `g_content(u) ∪ deferralDisjunctions(u)`, which also includes g_content directly.

For the **UltrafilterChain** sorry sites (R_G_refl, etc.), the situation is different. These are about the algebraic/ultrafilter approach where the ordering on the Lindenbaum algebra uses `G(a) <= a`. This is a fundamentally different proof path.

### Finding 8: Two-Track Fix Strategy (HIGH confidence)

Based on the analysis, the sorry sites fall into two categories requiring different fixes:

**Track 1: Seed-based proofs (simpler, most MCS-chain sites)**

For `forward_step_g_content`, `temporal_witness_g_persistence`, and similar sites where the witness W comes from a seed that includes `g_content(M)`:
- Fix: Use `a in g_content(M) -> a in seed -> a in W` directly.
- No new theorems needed.
- Affected files: DovetailedChain.lean (some sites), UltrafilterChain.lean (line 2591), MCSWitnessSuccessor.lean, TargetedChain.lean (some sites).

**Track 2: Algebraic/ordering sites (requires G(a) -> X(a))**

For `R_G_refl` and similar sites where we need `G(a) <= a` in the Lindenbaum algebra ordering:
- This ordering is FALSE under strict semantics. `G(a)` does NOT imply `a` in general.
- Fix: These sites need to be restructured. R_G should NOT be reflexive under strict semantics.
- The algebraic approach may need significant reworking.

**Track 3: Forward/backward coherence (requires derived G(a) -> X(a))**

For `forward_dovetailed_forward_G` and similar sites where we need to go from `G(phi) at time n` to `phi at time m >= n`:
- The correct statement under strict semantics is `phi at time m > n` (strict), not `m >= n`.
- For `m = n+1` (the successor case): use `G(a) -> X(a)` derivation from Finding 4.
- For `m > n+1`: use transitivity of `G` (temp_4) plus the successor case.
- The base case `m = n` is NO LONGER VALID and the theorem needs to be restated.

## Root Cause Summary

The root cause is a **conceptual mismatch** between the proof strategy and the semantics:

1. Under reflexive semantics, `G(a)` at time t means `a` at all times s >= t, including t itself. The T-axiom captures this reflexive content.

2. Under strict semantics, `G(a)` at time t means `a` at all times s > t, excluding t. There is no T-axiom.

3. The proof infrastructure was built assuming reflexive semantics. When the T-axiom was removed, every site that extracted `a` from `G(a)` at the same time point broke.

4. **Many of these extractions were unnecessary.** The seed-based constructions already include `g_content(M)` directly, so `a in W` follows from set inclusion, not from the T-axiom.

5. For the sites where the T-axiom extraction IS necessary (notably the forward G coherence theorems), the fix is to derive `G(a) -> X(a)` using `prop_s + temp_k_dist + seriality_future + F_until_equiv + until_induction`. This derivation is valid and complete (Finding 4).

6. For the algebraic (ultrafilter) path, `R_G` reflexivity fails and must be replaced with a different relation or the algebraic approach needs restructuring.

## Recommended Approach

### Priority 1: Prove `G(a) -> X(a)` as a derived theorem (CRITICAL)

Create a new theorem in `Theories/Bimodal/Theorems/`:
```lean
theorem G_implies_X (a : Formula) :
    [] ⊢ (Formula.all_future a).imp (Formula.untl Formula.bot a) := by
  -- 1. G(a -> (B -> a)) by necessitation of prop_s
  -- 2. G(a -> (B -> a)) -> (G(a) -> G(B -> a)) by temp_k_dist
  -- 3. G(a) -> G(B -> a) where B = top /\ X(a)
  -- 4. G(a -> a) by necessitation of identity
  -- 5. By until_induction: (top U a) -> X(a)
  -- 6. G(a) -> F(a) -> top U a -> X(a)
  sorry -- derivation tree construction
```

And the dual:
```lean
theorem H_implies_Y (a : Formula) :
    [] ⊢ (Formula.all_past a).imp (Formula.snce Formula.bot a) := by
  sorry -- symmetric
```

### Priority 2: Fix seed-based sorry sites (EASY)

For sites like `forward_step_g_content` where the seed already includes g_content:
- Replace the T-axiom route with direct seed membership.
- This may require extracting the seed-extension property from `temporal_theory_witness_exists`.

### Priority 3: Fix coherence theorems (MODERATE)

Restate forward/backward coherence to use strict inequality:
```lean
-- Old: G(phi) at n, phi at m for m >= n (uses T-axiom for m = n)
-- New: G(phi) at n, phi at m for m > n (uses G(a) -> X(a) for m = n+1)
theorem forward_dovetailed_forward_G (...) (h_lt : n < m) (...) :
    phi ∈ forward_dovetailed M_0 h_mcs_0 m
```

### Priority 4: Restructure algebraic path (HARDER)

The R_G reflexivity sites in UltrafilterChain.lean need fundamental rethinking. Under strict semantics, R_G is NOT reflexive. The algebraic approach needs to either:
- Use a different relation (R_X for the next-step operator)
- Accept irreflexivity and restructure the completeness argument
- Use R_G as a strict preorder (transitive but not reflexive) with separate handling of the reflexive step

## Confidence Levels

| Finding | Confidence | Rationale |
|---------|------------|-----------|
| Property is semantically valid | HIGH | Direct from definition of strict G on Z |
| Root cause is T-axiom extraction | HIGH | Every sorry comment confirms this |
| G(a)->X(a) derivable via until_induction + prop_s | HIGH | Complete proof sketch verified step by step |
| Seed-based sites fixable without new theorems | MEDIUM-HIGH | Requires confirming seed inclusion for each site |
| H(a)->Y(a) derivable symmetrically | HIGH | Since axioms are symmetric to Until axioms |
| R_G reflexivity unfixable under strict semantics | HIGH | Semantic fact: G(a) does not imply a at same point |
| Two-track fix strategy | HIGH | Clear separation between seed-based and algebraic sites |

## Appendix: Complete Sorry Site Classification

### Sites fixable via seed membership (Track 1):
1. DovetailedChain.lean:142 - `forward_step_g_content`
2. UltrafilterChain.lean:2591 - `temporal_witness_g_persistence`
3. MCSWitnessSuccessor.lean:259 - forward witness g_persistence
4. TargetedChain.lean:242 - targeted forward G extraction

### Sites requiring G(a)->X(a) derivation (Track 3):
5. DovetailedChain.lean:224 - `forward_dovetailed_forward_G` (m >= n case)
6. DovetailedChain.lean:891, 896 - forward direction propagation

### Sites requiring H(a)->Y(a) derivation (Track 3, dual):
7. DovetailedChain.lean:277, 282 - backward H base case
8. DovetailedChain.lean:762 - backward_step_g_content (H direction)
9. DovetailedChain.lean:912, 917 - backward direction propagation
10. MCSWitnessSuccessor.lean:319 - backward witness h_persistence
11. TargetedChain.lean:346, 512 - targeted backward H extraction

### Sites requiring algebraic restructuring (Track 2):
12. UltrafilterChain.lean:97 - R_G_refl
13. UltrafilterChain.lean:520 - R_G related
14. UltrafilterChain.lean:1009 - R_G with bot

### Sites in SuccChainFMCS requiring axiom derivation trees:
15. SuccChainFMCS.lean:1244 - temp_t_future chi derivation tree
16. SuccChainFMCS.lean:4276 - temp_t_future chi derivation tree
17. SuccChainFMCS.lean:4419 - temp_t_future neg_neg_bot derivation tree

These need to be replaced with derivation trees for `G(chi) -> X(chi)` or restructured to avoid the T-axiom pattern entirely.
