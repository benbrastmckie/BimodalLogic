/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFix.NegFix
import FormalSystem.Metalogic.WeakCanonical.Kamp.EANegationFixFaithful.NegFixOneFaithful

/-!
# Lemma 5.1's recursion, at `VVecEA2` over the faithful carrier (Rabinovich, PDF pp.10-11)

This module is the inductive step of the very argument the one-witness module
(`NegFixOneFaithful.lean`) settled at a single witness. PDF p.10 states the target:

> *"It is sufficient to show that `(∃z)^{<z₁}_{>z₀} INF^{¬β₁}(z) ∧
> ¬[α₀,β₁,α₁,…,β_{n+1},α_{n+1}](z₀,z₁)` is equivalent to a `∨∃⃗∀` formula. We prove this by
> induction on `n`. The basis is trivial. Inductive step `n ↦ n+1`."*

and then defines, immediately below, the `Aᵢ`/`Bᵢ` split that the induction runs on:

> `Aᵢ⁻(z₀,z) := [α₀,β₁,…,βᵢ,αᵢ](z₀,z)`, `Aᵢ⁺(z,z₁) := [αᵢ,β_{i+1},…,β_{n+1},α_{n+1}](z,z₁)`,
> `Aᵢ := Aᵢ⁻ ∧ Aᵢ⁺` for `i = 1,…,n`;
> `Bᵢ⁻(z₀,z) := [α₀,β₁,…,β_{i-1},α_{i-1},βᵢ,βᵢ](z₀,z)`,
> `Bᵢ⁺(z,z₁) := [βᵢ,βᵢ,αᵢ,β_{i+1},α_{i+1},…,β_{n+1},α_{n+1}](z,z₁)`,
> `Bᵢ := Bᵢ⁻ ∧ Bᵢ⁺` for `i = 1,…,n+1`

(the `Bᵢ⁺` spelling is read off **Figure 1**'s caption on p.10, which prints
`B₂(z₀,z,z₁) := [α₀,β₁,α₁,β₂,β₂](z₀,z) ∧ [β₂,β₂,α₂,β₃,α₃](z,z₁)`; the inline definition on the
same page drops one `βᵢ` in typesetting). The `Aᵢ` case is "`z` is one of the bracket's witness
points"; the `Bᵢ` case is "`z` falls strictly inside the `i`-th segment". Together they exhaust
the placements of an arbitrary interior `z`, which is p.11's first displayed equivalence.

## What this module reuses rather than re-derives

The `Aᵢ`/`Bᵢ` split is **already formalized, carrier-free**, as `splitsAt` / `bracketOf_splitsAt_iff`
(`EANegationFix/NegFix.lean:180`/`:216`): a `SplitEntry` records a left sub-bracket, the point type
carried at the distinguished point, and a right sub-bracket, and its three constructors are exactly
"`z` in segment 0" (a `Bᵢ` placement), "`z` at the first witness" (an `Aᵢ` placement) and "`z`
further along" (the recursive case). Nothing about that split changes when the carrier changes, so
it is imported and used unchanged.

What does change is the **gate** in front of it. `negFixList` (`EANegationFix/NegFix.lean:449`)
gates its Case 3 on an *attained* first-`¬β₁` point, supplied by `firstNegPin_or_all`
(`:137`) from `HasAttainedINF`. That dichotomy is a two-way split (`β₁` everywhere, or an attained
`¬β₁`-point). The faithful carrier `HasDedekindINF` gives a **three**-way split instead, because
`HasDedekindINF.first_occ` preserves Rabinovich's printed disjunction rather than collapsing it:

| gate | condition at the top of the recursion | source |
|---|---|---|
| Case 1 | `K⁺(¬β₁)(z₀)` — the infimum sits *at the left endpoint* | PDF p.9, Case 1; p.8 "Subcase `r₀ = z₀`" |
| Case 2 | `β₁` holds along `(z₀,z₁)` — no `¬β₁`-point at all | PDF p.10, Case 2 |
| Case 3 | the eq (5.3) pin `r₀ ∈ (z₀,z₁)` | PDF p.10, eq (5.3) |

Case 1 is the disjunct the attained formulation cannot have and does not need; it is the **limit
gate**, and `negFixListFaithful_case1_is_indispensable` below machine-checks that neither of the
other two disjuncts can cover it.

Inside Case 3 the limit alternative appears a second time, in the pin's own point type:
eq (5.3)'s third conjunct is `¬β₁(z) ∨ K⁺(¬β₁)(z)` (`infPinPoint`, `NegFixOneFaithful.lean:175`),
not `¬β₁(z)`. The step that consumes it is `bracketOne_witness_le_infPin`
(`NegFixOneFaithful.lean:317`) — carrier-free, and despite its name stated about a bare `β₁`-prefix
condition rather than about `bracketOne`, so it applies verbatim at every peel of this recursion.
Its `K⁺` branch is discharged by **density**, producing no witness point; that is exactly why the
possibly-unattained infimum suffices here.

## Structure

1. `VecPinnedItem` and its DNF machinery — the `VVecEA2` mirror of `PinnedItem` /
   `pinnedConj` / `pinnedConjAll` / `pinnedListToV` (`EANegationFix/NegFix.lean:298`-`:426`),
   rebuilt one type level up on Phase-landed `VVecEA2.conjFull`, `VVecEA2.conjEverywhere` and
   `VVecEA2.concatPin`.
2. `witness_absurd_of_kplusLeft` — the Case 1 consumer, carrier-free.
3. `negFixListFaithful` — the recursion, three disjuncts per cons step.
4. `negFixListFaithful_nil_iff`, `negFixListFaithful_iff` — the biconditional, over
   `HasDedekindINF` **alone**.
5. `negFixListFaithful_case1_is_indispensable` — the non-vacuity artifact: under `K⁺(¬β₁)(z₀)`,
   the Case 2 and Case 3 disjuncts are both *unsatisfiable*, so the limit gate is load-bearing.

## References

- Rabinovich 2014, *A Proof of Kamp's Theorem*, Lemma 5.1's inductive step, PDF pp.10-11
  (including Figure 1 on p.10 and the two displayed equivalences on p.11)
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Pinned `VVecEA2` machinery (the `Condᵢ ∧ Formᵢ` products at a shared pin)

The `VVecEA2` mirror of `EANegationFix/NegFix.lean:296`-`:426`. Structurally identical; the only
change is that each component is a `VVecEA2` rather than a `VBracketFormula`, so the endpoint
predicates survive the conjunction and the pinned concatenation. -/

/-- A pinned item at `VVecEA2`: left formula on `(z₀,r)`, point predicate at `r`, right formula on
    `(r,z₁)`, for a shared distinguished point `r`. Mirror of `PinnedItem`
    (`EANegationFix/NegFix.lean:298`). -/
structure VecPinnedItem where
  /-- Left `VVecEA2`, evaluated on `(z₀,r)`. -/
  left : VVecEA2
  /-- Point predicate at the pin `r`. -/
  atPin : TemporalPred
  /-- Right `VVecEA2`, evaluated on `(r,z₁)`. -/
  right : VVecEA2

/-- Semantics of one pinned item at a fixed pin `r`. -/
def VecPinnedItem.holdsAt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (it : VecPinnedItem) (z0 r z1 : M.carrier) : Prop :=
  it.left.holds M atomMap z0 r ∧ it.atPin.EvalAt M atomMap r ∧
    it.right.holds M atomMap r z1

/-- Conjunction of two pinned items: componentwise products, using `VVecEA2.conjFull`
    (`VecEAConjFull.lean:498`). -/
def VecPinnedItem.conj (p q : VecPinnedItem) : VecPinnedItem :=
  ⟨p.left.conjFull q.left, p.atPin.conj q.atPin, p.right.conjFull q.right⟩

/-- Semantics of the pinned-item conjunction. -/
theorem VecPinnedItem.conj_holdsAt_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (p q : VecPinnedItem) (z0 r z1 : M.carrier) :
    (p.conj q).holdsAt M atomMap z0 r z1 ↔
    p.holdsAt M atomMap z0 r z1 ∧ q.holdsAt M atomMap z0 r z1 := by
  simp only [holdsAt, conj, VVecEA2.conjFull_iff, TemporalPred.eval_at_conj]
  tauto

/-- DNF product of two pinned disjunction lists. -/
def vecPinnedConj (l1 l2 : List VecPinnedItem) : List VecPinnedItem :=
  l1.flatMap fun p => l2.map fun q => p.conj q

/-- Semantics of the DNF product. -/
theorem vecPinnedConj_holdsAt_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l1 l2 : List VecPinnedItem) (z0 r z1 : M.carrier) :
    (∃ it ∈ vecPinnedConj l1 l2, it.holdsAt M atomMap z0 r z1) ↔
    (∃ it ∈ l1, it.holdsAt M atomMap z0 r z1) ∧
    (∃ it ∈ l2, it.holdsAt M atomMap z0 r z1) := by
  simp only [vecPinnedConj, List.mem_flatMap, List.mem_map]
  constructor
  · rintro ⟨it, ⟨p, hp, q, hq, rfl⟩, hh⟩
    rw [VecPinnedItem.conj_holdsAt_iff] at hh
    exact ⟨⟨p, hp, hh.1⟩, ⟨q, hq, hh.2⟩⟩
  · rintro ⟨⟨p, hp, hph⟩, ⟨q, hq, hqh⟩⟩
    exact ⟨p.conj q, ⟨p, hp, q, hq, rfl⟩,
      (VecPinnedItem.conj_holdsAt_iff M atomMap p q z0 r z1).mpr ⟨hph, hqh⟩⟩

/-- The always-true pinned item (unit of the pinned conjunction). -/
def VecPinnedItem.unit : VecPinnedItem :=
  ⟨VVecEA2.trivialTrue, TemporalPred.top, VVecEA2.trivialTrue⟩

/-- The unit pinned item always holds. -/
theorem VecPinnedItem.unit_holdsAt {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (z0 r z1 : M.carrier) :
    VecPinnedItem.unit.holdsAt M atomMap z0 r z1 :=
  ⟨VVecEA2.trivialTrue_holds M atomMap z0 r,
    TemporalPred.eval_at_top M atomMap r,
    VVecEA2.trivialTrue_holds M atomMap r z1⟩

/-- Conjunction of a list of pinned disjunction lists (iterated DNF product). -/
def vecPinnedConjAll : List (List VecPinnedItem) → List VecPinnedItem
  | [] => [VecPinnedItem.unit]
  | l :: ls => vecPinnedConj l (vecPinnedConjAll ls)

/-- Semantics of the iterated DNF product: all conjunct lists hold at the pin. -/
theorem vecPinnedConjAll_holdsAt_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (ls : List (List VecPinnedItem)) (z0 r z1 : M.carrier) :
    (∃ it ∈ vecPinnedConjAll ls, it.holdsAt M atomMap z0 r z1) ↔
    ∀ l ∈ ls, ∃ it ∈ l, it.holdsAt M atomMap z0 r z1 := by
  induction ls with
  | nil =>
    simp only [vecPinnedConjAll, List.mem_singleton, List.not_mem_nil,
      false_implies, implies_true, iff_true]
    exact ⟨VecPinnedItem.unit, rfl, VecPinnedItem.unit_holdsAt M atomMap z0 r z1⟩
  | cons l ls ih =>
    rw [show vecPinnedConjAll (l :: ls) = vecPinnedConj l (vecPinnedConjAll ls) from
      rfl, vecPinnedConj_holdsAt_iff, ih, List.forall_mem_cons]

/-- Glue a pinned item into a `VVecEA2` on `(z₀,z₁)`: the pin is existentially bound, gated by
    `gateSeg` everywhere left of the pin and `gatePin` at the pin. Uses the Phase-landed
    `VVecEA2.conjEverywhere` and `VVecEA2.concatPin` (`VecEACombinators.lean:110`/`:194`). -/
noncomputable def VecPinnedItem.toV (it : VecPinnedItem) (gateSeg gatePin : TemporalPred) :
    VVecEA2 :=
  (it.left.conjEverywhere gateSeg).concatPin (it.atPin.conj gatePin) it.right

/-- Glue a pinned disjunction list into a single `VVecEA2`. -/
noncomputable def vecPinnedListToV (l : List VecPinnedItem) (gateSeg gatePin : TemporalPred) :
    VVecEA2 :=
  ⟨l.flatMap fun it => (it.toV gateSeg gatePin).disjuncts⟩

/-- Semantics of the glued pinned list: some interior pin `r` carries the gates and realizes some
    pinned item. Mirror of `pinnedListToV_holds_iff` (`EANegationFix/NegFix.lean:396`). -/
theorem vecPinnedListToV_holds_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (l : List VecPinnedItem) (gateSeg gatePin : TemporalPred)
    (z0 z1 : M.carrier) :
    (vecPinnedListToV l gateSeg gatePin).holds M atomMap z0 z1 ↔
    ∃ r : M.carrier, z0 < r ∧ r < z1 ∧
      (∀ y : M.carrier, z0 < y → y < r → gateSeg.EvalAt M atomMap y) ∧
      gatePin.EvalAt M atomMap r ∧
      ∃ it ∈ l, it.holdsAt M atomMap z0 r z1 := by
  constructor
  · rintro ⟨d, hmem, hh⟩
    simp only [vecPinnedListToV, List.mem_flatMap] at hmem
    obtain ⟨it, hit, hd⟩ := hmem
    have hv : (it.toV gateSeg gatePin).holds M atomMap z0 z1 := ⟨d, hd, hh⟩
    rw [VecPinnedItem.toV, VVecEA2.concatPin_holds_iff] at hv
    obtain ⟨r, h1, h2, hL, hp, hR⟩ := hv
    rw [VVecEA2.conjEverywhere_holds_iff] at hL
    rw [TemporalPred.eval_at_conj] at hp
    exact ⟨r, h1, h2, hL.2, hp.2, it, hit, hL.1, hp.1, hR⟩
  · rintro ⟨r, h1, h2, hseg, hgp, it, hit, hL, hp, hR⟩
    have hv : (it.toV gateSeg gatePin).holds M atomMap z0 z1 := by
      rw [VecPinnedItem.toV, VVecEA2.concatPin_holds_iff]
      exact ⟨r, h1, h2,
        (VVecEA2.conjEverywhere_holds_iff M atomMap it.left gateSeg z0 r).mpr ⟨hL, hseg⟩,
        (TemporalPred.eval_at_conj M atomMap it.atPin gatePin r).mpr ⟨hp, hgp⟩, hR⟩
    obtain ⟨d, hd, hh⟩ := hv
    refine ⟨d, ?_, hh⟩
    simp only [vecPinnedListToV, List.mem_flatMap]
    exact ⟨it, hit, hd⟩

/-! ## The Case 1 consumer: `K⁺(¬β₁)(z₀)` kills every witness — carrier-free (PDF p.9) -/

/-- **Case 1's whole content.** If `K⁺(¬β₁)(z₀)` holds then no point `x > z₀` can have `β₁`
    throughout `(z₀,x)`, so a bracket `[α₀,β₁,α₁,…]` has no first witness at all and fails
    outright. Rabinovich's *"In this case `¬[α₀,β₁,…](z₀,z₁)` is equivalent to True"* (PDF p.9).

    The companion of `bracketOne_witness_le_infPin` (`NegFixOneFaithful.lean:317`) at the *left
    endpoint*: there the pin sits strictly inside `(z₀,z₁)` and confines the witness to `(z₀,r₀]`;
    here it sits at `z₀` itself and leaves no room at all. Like that lemma, the `K⁺` alternative is
    discharged by density, so this consumes **no carrier**. -/
theorem witness_absurd_of_kplusLeft {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s : TemporalPred) {z0 x : M.carrier} (hx0 : z0 < x)
    (hk : kplus M atomMap s.neg.formula z0)
    (hpre : ∀ y : M.carrier, z0 < y → y < x → s.EvalAt M atomMap y) : False := by
  obtain ⟨-, hdense⟩ := hk
  obtain ⟨q, hq1, hq2, hq3⟩ := hdense x hx0
  exact ((TemporalPred.eval_at_neg' M atomMap s q).mp hq3) (hpre q hq1 hq2)

/-! ## The faithful recursion (PDF pp.10-11) -/

/-- **Lemma 5.1's recursion, faithful list form** (Rabinovich 2014, PDF pp.10-11).

    `negFixListFaithful s ps` is a `VVecEA2` whose semantics over `HasDedekindINF` is
    `¬ (bracketOf s ps).holds`.

    * `ps = []`: the negation of "`β₁` everywhere" is "`¬β₁` at some interior point"
      (`somePointBlock`). Rabinovich's *"The basis is trivial."* (PDF p.10). No carrier.
    * `ps = (a,b) :: qs`: the three gates of the faithful `HasDedekindINF` trichotomy.
      1. **Case 1** (PDF p.9): `K⁺(¬β₁)(z₀)`, carried by `kplusLeftBlock`
         (`Lemma53Faithful.lean:189`) as a pure left-endpoint predicate. `Form₁ = True`.
      2. **Case 2** (PDF p.10): `β₁` along `(z₀,z₁)` (via `VVecEA2.conjEverywhere`), conjoined
         with `Form₂` = the anchored Corollary 5.4(2) `negBoundedLeftFixAnchoredFaithful`
         (`BoundedFixAnchoredFaithful.lean:218`) — *"there is no `z ∈ (z₀,z₁)` such that
         `[α₁,β₂,…,βₙ,αₙ](z,z₁)`"*.
      3. **Case 3** (PDF p.10, eq (5.3)): the pin `r₀`, gated by `β₁` on `(z₀,r₀)` and the point
         type `infPinPoint β₁ = ¬β₁(r₀) ∨ K⁺(¬β₁)(r₀)`, carrying the pinned DNF of per-placement
         failure disjunctions over the `Aᵢ`/`Bᵢ` split (PDF pp.10-11): for the `z = r₀` placement,
         `¬α₁(r₀)` or the recursive tail failure; for each `z < r₀` placement (split entry `e`),
         the anchored `A`-failure on `(z₀,r₀)`, the pin-type failure `¬e.pin(r₀)`, or the
         recursive `B`-failure on `(r₀,z₁)`.

    Compare `negFixList` (`EANegationFix/NegFix.lean:449`), which has only disjuncts 2 and 3 and
    gates disjunct 3 on an *attained* `¬β₁`-point. Disjunct 1 is what the faithful carrier adds;
    `negFixListFaithful_case1_is_indispensable` shows the other two cannot absorb it.

    Termination is unchanged from the attained version: every recursive call is on a strictly
    shorter pair list (`splitsAt_rightPairs_length_le`, `EANegationFix/NegFix.lean:191`); the
    `A`-parts need no recursion. -/
noncomputable def negFixListFaithful : TemporalPred →
    List (TemporalPred × TemporalPred) → VVecEA2
  | s, [] => somePointBlock s.neg
  | s, (a, b) :: qs =>
      (kplusLeftBlock s.neg).disj
      ((((negBoundedLeftFixAnchoredFaithful a (bracketOf b qs)).conjEverywhere s)).disj
        (vecPinnedListToV
          (vecPinnedConjAll
            ([⟨VVecEA2.trivialTrue, a.neg, VVecEA2.trivialTrue⟩,
              ⟨VVecEA2.trivialTrue, TemporalPred.top,
                negFixListFaithful b qs⟩] ::
             (splitsAt b qs).attach.map fun ⟨e, _he⟩ =>
               [⟨negBoundedLeftFixAnchoredFaithful a (bracketOf e.leftSeg e.leftPairs),
                 TemporalPred.top, VVecEA2.trivialTrue⟩,
                ⟨VVecEA2.trivialTrue, e.pin.neg, VVecEA2.trivialTrue⟩,
                ⟨VVecEA2.trivialTrue, TemporalPred.top,
                 negFixListFaithful e.rightSeg e.rightPairs⟩]))
          s (infPinPoint s)))
  termination_by _ ps => ps.length
  decreasing_by
  · simp only [List.length_cons]
    omega
  · have hle := splitsAt_rightPairs_length_le b qs e _he
    simp only [List.length_cons]
    omega

/-- Base case of the faithful recursion — Rabinovich's *"The basis is trivial."* (PDF p.10).
    `negFixListFaithful s []` is "`¬β₁` at some interior point", the negation of "`β₁`
    everywhere". No carrier. -/
theorem negFixListFaithful_nil_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s : TemporalPred) (z0 z1 : M.carrier) :
    (negFixListFaithful s []).holds M atomMap z0 z1 ↔
    ¬ (bracketOf s []).holds M atomMap z0 z1 := by
  simp only [negFixListFaithful]
  rw [somePointBlock_holds, bracketOf_nil_holds_iff]
  constructor
  · rintro ⟨w, hw0, hw1, hw⟩ hall
    exact (TemporalPred.eval_at_neg' M atomMap s w).mp hw (hall w hw0 hw1)
  · intro h
    have hex : ∃ y : M.carrier, z0 < y ∧ y < z1 ∧ ¬ s.EvalAt M atomMap y := by
      by_contra hno
      push Not at hno
      exact h hno
    obtain ⟨y, hy0, hy1, hys⟩ := hex
    exact ⟨y, hy0, hy1, (TemporalPred.eval_at_neg' M atomMap s y).mpr hys⟩

/-- **Lemma 5.1's recursion, faithful `iff`** (Rabinovich 2014, PDF pp.10-11): over
    `HasDedekindINF` **alone**, `negFixListFaithful s ps` holds on `(z₀,z₁)` iff the list-form
    bracket `bracketOf s ps` fails there. Strong induction on the pair-list length, exactly as
    `negFixList_iff` (`EANegationFix/NegFix.lean:520`) — which needs `HasAttainedINF` **and**
    `HasAttainedSUP`.

    The three places the attained proof consumes a carrier become, respectively: the top-level
    trichotomy `HasDedekindINF.first_occ_tp` at `P := ¬β₁` (replacing `firstNegPin_or_all`, whose
    two-way dichotomy is the attained collapse of it); `negBoundedLeftFixAnchoredFaithful_iff`
    (replacing `negBoundedLeftFixAnchored_iff`, which is where `HasAttainedSUP` entered); and the
    witness-confinement step, which becomes the carrier-free `bracketOne_witness_le_infPin`. -/
theorem negFixListFaithful_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasDedekindINF M atomMap) :
    ∀ (N : Nat) (ps : List (TemporalPred × TemporalPred))
      (s : TemporalPred) (z0 z1 : M.carrier), ps.length ≤ N → z0 < z1 →
    ((negFixListFaithful s ps).holds M atomMap z0 z1 ↔
      ¬ (bracketOf s ps).holds M atomMap z0 z1) := by
  intro N
  induction N with
  | zero =>
    intro ps s z0 z1 hlen _h_lt
    have hps : ps = [] := List.length_eq_zero_iff.mp (Nat.le_zero.mp hlen)
    subst hps
    exact negFixListFaithful_nil_iff M atomMap s z0 z1
  | succ N ihN =>
    intro ps s z0 z1 hlen h_lt
    rcases ps with _ | ⟨⟨a, b⟩, qs⟩
    · exact negFixListFaithful_nil_iff M atomMap s z0 z1
    have hqs : qs.length ≤ N := by
      simp only [List.length_cons] at hlen
      omega
    simp only [negFixListFaithful]
    rw [VVecEA2.disj_holds, VVecEA2.disj_holds]
    constructor
    · -- some gated disjunct holds → the bracket fails
      rintro (h1 | h2 | h3)
      · -- Case 1: `K⁺(¬β₁)(z₀)`. No first witness can exist at all (PDF p.9).
        rw [kplusLeftBlock_holds] at h1
        intro hb
        obtain ⟨x, hx0, -, hpre, -, -⟩ :=
          (bracketOf_cons_holds_iff M atomMap s a b qs z0 z1).mp hb
        exact witness_absurd_of_kplusLeft M atomMap s hx0 h1 hpre
      · -- Case 2: `β₁` everywhere, no anchored tail instance (PDF p.10).
        obtain ⟨h2n, _hsev⟩ :=
          (VVecEA2.conjEverywhere_holds_iff M atomMap _ s z0 z1).mp h2
        have hnex := (negBoundedLeftFixAnchoredFaithful_iff M atomMap
          h_INF.toHasFaithfulDedekindINF a (bracketOf b qs) z0 z1 h_lt).mp h2n
        intro hb
        obtain ⟨x, hx0, hx1, _hpre, hax, htail⟩ :=
          (bracketOf_cons_holds_iff M atomMap s a b qs z0 z1).mp hb
        exact hnex ⟨x, hx0, hx1, hax, htail⟩
      · -- Case 3: pinned failure conjunction at the eq (5.3) pin (PDF p.10).
        obtain ⟨r, hr0, hr1, hsev, hpin, hitems⟩ :=
          (vecPinnedListToV_holds_iff M atomMap _ s (infPinPoint s) z0 z1).mp h3
        have hall := (vecPinnedConjAll_holdsAt_iff M atomMap _ z0 r z1).mp hitems
        intro hb
        obtain ⟨x, hx0, hx1, hpre, hax, htail⟩ :=
          (bracketOf_cons_holds_iff M atomMap s a b qs z0 z1).mp hb
        -- The eq (5.3) pin confines the witness to `(z₀,r]` — carrier-free, and the step at
        -- which the `K⁺` alternative is discharged by density rather than by a witness.
        have hxle : x ≤ r := bracketOne_witness_le_infPin M atomMap s hr0 hpin hpre
        rcases eq_or_lt_of_le hxle with heq | hxlt
        · -- `x = r`: the head item refutes it
          subst heq
          obtain ⟨it, hit, hh⟩ := hall _ (List.mem_cons_self ..)
          simp only [List.mem_cons, List.not_mem_nil, or_false] at hit
          rcases hit with rfl | rfl
          · have := hh.2.1
            rw [TemporalPred.eval_at_neg'] at this
            exact this hax
          · exact (ihN qs b x z1 hqs hx1).mp hh.2.2 htail
        · -- `x < r`: split the tail at the pin (the `Aᵢ`/`Bᵢ` split, PDF pp.10-11) and use the
          -- entry's item
          obtain ⟨e, he, heL, hep, heR⟩ :=
            (bracketOf_splitsAt_iff M atomMap qs b x r z1 hxlt hr1).mp htail
          have hmem : [(⟨negBoundedLeftFixAnchoredFaithful a
              (bracketOf e.leftSeg e.leftPairs),
              TemporalPred.top, VVecEA2.trivialTrue⟩ : VecPinnedItem),
            ⟨VVecEA2.trivialTrue, e.pin.neg, VVecEA2.trivialTrue⟩,
            ⟨VVecEA2.trivialTrue, TemporalPred.top,
              negFixListFaithful e.rightSeg e.rightPairs⟩] ∈
              ([⟨VVecEA2.trivialTrue, a.neg, VVecEA2.trivialTrue⟩,
                ⟨VVecEA2.trivialTrue, TemporalPred.top,
                  negFixListFaithful b qs⟩] ::
               (splitsAt b qs).attach.map fun ⟨e, he⟩ =>
                 [⟨negBoundedLeftFixAnchoredFaithful a
                     (bracketOf e.leftSeg e.leftPairs),
                   TemporalPred.top, VVecEA2.trivialTrue⟩,
                  ⟨VVecEA2.trivialTrue, e.pin.neg, VVecEA2.trivialTrue⟩,
                  ⟨VVecEA2.trivialTrue, TemporalPred.top,
                   negFixListFaithful e.rightSeg e.rightPairs⟩]) := by
            refine List.mem_cons_of_mem _ ?_
            rw [List.mem_map]
            exact ⟨⟨e, he⟩, List.mem_attach _ _, rfl⟩
          obtain ⟨it, hit, hh⟩ := hall _ hmem
          simp only [List.mem_cons, List.not_mem_nil, or_false] at hit
          rcases hit with rfl | rfl | rfl
          · -- `A`-failure: contradicts the witness `x`
            have hnA := (negBoundedLeftFixAnchoredFaithful_iff M atomMap
              h_INF.toHasFaithfulDedekindINF a
              (bracketOf e.leftSeg e.leftPairs) z0 r hr0).mp hh.1
            exact hnA ⟨x, hx0, hxlt, hax, heL⟩
          · -- pin-type failure: contradicts the entry's point type
            have := hh.2.1
            rw [TemporalPred.eval_at_neg'] at this
            exact this hep
          · -- `B`-failure: contradicts the right part, by the inductive hypothesis
            exact (ihN e.rightPairs e.rightSeg r z1
              (le_trans (splitsAt_rightPairs_length_le b qs e he) hqs)
              hr1).mp hh.2.2 heR
    · -- the bracket fails → some gated disjunct holds
      intro hnb
      by_cases hsev : ∀ y : M.carrier, z0 < y → y < z1 → s.EvalAt M atomMap y
      · -- Case 2: `β₁` everywhere (PDF p.10)
        refine Or.inr (Or.inl ((VVecEA2.conjEverywhere_holds_iff M atomMap _ s
          z0 z1).mpr ⟨(negBoundedLeftFixAnchoredFaithful_iff M atomMap
            h_INF.toHasFaithfulDedekindINF a
            (bracketOf b qs) z0 z1 h_lt).mpr ?_, hsev⟩))
        rintro ⟨x, hx0, hx1, hax, htail⟩
        exact hnb ((bracketOf_cons_holds_iff M atomMap s a b qs z0 z1).mpr
          ⟨x, hx0, hx1, fun y hy0 hy1 => hsev y hy0 (lt_trans hy1 hx1),
            hax, htail⟩)
      · -- `¬β₁` occurs somewhere: the faithful carrier's two remaining gates
        push Not at hsev
        obtain ⟨w, hw0, hw1, hws⟩ := hsev
        rcases h_INF.first_occ_tp s.neg z0 z1 h_lt
          ⟨w, hw0, hw1, (TemporalPred.eval_at_neg' M atomMap s w).mpr hws⟩ with
          hk | ⟨r0, hr00, hr01, h_none, h_disj⟩
        · -- Case 1: the infimum sits at the left endpoint, as `K⁺(¬β₁)(z₀)` (PDF p.9)
          exact Or.inl ((kplusLeftBlock_holds M atomMap s.neg z0 z1).mpr hk)
        · -- Case 3: the eq (5.3) pin realizes every failure item (PDF p.10)
          have hsev0 : ∀ y : M.carrier, z0 < y → y < r0 → s.EvalAt M atomMap y := by
            intro y hy0 hy1
            have := h_none y hy0 hy1
            rw [TemporalPred.eval_at_neg'] at this
            exact not_not.mp this
          have hpin : (infPinPoint s).EvalAt M atomMap r0 := by
            rw [infPinPoint_holds]
            rcases h_disj with hns | hkr
            · exact Or.inl ((TemporalPred.eval_at_neg' M atomMap s r0).mp hns)
            · exact Or.inr hkr
          refine Or.inr (Or.inr ((vecPinnedListToV_holds_iff M atomMap _ s (infPinPoint s)
            z0 z1).mpr ⟨r0, hr00, hr01, hsev0, hpin, ?_⟩))
          rw [vecPinnedConjAll_holdsAt_iff]
          intro l hl
          rw [List.mem_cons] at hl
          rcases hl with rfl | hl'
          · -- head item: `¬α₁(r₀)` or the recursive tail failure
            by_cases hB : (negFixListFaithful b qs).holds M atomMap r0 z1
            · exact ⟨⟨VVecEA2.trivialTrue, TemporalPred.top,
                negFixListFaithful b qs⟩, by simp,
                VVecEA2.trivialTrue_holds M atomMap z0 r0,
                TemporalPred.eval_at_top M atomMap r0, hB⟩
            · refine ⟨⟨VVecEA2.trivialTrue, a.neg, VVecEA2.trivialTrue⟩, by simp,
                VVecEA2.trivialTrue_holds M atomMap z0 r0, ?_,
                VVecEA2.trivialTrue_holds M atomMap r0 z1⟩
              rw [TemporalPred.eval_at_neg']
              intro hax
              have htail : (bracketOf b qs).holds M atomMap r0 z1 := by
                by_contra hc
                exact hB ((ihN qs b r0 z1 hqs hr01).mpr hc)
              exact hnb ((bracketOf_cons_holds_iff M atomMap s a b qs
                z0 z1).mpr ⟨r0, hr00, hr01, hsev0, hax, htail⟩)
          · -- split-entry item: `A`-failure, pin-type failure, or `B`-failure
            rw [List.mem_map] at hl'
            obtain ⟨⟨e, he⟩, -, rfl⟩ := hl'
            by_cases hB : (negFixListFaithful e.rightSeg e.rightPairs).holds M atomMap
              r0 z1
            · exact ⟨⟨VVecEA2.trivialTrue, TemporalPred.top,
                negFixListFaithful e.rightSeg e.rightPairs⟩, by simp,
                VVecEA2.trivialTrue_holds M atomMap z0 r0,
                TemporalPred.eval_at_top M atomMap r0, hB⟩
            by_cases hp : e.pin.EvalAt M atomMap r0
            · -- pin type holds: the `A`-part must fail, else the bracket holds
              refine ⟨⟨negBoundedLeftFixAnchoredFaithful a
                  (bracketOf e.leftSeg e.leftPairs),
                  TemporalPred.top, VVecEA2.trivialTrue⟩, by simp,
                ?_, TemporalPred.eval_at_top M atomMap r0,
                VVecEA2.trivialTrue_holds M atomMap r0 z1⟩
              rw [negBoundedLeftFixAnchoredFaithful_iff M atomMap
                h_INF.toHasFaithfulDedekindINF a
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
                  fun y hy0 hy1 => hsev0 y hy0 (lt_trans hy1 hxr), hax, htail⟩)
            · -- pin type fails
              refine ⟨⟨VVecEA2.trivialTrue, e.pin.neg, VVecEA2.trivialTrue⟩, by simp,
                VVecEA2.trivialTrue_holds M atomMap z0 r0, ?_,
                VVecEA2.trivialTrue_holds M atomMap r0 z1⟩
              rw [TemporalPred.eval_at_neg']
              exact hp

/-! ## Non-vacuity: the limit gate is load-bearing, not dead syntax -/

/-- **The Case 1 disjunct is indispensable, and this is machine-checked rather than argued.**

    Under `K⁺(¬β₁)(z₀)` — the limit gate the attained formulation cannot express — **neither** of
    the other two disjuncts of `negFixListFaithful s ((a,b) :: qs)` can hold:

    * the Case 2 disjunct asserts `β₁` at *every* interior point, and `K⁺(¬β₁)(z₀)` produces a
      `¬β₁`-point in `(z₀,z₁)`;
    * the Case 3 disjunct asserts a pin `r₀ ∈ (z₀,z₁)` with `β₁` on all of `(z₀,r₀)`, and
      `K⁺(¬β₁)(z₀)` produces a `¬β₁`-point in `(z₀,r₀)`.

    So on any structure where `K⁺(¬β₁)(z₀)` is satisfiable, dropping Case 1 would make
    `negFixListFaithful_iff` false: the bracket fails (by `witness_absurd_of_kplusLeft`) while the
    surviving disjuncts are unsatisfiable. This is the analogue, one level up, of
    `prior_makes_disjunct2_unreachable` (`Lemma53Faithful.lean`) and of Phase 6's `ℝ` probe: those
    two exhibit *where* the limit case is and is not reachable; this one shows *why it cannot be
    absorbed* by its neighbours.

    Carrier-free: no `HasDedekind*`/`HasAttained*` hypothesis appears. -/
theorem negFixListFaithful_case1_is_indispensable {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (s a b : TemporalPred) (qs : List (TemporalPred × TemporalPred))
    (z0 z1 : M.carrier) (h_lt : z0 < z1)
    (hk : kplus M atomMap s.neg.formula z0) :
    ¬ (((negBoundedLeftFixAnchoredFaithful a (bracketOf b qs)).conjEverywhere s).holds
        M atomMap z0 z1) ∧
    ¬ ((vecPinnedListToV
          (vecPinnedConjAll
            ([⟨VVecEA2.trivialTrue, a.neg, VVecEA2.trivialTrue⟩,
              ⟨VVecEA2.trivialTrue, TemporalPred.top,
                negFixListFaithful b qs⟩] ::
             (splitsAt b qs).attach.map fun ⟨e, _he⟩ =>
               [⟨negBoundedLeftFixAnchoredFaithful a (bracketOf e.leftSeg e.leftPairs),
                 TemporalPred.top, VVecEA2.trivialTrue⟩,
                ⟨VVecEA2.trivialTrue, e.pin.neg, VVecEA2.trivialTrue⟩,
                ⟨VVecEA2.trivialTrue, TemporalPred.top,
                 negFixListFaithful e.rightSeg e.rightPairs⟩]))
          s (infPinPoint s)).holds M atomMap z0 z1) := by
  constructor
  · intro h2
    obtain ⟨-, hsev⟩ := (VVecEA2.conjEverywhere_holds_iff M atomMap _ s z0 z1).mp h2
    exact witness_absurd_of_kplusLeft M atomMap s h_lt hk hsev
  · intro h3
    obtain ⟨r, hr0, -, hsev, -, -⟩ :=
      (vecPinnedListToV_holds_iff M atomMap _ s (infPinPoint s) z0 z1).mp h3
    exact witness_absurd_of_kplusLeft M atomMap s hr0 hk hsev

/-- The faithful recursion is available wherever the attained one is, and needs only the INF half:
    `HasAttainedINF.toHasDedekindINF` (`DedekindINF.lean:172`) supplies the carrier, and
    `HasAttainedSUP` is not required at all. The shim mirrors
    `negFixOneFaithful_iff_of_attained` (`NegFixOneFaithful.lean:498`). -/
theorem negFixListFaithful_iff_of_attained {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_INF : HasAttainedINF M atomMap)
    (ps : List (TemporalPred × TemporalPred)) (s : TemporalPred)
    (z0 z1 : M.carrier) (h_lt : z0 < z1) :
    (negFixListFaithful s ps).holds M atomMap z0 z1 ↔
    ¬ (bracketOf s ps).holds M atomMap z0 z1 :=
  negFixListFaithful_iff M atomMap h_INF.toHasDedekindINF ps.length ps s z0 z1
    (Nat.le_refl _) h_lt

end FormalSystem.Metalogic.WeakCanonical.Kamp
