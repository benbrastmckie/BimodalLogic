/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate
import FormalSystem.Metalogic.WeakCanonical.Kamp.ExteriorNegationPast

/-! # Adjacent Exterior Brackets + Enriched Composed Gate

Rabinovich 2014, Def 7.5 (p.13) / Lemma 7.10 (p.15) shapes over the landed one-sided
complement clause families (Phases 3-6), composed with the landed interior gate
`bracketEndChar_kvE2` (OuterGate.lean:70) by the DEGENERATE Lemma 7.6 (p.14) adjacency:
the exterior arrangements `x1 < x` / `x1 > t` belong to the ADJACENT intervals
`(-inf, x)` / `(t, inf)`, each with its own bracket, and the composition at the shared
free anchors `x, t` is plain conjunction (no new seam existential at the k=2 rung —
settled design, 347 adjudication verdict (b)).

## Deliverables

1. **Marking predicates** `kvE2_futMarked` / `kvE2_pastMarked` — the syntactic,
   model-independent per-σ compatibility record against `qnf`: exterior zone marking
   (`zFutT3` / `zPastX3`), base-restriction agreement (`nf0_dropFresh σ.1 = qnf.1`), and
   the six interior/boundary zone-bit agreements against `kvE2_futAnyBit qnf` (the exact
   `hbase`/`hbits` inventory of the per-side `_complete` lemmas, Phases 4/6 — the
   symmetric per-side hypothesis inventories threaded per the Phase-6 handoff).
2. **Adjacent exterior brackets** `kvE2_extBracketFut` / `kvE2_extBracketPast`
   (Def 7.5 p.13): conjunction over marked σ — bit-true σ contribute the positive
   `Until`/`Since`-navigated local-existence clause (`kvE2_futPos` / `kvE2_pastPos`,
   Lemma 7.10 p.15); bit-false σ contribute the complement clause
   (`kvE2_extNegFut` / `kvE2_extNegPast`).
3. **Per-side bridge lemmas** — the exact shapes Phase 8 consumes:
   - `kvE2_futMarked_of_realizer` / `kvE2_pastMarked_of_realizer`: an exterior realizer
     FORCES the marking (zone via the Phase-1 triage lemmas, base via the atom-layer
     restriction against `henv`, bits via the zone-4/zone-3 coupling lift against the
     `hbelow`/`habove` pin);
   - `kvE2_extBracketFut_sound` / `kvE2_extBracketPast_sound`: bracket true at its
     anchor kills EVERY bit-false σ at every exterior `x1` on its side (the `hexclExt`
     discharge shape — σ is NOT assumed marked: unmarked σ are killed because a realizer
     would force the marking);
   - `kvE2_extBracketFut_exists` / `kvE2_extBracketPast_exists`: bracket true at its
     anchor + marked bit-true σ yields an exterior realizer (the ⇒-side positive
     residue, via the per-side `_complete` contrapositive);
   - `kvE2_extBracketFut_complete` / `kvE2_extBracketPast_complete`: per-σ exterior
     facts re-establish the bracket at its anchor (the ⇐-side re-establishment, via the
     per-side `_complete` for bit-false σ and the `_sound` contrapositive for bit-true σ).
4. **Enriched composed gate** `bracketEndChar_kvE2Ext` (degenerate Lemma 7.6 p.14):
   the interior carrier with each disjunct's endpoint 1-types conjoined with the
   side-matching exterior bracket — `extBracketPast` at the LEFT anchor `x`,
   `extBracketFut` at the RIGHT anchor `t` — plus the anchor-semantics bridge
   `bracketEndChar_kvE2Ext_holds_iff` (`holds ↔ interior holds ∧ bracketPast @ x ∧
   bracketFut @ t`).

All per-side `_sound`/`_complete` lemmas (ExteriorNegation.lean:1243/:1484,
ExteriorNegationPast.lean:581/:855) are CALLED, never re-proved (H7: those files are
read-only territory; the two small zone-coupling lifts they keep `private` are mirrored
here file-locally, the sanctioned Phase-5/6 porting pattern).

Purely additive leaf module (H7 territory: this file + additive import wiring only). -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation

/-- `ZoneSpec n` equality is decidable (file-local mirror of the private SW:61 bridge). -/
private instance {n : Nat} : DecidableEq (ZoneSpec n) :=
  -- `inferInstanceAs`, not `decidable_of_iff (∀ i, a i = b i) …`: the latter needs
  -- `Decidable (∀ i : Fin n, a i = b i)`, which instance search cannot build without
  -- unfolding the semireducible `ZoneSpec`. Naming the unfolded type sidesteps that.
  inferInstanceAs (DecidableEq (Fin n → Bool × Bool))

/-- Classical conjunction reading of the encoded `Formula.and` (file-local; the encoding
    is `(φ.imp ψ.neg).neg`, so both directions are a double-negation shuffle). -/
private theorem temporal_truth_and_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (u : M.carrier) (φ ψ : Formula) :
    TemporalTruth M atomMap u (Formula.and φ ψ) ↔
      (TemporalTruth M atomMap u φ ∧ TemporalTruth M atomMap u ψ) := by
  simp only [Formula.and, Formula.neg, TemporalTruth]
  constructor
  · intro h
    constructor
    · by_contra hφ
      exact h fun hφ' _ => absurd hφ' hφ
    · by_contra hψ
      exact h fun _ hψ' => absurd hψ' hψ
  · rintro ⟨hφ, hψ⟩ h
    exact h hφ hψ

/-! ## The six per-side interior/boundary zone lists (the `hbits` index sets)

Future side: the six at-or-below-`t` outer zones (Phase-4 `hbits` disjunction,
ExteriorNegation.lean:1496-1498). Past side: the six at-or-above-`x` outer zones
(Phase-6 `hbits` disjunction, ExteriorNegationPast.lean:867-869). -/

/-- The six at-or-below-`t` outer zone-3 constants (future-side `hbits` index set). -/
def kvE2FutBelowZones : List (ZoneSpec 3) :=
  [kvE2SepZPastX3, kvE2SepZAtX3, kvE2SepZXW3,
   kvE2SepZAtW3, kvE2SepZWT3, kvE2SepZAtT3]

/-- The six at-or-above-`x` outer zone-3 constants (past-side `hbits` index set). -/
def kvE2PastAboveZones : List (ZoneSpec 3) :=
  [kvE2SepZAtX3, kvE2SepZXW3, kvE2SepZAtW3,
   kvE2SepZWT3, kvE2SepZAtT3, kvE2SepZFutT3]

/-- Every future-side listed zone has third-pair second component `false` (the
    at-or-below-`t` key consumed by the `hbelow` pin and the zone-4 coupling lift). -/
theorem kvE2_futBelowZones_key :
    ∀ zs ∈ kvE2FutBelowZones, (zs ⟨2, by omega⟩).2 = false := by
  intro zs hzs
  simp only [kvE2FutBelowZones, List.mem_cons, List.not_mem_nil, or_false] at hzs
  rcases hzs with rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-- Every past-side listed zone has second-pair first component `false` (the
    at-or-above-`x` key consumed by the `habove` pin and the zone-4 coupling lift). -/
theorem kvE2_pastAboveZones_key :
    ∀ zs ∈ kvE2PastAboveZones, (zs ⟨1, by omega⟩).1 = false := by
  intro zs hzs
  simp only [kvE2PastAboveZones, List.mem_cons, List.not_mem_nil, or_false] at hzs
  rcases hzs with rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-! ## Marking predicates (the per-σ `hbase`/`hbits` inventory, syntactic) -/

/-- **Future-side marking of σ against qnf** (syntactic, model-independent): `zFutT3`
    zone marking + base-restriction agreement + the six at-or-below-`t` zone-bit
    agreements against `kvE2_futAnyBit qnf` — exactly the `hbase`/`hbits` hypotheses of
    `kvE2_extNegFut_complete` (Phase 4). Under the gate pins an exterior-future realizer
    FORCES this marking (`kvE2_futMarked_of_realizer`), so unmarked σ are unrealizable
    on the future side and are legitimately absent from the bracket conjunction. -/
noncomputable def kvE2FutMarked {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4) : Bool :=
  decide (nf0ZoneSpec σ.1 = kvE2SepZFutT3) &&
  decide (nf0DropFresh (show NormalForm sig 0 4 from σ.1) =
    show NormalForm sig 0 3 from qnf.1) &&
  (kvE2FutBelowZones.all fun zs =>
    (Finset.univ.toList (α := NormalForm sig 0 1)).all fun χ =>
      decide (σ.2 (nf0Assemble (Fin.cons (true, false) zs) χ σ.1) =
        kvE2FutAnyBit qnf zs χ))

/-- **Past-side marking of σ against qnf** (mirror): `zPastX3` zone marking +
    base-restriction agreement + the six at-or-above-`x` zone-bit agreements
    (coupling `(false, true)`) — exactly the `hbase`/`hbits` hypotheses of
    `kvE2_extNegPast_complete` (Phase 6). -/
noncomputable def kvE2PastMarked {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4) : Bool :=
  decide (nf0ZoneSpec σ.1 = kvE2SepZPastX3) &&
  decide (nf0DropFresh (show NormalForm sig 0 4 from σ.1) =
    show NormalForm sig 0 3 from qnf.1) &&
  (kvE2PastAboveZones.all fun zs =>
    (Finset.univ.toList (α := NormalForm sig 0 1)).all fun χ =>
      decide (σ.2 (nf0Assemble (Fin.cons (false, true) zs) χ σ.1) =
        kvE2FutAnyBit qnf zs χ))

/-- Unpack the future-side marking into its three Prop components. -/
theorem kvE2_futMarked_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4) :
    kvE2FutMarked qnf σ = true ↔
      (nf0ZoneSpec σ.1 = kvE2SepZFutT3 ∧
       nf0DropFresh σ.1 = qnf.1 ∧
       ∀ zs ∈ kvE2FutBelowZones, ∀ χ : NormalForm sig 0 1,
         σ.2 (nf0Assemble (Fin.cons (true, false) zs) χ σ.1) =
           kvE2FutAnyBit qnf zs χ) := by
  simp only [kvE2FutMarked, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true]
  constructor
  · rintro ⟨⟨h1, h2⟩, h3⟩
    exact ⟨h1, h2, fun zs hzs χ =>
      h3 zs hzs χ (Finset.mem_toList.mpr (Finset.mem_univ χ))⟩
  · rintro ⟨h1, h2, h3⟩
    exact ⟨⟨h1, h2⟩, fun zs hzs χ _ => h3 zs hzs χ⟩

/-- Unpack the past-side marking into its three Prop components. -/
theorem kvE2_pastMarked_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4) :
    kvE2PastMarked qnf σ = true ↔
      (nf0ZoneSpec σ.1 = kvE2SepZPastX3 ∧
       nf0DropFresh σ.1 = qnf.1 ∧
       ∀ zs ∈ kvE2PastAboveZones, ∀ χ : NormalForm sig 0 1,
         σ.2 (nf0Assemble (Fin.cons (false, true) zs) χ σ.1) =
           kvE2FutAnyBit qnf zs χ) := by
  simp only [kvE2PastMarked, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true]
  constructor
  · rintro ⟨⟨h1, h2⟩, h3⟩
    exact ⟨h1, h2, fun zs hzs χ =>
      h3 zs hzs χ (Finset.mem_toList.mpr (Finset.mem_univ χ))⟩
  · rintro ⟨h1, h2, h3⟩
    exact ⟨⟨h1, h2⟩, fun zs hzs χ _ => h3 zs hzs χ⟩

/-! ## Zone-4 / zone-3 coupling lifts (file-local mirrors of the private
`kvE2_futZone4_below_iff` / `kvE2_pastZone4_above_iff`, ExteriorNegation.lean:344 /
ExteriorNegationPast.lean:697 — the sanctioned Phase-5/6 private-mirror porting pattern) -/

/-- An at-or-below-`t` zone-3 witness sits below any `x1 > t` (mirror of the private
    ExteriorNegation.lean:332). -/
private theorem extBk_futBelow_le_t {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (zs : ZoneSpec 3) (hz3 : (zs ⟨2, by omega⟩).2 = false) (v : M.carrier)
    (hzone : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v) :
    v ≤ t := by
  have h := (hzone ⟨2, by omega⟩).2
  rw [hz3] at h
  by_contra hc
  exact absurd (h.mp (not_le.mp hc)) Bool.false_ne_true

/-- Lift an at-or-below-`t` zone-3 fact to the corresponding zone-4 fact (coupling
    `(true, false)` to a fresh `x1 > t`), and back (mirror of the private
    ExteriorNegation.lean:344). -/
private theorem extBk_futZone4_below_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier) (htx1 : t < x1)
    (zs : ZoneSpec 3) (hz3 : (zs ⟨2, by omega⟩).2 = false) (v : M.carrier) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        (Fin.cons (true, false) zs) v ↔
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v := by
  constructor
  · intro h i
    have := h i.succ
    exact this
  · intro h i
    match i with
    | ⟨0, _⟩ =>
      have hle := (extBk_futBelow_le_t M w x t zs hz3 v h).trans_lt htx1
      exact ⟨iff_of_true hle rfl, iff_of_false (lt_asymm hle) Bool.false_ne_true⟩
    | ⟨1, _⟩ => exact h ⟨0, by omega⟩
    | ⟨2, _⟩ => exact h ⟨1, by omega⟩
    | ⟨3, _⟩ => exact h ⟨2, by omega⟩

/-- An at-or-above-`x` zone-3 witness sits above any `x1 < x` (mirror of the private
    ExteriorNegationPast.lean:684). -/
private theorem extBk_pastAbove_ge_x {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (zs : ZoneSpec 3) (hz1 : (zs ⟨1, by omega⟩).1 = false) (v : M.carrier)
    (hzone : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v) :
    x ≤ v := by
  have h := (hzone ⟨1, by omega⟩).1
  rw [hz1] at h
  by_contra hc
  exact absurd (h.mp (not_le.mp hc)) Bool.false_ne_true

/-- Lift an at-or-above-`x` zone-3 fact to the corresponding zone-4 fact (coupling
    `(false, true)` to a fresh `x1 < x`), and back (mirror of the private
    ExteriorNegationPast.lean:697). -/
private theorem extBk_pastZone4_above_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier) (hx1x : x1 < x)
    (zs : ZoneSpec 3) (hz1 : (zs ⟨1, by omega⟩).1 = false) (v : M.carrier) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        (Fin.cons (false, true) zs) v ↔
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v := by
  constructor
  · intro h i
    have := h i.succ
    exact this
  · intro h i
    match i with
    | ⟨0, _⟩ =>
      have hlt := hx1x.trans_le (extBk_pastAbove_ge_x M w x t zs hz1 v h)
      exact ⟨iff_of_false (lt_asymm hlt) Bool.false_ne_true, iff_of_true hlt rfl⟩
    | ⟨1, _⟩ => exact h ⟨0, by omega⟩
    | ⟨2, _⟩ => exact h ⟨1, by omega⟩
    | ⟨3, _⟩ => exact h ⟨2, by omega⟩

/-! ## Realizer-forces-marking bridges -/

/-- **Base agreement is forced by any realizer** (side-neutral: `x1` arbitrary): a σ
    realized over `[x1, w, x, t]` in an `henv`-pinned model has its `[w, x, t]`
    base restriction equal to `qnf.1` — the atom layer of the realizer reads the same
    order/predicate facts `henv` pins to `qnf.1`. -/
theorem kvE2_extBase_of_realizer {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier)
    (henv : ∀ a : AtomKind sig 3,
      AtomEval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hnf : NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    nf0DropFresh σ.1 = qnf.1 := by
  obtain ⟨hatomσ, -⟩ := hnf
  have hskip : ∀ k : Fin 3,
      (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))) : Fin 4 → M.carrier)
          (skipFin ⟨0, Nat.succ_pos 3⟩ k) =
        (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) k := by
    intro k
    rw [skipFin_zero_succ, Fin.cons_succ]
  funext a
  match a with
  | .pred p k =>
    have h4 := hatomσ (.pred p (skipFin ⟨0, Nat.succ_pos 3⟩ k))
    have h3 := henv (.pred p k)
    simp only [AtomEval] at h4 h3
    rw [hskip k] at h4
    exact Bool.eq_iff_iff.mpr (h4.symm.trans h3)
  | .order k1 k2 hne =>
    have h4 := hatomσ (.order (skipFin ⟨0, Nat.succ_pos 3⟩ k1)
      (skipFin ⟨0, Nat.succ_pos 3⟩ k2) ((skipFin_injective _).ne hne))
    have h3 := henv (.order k1 k2 hne)
    simp only [AtomEval] at h4 h3
    rw [hskip k1, hskip k2] at h4
    exact Bool.eq_iff_iff.mpr (h4.symm.trans h3)

/-- **A future-side exterior realizer forces the future marking**: under the gate pins
    (`hxw`, `hwt`, `henv`, `hbelow`), any σ realized at some `x1 > t` satisfies
    `kvE2_futMarked qnf σ = true` — zone via the Phase-1 zone determination, base via
    `kvE2_extBase_of_realizer`, bits via the zone-4/zone-3 coupling lift against
    `hbelow`. This is what lets the bracket conjunction range over marked σ ONLY. -/
theorem kvE2_futMarked_of_realizer {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (henv : ∀ a : AtomKind sig 3,
      AtomEval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨2, by omega⟩).2 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          NfEvalNf M 0 1 (fun _ => v) χ) ↔ kvE2FutAnyBit qnf zs χ = true))
    (hnf : NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    kvE2FutMarked qnf σ = true := by
  obtain ⟨-, hquantσ, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hnf
  refine (kvE2_futMarked_iff qnf σ).mpr
    ⟨kvE2_exterior_zone_determination_fut M x1 w x t σ hxw hwt htx1 hnf,
     kvE2_extBase_of_realizer M qnf σ x1 w x t henv hnf, ?_⟩
  intro zs hzs χ
  have hkey := kvE2_futBelowZones_key zs hzs
  have hlift : (∃ v : M.carrier,
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        (Fin.cons (true, false) zs) v ∧ NfEvalNf M 0 1 (fun _ => v) χ) ↔
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
        NfEvalNf M 0 1 (fun _ => v) χ) :=
    exists_congr fun v =>
      and_congr_left' (extBk_futZone4_below_iff M x1 w x t htx1 zs hkey v)
  exact Bool.eq_iff_iff.mpr
    ((hquantσ (Fin.cons (true, false) zs) χ).symm.trans
      (hlift.trans (hbelow zs χ hkey)))

/-- **A past-side exterior realizer forces the past marking** (mirror): any σ realized
    at some `x1 < x` under the pins (`hxw`, `hwt`, `henv`, `habove`) satisfies
    `kvE2_pastMarked qnf σ = true`. -/
theorem kvE2_pastMarked_of_realizer {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (hx1x : x1 < x)
    (henv : ∀ a : AtomKind sig 3,
      AtomEval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (habove : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨1, by omega⟩).1 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          NfEvalNf M 0 1 (fun _ => v) χ) ↔ kvE2FutAnyBit qnf zs χ = true))
    (hnf : NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    kvE2PastMarked qnf σ = true := by
  obtain ⟨-, hquantσ, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hnf
  refine (kvE2_pastMarked_iff qnf σ).mpr
    ⟨kvE2_exterior_zone_determination_past M x1 w x t σ hxw hwt hx1x hnf,
     kvE2_extBase_of_realizer M qnf σ x1 w x t henv hnf, ?_⟩
  intro zs hzs χ
  have hkey := kvE2_pastAboveZones_key zs hzs
  have hlift : (∃ v : M.carrier,
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        (Fin.cons (false, true) zs) v ∧ NfEvalNf M 0 1 (fun _ => v) χ) ↔
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
        NfEvalNf M 0 1 (fun _ => v) χ) :=
    exists_congr fun v =>
      and_congr_left' (extBk_pastZone4_above_iff M x1 w x t hx1x zs hkey v)
  exact Bool.eq_iff_iff.mpr
    ((hquantσ (Fin.cons (false, true) zs) χ).symm.trans
      (hlift.trans (habove zs χ hkey)))

/-! ## The adjacent exterior brackets (Def 7.5 p.13) -/

/-- **Future-side adjacent exterior bracket** (Def 7.5 p.13, anchored at `t` over the
    adjacent interval `(t, ∞)`): the conjunction over `kvE2_futMarked`-marked σ of the
    positive `Until`-navigated local-existence clause `kvE2_futPos σ` (Lemma 7.10 p.15)
    when qnf's bit is true, and of the complement clause `kvE2_extNegFut σ` when the
    bit is false. -/
noncomputable def kvE2ExtBracketFut {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) : Formula :=
  formulaConjList
    (((Finset.univ.toList (α := NormalForm sig 1 4)).filter (kvE2FutMarked qnf)).map
      fun σ =>
        if qnf.2 σ = true then kvE2FutPos atomMap h_surj σ
        else kvE2ExtNegFut atomMap h_surj σ)

/-- **Past-side adjacent exterior bracket** (mirror, anchored at `x` over the adjacent
    interval `(-∞, x)`): `Since`-navigated existence clause `kvE2_pastPos σ` for
    bit-true marked σ, complement clause `kvE2_extNegPast σ` for bit-false marked σ. -/
noncomputable def kvE2ExtBracketPast {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) : Formula :=
  formulaConjList
    (((Finset.univ.toList (α := NormalForm sig 1 4)).filter (kvE2PastMarked qnf)).map
      fun σ =>
        if qnf.2 σ = true then kvE2PastPos atomMap h_surj σ
        else kvE2ExtNegPast atomMap h_surj σ)

/-- Bracket-at-anchor unfolds to the per-σ clause conjunction (future side, pure
    formula-level bridge — no pins). -/
theorem kvE2_extBracketFut_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) (t : M.carrier) :
    TemporalTruth M atomMap t (kvE2ExtBracketFut atomMap h_surj qnf) ↔
      ∀ σ : NormalForm sig 1 4, kvE2FutMarked qnf σ = true →
        TemporalTruth M atomMap t
          (if qnf.2 σ = true then kvE2FutPos atomMap h_surj σ
           else kvE2ExtNegFut atomMap h_surj σ) := by
  rw [kvE2ExtBracketFut, formula_conjList_iff]
  constructor
  · intro h σ hm
    exact h _ (List.mem_map.mpr ⟨σ, List.mem_filter.mpr
      ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hm⟩, rfl⟩)
  · intro h f hf
    obtain ⟨σ, hσmem, rfl⟩ := List.mem_map.mp hf
    exact h σ (List.mem_filter.mp hσmem).2

/-- Bracket-at-anchor unfolds to the per-σ clause conjunction (past side). -/
theorem kvE2_extBracketPast_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) (x : M.carrier) :
    TemporalTruth M atomMap x (kvE2ExtBracketPast atomMap h_surj qnf) ↔
      ∀ σ : NormalForm sig 1 4, kvE2PastMarked qnf σ = true →
        TemporalTruth M atomMap x
          (if qnf.2 σ = true then kvE2PastPos atomMap h_surj σ
           else kvE2ExtNegPast atomMap h_surj σ) := by
  rw [kvE2ExtBracketPast, formula_conjList_iff]
  constructor
  · intro h σ hm
    exact h _ (List.mem_map.mpr ⟨σ, List.mem_filter.mpr
      ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hm⟩, rfl⟩)
  · intro h f hf
    obtain ⟨σ, hσmem, rfl⟩ := List.mem_map.mp hf
    exact h σ (List.mem_filter.mp hσmem).2

/-! ## Composed per-side soundness (the `hexclExt` discharge shape) -/

/-- **Future-side bracket soundness** (the shape Phase 8 feeds the `hexclExt`
    residue): the bracket true at `t` kills EVERY bit-false σ at every `x1 > t` —
    σ is NOT assumed marked, since a realizer would force the marking
    (`kvE2_futMarked_of_realizer`) and then `kvE2_extNegFut_sound` refutes it. -/
theorem kvE2_extBracketFut_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      AtomEval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨2, by omega⟩).2 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          NfEvalNf M 0 1 (fun _ => v) χ) ↔ kvE2FutAnyBit qnf zs χ = true))
    (hcl : TemporalTruth M atomMap t (kvE2ExtBracketFut atomMap h_surj qnf)) :
    ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
      ∀ x1 : M.carrier, t < x1 →
        ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro σ hbit x1 htx1 hnf
  have hm := kvE2_futMarked_of_realizer M qnf σ x1 w x t hxw hwt htx1 henv hbelow hnf
  have hneg : TemporalTruth M atomMap t (kvE2ExtNegFut atomMap h_surj σ) := by
    have h := (kvE2_extBracketFut_iff M atomMap h_surj qnf t).mp hcl σ hm
    rwa [if_neg (by simp [hbit])] at h
  exact kvE2_extNegFut_sound M atomMap h_surj σ w x t hxw hwt hneg x1 htx1 hnf

/-- **Past-side bracket soundness** (mirror): the bracket true at `x` kills every
    bit-false σ at every `x1 < x`. -/
theorem kvE2_extBracketPast_sound {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      AtomEval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (habove : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨1, by omega⟩).1 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          NfEvalNf M 0 1 (fun _ => v) χ) ↔ kvE2FutAnyBit qnf zs χ = true))
    (hcl : TemporalTruth M atomMap x (kvE2ExtBracketPast atomMap h_surj qnf)) :
    ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
      ∀ x1 : M.carrier, x1 < x →
        ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro σ hbit x1 hx1x hnf
  have hm := kvE2_pastMarked_of_realizer M qnf σ x1 w x t hxw hwt hx1x henv habove hnf
  have hneg : TemporalTruth M atomMap x (kvE2ExtNegPast atomMap h_surj σ) := by
    have h := (kvE2_extBracketPast_iff M atomMap h_surj qnf x).mp hcl σ hm
    rwa [if_neg (by simp [hbit])] at h
  exact kvE2_extNegPast_sound M atomMap h_surj σ w x t hxw hwt hneg x1 hx1x hnf

/-! ## Composed per-side positive-existence extraction (the ⇒-side positive residue) -/

/-- **Future-side existence extraction**: bracket true at `t` + marked bit-true σ
    yields an exterior realizer `x1 > t` — the `kvE2_extNegFut_complete` contrapositive
    under the marking's own `hbase`/`hbits` components. -/
theorem kvE2_extBracketFut_exists {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      AtomEval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨2, by omega⟩).2 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          NfEvalNf M 0 1 (fun _ => v) χ) ↔ kvE2FutAnyBit qnf zs χ = true))
    (hcl : TemporalTruth M atomMap t (kvE2ExtBracketFut atomMap h_surj qnf))
    (σ : NormalForm sig 1 4)
    (hm : kvE2FutMarked qnf σ = true) (hbit : qnf.2 σ = true) :
    ∃ x1 : M.carrier, t < x1 ∧
      NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨-, hbase, hb⟩ := (kvE2_futMarked_iff qnf σ).mp hm
  have hPos : TemporalTruth M atomMap t (kvE2FutPos atomMap h_surj σ) := by
    have h := (kvE2_extBracketFut_iff M atomMap h_surj qnf t).mp hcl σ hm
    rwa [if_pos hbit] at h
  by_contra hno
  push Not at hno
  exact kvE2_extNegFut_complete M atomMap h_surj qnf σ w x t hxw hwt henv hbelow hbase
    (fun zs χ hd => by
      rcases hd with rfl | rfl | rfl | rfl | rfl | rfl <;>
        exact hb _ (by simp [kvE2FutBelowZones]) χ)
    hno hPos

/-- **Past-side existence extraction** (mirror): bracket true at `x` + marked bit-true
    σ yields an exterior realizer `x1 < x`. -/
theorem kvE2_extBracketPast_exists {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      AtomEval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (habove : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨1, by omega⟩).1 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          NfEvalNf M 0 1 (fun _ => v) χ) ↔ kvE2FutAnyBit qnf zs χ = true))
    (hcl : TemporalTruth M atomMap x (kvE2ExtBracketPast atomMap h_surj qnf))
    (σ : NormalForm sig 1 4)
    (hm : kvE2PastMarked qnf σ = true) (hbit : qnf.2 σ = true) :
    ∃ x1 : M.carrier, x1 < x ∧
      NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨-, hbase, hb⟩ := (kvE2_pastMarked_iff qnf σ).mp hm
  have hPos : TemporalTruth M atomMap x (kvE2PastPos atomMap h_surj σ) := by
    have h := (kvE2_extBracketPast_iff M atomMap h_surj qnf x).mp hcl σ hm
    rwa [if_pos hbit] at h
  by_contra hno
  push Not at hno
  exact kvE2_extNegPast_complete M atomMap h_surj qnf σ w x t hxw hwt henv habove hbase
    (fun zs χ hd => by
      rcases hd with rfl | rfl | rfl | rfl | rfl | rfl <;>
        exact hb _ (by simp [kvE2PastAboveZones]) χ)
    hno hPos

/-! ## Composed per-side completeness (the ⇐-side re-establishment shape) -/

/-- **Future-side bracket completeness** (the shape Phase 8's ⇐ half consumes): per-σ
    exterior facts — realizers for marked bit-true σ, no-realizer for marked bit-false
    σ — re-establish the bracket at `t`, via `kvE2_extNegFut_complete` (bit-false) and
    the `kvE2_extNegFut_sound` contrapositive (bit-true). -/
theorem kvE2_extBracketFut_complete {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      AtomEval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨2, by omega⟩).2 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          NfEvalNf M 0 1 (fun _ => v) χ) ↔ kvE2FutAnyBit qnf zs χ = true))
    (hpos : ∀ σ : NormalForm sig 1 4, kvE2FutMarked qnf σ = true → qnf.2 σ = true →
      ∃ x1 : M.carrier, t < x1 ∧
        NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hneg : ∀ σ : NormalForm sig 1 4, kvE2FutMarked qnf σ = true → qnf.2 σ = false →
      ∀ x1 : M.carrier, t < x1 →
        ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    TemporalTruth M atomMap t (kvE2ExtBracketFut atomMap h_surj qnf) := by
  refine (kvE2_extBracketFut_iff M atomMap h_surj qnf t).mpr fun σ hm => ?_
  cases hbit : qnf.2 σ with
  | true =>
    rw [if_pos rfl]
    obtain ⟨x1, htx1, hreal⟩ := hpos σ hm hbit
    by_contra hno
    exact kvE2_extNegFut_sound M atomMap h_surj σ w x t hxw hwt hno x1 htx1 hreal
  | false =>
    rw [if_neg (by simp)]
    obtain ⟨-, hbase, hb⟩ := (kvE2_futMarked_iff qnf σ).mp hm
    exact kvE2_extNegFut_complete M atomMap h_surj qnf σ w x t hxw hwt henv hbelow hbase
      (fun zs χ hd => by
        rcases hd with rfl | rfl | rfl | rfl | rfl | rfl <;>
          exact hb _ (by simp [kvE2FutBelowZones]) χ)
      (hneg σ hm hbit)

/-- **Past-side bracket completeness** (mirror): per-σ exterior facts re-establish the
    bracket at `x`. -/
theorem kvE2_extBracketPast_complete {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      AtomEval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (habove : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨1, by omega⟩).1 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          NfEvalNf M 0 1 (fun _ => v) χ) ↔ kvE2FutAnyBit qnf zs χ = true))
    (hpos : ∀ σ : NormalForm sig 1 4, kvE2PastMarked qnf σ = true → qnf.2 σ = true →
      ∃ x1 : M.carrier, x1 < x ∧
        NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hneg : ∀ σ : NormalForm sig 1 4, kvE2PastMarked qnf σ = true → qnf.2 σ = false →
      ∀ x1 : M.carrier, x1 < x →
        ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    TemporalTruth M atomMap x (kvE2ExtBracketPast atomMap h_surj qnf) := by
  refine (kvE2_extBracketPast_iff M atomMap h_surj qnf x).mpr fun σ hm => ?_
  cases hbit : qnf.2 σ with
  | true =>
    rw [if_pos rfl]
    obtain ⟨x1, hx1x, hreal⟩ := hpos σ hm hbit
    by_contra hno
    exact kvE2_extNegPast_sound M atomMap h_surj σ w x t hxw hwt hno x1 hx1x hreal
  | false =>
    rw [if_neg (by simp)]
    obtain ⟨-, hbase, hb⟩ := (kvE2_pastMarked_iff qnf σ).mp hm
    exact kvE2_extNegPast_complete M atomMap h_surj qnf σ w x t hxw hwt henv habove hbase
      (fun zs χ hd => by
        rcases hd with rfl | rfl | rfl | rfl | rfl | rfl <;>
          exact hb _ (by simp [kvE2PastAboveZones]) χ)
      (hneg σ hm hbit)

/-! ## The enriched composed gate (degenerate Lemma 7.6 p.14 at the anchors `x, t`) -/

/-- Conjoin fixed endpoint enrichments onto every disjunct of a `VVecEA2`: `pL` at the
    LEFT anchor (`z0`), `pR` at the RIGHT anchor (`z1`). The Lemma 7.6 (p.14) adjacency
    composition DEGENERATES to this endpoint conjunction at the shared free anchors —
    no new seam existential. -/
def VVecEA2.enrichEndpoints (v : VVecEA2) (pL pR : Formula) : VVecEA2 :=
  ⟨v.disjuncts.map fun d =>
    ⟨d.1, { d.2 with
      endpointLeft := d.2.endpointLeft.conj ⟨pL⟩,
      endpointRight := d.2.endpointRight.conj ⟨pR⟩ }⟩⟩

/-- Enrichment semantics: the enriched formula holds iff the original holds AND the two
    endpoint enrichments hold at their anchors (the enrichments are disjunct-independent,
    so they factor out of the disjunction). -/
theorem VVecEA2.enrichEndpoints_holds {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2) (pL pR : Formula) (z0 z1 : M.carrier) :
    (v.enrichEndpoints pL pR).holds M atomMap z0 z1 ↔
      (v.holds M atomMap z0 z1 ∧
       TemporalTruth M atomMap z0 pL ∧ TemporalTruth M atomMap z1 pR) := by
  constructor
  · rintro ⟨vea', hmem', hh⟩
    obtain ⟨d, hd, rfl⟩ := List.mem_map.mp hmem'
    obtain ⟨hL, hR, hb⟩ := hh
    -- the enriched endpoint 1-types read as conjunctions (defeq through the structure
    -- update projections; `rw` cannot see through the mapped literal, applications can)
    have hL' := (temporal_truth_and_iff M atomMap z0 d.2.endpointLeft.formula pL).mp hL
    have hR' := (temporal_truth_and_iff M atomMap z1 d.2.endpointRight.formula pR).mp hR
    exact ⟨⟨d, hd, hL'.1, hR'.1, hb⟩, hL'.2, hR'.2⟩
  · rintro ⟨⟨d, hd, hL, hR, hb⟩, hpL, hpR⟩
    exact ⟨_, List.mem_map.mpr ⟨d, hd, rfl⟩,
      (temporal_truth_and_iff M atomMap z0 d.2.endpointLeft.formula pL).mpr ⟨hL, hpL⟩,
      (temporal_truth_and_iff M atomMap z1 d.2.endpointRight.formula pR).mpr ⟨hR, hpR⟩,
      hb⟩

/-- **The enriched composed gate** (Def 7.5 p.13 + degenerate
    Lemma 7.6 p.14): the landed interior gate `bracketEndChar_kvE2` (OuterGate.lean:70,
    a verified INPUT — applied, never re-proved) with the past-side adjacent bracket
    conjoined at the LEFT anchor `x` and the future-side adjacent bracket conjoined at
    the RIGHT anchor `t`. Phase 8's discharge theorem
    `bracketEndChar_kvE2Ext_correct_two_prior_frag` states the gate biconditional for
    THIS carrier, with `hexclExt` discharged internally by the per-side bracket
    soundness above. -/
noncomputable def bracketEndCharKvE2Ext {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1) :
    BracketEndCharCarrierV sig 2 :=
  fun qnf =>
    (bracketEndCharKvE2 atomMap h_surj P qnf).enrichEndpoints
      (kvE2ExtBracketPast atomMap h_surj qnf)
      (kvE2ExtBracketFut atomMap h_surj qnf)

/-- **Anchor-semantics bridge for the enriched gate** (the degenerate Lemma 7.6
    conjunction, exposed): the enriched gate holds at `(x, t)` iff the interior gate
    holds AND the past bracket is true at `x` AND the future bracket is true at `t`. -/
theorem bracketEndChar_kvE2Ext_holds_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndCharKvE2Ext atomMap h_surj P qnf).holds M atomMap x t ↔
      ((bracketEndCharKvE2 atomMap h_surj P qnf).holds M atomMap x t ∧
       TemporalTruth M atomMap x (kvE2ExtBracketPast atomMap h_surj qnf) ∧
       TemporalTruth M atomMap t (kvE2ExtBracketFut atomMap h_surj qnf)) :=
  VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t

/-! ## Phase 8 — gate-level pin derivations + the discharge theorem

The `hexclExt` residue is discharged INTERNALLY: at the SW:12788-shaped site (inside the
`hexclExt` lambda fed to the landed interior gate) the per-side bracket soundness lemmas
need the pins `henv` and `hbelow`/`habove`. These are derived here from the gate-level
inventory only —

- `kvE2_extGate_henv`: pred parts from the `EpL`/`EpR`/`ptW` endpoint 1-type heads
  (`kvE2_sepProj3` projections), order parts from `hxw`/`hwt` + the six qnf order-bit
  hypotheses (the recorded Phase-2 derivation obligation, ExteriorNegation.lean:43-47);
- `kvE2_extGate_anyBit_iff`: the UNRESTRICTED zone-fact biconditional (it subsumes both
  the at-or-below-`t` `hbelow` and the at-or-above-`x` `habove` keys). Forward: a zone
  witness in the closed cone rides `hexcl` on its own depth-1 characteristic; a witness
  below `x` / above `t` rides the interior gate's own `zPastX3` `Since` / `zFutT3`
  `Until` endpoint literal (`kvE2_sepHasPos` channel) bridged to the depth-0
  `kvE2_futAnyBit` channel through a `hrealB` realizer + `nf_eval_unique`. Backward:
  every positive σ' is realized (`hrealI` interior / `hrealB` otherwise) and the
  realizer reads back zone and profile from σ'.1's atom layer
  (the `kvE2_futAnyBit_correct` backward block, realizers now provider-supplied). -/

/-- `zPastX3` is not an interior zone (index-1 pair `(true, false)` vs `(false, true)`). -/
private theorem extDis_zPastX3_not_interior :
    ¬ (kvE2SepZPastX3 = kvE2SepZXW3 ∨ kvE2SepZPastX3 = kvE2SepZWT3) := by
  rintro (h | h) <;> exact absurd (congrFun h ⟨1, by omega⟩) (by decide)

/-- `zFutT3` is not an interior zone (index-2 pair `(false, true)` vs `(true, false)`). -/
private theorem extDis_zFutT3_not_interior :
    ¬ (kvE2SepZFutT3 = kvE2SepZXW3 ∨ kvE2SepZFutT3 = kvE2SepZWT3) := by
  rintro (h | h) <;> exact absurd (congrFun h ⟨2, by omega⟩) (by decide)

/-- **The `henv` pin from the gate inventory** (the SW:12788-site derivation recorded at
    ExteriorNegation.lean:43-47): predicate parts from the three `kvE2_sepProj3` head
    conjuncts of `ptW`/`EpL`/`EpR`, order parts from `hxw`/`hwt` + the six qnf order-bit
    hypotheses. Body copied from the `kvE2_outer_fold_frag` atom-layer block
    (SW:12718-12775) — same inventory, exposed as a standalone pin. -/
private theorem kvE2_extGate_henv {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (x t w : M.carrier) (hxw : x < w) (hwt : w < t)
    (hEpL : (kvE2SepEpL (nfDepth0CharFormula atomMap h_surj)
      (fun χ => P.existF 0 χ) qnf).EvalAt M atomMap x)
    (hEpR : (kvE2SepEpR (nfDepth0CharFormula atomMap h_surj)
      (fun χ => P.existF 0 χ) qnf).EvalAt M atomMap t)
    (hptW : (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj)
      (fun χ => P.existF 0 χ) qnf).EvalAt M atomMap w) :
    ∀ a : AtomKind sig 3,
      AtomEval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true := by
  have hprojW : NfEvalNf M 0 1 (fun _ => w) (kvE2SepProj3 qnf.1 ⟨0, by omega⟩) := by
    have h1 := hptW
    simp only [kvE2SepPtW, TemporalPred.EvalAt] at h1
    exact (nfPred_correct M atomMap h_surj _ w).mp
      ((formula_conjList_iff M atomMap w _).mp h1 _ List.mem_cons_self)
  have hprojX : NfEvalNf M 0 1 (fun _ => x) (kvE2SepProj3 qnf.1 ⟨1, by omega⟩) := by
    have h1 := hEpL
    simp only [kvE2SepEpL, TemporalPred.EvalAt] at h1
    exact (nfPred_correct M atomMap h_surj _ x).mp
      ((formula_conjList_iff M atomMap x _).mp h1 _ List.mem_cons_self)
  have hprojT : NfEvalNf M 0 1 (fun _ => t) (kvE2SepProj3 qnf.1 ⟨2, by omega⟩) := by
    have h1 := hEpR
    simp only [kvE2SepEpR, TemporalPred.EvalAt] at h1
    exact (nfPred_correct M atomMap h_surj _ t).mp
      ((formula_conjList_iff M atomMap t _).mp h1 _ List.mem_cons_self)
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    have h1 := hprojW (.pred p ⟨0, by omega⟩)
    exact h1
  | .pred p ⟨1, _⟩ =>
    have h1 := hprojX (.pred p ⟨0, by omega⟩)
    exact h1
  | .pred p ⟨2, _⟩ =>
    have h1 := hprojT (.pred p ⟨0, by omega⟩)
    exact h1
  | .order ⟨0, _⟩ ⟨1, _⟩ hne =>
    refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_yx.symm.trans hc))
    simp only [AtomEval]
    exact lt_asymm hxw
  | .order ⟨0, _⟩ ⟨2, _⟩ hne =>
    refine iff_of_true ?_ h_yt
    simp only [AtomEval]
    exact hwt
  | .order ⟨1, _⟩ ⟨0, _⟩ hne =>
    refine iff_of_true ?_ h_xy
    simp only [AtomEval]
    exact hxw
  | .order ⟨1, _⟩ ⟨2, _⟩ hne =>
    refine iff_of_true ?_ h_xt
    simp only [AtomEval]
    exact hxw.trans hwt
  | .order ⟨2, _⟩ ⟨0, _⟩ hne =>
    refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_ty.symm.trans hc))
    simp only [AtomEval]
    exact lt_asymm hwt
  | .order ⟨2, _⟩ ⟨1, _⟩ hne =>
    refine iff_of_false ?_ (fun hc => Bool.false_ne_true (h_tx.symm.trans hc))
    simp only [AtomEval]
    exact lt_asymm (hxw.trans hwt)
  | .order ⟨0, _⟩ ⟨0, _⟩ hne => exact absurd rfl hne
  | .order ⟨1, _⟩ ⟨1, _⟩ hne => exact absurd rfl hne
  | .order ⟨2, _⟩ ⟨2, _⟩ hne => exact absurd rfl hne

/-- **The zone-fact pin from the gate inventory** (unrestricted: subsumes both the
    `hbelow` and `habove` keys). Under the per-`w` instantiated 309-owned inventory
    (`hrealI`/`hrealB`/`hexcl` at the extracted pivot) plus the two endpoint 1-types,
    `kvE2_futAnyBit qnf` reads the TRUE depth-0 zone facts of `[w, x, t]` — the
    gate-level analogue of `kvE2_futAnyBit_correct`, with realized-qnf uses replaced by
    provider realization (backward) and by `hexcl` on characteristics / the `EpL`/`EpR`
    `kvE2_sepHasPos` literals (forward). -/
private theorem kvE2_extGate_anyBit_iff {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t w : M.carrier) (hxw : x < w) (hwt : w < t)
    (hEpL : (kvE2SepEpL (nfDepth0CharFormula atomMap h_surj)
      (fun χ => P.existF 0 χ) qnf).EvalAt M atomMap x)
    (hEpR : (kvE2SepEpR (nfDepth0CharFormula atomMap h_surj)
      (fun χ => P.existF 0 χ) qnf).EvalAt M atomMap t)
    (hrealI : ∀ σ ∈ kvE2SepPosI qnf,
      ∃ x1 : M.carrier, (x < x1 ∧ x1 < t) ∧
        NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hrealB : ∀ σ ∈ kvE2SepPos qnf,
      ¬ (nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) →
      ∃ x1 : M.carrier,
        NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
      ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
        ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (zs : ZoneSpec 3) (χ : NormalForm sig 0 1) :
    (∃ v : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
        NfEvalNf M 0 1 (fun _ => v) χ) ↔
      kvE2FutAnyBit qnf zs χ = true := by
  constructor
  · rintro ⟨v, hzv, hχv⟩
    by_cases hcone : x ≤ v ∧ v ≤ t
    · -- Cone witness: its own depth-1 characteristic is forced positive by `hexcl`.
      set σv : NormalForm sig 1 4 :=
        nfCharacteristic M 1 4 (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t)))) with hσv
      have hsat := nf_characteristic_satisfies M 1 4
        (Fin.cons v (Fin.cons w (Fin.cons x (fun _ => t))))
      have hposv : qnf.2 σv = true := by
        by_contra hne
        exact hexcl σv (Bool.eq_false_iff.mpr hne) v hcone.1 hcone.2 (hσv ▸ hsat)
      have hmem : σv ∈ kvE2SepPos qnf := by
        simp only [kvE2SepPos]
        exact List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ σv), hposv⟩
      refine List.any_eq_true.mpr ⟨σv, hmem, ?_⟩
      rw [Bool.and_eq_true]
      obtain ⟨hatom, -⟩ := hsat
      refine ⟨decide_eq_true ?_, decide_eq_true ?_⟩
      · -- ordering channel: read the couplings straight from the atom layer.
        funext i
        have hz := hzv i
        have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
        have h2 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
        change (σv.1 (.order 0 i.succ (Fin.succ_ne_zero i).symm),
              σv.1 (.order i.succ 0 (Fin.succ_ne_zero i))) = zs i
        exact Prod.ext (Bool.eq_iff_iff.mpr (h1.symm.trans hz.1))
          (Bool.eq_iff_iff.mpr (h2.symm.trans hz.2))
      · -- point-type channel: `v` satisfies both profiles, so they are equal.
        refine nf_eval_unique M 0 1 (fun _ => v) _ χ ?_ hχv
        intro a
        match a with
        | .pred p i =>
          have hi : i = 0 := Subsingleton.elim i 0
          subst hi
          exact hatom (.pred p 0)
        | .order i j hne => exact absurd (Subsingleton.elim i j) hne
    · -- Exterior witness: ride the interior gate's own `Since`/`Until` endpoint literal.
      set χ1 : NormalForm sig 1 1 := nfCharacteristic M 1 1 (fun _ => v) with hχ1
      have hχ1sat := nf_characteristic_satisfies M 1 1 (fun _ => v)
      rcases not_and_or.mp hcone with hvx | hvt
      · -- `v < x`: zone forced to `zPastX3`; `EpL`'s `Since` literal forces the
        -- `kvE2_sepHasPos` bit, whose owner is realized by `hrealB`.
        have hvx : v < x := not_le.mp hvx
        have hzs : zs = kvE2SepZPastX3 := by
          funext i
          have hvi : v < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
            match i with
            | ⟨0, _⟩ => exact hvx.trans hxw
            | ⟨1, _⟩ => exact hvx
            | ⟨2, _⟩ => exact hvx.trans (hxw.trans hwt)
          have e1 : (zs i).1 = true := (hzv i).1.mp hvi
          have e2 : (zs i).2 = false := by
            cases hc : (zs i).2 with
            | false => rfl
            | true => exact absurd ((hzv i).2.mpr hc) (lt_asymm hvi)
          have hconst : kvE2SepZPastX3 i = (true, false) := by
            match i with
            | ⟨0, _⟩ => rfl
            | ⟨1, _⟩ => rfl
            | ⟨2, _⟩ => rfl
          rw [hconst]
          exact Prod.ext e1 e2
        subst hzs
        -- Extract the `zPastX3` Since-literal for `χ1` from `EpL`.
        have h1 := hEpL
        simp only [kvE2SepEpL, TemporalPred.EvalAt] at h1
        have hlit := (formula_conjList_iff M atomMap x _).mp h1
          (kvE2SepLit (kvE2SepHasPos qnf kvE2SepZPastX3 χ1)
            (Formula.snce (P.existF 0 χ1) Formula.top))
          (List.mem_cons_of_mem _ (List.mem_append_left _ (List.mem_append_left _
            (List.mem_map.mpr ⟨χ1, Finset.mem_toList.mpr (Finset.mem_univ χ1), rfl⟩))))
        have hsnce : TemporalTruth M atomMap x (Formula.snce (P.existF 0 χ1) Formula.top) :=
          ⟨v, hvx, (bracketEndChar_kvE2_hck atomMap P M h_UZ h_SZ χ1 v).mpr (hχ1 ▸ hχ1sat),
            fun r _ _ hf => hf⟩
        cases hb : kvE2SepHasPos qnf kvE2SepZPastX3 χ1 with
        | false =>
          rw [hb] at hlit
          simp only [kvE2SepLit, Bool.false_eq_true, if_false] at hlit
          exact absurd hsnce hlit
        | true =>
          -- Owner extraction + `hrealB` realizer + profile bridge through `χ1`.
          rw [kvE2SepHasPos, List.any_eq_true] at hb
          obtain ⟨σ', hσ'mem, hproj'⟩ := hb
          have hproj' : nfkProjFresh σ' = χ1 := of_decide_eq_true hproj'
          have hzone' : nf0ZoneSpec σ'.1 = kvE2SepZPastX3 :=
            of_decide_eq_true (List.mem_filter.mp hσ'mem).2
          have hmemPos : σ' ∈ kvE2SepPos qnf := (List.mem_filter.mp hσ'mem).1
          obtain ⟨x1, hx1⟩ := hrealB σ' hmemPos
            (fun hc => extDis_zPastX3_not_interior (hzone' ▸ hc))
          have hx1χ1 : NfEvalNf M 1 1 (fun _ => x1) χ1 := by
            have := kvE2_sepProjFresh_eval M (Fin.cons w (Fin.cons x (fun _ => t))) x1 σ' hx1
            rwa [hproj'] at this
          refine List.any_eq_true.mpr ⟨σ', hmemPos, ?_⟩
          rw [Bool.and_eq_true]
          refine ⟨decide_eq_true hzone', decide_eq_true ?_⟩
          refine nf_eval_unique M 0 1 (fun _ => x1) _ χ ?_ ?_
          · intro a
            match a with
            | .pred p i =>
              have hi : i = 0 := Subsingleton.elim i 0
              subst hi
              simpa only [AtomEval, Fin.cons_zero, nf0ProjFresh] using hx1.1 (.pred p 0)
            | .order i j hne => exact absurd (Subsingleton.elim i j) hne
          · intro a
            match a with
            | .pred p i =>
              have hi : i = 0 := Subsingleton.elim i 0
              subst hi
              exact (hx1χ1.1 (.pred p 0)).trans
                (((hχ1 ▸ hχ1sat : NfEvalNf M 1 1 (fun _ => v) χ1).1
                  (.pred p 0)).symm.trans (hχv (.pred p 0)))
            | .order i j hne => exact absurd (Subsingleton.elim i j) hne
      · -- `t < v`: mirror — zone forced to `zFutT3`; `EpR`'s `Until` literal.
        have hvt : t < v := not_le.mp hvt
        have hzs : zs = kvE2SepZFutT3 := by
          funext i
          have hvi : (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < v := by
            match i with
            | ⟨0, _⟩ => exact hwt.trans hvt
            | ⟨1, _⟩ => exact (hxw.trans hwt).trans hvt
            | ⟨2, _⟩ => exact hvt
          have e2 : (zs i).2 = true := (hzv i).2.mp hvi
          have e1 : (zs i).1 = false := by
            cases hc : (zs i).1 with
            | false => rfl
            | true => exact absurd ((hzv i).1.mpr hc) (lt_asymm hvi)
          have hconst : kvE2SepZFutT3 i = (false, true) := by
            match i with
            | ⟨0, _⟩ => rfl
            | ⟨1, _⟩ => rfl
            | ⟨2, _⟩ => rfl
          rw [hconst]
          exact Prod.ext e1 e2
        subst hzs
        have h1 := hEpR
        simp only [kvE2SepEpR, TemporalPred.EvalAt] at h1
        have hlit := (formula_conjList_iff M atomMap t _).mp h1
          (kvE2SepLit (kvE2SepHasPos qnf kvE2SepZFutT3 χ1)
            (Formula.untl (P.existF 0 χ1) Formula.top))
          (List.mem_cons_of_mem _ (List.mem_append_left _ (List.mem_append_right _
            (List.mem_map.mpr ⟨χ1, Finset.mem_toList.mpr (Finset.mem_univ χ1), rfl⟩))))
        have huntl : TemporalTruth M atomMap t (Formula.untl (P.existF 0 χ1) Formula.top) :=
          ⟨v, hvt, (bracketEndChar_kvE2_hck atomMap P M h_UZ h_SZ χ1 v).mpr (hχ1 ▸ hχ1sat),
            fun r _ _ hf => hf⟩
        cases hb : kvE2SepHasPos qnf kvE2SepZFutT3 χ1 with
        | false =>
          rw [hb] at hlit
          simp only [kvE2SepLit, Bool.false_eq_true, if_false] at hlit
          exact absurd huntl hlit
        | true =>
          rw [kvE2SepHasPos, List.any_eq_true] at hb
          obtain ⟨σ', hσ'mem, hproj'⟩ := hb
          have hproj' : nfkProjFresh σ' = χ1 := of_decide_eq_true hproj'
          have hzone' : nf0ZoneSpec σ'.1 = kvE2SepZFutT3 :=
            of_decide_eq_true (List.mem_filter.mp hσ'mem).2
          have hmemPos : σ' ∈ kvE2SepPos qnf := (List.mem_filter.mp hσ'mem).1
          obtain ⟨x1, hx1⟩ := hrealB σ' hmemPos
            (fun hc => extDis_zFutT3_not_interior (hzone' ▸ hc))
          have hx1χ1 : NfEvalNf M 1 1 (fun _ => x1) χ1 := by
            have := kvE2_sepProjFresh_eval M (Fin.cons w (Fin.cons x (fun _ => t))) x1 σ' hx1
            rwa [hproj'] at this
          refine List.any_eq_true.mpr ⟨σ', hmemPos, ?_⟩
          rw [Bool.and_eq_true]
          refine ⟨decide_eq_true hzone', decide_eq_true ?_⟩
          refine nf_eval_unique M 0 1 (fun _ => x1) _ χ ?_ ?_
          · intro a
            match a with
            | .pred p i =>
              have hi : i = 0 := Subsingleton.elim i 0
              subst hi
              simpa only [AtomEval, Fin.cons_zero, nf0ProjFresh] using hx1.1 (.pred p 0)
            | .order i j hne => exact absurd (Subsingleton.elim i j) hne
          · intro a
            match a with
            | .pred p i =>
              have hi : i = 0 := Subsingleton.elim i 0
              subst hi
              exact (hx1χ1.1 (.pred p 0)).trans
                (((hχ1 ▸ hχ1sat : NfEvalNf M 1 1 (fun _ => v) χ1).1
                  (.pred p 0)).symm.trans (hχv (.pred p 0)))
            | .order i j hne => exact absurd (Subsingleton.elim i j) hne
  · -- Backward: the positive owner is provider-realized; the realizer reads back zone
    -- and profile from its own atom layer (the `kvE2_futAnyBit_correct` backward block).
    intro hbit
    obtain ⟨σ', hmem, hread⟩ := List.any_eq_true.mp hbit
    rw [Bool.and_eq_true] at hread
    obtain ⟨hzsb, hχb⟩ := hread
    have hzs : nf0ZoneSpec σ'.1 = zs := of_decide_eq_true hzsb
    have hχ : nf0ProjFresh σ'.1 = χ := of_decide_eq_true hχb
    have hx1 : ∃ x1 : M.carrier,
        NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ' := by
      by_cases hint : nf0ZoneSpec σ'.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ'.1 = kvE2SepZWT3
      · obtain ⟨x1, -, hx1⟩ := hrealI σ' ((kvE2_sepPosI_mem qnf σ').mpr ⟨hmem, hint⟩)
        exact ⟨x1, hx1⟩
      · exact hrealB σ' hmem hint
    obtain ⟨u, hu⟩ := hx1
    obtain ⟨hatom, -⟩ := hu
    refine ⟨u, fun i => ?_, ?_⟩
    · have h1 := hatom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
      have h2 := hatom (.order i.succ 0 (Fin.succ_ne_zero i))
      simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1 h2
      have hzi := congrFun hzs i
      have e1 : σ'.1 (.order 0 i.succ (Fin.succ_ne_zero i).symm) = (zs i).1 :=
        (congrArg Prod.fst hzi)
      have e2 : σ'.1 (.order i.succ 0 (Fin.succ_ne_zero i)) = (zs i).2 :=
        (congrArg Prod.snd hzi)
      exact ⟨h1.trans (by rw [e1]), h2.trans (by rw [e2])⟩
    · rw [← hχ]
      intro a
      match a with
      | .pred p i =>
        have hi : i = 0 := Subsingleton.elim i 0
        subst hi
        simpa only [AtomEval, Fin.cons_zero, nf0ProjFresh] using hatom (.pred p 0)
      | .order i j hne => exact absurd (Subsingleton.elim i j) hne

/-! ## The discharge theorem -/

/-- **Enriched k=2 gate correctness with `hexclExt` discharged internally** (Rabinovich
    Prop 4.3 re-flatten p.6-7 + Lemma 7.6 adjacency p.14). The
    enriched composed gate `bracketEndChar_kvE2Ext` — the landed interior gate with the
    two adjacent exterior brackets conjoined at the anchors — satisfies the gate
    biconditional under the caller-owned provider inventory ONLY (`hfrag`, `hrealI`,
    `hrealB`, `hexcl`, order bits, `h_UZ`/`h_SZ`): the exterior-marked residue
    `hexclExt` of `bracketEndChar_kvE2_correct_two_prior_frag` (OuterGate.lean:359) is
    NOT an input obligation. It is discharged internally: the Phase-1 triage guard split
    sends each strictly-exterior bit-false realizer to its side, where the per-side
    bracket soundness (`kvE2_extBracketPast_sound` / `kvE2_extBracketFut_sound`) refutes
    it under the gate-level pins (`kvE2_extGate_henv` / `kvE2_extGate_anyBit_iff`).

    ⇐ (completeness): an honest realization re-establishes all three conjuncts — the
    interior gate via the UNCONDITIONAL `bracketEndChar_kvE2_complete_two_prior`, the
    two brackets via `kvE2_extBracket{Past,Fut}_complete` with pins from the realized
    qnf (`hq.1` and `kvE2_futAnyBit_correct`), positive witnesses positioned exterior by
    the marking's own zone bits, negative exclusion from the raw `nf_eval_nf` semantics.

    Consumed by the KampPrior provider instantiation at `KampPrior.lean:351` (which
    additionally discharges the remaining provider obligations `hrealI`/`hrealB`/`hexcl` —
    the R1 scope split settled for the adjacent-bracket enrichment). -/
theorem bracketEndChar_kvE2Ext_correct_two_prior_frag {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (h_xy : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true)
    (h_yt : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_xt : qnf.atomAssgn (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h_yx : qnf.atomAssgn (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (h_ty : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = false)
    (h_tx : qnf.atomAssgn (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false)
    (M : OrderedMonadicStructure sig)
    (h_UZ : SemanticPriorUZ M atomMap) (h_SZ : SemanticPriorSZ M atomMap)
    (x t : M.carrier)
    (hfrag : KvE2SepFragment qnf)
    (hrealI : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ ∈ kvE2SepPosI qnf,
        ∃ x1 : M.carrier, (x < x1 ∧ x1 < t) ∧
          NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hrealB : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ ∈ kvE2SepPos qnf,
        ¬ (nf0ZoneSpec σ.1 = kvE2SepZXW3 ∨ nf0ZoneSpec σ.1 = kvE2SepZWT3) →
        ∃ x1 : M.carrier,
          NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hexcl : ∀ w : M.carrier, x < w → w < t →
      (kvE2SepPtW (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf).EvalAt
        M atomMap w →
      ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
        ∀ x1 : M.carrier, x ≤ x1 → x1 ≤ t →
          ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (bracketEndCharKvE2Ext atomMap h_surj P qnf).holds M atomMap x t ↔
      ∃ w : M.carrier, NfEvalNf M 2 3 (Fin.cons w (Fin.cons x (fun _ => t))) qnf := by
  constructor
  · -- ⇒: destructure the degenerate Lemma 7.6 conjunction, then feed the landed interior
    -- soundness half with `hexclExt` built from the per-side bracket soundness.
    intro hExt
    obtain ⟨hInt, hPastBr, hFutBr⟩ :=
      (bracketEndChar_kvE2Ext_holds_iff atomMap h_surj P qnf M x t).mp hExt
    have hbody : (kvE2SepBody (nfDepth0CharFormula atomMap h_surj)
        (fun χ => P.existF 0 χ) qnf).holds M atomMap x t := by
      rw [← bracketEndChar_kvE2_two_eq]
      exact hInt
    obtain ⟨hEpL, hEpR, -⟩ := kvE2_sepBody_extract
      (nfDepth0CharFormula atomMap h_surj) (fun χ => P.existF 0 χ) qnf M atomMap x t hbody
    refine bracketEndChar_kvE2_sound_two_prior_frag atomMap h_surj P qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t hfrag hrealI hrealB hexcl ?_ hInt
    -- The former `hexclExt` obligation, now discharged internally.
    intro w hxw hwt hptW σ hbit _hzone x1 hguard hnf
    have henv := kvE2_extGate_henv atomMap h_surj P qnf
      h_xy h_yt h_xt h_yx h_ty h_tx M x t w hxw hwt hEpL hEpR hptW
    have hany := kvE2_extGate_anyBit_iff atomMap h_surj P qnf M h_UZ h_SZ x t w hxw hwt
      hEpL hEpR (hrealI w hxw hwt hptW) (hrealB w hxw hwt hptW) (hexcl w hxw hwt hptW)
    rcases not_and_or.mp hguard with hx | ht
    · exact kvE2_extBracketPast_sound M atomMap h_surj qnf w x t hxw hwt henv
        (fun zs χ _ => hany zs χ) hPastBr σ hbit x1 (not_le.mp hx) hnf
    · exact kvE2_extBracketFut_sound M atomMap h_surj qnf w x t hxw hwt henv
        (fun zs χ _ => hany zs χ) hFutBr σ hbit x1 (not_le.mp ht) hnf
  · -- ⇐: an honest realization re-establishes all three conjuncts.
    rintro ⟨w, h⟩
    have hxw : x < w := by
      have := (h.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide))).mpr h_xy
      exact this
    have hwt : w < t := by
      have := (h.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide))).mpr h_yt
      exact this
    refine (bracketEndChar_kvE2Ext_holds_iff atomMap h_surj P qnf M x t).mpr
      ⟨bracketEndChar_kvE2_complete_two_prior atomMap h_surj P qnf
        h_xy h_yt h_xt h_yx h_ty h_tx M h_UZ h_SZ x t ⟨w, h⟩, ?_, ?_⟩
    · -- Past bracket at `x`: pins from realized qnf; positives positioned by the
      -- marking's `zPastX3` zone bit; negatives excluded by the raw semantics.
      refine kvE2_extBracketPast_complete M atomMap h_surj qnf w x t hxw hwt h.1
        (fun zs χ _ => kvE2_futAnyBit_correct M w x t qnf h zs χ) ?_ ?_
      · intro σ hm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        obtain ⟨hzone, -, -⟩ := (kvE2_pastMarked_iff qnf σ).mp hm
        have hb1 : (nf0ZoneSpec σ.1 ⟨1, by omega⟩).1 = true := by
          rw [hzone]; rfl
        have h1 := hx1.1 (.order 0 (Fin.succ ⟨1, by omega⟩)
          (Fin.succ_ne_zero ⟨1, by omega⟩).symm)
        simp only [AtomEval, Fin.cons] at h1
        exact ⟨x1, h1.mpr hb1, hx1⟩
      · intro σ _hm hbit x1 _hx1x hr
        have := (h.2 σ).mp ⟨x1, hr⟩
        exact absurd (hbit ▸ this) Bool.false_ne_true
    · -- Future bracket at `t` (mirror, `zFutT3` zone bit).
      refine kvE2_extBracketFut_complete M atomMap h_surj qnf w x t hxw hwt h.1
        (fun zs χ _ => kvE2_futAnyBit_correct M w x t qnf h zs χ) ?_ ?_
      · intro σ hm hbit
        obtain ⟨x1, hx1⟩ := (h.2 σ).mpr hbit
        obtain ⟨hzone, -, -⟩ := (kvE2_futMarked_iff qnf σ).mp hm
        have hb2 : (nf0ZoneSpec σ.1 ⟨2, by omega⟩).2 = true := by
          rw [hzone]; rfl
        have h2 := hx1.1 (.order (Fin.succ ⟨2, by omega⟩) 0
          (Fin.succ_ne_zero ⟨2, by omega⟩))
        simp only [AtomEval, Fin.cons] at h2
        exact ⟨x1, h2.mpr hb2, hx1⟩
      · intro σ _hm hbit x1 _htx1 hr
        have := (h.2 σ).mp ⟨x1, hr⟩
        exact absurd (hbit ▸ this) Bool.false_ne_true

end FormalSystem.Metalogic.WeakCanonical.Kamp
