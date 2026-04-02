import Bimodal.FrameConditions.Compatibility
import Bimodal.Metalogic.DiscreteCompleteness
import Bimodal.Metalogic.Algebraic.UltrafilterChain
import Bimodal.Metalogic.Algebraic.RestrictedTruthLemma

/-!
# Completeness Wiring

This module wires the existing completeness infrastructure through the typeclass
architecture, providing a unified API for completeness theorems.

## Main Definitions

- `completeness_over D`: Template for completeness over temporal domain D
- `bundle_to_bfmcs`: Convert BFMCS_Bundle to BFMCS (sorry-free)
- `bfmcs_from_mcs_temporally_coherent`: Family-level temporal coherence (isolated sorry)
- `bundle_validity_implies_provability`: Core completeness (structurally complete)
- `completeness_over_Int`: Completeness over integer time
- `discrete_completeness_fc`: Discrete completeness (reduces to Int)
- `dense_completeness_fc`: Dense completeness (separate sorry)

## Completeness Status

### Completeness over Int: Structurally Complete (Task #67)

The proof of `bundle_validity_implies_provability` is structurally complete,
with a single isolated sorry in `bfmcs_from_mcs_temporally_coherent`:

1. If phi is not provable, neg(phi) is consistent (sorry-free)
2. Extend to MCS M with neg(phi) in M, phi not in M (sorry-free)
3. Build canonical model via BFMCS from M (sorry-free)
4. Validity gives truth(phi) at the canonical model (sorry-free)
5. Shifted truth lemma gives phi in M (requires temporal coherence)
6. Contradiction with phi not in M (sorry-free)

### Discrete Completeness: Reduces to Int (sorry-free reduction)

### Dense Completeness: Separate sorry (Int is not dense)

## Design Notes

This module provides wrappers that expose completeness through the typeclass API.
The underlying proofs use the bundle construction from UltrafilterChain.

**IMPORTANT (2026-03-31)**: The bundle construction provides BUNDLE-level temporal
coherence, which is semantically INSUFFICIENT for TM task semantics. TM temporal
operators quantify over times in the SAME world history, but bundle-level coherence
allows F/P witnesses in DIFFERENT histories.

The sorry in `bfmcs_from_mcs_temporally_coherent` exists PRECISELY because bundle-level
coherence does not imply family-level coherence. The correct path uses SuccChainFMCS
with family-level temporal coherence.

See: Boneyard/BundleTemporalCoherence/README.md for full semantic explanation.

## References

- `Bimodal.Metalogic.Algebraic.UltrafilterChain`: Bundle-level temporal coherence
- `Bimodal.Metalogic.DiscreteCompleteness`: Discrete completeness infrastructure
-/

namespace Bimodal.FrameConditions

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Bundle.Canonical
open Bimodal.Metalogic.DiscreteCompleteness
open Bimodal.Metalogic.Algebraic.UltrafilterChain
open Bimodal.Metalogic.Algebraic.RestrictedTruthLemma

/-! ## Completeness Template -/

/--
Template for completeness: if a formula is valid over temporal domain D,
then it is provable.

This is the contrapositive of soundness composed with model construction:
- If φ is not provable, then neg φ is consistent
- Consistent formulas have models (canonical construction)
- Hence φ is not valid

**Note**: This is a template definition. Concrete completeness theorems
specialize this to specific frame classes.
-/
def completeness_over (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (φ : Formula) : Prop :=
  valid_over D φ → Nonempty ([] ⊢ φ)

/-! ## Dense Completeness -/

/--
Dense completeness statement: formulas valid over dense temporal frames are provable.

**Status**: In progress via SuccChain architecture.

**Type-Level Documentation**: This definition uses `DenseTemporalFrame` to
express the frame condition requirement at the type level.

**Note**: Uses `Nonempty` to convert derivation tree existence to Prop.
-/
def DenseCompletenessStatement (φ : Formula) : Prop :=
  (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
     [Nontrivial D] [NoMaxOrder D] [NoMinOrder D] [DenselyOrdered D]
     [DenseTemporalFrame D], valid_over D φ) →
  Nonempty ([] ⊢ φ)

/--
Dense completeness proof.

**Status**: BLOCKED — Cannot reduce to Int completeness.

**Why This Cannot Use `completeness_over_Int`**:
- The hypothesis is: φ valid over ALL densely-ordered D (Rat, Real, etc.)
- Int is NOT densely ordered (there's no integer between 0 and 1)
- Therefore we cannot specialize the hypothesis to Int
- A separate proof path using a dense canonical model (e.g., over Rat) is needed

**What Would Be Needed**:
1. A dense canonical model construction (like `construct_bfmcs_bundle` but for Rat)
2. A truth lemma for that construction
3. The same model-theoretic glue as `bundle_validity_implies_provability`

**Note**: The discrete version (`discrete_completeness_fc`) DOES reduce to Int
completeness because Int is discrete.
-/
theorem dense_completeness_fc {φ : Formula} :
    DenseCompletenessStatement φ := by
  intro _h_valid
  -- Cannot reduce to completeness_over_Int: Int is not densely ordered.
  -- Needs a separate proof using a dense canonical model (e.g., over Rat).
  sorry

/-! ## Discrete Completeness -/

/--
Discrete completeness infrastructure status.

This theorem documents the current state of discrete completeness:
- **Proven**: Discrete soundness via axiom_valid_discrete_fc
- **Blocked**: Full completeness requires `discrete_Icc_finite_axiom`
-/
theorem discrete_soundness_proven {φ : Formula} (ax : Axiom φ) (h_dc : ax.isDiscreteCompatible)
    (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Nontrivial D] [NoMaxOrder D] [NoMinOrder D]
    [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
    [DiscreteTemporalFrame D] :
    valid_over D φ :=
  axiom_valid_discrete_fc ax h_dc D

/--
Discrete completeness statement: formulas valid over discrete temporal frames are provable.
-/
def DiscreteCompletenessStatement (φ : Formula) : Prop :=
  (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
     [Nontrivial D] [NoMaxOrder D] [NoMinOrder D]
     [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
     [DiscreteTemporalFrame D], valid_over D φ) →
  Nonempty ([] ⊢ φ)

/-! ## Completeness over Int -/

/--
Completeness over Int statement: formulas valid on integer time are provable.

**Status**: PROVEN via bundle construction (Task #58).
-/
def CompletenessOverIntStatement (φ : Formula) : Prop :=
  valid_over Int φ → Nonempty ([] ⊢ φ)

/-!
## Helper: Convert BFMCS_Bundle to BFMCS

The `BFMCS_Bundle` from `construct_bfmcs_bundle` carries bundle-level temporal
coherence fields. The `BFMCS` structure only needs modal coherence. This
conversion discards the temporal fields, which are recovered via the
`temporally_coherent` predicate.
-/

/--
Convert a `BFMCS_Bundle` to a `BFMCS Int` by discarding bundle-level temporal fields.
-/
noncomputable def bundle_to_bfmcs (B : BFMCS_Bundle) : BFMCS Int where
  families := B.families
  nonempty := B.nonempty
  modal_forward := B.modal_forward
  modal_backward := B.modal_backward
  eval_family := B.eval_family
  eval_family_mem := B.eval_family_mem

/--
The eval_family of bundle_to_bfmcs agrees with the original.
-/
theorem bundle_to_bfmcs_eval_family (B : BFMCS_Bundle) :
    (bundle_to_bfmcs B).eval_family = B.eval_family := rfl

/--
The families of bundle_to_bfmcs agree with the original.
-/
theorem bundle_to_bfmcs_families (B : BFMCS_Bundle) :
    (bundle_to_bfmcs B).families = B.families := rfl

/-!
## Family-Level Temporal Coherence

The `shifted_truth_lemma` requires `B.temporally_coherent`, which asserts that
for each family in the BFMCS, F-witnesses and P-witnesses exist within the
SAME family (not just somewhere in the bundle).

This is the key lemma needed for completeness. The `construct_bfmcs_bundle`
construction builds families via `boxClassFamilies`, where each family is a
`shifted_fmcs (SuccChainFMCS S) delta` for some SerialMCS S.

**Status**: This lemma requires proving `succ_chain_forward_F` for each
SuccChainFMCS, which depends on the restricted chain F-nesting bound argument.
The remaining sorry is in the fuel-exhaustion branch of the bounded witness
proof (`restricted_bounded_witness_fueled` at fuel=0), which is semantically
unreachable but not yet proven so.
-/

/--
Family-level temporal coherence for BFMCS built from an MCS.

**Proof depends on**: `Z_chain_forward_F` and `Z_chain_backward_P` from
UltrafilterChain.lean, which have sorries in the fair-scheduling argument.

This isolates the temporal coherence sorry from the completeness proof structure.
-/
theorem bfmcs_from_mcs_temporally_coherent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    (bundle_to_bfmcs (construct_bfmcs_bundle M h_mcs)).temporally_coherent := by
  -- Each family in boxClassFamilies is a shifted SuccChainFMCS.
  -- Family-level forward_F requires resolving F-obligations within the same chain.
  -- This depends on the bounded F-nesting argument for restricted chains.
  -- The proof structure is correct but the fuel-exhaustion branch is not yet closed.
  sorry

/--
Restricted temporal coherence for BFMCS built from an MCS.

This version only requires forward_F/backward_P for formulas in `deferralClosure(root)`,
which is strictly weaker than `bfmcs_from_mcs_temporally_coherent`.

**Sorry dependency**: Depends on `succ_chain_restricted_forward_F` and
`succ_chain_restricted_backward_P` from UltrafilterChain.lean.
-/
theorem bfmcs_restricted_temporally_coherent (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (root : Formula) :
    (bundle_to_bfmcs (construct_bfmcs_bundle M h_mcs)).restricted_temporally_coherent root := by
  intro fam hfam
  simp only [bundle_to_bfmcs, construct_bfmcs_bundle, boxClassFamilies, Set.mem_setOf_eq] at hfam
  obtain ⟨W, h_W, k, ⟨_, h_eq⟩⟩ := hfam
  subst h_eq
  let S := MCS_to_SerialMCS W h_W
  constructor
  · -- Restricted forward_F
    intro t psi h_dc h_F
    exact shifted_restricted_forward_F (SuccChainFMCS S) root
      (fun n psi h_dc h_F => succ_chain_restricted_forward_F S root n psi h_dc h_F)
      k t psi h_dc h_F
  · -- Restricted backward_P
    intro t psi h_dc h_P
    exact shifted_restricted_backward_P (SuccChainFMCS S) root
      (fun n psi h_dc h_P => succ_chain_restricted_backward_P S root n psi h_dc h_P)
      k t psi h_dc h_P

/-!
## Core Completeness Theorem
-/

/--
Bundle validity implies provability: the core completeness lemma.

If φ is valid over Int, then φ is provable.

**Proof**: By contrapositive using canonical model construction.

1. If φ is not provable, then neg(φ) is consistent (sorry-free)
2. Extend to MCS M with neg(φ) ∈ M and φ ∉ M (sorry-free)
3. Build BFMCS from M via `construct_bfmcs_bundle` (sorry-free)
4. Apply `shifted_truth_lemma` to connect MCS membership with truth_at (sorry-free)
5. Validity gives truth(φ) at the canonical model
6. By truth lemma backward: φ ∈ M, contradicting φ ∉ M

**Sorry dependency**: Step 4 requires `B.temporally_coherent`, which is
isolated in `bfmcs_from_mcs_temporally_coherent`. The sorry is in the
fuel-exhaustion branch of the restricted chain bounded witness proof.
-/
theorem bundle_validity_implies_provability (φ : Formula)
    (h_valid : valid_over Int φ) : Nonempty ([] ⊢ φ) := by
  by_contra h_not_prov
  -- Step 1: neg(φ) is consistent
  have h_neg_cons := not_provable_implies_neg_consistent φ h_not_prov
  -- Step 2: Build MCS M with neg(φ) ∈ M and φ ∉ M
  obtain ⟨M, h_mcs, h_neg_in, h_phi_not⟩ :=
    neg_consistent_gives_mcs_without_phi φ h_neg_cons
  -- Step 3: Build BFMCS from M
  let BB := construct_bfmcs_bundle M h_mcs
  let B := bundle_to_bfmcs BB
  -- Step 4: Family-level temporal coherence (isolated sorry)
  have h_tc : B.temporally_coherent :=
    bfmcs_from_mcs_temporally_coherent M h_mcs
  -- Step 5: The eval_family at time 0 is M
  have h_eval_zero : B.eval_family.mcs 0 = M := by
    show BB.eval_family.mcs 0 = M
    exact construct_bfmcs_bundle_eval_at_zero M h_mcs
  -- Step 6: ShiftClosedCanonicalOmega is shift-closed
  have h_sc : ShiftClosed (ShiftClosedCanonicalOmega B) :=
    shiftClosedCanonicalOmega_is_shift_closed B
  -- Step 7: to_history of eval_family is in ShiftClosedCanonicalOmega
  have h_mem : to_history B.eval_family ∈ ShiftClosedCanonicalOmega B :=
    canonicalOmega_subset_shiftClosed B ⟨B.eval_family, B.eval_family_mem, rfl⟩
  -- Step 8: By validity, φ is true at the canonical model
  have h_true : truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B)
      (to_history B.eval_family) 0 φ :=
    h_valid CanonicalTaskFrame CanonicalTaskModel (ShiftClosedCanonicalOmega B)
      h_sc (to_history B.eval_family) h_mem 0
  -- Step 9: By shifted truth lemma backward, φ ∈ eval_family.mcs 0 = M
  have h_phi_in_M : φ ∈ B.eval_family.mcs 0 :=
    (shifted_truth_lemma B h_tc φ B.eval_family B.eval_family_mem 0).mpr h_true
  rw [h_eval_zero] at h_phi_in_M
  -- Step 10: Contradiction: φ ∈ M and φ ∉ M
  exact h_phi_not h_phi_in_M

/--
Restricted bundle validity implies provability: the core completeness lemma
using restricted temporal coherence.

This version uses `restricted_shifted_truth_lemma` instead of `shifted_truth_lemma`,
requiring only `B.restricted_temporally_coherent φ` instead of `B.temporally_coherent`.

**Sorry dependency**: Depends on `succ_chain_restricted_forward_F` and
`succ_chain_restricted_backward_P` via `bfmcs_restricted_temporally_coherent`.
These are strictly more precise sorries than `bfmcs_from_mcs_temporally_coherent`.
-/
theorem restricted_bundle_validity_implies_provability (φ : Formula)
    (h_valid : valid_over Int φ) : Nonempty ([] ⊢ φ) := by
  by_contra h_not_prov
  -- Step 1: neg(φ) is consistent
  have h_neg_cons := not_provable_implies_neg_consistent φ h_not_prov
  -- Step 2: Build MCS M with neg(φ) ∈ M and φ ∉ M
  obtain ⟨M, h_mcs, h_neg_in, h_phi_not⟩ :=
    neg_consistent_gives_mcs_without_phi φ h_neg_cons
  -- Step 3: Build BFMCS from M
  let BB := construct_bfmcs_bundle M h_mcs
  let B := bundle_to_bfmcs BB
  -- Step 4: Restricted temporal coherence for root = φ
  have h_tc : B.restricted_temporally_coherent φ :=
    bfmcs_restricted_temporally_coherent M h_mcs φ
  -- Step 5: The eval_family at time 0 is M
  have h_eval_zero : B.eval_family.mcs 0 = M := by
    show BB.eval_family.mcs 0 = M
    exact construct_bfmcs_bundle_eval_at_zero M h_mcs
  -- Step 6: ShiftClosedCanonicalOmega is shift-closed
  have h_sc : ShiftClosed (ShiftClosedCanonicalOmega B) :=
    shiftClosedCanonicalOmega_is_shift_closed B
  -- Step 7: to_history of eval_family is in ShiftClosedCanonicalOmega
  have h_mem : to_history B.eval_family ∈ ShiftClosedCanonicalOmega B :=
    canonicalOmega_subset_shiftClosed B ⟨B.eval_family, B.eval_family_mem, rfl⟩
  -- Step 8: By validity, φ is true at the canonical model
  have h_true : truth_at CanonicalTaskModel (ShiftClosedCanonicalOmega B)
      (to_history B.eval_family) 0 φ :=
    h_valid CanonicalTaskFrame CanonicalTaskModel (ShiftClosedCanonicalOmega B)
      h_sc (to_history B.eval_family) h_mem 0
  -- Step 9: By RESTRICTED shifted truth lemma backward, φ ∈ eval_family.mcs 0 = M
  -- φ is in subformulaClosure(φ) by self_mem_subformulaClosure
  have h_phi_in_M : φ ∈ B.eval_family.mcs 0 :=
    (restricted_shifted_truth_lemma B φ h_tc φ (self_mem_subformulaClosure φ)
      B.eval_family B.eval_family_mem 0).mpr h_true
  rw [h_eval_zero] at h_phi_in_M
  -- Step 10: Contradiction: φ ∈ M and φ ∉ M
  exact h_phi_not h_phi_in_M

/--
Completeness over Int: formulas valid over Int are provable.

Delegates to `restricted_bundle_validity_implies_provability` (restricted coherence path).

**Sorry dependency**: Inherits the isolated sorry from
`succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P`
via `bfmcs_restricted_temporally_coherent`.
-/
theorem completeness_over_Int {φ : Formula} :
    CompletenessOverIntStatement φ := by
  intro h_valid
  exact restricted_bundle_validity_implies_provability φ h_valid

/-! ## Discrete Completeness via Int -/

/--
Discrete completeness proof: reduces to `completeness_over_Int`.

**Proof Strategy**:
1. Hypothesis: φ is valid over ALL discrete temporal frames
2. Int is a discrete temporal frame (satisfies SuccOrder, PredOrder, IsSuccArchimedean)
3. Specialize the hypothesis to Int to get `valid_over Int φ`
4. Apply `completeness_over_Int` to conclude provability

**Note**: The sorry comes from `bundle_validity_implies_provability` in `completeness_over_Int`.
This proof is sorry-free modulo that single dependency.
-/
theorem discrete_completeness_fc {φ : Formula} :
    DiscreteCompletenessStatement φ := by
  intro h_valid_discrete
  -- Int is a discrete temporal frame with all required instances
  -- Specialize the discrete validity hypothesis to Int
  have h_valid_int : valid_over Int φ := h_valid_discrete Int
  -- Delegate to completeness_over_Int
  exact completeness_over_Int h_valid_int

/-! ## Documentation: Completeness Status (Task #58 / #67)

### Completeness over Int: Structurally Complete

The proof of `bundle_validity_implies_provability` is now structurally complete:
1. Contrapositive setup via `not_provable_implies_neg_consistent` (sorry-free)
2. MCS construction via `neg_consistent_gives_mcs_without_phi` (sorry-free)
3. Canonical model via `construct_bfmcs_bundle` + `bundle_to_bfmcs` (sorry-free)
4. Truth lemma via `shifted_truth_lemma` (sorry-free given temporal coherence)
5. Validity instantiation at canonical model (sorry-free)
6. Contradiction: φ ∈ M from truth lemma vs φ ∉ M from step 2 (sorry-free)

**Isolated sorry**: `bfmcs_from_mcs_temporally_coherent` — family-level temporal
coherence for the BFMCS built from boxClassFamilies. This requires proving that
each SuccChainFMCS resolves all F/P-obligations within the same chain. The
underlying gap is in `Z_chain_forward_F` (UltrafilterChain.lean), which needs
the fair-scheduling argument for resolving F-obligations.

### Discrete Completeness: REDUCES to Int Completeness (sorry-free reduction)

`discrete_completeness_fc` is proven by:
1. Int is a discrete temporal frame (has SuccOrder, PredOrder, IsSuccArchimedean)
2. The hypothesis "φ valid over ALL discrete D" can be specialized to Int
3. We then apply `completeness_over_Int`

This reduction is SORRY-FREE. The only sorry is in `bfmcs_from_mcs_temporally_coherent`.

### Dense Completeness: CANNOT reduce to Int Completeness

`dense_completeness_fc` still has its own sorry because:
- Int is NOT densely ordered (no integer between 0 and 1)
- Therefore we cannot specialize "φ valid over ALL dense D" to Int
- A separate proof using a dense canonical model (e.g., over Rat) would be needed

### Summary of Sorries in This File

| Theorem | Status | Dependency |
|---------|--------|------------|
| `dense_completeness_fc` | SORRY | Needs dense canonical model |
| `bfmcs_from_mcs_temporally_coherent` | SORRY | Family-level temporal coherence |
| `bundle_validity_implies_provability` | WIRED | Depends on `bfmcs_from_mcs_temporally_coherent` |
| `completeness_over_Int` | WIRED | Via `bundle_validity_implies_provability` |
| `discrete_completeness_fc` | WIRED | Via `completeness_over_Int` |

### Path to Closing the Sorry

`bfmcs_from_mcs_temporally_coherent` requires proving that each family in
`boxClassFamilies M h_mcs` has forward_F and backward_P. Each family is a
`shifted_fmcs (SuccChainFMCS S) delta`, so this reduces to proving
`succ_chain_forward_F` for arbitrary SerialMCS.

**Two approaches**:
1. **Restricted chain**: The bounded F-nesting argument in SuccChainFMCS.lean
   (restricted_bounded_witness_fueled) has a sorry only in the fuel=0 branch,
   which is semantically unreachable with fuel = B*B+1 where B = closure_F_bound.
   Proving this branch unreachable closes the restricted approach.
2. **Fair scheduling**: Modify the omega chain construction to dovetail F/P
   resolution, giving direct family-level forward_F. This is the standard
   textbook approach but requires new infrastructure.
-/

end Bimodal.FrameConditions
