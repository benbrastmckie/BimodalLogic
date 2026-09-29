import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Incompleteness

/-! Scratch probe: does (C1')'s `untl` clause also force class agreement, one step shifted? -/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula

namespace PlusSharingWitnessFamily

/-- (C1') forces `share`-class agreement on the one-step-shifted `untl` unfolding. -/
theorem untl_shift_share_congr {Γ Del : PlusContext} (S : PlusSharingWitnessFamily Γ Del)
    (hloc : S.PlusLocalCoherentShare) (t : ℤ) (i j : Fin S.lassos.length)
    (hij : S.share t i j) (g e : PlusFormula)
    (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) :
    ((e ∈ S.L i t ∨ (g ∈ S.L i t ∧ PlusFormula.untl g e ∈ S.L i t)) ↔
      (e ∈ S.L j t ∨ (g ∈ S.L j t ∧ PlusFormula.untl g e ∈ S.L j t))) := by
  have hii : S.share (t - 1 + 1) i i := S.share_refl _ i
  have hij' : S.share (t - 1 + 1) i j := by rw [sub_add_cancel]; exact hij
  have h1 := (hloc i (t - 1)).2.2.2.1 i hii g e hc
  have h2 := (hloc i (t - 1)).2.2.2.1 j hij' g e hc
  have h := h1.symm.trans h2
  rwa [sub_add_cancel] at h

/-- `Fp → (p ∨ ⊡Fp)`, i.e. `(¬p ∧ Fp) → ⊡Fp`. -/
def stabUntlTarget (p : Atom) : PlusFormula :=
  .imp (PlusFormula.untl PlusFormula.top (.atom p))
    (.imp (.imp (.atom p) .bot) (.stab (PlusFormula.untl PlusFormula.top (.atom p))))

theorem not_plusCertifies_stabUntl (p : Atom)
    (S : PlusSharingWitnessFamily [] [stabUntlTarget p]) (t : ℤ) : ¬ S.PlusCertifies t := by
  classical
  rintro ⟨hat, ⟨hloc, -⟩, -, htgt, hstab⟩
  set F : PlusFormula := PlusFormula.untl PlusFormula.top (.atom p) with hF
  have hcl_tgt : stabUntlTarget p ∈ plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusConclusion_mem_closure (List.mem_singleton_self _)
  have hcl_F : F ∈ plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusClosureOf_imp_left hcl_tgt
  have hcl_R : PlusFormula.imp (.imp (.atom p) .bot) (.stab F) ∈
      plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusClosureOf_imp_right hcl_tgt
  have hcl_np : PlusFormula.imp (.atom p) .bot ∈
      plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusClosureOf_imp_left hcl_R
  have hcl_stab : PlusFormula.stab F ∈
      plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusClosureOf_imp_right hcl_R
  have hcl_top : PlusFormula.top ∈ plusClosureOf (([] : PlusContext) ++ [stabUntlTarget p]) :=
    plusClosureOf_untl_right hcl_F
  set i := S.toPlusWitnessFamily.mainIdx with hidef
  have hnotL : stabUntlTarget p ∉ S.L i t := htgt.2 _ (List.mem_singleton_self _)
  have himp := (hloc i t).2.1 F _ hcl_tgt
  have hFi : F ∈ S.L i t := by
    by_contra hno
    exact hnotL (himp.mpr (fun h => absurd h hno))
  have hRnot : PlusFormula.imp (.imp (.atom p) .bot) (.stab F) ∉ S.L i t :=
    fun h => hnotL (himp.mpr (fun _ => h))
  have himpR := (hloc i t).2.1 _ _ hcl_R
  have hnpi : PlusFormula.imp (.atom p) .bot ∈ S.L i t := by
    by_contra hno
    exact hRnot (himpR.mpr (fun h => absurd h hno))
  have hstabnot : PlusFormula.stab F ∉ S.L i t := fun h => hRnot (himpR.mpr (fun _ => h))
  have hpi : PlusFormula.atom p ∉ S.L i t :=
    fun hp => (hloc i t).1 (((hloc i t).2.1 _ _ hcl_np).mp hnpi hp)
  rw [hstab i t F hcl_stab] at hstabnot
  have hex : ∃ j, S.share t i j ∧ F ∉ S.L j t := by
    by_contra hc
    refine hstabnot (fun j hj => ?_)
    by_contra hno
    exact hc ⟨j, hj, hno⟩
  obtain ⟨j, hij, hFj⟩ := hex
  have hpj : PlusFormula.atom p ∉ S.L j t := fun hp => hpi ((hat t i j hij p).mpr hp)
  have htopi : PlusFormula.top ∈ S.L i t :=
    ((hloc i t).2.1 .bot .bot hcl_top).mpr (fun h => h)
  have hcong := untl_shift_share_congr S hloc t i j hij PlusFormula.top (.atom p) hcl_F
  have hL : (PlusFormula.atom p ∈ S.L i t ∨ (PlusFormula.top ∈ S.L i t ∧ F ∈ S.L i t)) :=
    Or.inr ⟨htopi, hFi⟩
  rcases hcong.mp hL with h | ⟨_, h⟩
  · exact hpj h
  · exact hFj h

end PlusSharingWitnessFamily

end FormalSystem.Metalogic.Decidability
