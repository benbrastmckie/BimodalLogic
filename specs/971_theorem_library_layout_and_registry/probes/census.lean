import FormalSystem
open Lean Meta Elab Command

structure Frag where
  bx : Bool := false
  temp : Bool := false
  opq : Bool := false
deriving Repr

partial def walk (e : Expr) (f : Frag) : MetaM Frag := do
  let e ← whnf e
  match e.getAppFn.constName?, e.getAppArgs with
  | some ``FormalSystem.Syntax.Formula.atom, _ => pure f
  | some ``FormalSystem.Syntax.Formula.bot, _ => pure f
  | some ``FormalSystem.Syntax.Formula.imp, #[a, b] => walk a f >>= walk b
  | some ``FormalSystem.Syntax.Formula.box, #[a] => walk a {f with bx := true}
  | some ``FormalSystem.Syntax.Formula.untl, #[a, b] => walk a {f with temp := true} >>= walk b
  | some ``FormalSystem.Syntax.Formula.snce, #[a, b] => walk a {f with temp := true} >>= walk b
  | _, _ => if e.isFVar then pure f else pure {f with opq := true}

def fragName (f : Frag) : String :=
  (match f.bx, f.temp with
  | false, false => "Boolean"
  | true, false => "ModalBoolean"
  | false, true => "TemporalBoolean"
  | true, true => "ModalTemporalBoolean") ++ (if f.opq then "?" else "")

run_cmd liftTermElabM do
  let env ← getEnv
  let mut rows : Array String := #[]
  for (n, ci) in env.constants.map₁.toList do
    let some idx := env.getModuleIdxFor? n | continue
    let mod := env.header.moduleNames[idx.toNat]!
    unless (`FormalSystem.Theorems).isPrefixOf mod do continue
    if (`FormalSystem.Theorems.ProofMode).isPrefixOf mod then continue
    if n.isInternalDetail then continue
    if isPrivateName n then
      pure ()
    let r ← forallTelescope ci.type fun xs body => do
      let body ← whnfR body
      let isDT := body.isAppOf ``FormalSystem.ProofSystem.DerivationTree
      let mut hypDT := false
      let mut kinds : Array String := #[]
      for x in xs do
        let t ← inferType x
        let t' ← whnfR t
        if t'.isAppOf ``FormalSystem.ProofSystem.DerivationTree then hypDT := true; kinds := kinds.push "D"
        else if t'.isConstOf ``FormalSystem.Syntax.Formula then kinds := kinds.push "F"
        else if t'.isConstOf ``FormalSystem.ProofSystem.FrameClass then kinds := kinds.push "fc"
        else if (t.find? (·.isAppOf ``FormalSystem.ProofSystem.DerivationTree)).isSome then hypDT := true; kinds := kinds.push "D*"
        else if ← isProp t then kinds := kinds.push s!"P[{← ppExpr t}]"
        else kinds := kinds.push s!"O[{← ppExpr t}]"
      if !isDT then return none
      let args := body.getAppArgs
      let ctx ← whnf args[1]!
      let emptyCtx := ctx.isAppOf ``List.nil
      let fc ← ppExpr args[0]!
      let fr ← walk args[2]! {}
      let cls := if hypDT then "rule" else if emptyCtx then "closed" else "ctx"
      return some s!"{cls}\t{mod}\t{n}\t{fragName fr}\t{fc}\t{kinds}\t{if isPrivateName n then "private" else "public"}\t{match ci with | .defnInfo _ => "def" | .thmInfo _ => "thm" | .opaqueInfo _ => "opaque" | _ => "other"}"
    if let some s := r then rows := rows.push s
  for s in rows.qsort (· < ·) do IO.println s
