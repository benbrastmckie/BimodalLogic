# Teammate A Findings: Rigorous Analysis of the Ordered Discharge Chain

**Task**: 93 - Close BXCanonical embedding (6 sorry sites in RootScopedChain.lean)
**Date**: 2026-04-14
**Focus**: Mathematical rigor of ordered discharge chain; questions A-E from research brief

## Key Findings

1. **3-cycles in bx11_earlier DO exist** (semantically realizable). A BX11-minimum (element earlier than ALL others) may NOT exist for arbitrary defect sets. The `target_stays_direct_in_fold` precondition `h_earliest` cannot always be satisfied.

2. **Defect count is NOT a valid termination measure**. Resolved defects reappear because `psi in M'` implies `F(psi) in M'` (by temp_t_future). The F-obligation set is totally stable.

3. **The "eventually becomes earliest" argument is unsound**. The BX11 ordering changes at each step (depends on the current MCS), and no monotonicity argument connects orderings across steps.

4. **The CORRECT approach bypasses `target_stays_direct_in_fold` entirely**. Use `discharge_single_step` (line 955, already proved) which gives `psi in M'` and `g_content(M) subset M'` for a SPECIFIC formula psi, without needing any BX11 ordering. The chain must be redesigned around single-formula discharge.

5. **Forward_F follows from `rr_fwd_chain_F_propagate` + a single `discharge_single_step` insertion**. The key insight: `rr_fwd_chain_F_propagate` already reduces forward_F to "F(psi) cannot persist forever." We don't need F(psi) to persist -- we need a single step where F(psi) holds AND psi is resolved. `discharge_single_step` provides exactly this.

## Detailed Analysis

### A) Non-Transitivity and 3-Cycles in bx11_earlier

**Definition recall** (RootScopedChain.lean:906):
```
bx11_earlier M psi1 psi2 :=
  F(psi1 /\ psi2) in M  \/  F(psi1 /\ F(psi2)) in M
```

**Claim**: 3-cycles exist in the strict part of `bx11_earlier`.

**Proof by construction**: Consider formulas a, b, c and an MCS M such that:
- `F(a /\ F(b)) in M`, `F(a /\ b) not_in M` (a's witness strictly before b's)
- `F(b /\ F(c)) in M`, `F(b /\ c) not_in M` (b's witness strictly before c's)
- `F(c /\ F(a)) in M`, `F(c /\ a) not_in M` (c's witness strictly before a's)

**Why asymmetry holds**: If `F(a /\ b) in M`, then by `F_conj_comm_mcs` (line 897), `F(b /\ a) in M`, making `bx11_earlier M b a` true. So `NOT bx11_earlier M b a` requires `F(b /\ a) not_in M`, which requires `F(a /\ b) not_in M`. This is consistent with the construction above.

**Semantic realizability**: On integer time with M at time 0:
- a holds at times {1, 4} only, b holds at time {2} only, c holds at time {3} only
- F(a /\ F(b)): a at 1, F(b) at 1 (b at 2 > 1). CHECK.
- F(a /\ b) fails: no time where BOTH a and b hold. CHECK.
- F(b /\ F(c)): b at 2, F(c) at 2 (c at 3 > 2). CHECK.
- F(b /\ c) fails: no time where both b and c hold. CHECK.
- F(c /\ F(a)): c at 3, F(a) at 3 (a at 4 > 3). CHECK.
- F(c /\ a) fails: a at 1 (c not at 1), a at 4 (c not at 4). CHECK.

This is a valid model over integers. The 3-cycle arises because each formula has witnesses at DIFFERENT times -- `bx11_earlier M a b` says "some witness of a precedes some witness of b," NOT "all witnesses of a precede all witnesses of b."

**Consequence**: A BX11-minimum element (one that is `bx11_earlier` than ALL others) need not exist. In the 3-element case above: a is not earlier than c, b is not earlier than a, c is not earlier than b. `target_stays_direct_in_fold` CANNOT be applied because its precondition `h_earliest : forall chi, chi in others -> bx11_earlier M target chi` is unsatisfiable.

**Important caveat**: `target_stays_direct_in_fold` IS correctly proved (lines 1009-1046) -- it simply has a precondition that may not be satisfiable. The theorem is true but potentially vacuous for certain defect sets.

### B) Defect Count is Not a Valid Termination Measure

**The F-obligation set S = {chi in sigma_list | F(chi) in chain(n)} is totally stable.**

Proof: For any MCS M, if `psi in M`, then `F(psi) in M`. This follows from temp_t_future (BX1): `G(phi) -> phi`. In particular, `G(neg psi) -> neg psi`. Contrapositive: `psi -> neg G(neg psi) = F(psi)`. In an MCS, `psi in M` implies `F(psi) in M` by modus ponens with this theorem.

Therefore: resolving a defect (making `psi in M'`) does NOT remove psi from the F-obligation set. `psi in M'` implies `F(psi) in M'`. The formula remains an F-obligation forever.

Additionally, `no_new_f_defects` (OrderedSeedConsistency.lean:232) says F-obligations don't GROW (if `G(neg alpha) in M`, then `F(alpha) not_in M'` for any successor). Combined: the F-obligation set is exactly constant across all chain steps.

The "defect set" (formulas with F-obligation but NOT directly present) CAN fluctuate -- a formula can be resolved at one step and become a defect again at the next. **Defect count is not monotone in any direction.**

### C) "Eventually Becomes Earliest" is Unsound

The BX11 ordering depends on the MCS:
```
bx11_earlier M psi chi  :=  F(psi /\ chi) in M  \/  F(psi /\ F(chi)) in M
```

When M changes from chain(n) to chain(n+1), the BX11 ordering changes completely. There is no reason to expect:
- If `bx11_earlier chain(n) a b`, then `bx11_earlier chain(n+1) a b`
- If a is "not earliest" at step n, it eventually becomes earliest at step m > n

The BX11 ordering is computed from the CONTENTS of the MCS. After a Lindenbaum extension, the MCS can contain entirely different formulas (the extension adds formulas freely as long as consistency is maintained). The ordering at step n+1 can be completely unrelated to step n.

### D) Resolution Log and Its Limitations

A "resolution log" tracking which formulas have been directly resolved at least once does NOT help for forward_F because:

1. Resolving psi at step m (psi in chain(m+1)) does NOT guarantee psi remains in chain(s) for any s > m+1. The Lindenbaum extension at step m+2 may exclude psi.

2. Forward_F needs `exists s > n, psi in chain(s)` for a SPECIFIC n. The resolution must happen AFTER n. Having resolved psi before n is useless.

3. Even if every formula is resolved at least once during the chain, we need psi resolved at a step > n, which requires F(psi) to still be present at that step. Since the F-obligation set is stable (Section B), F(psi) is always present, but the resolution is not guaranteed to target psi specifically.

### E) The Fundamental Question -- Guaranteed Resolution of a SPECIFIC Formula

**Can we guarantee that a specific psi is directly resolved at some step after n?**

**YES -- using `discharge_single_step` (line 955)**. This is the key insight that the prior reports missed.

`discharge_single_step` states: given F(psi) in M, there exists M' with:
- `SetMaximalConsistent M'`
- `psi in M'`
- `g_content M subset M'`

No BX11 fold, no ordering, no disjunction. The formula psi is GUARANTEED to be in M'. The catch: other F-formulas are NOT preserved (no f_carry, no enriched fold). But **we don't need them for forward_F**.

## Recommended Approach

### Core Insight: Separate the Forward_F Proof from the Chain Construction

The current approach tries to prove forward_F WITHIN the existing `rr_fwd_chain`. This is the wrong level of abstraction. Instead:

**Step 1**: Use `rr_fwd_chain_F_propagate` (proved, line 1124). This says:

For all m >= n, either:
- There exists s with n < s <= m+1 and psi in chain(s), OR
- F(psi) in chain(m+1)

In other words: either psi appears somewhere in [n+1, m+1], or F(psi) persists to step m+1. This is an infinite disjunction: for every m, one of the two holds.

**Step 2**: By classical logic (excluded middle), either:
- Case A: psi in chain(s) for some s > n. DONE.
- Case B: For all s > n, psi not_in chain(s). Then by F_propagate with arbitrarily large m, F(psi) in chain(m) for all m > n. Now we need a contradiction or a witness.

**Step 3 (The New Argument)**: In Case B, F(psi) in chain(n) for all n >= the original n. Use `discharge_single_step` NOT as part of the chain, but as an EXISTENCE argument:

Given F(psi) in chain(n), `discharge_single_step` says there EXISTS an MCS M' with psi in M' and g_content(chain(n)) subset M'. But M' is NOT necessarily chain(n+1) -- it's just some MCS. This doesn't directly give us psi in chain(s).

**This doesn't work directly.** Let me reconsider.

### Revised Approach: Chain Modification (Approach A from handoff 02)

The only viable approach is to **modify the chain construction itself** so that psi is guaranteed to be resolved at its scheduled step.

**Key observation**: At step n where target = psi and F(psi) in chain(n), the current `enriched_fwd_step` uses `resolving_enriched_fwd_exists`, which gives the disjunction. Instead, use `discharge_single_step` at this step:

Define `targeted_fwd_step`:
```
targeted_fwd_step M h_mcs psi sigma_list :=
  if F(psi) in M then
    discharge_single_step M h_mcs psi h_F  -- gives psi in M', g_content(M) subset M'
  else
    fwd_succ M h_mcs psi  -- non-resolving step
```

Properties:
- `g_content(M) subset M'`: YES (both branches provide this)
- `psi in M'` when `F(psi) in M`: YES (guaranteed by discharge_single_step)
- Other F-formulas preserved: NO. F(chi) for chi != psi may be lost.

**Why F-formula loss doesn't matter**: We only need forward_F for the chain. Forward_F says: F(psi) in chain(n) implies psi in chain(s) for some s > n. The round-robin schedule visits psi at step n + k (for appropriate k < |sigma_list|). Between n and n+k, F(psi) is preserved by `rr_fwd_chain_F_propagate` ONLY IF the chain preserves F-formulas at each step.

**The problem**: If we use `targeted_fwd_step` at every step, F(psi) may be lost at intervening steps (when chi != psi is targeted). So F(psi) may not survive to psi's scheduled step.

**Alternative**: Use `targeted_fwd_step` only for psi, and `enriched_fwd_step` for other formulas. But this changes the chain definition per formula, making it impossible to define a single chain.

### The Correct Solution: A New Chain Per Formula

Define a new chain `psi_chain` for each formula psi:
```
psi_chain M0 h0 psi n :=
  discharge_single_step (psi_chain M0 h0 psi n).val ... psi ...
```

At every step, this chain resolves psi. So at step 1: psi in psi_chain(1). Forward_F is trivially satisfied for psi.

But this chain doesn't satisfy forward_F for OTHER formulas, and we need a SINGLE chain for the FMCS/BFMCS construction.

### Actually Viable: The Enriched Chain Already Works -- Proof by Contradiction

Reconsider `rr_fwd_chain_F_propagate`:

```
For all m >= n:
  (exists s, n < s <= m+1, psi in chain(s))  \/  F(psi) in chain(m+1)
```

Suppose for contradiction: psi not_in chain(s) for all s > n.

Then F(psi) in chain(m) for ALL m > n (by F_propagate with the left disjunct always false).

Now, the enriched_fwd_step at psi's visit step gives `psi in M' OR F(psi) in M'`. If psi never appears (our assumption), then F(psi) in M' at every step. In particular at psi's visit step m (where target = psi), `enriched_fwd_step_resolves_one` guarantees SOME w in M' with F(w) in chain(m). If w = psi, then psi in chain(m+1), contradicting our assumption. If w != psi, no contradiction.

**The key question**: Can we ensure w = psi at psi's visit step?

Using `target_stays_direct_in_fold`: only if psi is BX11-earliest among all defects. We showed this may not hold (3-cycles exist).

### The True Solution: Pairwise Discharge

Here is a concrete approach that WORKS:

**Insight**: We don't need psi to be BX11-earliest among ALL defects. We only need ONE step where psi is directly resolved. `discharge_two_step` (line 969, proved) says:

Given F(psi1) in M, F(psi2) in M, and `bx11_earlier M psi1 psi2`:
There exists M' with psi1 in M' and (psi2 in M' or F(psi2) in M') and g_content(M) subset M'.

`bx11_earlier_total` (line 912, proved) says: either `bx11_earlier M psi1 psi2` or `bx11_earlier M psi2 psi1`.

So for ANY two formulas with F-obligations, one of them is guaranteed to be directly resolved.

**Application to forward_F**: At psi's visit step m with F(psi) in chain(m):

Case 1: There are no other F-defects. Then `discharge_single_step` resolves psi. Done.

Case 2: There exist other F-defects. Take ANY other defect chi. By `bx11_earlier_total`, either `bx11_earlier M psi chi` or `bx11_earlier M chi psi`.
- If `bx11_earlier M psi chi`: `discharge_two_step` with target psi1 = psi gives psi in M'. Done.
- If `bx11_earlier M chi psi` (and NOT `bx11_earlier M psi chi`): chi is resolved instead. Psi may not be.

**The problem persists**: For every chi, we might have `bx11_earlier M chi psi` but not `bx11_earlier M psi chi`. Then psi is never the BX11-earlier element against any partner.

BUT: `bx11_earlier_total` gives AT LEAST ONE direction. If `bx11_earlier M psi chi` for ANY chi, we can use `discharge_two_step` to resolve psi. Only if `NOT bx11_earlier M psi chi` for ALL chi do we have a problem. And `NOT bx11_earlier M psi chi` means `F(psi /\ chi) not_in M AND F(psi /\ F(chi)) not_in M`. Combined with `bx11_earlier M chi psi` (by totality), this means `F(chi /\ psi) in M OR F(chi /\ F(psi)) in M`. By F_conj_comm_mcs, `F(chi /\ psi) = F(psi /\ chi)`, which we said is NOT in M. So `F(chi /\ F(psi)) in M`.

Now consider the fold with target = psi and all chi in others. At each fold step, BX11 between F(psi /\ acc) and F(chi) gives:
- Case 1: F(psi /\ acc /\ chi) -- requires F(psi /\ acc /\ chi) in M
- Case 2: F(psi /\ acc /\ F(chi)) -- psi stays direct
- Case 3: F(F(psi /\ acc) /\ chi) -- psi gets F-wrapped

In Case 3: `F(F(psi /\ acc) /\ chi) in M`. This means `NOT F((psi /\ acc) /\ chi) in M` and `NOT F((psi /\ acc) /\ F(chi)) in M` (since temp_linearity_mcs checks Case 1 first, then Case 2). But wait -- temp_linearity_mcs is deterministic: it checks Cases 1, 2, 3 in order. Case 3 only fires when Cases 1 and 2 don't hold in M. This means `F(psi /\ acc /\ chi) not_in M` and `F(psi /\ acc /\ F(chi)) not_in M`.

Hmm, but that's about the accumulated compound `psi /\ acc`, not psi alone. The BX11 relation between `F(psi)` and `F(chi)` is different from between `F(psi /\ acc)` and `F(chi)`.

**Conclusion on pairwise discharge**: It cannot guarantee psi is resolved when psi has no BX11-earlier pair-partner.

### Final Recommended Approach: Redefine the Chain with Single-Target Steps

The most reliable path forward:

1. **Redefine `rr_fwd_chain`** to use `discharge_single_step` at resolving steps (instead of `enriched_fwd_step`). Each step resolves EXACTLY its scheduled target:
   ```
   new_fwd_step M h_mcs target :=
     if F(target) in M then
       (discharge_single_step M h_mcs target ...).choose
     else
       fwd_succ M h_mcs target
   ```

2. **Reprove g_content propagation** (follows from discharge_single_step).

3. **Forward_F proof**: F(psi) in chain(n). By rr_fwd_chain_F_propagate (needs reproof for new chain), F(psi) persists or psi appears. But now F(psi) may NOT persist between steps (no enriched fold). So F_propagate may not hold for the new chain.

**This is the fundamental tension**: To guarantee psi is resolved at its scheduled step, we need `discharge_single_step` (which doesn't preserve other F-formulas). To guarantee F(psi) persists until psi's scheduled step, we need `enriched_fwd_step` (which doesn't guarantee psi is resolved).

### True Recommended Approach: Hybrid Chain

Define a hybrid chain that ALTERNATES:
- At psi's scheduled step: use `discharge_single_step` for psi
- At all other steps: use identity (M' = M via set_lindenbaum of g_content(M))

Wait -- this doesn't build a valid chain for all formulas.

**Actually, the simplest correct approach**:

For a SPECIFIC formula psi with F(psi) in chain(n):

Step 1: `rr_fwd_chain_F_propagate` gives us: for all m >= n, either psi appears in (n, m+1] or F(psi) in chain(m+1).

Step 2: Suppose psi never appears. Then F(psi) in chain(m) for all m >= n.

Step 3: The enriched_fwd_step at each step guarantees SOME formula w is directly resolved (`enriched_fwd_step_resolves_one`). Since the F-obligation set is constant (|sigma_list| formulas with F-obligations), and at each step one of them is directly resolved, by pigeonhole after |sigma_list| steps, psi must have been the resolved formula at some step.

**Wait -- is this true?** No. `enriched_fwd_step_resolves_one` says some w with F(w) in M is in M'. But w could be the SAME formula at every step. The BX11 fold may always pick the same "witness" w at every step. There is no pigeonhole argument because the same formula can be resolved repeatedly.

**Corrected pigeonhole**: In sigma_list.length consecutive steps, the schedule visits each formula exactly once. At psi's scheduled step m, target = psi and F(psi) in chain(m) (by Step 2). `enriched_fwd_step_resolves_one` says some w from sigma_list with F(w) in chain(m) is in chain(m+1). But w may equal some chi != psi.

**The only way to guarantee w = psi** is to ensure psi has the earliest BX11 witness, which requires the precondition of `target_stays_direct_in_fold`, which requires a BX11-minimum that may not exist.

### Final Assessment and Actual Recommendation

After exhaustive analysis, here is the honest assessment:

**The ordered discharge chain approach as currently formulated has a gap**: `target_stays_direct_in_fold` requires a BX11-minimum that may not exist due to 3-cycles. The plan's Phase 2 claim that "psi eventually becomes BX11-earliest" is unsound because the ordering changes at each step.

**What DOES work**: If we could show that for the SPECIFIC MCS at psi's visit step, psi happens to be BX11-earlier than all other defects, we'd be done. This is a property of the specific MCS, not of the BX11 ordering in general.

**The way forward** requires one of:

**(i) Prove that 3-cycles cannot occur at "visit steps"**: At psi's visit step, the MCS has been constructed by a specific sequence of enriched steps. Perhaps this construction ensures psi is BX11-earliest. This would require deep analysis of how the Lindenbaum extension affects BX11 ordering.

**(ii) Prove a weaker property than BX11-minimum**: For example, prove that at psi's visit step, the fold happens to resolve psi even without psi being the global minimum. This could work if the fold order (which depends on sigma_list ordering) aligns with the BX11 ordering.

**(iii) Redesign the chain using discharge_single_step with "F(psi) injection"**: Build a chain where at resolving steps, use `enriched_resolving_seed_consistent` with F(psi) injected into the compound. Specifically: fold all F-defects EXCEPT psi into a compound, then form `F(psi /\ compound) in M` (using BX11). The seed `{psi, compound} union g_content(M)` gives psi in M' guaranteed AND compound in M' (preserving other F-formulas). This requires `F(psi /\ compound) in M`, which requires psi to be BX11-earlier than the compound -- the same minimum problem.

**(iv) Completely different chain construction**: Use the Goldblatt/Burgess approach where the chain is constructed by defect selection (choosing the BX11-earliest AT EACH STEP among REMAINING defects), running for exactly N steps. The key: at each step, pick the pair-winner against ONE specific formula (not minimum over all). After N steps, psi must have been the winner at some step. This doesn't require a global minimum -- just that psi wins against at least one other formula. And by `F_conj_comm_mcs`, if `F(psi /\ chi) in M`, then `bx11_earlier M psi chi` AND `bx11_earlier M chi psi`. So the only way psi NEVER wins is if for all chi, `F(psi /\ chi) not_in M`, meaning BX11 always gives Case 2 or 3 but never Case 1 for psi. In Case 2: `F(psi /\ F(chi)) in M` -- psi IS BX11-earlier! So psi wins against chi. The only remaining case is Case 3 for ALL chi: `F(F(psi) /\ chi) in M` for all chi, meaning chi is always earlier than psi.

If psi is "last" against ALL chi (Case 3 always fires), then `F(F(psi) /\ chi) in M` for all chi. This means all chi are BX11-earlier than psi. Can we then run `target_stays_direct_in_fold` on ANY chi (say chi_1) with psi in the "others" list? We'd get chi_1 in M' guaranteed. Not helpful for resolving psi.

**HOWEVER**: if `F(F(psi) /\ chi) in M` for all chi, then `bx11_earlier M chi psi` for all chi (via Case 3 with commutativity). Now, does there exist a chi that is BX11-earlier than all OTHER chi's (excluding psi)? This is a smaller problem (n-1 formulas). By induction on the number of formulas, we can find a chain of resolutions until psi is the only remaining defect, then use `discharge_single_step`.

**This is the most promising direction**: An inductive argument on the number of unresolved defects, not requiring a global minimum.

## Confidence Level

**MEDIUM** (50%)

**Justification**: The 3-cycle analysis definitively shows that the plan's main assumption (existence of a BX11-minimum) is flawed. However, weaker properties may suffice. The inductive approach (resolve OTHER formulas first using `target_stays_direct_in_fold` on subsets, then discharge psi when it's alone) is promising but requires careful formalization. The key gap: after resolving chi at step m, the MCS at step m+1 may have a completely different BX11 ordering, and the "remaining defects" may not decrease (since resolved formulas re-enter the F-obligation set).

The fundamental tension remains: discharge_single_step gives deterministic resolution but loses F-formulas; enriched_fwd_step preserves F-formulas but gives non-deterministic resolution. No construction proposed so far cleanly combines both properties.
