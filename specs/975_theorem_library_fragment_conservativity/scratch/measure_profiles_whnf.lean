import BimodalLib
open Lean Meta Elab Command BimodalLib FormalSystem.ProofSystem

def measureWhnf : MetaM Unit := do
  let rows ← registryRows
  let mut bad : Nat := 0
  let mut stuck : Nat := 0
  for (n, _) in rows do
    let row := mkConst (rowName n)
    let fc ← mkAppM ``TheoremEntry.frameClass #[row]
    let h ← mkAppM ``le_refl #[fc]
    let d ← mkAppM ``TheoremEntry.proof #[row, fc, h, mkConst ``schemaVar]
    let e ← mkAppM ``Profile.le #[← mkAppM ``proofProfile #[d], ← mkAppM ``TheoremEntry.profile #[row]]
    let r ← withTransparency .all (whnf e)
    if r.isConstOf ``Bool.true then pure ()
    else if r.isConstOf ``Bool.false then
      bad := bad + 1
      logInfo m!"{n}: outside"
    else
      stuck := stuck + 1
      logInfo m!"{n}: stuck"
  logInfo m!"{rows.size} rows, {bad} outside, {stuck} stuck"

set_option maxHeartbeats 2000000 in
run_meta measureWhnf
