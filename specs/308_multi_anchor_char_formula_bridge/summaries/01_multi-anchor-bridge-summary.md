# Implementation Summary: Multi-Anchor Characteristic Formula Bridge (task 308)

- **Task**: 308 — multi_anchor_char_formula_bridge
- **Type**: lean4 (hard mode: H2 anti-analysis, H3 Tier-1 grounding, H9 wrap-up)
- **Session**: sess_1783349138_661f38
- **Status**: COMPLETED (6/6 phases, sorry-free, axioms = baseline)
- **Plan**: `specs/308_multi_anchor_char_formula_bridge/plans/01_multi-anchor-bridge-plan.md`
- **Deliverable file**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`
  (new leaf, module `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`, 578 lines, 0 sorries)

## Executive Result

Built the depth-graded two-anchor characteristic-formula bridge sorry-free, **off the live import
path** (zero importers — confirmed leaf). Two reusable deliverables, both intentionally
**hook-parametric** so the recursion interface is the seam that consuming tasks (307, 305)
instantiate rather than rebuild:

- **Deliverable 1** — `nf_char2_formula` (+ `_correct`): the arity-2 characteristic *formula*
  builder, mirroring the arity-1 template `nf_succ_char_formula` exactly one arity up. Unblocks
  **task 307 Phase 3** (the A_diag `x = t` arm).
- **Deliverable 2** — `nf_zone_flatten_navigable` (+ `_correct`): the general navigated
  bounded-existential corollary at arbitrary anchors `(x, t)`, five-zone navigated disjunction.
  Unblocks **task 307 Phases 4/5/6** (general flattening brick, A_past via `bracketBuildLeft`,
  A_future via `bracketBuildRight`).

## Final Verification (Phase 6)

| Check | Result |
|-------|--------|
| Full `lake build` (whole project) | **GREEN** (1700 jobs, exit 0) |
| `lean_verify nf_char2_formula` | axioms `[propext, Classical.choice, Quot.sound]`, 0 warnings |
| `lean_verify nf_char2_formula_correct` | axioms `[propext, Classical.choice, Quot.sound]`, 0 warnings |
| `lean_verify nf_zone_flatten_navigable` | axioms `[propext, Classical.choice, Quot.sound]`, 0 warnings |
| `lean_verify nf_zone_flatten_navigable_correct` | axioms `[propext, Classical.choice, Quot.sound]`, 0 warnings |
| `sorry` tokens in file (word-boundary, excl. "sorry-free") | **0** |
| Importers of `NfMultiAnchorBridge` | **none** (leaf, off live import path) |

Axiom set is **exactly** the verified baseline on all four headline declarations. No new axiom, no
`sorryAx`, no vacuous placeholder.

## Exact Signatures a Consumer Must Supply (R-C hand-off)

Namespace: `Bimodal.Metalogic.WeakCanonical.Kamp`. `TemporalPred`, `NormalForm`, `nf_eval_nf`,
`temporal_truth`, `zoneEnv3`, `bracketBuildLeft`/`Right`, `BracketFormula.trivial` are the existing
preserved assets (VecEATranslation / NfZoneDepthK / NfZoneFlattenNavigable / KampPrior).

### Deliverable 1 — `nf_char2_formula` (NfMultiAnchorBridge.lean:324)

```lean
noncomputable def nf_char2_formula {sig : MonadicSignature}
    (atomMap : Formula → sig.preds)
    (h_surj : ∀ p : sig.preds, ∃ a : Atom, atomMap (.atom a) = p)
    {k : Nat}
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)   -- recursion HOOKS
    (diagChar : NormalForm sig k 3 → Formula)                 -- recursion HOOK
    (sub_nf : NormalForm sig (k + 1) 2) : Formula
```

```lean
theorem nf_char2_formula_correct {sig : MonadicSignature}
    (atomMap …) (h_surj …) {k : Nat}
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (diagChar : NormalForm sig k 3 → Formula)
    (M : OrderedMonadicStructure sig) (t : M.carrier)
    (h_exist_correct : ∀ (qnf : NormalForm sig k 3),
      temporal_truth M atomMap t (nf_char2_diag_exist_tl pastEnd futureEnd diagChar qnf) ↔
        ∃ w : M.carrier, nf_eval_nf M k 3 (Fin.cons w (fun _ => t)) qnf)
    (sub_nf : NormalForm sig (k + 1) 2) :
    temporal_truth M atomMap t
        (nf_char2_formula atomMap h_surj pastEnd futureEnd diagChar sub_nf) ↔
      nf_eval_nf M (k + 1) 2 (fun _ => t) sub_nf
```

**What the consumer supplies:** the three hooks `pastEnd`/`futureEnd`/`diagChar` (the depth-`k`
recursion endpoints), and the single correctness obligation `h_exist_correct` — the iff for the
Phase-2 diagonal existential converter `nf_char2_diag_exist_tl`, which the codebase already provides
as `nf_char2_diag_exist_tl_correct` once the hooks are instantiated. This mirrors exactly the
arity-1 template `nf_succ_char_formula` / `_correct`, which is parametric over `exist_tl_fn` and its
`h_exist_correct`. Consuming task 307 Phase 3 plugs in its A_diag hooks and discharges
`h_exist_correct` at `x = t`.

### Deliverable 2 — `nf_zone_flatten_navigable` (NfMultiAnchorBridge.lean:537)

```lean
noncomputable def nf_zone_flatten_navigable {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)   -- navigated endpoint HOOKS
    (q : NormalForm sig k 3) : Prop
```

The RHS is the five-zone navigated disjunction (past-exterior `w < x` via `bracketBuildLeft` from
origin `x`; point `w = x`; bounded interior `x < w < t`; point `w = t`; future-exterior `t < w` via
`bracketBuildRight` from origin `t`). It is **Prop-valued**, not a single `Formula`, because the two
open exterior zones navigate from **distinct origins** `x` and `t` and cannot share one formula's
truth-point (see Deviations).

```lean
theorem nf_zone_flatten_navigable_correct {sig : MonadicSignature} {k : Nat}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds)
    (x t : M.carrier)
    (pastEnd futureEnd : NormalForm sig k 3 → TemporalPred)
    (q : NormalForm sig k 3)
    (h_past : ∀ w : M.carrier, w < x →
      ((pastEnd q).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w x t) q))
    (h_fut : ∀ w : M.carrier, t < w →
      ((futureEnd q).eval_at M atomMap w ↔ nf_eval_nf M k 3 (zoneEnv3 w x t) q)) :
    (∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q) ↔
      nf_zone_flatten_navigable M atomMap x t pastEnd futureEnd q
```

**What the consumer supplies:** the two navigated endpoint hooks `pastEnd`/`futureEnd`, and the two
correctness hypotheses `h_past`/`h_fut` — each stating that the hook's `.eval_at` at the navigated
witness characterizes the coupled arity-3 evaluation one depth down. **`h_past`/`h_fut` ARE the
depth-`k` induction hypothesis** at `k ≥ 1`; at `k = 0` they bottom out in the Phase-1 base
`nf_zone_flatten_navigable_zero`. The three residual zones (`w = x`, `x < w < t`, `w = t`) stay as
honest arity-3 `nf_eval_nf` obligations the caller discharges one depth down (via
`nf_char3_deeper_split`).

## How Task 307 Consumes These (Phases 3–6)

Reference: `specs/307_kamp_cor54_bound_anchor_zone_converter/reports/02_diag-blocker-audit.md`.

Task 307's `:391` obligation is the arm `| k + 1, n, sub_nf =>` / `match n with | 1 => sorry` inside
`nf_nvar_exist_all_depths` (KampPrior.lean:252), where `sub_nf : NormalForm sig (k+1) 2` is a
**universally quantified bound parameter** of the recursive definition. The blocker audit's decisive
finding (§1.1) is that the arity-1-collapse route for the A_diag arm
(`A_diag := char_k1 (diagCollapse sub_nf)`) is a genuine **non-theorem** that **BINDS** at the real
`:391` obligation precisely because `sub_nf` is arbitrary — no exploitable pipeline structure exists.
The audit's chosen route (iii) was to spawn this prerequisite: the missing object is the
depth-graded multi-anchor characteristic *formula* builder, load-bearing for 307 Phases 3, 4, 5, 6.
Task 308 supplies it. Consumption map:

| Task 307 phase | Consumes | Instantiation |
|----------------|----------|---------------|
| Phase 3 — A_diag arm (`x = t`) [BLOCKED→unblocked] | **Deliverable 1** `nf_char2_formula` (+ `_correct`) | supply `pastEnd`/`futureEnd`/`diagChar` at `x = t`; discharge `h_exist_correct` via `nf_char2_diag_exist_tl_correct` |
| Phase 4 — general-`k` navigable flattening brick | **Deliverable 2** `nf_zone_flatten_navigable` (+ `_correct`) | supply `pastEnd`/`futureEnd`; discharge `h_past`/`h_fut` as the depth-`k` IH |
| Phase 5 — A_past arm (`x < t`) via `bracketBuildLeft` | Deliverable 2 (past-exterior zone) | the `w < x` open zone is already the `bracketBuildLeft` navigation from origin `x` |
| Phase 6 — A_future arm (`t < x`) via `bracketBuildRight` | Deliverable 2 (future-exterior zone) | the `t < w` open zone is already the `bracketBuildRight` navigation from origin `t` |

Task 307 does **not** rebuild the bridge; it instantiates the hooks and discharges the correctness
side-conditions, then wires the assembled `A` into KampPrior.lean:391 (307 Phase 7).

## Task-305 Artifacts to Rewire (Reuse Verbatim, Do Not Rebuild)

Task 305's Phase-11b lineage circled this exact object three times without converging (the "recurring
failure object", plan Risk R-A). These 305 artifacts reference the Phase-11b / multi-anchor bracket
bridge and should be **rewired to reuse task 308's definitions verbatim** rather than re-attempting
construction:

| Task-305 artifact | Reference | Rewire action |
|-------------------|-----------|---------------|
| `specs/305_rabinovich_ea_formula_implementation/reports/40_phase11b-divergence-audit.md` | Divergence audit issuing **NO-GO** on the "multi-anchor bounded-existential bracket bridge" as an arity-tower | Supersede the NO-GO: 308's hook-parametric split avoids the arity tower (arity stays ≤3, anchor set `{x,t}`); cite 308 deliverable 2 as the resolved form |
| `specs/305_rabinovich_ea_formula_implementation/plans/39_direct-nf-construction.md` | Phase 11b projection/bracket framing (`:351–386`), "resume Phase 11b: build the bracket bridge" | Retarget the Phase-11b resume to *consume* `nf_char2_formula` / `nf_zone_flatten_navigable`; drop the from-scratch bracket-integration steps |
| `specs/305_rabinovich_ea_formula_implementation/plans/40_prop43-negation-closure-route.md` | Phase-11b outer `y`-split + inner `w`-split + char interface listed as preserved assets (`:127–128`) | Those preserved 305 assets (`nf_char3_eq_succ_iff`, `nf_characteristic_quant_split3`, `exists_nested_split3`) are exactly what 308 consumes — 305 keeps them, and imports 308's assembled bridge instead of assembling a fourth time |

## Depth / Anchor-Count Assumptions the 305 Rewire Must Respect

The task-305 rewire (and any consumer) must honor the invariants that make the construction
terminate and stay Rabinovich-faithful:

1. **Depth stratification (load-bearing discriminator vs. forbidden route (c)):** the diagonal
   collapse (`renameNF_eval_diag0`) is used **only at the depth-0 atom layer**, where it is a proven
   iff. The depth-`(k+1)` quant layer is discharged through the honest arity-3 navigated existential
   (deliverable 2), **never** collapsed to arity 1.
2. **Env arity ≤ 3, reducing to 2:** the navigated existential's env arity never exceeds
   `{w, x, t} = 3`, reducing to `{x, t} = 2` when `w` is peeled (proven by `zoneEnv3_arity_invariant`).
   The outer formula's anchor set stays `{x, t}` — the Rabinovich ≤2 free-variable cap (Lemma 3.2.2).
   Endpoint re-reference to anchors is encoded by **nested navigation**, never by growing env arity.
   This is what dissolves the 305 report-40 arity-tower NO-GO.
3. **Anchor set `{x, t}`:** exactly two anchors; deeper quantifier structure is absorbed as
   **additional bracket witnesses in one interval** (Rabinovich's method), not as new anchors.
4. **Prop-valued deliverable 2, distinct navigation origins:** the past-exterior zone navigates from
   `x`, the future-exterior from `t`; a consumer must keep these as separate disjuncts (Prop), not
   force them into one `Formula` truth-point.

## Forbidden-Route Guardrails and How the Landed Construction Avoids Each

From the plan's Postmortem Constraints (derived from three 305 refutations + the 307 audit). Each
landed lemma carries an in-file route audit; the sorry-free `lean_verify` at baseline is the
enforcement (a forbidden route would fail to close at the `:391`-shaped obligation).

- **(a) No projection-based VecEA2 bridge for `x = t`.** `liftIdx(totalUnskip)` is non-injective, so
  the coupled quant layer does not factor through per-variable projections. **Avoided:** the coupled
  `∃w` is split **directly on the full env** (`zoneEnv3 w x t` / `Fin.cons w (zoneEnv3 y x t)`) via
  `nf_char2_zone_split5` / `exists_nested_split3` / `nf_char3_eq_succ_iff` — never per-variable
  projection.
- **(b) No flat single-interval atomic bracket absorption.** A depth-0 atomic `BracketFormula` is
  confined to `[x, t]` and cannot capture exterior-`w` realizability. **Avoided:** both
  open-exterior-zone endpoints are **navigated** recursive `bracketBuild*` `TemporalPred`s (via
  `navigated_bracket_reaches_exterior_past`/`_future`), never depth-0 atomic brackets.
- **(c) No arity-1-collapse repair for the diagonal arm.** `char_k1 (diagCollapse sub_nf)` reduces to
  the depth-`(k+1)` lift of `diagDup_eval_zero`, a documented non-theorem (the `←` direction fails).
  **Avoided:** the diagonal collapse is confined to the depth-0 atom layer only; every quant residual
  stays an honest arity-3 `nf_eval_nf` on `zoneEnv3 · x t`.

## Phase-by-Phase Deviation Log

All deviations are plan-annotated inline (`plans/01_multi-anchor-bridge-plan.md`). None introduced a
sorry or a new axiom; all are R-B-sanctioned parametricity or scoping refinements.

| Phase | Deviation | Rationale |
|-------|-----------|-----------|
| 1 | `nf_char2_atom_layer` stated as the diagonal atom-layer iff for the value-duplicated form `diagDup nf1`; the arbitrary-`sub_nf.1` order-atom / pred-agreement guard **deferred to Phase 3** | The atom guard is naturally discharged at assembly, where the `atom_part` formula is built |
| 1 | `nf_zone_flatten_navigable_zero` realized via tail-diagonal duplication `diagDup3`/`diagDup3_eval_zero` (direct `renameNF_eval_diag0` instance) | Cleaner `k=0` base; still diag collapse at depth 0 only |
| 2 | endpoint `TemporalPred`s supplied as **parametric hooks** `pastEnd`/`futureEnd`, point zone via hook `diagChar` (with `h_diag`) | The arity-3 endpoint characteristic builder is not an existing asset; it is the recursion interface Phases 4–5 (and tasks 307/305) supply — mirrors arity-1 `exist_tl_fn` parametricity (plan R-B) |
| 3 | `atom_part` built by a new `nf_char2_atom_part` builder (diagonal-consistent atoms → arity-1 pred char; non-diagonal → `⊥`), discharging the Phase-1-deferred guard; `nf_char2_formula` stays hook-parametric; Phase-2 iff taken as `h_exist_correct` hypothesis | Mirrors `nf_succ_char_formula_correct`'s `h_exist_correct`; plan-sanctioned R-B parametricity |
| 4 | Five-zone split landed as `nf_char2_zone_split5` via a new generic two-boundary `exists_zone_split5` (nested `lt_trichotomy`), the outer-`y` mirror of `exists_nested_split3` | Outer split needs only 2 boundaries / 5 zones, not the inner 3-boundary / 7-zone `exists_nested_split3` |
| 5 | Deliverable 2 landed as a **Prop-valued corollary** (not a single `Formula`); `k`-recursion threaded through hooks (no literal `Nat.rec`) | The two open exterior zones navigate from distinct origins `x`/`t` and cannot share one formula's truth-point; hook threading bottoms out at `k=0` in `nf_zone_flatten_navigable_zero` |

## Preserved Assets (Consumed Verbatim, Not Modified)

`nf_char3_eq_succ_iff`, `nf_char_eq_iff_eval`, `nf_characteristic_quant_split3`,
`nf_characteristic_quant_succ`, `exists_nested_split3` (NfZoneDepthK.lean); `renameNF_eval_diag0`
(NfDepth0Generalized.lean); `bracketBuildLeft`/`Right` (+ `_correct`) (VecEATranslation.lean);
`nf_succ_char_formula`/`_correct`, `nf_quant_clause_tl`/`_correct`, `nf_depth0_char_formula`
(KampPrior.lean); `diagDup`/`diagDup_eval_zero`, `nf_zone_exists_trichotomy_k1`,
`exists_trichotomy_split`, `navigated_bracket_reaches_exterior_past`/`_future`
(NfZoneFlattenNavigable.lean). No preserved asset was re-derived or overwritten; the deliverable file
is a leaf importing only `NfZoneFlattenNavigable` and `KampPrior`.

## Artifacts

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (new leaf; both deliverables, 0 sorries)
- `specs/308_multi_anchor_char_formula_bridge/plans/01_multi-anchor-bridge-plan.md`
- `specs/308_multi_anchor_char_formula_bridge/summaries/01_multi-anchor-bridge-summary.md` (this file)
