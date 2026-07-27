/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness.Slots

/-! # Shared-Interior-Witness Joint Carrier — order-type index and gate

Module B of the `SharedWitness` tower. Cross-σ bit-compatibility, the endpoint/witness
literal families (`kvE2SepEpL`/`EpR`/`PtW`), the depth-2 gate `KvE2SepGate`, the
order-type disjunction index (`KvE2SepSpikeOrderType`, `kvE2SepArr'`) and the rank
`kvE2OrdRank` (Rabinovich Lemma 3.2(1), PDF p.3; §5 coincidence, PDF p.5). -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation
  (nfDepth0CharFormula nf_depth0_char_formula_correct
   formulaConjList formula_conjList_iff)

/-! ## Cross-σ bit-compatibility predicate

The original arrangement-blind filter (`kvE2SepSlotLe` below) admits ANY cross-σ interleaving
(`!(sub a = sub b)` ⇒ valid), which is arrangement-blind: it enumerates placements whose
per-interval segment content is INconsistent with a positive sub's fold-bit content (the
O4 CRUX defect, `SharedWitness` O4 block). Rabinovich 2014 Lemma 3.2(1) (PDF p.3) admits only
*consistent interval-decomposition refinements*: a foreign 1-type slot may sit in a region
relative to another positive σ only when σ's fold bit for that (region, 1-type) is TRUE.

The four definitions below encode that predicate. They are DELIBERATELY not yet wired into
`kvE2SepSlotLe`/`kvE2_sepValid`: switching the live filter breaks the identity-arrangement
`kvE2_sepSlotsL_valid`/`_valid` and hence `kvE2_sepBody_nonvacuous`, whose repair requires a
joint model-sorted arrangement (Phase 2 make-or-break — no single-σ `k1v_sorted_realization3`
analog exists for the joint slot list). The full switch + mechanical downstream repair is
captured, verified-compiling except those two lemmas, in
`handoffs/phase1-switch-and-repairs.patch`. These staged defs read arrangement fresh-slot
adjacency (slot INDICES) only, never a model-order `x1 < e_i` literal (LITMUS).

NOTE: the wiring narrative above is a historical record. `kvE2_sepValid`,
`kvE2_sepArrL`/`kvE2_sepArrR` and `kvE2_sepBody_nonvacuous` have since been REMOVED (see the
`-- REMOVED:` records below and in `Carrier.lean`); the live filter is the per-order-type
`kvE2SepDisjValid` over `kvE2SepArr'`. The four definitions below ARE live and are consumed
by that filter — only the "not yet wired into `kvE2_sepValid`" framing is superseded. -/

/-- Optional base 1-type carried by a slot: `some χ` for the six 1-type slots, `none`
    for the two fresh-witness E[Σ]-atom slots (`lX1`/`rX1`, which carry `charK`, no base χ). -/
def kvE2SepSlotChi {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    KvE2SepSlot sig → Option (NormalForm sig 0 1)
  | .lXU _ χ => some χ
  | .lX1 _ => none
  | .lUW _ χ => some χ
  | .lWT _ χ => some χ
  | .rXW _ χ => some χ
  | .rWX1 _ χ => some χ
  | .rX1 _ => none
  | .rX1T _ χ => some χ

/-- If the slot is a fresh-witness slot, the placement-generic zone pattern of its owner's
    BEFORE-fresh interior region — `x<v<x1` (`kvESub2ZXU`) for a left-interior σ's `lX1`,
    `w<v<x1` (`kvE2SepZWX1`) for a right-interior σ's `rX1`; `none` for 1-type slots. The
    zone is EXACTLY the one the owner's own before-fresh 1-type slots read their bits at
    (`kvE2SepSlotsLFor`/`RFor`), so a foreign slot placed there is admitted iff its 1-type
    is in σ's before-fresh segment. -/
def kvE2SepFreshZoneBefore {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    KvE2SepSlot sig → Option (ZoneSpec 4)
  | .lX1 _ => some kvESub2ZXU
  | .rX1 _ => some kvE2SepZWX1
  | _ => none

/-- Owner's AFTER-fresh interior region zone pattern — `x1<v<w` (`kvESub2ZUW`) for a
    left-interior σ's `lX1`, `x1<v<t` (`kvESub2ZWT`) for a right-interior σ's `rX1`;
    `none` for 1-type slots. -/
def kvE2SepFreshZoneAfter {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    KvE2SepSlot sig → Option (ZoneSpec 4)
  | .lX1 _ => some kvESub2ZUW
  | .rX1 _ => some kvESub2ZWT
  | _ => none

/-- Cross-σ bit-compatibility of the ordered pair `(a, b)` (`a` before `b` in the
    arrangement), for slots of DIFFERENT owners: (1) if `b` is `σ`'s fresh slot and `a`
    carries `χ`, then `a` lies in `σ`'s before-fresh region, admitted iff
    `kvE2SepBits σ (before-zone) χ = true`; (2) if `a` is `σ`'s fresh slot and `b` carries
    `χ`, then `b` lies in `σ`'s after-fresh region, admitted iff
    `kvE2SepBits σ (after-zone) χ = true`. Two 1-type slots or two fresh slots impose no
    cross constraint (their relative order does not place either inside the other's interval
    decomposition). Bool-valued / `decide`-friendly (`kvE2SepBits` is already `Bool`).
    Rabinovich 2014 Lemma 3.2(1) (PDF p.3). -/
def kvE2SepCompat {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (a b : KvE2SepSlot sig) : Bool :=
  (match kvE2SepFreshZoneBefore b, kvE2SepSlotChi a with
    | some zb, some χa => kvE2SepBits (kvE2SepSlotSub b) zb χa
    | _, _ => true)
  && (match kvE2SepFreshZoneAfter a, kvE2SepSlotChi b with
    | some za, some χb => kvE2SepBits (kvE2SepSlotSub a) za χb
    | _, _ => true)

/-- **Cross-σ discrimination witness** (proof form —
    stronger than the planned `#eval` sanity check, and abstract over any `sig`/`σ`/`χ`).
    A foreign 1-type slot `a` (carrying `χ`) placed BEFORE a left-interior σ's fresh slot
    `.lX1 σ` is admitted by the redefined compat filter iff σ's before-fresh
    (`kvESub2ZXU`, region `(x, x1)`) fold bit for `χ` is TRUE: the compat value equals
    that bit EXACTLY. Hence the filter REJECTS the arrangement-blind bad interleaving
    (`kvE2SepBits σ zXU χ = false` ⇒ `kvE2SepCompat a (.lX1 σ) = false`) and ADMITS the
    bit-true one — the cross-σ correctness the original arrangement-blind filter lacked
    (Rabinovich Lemma 3.2(1), PDF p.3; interval-decomposition + Feferman–Vaught composition
    PDF p.3, PDF pp.7-8). The mirror for `.rX1` (right-interior fresh, `kvE2SepZWX1`) and
    the after-fresh clause hold by the same reduction. NOTE (audit item 1a): a *fresh-less*
    sub's whole macro-side region (a right-interior σ on the LEFT list; a left-interior σ on
    the RIGHT list) is NOT keyed by this filter — its exclusion of foreign χ-points is owned
    by the refined-segment machinery `kvE2SepSegLForSub`/`kvE2SepSegRForSub` (uniform
    `kvESub2ZXU` / `kvESub2ZWT` segment forms), so the compat filter is CORRECTLY silent
    there; no third compat clause is needed. -/
theorem kvE2_sepCompat_lX1_eq {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) (a : KvE2SepSlot sig)
    (hχ : kvE2SepSlotChi a = some χ) :
    kvE2SepCompat a (.lX1 σ) = kvE2SepBits σ kvESub2ZXU χ := by
  unfold kvE2SepCompat
  cases a <;>
    simp_all [kvE2SepFreshZoneBefore, kvE2SepFreshZoneAfter, kvE2SepSlotChi,
      kvE2SepSlotSub]

/-- **After-fresh mirror** of `kvE2_sepCompat_lX1_eq`: a foreign 1-type slot `b` (carrying
    `χ`) placed AFTER a left-interior σ's fresh slot `.lX1 σ` is admitted iff σ's after-fresh
    (`kvESub2ZUW`, region `(x1, w)`) fold bit for `χ` is TRUE. Consumed by the joint
    sorted-realization proof (Phase 2) for the `p > x1_σ` branch. -/
theorem kvE2_sepCompat_lX1_after_eq {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) (b : KvE2SepSlot sig)
    (hχ : kvE2SepSlotChi b = some χ) :
    kvE2SepCompat (.lX1 σ) b = kvE2SepBits σ kvESub2ZUW χ := by
  unfold kvE2SepCompat
  cases b <;>
    simp_all [kvE2SepFreshZoneBefore, kvE2SepFreshZoneAfter, kvE2SepSlotChi,
      kvE2SepSlotSub]

/-- **Right-list before-fresh** mirror: a foreign 1-type slot `a` (carrying `χ`) placed
    BEFORE a right-interior σ's fresh slot `.rX1 σ` is admitted iff σ's before-fresh
    (`kvE2SepZWX1`, region `(w, x1)`) fold bit for `χ` is TRUE. -/
theorem kvE2_sepCompat_rX1_eq {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) (a : KvE2SepSlot sig)
    (hχ : kvE2SepSlotChi a = some χ) :
    kvE2SepCompat a (.rX1 σ) = kvE2SepBits σ kvE2SepZWX1 χ := by
  unfold kvE2SepCompat
  cases a <;>
    simp_all [kvE2SepFreshZoneBefore, kvE2SepFreshZoneAfter, kvE2SepSlotChi,
      kvE2SepSlotSub]

/-- **Right-list after-fresh** mirror: a foreign 1-type slot `b` (carrying `χ`) placed
    AFTER a right-interior σ's fresh slot `.rX1 σ` is admitted iff σ's after-fresh
    (`kvESub2ZWT`, region `(x1, t)`) fold bit for `χ` is TRUE. -/
theorem kvE2_sepCompat_rX1_after_eq {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) (b : KvE2SepSlot sig)
    (hχ : kvE2SepSlotChi b = some χ) :
    kvE2SepCompat (.rX1 σ) b = kvE2SepBits σ kvESub2ZWT χ := by
  unfold kvE2SepCompat
  cases b <;>
    simp_all [kvE2SepFreshZoneBefore, kvE2SepFreshZoneAfter, kvE2SepSlotChi,
      kvE2SepSlotSub]

/-- Arrangement validity relation, Bool-valued: slots of the SAME σ must appear in
    non-decreasing region rank; slots of different σ must be cross-σ bit-compatible
    (`kvE2SepCompat`) — the compat-aware redefinition of the original arrangement-blind
    filter (Rabinovich Lemma 3.2(1), PDF p.3). -/
def kvE2SepSlotLe {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (a b : KvE2SepSlot sig) : Bool :=
  if kvE2SepSlotSub a = kvE2SepSlotSub b then
    decide (kvE2SepSlotRank a ≤ kvE2SepSlotRank b)
  else
    kvE2SepCompat a b

-- REMOVED: the additive open-zone arrangement filter `kvE2_sepValid` and the
-- flat-union permutation-filter interleaving sets `kvE2_sepArrL`/`kvE2_sepArrR`. These enumerated
-- `(kvE2SepSlotsL/R qnf).permutations.filter kvE2_sepValid` — an additive open-bit filter over a
-- flat cross-owner slot union that is FALSE (empty) on the coincidence case (handoff 05). The
-- carrier now enumerates the order-type disjunction `kvE2SepArr'` (Lemma 3.2(1), PDF p.3), where
-- each disjunct reads the zone bit appropriate to its own arrangement.

/-! ## Joint endpoint predicates and the shared `ptW` slot -/

/-- Joint left endpoint predicate at the fixed `x`: `qnf.1`'s x-type head; σ-level
    `Since`/at-`x` `charK`-atom literals for the `zPastX3`/`zAtX3` outer classes (Prop
    3.5, PDF p.3 — navigation rides the `Since` evaluation point, LITMUS-clean); each
    interior σ's own x-type and exterior/boundary `charBase` literals
    (`SubBracket2V.lean:183-187` pattern). -/
noncomputable def kvE2SepEpL {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : TemporalPred :=
  ⟨formulaConjList
    (charBase (kvE2SepProj3 qnf.1 ⟨1, by omega⟩)
      :: ((Finset.univ.toList : List (NormalForm sig 1 1)).map fun χ =>
            kvE2SepLit (kvE2SepHasPos qnf kvE2SepZPastX3 χ)
              (Formula.snce (charK χ) Formula.top))
      ++ ((Finset.univ.toList : List (NormalForm sig 1 1)).map fun χ =>
            kvE2SepLit (kvE2SepHasPos qnf kvE2SepZAtX3 χ) (charK χ))
      ++ ((kvE2SepPosIn qnf kvE2SepZXW3 ++ kvE2SepPosIn qnf kvE2SepZWT3).flatMap
            fun σ =>
              charBase (kvE2SepProj4 σ ⟨2, by omega⟩)
                :: ((Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                      kvE2SepLit (kvE2SepBits σ kvE2SepZPastX4 χ)
                        (Formula.snce (charBase χ) Formula.top))
                ++ ((Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                      kvE2SepLit (kvE2SepBits σ kvE2SepZAtX4 χ) (charBase χ))))⟩

/-- Joint right endpoint predicate at the fixed `t` (mirror of `kvE2SepEpL`: at-`t` and
    `Until` σ-level literals for `zAtT3`/`zFutT3`; per interior σ its t-type and
    `zAtT4`/`zFutT4` literals, `SubBracket2V.lean:188-192` pattern). -/
noncomputable def kvE2SepEpR {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : TemporalPred :=
  ⟨formulaConjList
    (charBase (kvE2SepProj3 qnf.1 ⟨2, by omega⟩)
      :: ((Finset.univ.toList : List (NormalForm sig 1 1)).map fun χ =>
            kvE2SepLit (kvE2SepHasPos qnf kvE2SepZAtT3 χ) (charK χ))
      ++ ((Finset.univ.toList : List (NormalForm sig 1 1)).map fun χ =>
            kvE2SepLit (kvE2SepHasPos qnf kvE2SepZFutT3 χ)
              (Formula.untl (charK χ) Formula.top))
      ++ ((kvE2SepPosIn qnf kvE2SepZXW3 ++ kvE2SepPosIn qnf kvE2SepZWT3).flatMap
            fun σ =>
              charBase (kvE2SepProj4 σ ⟨3, by omega⟩)
                :: ((Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                      kvE2SepLit (kvE2SepBits σ kvE2SepZAtT4 χ) (charBase χ))
                ++ ((Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                      kvE2SepLit (kvE2SepBits σ kvE2SepZFutT4 χ)
                        (Formula.untl (charBase χ) Formula.top))))⟩

/-- The ONE shared interior-witness point type (the object the SubBracket2V banner names):
    `charBase` of `qnf.1`'s w-coordinate 1-type (arity-3 analog of the per-σ `ptW`,
    `SubBracket2V.lean:216-219`; Amendment F3 — a TYPE slot, never a `w = e 1` provider
    equation); the σ-level `zAtW3` `charK`-atom literals; and EVERY interior σ's own
    w-type plus `v = w` self-zone literals (`zAtWL` for the left class, `zAtWR` mirrored). -/
noncomputable def kvE2SepPtW {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) : TemporalPred :=
  ⟨formulaConjList
    (charBase (kvE2SepProj3 qnf.1 ⟨0, by omega⟩)
      :: ((Finset.univ.toList : List (NormalForm sig 1 1)).map fun χ =>
            kvE2SepLit (kvE2SepHasPos qnf kvE2SepZAtW3 χ) (charK χ))
      ++ ((kvE2SepPosIn qnf kvE2SepZXW3).flatMap fun σ =>
            charBase (kvE2SepProj4 σ ⟨1, by omega⟩)
              :: (Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                  kvE2SepLit (kvE2SepBits σ kvE2SepZAtWL χ) (charBase χ))
      ++ ((kvE2SepPosIn qnf kvE2SepZWT3).flatMap fun σ =>
            charBase (kvE2SepProj4 σ ⟨1, by omega⟩)
              :: (Finset.univ.toList : List (NormalForm sig 0 1)).map fun χ =>
                  kvE2SepLit (kvE2SepBits σ kvE2SepZAtWR χ) (charBase χ)))⟩

/-! ## Refined segment types (Cor 5.4, PDF p.5)

Each refined sub-interval of a joint arrangement carries EVERY interior σ's exclusion
content there. Which of σ's regions a LEFT sub-interval at cut `i` lies in is keyed by
whether σ's fresh-witness slot occurs among the first `i` slots of the arrangement —
a structural read of the arrangement, never an `x1 < e_i` literal (LITMUS). -/

/-- σ's exclusion contribution to the left-region refined sub-interval at cut `i` of
    arrangement `lL`. Left-interior σ: `(x,x1)` exclusion before its fresh slot, `(x1,w)`
    after. Right-interior σ: uniform `(x,w)` exclusion. Non-interior σ: no segment
    contribution (its content rides its `charK` E[Σ]-atom endpoint literal). -/
noncomputable def kvE2SepSegLForSub {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (lL : List (KvE2SepSlot sig)) (i : Nat) (σ : NormalForm sig 1 4) : Formula :=
  if nf0ZoneSpec σ.1 = kvE2SepZXW3 then
    (if (lL.take i).contains (.lX1 σ) then kvE2SepSegForm charBase σ kvESub2ZUW
     else kvE2SepSegForm charBase σ kvESub2ZXU)
  else if nf0ZoneSpec σ.1 = kvE2SepZWT3 then
    kvE2SepSegForm charBase σ kvESub2ZXU
  else Formula.top

/-- σ's exclusion contribution to the right-region refined sub-interval at cut `j` of
    arrangement `lR` (mirror: left-interior σ uniform `(w,t)`; right-interior σ `(w,x1)`
    before its fresh slot, `(x1,t)` after). -/
noncomputable def kvE2SepSegRForSub {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula)
    (lR : List (KvE2SepSlot sig)) (j : Nat) (σ : NormalForm sig 1 4) : Formula :=
  if nf0ZoneSpec σ.1 = kvE2SepZXW3 then
    kvE2SepSegForm charBase σ kvESub2ZWT
  else if nf0ZoneSpec σ.1 = kvE2SepZWT3 then
    (if (lR.take j).contains (.rX1 σ) then kvE2SepSegForm charBase σ kvESub2ZWT
     else kvE2SepSegForm charBase σ kvE2SepZWX1)
  else Formula.top

/-- Refined-conjunction segment type for the left region at cut `i`.
    Deliberate: stays mapping over `kvE2SepPos`, NOT `kvE2SepPosI` —
    semantically equivalent since non-interior owners contribute `⊤` conjuncts (the
    `else Formula.top` branches), but the anchors differ SYNTACTICALLY at the formula
    level, so re-anchoring would perturb formula-shape equalities for no semantic gain;
    report 07 sanctions either anchor and the conservative diff is smaller. -/
noncomputable def kvE2SepSegLAt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (lL : List (KvE2SepSlot sig)) (i : Nat) : TemporalPred :=
  ⟨formulaConjList ((kvE2SepPos qnf).map (kvE2SepSegLForSub charBase lL i))⟩

/-- Refined-conjunction segment type for the right region at cut `j`. Stays over
    `kvE2SepPos` (see `kvE2SepSegLAt` — deliberate choice). -/
noncomputable def kvE2SepSegRAt {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (lR : List (KvE2SepSlot sig)) (j : Nat) : TemporalPred :=
  ⟨formulaConjList ((kvE2SepPos qnf).map (kvE2SepSegRForSub charBase lR j))⟩

/-- Segment index dispatcher for the joint bracket: indices `≤ lL.length` are left-region
    cuts, the rest are right-region cuts (same boundary convention as `bracketFromLists`,
    `CarrierK1V.lean:389`). -/
noncomputable def kvE2SepSegs {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (lL lR : List (KvE2SepSlot sig)) (i : Nat) : TemporalPred :=
  if i ≤ lL.length then kvE2SepSegLAt charBase qnf lL i
  else kvE2SepSegRAt charBase qnf lR (i - lL.length - 1)

/-- **Fresh N-slot bracket builder** (plan Phase 7 O1): the `bracketFromLists`
    (`CarrierK1V.lean:389`) shape generalized to PER-INDEX segment types — required because
    the refined-conjunction segments vary across each region's cuts (the private 2-slot
    `bracketFromLists3` cannot express this). Point types are `lL ++ ptW :: lR` — the §5
    bracket `[α_0, …, α_n](z_0, z_1)` (PDF p.7) with the two FIXED endpoints and one shared
    interior witness slot at position `lL.length`. -/
def kvE2SepBracketN (lL : List TemporalPred) (ptW : TemporalPred)
    (lR : List TemporalPred) (segs : Nat → TemporalPred) :
    BracketFormula (lL.length + 1 + lR.length) where
  pointTypes := fun i =>
    (lL ++ ptW :: lR)[i.val]'(by
      simp only [List.length_append, List.length_cons]; omega)
  segmentTypes := fun i => segs i.val

/-- **Joint disjunct builder** (TOP-LEVEL per the crux failed-closer-3 lesson): one flat
    `VecEA2` per pair of left/right interleavings, with the joint endpoint predicates, the
    shared `ptW` slot, and the refined-conjunction segments. -/
noncomputable def kvE2SepDisjunct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (lL lR : List (KvE2SepSlot sig)) : Σ n, VecEA2 n :=
  ⟨(lL.map (kvE2SepSlotType charBase charK)).length + 1
      + (lR.map (kvE2SepSlotType charBase charK)).length,
   { endpointLeft := kvE2SepEpL charBase charK qnf
     endpointRight := kvE2SepEpR charBase charK qnf
     bracket := kvE2SepBracketN
       (lL.map (kvE2SepSlotType charBase charK))
       (kvE2SepPtW charBase charK qnf)
       (lR.map (kvE2SepSlotType charBase charK))
       (kvE2SepSegs charBase qnf lL lR) }⟩

/-! ## The depth-2 gate -/

/-- The seven consistent OUTER zones under the bracket order `x < w < t` (Def 3.1,
    PDF pp.2-3), including the shared-witness self-zone `zAtW3` (nine-zone lesson one level
    up: `SubBracket2V.lean:160-166`). -/
def KvE2SepOuterConsistent (zs : ZoneSpec 3) : Prop :=
  zs = kvE2SepZPastX3 ∨ zs = kvE2SepZAtX3 ∨ zs = kvE2SepZXW3 ∨
    zs = kvE2SepZAtW3 ∨ zs = kvE2SepZWT3 ∨ zs = kvE2SepZAtT3 ∨ zs = kvE2SepZFutT3

/-- The nine consistent INNER zones for a LEFT-interior σ (`x < x1 < w < t`) — the
    VERBATIM pattern set of `kvE_subBracket2V_gate_holds_of_honest`'s conclusion
    (`SubBracket2V.lean:1400-1408`), including both witness self-zones `zAtX1`/`zAtW`,
    so the honest discharge consumes that landed lemma directly. -/
def KvE2SepInnerConsistentL (zs : ZoneSpec 4) : Prop :=
  zs = Fin.cons (true, false) (Fin.cons (true, false)
      (Fin.cons (true, false) (fun _ => (true, false)))) ∨
  zs = Fin.cons (true, false) (Fin.cons (true, false)
      (Fin.cons (false, false) (fun _ => (true, false)))) ∨
  zs = Fin.cons (true, false) (Fin.cons (true, false)
      (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, false) (Fin.cons (true, false)
      (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (true, false)
      (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, false)
      (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true)
      (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true)
      (Fin.cons (false, true) (fun _ => (false, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true)
      (Fin.cons (false, true) (fun _ => (false, true))))

/-- The nine consistent INNER zones for a RIGHT-interior σ (`x < w < x1 < t`) — the mirror of
    `KvE2SepInnerConsistentL` with the pin `x1` above the shared witness `w`. Patterns 1-3 and
    7-9 (exterior/boundary and above-pin) coincide with the LEFT set; only the middle three swap
    (`zAtWR`/`zWX1`/`zAtX1R` replace `zAtX1L`/`zUW`/`zAtWL`). Used as the `hInnerR` classification
    target under R2. -/
def KvE2SepInnerConsistentR (zs : ZoneSpec 4) : Prop :=
  zs = Fin.cons (true, false) (Fin.cons (true, false)
      (Fin.cons (true, false) (fun _ => (true, false)))) ∨
  zs = Fin.cons (true, false) (Fin.cons (true, false)
      (Fin.cons (false, false) (fun _ => (true, false)))) ∨
  zs = Fin.cons (true, false) (Fin.cons (true, false)
      (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (true, false) (Fin.cons (false, false)
      (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (true, false) (Fin.cons (false, true)
      (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, false) (Fin.cons (false, true)
      (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true)
      (Fin.cons (false, true) (fun _ => (true, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true)
      (Fin.cons (false, true) (fun _ => (false, false)))) ∨
  zs = Fin.cons (false, true) (Fin.cons (false, true)
      (Fin.cons (false, true) (fun _ => (false, true))))

/-- **Depth-2 joint gate** (arity-3 lift of the per-σ gate `SubBracket2V.lean:232-234`):
    (i) OUTER off-fiber falsity — a sub whose atom-layer restriction to `[w,x,t]`
    disagrees with `qnf.1` is negative; (ii) OUTER seven-zone consistency — a positive
    sub's fresh witness sits in a consistent placement; (iii) INNER off-fiber falsity for
    every positive sub (its own depth-1 quant layer is on-fiber); (iv) INNER nine-zone
    consistency for LEFT-interior positives (the class the landed per-σ kit serves; the
    exact syntactic clause the O4 `hgate` derivation needs, `SubBracket2V.lean:1872-1877`). -/
def KvE2SepGate {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : Prop :=
  (∀ σ : NormalForm sig 1 4, nf0DropFresh σ.1 ≠ qnf.1 → qnf.2 σ = false) ∧
  (∀ σ : NormalForm sig 1 4, ¬ KvE2SepOuterConsistent (nf0ZoneSpec σ.1) →
    qnf.2 σ = false) ∧
  (∀ σ : NormalForm sig 1 4, qnf.2 σ = true →
    ∀ τ : NormalForm sig 0 5, nf0DropFresh τ ≠ σ.1 → σ.2 τ = false) ∧
  (∀ σ : NormalForm sig 1 4, qnf.2 σ = true → nf0ZoneSpec σ.1 = kvE2SepZXW3 →
    ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), ¬ KvE2SepInnerConsistentL zs →
      σ.2 (nf0Assemble zs χ σ.1) = false) ∧
  (∀ σ : NormalForm sig 1 4, qnf.2 σ = true → nf0ZoneSpec σ.1 = kvE2SepZWT3 →
    ∀ (zs : ZoneSpec 4) (χ : NormalForm sig 0 1), ¬ KvE2SepInnerConsistentR zs →
      σ.2 (nf0Assemble zs χ σ.1) = false)

/-! ## Order-type-disjunction index (RELOCATED above the carrier)

The order-type-disjunction index and per-disjunct validity predicate (built in Phases 1-2 and
originally sited below the carrier) are relocated here so `kvE2SepBody` can be rewired to
enumerate `kvE2SepArr'` (Phase 6). Verbatim; only the file position changed. The Phase-1 spike
THEOREMS and the Phase-4/5 three-way cuts remain below (they consume the coincidence brick and are
not needed to DEFINE the carrier). See the Phase-1/2 banners further down for the paper grounding
(Lemma 3.2(1), PDF p.3; §5 coincidence, PDF p.6). -/

/-- Order-type index for the 2-owner spike: the relative placement of the foreign owner τ's
    χ-witness against σ's fresh anchor `x1_σ` on the merged anchor set `{x1_σ, x1_τ, w}`. Ties are a
    first-class order-type (Lemma 3.2(1), PDF p.3; §5 coincidence, PDF p.6). -/
inductive KvE2SepSpikeOrderType where
  /-- τ's χ-witness STRICTLY BELOW `x1_σ` (`x < x1_τ < x1_σ`): reads σ's OPEN `zXU` bit. -/
  | strictBefore
  /-- τ's χ-witness STRICTLY ABOVE `x1_σ` (`x1_σ < x1_τ < w`): reads σ's OPEN `zUW` bit. -/
  | strictAfter
  /-- τ's χ-witness COINCIDENT at `x1_σ` (`x1_τ = x1_σ`): reads σ's CLOSED `zAtX1L` bit. -/
  | coincident
deriving DecidableEq

/-- The 2-owner order-type disjunction list (Lemma 3.2(1) disjuncts over the merged anchor set,
    PDF p.3): the coincidence order-type is a first-class disjunct. -/
def kvE2SepSpikeOrderTypes : List KvE2SepSpikeOrderType :=
  [.strictBefore, .strictAfter, .coincident]

/-- A k-owner weak order on the merged anchor set `A`: one entry per positive owner carrying BOTH
    its placement tag (relative to `w`, driving the F5 zone-bit read) AND its cross-owner **rank** —
    the position of the owner's fresh anchor in the merged ascending chain `{x1_σ, x1_τ, …}`
    (Lemma 3.2(1), PDF p.3: one global order over the union of both owners' points). Two owners whose
    anchors interleave differently (`x1_σ < x1_τ` vs `x1_τ < x1_σ`) receive DISTINCT rank tuples, so
    they are now DISTINGUISHABLE — the cross-owner data the grouped `.holds` builder consumes. The
    placement tag stays the 3-value per-owner type (F5: strict→OPEN, coincident→CLOSED); the ℕ rank
    is the orthogonal merged-chain position. -/
abbrev KvE2SepWeakOrder (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] :=
  List (NormalForm sig 1 4 × KvE2SepSpikeOrderType × List ℕ)

/-- The order-type tag list is exhaustive: every tag is a member. -/
theorem kvE2_sepSpikeOrderTypes_complete (tag : KvE2SepSpikeOrderType) :
    tag ∈ kvE2SepSpikeOrderTypes := by
  cases tag <;> decide

/-- **Cross-owner distinguishability witness** (the defining property this task installs). Two
    owners `σ, τ` interleaving as `x1_σ < x1_τ` (ranks `0 < 1`) versus `x1_τ < x1_σ` (ranks `1 < 0`)
    yield DISTINCT enriched weak orders. Under the previous carrier `List (NormalForm sig 1 4 ×
    KvE2SepSpikeOrderType)` both collapse to the SAME value `[(σ, c), (τ, c)]` — the exact
    under-specification that blocked the grouped-builder work. The added ℕ rank makes them
    unequal, giving the grouped `.holds` builder the cross-owner data to consume. -/
example {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ τ : NormalForm sig 1 4) :
    ([(σ, KvE2SepSpikeOrderType.coincident, [0, 1, 2]),
      (τ, KvE2SepSpikeOrderType.coincident, [3, 4, 5])]
        : KvE2SepWeakOrder sig)
      ≠ [(σ, KvE2SepSpikeOrderType.coincident, [3, 4, 5]),
         (τ, KvE2SepSpikeOrderType.coincident, [0, 1, 2])] := by
  simp

/-- **Per-slot global-index tuple**: for an owner at merged-chain position `k` in an
    `n`-owner arrangement, the region-primary placeholder index tuple `(k, n+k, 2n+k)` — the global
    indices of its region-rank-0/1/2 slots. Behavior-preserving: `giOf = regionRank·n + k`
    reproduces 339's region-primary/owner-secondary order EXACTLY (Phase 2). Consistency
    `i₀<i₁<i₂` holds (`k < n+k < 2n+k`). Phase 5 replaces this with the honest model value order. -/
def kvE2SepPlaceholderTuple (n k : ℕ) : List ℕ := [k, n + k, 2 * n + k]

/-- **Finite tuple index range**: all `(ℕ × ℕ × ℕ)` global-index tuples with each
    component `< 3n`. Finite, `DecidableEq`, `decide`-able; contains every `kvE2SepPlaceholderTuple
    n k` for `k < n` and every order-consistent interleaving over `n` owners' ≤3 region ranks. This
    is the per-slot index the enumeration ranges over, replacing the single `List.range n` rank. -/
def kvE2SepIdxTuples (n : ℕ) : List (List ℕ) :=
  (List.range (3 * n)).flatMap (fun a =>
    (List.range (3 * n)).flatMap (fun b =>
      (List.range (3 * n)).map (fun c => [a, b, c])))

/-- The placeholder tuple for position `k < n` is in the tuple index range. -/
theorem kvE2_sepPlaceholderTuple_mem (n k : ℕ) (hk : k < n) :
    kvE2SepPlaceholderTuple n k ∈ kvE2SepIdxTuples n := by
  rw [kvE2SepIdxTuples, kvE2SepPlaceholderTuple, List.mem_flatMap]
  refine ⟨k, List.mem_range.mpr (by omega), ?_⟩
  rw [List.mem_flatMap]
  refine ⟨n + k, List.mem_range.mpr (by omega), ?_⟩
  rw [List.mem_map]
  exact ⟨2 * n + k, List.mem_range.mpr (by omega), rfl⟩

/-- **Enumeration richness**: every order-consistent global-index tuple whose
    three components each lie in `[0, 3n)` is enumerated by `kvE2SepIdxTuples n`. This is the
    strict generalization of `kvE2_sepPlaceholderTuple_mem` from the region-primary
    placeholder shape `(k, n+k, 2n+k)` to an ARBITRARY in-range tuple `(a, b, c)` — the membership
    fact the model-value-faithful honest order (`kvE2SepHonestOrder`) needs: an owner's three
    slots' actual global positions in M's value order are all `< 3n` (there are `3n` slots total),
    so the honest tuple is a member by exactly the same three `List.mem_flatMap`/`List.mem_range`
    steps. Reads no zone bit; abstract-ℕ only (F4/LITMUS clean). -/
theorem kvE2_sepIdxTuple_mem_of_lt (n a b c : ℕ)
    (ha : a < 3 * n) (hb : b < 3 * n) (hc : c < 3 * n) :
    [a, b, c] ∈ kvE2SepIdxTuples n := by
  rw [kvE2SepIdxTuples, List.mem_flatMap]
  refine ⟨a, List.mem_range.mpr ha, ?_⟩
  rw [List.mem_flatMap]
  refine ⟨b, List.mem_range.mpr hb, ?_⟩
  rw [List.mem_map]
  exact ⟨c, List.mem_range.mpr hc, rfl⟩

/-- **Variable-length `N`-bound index enumeration**: every list of length `L`
    whose entries all lie in `[0, n)`. Generalizes the fixed length-3 `kvE2SepIdxTuples` to the
    per-owner block length `L = (kvE2SepSlotBlock σ).length`, the arity the per-INDIVIDUAL-slot
    refinement requires (a region provably holds ≥2 base slots, so a fixed 3-tuple is unfaithful —
    postmortem constraint). Finite, terminating, `decide`-able; the `N`-bound replaces the WRONG
    `3*n` bound (report 08). Reads no zone bit; abstract-ℕ only (F4/F5/LITMUS clean). -/
def kvE2SepIdxTuplesN (n : ℕ) : ℕ → List (List ℕ)
  | 0 => [[]]
  | L + 1 =>
    (List.range n).flatMap (fun a => (kvE2SepIdxTuplesN n L).map (fun t => a :: t))

/-- **Enumeration richness at the `N` bound**: every list whose entries all lie in
    `[0, n)` is enumerated by `kvE2SepIdxTuplesN n` at its own length. The variable-length strict
    generalization of `kvE2_sepIdxTuple_mem_of_lt` — the membership fact the per-slot honest order
    (whose per-owner payload is `(kvE2SepSlotBlock σ).length`-long with every entry `< N`) needs to
    be a member of the enumeration. Same `List.mem_flatMap`/`List.mem_range`/`List.mem_map`
    technique,
    now by induction on the list. Reads no zone bit; abstract-ℕ only (F4/LITMUS clean). -/
theorem kvE2_sepIdxTupleN_mem_of_forall_lt (n : ℕ) :
    ∀ (l : List ℕ), (∀ x ∈ l, x < n) → l ∈ kvE2SepIdxTuplesN n l.length := by
  intro l
  induction l with
  | nil => intro _; simp [kvE2SepIdxTuplesN]
  | cons a t ih =>
    intro h
    rw [List.length_cons, kvE2SepIdxTuplesN, List.mem_flatMap]
    refine ⟨a, List.mem_range.mpr (h a List.mem_cons_self), ?_⟩
    rw [List.mem_map]
    exact ⟨t, ih (fun x hx => h x (List.mem_cons_of_mem _ hx)), rfl⟩

/-! ### Abstract lex-rank kernel (model-agnostic sort spec)

The honest-order construction (steps 2/4/5 of the Phase-5 map) reduces every one of its obligations
— the in-range bound `i < 3n`, the per-owner consistency `i₀<i₁<i₂`, the cross-owner `Nodup`, and
the cross-region `a<u'<b` monotonicity — to ONE spec: the rank of an element in a finite family
under a STRICT total order is `< n`, strictly monotone, and injective. The construction takes the
strict order to be the LEX product `(model value, slot index)`, so that ties in the model value are
broken by the (always distinct) slot index. This is exactly what the distinctness crux
forces: distinct owners may share witness values, so value alone is NOT a strict order; the index
tiebreak makes it one WITHOUT any (unprovable) value-distinctness hypothesis. Pure `Finset.card`
combinatorics; reads no model data; abstract over any `LinearOrder` (F4/LITMUS clean). -/

/-- **Rank of `i` under a strict family**: the number of indices whose `g`-value
    is strictly smaller. When `g` is injective this is the 0-based position of `i` in the ascending
    sort of `g` — a bijection `Fin n → Fin n`'s underlying position map. The honest order uses
    `g = (model value, slot index)` in the lex order. -/
def kvE2OrdRank {β : Type*} [LinearOrder β] {n : ℕ} (g : Fin n → β) (i : Fin n) : ℕ :=
  (Finset.univ.filter (fun j => g j < g i)).card

/-- Every rank is `< n` (it counts a subset of the `n-1` indices other than `i`). Gives the
    `< 3n` enumeration-membership bound the honest tuple feeds to `kvE2_sepIdxTuple_mem_of_lt`. -/
theorem kvE2_ordRank_lt {β : Type*} [LinearOrder β] {n : ℕ} (g : Fin n → β) (i : Fin n) :
    kvE2OrdRank g i < n := by
  have hsub : Finset.univ.filter (fun j => g j < g i) ⊆ Finset.univ.erase i := by
    intro j hj
    rw [Finset.mem_filter] at hj
    rw [Finset.mem_erase]
    refine ⟨?_, Finset.mem_univ j⟩
    rintro rfl
    exact lt_irrefl _ hj.2
  have hn : 0 < n := i.pos
  calc kvE2OrdRank g i ≤ (Finset.univ.erase i).card := Finset.card_le_card hsub
    _ = n - 1 := by
        rw [Finset.card_erase_of_mem (Finset.mem_univ i), Finset.card_univ, Fintype.card_fin]
    _ < n := by omega

/-- **Strict monotonicity**: a strictly smaller `g`-value has a strictly smaller
    rank. Supplies BOTH the per-owner consistency `i₀<i₁<i₂` (from the bundle chain
    `val₀<val₁<val₂`)
    AND the cross-region `a<u'<b` monotonicity (from `val(σ,2) < val(τ,1)`). Needs only the single
    strict inequality — no value-distinctness. -/
theorem kvE2_ordRank_strictMono {β : Type*} [LinearOrder β] {n : ℕ} (g : Fin n → β) {a b : Fin n}
    (hab : g a < g b) : kvE2OrdRank g a < kvE2OrdRank g b := by
  have hsub : Finset.univ.filter (fun j => g j < g a) ⊆ Finset.univ.filter
      (fun j => g j < g b) := by
    intro j hj
    rw [Finset.mem_filter] at hj ⊢
    exact ⟨hj.1, lt_trans hj.2 hab⟩
  apply Finset.card_lt_card
  rw [Finset.ssubset_iff_of_subset hsub]
  refine ⟨a, Finset.mem_filter.mpr ⟨Finset.mem_univ a, hab⟩, ?_⟩
  rw [Finset.mem_filter]
  push Not
  intro _
  exact le_refl _

/-- **Injectivity**: an injective family has an injective rank — the ranks are
    `n` distinct values in `[0,n)`, hence a permutation of `Fin n`. Supplies the cross-owner `Nodup`
    conjunct of `kvE2SepDisjValid` (the honest `g = (value, index)` is injective in its index
    component, so distinct slots get distinct ranks even when model values coincide). -/
theorem kvE2_ordRank_injective {β : Type*} [LinearOrder β] {n : ℕ} (g : Fin n → β)
    (hg : Function.Injective g) : Function.Injective (kvE2OrdRank g) := by
  intro a b hrank
  by_contra hne
  rcases lt_trichotomy (g a) (g b) with h | h | h
  · exact absurd hrank (Nat.ne_of_lt (kvE2_ordRank_strictMono g h))
  · exact hne (hg h)
  · exact absurd hrank.symm (Nat.ne_of_lt (kvE2_ordRank_strictMono g h))

/-- **General order-type-disjunction index** (Lemma 3.2(1), PDF p.3): the finite `List` of weak
    orders on `A` — all per-owner (placement tag × per-slot global-index tuple) assignments, built
    as
    the cartesian `foldr` product over the INTERIOR owner index `kvE2SepPosI qnf`
    (re-anchoring: the interleaving index ranges over bracket witnesses only — the §5
    (p.7) ψ0/ψ1/φ split makes interiority a construction invariant of φ; Lemma 3.2(1) states
    the closure without printed proof), with the tuple component ranging over
    `kvE2SepIdxTuples n` (`n = |allSlots|`). Finite, terminating, `decide`-able. Enumerating
    index tuples alongside tags is what makes two differently-interleaving models yield DISTINCT
    weak orders; the order-CONSISTENCY of the tuple (per-owner `i₀<i₁<i₂` and cross-owner `Nodup`)
    is the cross-owner conjunct of `kvE2SepDisjValid`. Replaces the abandoned `kvE2_sepArrL/R`
    carrier. -/
noncomputable def kvE2SepOrderTypes {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : List (KvE2SepWeakOrder sig) :=
  let n := (kvE2SepAllSlots qnf).length
  (kvE2SepPosI qnf).foldr
    (fun σ acc =>
      kvE2SepSpikeOrderTypes.flatMap (fun tag =>
        (kvE2SepIdxTuplesN n (kvE2SepSlotBlock σ).length).flatMap
          (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
    [[]]

/-- σ's canonical (model) placement tag, read from its realized outer zone class. -/
noncomputable def kvE2SepModelTag {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : KvE2SepSpikeOrderType :=
  if nf0ZoneSpec σ.1 = kvE2SepZXW3 then .strictBefore else .strictAfter

/-- The model weak order: each INTERIOR positive owner (the enumeration
    ranges over the interior index `kvE2SepPosI`, matching `kvE2SepOrderTypes`) tagged with its
    canonical zone-class placement AND its rank = its index in `kvE2SepPosI` (via `zipIdx`, so
    the ranks are `0,1,…,n-1` — distinct, hence order-consistent). The strict per-owner tags
    remain honestly-undischargeable (the genuine Rabinovich `r_0=z_0` asymmetry),
    so this stays a conditional disjunct. -/
noncomputable def kvE2SepModelOrder {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : KvE2SepWeakOrder sig :=
  (kvE2SepPosI qnf).zipIdx.map
    (fun p => (p.1, kvE2SepModelTag p.1, (kvE2SepSlotBlock p.1).map (kvE2SepSlotIndexOf qnf)))

/-- The two interior outer classes are distinct (index-0 order bits differ). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (D,F,G,J).
theorem kvE2_sep_zWT3_ne_zXW3 : kvE2SepZWT3 ≠ kvE2SepZXW3 := by
  intro h
  have h0 := congrFun h (0 : Fin 3)
  simp only [kvE2SepZWT3, kvE2SepZXW3, Fin.cons_zero, Prod.mk.injEq] at h0
  exact Bool.false_ne_true h0.1

/-- **Closed-zone leaf — placement-generic forward read**. At a coincidence tie the
    disjunct is validated by σ's CLOSED self-zone bit at its own fresh type (§5 meet channel,
    PDF p.6), fed by the preserved axiom-clean coincidence discharges. The self-zone key is
    placement-appropriate: LEFT-interior owners (`nf0ZoneSpec σ.1 = kvE2SepZXW3`, `x < x1 < w`)
    read the CLOSED `zAtX1L` bit (`kvE2_sepCoincidentAnchor_discharge`); every other placement
    (in particular RIGHT-interior owners, `nf0ZoneSpec σ.1 = kvE2SepZWT3`, `w < x1 < t`) reads
    the CLOSED `zAtX1R` bit (`kvE2_sepCoincidentAnchor_discharge_R`). Both branches read CLOSED
    self-zone keys — never an OPEN key (F5). -/
def kvE2SepClosedLeafStub {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : Bool :=
  if nf0ZoneSpec σ.1 = kvE2SepZXW3 then
    kvE2SepBits σ kvE2SepZAtX1L (nf0ProjFresh σ.1)
  else
    kvE2SepBits σ kvE2SepZAtX1R (nf0ProjFresh σ.1)

/-! ### Tie-admitting validity infrastructure

The tie-collapse mechanism is forced by Def 3.1 (p.4: a single STRICT witness chain with free
variables pinned `z_k = x_{i_k}` and conjunction semantics); Lemma 3.2(1) states the closure
without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). Tie classes are
INDEX-LEVEL DATA ONLY: they live in the weak order's payload tuples, and every emitted disjunct
remains a strict Def-3.1 bracket — one slot per tie class with a conjoined point type
(strict-quotient guard; the grouped builder is `kvE2SepDisjunct'` below). Admissible tie classes
are
base-base and base-foreign-anchor within a region. Anchor-anchor ties are EXCLUDED by the
anchor-distinct conjunct below — a Lean-side, machine-checked pruning justified by the
keystone `nf_eval_unique` route (distinct positive owners provably cannot share a fresh
anchor, so anchor-anchor tie order types are honestly unrealizable); this pruning has NO
Rabinovich counterpart (audit note D7). -/

/-- **Closed-zone leaf at a FOREIGN base type**: the foreign-type
    generalization of `kvE2SepClosedLeafStub` — the anchor owner σ's CLOSED self-zone bit read
    at an arbitrary base type `χ` (its own fresh type is the `nf0ProjFresh σ.1` instance,
    `kvE2_sepClosedLeafStub_eq_at`). LEFT-interior owners read the CLOSED `zAtX1L` bit; every
    other placement reads the CLOSED `zAtX1R` bit. F5: this is a CLOSED self-zone key read at
    the foreign base type — no OPEN key enters any coincident read. This is the validity read a
    base-anchor tie class imposes (the honest discharge at the foreign type is
    `kvE2_sepClosedLeafAt_discharge_honest`). -/
def kvE2SepClosedLeafAt {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : Bool :=
  if nf0ZoneSpec σ.1 = kvE2SepZXW3 then
    kvE2SepBits σ kvE2SepZAtX1L χ
  else
    kvE2SepBits σ kvE2SepZAtX1R χ

/-- The forward stub is the own-fresh-type instance of the foreign-type leaf read. -/
theorem kvE2_sepClosedLeafStub_eq_at {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4) :
    kvE2SepClosedLeafStub σ = kvE2SepClosedLeafAt σ (nf0ProjFresh σ.1) := rfl

/-- A slot is a fresh-witness ANCHOR slot (`lX1`/`rX1`) — the slot kinds whose payload index
    participates in the anchor-distinct conjunct. -/
def kvE2SepSlotIsAnchor {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    KvE2SepSlot sig → Bool
  | .lX1 _ => true
  | .rX1 _ => true
  | _ => false

/-- The base type carried by a 1-type (base) slot; `none` for the anchor slots. -/
def kvE2SepSlotBaseType {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] :
    KvE2SepSlot sig → Option (NormalForm sig 0 1)
  | .lXU _ χ => some χ
  | .lX1 _ => none
  | .lUW _ χ => some χ
  | .lWT _ χ => some χ
  | .rXW _ χ => some χ
  | .rWX1 _ χ => some χ
  | .rX1 _ => none
  | .rX1T _ χ => some χ

/-- Anchor slots carry no base type. -/
theorem kvE2_sepSlotBaseType_eq_none_of_isAnchor {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {s : KvE2SepSlot sig} (h : kvE2SepSlotIsAnchor s = true) :
    kvE2SepSlotBaseType s = none := by
  cases s <;> simp_all [kvE2SepSlotIsAnchor, kvE2SepSlotBaseType]

/-- σ's fresh-anchor slot, by placement: `.lX1 σ` for a LEFT-interior owner, `.rX1 σ`
    otherwise. -/
def kvE2SepAnchorSlot {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : KvE2SepSlot sig :=
  if nf0ZoneSpec σ.1 = kvE2SepZXW3 then .lX1 σ else .rX1 σ

/-- The anchor slot is owned by σ. -/
theorem kvE2_sepSlotSub_anchorSlot {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (σ : NormalForm sig 1 4) :
    kvE2SepSlotSub (kvE2SepAnchorSlot σ) = σ := by
  rw [kvE2SepAnchorSlot]; split <;> rfl

/-- The anchor-slot family is injective (the slot constructor carries its owner). -/
theorem kvE2_sepAnchorSlot_injective {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    {σ τ : NormalForm sig 1 4} (h : kvE2SepAnchorSlot σ = kvE2SepAnchorSlot τ) : σ = τ := by
  have := congrArg kvE2SepSlotSub h
  rwa [kvE2_sepSlotSub_anchorSlot, kvE2_sepSlotSub_anchorSlot] at this

/-- An INTERIOR owner's anchor slot is a member of its slot block (the `.lX1`/`.rX1` entry of
    `kvE2SepSlotsLFor`/`kvE2SepSlotsRFor`). -/
theorem kvE2_sepAnchorSlot_mem_block {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] {σ : NormalForm sig 1 4}
    (hzone : nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) :
    kvE2SepAnchorSlot σ ∈ kvE2SepSlotBlock σ := by
  rw [kvE2_sepMem_slotBlock]
  rcases hzone with hz | hz
  · left
    rw [kvE2SepAnchorSlot, if_pos hz, kvE2SepSlotsLFor, if_pos hz]
    exact List.mem_append.mpr (Or.inr List.mem_cons_self)
  · right
    have hne : nf0ZoneSpec σ.1 ≠ kvE2SepZXW3 :=
      fun hc => kvE2_sep_zWT3_ne_zXW3 (hz.symm.trans hc)
    rw [kvE2SepAnchorSlot, if_neg hne, kvE2SepSlotsRFor, if_neg hne, if_pos hz]
    exact List.mem_append.mpr (Or.inr List.mem_cons_self)

/-- **Anchor payload projection**: the owner's ANCHOR-slot payload index,
    read from its per-slot tuple at the anchor's structural block position. Purely structural
    (`kvE2SepBlockPos` is a syntactic `idxOf`); reads no zone bit, no model data
    (F4/F5/LITMUS clean). -/
noncomputable def kvE2SepAnchorPayload {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (p : NormalForm sig 1 4 × KvE2SepSpikeOrderType × List ℕ) : ℕ :=
  p.2.2.getD (kvE2SepBlockPos (kvE2SepAnchorSlot p.1)) 0

/-- Reading the anchor payload off a `block.map g` payload returns `g` at the anchor slot
    (interior owners only — the anchor slot must be a block member). -/
theorem kvE2_sepAnchorPayload_map {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (g : KvE2SepSlot sig → ℕ)
    {σ : NormalForm sig 1 4} (tag : KvE2SepSpikeOrderType)
    (hzone : nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) :
    kvE2SepAnchorPayload (σ, tag, (kvE2SepSlotBlock σ).map g)
      = g (kvE2SepAnchorSlot σ) := by
  have hmem := kvE2_sepAnchorSlot_mem_block hzone
  have hlt : (kvE2SepSlotBlock σ).idxOf (kvE2SepAnchorSlot σ)
      < (kvE2SepSlotBlock σ).length := List.idxOf_lt_length_of_mem hmem
  have hpos : kvE2SepBlockPos (kvE2SepAnchorSlot σ)
      = (kvE2SepSlotBlock σ).idxOf (kvE2SepAnchorSlot σ) := by
    rw [kvE2SepBlockPos, kvE2_sepSlotSub_anchorSlot]
  rw [kvE2SepAnchorPayload, hpos]
  rw [kvE2_sepBlockMap_getD σ g ⟨_, hlt⟩, List.idxOf_get]

/-- **Anchor-distinct conjunct (iii')**: the cross-owner ANCHOR payload
    indices are pairwise distinct. This is what remains of the old global-`Nodup` conjunct
    after ties are admitted: base slots may tie freely (with each other and with foreign
    anchors), but two ANCHORS never coincide. D7 (Lean-side pruning, no paper counterpart):
    the exclusion is justified by the keystone route (`nf_eval_unique` —
    distinct positive owners provably cannot share a fresh anchor), so anchor-anchor order
    types are honestly unrealizable and dropping them preserves completeness; soundness is
    untouched (fewer disjuncts). Reads no zone bit (abstract ℕ `Nodup`; F4/F5/LITMUS clean). -/
noncomputable def kvE2SepAnchorDistinct {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig) : Bool :=
  decide (wo.map kvE2SepAnchorPayload).Nodup

/-- **Tie-class validity conjunct (iv)**: every payload tie involving an
    ANCHOR slot imposes the anchor owner's CLOSED-key read at the tied base slot's type — for
    each pair of slot occurrences with equal payload values where the first is the anchor slot
    of owner `σa` and the second is a base slot of type `χ` (foreign or own), the disjunct is
    admitted only when `kvE2SepClosedLeafAt σa χ = true`. Base-base tie classes impose NO read
    (F5-clean by construction); anchor-anchor ties are already excluded by (iii'), and each
    class contains at most one anchor slot for the same reason. F5: the only key entering this
    read path is the CLOSED `zAtX1L`/`zAtX1R` self-zone key (via `kvE2SepClosedLeafAt`) — no
    OPEN key enters any coincident read. Forced by Def 3.1 (p.4); Lemma 3.2(1) states the
    closure without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). -/
noncomputable def kvE2SepTieRead {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig) : Bool :=
  wo.all fun p =>
    wo.all fun q =>
      (kvE2SepSlotBlock p.1).zipIdx.all fun sj =>
        (kvE2SepSlotBlock q.1).zipIdx.all fun sk =>
          if kvE2SepSlotIsAnchor sj.1 && decide (p.2.2.getD sj.2 0 = q.2.2.getD sk.2 0) then
            match kvE2SepSlotBaseType sk.1 with
            | some χ => kvE2SepClosedLeafAt p.1 χ
            | none => true
          else true

/-- **Shared tie-conjunct discharge under a globally-`Nodup` payload**: for
    any weak order of the canonical `zipIdx`-map shape whose per-owner payload is `block.map g`
    with `g` globally duplicate-free over the slot family, BOTH new conjuncts hold — (iii')
    because the anchor payloads are a sub-selection of the duplicate-free family image, and
    (iv) vacuously because equal payload values force equal slots (all tie classes are
    singletons). This is the ONE repair lemma the three membership theorems share: their
    payloads (`kvE2SepSlotIndexOf`, `kvE2SepSlotHonestGIdx`) are globally `Nodup` (banked:
    `kvE2_sepAllSlots_map_slotIndexOf_nodup` / `_honestGIdx_nodup`). -/
theorem kvE2_sepValid_tie_of_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3)
    (tagf : NormalForm sig 1 4 → KvE2SepSpikeOrderType) (g : KvE2SepSlot sig → ℕ)
    (hnd : ((kvE2SepAllSlots qnf).map g).Nodup) :
    kvE2SepAnchorDistinct ((kvE2SepPosI qnf).zipIdx.map
        (fun p => (p.1, tagf p.1, (kvE2SepSlotBlock p.1).map g))) = true ∧
      kvE2SepTieRead ((kvE2SepPosI qnf).zipIdx.map
        (fun p => (p.1, tagf p.1, (kvE2SepSlotBlock p.1).map g))) = true := by
  have ginj := List.inj_on_of_nodup_map hnd
  constructor
  · -- (iii') anchor-distinct: anchor payloads are `g` at the (injective) anchor family.
    rw [kvE2SepAnchorDistinct, decide_eq_true_eq, List.map_map]
    have hcongr : ((kvE2SepPosI qnf).zipIdx.map
          (kvE2SepAnchorPayload ∘
            (fun p => (p.1, tagf p.1, (kvE2SepSlotBlock p.1).map g))))
        = (kvE2SepPosI qnf).zipIdx.map (fun p => g (kvE2SepAnchorSlot p.1)) := by
      apply List.map_congr_left
      intro p hp
      exact kvE2_sepAnchorPayload_map g (tagf p.1)
        (kvE2_sepPosI_zone (List.fst_mem_of_mem_zipIdx hp))
    rw [hcongr]
    have hfst : (kvE2SepPosI qnf).zipIdx.map (fun p => g (kvE2SepAnchorSlot p.1))
        = (kvE2SepPosI qnf).map (fun σ => g (kvE2SepAnchorSlot σ)) := by
      conv_rhs => rw [← List.zipIdx_map_fst 0 (kvE2SepPosI qnf)]
      rw [List.map_map]
      rfl
    rw [hfst]
    have hposI : (kvE2SepPosI qnf).Nodup :=
      List.Nodup.filter _ (List.Nodup.filter _ (Finset.nodup_toList _))
    refine List.Nodup.map_on (fun σ hσ τ hτ heq => ?_) hposI
    have hσa := kvE2_sepAnchorSlot_mem_block (kvE2_sepPosI_zone hσ)
    have hτa := kvE2_sepAnchorSlot_mem_block (kvE2_sepPosI_zone hτ)
    exact kvE2_sepAnchorSlot_injective
      (ginj (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hσa)
        (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hτ) hτa) heq)
  · -- (iv) tie-read: vacuous — equal `g`-values force equal slots (singleton classes).
    rw [kvE2SepTieRead, List.all_eq_true]
    intro p hp
    rw [List.all_eq_true]
    intro q hq
    obtain ⟨p', hp', rfl⟩ := List.mem_map.mp hp
    obtain ⟨q', hq', rfl⟩ := List.mem_map.mp hq
    rw [List.all_eq_true]
    intro sj hsj
    rw [List.all_eq_true]
    intro sk hsk
    obtain ⟨hjlt, hjeq⟩ := List.getElem?_eq_some_iff.mp
      (List.mem_zipIdx_iff_getElem?.mp hsj)
    obtain ⟨hklt, hkeq⟩ := List.getElem?_eq_some_iff.mp
      (List.mem_zipIdx_iff_getElem?.mp hsk)
    split
    case isTrue hcond =>
      rw [Bool.and_eq_true, decide_eq_true_eq] at hcond
      obtain ⟨hanchor, heq⟩ := hcond
      have hread1 : ((kvE2SepSlotBlock p'.1).map g).getD sj.2 0
          = g ((kvE2SepSlotBlock p'.1).get ⟨sj.2, hjlt⟩) :=
        kvE2_sepBlockMap_getD p'.1 g ⟨sj.2, hjlt⟩
      have hread2 : ((kvE2SepSlotBlock q'.1).map g).getD sk.2 0
          = g ((kvE2SepSlotBlock q'.1).get ⟨sk.2, hklt⟩) :=
        kvE2_sepBlockMap_getD q'.1 g ⟨sk.2, hklt⟩
      simp only [List.get_eq_getElem, hjeq, hkeq] at hread1 hread2
      rw [hread1, hread2] at heq
      have hjm : sj.1 ∈ kvE2SepSlotBlock p'.1 := hjeq ▸ List.getElem_mem hjlt
      have hkm : sk.1 ∈ kvE2SepSlotBlock q'.1 := hkeq ▸ List.getElem_mem hklt
      have hslots : sj.1 = sk.1 :=
        ginj (kvE2_sepMem_allSlots qnf
            (kvE2_sepPosI_subset (List.fst_mem_of_mem_zipIdx hp')) hjm)
          (kvE2_sepMem_allSlots qnf
            (kvE2_sepPosI_subset (List.fst_mem_of_mem_zipIdx hq')) hkm) heq
      rw [← hslots, kvE2_sepSlotBaseType_eq_none_of_isAnchor hanchor]
    case isFalse => rfl

/-- **Per-owner disjunct validity.** Strict placements read σ's OPEN zone bit; the `coincident` tie
    reads σ's CLOSED `zAtX1L` bit via the forward stub. No disjunct conflates open and closed keys
    (F5). -/
def kvE2SepDisjValidOwner {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : KvE2SepSpikeOrderType → Bool
  | .strictBefore => kvE2SepBits σ kvESub2ZXU (nf0ProjFresh σ.1)
  | .strictAfter  => kvE2SepBits σ kvESub2ZUW (nf0ProjFresh σ.1)
  | .coincident   => kvE2SepClosedLeafStub σ

/-- **Per-owner index-tuple consistency** (the linear-extension conjunct): the owner's
    per-slot global-index tuple `(i₀,i₁,i₂)` EXTENDS its region order — `i₀ < i₁ < i₂`, i.e. the
    global index of its region-rank-0 slot precedes its fresh anchor (rank 1) precedes its region-2
    slot (`lXU<lX1<lUW` left, `rWX1<rX1<rX1T` right). A linear extension of each owner's region
    partial order (Lemma 3.2(1), PDF p.3: one consistent global order over the union). Reads NO zone
    bit (F5 clean); an abstract ℕ compare, never an `x1 < e_i` model literal (F4/LITMUS clean). -/
def kvE2SepConsistentTuple (t : List ℕ) : Bool :=
  decide (t.getD 0 0 < t.getD 1 0 ∧ t.getD 1 0 < t.getD 2 0)

/-- **Per-disjunct validity** (faithful replacement of the additive `kvE2_sepValid`;
    tie-admitting): a weak order is valid iff (i) every per-owner placement is admitted
    by the owner's arrangement-appropriate zone bit (the per-order-type read, F5), (ii) every
    owner's per-slot global-index tuple EXTENDS its region order (`kvE2SepConsistentBlock`, the
    linear-extension conjunct), (iii') the cross-owner ANCHOR payload indices are
    pairwise distinct (`kvE2SepAnchorDistinct` — D7: a Lean-side `nf_eval_unique`-certified
    pruning of the honestly-unrealizable anchor-anchor ties, no paper counterpart), AND (iv)
    every base-anchor payload tie is admitted by the anchor owner's CLOSED-key read at the tied
    base type (`kvE2SepTieRead`; base-base ties impose no read). The former conjunct (iii) —
    global `Nodup` over the flattened payload — is GONE: it made the Lemma 3.2(1) equality-case
    order types unrepresentable (honest base-base slot ties and base-foreign-anchor ties realized
    NO disjunct at all — a machine-certified completeness hole). Ties are INDEX-LEVEL data only:
    each emitted disjunct remains a strict Def-3.1 bracket, one slot per tie class (strict-quotient
    guard; the grouped builder is Phase 7). Forced by Def 3.1 (p.4); Lemma 3.2(1) states the
    closure without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). The
    consistency conjunct (ii) is what makes the a<u'<b cross-region interleaving admissible while
    keeping each owner's own slots region-ordered. Reads no zone bit in (ii)/(iii'); (iv) reads
    ONLY the CLOSED `zAtX1L`/`zAtX1R` self-zone keys (F5). NOT an additive filter over a flat
    slot union. -/
noncomputable def kvE2SepDisjValid {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (_qnf : NormalForm sig 2 3) (wo : KvE2SepWeakOrder sig) : Bool :=
  wo.all (fun p => kvE2SepDisjValidOwner p.1 p.2.1)
    && wo.all (fun p => kvE2SepConsistentBlock p.1 p.2.2)
    && kvE2SepAnchorDistinct wo
    && kvE2SepTieRead wo

/-- **The faithful carrier** (replacing `kvE2_sepArrL/R`): the valid order-type disjuncts, the
    per-order-type filter of the disjunction index (Lemma 3.2(1), PDF p.3). -/
noncomputable def kvE2SepArr' {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) : List (KvE2SepWeakOrder sig) :=
  (kvE2SepOrderTypes qnf).filter (kvE2SepDisjValid qnf)

/-- The carrier's validity predicate is decidable, so `kvE2SepArr'` is `decide`-able. -/
noncomputable instance kvE2SepArr'Decidable {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3) :
    DecidablePred (fun wo : KvE2SepWeakOrder sig => kvE2SepDisjValid qnf wo = true) :=
  fun wo => inferInstanceAs (Decidable (kvE2SepDisjValid qnf wo = true))

/-- **Structural non-emptiness helper** (generalized over rank bound `n`, tag map `f`, and the
    `zipIdx` start `s`): the `(tag, rank)` assignment tagging each owner by `f` and ranking it by
    its
    consecutive `zipIdx` index `s, s+1, …` — all `< n` — is reachable in the cartesian rank×tag
    enumeration. Both `kvE2SepModelOrder` and `kvE2SepCoincidentOrder` are instances (`s = 0`,
    `n = |pos|`). -/
private theorem kvE2_sepOrderTypes_mem_aux {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (n : ℕ)
    (f : NormalForm sig 1 4 → KvE2SepSpikeOrderType)
    (gt : ℕ → List ℕ)
    (L : List (NormalForm sig 1 4)) (s : ℕ)
    (hb : ∀ i, i < L.length → gt (s + i) ∈ kvE2SepIdxTuples n) :
    (L.zipIdx s).map (fun p => (p.1, f p.1, gt p.2)) ∈
      L.foldr
        (fun σ acc =>
          kvE2SepSpikeOrderTypes.flatMap (fun tag =>
            (kvE2SepIdxTuples n).flatMap (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
        [[]] := by
  induction L generalizing s with
  | nil => simp
  | cons σ L ih =>
    simp only [List.zipIdx_cons, List.map_cons, List.foldr_cons]
    rw [List.mem_flatMap]
    refine ⟨f σ, kvE2_sepSpikeOrderTypes_complete _, ?_⟩
    rw [List.mem_flatMap]
    refine ⟨gt s, ?_, ?_⟩
    · simpa using hb 0 (by simp)
    · rw [List.mem_map]
      refine ⟨(L.zipIdx (s + 1)).map (fun p => (p.1, f p.1, gt p.2)), ?_, rfl⟩
      exact ih (s + 1) (fun i hi => by
        have h := hb (i + 1) (by simpa using hi)
        rwa [show s + (i + 1) = s + 1 + i by omega] at h)

/-- **Enumeration-parametric membership**: the per-OWNER payload assignment
    `gt` (each `gt σ` drawn from σ's own tuple set `enum σ`) is reachable in the σ-dependent
    cartesian
    tag×tuple enumeration. The generalization of `kvE2_sepOrderTypes_mem_aux` from a fixed tuple
    set +
    position-indexed `gt` to a per-owner `enum`/`gt` — the shape the variable-length per-slot
    payload
    (`block.map …`) needs. -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (D,F).
theorem kvE2_sepOrderTypes_mem_aux' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (f : NormalForm sig 1 4 → KvE2SepSpikeOrderType)
    (enum : NormalForm sig 1 4 → List (List ℕ))
    (gt : NormalForm sig 1 4 → List ℕ)
    (L : List (NormalForm sig 1 4)) (s : ℕ)
    (hb : ∀ σ ∈ L, gt σ ∈ enum σ) :
    (L.zipIdx s).map (fun p => (p.1, f p.1, gt p.1)) ∈
      L.foldr
        (fun σ acc =>
          kvE2SepSpikeOrderTypes.flatMap (fun tag =>
            (enum σ).flatMap (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
        [[]] := by
  induction L generalizing s with
  | nil => simp
  | cons σ L ih =>
    simp only [List.zipIdx_cons, List.map_cons, List.foldr_cons]
    rw [List.mem_flatMap]
    refine ⟨f σ, kvE2_sepSpikeOrderTypes_complete _, ?_⟩
    rw [List.mem_flatMap]
    refine ⟨gt σ, hb σ List.mem_cons_self, ?_⟩
    rw [List.mem_map]
    exact ⟨(L.zipIdx (s + 1)).map (fun p => (p.1, f p.1, gt p.1)),
      ih (s + 1) (fun τ hτ => hb τ (List.mem_cons_of_mem σ hτ)), rfl⟩

/-- **Enumeration-parametric owner projection**: every disjunct in the
    σ-dependent enumeration carries exactly `L` in order. Generalizes
    `kvE2_sepOrderTypes_owners_aux`
    over an arbitrary per-owner `enum`. -/
private theorem kvE2_sepOrderTypes_owners_aux' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (enum : NormalForm sig 1 4 → List (List ℕ))
    (L : List (NormalForm sig 1 4)) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈
      L.foldr
        (fun σ acc =>
          kvE2SepSpikeOrderTypes.flatMap (fun tag =>
            (enum σ).flatMap (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
        [[]]) :
    wo.map Prod.fst = L := by
  induction L generalizing wo with
  | nil => simp only [List.foldr_nil, List.mem_singleton] at hwo; subst hwo; rfl
  | cons σ L ih =>
    simp only [List.foldr_cons] at hwo
    rw [List.mem_flatMap] at hwo
    obtain ⟨tag, _, hwo⟩ := hwo
    rw [List.mem_flatMap] at hwo
    obtain ⟨t, _, hwo⟩ := hwo
    rw [List.mem_map] at hwo
    obtain ⟨wo', hwo', rfl⟩ := hwo
    simp only [List.map_cons, ih hwo']

/-- The model-order disjunct is present in the enumeration index (F2, structural level). -/
theorem kvE2_sepModelOrder_mem_orderTypes {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) :
    kvE2SepModelOrder qnf ∈ kvE2SepOrderTypes qnf := by
  rw [kvE2SepModelOrder, kvE2SepOrderTypes]
  refine kvE2_sepOrderTypes_mem_aux' kvE2SepModelTag _
    (fun σ => (kvE2SepSlotBlock σ).map (kvE2SepSlotIndexOf qnf)) (kvE2SepPosI qnf) 0
    (fun σ hσ => ?_)
  have h := kvE2_sepIdxTupleN_mem_of_forall_lt (kvE2SepAllSlots qnf).length
    ((kvE2SepSlotBlock σ).map (kvE2SepSlotIndexOf qnf)) (fun y hy => by
      obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hy
      exact kvE2_sepSlotIndexOf_lt qnf (kvE2_sepMem_allSlots qnf (kvE2_sepPosI_subset hσ) hs))
  rwa [List.length_map] at h

/-- **Structural non-vacuity** (F2, PDF p.3): whenever the honest model arrangement's disjunct is
    valid — the selection guaranteed by the honest bundle (full semantic discharge is Phase 8) —
    the faithful carrier `kvE2SepArr'` is non-empty, because the model-order disjunct is present in
    the enumeration and passes the per-order-type filter. -/
theorem kvE2_sepArr'_mem_modelOrder {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    (hvalid : kvE2SepDisjValid qnf (kvE2SepModelOrder qnf) = true) :
    kvE2SepModelOrder qnf ∈ kvE2SepArr' qnf := by
  rw [kvE2SepArr', List.mem_filter]
  exact ⟨kvE2_sepModelOrder_mem_orderTypes qnf, hvalid⟩

/-! ## Phase 4 — `wo`-driven slot ordering (the rewire consuming the cross-owner rank) -/

/-- **wo-driven owner ordering** (Phase 4): the owners of `wo` listed in ascending merged-chain
    RANK order — the cross-owner order `wo` now carries. This is what the rewired `kvE2SepBody`
    consumes to realize each disjunct's OWN cross-owner slot order, replacing the discarded-`_wo`
    body's fixed `kvE2SepPos` order (the exact root bug that stalled the grouped
    builder).
    Because `mergeSort` is a permutation of its input, `kvE2SepOrderOwners wo` carries the same
    owner MULTISET as `wo` — but sequenced by the rank the disjunct realizes. -/
def kvE2SepOrderOwners {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig) : List (NormalForm sig 1 4) :=
  (wo.mergeSort (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map Prod.fst

/-- **Owner merged-chain rank read**: σ's merged-chain rank as recorded in `wo` (338's
    per-owner rank field, consumed AS-IS). Owners not present in `wo` default to `0` (never occurs
    on the enumeration index, where `wo.map Prod.fst = kvE2SepPosI qnf`). -/
def kvE2SepOwnerRank {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig) (σ : NormalForm sig 1 4) : ℕ :=
  ((wo.find? (fun p => decide (p.1 = σ))).map (fun p => p.2.2.getD 0 0)).getD 0

/-- **Per-slot global index reader**: the single global index of slot `s` under `wo` —
    read from the owner's per-slot index tuple `(i₀,i₁,i₂)` at `s`'s region rank. Owners not in `wo`
    default to tuple `(0,0,0)` (never occurs on the enumeration index). This is the abstract ℕ the
    single-level merge key compares — a total order on the full slot multiset (Rabinovich Def 3.1
    single global chain), NOT a region×owner product. Reads no zone bit (F5 clean); never a model
    relative-position literal (F4/LITMUS clean — the index is structural carrier data). -/
noncomputable def kvE2SepSlotGIdx {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig) (s : KvE2SepSlot sig) : ℕ :=
  let t := ((wo.find? (fun p => decide (p.1 = kvE2SepSlotSub s))).map
    (fun p => p.2.2)).getD []
  t.getD (kvE2SepBlockPos s) 0

/-- **Single-level per-slot global-index merge key**: compares two slots by their global
    index `kvE2SepSlotGIdx wo`. Region rank is NO LONGER primary — a region-2 slot of one owner can
    precede a region-1 slot of another (the honest `a<u'<b` cross-region case, report 06, that the
    dropped 339 region-primary lex could not express). The index is a total order over the union of
    all owners' points (Def 3.1 single global chain), constrained to extend each owner's region
    order
    by the `kvE2SepDisjValid` consistency conjunct. Abstract ℕ compare; F4/F5/LITMUS clean. -/
noncomputable def kvE2SepSlotMergeLe {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig) (a b : KvE2SepSlot sig) : Bool :=
  decide (kvE2SepSlotGIdx wo a ≤ kvE2SepSlotGIdx wo b)

/-- The wo-ordered joint LEFT slot list — a genuine POINT-LEVEL cross-owner merge: the
    per-owner LEFT region slots, `mergeSort`ed by the composite point-level key
    `kvE2SepSlotMergeLe wo` (region rank primary, owner merged-chain rank secondary). Because
    `mergeSort` is a permutation of its input, this carries the SAME slot multiset as the block
    union `(kvE2SepOrderOwners wo).flatMap kvE2SepSlotsLFor` (so every per-owner slot-membership
    fact survives, `List.mergeSort_perm`), but individual owner slots are now interleaved into ONE
    globally key-sorted chain (Rabinovich Def 3.1, single global chain over the union of points),
    NOT sequenced as contiguous owner blocks. Genuinely CONSUMES `wo` (via `kvE2SepOwnerRank`).
    Never asserts flat-union monotone validity; the joint sorted-realization builder is
    `kvE2_sepBracket_holds_of_honest`. -/
noncomputable def kvE2SepSlotsLOf {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig) : List (KvE2SepSlot sig) :=
  ((kvE2SepOrderOwners wo).flatMap kvE2SepSlotsLFor).mergeSort (kvE2SepSlotMergeLe wo)

/-- The wo-ordered joint RIGHT slot list (right mirror of `kvE2SepSlotsLOf`): point-level merge of
    the per-owner RIGHT region slots by the same composite key. Consumes `wo`. -/
noncomputable def kvE2SepSlotsROf {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig) : List (KvE2SepSlot sig) :=
  ((kvE2SepOrderOwners wo).flatMap kvE2SepSlotsRFor).mergeSort (kvE2SepSlotMergeLe wo)

/-! ### Tie-class grouping

Grouping the wo-sorted joint slot lists into maximal runs of equal merge key
(`kvE2SepSlotGIdx wo` — the wo-payload index). On the `mergeSort`ed lists equal keys are
adjacent, so adjacent runs ARE the tie classes. Tie classes are INDEX-LEVEL data: the Phase-7
grouped builder emits ONE strict bracket slot per class with the conjoined point type
`formulaConjList (class.map (kvE2SepSlotType charBase charK))` — the strict-quotient guard.
Forced by Def 3.1 (p.4: single strict witness chain, free variables pinned, conjunction
semantics); Lemma 3.2(1) states the closure without printed proof; corroborated by the k=m
split (p.7) and Def 7.5 (p.13). -/

/-- **Adjacent-run grouping kernel** (house pattern — this toolchain's
    `List.splitBy` ships without lemma support): groups a list into maximal runs of adjacent
    elements with equal `key`. On a key-sorted list (the only use site) the runs are exactly
    the key's equivalence classes. Structural recursion; abstract over the element type
    (reads no zone bit, no model data). -/
def kvE2SepTieRuns {α : Type*} (key : α → ℕ) : List α → List (List α)
  | [] => []
  | [a] => [[a]]
  | a :: b :: rest =>
    match kvE2SepTieRuns key (b :: rest) with
    | [] => [[a]]
    | c :: cs => if key a = key b then (a :: c) :: cs else [a] :: c :: cs

/-- Structural shape: grouping a cons yields a first run headed by the head element. -/
theorem kvE2_sepTieRuns_shape {α : Type*} (key : α → ℕ) :
    ∀ (l : List α) (x : α), ∃ t cs, kvE2SepTieRuns key (x :: l) = (x :: t) :: cs
  | [], _ => ⟨[], [], rfl⟩
  | b :: rest, x => by
    obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
    by_cases hk : key x = key b
    · exact ⟨b :: t, cs, by rw [kvE2SepTieRuns, heq]; simp only [if_pos hk]⟩
    · exact ⟨[], (b :: t) :: cs, by rw [kvE2SepTieRuns, heq]; simp only [if_neg hk]⟩

/-- **Round trip**: flattening the tie classes returns the (sorted) input list — the grouping
    is a partition, losing and duplicating nothing. -/
theorem kvE2_sepTieRuns_flatten {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), (kvE2SepTieRuns key l).flatten = l
  | [] => rfl
  | [_] => rfl
  | a :: b :: rest => by
    have ih := kvE2_sepTieRuns_flatten key (b :: rest)
    obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
    rw [heq] at ih
    by_cases hk : key a = key b
    · rw [kvE2SepTieRuns, heq]
      simp only [if_pos hk]
      simpa using ih
    · rw [kvE2SepTieRuns, heq]
      simp only [if_neg hk]
      simpa using ih

/-- Every tie class is nonempty (each run is headed by an actual element). -/
theorem kvE2_sepTieRuns_ne_nil {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), ∀ c ∈ kvE2SepTieRuns key l, c ≠ []
  | [] => by simp [kvE2SepTieRuns]
  | [a] => by simp [kvE2SepTieRuns]
  | a :: b :: rest => by
    have ih := kvE2_sepTieRuns_ne_nil key (b :: rest)
    obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
    rw [heq] at ih
    intro c hc
    rw [kvE2SepTieRuns, heq] at hc
    by_cases hk : key a = key b
    · simp only [if_pos hk] at hc
      rcases List.mem_cons.mp hc with rfl | h
      · exact List.cons_ne_nil _ _
      · exact ih c (List.mem_cons_of_mem _ h)
    · simp only [if_neg hk] at hc
      rcases List.mem_cons.mp hc with rfl | h
      · exact List.cons_ne_nil _ _
      · exact ih c h

/-- **Nodup keys ⟹ all classes are singletons**: when the key family is duplicate-free over
    the list, the grouping degenerates to the singleton partition — the tie-free case, under
    which the Phase-7 grouped builder coincides with the flat builder. -/
theorem kvE2_sepTieRuns_of_nodup {α : Type*} (key : α → ℕ) :
    ∀ (l : List α), (l.map key).Nodup → kvE2SepTieRuns key l = l.map (fun a => [a])
  | [], _ => rfl
  | [_], _ => rfl
  | a :: b :: rest, hnd => by
    rw [List.map_cons, List.nodup_cons] at hnd
    have hne : key a ≠ key b := fun hc => hnd.1 (by
      rw [List.map_cons]
      exact hc ▸ List.mem_cons_self)
    have ih := kvE2_sepTieRuns_of_nodup key (b :: rest) hnd.2
    obtain ⟨t, cs, heq⟩ := kvE2_sepTieRuns_shape key rest b
    calc kvE2SepTieRuns key (a :: b :: rest)
        = [a] :: kvE2SepTieRuns key (b :: rest) := by
          rw [kvE2SepTieRuns, heq]
          simp only [if_neg hne]
      _ = [a] :: (b :: rest).map (fun a => [a]) := by rw [ih]
      _ = (a :: b :: rest).map (fun a => [a]) := rfl

/-- **LEFT tie-class grouping**: the wo-sorted joint LEFT slot list grouped
    into maximal runs of equal wo-payload index (`kvE2SepSlotGIdx wo`, the merge key). Equal
    keys are adjacent on the `mergeSort`ed list, so the runs are the tie classes. Consumed by
    the Phase-7 grouped disjunct builder: one strict bracket slot per class (strict-quotient
    guard — ties collapse the index, never the bracket). -/
noncomputable def kvE2SepTieGroupedL {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig) : List (List (KvE2SepSlot sig)) :=
  kvE2SepTieRuns (kvE2SepSlotGIdx wo) (kvE2SepSlotsLOf wo)

/-- **RIGHT tie-class grouping** (right mirror of `kvE2SepTieGroupedL`). -/
noncomputable def kvE2SepTieGroupedR {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (wo : KvE2SepWeakOrder sig) : List (List (KvE2SepSlot sig)) :=
  kvE2SepTieRuns (kvE2SepSlotGIdx wo) (kvE2SepSlotsROf wo)

/-- Round trip: the LEFT tie classes flatten back to the wo-sorted LEFT slot list. -/
theorem kvE2_sepTieGroupedL_flatten {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (wo : KvE2SepWeakOrder sig) :
    (kvE2SepTieGroupedL wo).flatten = kvE2SepSlotsLOf wo :=
  kvE2_sepTieRuns_flatten _ _

/-- Round trip: the RIGHT tie classes flatten back to the wo-sorted RIGHT slot list. -/
theorem kvE2_sepTieGroupedR_flatten {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (wo : KvE2SepWeakOrder sig) :
    (kvE2SepTieGroupedR wo).flatten = kvE2SepSlotsROf wo :=
  kvE2_sepTieRuns_flatten _ _

/-- Every LEFT tie class is nonempty. -/
theorem kvE2_sepTieGroupedL_ne_nil {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (wo : KvE2SepWeakOrder sig) :
    ∀ c ∈ kvE2SepTieGroupedL wo, c ≠ [] :=
  kvE2_sepTieRuns_ne_nil _ _

/-- Every RIGHT tie class is nonempty. -/
theorem kvE2_sepTieGroupedR_ne_nil {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (wo : KvE2SepWeakOrder sig) :
    ∀ c ∈ kvE2SepTieGroupedR wo, c ≠ [] :=
  kvE2_sepTieRuns_ne_nil _ _

/-- Nodup payload ⟹ every LEFT tie class is a singleton (the tie-free degenerate case). -/
theorem kvE2_sepTieGroupedL_of_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (wo : KvE2SepWeakOrder sig)
    (hnd : ((kvE2SepSlotsLOf wo).map (kvE2SepSlotGIdx wo)).Nodup) :
    kvE2SepTieGroupedL wo = (kvE2SepSlotsLOf wo).map (fun s => [s]) :=
  kvE2_sepTieRuns_of_nodup _ _ hnd

/-- Nodup payload ⟹ every RIGHT tie class is a singleton (the tie-free degenerate case). -/
theorem kvE2_sepTieGroupedR_of_nodup {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (wo : KvE2SepWeakOrder sig)
    (hnd : ((kvE2SepSlotsROf wo).map (kvE2SepSlotGIdx wo)).Nodup) :
    kvE2SepTieGroupedR wo = (kvE2SepSlotsROf wo).map (fun s => [s]) :=
  kvE2_sepTieRuns_of_nodup _ _ hnd

/-! ### Meet-folded grouped disjunct builder

One STRICT bracket slot per tie class (the strict-quotient guard): a class's point type is
the CONJUNCTION (meet) of its members' slot types; segments reuse the flat per-cut refined
conjunctions evaluated at the flat prefix (segments already meet-fold across all owners per
cut — Phase 4 finding — so tie folding is point-type grouping + cut reindexing ONLY). Ties
collapse the INDEX, never the bracket: the emitted disjunct is a strict Def-3.1 bracket and
`IntervalPattern.holds` strictness is untouched. Forced by Def 3.1 (p.4: single strict
witness chain, free variables pinned, conjunction semantics); Lemma 3.2(1) states the
closure without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). -/

/-- **Meet-folded point type of one tie class**: the conjunction of the members' slot types.
    A tie is ONE slot whose point realizes every tied type — never two slots with a weakened
    order (Def 3.1 conjunction semantics, p.4). -/
noncomputable def kvE2SepClassType {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (c : List (KvE2SepSlot sig)) : TemporalPred :=
  ⟨formulaConjList (c.map (fun s => (kvE2SepSlotType charBase charK s).formula))⟩

/-- Class-point evaluation: the meet-folded class type is realized iff EVERY member's slot
    type is realized at the point (conjunction semantics). -/
theorem kvE2_sepClassType_eval_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (c : List (KvE2SepSlot sig))
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (y : M.carrier) :
    (kvE2SepClassType charBase charK c).EvalAt M atomMap y ↔
      ∀ s ∈ c, (kvE2SepSlotType charBase charK s).EvalAt M atomMap y := by
  simp only [kvE2SepClassType, TemporalPred.EvalAt]
  rw [formula_conjList_iff]
  constructor
  · intro hall s hs
    exact hall _ (List.mem_map_of_mem hs)
  · intro hall f hf
    obtain ⟨s, hs, rfl⟩ := List.mem_map.mp hf
    exact hall s hs

/-- **Per-class evaluation helper** (the one extraction-side deliverable owed to the 337
    re-plan): a realized meet-folded class point realizes EACH member's slot type. -/
theorem kvE2_sepClassType_eval_mem {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    {c : List (KvE2SepSlot sig)}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (y : M.carrier)
    (h : (kvE2SepClassType charBase charK c).EvalAt M atomMap y)
    {s : KvE2SepSlot sig} (hs : s ∈ c) :
    (kvE2SepSlotType charBase charK s).EvalAt M atomMap y :=
  (kvE2_sepClassType_eval_iff charBase charK c M atomMap y).mp h s hs

/-- Singleton-class evaluation: the meet of one slot type eval-equals the slot type
    (`formulaConjList [f]` is `f ∧ ⊤`, not `f` — eval-level only, never syntactic). -/
theorem kvE2_sepClassType_singleton_eval {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (s : KvE2SepSlot sig)
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) (y : M.carrier) :
    (kvE2SepClassType charBase charK [s]).EvalAt M atomMap y ↔
      (kvE2SepSlotType charBase charK s).EvalAt M atomMap y := by
  rw [kvE2_sepClassType_eval_iff]
  exact List.forall_mem_singleton

/-- Flattening the singleton partition returns the list (the tie-free degenerate shape). -/
private theorem kvE2_sep_flatten_map_singleton {α : Type*} (l : List α) :
    (l.map (fun a => [a])).flatten = l := by
  induction l with
  | nil => rfl
  | cons a t ih => simp [ih]

/-- **Grouped segment dispatcher**: cut `i` of the grouped LEFT list
    reuses the EXISTING flat per-cut refined conjunction at the flat prefix — the segment at
    grouped cut `i` is `kvE2SepSegLAt` on `gL.flatten` at flat cut
    `((gL.take i).flatten).length` (segments between two members of one tie class disappear
    with the slot; segments already meet-fold across all owners per cut, so tie folding is
    point-type grouping + cut reindexing ONLY — no new segment machinery). Right mirror with
    the same boundary convention as `kvE2SepSegs`. -/
noncomputable def kvE2SepSegsG {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (gL gR : List (List (KvE2SepSlot sig))) (i : Nat) : TemporalPred :=
  if i ≤ gL.length then
    kvE2SepSegLAt charBase qnf gL.flatten ((gL.take i).flatten).length
  else
    kvE2SepSegRAt charBase qnf gR.flatten ((gR.take (i - gL.length - 1)).flatten).length

/-- On the singleton partition the grouped dispatcher agrees with the flat dispatcher at
    every bracket-relevant cut (singleton prefixes flatten to length exactly `i`). -/
-- Module-public (was file-private): consumed by later modules of the SharedWitness tower (F).
theorem kvE2_sepSegsG_map_singleton {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (qnf : NormalForm sig 2 3)
    (lL lR : List (KvE2SepSlot sig)) (i : Nat) (hi : i ≤ lL.length + 1 + lR.length) :
    kvE2SepSegsG charBase qnf (lL.map (fun s => [s])) (lR.map (fun s => [s])) i
      = kvE2SepSegs charBase qnf lL lR i := by
  rw [kvE2SepSegsG, kvE2SepSegs]
  by_cases hle : i ≤ lL.length
  · rw [if_pos (by simpa using hle), if_pos hle,
      kvE2_sep_flatten_map_singleton, ← List.map_take, kvE2_sep_flatten_map_singleton,
      List.length_take]
    congr 1
    omega
  · rw [if_neg (by simpa using hle), if_neg hle,
      kvE2_sep_flatten_map_singleton, ← List.map_take, kvE2_sep_flatten_map_singleton,
      List.length_take, List.length_map]
    congr 1
    omega

/-- **Meet-folded grouped joint disjunct builder** (TOP-LEVEL per the crux
    failed-closer-3 lesson — no let-buried builders). One STRICT Def-3.1 bracket slot per
    tie class: the class point type is the meet `kvE2SepClassType` of its members' slot
    types, the shared `ptW` and both endpoint predicates are unchanged, `kvE2SepBracketN`
    is consumed AS-IS (generic over point-type lists), and segments ride the grouped
    dispatcher `kvE2SepSegsG`. STRICT-QUOTIENT GUARD: tie classes are index-level data
    only — ties collapse the index, never the bracket, and `IntervalPattern.holds`
    strictness is untouched. Forced by Def 3.1 (p.4); Lemma 3.2(1) states the closure
    without printed proof; corroborated by the k=m split (p.7) and Def 7.5 (p.13). -/
noncomputable def kvE2SepDisjunct' {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (charBase : NormalForm sig 0 1 → Formula) (charK : NormalForm sig 1 1 → Formula)
    (qnf : NormalForm sig 2 3) (gL gR : List (List (KvE2SepSlot sig))) : Σ n, VecEA2 n :=
  ⟨(gL.map (kvE2SepClassType charBase charK)).length + 1
      + (gR.map (kvE2SepClassType charBase charK)).length,
   { endpointLeft := kvE2SepEpL charBase charK qnf
     endpointRight := kvE2SepEpR charBase charK qnf
     bracket := kvE2SepBracketN
       (gL.map (kvE2SepClassType charBase charK))
       (kvE2SepPtW charBase charK qnf)
       (gR.map (kvE2SepClassType charBase charK))
       (kvE2SepSegsG charBase qnf gL gR) }⟩

/-- Structural helper: every disjunct in the `foldr` enumeration carries EXACTLY the positive
    owners in `kvE2SepPos` order (one prepended entry per owner). -/
private theorem kvE2_sepOrderTypes_owners_aux {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (n : ℕ)
    (L : List (NormalForm sig 1 4)) {wo : KvE2SepWeakOrder sig}
    (hwo : wo ∈
      L.foldr
        (fun σ acc =>
          kvE2SepSpikeOrderTypes.flatMap (fun tag =>
            (kvE2SepIdxTuples n).flatMap (fun t => acc.map (fun wo => (σ, tag, t) :: wo))))
        [[]]) :
    wo.map Prod.fst = L := by
  induction L generalizing wo with
  | nil => simp only [List.foldr_nil, List.mem_singleton] at hwo; subst hwo; rfl
  | cons σ L ih =>
    simp only [List.foldr_cons] at hwo
    rw [List.mem_flatMap] at hwo
    obtain ⟨tag, _, hwo⟩ := hwo
    rw [List.mem_flatMap] at hwo
    obtain ⟨t, _, hwo⟩ := hwo
    rw [List.mem_map] at hwo
    obtain ⟨wo', hwo', rfl⟩ := hwo
    simp only [List.map_cons, ih hwo']

/-- Every `wo` in the enumeration index has owner-projection exactly the interior index
    `kvE2SepPosI qnf`. -/
theorem kvE2_sepOrderTypes_owners {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2SepOrderTypes qnf) :
    wo.map Prod.fst = kvE2SepPosI qnf := by
  rw [kvE2SepOrderTypes] at hwo
  exact kvE2_sepOrderTypes_owners_aux' _ _ hwo

/-- Every INTERIOR positive owner appears in the wo-ordered owner list (rank-reordering
    permutes, never drops, the owner multiset): the membership fact the `kvE2_sepBody_extract`
    rewire consumes. A consumer holding only `σ ∈ kvE2SepPos` plus a slot recovers the
    interior membership via `kvE2_sepMem_posI_of_slot` (nonempty blocks force interiority). -/
theorem kvE2_sepMem_orderOwners {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds] (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2SepOrderTypes qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2SepPosI qnf) :
    σ ∈ kvE2SepOrderOwners wo := by
  rw [kvE2SepOrderOwners]
  have hperm := (List.mergeSort_perm wo (fun a b => decide (a.2.2.getD 0 0 ≤ b.2.2.getD 0 0))).map
      Prod.fst
  rw [kvE2_sepOrderTypes_owners qnf hwo] at hperm
  exact hperm.mem_iff.mpr hσ

/-- **Point-level merge membership** (LEFT): every per-owner LEFT slot of a positive
    owner is a member of the merged chain `kvE2SepSlotsLOf wo`. Because the merge is a
    `mergeSort` (hence a permutation, `List.mergeSort_perm`) of the block union
    `(kvE2SepOrderOwners wo).flatMap kvE2SepSlotsLFor`, membership reduces to the block-union
    membership `kvE2_sepMem_orderOwners` — the same permutation technique as
    `kvE2_sepMem_orderOwners` itself. This is the `hmemL` witness the `kvE2_sepBody_extract`
    rewire consumes against the point-level def. -/
theorem kvE2_sepSlotsLOf_mem {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2SepOrderTypes qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2SepPosI qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2SepSlotsLFor σ) :
    s ∈ kvE2SepSlotsLOf wo := by
  rw [kvE2SepSlotsLOf]
  exact (List.mergeSort_perm _ _).mem_iff.mpr
    (List.mem_flatMap.mpr ⟨σ, kvE2_sepMem_orderOwners qnf hwo hσ, hs⟩)

/-- **Point-level merge membership** (RIGHT mirror of `kvE2_sepSlotsLOf_mem`). -/
theorem kvE2_sepSlotsROf_mem {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3)
    {wo : KvE2SepWeakOrder sig} (hwo : wo ∈ kvE2SepOrderTypes qnf)
    {σ : NormalForm sig 1 4} (hσ : σ ∈ kvE2SepPosI qnf)
    {s : KvE2SepSlot sig} (hs : s ∈ kvE2SepSlotsRFor σ) :
    s ∈ kvE2SepSlotsROf wo := by
  rw [kvE2SepSlotsROf]
  exact (List.mergeSort_perm _ _).mem_iff.mpr
    (List.mem_flatMap.mpr ⟨σ, kvE2_sepMem_orderOwners qnf hwo hσ, hs⟩)

/-- **Below-anchor cross-region interleaving** (the defining property this redesign
    installs — the case report 06 proved 339's region-primary key could NOT express). With a
    per-slot
    global index in which owner σ's region-2 slot `lUW` receives a STRICTLY SMALLER index than owner
    τ's region-1 anchor slot `lX1` — the honest `a < u' < b` configuration (σ's `lUW` witness `u'`
    below τ's anchor `b = x1_τ`) — the single-level merge key places `.lUW σ` BEFORE `.lX1 τ`.
    Region rank is no longer primary: a region-2 slot precedes a foreign region-1 slot. Under any
    2-level region-primary key (339) this is impossible, since region 1 < region 2 always forces
    `.lX1 τ` first regardless of owner data (report 06 Experiment C rank-independence). -/
example {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ τ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
    (wo : KvE2SepWeakOrder sig)
    (hlt : kvE2SepSlotGIdx wo (.lUW σ χ) < kvE2SepSlotGIdx wo (.lX1 τ)) :
    kvE2SepSlotMergeLe wo (.lUW σ χ) (.lX1 τ) = true := by
  simp only [kvE2SepSlotMergeLe, decide_eq_true_eq]
  omega

/-- **Same-owner region monotonicity of the global index**: whenever an owner's index
    tuple extends its region order (`i₀ < i₁ < i₂`, the `kvE2SepDisjValid` consistency conjunct),
    the global index is strictly increasing in region rank, so the merge keeps each owner's own
    slots in `lXU < lX1 < lUW` order (preserving the same-owner `rank<rank ⟹ index<index` fact the
    ⇒-extraction consumes). Here shown for σ's `lX1` (region 1) below `lUW` (region 2). -/
example {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1)
    (wo : KvE2SepWeakOrder sig)
    (hlt : kvE2SepSlotGIdx wo (.lX1 σ) < kvE2SepSlotGIdx wo (.lUW σ χ)) :
    kvE2SepSlotMergeLe wo (.lX1 σ) (.lUW σ χ) = true := by
  simp only [kvE2SepSlotMergeLe, decide_eq_true_eq]
  omega

end FormalSystem.Metalogic.WeakCanonical.Kamp
