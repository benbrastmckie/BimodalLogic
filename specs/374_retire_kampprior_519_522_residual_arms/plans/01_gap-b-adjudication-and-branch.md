# Implementation Plan: Gap B Adjudication and Branch (retire KampPrior :519/:522 residual arms)

- **Task**: 374 - retire_kampprior_519_522_residual_arms
- **Status**: [NOT STARTED]
- **Effort**: 5 hours (expected path: Phases 1 + 2; Phase 3 is a mutually exclusive contingency)
- **Dependencies**: None (task 373 orchestration completed; task 358 superseded)
- **Research Inputs**:
  - specs/374_retire_kampprior_519_522_residual_arms/reports/01_m2-asset-sufficiency-adjudication.md (H4-verified, authoritative)
  - specs/358_realization_recursion_nf_nvar_exist_all_depths/reports/11_render-cluster-divergence-audit.md (prior diagnosis, reference)
- **Artifacts**: plans/01_gap-b-adjudication-and-branch.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/plan-format-enforcement.md
  - .claude/rules/state-management.md
  - .claude/extensions/lean/context/contracts/reference-grounding.md (H3 lean4 Tier 1)
- **Type**: lean4

## Overview

Task 374's definition of done is: zero sorries in `KampPrior.lean`, full `lake build` green, no
new axioms. The two remaining sorries are `KampPrior.lean:519` (the n=1, k>=2 arm of
`nf_nvar_exist_all_depths`) and `KampPrior.lean:522` (the n>=2 arm). The H4-verified research
report (01) adjudicates the M2 assets as **INSUFFICIENT** for :519 as signed: the two abstract
char seams the entire `*Fib` certificate stack threads — `hcharFib`
(`ExteriorGateAssembleK.lean:574-578`) and `hcharFibSoundP` (`ExteriorGateAssembleK.lean:579-581`)
— are jointly refutable at any Prior model with >= 2 points and a realized render (Gap B), and
route (b) for :522 is refuted by the all-arity `ExistProviders` dependency (`P.existF 4`, 38
sites). The research's closing contradiction is a 3-step pen-and-paper argument over read
signatures, **not yet a compiled probe** — per the task description's mandate, Phase 1 of this
plan is the bounded feasibility adjudication that compiles that argument as a refutation probe.

**This plan is branch-structured.** Phase 1 settles REFUTED vs NOT-REFUTED mechanically (a
compiling Lean artifact, not a judgement call). Exactly ONE of Phase 2 (REFUTED — the expected
branch) or Phase 3 (NOT-REFUTED — the contingency) executes; the Phase 1 implementer marks the
non-selected branch phase `[COMPLETED]` with a "skipped — branch not taken" annotation so
per-phase dispatch always finds exactly one live phase.

**Definition-of-done transfer (explicit, per task description):** if Phase 1 refutes (expected),
proof construction STOPS. Phase 2 spawns one narrowly-scoped follow-up task (arity-general
zone-decomposed char engine) that inherits the "zero sorries in KampPrior.lean" definition of
done, and task 374 terminates cleanly as adjudication-complete — never `[PARTIAL]` indefinitely.
The two sorries at :519/:522 remain in place, owned by the follow-up.

**Not a skeleton plan** (`plan_metadata.skeleton: false`): the follow-up task's creation is
conditional on Phase 1's compiled verdict, so it is executed at implement time via the spawn
machinery (Phase 2), not allocated at plan time via `{{FOLLOWUP:i}}` tokens. The full spawn
payload is fixed verbatim in Phase 2 so the spawn is mechanical, not a fresh design decision.

### Research Integration

- reports/01_m2-asset-sufficiency-adjudication.md — integrated in plan v1 (2026-07-15). Its
  verdict, gap ledger (Gaps A-E), route adjudication (route (a)-amended), and follow-up target
  specification are the spine of this plan and are NOT re-litigated here.
- reports/11 (task 358 dir) — prior H5 audit; supplies the "do not resume plan v09 /
  folded-carrier interface" and "do not re-open carrier design" postmortem rules.

### Preserved Assets

The following work is complete (`lean_verify` clean this research session: axioms exactly
`{propext, Classical.choice, Quot.sound}`, no sorryAx) and must not regress:

| Component | File | Status | Verified |
|-----------|------|--------|----------|
| `kampPrior_hreal_supply` (row-5 interior realizer, seven zones) | Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorHrealSupplyK.lean:61 | [COMPLETED] | 2026-07-15 |
| `bracketEndChar_kvExtFib_correct_prior` (per-qnf gate certificate) | Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorGateAssembleK.lean:559 | [COMPLETED] | 2026-07-15 |
| `kvE_hsliceFut_supply` / `kvE_hslicePast_supply` (rows 8-9) | .../ExteriorDeepSliceSupplyK.lean:131/161 | [COMPLETED] | 2026-07-15 |
| `kvE_hexclDeepFut_supply` / `kvE_hexclDeepPast_supply` (rows 12-13) | .../ExteriorDeepExclSupplyK.lean:77/107 | [COMPLETED] | 2026-07-15 |
| `kampPrior_site_rungKFib_gate_match` (conditional gate theorem) | Theories/Bimodal/Metalogic/WeakCanonical/Kamp/KampPrior.lean:1058 | [COMPLETED] | 2026-07-15 |

These certificates are sorry-free but **uninstantiable at the :519 site as signed** (that is
Gap B, the thing Phase 1 compiles). The refutation refutes their *hypothesis signatures*, not
their proofs — the follow-up re-signs the seams and re-consumes these assets; no phase of this
plan (and no follow-up scoping language) may propose deleting or rewriting them.

### Source-to-Implementation Mapping (H3 Tier 1, Rabinovich 2014, doc_id `rabinovich_2014`)

Condensed from report 01's full 5-column table (which remains authoritative):

| Source | Prop/Location | Lean Identifier | Type Signature (abbrev.) | Status |
|--------|---------------|-----------------|--------------------------|--------|
| Rabinovich 2014 | Lemma 5.3, chunk_0014 lines 3-41 | `nf_nvar_exist_all_depths` (KampPrior.lean:346-522) | all-depth all-arity existential converter | sorry (arms :519, :522) |
| Rabinovich 2014 | Cor 5.4(1) ⇐, chunk_0015 lines 9-41 | `bracketEndChar_kvFib_realize_futT` / `_realize_pastX` (InteriorGateGeneralK.lean:1565/1597) | render-free endpoint extraction from native `Until`/`Since` firing | transcribed |
| Rabinovich 2014 | Cor 5.4 F_i-chain threading | `ExistProviders` (PriorInterface.lean:38-45) + `kampPrior_existProviders_of_ih` (KampPrior.lean:1278) | all-arity converter family | pending (green at depth 0 only) |
| Rabinovich 2014 | (divergence — no per-point arity-4 char formula exists in the source) | `hcharFib` / `hcharFibSoundP` binders | truth-set = realizer-set seam pair | **refutation target of Phase 1** |

Load-bearing literature facts: Lemma 5.3 is an induction on **n** with all P_i simultaneously
(chunk_0014 lines 7-41) — this is why one arity-general engine must serve both :519 (n=1) and
:522 (n>=2); Cor 5.4(1)'s witness fires directly off the `Until` semantics (chunk_0015 lines
23-29) — order content is structural, never carried by a per-point formula. The seam pair is the
M2 stack's deviation from the source and exactly where the refutation bites.

## Postmortem Constraints

Binding rules for all implementation dispatches. Derived from report 01 (Gaps A-E, contradiction
log), task 358 report 11 (three-dispatch divergence table), and task 370 report 02 (blast-radius
classification).

**Do NOT**:
- Dispatch a direct proof attempt at `KampPrior.lean:519` against the current seam signatures —
  Gap B shows the hypothesis set is false exactly where the ⇐ direction needs it; report 01
  explicitly withdrew this direction after the counterexample construction.
- Resume task 358 plan v09 (crux-first-interior-realizer) or any work against the pre-M2
  folded-carrier interface — refuted by report 11 (F1 lossy-fold refutation, closed circular
  cluster).
- Re-open the carrier design: no edits to the carrier trio (`Base.lean`, `CarrierK1V.lean`,
  `CarrierKv.lean` definitions), the `bracketEndChar_kv` body (CarrierKv.lean:240-249), the defeq
  bridges (InteriorGateGeneralK.lean:339-351; CarrierKv.lean:294-351), or
  `kampPrior_site_rungK_gate_match` (KampPrior.lean:941, live consumer at
  EndIntervalConsumerK.lean:248).
- Restate `nf_nvar_exist_all_depths` to n <= 1 (route (b)) — refuted: `ExistProviders.existF` is
  an all-arity field consumed at `P.existF 4` by 38 sites; a restatement type-breaks
  `kampPrior_existProviders_of_ih` and the entire :519 gate route.
- Treat :522 as freely deferrable if any :519 route uses providers at site depths >= 3 — Gap C
  entanglement: `Pbr : ExistProviders … _k` at gate depth _k >= 1 requires the n+2 arm at lower
  depths. Only the depth-0 bundle is green.
- Edit any existing Lean file in Phase 1 — the probe is additive-only (one new file). A probe
  that "needs" to weaken an existing binder to compile is by definition unfaithful.
- Silently proceed past an inconclusive Phase 1 — an uncompiled probe is NOT a NOT-REFUTED
  verdict (see Phase 1 outcome definitions); escalate as blocked instead.

**MUST preserve**:
- All five Preserved Assets above (re-consumed by the follow-up, never discarded).
- The k<=1 landed arms `kampPrior_case1_arm_k0/_k1` (KampPrior.lean:271/301) and the green
  `| 0 =>` / n=0 arms of the recursion.
- `kampPrior_existProviders_zero` (KampPrior.lean:1409).
- Full `lake build` green at every commit point (the probe file must not break the build).

**Design decisions are SETTLED** (do not re-open without a concrete compiled counterexample):
- M2 de-folded carrier over M1 (task 358 report 11 adjudication; M1 refuted).
- Route (a)-amended for :522 over route (b) (report 01 §Q2: (b) machine-refuted; (a) viable only
  via one arity-general engine serving both arms).
- The follow-up re-signs the additive `*Fib` sibling seams, NOT the frozen defeq surfaces —
  sibling-level, not file-level, frozen-boundary language (report 01 contradiction log item 3;
  task 370 report 02 §3 classifies the siblings as freely-editable additive code disjoint from
  the frozen surfaces).

**Constraint tension (surfaced, resolved by scoping — not silently violated or ignored):** the
task-374 constraint "no refactor of `InteriorGateGeneralK.lean`" collides with the only viable
fix, which re-signs `*Fib` sibling binders **inside that file** (`step_sound` :2101/2115,
`step_complete` :1733). Resolution adopted by this plan: task 374 itself honors the constraint
literally (Phase 1 is additive-only; no phase edits that file), and the spawned follow-up carries
re-scoped **sibling-level** constraint language (frozen surfaces enumerated by declaration, the
additive `*Fib` sibling chain explicitly editable) — see the Phase 2 spawn payload.

## Goals & Non-Goals

- **Goals**:
  - Compile the Gap B joint-seam refutation as a machine-checked probe (Phase 1), converting the
    research's High-confidence pen-and-paper argument into a settled verdict.
  - On REFUTED (expected): create the narrowly-scoped follow-up task with sibling-level frozen
    boundaries and route (a)-amended scope, transfer the definition of done to it, and close
    task 374 cleanly (Phase 2).
  - On NOT-REFUTED (contingency): audit probe fidelity, log the contradiction against the
    H4-verified research, and route to a v2 construction plan (Phase 3).
- **Non-Goals**:
  - Proving :519 or :522 within this task (foreclosed by the expected refutation; even the
    contingency branch routes to a revised plan rather than in-phase proof construction, because
    Gaps C/D/E are probe-independent multi-dispatch volume gaps).
  - Re-signing the `*Fib` seams or building the arity-general engine (that is the follow-up's
    scope, not task 374's).
  - Any edit to frozen surfaces or preserved assets.

## Risks & Mitigations

- **Risk**: The probe compiles only after weakening the seam binder shapes, producing a vacuous
  refutation. **Mitigation**: Phase 1 requires the probe's hypothesis pack to mirror the binders
  byte-faithfully from `ExteriorGateAssembleK.lean:574-581` / `KampPrior.lean:1073-1082` (cite
  line ranges in the probe's docstring); Phase 3's fidelity audit is the backstop.
- **Risk**: Probe does not close within one dispatch (budget exhaustion) and the implementer
  improvises a branch choice. **Mitigation**: outcome I (inconclusive) is an explicit third
  outcome that BLOCKS instead of branching; the phase's stopping condition is mechanical.
- **Risk**: Spawn wiring leaves task 374 dependent on the follow-up, stranding it un-completable.
  **Mitigation**: Phase 2 explicitly requires successor-style wiring (follow-up does not gate
  374's completion) and verifies 374's state entry after the spawn.
- **Risk**: The follow-up spawn payload drifts from the research's target specification.
  **Mitigation**: the payload is fixed verbatim in Phase 2 below, traceable to report 01 §Q1
  ("Exact missing statement") and §Recommended next steps.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 XOR 3 (branch: Phase 1 verdict) | 1 |

Phases 2 and 3 are mutually exclusive branches, never parallel. No parallel-dispatch opportunity
exists in this plan (H7 territory: Phase 1 owns exactly one new file; Phases 2/3 own only
specs/ artifacts and state).

**Branch condition (mechanical)** — Phase 1 terminates in exactly one of three outcomes:

- **Outcome R (REFUTED — expected)**: the probe file compiles inside the library build with a
  sorry-free theorem `seamPair_joint_refutation : … → False` whose hypothesis pack mirrors the
  `hcharFib`/`hcharFibSoundP` binder shapes, and `lean_verify` reports axioms within
  `{propext, Classical.choice, Quot.sound}`. → Execute Phase 2; mark Phase 3 `[COMPLETED]`
  ("skipped — branch not taken: Phase 1 outcome R").
- **Outcome S (NOT-REFUTED)**: instead of the False-proof, a compiling, sorry-free **witness
  instantiation** lands: a concrete `charFib` family together with proofs of BOTH seam
  hypotheses at the probe instance (same binder shapes, no weakening). → Execute Phase 3; mark
  Phase 2 `[COMPLETED]` ("skipped — branch not taken: Phase 1 outcome S").
- **Outcome I (inconclusive)**: neither R nor S compiles within the Phase 1 dispatch budget. →
  Mark Phase 1 `[PARTIAL]`, do NOT touch Phases 2/3, write handoff with the concrete blocking
  step; the orchestrator escalates (re-dispatch Phase 1 or /errors). Silence is forbidden.

### Phase 1: Compile the Gap B seam-pair refutation probe [COMPLETED]

**VERDICT: Outcome R (REFUTED)** — recorded 2026-07-15. The probe
`Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SeamPairRefutationProbe.lean`
compiles inside the full library build (green, 1761 jobs) with the sorry-free theorem
`seamPair_joint_refutation : … → False` whose hypothesis pack mirrors the
`hcharFib`/`hcharFibSoundP` binders byte-faithfully (source line ranges quoted in the module
docstring), plus the concrete non-vacuity instance `seamPair_joint_refutation_int` over
`(ℤ, <)` with `x = 0 < w0 = 1 < t = 2`, `qnf*` realized (`spQnf_render`) and satisfying the six
gate order-atom hypotheses (`spQnf_order_atoms`). `lean_verify` on both theorems: axioms exactly
`{propext, Classical.choice, Quot.sound}`, no sorryAx, no warnings. KampPrior sorry census
unchanged (exactly `:519`/`:522`); no new axioms; no vacuous defs; preserved assets
(`kampPrior_hreal_supply`, `kampPrior_site_rungKFib_gate_match`) spot-checked `lean_verify`
clean. → Next phase: Phase 2 (REFUTED branch); Phase 3 skipped.

- **Goal:** Convert report 01's Gap B counterexample (3-step argument, High confidence,
  machine-probe pending) into a compiled Lean artifact that settles REFUTED vs NOT-REFUTED.
- **Tasks:**
  - [x] Create ONE new additive file:
        `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SeamPairRefutationProbe.lean`
        (style precedent: `RefutationF2.lean`, `ExteriorPinnedProbe358K.lean` in the same
        directory). No edits to any existing file.
  - [x] State the hypothesis pack mirroring the seam binders **byte-faithfully** from
        `ExteriorGateAssembleK.lean:574-581` (cross-check `KampPrior.lean:1073-1082`,
        `InteriorGateGeneralK.lean:2115`): `hcharFib` = render-gated ↔ over `(σ, u)`;
        `hcharFibSoundP` = w-universal, unguarded, qnf-independent →. Quote the source line
        ranges in the probe's docstring.
  - [x] Prove `seamPair_joint_refutation : … → False` following report 01 Gap B verbatim:
        (1) take a Prior model `M` with >= 2 carrier points, `x < t`, and a realized render at
        witness `w0` — `qnf*` = the depth-(k+2) characteristic 3-type of `(w0,x,t)` realized via
        `nf_characteristic_satisfies` (NormalForm.lean), satisfying the six bracket order-atom
        hypotheses since `x < w0 < t`;
        (2) let `σ*` = the characteristic fiber of `(w0,w0,x,t)` — order atoms `(0<1) = false`,
        `(1<0) = false`; apply `hcharFib` `.mpr` at `w := w0` to get
        `temporal_truth M atomMap w0 (charFib (k+1) σ*)`;
        (3) apply `hcharFibSoundP` at any `w' ≠ w0` to get
        `nf_eval_nf M (k+1) 4 [w0, w', x, t] σ*`; its atom layer forces
        `¬(w0 < w') ∧ ¬(w' < w0)`, contradicting linearity with `w' ≠ w0`.
        A concrete two-point (or ℤ) instance may be used to supply `M`; the ingredients are all
        named in report 01 (order-atom evaluation at `KampPrior.lean:1064-1069`).
  - [x] Run `lake build` (green, whole library) and `lean_verify` on the probe theorem (axioms
        within `{propext, Classical.choice, Quot.sound}`, no sorryAx).
  - [x] Record the verdict (R, S, or I per the branch condition above) in this plan file under
        the Phase 1 heading and in the progress file; on R or S, flip the non-selected branch
        phase heading to `[COMPLETED]` with the skip annotation.
  - [x] Commit the green probe per git-workflow (`task 374 phase 1: …`).
- **Bounded-unit stopping condition:** one theorem in one new file. Target ~30-60 lines, hard cap
  ~120 lines. If the False-goal resists closure, ONE pivot is permitted within the same dispatch:
  attempt the Outcome S witness instantiation instead (a genuine failure mode of a refutation
  probe is that the hypotheses are satisfiable — exhibiting the witness is the honest converse).
  If neither closes by the end of the dispatch: Outcome I, mark `[PARTIAL]`, stop.
- **Estimated output:** ~60 lines Lean + verdict annotations.
- **Done when:** exactly one of Outcomes R/S/I is recorded with its compiled artifact (R or S) or
  blocking-step handoff (I), the build is green, and the non-selected branch phase is annotated
  (R/S only).
- **Timing:** one dispatch, ~2-3 hours.
- **Depends on:** none

### Phase 2: REFUTED branch — spawn the arity-general char-engine follow-up and close out task 374 [NOT STARTED]

- **Goal:** STOP proof construction per the task directive; create the single narrowly-scoped
  follow-up task carrying sibling-level frozen-boundary language; transfer the definition of
  done; terminate task 374 cleanly.
- **Precondition (mechanical):** Phase 1 recorded Outcome R. If Phase 1 recorded S or I, this
  phase must not run.
- **Tasks:**
  - [ ] Create the follow-up task via the spawn machinery (`/spawn 374` executed by the
        orchestrator, or a skill-spawn/spawn-agent dispatch) using the payload below VERBATIM
        (title and description; description may append the probe file path and final line
        numbers from Phase 1).
  - [ ] Verify wiring is successor-style: the new task appears in `state.json` with its
        description intact, and task 374's entry does NOT depend on it (task 374 completes now;
        the follow-up inherits the definition of done). If the spawn tooling wires a
        parent-depends-on-child dependency, remove it via the sanctioned state-update scripts
        (never raw-edit) and regenerate TODO.md.
  - [ ] Write `specs/374_retire_kampprior_519_522_residual_arms/summaries/01_gap-b-adjudication-summary.md`:
        Phase 1 verdict + probe path, the five preserved assets (untouched), the definition-of-done
        transfer statement naming the follow-up task number, and the explicit note that
        `KampPrior.lean:519/:522` remain as sorries owned by the follow-up.
  - [ ] Write `.orchestrator-handoff.json` (status `implemented`, artifacts = probe + summary,
        `next_action_hint`: complete task 374; note the spawned task number) and update task 374
        via `update-task-status.sh` postflight with a `completion_summary` recording:
        "Adjudication complete: Gap B machine-refuted (SeamPairRefutationProbe.lean);
        :519/:522 definition of done transferred to spawned follow-up task {number}."
  - [ ] Commit per git-workflow (`task 374 phase 2: …`, then `task 374: complete implementation`).
- **Spawn payload (fixed verbatim):**
  - **Title:** `arity_general_zone_decomposed_char_engine`
  - **Description:** "Build ONE arity-general, zone-decomposed char/provider engine for the M2
    de-folded carrier, discharging KampPrior.lean:519 (as its n=1 instance) and KampPrior.lean:522
    (n>=2 instances) together by Rabinovich 2014 Lemma 5.3's induction on n (doc_id
    rabinovich_2014, chunk_0014 lines 7-41; witness extraction per Cor 5.4(1), chunk_0015 lines
    23-29 — order content structural, only unary content rides the formula). MACHINE-GROUNDED
    BASIS: the seam pair hcharFib (ExteriorGateAssembleK.lean:574-578) + hcharFibSoundP (:579-581)
    is jointly refuted (compiled probe: SeamPairRefutationProbe.lean); hcharFib alone is
    additionally uninstantiable at shift-homogeneous Prior models (task 374 report 01, Gap A) —
    so the seams must be RE-SIGNED, not proved. TARGET INTERFACE: anchor-contextual zone-decomposed
    hcharFibZone (sketch: task 374 report 01 §Q1 'Exact missing statement') — order atoms of
    nf_eval_nf reconstructed from zoneHolds + carrier-certified anchor 1-types (pattern:
    step_complete's hz' fold biconditional, InteriorGateGeneralK.lean:1775-1795; endpoint shape:
    bracketEndChar_kvFib_realize_futT, InteriorGateGeneralK.lean:1565), fiber layer discharged
    recursively from the arity-general provider engine, which also supplies existF 4 at lower
    depths (dissolves Gap C, greening kampPrior_existProviders_of_ih beyond depth 0). SCOPE ALSO
    INCLUDES (size these in the plan): general-m supplies for ledger rows 6/10/11 (Gap D — hexcl
    has no general-m supply; hexclSlice* exist only as _zero variants) and the general-k arm
    assembly scaffolding (Gap E — kampArm_*_kv analogs of AggregateHookDischarge/AggregateOffDiagK1).
    FROZEN (sibling-level, NOT file-level): bracketEndChar_kv body (CarrierKv.lean:240-249); both
    defeq bridges (InteriorGateGeneralK.lean:339-351; CarrierKv.lean:294-351); the carrier trio
    definitions (Base.lean / CarrierK1V.lean / CarrierKv.lean); kampPrior_site_rungK_gate_match
    (KampPrior.lean:941, live consumer EndIntervalConsumerK.lean:248). EDITABLE: the additive *Fib
    sibling chain — step_sound (InteriorGateGeneralK.lean:2101/2115), step_complete (:1733),
    bracketEndChar_kvExtFib_correct_prior (ExteriorGateAssembleK.lean:559-660),
    kampPrior_site_rungKFib_gate_match (KampPrior.lean:1058-1181) — classified freely-editable
    additive siblings disjoint from frozen defeq surfaces by task 370 report 02 §3. PRESERVE
    (re-consume, never discard): kampPrior_hreal_supply, kvE_hsliceFut/hslicePast supplies,
    kvE_hexclDeep* supplies, bracketEndChar_kvFib_realize_futT/_pastX, kampPrior_existProviders_zero,
    the landed k<=1 arms. Do NOT restate nf_nvar_exist_all_depths to n<=1 (route (b) refuted:
    ExistProviders.existF is all-arity; P.existF 4 consumed at 38 sites). Do NOT treat :522 as
    deferrable — Gap C entangles it with :519 at site depths >= 3. DEFINITION OF DONE (inherited
    from the adjudication task): zero sorries in KampPrior.lean, full lake build green, no new
    axioms. Expected to need its own multi-phase plan (dispatch with --hard --lit)."
  - **Effort:** large; **task_type:** lean4; **dependencies:** none (successor, not blocker).
- **Estimated output:** ~150 lines (summary + handoff + state updates); no Lean output.
- **Done when:** follow-up task exists in state.json with the payload description; task 374 is
  completion-ready with the transfer recorded; summary and handoff written; commits made.
- **Timing:** one dispatch, ~1-2 hours.
- **Depends on:** 1

### Phase 3: NOT-REFUTED contingency — probe-fidelity audit and construction re-plan [COMPLETED]

**Skipped — branch not taken: Phase 1 outcome R** (the seam pair is machine-refuted; the
precondition "Phase 1 recorded Outcome S" is false, so this phase must not run). Annotated
2026-07-15 by the Phase 1 implementer per the branch condition.

- **Goal:** Handle the surprising outcome honestly: either expose an unfaithful probe (returning
  the adjudication to Outcome R territory) or, if the witness is genuine, log the contradiction
  against the H4-verified research and route to a revised construction plan toward the :519
  general-k proof and :522 via route (a)-amended.
- **Precondition (mechanical):** Phase 1 recorded Outcome S. If Phase 1 recorded R or I, this
  phase must not run.
- **Tasks:**
  - [ ] Fidelity audit: byte-compare the witness instantiation's hypothesis shapes against the
        consumed binders at `KampPrior.lean:1073-1082` and `ExteriorGateAssembleK.lean:574-581`
        (universally quantified `w` in the soundness seam; render-gated ↔ with the exact
        order-atom demands at `KampPrior.lean:1064-1069`). Any weakening (guarded `w`, restricted
        `σ`, altered atom layer) = unfaithful witness.
  - [ ] If unfaithful: correct the probe statement in `SeamPairRefutationProbe.lean` and re-run
        the Phase 1 outcome logic ONCE (a corrected R verdict re-routes to Phase 2 — flip the
        phase annotations accordingly and record the correction).
  - [ ] If faithful: the research's Gap B claim is overturned by machine evidence (precedence:
        compiled probe > report argument). Write a contradiction-resolution note into the
        summary (`summaries/01_gap-b-adjudication-summary.md`) naming exactly which step of the
        report-01 argument fails, and hand off with `next_action_hint: "revise"` so a v02 plan is
        authored for the construction path (:519 via the now-instantiable gate certificate, then
        :522 via route (a)-amended). Do NOT attempt the :519 proof inside this phase — Gaps C/D/E
        (provider entanglement, missing general-m supplies, missing arm-assembly scaffolding) are
        probe-independent, multi-dispatch volume gaps that require their own H8-sized plan.
  - [ ] Update task 374 status per the branch taken (back to Phase 2 flow, or `planned`-pending-
        revision via the orchestrator) and commit per git-workflow.
- **Estimated output:** ~100 lines (audit notes + summary + handoff); <= 20 lines Lean (probe
  statement correction only).
- **Done when:** the audit verdict (unfaithful → corrected probe outcome; faithful → contradiction
  note + revise handoff) is recorded with its artifact; no proof construction attempted.
- **Timing:** one dispatch, ~1-2 hours.
- **Depends on:** 1

## Testing & Validation

- [ ] Phase 1: `lake build` green with `SeamPairRefutationProbe.lean` included; `lean_verify` on
      the probe theorem — axioms within `{propext, Classical.choice, Quot.sound}`, no sorryAx.
- [ ] Phase 1: probe docstring cites the seam binder source line ranges (fidelity traceability).
- [ ] Invariant (all phases): `grep -c "sorry"` over `KampPrior.lean` reports exactly the two
      known arms (:519/:522) — no new sorries introduced anywhere.
- [ ] Invariant (all phases): the five Preserved Assets still `lean_verify` clean (spot-check
      `kampPrior_hreal_supply` and `kampPrior_site_rungKFib_gate_match` after the probe lands).
- [ ] Phase 2: `jq` check that the follow-up task exists in `state.json` with the payload
      description and that task 374's entry has no dependency on it; TODO.md regenerated.
- [ ] Branch integrity: after Phase 1, exactly one of Phases 2/3 is `[NOT STARTED]`; after the
      branch phase completes, no phase remains `[NOT STARTED]`/`[IN PROGRESS]`/`[PARTIAL]`.

## Artifacts & Outputs

- plans/01_gap-b-adjudication-and-branch.md (this file)
- Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SeamPairRefutationProbe.lean
  (Phase 1; additive)
- summaries/01_gap-b-adjudication-summary.md (Phase 2 or 3)
- Spawned follow-up task entry in specs/state.json + specs/TODO.md (Phase 2, expected path)
- specs/374_retire_kampprior_519_522_residual_arms/.orchestrator-handoff.json (per dispatch)

## Rollback/Contingency

- The probe is a single additive file: rollback = delete
  `SeamPairRefutationProbe.lean` (no existing file is edited by any phase, so the library state
  is untouched by construction). Take a `git-snapshot.sh` snapshot before any deletion.
- If Phase 1 lands Outcome I twice (two dispatches without R or S), stop re-dispatching and route
  to `/errors` — per the divergence-audit discipline, a third identical attempt requires an audit,
  not another try.
- If the spawn machinery fails in Phase 2, the follow-up payload above is self-contained: record
  it in the summary and hand off with blockers noting "spawn pending", keeping task 374 at
  `implementing` (recoverable) rather than completing without the transfer target.
- Phases 2/3 touch only specs/ artifacts and state; rollback = git revert of the specific commit.
