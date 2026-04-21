# Teammate A Findings — Task 109 Round 8

**Role**: Primary Angle — Rigorous analysis of correct chain constructions
**Date**: 2026-04-21
**Session**: (team research round 8)

---

## Key Findings

### 1. Why the "Schedule + Monotonicity Contrapositive" Strategy Fails

The Report 07 strategy claimed that when F(φ) drops at step k (meaning F(φ) ∈ chain(k-1)
but F(φ) ∉ chain(k)), then φ must appear in chain(k). This is the `defect_one_step_preservation`
step. **This is wrong for `fwd_succ` in the current construction.**

The proof of `fwd_chain_F_not_return` (RootScopedChain.lean lines 112-143) establishes that
once F(φ) leaves the forward chain it never returns. It works by showing:
- G(¬φ) ∈ chain(m) → G(G(¬φ)) ∈ chain(m) (via temp_4)
- G(G(¬φ)) propagates into chain(m+1) via g_content

But the REASON F(φ) drops at step k is that `fwd_succ` ran with `schedule(k-1) = ψ ≠ φ`,
and the Lindenbaum extension `set_lindenbaum({ψ} ∪ g_content(chain(k-1)))` chose (via
`Classical.choice`) to include G(¬φ). This is a free choice — `set_lindenbaum` only
guarantees that the seed is extended to an MCS; it may add G(¬φ) at any step where
G(¬φ) is not already excluded by the seed.

Concretely, `fwd_succ(M, ψ)` when F(ψ) ∈ M returns `set_lindenbaum({ψ} ∪ g_content(M))`.
This seed contains G(¬φ)? NO — g_content(M) = {α | G(α) ∈ M}. If G(¬φ) ∈ M, then
¬φ ∈ g_content(M). But we have F(φ) ∈ M, so ¬G(¬φ) ∈ M, so G(¬φ) ∉ M, so ¬φ ∉ g_content(M).

Wait — so far so good. The seed {ψ} ∪ g_content(M) does NOT include G(¬φ) if F(φ) ∈ M.
BUT the Lindenbaum extension can still add G(¬φ) to the resulting MCS, because G(¬φ) is
consistent with {ψ} ∪ g_content(M) **as long as G(¬φ) is not derivably inconsistent with
the seed**. And here is the key: G(¬φ) is consistent with {ψ} ∪ g_content(M) in general.

The seed {ψ} ∪ g_content(M) says:
- ψ is true at the next time
- All formulas α with G(α) ∈ M hold at the next time

This does NOT force φ to be true at the next time (F(φ) ∈ M says φ will be true at SOME
future time, not the IMMEDIATE next). Adding G(¬φ) to the MCS is consistent with the seed
as long as nothing in {ψ} ∪ g_content(M) derives φ — and nothing does, because
F(φ) = ¬G(¬φ) ∈ M does not propagate through g_content (only G-formulas propagate).

**Conclusion**: `defect_one_step_preservation` is FALSE for `fwd_succ`. When F(φ) drops at
step k, it is because `set_lindenbaum` freely added G(¬φ), and φ is NOT guaranteed to appear
in chain(k). The drop says "G(¬φ) was added," not "φ was placed." These are incompatible.

### 2. The Enriched Seed Approach: Can It Work?

The proposal: enrich the seed for step n to be
`{ψ, F(φ₁), F(φ₂), ...} ∪ g_content(M)` where ψ = schedule(n) and {φ₁, ...} = f_content(M)
(all current F-obligations). Then Lindenbaum would be forced to preserve all F-obligations.

**The consistency question**: Is `f_content(M) ∪ {ψ} ∪ g_content(M)` consistent when M is MCS?

We need: is {F(φ₁), F(φ₂), ..., ψ} ∪ g_content(M) consistent?

The existing `forward_temporal_witness_seed_consistent` shows {ψ} ∪ g_content(M) is consistent
when F(ψ) ∈ M. It uses the argument: if {ψ} ∪ g_content(M) ⊢ ⊥, then G(¬ψ) ∈ M (via
generalized temporal K), contradicting F(ψ) ∈ M.

For the enriched seed, suppose {F(φ₁), ..., F(φₖ), ψ} ∪ g_content(M) ⊢ ⊥. The generalized
temporal K argument requires that each element of the inconsistent finite subset have its G-form
in M. For F(φᵢ) = ¬G(¬φᵢ) to be usable in this way, we need G(¬G(¬φᵢ)) = G(F(φᵢ)) ∈ M.

**Here is the obstruction**: We do NOT in general have G(F(φ)) ∈ M when F(φ) ∈ M. This
would require the axiom `F(φ) → G(F(φ))` (F-formulas persist), which is NOT a BX axiom
and is NOT valid on all linear orders (counterexample: any model where φ holds at exactly
one future time point). This was confirmed in previous research rounds (Report 07, Teammate A).

So enriching the seed with the full f_content DOES NOT have a consistency proof. The seed
`f_content(M) ∪ {ψ} ∪ g_content(M)` may be inconsistent.

**Alternative enrichment — include only F(φ) itself**: The seed `{F(ψ), ψ} ∪ g_content(M)`.
We want to show this is consistent when F(ψ) ∈ M and F(ψ) ∈ M (trivially both conditions
are F(ψ) ∈ M). This is just adding F(ψ) to the existing consistent seed. But F(ψ) in the
seed means the Lindenbaum result M' contains F(ψ), so by monotonicity of F-obligations and
`fwd_chain_F_not_return`, F(ψ) persists in all chain(m) for m ≥ n+1.

Wait — is `{F(ψ), ψ} ∪ g_content(M)` consistent when F(ψ) ∈ M?

If L ⊆ {F(ψ), ψ} ∪ g_content(M) and L ⊢ ⊥, split cases on whether F(ψ) ∈ L:
- F(ψ) ∉ L: L ⊆ {ψ} ∪ g_content(M), which is consistent by the existing proof. Done.
- F(ψ) ∈ L: L = L' ∪ {F(ψ)} for some L'. L' ∪ {F(ψ)} ⊢ ⊥ means L' ⊢ ¬F(ψ) = G(¬ψ).
  Now L' ⊆ {ψ} ∪ g_content(M). Apply generalized temporal K to L':
  - If ψ ∈ L': The argument for {ψ} ∪ g_content(M) gives G(¬ψ) ∈ M (from L' \ {ψ} ⊆ g_content(M)
    deriving ¬ψ, then G-ing it). But F(ψ) ∈ M means ¬G(¬ψ) ∈ M. Contradiction.
  - If ψ ∉ L': L' ⊆ g_content(M), so G(α) ∈ M for each α ∈ L'. By genTK, G(G(¬ψ)) ∈ M,
    so G(¬ψ) ∈ M (by temp_4 applied in MCS: G(G(¬ψ)) → G(¬ψ) — wait, temp_4 says G(φ) → G(G(φ)),
    not G(G(φ)) → G(φ)). This direction does NOT give G(¬ψ) ∈ M from G(G(¬ψ)) ∈ M.

Hmm. G(G(¬ψ)) ∈ M does NOT imply G(¬ψ) ∈ M without the temporal T-axiom G(φ) → φ (removed
under irreflexive semantics). This is the same obstacle as the g_content_subset_self problem.

**Conclusion on enriched seeds**: The enriched seed `{F(ψ), ψ} ∪ g_content(M)` is not
straightforwardly consistent either, because in the case ψ ∉ L' we get G(G(¬ψ)) but cannot
reduce it to G(¬ψ) without the temporal T-axiom. The enriched seed approach is BLOCKED by
the same fundamental obstruction.

However, I note a subtlety: the existing `forward_temporal_witness_seed_consistent` for
`{ψ} ∪ g_content(M)` DOES work, because in the "ψ ∈ L" case it filters ψ out and applies
genTK to G(¬ψ) directly, and in the "ψ ∉ L" case it derives G(G(¬ψ)) and then uses
`G(⊥) → G(¬ψ)` (not G(G(¬ψ)) → G(¬ψ)) — specifically it uses G(⊥) which contradicts
F(ψ) via the formula `G(⊥) → G(¬ψ)` (since ⊥ → ¬ψ and necessitation). This works because
G(⊥) → G(¬ψ) IS derivable, but G(G(¬ψ)) → G(¬ψ) is not (without temporal T).

For the {F(ψ), ψ} ∪ g_content(M) case with F(ψ) ∈ L and ψ ∉ L':
- L' ⊢ G(¬ψ) (from L' ∪ {F(ψ)} ⊢ ⊥)
- L' ⊆ g_content(M)
- But L' ⊬ anything stronger — we can't apply G in front of L' ⊢ G(¬ψ) to get G(G(¬ψ)) ⊢ G(G(¬ψ))
  because L' is NOT a context of G-formulas in this subproof, only their contents.
- From G(α) ∈ M for each α ∈ L' (since L' ⊆ g_content(M)), genTK gives G(L') ⊢ G(G(¬ψ)),
  and all of G(α) ∈ M, so G(G(¬ψ)) ∈ M. Then G(¬ψ) ∈ M by... temporal T-axiom. BLOCKED.

The enriched seed with F(ψ) in it runs into the same wall. The enriched seed approach
does not work under irreflexive semantics.

### 3. Which BX Axioms Can Help F-Preservation?

Reviewing each relevant BX axiom:

**BX5 (self-accumulation)**: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`. This says Until is self-reinforcing.
Does NOT say F(φ) propagates. Useful for Until coherence, not F-preservation.

**BX9 (Until elimination)**: `(φ U ψ) → (φ ∨ ψ)`. Extracts current-time truth from Until.
Does NOT help with F-preservation.

**BX10 (F → Until)**: `(φ U ψ) → F(ψ)`. Together with BX12 gives F ↔ ⊤ U in some sense.
Does NOT preserve F across steps.

**BX11 (temporal linearity)**: `F(φ) ∧ F(ψ) → F(φ ∧ ψ) ∨ F(φ ∧ F(ψ)) ∨ F(F(φ) ∧ ψ)`.
This says two F-obligations have their witnesses linearly ordered. Importantly:
- If F(φ) ∈ M and we build a chain step, the Lindenbaum extension might violate F(φ) by
  introducing G(¬φ). BX11 is about ordering of witnesses, not about preservation.
- BX11 was the inspiration for the defect-directed chain (archived to Boneyard), but it
  does not give F-preservation within a single `fwd_succ` step.

**BX12 (F-Until bridge)**: `F(φ) → (⊤ U φ)`. This converts F-obligations to Until formulas.
If F(φ) ∈ M, then (⊤ U φ) ∈ M by BX12. Now (⊤ U φ) is an Until formula with vacuous guard.
Does (⊤ U φ) propagate through g_content? YES: if G(⊤ U φ) ∈ M, then (⊤ U φ) ∈ g_content(M).

**The key question**: Is G(⊤ U φ) ∈ M when F(φ) ∈ M?

From BX12: F(φ) → (⊤ U φ) is a theorem. So ⊢ G(F(φ) → (⊤ U φ)) by temporal necessitation.
And G(F(φ)) → G(⊤ U φ) follows by temporal K distribution.

But do we have G(F(φ)) ∈ M when F(φ) ∈ M? Again, this requires `F(φ) → G(F(φ))`, not
a BX theorem. So the BX12 bridge does not close the gap.

**BX4/connect_future**: `φ → G(P(φ))`. This says if φ holds now, then at all future times P(φ) holds.
Does NOT help with F-preservation.

**Summary**: No BX axiom allows us to derive G(F(φ)) from F(φ), which is what would be needed
to embed F-obligations into g_content propagation. The obstacle is fundamental.

### 4. The Correct Proof Strategy for `fwd_chain_forward_F` — A New Approach

The two standard approaches (enriched seed, monotonicity contrapositive) both fail. Here is
a rigorous analysis of what MIGHT work.

**Observation**: The statement needed for `restricted_temporally_coherent` is:

```
∀ fam ∈ B.families, ∀ t φ, φ ∈ deferralClosure root →
  F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s
```

For `bx_bfmcs`, each family is `shifted_bx_fmcs N h_N s`, so `fam.mcs t = int_chain N h_N (t - s)`.
The forward part works on `fwd_chain N h_N` for t ≥ s and `bwd_chain N h_N` for t < s.

The forward case needs: F(φ) ∈ fwd_chain(n) → ∃ m > n, φ ∈ fwd_chain(m).

**Key structural insight missed by prior rounds**: The issue is NOT just about `fwd_chain`.
The `deferralClosure root` is FINITE. This finiteness is the key.

The `deferralClosure root` contains finitely many formulas. Call them φ₁, ..., φₖ.
For each φᵢ, either:
(a) F(φᵢ) ∉ fwd_chain(0) (never an obligation starting from M₀ for φᵢ): trivially OK.
(b) F(φᵢ) ∈ fwd_chain(0): then by `fwd_chain_F_not_return`, F(φᵢ) either persists forever
    or drops at some first step k where F(φᵢ) ∉ fwd_chain(k).

In case (b), if F(φᵢ) persists forever, we cannot derive φᵢ ∈ fwd_chain(m) for any m.
This is the fundamental impossibility: a formula F(φ) can persist in ALL chain steps
without φ ever being resolved, because `fwd_succ` with schedule ψ ≠ φ only places ψ in the
seed, not φ, and may introduce G(¬φ) to kill F(φ) arbitrarily late.

Wait — `fwd_chain_F_not_return` says once F(φ) leaves, it never returns. But if F(φ) persists
FOREVER in the chain, does that mean we can never use `schedule_surjective_above` to resolve it?

Let's track what happens when schedule(m) = φ and F(φ) ∈ fwd_chain(m):
- `fwd_succ(fwd_chain(m), φ)` uses the resolving branch (since F(φ) ∈ fwd_chain(m))
- Returns `set_lindenbaum({φ} ∪ g_content(fwd_chain(m)))`
- `fwd_succ_resolves` guarantees φ ∈ fwd_chain(m+1)

So: IF F(φ) ∈ fwd_chain(m) at the step when schedule(m) = φ, THEN φ ∈ fwd_chain(m+1).

The question is: does F(φ) drop BEFORE schedule(m) = φ?

**The correct proof structure (if it works)**:

Assume F(φ) ∈ fwd_chain(n). Use `schedule_surjective_above` to find m ≥ n with schedule(m) = φ.
Now consider: is F(φ) ∈ fwd_chain(m)?

Case 1: F(φ) ∈ fwd_chain(m). Then `fwd_succ_resolves` gives φ ∈ fwd_chain(m+1). Done (s = m+1 > n).

Case 2: F(φ) ∉ fwd_chain(m). By `fwd_chain_F_not_return` contrapositive, since F(φ) ∈ fwd_chain(n)
and F(φ) ∉ fwd_chain(m), and m ≥ n, there must be a first step k where F(φ) drops: n ≤ k ≤ m,
F(φ) ∈ fwd_chain(k-1), F(φ) ∉ fwd_chain(k).

At step k: fwd_chain(k) = fwd_succ(fwd_chain(k-1), schedule(k-1)).
If schedule(k-1) = φ: then F(φ) ∈ fwd_chain(k-1) and `fwd_succ_resolves` gives φ ∈ fwd_chain(k). Done.
If schedule(k-1) ≠ φ: then fwd_succ ran the resolving branch for schedule(k-1), and
  set_lindenbaum extended {schedule(k-1)} ∪ g_content(fwd_chain(k-1)) to an MCS not containing F(φ).
  This means G(¬φ) was added. But φ may or may not be in fwd_chain(k) — there is NO axiom that
  forces φ ∈ fwd_chain(k) when G(¬φ) was just added to kill F(φ). This is the gap.

**Conclusion**: Step 4 of the proof outline fails. Case 2 with schedule(k-1) ≠ φ is genuinely
unprovable with the current chain construction. F(φ) CAN be killed at step k by G(¬φ) entering
via Lindenbaum extension, WITHOUT φ appearing at step k.

### 5. A Genuinely New Approach: Semantic Methods via the Parametric Truth Lemma

Since all chain-based proof strategies for `fwd_chain_forward_F` fail, the only path forward
is to avoid needing it. Looking at the structure of `dd_countermodel` (RootScopedChain.lean
lines 202-228), it calls:
- `bx_bfmcs_restricted_tc` (temporal coherence — the F-resolution sorry)
- `bx_bfmcs_restricted_buc` (backward Until coherence)
- `bx_bfmcs_restricted_fuc` (forward Until coherence)

These are passed to `fully_restricted_parametric_representation_from_neg_membership`.

The key insight for a viable approach: **these three conditions are the HYPOTHESES of the
representation theorem, not the conclusions.** We need to find a DIFFERENT BFMCS that
satisfies all three conditions, or find a different proof of completeness altogether.

**Alternative BFMCS construction — the full BXPoint canonical model**: Instead of the
schedule-based chain, use the full BXPoint space (all MCS over the full formula language,
indexed by some linear order). This is the Goldblatt/GHR approach:
- Worlds: all MCS M over the full BX language
- Temporal order: defined by g_content inclusion
- F-resolution: follows from BX axioms directly (BX1 gives serial future, BX12 gives Until)
- Until coherence: follows from BX5 + BX9 + BX10 applied to the MCS level

The obstacle for this approach is that it requires proving the ENTIRE truth lemma for the
full language, not just the restricted closure. This is the approach documented in the ROADMAP
as the "semantic completeness" fallback. It would work but requires substantial re-engineering.

**The minimal viable repair**: Instead of proving `restricted_tc` for `bx_bfmcs`, observe that:

1. The backward Until/Since coherence (`restricted_buc`) CAN be proved if a step transfer
   property is available. From UntilSinceCoherence.lean, `backward_until_from_step` shows
   this reduces to: `(φ U ψ) ∈ fam.mcs(r+1) ∧ φ ∈ fam.mcs(r) → (φ U ψ) ∈ fam.mcs(r)`.

2. For `int_chain`/`shifted_bx_fmcs`, the step transfer for backward Until requires
   knowing that if (φ U ψ) ∈ chain(n+1) and φ ∈ chain(n), then (φ U ψ) ∈ chain(n).
   This follows from a contrapositive: if (φ U ψ) ∉ chain(n), then ¬(φ U ψ) ∈ chain(n),
   so G(¬(φ U ψ)) ∈ chain(n) (wait — this would need G(¬(φ U ψ)) → ¬(φ U ψ), the temporal T-axiom).
   Again blocked by irreflexive semantics.

3. **BX9 provides current-time truth from Until**: `(φ U ψ) → (φ ∨ ψ)`. So if
   (φ U ψ) ∈ chain(n+1), then (φ ∨ ψ) ∈ chain(n+1). This is at time n+1, not time n.
   And g_content of chain(n+1) going backward gives... h_content. H(φ ∨ ψ) ∈ chain(n+1)?
   Not directly.

4. **BX5 + BX9 for backward Until step**: From `(φ U ψ) ∈ chain(n+1)`:
   - BX5: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)`. So ((φ ∧ (φ U ψ)) U ψ) ∈ chain(n+1).
   - BX9: `((φ ∧ (φ U ψ)) U ψ) → ((φ ∧ (φ U ψ)) ∨ ψ)`. So ((φ ∧ (φ U ψ)) ∨ ψ) ∈ chain(n+1).
   - Now h_content of chain(n+1) ⊆ chain(n). Is (φ U ψ) an H-formula? NO.
   - But if we know `H((φ ∧ (φ U ψ)) ∨ ψ) ∈ chain(n+1)` then (φ ∧ (φ U ψ)) ∨ ψ ∈ chain(n).
   - H(α) ∈ chain(n+1) would follow from G(H(α)) ∈ chain(n). But G(H(α)) ∈ chain(n)?
   - This is the connect_past/connect_future interaction: G(P(α)) ∈ chain(n) if α ∈ chain(n).
   - So BX4: α → G(P(α)). If α = (φ U ψ) is in chain(n), then G(P(φ U ψ)) ∈ chain(n),
     so P(φ U ψ) ∈ chain(n+1) by g_content. Then from P(φ U ψ) ∈ chain(n+1) and the MCS,
     (φ U ψ) ∈ chain(n) by... P elimination? There is no "P(φ) → φ" axiom (that's temporal T
     for past). Dead end again.

**The conclusion for backward Until**: The step transfer `(φ U ψ) ∈ chain(n+1) ∧ φ ∈ chain(n) →
(φ U ψ) ∈ chain(n)` is NOT provable from BX axioms under irreflexive semantics. Backward
Until coherence for the schedule-based chain faces the same irreflexive wall as temporal
coherence.

### 6. Forward Until Coherence Analysis

For `restricted_fuc`, given (φ U ψ) ∈ fam.mcs(t), we need s > t with ψ ∈ fam.mcs(s) and
φ ∈ fam.mcs(r) for all t ≤ r < s.

Step 1: BX10 gives F(ψ) ∈ fam.mcs(t) (from (φ U ψ) → F(ψ)).
Step 2: If we had temporal coherence (F-resolution), we'd get s > t with ψ ∈ fam.mcs(s).
Step 3: We need φ ∈ fam.mcs(r) for all t ≤ r < s.
  - BX5: (φ U ψ) → ((φ ∧ (φ U ψ)) U ψ). So at time t, ((φ ∧ (φ U ψ)) U ψ) holds.
  - BX9: ((φ ∧ (φ U ψ)) U ψ) → (φ ∧ (φ U ψ)) ∨ ψ. So either ψ holds at t (then s = t... but
    our semantics is STRICT, so s > t, and ψ at t doesn't finish it), or (φ ∧ (φ U ψ)) holds at t.
  - So φ ∈ fam.mcs(t) follows from BX9 + BX5 (in the non-resolved case at t).
  - For intermediate r ∈ (t, s): we need (φ U ψ) ∈ fam.mcs(r) to apply BX9. But how do we
    know (φ U ψ) persists from t to r? Again requires g_content propagation of (φ U ψ), which
    requires G(φ U ψ) ∈ chain(t). We do NOT have G(φ U ψ) from (φ U ψ) alone.

Forward Until coherence ALSO blocks on the same fundamental wall: we cannot propagate
(φ U ψ) forward through the chain via g_content without G(φ U ψ) ∈ M.

### 7. The Single Actionable Path: Replacing the Schedule with a Richer Chain

There is one genuine alternative not fully explored: constructing a chain where at each step,
the SEED explicitly includes all currently active Until/Since obligations at their full depth.

Specifically, define a modified `fwd_succ'` that returns
`set_lindenbaum(O(M, ψ) ∪ g_content(M))` where O(M, ψ) is the "obligation set":
```
O(M, ψ) = {ψ} ∪ {F(φᵢ) | φᵢ ∈ deferralClosure(root) ∧ F(φᵢ) ∈ M}
```

But as shown in Finding 2, adding F(φ) to the seed is blocked by the consistency proof.

**The one remaining avenue**: Use a schedule that PAIRS the F-obligation resolution with a
consistency argument via BX5/BX9 directly. Specifically:

When schedule(n) = φ and F(φ) ∈ chain(n), the seed `{φ} ∪ g_content(chain(n))` is consistent.
Now consider also adding `(⊤ U φ)` to the seed, using BX12 (F(φ) → ⊤ U φ):
- G(⊤ U φ) ∉ chain(n) in general (we'd need G(F(φ)) ∈ chain(n)).
- But (⊤ U φ) ∈ chain(n) by BX12 (F(φ) → ⊤ U φ at MCS level).
- Wait: does (⊤ U φ) ∈ g_content(chain(n))? Only if G(⊤ U φ) ∈ chain(n). Not guaranteed.

So the seed cannot be enriched via BX12 either.

---

## Recommended Approach

Given the rigorous analysis above, the three sorry sites (`restricted_tc`, `restricted_buc`,
`restricted_fuc`) are ALL blocked by the same fundamental obstacle: under irreflexive semantics,
there is no mechanism in the BX axiom system to force F-obligations to be resolved within a
finite Lindenbaum-based chain construction. The temporal T-axiom (G(φ) → φ) was the load-bearing
component of all prior completeness proofs, and its removal breaks the chain method.

**The only genuine path forward** is the semantic completeness approach:

**Option 1 — Reflexive semantics restoration**: Add back the temporal T-axiom G(φ) → φ
(making G reflexive). This restores g_content_subset_self, enables F-preservation via
G(F(φ)) from F(φ) ∈ M and G-closure, and makes the schedule-based chain proof work directly.
The cost is changing the semantics to ≤ rather than < for G/H. This is the most principled
fix if the intended semantics allows reflexive G.

**Option 2 — Full GHR-style canonical model**: Build the canonical model using all MCS over
the full language, ordered by g_content. Show BX5 + BX9 + BX10 + BX11 + BX12 give Until
coherence at the MCS level directly. This avoids chain construction entirely and is known to
work for Until/Since temporal logics (Burgess 1984, GHR 1994). The cost is re-engineering
the entire canonical model construction.

**Option 3 — Axiomatic completeness of `sorry` until a design decision**: Clearly document
the structural impossibility and mark as `[BLOCKED]` pending a design decision on whether
to switch to reflexive semantics or re-engineer the canonical model. This is the zero-debt
compliant option when no sorry-free path exists under current assumptions.

For the specific task of closing the three sorries under the CURRENT architecture (irreflexive
semantics + schedule-based chain), there is no sorry-free path. The sorries should be marked
[BLOCKED] with full documentation.

---

## Evidence and Examples

**The irreflexive wall (concrete counterexample)**:
Consider the linear order N = {0, 1, 2, ...} with strict <. Suppose M is an MCS at time 0
with F(p) ∈ M (p will be true at some future time). Build a chain step: choose G(¬p) to be
added (consistent with {ψ} ∪ g_content(M) as long as ψ ≠ ¬p and G(p) ∉ M). Then F(p) leaves
chain(1) and p never appears. This is a valid MCS extension under BX axioms with irreflexive
semantics, because the BX axioms for irreflexive semantics don't force p to ever appear —
only the semantic model forces it (via the frame condition), but the Lindenbaum construction
creates a SYNTACTIC model which may differ from the semantic requirement.

**The seed enrichment failure**:
The formula `G(G(¬ψ)) → G(¬ψ)` is precisely what the temporal T-axiom would give (applied
to G(¬ψ)): G(φ) → φ with φ := G(¬ψ) gives G(G(¬ψ)) → G(¬ψ). This axiom was REMOVED when
switching to irreflexive semantics (it requires the reflexive frame condition s ≤ s). All
attempts to use g_content propagation for F-preservation ultimately need this step.

**The BX12 path's dead end**:
BX12 says F(φ) → ⊤ U φ. In any MCS with F(φ), we get (⊤ U φ). The Until formula (⊤ U φ)
says: there exists s at which φ holds. But this is a SYNTACTIC statement in the MCS — it
does not force the chain construction to PLACE φ at any specific step. The Lindenbaum step
can extend an MCS containing (⊤ U φ) to an MCS containing G(¬φ) if G(¬φ) is consistent
with the seed, which it is when F(φ) is not in the seed.

**The codebase confirms this**: `fwd_chain_F_not_return` (CanonicalModel.lean lines 113-143)
is already proved and shows F-obligations can be killed at any step. The proof constructs
the kill explicitly via temp_4 + g_content propagation.

---

## Confidence Level: HIGH (for the impossibility), LOW (for alternative paths)

The impossibility of closing the three sorries under the current architecture is established
at HIGH confidence. The chain-based approach with irreflexive semantics and BX axioms cannot
satisfy temporal coherence or Until coherence without the temporal T-axiom.

The alternative paths (reflexive semantics switch, GHR-style reconstruction) are evaluated
at LOW-MEDIUM confidence for feasibility within a single task — they require substantial
re-engineering beyond the scope of "close 3 sorries."

**Specific actionable recommendation**: The task should be marked [BLOCKED] with documentation
pointing to the design decision: (a) switch to reflexive G/H semantics (easier fix), or (b)
pursue GHR-style completeness (principled but expensive). Option (a) is more tractable and
aligns with Burgess (1984) who uses reflexive G for his completeness theorem on linear orders.
