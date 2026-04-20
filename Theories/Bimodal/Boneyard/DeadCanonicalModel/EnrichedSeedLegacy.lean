/-!
# Enriched Seed Legacy — Dead Code Archive

These definitions and theorems were removed from
`Theories/Bimodal/Metalogic/BXCanonical/CanonicalModel.lean` during
Phase 1 of task 109 (2026-04-20).

They are NOT on the active completeness path.  The active path uses
`fwd_succ` with seed `g_content(M)` alone (consistent via seriality),
and `bwd_pred` with seed `h_content(M)` alone.

The `f_carry` / `p_carry` concepts (F-formulas / P-formulas literally
present in an MCS) were explored as a way to preserve F-obligations
through non-resolving chain steps.  They are mathematically sound as
definitions, but:

1. `enriched_seed_consistent` / `enriched_past_seed_consistent`:
   Under irreflexive semantics g_content(M) ⊆ M does NOT hold (BX1
   removed), so the old proof sketch is invalid.  Under the enriched
   seed approach this is also a dead end — see ROADMAP.md "Dead Ends"
   items #13 / #31.

2. `fwd_succ_f_carry` / `bwd_pred_p_carry`:
   Under irreflexive semantics the non-resolving fwd_succ branch seeds
   with g_content(M) alone, so f_carry is NOT preserved.  This was
   the correct observation; however the theorem is vacuously false in
   the current construction.

See ROADMAP.md for the definitive analysis of why the enriched-seed
approach is blocked.
-/

-- Dead code — NOT imported by the main Theories build.
-- Imports listed here for reference only; do not uncomment without
-- re-checking the current module structure.

-- import Bimodal.Metalogic.BXCanonical.CanonicalChain
-- import Bimodal.Metalogic.BXCanonical.TruthLemma
-- import Bimodal.Metalogic.Bundle.FMCSDef

-- namespace Bimodal.Metalogic.BXCanonical
-- open Bimodal.Syntax
-- open Bimodal.Metalogic.Core

/-! ## F-carry: F-formulas from an MCS (dead code) -/

-- /-- The set of F-formulas (some_future χ) that are in M. -/
-- def f_carry (M : Set Formula) : Set Formula :=
--   {φ ∈ M | ∃ χ, φ = Formula.some_future χ}
--
-- theorem f_carry_subset (M : Set Formula) : f_carry M ⊆ M :=
--   fun _ h => h.1

-- /-- The enriched non-resolving seed: g_content(M) ∪ f_carry(M) consistent.
-- Under irreflexive semantics, g_content(M) ⊆ M does not follow from BX1.
-- Dead end — see ROADMAP.md #13/#31. -/
-- theorem enriched_seed_consistent {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
--     SetConsistent (g_content M ∪ f_carry M) := by
--   sorry

-- /-- Under irreflexive semantics, f_carry is NOT preserved at non-resolving steps.
-- Dead code — not on the active completeness path. -/
-- theorem fwd_succ_f_carry (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula)
--     (h_not_F : Formula.some_future ψ ∉ M) :
--     f_carry M ⊆ fwd_succ M h_mcs ψ := by
--   sorry

/-! ## P-carry: P-formulas from an MCS (dead code) -/

-- /-- The set of P-formulas (some_past χ) that are in M. -/
-- def p_carry (M : Set Formula) : Set Formula :=
--   {φ ∈ M | ∃ χ, φ = Formula.some_past χ}
--
-- theorem p_carry_subset (M : Set Formula) : p_carry M ⊆ M :=
--   fun _ h => h.1

-- /-- The enriched non-resolving seed for backward: h_content(M) ∪ p_carry(M) consistent.
-- Dead end — symmetric to enriched_seed_consistent. -/
-- theorem enriched_past_seed_consistent {M : Set Formula} (h_mcs : SetMaximalConsistent M) :
--     SetConsistent (h_content M ∪ p_carry M) := by
--   sorry

-- /-- Under irreflexive semantics, p_carry is NOT preserved at non-resolving backward steps.
-- Dead code — not on the active completeness path. -/
-- theorem bwd_pred_p_carry (M : Set Formula) (h_mcs : SetMaximalConsistent M) (ψ : Formula)
--     (h_not_P : Formula.some_past ψ ∉ M) :
--     p_carry M ⊆ bwd_pred M h_mcs ψ := by
--   sorry

-- end Bimodal.Metalogic.BXCanonical
