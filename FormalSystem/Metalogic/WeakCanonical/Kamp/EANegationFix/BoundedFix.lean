/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix.OnBuilder

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! # Corollary 5.4 mirrors

Fixed-formula negation of the endpoint-moved bracket existentials
(Rabinovich 2014, Cor 5.4, chunk_0014 md:49, chunk_0015 md:3-43):

- `negBoundedRightFix bf` ↔ `¬∃ z ∈ (z0, z1), bf.holds z0 z`  (Cor 5.4(1))
- `negBoundedLeftFix bf` ↔ `¬∃ z ∈ (z0, z1), bf.holds z z1`   (Cor 5.4(2))

The construction follows the paper: fold the bracket's point/segment data
into nested Until (resp. Since) predicates `F_i` — `F_i := α_i ∧ (β_{i+1}
Until F_{i+1})` — so that the endpoint-moved bracket existential becomes
"`F̂` at the fixed endpoint AND a pointwise increasing chain of the tail
folds exists" (the ⇐ direction is the chunk_0015 induction with the
Until-witness `y ≤ c / y > c` relink case split). The chain negation is
Lemma 5.3 (`negChainOn`); the endpoint conjunct `¬F̂(z0)` — not expressible
as an interval formula directly — becomes an attained first-occurrence pin
of `¬β_0` (mirror: attained last-occurrence pin of `¬β_n`, consuming
`HasAttainedSUP`), which is where the attained INF/SUP surrogates for
Dedekind completeness enter.

Encoding note (endpoint types): this codebase's brackets carry no point
types at the interval endpoints (those live in `VecEA2`), so Rabinovich's
`α_0(z_0)` / `α_n(z)` endpoint conjuncts are `⊤` here; his `¬F_0(z_0)`
output disjunct correspondingly becomes the pin disjunct below rather than
an endpoint predicate. -/

/-! ## Temporal-predicate Until/Since builders -/

/-- `goal` is reachable strictly to the right, with `seg` holding at all
    points strictly in between (native `Formula.untl` semantics). -/
def TemporalPred.untl (goal seg : TemporalPred) : TemporalPred :=
  ⟨Formula.untlQ seg.formula goal.formula⟩

/-- `goal` is reachable strictly to the left, with `seg` holding at all
    points strictly in between (native `Formula.snce` semantics). -/
def TemporalPred.snce (goal seg : TemporalPred) : TemporalPred :=
  ⟨Formula.snceQ seg.formula goal.formula⟩

/-- Semantics of `TemporalPred.untl`. -/
theorem TemporalPred.eval_at_untl {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (goal seg : TemporalPred) (t : M.carrier) :
    (TemporalPred.untl goal seg).EvalAt M atomMap t ↔
    ∃ y : M.carrier, t < y ∧ goal.EvalAt M atomMap y ∧
      ∀ w : M.carrier, t < w → w < y → seg.EvalAt M atomMap w := by
  simp only [untl, EvalAt, TemporalTruth]

/-- Semantics of `TemporalPred.snce`. -/
theorem TemporalPred.eval_at_snce {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (goal seg : TemporalPred) (t : M.carrier) :
    (TemporalPred.snce goal seg).EvalAt M atomMap t ↔
    ∃ y : M.carrier, y < t ∧ goal.EvalAt M atomMap y ∧
      ∀ w : M.carrier, y < w → w < t → seg.EvalAt M atomMap w := by
  simp only [snce, EvalAt, TemporalTruth]

/-- Last occurrence of a temporal predicate P in (z0, z1) on structures with
    attained suprema. Mirror of `HasAttainedINF.first_occ_tp`. -/
theorem HasAttainedSUP.last_occ_tp {sig : MonadicSignature}
    {M : OrderedMonadicStructure sig} {atomMap : Formula → sig.preds}
    (h_SUP : HasAttainedSUP M atomMap)
    (P : TemporalPred) (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (h_exists : ∃ x : M.carrier, z0 < x ∧ x < z1 ∧ P.EvalAt M atomMap x) :
    ∃ r0 : M.carrier, z0 < r0 ∧ r0 < z1 ∧
      P.EvalAt M atomMap r0 ∧
      (∀ y : M.carrier, r0 < y → y < z1 → ¬P.EvalAt M atomMap y) := by
  obtain ⟨x, hx0, hx1, hPx⟩ := h_exists
  obtain ⟨r0, hr0_above, hr0_below, h_neg_after, hPr0⟩ :=
    h_SUP.last_occ P.formula z0 z1 h_lt ⟨x, hx0, hx1, hPx⟩
  exact ⟨r0, hr0_above, hr0_below, hPr0, fun y hy0 hy1 hPy =>
    h_neg_after y hy0 hy1 hPy⟩

/-! ## `chainAllTrue` structural lemmas -/

/-- The empty all-top chain always holds. -/
theorem chainAllTrue_nil_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 z1 : M.carrier) :
    (chainAllTrue []).holds M atomMap z0 z1 := by
  intro y _ _
  exact TemporalPred.eval_at_top M atomMap y

/-- `chainAllTrue` of a cons is a prepend with top segment. -/
theorem chainAllTrue_cons (P : TemporalPred) (Ps : List TemporalPred) :
    chainAllTrue (P :: Ps) =
      BracketFormula.prepend TemporalPred.top P (chainAllTrue Ps) := by
  simp only [chainAllTrue, BracketFormula.allTrue, BracketFormula.prepend]
  congr 1
  · funext i
    obtain ⟨iv, hiv⟩ := i
    cases iv with
    | zero => rfl
    | succ k => rfl
  · funext i
    obtain ⟨iv, hiv⟩ := i
    cases iv with
    | zero => rfl
    | succ k => rfl

/-- First-point decomposition of an all-top chain. -/
theorem chainAllTrue_cons_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (P : TemporalPred) (Ps : List TemporalPred) (z0 z1 : M.carrier) :
    (chainAllTrue (P :: Ps)).holds M atomMap z0 z1 ↔
    ∃ c : M.carrier, z0 < c ∧ c < z1 ∧ P.EvalAt M atomMap c ∧
      (chainAllTrue Ps).holds M atomMap c z1 := by
  rw [chainAllTrue_cons]
  constructor
  · intro h
    obtain ⟨r0, h1, h2, h3, _, h5⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ _ _ z0 z1 h
    exact ⟨r0, h1, h2, h3, h5⟩
  · rintro ⟨c, h1, h2, h3, h4⟩
    exact BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 c h1 h2 h3
      (fun y _ _ => TemporalPred.eval_at_top M atomMap y) h4

/-- Last-point decomposition of an all-top chain. -/
theorem chainAllTrue_snoc_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Ps : List TemporalPred) (P : TemporalPred) :
    ∀ (z0 z1 : M.carrier),
    (chainAllTrue (Ps ++ [P])).holds M atomMap z0 z1 ↔
    ∃ c : M.carrier, z0 < c ∧ c < z1 ∧
      (chainAllTrue Ps).holds M atomMap z0 c ∧ P.EvalAt M atomMap c := by
  induction Ps with
  | nil =>
    intro z0 z1
    rw [List.nil_append, chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨c, h1, h2, h3, _⟩
      exact ⟨c, h1, h2, chainAllTrue_nil_holds M atomMap z0 c, h3⟩
    · rintro ⟨c, h1, h2, _, h4⟩
      exact ⟨c, h1, h2, h4, chainAllTrue_nil_holds M atomMap c z1⟩
  | cons Q Ps' ih =>
    intro z0 z1
    rw [List.cons_append, chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨c, h1, h2, h3, h4⟩
      obtain ⟨d, hd1, hd2, hd3, hd4⟩ := (ih c z1).mp h4
      exact ⟨d, lt_trans h1 hd1, hd2,
        (chainAllTrue_cons_holds_iff M atomMap Q Ps' z0 d).mpr ⟨c, h1, hd1, h3, hd3⟩,
        hd4⟩
    · rintro ⟨d, hd1, hd2, hd3, hd4⟩
      obtain ⟨c, h1, h2, h3, h4⟩ :=
        (chainAllTrue_cons_holds_iff M atomMap Q Ps' z0 d).mp hd3
      exact ⟨c, h1, lt_trans h2 hd2, h3, (ih c z1).mpr ⟨d, h2, hd2, h4, hd4⟩⟩

/-- All-top chains are monotone in the left endpoint. -/
theorem chainAllTrue_holds_mono_left {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Ps : List TemporalPred) {z0 z0' z1 : M.carrier} (h : z0' ≤ z0)
    (hch : (chainAllTrue Ps).holds M atomMap z0 z1) :
    (chainAllTrue Ps).holds M atomMap z0' z1 := by
  match Ps with
  | [] => exact chainAllTrue_nil_holds M atomMap z0' z1
  | P :: Ps' =>
    rw [chainAllTrue_cons_holds_iff] at hch ⊢
    obtain ⟨c, h1, h2, h3, h4⟩ := hch
    exact ⟨c, lt_of_le_of_lt h h1, h2, h3, h4⟩

/-- All-top chains are monotone in the right endpoint. -/
theorem chainAllTrue_holds_mono_right {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (Ps : List TemporalPred) : ∀ {z0 z1 z1' : M.carrier}, z1 ≤ z1' →
    (chainAllTrue Ps).holds M atomMap z0 z1 →
    (chainAllTrue Ps).holds M atomMap z0 z1' := by
  induction Ps with
  | nil =>
    intro z0 z1 z1' _ _
    exact chainAllTrue_nil_holds M atomMap z0 z1'
  | cons P Ps' ih =>
    intro z0 z1 z1' h hch
    rw [chainAllTrue_cons_holds_iff] at hch ⊢
    obtain ⟨c, h1, h2, h3, h4⟩ := hch
    exact ⟨c, h1, lt_of_lt_of_le h2 h, h3, ih le_rfl (ih h h4)⟩

/-! ## The Until fold (Cor 5.4(1)) -/

/-- Rabinovich's `F_i` fold: `untilFold [(α_0, β_1), …, (α_{n-1}, β_n)]` is
    `α_0 ∧ (β_1 Until (α_1 ∧ (β_2 Until … (α_{n-1} ∧ (β_n Until ⊤)))))`.
    Each pair is a bracket point type together with the segment type that
    follows it; the empty fold is `⊤` (the moved right endpoint carries no
    point type in this codebase's brackets). -/
def untilFold : List (TemporalPred × TemporalPred) → TemporalPred
  | [] => TemporalPred.top
  | (a, b) :: rest => a.conj (TemporalPred.untl (untilFold rest) b)

/-- The chain predicates `[F_1, …, F_{n+1}]` of Cor 5.4(1): the Until folds
    of all suffixes of the pair list (last entry `⊤`). -/
def untilChainPreds (ps : List (TemporalPred × TemporalPred)) : List TemporalPred :=
  ps.tails.map untilFold

theorem untilChainPreds_nil : untilChainPreds [] = [TemporalPred.top] := rfl

theorem untilChainPreds_cons (a b : TemporalPred)
    (ps : List (TemporalPred × TemporalPred)) :
    untilChainPreds ((a, b) :: ps) =
      untilFold ((a, b) :: ps) :: untilChainPreds ps := by
  simp [untilChainPreds]

/-! ## List-form brackets (prepend recursion) -/

/-- The bracket `[s, α_0, β_1, α_1, …, β_{n-1}, α_{n-1}, β_n]` built by
    repeated prepend from a leading segment type `s` and the pair list
    `[(α_0, β_1), …, (α_{n-1}, β_n)]` (each point type paired with the
    segment type after it). -/
def bracketOf (s : TemporalPred) :
    (ps : List (TemporalPred × TemporalPred)) → BracketFormula ps.length
  | [] => BracketFormula.trivial s
  | (a, b) :: rest => BracketFormula.prepend s a (bracketOf b rest)

theorem bracketOf_nil_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s : TemporalPred) (z0 z1 : M.carrier) :
    (bracketOf s []).holds M atomMap z0 z1 ↔
    ∀ y : M.carrier, z0 < y → y < z1 → s.EvalAt M atomMap y :=
  BracketFormula.trivial_holds M atomMap s z0 z1

theorem bracketOf_cons_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s a b : TemporalPred) (ps : List (TemporalPred × TemporalPred))
    (z0 z1 : M.carrier) :
    (bracketOf s ((a, b) :: ps)).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      (∀ y : M.carrier, z0 < y → y < r → s.EvalAt M atomMap y) ∧
      a.EvalAt M atomMap r ∧ (bracketOf b ps).holds M atomMap r z1 := by
  constructor
  · intro h
    obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ s a z0 z1 h
    exact ⟨r, h1, h2, h4, h3, h5⟩
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    exact BracketFormula.prepend_holds M atomMap _ s a z0 z1 r h1 h2 h4 h3 h5

/-! ## Bridging arbitrary brackets to list form -/

/-- The fold pairs of a bracket: each point type with the segment type
    after it, in order. -/
def BracketFormula.foldPairs {n : Nat} (bf : BracketFormula n) :
    List (TemporalPred × TemporalPred) :=
  (List.finRange n).map fun i => (bf.pointTypes i, bf.segmentTypes i.succ)

/-- A bracket with `n + 1` points is the prepend of its head data onto its
    tail. -/
theorem BracketFormula.eq_prepend_tail {n : Nat} (bf : BracketFormula (n + 1)) :
    bf = BracketFormula.prepend (bf.segmentTypes ⟨0, Nat.succ_pos _⟩)
      (bf.pointTypes ⟨0, Nat.succ_pos _⟩) bf.tail := by
  cases bf with
  | mk pt st =>
    simp only [prepend, tail]
    congr 1
    · funext i
      obtain ⟨iv, hiv⟩ := i
      cases iv with
      | zero => rfl
      | succ k => rfl
    · funext i
      obtain ⟨iv, hiv⟩ := i
      cases iv with
      | zero => rfl
      | succ k => rfl

/-- Fold pairs of an `n + 1`-point bracket decompose as head pair plus the
    tail's fold pairs. -/
theorem BracketFormula.foldPairs_succ {n : Nat} (bf : BracketFormula (n + 1)) :
    bf.foldPairs =
      (bf.pointTypes ⟨0, Nat.succ_pos _⟩, bf.segmentTypes ⟨1, by omega⟩) ::
        bf.tail.foldPairs := by
  simp only [foldPairs, List.finRange_succ, List.map_cons, List.map_map, tail]
  refine congrArg₂ List.cons rfl ?_
  refine List.map_congr_left fun i _ => ?_
  refine congrArg₂ Prod.mk (congrArg bf.pointTypes (Fin.ext ?_))
    (congrArg bf.segmentTypes (Fin.ext ?_)) <;> simp [Fin.succ]

/-- **Bridge**: an arbitrary bracket holds iff its list form does. -/
theorem BracketFormula.holds_iff_bracketOf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    bf.holds M atomMap z0 z1 ↔
    (bracketOf (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) bf.foldPairs).holds
      M atomMap z0 z1 := by
  intro n
  induction n with
  | zero =>
    intro bf z0 z1
    have hfp : bf.foldPairs = [] := by simp [foldPairs]
    rw [hfp, bracketOf_nil_holds_iff]
    exact Iff.rfl
  | succ m ih =>
    intro bf z0 z1
    rw [foldPairs_succ, bracketOf_cons_holds_iff]
    conv_lhs => rw [eq_prepend_tail bf]
    constructor
    · intro h
      obtain ⟨r, h1, h2, h3, h4, h5⟩ :=
        BracketFormula.prepend_holds_inv M atomMap _ _ _ z0 z1 h
      exact ⟨r, h1, h2, h4, h3, (ih bf.tail r z1).mp h5⟩
    · rintro ⟨r, h1, h2, h3, h4, h5⟩
      exact BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 r h1 h2 h4 h3
        ((ih bf.tail r z1).mpr h5)

/-! ## Cor 5.4(1): the chain observation -/

/-- **Cor 5.4(1) chain observation** (Rabinovich chunk_0015 md:9-27,
    endpoint-free form): a bracket instance ending at some `z ∈ (z0, z1)`
    exists iff the head Until-fold `F̂ = s Until F_1` holds at `z0` and a
    pointwise increasing chain of the suffix folds exists in `(z0, z1)`.
    The ⇐ direction is the paper's induction with the Until-witness
    `y ≤ c / y > c` relink case split. -/
theorem exists_bracketOf_right_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (ps : List (TemporalPred × TemporalPred)) (s : TemporalPred)
      (z0 z1 : M.carrier), z0 < z1 →
    ((∃ z : M.carrier, z0 < z ∧ z < z1 ∧
        (bracketOf s ps).holds M atomMap z0 z) ↔
      ((TemporalPred.untl (untilFold ps) s).EvalAt M atomMap z0 ∧
       (chainAllTrue (untilChainPreds ps)).holds M atomMap z0 z1)) := by
  intro ps
  induction ps with
  | nil =>
    intro s z0 z1 _h_lt
    rw [untilChainPreds_nil, TemporalPred.eval_at_untl,
      chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨z, hz0, hz1, hz⟩
      rw [bracketOf_nil_holds_iff] at hz
      exact ⟨⟨z, hz0, TemporalPred.eval_at_top M atomMap z, fun w h1 h2 => hz w h1 h2⟩,
        ⟨z, hz0, hz1, TemporalPred.eval_at_top M atomMap z,
          chainAllTrue_nil_holds M atomMap z z1⟩⟩
    · rintro ⟨⟨y, hy0, _, hyseg⟩, ⟨c, hc0, hc1, _, _⟩⟩
      rcases le_or_gt y c with h | h
      · exact ⟨y, hy0, lt_of_le_of_lt h hc1,
          (bracketOf_nil_holds_iff M atomMap s z0 y).mpr hyseg⟩
      · exact ⟨c, hc0, hc1,
          (bracketOf_nil_holds_iff M atomMap s z0 c).mpr
            (fun w h1 h2 => hyseg w h1 (lt_trans h2 h))⟩
  | cons ab rest ih =>
    obtain ⟨a, b⟩ := ab
    intro s z0 z1 h_lt
    rw [untilChainPreds_cons, TemporalPred.eval_at_untl,
      chainAllTrue_cons_holds_iff]
    constructor
    · -- bracket instance → F̂(z0) ∧ chain
      rintro ⟨z, hz0, hz1, hz⟩
      rw [bracketOf_cons_holds_iff] at hz
      obtain ⟨r, hr0, hrz, hrseg, hra, hrtail⟩ := hz
      have h_rz1 : r < z1 := lt_trans hrz hz1
      obtain ⟨hFhat_r, hchain_rest⟩ :=
        (ih b r z1 h_rz1).mp ⟨z, hrz, hz1, hrtail⟩
      have hFr : (untilFold ((a, b) :: rest)).EvalAt M atomMap r := by
        rw [show untilFold ((a, b) :: rest) =
              a.conj (TemporalPred.untl (untilFold rest) b) from rfl,
          TemporalPred.eval_at_conj]
        exact ⟨hra, hFhat_r⟩
      exact ⟨⟨r, hr0, hFr, hrseg⟩,
        ⟨r, hr0, h_rz1, hFr, hchain_rest⟩⟩
    · -- F̂(z0) ∧ chain → bracket instance (the relink induction step)
      rintro ⟨⟨y, hy0, hyF, hyseg⟩, ⟨c, hc0, hc1, hcF, hcchain⟩⟩
      rw [show untilFold ((a, b) :: rest) =
            a.conj (TemporalPred.untl (untilFold rest) b) from rfl,
        TemporalPred.eval_at_conj] at hyF hcF
      -- pick the first bracket witness r: y if y ≤ c, else c
      rcases le_or_gt y c with hyc | hcy
      · -- r := y (the Until witness is in bounds)
        have h_yz1 : y < z1 := lt_of_le_of_lt hyc hc1
        have hchain_y : (chainAllTrue (untilChainPreds rest)).holds M atomMap y z1 :=
          chainAllTrue_holds_mono_left M atomMap _ hyc hcchain
        obtain ⟨z, hz1, hz2, hz3⟩ :=
          (ih b y z1 h_yz1).mpr ⟨hyF.2, hchain_y⟩
        exact ⟨z, lt_trans hy0 hz1, hz2,
          (bracketOf_cons_holds_iff M atomMap s a b rest z0 z).mpr
            ⟨y, hy0, hz1, hyseg, hyF.1, hz3⟩⟩
      · -- r := c (the chain point relinks)
        have hcseg : ∀ w : M.carrier, z0 < w → w < c → s.EvalAt M atomMap w :=
          fun w h1 h2 => hyseg w h1 (lt_trans h2 hcy)
        obtain ⟨z, hz1, hz2, hz3⟩ :=
          (ih b c z1 hc1).mpr ⟨hcF.2, hcchain⟩
        exact ⟨z, lt_trans hc0 hz1, hz2,
          (bracketOf_cons_holds_iff M atomMap s a b rest z0 z).mpr
            ⟨c, hc0, hz1, hcseg, hcF.1, hz3⟩⟩

/-! ## Cor 5.4(1): assembly -/

/-- Head decomposition of the chain-predicate list. -/
theorem untilChainPreds_head_cons (ps : List (TemporalPred × TemporalPred)) :
    ∃ L, untilChainPreds ps = untilFold ps :: L := by
  cases ps with
  | nil => exact ⟨[], rfl⟩
  | cons ab rest =>
    obtain ⟨a, b⟩ := ab
    exact ⟨untilChainPreds rest, untilChainPreds_cons a b rest⟩

/-- The attained first-`¬s` pin disjunct of `negBoundedRightFix`: the bracket
    `[s ∧ ¬F₁, (¬s ∧ ¬F₁), ⊤]`. This is the interval form of Rabinovich's
    `¬F₀(z0)` endpoint disjunct: on attained-INF structures, `¬(s Until F₁)`
    at `z0` (with a chain point available) is witnessed by the attained first
    `¬s`-point, below and at which `F₁` fails. -/
def rightPinBracket (s F1 : TemporalPred) : BracketFormula 1 :=
  BracketFormula.prepend (s.conj F1.neg) ((s.neg).conj F1.neg)
    (BracketFormula.trivial TemporalPred.top)

/-- Semantic characterization of the pin disjunct. -/
theorem rightPinBracket_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s F1 : TemporalPred) (z0 z1 : M.carrier) :
    (rightPinBracket s F1).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      (∀ y : M.carrier, z0 < y → y < r →
        s.EvalAt M atomMap y ∧ ¬F1.EvalAt M atomMap y) ∧
      ¬s.EvalAt M atomMap r ∧ ¬F1.EvalAt M atomMap r := by
  unfold rightPinBracket
  constructor
  · intro h
    obtain ⟨r, h1, h2, h3, h4, _⟩ :=
      BracketFormula.prepend_holds_inv M atomMap _ _ _ z0 z1 h
    simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg'] at h3 h4
    exact ⟨r, h1, h2, fun y hy0 hy1 => h4 y hy0 hy1, h3.1, h3.2⟩
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    refine BracketFormula.prepend_holds M atomMap _ _ _ z0 z1 r h1 h2 ?_ ?_ ?_
    · simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg']
      exact ⟨h4, h5⟩
    · intro y hy0 hy1
      simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg']
      exact h3 y hy0 hy1
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y

/-- **Cor 5.4(1), fixed formula** (Rabinovich 2014, chunk_0014 md:49): the
    V-bracket formula equivalent to `¬∃ z ∈ (z0, z1), bf.holds z0 z` on
    attained-INF structures. Disjuncts: the first-`¬β₀` pin plus the
    Lemma 5.3 chain negation `negChainOn [F₁, …, F_{n+1}]`. -/
def negBoundedRightFix {n : Nat} (bf : BracketFormula n) : VBracketFormula :=
  ⟨⟨1, rightPinBracket (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)
        (untilFold bf.foldPairs)⟩ ::
    (negChainOn (untilChainPreds bf.foldPairs)).disjuncts⟩

/-- **Cor 5.4(1) iff**: on attained-INF structures, `negBoundedRightFix bf`
    holds on `(z0, z1)` iff no `z ∈ (z0, z1)` satisfies the bracket `bf` on
    `(z0, z)`. (Only attained infima are needed for this direction; the
    left mirror additionally consumes attained suprema.) -/
theorem negBoundedRightFix_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedRightFix bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z := by
  -- Normalize the right side through the bridge and the chain observation.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z0 z) ↔
      ((TemporalPred.untl (untilFold bf.foldPairs)
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)).EvalAt M atomMap z0 ∧
       (chainAllTrue (untilChainPreds bf.foldPairs)).holds M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, h3⟩
      exact (exists_bracketOf_right_iff M atomMap bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, h3⟩ := (exists_bracketOf_right_iff M atomMap bf.foldPairs
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2, (BracketFormula.holds_iff_bracketOf M atomMap n bf z0 z).mpr h3⟩
  constructor
  · -- some disjunct holds → no bracket instance
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
  · -- no bracket instance → some disjunct holds
    intro hnex
    by_cases hchain :
      (chainAllTrue (untilChainPreds bf.foldPairs)).holds M atomMap z0 z1
    · -- chain exists, so F̂ must fail at z0: build the pin
      refine ⟨_, List.mem_cons_self .., ?_⟩
      change (rightPinBracket (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)
          (untilFold bf.foldPairs)).holds M atomMap z0 z1
      rw [rightPinBracket_holds_iff]
      have hnFhat : ¬ (TemporalPred.untl (untilFold bf.foldPairs)
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩)).EvalAt M atomMap z0 :=
        fun hFhat => hnex (h_rhs.mpr ⟨hFhat, hchain⟩)
      have h_no : ∀ y : M.carrier, z0 < y →
          (untilFold bf.foldPairs).EvalAt M atomMap y →
          ¬(∀ w : M.carrier, z0 < w → w < y →
            (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).EvalAt M atomMap w) :=
        fun y hy0 hyF hseg => hnFhat
          ((TemporalPred.eval_at_untl M atomMap _ _ z0).mpr ⟨y, hy0, hyF, hseg⟩)
      -- first chain point c carries F₁
      obtain ⟨L, hL⟩ := untilChainPreds_head_cons bf.foldPairs
      rw [hL, chainAllTrue_cons_holds_iff] at hchain
      obtain ⟨c, hc0, hc1, hcF1, -⟩ := hchain
      -- ¬β₀ occurs below c (else y := c would witness F̂)
      have h_fail : ∃ w : M.carrier, z0 < w ∧ w < c ∧
          ¬(bf.segmentTypes ⟨0, Nat.succ_pos n⟩).EvalAt M atomMap w := by
        by_contra hcon
        push Not at hcon
        exact h_no c hc0 hcF1 hcon
      obtain ⟨w0, hw1, hw2, hw3⟩ := h_fail
      obtain ⟨r0, hr00, hr01, hr0neg, hr0first⟩ :=
        h_INF.first_occ_tp (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).neg z0 z1 h_lt
          ⟨w0, hw1, lt_trans hw2 hc1,
            (TemporalPred.eval_at_neg' M atomMap _ w0).mpr hw3⟩
      have hs_before : ∀ y : M.carrier, z0 < y → y < r0 →
          (bf.segmentTypes ⟨0, Nat.succ_pos n⟩).EvalAt M atomMap y := by
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

/-! ## The Since fold (Cor 5.4(2), the mirror) -/

/-- The Since mirror of `untilFold`: `sinceFold [(α_{n-1}, β_{n-1}), …,
    (α_0, β_0)]` is `α_{n-1} ∧ (β_{n-1} Since (α_{n-2} ∧ (… ∧ (β_0 Since
    ⊤))))`. Each pair is a bracket point type together with the segment type
    that precedes it, consumed right-to-left. -/
def sinceFold : List (TemporalPred × TemporalPred) → TemporalPred
  | [] => TemporalPred.top
  | (a, b) :: rest => a.conj (TemporalPred.snce (sinceFold rest) b)

/-- The chain predicates `[G_1, …, G_{n+1}]` of Cor 5.4(2): the Since folds
    of all suffixes of the reversed pair list, in increasing chain order
    (first entry `⊤`). -/
def sinceChainPreds (mps : List (TemporalPred × TemporalPred)) : List TemporalPred :=
  (mps.tails.map sinceFold).reverse

theorem sinceChainPreds_nil : sinceChainPreds [] = [TemporalPred.top] := rfl

theorem sinceChainPreds_cons (a b : TemporalPred)
    (mps : List (TemporalPred × TemporalPred)) :
    sinceChainPreds ((a, b) :: mps) =
      sinceChainPreds mps ++ [sinceFold ((a, b) :: mps)] := by
  simp [sinceChainPreds]

/-- Last-element decomposition of the mirror chain-predicate list. -/
theorem sinceChainPreds_last_snoc (mps : List (TemporalPred × TemporalPred)) :
    ∃ L, sinceChainPreds mps = L ++ [sinceFold mps] := by
  cases mps with
  | nil => exact ⟨[], rfl⟩
  | cons ab rest =>
    obtain ⟨a, b⟩ := ab
    exact ⟨sinceChainPreds rest, sinceChainPreds_cons a b rest⟩

/-! ## List-form brackets (snoc recursion) -/

/-- The bracket `[β_0, α_0, β_1, …, α_{n-1}, s]` built by repeated snoc from
    a trailing segment type `s` and the reversed pair list
    `[(α_{n-1}, β_{n-1}), …, (α_0, β_0)]` (each point type paired with the
    segment type before it). -/
def bracketSnocOf (s : TemporalPred) :
    (mps : List (TemporalPred × TemporalPred)) → BracketFormula mps.length
  | [] => BracketFormula.trivial s
  | (a, b) :: rest => (bracketSnocOf b rest).snoc a s

theorem bracketSnocOf_nil_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s : TemporalPred) (z0 z1 : M.carrier) :
    (bracketSnocOf s []).holds M atomMap z0 z1 ↔
    ∀ y : M.carrier, z0 < y → y < z1 → s.EvalAt M atomMap y :=
  BracketFormula.trivial_holds M atomMap s z0 z1

theorem bracketSnocOf_cons_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s a b : TemporalPred) (mps : List (TemporalPred × TemporalPred))
    (z0 z1 : M.carrier) :
    (bracketSnocOf s ((a, b) :: mps)).holds M atomMap z0 z1 ↔
    ∃ x : M.carrier, z0 < x ∧ x < z1 ∧
      (bracketSnocOf b mps).holds M atomMap z0 x ∧
      a.EvalAt M atomMap x ∧
      ∀ y : M.carrier, x < y → y < z1 → s.EvalAt M atomMap y :=
  BracketFormula.snoc_holds_iff M atomMap (bracketSnocOf b mps) a s z0 z1

/-! ## Bridging arbitrary brackets to snoc-list form -/

/-- The reversed fold pairs of a bracket: each point type with the segment
    type before it, from the last point down to the first. Defined by
    recursion through `front` so its cons unfolding is definitional. -/
def BracketFormula.foldPairsRev :
    {n : Nat} → BracketFormula n → List (TemporalPred × TemporalPred)
  | 0, _ => []
  | n + 1, bf =>
    (bf.pointTypes ⟨n, Nat.lt_succ_self n⟩, bf.segmentTypes ⟨n, by omega⟩) ::
      bf.front.foldPairsRev

/-- **Mirror bridge**: an arbitrary bracket holds iff its snoc-list form
    does. -/
theorem BracketFormula.holds_iff_bracketSnocOf {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (n : Nat) (bf : BracketFormula n) (z0 z1 : M.carrier),
    bf.holds M atomMap z0 z1 ↔
    (bracketSnocOf (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
      bf.foldPairsRev).holds M atomMap z0 z1 := by
  intro n
  induction n with
  | zero =>
    intro bf z0 z1
    rw [show bf.foldPairsRev = [] from rfl, bracketSnocOf_nil_holds_iff]
    exact Iff.rfl
  | succ m ih =>
    intro bf z0 z1
    rw [show bf.foldPairsRev =
          (bf.pointTypes ⟨m, Nat.lt_succ_self m⟩,
           bf.segmentTypes ⟨m, by omega⟩) :: bf.front.foldPairsRev from rfl,
      bracketSnocOf_cons_holds_iff,
      BracketFormula.holds_succ_iff]
    constructor
    · rintro ⟨x, h1, h2, h3, h4, h5⟩
      exact ⟨x, h1, h2, (ih bf.front z0 x).mp h3, h4, h5⟩
    · rintro ⟨x, h1, h2, h3, h4, h5⟩
      exact ⟨x, h1, h2, (ih bf.front z0 x).mpr h3, h4, h5⟩

/-! ## Cor 5.4(2): the mirror chain observation -/

/-- **Cor 5.4(2) chain observation** (mirror of
    `exists_bracketOf_right_iff`): a bracket instance starting at some
    `z ∈ (z0, z1)` exists iff the trailing Since-fold `Ĝ = s Since G` holds
    at `z1` and a pointwise increasing chain of the mirror folds exists in
    `(z0, z1)`. The ⇐ direction is the mirrored relink induction with the
    Since-witness `c ≤ y / y < c` case split. -/
theorem exists_bracketSnocOf_left_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) :
    ∀ (mps : List (TemporalPred × TemporalPred)) (s : TemporalPred)
      (z0 z1 : M.carrier), z0 < z1 →
    ((∃ z : M.carrier, z0 < z ∧ z < z1 ∧
        (bracketSnocOf s mps).holds M atomMap z z1) ↔
      ((TemporalPred.snce (sinceFold mps) s).EvalAt M atomMap z1 ∧
       (chainAllTrue (sinceChainPreds mps)).holds M atomMap z0 z1)) := by
  intro mps
  induction mps with
  | nil =>
    intro s z0 z1 _h_lt
    rw [sinceChainPreds_nil, TemporalPred.eval_at_snce,
      chainAllTrue_cons_holds_iff]
    constructor
    · rintro ⟨z, hz0, hz1, hz⟩
      rw [bracketSnocOf_nil_holds_iff] at hz
      exact ⟨⟨z, hz1, TemporalPred.eval_at_top M atomMap z, fun w h1 h2 => hz w h1 h2⟩,
        ⟨z, hz0, hz1, TemporalPred.eval_at_top M atomMap z,
          chainAllTrue_nil_holds M atomMap z z1⟩⟩
    · rintro ⟨⟨y, hy1, _, hyseg⟩, ⟨c, hc0, hc1, _, _⟩⟩
      rcases le_or_gt c y with h | h
      · exact ⟨y, lt_of_lt_of_le hc0 h, hy1,
          (bracketSnocOf_nil_holds_iff M atomMap s y z1).mpr hyseg⟩
      · exact ⟨c, hc0, hc1,
          (bracketSnocOf_nil_holds_iff M atomMap s c z1).mpr
            (fun w h1 h2 => hyseg w (lt_trans h h1) h2)⟩
  | cons ab rest ih =>
    obtain ⟨a, b⟩ := ab
    intro s z0 z1 h_lt
    rw [TemporalPred.eval_at_snce, sinceChainPreds_cons]
    constructor
    · -- bracket instance → Ĝ(z1) ∧ chain
      rintro ⟨z, hz0, hz1, hz⟩
      rw [bracketSnocOf_cons_holds_iff] at hz
      obtain ⟨x, hzx, hxz1, hxfront, hxa, hxseg⟩ := hz
      have h_z0x : z0 < x := lt_trans hz0 hzx
      obtain ⟨hGhat_x, hchain_rest⟩ :=
        (ih b z0 x h_z0x).mp ⟨z, hz0, hzx, hxfront⟩
      have hGx : (sinceFold ((a, b) :: rest)).EvalAt M atomMap x := by
        rw [show sinceFold ((a, b) :: rest) =
              a.conj (TemporalPred.snce (sinceFold rest) b) from rfl,
          TemporalPred.eval_at_conj]
        exact ⟨hxa, hGhat_x⟩
      exact ⟨⟨x, hxz1, hGx, hxseg⟩,
        (chainAllTrue_snoc_holds_iff M atomMap _ _ z0 z1).mpr
          ⟨x, h_z0x, hxz1, hchain_rest, hGx⟩⟩
    · -- Ĝ(z1) ∧ chain → bracket instance (the mirrored relink step)
      rintro ⟨⟨y, hy1, hyG, hyseg⟩, hchain⟩
      obtain ⟨c, hc0, hc1, hcchain, hcG⟩ :=
        (chainAllTrue_snoc_holds_iff M atomMap _ _ z0 z1).mp hchain
      rw [show sinceFold ((a, b) :: rest) =
            a.conj (TemporalPred.snce (sinceFold rest) b) from rfl,
        TemporalPred.eval_at_conj] at hyG hcG
      rcases le_or_gt c y with hcy | hyc
      · -- x := y (the Since witness is in bounds)
        have h_z0y : z0 < y := lt_of_lt_of_le hc0 hcy
        have hchain_y : (chainAllTrue (sinceChainPreds rest)).holds M atomMap z0 y :=
          chainAllTrue_holds_mono_right M atomMap _ hcy hcchain
        obtain ⟨z, hz1, hz2, hz3⟩ :=
          (ih b z0 y h_z0y).mpr ⟨hyG.2, hchain_y⟩
        exact ⟨z, hz1, lt_trans hz2 hy1,
          (bracketSnocOf_cons_holds_iff M atomMap s a b rest z z1).mpr
            ⟨y, hz2, hy1, hz3, hyG.1, hyseg⟩⟩
      · -- x := c (the chain point relinks)
        have hcseg : ∀ w : M.carrier, c < w → w < z1 → s.EvalAt M atomMap w :=
          fun w h1 h2 => hyseg w (lt_trans hyc h1) h2
        obtain ⟨z, hz1, hz2, hz3⟩ :=
          (ih b z0 c hc0).mpr ⟨hcG.2, hcchain⟩
        exact ⟨z, hz1, lt_trans hz2 hc1,
          (bracketSnocOf_cons_holds_iff M atomMap s a b rest z z1).mpr
            ⟨c, hz2, hc1, hz3, hcG.1, hcseg⟩⟩

/-! ## Cor 5.4(2): assembly -/

/-- The attained last-`¬s` pin disjunct of `negBoundedLeftFix`: the bracket
    `[⊤, (¬s ∧ ¬G), s ∧ ¬G]`. Mirror of `rightPinBracket`, witnessed by the
    attained last `¬s`-point (`HasAttainedSUP`), above and at which `G`
    fails. -/
def leftPinBracket (s G : TemporalPred) : BracketFormula 1 :=
  (BracketFormula.trivial TemporalPred.top).snoc
    ((s.neg).conj G.neg) (s.conj G.neg)

/-- Semantic characterization of the mirror pin disjunct. -/
theorem leftPinBracket_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s G : TemporalPred) (z0 z1 : M.carrier) :
    (leftPinBracket s G).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      ¬s.EvalAt M atomMap r ∧ ¬G.EvalAt M atomMap r ∧
      (∀ y : M.carrier, r < y → y < z1 →
        s.EvalAt M atomMap y ∧ ¬G.EvalAt M atomMap y) := by
  unfold leftPinBracket
  rw [BracketFormula.snoc_holds_iff]
  constructor
  · rintro ⟨r, h1, h2, _, h4, h5⟩
    simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg'] at h4 h5
    exact ⟨r, h1, h2, h4.1, h4.2, fun y hy0 hy1 => h5 y hy0 hy1⟩
  · rintro ⟨r, h1, h2, h3, h4, h5⟩
    refine ⟨r, h1, h2, ?_, ?_, ?_⟩
    · rw [BracketFormula.trivial_holds]
      intro y _ _
      exact TemporalPred.eval_at_top M atomMap y
    · simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg']
      exact ⟨h3, h4⟩
    · intro y hy0 hy1
      simp only [TemporalPred.eval_at_conj, TemporalPred.eval_at_neg']
      exact h5 y hy0 hy1

/-- **Cor 5.4(2), fixed formula** (Rabinovich 2014, chunk_0015 md:43): the
    V-bracket formula equivalent to `¬∃ z ∈ (z0, z1), bf.holds z z1`.
    Mirror of `negBoundedRightFix`: last-`¬β_n` pin plus the Lemma 5.3
    chain negation over the Since folds. -/
def negBoundedLeftFix {n : Nat} (bf : BracketFormula n) : VBracketFormula :=
  ⟨⟨1, leftPinBracket (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
        (sinceFold bf.foldPairsRev)⟩ ::
    (negChainOn (sinceChainPreds bf.foldPairsRev)).disjuncts⟩

/-- **Cor 5.4(2) iff**: on structures with attained infima AND suprema,
    `negBoundedLeftFix bf` holds on `(z0, z1)` iff no `z ∈ (z0, z1)`
    satisfies the bracket `bf` on `(z, z1)`. The last-occurrence walk of the
    pin disjunct consumes `HasAttainedSUP`; the Lemma 5.3
    chain negation still consumes `HasAttainedINF`. -/
theorem negBoundedLeftFix_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap) (h_SUP : HasAttainedSUP M atomMap)
    {n : Nat} (bf : BracketFormula n) (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negBoundedLeftFix bf).holds M atomMap z0 z1 ↔
    ¬ ∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z z1 := by
  -- Normalize the right side through the mirror bridge and chain observation.
  have h_rhs : (∃ z : M.carrier, z0 < z ∧ z < z1 ∧ bf.holds M atomMap z z1) ↔
      ((TemporalPred.snce (sinceFold bf.foldPairsRev)
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)).EvalAt M atomMap z1 ∧
       (chainAllTrue (sinceChainPreds bf.foldPairsRev)).holds M atomMap z0 z1) := by
    constructor
    · rintro ⟨z, h1, h2, h3⟩
      exact (exists_bracketSnocOf_left_iff M atomMap bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mp
        ⟨z, h1, h2, (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mp h3⟩
    · intro h
      obtain ⟨z, h1, h2, h3⟩ := (exists_bracketSnocOf_left_iff M atomMap bf.foldPairsRev
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩) z0 z1 h_lt).mpr h
      exact ⟨z, h1, h2,
        (BracketFormula.holds_iff_bracketSnocOf M atomMap n bf z z1).mpr h3⟩
  constructor
  · -- some disjunct holds → no bracket instance
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
  · -- no bracket instance → some disjunct holds
    intro hnex
    by_cases hchain :
      (chainAllTrue (sinceChainPreds bf.foldPairsRev)).holds M atomMap z0 z1
    · -- chain exists, so Ĝ must fail at z1: build the mirror pin
      refine ⟨_, List.mem_cons_self .., ?_⟩
      change (leftPinBracket (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)
          (sinceFold bf.foldPairsRev)).holds M atomMap z0 z1
      rw [leftPinBracket_holds_iff]
      have hnGhat : ¬ (TemporalPred.snce (sinceFold bf.foldPairsRev)
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩)).EvalAt M atomMap z1 :=
        fun hGhat => hnex (h_rhs.mpr ⟨hGhat, hchain⟩)
      have h_no : ∀ y : M.carrier, y < z1 →
          (sinceFold bf.foldPairsRev).EvalAt M atomMap y →
          ¬(∀ w : M.carrier, y < w → w < z1 →
            (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).EvalAt M atomMap w) :=
        fun y hy1 hyG hseg => hnGhat
          ((TemporalPred.eval_at_snce M atomMap _ _ z1).mpr ⟨y, hy1, hyG, hseg⟩)
      -- last chain point c carries G
      obtain ⟨L, hL⟩ := sinceChainPreds_last_snoc bf.foldPairsRev
      rw [hL] at hchain
      obtain ⟨c, hc0, hc1, -, hcG⟩ :=
        (chainAllTrue_snoc_holds_iff M atomMap L _ z0 z1).mp hchain
      -- ¬β_n occurs above c (else y := c would witness Ĝ)
      have h_fail : ∃ w : M.carrier, c < w ∧ w < z1 ∧
          ¬(bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).EvalAt M atomMap w := by
        by_contra hcon
        push Not at hcon
        exact h_no c hc1 hcG hcon
      obtain ⟨w0, hw1, hw2, hw3⟩ := h_fail
      obtain ⟨r0, hr00, hr01, hr0neg, hr0last⟩ :=
        h_SUP.last_occ_tp (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).neg z0 z1 h_lt
          ⟨w0, lt_trans hc0 hw1, hw2,
            (TemporalPred.eval_at_neg' M atomMap _ w0).mpr hw3⟩
      have hs_after : ∀ y : M.carrier, r0 < y → y < z1 →
          (bf.segmentTypes ⟨n, Nat.lt_succ_self n⟩).EvalAt M atomMap y := by
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


end FormalSystem.Metalogic.WeakCanonical.Kamp
