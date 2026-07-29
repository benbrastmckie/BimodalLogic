import FormalSystem.Metalogic.Decidability.DecisionProcedure

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

def p : Formula := .atom (Atom.mkBase "p")
def gp : Formula := Formula.allFuture p

def b0 : Branch :=
  [ SignedFormula.pos gp { world := 0, time := 0 }
  , SignedFormula.neg (Formula.box gp) { world := 0, time := 0 } ]

def rulePos (r : TableauRule) : Nat :=
  match allRules.findIdx? (fun s => s == r) with
  | some i => i
  | none => 999

def step (bo : Branch × TimeOrdering) : List (Branch × TimeOrdering) :=
  match expandOnceUnblocked bo.1 bo.2 .Base with
  | (.saturated, o) => [(bo.1, o)]
  | (.extended b', o) => [(b', o)]
  | (.split bs, o) => bs.map fun b' => (b', o)
  | (.splitOrdered ps, _) => ps

def run : Nat → List (Branch × TimeOrdering) → List (Branch × TimeOrdering)
  | 0, bs => bs
  | n + 1, bs =>
      run n (bs.flatMap fun bo => if isClosed bo.1 .Base then [bo] else step bo)

def reached : List (Branch × TimeOrdering) := run 12 [(b0, TimeOrdering.empty)]

def clashAtFreshWorld (b : Branch) : Bool :=
  b.contains (SignedFormula.pos gp { world := 1, time := 0 })
    && b.contains (SignedFormula.neg gp { world := 1, time := 0 })

def main : IO Unit := do
  let out ← IO.getStdout
  IO.println s!"row1 (negPos < boxNeg)          = {Nat.blt (rulePos .negPos) (rulePos .boxNeg)}"; out.flush
  IO.println s!"row2 (boxNeg < impPos)          = {Nat.blt (rulePos .boxNeg) (rulePos .impPos)}"; out.flush
  IO.println s!"row3 (boxNeg < allFuturePos)    = {Nat.blt (rulePos .boxNeg) (rulePos .allFuturePos)}"; out.flush
  IO.println s!"row4 (T(G p) on every reached)  = {reached.all fun bo => bo.1.contains (SignedFormula.pos gp { world := 0, time := 0 })}"; out.flush
  IO.println s!"row5 (F(G p) at minted world)   = {reached.any fun bo => bo.1.contains (SignedFormula.neg gp { world := 1, time := 0 })}"; out.flush
  IO.println s!"row6 (clash at fresh world)     = {reached.any fun bo => clashAtFreshWorld bo.1}"; out.flush
  IO.println s!"row7 (reached.length, #open)    = {(reached.length, (reached.filter fun bo => !isClosed bo.1 .Base).length)}"; out.flush
  IO.println s!"row8 (closure reason of head)   = {(reached.head?.bind fun bo => findClosure bo.1 .Base).map fun cr => match cr with | .contradiction _ l => (1, l.world, l.time) | .botPos l => (2, l.world, l.time) | .axiomNeg _ _ l => (3, l.world, l.time)}"; out.flush
  IO.println "=== DONE ==="; out.flush
