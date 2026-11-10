import FormalSystem.Metalogic.NamingRules
import FormalSystem.Semantics.ConeUnravelling
import FormalSystem.PlusLanguage.PlusStateLocal
import FormalSystem.PlusLanguage.PlusIntTransfer

/-!
PROBE (task 895 research): the seven ingredients the formula-level Auxiliary-Atoms soundness
proof needs, each checked against the LANDED library rather than against a Mathlib-only mirror.
Every theorem below is `sorry`-free.

  (A) `stateLocal_state_only` — a state-local formula's truth depends on the world state ALONE,
      at possibly different times. Composition of `plusStateLocal_stab_iff` with
      `stab_state_only`; this is what makes the machine's input function `idx : WorldState → ℕ`
      well defined.
  (B) `next_iff_succ` — the L⁺ twin of `SourceLanguage/SentenceTruth.lean`'s `next_iff_succ`,
      absent from `PlusLanguage/PlusTruth.lean`. `⊡X` in the antecedent needs it.
  (C) `coneHist_step` — consecutive states of a history of `coneFrame F` are a one-step `coneR`
      edge. Phrased through `FrameOver.TaskRel`, because `coneFrame_taskRel` does NOT rewrite
      against a goal phrased with `(coneFrame F).toTaskFrame.TaskRel`.
  (D) `coneHist_inr_of_anchor` — the archived probe's `hin` induction, over genuine world
      histories instead of `IsWalk`, strengthened with the recorded list's length.
  (E) `congr_of_fresh_family` — the family form of `NamingRules.plusTruthAt_congr_of_fresh`: the
      landed theorem forgets ONE atom, and the rule discharges a finite SET of them.
  (F) `aaModel` + its two reading lemmas — the auxiliary-atom valuation on the cone carrier,
      reading the Q-atoms off the machine state and every other atom off the base model.
  (G) `aaState_step` — the step identity that is the semantic core of the AA antecedent: the
      archived `aa_expand` restated over `WorldHistory (coneFrame F)`.

NOTE the `↑intOrder` arithmetic obstruction, hit at (D) and (G): `omega` reports "no usable
constraints" on the duration type, so the archived probe's
`obtain ⟨k, rfl⟩ : ∃ k : ℕ, s = t + k := ⟨(s - t).toNat, by omega⟩` does not transfer.
`Int.toNat_of_nonneg` + `sub_nonneg` + `abel` replaces it.
-/

namespace Probe895

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.NamingRules

/-! ## (A) State-local truth is a function of the world state alone -/

theorem stateLocal_state_only {F : TaskFrame} {φ : PlusFormula} (hφ : φ.StateLocal)
    (M : TaskModel F) (τ σ : WorldHistory F) (t s : F.Duration)
    (h : τ.state t = σ.state s) :
    PlusTruthAt M τ t φ ↔ PlusTruthAt M σ s φ :=
  (plusStateLocal_stab_iff hφ M τ t).trans
    ((stab_state_only M τ σ t s h φ).trans (plusStateLocal_stab_iff hφ M σ s).symm)

/-! ## (B) `X` collapses to the successor -/

theorem next_iff_succ {F : TaskFrame} [SuccOrder F.Duration] [NoMaxOrder F.Duration]
    (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) (φ : PlusFormula) :
    PlusTruthAt M τ t φ.next ↔ PlusTruthAt M τ (Order.succ t) φ := by
  rw [PlusFormula.next, PlusTruth.untl_iff]
  constructor
  · rintro ⟨s, hts, hs, hgap⟩
    rcases lt_or_eq_of_le (Order.succ_le_of_lt hts) with h | h
    · exact absurd (hgap (Order.succ t) (Order.lt_succ t) h) (PlusTruth.bot_false M τ _)
    · exact h ▸ hs
  · intro h
    exact ⟨Order.succ t, Order.lt_succ t, h,
      fun r hr hrs => absurd (Order.succ_le_of_lt hr) (not_le_of_gt hrs)⟩

theorem next_iff_add_one {F : FrameOver intOrder} (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ↑intOrder) (φ : PlusFormula) :
    PlusTruthAt M τ t φ.next ↔ PlusTruthAt M τ (t + 1) φ := by
  rw [next_iff_succ M τ t φ, Order.succ_eq_add_one]

/-! ## (C), (D) Histories of the cone frame -/

theorem coneHist_step (F : FrameOver intOrder) [F.IsRegular]
    (τ' : WorldHistory (coneFrame F).toTaskFrame) (s : ↑intOrder) :
    coneR F.step (τ'.state s) (τ'.state (s + 1)) := by
  have h0 : (coneFrame F).TaskRel (τ'.state s) 1 (τ'.state (s + 1)) := by
    have := τ'.respects_task s (s + 1)
    rwa [show s + 1 - s = (1 : ↑intOrder) by abel] at this
  rw [coneFrame_taskRel] at h0
  have h1 := h0.1 (by norm_num)
  simp only [show (1 : ℤ).natAbs = 1 from rfl] at h1
  obtain ⟨v, hv, hstep⟩ := h1
  exact (iter_zero _ _ _ |>.mp hv) ▸ hstep

theorem coneHist_inr_of_anchor (F : FrameOver intOrder) [F.IsRegular]
    (τ' : WorldHistory (coneFrame F).toTaskFrame) (t : ↑intOrder) (w : F.WorldState)
    (ha : τ'.state t = .inr (w, [])) :
    ∀ n : ℕ, ∃ x : F.WorldState × List F.WorldState,
      τ'.state (t + (n : ℤ)) = .inr x ∧ x.2.length = n := by
  intro n
  induction n with
  | zero => exact ⟨(w, []), by simpa using ha, rfl⟩
  | succ n ih =>
    obtain ⟨x, hx, hlen⟩ := ih
    have hstep := coneHist_step F τ' (t + (n : ℤ))
    rw [hx] at hstep
    rw [show t + ((n + 1 : ℕ) : ℤ) = t + (n : ℤ) + 1 by push_cast; abel]
    rcases hv : τ'.state (t + (n : ℤ) + 1) with v | y
    · rw [hv] at hstep; exact hstep.elim
    · rw [hv] at hstep
      exact ⟨y, rfl, by rw [hstep.2]; simp [hlen]⟩

/-! ## (E) Forgetting a finite family of auxiliary atoms -/

theorem congr_of_fresh_family {F : TaskFrame} (M M' : TaskModel F) (qa : ℕ → Atom) (m : ℕ)
    (hV : ∀ (w : F.WorldState) (r : Atom), (∀ j, j < m → r ≠ qa j) →
      (M.valuation w r ↔ M'.valuation w r)) :
    ∀ φ : PlusFormula, (∀ j, j < m → Fresh (qa j) φ) →
      ∀ (τ : WorldHistory F) (t : F.Duration),
        PlusTruthAt M τ t φ ↔ PlusTruthAt M' τ t φ := by
  intro φ
  induction φ with
  | atom p => intro hq τ t; exact hV _ _ fun j hj => hq j hj
  | bot => intro _ _ _; exact Iff.rfl
  | imp a b ih1 ih2 =>
    intro hq τ t
    exact imp_congr (ih1 (fun j hj => (hq j hj).1) τ t) (ih2 (fun j hj => (hq j hj).2) τ t)
  | box a ih => intro hq τ t; exact forall_congr' fun σ => ih hq σ t
  | untl a b ih1 ih2 =>
    intro hq τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 (fun j hj => (hq j hj).2) τ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 (fun j hj => (hq j hj).1) τ r)
  | snce a b ih1 ih2 =>
    intro hq τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 (fun j hj => (hq j hj).2) τ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 (fun j hj => (hq j hj).1) τ r)
  | stab a ih =>
    intro hq τ t
    exact forall_congr' fun σ => imp_congr_right fun _ => ih hq σ t

/-! ## (F) The auxiliary-atom model on the cone carrier -/

/-- The machine run along a recorded path (most recent first). -/
def aaRun {W : Type} (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (idx : W → ℕ) : List W → ℕ
  | [] => b₀
  | u :: h => p (aaRun p b₀ idx h) (idx u)

/-- Which machine state a node of the cone carrier records. -/
def aaState {W : Type} (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (idx : W → ℕ) : W ⊕ (W × List W) → ℕ
  | .inl _ => b₀
  | .inr x => aaRun p b₀ idx x.2

/-- The auxiliary-atom model: the `Q`-atoms read the machine state, every other atom reads the
base model through the projection. -/
def aaModel (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (qa : ℕ → Atom) (m : ℕ) (st : (coneFrame F).WorldState → ℕ) :
    TaskModel (coneFrame F).toTaskFrame :=
  ⟨fun z r => (∃ j, j < m ∧ r = qa j ∧ st z = j) ∨
    ((∀ j, j < m → r ≠ qa j) ∧ M.valuation (coneF z) r)⟩

theorem aaModel_atom_q (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (qa : ℕ → Atom) (m : ℕ) (st : (coneFrame F).WorldState → ℕ)
    (hinj : ∀ j, j < m → ∀ j', j' < m → qa j = qa j' → j = j')
    (z : (coneFrame F).WorldState) (j : ℕ) (hj : j < m) :
    (aaModel F M qa m st).valuation z (qa j) ↔ st z = j := by
  constructor
  · rintro (⟨j', hj', he, hst⟩ | ⟨hne, _⟩)
    · exact hst.trans (hinj j' hj' j hj he.symm)
    · exact absurd rfl (hne j hj)
  · intro h; exact Or.inl ⟨j, hj, rfl, h⟩

theorem aaModel_valuation_off (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
    (qa : ℕ → Atom) (m : ℕ) (st : (coneFrame F).WorldState → ℕ)
    (z : (coneFrame F).WorldState) (r : Atom) (hr : ∀ j, j < m → r ≠ qa j) :
    (aaModel F M qa m st).valuation z r ↔ M.valuation (coneF z) r := by
  constructor
  · rintro (⟨j, hj, he, _⟩ | ⟨_, h⟩)
    · exact absurd he (hr j hj)
    · exact h
  · intro h; exact Or.inr ⟨hr, h⟩

/-! ## (G) The step identity -/

/-- **The semantic core of the AA antecedent**, over genuine world histories of `coneFrame F`:
on every history through an `inr`-anchored node, at every time from the anchor onward, every
history through the state reached moves to the machine's next state. This is the archived
probe's `aa_expand`, restated at the landed cone frame. -/
theorem aaState_step (F : FrameOver intOrder) [F.IsRegular]
    (p : ℕ → ℕ → ℕ) (b₀ : ℕ) (idx : F.WorldState → ℕ)
    (t : ↑intOrder) (w : F.WorldState)
    (ρ' : WorldHistory (coneFrame F).toTaskFrame) (ha : ρ'.state t = .inr (w, []))
    (s : ↑intOrder) (hs : t ≤ s)
    (η' : WorldHistory (coneFrame F).toTaskFrame) (he : η'.state s = ρ'.state s) :
    aaState p b₀ idx (η'.state (s + 1))
      = p (aaState p b₀ idx (ρ'.state s)) (idx (coneF (ρ'.state s))) := by
  obtain ⟨n, rfl⟩ : ∃ n : ℕ, s = t + (n : ℤ) :=
    ⟨(s - t).toNat, by
      have h : ((s - t).toNat : ℤ) = s - t := Int.toNat_of_nonneg (by simpa using sub_nonneg.mpr hs)
      rw [show ((((s - t).toNat : ℕ) : ℤ) : ↑intOrder) = ((s - t : ↑intOrder)) from h]
      abel⟩
  obtain ⟨x, hx, _⟩ := coneHist_inr_of_anchor F ρ' t w ha n
  have hstep := coneHist_step F η' (t + (n : ℤ))
  rw [he, hx] at hstep
  rcases hv : η'.state (t + (n : ℤ) + 1) with v | y
  · rw [hv] at hstep; exact hstep.elim
  · rw [hv] at hstep
    rw [hx]
    change aaRun p b₀ idx y.2 = p (aaRun p b₀ idx x.2) (idx x.1)
    rw [hstep.2]; rfl

end Probe895
