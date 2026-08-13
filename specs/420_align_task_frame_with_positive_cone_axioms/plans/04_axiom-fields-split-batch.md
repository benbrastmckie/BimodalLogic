# Implementation Plan: Task #420 (v4) — Four-Axiom Frame Alignment, Phase 14 Split by Size

- **Task**: 420 - align_task_frame_with_positive_cone_axioms
- **Status**: [IMPLEMENTING]
- **Effort**: 5 hours (Phases 1-5, landed) + 5.5 hours (Phases 6-9, landed) + 8 hours
  (Phases 10-13, landed) + ~8 hours (Phases 14.1, 14.2, 15 — the remaining work, re-sized by
  this revision)
- **Dependencies**: Tasks 438, 439 (landed context). **No task-level `420 -> 415` edge** — it was
  deliberately DROPPED on 2026-08-10 to break a real cycle (`420 <-> 415`, and
  `420 -> 415 -> 414 -> 420`) and MUST NOT be re-added by this or any later revision. The former
  Phase-10 *phase-level* wait on 415 is **RETIRED as STALE** by this revision (see
  `### Blocker Retirement Record` below); task 415 remains `implementing`, and nothing in this
  plan waits on it any longer. One joint design question with task 414 remains genuinely open
  (see `### Carried-Forward Open Caveats`).
- **Research Inputs**:
  - `specs/420_align_task_frame_with_positive_cone_axioms/reports/01_taskframe-positive-cone-limit-nullity.md`
    (integrated in plan v1)
  - Dedicated blocker-research pass, 2026-08-10 (delegated inline, no report file; findings
    carried in v2 and re-stated below only where still true)
  - **Blocker-staleness research pass, 2026-08-12** (delegated inline, no report file; verified
    against the live tree with `lake build` green at exit 0 / 2331 jobs and
    `bash scripts/check-paper-definitions.sh` exit 0 case (a), no paper drift — findings recorded
    verbatim in `### Research Integration (v3)` below). Integrated in v3.
  - **Phase-14 sizing measurement pass, 2026-08-12** (produced by the implementation dispatch
    that executed Phases 10-13 and then declined to open Phase 14's batch; no report file — the
    measurements are carried verbatim in the preserved `#### SIZING FINDING` subsection and in
    `### Research Integration (v4)` below). **Newly integrated in this revision**, and it is the
    sole reason this revision exists.
- **Reports Integrated**: `01_taskframe-positive-cone-limit-nullity.md` (v1); inline
  blocker-research findings 2026-08-10 (v2); inline blocker-staleness findings 2026-08-12 (v3);
  inline Phase-14 sizing measurements 2026-08-12 (v4)
- **Artifacts**: plans/04_axiom-fields-split-batch.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v2 landed Phases 1-9 green and committed and left Phase 10 — the structure change adding the
paper's four `def:frame` axioms as `TaskFrame` fields — `[BLOCKED]` on task 415's
`bundleFlowFrame`. Plan v3 retired that blocker as STALE with a recorded reason, re-scoped Phase 10
into an executable sequence (Phases 10-15), and corrected the site inventory from 16 live sites to
14. **Phases 10-13 then landed green and committed, and Phase 14's prerequisite sub-step 14.0
landed with them.**

**This revision (v4) exists for exactly one reason: Phase 14 is mis-sized, and the implementation
dispatch measured how badly before declining to open it.** Phase 14 bundled the four axiom fields
together with two *structural* changes — the `[Nontrivial D]` structure binder and
`Nonempty WorldState` — whose blast radius was never measured when the phase was written. Since
`sorry` is forbidden and no partial field addition builds, opening that batch would have produced
a long red window with nothing committable. **This is a sizing decision, not a lemma gap**: all
four of Phase 14's own pre-batch gates PASS (14 live `where`-sites reconciling with the plan
table, 0 `.mk` sites, a citable landed lemma for every one of the 14, `Boneyard/` exclusion
intact).

v4 implements the dispatch's own recommended resolution, splitting Phase 14 into:
- **Phase 14.1** — the four axiom fields, the per-site binder propagation they force, and the 14
  site discharges. This is the core deliverable and the **only** part Phase 15 depends on.
- **Phase 14.2** — `[Nontrivial D]` as a structure binder and `Nonempty WorldState`. These are
  independent of the four axioms and **gate nothing in Phase 15**.

Nothing in Phases 1-13 is re-run, reverted, or renumbered. They are landed history, preserved
verbatim below, and sub-step 14.0's hoist is preserved as a landed fact. The
`### Blocker Retirement Record` and the `#### SIZING FINDING` are both preserved: the first
because it is the standing reason nothing waits on task 415, the second because it is now the
**justification for this split**, not a resolved observation to be deleted.

**Definition of done for this plan**: `TaskFrame` carries `[Nontrivial D]`, `Nonempty WorldState`,
and the four axiom fields `comp` (biconditional), `serial`, `limit`, `spherical`, each stated
**definitionally** as the corresponding `FormalSystem/Semantics/FrameAxioms.lean` Prop; all 14 live
construction sites discharge every field sorry-free; `forward_comp` survives as the `←` projection
of `comp`; and `Step.lean`'s `step` consumes `F.serial` / `F.interpolates` / `F.spherical` in place
of its explicit hypothesis binders. `lake build` green, zero `sorry`, zero new axiom.

### Blocker Retirement Record (why the Phase-10 blocker is STALE)

**Blocker id**: `parametric-canonical-carrier` (recorded against Phase 10; `blocked_on_task: 415`).

**Recorded text (verbatim, for the record)**: "ParametricCanonicalTaskFrame
(FormalSystem/Metalogic/Algebraic/ParametricCanonical.lean:207-215) has a D-independent MCS-pair
carrier and a duration-blind relation above zero, so it cannot discharge the four def:frame axioms
sorry-free over dense D. Adding [SuccOrder D] [NoMaxOrder D] is not available: the frame witnesses
live theorems stated at Rat and probed at Real. Adding the axiom fields now would break the build
with no sorry-free discharge route."

**Disposition: RETIRED — STALE, not resolved-by-workaround and not silently dropped.** The blocker
is retired because **the object it describes no longer exists**, and because the replacement it
named has landed and is already wired in:

1. **The root cause was deleted.** `FormalSystem/Metalogic/Algebraic/ParametricCanonical.lean` is
   gone from the tree (`FormalSystem/Metalogic/Algebraic/` now holds only `BooleanStructure.lean`,
   `FlowFrame.lean`, `InteriorOperators.lean`, `LindenbaumQuotient.lean`, `README.md`,
   `UltrafilterMCS.lean`). `FormalSystem/Metalogic/Algebraic.lean:19-22` records the deletion in
   the tree itself: "The former parametric canonical model
   (`ParametricCanonical`/`ParametricHistory`/`ParametricTruthLemma`/`RestrictedParametricTruthLemma`/`ParametricCompleteness`)
   violated the frame definition's *Limit* axiom (`def:frame#Limit`) over dense duration types and
   has been deleted; its truth lemma is re-hosted on `bundleFlowFrame` in `FlowFrame.lean`."
   `grep -rn "ParametricCanonicalTaskFrame" FormalSystem/ Tests/ --include=*.lean` outside
   `Boneyard/` returns zero hits. Surviving references are confined to `FormalSystem/Boneyard/`,
   which is unreachable from the build root (`lakefile.lean:16-19` roots only `FormalSystem`;
   `FormalSystem.lean` carries no `Boneyard` import).
2. **The replacement landed and satisfies the recorded Coordination Contract.** `bundleFlowFrame`
   exists at `FormalSystem/Metalogic/Algebraic/FlowFrame.lean:361` with carrier
   `{fam // fam ∈ B.families} × D` and position projection `Prod.snd`;
   `bundleFlow_pos_shift` (FlowFrame.lean:385) proves `TaskRel w y u → u.2 = w.2 + y` — exactly the
   `R w y u → pos u = pos w + y` shape the contract demanded, which is what makes `limit_of_shift`
   applicable.
3. **All three replacement sites are already switched over**: `Completeness.lean:145`,
   `ChronicleToCountermodelBasic.lean:838`, and the ℝ probes at `CompletenessDedekind.lean:76`,
   `:79`, `:85`.
4. **All four axioms are already proved sorry-free for it**: `bundleFlow_comp_iff`
   (FlowFrame.lean:392), `bundleFlow_serial` (:400), `bundleFlow_limit` (:408),
   `bundleFlow_spherical` (:415).

**Consequences of the retirement**:
- Task 415 remains `implementing`. Phase 10 no longer waits on it, on any other task, or on any
  external artifact. **Do NOT re-add the `420 -> 415` `dependencies[]` edge** (2026-08-10
  cycle-breaking decision stands).
- v2's `### Coordination Contract with Task 415` is SUPERSEDED: its "minimum 415 must deliver" is
  delivered, verified above. It is retained in v2 only as the historical statement of what was
  waited on.
- v2's `### Decision Gate Resolution` (Option B: wait for 415's carrier) is DISCHARGED, not
  re-litigated. The wait ended; the work proceeds.
- The `blockers` free-text field on this task's `state.json` entry still carries the retired text
  (and still refers to the plan-v1 phase numbering, "phase 6"). Clearing it is a state-management
  action for postflight, not a plan edit; this record is the authoritative reason.

### Research Integration (v3)

Newly integrated in this revision — the blocker-staleness research pass of 2026-08-12, verified
against the live tree (`lake build` exit 0 / 2331 jobs; `bash scripts/check-paper-definitions.sh`
exit 0 case (a), no paper drift). Every claim below was independently re-confirmed while writing
this revision; file:line numbers are as observed on 2026-08-12 and remain plan-time hypotheses to
re-confirm before editing.

- **R1. The blocker's root cause no longer exists.** See `### Blocker Retirement Record` above.
- **R2. `bundleFlowFrame` is a definitional specialization, not an independent construction
  site.** `FlowFrame.lean:361` reads
  `noncomputable def bundleFlowFrame (B : BFMCS (fc := fc) D) : TaskFrame D := multiFamTaskFrameGen D {fam : FMCS (fc := fc) D // fam ∈ B.families}`.
  It therefore carries **no field obligations of its own**: discharging `multiFamTaskFrameGen`
  (FlowFrame.lean:130, the `where`-site) discharges it. The four `bundleFlow_*` lemmas are the
  specialization's proofs and are the model (and very likely the literal terms) for the generic
  frame's obligations.
- **R3. The three Phase-3/Phase-4 helpers survive verbatim** in
  `FormalSystem/Semantics/TaskFrame.lean`, all stated against a bare `R : W → D → W → Prop`:
  `limit_of_succOrder` (:302), `limit_of_shift` (:330, under `[Nontrivial D]`),
  `exists_uniform_radius_of_finite` (:381). The Phase-9 rename from `limit_nullity_of_*` landed.
- **R4. The site inventory is 14 LIVE, not 16.** Three v2 sites are gone and one is new:
  `identityFrame` was deleted in Phase 8 and replaced by `staticFrame` (with `staticFrame_serial`
  already proved at TaskFrame.lean:577); `zIntervalTaskFrame` has zero hits;
  `ParametricCanonicalTaskFrame` was deleted with its module. 16 − 3 + 1 = 14. Every site uses
  `where`-syntax; `grep -rn "TaskFrame.mk\|FiniteTaskFrame.mk"` outside `Boneyard/` returns
  nothing, so the compiler enumerates missing fields cleanly. Full corrected table in Phase 14.
- **R5. The apparatus is complete and sorry-free.** `FormalSystem/Semantics/FrameAxioms.lean`
  defines `Spherical` (:122), `Serial` (:137), `Interpolates` (:155), proves
  `nullity_of_serial_limit` (:182, `lem:nullity` derived choice-free from *Seriality* + *Limit*),
  and defines `Constraints` (:237) with the fiber/segment classification lemmas
  (`mem_Constraints` :245, `isSegment_of_mem_Constraints_left` :254,
  `isFiber_or_isSegment_of_mem_Constraints` :263). `Interpolates`'s own docstring records the
  target shape of this plan's `comp` field verbatim: "The full biconditional axiom is therefore
  `forward_comp ∧ Interpolates`."
- **R6. The full paper chain exists lemma-for-lemma**: `constraint` (Constraint.lean:393) ->
  `fibers` (Admissible.lean:144) -> `admissible` (Admissible.lean:283) -> `step` (Step.lean:116) ->
  `extension` (Extension.lean:187) -> `occurrence` (Extension.lean:237) -> `hF_nonempty`
  (Extension.lean:253). The LaTeX phase (Phase 6) is landed.
- **R7. The cross-task acceptance criterion is already discharged in hypothesis form.**
  `Step.lean:116` reads `theorem step (F : TaskFrame D) (hSph : Spherical F.TaskRel) (hSer : Serial F.TaskRel) …`
  and consumes `hSph` literally in its body (`obtain ⟨u, hu⟩ := hSph (Constraints τ z) hdir …`,
  :127). `Step.lean:108` records it as "the sole *Spherical* application site". This forecloses the
  inert-field failure mode **by construction**: a field whose statement differs from
  `FrameAxioms.lean`'s Props makes `step` stop typechecking the moment the substitution is
  attempted. That build break IS the acceptance test.

### Research Integration (v4)

Newly integrated in this revision — the Phase-14 sizing measurement pass of 2026-08-12, produced
by the implementation dispatch that landed Phases 10-13 and sub-step 14.0 and then declined to
open Phase 14's batch. Every measurement below was taken against the live tree at the post-Phase-13
commit; the raw numbers are preserved in the `#### SIZING FINDING` subsection inside Phase 14.1.
Counts here are hypotheses to re-confirm before editing, per the counts-are-hypotheses rule.

- **S1. The blocker is a SIZING blocker, not a lemma gap.** Blocker id `phase-14-mis-sized`, kind
  `sizing`, severity `needs-plan-decision`, `blocked_on_task: null` — it waits on no task and no
  external artifact. All four of Phase 14's own pre-batch gates PASS (see the gate table in
  Phase 14.1). No site lacks a lemma. Nothing here is descoped by assumption.
- **S2. `[Nontrivial D]` as a structure binder is the largest item and is NOT needed to state any
  of the four fields.** Measured: **575 `TaskFrame` mentions across 49 files** (re-measured
  2026-08-13 at 578 mentions / 49 files — the drift is Phase 13's own insertions; re-run the count
  before editing). The four field types mention only `Serial` / `Interpolates` / `Spherical` and
  *Limit*'s literal shape, none of which mentions `Nontrivial`. It is therefore separable, and this
  revision separates it into Phase 14.2.
- **S3. Per-site binder propagation forced by the *Limit* field is a much smaller, and
  unavoidable, item**: **~225 mentions across ~20 files** — `staticFrame` 27/4,
  `multiFamTaskFrameGen` 63/5 (plus `bundleFlowFrame` 29), `regionFrame` 65/5, `natFrame` 50/5,
  `genericNatFrame` 20/2. This is forced by the axiom fields (each of those frames' *Limit* lemma
  carries `[Nontrivial D]` or `[SuccOrder D] [NoMaxOrder D]`), so it stays with them, in Phase 14.1.
  **It is also green-committable on its own, before any field exists** — a stricter binder on a
  frame definition compiles by itself — which is why Phase 14.1 declares it as a pre-batch
  sub-step rather than as work inside the red window.
- **S4. `Nonempty WorldState` is cheap as a field and expensive to discharge.** New nonemptiness
  binders are needed at `staticFrame`, `regionFrame`, `multiFamTaskFrameGen`, and
  `bundleFlowFrame`; and **`FilteredWorld phi` has no nonemptiness proof in the tree**. Confirmed
  2026-08-13: `grep -rn "FilteredWorld"` over `FormalSystem/` yields exactly one instance,
  `FilteredWorld.finite` (FiniteModel.lean:137) — a `Finite` instance, which does not give
  `Nonempty`. Phase 14.2 carries that proof as **explicit work**, not as an assumption.
- **S5. Post-hoist correction to every "FrameAxioms.lean" reference in this plan.** Sub-step 14.0
  moved `Spherical`, `Serial`, and `Interpolates` out of `FormalSystem/Semantics/FrameAxioms.lean`
  and into `FormalSystem/Semantics/TaskFrame.lean` above the structure. Confirmed 2026-08-13:
  `Spherical` at TaskFrame.lean:322, `Serial` at :337, `Interpolates` at :355,
  `structure TaskFrame` at :401, `structure FiniteTaskFrame` at :1151. Fully qualified names,
  statements, and namespace are unchanged, so **every reference in this plan to "the
  `FrameAxioms.lean` Props" now means these three declarations at their new home**;
  `FrameAxioms.lean` retains `IsPaired`, `Constraints`, `nullity_of_serial_limit`, and the
  classification lemmas. Phase-body line numbers written before the hoist are stale by
  construction and must be re-read, not trusted.

### Corrected Site Inventory: 14 live, not 16

The count "16" and the v2 site table are **wrong everywhere they appear** and are corrected
throughout this plan. The authoritative list (14 live `where`-sites, verified 2026-08-12) is the
table in Phase 14. Summary of the delta from v2:

| v2 site | v3 disposition |
|---|---|
| `identityFrame` (v2 #2) | GONE — deleted in Phase 8, replaced by `staticFrame` (TaskFrame.lean:563) |
| `zIntervalTaskFrame` (v2 #10) | GONE — zero hits in `FormalSystem/` + `Tests/` |
| `ParametricCanonicalTaskFrame` (v2 #9) | GONE — module deleted (see Blocker Retirement Record) |
| `staticFrame` | NEW — the Phase-8 replacement, with `staticFrame_serial` already proved |
| `regionFrame` | MOVED — now `Bridge/RegionFrame.lean:169`, not `Bridge/Omega.lean:136`, and its relation was re-carriered to deterministic-shift form (see caveat (a)) |
| `multiFamTaskFrameGen` | MOVED — now `Algebraic/FlowFrame.lean:130`, not `Chronicle/ChronicleMonadicBridge.lean:139`; `bundleFlowFrame` is its specialization (R2) |
| all others | present, line numbers refreshed in the site tables now carried by Phase 14.1 |

`FiniteTaskFrame` (TaskFrame.lean:665) `extends TaskFrame` and therefore propagates every new
field obligation to its one live construction, `FiniteFilteredTaskFrame` (FiniteModel.lean:159).
It is not a 15th site; it is the mechanism by which that site inherits the obligations.

### Carried-Forward Open Caveats (NOT closed by this revision)

**(a) Three sites were flagged as failing dense-polymorphically and needing restriction or
re-carriering. That work is NOT addressed by 415's carrier and remains open.** It gets its own
phase (Phase 13). The three flagged sites and the current evidence on each:

| Flagged site | file:line | Status of the flag on 2026-08-12 |
|---|---|---|
| `RefinedFilteredTaskFrame` | Filtration.lean:197 | **Flag stands.** `refinedFilteredTaskRel` (:190) is `if d = 0 then w = u else True`. Over dense `D`, *Limit* fails outright: for any `x > 0` pick `y ≠ 0` with `\|y\| < x`, and the relation holds for every `u`. Discrete `D` is fine (`\|y\| < 1 → y = 0`), so the live options are the `[SuccOrder D] [NoMaxOrder D]` restriction or a re-carrier. |
| `FiniteFilteredTaskFrame` | FiniteModel.lean:159 | **Flag stands, derivatively.** It is `FiniteTaskFrame D where toTaskFrame := RefinedFilteredTaskFrame D phi`; whatever restriction or re-carrier the refined frame takes, this inherits. |
| `regionFrame` | RegionFrame.lean:169 | **Flag must be re-tested, NOT assumed.** The definition observed today is `WorldState := W × D` with `TaskRel := fun s d s' => s.1 = s'.1 ∧ s'.2 = s.2 + d` — the same deterministic-shift shape as `multiFamTaskFrameGen`, for which `limit_of_shift` applies with `pos := Prod.snd`. The flag predates the RegionFrame refactor (which moved the region structure out of the state and into the valuation, per RegionFrame.lean:160-168) and predates the site's move out of `Omega.lean`. **This observation is a hypothesis, not a closure**: Phase 13 tests it first, and either closes the flag with a `#### Reasoned Exclusions` entry carrying the evidence, or falls through to the same restriction/re-carrier treatment as the two filtration sites. |

**(b) The `nullity_identity` demotion is an unsettled joint decision with task 414. Leave the field
AS-IS.** The three options (demote to a derived lemma; keep the iff as a documented strengthening;
keep reflexivity derived and drop injectivity-at-zero) are framed at TaskFrame.lean:181-193 and in
v2's Open Design Questions. Checked on 2026-08-12: `specs/decisions/` contains
`total-history-validity-decisions.md` and `untl-snce-argument-order.md`, neither of which mentions
`nullity_identity`; the field's own docstring still reads "deliberately NOT settled by this module;
the field stays as-is until that joint decision lands". **Re-verified 2026-08-13 for this revision:
`ls specs/decisions/` returns those two files and nothing else, and
`grep -rln "nullity_identity" specs/decisions/` returns no hits. The decision has still NOT
landed.** No phase of this plan may settle it unilaterally. If it lands before Phase 14.1 runs,
apply it inside that phase's batch (it touches 40 reference sites) and record the decision anchor;
otherwise leave the field untouched.

Also still deferred, unchanged from v2: the `PartialHistory`/`WorldHistory` nonemptiness layering
(joint with 414 — note `PartialHistory` now exists at
`FormalSystem/Semantics/PartialHistory.lean:92`, so re-check what remains before acting on this),
the cone-topology T1 result, the Typst mirrors, and the collapse of duplicated frame bodies into
thin wrappers.

### Cross-Task Acceptance Criterion (BINDING; restated with its new status)

Adding the four fields is NOT done when they typecheck. *Spherical* must be LITERALLY the
hypothesis `step`'s proof consumes — never an inert field. In v2 this was a forward-looking risk;
per finding R7 it is now **structurally enforced**: `step` already takes
`hSph : Spherical F.TaskRel` and consumes it in its body, so a field whose statement differs from
the recorded `Spherical` cannot be substituted without a compilation failure. The binding
consequences for Phase 14.1:

- `TaskFrame.spherical` MUST be **definitionally** `Spherical TaskRel`.
- `TaskFrame.serial` MUST be **definitionally** `Serial TaskRel`.
- The interpolation half of the biconditional `comp` MUST be **definitionally**
  `Interpolates TaskRel`.
- **Never restate any of the three Props inline in a field, however equivalent the restatement
  looks.** Restating is precisely what would reintroduce the inert-field hazard. This prohibition
  survives the split unchanged and is restated in Phase 14.1's Constraints.
- Landing the fields (Phase 14.1) and demonstrating `step` consumes them (Phase 15) are ONE
  deliverable split across two phases only for sizing; neither is complete without the other.
  **Phase 14.2 is not part of that deliverable** — it gates nothing here.
- Post-hoist location note (finding S5): the three Props now live in
  `FormalSystem/Semantics/TaskFrame.lean` (`Spherical` :322, `Serial` :337, `Interpolates` :355),
  above `structure TaskFrame` (:401). The names and statements are unchanged; only the home moved.

Full rationale: `specs/decisions/total-history-validity-decisions.md`, section "The §7 acceptance
criterion". Note that *Spherical* keeps fibers and segments as **two separate classes** (the retired
device by which one-sided fibers counted among segments must not reappear), and that directedness is
its own definition per `def:directed` — both already honored by `FrameAxioms.lean:122-127`.

### Prior Plan Reference

- `plans/01_taskframe-limit-nullity-alignment.md` — Phases 1-5, landed.
- `plans/02_four-axiom-frame-alignment.md` — Phases 1-9 landed; its Phase 10 is superseded by
  Phases 10-15 of this plan. Its Phases 1-9 are carried forward below **verbatim** as recorded
  history, never re-run or reverted.
- `plans/03_four-axiom-fields-unblocked.md` — the immediately preceding version. Its Phases 1-13
  landed green and committed and are carried forward below **verbatim**, including their measured
  Verification Results, Deviations, Landed Declarations, and Phase 13's
  `#### Reasoned Exclusions` record. Its Phase 14 is superseded by Phases 14.1 and 14.2 of this
  plan; its Phase 15 is carried forward with only its `Depends on` field re-pointed.

## Goals & Non-Goals

**Goals**:
- Retire the `parametric-canonical-carrier` blocker as STALE with a recorded reason (done above,
  in this document).
- Prove, as standalone sorry-free lemmas over each frame's bare relation, the four axiom facts for
  every live construction site — BEFORE any structure field exists, so the build never goes red
  for want of a proof (Phases 10-13).
- Resolve caveat (a): restrict or re-carrier the sites that genuinely fail dense-polymorphically
  (Phase 13). **Landed.**
- Propagate the per-site binders the *Limit* lemmas force onto the frame definitions that need
  them, as a green, per-substep-committed pre-batch step (Phase 14.1, sub-step 14.1.1).
- Add the four axiom fields in ONE atomic batch, each field definitionally one of the three
  recorded Props (or *Limit*'s literal shape), re-deriving `forward_comp` as the `←` projection of
  `comp`, and discharging all 14 sites by citing the lemmas proved in Phases 10-13 (Phase 14.1).
- Correct every docstring that still describes the interpolation direction, *Seriality*, *Limit*,
  or *Spherical* as an absent "known gap" (Phase 14.1).
- Substitute `F.serial` / `F.interpolates` / `F.spherical` for `step`'s explicit hypothesis
  binders, discharging the acceptance criterion (Phase 15).
- Separately, and gating nothing above: add `[Nontrivial D]` as a `TaskFrame` structure binder and
  `Nonempty WorldState`, including the `FilteredWorld` nonemptiness proof that does not yet exist
  (Phase 14.2).

**Non-Goals**:
- **No re-running, reverting, or renumbering of Phases 1-13, and no undoing of sub-step 14.0's
  hoist.**
- **No re-merging of Phases 14.1 and 14.2 into a single batch.** The split is the whole content of
  this revision; collapsing it reinstates the measured over-size that stopped the last dispatch.
- No treating Phase 14.2 as a prerequisite for Phase 15. It is not one.
- No re-adding of the `420 -> 415` `dependencies[]` edge, and no new wait on task 415.
- No settling of the `nullity_identity` design question (caveat (b)) or the
  `PartialHistory`/`WorldHistory` nonemptiness layering — joint with 414.
- No validity/semantics refactor; no change to the `constraint -> fibers -> admissible -> step ->
  extension -> occurrence` chain beyond replacing `step`'s explicit hypotheses with field
  projections (Phase 15).
- **Paper is READ-ONLY**: no edits under `/home/benjamin/Philosophy/Papers/`. Cite by `\label` (or
  `\aitem` key) with verbatim quoted definition text; a bare `possible_worlds.tex:NNNN` is never a
  citation.
- Scope boundary with task 409: 409 owns `04-Metalogic.tex` and `06-Notes.tex`; this task owns the
  `02-Semantics.tex` frame subsection only (landed in Phase 6).
- **No `sorry` at any site, ever** — not as a bridge, not "temporarily", not inside the atomic
  batch. No new axiom, no vacuous or inert field.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A field is written as an inline restatement instead of the recorded Prop, reintroducing the inert-field hazard | H | M | Phase 14.1 states the three fields definitionally; Phase 15's substitution is the mechanical test — a restated field fails to typecheck there. Explicit prohibition in Phase 14.1's Constraints |
| The atomic batch is entered before every site has a proved lemma, producing a long red window with unknown-difficulty proofs inside it | H | L | Phases 10-13 pre-proved every site's four facts as standalone lemmas while the build stayed green (all landed); Phase 14.1 may only cite them, never discover a proof |
| **Phase 14.1's window is re-widened by folding 14.2's work back into it** — the exact failure that stopped the last dispatch | H | M | The split is stated in the Overview, the Goals, the wave table, and both phases' Constraints; 14.1's Constraints forbid touching the `TaskFrame` binder line or adding a nonemptiness field, and 14.2's forbid touching the four axiom fields |
| Per-site binder propagation (~225 mentions / ~20 files) is attempted *inside* the red window, so the window is long and nothing is committable | H | M | Phase 14.1 declares it as sub-step 14.1.1: a green, per-substep-committed pre-batch step, since a stricter binder on a frame definition compiles on its own. The batch (14.1.2) opens only after 14.1.1 is committed green |
| Phase 14.2 assumes a `Nonempty (FilteredWorld phi)` proof that does not exist, and discovers the gap inside a red window | H | M | Finding S4 records that only a `Finite` instance exists; Phase 14.2 carries the nonemptiness proof as sub-step 14.2.1, a **green pure addition committed before either atomic window opens** |
| Phase 14.2 is treated as a prerequisite for Phase 15, re-serializing the acceptance criterion behind the largest remaining change | M | M | Phase 15's `Depends on` names 14.1 only; the wave table places 14.2 after 15; the Non-Goals say so explicitly |
| Caveat (a) is quietly closed by assuming `regionFrame` is fine | M | M | Phase 13 requires the falsification test FIRST and a `#### Reasoned Exclusions` record with evidence before the flag may be closed |
| Restricting the two filtration sites to discrete `D` breaks their dense consumers | H | M | Phase 13's first task enumerates consumers of `RefinedFilteredTaskFrame`/`FiniteFilteredTaskFrame` and the duration types they elaborate at, before choosing restriction vs. re-carrier |
| Adding `[SuccOrder D] [NoMaxOrder D]` binders to `natFrame`/`genericNatFrame` breaks their call sites | M | M | Phase 10/11 Scope Hypotheses enumerate call sites (all at `Int`, which has both instances); binder changes are `interface`-tier with the dependents built |
| Biconditional `comp` collides with `forward_comp`'s 46 references across 12 files | M | M | Phase 14.1 re-derives `forward_comp` as the `←` projection of `comp` in the same batch, so consumers stay untouched |
| Someone settles `nullity_identity` (caveat (b)) unilaterally to simplify a proof | H | L | Explicit prohibition in caveat (b) and in Phase 14.1's Constraints; the field's own docstring says the same |
| The 14-site inventory drifts before Phase 14.1 runs | M | M | Every phase re-runs its own discovery grep under a Scope Hypothesis; Phase 14.1 re-runs the full inventory before adding any field |
| Line numbers recorded before sub-step 14.0's hoist are trusted rather than re-read | M | H | Finding S5 states the hoist moved the three Props and shifted every downstream line in `TaskFrame.lean`; every phase body's line numbers are declared plan-time hypotheses to confirm by reading |
| Task-number citations leak into deliverables outside `specs/**` | M | M | Prohibition restated in every phase's Constraints; grep at task close |
| `bundleFlow_*` proofs do not generalize from the specialization to `multiFamTaskFrameGen` | M | L | Phase 12's first task attempts the generalization; on failure the fallback is to prove the generic frame's facts directly (same deterministic-shift argument) and keep the specialization's lemmas as corollaries |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 (landed) | 1, 5 | -- |
| 2 (landed) | 2 | 1 |
| 3 (landed) | 3 | 2 |
| 4 (landed) | 4 | 3 |
| 5 (landed) | 6, 7 | -- |
| 6 (landed) | 8 | 7 |
| 7 (landed) | 9 | 8 |
| 8 (landed) | 10 | 9 |
| 9 (landed) | 11, 12, 13 | 10 |
| 10 | 14.1 | 10, 11, 12, 13 |
| 11 | 15 | 14.1 |
| 12 | 14.2 | 14.1 |

Phases within the same wave can execute in parallel.

**Why 14.2 sits in its own wave after 15, despite depending only on 14.1**: 14.2 is genuinely
independent of Phase 15 in the dependency sense — neither needs the other's output — but the two
MUST NOT run concurrently. 14.2's `[Nontrivial D]` structure-binder propagation reaches every
declaration mentioning `TaskFrame D` at polymorphic `D`, which includes Phase 15's territory
(`FormalSystem/Semantics/Extension/*.lean`), so the two have no clean territory contract. Ordering
15 first also discharges the Cross-Task Acceptance Criterion before the largest remaining
propagation is attempted, which is the outcome worth protecting if the task is interrupted.

Wave 9's three phases own disjoint file
territories — Phase 11 owns `Examples/TemporalStructures.lean`; Phase 12 owns
`Metalogic/Algebraic/FlowFrame.lean` and `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`;
Phase 13 owns `Metalogic/Decidability/FMP/Filtration.lean`,
`Metalogic/Decidability/FMP/FiniteModel.lean`, and
`Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` — and all three depend on Phase 10 only
because Phase 10 introduces the reusable class helpers they cite. No wave-9 phase may edit
`FormalSystem/Semantics/TaskFrame.lean`.

---

### Phase 1: Re-anchor stale def:frame citations [COMPLETED]

*(Landed under plan v1 — recorded history, do not re-run. Original content preserved.)*

**Goal**: Every `def:frame, line 1835` citation in the tree points at the correct live anchor.

**Tasks**:
- [x] Replace the stale anchor at `FormalSystem/Semantics/TaskFrame.lean:17`, `:68`, `:90`
- [x] Replace the stale anchor at `FormalSystem/Examples/TemporalStructures.lean:20`, `:57`
- [x] Replace the stale anchor at `docs/user-guide/architecture.md:454`
- [x] Replace the stale anchor at `docs/reference/API_REFERENCE.md:147`
- [x] Use the correct anchor: `possible_worlds.tex:2423-2451` for the formal `def:frame`,
      `possible_worlds.tex:908-926` for the body statement with gloss at 932
- [x] Re-run the discovery grep to confirm zero remaining `line 1835` hits outside `specs/**`

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Post-landing note (v2)**: the raw-line-number anchors this phase installed are themselves
superseded by the "bare `possible_worlds.tex:NNNN` is never a citation" constraint; Phase 9
converts them to `\label` citations with verbatim quoted text.

---

### Phase 2: Recast TaskFrame docstrings from divergence to agreement [COMPLETED]

*(Landed under plan v1 — recorded history, do not re-run. Original content preserved.)*

**Goal**: The module's prose states the true relationship to the paper: agreement on the
positive-cone presentation, with Reflection and backward composition derived and mixed-sign
composition inexpressible.

**Tasks**:
- [x] Rewrite the `converse` field docstring: the paper's definitional converse convention
      packaged as a structure field, not a substantive temporal-symmetry axiom
- [x] Invert the `Axiomatization Notes` block from "we diverge" to "we agree" (lax-law framing)
- [x] Record that Reflection and backward composition are derived; mixed-sign composition
      inexpressible at the primitive level
- [x] Record the known gap: paper requires `W` nonempty and `D` nontrivial
- [x] Add a forward-looking note that Limit Nullity is the one paper clause still absent

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Post-landing note (v2)**: the lax-law and "one clause absent" prose this phase wrote is now
stale a second time against the four-axiom `def:frame`; Phase 9 corrects it. The phase remains
recorded history.

---

### Phase 3: Add the two reusable Limit Nullity discharge helpers [COMPLETED]

*(Landed under plan v1 — recorded history, do not re-run. Original content preserved.)*

**Goal**: Both discharge strategies exist as standalone, sorry-free theorems before any field
consumes them.

**Tasks**:
- [x] `limit_nullity_of_succOrder` — landed verbatim at TaskFrame.lean:261-270:
      `[SuccOrder D] [NoMaxOrder D] {W} {R} (hnull : ∀ w u, R w 0 u ↔ w = u)`
- [x] `limit_nullity_of_shift` — landed at TaskFrame.lean:289-296 with the added binder
      `[Nontrivial D]` (deviation authorized by the phase's Scope Hypothesis):
      `[Nontrivial D] {W} (pos : W → D) {R} (hshift …) (hzero …)`
- [x] Both placed in `namespace TaskFrame` with docstrings; imports
      `Mathlib.Algebra.Order.Group.Abs` and `Mathlib.Order.SuccPred.Basic` added

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Post-landing note (v2)**: re-verified present VERBATIM on 2026-08-10 (finding B.3). All three
helpers state their hypotheses against a bare `R : W → D → W → Prop`, not a structure field —
exactly the shape Phase 10 consumes. The "Limit Nullity" NAMING is superseded (the axiom is now
*Limit*); Phase 9 handles the prose, and identifier renames fall under Phase 9's Scope
Hypothesis.

---

### Phase 4: Add the finite uniform-radius theorem [COMPLETED]

*(Landed under plan v1 — recorded history, do not re-run. Original content preserved.)*

**Goal**: The substitute for the deferred T1 stretch goal lands as a machine-checked derived
result.

**Tasks**:
- [x] `exists_uniform_radius_of_finite` — landed at TaskFrame.lean:340-346:
      `[Nontrivial D] {W} [Fintype W] (R) (hlim …) (w) : ∃ x, 0 < x ∧ ∀ u y, |y| < x → R w y u → u = w`
- [x] `push_neg` deprecation replaced with `push Not`; zero diagnostics
- [x] Docstrings: uniform-radius reading; finite frames over dense D are temporally rigid;
      deliberate substitute for the deferred cone-topology T1 result

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: local

---

### Phase 5: Restate the LaTeX Task Frame definition [COMPLETED]

*(Landed under plan v1 — recorded history, do not re-run. Original content preserved.)*

**Goal**: `latex/subfiles/02-Semantics.tex`'s frame-definition subsection matches the paper as
then recorded, and still compiles standalone.

**Tasks**:
- [x] Rewrote the Task Frame definition: nonempty `\worldstate`, nontrivial totally ordered
      abelian group `D`, positive-cone primitive relation, converse convention, two-sided cone
- [x] Stated THREE axioms (iff-Nullity, lax positive-cone Compositionality, Limit Nullity) —
      correct against the paper state known at the time
- [x] Added the derived-Reflection remark, corrected the primitives table, updated the gloss
- [x] Added `\label{def:frame}` (file previously had zero `\label` commands)
- [x] Added `\poscone` (`D^{+}`) and `\taskcone{w}{x}` (`(w)_{x}`) macros to
      `latex/assets/bimodal-notation.sty`

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Post-landing note (v2)**: stale a SECOND time — the restatement carries three axioms
(Nullity as an iff axiom, one-directional Compositionality, "Limit Nullity") and omits
*Seriality* and *Spherical* entirely; `:56` still claims the equality "would additionally assert
interpolation" (finding C.4). Phase 6 rewrites it to the four-axiom `def:frame`, PRESERVING this
phase's scaffolding (the `\label{def:frame}` cross-reference, the `\poscone`/`\taskcone` macros,
the primitives table).

---

### Phase 6: Rewrite 02-Semantics.tex to the four-axiom def:frame [COMPLETED]

**Goal**: The frame-definition subsection of `latex/subfiles/02-Semantics.tex` (currently lines
31-62) states the paper's FOUR-axiom `def:frame` with the supporting apparatus and derived
`lem:nullity`, and compiles standalone and in the master document.

**Tasks**:
- [x] Rewrite the frame definition to the four axioms, matching the record at
      `specs/paper-definitions-of-record.md:185` (quote alongside the anchor; verbatim axiom
      text, `\label` sub-anchors `def:frame#Compositionality|Seriality|Limit|Spherical`):
      - *Compositionality* (BICONDITIONAL): `$w \Rightarrow_{x + y} v$ if and only if
        $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$` — the right-to-left
        direction is load-bearing. Delete the current `:56` claim that the equality "would
        additionally assert interpolation" and is not adopted — it IS adopted.
      - *Seriality*: `$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some $u, v \in W$` (for
        `x ≥ 0`).
      - *Limit*: `$\bigcap_{x > 0} (w)_x = \set{w}$` (rename from "Limit Nullity").
      - *Spherical*: `$\bigcap \mathcal{S} \neq \emptyset$ for any directed family
        $\mathcal{S}$ of nonempty fibers and segments`.
- [x] Add the apparatus before the definition, per `def:task-relation`
      (paper-definitions-of-record.md:161) and `def:directed` (:176): Fiber
      `$\Fib(w, x) := \{u \in W : w \Rightarrow_x u\}$`; Cone
      `$(w)_x := \bigcup_{|y| < x} \Fib(w, y)$` for `x > 0`; Segment in the BRACKET form
      `$[w, v]_x^y := \Fib(w, x) \cap \Fib(v, -y)$` for `x, y ≥ 0` (the retired `\Seg`
      function-application notation is deleted from the paper preamble and must NOT be
      reintroduced); directed family per `def:directed`. *Spherical* ranges over directed
      families of nonempty FIBERS and SEGMENTS as TWO SEPARATE CLASSES — do not reintroduce the
      retired device by which one-sided fibers counted among the segments.
- [x] Demote Nullity: remove it from the axiom list and state it as the derived `lem:nullity`
      (reflexivity only, `$w \Rightarrow_0 w$`; proved from Seriality at `x = 0` plus Limit,
      choice-free) — per paper-definitions-of-record.md:220.
- [x] PRESERVE Phase 5's scaffolding: the `\label{def:frame}` cross-reference, the
      `\poscone`/`\taskcone` macros, and the primitives table (extend the table only as the
      apparatus requires, e.g. fiber/segment rows).
- [x] Update the gloss paragraph so it describes the four axioms actually stated.

**Timing**: 1.5 hours

**Depends on**: none (builds on landed Phase 5)

**Verification Tier**: interface

**Scope Hypothesis**: The stale region is `latex/subfiles/02-Semantics.tex:31-62` (finding
C.4). Line extents are a plan-time hypothesis; read the file and confirm before editing, and
keep the diff inside the Task Frames subsection — the World Histories subsection onward is out
of scope (its `WorldHistory` alignment is deferred, joint with 414).

**Files to modify**:
- `latex/subfiles/02-Semantics.tex` — apparatus, four-axiom definition, derived `lem:nullity`,
  gloss, primitives table
- `latex/assets/bimodal-notation.sty` — only if new macros are needed (e.g. `\Fib`, segment
  brackets); reuse `\poscone`/`\taskcone`

**Constraints**:
- **Notation (binding user decision, carried forward unchanged)**: any explicit converse
  operation is written with a superscript inverse — `$\Rightarrow^{-1}$` (and `$R^{-1}$` for
  abstract relations) — NEVER the relation-algebra breve/smile (`$\breve{R}$`,
  `$R^{\smallsmile}$`). The paper itself introduces no operator symbol for the converse
  (subscript negation only); the safest restatement introduces none either.
- Scope boundary: `04-Metalogic.tex` and `06-Notes.tex` belong to task 409 — do not touch them.
- Paper is READ-ONLY; cite by `\label` with verbatim quoted text.
- No task-number citations in any `.tex` or `.sty` file.

**Verification**:
- Standalone: `cd latex/subfiles && TEXINPUTS=../assets: pdflatex -interaction=nonstopmode 02-Semantics.tex`
  — exits clean, produces a PDF, no undefined-control-sequence errors
- Master: `cd latex && latexmk BimodalReference.tex` — green, no duplicate-label warnings
- Read the rendered definition and confirm all FOUR axioms, the apparatus (fiber, cone, segment
  in bracket form, directed family), and the derived `lem:nullity` are present, and Nullity is
  NOT listed as an axiom

---

### Phase 7: Define the fiber/cone/segment/directed-family apparatus in Lean [COMPLETED]

**Goal**: The supporting apparatus that makes *Spherical* statable exists as standalone,
sorry-free Lean definitions — pure additions over a bare relation, zero discharge obligations,
build stays green throughout.

**Tasks**:
- [x] Define, in `FormalSystem/Semantics/TaskFrame.lean` (same standalone style as the Phase 3
      helpers — against a bare relation or a frame parameter, NOT as structure fields), per
      `def:task-relation` (paper-definitions-of-record.md:161) and `def:directed` (:176):
      ```
      Fib F w x         := {u | F.TaskRel w x u}
      cone F w x (0<x)  := ⋃_{|y| < x} Fib F w y
      Seg F w v x y     := Fib F w x ∩ Fib F v (-y)     -- notation [w,v]_x^y, 0 ≤ x,y
      DirectedFamily S  := S.Nonempty ∧ ∀ S₁ S₂ ∈ S, ∃ S' ∈ S, S' ⊆ S₁ ∩ S₂
      ```
      (exact Lean spellings at the implementer's discretion — e.g. `Set W` vs predicates,
      hypothesis vs subtype for the cone's `0 < x` — but the MATHEMTICAL content must transcribe
      the recorded definitions exactly; segments use the two-endpoint bracket semantics, never a
      one-sided `\Seg`-style function application.)
- [x] Keep fibers and segments as TWO SEPARATE CLASSES wherever a "fibers and segments"
      predicate is needed (e.g. an `IsFiber s ∨ IsSegment s` disjunction) — the retired device
      by which one-sided fibers counted among the segments must not be reintroduced.
- [x] Docstring each definition with the `\label` anchor plus the verbatim recorded text (so a
      renamed anchor stays detectable by text search); no bare `possible_worlds.tex:NNNN`
      locators.
- [x] Optionally state and prove trivial sanity lemmas only if free (e.g. cone monotonicity);
      no obligation — this phase carries ZERO discharge obligation by design.

**Timing**: 1.5 hours

**Depends on**: none (same style as landed Phase 3)

**Verification Tier**: local

**Scope Hypothesis**: Finding C.2 (verified 2026-08-10): NO task-relation fiber, cone, segment,
or directed-family definition exists anywhere in `FormalSystem/` + `Tests/` (excluding
`Boneyard/`); the 966 `segment`/`directed` grep hits are all unrelated (Reynolds separability
prose at SoundnessLemmas/Separability.lean:38,259; DenseModelSurgery interval reasoning at
TruthTransfer.lean:208-210; order-theoretic "past-directed" naming). Re-run the grep before
defining; if a genuine collision has appeared since, reconcile naming rather than duplicating.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — new definitions (and notation) in
  `namespace TaskFrame`

**Constraints**:
- Pure additions only. Do NOT add or change any structure field in this phase.
- No task-number citations in this file.
- No `sorry`, no new axiom.

**Verification**:
- `lake build` — green, no new warnings
- `grep -n "sorry" FormalSystem/Semantics/TaskFrame.lean` returns nothing
- `#print axioms` on any new lemmas — only the standard Lean axioms

---

### Phase 8: Repair or delete identityFrame (Seriality violation, 415-independent) [COMPLETED]

**Goal**: `identityFrame` no longer violates *Seriality*, so the Phase 10 atomic batch does not
trip over a defect that has nothing to do with 415.

**Why now**: finding B.4(i) — TaskFrame.lean:393 has
`TaskRel := fun w x u => w = u ∧ x = 0`. *Seriality* requires
`∀ w x, 0 ≤ x → (∃ u, w ⇒ₓ u) ∧ (∃ v, v ⇒ₓ w)`; for any `x > 0` there is NO `u` with
`w = u ∧ x = 0`. The violation holds over EVERY nontrivial D — discretely as well as densely —
so task 415 is IRRELEVANT to it, and it MUST NOT be discovered inside the atomic-batch red
window. This is a failure plan v1 did not contemplate.

**Tasks**:
- [x] Enumerate the live references (Scope Hypothesis below): the export at TaskFrame.lean:390
      and the three consumers — WorldHistory.lean:125, SemanticPropertyTest.lean:108,
      TaskFrameTest.lean:41-42. Confirm by grep before editing.
- [x] Choose ONE of, based on what the reference sites actually need: *(chosen: option (a) re-carrier/redefine — renamed to `staticFrame` with `TaskRel := fun w _ u => w = u`; all three consumers updated; `staticFrame_serial` is the standalone Seriality lemma)*
      - **(a) Re-carrier/redefine**: replace the relation with one satisfying all four target
        axioms — the natural candidate is the static frame `TaskRel := fun w _ u => w = u`
        (every state related to itself at every duration), which satisfies biconditional
        Compositionality, Seriality, Limit, and Spherical trivially, and keeps
        `nullity_identity` intact. Rename if "identity" no longer describes it (e.g.
        `staticFrame`), updating the three consumers.
      - **(b) Delete**: remove `identityFrame` and repoint or delete the three consumers.
- [x] Whichever option: docstring the frame's axiom status against the recorded `def:frame`
      anchors; keep the `[Nontrivial D]` binder if the definition still requires it.
- [x] Do NOT add any structure field in this phase; the repaired frame must discharge the
      CURRENT structure's fields only (Phase 10 adds the rest and re-discharges).

**Timing**: 1 hour

**Depends on**: 7

**Verification Tier**: interface

**Scope Hypothesis**: Exactly 3 live references outside the definition itself
(WorldHistory.lean:125, SemanticPropertyTest.lean:108, TaskFrameTest.lean:41-42), per the
2026-08-10 inventory. Confirm with `grep -rn "identityFrame" FormalSystem/ Tests/` before
editing; treat any new site as in scope.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — the definition
- `FormalSystem/Semantics/WorldHistory.lean`, `Tests/.../SemanticPropertyTest.lean`,
  `Tests/.../TaskFrameTest.lean` — the consumers (as the chosen option requires)

**Constraints**:
- No task-number citations in any of these files.
- No `sorry`, no new axiom, no vacuous definition (a frame nothing can instantiate is not a
  repair).

**Verification**:
- `lake build` — green (full build: consumers span FormalSystem/ and Tests/)
- `grep -n "sorry"` on every touched file returns nothing
- The chosen definition provably satisfies *Seriality* as a standalone lemma OR is deleted —
  record which in the summary

---

### Phase 9: Correct stale docstrings, naming, and citations (field-independent subset) [COMPLETED]

**Goal**: Every C.4 item that does NOT depend on the structure change landing is corrected: the
prose tells the truth about the four-axiom target, and every paper reference is a `\label`
citation with verbatim quoted text.

**Tasks**:
- [x] **Lax-law claims** (TaskFrame.lean:48-53, 170-176): delete the claim that "the law is the
      LAX inclusion `R_{x+y} ⊇ R_x ∘ R_y`: an equality would additionally assert interpolation
      and is not adopted" — it directly contradicts `def:frame#Compositionality`
      (BICONDITIONAL, right-to-left load-bearing). Recast `forward_comp`'s docstring (:177): it
      is the `←` HALF of the paper's biconditional; the `→` (interpolation) direction lands with
      the structure change.
- [x] **Nullity claim** (TaskFrame.lean:47): replace "Paper's *Nullity* is an iff, and
      `nullity_identity` … is an exact match" — Nullity is NOT an axiom; `lem:nullity`
      (paper-definitions-of-record.md:220) is DERIVED and asserts reflexivity only. Document the
      `nullity_identity` iff-form as an OPEN DESIGN QUESTION (three options, joint with 414 —
      frame it exactly as this plan's Open Design Questions section does; do NOT settle it and
      do NOT change the field).
- [x] **"Limit Nullity" → *Limit*** naming (TaskFrame.lean:69, 84, 86, 232, and the :261
      header): the axiom is now simply *Limit*. Update all prose unconditionally. Rename the
      Lean identifiers (`limit_nullity_of_succOrder`, `limit_nullity_of_shift`) ONLY under the
      Scope Hypothesis below; otherwise record the naming lag in their docstrings and defer the
      rename into Phase 10's batch.
- [x] **Known-gaps block** (TaskFrame.lean:66-72): currently lists only `Nonempty W`,
      `Nontrivial D`, "Limit Nullity". Rewrite to the full gap list: `Nonempty W`,
      `[Nontrivial D]` (structure level — already carried by `valid`/`SemanticConsequence` at
      Validity.lean:80/104/171/189/242/278), *Seriality*, *Limit*, *Spherical*, the
      interpolation (`→`) direction of *Compositionality*, and the apparatus consumption
      (pointing at the Phase 7 definitions).
- [x] **Bare locators → `\label` citations** (TaskFrame.lean:52, 59, 63, 71, 105-106, 187, 232;
      WorldHistory.lean:73, 84): "a bare `possible_worlds.tex:NNNN` is never a citation" —
      convert every one to a `\label` reference (`def:frame`, `def:task-relation`,
      `def:temporal-order`, `def:world-history`, `lem:nullity`, …) quoting the recorded
      definition text verbatim alongside the anchor. *(deviation: altered — the site set was
      widened beyond this phase's declared "Files to modify" to three further files carrying
      the same `possible_worlds.tex:NNNN` form: `Syntax/Formula.lean`,
      `Theorems/DedekindDerived.lean`, `Examples/TemporalStructures.lean`. See the Deviations
      record below.)*
- [x] **WorldHistory.lean:73, 84**: beyond the locator fix, correct "Matches JPL paper
      def:world-history (line 1849)" — it does NOT fully match: no nonemptiness field (the
      empty history is legal in Lean but not per `def:world-history`,
      paper-definitions-of-record.md:232) and no `PartialHistory` layer. State the gap plainly
      as deferred joint scope with the consequence-refactor work; do NOT change any field.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: local

**Scope Hypothesis**: The identifier rename (`limit_nullity_of_*` → `limit_of_*` or similar) is
in scope ONLY if `grep -rn "limit_nullity_of" FormalSystem/ Tests/` confirms references are
confined to TaskFrame.lean itself (the helpers landed recently and plan-time expectation is
zero external consumers). If external references exist, do the prose-only correction here and
fold the rename into Phase 10's atomic batch. Line numbers throughout are plan-time hypotheses
from the 2026-08-10 findings; confirm each by reading before editing.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — docstrings, header comments, (conditionally) helper
  identifiers
- `FormalSystem/Semantics/WorldHistory.lean` — two docstrings

**Constraints**:
- Comment/docstring edits plus (at most) the grep-gated identifier rename. NO structure-field
  change, NO change to `nullity_identity` or `forward_comp` themselves.
- No task-number citations in these files (cite `def:frame`, `lem:nullity`, sibling filenames —
  durable anchors only).
- No `sorry`, no new axiom.

**Verification**:
- `lake build` — green
- `git diff` confined to comment/docstring regions plus any grep-gated rename sites
- `grep -rn "possible_worlds.tex:[0-9]" FormalSystem/ --include=*.lean` returns nothing (all
  converted to `\label` citations)
- `grep -rn "Limit Nullity" FormalSystem/ --include=*.lean` returns nothing (prose renamed)

**Verification results** (measured 2026-08-10):
- `lake build` — GREEN, exit 0, 2333 jobs, no new warnings attributable to this phase
- `grep -rn "possible_worlds.tex:[0-9]" FormalSystem/ --include=*.lean` — 0 hits
- `grep -rn "Limit Nullity" FormalSystem/ --include=*.lean` — 0 hits
- `grep -rn "limit_nullity_of" FormalSystem/ Tests/` — 0 hits (Scope Hypothesis satisfied: zero
  external consumers, so the rename to `limit_of_succOrder` / `limit_of_shift` was in scope and
  was applied; it did NOT have to be folded into Phase 10's batch)
- `git diff` confined to comment/docstring regions plus the two grep-gated rename sites — no
  structure field, no `nullity_identity` change, no `forward_comp` change
- Zero new `sorry`, zero new `axiom`

**Deviations**:
- **Site set widened beyond the declared "Files to modify"** (altered, justified). The declared
  file list named only `TaskFrame.lean` and `WorldHistory.lean`, but this phase's own
  verification criterion — `grep -rn "possible_worlds.tex:[0-9]" FormalSystem/ --include=*.lean`
  returns nothing — is repo-wide over `FormalSystem/`. Three further files carried locators of
  exactly that form and would have kept the criterion red:
  - `FormalSystem/Syntax/Formula.lean` — `possible_worlds.tex:3250` → the `TMP-CO` `\aitem`
    anchor with its verbatim `\aitem[CO]{TMP-CO} …` text
  - `FormalSystem/Theorems/DedekindDerived.lean` — the same `possible_worlds.tex:3250` → the
    same `TMP-CO` anchor and verbatim text
  - `FormalSystem/Examples/TemporalStructures.lean` — `possible_worlds.tex:2423-2451` and
    `possible_worlds.tex:908-926` → the `def:temporal-order` and `def:frame` anchors, with
    `def:temporal-order` quoted verbatim
  Every edit is the same class as the declared work (bare locator replaced by a `\label` /
  `\aitem` anchor with verbatim quoted text, per the binding "a bare locator is never a
  citation" rule), is comment-only, and changes no declaration. Judged in scope.
- **Two residual paper locators in a different textual form were deliberately NOT touched**
  (skipped, out of scope). They do not match this phase's declared grep and lie outside its
  enumerated site list:
  - `FormalSystem/Metalogic/Soundness.lean:95` — "JPL Paper app:valid (line 1984)". Already
    carries an anchor (`app:valid`); only the parenthetical line number is stale decoration.
  - `FormalSystem/Semantics/Truth.lean:46` — "matches paper's domain check at line 892 (atoms
    false outside domain)". This is more than a citation defect: `def:BL-semantics`'s current
    atom clause is `$\M,\tau,x \vDash p_i$ \textit{iff} $\tau(x) \in |p_i|$` — the `dom`
    conjunct was explicitly removed, so the claim is substantively stale, not merely
    ill-cited. Repairing it is `def:BL-semantics` / `TruthAt` architecture work, which
    `paper-definitions-of-record.md` assigns to the separate consequence-refactor scope; it is
    not a docstring correction and is not settled here.

---
### Phase 10: Reusable axiom-class helpers and the TaskFrame.lean example sites [COMPLETED]

**Goal**: The four axiom facts (*Seriality*, interpolation, *Limit*, *Spherical*) exist as
standalone, sorry-free lemmas for `trivialFrame`, `staticFrame`, `natFrame`, and `customFrame`,
together with the two reusable **class helpers** that Phases 11-13 cite. Pure additions plus (at
most) two binder changes; the build stays green throughout.

**Why this shape**: v2's Phase 10 tried to add the fields and discover every site's proof inside a
single red window. That is the one sequencing this plan refuses: every proof is found while the
build is green, and Phase 14 may only *cite* what these phases proved. This is the same
"pre-repair before the batch" pattern Phase 8 used successfully for `identityFrame`.

**Tasks**:
- [x] GATE (retirement confirmation, cheap; ~10 minutes, not an analysis budget): re-confirm the
      four facts the Blocker Retirement Record rests on —
      `ls FormalSystem/Metalogic/Algebraic/` shows no `ParametricCanonical.lean`;
      `grep -rn "ParametricCanonicalTaskFrame\|zIntervalTaskFrame\|identityFrame" FormalSystem/ Tests/ --include=*.lean`
      outside `Boneyard/` returns zero hits; `bundleFlow_comp_iff`/`_serial`/`_limit`/`_spherical`
      are present in `FlowFrame.lean`; the site-discovery greps yield 14 live `where`-sites. Record
      the observed counts in the phase's commit message. If any fact fails, STOP and re-revise —
      do not improvise around it.
- [x] **Helper A — subsingleton/total-relation class**: a lemma set giving `Serial R`,
      `Interpolates R`, the *Limit* hypothesis shape, and `Spherical R` for any frame whose
      relation is `fun _ _ _ => True` on a subsingleton carrier. Covers sites `trivialFrame`,
      `intTimeFrame`, `genericTimeFrame`. State it once, over a bare relation, in
      `namespace TaskFrame` beside the Phase-3 helpers.
- [x] **Helper B — permissive class** `fun w d u => d ≠ 0 ∨ w = u`: *Seriality* and interpolation
      are unconditional; *Limit* needs `[SuccOrder D] [NoMaxOrder D]` and goes through
      `limit_of_succOrder` (TaskFrame.lean:302); *Spherical* holds because every fiber is either
      the whole carrier (`d ≠ 0`) or a singleton (`d = 0`), so a directed family whose members are
      all nonempty cannot contain two distinct singletons — a `⊆`-least member argument mirroring
      `lem:step`'s recorded closing remark. Covers `natFrame`, `intNatFrame`, `genericNatFrame`,
      `customFrame`.
- [x] **Helper C — equality class** `fun w _ u => w = u` (`staticFrame`): *Seriality* is already
      `staticFrame_serial` (TaskFrame.lean:577); add interpolation (interpolate through `w`
      itself), *Limit* (only `w` is reachable), and *Spherical* (every nonempty fiber and segment
      is the same singleton).
- [x] Apply the helpers to `trivialFrame` (TaskFrame.lean:538), `staticFrame` (:563), `natFrame`
      (:591), and `customFrame` (TaskFrameTest.lean:60), yielding one named lemma per site per
      axiom (or one bundled per-site lemma — implementer's choice, documented).
- [x] Add `[SuccOrder D] [NoMaxOrder D]` to `natFrame`'s binders **only if** the Scope Hypothesis
      below confirms its consumers can supply them; otherwise state its *Limit* lemma under those
      instances as explicit hypotheses and record the deferral for Phase 14. *(deviation:
      altered — the plan's second branch was taken. `natFrame_limit` carries
      `[SuccOrder D] [NoMaxOrder D]` on the lemma, and `natFrame`'s own binders are unchanged;
      the binder change is deferred into Phase 14's batch. Enumerated propagation target for
      that later change: only `WorldHistory.universalNatFrame` (WorldHistory.lean:215), itself
      polymorphic in `D` and with zero consumers of its own — every other `natFrame` reference
      in `FormalSystem/` and `Tests/` elaborates at `Int`.)*
- [x] Docstring every new lemma with the `def:frame` sub-anchor (`#Compositionality`, `#Seriality`,
      `#Limit`, `#Spherical`) plus the verbatim recorded text, per the "a bare locator is never a
      citation" rule.

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: (i) 14 live `where`-sites and zero `.mk` sites, per finding R4 — re-run
`grep -rnE "^\s*(noncomputable )?(def|instance|abbrev)[^:]*: *(TaskFrame|FiniteTaskFrame)"`
over `FormalSystem/` + `Tests/` excluding `Boneyard/` and reconcile against Phase 14's table.
(ii) `natFrame`'s consumers are `WorldHistory.lean:217` (which builds a
`WorldHistory (TaskFrame.natFrame (D := D))` at **polymorphic** `D` — the binder change propagates
there and is the real constraint), `TaskFrameTest.lean:51/52/55`, and
`Tests/BimodalTest/Property/Generators.lean:176/179` (both at `Int`, which has `SuccOrder` and
`NoMaxOrder`). Confirm with `grep -rn "natFrame" FormalSystem/ Tests/` before changing any binder.
(iii) `Tests/BimodalTest/Semantics/SemanticBenchmark.lean:50` references `TaskFrame.trivial_frame`,
an identifier with **no definition anywhere in the live tree**; the file appears not to be imported
by `Tests/BimodalTest.lean` (it is named only in that file's module docstring at :76). Confirm
whether it is in the default build. If it is not, it carries no field obligation — but record the
finding in the summary rather than silently passing over it.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — class helpers, per-site lemmas, (conditionally) the
  `natFrame` binder
- `Tests/BimodalTest/Semantics/TaskFrameTest.lean` — `customFrame`'s lemmas
- `FormalSystem/Semantics/WorldHistory.lean` — only if the `natFrame` binder change requires it

**Constraints**:
- Pure additions plus at most the two grep-gated binder changes. **Do NOT add or change any
  `TaskFrame` structure field in this phase.**
- Every lemma must be stated so that Phase 14 can cite it directly for the corresponding field —
  i.e. in the exact shapes `Serial R`, `Interpolates R`, `Spherical R` from `FrameAxioms.lean`, and
  the literal *Limit* hypothesis shape
  `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w` that `limit_of_succOrder` and
  `limit_of_shift` conclude.
- No task-number citations in any Lean file. No `sorry`, no new axiom.

**Verification**:
- `lake build` — green after every sub-step commit
- `grep -rn "sorry" FormalSystem/Semantics/TaskFrame.lean Tests/BimodalTest/Semantics/TaskFrameTest.lean`
  returns nothing
- `#print axioms` on each new lemma — only the standard Lean axioms
- Each new lemma's statement is syntactically `Serial …` / `Interpolates …` / `Spherical …` (not a
  restatement) where the corresponding Prop applies

**Verification results** (measured 2026-08-12):
- GATE observed counts: `FormalSystem/Metalogic/Algebraic/` holds 6 entries and no
  `ParametricCanonical.lean`; `ParametricCanonicalTaskFrame|zIntervalTaskFrame|identityFrame`
  outside `Boneyard/` = **0 hits**; `bundleFlow_comp_iff`/`_serial`/`_limit`/`_spherical` present
  at FlowFrame.lean:392/400/408/415; site-discovery grep yields **14 live `where`-sites, 0 `.mk`
  sites**, reconciling exactly with Phase 14's table.
- `lake build` — GREEN, exit 0, 2331 jobs, no new warnings
- `lake build BimodalTest.Semantics.TaskFrameTest` — GREEN
- `#print axioms` on all 21 new declarations — only `propext`, `Classical.choice`, `Quot.sound`
- `grep -n "sorry"` on both touched files — 0 hits
- `lake build BimodalTest` failure set unchanged from the pre-phase baseline
  (`BoxSpreadProbe`, `RegionGateProbe`, `TableauConformance`; 11 errors) — pre-existing, unrelated

**Deviations**:
- **Prerequisite relocation, landed as sub-step 10.0** (added, forced). `Spherical`, `Serial`,
  and `Interpolates` were defined in `FormalSystem/Semantics/FrameAxioms.lean`, which *imports*
  `TaskFrame.lean` (via `PartialHistory.lean`). They were therefore invisible inside
  `TaskFrame.lean`, so neither this phase's requirement that every lemma be stated *syntactically*
  as `Serial R` / `Interpolates R` / `Spherical R` **in `namespace TaskFrame` beside the Phase-3
  helpers**, nor Phase 14's requirement that the fields be those Props *definitionally*, was
  reachable: a structure field's type may only mention declarations that precede it, so a
  predicate declared in a module importing `TaskFrame.lean` can never become a `TaskFrame` field.
  The three definitions were moved verbatim into `TaskFrame.lean`, beside the
  `Fib`/`cone`/`Seg`/`DirectedFamily`/`IsFiber`/`IsSegment` apparatus they are built from. Both
  modules already open `namespace FormalSystem.Semantics / namespace TaskFrame`, so the fully
  qualified names, statements, and namespace are **unchanged** and no consumer changed.
  `FrameAxioms.lean` keeps `IsPaired`, `Constraints`, `nullity_of_serial_limit`, and the
  classification lemmas, plus a pointer block recording the new home.
- **`staticFrame_serial` restated in `Serial` form** (altered). It previously read as an unfolded
  conjunction `(∃ u, …) ∧ (∃ v, …)` without the paper's `0 ≤ x` proviso, which Phase 14 could not
  cite for a `Serial TaskRel` field. It had zero consumers anywhere in the tree
  (`grep -rn "staticFrame_serial"` = the definition and one docstring mention). Content unchanged.
- **`import Mathlib.Data.Int.SuccPred` added to `TaskFrameTest.lean`** (added) — the `SuccOrder ℤ`
  instance `customFrame_limit` needs.
- **Scope Hypothesis (iii) resolved, not passed over**:
  `Tests/BimodalTest/Semantics/SemanticBenchmark.lean:50` references `TaskFrame.trivial_frame`,
  which has no definition in the live tree. The module is unreachable from
  `Tests/BimodalTest.lean` (named only in its module docstring at :76) and is absent from the
  default build — it would fail to elaborate if it were in it. It carries **no field obligation**.

**Landed declarations** (all in `namespace FormalSystem.Semantics.TaskFrame` unless noted):
- Shared: `exists_pos_of_nontrivial`, `sInter_nonempty_of_directed_of_univ_or_singleton`
- Helper A (total relation, subsingleton carrier): `serial_of_total`, `interpolates_of_total`,
  `limit_of_subsingleton`, `spherical_of_subsingleton`
- Helper B (permissive, `R w d u ↔ (d ≠ 0 ∨ w = u)`): `Fib_permissive_zero`, `Fib_permissive_ne`,
  `serial_of_permissive`, `interpolates_of_permissive`, `limit_of_permissive`,
  `univ_or_singleton_of_permissive`, `spherical_of_permissive`
- Helper C (equality, `R w d u ↔ w = u`): `Fib_eq_singleton`, `serial_of_eq`,
  `interpolates_of_eq`, `limit_of_eq`, `spherical_of_eq`
- Sites: `trivialFrame_{serial,interpolates,limit,spherical}`,
  `staticFrame_{rel_iff,serial,interpolates,limit,spherical}`,
  `natFrame_{rel_iff,serial,interpolates,limit,spherical}`, and in
  `BimodalTest.Semantics`: `customFrame_{rel_iff,serial,interpolates,limit,spherical}`

---

### Phase 11: Axiom lemmas for the TemporalStructures example frames [COMPLETED]

**Goal**: `intTimeFrame`, `intNatFrame`, `genericTimeFrame`, and `genericNatFrame` each have the
four axiom facts as standalone sorry-free lemmas, citing Phase 10's helpers.

**Tasks**:
- [x] `intTimeFrame` (TemporalStructures.lean:77) and `genericTimeFrame` (:157): `Unit` carrier,
      `TaskRel := fun _ _ _ => True` — discharge all four via Helper A.
- [x] `intNatFrame` (:90): permissive relation at `Int` — Helper B; *Limit* via
      `limit_of_succOrder`, whose `[SuccOrder Int] [NoMaxOrder Int]` instances are available
      without a binder change.
- [x] `genericNatFrame` (:169): permissive relation at **polymorphic** `D` — *Limit* fails over
      dense `D`, so this site needs `[SuccOrder D] [NoMaxOrder D]`. Add the binders if its
      consumers can supply them (Scope Hypothesis); otherwise state the *Limit* lemma under those
      instances as explicit hypotheses and record the binder change for Phase 14's batch.
- [x] Docstring each lemma with the `def:frame` sub-anchor and verbatim recorded text.

**Timing**: 1.5 hours

**Depends on**: 10

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: Four sites in this file at the lines above (plan-time hypothesis from the
2026-08-12 inventory; read the file and confirm). `genericNatFrame`'s and `genericTimeFrame`'s
consumers must be enumerated with `grep -rn "genericNatFrame\|genericTimeFrame" FormalSystem/ Tests/`
before any binder change; treat any consumer that elaborates at a dense duration type as a
blocking finding to record, not to work around.

**Files to modify**:
- `FormalSystem/Examples/TemporalStructures.lean`

**Constraints**:
- No structure-field change. No edits to `FormalSystem/Semantics/TaskFrame.lean` (Phase 10's
  territory; this phase only cites it).
- No task-number citations. No `sorry`, no new axiom.

**Verification**:
- `lake build` — green after every sub-step commit
- `grep -n "sorry" FormalSystem/Examples/TemporalStructures.lean` returns nothing
- `#print axioms` on each new lemma — only the standard Lean axioms

**Verification results** (measured 2026-08-12):
- `lake build` — GREEN, exit 0, 2331 jobs, no new warnings
- `grep -n "sorry" FormalSystem/Examples/TemporalStructures.lean` — 0 hits
- `#print axioms` on all 18 new declarations — only `propext`, `Classical.choice`, `Quot.sound`
- Scope Hypothesis confirmed: exactly four sites in this file, at :78 (`intTimeFrame`), :118
  (`intNatFrame`), :215 (`genericTimeFrame`), :251 (`genericNatFrame`) as read today (the plan's
  :77/:90/:157/:169 shifted by this phase's own insertions). Consumer enumeration
  (`grep -rn "genericNatFrame\|genericTimeFrame\|intNatFrame\|intTimeFrame" FormalSystem/ Tests/`):
  **no consumer outside this file at all** — the only external hits are two prose mentions in
  `TaskFrame.lean`'s helper-section docstring. Within the file, `genericTimeFrame` is used by
  `genericTimeHistory` and four examples; `genericNatFrame` and `intNatFrame` have **zero** uses.
  No consumer elaborates at a dense duration type, so nothing here is a blocking finding.

**Landed declarations** (namespace `FormalSystem.Examples.TemporalStructures`):
`intTimeFrame_{serial,interpolates,limit,spherical}` (total class),
`intNatFrame_{rel_iff,serial,interpolates,limit,spherical}` (permissive at `Int`),
`genericTimeFrame_{serial,interpolates,limit,spherical}` (total class, any `D`),
`genericNatFrame_{rel_iff,serial,interpolates,limit,spherical}` (permissive, polymorphic).

**Deviations**:
- **`genericNatFrame` binder change deferred** (altered; the plan's own sanctioned second branch).
  `genericNatFrame_limit` carries `[SuccOrder D] [NoMaxOrder D]` on the lemma; `genericNatFrame`'s
  binders are unchanged, and the change is recorded for Phase 14's batch. It is free when taken:
  `genericNatFrame` has **zero consumers** anywhere in `FormalSystem/` or `Tests/`.
- **`import Mathlib.Data.Int.SuccPred` added** (added) — the `SuccOrder ℤ` instance
  `intNatFrame_limit` needs. Same one-line addition as in `TaskFrameTest.lean`.
- **`genericTimeFrame_limit` needs no restriction on `D`** (noted). The plan grouped it with the
  total class; its `Unit` carrier discharges *Limit* via `limit_of_subsingleton` over **any**
  duration type, dense included, so — unlike `genericNatFrame` — it carries no deferred binder.

---

### Phase 12: Axiom lemmas for the deterministic-shift frames [COMPLETED]

**Goal**: `multiFamTaskFrameGen` (and hence `bundleFlowFrame`), `zTaskFrameV2`, and
`multiFamTaskFrame` each have the four axiom facts as standalone sorry-free lemmas.

**Why these three are cheap**: all carry a position projection and a deterministic shift, so
*Limit* is `limit_of_shift` (TaskFrame.lean:330) with `pos := Prod.snd` (or the identity at
`zTaskFrameV2`, whose carrier is `ℤ` itself), interpolation is the explicit midpoint
`(p.1, p.2 + x)`, and *Seriality* is the forward and backward shift. `bundleFlow_comp_iff` (:392),
`bundleFlow_serial` (:400), `bundleFlow_limit` (:408), and `bundleFlow_spherical` (:415) are already
proved for the bundle specialization and are the template.

**Tasks**:
- [x] Generalize the four `bundleFlow_*` lemmas from the specialization to `multiFamTaskFrameGen`
      (FlowFrame.lean:130) itself — the frame `bundleFlowFrame` (:361) is *definitionally*
      (`multiFamTaskFrameGen D {fam // fam ∈ B.families}`), so the generic statements should
      specialize back to the existing lemmas by `rfl`/direct application. Keep the existing
      `bundleFlow_*` names as corollaries so their consumers are untouched.
      **Fallback if generalization resists**: prove the generic facts directly by the same
      deterministic-shift argument; do NOT `sorry`, and do NOT delete the specialization lemmas.
- [x] `zTaskFrameV2` (ReynoldsBridge.lean:453) and `multiFamTaskFrame` (:697): the same four
      lemmas at `ℤ`. Where either is definitionally an instance of `multiFamTaskFrameGen`, derive
      rather than re-prove; record which route was taken.
- [x] Record explicitly, in the module docstring and in the summary, that `bundleFlowFrame` is a
      definitional specialization and therefore is **not** a separate discharge site for Phase 14.
- [x] Docstring each lemma with the `def:frame` sub-anchor and verbatim recorded text.

**Timing**: 2 hours

**Depends on**: 10

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Three `where`-sites in this territory (`FlowFrame.lean:130`,
`ReynoldsBridge.lean:453`, `ReynoldsBridge.lean:697`) plus the definitional specialization
`bundleFlowFrame` (`FlowFrame.lean:361`), per finding R2/R4. Re-run
`grep -rn "TaskFrame" FormalSystem/Metalogic/Algebraic/FlowFrame.lean FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`
and confirm before proving; treat any additional `where`-site as in scope.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`

**Constraints**:
- No structure-field change. No edits outside this phase's two files.
- The existing `bundleFlow_*` lemma names must survive (as corollaries at minimum) — they are
  consumed elsewhere.
- No task-number citations. No `sorry`, no new axiom.

**Verification**:
- `lake build` — green after every sub-step commit
- `grep -n "sorry"` on both touched files returns nothing
- `#print axioms` on each new lemma — only the standard Lean axioms
- `Completeness.lean`, `ChronicleToCountermodelBasic.lean`, and `CompletenessDedekind.lean` still
  elaborate unchanged

**Verification results** (measured 2026-08-12):
- `lake build` — GREEN, exit 0, 2331 jobs, no new warnings
- `grep -n "sorry"` on both touched files — `FlowFrame.lean` 0 hits; `ReynoldsBridge.lean` 6 hits,
  all prose mentions in docstrings ("the sorry-free Reynolds pipeline", etc.), identical to the
  pre-phase baseline (`git show HEAD:… | grep -c sorry` = 6). Zero `sorry` tactics, zero added.
- `#print axioms` on all 13 new declarations — only `propext`, `Classical.choice`, `Quot.sound`
- `Completeness.lean`, `ChronicleToCountermodelBasic.lean`, and `CompletenessDedekind.lean` still
  elaborate (covered by the green full build)
- Scope Hypothesis confirmed: three `where`-sites in this territory, plus the definitional
  specialization `bundleFlowFrame`. No additional `where`-site appeared.

**Route taken for each site** (the phase asked this be recorded):
- `multiFamTaskFrameGen` — **already proved**. The generalization the phase anticipated had
  already landed in the tree: `multiFamGen_comp_iff` (:214), `multiFamGen_serial` (:239),
  `multiFamGen_limit` (:248, via `TaskFrame.limit_of_shift` with `pos := Prod.snd`), and
  `multiFamGen_spherical` (:266) are stated for the *generic* frame, and the `bundleFlow_*`
  lemmas are already their specializations. What was missing was only the *shape*: those four are
  stated pointwise, not as the bare-relation predicates of record. Added
  `multiFamTaskFrameGen_{serial,interpolates,limit,spherical}` as pure repackagings — no new
  mathematical argument. The `bundleFlow_*` names are untouched and survive unchanged.
- `multiFamTaskFrame` (ReynoldsBridge.lean) — **derived, not re-proved**. `multiFamTaskFrame
  FamIdx = multiFamTaskFrameGen ℤ FamIdx` holds by `rfl` (same carrier, same relation, remaining
  fields are `Prop`s), recorded as `multiFamTaskFrame_eq_gen`. The four lemmas are the generic
  ones applied directly.
- `zTaskFrameV2` (ReynoldsBridge.lean) — **proved directly**. Its carrier is `ℤ` itself, not a
  product, so it is *not* an instance of `multiFamTaskFrameGen` and could not be derived. Same
  deterministic-shift argument: `TaskFrame.limit_of_shift` with `pos := id`, fibers are
  singletons (`zTaskFrameV2_fib_subsingleton`), *Spherical* via
  `Algebraic.sInter_nonempty_of_directed_subsingleton`.

**Landed declarations**:
- `FormalSystem.Metalogic.Algebraic`: `multiFamTaskFrameGen_{serial,interpolates,limit,spherical}`
- `FormalSystem.Metalogic.WeakCanonical`: `zTaskFrameV2_{fib_subsingleton,serial,interpolates,limit,spherical}`,
  `multiFamTaskFrame_{eq_gen,serial,interpolates,limit,spherical}`

**Deviations**:
- **No fallback needed** (noted). The phase's stated fallback ("if generalization resists, prove
  the generic facts directly") was not reached — the generic facts were already in the tree.
- **The phase's caution that `bundleFlow_*` "are consumed elsewhere" is stale** (noted, no action).
  `grep -rn "multiFamGen_*\|bundleFlow_*" FormalSystem/ Tests/` outside `FlowFrame.lean` returns
  **zero hits** — none of these lemmas has an external consumer today. They were nonetheless left
  untouched, as the phase's constraint requires.
- **`bundleFlowFrame`'s non-site status recorded in the module docstring**, as the phase asked:
  `FlowFrame.lean` now carries a dedicated "`bundleFlowFrame` is a specialization, not a
  construction site" section stating that it is a `def` whose body applies the generic frame, has
  no field obligations of its own, and must not be counted in any site inventory.

---

### Phase 13: Caveat (a) — restrict or re-carrier the dense-polymorphic failure sites [COMPLETED]

**Goal**: The three sites flagged as failing dense-polymorphically — `RefinedFilteredTaskFrame`,
`FiniteFilteredTaskFrame`, and `regionFrame` — each either have the four axiom facts proved, or
have been restricted/re-carriered so that they do. **This work is NOT addressed by the landed
`bundleFlowFrame` carrier and is the one genuinely open technical item this revision inherits.**

**Standing constraint**: a site is not "handled" by weakening a statement, by making the frame
vacuous, or by a `sorry`. If a site cannot be discharged, the correct outcome is to stop with a
precise gap statement and re-revise — the same rule that governed the retired blocker.

**Sub-step 13.1 — `regionFrame` (RegionFrame.lean:169): falsification test FIRST.**
- [x] Read the current definition. As observed 2026-08-12 it is `WorldState := W × D` with
      `TaskRel := fun s d s' => s.1 = s'.1 ∧ s'.2 = s.2 + d` — deterministic-shift shape, for which
      `limit_of_shift` applies with `pos := Prod.snd`, i.e. structurally identical to
      `multiFamTaskFrameGen`. **Test this, do not assume it.**
- [x] If the test passes: prove the four lemmas exactly as in Phase 12, and CLOSE the flag by
      recording a `#### Reasoned Exclusions` entry in this phase whose Evidence column carries the
      definition text and the discharging lemma names. The flag predates the RegionFrame refactor
      (region structure moved from state to valuation, RegionFrame.lean:160-168) and the site's
      move out of `Omega.lean`; closing it on that evidence is legitimate, closing it on assumption
      is not.
- [x] If the test fails: treat `regionFrame` under sub-step 13.2's restriction/re-carrier ladder
      and say so plainly in the summary.

**Sub-step 13.2 — the two filtration sites.**
- [x] Enumerate the consumers of `RefinedFilteredTaskFrame` (Filtration.lean:197) and
      `FiniteFilteredTaskFrame` (FiniteModel.lean:159) and the duration types they elaborate at
      (`grep -rn "RefinedFilteredTaskFrame\|FiniteFilteredTaskFrame\|refinedFilteredTaskRel" FormalSystem/ Tests/`).
      This enumeration decides the option, and must come before any edit.
- [x] Confirm the failure: `refinedFilteredTaskRel` (Filtration.lean:190) is
      `if d = 0 then w = u else True`, so over dense `D` every `u` sits in every cone and *Limit*
      collapses. Over a discrete `D`, `|y| < 1 → y = 0` restores it.
- [x] Choose ONE, based on what the enumerated consumers need, and record the choice with its
      reason:
      - **(a) Restrict**: add `[SuccOrder D] [NoMaxOrder D]` to both definitions and discharge
        *Limit* via `limit_of_succOrder`. Coordinate with the FMP-to-`ℤ` direction if that move is
        live; if every consumer is already at `ℤ` (or another discrete type), this is the cheap and
        honest option.
      - **(b) Re-carrier**: give the filtered frame a position-carrying carrier so `limit_of_shift`
        applies — the same manoeuvre that retired the blocker for the canonical model.
- [x] Prove *Seriality* (both conjuncts; at `d ≠ 0` the relation is universal, at `d = 0` it is
      identity), interpolation (split on whether `x + y = 0`; the existing `forward_comp` proof at
      Filtration.lean:208+ is the template), and *Spherical* (Phase 10's Helper B argument adapts:
      fibers are the whole carrier or a singleton) for the chosen form.
- [x] `FiniteFilteredTaskFrame` is `FiniteTaskFrame D where toTaskFrame := RefinedFilteredTaskFrame D phi`
      — it inherits whatever the refined frame becomes. Confirm `FiniteTaskFrame` (TaskFrame.lean:665)
      `extends TaskFrame`, so Phase 14's new fields propagate to it, and that no other
      `FiniteTaskFrame` construction exists.

**Timing**: 2.5 hours

**Depends on**: 10

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly three flagged sites, at Filtration.lean:197, FiniteModel.lean:159,
and RegionFrame.lean:169 (2026-08-12 inventory). `FiniteFilteredTaskFrame` is expected to be the
only live `FiniteTaskFrame` construction — confirm with
`grep -rn "FiniteTaskFrame" FormalSystem/ Tests/ --include=*.lean`. Any binder change is
`interface`-tier: build the enumerated dependents, not just the edited module.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean`
- `FormalSystem/Metalogic/Decidability/FMP/FiniteModel.lean`
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean`
- consumers of the above, as the chosen option requires (enumerated in-phase)

**Constraints**:
- No structure-field change; no edits to `FormalSystem/Semantics/TaskFrame.lean`.
- No vacuous repair: a frame nothing can instantiate, or a `D` restricted so narrowly that a live
  consumer breaks, is not a repair.
- No task-number citations. No `sorry`, no new axiom.

**Verification**:
- `lake build` — green after every sub-step commit (full build: FMP and Bridge consumers are wide)
- `grep -n "sorry"` on every touched file returns nothing
- `#print axioms` on each new lemma — only the standard Lean axioms
- The chosen option, and for `regionFrame` the falsification-test result, are recorded in the phase
  body (a `#### Reasoned Exclusions` record if the flag is closed) and in the summary

#### Reasoned Exclusions

| Item | Reason | Evidence |
|---|---|---|
| `regionFrame` (RegionFrame.lean:169) — the dense-polymorphic failure flag | **Flag REFUTED, not assumed away.** The falsification test was run first, as this phase requires, and failed to falsify: all four `def:frame` axioms were proved for `regionFrame` at **polymorphic `D` under `[Nontrivial D]` alone**, with no discreteness hypothesis anywhere. Had the flag been right, *Limit* could not have elaborated. The site therefore needs neither restriction nor re-carriering, and is excluded from sub-step 13.2's ladder. | **Definition text** (RegionFrame.lean:169-171): `def regionFrame (W ι D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] : TaskFrame D where WorldState := W × D; TaskRel := fun s d s' => s.1 = s'.1 ∧ s'.2 = s.2 + d` — the deterministic clock, structurally identical to `multiFamTaskFrameGen`. **Discharging lemmas** (all `lake build` green, `#print axioms` standard-only): `regionFrame_fib_subsingleton`, `regionFrame_serial`, `regionFrame_interpolates`, `regionFrame_limit` (via `TaskFrame.limit_of_shift` with `pos := Prod.snd`, hypotheses `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` — no `SuccOrder`, no `NoMaxOrder`), `regionFrame_spherical` (via `TaskFrame.sInter_nonempty_of_directed_of_univ_or_singleton`). **Root cause of the stale flag**, now recorded in the file: the flag was accurate against the frame's *former* relation `TaskRel s d s' := d = 0 → s = s'`, described in `regionFrame`'s own docstring at :155-157, which above zero related every pair and so did collapse *Limit* over dense `D`. The RegionFrame refactor replaced it with the clock; the flag was never re-tested against the replacement. |

**Verification results** (measured 2026-08-12):
- `lake build` — GREEN, exit 0, 2331 jobs, after each of the two sub-step commits
- `grep -n "sorry"` on all four touched files (`RegionFrame.lean`, `Filtration.lean`,
  `FiniteModel.lean`, `FMP.lean`) — **0 hits each**
- `#print axioms` on all new declarations — only `propext`, `Classical.choice`, `Quot.sound`
- Scope Hypothesis confirmed: exactly three flagged sites; `FiniteFilteredTaskFrame` is the only
  live `FiniteTaskFrame` construction (`grep -rn "FiniteTaskFrame" FormalSystem/ Tests/`: the
  structure itself, its namespace/`Coe` instance, `TaskModel.lean:98`, `FMP.lean:171/179`, and
  `FiniteModel.lean:160` — one construction); `FiniteTaskFrame` `extends TaskFrame`
  (TaskFrame.lean:1135-1136) confirmed, so Phase 14's fields propagate to it.

**Sub-step 13.2 — the option chosen, and why**: **(a) Restrict.** The consumer enumeration
required before any edit returned: `RefinedFilteredTaskFrame` → `FiniteFilteredTaskFrame` (and
`FiniteFilteredTaskFrame.worldState_eq`) → `filteredFiniteFrame` (FMP.lean:177), all three
polymorphic in `D`, and **nothing outside `FMP/` refers to any of them** — `filteredFiniteFrame`
and `BundledFilteredFrame` have zero consumers anywhere in `FormalSystem/` or `Tests/`. No live
consumer elaborates at a dense duration type, so the restriction breaks nothing. Option (b)
re-carriering would rebuild a carrier that `FilteredWorld.finite` depends on, for no gain. The
restriction is *forced by the axiom*: `refinedFilteredTaskRel` is universal above duration zero,
so over dense `D` every filtered world sits in every cone of every other and *Limit* collapses;
`TaskFrame.exists_uniform_radius_of_finite` records the same fact from the other side. Both
`TaskFrame.lean:371-372` and the frame's new docstring say so.
`[SuccOrder D] [NoMaxOrder D]` was added to `RefinedFilteredTaskFrame`,
`FiniteFilteredTaskFrame`, `FiniteFilteredTaskFrame.worldState_eq`, and `filteredFiniteFrame`.

**Landed declarations**:
- `…Verified.Bridge`: `regionFrame_{fib_subsingleton,serial,interpolates,limit,spherical}`
- `…Decidability.FMP`: `RefinedFilteredTaskFrame_{rel_iff,serial,interpolates,limit,spherical}`,
  `FiniteFilteredTaskFrame.taskRel_eq`,
  `FiniteFilteredTaskFrame_{serial,interpolates,limit,spherical}`

**Deviations**:
- **`regionFrame`'s *Spherical* routes through `TaskFrame.lean`'s directed-family helper, not
  `FlowFrame.lean`'s** (altered). The phase text points at Phase 12's route, but
  `Algebraic.sInter_nonempty_of_directed_subsingleton` is unreachable: `FlowFrame.lean` is not in
  the transitive import closure of either `RegionFrame.lean` or `Filtration.lean` (verified by
  walking the `import` graph). `TaskFrame.sInter_nonempty_of_directed_of_univ_or_singleton`
  (Phase 10) is reachable everywhere and does the same work, so **no edit to
  `FormalSystem/Semantics/TaskFrame.lean` was needed** and the phase's no-edit constraint on that
  file holds.
- **`refinedFilteredTaskRel` is the permissive class, so the helpers applied directly** (noted).
  The phase anticipated adapting Helper B's *Spherical* argument and using the existing
  `forward_comp` proof as an interpolation template. Neither was necessary: `if d = 0 then w = u
  else True` and `d ≠ 0 ∨ w = u` are the same proposition, recorded once as
  `RefinedFilteredTaskFrame_rel_iff`, after which all four axioms are one-line helper citations.

---

### Phase 14.1: Add the four axiom fields and discharge all 14 sites (atomic batch) [COMPLETED]

*(This phase is the "14a" half of the split recorded in `#### SIZING FINDING` below. It is the
core deliverable and the only part Phase 15 depends on.)*

**Goal**: `TaskFrame` carries the four axiom fields — `comp` (biconditional), `serial`, `limit`,
`spherical` — each **definitionally** one of the three recorded Props (or *Limit*'s literal
shape); the frame definitions whose *Limit* lemma requires them have acquired their binders;
`forward_comp` survives as the `←` projection of `comp`; every one of the 14 live sites discharges
every field by citing a lemma proved in Phases 10-13; and every docstring that describes these
four axioms as absent is corrected.

**Explicitly NOT in this phase**: the `[Nontrivial D]` *structure* binder on `TaskFrame` and the
`Nonempty WorldState` field. Both belong to Phase 14.2, are independent of the four axioms, and
gate nothing in Phase 15. Per-site binders on individual frame *definitions* (e.g.
`[Nontrivial D]` on `staticFrame`) ARE in scope here — they are forced by the *Limit* field and
are a different thing from a binder on the structure.

**This phase discovers no proofs.** Every discharge is a citation of an existing lemma. If a site
has no lemma to cite, the batch was entered too early: stop, return to the owning phase, and
re-enter.

**Field targets** (the three Props now live in `FormalSystem/Semantics/TaskFrame.lean` above the
structure, moved there verbatim by sub-step 14.0 — see finding S5; **never restate them inline** —
see the Cross-Task Acceptance Criterion above):

| Paper axiom | Target field | Definitional content |
|---|---|---|
| *Compositionality* (biconditional) | `comp : ∀ w v x y, 0 ≤ x → 0 ≤ y → (TaskRel w (x+y) v ↔ ∃ u, TaskRel w x u ∧ TaskRel u y v)` | its `→` half is exactly `Interpolates TaskRel` (TaskFrame.lean:355 post-hoist); its `←` half is the current `forward_comp`. `Interpolates`'s own docstring states the target: "The full biconditional axiom is therefore `forward_comp ∧ Interpolates`." The implementer may land the pair as one biconditional field or as `forward_comp` + an `interpolates` field, provided `F.interpolates` is definitionally `Interpolates F.TaskRel` and `F.forward_comp` remains available with its current statement |
| *Seriality* | `serial` | definitionally `Serial TaskRel` (TaskFrame.lean:337 post-hoist) |
| *Limit* | `limit` | the literal transcribed shape `∀ w u, (∀ x, 0 < x → ∃ y, \|y\| < x ∧ TaskRel w y u) → u = w` — exactly what `limit_of_succOrder` and `limit_of_shift` conclude and what `nullity_of_serial_limit` (still in FrameAxioms.lean) consumes |
| *Spherical* | `spherical` | definitionally `Spherical TaskRel` (TaskFrame.lean:322 post-hoist) |

All four line numbers above are post-hoist observations from 2026-08-13 and are plan-time
hypotheses: read the file and confirm before editing.

**Corrected site inventory — 14 live sites** (was wrongly 16 in v2; see `### Corrected Site
Inventory`). Every entry is `where`-syntax; no `.mk` site exists:

| # | Site | file:line | Class | Discharged by |
|---|---|---|---|---|
| 1 | `trivialFrame` | Semantics/TaskFrame.lean:538 | `Unit` / total | Phase 10, Helper A |
| 2 | `staticFrame` | Semantics/TaskFrame.lean:563 | equality | Phase 10, Helper C (+ `staticFrame_serial` :577) |
| 3 | `natFrame` | Semantics/TaskFrame.lean:591 | permissive | Phase 10, Helper B (discrete binders) |
| 4 | `intTimeFrame` | Examples/TemporalStructures.lean:77 | `Unit` / total | Phase 11 |
| 5 | `intNatFrame` | Examples/TemporalStructures.lean:90 | permissive at `Int` | Phase 11 |
| 6 | `genericTimeFrame` | Examples/TemporalStructures.lean:157 | `Unit` / total | Phase 11 |
| 7 | `genericNatFrame` | Examples/TemporalStructures.lean:169 | permissive, polymorphic | Phase 11 (discrete binders) |
| 8 | `multiFamTaskFrameGen` | Metalogic/Algebraic/FlowFrame.lean:130 | deterministic shift | Phase 12 — **also discharges `bundleFlowFrame` (:361), which is definitionally this frame and is NOT a separate site** |
| 9 | `zTaskFrameV2` | Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:453 | shift at `ℤ` | Phase 12 |
| 10 | `multiFamTaskFrame` | Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:697 | shift at `ℤ` | Phase 12 |
| 11 | `RefinedFilteredTaskFrame` | Metalogic/Decidability/FMP/Filtration.lean:197 | caveat (a) | Phase 13.2 |
| 12 | `FiniteFilteredTaskFrame` | Metalogic/Decidability/FMP/FiniteModel.lean:159 | caveat (a); `FiniteTaskFrame` extends `TaskFrame`, so it inherits every field obligation | Phase 13.2 |
| 13 | `regionFrame` | Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:169 | caveat (a); shift-shaped as observed | Phase 13.1 |
| 14 | `customFrame` | Tests/BimodalTest/Semantics/TaskFrameTest.lean:60 | permissive at `Int` | Phase 10 |

Non-sites (aliases or specializations; no field obligation of their own): `bundleFlowFrame`
(FlowFrame.lean:361), `Tests/BimodalTest/Property/Generators.lean:176/179`,
`Tests/BimodalTest/Semantics/TruthTest.lean:29`, and
`Tests/BimodalTest/Semantics/SemanticBenchmark.lean:50` (see Phase 10's Scope Hypothesis (iii)).
Dead and excluded: everything under `FormalSystem/Boneyard/` — re-confirm the exclusion holds
(`lakefile.lean:16-19` roots only `FormalSystem`; `FormalSystem.lean` has no `Boneyard` import).

#### Pre-batch state as of 2026-08-12 (batch NOT opened)

**Sub-step 14.0 is LANDED and committed green** — the one piece of this phase that could be done
without opening the red window. The `Fib`/`cone`/`Seg`/`DirectedFamily`/`IsFiber`/`IsSegment`
apparatus and the `Spherical`/`Serial`/`Interpolates` predicates were hoisted from *after* the
`TaskFrame` structure to *before* it (TaskFrame.lean, own `namespace TaskFrame` block at :151-358;
the structure now begins at :401). Pure relocation, no statement changed, no consumer touched.
It is a hard prerequisite: a structure field's type may only mention declarations that precede
it, so without it not one of the four fields is statable. `lake build` green, 2331 jobs.

**All four pre-batch gates PASS** (re-run 2026-08-12, after Phase 13):

| Gate | Result |
|---|---|
| Site-discovery grep reconciles with the table below | **PASS — exactly 14 live `where`-sites**, no new site, no disappeared site (line numbers have shifted from this table by the Phases 10-13 insertions; see the readiness table below for current ones) |
| Zero `.mk` sites | **PASS** — `grep -rn "TaskFrame.mk\|FiniteTaskFrame.mk"` outside `Boneyard/` returns nothing |
| Every site has a citable lemma from Phases 10-13 | **PASS — 14/14**, enumerated in the readiness table below |
| `Boneyard/` exclusion still holds | **PASS** — `lakefile.lean:15-19` roots only `FormalSystem`; `FormalSystem.lean` has no `Boneyard` import |
| Caveat (b) — has the `nullity_identity` joint decision landed? | **NO.** `specs/decisions/` holds `total-history-validity-decisions.md` and `untl-snce-argument-order.md`; neither mentions `nullity_identity`. Leave the field AS-IS. |

**Site readiness — all 14 discharged by an existing, landed, sorry-free lemma**:

| # | Site | file:line (current) | Citable lemmas |
|---|---|---|---|
| 1 | `trivialFrame` | Semantics/TaskFrame.lean:911 | `trivialFrame_{serial,interpolates,limit,spherical}` |
| 2 | `staticFrame` | Semantics/TaskFrame.lean:963 | `staticFrame_{serial,interpolates,limit,spherical}` (`limit` needs `[Nontrivial D]`) |
| 3 | `natFrame` | Semantics/TaskFrame.lean:1019 | `natFrame_{serial,interpolates,limit,spherical}` (`limit` needs `[SuccOrder D] [NoMaxOrder D]`) |
| 4 | `intTimeFrame` | Examples/TemporalStructures.lean:78 | `intTimeFrame_{serial,interpolates,limit,spherical}` |
| 5 | `intNatFrame` | Examples/TemporalStructures.lean:118 | `intNatFrame_{serial,interpolates,limit,spherical}` |
| 6 | `genericTimeFrame` | Examples/TemporalStructures.lean:216 | `genericTimeFrame_{serial,interpolates,limit,spherical}` (no restriction on `D`) |
| 7 | `genericNatFrame` | Examples/TemporalStructures.lean:256 | `genericNatFrame_{serial,interpolates,limit,spherical}` (`limit` needs `[SuccOrder D] [NoMaxOrder D]`) |
| 8 | `multiFamTaskFrameGen` | Metalogic/Algebraic/FlowFrame.lean:145 | `multiFamTaskFrameGen_{serial,interpolates,limit,spherical}` (`limit` needs `[Nontrivial D]`) — also covers `bundleFlowFrame`, which is NOT a site |
| 9 | `zTaskFrameV2` | …/ReynoldsBridge.lean:453 | `zTaskFrameV2_{serial,interpolates,limit,spherical}` |
| 10 | `multiFamTaskFrame` | …/ReynoldsBridge.lean:752 | `multiFamTaskFrame_{serial,interpolates,limit,spherical}` |
| 11 | `RefinedFilteredTaskFrame` | …/FMP/Filtration.lean:213 | `RefinedFilteredTaskFrame_{serial,interpolates,limit,spherical}` — binders already applied |
| 12 | `FiniteFilteredTaskFrame` | …/FMP/FiniteModel.lean:160 | `FiniteFilteredTaskFrame_{serial,interpolates,limit,spherical}` — binders already applied |
| 13 | `regionFrame` | …/Bridge/RegionFrame.lean:170 | `regionFrame_{serial,interpolates,limit,spherical}` (`limit` needs `[Nontrivial D]`) |
| 14 | `customFrame` | Tests/…/TaskFrameTest.lean:61 | `customFrame_{serial,interpolates,limit,spherical}` |

#### SIZING FINDING — preserved verbatim; this is the justification for the 14.1 / 14.2 split

*(Recorded by the implementation dispatch of 2026-08-12 against the then-undivided Phase 14.
**Preserved, not deleted as resolved**: it is the measured evidence on which this plan's split
rests, and re-merging the two phases would have to argue against these numbers. Its "Recommended
re-size" paragraph has been updated in place to record that the recommendation was adopted.)*

**The batch was deliberately NOT opened.** Not because a site lacks a lemma — all 14 have one —
but because the phase's task list bundles the four axiom fields together with two *structural*
changes whose blast radius was never measured when the phase was written, and which together are
far more than one agent run can close inside a window where `sorry` is forbidden and no partial
state may be committed. Opening it would have produced a long red window with nothing
committable. Measured 2026-08-12:

| Task-list item | Measured blast radius |
|---|---|
| `[Nontrivial D]` as a `TaskFrame` structure binder | **575 `TaskFrame` mentions across 49 files.** Every declaration with a polymorphic `D` that mentions `TaskFrame D` needs the instance in scope. This is not needed to *state* any of the four axiom fields — the field types are `Serial TaskRel`, `Interpolates TaskRel`, `Spherical TaskRel`, and *Limit*'s literal shape, none of which mentions `Nontrivial`. |
| `Nonempty WorldState` | Cheap as a *field*, but its **discharge** is not: `staticFrame` and `regionFrame` need `[Nonempty W]`, `multiFamTaskFrameGen` needs `[Nonempty FamIdx]`, `bundleFlowFrame` needs `B.families` nonempty, and `FilteredWorld phi` needs a nonemptiness proof that does not exist yet. Each new binder propagates to that frame's consumers. |
| Per-site binder propagation forced by the *Limit* field | **~225 mentions across ~20 files**: `staticFrame` 27/4, `multiFamTaskFrameGen` 63/5 (plus `bundleFlowFrame` 29), `regionFrame` 65/5, `natFrame` 50/5, `genericNatFrame` 20/2. The frames whose *Limit* lemmas carry `[Nontrivial D]` or `[SuccOrder D] [NoMaxOrder D]` must acquire those binders on their definitions, and every consumer must supply them. |

**Recommended re-size** (a plan decision — **ADOPTED by plan v4; this is the split now in
force**): split Phase 14 into
(14a) the four axiom fields plus the per-site binder propagation and the 14 discharges — the core
deliverable, and the only part the Cross-Task Acceptance Criterion binds; and
(14b) `[Nontrivial D]` and `Nonempty WorldState`, which are independent of the four axioms, have
their own much larger propagation, and gate nothing in Phase 15. Phase 15's substitution depends
only on 14a.

**Disposition**: 14a is **this phase, Phase 14.1**; 14b is **Phase 14.2**. Decimal sub-phase
numbering is used rather than letter suffixes because `### Phase 14a:` is not a conforming phase
heading in this repository — see `context/formats/plan-format.md`'s "Canonical phase-heading
shape". Phase 15 keeps its number and its `Depends on` is re-pointed to 14.1 alone.

**Two further sizing measures this plan adds on top of the recommendation**, both applying the
same "pre-repair before the batch" pattern that Phase 8 and Phases 10-13 used successfully:
- The per-site binder propagation (~225 mentions / ~20 files, the bulk of 14a's file churn) is
  **green on its own** — a stricter binder on a frame definition compiles without any field
  existing — so it is declared as sub-step 14.1.1 and committed per-substep BEFORE the red window
  opens. Only the field addition and the 14 discharges happen inside the window.
- The missing `Nonempty (FilteredWorld phi)` proof is a **pure addition**, so it is declared as
  sub-step 14.2.1 and committed green before either of 14.2's windows opens.

**Nothing here is descoped by assumption.** Every gate the phase names was run and passed; the
only reason the batch stayed shut is the measured sizing above.

#### Per-site binder propagation targets (sub-step 14.1.1)

Derived from the site-readiness table above: a frame definition must acquire whatever binders its
cited *Limit* lemma carries. Counts are from the 2026-08-12 measurement and are **hypotheses to
re-run**, not facts.

| Frame definition | Binders to add | Measured mentions / files |
|---|---|---|
| `staticFrame` (Semantics/TaskFrame.lean) | `[Nontrivial D]` | 27 / 4 |
| `natFrame` (Semantics/TaskFrame.lean) | `[SuccOrder D] [NoMaxOrder D]` | 50 / 5 |
| `genericNatFrame` (Examples/TemporalStructures.lean) | `[SuccOrder D] [NoMaxOrder D]` | 20 / 2 |
| `multiFamTaskFrameGen` (Metalogic/Algebraic/FlowFrame.lean) | `[Nontrivial D]` | 63 / 5, plus `bundleFlowFrame` 29 |
| `regionFrame` (…/Verified/Bridge/RegionFrame.lean) | `[Nontrivial D]` | 65 / 5 |
| `RefinedFilteredTaskFrame`, `FiniteFilteredTaskFrame` | none — `[SuccOrder D] [NoMaxOrder D]` already applied by Phase 13.2 | -- |
| `trivialFrame`, `intTimeFrame`, `genericTimeFrame` | none — subsingleton carrier, *Limit* holds over any `D` | -- |
| `intNatFrame`, `zTaskFrameV2`, `multiFamTaskFrame`, `customFrame` | none — all at `Int`/`ℤ`, which supplies every needed instance | -- |

Known propagation targets already enumerated by the landing phases: `natFrame`'s binder change
propagates only to `WorldHistory.universalNatFrame` (WorldHistory.lean:215), itself polymorphic in
`D` with zero consumers of its own (Phase 10 deviation record); `genericNatFrame` has **zero
consumers anywhere** in `FormalSystem/` or `Tests/` (Phase 11 verification results). Both are
therefore expected cheap — confirm, do not assume.

**Tasks**:

*Sub-step 14.1.0 — gates (cheap; re-run, do not trust the recorded PASSes above).*
- [x] Re-run the full site-discovery greps and reconcile against the table above **before adding
      any field**. Treat any newly-appeared site as in scope (and as a signal that a Phase 10-13
      lemma is missing); treat any disappeared site as resolved.
- [x] Confirm every site in the table has a citable lemma from Phases 10-13. If one does not,
      **do not enter the batch**. *(deviation: altered — all 56 frame-level lemmas verified present, but they are stated over `(X).TaskRel` and so are NOT citable from inside `X`'s own `where` block (forward reference). The five class-helper families of Phase 10 ARE citable, being bare-relation; the four deterministic-shift sites transcribe their landed lemma's proof term over the raw relation instead. No proof was discovered.)*
- [x] Re-confirm the `Boneyard/` exclusion still holds.
- [x] Re-read `FormalSystem/Semantics/TaskFrame.lean` around the three hoisted Props and
      `structure TaskFrame` and record their **current** line numbers. Sub-step 14.0's hoist
      shifted every line number this plan recorded before 2026-08-12; the numbers in this phase
      body are hypotheses.

*Sub-step 14.1.1 — per-site binder propagation. GREEN, committed per-substep, BEFORE the batch
opens.*
- [x] For each frame definition in the "Per-site binder propagation targets" table above, add the
      binders its cited *Limit* lemma carries, and thread them through that definition's
      consumers until `lake build` is green. **Commit each frame's propagation separately as its
      own green sub-step.** This is ordinary per-substep work and is NOT part of the atomic batch.
- [x] If any single frame's propagation turns out NOT to be green on its own *(deviation: skipped — all five propagations were green on their own; none had to be folded into the batch)* — original text: — i.e. the binder
      cannot be added without a field already existing — stop treating it as a pre-batch step,
      record why, and fold that one frame into the batch below. Do not fold the others in with it.
- [x] Confirm after the last propagation commit: `lake build` green, working tree clean. The batch
      may not open until this holds.

*Sub-step 14.1.2 — the atomic batch. Red from the first field to the last discharge; no commit
until green.*
- [x] Add the four fields per the target table, each definitionally one of the three hoisted Props
      (or *Limit*'s literal shape). *(deviation: altered — `comp` is stated as the NEW named Prop `TaskFrame.Compositional TaskRel`, declared beside `Serial`/`Interpolates`/`Spherical` above the structure and delta-reducing to the plan's exact `∀ w v x y, 0 ≤ x → 0 ≤ y → (TaskRel w (x+y) v ↔ ∃ u, …)` shape. Naming it is what keeps the field a citation rather than an inline restatement, and it makes the site discharges unify first-order instead of against an applied metavariable.)* **Do NOT add `[Nontrivial D]` to the `TaskFrame` structure
      binder list and do NOT add a `Nonempty WorldState` field — those are Phase 14.2.**
- [x] Immediately re-derive `forward_comp` as the `←` projection of `comp` (if `comp` replaces it
      as a single biconditional field), so the 46 existing references across 12 files stay
      mechanical or untouched.
- [x] Discharge all 14 sites by citation, in the order of the table. Every site's binders are
      already in place from 14.1.1, so no discharge should require a signature change here; if one
      does, that is a missed propagation target — add it and record the miss.
- [x] **Correct every docstring that describes these FOUR AXIOMS as absent.** The interpolation
      direction, *Seriality*, *Limit*, and *Spherical* are no longer "known gaps" once this phase
      lands; the prose must say so. **Leave the `Nonempty WorldState` and `[Nontrivial D]` entries
      in those same blocks standing** — they are still true until Phase 14.2 lands, and marking
      them corrected here would be a false statement in the tree. Known stale sites as of
      2026-08-12, all in `FormalSystem/Semantics/TaskFrame.lean`: the module "Known gaps relative
      to the paper" block (:74-89, which lists `Nonempty WorldState`, `[Nontrivial D]`,
      *Seriality*, *Limit*, *Spherical*, and the interpolation direction as absent, and says the
      apparatus "awaits consumption by the structure change"), the `forward_comp` bullet at
      :64-65, the Main Definitions entry at :96-97, the structure's Paper-Alignment paragraph at
      :153-159, the *Compositionality* paragraph at :167-171, and the `forward_comp` field
      docstring at :199-213 — each of which still says the `→` (interpolation) direction "is a
      known gap that lands with the structure change". Also re-check
      `FormalSystem/Semantics/Extension/Extension.lean:63` and
      `FormalSystem/Semantics/Extension/Step.lean:39` (which describes the hypothesis-binder
      arrangement as provisional, "When the axiom fields are …"). Confirm each line by reading
      before editing; **all these numbers predate sub-step 14.0's hoist and are stale by
      construction**.
- [x] Leave `nullity_identity` AS-IS (caveat (b)) unless the joint decision has landed by then; if
      it has, apply it inside this same batch and cite the decision record.

**Timing**: 3 hours (1 hour for sub-step 14.1.1's propagation, 2 hours for the batch)

**Depends on**: 10, 11, 12, 13

**Verification Tier**: full

**Commit Mode**: atomic-batch

Rationale for `atomic-batch` (carried from v2/v3, unchanged in substance): adding structure fields
is inherently atomic across all construction sites — the build is red from the first field until
the last site is discharged, and a partial field addition breaks the build. All `where`-syntax
means the compiler enumerates missing-field sites cleanly, but intermediate per-file states are
expected red and MUST NOT be committed. The batch is declared here, in advance (anti-abuse guard
satisfied), and is deliberately kept as small as it can be: every proof it needs was already
landed, green and committed, by Phases 10-13, and every binder it needs is landed green by
sub-step 14.1.1.

**Scope of the batch, precisely**: the atomic-batch carve-out covers **sub-step 14.1.2 only**.
Sub-steps 14.1.0 and 14.1.1 are green work under the ordinary per-substep mandate and MUST be
committed as they land. This is the same arrangement sub-step 14.0 already used successfully
inside the undivided Phase 14, and it is declared in advance here, so it is not a retroactive
widening or narrowing of a batch.

**Scope Hypothesis**: 14 live sites, 0 `.mk` sites, per finding R4 (verified 2026-08-12) — the
count is **14, not 16**; any artifact still saying 16 is stale. Reference counts to re-confirm at
implementation time: 46 `forward_comp` references across 12 files, 40 `nullity_identity`
references, and the ~225 mentions / ~20 files of the per-site binder table above. Re-run every
discovery grep before adding a field.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — the four fields, `forward_comp`'s re-derivation, the
  `trivialFrame`/`staticFrame`/`natFrame` discharges and their binders, the four-axiom docstring
  corrections
- `FormalSystem/Examples/TemporalStructures.lean` — four site discharges plus `genericNatFrame`'s
  binders
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`,
  `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` — three site discharges
  plus `multiFamTaskFrameGen`'s binders
- `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean`,
  `FormalSystem/Metalogic/Decidability/FMP/FiniteModel.lean`,
  `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` — three site discharges
  plus `regionFrame`'s binders
- `Tests/BimodalTest/Semantics/TaskFrameTest.lean` — `customFrame`'s discharge
- `FormalSystem/Semantics/WorldHistory.lean` and the other consumers the binder propagation
  reaches — enumerated in-phase by sub-step 14.1.1, not listed exhaustively here

**Constraints**:
- **The three Props are cited, never restated.** A field whose statement differs from the recorded
  Prop is a defect even if it typechecks in isolation — Phase 15 is where it fails, and that
  failure is the acceptance test.
- **NEVER `sorry` a site**, not even transiently inside the red window.
- **Do not touch `structure TaskFrame`'s binder list and do not add a nonemptiness field.** Those
  are Phase 14.2's territory, and pulling them in here re-creates the measured over-size that
  stopped the previous dispatch.
- Do not settle caveat (b) unilaterally.
- Notation: converse operations use `inv`/`⁻¹` vocabulary, never breve/smile.
- No task-number citations in any Lean file (cite `def:frame` sub-anchors, `lem:step`, filenames).
- Lean v4.33.0-rc1, Mathlib pinned to tag v4.33.0-rc1.

**Verification**:
- `lake build` — green after every 14.1.1 sub-step commit, and green at the single 14.1.2 batch
  commit
- `grep -rn "sorry" FormalSystem/ Tests/` shows no new occurrences relative to the pre-batch
  baseline
- `#print axioms` on every touched frame — no new axiom
- `Completeness.lean`, `ChronicleToCountermodelBasic.lean`, and the `CompletenessDedekind.lean`
  probes still elaborate
- `grep -n "known gap\|awaits consumption\|is absent from the structure" FormalSystem/Semantics/TaskFrame.lean`
  returns nothing that refers to the FOUR AXIOMS (hits that refer only to `Nonempty WorldState` or
  `[Nontrivial D]` are expected and correct until Phase 14.2 lands)
- Each of `F.serial`, `F.spherical`, and the interpolation half reduces to the recorded Prop by
  `rfl` (check with `example : Serial F.TaskRel := F.serial` and siblings)

---

### Phase 14.2: TaskFrame structure binders — Nontrivial D and Nonempty WorldState [NOT STARTED]

*(This phase is the "14b" half of the split recorded in `#### SIZING FINDING` above. It is
independent of the four axiom fields and **gates nothing in Phase 15**.)*

**Goal**: `TaskFrame` carries `[Nontrivial D]` as a structure binder and requires its world-state
type to be nonempty, as `def:temporal-order` and `def:task-relation` demand; every declaration
mentioning `TaskFrame D` at polymorphic `D` supplies the instance; all 14 live sites discharge the
nonemptiness obligation, including `FilteredWorld phi`, whose nonemptiness proof **does not exist
in the tree and is written here**; and the two remaining "known gaps" docstring entries are
corrected.

**Why this is separate**: measured blast radius. `[Nontrivial D]` alone touches **575 `TaskFrame`
mentions across 49 files** (re-measured at 578/49 on 2026-08-13) and is needed to state none of
the four axiom fields — the field types mention only `Serial`, `Interpolates`, `Spherical`, and
*Limit*'s literal shape. `Nonempty WorldState` is cheap to declare and expensive to discharge,
and one of its discharges is a proof that has to be found rather than cited. See
`#### SIZING FINDING` in Phase 14.1.

**Nonemptiness discharge inventory** — plan-time hypothesis, confirm each by reading:

| Site | Expected route |
|---|---|
| `trivialFrame`, `intTimeFrame`, `genericTimeFrame` | `Unit` carrier — `inferInstance` |
| `staticFrame` | new `[Nonempty W]` binder on the definition, propagated to consumers |
| `regionFrame` | new `[Nonempty W]` binder (carrier `W × D`; `D` is nonempty as an `AddCommGroup`) |
| `multiFamTaskFrameGen` | new `[Nonempty FamIdx]` binder, propagated to consumers |
| `bundleFlowFrame` | needs `B.families` nonempty — decide between a `BFMCS` field, a hypothesis, or a derived proof, and record the choice with its reason. Note this is a *specialization*, not a 15th site: whatever it needs, it needs in order to apply `multiFamTaskFrameGen` |
| `natFrame`, `intNatFrame`, `zTaskFrameV2`, `multiFamTaskFrame`, `customFrame` | carriers at `Int`/`ℤ` or already inhabited — expected free; confirm each |
| `RefinedFilteredTaskFrame`, `FiniteFilteredTaskFrame` | **blocked on a proof that does not exist** — `Nonempty (FilteredWorld phi)`. See sub-step 14.2.1 |

**Tasks**:

*Sub-step 14.2.1 — the missing `FilteredWorld` nonemptiness proof. GREEN pure addition, committed
before either window opens.*
- [ ] Confirm the gap before proving: `grep -rn "FilteredWorld" FormalSystem/ --include=*.lean`
      yields a `Finite` instance (`FilteredWorld.finite`, FiniteModel.lean:137) and **no
      `Nonempty` instance or lemma**. `Finite` does not give `Nonempty`. Do not assume the proof
      exists and do not assume it is trivial.
- [ ] Prove `Nonempty (FilteredWorld phi)` (or the inhabited-ness statement the field shape
      chosen below actually needs). `FilteredWorld phi` (Filtration.lean:158) is a quotient of
      `ClosureMCSBundle phi`, so the obligation reduces to exhibiting one closure MCS — i.e. a
      Lindenbaum-style extension over the closure of `phi`. **Locate the existing MCS-existence
      result and cite it; if none applies, prove it. Either way, no `sorry`.**
- [ ] If the proof turns out to require a hypothesis the filtration sites cannot supply (e.g. a
      consistency assumption on `phi`), **STOP and record a precise gap statement rather than
      weakening the frame or the field** — the same standard the retired blocker was held to. That
      is a genuine new blocker, and it is a blocker on 14.2 only; Phase 14.1 and Phase 15 are
      unaffected by it.
- [ ] Commit this proof green, on its own, before opening any window below.

*Sub-step 14.2.2 — `Nonempty WorldState`. Atomic window #1.*
- [ ] Decide and document the shape: a `nonempty : Nonempty WorldState` structure field, or an
      instance argument. Record the choice and its reason in the phase body and in the summary.
- [ ] Add it, and discharge it at all 14 sites per the inventory table above, adding the
      `[Nonempty W]` / `[Nonempty FamIdx]` binders those sites need and propagating each to its
      consumers.
- [ ] Commit once, green.

*Sub-step 14.2.3 — `[Nontrivial D]` as a structure binder. Atomic window #2.*
- [ ] Re-measure first: `grep -rn "TaskFrame" FormalSystem/ Tests/ --include=*.lean` excluding
      `Boneyard/` (575 mentions / 49 files on 2026-08-12; 578 / 49 on 2026-08-13). Record the
      observed count in the commit message.
- [ ] Add `[Nontrivial D]` to `structure TaskFrame`'s binder list (TaskFrame.lean:401 as read on
      2026-08-13 — confirm), and thread the instance through every declaration that mentions
      `TaskFrame D` at polymorphic `D`, including `FiniteTaskFrame` (TaskFrame.lean:1151), which
      `extends TaskFrame` and inherits the requirement.
- [ ] Note that `valid` and `SemanticConsequence` in `FormalSystem/Semantics/Validity.lean`
      already carry `[Nontrivial D]`, so the gap is specifically at the structure level; those
      sites should need no change beyond possibly becoming redundant. Record any that do.
- [ ] Commit once, green.

*Sub-step 14.2.4 — prose.*
- [ ] Correct the two remaining entries in `TaskFrame.lean`'s "Known gaps relative to the paper"
      block — `Nonempty WorldState` and `[Nontrivial D]` — which Phase 14.1 deliberately left
      standing. After this phase the block should carry no gap that the structure now closes.

**Timing**: 4 hours

**Depends on**: 14.1

**Verification Tier**: full

**Commit Mode**: atomic-batch

Rationale for `atomic-batch`: both a structure binder and a structure field are red from the first
edit until the last site or consumer is fixed, exactly as in Phase 14.1. This phase declares
**two** windows in advance — 14.2.2 and 14.2.3 — plus one green pre-window sub-step (14.2.1) and
one green post-window sub-step (14.2.4). The two windows are independent of each other and may be
opened in either order; each is committed once, green. Declaring both here in advance satisfies the
anti-abuse guard against retroactively widening a batch.

**Sizing note (binding)**: this phase is deliberately allowed to close `[PARTIAL]` after one
window. If the second window cannot be opened and closed green in the same run, commit the first,
mark the phase `[PARTIAL]` with a note naming which window remains, and stop. **Do not hold an
un-committed green window open in order to finish both.** Neither window gates Phase 15, so a
`[PARTIAL]` here does not stall the acceptance criterion.

**Scope Hypothesis**: 14 live sites (the same inventory as Phase 14.1 — re-run the discovery grep,
do not carry it over). `[Nontrivial D]` propagation: 575 mentions / 49 files as measured
2026-08-12, 578 / 49 as re-measured 2026-08-13; re-run before editing and treat the delta as a
signal that other work has landed. `FilteredWorld` nonemptiness: asserted absent on 2026-08-13 on
the strength of a single `Finite` instance being the only hit — re-run the grep and confirm the
absence before writing a proof that may since have landed elsewhere.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` — the structure binder, the nonemptiness field, the two
  remaining known-gaps entries
- `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean` — the `FilteredWorld` nonemptiness
  proof
- the frame definitions taking new `[Nonempty …]` binders (`staticFrame`, `regionFrame`,
  `multiFamTaskFrameGen`, and `bundleFlowFrame`'s call into it) and their consumers
- every declaration mentioning `TaskFrame D` at polymorphic `D` — enumerated in-phase by the
  re-measurement, not listed here

**Constraints**:
- **NEVER `sorry` a site**, not even transiently inside either red window, and not to stand in for
  the `FilteredWorld` nonemptiness proof.
- **Do not touch the four axiom fields**, their discharges, or `forward_comp`. Phase 14.1 owns
  them; if one of them is wrong, that is a Phase 14.1 defect to fix there.
- No vacuous repair: a nonemptiness obligation discharged by narrowing a frame until nothing
  instantiates it is not a discharge.
- Do not settle caveat (b) unilaterally.
- No task-number citations in any Lean file. Lean v4.33.0-rc1, Mathlib pinned to tag v4.33.0-rc1.

**Verification**:
- `lake build` — green at the 14.2.1 commit, and green at each window's single commit
- `grep -rn "sorry" FormalSystem/ Tests/` shows no new occurrences relative to the pre-phase
  baseline
- `#print axioms` on the `FilteredWorld` nonemptiness proof and on every touched frame — no new
  axiom
- `example : Nonempty F.WorldState := …` (or the chosen shape's equivalent) elaborates for a
  representative site from each class in the inventory table
- `grep -n "known gap\|awaits consumption" FormalSystem/Semantics/TaskFrame.lean` returns nothing
  that refers to `Nonempty WorldState` or `[Nontrivial D]`
- The chosen `bundleFlowFrame` nonemptiness route, and the `FilteredWorld` proof's route, are both
  named in the summary

---

### Phase 15: Substitute the fields for step's explicit hypotheses (acceptance) [IN PROGRESS]

**Goal**: `step` and the chain around it consume `F.serial` / `F.interpolates` / `F.spherical`
instead of explicit hypothesis binders, discharging the Cross-Task Acceptance Criterion by
construction.

**Why this is a separate phase**: it is a green-to-green edit (the fields exist; `step` still
typechecks with explicit binders), it is the mechanical test that the fields were stated
definitionally, and it sizes cleanly on its own. It is nonetheless **part of the same deliverable**
as Phase 14.1 — Phase 14.1 is not "done" in any meaningful sense until this lands.

**This phase depends on Phase 14.1 ONLY.** Phase 14.2 (`[Nontrivial D]` structure binder,
`Nonempty WorldState`) gates nothing here: `step` consumes `F.serial`, `F.interpolates`, and
`F.spherical`, none of which mentions `Nontrivial` or nonemptiness. Do not wait for 14.2, and do
not let a `[PARTIAL]` 14.2 block this.

**Tasks**:
- [ ] Replace `step`'s explicit binders (`Step.lean:116`, currently
      `theorem step (F : TaskFrame D) (hSph : Spherical F.TaskRel) (hSer : Serial F.TaskRel) …`)
      with the field projections. The proof body at :125-131 already consumes `hSph`, `hSer`, and
      the interpolation hypothesis; the substitution is by definition, with **zero restatement**.
- [ ] Propagate to the rest of the chain where the same hypotheses are threaded: `constraint`
      (Constraint.lean:393), `fibers` (Admissible.lean:144), `admissible` (Admissible.lean:283),
      `isTotal_of_isMax` (Extension.lean:157), `extension` (Extension.lean:187), `occurrence`
      (Extension.lean:237), `hF_nonempty` (Extension.lean:253) — updating call sites in step.
- [ ] Where a lemma is genuinely more useful over a bare relation than over a frame (the
      three recorded Props are all bare-relation by design), keep the bare-relation statement
      and pass `F.serial` etc. at the call site rather than rewriting the lemma. Record which
      declarations were converted and which were left bare, and why.
- [ ] Record the consuming declaration name(s) in the implementation summary — the acceptance
      criterion is "demonstrably consumed", not "typechecks".
- [ ] Update `Step.lean:39` and `Extension.lean:63`, which describe the explicit-binder
      arrangement as the provisional pre-field state.

**Timing**: 1 hour

**Depends on**: 14.1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Seven chain declarations take these hypotheses explicitly today
(`constraint`, `fibers`, `admissible`, `step`, `isTotal_of_isMax`, `extension`, `occurrence`,
`hF_nonempty` — re-count with `grep -rn "hSph\|hSer\|hInt\|hLim" FormalSystem/Semantics/Extension/`).
Line numbers are plan-time hypotheses from 2026-08-12; confirm by reading.

**Files to modify**:
- `FormalSystem/Semantics/Extension/Step.lean`
- `FormalSystem/Semantics/Extension/Constraint.lean`
- `FormalSystem/Semantics/Extension/Admissible.lean`
- `FormalSystem/Semantics/Extension/Extension.lean`
- call sites of the above, as the substitution requires

**Constraints**:
- No restatement of any Prop; no weakening of any statement to make a substitution go through.
- **NEVER `sorry` a site.** If a substitution does not go through, the field was restated rather
  than cited — fix the field in Phase 14.1, do not bridge the gap here.
- Do not depend on, or wait for, Phase 14.2.
- No task-number citations. No new axiom.

**Verification**:
- `lake build` — green
- `#print axioms` on `step`, `extension`, `occurrence`, `hF_nonempty` — no new axiom
- The `spherical` field appears in the proof term of the `lem:step` counterpart (inspect and record
  the consuming declaration name in the summary)
- `grep -n "sorry"` on every touched file returns nothing

---

## Testing & Validation

- [ ] `lake build` green after every sub-step commit in Phases 10-13, 14.1.1, 14.2.1, 14.2.4 and
      15, and after each declared atomic-batch commit (14.1.2, 14.2.2, 14.2.3)
- [ ] `grep -rn "sorry" FormalSystem/ Tests/` shows no new occurrences relative to the pre-plan
      baseline — at NO point, including inside any of the three red windows, is a `sorry` committed
- [ ] `#print axioms` on every new definition/theorem — only the standard Lean axioms
- [ ] `example : Serial F.TaskRel := F.serial`, and the `Interpolates` / `Spherical` analogues,
      elaborate by `rfl` (the definitional-content check)
- [ ] `step` (and the chain) consume the fields; the consuming declaration is named in the summary
- [ ] `Nonempty (FilteredWorld phi)` exists as a proved, sorry-free declaration (Phase 14.2), and
      its route is named in the summary — it was absent from the tree when this plan was written
- [ ] Phase 14.1 and Phase 14.2 landed as separate commits with separate red windows; no commit
      contains both a four-axiom field addition and a structure-binder/nonemptiness change
- [ ] `bash scripts/check-paper-definitions.sh` still exits 0 silent (no anchor drift)
- [ ] `grep -rn "possible_worlds.tex:[0-9]" FormalSystem/ --include=*.lean` still returns nothing
- [ ] `grep -rn "Limit Nullity" FormalSystem/ --include=*.lean` still returns nothing
- [ ] No docstring in `FormalSystem/Semantics/TaskFrame.lean` still describes *Seriality*, *Limit*,
      *Spherical*, or the interpolation direction as absent
- [ ] No task-number citation in any changed file outside `specs/**`
      (`bash .claude/scripts/check-task-references.sh` if available, else grep the diff)
- [ ] `git status` shows no stray edits outside the phases' declared file sets

## Artifacts & Outputs

- `specs/420_align_task_frame_with_positive_cone_axioms/plans/04_axiom-fields-split-batch.md`
  (this file)
- `specs/420_align_task_frame_with_positive_cone_axioms/summaries/04_axiom-fields-split-batch-summary.md`
  (on completion)
- `FormalSystem/Semantics/TaskFrame.lean` — class helpers and per-site lemmas (Phase 10); the four
  axiom fields, per-site binders, and four-axiom docstring corrections (Phase 14.1); the
  `[Nontrivial D]` structure binder, the nonemptiness field, and the remaining docstring
  corrections (Phase 14.2)
- `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean` — additionally, the `FilteredWorld`
  nonemptiness proof (Phase 14.2)
- `FormalSystem/Examples/TemporalStructures.lean` — per-site lemmas (Phase 11)
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean`,
  `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` — per-site lemmas
  (Phase 12)
- `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean`,
  `FormalSystem/Metalogic/Decidability/FMP/FiniteModel.lean`,
  `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` — caveat (a) resolution
  (Phase 13)
- `FormalSystem/Semantics/Extension/{Step,Constraint,Admissible,Extension}.lean` — field
  substitution (Phase 15)
- `Tests/BimodalTest/Semantics/TaskFrameTest.lean` — `customFrame` lemmas and discharge

**Deferred, recorded for follow-up (do not implement here)**:
- The `nullity_identity` design decision (caveat (b)) and the `PartialHistory`/`WorldHistory`
  nonemptiness layering — joint with the consequence-refactor scope
- The `lem:constraint`/`lem:fibers`/`lem:admissible`/`lem:step`/`thm:extension`/`cor:occurrence`
  chain's own further development beyond the Phase-15 substitution
- The cone-topology T1 result (`exists_uniform_radius_of_finite` is the sanctioned substitute)
- `typst/chapters/02-semantics.typ:37` (stale Nullity) and `typst/SYNC-MAP.md:230` (pre-refactor
  range)
- Collapsing the duplicated frame bodies into thin wrappers
- `FormalSystem/Metalogic/Soundness.lean:95` and `FormalSystem/Semantics/Truth.lean:46` — the two
  residual paper locators Phase 9 deliberately skipped, the latter being substantive
  `def:BL-semantics` work

## Rollback/Contingency

- Phases 10-13 are pure additions plus grep-gated binder changes, each committed per green
  sub-step; any one reverts independently without touching the structure. **They are landed and
  committed; nothing in this plan reverts them.**
- Sub-step 14.1.1's per-site binder propagation is committed per green sub-step and reverts one
  frame at a time without touching any field.
- Phase 14.1's batch (sub-step 14.1.2) is one objective. On a failed batch, revert to the last
  green 14.1.1 commit (Phases 10-13 and the binder propagation intact) and re-enter only after the
  missing lemma is landed by its owning phase. The snapshot-then-rollback ladder applies
  (`bash .claude/scripts/git-snapshot.sh 420` before any destructive recovery). **Never close the
  window with a `sorry`, a placeholder axiom, or a weakened field statement.**
- Phase 14.2's two windows revert independently of each other and of Phase 14.1 — neither the
  structure binder nor the nonemptiness field is referenced by the four axiom fields or by
  Phase 15. Sub-step 14.2.1's `FilteredWorld` nonemptiness proof is a pure addition and survives
  any rollback of either window.
- **If Phase 14.2 stalls, the task is not stalled.** Its correct terminus in that case is a
  `[PARTIAL]` phase with a named remaining window, not a `[BLOCKED]` task.
- Phase 15 reverts to explicit hypothesis binders, which is the current landed state — a failure
  there is a signal that a Phase-14.1 field was restated rather than cited, and the correct fix is
  to fix the field, not to keep the binders.
- If Phase 13 finds that neither restriction nor re-carriering discharges a filtration site without
  breaking a live consumer, STOP with a precise gap statement and re-revise. That is a genuine new
  blocker and should be recorded as one — with the same standard of evidence this revision applied
  when retiring the last one.
- **Terminal state**: with Phases 10-13, 14.1, 15, and 14.2 green and committed, the task's
  terminus is `[COMPLETED]`. There is no longer any external wait; a `[BLOCKED]` terminus would now
  be a misreport unless sub-step 14.2.1's `FilteredWorld` nonemptiness proof produces a genuinely
  new, recorded blocker — and that one would block Phase 14.2 alone, not the task.
- **The `phase-14-mis-sized` blocker is RETIRED by this revision**, and retired as *resolved by
  re-planning*, not as stale: the measurements that raised it are preserved verbatim in
  `#### SIZING FINDING` and are the reason the split exists. It named no blocking task
  (`blocked_on_task: null`), so nothing external was ever waited on. **Do not re-add the
  `420 -> 415` `dependencies[]` edge** — the 2026-08-10 cycle-breaking decision stands unchanged.
