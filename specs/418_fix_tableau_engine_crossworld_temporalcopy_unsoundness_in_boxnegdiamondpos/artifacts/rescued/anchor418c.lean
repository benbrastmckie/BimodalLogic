import FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

def p : Formula := .atom (Atom.mkBase "p")
def gp : Formula := Formula.allFuture p
def anchor : Formula := gp.imp gp.box

/-- Row 9's encoding, verbatim from `BoxNegReachabilityProbe.lean`. -/
def row9 (fuel : Nat) : Nat × Nat :=
  match buildTableau anchor fuel .Base with
  | none => (0, 0)
  | some (.allClosed bs) => (1, bs.length)
  | some (.hasOpen ob _ _ _) => (2, ob.length)

def main : IO Unit := do
  let out ← IO.getStdout
  IO.println "=== C. decide-constructor discrimination at a fuel level that RETURNS ==="
  out.flush
  for f in [400, 450] do
    let t0 ← IO.monoMsNow
    let r9 := row9 f
    let t1 ← IO.monoMsNow
    IO.println s!"  row9-encoding buildTableau fuel={f}: {r9}  ({t1 - t0} ms)"
    out.flush
    let t2 ← IO.monoMsNow
    let r := decide anchor 10 f
    let tup := (r.isValid, r.isInvalid, r.isFuelExhausted, r.isExtractionFailed, r.isUndecided)
    let t3 ← IO.monoMsNow
    IO.println s!"  decide fuel={f} (isValid,isInvalid,isFuelExh,isExtrFail,isUndec) = {tup}  ({t3 - t2} ms)"
    out.flush
    let t4 ← IO.monoMsNow
    let cm := (decide anchor 10 f).getCountermodel?.isSome
    let t5 ← IO.monoMsNow
    IO.println s!"  decide fuel={f} getCountermodel?.isSome = {cm}  ({t5 - t4} ms)"
    out.flush
  IO.println "=== DONE ==="
  out.flush
