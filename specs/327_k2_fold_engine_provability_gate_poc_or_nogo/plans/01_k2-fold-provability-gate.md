# Implementation Plan: k2 Outer Quant-Layer Fold — Provability GATE (PoC or NO-GO)

- **Task**: 327 - P1 provability GATE for `nf_quant_layer_fold_k2_gate` (depth-2 outer quant-layer fold)
- **Status**: [NOT STARTED]
- **Effort**: 4-8 hours (make-or-break; may terminate early with NO-GO)
- **Dependencies**: None (this task GATES its own downstream P2/P3; they must NOT start until this returns GO)
- **Research Inputs**: specs/321_implement_corrected_k2_carrier_and_close_the_correctness_gate_f4_resolution/reports/05_remaining-k2-gate-architecture.md
- **Artifacts**: plans/01_k2-fold-provability-gate.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/lean4.md
- **Type**: lean4

## Overview

This is a **provability GATE** (task 321's P1). It decides ONE make-or-break question for the entire
k=2 carrier route: **does the depth-2 outer quant-layer fold `nf_quant_layer_fold_k2_gate`
(arity-4/depth-1 analog of the landed `nf_quant_layer_fold_k1_gate`, NfEFold:525) fold CLEANLY, and
by WHICH route** — (a) naive `nfk`-split-kit factorization via `nf_eval_nf1_cons_factor`, (b) the
constant-arity E[Σ] `efold_of_nfk` route (outer analog of `nf_eval_nf1_iff_efold`, NfEFold:490), or
(c) a new argument. The deliverable is EITHER a proven proof-of-concept skeleton certifying the route,
OR a **machine-grounded NO-GO** with the exact failing goal state. All work is **purely additive** to a
single file: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`.

The gate exists because a naive `0 → 1` textual lift is **known-blocked**: it re-invokes the
arity-4 → arity-3 / G6 re-bounding barrier documented at `NfMultiAnchorBridge.lean:1622-1646`, and the
naive `nf_eval_nf1_cons_factor` is likely FALSE in clean form (the inner quant layer couples the outer
witness `x1` to `zoneHolds M (Fin.cons x env) zs x1` — genuine cross-content that does not distribute
across the outer `∃x1`). This gate isolates the whole route's residual **F4-flattening-relapse risk**.
If NO-GO, the entire carrier route needs fundamental reconsideration and **P2/P3 must NOT be started**.

**Definition of done**: exactly one of —
- **GO**: a sorry-free-spine PoC skeleton of `nf_quant_layer_fold_k2_gate` reducing the outer fold to
  per-(zone,χ) monadic obligations at constant arity via the certified route, `lake build` green,
  litmus enforced (reconstruction rides evaluation-point/structural position, never an `x1 < e_i`
  literal); at most one strategic sorry at the full-engine (Layer-2 split-kit) boundary, tracked; OR
- **NO-GO**: a machine-grounded record containing the exact failing `lean_goal` state, the failed
  tactic attempts, and the precise coupling that reproduces the :1622-1646 barrier — **no partial
  carrier and no `sorry` committed to the file** (DECISION-GATE contract, see :1638).

### Research Integration

- Integrated report: `specs/321_.../reports/05_remaining-k2-gate-architecture.md` (Layer-1 fold
  engine section; "Why the naive 0→1 lift is BLOCKED" proof; H3 Tier-1 Rabinovich grounding).
- Reference tier: **Tier 1 (literature-backed)** — Rabinovich 2014 Prop 4.3 E[Σ]-fold (constant arity,
  avoids the navigated arity-4 characteristic), Cor 5.4 (md:154-157), Def 4.1 (PDF p.5-6).

### Preserved Assets

The following are **complete and LANDED** and MUST NOT regress (this task is additive-only; it neither
edits nor re-derives them):

| Component | File:line | Status | Role |
|-----------|-----------|--------|------|
| `nf_quant_layer_fold_iff` / `_k1_gate` | NfEFold:391 / :525 | [COMPLETED] | depth-0 fold template + k=1 gate (the thing being lifted) |
| `nf_eval_nf0_cons_factor` | NfEFold:283 | [COMPLETED] | depth-0 3-way factorization (template for the risky lift) |
| depth-0 split kit `nf0_assemble/_dropFresh/_projFresh/_zoneSpec` + 4 round-trips | NfEFold:153-235 | [COMPLETED] | template for the depth-1 kit |
| `nfk_projFresh` | NfMultiAnchorBridge:3668 | [COMPLETED] | depth-k fresh projection (already exists; `= nf0_projFresh` at k=0) |
| `nf_eval_depth1_fold_iff` | NfMultiAnchorBridge:5344 | [COMPLETED] | single depth-1 form factorization (exposes the coupling) |
| `NormalFormEFold` / `nf_eval_efold` / `efold_of_nf1` / `nf_eval_nf1_iff_efold` | NfEFold:77 / :102 / :472 / :490 | [COMPLETED] | constant-arity E[Σ] transport (route (b) foundation) |
| `nf_eval_unique` | NormalForm:245 | [COMPLETED] | off-fiber uniqueness, **generic over k** (free at depth 1) |
| task-325/326 landed lemmas; `kvE2_body` / `bracketEndChar_kvE2` splice; `BracketCarrierCorrectVPrior`; `EANegation`; F1-F4 records | NfMultiAnchorBridge (various) | [COMPLETED] | DO-NOT-EDIT (byte-identical to `8448ea135`) |

### Source-to-Implementation Mapping (H3 Tier 1)

| Load-bearing decision | Source | Implementation target |
|-----------------------|--------|-----------------------|
| Route (a) naive factor reproduces the arity-4 barrier | scope-map "Why the naive 0→1 lift is BLOCKED"; NfMultiAnchorBridge:1622-1646 (verified this dispatch) | Phase 1 goal capture |
| Constant-arity E[Σ]-fold avoids the navigated arity-4 characteristic | Rabinovich 2014 **Prop 4.3 / Def 4.1** (PDF p.5-6); landed `efold_of_nf1`/`nf_eval_nf1_iff_efold` | Phase 2 route-(b) probe |
| Exterior witnesses positioned by since/until REACH, never a relative-position literal (LITMUS) | Rabinovich 2014 **Cor 5.4** (md:154-157) | Phase 2/3 litmus enforcement |
| Recursion bottoms out at landed generic assets (no 4th hidden layer) | scope-map H4 verification table (`nf_eval_unique` generic over k) | Phase 3 PoC spine |

## Goals & Non-Goals

- **Goals**:
  - Machine-decide whether `nf_quant_layer_fold_k2_gate` folds cleanly, and by which route.
  - Produce EITHER a proven PoC skeleton (GO) OR a machine-grounded NO-GO with the exact failing goal.
  - Keep every change purely additive to `NfMultiAnchorBridge.lean`.
- **Non-Goals**:
  - Building the full Layer-2 depth-1 split-kit or landing the complete engine (that is **P2** —
    do NOT start it here; it is gated on this task's GO verdict).
  - The 5-zone non-interior dischargers (that is **P3**).
  - Any Stage C / Stage D / Phase 15 (F4 ℤ) consumption inside task 321.
  - Editing or re-deriving any Preserved Asset.

## Risks & Mitigations

- **Risk: F4-flattening relapse** — forcing a naive factorization re-introduces a navigated arity-4
  characteristic (the :1622-1646 / G6 barrier). **Mitigation**: Phase 1 captures this as an *expected,
  machine-grounded* route-(a) NO-GO (not a whole-task failure); the LITMUS (reconstruction must ride
  evaluation-point/structural position, never an `x1 < e_i` literal) is enforced on every route-(b)
  reconstruction step in Phases 2-3.
- **Risk: H2 first-sorry-free-lemma bar vs the NO-GO branch.** On NO-GO, the DECISION-GATE contract
  (:1638) forbids committing any partial carrier or `sorry`, so no sorry-free lemma lands.
  **Mitigation**: the H2 "first sorry-free lemma within 30% of tool calls" bar applies to the **GO
  path**; on the NO-GO path the equivalent 30% bar is a **captured machine-grounded failing goal
  state** (via `lean_goal` + `lean_multi_attempt`), not a lemma. Route (b) is probed with
  `lean_multi_attempt` (no file writes) FIRST to reach the verdict cheaply before any lemma is
  committed.
- **Risk: front-loading wasted setup.** **Mitigation**: Phase 1 is a single cheap lemma statement +
  goal capture; the split-kit definitions and engine are deferred entirely to P2. No infrastructure is
  built until Phase 3's GO branch, and only the minimal certifying spine even then.
- **Risk: route (b) also fails (whole-task NO-GO).** **Mitigation**: this is an accepted, valuable
  outcome — the NO-GO exit criterion (below) defines exactly the goal state that certifies it; the plan
  terminates decisively rather than churning.

## Postmortem Constraints

Binding rules for all implementation dispatches on task 327. Derived from the scope-map's blocked-lift
proof, the DECISION-GATE contract at :1638, and the F4-flattening failure mode of plan-v2 Phase 8.

**Do NOT**:
- Do NOT attempt a verbatim `0 → 1` textual lift of `nf_quant_layer_fold_iff`/`_k1_gate`. It is proven
  BLOCKED — its residual reproduces the arity-4 → arity-3 re-bounding barrier at
  `NfMultiAnchorBridge.lean:1622-1646`. Probing route (a) is allowed ONLY to machine-ground the
  route-(a) NO-GO, not as a candidate GO path pursued past its first arity-4 residual.
- Do NOT discharge any reconstruction goal with an `x1 < e_i` (relative-position) literal. Witness
  positioning MUST ride evaluation-point / structural position (zone spec, since/until reach, bracket
  monotonicity) per Rabinovich Cor 5.4 — this is the F4-flattening LITMUS and its violation is an
  automatic route rejection.
- Do NOT use `simp`/`omega`/`aesop` to bypass a step the E[Σ]-fold literature (Prop 4.3 / Def 4.1)
  handles explicitly (literature-fidelity policy).
- Do NOT commit any partial probe carrier or `sorry` on a NO-GO verdict (DECISION-GATE, :1638). A
  NO-GO lands a *record* (comment block + summary), never live proof state.
- Do NOT start P2 (engine) or P3 (5-zone dischargers), and do NOT create the Layer-2 split-kit
  definitions beyond the single minimal spine needed by a GO PoC.

**MUST preserve**:
- Every Preserved Asset above, byte-identical (`kvE2_body` / `bracketEndChar_kvE2` splice equals
  `8448ea135`; task-325/326 lemmas; `BracketCarrierCorrectVPrior`; `EANegation`; F1-F4 records).
- Sorry-free status of the file: a GO PoC introduces at most ONE tracked strategic sorry (engine
  boundary); a NO-GO introduces none.

**Design decisions are SETTLED** (do not re-open without a concrete machine counterexample):
- The naive route (a) `nf_eval_nf1_cons_factor` is the high-risk / likely-FALSE path; route (b) E[Σ]
  `efold_of_nfk` is the recommended candidate (Rabinovich Prop 4.3, constant arity). Rejected
  alternative: pursuing route (a) past its documented arity-4 residual.
- χ has type `NormalForm sig 1 1` (depth-1 monadic), matching the carrier's `charK` domain (confirmed
  by `kvE_subBracket2V_sound_of_parts`). There is no type barrier at the consumption site.
- The recursion bottoms out at landed generic assets (`nf_eval_unique` generic over k; depth-0 kit;
  `nf_eval_depth1_fold_iff` for the inner monadic layer). There is no 4th hidden layer to discover
  here (scope-map H4 verification).

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Fully sequential: each phase's verdict determines the next phase's scope. Phase 3 runs exactly one of
its two mutually-exclusive branches (GO or NO-GO), selected by Phase 2's outcome.

### Phase 1: Route (a) barrier reproduction — machine-ground the naive-factor verdict [COMPLETED]

- Verdict: **route-(a) NO-GO (expected, a2)**. `probe_route_a` (transient) reduced the depth-1
  per-witness factorization forward projection via `nf_eval_depth1_fold_iff`; captured `lean_goal`
  shows the arity-1 monadic projection `nf_eval_nf M 1 1 (fun _ => x1) (nfk_projFresh sub)` whose
  inner fold reads `zoneHolds M (fun _ => x1) zs v` (arity-1, v-vs-x1 only), whereas the source
  `h` carries `zoneHolds M (Fin.cons x1 (Fin.cons w (Fin.cons x fun _ => t))) zs v` (arity-4). The
  monadic channel drops the inner witness's coupling to {w,x,t}: the factorization is lossy, not a
  clean biconditional. Route-(a) NO-GO is NOT a whole-task NO-GO — proceeded to Phase 2.

- **Goal:** State the naive load-bearing factorization `nf_eval_nf1_cons_factor` at the exact
  scope-map signature and, via `nf_eval_depth1_fold_iff` (NfMultiAnchorBridge:5344), reduce it to its
  residual goal to determine — machine-grounded — whether it splits cleanly or reproduces the
  arity-4 barrier at :1622-1646.
- **Tasks:**
  - [ ] Transcribe the `nf_eval_nf1_cons_factor` statement from the scope-map (Layer-2 table):
    `nf_eval_nf M 1 (n+1) (Fin.cons x env) sub ↔ zoneHolds M env (nfk_zoneSpec sub) x ∧ nf_eval_nf M 1 1 (fun _ => x) (nfk_projFresh sub) ∧ nf_eval_nf M 1 n env (nfk_dropFresh sub)` (using landed `nfk_projFresh`:3668; the `nfk_zoneSpec`/`nfk_dropFresh` referents are stubbed at k=1 only as needed to state the goal — no kit build).
  - [ ] Apply `nf_eval_depth1_fold_iff` to `sub : NormalForm sig 1 (n+1)` at env `Fin.cons x env`; use `lean_goal` to capture the residual after the atom layer factors via `nf_eval_nf0_cons_factor`.
  - [ ] Use `lean_multi_attempt` (NO file writes) to confirm the inner-fold residual references `x` inside `zoneHolds (Fin.cons x env) zs v` (the `x1 ↔ zoneHolds(cons x env)` cross-content coupling), reproducing the :1629-1636 arity-4 residual.
  - [ ] Record: EITHER (a1, unexpected) the naive factor proves sorry-free → route (a) GO, skip to Phase 3 GO branch citing route (a); OR (a2, expected) capture the exact residual `lean_goal` output as the route-(a) NO-GO evidence and proceed to Phase 2.
- **Estimated output:** ~40-120 lines (one lemma statement + captured goal states in comments; likely no committed proof).
- **Done when:** the route-(a) verdict is machine-grounded — either a sorry-free proof of
  `nf_eval_nf1_cons_factor` exists (a1), or the exact residual goal reproducing the :1622-1646 coupling
  is captured (a2). Route-(a) NO-GO is NOT a whole-task NO-GO.
- **Depends on:** none

### Phase 2: Route (b) E[Σ] efold transport probe — the make-or-break [COMPLETED]

- Verdict: **route-(b) NO-GO → WHOLE-TASK NO-GO (b2)**. `probe_route_b` (transient) set up the
  reconstruction (⟸) direction of the outer `∃x1` fold obligation at constant arity, supplying the
  x1-monadic channel `hmon : nf_eval_nf M 1 1 (fun _ => x1) (nfk_projFresh sub)`. After
  `nf_eval_depth1_fold_iff`, the crux inner-fold goal (`ZoneSpec 4`) reproduces the NO-GO exit
  criterion. Five failed `lean_multi_attempt` closers captured (see NO-GO record in
  `NfMultiAnchorBridge.lean`); the decisive one, `exact hmon.2.1 zs' χ'`, fails with **"argument
  `zs'` has type `ZoneSpec 4` but is expected to have type `ZoneSpec 1`"** — the E[Σ] constant-arity
  channel is structurally arity-1, too small to carry the inner witness's coupling to the three
  fixed anchors {w,x,t}. Route (b) does NOT dodge the :1622-1646 / G6 arity-4 barrier; it
  re-forms it at the outer quant layer's monadic fold. No viable route (c) at constant arity-1 χ
  (semantic impossibility). Proceeded to Phase 3 NO-GO branch.

- **Goal:** Probe whether the constant-arity E[Σ] outer fold (`efold_of_nfk`, the outer analog of the
  landed `nf_eval_nf1_iff_efold` NfEFold:490) folds the outer `∃x1` across zones **without** re-forming
  the arity-4 residual — reading the quant layer only through zone-bounded monadic E-atoms
  (`EAtomDom sig k n = ZoneSpec n × NormalForm sig k 1`, Def 4.1 / Prop 4.3). This is the whole-task
  make-or-break.
- **Tasks:**
  - [ ] Restate the target reduction: `nf_quant_layer_fold_k2_gate`'s RHS obligation
    `(∀ zs χ, (∃ x1, zoneHolds M [w,x,t] zs x1 ∧ nf_eval_nf M 1 1 (fun _ => x1) χ) ↔ qnf.2 (nfk_assemble zs χ qnf.1) = true)` from the scope-map Layer-1 signature.
  - [ ] Via `lean_multi_attempt`, apply the E[Σ] transport (`nf_eval_nf1_iff_efold` outer analog) to route the outer `∃x1` through the fold's `nf_eval_efold` clause; check with `lean_goal` whether the residual is per-(zone,χ) monadic at constant arity (env `fun _ => x1`, arity 1) — NOT the arity-4 `[x1,w,x,t]` environment.
  - [ ] Enforce LITMUS: confirm every reconstruction step positions `x1` by zone spec / since-until reach, never by an `x1 < e_i` literal (Rabinovich Cor 5.4).
  - [ ] Record the verdict: (b1) transport reduces to constant-arity per-(zone,χ) monadic obligations, litmus PASS → **GO** (proceed to Phase 3 GO branch); OR (b2) transport ALSO re-forms the arity-4 navigated-characteristic residual (:1622-1646 reproduced) or forces an `x1 < e_i` literal (litmus FAIL) → **whole-task NO-GO** (proceed to Phase 3 NO-GO branch).
- **Estimated output:** ~60-150 lines (probe reductions and captured goal states; proof committed only on b1 and only in Phase 3).
- **Done when:** the route-(b) verdict is machine-grounded — either the constant-arity reduction goal
  is reached with litmus PASS (b1 → GO), or the exact failing goal state satisfying the NO-GO exit
  criterion (below) is captured (b2 → NO-GO).
- **Depends on:** 1

### Phase 3: Certify — PoC skeleton (GO) OR machine-grounded NO-GO record [COMPLETED]

- Branch taken: **NO-GO**. Transient probe block removed (no `sorry`, no partial carrier
  committed — DECISION-GATE :1638 honored). Additive, inert NO-GO record comment block appended to
  `NfMultiAnchorBridge.lean` containing the exact failing `lean_goal` state, the five failed
  `lean_multi_attempt` closers, the arity-4 coupling reproducing :1622-1646, and the recommendation
  to NOT start P2/P3. `lake build` green.

Runs **exactly one** branch, selected by Phase 2 (or a Phase-1 a1 route-(a) GO).

- **Goal (GO branch):** Land a proven proof-of-concept skeleton of `nf_quant_layer_fold_k2_gate` whose
  spine is sorry-free via the certified route, reducing the outer fold to the per-(zone,χ) obligations
  and the off-fiber clause (`nf_eval_unique`, generic over k).
- **Tasks (GO branch):**
  - [ ] Write `nf_quant_layer_fold_k2_gate` at the scope-map Layer-1 signature; prove the spine via
    the certified route (b) transport; discharge the off-fiber `∀ sub, nfk_dropFresh sub ≠ qnf.1 → qnf.2 sub = false` clause via `nf_eval_unique`.
  - [ ] If the full Layer-2 split-kit is required to complete the spine, place **at most ONE** strategic sorry at that engine boundary — documented `-- sorry: assumes Layer-2 depth-1 split-kit; deferred because engine build is P2 (out of gate scope); follow-up: P2 engine task (spawned on GO)` — and record it in the handoff `sorry_inventory` with `strategic: true` and a non-null `follow_up_task` (the downstream engine task, spawned by the orchestrator/`/spawn 327` after this GO). Satisfy all five anti-analysis 5-condition tests.
  - [ ] Enforce LITMUS on every reconstruction step; run `lake build` on the module — must be green.
  - [ ] `#print axioms nf_quant_layer_fold_k2_gate` to confirm the spine is sorry-free except the one tracked strategic boundary sorry.
- **Goal (NO-GO branch):** Write the machine-grounded NO-GO record. Commit NO partial carrier and NO
  `sorry` (DECISION-GATE, :1638).
- **Tasks (NO-GO branch):**
  - [ ] Add a structured NO-GO comment block to the file (additive, no live proof state) containing:
    the exact failing `lean_goal` output from Phase 2, the `lean_multi_attempt` tactics that failed, the
    precise coupling reproducing :1622-1646, and the LITMUS-violation (if any).
  - [ ] Record the recommendation: the whole carrier route needs fundamental reconsideration; **do NOT
    start P2/P3**; route (c) "new argument" scope, if any, is out of this gate.
  - [ ] `lake build` on the module — must remain green (the comment block is additive/inert).
- **Estimated output:** GO ~150-350 lines (statement + spine proof); NO-GO ~30-80 lines (record comment block).
- **Done when:** EITHER a sorry-free-spine PoC (≤1 tracked strategic sorry) builds green (GO), OR the
  NO-GO record with the exact failing goal is written and the module builds green (NO-GO). Both are
  valid, decisive termini.
- **Depends on:** 2

## NO-GO Exit Criterion (whole-task terminus)

The whole-task **NO-GO is certified** when, and only when, the route-(b) probe (Phase 2) reaches a goal
state of the form

```
⊢ (∃ x1, zoneHolds M (Fin.cons w (Fin.cons x (fun _ => t))) zs x1 ∧ nf_eval_nf M 1 1 (fun _ => x1) χ)
    ↔ qnf.2 (nfk_assemble zs χ qnf.1) = true
```

that is **not closable without re-expanding `qnf.2` at the arity-4 environment `[x1, w, x, t]`** — i.e.,
the only remaining move requires a navigated arity-3 (arity-4 residual) characteristic, reproducing the
`NfMultiAnchorBridge.lean:1622-1646` / G6 coupling — **OR** any goal whose only closing move introduces
an `x1 < e_i` relative-position literal (LITMUS FAIL). Reaching this state (captured via `lean_goal` +
at least two failed `lean_multi_attempt` alternatives) STOPS the task: record the NO-GO, do NOT start
P2/P3. Route (a)'s arity-4 residual alone (Phase 1) does NOT satisfy this criterion — only failure of
route (b) (and no viable route (c)) certifies the whole-task NO-GO.

## Territory / DO-NOT-EDIT (single-file, additive-only)

- **Sole editable file**: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`,
  **append-only** (new declarations / comment records; no edits to existing declarations).
- **DO-NOT-RELAPSE anchor**: `NfMultiAnchorBridge.lean:1622-1646` — the arity-4 → arity-3 / G6
  re-bounding barrier. No reconstruction may route through a navigated arity-3 characteristic that this
  region documents as barred.
- **DO-NOT-EDIT anchors** (byte-identical to `8448ea135`): `kvE2_body` / `bracketEndChar_kvE2` splice;
  task-325 / task-326 landed lemmas (incl. `kvE_subBracket2V_sound_of_outer`:7910,
  `kvE_subBracket2V_complete`:8159, `kvE_subChain2V`:6955); `BracketCarrierCorrectVPrior`; `EANegation`;
  F1-F4 records.

## Testing & Validation

- [ ] `lake build Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge` is green at each
  phase end (GO: PoC compiles; NO-GO: additive record is inert).
- [ ] GO only: `#print axioms nf_quant_layer_fold_k2_gate` shows no `sorryAx` except the single tracked
  strategic-boundary sorry (if any); the `declaration uses 'sorry'` warning, if present, is located
  exactly at the documented engine boundary.
- [ ] LITMUS check: no reconstruction step uses an `x1 < e_i` literal (grep the added block + review).
- [ ] Preserved Assets unchanged: `git diff` touches only appended regions of the single file.
- [ ] NO-GO only: the record contains a concrete `lean_goal` state and ≥2 failed `lean_multi_attempt`
  alternatives (machine-grounded, not prose).

## Artifacts & Outputs

- plans/01_k2-fold-provability-gate.md (this file)
- Appended content in `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge.lean`
  (GO: PoC skeleton; NO-GO: machine-grounded record comment block)
- summaries/01_k2-fold-provability-gate-summary.md (verdict: GO+route or NO-GO+failing goal)
- .orchestrator-handoff.json (status, verdict, sorry_inventory if GO with strategic sorry)

## Rollback/Contingency

- Additive-only: rollback = remove the appended block; no Preserved Asset is ever touched.
- On NO-GO: nothing beyond the record comment is committed (no partial carrier / no `sorry`), so there
  is nothing to roll back beyond deleting the inert record if desired.
- On interruption mid-probe: no file writes occur during `lean_multi_attempt` probing, so a partial
  dispatch leaves the file green and unchanged; resume re-runs the current phase's probe.
