/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.BoundedFix

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! # Anchored Corollary 5.4 mirrors

Case 2 of the fixed-formula negation recursion (`BracketFormula.negFix`,
Phase 10b) peels the outermost point type `α` of a bracket, leaving the shape
`¬∃ z ∈ (z0, z1), α(z) ∧ peeled.holds … z0 z` — the peeled point type sits AT
the moving endpoint, and no plain bracket expresses a point type at its own
endpoint (machine-refuted on discrete carriers; Phase 10a handoff, design
note 1). The fix is the ANCHORED generalization of the Phase 9 Cor 5.4
machinery: parametrize the innermost fold goal of `untilFold`/`sinceFold` by
the peeled point type `α` (the Phase 9 code is the `α := ⊤` instance), with
the suffix-fold chain predicates carrying `α` as their last entry. The
paper's relink case split (`y ≤ c / y > c`) survives unchanged with the
anchor. Base case: `∃ z ∈ (z0, z1), α(z) ∧ (β on (z0, z))  ⟺
(β Until α)(z0) ∧ ∃ c ∈ (z0, z1), α(c)`. -/

/-! ## The anchored Until fold -/

/-- Anchored `untilFold`: `untilFoldAnchored α [(α_0, β_1), …, (α_{n-1}, β_n)]`
    is `α_0 ∧ (β_1 Until (α_1 ∧ (… ∧ (β_n Until α))))` — the innermost goal
    is the anchor `α` instead of `⊤`, so the moved right endpoint carries the
    peeled point type. `untilFold` is the `α := ⊤` instance constructor by
    constructor. -/
def untilFoldAnchored (α : TemporalPred) :
    List (TemporalPred × TemporalPred) → TemporalPred
  | [] => α
  | (a, b) :: rest => a.conj (TemporalPred.untl (untilFoldAnchored α rest) b)

/-- Anchored chain predicates `[F_1, …, F_{n+1}]`: the anchored Until folds
    of all suffixes of the pair list (last entry the anchor `α`). -/
def untilChainPredsAnchored (α : TemporalPred)
    (ps : List (TemporalPred × TemporalPred)) : List TemporalPred :=
  ps.tails.map (untilFoldAnchored α)

theorem untilChainPredsAnchored_nil (α : TemporalPred) :
    untilChainPredsAnchored α [] = [α] := rfl

theorem untilChainPredsAnchored_cons (α a b : TemporalPred)
    (ps : List (TemporalPred × TemporalPred)) :
    untilChainPredsAnchored α ((a, b) :: ps) =
      untilFoldAnchored α ((a, b) :: ps) :: untilChainPredsAnchored α ps := by
  simp [untilChainPredsAnchored]

/-! ## Anchored Cor 5.4(1): the chain observation -/

/-- **Anchored Cor 5.4(1) chain observation**: a bracket instance ending at
    an `α`-point `z ∈ (z0, z1)` exists iff the head anchored Until-fold
    `F̂ = s Until F_1` holds at `z0` and a pointwise increasing chain of the
    anchored suffix folds exists in `(z0, z1)`. The `α := ⊤` instance is
    `exists_bracketOf_right_iff`; the relink `y ≤ c / y > c` case split is
    unchanged — the anchor rides in the fold goals and the chain entries. -/
theorem exists_bracketOf_right_anchored_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (α : TemporalPred) :
    ∀ (ps : List (TemporalPred × TemporalPred)) (s : TemporalPred)
      (z0 z1 : M.carrier), z0 < z1 →
    ((∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
        (bracketOf s ps).holds M atomMap z0 z) ↔
      ((TemporalPred.untl (untilFoldAnchored α ps) s).eval_at M atomMap z0 ∧
       (chainAllTrue (untilChainPredsAnchored α ps)).holds M atomMap z0 z1)) := by
  intro ps
  induction ps with
  | nil =>
    intro s z0 z1 _h_lt
    rw [untilChainPredsAnchored_nil, TemporalPred.eval_at_untl,
      chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨z, hz0, hz1, hzα, hz⟩
      rw [bracketOf_nil_holds_iff] at hz
      exact ⟨⟨z, hz0, hzα, fun w h1 h2 => hz w h1 h2⟩,
        ⟨z, hz0, hz1, hzα, chainAllTrue_nil_holds M atomMap z z1⟩⟩
    · rintro ⟨⟨y, hy0, hyα, hyseg⟩, ⟨c, hc0, hc1, hcα, _⟩⟩
      rcases le_or_gt y c with h | h
      · exact ⟨y, hy0, lt_of_le_of_lt h hc1, hyα,
          (bracketOf_nil_holds_iff M atomMap s z0 y).mpr hyseg⟩
      · exact ⟨c, hc0, hc1, hcα,
          (bracketOf_nil_holds_iff M atomMap s z0 c).mpr
            (fun w h1 h2 => hyseg w h1 (lt_trans h2 h))⟩
  | cons ab rest ih =>
    obtain ⟨a, b⟩ := ab
    intro s z0 z1 h_lt
    rw [untilChainPredsAnchored_cons, TemporalPred.eval_at_untl,
      chainAllTrue_cons_holds_iff]
    constructor
    · -- α-anchored bracket instance → F̂(z0) ∧ chain
      rintro ⟨z, hz0, hz1, hzα, hz⟩
      rw [bracketOf_cons_holds_iff] at hz
      obtain ⟨r, hr0, hrz, hrseg, hra, hrtail⟩ := hz
      have h_rz1 : r < z1 := lt_trans hrz hz1
      obtain ⟨hFhat_r, hchain_rest⟩ :=
        (ih b r z1 h_rz1).mp ⟨z, hrz, hz1, hzα, hrtail⟩
      have hFr : (untilFoldAnchored α ((a, b) :: rest)).eval_at M atomMap r := by
        rw [show untilFoldAnchored α ((a, b) :: rest) =
              a.conj (TemporalPred.untl (untilFoldAnchored α rest) b) from rfl,
          TemporalPred.eval_at_conj]
        exact ⟨hra, hFhat_r⟩
      exact ⟨⟨r, hr0, hFr, hrseg⟩,
        ⟨r, hr0, h_rz1, hFr, hchain_rest⟩⟩
    · -- F̂(z0) ∧ chain → α-anchored bracket instance (the relink step)
      rintro ⟨⟨y, hy0, hyF, hyseg⟩, ⟨c, hc0, hc1, hcF, hcchain⟩⟩
      rw [show untilFoldAnchored α ((a, b) :: rest) =
            a.conj (TemporalPred.untl (untilFoldAnchored α rest) b) from rfl,
        TemporalPred.eval_at_conj] at hyF hcF
      -- pick the first bracket witness r: y if y ≤ c, else c
      rcases le_or_gt y c with hyc | hcy
      · -- r := y (the Until witness is in bounds)
        have h_yz1 : y < z1 := lt_of_le_of_lt hyc hc1
        have hchain_y :
            (chainAllTrue (untilChainPredsAnchored α rest)).holds M atomMap y z1 :=
          chainAllTrue_holds_mono_left M atomMap _ hyc hcchain
        obtain ⟨z, hz1, hz2, hzα, hz3⟩ :=
          (ih b y z1 h_yz1).mpr ⟨hyF.2, hchain_y⟩
        exact ⟨z, lt_trans hy0 hz1, hz2, hzα,
          (bracketOf_cons_holds_iff M atomMap s a b rest z0 z).mpr
            ⟨y, hy0, hz1, hyseg, hyF.1, hz3⟩⟩
      · -- r := c (the chain point relinks)
        have hcseg : ∀ w : M.carrier, z0 < w → w < c → s.eval_at M atomMap w :=
          fun w h1 h2 => hyseg w h1 (lt_trans h2 hcy)
        obtain ⟨z, hz1, hz2, hzα, hz3⟩ :=
          (ih b c z1 hc1).mpr ⟨hcF.2, hcchain⟩
        exact ⟨z, lt_trans hc0 hz1, hz2, hzα,
          (bracketOf_cons_holds_iff M atomMap s a b rest z0 z).mpr
            ⟨c, hc0, hz1, hcseg, hcF.1, hz3⟩⟩

/-! ## Anchored Cor 5.4(1): assembly -/

/-- Head decomposition of the anchored chain-predicate list. -/
theorem untilChainPredsAnchored_head_cons (α : TemporalPred)
    (ps : List (TemporalPred × TemporalPred)) :
    ∃ L, untilChainPredsAnchored α ps = untilFoldAnchored α ps :: L := by
  cases ps with
  | nil => exact ⟨[], rfl⟩
  | cons ab rest =>
    obtain ⟨a, b⟩ := ab
    exact ⟨untilChainPredsAnchored α rest, untilChainPredsAnchored_cons α a b rest⟩

/-- **Anchored Cor 5.4(1), fixed formula**: the V-bracket formula equivalent
    to `¬∃ z ∈ (z0, z1), α(z) ∧ bf.holds z0 z` on attained-INF structures.
    Same disjunct shape as `negBoundedRightFix` (= the `α := ⊤` instance):
    the first-`¬β₀` pin plus the Lemma 5.3 chain negation, both over the
    anchored folds. -/
def negBoundedRightFixAnchored (α : TemporalPred) {n : Nat}
    (bf : BracketFormula n) : VBracketFormula :=
  ⟨⟨1, rightPinBracket (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)
        (untilFoldAnchored α bf.foldPairs)⟩ ::
    (negChainOn (untilChainPredsAnchored α bf.foldPairs)).disjuncts⟩

/-- **Anchored Cor 5.4(1) iff**: on attained-INF structures,
    `negBoundedRightFixAnchored α bf` holds on `(z0, z1)` iff no `α`-point
    `z ∈ (z0, z1)` satisfies the bracket `bf` on `(z0, z)`. This is the
    Case 2 consumer shape for `BracketFormula.negFix` (Phase 10b-ii). -/
theorem negBoundedRightFixAnchored_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (α : TemporalPred)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedRightFixAnchored α bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
      bf.holds M atomMap z0 z := by
  -- Normalize the right side through the bridge and the anchored chain
  -- observation.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
      bf.holds M atomMap z0 z) ↔
      ((TemporalPred.untl (untilFoldAnchored α bf.foldPairs)
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)).eval_at M atomMap z0 ∧
       (chainAllTrue (untilChainPredsAnchored α bf.foldPairs)).holds
          M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, hα, h3⟩
      exact (exists_bracketOf_right_anchored_iff M atomMap α bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, hα,
          (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, hα, h3⟩ :=
        (exists_bracketOf_right_anchored_iff M atomMap α bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2, hα,
        (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mpr h3⟩
  constructor
  · -- some disjunct holds → no anchored bracket instance
    rintro ⟨d, hmem, hh⟩ hex
    obtain ⟨hFhat, hchain⟩ := h_rhs.mp hex
    rcases List.mem_cons.mp hmem with heq | hmem'
    · -- pin disjunct
      subst heq
      obtain ⟨r, _h1, _h2, h3, h4, h5⟩ :=
        (rightPinBracket_holds_iff M atomMap _ _ z0 z1).mp hh
      rw [TemporalPred.eval_at_untl] at hFhat
      obtain ⟨y, hy0, hyF1, hyseg⟩ := hFhat
      rcases lt_trichotomy y r with hlt | heqq | hgt
      · exact (h3 y hy0 hlt).2 hyF1
      · exact h5 (heqq ▸ hyF1)
      · exact h4 (hyseg r _h1 hgt)
    · -- chain-negation disjunct
      exact (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mp ⟨d, hmem', hh⟩ hchain
  · -- no anchored bracket instance → some disjunct holds
    intro hnex
    by_cases hchain :
      (chainAllTrue (untilChainPredsAnchored α bf.foldPairs)).holds M atomMap z0 z1
    · -- chain exists, so F̂ must fail at z0: build the pin
      refine ⟨_, List.mem_cons_self .., ?_⟩
      show (rightPinBracket (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)
          (untilFoldAnchored α bf.foldPairs)).holds M atomMap z0 z1
      rw [rightPinBracket_holds_iff]
      have hnFhat : ¬ (TemporalPred.untl (untilFoldAnchored α bf.foldPairs)
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)).eval_at M atomMap z0 :=
        fun hFhat => hnex (h_rhs.mpr ⟨hFhat, hchain⟩)
      have h_no : ∀ y : M.carrier, z0 < y →
          (untilFoldAnchored α bf.foldPairs).eval_at M atomMap y →
          ¬(∀ w : M.carrier, z0 < w → w < y →
            (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).eval_at M atomMap w) :=
        fun y hy0 hyF hseg => hnFhat
          ((TemporalPred.eval_at_untl M atomMap _ _ z0).mpr ⟨y, hy0, hyF, hseg⟩)
      -- first chain point c carries F₁
      obtain ⟨L, hL⟩ := untilChainPredsAnchored_head_cons α bf.foldPairs
      rw [hL, chainAllTrue_cons_holds_iff] at hchain
      obtain ⟨c, hc0, hc1, hcF1, -⟩ := hchain
      -- ¬β₀ occurs below c (else y := c would witness F̂)
      have h_fail : ∃ w : M.carrier, z0 < w ∧ w < c ∧
          ¬(bf.segmentTypes ⟨0, Nat.succ_pos n⟩).eval_at M atomMap w := by
        by_contra hcon
        push_neg at hcon
        exact h_no c hc0 hcF1 hcon
      obtain ⟨w0, hw1, hw2, hw3⟩ := h_fail
      obtain ⟨r0, hr00, hr01, hr0neg, hr0first⟩ :=
        h_INF.first_occ_tp (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).neg z0 z1 h_lt
          ⟨w0, hw1, lt_trans hw2 hc1,
            (TemporalPred.eval_at_neg' M atomMap _ w0).mpr hw3⟩
      have hs_before : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).eval_at M atomMap y := by
        intro y hy0 hy1
        have := hr0first y hy0 hy1
        rw [TemporalPred.eval_at_neg'] at this
        exact not_not.mp this
      refine ⟨r0, hr00, hr01, ?_, ?_, ?_⟩
      · intro y hy0 hy1
        refine ⟨hs_before y hy0 hy1, fun hF1y => ?_⟩
        exact h_no y hy0 hF1y (fun w h1 h2 => hs_before w h1 (lt_trans h2 hy1))
      · exact (TemporalPred.eval_at_neg' M atomMap _ r0).mp hr0neg
      · exact fun hF1r0 => h_no r0 hr00 hF1r0 hs_before
    · -- chain fails: the Lemma 5.3 disjuncts cover it
      obtain ⟨d, hmem, hh⟩ :=
        (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mpr hchain
      exact ⟨d, List.mem_cons_of_mem _ hmem, hh⟩

/-! ## The anchored Since fold (the mirror) -/

/-- Anchored `sinceFold`: the innermost goal is the anchor `α` instead of
    `⊤`, so the moved left endpoint carries the peeled point type. -/
def sinceFoldAnchored (α : TemporalPred) :
    List (TemporalPred × TemporalPred) → TemporalPred
  | [] => α
  | (a, b) :: rest => a.conj (TemporalPred.snce (sinceFoldAnchored α rest) b)

/-- Anchored mirror chain predicates: the anchored Since folds of all
    suffixes of the reversed pair list, in increasing chain order (first
    entry the anchor `α`). -/
def sinceChainPredsAnchored (α : TemporalPred)
    (mps : List (TemporalPred × TemporalPred)) : List TemporalPred :=
  (mps.tails.map (sinceFoldAnchored α)).reverse

theorem sinceChainPredsAnchored_nil (α : TemporalPred) :
    sinceChainPredsAnchored α [] = [α] := rfl

theorem sinceChainPredsAnchored_cons (α a b : TemporalPred)
    (mps : List (TemporalPred × TemporalPred)) :
    sinceChainPredsAnchored α ((a, b) :: mps) =
      sinceChainPredsAnchored α mps ++ [sinceFoldAnchored α ((a, b) :: mps)] := by
  simp [sinceChainPredsAnchored]

/-- Last-element decomposition of the anchored mirror chain-predicate
    list. -/
theorem sinceChainPredsAnchored_last_snoc (α : TemporalPred)
    (mps : List (TemporalPred × TemporalPred)) :
    ∃ L, sinceChainPredsAnchored α mps = L ++ [sinceFoldAnchored α mps] := by
  cases mps with
  | nil => exact ⟨[], rfl⟩
  | cons ab rest =>
    obtain ⟨a, b⟩ := ab
    exact ⟨sinceChainPredsAnchored α rest, sinceChainPredsAnchored_cons α a b rest⟩

/-! ## Anchored Cor 5.4(2): the mirror chain observation -/

/-- **Anchored Cor 5.4(2) chain observation**: a bracket instance starting
    at an `α`-point `z ∈ (z0, z1)` exists iff the trailing anchored
    Since-fold `Ĝ = s Since G` holds at `z1` and a pointwise increasing
    chain of the anchored mirror folds exists in `(z0, z1)`. The `α := ⊤`
    instance is `exists_bracketSnocOf_left_iff`. -/
theorem exists_bracketSnocOf_left_anchored_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (α : TemporalPred) :
    ∀ (mps : List (TemporalPred × TemporalPred)) (s : TemporalPred)
      (z0 z1 : M.carrier), z0 < z1 →
    ((∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
        (bracketSnocOf s mps).holds M atomMap z z1) ↔
      ((TemporalPred.snce (sinceFoldAnchored α mps) s).eval_at M atomMap z1 ∧
       (chainAllTrue (sinceChainPredsAnchored α mps)).holds M atomMap z0 z1)) := by
  intro mps
  induction mps with
  | nil =>
    intro s z0 z1 _h_lt
    rw [sinceChainPredsAnchored_nil, TemporalPred.eval_at_snce,
      chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨z, hz0, hz1, hzα, hz⟩
      rw [bracketSnocOf_nil_holds_iff] at hz
      exact ⟨⟨z, hz1, hzα, fun w h1 h2 => hz w h1 h2⟩,
        ⟨z, hz0, hz1, hzα, chainAllTrue_nil_holds M atomMap z z1⟩⟩
    · rintro ⟨⟨y, hy1, hyα, hyseg⟩, ⟨c, hc0, hc1, hcα, _⟩⟩
      rcases le_or_gt c y with h | h
      · exact ⟨y, lt_of_lt_of_le hc0 h, hy1, hyα,
          (bracketSnocOf_nil_holds_iff M atomMap s y z1).mpr hyseg⟩
      · exact ⟨c, hc0, hc1, hcα,
          (bracketSnocOf_nil_holds_iff M atomMap s c z1).mpr
            (fun w h1 h2 => hyseg w (lt_trans h h1) h2)⟩
  | cons ab rest ih =>
    obtain ⟨a, b⟩ := ab
    intro s z0 z1 h_lt
    rw [TemporalPred.eval_at_snce, sinceChainPredsAnchored_cons]
    constructor
    · -- α-anchored bracket instance → Ĝ(z1) ∧ chain
      rintro ⟨z, hz0, hz1, hzα, hz⟩
      rw [bracketSnocOf_cons_holds_iff] at hz
      obtain ⟨x, hzx, hxz1, hxfront, hxa, hxseg⟩ := hz
      have h_z0x : z0 < x := lt_trans hz0 hzx
      obtain ⟨hGhat_x, hchain_rest⟩ :=
        (ih b z0 x h_z0x).mp ⟨z, hz0, hzx, hzα, hxfront⟩
      have hGx : (sinceFoldAnchored α ((a, b) :: rest)).eval_at M atomMap x := by
        rw [show sinceFoldAnchored α ((a, b) :: rest) =
              a.conj (TemporalPred.snce (sinceFoldAnchored α rest) b) from rfl,
          TemporalPred.eval_at_conj]
        exact ⟨hxa, hGhat_x⟩
      exact ⟨⟨x, hxz1, hGx, hxseg⟩,
        (chainAllTrue_snoc_holds_iff M atomMap _ _ z0 z1).mpr
          ⟨x, h_z0x, hxz1, hchain_rest, hGx⟩⟩
    · -- Ĝ(z1) ∧ chain → α-anchored bracket instance (the mirrored relink)
      rintro ⟨⟨y, hy1, hyG, hyseg⟩, hchain⟩
      obtain ⟨c, hc0, hc1, hcchain, hcG⟩ :=
        (chainAllTrue_snoc_holds_iff M atomMap _ _ z0 z1).mp hchain
      rw [show sinceFoldAnchored α ((a, b) :: rest) =
            a.conj (TemporalPred.snce (sinceFoldAnchored α rest) b) from rfl,
        TemporalPred.eval_at_conj] at hyG hcG
      rcases le_or_gt c y with hcy | hyc
      · -- x := y (the Since witness is in bounds)
        have h_z0y : z0 < y := lt_of_lt_of_le hc0 hcy
        have hchain_y :
            (chainAllTrue (sinceChainPredsAnchored α rest)).holds M atomMap z0 y :=
          chainAllTrue_holds_mono_right M atomMap _ hcy hcchain
        obtain ⟨z, hz1, hz2, hzα, hz3⟩ :=
          (ih b z0 y h_z0y).mpr ⟨hyG.2, hchain_y⟩
        exact ⟨z, hz1, lt_trans hz2 hy1, hzα,
          (bracketSnocOf_cons_holds_iff M atomMap s a b rest z z1).mpr
            ⟨y, hz2, hy1, hz3, hyG.1, hyseg⟩⟩
      · -- x := c (the chain point relinks)
        have hcseg : ∀ w : M.carrier, c < w → w < z1 → s.eval_at M atomMap w :=
          fun w h1 h2 => hyseg w (lt_trans hyc h1) h2
        obtain ⟨z, hz1, hz2, hzα, hz3⟩ :=
          (ih b z0 c hc0).mpr ⟨hcG.2, hcchain⟩
        exact ⟨z, hz1, lt_trans hz2 hc1, hzα,
          (bracketSnocOf_cons_holds_iff M atomMap s a b rest z z1).mpr
            ⟨c, hz2, hc1, hz3, hcG.1, hcseg⟩⟩

/-! ## Anchored Cor 5.4(2): assembly -/

/-- **Anchored Cor 5.4(2), fixed formula**: the V-bracket formula equivalent
    to `¬∃ z ∈ (z0, z1), α(z) ∧ bf.holds z z1`. Mirror of
    `negBoundedRightFixAnchored`: last-`¬β_n` pin plus the Lemma 5.3 chain
    negation over the anchored Since folds. -/
def negBoundedLeftFixAnchored (α : TemporalPred) {n : Nat}
    (bf : BracketFormula n) : VBracketFormula :=
  ⟨⟨1, leftPinBracket (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
        (sinceFoldAnchored α bf.foldPairsRev)⟩ ::
    (negChainOn (sinceChainPredsAnchored α bf.foldPairsRev)).disjuncts⟩

/-- **Anchored Cor 5.4(2) iff**: on structures with attained infima AND
    suprema, `negBoundedLeftFixAnchored α bf` holds on `(z0, z1)` iff no
    `α`-point `z ∈ (z0, z1)` satisfies the bracket `bf` on `(z, z1)`. This
    is the mirror Case 2 consumer shape for `BracketFormula.negFix`
    (Phase 10b-ii). -/
theorem negBoundedLeftFixAnchored_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (α : TemporalPred)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedLeftFixAnchored α bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
      bf.holds M atomMap z z1 := by
  -- Normalize the right side through the mirror bridge and the anchored
  -- mirror chain observation.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ α.eval_at M atomMap z ∧
      bf.holds M atomMap z z1) ↔
      ((TemporalPred.snce (sinceFoldAnchored α bf.foldPairsRev)
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)).eval_at M atomMap z1 ∧
       (chainAllTrue (sinceChainPredsAnchored α bf.foldPairsRev)).holds
          M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, hα, h3⟩
      exact (exists_bracketSnocOf_left_anchored_iff M atomMap α bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, hα,
          (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, hα, h3⟩ :=
        (exists_bracketSnocOf_left_anchored_iff M atomMap α bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2, hα,
        (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mpr h3⟩
  constructor
  · -- some disjunct holds → no anchored bracket instance
    rintro ⟨d, hmem, hh⟩ hex
    obtain ⟨hGhat, hchain⟩ := h_rhs.mp hex
    rcases List.mem_cons.mp hmem with heq | hmem'
    · -- pin disjunct
      subst heq
      obtain ⟨r, _h1, _h2, h3, h4, h5⟩ :=
        (leftPinBracket_holds_iff M atomMap _ _ z0 z1).mp hh
      rw [TemporalPred.eval_at_snce] at hGhat
      obtain ⟨y, hy1, hyG, hyseg⟩ := hGhat
      rcases lt_trichotomy r y with hlt | heqq | hgt
      · exact (h5 y hlt hy1).2 hyG
      · exact h4 (heqq ▸ hyG)
      · exact h3 (hyseg r hgt _h2)
    · -- chain-negation disjunct
      exact (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mp ⟨d, hmem', hh⟩ hchain
  · -- no anchored bracket instance → some disjunct holds
    intro hnex
    by_cases hchain :
      (chainAllTrue (sinceChainPredsAnchored α bf.foldPairsRev)).holds
        M atomMap z0 z1
    · -- chain exists, so Ĝ must fail at z1: build the mirror pin
      refine ⟨_, List.mem_cons_self .., ?_⟩
      show (leftPinBracket (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
          (sinceFoldAnchored α bf.foldPairsRev)).holds M atomMap z0 z1
      rw [leftPinBracket_holds_iff]
      have hnGhat : ¬ (TemporalPred.snce (sinceFoldAnchored α bf.foldPairsRev)
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)).eval_at M atomMap z1 :=
        fun hGhat => hnex (h_rhs.mpr ⟨hGhat, hchain⟩)
      have h_no : ∀ y : M.carrier, y < z1 →
          (sinceFoldAnchored α bf.foldPairsRev).eval_at M atomMap y →
          ¬(∀ w : M.carrier, y < w → w < z1 →
            (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).eval_at M atomMap w) :=
        fun y hy1 hyG hseg => hnGhat
          ((TemporalPred.eval_at_snce M atomMap _ _ z1).mpr ⟨y, hy1, hyG, hseg⟩)
      -- last chain point c carries G
      obtain ⟨L, hL⟩ := sinceChainPredsAnchored_last_snoc α bf.foldPairsRev
      rw [hL] at hchain
      obtain ⟨c, hc0, hc1, -, hcG⟩ :=
        (chainAllTrue_snoc_holds_iff M atomMap L _ z0 z1).mp hchain
      -- ¬β_n occurs above c (else y := c would witness Ĝ)
      have h_fail : ∃ w : M.carrier, c < w ∧ w < z1 ∧
          ¬(bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).eval_at M atomMap w := by
        by_contra hcon
        push_neg at hcon
        exact h_no c hc1 hcG hcon
      obtain ⟨w0, hw1, hw2, hw3⟩ := h_fail
      obtain ⟨r0, hr00, hr01, hr0neg, hr0last⟩ :=
        h_SUP.last_occ_tp (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).neg z0 z1 h_lt
          ⟨w0, lt_trans hc0 hw1, hw2,
            (TemporalPred.eval_at_neg' M atomMap _ w0).mpr hw3⟩
      have hs_after : ∀ y : M.carrier, r0 < y → y < z1 →
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).eval_at M atomMap y := by
        intro y hy0 hy1
        have := hr0last y hy0 hy1
        rw [TemporalPred.eval_at_neg'] at this
        exact not_not.mp this
      refine ⟨r0, hr00, hr01, ?_, ?_, ?_⟩
      · exact (TemporalPred.eval_at_neg' M atomMap _ r0).mp hr0neg
      · exact fun hGr0 => h_no r0 hr01 hGr0 hs_after
      · intro y hy0 hy1
        refine ⟨hs_after y hy0 hy1, fun hGy => ?_⟩
        exact h_no y hy1 hGy (fun w h1 h2 => hs_after w (lt_trans hy0 h1) h2)
    · -- chain fails: the Lemma 5.3 disjuncts cover it
      obtain ⟨d, hmem, hh⟩ :=
        (negChainOn_iff M atomMap h_INF _ z0 z1 h_lt).mpr hchain
      exact ⟨d, List.mem_cons_of_mem _ hmem, hh⟩


end Bimodal.Metalogic.WeakCanonical.Kamp
