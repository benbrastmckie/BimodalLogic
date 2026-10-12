/-
PROTOTYPE TEST (not a wired probe): route (C) of the pre-landed prototype findings -- "bound the
carrier instead of indexing it" -- is tested against the landed finite-width obstruction, rather
than against a fresh seriality analysis.

Route (C) proposes replacing the infinite admissible ladder carrier by its deadline-bounded
sub-carrier `{x // c <= N and n <= N}`, which is a `Fintype` outright, so that no cell index is
needed.  The three facts below settle what that costs:

(1) `bounded_ladder_finite` -- the bounded sub-carrier IS finite, as route (C) claims;
(2) `finBranch_eq_ofSlicedStep` -- on a finite carrier the run layer's parallel constructor
    `ofSlicedStepFinBranch` is LITERALLY the frame `FrameOver.ofSlicedStep` builds (`rfl`: the
    two differ only in which proof discharges `Saturation`, and proof irrelevance is
    definitional);
(3) `bounded_width_validates_Phi_neg` -- hence EVERY model on such a frame validates `Phi.neg`,
    by `NoFiniteWidth.no_finite_width_sat`.  Since `Phi.neg` is a Z-time non-validity
    (`not_plusValidZTime_neg_Phi`), no bounded-deadline ladder model can refute it.

So route (C) cannot be the general completeness route: its premise -- "every refutable phi has a
refuting ladder object with deadlines <= N(phi)" -- is FALSE, with `phi = Phi.neg` the
counterexample, and the refutation is a landed theorem rather than a conjecture.  This is the
same obstruction `RunLayer.lean`'s design decision already records against capping the counters.
-/
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

namespace RouteCFiniteWidth

/-- **(1) The deadline-bounded admissible ladder sub-carrier is finite**, exactly as route (C)
claims: it injects into `Q × Fin (N+1) × Fin (N+1)`. -/
theorem bounded_ladder_finite {Q : Type} [Finite Q] (pend : Q → Bool) (N : ℕ) :
    Finite {x : LadderState Q pend // x.1.2.1 ≤ N ∧ x.1.2.2 ≤ N} := by
  refine Finite.of_injective
    (fun x => (x.1.1.1, (⟨x.1.1.2.1, Nat.lt_succ_of_le x.2.1⟩ : Fin (N + 1)),
      (⟨x.1.1.2.2, Nat.lt_succ_of_le x.2.2⟩ : Fin (N + 1)))) ?_
  intro a b hab
  simp only [Prod.mk.injEq, Fin.mk.injEq] at hab
  obtain ⟨h1, h2, h3⟩ := hab
  exact Subtype.ext (Subtype.ext (Prod.ext h1 (Prod.ext h2 h3)))

/-- **(2) On a finite carrier the run layer's parallel constructor is the landed one.**  The two
differ only in the proof discharging `Saturation`, and proof irrelevance is definitional, so the
frames are equal by `rfl` -- no transport is needed to apply a finite-width result to a
`ofSlicedStepFinBranch` frame. -/
theorem finBranch_eq_ofSlicedStep {W : Type} [Finite W] [Nonempty W] (R : ℤ → W → W → Prop)
    (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w) :
    ofSlicedStepFinBranch R hf hb fwd bwd = FrameOver.ofSlicedStep R fwd bwd := rfl

/-- **(3) Every model on a FINITE-carrier `ofSlicedStepFinBranch` frame validates `Φ.neg`.**
`NoFiniteWidth.no_finite_width_sat` applies unchanged through (2).  Since `Φ.neg` is a ℤ-time
non-validity (`NoFiniteWidth.not_plusValidZTime_neg_Φ`), no such model refutes it: route (C)'s
premise fails at `φ = Φ.neg`. -/
theorem bounded_width_validates_Phi_neg {W : Type} [Finite W] [Nonempty W]
    (R : ℤ → W → W → Prop) (hf : FwdFinBranch R) (hb : BwdFinBranch R)
    (fwd : ∀ t w, ∃ u, R t w u) (bwd : ∀ t w, ∃ v, R (t - 1) v w)
    (M : TaskModel (ofSlicedStepFinBranch R hf hb fwd bwd).toTaskFrame)
    (τ : WorldHistory (ofSlicedStepFinBranch R hf hb fwd bwd)) (t : ℤ) :
    PlusTruthAt M τ t NoFiniteWidth.Φ.neg := by
  show PlusTruthAt M τ t NoFiniteWidth.Φ → PlusTruthAt M τ t PlusFormula.bot
  intro hΦ
  exact NoFiniteWidth.no_finite_width_sat R fwd bwd M τ t hΦ

/-- The non-validity that route (C) therefore cannot reach, restated here so the citation is
machine-checked rather than quoted. -/
theorem Phi_neg_not_valid : ¬ PlusValidZTime NoFiniteWidth.Φ.neg :=
  NoFiniteWidth.not_plusValidZTime_neg_Φ

#print axioms RouteCFiniteWidth.bounded_ladder_finite
#print axioms RouteCFiniteWidth.finBranch_eq_ofSlicedStep
#print axioms RouteCFiniteWidth.bounded_width_validates_Phi_neg

end RouteCFiniteWidth
