import FormalSystem.Metalogic.Decidability.RaySummary.Present

/-!
# Crux probe B: the `Cons P` untl core

Does a *decidable, local* consistency condition on a finite labelled presentation force the
`untl` clause of `LocalRun` on every run? This is the hardest new obligation (S) carries, and
the one `Probe735.not_presented`'s pumping argument says must be there.
-/

namespace Probe746B

open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Expressiveness

set_option linter.unusedSectionVars false

variable {sig : MonadicSignature} {Q : Type} [Fintype Q] [DecidableEq Q]
  (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u g e : sig.preds)

/-- **One-step unfolding coherence** for the `untl` letter `u`, guard `g`, event `e`:
`PlusTruthAt`'s `untl` clause unfolded across one step. Decidable, per edge. -/
def UCoh : Prop :=
  ∀ q q', step q q' = true →
    (lab q u = true ↔ (lab q' e = true ∨ (lab q' g = true ∧ lab q' u = true)))

/-- **The deferral graph**: an edge out of every state claiming `u` without carrying `e`.
An infinite chain in it is a run deferring the eventuality forever — exactly what
`Probe735.pump_isRun` manufactures from a repeated state. -/
def deferGraph {sig : MonadicSignature} {Q : Type} (lab : Q → sig.preds → Bool)
    (step : Q → Q → Bool) (u e : sig.preds) (x y : Q) : Bool :=
  lab x u && !(lab x e) && step x y

/-- **No-deferral liveness**: no state begins an infinite `u`-claiming, `e`-free chain.
Decidable through `Present.lean`'s `live`. -/
def ULive {sig : MonadicSignature} {Q : Type} [Fintype Q] [DecidableEq Q]
    (lab : Q → sig.preds → Bool) (step : Q → Q → Bool) (u e : sig.preds) : Prop :=
  ∀ q, live (deferGraph lab step u e) q = false

/-- The discharge condition at `z` along `ρ`, i.e. the right-hand side of `LocalRun.untl`. -/
def Disch (ρ : ℤ → Q) (z : ℤ) : Prop :=
  ∃ s, z < s ∧ lab (ρ s) e = true ∧ ∀ r, z < r → r < s → lab (ρ r) g = true

/-- **Persistence along an undischarged stretch**: if the claim holds at `z` and is never
discharged, then from `z + 1` on the run claims `u`, carries the guard, and never carries `e`.
The whole content of the `untl` run condition's hard direction is here. -/
theorem persist (hco : UCoh lab step u g e) {ρ : ℤ → Q}
    (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) {z : ℤ}
    (hu : lab (ρ z) u = true) (hno : ¬ Disch lab g e ρ z) :
    ∀ n : ℕ, ∀ m : ℕ, m ≤ n →
      lab (ρ (z + 1 + m)) u = true ∧ lab (ρ (z + 1 + m)) e = false
        ∧ lab (ρ (z + 1 + m)) g = true := by
  intro n
  induction n with
  | zero =>
    intro m hm
    have hm0 : m = 0 := Nat.le_zero.mp hm
    subst hm0
    have h := (hco (ρ z) (ρ (z + 1)) (hstep z)).mp hu
    have hz1 : z + 1 + ((0 : ℕ) : ℤ) = z + 1 := by norm_num
    rw [hz1]
    rcases h with he | ⟨hg, hu'⟩
    · exact absurd ⟨z + 1, by omega, he, fun r h1 h2 => absurd h2 (by omega)⟩ hno
    · refine ⟨hu', ?_, hg⟩
      by_contra hc
      have he : lab (ρ (z + 1)) e = true := by
        rcases Bool.eq_false_or_eq_true (lab (ρ (z + 1)) e) with h' | h'
        · exact h'
        · exact absurd h' hc
      exact absurd ⟨z + 1, by omega, he, fun r h1 h2 => absurd h2 (by omega)⟩ hno
  | succ n ih =>
    intro m hm
    rcases Nat.lt_succ_iff_lt_or_eq.mp (Nat.lt_succ_of_le hm) with hlt | heq
    · exact ih m (Nat.lt_succ_iff.mp hlt)
    · subst heq
      obtain ⟨hun, -, -⟩ := ih n le_rfl
      have hs : step (ρ (z + 1 + (n : ℤ))) (ρ (z + 1 + (n : ℤ) + 1)) = true := hstep _
      have hcast : z + 1 + ((n + 1 : ℕ) : ℤ) = z + 1 + (n : ℤ) + 1 := by push_cast; omega
      -- the guard on the whole open interval `(z, z + 1 + n + 1)`, from `ih`
      have hguard : ∀ r : ℤ, z < r → r < z + 1 + (n : ℤ) + 1 → lab (ρ r) g = true := by
        intro r h1 h2
        have hm' : ((r - z - 1).toNat : ℤ) = r - z - 1 := by omega
        have hle : (r - z - 1).toNat ≤ n := by omega
        have := (ih _ hle).2.2
        rwa [show z + 1 + ((r - z - 1).toNat : ℤ) = r by omega] at this
      rw [hcast]
      rcases (hco _ _ hs).mp hun with he | ⟨hg, hu'⟩
      · exact absurd ⟨z + 1 + (n : ℤ) + 1, by omega, he, hguard⟩ hno
      · refine ⟨hu', ?_, hg⟩
        by_contra hc
        have he : lab (ρ (z + 1 + (n : ℤ) + 1)) e = true := by
          rcases Bool.eq_false_or_eq_true (lab (ρ (z + 1 + (n : ℤ) + 1)) e) with h' | h'
          · exact h'
          · exact absurd h' hc
        exact absurd ⟨z + 1 + (n : ℤ) + 1, by omega, he, hguard⟩ hno

/--
**The `untl` run condition's hard (⇒) direction, from the two decidable conditions alone.**
No `[Finite W]`, no model, no closure machinery: coherence per edge plus acyclicity of the
deferral graph forces every run of the presentation to discharge every claim it makes.
-/
theorem disch_of_UCoh_ULive (hco : UCoh lab step u g e) (hlive : ULive lab step u e)
    {ρ : ℤ → Q} (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) {z : ℤ}
    (hu : lab (ρ z) u = true) : Disch lab g e ρ z := by
  by_contra hno
  have hp := persist lab step u g e hco hstep hu hno
  -- the undischarged stretch is an infinite chain in the deferral graph
  have hchain : HasChain (deferGraph lab step u e) (ρ (z + 1)) := by
    refine ⟨fun n => ρ (z + 1 + (n : ℤ)), by norm_num, fun n => ?_⟩
    obtain ⟨hun, hen, -⟩ := hp n n le_rfl
    have hcast : z + 1 + ((n + 1 : ℕ) : ℤ) = z + 1 + (n : ℤ) + 1 := by push_cast; omega
    show deferGraph lab step u e (ρ (z + 1 + (n : ℤ))) (ρ (z + 1 + ((n + 1 : ℕ) : ℤ))) = true
    rw [hcast]
    simp only [deferGraph, Bool.and_eq_true, Bool.not_eq_true']
    exact ⟨⟨hun, hen⟩, hstep _⟩
  have := (live_iff (deferGraph lab step u e) (ρ (z + 1))).mpr hchain
  rw [hlive (ρ (z + 1))] at this
  exact Bool.false_ne_true this

/--
**The `untl` run condition's easy (⇐) direction**: a discharge witness forces the claim, by
walking the coherence back from the witness.
-/
theorem u_of_disch (hco : UCoh lab step u g e) {ρ : ℤ → Q}
    (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) {z : ℤ}
    (hd : Disch lab g e ρ z) : lab (ρ z) u = true := by
  obtain ⟨s, hzs, hes, hguard⟩ := hd
  -- backward induction on the distance from `z` to `s`
  have key : ∀ n : ℕ, ∀ w : ℤ, z ≤ w → w + (n : ℤ) + 1 = s → lab (ρ w) u = true := by
    intro n
    induction n with
    | zero =>
      intro w hzw hws
      refine (hco (ρ w) (ρ (w + 1)) (hstep w)).mpr (Or.inl ?_)
      rw [show w + 1 = s by omega]
      exact hes
    | succ n ih =>
      intro w hzw hws
      have hu1 : lab (ρ (w + 1)) u = true := ih (w + 1) (by omega) (by push_cast at hws ⊢; omega)
      refine (hco (ρ w) (ρ (w + 1)) (hstep w)).mpr (Or.inr ⟨?_, hu1⟩)
      exact hguard (w + 1) (by omega) (by push_cast at hws ⊢; omega)
  exact key (s - z - 1).toNat z le_rfl (by omega)

/-- **The `untl` run condition, in full, from two decidable conditions on the presentation.** -/
theorem untl_iff_of_UCoh_ULive (hco : UCoh lab step u g e) (hlive : ULive lab step u e)
    {ρ : ℤ → Q} (hstep : ∀ z, step (ρ z) (ρ (z + 1)) = true) (z : ℤ) :
    lab (ρ z) u = true ↔ Disch lab g e ρ z :=
  ⟨fun hu => disch_of_UCoh_ULive lab step u g e hco hlive hstep hu,
   fun hd => u_of_disch lab step u g e hco hstep hd⟩

end Probe746B
