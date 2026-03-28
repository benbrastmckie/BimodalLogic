# The Completeness Blocker: A Self-Contained Account

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-28

This report explains every step of the completeness problem, including all relevant definitions, so that the structure of the difficulty is fully transparent.

---

## 1. The Goal

Prove `bundle_validity_implies_provability`:

```
theorem bundle_validity_implies_provability (φ : Formula)
    (h_valid : valid_over Int φ) : Nonempty ([] ⊢ φ)
```

Where `valid_over Int φ` means: for every TaskFrame over `Int`, every TaskModel, every shift-closed set `Omega` of WorldHistories, every history `τ ∈ Omega`, and every time `t : Int`:

```
truth_at M Omega τ t φ
```

The proof proceeds by contrapositive: assume `¬Nonempty ([] ⊢ φ)`, construct a canonical model where `φ` is false, contradicting validity.

---

## 2. The Semantic Definitions

### 2.1 TaskFrame

A task frame over a totally ordered abelian group `D` provides the three-place task relation:

```
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x + y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

The task relation `task_rel w d u` means "world state `u` is reachable from `w` by a task of duration `d`." The three axioms ensure: zero duration is identity, non-negative durations compose, and the relation is symmetric under duration negation.

### 2.2 WorldHistory

A world history is a time-indexed path through world states:

```
structure WorldHistory (F : TaskFrame D) where
  domain : D → Prop
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ (s t : D) (hs : domain s) (ht : domain t),
      s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

The `respects_task` field constrains histories to be consistent with the task relation: adjacent states must be related by the task relation with the appropriate duration.

### 2.3 Truth Evaluation

Truth at a model-history-time triple, by structural induction on formulas:

```
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.atom p     => ∃ (ht : τ.domain t), M.valuation (τ.states t ht) p
  | Formula.bot        => False
  | Formula.imp φ ψ    => truth_at M Omega τ t φ → truth_at M Omega τ t ψ
  | Formula.box φ      => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
  | Formula.all_past φ  => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ
  | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ
```

Key observations:
- `box φ` quantifies over histories in `Omega` (modal dimension: different scenarios)
- `all_future φ` (= `G φ`) quantifies over future times along the SAME history `τ` (temporal dimension)
- `all_past φ` (= `H φ`) quantifies over past times along the SAME history `τ`
- The task relation does NOT appear in truth evaluation; it constrains WorldHistories via `respects_task`

---

## 3. The Syntactic Definitions

### 3.1 Maximal Consistent Set (MCS)

A set `M` of formulas is a maximal consistent set if:
- **Consistent**: No finite subset of `M` derives `⊥`
- **Maximal**: For every formula `φ`, either `φ ∈ M` or `neg(φ) ∈ M`

Key MCS properties (all sorry-free):
- **Negation completeness**: `φ ∈ M` or `neg(φ) ∈ M` (but not both)
- **Closure under derivation**: If `L ⊆ M` and `L ⊢ ψ`, then `ψ ∈ M`
- **Implication property**: If `φ → ψ ∈ M` and `φ ∈ M`, then `ψ ∈ M`

### 3.2 FMCS (Family of Maximal Consistent Sets)

An FMCS over `D` assigns an MCS to each time point with temporal propagation:

```
structure FMCS (D : Type*) [Preorder D] where
  mcs : D → Set Formula
  is_mcs : ∀ t, SetMaximalConsistent (mcs t)
  forward_G : ∀ t t' φ, t ≤ t' → Formula.all_future φ ∈ mcs t → φ ∈ mcs t'
  backward_H : ∀ t t' φ, t' ≤ t → Formula.all_past φ ∈ mcs t → φ ∈ mcs t'
```

- `forward_G`: If `G(φ) ∈ mcs(t)` and `t ≤ t'`, then `φ ∈ mcs(t')` — "G-formulas propagate forward"
- `backward_H`: If `H(φ) ∈ mcs(t)` and `t' ≤ t`, then `φ ∈ mcs(t')` — "H-formulas propagate backward"

### 3.3 BFMCS (Bundle of FMCS)

A BFMCS is a collection of FMCSes with modal coherence:

```
structure BFMCS (D : Type*) [...] where
  families : Set (FMCS D)
  nonempty : families.Nonempty
  modal_forward : ∀ fam ∈ families, ∀ φ t,
      Formula.box φ ∈ fam.mcs t → ∀ fam' ∈ families, φ ∈ fam'.mcs t
  modal_backward : ∀ fam ∈ families, ∀ φ t,
      (∀ fam' ∈ families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
```

### 3.4 Temporal Coherence

The temporal coherence condition on a BFMCS:

```
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t φ, F(φ) ∈ fam.mcs t → ∃ s > t, φ ∈ fam.mcs s) ∧
    (∀ t φ, P(φ) ∈ fam.mcs t → ∃ s < t, φ ∈ fam.mcs s)
```

This requires **family-level** witnesses: the `s` with `φ ∈ fam.mcs(s)` must be in the SAME family `fam`, not some other family.

There is also a weaker **bundle-level** coherence (in `BFMCS_Bundle`):

```
bundle_forward_F : ∀ fam ∈ families, ∀ φ t,
    F(φ) ∈ fam.mcs t → ∃ fam' ∈ families, ∃ s > t, φ ∈ fam'.mcs s
```

Here the witness can be in ANY family `fam'`, not necessarily the same one. The sorry-free `construct_bfmcs_bundle` provides bundle-level coherence. No sorry-free construction provides family-level coherence.

### 3.5 TemporalCoherentFamily

An FMCS extended with the existential duals of `forward_G` and `backward_H`:

```
structure TemporalCoherentFamily (D : Type*) [Preorder D] [Zero D] extends FMCS D where
  forward_F : ∀ t φ, F(φ) ∈ mcs t → ∃ s > t, φ ∈ mcs s
  backward_P : ∀ t φ, P(φ) ∈ mcs t → ∃ s < t, φ ∈ mcs s
```

---

## 4. The Truth Lemma

### 4.1 Statement

The parametric truth lemma connects MCS membership to semantic truth:

```
theorem parametric_shifted_truth_lemma (B : BFMCS D)
    (h_tc : B.temporally_coherent) (φ : Formula)
    (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) :
    φ ∈ fam.mcs t ↔
    truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ
```

This lemma is SORRY-FREE, but takes `h_tc : B.temporally_coherent` as a hypothesis.

### 4.2 Why the Truth Lemma Is Inherently Bidirectional

The proof is by structural induction on `φ`. For each formula, BOTH directions (forward: `∈ MCS → truth` and backward: `truth → ∈ MCS`) must be proved simultaneously.

**The `imp` case forces bidirectionality.** The forward direction for `(ψ → χ)` proceeds:

```
Forward: (ψ → χ) ∈ MCS, truth(ψ) ⊢ truth(χ)

  1. truth(ψ)                              [given]
  2. ψ ∈ fam.mcs(t)                        [BACKWARD IH for ψ]
  3. (ψ → χ) ∈ fam.mcs(t), ψ ∈ fam.mcs(t) [given + step 2]
  4. χ ∈ fam.mcs(t)                         [MCS modus ponens]
  5. truth(χ)                               [FORWARD IH for χ]
```

Step 2 uses the **backward** induction hypothesis for `ψ`. This is not a proof engineering choice — it reflects a structural necessity. To perform MCS modus ponens (step 3→4), we need `ψ ∈ MCS`, but we only have `truth(ψ)`. Converting `truth(ψ)` to `ψ ∈ MCS` IS the backward direction.

**Consequence for completeness**: To prove `neg(φ) ∈ MCS → truth(neg(φ))` (the forward direction for `neg(φ) = φ.imp ⊥`), we need the backward direction for `φ`. If `φ` contains G or H subformulas, the backward direction for those cases requires `h_tc`.

A forward-only truth lemma CANNOT be stated or proved for the `imp` connective.

### 4.3 Where `h_tc` Is Used

`h_tc` appears in exactly two places — the backward direction of `G` and `H`:

**Backward G** (truth at all future times → `G(ψ) ∈ MCS`):

```
  1. Assume G(ψ) ∉ fam.mcs(t)              [for contradiction]
  2. neg(G(ψ)) ∈ fam.mcs(t)               [MCS negation completeness]
  3. F(neg(ψ)) ∈ fam.mcs(t)               [temporal duality: neg(G(φ)) ≡ F(neg(φ))]
  4. ∃ s > t, neg(ψ) ∈ fam.mcs(s)         [forward_F from h_tc — THE CRITICAL STEP]
  5. ψ ∈ fam.mcs(s)                        [backward IH + semantic hypothesis]
  6. Contradiction: ψ and neg(ψ) in fam.mcs(s)  [MCS consistency]
```

Step 4 invokes `forward_F` from `h_tc`. The witness `neg(ψ)` must be in `fam.mcs(s)` — the SAME family. Why? Because:
- The semantic hypothesis says `truth(ψ)` at all `s ≥ t` along history `to_history(fam)`
- The backward IH converts this to `ψ ∈ fam.mcs(s)` — in family `fam`
- The contradiction requires both `ψ` and `neg(ψ)` in the SAME consistent set `fam.mcs(s)`
- If the `neg(ψ)` witness were in a different family `fam'`, there would be no contradiction: `ψ ∈ fam.mcs(s)` and `neg(ψ) ∈ fam'.mcs(s)` is perfectly consistent

**Backward H** is symmetric, using `backward_P` from `h_tc`.

### 4.4 Summary of Dependency Structure

```
truth_at for φ.imp ψ (forward)
  └── uses truth_at for φ (BACKWARD)
        └── if φ = G(χ): uses temporal_backward_G
              └── uses forward_F from h_tc
                    └── requires ∃ s > t, neg(χ) ∈ SAME FAMILY fam.mcs(s)
```

Every formula containing G or H under an implication triggers this chain.

---

## 5. The Completeness Proof Structure

### 5.1 The Contrapositive Argument

```
1. Assume ¬⊢ φ                                       [for contradiction]
2. {neg(φ)} is consistent                            [not_provable_implies_neg_consistent, SORRY-FREE]
3. Extend to MCS M with neg(φ) ∈ M                   [Lindenbaum's lemma, SORRY-FREE]
4. Build BFMCS_Bundle B with eval_family.mcs(0) = M  [construct_bfmcs_bundle, SORRY-FREE]
5. Prove B.temporally_coherent                        [THE GAP]
6. Truth lemma: neg(φ) ∈ M ↔ truth(neg(φ)) at (fam, 0)  [parametric_shifted_truth_lemma, SORRY-FREE given step 5]
7. Forward direction: neg(φ) true in canonical model  [from step 6]
8. valid_over Int φ applied to canonical model: φ true [from hypothesis]
9. truth(neg(φ)) = truth(φ → ⊥) = (truth(φ) → False) [definition of truth_at for imp]
10. Steps 7 + 8 + 9: False                           [contradiction]
```

Step 5 is the gap. Everything else is sorry-free.

### 5.2 What `construct_bfmcs_bundle` Provides (Sorry-Free)

The sorry-free bundle construction provides:
- `families`: Set of FMCSes (shifted SuccChains from box-class-agreeing MCSes)
- `modal_forward` / `modal_backward`: Box-formula coherence across families
- `bundle_forward_F` / `bundle_backward_P`: F/P witnesses in SOME family (bundle-level)
- `eval_family`: Distinguished family with `eval_family.mcs(0) = M`

Each family is a `SuccChainFMCS` (sorry-free), which already satisfies:
- `forward_G`: G-formulas propagate forward along the chain
- `backward_H`: H-formulas propagate backward along the chain

What is NOT provided: family-level `forward_F` and `backward_P` for arbitrary formulas.

### 5.3 The SuccChain Construction

Each `SuccChainFMCS` is built step-by-step using the `Succ` relation:

```
Succ(u, v) means:
  1. g_content(u) ⊆ v     — G-formulas propagate (G(φ) ∈ u → φ ∈ v)
  2. f_content(u) ⊆ v ∪ f_content(v)  — F-obligations resolved or deferred
```

At each step, if `F(ψ) ∈ chain(n)`, then either:
- `ψ ∈ chain(n+1)` — the obligation is **resolved**, or
- `F(ψ) ∈ chain(n+1)` — the obligation is **deferred** to the next step

For arbitrary formulas, deferral can continue indefinitely (f_nesting is unbounded for full MCSes — `f_nesting_is_bounded` is mathematically FALSE).

For formulas in `deferralClosure(target)`, deferral is bounded by `closure_F_bound(target)` because `iter_F_not_mem_closureWithNeg` (sorry-free) proves that F-nesting eventually exits the closure.

---

## 6. The Gap: Bundle-Level vs Family-Level Coherence

### 6.1 Bundle-Level (PROVED, sorry-free)

```
F(φ) ∈ fam.mcs(t) → ∃ fam' ∈ B.families, ∃ s > t, φ ∈ fam'.mcs(s)
```

Proof: `temporal_theory_witness_exists` (sorry-free) produces a witness MCS `W` with `φ ∈ W` and `box_class_agree(fam.mcs(t), W)`. A shifted `SuccChainFMCS(W)` placed at time `t+1` is a new family in `boxClassFamilies` containing `φ` at time `t+1`.

### 6.2 Family-Level (THE GAP)

```
F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s)
```

This requires the witness at a future time in the SAME family. The SuccChain construction defers F-obligations but may defer them indefinitely for arbitrary formulas.

### 6.3 Restricted Family-Level (PROVED for closure formulas, sorry-free)

```
F(φ) ∈ fam.mcs(t), φ ∈ deferralClosure(target) → ∃ s > t, φ ∈ fam.mcs(s)
```

Proved by `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:2921, sorry-free). The bounded nesting within the closure guarantees resolution.

---

## 7. The Critical Question

The truth lemma for target formula `φ` invokes `forward_F` only on formulas `neg(ψ)` where `ψ` is a subformula of `φ`. These negated subformulas are in `deferralClosure(φ)`.

**Can a truth lemma be proved using only restricted family-level coherence (for formulas in the deferral closure of the target) rather than unrestricted family-level coherence?**

If yes, then:
1. The restricted coherence is already proved sorry-free for each SuccChainFMCS
2. Each family in `construct_bfmcs_bundle` is a shifted SuccChainFMCS
3. The restricted coherence transfers through shifts
4. The truth lemma goes through with the restricted hypothesis
5. The completeness proof is complete

If no, then a fundamentally different approach is needed.

### 7.1 What Would Need to Be Verified

To confirm this path works, one must verify:

1. **Closure under subformula**: That `neg(ψ) ∈ deferralClosure(φ)` whenever `G(ψ)` or `H(ψ)` appears as a subformula in the induction. The deferral closure is defined to include negations of formulas whose F/P-wrapped forms appear in the subformula closure.

2. **Shift preservation**: That `restricted_forward_chain_forward_F` for a SuccChain from base MCS `W` carries over to `shifted_fmcs(SuccChainFMCS(W), k)` — the same chain shifted by offset `k`. The shift maps time `t` to `t - k`, so the F-witness at time `s` in the original chain becomes a witness at time `s + k` in the shifted chain.

3. **Uniformity across families**: That the deferral closure bound `closure_F_bound(φ)` applies to ALL families in the bundle, not just the eval family. Since `closure_F_bound` depends only on the target formula (not the base MCS), and every family is a SuccChain, this should hold uniformly.

4. **The truth lemma induction**: That the restricted truth lemma can be structured so the IH provides both directions for subformulas of `φ`, with the G/H backward cases using restricted coherence. The key is ensuring the `forward_F` invocation on `neg(ψ)` falls within the restricted domain at every induction step.

---

## 8. What Is Sorry-Free and What Is Not

### Sorry-free (usable as-is):
- `construct_bfmcs_bundle` — builds the bundle with bundle-level coherence
- `SuccChainFMCS` — each family with `forward_G`, `backward_H`
- `restricted_forward_chain_forward_F` — family-level F for closure formulas
- `restricted_backward_chain_backward_P` — family-level P for closure formulas
- `parametric_shifted_truth_lemma` — bidirectional truth lemma (conditional on `h_tc`)
- `parametric_algebraic_representation_conditional` — representation theorem (conditional on `construct_bfmcs`)
- `not_provable_implies_neg_consistent` — non-provability → consistency
- `temporal_theory_witness_exists` — F-witness MCS existence
- All TaskFrame axiom proofs for the canonical frame

### Has sorry (the gap):
- `bundle_validity_implies_provability` (FrameConditions/Completeness.lean:204) — the target
- `boxClassFamilies_temporally_coherent` (UltrafilterChain.lean:1822) — deprecated, depends on false `f_nesting_is_bounded`
- `construct_bfmcs` (UltrafilterChain.lean:1863) — deprecated
- `Z_chain_forward_G` crossing cases (UltrafilterChain.lean:2347, 2369) — needs `G(a) → H(G(a))` which is not valid
- `Z_chain_forward_F/backward_P` (UltrafilterChain.lean:2485, 2494) — dovetailing not implemented
- `restricted_tc_family_to_fmcs.forward_G/backward_H` (CanonicalConstruction.lean:885, 889) — independent Lindenbaum extensions break G/H propagation

### Independent of completeness (separate issues):
- Soundness.lean sorries (frame-class restrictions for extension axioms)
- TruthPreservation.lean sorries (strict-vs-reflexive semantics mismatch)

---

## 9. Summary

The completeness proof requires a **bidirectional** truth lemma connecting MCS membership to semantic truth. This truth lemma requires **family-level** temporal coherence (`forward_F` and `backward_P` with same-family witnesses). The sorry-free infrastructure provides:

- Bundle-level temporal coherence (witnesses in any family) — **insufficient** because the backward G case needs same-family witnesses for its contrapositive argument
- Restricted family-level coherence for deferral-closure formulas — **potentially sufficient** because the truth lemma only invokes `forward_F` on negated subformulas of the target, which are in the deferral closure

The remaining work is to prove that restricted family-level coherence suffices for the truth lemma and to wire this through the completeness argument. This requires verifying that the subformula-closure relationship holds at every step of the induction and that the restricted coherence transfers through shifted SuccChains.
