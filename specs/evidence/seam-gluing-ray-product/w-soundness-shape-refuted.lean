/-
Probe 747 (requirement (W) of the ray-product verdict, the run-layer verdict): **requirement
(S)'s construction `modelOf` cannot be the soundness half of (W) for `box`/`stab`-bearing L⁺,
on two independent axes.** Requirement (W) asks for ONE finite object that witnesses
`¬ PlusValidZTime φ` for some regular ℤ-model, history and time, with the `box` and `stab`
anchors nested under `untl`/`snce`. Its soundness half would be a construction turning such an
object into a refuting model. The only construction in the tree is (S)'s
`FormalSystem.Metalogic.Decidability.RaySummary.modelOf` — a model on the frame
`frameOf hC := FrameOver.ofSlicedStep` over a finite presentation `⟨Q, lab, step⟩` satisfying
`Cons` — and this probe shows, by two theorems that each cite the library and re-prove nothing,
that its SHAPE cannot be (W)'s: it has finite-width slices (WIDTH), and its realization
hypothesis collapses `⊡` at the seam (COLLAPSE).

**The fixture.** There is no fixture: both halves are stated over EVERY finite `Q`, every
labelling `lab`, every step relation `step` and every `Cons` presentation (WIDTH), and over
every regular ℤ-frame `F`, every model `M`, every seam `(τ, t)` and every `Presented`
presentation whose `now`-marked states are unique (COLLAPSE). The cited witnesses are the
library's own: `NoFiniteWidth.Φ` (the formula no finite-width `ofSlicedStep` model satisfies,
`Limits/NoFiniteWidth.lean`) for WIDTH, and `Fp → ⊡Fp` — refuted on model A of
`quasistate-does-not-determine-hit.lean` and, as `refute_determined`
(`PlusLanguage/PlusNonValidities.lean`), on `natFrame` — as the example COLLAPSE excludes.

**The argument.** WIDTH: `frameOf hC` is `ofSlicedStep` on the finite `Q` of the presentation,
so `NoFiniteWidth.no_finite_width_sat` applies verbatim (with the presentation's step relation
and `Cons.serialFwd`/`serialBwd` as its seriality arguments): no history of any `modelOf`
model satisfies `Φ` at any time (`modelOf_not_sat_Φ`). By `PlusTruth.neg_iff`, every `modelOf`
model therefore VALIDATES `Φ.neg` at every point (`modelOf_sat_neg_Φ`) — while `Φ.neg` is a
ℤ-time NON-validity (`NoFiniteWidth.not_plusValidZTime_neg_Φ`). The conjunction
`modelOf_incomplete` states the gap in one sentence: `¬ PlusValidZTime Φ.neg`, and yet no `Cons`
presentation's `modelOf` refutes `Φ.neg`. This holds whatever clauses are added to `Cons`: the
width is a property of `ofSlicedStep`, not of the consistency conditions. COLLAPSE: at a
`Presented` seam (`RaySummary/Trace.lean`: the seam's closure traces are exactly the
presentation's anchored run traces), every history `σ` through the seam is the splice of some
ray pair (`exists_spliced_eq`, the `⇐` half of `plusStab_iff_omega` read off `seamOmegaEquiv`),
so its closure trace is a seam trace, so it is realized by an anchored run `ρ`, and every
closure letter of `σ` at `t` is read off `lab (ρ t)` (`presented_letter_at_seam`). If the
presentation marks at most one state with `now` — exactly `Cons.nowUnique`, which (S) found
necessary — then every anchored run is at the SAME state at `t`, so every history through the
seam agrees with `τ` on every closure formula at `t`: `ψ → ⊡ψ` for all `ψ ∈ cl φ`
(`stab_of_presented_nowUnique`), i.e. `ψ ↔ ⊡ψ` (`stab_iff_of_presented_nowUnique`). No
`⊡`-refutation of a closure formula — `Fp ∧ ¬⊡Fp` at a seam, the shape every `⊡`-non-validity
needs — is ever witnessed at a `Presented`+`nowUnique` seam, independent of width.

**What is established (machine-checked).** `modelOf_not_sat_Φ`, `modelOf_sat_neg_Φ` and the
headline `modelOf_incomplete` (WIDTH), for every `[Fintype Q] [DecidableEq Q] [Nonempty Q]`,
every `φ`, `lab`, `step` and `hC : Cons φ lab step`; `exists_spliced_eq`,
`presented_letter_at_seam`, `stab_of_presented_nowUnique` and the headline
`stab_iff_of_presented_nowUnique` (COLLAPSE), for every `[F.IsRegular]`, `M`, `τ`, `t`, `φ`,
`lab`, `step`, `hP : Presented M τ t φ lab step` and the uniqueness hypothesis
`hU : ∀ q q', lab q (clNow φ) = true → lab q' (clNow φ) = true → q = q'`. Consequence for (W):
the realization hypothesis of its run layer must be Hit-level or product-level per cell
(`HitPresented`, family-triple SETS — `hit-presented-model-a.lean`), never trace-level
`Presented`; and the frame of its run layer must have infinite-width slices (the `Node`
thread-unfolding shape of `Limits/NoFiniteWidth.lean`, which `ofSlicedStep` cannot build).

**What is NOT established.** Requirement (S) is UNTOUCHED: `presented_modelOf`
(`RaySummary/Realize.lean`) is a correct soundness statement for `box`/`stab`-free `φ` at one
seam under `Cons`, and nothing here weakens, retires or re-proves it — WIDTH says only that its
frame SHAPE cannot be the whole soundness half of a lift for `box`/`stab`-bearing L⁺, and
COLLAPSE says only that its realization hypothesis cannot witness a `⊡`-refutation. Nothing here
is a negative decidability result: the verdict is that THIS construction and THIS hypothesis do
not deliver the lift, not that none exists; `Decidable (PlusValidZTime φ)` is NOT stated in any
form and no sentence here says L⁺ is or is not decidable. Nothing about `⊡(Pp)`: the collapse
is stated at the seam for every closure formula, but every fixture in this collection is
forward-only and there is still no backward Bool-fixture bridge — the backward side is fixed
only by `Probe719Backward.pastStab_iff_allBwdPathsMeet` on the asymmetric fixture. Nothing
about `HitPresented`, which holds on model A non-constructively
(`Probe745.hitPresented_modelA`) and remains the realization hypothesis (W) may use. No
complexity bound of any kind. Nothing about models whose slices are infinite beyond the
statement that (W)'s frame must have them. `no_finite_width_sat`, `not_plusValidZTime_neg_Φ`,
`Presented`, `clTrace_letter`, `seamOmegaEquiv` and `Cons` are the library's, cited and not
re-proved; this file declares only the seven theorems below.

**The decision held in place.** The (W) record's run layer is BLOCKED, not open-ended, on
three named obligations (`RaySummary/README.md`, "(W): what landed and what did not"): a
frame-scheme constructor producing infinite-width, finitely branching regular frames from a
finite object (WIDTH forbids `ofSlicedStep`); a Hit-level per-cell realization hypothesis
(COLLAPSE forbids `Presented`); and the presentation-size bound
`kTypeOf_listSeg_replicate_eventually_periodic`. The anchor layer of (W) — the `box`/`stab`
fixpoint equations on closure types, for every model — is landed in
`RaySummary/AnchorLayer.lean` and does not depend on any of the three. Any successor that
proposes a run-layer construction must first exhibit a frame shape that `modelOf_incomplete`
does not refute and a realization hypothesis that `stab_iff_of_presented_nowUnique` does not
collapse.

**Axiom record.** Every declaration below: `[propext, Classical.choice, Quot.sound]` (see the
`#print axioms` foot); the list is exactly these three and nothing is left unproved.
`Classical.choice` is inherited from the library's seam machinery (`seamOmegaEquiv`,
`FrameOver.worldHistoryOfStepPath`), as in every probe of this collection.

**Compile line.**
`lake env lean specs/evidence/seam-gluing-ray-product/w-soundness-shape-refuted.lean`
(wired into `scripts/check-evidence-probes.sh`).
-/
import FormalSystem.Metalogic.Decidability.RaySummary.Realize
import FormalSystem.Metalogic.Decidability.RaySummary.Trace
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Limits.NoFiniteWidth

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.Decidability.RaySummary
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate

namespace Probe747

/-! ## WIDTH: every `modelOf` model lives on a finite-width `ofSlicedStep` frame -/

section Width

variable {Q : Type} [Fintype Q] [DecidableEq Q] [Nonempty Q]

/-- No model built by `modelOf` satisfies the finite-width witness `Φ` at any seam and time. -/
theorem modelOf_not_sat_Φ {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step)
    (τ : WorldHistory (frameOf hC).toTaskFrame) (t : ℤ) :
    ¬ PlusTruthAt (modelOf φ lab step hC) τ t NoFiniteWidth.Φ :=
  NoFiniteWidth.no_finite_width_sat (fun _ q q' => step q q' = true)
    (fun _ q => hC.serialFwd q) (fun _ q => hC.serialBwd q) (modelOf φ lab step hC) τ t

/-- Hence every `modelOf` model VALIDATES `Φ.neg` at every point, although `Φ.neg` is refuted on
some regular ℤ-model (`not_plusValidZTime_neg_Φ`): the constructed-model family misses a
ℤ-time non-validity. -/
theorem modelOf_sat_neg_Φ {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool}
    {step : Q → Q → Bool} (hC : Cons φ lab step)
    (τ : WorldHistory (frameOf hC).toTaskFrame) (t : ℤ) :
    PlusTruthAt (modelOf φ lab step hC) τ t NoFiniteWidth.Φ.neg :=
  (PlusTruth.neg_iff _ _ _ _).mpr (modelOf_not_sat_Φ hC τ t)

/-- The gap, stated as one sentence: `Φ.neg` is not ℤ-valid, yet no `Cons` presentation's
`modelOf` refutes it. -/
theorem modelOf_incomplete :
    ¬ PlusValidZTime NoFiniteWidth.Φ.neg ∧
      ∀ {φ : PlusFormula} {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
        (hC : Cons φ lab step) (τ : WorldHistory (frameOf hC).toTaskFrame) (t : ℤ),
        PlusTruthAt (modelOf φ lab step hC) τ t NoFiniteWidth.Φ.neg :=
  ⟨NoFiniteWidth.not_plusValidZTime_neg_Φ, fun hC τ t => modelOf_sat_neg_Φ hC τ t⟩

end Width

/-! ## COLLAPSE: at a `Presented` seam with a unique `now` state, `ψ ↔ ⊡ψ` on `cl φ` -/

section Collapse

variable {F : FrameOver intOrder} [F.IsRegular] {Q : Type}

/-- Every history in the seam's fibre is a splice of some ray pair (the `⇐` half of
`plusStab_iff_omega`, extracted). -/
theorem exists_spliced_eq (τ σ : WorldHistory F.toTaskFrame) (t : ℤ)
    (hσ : τ.state t = σ.state t) : ∃ bf : SeqPair F (τ.state t), spliced τ t bf = σ := by
  let x : Presheaf.StabFibre F.toTaskFrame t (τ.state t) := ⟨σ, hσ.symm⟩
  refine ⟨(seamOmegaEquiv t (τ.state t)) x, ?_⟩
  show ((seamOmegaEquiv t (τ.state t)).symm ((seamOmegaEquiv t (τ.state t)) x)).1 = σ
  rw [(seamOmegaEquiv t (τ.state t)).symm_apply_apply]

/-- Under `Presented`, every history through the seam reads each closure letter at `t` off the
`now` state of some anchored run. -/
theorem presented_letter_at_seam (M : TaskModel F.toTaskFrame) (τ : WorldHistory F.toTaskFrame)
    (t : ℤ) (φ : PlusFormula) {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hP : Presented M τ t φ lab step) (σ : WorldHistory F.toTaskFrame)
    (hσ : τ.state t = σ.state t) :
    ∃ ρ : ℤ → Q, IsRun lab step (clNow φ) t ρ ∧
      ∀ {ψ : PlusFormula} (h : ψ ∈ plusSubformulaClosure φ),
        (PlusTruthAt M σ t ψ ↔ lab (ρ t) (clLetter φ h) = true) := by
  obtain ⟨bf, hbf⟩ := exists_spliced_eq τ σ t hσ
  obtain ⟨ρ, hρ, hc⟩ := (hP (clTrace M φ t σ)).mp ⟨bf, by rw [hbf]⟩
  refine ⟨ρ, hρ, fun {ψ} h => ?_⟩
  have := congrFun (congrFun hc (clLetter φ h)) t
  simp only [clTrace_letter, runTrace] at this
  exact Iff.of_eq this

/-- **The `⊡`-collapse at a `Presented` seam with a unique `now` state**: every closure formula
true at the seam is `⊡`-true there. -/
theorem stab_of_presented_nowUnique (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hP : Presented M τ t φ lab step)
    (hU : ∀ q q' : Q, lab q (clNow φ) = true → lab q' (clNow φ) = true → q = q')
    {ψ : PlusFormula} (h : ψ ∈ plusSubformulaClosure φ) :
    PlusTruthAt M τ t ψ → PlusTruthAt M τ t (.stab ψ) := by
  intro hψ σ hσ
  obtain ⟨ρτ, hρτ, hτ⟩ := presented_letter_at_seam M τ t φ hP τ rfl
  obtain ⟨ρσ, hρσ, hσ'⟩ := presented_letter_at_seam M τ t φ hP σ hσ
  have hq : ρσ t = ρτ t := hU _ _ ((hρσ.2 t).mpr rfl) ((hρτ.2 t).mpr rfl)
  rw [hσ' h, hq, ← hτ h]
  exact hψ

/-- The same, as the biconditional `ψ ↔ ⊡ψ` at the seam. -/
theorem stab_iff_of_presented_nowUnique (M : TaskModel F.toTaskFrame)
    (τ : WorldHistory F.toTaskFrame) (t : ℤ) (φ : PlusFormula)
    {lab : Q → (clSig φ).preds → Bool} {step : Q → Q → Bool}
    (hP : Presented M τ t φ lab step)
    (hU : ∀ q q' : Q, lab q (clNow φ) = true → lab q' (clNow φ) = true → q = q')
    {ψ : PlusFormula} (h : ψ ∈ plusSubformulaClosure φ) :
    PlusTruthAt M τ t ψ ↔ PlusTruthAt M τ t (.stab ψ) :=
  ⟨stab_of_presented_nowUnique M τ t φ hP hU h, fun hs => hs τ rfl⟩

end Collapse

end Probe747

#print axioms Probe747.modelOf_not_sat_Φ
#print axioms Probe747.modelOf_sat_neg_Φ
#print axioms Probe747.modelOf_incomplete
#print axioms Probe747.exists_spliced_eq
#print axioms Probe747.presented_letter_at_seam
#print axioms Probe747.stab_of_presented_nowUnique
#print axioms Probe747.stab_iff_of_presented_nowUnique
