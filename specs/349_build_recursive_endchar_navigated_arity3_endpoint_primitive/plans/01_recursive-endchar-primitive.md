# Implementation Plan: Task #349

- **Task**: 349 - Build the recursive navigated arity-3 endpoint primitive `endChar` + `endChar_correct`
- **Status**: [IMPLEMENTING]
- **Effort**: 8 hours
- **Dependencies**: None (consumes only already-landed, sorry-free assets)
- **Research Inputs**: None (this task); grounded in task-309 reports/02_endpoint-hook-discharge-research.md (§1.4, §4, §6) and reports/08_spawn-analysis.md
- **Artifacts**: plans/01_recursive-endchar-primitive.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Build the report-02 §1.4 primitive `endChar : (k : Nat) -> EndCharCarrier sig k` (where
`EndCharCarrier sig k := NormalForm sig k 3 -> TemporalPred`, Base.lean:1007) by recursion on `k`,
plus its correctness theorem `endChar_correct`. The base case is the already-landed, sorry-free
`endChar0`/`endChar0_correct` (Base.lean:995/1056). The step case (`k+1`) must characterize
`nf_eval_nf M (k+1) 3 (zoneEnv3 w a b) qnf` at a navigated witness `w` with two fixed anchors
`{a,b} subset {x,t}`; its inner quant layer produces **arity-4** sub-evaluations
`exists w', nf_eval_nf M k 4 (Fin.cons w' (zoneEnv3 w a b)) sub` that the fixed arity-3 carrier
cannot consume directly. The correct mechanism (report 02 §4.1/§4.2, Rabinovich 2014 Cor 5.4) is
the **brick-witness-collapse**: flatten each `exists w'` via `nf_zone_flatten_navigable_brick`,
keep every interior witness a *bracket* witness riding the non-trivial `seg` segment, and keep the
free-anchor set at `{x,t}` (<=2). This is emphatically NOT `nf_char3_deeper_split` (refuted route:
grows anchors to 4, forbidden tower). Scope is `Base.lean` only, additive. Definition of done:
`lake build` GREEN; `endChar`/`endChar_correct` sorry-free; `lean_verify` on `endChar_correct`
= exactly `[propext, Classical.choice, Quot.sound]`; no frozen-file edits; task 309 Phase 18/19 can
cite `endChar_correct` by name.

### Research Integration

No task-349 research report exists. The plan integrates the two task-309 artifacts that scoped this
work:
- **reports/02_endpoint-hook-discharge-research.md** — §1.4 defines the single missing primitive
  (`(endChar qnf).eval_at w <-> nf_eval_nf M k 3 (zoneEnv3 w a b) qnf`, navigated `w`, anchors
  `{a,b} subset {x,t}`, recursion on `k`, arity <=3); §4 refutes the `nf_char3_deeper_split`
  anchor-growth route; §6 gives the "Phase 8" decomposition (recursive `endChar` assembly,
  ~120-200 lines) this task realizes.
- **reports/08_spawn-analysis.md** — establishes this as a structural prerequisite (New Task 1),
  fully self-contained, consuming only landed sorry-free assets, not touching `KampPrior.lean`.

Design decisions grounded in source reads of Base.lean:
- `nf_eval_nf` at `k+1` unfolds to an atom layer at the full env plus, per arity-4 sub, a coupled
  `exists w'` on `Fin.cons w' (env)` (pattern read at Base.lean:606-615).
- `endChar0_correct` (Base.lean:1056) established the base-case statement shape: the navigated
  `w`-locus is read locally; the anchor+order atoms are supplied by a **residual hypothesis**
  `h_res`. The recursive `endChar_correct` must carry the analogous residual/coupling hypotheses
  (NOT a weaker or vacuous form).
- `nf_zone_flatten_navigable_brick`/`_correct` (Base.lean:813/687) is the hook-parametric
  five-zone flattener consumed verbatim; `seg`/`seg_holds_correct`/`seg_holds_coupled`
  (Base.lean:1127-1162) supply the non-trivial interior segment.

**Decoupling strategy**: The hard step content is isolated into a standalone step function
`endCharStep (k) (rec : EndCharCarrier sig k) : EndCharCarrier sig (k+1)` with a companion
`endCharStep_correct` proven under the IH correctness of `rec`. `endChar` is then
`Nat.rec endChar0 endCharStep` and `endChar_correct` a short induction. This keeps each phase a
green, independently committable unit and confines the load-bearing risk to Phase 3.

### Prior Plan Reference

No prior plan for task 349. Effort calibration and mechanism come from the task-309 v9 plan's
carried postmortem guards (G1-G5) and report 02's ~380-670-lines-over-4-phases estimate for the
sibling decomposition; report 08 sizes this specific primitive at ~300-500 in-file lines / 6-10h.

### Roadmap Alignment

No `roadmap_flag` was passed for this dispatch; ROADMAP.md is not modified by this task. The work
advances the Kamp-theorem formalization line (unblocks task 309 Phase 18/19, closing the
`KampPrior.lean:351` `n=1` arm's hook obligations).

## Goals & Non-Goals

**Goals**:
- Define `endChar : (k : Nat) -> EndCharCarrier sig k` by recursion on `k` (base `endChar0`, step
  brick-witness-collapse + `seg` interior + endpoint exteriors, arity capped at 3).
- Prove `endChar_correct : (endChar k qnf).eval_at M atomMap w <-> nf_eval_nf M k 3 (zoneEnv3 w a b) qnf`
  under the structurally-required residual/order hypotheses (mirroring the `h_res` precedent of
  `endChar0_correct`, never a weaker or vacuous form).
- Keep everything sorry-free; `lean_verify` axioms exactly `[propext, Classical.choice, Quot.sound]`.
- Land additively in `Base.lean` only, so task 309 Phase 18/19 can cite `endChar_correct` by name.

**Non-Goals**:
- The aggregate `forall`-qnf `quantEnd`/`seg` construction and the three arm-correctness hook
  discharges (that is task-309 New Task 2 / a separate follow-up).
- Editing `KampPrior.lean`, `nf_nvar_exist_all_depths`'s signature, or the `:351`/`:361` sorry
  region (out of scope; downstream task 309).
- Rebuilding `endChar0`, `seg`, or `nf_zone_flatten_navigable(_brick)` (consume verbatim).
- Any use of `nf_char3_deeper_split` or any route growing the anchor set beyond `{x,t}` (2).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Arity-4 sub-evaluation cannot collapse to arity-3 within the <=2 anchor cap (the core wall) | H | M | Phase 3 is the flagged load-bearing phase; split into 3a/3b at the (per-sub flatten)/(interior-segment assembly) seam if it overruns one agent run; escalate `[BLOCKED]` rather than resort to `nf_char3_deeper_split` |
| Temptation to reach for `nf_char3_deeper_split` when the collapse resists | H | M | G-guard binding: FORBIDDEN. Every interior witness stays a bracket witness; anchors provably `{x,t}` via `zoneEnv3_arity_invariant`. Route audit recorded per phase |
| Exact residual/coupling hypothesis shape of `endChar_correct` is an open implementation choice | M | H | Fix and freeze the statement in Phase 1 (mirroring `h_res`); Phases 3-4 must prove that exact statement, not a convenience-weakened one; guard against vacuity per lean4 vacuous-definitions rule |
| A sub-piece cannot close green | H | L-M | Mark the phase `[BLOCKED]`, document goal state reached and what is needed, return `status: partial`. Do NOT land a vacuous or sorry'd `endChar` |
| Manual Rabinovich chain-step bridges tempt a `simp`/`omega`/`aesop` shortcut | M | M | G5 binding: manual `constructor`/`intro` bridges only, mirroring `seg_holds_coupled` (Base.lean:1157-1162) |
| Frozen-file edit slips in | H | L | Never open the seven frozen providers or `KampPrior.lean`; verify `git status` touches only `Base.lean` before each commit |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This chain is fully sequential: each phase
consumes the green artifact of the prior one.

### Phase 1: Step-target unfolding + `endChar_correct` statement freeze [IN PROGRESS]

**Goal**: Establish the exact `k+1` target shape and freeze the `endChar`/`endChar_correct`
signatures (including the residual/coupling hypotheses) so downstream phases prove a fixed,
non-weakened statement.

**Tasks**:
- [ ] Read `nf_eval_nf`'s `k+1` unfolding (NormalForm.lean; cross-check the Base.lean:606-615
  pattern) and record, in an in-file docstring, the precise decomposition of
  `nf_eval_nf M (k+1) 3 (zoneEnv3 w a b) qnf` into (atom layer at `zoneEnv3 w a b`) AND (per
  arity-4 sub `sub`: `exists w', nf_eval_nf M k 4 (Fin.cons w' (zoneEnv3 w a b)) sub`).
- [ ] Prove a green helper lemma `nf_eval_nf_step_unfold` (or reuse an existing unfolding lemma if
  one already covers the arity-3 `k+1` case) exposing that decomposition as a citable equivalence.
- [ ] Write the frozen `endChar` recursion carrier signature `endChar : (k : Nat) -> EndCharCarrier sig k`
  and the frozen `endChar_correct` statement, choosing the residual/order hypothesis shape by
  direct analogy to `endChar0_correct`'s `h_res` (Base.lean:1061-1062). Record the choice and its
  justification in a docstring; do NOT yet supply the step body (Phase 3) — this phase may state
  the signature via the `endCharStep` decomposition placeholder only if it remains green (no sorry;
  if a green skeleton is impossible without the step, defer the `def` to Phase 4 and land only the
  unfolding lemma + a written signature spec here).
- [ ] Route audit: confirm target env is `zoneEnv3 w a b` (arity 3, anchors `{a,b} subset {x,t}`),
  `w` is the navigated witness (G4), no arity-1 collapse (G1).

**Timing**: ~1.5 hours (~80-150 lines)

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` - add the
  step-unfolding lemma and the frozen signature/docstring spec (additive)

**Verification**:
- `lake build` of the Base module is GREEN with the new unfolding lemma sorry-free.
- The `endChar_correct` statement is written out and reviewed to be the faithful navigated
  characterization (not a weakened/vacuous form).

### Phase 2: Arity-4 -> arity-3 brick-witness-collapse bridge [NOT STARTED]

**Goal**: Prove the load-bearing structural bridge that reduces each arity-4 sub-existential
`exists w', nf_eval_nf M k 4 (Fin.cons w' (zoneEnv3 w a b)) sub` to arity-3 navigated evaluations
consumable by a depth-`k` arity-3 carrier, keeping the free-anchor set at `{x,t}` (<=2) — the
brick-witness-collapse, NOT `nf_char3_deeper_split`.

**Tasks**:
- [ ] Instantiate `nf_zone_flatten_navigable_brick` (Base.lean:813) on the sub existential, with the
  navigated endpoint hooks `pastEnd`/`futureEnd` supplied by the depth-`k` recursion carrier
  applied to the appropriate arity-3 projections of `sub` (the anchor-management step).
- [ ] Prove the collapse lemma: the arity-4 evaluation with the fourth env slot a bracket witness
  reduces to arity-3 `nf_eval_nf M k 3 (zoneEnv3 . x t) .` residuals plus the two navigated
  exterior reaches, with `w'` never becoming a third free anchor (cite `zoneEnv3_arity_invariant`,
  Base.lean:545).
- [ ] Route audit: G2/G4 — anchors provably `{x,t} = 2`; explicitly assert the FORBIDDEN
  `nf_char3_deeper_split` route is not taken (record the reason: it grows anchors to 4).
- [ ] G5 — any Rabinovich chain-step bridge is a manual `constructor`/`intro`, no
  `simp`/`omega`/`aesop` shortcut.

**Timing**: ~2 hours (~150-250 lines). If it overruns one agent run, split at the
(brick instantiation)/(collapse proof) seam into 2a/2b.

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` - add the
  collapse bridge lemma(s) (additive)

**Verification**:
- Collapse lemma(s) typecheck and are sorry-free (`lake build` Base module GREEN).
- `lean_verify` on the new bridge lemma shows only `[propext, Classical.choice, Quot.sound]`.
- Grep confirms no `nf_char3_deeper_split` occurrence in the new code.

### Phase 3: Assemble `endCharStep` + `endCharStep_correct` under the IH [NOT STARTED]

**Goal**: Build the step function `endCharStep (k) (rec : EndCharCarrier sig k) : EndCharCarrier sig (k+1)`
as (base-shaped `w`-locus atom layer) ∧ (per-sub `seg`-interior + endpoint-exterior clauses via
the Phase-2 collapse), and prove `endCharStep_correct` given `rec`'s correctness as the IH.

**Tasks**:
- [ ] Define `endCharStep`: reuse the `endChar0`-shaped `w`-locus atom characteristic for position 0,
  compose the per-sub interior via `seg` (the non-trivial `beta_i` segment, G3 — never
  `TemporalPred.top`) and the exteriors via Phase-6/8-shaped endpoint characteristics built from
  `rec` through the Phase-2 collapse. Keep arity <=3 (G4).
- [ ] Prove `endCharStep_correct`: `(endCharStep k rec qnf).eval_at M atomMap w <-> nf_eval_nf M (k+1) 3 (zoneEnv3 w a b) qnf`
  under (i) the frozen residual hypotheses from Phase 1 and (ii) the IH
  `rec_correct` (`rec`'s `endChar_correct` at depth `k`). Discharge the interior coupling via
  `seg_holds_coupled` (Base.lean:1150, hook `h_endChar`) exactly as Phases 4/5 defer `h_quant` —
  NOT a sorry. Discharge the exterior reaches via `nf_zone_flatten_navigable_correct`
  (Base.lean:687) and the Phase-2 bridge.
- [ ] Route audit: G1 (honest arity-3 atom layer, no arity-1 collapse), G3 (non-trivial `seg`), G4
  (`w` and interior witnesses are bracket witnesses; anchors `{x,t}`), G5 (manual bridges).

**Timing**: ~2.5 hours (~150-300 lines). This is the flagged load-bearing phase; if a sub-piece
cannot close green, mark `[BLOCKED]`, document the goal state and the missing lemma, and return
`status: partial` — do NOT land a vacuous or sorry'd step.

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` - add `endCharStep`
  and `endCharStep_correct` (additive)

**Verification**:
- `lake build` Base module GREEN; `endCharStep`/`endCharStep_correct` sorry-free.
- `lean_verify endCharStep_correct` = exactly `[propext, Classical.choice, Quot.sound]`.
- The proved statement is the frozen Phase-1 one (no weakening), checked against the docstring spec.

### Phase 4: Assemble the recursion `endChar` + `endChar_correct` [NOT STARTED]

**Goal**: Tie the base and step together into the recursive primitive and prove global correctness
by induction on `k`.

**Tasks**:
- [ ] Define `endChar : (k : Nat) -> EndCharCarrier sig k` as `Nat.rec endChar0 endCharStep`
  (base `endChar 0 = endChar0 atomMap h_surj`; step `endChar (k+1) = endCharStep k (endChar k)`).
- [ ] Prove `endChar_correct` by induction on `k`: base case = `endChar0_correct` (Base.lean:1056,
  supplying its `h_res` residual); step case = `endCharStep_correct` fed the IH `endChar_correct k`
  as `rec_correct`.
- [ ] Confirm the statement matches report 02 §1.4 verbatim in shape:
  `(endChar k qnf).eval_at M atomMap w <-> nf_eval_nf M k 3 (zoneEnv3 w a b) qnf` under the frozen
  residual hypotheses; `endChar0` inhabits `EndCharCarrier sig 0` definitionally.
- [ ] Route audit: G1-G5 satisfied by construction (inherited from Phases 1-3).

**Timing**: ~1.5 hours (~80-120 lines)

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` - add `endChar`
  and `endChar_correct` (additive)

**Verification**:
- `lake build` Base module GREEN; `endChar`/`endChar_correct` sorry-free.
- `endChar` is not a vacuous definition (it genuinely recurses through `endCharStep`).

### Phase 5: Axiom + full-tree verification and downstream-citation check [NOT STARTED]

**Goal**: Confirm the definition-of-done gates and that task 309 can cite the result by name.

**Tasks**:
- [ ] `lean_verify` on `endChar_correct` (fully qualified name) returns exactly
  `[propext, Classical.choice, Quot.sound]` and reports no `sorry`.
- [ ] Full-tree `lake build` GREEN (scoped Base module at minimum; full tree recommended).
- [ ] `git status` confirms only `Base.lean` (and this plan/summary) changed — no frozen-provider or
  `KampPrior.lean` edits.
- [ ] Grep-confirm `endChar_correct` is a top-level citable name reachable from task 309's Phase
  18/19 consumers (`nf_char2_past_formula_correct`, `A_diag_correct`,
  `nf_char2_future_formula_correct` hook sites).

**Timing**: ~0.5 hours (~40-80 lines of verification output/adjustments)

**Depends on**: 4

**Files to modify**:
- None expected (verification only); minor doc adjustments to `Base.lean` if naming needs
  stabilizing for downstream citation.

**Verification**:
- All definition-of-done gates pass (axioms, sorry-free, no frozen edits, citable).

## Testing & Validation

- [ ] `lake build` of `Theories.Bimodal.Metalogic.WeakCanonical.Kamp.NfMultiAnchorBridge.Base`
  is GREEN after every phase (per-phase gate).
- [ ] Final full-tree `lake build` is GREEN.
- [ ] `lean_verify` on `endChar_correct` = exactly `[propext, Classical.choice, Quot.sound]`,
  no `sorry`.
- [ ] `lean_verify` on `endCharStep_correct` and the Phase-2 bridge lemma = the same axiom set.
- [ ] `git status --short` shows only `Base.lean` under `Theories/` modified (no frozen-file /
  `KampPrior.lean` edits).
- [ ] `endChar` and `endChar_correct` are top-level, name-citable declarations.
- [ ] No occurrence of `nf_char3_deeper_split` in any new code; anchors provably `{x,t}` (<=2).

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` — additive: the
  step-unfolding lemma, the arity-4->arity-3 collapse bridge, `endCharStep`/`endCharStep_correct`,
  and `endChar`/`endChar_correct` (recursion on `k`).
- `specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/plans/01_recursive-endchar-primitive.md`
  (this plan).
- `specs/349_build_recursive_endchar_navigated_arity3_endpoint_primitive/summaries/01_recursive-endchar-primitive-summary.md`
  (on completion).

## Rollback/Contingency

- The work is purely additive to `Base.lean`; rollback is `git checkout` of `Base.lean` to the
  pre-task commit (no other files touched). Snapshot before any intentional rollback per the
  "No Destructive Git on Uncommitted Work" rule.
- If Phase 2 or Phase 3 hits the anchor-collapse wall and cannot close green without the forbidden
  `nf_char3_deeper_split` tower, mark the phase `[BLOCKED]`, document the exact goal state and the
  missing structural lemma, return `status: partial` with `requires_user_review: true`, and
  escalate — do NOT land a vacuous or `sorry`'d `endChar`. Each earlier green phase remains
  committed so no progress is lost.
