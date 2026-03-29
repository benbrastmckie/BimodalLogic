# Research Report: Task #67 — Root Cause Analysis of F_top Blocker

**Task**: 67 — prove_bundle_validity_implies_provability
**Date**: 2026-03-29
**Angle**: Root Cause Analysis of Last Blocker (F_top not in deferralClosure)
**Session**: lean-research-agent

---

## Key Findings

### 1. The Blocker Is Genuine and Well-Understood

The blocker documented in plan 04_bypass-z-chain-plan.md is real: `F_top = F(neg bot)` is NOT in `deferralClosure(phi)` for general phi. This is not a proof gap or missing lemma — it is mathematically true.

The proof in SubformulaClosure.lean:919 (`some_future_in_deferralClosure_is_in_closureWithNeg`) establishes that any `F(chi)` in `deferralClosure(phi)` must be in `closureWithNeg(phi)`. Since `closureWithNeg(phi)` only contains subformulas of phi and their negations (plus duals), `F(neg bot)` is only in `closureWithNeg(phi)` if `F(neg bot)` is a subformula of phi. For phi = `box p`, there are no future operators in phi, so `deferralClosure(box p)` is `{box p, neg(box p), p, neg p}` with no deferral disjunctions.

### 2. The DeferralRestrictedSerialMCS Structure Is Too Restrictive

`DeferralRestrictedSerialMCS` (SuccChainFMCS.lean:2272) requires:
- `is_drm : DeferralRestrictedMCS phi world` — the world is an MCS within deferralClosure(phi)
- `has_F_top : F_top ∈ world` — F_top must be in the world
- `has_P_top : P_top ∈ world` — P_top must be in the world

For `DeferralRestrictedMCS phi`, the membership is governed by `deferralClosure phi`. The theorem `theorem_in_drm` (RestrictedMCS.lean:1322) allows inserting theorems, but ONLY when the theorem formula is itself in `deferralClosure phi`. Since F_top is not in `deferralClosure(phi)` for general phi, the condition `has_F_top` can never be satisfied structurally.

### 3. Why F_top Is Needed: Seriality in the Chain Construction

F_top is required for the restricted forward chain for a structural reason: `constrained_successor_restricted` (SuccChainFMCS.lean:1996) takes `h_F_top : F(neg bot) ∈ u` as an argument. It is used to:
- Drive the f-step: the seed includes deferral disjunctions for F-formulas in u, and `(neg bot) ∨ F(neg bot)` ends up in the seed
- Ensure the successor is non-trivially serial (avoids degeneracy)

The proof in `F_top_in_restricted_successor` (SuccChainFMCS.lean:2300) makes this circular dependency explicit: F_top ∈ u is required to build the successor, and to prove F_top ∈ successor, one needs F_top ∈ deferralClosure(phi) so that the DeferralRestrictedMCS maximality applies.

### 4. Two Structurally Different Resolution Paths Exist

**Path A: Extend deferralClosure to always include seriality formulas.**

Define `serialDeferralClosure(phi)` = `deferralClosure(phi) ∪ {F_top, P_top, neg bot, bot, neg F_top, neg P_top}`. This is:
- Finite (only 6 extra formulas)
- Preserves the key properties (F/P-nesting bounded, since F_top has nesting depth 1)
- Requires updating `DeferralRestrictedMCS` and all downstream infrastructure

Cost: Significant refactoring. All lemmas about `deferralClosure` would need to be re-examined.

**Path B: Bypass DeferralRestrictedSerialMCS entirely — use full MCS with restricted truth lemma.**

Key observation: `neg_consistent_gives_mcs_without_phi` (RestrictedTruthLemma.lean:412) already exists and is sorry-free. It produces a full MCS M containing neg(phi). The restricted chain is only needed for the bidirectional truth lemma.

Alternative: Use the existing `construct_bfmcs_bundle` (UltrafilterChain.lean:2853) which is sorry-free for modal coherence, plus a modified truth lemma that avoids `h_tc` for the formula phi itself.

**Path C: Prove the truth lemma using only the forward direction of G/H, which does NOT require same-family F-witnesses.**

The G forward direction (G(psi) ∈ mcs → truth(psi) at all s >= t) is provable without h_tc: it uses `forward_G` (g_content ⊆ next mcs). The blockage is only in the BACKWARD direction (truth(psi) at all s >= t → G(psi) ∈ mcs). The backward G case requires finding a counterexample when G(psi) ∉ mcs.

For the completeness proof, we only need the FORWARD direction of the truth lemma for neg(phi). But since neg(phi) = phi.imp bot, the forward imp case requires the BACKWARD IH for phi. This ultimately requires the backward G direction IF phi contains G.

However: for the specific case where phi is the formula being proven, the backward G direction is needed for G-subformulas of phi. These G-subformulas ARE in `subformulaClosure(phi)` and their inner formulas ARE in `deferralClosure(phi)`. But the temporal witnesses (from `forward_F`) might not be in `deferralClosure(phi)`.

### 5. The `theorem_in_drm` Conditional Requirement Is the Core Issue

`theorem_in_drm` (RestrictedMCS.lean:1322) states:
```
⊢ ψ and ψ ∈ deferralClosure phi → ψ ∈ M (for DeferralRestrictedMCS phi M)
```

F_top is a theorem (F_top_theorem at SuccChainFMCS.lean:120), but `F_top ∈ deferralClosure phi` fails for general phi. The conditional is necessary because DeferralRestrictedMCS only has maximality within deferralClosure — it is NOT a full MCS.

This is the correct behavior: DeferralRestrictedMCS is designed as a RESTRICTED structure. The issue is that the serial chain construction was designed assuming the seed already contains F_top as a given, not that it needs to be forced in from outside.

---

## Root Cause Analysis

**Root Cause**: The `DeferralRestrictedSerialMCS` structure was designed for seeds that ALREADY contain F_top and P_top (e.g., when starting from a full MCS obtained via the general Lindenbaum construction). The restricted Lindenbaum lemma was then expected to extend `{neg(phi)}` to a DeferralRestrictedMCS that is then extended to include F_top. But DeferralRestrictedMCS maximality only covers formulas in deferralClosure(phi), and F_top is not in deferralClosure(phi) for general phi.

**Why this blocker is fundamental**: The restricted chain construction provides sorry-free temporal witnesses BECAUSE it restricts formulas to deferralClosure(phi), which has bounded F/P nesting depth. Including F_top/P_top in deferralClosure would require extending the closure, which would then need to re-establish all the depth-bounding theorems for the larger set.

**Symmetry observation**: The general MCS approach (full Lindenbaum) does contain F_top because F_top is a theorem and full MCS has ALL theorems. The restricted approach only has theorems that are IN deferralClosure. This creates an unavoidable mismatch.

---

## Recommended Approach

**The mathematically most correct and least invasive solution is Path B: use a full MCS as the seed and restrict the truth lemma to subformulaClosure(phi).**

Concretely:

1. Start from `{neg(phi)}` consistent.
2. Use the general `set_lindenbaum` to extend to a full MCS M containing neg(phi). (Already done in `neg_consistent_gives_mcs_without_phi` — RestrictedTruthLemma.lean:412.)
3. This full MCS automatically contains F_top and P_top (theorems of TM logic).
4. Use `MCS_to_SerialMCS` (SuccChainFMCS.lean:153) to coerce M to a SerialMCS.
5. Build a standard `SuccChainFMCS` from this SerialMCS (not the restricted version).
6. The standard SuccChainFMCS has family-level temporal coherence via `SuccChainTemporalCoherent`.
7. Apply `parametric_canonical_truth_lemma` with the SuccChainFMCS as the BFMCS.

The gap: `SuccChainTemporalCoherent` for the forward_F direction requires proving that for any F(psi) in the chain at position t, psi appears in the chain at some future position. This is the `succ_chain_forward_F` theorem — which was marked as sorry-free in the restricted version but had the `f_nesting_is_bounded` sorry in the general version.

**Key insight from reading the code**: The restricted version is sorry-free for `forward_F` because F-nesting is bounded within deferralClosure(phi). The general version fails because an arbitrary MCS can contain F(F(F(...(p)...))) for unbounded nesting.

**However**, there is a key insight: the truth lemma for neg(phi) only needs to work for formulas IN subformulaClosure(phi). The backward G/H cases only need F-witnesses for psi where G(psi) or H(psi) is a subformula of phi. These psi are also subformulas of phi, and F(psi) and P(psi) are either subformulas of phi or not.

If we start from a full MCS M containing neg(phi) and build a `SuccChainFMCS` from it, the forward_F sorry is fundamental for the general MCS (F-nesting could be infinite). But we only need forward_F for psi such that F(psi) ∈ closureWithNeg(phi). The restricted chain already handles this!

**The cleanest resolution: Split the construction.**

- Use a full MCS as the seed (to get F_top and P_top membership).
- But restrict the chain construction to only track deferral-relevant formulas.
- The `RestrictedForwardChainElement` can take a full MCS seed (since full MCS is also a DeferralRestrictedMCS — check if this coercion exists).

**Checking coercion**: A full MCS M is a DeferralRestrictedMCS phi M if and only if all elements of M are in deferralClosure(phi). But a full MCS contains ALL formulas up to max nesting depth — it contains formulas outside deferralClosure(phi). Therefore a full MCS is NOT directly a DeferralRestrictedMCS phi in general.

This rules out the direct coercion. The fundamental obstruction is that DeferralRestrictedMCS requires `DeferralRestricted phi S` (all members of S are in deferralClosure phi), which a full MCS violates.

**The correct structural solution:**

Define a new concept: `SerialMCS_to_DeferralRestrictedSerialMCS (phi : Formula) (M : SerialMCS) : DeferralRestrictedSerialMCS phi` by:
1. Take M ∩ deferralClosure(phi) as the base set
2. This intersection is DeferralRestricted phi by construction
3. It may not be DeferralRestrictedMCS (not maximal within deferralClosure)
4. Apply deferral_restricted_lindenbaum to extend it to DeferralRestrictedMCS within deferralClosure(phi)
5. The extension M' satisfies: M' ⊇ M ∩ deferralClosure(phi)
6. Since F_top ∈ M (M is a full SerialMCS), and F_top ∈ deferralClosure(phi) would be required...

This circles back to the same problem: F_top ∈ deferralClosure(phi) is required.

**The fundamental architectural fix:**

The only clean solution is to extend `deferralClosure` to include a fixed set of "universal formulas" that are always included regardless of phi. This is the standard approach in textbook completeness proofs: the closure is defined to include certain "background" formulas needed for the construction.

Specifically:

```lean
def extendedDeferralClosure (phi : Formula) : Finset Formula :=
  deferralClosure phi ∪ {F_top, P_top, Formula.neg Formula.bot,
                          Formula.neg F_top, Formula.neg P_top}
```

This:
- Is still finite
- Contains F_top and P_top by construction
- Still has bounded F/P nesting depth (F_top has nesting depth 1)
- Allows all downstream theorems about `deferralClosure` to be adapted

The downstream changes required:
1. Update `DeferralRestrictedMCS` to use `extendedDeferralClosure`
2. Update `DeferralRestrictedSerialMCS` to drop the separate `has_F_top`/`has_P_top` fields (now automatic)
3. Verify that `some_future_in_deferralClosure_is_in_closureWithNeg` analog still works (it would not — F_top would be an exception case)
4. Update all 30+ lemmas about deferralClosure

This is significant engineering work but is the mathematically principled approach.

---

## Evidence/Examples

**Concrete counterexample showing the blocker**:

For phi = `p` (atom), `closureWithNeg(p) = {p, neg p}`. The `deferralClosure(p) = {p, neg p}` with no deferral disjunctions (no F or P formulas in the closure). F_top = `F(neg bot)` is clearly not in this set.

**The blocking lemma** (SubformulaClosure.lean:919): The proof uses a depth argument. F-formulas in deferralClosure come from three sources: closureWithNeg (direct), deferralDisjunctionSet (but these have f_nesting_depth = 0 as they are disjunctions, not raw F-formulas), and backwardDeferralSet (no F-formulas here). The depth argument shows that any F-formula in deferralClosure must come from closureWithNeg.

**The cross-chain sorries**: There are also sorries in `restricted_backward_to_combined_F_witness` and related cross-chain lemmas (SuccChainFMCS.lean:4512, 4516). These are separate from the F_top blocker and affect positions other than t=0. At t=0 (which is what the completeness proof needs), only the forward chain is used, so these cross-chain sorries may not be on the critical path.

**Existing infrastructure that IS sorry-free**:
- `restricted_forward_chain_forward_F` (line 2887): sorry-free
- `restricted_backward_chain_backward_P` (line 4238): sorry-free
- `build_restricted_tc_family` (line 4642): sorry-free (assuming the cross-chain sorries don't affect it)
- `neg_consistent_gives_mcs_without_phi` (RestrictedTruthLemma.lean:412): sorry-free
- `restricted_truth_lemma` (RestrictedTruthLemma.lean:293): the core statement exists but the proof may need work

---

## Alternative: "Augmented Closure" Approach (Minimal Change)

Rather than redefining deferralClosure, a targeted fix could work by augmenting the Lindenbaum extension step:

Given `{neg(phi)}` consistent:
1. Form seed = `{neg(phi)} ∪ {F_top, P_top}`
2. Show this augmented seed is still consistent:
   - neg(phi) and F_top are both theorems or atomic formulas — no direct contradiction
   - Actually neg(phi) might derive from phi if phi contains negations...
   - More carefully: the set `{neg(phi), F_top, P_top}` is consistent because F_top and P_top are theorems. Adding theorems to any consistent set preserves consistency.
3. Show this augmented seed is DeferralRestricted phi:
   - neg(phi) ∈ deferralClosure(phi) (yes)
   - F_top ∈ deferralClosure(phi)? (NO — this is the blocker)

So even the augmented seed approach fails at the DeferralRestricted check.

**Key insight**: `DeferralRestricted phi S` requires ALL elements of S to be in `deferralClosure phi`. Adding F_top to the seed immediately violates this when F_top ∉ deferralClosure phi.

**The only way to avoid extending deferralClosure** is to not require the DRM structure for the seed and use the full Lindenbaum extension directly, accepting the F-nesting boundedness sorry for the general case.

---

## Confidence Level

**HIGH confidence** in the following:
- The F_top ∉ deferralClosure(phi) fact for general phi is definitively established (mathematical fact, not a proof gap)
- `DeferralRestrictedSerialMCS` requires F_top in the world, and this can only be satisfied if F_top ∈ deferralClosure(phi) (due to how DRM maximality works)
- The "extend deferralClosure to include seriality formulas" is the most architecturally principled fix
- The cross-chain sorries (positions other than t=0) are a separate concern

**MEDIUM confidence** in:
- The claim that the cross-chain sorries don't affect t=0 evaluation (needs verification in the build_restricted_tc_family proof)
- Whether adapting the extended closure approach requires re-proving all deferralClosure lemmas or only the key ones

**LOW confidence** in:
- Whether there exists a clever workaround that avoids extending deferralClosure while still using the DRM infrastructure
- The exact scope of downstream changes needed for the extended closure approach

---

## Summary for Next Steps

The root cause is architectural: `DeferralRestrictedMCS` enforces set membership restriction to `deferralClosure(phi)`, but seriality formulas (F_top, P_top) are typically NOT subformulas of the formula being proven. The standard textbook approach handles this by including "background axioms" in the closure from the start.

The mathematically correct solution is to extend `deferralClosure` to always include seriality formulas. This requires updating the definition and re-examining all ~30 downstream lemmas. A targeted approach could update only the key lemmas needed for the completeness proof chain.

An alternative shortcut: abandon the DeferralRestrictedMCS approach for the seed and use the general Lindenbaum construction to get a full SerialMCS, then use the existing `SuccChainFMCS` infrastructure — accepting that `succ_chain_forward_F` has a sorry for the general case. But the general F-nesting boundedness is mathematically false for arbitrary MCS, so this just reintroduces the original blocker.

**Recommended immediate action**: Extend `deferralClosure` with a small fixed set of seriality formulas, update `DeferralRestrictedMCS`, and update the key downstream lemmas (`some_future_in_deferralClosure_is_in_closureWithNeg` exception case, `deferral_restricted_lindenbaum` unchanged, `F_top_in_restricted_successor` to use the new membership).
