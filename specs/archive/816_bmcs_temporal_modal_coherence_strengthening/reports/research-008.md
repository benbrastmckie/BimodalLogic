# Research Report: Task #816 - Resolving the Apparent Conflict on Sorry-Free Completeness

**Task**: 816 - bmcs_temporal_modal_coherence_strengthening
**Date**: 2026-02-02
**Focus**: Resolve apparent conflict between claims in research-006.md and research-007.md

## Executive Summary

This report resolves the apparent conflict between two claims:
1. "The completeness theorems are already sorry-free" (research-007.md)
2. "The forward direction for implication needs the backward direction for subformulas, so temporal backward sorries propagate" (research-006.md)

**Resolution**: Both claims are TRUE, but they describe different levels of the proof structure.

- **research-007.md is correct**: Completeness.lean has zero `sorry` in its own code
- **research-006.md is correct**: The Truth Lemma has sorries that are transitively inherited by the completeness proof

**However, the claims need careful interpretation**:
- When Lean reports "sorry-free file," it means NO explicit `sorry` in that file
- But Lean still tracks transitive sorries from dependencies
- The completeness theorems have **zero local sorries** but **inherit sorries** from TruthLemma.lean and Construction.lean

**For publication with zero-sorry policy**: The current state does NOT meet a strict zero-sorry standard because the proof chain has 3 sorries total.

## The Conflict Explained

### What research-006.md Claims

> "The forward/backward interdependence for the imp case is an inherent property of the standard truth lemma proof technique... If those subformulas contain temporal operators, and the backward temporal direction has sorries, then the forward direction transitively depends on those sorries."

**This is TRUE.** Looking at TruthLemma.lean lines 307-316:

```lean
| imp ψ χ ih_ψ ih_χ =>
  simp only [bmcs_truth_at]
  have h_mcs := fam.is_mcs t
  constructor
  · -- Forward: (ψ → χ) ∈ MCS → (bmcs_truth ψ → bmcs_truth χ)
    intro h_imp h_ψ_true
    have h_ψ_mcs : ψ ∈ fam.mcs t := (ih_ψ fam hfam t).mpr h_ψ_true  -- ← uses .mpr (backward)
    have h_χ_mcs : χ ∈ fam.mcs t := set_mcs_implication_property h_mcs h_imp h_ψ_mcs
    exact (ih_χ fam hfam t).mp h_χ_mcs
```

The forward direction of `imp` case uses `.mpr` (backward) on the subformula `ψ`. If `ψ = G φ` for some `φ`, then the backward direction of `G` is called, which has a `sorry`.

### What research-007.md Claims

> "The completeness theorems are already sorry-free... They use only the forward direction (`.mp`) of this lemma."

**This is ALSO TRUE at the Completeness.lean level.** Looking at Completeness.lean lines 107-108:

```lean
have h_in_mcs : φ ∈ B.eval_family.mcs 0 :=
  construct_bmcs_contains_context [φ] h_cons φ (by simp)
exact (bmcs_truth_lemma B B.eval_family B.eval_family_mem 0 φ).mp h_in_mcs
```

Completeness.lean only calls `.mp` (forward direction) on the truth lemma at the **top level**.

### The Key Distinction

The two claims operate at different levels:

| Level | What's Being Analyzed | Sorry Status |
|-------|----------------------|--------------|
| Completeness.lean file | Uses `.mp` on truth lemma | No sorries IN THIS FILE |
| bmcs_truth_lemma theorem | Forward direction internally uses backward IH | Sorries in G/H backward |
| Lean's transitive tracking | Chain from completeness to truth lemma | 3 sorries total |

**The truth lemma forward direction is NOT pure forward.** It's a mutual induction where:
- Forward top-level calls backward subformula IH (at `imp` case)
- Backward top-level calls forward subformula IH (at `imp` case)

So when Completeness.lean calls `.mp` on `bmcs_truth_lemma`, it gets the forward direction of the **outermost** formula. But inside that proof, the backward direction of **subformulas** is used, which includes the sorry-marked temporal backward cases.

## Verification via Lean's Sorry Tracking

I verified the sorry dependencies by examining the code:

### TruthLemma.lean Sorries (2)
- Line 383: `all_future` backward case
- Line 395: `all_past` backward case

### Construction.lean Sorries (1)
- Line 220: `modal_backward` in `singleFamilyBMCS`

### Completeness.lean Sorries (0 local, 3 inherited)
- No explicit `sorry` in the file
- But transitively depends on TruthLemma.lean and Construction.lean

**Lean 4 tracks axioms and sorries transitively.** Running `#print axioms bmcs_representation` would show these dependencies.

## Why This Matters for Publication

### Zero-Sorry Policy Interpretation

A strict zero-sorry policy means:
- NO sorries anywhere in the proof chain
- All lemmas and their transitive dependencies are fully verified

The current BMCS completeness proof has:
- **3 total sorries** in the transitive closure
- **0 sorries** in Completeness.lean itself

### What "Completeness is sorry-free" Actually Means

When research-007.md says "completeness is sorry-free," it means:
1. The completeness proof structure is complete
2. No additional sorries were needed for the completeness argument
3. The sorries are in the auxiliary constructions (temporal backward, modal backward)

This is a valid mathematical claim but NOT the same as "zero sorries in the verified proof."

## Options for True Zero-Sorry Completeness

### Option 1: Accept Transitive Sorries as Documented Axioms

Mark the sorries as explicit axioms (using Lean's `axiom` declaration instead of `sorry`):

```lean
axiom omega_saturation_G (fam : IndexedMCSFamily D) (t : D) (φ : Formula) :
  (∀ s, t ≤ s → φ ∈ fam.mcs s) → Formula.all_future φ ∈ fam.mcs t

axiom omega_saturation_H (fam : IndexedMCSFamily D) (t : D) (φ : Formula) :
  (∀ s, s ≤ t → φ ∈ fam.mcs s) → Formula.all_past φ ∈ fam.mcs t

axiom modal_saturation (fam : IndexedMCSFamily D) (φ : Formula) (t : D) :
  (∀ fam' ∈ B.families, φ ∈ fam'.mcs t) → Formula.box φ ∈ fam.mcs t
```

**Pros**: Honest, explicit, standard practice for infinitary assumptions
**Cons**: Still not "sorry-free" in the literal sense

### Option 2: Use the FMP Completeness Path

The codebase already has a completely sorry-free weak completeness via Finite Model Property:

```lean
-- From Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (∀ (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) →
    ⊢ phi
```

This approach:
- Uses bounded time domains (`BoundedTime k`)
- Works with finite world states (`FiniteWorldState`)
- Avoids the omega-rule by restricting to formula-dependent temporal bounds
- Is completely sorry-free

**Pros**: Already implemented, truly sorry-free
**Cons**: Different architectural approach (bounded time)

### Option 3: Multi-Family Modal Saturation (Partial Fix)

Implement a multi-family construction to eliminate the `modal_backward` sorry in Construction.lean:

```lean
/-- Multi-family BMCS with modal saturation -/
noncomputable def saturatedMultiFamilyBMCS (baseFam : IndexedMCSFamily D) : BMCS D where
  families := constructSaturatedFamilies baseFam
  modal_forward := ... -- proven by construction
  modal_backward := ... -- proven by saturation property
  ...
```

**Pros**: Eliminates 1 of 3 sorries
**Cons**: Does not help temporal sorries (different root cause)

### Option 4: Restrict Truth Lemma to Non-Temporal Fragment

Prove a biconditional truth lemma only for formulas without temporal operators:

```lean
def Formula.is_propositional_modal : Formula → Prop
  | .atom _ => True
  | .bot => True
  | .imp ψ χ => ψ.is_propositional_modal ∧ χ.is_propositional_modal
  | .box ψ => ψ.is_propositional_modal
  | .all_future _ => False
  | .all_past _ => False

theorem truth_lemma_propositional_modal
    (φ : Formula) (h_pm : φ.is_propositional_modal)
    (B : BMCS D) (fam : IndexedMCSFamily D) (hfam : fam ∈ B.families) (t : D) :
    φ ∈ fam.mcs t ↔ bmcs_truth_at B fam t φ := by
  induction φ generalizing t with
  -- all_future and all_past cases are vacuously true (h_pm.false)
```

**Pros**: True biconditional without sorries for the fragment
**Cons**: Weaker result than current (loses temporal formulas)

## Recommendation

For a journal submission with strict zero-sorry policy, the options in order of recommendation:

### 1. Primary: Use FMP Completeness (Recommended)

Reference `semantic_weak_completeness` from the FMP module. This is:
- Already implemented
- Completely sorry-free
- Standard approach (finite model property)

The BMCS approach can be presented as an alternative construction that provides additional insights into the modal semantics structure.

### 2. Secondary: Convert Sorries to Explicit Axioms

If BMCS must be the primary result:
- Convert the 3 sorries to explicit `axiom` declarations
- Document the omega-rule and modal saturation as foundational assumptions
- This is mathematically honest and follows academic precedent

### 3. Tertiary: Hybrid Approach

- Use FMP for the main completeness claim
- Present BMCS as a construction that:
  - Achieves sorry-free box case (the main technical contribution)
  - Has documented axioms for temporal/modal saturation
  - Provides a different perspective on the semantics

## Technical Verification: Why Imp Forward Needs Backward

To make the analysis concrete, here's the dependency chain:

```
bmcs_representation
  └── bmcs_truth_lemma.mp (forward direction at top level)
        └── induction on φ
              └── imp case (lines 307-346)
                    └── FORWARD direction (lines 312-316)
                          └── (ih_ψ ...).mpr (BACKWARD on subformula ψ)
                                └── if ψ = G χ, then all_future backward case
                                      └── sorry (line 383)
```

This shows why the forward direction of the truth lemma is NOT independent of the backward direction. The mutual induction is inherent to the proof technique.

## Conclusion

Both research-006.md and research-007.md are correct at their respective levels of analysis:

- **research-007.md**: Completeness.lean contains no sorries; it calls only `.mp` at the top level
- **research-006.md**: The truth lemma's forward direction internally uses backward IH, creating transitive dependencies

For strict zero-sorry publication:
1. **Use FMP completeness** as the primary result (already sorry-free)
2. **Present BMCS as supplementary** with explicit axiom documentation
3. **Document the omega-rule limitation** as foundational (not proof engineering gap)

The key mathematical achievement of BMCS remains valid: the **box case** is fully proven without sorry, resolving the modal completeness obstruction. The temporal sorries arise from a fundamentally different issue (omega-rule) that affects all finitary proof systems.

## References

### Primary Sources Analyzed
- `Theories/Bimodal/Metalogic/Bundle/TruthLemma.lean` - Lines 307-346 (imp case), 372-395 (temporal)
- `Theories/Bimodal/Metalogic/Bundle/Completeness.lean` - Lines 99-108, 116-126
- `Theories/Bimodal/Metalogic/Bundle/Construction.lean` - Lines 194-222 (singleFamilyBMCS)

### Research Reports
- `research-006.md` - Alternative proof techniques analysis
- `research-007.md` - Comprehensive strategy analysis

### Alternative Implementation
- `Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean` - Sorry-free FMP completeness
