/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.SharedWitness

/-! # Exterior Zone-Determination Triage

The order-atom-only residue triage for the exterior-marked `hexclExt` obligation
(binder: `SharedWitness.lean:12710`; sole consumption point `SharedWitness.lean:12788`).

**Method** (Rabinovich 2014, Prop 4.3 re-flatten p.6-7 + Notation 5.2 interior bounding p.8;
347 adjudication verdict (b)): a realized exterior witness's zone marking is FORCED by the
depth-0 atom clause (`NormalForm.lean:201-202`) — the `SharedWitness.lean:12642-12649`
transfer pattern run in reverse. Where the interior-slice lemma
`kvE2_sepInterior_exterior_notRealizable` (SW:12627) reads zone-spec bits and derives order
facts, the lemmas here read the TRUE order relations at a strictly-exterior `x1` and derive
the zone-spec bits:

- `x1 < x` (with `x < w < t`) puts `x1` below ALL of `w, x, t`, so every fresh-coupling
  order-bit pair is `(true, false)` — exactly the constant spec `kvE2_sep_zPastX3`;
- `t < x1` puts `x1` above ALL of `w, x, t`, so every pair is `(false, true)` — exactly
  `kvE2_sep_zFutT3`.

**Consequence** (the triage): the genuine `hexclExt` residue is ONLY `zPastX3`-marked σ at
`x1 < x` and `zFutT3`-marked σ at `t < x1`. Every other zone marking at a strictly-exterior
`x1` is order-atom-refutable with NO residue (`kvE2_exterior_offZone_notRealizable`), the
exterior mirror of the SW:12627 interior-slice discharge. Phases 2-6 build the
model-independent one-sided complement clauses for the two genuine residue classes; Phase 8
consumes `kvE2_exterior_zone_triage` to split `hexclExt` per side.

**R6 verification** (plan Risks): the guard split `¬ (x ≤ x1 ∧ x1 ≤ t) → x1 < x ∨ t < x1`
needs a linear order on `M.carrier`; it is exposed as the instance
`OrderedMonadicStructure.carrier_order` (`MonadicFO.lean:103-109`), so `not_and_or` /
`not_le` apply directly (used in `kvE2_exterior_zone_triage` below).

Purely additive leaf module: imports SharedWitness for the zone constants; edits nothing
frozen (341/347 frozen-file gate respected). -/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-- `kvE2_sep_zPastX3` is the CONSTANT `(true, false)` zone spec: `x1` strictly below
    every env point (`SharedWitness.lean:70-72`). -/
private theorem kvE2_sep_zPastX3_apply (i : Fin 3) :
    kvE2SepZPastX3 i = (true, false) := by
  match i with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl
  | ⟨2, _⟩ => rfl

/-- `kvE2_sep_zFutT3` is the CONSTANT `(false, true)` zone spec: `x1` strictly above
    every env point (`SharedWitness.lean:94-96`). -/
private theorem kvE2_sep_zFutT3_apply (i : Fin 3) :
    kvE2SepZFutT3 i = (false, true) := by
  match i with
  | ⟨0, _⟩ => rfl
  | ⟨1, _⟩ => rfl
  | ⟨2, _⟩ => rfl

/-- **Bit transfer, below-side** (SW:12642-12649 pattern in reverse): a realized depth-0
    atom clause forces the fresh-coupling order-bit pair at index `i` to `(true, false)`
    whenever the fresh witness `x1` sits strictly below the env point `env3 i`.
    `(nf0_zoneSpec σ0 i).1` IS `σ0 (.order 0 i.succ _)` and `.2` IS
    `σ0 (.order i.succ 0 _)` (`NfEFold.lean:153-156`); the atom clause
    (`NormalForm.lean:201-202`) makes each the mirror of the true order relation. -/
theorem kvE2_zoneBit_below {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 : M.carrier) (env3 : Fin 3 → M.carrier)
    (σ0 : NormalForm sig 0 4)
    (hσ_atom : ∀ a : AtomKind sig 4, AtomEval M (Fin.cons x1 env3) a ↔ σ0 a = true)
    (i : Fin 3) (hlt : x1 < env3 i) :
    nf0ZoneSpec σ0 i = (true, false) := by
  have h1 := hσ_atom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  have h2 := hσ_atom (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1 h2
  change (σ0 (.order 0 i.succ (Fin.succ_ne_zero i).symm),
        σ0 (.order i.succ 0 (Fin.succ_ne_zero i))) = (true, false)
  rw [h1.mp hlt, Bool.eq_false_iff.mpr fun hc => lt_asymm hlt (h2.mpr hc)]

/-- **Bit transfer, above-side**: the mirror of `kvE2_zoneBit_below` — the pair at index
    `i` is forced to `(false, true)` whenever `x1` sits strictly above `env3 i`. -/
theorem kvE2_zoneBit_above {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 : M.carrier) (env3 : Fin 3 → M.carrier)
    (σ0 : NormalForm sig 0 4)
    (hσ_atom : ∀ a : AtomKind sig 4, AtomEval M (Fin.cons x1 env3) a ↔ σ0 a = true)
    (i : Fin 3) (hgt : env3 i < x1) :
    nf0ZoneSpec σ0 i = (false, true) := by
  have h1 := hσ_atom (.order 0 i.succ (Fin.succ_ne_zero i).symm)
  have h2 := hσ_atom (.order i.succ 0 (Fin.succ_ne_zero i))
  simp only [AtomEval, Fin.cons_zero, Fin.cons_succ] at h1 h2
  change (σ0 (.order 0 i.succ (Fin.succ_ne_zero i).symm),
        σ0 (.order i.succ 0 (Fin.succ_ne_zero i))) = (false, true)
  rw [Bool.eq_false_iff.mpr fun hc => lt_asymm hgt (h1.mpr hc), h2.mp hgt]

/-- **Zone determination, past side**: a σ realized at `x1 < x` (under the bracket order
    `x < w < t`, env `[x1, w, x, t]`) is FORCED to carry the exterior-past marking —
    `x1` lies strictly below all of `w, x, t`, so all three fresh-coupling bit pairs are
    `(true, false)` = `kvE2_sep_zPastX3`. Env coordinates: `i = 0 ↦ w`, `1 ↦ x`, `2 ↦ t`
    (SW:64-68). -/
theorem kvE2_exterior_zone_determination_past {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hxw : x < w) (hwt : w < t) (hx1x : x1 < x)
    (hnf : NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    nf0ZoneSpec σ.1 = kvE2SepZPastX3 := by
  obtain ⟨hσ_atom, -⟩ := hnf
  funext i
  have hlt : x1 < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i := by
    match i with
    | ⟨0, _⟩ => exact hx1x.trans hxw
    | ⟨1, _⟩ => exact hx1x
    | ⟨2, _⟩ => exact hx1x.trans (hxw.trans hwt)
  rw [kvE2_zoneBit_below M x1 _ σ.1 hσ_atom i hlt, kvE2_sep_zPastX3_apply i]

/-- **Zone determination, future side**: a σ realized at `t < x1` is FORCED to carry the
    exterior-future marking — `x1` lies strictly above all of `w, x, t`, so all three
    fresh-coupling bit pairs are `(false, true)` = `kvE2_sep_zFutT3`. -/
theorem kvE2_exterior_zone_determination_fut {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hxw : x < w) (hwt : w < t) (htx1 : t < x1)
    (hnf : NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    nf0ZoneSpec σ.1 = kvE2SepZFutT3 := by
  obtain ⟨hσ_atom, -⟩ := hnf
  funext i
  have hgt : (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) i < x1 := by
    match i with
    | ⟨0, _⟩ => exact hwt.trans htx1
    | ⟨1, _⟩ => exact (hxw.trans hwt).trans htx1
    | ⟨2, _⟩ => exact htx1
  rw [kvE2_zoneBit_above M x1 _ σ.1 hσ_atom i hgt, kvE2_sep_zFutT3_apply i]

/-- **Exterior zone-determination lemma**: the
    order-atom-only lemma forcing a realized exterior witness's zone marking, in the
    exact combined shape the plan states. -/
theorem kvE2_exterior_zone_determination {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hnf : NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ)
    (hxw : x < w) (hwt : w < t) :
    (x1 < x → nf0ZoneSpec σ.1 = kvE2SepZPastX3) ∧
    (t < x1 → nf0ZoneSpec σ.1 = kvE2SepZFutT3) :=
  ⟨fun hx1x => kvE2_exterior_zone_determination_past M x1 w x t σ hxw hwt hx1x hnf,
   fun htx1 => kvE2_exterior_zone_determination_fut M x1 w x t σ hxw hwt htx1 hnf⟩

/-- **Exterior triage** (the split Phase 8 consumes at the `hexclExt` discharge site,
    SW:12788 shape): a σ realized at a strictly-exterior `x1` lands in exactly one of the
    two genuine residue classes. The guard split `¬ (x ≤ x1 ∧ x1 ≤ t) → x1 < x ∨ t < x1`
    rides the `LinearOrder M.carrier` instance (`MonadicFO.lean:103-109`, R6 verified). -/
theorem kvE2_exterior_zone_triage {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hxw : x < w) (hwt : w < t)
    (hguard : ¬ (x ≤ x1 ∧ x1 ≤ t))
    (hnf : NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    (x1 < x ∧ nf0ZoneSpec σ.1 = kvE2SepZPastX3) ∨
    (t < x1 ∧ nf0ZoneSpec σ.1 = kvE2SepZFutT3) := by
  rcases not_and_or.mp hguard with hx | ht
  · exact Or.inl ⟨not_le.mp hx,
      kvE2_exterior_zone_determination_past M x1 w x t σ hxw hwt (not_le.mp hx) hnf⟩
  · exact Or.inr ⟨not_le.mp ht,
      kvE2_exterior_zone_determination_fut M x1 w x t σ hxw hwt (not_le.mp ht) hnf⟩

/-- **Corollary — off-zone exterior refutation** (the off-zone half of the `hexclExt` triage): under
    `hexclExt`'s guards, every σ NOT marked `zPastX3`/`zFutT3` is not realizable at a
    strictly-exterior `x1` — R1-style refutation from order atoms alone, with NO residue
    (the exterior mirror of `kvE2_sepInterior_exterior_notRealizable`, SW:12627). Together
    with the SW:12627 interior-slice discharge, this shrinks the genuine `hexclExt` residue
    to `zPastX3`-marked σ at `x1 < x` and `zFutT3`-marked σ at `t < x1`. -/
theorem kvE2_exterior_offZone_notRealizable {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (x1 w x t : M.carrier)
    (σ : NormalForm sig 1 4)
    (hxw : x < w) (hwt : w < t)
    (hzone : ¬ (nf0ZoneSpec σ.1 = kvE2SepZPastX3 ∨ nf0ZoneSpec σ.1 = kvE2SepZFutT3))
    (hguard : ¬ (x ≤ x1 ∧ x1 ≤ t)) :
    ¬ NfEvalNf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro hnf
  rcases kvE2_exterior_zone_triage M x1 w x t σ hxw hwt hguard hnf with ⟨-, hz⟩ | ⟨-, hz⟩
  · exact hzone (Or.inl hz)
  · exact hzone (Or.inr hz)

end FormalSystem.Metalogic.WeakCanonical.Kamp
