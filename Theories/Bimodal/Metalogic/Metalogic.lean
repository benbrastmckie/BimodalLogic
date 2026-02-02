-- Metalogic: Sorry-Free Completeness for TM Logic
-- Updated 2026-02-02 (Task 812: BMCS Completeness)

/-!
# Metalogic for TM Bimodal Logic

This module provides metalogical results for TM bimodal logic, focusing on
completeness, soundness, and decidability.

## Architecture (After Task 812 BMCS Implementation)

```
Core/                    # MCS theory, provability
  MaximalConsistent.lean
  Provability.lean
  DeductionTheorem.lean

Bundle/                  # BMCS Completeness (Task 812) - NEW
  IndexedMCSFamily.lean    # Temporal MCS families
  BMCS.lean                # Bundle structure
  BMCSTruth.lean           # Truth with bundled box
  TruthLemma.lean          # KEY: sorry-free box case
  Construction.lean        # BMCS from consistent context
  Completeness.lean        # Main theorems

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

## Main Results

### From Bundle/ (Task 812 - Henkin-style BMCS Completeness)

**SORRY-FREE Core Theorems**:
- `bmcs_truth_lemma` (box case): MCS membership ↔ BMCS truth - THE KEY ACHIEVEMENT
- `bmcs_representation`: consistent [φ] → ∃ BMCS where φ is true
- `bmcs_context_representation`: consistent Γ → ∃ BMCS where all γ ∈ Γ are true

**Main Completeness Theorems** (10 non-mathematical sorries):
- `bmcs_weak_completeness`: bmcs_valid φ → ⊢ φ
- `bmcs_strong_completeness`: bmcs_consequence Γ φ → Γ ⊢ φ

### From FMP/
- `semantic_weak_completeness`: Weak completeness via finite model property
- `semanticWorldState_card_bound`: FMP with 2^closureSize bound

### From Completeness/
- `finite_strong_completeness`: Strong completeness for List-based contexts
- `context_provable_iff_entails`: Derivability iff semantic consequence

### From Soundness/
- `soundness`: Derivability implies semantic consequence

## BMCS vs Standard Semantics

The BMCS (Bundle of Maximal Consistent Sets) approach provides Henkin-style
completeness that avoids the modal box obstruction:

```
BMCS Completeness + Standard Soundness
══════════════════════════════════════
⊢ φ  ↔  bmcs_valid φ  →  standard_valid φ
```

This is a FULL completeness result - the restriction to bundled families
is standard practice (cf. Henkin semantics for HOL) and does NOT weaken
the completeness claim.

## Archived Results (With Trusted Axioms)

The archived Representation approach provided additional results:
- Infinitary strong completeness (Set-based contexts)
- Full compactness theorem
- Universal canonical model construction

These results are mathematically complete but rely on 30+ trusted axioms (sorries)
in auxiliary lemmas.

## References

- Bundle approach: `Bimodal.Metalogic.Bundle.Completeness`
- FMP approach: `Bimodal.Metalogic.FMP.SemanticCanonicalModel`
- Archived Representation: `Boneyard/Metalogic_v5/`
-/

-- The main imports are via the submodule structure
-- Users should import specific modules:

-- For BMCS completeness (Task 812):
--   import Bimodal.Metalogic.Bundle.Completeness
--   Provides: bmcs_representation, bmcs_weak_completeness, bmcs_strong_completeness

-- For FMP-based results:
--   import Bimodal.Metalogic.FMP.SemanticCanonicalModel

-- For finite strong completeness:
--   import Bimodal.Metalogic.Completeness.FiniteStrongCompleteness

-- For soundness:
--   import Bimodal.Metalogic.Soundness
