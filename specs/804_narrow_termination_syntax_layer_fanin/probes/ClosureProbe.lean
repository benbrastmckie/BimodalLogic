import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound
open Lean
partial def collect (env : Environment) (visited : Std.HashSet Name) (n : Name) : Std.HashSet Name :=
  if visited.contains n then visited
  else
    let visited := visited.insert n
    match env.find? n with
    | none => visited
    | some ci =>
      let deps := (ci.type.getUsedConstants ++ ((ci.value? (allowOpaque := true)).map Expr.getUsedConstants).getD #[])
      deps.foldl (fun acc d => collect env acc d) visited
run_cmd do
  let env ← getEnv
  let mods := env.header.moduleNames
  for grp in ["FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty",
              "FormalSystem.Metalogic.Decidability.Verified.Termination.TimeTypeBound",
              "FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel",
              "FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound",
              "FormalSystem.Metalogic.Decidability.Tableau",
              "FormalSystem.Metalogic.Decidability.Saturation"] do
    let mut cl : Std.HashSet Name := {}
    let mut roots := 0
    for (n, _) in env.constants.map₁.toList do
      let some i := env.getModuleIdxFor? n | continue
      if (mods[i.toNat]!).toString.startsWith grp then
        cl := collect env cl n; roots := roots + 1
    let mut per : Std.HashMap Name (Nat × List Name) := {}
    for c in cl.toList do
      let some j := env.getModuleIdxFor? c | continue
      let dm := mods[j.toNat]!
      unless dm.toString.startsWith "FormalSystem" do continue
      let (k, ex) := per.getD dm (0, [])
      per := per.insert dm (k+1, if k < 400 then c :: ex else ex)
    IO.println s!"## {grp} roots={roots} closure={cl.size}"
    for (m,(k,ex)) in per.toList do
      let s := m.toString
      let show_ := s.startsWith "FormalSystem.ProofSystem" || s.startsWith "FormalSystem.Automation" || s.startsWith "FormalSystem.Theorems" || s.startsWith "FormalSystem.Semantics" || s.startsWith "FormalSystem.Syntax.Sub" || s.startsWith "FormalSystem.Syntax.Context" || s.startsWith "FormalSystem.Tactic" || s.startsWith "FormalSystem.Init"
      let exs := ex.filter (fun n => !n.isInternalDetail)
      IO.println s!"  {m}: {k}{if show_ then s!" :: {exs}" else ""}"
