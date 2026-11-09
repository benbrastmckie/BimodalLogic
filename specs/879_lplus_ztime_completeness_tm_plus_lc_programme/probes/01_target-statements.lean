-- Elaborated this session with lean_run_code under `import FormalSystem` (success, no errors).
-- Stated, not proved: T1/T2/T3 are `Prop` definitions; no `theorem`, no `sorry`.
import FormalSystem

open FormalSystem.Syntax FormalSystem.ProofSystem FormalSystem.PlusLanguage
open FormalSystem.Metalogic.NamingRules

namespace Target879

open PlusFormula

/-- `LCU`, the until-form limit-closure schema (report 03 §2.3), in primitive syntax. -/
def lcU (α β : PlusFormula) : PlusFormula :=
  (PlusFormula.stab (PlusFormula.gle
      ((dstab α).imp (dstab (PlusFormula.untl (dstab β) (dstab α)))))).imp
    ((dstab α).imp (dstab (PlusFormula.gle
      ((dstab α).or (PlusFormula.untl (dstab β) (dstab α))))))

def IsLCAxiom (ψ : PlusFormula) : Prop :=
  ∃ (n : ℕ) (α : ℕ → PlusFormula), 0 < n ∧ (ψ = lcN n α ∨ ψ = (lcN n α).reflectTime)

def IsLCUAxiom (ψ : PlusFormula) : Prop :=
  ∃ α β : PlusFormula, ψ = lcU α β ∨ ψ = (lcU α β).reflectTime

structure RuleSet where
  clock : Bool
  aaFwd : Bool
  aaBwd : Bool

def RuleSet.none : RuleSet := ⟨false, false, false⟩
def RuleSet.all : RuleSet := ⟨true, true, true⟩

def listAnd : List PlusFormula → PlusFormula
  | [] => PlusFormula.bot.imp PlusFormula.bot
  | φ :: φs => φ.and (listAnd φs)

def bigOr (k : ℕ) (a : ℕ → PlusFormula) : PlusFormula :=
  (bigAnd k fun i => (a i).neg).neg

/-- The machine step: `⊡G≤ ⋀_{b ∈ Q, i < k} ((b ∧ aᵢ) → ⊡X p(b,i))`. -/
def aaStep (Q : List Atom) (k : ℕ) (a : ℕ → PlusFormula) (p : Atom → ℕ → Atom) : PlusFormula :=
  PlusFormula.stab (PlusFormula.gle (listAnd (Q.map fun b => bigAnd k fun i =>
    ((PlusFormula.atom b).and (a i)).imp
      (PlusFormula.stab (PlusFormula.next (PlusFormula.atom (p b i)))))))

/-- Exclusivity: `⊡G≤ ⋀_{b ≠ b'} ¬(b ∧ b')`. -/
def aaExcl (Q : List Atom) : PlusFormula :=
  PlusFormula.stab (PlusFormula.gle (listAnd (Q.map fun b => listAnd (Q.map fun b' =>
    if b = b' then PlusFormula.bot.imp PlusFormula.bot
    else ((PlusFormula.atom b).and (PlusFormula.atom b')).neg))))

/-- The Auxiliary-Atoms antecedent `θ⊡`, anchored at the evaluation point. -/
def aaAnte (b₀ : Atom) (Q : List Atom) (k : ℕ) (a : ℕ → PlusFormula) (p : Atom → ℕ → Atom) :
    PlusFormula :=
  (PlusFormula.atom b₀).and ((aaStep Q k a p).and (aaExcl Q))

/-- Theoremhood in TM⁺ + `Ax` + the rules enabled by `R`, at frame class `fc`. -/
inductive ExtDerivation (fc : FrameClass) (Ax : PlusFormula → Prop) (R : RuleSet) :
    PlusFormula → Prop
  | tm {φ} (d : PlusDerivable fc [] φ) : ExtDerivation fc Ax R φ
  | ax {φ} (h : Ax φ) : ExtDerivation fc Ax R φ
  | mp {φ ψ} (d₁ : ExtDerivation fc Ax R (φ.imp ψ)) (d₂ : ExtDerivation fc Ax R φ) :
      ExtDerivation fc Ax R ψ
  | nec {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R (PlusFormula.box φ)
  | tnec {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R φ.allFuture
  | refl {φ} (d : ExtDerivation fc Ax R φ) : ExtDerivation fc Ax R φ.reflectTime
  | clock {q φ} (hR : R.clock = true) (hq : Fresh q φ)
      (d : ExtDerivation fc Ax R ((clockAnte q).imp φ)) : ExtDerivation fc Ax R φ
  | aaFwd {φ} (hR : R.aaFwd = true) (b₀ : Atom) (Q : List Atom) (k : ℕ)
      (a : ℕ → PlusFormula) (p : Atom → ℕ → Atom)
      (hb : b₀ ∈ Q) (hp : ∀ b ∈ Q, ∀ i < k, p b i ∈ Q)
      (hsl : ∀ i < k, PlusFormula.StateLocal (a i))
      (hfresh : ∀ b ∈ Q, Fresh b φ ∧ ∀ i < k, Fresh b (a i))
      (hexh : ExtDerivation fc Ax R (bigOr k a))
      (hexcl : ∀ i < k, ∀ j < k, i ≠ j → ExtDerivation fc Ax R ((a i).and (a j)).neg)
      (d : ExtDerivation fc Ax R ((aaAnte b₀ Q k a p).imp φ)) : ExtDerivation fc Ax R φ
  | aaBwd {φ} (hR : R.aaBwd = true) (b₀ : Atom) (Q : List Atom) (k : ℕ)
      (a : ℕ → PlusFormula) (p : Atom → ℕ → Atom)
      (hb : b₀ ∈ Q) (hp : ∀ b ∈ Q, ∀ i < k, p b i ∈ Q)
      (hsl : ∀ i < k, PlusFormula.StateLocal (a i))
      (hfresh : ∀ b ∈ Q, Fresh b φ ∧ ∀ i < k, Fresh b (a i))
      (hexh : ExtDerivation fc Ax R (bigOr k a))
      (hexcl : ∀ i < k, ∀ j < k, i ≠ j → ExtDerivation fc Ax R ((a i).and (a j)).neg)
      (d : ExtDerivation fc Ax R ((aaAnte b₀ Q k a p).reflectTime.imp φ)) : ExtDerivation fc Ax R φ

def ExtSound (Ax : PlusFormula → Prop) (R : RuleSet) : Prop :=
  ∀ φ : PlusFormula, ExtDerivation FrameClass.ZTime Ax R φ → PlusValidZTime φ

def ExtComplete (Ax : PlusFormula → Prop) (R : RuleSet) : Prop :=
  ∀ φ : PlusFormula, PlusValidZTime φ → ExtDerivation FrameClass.ZTime Ax R φ

/-- T1: the dispatch's literal question — TM⁺ + LC_n + backward LC_n, no rules. -/
def T1 : Prop := ExtComplete IsLCAxiom RuleSet.none
/-- T2: the same schema set with the three naming rules. -/
def T2 : Prop := ExtComplete IsLCAxiom RuleSet.all
/-- T3: the Reynolds-2001 transposition — until-form schema plus the three rules. -/
def T3 : Prop := ExtComplete IsLCUAxiom RuleSet.all

example (n : ℕ) (hn : 0 < n) (α : ℕ → PlusFormula) : PlusValidZTime (lcN n α) ∧
    PlusValidZTime (lcN n α).reflectTime :=
  ⟨lcN_plusValidZTime n hn α, lcN_reflectTime_plusValidZTime n hn α⟩

end Target879
