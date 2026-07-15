# Implementation Plan: M2 Scope-and-Document (M1 refuted)

- **Task**: 369 - M1 endpoint kvE_futPos supply / break render cycle
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None (parent task 358 depends on this task)
- **Research Inputs**: reports/01_m1-endpoint-firing-adjudication.md (VERDICT: M1 NOT PROVABLE)
- **Artifacts**: plans/01_m2-scope-and-document.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/rules/status-markers.md
- **Type**: lean4

## Overview

**This is an M2 scope-and-document plan, NOT an M1 build.** The mandatory Phase-1 feasibility
adjudication (reports/01) returned a HIGH-confidence, adversarially verified verdict: **M1
(`kvE_futPos_supply_of_endpoint`) is NOT PROVABLE from its stated hypotheses; fall back to M2 (a
de-folded interior carrier).** The task-original "build the lemma + enrich `hepL`/`hepR` binders +
lake green" clauses were *conditional on M1 being provable* and therefore no longer apply. Do not
plan or dispatch an M1 lemma build.

The grounded refutation (reports/01 §"The bounded adjudication"): the obligation upgrades the
arity-1 `Until` witness that `igEpR@t` fires (the F1-lossy `igFoldBit` fold,
`InteriorGateGeneralK.lean:318`, projects arity-4 subs to arity-1 via `nfk_projFresh`) into a full
arity-4 σ-realizer. That upgrade needs depth-`(k+1)` saturation of the *specific* `M`, which is (a)
absent from M1's signature and (b) precisely the task-358 recursion's own conclusion (circular).
Every non-firing hypothesis (`hAmb`, `hcons`, `hmark`, `hfut`) is model-independent and cannot
manufacture a specific-`M` arity-4 witness; `ExistProviders.correct` is a depth-`k` tester, not a
depth-`(k+1)` generator.

**Definition of done for task 369** (redefined by the Phase-1 gate refutation): an authoritative,
precisely-grounded M2 scope-and-document artifact lands, plus a documented recommendation to spawn
the M2 execution task and to freeze task-358 Plan v09 Phase 5 against the current under-provisioned
interface. Optionally, a cheap sorry-free Phase-0 refutation probe upgrades the verdict from HIGH
confidence to machine-certain. **M2's actual carrier redesign is explicitly OUT OF SCOPE** for
task 369 — it becomes a spawned follow-up task.

### Research Integration

- reports/01_m1-endpoint-firing-adjudication.md — integrated in plan version 1 (2026-07-14).
  Supplies the refutation verdict, the H3 Tier-1 lemma-mapping table (13 findings), the M2 scope
  enumeration (§"M2 — the fallback"), the optional Phase-0 certainty gate (§"Optional Phase-0
  certainty gate"), and the H4 adversarial self-verification residual.

### Preserved Assets

The following work is complete and must not regress:

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| Phase-1 feasibility adjudication (M1 refutation verdict) | reports/01_m1-endpoint-firing-adjudication.md | [COMPLETED] | 2026-07-14 |
| Landed doppelgänger probe (sorry-free) | ExteriorPinnedProbeM1K.lean:600-669 | [COMPLETED] `lean_verify` = `[propext, Classical.choice, Quot.sound]` | 2026-07-14 (reports/01 finding #11) |
| task-363 fiber-consistency guard (excludes probe fake) | ExteriorFiberConsistencyProbeK.lean:305 (`kvE_probe363_qnfG1_antecedent_fails`) | [COMPLETED] | 2026-07-14 (reports/01 finding #12) |
| Frozen private carrier defeq (byte-locked) | CarrierKv.lean:246-249 + `bracketEndChar_kv_succ_eq` rfl (InteriorGateGeneralK.lean:339-351) | [COMPLETED / FROZEN] | pre-existing (Phase 1-4 tree byte-locked) |

### Source-to-Implementation Mapping (Tier 1)

Every load-bearing decision in this plan cites reports/01, which is itself grounded in landed
source (`lean_hover_info` / source-read confirmed) and literature (`rabinovich_2014`).

| Plan element | Source (reports/01) | Load-bearing file:line |
|--------------|---------------------|------------------------|
| M1 refutation (arity-1 → arity-4 level gap) | §"The bounded adjudication"; findings #1-#10 | `igFoldBit` InteriorGateGeneralK.lean:318-332; `igEpR` :219-225; `kampPrior_futRealizer_of_pos` KampPrior.lean:1662-1716 |
| Phase-0 certainty probe target | §"Optional Phase-0 certainty gate"; H4 residual row | `ExteriorPinnedProbeM1K.lean:600-669` (extend); collision test vs `kvE_fiberConsistent σ = true` |
| M2 carrier-redesign locus | §"M2 scope" item 1 | InteriorGateGeneralK.lean:209/219/243 (igEpL/igEpR/igPtW), :318 (igFoldBit), :290 (igBody), :276 (igMkDisjunct) |
| M2 frozen-boundary collision | §"M2 scope" item 2 | CarrierKv.lean:246-249; `bracketEndChar_kv_succ_eq` InteriorGateGeneralK.lean:339-351 |
| M2 render bridge replacement | §"M2 scope" item 3 | `igFoldBit_realize_iff` InteriorGateGeneralK.lean:563 |
| M2 assembly + binders | §"M2 scope" item 4 | ExteriorGateAssembleK.lean:337-338; KampPrior.lean:955-1000; drivers :1662/:1721 |
| M2 downstream re-verification | §"M2 scope" item 5 | InteriorHrealSupplyK.lean:116; ExteriorDeepExclSupplyK.lean:105/133 |
| task-358 freeze recommendation | Planner instruction (headline); reports/01:41-42 | KampPrior.lean row-5/6 binders; task-358 Plan v09 Phase 5 (`kampPrior_hreal_supply`) |

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from reports/01 (verdict + H2/H4 notes)
and the task-358 render-cycle history.

**Do NOT**:
- **Do NOT plan or attempt an M1 lemma build** (`kvE_futPos_supply_of_endpoint` or its past mirror).
  reports/01 proves it non-provable from `hepR`/`hAmb`/`hcons`/`hmark`/`hfut` + depth-`k` `P`; the
  bridging object (depth-`(k+1)` saturation of the specific `M`) is absent and circular.
- **Do NOT re-dispatch the `kampPrior_hreal_supply` body** (InteriorHrealSupplyK.lean:116) against
  the current binder *or* an `hepR`-enriched binder — reports/01 (line 42) certifies it is provably
  under-provisioned. Task-358 Plan v09 Phase 5 must not run until M2 lands.
- **Do NOT retain the InteriorHrealSupplyK.lean:116 strategic sorry as a resting state.** Per
  reports/01 H2 note (line 212-215): the sorry-free path is M2 (or its Phase-0 refutation probe).
  If a phase cannot proceed sorry-free, the correct terminus is `[BLOCKED]` for user review, not a
  retained sorry.
- **Do NOT modify the frozen private carrier** `bracketEndChar_kv` (CarrierKv.lean:246-249) or
  anything the `bracketEndChar_kv_succ_eq` rfl (InteriorGateGeneralK.lean:339-351) is locked to in
  THIS task. The modify-frozen-vs-parallel-carrier decision is the *spawned* M2 task's Phase-0
  architectural gate, not task-369 work.
- **Do NOT attempt any speculative M2 carrier-redesign implementation.** The only Lean code
  task-369 may land is the bounded Phase-0 certainty probe (one probe leaf, no frozen-boundary
  risk). Everything else in M2 is documentation only.
- **Do NOT let the Phase-0 probe balloon.** It has a fixed attempt budget: if a fiber-consistent
  fold-collision witness does not land cleanly, the phase documents the obstruction and stops. It
  must NOT expand into open-ended witness search.

**MUST preserve**:
- The sorry-free status of `ExteriorPinnedProbeM1K.lean` and `ExteriorFiberConsistencyProbeK.lean`
  (findings #11, #12). Any Phase-0 probe addition is additive and must keep the leaf sorry-free.
- The byte-for-byte frozen carrier defeq (`bracketEndChar_kv_succ_eq` rfl) and every Phase 1-4
  byte-locked file.
- The axiom floor: `[propext, sorryAx, Classical.choice, Quot.sound]` — no new axioms, no vacuous
  defs.

**Design decisions are SETTLED** (do not re-open without a concrete counterexample):
- **M1 is refuted.** The verdict rests on the model-independence classification of M1's hypotheses
  (reports/01 findings #3, #8, #9, #10 + §"Why hcons does NOT rescue M1"), which is airtight —
  NOT on the landed probe (whose fake has `hcons = false`). Re-opening requires exhibiting a
  specific-`M` arity-4 witness from the stated hypotheses, which reports/01 shows cannot exist.
- **The fix direction is de-folding (M2), not a firing oracle over the fold.** reports/01
  §"Rabinovich fidelity" (finding #13): the paper (`rabinovich_2014` Cor 5.4(1)⇐) fires the witness
  directly off `βn+1 Until αn+1` carrying the full ordered bracket sequence and never folds; Lean's
  `igFoldBit` fold IS the divergence. Inventing an arity-1 → arity-4 upgrade oracle is rejected.
- **M2 execution is out of scope for task 369** and becomes a spawned multi-phase follow-up task.

## Goals & Non-Goals

- **Goals**:
  - Produce the authoritative M2 scope-and-document artifact (reports/02) that a future
    implementation task executes against, preserving every file:line reference and target signature
    from reports/01.
  - Optionally upgrade the M1-refutation from HIGH confidence to machine-certain via a bounded,
    sorry-free Phase-0 refutation probe.
  - Document the recommendation to (a) spawn the M2 carrier-redesign execution task and (b) freeze
    task-358 Plan v09 Phase 5 against the current under-provisioned interface.
- **Non-Goals**:
  - Building M1 (`kvE_futPos_supply_of_endpoint`) — proven impossible.
  - Any M2 carrier-redesign implementation (de-folded `igEpR`/`igPtW`, parallel carrier, correctness
    chain re-proof) — deferred to the spawned follow-up task.
  - Modifying the frozen carrier or enriching `hepL`/`hepR` binders in task-358 files.
  - Creating the follow-up task or editing task-358's dependency in state.json (Phase 2 only
    *recommends*; actual creation/edits are performed by the orchestrator/implementer).

## Risks & Mitigations

- **Risk**: Phase-0 probe balloons into an open-ended search for a fiber-consistent fold-collision
  witness. **Mitigation**: fixed attempt budget (Postmortem Constraints); on non-landing, document
  the obstruction in reports/02 and stop — the HIGH-confidence verdict already stands without it.
- **Risk**: The M2 scope doc drifts into vague gestures, losing the actionable file:line precision.
  **Mitigation**: reports/02 must reproduce the reports/01 §"M2 scope" 5-item enumeration verbatim
  with every file:line and every target signature; a checklist in Phase 1 enforces this.
- **Risk**: A future dispatch re-attempts M1 or re-dispatches `kampPrior_hreal_supply`.
  **Mitigation**: Postmortem Constraints are binding; Phase 2 records the task-358 freeze explicitly
  so the orchestrator wires the dependency.
- **Risk**: Phase-0 probe edit accidentally desyncs the frozen carrier defeq. **Mitigation**: probe
  is confined to a probe/scratch leaf (`ExteriorPinnedProbeM1K.lean`), additive only; `lake build`
  green + `lean_verify` axiom check gate the phase.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0, 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel. Phase 0 (Lean probe, `ExteriorPinnedProbeM1K.lean`)
and Phase 1 (markdown `reports/02`) touch disjoint files and may run concurrently; if both run,
Phase 1's "Certainty status" line is updated with Phase 0's outcome. Phase 2 depends on the landed
reports/02 (Phase 1).

### Phase 0: Bounded fiber-consistent fold-collision refutation probe [COMPLETED]

**Outcome (2026-07-14, sess_1784091172_81406c):** Bounded probe landed sorry-free but did NOT
reach machine-certainty; verdict stays HIGH confidence (an acceptable Phase-0 outcome per the
bounded stop). Added `kvE_probeM1_foldCollision_hcons_status` (ExteriorPinnedProbeM1K.lean, tail)
— `lean_verify` = `[propext, Classical.choice, Quot.sound]`, no `sorryAx`; `lake build` green.
The certificate machine-checks the fold collision (`nfk_projFresh m1sigma = nfk_projFresh m1tau`),
fiber-consistency of the realized member (`kvE_fiberConsistent m1tau = true`, ambient-marked), and
the non-realization of its fold-mate `m1sigma`. **Documented obstruction:** the certainty gap is
that the non-realized fold-mate (`m1sigma`) has `kvE_fiberConsistent = false`; closing it needs a
fiber individually co-realizable yet not jointly pinned in this `M` (the model-independence gap
reports/01 rated Medium/unverified) — deliberately not attempted (ballooning boundary).

**Category: LAND LEAN CODE** (optional; recommended certainty gate)

- **Goal:** Convert the HIGH-confidence M1 refutation to machine-certain by landing a sorry-free
  fiber-consistent fold-collision witness, per reports/01 §"Optional Phase-0 certainty gate" and the
  H4 residual (reports/01:192, 203-210).
- **Grounding:** reports/01 notes the one honest residual — a machine-*certain* refutation needs a
  `σ` with `kvE_fiberConsistent σ = true` (the landed doppelgänger has `hcons = false`, so it does
  not by itself refute M1-under-`hcons`) together with a model `M` where the `igEpR@t` fold fires
  but the arity-4 realizer fails. Landing such a σ refutes M1 outright (not merely
  unprovable-from-these-hypotheses).
- **Target signature (drawn from reports/01, mirroring the existing casts):** extend
  `ExteriorPinnedProbeM1K.lean` (alongside `kvE_probeM1_interiorGuard_identical` :842 and
  `m1_no_marked_mate`) with a witness of the shape:
  - a concrete `σ : NormalForm sig (k+1) 4` with `kvE_fiberConsistent σ = true` AND `qnf.2 σ = true`
    AND `kvE_futAdmissible σ = true`, whose fold projection `nfk_projFresh σ` collides with a
    distinct fiber-consistent type (a fiber-consistent fold-collision — the pair
    `(zone, nfk_projFresh)` is shared, per reports/01 §"Why hcons does NOT rescue M1"), and
  - a model `M` (or the existing probe `M`) where `igEpR@t`'s FutT conjunct
    `Until(charK (nfk_projFresh σ), ⊤)` fires at `t` but `¬ ∃ x1 > t, nf_eval_nf M (k+1) 4
    [x1,w,x,t] σ`. Certify sorry-free via `lean_verify` (axiom set must remain
    `[propext, Classical.choice, Quot.sound]`; no `sorryAx`).
- **Tasks:**
  - [x] Read `ExteriorPinnedProbeM1K.lean:600-669, :842` and `ExteriorFiberConsistencyProbeK.lean:305`
    to reuse the doppelgänger scaffold and the `kvE_fiberConsistent` evaluator.
  - [ ] Construct the fiber-consistent fold-collision `σ` (contrast with the `hcons=false` fake at
    `:628-669`): the new witness must PASS `kvE_fiberConsistent` while sharing its
    `(zone, nfk_projFresh)` fold bits with a distinct type. *(deviation: skipped — the certainty-closing
    witness requires the non-realized fold-mate to pass `hcons`, i.e. a fiber individually
    co-realizable yet not jointly pinned in this `M`; that is the model-independence gap reports/01
    rated Medium/unverified and is the plan's explicit ballooning boundary — stop-and-document.)*
  - [x] State and prove sorry-free: fold fires yet the arity-4 realizer is absent in `M` at every
    `x1 > t`. *(deviation: altered — landed the one-sided certificate `kvE_probeM1_foldCollision_hcons_status`
    (fold collision + realized-side `hcons=true` + non-realization of the fold-mate) rather than a
    both-consistent witness; pins the residual as machine-checked facts.)*
  - [x] `lake build` green; `lean_verify` the new decl — axiom floor unchanged
    (`[propext, Classical.choice, Quot.sound]`, no `sorryAx`).
  - [x] Record the machine-certain outcome (or the obstruction) for Phase 1's "Certainty status" line.
    *(outcome: obstruction documented; verdict remains HIGH confidence.)*
- **Bounded-unit stopping condition:** one probe declaration in one leaf. If the witness does not
  land sorry-free within the phase, STOP: document the specific obstruction (which step failed:
  fiber-consistency, fold-collision, or model non-realization) in reports/02 and leave the verdict
  at HIGH confidence. Do NOT expand into open-ended witness search or touch any non-probe file.
- **Estimated output:** ~120-200 lines Lean (one probe decl + supporting `decide`/`Bool` lemmas),
  additive to `ExteriorPinnedProbeM1K.lean`.
- **Done when:** either (a) the fiber-consistent fold-collision probe lands sorry-free, `lake build`
  is green, `lean_verify` shows no `sorryAx`, and the M1 refutation is machine-certain; OR (b) a
  bounded obstruction is documented and the phase stops with the verdict at HIGH confidence.
- **Timing:** 1-1.5 hours (hard cap; stop-and-document on overrun).
- **Depends on:** none (optional; parallel with Phase 1).

### Phase 1: M2 carrier-redesign scope-and-document artifact [NOT STARTED]

**Category: WRITE DOCUMENTATION** (primary deliverable)

- **Goal:** Produce the authoritative M2 scoping document
  `reports/02_m2-carrier-redesign-scope.md` that a future M2 execution task executes against,
  reproducing every file:line reference and target signature from reports/01 §"M2 — the fallback".
- **Tasks:** the document MUST capture, from reports/01:
  - [ ] **Header/verdict restatement:** M1 refuted (reference reports/01 verdict); this is the M2
    fallback scope. State the arity-1 → arity-4 level gap and the de-fold fix direction (finding #13,
    Rabinovich fidelity) as SETTLED.
  - [ ] **De-folded interior carrier design** (reports/01 §"M2 scope" item 1): `igEpL`/`igEpR`/`igPtW`
    (InteriorGateGeneralK.lean:209/219/243) and `igFoldBit` (:318) replaced or paralleled by variants
    keyed on the full arity-4 fiber `σ : NF (k+1) 4` rather than the projected
    `(zone, χ : NF (k+1) 1)` pair; consumed by `igBody` (:290) and `igMkDisjunct` (:276).
  - [ ] **Frozen-carrier boundary hard edge** (item 2): the fold is baked into the frozen private
    carrier `bracketEndChar_kv`'s `k+1` branch (CarrierKv.lean:246-249), and
    `bracketEndChar_kv_succ_eq` (InteriorGateGeneralK.lean:339-351) is a pure `rfl` against it.
  - [ ] **Two architectural options** (item 2): (a) modify the frozen `bracketEndChar_kv` — breaking
    the byte-for-byte defeq the entire downstream is locked to; vs (b) a parallel non-folded carrier
    + re-prove the whole correctness chain (`igBody_holds_iff` :359, `step_sound` :1043, its fiber
    delegation :1150-1165, `igFoldBit_realize_iff` :563 analog). Flag this as the M2 **Phase-0
    architectural gate** (frozen-boundary decision).
  - [ ] **Render bridge replacement** (item 3): `igFoldBit_realize_iff` (:563, the render-gated
    bridge M1 routed around) replaced by a de-folded `endpoint → arity-4 realizer` extraction needing
    no render.
  - [ ] **Assembly + binders** (item 4): ExteriorGateAssembleK.lean:337-338 (render production) and
    the KampPrior.lean:955-1000 row-5/6 binders (`hreal`/`hexcl`) re-typed to de-folded endpoint
    evals; drivers `kampPrior_{fut,past}Realizer_of_pos` (:1662/:1721) re-wired.
  - [ ] **Downstream re-verification** (item 5): InteriorHrealSupplyK.lean (`kampPrior_hreal_supply`
    body, currently the :116 strategic sorry), ExteriorDeepExclSupplyK.lean:105/133 (rows 12-13
    general-`m` arms, currently sorried and render-dependent), and every leaf citing the render.
  - [ ] **Cost/risk signal** (reports/01 §"M2 cost signal"): carrier-redesign refactor crossing the
    frozen-carrier boundary; substantially larger than a leaf addition; touches Phase 1-4 byte-locked
    files; size as multi-phase with the frozen-boundary decision as its Phase-0 gate.
  - [ ] **Certainty status line:** record whether Phase 0 landed the fiber-consistent fold-collision
    probe (machine-certain) or the verdict remains HIGH confidence.
- **Estimated output:** ~200-350 lines markdown (design doc; documentation-heavy, not a proof).
- **Done when:** `reports/02_m2-carrier-redesign-scope.md` exists and contains all 6 reports/01
  §"M2 scope" items with verbatim file:line references, both architectural options, the Phase-0
  architectural gate, and the cost/risk signal.
- **Timing:** 1.5-2 hours.
- **Depends on:** none (self-contained from reports/01; parallel with Phase 0).

### Phase 2: Spawn recommendation + task-358 dependency note [NOT STARTED]

**Category: WRITE DOCUMENTATION**

- **Goal:** Document, at the end of reports/02 (a "Recommendations & Handoff" section), the two
  orchestration actions the M2 verdict implies — for the orchestrator/implementer to execute, not
  performed silently here.
- **Tasks:**
  - [ ] **(a) Spawn the M2 execution task:** recommend creating a follow-up task for the M2 carrier
    redesign (multi-phase), scoped by reports/02, with its own Phase-0 architectural gate
    (modify-frozen vs parallel-carrier). Note it depends on task 369 and inherits the file_scope
    (InteriorGateGeneralK.lean, CarrierKv.lean, ExteriorGateAssembleK.lean, KampPrior.lean,
    InteriorHrealSupplyK.lean, ExteriorDeepExclSupplyK.lean).
  - [ ] **(b) Freeze task-358 Plan v09 Phase 5:** record that task-358's Plan v09 Phase 5
    (`kampPrior_hreal_supply`, InteriorHrealSupplyK.lean:116) must NOT be re-dispatched against the
    current under-provisioned interface (reports/01:41-42) and now depends on the M2 outcome.
  - [ ] State explicitly that actual task creation and dependency/state.json edits are performed by
    the orchestrator/implementer (via `/spawn` or `/task`), not by this documentation phase.
- **Estimated output:** ~40-80 lines markdown (appended section in reports/02).
- **Done when:** reports/02 contains a "Recommendations & Handoff" section with both (a) the M2
  spawn recommendation and (b) the task-358 freeze, and the explicit note that creation/edits are
  performed downstream.
- **Timing:** 0.5 hour.
- **Depends on:** 1.

## Testing & Validation

- [ ] Phase 0 (if run): `lake build` green; `lean_verify` on the new probe decl returns
  `[propext, Classical.choice, Quot.sound]` with NO `sorryAx`; the probe leaf remains sorry-free.
- [ ] Phase 0 (if not landed): a bounded obstruction is documented; no non-probe file touched; no
  retained sorry introduced anywhere.
- [ ] Phase 1: reports/02 exists and every reports/01 §"M2 scope" file:line reference is reproduced
  verbatim (spot-check `igFoldBit:318`, `CarrierKv.lean:246-249`, `igFoldBit_realize_iff:563`,
  `kampPrior_hreal_supply:116`).
- [ ] Phase 2: reports/02 "Recommendations & Handoff" section names both actions and the
  downstream-execution caveat.
- [ ] Global: no M1 lemma build attempted; no `kampPrior_hreal_supply` re-dispatch; the frozen
  carrier is untouched.

## Artifacts & Outputs

- plans/01_m2-scope-and-document.md (this file)
- reports/02_m2-carrier-redesign-scope.md (Phase 1 primary deliverable; Phase 2 appends the
  "Recommendations & Handoff" section)
- ExteriorPinnedProbeM1K.lean (Phase 0, optional; additive sorry-free probe decl OR unchanged if the
  phase documents an obstruction)
- summaries/01_m2-scope-and-document-summary.md (implementation summary)

## Rollback/Contingency

- **Phase 0 probe fails to land:** no rollback needed — the probe is additive and confined to a
  probe leaf; document the obstruction in reports/02 and keep the HIGH-confidence verdict. If any
  probe edit desyncs `lake build`, revert the additive decl (the leaf returns to its prior
  sorry-free state); do NOT touch non-probe files to "fix" it.
- **M2 scope doc cannot be made precise (reports/01 references stale):** if a cited file:line no
  longer matches source, re-read the current source, correct the reference in reports/02, and note
  the drift; do NOT proceed with vague scope. If scope cannot be made sorry-free-executable, the
  correct terminus is `[BLOCKED]` for user review (per Postmortem Constraints), never a retained
  sorry.
- **No git rollback of task-358 files** is in scope: task 369 writes only its own artifacts and,
  optionally, an additive probe decl.
