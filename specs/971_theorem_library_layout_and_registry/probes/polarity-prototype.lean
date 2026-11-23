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
  addAndCompile (Declaration.defnDecl (mkDefinitionValEx declName [] teTy entry ReducibilityHints.abbrev DefinitionSafety.safe [declName]))

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
structure Pol where
  box : Bool := false
  dia : Bool := false
  g : Bool := false
  f : Bool := false
  h : Bool := false
  p : Bool := false
  u : Bool := false
  s : Bool := false
  deriving Repr, DecidableEq
def Pol.j (a b : Pol) : Pol := ⟨a.box||b.box, a.dia||b.dia, a.g||b.g, a.f||b.f, a.h||b.h, a.p||b.p, a.u||b.u, a.s||b.s⟩
def pol : Formula → Pol
  | .imp (.untl (.imp .bot .bot) (.imp φ .bot)) .bot => { pol φ with g := true }
  | .imp (.snce (.imp .bot .bot) (.imp φ .bot)) .bot => { pol φ with h := true }
  | .imp (.box (.imp φ .bot)) .bot => { pol φ with dia := true }
  | .untl (.imp .bot .bot) φ => { pol φ with f := true }
  | .snce (.imp .bot .bot) φ => { pol φ with p := true }
  | .box φ => { pol φ with box := true }
  | .untl ψ φ => { (pol φ).j (pol ψ) with u := true }
  | .snce ψ φ => { (pol φ).j (pol ψ) with s := true }
  | .imp φ ψ => (pol φ).j (pol ψ)
  | .atom _ => {}
  | .bot => {}
register_theorem FormalSystem.ProofSystem.DerivedAxioms.contraSwap
register_theorem FormalSystem.ProofSystem.DerivedAxioms.linearSince
register_theorem FormalSystem.ProofSystem.DerivedAxioms.linearUntilLegacy
register_theorem FormalSystem.ProofSystem.DerivedAxioms.modal4
register_theorem FormalSystem.ProofSystem.DerivedAxioms.modalB
register_theorem FormalSystem.ProofSystem.DerivedAxioms.orAssocRev
register_theorem FormalSystem.ProofSystem.DerivedAxioms.orRotate
register_theorem FormalSystem.Theorems.Combinators.bCombinator
register_theorem FormalSystem.Theorems.Combinators.identity
register_theorem FormalSystem.Theorems.Combinators.notNotIntro
register_theorem FormalSystem.Theorems.Combinators.pairing
register_theorem FormalSystem.Theorems.Combinators.temporalFutureDerived
register_theorem FormalSystem.Theorems.Combinators.theoremApp1
register_theorem FormalSystem.Theorems.Combinators.theoremApp2
register_theorem FormalSystem.Theorems.Combinators.theoremFlip
register_theorem FormalSystem.Theorems.Combinators.topThm
register_theorem FormalSystem.Theorems.ConnectDerived.connectFuture
register_theorem FormalSystem.Theorems.ConnectDerived.connectPast
register_theorem FormalSystem.Theorems.ConnectDerived.discretePropagateBwd
register_theorem FormalSystem.Theorems.ConnectDerived.discreteSymmBwd
register_theorem FormalSystem.Theorems.ConnectDerived.discreteSymmFwd
register_theorem FormalSystem.Theorems.ConnectDerived.fHImp
register_theorem FormalSystem.Theorems.ConnectDerived.lceImpThm
register_theorem FormalSystem.Theorems.ConnectDerived.rceImpThm
register_theorem FormalSystem.Theorems.ConnectDerived.untlBotFalseThm
register_theorem FormalSystem.Theorems.DedekindDerived.alwaysElimFuture
register_theorem FormalSystem.Theorems.DedekindDerived.alwaysElimHere
register_theorem FormalSystem.Theorems.DedekindDerived.alwaysElimPast
register_theorem FormalSystem.Theorems.DedekindDerived.coDerived
register_theorem FormalSystem.Theorems.DedekindDerived.snceAllPastAndImp
register_theorem FormalSystem.Theorems.DedekindDerived.someFutureAllPastImp
register_theorem FormalSystem.Theorems.DedekindDerived.someFutureAllPastUntlTop
register_theorem FormalSystem.Theorems.DiscreteUnfolding.dfSchema
register_theorem FormalSystem.Theorems.DiscreteUnfolding.nextAllFuture
register_theorem FormalSystem.Theorems.DiscreteUnfolding.nextConj
register_theorem FormalSystem.Theorems.DiscreteUnfolding.noBlockingTriple
register_theorem FormalSystem.Theorems.DiscreteUnfolding.prevAllPast
register_theorem FormalSystem.Theorems.DiscreteUnfolding.prevConj
register_theorem FormalSystem.Theorems.DiscreteUnfolding.prevIndicator
register_theorem FormalSystem.Theorems.DiscreteUnfolding.prevIndicatorAt
register_theorem FormalSystem.Theorems.DiscreteUnfolding.succIndicator
register_theorem FormalSystem.Theorems.DiscreteUnfolding.succIndicatorAt
register_theorem FormalSystem.Theorems.DiscreteUnfolding.unfoldBackward
register_theorem FormalSystem.Theorems.DiscreteUnfolding.unfoldBackwardSince
register_theorem FormalSystem.Theorems.DiscreteUnfolding.unfoldForward
register_theorem FormalSystem.Theorems.DiscreteUnfolding.unfoldTableBackward
register_theorem FormalSystem.Theorems.DiscreteUnfolding.unfoldTableForward
register_theorem FormalSystem.Theorems.DiscreteUnfolding.z1EventBot
register_theorem FormalSystem.Theorems.DiscreteUnfolding.z1Schema
register_theorem FormalSystem.Theorems.DiscreteUnfolding.z1SchemaAt
register_theorem FormalSystem.Theorems.pastKDist
register_theorem FormalSystem.Theorems.Interaction.alwaysBoxIffBox
register_theorem FormalSystem.Theorems.Interaction.alwaysDiamondToDiamond
register_theorem FormalSystem.Theorems.Interaction.alwaysNegToNotSometimes
register_theorem FormalSystem.Theorems.Interaction.boxAlwaysIffAlwaysBox
register_theorem FormalSystem.Theorems.Interaction.boxAlwaysIffBox
register_theorem FormalSystem.Theorems.Interaction.boxToAlwaysBox
register_theorem FormalSystem.Theorems.Interaction.diamondAlwaysToDiamond
register_theorem FormalSystem.Theorems.Interaction.diamondIffDiamondSometimes
register_theorem FormalSystem.Theorems.Interaction.diamondSometimesIffSometimesDiamond
register_theorem FormalSystem.Theorems.Interaction.diamondSometimesToSometimesDiamond
register_theorem FormalSystem.Theorems.Interaction.diamondToDiamondSometimes
register_theorem FormalSystem.Theorems.Interaction.notSometimesToAlwaysNeg
register_theorem FormalSystem.Theorems.Interaction.sometimesBoxIffBox
register_theorem FormalSystem.Theorems.Interaction.sometimesDiamondToDiamond
register_theorem FormalSystem.Theorems.Interaction.sometimesDiamondToDiamondSometimes
register_theorem FormalSystem.Theorems.Interaction.temporalPastDerived
register_theorem FormalSystem.Theorems.LinearityDerived.claviusThm
register_theorem FormalSystem.Theorems.LinearityDerived.density
register_theorem FormalSystem.Theorems.LinearityDerived.orInlThm
register_theorem FormalSystem.Theorems.LinearityDerived.orInrThm
register_theorem FormalSystem.Theorems.LinearityDerived.tempLinearity
register_theorem FormalSystem.Theorems.LinearityDerived.tempLinearityLegacy
register_theorem FormalSystem.Theorems.LinearityDerived.tempLinearityPast
register_theorem FormalSystem.Theorems.ModalDerived.axiom5NegativeIntrospection
register_theorem FormalSystem.Theorems.ModalDerived.boxDneTheorem
register_theorem FormalSystem.Theorems.ModalDerived.dneTheorem
register_theorem FormalSystem.Theorems.ModalDerived.gDneTheorem
register_theorem FormalSystem.Theorems.ModalDerived.hDneTheorem
register_theorem FormalSystem.Theorems.ModalDerived.modal5CollapseTheorem
register_theorem FormalSystem.Theorems.ModalDerived.negBoxToBoxNegBox
register_theorem FormalSystem.Theorems.ModalDerived.pastTempA
register_theorem FormalSystem.Theorems.ModalS4.s4BoxDiamondBox
register_theorem FormalSystem.Theorems.ModalS4.s4DiamondBoxConj
register_theorem FormalSystem.Theorems.ModalS4.s4DiamondBoxDiamond
register_theorem FormalSystem.Theorems.ModalS4.s5DiamondConjDiamond
register_theorem FormalSystem.Theorems.ModalS5.boxConjIff
register_theorem FormalSystem.Theorems.ModalS5.boxContrapose
register_theorem FormalSystem.Theorems.ModalS5.boxDisjIntro
register_theorem FormalSystem.Theorems.ModalS5.classicalMerge
register_theorem FormalSystem.Theorems.ModalS5.diamondDisjIff
register_theorem FormalSystem.Theorems.ModalS5.kDistDiamond
register_theorem FormalSystem.Theorems.ModalS5.s5DiamondBox
register_theorem FormalSystem.Theorems.ModalS5.s5DiamondBoxToTruth
register_theorem FormalSystem.Theorems.ModalS5.tBoxConsistency
register_theorem FormalSystem.Theorems.ModalS5.tBoxToDiamond
register_theorem FormalSystem.Theorems.Perpetuity.boxToFuture
register_theorem FormalSystem.Theorems.Perpetuity.boxToPast
register_theorem FormalSystem.Theorems.Perpetuity.boxToPresent
register_theorem FormalSystem.Theorems.Perpetuity.alwaysDne
register_theorem FormalSystem.Theorems.Perpetuity.alwaysDni
register_theorem FormalSystem.Theorems.Perpetuity.alwaysToFuture
register_theorem FormalSystem.Theorems.Perpetuity.alwaysToPast
register_theorem FormalSystem.Theorems.Perpetuity.alwaysToPresent
register_theorem FormalSystem.Theorems.Perpetuity.bridge1
register_theorem FormalSystem.Theorems.Perpetuity.bridge2
register_theorem FormalSystem.Theorems.Perpetuity.modalDualityNeg
register_theorem FormalSystem.Theorems.Perpetuity.modalDualityNegRev
register_theorem FormalSystem.Theorems.Perpetuity.pastPresentFutureToAlways
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity6
register_theorem FormalSystem.Theorems.Perpetuity.temporalDualityNeg
register_theorem FormalSystem.Theorems.Perpetuity.temporalDualityNegRev
register_theorem FormalSystem.Theorems.Perpetuity.boxDiamondToFutureBoxDiamond
register_theorem FormalSystem.Theorems.Perpetuity.boxDiamondToPastBoxDiamond
register_theorem FormalSystem.Theorems.Perpetuity.boxToBoxPast
register_theorem FormalSystem.Theorems.Perpetuity.diamond4
register_theorem FormalSystem.Theorems.Perpetuity.futureKDist
register_theorem FormalSystem.Theorems.Perpetuity.mbDiamond
register_theorem FormalSystem.Theorems.Perpetuity.modal5
register_theorem FormalSystem.Theorems.Perpetuity.pastKDistFromFuture
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity1
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity2
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity3
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity4
register_theorem FormalSystem.Theorems.Perpetuity.perpetuity5
register_theorem FormalSystem.Theorems.Perpetuity.persistence
register_theorem FormalSystem.Theorems.Propositional.classicalMerge
register_theorem FormalSystem.Theorems.Propositional.contraposeImp
register_theorem FormalSystem.Theorems.Propositional.demorganConjNeg
register_theorem FormalSystem.Theorems.Propositional.demorganConjNegBackward
register_theorem FormalSystem.Theorems.Propositional.demorganConjNegForward
register_theorem FormalSystem.Theorems.Propositional.demorganDisjNeg
register_theorem FormalSystem.Theorems.Propositional.demorganDisjNegBackward
register_theorem FormalSystem.Theorems.Propositional.demorganDisjNegForward
register_theorem FormalSystem.Theorems.Propositional.doubleNegation
register_theorem FormalSystem.Theorems.Propositional.efqAxiom
register_theorem FormalSystem.Theorems.Propositional.em
register_theorem FormalSystem.Theorems.Propositional.impNegImp
register_theorem FormalSystem.Theorems.Propositional.impOfNeg
register_theorem FormalSystem.Theorems.Propositional.lceImp
register_theorem FormalSystem.Theorems.Propositional.negImp
register_theorem FormalSystem.Theorems.Propositional.peirceAxiom
register_theorem FormalSystem.Theorems.Propositional.rceImp
register_theorem FormalSystem.Theorems.Propositional.snceBotFalse
register_theorem FormalSystem.Theorems.Propositional.topNegImpBot
register_theorem FormalSystem.Theorems.Propositional.untlBotFalse
register_theorem FormalSystem.Theorems.Propositional.biImp
register_theorem FormalSystem.Theorems.TemporalDerived.alwaysImpAllFuture
register_theorem FormalSystem.Theorems.TemporalDerived.alwaysImpAllPast
register_theorem FormalSystem.Theorems.TemporalDerived.alwaysToPresent
register_theorem FormalSystem.Theorems.TemporalDerived.connectFutureChain
register_theorem FormalSystem.Theorems.TemporalDerived.connectFutureG
register_theorem FormalSystem.Theorems.TemporalDerived.connectFutureThm
register_theorem FormalSystem.Theorems.TemporalDerived.connectPastChain
register_theorem FormalSystem.Theorems.TemporalDerived.connectPastH
register_theorem FormalSystem.Theorems.TemporalDerived.connectPastThm
register_theorem FormalSystem.Theorems.TemporalDerived.contrapositive
register_theorem FormalSystem.Theorems.TemporalDerived.fMono
register_theorem FormalSystem.Theorems.TemporalDerived.fNegG
register_theorem FormalSystem.Theorems.TemporalDerived.formulaOrComm
register_theorem FormalSystem.Theorems.TemporalDerived.gAndIntro
register_theorem FormalSystem.Theorems.TemporalDerived.gContrapose
register_theorem FormalSystem.Theorems.TemporalDerived.gDistribution
register_theorem FormalSystem.Theorems.TemporalDerived.gImpTrans
register_theorem FormalSystem.Theorems.TemporalDerived.gImpliesGId
register_theorem FormalSystem.Theorems.TemporalDerived.gMono
register_theorem FormalSystem.Theorems.TemporalDerived.gTransitivity
register_theorem FormalSystem.Theorems.TemporalDerived.hAndIntro
register_theorem FormalSystem.Theorems.TemporalDerived.hContrapose
register_theorem FormalSystem.Theorems.TemporalDerived.hDistribution
register_theorem FormalSystem.Theorems.TemporalDerived.hImpTrans
register_theorem FormalSystem.Theorems.TemporalDerived.hMono
register_theorem FormalSystem.Theorems.TemporalDerived.hTransitivity
register_theorem FormalSystem.Theorems.TemporalDerived.pMono
register_theorem FormalSystem.Theorems.TemporalDerived.pNegH
register_theorem FormalSystem.Theorems.TemporalDerived.presentToSometimes
register_theorem FormalSystem.Theorems.TemporalDerived.sinceImpP
register_theorem FormalSystem.Theorems.TemporalDerived.sinceImpliesSomePast
register_theorem FormalSystem.Theorems.TemporalDerived.sinceMonoEvent
register_theorem FormalSystem.Theorems.TemporalDerived.sinceMonoGuard
register_theorem FormalSystem.Theorems.TemporalDerived.temporal4Derived
register_theorem FormalSystem.Theorems.TemporalDerived.temporalKDistDerived
register_theorem FormalSystem.Theorems.TemporalDerived.untilImpF
register_theorem FormalSystem.Theorems.TemporalDerived.untilImpliesSomeFuture
register_theorem FormalSystem.Theorems.TemporalDerived.untilMonoEvent
register_theorem FormalSystem.Theorems.TemporalDerived.untilMonoGuard
register_theorem FormalSystem.Theorems.TemporalDerived.weakFutureLeft
register_theorem FormalSystem.Theorems.TemporalDerived.weakFutureRight
register_theorem FormalSystem.Theorems.TemporalDerived.weakPastLeft
register_theorem FormalSystem.Theorems.TemporalDerived.weakPastRight
open Lean Meta Elab Command in
run_cmd liftTermElabM do
  let env ← getEnv
  let mut tally : Std.HashMap String Nat := {}
  for (n, ci) in env.constants.map₂.toList do
    if ci.type.isConstOf ``BimodalLib.TheoremEntry then
      let e := mkConst n
      let st ← mkAppM ``BimodalLib.TheoremEntry.stmt #[e, mkConst ``BimodalLib.schemaVar]
      let r ← unsafe evalExpr Pol (mkConst ``Pol) (← mkAppM ``pol #[st])
      let side (a b : Bool) (nm : String) : String := match a, b with
        | true, false => s!"{nm}:univ-only" | false, true => s!"{nm}:exist-only" | true, true => s!"{nm}:both" | _, _ => ""
      for k in [side r.box r.dia "box/dia", side r.g r.f "G/F", side r.h r.p "H/P"] do
        if k != "" then tally := tally.insert k (tally.getD k 0 + 1)
  for (k, v) in tally.toList do IO.println s!"{v}\t{k}"
