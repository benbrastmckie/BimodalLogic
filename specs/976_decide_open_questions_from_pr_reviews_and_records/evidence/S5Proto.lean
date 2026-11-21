import FormalSystem.Theorems.ProofMode.PlusDiscrete
import FormalSystem.Theorems.Combinators

/-! Prototype: two ways to carry the shared S5 statement, against the Kit/Step shape of PR #7. -/
namespace S5Proto
open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage

-- Kit and Step as in PR #7's Congruence.lean (trans/refl dropped: not needed for the modal step).
structure Kit (L : Type) (P : L → Type) where
  imp : L → L → L

structure Step {L : Type} {P : L → Type} (kit : Kit L P) where
  wrap : L → L
  demand : L → L
  flips : Bool
  transfer : ∀ A B, P (kit.imp (demand (kit.imp A B))
    (if flips then kit.imp (wrap B) (wrap A) else kit.imp (wrap A) (wrap B)))
  demandMono : ∀ {A B}, P (kit.imp A B) → P (kit.imp (demand A) (demand B))

/-! ## Variant A: a structure with the operator as a field -/
structure Necessity {L : Type} {P : L → Type} (kit : Kit L P) where
  box : L → L
  mp : ∀ {A B}, P (kit.imp A B) → P A → P B
  nec : ∀ {A}, P A → P (box A)
  k : ∀ A B, P (kit.imp (box (kit.imp A B)) (kit.imp (box A) (box B)))
  t : ∀ A, P (kit.imp (box A) A)
  four : ∀ A, P (kit.imp (box A) (box (box A)))

/-- ONE modal congruence step, taking the operator. -/
def Necessity.step {L P} {kit : Kit L P} (N : Necessity kit) : Step kit where
  wrap := N.box
  demand := N.box
  flips := false
  transfer := N.k
  demandMono h := N.mp (N.k _ _) (N.nec h)

variable (fc : FrameClass)
def plusKit : Kit PlusFormula (PlusDerivationTree fc []) where imp := PlusFormula.imp
def tmKit : Kit Formula (DerivationTree fc []) where imp := Formula.imp

def plusBoxN : Necessity (plusKit fc) where
  box := PlusFormula.box
  mp hAB hA := .modus_ponens [] _ _ hAB hA
  nec h := .necessitation _ h
  k A B := .axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)
  t A := .axiom [] _ (.modal_t A) (FrameClass.base_le fc)
  four A := .axiom [] _ (.modal_4 A) (FrameClass.base_le fc)

def plusStabN : Necessity (plusKit fc) where
  box := PlusFormula.stab
  mp hAB hA := .modus_ponens [] _ _ hAB hA
  nec h := stabNecessitation h
  k A B := .axiom [] _ (.stab_k A B) (FrameClass.base_le fc)
  t A := .axiom [] _ (.stab_t A) (FrameClass.base_le fc)
  four A := .axiom [] _ (.stab_4 A) (FrameClass.base_le fc)

def tmBoxN : Necessity (tmKit fc) where
  box := Formula.box
  mp hAB hA := .modus_ponens [] _ _ hAB hA
  nec h := .necessitation _ h
  k A B := .axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)
  t A := .axiom [] _ (.modal_t A) (FrameClass.base_le fc)
  four A := FormalSystem.ProofSystem.DerivedAxioms.modal4 A

-- the two TM⁺ steps and the TM step are the same definition at three arguments
example : Step (plusKit fc) := (plusBoxN fc).step
example : Step (plusKit fc) := (plusStabN fc).step
example : Step (tmKit fc) := (tmBoxN fc).step
example : ((plusStabN fc).step).wrap = PlusFormula.stab := rfl

/-! ## Variant B: a class indexed by the operator -/
class S5Nec {L : Type} {P : L → Type} (kit : Kit L P) (box : L → L) where
  mp : ∀ {A B}, P (kit.imp A B) → P A → P B
  nec : ∀ {A}, P A → P (box A)
  k : ∀ A B, P (kit.imp (box (kit.imp A B)) (kit.imp (box A) (box B)))
  t : ∀ A, P (kit.imp (box A) A)

instance : S5Nec (plusKit fc) PlusFormula.box where
  mp hAB hA := .modus_ponens [] _ _ hAB hA
  nec h := .necessitation _ h
  k A B := .axiom [] _ (.modal_k_dist A B) (FrameClass.base_le fc)
  t A := .axiom [] _ (.modal_t A) (FrameClass.base_le fc)

instance : S5Nec (plusKit fc) PlusFormula.stab where
  mp hAB hA := .modus_ponens [] _ _ hAB hA
  nec h := stabNecessitation h
  k A B := .axiom [] _ (.stab_k A B) (FrameClass.base_le fc)
  t A := .axiom [] _ (.stab_t A) (FrameClass.base_le fc)

def classStep {L P} (kit : Kit L P) (box : L → L) [S5Nec kit box] : Step kit where
  wrap := box
  demand := box
  flips := false
  transfer := S5Nec.k
  demandMono h := S5Nec.mp (kit := kit) (box := box) (S5Nec.k _ _) (S5Nec.nec (kit := kit) (box := box) h)

-- two instances on one formula type coexist when the operator is the index
example : Step (plusKit fc) := classStep (plusKit fc) PlusFormula.box
example : Step (plusKit fc) := classStep (plusKit fc) PlusFormula.stab
-- B1: is the operator inferred from a goal? (no explicit box)
example (A : PlusFormula) : PlusDerivationTree fc [] ((PlusFormula.stab A).imp A) :=
  S5Nec.t (kit := plusKit fc) A
-- B2: lambda-presented operator
example : Step (plusKit fc) := classStep (plusKit fc) (fun x => PlusFormula.stab x)
-- B3: an operator presented through a definition
def myStab : PlusFormula → PlusFormula := PlusFormula.stab
/-- error: failed to synthesize instance of type class
  S5Nec (plusKit fc) myStab

Hint: Type class instance resolution failures can be inspected with the `set_option trace.Meta.synthInstance true` command. -/
#guard_msgs in
example : Step (plusKit fc) := classStep (plusKit fc) myStab
-- B4: the same through the structure: no resolution involved
example : Step (plusKit fc) := ({ plusStabN fc with box := myStab } : Necessity (plusKit fc)).step

end S5Proto
