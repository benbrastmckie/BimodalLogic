# Implementation Plan: Task #761

- **Task**: 761 - Ladder realization theorem: LadderCons and ladderRealized per ladder cell for all φ including box/stab letters
- **Status**: [IMPLEMENTING]
- **Effort**: 4.5 hours
- **Dependencies**: 760 (logical: `ladderModel`, `Adm`, `LadderState`, `ladderFrameAdm` are the theorem's inputs; no finite cell index is provided)
- **Research Inputs**: specs/761_ladder_realization_theorem/reports/01_ladder-realization-theorem.md
- **Artifacts**: plans/01_ladder-realization-blocked-probe.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The filed record asked for a library module `RaySummary/LadderRealize.lean` carrying `LadderCons`,
`ladderCons_localRun` and the Hit-level per-cell realization `ladderRealized` for ALL `φ`,
`box`/`stab` letters included. Research found the theorem is not merely unclosed but UNSTATABLE
on the tree as it stands: `truncate` is defined nowhere and its only reading is the index the
amended description deletes (F1); every per-cell soundness statement for the ladder presupposes
a finite index of ladder states — the open sub-problem — for three independent, library-anchored
reasons (F2: `cell_ne` defeats every `Q`-indexed candidate; the counters constrain pend-patterns,
so the `Q`-projection of a seam fibre is a proper subset of the `Q`-runs; any per-state labelling
collapses `ψ ↔ ⊡ψ`); and the `box`/`stab` acceptance clause itself is index-dependent (F3). One
design question is settled positively by machine check: the ladder's structural liveness is
FORWARD-ONLY — a history can be pending at every past time (`gPast_isPath`) — so `ulive` is
replaceable by `Count` and `slive` is not (F4). The user has ruled (decisions file, cycle 1):
**R1** — `[BLOCKED]` whole, with the obstruction landed as a wired probe and the records
corrected; no library module.

This plan therefore has one pre-decided `[BLOCKED]` phase (the filed statement, with its
obstruction recorded) and five executable phases that land the obstruction exactly as the
collection's twelfth probe landed its own: port the compiled prototype
(`prototype/ladder-liveness-forward-only-proto.lean`, 47 lines by `wc -l`, re-compiled at plan
time through the build guard: exit 0, zero warnings, three `#print axioms` lines) into the
thirteenth wired probe `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`;
wire it into `scripts/check-evidence-probes.sh`; amend the RaySummary README and one
`docs/theorem-index.md` row; amend the design of record and the task's own description so that
no residue of the deleted index (`hitOf (truncate B …)`, "`ulive`/`slive` replaced") survives;
run the full gate. The implementer ports proofs; nothing is discovered, and no file under
`FormalSystem/` other than the README is touched. Because a phase stays `[BLOCKED]`, the
implementation returns `partial` with `requires_user_review: true` per the Lean agent's
Escalation Protocol — never `implemented` — so the task's resting state holds the filed successor
chain (762 is independent of this record; 763 depends on it and inherits the block).

### Research Integration

- **F1 (the statement does not typecheck as filed), carried verbatim.** `grep -rn truncate
  FormalSystem/ specs/evidence/ docs/theorem-index.md` finds no definition; the only hits are the
  fixture theorems `hitCl_eq_truncated` / `hitCl_eq_truncated_node`, which truncate a seam index
  WINDOW on a fixture, not a ladder. `hitOf` needs `[Fintype Q]` on its presentation; the ladder
  carrier is infinite; so `hitOf (truncate B …)` can only mean the counter-clipping quotient
  `Q × Fin (B+1) × Fin (B+1)` — exactly the index `cell_ne` refutes and the description deletes.
  The description is internally inconsistent and the records are amended (Phase 5).
- **F2 (the index is the hypothesis of ANY per-cell soundness statement), carried verbatim.**
  (a) `Probe760.cell_ne B : cellAt M phi (w1 B) 0 ≠ cellAt M phi (w2 B) 0` for every `B`, so a
  presentation whose states carry one type set per `q ∈ Q` cannot be saturated (HWZ Def. 12,
  "every `t ∈ T_w` lies on some run") at both `w1 B` and `w2 B`. (b) `Count true true` forces a
  pending region at `(q, c, n)` to end at exactly `z + c + 1`, so a `step`-chain through `q₀`
  whose pend-pattern does not end its region in `c₀` steps lifts to NO `RladAdm` path through
  `(q₀, c₀, n₀)`: the `Q`-projection of the seam fibre is a proper subset of
  `{ρ | IsRun lab step (clNow φ) t ρ}`, and `hitOf` over `Q` over-approximates `HitCl` even for
  `box`/`stab`-free `φ`. (c) `PlusTruthAt M τ t (.stab ψ) ↔ ∀ σ, τ.state t = σ.state t →
  PlusTruthAt M σ t ψ` (`PlusTruth.lean`): any truth lemma reading `ψ`'s truth off the world
  state alone forces `ψ → ⊡ψ` at every point — `Probe747.stab_iff_of_presented_nowUnique`'s
  conclusion with both hypotheses dropped — and is false for any object with a non-deterministic
  `step` and an `untl` letter. Hence a per-cell object carries a SET of types per ladder state,
  which a finite object can do only through a finite index of ladder states. Nothing in this
  plan proves or restates any of (a)-(c); they are cited from the report and the landed
  declarations.
- **F3 (the acceptance clause is index-dependent), carried verbatim.** "The stab letter at
  `(q, c, n)` is that cell's bit" presupposes a presentation state per cell at which the bit is
  stored (`stab_mem_tpOf_iff` is per cell). With no index, a `LadderCons` field can only pin
  `lab q (⊡ψ)` per `q`, the wrong granularity by F2(a). A `LadderCons` without the clause would
  be a same-named, strictly weaker statement — forbidden by `plan-compliance.md`'s Statement
  Fidelity section. No `LadderCons` of any shape is landed (R1).
- **F4 (forward-only structural liveness), re-derived at plan time.** On the two-state object
  (`stepB ≡ true`, `pendB = id`), `gPast B z := if z ≤ 0 then (true, (-z).toNat, B) else
  (false, 0, B)` is admissible at every `z` (`gPast_adm`), `gPastA B` is an `IsSlicedStepPath`
  of `RladAdm stepB pendB` at offset `0` (`gPast_isPath`), pending at every `z ≤ 0`
  (`gPast_pending_past`) with countdown `(-z).toNat` (`gPast_count`). Backward, `Count true
  true` INCREASES `c`, so a `snce`-letter claimed along this history is never structurally
  discharged. Consequence: a ladder consistency bundle may replace `ulive` (forward: pending at
  `(q, c, n)` at `z` ⇒ idle at `z + c + 1`, plus a pend-field and `persist`) but must KEEP
  `slive` as the `SLive` deferral-graph condition of `Realize.lean` over `Q`'s `step`. The
  design of record's "`ulive`/`slive` replaced" is corrected to "`ulive` replaced, `slive`
  retained" (Phase 5). Compiled this plan round through
  `lake-build-guard.sh build … -- env lean specs/761_ladder_realization_theorem/prototype/ladder-liveness-forward-only-proto.lean`:
  exit 0, no warnings; `gPast_isPath` at `[propext, Classical.choice, Quot.sound]`,
  `gPast_pending_past` and `gPast_count` at `[propext, Quot.sound]`.
- **F5 (what transfers from `Realize.lean`)**: recorded in the probe header as the shape a
  successor bundle would take (`UCoh`, `deferGraph`, `Disch`, `persist`, `SCoh`,
  `bwdDeferGraph`, `SLive`, `snce_iff_of_SCoh_SLive` reusable on the `Q`-projection; `frameOf`/
  `modelOf` (WIDTH), `presented_modelOf` (trace level), `anchored_runTrace_of_boxStabFree`,
  `run_seam_state`/`isRun_of_chain_seam` not transferable). Nothing is ported into the library.
- **F6 (the two Hit-level positives are fixture arguments)**: `hitCl_eq_truncated` and
  `hitCl_eq_truncated_node` rest on a seam classification, a constant-block run and a fixture
  subset fact; on the ladder the seam fibre at a fixed `(q₀, c₀, n₀)` is infinite for any object
  with a pending cycle. Cited in the header's "what a true statement would need" paragraph; no
  general truncation lemma is claimed.
- **R3 (a realization theorem parametric in an abstract index `idx : LadderState Q pend → I`,
  `[Fintype I]`, with a saturation hypothesis)** is recorded in the header as research-level and
  NOT pursued: without an exhibited `idx` for a `⊡`-bearing `φ` it is the unsatisfiable-hypothesis
  form the tree already flags on `ladderFrame`.
- **Tactic notes for the port** (report Tactic Survey; all in the compiled prototype — port the
  calls verbatim): `gPast_adm` by `unfold gPast; split_ifs <;> simp [Adm]` (`Adm` is a `def`,
  not an `abbrev`, so `simp` needs it named); `gPast_isPath` by `rcases lt_trichotomy z 0`, then
  per branch the two inequality facts, `simp [RladAdm, Rlad, gPastA, gPast, h1, h2, Drift,
  Count]`, and `omega` on the `z < 0` branch (where `Count true true` leaves
  `(-(z+1)).toNat + 1 = (-z).toNat`); `subst` on the `z = 0` branch. The `simp only … ; refine
  ⟨rfl, …⟩` variant fails (`simp` has already reduced `stepB _ _ = true` to `True`) — use the
  full `simp` form.
- **The optional Hit-level twin of `cell_ne`** the report names (`hitCl_ne`, ~150-250 lines,
  risk-bearing) is NOT planned: `cell_ne` already carries the record's weight, the user's R1
  ruling names only the forward-only liveness probe, and the task is not costable.

### Prior Plan Reference

No prior plan for this task. The twelfth probe's plan
(`specs/760_ladder_model_cell_stabilization_lemma/plans/01_ladder-cell-refutation-probe.md`) is
the shape precedent for a `[BLOCKED]`-by-design record: its four phases ran in ~1.5 hours against
a 4-hour estimate; its one recorded deviation — the plan-level `- **Status**:` field is reserved
for `update-plan-status.sh` via the postflight, so the implementer must NOT hand-edit it — is
carried into Phase 6 below.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch, so ROADMAP.md was not consulted and is not
edited (the orchestrate conclusion regenerates it). The task's GUARDRAILS (a)-(e) are carried into
Phase 2's header checklist verbatim.

## Goals & Non-Goals

**Goals**:
(The identifier set equals the three theorem declarations of the Lean Challenge Statements block
below — the machine-checked forward-only liveness witness of report Finding F4; the block's
abbrev definitions, including the admissibility fact gPast_adm the probe also proves, are
context, not goals. No other identifier is backticked in this block, because the snapshot tool
reads every backticked token here as a Goal.)
- `gPast_isPath` — the past-pending history is an offset step path of the restricted ladder relation on the two-state object: structural liveness does not discharge a since-letter.
- `gPast_pending_past` — that history is pending at every time z ≤ 0.
- `gPast_count` — its countdown at z ≤ 0 is (-z).toNat: unbounded in the past, so no backward region ever ends.

**Non-Goals**:
- No library module: `RaySummary/LadderRealize.lean` is NOT created; `RaySummary.lean`,
  `FormalSystem.lean`, `KTypeSummaryAxiomTest.lean`, the C14 heredocs in
  `scripts/check-module-invariants.sh`, `Realize.lean`, `RunLayer.lean` and `LadderModel.lean`
  are untouched (R1; R2 — the index-free, `box`/`stab`-free run-layer half under an honest name
  — is the user's option by `/revise`).
- No `LadderCons` of any shape, with or without the `box`/`stab` clause; no `ladderCons_localRun`;
  no `ladderRealized`; no `truncate`; no index of which cell a ladder state has, over any
  substitute (the clipped-gap candidate included); no R3 parametric theorem.
- No sorry, axiom, vacuous definition, trace-level `Presented` hypothesis, finite-fibre or
  finite-width assumption, capped ladder, or weakened statement under the filed names
  (`plan-compliance.md`, Statement Fidelity).
- No successor design: what replaces the index, and whether R2's run-layer half is worth landing
  without a consumer, is the user's decision (`/revise` or `/spawn`), already so ruled.
- No machine-checked claim about `⊡(Pp)`; nothing about `HitPresented`, `PlusValidZTime`, or any
  complexity bound; no Büchi/MSO lemma cited; no cslib require.
- No edit to ROADMAP.md, to 762's description, or to 763's description (763's own text already
  names "[BLOCKED] on whichever predecessor did not close"; the inheritance is recorded in the
  design-of-record amendment, not re-stated in 763's entry).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An implementer lands `LadderCons` without the `box`/`stab` clause under the task's name, reading `[BLOCKED]` as licence for a best-effort module | H | M | F3 and Statement Fidelity: Phase 1 is pre-marked `[BLOCKED]`; the Non-Goals forbid any `LadderCons`; the Challenge block contains only the liveness witness; the header and README say in words why no statement exists |
| The implementer returns `implemented` because Phases 2-6 all closed, dropping the hold on 763 | H | M | Phase 6's last task and the Rollback section restate the Lean agent's Escalation Protocol: any `[BLOCKED]` phase forces `partial` + `requires_user_review: true`; the plan-level Status is set by the postflight, not by hand |
| Record edits re-introduce the deleted index or a cost figure | M | M | Guardrail (c); Phase 4/5 verification greps the touched records for `truncate`, `Fin (B+1)`, `min c B`, `clip (n` and requires every new occurrence to be inside a sentence that names it as deleted or research-level; every quantity named is a count |
| The forward-only verdict is read as a claim about `⊡(Pp)` or about backward fixtures | M | L | Header and README sentence: the witness is a past-pending history of the LADDER; nothing about `⊡(Pp)` beyond `Probe719Backward.pastStab_iff_allBwdPathsMeet`; guardrail (e) wording fixed in Phase 2's checklist |
| `state-write.sh` mutex (`specs/.scope-lock`) held by a concurrent writer — several orchestrations are live | M | M | Bounded retry (3 attempts, 30 s apart); on persistent refusal mark Phase 5 `[PARTIAL]` with the spec edits already committed enumerated in the progress file; never bypass the mutex, never hand-edit `state.json` |
| A `state.json` entry other than 761 changes as a side effect | M | L | The filter is scoped by `select(.project_number == 761)`; Phase 5 verifies HEAD-vs-worktree `jq -S` equality of every other entry (761 and this task's orchestrator-touched fields excluded) |
| README or theorem-index sentence trips C9 (`check-module-invariants.sh`), `readme-lint.sh`, or the task-reference lint | M | L | Cite only `specs/evidence/...` paths, declaration names and section headings — never `specs/761_…` (C9 matches `specs/[0-9]{3}_`) or "task N"; no record-versioning language ("no longer", "previously") in amended sentences — state the current fact |
| Port drift between the prototype and the probe changes a statement | M | L | The three Goal signatures are diffed byte-for-byte against the Challenge block; the prototype is a compiled oracle (exit 0 at plan time); `lean-challenge-snapshot.sh --check 761 .` is available as an advisory drift check |
| `lake env lean` on the probe fails because `LadderModel.olean` is stale while another session rebuilds | M | L | Compile through `lake-build-guard.sh build … -- env lean FILE` (as the prototype was); if an import is reported missing, wait on `lake-build-guard.sh status` rather than start a competing build |
| Cross-set collisions: README (744, not started), `typst/generated/status.typ` (410), `scripts/check-evidence-probes.sh` | L | L | All edits are appended rows/paragraphs or single-sentence amendments; `git status` on every target is clean at plan time; collisions left to the admission gate as the dispatch says — no edge is added |
| `file_scope` drift: the filed scope names `LadderRealize.lean` and the C14 files (untouched under R1) and omits the probe, the evidence script, the design-of-record file and `state.json` (touched) | L | H | `Files to modify` below is the harvest source; the postflight file-scope widening notice will fire for the added paths — expected, not a defect; the unused filed entries are harmless |
| The evidence-gate run (31 files) exceeds a foreground tool call | L | M | Run detached with a bounded waiter per `context/patterns/bounded-build-waiter.md`; it is a sequence of `lake env lean` calls, not a `lake build` |
| `typst-status-counts.sh` (pre-commit) regenerates `status.typ` with a diff | L | L | No library declaration changes under R1, so no diff is expected; if the hook regenerates it, commit it with Phase 6 and record the fact in the summary |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4, 5 | 2 |
| 3 | 6 | 3, 4, 5 |

Phases within the same wave can execute in parallel. Phase 1 is a pre-decided decision gate whose
measurement (the research report's F1-F4 and the compiled prototype) was taken before this plan
and is re-taken by Phase 2's port and Phase 6's gate run; it requires no work and is `[BLOCKED]`
at plan time, so — exactly as the twelfth probe's plan arranged it — it is never a prerequisite
of any executable phase and no executable phase waits on it. Phases 2-6 are the contingency
branch the design record names for this outcome. Phase 6 is the final phase: it depends
transitively on 2 through 5, and its full-gate verification re-observes Phase 1's measurement
through the wired probe.

### Phase 1: The Filed Statement — LadderCons, ladderCons_localRun, ladderRealized [BLOCKED]

- **Blocked**: 2026-10-12
- **Blocking Reason**: Unstatable on the tree as it stands (report F1-F3, each anchored in a
  landed declaration): `truncate` is defined nowhere and its only reading is the refuted index
  `Q × Fin (B+1) × Fin (B+1)` (`Probe760.cell_ne`, `exhibited_form_refuted`,
  `exists_form_refuted`); every per-cell soundness statement for the ladder — `HitCl = hitOf`,
  `HitPresented`, or a truth lemma on `(state, type)`-runs — presupposes a finite index of ladder
  states, because `cell_ne` defeats every `Q`-indexed candidate's saturation, the counters make
  the `Q`-projection of a seam fibre a proper subset of the `Q`-runs, and any per-state labelling
  collapses `ψ ↔ ⊡ψ` (the `stab` clause of `PlusTruth.lean`); and the `box`/`stab` acceptance
  clause — the task's named criterion — presupposes that same index (`stab_mem_tpOf_iff` is per
  cell). The contingency the design record (Section A) and the dispatch name for this case is
  `[BLOCKED]`, never a sorry, axiom, vacuous definition, trace-level hypothesis, finite-fibre or
  finite-width assumption, or a same-named weaker bundle. The user ruled R1 on 2026-10-12
  (decisions file, cycle 1).
- **Blocked by**: the open sub-problem of a computable index of WHICH cell a ladder state has —
  a question no predecessor answers and this record was told not to restate over any substitute
  — and, downstream of it, a user decision (R2: land the index-free, `box`/`stab`-free run-layer
  half under an honest name; R3: a research-first record for the index). Not by any question an
  agent could settle within this task.

**Goal**: The filed deliverables, verbatim from the dispatch — recorded here as the goals that
could not be met, for the `blockers[]` entry the implementation returns:
- `structure LadderCons (φ : PlusFormula) (lab) (step) (pend) : Prop` — `Cons`'s fields with the liveness fields `ulive`/`slive` replaced by the ladder's structural liveness, and with the box/stab letters PINNED per cell by the anchor layer's equations (`box_mem_tpOf_iff`, `stab_mem_tpOf_iff`)
- `theorem ladderCons_localRun …` — every ladder run satisfies the run conditions
- `theorem ladderRealized … (k : ℕ) (hk : 1 ≤ k) : HitCl (ladderModel …) τ t φ k = ↑(hitOf (truncate B …) … (clNow φ) k)` — per ladder cell, for ALL φ, box/stab letters INCLUDED, the cell being `cellAt (ladderModel …) φ (t, ⟨(q, c, n), h⟩)`

**Tasks** (none executable; each item is unstatable or forbidden — left unchecked deliberately):
- [ ] `LadderCons` with the `box`/`stab` clause — presupposes the open index (F3); without the clause it is a same-named weaker statement (forbidden).
- [ ] `ladderCons_localRun` — has no bundle to be stated over; its index-free half is R2, the user's option.
- [ ] `ladderRealized` with `hitOf (truncate B …)` — `truncate` undefined; its only reading is the deleted index (F1); every alternative per-cell shape is blocked on the same sub-problem (F2).
- [ ] "`ulive`/`slive` replaced by structural liveness" — half false: `slive` is not replaceable (F4, machine-checked); corrected in the records by Phases 4-5.

**What was tried**: the statement's formulability was tested before any proof was attempted
(report decision D5: no open goal exists to survey). **Goal state reached**: none of the three
declarations has a statement; the one settled design fact (forward-only liveness) is landed as
the thirteenth wired probe by Phases 2-3. **What unblocks**: a resolution of the index
sub-problem (research-first, `/spawn`), or the user's R2 via `/revise`.

**Timing**: 0 hours (no work; pre-decided)

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: This phase edits no file; its only measurement is the compiled prototype
(`bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/761_ladder_realization_theorem/prototype/ladder-liveness-forward-only-proto.lean`
exiting 0 with three `#print axioms` lines), already observed at plan time and re-observed by
Phase 2's port, so nothing cheaper or dearer applies.

**Files to modify**:
- none planned — this phase edits no file; the obstruction is landed by Phases 2-6.

**Verification**:
- The prototype compiles through the guard with exit 0 and the three axiom lines (plan-time: done).
- This phase heading still reads `[BLOCKED]` when the implementation returns; it is never
  re-marked `[COMPLETED]`, `[COMPLETED WITH EXCLUSIONS]`, or `[PARTIAL]` by the implementer.

---

### Phase 2: Author the Wired Forward-Only Liveness Probe [COMPLETED]

**Goal**: Create `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` — the
mandated header followed by the prototype's declarations under `namespace Probe761` — compiling
under `lake env lean` with no `sorry`, no axiom, no vacuous definition, and the three Challenge
statements verbatim.

**Tasks**:
- [x] Write the header docstring (`/- … -/`, before the imports, modeled on
      `ladder-cell-refutation.lean`'s), containing in this order:
      - Title line: "Probe 761 (requirement (W)'s run layer, phase 2, the soundness half, over the
        two-state object): the ladder's structural liveness is FORWARD-ONLY — an admissible ladder
        history can be pending at every past time, so `Cons`'s backward liveness field `slive` is
        not replaceable by `Count`, and the realization theorem this probe accompanies is
        `[BLOCKED]` on the open index of which cell a ladder state has."
      - **What was asked**: the three filed declarations (`LadderCons` with the `box`/`stab`
        clause, `ladderCons_localRun`, `ladderRealized` with `hitOf (truncate B …)`), quoted as
        in Phase 1's Goal, on `ladderModel` over `ladderFrameAdm` (`LadderModel.lean`).
      - **Why no statement exists** (three paragraphs, each citing its landed anchor and proving
        nothing here): `truncate` is defined nowhere and its only reading is the index
        `Q × Fin (B+1) × Fin (B+1)` refuted by `ladder-cell-refutation.lean`; every per-cell
        soundness statement presupposes a finite index of ladder states — `cell_ne` (saturation
        fails on every `Q`-indexed candidate), the `Count true true` clause (the `Q`-projection
        of a seam fibre is a proper subset of the `Q`-runs, so `hitOf` over `Q`
        over-approximates `HitCl` even for `box`/`stab`-free `φ`), and the `stab` clause of
        `PlusTruth.lean` (a per-state labelling forces `ψ ↔ ⊡ψ`, the eighth probe's collapse
        with both hypotheses dropped); the `box`/`stab` acceptance clause presupposes the same
        index (`stab_mem_tpOf_iff` is per cell), so a `LadderCons` without it would be a
        same-named weaker statement and is not written.
      - **What this probe establishes (F4)**: the object (`stepB ≡ true`, `pendB = id`), the
        history `gPast B z := if z ≤ 0 then (true, (-z).toNat, B) else (false, 0, B)`, its
        admissibility `gPast_adm`, the path fact `gPast_isPath`, `gPast_pending_past`,
        `gPast_count`; the mechanism — backward, `Count true true` reads `c' + 1 = c`, so the
        countdown GROWS into the past without bound; a `snce`-letter claimed along `gPastA B` is
        never structurally discharged.
      - **Consequence for a successor bundle**: `ulive` is replaceable (forward: a pending state
        `(q, c, n)` at `z` is idle at `z + c + 1`; with a pend-field and `persist` this is
        `untl_iff_of_UCoh_ULive`'s shape); `slive` must stay as `Realize.lean`'s `SLive`
        deferral-graph condition over `Q`'s `step` (sound on ladder paths because `Rlad`'s first
        conjunct makes the `Q`-projection a `step`-chain). Name what transfers from
        `Realize.lean` (`UCoh`, `deferGraph`, `Disch`, `persist`, `SCoh`, `bwdDeferGraph`,
        `SLive`, `snce_iff_of_SCoh_SLive`) and what does not (`frameOf`/`modelOf` — WIDTH;
        `presented_modelOf` — trace level; `anchored_runTrace_of_boxStabFree`;
        `run_seam_state`/`isRun_of_chain_seam`), as description, not as a plan.
      - **What a true statement would need** (one paragraph, no claim): a finite index of ladder
        states per cell (the open sub-problem); a theorem parametric in an abstract index
        `idx : LadderState Q pend → I`, `[Fintype I]`, with a saturation hypothesis, is the
        unsatisfiable-hypothesis form unless some `idx` is exhibited for a `⊡`-bearing `φ` —
        research-level, not claimed. The two Hit-level positives (`hitCl_eq_truncated`,
        `hitCl_eq_truncated_node`) are fixture arguments (seam classification, constant-block
        run, a fixture subset fact) and supply no general truncation lemma: on the ladder the
        seam fibre at a fixed `(q₀, c₀, n₀)` is infinite for any object with a pending cycle.
      - **What this probe does NOT say** (guardrails (a)-(e)): (a) cells are closure-indexed
        SETS over the time axis, `box`/`stab` bits included, never one bit per depth; (b) the
        slice `LadderState Q pend` is infinite (`Rlad_slice_infinite` one level down) and no
        fibre bound is assumed or claimed; (c) no upper bound of any kind, no complexity bound —
        `B` is a count; (d) zero debt — no external lemma, no cslib require, nothing cited in
        place of a proof; (e) the landed form is forward-only in the precise sense that the
        FORWARD liveness is structural and the BACKWARD one is not — the witness is a past-pending
        history of the ladder, not a claim about `⊡(Pp)` or about any backward fixture (nothing
        beyond `Probe719Backward.pastStab_iff_allBwdPathsMeet` is claimed there); no
        device-discrimination claim. Also: nothing about `HitPresented` or `PlusValidZTime`;
        `anchorCells_finite` and `anchorCells_ncard_le` untouched (the SET of cells stays finite
        and bounded); `presented_modelOf` untouched; no `LadderRealize.lean` exists and none is
        created by this probe; the index-free run-layer half is a design option not taken here.
      - Axiom foot sentence ("`gPast_isPath` carries `[propext, Classical.choice, Quot.sound]`;
        `gPast_pending_past` and `gPast_count` carry `[propext, Quot.sound]`") and the compile
        line `lake env lean specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`.
- [x] Import and opens exactly as the prototype: `RaySummary.LadderModel`; `open
      FormalSystem.Syntax FormalSystem.Semantics` and `open
      FormalSystem.Metalogic.Decidability.RaySummary`; `namespace Probe761`.
- [x] Port the prototype's declarations in order, keeping names, statements and docstrings:
      `stepB`, `pendB`, `gPast`, `gPast_adm`, `gPastA`, `gPast_isPath`, `gPast_pending_past`,
      `gPast_count`. Identifiers are already ASCII (the snapshot tool's regex is ASCII-only); no
      renames. Nothing else changes.
- [x] Close with `end Probe761` and `#print axioms` for `Probe761.gPast_isPath`,
      `Probe761.gPast_pending_past`, `Probe761.gPast_count`.
- [x] Compile through the guard:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`.
- [x] `git add` the new file (the gate's "tracked, not merely present" rule — Phase 3 fails
      otherwise) and commit per the green-substep mandate.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The probe is ~140-180 lines (prototype 47 lines by `wc -l`, re-derived at
plan time, plus a 95-130 line probe header). Confirm with `wc -l` on the written file; a figure
outside 120-220 is a signal to re-check that a header paragraph was not dropped or a declaration
duplicated, not a defect in itself.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`
(through the build guard) exiting 0 is the complete covering check — the file sits outside the
Lake build graph, nothing imports it, and it modifies no library module, so no other compilation
unit can be affected.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` - new probe file (header + ported proofs)

**Verification**:
- The guarded `lake env lean` exits 0 with zero `error` lines and zero `warning` lines; the three
  `#print axioms` lines read `[propext, Classical.choice, Quot.sound]` for `gPast_isPath` and
  `[propext, Quot.sound]` for `gPast_pending_past` and `gPast_count`.
- `grep -nE "sorry|^axiom |:= (True|Unit|trivial|Trivial)\s*$" specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`
  prints nothing.
- The three Goal declarations appear with exactly the signatures in `## Lean Challenge
  Statements` (docstrings may precede them); `bash .claude/scripts/lean-challenge-snapshot.sh --check 761 .`
  is available as an advisory drift check.
- Header read-through confirms every item in the first task's checklist is present, including
  the three "why no statement exists" paragraphs, the "`ulive` replaceable, `slive` retained"
  sentence, the forward-only sentence in guardrail (e)'s precise sense, the no-bound sentence,
  and "no `LadderRealize.lean` exists and none is created".
- `grep -c "truncate" specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`
  counts only occurrences inside the header's "defined nowhere" sentences (none in code).
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` exits 0.

---

### Phase 3: Wire the Probe into the Evidence Gate [COMPLETED]

**Goal**: Register the probe in `scripts/check-evidence-probes.sh` so the gate compiles it on
every run, with a table row recording what it holds in place.

**Tasks**:
- [x] Add a table row in the `# --- WIRED ---` comment table, directly after the
      `seam-gluing-ray-product/ladder-cell-refutation` row (the row block ends at the line before
      `WIRED=(`), in the same two-column `# probe | decision` wrapped format, headed
      `FORWARD-ONLY LIVENESS (requirement (W)'s run layer, "(W): what landed and what did not",
      obligation (ii) item 1, the soundness half, over the two-state object)` and stating: the
      realization theorem (`LadderCons` with its `box`/`stab` clause, `ladderCons_localRun`,
      `ladderRealized`) is `[BLOCKED]` on the open index of which cell a ladder state has —
      every per-cell soundness statement presupposes it (`cell_ne`; the `Count` clause makes the
      `Q`-projection of a seam fibre a proper subset of the `Q`-runs; a per-state labelling
      collapses `ψ ↔ ⊡ψ`) and so does the acceptance clause (`stab_mem_tpOf_iff` is per cell);
      what IS settled, machine-checked: an admissible ladder history can be pending at every past
      time (`gPast_isPath`, `gPast_pending_past`, `gPast_count` — backward, `Count true true`
      grows the countdown without bound), so `Cons`'s `ulive` is replaceable by structural
      liveness and `slive` is NOT. What it does NOT say (forward-only in the sense that the
      forward liveness is structural and the backward one is not — not a claim about `⊡(Pp)`;
      no bound of any kind; no finiteness; nothing about `HitPresented` or `PlusValidZTime`; no
      library module created; the successor design — an index, or the index-free run-layer half
      — not chosen; `anchorCells_ncard_le` untouched). Axioms `[propext, Classical.choice,
      Quot.sound]` (`gPast_pending_past`, `gPast_count` `[propext, Quot.sound]`). No task number
      anywhere in the row — durable anchors only.
- [x] Append `"seam-gluing-ray-product/ladder-liveness-forward-only"` to the `WIRED=(` array
      immediately after `"seam-gluing-ray-product/ladder-cell-refutation"`.
- [x] `bash -n scripts/check-evidence-probes.sh` (syntax) and then run the gate detached with a
      bounded waiter (`context/patterns/bounded-build-waiter.md`).
- [x] Commit the script edit.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: At plan time `WIRED` has 29 entries and `WIRED_REPO` 1 (counted with
`awk '/^WIRED=\(/,/^\)/' … | grep -c '^  "'`), so the gate's PASS line should read
`PASS  all 31 wired probe(s) compile` after the edit. Confirm by re-counting both arrays before
and after the edit (exactly +1 on `WIRED`) and matching the PASS line's number to the sum.

**Tier Justification**: `bash -n scripts/check-evidence-probes.sh` plus a full
`bash scripts/check-evidence-probes.sh` run exiting 0 is the complete covering check — the edit is
one comment block and one array element, the script has no other consumer that parses `WIRED`,
and `scripts/check-evidence-probes.sh` is self-excluded from `check-module-invariants.sh`'s C9.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - one WIRED table row and one `WIRED=(` array entry

**Verification**:
- `bash -n scripts/check-evidence-probes.sh` exits 0.
- `bash scripts/check-evidence-probes.sh` exits 0; its output contains
  `seam-gluing-ray-product/ladder-liveness-forward-only … PASS` and the final line
  `PASS  all 31 wired probe(s) compile` (the count per the Scope Hypothesis).
- `bash .claude/scripts/check-task-references.sh --quiet scripts/check-evidence-probes.sh` exits 0.
- `git diff --staged --stat` shows only `scripts/check-evidence-probes.sh` for this phase's commit.

---

### Phase 4: Record the Obstruction in the README and the Theorem Index [COMPLETED]

**Goal**: Add the thirteenth-probe paragraph to the README's Evidence section, amend the three
README sentences that now misdescribe the soundness half, amend one `docs/theorem-index.md` row,
and state the per-state-labelling collapse as a principle so no successor re-derives it.

**Tasks**:
- [x] In `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `## Evidence`, insert ONE
      paragraph directly after the "A twelfth wired probe, …" paragraph (which ends "…and the
      successor design is not chosen here.") and before "The permanent computability witnesses
      are …", of the shape: "A thirteenth wired probe,
      `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`, accompanies the
      run layer's phase-2 soundness half — the realization theorem per ladder cell — which is
      `[BLOCKED]` on the open index of which cell a ladder state has: every per-cell soundness
      statement for `ladderModel` presupposes a finite index of ladder states (the twelfth
      probe's `cell_ne` defeats the saturation of every `Q`-indexed candidate; `Count`'s pending
      clause makes the `Q`-projection of a seam fibre a proper subset of the `Q`-runs, so a
      presentation over `Q` over-approximates `HitCl` even for `box`/`stab`-free `φ`; and a
      labelling that reads closure truth off the world state alone forces `ψ ↔ ⊡ψ` by the `stab`
      clause, the eighth probe's collapse with both of its hypotheses dropped), and the
      `box`/`stab` acceptance clause presupposes that same index (`stab_mem_tpOf_iff` is per
      cell). What the probe settles, machine-checked on the two-state object: an admissible
      ladder history can be pending at every past time (`gPast_isPath`, `gPast_pending_past`,
      `gPast_count` — backward, `Count true true` grows the countdown without bound), so the
      ladder's structural liveness is forward-only: a ladder consistency bundle may replace
      `Cons`'s `ulive` by it and must keep `slive`. `gPast_isPath` at `[propext,
      Classical.choice, Quot.sound]`, the other two at `[propext, Quot.sound]`, citing
      `LadderModel.lean` and re-proving nothing — no bound of any kind, no finiteness, nothing
      about `HitPresented` or `PlusValidZTime`, no library module, `anchorCells_finite` and
      `anchorCells_ncard_le` untouched, the successor design not chosen here." Durable anchors
      only: no task number, no `specs/761_…` path, no record-versioning language.
- [x] Same README, "(W): what landed and what did not", item 1 of "Open: obligation (ii)":
      after the sentence ending "…while the SET of cells stays finite and bounded
      (`anchorCells_finite`, `anchorCells_ncard_le`).", insert: "That sub-problem is the
      hypothesis of the realization theorem itself, not a side question: any per-cell object
      must carry a SET of types per ladder state (saturation, HWZ Def. 12), and a finite object
      can do so only through a finite index of those states; a per-state labelling instead forces
      `ψ ↔ ⊡ψ` by the `stab` clause alone, with no `Presented` or `nowUnique` hypothesis — the
      eighth probe's collapse is the clause's own. The `box`/`stab` acceptance clause presupposes
      the index too (`stab_mem_tpOf_iff` is per cell), so no `LadderCons` is stated. What is
      settled: the ladder's structural liveness is forward-only (thirteenth wired probe,
      `gPast_isPath`), so such a bundle replaces `ulive` and keeps `slive`." Keep the rest of the
      item (the `Presented` prohibition) unchanged.
- [x] Same README, the sentence ending "…the run-layer consistency conditions that would play
      `Cons`'s role for the ladder are likewise named and not built." — amend minimally to add:
      "; whatever form they take replaces `ulive` only (a pending region at `(q, c, n)` ends at
      `z + c + 1`, by `Count`) and keeps `slive`, because an admissible ladder history can be
      pending at every past time (thirteenth wired probe, `gPast_isPath`)."
- [x] Same README, `## The verdict` table, row (W), the parenthesis "(soundness: the stabilization
      lemma in the pair of ladder counters is refuted by the twelfth wired probe
      `ladder-cell-refutation.lean`, and phase 2 is `[BLOCKED]` on the successor design;
      completeness: (C)'s general row, open)": amend to "(soundness: the stabilization lemma in
      the pair of ladder counters is refuted by the twelfth wired probe
      `ladder-cell-refutation.lean`, the realization theorem is `[BLOCKED]` on the open index of
      which cell a ladder state has, and the ladder's structural liveness is forward-only —
      thirteenth wired probe `ladder-liveness-forward-only.lean`; completeness: (C)'s general row,
      open)".
- [x] `docs/theorem-index.md`, the `ladderModel` row only: inside its "**What it is not**"
      clause, after "…which consumes these declarations)", add "; the realization theorem itself
      is `[BLOCKED]` on the open index of which cell a ladder state has, and the ladder's
      structural liveness is forward-only — an admissible history pending at every past time,
      wired probe `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`".
      Do not touch the row's Declaration, File, Frame class, or `pinned:C14` cells, nor the other
      four ladder rows.
- [x] Update the README's trailing `*Last verified: YYYY-MM-DD*` line to the implementation
      date.
- [x] Commit the README and theorem-index edits per the green-substep mandate.

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly one new README paragraph, three amended README sentences, the
`Last verified` line, and one amended theorem-index clause; confirm with `git diff --stat`
showing only `FormalSystem/Metalogic/Decidability/RaySummary/README.md` and
`docs/theorem-index.md` and a README hunk count of 5. `grep -c 'thirteenth wired probe'` on the
README should read 3 after the edit (plan-time baseline 0; re-count before editing).

**Tier Justification**: Every changed hunk is markdown prose with no compile surface, and the
covering checks are the repository's own lints read by exit status —
`bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary`,
`bash scripts/check-module-invariants.sh` (C9 task-reference scan and C15 theorem-index anchors),
and `bash .claude/scripts/check-task-references.sh --quiet` — plus the diff read-through the
`prose` row prescribes (`suite_selection_select` returns `__FULL_SWEEP__` for these paths, so no
shell suite is claimed as coverage).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - Evidence paragraph (new); item 1 of "(W): what landed and what did not"; the "named and not built" sentence; the verdict-table (W) row parenthesis; `Last verified` date
- `docs/theorem-index.md` - the `ladderModel` row's "What it is not" clause

**Verification**:
- `bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` exits 0.
- `bash scripts/check-module-invariants.sh` exits 0 (C9: zero task-number or `specs/NNN_`
  citations under `FormalSystem/`, `docs/`, `scripts/`; C15 theorem-index anchors intact; C14
  pins unchanged); run detached with a bounded waiter.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- `grep -nE "no longer|previously|formerly|used to" ` over the diff hunks of both files prints
  nothing (no record-versioning language).
- `git diff -U0 -- docs/theorem-index.md` shows exactly one hunk, inside the `ladderModel` row,
  and `grep -c 'pinned:C14' docs/theorem-index.md` is unchanged from baseline.
- `grep -nE "truncate|Fin \(B\+1\)|min c B|clip \(n" FormalSystem/Metalogic/Decidability/RaySummary/README.md docs/theorem-index.md`
  shows no NEW occurrence outside a sentence naming the device as refuted or research-level.

---

### Phase 5: Amend the Design of Record and the Task's Own Description [COMPLETED]

**Goal**: Remove the two residues of the deleted index from the records this task is stated on —
`hitOf (truncate B …)` and "`ulive`/`slive` replaced" — by dated amendment paragraphs in
`followup-scope-spec.md` (Sections A, C, D, H4, H6), in `successor-records.json` (T4), and in
this task's `state.json` description, so that a future `/revise` or `/spawn` reads the block and
its reasons rather than an inconsistent statement.

**Tasks**:
- [x] Draft the amendment paragraph once, in
      `specs/761_ladder_realization_theorem/records/761-amendment.txt`, of the shape: "AMENDED
      2026-10-12 (realization blocked): the realization theorem is [BLOCKED] on the open index
      sub-problem — `hitOf (truncate B …)` is a residue of the deleted index (`truncate` is
      defined nowhere; its only reading is `Q × Fin (B+1) × Fin (B+1)`) and is withdrawn from the
      statement line; every per-cell soundness statement presupposes a finite index of ladder
      states (`cell_ne`; the `Count` clause; the `stab` clause's collapse of any per-state
      labelling), and the `box`/`stab` acceptance clause presupposes it too; the ladder's
      structural liveness is FORWARD-ONLY (wired probe
      `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`: `gPast_isPath`),
      so a ladder bundle replaces `ulive` only and keeps `slive` — `ulive`/`slive` replaced`
      reads `ulive` replaced, `slive` retained. No library module; the index-free run-layer half
      is a user option (R2) not taken. See
      specs/761_ladder_realization_theorem/plans/01_ladder-realization-blocked-probe.md." (Task
      numbers and `specs/**` paths are permitted here: every target is under `specs/**`.)
- [x] `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md`:
      - Section A: after the existing "**Amendment (2026-10-11).**" paragraph, add
        "**Amendment (2026-10-12).**" carrying the paragraph above, and note that the
        "*Consistency conditions and `Adm`.*" paragraph's "`ulive`/`slive` replaced" reads
        "`ulive` replaced, `slive` retained".
      - Section C: after the "**Scope decision.**" bullets, add an "**Amendment (2026-10-12).**"
        paragraph: the `box`/`stab` acceptance clause cannot be formulated without the index, so
        obligation (3)'s first half stays assigned to (W) and is `[BLOCKED]` with it; Decision D1
        (no standalone (S) record) stands.
      - Section D: after the existing "**Amendment (2026-10-11).**" paragraph, add
        "**Amendment (2026-10-12).**": the (←) soundness half inherits the block on H4; H6 is
        `[BLOCKED]` on H4 by its own honest-outcome clause; `objBound φ` remains a count whose
        shape is open.
      - Section H4: prepend the amendment line to the quoted description block (a second `>
        AMENDED …` line above the existing one), and leave the "**Costability**" line unchanged.
      - Section H6: prepend "> AMENDED 2026-10-12 (realization blocked): T4 is [BLOCKED] on the
        open index sub-problem; this record's (←) half inherits that block — see
        specs/761_ladder_realization_theorem/plans/01_ladder-realization-blocked-probe.md."
- [x] `specs/757_lplus_decidability_successor_task_set/successor-records.json`: prepend the same
      amendment paragraph (plus a blank line) to T4's `description`, as a text-level edit of the
      current file touching only that one field (the twelfth probe's plan recorded that `jq`
      re-serialization re-flows untouched records; follow its precedent); `jq empty` the result.
- [x] `specs/state.json`, this task's description, via the sanctioned writer only (never `!=`,
      per the jq escaping hazard):
      `bash .claude/scripts/state-write.sh '(.active_projects[] | select(.project_number == 761)) |= (.description = ($d + "\n\n" + .description) | .last_updated = $ts)' --session-id "$SESSION_ID" --arg d "$(cat specs/761_ladder_realization_theorem/records/761-amendment.txt)" --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" --regen-todo`;
      on exit 2 (mutex) retry up to 3 times, 30 s apart.
- [x] Verify nothing else moved: `diff <(git show HEAD:specs/state.json | jq -S 'del(.active_projects[] | select(.project_number == 761))') <(jq -S 'del(.active_projects[] | select(.project_number == 761))' specs/state.json)` is empty.
- [x] Verify the content: `jq -r '.active_projects[] | select(.project_number == 761) | .description' specs/state.json | grep -c 'AMENDED 2026-10-12 (realization blocked)'` is 1 and `| grep -c 'slive. retained'` is 1; `diff <(jq -r '.records[] | select(.label == "T4") | .description' specs/757_lplus_decidability_successor_task_set/successor-records.json) <(jq -r '.active_projects[] | select(.project_number == 761) | .description' specs/state.json)` is empty; `jq empty` on both JSON files exits 0.
- [x] Commit the spec, the records file, `state.json` and the regenerated `TODO.md` as one
      batch.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: atomic-batch (the `state-write.sh` call and the regenerated `TODO.md` are one
pre-declared batch with the two record files: a commit between them would record `TODO.md` ahead
of `state.json`)

**Scope Hypothesis**: Exactly one `active_projects` entry changes (761; `description` and
`last_updated` only) and every other entry is byte-identical to HEAD (confirm with the `jq -S
del(...)` diff above); the spec gains five amendment insertions (A, C, D, H4, H6) and no other
hunk (`git diff -U0 -- specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md`
hunk count 5); `successor-records.json` differs from HEAD in T4's `description` only.

**Tier Justification**: The covering check is `jq empty` on both JSON files, the HEAD-vs-worktree
`jq -S` equality of every `state.json` entry other than 761, and the phrase greps above, each
read by exit status; this is a `specs/**`-only edit that no shell suite maps to
(`__FULL_SWEEP__`) and for which `verify-deploy.sh --only-gate 3,4` attests nothing in a
deploy-consumer tree, so neither is claimed as coverage.

**Files to modify**:
- `specs/761_ladder_realization_theorem/records/761-amendment.txt` - the amendment paragraph (new)
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - amendment paragraphs in Sections A, C, D; amendment lines in H4 and H6
- `specs/757_lplus_decidability_successor_task_set/successor-records.json` - T4 `description` only
- `specs/state.json` - 761 `description` and `last_updated`, via `state-write.sh` only
- `specs/TODO.md` - regenerated by `generate-todo.sh` through `--regen-todo`; never hand-edited

**Verification**:
- `state-write.sh` exits 0; `jq empty specs/state.json` and `jq empty specs/757_lplus_decidability_successor_task_set/successor-records.json` exit 0.
- The `jq -S del(...)` HEAD-vs-worktree diff is empty.
- The three content greps and the T4-vs-761 `diff` above pass.
- `grep -c 'AMENDED 2026-10-12' specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` is at least 2 (H4, H6) and `grep -c 'Amendment (2026-10-12)'` is 3 (A, C, D).
- `git diff --stat` for this phase names exactly the five files above.

---

### Phase 6: Run the Full Gate, Write the Summary, Return Blocked [COMPLETED]

**Goal**: Run the complete repository gate set over the landed probe and the amended records,
write the implementation summary, and return with Phase 1 still `[BLOCKED]`.

**Tasks**:
- [x] Re-run the guarded `lake env lean` on the probe after all commits.
- [x] Run the final gate set (below), detached where the pattern requires, and record each exit
      status in the summary. If the pre-commit hook regenerates `typst/generated/status.typ`,
      commit it with this phase and say so in the summary.
- [x] Write the implementation summary per `summary-format.md`
      (`specs/761_ladder_realization_theorem/summaries/01_ladder-realization-blocked-probe-summary.md`),
      naming Phase 1's obstruction, the forward-only verdict, the user's R1 ruling, and the two
      successor options (R2 via `/revise`; a research-first index record via `/spawn`).
- [x] Return per the Lean agent's Escalation Protocol, because Phase 1 is `[BLOCKED]`: leave the
      plan-level `- **Status**:` field to the postflight (`update-plan-status.sh` via
      `update-task-status.sh`; do NOT hand-edit it — the twelfth probe's implementation recorded
      this deviation); write `.return-meta.json` with `status: "partial"`,
      `requires_user_review: true`, `blocked_phase: 1`, and a `review_reason` naming the open
      index sub-problem and the R2/R3 choice; write the handoff with `status: "partial"`,
      `phases_completed: 5`, `phases_total: 6`, and one `blockers[]` entry for Phase 1 carrying
      the three verbatim goal lines from Phase 1's Goal, with `why_it_failed` stating that the
      statements are unformulable without the open index (not a failed proof) and that the
      remaining choice is the user's. NEVER return `implemented`.

**Timing**: 1.25 hours

**Depends on**: 3, 4, 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `specs/761_ladder_realization_theorem/summaries/01_ladder-realization-blocked-probe-summary.md` - the implementation summary (new)
- `typst/generated/status.typ` - only if regenerated by the pre-commit hook (no diff expected)

**Verification** (the complete gate set — every command's exit status is checked, never only its
output):
- `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean`
  exits 0 (three `#print axioms` lines as in Phase 2).
- `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 31 wired probe(s) compile`.
- `bash scripts/check-module-invariants.sh` exits 0 (C9 in particular: zero task-number or
  `specs/NNN_` citations under `FormalSystem/`, `docs/` and `scripts/`; C14 pins unchanged; C15
  theorem-index anchors intact); run detached with a bounded waiter.
- `bash .claude/scripts/check-task-references.sh --quiet` exits 0.
- `bash scripts/readme-lint.sh FormalSystem/Metalogic/Decidability/RaySummary` exits 0.
- `bash scripts/typst-sync-check.sh` exits 0 (or its documented Check-2 regeneration is applied
  and committed).
- Full `lake build` via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`,
  detached (`Bash(run_in_background: true)`) per
  `context/project/lean4/operations/long-builds.md`, exits 0 — expected a no-op success, since
  no library `.lean` file changes, but mandatory before the return.
- Lean agent Final Verification Stage over the resolved source roots AND the probe file:
  `lean-sorry-census.sh` count 0; vacuous-definition grep count 0; `grep -rn "^axiom "` count
  unchanged from baseline.
- `bash .claude/scripts/verify-deploy.sh` exits 0.
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 761 .` reports no drift (advisory).
- `git status --short` shows no stray modified files outside this plan's `Files to modify` set.
- The plan file's Phase 1 heading still reads `[BLOCKED]`; the return status is `partial`, not
  `implemented`.

## Lean Challenge Statements

The three `theorem` declarations are the Goals and carry `sorry` bodies. Everything above them is
supporting context declared with `abbrev`, which the snapshot tool (`lean-challenge-snapshot.sh`)
neither counts as a Goal nor rewrites — but it DOES swallow any non-`theorem` text that sits
between two `theorem` declarations into the preceding `:= sorry`, so every `abbrev` must precede
the first `theorem`. That ordering is why the admissibility fact the probe proves as a theorem
(`gPast_adm`) appears here as a `sorry`-bodied `abbrev`: it is not a Goal, its statement is pinned
by position only, and the probe proves it in full. The definitional bodies (the object, the
history) are part of the contract and are written out. The probe itself uses `def`/`theorem` for
these, exactly as the prototype does — the `abbrev` form is for the Challenge module only.
Identifiers are ASCII for the snapshot tool's regex; the probe uses the same names.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel

open FormalSystem.Syntax FormalSystem.Semantics
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761

abbrev stepB : Bool → Bool → Bool := fun _ _ => true
abbrev pendB : Bool → Bool := fun q => q

abbrev gPast (B : ℕ) (z : ℤ) : Bool × ℕ × ℕ :=
  if z ≤ 0 then (true, (-z).toNat, B) else (false, 0, B)

-- Proved as a theorem in the probe; `abbrev` here only so the snapshot tool keeps the ordering.
abbrev gPast_adm (B : ℕ) (z : ℤ) : (gPast B z).2.1 ∈ Adm pendB (gPast B z).1 := sorry

abbrev gPastA (B : ℕ) (z : ℤ) : LadderState Bool pendB := ⟨gPast B z, gPast_adm B z⟩

theorem gPast_isPath (B : ℕ) : IsSlicedStepPath (RladAdm stepB pendB) 0 (gPastA B) := sorry

theorem gPast_pending_past (B : ℕ) (z : ℤ) (hz : z ≤ 0) : (gPastA B z).1.1 = true := sorry

theorem gPast_count (B : ℕ) (z : ℤ) (hz : z ≤ 0) : (gPastA B z).1.2.1 = (-z).toNat := sorry

end Probe761
```

## Testing & Validation

- [x] The probe compiles under the gate's own command (`lake env lean`, through the build guard)
      with 0 errors, 0 warnings, and the axiom foot `[propext, Classical.choice, Quot.sound]` on
      `gPast_isPath` and `[propext, Quot.sound]` on `gPast_pending_past` and `gPast_count`.
- [x] No `sorry`, `axiom`, or vacuous-definition pattern in the probe (grep count 0).
- [x] The three Goal declarations match the Lean Challenge Statements block exactly
      (`lean-challenge-snapshot.sh --check 761 .` as an advisory drift check).
- [x] `check-evidence-probes.sh` reports 31 wired probes, all PASS.
- [x] `check-module-invariants.sh`, `check-task-references.sh`, `readme-lint.sh`,
      `typst-sync-check.sh`, `verify-deploy.sh` and the guarded full `lake build` all exit 0.
- [x] Header read-through: the three "why no statement exists" paragraphs; "`ulive` replaceable,
      `slive` retained"; guardrail (e)'s precise forward-only sense; the no-bound, no-finiteness,
      zero-debt sentences; `anchorCells_ncard_le` untouched; no `LadderRealize.lean`; successor
      design not chosen.
- [x] The README's `thirteenth wired probe` count is 3 and the theorem-index diff is one hunk in
      the `ladderModel` row.
- [x] No new `truncate` / `Fin (B+1)` / clipped-gap occurrence in any touched file outside a
      sentence naming it as deleted, refuted or research-level.
- [x] `state.json`: only 761's `description`/`last_updated` changed; T4's description in
      `successor-records.json` equals it; `TODO.md` regenerated, never hand-edited.
- [x] Phase 1 still `[BLOCKED]`; return status `partial` with `requires_user_review: true`.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/ladder-liveness-forward-only.lean` (new, tracked, wired — the thirteenth probe)
- `scripts/check-evidence-probes.sh` (one table row, one `WIRED` entry)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (one Evidence paragraph, three amended sentences, `Last verified` date)
- `docs/theorem-index.md` (one amended clause in the `ladderModel` row)
- `specs/757_lplus_decidability_successor_task_set/followup-scope-spec.md` (amendment paragraphs in A, C, D; amendment lines in H4, H6)
- `specs/757_lplus_decidability_successor_task_set/successor-records.json` (T4 `description`)
- `specs/state.json` (761 `description`, `last_updated`) and the regenerated `specs/TODO.md`
- `specs/761_ladder_realization_theorem/records/761-amendment.txt`
- `specs/761_ladder_realization_theorem/prototype/ladder-liveness-forward-only-proto.lean` (plan-time compiled oracle, already written)
- `specs/761_ladder_realization_theorem/summaries/01_ladder-realization-blocked-probe-summary.md`
- This plan, with Phase 1 `[BLOCKED]` at the return

## Rollback/Contingency

- Each executable phase is one to five files and commits per green substep (Phase 5 as one
  declared batch); reverting a phase is reverting its commit(s). If Phase 3's gate run fails on
  the new entry, remove the entry and row (the probe file stays, unwired) rather than weakening
  any statement.
- If the port does not compile, STOP and compare against the prototype line by line — it is a
  compiled oracle for every declaration (re-compiled at plan time, exit 0, zero warnings); do not
  re-derive proofs or substitute a different decomposition (`plan-compliance.md`). If a Challenge
  statement does not close as written, record the failure in the probe header as a further
  obstruction, mark Phase 2 `[BLOCKED]`, never a `sorry`, axiom, vacuous definition, or
  finite-fibre retreat.
- If `state-write.sh` is refused three times on the mutex, Phase 5 closes `[PARTIAL]` with the
  spec and records-file edits committed and the `state.json` step named as the remainder; the
  description amendment is then applied by the next dispatch, never by hand.
- Phase 1 is `[BLOCKED]` by design and by the user's ruling; it is never "unblocked" inside this
  task. Any `LadderCons`, `ladderCons_localRun`, `ladderRealized`, or `truncate` written under
  this task is a defect, not progress.
- The successor design — R2 (`/revise`: land `LadderRunCons` and `ladderRunCons_localRun`, the
  index-free, `box`/`stab`-free run-layer half, under an honest name with forward-only structural
  liveness and `slive` retained, ~250-350 lines plus pins, no consumer in the tree) or a
  research-first record for the index sub-problem (`/spawn`) — is the user's, as already ruled;
  the implementation's `partial` return with `requires_user_review: true` is the hand-back point.
