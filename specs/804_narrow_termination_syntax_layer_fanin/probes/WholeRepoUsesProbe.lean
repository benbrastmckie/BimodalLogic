import FormalSystem
import BimodalTest
import BimodalTools
open Lean
run_cmd do
  let env ← getEnv
  let mods := env.header.moduleNames
  let h ← IO.FS.Handle.mk "OUTDIR/graph.tsv" .write
  for i in [0:mods.size] do
    let md := env.header.moduleData[i]!
    for imp in md.imports do
      h.putStrLn s!"{mods[i]!}\t{imp.module}"
  let mut tbl : Std.HashMap (Name × Name) Name := {}
  for (n, ci) in env.constants.map₁.toList do
    let some i := env.getModuleIdxFor? n | continue
    let um := mods[i.toNat]!
    let r := um.getRoot.toString
    unless r == "FormalSystem" || r.startsWith "Bimodal" do continue
    let deps := ci.type.getUsedConstants ++ ((ci.value? (allowOpaque := true)).map Expr.getUsedConstants).getD #[]
    for d in deps do
      let some j := env.getModuleIdxFor? d | continue
      let dm := mods[j.toNat]!
      if dm == um then continue
      if d.isInternalDetail || (d.toString.splitOn ".eq_").length > 1 || (d.toString.splitOn "match_").length > 1 || (d.toString.splitOn "_sparseCasesOn").length > 1 || (d.toString.splitOn "._simp_").length > 1 || (d.toString.splitOn ".eq_def").length > 1 || (d.toString.splitOn "_sunfold").length > 1 || (d.toString.splitOn "_unary").length > 1 then continue
      unless tbl.contains (um,dm) do tbl := tbl.insert (um,dm) d
  let h2 ← IO.FS.Handle.mk "OUTDIR/uses.tsv" .write
  for ((um,dm),d) in tbl.toList do h2.putStrLn s!"{um}\t{dm}\t{d}"
