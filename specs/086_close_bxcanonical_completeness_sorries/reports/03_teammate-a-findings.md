# Teammate A Findings: Primary Mathematical Approach

**Task**: 86 - Close BXCanonical completeness sorry (imp Case B in usf_completeness)
**Focus**: Primary mathematical strategy for closing the remaining sorry
**Date**: 2026-04-08

## Key Findings

### 1. Precise Problem Statement

The sorry is at `CanonicalEmbedding.lean:409`, in `usf_completeness`, Case B of the `imp ψ χ` case. The current proof:

```
Given: valid(ψ.imp χ), untilSinceFree(ψ), untilSinceFree(χ), IH for ψ and χ
Case B: ψ is NOT valid
Proof by contradiction: assume ¬derivable(ψ.imp χ)
  → MCS w with ψ.imp χ ∉ w
  → ψ ∈ w and χ ∉ w (by imp_iff_mcs)
  → Need to contradict valid(ψ.imp χ) by exhibiting a model
     where ψ is true and χ is false at the same point
  → sorry
```

The gap: building a TaskModel + WorldHistory + Omega where both the forward truth lemma (ψ ∈ w → truth_at ψ) AND the backward countermodel (χ ∉ w → ¬truth_at χ) hold simultaneously.

### 2. Root Cause Analysis: Three-Way Tension

The fundamental difficulty is a **three-way tension** between:

**(A) Forward truth lemma for G/H**: Requires the history to visit bx_le-ordered BXPoints. `G(δ) ∈ w` means `δ ∈ v` for ALL `v ≥ w` (bx_le). The history must visit these successors at future times.

**(B) Backward countermodel for G/H**: `G(α) ∉ w` means `∃ v ≥ w, α ∉ v`. The history must visit this specific witness `v` at some future time, and α must be false there.

**(C) Box truth lemma**: Requires `Omega` to be calibrated so that `truth_at(box δ) ↔ box(δ) ∈ w`. This means at time 0, ALL histories in Omega must visit BXPoints modally-equivalent to w. But ShiftClosed Omega forces time-shifted histories into Omega, and their time-0 states are the CHAIN points, which need NOT be modally-equivalent to w.

**Why constant histories fail**: On `constant_history w`, all times map to w. The truth of G(α) and α become identical (time-independence). So truth_at G(α) = truth_at α on constant histories. If α ∈ w but G(α) ∉ w, the backward direction fails: truth_at G(α) = truth_at α = True (forward lemma), but G(α) ∉ w.

**Why simple chain histories fail at box**: A chain σ with σ(0) = w, σ(1) = v ≥ w requires Omega = {time_shift(σ, Δ)} for shift-closedness. But time_shift(σ, 1) has state v at time 0, and v might not be modally-equivalent to w. So the box forward truth lemma fails.

### 3. Critical Axiom Analysis

The interaction axioms are:
- `modal_future`: `□φ → □(Gφ)` — necessary truths are necessarily always true
- `temp_future`: `□φ → G(□φ)` — necessary truths will always be necessary

**Forward preservation**: `temp_future` gives `□φ ∈ w → □φ ∈ v` for all `v ≥ w`. So the modal theory at bx_le-successors EXTENDS the modal theory at w.

**Backward preservation**: `□φ → H(□φ)` is NOT derivable (and NOT semantically valid in general). So bx_le-predecessors need NOT preserve the modal theory.

**Consequence for Omega**: If the chain only goes forward (future direction), all chain points have modal theories EXTENDING w's. But this means the chain points might have STRICTLY MORE box-formulas than w, not the same. So they're not necessarily modally-equivalent.

### 4. Six Alternative Approaches Analyzed

#### Approach A: Flatten/Collapse Transformation — FAILS

Define `collapse(G(ψ)) = collapse(ψ)`, identity on others. Then `truth_at φ ↔ truth_at(collapse φ)` on constant histories. The plan: `valid(ψ→χ) → valid(collapse(ψ)→collapse(χ)) → derivable(collapse(ψ)→collapse(χ))` by fragment_completeness, then lift back.

**Failure point**: Lifting requires `derivable(collapse(χ) → χ)`, which needs `derivable(α → G(α))` when χ contains G(α) in a positive position. This is NOT valid.

The "forward" property `derivable(φ → collapse(φ))` DOES hold (via BX1: G(α)→α + IH + transitivity). But the "backward" property fails for G/H in consequent positions.

#### Approach B: Strong Completeness with Deduction Theorem — FAILS

Prove `∀ Γ, (Γ ⊨ φ) → (Γ ⊢ φ)` by structural induction on φ. The imp case becomes trivial: move antecedent to Γ, apply IH. But the `box` and `G` cases fail when Γ is non-empty:

- `G(ψ)` with Γ non-empty: need `DerivationTree Γ (G(ψ))`. The hypothesis gives `∀ model, Γ-true → G(ψ)-true`, but you can't reduce to `valid ψ` because the Γ-hypotheses constrain the model.
- `box(ψ)` with Γ non-empty: same issue. Box quantifies over different histories, but Γ hypotheses only hold at the current history.

The existing proof handles box/G/H by REDUCTION (valid G(φ) → valid φ → derivable φ → derivable G(φ)), which only works when Γ = [].

#### Approach C: Direct Proof-Theoretic Construction — INSUFFICIENT

With `¬valid ψ`: by soundness contrapositive, ψ is not derivable. With `valid(ψ→χ)` and `¬valid ψ`: can show χ is also not valid (if χ were valid, by IH χ would be derivable, hence in w, contradicting χ ∉ w). But having `¬valid ψ` and `¬valid χ` doesn't help construct a derivation of ψ → χ.

The IH is useless for both ψ and χ since neither is valid.

#### Approach D: Two-Point History — PARTIALLY WORKS

For χ = G(α) with temporal-free α: σ(0) = w, σ(t) = v for t ≥ 1 where v ≥ w and α ∉ v. On canonical_task_frame, `respects_task` is automatic (permissive relation: d ≠ 0 ∨ w = u). The temporal-free backward truth lemma works at v. The forward truth lemma works at w because all chain points are ≥ w.

**Limitation**: Only handles G/H with temporal-free subformulas. Nested G/H requires longer chains.

#### Approach E: Recursive Chain History — WORKS (modulo box)

Recursively build a chain of BXPoints from the structure of χ:
- `G(α) ∉ u`: get witness v ≥ u with α ∉ v, place at next future time, recurse on α at v
- `H(α) ∉ u`: get witness v ≤ u with α ∉ v, place at next past time, recurse on α at v
- `α.imp β` with α ∈ u, β ∉ u: recurse on β at same point u
- atom/bot: base case

Chain properties:
- Non-decreasing in future: w ≤ v₁ ≤ v₂ ≤ ... (all witnesses are bx_le-successors)
- Non-increasing in past: ... ≤ v₋₂ ≤ v₋₁ ≤ w
- Bounded length: at most temporal_depth(χ)
- respects_task is automatic on canonical_task_frame

**Forward truth lemma on chains** (proved by structural induction on γ):
- `G(δ) ∈ w → ∀ s ≥ 0, δ ∈ σ(s)` because σ(s) ≥ w and `bx_G_forward` gives δ ∈ σ(s)
- `H(δ) ∈ w → ∀ s ≤ 0, δ ∈ σ(s)` because σ(s) ≤ w and `bx_H_forward` gives δ ∈ σ(s)
- By IH at each chain point, truth_at corresponds to membership

**Backward countermodel on chains** (proved by structural recursion on χ):
- `G(α) ∉ w`: witness v at time 1 has α ∉ v, by IH truth_at α at (σ,1) = False
- `α.imp β` with β ∉ w: truth_at α = True (forward), truth_at β = False (IH)
- Chain gives ¬truth_at χ at (σ, 0)

**Box failure**: When χ or ψ contains `box(δ)` subformulas, the Omega must satisfy the box truth lemma. With Omega = {time_shifts of σ}, box(δ) at time 0 quantifies over σ(Δ) for all Δ. Since σ(Δ) may not be ~ w, the forward box truth lemma fails.

#### Approach F: Restricted Fragment (box-free USF) — VIABLE PARTIAL RESULT

If we restrict to formulas without box (fragment {atom, bot, imp, G, H}), the chain approach works perfectly with Omega = {time_shift(σ, Δ) | Δ}. The box truth lemma is vacuously satisfied. This gives a partial result for the "purely temporal" fragment without modal operators.

### 5. The Box Interaction Problem

The core open question is how to construct Omega such that:

1. **Contains the chain** σ ∈ Omega
2. **ShiftClosed**: ∀ σ' ∈ Omega, ∀ Δ, time_shift(σ', Δ) ∈ Omega
3. **Box forward**: box(δ) ∈ w → ∀ σ' ∈ Omega, truth_at δ at (σ', 0) [requires σ'(0) ~ w]
4. **Box backward**: ∀ v ~ w, ∃ σ' ∈ Omega with σ'(0) = v [for bx_modal_witness]

Properties (1) and (2) conflict with (3): time_shift(σ, Δ)(0) = σ(Δ), which is a chain point that may not be ~ w.

**Potential resolution using temp_future**: Since `□φ ∈ w → □φ ∈ v` for v ≥ w (by temp_future), the modal theory at successor chain points EXTENDS w's. If we could show that the relevant box-formulas (those appearing in ψ and χ) are preserved, we could build a box-compatible Omega.

**Full resolution**: Would require showing that for the specific formulas in ψ and χ, the chain points' modal theories are compatible. This is a formula-specific argument, not a general one.

### 6. Additional Observation: χ Not Valid Is Derivable

From the contradiction setup: if χ were valid, then by IH, χ would be derivable. A derivable formula is in every MCS (theorem_in_mcs). But χ ∉ w. Contradiction. So χ is not valid.

Similarly: ψ ∈ w but ψ is not valid (Case B assumption).

So we have: `valid(ψ → χ)`, `¬valid ψ`, `¬valid χ`, `ψ ∈ w`, `χ ∉ w`, w is MCS.

## Recommended Approach

### Primary Strategy: Chain History for Box-Free Fragment, Then Lift

**Phase 1: Prove completeness for the box-free USF fragment {atom, bot, imp, G, H}.**

Define `boxFree : Formula → Prop` excluding box. For box-free USF formulas, the chain history approach works completely:

1. Construct chain history from BXPoint witnesses (recursive on formula structure)
2. Use Omega = {time_shift(σ, Δ) | Δ : Int} (automatically shift-closed)
3. Prove forward truth lemma using bx_G_forward/bx_H_forward + chain non-decreasing/non-increasing
4. Prove backward countermodel using recursive witness placement
5. No box truth lemma needed (no box subformulas)

This closes the sorry for the box-free case and is estimated at **50-80 lines of Lean**.

**Phase 2: Handle box via the existing reduction.**

For the full USF fragment with box: the `box` case in usf_completeness is ALREADY handled by reduction (valid(□ψ) → valid(ψ) → derivable(ψ) → derivable(□ψ)). The sorry is only in the `imp` case.

The question is: when `ψ.imp χ` contains box subformulas, can we handle it?

Key insight: box subformulas of ψ and χ interact with the countermodel through the forward/backward truth lemmas. If we can prove a version of the truth lemma that handles box correctly with the chain Omega, we're done.

**Using temp_future**: Since `□φ → G(□φ)` is an axiom, and all chain points are ≥ w (bx_le), we get `□φ ∈ w → □φ ∈ σ(t)` for all t ≥ 0. For the box forward truth lemma: box(δ) ∈ σ(0) = w means δ ∈ v for all v ~ w. At time-shifted histories: σ'(0) = σ(Δ) for time_shift(σ, Δ). We need δ ∈ σ(Δ) or at least truth_at δ at σ(Δ).

If δ ∈ w and σ(Δ) ≥ w: by bx_G_forward (if G(δ) ∈ w, then δ ∈ σ(Δ)). But box(δ) ∈ w → δ ∈ w (by modal_t). Does G(δ) ∈ w follow from box(δ) ∈ w?

From box(δ) ∈ w: by modal_future, box(G(δ)) ∈ w. By modal_t, G(δ) ∈ w. **YES!**

So: `box(δ) ∈ w → G(δ) ∈ w → δ ∈ σ(Δ)` for all Δ ≥ 0.

And for Δ < 0: box(δ) ∈ w → by BX4' and interaction axioms... we need δ ∈ σ(Δ) for past chain points. From box(δ) ∈ w: by modal_future, box(G(δ)) ∈ w, so G(δ) ∈ w. Does box(δ) give H(δ) ∈ w too?

From box(δ) ∈ w: we get δ ∈ w by modal_t. By BX4': δ → H(F(δ)), so H(F(δ)) ∈ w. This gives F(δ) ∈ v for all v ≤ w. F(δ) at v means ∃ s ≥ v's time with δ at s. This is existential, not universal.

**Alternative**: From box(δ) ∈ w, we need to show δ ∈ σ(Δ) for Δ < 0. σ(Δ) ≤ w for Δ < 0. But box(δ) ∈ w → δ ∈ v for v ~ w, and σ(Δ) might not be ~ w.

HOWEVER: `truth_at(box δ)` at (time_shift(σ, Δ), 0) quantifies over ALL σ' ∈ Omega. If Omega only contains time-shifts of σ, then truth_at(box δ) at (time_shift(σ, Δ), 0) = ∀ Δ', truth_at δ at (time_shift(σ, Δ'), 0) = ∀ Δ', truth_at δ at σ(Δ'). This is a statement about truth of δ at ALL chain points, not just modal-equivalents of σ(Δ).

For the BACKWARD box truth lemma: truth_at(box δ) at (σ, 0) = ∀ Δ, truth_at δ at σ(Δ). This is ∀ chain points u, δ is true at u. Does this give box(δ) ∈ w?

box(δ) ∈ w ↔ ∀ v ~ w, δ ∈ v (box_iff_mcs). But truth_at gives δ true at all chain points, which only covers bx_le-related points (above and below w), not all modal-equivalents.

**So the backward box truth lemma also fails with Omega = shifts-of-chain.**

### Pragmatic Recommendation

Given the depth of the box interaction problem, I recommend a **two-step approach**:

**Step 1** (immediate, high confidence): Add a `boxFree` predicate and prove completeness for {atom, bot, imp, G, H}. Modify usf_completeness to handle the box-free sub-case of imp Case B using chain histories. This is a PARTIAL closure of the sorry.

**Step 2** (subsequent): For the full USF fragment with box, either:
- (a) Build the full canonical model with proper Omega (closes both the usf_completeness sorry AND bx_completeness sorry #5), or
- (b) Prove a derivable reduction: `derivable(ψ → χ)` when `ψ`, `χ` contain box can be reduced to derivability of box-free formulas via the K axiom and necessitation.

Option (b) is promising: Given `valid(ψ → χ)` with box subformulas, we might be able to "push" the box out using S5 axioms and reduce to the box-free case. This requires a careful proof-theoretic analysis but avoids the canonical model entirely.

## Evidence/Examples

### Example 1: G case works with chain history

Formula: `valid(p → G(p → q))` (hypothetical). MCS w with p ∈ w, G(p → q) ∉ w. Witness: v ≥ w with (p → q) ∉ v, so p ∈ v, q ∉ v.

Chain: σ(0) = w, σ(t) = v for t ≥ 1. Forward: G(δ) ∈ w → δ ∈ v (since v ≥ w). Backward: truth_at G(p→q) at (σ,0) requires truth_at(p→q) at (σ,1). truth_at p at v = True (p ∈ v). truth_at q at v = False (q ∉ v, temporal-free). So truth_at(p→q) at v = False. Hence ¬truth_at G(p→q) at (σ,0). And truth_at p at (σ,0) = True (p ∈ w). Contradiction with valid(p → G(p→q)).

### Example 2: Box blocks the chain approach

Formula: `valid(□p → G(p))`. MCS w with □p ∈ w, G(p) ∉ w. Wait -- from □p: by modal_future, □G(p) ∈ w, so G(p) ∈ w by modal_t. Contradiction. So this formula's imp Case B can't arise.

More interesting: `valid(□p → (q → G(q)))`. MCS w with □p ∈ w, (q → G(q)) ∉ w, so q ∈ w, G(q) ∉ w. Witness: v ≥ w with q ∉ v. Chain σ(0) = w, σ(t) = v for t ≥ 1. Omega = time-shifts.

Forward: □p ∈ w. truth_at(□p) at (σ, 0) = ∀ Δ, truth_at p at σ(Δ). Need p ∈ σ(Δ) for all Δ. σ(0) = w: p ∈ w? □p ∈ w → p ∈ w (modal_t). σ(Δ) = v for Δ ≥ 1: p ∈ v? From □p ∈ w and G(□p) ∈ w (temp_future), □p ∈ v (since v ≥ w). So p ∈ v (modal_t). σ(Δ) = w for Δ ≤ 0: p ∈ w. **All chain points have p!**

But truth_at(□p) also requires p at ALL σ' ∈ Omega. With Omega = {time_shift(σ, Δ)}: σ'(0) = σ(Δ), and p ∈ σ(Δ) for all Δ (shown above). So truth_at p at (σ', 0) for all σ'. Hence truth_at(□p) = True.

But wait: truth_at(□p) = ∀ σ' ∈ Omega, truth_at p at (σ', 0). truth_at p at (σ', 0) = p ∈ σ'(0). For σ' = time_shift(σ, Δ): σ'(0) = σ(Δ). We showed p ∈ σ(Δ) for all Δ. So truth_at(□p) = True. **It works in this case!**

This suggests that for many common patterns, the chain + shifts Omega actually satisfies the box forward truth lemma, thanks to `modal_future` + `temp_future` propagating box-formulas through the chain.

### Example 3: Box backward failure

truth_at(□p) at (σ, 0) = ∀ Δ, p ∈ σ(Δ). This says p is true at all chain points. But □p ∈ w requires p ∈ v for all v ~ w, not just chain points. So the backward direction can fail if there exists v ~ w not in the chain with p ∉ v.

For the countermodel, we need the FORWARD direction for ψ ∈ w (including box subformulas of ψ) and the BACKWARD direction (contrapositive) for χ ∉ w. If χ doesn't contain box, the backward is fine. If ψ contains box, the forward might work thanks to modal_future + temp_future (as in Example 2).

**Critical observation**: For the FORWARD box truth lemma on chains with Omega = shifts-of-σ:

box(δ) ∈ w → G(δ) ∈ w (by modal_future + modal_t) → δ ∈ σ(Δ) for Δ ≥ 0 (bx_G_forward).

And H(δ) ∈ w (by... is this derivable? box(δ) → H(δ)? From box(δ) and modal_future: box(G(δ)). From modal_t: G(δ). But H(δ) is different.)

Wait: we need δ ∈ σ(Δ) for Δ < 0 too. σ(Δ) ≤ w for Δ < 0. From box(δ) ∈ w: δ ∈ w. And H(δ) ∈ w would give δ ∈ σ(Δ) for Δ < 0. But we don't have H(δ) ∈ w from box(δ) ∈ w in general.

**However**: the chain for Δ < 0 is w itself (σ(Δ) = w for Δ ≤ 0 if no H-witnesses are needed). In this case, δ ∈ w suffices.

If the chain does go backwards (H-witnesses): σ(-1) = u ≤ w with some α ∉ u. Then we need δ ∈ u. From box(δ) ∈ w and u ≤ w: does box(δ) ∈ u? Using temp_future backwards... no, temp_future only gives G(□φ), not H(□φ).

**This is the remaining gap for the box forward truth lemma in the past direction.**

## Confidence Level

**Medium-High** for the box-free fragment (approach E + Omega = shifts-of-chain).

**Medium** for the full USF fragment including box. The forward box truth lemma works in the FUTURE direction (via modal_future + temp_future) but the PAST direction has a gap. If the chain only extends in the future direction (no H-witnesses needed for χ), or if the past chain points are all equal to w, the approach works.

**Specific confidence breakdown**:
- Box-free USF completeness (no box in ψ or χ): **HIGH** (90%)
- Full USF with box only in ψ (not in χ): **MEDIUM-HIGH** (75%) — forward truth lemma for box likely works
- Full USF with box in χ: **MEDIUM** (55%) — backward countermodel for box subformulas of χ requires careful Omega construction
- General approach is sound: **HIGH** (95%) — the chain history idea is mathematically correct, implementation details vary

## Summary

The sorry can be partially closed with a chain-history countermodel construction for the box-free USF fragment. The construction is mathematically clean: chain histories through bx_le-ordered BXPoints, with witnesses placed by structural recursion on the failing formula χ. The forward truth lemma follows from bx_G_forward/bx_H_forward plus chain monotonicity. The backward countermodel follows by construction.

The full USF fragment with box is harder due to the three-way tension between G/H temporal ordering, box modal equivalence, and shift-closedness of Omega. The temp_future axiom provides partial resolution for the future direction. A complete solution likely requires either the full canonical model construction (closing sorry #5 in bx_completeness) or a novel proof-theoretic reduction that eliminates box from the imp case.
