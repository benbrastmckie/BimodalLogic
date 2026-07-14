import Bimodal.Metalogic.Decidability.CancellableExpansion

open Bimodal.Syntax
open Bimodal.Metalogic.Decidability

/-- Observable tag for an `Option ExpandedTableau` result (avoids needing
    `DecidableEq` on the full structure). -/
def resultTag : Option ExpandedTableau → String
  | none => "none"
  | some (.allClosed _) => "closed"
  | some (.hasOpen ..) => "open"

-- Task 343 Phase 5 mirror spot-check: `buildTableauCancellable` with the abort
-- ref never set must agree with the pure `buildTableau` on sample formulas.
#eval show IO Unit from do
  let p := Formula.atom ⟨"p", none⟩
  let q := Formula.atom ⟨"q", none⟩
  let r := Formula.atom ⟨"r", none⟩
  let samples : List Formula := [
    .imp p .bot,                                 -- invalid
    .imp (.box p) .bot,                          -- invalid
    .imp p (.untl .bot q),                       -- invalid
    .imp p (.box .bot),                          -- invalid
    .imp (Formula.and p q) .bot,                 -- invalid
    .imp (.box (.box p)) (.untl .bot q),         -- invalid
    .imp p (.snce .bot q),                       -- invalid
    .imp (.untl p q) (.untl .bot r),             -- invalid
    .imp p p,                                     -- valid
    .imp (.box p) p,                             -- valid
    .imp (.box p) (.box (.box p)),               -- valid
    .imp (Formula.imp .bot .bot) .bot,           -- ⊤ → ⊥ invalid
    .imp (.untl p q) (.untl q (Formula.imp .bot .bot)) -- valid
  ]
  let abortRef ← IO.mkRef false
  let mut allMatch := true
  let mut idx := 0
  for φ in samples do
    idx := idx + 1
    let pureTag := resultTag (buildTableau φ 1000)
    let cancRes ← buildTableauCancellable abortRef φ 1000
    let cancTag := resultTag cancRes
    if pureTag == cancTag then
      IO.println s!"[spotcheck] OK   #{idx} : {pureTag}"
    else
      IO.println s!"[spotcheck] MISMATCH #{idx} : pure={pureTag} canc={cancTag}"
      allMatch := false
  if allMatch then
    IO.println "[spotcheck] PASS: mirror (abort never set) == pure buildTableau on all samples"
  else
    IO.println "[spotcheck] FAIL: mirror diverges from pure on some sample"
