import BimodalTools.FormulaEnumerator
import BimodalTools.AtomCanonicalization
import BimodalTools.TableauBridge
import BimodalLib.Fragment

set_option autoImplicit false
set_option maxHeartbeats 0

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.Metalogic.Decidability (decideAuto)

namespace YieldProbe

/-- The four fragments as a key, from BimodalLib's own computed profile. -/
def fragKey (φ : Formula) : String := (BimodalLib.profileF φ).fragment.name

structure Row where
  frag : String
  total : Nat := 0
  valid : Nat := 0
  invalid : Nat := 0
  invGated : Nat := 0
  fuel : Nat := 0
  extFail : Nat := 0
  deriving Repr

def bump (r : Row) (φ : Formula) (fc : FrameClass) : Row :=
  let r := { r with total := r.total + 1 }
  match decideAuto φ fc with
  | .valid _ => { r with valid := r.valid + 1 }
  | .invalid _ =>
      let g := BimodalTools.TableauBridge.evalBranchGates φ fc
      let ok := match g with | some gg => gg.gated | none => false
      { r with invalid := r.invalid + 1, invGated := r.invGated + (if ok then 1 else 0) }
  | .fuelExhausted => { r with fuel := r.fuel + 1 }
  | .extractionFailed => { r with extFail := r.extFail + 1 }

def run (bound : Nat) (fc : FrameClass) (atoms : List Atom) : IO Unit := do
  let cfg : BimodalTools.EnumConfig :=
    { maxModalDepth := bound, maxTemporalDepth := bound, maxSize := bound, atomPool := atoms }
  let raw := BimodalTools.enumerateUpToDepth cfg
  let canon := BimodalTools.AtomCanonicalization.deduplicateCanonical raw
  IO.println s!"bound={bound} fc={repr fc} atoms={atoms.length} enumerated={raw.length} canonical={canon.length}"
  let mut m : Std.HashMap String Row := {}
  for φ in canon do
    let k := fragKey φ
    let r := m.getD k { frag := k }
    m := m.insert k (bump r φ fc)
  let keys := ["Boolean", "ModalBoolean", "TemporalBoolean", "ModalTemporalBoolean"]
  IO.println "fragment                    total  valid invalid gated   fuel extFail"
  for k in keys do
    match m.get? k with
    | none => pure ()
    | some r =>
      IO.println s!"{k.leftpad 26} {toString r.total |>.leftpad 6} {toString r.valid |>.leftpad 6} {toString r.invalid |>.leftpad 7} {toString r.invGated |>.leftpad 5} {toString r.fuel |>.leftpad 6} {toString r.extFail |>.leftpad 7}"

end YieldProbe

def main : IO Unit := do
  let atoms : List FormalSystem.Syntax.Atom := [⟨"p", none⟩, ⟨"q", none⟩]
  YieldProbe.run 4 FormalSystem.ProofSystem.FrameClass.Base atoms
  YieldProbe.run 4 FormalSystem.ProofSystem.FrameClass.ZTime atoms

#eval main
