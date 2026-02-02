-- Metalogic: Sorry-Free Completeness for TM Logic
-- Updated 2026-02-02 (Task 809: Archive Representation approach)

/-!
# Metalogic for TM Bimodal Logic

This module provides metalogical results for TM bimodal logic, focusing on
completeness, soundness, and decidability.

## Architecture (After Task 809 Archival)

```
Core/                    # MCS theory, provability
  MaximalConsistent.lean
  Provability.lean
  DeductionTheorem.lean

FMP/                     # Finite Model Property (SORRY-FREE)
  SemanticCanonicalModel.lean  # semantic_weak_completeness
  (other FMP infrastructure)

Completeness/            # Completeness theorems
  FiniteStrongCompleteness.lean  # finite_strong_completeness

Soundness/               # Soundness theorem
  Soundness.lean

Decidability/            # Decision procedures
  (FMP-based decidability)
```

## Archived to Boneyard (Task 809)

The following were archived to `Boneyard/Metalogic_v5/` because they contained
or depended on 30+ sorries in the Representation approach:

```
Representation/          # ARCHIVED - contained 30 sorries
  CanonicalWorld.lean
  TaskRelation.lean
  CanonicalHistory.lean
  IndexedMCSFamily.lean
  CoherentConstruction.lean
  TruthLemma.lean
  TruthLemmaForward.lean
  UniversalCanonicalModel.lean

Completeness/ (partial)  # Depended on Representation
  WeakCompleteness.lean
  InfinitaryStrongCompleteness.lean

Compactness/             # Depended on InfinitaryStrongCompleteness
  Compactness.lean
```

## Main Results (Sorry-Free)

### From FMP/
- `semantic_weak_completeness`: Weak completeness via finite model property
- `semanticWorldState_card_bound`: FMP with 2^closureSize bound

### From Completeness/
- `finite_strong_completeness`: Strong completeness for List-based contexts
- `context_provable_iff_entails`: Derivability iff semantic consequence

### From Soundness/
- `soundness`: Derivability implies semantic consequence

## Archived Results (With Trusted Axioms)

The archived Representation approach provided additional results:
- Infinitary strong completeness (Set-based contexts)
- Full compactness theorem
- Universal canonical model construction

These results are mathematically complete but rely on 30+ trusted axioms (sorries)
in auxiliary lemmas.

## References

- FMP approach: `Bimodal.Metalogic.FMP.SemanticCanonicalModel`
- Archived Representation: `Boneyard/Metalogic_v5/`
-/

-- The main imports are via the submodule structure
-- Users should import specific modules:
--   import Bimodal.Metalogic.FMP.SemanticCanonicalModel
--   import Bimodal.Metalogic.Completeness.FiniteStrongCompleteness
--   import Bimodal.Metalogic.Soundness
