import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.BoundedFix

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! # Anchored Corollary 5.4 mirrors (task 350 Phase 10b-i)

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

/-! # The pinned-concatenation builder (task 350 Phase 10b-ii, unit 1)

Case 3 of the fixed-formula negation recursion glues IH outputs across the
attained first-`¬β₀` pin `r0`: the negation of a bracket on `(z0, z1)` is
assembled from V-brackets on `(z0, r0)` and `(r0, z1)` joined at a pinned
point type (Rabinovich chunk_0017, the A_i/B_i split; Phase 10a handoff,
design note 2). The builder concatenates every pair of disjuncts around the
pin; the `∃ r` and the fixed pin distribute over both disjunction lists. -/

/-- Splitting a list-form bracket at a distinguished pin pair: the bracket
    `[s, …ps…, pin, b, …qs…]` holds iff some `r ∈ (z0, z1)` splits it into
    the `ps`-bracket on `(z0, r)`, the pin at `r`, and the `qs`-bracket on
    `(r, z1)`. -/
theorem bracketOf_append_pin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (ps : List (TemporalPred × TemporalPred)) (s a b : TemporalPred)
      (qs : List (TemporalPred × TemporalPred)) (z0 z1 : M.carrier),
    (bracketOf s (ps ++ (a, b) :: qs)).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      (bracketOf s ps).holds M atomMap z0 r ∧
      a.eval_at M atomMap r ∧
      (bracketOf b qs).holds M atomMap r z1 := by
  intro ps
  induction ps with
  | nil =>
    intro s a b qs z0 z1
    rw [List.nil_append, bracketOf_cons_holds_iff]
    constructor
    · rintro ⟨r, h1, h2, h3, h4, h5⟩
      exact ⟨r, h1, h2, (bracketOf_nil_holds_iff M atomMap s z0 r).mpr h3, h4, h5⟩
    · rintro ⟨r, h1, h2, h3, h4, h5⟩
      exact ⟨r, h1, h2, (bracketOf_nil_holds_iff M atomMap s z0 r).mp h3, h4, h5⟩
  | cons ab' rest ih =>
    obtain ⟨a', b'⟩ := ab'
    intro s a b qs z0 z1
    rw [List.cons_append, bracketOf_cons_holds_iff]
    constructor
    · rintro ⟨r', h1, h2, h3, h4, h5⟩
      obtain ⟨r, hr1, hr2, hr3, hr4, hr5⟩ := (ih b' a b qs r' z1).mp h5
      exact ⟨r, lt_trans h1 hr1, hr2,
        (bracketOf_cons_holds_iff M atomMap s a' b' rest z0 r).mpr
          ⟨r', h1, hr1, h3, h4, hr3⟩, hr4, hr5⟩
    · rintro ⟨r, hr1, hr2, hr3, hr4, hr5⟩
      obtain ⟨r', h1, h2, h3, h4, h5⟩ :=
        (bracketOf_cons_holds_iff M atomMap s a' b' rest z0 r).mp hr3
      exact ⟨r', h1, lt_trans h2 hr2, h3, h4,
        (ih b' a b qs r' z1).mpr ⟨r, h2, hr2, h5, hr4, hr5⟩⟩

/-- Pinned concatenation of two brackets: `[bfL…, pin, bfR…]`. The witness
    count is the list length of the combined fold pairs (definitionally
    `nL + 1 + nR`, kept in list form to avoid `Fin` casts — the V-level
    consumer stores it under a `Σ`). -/
def BracketFormula.concatPin {nL nR : Nat} (bfL : BracketFormula nL)
    (pin : TemporalPred) (bfR : BracketFormula nR) :
    BracketFormula (bfL.foldPairs ++
      (pin, bfR.segmentTypes ⟨0, Nat.succ_pos nR⟩) :: bfR.foldPairs).length :=
  bracketOf (bfL.segmentTypes ⟨0, Nat.succ_pos nL⟩)
    (bfL.foldPairs ++ (pin, bfR.segmentTypes ⟨0, Nat.succ_pos nR⟩) :: bfR.foldPairs)

/-- Semantics of the pinned concatenation: some `r ∈ (z0, z1)` carries the
    pin, with `bfL` on `(z0, r)` and `bfR` on `(r, z1)`. -/
theorem BracketFormula.concatPin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    {nL nR : Nat} (bfL : BracketFormula nL) (pin : TemporalPred)
    (bfR : BracketFormula nR) (z0 z1 : M.carrier) :
    (bfL.concatPin pin bfR).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      bfL.holds M atomMap z0 r ∧ pin.eval_at M atomMap r ∧
      bfR.holds M atomMap r z1 := by
  unfold concatPin
  rw [bracketOf_append_pin_holds_iff]
  constructor
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    exact ⟨r, h1, h2,
      (BracketFormula.holds_iff_bracketOf M atomMap nL bfL z0 r).mpr h3, h4,
      (BracketFormula.holds_iff_bracketOf M atomMap nR bfR r z1).mpr h5⟩
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    exact ⟨r, h1, h2,
      (BracketFormula.holds_iff_bracketOf M atomMap nL bfL z0 r).mp h3, h4,
      (BracketFormula.holds_iff_bracketOf M atomMap nR bfR r z1).mp h5⟩

/-- Pinned concatenation of two V-brackets: every pair of disjuncts joined
    around the pin. -/
def VBracketFormula.concatPin (VL : VBracketFormula) (pin : TemporalPred)
    (VR : VBracketFormula) : VBracketFormula :=
  ⟨VL.disjuncts.flatMap fun dL =>
    VR.disjuncts.map fun dR => ⟨_, dL.2.concatPin pin dR.2⟩⟩

/-- Semantics of the V-level pinned concatenation: the `∃ r` and the fixed
    pin distribute over both disjunction lists. -/
theorem VBracketFormula.concatPin_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (VL : VBracketFormula) (pin : TemporalPred) (VR : VBracketFormula)
    (z0 z1 : M.carrier) :
    (VL.concatPin pin VR).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      VL.holds M atomMap z0 r ∧ pin.eval_at M atomMap r ∧
      VR.holds M atomMap r z1 := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [concatPin, List.mem_flatMap, List.mem_map] at hmem
    obtain ⟨dL, hdL, dR, hdR, rfl⟩ := hmem
    obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
      (BracketFormula.concatPin_holds_iff M atomMap dL.2 pin dR.2 z0 z1).mp hh
    exact ⟨r, h1, h2, ⟨dL, hdL, h3⟩, h4, ⟨dR, hdR, h5⟩⟩
  · rintro ⟨r, h1, h2, ⟨dL, hdL, h3⟩, h4, ⟨dR, hdR, h5⟩⟩
    refine ⟨⟨_, dL.2.concatPin pin dR.2⟩, ?_, ?_⟩
    · simp only [concatPin, List.mem_flatMap, List.mem_map]
      exact ⟨dL, hdL, dR, hdR, rfl⟩
    · exact (BracketFormula.concatPin_holds_iff M atomMap dL.2 pin dR.2 z0 z1).mpr
        ⟨r, h1, h2, h3, h4, h5⟩

/-! # Lemma 5.1 fixed-formula negation: the n = 1 gated instance
(task 350 Phase 10)

Rabinovich's Lemma 5.1 (chunk_0016) outputs `∨_i (Cond_i ∧ Form_i)` — the case
gates ride IN the disjuncts. For the one-witness bracket `[s0, p, s1]` on
attained structures the gate-complete disjunct list is `{A, B1, B2, B3, B4,
B4′}`:

- `A  = [¬p]` — `p` never occurs in `(z0, z1)`;
- `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]` — `s0` fails strictly before the first `p`-point;
- `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]` — `s1` fails strictly after the last `p`-point;
- `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]` — a `¬s0`-point strictly before a `¬s1`-point;
- `B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]` — the last `¬s1`-point, a `¬p`
  corridor, then the first `¬s0`-point;
- `B4′ = [⊤, (¬s0 ∧ ¬s1 ∧ ¬p), ⊤]` — the coincidence case of `B4`.

Each disjunct individually implies `¬[s0, p, s1]` (no attainment needed); the
cover direction pins the first `¬s0`-point and the last `¬s1`-point via
`HasAttainedINF`/`HasAttainedSUP`. The ℤ counterexample below (`NegFixGateProbe`)
machine-checks that the two-point gated shapes `B4`/`B4′` are unavoidable. -/

/-- The one-witness bracket `[s0, p, s1]`. -/
def bracketOne (s0 p s1 : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend s0 p (BracketFormula.trivial s1)

/-- Unfolded semantics of `[s0, p, s1]`. -/
theorem bracketOne_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) :
    (bracketOne s0 p s1).holds M atomMap z0 z1 ↔
    ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ p.eval_at M atomMap x ∧
      (∀ y : M.carrier, z0 < y → y < x → s0.eval_at M atomMap y) ∧
      (∀ y : M.carrier, x < y → y < z1 → s1.eval_at M atomMap y) := by
  constructor
  · intro h
    obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
    rw [BracketFormula.trivial_holds] at h5
    exact ⟨r, h1, h2, h3, h4, h5⟩
  · rintro ⟨x, h1, h2, h3, h4, h5⟩
    exact BracketFormula.prepend_holds M atomMap _ _ _ _ _ x h1 h2 h3 h4
      ((BracketFormula.trivial_holds M atomMap s1 x z1).mpr h5)

/-- Disjunct `A = [¬p]`. -/
def negFix1A (p : TemporalPred) : BracketFormula 0 :=
  BracketFormula.trivial p.neg

/-- Disjunct `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def negFix1B1 (s0 p : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend p.neg ((s0.neg).conj p.neg)
    (BracketFormula.trivial TemporalPred.top)

/-- Disjunct `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]`. -/
def negFix1B2 (p s1 : TemporalPred) : BracketFormula 1 :=
  (BracketFormula.trivial TemporalPred.top).snoc ((s1.neg).conj p.neg) p.neg

/-- Disjunct `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]`. -/
def negFix1B3 (s0 s1 : TemporalPred) : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top s0.neg
    (BracketFormula.prepend TemporalPred.top s1.neg
      (BracketFormula.trivial TemporalPred.top))

/-- Disjunct `B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def negFix1B4 (s0 p s1 : TemporalPred) : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top ((s1.neg).conj p.neg)
    (BracketFormula.prepend p.neg ((s0.neg).conj p.neg)
      (BracketFormula.trivial TemporalPred.top))

/-- Disjunct `B4′ = [⊤, (¬s0 ∧ ¬s1 ∧ ¬p), ⊤]`. -/
def negFix1B4c (s0 p s1 : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend TemporalPred.top
    ((s0.neg).conj ((s1.neg).conj p.neg))
    (BracketFormula.trivial TemporalPred.top)

/-- The fixed n = 1 negation formula: the six-disjunct gate-complete list. -/
def negFixOne (s0 p s1 : TemporalPred) : VBracketFormula :=
  ⟨[⟨0, negFix1A p⟩, ⟨1, negFix1B1 s0 p⟩, ⟨1, negFix1B2 p s1⟩,
    ⟨2, negFix1B3 s0 s1⟩, ⟨2, negFix1B4 s0 p s1⟩, ⟨1, negFix1B4c s0 p s1⟩]⟩

/-! ## Backward lemmas: each gated disjunct refutes the bracket -/

private theorem negFix1A_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1A p).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  rw [negFix1A, BracketFormula.trivial_holds] at h
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, -, -⟩
  have hnp := h x hx0 hx1
  rw [TemporalPred.eval_at_neg'] at hnp
  exact hnp hxp

private theorem negFix1B1_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B1 s0 p).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w, hw0, hw1, hwpt, hwseg, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hwpt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, -⟩
  rcases lt_trichotomy x w with hlt | heq | hgt
  · have hnp := hwseg x hx0 hlt
    rw [TemporalPred.eval_at_neg'] at hnp
    exact hnp hxp
  · exact hwpt.2 (heq ▸ hxp)
  · exact hwpt.1 (hxs0 w hw0 hgt)

private theorem negFix1B2_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B2 p s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  rw [negFix1B2, BracketFormula.snoc_holds_iff] at h
  obtain ⟨w, hw0, hw1, -, hwpt, hwseg⟩ := h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hwpt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, -, hxs1⟩
  rcases lt_trichotomy x w with hlt | heq | hgt
  · exact hwpt.1 (hxs1 w hlt hw1)
  · exact hwpt.2 (heq ▸ hxp)
  · have hnp := hwseg x hgt hx1
    rw [TemporalPred.eval_at_neg'] at hnp
    exact hnp hxp

private theorem negFix1B3_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B3 s0 s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w0, hw00, hw01, hw0pt, -, htail⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  obtain ⟨w1, hw10, hw11, hw1pt, -, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ htail
  rw [TemporalPred.eval_at_neg'] at hw0pt hw1pt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  rcases lt_or_le w0 x with h1 | h1
  · exact hw0pt (hxs0 w0 hw00 h1)
  · rcases lt_or_le x w1 with h2 | h2
    · exact hw1pt (hxs1 w1 h2 hw11)
    · exact absurd (lt_of_le_of_lt (le_trans h2 h1) hw10) (lt_irrefl w1)

private theorem negFix1B4_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B4 s0 p s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w1, hw10, hw11, hw1pt, -, htail⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  obtain ⟨w2, hw21, hw22, hw2pt, hcorr, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ htail
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hw1pt hw2pt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  rcases lt_trichotomy x w1 with h1 | h1 | h1
  · exact hw1pt.1 (hxs1 w1 h1 hw11)
  · exact hw1pt.2 (h1 ▸ hxp)
  · rcases lt_trichotomy x w2 with h2 | h2 | h2
    · have hnp := hcorr x h1 h2
      rw [TemporalPred.eval_at_neg'] at hnp
      exact hnp hxp
    · exact hw2pt.2 (h2 ▸ hxp)
    · exact hw2pt.1 (hxs0 w2 (lt_trans hw10 hw21) h2)

private theorem negFix1B4c_backward {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier)
    (h : (negFix1B4c s0 p s1).holds M atomMap z0 z1) :
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  obtain ⟨w, hw0, hw1, hwpt, -, -⟩ :=
    BracketFormula.prepend_holds_inv M atomMap _ _ _ _ _ h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_conj,
    TemporalPred.eval_at_neg', TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg'] at hwpt
  rw [bracketOne_holds_iff]
  rintro ⟨x, hx0, hx1, hxp, hxs0, hxs1⟩
  rcases lt_trichotomy x w with h1 | h1 | h1
  · exact hwpt.2.1 (hxs1 w h1 hw1)
  · exact hwpt.2.2 (h1 ▸ hxp)
  · exact hwpt.1 (hxs0 w hw0 h1)

/-! ## The n = 1 cover (consumes attained INF and SUP) -/

/-- **Cover** (Rabinovich Lemma 5.1, n = 1, gated): if `[s0, p, s1]` fails on
    `(z0, z1)`, one of the six gated disjuncts holds. The `B3/B4/B4′` cases pin
    the first `¬s0`-point and the last `¬s1`-point (attained INF/SUP). -/
theorem negFixOne_cover {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_neg : ¬ (bracketOne s0 p s1).holds M atomMap z0 z1) :
    (negFixOne s0 p s1).holds M atomMap z0 z1 := by
  rw [bracketOne_holds_iff] at h_neg
  by_cases hp_occ : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ p.eval_at M atomMap x
  case neg =>
    -- Disjunct A
    push_neg at hp_occ
    refine ⟨⟨0, negFix1A p⟩, by simp [negFixOne], ?_⟩
    rw [negFix1A, BracketFormula.trivial_holds]
    intro y hy0 hy1
    rw [TemporalPred.eval_at_neg']
    exact hp_occ y hy0 hy1
  case pos =>
  obtain ⟨r0, hr00, hr01, hp_r0, hnb0⟩ := h_INF.first_occ_tp p z0 z1 h_lt hp_occ
  by_cases hs0_pre : ∀ y : M.carrier, z0 < y → y < r0 → s0.eval_at M atomMap y
  case neg =>
    -- Disjunct B1: s0 fails strictly before the first p-point
    push_neg at hs0_pre
    obtain ⟨w, hw0, hw1, hws0⟩ := hs0_pre
    refine ⟨⟨1, negFix1B1 s0 p⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 w hw0
      (lt_trans hw1 hr01) ?_ ?_ ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hws0, hnb0 w hw0 hw1⟩
    · intro y hy0 hy1
      rw [TemporalPred.eval_at_neg']
      exact hnb0 y hy0 (lt_trans hy1 hw1)
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
  case pos =>
  obtain ⟨rN, hrN0, hrN1, hp_rN, hna1⟩ := h_SUP.last_occ_tp p z0 z1 h_lt hp_occ
  by_cases hs1_post : ∀ y : M.carrier, rN < y → y < z1 → s1.eval_at M atomMap y
  case neg =>
    -- Disjunct B2: s1 fails strictly after the last p-point
    push_neg at hs1_post
    obtain ⟨w, hw0, hw1, hws1⟩ := hs1_post
    refine ⟨⟨1, negFix1B2 p s1⟩, by simp [negFixOne], ?_⟩
    rw [negFix1B2, BracketFormula.snoc_holds_iff]
    refine ⟨w, lt_trans hrN0 hw0, hw1, ?_, ?_, ?_⟩
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hws1, hna1 w hw0 hw1⟩
    · intro y hy0 hy1
      rw [TemporalPred.eval_at_neg']
      exact hna1 y (lt_trans hw0 hy0) hy1
  case pos =>
  -- Both boundary gates hold: pin the last ¬s1-point and the first ¬s0-point.
  have h1fail : ¬ ∀ y : M.carrier, r0 < y → y < z1 → s1.eval_at M atomMap y :=
    fun hpost => h_neg ⟨r0, hr00, hr01, hp_r0, hs0_pre, hpost⟩
  push_neg at h1fail
  obtain ⟨v1, hv10, hv11, hv1s1⟩ := h1fail
  have h0fail : ¬ ∀ y : M.carrier, z0 < y → y < rN → s0.eval_at M atomMap y :=
    fun hpre => h_neg ⟨rN, hrN0, hrN1, hp_rN, hpre, hs1_post⟩
  push_neg at h0fail
  obtain ⟨v0, hv00, hv01, hv0s0⟩ := h0fail
  obtain ⟨y1, hy10, hy11, hy1s1, hy1last⟩ :=
    h_SUP.last_occ_tp s1.neg z0 z1 h_lt
      ⟨v1, lt_trans hr00 hv10, hv11,
        (TemporalPred.eval_at_neg' M atomMap s1 v1).mpr hv1s1⟩
  obtain ⟨y0, hy00, hy01, hy0s0, hy0first⟩ :=
    h_INF.first_occ_tp s0.neg z0 z1 h_lt
      ⟨v0, hv00, lt_trans hv01 hrN1,
        (TemporalPred.eval_at_neg' M atomMap s0 v0).mpr hv0s0⟩
  -- s1 holds strictly after y1; s0 holds strictly before y0.
  have hs1_after : ∀ y : M.carrier, y1 < y → y < z1 → s1.eval_at M atomMap y := by
    intro y hy hyz
    have := hy1last y hy hyz
    rw [TemporalPred.eval_at_neg'] at this
    exact not_not.mp this
  have hs0_before : ∀ y : M.carrier, z0 < y → y < y0 → s0.eval_at M atomMap y := by
    intro y hy hyy
    have := hy0first y hy hyy
    rw [TemporalPred.eval_at_neg'] at this
    exact not_not.mp this
  rw [TemporalPred.eval_at_neg'] at hy1s1 hy0s0
  rcases lt_trichotomy y0 y1 with hlt | heq | hgt
  · -- Disjunct B3: the first ¬s0-point sits strictly before the last ¬s1-point
    refine ⟨⟨2, negFix1B3 s0 s1⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 y0 hy00 hy01
      ((TemporalPred.eval_at_neg' M atomMap s0 y0).mpr hy0s0)
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    refine BracketFormula.prepend_holds M atomMap _ _ _ y0 z1 y1 hlt hy11
      ((TemporalPred.eval_at_neg' M atomMap s1 y1).mpr hy1s1)
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    rw [BracketFormula.trivial_holds]
    intro y _ _
    exact TemporalPred.eval_at_top M atomMap y
  · -- Disjunct B4′: the pins coincide; the point is also a ¬p-point
    have hnp : ¬ p.eval_at M atomMap y0 := by
      intro hp_y0
      have hfail : ¬ ∀ y : M.carrier, y0 < y → y < z1 → s1.eval_at M atomMap y :=
        fun hpost => h_neg ⟨y0, hy00, hy01, hp_y0, hs0_before, hpost⟩
      push_neg at hfail
      obtain ⟨w, hwa, hwb, hws1⟩ := hfail
      exact hws1 (hs1_after w (heq ▸ hwa) hwb)
    refine ⟨⟨1, negFix1B4c s0 p s1⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 y0 hy00 hy01 ?_
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_conj,
        TemporalPred.eval_at_neg', TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hy0s0, heq ▸ hy1s1, hnp⟩
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
  · -- Disjunct B4: last ¬s1-point, ¬p corridor, first ¬s0-point
    have hnp : ∀ x : M.carrier, y1 ≤ x → x ≤ y0 → ¬ p.eval_at M atomMap x := by
      intro x hx1 hx0 hpx
      have hx_in0 : z0 < x := lt_of_lt_of_le hy10 hx1
      have hx_in1 : x < z1 := lt_of_le_of_lt hx0 hy01
      have hpre : ∀ y : M.carrier, z0 < y → y < x → s0.eval_at M atomMap y :=
        fun y hy0 hyx => hs0_before y hy0 (lt_of_lt_of_le hyx hx0)
      have hfail : ¬ ∀ y : M.carrier, x < y → y < z1 → s1.eval_at M atomMap y :=
        fun hpost => h_neg ⟨x, hx_in0, hx_in1, hpx, hpre, hpost⟩
      push_neg at hfail
      obtain ⟨w, hwx, hwz, hws1⟩ := hfail
      exact hws1 (hs1_after w (lt_of_le_of_lt hx1 hwx) hwz)
    refine ⟨⟨2, negFix1B4 s0 p s1⟩, by simp [negFixOne], ?_⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 y1 hy10 hy11 ?_
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg']
      exact ⟨hy1s1, hnp y1 le_rfl (le_of_lt hgt)⟩
    · refine BracketFormula.prepend_holds M atomMap _ _ _ y1 z1 y0 hgt hy01 ?_ ?_ ?_
      · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
          TemporalPred.eval_at_neg']
        exact ⟨hy0s0, hnp y0 (le_of_lt hgt) le_rfl⟩
      · intro y hy0 hy1'
        rw [TemporalPred.eval_at_neg']
        exact hnp y (le_of_lt hy0) (le_of_lt hy1')
      · rw [BracketFormula.trivial_holds]
        intro y _ _
        exact TemporalPred.eval_at_top M atomMap y

/-- **Lemma 5.1, n = 1, fixed formula** (Rabinovich 2014, gated): on attained
    structures, `negFixOne s0 p s1` holds on `(z0, z1)` iff the bracket
    `[s0, p, s1]` fails on `(z0, z1)`. -/
theorem negFixOne_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    (s0 p s1 : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negFixOne s0 p s1).holds M atomMap z0 z1 ↔
    ¬ (bracketOne s0 p s1).holds M atomMap z0 z1 := by
  constructor
  · rintro ⟨d, hmem, hd⟩
    simp only [negFixOne, List.mem_cons, List.not_mem_nil, or_false] at hmem
    rcases hmem with rfl | rfl | rfl | rfl | rfl | rfl
    · exact negFix1A_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B1_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B2_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B3_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B4_backward M atomMap s0 p s1 z0 z1 hd
    · exact negFix1B4c_backward M atomMap s0 p s1 z0 z1 hd
  · exact negFixOne_cover M atomMap h_INF h_SUP s0 p s1 z0 z1 h_lt

/-! # Lemma 5.1 fixed-formula negation: the gate probes (task 350 Phase 10)

## R2 gate: the ℤ counterexample

Rabinovich's Lemma 5.1 output is `∨_i (Cond_i ∧ Form_i)` — the case gates RIDE
IN the disjuncts (chunk_0016 md:5). The report's Medium-High-confidence claim
(plan R2) is that the gates are load-bearing: a gate-free disjunct list cannot
be a biconditional cover. The following ℤ instance machine-checks this.

Take carrier ℤ, interval `(0, 10)`, and `bf = [s0, p, s1]` (one witness point
of type `p`, segment `s0` before it, `s1` after it) with
- `p` true exactly at `{2, 8}`,
- `¬s0` true exactly at `{7}` (i.e. `s0 = (· ≠ 7)`),
- `¬s1` true exactly at `{3}` (i.e. `s1 = (· ≠ 3)`).

Then `¬bf.holds 0 10` (witness 2 fails at `s1 3`; witness 8 fails at `s0 7`),
yet the four single-pin negation disjuncts all FAIL:
- `A = [¬p]` — refuted by `p 2`;
- `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]` — the only `¬s0` point is 7, but `p 2` breaks
  the `¬p` prefix;
- `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]` — the only `¬s1` point is 3, but `p 8` breaks
  the `¬p` suffix;
- `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]` — needs a `¬s0` point BEFORE a `¬s1` point,
  i.e. `7 < 3`.

Only the two-point gated disjunct
`B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]` holds (witnesses 3 < 7): the
last-`¬s1` point, then a `¬p` corridor, then the first-`¬s0` point. Hence any
biconditional negation cover MUST contain the B4/B4′ gated shapes; the
Boneyard's 3-disjunct list (A/B1-prepend/B2-INF) is forward-only. -/

namespace NegFixGateProbe

/-- Three predicate symbols: `p`, `s0`, `s1`. -/
abbrev sigZ : MonadicSignature := { preds := Fin 3 }

/-- The ℤ structure of the counterexample: `p` exactly at `{2, 8}`, `¬s0`
    exactly at `{7}`, `¬s1` exactly at `{3}`. -/
abbrev MZ : OrderedMonadicStructure sigZ where
  carrier := ℤ
  interp k t :=
    match k with
    | ⟨0, _⟩ => t = 2 ∨ t = 8
    | ⟨1, _⟩ => t ≠ 7
    | ⟨2, _⟩ => t ≠ 3
  carrier_order := inferInstance

/-- Atom map: fresh atoms with indices 0, 1, 2 name the three predicates. -/
def atomMapZ : Formula → sigZ.preds
  | .atom ⟨_, some 1⟩ => 1
  | .atom ⟨_, some 2⟩ => 2
  | _ => 0

/-- The point predicate `p` (true exactly at `{2, 8}`). -/
def pZ : TemporalPred := ⟨.atom ⟨"", some 0⟩⟩

/-- The left segment predicate `s0` (false exactly at `7`). -/
def s0Z : TemporalPred := ⟨.atom ⟨"", some 1⟩⟩

/-- The right segment predicate `s1` (false exactly at `3`). -/
def s1Z : TemporalPred := ⟨.atom ⟨"", some 2⟩⟩

theorem pZ_eval (t : ℤ) : pZ.eval_at MZ atomMapZ t ↔ t = 2 ∨ t = 8 := Iff.rfl

theorem s0Z_eval (t : ℤ) : s0Z.eval_at MZ atomMapZ t ↔ t ≠ 7 := Iff.rfl

theorem s1Z_eval (t : ℤ) : s1Z.eval_at MZ atomMapZ t ↔ t ≠ 3 := Iff.rfl

/-- The bracket `[s0, p, s1]`: one interior `p`-point, `s0` before, `s1`
    after. -/
def bfZ : BracketFormula 1 :=
  BracketFormula.prepend s0Z pZ (BracketFormula.trivial s1Z)

/-- Gate-free disjunct `A = [¬p]`. -/
def caseA_Z : BracketFormula 0 := BracketFormula.trivial pZ.neg

/-- Gated disjunct `B1 = [¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def caseB1_Z : BracketFormula 1 :=
  BracketFormula.prepend pZ.neg ((s0Z.neg).conj pZ.neg)
    (BracketFormula.trivial TemporalPred.top)

/-- Gated disjunct `B2 = [⊤, (¬s1 ∧ ¬p), ¬p]`. -/
def caseB2_Z : BracketFormula 1 :=
  (BracketFormula.trivial TemporalPred.top).snoc ((s1Z.neg).conj pZ.neg) pZ.neg

/-- Gate-free disjunct `B3 = [⊤, ¬s0, ⊤, ¬s1, ⊤]`. -/
def caseB3_Z : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top s0Z.neg
    (BracketFormula.prepend TemporalPred.top s1Z.neg
      (BracketFormula.trivial TemporalPred.top))

/-- The gated two-point disjunct
    `B4 = [⊤, (¬s1 ∧ ¬p), ¬p, (¬s0 ∧ ¬p), ⊤]`. -/
def caseB4_Z : BracketFormula 2 :=
  BracketFormula.prepend TemporalPred.top ((s1Z.neg).conj pZ.neg)
    (BracketFormula.prepend pZ.neg ((s0Z.neg).conj pZ.neg)
      (BracketFormula.trivial TemporalPred.top))

/-- The bracket `[s0, p, s1]` FAILS on `(0, 10)`: witness 2 is broken by
    `¬s1 3`, witness 8 by `¬s0 7`. -/
theorem bfZ_not_holds : ¬ bfZ.holds MZ atomMapZ 0 10 := by
  intro h
  obtain ⟨r, hr0, hr1, hp, hseg, htail⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ h
  rw [BracketFormula.trivial_holds] at htail
  rcases (pZ_eval r).mp hp with h2 | h8
  · have h3 := htail (3 : ℤ) (show (r : ℤ) < 3 by rw [h2]; decide) (by decide)
    rw [s1Z_eval] at h3
    exact h3 rfl
  · have h7 := hseg (7 : ℤ) (by decide) (show (7 : ℤ) < r by rw [h8]; decide)
    rw [s0Z_eval] at h7
    exact h7 rfl

/-- Disjunct `A` fails: `p 2`. -/
theorem caseA_not_holds : ¬ caseA_Z.holds MZ atomMapZ 0 10 := by
  rw [caseA_Z, BracketFormula.trivial_holds]
  intro h
  have h2 := h (2 : ℤ) (by decide) (by decide)
  rw [TemporalPred.eval_at_neg', pZ_eval] at h2
  exact h2 (Or.inl rfl)

/-- Disjunct `B1` fails: the only `¬s0` point is 7, but `p 2` breaks the
    `¬p` prefix on `(0, 7)`. -/
theorem caseB1_not_holds : ¬ caseB1_Z.holds MZ atomMapZ 0 10 := by
  intro h
  obtain ⟨r, hr0, hr1, hpt, hseg, -⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg', s0Z_eval, pZ_eval] at hpt
  have hr7 : (r : ℤ) = 7 := not_not.mp hpt.1
  have h2 := hseg (2 : ℤ) (by decide) (show (2 : ℤ) < r by rw [hr7]; decide)
  rw [TemporalPred.eval_at_neg', pZ_eval] at h2
  exact h2 (Or.inl rfl)

/-- Disjunct `B2` fails: the only `¬s1` point is 3, but `p 8` breaks the
    `¬p` suffix on `(3, 10)`. -/
theorem caseB2_not_holds : ¬ caseB2_Z.holds MZ atomMapZ 0 10 := by
  intro h
  rw [caseB2_Z, BracketFormula.snoc_holds_iff] at h
  obtain ⟨x, hx0, hx1, -, hpt, hseg⟩ := h
  rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
    TemporalPred.eval_at_neg', s1Z_eval, pZ_eval] at hpt
  have hx3 : (x : ℤ) = 3 := not_not.mp hpt.1
  have h8 := hseg (8 : ℤ) (show (x : ℤ) < 8 by rw [hx3]; decide) (by decide)
  rw [TemporalPred.eval_at_neg', pZ_eval] at h8
  exact h8 (Or.inr rfl)

/-- Disjunct `B3` fails: it needs a `¬s0` point strictly before a `¬s1`
    point, i.e. `7 < 3`. -/
theorem caseB3_not_holds : ¬ caseB3_Z.holds MZ atomMapZ 0 10 := by
  intro h
  obtain ⟨r1, hr10, hr11, hpt1, -, htail⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ h
  obtain ⟨r2, hr21, hr22, hpt2, -, -⟩ :=
    BracketFormula.prepend_holds_inv MZ atomMapZ _ _ _ _ _ htail
  rw [TemporalPred.eval_at_neg', s0Z_eval] at hpt1
  rw [TemporalPred.eval_at_neg', s1Z_eval] at hpt2
  have h12 : (r1 : ℤ) < r2 := hr21
  rw [not_not.mp hpt1, not_not.mp hpt2] at h12
  exact absurd h12 (by decide)

/-- The gated two-point disjunct `B4` HOLDS with witnesses `3 < 7`: the
    last-`¬s1` point, a `¬p` corridor, the first-`¬s0` point. -/
theorem caseB4_holds : caseB4_Z.holds MZ atomMapZ 0 10 := by
  refine BracketFormula.prepend_holds MZ atomMapZ _ _ _ 0 10 (3 : ℤ)
    (by decide) (by decide) ?_ ?_ ?_
  · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
      TemporalPred.eval_at_neg', s1Z_eval, pZ_eval]
    exact ⟨fun hne => hne rfl, by omega⟩
  · intro y _ _
    exact TemporalPred.eval_at_top MZ atomMapZ y
  · refine BracketFormula.prepend_holds MZ atomMapZ _ _ _ (3 : ℤ) 10 (7 : ℤ)
      (by decide) (by decide) ?_ ?_ ?_
    · rw [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg',
        TemporalPred.eval_at_neg', s0Z_eval, pZ_eval]
      exact ⟨fun hne => hne rfl, by omega⟩
    · intro y hy0 hy1
      rw [TemporalPred.eval_at_neg', pZ_eval]
      have h0 : (3 : ℤ) < y := hy0
      have h1 : (y : ℤ) < 7 := hy1
      rintro (h | h)
      · rw [h] at h0
        exact absurd h0 (by decide)
      · rw [h] at h1
        exact absurd h1 (by decide)
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top MZ atomMapZ y

end NegFixGateProbe

/-! # Lemma 5.1 general recursion: `BracketFormula.negFix` (task 350 Phase 10b-ii)

The general fixed-formula negation of a bracket `[β0, α0, β1, …, α_{n-1}, βn]`
on `(z0, z1)`, per Rabinovich Lemma 5.1 / chunk_0017, with the case gates
riding IN the disjuncts:

- **Case 2** (no `¬β0`-point in `(z0, z1)`): the `β0`-prefix of any witness is
  automatic, so the negation is the ANCHORED Cor 5.4 mirror
  `negBoundedLeftFixAnchored α0 tail`, gated by `β0`-`conjEverywhere`.
- **Case 3** (attained first-`¬β0` pin `r0`): witnesses are confined to
  `(z0, r0]`. Splitting the tail bracket at `r0` (the A_i/B_i split,
  chunk_0017) yields a finite positive disjunct list over placements of `r0`;
  the negation is the conjunction of per-item 3-way failure disjunctions
  (A-fail = anchored left mirror on `(z0, r0)`; pin-type fail; B-fail =
  recursive `negFix` of the strictly smaller right part on `(r0, z1)`),
  DNF-expanded via pinned `conjFull` products and glued into brackets on
  `(z0, z1)` by `concatPin` with the `β0`-prefix + `¬β0`-pin gates. The
  boundary simplifications (d)/(e) are absorbed: the seg-0 placement of the
  pin is vacuous since `¬β0(r0)`.

Recursion is on the fold-pair LIST (`negFixList`), terminating by list
length: the A-parts need no recursion (consumed by the already-proven
anchored fixes), and every recursive call is on a strictly shorter list. -/

/-! ## V-level helpers -/

/-- The always-true V-bracket: single trivial `⊤` disjunct. Neutral slot in
    pinned-conjunction items. -/
def VBracketFormula.trivialTrue : VBracketFormula :=
  ⟨[⟨0, BracketFormula.trivial TemporalPred.top⟩]⟩

/-- `trivialTrue` holds on every interval. -/
theorem VBracketFormula.trivialTrue_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    VBracketFormula.trivialTrue.holds M atomMap z0 z1 :=
  ⟨⟨0, BracketFormula.trivial TemporalPred.top⟩, List.mem_singleton.mpr rfl,
    (BracketFormula.trivial_holds M atomMap _ z0 z1).mpr
      fun y _ _ => TemporalPred.eval_at_top M atomMap y⟩

/-- Conjoin a segment type into every disjunct of a V-bracket via
    `BracketFormula.conjEverywhere`. -/
def VBracketFormula.conjEverywhere (v : VBracketFormula) (s : TemporalPred) :
    VBracketFormula :=
  ⟨v.disjuncts.map fun d => ⟨d.1, d.2.conjEverywhere s⟩⟩

/-- Semantics of the V-level `conjEverywhere`: the V-bracket holds and `s`
    holds at every interior point. -/
theorem VBracketFormula.conjEverywhere_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VBracketFormula) (s : TemporalPred) (z0 z1 : M.carrier) :
    (v.conjEverywhere s).holds M atomMap z0 z1 ↔
    v.holds M atomMap z0 z1 ∧
      ∀ y : M.carrier, z0 < y → y < z1 → s.eval_at M atomMap y := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [conjEverywhere, List.mem_map] at hmem
    obtain ⟨d', hd', rfl⟩ := hmem
    rw [BracketFormula.conjEverywhere_holds_iff] at hh
    exact ⟨⟨d', hd', hh.1⟩, hh.2⟩
  · rintro ⟨⟨d, hd, hh⟩, hs⟩
    refine ⟨⟨d.1, d.2.conjEverywhere s⟩, ?_, ?_⟩
    · simp only [conjEverywhere, List.mem_map]
      exact ⟨d, hd, rfl⟩
    · rw [BracketFormula.conjEverywhere_holds_iff]
      exact ⟨hh, hs⟩

/-- V-level full conjunction: pairwise `BracketFormula.conjFull` products,
    flattened. -/
def VBracketFormula.conjFull (v1 v2 : VBracketFormula) : VBracketFormula :=
  ⟨v1.disjuncts.flatMap fun d1 => v2.disjuncts.flatMap fun d2 =>
    (d1.2.conjFull d2.2).disjuncts⟩

/-- Semantics of the V-level full conjunction (iff form, order-generic). -/
theorem VBracketFormula.conjFull_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v1 v2 : VBracketFormula) (z0 z1 : M.carrier) :
    (v1.conjFull v2).holds M atomMap z0 z1 ↔
    v1.holds M atomMap z0 z1 ∧ v2.holds M atomMap z0 z1 := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [conjFull, List.mem_flatMap] at hmem
    obtain ⟨d1, hd1, d2, hd2, hmem⟩ := hmem
    have hcf : (d1.2.conjFull d2.2).holds M atomMap z0 z1 := ⟨d, hmem, hh⟩
    rw [BracketFormula.conjFull_iff] at hcf
    exact ⟨⟨d1, hd1, hcf.1⟩, ⟨d2, hd2, hcf.2⟩⟩
  · rintro ⟨⟨d1, hd1, h1⟩, ⟨d2, hd2, h2⟩⟩
    have hcf : (d1.2.conjFull d2.2).holds M atomMap z0 z1 := by
      rw [BracketFormula.conjFull_iff]
      exact ⟨h1, h2⟩
    obtain ⟨d, hmem, hh⟩ := hcf
    refine ⟨d, ?_, hh⟩
    simp only [conjFull, List.mem_flatMap]
    exact ⟨d1, hd1, d2, hd2, hmem⟩

/-! ## The first-failure pin dichotomy (Lemma 5.1 case split) -/

/-- **Pin dichotomy**: on attained-INF structures, either `s` holds at every
    interior point of `(z0, z1)` (Case 2), or there is an attained
    first-`¬s` pin `r0 ∈ (z0, z1)`: `s` everywhere on `(z0, r0)` and
    `¬s(r0)` (Case 3). -/
theorem firstNegPin_or_all {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (s : TemporalPred)
    (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (∀ y : M.carrier, z0 < y → y < z1 → s.eval_at M atomMap y) ∨
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
      (∀ y : M.carrier, z0 < y → y < r0 → s.eval_at M atomMap y) ∧
      ¬ s.eval_at M atomMap r0 := by
  by_cases h : ∃ y : M.carrier, z0 < y ∧ y < z1 ∧ ¬ s.eval_at M atomMap y
  · right
    obtain ⟨y, hy0, hy1, hys⟩ := h
    obtain ⟨r0, hr00, hr01, hr0P, hbefore⟩ := h_INF.first_occ_tp s.neg z0 z1 h_lt
      ⟨y, hy0, hy1, (TemporalPred.eval_at_neg' M atomMap s y).mpr hys⟩
    refine ⟨r0, hr00, hr01, ?_,
      (TemporalPred.eval_at_neg' M atomMap s r0).mp hr0P⟩
    intro w hw0 hw1
    have hnn := hbefore w hw0 hw1
    rw [TemporalPred.eval_at_neg'] at hnn
    exact not_not.mp hnn
  · left
    push_neg at h
    exact h

/-! ## The A_i/B_i split of a bracket at an interior point (chunk_0017) -/

/-- One placement of a distinguished interior point `r` relative to the
    witnesses of a list-form bracket: left sub-bracket on `(z0, r)`, point
    type at `r`, right sub-bracket on `(r, z1)`. -/
structure SplitEntry where
  /-- Base segment type of the left sub-bracket. -/
  leftSeg : TemporalPred
  /-- Fold pairs of the left sub-bracket. -/
  leftPairs : List (TemporalPred × TemporalPred)
  /-- Point type carried by the distinguished point. -/
  pin : TemporalPred
  /-- Base segment type of the right sub-bracket. -/
  rightSeg : TemporalPred
  /-- Fold pairs of the right sub-bracket. -/
  rightPairs : List (TemporalPred × TemporalPred)

/-- All placements of an interior point relative to the witnesses of
    `bracketOf s ps`: in segment 0, at the first witness, or (recursively)
    within the tail. -/
def splitsAt : TemporalPred → List (TemporalPred × TemporalPred) →
    List SplitEntry
  | s, [] => [⟨s, [], s, s, []⟩]
  | s, (a, b) :: qs =>
      ⟨s, [], s, s, (a, b) :: qs⟩ ::
      ⟨s, [], a, b, qs⟩ ::
      (splitsAt b qs).map fun e =>
        ⟨s, (a, e.leftSeg) :: e.leftPairs, e.pin, e.rightSeg, e.rightPairs⟩

/-- The right part of any split entry is no longer than the split list —
    the termination measure for `negFixList`. -/
theorem splitsAt_rightPairs_length_le (s : TemporalPred)
    (ps : List (TemporalPred × TemporalPred)) :
    ∀ e ∈ splitsAt s ps, e.rightPairs.length ≤ ps.length := by
  induction ps generalizing s with
  | nil =>
    intro e he
    simp only [splitsAt, List.mem_singleton] at he
    subst he
    exact Nat.le_refl _
  | cons ab qs ih =>
    obtain ⟨a, b⟩ := ab
    intro e he
    simp only [splitsAt, List.mem_cons, List.mem_map] at he
    rcases he with rfl | rfl | ⟨e', he', rfl⟩
    · exact Nat.le_refl _
    · simp only [List.length_cons]
      omega
    · have := ih b e' he'
      simp only [List.length_cons]
      omega

/-- **Splitting lemma** (the A_i/B_i split, chunk_0017): for any interior
    point `r ∈ (z0, z1)`, a list-form bracket holds on `(z0, z1)` iff some
    placement entry realizes: the left sub-bracket on `(z0, r)`, the entry's
    point type at `r`, and the right sub-bracket on `(r, z1)`. -/
theorem bracketOf_splitsAt_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (ps : List (TemporalPred × TemporalPred)) (s : TemporalPred)
      (z0 r z1 : M.carrier), z0 < r → r < z1 →
    ((bracketOf s ps).holds M atomMap z0 z1 ↔
      ∃ e ∈ splitsAt s ps,
        (bracketOf e.leftSeg e.leftPairs).holds M atomMap z0 r ∧
        e.pin.eval_at M atomMap r ∧
        (bracketOf e.rightSeg e.rightPairs).holds M atomMap r z1) := by
  intro ps
  induction ps with
  | nil =>
    intro s z0 r z1 hr0 hr1
    rw [bracketOf_nil_holds_iff]
    constructor
    · intro h
      refine ⟨⟨s, [], s, s, []⟩, List.mem_singleton.mpr rfl, ?_, ?_, ?_⟩
      · exact (bracketOf_nil_holds_iff M atomMap s z0 r).mpr
          fun y hy0 hy1 => h y hy0 (lt_trans hy1 hr1)
      · exact h r hr0 hr1
      · exact (bracketOf_nil_holds_iff M atomMap s r z1).mpr
          fun y hy0 hy1 => h y (lt_trans hr0 hy0) hy1
    · rintro ⟨e, he, hL, hp, hR⟩
      simp only [splitsAt, List.mem_singleton] at he
      subst he
      exact TemporalPred.eval_at_glue M atomMap s z0 r z1
        ((bracketOf_nil_holds_iff M atomMap s z0 r).mp hL) hp
        ((bracketOf_nil_holds_iff M atomMap s r z1).mp hR)
  | cons ab qs ih =>
    obtain ⟨a, b⟩ := ab
    intro s z0 r z1 hr0 hr1
    rw [bracketOf_cons_holds_iff]
    constructor
    · rintro ⟨x, hx0, hx1, hpre, hax, htail⟩
      rcases lt_trichotomy x r with hlt | heq | hgt
      · -- x < r: split the tail at r and lift the entry
        obtain ⟨e, he, hL, hp, hR⟩ := (ih b x r z1 hlt hr1).mp htail
        refine ⟨⟨s, (a, e.leftSeg) :: e.leftPairs, e.pin, e.rightSeg,
          e.rightPairs⟩, ?_, ?_, hp, hR⟩
        · simp only [splitsAt, List.mem_cons, List.mem_map]
          exact Or.inr (Or.inr ⟨e, he, rfl⟩)
        · exact (bracketOf_cons_holds_iff M atomMap s a e.leftSeg e.leftPairs
            z0 r).mpr ⟨x, hx0, hlt, hpre, hax, hL⟩
      · -- x = r: the witness placement
        subst heq
        refine ⟨⟨s, [], a, b, qs⟩, ?_, ?_, hax, htail⟩
        · simp only [splitsAt, List.mem_cons]
          exact Or.inr (Or.inl trivial)
        · exact (bracketOf_nil_holds_iff M atomMap s z0 x).mpr hpre
      · -- x > r: r sits in segment 0
        refine ⟨⟨s, [], s, s, (a, b) :: qs⟩, ?_, ?_, hpre r hr0 hgt, ?_⟩
        · simp only [splitsAt, List.mem_cons]
          exact Or.inl trivial
        · exact (bracketOf_nil_holds_iff M atomMap s z0 r).mpr
            fun y hy0 hy1 => hpre y hy0 (lt_trans hy1 hgt)
        · exact (bracketOf_cons_holds_iff M atomMap s a b qs r z1).mpr
            ⟨x, hgt, hx1, fun y hy0 hy1 => hpre y (lt_trans hr0 hy0) hy1,
              hax, htail⟩
    · rintro ⟨e, he, hL, hp, hR⟩
      simp only [splitsAt, List.mem_cons, List.mem_map] at he
      rcases he with rfl | rfl | ⟨e', he', rfl⟩
      · -- seg-0 entry: glue the prefix across r
        obtain ⟨x, hrx, hx1, hpre, hax, htail⟩ :=
          (bracketOf_cons_holds_iff M atomMap s a b qs r z1).mp hR
        refine ⟨x, lt_trans hr0 hrx, hx1, ?_, hax, htail⟩
        exact TemporalPred.eval_at_glue M atomMap s z0 r x
          ((bracketOf_nil_holds_iff M atomMap s z0 r).mp hL) hp hpre
      · -- witness entry: r itself is the first witness
        exact ⟨r, hr0, hr1,
          (bracketOf_nil_holds_iff M atomMap s z0 r).mp hL, hp, hR⟩
      · -- mapped entry: first witness inside (z0, r), tail resplit
        obtain ⟨x, hx0, hxr, hpre, hax, hLtail⟩ :=
          (bracketOf_cons_holds_iff M atomMap s a e'.leftSeg e'.leftPairs
            z0 r).mp hL
        refine ⟨x, hx0, lt_trans hxr hr1, hpre, hax, ?_⟩
        exact (ih b x r z1 hxr hr1).mpr ⟨e', he', hLtail, hp, hR⟩

/-! ## Pinned V-form machinery (the `Cond_i ∧ Form_i` products at a shared
pin) -/

/-- A pinned item: left V-bracket on `(z0, r)`, point predicate at `r`,
    right V-bracket on `(r, z1)`, for a shared distinguished point `r`. -/
structure PinnedItem where
  /-- Left V-bracket, evaluated on `(z0, r)`. -/
  left : VBracketFormula
  /-- Point predicate at the pin `r`. -/
  atPin : TemporalPred
  /-- Right V-bracket, evaluated on `(r, z1)`. -/
  right : VBracketFormula

/-- Semantics of one pinned item at a fixed pin `r`. -/
def PinnedItem.holdsAt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (it : PinnedItem) (z0 r z1 : M.carrier) : Prop :=
  it.left.holds M atomMap z0 r ∧ it.atPin.eval_at M atomMap r ∧
    it.right.holds M atomMap r z1

/-- Conjunction of two pinned items: componentwise products. -/
def PinnedItem.conj (p q : PinnedItem) : PinnedItem :=
  ⟨p.left.conjFull q.left, p.atPin.conj q.atPin, p.right.conjFull q.right⟩

/-- Semantics of the pinned-item conjunction. -/
theorem PinnedItem.conj_holdsAt_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (p q : PinnedItem) (z0 r z1 : M.carrier) :
    (p.conj q).holdsAt M atomMap z0 r z1 ↔
    p.holdsAt M atomMap z0 r z1 ∧ q.holdsAt M atomMap z0 r z1 := by
  simp only [holdsAt, conj, VBracketFormula.conjFull_holds_iff,
    TemporalPred.eval_at_conj]
  tauto

/-- DNF product of two pinned disjunction lists. -/
def pinnedConj (l1 l2 : List PinnedItem) : List PinnedItem :=
  l1.flatMap fun p => l2.map fun q => p.conj q

/-- Semantics of the DNF product. -/
theorem pinnedConj_holdsAt_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l1 l2 : List PinnedItem) (z0 r z1 : M.carrier) :
    (∃ it ∈ pinnedConj l1 l2, it.holdsAt M atomMap z0 r z1) ↔
    (∃ it ∈ l1, it.holdsAt M atomMap z0 r z1) ∧
    (∃ it ∈ l2, it.holdsAt M atomMap z0 r z1) := by
  simp only [pinnedConj, List.mem_flatMap, List.mem_map]
  constructor
  · rintro ⟨it, ⟨p, hp, q, hq, rfl⟩, hh⟩
    rw [PinnedItem.conj_holdsAt_iff] at hh
    exact ⟨⟨p, hp, hh.1⟩, ⟨q, hq, hh.2⟩⟩
  · rintro ⟨⟨p, hp, hph⟩, ⟨q, hq, hqh⟩⟩
    exact ⟨p.conj q, ⟨p, hp, q, hq, rfl⟩,
      (PinnedItem.conj_holdsAt_iff M atomMap p q z0 r z1).mpr ⟨hph, hqh⟩⟩

/-- The always-true pinned item (unit of the pinned conjunction). -/
def PinnedItem.unit : PinnedItem :=
  ⟨VBracketFormula.trivialTrue, TemporalPred.top, VBracketFormula.trivialTrue⟩

/-- The unit pinned item always holds. -/
theorem PinnedItem.unit_holdsAt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 r z1 : M.carrier) :
    PinnedItem.unit.holdsAt M atomMap z0 r z1 :=
  ⟨VBracketFormula.trivialTrue_holds M atomMap z0 r,
    TemporalPred.eval_at_top M atomMap r,
    VBracketFormula.trivialTrue_holds M atomMap r z1⟩

/-- Conjunction of a list of pinned disjunction lists (iterated DNF
    product). -/
def pinnedConjAll : List (List PinnedItem) → List PinnedItem
  | [] => [PinnedItem.unit]
  | l :: ls => pinnedConj l (pinnedConjAll ls)

/-- Semantics of the iterated DNF product: all conjunct lists hold at the
    pin. -/
theorem pinnedConjAll_holdsAt_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (ls : List (List PinnedItem)) (z0 r z1 : M.carrier) :
    (∃ it ∈ pinnedConjAll ls, it.holdsAt M atomMap z0 r z1) ↔
    ∀ l ∈ ls, ∃ it ∈ l, it.holdsAt M atomMap z0 r z1 := by
  induction ls with
  | nil =>
    simp only [pinnedConjAll, List.mem_singleton, List.not_mem_nil,
      false_implies, implies_true, iff_true]
    exact ⟨PinnedItem.unit, rfl, PinnedItem.unit_holdsAt M atomMap z0 r z1⟩
  | cons l ls ih =>
    rw [show pinnedConjAll (l :: ls) = pinnedConj l (pinnedConjAll ls) from
      rfl, pinnedConj_holdsAt_iff, ih, List.forall_mem_cons]

/-- Glue a pinned item into a V-bracket on `(z0, z1)`: the pin is
    existentially bound, gated by `gateSeg` everywhere left of the pin and
    `gatePin` at the pin. -/
def PinnedItem.toV (it : PinnedItem) (gateSeg gatePin : TemporalPred) :
    VBracketFormula :=
  (it.left.conjEverywhere gateSeg).concatPin (it.atPin.conj gatePin) it.right

/-- Glue a pinned disjunction list into a single V-bracket. -/
def pinnedListToV (l : List PinnedItem) (gateSeg gatePin : TemporalPred) :
    VBracketFormula :=
  ⟨l.flatMap fun it => (it.toV gateSeg gatePin).disjuncts⟩

/-- Semantics of the glued pinned list: some interior pin `r` carries the
    gates and realizes some pinned item. -/
theorem pinnedListToV_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l : List PinnedItem) (gateSeg gatePin : TemporalPred)
    (z0 z1 : M.carrier) :
    (pinnedListToV l gateSeg gatePin).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      (∀ y : M.carrier, z0 < y → y < r → gateSeg.eval_at M atomMap y) ∧
      gatePin.eval_at M atomMap r ∧
      ∃ it ∈ l, it.holdsAt M atomMap z0 r z1 := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [pinnedListToV, List.mem_flatMap] at hmem
    obtain ⟨it, hit, hd⟩ := hmem
    have hv : (it.toV gateSeg gatePin).holds M atomMap z0 z1 := ⟨d, hd, hh⟩
    rw [PinnedItem.toV, VBracketFormula.concatPin_holds_iff] at hv
    obtain ⟨r, h1, h2, hL, hp, hR⟩ := hv
    rw [VBracketFormula.conjEverywhere_holds_iff] at hL
    rw [TemporalPred.eval_at_conj] at hp
    exact ⟨r, h1, h2, hL.2, hp.2, it, hit, hL.1, hp.1, hR⟩
  · rintro ⟨r, h1, h2, hseg, hgp, it, hit, hL, hp, hR⟩
    have hv : (it.toV gateSeg gatePin).holds M atomMap z0 z1 := by
      rw [PinnedItem.toV, VBracketFormula.concatPin_holds_iff]
      exact ⟨r, h1, h2,
        (VBracketFormula.conjEverywhere_holds_iff M atomMap it.left gateSeg
          z0 r).mpr ⟨hL, hseg⟩,
        (TemporalPred.eval_at_conj M atomMap it.atPin gatePin r).mpr
          ⟨hp, hgp⟩, hR⟩
    obtain ⟨d, hd, hh⟩ := hv
    refine ⟨d, ?_, hh⟩
    simp only [pinnedListToV, List.mem_flatMap]
    exact ⟨it, hit, hd⟩

/-! ## The `negFix` recursion (Lemma 5.1, general fixed formula) -/

/-- **Lemma 5.1 fixed-formula negation, list form** (Rabinovich chunk_0016,
    chunk_0017). `negFixList s ps` is a V-bracket whose semantics on attained
    structures is `¬ (bracketOf s ps).holds`:

    - `ps = []`: the negation of "`s` everywhere" is `[⊤, ¬s, ⊤]`.
    - `ps = (a, b) :: qs`, **Case 2 disjunct** (gate: no `¬s`-point): the
      anchored mirror `negBoundedLeftFixAnchored a (bracketOf b qs)` gated by
      `s`-`conjEverywhere`.
    - `ps = (a, b) :: qs`, **Case 3 disjunct** (gate: attained first-`¬s`
      pin, carried by `pinnedListToV _ s s.neg`): the pinned DNF of per-item
      failure disjunctions — for the `x = r0` placement, `¬a(r0)` or the
      recursive tail failure; for each `x < r0` placement (split entry `e`),
      the anchored A-failure on `(z0, r0)`, the pin-type failure `¬e.pin(r0)`,
      or the recursive B-failure `negFixList e.rightSeg e.rightPairs` on
      `(r0, z1)`. The seg-0 placement (boundary (d)/(e)) is absorbed: it is
      vacuous under `¬s(r0)`.

    Termination: every recursive call is on a strictly shorter pair list
    (`splitsAt_rightPairs_length_le`); the A-parts need no recursion. -/
def negFixList : TemporalPred → List (TemporalPred × TemporalPred) →
    VBracketFormula
  | s, [] =>
      ⟨[⟨1, BracketFormula.prepend TemporalPred.top s.neg
        (BracketFormula.trivial TemporalPred.top)⟩]⟩
  | s, (a, b) :: qs =>
      ((negBoundedLeftFixAnchored a (bracketOf b qs)).conjEverywhere s).disj
      (pinnedListToV
        (pinnedConjAll
          ([⟨VBracketFormula.trivialTrue, a.neg, VBracketFormula.trivialTrue⟩,
            ⟨VBracketFormula.trivialTrue, TemporalPred.top,
              negFixList b qs⟩] ::
           (splitsAt b qs).attach.map fun ⟨e, he⟩ =>
             [⟨negBoundedLeftFixAnchored a (bracketOf e.leftSeg e.leftPairs),
               TemporalPred.top, VBracketFormula.trivialTrue⟩,
              ⟨VBracketFormula.trivialTrue, e.pin.neg,
               VBracketFormula.trivialTrue⟩,
              ⟨VBracketFormula.trivialTrue, TemporalPred.top,
               negFixList e.rightSeg e.rightPairs⟩]))
        s s.neg)
  termination_by _ ps => ps.length
  decreasing_by
  · simp only [List.length_cons]
    omega
  · have hle := splitsAt_rightPairs_length_le b qs e he
    simp only [List.length_cons]
    omega

/-- **Lemma 5.1 fixed-formula negation** (Rabinovich 2014): the general
    gated negation of a bracket formula, via the list recursion. -/
def BracketFormula.negFix {n : Nat} (bf : BracketFormula n) :
    VBracketFormula :=
  negFixList (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) bf.foldPairs

/-! ## `negFix_iff`: the Lemma 5.1 biconditional -/

/-- Base case of the list recursion: `negFixList s []` is `[⊤, ¬s, ⊤]`,
    the negation of "`s` everywhere". No attainment needed. -/
theorem negFixList_nil_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s : TemporalPred) (z0 z1 : M.carrier) :
    (negFixList s []).holds M atomMap z0 z1 ↔
    ¬ (bracketOf s []).holds M atomMap z0 z1 := by
  rw [bracketOf_nil_holds_iff]
  constructor
  · rintro ⟨d, hmem, hh⟩ hall
    simp only [negFixList, List.mem_singleton] at hmem
    subst hmem
    obtain ⟨r, h1, h2, hpt, _hseg, _htail⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ _ _ z0 z1 hh
    rw [TemporalPred.eval_at_neg'] at hpt
    exact hpt (hall r h1 h2)
  · intro h
    have hex : ∃ y : M.carrier, z0 < y ∧ y < z1 ∧
        ¬ s.eval_at M atomMap y := by
      by_contra hno
      push_neg at hno
      exact h hno
    obtain ⟨y, hy0, hy1, hys⟩ := hex
    refine ⟨⟨1, BracketFormula.prepend TemporalPred.top s.neg
      (BracketFormula.trivial TemporalPred.top)⟩, by simp [negFixList], ?_⟩
    exact BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 y hy0 hy1
      ((TemporalPred.eval_at_neg' M atomMap s y).mpr hys)
      (fun w _ _ => TemporalPred.eval_at_top M atomMap w)
      ((BracketFormula.trivial_holds M atomMap _ y z1).mpr
        fun w _ _ => TemporalPred.eval_at_top M atomMap w)

/-- **Lemma 5.1 iff, list form** (Rabinovich 2014, gated): on attained
    structures, `negFixList s ps` holds on `(z0, z1)` iff the list-form
    bracket `bracketOf s ps` fails on `(z0, z1)`. Strong induction on the
    pair-list length. -/
theorem negFixList_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap) :
    ∀ (N : Nat) (ps : List (TemporalPred × TemporalPred))
      (s : TemporalPred) (z0 z1 : M.carrier), ps.length ≤ N → z0 < z1 →
    ((negFixList s ps).holds M atomMap z0 z1 ↔
      ¬ (bracketOf s ps).holds M atomMap z0 z1) := by
  intro N
  induction N with
  | zero =>
    intro ps s z0 z1 hlen _h_lt
    have hps : ps = [] := List.length_eq_zero_iff.mp (Nat.le_zero.mp hlen)
    subst hps
    exact negFixList_nil_iff M atomMap s z0 z1
  | succ N ihN =>
    intro ps s z0 z1 hlen h_lt
    rcases ps with _ | ⟨⟨a, b⟩, qs⟩
    · exact negFixList_nil_iff M atomMap s z0 z1
    have hqs : qs.length ≤ N := by
      simp only [List.length_cons] at hlen
      omega
    simp only [negFixList]
    rw [VBracketFormula.disj_holds]
    constructor
    · -- some gated disjunct holds → the bracket fails
      rintro (h2 | h3)
      · -- Case 2: s everywhere, no anchored tail instance
        obtain ⟨h2n, hsev⟩ :=
          (VBracketFormula.conjEverywhere_holds_iff M atomMap _ s z0 z1).mp h2
        have hnex := (negBoundedLeftFixAnchored_iff M atomMap h_INF h_SUP a
          (bracketOf b qs) z0 z1 h_lt).mp h2n
        intro hb
        obtain ⟨x, hx0, hx1, _hpre, hax, htail⟩ :=
          (bracketOf_cons_holds_iff M atomMap s a b qs z0 z1).mp hb
        exact hnex ⟨x, hx0, hx1, hax, htail⟩
      · -- Case 3: pinned failure conjunction at the first-¬s pin
        obtain ⟨r, hr0, hr1, hsev, hnsr, hitems⟩ :=
          (pinnedListToV_holds_iff M atomMap _ s s.neg z0 z1).mp h3
        rw [TemporalPred.eval_at_neg'] at hnsr
        have hall := (pinnedConjAll_holdsAt_iff M atomMap _ z0 r z1).mp hitems
        intro hb
        obtain ⟨x, hx0, hx1, hpre, hax, htail⟩ :=
          (bracketOf_cons_holds_iff M atomMap s a b qs z0 z1).mp hb
        -- the pin confines the witness: x ≤ r
        have hxle : x ≤ r := le_of_not_gt fun hgt => hnsr (hpre r hr0 hgt)
        rcases eq_or_lt_of_le hxle with heq | hxlt
        · -- x = r: the head item refutes it
          subst heq
          obtain ⟨it, hit, hh⟩ := hall _ (List.mem_cons_self ..)
          simp only [List.mem_cons, List.not_mem_nil, or_false] at hit
          rcases hit with rfl | rfl
          · have := hh.2.1
            rw [TemporalPred.eval_at_neg'] at this
            exact this hax
          · exact (ihN qs b x z1 hqs hx1).mp hh.2.2 htail
        · -- x < r: split the tail at the pin and use the entry's item
          obtain ⟨e, he, heL, hep, heR⟩ :=
            (bracketOf_splitsAt_iff M atomMap qs b x r z1 hxlt hr1).mp htail
          have hmem : [⟨negBoundedLeftFixAnchored a
              (bracketOf e.leftSeg e.leftPairs),
              TemporalPred.top, VBracketFormula.trivialTrue⟩,
            (⟨VBracketFormula.trivialTrue, e.pin.neg,
              VBracketFormula.trivialTrue⟩ : PinnedItem),
            ⟨VBracketFormula.trivialTrue, TemporalPred.top,
              negFixList e.rightSeg e.rightPairs⟩] ∈
              ([⟨VBracketFormula.trivialTrue, a.neg,
                  VBracketFormula.trivialTrue⟩,
                ⟨VBracketFormula.trivialTrue, TemporalPred.top,
                  negFixList b qs⟩] ::
               (splitsAt b qs).attach.map fun ⟨e, he⟩ =>
                 [⟨negBoundedLeftFixAnchored a
                     (bracketOf e.leftSeg e.leftPairs),
                   TemporalPred.top, VBracketFormula.trivialTrue⟩,
                  ⟨VBracketFormula.trivialTrue, e.pin.neg,
                   VBracketFormula.trivialTrue⟩,
                  ⟨VBracketFormula.trivialTrue, TemporalPred.top,
                   negFixList e.rightSeg e.rightPairs⟩]) := by
            refine List.mem_cons_of_mem _ ?_
            rw [List.mem_map]
            exact ⟨⟨e, he⟩, List.mem_attach _ _, rfl⟩
          obtain ⟨it, hit, hh⟩ := hall _ hmem
          simp only [List.mem_cons, List.not_mem_nil, or_false] at hit
          rcases hit with rfl | rfl | rfl
          · -- A-failure: contradicts the witness x
            have hnA := (negBoundedLeftFixAnchored_iff M atomMap h_INF h_SUP a
              (bracketOf e.leftSeg e.leftPairs) z0 r hr0).mp hh.1
            exact hnA ⟨x, hx0, hxlt, hax, heL⟩
          · -- pin-type failure: contradicts the entry's pin type
            have := hh.2.1
            rw [TemporalPred.eval_at_neg'] at this
            exact this hep
          · -- B-failure: contradicts the right part, by IH
            exact (ihN e.rightPairs e.rightSeg r z1
              (le_trans (splitsAt_rightPairs_length_le b qs e he) hqs)
              hr1).mp hh.2.2 heR
    · -- the bracket fails → some gated disjunct holds
      intro hnb
      rcases firstNegPin_or_all M atomMap h_INF s z0 z1 h_lt with
        hsev | ⟨r0, hr00, hr01, hsev, hnsr0⟩
      · -- Case 2: s everywhere
        refine Or.inl ((VBracketFormula.conjEverywhere_holds_iff M atomMap _ s
          z0 z1).mpr ⟨(negBoundedLeftFixAnchored_iff M atomMap h_INF h_SUP a
            (bracketOf b qs) z0 z1 h_lt).mpr ?_, hsev⟩)
        rintro ⟨x, hx0, hx1, hax, htail⟩
        exact hnb ((bracketOf_cons_holds_iff M atomMap s a b qs z0 z1).mpr
          ⟨x, hx0, hx1, fun y hy0 hy1 => hsev y hy0 (lt_trans hy1 hx1),
            hax, htail⟩)
      · -- Case 3: the attained pin realizes every failure item
        refine Or.inr ((pinnedListToV_holds_iff M atomMap _ s s.neg
          z0 z1).mpr ⟨r0, hr00, hr01, hsev,
            (TemporalPred.eval_at_neg' M atomMap s r0).mpr hnsr0, ?_⟩)
        rw [pinnedConjAll_holdsAt_iff]
        intro l hl
        rw [List.mem_cons] at hl
        rcases hl with rfl | hl'
        · -- head item: ¬a(r0) or the recursive tail failure
          by_cases hB : (negFixList b qs).holds M atomMap r0 z1
          · exact ⟨⟨VBracketFormula.trivialTrue, TemporalPred.top,
              negFixList b qs⟩, by simp,
              VBracketFormula.trivialTrue_holds M atomMap z0 r0,
              TemporalPred.eval_at_top M atomMap r0, hB⟩
          · refine ⟨⟨VBracketFormula.trivialTrue, a.neg,
              VBracketFormula.trivialTrue⟩, by simp,
              VBracketFormula.trivialTrue_holds M atomMap z0 r0, ?_,
              VBracketFormula.trivialTrue_holds M atomMap r0 z1⟩
            rw [TemporalPred.eval_at_neg']
            intro hax
            have htail : (bracketOf b qs).holds M atomMap r0 z1 := by
              by_contra hc
              exact hB ((ihN qs b r0 z1 hqs hr01).mpr hc)
            exact hnb ((bracketOf_cons_holds_iff M atomMap s a b qs
              z0 z1).mpr ⟨r0, hr00, hr01, hsev, hax, htail⟩)
        · -- split-entry item: A-failure, pin-type failure, or B-failure
          rw [List.mem_map] at hl'
          obtain ⟨⟨e, he⟩, -, rfl⟩ := hl'
          by_cases hB : (negFixList e.rightSeg e.rightPairs).holds M atomMap
            r0 z1
          · exact ⟨⟨VBracketFormula.trivialTrue, TemporalPred.top,
              negFixList e.rightSeg e.rightPairs⟩, by simp,
              VBracketFormula.trivialTrue_holds M atomMap z0 r0,
              TemporalPred.eval_at_top M atomMap r0, hB⟩
          by_cases hp : e.pin.eval_at M atomMap r0
          · -- pin type holds: the A-part must fail, else the bracket holds
            refine ⟨⟨negBoundedLeftFixAnchored a
                (bracketOf e.leftSeg e.leftPairs),
                TemporalPred.top, VBracketFormula.trivialTrue⟩, by simp,
              ?_, TemporalPred.eval_at_top M atomMap r0,
              VBracketFormula.trivialTrue_holds M atomMap r0 z1⟩
            rw [negBoundedLeftFixAnchored_iff M atomMap h_INF h_SUP a
              (bracketOf e.leftSeg e.leftPairs) z0 r0 hr00]
            rintro ⟨x, hx0, hxr, hax, hxL⟩
            have heR : (bracketOf e.rightSeg e.rightPairs).holds M atomMap
                r0 z1 := by
              by_contra hc
              exact hB ((ihN e.rightPairs e.rightSeg r0 z1
                (le_trans (splitsAt_rightPairs_length_le b qs e he) hqs)
                hr01).mpr hc)
            have htail : (bracketOf b qs).holds M atomMap x z1 :=
              (bracketOf_splitsAt_iff M atomMap qs b x r0 z1 hxr hr01).mpr
                ⟨e, he, hxL, hp, heR⟩
            exact hnb ((bracketOf_cons_holds_iff M atomMap s a b qs
              z0 z1).mpr ⟨x, hx0, lt_trans hxr hr01,
                fun y hy0 hy1 => hsev y hy0 (lt_trans hy1 hxr), hax, htail⟩)
          · -- pin type fails
            refine ⟨⟨VBracketFormula.trivialTrue, e.pin.neg,
              VBracketFormula.trivialTrue⟩, by simp,
              VBracketFormula.trivialTrue_holds M atomMap z0 r0, ?_,
              VBracketFormula.trivialTrue_holds M atomMap r0 z1⟩
            rw [TemporalPred.eval_at_neg']
            exact hp

/-- **Lemma 5.1, general fixed formula** (Rabinovich 2014, gated): on
    attained structures, `bf.negFix` holds on `(z0, z1)` iff the bracket
    `bf` fails on `(z0, z1)`. -/
theorem BracketFormula.negFix_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    bf.negFix.holds M atomMap z0 z1 ↔ ¬ bf.holds M atomMap z0 z1 := by
  unfold BracketFormula.negFix
  exact (negFixList_iff M atomMap h_INF h_SUP bf.foldPairs.length
    bf.foldPairs (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1
    (Nat.le_refl _) h_lt).trans
    (not_congr (BracketFormula.holds_iff_bracketOf M atomMap n bf
      z0 z1).symm)

end Bimodal.Metalogic.WeakCanonical.Kamp
