import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.NegFixOne
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.ConcatPin
import Bimodal.Metalogic.WeakCanonical.Kamp.EANegationFix.BoundedFixAnchored
import Bimodal.Metalogic.WeakCanonical.Kamp.VecEAConjFull

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! # Lemma 5.1 general recursion: `BracketFormula.negFix` (task 350 Phase 10b-ii)

The general fixed-formula negation of a bracket `[β0, α0, β1, …, α_{n-1}, βn]`
on `(z0, z1)`, per Rabinovich Lemma 5.1, **PDF pp.9-10**, with the case gates
riding IN the disjuncts.

**Correspondence guard.** `BracketFormula.negFix_iff` below is Lemma 5.1; `negFixList` is the
`Aᵢ`/`Bᵢ` split plus the closing induction (PDF pp.10-11). The full page-cited Section 5
correspondence table is `Kamp/Section5Correspondence.lean`, reachable from
`Theories/Bimodal.lean` and so CI-protected — **consult it before planning any Section 5 work**.
Cite Rabinovich by PDF page only: the former `chunk_0017` citation here pointed into the
companion `.md` conversion, which is corrupt (drops displayed equations, inverts `k ≠ m` to
`k = m`), and has been re-cited by page.

**Carrier delta.** `BracketFormula.negFix_iff` is **INF-anchored**: it assumes
`HasAttainedINF`/`HasAttainedSUP`, which is strictly stronger than Rabinovich's Dedekind
completeness — stronger even than `HasDefinableINF`, machine-refuted as already too strong by
`hasDefinableINF_excludes_kplus` (`Lemma53.lean:282`). It is therefore **not** a refutation of
the ruling that the model-*independent* Prop 4.2 backward direction is unfixable at this level
(`Boneyard/NegationIndep.lean:346-364`); it **confirms** that ruling's diagnosis, since the
anchors are precisely what make the direction go through. Do not cite it as license for a bare
model-independent attempt.

The case gates:

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
