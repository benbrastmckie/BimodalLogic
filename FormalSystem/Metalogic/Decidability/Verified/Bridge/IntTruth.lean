/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.IntGaps
import FormalSystem.Metalogic.Decidability.Verified.Bridge.BoxSaturation

/-!
# The signed truth correspondence: every carrier point reads one branch label

The countermodel of `Bridge/Valuation.lean` assigns a state to every point of the carrier: at a
**placed** point `f i` the branch's label `(w, timeAt b i)`, at a **gap** point the label
`Bridge/RegionLabel.lean` chose for that point's region. This file gives that assignment a name —
`stateLabel` — and runs the truth-lemma induction against it.

The induction's statement is the **signed** one, which is what a tableau branch supports:

```
BranchTruthAt b ord f φ :=
  ∀ w r, (T(φ) at stateLabel w r  →   φ true at r)
       ∧ (F(φ) at stateLabel w r  →   φ false at r)
```

Neither direction is an `iff`: a saturated branch does not decide every formula at every label,
and does not need to. Only the two implications are used, and only they are true.

## What is generic and what is not

The `atom`, `bot`, `imp` and `box` cases are proved here **for an arbitrary carrier `D` and an
arbitrary injective placement `f`**. They need nothing about gaps beyond `cutIndex_le`, which is
free, so they serve `ℚ` and `ℝ` (sub-phase 7.1d) verbatim and are not `ℤ`-specific despite this
file's name. The `untl`/`snce` cases are where `ℤ` differs from `ℚ`/`ℝ`, and they are the ones
this file leaves owed; see the section "What the temporal cases still need".

## Correction 10 — the carrier has worlds the branch never mentioned, and the model must not
notice

`regionOmega f` is `Set.range fun p : WorldIndex × D => regionHistory f p.1 p.2` — the range over
**all** of `WorldIndex`, which is `Nat`. `truthAt_box_iff_base` quantifies over exactly that
range, so `T(□φ)` at a label demands `φ` at every world of the model, including the cofinitely
many the branch never mentions. At such a world `branchPlacedVal b w i p` is
`b.hasPosAt (.atom p) ⟨w, timeAt b i⟩`, which is `false` for every atom — so a single unmentioned
world falsifies `□p` for a branch carrying `T(□p)`, and the `box` case would be unclosable.

The repair is a **world normalisation**: `normWorld b w` is `w` when the branch knows `w`, and the
branch's first known world otherwise. `normModel` reads the branch through it, so every world of
the carrier is a copy of a known one. This is a composition on the outside of `regionModel`'s
`placedVal` and `gapVal` arguments — no signature moves, `branchModel`'s `gapVal` type is
untouched, and `branchRegionVal` is consumed exactly as `Bridge/RegionLabel.lean` states it. It is
recorded as a correction rather than folded in silently because the previous four Phase 7 banners
each turned on an interface mismatch of precisely this kind that had been assumed away.

## What `findUnexpanded = none` does and does not certify

`ExpandedTableau.hasOpen` carries `findUnexpanded openBranch = none`. That reads
`findApplicableRule`, which reads `allRulesForFC`, and **`serialityRule` is deliberately outside
`allRulesForFC`** — it is scheduled by the two-stage pick, not gated by frame class. So the
certificate says "no *ordinary* rule applies", and a certified branch may still be owed
`T(F ⊤)` and `T(P ⊤)` at every one of its labels.

This costs the extracted model nothing: `F ⊤` and `P ⊤` are true at every point of every history
of any serial frame, and `ℤ` (like `ℚ` and `ℝ`) has no endpoints, so both hold everywhere in
`regionOmega f` regardless of what the branch says. But it is a genuine gap in the certificate,
and the truth lemma **names** it rather than assuming it away: no lemma below takes
`T(F ⊤) ∈ b` or `T(P ⊤) ∈ b` as a hypothesis, and none needs to.
-/

namespace FormalSystem.Metalogic.Decidability.Verified.Bridge

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability

/-! ## Branch membership, both ways

`Bridge/SubformulaProperty.lean` exports `mem_of_branch_contains`; the converse is used just as
often here (the `box` case feeds a membership fact back into the induction hypothesis, which is
stated in `hasPosAt`/`hasNegAt` form) and is not exported anywhere, so it is proved locally.
-/

theorem branch_contains_of_mem {b : Branch} {x : SignedFormula} (h : x ∈ b) :
    b.contains x = true := by
  simp only [Branch.contains, List.any_eq_true]
  exact ⟨x, h, beq_self_eq_true x⟩

theorem hasPosAt_iff_mem (b : Branch) (φ : Formula) (l : Label) :
    b.hasPosAt φ l = true ↔ (⟨.pos, φ, l⟩ : SignedFormula) ∈ b :=
  ⟨mem_of_branch_contains, branch_contains_of_mem⟩

theorem hasNegAt_iff_mem (b : Branch) (φ : Formula) (l : Label) :
    b.hasNegAt φ l = true ↔ (⟨.neg, φ, l⟩ : SignedFormula) ∈ b :=
  ⟨mem_of_branch_contains, branch_contains_of_mem⟩

/-- Every branch time is `timeAt` of some index. -/
theorem exists_index_of_mem_knownTimes {b : Branch} {t : TimeIndex} (h : t ∈ b.knownTimes) :
    ∃ i : BranchTime b, timeAt b i = t := by
  obtain ⟨n, hn, hval⟩ := List.getElem_of_mem h
  exact ⟨⟨n, hn⟩, hval⟩

/-! ## World normalisation

See Correction 10 in the module docstring. `normWorld` is the identity on the worlds the branch
knows and lands on `anchorWorld` elsewhere, so the model has no world whose atoms the branch has
not dictated.
-/

/-- The branch's first known world; junk (`0`) only on the empty branch. -/
def anchorWorld (b : Branch) : WorldIndex := b.knownWorlds.headD 0

/-- Every carrier world, read as a world the branch knows. -/
def normWorld (b : Branch) (w : WorldIndex) : WorldIndex :=
  if w ∈ b.knownWorlds then w else anchorWorld b

theorem normWorld_eq_self {b : Branch} {w : WorldIndex} (hw : w ∈ b.knownWorlds) :
    normWorld b w = w := by
  simp [normWorld, hw]

theorem anchorWorld_mem {b : Branch} (hne : b.knownWorlds ≠ []) :
    anchorWorld b ∈ b.knownWorlds := by
  cases hb : b.knownWorlds with
  | nil => exact absurd hb hne
  | cons x xs => simp [anchorWorld, hb]

theorem normWorld_mem {b : Branch} (hne : b.knownWorlds ≠ []) (w : WorldIndex) :
    normWorld b w ∈ b.knownWorlds := by
  by_cases hw : w ∈ b.knownWorlds
  · simp [normWorld, hw]
  · simpa [normWorld, hw] using anchorWorld_mem hne

theorem normWorld_idem {b : Branch} (hne : b.knownWorlds ≠ []) (w : WorldIndex) :
    normWorld b (normWorld b w) = normWorld b w :=
  normWorld_eq_self (normWorld_mem hne w)

/-! ## The model, and the label a point reads -/

section Model

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/--
**The countermodel, with worlds normalised.**

`regionModel`'s two valuation arguments composed with `normWorld`. At a known world this is
`branchModel b f (branchRegionVal b ord)` on the nose (`normModel_eq_branchModel_at`, below, is
not needed and is not stated: the composition is the definition, and every consumer goes through
`truthAt_atom_state`).
-/
noncomputable def normModel (b : Branch) (ord : TimeOrdering) (f : BranchTime b → D) :
    TaskModel (regionFrame WorldIndex (BranchTime b) D) :=
  regionModel f (fun w => branchPlacedVal b (normWorld b w))
    (fun w => branchRegionVal b ord (normWorld b w))

open Classical in
/--
**The time a carrier point reads.** A placed point reads its own branch time; every other point
reads the label its region was assigned by `Bridge/RegionLabel.lean`.
-/
noncomputable def stateTime (b : Branch) (ord : TimeOrdering) (f : BranchTime b → D)
    (w : WorldIndex) (r : D) : TimeIndex :=
  if h : ∃ i : BranchTime b, f i = r then timeAt b h.choose
  else regionLabel b ord w (cutIndex (regionCode f r))

/-- **The label a carrier point reads**, world normalisation included. -/
noncomputable def stateLabel (b : Branch) (ord : TimeOrdering) (f : BranchTime b → D)
    (w : WorldIndex) (r : D) : Label :=
  ⟨normWorld b w, stateTime b ord f (normWorld b w) r⟩

variable {b : Branch} {ord : TimeOrdering} {f : BranchTime b → D}

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/-- A point in the image of the placement carries a placed region code. -/
theorem isPlacedCode_of_eq {r : D} {i : BranchTime b} (hi : f i = r) :
    IsPlacedCode f (regionCode f r) := ⟨i, by rw [placedCode, hi]⟩

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/-- …and conversely, so `IsPlacedCode` and "is in the image" are the same test. -/
theorem exists_eq_of_isPlacedCode {r : D}
    (h : IsPlacedCode f (regionCode f r)) : ∃ i : BranchTime b, f i = r := by
  obtain ⟨i, hi⟩ := h
  rw [placedCode] at hi
  refine ⟨i, ?_⟩
  have h1 : (i ∈ (regionCode f (f i)).1) ↔ (i ∈ (regionCode f r).1) := by rw [hi]
  have h2 : (i ∈ (regionCode f (f i)).2) ↔ (i ∈ (regionCode f r).2) := by rw [hi]
  simp only [regionCode, Set.mem_setOf_eq, lt_irrefl, false_iff, not_lt] at h1 h2
  exact le_antisymm h2 h1

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
theorem stateTime_placed (hf : Function.Injective f) (w : WorldIndex) {r : D}
    {i : BranchTime b} (hi : f i = r) : stateTime b ord f w r = timeAt b i := by
  have hex : ∃ j : BranchTime b, f j = r := ⟨i, hi⟩
  rw [stateTime, dif_pos hex]
  congr 1
  exact hf (hex.choose_spec.trans hi.symm)

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
theorem stateTime_gap (w : WorldIndex) {r : D} (hr : ¬ IsPlacedCode f (regionCode f r)) :
    stateTime b ord f w r = regionLabel b ord w (cutIndex (regionCode f r)) := by
  rw [stateTime, dif_neg]
  rintro ⟨i, hi⟩
  exact hr (isPlacedCode_of_eq hi)

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
theorem stateLabel_placed (hf : Function.Injective f) (w : WorldIndex) {r : D}
    {i : BranchTime b} (hi : f i = r) :
    stateLabel b ord f w r = ⟨normWorld b w, timeAt b i⟩ := by
  rw [stateLabel, stateTime_placed hf _ hi]

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
theorem stateLabel_gap (w : WorldIndex) {r : D} (hr : ¬ IsPlacedCode f (regionCode f r)) :
    stateLabel b ord f w r =
      ⟨normWorld b w, regionLabel b ord (normWorld b w) (cutIndex (regionCode f r))⟩ := by
  rw [stateLabel, stateTime_gap _ hr]

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/-- The label a point reads is always a label the branch knows the time of. -/
theorem stateTime_mem_knownTimes (hf : Function.Injective f)
    (hCheck : regionLabelCheck b ord = true)
    (hne : b.knownWorlds ≠ []) (w : WorldIndex) (r : D) :
    stateTime b ord f (normWorld b w) r ∈ b.knownTimes := by
  by_cases hr : IsPlacedCode f (regionCode f r)
  · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hr
    rw [stateTime_placed hf _ hi]
    exact timeAt_mem b i
  · rw [stateTime_gap _ hr]
    exact regionLabel_mem_knownTimes hCheck (normWorld_mem hne w) (cutIndex_le b _)

/-! ## The atom clause, at every point of the carrier at once

`Bridge/Valuation.lean` gives the placed readback and `Bridge/RegionLabel.lean` the gap one. With
`stateLabel` naming the label in both cases they become a single statement, and it is an `iff` —
the atom case is the one case where the branch does determine the model.
-/

theorem truthAt_atom_state (hf : Function.Injective f) (w : WorldIndex) (r : D) (p : Atom) :
    TruthAt (normModel b ord f) (regionOmega f) (regionHistory f w (0 : D)) r (Formula.atom p) ↔
      b.hasPosAt (Formula.atom p) (stateLabel b ord f w r) = true := by
  by_cases hr : IsPlacedCode f (regionCode f r)
  · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hr
    subst hi
    rw [stateLabel_placed hf w rfl, normModel,
      truthAt_atom_placed hf (fun w => branchPlacedVal b (normWorld b w))
        (fun w => branchRegionVal b ord (normWorld b w)) w i p]
    rfl
  · rw [stateLabel_gap w hr, normModel,
      truthAt_atom_gap hr (fun w => branchPlacedVal b (normWorld b w))
        (fun w => branchRegionVal b ord (normWorld b w)) w p]
    rfl

end Model

end FormalSystem.Metalogic.Decidability.Verified.Bridge
