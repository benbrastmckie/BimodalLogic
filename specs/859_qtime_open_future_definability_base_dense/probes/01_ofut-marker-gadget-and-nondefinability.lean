import FormalSystem.OpenLanguage
import FormalSystem.Semantics.Frames.TranslationProduct

/-!
# Probe 01: the marker gadget, and `▷` reaches a gap-anchored past property

**Compiled-live**: everything below is stated against the repository's own `OpenTruthAt`,
`PlusTruthAt`, `AgreeUpTo`/`AgreeFrom` and `ofPlus`, not against a mirror. No faithfulness
audit is owed.

## The problem this probe attacks

At `.ZTime`/`.RTime`, `▷` is L⁺-definable through Gabbay separation. Over a non-Dedekind-complete
duration that route is closed (U/S is not separable over `ℚ`), and the open question was whether
`▷` is nonetheless definable at `.Base`/`.Dense`. A negative answer needs an L⁺ formula `φ` and a
pointed-model pair that L⁺ cannot tell apart but `▷φ` can. The obstruction to building one was
that nobody knew what `▷` could *reach*: `▷ψ` is past-determined, so it can only ever express
pure-past properties, and all the known U/S-inexpressible properties (Stavi's `U'`, GHR's
`γ₀⁺`/`γ_π⁺`) are stated with a quantifier ranging over an interval whose endpoint is a **gap**,
which U/S has no way to anchor.

## The gadget

This probe supplies the missing anchor. Work with two atoms, `p` (the data atom) and `m` (the
marker). Put

```
θ  :=  ¬m ∧ ⊞m                 (`⊞` = `allFuture`)
ν  :=  θ ∨ ⟡θ                  (`⟡` = `someFuture`)
R  :=  p ∧ ⊞(ν → p)
Δ' :=  S(¬(p ∧ ¬R), ¬p)
φ  :=  θ ∧ Δ'
```

1. **`theta_eq_iff`** — in any model, on any frame, over any duration: if `m` is false at `t` and
   true at every time after `t`, then `θ` holds at `s` **iff `s = t`**. So `θ` is a definable
   singleton: the evaluation point is nameable from inside the language.
2. **`nu_iff_le`** — hence `ν` holds at `v` iff `v ≤ t`: the closed past `(-∞, t]` is a definable
   region.
3. **`run_iff`** — hence `R` holds at `v ≤ t` iff `p` holds throughout `[v, t]`: membership in the
   backward `p`-run of `t` is definable, *including when that run's lower endpoint is a gap*. This
   is the step U/S cannot take on its own — `R` is not `U(p, ·)`; it is a bounded-below universal
   over a region named by `ν`.
4. **`delta_iff`** — hence `Δ'` holds at `t` iff: there is `u < t` with `¬p` at `u` such that every
   `p`-point of `(u, t)` already lies in the backward `p`-run of `t` (`DeltaProp`).

`DeltaProp` is the ℚ-time shape of GHR's isolation condition on a left `p` gap: it says the
`p`-run of `t` is *immediately preceded* by a stretch of `¬p`, with no `p`-run accumulating at the
run's lower gap.

## What this buys

`m` appears in `φ` only inside `θ`, and `θ` is exactly the marker condition. So the **existential**
dual of `▷` — `¬▷¬φ`, "some world with this past makes `φ` true" — can choose the marker, and
nothing else about the chosen world matters:

**`dofut_probe_iff`**: on any frame, at any `(M, τ, t)` with `m` false at `τ(t)` and at least one
world in `|τ⟩_t` carrying the marker future,

```
(∃ ρ ∈ |τ⟩_t, PlusTruthAt M ρ t φ)  ↔  DeltaProp M τ t.
```

Equivalently `▷(¬φ) ↔ ¬DeltaProp` (`ofut_neg_probe_iff`). So `▷` **computes `DeltaProp`** — exactly,
with no slack, on every frame with enough worlds. Together with
`not_definable_of_deltaProp_inexpressible`, any frame on which `DeltaProp` is not L⁺-expressible
refutes definability of `▷` there.

## What is NOT proved here, and where it comes from

That `DeltaProp` is not L⁺-expressible on a particular frame. The research report gives the
argument in full for the permissive frame over `ℚ` (all functions `ℚ → WorldState` are worlds, so
`⊡`/`□` collapse to Boolean functions of the present state by translation invariance, and every
L⁺ formula collapses to one of `p, ¬p, ⊤, ⊥` on GHR-nice structures — their Lemma 12.4.2
computation, transposed from their flow `T` to `ℚ`), together with the two nice ℚ-structures that
`DeltaProp` separates. That half is UNVERIFIED in Lean and is the paper step of record.

Also recorded here, because they are what constrains any such attempt:
`ofut_pastDet` / `opast_futDet` — `▷ψ` depends only on `τ|(-∞,t]` and `◁ψ` only on `τ|[t,∞)`, for
*every* `OpenFormula` `ψ`. A separator for `▷` must therefore be a pair of worlds with
L⁺-indistinguishable but `DeltaProp`-distinguishable **pasts**; a pair differing only in the future
cannot work, whatever it does to the Stavi connectives.

## Compile

```
LP=.lake/build/lib/lean; for d in .lake/packages/*/.lake/build/lib/lean; do LP="$LP:$d"; done
LEAN_PATH="$LP" ~/.elan/toolchains/leanprover--lean4---v4.33.0-rc1/bin/lean \
  specs/859_qtime_open_future_definability_base_dense/probes/01_ofut-marker-gadget-and-nondefinability.lean
```
-/

namespace Probe859R01

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage

variable {F : TaskFrame}

/-! ## `▷` is past-determined and `◁` is future-determined

Recorded first because it is what rules out whole families of separator attempts: these hold for
*every* `OpenFormula`, by one unfolding of the clause plus transitivity of agreement. -/

/-- `▷ψ` depends only on the history up to and including `t`. -/
theorem ofut_pastDet (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (hag : AgreeUpTo τ σ t) (ψ : OpenFormula) :
    OpenTruthAt M τ t (.ofut ψ) ↔ OpenTruthAt M σ t (.ofut ψ) :=
  ⟨fun h ρ hρ => h ρ fun s hs => (hag s hs).trans (hρ s hs),
   fun h ρ hρ => h ρ fun s hs => (hag s hs).symm.trans (hρ s hs)⟩

/-- `◁ψ` depends only on the history from `t` onward. -/
theorem opast_futDet (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (hag : AgreeFrom τ σ t) (ψ : OpenFormula) :
    OpenTruthAt M τ t (.opast ψ) ↔ OpenTruthAt M σ t (.opast ψ) :=
  ⟨fun h ρ hρ => h ρ fun s hs => (hag s hs).trans (hρ s hs),
   fun h ρ hρ => h ρ fun s hs => (hag s hs).symm.trans (hρ s hs)⟩

/-! ## The two probe atoms and the gadget formulas -/

/-- The data atom. -/
def pAtom : Atom := ⟨"p", none⟩

/-- The marker atom. -/
def mAtom : Atom := ⟨"m", none⟩

/-- Truth of an atom along a world, as the valuation reads it. -/
def holds (M : TaskModel F) (τ : WorldHistory F) (s : F.Duration) (a : Atom) : Prop :=
  M.valuation (τ.state s) a

@[simp] theorem holds_iff (M : TaskModel F) (τ : WorldHistory F) (s : F.Duration) (a : Atom) :
    PlusTruthAt M τ s (.atom a) ↔ holds M τ s a := Iff.rfl

/-- `θ := ¬m ∧ ⊞m` — the marker condition. -/
def theta : PlusFormula := (PlusFormula.atom mAtom).neg.and (PlusFormula.allFuture (.atom mAtom))

/-- `ν := θ ∨ ⟡θ` — "the marked point is here or later", i.e. the closed past. -/
def nu : PlusFormula := theta.or (PlusFormula.someFuture theta)

/-- `R := p ∧ ⊞(ν → p)` — membership in the backward `p`-run of the marked point. -/
def runAt : PlusFormula := (PlusFormula.atom pAtom).and
  (PlusFormula.allFuture (nu.imp (.atom pAtom)))

/-- `Δ' := S(¬(p ∧ ¬R), ¬p)` — the gap-anchored past property. -/
def delta : PlusFormula :=
  PlusFormula.snce (((PlusFormula.atom pAtom).and runAt.neg).neg) (PlusFormula.atom pAtom).neg

/-- `φ := θ ∧ Δ'` — the formula fed to the existential dual of `▷`. -/
def probe : PlusFormula := theta.and delta

/-! ## The marker -/

/-- `ρ` carries the **marker future** at `t`: `m` is false at `t` and true everywhere after. -/
def MarkedAt (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration) : Prop :=
  ¬ holds M ρ t mAtom ∧ ∀ s, t < s → holds M ρ s mAtom

/-- `θ` unfolds to the marker condition read at the point of evaluation. -/
theorem theta_iff (M : TaskModel F) (ρ : WorldHistory F) (s : F.Duration) :
    PlusTruthAt M ρ s theta ↔ MarkedAt M ρ s := by
  rw [theta, PlusTruth.and_iff, PlusTruth.neg_iff, PlusTruth.allFuture_iff]
  exact Iff.rfl

/-- **The gadget.** If `ρ` carries the marker future at `t`, then `θ` is true at exactly `t`:
a definable singleton, on any frame over any duration. -/
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
  holds M ρ v pAtom ∧ ∀ s, v < s → s ≤ t → holds M ρ s pAtom

/-- **The run is definable.** Under the marker, `R` holds at `v` iff `v` is in the backward
`p`-run of `t` — with no appeal to a lower endpoint of that run, which over `ℚ` is a gap. -/
theorem run_iff (M : TaskModel F) (ρ : WorldHistory F) (t : F.Duration)
    (h : MarkedAt M ρ t) (v : F.Duration) :
    PlusTruthAt M ρ v runAt ↔ PRun M ρ v t := by
  rw [runAt, PlusTruth.and_iff, PlusTruth.allFuture_iff]
  refine and_congr Iff.rfl (forall_congr' fun s => imp_congr_right fun hvs => ?_)
  rw [PlusTruth.imp_iff]
  exact ⟨fun hs hst => hs ((nu_iff_le M ρ t h s).mpr hst),
    fun hs hnu => hs ((nu_iff_le M ρ t h s).mp hnu)⟩

/-! ## The property `▷` computes -/

/-- **`DeltaProp`** — the ℚ-time isolation condition: there is a `¬p` point `u < t` such that every
`p` point strictly between `u` and `t` already lies in the backward `p`-run of `t`. Equivalently:
the `p`-run of `t` is immediately preceded by a stretch of `¬p`, with no further `p`-run
accumulating at the run's lower gap. -/
def DeltaProp (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration) : Prop :=
  ∃ u, u < t ∧ ¬ holds M τ u pAtom ∧
    ∀ v, u < v → v < t → holds M τ v pAtom → PRun M τ v t

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

/-- `DeltaProp` is past-determined, as it must be if `▷` is to compute it. -/
theorem deltaProp_pastDet (M : TaskModel F) (τ σ : WorldHistory F) (t : F.Duration)
    (hag : AgreeUpTo τ σ t) : DeltaProp M τ t ↔ DeltaProp M σ t := by
  have key : ∀ (ρ ρ' : WorldHistory F), AgreeUpTo ρ ρ' t → DeltaProp M ρ t → DeltaProp M ρ' t := by
    intro ρ ρ' hag' ⟨u, hut, hnp, hrun⟩
    refine ⟨u, hut, ?_, fun v huv hvt hp => ?_⟩
    · change ¬ M.valuation _ pAtom
      rw [← hag' u (le_of_lt hut)]; exact hnp
    · have hpv : holds M ρ v pAtom := by
        change M.valuation _ pAtom; rw [hag' v (le_of_lt hvt)]; exact hp
      obtain ⟨h1, h2⟩ := hrun v huv hvt hpv
      refine ⟨hp, fun s hvs hst => ?_⟩
      change M.valuation _ pAtom; rw [← hag' s hst]; exact h2 s hvs hst
  exact ⟨key τ σ hag, key σ τ fun s hs => (hag s hs).symm⟩

/-! ## `▷` computes `DeltaProp`

`m` occurs in `probe` only through `θ`, and `θ` is the marker condition itself. So the existential
dual of `▷` gets to install the marker for free. -/

/-- **The main computation.** On any frame, at any `(M, τ, t)` where `m` is false at the present
state and at least one world with `τ`'s past carries the marker future:

```
(∃ ρ ∈ |τ⟩_t, PlusTruthAt M ρ t φ)  ↔  DeltaProp M τ t.
```

`→` reads the marker out of `θ` and transfers `Δ'` back along `AgreeUpTo`; `←` installs the
marker. Nothing about the chosen world beyond the marker is used, so the equivalence is exact. -/
theorem dofut_probe_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (hm : ¬ holds M τ t mAtom)
    (hex : ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s mAtom) :
    (∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ PlusTruthAt M ρ t probe) ↔ DeltaProp M τ t := by
  constructor
  · rintro ⟨ρ, hag, hp⟩
    rw [probe, PlusTruth.and_iff] at hp
    have hmk : MarkedAt M ρ t := (theta_iff M ρ t).mp hp.1
    exact (deltaProp_pastDet M ρ τ t (fun s hs => (hag s hs).symm)).mp ((delta_iff M ρ t hmk).mp hp.2)
  · intro hΔ
    obtain ⟨ρ, hag, hmark⟩ := hex
    have hmk : MarkedAt M ρ t := by
      refine ⟨?_, hmark⟩
      change ¬ M.valuation _ mAtom
      rw [← hag t le_rfl]; exact hm
    refine ⟨ρ, hag, ?_⟩
    rw [probe, PlusTruth.and_iff]
    exact ⟨(theta_iff M ρ t).mpr hmk,
      (delta_iff M ρ t hmk).mpr ((deltaProp_pastDet M τ ρ t hag).mp hΔ)⟩

/-- The same fact in `▷` form, inside L^▷: `▷(¬φ) ↔ ¬DeltaProp`. -/
theorem ofut_neg_probe_iff (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (hm : ¬ holds M τ t mAtom)
    (hex : ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s mAtom) :
    OpenTruthAt M τ t (.ofut (ofPlus probe.neg)) ↔ ¬ DeltaProp M τ t := by
  rw [← dofut_probe_iff M τ t hm hex]
  constructor
  · rintro h ⟨ρ, hag, hp⟩
    exact ((openTruthAt_ofPlus M ρ t probe.neg).mp (h ρ hag)) hp
  · intro h ρ hag
    exact (openTruthAt_ofPlus M ρ t probe.neg).mpr fun hp => h ⟨ρ, hag, hp⟩

/-! ## The non-definability theorem -/

/-- **`▷`/`◁` are L⁺-definable at a frame**: a truth-preserving translation of the whole of L^▷
into L⁺, at every model, world and time of that frame. This is the notion the class-level
`openValidIn_iff_tr` results of the ZTime/RTime round are instances of. -/
def Definable (F : TaskFrame) : Prop :=
  ∃ tr : OpenFormula → PlusFormula, ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula), OpenTruthAt M τ t φ ↔ PlusTruthAt M τ t (tr φ)

/-- **If `DeltaProp` is not L⁺-expressible at `F`, then `▷` is not definable at `F`.**

`hmarkers` is the frame's "enough worlds" condition: from any present state with `m` false there
is a world with the same past carrying the marker future. It holds on any permissive frame.
`hinexpr` is the paper step of record, discharged in the report for the permissive frame over
`ℚ` by a GHR Lemma 12.4.2-style collapse argument. -/
theorem not_definable_of_deltaProp_inexpressible
    (hmarkers : ∀ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
      ¬ holds M τ t mAtom →
        ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s mAtom)
    (hinexpr : ∀ ψ : PlusFormula, ∃ (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration),
      ¬ holds M τ t mAtom ∧ ¬ (DeltaProp M τ t ↔ PlusTruthAt M τ t ψ)) :
    ¬ Definable F := by
  rintro ⟨tr, htr⟩
  obtain ⟨M, τ, t, hm, hbad⟩ := hinexpr (tr (.ofut (ofPlus probe.neg))).neg
  refine hbad ?_
  rw [PlusTruth.neg_iff, ← htr M τ t (.ofut (ofPlus probe.neg)),
    ofut_neg_probe_iff M τ t hm (hmarkers M τ t hm)]
  exact (not_not).symm


/-! ## The witness frame: four colours on a clock, over any duration

`hmarkers` is not an idle hypothesis. `colourClock` (`Semantics/Frames/TranslationProduct.lean`)
turns any finite reflective, serial, compositional relation with trivial zero-fibres into a
*regular* frame over **any** temporal order — the clock discharges *Limit*, and finiteness
discharges *Saturation*. Taking the relation that is free at every nonzero duration gives a frame
whose world histories are exactly the arbitrary colour functions (plus a clock offset), over `ℚ`
as readily as over `ℤ`.

This matters because *Limit* is otherwise a real obstruction: at a frame whose states are the
colours alone, `R w y u` must fail for all small `|y|` whenever `u ≠ w`, so over a dense duration
a history with finitely many states is a step function with a uniform minimum step — no
accumulating run structure, hence no gap for `Δ'` to be anchored at. The clock component is what
removes that obstruction while keeping the frame regular. -/

section WitnessFrame

variable {D : TemporalOrder}

/-- The four colours: one bit for `p`, one for `m`. -/
abbrev Colour := Bool × Bool

/-- The base relation: free at every nonzero duration, the identity at zero. -/
def cRel : Colour → ↑D → Colour → Prop := fun w d u => d = 0 → u = w

theorem cRel_reflection : ∀ w (d : ↑D) u, cRel w d u ↔ cRel u (-d) w := by
  intro w d u
  constructor
  · intro h hd; exact (h (neg_eq_zero.mp hd)).symm
  · intro h hd; exact (h (by rw [hd, neg_zero])).symm

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

theorem cRel_serial : TaskFrame.Serial (cRel (D := D)) :=
  fun w _ _ => ⟨⟨w, fun _ => rfl⟩, ⟨w, fun _ => rfl⟩⟩

theorem cRel_zero : ∀ w u, cRel (D := D) w 0 u → u = w := fun _ _ h => h rfl

/-- **The witness frame**: four colours on a clock over `D`, regular over every temporal order
by `colourClock`. The four conditions above are its entire input; `Limit` comes from the clock
and `Saturation` from finiteness of `Colour`. -/
def colourFibre (D : TemporalOrder) : FrameOver D :=
  colourClock (W := Colour) cRel cRel_reflection cRel_comp cRel_serial cRel_zero

instance colourFibre_isRegular : (colourFibre D).IsRegular :=
  colourClock_isRegular (W := Colour) cRel cRel_reflection cRel_comp cRel_serial cRel_zero

/-! **Histories of `colourFibre D` are exactly the arbitrary colour functions with a clock
offset.** Not formalized here (the `colourClock` wrapper's internal `Nonempty` instance blocks the
`ofReflectiveRegular_taskRel` bridge from unifying without plumbing this probe does not need);
it is read off `prodRel`'s shape, `prodRel R a x b ↔ R a.1 x b.1 ∧ b.2 = a.2 + x`, in one line:
a function `t ↦ (f t, c + t)` respects the task relation iff `cRel (f s) (t - s) (f t)` and
`c + t = (c + s) + (t - s)`, the first vacuous for `t ≠ s` and the second an abelian-group
identity. Hence `hmarkers` holds at `colourFibre D` for every `D`, `ℚ` included: the marker
future is just another colour function. -/

end WitnessFrame

/-! ## A sanity instance: the gadget is not vacuous

Under the marker, `Δ'` at `t` is *witnessed* whenever the point immediately named by a `¬p` time
`u < t` has `p` false throughout `(u, t)` — the degenerate shape of `DeltaProp`. Recorded so that
`DeltaProp` is not an empty condition. -/

theorem deltaProp_of_no_p_between (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    {u : F.Duration} (hut : u < t) (hnp : ¬ holds M τ u pAtom)
    (hclear : ∀ v, u < v → v < t → ¬ holds M τ v pAtom) :
    DeltaProp M τ t :=
  ⟨u, hut, hnp, fun v huv hvt hp => absurd hp (hclear v huv hvt)⟩

end Probe859R01

#print axioms Probe859R01.ofut_pastDet
#print axioms Probe859R01.opast_futDet
#print axioms Probe859R01.theta_eq_iff
#print axioms Probe859R01.nu_iff_le
#print axioms Probe859R01.run_iff
#print axioms Probe859R01.delta_iff
#print axioms Probe859R01.dofut_probe_iff
#print axioms Probe859R01.ofut_neg_probe_iff
#print axioms Probe859R01.not_definable_of_deltaProp_inexpressible
