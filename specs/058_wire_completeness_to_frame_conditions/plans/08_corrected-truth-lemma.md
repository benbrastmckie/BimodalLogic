# Implementation Plan: Task #58 - Corrected Truth Lemma Analysis (v8)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 16 hours
- **Dependencies**: None (all building blocks are sorry-free)
- **Research Inputs**: reports/17_team-research.md, plans/07_bidirectional-truth-lemma.md
- **Artifacts**: plans/08_corrected-truth-lemma.md (this file)
- **Type**: lean4
- **Lean Intent**: true

## ERRATA: Correcting Prior Mistakes

### Mistake 1 (Report 17): "Forward-only truth lemma suffices"

**FALSE**. The forward and backward directions of the truth lemma are mutually dependent
in the structural induction. The `imp` backward case uses `IH.mp` (forward direction for
the antecedent subformula). A sorry in any backward case makes the entire induction unsound.

See: `ParametricRepresentation.lean:193,212` — completeness uses `.mpr` (backward direction).

### Mistake 2 (Plan v7): "Cross-family F transfer"

**FALSE**. The plan v7 proposed that F(φ) quantifies across families in Omega, so a
"cross-family F transfer" theorem was needed. This misunderstands the semantics.

**Actual semantics** (Truth.lean:118-125):
- `truth_at(G(φ))` at `(τ, t)` = `∀ s ≥ t, truth_at(τ, s, φ)` — SAME history τ
- `truth_at(F(φ))` at `(τ, t)` = `∃ s ≥ t, truth_at(τ, s, φ)` — SAME history τ
- ONLY `truth_at(□φ)` quantifies over different histories σ ∈ Omega

F and G do NOT quantify across families. They vary time along a SINGLE history. The
bundle-level coherence (`bundle_forward_F`) is about what's IN the MCS, not about the
semantic `truth_at` definition.

### The Precise Blocker

The truth lemma induction has 6 cases (the 6 Formula constructors). The **only** blocked
case is:

**`all_future` backward**: `truth_at(Gψ) at (τ, t) → Gψ ∈ fam.mcs t`

Proof attempt:
1. `truth_at(Gψ)` = `∀ s ≥ t, truth_at(τ, s, ψ)` — same history τ
2. By IH backward: `∀ s ≥ t, ψ ∈ fam.mcs s` — SAME family (because τ = history(fam))
3. Need: `Gψ ∈ fam.mcs t`
4. By contraposition (`temporal_backward_G`, TemporalCoherence.lean:165-178):
   - Assume `Gψ ∉ fam.mcs t`
   - Then `F(¬ψ) ∈ fam.mcs t` (MCS maximality + `neg_all_future_to_some_future_neg`)
   - **Need**: `∃ s > t, ¬ψ ∈ fam.mcs s` — this IS `fam.forward_F`
   - Get contradiction with step 2
5. **`fam.forward_F` is sub-case (b) of the original problem**

The `all_past` backward case is symmetric (needs `fam.backward_P`).

All other backward cases (atom, bot, imp, box) work without temporal coherence.

## The Fundamental Problem

The truth lemma backward for G requires:

```
(∀ s ≥ t, ψ ∈ fam.mcs s) → Gψ ∈ fam.mcs t
```

The only known proof uses contraposition through `forward_F`. And `forward_F` for the
constructed families (SuccChainFMCS) cannot be proven sorry-free due to sub-case (b):
when `F(φ) ∈ fam.mcs(t)` with `G(¬φ) ∈ M0`, the witness must be in the same family
at some `s > t`, but the chain construction doesn't guarantee this.

**This is not a Lean engineering problem — it is a mathematical obstruction.**

## Overview

This plan takes the mathematical obstruction seriously and explores two approaches:

**Approach A (Primary, 10h)**: Prove `temporal_backward_G` without `forward_F` by finding an
alternative proof that `(∀ s > t, ψ ∈ fam.mcs s) → Gψ ∈ fam.mcs t` without contraposition
through F. If such a proof exists, the truth lemma and completeness follow immediately.

**Approach B (Fallback, 6h)**: If Approach A fails, restructure the completeness proof to
avoid the full bidirectional truth lemma. Investigate whether the specific usage in
`ParametricRepresentation.lean` can be replaced by a weaker statement.

## Approach A: Direct Proof of Temporal Backward G

### The Question

Is there a proof of `(∀ s > t, ψ ∈ fam.mcs s) → Gψ ∈ fam.mcs t` that does NOT
use contraposition through `forward_F`?

### Potential Strategies

**Strategy A1: Lindenbaum/compactness argument**

If `Gψ ∉ fam.mcs t`, then `{¬Gψ} ∪ fam.mcs t` is consistent (since ¬Gψ ∈ fam.mcs t).
But `¬Gψ = F(¬ψ)`. So `fam.mcs t` contains `F(¬ψ)`. The question is: can we derive a
contradiction from `F(¬ψ) ∈ fam.mcs t` and `∀ s > t, ψ ∈ fam.mcs s` without producing
a witness s?

This seems to require `forward_F` inevitably, since the inconsistency comes from the
witness existing, not from any syntactic property.

**Strategy A2: Use G-persistence (FMCS.forward_G) + MCS properties**

`fam.forward_G` gives: `Gψ ∈ fam.mcs t → ψ ∈ fam.mcs s` for `s ≥ t`.
This is the forward direction only. The backward direction is what we're trying to prove.

**Strategy A3: Direct from chain construction properties**

The SuccChainFMCS families have specific structural properties. Perhaps the chain
construction already guarantees: if `ψ ∈ fam.mcs s` for all `s > t`, then the chain
construction forces `Gψ` into `fam.mcs t`.

For SuccChainFMCS: `fam.mcs(n+1)` is a Lindenbaum extension of a seed containing
`G_theory(fam.mcs n)`. So `Gψ ∈ fam.mcs n → ψ ∈ seed(n+1) → ψ ∈ fam.mcs(n+1)`.
But we need the reverse: `ψ ∈ fam.mcs(n+1)` for all `n > t` → `Gψ ∈ fam.mcs t`.

The seed at step t contains `G_theory(fam.mcs(t-1))`. So `Gψ ∈ fam.mcs(t-1) →
Gψ ∈ seed(t)`. But the Lindenbaum extension is non-constructive and might not include
`Gψ` even if `ψ` is at all future times.

**Strategy A4: Exploit the reflexive semantics**

Under reflexive semantics, `Gψ` means `∀ s ≥ t, ψ at s` (including `t` itself).
So the hypothesis gives `ψ ∈ fam.mcs t` as well. Combined with the `temp_4` axiom
(`Gψ → GGψ`), we get transitivity. But this still doesn't give us `Gψ` from `ψ at all
future times` — that's the induction principle for G, which requires `forward_F`.

**Assessment**: Strategy A1-A4 all appear to reduce to needing `forward_F`. The
fundamental issue is that MCS membership is determined by logical consistency, not by
semantic truth at future times. Without a witness for `F(¬ψ)` (i.e., a time `s > t`
where `¬ψ` holds), we cannot derive a contradiction.

**Verdict**: Approach A likely fails. But Phase 2 will verify this rigorously.

## Approach B: Restructure Completeness Without Full Truth Lemma

### Key Observation

The completeness proof uses `parametric_shifted_truth_lemma` in three places
(ParametricRepresentation.lean):
1. Line 193: `.mpr` in `neg_in_mcs_implies_false_at_model`
2. Line 212: `.mpr` in `parametric_algebraic_representation_relative`
3. Line 297: `.mp` in soundness direction

**What `.mpr` actually does**: It converts `truth_at φ` back to `φ ∈ fam.mcs t`.
This is used to get a contradiction: if both `φ` and `¬φ` are in the MCS, that
contradicts MCS consistency.

**Alternative**: Instead of proving `truth_at φ → φ ∈ fam.mcs t` (full backward),
prove a weaker statement that's sufficient for the contradiction:

```lean
theorem truth_lemma_neg_contradiction (B : BFMCS_Bundle)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (φ : Formula) :
    φ ∈ fam.mcs t → ¬truth_at M Omega (parametric_to_history fam) t φ.neg
```

This is: `φ ∈ MCS → ¬truth_at(¬φ)`. It uses the forward direction only:
- `φ ∈ fam.mcs t` → `truth_at φ` (forward)
- `truth_at(¬φ)` = `truth_at(φ → ⊥)` = `truth_at φ → False`
- Contradiction

**But wait**: This IS just the forward direction applied to φ, composed with the
semantics of negation. The question is whether this suffices for completeness.

Looking at `neg_in_mcs_implies_false_at_model`:
```lean
-- By shifted truth lemma (backward): truth_at ... φ implies φ ∈ fam.mcs t
have h_phi_in := (parametric_shifted_truth_lemma B h_tc φ fam hfam t).mpr h_phi_true
-- But φ.neg ∈ fam.mcs t, contradiction with MCS consistency
exact set_consistent_not_both (fam.is_mcs t).1 φ h_phi_in h_neg_in
```

This uses `.mpr` to get `φ ∈ fam.mcs t` from `truth_at φ`, then contradicts with
`φ.neg ∈ fam.mcs t`.

**Alternative proof**: Instead of getting `φ ∈ MCS` from `truth_at φ`, we can get
`truth_at φ` from `φ.neg ∉ MCS` (using `φ.neg ∈ MCS → truth_at(φ.neg) → ¬truth_at(φ)`)...
no, this is circular.

**Another alternative**: Use the forward direction on `φ.neg`:
- `φ.neg ∈ fam.mcs t` → `truth_at(φ.neg)` (forward)
- `truth_at(φ.neg)` = `truth_at(φ) → False` = `¬truth_at(φ)`

So from `φ.neg ∈ fam.mcs t`, we get `¬truth_at(φ)`. This gives a **countermodel**:
a model where `φ` is false. This contradicts `valid φ`.

**THIS MIGHT WORK** — the forward direction maps `φ.neg ∈ MCS` to `¬truth_at(φ)`,
giving a countermodel directly. No backward direction needed!

The question is: does the forward direction of the truth lemma require the backward
direction at any point in its induction? If the induction only uses IH forward, then
a forward-only lemma is self-contained.

### Forward-Only Self-Containment Check

The forward direction `φ ∈ fam.mcs t → truth_at(τ, t, φ)` by cases:

| Case | Forward Proof | Uses IH Backward? |
|------|---------------|-------------------|
| atom | Direct from valuation definition | No |
| bot | `bot ∉ MCS` by consistency, vacuously true | No |
| imp | `(ψ → χ) ∈ MCS` and `truth_at ψ` → need `ψ ∈ MCS` → need IH backward for ψ | **YES** |
| box | `□ψ ∈ MCS` → `ψ ∈ fam'.mcs t` (modal_forward) → IH forward for ψ | No |
| all_future | `Gψ ∈ MCS t` → `ψ ∈ MCS s` (forward_G) → IH forward for ψ | No |
| all_past | `Hψ ∈ MCS t` → `ψ ∈ MCS s` (backward_H) → IH forward for ψ | No |

**The imp forward case uses IH backward**: Given `(ψ → χ) ∈ fam.mcs t`, to show
`truth_at(ψ) → truth_at(χ)`, assume `truth_at(ψ)`. Need `truth_at(χ)`. But to get
`χ ∈ fam.mcs t` from `(ψ → χ) ∈ fam.mcs t`, we need `ψ ∈ fam.mcs t`, which requires
IH backward for ψ.

**So the imp forward case DOES require IH backward. The user is correct: forward and
backward are interdependent.**

However, there's an alternative proof for imp forward that avoids IH backward:

**Alternative imp forward proof**:
- `(ψ → χ) ∈ fam.mcs t` and we want `truth_at(ψ) → truth_at(χ)`
- By MCS maximality: either `ψ ∈ fam.mcs t` or `ψ.neg ∈ fam.mcs t`
- Case 1: `ψ.neg ∈ fam.mcs t`. Then `(ψ → χ)` is vacuously in MCS. We need
  `truth_at(ψ) → truth_at(χ)`. If we assume `truth_at(ψ)`, we need `truth_at(χ)`.
  But we don't know `χ ∈ fam.mcs t`... unless we use IH backward for ψ to get
  `ψ ∈ fam.mcs t`, contradicting `ψ.neg ∈ fam.mcs t`.
- Case 2: `ψ ∈ fam.mcs t`. Then by MCS modus ponens: `χ ∈ fam.mcs t`. By IH forward: `truth_at(χ)`.

In Case 1, we still need IH backward to derive the contradiction. The forward direction
is NOT self-contained.

**Conclusion**: The forward and backward directions are genuinely interdependent via the
imp case. A forward-only lemma cannot be proven by structural induction.

## Implementation Phases

### Phase 1: Document the Semantic Corrections [NOT STARTED]

**Goal**: Add precise documentation to the codebase explaining:
1. The semantics of G/H/F/P (same-history, varies-time only)
2. Why forward-only truth lemma fails (imp case needs IH backward)
3. The exact blocker: `temporal_backward_G` needs `forward_F`
4. Why cross-family reasoning is irrelevant (F doesn't cross families)

**Tasks**:
- [ ] Add warning block in `UltrafilterChain.lean` near BFMCS_Bundle
- [ ] Add comment in `ParametricTruthLemma.lean` explaining bidirectionality
- [ ] Add note in `TemporalCoherence.lean` about the criticality of `forward_F`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- `Theories/Bimodal/Metalogic/Algebraic/ParametricTruthLemma.lean`
- `Theories/Bimodal/Metalogic/Bundle/TemporalCoherence.lean`

---

### Phase 2: Rigorously Verify `forward_F` is Necessary [NOT STARTED]

**Goal**: Confirm or refute whether there exists ANY proof of
`(∀ s > t, ψ ∈ fam.mcs s) → Gψ ∈ fam.mcs t` that avoids `forward_F`.

**Tasks**:
- [ ] Attempt direct proof (not by contraposition)
- [ ] Attempt proof using chain construction properties of SuccChainFMCS
- [ ] Attempt proof using algebraic properties (temp_4, etc.)
- [ ] Search Mathlib/literature for analogous results
- [ ] If all fail: write a clear explanation of why `forward_F` is necessary
- [ ] Attempt to prove `forward_F` directly for SuccChainFMCS (revisit sub-case (b))

**Timing**: 4 hours

**Key investigation**: Can we prove `forward_F` for SuccChainFMCS families by showing
the omega dovetailing construction actually provides F-witnesses? The dovetailing
enumerates all F-obligations — does it resolve them within the same family?

---

### Phase 3: Investigate Omega Dovetailing for Same-Family F [NOT STARTED]

**Goal**: The omega chain construction uses dovetailing to enumerate F/P obligations.
Determine whether this guarantees same-family witnesses.

**Tasks**:
- [ ] Read the omega forward chain construction in UltrafilterChain.lean
- [ ] Trace the dovetailing mechanism for F-obligations
- [ ] Determine: if `F(φ) ∈ fam.mcs(t)`, does the dovetailing ensure
  `∃ s > t, φ ∈ fam.mcs(s)` within the SAME family?
- [ ] If yes: prove `forward_F` for the omega chain families
- [ ] If no: identify the exact step where the guarantee breaks down

**Timing**: 4 hours

**Rationale**: The omega chain was designed to resolve F/P obligations. If the dovetailing
actually works (enumerating all obligations and resolving them), then `forward_F` IS
provable for these specific families. The sub-case (b) analysis may have been overly
pessimistic.

---

### Phase 4: Implement Solution or Document Gap [NOT STARTED]

**Goal**: Based on findings from Phases 2-3:

**If `forward_F` is provable for omega chain families**:
- [ ] Prove `omega_chain_forward_F`: F(φ) in omega_chain.mcs(t) → ∃ s > t, φ in omega_chain.mcs(s)
- [ ] Prove `omega_chain_temporally_coherent`: omega chain families satisfy TemporalCoherentFamily
- [ ] Use existing `parametric_shifted_truth_lemma` (which works with TemporalCoherentFamily)
- [ ] Wire to completeness theorems

**If `forward_F` is NOT provable**:
- [ ] Document the mathematical obstruction precisely
- [ ] Explain why TM over Int completeness requires a different approach
- [ ] Investigate algebraic completeness bypass (representation theorem without truth lemma)
- [ ] Consider whether the logic itself needs an additional axiom

**Timing**: 6 hours

---

### Phase 5: Wire to Completeness Theorems [NOT STARTED]

**Goal**: If Phase 4 succeeds, eliminate the target sorries.

**Tasks**:
- [ ] Update `dense_completeness_fc`
- [ ] Update `discrete_completeness_fc`
- [ ] Update `completeness_over_Int`
- [ ] Verify with `#print axioms`

**Timing**: 2 hours

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] Documentation warnings are clear and semantically precise
- [ ] All new lemmas verified with `#print axioms`
- [ ] Forward_F investigation is conclusive (either proof or clear impossibility argument)

## Key Lesson

> **The truth lemma is an iff by structural induction. Both directions are proved
> simultaneously, with the imp case creating mutual dependency. Any sorry in any
> backward case prevents ALL forward cases from being sorry-free.**
>
> **The semantic definition of truth_at for G/H/F/P quantifies over TIME along a
> SINGLE history. Only Box quantifies across histories. Cross-family reasoning is
> relevant only for Box, not for temporal operators.**
