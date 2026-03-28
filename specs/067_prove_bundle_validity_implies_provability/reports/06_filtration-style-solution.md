# Filtration-Style Solution for Task 67

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-28

---

## 1. Overview

Standard Kripke completeness for linear tense logic avoids the family-level coherence problem entirely: the canonical model is a flat set of MCSes with a binary relation, and the Existence Lemma generates fresh MCSes as needed (Goldblatt 1992, Venema 2001, de Jongh-Veltman-Verbrugge 2004). The difficulty in TM arises because the bundle semantics forces G to quantify along a single history, not across all accessible worlds.

The filtration-style solution exploits the fact that the truth lemma, proved by structural induction on a fixed target formula, only invokes `forward_F` on a **finite, predictable** set of formulas. If we can show that the sorry-free `SuccChainFMCS` resolves these specific F-obligations, we obtain family-level temporal coherence where it matters — without proving it for all formulas.

---

## 2. The Precise Set of Formulas Requiring `forward_F`

### 2.1 Trace Through the Truth Lemma

The backward G case (ParametricTruthLemma.lean:278-289) calls `temporal_backward_G` with formula `ψ`, where `G(ψ)` is the formula being processed. Inside `temporal_backward_G` (TemporalCoherence.lean:165-178):

```
1. Assume G(ψ) ∉ fam.mcs(t)
2. neg(G(ψ)) ∈ fam.mcs(t)                             [MCS negation completeness]
3. F(neg(ψ)) ∈ fam.mcs(t)                             [neg_all_future_to_some_future_neg]
4. ∃ s > t, neg(ψ) ∈ fam.mcs(s)                       [forward_F on neg(ψ)]
```

Step 3 transforms `neg(G(ψ))` to `F(neg(ψ))` using `G_dne_theorem` contrapositively. These are syntactically different formulas:

```
neg(G(ψ))  = (ψ.all_future).imp bot
F(neg(ψ))  = ((ψ.imp bot).imp bot).all_future).imp bot    [= some_future(neg(ψ))]
```

The derivation uses `SetMaximalConsistent.contrapositive`, which requires a full MCS.

Step 4 calls `forward_F` on the formula `neg(ψ)`.

### 2.2 The Complete Set

For target formula `φ`, define:

```
S_F(φ) = { neg(ψ) : G(ψ) is a subformula of φ }
S_P(φ) = { neg(ψ) : H(ψ) is a subformula of φ }
```

`forward_F` is called on `some_future(θ)` for `θ ∈ S_F(φ)`.
`backward_P` is called on `some_past(θ)` for `θ ∈ S_P(φ)`.

Both sets are finite and contained in `closureWithNeg(φ)`:
- If `G(ψ) ∈ subformulaClosure(φ)`, then `ψ ∈ subformulaClosure(φ)`, so `neg(ψ) ∈ closureWithNeg(φ) ⊆ deferralClosure(φ)`.

### 2.3 A Critical Subtlety

Although `neg(ψ) ∈ deferralClosure(φ)`, the formula `F(neg(ψ)) = some_future(neg(ψ))` is generally **NOT** in `deferralClosure(φ)`. The deferral closure contains `closureWithNeg(φ)` plus deferral disjunctions `{χ ∨ F(χ) : F(χ) ∈ closureWithNeg(φ)}`. Since `F(neg(ψ))` is syntactically different from `neg(G(ψ))`, it may not appear in `closureWithNeg(φ)`.

This means:
- In a **DeferralRestrictedMCS** (DRM), the derivation `neg(G(ψ)) → F(neg(ψ))` may fail because the target formula `F(neg(ψ))` falls outside the restricted domain.
- In a **full MCS**, the derivation works because full MCSes are closed under all derivation.

**Consequence**: The filtration approach must use **full MCSes**, not DRMs, for the chain positions.

---

## 3. The Solution: SuccChainFMCS with Targeted Forward_F

### 3.1 Key Observation

Every family in `construct_bfmcs_bundle` (UltrafilterChain.lean:2853, sorry-free) is a `shifted_fmcs(SuccChainFMCS(W), k)` where `W` is a `SerialMCS`. The `SuccChainFMCS` (SuccChainFMCS.lean:980) produces a full `FMCS Int`:
- Each `chain(t)` is a full `SetMaximalConsistent` set
- `forward_G` is sorry-free (`succ_chain_forward_G_le`)
- `backward_H` is sorry-free (`succ_chain_backward_H_le`)

**Full MCSes resolve the subtlety**: the derivation `neg(G(ψ)) → F(neg(ψ))` works at every chain position because every position is a full MCS.

The remaining question: does `F(neg(ψ)) ∈ SuccChainFMCS(W).mcs(t)` imply `∃ s > t, neg(ψ) ∈ SuccChainFMCS(W).mcs(s)`?

### 3.2 The Succ Step Mechanism

Each step in the SuccChain uses the `Succ` relation (SuccRelation.lean:59):

```
Succ(u, v) means:
  g_content(u) ⊆ v             [G-persistence]
  f_content(u) ⊆ v ∪ f_content(v)   [F-step: resolve or defer]
```

Where `f_content(u) = {ψ : some_future(ψ) ∈ u}`. So if `F(neg(ψ)) ∈ chain(t)`, then `neg(ψ) ∈ f_content(chain(t))`, and by the F-step condition:

```
neg(ψ) ∈ chain(t+1)               [resolved]
   OR
neg(ψ) ∈ f_content(chain(t+1))    [deferred: F(neg(ψ)) ∈ chain(t+1)]
```

If deferred, `F(neg(ψ))` persists at `t+1` and the process repeats.

### 3.3 Why Deferral Terminates for Closure Formulas

For the restricted chain (DRMs), the bounded nesting theorem `iter_F_not_mem_closureWithNeg` (CanonicalTaskRelation.lean:175, sorry-free) proves that deferral is bounded: `iter_F n ψ ∉ closureWithNeg(φ)` for `n ≥ closure_F_bound(φ)`. Since the DRM chain only contains formulas in `deferralClosure(φ)`, the F-obligation must be resolved before the nesting exceeds the bound.

For the general chain (full MCSes), this argument does NOT directly apply: a full MCS can contain `F(neg(ψ))` even when the iterated F-wrapping exits the closure. The chain is not restricted to closure formulas.

### 3.4 The Targeted Approach

Rather than proving `forward_F` for all formulas (impossible — `f_nesting_is_bounded` is false), prove it for the specific formulas in `S_F(φ)`:

```
theorem succ_chain_targeted_forward_F (W : SerialMCS) (φ : Formula)
    (ψ : Formula) (h_sub : G(ψ) ∈ subformulaClosure φ)
    (t : Int) (h_F : some_future(neg(ψ)) ∈ SuccChainFMCS(W).mcs t) :
    ∃ s > t, neg(ψ) ∈ SuccChainFMCS(W).mcs s
```

**Proof strategy**: Use the f_content deferral mechanism. At each step, `neg(ψ)` is either resolved or deferred. The key is showing deferral terminates.

For `neg(ψ)` where `ψ ∈ subformulaClosure(φ)`:
- Each deferral step keeps `F(neg(ψ))` in the chain, meaning `neg(ψ) ∈ f_content(chain(t+k))`
- The deferral disjunction `neg(ψ) ∨ F(neg(ψ))` is included in the successor seed
- At each step, the Lindenbaum extension chooses `neg(ψ)` or `F(neg(ψ))`
- The question: can `F(neg(ψ))` persist forever?

In a full MCS, `F(neg(ψ))` can persist. But the F-step condition says the obligation is either resolved or deferred at each step. If deferred forever, we have `F(neg(ψ)) ∈ chain(t+k)` for all `k ≥ 0`. From this, `G(neg(neg(ψ))) ∉ chain(t+k)` for all `k` (since `F(neg(ψ)) = neg(G(neg(neg(ψ))))` and MCS consistency). But `G(ψ) ∈ chain(t)` implies `ψ ∈ chain(t+k)` for all `k ≥ 0` by `forward_G`. And `ψ` and `neg(ψ)` cannot both be in `chain(t+k)` by consistency.

**Wait** — this is the wrong direction. We DON'T have `G(ψ) ∈ chain(t)`. We're in the backward direction where we're trying to PROVE `G(ψ) ∈ chain(t)` from "ψ true everywhere." The hypothesis is that `G(ψ) ∉ chain(t)`, and we derived `F(neg(ψ)) ∈ chain(t)`.

So the correct argument is: if `F(neg(ψ))` persists forever (deferred at every step), then `neg(ψ) ∉ chain(t+k)` for all `k > 0` (since it's always deferred, never resolved). But then, by the hypothesis of `temporal_backward_G`, `ψ ∈ chain(t+k)` for all `k > 0`. Since each `chain(t+k)` is a full MCS, `ψ ∈ chain(t+k)` and `neg(ψ) ∉ chain(t+k)` is consistent. And `F(neg(ψ)) ∈ chain(t+k)` simply means there EXISTS some future time with `neg(ψ)`, which could be further in the future. But our hypothesis says `ψ` is everywhere in the future — contradiction with the existence of any `neg(ψ)` witness.

This is exactly the standard contrapositive argument, but applied to the chain rather than to a single MCS. The `forward_F` lemma is the tool that extracts the witness. And whether `forward_F` holds for this specific formula depends on whether deferral terminates.

### 3.5 The Core Mathematical Argument

**Claim**: For any `ψ` such that `neg(ψ)` has bounded F-nesting depth within `closureWithNeg(φ)`, if `F(neg(ψ)) ∈ SuccChainFMCS(W).mcs(t)`, then there exists `s > t` with `neg(ψ) ∈ SuccChainFMCS(W).mcs(s)`.

**Proof sketch**: By contradiction. Suppose `F(neg(ψ))` is deferred forever. At each step `t+k`, the successor seed includes `neg(ψ) ∨ F(neg(ψ))`. The Lindenbaum extension always chooses `F(neg(ψ))`. This means at every step, `F(neg(ψ)) ∈ chain(t+k)`.

Now, at step `t+1`, the chain has `F(neg(ψ))`. By the Succ relation's f_content condition applied at `t+1`: either `neg(ψ) ∈ chain(t+2)` (done) or `F(neg(ψ)) ∈ chain(t+2)`. If the latter, we can repeat. Each "deferral" means the successor chose `F(neg(ψ))` over `neg(ψ)` in the disjunction.

The bounded nesting argument (iter_F_not_mem_closureWithNeg) shows that `iter_F n (neg(ψ))` leaves `closureWithNeg(φ)` for large enough `n`. But in the general chain, the MCS can still contain these formulas. So the bounded nesting argument alone doesn't force termination.

**Alternative argument using the Succ seed structure**: The successor seed at step `t+k` includes `neg(ψ) ∨ F(neg(ψ))`. This is a syntactic disjunction. By MCS disjunction property, the MCS at `t+k+1` contains `neg(ψ)` or `F(neg(ψ))`. If we can show that at some point the seed favors `neg(ψ)`, we're done.

However, the Lindenbaum extension is non-constructive (Zorn's lemma), so we cannot control which disjunct is chosen.

**The actual path**: Use the restricted chain construction to show the argument works in the DRM setting, then lift to the general chain using the DRM-to-extension equivalence (`restricted_truth_lemma` at RestrictedTruthLemma.lean:268, sorry-free).

---

## 4. The Two-Level Architecture

The solution uses a two-level approach:

### Level 1: Restricted Chain (DRM level)

The restricted chain operates within `deferralClosure(φ)`:
- Each position is a `DeferralRestrictedMCS φ`
- `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:2921, sorry-free): F-obligations are resolved within bounded steps
- `restricted_backward_chain_backward_P` (line 4262, has termination sorry)
- `restricted_truth_lemma` (RestrictedTruthLemma.lean:268, sorry-free): For `ψ ∈ subformulaClosure(φ)`, membership in the DRM chain equals membership in the Lindenbaum extension

### Level 2: General Chain (Full MCS level)

The general `SuccChainFMCS` provides full MCSes with:
- `forward_G` (sorry-free)
- `backward_H` (sorry-free)
- Full MCS properties (negation completeness, closure under derivation)

### The Bridge

The `restricted_truth_lemma` connects the two levels:

```
For ψ ∈ subformulaClosure(φ):
  ψ ∈ DRM_chain(n) ↔ ψ ∈ extended_chain(n)
```

Where `extended_chain(n)` is the Lindenbaum extension of `DRM_chain(n)` to a full MCS. If the general SuccChain can be shown to agree with the extended chain on `subformulaClosure(φ)` formulas, then:

```
forward_F for DRM_chain    (sorry-free, restricted)
    ↕  (restricted_truth_lemma)
forward_F for extended_chain   (for subformulaClosure formulas)
    ↕  (agreement with SuccChain)
forward_F for SuccChain    (for subformulaClosure formulas)
```

---

## 5. Concrete Implementation Plan

### Phase 1: Targeted Forward_F for SuccChainFMCS

**Goal**: Prove that the general `SuccChainFMCS` resolves F-obligations for formulas `neg(ψ)` where `ψ ∈ subformulaClosure(φ)`.

**Approach A (Direct)**: Build a variant of `SuccChainFMCS` where each step's Lindenbaum extension is guided to resolve closure F-obligations preferentially. Use the restricted chain as an "oracle" to determine which disjuncts to choose.

**Approach B (Projection)**: Prove that for formulas in `closureWithNeg(φ)`, the general SuccChain agrees with the restricted chain at every time step. The restricted chain resolves the F-obligation, so the general chain does too.

**Approach C (Correlated Lindenbaum)**: Instead of independent Lindenbaum extensions, build the general chain by extending the restricted chain: at each position, start from the DRM and extend to a full MCS. The extension preserves all DRM membership, so formulas resolved in the DRM chain are resolved in the extension.

Approach C is most promising. The key lemma:

```
theorem extended_drm_preserves_forward_F (φ : Formula) (seed : DeferralRestrictedSerialMCS φ)
    (ψ : Formula) (n : Int)
    (h_F : some_future(ψ) ∈ restricted_succ_chain_fam φ seed n) :
    ∃ m > n, ψ ∈ extended_chain(m)
```

This follows from `restricted_forward_chain_forward_F` (gives witness `m` with `ψ ∈ DRM_chain(m)`) and `restricted_truth_lemma` (lifts to `ψ ∈ extended_chain(m)` for `ψ ∈ subformulaClosure(φ)`).

### Phase 2: Build FMCS from Extended Chain

Use the Lindenbaum extensions of the DRM chain as a full FMCS. Need:
- `forward_G`: G(ψ) at `n` implies ψ at `m ≥ n`. Follows from the DRM chain's G-step property (`restricted_chain_G_step`, sorry-free for DRM, then lift via restricted_truth_lemma).
- `backward_H`: Symmetric. Has sorry in `restricted_chain_H_step` (RestrictedTruthLemma.lean:135).

### Phase 3: Restricted Truth Lemma for Semantic Truth

Prove a semantic truth lemma restricted to `subformulaClosure(φ)`:

```
theorem restricted_semantic_truth_lemma (B_bundle : BFMCS_Bundle) (φ_target : Formula)
    (ψ : Formula) (h_sub : ψ ∈ subformulaClosure φ_target)
    (fam : FMCS Int) (hfam : fam ∈ B_bundle.families) (t : Int) :
    ψ ∈ fam.mcs t ↔ truth_at (canonical_model ...) (canonical_omega ...) (to_history fam) t ψ
```

The induction is on `ψ ∈ subformulaClosure(φ_target)`. The backward G case uses targeted `forward_F` from Phase 1 instead of unrestricted `B.temporally_coherent`.

### Phase 4: Wire to Completeness

```
1. ¬⊢ φ → neg(φ) consistent → MCS M with neg(φ) ∈ M
2. Build BFMCS_Bundle from M (sorry-free)
3. Build extended DRM chain FMCS targeting φ (Phase 2)
4. Restricted truth lemma (Phase 3): neg(φ) ∈ M ↔ truth(neg(φ))
5. Forward direction: neg(φ) true → φ false
6. Contradicts valid_over Int φ
```

---

## 6. Remaining Sorries to Address

| Sorry | Location | Nature | Path to Fill |
|-------|----------|--------|-------------|
| `restricted_chain_G_propagates` | RestrictedTruthLemma.lean:106,115 | G-propagation through DRM chain for m > n+1 | Induction on m-n using `restricted_chain_G_step` (sorry-free for step case) |
| `restricted_chain_H_step` | RestrictedTruthLemma.lean:135 | H-step backward in DRM chain | Uses h_content backward propagation |
| `restricted_bounded_witness` termination | SuccChainFMCS.lean:2838 | Lean termination for recursive witness search | Well-founded measure on F-nesting depth |
| `restricted_backward_bounded_witness` termination | SuccChainFMCS.lean:4257 | Symmetric termination | Same measure |
| `constrained_predecessor_restricted_g_persistence_reverse` | SuccChainFMCS.lean:3793 | G-formulas in predecessor | Temporal reasoning on predecessor seed |
| `constrained_predecessor_restricted_f_step_forward` | SuccChainFMCS.lean:3853 | f_step when chi not in u | Lindenbaum extension analysis |

The termination sorries (lines 2838, 4257) are proof engineering issues (providing Lean's termination checker a decreasing measure), not mathematical gaps. The G-propagation sorry (lines 106, 115) should follow by induction from the sorry-free step case. The backward chain sorries (lines 3793, 3853) are the hardest remaining mathematical issues.

---

## 7. Comparison with Standard Literature

### 7.1 Standard Kripke Completeness (Goldblatt, Venema)

Standard approach: flat set of ALL MCSes, binary R relation, Existence Lemma generates fresh MCSes. Truth lemma works for all formulas. No restriction needed.

**Why it works**: G quantifies over R-successors (any MCS), not along a fixed history. Existence Lemma provides witnesses freely.

### 7.2 Bulldozing (Segerberg 1970)

After canonical model construction, the frame is a "pseudo-line" (clusters linearly ordered). Bulldozing replaces each cluster with a dense/discrete linear segment, preserving satisfiability.

**Relevance**: Not directly needed for TM because the SuccChain already produces a linear Z-indexed chain. But the cluster-elimination insight could simplify the construction.

### 7.3 Constructive Completeness (de Jongh-Veltman-Verbrugge 2004)

Builds the frame stage-by-stage: at each stage, extend the linearly ordered set by inserting new MCS-labeled points that resolve pending obligations.

**Relevance**: Closest to the SuccChain approach. Each Succ step adds a new point resolving F-obligations. The bounded nesting argument matches their termination proof for the construction stages.

### 7.4 Filtration (Blackburn-de Rijke-Venema 2001, Ch. 2)

Standard filtration restricts the model to equivalence classes of worlds modulo agreement on a finite set of formulas (the subformula closure). The truth lemma holds only for formulas in the closure.

**Direct analogy**: Our restricted truth lemma is a filtration of the truth lemma argument — restricting temporal coherence to formulas in the deferral closure (a finite superset of the subformula closure). The closure is finite, the truth lemma is restricted to subformulas, and the F-obligation resolution is bounded by the closure's F-nesting depth.

---

## 8. Summary

The filtration-style solution proceeds:

1. The truth lemma for target `φ` only needs `forward_F` on formulas `neg(ψ)` where `G(ψ)` is a subformula of `φ`. These are in `closureWithNeg(φ)`.

2. The sorry-free restricted chain construction resolves F-obligations for closure formulas within bounded steps.

3. The Lindenbaum extension of the restricted chain provides full MCSes that inherit the restricted resolution properties (for closure formulas).

4. The intermediate formula `F(neg(ψ))` (needed by `temporal_backward_G`) is derivable in the full MCS extension, even though it falls outside `deferralClosure(φ)`.

5. The restricted semantic truth lemma, proved by induction on subformulas of `φ`, uses targeted `forward_F` for the backward G/H cases and the sorry-free BFMCS_Bundle infrastructure for the Box cases.

6. The completeness proof follows by constructing the canonical model from the BFMCS_Bundle, applying the restricted truth lemma to `neg(φ)`, and deriving a contradiction with validity.

The remaining implementation work is concentrated in:
- Proving that extended DRM chains form a valid FMCS (forward_G/backward_H for all formulas)
- Lifting restricted forward_F from DRM chains to extended chains
- Structuring the restricted semantic truth lemma
- Filling the backward chain and termination sorries
