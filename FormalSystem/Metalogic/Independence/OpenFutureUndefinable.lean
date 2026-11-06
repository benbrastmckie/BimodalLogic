/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Expressiveness.OpenFutureElimination
import FormalSystem.Semantics.Frames.TranslationProduct

/-!
# The open-future modal is not L⁺-definable over non-Dedekind-complete time

## What is proved here

The **marker gadget**: two atoms, `p` (data) and `m` (marker), and four L⁺ formulas

```
θ  :=  ¬m ∧ ⊞m                 (`⊞` = `allFuture`)
ν  :=  θ ∨ ⟡θ                  (`⟡` = `someFuture`)
R  :=  p ∧ ⊞(ν → p)
Δ' :=  S(¬(p ∧ ¬R), ¬p)
φ  :=  θ ∧ Δ'
```

whose joint effect is that the point of evaluation becomes nameable from inside L⁺, at the cost
of one atom:

* `MarkerGadget.theta_eq_iff` — if `m` is false at `t` and true everywhere after, then `θ` holds
  at `s` **iff `s = t`**: `θ` is a definable singleton, on any frame over any duration.
* `MarkerGadget.nu_iff_le` — hence `ν` names the closed past `(-∞, t]`.
* `MarkerGadget.run_iff` — hence `R` names membership in the backward `p`-run of `t`, *without*
  naming that run's lower endpoint, which over a non-Dedekind-complete duration is a gap. This
  is the step `U`/`S` cannot take on its own: `R` is not `U(p, ·)`, it is a bounded-below
  universal over a region named by `ν`.
* `MarkerGadget.delta_iff` — hence `Δ'` holds at `t` exactly when `MarkerGadget.DeltaProp` does.

`DeltaProp` is the gap-anchored past property: there is a `¬p` point `u < t` such that every `p`
point strictly between `u` and `t` already lies in the backward `p`-run of `t`. Equivalently, the
`p`-run of `t` is immediately preceded by a stretch of `¬p`, with no further `p`-run accumulating
at the run's lower gap. It is the transposition to this setting of the isolation condition on a
left `p` gap used in [GHR][gabbay1994] vol. 1, §12.5.

The exactness claim is `MarkerGadget.dofut_probe_iff`: because `m` occurs in `φ` only inside `θ`,
and `θ` is the marker condition itself, the **existential** dual of `▷` can install the marker
for free and nothing else about the chosen world matters. So on any frame with enough worlds,

```
(∃ ρ ∈ |τ⟩_t, PlusTruthAt M ρ t φ)  ↔  DeltaProp M τ t,
```

equivalently `▷(¬φ) ↔ ¬DeltaProp` (`MarkerGadget.ofut_neg_probe_iff`): `▷` **computes**
`DeltaProp`, with no slack. The conditional non-definability theorem
`ofut_not_plusDefinable_of_deltaProp_inexpressible` reads that off: at any frame where
`DeltaProp` is not L⁺-expressible, `▷` is not L⁺-definable.

## The verdict, and exactly how much of it is machine-checked

The verdict the research round settled is that `▷` — and, by time reflection, its mirror `◁` —
is **not** L⁺-definable at `.Base` and not at `.Dense`. Together with the positive result at
`.ZTime` and `.RTime` (`Metalogic/Expressiveness/OpenFutureElimination.lean`, which obtains a
truth-preserving translation through Gabbay separation), the class split closes: `▷` is a genuine
expressive extension of L⁺ over non-Dedekind-complete time, and not notation for anything L⁺ can
already say.

**That unconditional reading depends on `hinexpr`, which is not formalized in this tree.** What
compiles here is the reduction: *given* the frame's enough-worlds condition and the
inexpressibility of `DeltaProp` at that frame, `▷` is not definable there. The verdict follows
from the reduction only once `hinexpr` is discharged, and discharging it is a paper step.

## What is not proved here

* **`hinexpr`** — that `DeltaProp` is not L⁺-expressible on the permissive frame over a dense,
  non-Dedekind-complete duration. The research round derives it: on that frame every function
  from the duration to world states is a world, so `⊡` and `□` collapse to Boolean functions of
  the present state by translation invariance, and every L⁺ formula collapses to one of `p`,
  `¬p`, `⊤`, `⊥` on the nice structures — a collapse computation in the style of
  [GHR][gabbay1994] vol. 1, Lemma 12.4.2, transposed from their flow to a dense carrier, and
  **derived rather than quoted**. The two separating structures have run order type `ℤ` and
  `ω + 1 + ω`, and `DeltaProp` tells them apart. That half is **UNVERIFIED in Lean** and is the
  paper step of record.
* **The all-models form of `hmarkers`.** Read literally, the hypothesis of
  `ofut_not_plusDefinable_of_deltaProp_inexpressible` quantifies over every model of the frame,
  and in that form it is false everywhere: a valuation making `m` false at every state admits no
  history carrying the marker future. What is now compiled is the condition at the *intended*
  valuation — `colourFibre_hmarkers`, at `colourFibre D` under `markerModel D`, consumed by the
  fixed-model variant `ofut_not_plusDefinable_of_deltaProp_inexpressible_at`. The all-models
  hypothesis itself is kept as stated and is not discharged here.
* Any claim that the companion module's `openTruthAt_iff_tr` is literally a positive instance of
  `OfutPlusDefinable`. The two are the same truth-level notion and the cross-reference is
  recorded, but no bridge between them is proved here.
* Any completeness or decidability claim for L^▷ or for L⁺, and any refutation of a
  validity-level-only translation: `OfutPlusDefinable` is the **truth**-level notion, and a
  negative result about it leaves a validity-level-only translation untouched.

## The frame constraint that shaped the witness frame

*Limit* forbids the naive permissive rational-time frame. With world states taken to be the atom
colours alone, `R w y u` must fail for all small `|y|` whenever `u ≠ w`, so over a dense duration
a history with finitely many states is a step function with a uniform minimum step: nothing
accumulates, and there is therefore no gap for `Δ'` to be anchored at. The obstruction was the
*frame*, not the duration. The repository's own `colourClock`
(`Semantics/Frames/TranslationProduct.lean`) removes it — the clock component discharges *Limit*
(`prodRel_limit`) and finiteness of the colour set discharges *Saturation* — giving a regular
four-colour frame `colourFibre` over **every** temporal order (`colourFibre_isRegular`).

## Why `DeltaProp`, and not the future-side isolation condition

Because `▷ψ` is past-determined for *every* `OpenFormula` `ψ` (`ofut_pastDet`, with its mirror
`opast_futDet`), the open-future modal can only ever express pure-past properties. A separator
for `▷` must therefore be a pair of worlds with L⁺-indistinguishable but
`DeltaProp`-distinguishable **pasts**; a pair differing only in the future cannot work, whatever
it does to the Stavi connectives. So the target had to be a past-side transposition of the
isolation condition, which is what `DeltaProp` is.

## Main Results

* `ofut_pastDet`, `opast_futDet` — `▷ψ` depends only on the history up to and including `t`, and
  `◁ψ` only on the history from `t` onward, for every `OpenFormula` `ψ`.
* `MarkerGadget.dataAtom`, `MarkerGadget.markerAtom` — the two probe atoms.
* `MarkerGadget.holds`, `MarkerGadget.holds_iff` — atomic truth as the valuation reads it.
* `MarkerGadget.theta`, `MarkerGadget.nu`, `MarkerGadget.runAt`, `MarkerGadget.delta`,
  `MarkerGadget.probe` — the five gadget formulas.
* `MarkerGadget.MarkedAt`, `MarkerGadget.theta_iff`, `MarkerGadget.theta_eq_iff` — the marker
  future, and `θ` as a definable singleton.
* `MarkerGadget.nu_iff_le` — `ν` names the closed past.
* `MarkerGadget.PRun`, `MarkerGadget.run_iff` — the backward `p`-run, named without its lower
  endpoint.
* `MarkerGadget.DeltaProp`, `MarkerGadget.delta_iff`, `MarkerGadget.deltaProp_pastDet` — the
  gap-anchored past property, what `Δ'` says, and its past-determinedness.
* `MarkerGadget.dofut_probe_iff`, `MarkerGadget.ofut_neg_probe_iff` — `▷` computes `DeltaProp`
  exactly.
* `MarkerGadget.deltaProp_of_no_p_between` — the non-vacuity witness for `DeltaProp`.
* `OfutPlusDefinable` — truth-level L⁺-definability of the whole of L^▷ at a frame.
* `ofut_not_plusDefinable_of_deltaProp_inexpressible` — the conditional non-definability theorem.
* `ofut_not_plusDefinable_of_deltaProp_inexpressible_at` — the same reduction at one fixed model,
  which is the form a concrete frame can discharge.
* `MarkerColour`, `cRel`, `cRel_reflection`, `cRel_comp`, `cRel_serial`, `cRel_zero`, `cRel_free`,
  `colourFibre`, `colourFibre_isRegular` — the four-colour clock witness frame, regular over
  every temporal order, with its colour relation free away from `0`.
* `markerAtom_ne_dataAtom`, `markerValuation`, `markerModel` — the intended valuation on the
  witness frame: the first colour bit is `p`, the second is `m`, every other atom is false.
* `colourFibre.ofColourFun`, `colourFibre.ofColourFun_state` — every colour function is a history
  of the witness frame, at any clock offset.
* `colourFibre_hmarkers` — the enough-worlds condition **compiled** at `colourFibre D` under
  `markerModel D`.
* `colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible` — the reduction at the witness
  frame with that condition discharged, leaving `hinexpr` its one remaining hypothesis.

## References

* [GHR][gabbay1994] vol. 1, Lemmas 12.4.1-12.4.2 and 12.4.7, and §12.5 — the collapse
  computation `hinexpr` is derived in the style of, and the isolation condition on a left gap
  that `DeltaProp` transposes.
* [Rabinovich][rabinovich2014] §2.3 and §7 — separation and its failure over
  non-Dedekind-complete flows, which is what closes the `.ZTime`/`.RTime` route at `.Base` and
  `.Dense`.
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage
open FormalSystem.Metalogic.Expressiveness

variable {F : TaskFrame}

/-! ## `▷` is past-determined and `◁` is future-determined

Recorded first because it is what rules out whole families of separator attempts: these hold for
*every* `OpenFormula`, by one unfolding of the clause plus transitivity of agreement. They are
**not** instances of the companion module's `PastDet`/`FutDet`, which are predicates on
`PlusFormula`; weakening the quantifier here to an embedded `ofPlus φ` would throw away exactly
the content that rules out future-side separators. -/

/-- `▷ψ` depends only on the history up to and including `t`, for every `OpenFormula` `ψ`.

Consequence: a separator for `▷` must be a pair of worlds with L⁺-indistinguishable but
`MarkerGadget.DeltaProp`-distinguishable *pasts*. No pair differing only in the future can
work. -/
theorem ofut_pastDet (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (hag : AgreeUpTo τ σ t) (ψ : OpenFormula) :
    OpenTruthAt M τ t (.ofut ψ) ↔ OpenTruthAt M σ t (.ofut ψ) :=
  ⟨fun h ρ hρ => h ρ fun s hs => (hag s hs).trans (hρ s hs),
   fun h ρ hρ => h ρ fun s hs => (hag s hs).symm.trans (hρ s hs)⟩

/-- `◁ψ` depends only on the history from `t` onward, for every `OpenFormula` `ψ`: the mirror of
`ofut_pastDet`, and the same constraint on separators for `◁`. -/
theorem opast_futDet (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (hag : AgreeFrom τ σ t) (ψ : OpenFormula) :
    OpenTruthAt M τ t (.opast ψ) ↔ OpenTruthAt M σ t (.opast ψ) :=
  ⟨fun h ρ hρ => h ρ fun s hs => (hag s hs).trans (hρ s hs),
   fun h ρ hρ => h ρ fun s hs => (hag s hs).symm.trans (hρ s hs)⟩

/-! ## The marker gadget

Nested in its own namespace: the identifiers below are deliberately generic, and the enclosing
`FormalSystem.Metalogic.Independence` namespace is shared by every module in this directory. -/

namespace MarkerGadget

/-- The data atom `p`. -/
def dataAtom : Atom := Atom.mkBase "p"

/-- The marker atom `m`. The whole gadget costs exactly this one extra atom. -/
def markerAtom : Atom := Atom.mkBase "m"

/-- Truth of an atom along a world history, as the valuation reads it: the shorthand every
statement below is phrased in. -/
def holds (M : TaskModel F) (τ : WorldHistory F) (s : F.Duration) (a : Atom) : Prop :=
  M.valuation (τ.state s) a

/-- `PlusTruthAt` on an atom is `holds`, by definition of the atomic clause. Tagged `@[simp]` so
the gadget proofs below can read atomic truth off without unfolding. -/
@[simp] theorem holds_iff (M : TaskModel F) (τ : WorldHistory F) (s : F.Duration) (a : Atom) :
    PlusTruthAt M τ s (.atom a) ↔ holds M τ s a := Iff.rfl

/-- `θ := ¬m ∧ ⊞m` — the marker condition: `m` false here and true everywhere strictly later. -/
def theta : PlusFormula :=
  (PlusFormula.atom markerAtom).neg.and (PlusFormula.allFuture (.atom markerAtom))

/-- `ν := θ ∨ ⟡θ` — "the marked point is here or later", i.e. the closed past of the marked
point. -/
def nu : PlusFormula := theta.or (PlusFormula.someFuture theta)

/-- `R := p ∧ ⊞(ν → p)` — membership in the backward `p`-run of the marked point, expressed as a
universal bounded by the definable region `ν` rather than by the run's own lower endpoint. -/
def runAt : PlusFormula :=
  (PlusFormula.atom dataAtom).and (PlusFormula.allFuture (nu.imp (.atom dataAtom)))

/-- `Δ' := S(¬(p ∧ ¬R), ¬p)` — the gap-anchored past property, in L⁺. -/
def delta : PlusFormula :=
  PlusFormula.snce (((PlusFormula.atom dataAtom).and runAt.neg).neg)
    (PlusFormula.atom dataAtom).neg

/-- `φ := θ ∧ Δ'` — the formula fed to the existential dual of `▷`. The marker atom occurs in it
only inside `θ`, which is what makes `dofut_probe_iff` an exact equivalence. -/
def probe : PlusFormula := theta.and delta

/-- `ρ` carries the **marker future** at `t`: `m` is false at `t` and true everywhere after. -/
def MarkedAt (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration) : Prop :=
  ¬ holds M ρ t markerAtom ∧ ∀ s, t < s → holds M ρ s markerAtom

/-- `θ` unfolds to the marker condition read at the point of evaluation. -/
theorem theta_iff (M : TaskModel F) (ρ : WorldHistory F) (s : F.Duration) :
    PlusTruthAt M ρ s theta ↔ MarkedAt M ρ s := by
  rw [theta, PlusTruth.and_iff, PlusTruth.neg_iff, PlusTruth.allFuture_iff]
  exact Iff.rfl

/-- **The gadget.** If `ρ` carries the marker future at `t`, then `θ` is true at exactly `t`: a
definable singleton, on any frame over any duration. This is what makes the point of evaluation
nameable from inside L⁺. -/
theorem theta_eq_iff (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration)
    (h : MarkedAt M ρ t) (s : F.Duration) :
    PlusTruthAt M ρ s theta ↔ s = t := by
  rw [theta_iff]
  constructor
  · rintro ⟨hns, hfs⟩
    rcases lt_trichotomy s t with hst | rfl | hts
    · exact absurd (hfs t hst) h.1
    · rfl
    · exact absurd (h.2 s hts) hns
  · rintro rfl; exact h

/-- Hence `ν` names the closed past `(-∞, t]`. -/
theorem nu_iff_le (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration)
    (h : MarkedAt M ρ t) (v : F.Duration) :
    PlusTruthAt M ρ v nu ↔ v ≤ t := by
  rw [nu, PlusTruth.or_iff, PlusTruth.someFuture_iff]
  constructor
  · rintro (hv | ⟨s, hvs, hs⟩)
    · exact le_of_eq ((theta_eq_iff M ρ t h v).mp hv)
    · exact le_of_lt (((theta_eq_iff M ρ t h s).mp hs) ▸ hvs)
  · intro hvt
    rcases lt_or_eq_of_le hvt with hlt | heq
    · exact Or.inr ⟨t, hlt, (theta_eq_iff M ρ t h t).mpr rfl⟩
    · exact Or.inl ((theta_eq_iff M ρ t h v).mpr heq)

/-- `v` lies in the backward `p`-run of `t`: `p` holds throughout `[v, t]`. -/
def PRun (M : TaskModel F) (ρ : WorldHistory F) (v t : F.Duration) : Prop :=
  holds M ρ v dataAtom ∧ ∀ s, v < s → s ≤ t → holds M ρ s dataAtom

/-- **The run is definable.** Under the marker, `R` holds at `v` iff `v` is in the backward
`p`-run of `t` — with no appeal to a lower endpoint of that run, which over a dense,
non-Dedekind-complete duration is a gap. This is the step `U`/`S` cannot take on its own. -/
theorem run_iff (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration)
    (h : MarkedAt M ρ t) (v : F.Duration) :
    PlusTruthAt M ρ v runAt ↔ PRun M ρ v t := by
  rw [runAt, PlusTruth.and_iff, PlusTruth.allFuture_iff]
  refine and_congr Iff.rfl (forall_congr' fun s => imp_congr_right fun hvs => ?_)
  rw [PlusTruth.imp_iff]
  exact ⟨fun hs hst => hs ((nu_iff_le M ρ t h s).mpr hst),
    fun hs hnu => hs ((nu_iff_le M ρ t h s).mp hnu)⟩

/-- **The gap-anchored past property**: there is a `¬p` point `u < t` such that every `p` point
strictly between `u` and `t` already lies in the backward `p`-run of `t`. Equivalently: the
`p`-run of `t` is immediately preceded by a stretch of `¬p`, with no further `p`-run accumulating
at the run's lower gap. -/
def DeltaProp (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) : Prop :=
  ∃ u, u < t ∧ ¬ holds M τ u dataAtom ∧
    ∀ v, u < v → v < t → holds M τ v dataAtom → PRun M τ v t

/-- Under the marker, `Δ'` says exactly `DeltaProp`. -/
theorem delta_iff (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration)
    (h : MarkedAt M ρ t) :
    PlusTruthAt M ρ t delta ↔ DeltaProp M ρ t := by
  rw [delta, PlusTruth.snce_iff]
  refine exists_congr fun u => and_congr_right fun _ => ?_
  rw [PlusTruth.neg_iff]
  refine and_congr Iff.rfl (forall_congr' fun v => imp_congr_right fun huv =>
    imp_congr_right fun hvt => ?_)
  rw [PlusTruth.neg_iff, PlusTruth.and_iff, PlusTruth.neg_iff, run_iff M ρ t h v]
  exact ⟨fun hnot hp => not_not.mp fun hnr => hnot ⟨hp, hnr⟩,
    fun himp hc => hc.2 (himp hc.1)⟩

/-- `DeltaProp` is past-determined, as it must be if `▷` is to compute it (`ofut_pastDet`). -/
theorem deltaProp_pastDet (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (hag : AgreeUpTo τ σ t) : DeltaProp M τ t ↔ DeltaProp M σ t := by
  have key : ∀ (ρ ρ' : WorldHistory F), AgreeUpTo ρ ρ' t → DeltaProp M ρ t → DeltaProp M ρ' t := by
    intro ρ ρ' hag' ⟨u, hut, hnp, hrun⟩
    refine ⟨u, hut, ?_, fun v huv hvt hp => ?_⟩
    · change ¬ M.valuation _ dataAtom
      rw [← hag' u (le_of_lt hut)]; exact hnp
    · have hpv : holds M ρ v dataAtom := by
        change M.valuation _ dataAtom; rw [hag' v (le_of_lt hvt)]; exact hp
      obtain ⟨h1, h2⟩ := hrun v huv hvt hpv
      refine ⟨hp, fun s hvs hst => ?_⟩
      change M.valuation _ dataAtom; rw [← hag' s hst]; exact h2 s hvs hst
  exact ⟨key τ σ hag, key σ τ fun s hs => (hag s hs).symm⟩

/-- **The main computation.** On any frame, at any `(M, τ, t)` where `m` is false at the present
state and at least one world with `τ`'s past carries the marker future:

```
(∃ ρ ∈ |τ⟩_t, PlusTruthAt M ρ t φ)  ↔  DeltaProp M τ t.
```

`→` reads the marker out of `θ` and transfers `Δ'` back along `AgreeUpTo`; `←` installs the
marker. Nothing about the chosen world beyond the marker is used, so the equivalence is exact:
`▷` computes `DeltaProp` with no slack. -/
theorem dofut_probe_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (hm : ¬ holds M τ t markerAtom)
    (hex : ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s markerAtom) :
    (∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ PlusTruthAt M ρ t probe) ↔ DeltaProp M τ t := by
  constructor
  · rintro ⟨ρ, hag, hp⟩
    rw [probe, PlusTruth.and_iff] at hp
    have hmk : MarkedAt M ρ t := (theta_iff M ρ t).mp hp.1
    exact (deltaProp_pastDet M ρ τ t
      (fun s hs => (hag s hs).symm)).mp ((delta_iff M ρ t hmk).mp hp.2)
  · intro hΔ
    obtain ⟨ρ, hag, hmark⟩ := hex
    have hmk : MarkedAt M ρ t := by
      refine ⟨?_, hmark⟩
      change ¬ M.valuation _ markerAtom
      rw [← hag t le_rfl]; exact hm
    refine ⟨ρ, hag, ?_⟩
    rw [probe, PlusTruth.and_iff]
    exact ⟨(theta_iff M ρ t).mpr hmk,
      (delta_iff M ρ t hmk).mpr ((deltaProp_pastDet M τ ρ t hag).mp hΔ)⟩

/-- The same fact in `▷` form, inside L^▷: `▷(¬φ) ↔ ¬DeltaProp`. The `▷`-level unfolding is the
companion module's `ofutP_iff`, which is where that bridge lives. -/
theorem ofut_neg_probe_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (hm : ¬ holds M τ t markerAtom)
    (hex : ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s markerAtom) :
    OpenTruthAt M τ t (.ofut (ofPlus probe.neg)) ↔ ¬ DeltaProp M τ t := by
  rw [← dofut_probe_iff M τ t hm hex, ofutP_iff M τ t probe.neg]
  constructor
  · rintro h ⟨ρ, hag, hp⟩
    exact (h ρ hag) hp
  · intro h ρ hag
    exact fun hp => h ⟨ρ, hag, hp⟩

/-- **The gadget is not vacuous.** Under the marker, `Δ'` at `t` is witnessed whenever some `¬p`
time `u < t` has `p` false throughout `(u, t)` — the degenerate shape of `DeltaProp`. Recorded so
that `DeltaProp` is visibly not an empty condition. -/
theorem deltaProp_of_no_p_between (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {u : F.Duration} (hut : u < t) (hnp : ¬ holds M τ u dataAtom)
    (hclear : ∀ v, u < v → v < t → ¬ holds M τ v dataAtom) :
    DeltaProp M τ t :=
  ⟨u, hut, hnp, fun v huv hvt hp => absurd hp (hclear v huv hvt)⟩

end MarkerGadget

open MarkerGadget

/-! ## The non-definability theorem -/

/-- **`▷`/`◁` are L⁺-definable at `F`**: there is a translation of the whole of L^▷ into L⁺
preserving truth at every model, world history and time of `F`.

This is the **truth**-level notion, and it is the weaker, correct target for a negative result:
the companion module's `openTruthAt_iff_tr`
(`Metalogic/Expressiveness/OpenFutureElimination.lean`) is the positive instance of exactly this
notion at `.ZTime` and `.RTime`. Nothing proved here refutes a validity-level-only translation,
which is the one thing the verdict does not settle. -/
def OfutPlusDefinable (F : TaskFrame) : Prop :=
  ∃ tr : OpenFormula → PlusFormula, ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula), OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr φ)

/-- **If `DeltaProp` is not L⁺-expressible at `F`, then `▷` is not L⁺-definable at `F`.**

Both hypotheses are named for what they are.

`hmarkers` is the frame's **enough-worlds** condition: from any present state with `m` false there
is a world with the same past carrying the marker future. As stated here it quantifies over
*every* model of `F`, and in that form it is false at every frame — a valuation sending
`markerAtom` to `False` at every state admits no history carrying the marker future at all. What
holds is the condition at the **intended** valuation: at `colourFibre D`, under `markerModel D`,
it is compiled below as `colourFibre_hmarkers`, since that frame's histories are the arbitrary
colour functions with a clock offset and the marker future is just another colour function. The
form that consumes that discharge is
`ofut_not_plusDefinable_of_deltaProp_inexpressible_at`, which fixes one model; this theorem's
all-models hypothesis is strictly stronger and is kept as stated.

`hinexpr` is **the paper step of record**. It was discharged in the research round for the
permissive frame over a dense, non-Dedekind-complete duration by a collapse argument in the style
of [GHR][gabbay1994] vol. 1, Lemma 12.4.2 — derived rather than quoted, and transposed from their
flow — together with the two separating structures of run order type `ℤ` and `ω + 1 + ω`. It is
**not formalized in this tree**, so the unconditional `.Base`/`.Dense` verdict is not
machine-checked here; only this reduction is.

Paper: — (formalization-native; the manuscript states no definability question for the restricted
modals and supplies no witness frame) -/
theorem ofut_not_plusDefinable_of_deltaProp_inexpressible
    (hmarkers : ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
      ¬ holds M τ t markerAtom →
        ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s markerAtom)
    (hinexpr : ∀ ψ : PlusFormula, ∃ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
      ¬ holds M τ t markerAtom ∧ ¬ (DeltaProp M τ t ↔ PlusTruthAt M τ t ψ)) :
    ¬ OfutPlusDefinable F := by
  rintro ⟨tr, htr⟩
  obtain ⟨M, τ, t, hm, hbad⟩ := hinexpr (tr (.ofut (ofPlus probe.neg))).neg
  refine hbad ?_
  rw [PlusTruth.neg_iff, ← htr M τ t (.ofut (ofPlus probe.neg)),
    ofut_neg_probe_iff M τ t hm (hmarkers M τ t hm)]
  exact (not_not).symm

/-- **The same reduction at one fixed model.** Both hypotheses are stated at a single given `M`,
which is all the proof ever uses: `hinexpr` hands back a model, and the all-models form of
`hmarkers` is only ever applied at that one.

This is the form that can actually be discharged at a concrete frame. The all-models `hmarkers`
of `ofut_not_plusDefinable_of_deltaProp_inexpressible` is strictly stronger and, read literally,
false at every frame: a valuation sending `markerAtom` to `False` at every state admits no
history carrying the marker future. What holds at a witness frame is the condition *under the
intended valuation*, and that is exactly what this variant asks for — see
`colourFibre_hmarkers`.

Paper: — (formalization-native) -/
theorem ofut_not_plusDefinable_of_deltaProp_inexpressible_at (M : TaskModel F)
    (hmarkers : ∀ (τ : WorldHistory F) (t : F.Duration),
      ¬ holds M τ t markerAtom →
        ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s markerAtom)
    (hinexpr : ∀ ψ : PlusFormula, ∃ (τ : WorldHistory F) (t : F.Duration),
      ¬ holds M τ t markerAtom ∧ ¬ (DeltaProp M τ t ↔ PlusTruthAt M τ t ψ)) :
    ¬ OfutPlusDefinable F := by
  rintro ⟨tr, htr⟩
  obtain ⟨τ, t, hm, hbad⟩ := hinexpr (tr (.ofut (ofPlus probe.neg))).neg
  refine hbad ?_
  rw [PlusTruth.neg_iff, ← htr M τ t (.ofut (ofPlus probe.neg)),
    ofut_neg_probe_iff M τ t hm (hmarkers τ t hm)]
  exact (not_not).symm

/-! ## The witness frame: four colours on a clock, over any temporal order

`hmarkers` is not an idle hypothesis, but the obvious way to satisfy it is blocked, and the
obstruction is worth recording.

*Limit* forbids the naive permissive rational-time frame. At a frame whose world states are the
atom colours alone, `R w y u` must fail for all small `|y|` whenever `u ≠ w`, so over a dense
duration a history with finitely many states is a step function with a uniform minimum step:
nothing accumulates, and there is therefore no gap for `Δ'` to be anchored at. The obstruction was
the *frame*, not the duration.

The repository's own `colourClock` (`Semantics/Frames/TranslationProduct.lean`) removes it: the
clock component discharges *Limit* (`prodRel_limit`) and finiteness of the colour set discharges
*Saturation* (`cor:saturation-finite`). Taking the colour relation that is free at every nonzero
duration gives a **regular** four-colour frame over every temporal order, whose world histories
are the arbitrary colour functions with a clock offset — over a dense carrier as readily as over a
discrete one. -/

section WitnessFrame

variable {D : TemporalOrder}

/-- The four colours: one bit for the data atom `p`, one for the marker atom `m`. Finiteness is
what discharges *Saturation* for `colourFibre`. -/
abbrev MarkerColour := Bool × Bool

/-- The base colour relation: free at every nonzero duration, the identity at zero. -/
def cRel : MarkerColour → ↑D → MarkerColour → Prop := fun w d u => d = 0 → u = w

/-- `cRel` is reflective: relating `w` to `u` across `d` is relating `u` to `w` across `-d`. One
of the four inputs `colourClock` consumes. -/
theorem cRel_reflection : ∀ w (d : ↑D) u, cRel w d u ↔ cRel u (-d) w := by
  intro w d u
  constructor
  · intro h hd; exact (h (neg_eq_zero.mp hd)).symm
  · intro h hd; exact (h (by rw [hd, neg_zero])).symm

/-- `cRel` is compositional: a `cRel`-step across `x + y` factors through an intermediate colour,
and conversely. The nonzero case is free; the zero case forces both summands to vanish. One of the
four inputs `colourClock` consumes. -/
theorem cRel_comp : TaskFrame.Compositional (cRel (D := D)) := by
  intro w v x y hx hy
  constructor
  · intro h
    by_cases hx0 : x = 0
    · subst hx0
      refine ⟨w, fun _ => rfl, fun hy0 => ?_⟩
      exact h (by rw [hy0, add_zero])
    · exact ⟨v, fun h' => absurd h' hx0, fun _ => rfl⟩
  · rintro ⟨u, h1, h2⟩ hxy
    have hxle : x ≤ 0 := by
      have : x ≤ x + y := le_add_of_nonneg_right hy
      rwa [hxy] at this
    have hx0 : x = 0 := le_antisymm hxle hx
    have hy0 : y = 0 := by
      have : y = x + y := by rw [hx0, zero_add]
      rw [this, hxy]
    rw [h2 hy0, h1 hx0]

/-- `cRel` is serial in both directions: every colour relates to itself across every duration.
One of the four inputs `colourClock` consumes. -/
theorem cRel_serial : TaskFrame.Serial (cRel (D := D)) :=
  fun w _ _ => ⟨⟨w, fun _ => rfl⟩, ⟨w, fun _ => rfl⟩⟩

/-- `cRel` has trivial zero-fibres: at duration `0` it is the identity. One of the four inputs
`colourClock` consumes, and the one that lets the clock discharge *Limit*. -/
theorem cRel_zero : ∀ w u, cRel (D := D) w 0 u → u = w := fun _ _ h => h rfl

/-- **The witness frame**: four colours on a clock over `D`. Its histories are the arbitrary
colour functions with a clock offset (`colourFibre.ofColourFun`), so the marker future is just
another history and the enough-worlds condition holds at it under the intended valuation
`markerModel D` — compiled as `colourFibre_hmarkers`, and consumed by
`ofut_not_plusDefinable_of_deltaProp_inexpressible_at`. -/
def colourFibre (D : TemporalOrder) : FrameOver D :=
  colourClock (W := MarkerColour) cRel cRel_reflection cRel_comp cRel_serial cRel_zero

/-- **The four-colour clock frame is regular over every temporal order.** The clock component
discharges *Limit* and finiteness of `MarkerColour` discharges *Saturation*, so the four
conditions `cRel_reflection`, `cRel_comp`, `cRel_serial` and `cRel_zero` are its entire input.

This is what removes the *Limit* obstruction recorded above: with states taken to be the colours
alone, a finite-state history over a dense duration would be a uniformly discrete step function
with nothing accumulating and so no gap for `Δ'` to anchor at; the clock keeps the frame regular
while restoring the accumulation.

Paper: — (formalization-native; the manuscript states no definability question for the restricted
modals and supplies no witness frame) -/
instance colourFibre_isRegular : (colourFibre D).IsRegular :=
  colourClock_isRegular (W := MarkerColour) cRel cRel_reflection cRel_comp cRel_serial cRel_zero

/-! ### The intended valuation, and the enough-worlds condition compiled

`hmarkers` is not a property of a frame alone: it quantifies over models, and at a valuation that
never makes `m` true it fails at every frame. The condition that *does* hold at `colourFibre` is
the one at its intended valuation, where the two colour bits are read as the two atoms. That is
what `markerModel` fixes and `colourFibre_hmarkers` compiles. -/

/-- The two probe atoms are distinct: they are `Atom.mkBase` of distinct string literals. Stated
as a named `@[simp]` lemma so the valuation's simp set carries it, rather than leaving each proof
to rediscover it by `decide`. -/
@[simp] theorem markerAtom_ne_dataAtom : markerAtom ≠ dataAtom := by decide

/-- **The intended valuation** on the four-colour clock: the first colour bit is the data atom
`p`, the second is the marker atom `m`, and every other atom is false everywhere. The clock
component is ignored, as it must be — sentence letters denote sets of world states, and the clock
is not part of a colour. -/
def markerValuation : MarkerColour × ↑D → Atom → Prop :=
  fun s a => (a = dataAtom ∧ s.1.1 = true) ∨ (a = markerAtom ∧ s.1.2 = true)

/-- **The intended model** on the witness frame: `colourFibre D` under `markerValuation`. -/
def markerModel (D : TemporalOrder) : TaskModel (colourFibre D).toTaskFrame :=
  { valuation := markerValuation }

/-- `cRel` is free at every nonzero duration: its only constraint is at `0`. This is what makes
every colour function a history (`colourClock.ofFreeColourFun`). -/
theorem cRel_free (w : MarkerColour) (d : ↑D) (u : MarkerColour) (hd : d ≠ 0) :
    cRel (D := D) w d u := fun hd0 => absurd hd0 hd

/-- **Every colour function is a history of the witness frame**, at any clock offset:
`colourClock.ofFreeColourFun` instantiated at `cRel`, whose freeness away from `0` is
`cRel_free`. -/
def colourFibre.ofColourFun (f : ↑D → MarkerColour) (c : ↑D) :
    WorldHistory (colourFibre D).toTaskFrame :=
  colourClock.ofFreeColourFun (W := MarkerColour) cRel cRel_reflection cRel_comp cRel_serial
    cRel_zero (fun w d u hd => cRel_free w d u hd) f c

/-- The state of a colour-function history of the witness frame. -/
@[simp] theorem colourFibre.ofColourFun_state (f : ↑D → MarkerColour) (c t : ↑D) :
    (colourFibre.ofColourFun f c).state t = (f t, c + t) := rfl

/-- **The enough-worlds condition, compiled at `colourFibre` under the intended valuation.**

Given any history `τ` and time `t` at which `m` is false, the witness is the colour function that
copies `τ`'s colours up to `t` and, after `t`, keeps `τ`'s data bit but sets the marker bit —
a colour function like any other, hence a history by `colourFibre.ofColourFun`. Agreement up to
`t` is the first branch of the `if` together with `colourClock_clock_eq`, which pins the clock
component of every history of the frame to `(τ.state 0).2 + s`; the marker future is the literal
`true` in the second branch.

The `¬ holds` hypothesis is named for the shape
`ofut_not_plusDefinable_of_deltaProp_inexpressible_at` consumes and is not used: the witness
exists at *every* `(τ, t)` of this frame, marker bit or not, because the marker future is simply
another colour function. Hence the underscore on its binder.

This is the step `colourFibre`'s docstring states below, now compiled.

Paper: — (formalization-native) -/
theorem colourFibre_hmarkers (τ : WorldHistory (colourFibre D).toTaskFrame) (t : ↑D)
    (_hm : ¬ holds (markerModel D) τ t markerAtom) :
    ∃ ρ : WorldHistory (colourFibre D).toTaskFrame, AgreeUpTo τ ρ t ∧
      ∀ s, t < s → holds (markerModel D) ρ s markerAtom := by
  refine ⟨colourFibre.ofColourFun
      (fun s => if s ≤ t then (τ.state s).1 else ((τ.state s).1.1, true)) (τ.state 0).2,
    fun s hs => ?_, fun s hts => ?_⟩
  · have hst : (colourFibre.ofColourFun
        (fun s => if s ≤ t then (τ.state s).1 else ((τ.state s).1.1, true))
        (τ.state 0).2).state s = ((τ.state s).1, (τ.state 0).2 + s) := by
      rw [colourFibre.ofColourFun_state, if_pos hs]
    rw [hst]
    exact Prod.ext rfl
      (colourClock_clock_eq cRel cRel_reflection cRel_comp cRel_serial cRel_zero τ s)
  · refine Or.inr ⟨rfl, ?_⟩
    rw [colourFibre.ofColourFun_state, if_neg (not_le.mpr hts)]

/-- **The reduction at the witness frame, with the enough-worlds condition discharged.** The one
remaining hypothesis is `hinexpr`, the paper step of record: that `DeltaProp` is not
L⁺-expressible at `colourFibre D` under the intended valuation.

This is *not* an unconditional non-definability verdict. It is the reduction with one of its two
hypotheses now compiled rather than assumed.

Paper: — (formalization-native) -/
theorem colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible
    (hinexpr : ∀ ψ : PlusFormula,
      ∃ (τ : WorldHistory (colourFibre D).toTaskFrame) (t : ↑D),
        ¬ holds (markerModel D) τ t markerAtom ∧
          ¬ (DeltaProp (markerModel D) τ t ↔ PlusTruthAt (markerModel D) τ t ψ)) :
    ¬ OfutPlusDefinable (colourFibre D).toTaskFrame :=
  ofut_not_plusDefinable_of_deltaProp_inexpressible_at (markerModel D)
    (fun τ t hm => colourFibre_hmarkers τ t hm) hinexpr

end WitnessFrame

end FormalSystem.Metalogic.Independence
