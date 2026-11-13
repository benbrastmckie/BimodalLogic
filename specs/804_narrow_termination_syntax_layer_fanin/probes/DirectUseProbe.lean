import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound
import FormalSystem.Metalogic.Decidability.Verified.Decidable
open Lean
def isTarget (m : Name) : Bool :=
  let s := m.toString
  s.startsWith "FormalSystem.Metalogic.Decidability.Verified.Termination" ||
  s == "FormalSystem.Metalogic.Decidability.Verified.RuleSpec" ||
  s ∈ ["FormalSystem.Metalogic.Decidability.SignedFormula","FormalSystem.Metalogic.Decidability.Tableau",
       "FormalSystem.Metalogic.Decidability.Closure","FormalSystem.Metalogic.Decidability.Saturation",
       "FormalSystem.Metalogic.Decidability.TraceCertificate","FormalSystem.Automation.ProofSearch.Core"]
-- direct module-level edges over ALL FormalSystem modules, then closure in python
run_cmd do
  let env ← getEnv
  let mods := env.header.moduleNames
  let mut tbl : Std.HashMap (Name × Name) (Nat × Name × Name) := {}
  for (n, ci) in env.constants.map₁.toList do
    let some i := env.getModuleIdxFor? n | continue
    let um := mods[i.toNat]!
    unless um.toString.startsWith "FormalSystem" do continue
    let deps := ci.type.getUsedConstants ++ ((ci.value? (allowOpaque := true)).map Expr.getUsedConstants).getD #[]
    for d in deps do
      let some j := env.getModuleIdxFor? d | continue
      let dm := mods[j.toNat]!
      if dm == um then continue
      unless dm.toString.startsWith "FormalSystem" do continue
      match tbl[(um,dm)]? with
      | some (c, a, b) => tbl := tbl.insert (um,dm) (c+1, a, b)
      | none => tbl := tbl.insert (um,dm) (1, n, d)
  for ((um,dm),(c,a,b)) in tbl.toList do IO.println s!"{um}\t{dm}\t{c}\t{a}\t{b}"
-- distinct constants of ProofSystem.Axioms / Automation / Derivation used by targets
run_cmd do
  let env ← getEnv
  let mods := env.header.moduleNames
  let mut tbl : Std.HashMap (Name × Name) Nat := {}
  for (n, ci) in env.constants.map₁.toList do
    let some i := env.getModuleIdxFor? n | continue
    let um := mods[i.toNat]!
    unless isTarget um do continue
    let deps := ci.type.getUsedConstants ++ ((ci.value? (allowOpaque := true)).map Expr.getUsedConstants).getD #[]
    for d in deps do
      let some j := env.getModuleIdxFor? d | continue
      let dm := mods[j.toNat]!
      if dm == um then continue
      let s := dm.toString
      unless (s.startsWith "FormalSystem.ProofSystem" || s.startsWith "FormalSystem.Automation" || s.startsWith "FormalSystem.Semantics" || s.startsWith "FormalSystem.Theorems" || s.startsWith "FormalSystem.Syntax.Sub" || s.startsWith "FormalSystem.Syntax.Context") do continue
      tbl := tbl.insert (um, d) ((tbl.getD (um,d) 0) + 1)
  for ((um,d),c) in tbl.toList do IO.println s!"CONST\t{um}\t{d}\t{c}"
