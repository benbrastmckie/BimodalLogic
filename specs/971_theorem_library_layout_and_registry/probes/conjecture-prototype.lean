import FormalSystem.Theorems
import FormalSystem.PlusLanguage.PlusStateLocal
import FormalSystem.PlusLanguage.Derivation
open Lean Meta Elab Command
open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

namespace BimodalLib

/-- The operator families over the Boolean base. -/
inductive Family | Modal | Temporal
  deriving DecidableEq, Repr

/-- The four fragments. -/
inductive Fragment | Boolean | ModalBoolean | TemporalBoolean | ModalTemporalBoolean
  deriving DecidableEq, Repr

/-- Which primitive operators occur. -/
structure Profile where
  box : Bool := false
  stab : Bool := false
  temporal : Bool := false
  deriving DecidableEq, Repr

def Profile.join (a b : Profile) : Profile :=
  ⟨a.box || b.box, a.stab || b.stab, a.temporal || b.temporal⟩

def Profile.fragment (p : Profile) : Fragment :=
  match p.box || p.stab, p.temporal with
  | false, false => .Boolean
  | true, false => .ModalBoolean
  | false, true => .TemporalBoolean
  | true, true => .ModalTemporalBoolean

def profileF : Formula → Profile
  | .atom _ => {}
  | .bot => {}
  | .imp φ ψ => (profileF φ).join (profileF ψ)
  | .box φ => { profileF φ with box := true }
  | .untl φ ψ => { (profileF φ).join (profileF ψ) with temporal := true }
  | .snce φ ψ => { (profileF φ).join (profileF ψ) with temporal := true }

def profileP : PlusFormula → Profile
  | .atom _ => {}
  | .bot => {}
  | .imp φ ψ => (profileP φ).join (profileP ψ)
  | .box φ => { profileP φ with box := true }
  | .untl φ ψ => { (profileP φ).join (profileP ψ) with temporal := true }
  | .snce φ ψ => { (profileP φ).join (profileP ψ) with temporal := true }
  | .stab φ => { profileP φ with stab := true }

/-- The embedding preserves the profile: a kernel-checked coherence fact. -/
theorem profileP_ofFormula (φ : Formula) : profileP (ofFormula φ) = profileF φ := by
  induction φ <;> simp_all [profileP, profileF, ofFormula]

/-- The canonical schema variables. -/
def schemaVar (i : Nat) : Formula := .atom (Atom.mkFresh "p" i)

/-- A registered theorem: kernel-checked row. -/
structure TheoremEntry where
  arity : Nat
  frameClass : FrameClass
  stmt : (Nat → Formula) → Formula
  proof : ∀ fc, frameClass ≤ fc → ∀ v, DerivationTree fc [] (stmt v)
  profile : Profile
  profile_eq : profileF (stmt schemaVar) = profile

def TheoremEntry.fragment (e : TheoremEntry) : Fragment := e.profile.fragment



/-- `register_theorem X` builds the row for `X` from the TYPE of `X`. -/
elab "register_theorem " id:ident : command => liftTermElabM do
  let n ← realizeGlobalConstNoOverloadWithInfo id
  let ci ← getConstInfo n
  unless ci.levelParams.isEmpty do throwError "universe-polymorphic"
  -- pass 1: find the frame class
  let fcTy := mkConst ``FrameClass
  let fmTy := mkConst ``Formula
  let (cls, fixed) ← forallTelescope ci.type fun xs body => do
    let mut cls : Option Expr := none
    for x in xs do
      let t ← whnfR (← inferType x)
      if t.isAppOfArity ``LE.le 4 then cls := some t.appFn!.appArg!
    let body ← whnfR body
    unless body.isAppOfArity ``DerivationTree 3 do throwError "not a derivation"
    let fcE := body.getAppArgs[0]!
    if fcE.isFVar then return (cls.getD (mkConst ``FrameClass.Base), false)
    else return (fcE, true)
  let entry ← withLocalDeclD `fc fcTy fun fc => do
    let hTy ← mkAppM ``LE.le #[cls, fc]
    withLocalDeclD `h hTy fun h => do
    withLocalDeclD `v (← mkArrow (mkConst ``Nat) fmTy) fun v => do
      let mut ty := ci.type
      let mut args : Array Expr := #[]
      let mut k := 0
      repeat
        let .forallE _ d b _ := ty | break
        let d' ← whnfR d
        let a ←
          if d'.isConstOf ``FrameClass then pure fc
          else if d'.isConstOf ``Formula then do
            let a := mkApp v (mkNatLit k); k := k + 1; pure a
          else if d'.isAppOfArity ``LE.le 4 then pure h
          else throwError m!"unsupported binder {d}"
        args := args.push a
        ty := b.instantiate1 a
      let ty2 ← whnfR ty
      let φ := ty2.getAppArgs[2]!
      let ctx ← whnf ty2.getAppArgs[1]!
      unless ctx.isAppOf ``List.nil do throwError "not a closed derivation"
      if φ.containsFVar fc.fvarId! then throwError "statement depends on fc"
      let stmt ← mkLambdaFVars #[v] φ
      let d := mkAppN (mkConst n) args
      let d ← if fixed then mkAppOptM ``DerivationTree.lift #[cls, fc, h, none, none, d] else pure d
      let proof ← mkLambdaFVars #[fc, h, v] d
      let prof ← reduce (← mkAppM ``profileF #[stmt.beta #[mkConst ``schemaVar]])
      let pe ← mkEqRefl prof
      let pe ← mkExpectedTypeHint pe (← mkEq (← mkAppM ``profileF #[mkApp stmt (mkConst ``schemaVar)]) prof)
      mkAppM ``TheoremEntry.mk #[mkNatLit k, cls, stmt, proof, prof, pe]
  let entry ← instantiateMVars entry
  let declName := `BimodalLib.Registry ++ n
  let teTy : Expr := mkConst ``TheoremEntry
  addDecl (Declaration.defnDecl (mkDefinitionValEx declName [] teTy entry ReducibilityHints.abbrev DefinitionSafety.safe [declName]))

/-- The constant an entry registers, read off the kernel-checked `proof` field. -/
def registeredConsts : MetaM NameSet := do
  let env ← getEnv
  let mut s : NameSet := {}
  for (n, ci) in env.constants.map₁.toList ++ env.constants.map₂.toList do
    if ci.type.isConstOf ``TheoremEntry then
      if let some v := ci.value? then
        if (`BimodalLib.Registry).isPrefixOf n then
          s := s.insert (n.replacePrefix `BimodalLib.Registry .anonymous)
          -- cross-check: the proof field mentions the constant
          unless (v.find? (·.isConstOf (n.replacePrefix `BimodalLib.Registry .anonymous))).isSome do
            throwError "row {n} does not cite its declaration"
  return s

def closedDerivations (pfx excl : Name) : MetaM (Array Name) := do
  let env ← getEnv
  let mut out := #[]
  for (n, ci) in env.constants.map₁.toList do
    let some idx := env.getModuleIdxFor? n | continue
    let mod := env.header.moduleNames[idx.toNat]!
    unless pfx.isPrefixOf mod && !excl.isPrefixOf mod do continue
    if n.isInternalDetail then continue
    let ok ← forallTelescope ci.type fun xs body => do
      let body ← whnfR body
      unless body.isAppOfArity ``DerivationTree 3 do return false
      unless (← whnf body.getAppArgs[1]!).isAppOf ``List.nil do return false
      for x in xs do
        let t ← inferType x
        if (t.find? (·.isAppOf ``DerivationTree)).isSome then return false
      return true
    if ok then out := out.push n
  return out.qsort (·.toString < ·.toString)

elab "#check_registry_complete" : command => liftTermElabM do
  let reg ← registeredConsts
  let all ← closedDerivations `FormalSystem.Theorems `FormalSystem.Theorems.ProofMode
  let missing := all.filter (!reg.contains ·)
  logInfo m!"closed derivations: {all.size}; registered: {reg.size}"
  unless missing.isEmpty do
    throwError "{missing.size} unregistered closed derivation(s): {missing.toList.take 5} ..."

/-- Pairing: a second proof elaborated against the TYPE of the registered declaration. -/
syntax "reprove " ident " as " ident " := " term : command
macro_rules
  | `(reprove $x as $y := $t) => `(def $y : type_of% @$x := $t)

/-- A conjecture: a statement, no proof term. -/
inductive ConjectureStatus | open_ | heuristicallyRefuted | undetermined
  deriving DecidableEq, Repr
structure Conjecture where
  statement : Prop
  fragment : Fragment
  ops : Profile
  frameClass : Option FrameClass
  status : ConjectureStatus
  note : String

end BimodalLib

open BimodalLib
namespace BimodalLib
/-- Profile order: `a ≤ b` when every operator of `a` occurs in `b`. -/
def Profile.le (a b : Profile) : Bool := (!a.box || b.box) && (!a.stab || b.stab) && (!a.temporal || b.temporal)

/-- The conclusion of a derivation. -/
def conclOf {fc : FrameClass} {Γ : FormalSystem.Syntax.Context} {φ : Formula} (_ : DerivationTree fc Γ φ) : Formula := φ

/-- Every formula of the derivation lies in the cell `c`. -/
def within (c : Profile) {fc : FrameClass} : {Γ : FormalSystem.Syntax.Context} → {φ : Formula} → DerivationTree fc Γ φ → Prop
  | _, φ, .axiom _ _ _ _ => (profileF φ).le c
  | _, φ, .assumption _ _ _ => (profileF φ).le c
  | _, φ, .modus_ponens _ _ _ d1 d2 => (profileF φ).le c ∧ within c d1 ∧ within c d2
  | _, _, e@(.necessitation _ d) => (profileF (conclOf e)).le c ∧ within c d
  | _, _, e@(.temporal_necessitation _ d) => (profileF (conclOf e)).le c ∧ within c d
  | _, _, e@(.time_reflection _ d) => (profileF (conclOf e)).le c ∧ within c d
  | _, φ, .weakening _ _ _ d _ => (profileF φ).le c ∧ within c d

/-- Derivable inside the cell. -/
def DerivableIn (c : Profile) (fc : FrameClass) (φ : Formula) : Prop :=
  ∃ d : DerivationTree fc [] φ, within c d

/-- The conservativity edge from cell `c` into TM at `fc`. -/
def ConservativeEdge (c : Profile) (fc : FrameClass) : Prop :=
  ∀ φ : Formula, (profileF φ).le c → Nonempty (DerivationTree fc [] φ) → DerivableIn c fc φ

def booleanIntoModalBoolean : Conjecture where
  statement := ∀ φ : Formula, (profileF φ).le {} → DerivableIn { box := true } .Base φ → DerivableIn {} .Base φ
  fragment := .ModalBoolean
  ops := { box := true }
  frameClass := none
  status := .open_
  note := "completeness of the smaller logic is the propositional procedure"

def modalBooleanIntoTM (fc : FrameClass) : Conjecture where
  statement := ConservativeEdge { box := true } fc
  fragment := .ModalTemporalBoolean
  ops := { box := true }
  frameClass := some fc
  status := .open_
  note := "needs completeness of S5 for the box fragment"
end BimodalLib
#print axioms BimodalLib.modalBooleanIntoTM
