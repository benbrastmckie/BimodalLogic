import FormalSystem

/-!
Probe (research round 2): the hop-free (`transId`) producer is incomplete even for a target
with no long-range eventuality.

Target: `¬(□⟐Xp ∧ □⟐X¬p)`, i.e. `□⟐Xp → (□⟐X¬p → ⊥)`. It is a ℤ-time non-validity, and no
family whose succession is index-identity certifies its refutation, whatever its size.
-/

open FormalSystem FormalSystem.PlusLanguage FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability FormalSystem.Semantics
open FormalSystem.PlusLanguage.PlusTruth

namespace Probe703HopFree

def pa : Atom := Atom.mkBase "p"
def p : PlusFormula := .atom pa
def np : PlusFormula := .imp p .bot
def Xp : PlusFormula := .untl .bot p
def Xnp : PlusFormula := .untl .bot np
def dXp : PlusFormula := .imp (.stab (.imp Xp .bot)) .bot
def dXnp : PlusFormula := .imp (.stab (.imp Xnp .bot)) .bot
def th1 : PlusFormula := .box dXp
def th2 : PlusFormula := .box dXnp
def phi1 : PlusFormula := .imp th1 (.imp th2 .bot)

theorem not_plusValidZTime_phi1 : ¬ PlusValidZTime phi1 := by
  intro h
  have hsat : ProofSystem.FrameClass.ZTime.Sat FormalSystem.PlusLanguage.NF :=
    ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩
  have hv := h FormalSystem.PlusLanguage.NF hsat natModel (natHist fun _ => 0) 0
  have h1 : PlusTruthAt natModel (natHist fun _ => 0) 0 th1 := by
    intro σ hstab
    refine hstab (natHist fun s => if s = 1 then 0 else (show ℕ from σ.state 0)) ?_ ?_
    · change σ.state 0 = (if (0 : ℤ) = 1 then 0 else (show ℕ from σ.state 0))
      simp
    · refine ⟨(1 : ℤ), (by decide : (0 : ℤ) < 1), ?_, ?_⟩
      · change (if (1 : ℤ) = 1 then (0 : ℕ) else (show ℕ from σ.state 0)) = 0
        simp
      · intro r h0 h1
        exfalso
        have h0' : (0 : ℤ) < (show ℤ from r) := h0
        have h1' : (show ℤ from r) < (1 : ℤ) := h1
        generalize (show ℤ from r) = z at h0' h1'
        omega
  have h2 : PlusTruthAt natModel (natHist fun _ => 0) 0 th2 := by
    intro σ hstab
    refine hstab (natHist fun s => if s = 1 then 1 else (show ℕ from σ.state 0)) ?_ ?_
    · change σ.state 0 = (if (0 : ℤ) = 1 then 1 else (show ℕ from σ.state 0))
      simp
    · refine ⟨(1 : ℤ), (by decide : (0 : ℤ) < 1), ?_, ?_⟩
      · intro hp
        change (if (1 : ℤ) = 1 then (1 : ℕ) else (show ℕ from σ.state 0)) = 0 at hp
        simp at hp
      · intro r h0 h1
        exfalso
        have h0' : (0 : ℤ) < (show ℤ from r) := h0
        have h1' : (show ℤ from r) < (1 : ℤ) := h1
        generalize (show ℤ from r) = z at h0' h1'
        omega
  exact hv h1 h2

abbrev Δ1 : PlusContext := [phi1]
abbrev Cl : Finset PlusFormula := plusClosureOf (([] : PlusContext) ++ Δ1)

theorem phi1_mem : phi1 ∈ Cl := plusConclusion_mem_closure (List.mem_singleton_self _)
theorem th1_mem : th1 ∈ Cl := plusClosureOf_imp_left phi1_mem
theorem rest_mem : PlusFormula.imp th2 .bot ∈ Cl := plusClosureOf_imp_right phi1_mem
theorem th2_mem : th2 ∈ Cl := plusClosureOf_imp_left rest_mem
theorem dXp_mem : dXp ∈ Cl := plusClosureOf_box th1_mem
theorem dXnp_mem : dXnp ∈ Cl := plusClosureOf_box th2_mem
theorem sXp_mem : PlusFormula.stab (.imp Xp .bot) ∈ Cl := plusClosureOf_imp_left dXp_mem
theorem sXnp_mem : PlusFormula.stab (.imp Xnp .bot) ∈ Cl := plusClosureOf_imp_left dXnp_mem
theorem nXp_mem : PlusFormula.imp Xp .bot ∈ Cl := plusClosureOf_stab sXp_mem
theorem nXnp_mem : PlusFormula.imp Xnp .bot ∈ Cl := plusClosureOf_stab sXnp_mem
theorem Xp_mem : Xp ∈ Cl := plusClosureOf_imp_left nXp_mem
theorem Xnp_mem : Xnp ∈ Cl := plusClosureOf_imp_left nXnp_mem
theorem np_mem : np ∈ Cl := plusClosureOf_untl_left Xnp_mem

/-- **No hop-free family certifies the refutation of `phi1`.** -/
theorem no_hopFree_certificate (S : PlusSharingWitnessFamily ([] : PlusContext) Δ1) (t : ℤ)
    (hid : ∀ (u : ℤ) (i j : Fin S.lassos.length), S.trans u i j → i = j) :
    ¬ S.PlusCertifies t := by
  rintro ⟨hat, ⟨hloc, -⟩, hbox, htgt, hstab⟩
  classical
  have himp : ∀ (i : Fin S.lassos.length) (u : ℤ) (a b : PlusFormula),
      PlusFormula.imp a b ∈ Cl →
      (PlusFormula.imp a b ∈ S.L i u ↔ (a ∈ S.L i u → b ∈ S.L i u)) :=
    fun i u a b h => (hloc i u).2.1 a b h
  have hbot : ∀ (i : Fin S.lassos.length) (u : ℤ), PlusFormula.bot ∉ S.L i u :=
    fun i u => (hloc i u).1
  have hbx : ∀ (i : Fin S.lassos.length) (u : ℤ) (χ : PlusFormula), PlusFormula.box χ ∈ Cl →
      (PlusFormula.box χ ∈ S.L i u ↔ S.bx χ = true) :=
    fun i u χ h => (hloc i u).2.2.1 χ h
  have huntl : ∀ (i : Fin S.lassos.length) (u : ℤ) (j : Fin S.lassos.length), S.trans u i j →
      ∀ g e : PlusFormula, PlusFormula.untl g e ∈ Cl →
      (PlusFormula.untl g e ∈ S.L i u ↔
        (e ∈ S.L j (u + 1) ∨ (g ∈ S.L j (u + 1) ∧ PlusFormula.untl g e ∈ S.L j (u + 1)))) :=
    fun i u j h => (hloc i u).2.2.2.1 j h
  have hphi : phi1 ∉ S.L S.mainIdx t := htgt.2 phi1 (List.mem_singleton_self _)
  have h1 : th1 ∈ S.L S.mainIdx t := by
    by_contra h
    exact hphi ((himp _ _ th1 _ phi1_mem).mpr (fun h' => absurd h' h))
  have hrest : PlusFormula.imp th2 .bot ∉ S.L S.mainIdx t := fun h =>
    hphi ((himp _ _ th1 _ phi1_mem).mpr (fun _ => h))
  have h2 : th2 ∈ S.L S.mainIdx t := by
    by_contra h
    exact hrest ((himp _ _ th2 _ rest_mem).mpr (fun h' => absurd h' h))
  have hall1 : ∀ (i : Fin S.lassos.length) (u : ℤ), dXp ∈ S.L i u :=
    (hbox dXp th1_mem).mp ((hbx _ _ dXp th1_mem).mp h1)
  have hall2 : ∀ (i : Fin S.lassos.length) (u : ℤ), dXnp ∈ S.L i u :=
    (hbox dXnp th2_mem).mp ((hbx _ _ dXnp th2_mem).mp h2)
  have stepP : ∀ (i : Fin S.lassos.length) (u : ℤ), ∃ j, S.share u i j ∧ p ∈ S.L j (u + 1) := by
    intro i u
    have hns : PlusFormula.stab (.imp Xp .bot) ∉ S.L i u := fun hs =>
      hbot i u ((himp i u _ _ dXp_mem).mp (hall1 i u) hs)
    have hex : ¬ ∀ j, S.share u i j → PlusFormula.imp Xp .bot ∈ S.L j u :=
      fun hh => hns ((hstab i u (.imp Xp .bot) sXp_mem).mpr hh)
    push Not at hex
    obtain ⟨j, hsh, hj⟩ := hex
    refine ⟨j, hsh, ?_⟩
    have hX : Xp ∈ S.L j u := by
      by_contra h
      exact hj ((himp j u Xp .bot nXp_mem).mpr (fun h' => absurd h' h))
    rcases (huntl j u j (S.trans_refl' u j) .bot p Xp_mem).mp hX with h | ⟨h, -⟩
    · exact h
    · exact absurd h (hbot j (u + 1))
  have stepN : ∀ (i : Fin S.lassos.length) (u : ℤ), ∃ j, S.share u i j ∧ p ∉ S.L j (u + 1) := by
    intro i u
    have hns : PlusFormula.stab (.imp Xnp .bot) ∉ S.L i u := fun hs =>
      hbot i u ((himp i u _ _ dXnp_mem).mp (hall2 i u) hs)
    have hex : ¬ ∀ j, S.share u i j → PlusFormula.imp Xnp .bot ∈ S.L j u :=
      fun hh => hns ((hstab i u (.imp Xnp .bot) sXnp_mem).mpr hh)
    push Not at hex
    obtain ⟨j, hsh, hj⟩ := hex
    refine ⟨j, hsh, ?_⟩
    have hX : Xnp ∈ S.L j u := by
      by_contra h
      exact hj ((himp j u Xnp .bot nXnp_mem).mpr (fun h' => absurd h' h))
    have hnp : np ∈ S.L j (u + 1) := by
      rcases (huntl j u j (S.trans_refl' u j) .bot np Xnp_mem).mp hX with h | ⟨h, -⟩
      · exact h
      · exact absurd h (hbot j (u + 1))
    exact fun hp => hbot j (u + 1) ((himp j (u + 1) p .bot np_mem).mp hnp hp)
  -- At every time the main index's state has a successor state other than its own.
  have dev : ∀ u : ℤ, ∃ d, S.share u S.mainIdx d ∧ ¬ S.share (u + 1) S.mainIdx d := by
    intro u
    obtain ⟨jP, hP1, hP2⟩ := stepP S.mainIdx u
    obtain ⟨jN, hN1, hN2⟩ := stepN S.mainIdx u
    by_cases hm : p ∈ S.L S.mainIdx (u + 1)
    · exact ⟨jN, hN1, fun hs => hN2 ((hat (u + 1) _ _ hs pa).mp hm)⟩
    · exact ⟨jP, hP1, fun hs => hm ((hat (u + 1) _ _ hs pa).mpr hP2)⟩
  choose d hd1 hd2 using dev
  -- One deviating state path per time, each tracked by a constant index.
  have track : ∀ m : ℤ, ∃ k : Fin S.lassos.length,
      (∀ u, u ≤ m → S.share u S.mainIdx k) ∧ ¬ S.share (m + 1) S.mainIdx k := by
    intro m
    set σ : ℤ → Fin S.lassos.length := fun u => if u ≤ m then S.mainIdx else d m with hσ
    have hσstep : ∀ u : ℤ,
        stepOf S.lassos.length S.repBack S.repMid S.repFwd u (σ u) (σ (u + 1)) := by
      intro u
      by_cases h1 : u + 1 ≤ m
      · have e1 : σ u = S.mainIdx := by simp only [hσ, if_pos (show u ≤ m by omega)]
        have e2 : σ (u + 1) = S.mainIdx := by simp only [hσ, if_pos h1]
        rw [e1, e2]; exact ⟨_, rfl, rfl⟩
      · by_cases h2 : u ≤ m
        · have hum : u = m := by omega
          have e1 : σ u = S.mainIdx := by simp only [hσ, if_pos h2]
          have e2 : σ (u + 1) = d m := by simp only [hσ, if_neg h1]
          rw [e1, e2, hum]
          exact ⟨d m, hd1 m, rfl⟩
        · have e1 : σ u = d m := by simp only [hσ, if_neg h2]
          have e2 : σ (u + 1) = d m := by simp only [hσ, if_neg h1]
          rw [e1, e2]; exact ⟨_, rfl, rfl⟩
    obtain ⟨τ, hτ, hτσ⟩ := S.lift σ hσstep
    have hτstep : ∀ u : ℤ, S.trans u (τ u) (τ (u + 1)) := hτ
    have hτshare : ∀ u : ℤ, S.share u (σ u) (τ u) := hτσ
    have hsucc : ∀ u : ℤ, τ (u + 1) = τ u := fun u => (hid u _ _ (hτstep u)).symm
    have hconst : ∀ u : ℤ, τ u = τ 0 := by
      intro u
      induction u using Int.induction_on with
      | zero => rfl
      | succ i ih => rw [hsucc]; exact ih
      | pred i ih =>
        have := hsucc (-(i : ℤ) - 1)
        rw [show -(i : ℤ) - 1 + 1 = -(i : ℤ) by ring] at this
        rw [← this]; exact ih
    refine ⟨τ 0, fun u hu => ?_, fun hs => ?_⟩
    · have := hτshare u
      rw [hconst u] at this
      simpa only [hσ, if_pos hu] using this
    · have := hτshare (m + 1)
      rw [hconst (m + 1)] at this
      have e : σ (m + 1) = d m := by simp only [hσ, if_neg (show ¬ m + 1 ≤ m by omega)]
      rw [e] at this
      exact hd2 m (PlusSharingWitnessFamily.share_trans hs
        (PlusSharingWitnessFamily.share_symm this))
  choose k hk1 hk2 using track
  -- The tracking indices are pairwise distinct, so there are infinitely many of them.
  have hinj : Function.Injective (fun m : Fin (S.lassos.length + 1) => k ((m : ℕ) : ℤ)) := by
    intro x y hxy
    simp only at hxy
    by_contra hne
    rcases lt_or_gt_of_ne (fun h => hne (Fin.ext h)) with hlt | hlt
    · exact hk2 ((x : ℕ) : ℤ) (by rw [hxy]; exact hk1 _ _ (by omega))
    · exact hk2 ((y : ℕ) : ℤ) (by rw [← hxy]; exact hk1 _ _ (by omega))
  have := Fintype.card_le_of_injective _ hinj
  simp at this

#print axioms no_hopFree_certificate
#print axioms not_plusValidZTime_phi1

end Probe703HopFree
