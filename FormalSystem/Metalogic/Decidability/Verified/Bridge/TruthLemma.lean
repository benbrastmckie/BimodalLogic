/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.Omega

/-!
# Region invariance, per history — the truth lemma's engine

`Bridge/Interpolate.lean` proves region invariance in the form

```
InterpInvariant f M Om χ := ∀ τ ∈ Om, ∀ r r', SameRegion f r r' → (TruthAt … τ r χ ↔ … τ r' χ)
```

from the hypothesis `∀ τ ∈ Om, RegionConstant f τ`. `Bridge/Omega.lean`'s module docstring shows
that hypothesis is **unsatisfiable** for the shift-closed `Ω` that `valid` demands (a shift-closed
admissible set contains the time-translates of its members, and asking every translate to be
constant on the regions of one fixed placement forces the states constant, hence the model
blind to time); `not_regionConstant_regionHistory_one` is the concrete witness.

This file supplies the form Phase 7 can actually use: invariance at **one** history,

```
InterpInvariantAt f M Om τ χ := ∀ r r', SameRegion f r r' → (TruthAt … τ r χ ↔ … τ r' χ)
```

hypothesised on `RegionConstant f τ` for that history alone, plus `ShiftClosed Om`.

## What changes, and what does not

Only the `box` case changes, and it gets *easier*. Phase 6's `box` case is the reason the global
form exists at all: `TruthAt … (box φ)` is a universal over `Om`, so equating its value at `r` and
at `r'` needed the induction hypothesis at every history of `Om` simultaneously. Here the case
consumes `truthAt_box_iff` instead — for a shift-closed `Om`, truth of `box φ` does not depend on
the evaluation point at all — and uses **no** induction hypothesis. The atom case needs
region-constancy of `τ` only, and the `untl`/`snce` cases were already single-history arguments
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

The single-history refinement of `InterpInvariant`. `Om` still appears — it is `TruthAt`'s
admissible set, which the `box` clause quantifies over — but the property is asserted of `τ`
alone, so it can be established for a history whose *translates* in `Om` are not region-constant.
-/
def InterpInvariantAt (f : ι → D) (M : TaskModel F) (Om : Set (WorldHistory F))
    (τ : WorldHistory F) (χ : Formula) : Prop :=
  ∀ r r' : D, SameRegion f r r' → (TruthAt M Om τ r χ ↔ TruthAt M Om τ r' χ)

variable {f : ι → D} {M : TaskModel F} {Om : Set (WorldHistory F)} {τ : WorldHistory F}

/-- The global Phase 6 statement implies the per-history one at each of its histories. -/
theorem interpInvariantAt_of_interpInvariant {χ : Formula}
    (h : InterpInvariant f M Om χ) (hτ : τ ∈ Om) : InterpInvariantAt f M Om τ χ :=
  fun r r' hrr' => h τ hτ r r' hrr'

/-! ### Propositional and modal cases -/

/--
**Atom case.** Needs region-constancy of this history only: the atom's value at `r` is a function
of `τ`'s domain and state at `r`, and both agree with their region-mates.
-/
theorem interpInvariantAt_atom (hRC : RegionConstant f τ) (p : Atom) :
    InterpInvariantAt f M Om τ (Formula.atom p) := by
  intro r r' hrr'
  simp only [TruthAt]
  constructor
  · rintro ⟨hr, hv⟩
    have hr' : τ.domain r' := (hRC.domain_congr hrr').mp hr
    refine ⟨hr', ?_⟩
    rwa [← hRC.states_congr hrr' hr hr']
  · rintro ⟨hr', hv⟩
    have hr : τ.domain r := (hRC.domain_congr hrr').mpr hr'
    refine ⟨hr, ?_⟩
    rwa [hRC.states_congr hrr' hr hr']

/-- **Bottom case.** -/
theorem interpInvariantAt_bot : InterpInvariantAt f M Om τ Formula.bot := by
  intro _ _ _
  exact Iff.rfl

/-- **Implication case.** -/
theorem interpInvariantAt_imp {φ ψ : Formula} (hφ : InterpInvariantAt f M Om τ φ)
    (hψ : InterpInvariantAt f M Om τ ψ) : InterpInvariantAt f M Om τ (φ.imp ψ) := by
  intro r r' hrr'
  exact imp_congr (hφ r r' hrr') (hψ r r' hrr')

/--
**Box case.** Free, and it does not consume the induction hypothesis.

For a shift-closed `Om`, `truthAt_box_iff` says `box φ` holds at a point iff `φ` holds at every
history of `Om` and every time — a statement with no free evaluation point left in it. This is
the case that forced Phase 6's global formulation, and it is exactly the case shift-closure pays
for.
-/
theorem interpInvariantAt_box (hsc : ShiftClosed Om) (φ : Formula) :
    InterpInvariantAt f M Om τ φ.box := by
  intro r r' _
  exact truthAt_box_congr M hsc τ r r' φ

/-- **Negation.** -/
theorem interpInvariantAt_neg {φ : Formula} (hφ : InterpInvariantAt f M Om τ φ) :
    InterpInvariantAt f M Om τ φ.neg :=
  interpInvariantAt_imp hφ interpInvariantAt_bot

/-- **Verum.** -/
theorem interpInvariantAt_top : InterpInvariantAt f M Om τ (Formula.top : Formula) :=
  interpInvariantAt_imp interpInvariantAt_bot interpInvariantAt_bot

/-! ### Temporal cases

Structurally identical to `Interpolate.lean`'s, with the per-history hypothesis in place of the
global one. Every object these proofs touch — witness, guard point, replacement witness — lives
in `τ`, which is why the weakening costs nothing.
-/

variable [Fintype ι] [DenselyOrdered D]

/-- One direction of the `untl` case, for `r < r'`. -/
private theorem untlAt_forward [NoMaxOrder D] {φ ψ : Formula}
    (hφ : InterpInvariantAt f M Om τ φ) (hψ : InterpInvariantAt f M Om τ ψ)
    {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M Om τ r (φ.untl ψ)) : TruthAt M Om τ r' (φ.untl ψ) := by
  obtain ⟨s, hrs, hφs, hg⟩ := h
  by_cases hcase : r' < s
  · exact ⟨s, hcase, hφs, fun x hx hxs => hg x (lt_trans hlt hx) hxs⟩
  · push_neg at hcase
    have hsreg : SameRegion f r s := sameRegion_convex hrr' hrs.le hcase
    have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
    obtain ⟨s', hr's', hs'reg⟩ := exists_gt_sameRegion (f := f) (r := r') hnp.2
    obtain ⟨x₀, hx₀l, hx₀r⟩ := exists_between hrs
    have hx₀reg : SameRegion f r x₀ := sameRegion_convex hsreg hx₀l.le hx₀r.le
    have hψx₀ : TruthAt M Om τ x₀ ψ := hg x₀ hx₀l hx₀r
    refine ⟨s', hr's', ?_, ?_⟩
    · exact (hφ s s' ((hsreg.symm.trans hrr').trans hs'reg)).mp hφs
    · intro x hx hxs'
      have hxreg : SameRegion f r' x := sameRegion_convex hs'reg hx.le hxs'.le
      exact (hψ x₀ x ((hx₀reg.symm.trans hrr').trans hxreg)).mp hψx₀

/-- The reverse direction of the `untl` case, for `r < r'`. -/
private theorem untlAt_backward [NoMaxOrder D] {φ ψ : Formula}
    (hψ : InterpInvariantAt f M Om τ ψ)
    {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M Om τ r' (φ.untl ψ)) : TruthAt M Om τ r (φ.untl ψ) := by
  obtain ⟨s, hr's, hφs, hg⟩ := h
  have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
  obtain ⟨s₁, hr's₁, hs₁reg⟩ := exists_gt_sameRegion (f := f) (r := r') hnp.2
  obtain ⟨y, hyl, hyr⟩ := exists_between (lt_min hr's hr's₁)
  have hys : y < s := lt_of_lt_of_le hyr (min_le_left _ _)
  have hys₁ : y < s₁ := lt_of_lt_of_le hyr (min_le_right _ _)
  have hyreg : SameRegion f r' y := sameRegion_convex hs₁reg hyl.le hys₁.le
  have hψy : TruthAt M Om τ y ψ := hg y hyl hys
  refine ⟨s, lt_trans hlt hr's, hφs, ?_⟩
  intro x hx hxs
  by_cases hcase : r' < x
  · exact hg x hcase hxs
  · push_neg at hcase
    have hxreg : SameRegion f r x := sameRegion_convex hrr' hx.le hcase
    exact (hψ y x ((hyreg.symm.trans hrr'.symm).trans hxreg)).mp hψy

/-- **Until case**, per history. -/
theorem interpInvariantAt_untl [NoMaxOrder D] {φ ψ : Formula}
    (hφ : InterpInvariantAt f M Om τ φ) (hψ : InterpInvariantAt f M Om τ ψ) :
    InterpInvariantAt f M Om τ (Formula.untl φ ψ) := by
  intro r r' hrr'
  rcases lt_trichotomy r r' with hlt | heq | hgt
  · exact ⟨untlAt_forward hφ hψ hrr' hlt, untlAt_backward hψ hrr' hlt⟩
  · rw [heq]
  · exact ⟨untlAt_backward hψ hrr'.symm hgt, untlAt_forward hφ hψ hrr'.symm hgt⟩

/-- One direction of the `snce` case, for `r < r'`. -/
private theorem snceAt_forward [NoMinOrder D] {φ ψ : Formula}
    (hψ : InterpInvariantAt f M Om τ ψ)
    {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M Om τ r (φ.snce ψ)) : TruthAt M Om τ r' (φ.snce ψ) := by
  obtain ⟨s, hsr, hφs, hg⟩ := h
  have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
  obtain ⟨s₁, hs₁r, hs₁reg⟩ := exists_lt_sameRegion (f := f) (r := r) hnp.1
  obtain ⟨y, hyl, hyr⟩ := exists_between (max_lt hsr hs₁r)
  have hsy : s < y := lt_of_le_of_lt (le_max_left _ _) hyl
  have hs₁y : s₁ < y := lt_of_le_of_lt (le_max_right _ _) hyl
  have hyreg : SameRegion f r y := hs₁reg.trans (sameRegion_convex hs₁reg.symm hs₁y.le hyr.le)
  have hψy : TruthAt M Om τ y ψ := hg y hsy hyr
  refine ⟨s, lt_trans hsr hlt, hφs, ?_⟩
  intro x hsx hxr'
  by_cases hcase : x < r
  · exact hg x hsx hcase
  · push_neg at hcase
    have hxreg : SameRegion f r x := sameRegion_convex hrr' hcase hxr'.le
    exact (hψ y x (hyreg.symm.trans hxreg)).mp hψy

/-- The reverse direction of the `snce` case, for `r < r'`. -/
private theorem snceAt_backward [NoMinOrder D] {φ ψ : Formula}
    (hφ : InterpInvariantAt f M Om τ φ) (hψ : InterpInvariantAt f M Om τ ψ)
    {r r' : D} (hrr' : SameRegion f r r') (hlt : r < r')
    (h : TruthAt M Om τ r' (φ.snce ψ)) : TruthAt M Om τ r (φ.snce ψ) := by
  obtain ⟨s, hsr', hφs, hg⟩ := h
  by_cases hcase : s < r
  · exact ⟨s, hcase, hφs, fun x hsx hxr => hg x hsx (lt_trans hxr hlt)⟩
  · push_neg at hcase
    have hsreg : SameRegion f r s := sameRegion_convex hrr' hcase hsr'.le
    have hnp := placed_ne_of_sameRegion_ne hrr' (ne_of_lt hlt)
    obtain ⟨s', hs'r, hs'reg⟩ := exists_lt_sameRegion (f := f) (r := r) hnp.1
    obtain ⟨y, hyl, hyr⟩ := exists_between hsr'
    have hyreg : SameRegion f s y := sameRegion_convex (hsreg.symm.trans hrr') hyl.le hyr.le
    have hψy : TruthAt M Om τ y ψ := hg y hyl hyr
    refine ⟨s', hs'r, ?_, ?_⟩
    · exact (hφ s s' (hsreg.symm.trans hs'reg)).mp hφs
    · intro x hs'x hxr
      have hxreg : SameRegion f r x :=
        hs'reg.trans (sameRegion_convex hs'reg.symm hs'x.le hxr.le)
      exact (hψ y x ((hyreg.symm.trans hsreg.symm).trans hxreg)).mp hψy

/-- **Since case**, per history. -/
theorem interpInvariantAt_snce [NoMinOrder D] {φ ψ : Formula}
    (hφ : InterpInvariantAt f M Om τ φ) (hψ : InterpInvariantAt f M Om τ ψ) :
    InterpInvariantAt f M Om τ (Formula.snce φ ψ) := by
  intro r r' hrr'
  rcases lt_trichotomy r r' with hlt | heq | hgt
  · exact ⟨snceAt_forward hψ hrr' hlt, snceAt_backward hφ hψ hrr' hlt⟩
  · rw [heq]
  · exact ⟨snceAt_backward hφ hψ hrr'.symm hgt, snceAt_forward hψ hrr'.symm hgt⟩

/-! ### The derived temporal operators -/

/-- **`F φ`.** -/
theorem interpInvariantAt_someFuture [NoMaxOrder D] {φ : Formula}
    (hφ : InterpInvariantAt f M Om τ φ) : InterpInvariantAt f M Om τ φ.someFuture :=
  interpInvariantAt_untl hφ interpInvariantAt_top

/-- **`P φ`.** -/
theorem interpInvariantAt_somePast [NoMinOrder D] {φ : Formula}
    (hφ : InterpInvariantAt f M Om τ φ) : InterpInvariantAt f M Om τ φ.somePast :=
  interpInvariantAt_snce hφ interpInvariantAt_top

/-- **`G φ`.** -/
theorem interpInvariantAt_allFuture [NoMaxOrder D] {φ : Formula}
    (hφ : InterpInvariantAt f M Om τ φ) : InterpInvariantAt f M Om τ φ.allFuture :=
  interpInvariantAt_neg (interpInvariantAt_someFuture (interpInvariantAt_neg hφ))

/-- **`H φ`.** -/
theorem interpInvariantAt_allPast [NoMinOrder D] {φ : Formula}
    (hφ : InterpInvariantAt f M Om τ φ) : InterpInvariantAt f M Om τ φ.allPast :=
  interpInvariantAt_neg (interpInvariantAt_somePast (interpInvariantAt_neg hφ))

/-! ### The assembled induction -/

/--
**Per-history interpolation invariance.** On a densely ordered carrier with no endpoints, truth of
every formula in a *region-constant* history is constant on each region, provided the admissible
set is shift-closed.

The hypotheses are exactly the two the countermodel supplies: `regionConstant_regionHistory_zero`
for the base history and `shiftClosed_regionOmega` for `Ω`. Contrast Phase 6's `interpInvariant`,
which additionally demands region-constancy of *every* member of `Om` — a demand no shift-closed
`Om` can meet (`Bridge/Omega.lean`, Consequence 3).
-/
theorem interpInvariantAt [NoMaxOrder D] [NoMinOrder D]
    (hsc : ShiftClosed Om) (hRC : RegionConstant f τ) (χ : Formula) :
    InterpInvariantAt f M Om τ χ := by
  induction χ with
  | atom p => exact interpInvariantAt_atom hRC p
  | bot => exact interpInvariantAt_bot
  | imp φ ψ hφ hψ => exact interpInvariantAt_imp hφ hψ
  | box φ _ => exact interpInvariantAt_box hsc φ
  | untl φ ψ hφ hψ => exact interpInvariantAt_untl hφ hψ
  | snce φ ψ hφ hψ => exact interpInvariantAt_snce hφ hψ

end Invariance

/-! ## The countermodel's invariance, instantiated

The two hypotheses of `interpInvariantAt` discharged against the objects of `Bridge/Omega.lean`,
for an arbitrary carrier and then at each of the three dense carriers the Phase 6 route serves.
-/

section Countermodel

variable {W ι : Type} {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
variable [Fintype ι] [DenselyOrdered D] [NoMaxOrder D] [NoMinOrder D]

/--
**The countermodel is region-invariant at every base history.** Both hypotheses of
`interpInvariantAt` are discharged by construction: the base history is region-constant
(`regionConstant_regionHistory_zero`) and `Ω` is shift-closed (`shiftClosed_regionOmega`).
-/
theorem interpInvariantAt_regionHistory (f : ι → D) (M : TaskModel (regionFrame W ι D)) (w : W)
    (χ : Formula) :
    InterpInvariantAt f M (regionOmega f) (regionHistory f w (0 : D)) χ :=
  interpInvariantAt (shiftClosed_regionOmega f) (regionConstant_regionHistory_zero f w) χ

end Countermodel

/-! ## What the truth lemma still needs

Recorded here because this is the file the next dispatch opens. **O1 and O3 are discharged; O2 is
NOT — its interface was refuted, and the refutation is machine-checked.** Read the O2 entry below
before budgeting anything, and read `gapAdequate_insufficient` (`Bridge/Valuation.lean`) before
budgeting the induction: the induction cannot be closed against `GapAdequate`, whatever policy is
plugged into it. The interfaces, and where they live:

**O1 — the valuation. Done** (`Bridge/Valuation.lean`). `regionFrame`'s states are
`W × (Set ι × Set ι)`, so a `TaskModel` over it is a predicate on (world, region code). At a
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

**O3 — the box grid. Done, after two corrections** (`Bridge/BoxSaturation.lean`). The `box` case
needs `T(□φ) @ (w,t)` to reach every known *label*, and `sat_box_pos` reaches only the same time.
The interface is now `sat_box_grid_of_check`, whose two side conditions are both `Bool` equations
on the finished branch: `timeOrderTotal b timeOrd = true` and `boxAnchoredCheck b = true`.

  Two invariants were tried and both are refuted in tree, so neither should be reached for again.
  `BoxContextClosed` ("`T(□φ)` at every known label") fails because world-minting copies box
  formulas' *contents*, never the formulas. `BoxTemporalSpread` ("`T(Gφ)`/`T(Hφ)` at every known
  world at the box formula's own time") fails because `boxDiamondPersistence` relabels `T(□φ)`
  into every time the run later mints in that world, while the world-minting copy of
  `allFuturePosAtTime` happened once, at the triggering time — measured on
  `(□p ∧ ◇q) → r`, see `Tests/BimodalTest/BoxSpreadProbe.lean`. `BoxAnchored` — one anchor time
  per known world carrying `T(φ)`, `T(Gφ)` and `T(Hφ)` together — is what survives, and
  `timeOrderTotal` sweeps the world's whole row from that single anchor.

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
example (M : TaskModel (regionFrame Unit (Fin 1) ℚ)) (χ : Formula) :
    InterpInvariantAt (fun _ : Fin 1 => (0 : ℚ)) M
      (regionOmega (fun _ : Fin 1 => (0 : ℚ))) (regionHistory (fun _ : Fin 1 => (0 : ℚ)) () 0) χ :=
  interpInvariantAt_regionHistory _ M () χ

example (M : TaskModel (regionFrame Unit (Fin 1) ℝ)) (χ : Formula) :
    InterpInvariantAt (fun _ : Fin 1 => (0 : ℝ)) M
      (regionOmega (fun _ : Fin 1 => (0 : ℝ))) (regionHistory (fun _ : Fin 1 => (0 : ℝ)) () 0) χ :=
  interpInvariantAt_regionHistory _ M () χ

end Checks

end FormalSystem.Metalogic.Decidability.Verified.Bridge
