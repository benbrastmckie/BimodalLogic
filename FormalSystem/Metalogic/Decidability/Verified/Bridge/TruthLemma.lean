/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionFrame

/-!
# Region invariance, per history — the truth lemma's engine

`Bridge/Interpolate.lean` proves region invariance in the form

```
InterpInvariant f M χ := ∀ τ, τ.IsTotal → ∀ r r', SameRegion f r r' →
  (TruthAt … τ r χ ↔ … τ r' χ)
```

from the hypothesis `∀ τ, τ.IsTotal → RegionConstant f τ`. `Bridge/RegionFrame.lean`'s module docstring
shows that hypothesis is **unsatisfiable** here (the total histories are closed under time
translation, and asking every translate to be constant on the regions of one fixed placement
forces the states constant, hence the model blind to time);
`not_regionConstant_regionHistory_one` is the concrete witness.

This file supplies the form Phase 7 can actually use: invariance at **one** history,

```
InterpInvariantAt f M τ χ := ∀ r r', SameRegion f r r' → (TruthAt … τ r χ ↔ … τ r' χ)
```

hypothesised on `AtomRegionInvariant f M τ` for that history alone — and, since the box clause was
retargeted from membership in a designated set to totality, on nothing else.

`AtomRegionInvariant` is the weakening `regionFrame`'s determinism forces: it asks that `M` and
`τ` agree *atomically* on region-mates, not that `τ` assign them the same state. Region-constancy
of a history is no longer available at all — the clock relation propagates a state along time, so
a region-constant history would repeat a state at two distinct times
(`not_regionConstant_regionHistory`) — and the condition therefore sits on the valuation instead
(`RegionValued`, discharged by `regionModel` in `Bridge/Valuation.lean`).
`RegionConstant.atomRegionInvariant` records that the old hypothesis still implies the new one.

## What changes, and what does not

Only the `box` case changes, and it gets *easier*. The global form's `box` case is the reason that
form exists at all: `TruthAt … (box φ)` is a universal over the total histories, so equating its
value at `r` and at `r'` needed the induction hypothesis at every total history simultaneously.
Here the case consumes `truthAt_box_iff` instead — truth of `box φ` does not depend on the
evaluation point at all — and uses **no** induction hypothesis. The atom case needs
atomic region-invariance of `τ` against `M` only, and the `untl`/`snce` cases were already single-history arguments
in Phase 6: every witness, guard point and replacement witness they manipulate lives in the one
history being quantified over. They are reproduced here against the weaker hypothesis, unchanged
in structure; the region lemmas they run on (`sameRegion_convex`, `placed_ne_of_sameRegion_ne`,
`exists_gt_sameRegion`, `exists_lt_sameRegion`) are consumed from `Interpolate.lean` verbatim.

`interpInvariantAt_of_interpInvariant` records that this form is genuinely weaker: the global
statement implies it pointwise, so nothing proved in Phase 6 is lost.

## Density is still load-bearing

The `untl`/`snce` cases carry `[DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]` for exactly the
reason `Interpolate.lean` records: "an open region has a member strictly above any of its members"
is false on `ℤ` (`not_exists_gt_sameRegion_int`). `.Base ℚ`, `.Dense ℚ` and `.Dedekind ℝ` are
served here; `.Discrete ℤ` needs its own route and does not get one from this file.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

section Invariance

variable {D : Type*} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
variable {F : TaskFrame D} {ι : Type*}

/--
Region invariance of `χ` at a single history: truth of `χ` in `τ` does not distinguish points of
one region.

The single-history refinement of `InterpInvariant`. No designated admissible set appears — the
`box` clause no longer quantifies over one — and the property is asserted of `τ` alone, so it can
be established for a history whose *time-translates* are not region-constant.
-/
def InterpInvariantAt (f : ι → D) (M : TaskModel F)
    (τ : WorldHistory F) (χ : Formula) : Prop :=
  ∀ r r' : D, SameRegion f r r' → (TruthAt M τ r χ ↔ TruthAt M τ r' χ)

variable {f : ι → D} {M : TaskModel F} {τ : WorldHistory F}

/-- The global statement implies the per-history one at each *total* history. -/
theorem interpInvariantAt_of_interpInvariant {χ : Formula}
    (h : InterpInvariant f M χ) (hτ : τ.IsTotal) : InterpInvariantAt f M τ χ :=
  fun r r' hrr' => h τ hτ r r' hrr'

/--
**The atom case's actual hypothesis**: the pair `(M, τ)` cannot tell two points of one region
apart *atomically* — neither in `τ`'s domain, nor in the truth value the valuation assigns to the
states there.

This is strictly weaker than `RegionConstant f τ`, which demands the two states be *equal*.
The weakening is forced: `regionFrame`'s task relation is now the deterministic clock, so a state
carries a time and a region-constant history would repeat a state at two distinct times
(`not_regionConstant_regionHistory`). The region structure therefore lives in the valuation — the
model may read the time component, but only through its region code — and that is exactly what
this predicate asks for. `RegionConstant.atomRegionInvariant` records that nothing is lost:
wherever the old, stronger hypothesis is available, this one follows.
-/
structure AtomRegionInvariant (f : ι → D) (M : TaskModel F) (τ : WorldHistory F) : Prop where
  /-- Region-mates are both in the domain or both out of it. -/
  domain_congr : ∀ {r r' : D}, SameRegion f r r' → (τ.domain r ↔ τ.domain r')
  /-- Region-mates carry the same atomic truth values. -/
  valuation_congr : ∀ {r r' : D} (_h : SameRegion f r r') (hr : τ.domain r) (hr' : τ.domain r')
      (p : Atom), (M.valuation (τ.states r hr) p ↔ M.valuation (τ.states r' hr') p)

/-- A region-constant history is atomically region-invariant against *every* model. -/
theorem RegionConstant.atomRegionInvariant (hRC : RegionConstant f τ) (M : TaskModel F) :
    AtomRegionInvariant f M τ where
  domain_congr := hRC.domain_congr
  valuation_congr := by
    intro r r' h hr hr' p
    rw [hRC.states_congr h hr hr']

/-! ### Propositional and modal cases -/

/--
**Atom case.** Needs atomic region-invariance of this history against this model only: the atom's
value at `r` is a function of `τ`'s domain at `r` and of the valuation at the state there, and
both agree with their region-mates.
-/
theorem interpInvariantAt_atom (hAI : AtomRegionInvariant f M τ) (p : Atom) :
    InterpInvariantAt f M τ (Formula.atom p) := by
  intro r r' hrr'
  simp only [TruthAt]
  constructor
  · rintro ⟨hr, hv⟩
    have hr' : τ.domain r' := (hAI.domain_congr hrr').mp hr
    exact ⟨hr', (hAI.valuation_congr hrr' hr hr' p).mp hv⟩
  · rintro ⟨hr', hv⟩
    have hr : τ.domain r := (hAI.domain_congr hrr').mpr hr'
    exact ⟨hr, (hAI.valuation_congr hrr' hr hr' p).mpr hv⟩

/-- **Bottom case.** -/
theorem interpInvariantAt_bot : InterpInvariantAt f M τ Formula.bot := by
  intro _ _ _
  exact Iff.rfl

/-- **Implication case.** -/
theorem interpInvariantAt_imp {φ ψ : Formula} (hφ : InterpInvariantAt f M τ φ)
    (hψ : InterpInvariantAt f M τ ψ) : InterpInvariantAt f M τ (φ.imp ψ) := by
  intro r r' hrr'
  exact imp_congr (hφ r r' hrr') (hψ r r' hrr')

/--
**Box case.** Free, and it does not consume the induction hypothesis.

`truthAt_box_iff` says `box φ` holds at a point iff `φ` holds at every *total* history and every
time — a statement with no free evaluation point left in it. This is the case that forced the
global formulation. It used to be the case shift-closure paid for; under the totality box clause
it costs nothing, because `WorldHistory.isTotal_timeShift` supplies the shifted witness outright.
-/
theorem interpInvariantAt_box (φ : Formula) :
    InterpInvariantAt f M τ φ.box := by
  intro r r' _
  exact truthAt_box_congr M τ r r' φ

/-- **Negation.** -/
theorem interpInvariantAt_neg {φ : Formula} (hφ : InterpInvariantAt f M τ φ) :
    InterpInvariantAt f M τ φ.neg :=
  interpInvariantAt_imp hφ interpInvariantAt_bot

/-- **Verum.** -/
theorem interpInvariantAt_top : InterpInvariantAt f M τ (Formula.top : Formula) :=
  interpInvariantAt_imp interpInvariantAt_bot interpInvariantAt_bot

/-! ### Temporal cases

Structurally identical to `Interpolate.lean`'s, with the per-history hypothesis in place of the
global one. Every object these proofs touch — witness, guard point, replacement witness — lives
in `τ`, which is why the weakening costs nothing.
-/

variable [Fintype ι] [DenselyOrdered D]

/-- One direction of the `untl` case, for `r < r'`. -/
private theorem untlAt_forward [NoMaxOrder D] {φ ψ : Formula}
    (hφ : InterpInvariantAt f M τ φ) (hψ : InterpInvariantAt f M τ ψ)
    {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M τ r (φ.untl ψ)) : TruthAt M τ r' (φ.untl ψ) := by
  obtain ⟨s, hrs, hφs, hg⟩ := h
  by_cases hcase : r' < s
  · exact ⟨s, hcase, hφs, fun x hx hxs => hg x (lt_trans hlt hx) hxs⟩
  · push_neg at hcase
    have hsreg : SameRegion f r s := sameRegion_convex hrr' hrs.le hcase
    have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
    obtain ⟨s', hr's', hs'reg⟩ := exists_gt_sameRegion (f := f) (r := r') hnp.2
    obtain ⟨x₀, hx₀l, hx₀r⟩ := exists_between hrs
    have hx₀reg : SameRegion f r x₀ := sameRegion_convex hsreg hx₀l.le hx₀r.le
    have hψx₀ : TruthAt M τ x₀ ψ := hg x₀ hx₀l hx₀r
    refine ⟨s', hr's', ?_, ?_⟩
    · exact (hφ s s' ((hsreg.symm.trans hrr').trans hs'reg)).mp hφs
    · intro x hx hxs'
      have hxreg : SameRegion f r' x := sameRegion_convex hs'reg hx.le hxs'.le
      exact (hψ x₀ x ((hx₀reg.symm.trans hrr').trans hxreg)).mp hψx₀

/-- The reverse direction of the `untl` case, for `r < r'`. -/
private theorem untlAt_backward [NoMaxOrder D] {φ ψ : Formula}
    (hψ : InterpInvariantAt f M τ ψ)
    {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M τ r' (φ.untl ψ)) : TruthAt M τ r (φ.untl ψ) := by
  obtain ⟨s, hr's, hφs, hg⟩ := h
  have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
  obtain ⟨s₁, hr's₁, hs₁reg⟩ := exists_gt_sameRegion (f := f) (r := r') hnp.2
  obtain ⟨y, hyl, hyr⟩ := exists_between (lt_min hr's hr's₁)
  have hys : y < s := lt_of_lt_of_le hyr (min_le_left _ _)
  have hys₁ : y < s₁ := lt_of_lt_of_le hyr (min_le_right _ _)
  have hyreg : SameRegion f r' y := sameRegion_convex hs₁reg hyl.le hys₁.le
  have hψy : TruthAt M τ y ψ := hg y hyl hys
  refine ⟨s, lt_trans hlt hr's, hφs, ?_⟩
  intro x hx hxs
  by_cases hcase : r' < x
  · exact hg x hcase hxs
  · push_neg at hcase
    have hxreg : SameRegion f r x := sameRegion_convex hrr' hx.le hcase
    exact (hψ y x ((hyreg.symm.trans hrr'.symm).trans hxreg)).mp hψy

/-- **Until case**, per history. -/
theorem interpInvariantAt_untl [NoMaxOrder D] {φ ψ : Formula}
    (hφ : InterpInvariantAt f M τ φ) (hψ : InterpInvariantAt f M τ ψ) :
    InterpInvariantAt f M τ (Formula.untl φ ψ) := by
  intro r r' hrr'
  rcases lt_trichotomy r r' with hlt | heq | hgt
  · exact ⟨untlAt_forward hφ hψ hrr' hlt, untlAt_backward hψ hrr' hlt⟩
  · rw [heq]
  · exact ⟨untlAt_backward hψ hrr'.symm hgt, untlAt_forward hφ hψ hrr'.symm hgt⟩

/-- One direction of the `snce` case, for `r < r'`. -/
private theorem snceAt_forward [NoMinOrder D] {φ ψ : Formula}
    (hψ : InterpInvariantAt f M τ ψ)
    {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M τ r (φ.snce ψ)) : TruthAt M τ r' (φ.snce ψ) := by
  obtain ⟨s, hsr, hφs, hg⟩ := h
  have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
  obtain ⟨s₁, hs₁r, hs₁reg⟩ := exists_lt_sameRegion (f := f) (r := r) hnp.1
  obtain ⟨y, hyl, hyr⟩ := exists_between (max_lt hsr hs₁r)
  have hsy : s < y := lt_of_le_of_lt (le_max_left _ _) hyl
  have hs₁y : s₁ < y := lt_of_le_of_lt (le_max_right _ _) hyl
  have hyreg : SameRegion f r y := hs₁reg.trans (sameRegion_convex hs₁reg.symm hs₁y.le hyr.le)
  have hψy : TruthAt M τ y ψ := hg y hsy hyr
  refine ⟨s, lt_trans hsr hlt, hφs, ?_⟩
  intro x hsx hxr'
  by_cases hcase : x < r
  · exact hg x hsx hcase
  · push_neg at hcase
    have hxreg : SameRegion f r x := sameRegion_convex hrr' hcase hxr'.le
    exact (hψ y x (hyreg.symm.trans hxreg)).mp hψy

/-- The reverse direction of the `snce` case, for `r < r'`. -/
private theorem snceAt_backward [NoMinOrder D] {φ ψ : Formula}
    (hφ : InterpInvariantAt f M τ φ) (hψ : InterpInvariantAt f M τ ψ)
    {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M τ r' (φ.snce ψ)) : TruthAt M τ r (φ.snce ψ) := by
  obtain ⟨s, hsr', hφs, hg⟩ := h
  by_cases hcase : s < r
  · exact ⟨s, hcase, hφs, fun x hsx hxr => hg x hsx (lt_trans hxr hlt)⟩
  · push_neg at hcase
    have hsreg : SameRegion f r s := sameRegion_convex hrr' hcase hsr'.le
    have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
    obtain ⟨s', hs'r, hs'reg⟩ := exists_lt_sameRegion (f := f) (r := r) hnp.1
    obtain ⟨y, hyl, hyr⟩ := exists_between hsr'
    have hyreg : SameRegion f s y := sameRegion_convex (hsreg.symm.trans hrr') hyl.le hyr.le
    have hψy : TruthAt M τ y ψ := hg y hyl hyr
    refine ⟨s', hs'r, ?_, ?_⟩
    · exact (hφ s s' (hsreg.symm.trans hs'reg)).mp hφs
    · intro x hs'x hxr
      have hxreg : SameRegion f r x :=
        hs'reg.trans (sameRegion_convex hs'reg.symm hs'x.le hxr.le)
      exact (hψ y x ((hyreg.symm.trans hsreg.symm).trans hxreg)).mp hψy

/-- **Since case**, per history. -/
theorem interpInvariantAt_snce [NoMinOrder D] {φ ψ : Formula}
    (hφ : InterpInvariantAt f M τ φ) (hψ : InterpInvariantAt f M τ ψ) :
    InterpInvariantAt f M τ (Formula.snce φ ψ) := by
  intro r r' hrr'
  rcases lt_trichotomy r r' with hlt | heq | hgt
  · exact ⟨snceAt_forward hψ hrr' hlt, snceAt_backward hφ hψ hrr' hlt⟩
  · rw [heq]
  · exact ⟨snceAt_backward hφ hψ hrr'.symm hgt, snceAt_forward hψ hrr'.symm hgt⟩

/-! ### The derived temporal operators -/

/-- **`F φ`.** -/
theorem interpInvariantAt_someFuture [NoMaxOrder D] {φ : Formula}
    (hφ : InterpInvariantAt f M τ φ) : InterpInvariantAt f M τ φ.someFuture :=
  interpInvariantAt_untl hφ interpInvariantAt_top

/-- **`P φ`.** -/
theorem interpInvariantAt_somePast [NoMinOrder D] {φ : Formula}
    (hφ : InterpInvariantAt f M τ φ) : InterpInvariantAt f M τ φ.somePast :=
  interpInvariantAt_snce hφ interpInvariantAt_top

/-- **`G φ`.** -/
theorem interpInvariantAt_allFuture [NoMaxOrder D] {φ : Formula}
    (hφ : InterpInvariantAt f M τ φ) : InterpInvariantAt f M τ φ.allFuture :=
  interpInvariantAt_neg (interpInvariantAt_someFuture (interpInvariantAt_neg hφ))

/-- **`H φ`.** -/
theorem interpInvariantAt_allPast [NoMinOrder D] {φ : Formula}
    (hφ : InterpInvariantAt f M τ φ) : InterpInvariantAt f M τ φ.allPast :=
  interpInvariantAt_neg (interpInvariantAt_somePast (interpInvariantAt_neg hφ))

/-! ### The assembled induction -/

/--
**Per-history interpolation invariance.** On a densely ordered carrier with no endpoints, truth of
every formula in an *atomically region-invariant* history is constant on each region.

The one hypothesis is exactly what the countermodel supplies:
`atomRegionInvariant_regionHistory` for the base history. Shift-closure is no longer needed — the
box case now instantiates against totality, which `timeShift` preserves outright.
Contrast the global `interpInvariant`, which additionally demands region-constancy of *every*
total history — a demand this carrier cannot meet (`Bridge/RegionFrame.lean`, Consequence 3).
-/
theorem interpInvariantAt [NoMaxOrder D] [NoMinOrder D]
    (hAI : AtomRegionInvariant f M τ) (χ : Formula) :
    InterpInvariantAt f M τ χ := by
  induction χ with
  | atom p => exact interpInvariantAt_atom hAI p
  | bot => exact interpInvariantAt_bot
  | imp φ ψ hφ hψ => exact interpInvariantAt_imp hφ hψ
  | box φ _ => exact interpInvariantAt_box φ
  | untl φ ψ hφ hψ => exact interpInvariantAt_untl hφ hψ
  | snce φ ψ hφ hψ => exact interpInvariantAt_snce hφ hψ

end Invariance

/-! ## The countermodel's invariance, instantiated

The two hypotheses of `interpInvariantAt` discharged against the objects of `Bridge/RegionFrame.lean`,
for an arbitrary carrier and then at each of the three dense carriers the Phase 6 route serves.
-/

section Countermodel

variable {W ι : Type} {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
variable [Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]
-- `regionFrame` carries `[Nontrivial D]` (its *Limit* lemma needs it). It is declared here in its
-- own right rather than being recovered from `[NoMaxOrder D]`, so that the `omit` clauses below
-- can still drop the density instances.
variable [Nontrivial D]

/--
**The region condition on the valuation.** `regionFrame`'s states are `(world, time)` pairs, and a
`RegionValued` model is one whose atoms read the time component only through its region code —
equivalently, one that cannot separate two region-mates at a fixed world.

This is where the region structure went when `regionFrame`'s task relation became deterministic.
It cannot be imposed on the histories any longer: determinism propagates a state along the clock,
so region-constancy of a history is now outright false (`not_regionConstant_regionHistory`). It is
a condition on the *model*, discharged once and for all by `regionModel` in `Bridge/Valuation.lean`,
whose valuation is literally a function of `regionCode f` applied to the time component.
-/
def RegionValued (f : ι → D) (M : TaskModel (regionFrame W ι D)) : Prop :=
  ∀ (w : W) (r r' : D), SameRegion f r r' → ∀ p : Atom,
    (M.valuation (w, r) p ↔ M.valuation (w, r') p)

omit [Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D] in
/--
**A region-valued model is atomically region-invariant at every base history.** `regionHistory`'s
domain is total, so the domain half is trivial, and its state at `r` is `(w, r)`, so the valuation
half is exactly `RegionValued`.
-/
theorem atomRegionInvariant_regionHistory {f : ι → D} {M : TaskModel (regionFrame W ι D)}
    (hRV : RegionValued f M) (w : W) :
    AtomRegionInvariant f M (regionHistory f w (0 : D)) where
  domain_congr := fun _ => Iff.rfl
  valuation_congr := by
    intro r r' h hr hr' p
    simp only [regionHistory_states, add_zero]
    exact hRV w r r' h p

/--
**The countermodel is region-invariant at every base history.** The hypothesis of
`interpInvariantAt` is discharged by construction: the model is region-valued (supplied by
`Bridge/Valuation.lean`). The former second hypothesis, shift-closure of the admissible set, is
gone with the retarget of the box clause to totality.
-/
theorem interpInvariantAt_regionHistory {f : ι → D} {M : TaskModel (regionFrame W ι D)}
    (hRV : RegionValued f M) (w : W) (χ : Formula) :
    InterpInvariantAt f M (regionHistory f w (0 : D)) χ :=
  interpInvariantAt (atomRegionInvariant_regionHistory hRV w) χ

end Countermodel

/-! ## What the truth lemma still needs

Recorded here because this is the file the next dispatch opens. **O1 and O3 are discharged; O2 is
NOT — its interface was refuted, and the refutation is machine-checked.** Read the O2 entry below
before budgeting anything, and read `gapAdequate_insufficient` (`Bridge/Valuation.lean`) before
budgeting the induction: the induction cannot be closed against `GapAdequate`, whatever policy is
plugged into it. The interfaces, and where they live:

**O1 — the valuation. Done** (`Bridge/Valuation.lean`). `regionFrame`'s states are `W × D`, and
`regionModel` factors the time component through `regionCode f`, so the model is a predicate on
(world, region code) — and is `RegionValued` by construction. At a
*placed* code — one of the form `regionCode f (f i)` — the branch dictates the value:
`branchPlacedVal`, reading `b.hasPosAt (.atom p) ⟨w, timeAt b i⟩`, with `truthAt_atom_branch_placed`
the readback. `regionValuation` is total on codes; `truthAt_atom_regionHistory` discharges the
domain existential outright.

**O2 — the gap policy. OPEN, and its interface is refuted** (`Bridge/Valuation.lean`). Three
successive statements of this obligation have now been machine-refuted, each by the file that
states it, so the history matters:

* `GapDemands` — stated backwards, `gapDemands_trivial` proves every policy meets it.
* the endpoint-copy policies — `not_leftCopy_gapAdequate`, `not_rightCopy_gapAdequate`.
* `GapAdequate` itself — **`gapAdequate_insufficient`**. `branchGapVal` satisfies `GapAdequate`
  (`branchGapVal_gapAdequate`) and still falsifies a branch fact: on `refuteBoxBranch`, carrying
  `T(□p)` and `T(□(p → q))` with no `T(□q)`/`T(G q)`/`T(H q)` anywhere, the gap points get `p`
  true and `q` false, so `□(p → q)` is false in the model. `Tests/BimodalTest/BoxSpreadProbe.lean`
  row D measures that the engine produces exactly this configuration on
  `(□p ∧ □(p → q)) → r` at `.Base`.

The defect is structural, not a bad choice of policy. `GapAdequate` constrains `gapVal` at atoms
only, on the ground that a compound formula's value at a gap point is fixed by the induction;
`truthAt_box_iff_base` breaks that ground, because `T(□χ)` for compound `χ` is a demand *at* the
gap points that only the atom policy can meet. The gap's state must be closed under the
propositional consequences of the forced set
`{χ : T(Gχ) below} ∪ {χ : T(Hχ) above} ∪ {χ : T(□χ)}`, and a saturated branch is not closed under
those consequences — the lower ray gives the same failure from `T(H(p → q))`, `T(H p)` and `F(q)`
at the earliest known time, a satisfiable configuration that forces `q` on the ray with nothing on
the branch naming it.

So O2's replacement is a **realisability condition on the branch**, in the decidable-check family
`timeOrderTotal` / `boxAnchoredCheck` already belong to, not a policy. Two routes, neither yet
probed — and by the process lesson that cost two earlier dispatches, **probe before proving**:

* *Model-side.* Assign each gap region the atoms of a chosen known label, with a `Bool` check that
  the chosen label's positive content contains the region's forced set. Cheap to check, but the
  induction target has to be restated: "truth at `r`" is then indexed by the label assigned to
  `r`'s region, and the temporal cases must be re-derived at gap points rather than inherited.
* *Branch-side.* Have the dense rules realise each gap as an actual minted label
  (`prior_U_gap`/`prior_S_gap`/`sep` are already shaped for this) and place those labels in the
  carrier, so no region is forced by facts it does not itself carry. Costlier, and it touches the
  engine's rule set rather than the bridge.

The `U`/`S` straddling guards remain obligations of the induction, not of `gapVal` — that part of
the previous reading survives the refutation unchanged.

**O3 — the box grid. Proved, but its side condition has since stopped being computable-true**
(`Bridge/BoxSaturation.lean`). The `box` case needs `T(□φ) @ (w,t)` to reach every known *label*,
and `sat_box_pos` reaches only the same time. The interface is `sat_box_grid_of_check`, whose two
side conditions are both `Bool` equations on the finished branch: `timeOrderTotal b timeOrd = true`
and `boxAnchoredCheck b = true`. Both lemmas still typecheck; the second hypothesis is carried and
never unfolded.

  Two invariants were tried and both are refuted in tree, so neither should be reached for again.
  `BoxContextClosed` ("`T(□φ)` at every known label") fails because world-minting copies box
  formulas' *contents*, never the formulas. `BoxTemporalSpread` ("`T(Gφ)`/`T(Hφ)` at every known
  world at the box formula's own time") fails because `boxDiamondPersistence` relabels `T(□φ)`
  into every time the run later mints in that world, while the world-minting copy of
  `allFuturePosAtTime` happened once, at the triggering time — measured on
  `(□p ∧ ◇q) → r`, see `Tests/BimodalTest/BoxSpreadProbe.lean`. `BoxAnchored` — one anchor time
  per known world carrying `T(φ)`, `T(Gφ)` and `T(Hφ)` together — is the statement that survived
  those two refutations, and `timeOrderTotal` sweeps the world's whole row from that single
  anchor.

  **What has changed since.** The world-minting copies of `allFuturePosAtTime`/`allPastPosAtTime`
  — the six group-3 blocks in `boxNeg` and `diamondPos` — have been **removed from the engine as
  unsound**: they asserted of a freshly minted alternative world what was only known of the
  history being built. They were the only route by which `T(Gφ)`/`T(Hφ)` could reach a fresh
  world, so `boxAnchoredCheck` no longer computes `true` on multi-world branches, and
  `sat_box_grid_of_check`'s second side condition is no longer dischargeable by `decide` on real
  engine output. Nothing here fails to typecheck; what O3 has lost is the ability to *supply* its
  own hypothesis. Choosing the repair — propagate `T(□φ)` itself, copy `T(Gφ)`/`T(Hφ)` only when
  box-derived, or restructure the `box` case to need no anchor — is an open design decision with
  its own soundness obligations. Do **not** reinstate the removed copies. The measurement, the
  carrier list, and the repair options are written up in
  `specs/418_.../artifacts/boxanchored-finding.md`.

**The `sat_*` family is now complete** for the induction's propositional needs.
`Bridge/PropSaturation.lean` adds `sat_imp_pos`, which `CountermodelExtraction.lean` did not
carry: `impPos` is the only *branching* propositional rule, and the guard it fails under
`findUnexpanded = none` is `bss.any (fun fs => fs.all branch.contains)` — i.e. exactly
`F(ψ) ∈ b ∨ T(χ) ∈ b`. Nothing about it depends on the gap policy, so it survives the O2
refutation intact.

**What is owed, in order.** (1) O2's replacement — a realisability condition on the branch, chosen
between the two routes above **after** probing the engine's output, not before. (2) Then
`not_valid_of_hasOpen`, generic in `TemporalCarrier`, consuming the `sat_*` family and the
interfaces above. Its preamble must state that `findUnexpanded = none` means "no *ordinary* rule
applies" — `serialityRule` is deliberately outside `allRulesForFC`, so the branch may still be
owed `T(F ⊤)`/`T(P ⊤)` at every label. Those are true at every point of any serial frame, so the
extracted model is unaffected, but the gap must be named rather than assumed away.

Do **not** start the induction against `GapAdequate`. It is refuted, and the `box` case is where
it fails, so a partial induction that leaves `box` for last will look healthy until the last case
and then be unclosable.
-/

/-! ## Sanity checks -/

section Checks

/-- The three dense carriers admit the invariance instantiation; `ℤ` deliberately does not. -/
example (M : TaskModel (regionFrame Unit (Fin 1) ℚ))
    (hRV : RegionValued (fun _ : Fin 1 => (0 : ℚ)) M) (χ : Formula) :
    InterpInvariantAt (fun _ : Fin 1 => (0 : ℚ)) M
      (regionHistory (fun _ : Fin 1 => (0 : ℚ)) () 0) χ :=
  interpInvariantAt_regionHistory hRV () χ

example (M : TaskModel (regionFrame Unit (Fin 1) ℝ))
    (hRV : RegionValued (fun _ : Fin 1 => (0 : ℝ)) M) (χ : Formula) :
    InterpInvariantAt (fun _ : Fin 1 => (0 : ℝ)) M
      (regionHistory (fun _ : Fin 1 => (0 : ℝ)) () 0) χ :=
  interpInvariantAt_regionHistory hRV () χ

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
