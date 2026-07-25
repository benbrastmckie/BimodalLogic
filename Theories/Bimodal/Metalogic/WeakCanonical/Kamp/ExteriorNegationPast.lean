import Bimodal.Metalogic.WeakCanonical.Kamp.ExteriorNegation

/-! # One-Sided Exterior Complement Clauses — Past Side (Phase 5)

The past-side (`x1 < x`) mirror of the Phase-3 future-side clause family
(`ExteriorNegation.lean`): for EVERY `σ : NormalForm sig 1 4`,

  `kvE2_extNegPast atomMap h_surj σ = (kvE2_pastPos atomMap h_surj σ).neg`

where `kvE2_pastPos` is the `Since`-navigated positive local-existence form anchored at
the LEFT endpoint `x` (Rabinovich 2014, Cor 5.4(1) exterior analog, p.9; Lemma 7.10
TL-expressibility, p.15): a disjunction over the PERMUTATIONS of σ's gap-profile list of
`D`-guarded `Since` chains, each terminating in the endpoint description (fresh profile +
exact ray content over `(−∞, x1)`). The construction is gated on the syntactic
order-admissibility Bool `kvE2_pastAdmissible` (zone marking `kvE2_sep_zPastX3`,
off-fiber bits, order-impossible zone bits, self-zone bit pattern) — for inadmissible σ
the positive form is `⊥`, so the clause is trivially true; a realizer FORCES
admissibility (`kvE2_pastRealizer_admissible`), so soundness is unconditional.

## Time-reversal dictionary (Phase-2 BINDING signature, modulo side — H6)

| future side (`ExteriorNegation.lean`) | past side (this file) |
|---|---|
| anchor `t`, exterior `t < x1` | anchor `x`, exterior `x1 < x` |
| `Formula.untl` navigation | `Formula.snce` navigation |
| zone marking `kvE2_sep_zFutT3` | zone marking `kvE2_sep_zPastX3` |
| gap `(t, x1)`, coupling `(true, false)` | gap `(x1, x)`, coupling `(false, true)` |
| ray `(x1, ∞)`, coupling `(false, true)` | ray `(−∞, x1)`, coupling `(true, false)` |
| six at-or-below-`t` zones, key `(zs ⟨2⟩).2 = false` | six at-or-above-`x` zones, key `(zs ⟨1⟩).1 = false` |
| minimal-witness chain sort (`kvE2_futMinPick`) | maximal-witness chain sort (`kvE2_pastMaxPick`) |
| `kvE2_exterior_zone_determination_fut` | `kvE2_exterior_zone_determination_past` |

`kvE2_extNegPast_sound` holds under the order bits `(hxw, hwt)` ONLY — the `hexclExt`
binder inventory, no semantic hypothesis on `M`, and no `zPastX3`-marking hypothesis on σ:
a σ realized at exterior `x1 < x` is FORCED to be `zPastX3`-marked
(`kvE2_exterior_zone_determination_past`, Phase 1).

Per the Phase-4 handoff and the plan's H7 territory note, the future-side `private`
helpers are NOT reachable from this file; the side-parametric generalization is deferred
to Phase 7's dedupe pass, and this file keeps past-side local copies (the side-neutral
`nf_profile_unique`/`nf_profile_exists` verbatim, the rest time-reversed). The public
side-neutral lemmas `nf_depth0_char_correct'` and `kvE2_futFreshProfile` are reused
directly from `ExteriorNegation.lean`.

Phase 6 (below) adds `kvE2_extNegPast_complete` (the pinned ⇐ direction): the
time-reversal of `kvE2_extNegFut_complete` via the private mirrors
`kvE2_pastAbove_ge_x`/`kvE2_pastZone4_above_iff`, `kvE2_pastSigma_atom`, and
`kvE2_pastChainDestruct`; the at-or-above-`x` bit comparison reuses the SIDE-NEUTRAL
`kvE2_futAnyBit qnf` with the six-constant guard swapped to `{zAtX3 … zFutT3}`.

Purely additive leaf module (H7 territory: this file + additive import wiring only). -/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical
open Bimodal.Metalogic.WeakCanonical.Separation

/-- `ZoneSpec n` equality is decidable (file-local mirror of the private SW:61 bridge;
    the `ExteriorNegation.lean` copy is `private` and not reachable here). -/
private instance {n : Nat} : DecidableEq (ZoneSpec n) :=
  -- `inferInstanceAs`, not `decidable_of_iff (∀ i, a i = b i) …`: the latter needs
  -- `Decidable (∀ i : Fin n, a i = b i)`, which instance search cannot build without
  -- unfolding the semireducible `ZoneSpec`. Naming the unfolded type sidesteps that.
  inferInstanceAs (DecidableEq (Fin n → Bool × Bool))

/-- `ZoneSpec 4` is a finite type (file-local mirror, as above). -/
private instance : Fintype (ZoneSpec 4) :=
  inferInstanceAs (Fintype (Fin 4 → Bool × Bool))

/-- Profiles realized by the same point coincide (file-local copy of the side-neutral
    `ExteriorNegation.lean` private lemma; dedupe deferred to Phase 7). -/
private theorem nf_profile_unique {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v : M.carrier) (χ χ' : NormalForm sig 0 1)
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

/-- Every point realizes its depth-0 monadic characteristic (file-local copy, as above). -/
private theorem nf_profile_exists {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v : M.carrier) :
    ∃ χ : NormalForm sig 0 1, nf_eval_nf M 0 1 (fun _ => v) χ :=
  ⟨nf_characteristic M 0 1 (fun _ => v), nf_characteristic_satisfies M 0 1 (fun _ => v)⟩

/-! ## Zone bookkeeping helpers (time-reversed mirrors) -/

/-- A point strictly below `x` (with `x < w < t`) couples to `[w,x,t]` as `zPastX3` and
    to `x1` by the given pair — the canonical zone-4 spec of each `(−∞, x)`-side
    position (mirror of `kvE2_futZone4_of_above`). -/
private theorem kvE2_pastZone4_of_below {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hvx : v < x)
    (p0 : Bool × Bool)
    (h0a : v < x1 ↔ p0.1 = true) (h0b : x1 < v ↔ p0.2 = true) :
    zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t))))
      (Fin.cons p0 kvE2_sep_zPastX3) v := by
  intro i
  match i with
  | ⟨0, _⟩ => exact ⟨h0a, h0b⟩
  | ⟨1, _⟩ =>
    exact ⟨iff_of_true (hvx.trans hxw) rfl,
           iff_of_false (lt_asymm (hvx.trans hxw)) Bool.false_ne_true⟩
  | ⟨2, _⟩ =>
    exact ⟨iff_of_true hvx rfl, iff_of_false (lt_asymm hvx) Bool.false_ne_true⟩
  | ⟨3, _⟩ =>
    exact ⟨iff_of_true (hvx.trans (hxw.trans hwt)) rfl,
           iff_of_false (lt_asymm (hvx.trans (hxw.trans hwt))) Bool.false_ne_true⟩

/-- Zone-4 characterization: a `zoneHolds` spec is pointwise forced by the witness's
    actual order relations (side-neutral local copy of `kvE2_futCharZone4`). -/
private theorem kvE2_pastCharZone4 {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier) (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v)
    (p0 p1 p2 p3 : Bool × Bool)
    (h0a : v < x1 ↔ p0.1 = true) (h0b : x1 < v ↔ p0.2 = true)
    (h1a : v < w ↔ p1.1 = true) (h1b : w < v ↔ p1.2 = true)
    (h2a : v < x ↔ p2.1 = true) (h2b : x < v ↔ p2.2 = true)
    (h3a : v < t ↔ p3.1 = true) (h3b : t < v ↔ p3.2 = true) :
    zs = Fin.cons p0 (Fin.cons p1 (Fin.cons p2 (fun _ => p3))) := by
  funext i
  match i with
  | ⟨0, _⟩ =>
    have hz0 := hz ⟨0, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz0.1.symm.trans h0a))
      (Bool.eq_iff_iff.mpr (hz0.2.symm.trans h0b))
  | ⟨1, _⟩ =>
    have hz1 := hz ⟨1, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz1.1.symm.trans h1a))
      (Bool.eq_iff_iff.mpr (hz1.2.symm.trans h1b))
  | ⟨2, _⟩ =>
    have hz2 := hz ⟨2, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz2.1.symm.trans h2a))
      (Bool.eq_iff_iff.mpr (hz2.2.symm.trans h2b))
  | ⟨3, _⟩ =>
    have hz3 := hz ⟨3, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz3.1.symm.trans h3a))
      (Bool.eq_iff_iff.mpr (hz3.2.symm.trans h3b))

/-- Zone-3 spec uniqueness over `[w,x,t]` (side-neutral local copy of
    `kvE2_futCharZone3'`). -/
private theorem kvE2_pastCharZone3' {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v w x t : M.carrier) (zs3 : ZoneSpec 3)
    (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs3 v)
    (p0 p1 p2 : Bool × Bool)
    (h0a : v < w ↔ p0.1 = true) (h0b : w < v ↔ p0.2 = true)
    (h1a : v < x ↔ p1.1 = true) (h1b : x < v ↔ p1.2 = true)
    (h2a : v < t ↔ p2.1 = true) (h2b : t < v ↔ p2.2 = true) :
    zs3 = Fin.cons p0 (Fin.cons p1 (fun _ => p2)) := by
  funext i
  match i with
  | ⟨0, _⟩ =>
    have hz0 := hz ⟨0, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz0.1.symm.trans h0a))
      (Bool.eq_iff_iff.mpr (hz0.2.symm.trans h0b))
  | ⟨1, _⟩ =>
    have hz1 := hz ⟨1, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz1.1.symm.trans h1a))
      (Bool.eq_iff_iff.mpr (hz1.2.symm.trans h1b))
  | ⟨2, _⟩ =>
    have hz2 := hz ⟨2, by omega⟩
    exact Prod.ext (Bool.eq_iff_iff.mpr (hz2.1.symm.trans h2a))
      (Bool.eq_iff_iff.mpr (hz2.2.symm.trans h2b))

/-- **Above-`x` zone classification** (mirror of `kvE2_futBelowClass`): an
    at-or-above-`x` witness's `[w,x,t]` zone spec is one of the six canonical
    constants `zAtX3 … zFutT3`. -/
private theorem kvE2_pastAboveClass {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hxv : x ≤ v)
    (zs3 : ZoneSpec 3) (hz : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs3 v) :
    zs3 = kvE2_sep_zAtX3 ∨ zs3 = kvE2_sep_zXW3 ∨ zs3 = kvE2_sep_zAtW3 ∨
      zs3 = kvE2_sep_zWT3 ∨ zs3 = kvE2_sep_zAtT3 ∨ zs3 = kvE2_sep_zFutT3 := by
  rcases hxv.lt_or_eq with hx | hx
  · -- x < v : trichotomy against w, then t
    rcases lt_trichotomy v w with hw | hw | hw
    · exact Or.inr (Or.inl
        (kvE2_pastCharZone3' M v w x t zs3 hz (true, false) (false, true) (true, false)
          (iff_of_true hw rfl) (iff_of_false (lt_asymm hw) Bool.false_ne_true)
          (iff_of_false (lt_asymm hx) Bool.false_ne_true) (iff_of_true hx rfl)
          (iff_of_true (hw.trans hwt) rfl)
          (iff_of_false (lt_asymm (hw.trans hwt)) Bool.false_ne_true)))
    · exact Or.inr (Or.inr (Or.inl
        (kvE2_pastCharZone3' M v w x t zs3 hz (false, false) (false, true) (true, false)
          (iff_of_false (by rw [hw]; exact lt_irrefl w) Bool.false_ne_true)
          (iff_of_false (by rw [hw]; exact lt_irrefl w) Bool.false_ne_true)
          (iff_of_false (lt_asymm hx) Bool.false_ne_true) (iff_of_true hx rfl)
          (iff_of_true (by rw [hw]; exact hwt) rfl)
          (iff_of_false (by rw [hw]; exact lt_asymm hwt) Bool.false_ne_true))))
    · rcases lt_trichotomy v t with ht | ht | ht
      · exact Or.inr (Or.inr (Or.inr (Or.inl
          (kvE2_pastCharZone3' M v w x t zs3 hz (false, true) (false, true) (true, false)
            (iff_of_false (lt_asymm hw) Bool.false_ne_true) (iff_of_true hw rfl)
            (iff_of_false (lt_asymm hx) Bool.false_ne_true) (iff_of_true hx rfl)
            (iff_of_true ht rfl) (iff_of_false (lt_asymm ht) Bool.false_ne_true)))))
      · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl
          (kvE2_pastCharZone3' M v w x t zs3 hz (false, true) (false, true) (false, false)
            (iff_of_false (lt_asymm hw) Bool.false_ne_true) (iff_of_true hw rfl)
            (iff_of_false (lt_asymm hx) Bool.false_ne_true) (iff_of_true hx rfl)
            (iff_of_false (by rw [ht]; exact lt_irrefl t) Bool.false_ne_true)
            (iff_of_false (by rw [ht]; exact lt_irrefl t) Bool.false_ne_true))))))
      · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr
          (kvE2_pastCharZone3' M v w x t zs3 hz (false, true) (false, true) (false, true)
            (iff_of_false (lt_asymm hw) Bool.false_ne_true) (iff_of_true hw rfl)
            (iff_of_false (lt_asymm hx) Bool.false_ne_true) (iff_of_true hx rfl)
            (iff_of_false (lt_asymm ht) Bool.false_ne_true) (iff_of_true ht rfl))))))
  · -- x = v : left-endpoint boundary zAtX3
    exact Or.inl
      (kvE2_pastCharZone3' M v w x t zs3 hz (true, false) (false, false) (true, false)
        (iff_of_true (by rw [← hx]; exact hxw) rfl)
        (iff_of_false (by rw [← hx]; exact lt_asymm hxw) Bool.false_ne_true)
        (iff_of_false (by rw [← hx]; exact lt_irrefl x) Bool.false_ne_true)
        (iff_of_false (by rw [← hx]; exact lt_irrefl x) Bool.false_ne_true)
        (iff_of_true (by rw [← hx]; exact hxw.trans hwt) rfl)
        (iff_of_false (by rw [← hx]; exact lt_asymm (hxw.trans hwt)) Bool.false_ne_true))

/-! ### σ's exterior-zone channels (past side) -/

/-- Gap-zone bit of σ: does σ prescribe a point of profile `χ` in `(x1, x)`? -/
noncomputable def kvE2_pastGapBit {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : Bool :=
  σ.2 (nf0_assemble (Fin.cons (false, true) kvE2_sep_zPastX3) χ σ.1)

/-- Ray-zone bit of σ: does σ prescribe a point of profile `χ` in `(−∞, x1)`? -/
noncomputable def kvE2_pastRayBit {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : Bool :=
  σ.2 (nf0_assemble (Fin.cons (true, false) kvE2_sep_zPastX3) χ σ.1)

/-- Self-zone bit of σ: does σ prescribe profile `χ` at the fresh point `x1` itself? -/
noncomputable def kvE2_pastSelfBit {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) (χ : NormalForm sig 0 1) : Bool :=
  σ.2 (nf0_assemble (Fin.cons (false, false) kvE2_sep_zPastX3) χ σ.1)

/-- The (nodup) list of gap profiles σ prescribes for `(x1, x)`. -/
noncomputable def kvE2_pastGapList {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : List (NormalForm sig 0 1) :=
  Finset.univ.toList.filter (kvE2_pastGapBit σ)

/-- The (nodup) list of ray profiles σ prescribes for `(−∞, x1)`. -/
noncomputable def kvE2_pastRayList {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : List (NormalForm sig 0 1) :=
  Finset.univ.toList.filter (kvE2_pastRayBit σ)

/-- The nine zone-4 specs an actual point can carry relative to `[x1, w, x, t]` with
    `x1 < x < w < t`: the six at-or-above-`x` couplings, the gap, the self point, and
    the ray. Everything else is order-impossible. -/
def kvE2_pastPossibleZones : List (ZoneSpec 4) :=
  [Fin.cons (false, true) kvE2_sep_zAtX3,
   Fin.cons (false, true) kvE2_sep_zXW3,
   Fin.cons (false, true) kvE2_sep_zAtW3,
   Fin.cons (false, true) kvE2_sep_zWT3,
   Fin.cons (false, true) kvE2_sep_zAtT3,
   Fin.cons (false, true) kvE2_sep_zFutT3,
   Fin.cons (false, true) kvE2_sep_zPastX3,
   Fin.cons (false, false) kvE2_sep_zPastX3,
   Fin.cons (true, false) kvE2_sep_zPastX3]

/-! #### Membership certificates for `kvE2_pastPossibleZones`

Mirror of the future-side block in `ExteriorNegation.lean`, and for the same reason: the
entries are `Fin.cons p (zs3 : ZoneSpec 3)`, whose implicit motive is solved as
`fun _ => Bool × Bool`, so the tail's expected type is `Fin 3 → Bool × Bool` while its
actual type is the semireducible `ZoneSpec 3`. Since Lean 4.31 definitional equality
strictly respects transparency levels, the list literal is not type-correct at `implicit`
transparency and `simp`/`rcases` refuse to traverse it. `exact`/`apply` check at `default`,
where `ZoneSpec` unfolds. -/

/-- Any of the six at-or-above-`x` couplings, headed by `(false, true)`, is a possible zone. -/
private theorem kvE2_pastPossibleZones_mem_above (zs3 : ZoneSpec 3)
    (h : zs3 = kvE2_sep_zAtX3 ∨ zs3 = kvE2_sep_zXW3 ∨ zs3 = kvE2_sep_zAtW3 ∨
      zs3 = kvE2_sep_zWT3 ∨ zs3 = kvE2_sep_zAtT3 ∨ zs3 = kvE2_sep_zFutT3) :
    Fin.cons (false, true) zs3 ∈ kvE2_pastPossibleZones := by
  rcases h with rfl | rfl | rfl | rfl | rfl | rfl
  · exact List.Mem.head _
  · exact List.Mem.tail _ (List.Mem.head _)
  · exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))
  · exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))
  · exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))))
  · exact List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _
      (List.Mem.tail _ (List.Mem.head _)))))

/-- The gap zone `(x1, x)` is a possible zone (entry 7). -/
theorem kvE2_pastPossibleZones_mem_gap :
    Fin.cons (false, true) kvE2_sep_zPastX3 ∈ kvE2_pastPossibleZones :=
  List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _
    (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))))))

/-- The self zone `x1` itself is a possible zone (entry 8). -/
theorem kvE2_pastPossibleZones_mem_self :
    Fin.cons (false, false) kvE2_sep_zPastX3 ∈ kvE2_pastPossibleZones :=
  List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _
    (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _)))))))

/-- The ray zone `(−∞, x1)` is a possible zone (entry 9). -/
theorem kvE2_pastPossibleZones_mem_ray :
    Fin.cons (true, false) kvE2_sep_zPastX3 ∈ kvE2_pastPossibleZones :=
  List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _
    (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.tail _ (List.Mem.head _))))))))

/-- Elimination form: membership in `kvE2_pastPossibleZones` is the nine-way disjunction. -/
private theorem kvE2_pastPossibleZones_cases {zs : ZoneSpec 4}
    (h : zs ∈ kvE2_pastPossibleZones) :
    zs = Fin.cons (false, true) kvE2_sep_zAtX3 ∨
      zs = Fin.cons (false, true) kvE2_sep_zXW3 ∨
      zs = Fin.cons (false, true) kvE2_sep_zAtW3 ∨
      zs = Fin.cons (false, true) kvE2_sep_zWT3 ∨
      zs = Fin.cons (false, true) kvE2_sep_zAtT3 ∨
      zs = Fin.cons (false, true) kvE2_sep_zFutT3 ∨
      zs = Fin.cons (false, true) kvE2_sep_zPastX3 ∨
      zs = Fin.cons (false, false) kvE2_sep_zPastX3 ∨
      zs = Fin.cons (true, false) kvE2_sep_zPastX3 := by
  rcases List.mem_cons.mp h with h | h
  · exact Or.inl h
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inl h)
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inl h))
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inr (Or.inl h)))
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h))))
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h)))))
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h))))))
  rcases List.mem_cons.mp h with h | h
  · exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl h)))))))
  exact Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr
    (List.mem_singleton.mp h))))))))

/-- **Zone-4 classification at exterior `x1`** (past side): any point's `zoneHolds`
    spec over `[x1, w, x, t]` (with `x1 < x < w < t`) is one of the nine possible
    zones. -/
theorem kvE2_pastZoneClass {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (v x1 w x t : M.carrier)
    (hxw : x < w) (hwt : w < t) (hx1x : x1 < x)
    (zs : ZoneSpec 4)
    (hz : zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) zs v) :
    zs ∈ kvE2_pastPossibleZones := by
  rcases le_or_gt x v with hxv | hvx
  · -- at-or-above x: head coupling (false, true), tail one of the six above constants
    have hz3 : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) (Fin.tail zs) v :=
      fun i => hz i.succ
    have h0 := hz ⟨0, by omega⟩
    have hgt : x1 < v := hx1x.trans_le hxv
    have hzeq0 : zs 0 = (false, true) :=
      Prod.ext (by
        cases hb : (zs 0).1 with
        | false => rfl
        | true => exact absurd (h0.1.mpr hb) (lt_asymm hgt))
        (h0.2.mp hgt)
    have hcls := kvE2_pastAboveClass M v w x t hxw hwt hxv (Fin.tail zs) hz3
    rw [← Fin.cons_self_tail zs, hzeq0]
    exact kvE2_pastPossibleZones_mem_above (Fin.tail zs) hcls
  · -- below x: the three (−∞, x)-side zones by trichotomy against x1
    rcases lt_trichotomy v x1 with hvx1 | hvx1 | hvx1
    · have hzeq := kvE2_pastCharZone4 M v x1 w x t zs hz
        (true, false) (true, false) (true, false) (true, false)
        (iff_of_true hvx1 rfl) (iff_of_false (lt_asymm hvx1) Bool.false_ne_true)
        (iff_of_true (hvx.trans hxw) rfl)
        (iff_of_false (lt_asymm (hvx.trans hxw)) Bool.false_ne_true)
        (iff_of_true hvx rfl) (iff_of_false (lt_asymm hvx) Bool.false_ne_true)
        (iff_of_true (hvx.trans (hxw.trans hwt)) rfl)
        (iff_of_false (lt_asymm (hvx.trans (hxw.trans hwt))) Bool.false_ne_true)
      rw [hzeq]
      exact kvE2_pastPossibleZones_mem_ray
    · have hzeq := kvE2_pastCharZone4 M v x1 w x t zs hz
        (false, false) (true, false) (true, false) (true, false)
        (iff_of_false (hvx1 ▸ lt_irrefl v) Bool.false_ne_true)
        (iff_of_false (hvx1 ▸ lt_irrefl v) Bool.false_ne_true)
        (iff_of_true (hvx.trans hxw) rfl)
        (iff_of_false (lt_asymm (hvx.trans hxw)) Bool.false_ne_true)
        (iff_of_true hvx rfl) (iff_of_false (lt_asymm hvx) Bool.false_ne_true)
        (iff_of_true (hvx.trans (hxw.trans hwt)) rfl)
        (iff_of_false (lt_asymm (hvx.trans (hxw.trans hwt))) Bool.false_ne_true)
      rw [hzeq]
      exact kvE2_pastPossibleZones_mem_self
    · have hzeq := kvE2_pastCharZone4 M v x1 w x t zs hz
        (false, true) (true, false) (true, false) (true, false)
        (iff_of_false (lt_asymm hvx1) Bool.false_ne_true) (iff_of_true hvx1 rfl)
        (iff_of_true (hvx.trans hxw) rfl)
        (iff_of_false (lt_asymm (hvx.trans hxw)) Bool.false_ne_true)
        (iff_of_true hvx rfl) (iff_of_false (lt_asymm hvx) Bool.false_ne_true)
        (iff_of_true (hvx.trans (hxw.trans hwt)) rfl)
        (iff_of_false (lt_asymm (hvx.trans (hxw.trans hwt))) Bool.false_ne_true)
      rw [hzeq]
      exact kvE2_pastPossibleZones_mem_gap

/-! ### Syntactic order-admissibility (past side) -/

/-- **Order-admissibility of σ** (past side, syntactic, model-independent): the
    conjunction of the conditions a realizer at exterior `x1 < x` FORCES on σ —

    1. `zPastX3` zone marking of the base layer;
    2. off-fiber quant bits false;
    3. quant bits false on every order-impossible zone-4 spec;
    4. self-zone bits carve out exactly the fresh profile `nf0_projFresh σ.1`.

    For inadmissible σ the positive form below is `⊥` (clause trivially true), which is
    sound because such σ has NO exterior realizer (`kvE2_pastRealizer_admissible`). -/
noncomputable def kvE2_pastAdmissible {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (σ : NormalForm sig 1 4) : Bool :=
  decide (nf0_zoneSpec σ.1 = kvE2_sep_zPastX3) &&
  ((Finset.univ.toList (α := NormalForm sig 0 5)).all fun τ =>
    decide (nf0_dropFresh τ = show NormalForm sig 0 4 from σ.1) || !(σ.2 τ)) &&
  ((Finset.univ.toList (α := ZoneSpec 4)).all fun zs =>
    (kvE2_pastPossibleZones.any fun z => decide (zs = z)) ||
    ((Finset.univ.toList (α := NormalForm sig 0 1)).all fun χ =>
      !(σ.2 (nf0_assemble zs χ σ.1)))) &&
  ((Finset.univ.toList (α := NormalForm sig 0 1)).all fun χ =>
    decide (kvE2_pastSelfBit σ χ = decide (χ = nf0_projFresh σ.1)))

/-- **A realizer forces admissibility** (past side): if some exterior `x1 < x` realizes
    σ over `[x1, w, x, t]` (with `x < w < t`), then σ is order-admissible. Uses only
    the order bits — no semantic hypothesis on `M`. The fresh-profile read reuses the
    side-neutral `kvE2_futFreshProfile` (public in `ExteriorNegation.lean`). -/
theorem kvE2_pastRealizer_admissible {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (hx1x : x1 < x)
    (hnf : nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    kvE2_pastAdmissible σ = true := by
  obtain ⟨hatomσ, hquantσ, hoff⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hnf
  have hx1fr := kvE2_futFreshProfile M σ x1 w x t hatomσ
  rw [kvE2_pastAdmissible]
  simp only [Bool.and_eq_true]
  refine ⟨⟨⟨?_, ?_⟩, ?_⟩, ?_⟩
  · -- zone marking (Phase-1 zone determination, past side)
    exact decide_eq_true
      (kvE2_exterior_zone_determination_past M x1 w x t σ hxw hwt hx1x hnf)
  · -- off-fiber bits false
    rw [List.all_eq_true]
    intro τ _
    by_cases hτ : nf0_dropFresh τ = show NormalForm sig 0 4 from σ.1
    · rw [decide_eq_true hτ, Bool.true_or]
    · rw [hoff τ hτ, Bool.not_false, Bool.or_true]
  · -- order-impossible zone bits false
    rw [List.all_eq_true]
    intro zs _
    by_cases hzp : ∃ z ∈ kvE2_pastPossibleZones, zs = z
    · obtain ⟨z, hzmem, hzeq⟩ := hzp
      rw [Bool.or_eq_true]
      exact Or.inl (List.any_eq_true.mpr ⟨z, hzmem, decide_eq_true hzeq⟩)
    · rw [Bool.or_eq_true]
      refine Or.inr ?_
      rw [List.all_eq_true]
      intro χ _
      cases hb : σ.2 (nf0_assemble zs χ σ.1) with
      | false => rfl
      | true =>
        obtain ⟨v, hzv, -⟩ := (hquantσ zs χ).mpr hb
        exact absurd ⟨zs, kvE2_pastZoneClass M v x1 w x t hxw hwt hx1x zs hzv, rfl⟩ hzp
  · -- self-zone bit pattern
    rw [List.all_eq_true]
    intro χ _
    refine decide_eq_true ?_
    rw [Bool.eq_iff_iff]
    constructor
    · intro hb
      obtain ⟨v, hzv, hvχ⟩ := (hquantσ (Fin.cons (false, false) kvE2_sep_zPastX3) χ).mpr hb
      have h0 := hzv ⟨0, by omega⟩
      have hvx1 : v = x1 := by
        have hn1 : ¬ v < x1 := fun hltv => absurd (h0.1.mp hltv) Bool.false_ne_true
        have hn2 : ¬ x1 < v := fun hltv => absurd (h0.2.mp hltv) Bool.false_ne_true
        exact le_antisymm (not_lt.mp hn2) (not_lt.mp hn1)
      subst hvx1
      exact decide_eq_true (nf_profile_unique M v χ (nf0_projFresh σ.1) hvχ hx1fr)
    · intro hd
      have hχ : χ = nf0_projFresh σ.1 := of_decide_eq_true hd
      subst hχ
      exact (hquantσ (Fin.cons (false, false) kvE2_sep_zPastX3) _).mp
        ⟨x1, kvE2_pastZone4_of_below M x1 x1 w x t hxw hwt hx1x (false, false)
          (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
          (iff_of_false (lt_irrefl x1) Bool.false_ne_true), hx1fr⟩

/-! ### The clause family (past side) -/

/-- Gap guard `D`: the disjunction of the characteristic formulas of σ's gap profiles
    (empty gap list gives `⊥` — the "no gap points" guard). -/
noncomputable def kvE2_pastGapD {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  formula_disjList ((kvE2_pastGapList σ).map (nf_depth0_char_formula atomMap h_surj))

/-- Ray disjunction: the characteristic disjunction of σ's ray profiles. -/
noncomputable def kvE2_pastRayD {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  formula_disjList ((kvE2_pastRayList σ).map (nf_depth0_char_formula atomMap h_surj))

/-- Exact-ray-content form at the endpoint (past side): every past point carries a ray
    profile (`¬P(¬D_ray)` — for `S_ray = ∅` this is ray emptiness `¬P⊤` semantics),
    and each ray profile occurs (`P(char χ)` for each `χ ∈ S_ray`). -/
noncomputable def kvE2_pastRayForm {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  formula_conjList
    ((Formula.snce (kvE2_pastRayD atomMap h_surj σ).neg Formula.top).neg ::
      (kvE2_pastRayList σ).map fun χ =>
        Formula.snce (nf_depth0_char_formula atomMap h_surj χ) Formula.top)

/-- Endpoint description: fresh profile + exact ray content. -/
noncomputable def kvE2_pastEnd {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  formula_conjList
    [nf_depth0_char_formula atomMap h_surj (nf0_projFresh σ.1),
     kvE2_pastRayForm atomMap h_surj σ]

/-- `D`-guarded `Since` chain visiting the listed profiles in order (descending) and
    terminating in `endF` — the Lemma 5.3 / Cor 5.4 O_n device, time-reversed. -/
noncomputable def kvE2_pastChain {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (endF D : Formula) : List (NormalForm sig 0 1) → Formula
  | [] => Formula.snce endF D
  | χ :: rest =>
      Formula.snce
        (formula_conjList
          [nf_depth0_char_formula atomMap h_surj χ,
           kvE2_pastChain atomMap h_surj endF D rest])
        D

/-- **Positive local-existence form** for σ (Cor 5.4(1) exterior analog, general form):
    admissibility-gated disjunction over the permutations of σ's gap-profile list of
    `D`-guarded `Since` chains ending in the endpoint description. -/
noncomputable def kvE2_pastPos {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  if kvE2_pastAdmissible σ = true then
    formula_disjList ((kvE2_pastGapList σ).permutations.map
      (kvE2_pastChain atomMap h_surj (kvE2_pastEnd atomMap h_surj σ)
        (kvE2_pastGapD atomMap h_surj σ)))
  else Formula.bot

/-- **The past-side complement clause family** (Phase-2 BINDING signature, modulo
    side): the negation of the positive local-existence form, anchored at `x`. -/
noncomputable def kvE2_extNegPast {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4) : Formula :=
  (kvE2_pastPos atomMap h_surj σ).neg

/-! ### Soundness of the clause family (past side) -/

/-- Maximal-witness selection (mirror of `kvE2_futMinPick`): from per-element witnesses
    over a nonempty list, pick an element whose witness is ≥ every element's (some)
    witness. -/
private theorem kvE2_pastMaxPick {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {α : Type}
    (M : OrderedMonadicStructure sig) (P : α → M.carrier → Prop) :
    ∀ l : List α, l ≠ [] → (∀ a ∈ l, ∃ r, P a r) →
      ∃ a₀, a₀ ∈ l ∧ ∃ r₀, P a₀ r₀ ∧ ∀ a ∈ l, ∃ r, P a r ∧ r ≤ r₀ := by
  intro l
  induction l with
  | nil => intro h; exact absurd rfl h
  | cons a l ih =>
    intro _ hocc
    obtain ⟨r, hr⟩ := hocc a (by simp)
    by_cases hl : l = []
    · subst hl
      refine ⟨a, by simp, r, hr, fun b hb => ?_⟩
      rw [List.mem_singleton] at hb
      subst hb
      exact ⟨r, hr, le_refl r⟩
    · obtain ⟨a', ha'mem, r', hr', hmax⟩ :=
        ih hl (fun c hc => hocc c (List.mem_cons_of_mem a hc))
      rcases le_or_gt r' r with hle | hlt
      · refine ⟨a, by simp, r, hr, fun c hc => ?_⟩
        rcases List.mem_cons.mp hc with rfl | hc'
        · exact ⟨r, hr, le_refl r⟩
        · obtain ⟨r'', hr'', hle'⟩ := hmax c hc'
          exact ⟨r'', hr'', hle'.trans hle⟩
      · refine ⟨a', List.mem_cons_of_mem a ha'mem, r', hr', fun c hc => ?_⟩
        rcases List.mem_cons.mp hc with rfl | hc'
        · exact ⟨r, hr, hlt.le⟩
        · exact hmax c hc'

/-- **Chain construction** (past side): from a `D`-uniform gap above `x1`, an endpoint
    description at `x1`, and one occurrence in `(x1, s)` for each profile in a nodup
    list `L`, SOME permutation of `L` carries a true `D`-guarded `Since` chain at `s`
    (sort the chosen occurrences by maximal-witness extraction; distinct profiles
    occupy distinct points, so the strict order propagates through the recursion). -/
private theorem kvE2_pastChainBuild {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (endF D : Formula) (x x1 : M.carrier)
    (hD : ∀ r : M.carrier, x1 < r → r < x → temporal_truth M atomMap r D)
    (hend : temporal_truth M atomMap x1 endF) :
    ∀ (n : Nat) (L : List (NormalForm sig 0 1)), L.length ≤ n → L.Nodup →
      ∀ s : M.carrier, x1 < s → (∀ r : M.carrier, r < s → r < x) →
      (∀ χ ∈ L, ∃ r : M.carrier, r < s ∧ x1 < r ∧ nf_eval_nf M 0 1 (fun _ => r) χ) →
      ∃ l : List (NormalForm sig 0 1), l.Perm L ∧
        temporal_truth M atomMap s (kvE2_pastChain atomMap h_surj endF D l) := by
  intro n
  induction n with
  | zero =>
    intro L hlen _ s hx1s hbound _
    have hL : L = [] := by
      cases L with
      | nil => rfl
      | cons a l => simp at hlen
    subst hL
    refine ⟨[], List.Perm.refl [], ?_⟩
    simp only [kvE2_pastChain]
    exact ⟨x1, hx1s, hend, fun r hx1r hrs => hD r hx1r (hbound r hrs)⟩
  | succ n ih =>
    intro L hlen hnd s hx1s hbound hocc
    by_cases hL : L = []
    · subst hL
      refine ⟨[], List.Perm.refl [], ?_⟩
      simp only [kvE2_pastChain]
      exact ⟨x1, hx1s, hend, fun r hx1r hrs => hD r hx1r (hbound r hrs)⟩
    · obtain ⟨χ₀, hχ₀mem, r₀, ⟨hr₀s, hx1r₀, hprof₀⟩, hmax⟩ :=
        kvE2_pastMaxPick M
          (fun χ r => r < s ∧ x1 < r ∧ nf_eval_nf M 0 1 (fun _ => r) χ) L hL hocc
      have hr₀x : r₀ < x := hbound r₀ hr₀s
      have hlen' : (L.erase χ₀).length ≤ n := by
        have h1 := List.length_erase_of_mem hχ₀mem
        have h2 : 0 < L.length := List.length_pos_of_mem hχ₀mem
        omega
      obtain ⟨l', hl'perm, hl'truth⟩ := ih (L.erase χ₀) hlen' (hnd.erase χ₀) r₀ hx1r₀
        (fun r hr => hr.trans hr₀x)
        (fun χ hχ => by
          obtain ⟨hne, hχL⟩ := (List.Nodup.mem_erase_iff hnd).mp hχ
          obtain ⟨r, ⟨_, hx1r, hprofr⟩, hler⟩ := hmax χ hχL
          refine ⟨r, lt_of_le_of_ne hler ?_, hx1r, hprofr⟩
          intro he
          exact hne (nf_profile_unique M r χ χ₀ hprofr (he ▸ hprof₀)))
      refine ⟨χ₀ :: l', (hl'perm.cons χ₀).trans (List.perm_cons_erase hχ₀mem).symm, ?_⟩
      simp only [kvE2_pastChain]
      refine ⟨r₀, hr₀s, ?_,
        fun r hr₀r hrs => hD r (hx1r₀.trans hr₀r) (hbound r hrs)⟩
      rw [formula_conjList_iff]
      intro f hf
      simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
      rcases hf with rfl | rfl
      · exact (nf_depth0_char_correct' M atomMap h_surj χ₀ r₀).mpr hprof₀
      · exact hl'truth

/-- **Family soundness** (Cor 5.4(1) exterior analog, ⇒ — the Phase-2 BINDING
    signature, side Past): if the complement clause of σ holds at the left anchor `x`,
    then no exterior point `x1 < x` realizes σ. Uses only the order bits `hxw`/`hwt`
    (the `hexclExt` binder inventory) — no semantic hypothesis on `M`, and no
    zone-marking hypothesis on σ (a realized exterior σ is forced `zPastX3`-marked).
    This direction discharges `hexclExt` for the whole past-side alphabet. -/
theorem kvE2_extNegPast_sound {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (σ : NormalForm sig 1 4)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (hcl : temporal_truth M atomMap x (kvE2_extNegPast atomMap h_surj σ)) :
    ∀ x1 : M.carrier, x1 < x →
      ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ := by
  intro x1 hx1x hnf
  obtain ⟨hatomσ, hquantσ, -⟩ := (nf_eval_depth1_fold_iff M _ σ).mp hnf
  have hadm : kvE2_pastAdmissible σ = true :=
    kvE2_pastRealizer_admissible M σ x1 w x t hxw hwt hx1x hnf
  have hx1fr := kvE2_futFreshProfile M σ x1 w x t hatomσ
  -- the gap (x1, x) is uniformly D
  have hD : ∀ r : M.carrier, x1 < r → r < x →
      temporal_truth M atomMap r (kvE2_pastGapD atomMap h_surj σ) := by
    intro r hx1r hrx
    obtain ⟨χr, hχr⟩ := nf_profile_exists M r
    have hzr := kvE2_pastZone4_of_below M r x1 w x t hxw hwt hrx (false, true)
      (iff_of_false (lt_asymm hx1r) Bool.false_ne_true) (iff_of_true hx1r rfl)
    have hb : kvE2_pastGapBit σ χr = true :=
      (hquantσ (Fin.cons (false, true) kvE2_sep_zPastX3) χr).mp ⟨r, hzr, hχr⟩
    rw [kvE2_pastGapD, formula_disjList_iff]
    exact ⟨_, List.mem_map.mpr
      ⟨χr, List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ χr), hb⟩, rfl⟩,
      (nf_depth0_char_correct' M atomMap h_surj χr r).mpr hχr⟩
  -- endpoint description at x1
  have hend : temporal_truth M atomMap x1 (kvE2_pastEnd atomMap h_surj σ) := by
    rw [kvE2_pastEnd, formula_conjList_iff]
    intro f hf
    simp only [List.mem_cons, List.not_mem_nil, or_false] at hf
    rcases hf with rfl | rfl
    · exact (nf_depth0_char_correct' M atomMap h_surj _ x1).mpr hx1fr
    · rw [kvE2_pastRayForm, formula_conjList_iff]
      intro g hg
      rcases List.mem_cons.mp hg with rfl | hg'
      · -- every past point carries a ray profile
        intro hP
        obtain ⟨u, hux1, hnotD, -⟩ := hP
        apply hnotD
        obtain ⟨χu, hχu⟩ := nf_profile_exists M u
        have hzu := kvE2_pastZone4_of_below M u x1 w x t hxw hwt (hux1.trans hx1x)
          (true, false)
          (iff_of_true hux1 rfl) (iff_of_false (lt_asymm hux1) Bool.false_ne_true)
        have hb : kvE2_pastRayBit σ χu = true :=
          (hquantσ (Fin.cons (true, false) kvE2_sep_zPastX3) χu).mp ⟨u, hzu, hχu⟩
        rw [kvE2_pastRayD, formula_disjList_iff]
        exact ⟨_, List.mem_map.mpr
          ⟨χu, List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ χu), hb⟩, rfl⟩,
          (nf_depth0_char_correct' M atomMap h_surj χu u).mpr hχu⟩
      · -- each ray profile occurs
        obtain ⟨χ, hχmem, rfl⟩ := List.mem_map.mp hg'
        have hb : kvE2_pastRayBit σ χ = true := (List.mem_filter.mp hχmem).2
        obtain ⟨v, hzv, hvχ⟩ :=
          (hquantσ (Fin.cons (true, false) kvE2_sep_zPastX3) χ).mpr hb
        have h0 := hzv ⟨0, by omega⟩
        exact ⟨v, h0.1.mpr rfl,
          (nf_depth0_char_correct' M atomMap h_surj χ v).mpr hvχ, fun r _ _ => id⟩
  -- each gap profile occurs in (x1, x)
  have hocc : ∀ χ ∈ kvE2_pastGapList σ, ∃ r : M.carrier,
      r < x ∧ x1 < r ∧ nf_eval_nf M 0 1 (fun _ => r) χ := by
    intro χ hχ
    have hb : kvE2_pastGapBit σ χ = true := (List.mem_filter.mp hχ).2
    obtain ⟨v, hzv, hvχ⟩ :=
      (hquantσ (Fin.cons (false, true) kvE2_sep_zPastX3) χ).mpr hb
    have h0 := hzv ⟨0, by omega⟩
    have h2 := hzv ⟨2, by omega⟩
    exact ⟨v, h2.1.mpr rfl, h0.2.mpr rfl, hvχ⟩
  have hnd : (kvE2_pastGapList σ).Nodup :=
    List.Nodup.filter _ (Finset.nodup_toList _)
  obtain ⟨l, hlperm, hltruth⟩ :=
    kvE2_pastChainBuild M atomMap h_surj (kvE2_pastEnd atomMap h_surj σ)
      (kvE2_pastGapD atomMap h_surj σ) x x1 hD hend
      (kvE2_pastGapList σ).length (kvE2_pastGapList σ) le_rfl hnd x hx1x
      (fun r hr => hr) hocc
  refine hcl ?_
  rw [kvE2_pastPos, if_pos hadm, formula_disjList_iff]
  exact ⟨_, List.mem_map.mpr ⟨l, List.mem_permutations.mpr hlperm, rfl⟩, hltruth⟩

/-! ## Phase 6: Completeness of the clause family

The ⇐ half at family generality, time-reversed from `kvE2_extNegFut_complete`
(`ExteriorNegation.lean`, Phase 4): if NO exterior `x1 < x` realizes σ, the complement
clause holds at `x`. Contrapositive: a true positive form at `x` reconstructs a full
exterior realizer — the 9-zone reconstruction generalized over the finite alphabet via
the Phase-5 support kit.

Hypotheses are EXACTLY the Phase-4 obligations modulo side (Phase-5 handoff): the
gate-level pins `(hxw, hwt, henv, habove)` PLUS the two syntactic σ-side hypotheses

* `hbase : nf0_dropFresh σ.1 = qnf.1` (base-restriction match);
* `hbits` : σ's six at-or-above-`x` bits agree with `kvE2_futAnyBit qnf` (the above-bit
  comparison — `kvE2_futAnyBit` is qnf-side and SIDE-NEUTRAL in its zone-3 argument, so
  the SAME bits serve both sides; only the six-constant disjunction guard swaps to the
  above-`x` set `{zAtX3 … zFutT3}`, key `(zs ⟨1⟩).1 = false`).

No `zPastX3`-marking hypothesis is needed: Phase 5's if-gate hands admissibility for
free (a true positive form certifies `kvE2_pastAdmissible σ`, since the else-branch is
`⊥`), and admissibility CONTAINS the zone marking. -/

/-- An at-or-above-`x` zone-3 witness sits above any `x1 < x`: read `¬(v < x)` off the
    zone-3 spec's second pair (mirror of `kvE2_futBelow_le_t`; the above-`x` key is
    `(zs ⟨1⟩).1 = false`). -/
private theorem kvE2_pastAbove_ge_x {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (w x t : M.carrier)
    (zs : ZoneSpec 3) (hz1 : (zs ⟨1, by omega⟩).1 = false) (v : M.carrier)
    (hzone : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v) :
    x ≤ v := by
  have h := (hzone ⟨1, by omega⟩).1
  rw [hz1] at h
  by_contra hc
  exact absurd (h.mp (not_le.mp hc)) Bool.false_ne_true

/-- Lift an at-or-above-`x` zone-3 fact to the corresponding zone-4 fact (coupling
    `(false, true)` to a fresh `x1 < x`), and back (mirror of
    `kvE2_futZone4_below_iff`). -/
private theorem kvE2_pastZone4_above_iff {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
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
      have hlt := hx1x.trans_le (kvE2_pastAbove_ge_x M w x t zs hz1 v h)
      exact ⟨iff_of_false (lt_asymm hlt) Bool.false_ne_true, iff_of_true hlt rfl⟩
    | ⟨1, _⟩ => exact h ⟨0, by omega⟩
    | ⟨2, _⟩ => exact h ⟨1, by omega⟩
    | ⟨3, _⟩ => exact h ⟨2, by omega⟩

/-- **σ's atom layer holds at a reconstructed endpoint** (mirror of
    `kvE2_futSigma_atom`): under the zone marking `nf0_zoneSpec σ.1 = kvE2_sep_zPastX3`
    (from admissibility), the base-restriction match `nf0_dropFresh σ.1 = qnf.1`, the
    anchor-base pin `henv`, and σ's fresh profile at `x1 < x`, every `AtomKind sig 4`
    atom of `σ.1` is honest over `[x1, w, x, t]`. -/
private theorem kvE2_pastSigma_atom {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (x1 w x t : M.carrier) (hxw : x < w) (hwt : w < t) (hx1x : x1 < x)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (hzs : nf0_zoneSpec σ.1 = kvE2_sep_zPastX3)
    (hbase : nf0_dropFresh σ.1 = qnf.1)
    (hx1fr : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1)) :
    ∀ a : AtomKind sig 4,
      atom_eval M (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) a ↔
        σ.1 a = true := by
  intro a
  match a with
  | .pred p ⟨0, _⟩ =>
    show M.interp p x1 ↔ σ.1 (.pred p 0) = true
    have h := hx1fr (.pred p 0)
    simpa only [atom_eval, nf0_projFresh] using h
  | .pred p ⟨i + 1, hi⟩ =>
    have hb : σ.1 (.pred p ⟨i + 1, hi⟩) = qnf.1 (.pred p ⟨i, by omega⟩) := by
      rw [← hbase]
      simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
      rfl
    show M.interp p ((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨i, by omega⟩)
      ↔ σ.1 (.pred p ⟨i + 1, hi⟩) = true
    rw [hb]
    have h := henv (.pred p ⟨i, by omega⟩)
    simpa only [atom_eval] using h
  | .order ⟨0, _⟩ ⟨0, _⟩ h => exact absurd rfl h
  | .order ⟨0, _⟩ ⟨j + 1, hj⟩ h =>
    have e1 : σ.1 (.order ⟨0, by omega⟩ ⟨j + 1, hj⟩ h) =
        (kvE2_sep_zPastX3 ⟨j, by omega⟩).1 :=
      congrArg Prod.fst (congrFun hzs ⟨j, by omega⟩)
    show (x1 < (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨j, by omega⟩)
      ↔ σ.1 (.order ⟨0, by omega⟩ ⟨j + 1, hj⟩ h) = true
    rw [e1]
    refine iff_of_true ?_ (by
      show (kvE2_sep_zPastX3 ⟨j, by omega⟩).1 = true
      match j, hj with
      | 0, _ => rfl
      | 1, _ => rfl
      | 2, _ => rfl)
    match j, hj with
    | 0, _ => exact hx1x.trans hxw
    | 1, _ => exact hx1x
    | 2, _ => exact hx1x.trans (hxw.trans hwt)
  | .order ⟨i + 1, hi⟩ ⟨0, _⟩ h =>
    have e2 : σ.1 (.order ⟨i + 1, hi⟩ ⟨0, by omega⟩ h) =
        (kvE2_sep_zPastX3 ⟨i, by omega⟩).2 :=
      congrArg Prod.snd (congrFun hzs ⟨i, by omega⟩)
    show ((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨i, by omega⟩ < x1)
      ↔ σ.1 (.order ⟨i + 1, hi⟩ ⟨0, by omega⟩ h) = true
    rw [e2]
    refine iff_of_false ?_ (by
      show ¬ ((kvE2_sep_zPastX3 ⟨i, by omega⟩).2 = true)
      match i, hi with
      | 0, _ => exact Bool.false_ne_true
      | 1, _ => exact Bool.false_ne_true
      | 2, _ => exact Bool.false_ne_true)
    match i, hi with
    | 0, _ => exact lt_asymm (hx1x.trans hxw)
    | 1, _ => exact lt_asymm hx1x
    | 2, _ => exact lt_asymm (hx1x.trans (hxw.trans hwt))
  | .order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h =>
    have hij : i ≠ j := by
      simp only [ne_eq, Fin.mk.injEq] at h; omega
    have hne : (⟨i, by omega⟩ : Fin 3) ≠ ⟨j, by omega⟩ := by
      simp only [ne_eq, Fin.mk.injEq]; exact hij
    have hb : σ.1 (.order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h) =
        qnf.1 (.order ⟨i, by omega⟩ ⟨j, by omega⟩ hne) := by
      rw [← hbase]
      simp only [nf0_dropFresh, mergeNF, skipFin_zero_succ]
      rfl
    show ((Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨i, by omega⟩ <
        (Fin.cons w (Fin.cons x (fun _ => t)) : Fin 3 → M.carrier) ⟨j, by omega⟩)
      ↔ σ.1 (.order ⟨i + 1, hi⟩ ⟨j + 1, hj⟩ h) = true
    rw [hb]
    have hh := henv (.order ⟨i, by omega⟩ ⟨j, by omega⟩ hne)
    simpa only [atom_eval] using hh

/-- **Chain destruction** (converse of `kvE2_pastChainBuild`, mirror of
    `kvE2_futChainDestruct`): a true `D`-guarded `Since` chain at `s` yields an
    endpoint `x1 < s` satisfying `endF`, a `D`-uniform gap `(x1, s)` (given that each
    visited profile's characteristic pointwise implies `D`), and one occurrence in
    `(x1, s)` for every profile in the chain's list. -/
private theorem kvE2_pastChainDestruct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (endF D : Formula) :
    ∀ (l : List (NormalForm sig 0 1)) (s : M.carrier),
      (∀ χ ∈ l, ∀ r : M.carrier,
        temporal_truth M atomMap r (nf_depth0_char_formula atomMap h_surj χ) →
        temporal_truth M atomMap r D) →
      temporal_truth M atomMap s (kvE2_pastChain atomMap h_surj endF D l) →
      ∃ x1 : M.carrier, x1 < s ∧ temporal_truth M atomMap x1 endF ∧
        (∀ r : M.carrier, x1 < r → r < s → temporal_truth M atomMap r D) ∧
        (∀ χ ∈ l, ∃ r : M.carrier, x1 < r ∧ r < s ∧
          temporal_truth M atomMap r (nf_depth0_char_formula atomMap h_surj χ)) := by
  intro l
  induction l with
  | nil =>
    intro s _ hch
    simp only [kvE2_pastChain] at hch
    obtain ⟨x1, hx1s, hend, hgap⟩ := hch
    exact ⟨x1, hx1s, hend, hgap, by simp⟩
  | cons χ rest ih =>
    intro s himp hch
    simp only [kvE2_pastChain] at hch
    obtain ⟨r₀, hr₀s, hconj, hgap1⟩ := hch
    rw [formula_conjList_iff] at hconj
    have hχr₀ : temporal_truth M atomMap r₀ (nf_depth0_char_formula atomMap h_surj χ) :=
      hconj _ (by simp)
    have hrest : temporal_truth M atomMap r₀ (kvE2_pastChain atomMap h_surj endF D rest) :=
      hconj _ (by simp)
    obtain ⟨x1, hx1r₀, hend, hgap2, hocc⟩ :=
      ih r₀ (fun χ' hχ' => himp χ' (List.mem_cons_of_mem χ hχ')) hrest
    refine ⟨x1, hx1r₀.trans hr₀s, hend, ?_, ?_⟩
    · intro r hx1r hrs
      rcases lt_trichotomy r r₀ with hlt | heq | hgt
      · exact hgap2 r hx1r hlt
      · exact heq ▸ himp χ List.mem_cons_self r₀ hχr₀
      · exact hgap1 r hgt hrs
    · intro χ' hχ'
      rcases List.mem_cons.mp hχ' with rfl | hmem
      · exact ⟨r₀, hx1r₀, hr₀s, hχr₀⟩
      · obtain ⟨r, hx1r, hrr₀, hprof⟩ := hocc χ' hmem
        exact ⟨r, hx1r, hrr₀.trans hr₀s, hprof⟩

/-- **Family completeness** (Cor 5.4(2) exterior analog, ⇐ — the Phase-2 BINDING
    signature at family generality, side Past): if no exterior `x1 < x` realizes σ, the
    complement clause holds at `x`. Conditional on the gate-level pins `henv`/`habove`
    plus the two syntactic σ-side hypotheses `hbase`/`hbits` (the recorded Phase-4
    obligations, six-constant guard swapped to the above-`x` set). Admissibility is NOT
    hypothesized — a true positive form certifies it (the else-branch is `⊥`). -/
theorem kvE2_extNegPast_complete {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    (qnf : NormalForm sig 2 3) (σ : NormalForm sig 1 4)
    (w x t : M.carrier) (hxw : x < w) (hwt : w < t)
    (henv : ∀ a : AtomKind sig 3,
      atom_eval M (Fin.cons w (Fin.cons x (fun _ => t))) a ↔ qnf.1 a = true)
    (habove : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1), (zs ⟨1, by omega⟩).1 = false →
      ((∃ v : M.carrier,
          zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs v ∧
          nf_eval_nf M 0 1 (fun _ => v) χ) ↔ kvE2_futAnyBit qnf zs χ = true))
    (hbase : nf0_dropFresh σ.1 = qnf.1)
    (hbits : ∀ (zs : ZoneSpec 3) (χ : NormalForm sig 0 1),
      (zs = kvE2_sep_zAtX3 ∨ zs = kvE2_sep_zXW3 ∨ zs = kvE2_sep_zAtW3 ∨
        zs = kvE2_sep_zWT3 ∨ zs = kvE2_sep_zAtT3 ∨ zs = kvE2_sep_zFutT3) →
      σ.2 (nf0_assemble (Fin.cons (false, true) zs) χ σ.1) = kvE2_futAnyBit qnf zs χ)
    (hnorel : ∀ x1 : M.carrier, x1 < x →
      ¬ nf_eval_nf M 1 4 (Fin.cons x1 (Fin.cons w (Fin.cons x (fun _ => t)))) σ) :
    temporal_truth M atomMap x (kvE2_extNegPast atomMap h_surj σ) := by
  intro hPos
  by_cases hadm : kvE2_pastAdmissible σ = true
  case neg =>
    rw [kvE2_pastPos, if_neg hadm] at hPos
    exact hPos
  case pos =>
  -- unpack admissibility into its four syntactic components
  have hadm' := hadm
  rw [kvE2_pastAdmissible] at hadm'
  simp only [Bool.and_eq_true] at hadm'
  obtain ⟨⟨⟨hadm1, hadm2⟩, hadm3⟩, hadm4⟩ := hadm'
  have hzs : nf0_zoneSpec σ.1 = kvE2_sep_zPastX3 := of_decide_eq_true hadm1
  have hoff : ∀ τ : NormalForm sig 0 5, nf0_dropFresh τ ≠ σ.1 → σ.2 τ = false := by
    intro τ hτ
    rw [List.all_eq_true] at hadm2
    have h2 := hadm2 τ (Finset.mem_toList.mpr (Finset.mem_univ τ))
    rw [Bool.or_eq_true] at h2
    rcases h2 with h2 | h2
    · have h2' : nf0_dropFresh τ = show NormalForm sig 0 4 from σ.1 := of_decide_eq_true h2
      exact absurd h2' hτ
    · simpa using h2
  have himposs : ∀ zs : ZoneSpec 4, zs ∉ kvE2_pastPossibleZones →
      ∀ χ : NormalForm sig 0 1, σ.2 (nf0_assemble zs χ σ.1) = false := by
    intro zs hzp χ
    rw [List.all_eq_true] at hadm3
    have h2 := hadm3 zs (Finset.mem_toList.mpr (Finset.mem_univ zs))
    rw [Bool.or_eq_true] at h2
    rcases h2 with h2 | h2
    · exfalso
      obtain ⟨z, hzmem, hdec⟩ := List.any_eq_true.mp h2
      exact hzp ((of_decide_eq_true hdec) ▸ hzmem)
    · rw [List.all_eq_true] at h2
      have h3 := h2 χ (Finset.mem_toList.mpr (Finset.mem_univ χ))
      simpa using h3
  have hself : ∀ χ : NormalForm sig 0 1,
      kvE2_pastSelfBit σ χ = decide (χ = nf0_projFresh σ.1) := by
    intro χ
    rw [List.all_eq_true] at hadm4
    exact of_decide_eq_true (hadm4 χ (Finset.mem_toList.mpr (Finset.mem_univ χ)))
  -- destructure the true positive form: some permutation chain is true at x
  rw [kvE2_pastPos, if_pos hadm, formula_disjList_iff] at hPos
  obtain ⟨f, hfmem, hftruth⟩ := hPos
  obtain ⟨l, hlmem, rfl⟩ := List.mem_map.mp hfmem
  have hlperm : l.Perm (kvE2_pastGapList σ) := List.mem_permutations.mp hlmem
  -- a visited gap profile's characteristic implies the gap guard D
  have himpD : ∀ χ ∈ l, ∀ r : M.carrier,
      temporal_truth M atomMap r (nf_depth0_char_formula atomMap h_surj χ) →
      temporal_truth M atomMap r (kvE2_pastGapD atomMap h_surj σ) := by
    intro χ hχ r hr
    rw [kvE2_pastGapD, formula_disjList_iff]
    exact ⟨_, List.mem_map.mpr ⟨χ, hlperm.mem_iff.mp hχ, rfl⟩, hr⟩
  obtain ⟨x1, hx1x, hend, hgapD, hoccl⟩ :=
    kvE2_pastChainDestruct M atomMap h_surj (kvE2_pastEnd atomMap h_surj σ)
      (kvE2_pastGapD atomMap h_surj σ) l x himpD hftruth
  -- endpoint description: fresh profile + exact ray content
  rw [kvE2_pastEnd, formula_conjList_iff] at hend
  have hchfr : temporal_truth M atomMap x1
      (nf_depth0_char_formula atomMap h_surj (nf0_projFresh σ.1)) := hend _ (by simp)
  have hrayform : temporal_truth M atomMap x1 (kvE2_pastRayForm atomMap h_surj σ) :=
    hend _ (by simp)
  have hx1fr : nf_eval_nf M 0 1 (fun _ => x1) (nf0_projFresh σ.1) :=
    (nf_depth0_char_correct' M atomMap h_surj _ x1).mp hchfr
  rw [kvE2_pastRayForm, formula_conjList_iff] at hrayform
  have hnoray : temporal_truth M atomMap x1
      (Formula.snce (kvE2_pastRayD atomMap h_surj σ).neg Formula.top).neg :=
    hrayform _ (by simp)
  have hray : ∀ u : M.carrier, u < x1 →
      temporal_truth M atomMap u (kvE2_pastRayD atomMap h_surj σ) := by
    intro u hu
    by_contra hc
    exact hnoray ⟨u, hu, hc, fun r _ _ => id⟩
  have hrayocc : ∀ χ ∈ kvE2_pastRayList σ, ∃ u : M.carrier, u < x1 ∧
      nf_eval_nf M 0 1 (fun _ => u) χ := by
    intro χ hχ
    have h := hrayform _ (List.mem_cons_of_mem _ (List.mem_map.mpr ⟨χ, hχ, rfl⟩))
    obtain ⟨u, hu, hchu, -⟩ := h
    exact ⟨u, hu, (nf_depth0_char_correct' M atomMap h_surj χ u).mp hchu⟩
  -- gap points carry gap profiles
  have hgapprof : ∀ r : M.carrier, x1 < r → r < x →
      ∃ χ, kvE2_pastGapBit σ χ = true ∧ nf_eval_nf M 0 1 (fun _ => r) χ := by
    intro r hx1r hrx
    have h := hgapD r hx1r hrx
    rw [kvE2_pastGapD, formula_disjList_iff] at h
    obtain ⟨g, hg, hgt2⟩ := h
    obtain ⟨χ, hχmem, rfl⟩ := List.mem_map.mp hg
    exact ⟨χ, (List.mem_filter.mp hχmem).2,
      (nf_depth0_char_correct' M atomMap h_surj χ r).mp hgt2⟩
  -- each gap profile occurs in (x1, x)
  have hgapocc : ∀ χ : NormalForm sig 0 1, kvE2_pastGapBit σ χ = true →
      ∃ r : M.carrier, x1 < r ∧ r < x ∧ nf_eval_nf M 0 1 (fun _ => r) χ := by
    intro χ hb
    have hχl : χ ∈ l := hlperm.mem_iff.mpr
      (List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ χ), hb⟩)
    obtain ⟨r, hx1r, hrx, hchr⟩ := hoccl χ hχl
    exact ⟨r, hx1r, hrx, (nf_depth0_char_correct' M atomMap h_surj χ r).mp hchr⟩
  -- x1 realizes σ, contradicting hnorel
  apply hnorel x1 hx1x
  refine (nf_eval_depth1_fold_iff M _ σ).mpr ⟨?_, ?_, ?_⟩
  · exact kvE2_pastSigma_atom M qnf σ x1 w x t hxw hwt hx1x henv hzs hbase hx1fr
  · intro zs χ
    constructor
    · rintro ⟨v, hzv, hvχ⟩
      rcases lt_trichotomy v x1 with hlt | heq | hgt
      · -- ray (−∞, x1) : profile forced into the ray alphabet by the exact-ray-content
        have hzeq : zs = Fin.cons (true, false) kvE2_sep_zPastX3 :=
          kvE2_pastCharZone4 M v x1 w x t zs hzv (true, false) (true, false) (true, false)
            (true, false)
            (iff_of_true hlt rfl) (iff_of_false (lt_asymm hlt) Bool.false_ne_true)
            (iff_of_true ((hlt.trans hx1x).trans hxw) rfl)
            (iff_of_false (lt_asymm ((hlt.trans hx1x).trans hxw)) Bool.false_ne_true)
            (iff_of_true (hlt.trans hx1x) rfl)
            (iff_of_false (lt_asymm (hlt.trans hx1x)) Bool.false_ne_true)
            (iff_of_true ((hlt.trans hx1x).trans (hxw.trans hwt)) rfl)
            (iff_of_false (lt_asymm ((hlt.trans hx1x).trans (hxw.trans hwt)))
              Bool.false_ne_true)
        rw [hzeq]
        show kvE2_pastRayBit σ χ = true
        have hrD := hray v hlt
        rw [kvE2_pastRayD, formula_disjList_iff] at hrD
        obtain ⟨g, hg, hgt2⟩ := hrD
        obtain ⟨χ', hχ'mem, rfl⟩ := List.mem_map.mp hg
        have hχeq : χ = χ' := nf_profile_unique M v χ χ' hvχ
          ((nf_depth0_char_correct' M atomMap h_surj χ' v).mp hgt2)
        rw [hχeq]
        exact (List.mem_filter.mp hχ'mem).2
      · -- v = x1 : the fresh point, profile = σ's fresh profile
        have hzeq : zs = Fin.cons (false, false) kvE2_sep_zPastX3 :=
          kvE2_pastCharZone4 M v x1 w x t zs hzv (false, false) (true, false) (true, false)
            (true, false)
            (iff_of_false (heq ▸ lt_irrefl x1) Bool.false_ne_true)
            (iff_of_false (heq ▸ lt_irrefl x1) Bool.false_ne_true)
            (iff_of_true (heq ▸ hx1x.trans hxw) rfl)
            (iff_of_false (heq ▸ lt_asymm (hx1x.trans hxw)) Bool.false_ne_true)
            (iff_of_true (heq ▸ hx1x) rfl)
            (iff_of_false (heq ▸ lt_asymm hx1x) Bool.false_ne_true)
            (iff_of_true (heq ▸ hx1x.trans (hxw.trans hwt)) rfl)
            (iff_of_false (heq ▸ lt_asymm (hx1x.trans (hxw.trans hwt))) Bool.false_ne_true)
        rw [hzeq]
        show kvE2_pastSelfBit σ χ = true
        rw [hself χ]
        exact decide_eq_true (nf_profile_unique M v χ _ hvχ (heq ▸ hx1fr))
      · -- x1 < v : above-x six zones or the gap (x1, x)
        rcases le_or_gt x v with hxv | hvx
        · -- at-or-above x : reduce to the qnf-pinned zone fact via hbits + habove
          have hz3 : zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) (Fin.tail zs) v :=
            fun i => hzv i.succ
          have h0 := hzv 0
          have hzeq0 : zs 0 = (false, true) :=
            Prod.ext (by
              cases hb : (zs 0).1 with
              | false => rfl
              | true => exact absurd (h0.1.mpr hb) (lt_asymm hgt))
              (h0.2.mp hgt)
          have hcls := kvE2_pastAboveClass M v w x t hxw hwt hxv (Fin.tail zs) hz3
          rw [← Fin.cons_self_tail zs, hzeq0]
          rcases hcls with h | h | h | h | h | h
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inl rfl)]
            exact (habove _ χ rfl).mp ⟨v, hz3, hvχ⟩
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inr (Or.inl rfl))]
            exact (habove _ χ rfl).mp ⟨v, hz3, hvχ⟩
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inr (Or.inr (Or.inl rfl)))]
            exact (habove _ χ rfl).mp ⟨v, hz3, hvχ⟩
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inl rfl))))]
            exact (habove _ χ rfl).mp ⟨v, hz3, hvχ⟩
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl rfl)))))]
            exact (habove _ χ rfl).mp ⟨v, hz3, hvχ⟩
          · rw [h] at hz3 ⊢
            rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr rfl)))))]
            exact (habove _ χ rfl).mp ⟨v, hz3, hvχ⟩
        · -- gap (x1, x) : profile forced into the gap alphabet by the D-uniform gap
          have hzeq : zs = Fin.cons (false, true) kvE2_sep_zPastX3 :=
            kvE2_pastCharZone4 M v x1 w x t zs hzv (false, true) (true, false) (true, false)
              (true, false)
              (iff_of_false (lt_asymm hgt) Bool.false_ne_true) (iff_of_true hgt rfl)
              (iff_of_true (hvx.trans hxw) rfl)
              (iff_of_false (lt_asymm (hvx.trans hxw)) Bool.false_ne_true)
              (iff_of_true hvx rfl) (iff_of_false (lt_asymm hvx) Bool.false_ne_true)
              (iff_of_true (hvx.trans (hxw.trans hwt)) rfl)
              (iff_of_false (lt_asymm (hvx.trans (hxw.trans hwt))) Bool.false_ne_true)
          rw [hzeq]
          obtain ⟨χ', hb', hχ'v⟩ := hgapprof v hgt hvx
          have hχeq : χ = χ' := nf_profile_unique M v χ χ' hvχ hχ'v
          show kvE2_pastGapBit σ χ = true
          rw [hχeq]
          exact hb'
    · intro hbitv
      by_cases hzp : zs ∈ kvE2_pastPossibleZones
      · rcases kvE2_pastPossibleZones_cases hzp with
          rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl | rfl
        · rw [hbits _ χ (Or.inl rfl)] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (habove kvE2_sep_zAtX3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_pastZone4_above_iff M x1 w x t hx1x _ rfl v).mpr hv3, hvχ⟩
        · rw [hbits _ χ (Or.inr (Or.inl rfl))] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (habove kvE2_sep_zXW3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_pastZone4_above_iff M x1 w x t hx1x _ rfl v).mpr hv3, hvχ⟩
        · rw [hbits _ χ (Or.inr (Or.inr (Or.inl rfl)))] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (habove kvE2_sep_zAtW3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_pastZone4_above_iff M x1 w x t hx1x _ rfl v).mpr hv3, hvχ⟩
        · rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inl rfl))))] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (habove kvE2_sep_zWT3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_pastZone4_above_iff M x1 w x t hx1x _ rfl v).mpr hv3, hvχ⟩
        · rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inr (Or.inl rfl)))))] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (habove kvE2_sep_zAtT3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_pastZone4_above_iff M x1 w x t hx1x _ rfl v).mpr hv3, hvχ⟩
        · rw [hbits _ χ (Or.inr (Or.inr (Or.inr (Or.inr (Or.inr rfl)))))] at hbitv
          obtain ⟨v, hv3, hvχ⟩ := (habove kvE2_sep_zFutT3 χ rfl).mpr hbitv
          exact ⟨v, (kvE2_pastZone4_above_iff M x1 w x t hx1x _ rfl v).mpr hv3, hvχ⟩
        · -- gap
          obtain ⟨r, hx1r, hrx, hrχ⟩ := hgapocc χ hbitv
          exact ⟨r, kvE2_pastZone4_of_below M r x1 w x t hxw hwt hrx (false, true)
              (iff_of_false (lt_asymm hx1r) Bool.false_ne_true)
              (iff_of_true hx1r rfl), hrχ⟩
        · -- self
          have hb : kvE2_pastSelfBit σ χ = true := hbitv
          rw [hself χ] at hb
          have hχf : χ = nf0_projFresh σ.1 := of_decide_eq_true hb
          subst hχf
          exact ⟨x1, kvE2_pastZone4_of_below M x1 x1 w x t hxw hwt hx1x (false, false)
              (iff_of_false (lt_irrefl x1) Bool.false_ne_true)
              (iff_of_false (lt_irrefl x1) Bool.false_ne_true), hx1fr⟩
        · -- ray
          have hb : kvE2_pastRayBit σ χ = true := hbitv
          obtain ⟨u, hux1, huχ⟩ := hrayocc χ
            (List.mem_filter.mpr ⟨Finset.mem_toList.mpr (Finset.mem_univ χ), hb⟩)
          exact ⟨u, kvE2_pastZone4_of_below M u x1 w x t hxw hwt (hux1.trans hx1x)
              (true, false)
              (iff_of_true hux1 rfl) (iff_of_false (lt_asymm hux1) Bool.false_ne_true), huχ⟩
      · rw [himposs zs hzp χ] at hbitv
        exact absurd hbitv Bool.false_ne_true
  · exact hoff

end Bimodal.Metalogic.WeakCanonical.Kamp
