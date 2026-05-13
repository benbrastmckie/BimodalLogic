# Implementation Summary: Remove A4a via Xu 3.2.1+3.2.2

- **Task**: 115 - Remove A4a (separation_until/separation_since) for axiom minimality
- **Status**: [COMPLETED]
- **Session**: sess_1778701132_a3d37f
- **Date**: 2026-05-13
- **Plan**: plans/03_remove-a4a-plan.md (v3)

## Changes

### Phase 1: Xu Lemma 2.3 (Guard Strengthening with Top) [COMPLETED]
- Added `xu_lemma_2_3_since_top` and `xu_lemma_2_3_until_top` in PointInsertion.lean
- Proves R(A,B,C) implies S(α,⊤) ∈ B and U(γ,⊤) ∈ B

### Phase 2: Xu Lemma 3.2.1 (Guard Strengthening for Transitive Frames) [COMPLETED]
- Added `xu_lemma_3_2_1_until` and `xu_lemma_3_2_1_since` in PointInsertion.lean
- Proves R(A,B,C) implies U(γ,β) ∈ B for all β ∈ B, γ ∈ C (and dual)
- Uses BX5 (self_accum_until) via contradiction + BurgessR3Maximal_extension_fails
- Strengthens Phase 1 from "top" to "all β ∈ B"

### Phase 3: Xu 3.2.2 Splitting and BX14 Elimination [COMPLETED]
- Replaced `lemma_2_6_splitting` internals with Xu 3.2.2 construction
- Seed simplified from rich D₀ to just B* ∪ {¬β} with trivial consistency
- Established r(A, B*, D) and r(D, B*, C) via Xu 3.2.1
- Output type identical — zero changes to CounterexampleElimination.lean callers
- Removed `separation_until_mcs` helper and all 4 BX14 usage sites
- Removed `burgess_zeta_consistent` and related dead code

### Phase 4: Remove Axiom Constructors and Downstream References [COMPLETED]
- Removed `separation_until` and `separation_since` constructors from Axioms.lean
- Removed `separation_until_valid` and `separation_since_valid` from Soundness.lean
- Removed all match arms in SoundnessLemmas.lean
- Removed match arms in Substitution.lean
- Constructor count: 61 → 43

### Phase 5: Final Verification and Cleanup [COMPLETED]
- `lake build` passes clean (1633 jobs)
- Updated Axioms.lean header (43 constructors)
- Updated ROADMAP.md axiom table (removed BX14/BX14' rows)
- No sorry regressions
- Zero `Axiom.separation_until`/`Axiom.separation_since` references in Theories/

## Verification

- **Lake build**: Success (1633 jobs)
- **Sorry check**: Clean (no regressions)
- **Axiom count**: 0 custom axioms (standard axiom constructors only)
- **Constructor count**: 43 (reduced from 61)

## Key Theorems Added

| Theorem | File | Statement |
|---------|------|-----------|
| `xu_lemma_2_3_since_top` | PointInsertion.lean | R(A,B,C) → S(α,⊤) ∈ B |
| `xu_lemma_2_3_until_top` | PointInsertion.lean | R(A,B,C) → U(γ,⊤) ∈ B |
| `xu_lemma_3_2_1_until` | PointInsertion.lean | R(A,B,C) → U(γ,β) ∈ B for all β ∈ B |
| `xu_lemma_3_2_1_since` | PointInsertion.lean | R(A,B,C) → S(α,β) ∈ B for all β ∈ B |

## Files Modified

- `Theories/Bimodal/ProofSystem/Axioms.lean` — removed 2 constructors, updated header
- `Theories/Bimodal/Metalogic/Soundness.lean` — removed validity theorems and match arms
- `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` — removed match arms
- `Theories/Bimodal/ProofSystem/Substitution.lean` — removed match arms
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — added Xu theorems, replaced splitting
