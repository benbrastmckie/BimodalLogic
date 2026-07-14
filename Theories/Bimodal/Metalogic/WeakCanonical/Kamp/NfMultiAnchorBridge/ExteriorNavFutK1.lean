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

/-! ## Local profile helpers (the ExteriorNavPastK1.lean private idiom, re-derived) -/

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

/-- Every point realizes its depth-0 monadic characteristic. -/
private theorem navR_profile_exists (M : OrderedMonadicStructure sig) (v : M.carrier) :
    ∃ χ : NormalForm sig 0 1, nf_eval_nf M 0 1 (fun _ => v) χ :=
  ⟨nf_characteristic M 0 1 (fun _ => v), nf_characteristic_satisfies M 0 1 (fun _ => v)⟩

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

end ExteriorNavFut

end Bimodal.Metalogic.WeakCanonical.Kamp
