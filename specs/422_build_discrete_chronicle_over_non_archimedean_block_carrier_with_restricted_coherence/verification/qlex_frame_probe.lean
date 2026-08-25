/- Probe: the generic multi-family frame machinery elaborates at D := ℚ ×ₗ ℤ,
   i.e. the frame side of the k-equivalence-transfer route needs no new work.
   Also: the Base-branch existential shape is satisfiable-by-construction at this
   carrier once a model refuting φ is supplied (shape check only, no truth claim). -/
import FormalSystem.Metalogic.Algebraic.FlowFrame
import Mathlib.Algebra.Order.Monoid.Prod

open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

abbrev QZ := Lex (ℚ × ℤ)

-- Four Base binders resolve at ℚ ×ₗ ℤ
example : AddCommGroup QZ := inferInstance
example : LinearOrder QZ := inferInstance
example : IsOrderedAddMonoid QZ := inferInstance
example : Nontrivial QZ := inferInstance

-- The D-generic multi-family frame and history elaborate at ℚ ×ₗ ℤ
noncomputable def probeFrame : TaskFrame QZ := multiFamTaskFrameGen QZ Unit
noncomputable def probeHistory : WorldHistory probeFrame := multiFamHistoryGen (D := QZ) () 0

-- Its histories are total (the property `countermodel_discrete` must supply)
example : WorldHistory.IsTotal probeHistory := fun _ => trivial

#print axioms probeFrame
