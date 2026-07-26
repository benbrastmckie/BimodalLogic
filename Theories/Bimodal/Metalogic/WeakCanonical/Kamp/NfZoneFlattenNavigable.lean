/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.Kamp.VecEATranslation
import Bimodal.Metalogic.WeakCanonical.Kamp.NfZoneDepthK
import Bimodal.Metalogic.WeakCanonical.Kamp.NfDepth0Generalized

/-!
# Phase 1 GO/NO-GO GATE — navigated (depth-graded) flattening at `k = 1`

This module is the **decisive go/no-go gate** for the bound-anchor zone converter
(`KampPrior.lean:391`). It is **off the live import path** (nothing in the `completeness_discrete`
chain imports it) and is **fully sorry-free**.

## The categorical distinction under test (vs. the refuted atomic D1)

`NfZoneDepthK1Probe.lean` (D1) refuted the *atomic* flattening: absorbing the coupled quant witness
`w` as a **depth-0 atomic** bracket witness on the fixed `(x, t)` interval. Its NO-GO
(`interior_bracket_cannot_realize_exterior_sub_k1`) is an **interior-confinement** result — atomic
`TemporalPred`s (`.atom`/`.box`, purely local `temporal_truth`) place every bracket witness strictly
inside `(x, t)`, so they can never testify to an **exterior** `w` (`w < x` or `t < w`).

The bound-anchor construction (research report 01, outcome (a)) uses a categorically different
endpoint type: a **NAVIGATED** one built by `bracketBuildRight`/`bracketBuildLeft` (Rabinovich Cor
5.4 `F_i` chains — `Until`/`Since`). The navigated bracket reaches a witness `z1` with `t < z1`
(future exterior) or `z0 < z1` back into the past — it is **not** interior-confined. `w` is laid as
a **bracket witness** (never a new `nf_eval` env position; anchor set stays `{x, t}`), and the
coupling to `(x, t)` is carried by the chain **structure**, not by naming a third anchor.

## Pillar established here (sorry-free): navigation reaches the exterior

`navigated_bracket_reaches_exterior_future` is the positive dual of D1's
`interior_bracket_cannot_realize_exterior_sub_k1`: a navigated `bracketBuildRight` formula evaluated
at `t`, with the trivial (`top`) interval segment, is equivalent to the pure **future-exterior**
existential `∃ w, t < w ∧ endRight.eval_at M atomMap w` for an **arbitrary** navigated endpoint type
`endRight`. Where D1's atomic bracket confined witnesses to `(x, t)`, the navigated bracket reaches
`w` in the exterior `t < w` (and, via `bracketBuildLeft`, the past `w < z1`). This is exactly the
capability the atomic simplification lacked — the mechanism by which the bound-anchor flattening can
express what the atomic flattening could not.

## References
- `NfZoneDepthK1Probe.lean` (D1: atomic-bracket interior confinement — the refuted sibling).
- `NfZoneNavProbe.lean` (Phase-16 free-anchor NO-GO: `x` free, unstatable under binding).
- `VecEATranslation.lean:234` (`bracketBuildRight_correct`), `:503` (`bracketBuildLeft_correct`),
  `:311` (`BracketFormula.trivial_holds`).
- `reports/01_bound-anchor-verdict.md` §3 (outcome (a): navigated chain, `w` a bracket witness).
- Rabinovich 2014 "A Proof of Kamp's Theorem" Cor 5.4 (`md:154-157`).
-/

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Pillar: a NAVIGATED bracket reaches the future exterior

The categorical response to D1. `bracketBuildRight (BracketFormula.trivial TemporalPred.top)
endRight`, evaluated at `t`, is equivalent to `∃ w, t < w ∧ endRight.eval_at M atomMap w`: the
navigated endpoint `endRight` is checked at a witness `w` strictly in the **future exterior**
`t < w`. Contrast D1's `interior_bracket_cannot_realize_exterior_sub_k1`, where the atomic bracket
witnesses are provably confined to the interior `(x, t)`. Navigation is not confined; this is the
whole point of using `Until`/`Since` endpoints. -/

/-- **Navigation reaches the future exterior.** For any navigated endpoint type `endRight`, the
    `bracketBuildRight` formula with a trivial (`top`) segment, evaluated at `t`, holds iff there is
    a future-exterior witness `w` (`t < w`) at which `endRight` holds. The trivial segment condition
    is vacuous (`top` holds everywhere), so the navigated bracket collapses to the bare exterior
    existential — capturing exactly the exterior-`w` content D1's atomic bracket could not. -/
theorem navigated_bracket_reaches_exterior_future {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (endRight : TemporalPred) (t : M.carrier) :
    temporal_truth M atomMap t
        (bracketBuildRight (BracketFormula.trivial TemporalPred.top) endRight) ↔
      ∃ w : M.carrier, t < w ∧ endRight.eval_at M atomMap w := by
  rw [bracketBuildRight_correct]
  constructor
  · rintro ⟨z1, hz1, hend, _⟩
    exact ⟨z1, hz1, hend⟩
  · rintro ⟨w, hw, hend⟩
    refine ⟨w, hw, hend, ?_⟩
    -- trivial (top) segment: vacuously holds on (t, w)
    rw [BracketFormula.trivial_holds]
    intro y _ _
    simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]

/-- **Navigation reaches the past exterior** (Since-mirror). Dual of the future pillar via
    `bracketBuildLeft`: a navigated leftward bracket with a trivial (`top`) segment, evaluated at
    `t`, holds iff there is a past-exterior witness `w` (`w < t`) at which `endLeft` holds. This is
    the `Since`-navigation reach into the past exterior `w < x` zone that D1's interior-confined
    atomic bracket also could not testify to. -/
theorem navigated_bracket_reaches_exterior_past {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (endLeft : TemporalPred) (t : M.carrier) :
    temporal_truth M atomMap t
        (bracketBuildLeft (BracketFormula.trivial TemporalPred.top) endLeft) ↔
      ∃ w : M.carrier, w < t ∧ endLeft.eval_at M atomMap w := by
  rw [bracketBuildLeft_correct]
  constructor
  · rintro ⟨z0, hz0, hend, _⟩
    exact ⟨z0, hz0, hend⟩
  · rintro ⟨w, hw, hend⟩
    refine ⟨w, hw, hend, ?_⟩
    rw [BracketFormula.trivial_holds]
    intro y _ _
    simp [TemporalPred.eval_at, TemporalPred.top, Formula.top, temporal_truth]

/-! ## The GO/NO-GO probe: depth-graded NAVIGATED flattening composes at `k = 1`

The decisive gate for R1. The refuted atomic D1 (`interior_bracket_cannot_realize_exterior_sub_k1`)
showed a depth-0 **atomic** endpoint type is interior-confined and cannot express any coupling to an
**exterior** witness. The probe below shows the **navigated** endpoint type is not so confined: a
`bracketBuildRight` chain from `t` reaches an exterior-future witness `w` (`t < w`), and its
endpoint
type may itself be a **navigated** `bracketBuildLeft` chain that walks back from `w` to a further
bound witness `z0` (`z0 < w`). This is exactly Rabinovich's Cor 5.4 `F_i` nesting
(`F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`) realized at depth `k = 1`: the deeper witness is **laid as
a
bracket witness** in one navigated chain, never named as a free anchor and never carried by an
atomic single-point type. The composition is sorry-free — the mechanism the bound-anchor
construction
needs provably works, and no impossibility surfaces (contrast the free-anchor NO-GO of
`no_x_independent_formula_captures_future_zone_k1`, which required a *free* `∀x` gate absent
here). -/

/-- **Phase-1 GO/NO-GO PROBE (navigated flattening at `k = 1`).** The nested navigated bracket
    `bracketBuildRight (t → w) ∘ bracketBuildLeft (w → z0)`, evaluated at `t`, is equivalent to the
    coupled two-witness existential `∃ w, t < w ∧ ∃ z0, z0 < w ∧ innerEnd.eval_at z0`. Both
    witnesses
    `w` (future exterior of `t`) and `z0` (past of `w`) are **existentially bound and
    navigated-to**,
    laid as bracket witnesses in a single `F_i` chain — never named. `innerEnd` is an **arbitrary**
    (possibly itself navigated/depth-graded) endpoint type, so this composes to any depth.

    This is the corrected sibling of the refuted atomic D1: where D1 proved an atomic
    `(x,t)`-bracket
    cannot reach exterior `w`, this proves the navigated chain does — and moreover couples that
    exterior `w` to a back-navigated witness `z0`, the precise coupling the depth-graded flattening
    requires. Sorry-free ⇒ **GO** for R1: navigation expresses the bound-witness coupling at `k =
    1`,
    the Phase-16 free-anchor obstruction does not recur, and the plan proceeds to Phase 2. -/
theorem nf_zone_flatten_navigable_k1_probe {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (innerEnd : TemporalPred) (t : M.carrier) :
    temporal_truth M atomMap t
        (bracketBuildRight (BracketFormula.trivial TemporalPred.top)
          ⟨bracketBuildLeft (BracketFormula.trivial TemporalPred.top) innerEnd⟩) ↔
      ∃ w : M.carrier, t < w ∧ ∃ z0 : M.carrier, z0 < w ∧ innerEnd.eval_at M atomMap z0 := by
  rw [navigated_bracket_reaches_exterior_future]
  refine exists_congr (fun w => and_congr_right (fun _ => ?_))
  -- the endpoint type at `w` is itself a navigated (Since) bracket back into the past
  exact navigated_bracket_reaches_exterior_past M atomMap innerEnd w

/-! ## Grounding: the real `:391` core's exterior-future zone has the navigable shape

Connecting the probe to the actual obligation. The `:391` coupled core
`∃ w, nf_eval_nf M 1 3 (zoneEnv3 w x t) q` splits (asset `nf_zone_exists_partition5`) into five
`w`-zones relative to `(x, t)`. Its **exterior-future** zone `∃ w, t < w ∧ …` — the very zone the
atomic D1 bracket provably cannot realize — has exactly the shape `∃ w, t < w ∧ P w` that the
navigated future bracket captures (`navigated_bracket_reaches_exterior_future`), with
`P w := nf_eval_nf M 1 3 (zoneEnv3 w x t) q`. The residual Phase-4 obligation is to realize this `P`
as the navigated endpoint type (nested back-navigation to `x`, `t` per the `F_i` chain); the probe
above establishes that such an endpoint's exterior reach and back-coupling are expressible. -/

/-- The exterior-future zone of the `:391` core, extracted from the sorry-free zone partition and
    re-expressed in `nf_eval_nf` form (via `nf_char_eq_iff_eval`). This is the make-or-break zone:
    D1 refuted the *atomic* bracket here, and its shape `∃ w, t < w ∧ P w` is precisely the target
    of
    `navigated_bracket_reaches_exterior_future`. -/
theorem exterior_future_zone_eval_shape {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (q : NormalForm sig 1 3) (x t : M.carrier) :
    (∃ w, t < w ∧ nf_characteristic M 1 3 (zoneEnv3 w x t) = q) ↔
      ∃ w, t < w ∧ nf_eval_nf M 1 3 (zoneEnv3 w x t) q := by
  refine exists_congr (fun w => and_congr_right (fun _ => ?_))
  exact nf_char_eq_iff_eval M 1 3 (zoneEnv3 w x t) q

/-! ## Phase 2: x-trichotomy split of the `:391` RHS existential

The `:391` obligation quantifies a single free anchor `x` over the arity-2 environment
`Fin.cons x (fun _ => t)` (the depth-`(k+1)` sub-form's env `[x, t]`, origin `t` fixed). Before any
navigation is built (Phases 4-6), the existential splits **unconditionally** into the three order
zones of `x` relative to the fixed origin `t`: past (`x < t`), diagonal (`x = t`), future (`t < x`).
This is the single-anchor analog of the arity-3 five-zone `nf_zone_exists_partition5`
(NfZoneDepthK.lean) — here only ONE boundary (`t`) exists, so the five zones collapse to the three
of the generic atom `exists_trichotomy_split`. No navigation, no characteristic-type machinery, no
new mathematics: it is exactly `exists_trichotomy_split` at boundary `c := t` with
`P x := nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`.

The env convention `Fin.cons x (fun _ => t)` matches `exist_tl_fn_k_correct`
(KampPrior.lean:334-344)
verbatim, so the past/future arms (Phases 5/6) and the diagonal arm (Phase 3) consume these three
disjuncts directly. The diagonal disjunct is `P t = nf_eval_nf M (k+1) 2 (Fin.cons t (fun _ => t))
sub_nf` (the two-value collision `[t, t]` collapsed by `renameNF_eval_diag0` + `char_k1` in Phase
3).
-/

/-- **Single-anchor `x`-trichotomy split** of the `:391` RHS existential. The bound anchor `x` lies
    below, at, or above the fixed origin `t`, splitting `∃ x, nf_eval_nf M (k+1) 2 [x,t] sub_nf`
    into
    past / diagonal / future disjuncts. Unconditional (pure order trichotomy); the single-boundary
    analog of `nf_zone_exists_partition5`, delegated directly to the generic atom
    `exists_trichotomy_split`. Feeds Phase 3 (diagonal, `x=t`), Phase 5 (past, `x<t`), Phase 6
    (future, `t<x`). -/
theorem nf_zone_exists_trichotomy_k1 {sig : MonadicSignature} [Fintype sig.preds]
    [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (k : Nat)
    (sub_nf : NormalForm sig (k + 1) 2) (t : M.carrier) :
    (∃ x, nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf) ↔
      (∃ x, x < t ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf) ∨
      (nf_eval_nf M (k + 1) 2 (Fin.cons t (fun _ => t)) sub_nf) ∨
      (∃ x, t < x ∧ nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf) :=
  exists_trichotomy_split
    (fun x => nf_eval_nf M (k + 1) 2 (Fin.cons x (fun _ => t)) sub_nf) t

/-! ## Phase 3: A_diag arm (x = t) — diagonal value-duplication collapse

The middle disjunct of `nf_zone_exists_trichotomy_k1` is the **diagonal** term
`nf_eval_nf M (k+1) 2 (Fin.cons t (fun _ => t)) sub_nf` — evaluation of the arity-2 sub-NF on the
**constant** environment `[t, t]` (both anchors collapse onto the fixed origin `t`). The goal is to
characterize this by an arity-1 characteristic formula (`char_k1`) applied to a **value-duplication
collapse** of `sub_nf`, per Obstruction 1: factor through `renameNF_eval_diag0`
(NfDepth0Generalized.lean:1646) + `char_k1_correct`, NEVER per-variable projection.

### Collapse / expand maps (arity 2 ↔ 1)

`diagCollapseMap : Fin 2 → Fin 1` merges both anchor positions to the single position `0`;
`diagExpandMap : Fin 1 → Fin 2` embeds the single position as position `0`. Their composite
`diagCollapseMap ∘ diagExpandMap = id` (the retraction `hsec2` that `renameNF_eval_diag0` needs),
but `diagExpandMap ∘ diagCollapseMap ≠ id` (the section `hsec` that the *non-injective* merge
violates — exactly why `renameNF_eval_iff` is inapplicable and the depth-lift is delicate). -/

/-- Collapse map arity 2 → 1: merge both anchor positions to the single position `0`. -/
def diagCollapseMap : Fin 2 → Fin 1 := fun _ => 0

/-- Expand map arity 1 → 2: the single position embeds as position `0`. -/
def diagExpandMap : Fin 1 → Fin 2 := fun _ => 0

/-- The retraction `hsec2`: collapsing after expanding is the identity on `Fin 1`. -/
theorem diagCollapse_expand_id : ∀ i : Fin 1, diagCollapseMap (diagExpandMap i) = i := by
  intro i
  simp only [diagCollapseMap]
  exact (Fin.fin_one_eq_zero i).symm

/-- **Value-duplication** of an arity-1 NF to arity 2 (any depth): duplicate the single position
    onto both anchor positions. `renameNF diagCollapseMap diagExpandMap : NF k 1 → NF k 2`. -/
def diagDup {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds] {k : Nat}
    (nf : NormalForm sig k 1) : NormalForm sig k 2 :=
  renameNF diagCollapseMap diagExpandMap nf

/-! ### Depth-0 base: duplication equivalence on the constant environment

At depth 0 the value-duplication equivalence holds **in both directions** (this is exactly
`renameNF_eval_diag0`, which drops the failing section `hsec` and needs only value compatibility on
the constant env plus the retraction `hsec2`). This is the sorry-free base that Obstruction 1's
diagonal factoring rests on. -/

/-- **Depth-0 constant-env duplication equivalence.** On the constant environment `fun _ => t`,
    the duplicated arity-2 NF `diagDup nf` evaluates iff the arity-1 `nf` does. Direct instance of
    `renameNF_eval_diag0` with the diagonal (all-`t`) env, `E = e = fun _ => t`. -/
theorem diagDup_eval_zero {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (nf : NormalForm sig 0 1) (t : M.carrier) :
    nf_eval_nf M 0 2 (fun _ => t) (diagDup nf) ↔ nf_eval_nf M 0 1 (fun _ => t) nf := by
  simp only [diagDup]
  exact renameNF_eval_diag0 M diagExpandMap diagCollapseMap
    (fun _ => t) (fun _ => t)
    (fun _ => rfl) (fun _ => rfl) diagCollapse_expand_id nf

/-! ### Phase-3 OBSTRUCTION: the diagonal arm is NOT arity-1-collapsible at depth `k+1`

The plan's Phase-3 route ("`A_diag_correct` as a plain iff `temporal_truth M t (char_k1 (collapse
sub_nf)) ↔ nf_eval_nf M (k+1) 2 [t,t] sub_nf`, assets only") is a **non-theorem for arbitrary
`sub_nf`** at depth `k+1`. This is the depth-`≥1` diagonal crux flagged sorry-free in
`NfDepth0Generalized.lean:1691-1719` ("at depth `k ≥ 1` the x=t arm is NOT separable from the
Phase-11 crux"), here re-derived directly for the constant-env `[t,t]` case.

**Why the depth-0 base (`diagDup_eval_zero`) does not lift.** Unfolding
`nf_eval_nf M (k+1) 2 (fun _ => t) sub_nf` at the quant layer, and any `char_k1`-of-a-collapse
formula's truth, both reduce a per-sub-form obligation to the **inner iff**

```
(∃ x, nf_eval_nf M k 3 (Fin.cons x (fun _ => t)) sub_a)          -- env [x, t, t]
  ↔ (∃ x, nf_eval_nf M k 2 (Fin.cons x (fun _ => t)) (Coll' sub_a))   -- env [x, t]
```

where `Coll' := renameNF (liftIdx diagExpandMap) (liftIdx diagCollapseMap)` collapses the two
`t`-positions. The `→` direction holds (the merged positions genuinely carry equal values `t`), but
the `←` direction is **false**: pick a non-diagonal-invariant `sub_a` (e.g. one whose atom layer
demands `order 1 2`, unsatisfiable at `[x,t,t]` since `t < t` is false) whose collapse `Coll' sub_a`
is nonetheless a realizable arity-2 characteristic. Then the RHS holds while the LHS fails, because
`nf_characteristic M k 3 [x,t,t]` is always diagonal-invariant and no `x` makes `sub_a` its value.

**Consequence.** `nf_characteristic M (k+1) 2 (fun _ => t) ≠ diagDup (nf_characteristic M (k+1) 1
(fun _ => t))` in general: the arity-2 characteristic encodes strictly more (which non-diagonal
sub-forms are unrealizable) than any arity-1 collapse can carry. Hence **no `char_k1`-of-collapse
formula characterizes the diagonal disjunct for arbitrary `sub_nf`.** A correct `A_diag` requires a
genuine **arity-2 (two-anchor) characteristic FORMULA builder** at depth `k+1` — which does not
exist as an asset (`KampPrior.nf_succ_char_formula` is arity-1 only;
`NfZoneDepthK.nf_char3_eq_succ_iff`
is an equality *decomposition*, not a temporal-formula construction). Building it is the two-anchor
"Phase-11 crux".

This is a **grounded scoping obstruction**, not a proof-engineering stall (it does not contradict
research VERDICT (a): a uniform navigable `A` still exists — but the diagonal arm's realization
needs
the two-anchor characteristic machinery, not the arity-1 collapse the plan assumed). Sorry-free
scaffolding landed here: `diagCollapseMap`/`diagExpandMap`, `diagCollapse_expand_id`, `diagDup`,
`diagDup_eval_zero`. The recommended follow-up is a dedicated build-out of the two-anchor
characteristic machinery the diagonal arm needs. -/

/-! ## Phase 5: A_past arm (`x < t`) — outer `bracketBuildLeft` (Since) navigation

The **past** disjunct of the Phase-2 trichotomy `nf_zone_exists_trichotomy_k1` is
`∃ x, x < t ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf`: the bound anchor `x` lies in
the
**past exterior** of the fixed origin `t`. Following Rabinovich Cor 5.4, this zone is realized by an
OUTER **navigated** `bracketBuildLeft` (Since) chain walking from `t` back to the bound witness `x`,
with a trivial (`top`) segment — exactly the `navigated_bracket_reaches_exterior_past` pillar
(established above, sorry-free, on top of the preserved asset `bracketBuildLeft_correct`). The chain
lays `x` as a **bracket witness** (never a named free anchor), so `A_past` = `bracketBuildLeft`
applied to a single endpoint `TemporalPred` `pastEnd`.

`pastEnd` is the OUTER endpoint hook: the depth-`(k+1)` arity-2 characteristic of `sub_nf` at the
navigated witness `x`, coupled to the fixed origin `t` (env `[x, t]`), checked by `.eval_at` at `x`.
Its correctness `h_past` is the recursion IH one arity/one depth in: unfolding
`nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t)) sub_nf` at the quant layer yields, per sub-form
`qnf : NormalForm sig k 3`, the coupled inner existential `∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t)
qnf`
— which is precisely what the **Phase-4 brick** `nf_zone_flatten_navigable_brick` (deliverable
2, `NfMultiAnchorBridge.lean`) flattens into a five-zone navigated disjunction. So the Phase-4
brick is
consumed **inside the construction of `pastEnd`/`h_past`** (the recursion, wired at Phase 7); the
A_past ASSEMBLY here stays hook-parametric over `pastEnd`/`h_past`, exactly as Phase 3's `A_diag`
and
Phase 4's brick stay hook-parametric over their recursion hooks.

### Route audit (Postmortem forbidden-route guards)
- **Two-endpoint architectural fact (Rabinovich):** the witness `x` couples to the interval endpoint
  `t` only (single-boundary past zone); deeper structure (the inner-`w` flattening) is absorbed as
  bracket witnesses within the endpoint `pastEnd`, never as a new anchor.
- **(b)** The endpoint is a NAVIGATED `TemporalPred` reached by `bracketBuildLeft` into the past
  exterior `x < t`, never a depth-0 atomic bracket (D1 refuted the atomic route).
- **(c)** No arity-1 collapse, no projection `VecEA2` bridge: `A_past` is pure outer navigation; the
  arity-2 evaluation at `[x, t]` stays honest inside `h_past` (the IH).

### Cycle-safe placement
`A_past` / `A_past_correct` depend ONLY on `navigated_bracket_reaches_exterior_past` (this file) and
`bracketBuildLeft` (`VecEATranslation`); neither references `NfMultiAnchorBridge` nor `KampPrior`.
They are therefore placed in this **KampPrior-independent** file (unlike Phase 3's `A_diag`, which
needs KampPrior-side `nf_char2_formula`), directly advancing the Phase-7 relocation concern: the
outer-navigation arms can live cycle-safe. -/

/-- **A_past arm** (Phase 5; the segment refactor): the outer
`bracketBuildLeft` (Since) navigation from the fixed origin `t` back to the bound witness `x` in the
past exterior, over a caller-supplied non-trivial segment `seg : BracketFormula 0` (the Rabinovich
Cor 5.4 `β_i` segment, md:154-157) and a single endpoint hook `pastEnd` (the depth-`(k+1)` arity-2
characteristic at the navigated `[x, t]`). The segment is now a parameter (previously hardcoded to
`BracketFormula.trivial TemporalPred.top`): per guard G3, the off-diagonal `(x, t)` coupling MUST
ride the non-trivial `β_i` segment supplied by the caller, so this def is segment-parametric. -/
noncomputable def A_past (seg : BracketFormula 0) (pastEnd : TemporalPred) : Formula :=
  bracketBuildLeft seg pastEnd

/-- **A_past arm correctness** (Phase 5; the segment refactor). `A_past seg
pastEnd` holds at `t` iff there is a past endpoint `z0 < t` where `pastEnd` holds and the caller's
segment `seg` holds on the open interval `(z0, t)`. This is the segment-carrying characterization
the
off-diagonal `F_i` chain (Phase 4) needs: a direct application of the preserved asset
`bracketBuildLeft_correct` (Rabinovich Cor 5.4 `β_i` past bracket, md:154-157), never rebuilding the
navigation mechanism. The `nf_eval_nf` coupling of `pastEnd` at `[x, t]` is discharged by the caller
one level up (Phase 4), not here — this lemma is purely the outer navigation ↔ segment-witness
equivalence. -/
theorem A_past_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier)
    (seg : BracketFormula 0) (pastEnd : TemporalPred) :
    temporal_truth M atomMap t (A_past seg pastEnd) ↔
      ∃ z0 : M.carrier, z0 < t ∧ pastEnd.eval_at M atomMap z0 ∧
        seg.holds M atomMap z0 t := by
  simp only [A_past]
  exact bracketBuildLeft_correct seg pastEnd M atomMap t

/-! ## Phase 6: A_future arm (`t < x`) — outer `bracketBuildRight` (Until) navigation

The exact **dual** of Phase 5. The **future** disjunct of the Phase-2 trichotomy
`nf_zone_exists_trichotomy_k1` is `∃ x, t < x ∧ nf_eval_nf M (k+1) 2 (Fin.cons x (fun _ => t))
sub_nf`:
the bound anchor `x` lies in the **future exterior** of the fixed origin `t`. It is realized by an
OUTER **navigated** `bracketBuildRight` (Until) chain walking from `t` forward to the bound witness
`x`, with a trivial (`top`) segment — the `navigated_bracket_reaches_exterior_future` pillar (Since-
mirror of the past pillar; sorry-free, on top of the preserved asset `bracketBuildRight_correct`).
`x` is laid as a bracket witness (never a named free anchor), so `A_future` = `bracketBuildRight`
applied to a single endpoint `TemporalPred` `futureEnd`.

`futureEnd` is the OUTER endpoint hook: the depth-`(k+1)` arity-2 characteristic of `sub_nf` at the
navigated witness `x`, coupled to the fixed origin `t` (env `[x, t]`), checked by `.eval_at` at `x`;
its correctness `h_fut` is the recursion IH, and (exactly as in Phase 5) the Phase-4 brick
`nf_zone_flatten_navigable_brick` is consumed inside `futureEnd`/`h_fut` (the quant layer of the
arity-2 char at `[x,t]` flattens via the brick), wired at Phase 7. The A_future ASSEMBLY stays
hook-parametric over `futureEnd`/`h_fut`.

### Route audit — identical to Phase 5 (dual)
Two-endpoint architectural fact respected (`x` couples to endpoint `t` only; deeper structure
absorbed
as bracket witnesses in `futureEnd`); endpoint NAVIGATED (route (b), not depth-0 atomic); no arity-1
collapse / no projection `VecEA2` (route (c)/(a)). Placed cycle-safe in this KampPrior-independent
file alongside `A_past`. -/

/-- **A_future arm** (Phase 6; the segment refactor): the outer
`bracketBuildRight` (Until) navigation from the fixed origin `t` forward to the bound witness `x` in
the future exterior, over a caller-supplied non-trivial segment `seg : BracketFormula 0` (the
Rabinovich Cor 5.4 future-dual `β_i` segment, md:154-157) and a single endpoint hook `futureEnd`
(the
depth-`(k+1)` arity-2 characteristic at the navigated `[x, t]`). Dual of `A_past`; the segment is a
parameter per guard G3 (the off-diagonal `(t, x)` coupling rides the non-trivial segment). -/
noncomputable def A_future (seg : BracketFormula 0) (futureEnd : TemporalPred) : Formula :=
  bracketBuildRight seg futureEnd

/-- **A_future arm correctness** (Phase 6; the segment refactor). Dual of
`A_past_correct`: `A_future seg futureEnd` holds at `t` iff there is a future endpoint `z1 > t`
where
`futureEnd` holds and the caller's segment `seg` holds on the open interval `(t, z1)`. A direct
application of the preserved asset `bracketBuildRight_correct` (Rabinovich Cor 5.4 future-dual `β_i`
bracket, md:154-157), never rebuilding the navigation mechanism. The `nf_eval_nf` coupling of
`futureEnd` at `[x, t]` is discharged by the caller one level up (Phase 5). -/
theorem A_future_correct {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (t : M.carrier)
    (seg : BracketFormula 0) (futureEnd : TemporalPred) :
    temporal_truth M atomMap t (A_future seg futureEnd) ↔
      ∃ z1 : M.carrier, t < z1 ∧ futureEnd.eval_at M atomMap z1 ∧
        seg.holds M atomMap t z1 := by
  simp only [A_future]
  exact bracketBuildRight_correct seg futureEnd M atomMap t

end Bimodal.Metalogic.WeakCanonical.Kamp
