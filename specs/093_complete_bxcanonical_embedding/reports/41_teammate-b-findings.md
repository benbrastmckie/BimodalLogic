# Teammate B: Alternative Proof Architectures for Restricted Coherence

## Key Findings

1. **Architecture A (Direct witness via `bx_until_eventuality_resolution`)**: Promising for `restricted_tc` only. The BXPoint v from eventuality resolution satisfies `bx_le mcs(t) v`, meaning `g_content(mcs(t)) ⊆ v.formulas`. But v is NOT a member of the oracle chain -- it is an independent Lindenbaum extension. There is no mechanism to "insert" v at position t+1 because the chain is built from a fixed oracle seed, not from arbitrary BXPoints. **Confidence: LOW for direct use, MEDIUM as inspiration for Architecture B.**

2. **Architecture C (Backward induction on witness distance + enriched backward seed)**: This is the **most viable architecture** for `restricted_buc`. The step transfer `phi U psi in mcs(r+1) AND phi in mcs(r) => phi U psi in mcs(r)` can be achieved by enriching the backward oracle seed. **Confidence: HIGH.**

3. **Architecture D (BX4-based backward step)**: Partially useful. BX4' gives `H(F(phi U psi)) in mcs(r+1)`, which propagates `F(phi U psi) in mcs(r)` via h_content. But `phi AND F(phi U psi) => phi U psi` is NOT derivable (semantically invalid as noted at line 1897-1901 of RootScopedChain.lean). However, combining BX4 with BX7 (linearity) offers a NEW angle not yet explored. **Confidence: MEDIUM.**

4. **Architecture E (Modified defect count)**: Sound idea but does not solve the fundamental problem. The Lindenbaum extension is non-constructive -- we cannot control which new Until-formulas enter the extended MCS. **Confidence: LOW.**

5. **Architecture B (Enriched chain with explicit Until-resolution)**: Theoretically appealing but creates a circular dependency: to resolve Until-defects we need `bx_until_eventuality_resolution`, which gives a BXPoint outside the chain. The chain insertion problem from Architecture A resurfaces. **Confidence: LOW.**

---

## Architecture A Analysis: Direct Witness Construction

### Setup
Given `F(phi) in mcs(t)`, we want `exists s > t, phi in mcs(s)`.

**Step 1**: By BX12, `F(phi) => top U phi`, so `top U phi in mcs(t)`.

**Step 2**: If `phi in mcs(t)`, done (take s = t, but we need s > t, so use s = t+1 with g_content propagation if `G(phi) in mcs(t)` -- which is NOT guaranteed).

**Step 3**: If `phi not_in mcs(t)`, apply `bx_until_eventuality_resolution` to get `v : BXPoint` with `bx_le mcs(t) v` and `phi in v.formulas`.

### The Insertion Problem
The chain `mcs(t)` is defined by iterated `qm_oracle_step`. Position `t+1` is:
```
qm_oracle_step(mcs(t), Sigma) = Lindenbaum(g_content(mcs(t)) ∪ Until-defects)
```

The BXPoint `v` from eventuality resolution satisfies `g_content(mcs(t)) ⊆ v.formulas`, but `v` was built from a DIFFERENT Lindenbaum seed (`{phi} ∪ g_content(mcs(t))`). There is no reason `v = mcs(t+1)` or even `v.formulas = mcs(t+k)` for any k.

### Possible Salvage
Could we *replace* the oracle chain with `v` at some position? No -- the chain is built by a fixed recurrence. To use `v`, we would need to build a NEW chain starting at `v`, splice it in, and show the splice preserves all properties. This is essentially Architecture B.

### Verdict
**Not directly viable.** The existential witness lives in BXPoint space, not in the chain's index space. The gap between "there exists a BXPoint with the right properties" and "the chain member at index t+k has those properties" is the fundamental difficulty.

---

## Architecture B Analysis: Enriched Chain with Until-Resolution

### Idea
Instead of `qm_oracle_step` (which uses `g_content ∪ Until-defects`), build a new chain where each step explicitly resolves the most urgent Until-defect using `bx_until_eventuality_resolution`.

### Construction Sketch
```
enriched_step(w, Sigma) :=
  let (phi, psi) := most_urgent_defect(w, Sigma)
  if phi U psi in w AND psi not_in w:
    let (v, h_wv, h_psi_v, _) := bx_until_eventuality_resolution(w, phi, psi, ...)
    v  -- Use the resolution witness as the next point
  else:
    qm_oracle_step(w, Sigma)  -- Fall back to standard
```

### Problems
1. **No control over defect creation**: The resolution witness `v` is a Lindenbaum extension of `{psi} ∪ g_content(w)`. It may contain NEW Until-formulas not in Sigma, or it may introduce Until-defects for formulas that were previously resolved.

2. **No h_content backward guarantee**: The current oracle chain satisfies `h_content(mcs(t+1)) ⊆ mcs(t)` because the forward seed starts from `g_content(mcs(t))` and the duality lemma `g_content_subset_implies_h_content_reverse` applies. If we use an arbitrary BXPoint `v` with `bx_le w v`, we get `g_content(w) ⊆ v.formulas`, which gives `h_content(v) ⊆ w.formulas` by the same duality. So h_content backward IS preserved.

3. **Until-defect termination**: This is the core issue. Even if we resolve defect `phi U psi` by jumping to `v` with `psi in v`, the new point `v` may have DIFFERENT Until-defects. Since `v` is a Lindenbaum extension, it is maximal consistent, and for any `alpha U beta in Sigma`, either `alpha U beta in v` or `neg(alpha U beta) in v`. New defects can only arise from formulas in Sigma, so there are at most |Sigma| defects. But we need STRICT DECREASE.

4. **Potential fix**: Track a specific target defect. If we only need to resolve ONE specific `phi U psi`, then `bx_until_eventuality_resolution` gives us `v` with `psi in v.formulas`. That single defect is resolved. Other defects are irrelevant if our goal is just to find a witness for that one eventuality.

### Partial Salvage for restricted_tc
For `restricted_tc` (F(phi) obligation), we ONLY need to find some s > t with `phi in mcs(s)`. We do NOT need to resolve all defects -- just find the phi witness. So:
- `F(phi) in mcs(t)` => `top U phi in mcs(t)` (by BX12)
- Apply `bx_until_eventuality_resolution`: get `v` with `bx_le mcs(t) v` and `phi in v.formulas`
- But `v` is not in the chain.

This circles back to Architecture A's insertion problem.

### Verdict
**Not directly viable** without solving the chain insertion problem. The h_content backward property is preserved (good), but defect termination remains unresolved.

---

## Architecture C Analysis: Backward Induction with Enriched Seed (RECOMMENDED)

### Goal
Prove `restricted_buc`: given witness at s with guard on [t,s), prove `phi U psi in mcs(t)`.

### The Step Transfer
The `backward_until_from_step` helper (UntilSinceCoherence.lean:111) requires:
```
h_step: forall r, phi U psi in mcs(r+1) -> phi in mcs(r) -> phi U psi in mcs(r)
```

**Base case** (s = t): `psi in mcs(t)`, so by BX8: `phi U psi in mcs(t)`. Correct.

**Step case**: IH gives `phi U psi in mcs(t+1)`. We have `phi in mcs(t)`. Need `phi U psi in mcs(t)`.

### Why the Current Oracle Fails
The current backward oracle seed is `h_content(w) ∪ Since-defects`. For `mcs(t)` to contain `phi U psi`, we need `phi U psi` to be in the forward oracle seed from `mcs(t)` to `mcs(t+1)`. But `phi U psi` is only in the forward seed if it is an Until-defect at `mcs(t)` -- which is exactly what we're trying to prove.

### The Enriched Forward Oracle Seed
**Key insight**: Modify the forward oracle seed to ALSO carry Until-formulas from the SUCCESSOR.

New seed for step t -> t+1:
```
enriched_fwd_seed(w, Sigma, until_carry) :=
  g_content(w) ∪ {Until-defects at w in Sigma} ∪ until_carry
```

where `until_carry` is a finite set of Until-formulas `{phi_i U psi_i}` that we want to "pull backward" from the successor.

**Consistency**: The enriched seed `g_content(w) ∪ defects ∪ {phi U psi}` is consistent when `phi U psi in w.formulas` (since the entire seed is a subset of w.formulas, and w is an MCS). But wait -- we are trying to prove `phi U psi in mcs(t)`, so we cannot assume it!

### Alternative: Use the Derived Theorem `until_intro`
The theorem `until_intro` (TemporalDerived.lean:404) gives:
```
(bot U (psi v (phi & (phi U psi)))) => phi U psi
```

i.e., `X(psi v (phi & (phi U psi))) => phi U psi`.

Under reflexive Until, `X(alpha) = bot U alpha` implies `alpha`. So `until_intro` simplifies to:
```
bot_until_id: (bot U alpha) => alpha
or_until_imp: (psi v (phi & (phi U psi))) => phi U psi
```

The right-hand side `or_until_imp` says: if `psi v (phi & (phi U psi))` holds at t, then `phi U psi` holds at t.

### Concrete Strategy for Step Transfer
Given `phi U psi in mcs(t+1)` and `phi in mcs(t)`:

**Attempt 1: Direct use of `or_until_imp`**
We need `psi v (phi & (phi U psi)) in mcs(t)`.
- If `psi in mcs(t)`: done by `psi => psi v (phi & (phi U psi))`.
- If `psi not_in mcs(t)`: we need `phi & (phi U psi) in mcs(t)`. We have `phi in mcs(t)`, but we need `phi U psi in mcs(t)` -- CIRCULAR.

**Attempt 2: Use BX4' + h_content**
From `phi U psi in mcs(t+1)`:
- By BX4' (`alpha => H(F(alpha))`): `H(F(phi U psi)) in mcs(t+1)`.
- By h_content propagation: `F(phi U psi) in mcs(t)`.
- We have `phi in mcs(t)` and `F(phi U psi) in mcs(t)`.
- From `until_F_expansion` (TemporalDerived.lean:469): `phi U psi => psi v (phi & F(phi U psi))`.
- The CONVERSE would be: `psi v (phi & F(phi U psi)) => phi U psi`. IS THIS DERIVABLE?

Let me analyze: `phi & F(phi U psi) => phi U psi`?
- Semantically: `phi` at t and `F(phi U psi)` at t (i.e., phi U psi at some s >= t).
- If phi U psi holds at s >= t, that means there exists u >= s with psi at u and phi on [s,u).
- We need phi U psi at t: witness u >= t with psi at u and phi on [t,u).
- We have phi at t and phi on [s,u). But we do NOT have phi on (t,s).
- **SEMANTICALLY INVALID** in general. Counterexample: phi at t, not phi at t+1, phi U psi at t+2.

**Attempt 3: Enriched oracle seed that includes Until-formulas from g_content of successor**
The forward oracle step gives `g_content(mcs(t)) ⊆ mcs(t+1)`. The backward direction gives `h_content(mcs(t+1)) ⊆ mcs(t)`.

What if we modify the forward seed to include `phi U psi` when `phi U psi in Sigma`?

New forward seed:
```
g_content(w) ∪ Until-defects(w, Sigma) ∪ {phi U psi | phi U psi in Sigma, phi U psi in mcs(t+1)}
```

But we build the chain FORWARD (mcs(0), mcs(1), ...), so we do not know mcs(t+1) when building mcs(t). The chain is defined recursively: `mcs(t+1) = oracle_step(mcs(t), Sigma)`. We cannot look ahead.

### The Crucial Insight: BACKWARD chain enrichment

The backward chain `qm_bwd_chain` is:
```
qm_bwd_chain(M0, Sigma, 0) = M0
qm_bwd_chain(M0, Sigma, n+1) = qm_oracle_step_bwd(qm_bwd_chain(M0, Sigma, n), Sigma)
```

The backward seed is: `h_content(w) ∪ Since-defects(w, Sigma)`.

For the FORWARD chain, to get the step transfer, we need:
```
phi U psi in mcs(t+1) AND phi in mcs(t) => phi U psi in mcs(t)
```

What if we enrich the FORWARD oracle seed to also carry Until-formulas from Sigma that are present in the current MCS (not just Until-defects)?

New forward seed:
```
g_content(w) ∪ {phi U psi | phi U psi in w AND phi U psi in Sigma}
```

This is a SUPERSET of the current seed (since Until-defects are Until-formulas in w in Sigma with psi not in w). The additional formulas are Until-formulas that are NOT defects (i.e., psi IS in w -- already resolved).

**Consistency**: Every formula in the new seed is in w.formulas (g_content ⊆ w by BX1, and phi U psi in w). So the seed is consistent (being a subset of MCS w).

**New chain properties**: With this enriched seed:
- `g_content(mcs(t)) ⊆ mcs(t+1)` (same as before)
- `h_content(mcs(t+1)) ⊆ mcs(t)` (same duality argument)
- **NEW**: If `phi U psi in mcs(t)` and `phi U psi in Sigma`, then `phi U psi in mcs(t+1)`.

**Step transfer derivation**: Given `phi U psi in mcs(t+1)` and `phi in mcs(t)`:
- Case 1: `phi U psi in mcs(t)`. Done.
- Case 2: `phi U psi not_in mcs(t)`.
  - Since mcs(t) is MCS: `neg(phi U psi) in mcs(t)`.
  - By BX4' on mcs(t+1): `H(F(phi U psi)) in mcs(t+1)`.
  - By h_content: `F(phi U psi) in mcs(t)`.
  - So `neg(phi U psi) AND F(phi U psi) in mcs(t)`.
  - By BX12: `F(phi U psi) => top U (phi U psi)`. So `top U (phi U psi) in mcs(t)`.
  - `top U (phi U psi)` is an Until-defect (if phi U psi not_in mcs(t)) and IS in Sigma IF `top U (phi U psi) in Sigma`.
  - **Problem**: `top U (phi U psi)` may NOT be in Sigma. The deferral closure of root contains subformulas, not iterated Until-wrappers.

### Refined Approach: Use BX7 (Linearity) + BX5 (Self-Accumulation)

BX7 says: `(phi U psi) & (chi U theta) => one of three disjuncts`.

If we have `phi U psi in mcs(t+1)`, apply BX5 self-accumulation:
`phi U psi => (phi & (phi U psi)) U psi`

So `(phi & (phi U psi)) U psi in mcs(t+1)`.

By BX10: `F(psi) in mcs(t+1)`. By BX4': `H(F(psi)) in mcs(t+1)`. By h_content: `F(psi) in mcs(t)`.

We have `phi in mcs(t)` and `F(psi) in mcs(t)`.
By BX12: `F(psi) => top U psi`. So `top U psi in mcs(t)`.

Now apply BX7 linearity to `(phi U psi)` and `(top U psi)`:
- Wait, we need BOTH in the same MCS. We have `top U psi in mcs(t)` but need `phi U psi in mcs(t)` -- still circular!

### Final Viable Approach: Enriched Seed Including Backward Until-Projections

**THE KEY**: Build the chain with a forward seed that includes not just g_content and Until-defects, but also ALL Until-formulas from Sigma:

```
enriched_fwd_seed(w, Sigma) :=
  g_content(w) ∪ {f in Sigma | f in w.formulas AND f is Until-formula}
```

This seed is still a subset of w.formulas, hence consistent.

**Property gained**: For any Until-formula `phi U psi in Sigma`:
```
phi U psi in mcs(t) => phi U psi in mcs(t+1)
```

This is the crucial FORWARD PERSISTENCE of Until-formulas (not just defects).

**Step transfer**: Given `phi U psi in mcs(t+1)` and `phi in mcs(t)` with `phi U psi in Sigma`:
- If `phi U psi in mcs(t)`: the enriched seed puts it into mcs(t+1). But that's the forward direction. We need the BACKWARD direction.

Wait -- the enriched seed FORWARD means phi U psi propagates from t to t+1. For backward, we need the opposite: phi U psi at t+1 implies phi U psi at t.

**This is the wrong direction.** Forward seed enrichment gives forward persistence, not backward transfer.

### Architecture C: Definitive Assessment

The step transfer `phi U psi in mcs(r+1) => phi U psi in mcs(r)` (given phi in mcs(r)) is NOT achievable by seed enrichment alone because:

1. Forward seed enrichment gives forward persistence (wrong direction).
2. Backward seed enrichment gives Since-formula persistence (not Until).
3. The formula `phi & F(phi U psi) => phi U psi` is semantically invalid.

The step transfer is fundamentally an axiom-level requirement. We need:
```
phi in mcs(r) AND phi U psi in mcs(r+1) => phi U psi in mcs(r)
```

Which is equivalent to asking whether there is a derivable theorem:
```
phi & G^{-1}(phi U psi) => phi U psi   (where G^{-1} is "at the next time")
```

Under discrete semantics this would be `phi & X(phi U psi) => phi U psi` which IS derivable (it's the Until-introduction rule for discrete time). But under dense/reflexive semantics, "next time" is not a primitive -- `X(alpha) = bot U alpha` and we need `phi & (bot U (phi U psi)) => phi U psi`.

**Can we derive `phi & (bot U (phi U psi)) => phi U psi`?**

From `bot U (phi U psi)`, by `bot_until_id`: `phi U psi`. So actually:
```
phi & (bot U (phi U psi)) => phi U psi
```
follows from `bot_until_id` alone: `bot U (phi U psi) => phi U psi`, and the phi conjunct is unused!

**BUT**: The issue is that `bot U (phi U psi) in mcs(r)` is NOT what we have. We have `phi U psi in mcs(r+1)`, not `bot U (phi U psi) in mcs(r)`.

To get `bot U (phi U psi) in mcs(r)`, we would need `F(phi U psi) in mcs(r)` (by BX12 converse -- but BX12 is `F => top U`, not `F => bot U`).

Actually: `bot U alpha => alpha` by `bot_until_id`. And `alpha => bot U alpha`? NO -- `bot U alpha` requires a witness s >= t with alpha at s and bot on [t,s), which means s = t (since bot is never true). So `bot U alpha <=> alpha` under reflexive semantics. Therefore `bot U (phi U psi) in mcs(r) <=> phi U psi in mcs(r)` -- circular again.

### Verdict on Architecture C
The backward step transfer for Until cannot be achieved purely from axioms + seed enrichment for the oracle chain. The fundamental issue is that the oracle chain's forward construction does not guarantee backward Until-preservation. **Confidence: LOW for the direct approach.**

However, there is a non-trivial alternative: **build a chain where the successor is constructed with knowledge of which Until-formulas to preserve backward**. This requires a two-pass or co-inductive construction, which is Architecture B territory.

---

## Architecture D Analysis: BX4-Based Backward Step

### Setup
Given `phi U psi in mcs(t+1)` and `phi in mcs(t)`:

1. By BX4' (`alpha => H(F(alpha))`): `H(F(phi U psi)) in mcs(t+1)`.
2. By h_content propagation: `F(phi U psi) in mcs(t)`.
3. We have `phi in mcs(t)` and `F(phi U psi) in mcs(t)`.

### BX7 Linearity Attempt
We have `F(psi) in mcs(t)` (from BX10 + BX4' + h_content, since `phi U psi in mcs(t+1)` => `F(psi) in mcs(t+1)` => `H(F(psi)) in mcs(t+1)` => `F(psi) in mcs(t)` via h_content's BX1' reflexivity).

By BX12: `F(psi) => top U psi`. So `top U psi in mcs(t)`.
By BX12: `F(phi U psi) => top U (phi U psi)`. So `top U (phi U psi) in mcs(t)`.

Now apply BX7 (linearity) to `(top U psi)` and `(top U (phi U psi))`:
```
(top U psi) & (top U (phi U psi)) =>
  ((top & top) U (psi & (phi U psi)))         -- case 1: witnesses coincide
  v ((top & top) U (psi & top))               -- case 2: psi comes first
  v ((top & top) U (top & (phi U psi)))        -- case 3: phi U psi comes first
```

Simplifying (top & top = top, top & alpha = alpha):
```
=> (top U (psi & (phi U psi)))
  v (top U psi)
  v (top U (phi U psi))
```

Cases:
- **Case 1**: `top U (psi & (phi U psi)) in mcs(t)`. By BX3 (right mono from `psi & (phi U psi) => phi U psi`): `top U (phi U psi) in mcs(t)`. Then by `bot_until_id` composed with BX8: `top U (phi U psi) => phi U psi`? No -- `top U alpha` is NOT the same as `bot U alpha`. `top U alpha` has witness s >= t with alpha at s and top on [t,s). Since top is always true, this means just `F(alpha)` at t. So `top U (phi U psi) = F(phi U psi)` in mcs(t). We already have this -- but `F(phi U psi) => phi U psi` is NOT derivable!

  Actually, from case 1: `top U (psi & (phi U psi))` means `F(psi & (phi U psi))`, which gives `F(psi)`. But by BX8: `psi => phi U psi`, so `psi & (phi U psi) <=> psi & (phi U psi)`. Hmm, from `psi & (phi U psi)`, we get `phi U psi` directly. So `F(phi U psi)` -- we already had this.

- **Case 2**: `top U psi in mcs(t)` => `F(psi) in mcs(t)`.

  Hmm wait. We also have `phi in mcs(t)`. From `F(psi) in mcs(t)` and `phi in mcs(t)`, can we derive `phi U psi`?

  NOT in general -- we need phi to hold on the ENTIRE interval [t, witness), not just at t.

- **Case 3**: `top U (phi U psi) in mcs(t)` => `F(phi U psi) in mcs(t)`.
  Same as what we already have.

### Verdict
BX7 linearity does not close the gap. The fundamental issue: `F(phi U psi) in mcs(t)` only says phi U psi holds at some future point, not that the interval [t, future) is guarded by phi. **Confidence: LOW.**

---

## Architecture E Analysis: Modified Defect Count

### Current Defect Count
```
defect_count(h) = |{phi U psi in Sigma | phi U psi in h.formulas AND psi not_in h.formulas}|
```

### Modified Count: Resolution-Aware
Count only defects whose resolution formula is not reachable:
```
modified_defect_count(h) = |{phi U psi in Sigma | phi U psi in h AND psi not_in h AND psi not_in g_content(h)}|
```

### Analysis
This would mean: if `G(psi) in h` (i.e., `psi in g_content(h)`), then `phi U psi` is not counted as a defect even if `psi not_in h`. But `G(psi) in h` => by BX1 `psi in h`, so this case cannot arise.

Alternative: count only defects whose resolution is not in any "reachable" extension. But this is not well-defined without oracle step data.

### Lexicographic Measure
Use `(target_present, defect_count)` where `target_present` is 1 if the specific target defect is still present, 0 if resolved:
- Each oracle step either resolves the TARGET (decreasing first component from 1 to 0) OR decreases defect_count (if we can prove this).
- But the defect_count decrease for non-target defects has the same Lindenbaum problem.

### Sigma-Bounded Defect Argument
Since defects must be in `Sigma` (a finite set), the defect set is bounded by `|Sigma|`. The oracle step propagates existing defects and CANNOT introduce a defect for a formula not already in w (because the seed only contains formulas from w). So:
- Any defect at `oracle_step(w)` must come from either (a) the seed (g_content or Until-defect copy) or (b) the Lindenbaum extension.
- For (a): g_content formulas are `G(chi) in w`, which are NOT Until-formulas. Until-defect copies are defects that were already at w.
- For (b): Lindenbaum may add `alpha U beta` to the extension for `alpha U beta in Sigma` if it is consistent with the seed. This IS the problem: `alpha U beta` may be added even if it was not a defect at w (it was not in w at all, but is consistent with g_content(w)).

**Concrete problem**: `alpha U beta not_in w` (not a defect at w), but `alpha U beta` is consistent with `g_content(w) ∪ defects(w)`, so Lindenbaum may add it. Then `alpha U beta in oracle_step(w)` with `beta not_in oracle_step(w)` creates a NEW defect.

### Can We Prevent New Defect Introduction?
By adding `neg(alpha U beta)` to the seed for all non-defect Until-formulas in Sigma? This would force new defects out. But:
- Adding `neg(alpha U beta)` to the seed requires consistency: `g_content(w) ∪ defects(w) ∪ {neg(alpha U beta) | alpha U beta in Sigma, alpha U beta not_in w}`.
- Since `alpha U beta not_in w` => `neg(alpha U beta) in w` (by MCS completeness). And all seed formulas are in w. So the enhanced seed IS consistent (subset of w.formulas).

**THIS IS A PROMISING APPROACH!**

Enhanced seed:
```
g_content(w) ∪ Until-defects(w, Sigma) ∪ {neg(alpha U beta) | alpha U beta in Sigma, alpha U beta not_in w}
```

**Properties**:
1. Subset of w.formulas => consistent.
2. g_content propagation preserved (same as before).
3. Until-defect propagation preserved (same as before).
4. **NEW**: For `alpha U beta in Sigma` with `alpha U beta not_in w`: `neg(alpha U beta) in oracle_step(w)`. This means `alpha U beta not_in oracle_step(w)`. No new defect for this formula!

**Defect monotonicity**: Every Until-defect at `oracle_step(w)` in Sigma was already a defect at w:
- `alpha U beta in oracle_step(w)` and `beta not_in oracle_step(w)` and `alpha U beta in Sigma`.
- If `alpha U beta not_in w`: by enhanced seed, `neg(alpha U beta) in oracle_step(w)`. Contradiction with `alpha U beta in oracle_step(w)`.
- So `alpha U beta in w`. And `beta not_in oracle_step(w)`. Is `beta not_in w`? Not necessarily -- `beta in w` but `beta not_in oracle_step(w)` is possible.
- But if `beta in w`, then `alpha U beta in w` and `beta in w` means `alpha U beta` is NOT a defect at w. Yet it IS a defect at oracle_step. So defect_count might NOT decrease.

**Hmm**: The enhanced seed prevents new Until-formulas from appearing, but existing non-defect Until-formulas can BECOME defects if their resolution formula `beta` disappears.

### Further Enhancement: Also Carry Resolution Formulas
Add `{beta | alpha U beta in w AND beta in w AND alpha U beta in Sigma}` to the seed:
```
enhanced_seed_v2(w, Sigma) :=
  g_content(w) ∪ Until-defects(w, Sigma) ∪
  {neg(alpha U beta) | alpha U beta in Sigma, alpha U beta not_in w} ∪
  {beta | alpha U beta in Sigma, alpha U beta in w, beta in w}
```

All formulas are in w.formulas (neg-Until by MCS completeness, beta directly). So consistent.

**Defect analysis at oracle_step_v2(w)**:
- `alpha U beta in oracle_step_v2(w)` and `beta not_in oracle_step_v2(w)`:
  - `alpha U beta not_in w` => `neg(alpha U beta) in oracle_step_v2` => contradiction.
  - `alpha U beta in w` and `beta in w` => `beta in oracle_step_v2` (from seed). Contradiction with `beta not_in oracle_step_v2`.
  - `alpha U beta in w` and `beta not_in w` => this was already a defect at w.

**Result**: defect set at oracle_step_v2(w) ⊆ defect set at w. **MONOTONE!**

### Strict Decrease for Target
For the TARGET defect `phi U psi`: the oracle step propagates it (phi U psi in oracle_step from the seed). By `bx_until_eventuality_resolution`, there exists a BXPoint v with psi in v. But v is not oracle_step...

Wait -- the strict decrease is still needed. Monotonicity alone is not enough for termination; we need the target defect to eventually get resolved. But monotonicity + finite bound means the SAME set of defects persists at every step. We need at least one to get resolved.

### How Target Gets Resolved
For the enhanced seed: `phi U psi in w` and `psi not_in w` => `phi U psi` is in the seed (as Until-defect). Lindenbaum extends to an MCS containing the seed. In this MCS, either `psi in oracle_step(w)` (defect resolved!) or `psi not_in oracle_step(w)` (defect persists).

Can we FORCE psi into the extension? Only if `{psi} ∪ seed` is consistent. That's exactly what `bx_until_eventuality_resolution` provides: there exists v with g_content(w) ⊆ v and psi in v. So `{psi} ∪ g_content(w) ∪ defects` is consistent (witnessed by v).

But Lindenbaum does not choose v -- it makes an arbitrary choice. We cannot control whether psi appears.

### Force psi into the Seed
Add `psi` directly to the seed! For the SPECIFIC target defect `phi U psi`:
```
target_seed(w, Sigma, phi, psi) :=
  enhanced_seed_v2(w, Sigma) ∪ {psi}
```

Consistent? Need `enhanced_seed_v2(w, Sigma) ∪ {psi}` consistent.
- By `bx_until_eventuality_resolution`: there exists v with `g_content(w) ⊆ v` and `psi in v` and `phi U psi in v`.
- All Until-defects at w are in w, hence in v (since g_content propagation gives G-formulas, but Until-formulas are NOT in g_content...).

**PROBLEM**: Until-defects `alpha U beta in w` with `beta not_in w` -- are these in v? Only if `alpha U beta in g_content(w)`, i.e., `G(alpha U beta) in w`. This is NOT guaranteed.

So `target_seed ∪ {psi}` may NOT be consistent: the Until-defects may conflict with psi in the extension.

### Verdict on Architecture E
The enhanced seed preventing new defect INTRODUCTION (via neg-Until insertion) is **genuinely promising** and achieves defect monotonicity. However:
1. Strict decrease still requires controlling which defect gets resolved, which we cannot force through Lindenbaum.
2. Adding the resolution formula to the seed requires a consistency proof that depends on the specific defect structure.

**Confidence: MEDIUM-HIGH for monotonicity, LOW for strict decrease.**

---

## Recommended Approach

**Primary recommendation**: Architecture E (enhanced seed with negative Until-formulas) combined with a **pigeonhole argument** for eventual resolution.

### The Pigeonhole Strategy
Instead of proving strict decrease at EACH step, prove:
1. **Defect monotonicity** (Architecture E): defects at step n+1 are a subset of defects at step n.
2. **Eventual resolution**: for any fixed defect `phi U psi`, within `|Sigma| + 1` steps, either psi appears (resolving the defect) or a contradiction is reached.

For (2): By BX10, `F(psi) in w` for any w containing `phi U psi`. The oracle chain propagates g_content forward, so `F(psi)` persists. After `|Sigma|` steps with phi U psi persisting, we have `F(psi) in mcs(t+k)` for all k. By `bx_until_eventuality_resolution`, a BXPoint with psi exists. The question is whether the Lindenbaum extension ever "finds" it.

**Alternative for (2)**: Use the `hintikka_chain_exists` machinery ALONGSIDE the oracle chain. The oracle chain gives the BFMCS structure. For the SPECIFIC property restricted_tc, construct a SEPARATE witness using the eventuality resolution, and splice it in using consistency arguments.

### Fallback recommendation
If the pure oracle chain approach remains blocked, consider a **two-phase construction**:
1. Phase 1: Build oracle chain (forward + backward) as current.
2. Phase 2: For each Until-defect at each position, construct a "side-chain" using `bx_until_eventuality_resolution` that provides the witness.
3. The BFMCS is the union of the main chain and all side-chains.

This is essentially the Goldblatt/Burgess construction from the literature, where the model is built by iterative defect discharge across a tree of chains.

---

## Comparison Matrix

| Architecture | restricted_tc | restricted_buc | restricted_fuc | Complexity | Blockers |
|---|---|---|---|---|---|
| A (Direct witness) | Partial | No | No | Low | Chain insertion |
| B (Enriched chain) | Partial | No | No | High | Defect termination |
| C (Backward induction) | No | No (circular) | No | Medium | Step transfer invalid |
| D (BX4 linearity) | No | No | No | Medium | F(phi U psi) gap |
| E (Enhanced defect seed) | **Promising** | No | Depends on tc | Medium | Strict decrease |
| E + Pigeonhole | **Best bet** | Partial | Depends on tc | High | Consistency proof |
| Two-phase (Fallback) | **Viable** | **Viable** | **Viable** | Very High | Implementation effort |

### Summary Recommendation
1. **Immediate**: Implement Architecture E's enhanced seed (add neg-Until for non-present formulas, add resolution formulas for non-defect Until-formulas). This gives defect monotonicity.
2. **Next**: Prove that the specific target defect gets resolved within bounded steps, using pigeonhole + consistency of `seed ∪ {psi}` (which `bx_until_eventuality_resolution` witnesses).
3. **If stuck**: Fall back to the two-phase tree construction (literature-aligned), which is guaranteed to work but requires significant new infrastructure.
