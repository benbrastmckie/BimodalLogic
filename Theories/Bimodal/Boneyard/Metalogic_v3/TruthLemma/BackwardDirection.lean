/-!
# Backward Truth Lemma (Boneyard)

This file documents what would be needed to prove the backward direction of the Truth Lemma,
which is **NOT REQUIRED for the completeness theorem**.

## Task 745 Update (2026-01-29)

Task 745 moved the backward direction infrastructure from Representation/ to Boneyard/ and
cleaned up TruthLemma.lean to present only the forward direction cleanly. Key changes:

- **TemporalCompleteness.lean**: Moved to `Boneyard/Metalogic_v3/TruthLemma/TemporalCompleteness.lean`
  Contains H/G-completeness lemmas (with sorry) blocked by omega-rule limitation.

- **TruthLemma.lean**: Documentation cleaned to remove Boneyard references and historical
  mentions. The sorries remain but are now documented as architectural limitations inline.

The mutual induction structure in TruthLemma.lean must be retained because the forward
imp case genuinely requires the backward IH to convert `truth_at psi` to `psi ∈ MCS`
before applying modus ponens.

## Task 741 Analysis (2026-01-29)

Task 741 performed detailed analysis of the witness extraction architecture.
The key finding is that the proof is blocked by the **omega-rule limitation**:

- H-completeness requires: `(∀ s < t, psi ∈ mcs(s)) → H psi ∈ mcs(t)`
- This requires deriving H psi from infinitely many psi instances
- TM logic (and standard proof systems) lack this "omega-rule"
- The IndexedMCSFamily coherence only provides the converse direction

See:
- `Boneyard/Metalogic_v3/TruthLemma/TemporalCompleteness.lean` for infrastructure (sorry'd)
- `specs/741_witness_extraction_architecture_for_backward_truth_lemma/` for research and plan
- `specs/745_move_backward_truth_lemma_to_boneyard/` for Task 745 implementation

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

## Estimated Effort (Blocked)

All approaches analyzed in Task 741 are blocked:
1. **Construction-specific proof**: Lindenbaum is non-deterministic
2. **Semantic bridge**: Circular (would need backward Truth Lemma)
3. **Negation duality**: Doesn't extract witnesses
4. **Finite approximation**: Needs TM compactness (unavailable)

## Reference

- Original location: `Bimodal/Metalogic/Representation/TruthLemma.lean` lines 420-435, 449-459
- Moved infrastructure: `Boneyard/Metalogic_v3/TruthLemma/TemporalCompleteness.lean`
- Gap analysis: `specs/681_redesign_construct_indexed_family_coherent_approach/reports/research-004.md`
- Witness extraction: `specs/741_witness_extraction_architecture_for_backward_truth_lemma/`
- Boneyard cleanup: `specs/745_move_backward_truth_lemma_to_boneyard/`
-/

-- This file is documentation only. No compilable Lean code here.
