/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Embed

/-!
# The Embedded Certificate's Semantics, and the Flagship

`Embed.lean` builds the certificate `WitnessFamily.sliced` out of a landed `WitnessFamily` and
reads off its structure. This module supplies the **semantic** half: a truth lemma for the embedded
model that stands on the family's own certification conditions and on nothing the certificate has
yet to establish.

## Why a second truth lemma, and why it is not a duplicate

`Sound.lean`'s `plusTruthAt_iff_canAt` is the subtree's own truth lemma, and it cannot serve here:
it takes `BoxLabelFaithful`, `TailStable`, `StabFaithful` and `BoxLiveFaithful` as hypotheses, and
those are exactly what an embedded certificate is trying to establish. Using it would be circular.
`WitnessFamily.truth_iff_mem` cannot serve either — it is stated at the L side's own shift-set
model on carrier `Fin k × ℤ`, not at the sliced frame on `ℤ × Fin k`, and transporting it would
need a model isomorphism this subtree does not have.

What makes a direct induction cheap here is the **self-loop** edge relation. Every history of the
embedded frame is an offset path whose index never changes (`sliced_history_const`), so the `□`
clause's history quantifier collapses to a quantifier over one index and one offset, and the two
label-level inner inductions already landed on the L side
(`WitnessFamily.untl_mem_of_witness` / `snce_mem_of_witness`) discharge the two temporal cases
without being re-derived. The `⊡` case never arises: the induction runs over `ψ : Formula`, and
`ofFormula ψ` is never a top-level `stab`.

## Main results

- `WitnessFamily.sliced_history_const` — every history of the embedded frame has a constant index
- `WitnessFamily.sliced_exists_history` — and every index-and-offset pair is realized by one
- `WitnessFamily.sliced_plusTruthAt_iff_mem` — the truth lemma: truth along a history with index
  `j` and offset `k` is membership in lasso `j`'s label at the shifted time
- `WitnessFamily.sliced_canAt_iff_mem` — the canonical membership predicate, likewise
- `WitnessFamily.sliced_target_lab_eq_canLab` — hypothesis `hcan` of the completeness headline
- `WitnessFamily.sliced_slabTrue` — hypothesis `hst`, both clauses

## Tags

plus-language · certificate · time-sliced · embedding · truth-lemma
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.Semantics

/-! ## A pointwise-constant integer function is constant -/

namespace Periodic

/-- **A function on `ℤ` that never changes across one step is constant.** Used to collapse the
embedded frame's history quantifier: a self-loop edge relation forces every history's index to be
pointwise fixed, and this turns that into a single index. -/
theorem const_of_step_eq {α : Type*} {f : ℤ → α} (h : ∀ t : ℤ, f t = f (t + 1)) (t : ℤ) :
    f t = f 0 := by
  have hup : ∀ m : ℕ, f (m : ℤ) = f 0 := by
    intro m
    induction m with
    | zero => rfl
    | succ k ih =>
      rw [show ((k + 1 : ℕ) : ℤ) = (k : ℤ) + 1 from by push_cast; ring, ← h (k : ℤ), ih]
  have hdown : ∀ m : ℕ, f (-(m : ℤ)) = f 0 := by
    intro m
    induction m with
    | zero => rfl
    | succ k ih =>
      have := h (-((k : ℤ) + 1))
      rw [show -((k : ℤ) + 1) + 1 = -(k : ℤ) from by ring] at this
      rw [show (-((k + 1 : ℕ) : ℤ)) = -((k : ℤ) + 1) from by push_cast; ring, this, ih]
  rcases Int.lt_or_le t 0 with ht | ht
  · obtain ⟨m, hm⟩ := Int.eq_ofNat_of_zero_le (show (0 : ℤ) ≤ -t from by omega)
    rw [show t = -(m : ℤ) from by omega]
    exact hdown m
  · obtain ⟨m, rfl⟩ := Int.eq_ofNat_of_zero_le ht
    exact hup m

end Periodic

namespace WitnessFamily

variable {φ : Formula}

/-! ## The embedded frame's histories, in both directions

A history of `(W.sliced tt).frame` is an offset step path, and the self-loop edge relation forces
its index to be constant. So the history space is exactly `Fin W.lassos.length × ℤ` — one index and
one offset — which is what collapses the `□` clause of the truth lemma below.
-/

/-- **Every history of the embedded frame has a constant index.** -/
theorem sliced_history_const (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ)
    (σ : WorldHistory ((W.sliced tt).frame (W.sliced_biSerial tt)).toTaskFrame) :
    ∃ (j : Fin (W.sliced tt).n) (k : ℤ),
      ∀ u : ℤ, (show ℤ × Fin (W.sliced tt).n from σ.state u) = (u + k, j) := by
  obtain ⟨k, g, hg, hpath, -⟩ := (W.sliced tt).exists_stepHistory (W.sliced_biSerial tt) σ
  have hstep : ∀ t : ℤ, g t = g (t + 1) := by
    intro t
    have := hg t
    rw [W.sliced_edge tt t] at this
    exact of_decide_eq_true this
  refine ⟨g 0, k, fun u => ?_⟩
  rw [show (show ℤ × Fin (W.sliced tt).n from σ.state u) = σ.path u from rfl, hpath u,
    Periodic.const_of_step_eq hstep (u + k)]

/-- **Every index-and-offset pair is realized by a history.** The converse of
`sliced_history_const`, and what the `□` clause's forward direction needs. -/
theorem sliced_exists_history (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ)
    (j : Fin (W.sliced tt).n) (k : ℤ) :
    ∃ σ : WorldHistory ((W.sliced tt).frame (W.sliced_biSerial tt)).toTaskFrame,
      ∀ u : ℤ, (show ℤ × Fin (W.sliced tt).n from σ.state u) = (u + k, j) := by
  obtain ⟨σ, hσ⟩ :=
    ((W.sliced tt).mem_HF_iff_slicedPath (W.sliced_biSerial tt) (fun u => (u + k, j))).mpr
      ⟨k, fun _ => j, fun t => by
        rw [W.sliced_edge tt (t + k)]
        simp only [decide_eq_true_eq], rfl⟩
  exact ⟨σ, fun u => congrFun hσ u⟩

/-! ## The truth lemma for the embedded model

Six cases, one per `Formula` constructor; the `⊡` case does not arise because the induction runs
over the base language. Three of the family's four certification conditions are consumed, each
exactly once: `LocalCoherentLab` in `bot`, `imp` and `box`, `BoxFaithful` in `box`, and
`FulfillingLab` in `untl` and `snce`.
-/

/--
**Truth in the embedded model is label membership.**

Along a history with constant index `j` and offset `k`, the embedded formula `ofFormula ψ` is true
at time `u` exactly when `ψ` is labelled on lasso `j` at time `u + k`.
-/
theorem sliced_plusTruthAt_iff_mem (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ) :
    ∀ ψ : Formula, ψ ∈ closureOf (([] : Context) ++ [φ]) →
      ∀ (σ : WorldHistory ((W.sliced tt).frame (W.sliced_biSerial tt)).toTaskFrame)
        (j : Fin (W.sliced tt).n) (k : ℤ),
        (∀ u : ℤ, (show ℤ × Fin (W.sliced tt).n from σ.state u) = (u + k, j)) →
        ∀ u : ℤ,
          (PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ u (ofFormula ψ)
            ↔ ψ ∈ W.L j (u + k)) := by
  intro ψ
  induction ψ with
  | atom a =>
    intro _ σ j k hσ u
    rw [show PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ u
        (ofFormula (Formula.atom a))
        = ((W.sliced tt).model (W.sliced_biSerial tt)).valuation (σ.state u) (a) from rfl]
    rw [(W.sliced tt).model_valuation (W.sliced_biSerial tt)
      (show ℤ × Fin (W.sliced tt).n from σ.state u) a]
    rw [hσ u]
    rw [W.sliced_slab tt (u + k) j]
    exact mem_trLab (X := W.L j (u + k)) (ψ := Formula.atom a)
  | bot =>
    intro _ σ j k hσ u
    simp only [ofFormula]
    constructor
    · intro h; exact absurd h (by simp)
    · intro h; exact absurd h (hloc j (u + k)).1
  | imp a b iha ihb =>
    intro hmem σ j k hσ u
    have hab := (hloc j (u + k)).2.1 a b hmem
    rw [show (ofFormula (Formula.imp a b)) = PlusFormula.imp (ofFormula a) (ofFormula b) from rfl]
    rw [show PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ u
        (PlusFormula.imp (ofFormula a) (ofFormula b))
        = (PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ u (ofFormula a) →
            PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ u (ofFormula b)) from rfl]
    rw [iha (closureOf_imp_left hmem) σ j k hσ u, ihb (closureOf_imp_right hmem) σ j k hσ u, hab]
  | box χ ih =>
    intro hmem σ j k hσ u
    have hχ : χ ∈ closureOf (([] : Context) ++ [φ]) := closureOf_box hmem
    rw [show (ofFormula (Formula.box χ)) = PlusFormula.box (ofFormula χ) from rfl]
    rw [show PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ u
        (PlusFormula.box (ofFormula χ))
        = ∀ τ : WorldHistory ((W.sliced tt).frame (W.sliced_biSerial tt)).toTaskFrame,
            PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) τ u (ofFormula χ) from rfl]
    rw [(hloc j (u + k)).2.2.1 χ hmem, hbf χ hmem]
    constructor
    · intro hall i v
      obtain ⟨τ, hτ⟩ := W.sliced_exists_history tt i (v - u)
      have := (ih hχ τ i (v - u) hτ u).mp (hall τ)
      rwa [show u + (v - u) = v from by omega] at this
    · intro hall τ
      obtain ⟨i, k', hτ⟩ := W.sliced_history_const tt τ
      exact (ih hχ τ i k' hτ u).mpr (hall i (u + k'))
  | untl g e ihg ihe =>
    intro hmem σ j k hσ u
    have hgc : g ∈ closureOf (([] : Context) ++ [φ]) := closureOf_untl_right hmem
    have hec : e ∈ closureOf (([] : Context) ++ [φ]) := closureOf_untl_left hmem
    rw [show (ofFormula (Formula.untl g e))
        = PlusFormula.untl (ofFormula g) (ofFormula e) from rfl]
    rw [show PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ u
        (PlusFormula.untl (ofFormula g) (ofFormula e))
        = ∃ s : ℤ, u < s ∧
            PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ s (ofFormula e) ∧
            ∀ r : ℤ, u < r → r < s →
              PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ r (ofFormula g) from rfl]
    constructor
    · rintro ⟨s, hus, hse, hguard⟩
      have hse' : e ∈ W.L j (s + k) := (ihe hec σ j k hσ s).mp hse
      have hguard' : ∀ r : ℤ, u + k < r → r < s + k → g ∈ W.L j r := by
        intro r hr1 hr2
        have := (ihg hgc σ j k hσ (r - k)).mp (hguard (r - k) (by omega) (by omega))
        rwa [show r - k + k = r from by omega] at this
      exact W.untl_mem_of_witness hloc hmem j (s + k - (u + k)).toNat (u + k) (s + k)
        (by omega) (by omega) hse' hguard'
    · intro h
      obtain ⟨s, hs1, hs2, hs3⟩ := hful.1 j (u + k) g e h
      refine ⟨s - k, by omega, ?_, ?_⟩
      · exact (ihe hec σ j k hσ (s - k)).mpr (by rwa [show s - k + k = s from by omega])
      · intro r hr1 hr2
        exact (ihg hgc σ j k hσ r).mpr (hs3 (r + k) (by omega) (by omega))
  | snce g e ihg ihe =>
    intro hmem σ j k hσ u
    have hgc : g ∈ closureOf (([] : Context) ++ [φ]) := closureOf_snce_right hmem
    have hec : e ∈ closureOf (([] : Context) ++ [φ]) := closureOf_snce_left hmem
    rw [show (ofFormula (Formula.snce g e))
        = PlusFormula.snce (ofFormula g) (ofFormula e) from rfl]
    rw [show PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ u
        (PlusFormula.snce (ofFormula g) (ofFormula e))
        = ∃ s : ℤ, s < u ∧
            PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ s (ofFormula e) ∧
            ∀ r : ℤ, s < r → r < u →
              PlusTruthAt ((W.sliced tt).model (W.sliced_biSerial tt)) σ r (ofFormula g) from rfl]
    constructor
    · rintro ⟨s, hsu, hse, hguard⟩
      have hse' : e ∈ W.L j (s + k) := (ihe hec σ j k hσ s).mp hse
      have hguard' : ∀ r : ℤ, s + k < r → r < u + k → g ∈ W.L j r := by
        intro r hr1 hr2
        have := (ihg hgc σ j k hσ (r - k)).mp (hguard (r - k) (by omega) (by omega))
        rwa [show r - k + k = r from by omega] at this
      exact W.snce_mem_of_witness hloc hmem j (u + k - (s + k)).toNat (u + k) (s + k)
        (by omega) (by omega) hse' hguard'
    · intro h
      obtain ⟨s, hs1, hs2, hs3⟩ := hful.2 j (u + k) g e h
      refine ⟨s - k, by omega, ?_, ?_⟩
      · exact (ihe hec σ j k hσ (s - k)).mpr (by rwa [show s - k + k = s from by omega])
      · intro r hr1 hr2
        exact (ihg hgc σ j k hσ r).mpr (hs3 (r + k) (by omega) (by omega))

/-! ## The canonical membership predicate, at a constant index

`canAt` is defined from the slice labelling alone, so no history and no semantic notion enters.
At a constant index the same six-case induction runs at the label level, consuming
`LocalCoherentLab` and `FulfillingLab` and nothing else. The `box` case is cheaper here than in the
truth lemma: `canAt`'s `□` clause *is* the slice labelling, so `BoxFaithful` is not needed.
-/

/-- **The canonical membership predicate at a constant index is label membership.** -/
theorem sliced_canAt_iff_mem (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (tt : ℤ)
    (g : ℤ → Fin (W.sliced tt).n) (j : Fin (W.sliced tt).n) (hgc : ∀ u : ℤ, g u = j) :
    ∀ ψ : Formula, ψ ∈ closureOf (([] : Context) ++ [φ]) →
      ∀ t : ℤ, ((W.sliced tt).canAt g (ofFormula ψ) t ↔ ψ ∈ W.L j t) := by
  intro ψ
  induction ψ with
  | atom a =>
    intro _ t
    rw [show (ofFormula (Formula.atom a)) = PlusFormula.atom a from rfl,
      (W.sliced tt).canAt_atom g a t, hgc t, W.sliced_slab tt t j]
    exact mem_trLab (X := W.L j t) (ψ := Formula.atom a)
  | bot =>
    intro _ t
    rw [show (ofFormula Formula.bot) = PlusFormula.bot from rfl]
    constructor
    · intro h; exact absurd h ((W.sliced tt).canAt_bot g t)
    · intro h; exact absurd h (hloc j t).1
  | imp a b iha ihb =>
    intro hmem t
    rw [show (ofFormula (Formula.imp a b))
        = PlusFormula.imp (ofFormula a) (ofFormula b) from rfl,
      (W.sliced tt).canAt_imp g (ofFormula a) (ofFormula b) t,
      iha (closureOf_imp_left hmem) t, ihb (closureOf_imp_right hmem) t,
      (hloc j t).2.1 a b hmem]
  | box χ _ =>
    intro hmem t
    rw [show (ofFormula (Formula.box χ)) = PlusFormula.box (ofFormula χ) from rfl,
      (W.sliced tt).canAt_box g (ofFormula χ) t, hgc t, W.sliced_slab tt t j]
    exact mem_trLab (X := W.L j t) (ψ := Formula.box χ)
  | untl g' e ihg ihe =>
    intro hmem t
    have hgc' : g' ∈ closureOf (([] : Context) ++ [φ]) := closureOf_untl_right hmem
    have hec : e ∈ closureOf (([] : Context) ++ [φ]) := closureOf_untl_left hmem
    rw [show (ofFormula (Formula.untl g' e))
        = PlusFormula.untl (ofFormula g') (ofFormula e) from rfl,
      (W.sliced tt).canAt_untl g (ofFormula g') (ofFormula e) t]
    constructor
    · rintro ⟨s, hts, hse, hguard⟩
      exact W.untl_mem_of_witness hloc hmem j (s - t).toNat t s (by omega) hts
        ((ihe hec s).mp hse) (fun r hr1 hr2 => (ihg hgc' r).mp (hguard r hr1 hr2))
    · intro h
      obtain ⟨s, hs1, hs2, hs3⟩ := hful.1 j t g' e h
      exact ⟨s, hs1, (ihe hec s).mpr hs2,
        fun r hr1 hr2 => (ihg hgc' r).mpr (hs3 r hr1 hr2)⟩
  | snce g' e ihg ihe =>
    intro hmem t
    have hgc' : g' ∈ closureOf (([] : Context) ++ [φ]) := closureOf_snce_right hmem
    have hec : e ∈ closureOf (([] : Context) ++ [φ]) := closureOf_snce_left hmem
    rw [show (ofFormula (Formula.snce g' e))
        = PlusFormula.snce (ofFormula g') (ofFormula e) from rfl,
      (W.sliced tt).canAt_snce g (ofFormula g') (ofFormula e) t]
    constructor
    · rintro ⟨s, hst, hse, hguard⟩
      exact W.snce_mem_of_witness hloc hmem j (t - s).toNat t s (by omega) hst
        ((ihe hec s).mp hse) (fun r hr1 hr2 => (ihg hgc' r).mp (hguard r hr1 hr2))
    · intro h
      obtain ⟨s, hs1, hs2, hs3⟩ := hful.2 j t g' e h
      exact ⟨s, hs1, (ihe hec s).mpr hs2,
        fun r hr1 hr2 => (ihg hgc' r).mpr (hs3 r hr1 hr2)⟩

/-! ## The two remaining hypotheses of the completeness headline -/

/--
**Hypothesis `hcan`: the embedded target path's labels are the canonical ones.**

The target path's state sequence is constantly the main lasso's index, so `sliced_canAt_iff_mem`
applies at `j = W.mainIdx`, and both sides are then the main lasso's own label translated.
-/
theorem sliced_target_lab_eq_canLab (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (tt : ℤ) (t : ℤ) :
    (W.sliced tt).target.lab t = (W.sliced tt).canLab (W.sliced tt).target.st t := by
  have hgc : ∀ u : ℤ, (W.sliced tt).target.st u = W.mainIdx := fun u => W.sliced_target_st tt u
  have hkey := W.sliced_canAt_iff_mem hloc hful tt (W.sliced tt).target.st W.mainIdx hgc
  rw [W.sliced_target_lab tt t]
  ext ψ
  rw [(W.sliced tt).mem_canLab]
  constructor
  · intro hψ
    rw [trLab, Finset.mem_image] at hψ
    obtain ⟨χ, hχ, rfl⟩ := hψ
    have hχc : χ ∈ closureOf (([] : Context) ++ [φ]) := W.subset_closureOf W.mainIdx t hχ
    exact ⟨mem_plusClosureOf_ofCtx.mpr hχc, (hkey χ hχc t).mpr hχ⟩
  · rintro ⟨hmem, hcan⟩
    obtain ⟨χ, rfl, hχc⟩ := exists_ofFormula_of_mem_plusClosureOf_ofCtx
      (S := ([] : Context) ++ [φ]) hmem
    exact mem_trLab.mpr ((hkey χ hχc t).mp hcan)

/--
**Hypothesis `hst`: the slice labelling is semantically correct.**

The `□` clause is the truth lemma read at every history, collapsed by `sliced_history_const` and
`sliced_exists_history` to a quantifier over one index and one time, which is exactly what
`BoxFaithful` reports. The `⊡` clause is vacuous: no `⊡`-formula lies in an embedded closure.
-/
theorem sliced_slabTrue (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ) :
    (W.sliced tt).SlabTrue (W.sliced_biSerial tt) := by
  refine ⟨?_, ?_⟩
  · intro χ hχ t w
    obtain ⟨ψ, hψe, hψc⟩ := exists_ofFormula_of_mem_plusClosureOf_ofCtx
      (S := ([] : Context) ++ [φ]) hχ
    obtain ⟨χ', rfl⟩ : ∃ χ' : Formula, ψ = Formula.box χ' := by
      cases ψ with
      | box χ' => exact ⟨χ', rfl⟩
      | atom a => exact absurd hψe (by simp [ofFormula])
      | bot => exact absurd hψe (by simp [ofFormula])
      | imp a b => exact absurd hψe (by simp [ofFormula])
      | untl a b => exact absurd hψe (by simp [ofFormula])
      | snce a b => exact absurd hψe (by simp [ofFormula])
    have hχeq : χ = ofFormula χ' := by
      have := hψe
      rw [show (ofFormula (Formula.box χ')) = PlusFormula.box (ofFormula χ') from rfl] at this
      exact (PlusFormula.box.inj this).symm
    subst hχeq
    rw [W.sliced_slab tt t w,
      show (PlusFormula.box (ofFormula χ')) = ofFormula (Formula.box χ') from rfl, mem_trLab,
      (hloc w t).2.2.1 χ' hψc, hbf χ' hψc]
    constructor
    · intro hall σ u
      obtain ⟨i, k, hσ⟩ := W.sliced_history_const tt σ
      exact (W.sliced_plusTruthAt_iff_mem hloc hful hbf tt χ' (closureOf_box hψc) σ i k hσ u).mpr
        (hall i (u + k))
    · intro hall i v
      obtain ⟨σ, hσ⟩ := W.sliced_exists_history tt i 0
      have := hall σ v
      rwa [(W.sliced_plusTruthAt_iff_mem hloc hful hbf tt χ' (closureOf_box hψc) σ i 0 hσ v),
        add_zero] at this
  · intro χ hχ
    exact absurd hχ (sliced_not_stab_mem φ χ)

end WitnessFamily

end FormalSystem.Metalogic.Decidability
