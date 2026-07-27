/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.AggregateHookDischarge

/-! # Exterior fiber kit + single-fiber R3 probe

The 7-zone fiber partition kit for the exterior channels of the k=1 population match: the
arity-3 instance of the delivered arity-2 zone technique (`agg2Mk` constants +
`agg2_zoneHolds_cons_iff` + `agg2_zone_consistent_*`, AggregateHookDischarge.lean), applied
to the past-exterior ambient order `w < x < t` over the env `[w, x, t]` (position 0 = the
exterior witness `w`, position 1 = the pin `x`, position 2 = the origin `t`).

## Deliverables

1. **R3 ADJUDICATION PROBE (first proved item)**: `extProbeQnf` — ONE concrete qnf with the
   `w < x` channel order row, one bit-TRUE inner fiber (zone `v < w`, point type
   `extProbeChi`) and all other fibers bit-FALSE (in particular the interior fiber
   `x < v < t` with the same point type). Its clause iff `extProbe_clause_iff` is proved
   end-to-end through the intended device: the depth-1 fold engine
   `nf_eval_depth1_fold_iff` (CarrierKv.lean:466) + the depth-0 split-kit round-trips
   (`nf0_zoneSpec_assemble` / `nf0_projFresh_assemble` / `nf0_dropFresh_assemble`,
   NfEFold.lean) + the zone reading lemmas below. Named corollaries
   `extProbe_bitTrue_realized` / `extProbe_bitFalse_excluded` read the two probed fibers
   off the clause iff.
2. `ext3Mk` + the 7 order-consistent zone constants of `w < x < t`
   (`v<w, v=w, w<v<x, v=x, x<v<t, v=t, t<v`), with `ext3_zoneHolds_cons_iff` /
   `ext3_zs_ext` (arity-3 cons reading / builder) and the 7 per-zone `zoneHolds`
   simplifications `extZ_*_holds_iff` under the ambient order.
3. `extZone_consistent_lt` — the arity-3 routing lemma (any realized zone spec is one of
   the 7 consistent zones), and `extZone_inconsistent_false` — the fold-bit falsity of
   every order-channel-inconsistent fiber under any realizer (the `agg2_zone_consistent_*`
   technique, arity-3 instance).
4. `extZoneFiber_k1` — the depth-1 fold at n=3, env `[w, x, t]`, re-partitioned into
   MONADIC clauses over the 7 zones: per-zone biconditional fiber clauses + the
   inconsistent-zone falsity conjunct + the off-fiber honesty clause.

## Guards

G1 — the population obligation stays the honest arity-3 existential; this module only
re-fibers it losslessly (depth-0 split-kit bijection). G2/G4 — anchors exactly `{x, t}`
plus the exterior witness `w` laid by the (Phase 14c) `∃w` glue; no interior point enters
an env. G5 — every bridge below is a manual `constructor`/`intro`/`exact` step. FORBIDDEN
`nf_char3_deeper_split` is not referenced. No frozen file is touched.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem": Lemma 3.2(2) split (chunk_0009, PDF p.4);
  Def 7.13 multi-anchor `(z0,…,zk,∞)-∨→∃∀` conjunction form (chunk_0023) — the 7 zones ARE
  the order-consistent witness positions of the three-anchor frame `w < x < t`.
- The negfix-refactor design for the exterior carriers, Phase 13 (E1 — the zone-fiber kit).
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

section ExteriorFiberKit

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-! ## The 7 order-consistent zones of `w < x < t` (arity-3 zone constants)

Env `[w, x, t]`: position 0 = the exterior witness `w`, position 1 = the pin `x`,
position 2 = the origin `t`. Zone coordinates reuse the delivered arity-2 pair constants
`agg2Ltz` (`v < env i`), `agg2Eqz` (`v = env i`), `agg2Gtz` (`env i < v`). -/

/-- Zone-spec builder for the arity-3 env `[w, x, t]`. -/
def ext3Mk (pw px pt : Bool × Bool) : ZoneSpec 3 :=
  Fin.cons pw (Fin.cons px (fun _ => pt))

/-- `v < w` (past exterior of the witness; under `w < x < t` also `v < x`, `v < t`). -/
def extZBelowW : ZoneSpec 3 := ext3Mk agg2Ltz agg2Ltz agg2Ltz
/-- `v = w` (at the exterior witness). -/
def extZAtW : ZoneSpec 3 := ext3Mk agg2Eqz agg2Ltz agg2Ltz
/-- `w < v < x` (bounded interior between the witness and the pin). -/
def extZIntWX : ZoneSpec 3 := ext3Mk agg2Gtz agg2Ltz agg2Ltz
/-- `v = x` (at the pin). -/
def extZAtX : ZoneSpec 3 := ext3Mk agg2Gtz agg2Eqz agg2Ltz
/-- `x < v < t` (bounded interior between the pin and the origin). -/
def extZIntXT : ZoneSpec 3 := ext3Mk agg2Gtz agg2Gtz agg2Ltz
/-- `v = t` (at the origin). -/
def extZAtT : ZoneSpec 3 := ext3Mk agg2Gtz agg2Gtz agg2Eqz
/-- `t < v` (future exterior of all three anchors). -/
def extZAboveT : ZoneSpec 3 := ext3Mk agg2Gtz agg2Gtz agg2Gtz

/-- Pointwise reading of an arity-3 `zoneHolds` over the three-anchor env `[w, x, t]`
    (the `n = 3` analog of `agg2_zoneHolds_cons_iff`; Def 3.1 ordering channel, PDF p.4). -/
theorem ext3_zoneHolds_cons_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (pw px pt : Bool × Bool) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      (Fin.cons pw (Fin.cons px (fun _ => pt)) : ZoneSpec 3) u ↔
    ((((u < w) ↔ pw.1 = true) ∧ ((w < u) ↔ pw.2 = true)) ∧
     (((u < x) ↔ px.1 = true) ∧ ((x < u) ↔ px.2 = true)) ∧
     (((u < t) ↔ pt.1 = true) ∧ ((t < u) ↔ pt.2 = true))) := by
  constructor
  · intro h
    have h0 := h ⟨0, by omega⟩
    have h1 := h ⟨1, by omega⟩
    have h2 := h ⟨2, by omega⟩
    simp only [Fin.cons] at h0 h1 h2
    exact ⟨h0, h1, h2⟩
  · rintro ⟨h0, h1, h2⟩ i
    match i with
    | ⟨0, _⟩ => exact h0
    | ⟨1, _⟩ => exact h1
    | ⟨2, _⟩ => exact h2

/-- Pointwise equality builder for an arity-3 zone spec from its three coordinates. -/
private theorem ext3_zs_ext {zs : ZoneSpec 3} (pw px pt : Bool × Bool)
    (e0 : zs ⟨0, by omega⟩ = pw) (e1 : zs ⟨1, by omega⟩ = px)
    (e2 : zs ⟨2, by omega⟩ = pt) :
    zs = ext3Mk pw px pt := by
  funext i
  match i with
  | ⟨0, _⟩ => exact e0
  | ⟨1, _⟩ => exact e1
  | ⟨2, _⟩ => exact e2

/-! ## Per-zone `zoneHolds` simplifications under the ambient order `w < x < t`

Each of the 7 consistent zone specs reads as its plain monadic order condition: the two
non-defining coordinates per anchor follow from transitivity of the ambient order. These
are the readings that make the Phase-13 partition clauses MONADIC (Lemma 3.2(2)). -/

/-- Zone `v < w`. -/
theorem extZ_belowW_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hwx : w < x) (hxt : x < t) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extZBelowW u ↔ u < w := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Ltz agg2Ltz agg2Ltz) ?_
  constructor
  · rintro ⟨⟨h, -⟩, -, -⟩
    exact h.mpr rfl
  · intro h
    have hux : u < x := h.trans hwx
    have hut : u < t := hux.trans hxt
    exact ⟨⟨iff_of_true h rfl, iff_of_false (lt_asymm h) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (fun hf => Bool.noConfusion hf)⟩⟩

/-- Zone `v = w`. -/
theorem extZ_atW_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hwx : w < x) (hxt : x < t) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extZAtW u ↔ u = w := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Eqz agg2Ltz agg2Ltz) ?_
  constructor
  · rintro ⟨⟨h1, h2⟩, -, -⟩
    rcases lt_trichotomy u w with h | h | h
    · exact absurd (h1.mp h) (fun hf => Bool.noConfusion hf)
    · exact h
    · exact absurd (h2.mp h) (fun hf => Bool.noConfusion hf)
  · rintro rfl
    have hux : u < x := hwx
    have hut : u < t := hux.trans hxt
    exact ⟨⟨iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf),
        iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (fun hf => Bool.noConfusion hf)⟩⟩

/-- Zone `w < v < x`. -/
theorem extZ_intWX_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hxt : x < t) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extZIntWX u ↔ w < u ∧ u < x := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Gtz agg2Ltz agg2Ltz) ?_
  constructor
  · rintro ⟨⟨-, h1⟩, ⟨h2, -⟩, -⟩
    exact ⟨h1.mpr rfl, h2.mpr rfl⟩
  · rintro ⟨hwu, hux⟩
    have hut : u < t := hux.trans hxt
    exact ⟨⟨iff_of_false (lt_asymm hwu) (fun hf => Bool.noConfusion hf), iff_of_true hwu rfl⟩,
      ⟨iff_of_true hux rfl, iff_of_false (lt_asymm hux) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (fun hf => Bool.noConfusion hf)⟩⟩

/-- Zone `v = x`. -/
theorem extZ_atX_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hwx : w < x) (hxt : x < t) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extZAtX u ↔ u = x := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Gtz agg2Eqz agg2Ltz) ?_
  constructor
  · rintro ⟨-, ⟨h1, h2⟩, -⟩
    rcases lt_trichotomy u x with h | h | h
    · exact absurd (h1.mp h) (fun hf => Bool.noConfusion hf)
    · exact h
    · exact absurd (h2.mp h) (fun hf => Bool.noConfusion hf)
  · rintro rfl
    have hwu : w < u := hwx
    have hut : u < t := hxt
    exact ⟨⟨iff_of_false (lt_asymm hwu) (fun hf => Bool.noConfusion hf), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf),
        iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (fun hf => Bool.noConfusion hf)⟩⟩

/-- Zone `x < v < t`. -/
theorem extZ_intXT_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hwx : w < x) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extZIntXT u ↔ x < u ∧ u < t := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Gtz agg2Gtz agg2Ltz) ?_
  constructor
  · rintro ⟨-, ⟨-, h1⟩, ⟨h2, -⟩⟩
    exact ⟨h1.mpr rfl, h2.mpr rfl⟩
  · rintro ⟨hxu, hut⟩
    have hwu : w < u := hwx.trans hxu
    exact ⟨⟨iff_of_false (lt_asymm hwu) (fun hf => Bool.noConfusion hf), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (fun hf => Bool.noConfusion hf), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (fun hf => Bool.noConfusion hf)⟩⟩

/-- Zone `v = t`. -/
theorem extZ_atT_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hwx : w < x) (hxt : x < t) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extZAtT u ↔ u = t := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Gtz agg2Gtz agg2Eqz) ?_
  constructor
  · rintro ⟨-, -, ⟨h1, h2⟩⟩
    rcases lt_trichotomy u t with h | h | h
    · exact absurd (h1.mp h) (fun hf => Bool.noConfusion hf)
    · exact h
    · exact absurd (h2.mp h) (fun hf => Bool.noConfusion hf)
  · rintro rfl
    have hxu : x < u := hxt
    have hwu : w < u := hwx.trans hxu
    exact ⟨⟨iff_of_false (lt_asymm hwu) (fun hf => Bool.noConfusion hf), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (fun hf => Bool.noConfusion hf), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf),
        iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf)⟩⟩

/-- Zone `t < v`. -/
theorem extZ_aboveT_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hwx : w < x) (hxt : x < t) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extZAboveT u ↔ t < u := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Gtz agg2Gtz agg2Gtz) ?_
  constructor
  · rintro ⟨-, -, ⟨-, h⟩⟩
    exact h.mpr rfl
  · intro h
    have hxu : x < u := hxt.trans h
    have hwu : w < u := hwx.trans hxu
    exact ⟨⟨iff_of_false (lt_asymm hwu) (fun hf => Bool.noConfusion hf), iff_of_true hwu rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (fun hf => Bool.noConfusion hf), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_asymm h) (fun hf => Bool.noConfusion hf), iff_of_true h rfl⟩⟩

/-! ## Routing: zone consistency + inconsistent-fiber falsity (`agg2_zone_consistent_*`
technique, arity-3 instance)

Any zone spec realized over `[w, x, t]` under the ambient `w < x < t` is one of the 7
order-consistent zones; contrapositively, the fold bit of every inconsistent spec is
forced `false` under any realizer of the depth-1 evaluation (Def 3.1, PDF pp.4-5:
disjunctions range only over consistent order types). -/

/-- **Past-exterior routing lemma** (`w < x < t`): a realized arity-3 zone spec is one of
    the seven consistent zones `v<w` / `v=w` / `w<v<x` / `v=x` / `x<v<t` / `v=t` / `t<v`. -/
theorem extZone_consistent_lt (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hwx : w < x) (hxt : x < t)
    (zs : ZoneSpec 3)
    (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u) :
    zs = extZBelowW ∨ zs = extZAtW ∨ zs = extZIntWX ∨ zs = extZAtX ∨
    zs = extZIntXT ∨ zs = extZAtT ∨ zs = extZAboveT := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  simp only [Fin.cons] at h0 h1 h2
  rcases lt_trichotomy u w with huw | huw | huw
  · -- u < w < x < t : zone `v < w`.
    have hux : u < x := huw.trans hwx
    have hut : u < t := hux.trans hxt
    exact Or.inl (ext3_zs_ext _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hux, k1v_bool_eq_false h1.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))
  · -- u = w : zone `v = w`.
    subst huw
    have hut : u < t := hwx.trans hxt
    exact Or.inr (Or.inl (ext3_zs_ext _ _ _
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
        k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hwx, k1v_bool_eq_false h1.2 (lt_asymm hwx)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩)))
  · -- w < u : split against x.
    rcases lt_trichotomy u x with hux | hux | hux
    · -- w < u < x : bounded interior `(w, x)`.
      have hut : u < t := hux.trans hxt
      exact Or.inr (Or.inr (Or.inl (ext3_zs_ext _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
        (Prod.ext_iff.mpr ⟨h1.1.mp hux, k1v_bool_eq_false h1.2 (lt_asymm hux)⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))
    · -- u = x : zone `v = x`.
      subst hux
      exact Or.inr (Or.inr (Or.inr (Or.inl (ext3_zs_ext _ _ _
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
          k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hxt, k1v_bool_eq_false h2.2 (lt_asymm hxt)⟩)))))
    · -- x < u : split against t.
      rcases lt_trichotomy u t with hut | hut | hut
      · -- x < u < t : bounded interior `(x, t)`.
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (ext3_zs_ext _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))))
      · -- u = t : zone `v = t`.
        subst hut
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (ext3_zs_ext _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl u),
            k1v_bool_eq_false h2.2 (lt_irrefl u)⟩)))))))
      · -- t < u : future exterior.
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (ext3_zs_ext _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hut), h2.2.mp hut⟩)))))))

/-- **Inconsistent-fiber falsity** (the arity-3 `agg2_zone_consistent_*` falsity form):
    under any realizer of a depth-1 arity-3 evaluation at `[w, x, t]` with `w < x < t`,
    the fold bit of every order-channel-inconsistent fiber is `false`. -/
theorem extZone_inconsistent_false (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hwx : w < x) (hxt : x < t)
    (σ : NormalForm sig 1 3)
    (hnf : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ)
    (zs : ZoneSpec 3)
    (hcons : ¬(zs = extZBelowW ∨ zs = extZAtW ∨ zs = extZIntWX ∨ zs = extZAtX ∨
      zs = extZIntXT ∨ zs = extZAtT ∨ zs = extZAboveT))
    (χ : NormalForm sig 0 1) :
    σ.2 (nf0_assemble zs χ σ.1) = false := by
  obtain ⟨-, hfold, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hnf
  cases hb : σ.2 (nf0_assemble zs χ σ.1) with
  | false => rfl
  | true =>
    obtain ⟨v, hzv, -⟩ := (hfold zs χ).mpr hb
    exact absurd (extZone_consistent_lt M w x t v hwx hxt zs hzv) hcons

/-! ## The 7-zone fiber partition (`extZoneFiber_k1`)

The depth-1 fold at n=3, env `[w, x, t]`, re-partitioned into MONADIC clauses over the 7
order-consistent zones of `w < x < t`: the generic per-`(zs, χ)` fold clause of
`nf_eval_depth1_fold_iff` splits into seven per-zone biconditionals whose zone readings
are plain order conditions (Lemma 3.2(2) — each clause couples the witness to at most the
zone's defining anchors), an inconsistent-zone falsity conjunct, and the off-fiber honesty
clause. This is the E1 kit shape that Phases 14a-14c consume per fiber. -/

theorem extZoneFiber_k1 (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hwx : w < x) (hxt : x < t) (σ : NormalForm sig 1 3) :
    nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ ↔
      ((∀ a : AtomKind sig 3,
          atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ σ.1 a = true) ∧
       ((∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extZBelowW χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           nf_eval_nf M 0 1 (fun _ => w) χ ↔
             σ.2 (nf0_assemble extZAtW χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, w < v ∧ v < x ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extZIntWX χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           nf_eval_nf M 0 1 (fun _ => x) χ ↔
             σ.2 (nf0_assemble extZAtX χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, x < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extZIntXT χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           nf_eval_nf M 0 1 (fun _ => t) χ ↔
             σ.2 (nf0_assemble extZAtT χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, t < v ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extZAboveT χ σ.1) = true)) ∧
       (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
          ¬(zs = extZBelowW ∨ zs = extZAtW ∨ zs = extZIntWX ∨ zs = extZAtX ∨
            zs = extZIntXT ∨ zs = extZAtT ∨ zs = extZAboveT) →
          σ.2 (nf0_assemble zs χ σ.1) = false) ∧
       (∀ τ : NormalForm sig 0 4, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)) := by
  rw [nf_eval_depth1_fold_iff]
  constructor
  · rintro ⟨hatom, hfold, hoff⟩
    refine ⟨hatom, ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩, ?_, hoff⟩
    · -- Zone `v < w`.
      intro χ
      refine Iff.trans ?_ (hfold extZBelowW χ)
      refine exists_congr fun v => ?_
      rw [extZ_belowW_holds_iff M w x t v hwx hxt]
    · -- Zone `v = w`.
      intro χ
      refine Iff.trans ?_ (hfold extZAtW χ)
      constructor
      · intro h
        exact ⟨w, (extZ_atW_holds_iff M w x t w hwx hxt).mpr rfl, h⟩
      · rintro ⟨v, hzv, h⟩
        rw [(extZ_atW_holds_iff M w x t v hwx hxt).mp hzv] at h
        exact h
    · -- Zone `w < v < x`.
      intro χ
      refine Iff.trans ?_ (hfold extZIntWX χ)
      refine exists_congr fun v => ?_
      rw [extZ_intWX_holds_iff M w x t v hxt]
      exact and_assoc.symm
    · -- Zone `v = x`.
      intro χ
      refine Iff.trans ?_ (hfold extZAtX χ)
      constructor
      · intro h
        exact ⟨x, (extZ_atX_holds_iff M w x t x hwx hxt).mpr rfl, h⟩
      · rintro ⟨v, hzv, h⟩
        rw [(extZ_atX_holds_iff M w x t v hwx hxt).mp hzv] at h
        exact h
    · -- Zone `x < v < t`.
      intro χ
      refine Iff.trans ?_ (hfold extZIntXT χ)
      refine exists_congr fun v => ?_
      rw [extZ_intXT_holds_iff M w x t v hwx]
      exact and_assoc.symm
    · -- Zone `v = t`.
      intro χ
      refine Iff.trans ?_ (hfold extZAtT χ)
      constructor
      · intro h
        exact ⟨t, (extZ_atT_holds_iff M w x t t hwx hxt).mpr rfl, h⟩
      · rintro ⟨v, hzv, h⟩
        rw [(extZ_atT_holds_iff M w x t v hwx hxt).mp hzv] at h
        exact h
    · -- Zone `t < v`.
      intro χ
      refine Iff.trans ?_ (hfold extZAboveT χ)
      refine exists_congr fun v => ?_
      rw [extZ_aboveT_holds_iff M w x t v hwx hxt]
    · -- Inconsistent-zone falsity.
      intro zs χ hcons
      cases hb : σ.2 (nf0_assemble zs χ σ.1) with
      | false => rfl
      | true =>
        obtain ⟨v, hzv, -⟩ := (hfold zs χ).mpr hb
        exact absurd (extZone_consistent_lt M w x t v hwx hxt zs hzv) hcons
  · rintro ⟨hatom, ⟨h1, h2, h3, h4, h5, h6, h7⟩, hbad, hoff⟩
    refine ⟨hatom, ?_, hoff⟩
    intro zs χ
    by_cases hcons : zs = extZBelowW ∨ zs = extZAtW ∨ zs = extZIntWX ∨ zs = extZAtX ∨
        zs = extZIntXT ∨ zs = extZAtT ∨ zs = extZAboveT
    · rcases hcons with rfl | rfl | rfl | rfl | rfl | rfl | rfl
      · -- Zone `v < w`.
        refine Iff.trans ?_ (h1 χ)
        refine exists_congr fun v => ?_
        rw [extZ_belowW_holds_iff M w x t v hwx hxt]
      · -- Zone `v = w`.
        refine Iff.trans ?_ (h2 χ)
        constructor
        · rintro ⟨v, hzv, h⟩
          rw [(extZ_atW_holds_iff M w x t v hwx hxt).mp hzv] at h
          exact h
        · intro h
          exact ⟨w, (extZ_atW_holds_iff M w x t w hwx hxt).mpr rfl, h⟩
      · -- Zone `w < v < x`.
        refine Iff.trans ?_ (h3 χ)
        refine exists_congr fun v => ?_
        rw [extZ_intWX_holds_iff M w x t v hxt]
        exact and_assoc
      · -- Zone `v = x`.
        refine Iff.trans ?_ (h4 χ)
        constructor
        · rintro ⟨v, hzv, h⟩
          rw [(extZ_atX_holds_iff M w x t v hwx hxt).mp hzv] at h
          exact h
        · intro h
          exact ⟨x, (extZ_atX_holds_iff M w x t x hwx hxt).mpr rfl, h⟩
      · -- Zone `x < v < t`.
        refine Iff.trans ?_ (h5 χ)
        refine exists_congr fun v => ?_
        rw [extZ_intXT_holds_iff M w x t v hwx]
        exact and_assoc
      · -- Zone `v = t`.
        refine Iff.trans ?_ (h6 χ)
        constructor
        · rintro ⟨v, hzv, h⟩
          rw [(extZ_atT_holds_iff M w x t v hwx hxt).mp hzv] at h
          exact h
        · intro h
          exact ⟨t, (extZ_atT_holds_iff M w x t t hwx hxt).mpr rfl, h⟩
      · -- Zone `t < v`.
        refine Iff.trans ?_ (h7 χ)
        refine exists_congr fun v => ?_
        rw [extZ_aboveT_holds_iff M w x t v hwx hxt]
    · -- Inconsistent zone: bit is false, existential refuted by routing.
      refine iff_of_false ?_ ?_
      · rintro ⟨v, hzv, -⟩
        exact absurd (extZone_consistent_lt M w x t v hwx hxt zs hzv) hcons
      · rw [hbad zs χ hcons]
        exact fun hf => Bool.noConfusion hf

/-! ## R3 ADJUDICATION PROBE (plan v3 Phase 13 FIRST task)

ONE concrete qnf with the `w < x` channel: order row = the positional order bits of
`w < x < t`; quant layer = exactly ONE true bit, at the fiber (zone `v < w`,
point type `extProbeChi`). The clause iff `extProbe_clause_iff` runs end-to-end through
the intended device — the depth-1 fold engine + the depth-0 split-kit round-trips + the
per-zone readings — and the two named corollaries read off the bit-TRUE fiber
(`extProbe_bitTrue_realized`: the `v < w` monadic existential IS realized) and a bit-FALSE
fiber (`extProbe_bitFalse_excluded`: the interior `x < v < t` fiber with the same point
type is EXCLUDED). Compiling green, this retires risk R3 for the E1 device: fiber bits
route soundly in both polarities before E2 generalizes. -/

/-- Probe order row: the `w < x` channel — order atom `(i, j)` true iff `i < j`
    positionally (encoding `w < x`, `w < t`, `x < t`); no predicate content. -/
def extProbeRow : NormalForm sig 0 3 :=
  fun a => match a with
  | .pred _ _ => false
  | .order i j _ => decide (i.val < j.val)

/-- Probe monadic point type: the all-false complete type. -/
def extProbeChi : NormalForm sig 0 1 := fun _ => false

/-- The bit-TRUE fiber target: zone `v < w`, point type `extProbeChi`, over the probe row. -/
def extProbeTarget : NormalForm sig 0 4 :=
  nf0_assemble extZBelowW extProbeChi extProbeRow

open Classical in
/-- Probe quant layer: exactly one true bit, at `extProbeTarget`. -/
noncomputable def extProbeQuant : NormalForm sig 0 4 → Bool :=
  fun τ => if τ = extProbeTarget (sig := sig) then true else false

/-- The R3 probe qnf: `w < x` channel order row + single-true-bit quant layer. -/
noncomputable def extProbeQnf : NormalForm sig 1 3 := (extProbeRow, extProbeQuant)

/-- The probe bit at the target fiber is TRUE. -/
theorem extProbe_bit_true :
    extProbeQuant (sig := sig) extProbeTarget = true := by
  simp only [extProbeQuant, if_pos]

/-- The probe bit at any OTHER assembled fiber over the probe row is FALSE (split-kit
    round-trips: assembled fibers with distinct `(zone, point type)` channels are
    distinct). -/
theorem extProbe_bit_false_of_ne (zs : ZoneSpec 3) (χ : NormalForm sig 0 1)
    (h : ¬(zs = extZBelowW ∧ χ = extProbeChi (sig := sig))) :
    extProbeQuant (sig := sig) (nf0_assemble zs χ extProbeRow) = false := by
  refine if_neg (fun he => h ?_)
  have hz := congrArg nf0_zoneSpec he
  have hp := congrArg nf0_projFresh he
  rw [show extProbeTarget (sig := sig) =
      nf0_assemble extZBelowW extProbeChi extProbeRow from rfl] at hz hp
  rw [nf0_zoneSpec_assemble, nf0_zoneSpec_assemble] at hz
  rw [nf0_projFresh_assemble, nf0_projFresh_assemble] at hp
  exact ⟨hz, hp⟩

/-- The probe quant layer satisfies the off-fiber honesty clause. -/
theorem extProbe_quant_off :
    ∀ τ : NormalForm sig 0 4,
      nf0_dropFresh τ ≠ (extProbeRow (sig := sig)) →
      extProbeQuant (sig := sig) τ = false := by
  intro τ hτ
  refine if_neg (fun he => hτ ?_)
  rw [he]
  exact nf0_dropFresh_assemble extZBelowW extProbeChi extProbeRow

/-- **R3 adjudication probe — the clause iff for the concrete probe qnf, end-to-end.**
    The depth-1 evaluation of `extProbeQnf` at `[w, x, t]` under the ambient `w < x < t`
    is exactly: the probe atom row + the REALIZED bit-true fiber (the `v < w` monadic
    existential for `extProbeChi`) + the EXCLUSION of every other `(zone, point type)`
    fiber (all bit-false). Proved through the full intended device: the depth-1 fold
    engine `nf_eval_depth1_fold_iff`, the split-kit round-trips, and the zone readings. -/
theorem extProbe_clause_iff (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hwx : w < x) (hxt : x < t) :
    nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t)))
        (extProbeQnf (sig := sig)) ↔
      ((∀ a : AtomKind sig 3,
          atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔
            extProbeRow a = true) ∧
       (∃ v : M.carrier, v < w ∧ nf_eval_nf M 0 1 (fun _ => v) extProbeChi) ∧
       (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
          ¬(zs = extZBelowW ∧ χ = extProbeChi (sig := sig)) →
          ¬∃ v : M.carrier,
            zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
              nf_eval_nf M 0 1 (fun _ => v) χ)) := by
  rw [nf_eval_depth1_fold_iff]
  constructor
  · rintro ⟨hatom, hfold, -⟩
    refine ⟨hatom, ?_, ?_⟩
    · -- The bit-TRUE fiber is realized: read the target bit back through the fold.
      obtain ⟨v, hzv, hχv⟩ := (hfold extZBelowW extProbeChi).mpr extProbe_bit_true
      exact ⟨v, (extZ_belowW_holds_iff M w x t v hwx hxt).mp hzv, hχv⟩
    · -- Every other fiber is excluded: its bit is FALSE.
      rintro zs χ hne ⟨v, hzv, hχv⟩
      have hbit : extProbeQuant (sig := sig) (nf0_assemble zs χ extProbeRow) = true :=
        (hfold zs χ).mp ⟨v, hzv, hχv⟩
      rw [extProbe_bit_false_of_ne zs χ hne] at hbit
      exact Bool.noConfusion hbit
  · rintro ⟨hatom, ⟨v0, hv0, hχ0⟩, hexcl⟩
    refine ⟨hatom, ?_, extProbe_quant_off⟩
    intro zs χ
    by_cases hc : zs = extZBelowW ∧ χ = extProbeChi (sig := sig)
    · obtain ⟨rfl, rfl⟩ := hc
      refine iff_of_true ?_ extProbe_bit_true
      exact ⟨v0, (extZ_belowW_holds_iff M w x t v0 hwx hxt).mpr hv0, hχ0⟩
    · refine iff_of_false (hexcl zs χ hc) (fun hbit => ?_)
      have hbit' : extProbeQuant (sig := sig) (nf0_assemble zs χ extProbeRow) = true := hbit
      rw [extProbe_bit_false_of_ne zs χ hc] at hbit'
      exact Bool.noConfusion hbit'

/-- **Probe corollary (bit-TRUE fiber)**: under any realizer of the probe qnf, the
    `v < w` inner fiber with point type `extProbeChi` IS realized. -/
theorem extProbe_bitTrue_realized (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hwx : w < x) (hxt : x < t)
    (hnf : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t)))
      (extProbeQnf (sig := sig))) :
    ∃ v : M.carrier, v < w ∧ nf_eval_nf M 0 1 (fun _ => v) extProbeChi :=
  ((extProbe_clause_iff M w x t hwx hxt).mp hnf).2.1

/-- **Probe corollary (bit-FALSE fiber)**: under any realizer of the probe qnf, the
    interior `x < v < t` inner fiber with the SAME point type is EXCLUDED (its bit is
    false, and the exclusion transports through the zone reading). -/
theorem extProbe_bitFalse_excluded (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hwx : w < x) (hxt : x < t)
    (hnf : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t)))
      (extProbeQnf (sig := sig))) :
    ¬∃ v : M.carrier, x < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) extProbeChi := by
  have hexcl := ((extProbe_clause_iff M w x t hwx hxt).mp hnf).2.2
  rintro ⟨v, hxv, hvt, hχv⟩
  have hzne : ¬(extZIntXT = extZBelowW ∧
      extProbeChi (sig := sig) = extProbeChi (sig := sig)) := by
    rintro ⟨hz, -⟩
    exact absurd (congrFun hz ⟨0, by omega⟩) (by decide)
  exact hexcl extZIntXT extProbeChi hzne
    ⟨v, (extZ_intXT_holds_iff M w x t v hwx).mpr ⟨hxv, hvt⟩, hχv⟩

end ExteriorFiberKit

end FormalSystem.Metalogic.WeakCanonical.Kamp
