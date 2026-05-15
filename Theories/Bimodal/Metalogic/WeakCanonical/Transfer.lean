import Bimodal.Metalogic.WeakCanonical.IntegerModel
import Bimodal.Metalogic.WeakCanonical.OrderedSum
import Bimodal.Metalogic.Algebraic.ParametricCanonical
import Bimodal.Metalogic.Algebraic.ParametricHistory
import Bimodal.Metalogic.Algebraic.ParametricRepresentation
import Bimodal.Metalogic.Algebraic.RestrictedParametricTruthLemma
import Bimodal.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodel
import Bimodal.Semantics.Validity

/-!
# Z-Model Transfer for the Reflexive Canonical Model

The main theorem: `doets_countermodel_discrete` — a drop-in replacement for
`dd_countermodel_chronicle_discrete` using the Reynolds/Doets compression.

## Architecture

The proof proceeds in three layers:

1. **Chronicle Extraction** (Phase 2, ChronicleExtraction.lean):
   Extract a `ChronicleAsPriorModel` from MCS A with `□(next_top) ∈ A`.
   The chronicle satisfies Reynolds Corollary 3: countable, discrete
   without endpoints, Prior-UZ/SZ valid everywhere.

2. **Reynolds Compression** (Phase 5, IntegerModel.lean):
   Using `chronicle_is_good`, prove that the chronicle is "good" at
   depth `phi.complexity + 1` — meaning it is k-equivalent to a
   Z-structure (carrier = ℤ). This yields `N : ZStructure sig` with
   `k_equiv` to the chronicle.

3. **Truth Transfer** (future work):
   From the k-equivalence, transfer temporal truth of `¬φ` from the
   chronicle to the Z-model N. Package N as a `TaskFrame Int` /
   `TaskModel` counterexample.

## Status

The Reynolds pipeline is structurally complete:
- `chronicle_is_good` is proved (via `one_class` + `very_good_implies_good`)
- `one_class` is proved (via gap elimination chain)
- `finite_structures_good`, `no_boundary_at_successor` proved
- All proofs carry sorry-propagation from `k_type_of` (monadic FO satisfaction)
- Truth transfer (table correctness) remains deferred
- The chronicle fallback provides the working countermodel

## References
- Reynolds 1994, Theorem 18 (full completeness pipeline): `literature/Reynolds_1994_Axiomatising_U_and_S_over_integer_time.md`
- Report 08, Q5 (succ_cofinal bypassed, not proved): `reports/08_phase-by-phase-research.md`
-/
namespace Bimodal.Metalogic.WeakCanonical

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Algebraic.ParametricCanonical
open Bimodal.Metalogic.Algebraic.ParametricHistory
open Bimodal.Semantics

/-! ## Signature and Atom Map Construction -/

/--
Build a `MonadicSignature` from a formula φ. The predicate symbols
are the atoms appearing in φ (represented as `Fin n` where `n` is
the number of distinct atoms).

For the Reynolds pipeline, this signature provides the finite set of
predicates needed for the table translation of φ.
-/
noncomputable def mkSigFrom (φ : Formula) : MonadicSignature where
  preds := φ.predFormulas
  fintypePreds := inferInstance
  decEqPreds := inferInstance

/--
Build an atom map from the signature's predicates to temporal formulas.
Each predicate symbol is a member of `φ.predFormulas` (i.e., either
`Formula.atom a` or `Formula.box ψ`), so the map simply extracts
the underlying formula.

For the Reynolds pipeline, this map connects the monadic structure's
predicate interpretations to the temporal truth of formulas in the MCS.
-/
noncomputable def mkAtomMap (φ : Formula) :
    (mkSigFrom φ).preds → Formula :=
  fun p => p.val

/-! ## Main Theorem: doets_countermodel_discrete -/

/--
Doets/Reynolds discrete countermodel construction.

For any MCS A containing ¬φ and □(next_top) (discrete box-class),
there exists a countermodel on Int where φ is false.

Signature matches `dd_countermodel_chronicle_discrete` exactly,
making this a drop-in replacement at Completeness.lean line 159.

## Reynolds pipeline status (Task 140)

| Step | Description | Status |
|------|-------------|--------|
| 1 | Extract chronicle | READY (`extract_chronicle_as_prior`) |
| 2 | Build signature and atom map | READY (`mkSigFrom`, `mkAtomMap`) |
| 3 | Prove chronicle is good | SORRY (`chronicle_is_good` → `sum_preservation`) |
| 4 | Extract Z-interval | READY (from `good` definition) |
| 5 | Transfer truth via `table_correctness` | PARTIAL (temporal cases need `lift_eval`) |
| 6 | Package Z-model as TaskFrame Int | BLOCKED (ZIntervalStructure → TaskFrame bridge) |

`table` is now implemented (Task 140). `table_depth_bound` is proved.
`table_correctness` is stated and proved for base cases; temporal operator
cases depend on `lift_eval` (sorry-propagating, Task 141 scope).
`mkSigFrom` uses `φ.predFormulas`; `mkAtomMap` uses subtype projection.

The proof still falls back to the chronicle construction. Full pipeline
activation requires: (a) `chronicle_is_good` → `sum_preservation` (Doets 1.4),
(b) ZIntervalStructure → TaskFrame bridge, (c) `lift_eval` proofs.

The dense completeness path is unaffected (uses separate theorem).
-/
theorem doets_countermodel_discrete (A : Set Formula) (h_mcs : SetMaximalConsistent A)
    (φ : Formula) (h_neg_in : φ.neg ∈ A)
    (h_box_discrete : Formula.box next_top ∈ A) :
    ∃ (D : Type) (_ : AddCommGroup D) (_ : LinearOrder D) (_ : IsOrderedAddMonoid D)
      (_ : Nontrivial D) (F : TaskFrame D) (TM : TaskModel F)
      (Omega : Set (WorldHistory F)) (_ : ShiftClosed Omega)
      (τ : WorldHistory F) (_ : τ ∈ Omega) (t : D),
      ¬truth_at TM Omega τ t φ := by
  -- REYNOLDS PIPELINE (Task 140): steps 1-2 now have genuine implementations.
  -- Step 1: Extract chronicle
  -- let M := extract_chronicle_as_prior A h_mcs h_box_discrete
  -- Step 2: Build signature and atom map (READY — mkSigFrom, mkAtomMap redesigned)
  -- let sig := mkSigFrom φ
  -- let aMap := mkAtomMap φ
  -- Step 3: Prove chronicle is good (BLOCKED: requires sum_preservation, Doets 1.4, task 143+)
  -- have h_good := chronicle_is_good M sig aMap (φ.complexity + 1)
  -- Step 4: Extract Z-interval structure from `good`
  -- obtain ⟨Z, h_equiv⟩ := h_good
  -- Step 5: Transfer truth via table_correctness (PARTIAL: temporal cases need lift_eval)
  -- have h_table := table_correctness (Z.toOrdered sig) atomMap_fwd t φ
  -- Step 6: Package Z-model as TaskFrame Int (BLOCKED: ZIntervalStructure → TaskFrame bridge)

  -- FALLBACK: delegate to chronicle construction until truth transfer is complete.
  have h_next_top_eq : next_top = Bimodal.Metalogic.BXCanonical.Chronicle.next_top := rfl
  have h_box_discrete_chronicle : Formula.box Bimodal.Metalogic.BXCanonical.Chronicle.next_top ∈ A := by
    rw [← h_next_top_eq]; exact h_box_discrete
  exact Bimodal.Metalogic.BXCanonical.Chronicle.dd_countermodel_chronicle_discrete
    A h_mcs φ h_neg_in h_box_discrete_chronicle

end Bimodal.Metalogic.WeakCanonical
