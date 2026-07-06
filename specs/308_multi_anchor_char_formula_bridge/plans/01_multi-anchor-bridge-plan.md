# Implementation Plan: Multi-Anchor Characteristic Formula Bridge (task 308)

- **Task**: 308 - multi_anchor_char_formula_bridge
- **Status**: [IMPLEMENTING]
- **Effort**: 10-15 hours (6 phases, ~1.5-3 h each)
- **Dependencies**: None (all preserved assets already landed; off the live import path)
- **Research Inputs**: reports/01_multi-anchor-bridge-research.md (H4-verified, Tier 1 Rabinovich 2014)
- **Artifacts**: plans/01_multi-anchor-bridge-plan.md (this file)
- **Standards**:
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/rules/git-workflow.md
- **Type**: lean4

## Overview

Build one reusable, sorry-free object — the depth-graded two-anchor characteristic **formula**
builder — in a new leaf file `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`
(module `Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge`), importing
`...Kamp.NfZoneFlattenNavigable` (transitively pulls VecEATranslation + NfZoneDepthK +
NfDepth0Generalized) and `...Kamp.KampPrior` (for `nf_succ_char_formula`, `nf_quant_clause_tl`,
`nf_depth0_char_formula`). The file must remain a leaf — nothing imports it, and it imports nothing
new — so `lean_verify` runs cleanly per declaration and both deliverables stay off the live import
path. Two deliverables (diagonal-first per R-B): (1) `nf_char2_formula : NormalForm sig (k+1) 2 →
Formula` with correctness iff against the diagonal/constant two-anchor env `[t,t]`; (2) the general
navigated bounded-existential corollary `nf_zone_flatten_navigable` at arbitrary depth `k`,
recursion on `k`. Definition of done: both deliverables sorry-free, `lake build` GREEN, axioms
**exactly `[propext, Classical.choice, Quot.sound]`** on both, and an R-C consumption-notes summary
for task 305 written under `summaries/`.

### Research Integration

- Integrated report: `reports/01_multi-anchor-bridge-research.md` (plan_version 1, 2026-07-06).
- Chosen construction route (F1/F2/F3), the H3 source-to-implementation mapping (F2), the Rabinovich
  Cor 5.4 `F_i` chain step map, and the adversarial refutation of forbidden routes (a)/(b)/(c) are
  carried into the phase design below.

### Source-to-Implementation Mapping (H3, Tier 1 — Rabinovich 2014, Cor 5.4 `F_i` chain)

| Source (paper construct) | Lean identifier | File:line | Consumed in phase |
|--------------------------|-----------------|-----------|-------------------|
| Cor 5.4 `F_n := α_n` (chain terminus / atom endpoint) | `nf_succ_char_formula` (arity-1 template), `nf_depth0_char_formula` | KampPrior.lean:107 / (Separation) | P1, P3 |
| Base diagonal endpoint collision (depth-0 iff) | `renameNF_eval_diag0` | NfDepth0Generalized.lean:1646 | P1 |
| Depth-0 constant-env duplication base (reuse verbatim) | `diagDup` / `diagDup_eval_zero` | NfZoneFlattenNavigable.lean:229 / 243 | P1 |
| Cor 5.4 `F_{i-1} := α_{i-1} ∧ (β_i Until F_i)` (future nav) | `bracketBuildRight` / `_correct` | VecEATranslation.lean:50 / 234 | P2, P4 |
| Cor 5.4 mirror (Since nesting, past nav) | `bracketBuildLeft` / `_correct` | VecEATranslation.lean:273 / 503 | P2, P4 |
| Single-anchor x-trichotomy (past/diag/future split of `:391` RHS) | `nf_zone_exists_trichotomy_k1`, `exists_trichotomy_split` | NfZoneFlattenNavigable.lean:188 | P2 |
| Coupled quant layer `∃w, nf_eval M k (n+1) [w,env] sub` as iff | `nf_characteristic_quant_succ` | NfZoneDepthK.lean:432 | P4 |
| Lemma 5.1 inner w-zone decomposition (7 zones) | `nf_characteristic_quant_split3` (+ `exists_nested_split3`:477) | NfZoneDepthK.lean:514 | P4 |
| Full `char[y,x,t]=qnf` atom+quant decomposition | `nf_char3_eq_succ_iff` (+ `nf_char_eq_iff_eval`:458) | NfZoneDepthK.lean:537 | P4, P5 |
| quant-clause wrapper (atom+quant conjunct) | `nf_quant_clause_tl` (+ `_correct`) | KampPrior.lean:78 | P3 |
| Navigated future/past reach probes (GO evidence) | `navigated_bracket_reaches_exterior_future`/`_past`, `..._k1_probe` | NfZoneFlattenNavigable.lean:66 / 88 / 130 | P4 |
| **Deliverable 1 (to build)** | `nf_char2_formula` / `_correct` | NfMultiAnchorBridge.lean (new) | P3 |
| **Deliverable 2 (to build)** | `nf_zone_flatten_navigable` / `_correct` | NfMultiAnchorBridge.lean (new) | P4, P5 |

## Postmortem Constraints

Binding rules for all implementation dispatches. Every implementing agent MUST read this block
in-phase before writing any construction. Derived from three prior refutations in the task-305
Phase-11b lineage and the task-307 blocker audit.

**Do NOT** (the forbidden-route list — check every candidate construction against this before coding):
- **(a) Do NOT re-attempt a projection-based VecEA2 bridge for the `x=t` diagonal case.**
  `liftIdx(totalUnskip)` is non-injective, so the coupled quant layer does **not** factor through
  per-variable projections. The coupled `∃w` must be split **directly** on the full env `[w,x,t]`
  (via `exists_nested_split3` / `exists_trichotomy_split`) and discharged through
  `nf_char3_eq_succ_iff`'s joint decomposition — never per-variable projection. (Refuted: task-307
  report 02 §2.1; NfZoneDepthK.lean:514-548.)
- **(b) Do NOT re-attempt a flat single-interval atomic bracket absorption (D1 flat-bracket).**
  A depth-0 atomic `BracketFormula` is confined to the closed interval `[x,t]` and cannot capture
  exterior-`w` realizability. Endpoint types MUST be **navigated** recursive `bracketBuild*`
  `TemporalPred`s, not depth-0 atomic brackets. (Refuted sorry-free by
  `interior_bracket_cannot_realize_exterior_sub_k1`, NfZoneDepthK1Probe.lean:143; positive capability
  proven by `navigated_bracket_reaches_exterior_future`.)
- **(c) Do NOT re-attempt an arity-1-collapse repair for the diagonal arm**
  (`char_k1 (diagCollapse sub_nf)`). This reduces to the depth-`(k+1)` lift of `diagDup_eval_zero`,
  documented sorry-free as a **non-theorem** (NfDepth0Generalized.lean:1691-1719; `liftIdx r` is
  non-injective, the `←` direction fails). This route BINDS at the actual `:391` obligation because
  `sub_nf` there is universally quantified.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- The diagonal collapse (`renameNF_eval_diag0`) is used **only at the depth-0 atom layer**, where it
  is a proven iff. The depth-`(k+1)` quant layer is discharged through the honest arity-3 navigated
  existential (deliverable 2), **never collapsed to arity-1**. This depth stratification is the
  load-bearing discriminator against route (c). (Report §Contradiction Log.)
- File placement is a new leaf `NfMultiAnchorBridge.lean` (NOT an extension of
  `NfZoneFlattenNavigable.lean`, which carries scaffolding sorries) — keeps the sorry-free
  deliverables isolated for clean per-declaration `lean_verify`.
- The env-arity invariant is `≤ {w,x,t} = 3`, reducing to `{x,t} = 2` when `w` is peeled; the outer
  formula's anchor set stays `{x,t}` (Rabinovich ≤2 free-variable cap, Lemma 3.2.2 / md:78). Endpoint
  re-reference to anchors is encoded by **nested navigation**, never by growing env arity.

**MUST preserve** (consume verbatim; do NOT re-derive or overwrite):
- `nf_char3_eq_succ_iff`, `nf_characteristic_quant_split3`, `nf_characteristic_quant_succ`
  (NfZoneDepthK.lean, sorry-free).
- `renameNF_eval_diag0` (NfDepth0Generalized.lean:1646, sorry-free).
- `bracketBuildLeft` / `bracketBuildRight` (+ `_correct`, VecEATranslation.lean, 0 sorries).
- `nf_succ_char_formula` / `_correct`, `nf_quant_clause_tl` / `_correct` (KampPrior.lean, arity-1
  templates + wrapper).
- `diagDup` / `diagDup_eval_zero`, `nf_zone_exists_trichotomy_k1`, navigated reach probes
  (NfZoneFlattenNavigable.lean, sorry-free).
- The verified baseline axiom set `[propext, Classical.choice, Quot.sound]` — introduce **no new
  axiom**, leave **no sorry**.

### Preserved Assets

The following work is complete, sorry-free, and must not regress. Deliverables consume these.

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| `nf_char3_eq_succ_iff`, `nf_char_eq_iff_eval` | NfZoneDepthK.lean:537 / 458 | [COMPLETED] | lean_verify = baseline (report H4) |
| `nf_characteristic_quant_split3`, `nf_characteristic_quant_succ`, `exists_nested_split3` | NfZoneDepthK.lean:514 / 432 / 477 | [COMPLETED] | source read sorry-free (report H4) |
| `renameNF_eval_diag0` | NfDepth0Generalized.lean:1646 | [COMPLETED] | lean_verify = baseline (report H4) |
| `bracketBuildLeft`/`Right` (+ `_correct`) | VecEATranslation.lean:50/234/273/503 | [COMPLETED] | grep 0 sorries; lean_verify = baseline (report H4) |
| `nf_succ_char_formula`/`_correct`, `nf_quant_clause_tl`/`_correct`, `nf_depth0_char_formula` | KampPrior.lean:107/121/78 | [COMPLETED] | source read sorry-free (report H4) |
| `diagDup`/`diagDup_eval_zero`, `nf_zone_exists_trichotomy_k1`, `exists_trichotomy_split`, navigated reach probes | NfZoneFlattenNavigable.lean:229/243/188/66/88/130 | [COMPLETED] | lean_verify = baseline / source read (report H4) |

## Goals & Non-Goals

- **Goals**:
  - Deliverable 1: `nf_char2_formula : NormalForm sig (k+1) 2 → Formula` + `nf_char2_formula_correct`
    (iff against `nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf`), sorry-free.
  - Deliverable 2: `nf_zone_flatten_navigable` at arbitrary depth `k` (recursion on `k`) + `_correct`,
    sorry-free.
  - Both carry axioms exactly `[propext, Classical.choice, Quot.sound]`; `lake build` GREEN.
  - R-C consumption-notes summary for task 305.
- **Non-Goals**:
  - Do NOT touch the live import path (KampPrior consumers, Completeness terminus). New file is a leaf.
  - Do NOT rebuild or modify any preserved asset.
  - Do NOT resume task 307 Phases 3-6 here (this task only supplies their prerequisite).
  - Do NOT re-derive Dedekind completeness (already discharged inside landed zone-partition assets).

## Risks & Mitigations

- **R-A (Medium — recurring failure object)**: This is the object task-305 Phase-11b failed three
  times. *Mitigation*: the Postmortem Constraints (a)/(b)/(c) block is in-phase; every phase exit
  criterion requires `lean_verify` on the landed lemma so a silent collapse to a forbidden route
  cannot pass unnoticed (a forbidden route would fail to close sorry-free at the `:391`-shaped
  obligation).
- **R-B (Medium — size/mutual recursion)**: ~400-700 lines, mutual recursion (char-of-`[w,x,t]` ↔
  zone-flatten). *Mitigation*: 6 bounded phases, diagonal-first; deliverable 1 (P1-P3) lands and
  unblocks task-307 Phase 3 before the general recursion (P4-P5) is attempted. The recursion hook is
  already exposed by the arity-1 template `nf_succ_char_formula` (takes `exist_tl_fn : NormalForm sig
  k 2 → Formula`), so the arity-2 builder mirrors it with `exist_tl_fn : NormalForm sig k 3 → Formula`.
- **R-C (Low-Medium — termination)**: mutual recursion must be structurally terminating on `k`;
  endpoint `TemporalPred` at navigated `w` must re-reference anchors by nested navigation, not by
  growing env arity. *Mitigation*: P4 states the arity-≤3 invariant as an explicit named lemma;
  `nf_characteristic_quant_split3` already keeps arity at 4 one level down without growth.
- **R-D (Low — task-305 coupling)**: build once, hand back consumption notes. *Mitigation*: P6
  writes the R-C summary with exact signatures and rewire guidance.
- **Territory (H7)**: all construction lands in the single new file `NfMultiAnchorBridge.lean`.
  Phases are serialized (one dispatch owns the file at a time) even where logically parallel, to
  avoid write collisions.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases are fully sequential. P3 (deliverable-1 assembly) and P4 (general-recursion helpers) are
logically independent given P2, but both write the single leaf file `NfMultiAnchorBridge.lean`, so
they are serialized under the H7 single-file territory contract (no parallel wave).

### Phase 1: File scaffold + diagonal depth-0 atom layer + k=0 zone-flatten base [COMPLETED]
- **Goal:** Stand up the new leaf file and land the two bottom-of-recursion sorry-free lemmas: the
  diagonal atom-layer iff at `[t,t]`, and the `k=0` base of the zone-flatten (endpoints are atom
  types, no navigation yet).
- **Tasks:**
  - [x] Create `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` with module
    docstring, `import Bimodal.Metalogic.WeakCanonical.Kamp.NfZoneFlattenNavigable` and
    `import Bimodal.Metalogic.WeakCanonical.Kamp.KampPrior` (import nothing else — keep it a leaf).
  - [x] Paste the Postmortem forbidden-route (a)/(b)/(c) "Do NOT" list as a top-of-file block comment
    so every future dispatch sees it in-file.
  - [x] Land `nf_char2_atom_layer` *(deviation: altered — stated as the diagonal atom-layer iff for
    the value-duplicated form `diagDup nf1` (`nf1 : NormalForm sig 0 2`→1), the exact `renameNF_eval_diag0`
    /`diagDup_eval_zero` base; the arbitrary-`sub_nf.1` order-atom / pred-agreement guard is deferred to
    the Phase-3 assembly where the `atom_part` formula is built. Uses `nf_depth0_char_formula` +
    `diagDup_eval_zero` verbatim, diagonal collapse at depth-0 atom layer only.)*
  - [x] Land `nf_zone_flatten_navigable_zero`: the `k=0` base case of deliverable 2 (endpoints are
    atom/anchor types via `renameNF_eval_diag0` / depth-0 char; no `bracketBuild*` navigation yet)
    *(realized via the tail-diagonal duplication `diagDup3`/`diagDup3_eval_zero`, a direct
    `renameNF_eval_diag0` instance, wrapped existentially.)*
  - [x] `lake build` the new file green.
- **Timing:** ~1.5-2 h. **Estimated output:** ~150-250 lines.
- **Depends on:** none.
- **Done when:** file `lake build`s green; `nf_char2_atom_layer` and `nf_zone_flatten_navigable_zero`
  are sorry-free; `lean_verify` on both returns axioms exactly `[propext, Classical.choice,
  Quot.sound]`. No forbidden route (a)/(b)/(c) used (atom layer uses diag collapse at depth 0 ONLY).

### Phase 2: Diagonal quant-clause converter (deliverable 2 at x=t, three-zone) [COMPLETED]
- **Goal:** Land the diagonal existential converter `nf_char2_diag_exist_tl : NormalForm sig k 3 →
  Formula` with correctness `temporal_truth M atomMap t (nf_char2_diag_exist_tl qnf) ↔ ∃ w,
  nf_eval_nf M k 3 (Fin.cons w (fun _=>t)) qnf` — deliverable 2 specialized to `x=t`. This is the
  recursion hook consumed by `nf_char2_formula` in P3.
- **Tasks:**
  - [x] Split `∃w` by the single boundary `t` via `exists_trichotomy_split` /
    `nf_zone_exists_trichotomy_k1` into `w<t` / `w=t` / `t<w`. *(used the generic
    `exists_trichotomy_split` at `P w := nf_eval_nf M k 3 (Fin.cons w (fun _=>t)) qnf`, `c := t`.)*
  - [x] Navigate the two open zones with `bracketBuildLeft` (past `w<t`, `Since`) and
    `bracketBuildRight` (future `t<w`, `Until`); endpoint `TemporalPred` = the depth-`k`
    characteristic of `qnf` at the navigated `w` (recursion hook — at `k=0` bottoms out in P1's base).
    *(deviation: altered — realized via `navigated_bracket_reaches_exterior_past`/`_future` with the
    endpoint `TemporalPred`s supplied as PARAMETRIC HOOKS `pastEnd`/`futureEnd`, exactly mirroring how
    the arity-1 template `nf_succ_char_formula` is parametric over `exist_tl_fn`. The endpoint
    characteristic builder for arity-3 NFs does not exist as an asset — NfZoneFlattenNavigable.lean:275-282
    documents this sorry-free — so it is the recursion interface Phases 4-5 supply, not built in-phase.)*
  - [x] Handle the `w=t` point zone via the depth-`k` diagonal characteristic (P1 base at `k=0`).
    *(supplied as the parametric hook `diagChar` with its correctness hypothesis `h_diag`.)*
  - [x] Assemble correctness from `bracketBuildLeft_correct` / `bracketBuildRight_correct` +
    the trichotomy split; endpoints are NAVIGATED brackets (route (b) guard), never per-variable
    projections (route (a) guard), never arity-collapsed (route (c) guard).
  - [x] `lake build` green.
- **Timing:** ~2-3 h. **Estimated output:** ~200-320 lines.
- **Depends on:** 1.
- **Done when:** `nf_char2_diag_exist_tl` + its `_correct` are sorry-free; `lean_verify` on `_correct`
  returns exactly `[propext, Classical.choice, Quot.sound]`; `lake build` green. Endpoint types are
  navigated `bracketBuild*` `TemporalPred`s (confirm against route (b)).

### Phase 3: Assemble `nf_char2_formula` + `_correct` (Deliverable 1 COMPLETE) [NOT STARTED]
- **Goal:** Build deliverable 1 by mirroring `nf_succ_char_formula` (arity-1) at arity 2, and prove
  its correctness against the diagonal/constant env `[t,t]`. Completing this phase unblocks task 307
  Phase 3.
- **Tasks:**
  - [ ] Define `nf_char2_formula sub_nf := formula_conjList (atom_part :: quant_clauses)` where
    `atom_part` is P1's diagonal atom characteristic and each `quant_clause` is
    `nf_quant_clause_tl (nf_char2_diag_exist_tl qnf) (sub_nf.2 qnf)` for `qnf : NormalForm sig k 3`
    (mirroring the KampPrior template exactly, one arity up).
  - [ ] Prove `nf_char2_formula_correct`:
    `temporal_truth M atomMap t (nf_char2_formula sub_nf) ↔ nf_eval_nf M (k+1) 2 (fun _=>t) sub_nf`
    via `formula_conjList_iff` + `nf_quant_clause_tl_correct` per clause + P1 atom-layer iff + P2
    diagonal quant iff (unfold `nf_eval_nf` at `k+1` per `nf_char3_eq_succ_iff`'s pattern).
  - [ ] `lake build` green.
- **Timing:** ~1.5-2.5 h. **Estimated output:** ~120-220 lines.
- **Depends on:** 2 (serialized after 2; consumes P1 + P2).
- **Done when:** `nf_char2_formula` and `nf_char2_formula_correct` are sorry-free; `lean_verify` on
  both returns exactly `[propext, Classical.choice, Quot.sound]`; `lake build` green. Deliverable 1
  is complete and task-307 Phase 3 is unblocked.

### Phase 4: General zone-flatten decomposition helpers (five-zone + arity invariant + deeper layer) [NOT STARTED]
- **Goal:** Land the named sorry-free helper lemmas for the arbitrary-`(x,t)` case that P5 assembles:
  the five-zone split, the arity-≤3 invariance lemma, and the deeper coupled-layer decomposition via
  `nf_characteristic_quant_split3`.
- **Tasks:**
  - [ ] State and prove the arity-invariance lemma: the env arity of the navigated existential never
    exceeds `{w,x,t}=3`, reducing to `{x,t}=2` when `w` is peeled; anchor set of the outer formula
    stays `{x,t}` (Rabinovich ≤2 cap). This is the R-C termination guardrail.
  - [ ] Land the five-zone split of `∃w, nf_eval_nf M k 3 (zoneEnv3 w x t) q` over `(x,t)`
    (`w<x`, `w=x`, `x<w<t`, `w=t`, `t<w`) via `exists_nested_split3`, tolerating degenerate anchor
    orders (a disjunction empties/overlaps zones harmlessly).
  - [ ] Land the deeper coupled-layer decomposition one recursion down (arity-4 `[w',w,x,t]`) via
    `nf_characteristic_quant_split3` (seven zones) + `nf_char3_eq_succ_iff`, discharging the endpoint
    `char[w,x,t]=q` into an atom-point predicate + a quant layer that is the same bridge one depth
    down. Endpoints re-navigate to anchors via nested `bracketBuild*` (route (b) guard); use
    navigated reach probes (`navigated_bracket_reaches_exterior_future`/`_past`) as the exterior-`w`
    coupling evidence.
  - [ ] `lake build` green.
- **Timing:** ~2.5-3 h. **Estimated output:** ~250-380 lines.
- **Depends on:** 3 (serialized under single-file territory; logically depends on P1 + P2 machinery).
- **Done when:** the arity-invariance lemma, the five-zone split lemma, and the deeper coupled-layer
  lemma are each sorry-free and named; `lean_verify` on each returns exactly `[propext,
  Classical.choice, Quot.sound]`; `lake build` green. No forbidden route used (coupled `∃w` split
  directly on full env, not projected — route (a) guard).

### Phase 5: Assemble `nf_zone_flatten_navigable` + `_correct` (Deliverable 2 COMPLETE) [NOT STARTED]
- **Goal:** Assemble the general navigated bounded-existential corollary at arbitrary depth `k`
  (recursion on `k`, structurally terminating) from the P4 helpers, and prove its correctness iff.
  Completing this phase unblocks task 307 Phases 4/5/6.
- **Tasks:**
  - [ ] Define `nf_zone_flatten_navigable` at arbitrary `k` as the `bracketBuild` disjunction over
    `w`'s five zones relative to `(x,t)`, endpoints navigated, `w` a bracket witness; recurse on `k`
    with `k=0` bottoming out in P1's `nf_zone_flatten_navigable_zero`.
  - [ ] Prove `nf_zone_flatten_navigable_correct`:
    `(∃ w, nf_eval_nf M k 3 (zoneEnv3 w x t) q) ↔ (the bracketBuild disjunction)` via the P4 five-zone
    split, `bracketBuildLeft`/`Right_correct` per open zone, and the depth-`k` IH for each residual.
  - [ ] Confirm structural termination on `k` and the arity-≤3 invariant (P4 lemma) throughout.
  - [ ] `lake build` green.
- **Timing:** ~2-3 h. **Estimated output:** ~180-300 lines.
- **Depends on:** 4.
- **Done when:** `nf_zone_flatten_navigable` and `nf_zone_flatten_navigable_correct` are sorry-free;
  recursion on `k` is structurally terminating; `lean_verify` on both returns exactly `[propext,
  Classical.choice, Quot.sound]`; `lake build` green. Deliverable 2 is complete.

### Phase 6: Axiom verification, full build, R-C consumption-notes summary [NOT STARTED]
- **Goal:** Final verification of both deliverables and the R-C hand-off to task 305.
- **Tasks:**
  - [ ] Run `lean_verify` on `nf_char2_formula`, `nf_char2_formula_correct`,
    `nf_zone_flatten_navigable`, `nf_zone_flatten_navigable_correct` — each must return axioms
    **exactly** `[propext, Classical.choice, Quot.sound]` with no warnings.
  - [ ] Run a full `lake build` (whole project) and confirm GREEN; confirm `NfMultiAnchorBridge.lean`
    has zero importers (still a leaf, off the live import path) via grep.
  - [ ] Confirm zero `sorry` tokens in `NfMultiAnchorBridge.lean` (grep `-c sorry` = 0).
  - [ ] Write `specs/308_multi_anchor_char_formula_bridge/summaries/01_multi-anchor-bridge-summary.md`
    with the R-C consumption notes: exact signatures of `nf_char2_formula` and
    `nf_zone_flatten_navigable` (with module path), which task-305 artifacts/plans reference the
    Phase-11b bridge and should be rewired to reuse these definitions verbatim rather than rebuild,
    and the depth/anchor-count assumptions the task-305 rewire must respect (env arity ≤ 3 → 2,
    anchor set `{x,t}`, Rabinovich ≤2 free-variable cap).
- **Timing:** ~1-1.5 h. **Estimated output:** summary doc + verification (minimal Lean).
- **Depends on:** 5.
- **Done when:** all four `lean_verify` runs show exactly the baseline axiom set with no warnings;
  full `lake build` GREEN; file confirmed leaf with 0 sorries; the R-C summary exists and documents
  signatures + task-305 rewire guidance.

## Testing & Validation

- [ ] `lake build` GREEN after every phase (incremental commit at each green phase per H9).
- [ ] `lean_verify` on each load-bearing lemma at the phase where it lands = `[propext,
  Classical.choice, Quot.sound]`, no warnings.
- [ ] Final: `lean_verify` on all four deliverable declarations = baseline axiom set.
- [ ] `grep -c sorry NfMultiAnchorBridge.lean` = 0.
- [ ] `grep -rl NfMultiAnchorBridge Theories` shows no importer (leaf / off live import path).
- [ ] Route audit per phase: confirm no construction reduces to forbidden (a)/(b)/(c) — endpoints are
  navigated brackets, coupled `∃w` split directly on full env, diagonal collapse used at depth-0 atom
  layer only.

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean` (new leaf; both deliverables)
- `specs/308_multi_anchor_char_formula_bridge/plans/01_multi-anchor-bridge-plan.md` (this file)
- `specs/308_multi_anchor_char_formula_bridge/summaries/01_multi-anchor-bridge-summary.md` (P6, R-C notes)

## Rollback/Contingency

- The new file is a leaf with zero importers: if a phase cannot be landed sorry-free, the file can be
  reverted (or the phase's lemmas left `[PARTIAL]`) with **no effect on the live build** — nothing
  downstream imports it. No preserved asset is modified, so rollback is confined to
  `NfMultiAnchorBridge.lean`.
- If a phase overruns one dispatch (H8 breach), mark it `[PARTIAL]`, commit the green prefix, and
  resume; do NOT introduce a sorry to force a green — per the recovery ladder, fix forward. If a
  genuine strategic-sorry division point emerges, it must be pre-declared (this plan declares none;
  any implementer-placed sorry is a plan-unanticipated deviation and must be flagged in the summary).
- Never discard uncommitted changes to reach a passing build (git-workflow.md "No Destructive Git on
  Uncommitted Work").
