import FormalSystem.Semantics.Truth
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.WorldHistory
import Mathlib.Algebra.Order.Group.Int
import Mathlib.Data.Int.SuccPred
import FormalSystem.Metalogic.Independence.LoopingDuration

open FormalSystem.Syntax FormalSystem.Semantics
open scoped Classical

namespace Scratch511

/-! ## Probe A: `natFrame` over ℤ realises an arbitrary time-valuation, and refutes density. -/

noncomputable def natHist (S : Set ℤ) : WorldHistory (TaskFrame.natFrame (D := ℤ)) where
  domain := fun _ => True
  nonempty_domain := ⟨0, trivial⟩
  states := fun t _ => (if t ∈ S then 1 else 0 : Nat)
  respects_task := by
    intro s t _ _
    by_cases h : t - s = 0
    · right
      have : t = s := by omega
      subst this; rfl
    · left; exact h
  convex := fun _ _ _ _ _ _ _ => trivial

theorem natHist_isTotal (S : Set ℤ) : (natHist S).IsTotal := fun _ => trivial

noncomputable def natModel : TaskModel (TaskFrame.natFrame (D := ℤ)) where
  valuation := fun n _ => (show Nat from n) = 1

/-- **Realisation**: the time-valuation of any atom along `natHist S` is exactly `S`. -/
theorem natHist_atom (S : Set ℤ) (p : Atom) (t : ℤ) :
    TruthAt natModel (natHist S) t (Formula.atom p) ↔ t ∈ S := by
  show (∃ _ : True, natModel.valuation ((natHist S).states t trivial) p) ↔ t ∈ S
  constructor
  · intro hh
    obtain ⟨-, h⟩ := hh
    by_contra hs
    have : (natHist S).states t trivial = (0 : Nat) := by
      simp only [natHist, if_neg hs]
      rfl
    rw [this] at h
    exact absurd h (by simp [natModel])
  · intro hs
    refine ⟨trivial, ?_⟩
    have : (natHist S).states t trivial = (1 : Nat) := by
      simp only [natHist, if_pos hs]
      rfl
    rw [this]
    simp [natModel]

/-- **natFrame ⊭ density over ℤ**. -/
theorem natFrame_refutes_density (p : Atom) :
    ¬ (∀ (M : TaskModel (TaskFrame.natFrame (D := ℤ))) (τ : WorldHistory _),
        τ.IsTotal → ∀ t : ℤ,
        TruthAt M τ t ((Formula.atom p).allFuture.allFuture.imp (Formula.atom p).allFuture)) := by
  intro h
  have hgg : TruthAt natModel (natHist {r : ℤ | 2 ≤ r}) 0
      (Formula.atom p).allFuture.allFuture := by
    rw [Truth.future_iff]
    intro s hs
    rw [Truth.future_iff]
    intro u hu
    rw [natHist_atom]
    simp only [Set.mem_setOf_eq]
    omega
  have hg := h natModel (natHist _) (natHist_isTotal _) 0 hgg
  rw [Truth.future_iff] at hg
  have hone := hg 1 (by omega)
  rw [natHist_atom] at hone
  simp only [Set.mem_setOf_eq] at hone
  omega


/-! ## Probe B: `staticFrame` over ℤ — truth is time-invariant, hence density is valid. -/

namespace Static

variable {W : Type} [Nonempty W]

/-- Along any total history of `staticFrame`, the state is the same at every time. -/
theorem states_const (τ : WorldHistory (TaskFrame.staticFrame W (D := ℤ)))
    (s t : ℤ) (hs : τ.domain s) (ht : τ.domain t) :
    τ.states s hs = τ.states t ht :=
  τ.respects_task s t hs ht

/-- **Time-invariance**: on `staticFrame`, every formula's truth value is independent of the
    time of evaluation (one direction; the statement is `∀ t s`, so the iff follows). -/
theorem truth_time_invariant (M : TaskModel (TaskFrame.staticFrame W (D := ℤ))) (φ : Formula) :
    ∀ (τ : WorldHistory (TaskFrame.staticFrame W (D := ℤ))), τ.IsTotal →
      ∀ t s : ℤ, TruthAt M τ t φ → TruthAt M τ s φ := by
  induction φ with
  | atom p =>
      intro τ hτ t s h
      obtain ⟨ht, hv⟩ := h
      exact ⟨hτ s, by rw [states_const τ s t (hτ s) ht]; exact hv⟩
  | bot => intro τ hτ t s h; exact h
  | imp φ ψ ihφ ihψ =>
      intro τ hτ t s h hφs
      exact ihψ τ hτ t s (h (ihφ τ hτ s t hφs))
  | box φ ihφ =>
      intro τ hτ t s h σ hσ
      exact ihφ σ hσ t s (h σ hσ)
  | untl ψ φ ihψ ihφ =>
      intro τ hτ t s h
      obtain ⟨u, htu, hφu, -⟩ := h
      refine ⟨s + 1, by omega, ihφ τ hτ u (s + 1) hφu, ?_⟩
      intro r h1 h2; omega
  | snce ψ φ ihψ ihφ =>
      intro τ hτ t s h
      obtain ⟨u, hut, hφu, -⟩ := h
      refine ⟨s - 1, by omega, ihφ τ hτ u (s - 1) hφu, ?_⟩
      intro r h1 h2; omega

/-- **staticFrame ⊨ density over ℤ**, for every instance `φ`. -/
theorem staticFrame_validates_density (φ : Formula) :
    ∀ (M : TaskModel (TaskFrame.staticFrame W (D := ℤ)))
      (τ : WorldHistory (TaskFrame.staticFrame W (D := ℤ))),
      τ.IsTotal → ∀ t : ℤ,
      TruthAt M τ t (φ.allFuture.allFuture.imp φ.allFuture) := by
  intro M τ hτ t hgg
  rw [Truth.future_iff]
  intro s hs
  rw [Truth.future_iff] at hgg
  have h1 := hgg s hs
  rw [Truth.future_iff] at h1
  exact truth_time_invariant M φ τ hτ (s + 1) s (h1 (s + 1) (by omega))

end Static

/-! ## Probe C: the corrected, frame-valued Tier-0 correspondent for density. -/

namespace Corr

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

/-- `s` is an immediate successor of `t` in `(D, <)`. -/
def Covers (t s : D) : Prop := t < s ∧ ∀ r : D, t < r → r < s → False

/--
**The candidate correspondent.** Every total history of `F` is *state-recurrent at covering
pairs*: whenever `s` immediately succeeds `t`, the state occupied at `s` also occurs at some
time strictly after `s` — stated in the equivalent "every set of states holding throughout
`(s, ∞)` already holds at `s`" form, which is the shape the axiom consumes.

This is a condition on `F`'s own structure (which histories `F.TaskRel` admits), **not** on the
carrier type `D` alone.
-/
def FwdRec (F : TaskFrame D) : Prop :=
  ∀ (τ : WorldHistory F) (hτ : τ.IsTotal) (t s : D), Covers t s →
    ∀ A : F.WorldState → Prop,
      (∀ r : D, s < r → A (τ.states r (hτ r))) → A (τ.states s (hτ s))

/--
**Exact per-frame correspondence for the atomic density schema.**

`F` validates every atomic instance of `GGφ → Gφ` **iff** `F` is forward-recurrent at covering
pairs. Both sides are properties of `F`; nothing here is a property of `D` alone.
-/
theorem density_iff_fwdRec (F : TaskFrame D) :
    (∀ (p : Atom) (M : TaskModel F) (τ : WorldHistory F), τ.IsTotal → ∀ t : D,
        TruthAt M τ t ((Formula.atom p).allFuture.allFuture.imp (Formula.atom p).allFuture))
      ↔ FwdRec F := by
  constructor
  · -- validity ⟹ recurrence: read the recurrence witness off the axiom instance
    intro h τ hτ t s hcov A hA
    let M : TaskModel F := ⟨fun w _ => A w⟩
    have hgg : TruthAt M τ t (Formula.atom (Atom.mk "p" none)).allFuture.allFuture := by
      rw [Truth.future_iff]
      intro u hu
      rw [Truth.future_iff]
      intro r hr
      have hsu : s ≤ u := by
        by_contra hlt
        exact hcov.2 u hu (lt_of_not_ge hlt)
      exact ⟨hτ r, hA r (lt_of_le_of_lt hsu hr)⟩
    have hg := h (Atom.mk "p" none) M τ hτ t hgg
    rw [Truth.future_iff] at hg
    have hx : ∃ hd : τ.domain s, M.valuation (τ.states s hd) (Atom.mk "p" none) :=
      hg s hcov.1
    obtain ⟨hd, hv⟩ := hx
    exact hv
  · -- recurrence ⟹ validity
    intro h p M τ hτ t hgg
    rw [Truth.future_iff]
    intro s hst
    rw [Truth.future_iff] at hgg
    by_cases hmid : ∃ r : D, t < r ∧ r < s
    · -- `s` is not a cover of `t`: the axiom goes through on order grounds alone
      obtain ⟨r, h1, h2⟩ := hmid
      have := hgg r h1
      rw [Truth.future_iff] at this
      exact this s h2
    · -- `s` covers `t`: this is exactly where the frame condition is consumed
      push_neg at hmid
      have hcov : Covers t s := ⟨hst, fun r hr1 hr2 => absurd hr2 (not_lt.mpr (hmid r hr1))⟩
      have hA : ∀ r : D, s < r → M.valuation (τ.states r (hτ r)) p := by
        intro r hr
        have := hgg s hst
        rw [Truth.future_iff] at this
        have hx : ∃ hd : τ.domain r, M.valuation (τ.states r hd) p := this r hr
        obtain ⟨hd, hv⟩ := hx
        exact hv
      exact ⟨hτ s, h τ hτ t s hcov (fun w => M.valuation w p) hA⟩

/-- **Soundness half, uniformly**: over a densely ordered `D` there are no covering pairs, so
`FwdRec` is vacuous and *every* frame validates density. -/
theorem fwdRec_of_denselyOrdered [DenselyOrdered D] (F : TaskFrame D) : FwdRec F := by
  intro τ hτ t s hcov A hA
  obtain ⟨r, hr1, hr2⟩ := exists_between hcov.1
  exact absurd hr2 (fun h => hcov.2 r hr1 h)

/-- `staticFrame` is forward-recurrent: its total histories are constant. -/
theorem staticFrame_fwdRec (W : Type) [Nonempty W] : FwdRec (TaskFrame.staticFrame W (D := D)) := by
  intro τ hτ t s hcov A hA
  obtain ⟨x, hx⟩ := TaskFrame.exists_pos_of_nontrivial (D := D)
  have hlt : s < s + x := by simpa using hx
  have := hA (s + x) hlt
  have heq : τ.states s (hτ s) = τ.states (s + x) (hτ (s + x)) :=
    τ.respects_task s (s + x) (hτ s) (hτ (s + x))
  rwa [heq]

end Corr

/-! ## Probe D: the splitting condition is a frame *axiom*, so it separates nothing. -/

/-- The challenge's candidate splitting condition is literally `TaskFrame.Interpolates`, which
    every task frame satisfies (it is the `→` half of the `comp` field). It therefore cannot
    distinguish `staticFrame` from `natFrame`, or any two frames at all. -/
theorem splitting_is_universal {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] (F : TaskFrame D) :
    ∀ w v x y, 0 ≤ x → 0 ≤ y → F.TaskRel w (x + y) v → ∃ u, F.TaskRel w x u ∧ F.TaskRel u y v :=
  F.interpolates

/-! ## Probe E: the two frames sit on opposite sides of the new correspondent. -/

theorem natFrame_not_fwdRec : ¬ Corr.FwdRec (TaskFrame.natFrame (D := ℤ)) := by
  intro h
  exact natFrame_refutes_density (Atom.mk "p" none)
    (fun M τ hτ t => (Corr.density_iff_fwdRec _).mpr h _ M τ hτ t)

theorem staticFrame_density_via_corr (W : Type) [Nonempty W] :
    ∀ (p : Atom) (M : TaskModel (TaskFrame.staticFrame W (D := ℤ)))
      (τ : WorldHistory (TaskFrame.staticFrame W (D := ℤ))), τ.IsTotal → ∀ t : ℤ,
      TruthAt M τ t ((Formula.atom p).allFuture.allFuture.imp (Formula.atom p).allFuture) :=
  (Corr.density_iff_fwdRec _).mpr (Corr.staticFrame_fwdRec W)

#print axioms Scratch511.natFrame_refutes_density
#print axioms Scratch511.natHist_atom
#print axioms Scratch511.Static.staticFrame_validates_density
#print axioms Scratch511.Static.truth_time_invariant
#print axioms Scratch511.Corr.density_iff_fwdRec
#print axioms Scratch511.Corr.fwdRec_of_denselyOrdered
#print axioms Scratch511.Corr.staticFrame_fwdRec
#print axioms Scratch511.natFrame_not_fwdRec
#print axioms Scratch511.splitting_is_universal

/-! ## Probe F: full-schema sufficiency from an existing tree asset. -/

/--
**A looping duration validates the whole density schema**, over any duration type, for every
formula — not just atoms. The proof is three lines and consumes only
`Independence.LoopingDuration.truthAt_add_period`, which the tree already has.

`staticFrame` has every nonzero duration as a looping duration; `clockFrame` has `1`.
-/
theorem density_of_loopingDuration {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] {F : TaskFrame D} {pi : D}
    (h : FormalSystem.Metalogic.Independence.LoopingDuration F pi) (phi : Formula) :
    ∀ (M : TaskModel F) (tau : WorldHistory F), tau.IsTotal → ∀ t : D,
      TruthAt M tau t (phi.allFuture.allFuture.imp phi.allFuture) := by
  obtain ⟨p, hp, hlp⟩ := h.exists_pos
  intro M tau htau t hgg
  rw [Truth.future_iff]
  intro s hs
  rw [Truth.future_iff] at hgg
  have h1 := hgg s hs
  rw [Truth.future_iff] at h1
  have h2 : TruthAt M tau (s + p) phi := h1 (s + p) (by simpa using hp)
  exact (FormalSystem.Metalogic.Independence.truthAt_add_period M hlp phi tau htau s).mpr h2

/-- `staticFrame` has a looping duration, so Probe F covers it for *every* formula. -/
theorem staticFrame_looping {D : Type*} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [Nontrivial D] (W : Type) [Nonempty W] :
    ∃ pi : D, FormalSystem.Metalogic.Independence.LoopingDuration
      (TaskFrame.staticFrame W (D := D)) pi := by
  obtain ⟨x, hx⟩ := TaskFrame.exists_pos_of_nontrivial (D := D)
  exact ⟨x, ne_of_gt hx, fun w u => ⟨fun hr => hr.symm, fun hr => hr.symm⟩⟩

#print axioms Scratch511.density_of_loopingDuration
#print axioms Scratch511.staticFrame_looping

end Scratch511
