/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Tail
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Canon
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Check
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Agreement
import FormalSystem.Metalogic.Decidability.PlusWitnessFamily.Compression.Types

/-!
# Soundness of the Time-Sliced L⁺ Certificate

The truth lemma for the sliced certificate, and the refutation interface it lands: an accepted
`PlusSlicedCertificate` yields `PlusWitnessFamily.PlusRefutes Γ Del`, the **same** interface the
landed `PlusSharingWitnessFamily.plusRefutes_of_certifies` lands.

## This declaration is *beside* the landed one, not in place of it

`PlusSharingWitnessFamily.plusRefutes_of_certifies` is sound and stays, with its statement
unchanged. The two theorems are about **different certificate classes** — one carries a finite
family of shared indices, the other a time-sliced graph presenting a frame on an infinite carrier —
and they land the same conclusion because `PlusRefutes` is a statement about ℤ-time models and not
about certificates. Neither subsumes the other: the sliced class certifies ℤ-time non-validities the
sharing class provably cannot (`PlusWitnessFamily/Limits/NoCertificate.lean`), and the sharing class
is the cheaper object wherever it applies.

**Why the presented carrier is infinite, and why that is required.** `G.frame h` is
`FrameOver.ofSlicedStep` on `ℤ × Fin G.n`, whose carrier `frame_worldState_not_finite` proves is not
finite. That is not a convenience. There is a `⊡`-free ℤ-time non-validity that no
`FrameOver.ofStep` frame satisfies at all, so a certificate presenting a finite-carrier frame cannot
certify it; the finite data lives in the *fibres*, which is what keeps every clause of the checker
decidable while the carrier stays infinite.

## The shape of the truth lemma, and the one thing it does not do

The lemma below relates truth in the presented model to `Canon.lean`'s **canonical** membership
predicate `canAt`, not to a run's label directly. That indirection is the point, and it is what
`Canon.lean` was landed for: `plusTypeAtM`-style local coherence takes the semantic correctness of
the box guess as a *hypothesis*, and `AgreesOnState` for the true type is that same correctness at
the `□` and `⊡` shapes, so a truth-based labelling argues in a circle — and not a
formula-structural one, since `AgreesOnState` quantifies over every state shape of the closure.
`canAt` never mentions truth: its `□` and `⊡` cases read `G.slab` by fiat. A run's label is then
recovered as a *theorem* (`lab_eq_canLab`), not assumed.

Each case of the induction is one clause:

* `atom` — the model's own valuation is the slice labelling, so this is `Iff.rfl`.
* `bot`, `imp` — `canAt`'s own clauses, which are the semantic ones verbatim.
* `untl`, `snce` — likewise: `canAt` takes the **existential** form of both, which is exactly the
  semantic clause, so these two cases are a direct transfer under the induction hypotheses. No
  fulfilment and no step clause is consumed here; both were already spent inside `Canon.lean`.
* `box` — (C3b) `BoxLabelFaithful` ties the slice labelling to the box guess, the box clause
  `BoxLiveFaithful` ties the guess to the live positions, and `plusBox_const` is what lets the
  clause be read at the time the live position sits at rather than at the asking time.
* `stab` — (C5) `StabFaithful`, at the window representative of the asking time. This is the case
  the residue-indexed `TailStable` exists for: see below.

## Why the `⊡` case needs `exists_win_live_eq` and the `□` case does not need more

Both `StabFaithful` and `BoxLiveFaithful` are stated at **window** times and against the computed
`G.liveAt`, because that is the only form a checker can evaluate, while the truth lemma needs its
clauses at an **arbitrary** time: the `U` and `S` cases send the induction to arbitrary times, and
the `⊡` clause's comparison class is the histories agreeing at `τ.state t = (t, w)`, whose first
component *is* the time. So no shift normalizes the `⊡` clause's time away — `plusTruthAt_shiftBack`
re-times the comparison class without changing it — and the live set has to transport instead.
`Tail.lean`'s `exists_win_live_eq` is that transport, and it is what the residue indexing of
`TailStable` buys.

The `□` case is in the same position for a different reason: `plusBox_const` makes `□χ`'s truth
independent of both history and time, so the clause may be read at whatever time is convenient — but
the position whose label must contain `χ` still sits at an arbitrary time, so its liveness still has
to reach a window time. The same transport serves. What the `□` case does *not* need is any
re-timing of the formula.

## Main definitions

- `PlusSlicedCertificate.stepHistory` — the history a bare `G.edge`-path presents, at offset `0`
- `PlusSlicedCertificate.frame_sat_ztime` — the presented frame satisfies `FrameClass.ZTime`

## Main results

- `PlusSlicedCertificate.exists_stepHistory` — every history of the presented frame is a time-shift
  of a `stepHistory`
- `PlusSlicedCertificate.plusTruthAt_iff_canAt` — **the truth lemma**, all seven cases
- `PlusSlicedCertificate.mem_canLab_iff_plusTruthAt` — the same, read on the canonical label
- `PlusSlicedCertificate.plusRefutes_of_certifies` — the refutation interface, landing
  `PlusWitnessFamily.PlusRefutes Γ Del` unchanged

## Tags

plus-language · certificate · time-sliced · soundness · truth-lemma
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.PlusLanguage
open FormalSystem.Semantics

namespace PlusSlicedCertificate

variable {Γ Del : PlusContext}

/-! ## The presented frame is a ℤ-time frame -/

/-- **The presented frame is a ℤ-time frame.** Applied with an explicit `@` and four
`inferInstanceAs` arguments, exactly as `SharingSkeleton.frame_isZTime` is: a `haveI` shadows the
`SuccOrder` instance that `IsSuccArchimedean` is indexed by, and the application then fails to
elaborate. -/
theorem frame_isZTime (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) :
    (G.frame h).toTaskFrame.IsZTime :=
  @TaskFrame.isZTime_of_instances (G.frame h).toTaskFrame
    (inferInstanceAs (SuccOrder ℤ)) (inferInstanceAs (PredOrder ℤ))
    (inferInstanceAs (IsSuccArchimedean ℤ)) (inferInstanceAs (IsPredArchimedean ℤ))

/-- **The presented frame satisfies the ℤ-time frame class**, which is the second component
`PlusRefutes` asks for. -/
theorem frame_sat_ztime (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) :
    FormalSystem.ProofSystem.FrameClass.ZTime.Sat (G.frame h).toTaskFrame :=
  ⟨inferInstance, G.frame_isZTime h⟩

/-! ## The history a bare edge path presents

`Frame.lean`'s `pathHistory` takes a `PlusGraphPath`, which carries a labelling the truth lemma has
no use for. What the truth lemma quantifies over is the **state** paths, so this is the same
construction on a bare `g : ℤ → Fin G.n`.
-/

/-- **The history of a bare `G.edge`-path**, at offset `0`: it occupies slice `t` at time `t`. -/
def stepHistory (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) (g : ℤ → Fin G.n)
    (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) : WorldHistory (G.frame h) :=
  FrameOver.worldHistoryOfStepPath (G.frame h) (fun t => ((t, g t) : ℤ × Fin G.n))
    (fun n => (G.frame_step h _ _).mpr ⟨rfl, hg n⟩)

@[simp]
theorem stepHistory_state (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial) (g : ℤ → Fin G.n)
    (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) (t : ℤ) :
    (G.stepHistory h g hg).state t = ((t, g t) : ℤ × Fin G.n) := rfl

/--
**Every history of the presented frame is a time-shift of a `stepHistory`.**

`mem_HF_iff_slicedPath` says a history is an *offset* step path; this moves the offset into the
path's index, which is the form the truth lemma's `□` and `⊡` cases consume. Note that the
re-indexed path `fun s => g₀ (s - k)` is an edge path at the **unshifted** times, which is what
makes it a legitimate offset-`0` path: the slice sequence is not shift-invariant, so the re-indexing
has to be checked and not assumed.
-/
theorem exists_stepHistory (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (σ : WorldHistory (G.frame h)) :
    ∃ (k : ℤ) (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true),
      (∀ v : ℤ, σ.path v = ((v + k, g (v + k)) : ℤ × Fin G.n)) ∧
        σ.timeShift (-k) = G.stepHistory h g hg := by
  obtain ⟨k, g₀, hg₀, hpath⟩ := (G.mem_HF_iff_slicedPath h σ.path).mp ⟨σ, rfl⟩
  have hg : ∀ t : ℤ, G.edge t (g₀ (t - k)) (g₀ (t + 1 - k)) = true := by
    intro t
    have hb := hg₀ (t - k)
    rwa [show t - k + k = t from by omega, show t - k + 1 = t + 1 - k from by omega] at hb
  refine ⟨k, fun s => g₀ (s - k), hg, ?_, ?_⟩
  · intro v
    refine Eq.trans (congrFun hpath v) ?_
    change ((v + k, g₀ v) : ℤ × Fin G.n) = ((v + k, g₀ (v + k - k)) : ℤ × Fin G.n)
    rw [show v + k - k = v from by omega]
  · have key : ∀ v : ℤ, ((σ.timeShift (-k)).state v : ℤ × Fin G.n)
        = ((v, g₀ (v - k)) : ℤ × Fin G.n) := by
      intro v
      refine Eq.trans
        (show ((σ.timeShift (-k)).state v : ℤ × Fin G.n) = σ.path (v + -k) from rfl) ?_
      rw [congrFun hpath (v + -k), show v + -k + k = v from by omega,
        show v + -k = v - k from by omega]
    exact WorldHistory.ext_state (fun v => key v)

/-! ## The truth lemma -/

/--
**The truth lemma, all seven cases.**

Truth in the presented model along an arbitrary `G.edge`-path agrees with the canonical membership
predicate of that path, at every time and every L⁺ formula of the target closure.

Four hypotheses are consumed, and each exactly once: (C3b) `BoxLabelFaithful` in the `□` case and
inside the liveness bridge, the box clause `BoxLiveFaithful` in the `□` case, (C5) `StabFaithful` in
the `⊡` case, and `TailStable` in both of those two cases through `exists_win_live_eq`. Delete any
one and the corresponding case does not elaborate.
-/
theorem plusTruthAt_iff_canAt (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (hbox : G.BoxLabelFaithful) (hTS : G.TailStable) (hstab : G.StabFaithful)
    (hblf : G.BoxLiveFaithful) :
    ∀ ψ : PlusFormula, ψ ∈ plusClosureOf (Γ ++ Del) →
      ∀ (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) (t : ℤ),
        PlusTruthAt (G.model h) (G.stepHistory h g hg) t ψ ↔ G.canAt g ψ t := by
  intro ψ
  induction ψ with
  | atom a => intro _ g hg t; exact Iff.rfl
  | bot => intro _ g hg t; exact Iff.rfl
  | imp a b iha ihb =>
    intro hmem g hg t
    rw [show PlusTruthAt (G.model h) (G.stepHistory h g hg) t (PlusFormula.imp a b)
        = (PlusTruthAt (G.model h) (G.stepHistory h g hg) t a →
            PlusTruthAt (G.model h) (G.stepHistory h g hg) t b) from rfl,
      G.canAt_imp g a b t]
    exact Iff.imp (iha (plusClosureOf_imp_left hmem) g hg t)
      (ihb (plusClosureOf_imp_right hmem) g hg t)
  | box χ ih =>
    intro hmem g hg t
    have hχ : χ ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_box hmem
    rw [G.canAt_box g χ t, hbox χ hmem t (g t), hblf χ hmem]
    constructor
    · -- every history carries `χ` at `t`, hence at every time, hence at every live position
      intro hall u hu p hp
      obtain ⟨g', hg', h1, h2⟩ := G.exists_path_canLab_of_live
        (G.live_of_mem_liveAt hbox hu hp)
      have hbu : PlusTruthAt (G.model h) (G.stepHistory h g' hg') u (PlusFormula.box χ) :=
        (plusBox_const (G.model h) (G.stepHistory h g hg) (G.stepHistory h g' hg') t u χ).mp hall
      have hcan := (ih hχ g' hg' u).mp (hbu (G.stepHistory h g' hg'))
      rw [h2]
      exact (G.mem_canLab g').mpr ⟨hχ, hcan⟩
    · -- every live position carries `χ`, and every history is a shifted edge path
      intro hlive
      change ∀ σ : WorldHistory (G.frame h).toTaskFrame, PlusTruthAt (G.model h) σ t χ
      intro σ
      obtain ⟨k, g', hg', -, hσ⟩ := G.exists_stepHistory h σ
      rw [G.plusTruthAt_shiftBack h σ χ t k, hσ, ih hχ g' hg' (t + k)]
      obtain ⟨s, hs, -, hliveiff⟩ := G.exists_win_live_eq hbox hTS (t + k)
      have hp : G.Live s ((g' (t + k),
          ⟨G.canLab g' (t + k), Finset.mem_powerset.mpr (G.canLab_subset g' (t + k))⟩) : G.Pos) :=
        (hliveiff _).mp (G.live_canRun_pair hbox g' hg' (t + k))
      have hmemlive := G.mem_liveAt_of_live hs hp
      exact ((G.mem_canLab g').mp (hlive s hs _ hmemlive)).2
  | untl a b iha ihb =>
    intro hmem g hg t
    have hac : a ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_untl_right hmem
    have hbc : b ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_untl_left hmem
    rw [G.canAt_untl g a b t]
    constructor
    · rintro ⟨s, hts, hbs, hguard⟩
      exact ⟨s, hts, (ihb hbc g hg s).mp hbs,
        fun r hr1 hr2 => (iha hac g hg r).mp (hguard r hr1 hr2)⟩
    · rintro ⟨s, hts, hbs, hguard⟩
      exact ⟨s, hts, (ihb hbc g hg s).mpr hbs,
        fun r hr1 hr2 => (iha hac g hg r).mpr (hguard r hr1 hr2)⟩
  | snce a b iha ihb =>
    intro hmem g hg t
    have hac : a ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_snce_right hmem
    have hbc : b ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_snce_left hmem
    rw [G.canAt_snce g a b t]
    constructor
    · rintro ⟨s, hst, hbs, hguard⟩
      exact ⟨s, hst, (ihb hbc g hg s).mp hbs,
        fun r hr1 hr2 => (iha hac g hg r).mp (hguard r hr1 hr2)⟩
    · rintro ⟨s, hst, hbs, hguard⟩
      exact ⟨s, hst, (ihb hbc g hg s).mpr hbs,
        fun r hr1 hr2 => (iha hac g hg r).mpr (hguard r hr1 hr2)⟩
  | stab χ ih =>
    intro hmem g hg t
    have hχ : χ ∈ plusClosureOf (Γ ++ Del) := plusClosureOf_stab hmem
    obtain ⟨s, hs, hslice, hliveiff⟩ := G.exists_win_live_eq hbox hTS t
    rw [G.canAt_stab g χ t, ← G.slab_congr hslice (g t), hstab s hs (g t) χ hmem]
    constructor
    · -- every agreeing history carries `χ`, and a live position is such a history's own position
      intro hall p hp hfst
      have hlt : G.Live t p := (hliveiff p).mpr (G.live_of_mem_liveAt hbox hs hp)
      obtain ⟨g', hg', h1, h2⟩ := G.exists_path_canLab_of_live hlt
      have hgg : g t = g' t := by rw [← h1, hfst]
      have hstate : (G.stepHistory h g hg).state t = (G.stepHistory h g' hg').state t := by
        rw [G.stepHistory_state, G.stepHistory_state, hgg]
      have hcan := (ih hχ g' hg' t).mp (hall (G.stepHistory h g' hg') hstate)
      rw [h2]
      exact (G.mem_canLab g').mpr ⟨hχ, hcan⟩
    · -- a live position's label is read off the agreeing history it comes from
      intro hlive
      change ∀ σ : WorldHistory (G.frame h).toTaskFrame,
        (G.stepHistory h g hg).state t = σ.state t → PlusTruthAt (G.model h) σ t χ
      intro σ hstate
      obtain ⟨k, g', hg', hoff, hσ⟩ := G.exists_stepHistory h σ
      have he : ((t, g t) : ℤ × Fin G.n) = ((t + k, g' (t + k)) : ℤ × Fin G.n) := by
        rw [← hoff t]
        exact hstate
      have hk : k = 0 := by
        have h1 := congrArg Prod.fst he
        simp only at h1
        omega
      have hgt : g' t = g t := by
        have h2 := congrArg Prod.snd he
        simp only at h2
        rw [hk, add_zero] at h2
        exact h2.symm
      rw [G.plusTruthAt_shiftBack h σ χ t k, hσ, ih hχ g' hg' (t + k), hk, add_zero]
      have hp : G.Live s ((g' t,
          ⟨G.canLab g' t, Finset.mem_powerset.mpr (G.canLab_subset g' t)⟩) : G.Pos) :=
        (hliveiff _).mp (G.live_canRun_pair hbox g' hg' t)
      have hmemlive := G.mem_liveAt_of_live hs hp
      exact ((G.mem_canLab g').mp (hlive _ hmemlive hgt)).2

/-- **The truth lemma, read on the canonical label.** The form the target clause consumes. -/
theorem mem_canLab_iff_plusTruthAt (G : PlusSlicedCertificate Γ Del) (h : G.BiSerial)
    (hbox : G.BoxLabelFaithful) (hTS : G.TailStable) (hstab : G.StabFaithful)
    (hblf : G.BoxLiveFaithful) {ψ : PlusFormula} (hψ : ψ ∈ plusClosureOf (Γ ++ Del))
    (g : ℤ → Fin G.n) (hg : ∀ t : ℤ, G.edge t (g t) (g (t + 1)) = true) (t : ℤ) :
    ψ ∈ G.canLab g t ↔ PlusTruthAt (G.model h) (G.stepHistory h g hg) t ψ := by
  rw [G.mem_canLab g, G.plusTruthAt_iff_canAt h hbox hTS hstab hblf ψ hψ g hg t]
  exact ⟨fun hc => hc.2, fun hc => ⟨hψ, hc⟩⟩

/-! ## The refutation interface

The theorem the whole subtree exists to land, and it lands `PlusWitnessFamily.PlusRefutes Γ Del`
verbatim — the same proposition `PlusSharingWitnessFamily.plusRefutes_of_certifies` lands, not a new
refutation predicate. See this module's header for why the two coexist.

The fulfilling run comes from `exists_fulfilling_run_at_targetTime`, which is what pays for the
dropped `witness` field: clause 6 of `Certifies` says the target path's position at the target time
is live, and liveness is occupancy by a run discharging both halves of fulfilment. `lab_eq_canLab`
then says that run's label *is* the canonical label of its state path, so the target clause — stated
on `G.target.lab G.targetTime` — is read through the truth lemma without the target path itself
having to be fulfilling.
-/

/--
**The producer for the L⁺ refutation interface, from a time-sliced certificate.**

`PlusRefutes Γ Del` at the presented frame, the presented model, the history of the fulfilling run
through the target position, and the target time. Every premise is L⁺-true there and every
conclusion L⁺-false, by the truth lemma against (C4) `Target`.

Paper: — (a formalization-native producer for the refutation interface; the paper has no
counterpart)
-/
theorem plusRefutes_of_certifies (G : PlusSlicedCertificate Γ Del) (hc : G.Certifies) :
    PlusWitnessFamily.PlusRefutes Γ Del := by
  have h := G.biSerial_of_certifies hc
  have hbox := G.boxLabelFaithful_of_certifies hc
  have hTS := G.tailStable_of_certifies hc
  have hstab := G.stabFaithful_of_certifies hc
  have hblf := G.boxLiveFaithful_of_certifies hc
  have htgt := G.target_of_certifies hc
  obtain ⟨R, hRf, hRlab⟩ := G.exists_fulfilling_run_at_targetTime hc
  have hlab : G.target.lab G.targetTime = G.canLab R.st G.targetTime := by
    rw [← hRlab]
    exact G.lab_eq_canLab R hRf G.targetTime
  refine ⟨(G.frame h).toTaskFrame, G.frame_sat_ztime h, G.model h,
    G.stepHistory h R.st R.steps, G.targetTime, ?_, ?_⟩
  · intro γ hγ
    refine (G.mem_canLab_iff_plusTruthAt h hbox hTS hstab hblf
      (plusPremise_mem_closure hγ) R.st R.steps G.targetTime).mp ?_
    rw [← hlab]
    exact htgt.1 γ hγ
  · intro σ hσ hT
    refine htgt.2 σ hσ ?_
    rw [hlab]
    exact (G.mem_canLab_iff_plusTruthAt h hbox hTS hstab hblf
      (plusConclusion_mem_closure hσ) R.st R.steps G.targetTime).mpr hT

end PlusSlicedCertificate

end FormalSystem.Metalogic.Decidability
