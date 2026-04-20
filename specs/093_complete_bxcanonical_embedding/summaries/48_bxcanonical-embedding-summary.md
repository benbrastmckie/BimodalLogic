# Implementation Summary: Task #93

- **Task**: 93 - Complete BXCanonical embedding (irreflexive semantics switch)
- **Status**: [PARTIAL]
- **Started**: 2026-04-19
- **Completed**: 2026-04-19
- **Effort**: ~3 hours
- **Dependencies**: Task 92 (truth lemma sorry-free)
- **Artifacts**: plans/48_bxcanonical-embedding.md
- **Standards**: status-markers.md, artifact-management.md, tasks.md, summary-format.md

## Overview

Implemented Phase 1 of the irreflexive semantics switch for the BX bimodal logic proof system. Changed the semantic foundation from reflexive (≤) to irreflexive (<) temporal quantification with open guard semantics for Until and Since. This is a foundational change that affects every file using `truth_at`.

## What Changed

- **Truth.lean**: Changed `all_future` from `t ≤ s` to `t < s`, `all_past` from `s ≤ t` to `s < t`, Until witness from `t ≤ s` to `t < s` with open guard `t < r` (was `t ≤ r`), Since witness from `s ≤ t` to `s < t` with open guard `r < t` (was `r ≤ t`). Updated all TimeShift proofs.
- **Axioms.lean**: Removed `temp_t_future` (BX1), `temp_t_past` (BX1'), `refl_intro_until` (BX8), `refl_intro_since` (BX8'). Added `serial_future` (⊤ → F(⊤)), `serial_past` (⊤ → P(⊤)), `until_step` (φ ∧ F(φ U ψ) → φ U ψ), `since_step` (φ ∧ P(φ S ψ) → φ S ψ). Axiom count: 37 → 35.
- **Soundness.lean**: Updated all validity proofs. `temp_4_valid` uses `lt_trans` instead of `le_trans`. `density_valid` uses `exists_between` (DenselyOrdered). Updated all case match tables. Sorry'd seriality and step axiom validity proofs (require frame conditions).
- **SoundnessLemmas.lean**: Sorry'd `axiom_swap_valid`, `axiom_swap_valid_general`, `axiom_locally_valid`, `axiom_locally_valid_general`, and helper proofs. These need mechanical ≤ → < updates throughout.
- **TemporalDerived.lean**: Sorry'd all BX1-dependent theorems (`G_bot_absurd`, `H_bot_absurd`, `density_derivable`, `refl_F`, `refl_P`, `psi_imp_until`, `psi_imp_since`).
- **Frame.lean**: Sorry'd `bx_le_refl` (no longer valid under irreflexive semantics), `g_content_set_consistent`, `bx_H_backward`.
- **SuccRelation.lean**: Sorry'd `g_content_subset_mcs`, `h_content_subset_mcs`.
- **ParametricTruthLemma.lean**: Sorry'd `parametric_canonical_truth_lemma`, `parametric_shifted_truth_lemma`.

## Decisions

- Chose **open guard** semantics (t, s) for Until and (s, t) for Since, matching standard Burgess 1984 formulation. This makes BX2/BX3 (monotonicity) valid but invalidates BX9 (until_elim: φ U ψ → φ ∨ ψ) since the guard no longer includes the current time.
- BX9 is sorry'd but BX10 (φ U ψ → F(ψ)) remains valid and is the critical axiom for completeness.
- Seriality axioms require frame conditions (NoMaxOrder/NoMinOrder) so are sorry'd in the universal validity proof but will be valid on the canonical model.

## Impacts

- 41 compilation errors remain in 6 downstream files (expected, to be addressed in Phase 2+)
- Key files affected: TruthLemma.lean, SigmaOrdering.lean, Construction.lean, Compatibility.lean, RestrictedParametricTruthLemma.lean, SuccExistence.lean
- Many theorems now sorry'd that were previously sorry-free -- this is expected and planned

## Follow-ups

- Phase 2: Repair Frame.lean and CanonicalModel.lean (remove bx_le_refl usage, use seriality)
- Fix remaining 41 compilation errors in downstream files
- Re-prove sorry'd SoundnessLemmas proofs with < instead of ≤ (mechanical but tedious)
- Re-prove TemporalDerived theorems using seriality instead of BX1

## References

- `specs/093_complete_bxcanonical_embedding/plans/48_bxcanonical-embedding.md`
- `specs/093_complete_bxcanonical_embedding/reports/48_team-research.md`
- `Theories/Bimodal/Semantics/Truth.lean`
- `Theories/Bimodal/ProofSystem/Axioms.lean`
