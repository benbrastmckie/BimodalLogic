import Bimodal.Metalogic.Decidability.CancellableExpansion

open Bimodal.Syntax
open Bimodal.Metalogic.Decidability

/-- Observable tag for an `Option ExpandedTableau` result. -/
def tag2 : Option ExpandedTableau → String
  | none => "none/aborted"
  | some (.allClosed _) => "closed"
  | some (.hasOpen ..) => "open"

-- Task 343 Phase 5 abort-mechanism check: with the abort flag PRE-SET, the
-- cancellable tableau must observe the abort and return `none` promptly at
-- every recursive step, rather than running the expansion to fuel exhaustion.
-- Contrast: abort-unset runs normally (already covered by spotcheck_mirror).
#eval show IO Unit from do
  let p := Formula.atom ⟨"p", none⟩
  let q := Formula.atom ⟨"q", none⟩
  -- A formula whose (unbounded) expansion is nontrivial; with abort preset the
  -- run must not depend on fuel at all.
  let φ : Formula := .imp (.box (.box p)) (.untl q (.box p))
  -- 1. Abort PRE-SET → must return none (aborted) even with huge fuel.
  let abortRef ← IO.mkRef true
  let t0 ← IO.monoNanosNow
  let aborted ← buildTableauCancellable abortRef φ 1000000
  let t1 ← IO.monoNanosNow
  IO.println s!"[abort] preset-abort, fuel=1000000 : {tag2 aborted}  ({(t1 - t0) / 1000} µs)"
  if aborted.isSome then
    IO.println "[abort] FAIL: preset abort did not short-circuit (expected none)"
  else
    IO.println "[abort] OK: preset abort short-circuits to none regardless of fuel"
  -- 2. Decision-level: preset abort must map to a non-valid/non-invalid result.
  let abortRef2 ← IO.mkRef true
  let (res, note) ← decideAutoAdaptiveCancellable abortRef2 φ .Base 500
  let label := match res with
    | .valid _ => "valid"
    | .invalid _ => "invalid"
    | .timeout => "timeout"
  IO.println s!"[abort] decideAutoAdaptiveCancellable preset-abort : {label}  (note={note})"
  match res with
  | .valid _ | .invalid _ =>
      IO.println "[abort] FAIL: aborted decision produced valid/invalid (must be timeout)"
  | .timeout =>
      IO.println "[abort] OK: aborted decision maps to timeout (never valid/invalid)"
