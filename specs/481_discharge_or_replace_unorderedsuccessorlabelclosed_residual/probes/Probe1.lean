import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound

namespace FormalSystem.Metalogic.Decidability
open FormalSystem.Syntax

private def gp : Formula := .atom (Atom.mkBase "p")

/-- Generalized witness at an arbitrary label. -/
def gWitness (l : Label) : SignedFormula := SignedFormula.neg (Formula.box gp) l
def gBranch (l : Label) : Branch := [gWitness l]

-- probe 1: are the isApplicable facts rfl at a variable label?
example (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .boxNeg (gWitness l) fc = true := rfl

example (fc : FormalSystem.ProofSystem.FrameClass) (l : Label) :
    isApplicable .boxPos (gWitness l) fc = false := rfl

example (l : Label) : ruleMintsFreshLabel .boxNeg = true := rfl

example (l : Label) :
    witnessPresent .boxNeg (gWitness l) (gBranch l) TimeOrdering.empty = false := rfl

example (l : Label) :
    trivialEventWitnessed .boxNeg (gWitness l) (gBranch l) TimeOrdering.empty = false := rfl

example (l : Label) : Branch.nextWorld (gBranch l) = l.world + 1 := by
  simp [Branch.nextWorld, Branch.maxWorld, gBranch, gWitness, SignedFormula.neg]

