import Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.ExteriorNavPastK1

/-! # Until-navigated future-exterior mirror `CExtFut` (task 350 Phase 15 / E5)

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
| atoms at `w` | `nf_depth0_char_formula` on the position-0 projection | (same conjunction, literal polarity) |
| zone `v = w` | characteristic conjunct `charF χ` at the Until-witness | negated characteristic |
| zone `w < v` | native future Until-lit `U(charF χ, ⊤)` (`navDFutLit`) | negated Until-lit |
| zone `t < v < w` | arrangement slot inside the fold (nested-Until chain `navRChain`) | exclusion segment `navRSegGuard` |
| zone `v < x` | native past Since-lit `S(charF χ, ⊤)` (`navLPastLit`) at the pin `x` | negated Since-lit |

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
- specs/350_…/plans/03_negfix-refactor-exterior-carriers.md, Phase 15 (E5 + E6).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

section ExteriorNavFut

variable {sig : MonadicSignature}
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
  | ⟨0, _⟩ => simpa only [ext3Mk, Fin.cons] using e0
  | ⟨1, _⟩ => simpa only [ext3Mk, Fin.cons] using e1
  | ⟨2, _⟩ => simpa only [ext3Mk, Fin.cons] using e2

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

end ExteriorNavFut

end Bimodal.Metalogic.WeakCanonical.Kamp
