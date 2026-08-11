# Implementation Plan: Task #415

- **Task**: 415 - Completeness over total-history semantics — internalized, not bridged
- **Status**: [NOT STARTED]
- **Effort**: 13.5 hours
- **Dependencies**: 438 (completed); 414 (not_started — gates Phases 5-7 only); 420 phase 10 (gates Phase 8 only)
- **Research Inputs**: specs/415_completeness_over_total_history_semantics/reports/02_total-history-internalization.md
- **Artifacts**: plans/02_total-history-completeness.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Restate and reprove weak completeness per frame class so the canonical/chronicle constructions
deliver countermodels that are total-history models outright: the countermodel family is the full
total-history set H_F (paper anchor `def:world-history`: "A world history is *total* ---
equivalently, a *possible world* --- just in case X = D. ... The set of all total world histories
over F is denoted H_F"), with the box clause per `def:BL-semantics` ("M,tau,x |= Box phi *iff*
M,sigma,x |= phi for all sigma in H_F") and no transfer or realization lemma in any final
statement. The plan is explicitly partitioned into a **414-independent tranche (Phases 1-4,
executable now)** and a **414-gated tranche (Phases 5-7)**, plus a 420-phase-10 handshake
(Phase 8). Phase 3 (dense re-host under the current Omega signature, report section 6.2
Option A) is the **420-phase-10-unblocking milestone**: 420's phase 10 is `[BLOCKED]` on exactly
this task's `bundleFlowFrame` and its live-path replacement of `ParametricCanonicalTaskFrame`.

### Research Integration

From report 02 (supersedes report 01 in full except its re-confirmed SURVIVES items):

- The totality reframing replaces round 1's maximality machinery entirely: no
  `Preorder (WorldHistory F)`, no `IsMax`, no Zorn, no `[Nonempty FamIdx]` fence. The workhorse
  is `multiFamGen_total_eq` (every total history of the deterministic flow frame is a flow
  line), statable and provable today against the current `WorldHistory` structure
  (`FormalSystem/Semantics/WorldHistory.lean:94-123`).
- The D-generic flow frame `multiFamTaskFrameGen`/`multiFamHistoryGen` already exists on disk
  (`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean:139-200`);
  `bundleFlowFrame` is an instantiation plus a valuation.
- All four `def:frame` axioms discharge generically: Limit via the on-disk
  `TaskFrame.limit_of_shift` (`FormalSystem/Semantics/TaskFrame.lean:330`) with
  `pos := Prod.snd` and `[Nontrivial D]`; Spherical via a new ~10-line
  directed-family-of-nonempty-subsingletons `sInter` helper; biconditional Compositionality via
  the unique intermediate `(w.1, w.2 + x)`; Seriality via the clock. The segment identity
  `w ⇒_{x+y} v ↔ [w,v]_x^y ≠ ∅` is a 3-line DERIVED lemma (comp-iff + `converse` + `mem_Seg`) —
  it may no longer be cited to the paper.
- The dense truth-lemma re-host fully replaces the Limit-violating
  `ParametricCanonicalTaskFrame` on live paths (two independent kill-shots: junk-histories
  refutation under Omega-free semantics; genuine Limit failure over dense D — repair in place is
  impossible).
- Sole live sorry: `Transfer.lean:1242` (`countermodel_discrete` Base branch) — **restate-only
  under this task; closure belongs to task 169**.
- The Limit-violating-witness audit closed clean — no additional rebase surface.
- Tasks 170 (Dense) and 408 (Dedekind) no longer exist in state.json: those legs are owned by
  this plan's own phases (6 and 7), with no external coordination partner.

### Prior Plan Reference

No prior plan exists for this task (plans/ directory was empty). Round-1 research
(report 01) is superseded; its SURVIVES items (staging Discrete → Dense → Base → Dedekind;
internalize-don't-bridge; deterministic lead frame) are carried forward via report 02.

### Roadmap Alignment

No ROADMAP.md found (not provided in delegation context; roadmap_flag not set).

## Goals & Non-Goals

**Goals**:
- Generic four-axiom conformance layer (`comp_iff`/`serial`/`limit`/`spherical`) + totality
  characterization for `multiFamTaskFrameGen`, proved once and transported to ℤ/ℚ/ℝ instances.
- `bundleFlowFrame`/`bundleFlowHistory`/`bundleFlowModel` as the bundle-index instantiation;
  dense truth-lemma re-host off `ParametricCanonicalTaskFrame` on all live paths (Option A:
  under the current Omega signature, now — the 420-phase-10-unblocking milestone).
- Deletion of the dead singleton-Omega device (`Transfer.lean:568-687`) and, if consumer checks
  confirm, the superseded parametric modules.
- Post-414: Omega-free restatement of the Discrete/Dense/Base/Dedekind countermodels, headliners,
  and consequence layer, with the box case destructured via totality (`τ.IsTotal`-shaped per
  414's actual spelling).
- Restate `countermodel_discrete` (Base discrete branch) Omega-free/totality-shaped, still
  sorried.

**Non-Goals**:
- Closing the `Transfer.lean:1242` sorry (task 169's Base-frame-class programme — restate only).
- Editing anything under `/home/benjamin/Philosophy/Papers/` (paper is read-only ground truth).
- Weakening any frame axiom to make a construction go through.
- Defining the Omega-free `TruthAt`/`valid`/`SemanticConsequence` API (task 414 owns
  `Semantics/Truth.lean`, `Semantics/Validity.lean`, and the soundness propagation).
- Adding the Seriality/Limit/Spherical/interpolation fields to the `TaskFrame` structure (420
  phase 10 executes that; Phase 8 here only confirms and consumes it).
- Proving the Zorn extension chain (`lem:constraint` → `lem:step` → `thm:extension` →
  `cor:occurrence`) for arbitrary frames — 415's flow frames bypass it constructively
  (`multiFamHistoryGen f (w - x)` puts `(f, w)` at time `x` outright).

## Paper Definitions of Record (binding citations)

All by `\label`/`\aitem` anchor against `specs/paper-definitions-of-record.md` (lint case (b)
pass at research time); run `bash scripts/check-paper-definitions.sh` at the start of every
implementation dispatch and STOP on a case (c) FAIL.

- **`def:frame`** — "A *frame* is any F = ⟨W, D, ⇒⟩ where W is a nonempty set of world states,
  D is a temporal order, and ⇒ is a task relation satisfying the following for x, y ≥ 0":
  - **`def:frame#Compositionality`** — "$w \Rightarrow_{x + y} v$ if and only if
    $w \Rightarrow_x u$ and $u \Rightarrow_y v$ for some $u \in W$" (a biconditional; the `→`
    interpolation direction is a NEW obligation beyond the on-disk `forward_comp`).
  - **`def:frame#Seriality`** — "$w \Rightarrow_x u$ and $v \Rightarrow_x w$ for some
    $u, v \in W$".
  - **`def:frame#Limit`** — "$\bigcap\limits_{x > 0} (w)_x = \set{w}$".
  - **`def:frame#Spherical`** — "$\bigcap \mathcal{S} \neq \emptyset$ for any directed family
    $\mathcal{S}$ of nonempty fibers and segments".
- **`def:task-relation`** — Fiber "$\Fib(w, x) \coloneq \set{u \in W : w \Rightarrow_x u}$";
  Cone "$(w)_x \coloneq \bigcup_{|y| < x} \Fib(w, y)$ where $x > 0$"; Segment
  "$[w, v]_x^y \coloneq \Fib(w, x) \cap \Fib(v, -y)$ where $x, y \geq 0$" (bracket form only;
  `\Seg` is retired).
- **`def:directed`** — "A nonempty family of sets $\mathcal{S}$ is *directed* just in case
  $S \subseteq S_1 \cap S_2$ for some $S \in \mathcal{S}$ whenever $S_1, S_2 \in \mathcal{S}$."
- **`def:world-history`** — partial history (nonempty domain, no convexity) → world history
  (convex domain) → "A world history is *total* --- equivalently, a *possible world* --- just in
  case X = D. ... The set of all total world histories over F is denoted H_F."
- **`def:BL-semantics`** box clause — "$\M,\tau,x \vDash \Box \varphi$ *iff*
  $\M,\sigma,x \vDash \varphi$ for all $\sigma \in H_{\F}$." Atom clause (no dom conjunct):
  "$\M,\tau,x \vDash p_i$ *iff* $\tau(x) \in |p_i|$."
- **`def:logical-consequence`** — "for all models M, possible worlds τ ∈ H_F, and times
  x ∈ D ..."; **`def:frame-validity`** — the frame-relative analogue.

The segment identity `w ⇒_{x+y} v ↔ [w,v]_x^y ≠ ∅` no longer appears as paper text: it MUST be
derived in Lean (Phase 1), never cited to the paper. A bare `possible_worlds.tex:NNNN` locator
is never a citation.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `WorldHistory.mk` equality bookkeeping in `multiFamGen_total_eq` (funext/propext across dependent `states` field) | M | L | Two in-repo precedents: `multiFamHistoryGen_shift_eq` (ChronicleMonadicBridge.lean:180-188), `multiFamHistory_shift_eq` (ReynoldsBridge.lean:698) — use the `change WorldHistory.mk ...; congr 1` pattern verbatim |
| 414 interface drift (subtype vs. predicate for totality) changes packaging-existential shape in Phases 5-7 | H | M | Coordinate the spelling — recommend `def WorldHistory.IsTotal (τ : WorldHistory F) : Prop := ∀ t, τ.domain t` — with task 414 BEFORE Phase 5 starts; Phase 5's preconditions require reading the actual on-disk spelling from `Semantics/Truth.lean`/`Validity.lean` and substituting mechanically |
| Option-A double pass on the dense truth-lemma box case mistaken for churn | M | M | The second pass is pre-budgeted in Phase 6 (~20-40 lines per site, box case + packaging only); it is planned rework, not churn — recorded here so convergence policing does not flag it |
| An implementer silently starts a 414-gated phase before 414 lands | H | M | Phases 5-7 carry a MUST-NOT-START precondition with a concrete on-disk check (grep for the totality predicate in `Semantics/Truth.lean`); the gate is in the phase body, not only in this table |
| Deleting the dead singleton-Omega device or parametric modules breaks a hidden consumer | M | L | Scope Hypotheses on Phases 2 and 4: grep-verified zero-consumer confirmation before each deletion; full `lake build` after |
| 420 phase 10 lands mid-stream and changes the `TaskFrame` structure under Phases 3-7 | M | M | Phase 8 is the designated reconciliation point; coordinate via the orchestrator — 420's field addition is `exact`-discharge of Phase 1's theorems, so the conflict surface is small |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 5 | 2 (Phase 5 additionally externally gated on task 414) |
| 4 | 4, 8 | 3 (Phase 8 additionally externally gated on 420 phase 10) |
| 5 | 6 | 3, 5 |
| 6 | 7 | 6 |

Phases within the same wave can execute in parallel (subject to the external gates noted).
**External gates**: Phases 5, 6, 7 are gated on task 414 landing; Phase 8 is gated on task 420
phase 10 landing. Phases 1-4 are 414-independent and executable immediately.

---

### Phase 1: Generic flow-frame conformance + totality layer [NOT STARTED]

**Goal**: Prove, once and D-generically, the four `def:frame` axiom obligations, the derived
segment identity, and the totality characterization for `multiFamTaskFrameGen` — the layer every
later phase (and 420 phase 10) consumes.

**Tasks**:
- [ ] Run `bash scripts/check-paper-definitions.sh`; STOP on case (c)
- [ ] Create `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` (imports:
      `ChronicleMonadicBridge`, `TaskFrame`; wire into the library's import root)
- [ ] `sInter_nonempty_of_directed_subsingleton` — for any `W`: a `TaskFrame.DirectedFamily` of
      nonempty subsingleton sets has nonempty `⋂₀` (~10 lines; proof per report §4: pick
      `a ∈ s₀`, directedness + subsingleton elimination force `a ∈ s₁` for every `s₁ ∈ S`)
- [ ] `taskRel_add_iff_seg_nonempty` — DERIVED (never cited to the paper):
      `R w (x+y) v ↔ (TaskFrame.Seg R w v x y).Nonempty` from the comp biconditional +
      converse convention + `mem_Seg` (~3 lines)
- [ ] `multiFamGen_comp_iff` — biconditional Compositionality; `←` is the existing
      `forward_comp`, `→` interpolates via the unique intermediate `u := (w.1, w.2 + x)`
      (`abel`-level algebra; state the strong form holding for all x, y, project the sign-
      hypothesis field form)
- [ ] `multiFamGen_serial` — `u := (w.1, w.2 + x)`, `v := (w.1, w.2 - x)`
- [ ] `multiFamGen_limit` — `exact TaskFrame.limit_of_shift Prod.snd ...` with `hshift` from the
      relation's second conjunct, `hzero` from `nullity_identity`; requires `[Nontrivial D]`
- [ ] `multiFamGen_spherical` — every fiber `Fib R (f,a) x = {(f, a + x)}` is a singleton, every
      segment an intersection of fibers hence subsingleton; apply the sInter helper
- [ ] `multiFamGen_total_eq` — `(htot : ∀ t, σ.domain t) → ∃ f w₀, σ = multiFamHistoryGen f w₀`;
      states-field equality via the `change WorldHistory.mk ...; congr 1` precedent
      (`multiFamHistoryGen_shift_eq`)
- [ ] Zero sorries in the new module; docstrings cite paper anchors by `\label` only and MUST
      NOT reference task numbers (durable anchors only, per repo deliverable rules)

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: ~250-400 lines in one new module, per report §10 item 1. Confirm at
implementation time; if the module trends past ~500 lines, split the sInter helper + segment
identity into a separate commit-green sub-step rather than a new file.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` - new module (all theorems above)
- The library import root that must expose it (confirm exact file at implementation time)

**Verification**:
- `lake build` scoped to the new module green; `lean_diagnostic_messages` clean
- `grep -cw sorry` on the new file returns 0
- Statement shapes match report §8's target signatures

---

### Phase 2: bundleFlowFrame instantiation + dead-device deletion [NOT STARTED]

**Goal**: Deliver the dense/Dedekind carrier as the bundle-index instantiation of the generic
frame, and delete the dead singleton-Omega device.

**Tasks**:
- [ ] Define in `FlowFrame.lean` (or a sibling module; names per report §6.2):
      `noncomputable def bundleFlowFrame (B : BFMCS (fc := fc) D) : TaskFrame D :=
      multiFamTaskFrameGen D {fam : FMCS (fc := fc) D // fam ∈ B.families}`
- [ ] `bundleFlowHistory (fam) (w₀ : D) := multiFamHistoryGen fam w₀`
- [ ] `bundleFlowModel` with
      `valuation := fun w p => Formula.atom p ∈ w.1.val.mcs w.2`
- [ ] Instantiate the Phase 1 conformance + totality theorems at the bundle index (inheritance
      should be by `exact`/specialization — no new proof content)
- [ ] Verify the carrier satisfies 420 phase 10's Coordination Contract: `Index × D` with
      `pos : W → D` (= `Prod.snd`), `R w y u → pos u = pos w + y`
- [ ] Delete the dead singleton-Omega device `Transfer.lean:568-687`
      (`zIntervalTaskFrame`/`zIntervalOmega`/`zIntervalBox_transparent`/`z_interval_countermodel`)
      AFTER re-confirming zero consumers by grep

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: the singleton-Omega device has zero live consumers (round-1 grep,
re-confirmed by the report's Omega-mention survey). Confirm at implementation time with
`grep -rn "zInterval" FormalSystem/ Tests/` before deleting; if a consumer surfaces, restate the
consumer against `bundleFlowFrame` in this phase rather than retaining the device.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` - bundle instantiation
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` - delete lines ~568-687 (dead device)

**Verification**:
- `lake build` of the changed module plus enumerated dependents (`Transfer.lean` importers) green
- `grep -rn "zInterval" FormalSystem/ Tests/` returns nothing
- No change to the sole live sorry count (still exactly `Transfer.lean` `countermodel_discrete`)

---

### Phase 3: Dense truth-lemma re-host under Omega signature (420-unblocking milestone) [NOT STARTED]

**Goal**: Re-host the dense truth lemma onto `bundleFlowFrame` under the CURRENT Omega
signature (report §6.2 **Option A**, `Omega := multiFamOmegaGen ...`), replacing the
Limit-violating `ParametricCanonicalTaskFrame` at all three live-path exposure sites. This
phase's completion discharges 420 phase 10's gate — notify the orchestrator/420 on green.

**Tasks**:
- [ ] Re-host `fully_restricted_parametric_shifted_truth_lemma`
      (`RestrictedParametricTruthLemma.lean:286`) as `bundleFlow_truth_lemma` with `(fam, w₀)`
      replacing `timeShift (parametricToHistory fam) delta` (the flow history at offset w₀ IS
      the shifted history — the separate "shifted" formulation dissolves)
- [ ] Atom case: definitional MCS membership; imp/bot/untl/snce: FMCS temporal coherence
      (`forward_G`, restricted tc/buc/fuc — frame-independent, preserved verbatim); box case:
      `parametric_box_persistent` + `B.modal_forward`/`B.modal_backward` (`Bundle/BFMCS.lean:91`
      ff.) with Omega-destructuring against `multiFamOmegaGen`
- [ ] Re-point `Completeness.lean:143` (`countermodel_dense_enriched` witness) at
      `bundleFlowFrame` at `D := ℚ` using the unchanged chronicle suppliers
      (`Chronicle.cantorBfmcsDense`, `rootedCantorFmcsDense`,
      `cantor_bfmcs_dense_restricted_tc/buc/fuc`)
- [ ] Re-point `ChronicleToCountermodelBasic.lean:839` likewise
- [ ] Re-point the ℝ elaborations at `CompletenessDedekind.lean:78/81/86`
- [ ] Confirm `ParametricCanonicalTaskFrame` no longer appears on any live (non-Boneyard,
      non-superseded-module) path
- [ ] On green: record in the phase completion notes + handoff that 420 phase 10's gate is
      discharged (the orchestrator relays; do not edit 420's plan from this dispatch)

**Timing**: 2.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: atomic-batch — declared file set:
`FormalSystem/Metalogic/Algebraic/FlowFrame.lean` (or the truth-lemma sibling module),
`FormalSystem/Metalogic/BXCanonical/Completeness.lean`,
`FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`,
`FormalSystem/Metalogic/CompletenessDedekind.lean`. Intermediate per-file states are expected
red while the witness swaps land; one batch-level green commit.

**Scope Hypothesis**: exactly three live-path exposure sites (per 420 plan v2 phase 10 and
report §2); ~400-600 lines total across Phases 2-3. Confirm the site list at implementation
time with `grep -rn "ParametricCanonicalTaskFrame" FormalSystem/` before starting; any
additional live site found joins this phase's batch.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` (or sibling) - `bundleFlow_truth_lemma`
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean` - dense countermodel witness
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean` - re-point
- `FormalSystem/Metalogic/CompletenessDedekind.lean` - ℝ probes re-point

**Verification**:
- Full `lake build` green; sorry count unchanged (exactly 1, `Transfer.lean`)
- `grep -rn "ParametricCanonicalTaskFrame"` hits only Boneyard/superseded modules (cleaned in
  Phase 4)
- `countermodel_dense_enriched`, the Dedekind probes, and `ChronicleToCountermodelBasic`
  consumers all elaborate against `bundleFlowFrame`

---

### Phase 4: Superseded-parametric cleanup [NOT STARTED]

**Goal**: Remove (or confine to Boneyard) the parametric modules the re-host orphaned, so the
live tree has one dense countermodel engine.

**Tasks**:
- [ ] Enumerate remaining consumers of `ParametricCanonicalTaskFrame`
      (`ParametricCanonical.lean:207`), `ParametricHistory.lean`'s Omega definitions,
      `ParametricTruthLemma.lean`, and `ParametricCompleteness.lean`
- [ ] Delete each module (or module section) with zero live consumers; retain anything the
      restricted truth lemma's re-host still genuinely consumes
- [ ] Update module docstrings/imports accordingly (no task-number references in deliverables)

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: report §7 lists these as "possible post-re-host deletions (check at plan
time)" — the check is deferred to implementation time by design: run
`grep -rn "Parametric" FormalSystem/ --include=*.lean -l` and `lean_references` on each
candidate symbol; delete only zero-consumer modules. If most of the surface is still consumed,
this phase closes as `[COMPLETED WITH EXCLUSIONS]` with the evidence table.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/ParametricCanonical.lean` - delete or prune
- `FormalSystem/Metalogic/Algebraic/ParametricHistory.lean` - Omega definitions prune
- `FormalSystem/Metalogic/Algebraic/ParametricTruthLemma.lean` - delete if orphaned
- `FormalSystem/Metalogic/Algebraic/ParametricCompleteness.lean` - delete if orphaned

**Verification**:
- Full `lake build` green; sorry count unchanged
- Every deleted symbol grep-confirmed consumer-free before deletion

---

### Phase 5: Discrete rebase (ReynoldsBridge) [NOT STARTED]

**GATE — MUST NOT START until task 414 has landed.** Precondition check (perform on disk, do
not trust status alone): the Omega-free `TruthAt` and `valid` are present in
`FormalSystem/Semantics/Truth.lean` / `Validity.lean` (e.g.
`grep -n "IsTotal" FormalSystem/Semantics/Truth.lean FormalSystem/Semantics/Validity.lean`
returns hits, and `TruthAt` no longer takes an `Omega : Set (WorldHistory F)` parameter). If
the check fails, this phase (and 6, 7) must not be dispatched. **Coordination obligation
(before this phase)**: confirm 414's totality-predicate spelling — the recommendation to 414 is
`def WorldHistory.IsTotal (τ : WorldHistory F) : Prop := ∀ t, τ.domain t`; whatever 414
actually shipped, read it from disk and substitute mechanically into all Phase 5-7 statements.

**Goal**: `completeness_discrete` green Omega-free over the ℤ flow frame, box case destructured
via totality.

**Tasks**:
- [ ] Re-run `bash scripts/check-paper-definitions.sh`; STOP on case (c)
- [ ] Truth-correspondence induction (`ReynoldsBridge.lean:804-940`): box case ONLY — forward
      direction instantiates at `multiFamHistory f' (z-t)` using its definitional totality
      (in place of `∈ multiFamOmega`); reverse direction destructures an arbitrary total σ via
      the ℤ instance of `multiFamGen_total_eq` (certified as the definitional specialization of
      the generic frame by `ChronicleMonadicBridge`'s `_int` lemmas)
- [ ] Atom case: drop the dom conjunct (gone post-414). Temporal cases: untouched
- [ ] Packaging: drop `(Omega, ShiftClosed Omega, τ ∈ Omega)` for the witness's totality
      (414's spelling); `countermodel_discrete_reynolds_v2` per report §8 target signature
- [ ] `completeness_discrete : ValidDiscrete φ → Derivable FrameClass.Discrete [] φ` green
- [ ] Preserve verbatim the entire `TemporalTruth`-side Reynolds cone (mkSigFrom, KEquiv,
      truth_transfer, table_correctness, EF games, Kamp/Prior) — it is already Omega-free

**Timing**: 2 hours

**Depends on**: 1, 2 (internal); task 414 (external gate)

**Verification Tier**: full

**Commit Mode**: atomic-batch — declared file set:
`FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` plus the
`completeness_discrete` packaging site(s) it feeds (enumerate at dispatch:
`grep -rn "countermodel_discrete_reynolds_v2" FormalSystem/`). Statement-shape changes ripple
within the batch; one batch-level green commit.

**Scope Hypothesis**: only the box case (~lines 840-940), atom case, and packaging change; the
temporal cases and the Reynolds cone are untouched. Confirm by diff review at phase close —
edits outside those regions require justification in the phase notes.

**Files to modify**:
- `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` - box/atom/packaging
- Consumers of `countermodel_discrete_reynolds_v2` (enumerated at dispatch)

**Verification**:
- Full `lake build` green; sorry count unchanged (exactly 1)
- `completeness_discrete` statement mentions no `Omega`/`ShiftClosed`
- Reynolds cone diff-clean

---

### Phase 6: Dense + Base finalization [NOT STARTED]

**GATE — MUST NOT START until task 414 has landed** (same on-disk precondition check as
Phase 5).

**Goal**: The re-hosted dense truth lemma and the Base headliner restated Omega-free; the
sorried Base-discrete countermodel restated (still sorried).

**Tasks**:
- [ ] Box-case swap in `bundleFlow_truth_lemma`: totality-destructuring (via the bundle-index
      instance of `multiFamGen_total_eq`) in place of Omega-destructuring — this is the
      pre-budgeted Option-A second pass (~20-40 lines per site; planned rework, not churn)
- [ ] `countermodel_dense_enriched` restated per report §8:
      `∃ (F : TaskFrame ℚ) (TM : TaskModel F) (τ : WorldHistory F), τ.IsTotal ∧ ∃ t : ℚ, ¬TruthAt TM τ t φ`
      (spelling per 414)
- [ ] `completeness_dense : ValidDense φ → Derivable FrameClass.Dense [] φ` green
- [ ] `completeness : valid φ → Derivable FrameClass.Base [] φ` (`Completeness.lean:196` ff.):
      dense and mixed branches re-point at the re-hosted machinery; the three-way case-split
      proof theory (`neg_consistent_of_not_derivable`, `set_lindenbaum`,
      `mcs_mixed_case_absurd`, the ten-step Discrete derivation) untouched
- [ ] Restate `countermodel_discrete` (`Transfer.lean:1225-1242`) Omega-free/totality-shaped —
      **it remains `sorry`; do NOT attempt closure** (task 169's programme; keep the in-file
      route documentation at Transfer.lean:1234-1241)
- [ ] Headline docs in `Metalogic.lean` (or wherever the headliner docstrings live) updated to
      the total-history statements; no transfer/realization lemma named anywhere

**Timing**: 2 hours

**Depends on**: 3, 5 (internal); task 414 (external gate)

**Verification Tier**: full

**Commit Mode**: atomic-batch — declared file set: the truth-lemma module (`FlowFrame.lean` or
sibling), `FormalSystem/Metalogic/BXCanonical/Completeness.lean`,
`FormalSystem/Metalogic/WeakCanonical/Transfer.lean`, headline-doc file. One batch-level green
commit.

**Scope Hypothesis**: box case + packaging only in the truth lemma (~20-40 lines per site, per
report §6.2); confirm by diff review — larger rewrites indicate the Option-A re-host drifted and
must be flagged, not silently absorbed.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` (or sibling) - box-case swap
- `FormalSystem/Metalogic/BXCanonical/Completeness.lean` - headliners
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` - sorried restatement
- Headliner docstring site(s)

**Verification**:
- Full `lake build` green; sorry count exactly 1 (the restated `countermodel_discrete`)
- No `Omega`/`ShiftClosed` mention in any 415-owned final statement
- `grep -n "sorry" FormalSystem/Metalogic/WeakCanonical/Transfer.lean` shows exactly the one
  restated site

---

### Phase 7: Dedekind restatement [NOT STARTED]

**GATE — MUST NOT START until task 414 has landed** (same on-disk precondition check as
Phase 5).

**Goal**: The Dedekind consequence layer and engine statements restated over the flow
machinery, Omega-free.

**Tasks**:
- [ ] `StrongCompleteness.lean:274-308`: consequence definitions +
      `completeness_dedekind_of_engine` / `consequence_completeness_dedekind_of_engine`
      restated with the totality substitution
- [ ] `CompletenessDedekind.lean` ℝ probes (78/81/86, already re-pointed at `bundleFlowFrame`
      at `D := ℝ` in Phase 3): final Omega-free statement form
- [ ] `real_lub_of_bddAbove` untouched
- [ ] Note: no external task owns these files any more (Dense/Dedekind task-level owners were
      removed from state.json) — this phase owns them outright; no coordination partner exists

**Timing**: 1.5 hours

**Depends on**: 6 (internal); task 414 (external gate)

**Verification Tier**: full

**Commit Mode**: atomic-batch — declared file set:
`FormalSystem/Metalogic/StrongCompleteness.lean`,
`FormalSystem/Metalogic/CompletenessDedekind.lean`. One batch-level green commit.

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` - consequence + engine statements
- `FormalSystem/Metalogic/CompletenessDedekind.lean` - final probe form

**Verification**:
- Full `lake build` green; sorry count exactly 1
- No `Omega`/`ShiftClosed` mention in the Dedekind consequence layer

---

### Phase 8: Conformance-field handshake with 420 [NOT STARTED]

**GATE — MUST NOT START until 420 phase 10 has landed** (precondition check: the `TaskFrame`
structure in `FormalSystem/Semantics/TaskFrame.lean` carries the Seriality/Limit/Spherical/
interpolation fields beyond today's `nullity_identity`/`forward_comp`/`converse`). May run any
time after Phases 1-3, independent of the 414 gate.

**Goal**: 415's frames populate 420's new `TaskFrame` fields directly, discharging them by
`exact` from the Phase 1 theorems.

**Tasks**:
- [ ] Confirm each Phase 1 theorem discharges the corresponding new field at
      `multiFamTaskFrameGen` and `bundleFlowFrame` (per report §4 this is `exact`-mechanical:
      comp_iff/serial/spherical directly; limit via `limit_of_shift Prod.snd`)
- [ ] Adjust `multiFamTaskFrameGen`'s instantiation path (and `bundleFlowFrame`) to populate
      the fields directly rather than as external theorems
- [ ] Keep the standalone bare-relation theorems if other consumers exist; otherwise fold them
      into the field proofs

**Timing**: 1 hour

**Depends on**: 2, 3 (internal); 420 phase 10 (external gate)

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` - field population
- `FormalSystem/Metalogic/BXCanonical/Chronicle/ChronicleMonadicBridge.lean` - generic frame
  fields (coordinate with whatever 420 phase 10 already did there)

**Verification**:
- Full `lake build` green; sorry count exactly 1
- `bundleFlowFrame` elaborates against the four-axiom structure with no `sorry`ed field

---

## Testing & Validation

- [ ] `lake build` green at every phase close (the full gate set runs before every phase closes
      and before task completion, regardless of in-phase tier)
- [ ] Sorry inventory invariant: exactly 1 live sorry (`Transfer.lean` `countermodel_discrete`)
      at every phase close — strict `grep -rwn sorry FormalSystem/ --include=*.lean` excluding
      Boneyard and comment/docstring hits
- [ ] `bash scripts/check-paper-definitions.sh` at the start of every implementation dispatch;
      STOP on case (c)
- [ ] After Phase 3: `ParametricCanonicalTaskFrame` absent from all live paths; 420 phase 10
      gate discharge recorded in the handoff
- [ ] After Phases 5-7: no `Omega`/`ShiftClosed` mention in any 415-owned final statement
      (`completeness_discrete`, `completeness_dense`, `completeness`,
      `countermodel_dense_enriched`, `countermodel_discrete_reynolds_v2`,
      `completeness_dedekind_of_engine`, `consequence_completeness_dedekind_of_engine`)
- [ ] No transfer or realization lemma appears in any final statement
- [ ] No task-number references in any Lean deliverable (docstrings cite paper `\label` anchors
      and sibling module names only)

## Artifacts & Outputs

- `plans/02_total-history-completeness.md` (this file)
- `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` (new: generic conformance + totality layer,
  bundle instantiation, re-hosted truth lemma)
- Modified: `Transfer.lean`, `Completeness.lean`, `ChronicleToCountermodelBasic.lean`,
  `CompletenessDedekind.lean`, `StrongCompleteness.lean`, `ReynoldsBridge.lean`; deleted or
  pruned parametric modules
- `summaries/02_total-history-completeness-summary.md` (at implementation completion)

## Rollback/Contingency

- Every phase commits per its declared commit mode; atomic-batch phases produce one revertable
  commit each — `git revert` of the batch commit restores the prior green state.
- Before any intentional destructive rollback on a dirty tree, run
  `bash .claude/scripts/git-snapshot.sh 415` per git-workflow rules.
- If Phase 3's re-host stalls (truth lemma resists Option A under the Omega signature), the
  fallback is report §6.2 Option B: hold Phases 3-4 until 414 lands and do a single pass — the
  plan collapses to the same content with Phases 3 and 6 merged; record the decision in the
  handoff rather than weakening any axiom.
- If 414 lands mid-Phases-1-4, Phases 5-7's gates open early; no plan revision needed — the
  gate checks are on-disk, not calendar-based.
- If a deletion in Phase 2/4 breaks a hidden consumer, restore the deleted section from git and
  restate the consumer against `bundleFlowFrame` instead (documented in the phase's Scope
  Hypothesis).
