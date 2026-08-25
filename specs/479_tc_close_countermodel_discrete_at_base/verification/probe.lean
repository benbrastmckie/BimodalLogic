import FormalSystem.Metalogic.WeakCanonical
import FormalSystem.Metalogic.Algebraic.FlowFrame
import FormalSystem.Metalogic.BXCanonical.Completeness

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Algebraic

#print axioms FormalSystem.Metalogic.WeakCanonical.companionChronicle
#print axioms FormalSystem.Metalogic.WeakCanonical.companionGeneral
#print axioms FormalSystem.Metalogic.WeakCanonical.countermodel_discrete_reynolds_v2
#print axioms FormalSystem.Metalogic.BXCanonical.completeness

-- carrier gate
example : AddCommGroup (ℚ ×ₗ ℤ) := inferInstance
example : LinearOrder (ℚ ×ₗ ℤ) := inferInstance
example : IsOrderedAddMonoid (ℚ ×ₗ ℤ) := inferInstance
example : Nontrivial (ℚ ×ₗ ℤ) := inferInstance

-- strict order-translation facts needed for the untl/snce cases
example (w t s : ℚ ×ₗ ℤ) : w + t < w + s ↔ t < s := add_lt_add_iff_left w
example (w s : ℚ ×ₗ ℤ) : w + (s - w) = s := by abel
example (Fam : Type) [Nonempty Fam] : TaskFrame (ℚ ×ₗ ℤ) := multiFamTaskFrameGen (ℚ ×ₗ ℤ) Fam
example (Fam : Type) [Nonempty Fam] (f : Fam) (w : ℚ ×ₗ ℤ) :
    WorldHistory (multiFamTaskFrameGen (ℚ ×ₗ ℤ) Fam) := multiFamHistoryGen f w

-- QZ carrier is definitionally the group
example (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (Q : QZStructure sig) : (Q.toOrdered sig).carrier = (ℚ ×ₗ ℤ) := rfl
