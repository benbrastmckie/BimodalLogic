import Bimodal.FrameConditions.Compatibility
import Bimodal.Metalogic.DiscreteCompleteness

/-!
# Completeness Wiring

This module wires the existing completeness infrastructure through the typeclass
architecture, providing a unified API for completeness theorems.

## Main Definitions

- `completeness_over D`: Template for completeness over temporal domain D
- `dense_completeness_fc`: Dense completeness using typeclass constraints
- `discrete_completeness_fc`: Discrete completeness using typeclass constraints

## Completeness Status

### Dense Completeness: IN PROGRESS (SuccChain Architecture)

Dense completeness is being rebuilt using the SuccChain architecture.
See `Bimodal.Metalogic.SuccChain/` for the current approach.

### Discrete Completeness: BLOCKED by `discrete_Icc_finite_axiom`

The discrete completeness proof depends on `discrete_Icc_finite_axiom`.
This axiom asserts finiteness of closed intervals in the discrete timeline quotient.

**Technical Debt Status**: Per proof-debt-policy.md, this axiom is documented
technical debt. Analysis confirmed the covering lemma gap is fundamental:
- DF axiom creates existential F-obligations witnessable by any MCS
- The syntactic-to-structural gap cannot be bridged
- User will return to address this debt in a future task

## Design Notes

This module provides wrappers that expose completeness through the typeclass API.
The underlying proofs are unchanged; we simply add the typeclass constraints to
the type signatures for cleaner integration with the FrameConditions architecture.

## References

- `Bimodal.Metalogic.SuccChain/`: Current completeness approach
- `Bimodal.Metalogic.DiscreteCompleteness`: Discrete completeness infrastructure
-/

namespace Bimodal.FrameConditions

open Bimodal.Syntax
open Bimodal.Semantics
open Bimodal.ProofSystem
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.DiscreteCompleteness

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

The proof structure:
1. If φ not provable, then neg φ is consistent
2. Extend neg φ to MCS via Lindenbaum
3. Build model from that MCS using SuccChain construction
4. By hypothesis, φ is valid over the model
5. By truth lemma, φ is NOT valid over the model
6. Contradiction

**Status**: Blocked pending SuccChain completeness integration.
-/
theorem dense_completeness_fc {φ : Formula} :
    DenseCompletenessStatement φ := by
  intro _h_valid
  -- Blocked pending SuccChain completeness integration
  -- See SuccChain/ for current development
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

**Status**: BLOCKED by `discrete_Icc_finite_axiom` (documented debt).
-/
def DiscreteCompletenessStatement (φ : Formula) : Prop :=
  (∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
     [Nontrivial D] [NoMaxOrder D] [NoMinOrder D]
     [SuccOrder D] [PredOrder D] [IsSuccArchimedean D]
     [DiscreteTemporalFrame D], valid_over D φ) →
  Nonempty ([] ⊢ φ)

/--
Discrete completeness proof (blocked by discrete_Icc_finite_axiom).

**Technical Debt Reference**:
- Root cause: DF axiom creates existential obligations witnessable by any MCS
- Resolution: Future task after FrameConditions refactor complete
-/
theorem discrete_completeness_fc {φ : Formula} :
    DiscreteCompletenessStatement φ := by
  intro _h_valid
  -- Blocked by discrete_Icc_finite_axiom dependency
  -- See DiscreteCompleteness.lean for details
  sorry

/-! ## Completeness over Int -/

/--
Completeness over Int statement: formulas valid on integer time are provable.

**Status**: Blocked by discrete completeness (inherits `discrete_Icc_finite_axiom` dependency).
-/
def CompletenessOverIntStatement (φ : Formula) : Prop :=
  valid_over Int φ → Nonempty ([] ⊢ φ)

/--
Completeness over Int (blocked by discrete completeness).
-/
theorem completeness_over_Int {φ : Formula} :
    CompletenessOverIntStatement φ := by
  intro _h_valid
  -- Inherits discrete completeness dependency
  sorry

/-! ## Documentation: Axiom Dependencies in Completeness

### Dense Completeness: IN PROGRESS (SuccChain)

Dense completeness is being rebuilt using the SuccChain architecture.
The StagedConstruction approach has been archived.
See proof-debt-policy.md for archival details.

### Discrete Completeness: ONE DOCUMENTED AXIOM

The discrete completeness proof requires:
- `discrete_Icc_finite_axiom`: Finiteness of closed intervals in DiscreteTimelineQuot

This axiom is documented technical debt per proof-debt-policy.md:
```lean
axiom discrete_Icc_finite_axiom
    (root_mcs : Set Formula) (root_mcs_proof : SetMaximalConsistent root_mcs)
    (a b : DiscreteTimelineQuot root_mcs root_mcs_proof) :
    (Set.Icc a b).Finite
```

**Why it's needed**: The covering lemma for SuccOrder requires proving that
any point strictly between `a` and `Order.succ a` is empty. This depends on
showing that the interval `[a, succ a]` is finite (contains exactly 2 points).

**Why it can't be proven**: Research exhaustively explored all
approaches. The fundamental gap: DF axiom creates existential F-obligations
witnessable by *any* MCS, not specifically the alleged intermediate. The
syntactic (DF membership) to structural (covering property) bridge fails.

**Note**: The discrete_Icc_finite_axiom has been archived. Discrete
completeness requires a fundamentally different approach.
-/

end Bimodal.FrameConditions
