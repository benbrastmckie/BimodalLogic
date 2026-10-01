/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Embed
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.HalfRun
import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Family

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

- `WitnessFamily.sliced_history_const` — every history of the embedded frame has a constant index -
  `WitnessFamily.sliced_exists_history` — and every index-and-offset pair is realized by one -
  `WitnessFamily.sliced_plusTruthAt_iff_mem` — the truth lemma: truth along a history with index
  `j` and offset `k` is membership in lasso `j`'s label at the shifted time -
  `WitnessFamily.sliced_canAt_iff_mem` — the canonical membership predicate, likewise -
  `WitnessFamily.sliced_target_lab_eq_canLab` — hypothesis `hcan` of the completeness headline -
  `WitnessFamily.sliced_slabTrue` — hypothesis `hst`, both clauses -
  `WitnessFamily.SnceProbe.snceProbeFamily_not_tailStableBackRaw` and the `Live` mirror — the
  **raw** backward conjunct is **refuted** at a certifying embedded certificate, at the single
  residue `r = 0` - `WitnessFamily.SnceProbe.snceProbeFamily_tailStable` and the `Live` mirror —
  the **landed** `TailStable`, whose backward conjunct carries `Stable.lean`'s `bwdLiveAt` filter
  from sub-phase 20.4, **holds** at both of those certificates and at both of sub-phase 20.1's -
  `PlusSlicedCertificate.TailStableBackRaw` / `TailStableBack` — the two backward demands isolated
  side by side, with `tailStableBack_of_raw` between them

## What is NOT here, and why

The flagship `exists_plusSlicedCertificate_of_not_plusValidZTime_ofFormula` is **not** here yet. Its
route through `Complete.lean`'s headline needs `(W.sliced tt).TailStable` for an **arbitrary**
certifying `W`, and what this module carries is seven certificates' worth of favourable verdicts.
Seven certificates are evidence, not a theorem, and nothing below is stated more strongly than it is
measured. The obstruction that blocked this route — the **raw** backward conjunct's refutation — is
recorded as kernel-checked theorems and is discharged by sub-phase 20.4's filter rather than worked
around; no `sorry` and no weakened statement stands in for it.

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

/-! ## The two conjuncts of `TailStable`, isolated, and the raw backward demand beside them

A refutation wants to name one conjunct rather than the conjunction, so each is isolated below. The
backward one carries its liveness filter — the mirror repair landed in `Stable.lean` at sub-phase
20.4 as `bwdLiveAt`, no longer a candidate in this module — and `TailStableBackRaw` is the
pre-repair demand, kept so that the refutation this module records keeps naming exactly what it
refutes.
-/

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-- **The RAW backward conjunct, isolated**, so that the refutation below can name what it refutes.
The `r = 0` instance is `Φ_back L₀ = L₀` verbatim. This is the pre-repair demand: `TailStable`'s own
backward conjunct carries the liveness filter and is `TailStableBack`. -/
def TailStableBackRaw (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ r ∈ Finset.range G.NBnat,
    G.iterBack (-G.NB - (r : ℤ)) (G.liveAt (-G.NB - (r : ℤ))) G.NBnat
      = G.liveAt (-G.NB - (r : ℤ))

instance decidableTailStableBackRaw (G : PlusSlicedCertificate Γ Del) :
    Decidable G.TailStableBackRaw :=
  inferInstanceAs (Decidable (∀ r ∈ Finset.range G.NBnat,
    G.iterBack (-G.NB - (r : ℤ)) (G.liveAt (-G.NB - (r : ℤ))) G.NBnat
      = G.liveAt (-G.NB - (r : ℤ))))

/-- **The landed backward conjunct, isolated**: the filtered one, as `TailStable` carries it. -/
def TailStableBack (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ r ∈ Finset.range G.NBnat,
    G.iterBack (-G.NB - (r : ℤ)) (G.liveAt (-G.NB - (r : ℤ))) G.NBnat
      ∩ G.bwdLiveAt (-G.NB - (r : ℤ)) = G.liveAt (-G.NB - (r : ℤ))

instance decidableTailStableBack (G : PlusSlicedCertificate Γ Del) :
    Decidable G.TailStableBack :=
  inferInstanceAs (Decidable (∀ r ∈ Finset.range G.NBnat,
    G.iterBack (-G.NB - (r : ℤ)) (G.liveAt (-G.NB - (r : ℤ))) G.NBnat
      ∩ G.bwdLiveAt (-G.NB - (r : ℤ)) = G.liveAt (-G.NB - (r : ℤ))))

/-- **The filtered backward demand is weaker than the raw one.** The mirror of
`Stable.tailStable_of_raw`'s backward component, isolated here beside the two conjuncts it compares.
The converse fails: `snceProbeFamily_not_tailStableBackRaw` together with
`snceProbeFamily_tailStableBack`. -/
theorem tailStableBack_of_raw (G : PlusSlicedCertificate Γ Del) (h : G.TailStableBackRaw) :
    G.TailStableBack := by
  intro r hr
  rw [h r hr]
  exact Finset.ext fun p =>
    ⟨fun hp => (Finset.mem_inter.mp hp).1,
      fun hp => Finset.mem_inter.mpr ⟨hp, G.liveAt_subset_bwdLiveAt _ hp⟩⟩

/-- **The landed forward conjunct, isolated**, the mirror of `TailStableBack`. -/
def TailStableFwd (G : PlusSlicedCertificate Γ Del) : Prop :=
  ∀ r ∈ Finset.range G.NFnat,
    G.iterFwd (G.NM + G.NF + (r : ℤ)) (G.liveAt (G.NM + G.NF + (r : ℤ))) G.NFnat
      ∩ G.fwdLiveAt (G.NM + G.NF + (r : ℤ)) = G.liveAt (G.NM + G.NF + (r : ℤ))

instance decidableTailStableFwd (G : PlusSlicedCertificate Γ Del) : Decidable G.TailStableFwd :=
  inferInstanceAs (Decidable (∀ r ∈ Finset.range G.NFnat,
    G.iterFwd (G.NM + G.NF + (r : ℤ)) (G.liveAt (G.NM + G.NF + (r : ℤ))) G.NFnat
      ∩ G.fwdLiveAt (G.NM + G.NF + (r : ℤ)) = G.liveAt (G.NM + G.NF + (r : ℤ))))

/-- **The two isolated conjuncts are `TailStable`.** Definitional, so a refutation of either is a
refutation of the demand. -/
theorem tailStable_iff_conjuncts (G : PlusSlicedCertificate Γ Del) :
    G.TailStable ↔ (G.TailStableBack ∧ G.TailStableFwd) := Iff.rfl

end PlusSlicedCertificate

/-! ## The RAW backward conjunct is REFUTED at the embedding, and the filter is what repairs it

Sub-phase 20.1 evaluated `TailStable` at two embedded certificates and found it **true**, and
recorded explicitly that two certificates are not a general argument. Both of those certificates
carry an `untl` closure and no `snce` at all. That was the gap: at the time, the two conjuncts of
`TailStable` were **not** symmetric — the forward one filtered by the computed forward-live set (the
repair landed at sub-phase 16.3) and the backward one did not — so an obstruction living in the
`snce` direction was invisible to an `untl`-only probe.

**The standing probe-shape rule this cost two dispatches to learn.** Any future evaluation of a
`TailStable`-like demand must carry **both** an `untl` and a `snce` in its closure. A one-sided
probe measures one conjunct and reports on both.

**What the verdicts below now say.** The raw backward demand `TailStableBackRaw` is refuted at a
certifying embedded certificate, at two independent families; the **filtered** `TailStableBack`
holds at both, and at both of 20.1's certificates too. That is the measured case for the repair
landed at sub-phase 20.4, and it is recorded here rather than argued.

**The mechanism, stated before the witnesses.** `Position.lean`'s `snceClauseAt` constrains the
**later** label from the earlier one: `snce g e ∈ Y ↔ e ∈ X ∨ (g ∈ X ∧ snce g e ∈ X)`. So a label
carrying a `snce` obligation constrains its *predecessors* and leaves its *successors* free, and
`LabCoherent` constrains no eventuality at all. Hence a position whose label carries a `snce`
obligation that no admissible predecessor can discharge is a legitimate member of `posAt` with an
empty `predP` — not backward-live, therefore not live — while its `succP` is non-empty, because
dropping the obligation rightward is always permitted. `Stable.lean`'s `stepBack` is a
`succP`-**preimage**, so that position is in `iterBack`, and the backward conjunct, having no
filter, demands it be live. It is not.

This is the exact mirror of `FixtureStable.lean`'s obstruction to the raw forward demand, and the
mirror filter removes the mirror witness exactly as `Fixture.not_mem_R₀fwd_pR` records for the
forward one. `Bridge.lean`'s `bwdVertFold` / `mem_bwdLiveT_of_bwdLive_fold` is what makes that
filter **sound** and not merely decidable, and `Stable.lean`'s `mem_L₀bwd_of_bwdLive_tail` is where
it carries genuine backward liveness down the left tail to the reference time.

**What is claimed and what is not.** What is claimed: `(W.sliced tt).TailStableBackRaw` does
**not** follow from `W.Certifies tt`, and the counterexample family meets every output condition of
`WitnessFamily.exists_witnessFamily_of_not_validZTime` besides the invalidity of its own target —
so the **raw** backward demand is not available from that theorem's stated output along this route.
What is **not** claimed: that the filtered `TailStableBack` fails anywhere (it is measured clean at
all four certificates below, which is why it is the landed conjunct), that the filtered demand is a
*theorem* (`FixtureStable.Φ_back_L₀_inter_ne_cert` refutes it at a named certificate, a `⊇` failure
no filter repairs), or that `snce p q` is ℤ-time invalid, which is evident but is not mechanized
here.
-/

namespace WitnessFamily

namespace SnceProbe

open FormalSystem.Syntax

/-- The guard atom of the `snce` probe. -/
def snceProbeAtomG : Atom := Atom.mkBase "g"

/-- The event atom of the `snce` probe. -/
def snceProbeAtomE : Atom := Atom.mkBase "e"

/-- The guard of the probe obligation. -/
def snceProbeGuard : Formula := Formula.atom snceProbeAtomG

/-- The event of the probe obligation. -/
def snceProbeEvent : Formula := Formula.atom snceProbeAtomE

/-- The smallest target whose closure carries a `snce` obligation at all: the exact mirror of
`Embedded.evTarget`. -/
def snceProbeTarget : Formula := Formula.snce snceProbeGuard snceProbeEvent

theorem snceProbeTarget_mem :
    snceProbeTarget ∈ closureOf (([] : Context) ++ [snceProbeTarget]) :=
  self_mem_closureOf (by simp)

theorem snceProbeEvent_mem :
    snceProbeEvent ∈ closureOf (([] : Context) ++ [snceProbeTarget]) :=
  closureOf_snce_left snceProbeTarget_mem

/-- The empty-labelled lasso over the `snce` target: locally coherent, vacuously fulfilling, and
refuting the target everywhere. -/
def snceProbeLasso : LabelledLasso (closureOf (([] : Context) ++ [snceProbeTarget])) where
  back := [∅]
  mid := []
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    have hE : X = ∅ := by
      rcases List.mem_append.mp hX with h | h
      · rcases List.mem_append.mp h with h | h
        · exact List.mem_singleton.mp h
        · simp at h
      · exact List.mem_singleton.mp h
    subst hE
    exact Finset.empty_subset _

/-- The one-lasso family over `snceProbeLasso`. -/
def snceProbeFamily : WitnessFamily ([] : Context) [snceProbeTarget] where
  bx := fun _ => false
  lassos := [snceProbeLasso]
  lassos_ne := by simp

/-- **The family certifies**, so the refutation below is at a genuine member of the class the
embedding consumes and not at an arbitrary structure. -/
theorem snceProbeFamily_certifies : snceProbeFamily.Certifies 0 := by decide

/-- **THE REFUTATION.** The embedded certificate of a certifying family fails the **raw** backward
demand, and `NBnat = 1` here, so the single residue it quantifies over is `r = 0` — the pre-residue
demand `Φ_back L₀ = L₀` itself, not an artifact of the residue indexing landed at sub-phase 18.3. -/
theorem snceProbeFamily_not_tailStableBackRaw :
    ¬ (snceProbeFamily.sliced 0).TailStableBackRaw := by decide

/-- **The forward conjunct holds** at the same certificate: the raw failure is one-sided, and it is
on the side that carried no liveness filter when the refutation was found. -/
theorem snceProbeFamily_tailStableFwd : (snceProbeFamily.sliced 0).TailStableFwd := by decide

/-- **The residue count is one**, so `r = 0` is the whole of the backward demand here. -/
theorem snceProbeFamily_nBnat : (snceProbeFamily.sliced 0).NBnat = 1 := by decide

/-- **The filter repairs it.** The landed, filtered backward conjunct holds at the very certificate
that refutes the raw one — the measured case for sub-phase 20.4's repair, at this certificate. -/
theorem snceProbeFamily_tailStableBack : (snceProbeFamily.sliced 0).TailStableBack := by decide

/-- **And therefore the whole landed demand holds here.** The refutation that blocked Phase 20 is
discharged by the repair rather than worked around: this certificate is now tail-stable. -/
theorem snceProbeFamily_tailStable : (snceProbeFamily.sliced 0).TailStable := by decide

/-! ### The same refutation at a family that genuinely carries and discharges the obligation

The empty-labelled family above tests the demand against an empty closure, which sub-phase 20.1
rightly treated as the weaker of two probe shapes. This one is the mirror of `Embedded.liveFamily`:
the event at time `0`, the obligation at time `1`, `perM = 2`, twelve timed vertices, and the
obligation genuinely discharged inside the lasso. The verdict is the same, so the refutation is
structural rather than an artifact of empty labels.
-/

/-- `e` at time `0`, `e S g` at time `1`, empty elsewhere. -/
def snceProbeLiveLasso : LabelledLasso (closureOf (([] : Context) ++ [snceProbeTarget])) where
  back := [∅]
  mid := [{snceProbeEvent}, {snceProbeTarget}]
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    have hE : X = ∅ ∨ X = {snceProbeEvent} ∨ X = {snceProbeTarget} := by
      rcases List.mem_append.mp hX with h | h
      · rcases List.mem_append.mp h with h | h
        · exact Or.inl (List.mem_singleton.mp h)
        · rcases List.mem_cons.mp h with rfl | h
          · exact Or.inr (Or.inl rfl)
          · exact Or.inr (Or.inr (List.mem_singleton.mp h))
      · exact Or.inl (List.mem_singleton.mp h)
    rcases hE with rfl | rfl | rfl
    · exact Finset.empty_subset _
    · exact Finset.singleton_subset_iff.mpr snceProbeEvent_mem
    · exact Finset.singleton_subset_iff.mpr snceProbeTarget_mem

/-- The one-lasso family over `snceProbeLiveLasso`. -/
def snceProbeLiveFamily : WitnessFamily ([] : Context) [snceProbeTarget] where
  bx := fun _ => false
  lassos := [snceProbeLiveLasso]
  lassos_ne := by simp

theorem snceProbeLiveFamily_certifies : snceProbeLiveFamily.Certifies 0 := by decide

/-- **The refutation again**, at twelve timed vertices and with the obligation genuinely carried and
genuinely discharged. -/
theorem snceProbeLiveFamily_not_tailStableBackRaw :
    ¬ (snceProbeLiveFamily.sliced 0).TailStableBackRaw := by decide

theorem snceProbeLiveFamily_tailStableFwd : (snceProbeLiveFamily.sliced 0).TailStableFwd := by
  decide

/-- **The filter repairs this one too**, so the repair is not tuned to the smaller family. -/
theorem snceProbeLiveFamily_tailStableBack :
    (snceProbeLiveFamily.sliced 0).TailStableBack := by decide

theorem snceProbeLiveFamily_tailStable : (snceProbeLiveFamily.sliced 0).TailStable := by decide

/-! ### The filter does not regress the two certificates sub-phase 20.1 landed

Both of 20.1's `untl` certificates already satisfy the **unfiltered** backward conjunct, and the
filtered one is weaker, so neither verdict can change. Evaluated rather than argued, because the
point of a repair is that it is measured at every certificate the tree has.
-/

theorem emptyFamily_tailStableBack : (Embedded.emptyFamily.sliced 0).TailStableBack := by decide

theorem liveFamily_tailStableBack :
    (Embedded.liveFamily.sliced (-1)).TailStableBack := by decide

/-! ### The refuting family meets the compression theorem's own output specification

`WitnessFamily.exists_witnessFamily_of_not_validZTime` outputs a family together with four
conditions besides `Certifies`: per-lasso segment bounds, a lasso-count bound, a `bx` of the form
`fun χ => decide (χ ∈ S)` for some closure subset `S`, and a target time in `[0, compressionBound]`.
The refuting family satisfies all four. So the obstruction is not dodged by reading more of that
theorem's conclusion: the flagship's route has to repair the demand, strengthen the compression
theorem's output, or change route.
-/

theorem snceProbeFamily_segment_bounds : ∀ Λ ∈ snceProbeFamily.lassos,
    Λ.back.length ≤ compressionBound ([] : Context) [snceProbeTarget] ∧
    Λ.mid.length ≤ compressionBound ([] : Context) [snceProbeTarget] ∧
    Λ.fwd.length ≤ compressionBound ([] : Context) [snceProbeTarget] := by decide

theorem snceProbeFamily_lasso_count : snceProbeFamily.lassos.length
    ≤ (closureOf (([] : Context) ++ [snceProbeTarget])).card + 1 := by decide

theorem snceProbeFamily_bx_shape :
    snceProbeFamily.bx = fun χ => decide (χ ∈ (∅ : Finset Formula)) := by
  funext χ
  simp [snceProbeFamily]

theorem snceProbeFamily_target_time :
    (0 : ℤ) ≤ 0 ∧ (0 : ℤ) ≤ (compressionBound ([] : Context) [snceProbeTarget] : ℤ) := by decide

theorem snceProbeLiveFamily_segment_bounds : ∀ Λ ∈ snceProbeLiveFamily.lassos,
    Λ.back.length ≤ compressionBound ([] : Context) [snceProbeTarget] ∧
    Λ.mid.length ≤ compressionBound ([] : Context) [snceProbeTarget] ∧
    Λ.fwd.length ≤ compressionBound ([] : Context) [snceProbeTarget] := by decide

end SnceProbe

/-! ## The two `⊥`-targets: the smallest witness that each conjunct needs its filter

A permanent regression pair, and the thing whose absence let an earlier dispatch return a favourable
verdict from two `untl`-only certificates. `⊥ U ⊥` is the smallest target whose closure carries an
`untl` obligation that nothing can discharge, and `⊥ S ⊥` the smallest carrying an undischargeable
`snce` one — no atom is needed, because `⊥` is already the event that never happens. Each comes with
three things, so that each is a complete end-to-end witness rather than a bare `decide`:

1. its **ℤ-time non-validity**, so it is a genuine input to
   `WitnessFamily.exists_witnessFamily_of_not_validZTime` and not a formula chosen for convenience;
2. its family's **`Certifies` verdict**, so the certificate is a genuine member of the class the
   embedding consumes;
3. the **raw** demand failing in its own direction and the **filtered** demand holding.

Taken together, (3) is the measured statement that neither filter is decoration: drop the forward
one and `⊥ U ⊥` is rejected, drop the backward one and `⊥ S ⊥` is. They decide in milliseconds.

**The standing probe-shape rule.** Any future evaluation of a `TailStable`-like demand must carry
**both** an `untl` and a `snce` in its closure. A probe carrying only one measures one conjunct and
reports on both, which is exactly how the backward obstruction stayed hidden behind two favourable
`untl` verdicts.
-/

namespace BotTargets

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

/-! ### A ℤ-time frame to refute on

The permissive frame over `ℤ`: every function `ℤ → ℕ` is a total history. Both refutations below
need nothing of it beyond membership in the ℤ-time class, because `⊥` is false at every point of
every model.
-/

/-- The permissive ℤ-frame. -/
abbrev botFrame : TaskFrame := FrameOver.natFrame (D := ℤ)

/-- Any function `ℤ → ℕ` as a total history of `botFrame`. -/
def botHist (f : ℤ → ℕ) : WorldHistory botFrame :=
  WorldHistory.ofTotal botFrame f (fun s t => by
    refine (FrameOver.natFrame_rel_iff _ _ _).mpr ?_
    by_cases h : t - s = 0
    · right
      have : t = s := sub_eq_zero.mp h
      subst this; rfl
    · left; exact h)

/-- Every atom true at world state `0` and nowhere else; the valuation is irrelevant here. -/
def botModel : TaskModel botFrame where
  valuation := fun (n : ℕ) _ => n = 0

theorem botFrame_sat : FrameClass.ZTime.Sat botFrame :=
  ⟨inferInstance, TaskFrame.isZTime_of_instances _⟩

/-! ### `⊥ U ⊥`: the forward filter is load-bearing -/

/-- **The smallest target carrying an undischargeable `untl` obligation.** -/
def botUntl : Formula := Formula.untl Formula.bot Formula.bot

/-- **`⊥ U ⊥` is a genuine ℤ-time non-validity.** Its truth demands a later point where `⊥` holds,
and there is none in any model. -/
theorem not_validZTime_botUntl : ¬ ValidZTime botUntl := by
  intro h
  obtain ⟨s, -, hbot, -⟩ := h botFrame botFrame_sat botModel (botHist fun _ => 0) 0
  exact hbot

/-- The empty-labelled lasso over `⊥ U ⊥`. -/
def botUntlLasso : LabelledLasso (closureOf (([] : Context) ++ [botUntl])) where
  back := [∅]
  mid := []
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    have hE : X = ∅ := by
      rcases List.mem_append.mp hX with h | h
      · rcases List.mem_append.mp h with h | h
        · exact List.mem_singleton.mp h
        · simp at h
      · exact List.mem_singleton.mp h
    subst hE
    exact Finset.empty_subset _

/-- The one-lasso family over `botUntlLasso`. -/
def botUntlFamily : WitnessFamily ([] : Context) [botUntl] where
  bx := fun _ => false
  lassos := [botUntlLasso]
  lassos_ne := by simp

theorem botUntlFamily_certifies : botUntlFamily.Certifies 0 := by decide

/-- **The RAW demand fails**, by its forward conjunct: `⊥ U ⊥` sits in `posAt` at the right
endpoint, is reachable, and is forward-dead. -/
theorem botUntlFamily_not_tailStableRaw :
    ¬ (botUntlFamily.sliced 0).TailStableRaw := by decide

/-- **The filtered forward conjunct holds** at the same certificate: the filter removes the
reachable-but-forward-dead position rather than demanding it be live. -/
theorem botUntlFamily_tailStableFwd : (botUntlFamily.sliced 0).TailStableFwd := by decide

/-- **And so the landed demand holds.** -/
theorem botUntlFamily_tailStable : (botUntlFamily.sliced 0).TailStable := by decide

/-! ### `⊥ S ⊥`: the backward filter is load-bearing -/

/-- **The smallest target carrying an undischargeable `snce` obligation.** -/
def botSnce : Formula := Formula.snce Formula.bot Formula.bot

/-- **`⊥ S ⊥` is a genuine ℤ-time non-validity.** -/
theorem not_validZTime_botSnce : ¬ ValidZTime botSnce := by
  intro h
  obtain ⟨s, -, hbot, -⟩ := h botFrame botFrame_sat botModel (botHist fun _ => 0) 0
  exact hbot

/-- The empty-labelled lasso over `⊥ S ⊥`. -/
def botSnceLasso : LabelledLasso (closureOf (([] : Context) ++ [botSnce])) where
  back := [∅]
  mid := []
  fwd := [∅]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by
    intro X hX
    have hE : X = ∅ := by
      rcases List.mem_append.mp hX with h | h
      · rcases List.mem_append.mp h with h | h
        · exact List.mem_singleton.mp h
        · simp at h
      · exact List.mem_singleton.mp h
    subst hE
    exact Finset.empty_subset _

/-- The one-lasso family over `botSnceLasso`. -/
def botSnceFamily : WitnessFamily ([] : Context) [botSnce] where
  bx := fun _ => false
  lassos := [botSnceLasso]
  lassos_ne := by simp

theorem botSnceFamily_certifies : botSnceFamily.Certifies 0 := by decide

/-- **The RAW backward conjunct fails**: `⊥ S ⊥` sits in `posAt` at the left endpoint, is in
`iterBack` because `stepBack` is a `succP`-preimage, and is backward-dead. -/
theorem botSnceFamily_not_tailStableBackRaw :
    ¬ (botSnceFamily.sliced 0).TailStableBackRaw := by decide

/-- **The filtered backward conjunct holds** at the same certificate — the mirror of
`botUntlFamily_tailStableFwd`, and the smallest witness that sub-phase 20.4's filter is needed. -/
theorem botSnceFamily_tailStableBack : (botSnceFamily.sliced 0).TailStableBack := by decide

/-- **And so the landed demand holds.** -/
theorem botSnceFamily_tailStable : (botSnceFamily.sliced 0).TailStable := by decide

end BotTargets

/-! ## Towards `hTS` in general: every run of the embedded certificate has CONSTANT state

Sub-phase 20.5 owes `(W.sliced tt).TailStable` for an **arbitrary** certifying `W`, not a verdict at
finitely many certificates. The structural fact that route turns on is below, and it is landed here
rather than assumed: the embedded certificate's edge relation is the identity
(`sliced_edge : edge t i j = decide (i = j)`), so a run's `steps` field forces its state to be the
same at every time. A run of `W.sliced tt` is therefore exactly a **fixed lasso index** `w` together
with a labelling `ℤ → Finset PlusFormula` that agrees with `trLab (W.L w ·)` on the state formulas
at every time, is locally coherent, and is fulfilling.

**The period-invariance that obligation turned on is now a theorem, and the route is closed.** Fix
a left residue `r < W.perB` and write `t₀ = -NB - r`. The `⊇` half of the backward conjunct asks,
for each `p = (w, X) ∈ liveAt t₀`, that `p ∈ iterBack t₀ (liveAt t₀) NBnat` — a `succP`-chain of one
whole back period from `p` *placed at* `t₀ - NB` up to a member of `liveAt t₀`. An **arbitrary** run
through `p` does not supply it: reading the run one period to the left needs
`R.lab (t₀ - NB) = X`, and `LabRun.agrees` is demanded at every `s : ℤ`, including the non-negative
times where `trLab (W.L w ·)` is not `perB`-periodic, so a run cannot simply be shifted.

What closes it is that at the embedded certificate there is **no** arbitrary run through a live
position: `slicedCanon_mem_liveAt_iff` proves that a live position's label **is** the family's own
translated label `trLab (W.L w t)`, by `Canon.lean`'s rigidity (`exists_path_canLab_of_live`: a
run's labelling is the canonical labelling of its state path) together with the self-loop edge
relation below (every step path is constant) and `sliced_canAt_iff_mem` (the canonical label of a
constant path is the family's own). The family's label is `perB`-periodic on the negatives by
construction (`lab_sub_perB`), so the canonical run returns to its own position one whole period
down the tail (`famRun_pos_sub_mul_perB`) and `mem_iterBack_of_run` hands the transfer that run as
its chain. `slicedCanon_liveAt_subset_iterBack` and `slicedCanon_liveAt_subset_iterFwd` are the
two resulting `⊇` halves, at every residue and every number of periods.

**What is still owed is the `⊆` half of each conjunct**, and it is a different obstruction from the
one above rather than a remainder of it. With `liveAt = fwdLiveAt ∩ bwdLiveAt` (both are filters of
`posAt` by the two halves of `liveT`), the backward conjunct's `⊆` half reduces exactly to
`iterBack t₀ (liveAt t₀) NBnat ∩ bwdLiveAt t₀ ⊆ fwdLiveAt t₀`, and the forward one's to
`iterFwd t₁ (liveAt t₁) NFnat ∩ fwdLiveAt t₁ ⊆ bwdLiveAt t₁`. In each case the chain pins one
half of the arriving label and the filter must pin the other: down a `succP`-chain the one-step
`untl` clause determines the earlier label's `untl`-content from the later one, and up a chain the
`snce` clause determines the later label's `snce`-content from the earlier, so a chain from a
canonical endpoint leaves exactly the opposite half of the other endpoint free. Turning the
filter's **computed** membership into the **declarative** liveness that would pin that half is what
`Bridge.lean`'s `live_of_mem_liveT` does — and it consumes *both* halves of `liveT`, because
`FwdLive` and `BwdLive` each demand a bi-infinite run. The half-run the chain supplies is genuine
(for the forward conjunct: the canonical run below `t₁ - NF`, which is a window time at or past
`NM` because `t₁ - NF = NM + r`, followed by the chain re-timed down one period), so what is
missing is a **one-directional** computed-to-declarative bridge that accepts an explicit half-run
for the other direction. Nothing below is stated more strongly than it is proved, and no `sorry`
and no weakened `TailStable` stands in for that gap.
-/

namespace Embedded

variable {φ : Formula}

/--
**Every run of the embedded certificate has constant state.**

Immediate from `sliced_edge`: the edge relation is `decide (i = j)`, so `LabRun.steps` reads
`R.st s = R.st (s + 1)` at every `s`, and the two-sided induction closes it. This is what makes a
run of `W.sliced tt` a *labelling at a fixed lasso index* rather than a wandering path, and it is
the first input of the general `hTS` argument sub-phase 20.5 owes.
-/
theorem sliced_run_st_const (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ)
    (R : (W.sliced tt).LabRun) (s t : ℤ) : R.st s = R.st t := by
  have hstep : ∀ u : ℤ, R.st u = R.st (u + 1) := by
    intro u
    have h := R.steps u
    rw [W.sliced_edge tt u (R.st u) (R.st (u + 1))] at h
    exact of_decide_eq_true h
  have hup : ∀ (a : ℤ) (k : ℕ), R.st a = R.st (a + (k : ℤ)) := by
    intro a k
    induction k with
    | zero => rw [Nat.cast_zero, add_zero]
    | succ j ih =>
        rw [show a + ((j + 1 : ℕ) : ℤ) = (a + (j : ℤ)) + 1 from by push_cast; omega]
        exact ih.trans (hstep _)
  rcases le_total s t with h | h
  · obtain ⟨k, hk⟩ : ∃ k : ℕ, t = s + (k : ℤ) := ⟨(t - s).toNat, by omega⟩
    rw [hk]; exact hup s k
  · obtain ⟨k, hk⟩ : ∃ k : ℕ, s = t + (k : ℤ) := ⟨(s - t).toNat, by omega⟩
    rw [hk]; exact (hup t k).symm

/-- **A run's position is determined by its label**, once the state is known to be constant: the
state component never moves off the index the run starts at. -/
theorem sliced_run_pos_fst (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ)
    (R : (W.sliced tt).LabRun) (t : ℤ) : (R.pos t).1 = R.st 0 :=
  sliced_run_st_const W tt R t 0

end Embedded


end WitnessFamily

namespace WitnessFamily

variable {φ : Formula}

/-! ## Iterated periodicity of a family's labels

`lab_sub_perB` / `lab_add_perF` are the one-period steps. Both tails of the tail-stability demand
are read one whole period away from the reference time, and the generic form used below is
`k` periods away, so each is iterated once and for all.
-/

/-- **Leftward periodicity, iterated.** Every intermediate time is negative, which is what each
step of the induction consumes. -/
theorem lab_sub_mul_perB {Γ Del : Context} (W : WitnessFamily Γ Del)
    (i : Fin W.lassos.length) {t : ℤ} (ht : t < 0) (k : ℕ) :
    W.L i (t - (k : ℤ) * (W.perB : ℤ)) = W.L i t := by
  have hB : (0 : ℤ) < (W.perB : ℤ) := by exact_mod_cast W.perB_pos
  induction k with
  | zero => simp
  | succ k ih =>
    have hknn : (0 : ℤ) ≤ (k : ℤ) * (W.perB : ℤ) :=
      mul_nonneg (Int.natCast_nonneg k) (le_of_lt hB)
    have hstep : t - ((k + 1 : ℕ) : ℤ) * (W.perB : ℤ)
        = (t - (k : ℤ) * (W.perB : ℤ)) - (W.perB : ℤ) := by push_cast; ring
    rw [hstep, W.lab_sub_perB i (show t - (k : ℤ) * (W.perB : ℤ) < 0 from by omega), ih]

/-- **Rightward periodicity, iterated.** Every intermediate time is at or past `perM`. -/
theorem lab_add_mul_perF {Γ Del : Context} (W : WitnessFamily Γ Del)
    (i : Fin W.lassos.length) {t : ℤ} (ht : (W.perM : ℤ) ≤ t) (k : ℕ) :
    W.L i (t + (k : ℤ) * (W.perF : ℤ)) = W.L i t := by
  have hF : (0 : ℤ) < (W.perF : ℤ) := by exact_mod_cast W.perF_pos
  induction k with
  | zero => simp
  | succ k ih =>
    have hknn : (0 : ℤ) ≤ (k : ℤ) * (W.perF : ℤ) :=
      mul_nonneg (Int.natCast_nonneg k) (le_of_lt hF)
    have hstep : t + ((k + 1 : ℕ) : ℤ) * (W.perF : ℤ)
        = (t + (k : ℤ) * (W.perF : ℤ)) + (W.perF : ℤ) := by push_cast; ring
    rw [hstep, W.lab_add_perF i (show (W.perM : ℤ) ≤ t + (k : ℤ) * (W.perF : ℤ) from by omega), ih]

/-! ## The embedded certificate under the canonical box guess

`Embed.lean` leaves the box guess at the constant `false`, because `Complete.lean`'s headline
re-chooses it. That choice is harmless for everything `Embed.lean` reads — `posAt`, `succP`,
`liveT` and hence `TailStable` never mention `bx` — but it is **not** harmless for runs: a
`LabRun`'s own `□` clause is read against `G.bx`, so under the constant `false` guess a family whose
labels carry a `□`-formula has no runs at all. Every declarative statement below is therefore made
at the certificate `Complete.lean` itself installs, and transported back across `withBx` at the end
by `withBx_tailStable`.
-/

/-- **The embedded certificate with the canonical box guess** — the one `Complete.lean`'s headline
installs, and the only one under which the embedded certificate's runs are the family's own
lassos. -/
@[reducible] def slicedCanon (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    PlusSlicedCertificate ([] : PlusContext) [ofFormula φ] :=
  (W.sliced tt).withBx (W.sliced tt).canonBx

/-- **(C3b) holds at the canonical box guess.** `Complete.lean`'s own route, read at the embedded
certificate: `sliced_slabTrue` is landed, and `canonBx` is by definition the `□`-content of one
slice at one state. -/
theorem slicedCanon_boxLabelFaithful (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ) :
    (W.slicedCanon tt).BoxLabelFaithful :=
  PlusSlicedCertificate.boxLabelFaithful_of_slabTrue _ (W.sliced_biSerial tt)
    (W.sliced_slabTrue hloc hful hbf tt) (fun χ _ => (W.sliced tt).canonBx_eq_true χ)

/-- **Every self-loop of the embedded certificate is an edge.** -/
theorem slicedCanon_edge_self (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ)
    (j : Fin (W.slicedCanon tt).n) (t : ℤ) : (W.slicedCanon tt).edge t j j = true := by
  rw [show (W.slicedCanon tt).edge t j j = (W.sliced tt).edge t j j from rfl,
    W.sliced_edge tt t j j]
  exact decide_eq_true rfl

/--
**The canonical label of a constant index is the translated lasso label.**

The generic form of `sliced_target_lab_eq_canLab`'s key step: there the index is the main lasso's
and the path is the target path's, here both are arbitrary. `sliced_canAt_iff_mem` does the work and
is consumed unchanged.
-/
theorem sliced_canLab_const (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (tt : ℤ)
    (g : ℤ → Fin (W.sliced tt).n) (j : Fin (W.sliced tt).n) (hgc : ∀ u : ℤ, g u = j) (t : ℤ) :
    (W.sliced tt).canLab g t = trLab (W.L j t) := by
  have hkey := W.sliced_canAt_iff_mem hloc hful tt g j hgc
  ext ψ
  rw [(W.sliced tt).mem_canLab]
  constructor
  · rintro ⟨hmem, hcan⟩
    obtain ⟨χ, rfl, hχc⟩ := exists_ofFormula_of_mem_plusClosureOf_ofCtx
      (S := ([] : Context) ++ [φ]) hmem
    exact mem_trLab.mpr ((hkey χ hχc t).mp hcan)
  · intro hψ
    rw [trLab, Finset.mem_image] at hψ
    obtain ⟨χ, hχ, rfl⟩ := hψ
    have hχc : χ ∈ closureOf (([] : Context) ++ [φ]) := W.subset_closureOf j t hχ
    exact ⟨mem_plusClosureOf_ofCtx.mpr hχc, (hkey χ hχc t).mpr hχ⟩

/-- **Every step path of the embedded certificate has a constant index.** The label-level mirror of
`sliced_history_const`, from the self-loop edge relation. -/
theorem slicedCanon_path_const (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ)
    {g : ℤ → Fin (W.slicedCanon tt).n}
    (hg : ∀ s : ℤ, (W.slicedCanon tt).edge s (g s) (g (s + 1)) = true) (u v : ℤ) :
    g u = g v := by
  have hstep : ∀ s : ℤ, g s = g (s + 1) := by
    intro s
    have h := hg s
    rw [show (W.slicedCanon tt).edge s (g s) (g (s + 1))
        = (W.sliced tt).edge s (g s) (g (s + 1)) from rfl,
      W.sliced_edge tt s (g s) (g (s + 1))] at h
    exact of_decide_eq_true h
  rw [Periodic.const_of_step_eq hstep u, Periodic.const_of_step_eq hstep v]

/-! ### The family's own lassos are the embedded certificate's runs -/

/--
**The canonical run at a lasso index.**

The constant-index step path, with the canonical labelling `Canon.lean` attaches to it. By
`famRun_lab` that labelling *is* the family's own translated label sequence, so this run is not a
new object: it is lasso `j`, read as a run of the embedded certificate.
-/
noncomputable def famRun (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ)
    (j : Fin (W.slicedCanon tt).n) : (W.slicedCanon tt).LabRun :=
  (W.slicedCanon tt).canRun (W.slicedCanon_boxLabelFaithful hloc hful hbf tt) (fun _ => j)
    (fun t => W.slicedCanon_edge_self tt j t)

/-- **The canonical run's label is the family's own translated label.** -/
theorem famRun_lab (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ)
    (j : Fin (W.slicedCanon tt).n) (t : ℤ) :
    (W.famRun hloc hful hbf tt j).lab t = trLab (W.L j t) := by
  rw [famRun, PlusSlicedCertificate.canRun_lab, PlusSlicedCertificate.withBx_canLab,
    W.sliced_canLab_const hloc hful tt (fun _ => j) j (fun _ => rfl) t]

/-- **The canonical run's state never moves.** -/
@[simp] theorem famRun_st (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ)
    (j : Fin (W.slicedCanon tt).n) (t : ℤ) : (W.famRun hloc hful hbf tt j).st t = j := rfl

/-- **The canonical run is fulfilling in both directions.** -/
theorem famRun_fulfilling (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ)
    (j : Fin (W.slicedCanon tt).n) :
    PlusFulfillingSeqLab (W.famRun hloc hful hbf tt j).lab :=
  (W.slicedCanon tt).canRun_fulfilling _ _ _

/-- **A position whose label is the translated lasso label is the canonical run's position.** -/
theorem famRun_pos_eq (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ)
    (p : (W.slicedCanon tt).Pos) (t : ℤ)
    (hcan : (p.2.1 : Finset PlusFormula) = trLab (W.L p.1 t)) :
    (W.famRun hloc hful hbf tt p.1).pos t = p :=
  Prod.ext rfl (Subtype.ext (by rw [show ((W.famRun hloc hful hbf tt p.1).pos t).2.1
      = (W.famRun hloc hful hbf tt p.1).lab t from rfl, W.famRun_lab, hcan]))

/--
**The live positions of the embedded certificate are exactly the canonical ones.**

`→` is `Canon.lean`'s rigidity (`exists_path_canLab_of_live`) plus the self-loop edge relation: a
live position's label is the canonical label of a step path through its state, every step path is
constant, and the canonical label of a constant path is the family's own. `←` is the canonical run
itself.

This is the structural fact the whole of `hTS` turns on, and the one that makes the embedded
certificate's live sets **periodic** where a general certificate's are not: `canLab` is not
`perB`-periodic on the negatives for an arbitrary certificate, because its `U` clause looks into the
non-periodic middle, but here it coincides with a label sequence that is periodic by construction.
-/
theorem slicedCanon_mem_liveAt_iff (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ) {t : ℤ}
    (ht : t ∈ (W.slicedCanon tt).winTimes) (p : (W.slicedCanon tt).Pos) :
    p ∈ (W.slicedCanon tt).liveAt t ↔ (p.2.1 : Finset PlusFormula) = trLab (W.L p.1 t) := by
  have hbox := W.slicedCanon_boxLabelFaithful hloc hful hbf tt
  constructor
  · intro hp
    obtain ⟨g, hg, h1, h2⟩ := (W.slicedCanon tt).exists_path_canLab_of_live
      ((W.slicedCanon tt).live_of_mem_liveAt hbox ht hp)
    have hgc : ∀ u : ℤ, g u = p.1 := by
      intro u
      rw [W.slicedCanon_path_const tt hg u t, ← h1]
    rw [h2, PlusSlicedCertificate.withBx_canLab,
      W.sliced_canLab_const hloc hful tt g p.1 hgc t]
  · intro hcan
    have hlive := (W.slicedCanon tt).live_canRun hbox (fun _ => p.1)
      (fun t => W.slicedCanon_edge_self tt p.1 t) t
    rw [show (W.slicedCanon tt).canRun hbox (fun _ => p.1)
        (fun t => W.slicedCanon_edge_self tt p.1 t) = W.famRun hloc hful hbf tt p.1 from rfl,
      W.famRun_pos_eq hloc hful hbf tt p t hcan] at hlive
    exact (W.slicedCanon tt).mem_liveAt_of_live ht hlive

/-! ## The `⊇` halves of both tail-stability conjuncts

At a reference time inside a periodic tail the canonical run *returns to its own position* one whole
period away — `famRun_lab` makes its label the family's, and the family's label is periodic there by
construction. `mem_iterBack_of_run` then hands the transfer the run itself as the chain it asks for.
No filter is involved in either statement: the `⊇` half of each filtered conjunct is the inclusion
into the iterate together with `liveAt_subset_bwdLiveAt` / `liveAt_subset_fwdLiveAt`, which are
free.
-/

/-- **The canonical run returns to its own position one whole period down the left tail.** -/
theorem famRun_pos_sub_mul_perB (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ)
    (j : Fin (W.slicedCanon tt).n) {t : ℤ} (ht : t < 0) (k : ℕ) :
    (W.famRun hloc hful hbf tt j).pos (t - (k : ℤ) * (W.perB : ℤ))
      = (W.famRun hloc hful hbf tt j).pos t :=
  Prod.ext rfl (Subtype.ext (by
    rw [show ((W.famRun hloc hful hbf tt j).pos (t - (k : ℤ) * (W.perB : ℤ))).2.1
        = (W.famRun hloc hful hbf tt j).lab (t - (k : ℤ) * (W.perB : ℤ)) from rfl,
      show ((W.famRun hloc hful hbf tt j).pos t).2.1
        = (W.famRun hloc hful hbf tt j).lab t from rfl,
      W.famRun_lab, W.famRun_lab, W.lab_sub_mul_perB j ht k]))

/-- **The mirror, down the right tail.** -/
theorem famRun_pos_add_mul_perF (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ)
    (j : Fin (W.slicedCanon tt).n) {t : ℤ} (ht : (W.perM : ℤ) ≤ t) (k : ℕ) :
    (W.famRun hloc hful hbf tt j).pos (t + (k : ℤ) * (W.perF : ℤ))
      = (W.famRun hloc hful hbf tt j).pos t :=
  Prod.ext rfl (Subtype.ext (by
    rw [show ((W.famRun hloc hful hbf tt j).pos (t + (k : ℤ) * (W.perF : ℤ))).2.1
        = (W.famRun hloc hful hbf tt j).lab (t + (k : ℤ) * (W.perF : ℤ)) from rfl,
      show ((W.famRun hloc hful hbf tt j).pos t).2.1
        = (W.famRun hloc hful hbf tt j).lab t from rfl,
      W.famRun_lab, W.famRun_lab, W.lab_add_mul_perF j ht k]))

/-- **`NBnat` of the embedded certificate is the family's back period.** -/
theorem slicedCanon_NBnat (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.slicedCanon tt).NBnat = W.perB := W.sliced_NBnat tt

/-- **`NFnat` of the embedded certificate is the family's forward period.** -/
theorem slicedCanon_NFnat (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.slicedCanon tt).NFnat = W.perF := W.sliced_NFnat tt

/-- **`NM` of the embedded certificate is the family's middle length.** -/
theorem slicedCanon_NM (W : WitnessFamily ([] : Context) [φ]) (tt : ℤ) :
    (W.slicedCanon tt).NM = (W.perM : ℤ) := W.sliced_NM tt

/--
**The `⊇` half of the backward conjunct, at every negative window reference time and every number
of periods.**

This is exactly the `hstab` that `live_of_mem_liveAt_tail` consumes, and it is the half the
**filtered** backward demand keeps — see `liveAt_refBack_subset_iterBack` for the shape the demand
itself supplies it in.
-/
theorem slicedCanon_liveAt_subset_iterBack (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ) {t₀ : ℤ}
    (ht₀ : t₀ < 0) (hwin : t₀ ∈ (W.slicedCanon tt).winTimes) (k : ℕ) :
    (W.slicedCanon tt).liveAt t₀
      ⊆ (W.slicedCanon tt).iterBack t₀ ((W.slicedCanon tt).liveAt t₀)
          (k * (W.slicedCanon tt).NBnat) := by
  intro p hp
  have hcan := (W.slicedCanon_mem_liveAt_iff hloc hful hbf tt hwin p).mp hp
  have hpR : (W.famRun hloc hful hbf tt p.1).pos t₀ = p :=
    W.famRun_pos_eq hloc hful hbf tt p t₀ hcan
  have h := (W.slicedCanon tt).mem_iterBack_of_run (W.famRun hloc hful hbf tt p.1) t₀
    (by rw [hpR]; exact hp) (k * (W.slicedCanon tt).NBnat)
  have hmc : ((k * (W.slicedCanon tt).NBnat : ℕ) : ℤ) = (k : ℤ) * (W.perB : ℤ) := by
    rw [W.slicedCanon_NBnat tt, Nat.cast_mul]
  rw [hmc, W.famRun_pos_sub_mul_perB hloc hful hbf tt p.1 ht₀ k, hpR] at h
  exact h

/-- **The mirror, on the right tail.** The reference time is at or past `NM`, which is what the
rightward periodicity of the family's labels asks for. -/
theorem slicedCanon_liveAt_subset_iterFwd (W : WitnessFamily ([] : Context) [φ])
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbf : W.BoxFaithful) (tt : ℤ) {t₁ : ℤ}
    (ht₁ : (W.perM : ℤ) ≤ t₁) (hwin : t₁ ∈ (W.slicedCanon tt).winTimes) (k : ℕ) :
    (W.slicedCanon tt).liveAt t₁
      ⊆ (W.slicedCanon tt).iterFwd t₁ ((W.slicedCanon tt).liveAt t₁)
          (k * (W.slicedCanon tt).NFnat) := by
  intro p hp
  have hcan := (W.slicedCanon_mem_liveAt_iff hloc hful hbf tt hwin p).mp hp
  have hpR : (W.famRun hloc hful hbf tt p.1).pos t₁ = p :=
    W.famRun_pos_eq hloc hful hbf tt p t₁ hcan
  have h := (W.slicedCanon tt).mem_iterFwd_of_run (W.famRun hloc hful hbf tt p.1) t₁
    (by rw [hpR]; exact hp) (k * (W.slicedCanon tt).NFnat)
  have hmc : ((k * (W.slicedCanon tt).NFnat : ℕ) : ℤ) = (k : ℤ) * (W.perF : ℤ) := by
    rw [W.slicedCanon_NFnat tt, Nat.cast_mul]
  rw [hmc, W.famRun_pos_add_mul_perF hloc hful hbf tt p.1 ht₁ k, hpR] at h
  exact h

end WitnessFamily

end FormalSystem.Metalogic.Decidability
