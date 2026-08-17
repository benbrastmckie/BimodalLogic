import FormalSystem.Metalogic.Decidability.IntPresentation
import FormalSystem.Semantics.Truth

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

namespace Probe2

/-- Two states, universal one-step relation: every function `ℤ → Fin 2` is a legal history. -/
def univ2 : IntPresentation where
  card := 2
  card_pos := by omega
  step := fun _ _ => true
  val := fun _ w => w == 0
  fwd := fun w => ⟨w, rfl⟩
  bwd := fun w => ⟨w, rfl⟩

/-- Satisfiability at a state: the reading the planned `check_correct` bridge assigns to
`check P w φ = true`. -/
def Sat (P : IntPresentation) (w : Fin P.card) (φ : Formula) : Prop :=
  ∃ τ : P.toTaskFrame.HF, τ.path 0 = w ∧ TruthAt P.toModel τ.val 0 φ

/-- Every function into `univ2`'s carrier is a step path. -/
theorem univ2_all (f : ℤ → Fin univ2.card) : IsStepPath univ2.toTaskFrame f := by
  rw [univ2.isStepPath_iff]; intro _; rfl

/-- The `H_F` member a bare function determines. -/
noncomputable def hist (f : ℤ → Fin univ2.card) : univ2.toTaskFrame.HF :=
  TaskFrame.HFofStepPath univ2.toTaskFrame f (univ2_all f)

theorem hist_path (f : ℤ → Fin univ2.card) : (hist f).path = f := rfl

/-- Truth of an atom at a `hist` reduces to the valuation at the state. -/
theorem truth_atom (f : ℤ → Fin univ2.card) (t : ℤ) (p : Atom) :
    TruthAt univ2.toModel (hist f).val t (Formula.atom p) ↔ (f t == 0) = true :=
  ⟨fun ⟨_, h⟩ => h, fun h => ⟨trivial, h⟩⟩

/-- `⊤`, as this `Formula` type spells it. -/
def top : Formula := Formula.imp Formula.bot Formula.bot

/-- "`p` holds at some strictly future time". -/
def someFutureP (p : Atom) : Formula := Formula.untl (Formula.atom p) top

section
variable (p : Atom)

/-- FACT 1. At state `1`, `someFutureP p` is satisfiable: the path that sits at `1` until time 0
and drops to `0` afterwards witnesses it. -/
theorem fact1 : Sat univ2 1 (someFutureP p) := by
  refine ⟨hist (fun n => if 0 < n then 0 else 1), by simp [hist_path] <;> rfl, ?_⟩
  refine ⟨1, by decide, ?_, ?_⟩
  · exact (truth_atom _ 1 p).mpr (by decide)
  · intro r _ hr2; exact fun h => h

/-- FACT 2. `⊥` is never satisfiable. -/
theorem fact2 : ¬ Sat univ2 1 Formula.bot := fun ⟨_, _, h⟩ => h

/-- FACT 3. At state `1`, `someFutureP p → ⊥` IS satisfiable: the constant-`1` path never makes
`p` true, so the antecedent fails and the implication holds vacuously. -/
theorem fact3 : Sat univ2 1 (Formula.imp (someFutureP p) Formula.bot) := by
  refine ⟨hist (fun _ => 1), rfl, ?_⟩
  rintro ⟨s, _, hp, _⟩
  exact absurd ((truth_atom _ s p).mp hp) (by decide)

/-- FACT 4. At state `0`, `p → ⊥` is NOT satisfiable: every history through state `0` at time 0
makes `p` true there, so the implication would need `⊥`. -/
theorem fact4 : ¬ Sat univ2 0 (Formula.imp (Formula.atom p) Formula.bot) := by
  rintro ⟨τ, h0, himp⟩
  refine himp ⟨τ.property 0, ?_⟩
  show univ2.val p (τ.path 0) = true
  rw [h0]; rfl

/-- FACT 5. At state `0`, `p` alone IS satisfiable. -/
theorem fact5 : Sat univ2 0 (Formula.atom p) :=
  ⟨hist (fun _ => 0), rfl, (truth_atom _ 0 p).mpr rfl⟩

/--
**No `Bool`-valued, formula-structurally-recursive `check` can compute `Sat`.**

`Formula.imp` breaks compositionality: the two instances below feed the *same* pair of truth
values `(true, false)` to the implication clause, yet the implication's own satisfiability differs.
So no function `g : Bool → Bool → Bool` can serve as `check`'s `imp` case.
-/
theorem no_compositional_imp (p : Atom)
    (g : Prop → Prop → Prop)
    (hg : ∀ (w : Fin univ2.card) (φ ψ : Formula),
      Sat univ2 w (Formula.imp φ ψ) ↔ g (Sat univ2 w φ) (Sat univ2 w ψ)) : False := by
  have e1 : Sat univ2 1 (someFutureP p) ↔ Sat univ2 0 (Formula.atom p) :=
    ⟨fun _ => fact5 p, fun _ => fact1 p⟩
  have e2 : Sat univ2 1 Formula.bot ↔ Sat univ2 0 Formula.bot :=
    ⟨fun h => absurd h (fact2), fun ⟨_, _, h⟩ => h.elim⟩
  have h3 := (hg 1 (someFutureP p) Formula.bot).mp (fact3 p)
  rw [propext e1, propext e2] at h3
  exact fact4 p ((hg 0 (Formula.atom p) Formula.bot).mpr h3)

end

end Probe2
