# Teammate A Findings — Round 7: Forward F / Backward P Blocker Analysis

## Key Findings

### 1. The Scheduling Chain Construction (CanonicalModel.lean)

The int_chain is built via:
- `fwd_succ M h_mcs ψ`: resolving step if `F(ψ) ∈ M` (seed = `{ψ} ∪ g_content(M)`); non-resolving step otherwise (seed = `g_content(M) ∪ f_carry(M)`)
- `bwd_pred M h_mcs ψ`: symmetric for past
- `fwd_chain`/`bwd_chain` index by `Nat`, unified via `int_chain` over `Int`
- Schedule: `schedule n = Denumerable.ofNat Formula (Nat.unpair n).2`, surjective above any bound

**f_carry mechanism**: In non-resolving steps, `f_carry(M)` (all `F(χ) ∈ M`) is included in the seed. This is already implemented via `fwd_succ_f_carry`. The theorem says: if `F(ψ) ∉ M`, then `f_carry(M) ⊆ fwd_succ M h_mcs ψ`.

**Critical gap confirmed**: At a resolving step for formula `χ ≠ ψ`, the seed is `{χ} ∪ g_content(M)`. The `f_carry(M)` is NOT included. So `F(ψ) ∈ M` can be dropped at the resolving step for `χ`.

### 2. The F-dropping Problem in Detail

Let `F(ψ) ∈ chain(t)`. The schedule visits `ψ` at some `n > t`. But:
- Between `t` and `n`, there are resolving steps for other formulas `χ₁, χ₂, ...`
- At a resolving step for `χᵢ`, the seed is `{χᵢ} ∪ g_content(chain(t))`. F-carry is absent.
- The Lindenbaum extension for this step need NOT include `F(ψ)`.
- So `F(ψ)` can disappear from the chain before ψ gets its scheduled turn.

The f_carry mechanism only carries `F(ψ)` through non-resolving steps. It does NOT carry through resolving steps for other formulas. This is the fundamental obstruction.

### 3. Can Restricted Scope Break the Circularity?

**Claim from the brief**: Restricted forward_F (only for `φ ∈ deferralClosure(root)`) might break the circularity. Analysis:

The circularity is:
- To prove `forward_F`: need `G(¬ψ) ∈ chain(t)` from `¬ψ ∈ chain(s)` for all `s > t`
- To prove `G(¬ψ) ∈ chain(t)`: need backward G reasoning
- Backward G reasoning in the BX system uses `int_chain_backward_H` which needs `H(G(¬ψ)) ∈ chain(t')` for some `t'` — but this doesn't use forward_F

**Wait — the circularity is in FiniteDeferral.lean, not CanonicalModel.lean.** The `temporal_backward_G_with_fwd_F` function takes forward_F as a hypothesis. But in CanonicalModel.lean, the chain already has `int_chain_backward_H` which does NOT require forward_F.

**Re-examining G_neg_kills_until**: This theorem is in FiniteDeferral.lean and works for the `deterministic_chain`. It uses `until_induction` from the BX axiom system. But line 325 shows: `have h_ax := sorry /- until_induction removed in BX -/ ψ Formula.bot)` — **until_induction is not in BX!**

This is a second independent obstacle: even if we could derive `G(¬ψ)`, we cannot use Until Induction to derive the contradiction because BX does not have that axiom.

### 4. The FiniteDeferral Approach Fails for Two Reasons

1. **F-dropping**: `F(ψ)` can be dropped at resolving steps for other formulas before `ψ` gets its scheduled turn. The f_carry mechanism only works for non-resolving steps.

2. **Until Induction missing**: `G_neg_kills_until` in FiniteDeferral.lean contains `sorry /- until_induction removed in BX -/`. This means the `G_neg_kills_until` lemma itself is sorry'd. BX does not have the Until Induction axiom, so the standard "pigeonhole + cycle" argument for discrete temporal logic does not directly apply.

### 5. The Modified Seed Approach

**Proposal**: Include `f_carry(M)` in ALL branches (both resolving and non-resolving):
- Resolving seed for `ψ`: `{ψ} ∪ g_content(M) ∪ f_carry(M)` instead of `{ψ} ∪ g_content(M)`

**Does this preserve consistency?** Yes. `{ψ} ∪ g_content(M) ∪ f_carry(M) ⊆ {ψ} ∪ M` is consistent since `ψ ∈ M` (because `F(ψ) ∈ M` implies `ψ ∨ X(ψ)` by axioms — wait, no. `ψ` might not be in `M`; `F(ψ) ∈ M` means `ψ` holds at SOME future time. So `ψ ∉ M` in general, and the seed `{ψ} ∪ g_content(M)` must be proved consistent — this is `forward_temporal_witness_seed_consistent`. Adding `f_carry(M)` to the resolving seed: is `{ψ} ∪ g_content(M) ∪ f_carry(M)` consistent?

Since `g_content(M) ∪ f_carry(M) ⊆ M` (by `g_content_subset_self` + `f_carry_subset`) and `{ψ} ∪ g_content(M)` is already proved consistent via `forward_temporal_witness_seed_consistent`, adding `f_carry(M) ⊆ M` to a consistent seed: not automatically consistent. Reason: `{ψ} ∪ g_content(M)` is consistent because we derive it from `F(ψ) ∈ M` and the axioms. But `{ψ} ∪ g_content(M) ∪ f_carry(M)` — we need `{ψ}` to be compatible with ALL F-formulas. Since `f_carry(M) ⊆ M` and `g_content(M) ⊆ M`, this is a subset of `{ψ} ∪ M`. If `ψ ∈ M` this is trivially `⊆ M` hence consistent. But `ψ ∉ M` in general...

**Actually**: `{ψ} ∪ M` might be inconsistent! That's exactly the point of the Lindenbaum construction — we need `{ψ}` to be consistent with the seed. The seed `forward_temporal_witness_seed M ψ` is specifically crafted to be consistent because of the `F(ψ)` axiom. Adding `f_carry(M)` formulas (which are `F(χ)` formulas) to this resolving seed would need a separate consistency proof.

**Assessment**: The modified seed approach is plausible but would require re-proving `forward_temporal_witness_seed_consistent` with the extended seed. The key question is: does `F(χ) ∈ M` remain compatible with `ψ` in the extension? Since `{ψ} ∪ g_content(M) ∪ f_carry(M) ⊆ {ψ} ∪ M`, consistency holds IF `{ψ}` is consistent with `M`. But `{ψ}` being consistent with `M` is not guaranteed — otherwise `forward_temporal_witness_seed` wouldn't need special treatment.

**However**, looking at it more carefully: `forward_temporal_witness_seed M ψ = {ψ} ∪ g_content(M)`, and this is consistent because `F(ψ) ∈ M` and the `F(ψ) → X(ψ ∨ F(ψ))` (or similar axiom) gives a consistent successor containing `ψ`. The argument doesn't depend on `f_carry(M)` being absent. So we need: is `{ψ} ∪ g_content(M) ∪ f_carry(M)` consistent?

Since `g_content(M) ∪ f_carry(M) ⊆ M` and the Lindenbaum construction for `{ψ} ∪ g_content(M)` gives a full MCS extension, and that MCS extension contains `ψ` and all of `g_content(M)`. Can we always choose the extension to also include `f_carry(M)`? Not necessarily — the extension is free to exclude some `F(χ)`. We need this explicitly.

**Alternative**: Look at the original consistency proof for `{ψ} ∪ g_content(M)`. It uses `forward_temporal_witness_seed_consistent M h_mcs ψ h_F` where `h_F : F(ψ) ∈ M`. The proof produces an MCS extension. Since `f_carry(M) ⊆ M`, and `M` is consistent, `{ψ} ∪ g_content(M) ∪ f_carry(M) ⊆ {ψ} ∪ M`. Consistency of `{ψ} ∪ M` would give what we need, but `{ψ} ∪ M` being consistent requires that `¬ψ ∉ M`, i.e., `ψ ∈ M` (since MCS is complete). But if `ψ ∈ M`, the resolving step is trivial. When `ψ ∉ M` (and `¬ψ ∈ M`), `{ψ} ∪ M` IS inconsistent. So we cannot simply add `f_carry(M)` to the resolving seed.

**Conclusion**: The modified seed approach (include f_carry in resolving steps) does NOT work in general because the resolving seed `{ψ} ∪ g_content(M)` is an ORACLE-STYLE construction — it is consistent specifically because of the temporal structure, but `{ψ} ∪ M` itself is inconsistent (when `¬ψ ∈ M`). Adding `f_carry(M) ⊆ M` to the resolving seed likely breaks consistency when some `F(χ)` and `ψ` are incompatible via the logical theory.

### 6. Well-Founded Induction on Formula Complexity

The brief asks whether induction on formula complexity within `deferralClosure` can break the circularity.

The circularity is: prove `forward_F(ψ)` requires proving `forward_F` for sub-instances. But `F(ψ)` and `G(¬ψ)` have the same complexity as `ψ` (they are "above" `ψ`). So complexity induction does not immediately help.

However, `deferralClosure(root)` is finite and fixed. If we could show:
- "For each `ψ ∈ deferralClosure(root)`, assuming `forward_F(χ)` for all strictly simpler `χ`, prove `forward_F(ψ)`"

Then well-founded induction would close the proof. But the proof of `forward_F(ψ)` doesn't directly reduce to `forward_F` for simpler formulas — it requires `G(¬ψ)`, which requires the backward G argument, which in the FiniteDeferral infrastructure is left sorry'd due to the missing Until Induction axiom.

**This approach is blocked by the missing `until_induction` in BX**, not just the circularity.

### 7. What IS Proved vs. What Is Sorry'd

In FiniteDeferral.lean (deterministic chain context):
- `F_to_until_in_chain` — proved (sorry-free)
- `until_persists_forward_steps` — proved (sorry-free)
- `pigeonhole_restricted_theories` — proved (sorry-free)
- `G_neg_kills_until` — **SORRY'd** at line 325 (`until_induction removed in BX`)
- `forward_F_via_deferral` — **SORRY'd** (the main theorem)

In CanonicalModel.lean:
- `bx_fmcs_forward_F` (line 497) — **SORRY**
- `bx_fmcs_backward_P` (line 503) — **SORRY**
- `bx_bfmcs_restricted_tc` (lines 603-615) — delegates to above two, so effectively SORRY
- `bx_bfmcs_restricted_buc` (line 621) — **SORRY**
- `bx_bfmcs_restricted_fuc` (line 627) — **SORRY**

### 8. The Until/Since Coherence Sorries (buc/fuc)

These are separate from forward_F:
- `bx_bfmcs_restricted_buc`: Given `ψ φ Until ψ` at some future `r ≥ t`, and `φ` holds throughout `[t, r)`, conclude `φ Until ψ ∈ chain(t)`.
- `bx_bfmcs_restricted_fuc`: Given `φ Until ψ ∈ chain(t)`, find witness where `ψ` holds with `φ` guard.

These require different infrastructure from forward_F. They may be provable via the X-operator semantics and induction on the interval `[t, r]`.

## Recommended Approach

### For forward_F / backward_P

The correct approach for this scheduling chain architecture is **NOT** the FiniteDeferral route (which requires Until Induction, absent from BX). Instead:

**Approach A: Direct scheduling argument with extended non-resolving carry**

The key insight missed so far: the schedule visits every formula infinitely often. The F-dropping problem occurs at resolving steps for OTHER formulas. Can we prove that `F(ψ)` persists to the step where `schedule(n) = ψ` using a SEQUENCE OF CARRIES?

Specifically: define `carry_persists`: if `F(ψ) ∈ chain(t)` and `schedule(k) ≠ ψ` for all `k ∈ [t, t+n)`, then `F(ψ) ∈ chain(t+n)`. This requires showing F-carry survives resolving steps. But this requires `F(ψ)` to be in the resolving seed for χ — which it is NOT by construction.

**This approach is blocked** unless we change the chain construction.

**Approach B: Carry F-formulas explicitly through resolving steps via g_content enhancement**

If we can show that `G(F(ψ)) ∈ chain(t)` whenever `F(ψ) ∈ chain(t)` (using some BX axiom like `F(ψ) → G(F(ψ))` which is NOT generally valid in temporal logic), then `F(ψ)` would survive via g_content. But `F(ψ) → G(F(ψ))` is `F → GF`, equivalent to `¬(F ∧ GG¬)` — this is not a theorem of BX.

**This approach is blocked** by the temporal semantics.

**Approach C: Quasimodel/Mosaic construction**

As noted in FiniteDeferral.lean line 374: "Approach (4), the quasimodel construction, is the standard method in the literature for discrete temporal completeness." This avoids the incremental chain construction. However, it requires ~1000 lines of new infrastructure and is a major architectural change.

**Approach D: Modify the scheduling chain to a "round-robin resolution" chain**

Instead of the dovetailed schedule, use a chain that directly addresses ALL F-formulas at each step. Specifically:
- At step `n`, use the Lindenbaum extension with seed containing `{schedule(n)} ∪ g_content(M) ∪ f_carry(M)`
- Prove this extended resolving seed is consistent

The consistency question: is `{ψ} ∪ g_content(M) ∪ f_carry(M)` consistent when `F(ψ) ∈ M`?

Note: `f_carry(M)` contains `F(χ)` for various `χ`. The seed `{ψ} ∪ g_content(M) ∪ f_carry(M)` is consistent if:
- `{ψ} ∪ g_content(M)` is consistent (given by `forward_temporal_witness_seed_consistent`) AND
- `f_carry(M)` is compatible with the extension

Since `f_carry(M) ⊆ M` and `g_content(M) ⊆ M`, we have `g_content(M) ∪ f_carry(M) ⊆ M`. The issue is whether `ψ` is compatible with `f_carry(M)`.

Key: `F(ψ) ∈ M` means the forward temporal witness seed `{ψ} ∪ g_content(M)` is consistent. Can we extend this consistency to include `f_carry(M)`? We need: there is NO derivation of `⊥` from `{ψ} ∪ g_content(M) ∪ f_carry(M)`. Since `f_carry(M) ⊆ M` and `M` is consistent, and `{ψ} ∪ g_content(M)` is consistent, we need `ψ` to not contradict any `F(χ) ∈ M`. But `ψ` might interact with `F(χ)` via complex logical dependencies.

**However**: `forward_temporal_witness_seed_consistent` proves `{ψ} ∪ g_content(M)` is consistent using: any finite subset of `{ψ} ∪ g_content(M)` is provable iff `¬(ψ ∧ G(φ₁) ∧ ... ∧ G(φₙ))` is derivable from `F(ψ) ∈ M`. Adding `F(χ₁), ..., F(χₖ)` from f_carry: we need `¬(ψ ∧ G(φ₁) ∧ ... ∧ F(χ₁) ∧ ...)` not derivable. Since `F(χ) ∈ M` is consistent with M and so is `ψ` with `g_content(M)`, this is plausible but NOT automatic — it requires a proof.

**Recommended concrete approach**: Modify `fwd_succ` to use the seed `{ψ} ∪ g_content(M) ∪ f_carry(M)` in the resolving case, and prove consistency of this extended seed. The consistency proof would need to show that `{ψ} ∪ g_content(M) ∪ f_carry(M)` has a consistent Lindenbaum extension. This may follow from the fact that the BFMCS/FMCS temporal frame satisfaction guarantees a successor containing `ψ` and all carried F-formulas.

### For backward_until_since_coherent (buc)

This is a SEPARATE blocker. Given a future witness `r` where `ψ` holds and `φ` holds throughout `[t, r)`, we need to conclude `φ Until ψ ∈ chain(t)`. This should follow from the X-operator semantics (the chain has the property that `X(φ)` ↔ the next MCS contains `φ`). The proof would be by backward induction from `r` to `t` using:
1. `ψ ∈ chain(r)` → `φ Until ψ ∈ chain(r)` (by `until_intro_right` or equivalent)
2. `φ ∈ chain(k)` and `φ Until ψ ∈ chain(k+1)` → `φ Until ψ ∈ chain(k)` (by Until introduction)

The key needed lemma: the X-operator corresponds to the chain step. For the scheduling chain: `X(φ) ∈ chain(k) ↔ φ ∈ chain(k+1)`. This requires the chain to satisfy the X-operator property — but the scheduling chain does NOT have the simple X-stepping property that the deterministic chain (Boneyard) has, because the successor of `chain(k)` via `fwd_succ` is NOT uniquely determined by X-operator membership.

This suggests the buc/fuc sorries may be harder than expected.

### For forward_until_since_coherent (fuc)

Given `φ Until ψ ∈ chain(t)`, find the witness `r` with `ψ ∈ chain(r)` and `φ` guards. This reduces to: `φ Until ψ ∈ chain(t)` → `ψ ∈ chain(t)` OR (`φ ∈ chain(t)` AND `φ Until ψ ∈ chain(t+1)`). This is the Until Unfold axiom. Then iterate forward. But we need the iteration to terminate — which again requires forward_F applied to `Until`-type formulas. So fuc reduces to forward_F.

## Evidence / Examples

### Evidence That Restricted Scope Does Not Break the Core Circularity

`bx_bfmcs_restricted_tc` (lines 603-615) simply calls `bx_fmcs_forward_F N h_N (t - s) ψ h_F`. The "restricted" part (the `_h_dc : ψ ∈ deferralClosure root` hypothesis) is DISCARDED (named `_h_dc`). So restricted_tc provides no actual relief — it is formally the same as unrestricted_tc, just with an additional unused hypothesis. The restriction does NOT enable a different proof strategy at the current code level.

### Evidence for the f_carry Gap

Looking at `fwd_succ_f_carry` (lines 108-114): f_carry is only guaranteed in the `dif_neg h_not_F` branch. In the `dif_pos h_F` (resolving) branch, only `{ψ} ∪ g_content(M)` is seeded via `forward_temporal_witness_seed`. The `f_carry` formulas are not in the seed.

### Evidence That Until Induction is Missing from BX

Line 325 of FiniteDeferral.lean: `have h_ax := sorry /- until_induction removed in BX -/ ψ Formula.bot)`. This is a HARD blocker for the `G_neg_kills_until` approach. The BX system uses `F_until_equiv` (F(ψ) ↔ ⊤ U ψ) but not the general Until Induction axiom.

## Confidence Level

**High confidence** in the following assessments:
- The f_carry mechanism does NOT carry F-formulas through resolving steps — this is directly verifiable from the code at lines 76-78 and 108-114.
- The `G_neg_kills_until` lemma in FiniteDeferral.lean is sorry'd due to missing Until Induction in BX — verified at line 325.
- `bx_bfmcs_restricted_tc` provides no relief over unrestricted version — verified by inspection of lines 606-615 showing `_h_dc` is unused.

**Medium confidence**:
- Extended resolving seed approach (Approach D) might work but requires new consistency proof.
- The buc/fuc sorries may be provable via X-operator properties if the chain has the right stepping lemma.

**Low confidence**:
- Any strategy based on FiniteDeferral.lean's pigeonhole infrastructure succeeding without Until Induction.
- Well-founded induction on formula complexity as a path to forward_F.

## Summary Assessment

The primary blocker is twofold:
1. **Structural**: The scheduling chain's resolving steps drop f_carry, making F-formula persistence across resolving steps unprovable with current construction.
2. **Axiomatic**: BX lacks Until Induction, blocking the `G_neg_kills_until` approach in FiniteDeferral.lean.

The most promising single change is **Approach D**: modify `fwd_succ` to include `f_carry(M)` in the resolving seed and prove extended consistency. If consistent, then by induction on the schedule, F(ψ) can be shown to persist to the step where `schedule(n) = ψ`, at which point `ψ ∈ chain(n+1)`. This avoids Until Induction entirely and only requires: (a) new extended consistency theorem, and (b) a carry persistence lemma for resolving steps.
