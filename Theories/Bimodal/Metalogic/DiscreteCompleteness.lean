import Bimodal.Metalogic.Bundle.CanonicalConstruction
import Bimodal.Metalogic.Bundle.CanonicalFMCS
import Bimodal.Metalogic.Bundle.BFMCS
import Bimodal.Metalogic.DiscreteSoundness
import Bimodal.Semantics.Validity
import Bimodal.ProofSystem.Derivation

/-!
# Discrete Completeness - Completeness Framework for Discrete TM Logic

This module provides the completeness framework for the discrete temporal fragment
of bimodal logic TM (using base axioms plus discreteness and seriality axioms).

## Main Results

- `discrete_soundness_export`: All discrete-compatible axioms are valid on discrete orders
- `discrete_completeness_infrastructure`: Documents available infrastructure and gaps

## Required Axioms for Discrete Logic

The discrete proof system uses base axioms plus:
- `discreteness_forward`: DF = `(F⊤ ∧ φ ∧ Hφ) → F(Hφ)` (SuccOrder)
- `seriality_future`: `F(¬⊥)` (NoMaxOrder)
- `seriality_past`: `P(¬⊥)` (NoMinOrder)

The backward discreteness axiom DP is DERIVABLE from DF via temporal duality.

## Infrastructure Status

### Proven Components

1. **Discrete Soundness** (`DiscreteSoundness.lean`):
   All discrete-compatible axioms valid on discrete orders

2. **Base Truth Lemma** (`CanonicalConstruction.lean`):
   MCS membership ↔ semantic truth for Int-indexed model

3. **Temporal Coherent FMCS** (`CanonicalFMCS.lean`):
   Any consistent context extends to temporal coherent family

### Task 974 Dependencies (Blocked Components)

The discrete completeness requires SuccOrder/PredOrder instances for the
canonical discrete timeline. These are proven in `DiscreteTimeline.lean` but
currently have sorries awaiting Task 974:

1. **SuccOrder DiscreteTimelineQuot**: Immediate successor operation
2. **PredOrder DiscreteTimelineQuot**: Immediate predecessor operation
3. **IsSuccArchimedean DiscreteTimelineQuot**: Finite step reachability

**Root Cause**: The `succ_le_of_lt` coverness lemma in DiscreteTimeline.lean,
which establishes that the discreteness axiom DF implies no strict intermediate
elements between adjacent points.

## Domain Consideration for Discrete Completeness

Unlike dense completeness (which needs `D ≃o ℚ`), discrete completeness needs
`D ≃o ℤ`. The characterization theorem requires:
- `LinearOrder D`
- `SuccOrder D`
- `PredOrder D`
- `NoMaxOrder D` and `NoMinOrder D`
- `IsSuccArchimedean D`

When task 974 completes, DiscreteTimelineQuot will satisfy all these properties,
enabling the ℤ isomorphism via Mathlib's `orderIsoIntOfLinearSuccPredArch`.

## References

- Task 974: Prove SuccOrder/PredOrder for discrete timeline
- Task 977: Current organization task
- `DiscreteTimeline.lean`: Discrete timeline construction (with sorries)
- `DiscreteSoundness.lean`: Discrete soundness (proven)
-/

namespace Bimodal.Metalogic.DiscreteCompleteness

open Bimodal.Syntax
open Bimodal.ProofSystem
open Bimodal.Semantics
open Bimodal.Metalogic.Core
open Bimodal.Metalogic.Bundle
open Bimodal.Metalogic.Bundle.Canonical

/-!
## Discrete Completeness Statement

The discrete completeness theorem states that validity over discrete temporal
orders implies provability using the discrete axiom set.

### Formal Statement

```
theorem completeness_discrete (φ : Formula) :
    valid_discrete φ → Nonempty (⊢_discrete φ)
```

where `⊢_discrete φ` means derivable using base axioms plus DF, SF, SP.

### Proof Sketch (Contrapositive)

1. Assume φ is not derivable in the discrete proof system
2. Then [φ.neg] is consistent (otherwise φ would be derivable)
3. By Lindenbaum: extend [φ.neg] to MCS S₀
4. Build DiscreteTimelineQuot from S₀ (the discrete canonical domain)
5. By ℤ-characterization: DiscreteTimelineQuot ≃o ℤ
6. Build TaskFrame over ℤ with discrete structure
7. By truth lemma: φ.neg true at evaluation point
8. Contradiction: valid_discrete φ but φ false at discrete model

### Gap (Steps 4-5)

Step 4 requires SuccOrder/PredOrder for DiscreteTimelineQuot.
Step 5 uses Mathlib's `orderIsoIntOfLinearSuccPredArch`.

Both are blocked by task 974 sorries in DiscreteTimeline.lean.
-/

/-!
## Soundness Re-exports

These provide the proven direction: derivability implies validity.
-/

/--
The forward discreteness axiom DF is valid over all discrete temporal orders.
Re-export from DiscreteSoundness.lean.
-/
theorem discreteness_forward_valid_discrete (φ : Formula) :
    valid_discrete (Formula.and (Formula.bot.neg.some_future)
      (Formula.and φ (Formula.all_past φ)) |>.imp
      (Formula.all_past φ).some_future) :=
  DiscreteSoundness.discreteness_forward_sound_discrete φ

/--
All discrete-compatible axioms are valid over discrete temporal orders.
Re-export from DiscreteSoundness.lean.
-/
theorem axiom_discrete_sound {φ : Formula} (h : Axiom φ) (h_dc : h.isDiscreteCompatible) :
    valid_discrete φ :=
  DiscreteSoundness.axiom_discrete_valid h h_dc

/-!
## Infrastructure for Completeness (Int-Based)

The base infrastructure uses Int for the canonical construction. While Int does
not have a `SuccOrder` instance in Mathlib (since it is more naturally viewed as
a dense-like domain for the reals), discrete completeness requires a domain with
actual SuccOrder structure.

**Key Point**: The canonical domain for discrete completeness is NOT Int directly.
Instead, it should be DiscreteTimelineQuot (from DiscreteTimeline.lean), which
is the quotient of the staged timeline construction with no density intermediates.
This quotient IS discretely ordered when DF is in the axiom system.

The Int-based truth lemma below can be used as a template, but the actual discrete
completeness proof requires the DiscreteTimelineQuot domain (blocked by task 974).
-/

/--
Re-export: The canonical truth lemma for Int-based BFMCS.
This provides a template for the discrete completeness truth lemma.
-/
theorem discrete_base_truth_lemma
    (B : BFMCS Int) (h_tc : B.temporally_coherent)
    (fam : FMCS Int) (hfam : fam ∈ B.families)
    (t : Int) (φ : Formula) :
    φ ∈ fam.mcs t ↔
      truth_at CanonicalTaskModel (CanonicalOmega B) (to_history fam) t φ :=
  canonical_truth_lemma B h_tc fam hfam t φ

/-!
## Task 974 Dependency Documentation

The following components are needed from task 974 to complete the discrete
completeness theorem. Until these are resolved, the full theorem cannot be
stated without sorries.

### Required from DiscreteTimeline.lean

1. `DiscreteTimelineQuot.succOrder`: SuccOrder instance
   - Current status: sorry in `succ_le_of_lt` proof
   - Needed for: Immediate successor in canonical model

2. `DiscreteTimelineQuot.predOrder`: PredOrder instance
   - Current status: sorry in `pred_le_of_lt` proof
   - Needed for: Immediate predecessor in canonical model

3. `DiscreteTimelineQuot.isSuccArchimedean`: IsSuccArchimedean instance
   - Current status: sorry
   - Needed for: Finite step reachability, ℤ isomorphism

### Root Issue

The `succ_le_of_lt` lemma requires showing that the discreteness axiom DF
implies there are no strict intermediate points between adjacent equivalence
classes in the quotient. The proof strategy is:

1. Take [M] < [N] in DiscreteTimelineQuot
2. Assume for contradiction there exists [W] with [M] < [W] < [N]
3. Use DF to derive a formula that must be in both M and W
4. Show this contradicts the strict ordering

This is a complex proof involving canonical model theory and the specific
structure of the staged timeline construction.

### Temporary Workaround

For now, Int-based completeness infrastructure is available and proven.
The discrete-specific domain construction (DiscreteTimelineQuot ≃o ℤ) awaits
task 974. Applications that need discrete completeness can either:

1. Use Int directly (which has discrete structure)
2. Wait for task 974 completion
-/

/-!
## Completeness Hierarchy

The three completeness theorems relate as follows:

```
valid φ  ──────────────────────────────────────────────────>  ⊢ φ (base)
   │                                                            │
   │ (specialization)                                           │ (extension)
   ▼                                                            ▼
valid_dense φ ─────────────────────────────────────────────>  ⊢_dense φ

valid_discrete φ ──────────────────────────────────────────>  ⊢_discrete φ
```

Note that dense and discrete are INCOMPATIBLE extensions:
- Dense requires DenselyOrdered (no immediate successors)
- Discrete requires SuccOrder (immediate successors exist)
- No domain satisfies both (except degenerate cases)

This is reflected in the axioms:
- DN (density) is NOT valid on discrete orders
- DF (discreteness) is NOT valid on dense orders
-/

end Bimodal.Metalogic.DiscreteCompleteness
