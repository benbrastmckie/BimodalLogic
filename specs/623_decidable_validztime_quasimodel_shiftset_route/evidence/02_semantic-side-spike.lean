/-
Compression spike (research round 02): the SEMANTIC half of the compression direction,
compiled green via `lean_run_code` against the tree at 26d45a4c5.

What this establishes, ahead of planning:

* `typeAtM` — the presentation-free type of a position of an ARBITRARY `FrameOver intOrder`
  model, filtered through `closureOf (Gam ++ Del)` rather than `subformulaClosure phi`.
  This is `BiLasso/SmallModel.lean`'s `typeAt` with the presentation removed.
* `typeAtM_clauses` — all FIVE `WitnessFamily.LocalCoherentLab` clauses hold of that type
  sequence, with the box guess read off the model. `LocalCoherentLab` drops `LocalCoherentSeq`'s
  atom clause, which is exactly the clause that needed a presentation, so nothing is lost.
* `typeAtM_fulfilling` — the `untl` half of `FulfillingLab`, straight from the truth clause
  (the `snce` half is its mirror and is not transcribed here).

Consequence for the plan: the "labels come from a real model" half of compression costs a
transcription of `typeAt_localCoherentSeq`, not a new argument. What remains is purely
combinatorial: pigeonhole over the type space, good cycles, splicing, and assembly into a
`List (LabelledLasso ...)`.

Also compiled separately (not reproduced here):
  * `closureOf ([] ++ [phi]) = subformulaClosure phi`                      by `simp [closureOf]`
  * `SemanticConsequenceIn fc [] phi <-> ValidIn fc phi`                   in six lines
  * a one-state `IntPresentation` `dummyP`, with
    `cycleBound dummyP phi = (2 * subformulaClosureCard phi + 1) * 2 ^ subformulaClosureCard phi`
-/
import FormalSystem.Metalogic.Decidability.WitnessFamily.Predicates
import FormalSystem.Metalogic.Decidability.BiLasso.Unfold
import FormalSystem.Semantics.TruthTransport

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.Metalogic.Decidability

variable {Gam Del : Context}

/-- The type of a position of an arbitrary ℤ-frame model, at the `WitnessFamily` closure. -/
noncomputable def typeAtM {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (Gam Del : Context) (tau : WorldHistory F.toTaskFrame) (u : ℤ) : Finset Formula :=
  @Finset.filter Formula (fun psi => TruthAt M tau u psi) (Classical.decPred _)
    (closureOf (Gam ++ Del))

theorem mem_typeAtM {F : FrameOver intOrder} {M : TaskModel F.toTaskFrame}
    {tau : WorldHistory F.toTaskFrame} {u : ℤ} {psi : Formula} :
    psi ∈ typeAtM M Gam Del tau u ↔ psi ∈ closureOf (Gam ++ Del) ∧ TruthAt M tau u psi := by
  simp only [typeAtM, Finset.mem_filter]

/-- The five `LocalCoherentLab` clauses hold of the type sequence of a genuine history. -/
theorem typeAtM_clauses {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (bx : Formula → Bool)
    (hbx : ∀ chi : Formula, bx chi = true ↔ ∀ (sig : WorldHistory F.toTaskFrame) (v : ℤ),
      TruthAt M sig v chi)
    (tau : WorldHistory F.toTaskFrame) (t : ℤ) :
    (Formula.bot ∉ typeAtM M Gam Del tau t) ∧
    (∀ a b : Formula, Formula.imp a b ∈ closureOf (Gam ++ Del) →
        (Formula.imp a b ∈ typeAtM M Gam Del tau t ↔
          (a ∈ typeAtM M Gam Del tau t → b ∈ typeAtM M Gam Del tau t))) ∧
    (∀ chi : Formula, Formula.box chi ∈ closureOf (Gam ++ Del) →
        (Formula.box chi ∈ typeAtM M Gam Del tau t ↔ bx chi = true)) ∧
    (∀ g e : Formula, Formula.untl g e ∈ closureOf (Gam ++ Del) →
        (Formula.untl g e ∈ typeAtM M Gam Del tau t ↔
          (e ∈ typeAtM M Gam Del tau (t + 1) ∨
            (g ∈ typeAtM M Gam Del tau (t + 1) ∧
              Formula.untl g e ∈ typeAtM M Gam Del tau (t + 1))))) ∧
    (∀ g e : Formula, Formula.snce g e ∈ closureOf (Gam ++ Del) →
        (Formula.snce g e ∈ typeAtM M Gam Del tau t ↔
          (e ∈ typeAtM M Gam Del tau (t - 1) ∨
            (g ∈ typeAtM M Gam Del tau (t - 1) ∧
              Formula.snce g e ∈ typeAtM M Gam Del tau (t - 1))))) := by
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · intro h
    exact Truth.bot_false (mem_typeAtM.mp h).2
  · intro a b hab
    rw [mem_typeAtM]
    constructor
    · rintro ⟨-, himp⟩ ha
      exact mem_typeAtM.mpr ⟨closureOf_imp_right hab,
        (Truth.imp_iff a b).mp himp (mem_typeAtM.mp ha).2⟩
    · intro h
      refine ⟨hab, (Truth.imp_iff a b).mpr ?_⟩
      intro hta
      exact (mem_typeAtM.mp (h (mem_typeAtM.mpr ⟨closureOf_imp_left hab, hta⟩))).2
  · intro chi hchi
    rw [mem_typeAtM]
    constructor
    · rintro ⟨-, hb⟩
      refine (hbx chi).mpr ?_
      intro sig v
      have h2 : TruthAt M sig v (Formula.box chi) := (Truth.box_const M tau sig t v chi).mp hb
      exact (Truth.box_iff chi).mp h2 sig
    · intro hb
      exact ⟨hchi, (Truth.box_iff chi).mpr (fun sig => (hbx chi).mp hb sig t)⟩
  · intro g e hge
    rw [mem_typeAtM, mem_typeAtM, mem_typeAtM, mem_typeAtM]
    constructor
    · rintro ⟨-, hu⟩
      rcases (truth_untl_succ (M := M) (τ := tau) t g e).mp hu with h | ⟨hg, hu'⟩
      · exact Or.inl ⟨closureOf_untl_left hge, h⟩
      · exact Or.inr ⟨⟨closureOf_untl_right hge, hg⟩, ⟨hge, hu'⟩⟩
    · intro h
      refine ⟨hge, (truth_untl_succ (M := M) (τ := tau) t g e).mpr ?_⟩
      rcases h with ⟨-, he⟩ | ⟨⟨-, hg⟩, ⟨-, hu⟩⟩
      · exact Or.inl he
      · exact Or.inr ⟨hg, hu⟩
  · intro g e hge
    rw [mem_typeAtM, mem_typeAtM, mem_typeAtM, mem_typeAtM]
    constructor
    · rintro ⟨-, hs⟩
      rcases (truth_snce_pred (M := M) (τ := tau) t g e).mp hs with h | ⟨hg, hs'⟩
      · exact Or.inl ⟨closureOf_snce_left hge, h⟩
      · exact Or.inr ⟨⟨closureOf_snce_right hge, hg⟩, ⟨hge, hs'⟩⟩
    · intro h
      refine ⟨hge, (truth_snce_pred (M := M) (τ := tau) t g e).mpr ?_⟩
      rcases h with ⟨-, he⟩ | ⟨⟨-, hg⟩, ⟨-, hs⟩⟩
      · exact Or.inl he
      · exact Or.inr ⟨hg, hs⟩

/-- Fulfilment (`untl` half) of the type sequence of a genuine history. -/
theorem typeAtM_fulfilling {F : FrameOver intOrder} {M : TaskModel F.toTaskFrame}
    (tau : WorldHistory F.toTaskFrame) :
    (∀ (t : ℤ) (g e : Formula), Formula.untl g e ∈ typeAtM M Gam Del tau t →
        ∃ s : ℤ, t < s ∧ e ∈ typeAtM M Gam Del tau s ∧
          ∀ r : ℤ, t < r → r < s → g ∈ typeAtM M Gam Del tau r) := by
  intro t g e hmem
  obtain ⟨hcl, hu⟩ := mem_typeAtM.mp hmem
  obtain ⟨s, hts, hse, hguard⟩ := hu
  refine ⟨s, hts, mem_typeAtM.mpr ⟨closureOf_untl_left hcl, hse⟩, ?_⟩
  intro r hr1 hr2
  exact mem_typeAtM.mpr ⟨closureOf_untl_right hcl, hguard r hr1 hr2⟩
