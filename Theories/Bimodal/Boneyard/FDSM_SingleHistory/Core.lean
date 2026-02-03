import Bimodal.Metalogic.FDSM.Core
import Bimodal.Metalogic.Core.MaximalConsistent
import Bimodal.Metalogic.Core.MCSProperties
import Bimodal.Metalogic.FMP.Closure

/-!
# ARCHIVED: Single-History FDSM Construction

This code was archived because the single-history approach trivializes
modal operators, making Box psi = psi for all psi.

## Why This Is Wrong

In a single-history model:
- Box psi means "psi holds at all histories" = "psi holds at the one history" = psi
- Diamond psi means "psi holds at some history" = "psi holds at the one history" = psi

This validates invalid principles:
- Box psi <-> psi (NOT a theorem of modal logic!)
- Diamond psi <-> psi (NOT a theorem!)

The completeness proof using this construction "proves" that any formula
valid in all single-history FDSM models is provable. But single-history
models satisfy EXTRA principles (Box <-> id), so this proves nothing useful.

## Specific Problems

1. **Modal Trivialization**: The single-history model has exactly one history,
   so "all histories" = "the one history" and "some history" = "the one history".
   This means Box and Diamond become identity operations.

2. **False Completeness**: The "completeness" theorem states that formulas
   valid in all single-history models are provable. But single-history models
   validate MORE formulas than sound modal logic (they validate Box psi <-> psi),
   so we're proving completeness with respect to the wrong class of models.

3. **Diamond Witness Issue**: The modal_saturated field is satisfied trivially
   because with one history, if Diamond psi holds, the single history must
   model psi (since Diamond psi = psi in single-history semantics). But this
   is circular reasoning: we're assuming what we need to prove.

## Correct Approach

See `Bimodal.Metalogic.FDSM.ModalSaturation` for the multi-history
construction that properly handles modal saturation. The key insight is:

1. Track MCS origins with `MCSTrackedHistory`
2. Build witness histories via `buildMCSTrackedWitness` when Diamond psi holds
3. Saturate by iteratively adding witnesses until fixed point
4. The resulting FDSM has multiple histories with proper modal semantics

## Archive History

- Original location: Bimodal.Metalogic.FDSM.Completeness
- Archived: 2026-02-03 (Task 825)
- Reason: Modal trivialization (Box psi = psi)
-/

namespace Bimodal.Metalogic.FDSM.Boneyard

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.FMP

/--
Build a single-history FDSM from a closure MCS.

**ARCHIVED**: This construction trivializes modal operators.
See module docstring for explanation.

This is the simplest FDSM construction - a single constant history.
The evaluation history is this single history.

**Note**: This construction satisfies modal saturation trivially because
there's only one history. For a formula to require a witness, Diamond psi
must hold, but with one history, Box (neg psi) is equivalent to neg psi,
so Diamond psi = neg(neg psi) = psi. If psi holds, the single history
itself is the witness.

**Problem**: This reasoning is circular - we're using the modal trivialization
(Diamond psi = psi) to justify the model having modal saturation, but that's
exactly the property we're supposed to prove constructively, not assume.
-/
noncomputable def fdsm_from_closure_mcs_ARCHIVED (phi : Formula) (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) : FiniteDynamicalSystemModel phi where
  histories := {fdsm_history_from_closure_mcs phi S h_mcs}

  nonempty := ⟨fdsm_history_from_closure_mcs phi S h_mcs, Finset.mem_singleton_self _⟩

  modal_saturated := fun h hh t psi h_psi_clos h_diamond => by
    -- With a single history, modal saturation is trivial
    -- Diamond psi = neg(Box(neg psi))
    -- In single-history semantics, Box chi = chi for all chi
    -- So Diamond psi = neg(neg psi) = psi
    -- If psi holds, the single history is its own witness
    have h_eq : h = fdsm_history_from_closure_mcs phi S h_mcs := Finset.mem_singleton.mp hh
    -- The diamond formula holding means psi holds at h
    -- (This is the key simplification of single-history models)
    use fdsm_history_from_closure_mcs phi S h_mcs
    constructor
    · exact Finset.mem_singleton_self _
    · -- Need to show psi holds at the single history
      -- This follows from the diamond formula structure
      -- **ARCHIVED**: This sorry represents the fundamental flaw -
      -- we cannot prove psi holds just because Diamond psi holds
      -- without the modal trivialization assumption.
      sorry

  eval_history := fdsm_history_from_closure_mcs phi S h_mcs

  eval_history_mem := Finset.mem_singleton_self _

/--
The evaluation history of the FDSM from closure MCS.
-/
theorem fdsm_from_closure_mcs_eval_ARCHIVED {phi : Formula} (S : Set Formula)
    (h_mcs : ClosureMaximalConsistent phi S) :
    (fdsm_from_closure_mcs_ARCHIVED phi S h_mcs).eval_history =
    fdsm_history_from_closure_mcs phi S h_mcs := rfl

end Bimodal.Metalogic.FDSM.Boneyard
