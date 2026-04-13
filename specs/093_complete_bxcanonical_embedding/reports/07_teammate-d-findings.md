# Teammate D (Horizons) — Round 7 Findings

## Key Findings

### The Exact Sorry Landscape (6 sorries in CanonicalModel.lean)

After reading the code directly, there are exactly 6 sorries in the active path:

1. **`bx_fmcs_forward_F`** (line 497): `F(ψ) ∈ chain(t) → ∃ s > t, ψ ∈ chain(s)`
2. **`bx_fmcs_backward_P`** (line 503): `P(ψ) ∈ chain(t) → ∃ s < t, ψ ∈ chain(s)`
3. **`bx_bfmcs_buc`** (line 586): `backward_until_since_coherent` (full)
4. **`bx_bfmcs_fuc`** (line 591): `forward_until_since_coherent` (full)
5. **`bx_bfmcs_restricted_buc`** (line 621): `restricted_backward_until_since_coherent`
6. **`bx_bfmcs_restricted_fuc`** (line 627): `restricted_forward_until_since_coherent`

The active path through `bx_countermodel` uses ONLY sorries 1, 2, 5, 6 (the restricted versions). Sorries 3 and 4 are dead code.

### The f_carry Mechanism Already Exists

The code in `fwd_succ` already includes an `f_carry` enrichment in non-resolving steps:
```
· exact (set_lindenbaum (g_content M ∪ f_carry M) ...)
```

Where `f_carry M = {F(χ) | F(χ) ∈ M}`. This means F-formulas persist through steps that aren't resolving them — they're carried forward. This is the key innovation already in the code. The **gap** is that the proof of `bx_fmcs_forward_F` (sorry 1) doesn't yet exploit this carry mechanism.

### Why f_carry Doesn't Directly Solve forward_F

The f_carry mechanism ensures `F(ψ) ∈ chain(t)` propagates to `F(ψ) ∈ chain(t+1)` when step t+1 isn't resolving ψ. The schedule `schedule n = Denumerable.ofNat Formula (Nat.unpair n).2` is surjective with `schedule_surjective_above`: for any ψ and k, ∃ n ≥ k with schedule n = ψ.

The intended proof of `bx_fmcs_forward_F` would be:
1. `F(ψ) ∈ chain(t)` means `F(ψ) ∈ fwd_chain M₀ h₀ t.toNat` (for t ≥ 0)
2. F-formulas propagate by f_carry until the step that resolves ψ
3. By `schedule_surjective_above`, there exists n ≥ t.toNat with `schedule n = ψ`
4. At that step: `F(ψ) ∈ chain(n)` → `ψ ∈ chain(n+1)` (via `fwd_succ_resolves`)
5. So `ψ ∈ chain(n+1)` with n+1 > t

**The mathematical argument is correct and complete.** The gap is filling in the f_carry propagation chain formally: we need `F(ψ) ∈ chain(t)` → `F(ψ) ∈ chain(n)` for the n where `schedule n = ψ`.

### The f_carry Propagation Lemma Is the Real Gap

What's needed (but not yet proved) is:
```
∀ m n, m ≤ n → F(ψ) ∈ chain(m) → F(ψ) ∈ chain(n) ∨ ∃ k ∈ [m, n), ψ ∈ chain(k+1)
```

This requires:
- Either F(ψ) persists (via f_carry at each non-resolving step)
- Or ψ was resolved at some intermediate step k

This is a "persistence or resolution" invariant. The key lemma needed:
```lean
theorem f_carry_persists_or_resolved
    (M₀ : Set Formula) (h₀ : SetMaximalConsistent M₀) (ψ : Formula)
    (m n : Nat) (h_mn : m ≤ n)
    (h_F : Formula.some_future ψ ∈ (fwd_chain M₀ h₀ m).val) :
    Formula.some_future ψ ∈ (fwd_chain M₀ h₀ n).val ∨
    ∃ k : Nat, m ≤ k ∧ k < n ∧ ψ ∈ (fwd_chain M₀ h₀ (k+1)).val
```

This propagation lemma, combined with `schedule_surjective_above`, would close `bx_fmcs_forward_F`.

### What backward_until_since_coherent Needs

Sorry 5 (`bx_bfmcs_restricted_buc`): the goal is:
```
(φ U ψ) ∈ fam.mcs (r+1) → φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r
```

This is the "backward step" that `backward_until_from_step` needs. The f_carry/p_carry mechanism doesn't help here because Until is not an F/P formula — it can't be carried by f_carry.

The **only known way** to prove this is via some form of:
1. Axiom `until_intro` or its BX analog (not in BX!)
2. A chain-link property that encodes `(φ U ψ) ∈ chain(n+1)` in terms of chain(n)
3. BX5 `self_accum_until` + BX6 `absorb_until` as a proxy

### Novel Approach: Direct Proof of restricted_backward_until via MCS Properties

The backward Until step needs: given `(φ U ψ) ∈ M'` (successor MCS) and `φ ∈ M`, prove `(φ U ψ) ∈ M`.

Under BX reflexive semantics with `fwd_succ`:
- M' = `fwd_succ M hM ψ_sched`
- M' contains `g_content(M)` always
- `(φ U ψ) ∈ M'` means either ψ ∈ M' (BX9 elim) or φ ∈ M' (BX9 elim) and recursion

Key insight from BX axiom BX9 (`(φ U ψ) → (φ ∨ ψ)`): if `(φ U ψ) ∈ M'`, then `φ ∈ M'` or `ψ ∈ M'`. And `M' ⊇ g_content(M)`, so `G(φ U ψ) ∈ M` would give `(φ U ψ) ∈ M'`.

But we can't prove `G(φ U ψ) ∈ M` from `(φ U ψ) ∈ M'` alone.

**The backward_until step is genuinely hard** without a chain-link that directly mirrors `(φ U ψ) ∈ chain(n+1) → (φ U ψ) ∈ chain(n)` or `φ ∈ chain(n)`.

### Novel Approach: Forward Until via BX12 + Forward_F Chain

For `restricted_forward_until_since_coherent` (sorry 6): given `(φ U ψ) ∈ fam.mcs t`, produce witness.

By BX10 (`(φ U ψ) → F(ψ)`): `F(ψ) ∈ fam.mcs t`. Then by `forward_F` (sorry 1): `∃ s > t, ψ ∈ fam.mcs s`.

**But we also need the guard**: `∀ r ∈ [t, s), φ ∈ fam.mcs r`.

From BX9: `(φ U ψ) → (φ ∨ ψ)`, so at t: φ ∈ M or ψ ∈ M. If ψ ∈ M, witness is t itself (reflexive case). Otherwise φ ∈ M. At subsequent steps via g_content: `G(φ U ψ) ∈ M` would give `(φ U ψ)` everywhere, but that's too strong.

The guard condition requires that φ holds at every intermediate step, which requires knowing that the chain steps don't drop φ — not directly available from g_content alone.

**Key insight**: For the *restricted* forward until, φ and ψ are in `subformulaClosure(root)` (finite). If we could ensure the scheduling chain resolves ψ at the first step where ψ is consistent, and preserves φ until then, that would give the guard. But this requires much stronger chain construction guarantees.

### Novel Approach 1: Augmented Resolving Seed (Most Promising for forward_F)

**The f_carry mechanism is the right idea, and the proof strategy exists.** The specific approach:

For `bx_fmcs_forward_F`: Use a well-founded induction on the distance to the resolving step. The existence of the resolving step follows from `schedule_surjective_above`. The f_carry propagation ensures F(ψ) persists until that step.

Proof sketch for `bx_fmcs_forward_F`:
```
1. Let t ≥ 0 (positive direction; negative is symmetric via backward)
2. F(ψ) ∈ fwd_chain M₀ h₀ t.toNat
3. By schedule_surjective_above: ∃ n ≥ t.toNat, schedule n = ψ
4. CLAIM: F(ψ) ∈ fwd_chain M₀ h₀ n (proved by induction on n - t.toNat)
   - Base: n = t.toNat, trivial
   - Step: if F(ψ) ∈ chain(k) and schedule k ≠ ψ, then f_carry preserves F(ψ) to chain(k+1)
     (via fwd_succ_f_carry: h_not_F : F(ψ) ∉ domain... wait, h_not_F is about the scheduled formula)
```

**PROBLEM**: `fwd_succ_f_carry` says: if `Formula.some_future ψ ∉ M` (i.e., we're NOT resolving ψ specifically), then `f_carry M ⊆ fwd_succ M h_mcs ψ`. So `F(ψ') ∈ M` for any `ψ'` would be carried — including `F(ψ)` if `schedule k ≠ ψ`.

Wait — the condition `h_not_F : Formula.some_future ψ ∉ M` in `fwd_succ_f_carry` is about the **scheduled** formula ψ (the argument to fwd_succ), not about F(ψ) being in M. The step says: if `F(schedule(k)) ∉ chain(k)`, then ALL f_carry elements (including `F(someOtherFormula)`) persist.

**Revised understanding**: `fwd_succ M hM ψ_sched`:
- If `F(ψ_sched) ∈ M`: resolving step, ψ_sched gets added. F(ψ_sched) may or may not persist.
- If `F(ψ_sched) ∉ M`: non-resolving step, all F-formulas in M persist via f_carry.

So in the induction: `F(ψ) ∈ chain(k)`. At step k+1:
- If `schedule(k) = ψ` AND `F(ψ) ∈ chain(k)`: resolving step! `ψ ∈ chain(k+1)`. Done.
- If `schedule(k) = ψ` AND `F(ψ) ∉ chain(k)`: Can't happen (we assumed F(ψ) ∈ chain(k)).
- If `schedule(k) ≠ ψ` AND `F(schedule(k)) ∉ chain(k)`: non-resolving, f_carry preserves F(ψ).
- If `schedule(k) ≠ ψ` AND `F(schedule(k)) ∈ chain(k)`: resolving for schedule(k), NOT ψ. Does F(ψ) persist?

**In the last case**: the resolving step for `schedule(k)` uses seed `{schedule(k)} ∪ g_content(chain(k))`. F(ψ) is NOT directly in this seed (neither in g_content nor in {schedule(k)}). So the Lindenbaum extension might NOT include F(ψ) in the successor!

**This is the fundamental gap.** The f_carry mechanism only helps non-resolving steps. During a resolving step for some OTHER formula, F(ψ) might be dropped.

### Critical Negative Result: f_carry Does Not Fully Solve forward_F

The current construction has a genuine gap: when resolving `F(χ)` for some `χ ≠ ψ`, the seed is `{χ} ∪ g_content(M)`, and `F(ψ) ∈ M` is in `f_carry(M) \ g_content(M)`, which is NOT included in the seed. So `F(ψ)` might not persist through resolving steps for other formulas.

### Recommended Approach: Doubly-Enriched Seed

**The path of least resistance**: Enrich the resolving seed to include f_carry as well:

New resolving seed: `{ψ} ∪ g_content(M) ∪ f_carry(M)`

This is still consistent (same argument as `enriched_seed_consistent`: all elements ⊆ M). And it would preserve all F-formulas through ALL steps (both resolving and non-resolving).

The result would be a strengthening of `fwd_succ_g_content`:
- When resolving: `g_content(M) ∪ f_carry(M) ⊆ fwd_succ M h_mcs ψ`
- When not resolving: `g_content(M) ∪ f_carry(M) ⊆ fwd_succ M h_mcs ψ` (same)

And `fwd_succ_f_carry` would become universal:
- ALWAYS: `f_carry(M) ⊆ fwd_succ M h_mcs ψ`

This would make the f_carry propagation hold even through resolving steps, enabling the clean proof of `bx_fmcs_forward_F`.

**Consistency of doubly-enriched resolving seed** `{ψ} ∪ g_content(M) ∪ f_carry(M)`:
This follows from `{ψ} ∪ g_content(M) ∪ f_carry(M) ⊆ {ψ} ∪ M ⊆ M` (since `F(ψ) ∈ M` implies this seed is within `M ∪ {ψ}`, and the original `forward_temporal_witness_seed_consistent` already handles consistency of `{ψ} ∪ g_content(M)` under the hypothesis `F(ψ) ∈ M`). Actually this exact same consistency proof works since `f_carry(M) ⊆ M`.

**The modified `fwd_succ`**:
```lean
noncomputable def fwd_succ (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula) :
    Set Formula := by
  by_cases h_F : Formula.some_future ψ ∈ M
  · exact (set_lindenbaum ({ψ} ∪ g_content M ∪ f_carry M)  -- ADD f_carry here
      (enriched_resolving_seed_consistent M h_mcs ψ h_F)).choose
  · exact (set_lindenbaum (g_content M ∪ f_carry M)
      (enriched_seed_consistent h_mcs)).choose
```

This is a minor change to the resolving case. The non-resolving case is already correct.

### For backward_until_since_coherent: A Separate Problem

The backward Until step (`(φ U ψ) ∈ chain(n+1) ∧ φ ∈ chain(n) → (φ U ψ) ∈ chain(n)`) is a fundamentally different problem. No chain enrichment obviously solves this.

However, looking at the BX axiom system:
- BX5: `(φ U ψ) → ((φ ∧ (φ U ψ)) U ψ)` — self-accumulation
- BX9: `(φ U ψ) → (φ ∨ ψ)` — current-time elimination
- BX12: `F(ψ) → (⊤ U ψ)` — bridge to Until

**Key observation**: If we use `forward_F` (once proved) plus BX12, then `F(ψ) ∈ fam.mcs t` gives `(⊤ U ψ) ∈ fam.mcs t`. And by BX8, `ψ → (φ U ψ)` at each step. So if we KNOW ψ will be resolved at step s, and we know φ holds at all intermediate steps...

But this is circular with forward Until coherence (which we also need to prove).

**Alternative for backward_until**: Use `or_until_in_mcs` from SuccRelation.lean (if it exists):
The idea: `(φ ∨ (φ U ψ)) ∈ M` → `φ U ψ ∈ M` using some BX axiom. Or: if `(φ U ψ) ∈ M'` (successor) and the successor was built from g_content(M), then `G(φ U ψ) ∈ M` would give `(φ U ψ) ∈ M'. We'd need `(φ U ψ) ∈ g_content^{-1}` of the seed.

**Pivotal observation**: The current `backward_until_from_step` framework in `UntilSinceCoherence.lean` abstracts over the step hypothesis and builds backward induction from it. All that's needed is one lemma:
```lean
∀ r : Int, (φ U ψ) ∈ fam.mcs (r + 1) → φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r
```

This is a chain-structural property. For the scheduling chain with enriched seed, it still doesn't follow automatically.

**One viable approach**: Include `(φ U ψ)` in the non-resolving seed for EVERY Until formula in `subformulaClosure(root)`. Since this is finite, the seed remains finite and consistent. This is the "formula-aware chain" idea.

### Novel Approach 2: Formula-Aware Restricted Chain

For `restricted_backward_until_since_coherent root`: Instead of proving it for the general scheduling chain, build a **different** chain that specifically targets the Until/Since formulas in `subformulaClosure(root)`.

The restricted coherence only needs to hold for `(φ U ψ) ∈ subformulaClosure(root)` — a finite set. Build a chain that, at every step, includes ALL Until/Since formulas from the current MCS that are in `subformulaClosure(root)` in its seed.

This means the seed for step n includes:
- `g_content(chain(n))` always
- `f_carry(chain(n))` always
- For each `(φ U ψ) ∈ subformulaClosure(root)`: if `(φ U ψ) ∈ chain(n)`, include it in seed

The key step: if `(φ U ψ) ∈ chain(n)`, then by BX9 `φ ∈ chain(n)` or `ψ ∈ chain(n)`. If φ ∈ chain(n), then `G(φ U ψ)` follows from... no, this doesn't directly work.

**Actually simpler**: If `(φ U ψ) ∈ chain(n)` is in the seed for chain(n+1), and `g_content(chain(n)) ⊆ chain(n+1)` means `G(φ U ψ) ∈ chain(n) → (φ U ψ) ∈ chain(n+1)` — but we don't have G(φ U ψ) generally.

The backward step property is: `(φ U ψ) ∈ chain(n+1) ∧ φ ∈ chain(n) → (φ U ψ) ∈ chain(n)`. This is needed to pull backward. We have the forward direction (G propagation), not the backward.

### Novel Approach 3: Until Carry (Direct Resolution)

Add an `until_carry` mechanism similar to `f_carry`: for each `(φ U ψ) ∈ subformulaClosure(root)`, carry `(φ U ψ)` forward unless ψ is realized.

The key: `(φ U ψ)` in MCS M and `φ ∈ M` should give `(φ U ψ)` in the successor by:
1. `(φ U ψ) ∈ M` and by BX9: `φ ∈ M` or `ψ ∈ M`.
2. If `ψ ∈ M`: BX8 gives `(φ U ψ)` trivially.
3. If only `φ ∈ M`: need something more.

Actually — add `(φ U ψ)` to the SEED (similar to how we add ψ to the seed when F(ψ) ∈ M). The seed `{(φ U ψ)} ∪ g_content(M)` is consistent when `(φ U ψ) ∈ M` (the formula is in M itself). This gives a "resolving-for-Until" step: resolve pending Until formulas.

With scheduling extended to target Until formulas, and including them in seeds when present: the backward step would hold because the Until formula is explicitly in the seed.

But then we need to check that this doesn't conflict with the semantics.

### The Wiring: How backward_until Connects to forward_F

Looking at `restricted_parametric_shifted_truth_lemma` for the `untl` case (lines 235-264):
```
obtain ⟨h_fwd_U, _⟩ := h_fuc fam hfam  -- restricted_forward_until_since_coherent
obtain ⟨h_bwd_U, _⟩ := h_buc fam hfam  -- restricted_backward_until_since_coherent
```

These are SEPARATE properties. Forward Until needs the witness with guard. Backward Until needs step transfer.

Checking: `bx_countermodel` calls `fully_restricted_parametric_representation_from_neg_membership` with:
- `bx_bfmcs_restricted_tc M h_mcs φ` — calls sorry 1 (forward_F) and sorry 2 (backward_P)
- `bx_bfmcs_restricted_buc M h_mcs φ` — sorry 5 (backward until)
- `bx_bfmcs_restricted_fuc M h_mcs φ` — sorry 6 (forward until)

So ALL FOUR sorries (1, 2, 5, 6) need to be closed.

## Recommended Approach

**Priority order (least to most resistance)**:

### Step 1: Close forward_F and backward_P (sorries 1 & 2) — HIGHEST CONFIDENCE

**Action**: Modify the resolving case in `fwd_succ` to use `{ψ} ∪ g_content(M) ∪ f_carry(M)` instead of `forward_temporal_witness_seed M ψ = {ψ} ∪ g_content(M)`.

Need to prove: `{ψ} ∪ g_content(M) ∪ f_carry(M)` is consistent when `F(ψ) ∈ M`.

Proof: `{ψ} ∪ g_content(M) ∪ f_carry(M) ⊆ {ψ} ∪ M`. If `F(ψ) ∈ M`, this is consistent by `forward_temporal_witness_seed_consistent` (the existing proof handles `{ψ} ∪ g_content(M)` and the argument only uses `f_carry(M) ⊆ M`).

Then prove:
```lean
theorem f_carry_preserved_through_all_steps
    (M₀ : Set Formula) (h₀) (ψ ψ_target : Formula) (m n : Nat) (h_mn : m ≤ n)
    (h_F : Formula.some_future ψ_target ∈ (fwd_chain M₀ h₀ m).val) :
    Formula.some_future ψ_target ∈ (fwd_chain M₀ h₀ n).val ∨
    ∃ k, m ≤ k ∧ k < n ∧ ψ_target ∈ (fwd_chain M₀ h₀ (k+1)).val
```

By induction on n - m, using the enriched seed at each step.

Then `bx_fmcs_forward_F` follows via `schedule_surjective_above`.

**Estimated lines: ~50-70 lines.** Medium difficulty but no circular dependencies.

### Step 2: Close restricted_backward_until_since_coherent (sorry 5)

**Most viable approach**: Use `backward_until_from_step` from `UntilSinceCoherence.lean`, which only requires proving the single-step property:
```lean
(φ U ψ) ∈ fam.mcs (r+1) → φ ∈ fam.mcs r → (φ U ψ) ∈ fam.mcs r
```

For the scheduling chain, this requires: given `(φ U ψ) ∈ chain(r+1)` and `φ ∈ chain(r)`, prove `(φ U ψ) ∈ chain(r)`.

Strategy: Add a `u_carry` mechanism — for all `(φ U ψ) ∈ subformulaClosure(root)`, carry them forward in the seed if `φ U ψ ∈ current_chain`. The seed becomes:
```
seed = g_content(M) ∪ f_carry(M) ∪ {(φ U ψ) ∈ M | (φ U ψ) ∈ subformulaClosure(root)}
```

This is consistent (all elements ⊆ M). With this enriched seed, if `(φ U ψ) ∈ chain(n)` at non-resolving step, it persists to chain(n+1). For resolving step: also add it to the resolving seed.

The backward step property then follows for formulas in `subformulaClosure(root)`.

**However**: This is a significant refactor of the chain construction and would affect the existing sorry structure. The `bx_bfmcs_restricted_buc` sorry already has the `_h_sub` hypothesis available, so it knows `(φ U ψ) ∈ subformulaClosure(root)` — we can exploit this.

**Estimated lines: ~80-100 lines including chain refactor.**

### Step 3: Close restricted_forward_until_since_coherent (sorry 6)

**Given forward_F (step 1 above)**: For `(φ U ψ) ∈ fam.mcs t`:
1. BX10: `F(ψ) ∈ fam.mcs t`
2. `forward_F`: `∃ s > t, ψ ∈ fam.mcs s` (closed in step 1)
3. Need: `∀ r ∈ [t, s), φ ∈ fam.mcs r`

This requires knowing that φ persists from t to s. This is the hardest part. The scheduling chain doesn't guarantee φ at intermediate steps.

**One approach**: Take the MINIMAL such s (smallest step where ψ is resolved). Then argue that at all steps before the minimal s, `(φ U ψ)` is still in the chain (by the u_carry mechanism from step 2). Then BX9: `(φ U ψ) → (φ ∨ ψ)`. If ψ is not resolved at intermediate step r (by minimality), then φ ∈ chain(r).

This argument is tight but works if we have the u_carry mechanism.

**Alternative weaker approach**: The `_h_sub` hypothesis in sorry 6 says `(φ U ψ) ∈ subformulaClosure(root)`. Use this to identify the specific formula type. Actually this doesn't add new information for the proof.

**Estimated lines: ~60-80 lines assuming u_carry mechanism and forward_F.** This is medium difficulty once the earlier steps are done.

## Evidence and Examples

### Chain Structure (from code)

```lean
-- fwd_chain builds: M₀, fwd_succ(M₀, schedule(0)), fwd_succ(fwd_succ(M₀,...), schedule(1)), ...
-- schedule is surjective above any bound (schedule_surjective_above)
-- f_carry(M) = {F(χ) ∈ M} propagates through non-resolving steps (fwd_succ_f_carry)
-- MISSING: f_carry propagates through resolving steps for OTHER formulas
```

### The Key Consistency Lemma (new, needed for step 1)

```lean
theorem enriched_resolving_seed_consistent {M : Set Formula}
    (h_mcs : SetMaximalConsistent M) (ψ : Formula)
    (h_F : Formula.some_future ψ ∈ M) :
    SetConsistent ({ψ} ∪ g_content M ∪ f_carry M) := by
  -- Same as forward_temporal_witness_seed_consistent but with f_carry included
  -- f_carry M ⊆ M, so {ψ} ∪ g_content M ∪ f_carry M ⊆ {ψ} ∪ M
  -- The existing proof already handles this since f_carry ⊆ M
  ...
```

### What bx_countermodel Actually Calls

```lean
theorem bx_countermodel uses:
  - bx_bfmcs_restricted_tc M h_mcs φ  → needs bx_fmcs_forward_F (sorry 1) + bx_fmcs_backward_P (sorry 2)
  - bx_bfmcs_restricted_buc M h_mcs φ → sorry 5 directly
  - bx_bfmcs_restricted_fuc M h_mcs φ → sorry 6 directly
```

The dependency chain: `bx_countermodel → bx_bfmcs_restricted_{tc,buc,fuc} → bx_fmcs_{forward_F,backward_P}`.

## Confidence Level

| Approach | Confidence | Lines | Dependencies |
|----------|-----------|-------|-------------|
| Enrich resolving seed + f_carry persistence for forward_F | **High** | ~70 | None (self-contained) |
| backward_P mirror of forward_F | **High** | ~40 | Same pattern |
| restricted_backward_until via u_carry | **Medium** | ~100 | Chain refactor |
| restricted_forward_until via minimality arg | **Medium** | ~80 | Needs forward_F + u_carry |

**Overall confidence in the doubly-enriched seed approach closing sorries 1 & 2: HIGH** (the math works cleanly, the code structure supports it, and the change is minimal — only the resolving seed definition changes).

**Overall confidence in closing sorries 5 & 6 (Until coherence): MEDIUM** — the u_carry mechanism requires understanding the chain construction more deeply, and the minimality argument for forward Until requires careful formalization.

**Path of least resistance**: Close sorries 1 & 2 first (they're independent), then 5 & 6 using the new chain properties.
