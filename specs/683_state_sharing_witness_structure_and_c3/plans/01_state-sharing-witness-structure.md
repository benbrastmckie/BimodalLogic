# Implementation Plan: Task #683

- **Task**: 683 - State-sharing witness structure and C3
- **Status**: [IMPLEMENTING]
- **Effort**: 23.5 hours
- **Dependencies**: 682
- **Research Inputs**: specs/683_state_sharing_witness_structure_and_c3/reports/01_state-sharing-witness-structure.md; specs/683_state_sharing_witness_structure_and_c3/handoffs/phase-6-handoff-20260927.md; specs/683_state_sharing_witness_structure_and_c3/.decisions.json (the (C5) scope decision)
- **Artifacts**: plans/01_state-sharing-witness-structure.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false
- **Revision**: round 1, revision 1 — (C5) `StabFaithful` dropped from scope per the recorded user decision; see "Revision 1" under Research Integration
- **Reports Integrated**: 01_state-sharing-witness-structure.md

## Overview

Add a state-sharing (branching) witness device alongside the existing deterministic bi-lasso
device, under a new `SharingWitnessFamily` structure that extends `WitnessFamily` with a
periodic, per-time equivalence on lasso indices (`share`). The branching device gets its own
frame (built directly as a `FrameOver intOrder`, not through `ShiftSet`), its own histories
characterization (`total_eq_thread`, replacing the determinism-only `ShiftSet.total_eq_orbit`),
its own coherence and fulfilment conditions, and its own producer for the existing
`WitnessFamily.Refutes` interface. The deterministic device is not modified anywhere: it is
recovered at the end as the `share u i j := i = j` instance, up to an explicit frame
isomorphism. Done when the sharing family's `Certifies` bundle is decidable, its
`refutes_of_certifies` twin type-checks, the deterministic specialization is proved, and the
repository builds sorry-free with the existing deterministic path byte-identical.

The stability clause (C5) is **not** part of this task. It cannot be stated over a
`Formula`-indexed certificate, and the user has decided to defer it (see Revision 1 below). What
this task delivers for it is the enabling artifact: a frame whose task relation genuinely
branches, so `PlusDeterminism.states_eq_of_deterministic` no longer collapses `⊡` to the
identity on it.

### Research Integration

Report `reports/01_state-sharing-witness-structure.md` is integrated in full, and three of its
findings materially reshape this plan away from the task description's literal wording:

- **(C3) `BoxFaithful` needs no redesign and is reused verbatim.** Its right-hand side
  (`∀ i t, χ ∈ W.L i t`) mentions only the label pool, and a recombined history's label at each
  position is drawn from that same pool, so recombination adds no new labels for `□` to range
  over. The task description's "redesigned box condition" and the consuming adequacy document's
  "redesigning condition (C3)" are both refuted by the Lean reading. The conditions that
  actually break are (C1) `LocalCoherentLab` and (C2) `FulfillingLab`, both stated per-lasso.
  This plan therefore spends its condition work in Phases 6-9, not on `BoxFaithful`.
- **No condition quantifies over walks, so the task description's "infinitely many walks"
  decidability worry does not arise where it is placed.** (C0), (C1') and (C5) are
  one-step/one-position conditions, finite by the existing periodic-window reduction. Only
  (C2') has new content, and it is a CTL-style `A[g U e]` least fixpoint on a *finite* periodic
  position graph.
- **No new frame-axiom work is needed.** Limit still comes from `TaskFrame.limit_of_succOrder`
  (needs only `R w 0 u → u = w`, not determinism); Saturation moves off
  `saturation_of_fib_subsingleton` onto the already-proved `saturation_of_fib_finite`, whose
  docstring names the infinite-carrier/finite-fibres case this construction is.

Two further report findings are carried as hard constraints: `ShiftSet.lean` must not be edited
(D2), and `share` must decode through `Periodic.unrollOf` with the same three-segment scheme as
the labels (D4), so `Decide.lean`'s window lemmas generalize by instantiation.

#### Revision 1 — (C5) `StabFaithful` dropped from scope

This revision integrates one finding that is not in the research report, because it only
surfaced when Phase 6 tried to elaborate the condition, plus the user decision that resolved it.

- **The finding.** (C5) is not stateable at the `WitnessFamily` datatype. That datatype is
  monomorphic in `FormalSystem.Syntax.Formula`, which has exactly six constructors (`atom`,
  `bot`, `imp`, `box`, `untl`, `snce`) and no `⊡`. The stability modal is `PlusFormula.stab`, a
  constructor of the **separate inductive** `FormalSystem.PlusLanguage.PlusFormula`
  (`PlusLanguage/Formula.lean` records the separate-inductive decision and the
  constructor-to-constructor embedding `ofFormula`). The two inductives share no supertype, so
  no instantiation, coercion or type-class route states (C5) over the existing certificate.
  This is a **type-level obstruction, not a proof difficulty**: the blocked `def` never
  elaborated. The research report's line 425 and the original plan's Lean Challenge block both
  missed it because (C5) was written as prose inside a `sorry`-bodied `def` whose statement was
  never checked. Treat that as a correction to the report, not as a disagreement with it: the
  report's *semantic* analysis of (C5) (its consistency with `stab_state_only`, its
  one-finite-`∀ j` decidability) is sound and remains the specification for the follow-up.
- **The decision.** The user chose to drop (C5), `StabFaithful` and the `⊡` case of the truth
  lemma from this task, keeping the branching frame as the deliverable that *unblocks* a
  stability modal, and to move the condition itself to a follow-up task. The alternative —
  re-indexing `LabelledLasso`, `closureOf`, `WitnessFamily`, its four conditions and its
  agreement theorem over `PlusFormula` — was rejected as too large here and because it re-opens
  the JSON export contract the model checker consumes.
- **What this revision changes.** Goals drop from sixteen pinned declarations to fifteen. Phase 6
  closes as `[COMPLETED WITH EXCLUSIONS]` with the record below rather than as `[PARTIAL]`.
  Phase 7 decides two conditions rather than three, Phase 10 loses the `⊡` truth case, Phase 11's
  `Certifies` bundle has five components rather than six, and Phase 12 loses one reduction
  lemma. Phases 1-5, 8, 9 and 13 are untouched. Effort drops from 25 to 23.5 hours.
- **What this revision does not change.** No completed phase is reopened. Phases 1-5 are
  committed and green; `Sharing/Predicates.lean`'s (C0) and (C1') are landed and stay. The
  deterministic path remains byte-identical, and `ShiftSet.lean` remains untouched.

### Prior Plan Reference

No prior plan. This is round 1 for this task.

### Roadmap Alignment

`roadmap_path` was not provided in the delegation context, so no roadmap consultation was
dispatched and no roadmap phases are included. `specs/ROADMAP.md` exists in the repository; a
grep of it for the terms this task turns on surfaced a related but distinct line
(`StarDeterminism.states_eq_of_deterministic` under item 13) and no item this plan advances
directly. Treat roadmap alignment as unassessed rather than as none.

## Goals & Non-Goals

**Goals**:
- `SharingWitnessFamily`
- `SharingWitnessFamily.share`
- `SharingWitnessFamily.Thread`
- `SharingWitnessFamily.frame`
- `SharingWitnessFamily.instIsRegular`
- `SharingWitnessFamily.total_eq_thread`
- `SharingWitnessFamily.AtomCoherent`
- `SharingWitnessFamily.LocalCoherentShare`
- `SharingWitnessFamily.ThreadFulfilling`
- `SharingWitnessFamily.Certifies`
- `SharingWitnessFamily.decidableCertifies`
- `SharingWitnessFamily.truth_iff_mem`
- `SharingWitnessFamily.refutes_of_certifies`
- `WitnessFamily.toSharing`
- `WitnessFamily.certifies_toSharing`

Beyond those fifteen pinned declarations the phases below also deliver supporting plumbing (the
periodic `share` decoding lemmas, the thread-graph fixpoint and its termination measure, the
frame isomorphism used by the specialization, and README updates). Those carry no pinned
statement and are therefore not listed as Goals identifiers.

**Non-Goals**:
- Any edit to `FormalSystem/Semantics/ShiftSet.lean`. It is in this task's declared `file_scope`
  but the shipped deterministic path depends on it and a sibling task also claims it. Cite
  `total_eq_orbit` by name, never by line number.
- Any change to the existing `WitnessFamily` conditions (C1)-(C4), to `WitnessFamily.std`, to
  `WitnessFamily.Certifies`, or to `WitnessFamily.refutes_of_certifies`. The deterministic path
  must remain byte-identical.
- Any change to the JSON export contract. `back`, `mid`, `fwd`, `bx`, `lassos` keep their names
  and positions; the sharing structure *extends* rather than edits.
- **(C5) `StabFaithful`, the stability clause, and the `⊡` case of the truth lemma.** Dropped by
  user decision after Phase 6 established that they are not stateable over a `Formula`-indexed
  certificate (see Revision 1). Two specific prohibitions follow, and they are the point of this
  entry: do **not** state `StabFaithful` at `Formula` with a vacuous or `True`-valued body, and
  do **not** weaken it to a `box`-shaped clause. Both would type-check and certify nothing. The
  condition belongs to a follow-up task that introduces an L⁺-indexed certificate datatype.
- Any L⁺-indexed (`PlusFormula`-indexed) certificate datatype. Re-indexing `LabelledLasso`,
  `closureOf`, `WitnessFamily`, its four conditions and its agreement theorem over `PlusFormula`
  is the follow-up task's subject, not this one's; it also re-opens the JSON export contract.
- The A1 compression theorem. The consuming repository records it as open with a named route;
  it is a separate line of work.
- Re-litigating `Probe476.fmp_false`. It is cited, accurately, as the refutation of the
  *time-free finite digraph* small-model hypothesis, and explicitly not as an obstruction to
  this design (its pigeonhole step has no analogue once the time coordinate stays in the
  carrier).
- Any `sorry`, any new axiom, and `native_decide` in any form. If a phase does not close, mark
  the task `[BLOCKED]` for user review.
- Any edit inside `~/Projects/ModelChecker`. Consequences for the consuming repository are
  recorded as a hand-off in Phase 14, never performed here.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An implementer follows the task description literally, rewrites `BoxFaithful`, and leaves (C1)/(C2) per-lasso — producing an unsound certificate that still type-checks | H | M | The Research Integration section states the correction in this plan's own words; Phases 6-9 are the (C1')/(C2') work and Phase 11 reuses (C3) unchanged by name |
| `ShiftSet.lean` edited, regressing the shipped deterministic path | H | M | Declared a Non-Goal; Phase 3 builds a `FrameOver` directly. Phase 14's gate re-checks `git diff` is empty for that file |
| Phase 8/9's fixpoint overruns and invites a `sorry` | H | M | Split across two phases (graph+fixpoint, then correctness); `BiLasso/GoodCycle.lean`'s shrinking-`Finset` cardinality measure is the template; escalate to `[BLOCKED]` rather than defer |
| The frame isomorphism in Phase 13 is assumed definitional and the phase stalls | M | H | The two frames are a `Quotient` of `Fin L × ℤ` and `Fin L × ℤ` respectively — isomorphic, not definitionally equal. Budget the transport via `Semantics/TruthTransport.lean` and `HistoryMorphism.lean`; do not plan on `rfl` |
| Atom coherence (C0) is missed because `Predicates.lean`'s header says atoms are "deliberately unconstrained" | H | M | Phase 6 makes it the first deliverable. The tell is that the agreement theorem's `atom` case stops being `Iff.rfl` once the valuation reads a class rather than a pair |
| `share` encoded as a bare function, losing the window reduction and hence decidability | H | M | Phase 1 fixes the periodic three-segment encoding as a hard acceptance criterion; Phase 7 cannot close without it |
| The `SuccOrder`/`IsSuccArchimedean` instance for the new frame fails to elaborate under `haveI` | M | H | `WitnessFamily/Std.lean`'s header records the `@`-with-four-`inferInstanceAs` idiom; Phase 4 copies it verbatim rather than re-deriving |
| Task-number citations leak into `FormalSystem/**` | M | M | Cite durable anchors only (`total_eq_orbit`, `saturation_of_fib_finite`, `stab_iff_of_deterministic`, `Probe476.fmp_false`); the repo-wide lint covers this |
| The declared `file_scope` does not list the new `Sharing/` modules, so a snapshot or gate refuses | M | M | Phase 1's first task extends `file_scope` in `specs/state.json` (append-only, via the sanctioned helper) before any new file is created |
| A later implementer reinstates (C5) as a `Formula`-shaped clause with a vacuous or `box`-shaped body, producing a certificate that type-checks and certifies nothing about `⊡` | H | M | Named twice as a Non-Goal with both prohibited shapes spelled out; Phase 6's Reasoned Exclusions record carries the type-level reason; Phase 11's bundle pins the component count at five |
| The (C5) deferral is read as "the branching device does not help the stability modal", and the follow-up is never opened | M | M | Phase 14 adds a `Sharing/README.md` section stating what the branching frame does deliver for `⊡` (its task relation is not functional, so `states_eq_of_deterministic` does not apply) and what the follow-up needs |
| Estimates here are agent-run budgets, not the research report's 3-6 week human wall-clock figure | L | H | Stated openly; each phase is sized to one agent run producing roughly 100-500 lines, and phase count absorbs the total rather than phase length |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 6 | 1 |
| 3 | 3, 7, 8 | 2, 6 |
| 4 | 4, 9 | 3, 8 |
| 5 | 5 | 4 |
| 6 | 10 | 5, 6 |
| 7 | 11 | 7, 9, 10 |
| 8 | 12 | 11 |
| 9 | 13 | 12 |
| 10 | 14 | 13 |

Phases within the same wave can execute in parallel.

### Phase 1: The `share` field and its periodic decoding [COMPLETED]

**Goal**: `SharingWitnessFamily` exists, extends `WitnessFamily` without touching the export
contract, and its `share` relation decodes through `Periodic.unrollOf` so the existing window
lemmas apply by instantiation.

**Tasks**:
- [x] Extend this task's `file_scope` in `specs/state.json` to cover the new
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/` modules. Append via `+=` or
      the sanctioned helper; never assign `.file_scope` or `.artifacts` wholesale.
- [x] Create `Sharing/Basic.lean` with `structure SharingWitnessFamily Γ Del extends
      WitnessFamily Γ Del`, adding exactly three periodic segments plus their two non-emptiness
      fields and one idempotence field.
- [x] Encode each segment as a **representative map** `Fin lassos.length → Fin lassos.length`
      rather than as a relation. `share u i j := rep u i = rep u j` is then an equivalence for
      free (it is the kernel of a function), which removes the `share_equiv` proof obligation
      the research report carried as a structure field. Record this choice and its rationale in
      the module docstring.
- [x] Define `SharingWitnessFamily.rep u := Periodic.unrollOf repBack repMid repFwd u` and
      `SharingWitnessFamily.share`, with `share_refl`, `share_symm`, `share_trans` proved
      directly from the kernel characterization.
- [x] Instantiate the two periodicity lemmas (`rep_sub_back_length`, `rep_add_fwd_length`) at
      this decoding, mirroring `LabelledLasso.lab_sub_back_length` / `lab_add_fwd_length`
      exactly. Do not re-prove `Periodic.unrollOf`'s arithmetic.
- [x] Add `Decidable (S.share u i j)` from `DecidableEq (Fin _)`.
- [x] Register `Sharing/Basic.lean` in `WitnessFamily.lean`'s import aggregator.

**Timing**: 2 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that exactly three new periodic segments (plus two
non-emptiness fields and one idempotence field) suffice, and that the two periodicity lemmas
generalize by instantiation with no new arithmetic. Confirm at implementation time by
type-checking `Sharing/Basic.lean` with the two lemma bodies copied from `Basic.lean`'s
`LabelledLasso` pair and adjusted only in their carrier; if either needs a genuinely new
argument, record that as a scope correction in the phase notes before proceeding.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Basic.lean` - new; the structure,
  `rep`, `share`, the equivalence laws, the two periodicities, the `Decidable` instance
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` - add the new import
- `specs/state.json` - extend `file_scope` (append-only)

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Basic` succeeds
- `bash .claude/scripts/lean-sorry-census.sh FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/` reports zero
- `git diff --stat FormalSystem/Metalogic/Decidability/WitnessFamily/Basic.lean` is empty
  (the export contract is untouched)

---

### Phase 2: `Thread` and its basic constructions [COMPLETED]

**Goal**: The branching analogue of "a lasso orbit" exists as a type, with the constructions the
frame's regularity discharges will need.

**Tasks**:
- [x] Create `Sharing/Thread.lean` with `structure SharingWitnessFamily.Thread` carrying
      `idx : ℤ → Fin S.lassos.length` and `step : ∀ u, S.share (u+1) (idx u) (idx (u+1))`.
- [x] Prove `Thread` is inhabited: every constant `fun _ => i` is a thread, by `share_refl`.
- [ ] Define thread time-shift (`Thread.shift θ d`) and prove it is a thread. *(deviation: skipped — `share` is decoded from periodic segments indexed by absolute time, so `share u` and `share (u+d)` are different relations and `fun u => θ.idx (u + d)` fails the step field; the time offset lives in the history's parametrization instead, as `total_eq_thread`'s explicit `s : ℤ`)*
- [x] Define finite thread segments (`ThreadSeg S a b`) and prove concatenation and splitting —
      these are precisely what the `Compositional` discharge in Phase 4 consumes. *(deviation: altered — delivered as the inductive `Step` / `ReachN` relations with `reachN_add` for concatenation and splitting, rather than as a function-on-an-interval structure; the relational form also gives the four share-congruences the quotient carrier needs and a `Decidable` instance the Phase 7/8 window work consumes)*
- [x] Prove `Thread.ext` (extensionality on `idx`) so downstream `refine ... ext` steps work.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Thread.lean` - new
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` - add the new import

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Thread` succeeds
- `#check @SharingWitnessFamily.Thread.shift` and the concat/split lemmas elaborate at their
  intended statements
- sorry census on `Sharing/` reports zero

---

### Phase 3: The branching frame [COMPLETED]

**Goal**: A `FrameOver intOrder` whose `WorldState` is the `share`-quotient of `Fin L × ℤ` and
whose `TaskRel` is "there is a thread segment of that length", with the two easy regularity
fields discharged.

**Tasks**:
- [x] Create `Sharing/Frame.lean`. Define the `Setoid` on `Fin L × ℤ` that identifies `(i,u)`
      with `(j,u)` exactly when `share u i j`, and **only within a single time** — `(i,u)` and
      `(i,u')` are never identified. Prove it is a `Setoid` from Phase 1's equivalence laws.
- [x] Define `SharingWitnessFamily.WorldState := Quotient (shareSetoid S)` and its `Nonempty`
      instance from `mainIdx`.
- [x] Define `SharingWitnessFamily.PosRel ⟦(i,u)⟧ d ⟦(j,v)⟧` as `v = u + d` together with the
      existence of a thread segment from `(i,u)` to `(j,v)`, and prove it well-defined on the
      quotient (this is the lift obligation the quotient carrier buys). *(deviation: altered — factored through a duration-free connectivity predicate `Conn` and one two-sided relation `RelZ`, with `PosRel` the restriction of `RelZ` to the positive cone; this makes the reflection law `conn_symm` plus `omega` rather than a sign case-split inside every constraint proof, and lets the four `TaskFrame.*_reflect_of_reflective` helpers be cited exactly as `ShiftSet.fibre_isRegular` does)*
- [x] Assemble `SharingWitnessFamily.frame : FrameOver intOrder`.
- [x] Discharge `comp` (thread concatenation and splitting, from Phase 2) and `serial` (every
      class continues, because each lasso continues) as standalone lemmas
      `frame_comp` / `frame_serial`.

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that the quotient lift for `PosRel` needs only the
per-time restriction of the setoid (no additional compatibility field on the structure). Confirm
by closing the well-definedness obligation without adding a structure field; if a field turns
out to be needed, it belongs in Phase 1's structure and this phase must say so explicitly rather
than adding it silently downstream.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Frame.lean` - new
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` - add the new import

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Frame` succeeds
- `#check SharingWitnessFamily.frame` shows `FrameOver intOrder`
- `frame_comp` and `frame_serial` type-check at `TaskFrame.Compositional` / `TaskFrame.Serial`
- sorry census on `Sharing/` reports zero

---

### Phase 4: `IsRegular` and the ℤ-time instances [COMPLETED]

**Goal**: The branching frame is a regular ℤ-time frame, with Limit and Saturation discharged by
the two existing lemmas the research report identified — no new frame-axiom argument.

**Tasks**:
- [x] Discharge `limit` via `TaskFrame.limit_of_succOrder`, which needs only `R w 0 u → u = w`.
      Prove that zero-shift law for `PosRel` (a length-zero thread segment is trivial) and apply.
- [x] Discharge `saturation` via `TaskFrame.saturation_of_fib_finite`. The obligation is finite
      *fibres* on an infinite carrier: at each time there are at most `lassos.length` classes.
      Prove the fibre-finiteness as a named lemma `frame_fib_finite` rather than inline. *(deviation: altered — named `relZ_fib_finite`, since it is stated at the two-sided relation `RelZ` rather than at the frame's reflected task relation)*
- [x] Assemble `instance SharingWitnessFamily.instIsRegular : S.frame.IsRegular` from
      `frame_comp`, `frame_serial`, `frame_limit`, `frame_saturation`.
- [x] Prove `frame_isZTime` using the `@TaskFrame.isZTime_of_instances` idiom with four explicit
      `inferInstanceAs` arguments, copied verbatim from `WitnessFamily/Std.lean` — `haveI`
      shadows the `SuccOrder` instance `IsSuccArchimedean` is indexed by and fails to elaborate.
- [x] Prove `frame_sat_ztime : FrameClass.ZTime.Sat S.frame.toTaskFrame`.

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that all four `IsRegular` fields close by direct
application of the four named existing lemmas with no new auxiliary theory. Confirm by checking
each discharge is a single application (plus bookkeeping); any field requiring a genuinely new
argument is a scope correction to record before continuing, and — per the research report's
framing — a signal that the design has drifted.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Frame.lean` - the four discharges,
  the `IsRegular` instance, and the two ℤ-time results

**Verification**:
- `lake build` of the `Sharing.Frame` module succeeds
- `example (S : SharingWitnessFamily Γ Del) : S.frame.IsRegular := inferInstance` elaborates
- `bash .claude/scripts/lean-sorry-census.sh` on `Sharing/` reports zero
- `#print axioms SharingWitnessFamily.frame_sat_ztime` shows no `sorryAx`

---

### Phase 5: `total_eq_thread` — the histories characterization [COMPLETED]

**Goal**: Replace the determinism-only `ShiftSet.total_eq_orbit` for the branching frame: every
world history of `S.frame` is the trace of a thread.

**Tasks**:
- [x] Create `Sharing/Histories.lean`.
- [x] State `total_eq_thread : ∀ σ : WorldHistory S.frame.toTaskFrame, ∃ θ : S.Thread, ∃ s : ℤ,
      ∀ t, σ.state t = ⟦(θ.idx (s + t), s + t)⟧`.
- [x] Extract, from `σ.respects_task`, a one-step `share` link at each `u`; note that unlike
      `total_eq_orbit` this is **not** a consequence of `respects_task 0` alone.
- [x] Build the thread by two-directional recursion over `ℤ` (forward from the base point by
      `Int.rec`-style induction on `Nat`, backward dually), then glue. Isolate the forward and
      backward halves as separate lemmas so neither proof grows past a screen. *(deviation: altered — no recursion or gluing was needed. The index at each time is read off the **step witness** supplied by the frame's one-step relation at that time, which is an independent choice per time (`choose`), and the thread's step law then follows from transitivity of `share` at the later time. The plan's recursion budget assumed the index had to be chosen before the step was known.)*
- [x] Prove the converse direction (`thread_is_history`): every thread's trace is a world
      history, which is what the truth lemma in Phase 10 consumes for `□`.
- [x] Record in the module docstring that `share u i j := (i = j)` collapses `Thread` to a
      constant function, so `Thread ≃ Fin L` and this statement degenerates to `total_eq_orbit`'s
      content — the durable anchor for the specialization in Phase 12.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Histories.lean` - new
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` - add the new import

**Verification**:
- `total_eq_thread` and `thread_is_history` type-check at their pinned statements
- `lake build` of the module succeeds
- sorry census on `Sharing/` reports zero
- `#print axioms SharingWitnessFamily.total_eq_thread` shows no `sorryAx`

---

### Phase 6: The new and revised conditions, as definitions [COMPLETED WITH EXCLUSIONS]

**Goal**: (C0) atom coherence and (C1') cross-step local coherence exist as `Prop`s; (C3) and
(C4) are reused by name, unchanged. (C5), the stability clause, was the third deliverable when
this phase was written and is excluded — see the record below.

**Tasks**:
- [x] Create `Sharing/Predicates.lean`.
- [x] Define `AtomCoherent S : Prop := ∀ u i j, S.share u i j → ∀ p,
      (Formula.atom p ∈ S.L i u ↔ Formula.atom p ∈ S.L j u)`. Document why this is mandatory and
      new: the class-level valuation reads a `share`-class, not a pair, so the agreement
      theorem's `atom` case stops being `Iff.rfl`. `Predicates.lean`'s "atoms are deliberately
      unconstrained" header remains true of the deterministic device and false here.
- [x] Define `LocalCoherentShare S : Prop` as (C1) with the `untl` clause taken **across**
      `share (t+1)`-linked pairs and the `snce` clause dually across `share t`. The `bot`, `imp`
      and `box` clauses are carried over unchanged.
- ~~Define `StabFaithful S : Prop := ∀ φ ..., ⊡φ ∈ S.L i u ↔ ∀ j, S.share u i j → φ ∈ S.L j u`,
      and prove the immediate corollary `share u i j → (⊡φ ∈ L i u ↔ ⊡φ ∈ L j u)`.~~ **Excluded**
      — see Reasoned Exclusions below.
- [x] Add a docstring section stating plainly that `BoxFaithful` (C3) is **reused verbatim** and
      why: its right-hand side mentions only the label pool, which recombination does not
      enlarge. Name this as a correction to the consuming adequacy document's claim, per the
      research report's decision D1.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| (C5) `SharingWitnessFamily.StabFaithful`, the stability clause | Not stateable at this datatype, and the obstruction is type-level rather than a proof difficulty. `WitnessFamily` is indexed by `Context = List Formula`, its labels are `Finset Formula`, and its closure is `closureOf : List Formula → Finset Formula`. `Formula` has exactly six constructors (`atom`, `bot`, `imp`, `box`, `untl`, `snce`) — there is no `⊡` to write. The stability modal is `PlusFormula.stab` on the separate inductive `FormalSystem.PlusLanguage.PlusFormula`, and the two inductives share no supertype, so no instantiation, coercion or type-class route states (C5) over the existing certificate. Stating it requires an L⁺-indexed certificate datatype, which also re-opens the JSON export contract. The user decided to drop it here and move it to a follow-up task. | `FormalSystem/Syntax/Formula.lean` — `Formula`, six constructors, no `stab`. `FormalSystem/PlusLanguage/Formula.lean` — `PlusFormula.stab`, the separate-inductive decision, and the `ofFormula` embedding. The attempted `def` never elaborated; by contrast `Sharing/Predicates.lean` builds sorry-free with (C0) and (C1') landed, full `lake build` green (2746 jobs, exit 0), sorry census zero, `#print axioms` on every landed Goal exactly `[propext, Classical.choice, Quot.sound]`. User decision recorded in `.decisions.json` (`dispatch_seq` 3, `blocking: true`, answered by user). |
| The `stab_state_only` consistency corollary | Consumes `StabFaithful`; falls with the row above. Its content is preserved as the follow-up's specification: the research report establishes that `share u` being an equivalence makes (C5) consistent with `stab_state_only` by construction, with `Metalogic/Conservativity/Plus/Atomization.lean` as the transfer route. | `reports/01_state-sharing-witness-structure.md`, the `stab_state_only` discussion; `FormalSystem/PlusLanguage/PlusTruth.lean`'s `stab` clause of `PlusTruthAt`. |

The exclusions are confined to (C5). Phases 7, 8 and 9 never depended on it. Phases 10, 11 and 12
each carried one `StabFaithful` deliverable, and this revision removes exactly those three
deliverables from those phases — they are not deferred within this plan, they are out of scope.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean` - new
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` - add the new import

**Verification**:
- The two new `Prop`s elaborate; `#check` each
- `grep -n "BoxFaithful" Sharing/Predicates.lean` shows it referenced, never redefined
- `grep -n "StabFaithful" Sharing/Predicates.lean` finds nothing (the exclusion is real, not a
  stub)
- sorry census reports zero

---

### Phase 7: Decidability of (C0) and (C1') by the window reduction [COMPLETED]

**Goal**: The two one-position/one-step conditions are decidable, reusing
`Decide.lean`'s existing window machinery rather than a new reduction.

**Tasks**:
- [x] Create `Sharing/Decide.lean`.
- [x] Define the combined window for a sharing family: the label window
      `[-2·nb, nm + 2·nf)` intersected with the `share` segments' own period, so both decodings
      are periodic across it. Prove the combined-window analogue of `coherent_iff_window`.
      *(landed as `perBack`/`perFwd`/`perMid`, `cohWindowLo`/`cohWindowHi` and
      `exists_window_repr`; see the Scope Hypothesis confirmation below for the one correction
      to the window's shape)*
- [x] Prove `atomCoherent_iff_window` and `localCoherentShare_iff_window` off that lemma. (A
      third sibling, `stabFaithful_iff_window`, was planned; (C5) is out of scope — see Phase 6's
      Reasoned Exclusions — so it is not part of this phase.)
- [x] Derive `Decidable` instances for the two conditions by `decidable_of_iff` through the
      window statements, with the inner `∀ j : Fin lassos.length` discharged by `Fintype`.
      *(landed as `decidableAtomCoherent` and `decidableLocalCoherentShare`)*
- [x] Confirm by `#check` that `decidableBoxFaithful`, `instDecidableMemAll`,
      `instDecidableBoxClause` and `decidableTarget` apply to a sharing family's underlying
      `toWitnessFamily` unchanged. *(confirmed by `example … := inferInstance` rather than
      `#check`, which is a strictly stronger check — `#check` on an instance name would
      elaborate the constant, not the synthesis at a sharing family)*

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that the combined window is the label window widened
only by the `share` period, and that four of the fifteen existing `Decidable` instances are
reusable as-is. Confirm at implementation time by (a) closing the combined-window lemma without
a new periodicity argument and (b) `#check`ing those four instances at a sharing family; record
the actual reusable count in the phase notes if it differs from four.

#### Scope Hypothesis: confirmed with two corrections

(a) **Confirmed.** `exists_window_repr` closes with no new periodicity argument. The two
representative-map congruences (`rep_congr_back`, `rep_congr_fwd`) are instantiations of two
new but purely generic `Periodic.unrollOf` lemmas (`unrollOf_congr_back`, `unrollOf_congr_fwd`),
each a two-line composition of the existing `unrollOf_neg`/`unrollOf_fwd` with the existing
`cyc_congr`; the label congruences are `LabelledLasso.lab_congr_back`/`lab_congr_fwd` reused
verbatim.

**Correction 1 — the window's shape.** "The label window widened only by the `share` period" is
right in direction and wrong in detail. Because both sharing conditions compare *two different
lassos* at the same time (`AtomCoherent` reads `L i u` against `L j u`; (C1')'s temporal clauses
read `L i t` against `L j (t ± 1)`), `Decide.lean`'s per-lasso decomposition
(`localCoherentLab_iff_lassos`) is unavailable and the different lassos' windows must be
reconciled with *each other*, not only with the `share` period. The window is therefore built
from a family-wide common multiple: `perBack = |repBack| · ∏ᵢ |backᵢ|`,
`perFwd = |repFwd| · ∏ᵢ |fwdᵢ|`, `perMid = |repMid| + Σᵢ |midᵢ|`, and the window is
`[-2·perBack, perMid + 2·perFwd)`. A common multiple rather than a least common multiple:
nothing needs minimality, and `List.dvd_prod` gives the divisibility facts off the shelf.

**Correction 2 — a closure gate the plan did not anticipate.** (C0) as stated in Phase 6
quantifies over `∀ p : Atom`, and `FormalSystem.Syntax.Atom` is `Infinite`
(`Syntax/Atom.lean`'s `instance : Infinite Atom`), so the condition is not decidable in the
shape it is written. It *is* decidable, because every label is a subset of
`closureOf (Γ ++ Del)`: an atom outside the closure is absent from both sides. `atomClauseAt`
is the closure-member form and `atomCoherent_iff_at` the equivalence. This is the same device
`labClauseAt`/`boxClause` already use in `Decide.lean` for the deterministic conditions, so it
is a reuse rather than a new technique — but it is an extra lemma the phase did not budget.
(C0) itself is unchanged in `Sharing/Predicates.lean`; the gate lives only in the reduction.

(b) **Confirmed, and the count is seven, not four.** `decidableBoxFaithful`,
`instDecidableMemAll`, `instDecidableBoxClause` and `decidableTarget` all synthesize at
`S.toWitnessFamily`, and so do `decidableLocalCoherentLab`, `decidableFulfillingLab` and
`decidableCertifies` — nothing in `Decide.lean` reads the sharing datum, so every instance it
exports is inherited. The confirmation is nine `example … := inferInstance` lines in the
`Inherited` section at the foot of `Sharing/Decide.lean` (the seven inherited ones plus this
phase's two new ones), which is stronger than `#check` on the instance names: it exercises
instance *synthesis* at a `SharingWitnessFamily`, not merely the constants' existence.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Decide.lean` - new
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` - add the new import

**Verification**:
- `example (S : SharingWitnessFamily Γ Del) : Decidable (AtomCoherent S) := inferInstance` and
  its `LocalCoherentShare` sibling elaborate
- `lake build` of the module succeeds
- sorry census reports zero

---

### Phase 8: The finite position graph and the `A[g U e]` fixpoint [COMPLETED]

**Goal**: The computational core of (C2'): a finite graph over periodic positions, and a
terminating least-fixpoint computation of "every thread from here delivers `e` with `g`
throughout".

**Tasks**:
- [x] Create `Sharing/Fulfil.lean`.
- [x] Define the position graph: vertices `(i, u)` for `i : Fin lassos.length` and `u` in the
      combined window from Phase 7; edges `(i,u) → (j,u+1)` when `share (u+1) i j`, with window
      wraparound handled by the periodicity lemmas. Establish `Fintype` on the vertex set.
      *(landed as `Pos`, `winTimes`, `verts`, `nextTime`/`prevTime` and `succF`/`predF`; the
      wraps are discharged by `rep_nextTime`, `L_nextTime`, `rep_prevTime`, `L_prevTime`, all
      instantiations of Phase 7's `data_congr_fwd`/`data_congr_back`. `Fintype` is on the
      coercion of `verts`, not on `Pos` — see the representation note below)*
- [x] Define the `A[g U e]` operator as a monotone map on `Finset Vertex` and iterate it with a
      fuel bound equal to the vertex count. *(landed as `AUFix.step`, `AUFix.step_mono`,
      `AUFix.iter` and `AUFix.lfp`; the fuel is `|V| + 1`, not `|V|` — see below)*
- [x] Prove termination/stabilization: the "not yet known to fulfil" `Finset` strictly shrinks
      at each non-fixed iteration, so well-founded recursion on its cardinality closes. Use
      `BiLasso/GoodCycle.lean`'s single-cycle measure as the template; do not invent a new one.
      *(landed as `AUFix.exists_stab`, `AUFix.iter_stab`, `AUFix.lfp_fixed`, `AUFix.lfp_least`,
      with `AUFix.lfp_induction` added as the soundness tool Phase 9 consumes)*
- [x] Define the dual computation for `snce` on the reversed graph, as an instance of the same
      operator rather than a copied proof. *(landed as `snceFix := AUFix.lfp verts predF …`,
      differing from `untlFix` in the successor function alone)*

#### Representation note: `Fintype` lives on `verts`, not on `Pos`

`Pos S := Fin |lassos| × ℤ` is not a `Fintype` and cannot be made one: its time coordinate is
`ℤ`, and keeping the time coordinate in the carrier is exactly the feature that makes
`Probe476.fmp_false`'s pigeonhole step inapplicable to this design (the research report's
reading, and the plan's own Non-Goal on re-litigating it). Finiteness therefore lives on the
`Finset` `verts`, the graph is carried as a `Finset`-valued successor function, and the
`Fintype` the task asks for is `Fintype {v : S.Pos // v ∈ S.verts}`, confirmed by an
`example … := inferInstance` beside `mem_verts`. This is a representation choice, not a
weakening: every lemma the fixpoint needs is stated relative to `verts`.

**Timing**: 2 hours

**Depends on**: 2, 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the fixpoint terminates within a fuel bound equal to
the vertex count, and that the `snce` dual is an instantiation rather than a second proof.
Confirm by closing termination with the cardinality measure and by the dual being defined
through the same operator; if the dual needs its own proof, say so explicitly and re-budget
Phase 9 rather than absorbing it silently.

#### Scope Hypothesis: confirmed, with the fuel bound off by one

**Termination: confirmed, by the cardinality measure.** `AUFix.exists_stab` is the pigeonhole:
the iteration is increasing (`iter_succ_mono`, from `step_mono`) and confined to `V`
(`iter_subset`), so an index at which it is not yet fixed strictly increases its cardinality;
`|V| + 1` such indices would force `(iter (|V| + 1)).card ≥ |V| + 1 > |V|`. This is
`BiLasso/GoodCycle.lean`'s measure read in the growing rather than the shrinking direction —
`V \ iter n` strictly shrinks exactly when `iter n` strictly grows — and no well-founded
recursion was needed, because the bound is a plain `∃ n ≤ V.card` and `lfp` is the iteration
evaluated at a constant index. No new measure was invented.

**Correction — the fuel is `|V| + 1`, not `|V|`.** The chain starts at index `0` with `∅`, so
`|V|` distinct growth steps land at index `|V|`, and index `|V| + 1` is the first index
guaranteed to repeat its predecessor. `AUFix.lfp` is therefore `iter (V.card + 1)`, and
`lfp_fixed` is proved by pushing the stabilization out to indices `|V| + 1` and `|V| + 2`. The
off-by-one is recorded rather than silently absorbed.

**The `snce` dual: confirmed as an instantiation.** `snceFix S g e = AUFix.lfp S.verts S.predF
(S.atPos e) (S.atPos g)` — the same `lfp` with `predF` for `succF`. Every fixpoint lemma
(`lfp_subset`, `lfp_fixed`, `lfp_least`, `mem_lfp_iff`, `lfp_induction`) is stated at an
arbitrary successor function and specialises to both directions; `mem_snceFix_iff` and
`snceFix_induction` are two-line specialisations, not second proofs. Phase 9 does **not** need
re-budgeting on this account.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean` - new
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` - add the new import

**Verification**:
- The operator, its monotonicity, and the stabilization lemma type-check *(done:
  `AUFix.step`, `AUFix.step_mono`, `AUFix.exists_stab`, `AUFix.lfp_fixed`)*
- `#eval` of the fixpoint on a small hand-built example terminates and gives the expected set
  *(done as three `#guard`s in `Sharing/Fulfil.lean`'s `SmokeTest` section, which check the
  computed answer rather than only printing it: on the one-lasso family with
  `back = [∅]`, `mid = [{p}]`, `fwd = [∅]` and identity representatives the window is `[-2, 4)`,
  `untlFix p p` is the single position at time `-1`, and `snceFix p p` its mirror at time `1`.
  The answers being singletons rather than `∅` or the whole window is the non-vacuity content)*
- sorry census reports zero *(0 across the resolved source roots)*

---

### Phase 9: (C2') `ThreadFulfilling` and its correctness [NOT STARTED]

**Goal**: The semantic condition "every thread through `(i,u)` fulfils `untl g e`" is defined,
proved equivalent to Phase 8's fixpoint, and thereby decidable.

**Tasks**:
- [ ] Define `ThreadFulfilling S : Prop` in `Sharing/Predicates.lean`: for every `i`, `u`, `g`,
      `e` with `untl g e ∈ S.L i u`, **every** thread `θ` with `θ.idx u = i` has some `s > u`
      with `e ∈ S.L (θ.idx s) s` and `g ∈ S.L (θ.idx r) r` for all `u < r < s`; dually for `snce`.
- [ ] Prove soundness: a vertex in the fixpoint implies the semantic property (induction on the
      iteration index, transporting along threads).
- [ ] Prove completeness: a vertex outside the fixpoint admits a counterexample thread. This is
      the direction that needs the periodicity lemmas — the finite escape path is pumped into a
      bi-infinite thread, which is legitimate here because the *time* coordinate is carried, so
      no position is skipped. Note in the docstring that this is exactly where
      `Probe476.fmp_false`'s pigeonhole step has no analogue.
- [ ] Derive `Decidable (ThreadFulfilling S)` by `decidable_of_iff` through the fixpoint.

**Timing**: 2 hours

**Depends on**: 8

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean` - the definition
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean` - the two directions
  and the `Decidable` instance

**Verification**:
- `example (S : SharingWitnessFamily Γ Del) : Decidable (ThreadFulfilling S) := inferInstance`
  elaborates
- Both directions type-check at their stated forms
- `#print axioms` on the correctness lemma shows no `sorryAx`
- sorry census reports zero

---

### Phase 10: `forward_repr` and the truth lemma for the sharing family [NOT STARTED]

**Goal**: Labels are truth in the branching presented model — the branching twin of
`ShiftSet.forward_repr` and `WitnessFamily.truth_iff_mem`, with the `box` case grounded in
`total_eq_thread` rather than `total_eq_orbit`.

**Tasks**:
- [ ] Create `Sharing/Agreement.lean`.
- [ ] Define the branching `TaskModel` on `S.frame`, with the valuation lifted to the quotient —
      well-defined precisely by (C0) `AtomCoherent`. This is where the deterministic device's
      `Iff.rfl` atom case is replaced by a `Quotient.lift` argument.
- [ ] Prove the branching `forward_repr`: the `box` case quantifies over all world histories,
      which `total_eq_thread` turns into a quantification over threads and, by the class-level
      surjectivity analogue of `sh_surj`, over all `(i,u)` positions.
- [ ] Prove `truth_iff_mem` for the sharing family by induction on the formula, using
      `LocalCoherentShare` for the one-step temporal cases, `ThreadFulfilling` for the
      eventualities, and **`BoxFaithful` unchanged** for `□`. The induction is over
      `FormalSystem.Syntax.Formula`'s six constructors and is therefore complete as stated;
      there is no `⊡` case to prove, because `Formula` has no `⊡`.
- [ ] Record in the module docstring what the branching frame delivers for the stability modal
      even though (C5) is out of scope here: the frame's task relation is not functional, so
      `PlusDeterminism.states_eq_of_deterministic` does not apply to it and
      `stab_iff_of_deterministic`'s `⊡φ ↔ φ` collapse does not hold. That is the sense in which
      the deterministic device is blind to `⊡` **by construction** — not merely incomplete for
      it, so it cannot be extended by adding a truth clause — and the sense in which this frame
      unblocks the follow-up. Cite both lemmas by name; state plainly that the corresponding
      truth clause is future work on an L⁺-indexed certificate.

**Timing**: 1.5 hours

**Depends on**: 5, 6

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Agreement.lean` - new
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` - add the new import

**Verification**:
- `truth_iff_mem` type-checks at its pinned statement
- `grep -n "BoxFaithful" Sharing/Agreement.lean` confirms the existing (C3) is applied, not
  restated
- `grep -n "StabFaithful" Sharing/Agreement.lean` finds nothing outside the docstring
- `#print axioms SharingWitnessFamily.truth_iff_mem` shows no `sorryAx`
- sorry census reports zero

---

### Phase 11: `Certifies`, its `Decidable` instance, and the `Refutes` producer [NOT STARTED]

**Goal**: A second producer for the unchanged `WitnessFamily.Refutes` interface, decidable
end-to-end.

**Tasks**:
- [ ] Bundle `SharingWitnessFamily.Certifies S t` as the conjunction of exactly five components —
      `AtomCoherent`, `LocalCoherentShare`, `ThreadFulfilling`, `BoxFaithful` (reused) and
      `Target` (reused) — in a fixed projection order matching the instance evaluation order. A
      sixth, `StabFaithful`, was planned and is out of scope; see Phase 6's Reasoned Exclusions.
- [ ] Derive `decidableCertifies` from the five component instances.
- [ ] Prove `joint_countermodel`'s branching twin and then
      `refutes_of_certifies : S.Certifies t → WitnessFamily.Refutes Γ Del`, landing in the
      **same** `Refutes` (`Agreement.lean`'s existential over frames is what makes this possible
      with no change to the deterministic producer).
- [ ] Add a module docstring stating the coexistence mechanism explicitly: `Refutes`
      existentially quantifies the frame, so the two devices are two producers for one
      interface, and `WitnessFamily.refutes_of_certifies` is untouched.

**Timing**: 1.5 hours

**Depends on**: 7, 9, 10

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the bundle has exactly five components (three carried
over or adapted, two new). Confirm by the `decidableCertifies` derivation closing with exactly
that many component instances; adjust the count in the docstring if the definition settles
differently. Five, not six: the planned `StabFaithful` component is out of scope.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Agreement.lean` - the bundle and
  the producer
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Decide.lean` - `decidableCertifies`

**Verification**:
- `example (S : SharingWitnessFamily Γ Del) (t : ℤ) : Decidable (S.Certifies t) := inferInstance`
  elaborates
- `#check @SharingWitnessFamily.refutes_of_certifies` shows the `WitnessFamily.Refutes` codomain
- `git diff --stat FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean` is empty
- Full `lake build` succeeds

---

### Phase 12: `toSharing` and the condition reductions [NOT STARTED]

**Goal**: The deterministic device is exhibited as the `share u i j := i = j` instance, with each
new condition proved to reduce to its existing counterpart.

**Tasks**:
- [ ] Create `Sharing/Specialize.lean`. Define `WitnessFamily.toSharing W` with the three `share`
      segments set to singleton lists of `id`, so `share u i j ↔ i = j`.
- [ ] Prove `share_toSharing : (W.toSharing).share u i j ↔ i = j`.
- [ ] Prove `AtomCoherent (W.toSharing)` unconditionally (it degenerates to `i = j → ...`),
      recording that this is why the existing device could leave atoms unconstrained.
- [ ] Prove `LocalCoherentShare (W.toSharing) ↔ LocalCoherentLab W`.
- [ ] Prove `ThreadFulfilling (W.toSharing) ↔ FulfillingLab W`, using the fact that a thread in
      `W.toSharing` is a constant function.
- [ ] Assemble `certifies_toSharing : W.Certifies t → (W.toSharing).Certifies t` from the four
      reductions above. (A fifth, `StabFaithful (W.toSharing)` as the `⊡φ ↔ φ` collapse, was
      planned; (C5) is out of scope — see Phase 6's Reasoned Exclusions. Record
      `states_eq_of_deterministic` / `stab_iff_of_deterministic` in the module docstring instead,
      as the semantic statement of why the diagonal instance would collapse `⊡`.)

**Timing**: 1.5 hours

**Depends on**: 11

**Verification Tier**: local

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Specialize.lean` - new
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` - add the new import

**Verification**:
- All four reduction lemmas and `certifies_toSharing` type-check
- `#print axioms WitnessFamily.certifies_toSharing` shows no `sorryAx`
- sorry census reports zero

---

### Phase 13: The frame isomorphism and truth transport [NOT STARTED]

**Goal**: `(W.toSharing).frame` and `W.std.frame` are shown isomorphic and truth is transported
across, so the deterministic case is a genuine specialization rather than a parallel development.

**Tasks**:
- [ ] Construct the frame isomorphism `(W.toSharing).frame ≅ W.std.frame`. The carriers are
      `Quotient (shareSetoid (W.toSharing))` and `Fin L × ℤ`; the quotient is by equality, so the
      map is `Quotient.lift id` with `Quotient.mk` as inverse. **These are isomorphic, not
      definitionally equal — do not plan on `rfl`.**
- [ ] Transport truth across it using `Semantics/HistoryMorphism.lean` and
      `Semantics/TruthTransport.lean`; state the transported agreement as
      `truth_iff_mem_toSharing`.
- [ ] Prove the specialization corollary: the branching `refutes_of_certifies` applied at
      `W.toSharing` yields the same `Refutes Γ Del` as `WitnessFamily.refutes_of_certifies`
      applied at `W`, so nothing about the deterministic acceptance branch changes.
- [ ] Record the transport cost in the module docstring so a future reader does not try to
      collapse it.

**Timing**: 2 hours

**Depends on**: 12

**Verification Tier**: interface

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Specialize.lean` - the isomorphism,
  the transport, the corollary

**Verification**:
- The isomorphism and `truth_iff_mem_toSharing` type-check
- The specialization corollary type-checks
- Full `lake build` succeeds
- `#print axioms` on the corollary shows no `sorryAx`

---

### Phase 14: Documentation, corrections, and the final gate [NOT STARTED]

**Goal**: The design decisions and the two corrections to the received account are recorded in
durable, in-repo documentation, and the whole change is verified against the full gate set.

**Tasks**:
- [ ] Update `WitnessFamily/README.md`: add the `Sharing/` submodule map, and state that (C3)
      `BoxFaithful` is recombination-stable because its right-hand side mentions only the label
      set — an explicit correction to the consuming adequacy document's "redesigning condition
      (C3)".
- [ ] Add `Sharing/README.md` covering the `share` encoding decision (representative maps, so
      the equivalence laws are free), the thread characterization, and the (C2') fixpoint.
- [ ] Update `BiLasso/README.md` only where it asserts that all histories are lasso orbits, to
      scope that claim to the deterministic device.
- [ ] Record `Probe476.fmp_false` accurately in `Sharing/README.md`: it refutes a finite
      small-model property for *time-free* finite digraphs; its pigeonhole step has no analogue
      here because the time coordinate stays in the carrier. Do not cite it as an obstruction to
      this design.
- [ ] Record the (C5) status in `Sharing/README.md` in its own section, in three parts: (a) the
      stability clause is **not** part of this device, and why — `WitnessFamily` is indexed by
      `Formula`, which has six constructors and no `⊡`, while the modal is `PlusFormula.stab` on
      a separate inductive; (b) what this device nonetheless delivers for it — a non-functional
      task relation, so `states_eq_of_deterministic` does not apply and
      `stab_iff_of_deterministic`'s collapse does not hold; (c) what a follow-up needs — an
      L⁺-indexed certificate datatype (`LabelledLasso`, `closureOf`, `WitnessFamily`, its
      conditions and its agreement theorem re-indexed over `PlusFormula`), which also re-opens
      the JSON export contract. Cite durable anchors only; no task numbers.
- [ ] Record the consuming-repository hand-off (what the model checker would need to emit to use
      a sharing certificate) as prose in `Sharing/README.md`. Do not edit that repository.
- [ ] Run the full gate set and confirm the deterministic path is untouched.

**Timing**: 1 hour

**Depends on**: 13

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` - submodule map, (C3) correction
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` - new
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` - scope the all-histories claim

**Verification**:
- `lake build` succeeds from clean
- `bash .claude/scripts/lean-sorry-census.sh` over the Lean source roots reports zero new sorries
- `bash .claude/scripts/check-task-references.sh` passes (no task numbers under `FormalSystem/**`)
- `git diff --stat FormalSystem/Semantics/ShiftSet.lean FormalSystem/Metalogic/Decidability/WitnessFamily/{Basic,Predicates,Std,Agreement,Decide}.lean`
  shows no content change to the deterministic path beyond added imports
- `#print axioms` on each of the fifteen pinned Goal identifiers shows no `sorryAx`

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.WitnessFamily.Agreement
import FormalSystem.Metalogic.Decidability.WitnessFamily.Decide

open FormalSystem.Syntax FormalSystem.Semantics

namespace FormalSystem.Metalogic.Decidability

/--
A witness family extended by a periodic, per-time equivalence on lasso indices, encoded as a
representative map so the equivalence laws come for free as the kernel of a function.

The parent's five fields (`back`, `mid`, `fwd`, `bx`, `lassos`) are an export contract and are
inherited, not re-declared.
-/
structure SharingWitnessFamily (Gam Del : FormalSystem.Syntax.Context)
    extends WitnessFamily Gam Del where
  /-- Representative maps for the leftward cycle. -/
  repBack : List (Fin toWitnessFamily.lassos.length → Fin toWitnessFamily.lassos.length)
  /-- Representative maps for the finite window. -/
  repMid : List (Fin toWitnessFamily.lassos.length → Fin toWitnessFamily.lassos.length)
  /-- Representative maps for the rightward cycle. -/
  repFwd : List (Fin toWitnessFamily.lassos.length → Fin toWitnessFamily.lassos.length)
  /-- The leftward cycle is non-empty, so leftward decoding is periodic. -/
  repBack_ne : repBack ≠ []
  /-- The rightward cycle is non-empty, so rightward decoding is periodic. -/
  repFwd_ne : repFwd ≠ []
  /-- Every listed map is idempotent, so it is a choice of class representatives. -/
  rep_idem : ∀ f ∈ repBack ++ repMid ++ repFwd, ∀ i, f (f i) = f i

variable {Gam Del : FormalSystem.Syntax.Context}

/-- Two lasso indices name the same world state at time `u`. -/
def SharingWitnessFamily.share (S : SharingWitnessFamily Gam Del) (u : ℤ)
    (i j : Fin S.lassos.length) : Prop := sorry

/-- A bi-infinite choice of lasso index, stepping only across shared states. -/
structure SharingWitnessFamily.Thread (S : SharingWitnessFamily Gam Del) where
  /-- The index held at each time. -/
  idx : ℤ → Fin S.lassos.length
  /-- Consecutive indices name the same world state at the later time. -/
  step : ∀ u : ℤ, S.share (u + 1) (idx u) (idx (u + 1))

/-- The branching frame: world states are `share`-classes of index/time pairs. -/
def SharingWitnessFamily.frame (S : SharingWitnessFamily Gam Del) :
    FrameOver intOrder := sorry

/-- The branching frame is regular. -/
instance SharingWitnessFamily.instIsRegular (S : SharingWitnessFamily Gam Del) :
    S.frame.IsRegular := sorry

/-- **The histories characterization.** Every world history of the branching frame is the trace
of a thread. This replaces `ShiftSet.total_eq_orbit`, which holds only because the deterministic
device's task relation is functional. -/
theorem SharingWitnessFamily.total_eq_thread (S : SharingWitnessFamily Gam Del)
    (sigma : WorldHistory S.frame.toTaskFrame) :
    ∃ theta : S.Thread, ∃ s : ℤ,
      ∀ t : ℤ, sigma.state t = Quotient.mk (SharingWitnessFamily.shareSetoid S)
        (theta.idx (s + t), s + t) := sorry

/-- (C0) Atoms agree across shared states, so the class-level valuation is well defined. -/
def SharingWitnessFamily.AtomCoherent (S : SharingWitnessFamily Gam Del) : Prop := sorry

/-- (C1') Local coherence with the one-step clauses taken across `share`-linked index pairs. -/
def SharingWitnessFamily.LocalCoherentShare (S : SharingWitnessFamily Gam Del) : Prop := sorry

/-- (C2') Every thread through a position fulfils that position's eventualities. -/
def SharingWitnessFamily.ThreadFulfilling (S : SharingWitnessFamily Gam Del) : Prop := sorry

/-- The bundled conditions at a target time. (C3) `BoxFaithful` and (C4) `Target` are reused
from the deterministic device verbatim. -/
def SharingWitnessFamily.Certifies (S : SharingWitnessFamily Gam Del) (t : ℤ) : Prop := sorry

instance SharingWitnessFamily.decidableCertifies (S : SharingWitnessFamily Gam Del) (t : ℤ) :
    Decidable (S.Certifies t) := sorry

/-- **Labels are truth in the branching presented model.** -/
theorem SharingWitnessFamily.truth_iff_mem (S : SharingWitnessFamily Gam Del)
    (hc : S.Certifies 0) : True := sorry

/-- A second producer for the unchanged `WitnessFamily.Refutes` interface. -/
theorem SharingWitnessFamily.refutes_of_certifies (S : SharingWitnessFamily Gam Del) {t : ℤ}
    (h : S.Certifies t) : WitnessFamily.Refutes Gam Del := sorry

/-- The deterministic device as the diagonal instance. -/
def WitnessFamily.toSharing (W : WitnessFamily Gam Del) :
    SharingWitnessFamily Gam Del := sorry

/-- The deterministic conditions specialize to the branching ones. -/
theorem WitnessFamily.certifies_toSharing (W : WitnessFamily Gam Del) {t : ℤ}
    (h : W.Certifies t) : (W.toSharing).Certifies t := sorry

end FormalSystem.Metalogic.Decidability
```

Five notes on this block, all deliberate:

- `SharingWitnessFamily` and `Thread` are declared as full `structure`s rather than with `sorry`
  bodies, because a structure has no body to elide and because every later declaration projects
  its fields. The pinned content is the field shape, which is exactly what this section is for.
- `SharingWitnessFamily.shareSetoid` appears in `total_eq_thread`'s statement as the quotient it
  is taken over. It is a Phase 3 construction, not a pinned Goal: the pinned commitment is the
  *shape* of the characterization (a thread plus a time offset reproducing every state), not the
  particular name of the setoid.
- `truth_iff_mem` is pinned by name with a placeholder conclusion, because its real statement
  quantifies over the branching `TaskModel` and `WorldHistory` constructed in Phase 10, which do
  not exist yet and cannot be named in an isolated module. Phase 10 fixes the real statement;
  this row exists so the identifier is committed and cross-validated.
- `refutes_of_certifies` deliberately lands in the **existing** `WitnessFamily.Refutes`, not in a
  new one. That is the whole coexistence mechanism, and pinning it here makes a drift into a
  parallel interface a type error rather than a review finding.
- `StabFaithful` is **absent by design**, and its absence is itself pinned. An earlier version of
  this block carried it with a `sorry` body, which is exactly how the type-level obstruction went
  unnoticed: a `sorry`-bodied `def` whose statement is written in prose is never elaborated, so
  the missing `⊡` constructor never produced an error. The lesson generalizes — a pinned Goal
  whose real content lives in a comment is not pinned. Nothing in this plan may reintroduce a
  `StabFaithful` at `Formula`.

## Testing & Validation

- [ ] `lake build` succeeds from a clean state after every phase and at the end.
- [ ] `bash .claude/scripts/lean-sorry-census.sh` over the resolved Lean source roots reports
      zero sorries in `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/`.
- [ ] `#print axioms` on each of the fifteen Goal identifiers shows no `sorryAx` and no axiom
      beyond `propext`, `Classical.choice`, `Quot.sound`.
- [ ] `grep -rn "StabFaithful" FormalSystem/` finds nothing outside README/docstring prose: the
      (C5) exclusion is real, not a vacuous stub.
- [ ] `git diff` shows no content change to `FormalSystem/Semantics/ShiftSet.lean`.
- [ ] `git diff` shows no change to `WitnessFamily/{Basic,Predicates,Std,Agreement,Decide}.lean`
      other than, where unavoidable, added imports — and specifically no change to
      `LocalCoherentLab`, `FulfillingLab`, `BoxFaithful`, `Target`, `Certifies`, `std`, or
      `refutes_of_certifies`.
- [ ] `example (W : WitnessFamily Γ Del) (t : ℤ) : Decidable (W.Certifies t) := inferInstance`
      still elaborates (the deterministic decision procedure is intact).
- [ ] `bash .claude/scripts/check-task-references.sh` passes: no task-number citations anywhere
      under `FormalSystem/**`.
- [ ] A small hand-built branching example in `WitnessFamily/Examples.lean`'s style `#eval`s its
      `Certifies` decision to `true`, and a deliberately broken variant to `false`.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Basic.lean` (new)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Thread.lean` (new)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Frame.lean` (new)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Histories.lean` (new)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Predicates.lean` (new)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Decide.lean` (new)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Fulfil.lean` (new)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Agreement.lean` (new)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Specialize.lean` (new)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` (new)
- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` (import aggregator, additive)
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` (submodule map, (C3) correction)
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` (scope the all-histories claim)
- `specs/683_state_sharing_witness_structure_and_c3/summaries/01_*-summary.md` (at completion)

## Rollback/Contingency

Every phase is additive: the new modules live under a new `Sharing/` directory and the only
edits to existing Lean files are import lines. Reverting is therefore a matter of deleting the
new directory and its import lines, with no proof elsewhere to restore.

- **Per-phase**: each phase ends green and is committed (`Commit Mode: per-substep`), so
  `git revert` of the phase's commits is the normal contingency. No working-tree discard is
  needed.
- **If a working-tree rollback is genuinely required** (a phase left the tree dirty and
  unrecoverable), take a snapshot first and then roll back, following
  `context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
  out-of-scope override flag for the deliberate whole-tree case. Do not emit a bare
  `git-snapshot.sh` in its default reverting form as a routine start-of-phase precaution; an
  ordinary defensive checkpoint before risky work uses `--no-revert`.
- **If Phase 8 or 9 does not close**: mark the task `[BLOCKED]` for user review. Do not
  introduce `sorry`, and do not weaken (C2') to a per-lasso condition — a per-lasso fulfilment
  condition on a branching frame is unsound, and it would type-check.
- **If Phase 13's transport stalls**: the branching device is still usable as an independent
  `Refutes` producer (Phase 11 is self-contained). Close Phases 1-12 and record the
  specialization as a follow-up rather than blocking the whole task.
