/-
Probe: the branching L-plus certificate is INCOMPLETE for ℤ-time refutation.

Research probe for the stability-compression research round. Every declaration below was run
green through `lean_run_code` against the pinned toolchain; nothing here is a sketch.

WHAT IS SHOWN, in three parts.

1. `snce_state_determined` — the root cause. (C1') `PlusLocalCoherentShare`'s `snce` clause
   quantifies its predecessor universally over the `share`-class at the SAME time `t`. Reading it
   twice (once at `i` with `k := j`, once at `j` with `k := j` by reflexivity) forces any two
   indices naming the same world state at `t` to AGREE on every `snce` formula of the closure.
   So in every presented model, past-tense truth is a function of the world state.

2. `no_certificate` / `no_certificate_premise_form` — the consequence. No
   `PlusSharingWitnessFamily` certifies any instance of the schema `(g S e) → ⊡(g S e)`, at any
   time, at any size — whether the schema is placed as the conclusion (`Del = [φ]`) or as a
   negated premise (`Γ = [¬φ]`, `Del = []`), so "reformulate the target" is not an escape.
   Only (C1')'s `imp`/`bot`/`snce` clauses, (C4) and (C5) are used: the obstruction involves
   neither (C0) nor (C2') nor (C3), and no bound.

3. `not_plusValidZTime_instance` — the schema is a genuine non-validity. At `g := ⊤`,
   `e := p` the instance is `Pp → ⊡Pp`, refuted on the permissive ℤ-frame `NF` by the two
   histories `PlusNonValidities.refute_somePast_stab` already uses.

CONCLUSION. `¬ PlusValidZTime φ → ∃ S t, ... ∧ S.PlusCertifies t` — the L-plus analogue of
`WitnessFamily/Compression/Family.lean`'s `exists_witnessFamily_of_not_validZTime` — is FALSE
against the landed six conditions. It is not unproved-but-true and the failure is not about the
size of the bound: for these targets the certificate class is empty.
-/
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily
import FormalSystem.PlusLanguage.PlusNonValidities

open FormalSystem.Syntax FormalSystem.PlusLanguage FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability
open FormalSystem.PlusLanguage.PlusFormula
open PlusTruth
open FormalSystem.ProofSystem

namespace Probe685

/-! ## 1. The root cause: (C1')'s `snce` clause makes past truth state-determined -/

/-- (C1') forces two indices naming the same state at `t` to agree on every `snce` formula of
the closure. Both readings of the one clause; no other condition is used. -/
theorem snce_state_determined {Γ Del : PlusContext} (S : PlusSharingWitnessFamily Γ Del)
    (hloc : S.PlusLocalCoherentShare) (t : ℤ) (i j : Fin S.lassos.length)
    (hij : S.share t i j) (g e : PlusFormula)
    (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) :
    (PlusFormula.snce g e ∈ S.L i t ↔ PlusFormula.snce g e ∈ S.L j t) :=
  ((hloc i t).2.2.2.2 j hij g e hc).trans
    ((hloc j t).2.2.2.2 j (S.share_refl t j) g e hc).symm

/-! ## 2. The consequence: an empty certificate class -/

/-- The schema `(g S e) → ⊡(g S e)`. -/
def tgt (g e : PlusFormula) : PlusFormula :=
  .imp (PlusFormula.snce g e) (.stab (PlusFormula.snce g e))

/-- **No branching L-plus certificate refutes any instance of `(g S e) → ⊡(g S e)`**, at any
time and at any size. Conclusion placement (`Del = [tgt]`). -/
theorem no_certificate (g e : PlusFormula) (S : PlusSharingWitnessFamily [] [tgt g e]) (t : ℤ) :
    ¬ S.PlusCertifies t := by
  classical
  rintro ⟨-, ⟨hloc, -⟩, -, htgt, hstab⟩
  set A : PlusFormula := PlusFormula.snce g e with hAdef
  have hcl_tgt : tgt g e ∈ plusClosureOf (([] : PlusContext) ++ [tgt g e]) :=
    plusConclusion_mem_closure (List.mem_singleton_self _)
  have hcl_stab : PlusFormula.stab A ∈ plusClosureOf (([] : PlusContext) ++ [tgt g e]) :=
    plusClosureOf_imp_right hcl_tgt
  have hcl_A : A ∈ plusClosureOf (([] : PlusContext) ++ [tgt g e]) :=
    plusClosureOf_stab hcl_stab
  set i := S.toPlusWitnessFamily.mainIdx with hidef
  have hnotL : PlusFormula.imp A (PlusFormula.stab A) ∉ S.L i t :=
    htgt.2 _ (List.mem_singleton_self _)
  have himp := (hloc i t).2.1 A (PlusFormula.stab A) hcl_tgt
  have h1 : ¬ (A ∈ S.L i t → PlusFormula.stab A ∈ S.L i t) := fun h => hnotL (himp.mpr h)
  have hAi : A ∈ S.L i t := by
    by_contra hno
    exact h1 (fun h => absurd h hno)
  have hSt : PlusFormula.stab A ∉ S.L i t := fun h => h1 (fun _ => h)
  rw [hstab i t A hcl_stab] at hSt
  have hex : ∃ j, S.share t i j ∧ A ∉ S.L j t := by
    by_contra hc
    refine hSt (fun j hj => ?_)
    by_contra hno
    exact hc ⟨j, hj, hno⟩
  obtain ⟨j, hij, hAj⟩ := hex
  exact hAj ((snce_state_determined S hloc t i j hij g e hcl_A).mp hAi)

/-- `¬((g S e) → ⊡(g S e))`, for the premise placement. -/
def ngt (g e : PlusFormula) : PlusFormula := PlusFormula.imp (tgt g e) PlusFormula.bot

/-- **The same, with the target as a negated premise** (`Γ = [¬tgt]`, `Del = []`): moving the
target from the conclusion list to the premise list is not an escape. -/
theorem no_certificate_premise_form (g e : PlusFormula)
    (S : PlusSharingWitnessFamily [ngt g e] []) (t : ℤ) : ¬ S.PlusCertifies t := by
  classical
  rintro ⟨-, ⟨hloc, -⟩, -, htgt, hstab⟩
  set A : PlusFormula := PlusFormula.snce g e with hAdef
  set B : PlusFormula := PlusFormula.imp A (PlusFormula.stab A) with hBdef
  have hcl_n : ngt g e ∈ plusClosureOf (([ngt g e] : PlusContext) ++ []) :=
    plusPremise_mem_closure (List.mem_singleton_self _)
  have hcl_B : B ∈ plusClosureOf (([ngt g e] : PlusContext) ++ []) := plusClosureOf_imp_left hcl_n
  have hcl_stab : PlusFormula.stab A ∈ plusClosureOf (([ngt g e] : PlusContext) ++ []) :=
    plusClosureOf_imp_right hcl_B
  have hcl_A : A ∈ plusClosureOf (([ngt g e] : PlusContext) ++ []) := plusClosureOf_stab hcl_stab
  set i := S.toPlusWitnessFamily.mainIdx with hidef
  have hin : PlusFormula.imp B PlusFormula.bot ∈ S.L i t :=
    htgt.1 _ (List.mem_singleton_self _)
  have hbot : PlusFormula.bot ∉ S.L i t := (hloc i t).1
  have himpn := (hloc i t).2.1 B PlusFormula.bot hcl_n
  have hBnot : B ∉ S.L i t := fun hB => hbot (himpn.mp hin hB)
  have himp := (hloc i t).2.1 A (PlusFormula.stab A) hcl_B
  have h1 : ¬ (A ∈ S.L i t → PlusFormula.stab A ∈ S.L i t) := fun h => hBnot (himp.mpr h)
  have hAi : A ∈ S.L i t := by
    by_contra hno
    exact h1 (fun h => absurd h hno)
  have hSt : PlusFormula.stab A ∉ S.L i t := fun h => h1 (fun _ => h)
  rw [hstab i t A hcl_stab] at hSt
  have hex : ∃ j, S.share t i j ∧ A ∉ S.L j t := by
    by_contra hc
    refine hSt (fun j hj => ?_)
    by_contra hno
    exact hc ⟨j, hj, hno⟩
  obtain ⟨j, hij, hAj⟩ := hex
  exact hAj ((snce_state_determined S hloc t i j hij g e hcl_A).mp hAi)

/-! ## 3. The schema is a genuine ℤ-time non-validity -/

/-- **`Pp → ⊡Pp` is not ℤ-time valid**: the `tgt` instance at `g := ⊤`, `e := p`, refuted on the
permissive ℤ-frame `NF` with the two histories of `refute_somePast_stab`. -/
theorem not_plusValidZTime_instance (p : Atom) :
    ¬ PlusValidZTime (tgt PlusFormula.top (PlusFormula.atom p)) := by
  intro h
  have hsat : FrameClass.ZTime.Sat NF := ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩
  have hv := h NF hsat natModel (natHist fun _ => 0) 0
  have hA : PlusTruthAt natModel (natHist fun _ => 0) 0 (somePast (PlusFormula.atom p)) := by
    rw [somePast_iff]
    exact ⟨(-1 : ℤ), (by decide : (-1 : ℤ) < 0), (rfl : (0 : ℕ) = 0)⟩
  have hB := hv hA (natHist fun s => if s < 0 then 1 else 0)
    (by change (0 : ℕ) = (if (0 : ℤ) < 0 then 1 else 0); simp)
  rw [show PlusFormula.snce PlusFormula.top (PlusFormula.atom p)
      = somePast (PlusFormula.atom p) from rfl, somePast_iff] at hB
  obtain ⟨s, hs, hat⟩ := hB
  rw [atom_iff] at hat
  have hs' : (s : ℤ) < 0 := hs
  have v' : (if (s : ℤ) < 0 then (1 : ℕ) else 0) = 0 := hat
  rw [if_pos hs'] at v'
  exact one_ne_zero v'

end Probe685
