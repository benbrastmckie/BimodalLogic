import Bimodal.Metalogic.WeakCanonical.Kamp.VecEATranslation
import Bimodal.Metalogic.WeakCanonical.Kamp.NfZoneDepthK

/-!
ARCHIVED (Boneyard) — never compiled. Archived material; see the Boneyard README inventory.

# Phase 16 GO/NO-GO GATE — exterior-navigation capture at k = 1 (plan v40)

This module is the **decisive go/no-go gate** for plan v40's Uniform-Prop-4.3 negation-closure
route (`plans/40_prop43-negation-closure-route.md`, Phase 16). It is **off the live import path**
(nothing in the `completeness_discrete` chain imports it) and is **fully sorry-free**.

## The make-or-break claim under test

Plan v40 Phase 16 proposes to define a model-independent temporal formula `A_fut_k1` (via
`bracketBuildRight`, with the depth-0 IH realizability formula as the navigable endpoint type) and
prove, for **all** Prior `M` and a **free anchor `x`** with `x < t`:

    temporal_truth M atomMap t (A_fut_k1 … qnf)  ↔  (∃ y, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf)

i.e. that navigation (`bracketBuildRight` — `Until` from `t`, and `Since` back from the witness `y`
to look at `x`) captures the **future exterior zone** `t < y` coupled existential that a flat atomic
bracket provably cannot (D1, `NfZoneDepthK1Probe.lean`). The plan's own "Note on `x`" flags the
falsification criterion verbatim:

  > if the future-zone iff for a *free* anchor `x` cannot be stated with `A_fut_k1`
  > model-independent (because `A` at `t` cannot see a free `x`), that IS the NO-GO signal — the
  > multi-anchor single-point obstruction (report 40 §2.1-A) has recurred.

## Verdict landed here: NO-GO (sorry-free refutation)

**The gate as stated is a non-theorem, and this file proves it — for _every_ candidate formula
`A`, not merely the intended `bracketBuildRight` construction.**

The obstruction is the *free-anchor identification problem*, the future-zone (navigable) sibling of
D1's interior-confinement obstruction and the arity-tower obstruction of report 40 §2.1-A:

* The RHS `∃ y, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf` **pins the free anchor `x`'s local
  monadic type**: its atom layer forces, for every predicate `p`, `M.interp p x ↔ qnf` assigns `p`
  at variable `1`. So the RHS depends genuinely on `x` (`future_zone_pins_x_pred`).
* The LHS `temporal_truth M atomMap t A` is, for any fixed `A`, a **single** truth value determined
  by `(M, atomMap, t)` — it **cannot see the free anchor `x`** (`A` is built from `qnf`, not `x`).
  So the gate iff would force the RHS to be *independent of `x`* (`gate_forces_x_independence`).

These two facts are contradictory in any non-degenerate model: pick two past anchors `x₁, x₂ < t`
where `x₁` realizes the zone but `x₂` has the *wrong* `p`-type; the gate iff makes both RHS values
equal to `temporal_truth M atomMap t A`, forcing `x₂` to carry `p` after all — a contradiction
(`no_x_independent_formula_captures_future_zone_k1`). No amount of `Until`/`Since` navigation
repairs this: navigation from `t` (or from a future witness `y`) can quantify over past points
("∃ a past point of type τ", "∀ past points …") but can never **name the specific free point `x`**.
This is exactly report 40 §2.1-A's finding — the endpoint `TemporalPred` is single-point
(`ExistsForallNF.lean:49-56`), and a multi-anchor `char[y,x,t] = qnf` condition with a *free* second
anchor `x` cannot be carried by it — restated here for the future-navigable encoding.

## Consequence / next action

Per the Phase 16 GATE DECISION and the plan v40 NO-GO branch: **NO-GO. STOP.** Do not attempt
Phases 17-20; do not recede to a new framing. The residual is the named `/spawn` candidate:

  > Kamp Cor 5.4 depth-k zone converter — resolve the multi-anchor single-point coupling: express the
  > quantified zone witness's coupling to the second anchor as a uniform navigable temporal formula
  > **when that anchor is existentially bound and navigated-to (not free)**, or establish the
  > definitive obstruction there too.

### Divergence note (Rabinovich 2014 §5, verbatim)

The route sought to realize Rabinovich's Cor 5.4 (`md:154-157`): *"Define `F_n := α_n` and
`F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`. Then `[α_0, …, α_n](z_0, z)` holds iff there is an
increasing sequence in `(z_0, z_1)` with `F_0(z_0)` holding. … the `F_i` are TL-definable."* In
Rabinovich the interval endpoints `z_0, z_1` bound the construction and the witnesses
`x_0 < … < x_n` all lie **in the single interval `(z_0, z_1)`** with **quantifier-free single-point
types** `α_j, β_j` (Def 3.1 / Key Insight §2, `md:65-74,213-219`). The Lean gate diverges by
requiring the endpoint type to encode the *depth-`k` characteristic type* `char[y,x,t] = qnf` of a
**second, free anchor `x` distinct from both interval endpoints `t` and the witness `y`**. This is
not a construct the paper's `F_i` chain expresses: Rabinovich's `F_i` couple witnesses to the two
*interval* endpoints, never to a third free anchor. The paper's Dedekind-completeness / INF
machinery (§5.2, `md:145-149`; Key Insight §3, `md:221`) resolves *negation over one interval*, not
free-anchor identification. Hence the Lean encoding is **forced to diverge** from the paper, and the
divergence is exactly the non-theorem this file records.

## References
- `plans/40_prop43-negation-closure-route.md` Phase 16 (this gate), Postmortem Constraints, Note on `x`.
- `reports/40_phase11b-divergence-audit.md` §2.1-A (single-point endpoint; multi-anchor char impossible).
- `NfZoneDepthK1Probe.lean` (D1: the flat-bracket sibling obstruction — interior confinement).
- `NfZoneDepthK.lean:537` (`nf_char3_eq_succ_iff` — the atom-layer/quant-layer decomposition used here).
- `NormalForm.lean:113-117,201-207` (`atom_eval`, `nf_eval_nf` depth-0; monadic atom = `M.interp p (env i)`).
- Rabinovich 2014 "A Proof of Kamp's Theorem" §5 / Cor 5.4 (`md:119-157`), Key Insights (`md:208-230`).
  Local: `~/Projects/Literature/sources/rabinovich_2014/Rabinovich_2014_Proof_of_Kamps_Theorem.md`.
-/

#exit

namespace Bimodal.Metalogic.WeakCanonical.Kamp

open Bimodal.Syntax
open Bimodal.Metalogic.WeakCanonical

/-! ## Pillar 1: the future-zone RHS pins the free anchor `x`'s monadic type

The arity-3 env `zoneEnv3 y x t = Fin.cons y (Fin.cons x (fun _ => t))` places `x` at position `1`.
The monadic atom `.pred p ⟨1, _⟩` evaluates to `M.interp p x` — depending **only** on `x`, not on the
witness `y`. So a realization of `qnf` at `[y, x, t]` forces `x`'s `p`-value to equal `qnf`'s
variable-`1` assignment. Hence the future-zone existential, for any witness, pins `x`'s local type. -/

/-- The variable-`1` (anchor `x`) monadic-atom fact extracted from a depth-`1` realization at the
    two-anchor env `[y, x, t]`: for any predicate `p`, `M.interp p x` iff `qnf` sets `p` at
    variable `1`. Pure atom-layer read-off (`nf_eval_atom_layer`), witness `y` irrelevant. -/
theorem nf3_pred_x {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (y x t : M.carrier) (p : sig.preds)
    (h : nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf) :
    (M.interp p x) ↔ (qnf.atom_assgn (.pred p ⟨1, by omega⟩) = true) := by
  have hlayer := nf_eval_atom_layer M 1 3 (zoneEnv3 y x t) qnf h (.pred p ⟨1, by omega⟩)
  simpa [atom_eval, zoneEnv3, Fin.cons] using hlayer

/-- **The future-zone RHS pins `x`'s monadic type.** If the future exterior zone existential
    `∃ y, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf` holds, then `x`'s `p`-value is exactly
    `qnf`'s variable-`1` assignment for `p`. This is the load-bearing dependence of the RHS on the
    free anchor `x`: the RHS genuinely varies with `x`'s local type. -/
theorem future_zone_pins_x_pred {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (qnf : NormalForm sig 1 3) (x t : M.carrier) (p : sig.preds)
    (h : ∃ y : M.carrier, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf) :
    (M.interp p x) ↔ (qnf.atom_assgn (.pred p ⟨1, by omega⟩) = true) := by
  obtain ⟨y, _, hy⟩ := h
  exact nf3_pred_x M qnf y x t p hy

/-! ## Pillar 2: an `x`-independent formula at `t` cannot vary with `x`

For any fixed formula `A`, `temporal_truth M atomMap t A` is one truth value (it does not mention
`x`). So if `A` satisfied the gate iff for all `x < t`, the RHS would be forced independent of `x`.
This is the future-navigable sibling of report 40 §2.1-A: the endpoint is single-point and cannot
name a free second anchor. -/

/-- **The gate iff forces the RHS to be independent of the free anchor `x`.** If a single formula
    `A` satisfies the future-zone gate iff for every past anchor, then the future-zone existential
    takes the same truth value at any two past anchors `x₁, x₂ < t` (both equal
    `temporal_truth M atomMap t A`). The formula literally cannot distinguish anchors it does not
    mention. -/
theorem gate_forces_x_independence {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (qnf : NormalForm sig 1 3) (A : Formula) (t : M.carrier)
    (hgate : ∀ x : M.carrier, x < t →
      (temporal_truth M atomMap t A ↔
        ∃ y : M.carrier, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf))
    (x₁ x₂ : M.carrier) (h₁ : x₁ < t) (h₂ : x₂ < t) :
    (∃ y : M.carrier, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x₁ t) qnf) ↔
      (∃ y : M.carrier, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x₂ t) qnf) := by
  rw [← hgate x₁ h₁, ← hgate x₂ h₂]

/-! ## The packaged obstruction (NO-GO core)

Combining the two pillars: in any non-degenerate model — one containing a past anchor `x₁ < t` that
realizes the future-zone existential and a past anchor `x₂ < t` whose `p`-type is *wrong* for `qnf`
— **no** formula `A` can satisfy the future-zone gate iff. The RHS pins `x`'s type (Pillar 1) yet
the gate would force it independent of `x` (Pillar 2); these collide. -/

/-- **NO-GO obstruction, future exterior zone, depth 1.** There is no formula `A` (built from `qnf`,
    hence not mentioning the free anchor `x`) satisfying the Phase-16 future-zone gate iff for all
    past anchors, in any model exhibiting a *realizing* anchor `x₁` and a *type-mismatched* anchor
    `x₂`. Concretely: if `qnf` sets predicate `p` at variable `1`, some `x₁ < t` realizes the zone,
    and some `x₂ < t` fails `p` (`¬ M.interp p x₂`), then the gate iff is contradictory.

    This is the future-navigable sibling of D1's `interior_bracket_cannot_realize_exterior_sub_k1`:
    where D1 refuted the *flat* bracket by interior confinement, this refutes the *navigable* bracket
    by free-anchor identification. Together with report 40 §2.1-A's arity-tower trace, the three
    obstructions converge — a temporal formula at a single anchor cannot encode a characteristic-type
    condition on a *second free anchor*. -/
theorem no_x_independent_formula_captures_future_zone_k1 {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (qnf : NormalForm sig 1 3) (A : Formula) (t : M.carrier) (p : sig.preds)
    (hp : qnf.atom_assgn (.pred p ⟨1, by omega⟩) = true)
    (x₁ x₂ : M.carrier) (h₁ : x₁ < t) (h₂ : x₂ < t)
    (hx₁ : ∃ y : M.carrier, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x₁ t) qnf)
    (hx₂ : ¬ M.interp p x₂)
    (hgate : ∀ x : M.carrier, x < t →
      (temporal_truth M atomMap t A ↔
        ∃ y : M.carrier, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x t) qnf)) :
    False := by
  -- The gate forces the future-zone existential to agree at x₁ and x₂.
  have hshared := gate_forces_x_independence M atomMap qnf A t hgate x₁ x₂ h₁ h₂
  -- x₁ realizes, so the shared value is `True`; hence x₂ realizes too.
  have hx₂real : ∃ y : M.carrier, t < y ∧ nf_eval_nf M 1 3 (zoneEnv3 y x₂ t) qnf :=
    hshared.mp hx₁
  -- But realizing at x₂ pins x₂'s p-type to `qnf`'s (true), contradicting hx₂.
  have hpin := (future_zone_pins_x_pred M qnf x₂ t p hx₂real).mpr hp
  exact hx₂ hpin

end Bimodal.Metalogic.WeakCanonical.Kamp
