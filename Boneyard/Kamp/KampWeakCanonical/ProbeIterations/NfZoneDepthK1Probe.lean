import FormalSystem.Metalogic.WeakCanonical.Kamp.NfZoneDepthK

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Phase 11b D1 — flattening go/no-go probe at depth `k = 1` (report 40 §3.2)

This module is the **decisive go/no-go gate** for the corrected Phase-11b target proposed in
`reports/40_phase11b-divergence-audit.md §3.2`: the *flattening pilot* `nf_zone_mid_flatten_k1`.
It is **off the live import path** (nothing in the `completeness_discrete` chain imports it) and is
**fully sorry-free**.

## The make-or-break claim under test

Report 40 §3.2 reframes the zone converter around Rabinovich's actual mechanism: *keep the two
anchors `x, t`, and absorb the coupled quant witness `w` as a **second bracket witness on the fixed
`(x, t)` interval** with a single-point (depth-0 atomic) type.* The proposed decisive experiment is
the mid-zone (`x < y < t`) existential at `k = 1`, whose RHS the report specifies as "a concrete
`BracketFormula.holds M atomMap x t bf_i` disjunction over `w`'s 7 zones … on the `(x, t)`
interval." The single unverified premise (report 40 §4, confidence *Low*) is that this absorption
**succeeds**; if it fails "for the same non-injectivity that killed projection," the verdict is
**NO-GO → STOP + `/spawn` the Uniform-Prop-4.3 route (plan v39:181)."

## Verdict landed here: NO-GO (sorry-free refutation)

The absorption is **refuted**. At `k = 1` the innermost sub-form `sub : NormalForm sig 0 4` is a
pure atom assignment over the arity-4 env `[w, y, x, t]` (positions `0 = w`, `1 = y`, `2 = x`,
`3 = t`). Its coupled realizability layer (`nf_characteristic_quant_succ`,
`nf_characteristic_quant_split3`) ranges `w` over **all** of `M.carrier`, and `sub` fixes **every**
pairwise order atom — in particular the order atom `(0, 2)` = `w < x`. So `sub` may *demand* an
**exterior** witness (`w < x`, or dually `t < w`). The mid-zone LHS's quant biconditional
(`∀ sub, (∃ w, …) ↔ qnf.quant_assgn sub`) therefore constrains realizability in the exterior zones
`w < x` and `t < w`.

But a `BracketFormula.holds M atomMap x t bf` on the fixed `(x, t)` interval provides witnesses that
are **strictly interior** (`IntervalPattern.holds`, `ExistsForallNF.lean:106-132`: every witness
lies in `(x, t)`), and — when the point/segment types are the mandated depth-0 **atomic**
`TemporalPred`s — every `eval_at` is a purely local valuation (`temporal_truth` on `.atom`/`.box`
is `M.interp … pt`, no `Until`/`Since` navigation, `Table.lean:186,189`). Such a bracket is
**confined to the closed interval `[x, t]`** and cannot testify to, nor rule out, any exterior-`w`
realizability. Hence no atomic `(x, t)`-bracket disjunction can be equivalent to the mid-zone LHS:
the "absorb `w` as a second bracket witness on `(x, t)`" step is a **non-theorem for exterior `w`**.

The two sorry-free theorems below mechanize the two pillars of this refutation:

* `nf0_4_exterior_witness_is_exterior` — a `w` realizing an *exterior-demanding* `sub` (one whose
  `w < x` order atom is set) provably satisfies `w < x`, hence `¬ (x < w ∧ w < t)`: the realizer is
  **not** in `(x, t)`.
* `intervalPattern_witnesses_interior` — every witness of a holding `IntervalPattern` on `(x, t)`
  lies strictly in `(x, t)`.
* `interior_bracket_cannot_realize_exterior_sub_k1` — the packaged obstruction: an interior
  `(x, t)`-bracket witness can never *be* the realizer of an exterior-demanding `sub`.

Together they show the mandated flat-`(x, t)` absorption drops exactly the exterior-`w` content the
mid-zone LHS pins down — a genuine non-theorem discovery, not a recession.

## Consequence / next action

Per report 40 §3.2 and the D1 go/no-go contract: **NO-GO**. Do not build the flat single-interval
bracket bridge (it cannot capture exterior-`w` realizability with atomic types). **STOP and
`/spawn` the Uniform-Prop-4.3 negation-closure route (plan v39:181; `Prop43.lean`,
`EAVecNegationClosure.lean` already exist).** The faithful Rabinovich construction requires
past-of-`x` / future-of-`t` **temporal navigation** at the endpoints (nested `Until`/`Since`, Cor
5.4 `F_i` chain) — which is exactly the machinery the flat-flattening reframing sought to avoid, and
which is *not* a flat `BracketFormula.holds … x t` disjunction.

## References
- `reports/40_phase11b-divergence-audit.md` §3.2 (D1 target), §4 (low-confidence flag on absorption)
- `NfZoneDepthK.lean:487-518` (`nf_characteristic_quant_split3`, `nf_char3_eq_succ_iff` — the 7-zone
  inner `w`-split this probe tests)
- `ExistsForallNF.lean:106-132` (`IntervalPattern.holds`: witnesses strictly interior)
- `Table.lean:186,189` (`temporal_truth` on `.atom`/`.box`: local, no navigation)
- `NormalForm.lean:113-117,201-207` (`atom_eval`, `nf_eval_nf` depth-0)
-/

#exit

namespace FormalSystem.Metalogic.WeakCanonical.Kamp

open FormalSystem.Syntax
open FormalSystem.Metalogic.WeakCanonical

/-! ## Pillar 1: an exterior-demanding sub forces an exterior realizer

The arity-4 env `Fin.cons w (zoneEnv3 y x t)` places `w` at position `0`, `y` at `1`, `x` at `2`,
`t` at `3`. The order atom `(0, 2)` evaluates to `w < x`. So a depth-0 `sub` that sets this atom to
`true` can only be realized by a `w` with `w < x` — an exterior witness relative to `(x, t)`. -/

/-- The `w < x` order-atom fact extracted from a depth-0 realization at the arity-4 env
    `[w, y, x, t]`: for any depth-0 `sub`, `w < x` iff `sub` sets the `(0, 2)` order atom. -/
theorem nf0_4_order_w_lt_x {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (w y x t : M.carrier)
    (sub : NormalForm sig 0 4)
    (h : nf_eval_nf M 0 4 (Fin.cons w (zoneEnv3 y x t)) sub) :
    (w < x) ↔ (sub (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true) := by
  have hatom : atom_eval M (Fin.cons w (zoneEnv3 y x t))
      (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) ↔
      (sub (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true) := h _
  simpa [atom_eval, zoneEnv3, Fin.cons] using hatom

/-- **Exterior realizer is exterior.** If `sub` demands `w < x` (its `(0, 2)` order atom is set) and
    `w` realizes `sub` at `[w, y, x, t]`, then `w < x`; in particular `w` is **not** in the open
    interval `(x, t)`. This is the depth-0 core of the NO-GO: the coupled quant witness for an
    exterior-demanding type cannot lie interior to the anchors. -/
theorem nf0_4_exterior_witness_is_exterior {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (w y x t : M.carrier)
    (sub : NormalForm sig 0 4)
    (hsub : sub (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true)
    (h : nf_eval_nf M 0 4 (Fin.cons w (zoneEnv3 y x t)) sub) :
    w < x ∧ ¬ (x < w ∧ w < t) := by
  have hwx : w < x := (nf0_4_order_w_lt_x M w y x t sub h).mpr hsub
  refine ⟨hwx, ?_⟩
  rintro ⟨hxw, _⟩
  exact absurd (lt_trans hxw hwx) (lt_irrefl x)

/-! ## Pillar 2: bracket witnesses on `(x, t)` are strictly interior

`IntervalPattern.holds` (hence `BracketFormula.holds`) on `(x, t)` with `n + 1` witnesses places
**every** witness strictly inside `(x, t)`. So no bracket witness can equal an exterior realizer. -/

/-- Every witness of a holding interval pattern on `(x, t)` (with `n + 1` witnesses) lies strictly
    in the open interval `(x, t)`. Direct read-off of the `hrange` conjunct of
    `IntervalPattern.holds_succ`. -/
theorem intervalPattern_witnesses_interior {sig : MonadicSignature} {n : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (pat : IntervalPattern (n + 1)) (x t : M.carrier)
    (h : pat.holds M atomMap x t) :
    ∃ witnesses : Fin (n + 1) → M.carrier,
      (∀ i : Fin (n + 1), x < witnesses i ∧ witnesses i < t) ∧
      (∀ i : Fin (n + 1), (pat.alpha i).eval_at M atomMap (witnesses i)) := by
  rw [IntervalPattern.holds_succ] at h
  obtain ⟨w, _, hrange, hpt, _⟩ := h
  exact ⟨w, hrange, hpt⟩

/-! ## The packaged obstruction (NO-GO core)

Combining the two pillars: an interior `(x, t)`-bracket witness can never *be* the realizer of an
exterior-demanding `sub`. Concretely, no `w` can simultaneously (i) realize an exterior-demanding
`sub` and (ii) be interior to `(x, t)`. Since the mid-zone LHS's quant biconditional forces such
exterior realizers whenever `qnf.quant_assgn` sets an exterior-demanding `sub`, and a flat
`(x, t)`-bracket supplies only interior witnesses, the flat absorption is a non-theorem. -/

/-- **NO-GO obstruction, depth 1.** There is no interior witness `w ∈ (x, t)` that realizes an
    exterior-demanding depth-0 `sub`. Equivalently: the "absorb `w` as a second bracket witness on
    the fixed `(x, t)` interval" step of report 40 §3.2 fails for every `sub` whose `w < x` order
    atom is set — the realizer is forced exterior, but bracket witnesses are forced interior. -/
theorem interior_bracket_cannot_realize_exterior_sub_k1 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (y x t : M.carrier)
    (sub : NormalForm sig 0 4)
    (hsub : sub (.order ⟨0, by omega⟩ ⟨2, by omega⟩ (by decide)) = true) :
    ¬ ∃ w, (x < w ∧ w < t) ∧ nf_eval_nf M 0 4 (Fin.cons w (zoneEnv3 y x t)) sub := by
  rintro ⟨w, hInterior, hReal⟩
  exact (nf0_4_exterior_witness_is_exterior M w y x t sub hsub hReal).2 hInterior

end FormalSystem.Metalogic.WeakCanonical.Kamp
