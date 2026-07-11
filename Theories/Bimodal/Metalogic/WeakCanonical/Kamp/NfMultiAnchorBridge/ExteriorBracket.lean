import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.OuterGate
import Bimodal.Metalogic.WeakCanonical.Kamp.ExteriorNegationPast

/-! # Adjacent Exterior Brackets + Enriched Composed Gate (task 348, Phase 7)

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

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-- `ZoneSpec n` equality is decidable (file-local mirror of the private SW:61 bridge). -/
private instance {n : Nat} : DecidableEq (ZoneSpec n) :=
  fun a b => decidable_of_iff (∀ i : Fin n, a i = b i) funext_iff.symm

/-- Classical conjunction reading of the encoded `Formula.and` (file-local; the encoding
    is `(φ.imp ψ.neg).neg`, so both directions are a double-negation shuffle). -/
private theorem temporal_truth_and_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (u : M.carrier) (φ ψ : Formula) :
    temporal_truth M atomMap u (Formula.and φ ψ) ↔
      (temporal_truth M atomMap u φ ∧ temporal_truth M atomMap u ψ) := by
  simp only [Formula.and, Formula.neg, temporal_truth]
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
def kvE2_futBelowZones : List (ZoneSpec 3) :=
  [kvE2_sep_zPastX3, kvE2_sep_zAtX3, kvE2_sep_zXW3,
   kvE2_sep_zAtW3, kvE2_sep_zWT3, kvE2_sep_zAtT3]

/-- The six at-or-above-`x` outer zone-3 constants (past-side `hbits` index set). -/
def kvE2_pastAboveZones : List (ZoneSpec 3) :=
  [kvE2_sep_zAtX3, kvE2_sep_zXW3, kvE2_sep_zAtW3,
   kvE2_sep_zWT3, kvE2_sep_zAtT3, kvE2_sep_zFutT3]

/-- Every future-side listed zone has third-pair second component `false` (the
    at-or-below-`t` key consumed by the `hbelow` pin and the zone-4 coupling lift). -/
theorem kvE2_futBelowZones_key :
    ∀ zs ∈ kvE2_futBelowZones, (zs ⟨2, by omega⟩).2 = false := by
  intro zs hzs
  simp only [kvE2_futBelowZones, List.mem_cons, List.not_mem_nil, or_false] at hzs
  rcases hzs with rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-- Every past-side listed zone has second-pair first component `false` (the
    at-or-above-`x` key consumed by the `habove` pin and the zone-4 coupling lift). -/
theorem kvE2_pastAboveZones_key :
    ∀ zs ∈ kvE2_pastAboveZones, (zs ⟨1, by omega⟩).1 = false := by
  intro zs hzs
  simp only [kvE2_pastAboveZones, List.mem_cons, List.not_mem_nil, or_false] at hzs
  rcases hzs with rfl | rfl | rfl | rfl | rfl | rfl <;> rfl

/-! ## Marking predicates (the per-σ `hbase`/`hbits` inventory, syntactic) -/

/-- **Future-side marking of σ against qnf** (syntactic, model-independent): `zFutT3`
    zone marking + base-restriction agreement + the six at-or-below-`t` zone-bit
    agreements against `kvE2_futAnyBit qnf` — exactly the `hbase`/`hbits` hypotheses of
    `kvE2_extNegFut_complete` (Phase 4). Under the gate pins an exterior-future realizer
    FORCES this marking (`kvE2_futMarked_of_realizer`), so unmarked σ are unrealizable
    on the future side and are legitimately absent from the bracket conjunction. -/
noncomputable def kvE2_futMarked {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4) : Bool :=
  decide (nf0_zoneSpec σ.1 = kvE2_sep_zFutT3) &&
  decide (nf0_dropFresh σ.1 = qnf.1) &&
  (kvE2_futBelowZones.all fun zs =>
    (Finset.univ.toList (α := NormalForm sig 0 1)).all fun χ =>
      decide (σ.2 (nf0_assemble (Fin.cons (true, false) zs) χ σ.1) =
        kvE2_futAnyBit qnf zs χ))

/-- **Past-side marking of σ against qnf** (mirror): `zPastX3` zone marking +
    base-restriction agreement + the six at-or-above-`x` zone-bit agreements
    (coupling `(false, true)`) — exactly the `hbase`/`hbits` hypotheses of
    `kvE2_extNegPast_complete` (Phase 6). -/
noncomputable def kvE2_pastMarked {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4) : Bool :=
  decide (nf0_zoneSpec σ.1 = kvE2_sep_zPastX3) &&
  decide (nf0_dropFresh σ.1 = qnf.1) &&
  (kvE2_pastAboveZones.all fun zs =>
    (Finset.univ.toList (α := NormalForm sig 0 1)).all fun χ =>
      decide (σ.2 (nf0_assemble (Fin.cons (false, true) zs) χ σ.1) =
        kvE2_futAnyBit qnf zs χ))

/-- Unpack the future-side marking into its three Prop components. -/
theorem kvE2_futMarked_iff {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4) :
    kvE2_futMarked qnf σ = true ↔
      (nf0_zoneSpec σ.1 = kvE2_sep_zFutT3 ∧
       nf0_dropFresh σ.1 = qnf.1 ∧
       ∀ zs ∈ kvE2_futBelowZones, ∀ χ : NormalForm sig 0 1,
         σ.2 (nf0_assemble (Fin.cons (true, false) zs) χ σ.1) =
           kvE2_futAnyBit qnf zs χ) := by
  simp only [kvE2_futMarked, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true]
  constructor
  · rintro ⟨⟨h1, h2⟩, h3⟩
    exact ⟨h1, h2, fun zs hzs χ =>
      h3 zs hzs χ (Finset.mem_toList.mpr (Finset.mem_univ χ))⟩
  · rintro ⟨h1, h2, h3⟩
    exact ⟨⟨h1, h2⟩, fun zs hzs χ _ => h3 zs hzs χ⟩

/-- Unpack the past-side marking into its three Prop components. -/
theorem kvE2_pastMarked_iff {sig : MonadicSignature}
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4) :
    kvE2_pastMarked qnf σ = true ↔
      (nf0_zoneSpec σ.1 = kvE2_sep_zPastX3 ∧
       nf0_dropFresh σ.1 = qnf.1 ∧
       ∀ zs ∈ kvE2_pastAboveZones, ∀ χ : NormalForm sig 0 1,
         σ.2 (nf0_assemble (Fin.cons (false, true) zs) χ σ.1) =
           kvE2_futAnyBit qnf zs χ) := by
  simp only [kvE2_pastMarked, Bool.and_eq_true, decide_eq_true_eq, List.all_eq_true]
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
private theorem extBk_futBelow_le_t {sig : MonadicSignature}
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
private theorem extBk_futZone4_below_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier) (htx1 : t < x1)
    (zs : ZoneSpec 3) (hz3 : (zs ⟨2, by omega⟩).2 = false) (v : M.carrier) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        (Fin.cons (true, false) zs) v ↔
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v := by
  constructor
  · intro h i
    have := h i.succ
    simpa only [Fin.cons_succ] using this
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
private theorem extBk_pastAbove_ge_x {sig : MonadicSignature}
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
private theorem extBk_pastZone4_above_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier) (hx1x : x1 < x)
    (zs : ZoneSpec 3) (hz1 : (zs ⟨1, by omega⟩).1 = false) (v : M.carrier) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        (Fin.cons (false, true) zs) v ↔
      zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v := by
  constructor
  · intro h i
    have := h i.succ
    simpa only [Fin.cons_succ] using this
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
theorem kvE2_extBase_of_realizer {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hnf : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    nf0_dropFresh σ.1 = qnf.1 := by
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
    simp only [atom_eval] at h4 h3
    rw [hskip k] at h4
    exact Bool.eq_iff_iff.mpr (h4.symm.trans h3)
  | .order k1 k2 hne =>
    have h4 := hatomσ (.order (skipFin ⟨0, Nat.succ_pos 3⟩ k1)
      (skipFin ⟨0, Nat.succ_pos 3⟩ k2) ((skipFin_injective _).ne hne))
    have h3 := henv (.order k1 k2 hne)
    simp only [atom_eval] at h4 h3
    rw [hskip k1, hskip k2] at h4
    exact Bool.eq_iff_iff.mpr (h4.symm.trans h3)

/-- **A future-side exterior realizer forces the future marking**: under the gate pins
    (`hxw`, `hwt`, `henv`, `hbelow`), any σ realized at some `x1 > t` satisfies
    `kvE2_futMarked qnf σ = true` — zone via the Phase-1 zone determination, base via
    `kvE2_extBase_of_realizer`, bits via the zone-4/zone-3 coupling lift against
    `hbelow`. This is what lets the bracket conjunction range over marked σ ONLY. -/
theorem kvE2_futMarked_of_realizer {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨2, by omega⟩).2 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hnf : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    kvE2_futMarked qnf σ = true := by
  obtain ⟨-, hquantσ, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hnf
  refine (kvE2_futMarked_iff qnf σ).mpr
    ⟨kvE2_exterior_zone_determination_fut M x1 w x t σ hxw hwt htx1 hnf,
     kvE2_extBase_of_realizer M qnf σ x1 w x t henv hnf, ?_⟩
  intro zs hzs χ
  have hkey := kvE2_futBelowZones_key zs hzs
  have hlift : (∃ v : M.carrier,
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        (Fin.cons (true, false) zs) v ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) :=
    exists_congr fun v =>
      and_congr_left' (extBk_futZone4_below_iff M x1 w x t htx1 zs hkey v)
  exact Bool.eq_iff_iff.mpr
    ((hquantσ (Fin.cons (true, false) zs) χ).symm.trans
      (hlift.trans (hbelow zs χ hkey)))

/-- **A past-side exterior realizer forces the past marking** (mirror): any σ realized
    at some `x1 < x` under the pins (`hxw`, `hwt`, `henv`, `habove`) satisfies
    `kvE2_pastMarked qnf σ = true`. -/
theorem kvE2_pastMarked_of_realizer {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (hx1x : x1 < x)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (habove : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨1, by omega⟩).1 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hnf : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    kvE2_pastMarked qnf σ = true := by
  obtain ⟨-, hquantσ, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hnf
  refine (kvE2_pastMarked_iff qnf σ).mpr
    ⟨kvE2_exterior_zone_determination_past M x1 w x t σ hxw hwt hx1x hnf,
     kvE2_extBase_of_realizer M qnf σ x1 w x t henv hnf, ?_⟩
  intro zs hzs χ
  have hkey := kvE2_pastAboveZones_key zs hzs
  have hlift : (∃ v : M.carrier,
      zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
        (Fin.cons (false, true) zs) v ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
      (∃ v : M.carrier,
        zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
        nf_eval_nf M 0 1 (fun _ => v) χ) :=
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
noncomputable def kvE2_extBracketFut {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) : Formula :=
  formula_conjList
    (((Finset.univ.toList (α := NormalForm sig 1 4)).filter (kvE2_futMarked qnf)).map
      fun σ =>
        if qnf.2 σ = true then kvE2_futPos atomMap h_surj σ
        else kvE2_extNegFut atomMap h_surj σ)

/-- **Past-side adjacent exterior bracket** (mirror, anchored at `x` over the adjacent
    interval `(-∞, x)`): `Since`-navigated existence clause `kvE2_pastPos σ` for
    bit-true marked σ, complement clause `kvE2_extNegPast σ` for bit-false marked σ. -/
noncomputable def kvE2_extBracketPast {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) : Formula :=
  formula_conjList
    (((Finset.univ.toList (α := NormalForm sig 1 4)).filter (kvE2_pastMarked qnf)).map
      fun σ =>
        if qnf.2 σ = true then kvE2_pastPos atomMap h_surj σ
        else kvE2_extNegPast atomMap h_surj σ)

/-- Bracket-at-anchor unfolds to the per-σ clause conjunction (future side, pure
    formula-level bridge — no pins). -/
theorem kvE2_extBracketFut_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) (t : M.carrier) :
    temporal_truth M atomMap t (kvE2_extBracketFut atomMap h_surj qnf) ↔
      ∀ σ : NormalForm sig 1 4, kvE2_futMarked qnf σ = true →
        temporal_truth M atomMap t
          (if qnf.2 σ = true then kvE2_futPos atomMap h_surj σ
           else kvE2_extNegFut atomMap h_surj σ) := by
  rw [kvE2_extBracketFut, formula_conjList_iff]
  constructor
  · intro h σ hm
    exact h _ (List.mem_map.mpr ⟨σ, List.mem_filter.mpr
      ⟨Finset.mem_toList.mpr (Finset.mem_univ σ), hm⟩, rfl⟩)
  · intro h f hf
    obtain ⟨σ, hσmem, rfl⟩ := List.mem_map.mp hf
    exact h σ (List.mem_filter.mp hσmem).2

/-- Bracket-at-anchor unfolds to the per-σ clause conjunction (past side). -/
theorem kvE2_extBracketPast_iff {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) (x : M.carrier) :
    temporal_truth M atomMap x (kvE2_extBracketPast atomMap h_surj qnf) ↔
      ∀ σ : NormalForm sig 1 4, kvE2_pastMarked qnf σ = true →
        temporal_truth M atomMap x
          (if qnf.2 σ = true then kvE2_pastPos atomMap h_surj σ
           else kvE2_extNegPast atomMap h_surj σ) := by
  rw [kvE2_extBracketPast, formula_conjList_iff]
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
theorem kvE2_extBracketFut_sound {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨2, by omega⟩).2 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hcl : temporal_truth M atomMap t (kvE2_extBracketFut atomMap h_surj qnf)) :
    ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
      ∀ x1 : M.carrier, t < x1 →
        ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro σ hbit x1 htx1 hnf
  have hm := kvE2_futMarked_of_realizer M qnf σ x1 w x t hxw hwt htx1 henv hbelow hnf
  have hneg : temporal_truth M atomMap t (kvE2_extNegFut atomMap h_surj σ) := by
    have h := (kvE2_extBracketFut_iff M atomMap h_surj qnf t).mp hcl σ hm
    rwa [if_neg (by simp [hbit])] at h
  exact kvE2_extNegFut_sound M atomMap h_surj σ w x t hxw hwt hneg x1 htx1 hnf

/-- **Past-side bracket soundness** (mirror): the bracket true at `x` kills every
    bit-false σ at every `x1 < x`. -/
theorem kvE2_extBracketPast_sound {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (habove : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨1, by omega⟩).1 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hcl : temporal_truth M atomMap x (kvE2_extBracketPast atomMap h_surj qnf)) :
    ∀ σ : NormalForm sig 1 4, qnf.2 σ = false →
      ∀ x1 : M.carrier, x1 < x →
        ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro σ hbit x1 hx1x hnf
  have hm := kvE2_pastMarked_of_realizer M qnf σ x1 w x t hxw hwt hx1x henv habove hnf
  have hneg : temporal_truth M atomMap x (kvE2_extNegPast atomMap h_surj σ) := by
    have h := (kvE2_extBracketPast_iff M atomMap h_surj qnf x).mp hcl σ hm
    rwa [if_neg (by simp [hbit])] at h
  exact kvE2_extNegPast_sound M atomMap h_surj σ w x t hxw hwt hneg x1 hx1x hnf

/-! ## Composed per-side positive-existence extraction (the ⇒-side positive residue) -/

/-- **Future-side existence extraction**: bracket true at `t` + marked bit-true σ
    yields an exterior realizer `x1 > t` — the `kvE2_extNegFut_complete` contrapositive
    under the marking's own `hbase`/`hbits` components. -/
theorem kvE2_extBracketFut_exists {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨2, by omega⟩).2 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hcl : temporal_truth M atomMap t (kvE2_extBracketFut atomMap h_surj qnf))
    (σ : NormalForm sig 1 4)
    (hm : kvE2_futMarked qnf σ = true) (hbit : qnf.2 σ = true) :
    ∃ x1 : M.carrier, t < x1 ∧
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨-, hbase, hb⟩ := (kvE2_futMarked_iff qnf σ).mp hm
  have hPos : temporal_truth M atomMap t (kvE2_futPos atomMap h_surj σ) := by
    have h := (kvE2_extBracketFut_iff M atomMap h_surj qnf t).mp hcl σ hm
    rwa [if_pos hbit] at h
  by_contra hno
  push_neg at hno
  exact kvE2_extNegFut_complete M atomMap h_surj qnf σ w x t hxw hwt henv hbelow hbase
    (fun zs χ hd => by
      rcases hd with rfl | rfl | rfl | rfl | rfl | rfl <;>
        exact hb _ (by simp [kvE2_futBelowZones]) χ)
    hno hPos

/-- **Past-side existence extraction** (mirror): bracket true at `x` + marked bit-true
    σ yields an exterior realizer `x1 < x`. -/
theorem kvE2_extBracketPast_exists {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (habove : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨1, by omega⟩).1 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hcl : temporal_truth M atomMap x (kvE2_extBracketPast atomMap h_surj qnf))
    (σ : NormalForm sig 1 4)
    (hm : kvE2_pastMarked qnf σ = true) (hbit : qnf.2 σ = true) :
    ∃ x1 : M.carrier, x1 < x ∧
      nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  obtain ⟨-, hbase, hb⟩ := (kvE2_pastMarked_iff qnf σ).mp hm
  have hPos : temporal_truth M atomMap x (kvE2_pastPos atomMap h_surj σ) := by
    have h := (kvE2_extBracketPast_iff M atomMap h_surj qnf x).mp hcl σ hm
    rwa [if_pos hbit] at h
  by_contra hno
  push_neg at hno
  exact kvE2_extNegPast_complete M atomMap h_surj qnf σ w x t hxw hwt henv habove hbase
    (fun zs χ hd => by
      rcases hd with rfl | rfl | rfl | rfl | rfl | rfl <;>
        exact hb _ (by simp [kvE2_pastAboveZones]) χ)
    hno hPos

/-! ## Composed per-side completeness (the ⇐-side re-establishment shape) -/

/-- **Future-side bracket completeness** (the shape Phase 8's ⇐ half consumes): per-σ
    exterior facts — realizers for marked bit-true σ, no-realizer for marked bit-false
    σ — re-establish the bracket at `t`, via `kvE2_extNegFut_complete` (bit-false) and
    the `kvE2_extNegFut_sound` contrapositive (bit-true). -/
theorem kvE2_extBracketFut_complete {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hbelow : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨2, by omega⟩).2 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hpos : ∀ σ : NormalForm sig 1 4, kvE2_futMarked qnf σ = true → qnf.2 σ = true →
      ∃ x1 : M.carrier, t < x1 ∧
        nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hneg : ∀ σ : NormalForm sig 1 4, kvE2_futMarked qnf σ = true → qnf.2 σ = false →
      ∀ x1 : M.carrier, t < x1 →
        ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap t (kvE2_extBracketFut atomMap h_surj qnf) := by
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
          exact hb _ (by simp [kvE2_futBelowZones]) χ)
      (hneg σ hm hbit)

/-- **Past-side bracket completeness** (mirror): per-σ exterior facts re-establish the
    bracket at `x`. -/
theorem kvE2_extBracketPast_complete {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (habove : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨1, by omega⟩).1 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hpos : ∀ σ : NormalForm sig 1 4, kvE2_pastMarked qnf σ = true → qnf.2 σ = true →
      ∃ x1 : M.carrier, x1 < x ∧
        nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hneg : ∀ σ : NormalForm sig 1 4, kvE2_pastMarked qnf σ = true → qnf.2 σ = false →
      ∀ x1 : M.carrier, x1 < x →
        ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap x (kvE2_extBracketPast atomMap h_surj qnf) := by
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
          exact hb _ (by simp [kvE2_pastAboveZones]) χ)
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
theorem VVecEA2.enrichEndpoints_holds {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (v : VVecEA2) (pL pR : Formula) (z0 z1 : M.carrier) :
    (v.enrichEndpoints pL pR).holds M atomMap z0 z1 ↔
      (v.holds M atomMap z0 z1 ∧
       temporal_truth M atomMap z0 pL ∧ temporal_truth M atomMap z1 pR) := by
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

/-- **The enriched composed gate** (task 348 Phase 7; Def 7.5 p.13 + degenerate
    Lemma 7.6 p.14): the landed interior gate `bracketEndChar_kvE2` (OuterGate.lean:70,
    a verified INPUT — applied, never re-proved) with the past-side adjacent bracket
    conjoined at the LEFT anchor `x` and the future-side adjacent bracket conjoined at
    the RIGHT anchor `t`. Phase 8's discharge theorem
    `bracketEndChar_kvE2Ext_correct_two_prior_frag` states the gate biconditional for
    THIS carrier, with `hexclExt` discharged internally by the per-side bracket
    soundness above. -/
noncomputable def bracketEndChar_kvE2Ext {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1) :
    BracketEndCharCarrierV sig 2 :=
  fun qnf =>
    (bracketEndChar_kvE2 atomMap h_surj P qnf).enrichEndpoints
      (kvE2_extBracketPast atomMap h_surj qnf)
      (kvE2_extBracketFut atomMap h_surj qnf)

/-- **Anchor-semantics bridge for the enriched gate** (the degenerate Lemma 7.6
    conjunction, exposed): the enriched gate holds at `(x, t)` iff the interior gate
    holds AND the past bracket is true at `x` AND the future bracket is true at `t`. -/
theorem bracketEndChar_kvE2Ext_holds_iff {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (P : ExistProviders sig atomMap 1)
    (qnf : NormalForm sig 2 3)
    (M : OrderedMonadicStructure sig) (x t : M.carrier) :
    (bracketEndChar_kvE2Ext atomMap h_surj P qnf).holds M atomMap x t ↔
      ((bracketEndChar_kvE2 atomMap h_surj P qnf).holds M atomMap x t ∧
       temporal_truth M atomMap x (kvE2_extBracketPast atomMap h_surj qnf) ∧
       temporal_truth M atomMap t (kvE2_extBracketFut atomMap h_surj qnf)) :=
  VVecEA2.enrichEndpoints_holds M atomMap _ _ _ x t

end Bimodal.Metalogic.WeakCanonical.Kamp
