# Implementation Summary: Z1 Axiom and Doets Gap Elimination (v15)

- **Task**: 123 - fix_c5_witness_bot_and_prove_icc_finite
- **Plan**: plans/12_semantic-z1-gap.md
- **Status**: Partial (Phase 2 completed, Phase 3 not started)
- **Session**: sess_1778635637_869428

## What Was Accomplished

### Phase 1: Add Imports and Prove Order.succ Equality [COMPLETED]
Already completed in prior session.

### Phase 2: Add Z1 Axiom and Prove Soundness [COMPLETED]

**Step 2a**: Added `z1` constructor to `Axiom` inductive type in `Axioms.lean`:
```lean
| z1 (phi : Formula) :
    Axiom ((phi.all_future.imp phi).all_future.imp (phi.all_future.some_future.imp phi.all_future))
```

**Step 2b**: Updated axiom classification predicates:
- `Axiom.frameClass`: z1 => .Discrete
- `Axiom.isBase`: z1 => False
- `Axiom.isDenseCompatible`: z1 => False
- `Axiom.isDiscreteCompatible`: unchanged (wildcard covers z1)

**Step 2c**: Proved Z1 soundness in `SoundnessLemmas.lean`:
- `z1_is_valid`: G(Gphi->phi) -> (FGphi->Gphi) is valid on IsSuccArchimedean discrete orders
- `z1_past_is_valid`: H(Hphi->phi) -> (PHphi->Hphi) is valid on IsPredArchimedean discrete orders
- Both proofs use backward induction from the Gphi/Hphi witness via `exists_succ_iterate`/`exists_pred_iterate` and `Nat.strong_induction_on`

**Step 2d**: Updated ALL pattern matches on Axiom (~8 theorems across 2 files):

In `SoundnessLemmas.lean` (4 isDenseCompatible guards + 2 discrete validity handlers):
- `axiom_swap_valid`: added z1 absurd case
- `axiom_locally_valid`: added z1 absurd case
- `axiom_swap_valid_general`: added z1 absurd case
- `axiom_locally_valid_general`: added z1 absurd case
- `axiom_swap_valid_discrete`: added z1 case using z1_past_is_valid
- `axiom_locally_valid_discrete`: added z1 case using z1_is_valid

In `Soundness.lean` (5 pattern match sites):
- `axiom_base_valid`: added z1 absurd case (not base)
- `axiom_valid_dense`: added z1 absurd case (not dense-compatible)
- `axiom_valid_discrete`: added z1 case using z1_valid
- `soundness` (dense-compatible): added z1 absurd case
- `soundness_dense`: added z1 absurd case

Added `z1_valid` bridge theorem in `Soundness.lean`.

**Step 3a (partial)**: Replaced sorry'd `z1_derivation` with axiom-based version:
```lean
private def z1_derivation (phi : Formula) :
    DerivationTree [] (z1_formula phi) :=
  DerivationTree.axiom [] _ (Axiom.z1 phi)
```
This eliminates the `z1_derivation` sorry in `ChronicleToCountermodel.lean`.

### Phase 3: Doets Maximum Principle and Gap Elimination [NOT STARTED]

The `succ_cofinal` sorry at line 1866 remains. This is the hardest part of the plan.

### Phase 4: Verification and Cleanup [NOT STARTED]

## Modified Files

| File | Changes |
|------|---------|
| `Theories/Bimodal/ProofSystem/Axioms.lean` | Added `z1` constructor + updated classification predicates |
| `Theories/Bimodal/Metalogic/SoundnessLemmas.lean` | Added `z1_is_valid`, `z1_past_is_valid`, updated 6 pattern matches |
| `Theories/Bimodal/Metalogic/Soundness.lean` | Added `z1_valid`, updated 5 pattern matches |
| `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` | Replaced sorry'd `z1_derivation` with axiom-based version |

## Build Status

- `lake build`: passes (1633 jobs, 0 errors)
- No new Lean-level axioms introduced (only the proof-system `Axiom` constructor)
- 1 sorry eliminated (`z1_derivation`)
- `succ_cofinal` sorry remains (Phase 3 target)

## Remaining Work

Phase 3 (gap elimination) requires proving `False` from the gap scenario using Z1 in every MCS. The proof infrastructure is in place (backward_G, backward_F, z1_in_mcs, orbit_below_L, h_lt_pred_chain). The creative step is finding a discriminating formula or showing the constant-MCS case contradicts the construction, then applying the Doets maximum principle.
