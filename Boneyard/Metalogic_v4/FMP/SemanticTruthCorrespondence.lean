/-!
# ARCHIVED: Semantic Truth Correspondence

**Archived from**: Theories/Bimodal/Metalogic/FMP/SemanticTruthCorrespondence.lean
**Archive date**: 2026-01-30
**Reason**: This file documents the failed attempt to bridge `valid phi` to `semantic_truth_at_v2`.
            The approach is architecturally impossible. See TruthLemmaGap.lean for related documentation.
**Task**: 779

## Why Archived

The file contains 4 sorries documenting an unbridgeable architectural gap:
- `truth_at_semantic_implies_semantic_truth` - core gap
- `truth_correspondence_imp` (2 sorries) - requires MCS maximality
- `truth_correspondence_box_analysis` - requires history quantification

The correct approach is to use `semantic_weak_completeness` which avoids this gap entirely.

## Original Content Below

The original file is preserved below for reference. It explains why the semantic model
embedding approach cannot work.
-/

-- NOTE: This file is archived and NOT part of the active build.
-- The imports below will fail in the Boneyard context.
-- import Bimodal.Metalogic.FMP.SemanticTaskFrame
-- import Bimodal.Metalogic.FMP.SemanticCanonicalModel

/-!
# Semantic Truth Correspondence

This module documents the attempt to bridge `valid phi` to `semantic_truth_at_v2`,
and explains why the approach fails due to an architectural gap.

## Overview

The research (research-002.md) proposed building a TaskModel from SemanticWorldStates
and proving truth correspondence. However, implementation revealed that this approach
faces the same architectural gap as the original forward truth lemma:

**The Gap**: `semantic_truth_at_v2` checks the assignment directly, while `truth_at`
evaluates formulas recursively. These only coincide for MCS-derived world states,
not arbitrary locally-consistent world states.

## Why the Bridge Fails

1. `semantic_truth_at_v2 phi w t psi` = `w.toFiniteWorldState.models psi h_mem`
   = `w.assignment ⟨psi, h_mem⟩ = true`

2. `truth_at (SemanticTaskModel phi) τ t psi` is defined recursively:
   - For atoms: matches assignment (correspondence works)
   - For bot: both False (correspondence works)
   - For imp: `truth_at psi -> truth_at chi` (MAY DIFFER from assignment!)

3. A locally consistent world state can have:
   - assignment(psi->chi) = false
   - assignment(psi) = false
   - assignment(chi) = true
   This is consistent (modus ponens doesn't apply), but truth_at(psi->chi) = true!

4. The mismatch means: valid(phi) doesn't imply semantic_truth_at_v2 for all world states.

## What Works

- `valid_at_semantic_model`: valid phi implies truth_at in SemanticTaskModel (trivial instantiation)
- `truth_correspondence_atom`: Atoms have correspondence in both directions
- `truth_correspondence_bot`: Bot has correspondence (both False)

## What Doesn't Work

- `truth_at_semantic_implies_semantic_truth`: SORRY - the core bridge lemma
- `truth_correspondence_imp` forward direction: Requires MCS-like maximality
- Full truth correspondence: Only works for MCS-derived world states

## Recommendation

The sorry in `weak_completeness` is architectural. Use `semantic_weak_completeness` instead,
which works via contrapositive and only requires MCS-derived world states.

## References

- Task 779: This implementation attempt
- Task 750: Original research on truth lemma gap
- Boneyard/Metalogic_v4/FMP/TruthLemmaGap.lean: Detailed gap documentation
-/
