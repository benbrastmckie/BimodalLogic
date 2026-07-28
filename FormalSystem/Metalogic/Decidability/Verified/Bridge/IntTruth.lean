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
      TruthAt (normModel b ord f) (regionOmega f) (regionHistory f w (0 : D)) r φ) ∧
    (b.hasNegAt φ (stateLabel b ord f w r) = true →
      ¬ TruthAt (normModel b ord f) (regionOmega f) (regionHistory f w (0 : D)) r φ)

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

/-! ## The temporal cases — OWED, and precisely bounded

These are the two cases this dispatch does **not** close, and they are stated rather than omitted
so that the remaining obligation is exactly two named lemmas with a fixed hypothesis bundle,
rather than an unscoped "run the induction". Everything else in this file is sorry-free and the
build is green.

### What is missing, item by item

1. **`sat_untl_pos` discards the ordering.** It concludes `∃ t' ∈ b.knownTimes, T(event) @ t' ∨
   (T(guard) @ t' ∧ T(U) @ t')` — with no relation between `t'` and the until's own time. The
   ordering is present in the proof and thrown away: `witnessPresent` scans
   `timeOrd.futureOf t`, and the existing proof binds that membership to `_` before replacing it
   with `mem_knownTimes_of_mem`. A strengthened `sat_untl_pos_future` keeping
   `strictBefore ord t t' = true` is the first item, and it is a re-run of the existing proof,
   not a new argument. `sat_snce_pos` is the mirror.
2. **The witness has to be the *earliest* one.** `TruthAt … (untl φ ψ)` demands `ψ` at every
   point strictly between the evaluation point and the witness. The saturation fact's second
   disjunct (`T(guard)` and the until again, at `t'`) is the step of an iteration, and the
   iteration needs a decreasing measure: `b.knownTimes.length - branchRank b ord t'` is the
   obvious one, and `branchRank` (`Bridge/RegionLabel.lean`) already exists for the gate.
3. **The ray self-demand.** An upper-ray point has no point above it outside its own ray, so
   `T(U(φ,ψ))` at the ray's chosen label needs `T(φ)` at that same label. No row of
   `regionLabelCheck` asks for this. `Tests/BimodalTest/RayRegionProbe.lean` measures it on the
   engine corpus **before** it is stated here: `rayUp` and `rayDn` are `true` on all six engine
   rows alongside `check=true`, and row G is a synthetic branch with `check=true rayUp=false`, so
   the condition is a real strengthening the engine happens to satisfy. It is therefore a
   candidate additional gate row in the family `timeOrderTotal`/`boxAnchoredCheck`/
   `regionLabelCheck` already belong to — not a refutation of the gate, and not a reason to
   restate the region labelling.
4. **Region invariance is unavailable at `ℤ`.** `interpInvariantAt` (`Bridge/TruthLemma.lean`)
   needs `DenselyOrdered D`, and `not_exists_gt_sameRegion_int` (`Bridge/Interpolate.lean`) is
   the machine witness that the `untl` case's `exists_gt_sameRegion` step genuinely fails at
   `ℤ`. So the two rays are infinite regions whose points must be handled one at a time here,
   where at `ℚ`/`ℝ` one invariance lemma handles each region wholesale. **This corrects the
   premise on which `ℤ` was scheduled first**: contiguity empties the *interior*, and buys
   nothing on the rays.

None of 1–4 touches an engine file, the region labelling, or any interface already landed.
-/

/-- **Until case — OWED.** See the section docstring for the four items this needs. -/
theorem branchTruthAt_untl (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hRO : RayOnly b f) (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hne : b.knownWorlds ≠ [])
    {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ) (hψ : BranchTruthAt b ord f ψ) :
    BranchTruthAt b ord f (Formula.untl φ ψ) := by
  sorry

/-- **Since case — OWED.** The past-directed mirror of `branchTruthAt_untl`. -/
theorem branchTruthAt_snce (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hRO : RayOnly b f) (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hne : b.knownWorlds ≠ [])
    {φ ψ : Formula} (hφ : BranchTruthAt b ord f φ) (hψ : BranchTruthAt b ord f ψ) :
    BranchTruthAt b ord f (Formula.snce φ ψ) := by
  sorry

/-! ## The assembled induction

`Formula` has exactly six constructors — `atom`, `bot`, `imp`, `box`, `untl`, `snce`. There are
no `G`/`H`/`F`/`P` constructors: `allFuture φ` is `(untl φ.neg ⊤).neg`, so every temporal
universal lands on the `untl`/`snce` cases through `imp`.
-/

/-- **The truth lemma**, at every formula, for any placement with no inhabited interior gap. -/
theorem branchTruthAt (hf : Function.Injective f) (hOF : OrderFaithful b ord f)
    (hRO : RayOnly b f) (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true) (hne : b.knownWorlds ≠ [])
    (χ : Formula) : BranchTruthAt b ord f χ := by
  induction χ with
  | atom p => exact branchTruthAt_atom hf fc hOpen p
  | bot => exact branchTruthAt_bot fc hOpen
  | imp φ ψ hφ hψ => exact branchTruthAt_imp hSat hφ hψ
  | box φ hφ => exact branchTruthAt_box hf hSat hTot hBA hCheck hne hφ
  | untl φ ψ hφ hψ =>
      exact branchTruthAt_untl hf hOF hRO fc hSat hOpen hTot hBA hCheck hne hφ hψ
  | snce φ ψ hφ hψ =>
      exact branchTruthAt_snce hf hOF hRO fc hSat hOpen hTot hBA hCheck hne hφ hψ

end Model

/-! ## The `ℤ` instantiation

`valid` (`Semantics/Validity.lean`) quantifies over every carrier, so **one** carrier refutes it,
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

/-! ### Headline result 1, at `ℤ`

The hypothesis bundle is the open-branch certificate plus the three decidable branch gates.
`findUnexpanded … = none` is the `hasOpen` field verbatim, and it means "no **ordinary** rule
applies" — `serialityRule` is outside `allRulesForFC`, so the branch may still be owed
`T(F ⊤)`/`T(P ⊤)` at every label. Neither this theorem nor anything it calls consumes those, and
both are true at every point of the `ℤ` countermodel regardless.
-/

/--
**`not_valid_of_hasOpen`, at `ℤ`.** A saturated open branch denying `χ` at one of its labels
refutes `valid χ`.

The countermodel is `normModel b ord (intPlace b ord hV)` over `regionFrame WorldIndex
(BranchTime b) ℤ`, with `regionOmega` as the shift-closed admissible set and the base history of
the denying label's own world as the falsifying history.
-/
theorem not_valid_of_hasOpen_int (hV : branchOrderValid b ord = true)
    (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true)
    {χ : Formula} {l₀ : Label} (hw₀ : l₀.world ∈ b.knownWorlds)
    (hroot : (⟨.neg, χ, l₀⟩ : SignedFormula) ∈ b) : ¬ valid χ := by
  intro hval
  set f := intPlace b ord hV with hf_def
  have hf : Function.Injective f := intPlace_injective hV
  have hne : b.knownWorlds ≠ [] := fun hc => by rw [hc] at hw₀; exact absurd hw₀ (by simp)
  obtain ⟨i, hi⟩ := exists_index_of_mem_knownTimes (mem_knownTimes_of_mem hroot)
  have hlab : stateLabel b ord f l₀.world (f i) = l₀ := by
    rw [stateLabel_placed hf l₀.world (rfl : f i = f i), normWorld_eq_self hw₀, hi]
  have hneg : b.hasNegAt χ (stateLabel b ord f l₀.world (f i)) = true := by
    rw [hlab, hasNegAt_iff_mem]; exact hroot
  exact (branchTruthAt hf (orderFaithful_intPlace hV) (rayOnly_intPlace hV) fc hSat hOpen hTot
      hBA hCheck hne χ l₀.world (f i)).2 hneg
    (hval ℤ (regionFrame WorldIndex (BranchTime b) ℤ) (normModel b ord f) (regionOmega f)
      (shiftClosed_regionOmega f) (regionHistory f l₀.world (0 : ℤ))
      (regionHistory_mem_regionOmega f l₀.world 0) (f i))

/--
**The `ValidDiscrete` companion.** `ℤ` carries `SuccOrder`, `PredOrder`, `IsSuccArchimedean` and
`IsPredArchimedean`, which is what `.Discrete`'s binder list adds; the countermodel and the truth
lemma are the same objects, so the two results differ only in which binder list is discharged.
-/
theorem not_validDiscrete_of_hasOpen_int (hV : branchOrderValid b ord = true)
    (fc : ProofSystem.FrameClass)
    (hSat : findUnexpanded b (timeOrd := ord) = none) (hOpen : findClosure b fc = none)
    (hTot : timeOrderTotal b ord = true) (hBA : boxAnchoredCheck b = true)
    (hCheck : regionLabelCheck b ord = true)
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
  exact (branchTruthAt hf (orderFaithful_intPlace hV) (rayOnly_intPlace hV) fc hSat hOpen hTot
      hBA hCheck hne χ l₀.world (f i)).2 hneg
    (hval ℤ (regionFrame WorldIndex (BranchTime b) ℤ) (normModel b ord f) (regionOmega f)
      (shiftClosed_regionOmega f) (regionHistory f l₀.world (0 : ℤ))
      (regionHistory_mem_regionOmega f l₀.world 0) (f i))

end IntCarrier

end FormalSystem.Metalogic.Decidability.Verified.Bridge
