# Task Semantics Analysis for Completeness

**Task**: 67 - prove_bundle_validity_implies_provability
**Date**: 2026-03-28
**Focus**: Analyzing from task semantics perspective rather than standard Kripke

---

## Task Semantics Analysis (How G/H Work in This Framework)

### The Three-Place Task Relation

The task frame provides a fundamentally different structure than standard Kripke frames:

```lean
structure TaskFrame (D : Type*) [...] where
  WorldState : Type
  task_rel : WorldState → D → WorldState → Prop
  nullity_identity : ∀ w u, task_rel w 0 u ↔ w = u
  forward_comp : ∀ w u v x y, 0 ≤ x → 0 ≤ y → task_rel w x u → task_rel u y v → task_rel w (x+y) v
  converse : ∀ w d u, task_rel w d u ↔ task_rel u (-d) w
```

The key insight: `task_rel w d u` is a **three-place relation** where `d : D` is a *duration*, not a single accessibility relation. This creates a fundamentally different semantic structure.

### World Histories: Time-Indexed Paths

A world history is NOT a single world but a function from times to world states:

```lean
structure WorldHistory (F : TaskFrame D) where
  domain : D → Prop
  convex : ∀ x z, domain x → domain z → ∀ y, x ≤ y → y ≤ z → domain y
  states : (t : D) → domain t → F.WorldState
  respects_task : ∀ s t (hs : domain s) (ht : domain t),
      s ≤ t → F.task_rel (states s hs) (t - s) (states t ht)
```

Critical observation: A history `τ` assigns a world state `τ.states(t)` to each time `t` in its domain, and these states must be connected by the task relation with appropriate durations.

### Truth Conditions for Temporal Operators

The truth definition reveals the core semantic distinction:

```lean
def truth_at (M : TaskModel F) (Omega : Set (WorldHistory F))
    (τ : WorldHistory F) (t : D) : Formula → Prop
  | Formula.all_future φ => ∀ (s : D), t ≤ s → truth_at M Omega τ s φ  -- G
  | Formula.all_past φ   => ∀ (s : D), s ≤ t → truth_at M Omega τ s φ  -- H
  | Formula.box φ        => ∀ (σ : WorldHistory F), σ ∈ Omega → truth_at M Omega σ t φ
```

**The semantic split is fundamental**:

1. **G(φ)** ("φ at all future times"): Quantifies over times `s ≥ t` along the **SAME history τ**
2. **H(φ)** ("φ at all past times"): Quantifies over times `s ≤ t` along the **SAME history τ**
3. **□φ** ("necessarily φ"): Quantifies over **different histories σ** at the **SAME time t**

This is NOT standard Kripke semantics where both temporal and modal operators quantify over accessible worlds. In task semantics:
- Time is **within a history** (changes `t` along fixed `τ`)
- Modality is **across histories** (changes `τ` while fixing `t`)

---

## Truth Lemma Requirements (What's Actually Needed Given Task Semantics)

### The Canonical Model Structure

The parametric canonical model maps syntactic objects to semantic objects:

1. **World states**: MCS wrapped as `ParametricCanonicalWorldState`
2. **Histories**: FMCS (Family of MCS) converted via `parametric_to_history`:
   - `domain = True` (full domain)
   - `states(t) = fam.mcs(t)` (MCS at time t)
3. **Omega**: Set of histories from bundle families

### The Truth Lemma Statement

```lean
theorem parametric_shifted_truth_lemma (B : BFMCS D)
    (h_tc : B.temporally_coherent) (φ : Formula)
    (fam : FMCS D) (hfam : fam ∈ B.families) (t : D) :
    φ ∈ fam.mcs t ↔
    truth_at (ParametricCanonicalTaskModel D) (ShiftClosedParametricCanonicalOmega B)
      (parametric_to_history fam) t φ
```

### The Backward G/H Cases Require Same-History Witnesses

The critical insight from the truth lemma proof:

**Backward G case** (`truth(G(ψ)) → G(ψ) ∈ MCS`):
```
1. Assume G(ψ) ∉ fam.mcs(t)              [for contradiction]
2. neg(G(ψ)) ∈ fam.mcs(t)                [MCS negation completeness]
3. F(neg(ψ)) ∈ fam.mcs(t)                [temporal duality]
4. ∃ s > t, neg(ψ) ∈ fam.mcs(s)          [forward_F — SAME family fam]
5. But truth(G(ψ)) means truth(ψ) at all s ≥ t along τ = parametric_to_history(fam)
6. By backward IH: ψ ∈ fam.mcs(s)        [for the SAME family fam]
7. Contradiction: ψ and neg(ψ) in fam.mcs(s)
```

**Why same-family is essential**: The semantic hypothesis in step 5 says ψ is true at all future times *along the history τ = parametric_to_history(fam)*. By the backward IH, this translates to `ψ ∈ fam.mcs(s)` — specifically in family `fam`. The contradiction requires both `ψ` and `neg(ψ)` in the **same consistent set** `fam.mcs(s)`.

If the `neg(ψ)` witness were in a different family `fam'`, there would be no contradiction: `ψ ∈ fam.mcs(s)` and `neg(ψ) ∈ fam'.mcs(s)` is perfectly consistent (different MCSes).

### The History Structure Constrains Witnesses

In task semantics, G quantifies **along the history**. The canonical history `parametric_to_history(fam)` at each time `t` gives the MCS `fam.mcs(t)`. Thus:
- G(ψ) true at (τ, t) means ψ true at (τ, s) for all s ≥ t
- This translates to ψ ∈ fam.mcs(s) for all s ≥ t **in the same family fam**

The "witness in same family" requirement IS exactly "witness in same history" because each family corresponds to exactly one history in the canonical model.

---

## Gap Analysis (Where Current Infrastructure Falls Short)

### What Is Sorry-Free

1. **Bundle construction** (`construct_bfmcs_bundle`): Builds BFMCS_Bundle with:
   - `modal_forward` / `modal_backward`: □-formula coherence
   - `bundle_forward_F` / `bundle_backward_P`: Witnesses in **some** family (bundle-level)

2. **Each FMCS family** (`SuccChainFMCS`):
   - `forward_G`: G(φ) at t implies φ at all t' ≥ t (sorry-free)
   - `backward_H`: H(φ) at t implies φ at all t' ≤ t (sorry-free)

3. **Restricted family-level coherence** (for deferral closure formulas):
   - `restricted_forward_chain_forward_F` (SuccChainFMCS.lean:2921): F-witness within bounded steps

4. **Truth lemma** (`parametric_shifted_truth_lemma`): Sorry-free **given** `h_tc : B.temporally_coherent`

### The Gap

**Bundle-level temporal coherence** (proved, sorry-free):
```lean
F(φ) ∈ fam.mcs(t) → ∃ fam' ∈ B.families, ∃ s > t, φ ∈ fam'.mcs(s)
```

**Family-level temporal coherence** (THE GAP):
```lean
F(φ) ∈ fam.mcs(t) → ∃ s > t, φ ∈ fam.mcs(s)  -- same family fam
```

The existing infrastructure provides bundle-level but NOT family-level coherence for arbitrary formulas.

### Why the Gap Matters (Task Semantics Perspective)

In task semantics:
- A history τ is a time-indexed path through world states
- G quantifies over times **along τ**, not across all accessible worlds
- The canonical model maps `fam` to `parametric_to_history(fam)`
- Truth at time s along this history corresponds to membership in `fam.mcs(s)`

The truth lemma's backward G case requires finding a witness `s > t` where `neg(ψ) ∈ fam.mcs(s)` — in the **same family** that generates the **same history**. A witness in a different family would correspond to a different history, breaking the contrapositive argument.

---

## Proposed Resolution

### Key Observation: Restricted Coherence May Suffice

The truth lemma invokes `forward_F` only on formulas of the form `neg(ψ)` where `G(ψ)` appears in the target formula φ. These `neg(ψ)` are in `closureWithNeg(φ)`, hence in `deferralClosure(φ)`.

For formulas in the deferral closure, `restricted_forward_chain_forward_F` provides same-family witnesses with bounded deferral.

### Proposed Path: Restricted Truth Lemma

**Hypothesis**: A restricted truth lemma can be proved using only restricted family-level coherence:

```lean
theorem restricted_parametric_truth_lemma
    (B : BFMCS_Bundle)
    (φ_target : Formula)
    (ψ : Formula) (h_sub : ψ ∈ subformulaClosure φ_target)
    (fam : FMCS Int) (hfam : fam ∈ B.families) (t : Int)
    (h_restricted_tc : ∀ χ ∈ deferralClosure φ_target,
        F(χ) ∈ fam.mcs t → ∃ s > t, χ ∈ fam.mcs s) :
    ψ ∈ fam.mcs t ↔ truth_at (canonical_model) (canonical_omega) (parametric_to_history fam) t ψ
```

The induction proceeds on subformulas of `φ_target`. The G backward case invokes `forward_F` on `neg(ψ')` where `G(ψ')` is a subformula — and `neg(ψ') ∈ deferralClosure(φ_target)` by construction of the closure.

### Implementation Steps

1. **Verify closure property**: Confirm that `neg(ψ) ∈ deferralClosure(φ)` whenever `G(ψ)` is a subformula of φ.

2. **Lift restricted coherence through shifts**: Show that `restricted_forward_chain_forward_F` for `SuccChainFMCS(W)` transfers to `shifted_fmcs(SuccChainFMCS(W), k)`.

3. **Structure the restricted truth lemma**: Prove the bidirectional truth lemma for subformulas of φ_target, using restricted coherence in the G/H backward cases.

4. **Wire to completeness**: Given non-provability of φ, apply restricted truth lemma to `neg(φ)` (which is a subformula of itself) to get a satisfying assignment.

### Why This Should Work

The task semantics constraint that G quantifies along a single history actually **helps** the restricted approach:
- We only need witnesses along the specific history being evaluated
- That history corresponds to a specific FMCS family
- The deferral closure captures exactly the formulas where witnesses are needed
- The bounded deferral mechanism in SuccChain resolves these obligations

---

## Confidence Level: **Medium-High**

### Justification

**High confidence factors**:
1. The task semantics analysis is mathematically precise and matches the implementation
2. The "same-family" requirement follows directly from the truth lemma proof structure
3. The restricted coherence is already sorry-free for deferral closure formulas
4. The closure property (neg(ψ) ∈ deferralClosure when G(ψ) is a subformula) is by construction

**Medium confidence factors**:
1. The restricted truth lemma hasn't been fully implemented and verified
2. Shift preservation of restricted coherence needs verification
3. Some termination sorries remain in the restricted chain construction

**Risk areas**:
1. The intermediate formula `F(neg(ψ))` (step 3 in the backward G proof) may require MCS closure properties that extend beyond the deferral closure
2. The backward P case (for H) has analogous structure but may have independent sorries

---

## Summary

The task semantics perspective clarifies why family-level coherence is required:

1. **G quantifies within a history**: In `truth_at M Omega τ t (G ψ)`, we check ψ at all times `s ≥ t` along the **same history τ**

2. **Canonical histories correspond to FMCS families**: `parametric_to_history(fam)` generates a history whose states at time t are `fam.mcs(t)`

3. **Same-family witnesses = same-history witnesses**: The contrapositive argument needs `neg(ψ)` at some future time in the same family because that's the same history where truth is being evaluated

4. **Restricted coherence may suffice**: The truth lemma only needs `forward_F` for formulas in `deferralClosure(φ)`, where bounded deferral is already proved

The path forward is to formalize and verify the restricted truth lemma approach, leveraging the sorry-free restricted coherence infrastructure.
