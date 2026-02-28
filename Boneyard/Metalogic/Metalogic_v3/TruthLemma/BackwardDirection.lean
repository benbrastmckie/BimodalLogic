/-!
# Backward Truth Lemma (Boneyard)

This file documents what would be needed to prove the backward direction of the Truth Lemma,
which is **NOT REQUIRED for the completeness theorem**.

## Task 741 Update (2026-01-29)

Task 741 performed detailed analysis of the witness extraction architecture.
The key finding is that the proof is blocked by the **omega-rule limitation**:

- H-completeness requires: `(∀ s < t, psi ∈ mcs(s)) → H psi ∈ mcs(t)`
- This requires deriving H psi from infinitely many psi instances
- TM logic (and standard proof systems) lack this "omega-rule"
- The IndexedMCSFamily coherence only provides the converse direction

See:
- `Theories/Bimodal/Metalogic/Representation/TemporalCompleteness.lean` for infrastructure
- `specs/741_witness_extraction_architecture_for_backward_truth_lemma/` for research and plan

## What the Backward Truth Lemma Would Prove

```lean
theorem truth_lemma_backward (family : IndexedMCSFamily D) (t : D) (phi : Formula) :
    truth_at (canonical_model family) (canonical_history family) t phi → phi ∈ family.mcs t
```

This is the converse of `truth_lemma_forward`. Together they establish:
```lean
phi ∈ family.mcs t ↔ truth_at ... phi
```

## Why It's Not Needed for Completeness

The representation theorem only uses the forward direction:

```
representation_theorem
    └── truth_lemma_forward
        ├── forward direction: phi ∈ MCS → truth_at phi
        └── (uses backward IH internally for imp case, but not backward conclusion)
```

The completeness theorem needs to show: if phi is consistent, then phi is satisfiable.
This only requires showing that membership in an MCS implies truth (forward direction).

## What It Would Be Good For

The backward direction ("tightness") proves that the canonical model has no
extraneous truths - every true formula is in the MCS. This is useful for:

1. **Soundness of the canonical model**: Everything true in the model is in the MCS
2. **Frame correspondence**: Connecting axiomatic strength to frame properties
3. **Definability results**: Showing which formulas define which frame classes
4. **Completeness of extensions**: When adding new axioms

## Proof Strategy for all_past Backward Case

```lean
-- Goal: (∀ s < t, truth_at s psi) → H psi ∈ mcs t

-- Approach 1: Contrapositive
-- Assume ¬(H psi) ∈ mcs t
-- By negation completeness for temporal operators:
--   ¬(H psi) ∈ MCS implies sometime_past (¬psi) ∈ MCS
-- This means: ∃ s < t. (¬psi) ∈ mcs s
-- By forward IH at s: truth_at s (¬psi)
-- Contradiction with h_all_past

-- Key infrastructure needed:
-- 1. Negation completeness for H: ¬(H φ) ↔ sometime_past (¬φ)
-- 2. Witness extraction from sometime_past in MCS
-- 3. Forward IH application at the witness time
```

## Proof Strategy for all_future Backward Case

```lean
-- Goal: (∀ s > t, truth_at s psi) → G psi ∈ mcs t

-- Approach 1: Contrapositive (symmetric to all_past)
-- Assume ¬(G psi) ∈ mcs t
-- By negation completeness for temporal operators:
--   ¬(G psi) ∈ MCS implies sometime_future (¬psi) ∈ MCS
-- This means: ∃ s > t. (¬psi) ∈ mcs s
-- By forward IH at s: truth_at s (¬psi)
-- Contradiction with h_all_future

-- Key infrastructure needed:
-- 1. Negation completeness for G: ¬(G φ) ↔ sometime_future (¬φ)
-- 2. Witness extraction from sometime_future in MCS
-- 3. Forward IH application at the witness time
```

## Estimated Effort

To prove the backward Truth Lemma cases:
- 4-6 hours for negation completeness lemmas for temporal operators
- 2-3 hours for witness extraction infrastructure
- 2-3 hours for connecting to forward IH

Total: ~10-12 hours

## Reference

- Original location: `Bimodal/Metalogic/Representation/TruthLemma.lean` lines 410, 423
- Gap analysis: `specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-004.md`
- Task: 681
-/

-- This file is documentation only. No compilable Lean code here.
