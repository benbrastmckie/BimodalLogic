import FormalSystem.Metalogic.Decidability.RaySummary.SeamMulti

/-!
# Research probe: B3a — a computable `kTypeOf` on finite decidable structures

Tests the predecessor's HIGH-risk claim that "`kTypeOf` is `Classical.dec` by design" blocks an
effective `k`-type. It does not: `NfEvalNf` is a finite conjunction of finite quantifications
once the carrier is a `Fintype` with decidable order and decidable predicates, so a `Decidable`
instance follows by induction on the depth `k`, and the resulting `kTypeOfFin` agrees with the
library's classical `kTypeOf` pointwise (`decide` is instance-irrelevant).

What this probe does NOT do: it composes nothing, decides nothing about `Hit`, and claims no
complexity bound. The `#eval` lines are sanity checks on a 3-point and a 5-point segment at
depth 1 (expected: exactly one depth-1 normal form holds — `nf_exists_unique` — and the two
segments have equal depth-1 types).

Every instance below is written as an explicit term: `inferInstanceAs` on `ℤ`-subtypes picks up
`Int.instConditionallyCompleteLinearOrder`, which is noncomputable, and would make the whole
device noncomputable for no mathematical reason.
-/

namespace Probe742

open FormalSystem.Metalogic.Expressiveness FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Decidability.RaySummary

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-- The decidability data a finite structure carries for `NfEvalNf` to be decided. -/
class FinDec (M : OrderedMonadicStructure sig) where
  fin : Fintype M.carrier
  deq : DecidableEq M.carrier
  dlt : ∀ x y : M.carrier, Decidable (x < y)
  dint : ∀ p, DecidablePred (M.interp p)

def decAtomEval (M : OrderedMonadicStructure sig) [FinDec M] {n : ℕ}
    (env : Fin n → M.carrier) : (a : AtomKind sig n) → Decidable (AtomEval M env a)
  | .pred p i => FinDec.dint p (env i)
  | .order i j _ => FinDec.dlt (env i) (env j)

/-- `NfEvalNf` is decidable on a finite decidable structure, by induction on the depth. -/
def decNfEvalNf (M : OrderedMonadicStructure sig) [FinDec M] :
    (k n : ℕ) → (env : Fin n → M.carrier) → (nf : NormalForm sig k n) →
      Decidable (NfEvalNf M k n env nf)
  | 0, n, env, nf =>
      @Fintype.decidableForallFintype (AtomKind sig n)
        (fun a => AtomEval M env a ↔ (nf a = true))
        (fun a => @instDecidableIff _ _ (decAtomEval M env a) (instDecidableEqBool _ _))
        (atomKindFintype sig n)
  | k + 1, n, env, ⟨atomA, quantA⟩ =>
      let dAtoms : Decidable (∀ a : AtomKind sig n, AtomEval M env a ↔ (atomA a = true)) :=
        @Fintype.decidableForallFintype (AtomKind sig n)
          (fun a => AtomEval M env a ↔ (atomA a = true))
          (fun a => @instDecidableIff _ _ (decAtomEval M env a) (instDecidableEqBool _ _))
          (atomKindFintype sig n)
      let dEx : ∀ sub_nf : NormalForm sig k (n + 1),
          Decidable (∃ x : M.carrier, NfEvalNf M k (n + 1) (Fin.cons x env) sub_nf) :=
        fun sub_nf =>
          @Fintype.decidableExistsFintype M.carrier
            (fun x => NfEvalNf M k (n + 1) (Fin.cons x env) sub_nf)
            (fun x => decNfEvalNf M k (n + 1) (Fin.cons x env) sub_nf)
            FinDec.fin
      let dQuant : Decidable (∀ sub_nf : NormalForm sig k (n + 1),
          (∃ x : M.carrier, NfEvalNf M k (n + 1) (Fin.cons x env) sub_nf) ↔
            (quantA sub_nf = true)) :=
        @Fintype.decidableForallFintype (NormalForm sig k (n + 1))
          (fun sub_nf => (∃ x : M.carrier, NfEvalNf M k (n + 1) (Fin.cons x env) sub_nf) ↔
            (quantA sub_nf = true))
          (fun sub_nf => @instDecidableIff _ _ (dEx sub_nf) (instDecidableEqBool _ _))
          (normalFormFintype sig k (n + 1))
      @instDecidableAnd _ _ dAtoms dQuant

/-- **The computable `k`-type** of a finite decidable structure. -/
def kTypeOfFin (M : OrderedMonadicStructure sig) [FinDec M] (k : ℕ) : KType sig k :=
  fun nf => @decide (NfEvalNf M k 0 Fin.elim0 nf) (decNfEvalNf M k 0 Fin.elim0 nf)

/-- It is the library's `k`-type: `decide` does not depend on the instance. -/
theorem kTypeOfFin_eq (M : OrderedMonadicStructure sig) [FinDec M] (k : ℕ) :
    kTypeOfFin M k = kTypeOf sig k M := by
  funext nf
  unfold kTypeOfFin kTypeOf
  exact decide_eq_decide.mpr Iff.rfl

/-- A half-open segment of a decidable colouring is finite and decidable. -/
instance segZFinDec (c : sig.preds → ℤ → Prop) [∀ p, DecidablePred (c p)] (a b : ℤ) :
    FinDec (segZ sig c a b) where
  fin := Fintype.subtype (@Finset.Ico ℤ Int.instLinearOrder.toPartialOrder.toPreorder
    Int.instLocallyFiniteOrder a b) (fun _ => Finset.mem_Ico)
  deq := fun x y =>
    @decidable_of_iff (x = y) (x.1 = y.1) ⟨Subtype.ext, congrArg Subtype.val⟩ (Int.decEq x.1 y.1)
  dlt := fun x y => @decidable_of_iff (x.1 < y.1) (x < y) Iff.rfl (Int.decLt x.1 y.1)
  dint := fun p t => inferInstanceAs (Decidable (c p t.1))

/-- The computable `k`-type of a segment is the segment's `k`-type. -/
theorem kTypeOfFin_segZ (c : sig.preds → ℤ → Prop) [∀ p, DecidablePred (c p)] (a b : ℤ)
    (k : ℕ) : kTypeOfFin (segZ sig c a b) k = kTypeOf sig k (segZ sig c a b) :=
  kTypeOfFin_eq _ k

/-! ## Sanity checks on the two-letter alphabet (no claim beyond "it runs") -/

/-- `now` exactly at `0`; the letter `φ` at the even times. -/
def cBool : Bool → ℤ → Bool := fun p z => bif p then decide (z = 0) else decide (z % 2 = 0)

def c2 : twoLetter.preds → ℤ → Prop := fun p z => cBool p z = true

instance : ∀ p, DecidablePred (c2 p) := fun _ _ => inferInstanceAs (Decidable (_ = true))

-- Exactly one depth-1 normal form holds on `[0, 3)` (`nf_exists_unique`). Expected: `1`.
#eval (Finset.univ.filter (fun nf => kTypeOfFin (segZ twoLetter c2 0 3) 1 nf = true)).card

-- `[0, 3)` and `[0, 5)` have the same depth-1 type (both realise `now ∧ φ`, `¬now ∧ φ`,
-- `¬now ∧ ¬φ`); `[0, 1)` does not. Expected: `true`, then `false`.
#eval decide (kTypeOfFin (segZ twoLetter c2 0 3) 1 = kTypeOfFin (segZ twoLetter c2 0 5) 1)
#eval decide (kTypeOfFin (segZ twoLetter c2 0 3) 1 = kTypeOfFin (segZ twoLetter c2 0 1) 1)

#print axioms kTypeOfFin_eq
#print axioms kTypeOfFin_segZ

end Probe742
