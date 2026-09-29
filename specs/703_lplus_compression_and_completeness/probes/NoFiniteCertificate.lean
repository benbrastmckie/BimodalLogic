import FormalSystem

/-!
Probe (research round 2): the L⁺ certificate class is incomplete.

Step 1 of the probe: the target formula, its closure memberships, and its ℤ-time non-validity.
-/

open FormalSystem FormalSystem.PlusLanguage FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability FormalSystem.Semantics
open FormalSystem.PlusLanguage.PlusTruth

namespace Probe703

def pa : Atom := Atom.mkBase "p"
def p : PlusFormula := .atom pa
def np : PlusFormula := .imp p .bot
def tp : PlusFormula := .imp .bot .bot
def Xp : PlusFormula := .untl .bot p
def Xnp : PlusFormula := .untl .bot np
def Fp : PlusFormula := .untl tp p
/-- `⟐Xp`. -/
def dXp : PlusFormula := .imp (.stab (.imp Xp .bot)) .bot
/-- `⟐X¬p`. -/
def dXnp : PlusFormula := .imp (.stab (.imp Xnp .bot)) .bot
def th1 : PlusFormula := .box dXp
def th2 : PlusFormula := .box dXnp
def tail : PlusFormula := .imp (.imp Fp Fp) .bot
def phi0 : PlusFormula := .imp th1 (.imp th2 tail)

/-- The target is a genuine ℤ-time non-validity. -/
theorem not_plusValidZTime_phi0 : ¬ PlusValidZTime phi0 := by
  intro h
  have hsat : ProofSystem.FrameClass.ZTime.Sat FormalSystem.PlusLanguage.NF :=
    ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩
  have hv := h FormalSystem.PlusLanguage.NF hsat natModel (natHist fun _ => 0) 0
  have h1 : PlusTruthAt natModel (natHist fun _ => 0) 0 th1 := by
    intro σ hstab
    have w : ℕ := σ.state 0
    have hw : σ.state 0 = (show ℕ from σ.state 0) := rfl
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
  exact hv h1 h2 (fun hF => hF)

/-! ## Step 2: closure memberships -/

abbrev Δ0 : PlusContext := [phi0]
abbrev Cl : Finset PlusFormula := plusClosureOf (([] : PlusContext) ++ Δ0)

theorem phi0_mem : phi0 ∈ Cl := plusConclusion_mem_closure (List.mem_singleton_self _)
theorem th1_mem : th1 ∈ Cl := plusClosureOf_imp_left phi0_mem
theorem rest_mem : PlusFormula.imp th2 tail ∈ Cl := plusClosureOf_imp_right phi0_mem
theorem th2_mem : th2 ∈ Cl := plusClosureOf_imp_left rest_mem
theorem tail_mem : tail ∈ Cl := plusClosureOf_imp_right rest_mem
theorem FpFp_mem : PlusFormula.imp Fp Fp ∈ Cl := plusClosureOf_imp_left tail_mem
theorem Fp_mem : Fp ∈ Cl := plusClosureOf_imp_left FpFp_mem
theorem tp_mem : tp ∈ Cl := plusClosureOf_untl_right Fp_mem
theorem dXp_mem : dXp ∈ Cl := plusClosureOf_box th1_mem
theorem dXnp_mem : dXnp ∈ Cl := plusClosureOf_box th2_mem
theorem sXp_mem : PlusFormula.stab (.imp Xp .bot) ∈ Cl := plusClosureOf_imp_left dXp_mem
theorem sXnp_mem : PlusFormula.stab (.imp Xnp .bot) ∈ Cl := plusClosureOf_imp_left dXnp_mem
theorem nXp_mem : PlusFormula.imp Xp .bot ∈ Cl := plusClosureOf_stab sXp_mem
theorem nXnp_mem : PlusFormula.imp Xnp .bot ∈ Cl := plusClosureOf_stab sXnp_mem
theorem Xp_mem : Xp ∈ Cl := plusClosureOf_imp_left nXp_mem
theorem Xnp_mem : Xnp ∈ Cl := plusClosureOf_imp_left nXnp_mem
theorem np_mem : np ∈ Cl := plusClosureOf_untl_left Xnp_mem

/-! ## Step 3: the branching sequence -/

/-- Follow `¬p`-successors, except at step `k`, where a `p`-successor is taken. -/
def seqA {n : ℕ} (i0 : Fin n) (fP fN : Fin n → ℤ → Fin n) (u0 : ℤ) (k : ℕ) : ℕ → Fin n
  | 0 => i0
  | m + 1 =>
      if m = k then fP (seqA i0 fP fN u0 k m) (u0 + m + 1)
      else fN (seqA i0 fP fN u0 k m) (u0 + m + 1)

/-! ## Step 4: no family certifies the refutation of `phi0` -/

theorem no_certificate (S : PlusSharingWitnessFamily ([] : PlusContext) Δ0) (t : ℤ) :
    ¬ S.PlusCertifies t := by
  rintro ⟨hat, ⟨hloc, hful⟩, hbox, htgt, hstab⟩
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
  -- The target forces both boxes.
  have hphi : phi0 ∉ S.L S.mainIdx t := htgt.2 phi0 (List.mem_singleton_self _)
  have h1 : th1 ∈ S.L S.mainIdx t := by
    by_contra h
    exact hphi ((himp _ _ th1 _ phi0_mem).mpr (fun h' => absurd h' h))
  have hrest : PlusFormula.imp th2 tail ∉ S.L S.mainIdx t := fun h =>
    hphi ((himp _ _ th1 _ phi0_mem).mpr (fun _ => h))
  have h2 : th2 ∈ S.L S.mainIdx t := by
    by_contra h
    exact hrest ((himp _ _ th2 _ rest_mem).mpr (fun h' => absurd h' h))
  have hall1 : ∀ (i : Fin S.lassos.length) (u : ℤ), dXp ∈ S.L i u :=
    (hbox dXp th1_mem).mp ((hbx _ _ dXp th1_mem).mp h1)
  have hall2 : ∀ (i : Fin S.lassos.length) (u : ℤ), dXnp ∈ S.L i u :=
    (hbox dXnp th2_mem).mp ((hbx _ _ dXnp th2_mem).mp h2)
  -- Every state at every time has a `p`-successor and a `¬p`-successor.
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
  choose fP hfP1 hfP2 using stepP
  choose fN hfN1 hfN2 using stepN
  -- Parameters: start in the forward-periodic region, run longer than the position count.
  set u0 : ℤ := S.NM with hu0
  set k : ℕ := S.lassos.length * S.perFwd + 1 with hk
  set a : ℕ → Fin S.lassos.length := seqA S.mainIdx fP fN u0 k with ha
  have ha_succ : ∀ m, a (m + 1) =
      if m = k then fP (a m) (u0 + m + 1) else fN (a m) (u0 + m + 1) := fun m => rfl
  have ha_share : ∀ m : ℕ, S.share (u0 + m + 1) (a m) (a (m + 1)) := by
    intro m
    rw [ha_succ]
    split_ifs
    · exact hfP1 _ _
    · exact hfN1 _ _
  have ha_p : ∀ m : ℕ, (m = k → p ∈ S.L (a (m + 1)) (u0 + m + 1 + 1)) ∧
      (m ≠ k → p ∉ S.L (a (m + 1)) (u0 + m + 1 + 1)) := by
    intro m
    rw [ha_succ]
    constructor
    · intro h; rw [if_pos h]; exact hfP2 _ _
    · intro h; rw [if_neg h]; exact hfN2 _ _
  -- The state path.
  set σ : ℤ → Fin S.lassos.length := fun u => a (u - u0).toNat with hσ
  have hσ_at : ∀ m : ℕ, σ (u0 + m) = a m := by
    intro m
    simp only [hσ]
    congr 1
    omega
  have hσstep : ∀ u : ℤ, stepOf S.lassos.length S.repBack S.repMid S.repFwd u (σ u) (σ (u + 1)) := by
    intro u
    by_cases hu : u0 ≤ u
    · obtain ⟨m, rfl⟩ : ∃ m : ℕ, u = u0 + m := ⟨(u - u0).toNat, by omega⟩
      rw [hσ_at, show u0 + (m : ℤ) + 1 = u0 + ((m + 1 : ℕ) : ℤ) by push_cast; ring, hσ_at]
      refine ⟨a m, rfl, ?_⟩
      exact ha_share m
    · have e1 : σ u = a 0 := by
        simp only [hσ]; congr 1; omega
      have e2 : σ (u + 1) = a 0 := by
        simp only [hσ]; congr 1; omega
      rw [e1, e2]
      exact ⟨a 0, rfl, rfl⟩
  obtain ⟨τ, hτ, hτσ⟩ := S.lift σ hσstep
  have hτstep : ∀ u : ℤ, S.trans u (τ u) (τ (u + 1)) := hτ
  have hτshare : ∀ u : ℤ, S.share u (σ u) (τ u) := hτσ
  -- Atom `p` along the tracking thread.
  have hτp : ∀ m : ℕ, (m = k → p ∈ S.L (τ (u0 + m + 2)) (u0 + m + 2)) ∧
      (m ≠ k → p ∉ S.L (τ (u0 + m + 2)) (u0 + m + 2)) := by
    intro m
    have hsh1 : S.share (u0 + m + 2) (a (m + 1)) (a (m + 2)) := by
      have := ha_share (m + 1)
      rw [show u0 + ((m + 1 : ℕ) : ℤ) + 1 = u0 + (m : ℤ) + 2 by push_cast; ring] at this
      exact this
    have hsh2 : S.share (u0 + m + 2) (a (m + 2)) (τ (u0 + m + 2)) := by
      have := hτshare (u0 + m + 2)
      rw [show u0 + (m : ℤ) + 2 = u0 + ((m + 2 : ℕ) : ℤ) by push_cast; ring, hσ_at] at this
      rw [show u0 + (m : ℤ) + 2 = u0 + ((m + 2 : ℕ) : ℤ) by push_cast; ring]
      exact this
    have hsh : S.share (u0 + m + 2) (a (m + 1)) (τ (u0 + m + 2)) :=
      PlusSharingWitnessFamily.share_trans hsh1 hsh2
    have hco := hat (u0 + m + 2) _ _ hsh pa
    have hap := ha_p m
    rw [show u0 + (m : ℤ) + 1 + 1 = u0 + (m : ℤ) + 2 by ring] at hap
    exact ⟨fun h => hco.mp (hap.1 h), fun h hp => hap.2 h (hco.mpr hp)⟩
  -- `⊤` is labelled everywhere.
  have htp : ∀ (i : Fin S.lassos.length) (u : ℤ), tp ∈ S.L i u := fun i u =>
    (himp i u .bot .bot tp_mem).mpr (fun h => h)
  -- `Fp` propagates backwards along the tracking thread.
  have hFback : ∀ v w : ℤ, w = v + 1 →
      (p ∈ S.L (τ w) w ∨ Fp ∈ S.L (τ w) w) → Fp ∈ S.L (τ v) v := by
    intro v w hw h
    subst hw
    refine (huntl (τ v) v (τ (v + 1)) (hτstep v) tp p Fp_mem).mpr ?_
    rcases h with h | h
    · exact Or.inl h
    · exact Or.inr ⟨htp _ _, h⟩
  have hF : ∀ d : ℕ, Fp ∈ S.L (τ (u0 + k + 1 - d)) (u0 + k + 1 - d) := by
    intro d
    induction d with
    | zero =>
      refine hFback _ (u0 + k + 2) (by push_cast; ring) (Or.inl ?_)
      exact (hτp k).1 rfl
    | succ d ih =>
      refine hFback _ (u0 + k + 1 - d) (by push_cast; ring) (Or.inr ih)
  -- Pigeonhole on the thread's index at `n + 1` times one period apart.
  have hNF : (0 : ℤ) < S.NF := S.NF_pos
  obtain ⟨x, y, hxy, hg⟩ := Fintype.exists_ne_map_eq_of_card_lt
    (fun m : Fin (S.lassos.length + 1) => τ (u0 + 2 + (m : ℕ) * S.NF)) (by simp)
  wlog hlt : (x : ℕ) < (y : ℕ) generalizing x y
  · exact this y x hxy.symm hg.symm
      (lt_of_le_of_ne (not_lt.mp hlt) (fun h => hxy (Fin.ext h.symm)))
  have hg' : τ (u0 + 2 + (x : ℕ) * S.NF) = τ (u0 + 2 + (y : ℕ) * S.NF) := hg
  set v : ℤ := u0 + 2 + (x : ℕ) * S.NF with hv
  set v' : ℤ := u0 + 2 + (y : ℕ) * S.NF with hv'
  set c : ℤ := ((y : ℕ) : ℤ) - ((x : ℕ) : ℤ) with hc
  have hcpos : 0 < c := by simp only [hc]; omega
  set D : ℤ := S.NF * c with hD
  have hDpos : 0 < D := mul_pos hNF hcpos
  have hvv' : v' = v + D := by simp only [hv, hv', hD, hc]; ring
  have hvlo : u0 + 2 ≤ v := by
    have : (0 : ℤ) ≤ ((x : ℕ) : ℤ) * S.NF := mul_nonneg (Int.natCast_nonneg _) hNF.le
    simp only [hv]; omega
  have hv'hi : v' ≤ u0 + k + 1 := by
    have hy : ((y : ℕ) : ℤ) ≤ (S.lassos.length : ℤ) := by
      have := y.2
      omega
    have : ((y : ℕ) : ℤ) * S.NF ≤ (S.lassos.length : ℤ) * S.NF := mul_le_mul_of_nonneg_right hy hNF.le
    have hkc : ((k : ℕ) : ℤ) = (S.lassos.length : ℤ) * S.NF + 1 := by
      simp only [hk]; push_cast; rfl
    simp only [hv']; omega
  -- No `p` on the thread between `v` and `v'`.
  have hnop : ∀ w : ℤ, v ≤ w → w < v' → p ∉ S.L (τ w) w := by
    intro w h1 h2
    obtain ⟨m, rfl⟩ : ∃ m : ℕ, w = u0 + m + 2 := ⟨(w - u0 - 2).toNat, by omega⟩
    exact (hτp m).2 (by omega)
  -- The looped thread.
  set fold : ℤ → ℤ := fun w => if w < v then w else v + (w - v) % D with hfold
  have hfold_lt : ∀ w, w < v → fold w = w := fun w h => by simp only [hfold, if_pos h]
  have hfold_ge : ∀ w, v ≤ w → fold w = v + (w - v) % D := fun w h => by
    simp only [hfold, if_neg (not_lt.mpr h)]
  have hr_nonneg : ∀ w, 0 ≤ (w - v) % D := fun w => Int.emod_nonneg _ hDpos.ne'
  have hr_lt : ∀ w, (w - v) % D < D := fun w => Int.emod_lt_of_pos _ hDpos
  -- Data at `w ≥ v` agree with data at `fold w`.
  have hcong : ∀ w, v ≤ w → (w - S.NM) % S.NF = (fold w - S.NM) % S.NF := by
    intro w hw
    rw [hfold_ge w hw]
    have hdecomp : w - v = (w - v) % D + D * ((w - v) / D) := (Int.emod_add_mul_ediv _ _).symm
    have : w - S.NM = (v + (w - v) % D - S.NM) + S.NF * (c * ((w - v) / D)) := by
      have : D * ((w - v) / D) = S.NF * (c * ((w - v) / D)) := by simp only [hD]; ring
      omega
    rw [this, Int.add_mul_emod_self_left]
  have hfold_NM : ∀ w, v ≤ w → S.NM ≤ fold w := by
    intro w hw
    rw [hfold_ge w hw]
    have := hr_nonneg w
    omega
  have hloopstep : ∀ w : ℤ, S.trans w (τ (fold w)) (τ (fold (w + 1))) := by
    intro w
    by_cases hw : w < v
    · have e1 := hfold_lt w hw
      have e2 : fold (w + 1) = w + 1 := by
        by_cases hw' : w + 1 < v
        · exact hfold_lt _ hw'
        · have : w + 1 = v := by omega
          rw [hfold_ge _ (by omega), this]
          simp
      rw [e1, e2]
      exact hτstep w
    · have hw' : v ≤ w := not_lt.mp hw
      have hrn := hr_nonneg w
      have hrl := hr_lt w
      -- The step taken at the folded time.
      have key : S.trans (fold w) (τ (fold w)) (τ (fold (w + 1))) := by
        rw [hfold_ge w hw', hfold_ge (w + 1) (by omega)]
        have hsplit : w + 1 - v = ((w - v) % D + 1) + D * ((w - v) / D) := by
          have := Int.emod_add_mul_ediv (w - v) D
          omega
        by_cases hwrap : (w - v) % D + 1 < D
        · have : (w + 1 - v) % D = (w - v) % D + 1 := by
            rw [hsplit, Int.add_mul_emod_self_left]
            exact Int.emod_eq_of_lt (by omega) hwrap
          rw [this, show v + ((w - v) % D + 1) = v + (w - v) % D + 1 by ring]
          exact hτstep _
        · have hD' : (w - v) % D + 1 = D := by omega
          have : (w + 1 - v) % D = 0 := by
            rw [hsplit, Int.add_mul_emod_self_left, hD']
            exact Int.emod_self
          rw [this, add_zero]
          have hst := hτstep (v + (w - v) % D)
          rw [show v + (w - v) % D + 1 = v' by rw [hvv']; omega] at hst
          have hgv : τ v' = τ v := hg'.symm
          rw [hgv] at hst
          exact hst
      -- Transport it to the real time by forward periodicity.
      have hNMw : S.NM ≤ w := by omega
      have hNMf : S.NM ≤ fold w := hfold_NM w hw'
      have hraw : S.transRaw w = S.transRaw (fold w) :=
        S.transRaw_congr_NF hNMw hNMf (hcong w hw')
      have hcong1 : (w + 1 - S.NM) % S.NF = (fold w + 1 - S.NM) % S.NF := by
        have := hcong w hw'
        have e1 : w + 1 - S.NM = (w - S.NM) + 1 := by ring
        have e2 : fold w + 1 - S.NM = (fold w - S.NM) + 1 := by ring
        rw [e1, e2, Int.add_emod, this, ← Int.add_emod]
      have hrep : S.rep (w + 1) = S.rep (fold w + 1) :=
        (S.data_congr_fwd (by omega) (by omega) hcong1).1
      rw [S.trans_def] at key ⊢
      refine ⟨by rw [hraw]; exact key.1, ?_⟩
      rw [S.share_def, hrep]
      exact (S.share_def _ _ _).mp key.2
  let θ : S.Thread := ⟨fun w => τ (fold w), hloopstep⟩
  have hθv : θ.idx v = τ v := by
    show τ (fold v) = τ v
    rw [hfold_ge v le_rfl]
    simp
  -- `Fp` is labelled at the loop's entry.
  have hFv : Fp ∈ S.L (τ v) v := by
    have := hF (u0 + k + 1 - v).toNat
    rw [show u0 + (k : ℤ) + 1 - ((u0 + (k : ℤ) + 1 - v).toNat : ℤ) = v by omega] at this
    exact this
  obtain ⟨s, hs, hps, -⟩ := hful.1 (τ v) v tp p hFv θ hθv
  -- But the loop never sees `p`.
  have hθL : S.L (θ.idx s) s = S.L (τ (fold s)) (fold s) :=
    (S.data_congr_fwd (by omega) (hfold_NM s hs.le) (hcong s hs.le)).2 _
  rw [hθL] at hps
  refine hnop (fold s) ?_ ?_ hps
  · rw [hfold_ge s hs.le]
    have := hr_nonneg s
    omega
  · rw [hfold_ge s hs.le, hvv']
    have := hr_lt s
    omega

/-- **The L⁺ compression statement fails at `phi0`.** A genuine ℤ-time non-validity with no
certifying family of any size. -/
theorem compression_statement_fails :
    ¬ PlusValidZTime phi0 ∧
      ¬ ∃ (S : PlusSharingWitnessFamily ([] : PlusContext) [phi0]) (t : ℤ), S.PlusCertifies t :=
  ⟨not_plusValidZTime_phi0, fun ⟨S, t, h⟩ => no_certificate S t h⟩

#print axioms compression_statement_fails

end Probe703
