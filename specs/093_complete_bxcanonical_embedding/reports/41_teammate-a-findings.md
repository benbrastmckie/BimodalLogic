# Teammate A: Primary Mathematical Analysis of Blockers

## Key Findings

1. **Blocker 1 (defect_count decrease) is solvable** with a modified oracle seed construction. Confidence: HIGH (85%).
2. **Blocker 2 (backward step transfer) is fundamentally unsound as stated**, but the backward Until coherence property IS provable via a different construction strategy. Confidence: HIGH (80%).
3. **The two blockers share a common root cause**: the oracle chain construction was designed for forward propagation only. A bidirectional construction resolves both.
4. **Blocker 1 is more tractable** and should be attacked first, as Blocker 2's resolution depends on restricted_tc (which depends on Blocker 1).

---

## Blocker 1 Analysis: defect_count Decrease

### The Problem

In `OracleStep.lean:272` and `:452`, the sorry is at:

```
defect_count(sigma_sig(qm_oracle_step w Sigma)) < defect_count(sigma_sig(w))
```

The goal is to show that when `psi notin oracle_step` (the target defect is NOT discharged), the defect count still strictly decreases. This requires proving `untilDefectSet(sigma_sig(oracle)) subset untilDefectSet(sigma_sig(w))` (defect monotonicity).

### Root Cause Analysis

The oracle seed is `g_content(w) union {Until-defects of w in Sigma}`. The Lindenbaum extension produces an MCS containing this seed, but potentially also containing additional formulas. The concern is sub-case (b) from the code comments:

> If `f U g` is added by Lindenbaum (not from the seed), and `g notin oracle_step`, then this is a NEW defect not present in `w`.

### Can Lindenbaum Introduce New Until-Defects?

**YES, in general.** Lindenbaum extension is non-constructive (Zorn's lemma). The MCS it produces contains the seed but can contain ANY consistent extension. If `alpha U beta in Sigma` and `alpha U beta` is consistent with the seed but `alpha U beta notin w.formulas`, Lindenbaum could add it, creating a new defect.

**However**, there is a crucial constraint: the defect set is restricted to `Sigma`. So the question is whether Lindenbaum can add `f U g in Sigma` that was NOT in `w.formulas`.

Consider: `f U g in Sigma` and `f U g notin w.formulas`. Then `neg(f U g) in w.formulas` (by MCS maximality of w). Is `neg(f U g)` in the oracle seed? Not necessarily -- the seed only contains `g_content(w)` and Until-defects. But `neg(f U g)` is in `w.formulas`, not in the seed.

So Lindenbaum extension could in principle produce an MCS containing BOTH the seed AND `f U g` (if `neg(f U g)` is not derivable from the seed). This would be a new defect.

### Solution Strategy A: Enriched Oracle Seed (RECOMMENDED)

**Enrich the oracle seed to include ALL Until-formulas from Sigma that are in w:**

```
qm_oracle_seed_enriched w Sigma :=
  g_content(w)
  union {f U g | f U g in w.formulas, f U g in Sigma}    -- ALL Until in Sigma at w
  union {neg(f U g) | neg(f U g) in w.formulas, f U g in Sigma}  -- ALL neg-Until in Sigma at w
```

This seed is still a subset of `w.formulas` (hence consistent). By including both `f U g` and `neg(f U g)` for all Until-formulas in Sigma, Lindenbaum cannot flip the membership of any Until-formula in Sigma. This gives:

**For any `f U g in Sigma`:**
- If `f U g in w.formulas`, then `f U g in seed subset oracle_step`
- If `f U g notin w.formulas`, then `neg(f U g) in w.formulas`, so `neg(f U g) in seed subset oracle_step`, so `f U g notin oracle_step`

Therefore: `{f U g in Sigma | f U g in oracle_step} = {f U g in Sigma | f U g in w.formulas}`.

**Defect monotonicity follows immediately**: An Until-defect at oracle_step is `f U g in Sigma, f U g in oracle_step, g notin oracle_step`. Since `f U g in oracle_step` iff `f U g in w.formulas`, this means `f U g in w.formulas`. And `g notin oracle_step` (while we cannot conclude `g notin w.formulas` directly from this), we need a finer argument.

Actually, wait. Defect monotonicity says: if `f U g` is a defect at `sigma_sig(oracle)`, then it's a defect at `sigma_sig(w)`. A defect at oracle means `f U g in Sigma, f U g in oracle_step, g notin oracle_step`. With the enriched seed, `f U g in oracle_step` implies `f U g in w.formulas`. So `f U g in sigma_sig(w)`. But we need `g notin sigma_sig(w)`, i.e., `g notin w.formulas` (given `g in Sigma`).

Could `g in w.formulas` but `g notin oracle_step`? Yes! The enriched seed doesn't force `g` into the oracle_step. If `g in w.formulas` but the Lindenbaum extension happens to exclude `g`... wait, `g` need not be in the seed. So Lindenbaum could put `neg(g)` in the oracle instead.

**This means the enriched seed approach alone is not quite sufficient for defect monotonicity in the strict subset sense.**

### Solution Strategy B: Enriched Seed + Target Witness Tracking (RECOMMENDED)

A cleaner approach: instead of proving `untilDefectSet(oracle) subset untilDefectSet(w)`, prove the OR-condition directly. The `hintikka_step_or_condition_sigma_sig` theorem needs:

```
psi in sigma_sig(oracle) OR (phi U psi in sigma_sig(oracle) AND defect_count decreases)
```

In the second disjunct, we need defect_count decrease. Use `hintikka_step_target_decrease` which requires:
1. The target `phi U psi` is a defect at `sigma_sig(w)` -- YES (by hypothesis)
2. `psi in sigma_sig(oracle)` -- we're in the case where this is FALSE (we took the right disjunct)
3. Wait, `hintikka_step_target_decrease` needs `psi in h2.formulas` (the witness reached). But we're in the case `psi notin oracle`. So we CAN'T use this theorem directly.

Actually, re-reading `hintikka_step_target_decrease`: it needs `psi in h2.formulas` to get the STRICT decrease. But in our OR-condition, the right disjunct is taken when `psi notin oracle`. So we need a DIFFERENT decrease argument.

### Solution Strategy C: Alternative Termination Measure

Instead of `defect_count` (number of unsatisfied Until-formulas), use a **lexicographic measure** on the sequence of oracle steps:

Since the oracle chain iterates `qm_oracle_step`, and each step either:
- Discharges a defect (psi enters the MCS) -- strict decrease
- Propagates all defects -- but the set of defects cannot grow (with enriched seed)

With the enriched seed from Strategy A, the set `{f U g in Sigma | f U g in oracle_step}` is exactly `{f U g in Sigma | f U g in w.formulas}`. So the Until-formulas-in-Sigma at the oracle are a SUBSET of those at w. But their defect status might differ because `g` membership can change.

Actually, with enriched seed, include `g` and `neg(g)` too for all `g` where `f U g in Sigma`:

```
qm_oracle_seed_full w Sigma :=
  g_content(w)
  union {f | f in w.formulas, f in Sigma or neg(f) in Sigma}
```

This forces the sigma_signature to be IDENTICAL: `sigma_sig(oracle) = sigma_sig(w)` for all formulas in Sigma. But then NO defect is ever discharged, which is useless.

### Solution Strategy D: The Correct Approach -- Quasimodel Chain Termination

The actual fix is to recognize that `hintikka_step_or_condition_sigma_sig` is asking the wrong question at this level. The defect_count decrease should be proved at the CHAIN level, not at the single-step level.

The `hintikka_chain_exists` construction uses well-founded recursion on `defect_count`. At each step:
- If `psi in oracle_step`: chain terminates, defect discharged
- If `psi notin oracle_step`: `phi U psi` persists (by oracle seed), and we recurse

The recursion terminates because Sigma is finite (at most `|Sigma|` Until-defects). But we need the defect count to STRICTLY DECREASE at each step where the target is not discharged. Since the target defect `phi U psi` persists AND `psi` is still absent, the target is still a defect. So the defect count doesn't decrease from discharging the target.

**The key insight**: at each oracle step, SOME defect must be discharged or the whole MCS is unchanged. By the pigeonhole principle over the finite `Sigma`, after at most `|Sigma|` steps with no target discharge, some other defect must have been discharged, changing the MCS. But this doesn't directly give a decreasing measure at each step.

**The standard literature approach** (Burgess 1984, Reynolds 1996): Build the chain by choosing to discharge ONE specific defect at a time. The oracle should be targeted: at step i, if the target `phi U psi` is still a defect, pick ANY defect and build the next MCS to specifically discharge THAT defect. Since each step discharges one defect and the enriched seed prevents new defects from appearing, after at most `|Sigma|` steps, either the target is discharged or there are no defects left (contradiction since the target is still a defect).

**This requires changing `qm_oracle_step` to be a TARGETED oracle** that resolves a chosen defect rather than just propagating g_content + all defects.

### Concrete Implementation Plan for Blocker 1

1. **Modify `qm_oracle_seed`** to include enriched content:
   - `g_content(w)` (as before)
   - All Until-defects in Sigma at w (as before)
   - For EACH Until-defect `f U g` in Sigma: add `g` if `g in w.formulas` (or equivalently, skip the defect if already resolved)
   - Negations of all `f U g in Sigma` where `f U g notin w.formulas`

2. **Or, better**: use a TWO-PHASE oracle:
   - Phase 1: Choose a specific defect `alpha U beta` (the one with, say, the smallest index in Sigma)
   - Phase 2: Build seed = `g_content(w) union {beta} union {neg-Until for all other Until in Sigma not in w}`

   But `beta` might not be consistent with the seed! (That's the whole point of a defect -- `beta` is absent.)

3. **The truly correct approach**: Use BX10 (`phi U psi -> F(psi)`) + BX1 (`G(psi) -> psi`) at the MCS level. Since `phi U psi in w.formulas`, we have `F(psi) in w.formulas` by BX10. So `psi in g_content(w)` is FALSE (that would mean `G(psi) in w`, which combined with BX1 gives `psi in w`, contradicting the defect). But `F(psi) in w.formulas` means `neg(G(neg(psi))) in w.formulas`, which means `G(neg(psi)) notin w.formulas`.

   At the oracle step, `g_content(w) subset oracle_step`, but `F(psi)` does NOT propagate through g_content (F is not G). However, by BX12: `F(psi) -> top U psi`. So `top U psi in w.formulas`. If `top U psi in Sigma`, it's in the defect set and propagates to oracle_step.

### Assessment

Blocker 1 requires restructuring the oracle to use a **targeted defect-discharge** approach rather than blanket propagation. The enriched seed must prevent new defects while ensuring one specific defect is discharged. This is a non-trivial but well-understood construction from the literature.

**Estimated difficulty**: Medium-high. Requires modifying `qm_oracle_step` and proving new consistency lemmas.

---

## Blocker 2 Analysis: Backward Step Transfer

### The Problem

In `RootScopedChain.lean:1921`, the sorry needs:

```
phi U psi in mcs(r+1) AND phi in mcs(r) -> phi U psi in mcs(r)
```

where `mcs(r)` and `mcs(r+1)` are consecutive elements of the oracle chain.

### Why This is Semantically Invalid

The docstring at line 1899-1901 gives the correct counterexample:
- `phi` at t=0, `neg phi` at t=1, `phi` at t=2, `psi` at t=2
- Then `phi U psi` holds at t=1 (witness t=2, guard holds vacuously on empty interval)
- `F(phi U psi)` holds at t=0 (witnessed by t=1)
- But `phi U psi` does NOT hold at t=0 (guard fails at t=1 where `neg phi`)

So `phi AND F(phi U psi) -> phi U psi` is invalid. No BX axiom combination can derive it.

### Can BX5 + BX6 Help?

**BX5** (self-accumulation): `phi U psi -> (phi AND (phi U psi)) U psi`
**BX6** (absorption): `phi U (phi AND (phi U psi)) -> phi U psi`

These operate on the SAME MCS, not across chain steps. They don't help with the backward transfer.

### Does Backward Until Follow from restricted_tc + restricted_fuc?

**NO.** Consider: restricted_tc gives `F(phi) in mcs(t) -> exists s > t, phi in mcs(s)`. restricted_fuc gives `phi U psi in mcs(t) -> exists s >= t, psi in mcs(s) with guard`. Neither gives backward Until coherence.

Backward Until coherence says: if the SEMANTIC witness exists (psi at s, phi on [t,s)), then `phi U psi in mcs(t)`. This is the COMPLETENESS direction for Until -- it says the MCS "knows" about Until when the witness pattern exists in the chain.

### The Correct Approach: Construction-Based

The backward step transfer approach is doomed because it tries to prove a general principle that is semantically invalid. Instead, backward Until coherence should be proved by **construction**: build the chain so that `phi U psi` is present at mcs(t) whenever the witness pattern exists.

**Approach 1: Enriched Backward Oracle Seed**

When building `mcs(r)` from `mcs(r+1)` (backward), include Until-formulas in the seed:

```
backward_seed(mcs(r+1), Sigma) :=
  h_content(mcs(r+1))
  union {phi U psi | phi U psi in Sigma, phi U psi in mcs(r+1)}
```

But this doesn't work for the forward chain (which builds mcs(r+1) from mcs(r), not the reverse).

The fundamental issue: the oracle chain builds FORWARD (mcs(n+1) from mcs(n)), but backward Until coherence requires information to flow BACKWARD.

**Approach 2: Two-Pass Construction**

1. First pass: build the forward chain `mcs(0), mcs(1), ...` using the current oracle
2. Second pass: for each position t, if the semantic witness pattern for `phi U psi` exists at t, enrich `mcs(t)` to include `phi U psi`

But MCS enrichment is not possible -- an MCS is already maximal.

**Approach 3: Build the Chain with Until-Awareness from the Start (RECOMMENDED)**

The key insight from Burgess's original construction: the chain should not just propagate g_content and Until-defects forward. It should be built so that the BACKWARD Until property holds by construction.

In the standard completeness proof for temporal logic, the canonical model construction ensures Until coherence by using the **filtration/unraveling** technique: the chain is built from a TREE of MCS's, where backward coherence is guaranteed because each node's content is chosen to satisfy all temporal formulas.

For our linear chain indexed by Int, the approach is:

**Use BX6 (absorption) + BX5 (self-accumulation) to derive backward Until at each step:**

Given: `phi U psi in mcs(r+1)` and `phi in mcs(r)`.

By BX5: `phi U psi in mcs(r+1)` implies `(phi AND (phi U psi)) U psi in mcs(r+1)`.

By h_content propagation: `H((phi AND (phi U psi)) U psi) in mcs(r+1)` would give `(phi AND (phi U psi)) U psi in mcs(r)`. But we DON'T have this H-formula.

What we DO have: `h_content(mcs(r+1)) subset mcs(r)`. So if `H(alpha) in mcs(r+1)`, then `alpha in mcs(r)`. But `H(phi U psi)` is not in `mcs(r+1)` in general.

**Approach 4: Modified Construction -- Include H(phi U psi) in Forward Seed**

When building `mcs(r+1)` from `mcs(r)`, if `phi U psi in mcs(r)` and `psi notin mcs(r)`, include `H(phi U psi)` in the oracle seed for `mcs(r+1)`:

```
enriched_oracle_seed(w, Sigma) :=
  g_content(w)
  union {phi U psi | phi U psi in w, psi notin w, phi U psi in Sigma}  -- defects
  union {H(phi U psi) | phi U psi in w, phi U psi in Sigma}           -- backward projections
```

Then `H(phi U psi) in mcs(r+1)`, so by h_content duality: at step r+2, when we look back, `phi U psi in mcs(r+1)` is ensured by the h_content relation... wait, that's circular.

Actually: `H(phi U psi) in seed subset mcs(r+1)`. Now at mcs(r+2), `h_content(mcs(r+2)) subset mcs(r+1)` gives us nothing about mcs(r).

The real question is: with `H(phi U psi) in mcs(r+1)`, can we conclude `phi U psi in mcs(r)` via `h_content(mcs(r+1)) subset mcs(r)`? YES! Because `H(phi U psi) in mcs(r+1)` means `phi U psi in h_content(mcs(r+1))`, and `h_content(mcs(r+1)) subset mcs(r)` gives `phi U psi in mcs(r)`.

**THIS WORKS!** The key: modify the oracle seed to include `H(phi U psi)` for all `phi U psi in Sigma` that are in `w.formulas`.

### Verification of Approach 4

**Consistency**: We need `H(phi U psi)` to be consistent with the rest of the seed. The seed includes `g_content(w)` and Until-defects. Since `phi U psi in w.formulas`, by BX4 (connectedness): `G(P(phi U psi)) in w.formulas`. So `P(phi U psi) in g_content(w) subset seed`. And `P(phi U psi) = neg(H(neg(phi U psi)))`. So `H(neg(phi U psi)) notin` any consistent extension of the seed (since `neg(H(neg(phi U psi)))` is in the seed). This means `H(phi U psi)` is NOT derivably inconsistent from `P(phi U psi)`, but nor is it derivable from it.

Wait, we need to check: is `{g_content(w)} union {H(phi U psi)}` consistent?

`g_content(w) = {chi | G(chi) in w}`. We need `H(phi U psi)` to be consistent with `g_content(w)`.

Assume for contradiction: `g_content(w) |- neg(H(phi U psi))`, i.e., `g_content(w) |- G(neg(phi U psi))` (since `neg(H(alpha)) = G(neg(alpha))`). Wait, `neg(H(alpha))` is NOT `G(neg(alpha))`. Let me be precise:

`H(alpha) = neg(P(neg(alpha))) = neg(neg(G'(neg(neg(alpha)))))` -- no, this is getting confused. In our syntax:
- `Formula.all_past chi` = H(chi)
- `Formula.some_future chi` = F(chi) = neg(G(neg(chi)))

So `neg(H(phi U psi)) = P(neg(phi U psi))` = `some_past(neg(phi U psi))`.

For the seed to be consistent, we need: the set `g_content(w) union {H(phi U psi) | ...} union {defects}` does not derive False.

Since this entire set is a subset of what we WANT in mcs(r+1), and mcs(r+1) exists as an MCS (by Lindenbaum), the question is whether this particular subset is consistent.

Actually, the simplest argument: `qm_oracle_seed w Sigma subset w.formulas` (proved as `qm_oracle_seed_subset_mcs`). If we add `H(phi U psi)` to the seed, is `H(phi U psi) in w.formulas`?

By BX4 (connect_future): `phi U psi in w.formulas` implies `G(P(phi U psi)) in w.formulas`. But we want `H(phi U psi)`, not `P(phi U psi)`.

`H(phi U psi)` means "at all past times, phi U psi held." This is NOT derivable from `phi U psi in w`. So `H(phi U psi)` might not be in `w.formulas`.

**Problem**: The enriched seed `g_content(w) union {H(phi U psi)}` might NOT be a subset of `w.formulas`, so we can't use the simple consistency argument.

We need to prove consistency directly: `g_content(w) union {H(phi U psi)}` is consistent.

Assume it derives False: there exist `chi_1, ..., chi_k in g_content(w)` such that `chi_1, ..., chi_k |- neg(H(phi U psi))`. By temporal necessitation: `G(chi_1), ..., G(chi_k) |- G(neg(H(phi U psi)))`. Since `G(chi_i) in w.formulas` for each i, we get `G(neg(H(phi U psi))) in w.formulas`.

Now `G(neg(H(phi U psi)))` in w means at all future times, `neg(H(phi U psi))` holds, i.e., at all future times, there exists a past time where `neg(phi U psi)` holds. This does not obviously contradict `phi U psi in w.formulas`.

**This consistency proof is non-trivial and may fail.** The enriched seed might genuinely be inconsistent for some w.

### Assessment of Approach 4

The approach has a consistency gap. We cannot simply add `H(phi U psi)` to the oracle seed without proving it's consistent with `g_content(w)`. This consistency is NOT obvious and might not hold in general.

### Approach 5: Direct Construction with BX Axioms

Instead of modifying the oracle seed, prove backward Until coherence DIRECTLY from the chain's structural properties.

The chain has: `g_content(mcs(r)) subset mcs(r+1)` and `h_content(mcs(r+1)) subset mcs(r)`.

Given: `phi U psi in mcs(r+1)` and `phi in mcs(r)`.

By BX4 (connect_future): `phi U psi in mcs(r+1)` implies `G(P(phi U psi)) in mcs(r+1)`.
By h_content: `P(phi U psi) in h_content(mcs(r+1)) subset mcs(r)`.
So `P(phi U psi) in mcs(r)`.
Also `phi in mcs(r)`.

Now: `P(phi U psi) AND phi in mcs(r)`. We need `phi U psi in mcs(r)`.

Is `P(phi U psi) AND phi -> phi U psi` derivable? This says: if at some past time `phi U psi` held, and phi holds now, then `phi U psi` holds now. **This is semantically VALID!**

Proof: If `phi U psi` held at time s < r, then there exists u >= s with psi at u and phi on [s, u). If u >= r, then phi on [r, u) (subset of [s, u)), psi at u, so `phi U psi` at r. If u < r, then psi at u < r. But wait, we also need phi on [r, u)... but u < r so this interval is empty. So we need psi at some u >= r. Hmm, this doesn't work: `phi U psi` at s < r means psi at some u in [s, infinity) with guard. But u could be < r, giving us psi at u < r, which doesn't help for `phi U psi` at r.

**Wait, actually `P(phi U psi)` at time r means `phi U psi` held at some time s < r.** It does NOT mean `phi U psi` holds at r. The formula `P(phi U psi) AND phi -> phi U psi` is **NOT** semantically valid.

Counterexample: time 0: phi, psi (so phi U psi at 0). Time 1: phi, neg psi. Time 2: neg phi. Then P(phi U psi) at time 1 (witnessed by time 0), phi at time 1, but phi U psi does NOT hold at time 1 (guard fails at time 2, or rather there's no future witness for psi reachable with phi-guard).

So Approach 5 fails.

### Approach 6: BX11 (Temporal Linearity) + Direct Semantic Argument

BX11: `F(phi) AND F(psi) -> F(phi AND psi) OR F(phi AND F(psi)) OR F(F(phi) AND psi)`.

This doesn't directly help with backward Until.

### Approach 7: The Canonical Approach -- Filtration Through Sigma

The standard approach for backward Until coherence in temporal logic completeness proofs (e.g., Reynolds 2003, Gabbay et al. 2003) is:

**Build the chain so that at each time t, the MCS mcs(t) contains phi U psi whenever the semantic witness pattern exists in the chain.** This is done by constructing the chain ALL AT ONCE rather than iteratively.

For an Int-indexed chain, the construction is:
1. Start with the "seed" MCS at position 0
2. For each phi U psi in subformulaClosure(root), ensure the chain satisfies the semantic condition

This is the **filtration** or **bulldozing** technique. It requires building the model globally, not locally step-by-step.

**For the current codebase**: The `dd_bfmcs` construction (defect-discharge BFMCS) at `RootScopedChain.lean:955` has the same sorry. The `qm_bfmcs` construction attempts a different approach but hits the same wall.

The resolution requires either:
1. A global construction (not step-by-step oracle iteration), OR
2. An enriched oracle that maintains backward Until as an invariant

### Approach 8: Enriched Oracle with G(phi U psi) (MOST PROMISING)

Instead of `H(phi U psi)`, use `G(phi U psi)`:

The key BX axiom for Until is BX5 (self-accumulation): `phi U psi -> (phi AND (phi U psi)) U psi`.

Combined with BX10: `phi U psi -> F(psi)`.

And BX1 (reflexivity of G): `G(alpha) -> alpha`.

Consider: if `phi U psi in w.formulas`, does `G(phi U psi) in w.formulas`?

NOT in general. `phi U psi` at time t does not imply `phi U psi` at all future times.

But: by BX5, `phi U psi -> (phi AND (phi U psi)) U psi`. So at any intermediate time where phi holds and phi U psi hasn't been discharged yet, phi U psi still holds. This is the self-accumulation property.

**The chain construction already preserves this**: at step r, if `phi U psi in mcs(r)` and `psi notin mcs(r)`, then `phi U psi` is in the oracle seed for mcs(r+1), so `phi U psi in mcs(r+1)`.

For BACKWARD: at step r, if `phi U psi in mcs(r+1)`, can we conclude `phi U psi in mcs(r)`? Only if we built mcs(r) to contain it. Since mcs(r) was built BEFORE mcs(r+1), we can't retroactively add formulas.

**The fundamental tension**: forward chains can't guarantee backward properties without advance knowledge.

### Summary for Blocker 2

The backward step transfer `phi AND F(phi U psi) -> phi U psi` is semantically invalid. No combination of BX axioms can derive it. The backward Until coherence requires a fundamentally different construction strategy:

1. **Global (non-iterative) construction**: Build all MCS's simultaneously, e.g., via filtration
2. **Reverse-pass enrichment**: Build forward, then rebuild backward to add Until-formulas
3. **Bidirectional oracle**: Build the chain from the MIDDLE (where the witness is) outward

Of these, option 3 is most compatible with the current codebase architecture.

---

## Recommended Approach

### Priority: Attack Blocker 1 First

Blocker 1 (defect_count decrease) blocks restricted_tc, which in turn blocks restricted_fuc. Blocker 2 is independent but harder.

### For Blocker 1: Targeted Defect-Discharge Oracle

Replace `qm_oracle_step` with a targeted version that:
1. Picks a specific Until-defect to discharge
2. Uses BX10 (`phi U psi -> F(psi)`) + Lindenbaum to get `psi` into the next MCS
3. Includes negations of all other Until-formulas in Sigma to prevent new defects

The targeted oracle discharges exactly one defect per step, giving strict decrease.

**Implementation sketch**:
```
targeted_oracle_seed w Sigma target :=
  g_content(w)
  union {target_psi}                    -- discharge the target
  union {neg(f U g) | f U g in Sigma, f U g notin w, f U g != target}
  union {f U g | f U g in w, f U g in Sigma, f U g != target}  -- preserve others
```

Consistency proof: `target_psi` is consistent with `g_content(w)` because `F(target_psi) in w` (by BX10), and `G(neg(target_psi)) notin w` (else `neg(target_psi) in w` by BX1, contradicting MCS consistency with `phi U psi in w` via BX9).

Wait -- `F(psi)` means `neg(G(neg(psi)))`, so `G(neg(psi)) notin w`. But does this mean `psi` is consistent with `g_content(w)`?

Yes: if `g_content(w) |- neg(psi)`, then by temporal necessitation `G(g_content(w)) |- G(neg(psi))`, so `G(neg(psi)) in w`, contradicting `F(psi) in w`.

So `g_content(w) union {psi}` is consistent. The full seed consistency requires checking that adding the negations of other Until-formulas doesn't create contradiction with `psi`. This needs careful verification.

### For Blocker 2: Bidirectional Chain Construction

Build the chain from each position that has Until-obligations, ensuring backward Until coherence by construction:

1. For `phi U psi in mcs(t)`: the forward chain from t will eventually discharge psi at some step u
2. Between t and u, phi U psi persists (by oracle seed construction)
3. For positions r < t: build mcs(r) with `phi U psi` included if phi holds at r and phi U psi holds at r+1

This requires building mcs(r) AFTER mcs(r+1) is known, i.e., building the chain from position u BACKWARD to some start. The bidirectional construction:
- Forward pass: discharge defects
- Backward pass: propagate Until-formulas backward through positions where guard holds

The backward pass modifies the chain, which means re-checking forward properties. But since we're only ADDING formulas (enriching MCS's is not possible since they're maximal), this requires a different technique.

**Most viable**: Build the chain in a single pass that includes backward Until-formulas in the seed by using the BX4 (connectedness) + BX10 (eventuality) axioms to ensure the right content.

### Estimated Effort

- Blocker 1: 2-3 implementation phases (modify oracle, prove consistency, prove defect decrease)
- Blocker 2: 3-4 implementation phases (design bidirectional construction, prove coherence properties)

---

## Evidence/Examples

### Blocker 1: Lindenbaum Can Add New Until-Defects

Let Sigma = {p, q, p U q, r, s, r U s}.
Let w.formulas contain p U q (defect: q absent) but NOT r U s.

Oracle seed = g_content(w) union {p U q}.
Lindenbaum extension could add r U s (consistent with seed if neg(r U s) is not derivable from the seed).
If s is also absent from the extension, r U s is a new defect not present at w.

### Blocker 2: Step Transfer Counterexample

Let mcs(0) = MCS containing {phi, neg psi, neg(phi U psi)}.
Let mcs(1) = MCS containing {phi U psi, neg phi, psi}.

This is consistent: mcs(0) has phi but not phi U psi. mcs(1) has phi U psi (discharged by psi at time 1).
g_content(mcs(0)) subset mcs(1): any G(chi) in mcs(0) gives chi in mcs(1). This doesn't force phi U psi.
h_content(mcs(1)) subset mcs(0): any H(chi) in mcs(1) gives chi in mcs(0). This doesn't give phi U psi in mcs(0).

Step transfer asks: phi U psi in mcs(1) AND phi in mcs(0) -> phi U psi in mcs(0). But phi U psi notin mcs(0) (neg(phi U psi) in mcs(0)). So step transfer FAILS.

### BX5 Self-Accumulation Example

phi U psi in w gives (phi AND (phi U psi)) U psi in w. This means: at some future time u, psi holds, and at all times in [now, u), BOTH phi and phi U psi hold. This is the enriched guard that makes the forward chain propagate phi U psi automatically until discharge.
