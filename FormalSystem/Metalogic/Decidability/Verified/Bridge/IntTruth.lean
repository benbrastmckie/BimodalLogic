/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.IntGaps
import FormalSystem.Metalogic.Decidability.Verified.Bridge.BoxSaturation
import FormalSystem.Metalogic.Decidability.Verified.Bridge.TemporalGate

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

The total histories of this frame are `regionHistory f w Δ` ranging over **all** of `WorldIndex`,
which is `Nat`, and all time offsets. Under `regionFrame`'s task relation — the deterministic
clock `(w, x) ⇒_d (w, x + d)` — that family is *exactly* the frame's total histories
(`isTotal_iff_regionHistory`), because `respects_task` propagates the state at time `0` to every
other time. So there is no total history outside the family to worry about, and the box clause's
quantifier over total histories is a quantifier over this family.

`truthAt_box_iff_base` quantifies over exactly that range, so `T(□φ)` at a label demands `φ` at
every world of the model, including the cofinitely
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
every region history regardless of what the branch says. Every region history has total domain,
and by `isTotal_iff_regionHistory` those are all of the frame's total histories, so the argument
leaves no history the box clause can reach uncovered. But it is a genuine gap in the certificate,
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

/--
A known time's rank is a genuine region index strictly below the top one: `branchRank` counts the
known times strictly below `t`, and `t` is not one of them.

This is what lets a **placed** evaluation point reach the **upper ray**'s label through
`regionLabel_untlNeg`, whose side condition is "asserted strictly below region `j`" at `j = n`.
-/
theorem branchRank_lt_length {b : Branch} {ord : TimeOrdering}
    (hV : branchOrderValid b ord = true) {t : TimeIndex} (ht : t ∈ b.knownTimes) :
    branchRank b ord t < b.knownTimes.length := by
  rw [branchRank]
  rcases Nat.lt_or_ge (b.knownTimes.filter fun s => strictBefore ord s t).length
    b.knownTimes.length with h | h
  · exact h
  · exfalso
    have heq : (b.knownTimes.filter fun s => strictBefore ord s t) = b.knownTimes :=
      List.filter_sublist.eq_of_length (le_antisymm (List.length_filter_le _ _) h)
    have hmem : t ∈ b.knownTimes.filter fun s => strictBefore ord s t := by rw [heq]; exact ht
    rw [List.mem_filter, irrefl_of_valid hV ht] at hmem
    simp at hmem

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

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]

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
    TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r (Formula.atom p) ↔
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

/-! ## The signed correspondence, and the four cases that are not temporal -/

/--
**The truth lemma's induction predicate**, at one formula.

Signed and one-directional in each sign, which is exactly the strength a tableau branch has: a
saturated branch asserts and denies formulas at labels, and decides neither every formula nor
every label.
-/
def BranchTruthAt (b : Branch) (ord : TimeOrdering) (f : BranchTime b → D) (φ : Formula) : Prop :=
  ∀ (w : WorldIndex) (r : D),
    (b.hasPosAt φ (stateLabel b ord f w r) = true →
      TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r φ) ∧
    (b.hasNegAt φ (stateLabel b ord f w r) = true →
      ¬ TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r φ)

/--
**Atom case.** The positive half is `truthAt_atom_state`; the negative half is that plus openness,
which is the only thing that stops a branch from asserting and denying the same atom.
-/
theorem branchTruthAt_atom (hf : Function.Injective f) (fc : ProofSystem.FrameClass)
    (hOpen : findClosure b fc = none) (p : Atom) :
    BranchTruthAt b ord f (Formula.atom p) := by
  intro w r
  refine ⟨fun hp => (truthAt_atom_state hf w r p).mpr hp, fun hn hT => ?_⟩
  exact sat_atom_consistent b fc hOpen p (stateLabel b ord f w r)
    ⟨(truthAt_atom_state hf w r p).mp hT, hn⟩

/-- **Bottom case.** `T(⊥)` closes a branch, and `⊥` is false at every point of every model. -/
theorem branchTruthAt_bot (fc : ProofSystem.FrameClass) (hOpen : findClosure b fc = none) :
    BranchTruthAt b ord f Formula.bot := by
  intro w r
  exact ⟨fun hp => absurd ((hasPosAt_iff_mem b _ _).mp hp) (sat_no_bot_pos b fc hOpen _),
    fun _ hT => hT⟩

/--
**Implication case.** Both halves are saturation facts at the *same* label, so no gap point is
involved and nothing about the placement is used. `sat_imp_pos` (`Bridge/PropSaturation.lean`) is
the positive half — the only *branching* propositional rule, whose declined guard says literally
`F(ψ) ∈ b ∨ T(χ) ∈ b`.
-/
theorem branchTruthAt_imp (hSat : findUnexpanded b (timeOrd := ord) = none)
    {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ) (hψ : BranchTruthAt b ord f ψ) :
    BranchTruthAt b ord f (φ.imp ψ) := by
  intro w r
  constructor
  · intro hp
    rcases sat_imp_pos b ord hSat φ ψ _ ((hasPosAt_iff_mem b _ _).mp hp) with hneg | hpos
    · exact fun hTφ => absurd hTφ ((hφ w r).2 ((hasNegAt_iff_mem b _ _).mpr hneg))
    · exact fun _ => (hψ w r).1 ((hasPosAt_iff_mem b _ _).mpr hpos)
  · intro hn hT
    obtain ⟨hφp, hψn⟩ := sat_imp_neg b ord hSat φ ψ _ ((hasNegAt_iff_mem b _ _).mp hn)
    exact (hψ w r).2 ((hasNegAt_iff_mem b _ _).mpr hψn)
      (hT ((hφ w r).1 ((hasPosAt_iff_mem b _ _).mpr hφp)))

/--
**Box case — written first, deliberately.**

`truthAt_box_iff_base` turns `□φ` into a demand on `φ` at **every** world of the carrier and
**every** point of it, with no evaluation point left free. That is the case that machine-refuted
`GapAdequate` (`gapAdequate_insufficient`, `Bridge/Valuation.lean`), because a gap point's value at
a *compound* `φ` is not something an atom-wise policy can supply. It closes here because the two
halves of the demand are met by two facts of the same shape, both branch-fact-in and
branch-fact-out:

* at a **placed** point, `sat_box_grid_of_check` — `T(□φ)` anywhere reaches every known label;
* at a **gap** point, `regionLabel_box` — the region's chosen label carries `T(φ)` because the
  gate's box row demanded it.

Both land the induction hypothesis at a *label*, never at a gap valuation, which is the whole
content of the region-labelling decision.

The negative half needs no gate at all: `sat_box_neg` mints a known world carrying `F(φ)` at the
same time, and that time is placed, so the induction hypothesis applies at a placed point of that
world's own history.
-/
theorem branchTruthAt_box (hf : Function.Injective f)
    (hSat : findUnexpanded b (timeOrd := ord) = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hne : b.knownWorlds ≠ [])
    {φ : Formula} (hφ : BranchTruthAt b ord f φ) :
    BranchTruthAt b ord f φ.box := by
  intro w r
  constructor
  · intro hp
    have hmem := (hasPosAt_iff_mem b _ _).mp hp
    rw [truthAt_box_iff_base]
    intro w' y
    refine (hφ w' y).1 ?_
    rw [hasPosAt_iff_mem]
    by_cases hy : IsPlacedCode f (regionCode f y)
    · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hy
      rw [stateLabel_placed hf w' hi]
      exact sat_box_grid_of_check b ord hSat hTot hBA φ _ _ hmem
        (normWorld b w') (normWorld_mem hne w') (timeAt b i) (timeAt_mem b i)
    · rw [stateLabel_gap w' hy]
      exact regionLabel_box hCheck (normWorld_mem hne w') (cutIndex_le b _) hmem
  · intro hn hT
    have hmem := (hasNegAt_iff_mem b _ _).mp hn
    obtain ⟨w'', hw'', hmem'⟩ :=
      sat_box_neg b ord hSat φ (stateLabel b ord f w r).world (stateLabel b ord f w r).time hmem
    obtain ⟨i, hi⟩ :=
      exists_index_of_mem_knownTimes (stateTime_mem_knownTimes hf hCheck hne w r)
    rw [truthAt_box_iff_base] at hT
    refine (hφ w'' (f i)).2 ?_ (hT w'' (f i))
    rw [hasNegAt_iff_mem, stateLabel_placed hf w'' (rfl : f i = f i), normWorld_eq_self hw'', hi]
    exact hmem'

/-! ## What the temporal cases need of the placement

Two properties, both stated **without** a `LinearOrder` instance on `BranchTime b` so that they
can appear in the case lemmas' hypotheses without a `letI` in every statement. Both are
discharged at `ℤ` in the last section, from `Bridge/Embed.lean` and `Bridge/IntGaps.lean`.
-/

/--
The placement is faithful to the branch's own order: a strict `futureOf` fact between two branch
times is a strict inequality between their carrier positions.
-/
def OrderFaithful (b : Branch) (ord : TimeOrdering) (f : BranchTime b → D) : Prop :=
  ∀ i j : BranchTime b, strictBefore ord (timeAt b i) (timeAt b j) = true → f i < f j

/--
The placement has **no inhabited interior gap**: every non-placed point is on one of the two
rays, so its region index is `0` or `n`.

True of `ℤ` under `finiteOrderEmbInt`, which is the `Nat`-cast and therefore contiguous
(`ray_of_gap_finiteOrderEmbInt`). False of `ℚ` and `ℝ`, where sub-phase 7.1d has to meet the
`G`-content from the left and the `H`-content from the right in one region state.
-/
def RayOnly (b : Branch) (f : BranchTime b → D) : Prop :=
  ∀ r : D, ¬ IsPlacedCode f (regionCode f r) →
    cutIndex (regionCode f r) = 0 ∨ cutIndex (regionCode f r) = b.knownTimes.length

/--
The placement also **reflects** the branch's order: a strict inequality between two placed points
is a strict `futureOf` fact between the times they place. The converse of `OrderFaithful`.

This is what turns the semantic "the witness sits above the evaluation point" back into a branch
fact, which is the only currency the gates trade in. It is a genuinely separate demand from
`OrderFaithful`: faithfulness alone permits a placement that spreads incomparable times apart,
and it is `timeAt`'s injectivity (`Bridge/BranchOrder.lean`) that rules out the remaining tie.
-/
def OrderReflecting (b : Branch) (ord : TimeOrdering) (f : BranchTime b → D) : Prop :=
  ∀ i j : BranchTime b, f i < f j → strictBefore ord (timeAt b i) (timeAt b j) = true

/--
Each non-placed point lies **outside** the placed block, on the side its region index names:
region `0` below every placed point, region `n` above every one.

`RayOnly` says a non-placed point's region index is `0` or `n`; this says the index is not
merely a label but a position. The temporal cases need both — the index to know which label the
point reads, and the position to know which points lie above it.
-/
def RaySplit (b : Branch) (f : BranchTime b → D) : Prop :=
  ∀ r : D, ¬ IsPlacedCode f (regionCode f r) →
    (cutIndex (regionCode f r) = 0 → ∀ i : BranchTime b, r < f i) ∧
    (cutIndex (regionCode f r) = b.knownTimes.length → ∀ i : BranchTime b, f i < r)

/--
**The carrier is stepped**: every point has an immediate successor and an immediate predecessor.

This is the resolution of the witness-existence obstruction the negative halves exposed. At an
**upper-ray** evaluation point the positive `untl` case closes by `untlRay_self` — every point
above reads the same label, so the witness is that label — but the argument silently needs *some*
`s > r` to be the witness, and a guard interval `(r,s)` it can empty. Neither `RayOnly` nor
`RaySplit` says anything about inhabitance above the upper ray, and where the temporal cases are
stated `D` is only an `AddCommGroup` + `LinearOrder`, so `r + 1` is not available. This is stated
as a property of the carrier rather than of the placement because that is all it is, and it is
discharged at `ℤ` by `r + 1` and `r - 1` (`stepped_int`).

Like `RayOnly` and `RaySplit` it is **false** at `ℚ` and `ℝ`, and like them it is used only by the
temporal cases; sub-phase 7.1d replaces all three at once with `Bridge/Interpolate.lean`'s
`exists_gt_sameRegion`/`exists_lt_sameRegion`, which supply a witness by density instead of by a
step. So this adds no restriction that was not already present.
-/
def Stepped (C : Type) [LinearOrder C] : Prop :=
  (∀ r : C, ∃ s : C, r < s ∧ ∀ u : C, r < u → ¬ u < s) ∧
  (∀ r : C, ∃ s : C, s < r ∧ ∀ u : C, u < r → ¬ s < u)

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/--
**Contiguity, in the form the induction consumes it.** A carrier point strictly between two
placed points is itself placed.

`RayOnly` and `RaySplit` together say every non-placed point is outside the placed block, so
there is nothing left for the interior. This is the step that turns the semantics' "`ψ` at
*every* carrier point strictly between" into the branch's "`ψ` at every known time strictly
between", and it is where the `ℤ` placement differs from `ℚ` and `ℝ`: at those carriers the
interior of a gap is inhabited and `RayOnly` is false, which is why sub-phase 7.1d needs
`Bridge/Interpolate.lean`'s `exists_gt_sameRegion` in its place.

It is also what makes three of the negative case's seven leaves vacuous, in the contrapositive
form used there.
-/
theorem isPlacedCode_of_between (hRO : RayOnly b f) (hRS : RaySplit b f)
    {i j : BranchTime b} {u : D} (hiu : f i < u) (huj : u < f j) :
    IsPlacedCode f (regionCode f u) := by
  by_contra hu
  rcases hRO u hu with h0 | hn
  · exact absurd ((hRS u hu).1 h0 i) (asymm hiu)
  · exact absurd ((hRS u hu).2 hn j) (asymm huj)

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/--
**The upper ray is upward-closed.** Everything strictly above an upper-ray point is itself on the
upper ray, and so reads the same label.

Derived rather than assumed: a point above an upper-ray point cannot be placed (`RaySplit` puts
every placed point below the ray), and cannot be on the lower ray (`RaySplit` would then put it
below every placed point, hence below the ray point itself). The `n = 0` case — no placed points
at all, so the two rays' indices coincide — is not an exception but a degeneracy, and is settled
by the two indices being equal.
-/
theorem upperRay_of_gt (hRO : RayOnly b f) (hRS : RaySplit b f) {r s : D}
    (hr : ¬ IsPlacedCode f (regionCode f r))
    (hn : cutIndex (regionCode f r) = b.knownTimes.length) (hrs : r < s) :
    ¬ IsPlacedCode f (regionCode f s) ∧
      cutIndex (regionCode f s) = b.knownTimes.length := by
  have habove : ∀ i : BranchTime b, f i < r := (hRS r hr).2 hn
  have hs : ¬ IsPlacedCode f (regionCode f s) := by
    intro h
    obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode h
    exact absurd (hi ▸ habove i) (asymm hrs)
  refine ⟨hs, ?_⟩
  rcases hRO s hs with h0 | hn'
  · by_cases hlen : b.knownTimes.length = 0
    · rw [h0, hlen]
    · exact absurd (hrs.trans (((hRS s hs).1 h0 ⟨0, Nat.pos_of_ne_zero hlen⟩).trans
        (habove ⟨0, Nat.pos_of_ne_zero hlen⟩))) (lt_irrefl r)
  · exact hn'

omit [AddCommGroup D] [IsOrderedAddMonoid D] in
/-- **The lower ray is downward-closed**, the mirror. -/
theorem lowerRay_of_lt (hRO : RayOnly b f) (hRS : RaySplit b f) {r s : D}
    (hr : ¬ IsPlacedCode f (regionCode f r))
    (hz : cutIndex (regionCode f r) = 0) (hsr : s < r) :
    ¬ IsPlacedCode f (regionCode f s) ∧ cutIndex (regionCode f s) = 0 := by
  have hbelow : ∀ i : BranchTime b, r < f i := (hRS r hr).1 hz
  have hs : ¬ IsPlacedCode f (regionCode f s) := by
    intro h
    obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode h
    exact absurd (hi ▸ hbelow i) (asymm hsr)
  refine ⟨hs, ?_⟩
  rcases hRO s hs with h0 | hn'
  · exact h0
  · by_cases hlen : b.knownTimes.length = 0
    · rw [hn', hlen]
    · exact absurd ((hbelow ⟨0, Nat.pos_of_ne_zero hlen⟩).trans
        (((hRS s hs).2 hn' ⟨0, Nat.pos_of_ne_zero hlen⟩).trans hsr)) (lt_irrefl r)


/-! ## The temporal cases — LANDED, and here is what each direction runs on

All four halves are sorry-free. `branchTruthAt_untl` is `fun w r => ⟨pos w r, neg w r⟩`, and
likewise for `snce`; splitting the theorem before proving any of it is what let the two directions
stop depending on each other, and neither has since needed anything the other proved.

### The design decisions that survived, and the two that did not

1. **`sat_untl_pos` discards the ordering.** `Bridge/TemporalSaturation.lean`'s
   `sat_untl_pos_future` and `sat_snce_pos_past` keep the witness's position. In the event they
   are **not called**: row 7 keeps the witness in the guard-`⊤` case too, which is the only place
   the older design needed them.
2. **The witness has to be the *earliest* one — dropped.** No earliest-witness iteration appears
   anywhere. Row 7 hands back a witness *together with* the guard below it, so the branch does the
   minimisation once, decidably, instead of the proof redoing it. This is what the row shapes were
   measured for and it is why the placed leaf is six lines.
3. **The ray self-demand.** `untlRaySelf`/`snceRaySelf` (rows 3 and 4) close the leaf where the
   evaluation point looks along its own ray, `untl` upward and `snce` downward.
4. **Region invariance is unavailable at `ℤ`** — unchanged, and it is why the rays are handled a
   point at a time. `interpInvariantAt` needs `DenselyOrdered D`, and
   `not_exists_gt_sameRegion_int` is the machine witness that `exists_gt_sameRegion` genuinely
   fails here.

### The `⊤` trap, which governed the design and still does

`Tests/BimodalTest/TemporalWitnessProbe.lean` refutes any row asking the branch to *assert* a
guard on nine of twelve rows, **including rows with no genuine until in them**: the guard of a
`someFuture` is `⊤` and the engine never writes `T(⊤)`. So `ψ = ⊤` splits off at every leaf and is
discharged semantically — `⊤` is true at every point of every model. What the positive halves
changed is *where* the exemption sits: rows 7 and 9 exempt `ψ = ⊤` from the **guard** only and
keep the witness, because `TruthAt … (untl ⊤ φ)` still demands one. A row exempting itself
entirely there asserts nothing on the whole `someFuture`/`somePast` fragment.

### The negative case tree

Four live leaves and three vacuous ones. Write `r` for the evaluation point and `s` for the
witness the semantics hands back, so `r < s`.

* `r` **placed**, `s` **placed** — `OrderReflecting` turns `f i < f j` back into a `strictBefore`
  fact and `untlNeg_spread` denies `φ` there.
* `r` **placed**, `s` on the **upper ray** — `s` reads `regionLabel … n`, and `regionLabel_untlNeg`
  reaches it, its "strictly below region `j`" side condition being `branchRank_lt_length`.
* `r` **placed**, `s` on the **lower ray** — vacuous: `RaySplit` puts `s` below `r`.
* `r` on the **lower ray** — one leaf for all three shapes of `s`, and that is exactly the reach of
  row 5, `untlNegRay_low`, because every label any point reads is a known time.
* `r` on the **upper ray** — `s` placed and `s` on the lower ray are vacuous; `s` on the upper ray
  reads `r`'s own label and `regionLabel_untlNeg` closes it against itself.

### The positive case tree, and the obstruction it exposed

Three live leaves, one row each, and no vacuous ones — the positive direction chooses its witness
rather than being handed one, so nothing is ruled out for it.

* `r` **placed** — row 7. `isPlacedCode_of_between` makes every carrier point of the guard interval
  placed and `OrderReflecting` reads its time back as strictly between, which is the row's reach.
* `r` on the **lower ray** (`untl`; the **upper** ray for `snce`) — row 9, Correction 12's residual.
  The reach has to be all of `b.knownTimes`: the interval holds placed points below the witness
  *and* ray points reading the evaluation point's own label, and `regionLabel` picks the first
  eligible candidate rather than the order-minimal one.
* `r` on the **upper ray** (`untl`; the **lower** ray for `snce`) — `untlRay_self`, plus `Stepped`.

That last leaf is where the design was incomplete and the incompleteness was invisible until the
negative halves were written. "The guard interval is empty" needs *some* `s > r` to be empty
between, and neither `RayOnly` nor `RaySplit` says anything about inhabitance above the upper ray.
`Stepped` is the minimal repair; `upperRay_of_gt` and `lowerRay_of_lt` supply the other half of
that leaf — that every point above an upper-ray point reads the ray's label — and they are
**derived** from `RayOnly` and `RaySplit` rather than assumed.

### What the positive halves do not need

Neither positive half references `branchOrderValid`, the frame class, `findUnexpanded`,
`findClosure`, `timeOrderTotal`, `boxAnchoredCheck`, `regionLabelCheck` or the non-empty-worlds
hypothesis. The positive direction is carried by the placement geometry and rows 3, 7, 9 and 10
alone. The negative direction is where `regionLabelCheck` is load-bearing.

None of the above touches an engine file, the region labelling, or any interface already landed.
-/

/--
**Until case, negative half.** `F(U(φ,ψ))` at a point's label makes `U(φ,ψ)` false there.

No guard reasoning appears: `untlNeg_spread` denies the *event* at every known later time
outright, which is strictly more than the semantics asks for and is what makes this half
independent of the `⊤` trap that governs the positive one.
-/
theorem branchTruthAt_untl_neg (hf : Function.Injective f) (hOR : OrderReflecting b ord f)
    (hRO : RayOnly b f) (hRS : RaySplit b f) (hV : branchOrderValid b ord = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    (hne : b.knownWorlds ≠ []) {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ)
    (w : WorldIndex) (r : D) :
    b.hasNegAt (Formula.untl ψ φ) (stateLabel b ord f w r) = true →
      ¬ TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r
        (Formula.untl ψ φ) := by
  intro hn hT
  obtain ⟨s, hrs, hsφ, -⟩ := hT
  have hw' : normWorld b w ∈ b.knownWorlds := normWorld_mem hne w
  have hmem : (⟨.neg, .untl ψ φ, stateLabel b ord f w r⟩ : SignedFormula) ∈ b :=
    (hasNegAt_iff_mem b _ _).mp hn
  refine (hφ w s).2 ?_ hsφ
  by_cases hr : IsPlacedCode f (regionCode f r)
  · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hr
    rw [stateLabel_placed hf w hi] at hmem
    by_cases hs : IsPlacedCode f (regionCode f s)
    · obtain ⟨j, hj⟩ := exists_eq_of_isPlacedCode hs
      rw [stateLabel_placed hf w hj]
      exact untlNeg_spread hTW hmem (timeAt_mem b j) (hOR i j (by rw [hi, hj]; exact hrs))
    · rw [stateLabel_gap w hs]
      rcases hRO s hs with h0 | hnn
      · exact absurd (hi ▸ (hRS s hs).1 h0 i) (asymm hrs)
      · rw [hnn, hasNegAt_iff_mem]
        exact regionLabel_untlNeg hCheck hw' (le_refl _) hmem
          (branchRank_lt_length hV (timeAt_mem b i))
  · rw [stateLabel_gap w hr] at hmem
    by_cases hz : cutIndex (regionCode f r) = 0
    · rw [hz] at hmem
      exact untlNegRay_low hTW hmem (stateTime_mem_knownTimes hf hCheck hne w s)
    · have hnn : cutIndex (regionCode f r) = b.knownTimes.length := (hRO r hr).resolve_left hz
      have hlen : 0 < b.knownTimes.length := by omega
      rw [hnn] at hmem
      have habove : ∀ i : BranchTime b, f i < r := (hRS r hr).2 hnn
      by_cases hs : IsPlacedCode f (regionCode f s)
      · obtain ⟨j, hj⟩ := exists_eq_of_isPlacedCode hs
        exact absurd (hj ▸ habove j) (asymm hrs)
      · rw [stateLabel_gap w hs]
        rcases hRO s hs with h0 | hnn'
        · exact absurd (hrs.trans (((hRS s hs).1 h0 ⟨0, hlen⟩).trans (habove ⟨0, hlen⟩)))
            (lt_irrefl r)
        · rw [hnn', hasNegAt_iff_mem]
          exact regionLabel_untlNeg hCheck hw' (le_refl _) hmem
            (branchRank_lt_length hV (regionLabel_mem_knownTimes hCheck hw' (le_refl _)))

/-- **Since case, negative half.** The past-directed mirror, closing at the upper ray by row 6
and at the lower ray by `regionLabel_snceNeg`'s free `0 ≤ branchRank` side condition. -/
theorem branchTruthAt_snce_neg (hf : Function.Injective f) (hOR : OrderReflecting b ord f)
    (hRO : RayOnly b f) (hRS : RaySplit b f) (hV : branchOrderValid b ord = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    (hne : b.knownWorlds ≠ []) {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ)
    (w : WorldIndex) (r : D) :
    b.hasNegAt (Formula.snce ψ φ) (stateLabel b ord f w r) = true →
      ¬ TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r
        (Formula.snce ψ φ) := by
  intro hn hT
  obtain ⟨s, hsr, hsφ, -⟩ := hT
  have hw' : normWorld b w ∈ b.knownWorlds := normWorld_mem hne w
  have hmem : (⟨.neg, .snce ψ φ, stateLabel b ord f w r⟩ : SignedFormula) ∈ b :=
    (hasNegAt_iff_mem b _ _).mp hn
  refine (hφ w s).2 ?_ hsφ
  by_cases hr : IsPlacedCode f (regionCode f r)
  · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hr
    rw [stateLabel_placed hf w hi] at hmem
    by_cases hs : IsPlacedCode f (regionCode f s)
    · obtain ⟨j, hj⟩ := exists_eq_of_isPlacedCode hs
      rw [stateLabel_placed hf w hj]
      exact snceNeg_spread hTW hmem (timeAt_mem b j) (hOR j i (by rw [hi, hj]; exact hsr))
    · rw [stateLabel_gap w hs]
      rcases hRO s hs with h0 | hnn
      · rw [h0, hasNegAt_iff_mem]
        exact regionLabel_snceNeg hCheck hw' (Nat.zero_le _) hmem (Nat.zero_le _)
      · exact absurd (hi ▸ (hRS s hs).2 hnn i) (asymm hsr)
  · rw [stateLabel_gap w hr] at hmem
    by_cases hu : cutIndex (regionCode f r) = b.knownTimes.length
    · rw [hu] at hmem
      exact snceNegRay_up hTW hmem (stateTime_mem_knownTimes hf hCheck hne w s)
        (branchRank_lt_length hV (stateTime_mem_knownTimes hf hCheck hne w s))
    · have hz : cutIndex (regionCode f r) = 0 := (hRO r hr).resolve_right hu
      have hlen : 0 < b.knownTimes.length := by omega
      rw [hz] at hmem
      have hbelow : ∀ i : BranchTime b, r < f i := (hRS r hr).1 hz
      by_cases hs : IsPlacedCode f (regionCode f s)
      · obtain ⟨j, hj⟩ := exists_eq_of_isPlacedCode hs
        exact absurd (hj ▸ hbelow j) (asymm hsr)
      · rw [stateLabel_gap w hs]
        rcases hRO s hs with h0 | hnn'
        · rw [h0, hasNegAt_iff_mem]
          exact regionLabel_snceNeg hCheck hw' (Nat.zero_le _) hmem (Nat.zero_le _)
        · exact absurd (hsr.trans ((hbelow ⟨0, hlen⟩).trans ((hRS s hs).2 hnn' ⟨0, hlen⟩)))
            (lt_irrefl s)

/--
**Until case, positive half.** `T(U(φ,ψ))` at a point's label makes `U(φ,ψ)` true there.

Three leaves, and the guard is read off a different row at each.

* `r` **placed** — row 7 (`untlPos_witness`) hands back a known time `t'` strictly after `r`'s own
  carrying `T(φ)`, and the guard at every known time strictly between. `OrderFaithful` puts the
  witness above `r`; `isPlacedCode_of_between` makes every carrier point of the guard interval
  placed and `OrderReflecting` reads its time back as strictly between, which is exactly the row's
  reach.
* `r` on the **lower ray** — row 9 (`untlRayDn_witness`), Correction 12's residual. The witness may
  be *any* known time, since every placed point is above `r`; the guard interval contains placed
  points below the witness *and* lower-ray points reading `r`'s own label, so the row has to carry
  the guard at both, which is why its reach is `b.knownTimes` rather than a slice.
* `r` on the **upper ray** — `untlRay_self` gives `T(φ)` at the label, `upperRay_of_gt` says every
  point above reads that same label, and `Stepped`'s successor supplies a witness with an empty
  guard interval. Without `Stepped` there is no witness to hand back at all: this leaf is where
  the property earns its place.

`ψ = ⊤` splits off at every leaf and is discharged semantically — `⊤` is true at every point of
every model, and the engine never writes `T(⊤)`, so no row may ask for it. Rows 7 and 9 keep the
witness in that case and drop only the guard.
-/
theorem branchTruthAt_untl_pos (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hOR : OrderReflecting b ord f) (hRO : RayOnly b f) (hRS : RaySplit b f) (hSt : Stepped D)
    (hTW : temporalWitnessCheck b ord = true) {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ)
    (hψ : BranchTruthAt b ord f ψ) (w : WorldIndex) (r : D) :
    b.hasPosAt (Formula.untl ψ φ) (stateLabel b ord f w r) = true →
      TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r
        (Formula.untl ψ φ) := by
  intro hp
  have hmem : (⟨.pos, .untl ψ φ, stateLabel b ord f w r⟩ : SignedFormula) ∈ b :=
    (hasPosAt_iff_mem b _ _).mp hp
  by_cases hr : IsPlacedCode f (regionCode f r)
  · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hr
    rw [stateLabel_placed hf w hi] at hmem
    obtain ⟨t', ht'mem, ht'lt, ht'φ, hguard⟩ := untlPos_witness hTW hmem
    obtain ⟨j, hj⟩ := exists_index_of_mem_knownTimes ht'mem
    refine ⟨f j, by rw [← hi]; exact hOF i j (by rw [hj]; exact ht'lt), ?_, ?_⟩
    · exact (hφ w (f j)).1 (by rw [stateLabel_placed hf w (rfl : f j = f j), hj]; exact ht'φ)
    · intro u hru huj
      rcases hguard with hg | hg
      · subst hg; exact id
      · obtain ⟨k, hk⟩ :=
          exists_eq_of_isPlacedCode
            (isPlacedCode_of_between hRO hRS (by rw [hi]; exact hru : f i < u) huj)
        refine (hψ w u).1 ?_
        rw [stateLabel_placed hf w hk]
        exact hg (timeAt b k) (timeAt_mem b k) (hOR i k (by rw [hi, hk]; exact hru))
          (by rw [← hj]; exact hOR k j (by rw [hk]; exact huj))
  · rw [stateLabel_gap w hr] at hmem
    by_cases hz : cutIndex (regionCode f r) = 0
    · rw [hz] at hmem
      have hbelow : ∀ i : BranchTime b, r < f i := (hRS r hr).1 hz
      obtain ⟨t, htmem, htφ, hguard⟩ := untlRayDn_witness hTW hmem
      obtain ⟨j, hj⟩ := exists_index_of_mem_knownTimes htmem
      refine ⟨f j, hbelow j, ?_, ?_⟩
      · exact (hφ w (f j)).1 (by rw [stateLabel_placed hf w (rfl : f j = f j), hj]; exact htφ)
      · intro u hru huj
        rcases hguard with hg | ⟨hl, hg⟩
        · subst hg; exact id
        · refine (hψ w u).1 ?_
          by_cases hu : IsPlacedCode f (regionCode f u)
          · obtain ⟨k, hk⟩ := exists_eq_of_isPlacedCode hu
            rw [stateLabel_placed hf w hk]
            exact hg (timeAt b k) (timeAt_mem b k)
              (by rw [← hj]; exact hOR k j (by rw [hk]; exact huj))
          · rw [stateLabel_gap w hu]
            rcases hRO u hu with h0 | hnn
            · rw [h0]; exact hl
            · exact absurd ((hRS u hu).2 hnn j) (asymm huj)
    · have hn : cutIndex (regionCode f r) = b.knownTimes.length := (hRO r hr).resolve_left hz
      rw [hn] at hmem
      have hev := untlRay_self hTW hmem
      obtain ⟨s, hrs, hgap⟩ := hSt.1 r
      obtain ⟨hs, hsn⟩ := upperRay_of_gt hRO hRS hr hn hrs
      exact ⟨s, hrs, (hφ w s).1 (by rw [stateLabel_gap w hs, hsn]; exact hev),
        fun u hru hus => absurd hus (hgap u hru)⟩

/--
**Since case, positive half.** The past-directed mirror, with the rays swapped.

`snceRay_self` closes the **lower** ray by `Stepped`'s predecessor, and row 10
(`snceRayUp_witness`) carries Correction 12's residual at the **upper** one — the same asymmetry
the negative halves show, running the same way round. Everything else transposes verbatim:
`sncePos_witness` for `untlPos_witness`, `lowerRay_of_lt` for `upperRay_of_gt`, and the guard
interval `(s,r)` sitting *above* the witness rather than below it, which is why row 10's reach is
stated with `strictBefore ord t v` where row 9's is `strictBefore ord v t`.
-/
theorem branchTruthAt_snce_pos (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hOR : OrderReflecting b ord f) (hRO : RayOnly b f) (hRS : RaySplit b f) (hSt : Stepped D)
    (hTW : temporalWitnessCheck b ord = true) {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ)
    (hψ : BranchTruthAt b ord f ψ) (w : WorldIndex) (r : D) :
    b.hasPosAt (Formula.snce ψ φ) (stateLabel b ord f w r) = true →
      TruthAt (normModel b ord f) (regionHistory f w (0 : D)) r
        (Formula.snce ψ φ) := by
  intro hp
  have hmem : (⟨.pos, .snce ψ φ, stateLabel b ord f w r⟩ : SignedFormula) ∈ b :=
    (hasPosAt_iff_mem b _ _).mp hp
  by_cases hr : IsPlacedCode f (regionCode f r)
  · obtain ⟨i, hi⟩ := exists_eq_of_isPlacedCode hr
    rw [stateLabel_placed hf w hi] at hmem
    obtain ⟨t', ht'mem, ht'lt, ht'φ, hguard⟩ := sncePos_witness hTW hmem
    obtain ⟨j, hj⟩ := exists_index_of_mem_knownTimes ht'mem
    refine ⟨f j, by rw [← hi]; exact hOF j i (by rw [hj]; exact ht'lt), ?_, ?_⟩
    · exact (hφ w (f j)).1 (by rw [stateLabel_placed hf w (rfl : f j = f j), hj]; exact ht'φ)
    · intro u hju hur
      rcases hguard with hg | hg
      · subst hg; exact id
      · obtain ⟨k, hk⟩ :=
          exists_eq_of_isPlacedCode
            (isPlacedCode_of_between hRO hRS hju (by rw [hi]; exact hur : u < f i))
        refine (hψ w u).1 ?_
        rw [stateLabel_placed hf w hk]
        exact hg (timeAt b k) (timeAt_mem b k) (hOR k i (by rw [hi, hk]; exact hur))
          (by rw [← hj]; exact hOR j k (by rw [hk]; exact hju))
  · rw [stateLabel_gap w hr] at hmem
    by_cases hn : cutIndex (regionCode f r) = b.knownTimes.length
    · rw [hn] at hmem
      have habove : ∀ i : BranchTime b, f i < r := (hRS r hr).2 hn
      obtain ⟨t, htmem, htφ, hguard⟩ := snceRayUp_witness hTW hmem
      obtain ⟨j, hj⟩ := exists_index_of_mem_knownTimes htmem
      refine ⟨f j, habove j, ?_, ?_⟩
      · exact (hφ w (f j)).1 (by rw [stateLabel_placed hf w (rfl : f j = f j), hj]; exact htφ)
      · intro u hju hur
        rcases hguard with hg | ⟨hl, hg⟩
        · subst hg; exact id
        · refine (hψ w u).1 ?_
          by_cases hu : IsPlacedCode f (regionCode f u)
          · obtain ⟨k, hk⟩ := exists_eq_of_isPlacedCode hu
            rw [stateLabel_placed hf w hk]
            exact hg (timeAt b k) (timeAt_mem b k)
              (by rw [← hj]; exact hOR j k (by rw [hk]; exact hju))
          · rw [stateLabel_gap w hu]
            rcases hRO u hu with h0 | hnn
            · exact absurd ((hRS u hu).1 h0 j) (asymm hju)
            · rw [hnn]; exact hl
    · have hz : cutIndex (regionCode f r) = 0 := (hRO r hr).resolve_right hn
      rw [hz] at hmem
      have hev := snceRay_self hTW hmem
      obtain ⟨s, hsr, hgap⟩ := hSt.2 r
      obtain ⟨hs, hs0⟩ := lowerRay_of_lt hRO hRS hr hz hsr
      exact ⟨s, hsr, (hφ w s).1 (by rw [stateLabel_gap w hs, hs0]; exact hev),
        fun u hsu hur => absurd hsu (hgap u hur)⟩

/-- **Until case**, assembled from its two halves, both sorry-free. -/
theorem branchTruthAt_untl (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hOR : OrderReflecting b ord f) (hRO : RayOnly b f) (hRS : RaySplit b f) (hSt : Stepped D)
    (hV : branchOrderValid b ord = true) (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    (hne : b.knownWorlds ≠ [])
    {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ) (hψ : BranchTruthAt b ord f ψ) :
    BranchTruthAt b ord f (Formula.untl ψ φ) := fun w r =>
  ⟨branchTruthAt_untl_pos hf hOF hOR hRO hRS hSt hTW hφ hψ w r,
    branchTruthAt_untl_neg hf hOR hRO hRS hV hCheck hTW hne hφ w r⟩

/-- **Since case**, assembled from its two halves, both sorry-free. -/
theorem branchTruthAt_snce (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hOR : OrderReflecting b ord f) (hRO : RayOnly b f) (hRS : RaySplit b f) (hSt : Stepped D)
    (hV : branchOrderValid b ord = true) (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    (hne : b.knownWorlds ≠ [])
    {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ) (hψ : BranchTruthAt b ord f ψ) :
    BranchTruthAt b ord f (Formula.snce ψ φ) := fun w r =>
  ⟨branchTruthAt_snce_pos hf hOF hOR hRO hRS hSt hTW hφ hψ w r,
    branchTruthAt_snce_neg hf hOR hRO hRS hV hCheck hTW hne hφ w r⟩

/-! ## The assembled induction

`Formula` has exactly six constructors — `atom`, `bot`, `imp`, `box`, `untl`, `snce`. There are
no `G`/`H`/`F`/`P` constructors: `allFuture φ` is `(untl ⊤ φ.neg).neg`, so every temporal
universal lands on the `untl`/`snce` cases through `imp`.
-/

/-- **The truth lemma**, at every formula, for any placement with no inhabited interior gap. -/
theorem branchTruthAt (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hOR : OrderReflecting b ord f) (hRO : RayOnly b f) (hRS : RaySplit b f) (hSt : Stepped D)
    (hV : branchOrderValid b ord = true) (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    (hne : b.knownWorlds ≠ [])
    (χ : Formula) : BranchTruthAt b ord f χ := by
  induction χ with
  | atom p => exact branchTruthAt_atom hf fc hOpen p
  | bot => exact branchTruthAt_bot fc hOpen
  | imp φ ψ hφ hψ => exact branchTruthAt_imp hSat hφ hψ
  | box φ hφ => exact branchTruthAt_box hf hSat hTot hBA hCheck hne hφ
  | untl ψ φ hψ hφ =>
      exact branchTruthAt_untl hf hOF hOR hRO hRS hSt hV fc hSat hOpen hTot hBA hCheck hTW hne hφ hψ
  | snce ψ φ hψ hφ =>
      exact branchTruthAt_snce hf hOF hOR hRO hRS hSt hV fc hSat hOpen hTot hBA hCheck hTW hne hφ hψ

end Model

/-! ## The `ℤ` instantiation

`Valid` (`Semantics/Validity.lean`) quantifies over every carrier, so **one** carrier refutes it,
and `ℤ` under `finiteOrderEmbInt` is the one whose interior gaps are empty. The placement is
instantiated **directly**, not through `exists_monotone_placement`: that returns an existential
and discards the contiguity, which is the only thing `ℤ` has going for it.
-/

section IntCarrier

variable {b : Branch} {ord : TimeOrdering}

/-- The `ℤ` placement of a gated branch's times. -/
noncomputable def intPlace (b : Branch) (ord : TimeOrdering)
    (hV : branchOrderValid b ord = true) (i : BranchTime b) : ℤ :=
  letI := BranchOrder b ord hV
  finiteOrderEmbInt (BranchTime b) i

theorem intPlace_injective (hV : branchOrderValid b ord = true) :
    Function.Injective (intPlace b ord hV) := by
  letI := BranchOrder b ord hV
  exact (finiteOrderEmbInt (BranchTime b)).injective

/--
The placement is monotone for the **packaged** branch order.

Stated with the packaged order's `le` written out rather than as `≤`, deliberately, and routed
through `RelEmbedding.map_rel_iff` rather than `OrderEmbedding.monotone`. `BranchTime b` is an
`abbrev` for `Fin n`, so bare `i ≤ j` resolves to `Fin`'s own instance and not to
`BranchOrder b ord hV`, and a `letI` does not displace it; separately, the `LE` instance
`finiteOrderEmbInt` carries reaches `LinearOrder` through `DistribLattice` where `Monotone`
reaches it through `Preorder`, and the two paths are defeq but not syntactically equal, so
unification against a metavariable fails. `map_rel_iff` has no instance arguments at all — the
relations come from the embedding's own type — so neither trap can fire. Every consumer goes
through this lemma.
-/
theorem le_intPlace_of_branchLE (hV : branchOrderValid b ord = true) {i j : BranchTime b}
    (h : (BranchOrder b ord hV).le i j) : intPlace b ord hV i ≤ intPlace b ord hV j := by
  letI := BranchOrder b ord hV
  exact (finiteOrderEmbInt (BranchTime b)).map_rel_iff.mpr h

/-- **Order faithfulness at `ℤ`**: a `futureOf` fact is a strict `branchLT` fact
(`lt_of_strictBefore`), hence a `≤` fact whose two sides are distinct, and the placement is
injective. -/
theorem orderFaithful_intPlace (hV : branchOrderValid b ord = true) :
    OrderFaithful b ord (intPlace b ord hV) := by
  intro i j hij
  have hlt : (BranchOrder b ord hV).lt i j := lt_of_strictBefore hV hij
  have hne : i ≠ j := by rintro rfl; exact branchLT_irrefl hV i hlt
  exact lt_of_le_of_ne (le_intPlace_of_branchLE hV (Or.inr hlt))
    (fun hc => hne (intPlace_injective hV hc))

/-- **Order reflection at `ℤ`**: the converse of `orderFaithful_intPlace`.

The packaged order's totality leaves three cases at two known times. Comparability the right way
round is the conclusion; the wrong way round contradicts faithfulness; and *equality of the two
times* is where `timeAt_injective` earns its keep — it collapses the two indices, and a point is
not strictly below itself. -/
theorem orderReflecting_intPlace (hV : branchOrderValid b ord = true) :
    OrderReflecting b ord (intPlace b ord hV) := by
  intro i j hij
  rcases total_of_valid hV (timeAt_mem b i) (timeAt_mem b j) with heq | hs | hs
  · have hij' : i = j := timeAt_injective b heq
    subst hij'
    exact absurd hij (lt_irrefl _)
  · exact hs
  · exact absurd (orderFaithful_intPlace hV j i hs) (asymm hij)

/-- **The rays sit outside the placed block at `ℤ`.** `ray_of_gap_finiteOrderEmbInt` puts a
non-placed integer strictly below `0` or at-or-above `n`, and the placement is exactly `0, …,
n-1`. The two cross terms are vacuous rather than false: a point below `0` has region index `0`,
so demanding that its index be `n` forces `n = 0`, and then there is no placed point to compare
it with. -/
theorem raySplit_intPlace (hV : branchOrderValid b ord = true) :
    RaySplit b (intPlace b ord hV) := by
  letI := BranchOrder b ord hV
  intro r hr
  rcases ray_of_gap_finiteOrderEmbInt (BranchTime b) hr with hlo | hhi
  · have hz : cutIndex (regionCode (intPlace b ord hV) r) = 0 :=
      cutIndex_eq_zero (regionCode_fst_eq_empty_of_neg (BranchTime b) hlo)
    refine ⟨fun _ i => lt_of_lt_of_le hlo (finiteOrderEmbInt_nonneg (BranchTime b) i),
      fun hn i => ?_⟩
    have hlen : b.knownTimes.length = 0 := by omega
    exact absurd i.isLt (by omega)
  · have hu : cutIndex (regionCode (intPlace b ord hV) r) = b.knownTimes.length :=
      cutIndex_eq_length (regionCode_fst_eq_univ_of_card_le (BranchTime b) hhi)
    refine ⟨fun hn i => ?_,
      fun _ i => lt_of_lt_of_le (finiteOrderEmbInt_lt_card (BranchTime b) i) hhi⟩
    have hlen : b.knownTimes.length = 0 := by omega
    exact absurd i.isLt (by omega)

/-- **No inhabited interior gap at `ℤ`**: `ray_of_gap_finiteOrderEmbInt` says a non-placed
integer is on one of the two rays, and `cutIndex_eq_zero`/`cutIndex_eq_length` name those rays
as regions `0` and `n` of the gate's indexing. -/
theorem rayOnly_intPlace (hV : branchOrderValid b ord = true) :
    RayOnly b (intPlace b ord hV) := by
  letI := BranchOrder b ord hV
  intro r hr
  rcases ray_of_gap_finiteOrderEmbInt (BranchTime b) hr with hlo | hhi
  · exact Or.inl (cutIndex_eq_zero (regionCode_fst_eq_empty_of_neg (BranchTime b) hlo))
  · exact Or.inr (cutIndex_eq_length (regionCode_fst_eq_univ_of_card_le (BranchTime b) hhi))

/-- **`ℤ` is stepped**: `r + 1` is an immediate successor and `r - 1` an immediate predecessor.
This is the discharge of the witness-existence obstruction, and it is the whole of it. -/
theorem stepped_int : Stepped ℤ :=
  ⟨fun r => ⟨r + 1, by omega, fun u hu => by omega⟩,
    fun r => ⟨r - 1, by omega, fun u hu => by omega⟩⟩

/-! ### Headline result 1, at `ℤ`

The hypothesis bundle is the open-branch certificate plus the three decidable branch gates.
`findUnexpanded … = none` is the `hasOpen` field verbatim, and it means "no **ordinary** rule
applies" — `serialityRule` is outside `allRulesForFC`, so the branch may still be owed
`T(F ⊤)`/`T(P ⊤)` at every label. Neither this theorem nor anything it calls consumes those, and
both are true at every point of the `ℤ` countermodel regardless.
-/

/--
**`not_valid_of_hasOpen`, at `ℤ`.** A saturated open branch denying `χ` at one of its labels
refutes `Valid χ`.

The countermodel is `normModel b ord (intPlace b ord hV)` over `regionFrame WorldIndex
(BranchTime b) ℤ`, and the base history of
the denying label's own world as the falsifying history.
-/
theorem not_valid_of_hasOpen_int (hV : branchOrderValid b ord = true)
    (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    {χ : Formula} {l₀ : Label} (hw₀ : l₀.world ∈ b.knownWorlds)
    (hroot : (⟨.neg, χ, l₀⟩ : SignedFormula) ∈ b) : ¬ Valid χ := by
  intro hval
  set f := intPlace b ord hV with hf_def
  have hf : Function.Injective f := intPlace_injective hV
  have hne : b.knownWorlds ≠ [] := fun hc => by rw [hc] at hw₀; exact absurd hw₀ (by simp)
  obtain ⟨i, hi⟩ := exists_index_of_mem_knownTimes (mem_knownTimes_of_mem hroot)
  have hlab : stateLabel b ord f l₀.world (f i) = l₀ := by
    rw [stateLabel_placed hf l₀.world (rfl : f i = f i), normWorld_eq_self hw₀, hi]
  have hneg : b.hasNegAt χ (stateLabel b ord f l₀.world (f i)) = true := by
    rw [hlab, hasNegAt_iff_mem]; exact hroot
  exact (branchTruthAt hf (orderFaithful_intPlace hV) (orderReflecting_intPlace hV)
      (rayOnly_intPlace hV) (raySplit_intPlace hV) stepped_int hV fc hSat hOpen hTot hBA hCheck hTW
      hne
      χ l₀.world (f i)).2 hneg
    (hval.apply (regionFrame WorldIndex (BranchTime b) ℤ) (normModel b ord f)
      (regionHistory f l₀.world (0 : ℤ)) (fun _ => trivial) (f i))

/--
**The `ValidDiscrete` companion.** `ℤ` carries `SuccOrder`, `PredOrder`, `IsSuccArchimedean` and
`IsPredArchimedean`, which is what `.Discrete`'s binder list adds; the countermodel and the truth
lemma are the same objects, so the two results differ only in which binder list is discharged.
-/
theorem not_validDiscrete_of_hasOpen_int (hV : branchOrderValid b ord = true)
    (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hTW : temporalWitnessCheck b ord = true)
    {χ : Formula} {l₀ : Label} (hw₀ : l₀.world ∈ b.knownWorlds)
    (hroot : (⟨.neg, χ, l₀⟩ : SignedFormula) ∈ b) : ¬ ValidDiscrete χ := by
  intro hval
  set f := intPlace b ord hV with hf_def
  have hf : Function.Injective f := intPlace_injective hV
  have hne : b.knownWorlds ≠ [] := fun hc => by rw [hc] at hw₀; exact absurd hw₀ (by simp)
  obtain ⟨i, hi⟩ := exists_index_of_mem_knownTimes (mem_knownTimes_of_mem hroot)
  have hlab : stateLabel b ord f l₀.world (f i) = l₀ := by
    rw [stateLabel_placed hf l₀.world (rfl : f i = f i), normWorld_eq_self hw₀, hi]
  have hneg : b.hasNegAt χ (stateLabel b ord f l₀.world (f i)) = true := by
    rw [hlab, hasNegAt_iff_mem]; exact hroot
  exact (branchTruthAt hf (orderFaithful_intPlace hV) (orderReflecting_intPlace hV)
      (rayOnly_intPlace hV) (raySplit_intPlace hV) stepped_int hV fc hSat hOpen hTot hBA hCheck hTW
      hne
      χ l₀.world (f i)).2 hneg
    (ValidIn.apply_total hval (regionFrame WorldIndex (BranchTime b) ℤ)
      (TaskFrame.isSuccArchDiscrete_of_instances _) (normModel b ord f)
      (regionHistory f l₀.world (0 : ℤ)) (fun _ => trivial) (f i))

end IntCarrier

end FormalSystem.Metalogic.Decidability.Verified.Bridge
