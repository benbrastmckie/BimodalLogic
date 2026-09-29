import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Incompleteness
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Examples

/-!
Scratch probe (research round 2): the `trans`-redesign non-vacuity gate, by construction.

Everything here is stated ON TOP of the landed `PlusSharingWitnessFamily`, with the succession
relation `trans` supplied as an external parameter, so that the redesigned conditions can be
elaborated against the current oleans without touching the tree.

1. Generic layer: the redesigned (C1') `TLocalCoherent`, trans-threads `TThread`, the redesigned
   (C2') `TThreadFulfilling`, the bundle `TCertifies`, `ArrivalPruned` and `Liftable`; and the two
   facts the substrate switch rests on — `Liftable` alone gives the histories characterization
   for trans-threads, and `ArrivalPruned` alone makes every trans-thread a `share`-thread.
2. Family A (`famA`): two lassos sharing on `[0, ∞)`, `trans = eq`. It satisfies all six
   redesigned conditions at `t = 0` for the target `Pp → ⊡Pp` (`stabSnceTarget ⊤ p`), it is
   `Liftable`, and it refutes the analogue of `snce_share_congr`.
3. `stabFamily` (the landed (C5) witness, sharing at `u = 0` only) is NOT `Liftable` at
   `trans = eq`: the closure obligation is genuine, not an artefact of the argument.
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

namespace PlusSharingWitnessFamily

variable {Γ Del : PlusContext}

/-! ## 1. The redesigned conditions, parameterized by an external succession relation -/

/-- Redesigned (C1'): the `untl` clause quantifies over `trans t i j`, the `snce` clause over
`trans (t-1) k i`. The three one-position clauses are unchanged. -/
def TLocalCoherent (S : PlusSharingWitnessFamily Γ Del)
    (trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop) : Prop :=
  ∀ (i : Fin S.lassos.length) (t : ℤ),
    (PlusFormula.bot ∉ S.L i t) ∧
    (∀ a b : PlusFormula, PlusFormula.imp a b ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.imp a b ∈ S.L i t ↔ (a ∈ S.L i t → b ∈ S.L i t))) ∧
    (∀ χ : PlusFormula, PlusFormula.box χ ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.box χ ∈ S.L i t ↔ S.bx χ = true)) ∧
    (∀ j : Fin S.lassos.length, trans t i j →
      ∀ g e : PlusFormula, PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.untl g e ∈ S.L i t ↔
          (e ∈ S.L j (t + 1) ∨ (g ∈ S.L j (t + 1) ∧ PlusFormula.untl g e ∈ S.L j (t + 1))))) ∧
    (∀ k : Fin S.lassos.length, trans (t - 1) k i →
      ∀ g e : PlusFormula, PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del) →
        (PlusFormula.snce g e ∈ S.L i t ↔
          (e ∈ S.L k (t - 1) ∨ (g ∈ S.L k (t - 1) ∧ PlusFormula.snce g e ∈ S.L k (t - 1)))))

/-- A trans-thread: consecutive indices are `trans`-related. -/
structure TThread (S : PlusSharingWitnessFamily Γ Del)
    (trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop) where
  idx : ℤ → Fin S.lassos.length
  step : ∀ u : ℤ, trans u (idx u) (idx (u + 1))

/-- Redesigned (C2'): fulfilment along every trans-thread. -/
def TThreadFulfilling (S : PlusSharingWitnessFamily Γ Del)
    (trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop) : Prop :=
  (∀ (i : Fin S.lassos.length) (u : ℤ) (g e : PlusFormula), PlusFormula.untl g e ∈ S.L i u →
      ∀ θ : S.TThread trans, θ.idx u = i →
        ∃ s : ℤ, u < s ∧ e ∈ S.L (θ.idx s) s ∧
          ∀ r : ℤ, u < r → r < s → g ∈ S.L (θ.idx r) r) ∧
  (∀ (i : Fin S.lassos.length) (u : ℤ) (g e : PlusFormula), PlusFormula.snce g e ∈ S.L i u →
      ∀ θ : S.TThread trans, θ.idx u = i →
        ∃ s : ℤ, s < u ∧ e ∈ S.L (θ.idx s) s ∧
          ∀ r : ℤ, s < r → r < u → g ∈ S.L (θ.idx r) r)

/-- The redesigned six-condition bundle, same shape as `PlusCertifies`. -/
def TCertifies (S : PlusSharingWitnessFamily Γ Del)
    (trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop) (t : ℤ) : Prop :=
  S.PlusAtomCoherent ∧ (S.TLocalCoherent trans ∧ S.TThreadFulfilling trans) ∧
    S.toPlusWitnessFamily.PlusBoxFaithful ∧ S.toPlusWitnessFamily.PlusTarget t ∧ S.StabFaithful

/-- Arrival pruning: a `trans`-successor names the state the thread arrives at. -/
def ArrivalPruned (S : PlusSharingWitnessFamily Γ Del)
    (trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop) : Prop :=
  ∀ (u : ℤ) (i j : Fin S.lassos.length), trans u i j → S.share (u + 1) i j

/-- Thread-lifting: every `Step`-path of the frame is class-equal to a trans-thread. -/
def Liftable (S : PlusSharingWitnessFamily Γ Del)
    (trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop) : Prop :=
  ∀ σ : ℤ → Fin S.lassos.length, (∀ u : ℤ, S.skeleton.Step u (σ u) (σ (u + 1))) →
    ∃ θ : S.TThread trans, ∀ u : ℤ, S.share u (σ u) (θ.idx u)

/-- **(A5 under the redesign)** Arrival pruning turns every trans-thread into a `share`-thread,
hence into a world history via the untouched `hist`. -/
def TThread.toThread {S : PlusSharingWitnessFamily Γ Del}
    {trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop}
    (hap : S.ArrivalPruned trans) (θ : S.TThread trans) : S.Thread :=
  ⟨θ.idx, fun u => hap u _ _ (θ.step u)⟩

/-- **(A4 under the redesign)** `Liftable` alone gives the histories characterization for
trans-threads; the statement is `total_eq_thread`'s with `TThread` for `Thread`. -/
theorem total_eq_tthread_of_liftable (S : PlusSharingWitnessFamily Γ Del)
    {trans : ℤ → Fin S.lassos.length → Fin S.lassos.length → Prop}
    (hlift : S.Liftable trans)
    (σ : FormalSystem.Semantics.WorldHistory S.frame.toTaskFrame) :
    ∃ θ : S.TThread trans, ∃ s : ℤ, ∀ t : ℤ, σ.state t = S.cls (θ.idx (s + t)) (s + t) := by
  obtain ⟨θ₀, s, h⟩ := S.total_eq_thread σ
  obtain ⟨θ, hθ⟩ := hlift θ₀.idx (fun u => SharingSkeleton.Thread.step' θ₀ u)
  refine ⟨θ, s, fun t => ?_⟩
  rw [h t]
  exact cls_eq rfl (hθ (s + t))

/-- With `trans = eq`, every trans-thread is constant. -/
theorem TThread.eq_const {S : PlusSharingWitnessFamily Γ Del}
    (θ : S.TThread (fun _ i j => i = j)) (u v : ℤ) : θ.idx u = θ.idx v := by
  have hfwd : ∀ (n : ℕ) (w : ℤ), θ.idx (w + n) = θ.idx w := by
    intro n
    induction n with
    | zero => intro w; simp
    | succ n ih =>
      intro w
      have hs : θ.idx (w + n) = θ.idx (w + n + 1) := θ.step (w + n)
      rw [show w + ((n + 1 : ℕ) : ℤ) = w + n + 1 by omega, ← hs, ih w]
  rcases le_total u v with huv | huv
  · have := hfwd (v - u).toNat u
    rw [show u + (((v - u).toNat : ℕ) : ℤ) = v by omega] at this
    exact this.symm
  · have := hfwd (u - v).toNat v
    rw [show v + (((u - v).toNat : ℕ) : ℤ) = u by omega] at this
    exact this

/-! ## 2. Family A -/

section Periodic

variable {α : Type*} [Inhabited α]

private theorem cyc_singleton (a : α) (i : ℤ) : Periodic.cyc [a] i = a := by
  simp [Periodic.cyc, Int.emod_one]

/-- Three singleton segments decode to `a` on the negatives, `b` at the origin, `c` beyond. -/
private theorem unrollOf_three (a b c : α) (t : ℤ) :
    Periodic.unrollOf [a] [b] [c] t = if t < 0 then a else if t = 0 then b else c := by
  rcases lt_trichotomy t 0 with ht | ht | ht
  · rw [Periodic.unrollOf_neg _ _ _ ht, cyc_singleton, if_pos ht]
  · subst ht
    rw [Periodic.unrollOf_mid _ _ _ le_rfl (by simp)]
    simp
  · have hlen : ((([b] : List α).length : ℕ) : ℤ) = 1 := by simp
    rw [Periodic.unrollOf_fwd _ _ _ (by rw [hlen]; omega), cyc_singleton,
      if_neg (by omega), if_neg (by omega)]

end Periodic

section FamilyA

variable (p : Atom)

/-- `Pp := ⊤ S p`. -/
abbrev Pp : PlusFormula := PlusFormula.snce PlusFormula.top (.atom p)
/-- `⊡Pp`. -/
abbrev SPp : PlusFormula := PlusFormula.stab (Pp p)
/-- The target `Pp → ⊡Pp`; definitionally `stabSnceTarget ⊤ p`. -/
abbrev TA : PlusFormula := PlusFormula.imp (Pp p) (SPp p)

theorem TA_eq : TA p = stabSnceTarget PlusFormula.top (.atom p) := rfl

abbrev closA : Finset PlusFormula := plusClosureOf (([] : PlusContext) ++ [TA p])

/-- The closure of the target, enumerated. -/
theorem mem_closA (ψ : PlusFormula) :
    ψ ∈ closA p ↔ ψ = TA p ∨ ψ = Pp p ∨ ψ = SPp p ∨ ψ = PlusFormula.top ∨
      ψ = PlusFormula.bot ∨ ψ = PlusFormula.atom p := by
  rw [mem_plusClosureOf]
  simp only [List.nil_append, List.mem_singleton, exists_eq_left]
  rw [plusSubformulaClosure, List.mem_toFinset]
  simp only [PlusFormula.top, PlusFormula.subformulas, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false]
  tauto

theorem imp_mem_closA {a b : PlusFormula} (h : PlusFormula.imp a b ∈ closA p) :
    (a = Pp p ∧ b = SPp p) ∨ (a = PlusFormula.bot ∧ b = PlusFormula.bot) := by
  rw [mem_closA] at h
  simp only [PlusFormula.top, PlusFormula.imp.injEq, reduceCtorEq, or_false] at h
  tauto

theorem snce_mem_closA {g e : PlusFormula} (h : PlusFormula.snce g e ∈ closA p) :
    g = PlusFormula.top ∧ e = PlusFormula.atom p := by
  rw [mem_closA] at h
  simp only [PlusFormula.top, PlusFormula.snce.injEq, reduceCtorEq, or_false, false_or] at h
  exact h

theorem untl_not_mem_closA {g e : PlusFormula} (h : PlusFormula.untl g e ∈ closA p) : False := by
  rw [mem_closA] at h
  simp only [PlusFormula.top, reduceCtorEq, or_false] at h

theorem box_not_mem_closA {χ : PlusFormula} (h : PlusFormula.box χ ∈ closA p) : False := by
  rw [mem_closA] at h
  simp only [PlusFormula.top, reduceCtorEq, or_false] at h

theorem stab_mem_closA {φ : PlusFormula} (h : PlusFormula.stab φ ∈ closA p) : φ = Pp p := by
  rw [mem_closA] at h
  simp only [PlusFormula.top, PlusFormula.stab.injEq, reduceCtorEq, or_false, false_or] at h
  exact h

/-- Lasso 0 off the origin, and lasso 1 on `[1, ∞)`: `{p, Pp, ⊡Pp, ⊤, T}`. -/
def a0b : Finset PlusFormula :=
  {PlusFormula.atom p, Pp p, SPp p, PlusFormula.top, TA p}
/-- Lasso 0 at the origin: `{p, Pp, ⊤}` — `⊡Pp` and hence `T` absent. -/
def a0m : Finset PlusFormula := {PlusFormula.atom p, Pp p, PlusFormula.top}
/-- Lasso 1 on the negatives: `{⊤, T}`. -/
def a1b : Finset PlusFormula := {PlusFormula.top, TA p}
/-- Lasso 1 at the origin: `{p, ⊤, T}` — `p` arrives, `Pp` not yet. -/
def a1m : Finset PlusFormula := {PlusFormula.atom p, PlusFormula.top, TA p}

theorem a0b_sub : a0b p ⊆ closA p := by
  intro ψ h; rw [mem_closA]; simp only [a0b, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem a0m_sub : a0m p ⊆ closA p := by
  intro ψ h; rw [mem_closA]; simp only [a0m, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem a1b_sub : a1b p ⊆ closA p := by
  intro ψ h; rw [mem_closA]; simp only [a1b, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem a1m_sub : a1m p ⊆ closA p := by
  intro ψ h; rw [mem_closA]; simp only [a1m, Finset.mem_insert, Finset.mem_singleton] at h; tauto

def lassoA0 : PlusLabelledLasso (closA p) where
  back := [a0b p]
  mid := [a0m p]
  fwd := [a0b p]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl | rfl
    · exact a0b_sub p
    · exact a0m_sub p
    · exact a0b_sub p

def lassoA1 : PlusLabelledLasso (closA p) where
  back := [a1b p]
  mid := [a1m p]
  fwd := [a0b p]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl | rfl
    · exact a1b_sub p
    · exact a1m_sub p
    · exact a0b_sub p

/-- **Family A.** Separate on the negatives, one class on `[0, ∞)`. -/
def famA : PlusSharingWitnessFamily ([] : PlusContext) [TA p] where
  bx := fun _ => false
  lassos := [lassoA0 p, lassoA1 p]
  lassos_ne := by simp
  repBack := [id]
  repMid := [fun _ => ⟨0, by simp⟩]
  repFwd := [fun _ => ⟨0, by simp⟩]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by
    intro f hf i
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hf
    rcases hf with rfl | rfl | rfl <;> rfl

@[simp] theorem famA_lassos_length : (famA p).lassos.length = 2 := rfl

theorem famA_zero_lt : 0 < (famA p).lassos.length :=
  (famA p).toPlusWitnessFamily.lassos_length_pos
theorem famA_one_lt : 1 < (famA p).lassos.length := by
  rw [famA_lassos_length]; omega

theorem famA_index_cases (i : Fin (famA p).lassos.length) : i.val = 0 ∨ i.val = 1 := by
  have h : i.val < 2 := i.isLt
  omega

/-- The labels, decoded. -/
theorem famA_L (i : Fin (famA p).lassos.length) (u : ℤ) :
    (famA p).L i u =
      if i.val = 0 then (if u < 0 then a0b p else if u = 0 then a0m p else a0b p)
      else (if u < 0 then a1b p else if u = 0 then a1m p else a0b p) := by
  have hget : (famA p).lassos.get i = if i.val = 0 then lassoA0 p else lassoA1 p := by
    rcases famA_index_cases p i with h | h
    · rw [if_pos h]
      have hi : i = ⟨0, famA_zero_lt p⟩ := Fin.ext h
      rw [hi]; rfl
    · rw [if_neg (by omega)]
      have hi : i = ⟨1, famA_one_lt p⟩ := Fin.ext h
      rw [hi]; rfl
  rw [PlusWitnessFamily.L, hget]
  rcases famA_index_cases p i with h | h
  · rw [if_pos h, if_pos h, PlusLabelledLasso.lab_def]
    exact unrollOf_three _ _ _ u
  · rw [if_neg (by omega), if_neg (by omega), PlusLabelledLasso.lab_def]
    exact unrollOf_three _ _ _ u

/-- The origin representative. -/
abbrev c0 : Fin (famA p).lassos.length → Fin (famA p).lassos.length :=
  fun _ => ⟨0, famA_zero_lt p⟩

/-- The representative map: identity on the negatives, constant `0` from the origin on. -/
theorem famA_rep (u : ℤ) (i : Fin (famA p).lassos.length) :
    (famA p).rep u i = if u < 0 then i else ⟨0, famA_zero_lt p⟩ := by
  have hrep : (famA p).rep u = if u < 0 then id else if u = 0 then c0 p else c0 p :=
    @unrollOf_three _ (repIdInhabited (famA p).lassos.length) id (c0 p) (c0 p) u
  rw [hrep]
  split_ifs <;> rfl

theorem famA_share_neg {u : ℤ} (hu : u < 0) (i j : Fin (famA p).lassos.length) :
    (famA p).share u i j ↔ i = j := by
  rw [(famA p).share_def, famA_rep, famA_rep]
  simp [hu]

theorem famA_share_nonneg {u : ℤ} (hu : 0 ≤ u) (i j : Fin (famA p).lassos.length) :
    (famA p).share u i j := by
  rw [(famA p).share_def, famA_rep, famA_rep]
  simp [not_lt.mpr hu]

/-- The skeleton-level restatement, for hypotheses produced by `Step`. -/
theorem famA_skel_share_neg {u : ℤ} (hu : u < 0) (i j : Fin (famA p).skeleton.n) :
    (famA p).skeleton.share u i j ↔ i = j :=
  famA_share_neg p hu i j

/-- The succession relation of Family A: no hopping. -/
abbrev transEq : ℤ → Fin (famA p).lassos.length → Fin (famA p).lassos.length → Prop :=
  fun _ i j => i = j

/-- (C0). -/
theorem famA_atomCoherent : (famA p).PlusAtomCoherent := by
  intro u i j hij q
  rcases lt_or_ge u 0 with hu | hu
  · rw [famA_share_neg p hu] at hij
    subst hij
    exact Iff.rfl
  · rw [famA_L, famA_L]
    rcases eq_or_lt_of_le hu with hu0 | hu0
    · subst hu0
      rcases famA_index_cases p i with hi | hi <;> rcases famA_index_cases p j with hj | hj <;>
        simp [hi, hj, a0m, a1m, PlusFormula.top]
    · rcases famA_index_cases p i with hi | hi <;> rcases famA_index_cases p j with hj | hj <;>
        simp [hi, hj, not_lt.mpr hu, hu0.ne', a0b]

/-- Redesigned (C1') at `trans = eq`. -/
theorem famA_tLocalCoherent : (famA p).TLocalCoherent (transEq p) := by
  intro i t
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · -- bot
    rw [famA_L]
    split_ifs <;> simp [a0b, a0m, a1b, a1m, PlusFormula.top]
  · -- imp
    intro a b hab
    rcases imp_mem_closA p hab with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩
    · rw [famA_L]
      split_ifs <;> simp [a0b, a0m, a1b, a1m, PlusFormula.top]
    · rw [famA_L]
      split_ifs <;> simp [a0b, a0m, a1b, a1m, PlusFormula.top]
  · -- box: vacuous
    intro χ hχ
    exact (box_not_mem_closA p hχ).elim
  · -- untl: vacuous
    intro j _ g e hge
    exact (untl_not_mem_closA p hge).elim
  · -- snce, over trans (t-1) k i, i.e. k = i
    intro k hki g e hge
    obtain ⟨rfl, rfl⟩ := snce_mem_closA p hge
    change k = i at hki
    subst hki
    rw [famA_L, famA_L]
    rcases famA_index_cases p k with hk | hk
    · simp only [hk, if_true]
      rcases lt_trichotomy t 0 with ht | ht | ht
      · simp [ht, show t - 1 < 0 by omega, a0b, PlusFormula.top]
      · subst ht
        simp [a0b, a0m, PlusFormula.top]
      · rcases eq_or_lt_of_le (show 1 ≤ t by omega) with ht1 | ht1
        · subst ht1
          simp [a0b, a0m, PlusFormula.top]
        · simp [not_lt.mpr ht.le, ht.ne', show ¬ t - 1 < 0 by omega,
            show t - 1 ≠ 0 by omega, a0b, PlusFormula.top]
    · simp only [hk, one_ne_zero, if_false]
      rcases lt_trichotomy t 0 with ht | ht | ht
      · simp [ht, show t - 1 < 0 by omega, a1b, PlusFormula.top]
      · subst ht
        simp [a1b, a1m, PlusFormula.top]
      · rcases eq_or_lt_of_le (show 1 ≤ t by omega) with ht1 | ht1
        · subst ht1
          simp [a0b, a1m, PlusFormula.top]
        · simp [not_lt.mpr ht.le, ht.ne', show ¬ t - 1 < 0 by omega,
            show t - 1 ≠ 0 by omega, a0b, PlusFormula.top]

/-- Redesigned (C2') at `trans = eq`. -/
theorem famA_tThreadFulfilling : (famA p).TThreadFulfilling (transEq p) := by
  refine ⟨fun i u g e hmem θ _ => ?_, fun i u g e hmem θ hθ => ?_⟩
  · exact (untl_not_mem_closA p ((famA p).subset_plusClosureOf i u hmem)).elim
  · obtain ⟨rfl, rfl⟩ := snce_mem_closA p ((famA p).subset_plusClosureOf i u hmem)
    have hconst : ∀ r, θ.idx r = i := fun r => (θ.eq_const r u).trans hθ
    rcases famA_index_cases p i with hi | hi
    · -- lasso 0: `p` one step back, no guard positions
      refine ⟨u - 1, by omega, ?_, fun r h1 h2 => by omega⟩
      rw [hconst, famA_L]
      simp only [hi, if_true]
      split_ifs <;> simp [a0b, a0m]
    · -- lasso 1: `Pp` is labelled only at `u ≥ 1`; discharge at `s = 0`
      have hu : 1 ≤ u := by
        rw [famA_L] at hmem
        simp only [hi, one_ne_zero, if_false] at hmem
        by_contra hlt
        rcases lt_or_ge u 0 with hu0 | hu0
        · simp [hu0, a1b, PlusFormula.top] at hmem
        · have hu0' : u = 0 := by omega
          simp [hu0', a1m, PlusFormula.top] at hmem
      refine ⟨0, by omega, ?_, fun r h1 h2 => ?_⟩
      · rw [hconst, famA_L]
        simp [hi, a1m]
      · rw [hconst, famA_L]
        simp only [hi, one_ne_zero, if_false]
        simp [not_lt.mpr h1.le, h1.ne', a0b]

/-- (C3): vacuous, no `box` in the closure. -/
theorem famA_boxFaithful : (famA p).toPlusWitnessFamily.PlusBoxFaithful :=
  fun _χ hχ => (box_not_mem_closA p hχ).elim

/-- (C4) at `t = 0`. -/
theorem famA_target : (famA p).toPlusWitnessFamily.PlusTarget 0 := by
  refine ⟨fun γ hγ => (List.not_mem_nil hγ).elim, fun σ hσ => ?_⟩
  have hσ' : σ = TA p := by simpa using hσ
  subst hσ'
  change TA p ∉ (famA p).L (famA p).toPlusWitnessFamily.mainIdx 0
  rw [famA_L]
  simp [PlusWitnessFamily.mainIdx, a0m, PlusFormula.top]

/-- (C5). -/
theorem famA_stabFaithful : (famA p).StabFaithful := by
  intro i u φ hc
  obtain rfl := stab_mem_closA p hc
  rcases lt_or_ge u 0 with hu | hu
  · have hright : (∀ j, (famA p).share u i j → Pp p ∈ (famA p).L j u) ↔
        Pp p ∈ (famA p).L i u := by
      constructor
      · intro h; exact h i ((famA_share_neg p hu i i).mpr rfl)
      · intro h j hij
        rw [famA_share_neg p hu] at hij
        exact hij ▸ h
    rw [hright, famA_L]
    rcases famA_index_cases p i with hi | hi
    · simp [hi, hu, a0b]
    · simp [hi, hu, a1b, PlusFormula.top]
  · rcases eq_or_lt_of_le hu with hu0 | hu0
    · subst hu0
      have hright : ¬ ∀ j, (famA p).share 0 i j → Pp p ∈ (famA p).L j 0 := by
        intro h
        have := h ⟨1, famA_one_lt p⟩ (famA_share_nonneg p le_rfl _ _)
        rw [famA_L] at this
        simp [a1m, PlusFormula.top] at this
      rw [famA_L]
      rcases famA_index_cases p i with hi | hi
      · simp only [hi, if_true, lt_irrefl, if_false]
        exact iff_of_false (by simp [a0m, PlusFormula.top]) hright
      · simp only [hi, one_ne_zero, if_false, lt_irrefl]
        exact iff_of_false (by simp [a1m, PlusFormula.top]) hright
    · have hright : ∀ j, (famA p).share u i j → Pp p ∈ (famA p).L j u := by
        intro j _
        rw [famA_L]
        rcases famA_index_cases p j with hj | hj <;>
          simp [hj, not_lt.mpr hu, hu0.ne', a0b]
      rw [famA_L]
      rcases famA_index_cases p i with hi | hi
      · simp only [hi, if_true, not_lt.mpr hu, hu0.ne', if_false]
        exact iff_of_true (by simp [a0b]) hright
      · simp only [hi, one_ne_zero, if_false, not_lt.mpr hu, hu0.ne']
        exact iff_of_true (by simp [a0b]) hright

/-- **The gate, first half:** Family A meets all six redesigned conditions at `t = 0`, for the
target that `not_plusCertifies_stabSnce` shows no landed family can certify. -/
theorem famA_tCertifies : (famA p).TCertifies (transEq p) 0 :=
  ⟨famA_atomCoherent p, ⟨famA_tLocalCoherent p, famA_tThreadFulfilling p⟩,
    famA_boxFaithful p, famA_target p, famA_stabFaithful p⟩

/-- Family A's trivial trans is arrival-pruned. -/
theorem famA_arrivalPruned : (famA p).ArrivalPruned (transEq p) := by
  intro u i j hij
  change i = j at hij
  subst hij
  exact (famA p).share_refl _ _

/-- **Family A is liftable.** Every `Step`-path is constant on `(-∞, -1]`, hence class-equal to
the constant thread at its value there. -/
theorem famA_liftable : (famA p).Liftable (transEq p) := by
  intro σ hstep
  -- the path is constant on the negatives
  have hneg : ∀ n : ℕ, σ (-1 - n) = σ (-1) := by
    intro n
    induction n with
    | zero => simp
    | succ n ih =>
      obtain ⟨k, h1, h2⟩ := hstep (-1 - ((n + 1 : ℕ) : ℤ))
      rw [famA_skel_share_neg p (by omega)] at h1
      rw [famA_skel_share_neg p (by omega)] at h2
      rw [show -1 - ((n + 1 : ℕ) : ℤ) + 1 = -1 - (n : ℤ) by omega] at h2
      rw [h1, h2, ih]
  refine ⟨⟨fun _ => σ (-1), fun _ => rfl⟩, fun u => ?_⟩
  rcases lt_or_ge u 0 with hu | hu
  · rw [famA_share_neg p hu]
    have := hneg (-1 - u).toNat
    rw [show -1 - (((-1 - u).toNat : ℕ) : ℤ) = u by omega] at this
    exact this
  · exact famA_share_nonneg p hu _ _

/-- **The gate, second half:** the redesigned (C1') no longer entails `snce_share_congr`'s
conclusion — Family A satisfies it and separates class-mates on `Pp` at the origin. -/
theorem famA_refutes_snce_share_congr :
    (famA p).TLocalCoherent (transEq p) ∧
    ¬ (∀ (i j : Fin (famA p).lassos.length), (famA p).share 0 i j →
        (Pp p ∈ (famA p).L i 0 ↔ Pp p ∈ (famA p).L j 0)) := by
  refine ⟨famA_tLocalCoherent p, fun h => ?_⟩
  have := h ⟨0, famA_zero_lt p⟩ ⟨1, famA_one_lt p⟩ (famA_share_nonneg p le_rfl _ _)
  rw [famA_L, famA_L] at this
  simp [a0m, a1m, PlusFormula.top] at this

/-- Sanity: the landed (C1') is indeed violated by Family A (the `snce` clause read across the
class at the origin), so the certificate above is not one the current tree already had. -/
theorem famA_not_plusLocalCoherentShare : ¬ (famA p).PlusLocalCoherentShare := by
  intro h
  exact (famA_refutes_snce_share_congr p).2
    (fun i j hij => snce_share_congr (famA p) h 0 i j hij _ _
      (plusClosureOf_imp_left (plusConclusion_mem_closure (List.mem_singleton_self _))))

end FamilyA

/-! ## 3. The closure obligation is genuine: `stabFamily` is not liftable at `trans = eq` -/

section NotLiftable

variable (p : Atom)

/-- The `Step`-path that rides lasso 0 on the negatives and lasso 1 from the origin on. -/
def crossPath : ℤ → Fin (stabFamily p).lassos.length :=
  fun u => if u < 0 then ⟨0, stabFamily_zero_lt p⟩ else ⟨1, stabFamily_one_lt p⟩

theorem crossPath_step (u : ℤ) :
    (stabFamily p).skeleton.Step u (crossPath p u) (crossPath p (u + 1)) := by
  unfold crossPath
  rcases lt_trichotomy u (-1) with hu | hu | hu
  · rw [if_pos (by omega), if_pos (by omega)]
    exact SharingSkeleton.step_refl _ _ _
  · subst hu
    rw [if_pos (by omega), if_neg (by omega)]
    refine ⟨⟨0, stabFamily_zero_lt p⟩, (stabFamily p).share_refl _ _, ?_⟩
    rw [show (-1 : ℤ) + 1 = 0 by norm_num]
    exact stabFamily_share_zero p _ _
  · rw [if_neg (by omega), if_neg (by omega)]
    exact SharingSkeleton.step_refl _ _ _

/-- **`stabFamily` is not liftable at `trans = eq`.** The crossing path is a frame history (it
is a `Step`-path), but no hop-free thread traces it: at `u = -1` the thread must be on lasso 0
and at `u = 1` on lasso 1, and hop-free threads are constant. -/
theorem stabFamily_not_liftable : ¬ (stabFamily p).Liftable (fun _ i j => i = j) := by
  intro hlift
  obtain ⟨θ, hθ⟩ := hlift (crossPath p) (crossPath_step p)
  have h1 := hθ (-1)
  have h2 := hθ 1
  rw [stabFamily_share_ne p (by norm_num)] at h1 h2
  have hc := θ.eq_const (-1) 1
  rw [← h1, ← h2] at hc
  simp [crossPath] at hc

end NotLiftable


/-! ## 4. Family B — the `untl`-side twin, flipping `not_plusCertifies_stabUntl` (round-1 probe) -/

section FamilyB

variable (p : Atom)

/-- `Fp := ⊤ U p`. -/
abbrev Fp : PlusFormula := PlusFormula.untl PlusFormula.top (.atom p)
/-- `¬p`. -/
abbrev Np : PlusFormula := PlusFormula.imp (.atom p) .bot
/-- `R := ¬p → ⊡Fp`. -/
abbrev RB : PlusFormula := PlusFormula.imp (Np p) (PlusFormula.stab (Fp p))
/-- The target `U := Fp → (¬p → ⊡Fp)`, i.e. `Fp → (p ∨ ⊡Fp)`. -/
abbrev UB : PlusFormula := PlusFormula.imp (Fp p) (RB p)

abbrev closB : Finset PlusFormula := plusClosureOf (([] : PlusContext) ++ [UB p])

theorem mem_closB (ψ : PlusFormula) :
    ψ ∈ closB p ↔ ψ = UB p ∨ ψ = Fp p ∨ ψ = RB p ∨ ψ = Np p ∨
      ψ = PlusFormula.stab (Fp p) ∨ ψ = PlusFormula.top ∨ ψ = PlusFormula.bot ∨
      ψ = PlusFormula.atom p := by
  rw [mem_plusClosureOf]
  simp only [List.nil_append, List.mem_singleton, exists_eq_left]
  rw [plusSubformulaClosure, List.mem_toFinset]
  simp only [PlusFormula.top, PlusFormula.subformulas, List.mem_cons, List.mem_append,
    List.not_mem_nil, or_false]
  tauto

theorem imp_mem_closB {a b : PlusFormula} (h : PlusFormula.imp a b ∈ closB p) :
    (a = Fp p ∧ b = RB p) ∨ (a = Np p ∧ b = PlusFormula.stab (Fp p)) ∨
    (a = PlusFormula.atom p ∧ b = PlusFormula.bot) ∨
    (a = PlusFormula.bot ∧ b = PlusFormula.bot) := by
  rw [mem_closB] at h
  simp only [PlusFormula.top, PlusFormula.imp.injEq, reduceCtorEq, or_false] at h
  tauto

theorem untl_mem_closB {g e : PlusFormula} (h : PlusFormula.untl g e ∈ closB p) :
    g = PlusFormula.top ∧ e = PlusFormula.atom p := by
  rw [mem_closB] at h
  simp only [PlusFormula.top, PlusFormula.untl.injEq, reduceCtorEq, or_false, false_or] at h
  exact h

theorem snce_not_mem_closB {g e : PlusFormula} (h : PlusFormula.snce g e ∈ closB p) : False := by
  rw [mem_closB] at h
  simp only [PlusFormula.top, reduceCtorEq, or_false] at h

theorem box_not_mem_closB {χ : PlusFormula} (h : PlusFormula.box χ ∈ closB p) : False := by
  rw [mem_closB] at h
  simp only [PlusFormula.top, reduceCtorEq, or_false] at h

theorem stab_mem_closB {φ : PlusFormula} (h : PlusFormula.stab φ ∈ closB p) : φ = Fp p := by
  rw [mem_closB] at h
  simp only [PlusFormula.top, PlusFormula.stab.injEq, reduceCtorEq, or_false, false_or] at h
  exact h

/-- Lasso 0 on `(-∞, 0]`: `{Fp, ¬p, ⊤}`. -/
def b0n : Finset PlusFormula := {Fp p, Np p, PlusFormula.top}
/-- Lasso 0 on `[1, ∞)`: `{p, Fp, ⊡Fp, R, U, ⊤}`. -/
def b0f : Finset PlusFormula :=
  {PlusFormula.atom p, Fp p, PlusFormula.stab (Fp p), RB p, UB p, PlusFormula.top}
/-- Lasso 1 everywhere: `{¬p, U, ⊤}`. -/
def b1 : Finset PlusFormula := {Np p, UB p, PlusFormula.top}

theorem b0n_sub : b0n p ⊆ closB p := by
  intro ψ h; rw [mem_closB]; simp only [b0n, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem b0f_sub : b0f p ⊆ closB p := by
  intro ψ h; rw [mem_closB]; simp only [b0f, Finset.mem_insert, Finset.mem_singleton] at h; tauto
theorem b1_sub : b1 p ⊆ closB p := by
  intro ψ h; rw [mem_closB]; simp only [b1, Finset.mem_insert, Finset.mem_singleton] at h; tauto

def lassoB0 : PlusLabelledLasso (closB p) where
  back := [b0n p]
  mid := [b0n p]
  fwd := [b0f p]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl | rfl
    · exact b0n_sub p
    · exact b0n_sub p
    · exact b0f_sub p

def lassoB1 : PlusLabelledLasso (closB p) where
  back := [b1 p]
  mid := [b1 p]
  fwd := [b1 p]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hX
    rcases hX with rfl | rfl | rfl <;> exact b1_sub p

/-- **Family B.** One class on `(-∞, 0]`, separate on `[1, ∞)`. -/
def famB : PlusSharingWitnessFamily ([] : PlusContext) [UB p] where
  bx := fun _ => false
  lassos := [lassoB0 p, lassoB1 p]
  lassos_ne := by simp
  repBack := [fun _ => ⟨0, by simp⟩]
  repMid := [fun _ => ⟨0, by simp⟩]
  repFwd := [id]
  repBack_ne := by simp
  repFwd_ne := by simp
  rep_idem := by
    intro f hf i
    simp only [List.cons_append, List.nil_append, List.mem_cons, List.not_mem_nil,
      or_false] at hf
    rcases hf with rfl | rfl | rfl <;> rfl

@[simp] theorem famB_lassos_length : (famB p).lassos.length = 2 := rfl

theorem famB_zero_lt : 0 < (famB p).lassos.length :=
  (famB p).toPlusWitnessFamily.lassos_length_pos
theorem famB_one_lt : 1 < (famB p).lassos.length := by
  rw [famB_lassos_length]; omega

theorem famB_index_cases (i : Fin (famB p).lassos.length) : i.val = 0 ∨ i.val = 1 := by
  have h : i.val < 2 := i.isLt
  omega

theorem famB_L (i : Fin (famB p).lassos.length) (u : ℤ) :
    (famB p).L i u = if i.val = 0 then (if 0 < u then b0f p else b0n p) else b1 p := by
  have hget : (famB p).lassos.get i = if i.val = 0 then lassoB0 p else lassoB1 p := by
    rcases famB_index_cases p i with h | h
    · rw [if_pos h]
      have hi : i = ⟨0, famB_zero_lt p⟩ := Fin.ext h
      rw [hi]; rfl
    · rw [if_neg (by omega)]
      have hi : i = ⟨1, famB_one_lt p⟩ := Fin.ext h
      rw [hi]; rfl
  rw [PlusWitnessFamily.L, hget]
  rcases famB_index_cases p i with h | h
  · rw [if_pos h, if_pos h, PlusLabelledLasso.lab_def]
    change Periodic.unrollOf [b0n p] [b0n p] [b0f p] u = _
    rw [unrollOf_three]
    split_ifs <;> first | rfl | omega
  · rw [if_neg (by omega), if_neg (by omega), PlusLabelledLasso.lab_def]
    change Periodic.unrollOf [b1 p] [b1 p] [b1 p] u = _
    rw [unrollOf_three]
    split_ifs <;> rfl

abbrev d0 : Fin (famB p).lassos.length → Fin (famB p).lassos.length :=
  fun _ => ⟨0, famB_zero_lt p⟩

theorem famB_rep (u : ℤ) (i : Fin (famB p).lassos.length) :
    (famB p).rep u i = if 0 < u then i else ⟨0, famB_zero_lt p⟩ := by
  have hrep : (famB p).rep u = if u < 0 then d0 p else if u = 0 then d0 p else id :=
    @unrollOf_three _ (repIdInhabited (famB p).lassos.length) (d0 p) (d0 p) id u
  rw [hrep]
  split_ifs <;> first | rfl | omega

theorem famB_share_pos {u : ℤ} (hu : 0 < u) (i j : Fin (famB p).lassos.length) :
    (famB p).share u i j ↔ i = j := by
  rw [(famB p).share_def, famB_rep, famB_rep]
  simp [hu]

theorem famB_share_nonpos {u : ℤ} (hu : u ≤ 0) (i j : Fin (famB p).lassos.length) :
    (famB p).share u i j := by
  rw [(famB p).share_def, famB_rep, famB_rep]
  simp [not_lt.mpr hu]

theorem famB_skel_share_pos {u : ℤ} (hu : 0 < u) (i j : Fin (famB p).skeleton.n) :
    (famB p).skeleton.share u i j ↔ i = j :=
  famB_share_pos p hu i j

abbrev transEqB : ℤ → Fin (famB p).lassos.length → Fin (famB p).lassos.length → Prop :=
  fun _ i j => i = j

theorem famB_atomCoherent : (famB p).PlusAtomCoherent := by
  intro u i j hij q
  rcases lt_or_ge 0 u with hu | hu
  · rw [famB_share_pos p hu] at hij
    subst hij
    exact Iff.rfl
  · rw [famB_L, famB_L]
    rcases famB_index_cases p i with hi | hi <;> rcases famB_index_cases p j with hj | hj <;>
      simp [hi, hj, not_lt.mpr hu, b0n, b1, PlusFormula.top]

theorem famB_tLocalCoherent : (famB p).TLocalCoherent (transEqB p) := by
  intro i t
  refine ⟨?_, ?_, ?_, ?_, ?_⟩
  · rw [famB_L]
    split_ifs <;> simp [b0n, b0f, b1, PlusFormula.top]
  · intro a b hab
    rcases imp_mem_closB p hab with ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ | ⟨rfl, rfl⟩ <;>
      · rw [famB_L]
        split_ifs <;> simp [b0n, b0f, b1, PlusFormula.top]
  · intro χ hχ
    exact (box_not_mem_closB p hχ).elim
  · -- untl over trans t i j, i.e. j = i
    intro j hij g e hge
    obtain ⟨rfl, rfl⟩ := untl_mem_closB p hge
    change i = j at hij
    subst hij
    rw [famB_L, famB_L]
    rcases famB_index_cases p i with hi | hi
    · simp only [hi, if_true]
      rcases lt_or_ge 0 t with ht | ht
      · simp [ht, show 0 < t + 1 by omega, b0f, PlusFormula.top]
      · rcases eq_or_lt_of_le ht with ht0 | ht0
        · subst ht0
          simp [b0n, b0f, PlusFormula.top]
        · simp [not_lt.mpr ht, show ¬ 0 < t + 1 by omega, b0n, PlusFormula.top]
    · simp only [hi, one_ne_zero, if_false]
      simp [b1, PlusFormula.top]
  · intro k _ g e hge
    exact (snce_not_mem_closB p hge).elim

theorem famB_tThreadFulfilling : (famB p).TThreadFulfilling (transEqB p) := by
  refine ⟨fun i u g e hmem θ hθ => ?_, fun i u g e hmem θ _ => ?_⟩
  · obtain ⟨rfl, rfl⟩ := untl_mem_closB p ((famB p).subset_plusClosureOf i u hmem)
    have hconst : ∀ r, θ.idx r = i := fun r => (θ.eq_const r u).trans hθ
    rcases famB_index_cases p i with hi | hi
    · -- lasso 0: `p` at every positive time, guard `⊤` everywhere
      refine ⟨(u.natAbs : ℤ) + 1, by omega, ?_, fun r _ _ => ?_⟩
      · rw [hconst, famB_L]
        simp only [hi, if_true]
        rw [if_pos (by omega)]
        simp [b0f]
      · rw [hconst, famB_L]
        simp only [hi, if_true]
        split_ifs <;> simp [b0n, b0f, PlusFormula.top]
    · -- lasso 1 never carries `Fp`
      exfalso
      rw [famB_L] at hmem
      simp only [hi, one_ne_zero, if_false] at hmem
      simp [b1, PlusFormula.top] at hmem
  · exact (snce_not_mem_closB p ((famB p).subset_plusClosureOf i u hmem)).elim

theorem famB_boxFaithful : (famB p).toPlusWitnessFamily.PlusBoxFaithful :=
  fun _χ hχ => (box_not_mem_closB p hχ).elim

theorem famB_target : (famB p).toPlusWitnessFamily.PlusTarget 0 := by
  refine ⟨fun γ hγ => (List.not_mem_nil hγ).elim, fun σ hσ => ?_⟩
  have hσ' : σ = UB p := by simpa using hσ
  subst hσ'
  change UB p ∉ (famB p).L (famB p).toPlusWitnessFamily.mainIdx 0
  rw [famB_L]
  simp [PlusWitnessFamily.mainIdx, b0n, PlusFormula.top]

theorem famB_stabFaithful : (famB p).StabFaithful := by
  intro i u φ hc
  obtain rfl := stab_mem_closB p hc
  rcases lt_or_ge 0 u with hu | hu
  · have hright : (∀ j, (famB p).share u i j → Fp p ∈ (famB p).L j u) ↔
        Fp p ∈ (famB p).L i u := by
      constructor
      · intro h; exact h i ((famB_share_pos p hu i i).mpr rfl)
      · intro h j hij
        rw [famB_share_pos p hu] at hij
        exact hij ▸ h
    rw [hright, famB_L]
    rcases famB_index_cases p i with hi | hi
    · simp [hi, hu, b0f]
    · simp [hi, b1, PlusFormula.top]
  · have hright : ¬ ∀ j, (famB p).share u i j → Fp p ∈ (famB p).L j u := by
      intro h
      have := h ⟨1, famB_one_lt p⟩ (famB_share_nonpos p hu _ _)
      rw [famB_L] at this
      simp [b1, PlusFormula.top] at this
    rw [famB_L]
    rcases famB_index_cases p i with hi | hi
    · simp only [hi, if_true, not_lt.mpr hu, if_false]
      exact iff_of_false (by simp [b0n, PlusFormula.top]) hright
    · simp only [hi, one_ne_zero, if_false]
      exact iff_of_false (by simp [b1, PlusFormula.top]) hright

/-- **Gate, `untl` side, first half.** -/
theorem famB_tCertifies : (famB p).TCertifies (transEqB p) 0 :=
  ⟨famB_atomCoherent p, ⟨famB_tLocalCoherent p, famB_tThreadFulfilling p⟩,
    famB_boxFaithful p, famB_target p, famB_stabFaithful p⟩

theorem famB_liftable : (famB p).Liftable (transEqB p) := by
  intro σ hstep
  have hpos : ∀ n : ℕ, σ (1 + n) = σ 1 := by
    intro n
    induction n with
    | zero => simp
    | succ n ih =>
      obtain ⟨k, h1, h2⟩ := hstep (1 + (n : ℤ))
      rw [famB_skel_share_pos p (by omega)] at h1
      rw [famB_skel_share_pos p (by omega)] at h2
      rw [show (1 : ℤ) + ((n + 1 : ℕ) : ℤ) = 1 + (n : ℤ) + 1 by omega, ← h2, ← h1, ih]
  refine ⟨⟨fun _ => σ 1, fun _ => rfl⟩, fun u => ?_⟩
  rcases lt_or_ge 0 u with hu | hu
  · rw [famB_share_pos p hu]
    have := hpos (u - 1).toNat
    rw [show (1 : ℤ) + (((u - 1).toNat : ℕ) : ℤ) = u by omega] at this
    exact this
  · exact famB_share_nonpos p hu _ _

/-- **Gate, `untl` side, second half:** the redesigned (C1') no longer entails the shifted
`untl` congruence (`untl_shift_share_congr` of the round-1 probe). -/
theorem famB_refutes_untl_shift_congr :
    (famB p).TLocalCoherent (transEqB p) ∧
    ¬ (∀ (i j : Fin (famB p).lassos.length), (famB p).share 0 i j →
        ((PlusFormula.atom p ∈ (famB p).L i 0 ∨
            (PlusFormula.top ∈ (famB p).L i 0 ∧ Fp p ∈ (famB p).L i 0)) ↔
         (PlusFormula.atom p ∈ (famB p).L j 0 ∨
            (PlusFormula.top ∈ (famB p).L j 0 ∧ Fp p ∈ (famB p).L j 0)))) := by
  refine ⟨famB_tLocalCoherent p, fun h => ?_⟩
  have := h ⟨0, famB_zero_lt p⟩ ⟨1, famB_one_lt p⟩ (famB_share_nonpos p le_rfl _ _)
  rw [famB_L, famB_L] at this
  simp [b0n, b1, PlusFormula.top] at this

end FamilyB

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability

#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.total_eq_tthread_of_liftable
#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.famA_tCertifies
#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.famA_liftable
#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.famA_refutes_snce_share_congr
#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.famA_not_plusLocalCoherentShare
#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.stabFamily_not_liftable
#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.famB_tCertifies
#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.famB_liftable
#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.famB_refutes_untl_shift_congr
