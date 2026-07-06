# Report 01 — Multi-Anchor Characteristic Formula Bridge (task 308)

- **Task**: 308 — multi_anchor_char_formula_bridge
- **Type**: lean4 (hard-mode research; H2/H3/H4 apply; spawned from task 307 blocker audit)
- **Session**: sess_1783349138_661f38
- **Reference grounding tier**: Tier 1 (literature-backed — Rabinovich 2014, Cor 5.4 §5 `F_i` chain; Lemma 5.1 w-zone decomposition)
- **Inputs verified**: `KampPrior.lean:78,107-198,244-402`, `NfZoneDepthK.lean:432-550`,
  `NfDepth0Generalized.lean:1646-1721`, `VecEATranslation.lean:50-62,234-310,503-566`,
  `NfZoneFlattenNavigable.lean:47-290`, `NfZoneDepthK1Probe.lean:143`, task-307 report 02,
  Rabinovich md:59-173.

## Executive Summary

Task 308 builds one reusable object — the depth-graded two-anchor characteristic **formula**
builder — that unblocks task-307 Phases 3–6 and supplies task-305's Phase-11b crux. All preserved
assets were verified to exist, be sorry-free at the declaration level, and (for the four
load-bearing ones) to carry axioms **exactly `[propext, Classical.choice, Quot.sound]`** via
`lean_verify`. A viable construction route is identified that provably avoids all three
Postmortem-forbidden routes (a)/(b)/(c). The decisive discriminator: **the diagonal collapse
(`renameNF_eval_diag0`) is confined to the depth-0 atom layer, where it is a genuine iff; the
depth-`(k+1)` quant layer is discharged through the honest arity-3 navigated existential (never
collapsed to arity-1).** This is exactly the separation that the sorry-free non-theorem at
`NfDepth0Generalized.lean:1691-1719` says is required.

## Findings

### F1. Deliverable shapes (verified against the live obligation)

The `:391` obligation in `nf_nvar_exist_all_depths` (KampPrior.lean:387-391, match arm
`k+1, 1, sub_nf`) is:

```
∃ env : Fin 1 → M.carrier, nf_eval_nf M (k+1) 2 (insertEnv env t) sub_nf
```

which `nf_zone_exists_trichotomy_k1` (NfZoneFlattenNavigable.lean:188, **landed sorry-free**)
already splits into past (`x<t`) / **diagonal (`x=t`)** / future (`t<x`) disjuncts over the env
`Fin.cons x (fun _ => t)`. The **diagonal** disjunct is `nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf`
— exactly deliverable 1's target. The past/future disjuncts are the navigated bounded existentials
that deliverable 2 realizes.

**Deliverable 1** `nf_char2_formula : NormalForm sig (k+1) 2 → Formula` with
`temporal_truth M atomMap t (nf_char2_formula sub_nf) ↔ nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf`.
Unfolding `nf_eval_nf` at `k+1` (per `nf_char3_eq_succ_iff`'s pattern, one arity down) gives two
layers on the **constant env `[t,t]`**:
- **atom layer**: `∀ a : AtomKind sig 2, atom_eval M (fun _=>t) a ↔ sub_nf.atom_assgn a` — a
  single-point predicate at `t` with all order atoms constant-false (`t<t`). This is the
  **diagonal depth-0 base**, discharged by `renameNF_eval_diag0` (arity-2→1 diagonal collapse, sound
  *at depth 0*).
- **quant layer**: `∀ qnf : NormalForm sig k 3, (∃ w, nf_eval_nf M k 3 (Fin.cons w (fun _=>t)) qnf)
  ↔ sub_nf.quant_assgn qnf` — for each `qnf`, a coupled **two-anchor bounded existential with both
  anchors collapsed to `t`** (env `[w,t,t]`). This is deliverable 2 specialized to `x=t`.

**Deliverable 2** `nf_zone_flatten_navigable` (arbitrary depth `k`):
`∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q ↔` a `bracketBuild` disjunction over `w`'s zones relative
to `(x,t)`, endpoints navigated, `w` a bracket witness. Recursion is on depth `k`.

### F2. H3 Source-to-Implementation Mapping Table (Tier 1 — Rabinovich 2014)

| Source (paper construct) | Lean identifier | File:line | Status (verified) | Notes |
|--------------------------|-----------------|-----------|-------------------|-------|
| Cor 5.4 `F_n := α_n` (chain terminus) | `nf_succ_char_formula` / `_correct` | KampPrior.lean:107 / 121 | sorry-free (body read); **arity-1 template** | The atom-part + quant-clause conjList pattern to mirror at arity 2 |
| Cor 5.4 `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` (Until nesting) | `bracketBuildRight` / `_correct` | VecEATranslation.lean:50 / 234 | **verified `[propext,Classical.choice,Quot.sound]`** | Future navigation; endpoint `TemporalPred` = next `F_i` |
| Cor 5.4 mirror (Since nesting, past) | `bracketBuildLeft` / `_correct` | VecEATranslation.lean:273 / 503 | sorry-free (file has 0 sorries) | Past navigation |
| Coupled quant layer `∃w, nf_eval M k (n+1) [w,env] sub` | `nf_characteristic_quant_succ` | NfZoneDepthK.lean:432 | sorry-free (body read) | Exposes the joint realizability set as an iff |
| Lemma 5.1 inner w-zone decomposition (7 zones at y,x,t) | `nf_characteristic_quant_split3` (+ `exists_nested_split3`:477) | NfZoneDepthK.lean:514 (477) | sorry-free (body read) | Nested trichotomy; degenerate orders tolerated |
| Full `char[y,x,t] = qnf` decomposition | `nf_char3_eq_succ_iff` (+ `nf_char_eq_iff_eval`:458) | NfZoneDepthK.lean:537 (458) | **verified `[propext,Classical.choice,Quot.sound]`** | atom-layer + quant-layer split for the endpoint `TemporalPred` |
| Base case (single-point degenerate) / diagonal endpoint collision | `renameNF_eval_diag0` | NfDepth0Generalized.lean:1646 | **verified `[propext,Classical.choice,Quot.sound]`** | Diagonal depth-0 iff; **depth-0 only** |
| Depth-0 constant-env duplication base | `diagDup` / `diagDup_eval_zero` | NfZoneFlattenNavigable.lean:229 / 243 | **verified `[propext,Classical.choice,Quot.sound]`** | Reuse verbatim; do not re-derive |
| Single-anchor x-trichotomy of `:391` RHS | `nf_zone_exists_trichotomy_k1` | NfZoneFlattenNavigable.lean:188 | sorry-free (body read) | Supplies past/diag/future disjuncts |
| Navigated future/past reach probes (D1-corrected) | `navigated_bracket_reaches_exterior_future`/`_past`, `nf_zone_flatten_navigable_k1_probe` | NfZoneFlattenNavigable.lean:66 / 88 / 130 | sorry-free (body read) | GO evidence that navigation reaches exterior-w |
| quant-clause wrapper (atom+quant conjunct) | `nf_quant_clause_tl` (+ `_correct`) | KampPrior.lean:78 | sorry-free (body read) | Reused for the arity-2 quant clauses |
| **Two-anchor characteristic FORMULA builder (deliverable 1)** | `nf_char2_formula` (to build) | new file | **does not exist — build sorry-free** | atom via diag0 base + quant via deliverable 2 |
| **Navigated bounded-existential corollary (deliverable 2)** | `nf_zone_flatten_navigable` (to build) | new file | **does not exist — build sorry-free** | recursion on depth `k` |
| Depth-lift of the diagonal congruence | — | NfDepth0Generalized.lean:1691-1719 | **non-theorem (sorry-free doc)** | Forbidden route (c) reduces here |
| Interior atomic bracket confinement | `interior_bracket_cannot_realize_exterior_sub_k1` | NfZoneDepthK1Probe.lean:143 | sorry-free | Forbidden route (b) refuted here |

### F3. File placement (off the live import path)

- `NfZoneFlattenNavigable.lean` is a **leaf** (grep confirms nothing imports it) and already imports
  `VecEATranslation` + `NfZoneDepthK` + `NfDepth0Generalized`. It hosts the deliverable-2 scaffolding
  (`nf_zone_exists_trichotomy_k1`, `diagDup`, navigated probes, `exterior_future_zone_eval_shape`).
- `KampPrior` imports only `ExistsForallNF`, `NfToVecEA`, `NfDepth0Generalized`, `KampTranslation`
  — it does **not** import `NfZoneDepthK`/`VecEATranslation`/`NfZoneFlattenNavigable`, so importing
  `KampPrior` into the new file is **cycle-free** (verified by grep of KampPrior imports).
- **Recommendation**: create a new sibling file (e.g.
  `Kamp/NfMultiAnchorBridge.lean`) importing `...Kamp.NfZoneFlattenNavigable` (transitively pulls
  the three deps) **and** `...Kamp.KampPrior` (for `nf_succ_char_formula`, `nf_quant_clause_tl`,
  `Separation.nf_depth0_char_formula`). Keep it a leaf (import nothing new). A new file (rather than
  extending `NfZoneFlattenNavigable.lean`, which carries 6 scaffolding sorries) keeps the
  sorry-free deliverable isolated and lets `lean_verify` run cleanly per declaration.

## Literature Proof Structure (Tier 1 — Rabinovich 2014, Cor 5.4 `F_i` chain)

Step map for the navigated bracket assembly (md:154-157, 159-173). Follow **step-by-step**; no
simp/omega shortcut of a chain step (lean4.md Literature Fidelity).

1. **Chain terminus (`F_n := α_n`)** — the innermost endpoint type is the depth-0/anchor point
   type (an `α`, a quantifier-free/atom characteristic). Lean: `nf_succ_char_formula` atom-part /
   `renameNF_eval_diag0` at the diagonal.
2. **Chain step (`F_{i-1} := α_{i-1} ∧ (β_i Until F_i)`)** — each outward step conjoins a point
   type `α_{i-1}` with a `Until`-navigated segment-type `β_i` whose target is the previous `F_i`.
   Lean: `bracketBuildRight` (future / `Until`) and `bracketBuildLeft` (past / `Since`), endpoint
   `TemporalPred := F_i`.
3. **Inner w-zone case decomposition (Lemma 5.1, md:159-169)** — the coupled `∃w` over the interior
   splits into the seven zones relative to the boundaries `y,x,t` (below/at/between for the three
   points). Lean: `nf_characteristic_quant_split3` (built on `exists_nested_split3`). For deliverable
   1's diagonal case (`x=t`), the two coincident boundaries collapse the split to **three** zones
   (`w<t`, `w=t`, `t<w`) via `exists_trichotomy_split`.
4. **Endpoint type = characteristic equality (md:157 "F_i are TL-definable")** — each navigated
   endpoint must encode `char[·] = qnf`, decomposed by `nf_char3_eq_succ_iff` into an atom-layer
   point predicate and a quant-layer that is itself step 3 one depth down. This is the **recursion
   on `k`**.
5. **Dedekind completeness (md:146-149, 222)** — used only at the INF/limit point; in this codebase
   it is already discharged inside the landed zone-partition assets, not re-derived here.

**Translation note per step**: the paper's `Until`/`Since` map to `Formula.untl`/`Formula.snce`
inside `bracketBuildRight`/`Left`; the paper's "increasing sequence in `(z0,z)`" maps to
`BracketFormula.holds`; the anchor cap "≤2 free variables" (Lemma 3.2.2, md:78) maps to the
invariant that the env arity never exceeds `{w,x,t}=3` and reduces to `{x,t}=2` when `w` is peeled.

## Construction Route — Deliverable 1 (`nf_char2_formula`)

Mirror `nf_succ_char_formula` (arity-1) at arity 2:

```
nf_char2_formula sub_nf :=
  formula_conjList (atom_part :: quant_clauses)
```

- **`atom_part`**: characterizes the diagonal atom layer of `sub_nf.1 : NormalForm sig 0 2` on the
  constant env `[t,t]`. Route: a depth-0 diagonal characteristic whose correctness is
  `renameNF_eval_diag0` (arity-2→1 diagonal collapse at depth 0). Order atoms are constant-false at
  `[t,t]`; predicate atoms reduce to the single point `t`. **This is the only place the diagonal
  collapse is used, and it is used at depth 0, where it is a proven iff.**
- **`quant_clauses`**: for each `qnf : NormalForm sig k 3`, `nf_quant_clause_tl (E qnf)
  (sub_nf.2 qnf)` where `E qnf : Formula` satisfies
  `temporal_truth M atomMap t (E qnf) ↔ ∃ w, nf_eval_nf M k 3 (Fin.cons w (fun _=>t)) qnf`.
  `E qnf` is **deliverable 2 at the diagonal `x=t`**: split `∃w` by the single boundary `t`
  (`exists_trichotomy_split`) into `w<t` / `w=t` / `t<w`; navigate the open zones with
  `bracketBuildLeft`/`bracketBuildRight` (endpoint = depth-`k` characteristic of `qnf` at the
  navigated `w`), and handle the `w=t` point zone by the depth-`k` recursion.

Correctness assembles exactly as `nf_succ_char_formula_correct`: `formula_conjList_iff` +
`nf_quant_clause_tl_correct` per clause + the diagonal atom-layer iff.

## Recursion Structure — Deliverable 2 (`nf_zone_flatten_navigable`)

- **Induction variable**: depth `k` (mutual with the depth-`k` characteristic-of-`[w,x,t]` formula
  builder). At `k=0` the endpoints are atom types (`renameNF_eval_diag0` / depth-0 char); at `k+1`
  the endpoints are themselves navigated brackets (the `F_i` chain), one depth down.
- **Zone split**: `∃w, nf_eval_nf M k 3 (zoneEnv3 w x t) q` splits by the two anchors `(x,t)` into
  five zones (`w<x`, `w=x`, `x<w<t`, `w=t`, `t<w`); degenerate anchor orders merely empty/overlap
  zones (a disjunction tolerates that). In the **diagonal** consumption (`x=t`) the five collapse to
  the **three** of `exists_trichotomy_split`. The deeper coupled layer (one recursion down, arity 4
  `[w',w,x,t]`) uses the **seven**-zone `nf_characteristic_quant_split3`.
- **Endpoint navigation**: each open zone `∃w, (bounds) ∧ nf_eval_nf M k 3 [w,x,t] q` becomes a
  `bracketBuild*` formula whose endpoint `TemporalPred` re-navigates from `w` back to the anchors
  `x,t` (nested `F_i` chain), and whose residual is discharged by the **depth-`k` IH**. The
  navigated-reach probes (`navigated_bracket_reaches_exterior_future`/`_past`,
  `nf_zone_flatten_navigable_k1_probe`, all sorry-free) already establish that navigation reaches
  the exterior-`w` and couples back — the precise capability D1 lacked.
- **IH discharge obligation**: for the endpoint at navigated `w`, `nf_char3_eq_succ_iff` reduces
  `char[w,x,t] = q` to an atom-point predicate (decidable at `w`, re-navigating to `x,t`) plus a
  quant layer `∀ sub, (∃w', nf_eval M (k-1) 4 [w',w,x,t] sub) ↔ q.quant_assgn sub` that is the same
  bridge one depth down (arity stays ≤ `{w',w,x,t}`; anchor set of the *outer* formula stays
  `{x,t}`). This is the arity-invariance that keeps it within Rabinovich's ≤2 free-variable cap.

## Adversarial Self-Verification

Applied the Claim Verification Bar to every load-bearing claim. `Verification Method` uses the
lean4 domain values (`lean_verify axiom profile`, `lean_local_search / grep hit`, `source read of
sorry-free proof body`, `deductive`).

| Claim | Source/Counterexample | Verification Method | Confidence |
|-------|------------------------|---------------------|------------|
| `bracketBuildRight_correct`, `renameNF_eval_diag0`, `nf_char3_eq_succ_iff`, `diagDup_eval_zero` all carry axioms exactly `[propext,Classical.choice,Quot.sound]` | four `lean_verify` runs, all `{"axioms":[…],"warnings":[]}` | lean_verify axiom profile | High |
| The three NfZoneDepthK theorems (`nf_characteristic_quant_succ`, `_split3`, `nf_char3_eq_succ_iff`) are sorry-free | proof bodies read NfZoneDepthK.lean:432-548 (no `sorry` token in any body); file's 14 sorries lie elsewhere | source read of sorry-free proof body | High |
| `bracketBuildLeft`/`Right` (+`_correct`) sorry-free | VecEATranslation.lean has **0** sorries (grep `-c sorry` = 0) | grep hit | High |
| `nf_zone_exists_trichotomy_k1`, `diagDup`, `diagDup_eval_zero`, navigated probes sorry-free | bodies read NfZoneFlattenNavigable.lean:188-249, 66-140 (delegated to `exists_trichotomy_split`/`renameNF_eval_diag0`/`bracketBuild*_correct`) | source read of sorry-free proof body | High |
| Route does **not** reduce to forbidden (c) arity-1 collapse | (c) collapses the whole `sub_nf` incl. quant layer via `diagDup`/`liftIdx r` at depth `k+1`; our route applies the diagonal collapse **only to the depth-0 atom layer** (`renameNF_eval_diag0`), and discharges the depth-`(k+1)` quant layer via the arity-3 navigated existential (deliverable 2), never collapsing arity | deductive from NfDepth0Generalized.lean:1691-1719 (the exact non-theorem) | High |
| Route does **not** reduce to forbidden (b) flat atomic bracket | endpoint types are **navigated** recursive `bracketBuild*` `TemporalPred`s (not depth-0 atomic `BracketFormula` confined to `[x,t]`); `navigated_bracket_reaches_exterior_future` proves the navigated bracket reaches exterior `t<w`, the exact content D1's `interior_bracket_cannot_realize_exterior_sub_k1` forbids to the atomic bracket | deductive + source read (probes vs NfZoneDepthK1Probe.lean:143) | High |
| Route does **not** reduce to forbidden (a) projection VecEA2 | the coupled `∃w` is split **directly** on the full env `[w,x,t]` via `exists_nested_split3`/`exists_trichotomy_split` and discharged through `nf_char3_eq_succ_iff`'s joint decomposition — no per-variable projection of the coupled quant layer; `liftIdx(totalUnskip)` non-injectivity is never relied upon for a `←` factoring | deductive from task-307 report 02 §2.1 + NfZoneDepthK.lean:514-548 | High |
| Diagonal disjunct is the target of deliverable 1 and is NOT the R2 arity-tower | free-anchor count at top = 1 (`t`); `w` bound as a navigated bracket witness, never a named env position; env arity ≤ `{w,x,t}=3` reducing to `{x,t}=2` (Rabinovich ≤2 cap, md:78) | source read (KampPrior.lean:387-391 arm) + Rabinovich md:78,154-157 | High |
| Importing `KampPrior` into the new leaf file is cycle-free | `KampPrior` imports `{ExistsForallNF,NfToVecEA,NfDepth0Generalized,KampTranslation}` only — none of the zone files; grep confirms | grep hit | High |
| New file stays off the live import path | `NfZoneFlattenNavigable` has **zero** importers (grep `-rl` empty); a new sibling importing only it + KampPrior is likewise a leaf | grep hit | High |
| `:391` `sub_nf` is universally quantified (no exploitable structure) | KampPrior.lean:256 `(sub_nf : NormalForm sig k (n+1)) → ∃A,…`; match arm `k+1,1,sub_nf` | source read of signature (corroborates task-307 report 02 §1.1) | High |
| Estimated size ~400-700 lines | codebase self-scoping (NfZoneDepthK.lean:131-132; task-307 report 02) | source read (codebase estimate) | Medium |
| Deliverable 1's diagonal quant clause `E qnf` = deliverable 2 at `x=t` (so 1 depends on 2's machinery) | F1 layer unfolding; `[w,t,t]` is `[w,x,t]` with `x:=t` | deductive | Medium-High |

**Contradiction Log**: None unresolved. Apparent tension "diagonal collapse is forbidden (c) yet
the route uses `renameNF_eval_diag0`" resolves cleanly by the **depth stratification**: (c) is the
forbidden depth-`(k+1)` *quant-layer* collapse (the documented non-theorem); the route uses the
diagonal collapse only at the depth-0 *atom layer*, where `renameNF_eval_diag0` is a verified iff.
These are different obligations; no contradiction.

**Forbidden-output check**: No "mathlib likely has this" claim (this is a codebase-internal
construction, not a Mathlib lookup). No sorry-deferral, no `def X := True` vacuous pattern, no new
axiom recommended — the deliverables are concrete sorry-free obligations targeting the verified
baseline axiom set. First verified asset (`lean_verify` hit) occurred well within the first 30% of
tool calls (H2 satisfied).

**Recommendations modified after verification**: none reversed; the depth-stratification
distinction (atom-layer diag0 vs. quant-layer non-collapse) was sharpened during verification and is
now the load-bearing discriminator against route (c).

## Key Risks

- **R-A (Medium)**: This is the object task-305 Phase-11b failed three times (projection VecEA2 /
  atomic D1 / arity-1 collapse). *Mitigation*: the route is explicitly checked against all three in
  the H4 table; the depth-0-only confinement of the diagonal collapse is the concrete guardrail.
  Implementation must run `--hard` with the (a)/(b)/(c) "Do NOT" list.
- **R-B (Medium)**: Size (~400-700 lines) may exceed one dispatch and the recursion is mutual
  (char-of-`[w,x,t]` ↔ zone-flatten). *Mitigation*: phase-decompose — land `nf_char2_formula`'s
  atom-layer + a `k=0` base first (unblocks task-307 Phase 3 minimally), then the general navigated
  `nf_zone_flatten_navigable` recursion.
- **R-C (Low-Medium)**: The mutual recursion's termination (on `k`) must be structural; the
  endpoint `TemporalPred` at navigated `w` re-references anchors `x,t`, which must be encoded by
  nested navigation, not by growing the env arity. *Mitigation*: enforce the arity-≤3 invariant
  as an explicit lemma statement; `nf_characteristic_quant_split3` already keeps arity at 4 one
  level down without growth.
- **R-D (Low)**: Coupling to task 305 — build once, hand back consumption notes so task-305
  Phase-11b rewires to reuse rather than rebuild.

## Recommended Next Action

`/plan 308` — phase-decompose the two deliverables: (P1) diagonal atom-layer + `k=0` base of
`nf_char2_formula`; (P2) diagonal quant clauses via `exists_trichotomy_split` + navigated brackets;
(P3) general `nf_zone_flatten_navigable` recursion on `k` with the `F_i` chain; (P4) assemble
`nf_char2_formula` and its `_correct`; verify axioms `= [propext, Classical.choice, Quot.sound]`.
