import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Semantics.IntTransfer

/-! Final gate for the reach-through residue close-out: the two named theorems must depend on
exactly `[propext, Classical.choice, Quot.sound]`, with no `sorryAx`. -/

#print axioms FormalSystem.Semantics.validZTime_iff_validInt
#print axioms FormalSystem.Semantics.truthAt_map
