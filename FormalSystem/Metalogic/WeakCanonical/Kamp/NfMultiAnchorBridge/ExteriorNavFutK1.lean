/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNavPastK1

/-! # Until-navigated future-exterior mirror `CExtFut`

The `t < w` channel: the time-reversed mirror of the delivered past-exterior stack E1-E4
(`ExteriorFiberKitK1.lean` + `ExteriorNavPastK1.lean`) for the future-exterior ambient
`x < t < w` over the SAME env `[w, x, t]` (position 0 = the exterior witness `w`,
positions 1, 2 = the pins `x`, `t` — the Phase-16a dispatcher convention).

## E6 decision (RECORDED): duplication fallback

The optional shared `extDuality` (E6) is NOT landed: no `M`-reversal (OrderDual
`OrderedMonadicStructure` instance + Since/Until formula-duality transport + σ order-atom
reindexing) exists anywhere in `WeakCanonical`, matching the plan's H4 flag (Rabinovich
chunk_0022 says only "proved similarly" for Lemma 7.8(2)). The codebase's own precedent
for time-reversed mirrors (`ExteriorNegationPast.lean`) is explicit duplication. This
module therefore duplicates the E1-E4 shapes with orders reversed, exactly as the plan's
fallback prescribes.

## Structure (mirror inventory)

1. **Future zone kit (E1 mirror)**: the 7 order-consistent zones of `x < t < w`
   (`v<x, v=x, x<v<t, v=t, t<v<w, v=w, w<v`) as fresh constants `extFZ*`, their
   `zoneHolds` readings, the routing lemma `extFZone_consistent_lt`, the
   inconsistent-fiber falsity `extFZone_inconsistent_false`, and the 7-zone partition
   `extZoneFiberFut_k1`.
2. **Until-navigated w-package (E2 mirror)**: `navRAtWPack` (atoms at `w`; zone `v = w`
   characteristics; zone `w < v` native future Until-lits `U(charF χ, ⊤)`), the `(t, w)`
   exclusion segment `navRSegGuard`, the nested-Until chain `navRChain` (Lemma 7.10 shape,
   time-reversed: witnesses threaded ASCENDING by repeated minimum extraction), and
   `navPackRight` + **`navPackRight_correct`** — the fold iff at the pin `t`.
3. **w-independent distribution (E3 mirror)**: `navRAtXPack` (`endpointLeft` content:
   atoms at `x`; zone `v = x`; zone `v < x` native past Since-lits), the `(x, t)` bracket
   arrangement `navRXTBracket` over the FUTURE-channel interior fibers `extFZIntXT`,
   `navRAtTPack` (the t-endpoint conjunct: atoms at `t`; zone `v = t`), the order-channel
   row `navROrderRow`, and **`navDistribRight`**.
4. **Carrier (E4 mirror)**: the gate `navRGate`, the dite carrier `CExtFut`
   (`agg2Past`/`CExtPast` pattern; empty disjunction off-gate), the ∃w pin glue
   **`CExtFut_correct`**, and the 3-bot falsity trio `navR_inconsistent_eval_false` /
   `CExtFut_offGate_false` / `CExtFut_inconsistent_false`.

## Devices (per fiber class — the Phase 15 record, mirroring Phase 14a)

| Fiber class | bit-TRUE device | bit-FALSE device |
|---|---|---|
| atoms at `w` | `nf_depth0_char_formula` on the position-0 projection | (same conjunction, literal
polarity) |
| zone `v = w` | characteristic conjunct `charF χ` at the Until-witness | negated characteristic |
| zone `w < v` | native future Until-lit `U(charF χ, ⊤)` (`navDFutLit`) | negated Until-lit |
| zone `t < v < w` | arrangement slot inside the fold (nested-Until chain `navRChain`) | exclusion
segment `navRSegGuard` |
| zone `v < x` | native past Since-lit `S(charF χ, ⊤)` (`navLPastLit`) at the pin `x` | negated
Since-lit |

## Guards

G1 — lossless re-fibering only; the `∃w` stays honest (it is literally the RHS binder).
G2/G4 — anchors exactly `{x, t}` plus the exterior witness `w` laid by the `∃w` glue at
the pin `t`; no interior point enters an env. G5 — every bridge is a manual
`constructor`/`intro`/`exact` step. FORBIDDEN `nf_char3_deeper_split` is not referenced.
No frozen file is touched.

## References

- Rabinovich 2014, "A Proof of Kamp's Theorem": **Lemma 7.8(2)** TL(Until, K⁻) duality
  (chunk_0022) — realized here by duplication (see the E6 decision above); Lemma 7.10 /
  Prop 3.5 one-free-variable fold (chunks 0023, 0010); Lemma 7.6 gluing (chunk_0021).
- Consumed by name (public Phase 13/14 assets): `ext3Mk`, `ext3_zoneHolds_cons_iff`,
  `agg2Ltz/agg2Eqz/agg2Gtz`, `k1v_bool_eq_false`, `nf_eval_depth1_fold_iff`,
  `nf0_assemble` + split-kit round-trips, `navLProjW`/`navDProjX`/`navDProjT`,
  `navLPastLit`, `navDFutLit`.
- The negfix-refactor design for the exterior carriers, Phase 15 (E5 + E6 — the future-side
  navigators).
-/

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Metalogic.WeakCanonical.Separation

section ExteriorNavFut

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
variable (atomMap : Formula → sig.preds)
variable (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)

/-! ## The 7 order-consistent zones of `x < t < w` (E1 mirror, arity-3 zone constants)

Env `[w, x, t]` (same as the past channel): position 0 = the exterior witness `w`,
position 1 = the pin `x`, position 2 = the origin `t`. Under the FUTURE ambient
`x < t < w` the 7 order-consistent witness positions are
`v<x, v=x, x<v<t, v=t, t<v<w, v=w, w<v`. -/

/-- `v < x` (past exterior of all three anchors; under `x < t < w` also `v < t`, `v < w`). -/
def extFZBelowX : ZoneSpec 3 := ext3Mk agg2Ltz agg2Ltz agg2Ltz
/-- `v = x` (at the pin `x`; under `x < t < w` also `v < t`, `v < w`). -/
def extFZAtX : ZoneSpec 3 := ext3Mk agg2Ltz agg2Eqz agg2Ltz
/-- `x < v < t` (bounded interior between the pins; under `x < t < w` also `v < w`). -/
def extFZIntXT : ZoneSpec 3 := ext3Mk agg2Ltz agg2Gtz agg2Ltz
/-- `v = t` (at the origin; under `x < t < w` also `x < v`, `v < w`). -/
def extFZAtT : ZoneSpec 3 := ext3Mk agg2Ltz agg2Gtz agg2Eqz
/-- `t < v < w` (bounded interior between the origin and the witness). -/
def extFZIntTW : ZoneSpec 3 := ext3Mk agg2Ltz agg2Gtz agg2Gtz
/-- `v = w` (at the exterior witness). -/
def extFZAtW : ZoneSpec 3 := ext3Mk agg2Eqz agg2Gtz agg2Gtz
/-- `w < v` (future exterior of the witness, hence of all three anchors). -/
def extFZAboveW : ZoneSpec 3 := ext3Mk agg2Gtz agg2Gtz agg2Gtz

/-- Pointwise equality builder for an arity-3 zone spec from its three coordinates
    (local copy of the Phase-13 private `ext3_zs_ext`). -/
private theorem extF_zs_ext {zs : ZoneSpec 3} (pw px pt : Bool × Bool)
    (e0 : zs ⟨0, by omega⟩ = pw) (e1 : zs ⟨1, by omega⟩ = px)
    (e2 : zs ⟨2, by omega⟩ = pt) :
    zs = ext3Mk pw px pt := by
  funext i
  match i with
  | ⟨0, _⟩ => exact e0
  | ⟨1, _⟩ => exact e1
  | ⟨2, _⟩ => exact e2

/-! ### Per-zone `zoneHolds` simplifications under the ambient order `x < t < w` -/

/-- Zone `v < x`. -/
theorem extFZ_belowX_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hxt : x < t) (htw : t < w) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extFZBelowX u ↔ u < x := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Ltz agg2Ltz agg2Ltz) ?_
  constructor
  · rintro ⟨-, ⟨h, -⟩, -⟩
    exact h.mpr rfl
  · intro h
    have hut : u < t := h.trans hxt
    have huw : u < w := hut.trans htw
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_true h rfl, iff_of_false (lt_asymm h) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (fun hf => Bool.noConfusion hf)⟩⟩

/-- Zone `v = x`. -/
theorem extFZ_atX_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hxt : x < t) (htw : t < w) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extFZAtX u ↔ u = x := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Ltz agg2Eqz agg2Ltz) ?_
  constructor
  · rintro ⟨-, ⟨h1, h2⟩, -⟩
    rcases lt_trichotomy u x with h | h | h
    · exact absurd (h1.mp h) (fun hf => Bool.noConfusion hf)
    · exact h
    · exact absurd (h2.mp h) (fun hf => Bool.noConfusion hf)
  · rintro rfl
    have hut : u < t := hxt
    have huw : u < w := hut.trans htw
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf),
        iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (fun hf => Bool.noConfusion hf)⟩⟩

/-- Zone `x < v < t`. -/
theorem extFZ_intXT_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (htw : t < w) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extFZIntXT u ↔ x < u ∧ u < t := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Ltz agg2Gtz agg2Ltz) ?_
  constructor
  · rintro ⟨-, ⟨-, h1⟩, ⟨h2, -⟩⟩
    exact ⟨h1.mpr rfl, h2.mpr rfl⟩
  · rintro ⟨hxu, hut⟩
    have huw : u < w := hut.trans htw
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_false (lt_asymm hxu) (fun hf => Bool.noConfusion hf), iff_of_true hxu rfl⟩,
      ⟨iff_of_true hut rfl, iff_of_false (lt_asymm hut) (fun hf => Bool.noConfusion hf)⟩⟩

/-- Zone `v = t`. -/
theorem extFZ_atT_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hxt : x < t) (htw : t < w) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extFZAtT u ↔ u = t := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Ltz agg2Gtz agg2Eqz) ?_
  constructor
  · rintro ⟨-, -, ⟨h1, h2⟩⟩
    rcases lt_trichotomy u t with h | h | h
    · exact absurd (h1.mp h) (fun hf => Bool.noConfusion hf)
    · exact h
    · exact absurd (h2.mp h) (fun hf => Bool.noConfusion hf)
  · rintro rfl
    have hxu : x < u := hxt
    have huw : u < w := htw
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_false (lt_asymm hxu) (fun hf => Bool.noConfusion hf), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf),
        iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf)⟩⟩

/-- Zone `t < v < w`. -/
theorem extFZ_intTW_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hxt : x < t) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extFZIntTW u ↔ t < u ∧ u < w := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Ltz agg2Gtz agg2Gtz) ?_
  constructor
  · rintro ⟨⟨h1, -⟩, -, ⟨-, h2⟩⟩
    exact ⟨h2.mpr rfl, h1.mpr rfl⟩
  · rintro ⟨htu, huw⟩
    have hxu : x < u := hxt.trans htu
    exact ⟨⟨iff_of_true huw rfl, iff_of_false (lt_asymm huw) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_false (lt_asymm hxu) (fun hf => Bool.noConfusion hf), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_asymm htu) (fun hf => Bool.noConfusion hf), iff_of_true htu rfl⟩⟩

/-- Zone `v = w`. -/
theorem extFZ_atW_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hxt : x < t) (htw : t < w) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extFZAtW u ↔ u = w := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Eqz agg2Gtz agg2Gtz) ?_
  constructor
  · rintro ⟨⟨h1, h2⟩, -, -⟩
    rcases lt_trichotomy u w with h | h | h
    · exact absurd (h1.mp h) (fun hf => Bool.noConfusion hf)
    · exact h
    · exact absurd (h2.mp h) (fun hf => Bool.noConfusion hf)
  · rintro rfl
    have htu : t < u := htw
    have hxu : x < u := hxt.trans htu
    exact ⟨⟨iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf),
        iff_of_false (lt_irrefl u) (fun hf => Bool.noConfusion hf)⟩,
      ⟨iff_of_false (lt_asymm hxu) (fun hf => Bool.noConfusion hf), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_asymm htu) (fun hf => Bool.noConfusion hf), iff_of_true htu rfl⟩⟩

/-- Zone `w < v`. -/
theorem extFZ_aboveW_holds_iff (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hxt : x < t) (htw : t < w) :
    zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier)
      extFZAboveW u ↔ w < u := by
  refine Iff.trans
    (ext3_zoneHolds_cons_iff M w x t u agg2Gtz agg2Gtz agg2Gtz) ?_
  constructor
  · rintro ⟨⟨-, h⟩, -, -⟩
    exact h.mpr rfl
  · intro h
    have htu : t < u := htw.trans h
    have hxu : x < u := hxt.trans htu
    exact ⟨⟨iff_of_false (lt_asymm h) (fun hf => Bool.noConfusion hf), iff_of_true h rfl⟩,
      ⟨iff_of_false (lt_asymm hxu) (fun hf => Bool.noConfusion hf), iff_of_true hxu rfl⟩,
      ⟨iff_of_false (lt_asymm htu) (fun hf => Bool.noConfusion hf), iff_of_true htu rfl⟩⟩

/-! ### Routing: zone consistency + inconsistent-fiber falsity (future ambient) -/

/-- **Future-exterior routing lemma** (`x < t < w`): a realized arity-3 zone spec is one
    of the seven consistent zones `v<x` / `v=x` / `x<v<t` / `v=t` / `t<v<w` / `v=w` /
    `w<v`. -/
theorem extFZone_consistent_lt (M : OrderedMonadicStructure sig)
    (w x t u : M.carrier) (hxt : x < t) (htw : t < w)
    (zs : ZoneSpec 3)
    (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs u) :
    zs = extFZBelowX ∨ zs = extFZAtX ∨ zs = extFZIntXT ∨ zs = extFZAtT ∨
    zs = extFZIntTW ∨ zs = extFZAtW ∨ zs = extFZAboveW := by
  have h0 := hz ⟨0, by omega⟩
  have h1 := hz ⟨1, by omega⟩
  have h2 := hz ⟨2, by omega⟩
  simp only [Fin.cons] at h0 h1 h2
  rcases lt_trichotomy u x with hux | hux | hux
  · -- u < x < t < w : zone `v < x`.
    have hut : u < t := hux.trans hxt
    have huw : u < w := hut.trans htw
    exact Or.inl (extF_zs_ext _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨h1.1.mp hux, k1v_bool_eq_false h1.2 (lt_asymm hux)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))
  · -- u = x : zone `v = x`.
    subst hux
    have hut : u < t := hxt
    have huw : u < w := hut.trans htw
    exact Or.inr (Or.inl (extF_zs_ext _ _ _
      (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
      (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_irrefl u),
        k1v_bool_eq_false h1.2 (lt_irrefl u)⟩)
      (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩)))
  · -- x < u : split against t.
    rcases lt_trichotomy u t with hut | hut | hut
    · -- x < u < t : bounded interior `(x, t)`.
      have huw : u < w := hut.trans htw
      exact Or.inr (Or.inr (Or.inl (extF_zs_ext _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨h2.1.mp hut, k1v_bool_eq_false h2.2 (lt_asymm hut)⟩))))
    · -- u = t : zone `v = t`.
      subst hut
      have huw : u < w := htw
      exact Or.inr (Or.inr (Or.inr (Or.inl (extF_zs_ext _ _ _
        (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
        (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_irrefl u),
          k1v_bool_eq_false h2.2 (lt_irrefl u)⟩)))))
    · -- t < u : split against w.
      rcases lt_trichotomy u w with huw | huw | huw
      · -- t < u < w : bounded interior `(t, w)`.
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (extF_zs_ext _ _ _
          (Prod.ext_iff.mpr ⟨h0.1.mp huw, k1v_bool_eq_false h0.2 (lt_asymm huw)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hut), h2.2.mp hut⟩))))))
      · -- u = w : zone `v = w`.
        subst huw
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl (extF_zs_ext _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_irrefl u),
            k1v_bool_eq_false h0.2 (lt_irrefl u)⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hut), h2.2.mp hut⟩)))))))
      · -- w < u : future exterior.
        exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (extF_zs_ext _ _ _
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h0.1 (lt_asymm huw), h0.2.mp huw⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h1.1 (lt_asymm hux), h1.2.mp hux⟩)
          (Prod.ext_iff.mpr ⟨k1v_bool_eq_false h2.1 (lt_asymm hut), h2.2.mp hut⟩)))))))

/-- **Inconsistent-fiber falsity (future ambient)**: under any realizer of a depth-1
    arity-3 evaluation at `[w, x, t]` with `x < t < w`, the fold bit of every
    order-channel-inconsistent fiber is `false`. -/
theorem extFZone_inconsistent_false (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxt : x < t) (htw : t < w)
    (σ : NormalForm sig 1 3)
    (hnf : nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ)
    (zs : ZoneSpec 3)
    (hcons : ¬(zs = extFZBelowX ∨ zs = extFZAtX ∨ zs = extFZIntXT ∨ zs = extFZAtT ∨
      zs = extFZIntTW ∨ zs = extFZAtW ∨ zs = extFZAboveW))
    (χ : NormalForm sig 0 1) :
    σ.2 (nf0_assemble zs χ σ.1) = false := by
  obtain ⟨-, hfold, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hnf
  cases hb : σ.2 (nf0_assemble zs χ σ.1) with
  | false => rfl
  | true =>
    obtain ⟨v, hzv, -⟩ := (hfold zs χ).mpr hb
    exact absurd (extFZone_consistent_lt M w x t v hxt htw zs hzv) hcons

/-! ### The 7-zone fiber partition (`extZoneFiberFut_k1`, future ambient) -/

/-- The depth-1 fold at n=3, env `[w, x, t]`, re-partitioned into MONADIC clauses over
    the 7 order-consistent zones of `x < t < w` (the future-ambient mirror of
    `extZoneFiber_k1`): per-zone biconditional fiber clauses + the inconsistent-zone
    falsity conjunct + the off-fiber honesty clause. -/
theorem extZoneFiberFut_k1 (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (hxt : x < t) (htw : t < w) (σ : NormalForm sig 1 3) :
    nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ ↔
      ((∀ a : AtomKind sig 3,
          atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ σ.1 a = true) ∧
       ((∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, v < x ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extFZBelowX χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           nf_eval_nf M 0 1 (fun _ => x) χ ↔
             σ.2 (nf0_assemble extFZAtX χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, x < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extFZIntXT χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           nf_eval_nf M 0 1 (fun _ => t) χ ↔
             σ.2 (nf0_assemble extFZAtT χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, t < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extFZIntTW χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           nf_eval_nf M 0 1 (fun _ => w) χ ↔
             σ.2 (nf0_assemble extFZAtW χ σ.1) = true) ∧
        (∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, w < v ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extFZAboveW χ σ.1) = true)) ∧
       (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
          ¬(zs = extFZBelowX ∨ zs = extFZAtX ∨ zs = extFZIntXT ∨ zs = extFZAtT ∨
            zs = extFZIntTW ∨ zs = extFZAtW ∨ zs = extFZAboveW) →
          σ.2 (nf0_assemble zs χ σ.1) = false) ∧
       (∀ τ : NormalForm sig 0 4, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)) := by
  rw [nf_eval_depth1_fold_iff]
  constructor
  · rintro ⟨hatom, hfold, hoff⟩
    refine ⟨hatom, ⟨?_, ?_, ?_, ?_, ?_, ?_, ?_⟩, ?_, hoff⟩
    · -- Zone `v < x`.
      intro χ
      refine Iff.trans ?_ (hfold extFZBelowX χ)
      refine exists_congr fun v => ?_
      rw [extFZ_belowX_holds_iff M w x t v hxt htw]
    · -- Zone `v = x`.
      intro χ
      refine Iff.trans ?_ (hfold extFZAtX χ)
      constructor
      · intro h
        exact ⟨x, (extFZ_atX_holds_iff M w x t x hxt htw).mpr rfl, h⟩
      · rintro ⟨v, hzv, h⟩
        rw [(extFZ_atX_holds_iff M w x t v hxt htw).mp hzv] at h
        exact h
    · -- Zone `x < v < t`.
      intro χ
      refine Iff.trans ?_ (hfold extFZIntXT χ)
      refine exists_congr fun v => ?_
      rw [extFZ_intXT_holds_iff M w x t v htw]
      exact and_assoc.symm
    · -- Zone `v = t`.
      intro χ
      refine Iff.trans ?_ (hfold extFZAtT χ)
      constructor
      · intro h
        exact ⟨t, (extFZ_atT_holds_iff M w x t t hxt htw).mpr rfl, h⟩
      · rintro ⟨v, hzv, h⟩
        rw [(extFZ_atT_holds_iff M w x t v hxt htw).mp hzv] at h
        exact h
    · -- Zone `t < v < w`.
      intro χ
      refine Iff.trans ?_ (hfold extFZIntTW χ)
      refine exists_congr fun v => ?_
      rw [extFZ_intTW_holds_iff M w x t v hxt]
      exact and_assoc.symm
    · -- Zone `v = w`.
      intro χ
      refine Iff.trans ?_ (hfold extFZAtW χ)
      constructor
      · intro h
        exact ⟨w, (extFZ_atW_holds_iff M w x t w hxt htw).mpr rfl, h⟩
      · rintro ⟨v, hzv, h⟩
        rw [(extFZ_atW_holds_iff M w x t v hxt htw).mp hzv] at h
        exact h
    · -- Zone `w < v`.
      intro χ
      refine Iff.trans ?_ (hfold extFZAboveW χ)
      refine exists_congr fun v => ?_
      rw [extFZ_aboveW_holds_iff M w x t v hxt htw]
    · -- Inconsistent-zone falsity.
      intro zs χ hcons
      cases hb : σ.2 (nf0_assemble zs χ σ.1) with
      | false => rfl
      | true =>
        obtain ⟨v, hzv, -⟩ := (hfold zs χ).mpr hb
        exact absurd (extFZone_consistent_lt M w x t v hxt htw zs hzv) hcons
  · rintro ⟨hatom, ⟨h1, h2, h3, h4, h5, h6, h7⟩, hbad, hoff⟩
    refine ⟨hatom, ?_, hoff⟩
    intro zs χ
    by_cases hcons : zs = extFZBelowX ∨ zs = extFZAtX ∨ zs = extFZIntXT ∨ zs = extFZAtT ∨
        zs = extFZIntTW ∨ zs = extFZAtW ∨ zs = extFZAboveW
    · rcases hcons with rfl | rfl | rfl | rfl | rfl | rfl | rfl
      · -- Zone `v < x`.
        refine Iff.trans ?_ (h1 χ)
        refine exists_congr fun v => ?_
        rw [extFZ_belowX_holds_iff M w x t v hxt htw]
      · -- Zone `v = x`.
        refine Iff.trans ?_ (h2 χ)
        constructor
        · rintro ⟨v, hzv, h⟩
          rw [(extFZ_atX_holds_iff M w x t v hxt htw).mp hzv] at h
          exact h
        · intro h
          exact ⟨x, (extFZ_atX_holds_iff M w x t x hxt htw).mpr rfl, h⟩
      · -- Zone `x < v < t`.
        refine Iff.trans ?_ (h3 χ)
        refine exists_congr fun v => ?_
        rw [extFZ_intXT_holds_iff M w x t v htw]
        exact and_assoc
      · -- Zone `v = t`.
        refine Iff.trans ?_ (h4 χ)
        constructor
        · rintro ⟨v, hzv, h⟩
          rw [(extFZ_atT_holds_iff M w x t v hxt htw).mp hzv] at h
          exact h
        · intro h
          exact ⟨t, (extFZ_atT_holds_iff M w x t t hxt htw).mpr rfl, h⟩
      · -- Zone `t < v < w`.
        refine Iff.trans ?_ (h5 χ)
        refine exists_congr fun v => ?_
        rw [extFZ_intTW_holds_iff M w x t v hxt]
        exact and_assoc
      · -- Zone `v = w`.
        refine Iff.trans ?_ (h6 χ)
        constructor
        · rintro ⟨v, hzv, h⟩
          rw [(extFZ_atW_holds_iff M w x t v hxt htw).mp hzv] at h
          exact h
        · intro h
          exact ⟨w, (extFZ_atW_holds_iff M w x t w hxt htw).mpr rfl, h⟩
      · -- Zone `w < v`.
        refine Iff.trans ?_ (h7 χ)
        refine exists_congr fun v => ?_
        rw [extFZ_aboveW_holds_iff M w x t v hxt htw]
    · -- Inconsistent zone: bit is false, existential refuted by routing.
      refine iff_of_false ?_ ?_
      · rintro ⟨v, hzv, -⟩
        exact absurd (extFZone_consistent_lt M w x t v hxt htw zs hzv) hcons
      · rw [hbad zs χ hcons]
        exact fun hf => Bool.noConfusion hf

/-! ## Local profile helpers (the ExteriorNavPastK1.lean private idiom, re-derived) -/

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Monadic-profile evaluation unfolds to the per-predicate reading (the `AtomKind sig 1`
    order case is uninhabited). -/
private theorem navR_profile_iff (M : OrderedMonadicStructure sig)
    (v : M.carrier) (χ : NormalForm sig 0 1) :
    nf_eval_nf M 0 1 (fun _ => v) χ ↔
      (∀ p : sig.preds, M.interp p v ↔ χ (.pred p 0) = true) := by
  constructor
  · intro h p
    exact h (.pred p 0)
  · intro h a
    match a with
    | .pred p i =>
      have hi : i = 0 := Subsingleton.elim i 0
      subst hi
      exact h p
    | .order i j hij => exact absurd (Subsingleton.elim i j) hij

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Profiles realized by the same point coincide. -/
private theorem navR_profile_unique (M : OrderedMonadicStructure sig)
    (v : M.carrier) (χ χ' : NormalForm sig 0 1)
    (h : nf_eval_nf M 0 1 (fun _ => v) χ) (h' : nf_eval_nf M 0 1 (fun _ => v) χ') :
    χ = χ' := by
  funext a
  match a with
  | .pred p i =>
    have hi : i = 0 := Subsingleton.elim i 0
    subst hi
    have := ((h (.pred p 0)).symm.trans (h' (.pred p 0)))
    cases hχ : χ (.pred p 0) <;> cases hχ' : χ' (.pred p 0) <;> simp_all
  | .order i j hij => exact absurd (Subsingleton.elim i j) hij

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Every point realizes its depth-0 monadic characteristic. -/
private theorem navR_profile_exists (M : OrderedMonadicStructure sig) (v : M.carrier) :
    ∃ χ : NormalForm sig 0 1, nf_eval_nf M 0 1 (fun _ => v) χ :=
  ⟨nf_characteristic M 0 1 (fun _ => v), nf_characteristic_satisfies M 0 1 (fun _ => v)⟩

omit [DecidableEq sig.preds] in
/-- Depth-0 characteristic-formula correctness in `nf_eval` form (local copy). -/
private theorem navR_char_correct (M : OrderedMonadicStructure sig)
    (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (nf_depth0_char_formula atomMap h_surj χ) ↔
      nf_eval_nf M 0 1 (fun _ => u) χ := by
  rw [nf_depth0_char_formula_correct]
  exact (navR_profile_iff M u χ).symm

/-- Generic polarity-group reading: the conjunction over ALL monadic profiles of the
    bit-directed literal holds iff every profile's semantic clause matches its bit
    (local copy of the Phase-14a private `navL_bitGroup_iff`). -/
private theorem navR_bitGroup_iff (M : OrderedMonadicStructure sig) (u : M.carrier)
    (bit : NormalForm sig 0 1 → Bool) (lit : NormalForm sig 0 1 → Formula)
    (P : NormalForm sig 0 1 → Prop)
    (hlit : ∀ χ, temporal_truth M atomMap u (lit χ) ↔ P χ) :
    temporal_truth M atomMap u (formula_conjList
      (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
        if bit χ = true then lit χ else (lit χ).neg)) ↔
    ∀ χ : NormalForm sig 0 1, P χ ↔ bit χ = true := by
  rw [formula_conjList_iff]
  constructor
  · intro h χ
    have hmem : (if bit χ = true then lit χ else (lit χ).neg) ∈
        ((Finset.univ : Finset (NormalForm sig 0 1)).toList).map
          (fun χ => if bit χ = true then lit χ else (lit χ).neg) :=
      List.mem_map.mpr ⟨χ, Finset.mem_toList.mpr (Finset.mem_univ χ), rfl⟩
    have hφ := h _ hmem
    by_cases hb : bit χ = true
    · rw [if_pos hb] at hφ
      exact iff_of_true ((hlit χ).mp hφ) hb
    · rw [if_neg hb] at hφ
      exact iff_of_false (fun hP => (temporal_truth_neg M atomMap u (lit χ)).mp hφ
        ((hlit χ).mpr hP)) hb
  · intro h φ hmem
    obtain ⟨χ, -, rfl⟩ := List.mem_map.mp hmem
    by_cases hb : bit χ = true
    · rw [if_pos hb]
      exact (hlit χ).mpr ((h χ).mpr hb)
    · rw [if_neg hb]
      exact (temporal_truth_neg M atomMap u (lit χ)).mpr
        (fun hφ => hb ((h χ).mp ((hlit χ).mp hφ)))

omit [DecidableEq sig.preds] in
/-- Reading of the future Until-lit `navDFutLit` (local copy of the Phase-14b private
    `navD_futLit_iff`). -/
private theorem navR_futLit_iff (M : OrderedMonadicStructure sig)
    (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (navDFutLit atomMap h_surj χ) ↔
      ∃ v : M.carrier, u < v ∧ nf_eval_nf M 0 1 (fun _ => v) χ := by
  simp only [navDFutLit, temporal_truth]
  constructor
  · rintro ⟨s, hus, hφ, -⟩
    exact ⟨s, hus, (navR_char_correct atomMap h_surj M χ s).mp hφ⟩
  · rintro ⟨v, huv, hχ⟩
    exact ⟨v, huv, (navR_char_correct atomMap h_surj M χ v).mpr hχ,
      fun r _ _ => temporal_truth_top M atomMap r⟩

omit [DecidableEq sig.preds] in
/-- Reading of the past Since-lit `navLPastLit` (local copy of the Phase-14a private
    `navL_pastLit_iff`). -/
private theorem navR_pastLit_iff (M : OrderedMonadicStructure sig)
    (χ : NormalForm sig 0 1) (u : M.carrier) :
    temporal_truth M atomMap u (navLPastLit atomMap h_surj χ) ↔
      ∃ v : M.carrier, v < u ∧ nf_eval_nf M 0 1 (fun _ => v) χ := by
  simp only [navLPastLit, temporal_truth]
  constructor
  · rintro ⟨s, hsu, hφ, -⟩
    exact ⟨s, hsu, (navR_char_correct atomMap h_surj M χ s).mp hφ⟩
  · rintro ⟨v, hvu, hχ⟩
    exact ⟨v, hvu, (navR_char_correct atomMap h_surj M χ v).mpr hχ,
      fun r _ _ => temporal_truth_top M atomMap r⟩

/-! ## The w-point package: atoms at `w`, zone `v = w`, zone `w < v` (E2 mirror) -/

/-- **The future w-point package**: atoms at `w` (position-0 projection characteristic —
    `navLProjW`, reused), the `v = w` fiber group (characteristic literals over
    `extFZAtW`), and the `w < v` fiber group (native future Until-lits `navDFutLit` over
    `extFZAboveW`, negated on bit-false fibers). Time-reversed mirror of `navLAtWPack`. -/
noncomputable def navRAtWPack (σ : NormalForm sig 1 3) : Formula :=
  formula_conjList
    [nf_depth0_char_formula atomMap h_surj (navLProjW σ.1),
     formula_conjList
       (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
         if σ.2 (nf0_assemble extFZAtW χ σ.1) = true
         then nf_depth0_char_formula atomMap h_surj χ
         else (nf_depth0_char_formula atomMap h_surj χ).neg),
     formula_conjList
       (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
         if σ.2 (nf0_assemble extFZAboveW χ σ.1) = true
         then navDFutLit atomMap h_surj χ
         else (navDFutLit atomMap h_surj χ).neg)]

/-- Reading of the future w-point package: exactly the three w-anchored clause groups of
    `extZoneFiberFut_k1` (atom layer restricted to position 0; `v = w`; `w < v`). -/
private theorem navR_atWPack_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w : M.carrier) :
    temporal_truth M atomMap w (navRAtWPack atomMap h_surj σ) ↔
      ((∀ p : sig.preds, M.interp p w ↔ σ.1 (.pred p ⟨0, by omega⟩) = true) ∧
       (∀ χ : NormalForm sig 0 1,
         nf_eval_nf M 0 1 (fun _ => w) χ ↔ σ.2 (nf0_assemble extFZAtW χ σ.1) = true) ∧
       (∀ χ : NormalForm sig 0 1,
         (∃ v : M.carrier, w < v ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
           σ.2 (nf0_assemble extFZAboveW χ σ.1) = true)) := by
  simp only [navRAtWPack, formula_conjList]
  rw [temporal_truth_and, temporal_truth_and, temporal_truth_and]
  have htop : temporal_truth M atomMap w Formula.top := temporal_truth_top M atomMap w
  constructor
  · rintro ⟨h1, h2, h3, -⟩
    refine ⟨?_, ?_, ?_⟩
    · intro p
      have := (nf_depth0_char_formula_correct M atomMap h_surj (navLProjW σ.1) w).mp h1 p
      exact this
    · exact (navR_bitGroup_iff atomMap M w _ _ _
        (fun χ => navR_char_correct atomMap h_surj M χ w)).mp h2
    · exact (navR_bitGroup_iff atomMap M w _ _ _
        (fun χ => navR_futLit_iff atomMap h_surj M χ w)).mp h3
  · rintro ⟨h1, h2, h3⟩
    refine ⟨?_, ?_, ?_, htop⟩
    · exact (nf_depth0_char_formula_correct M atomMap h_surj (navLProjW σ.1) w).mpr h1
    · exact (navR_bitGroup_iff atomMap M w _ _ _
        (fun χ => navR_char_correct atomMap h_surj M χ w)).mpr h2
    · exact (navR_bitGroup_iff atomMap M w _ _ _
        (fun χ => navR_futLit_iff atomMap h_surj M χ w)).mpr h3

/-! ## The `(t, w)` exclusion segment -/

/-- The bit-TRUE `t < v < w` fiber profiles of `σ` (the arrangement-slot inventory). -/
noncomputable def navRBitTrueList (σ : NormalForm sig 1 3) :
    List (NormalForm sig 0 1) :=
  ((Finset.univ : Finset (NormalForm sig 0 1)).filter
    fun χ => σ.2 (nf0_assemble extFZIntTW χ σ.1) = true).toList

private theorem navR_bitTrueList_mem (σ : NormalForm sig 1 3)
    (χ : NormalForm sig 0 1) :
    χ ∈ navRBitTrueList σ ↔ σ.2 (nf0_assemble extFZIntTW χ σ.1) = true := by
  simp [navRBitTrueList, Finset.mem_toList, Finset.mem_filter]

private theorem navR_bitTrueList_nodup (σ : NormalForm sig 1 3) :
    (navRBitTrueList σ).Nodup :=
  Finset.nodup_toList _

/-- **The `(t, w)` exclusion segment**: the disjunction of the bit-TRUE characteristics
    (time-reversed mirror of `navLSegGuard`). -/
noncomputable def navRSegGuard (σ : NormalForm sig 1 3) : Formula :=
  formula_disjList
    ((navRBitTrueList σ).map (nf_depth0_char_formula atomMap h_surj))

/-- Reading of the exclusion segment. -/
private theorem navR_segGuard_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (v : M.carrier) :
    temporal_truth M atomMap v (navRSegGuard atomMap h_surj σ) ↔
      ∃ χ : NormalForm sig 0 1, σ.2 (nf0_assemble extFZIntTW χ σ.1) = true ∧
        nf_eval_nf M 0 1 (fun _ => v) χ := by
  simp only [navRSegGuard]
  rw [formula_disjList_iff]
  constructor
  · rintro ⟨φ, hmem, hφ⟩
    obtain ⟨χ, hχmem, rfl⟩ := List.mem_map.mp hmem
    exact ⟨χ, (navR_bitTrueList_mem σ χ).mp hχmem,
      (navR_char_correct atomMap h_surj M χ v).mp hφ⟩
  · rintro ⟨χ, hbit, hχ⟩
    exact ⟨_, List.mem_map.mpr ⟨χ, (navR_bitTrueList_mem σ χ).mpr hbit, rfl⟩,
      (navR_char_correct atomMap h_surj M χ v).mpr hχ⟩

/-! ## The nested-Until arrangement chain (Lemma 7.10 shape, time-reversed) -/

/-- Nested-Until arrangement chain: one Until step per listed profile (listed from the
    BOTTOM slot nearest `t` upward), each guarded by the exclusion segment, anchored at
    the future w-point package. The time-reversed mirror of `navLChain`. -/
noncomputable def navRChain (σ : NormalForm sig 1 3) :
    List (NormalForm sig 0 1) → Formula
  | [] => Formula.untl (navRAtWPack atomMap h_surj σ) (navRSegGuard atomMap h_surj σ)
  | χ :: rest => Formula.untl
      (Formula.and (nf_depth0_char_formula atomMap h_surj χ) (navRChain σ rest))
      (navRSegGuard atomMap h_surj σ)

/-- **Chain soundness**: a chain at `u` yields the anchor `u < w` carrying the future
    w-point package, one witness per listed profile inside `(u, w)`, and the exclusion
    segment (or a listed witness profile) at every interior point. -/
private theorem navR_chain_sound (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) :
    ∀ (L : List (NormalForm sig 0 1)) (u : M.carrier),
      temporal_truth M atomMap u (navRChain atomMap h_surj σ L) →
      ∃ w : M.carrier, u < w ∧
        temporal_truth M atomMap w (navRAtWPack atomMap h_surj σ) ∧
        (∀ χ ∈ L, ∃ v : M.carrier, u < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ∧
        (∀ v : M.carrier, u < v → v < w →
          temporal_truth M atomMap v (navRSegGuard atomMap h_surj σ) ∨
            ∃ χ ∈ L, nf_eval_nf M 0 1 (fun _ => v) χ) := by
  intro L
  induction L with
  | nil =>
    intro u h
    simp only [navRChain, temporal_truth] at h
    obtain ⟨s, hus, hpack, hguard⟩ := h
    exact ⟨s, hus, hpack, fun χ hχ => absurd hχ List.not_mem_nil,
      fun v huv hvs => Or.inl (hguard v huv hvs)⟩
  | cons χ1 rest ih =>
    intro u h
    simp only [navRChain, temporal_truth] at h
    obtain ⟨s, hus, hand, hguard⟩ := h
    rw [temporal_truth_and] at hand
    obtain ⟨hχ1s, hrest⟩ := hand
    obtain ⟨w, hsw, hpack, hwit, hseg⟩ := ih s hrest
    refine ⟨w, hus.trans hsw, hpack, ?_, ?_⟩
    · intro χ hχmem
      rcases List.mem_cons.mp hχmem with rfl | hmem
      · exact ⟨s, hus, hsw, (navR_char_correct atomMap h_surj M χ s).mp hχ1s⟩
      · obtain ⟨v, hsv, hvw, hv⟩ := hwit χ hmem
        exact ⟨v, hus.trans hsv, hvw, hv⟩
    · intro v huv hvw
      rcases lt_trichotomy v s with hvs | rfl | hsv
      · exact Or.inl (hguard v huv hvs)
      · exact Or.inr ⟨χ1, List.mem_cons_self ..,
          (navR_char_correct atomMap h_surj M χ1 v).mp hχ1s⟩
      · rcases hseg v hsv hvw with hg | ⟨χ, hm, hv⟩
        · exact Or.inl hg
        · exact Or.inr ⟨χ, List.mem_cons_of_mem _ hm, hv⟩

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Minimum extraction over a nonempty list (the time-reversed witness-threading key —
    the mirror of the Phase-14a private `navL_listMax`). -/
private theorem navR_listMin {α : Type} (M : OrderedMonadicStructure sig)
    (f : α → M.carrier) :
    ∀ l : List α, l ≠ [] → ∃ a ∈ l, ∀ b ∈ l, f a ≤ f b := by
  intro l
  induction l with
  | nil => intro h; exact absurd rfl h
  | cons x tl ih =>
    intro _
    by_cases htl : tl = []
    · subst htl
      exact ⟨x, List.mem_cons_self .., fun b hb => by
        rcases List.mem_cons.mp hb with rfl | h
        · exact le_refl _
        · exact absurd h List.not_mem_nil⟩
    · obtain ⟨m, hm, hmin⟩ := ih htl
      rcases le_total (f x) (f m) with hle | hle
      · refine ⟨x, List.mem_cons_self .., fun b hb => ?_⟩
        rcases List.mem_cons.mp hb with rfl | h
        · exact le_refl _
        · exact hle.trans (hmin b h)
      · refine ⟨m, List.mem_cons_of_mem _ hm, fun b hb => ?_⟩
        rcases List.mem_cons.mp hb with rfl | h
        · exact hle
        · exact hmin b h

/-- **Chain completeness**: given the future w-point package at `u < w`, one witness per
    listed profile inside `(u, w)` (the list duplicate-free), and the exclusion segment
    at every interior point, SOME arrangement of the list has its chain holding at `u`.
    Witnesses are threaded ASCENDING by repeated minimum extraction; distinct listed
    profiles have distinct witnesses (`navR_profile_unique`), so the minima strictly
    increase. -/
private theorem navR_chain_complete (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (w : M.carrier)
    (hpack : temporal_truth M atomMap w (navRAtWPack atomMap h_surj σ)) :
    ∀ (n : Nat) (T : List (NormalForm sig 0 1)), T.length = n → T.Nodup →
      ∀ u : M.carrier, u < w →
      (∀ χ ∈ T, ∃ v : M.carrier, u < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ) →
      (∀ v : M.carrier, u < v → v < w →
        temporal_truth M atomMap v (navRSegGuard atomMap h_surj σ)) →
      ∃ L ∈ T.permutations, temporal_truth M atomMap u (navRChain atomMap h_surj σ L) := by
  intro n
  induction n with
  | zero =>
    intro T hlen hnd u huw hwit hguard
    have hT : T = [] := List.eq_nil_of_length_eq_zero hlen
    subst hT
    refine ⟨[], List.mem_permutations.mpr (List.Perm.refl []), ?_⟩
    simp only [navRChain, temporal_truth]
    exact ⟨w, huw, hpack, fun r hur hrw => hguard r hur hrw⟩
  | succ n ih =>
    intro T hlen hnd u huw hwit hguard
    have hTne : T ≠ [] := by
      intro h; subst h; simp at hlen
    -- Choose one witness per profile, then extract the profile with the MINIMAL witness.
    have hattne : T.attach ≠ [] := by
      intro h
      have := congrArg List.length h
      rw [List.length_attach] at this
      exact hTne (List.eq_nil_of_length_eq_zero this)
    obtain ⟨⟨χ1, hχ1T⟩, -, hmin⟩ :=
      navR_listMin M (fun s : {χ // χ ∈ T} => (hwit s.1 s.2).choose) T.attach hattne
    obtain ⟨huv1, hv1w, hχ1v1⟩ := (hwit χ1 hχ1T).choose_spec
    set v1 := (hwit χ1 hχ1T).choose with hv1def
    -- Recurse on the erased list above the minimal witness.
    have hrestlen : (T.erase χ1).length = n := by
      rw [List.length_erase_of_mem hχ1T, hlen]
      omega
    have hrestnd : (T.erase χ1).Nodup := hnd.erase χ1
    have hrestwit : ∀ χ ∈ T.erase χ1,
        ∃ v : M.carrier, v1 < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ := by
      intro χ hχrest
      obtain ⟨hne, hχT⟩ := (List.Nodup.mem_erase_iff hnd).mp hχrest
      obtain ⟨huv, hvw, hχv⟩ := (hwit χ hχT).choose_spec
      have hle : v1 ≤ (hwit χ hχT).choose :=
        hmin ⟨χ, hχT⟩ (List.mem_attach T ⟨χ, hχT⟩)
      have hvne : (hwit χ hχT).choose ≠ v1 := by
        intro he
        rw [he] at hχv
        exact hne (navR_profile_unique M v1 χ χ1 hχv hχ1v1)
      exact ⟨(hwit χ hχT).choose, lt_of_le_of_ne hle (Ne.symm hvne), hvw, hχv⟩
    have hrestguard : ∀ v : M.carrier, v1 < v → v < w →
        temporal_truth M atomMap v (navRSegGuard atomMap h_surj σ) :=
      fun v hv hvw => hguard v (huv1.trans hv) hvw
    obtain ⟨L', hL'mem, hL'chain⟩ :=
      ih (T.erase χ1) hrestlen hrestnd v1 hv1w hrestwit hrestguard
    refine ⟨χ1 :: L', ?_, ?_⟩
    · -- (χ1 :: L') is a permutation of T.
      have h1 : L'.Perm (T.erase χ1) := List.mem_permutations.mp hL'mem
      have h2 : T.Perm (χ1 :: T.erase χ1) := List.perm_cons_erase hχ1T
      exact List.mem_permutations.mpr ((List.Perm.cons χ1 h1).trans h2.symm)
    · -- The chain holds at u with bottom witness v1.
      simp only [navRChain, temporal_truth]
      refine ⟨v1, huv1, ?_, fun r hur hrv1 => hguard r hur (hrv1.trans hv1w)⟩
      rw [temporal_truth_and]
      exact ⟨(navR_char_correct atomMap h_surj M χ1 v1).mpr hχ1v1, hL'chain⟩

/-! ## The E5 package deliverable: `navPackRight` + the fold iff -/

/-- **`navPackRight`** (E5, Lemma 7.10 / Prop 3.5, time-reversed): the Until-navigated
    w-package — the disjunction, over all arrangements of the bit-TRUE `t < v < w` fiber
    profiles, of the nested-Until chain anchored at the future w-point package and
    guarded by the exclusion segment. A single one-free-variable temporal predicate
    evaluated at the pin `t`. -/
noncomputable def navPackRight (σ : NormalForm sig 1 3) : TemporalPred :=
  ⟨formula_disjList
    ((navRBitTrueList σ).permutations.map (navRChain atomMap h_surj σ))⟩

/-- **The E5 fold iff** (`navPackRight` correctness): the Until-navigated w-package at
    the pin `t` is exactly the `∃ w > t` fold of the four w-DEPENDENT clause groups of
    `extZoneFiberFut_k1` — atoms at `w` (position-0 predicate layer), the `v = w` fiber
    biconditionals, the `w < v` fiber biconditionals, and the `t < v < w` fiber
    biconditionals — each stated verbatim in the future-kit shape. No ambient hypothesis
    is needed: the fold itself introduces the exterior witness `w`. -/
theorem navPackRight_correct (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (t : M.carrier) :
    (navPackRight atomMap h_surj σ).eval_at M atomMap t ↔
      ∃ w : M.carrier, t < w ∧
        ((∀ p : sig.preds, M.interp p w ↔ σ.1 (.pred p ⟨0, by omega⟩) = true) ∧
         (∀ χ : NormalForm sig 0 1,
           nf_eval_nf M 0 1 (fun _ => w) χ ↔
             σ.2 (nf0_assemble extFZAtW χ σ.1) = true) ∧
         (∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, w < v ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extFZAboveW χ σ.1) = true) ∧
         (∀ χ : NormalForm sig 0 1,
           (∃ v : M.carrier, t < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
             σ.2 (nf0_assemble extFZIntTW χ σ.1) = true)) := by
  simp only [navPackRight, TemporalPred.eval_at]
  rw [formula_disjList_iff]
  constructor
  · -- Soundness: some arrangement's chain at t yields the ∃w package.
    rintro ⟨φ, hmem, hφ⟩
    obtain ⟨L, hLperm, rfl⟩ := List.mem_map.mp hmem
    have hperm : L.Perm (navRBitTrueList σ) := List.mem_permutations.mp hLperm
    obtain ⟨w, htw, hpack, hwit, hseg⟩ := navR_chain_sound atomMap h_surj M σ L t hφ
    obtain ⟨ha, hc, hb⟩ := (navR_atWPack_iff atomMap h_surj M σ w).mp hpack
    refine ⟨w, htw, ha, hc, hb, ?_⟩
    intro χ
    constructor
    · rintro ⟨v, htv, hvw, hχv⟩
      rcases hseg v htv hvw with hg | ⟨χ', hχ'L, hχ'v⟩
      · obtain ⟨χ'', hbit'', hχ''v⟩ := (navR_segGuard_iff atomMap h_surj M σ v).mp hg
        rwa [navR_profile_unique M v χ χ'' hχv hχ''v]
      · rw [navR_profile_unique M v χ χ' hχv hχ'v]
        exact (navR_bitTrueList_mem σ χ').mp (hperm.mem_iff.mp hχ'L)
    · intro hbit
      have hχL : χ ∈ L := hperm.mem_iff.mpr ((navR_bitTrueList_mem σ χ).mpr hbit)
      exact hwit χ hχL
  · -- Completeness: the ∃w package realizes some arrangement's chain at t.
    rintro ⟨w, htw, ha, hc, hb, hd⟩
    have hpack : temporal_truth M atomMap w (navRAtWPack atomMap h_surj σ) :=
      (navR_atWPack_iff atomMap h_surj M σ w).mpr ⟨ha, hc, hb⟩
    have hwit : ∀ χ ∈ navRBitTrueList σ,
        ∃ v : M.carrier, t < v ∧ v < w ∧ nf_eval_nf M 0 1 (fun _ => v) χ :=
      fun χ hχ => (hd χ).mpr ((navR_bitTrueList_mem σ χ).mp hχ)
    have hguard : ∀ v : M.carrier, t < v → v < w →
        temporal_truth M atomMap v (navRSegGuard atomMap h_surj σ) := by
      intro v htv hvw
      obtain ⟨χv, hχv⟩ := navR_profile_exists M v
      exact (navR_segGuard_iff atomMap h_surj M σ v).mpr
        ⟨χv, (hd χv).mp ⟨v, htv, hvw, hχv⟩, hχv⟩
    obtain ⟨L, hLmem, hLchain⟩ := navR_chain_complete atomMap h_surj M σ w hpack
      (navRBitTrueList σ).length (navRBitTrueList σ) rfl
      (navR_bitTrueList_nodup σ) t htw hwit hguard
    exact ⟨navRChain atomMap h_surj σ L, List.mem_map.mpr ⟨L, hLmem, rfl⟩, hLchain⟩

/-! ## E3 mirror: w-independent distribution `navDistribRight`

Distributes the w-INDEPENDENT parts of the future-exterior channel `x < t < w` out of
the `∃w` (Rabinovich Lemma 7.6 gluing decomposition, time-reversed):

- zones `v = x`, `v < x` (+ atoms at `x`, position-1 layer) → the `endpointLeft` content
  `navRAtXPack`, read AT the pin `x` (past fibers as native Since-lits `S(charF χ, ⊤)`);
- zone `x < v < t` fibers (`extFZIntXT`) → the `(x, t)` bracket arrangement slots
  `navRXTBracket` + the exclusion segment `navRXTSegGuard` on every gap;
- zone `v = t` and the atoms at `t` (position-2 layer) → the t-endpoint conjunct
  `navRAtTPack`, read AT the pin `t` (glued to `navPackRight` inside `endpointRight`);
- the order-channel row bits → the pure σ-condition `navROrderRow`;
- inconsistent-zone falsity and off-fiber honesty → pure σ-conditions, verbatim. -/

/-- **The x-endpoint pack** (`endpointLeft` content, future channel): atoms at `x`
    (position-1 projection characteristic), the `v = x` fiber group (characteristic
    literals over `extFZAtX`), and the `v < x` fiber group (native past Since-lits
    `navLPastLit` over `extFZBelowX`, negated on bit-false fibers). Every x-read lives
    HERE, at its own pin (world-locality) — the time-reversed mirror of `navDAtTPack`. -/
noncomputable def navRAtXPack (σ : NormalForm sig 1 3) : Formula :=
  formula_conjList
    [nf_depth0_char_formula atomMap h_surj (navDProjX σ.1),
     formula_conjList
       (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
         if σ.2 (nf0_assemble extFZAtX χ σ.1) = true
         then nf_depth0_char_formula atomMap h_surj χ
         else (nf_depth0_char_formula atomMap h_surj χ).neg),
     formula_conjList
       (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
         if σ.2 (nf0_assemble extFZBelowX χ σ.1) = true
         then navLPastLit atomMap h_surj χ
         else (navLPastLit atomMap h_surj χ).neg)]

/-- Reading of the x-endpoint pack: exactly the three x-anchored clause groups of
    `extZoneFiberFut_k1` (atom layer restricted to position 1; `v = x`; `v < x`). -/
theorem navR_atXPack_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x : M.carrier) :
    temporal_truth M atomMap x (navRAtXPack atomMap h_surj σ) ↔
      ((∀ p : sig.preds, M.interp p x ↔ σ.1 (.pred p ⟨1, by omega⟩) = true) ∧
       (∀ χ : NormalForm sig 0 1,
         nf_eval_nf M 0 1 (fun _ => x) χ ↔ σ.2 (nf0_assemble extFZAtX χ σ.1) = true) ∧
       (∀ χ : NormalForm sig 0 1,
         (∃ v : M.carrier, v < x ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
           σ.2 (nf0_assemble extFZBelowX χ σ.1) = true)) := by
  simp only [navRAtXPack, formula_conjList]
  rw [temporal_truth_and, temporal_truth_and, temporal_truth_and]
  have htop : temporal_truth M atomMap x Formula.top := temporal_truth_top M atomMap x
  constructor
  · rintro ⟨h1, h2, h3, -⟩
    refine ⟨?_, ?_, ?_⟩
    · intro p
      exact (nf_depth0_char_formula_correct M atomMap h_surj (navDProjX σ.1) x).mp h1 p
    · exact (navR_bitGroup_iff atomMap M x _ _ _
        (fun χ => navR_char_correct atomMap h_surj M χ x)).mp h2
    · exact (navR_bitGroup_iff atomMap M x _ _ _
        (fun χ => navR_pastLit_iff atomMap h_surj M χ x)).mp h3
  · rintro ⟨h1, h2, h3⟩
    refine ⟨?_, ?_, ?_, htop⟩
    · exact (nf_depth0_char_formula_correct M atomMap h_surj (navDProjX σ.1) x).mpr h1
    · exact (navR_bitGroup_iff atomMap M x _ _ _
        (fun χ => navR_char_correct atomMap h_surj M χ x)).mpr h2
    · exact (navR_bitGroup_iff atomMap M x _ _ _
        (fun χ => navR_pastLit_iff atomMap h_surj M χ x)).mpr h3

/-- **The t-endpoint conjunct** (future channel): atoms at `t` (position-2 projection
    characteristic) and the `v = t` fiber group (characteristic literals over
    `extFZAtT`). The w-independent conjunct glued to `navPackRight` inside
    `endpointRight` — the time-reversed mirror of `navDAtXPack`. -/
noncomputable def navRAtTPack (σ : NormalForm sig 1 3) : Formula :=
  formula_conjList
    [nf_depth0_char_formula atomMap h_surj (navDProjT σ.1),
     formula_conjList
       (((Finset.univ : Finset (NormalForm sig 0 1)).toList).map fun χ =>
         if σ.2 (nf0_assemble extFZAtT χ σ.1) = true
         then nf_depth0_char_formula atomMap h_surj χ
         else (nf_depth0_char_formula atomMap h_surj χ).neg)]

/-- Reading of the t-endpoint conjunct: exactly the two t-anchored w-independent clause
    groups of `extZoneFiberFut_k1` (atom layer restricted to position 2; zone `v = t`). -/
theorem navR_atTPack_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (t : M.carrier) :
    temporal_truth M atomMap t (navRAtTPack atomMap h_surj σ) ↔
      ((∀ p : sig.preds, M.interp p t ↔ σ.1 (.pred p ⟨2, by omega⟩) = true) ∧
       (∀ χ : NormalForm sig 0 1,
         nf_eval_nf M 0 1 (fun _ => t) χ ↔ σ.2 (nf0_assemble extFZAtT χ σ.1) = true)) := by
  simp only [navRAtTPack, formula_conjList]
  rw [temporal_truth_and, temporal_truth_and]
  have htop : temporal_truth M atomMap t Formula.top := temporal_truth_top M atomMap t
  constructor
  · rintro ⟨h1, h2, -⟩
    refine ⟨?_, ?_⟩
    · intro p
      exact (nf_depth0_char_formula_correct M atomMap h_surj (navDProjT σ.1) t).mp h1 p
    · exact (navR_bitGroup_iff atomMap M t _ _ _
        (fun χ => navR_char_correct atomMap h_surj M χ t)).mp h2
  · rintro ⟨h1, h2⟩
    refine ⟨?_, ?_, htop⟩
    · exact (nf_depth0_char_formula_correct M atomMap h_surj (navDProjT σ.1) t).mpr h1
    · exact (navR_bitGroup_iff atomMap M t _ _ _
        (fun χ => navR_char_correct atomMap h_surj M χ t)).mpr h2

/-! ### The `(x, t)` bracket arrangement slots + exclusion segment (future channel) -/

/-- The bit-TRUE `x < v < t` fiber profiles of `σ` in the FUTURE channel (zone spec
    `extFZIntXT` — distinct from the past channel's `extZIntXT` because the spec also
    encodes the witness relation `v < w`). -/
noncomputable def navRXTBitTrueList (σ : NormalForm sig 1 3) :
    List (NormalForm sig 0 1) :=
  ((Finset.univ : Finset (NormalForm sig 0 1)).filter
    fun χ => σ.2 (nf0_assemble extFZIntXT χ σ.1) = true).toList

private theorem navR_xtBitTrueList_mem (σ : NormalForm sig 1 3)
    (χ : NormalForm sig 0 1) :
    χ ∈ navRXTBitTrueList σ ↔ σ.2 (nf0_assemble extFZIntXT χ σ.1) = true := by
  simp [navRXTBitTrueList, Finset.mem_toList, Finset.mem_filter]

private theorem navR_xtBitTrueList_nodup (σ : NormalForm sig 1 3) :
    (navRXTBitTrueList σ).Nodup :=
  Finset.nodup_toList _

/-- **The `(x, t)` exclusion segment (future channel)**: the disjunction of the bit-TRUE
    characteristics. -/
noncomputable def navRXTSegGuard (σ : NormalForm sig 1 3) : TemporalPred :=
  ⟨formula_disjList
    ((navRXTBitTrueList σ).map (nf_depth0_char_formula atomMap h_surj))⟩

/-- Reading of the `(x, t)` exclusion segment. -/
private theorem navR_xtSegGuard_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (v : M.carrier) :
    (navRXTSegGuard atomMap h_surj σ).eval_at M atomMap v ↔
      ∃ χ : NormalForm sig 0 1, σ.2 (nf0_assemble extFZIntXT χ σ.1) = true ∧
        nf_eval_nf M 0 1 (fun _ => v) χ := by
  simp only [navRXTSegGuard, TemporalPred.eval_at]
  rw [formula_disjList_iff]
  constructor
  · rintro ⟨φ, hmem, hφ⟩
    obtain ⟨χ, hχmem, rfl⟩ := List.mem_map.mp hmem
    exact ⟨χ, (navR_xtBitTrueList_mem σ χ).mp hχmem,
      (navR_char_correct atomMap h_surj M χ v).mp hφ⟩
  · rintro ⟨χ, hbit, hχ⟩
    exact ⟨_, List.mem_map.mpr ⟨χ, (navR_xtBitTrueList_mem σ χ).mpr hbit, rfl⟩,
      (navR_char_correct atomMap h_surj M χ v).mpr hχ⟩

/-- **The `(x, t)` bracket arrangement (future channel)**: one witness slot per listed
    profile — listed from the TOP slot nearest `t` downward — with the exclusion segment
    on EVERY gap. `BracketFormula.snoc` recursion, the `navDXTBracket` shape with the
    future-channel fibers. -/
noncomputable def navRXTBracket (σ : NormalForm sig 1 3) :
    (L : List (NormalForm sig 0 1)) → BracketFormula L.length
  | [] => BracketFormula.trivial (navRXTSegGuard atomMap h_surj σ)
  | χ :: rest => (navRXTBracket σ rest).snoc
      ⟨nf_depth0_char_formula atomMap h_surj χ⟩
      (navRXTSegGuard atomMap h_surj σ)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Maximum extraction over a nonempty list (local copy of the Phase-14a private
    `navL_listMax` — the bracket threads its top slot nearest `t` first). -/
private theorem navR_listMax {α : Type} (M : OrderedMonadicStructure sig)
    (f : α → M.carrier) :
    ∀ l : List α, l ≠ [] → ∃ a ∈ l, ∀ b ∈ l, f b ≤ f a := by
  intro l
  induction l with
  | nil => intro h; exact absurd rfl h
  | cons x tl ih =>
    intro _
    by_cases htl : tl = []
    · subst htl
      exact ⟨x, List.mem_cons_self .., fun b hb => by
        rcases List.mem_cons.mp hb with rfl | h
        · exact le_refl _
        · exact absurd h List.not_mem_nil⟩
    · obtain ⟨m, hm, hmax⟩ := ih htl
      rcases le_total (f x) (f m) with hle | hle
      · refine ⟨m, List.mem_cons_of_mem _ hm, fun b hb => ?_⟩
        rcases List.mem_cons.mp hb with rfl | h
        · exact hle
        · exact hmax b h
      · refine ⟨x, List.mem_cons_self .., fun b hb => ?_⟩
        rcases List.mem_cons.mp hb with rfl | h
        · exact le_refl _
        · exact (hmax b h).trans hle

/-- **Arrangement soundness (future channel)**: a held arrangement on `(x, u)` yields one
    witness per listed profile strictly inside `(x, u)`, and the exclusion segment (or a
    listed witness profile) at every interior point. -/
private theorem navR_bracket_sound (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) :
    ∀ (L : List (NormalForm sig 0 1)) (x u : M.carrier),
      (navRXTBracket atomMap h_surj σ L).holds M atomMap x u →
      (∀ χ ∈ L, ∃ v : M.carrier, x < v ∧ v < u ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ∧
      (∀ v : M.carrier, x < v → v < u →
        (navRXTSegGuard atomMap h_surj σ).eval_at M atomMap v ∨
          ∃ χ ∈ L, nf_eval_nf M 0 1 (fun _ => v) χ) := by
  intro L
  induction L with
  | nil =>
    intro x u h
    simp only [navRXTBracket] at h
    rw [BracketFormula.trivial_holds] at h
    exact ⟨fun χ hχ => absurd hχ List.not_mem_nil,
      fun v hxv hvu => Or.inl (h v hxv hvu)⟩
  | cons χ1 rest ih =>
    intro x u h
    simp only [navRXTBracket] at h
    rw [BracketFormula.snoc_holds_iff] at h
    obtain ⟨s, hxs, hsu, hfront, hpt, hseg⟩ := h
    obtain ⟨hwit, hcov⟩ := ih x s hfront
    refine ⟨?_, ?_⟩
    · intro χ hχmem
      rcases List.mem_cons.mp hχmem with rfl | hmem
      · exact ⟨s, hxs, hsu, (navR_char_correct atomMap h_surj M χ s).mp hpt⟩
      · obtain ⟨v, hxv, hvs, hv⟩ := hwit χ hmem
        exact ⟨v, hxv, hvs.trans hsu, hv⟩
    · intro v hxv hvu
      rcases lt_trichotomy v s with hvs | rfl | hsv
      · rcases hcov v hxv hvs with hg | ⟨χ, hm, hv⟩
        · exact Or.inl hg
        · exact Or.inr ⟨χ, List.mem_cons_of_mem _ hm, hv⟩
      · exact Or.inr ⟨χ1, List.mem_cons_self ..,
          (navR_char_correct atomMap h_surj M χ1 v).mp hpt⟩
      · exact Or.inl (hseg v hsv hvu)

/-- **Arrangement completeness (future channel)**: given one witness per listed profile
    strictly inside `(x, u)` (the list duplicate-free) and the exclusion segment at every
    interior point, SOME arrangement of the list holds on `(x, u)`. -/
private theorem navR_bracket_complete (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x : M.carrier) :
    ∀ (n : Nat) (T : List (NormalForm sig 0 1)), T.length = n → T.Nodup →
      ∀ u : M.carrier,
      (∀ χ ∈ T, ∃ v : M.carrier, x < v ∧ v < u ∧ nf_eval_nf M 0 1 (fun _ => v) χ) →
      (∀ v : M.carrier, x < v → v < u →
        (navRXTSegGuard atomMap h_surj σ).eval_at M atomMap v) →
      ∃ L ∈ T.permutations,
        (navRXTBracket atomMap h_surj σ L).holds M atomMap x u := by
  intro n
  induction n with
  | zero =>
    intro T hlen hnd u hwit hguard
    have hT : T = [] := List.eq_nil_of_length_eq_zero hlen
    subst hT
    refine ⟨[], List.mem_permutations.mpr (List.Perm.refl []), ?_⟩
    simp only [navRXTBracket]
    rw [BracketFormula.trivial_holds]
    exact fun r hxr hru => hguard r hxr hru
  | succ n ih =>
    intro T hlen hnd u hwit hguard
    have hTne : T ≠ [] := by
      intro h; subst h; simp at hlen
    -- Choose one witness per profile, then extract the profile with the MAXIMAL witness.
    have hattne : T.attach ≠ [] := by
      intro h
      have := congrArg List.length h
      rw [List.length_attach] at this
      exact hTne (List.eq_nil_of_length_eq_zero this)
    obtain ⟨⟨χ1, hχ1T⟩, -, hmax⟩ :=
      navR_listMax M (fun s : {χ // χ ∈ T} => (hwit s.1 s.2).choose) T.attach hattne
    obtain ⟨hxv1, hv1u, hχ1v1⟩ := (hwit χ1 hχ1T).choose_spec
    set v1 := (hwit χ1 hχ1T).choose with hv1def
    -- Recurse on the erased list below the maximal witness.
    have hrestlen : (T.erase χ1).length = n := by
      rw [List.length_erase_of_mem hχ1T, hlen]
      omega
    have hrestnd : (T.erase χ1).Nodup := hnd.erase χ1
    have hrestwit : ∀ χ ∈ T.erase χ1,
        ∃ v : M.carrier, x < v ∧ v < v1 ∧ nf_eval_nf M 0 1 (fun _ => v) χ := by
      intro χ hχrest
      obtain ⟨hne, hχT⟩ := (List.Nodup.mem_erase_iff hnd).mp hχrest
      obtain ⟨hxv, hvu, hχv⟩ := (hwit χ hχT).choose_spec
      have hle : (hwit χ hχT).choose ≤ v1 :=
        hmax ⟨χ, hχT⟩ (List.mem_attach T ⟨χ, hχT⟩)
      have hvne : (hwit χ hχT).choose ≠ v1 := by
        intro he
        rw [he] at hχv
        exact hne (navR_profile_unique M v1 χ χ1 hχv hχ1v1)
      exact ⟨(hwit χ hχT).choose, hxv, lt_of_le_of_ne hle hvne, hχv⟩
    have hrestguard : ∀ v : M.carrier, x < v → v < v1 →
        (navRXTSegGuard atomMap h_surj σ).eval_at M atomMap v :=
      fun v hxv hv => hguard v hxv (hv.trans hv1u)
    obtain ⟨L', hL'mem, hL'holds⟩ :=
      ih (T.erase χ1) hrestlen hrestnd v1 hrestwit hrestguard
    refine ⟨χ1 :: L', ?_, ?_⟩
    · -- (χ1 :: L') is a permutation of T.
      have h1 : L'.Perm (T.erase χ1) := List.mem_permutations.mp hL'mem
      have h2 : T.Perm (χ1 :: T.erase χ1) := List.perm_cons_erase hχ1T
      exact List.mem_permutations.mpr ((List.Perm.cons χ1 h1).trans h2.symm)
    · -- The arrangement holds on (x, u) with top witness v1.
      simp only [navRXTBracket]
      rw [BracketFormula.snoc_holds_iff]
      exact ⟨v1, hxv1, hv1u, hL'holds,
        (navR_char_correct atomMap h_surj M χ1 v1).mpr hχ1v1,
        fun r hv1r hru => hguard r (hxv1.trans hv1r) hru⟩

/-- **The `(x, t)` interior fiber reading (future channel)**: some arrangement of the
    bit-TRUE `x < v < t` profiles holds on `(x, t)` iff every fiber biconditional of the
    `extFZIntXT` zone reads correctly — stated verbatim in the `extZoneFiberFut_k1`
    clause shape. No ambient hypothesis is needed. -/
theorem navRXTBracket_arrangements_iff (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x t : M.carrier) :
    (∃ L ∈ (navRXTBitTrueList σ).permutations,
        (navRXTBracket atomMap h_surj σ L).holds M atomMap x t) ↔
      ∀ χ : NormalForm sig 0 1,
        (∃ v : M.carrier, x < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) χ) ↔
          σ.2 (nf0_assemble extFZIntXT χ σ.1) = true := by
  constructor
  · rintro ⟨L, hLperm, hL⟩
    have hperm : L.Perm (navRXTBitTrueList σ) := List.mem_permutations.mp hLperm
    obtain ⟨hwit, hcov⟩ := navR_bracket_sound atomMap h_surj M σ L x t hL
    intro χ
    constructor
    · rintro ⟨v, hxv, hvt, hχv⟩
      rcases hcov v hxv hvt with hg | ⟨χ', hχ'L, hχ'v⟩
      · obtain ⟨χ'', hbit'', hχ''v⟩ := (navR_xtSegGuard_iff atomMap h_surj M σ v).mp hg
        rwa [navR_profile_unique M v χ χ'' hχv hχ''v]
      · rw [navR_profile_unique M v χ χ' hχv hχ'v]
        exact (navR_xtBitTrueList_mem σ χ').mp (hperm.mem_iff.mp hχ'L)
    · intro hbit
      exact hwit χ (hperm.mem_iff.mpr ((navR_xtBitTrueList_mem σ χ).mpr hbit))
  · intro hd
    have hwit : ∀ χ ∈ navRXTBitTrueList σ,
        ∃ v : M.carrier, x < v ∧ v < t ∧ nf_eval_nf M 0 1 (fun _ => v) χ :=
      fun χ hχ => (hd χ).mpr ((navR_xtBitTrueList_mem σ χ).mp hχ)
    have hguard : ∀ v : M.carrier, x < v → v < t →
        (navRXTSegGuard atomMap h_surj σ).eval_at M atomMap v := by
      intro v hxv hvt
      obtain ⟨χv, hχv⟩ := navR_profile_exists M v
      exact (navR_xtSegGuard_iff atomMap h_surj M σ v).mpr
        ⟨χv, (hd χv).mp ⟨v, hxv, hvt, hχv⟩, hχv⟩
    exact navR_bracket_complete atomMap h_surj M σ x
      (navRXTBitTrueList σ).length (navRXTBitTrueList σ) rfl
      (navR_xtBitTrueList_nodup σ) t hwit hguard

/-! ### The order-channel row and the atom-layer split (future ambient) -/

/-- **The w-independent order-channel row (future channel)**: the six order bits of
    `σ.1` forced by the channel pattern `x < t < w`. Constant across ALL exterior
    witnesses `t < w` (given the ambient `x < t`), hence w-independent. -/
def navROrderRow (σ : NormalForm sig 1 3) : Prop :=
  σ.1 (.order ⟨1, by omega⟩ ⟨2, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨1, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨0, by omega⟩ (by decide)) = true ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨1, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = false ∧
  σ.1 (.order ⟨2, by omega⟩ ⟨1, by omega⟩ (by decide)) = false

/-- A biconditional against a refuted proposition forces the bit false. -/
private theorem navR_atomBit_false {P : Prop} {b : Bool}
    (h : P ↔ b = true) (hnp : ¬P) : b = false := by
  cases b with
  | false => rfl
  | true => exact absurd (h.mpr rfl) hnp

/-- A refuted proposition is equivalent to a false bit's truth. -/
private theorem navR_atomBit_iff_false {P : Prop} {b : Bool}
    (hnp : ¬P) (hb : b = false) : P ↔ b = true := by
  subst hb
  exact iff_of_false hnp Bool.false_ne_true

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The atom-layer split (future ambient)**: under `x < t < w`, the arity-3 atom layer
    of `extZoneFiberFut_k1` splits into the three per-position predicate layers (at `w`,
    `x`, `t`) and the order-channel row. The position-0 layer is the ONLY w-dependent
    part; the row is constant across all `t < w`. -/
private theorem navR_atomLayer_iff (M : OrderedMonadicStructure sig)
    (w x t : M.carrier) (hxt : x < t) (htw : t < w) (σ : NormalForm sig 1 3) :
    (∀ a : AtomKind sig 3,
        atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ σ.1 a = true) ↔
      ((∀ p : sig.preds, M.interp p w ↔ σ.1 (.pred p ⟨0, by omega⟩) = true) ∧
       (∀ p : sig.preds, M.interp p x ↔ σ.1 (.pred p ⟨1, by omega⟩) = true) ∧
       (∀ p : sig.preds, M.interp p t ↔ σ.1 (.pred p ⟨2, by omega⟩) = true) ∧
       navROrderRow σ) := by
  have hxw : x < w := hxt.trans htw
  constructor
  · intro h
    exact ⟨fun p => h (.pred p (0 : Fin 3)), fun p => h (.pred p (1 : Fin 3)),
      fun p => h (.pred p (2 : Fin 3)),
      (h _).mp hxt, (h _).mp hxw, (h _).mp htw,
      navR_atomBit_false (h _) (lt_asymm hxw),
      navR_atomBit_false (h _) (lt_asymm htw),
      navR_atomBit_false (h _) (lt_asymm hxt)⟩
  · rintro ⟨h0, h1, h2, h12, h10, h20, h01, h02, h21⟩
    intro a
    match a with
    | .pred p i =>
      match i with
      | ⟨0, _⟩ => exact h0 p
      | ⟨1, _⟩ => exact h1 p
      | ⟨2, _⟩ => exact h2 p
    | .order i j hij =>
      match i, j with
      | ⟨0, _⟩, ⟨0, _⟩ => exact absurd rfl hij
      | ⟨0, _⟩, ⟨1, _⟩ => exact navR_atomBit_iff_false (lt_asymm hxw) h01
      | ⟨0, _⟩, ⟨2, _⟩ => exact navR_atomBit_iff_false (lt_asymm htw) h02
      | ⟨1, _⟩, ⟨0, _⟩ => exact iff_of_true hxw h10
      | ⟨1, _⟩, ⟨1, _⟩ => exact absurd rfl hij
      | ⟨1, _⟩, ⟨2, _⟩ => exact iff_of_true hxt h12
      | ⟨2, _⟩, ⟨0, _⟩ => exact iff_of_true htw h20
      | ⟨2, _⟩, ⟨1, _⟩ => exact navR_atomBit_iff_false (lt_asymm hxt) h21
      | ⟨2, _⟩, ⟨2, _⟩ => exact absurd rfl hij
      | ⟨_ + 3, hn⟩, _ => exact absurd hn (by omega)
      | _, ⟨_ + 3, hn⟩ => exact absurd hn (by omega)

/-! ### The E5 distribution deliverable: `navDistribRight` -/

/-- **The E5 distribution lemma `navDistribRight`** (Rabinovich Lemma 7.6 gluing
    decomposition, time-reversed): under the ambient `x < t`, the `∃ w > t`
    future-exterior evaluation splits into the w-DEPENDENT package (exactly
    `navPackRight`, by its fold iff) and the w-INDEPENDENT remainder, each part read at
    its own slot:

    - `navPackRight` at the pin `t` (the ∃w fold);
    - `navRAtTPack` at the pin `t` (atoms at `t`; zone `v = t`) — the `endpointRight`
      conjunct;
    - the `(x, t)` bracket arrangement disjunction (zone `x < v < t`, future-channel
      fibers `extFZIntXT`);
    - `navRAtXPack` at the pin `x` (atoms at `x`; zones `v = x`, `v < x`) — the
      `endpointLeft` content;
    - the order-channel row, inconsistent-zone falsity, and off-fiber honesty — pure
      σ-conditions.

    Phase-15 carrier assembly consumes this iff directly for the ∃w glue of
    `CExtFut_correct`. -/
theorem navDistribRight (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x t : M.carrier) (hxt : x < t) :
    (∃ w : M.carrier, t < w ∧
        nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ) ↔
      ((navPackRight atomMap h_surj σ).eval_at M atomMap t ∧
       temporal_truth M atomMap t (navRAtTPack atomMap h_surj σ) ∧
       (∃ L ∈ (navRXTBitTrueList σ).permutations,
         (navRXTBracket atomMap h_surj σ L).holds M atomMap x t) ∧
       temporal_truth M atomMap x (navRAtXPack atomMap h_surj σ) ∧
       navROrderRow σ ∧
       (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
          ¬(zs = extFZBelowX ∨ zs = extFZAtX ∨ zs = extFZIntXT ∨ zs = extFZAtT ∨
            zs = extFZIntTW ∨ zs = extFZAtW ∨ zs = extFZAboveW) →
          σ.2 (nf0_assemble zs χ σ.1) = false) ∧
       (∀ τ : NormalForm sig 0 4, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)) := by
  constructor
  · -- Distribution: peel the w-independent clause groups out of the ∃w.
    rintro ⟨w, htw, hnf⟩
    obtain ⟨hatom, ⟨h1, h2, h3, h4, h5, h6, h7⟩, hbad, hoff⟩ :=
      (extZoneFiberFut_k1 M w x t hxt htw σ).mp hnf
    obtain ⟨ha0, ha1, ha2, hrow⟩ := (navR_atomLayer_iff M w x t hxt htw σ).mp hatom
    refine ⟨?_, ?_, ?_, ?_, hrow, hbad, hoff⟩
    · exact (navPackRight_correct atomMap h_surj M σ t).mpr ⟨w, htw, ha0, h6, h7, h5⟩
    · exact (navR_atTPack_iff atomMap h_surj M σ t).mpr ⟨ha2, h4⟩
    · exact (navRXTBracket_arrangements_iff atomMap h_surj M σ x t).mpr h3
    · exact (navR_atXPack_iff atomMap h_surj M σ x).mpr ⟨ha1, h2, h1⟩
  · -- Gluing: the ∃w of the navPackRight fold carries the w-independent parts back in.
    rintro ⟨hpack, hT, hbr, hX, hrow, hbad, hoff⟩
    obtain ⟨w, htw, ha0, hatW, haboveW, hintTW⟩ :=
      (navPackRight_correct atomMap h_surj M σ t).mp hpack
    obtain ⟨ha2, hatT⟩ := (navR_atTPack_iff atomMap h_surj M σ t).mp hT
    obtain ⟨ha1, hatX, hbelX⟩ := (navR_atXPack_iff atomMap h_surj M σ x).mp hX
    have hintXT := (navRXTBracket_arrangements_iff atomMap h_surj M σ x t).mp hbr
    exact ⟨w, htw, (extZoneFiberFut_k1 M w x t hxt htw σ).mpr
      ⟨(navR_atomLayer_iff M w x t hxt htw σ).mpr ⟨ha0, ha1, ha2, hrow⟩,
       ⟨hbelX, hatX, hintXT, hatT, hintTW, hatW, haboveW⟩, hbad, hoff⟩⟩

/-! ## E4 mirror: the future-exterior carrier `CExtFut` + the ∃w pin glue

Assembles the E5 mirror stack into the per-qnf future-exterior carrier (Rabinovich
Lemma 7.6 closure for the ∃w glue at the pin `t`; Lemma 7.8(2) TL(Until,K⁻)): one
`VecEA2` disjunct per arrangement of the bit-TRUE `(x, t)` future-channel profiles,
with the shared endpoints

- `endpointLeft` = `navRAtXPack` at the pin `x` (atoms at `x`; zones `v = x`, `v < x`);
- `bracket` = the `(x, t)` arrangement slots + exclusion segment (`navRXTBracket`);
- `endpointRight` = `navPackRight ∧ navRAtTPack` at the pin `t` — the Until-navigated
  ∃w fold glued to the t-endpoint conjunct;

gated on the three pure σ-side conditions of `navDistribRight` (empty disjunction
off-gate — the `CExtPast`/`agg2Past` dite pattern). -/

/-- **The future-exterior gate**: the three pure σ-side conjuncts of `navDistribRight` —
    the order-channel row `navROrderRow`, inconsistent-zone falsity (future zones), and
    off-fiber honesty. A Prop on `σ` alone (no model data). -/
def navRGate (σ : NormalForm sig 1 3) : Prop :=
  navROrderRow σ ∧
  (∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
      ¬(zs = extFZBelowX ∨ zs = extFZAtX ∨ zs = extFZIntXT ∨ zs = extFZAtT ∨
        zs = extFZIntTW ∨ zs = extFZAtW ∨ zs = extFZAboveW) →
      σ.2 (nf0_assemble zs χ σ.1) = false) ∧
  (∀ τ : NormalForm sig 0 4, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false)

/-- **The E5 future-exterior carrier `CExtFut`** (the `t < w` channel): one `VecEA2`
    disjunct per arrangement of the bit-TRUE `(x, t)` future-channel profiles —
    `endpointLeft` is the x-endpoint pack `navRAtXPack` (every x-read at its own pin);
    the bracket carries the `(x, t)` arrangement slots + exclusion segment;
    `endpointRight` is the Until-navigated w-package `navPackRight` (the ∃w fold across
    the pin `t`) conjoined with the t-endpoint conjunct `navRAtTPack`. Gated on
    `navRGate` (empty disjunction off-gate). -/
noncomputable def CExtFut (σ : NormalForm sig 1 3) : VVecEA2 :=
  @dite _ (navRGate σ) (Classical.dec _)
    (fun _ =>
      { disjuncts := (navRXTBitTrueList σ).permutations.map (fun L =>
          ⟨L.length,
           { endpointLeft := ⟨navRAtXPack atomMap h_surj σ⟩
             endpointRight := ⟨Formula.and (navPackRight atomMap h_surj σ).formula
               (navRAtTPack atomMap h_surj σ)⟩
             bracket := navRXTBracket atomMap h_surj σ L }⟩) })
    (fun _ => { disjuncts := [] })

/-- **The E5 correctness iff `CExtFut_correct`** (the ∃w glue across the pin at `t`,
    Rabinovich Lemma 7.6, time-reversed; Lemma 7.8(2) TL(Until,K⁻) by duplication):
    under the ambient `x < t`, the carrier's 2-pin semantics at `(x, t)` is exactly the
    `∃ w > t` future-exterior evaluation of `σ` at `[w, x, t]`. Pure plumbing against
    `navDistribRight`: the shared endpoints distribute over the arrangement disjunction,
    and the three gate conjuncts are exactly the pure σ-conditions of the distribution
    RHS. -/
theorem CExtFut_correct (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (x t : M.carrier) (hxt : x < t) :
    (CExtFut atomMap h_surj σ).holds M atomMap x t ↔
      ∃ w : M.carrier, t < w ∧
        nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ := by
  rw [navDistribRight atomMap h_surj M σ x t hxt]
  unfold CExtFut
  split
  case isTrue hg =>
    obtain ⟨hrow, hbad, hoff⟩ := hg
    constructor
    · rintro ⟨vea, hmem, hv⟩
      rw [List.mem_map] at hmem
      obtain ⟨L, hLperm, rfl⟩ := hmem
      obtain ⟨hepL, hepR, hbr⟩ := hv
      simp only [TemporalPred.eval_at] at hepL hepR
      rw [temporal_truth_and] at hepR
      exact ⟨hepR.1, hepR.2, ⟨L, hLperm, hbr⟩, hepL, hrow, hbad, hoff⟩
    · rintro ⟨hpack, hT, ⟨L, hLperm, hbr⟩, hX, -, -, -⟩
      have hepR : temporal_truth M atomMap t
          (Formula.and (navPackRight atomMap h_surj σ).formula
            (navRAtTPack atomMap h_surj σ)) :=
        (temporal_truth_and M atomMap t _ _).mpr ⟨hpack, hT⟩
      exact ⟨_, List.mem_map.mpr ⟨L, hLperm, rfl⟩, hX, hepR, hbr⟩
  case isFalse hg =>
    constructor
    · rintro ⟨vea, hmem, -⟩
      exact (List.not_mem_nil hmem).elim
    · rintro ⟨-, -, -, -, hrow, hbad, hoff⟩
      exact absurd ⟨hrow, hbad, hoff⟩ hg

/-! ### 3-bot falsity for order-channel-inconsistent `σ` (future channel) -/

/-- **Eval-side 3-bot falsity (future channel)**: if the order-channel row of `σ` does
    not match the channel pattern `x < t < w`, then NO exterior triple realizes `σ` —
    the atom layer of `extZoneFiberFut_k1` forces the row. -/
theorem navR_inconsistent_eval_false (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (hrow : ¬ navROrderRow σ)
    (w x t : M.carrier) (hxt : x < t) (htw : t < w) :
    ¬ nf_eval_nf M 1 3 (Fin.cons w (Fin.cons x (fun _ => t))) σ := by
  intro hnf
  obtain ⟨hatom, -, -, -⟩ := (extZoneFiberFut_k1 M w x t hxt htw σ).mp hnf
  exact hrow ((navR_atomLayer_iff M w x t hxt htw σ).mp hatom).2.2.2

/-- **Carrier-side 3-bot falsity (off-gate)**: off the gate the carrier is the empty
    disjunction, so its 2-pin semantics is `False` at EVERY pin pair — no ambient
    hypothesis needed. -/
theorem CExtFut_offGate_false (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (hg : ¬ navRGate σ) (x t : M.carrier) :
    ¬ (CExtFut atomMap h_surj σ).holds M atomMap x t := by
  unfold CExtFut
  rw [dif_neg hg]
  rintro ⟨vea, hmem, -⟩
  exact List.not_mem_nil hmem

/-- **Carrier-side 3-bot falsity (order-channel-inconsistent `σ`)**: a `σ` whose
    order-channel row does not match `x < t < w` fails the gate, so the carrier's
    semantics is `False` everywhere — the two falsity readings agree with
    `CExtFut_correct` (both sides `False`). -/
theorem CExtFut_inconsistent_false (M : OrderedMonadicStructure sig)
    (σ : NormalForm sig 1 3) (hrow : ¬ navROrderRow σ) (x t : M.carrier) :
    ¬ (CExtFut atomMap h_surj σ).holds M atomMap x t :=
  CExtFut_offGate_false atomMap h_surj M σ (fun hg => hrow hg.1) x t

end ExteriorNavFut

end FormalSystem.Metalogic.WeakCanonical.Kamp
