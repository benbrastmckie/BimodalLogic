/-!
# Archived: Semantic Canonical Frame and Model (Task 776)

**Archived**: 2026-01-30
**Original Location**: Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean
**Reason**: Contains sorry in compositionality axiom that is mathematically impossible

## Why This Code is Archived

### Sorry #1: SemanticCanonicalFrame.compositionality

The compositionality axiom requires:
  `task_rel w d1 v -> task_rel v d2 u -> task_rel w (d1+d2) u`

This is **mathematically false** for unbounded durations in finite time domain [-k, k]:
- The time domain is bounded: `BoundedTime k = Fin (2*k+1)` representing `[-k, k]`
- When composing, `d1 + d2` can exceed `[-2k, 2k]` - the representable range
- Example: If `k = 3`, we can have `d1 = 6` and `d2 = 6` but `d1 + d2 = 12` is unrepresentable

## Sorry-Free Alternative

Use `semantic_weak_completeness` from the active codebase:

```lean
-- In Theories/Bimodal/Metalogic/FMP/SemanticCanonicalModel.lean
noncomputable def semantic_weak_completeness (phi : Formula) :
    (forall (w : SemanticWorldState phi),
     semantic_truth_at_v2 phi w (BoundedTime.origin (temporalBound phi)) phi) ->
    |- phi
```

This theorem is completely sorry-free and works via contrapositive without
requiring the frame's compositionality axiom.

## Archived Code

The following definitions were moved from SemanticCanonicalModel.lean:
- SemanticCanonicalFrame
- SemanticCanonicalModel
- finiteHistoryToWorldHistory
- semantic_world_state_has_world_history

These are preserved for reference but should not be used for new development.
-/

-- NOTE: This file does not compile. It is preserved as documentation only.
-- The code below shows the original definitions for reference.

/-
namespace Bimodal.Metalogic.FMP

open Bimodal.Syntax Bimodal.ProofSystem Bimodal.Semantics

/--
The semantic canonical frame.

**DEPRECATED (Task 769)**: The `compositionality` field contains a sorry because it is
mathematically false for unbounded durations in finite time domain [-k, k]. This frame
definition is retained for compatibility but should not be used for new development.
Use `semantic_weak_completeness` which avoids this frame entirely.
-/
noncomputable def SemanticCanonicalFrame (phi : Formula) : TaskFrame Int where
  WorldState := SemanticWorldState phi
  task_rel := semantic_task_rel phi
  nullity := semantic_task_rel_nullity phi
  -- Known Limitation: Compositionality is mathematically false for unbounded durations in finite
  -- time domain [-k, k]. Sum d1 + d2 can exceed representable range [-2k, 2k]. Not needed for
  -- completeness proof which uses semantic_weak_completeness via semantic_truth_at_v2.
  compositionality := fun _ _ _ _ _ => sorry

/--
The semantic canonical model.
-/
noncomputable def SemanticCanonicalModel (phi : Formula) :
    TaskModel (SemanticCanonicalFrame phi) where
  valuation := semantic_valuation phi

/--
Convert a finite history to a world history.

The world history has domain [-k, k] where k = temporalBound phi.
-/
def finiteHistoryToWorldHistory (phi : Formula) (h : FiniteHistory phi) :
    WorldHistory (SemanticCanonicalFrame phi) where
  domain := inFiniteDomain phi
  convex := fun x z h_x h_z y h_xy h_yz => by
    unfold inFiniteDomain at h_x h_z ⊢
    constructor <;> omega
  states := fun t h_t =>
    SemanticWorldState.ofHistoryTime h (intToBoundedTime phi t h_t)
  respects_task := fun s t hs ht _h_le => by
    let fs := intToBoundedTime phi s hs
    let ft := intToBoundedTime phi t ht
    use h, fs, ft
    refine ⟨rfl, rfl, ?_⟩
    simp only [BoundedTime.toInt]
    show ((intToBoundedTime phi t ht).val : Int) - (temporalBound phi : Int) -
         (((intToBoundedTime phi s hs).val : Int) - (temporalBound phi : Int)) = t - s
    simp only [intToBoundedTime]
    have h_t_nonneg : 0 ≤ t + (temporalBound phi : Int) := by
      unfold inFiniteDomain at ht; omega
    have h_s_nonneg : 0 ≤ s + (temporalBound phi : Int) := by
      unfold inFiniteDomain at hs; omega
    omega

/--
For any SemanticWorldState w, there exists a WorldHistory containing w at time 0.

This shows that every semantic world state is reachable from some world history,
which is needed to instantiate the `valid` quantifier.
-/
theorem semantic_world_state_has_world_history (phi : Formula) (w : SemanticWorldState phi) :
    ∃ (tau : WorldHistory (SemanticCanonicalFrame phi)) (ht : tau.domain 0),
    tau.states 0 ht = w := by
  let ws := SemanticWorldState.toFiniteWorldState w
  let hist := finite_history_from_state phi ws
  let tau := finiteHistoryToWorldHistory phi hist

  have h_domain : inFiniteDomain phi 0 := by
    unfold inFiniteDomain
    constructor <;> omega

  use tau, h_domain

  rw [SemanticWorldState.eq_iff_toFiniteWorldState_eq]
  rfl

end Bimodal.Metalogic.FMP
-/
