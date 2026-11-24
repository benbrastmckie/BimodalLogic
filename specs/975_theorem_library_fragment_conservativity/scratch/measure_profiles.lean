import BimodalLib
open Lean Meta Elab Command BimodalLib FormalSystem.ProofSystem

unsafe def evalProfileUnsafe (e : Expr) : MetaM Profile := evalExpr Profile (mkConst ``Profile) e

unsafe def measureProfiles : MetaM Unit := do
  let rows ← registryRows
  let mut bad : Nat := 0
  for (n, _) in rows do
    let row := mkConst (rowName n)
    let fc ← mkAppM ``TheoremEntry.frameClass #[row]
    let h ← mkAppM ``le_refl #[fc]
    let d ← mkAppM ``TheoremEntry.proof #[row, fc, h, mkConst ``schemaVar]
    let e ← mkAppM ``proofProfile #[d]
    let stmt ← evalProfileUnsafe (← mkAppM ``TheoremEntry.profile #[row])
    let fcv ← whnf fc
    try
      let p ← evalProfileUnsafe e
      unless p ≤ stmt do
        bad := bad + 1
        logInfo m!"{n}: statement {repr stmt} proof {repr p} at {fcv}"
    catch ex => logInfo m!"{n}: FAILED {ex.toMessageData}"
  logInfo m!"{rows.size} rows, {bad} outside"

run_meta unsafe measureProfiles
