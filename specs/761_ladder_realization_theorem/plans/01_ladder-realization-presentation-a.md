# Implementation Plan: Task #761

- **Task**: 761 - Ladder realization theorem: `LadderCons` and `ladderRealized` per ladder cell for all φ including box/stab letters
- **Status**: [IMPLEMENTING]
- **Effort**: 18 hours costable (Phases 1, 7-10, 13-15) + Phase 11 ~3 hours + Phase 12 NOT COSTABLE
- **Dependencies**: 760, 775, 805, 806, 819, 820 — all six discharged (760/775 archived; 805/806 `[COMPLETED]`; 819 the presentation decision; 820 the counter-lift gate table). No open edge remains.
- **Research Inputs**:
  - specs/761_ladder_realization_theorem/reports/01_ladder-realization-theorem.md
  - specs/761_ladder_realization_theorem/reports/02_spawn-analysis.md
  - specs/819_ladder_cell_presentation_design_decision/reports/01_ladder-cell-presentation-decision.md
  - specs/820_ladder_counter_lift_lemma_gated/summaries/01_counter-lift-gate-table-summary.md
- **Artifacts**: plans/01_ladder-realization-presentation-a.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The filed record asks for a library module carrying `LadderCons`, `ladderCons_localRun` and the
per-cell realization `ladderRealized` for ALL `φ`, `box`/`stab` letters included. The prior round
found the three declarations UNSTATABLE — `hitOf (truncate B …)` reached `[Fintype Q]` through an
index that `ladder-cell-refutation.lean` refutes and the carrier-repair record deleted — and
landed that obstruction as the thirteenth wired probe (Phases 2-6, all `[COMPLETED]`, preserved
below verbatim).

**Statability is now restored, and by a different object than the one that was deleted.** Two
predecessor records closed since: the presentation decision chose **(a), the set-valued per-state
datum** — the index is `D`, the maximum `certAdm`-certified subset of the finite carrier
`Q × ClType φ × K`; `ladderRealized` is the FIBRE EQUATION (`cellAt` at `(q, c, n)` equals `D`'s
fibre at `(q, κ (c, n))`); the factorization lemma for `K` is its COROLLARY, never its hypothesis;
and no tuple is stated as an index at any parameters, `K` being a carrier coordinate whose
parameters are outputs of the counter-lift lemma. And the counter-lift gate table compiled with
**both decision gates COLLIDING** (`gate9_col_cell_eq`, `gap_shift_cell_eq`, each an EQUALITY of
`cellAt` values with non-vacuity witnessed on both sides), so neither hazard is a seventh
mechanism, the ladder route is not closed, and the lemma's two halves are LICENSED in pumping
form. The positionwise statement shape is refuted for every finite counter quotient
(`no_positionwise_lift`), so the completeness clause must PUMP; the pin lemma's lift half
(`drift_extension_of_pins`, `exists_rlad_hist_of_walk`) is compiled and generic in `Q`, `step`,
`pend`.

Licensed is not proved. This task inherits the obligations: **(S)** soundness, **(C')**
completeness in pumping form, **(K1)-(K4)** the parameter sources, and the `certStab` rebuild per
`(q, κ)` with gate 8 still SIDESTEPPED. It also inherits one unglamorous prerequisite the
predecessors left standing: **the certificate layer exists only in evidence probes** — `ClType`,
`coh`/`cohBi`, `certAdm`, `certBiInf`, `Realizes` and the dovetailing theorem are declared in
`specs/evidence/seam-gluing-ray-product/*.lean`, and `grep -rln 'certAdm\|ClType' FormalSystem/`
hits nothing but the RaySummary README. A library module cannot import a probe, so promotion of
that layer into `FormalSystem/` is work this task must do before any of its own statements can be
written. The promotion is a PORT from compiled oracles, not discovery.

Definition of done: `ladderRealized` proved as the fibre equation for ALL `φ` with the
`box`/`stab` acceptance clause intact, over the admissible-carrier frame `ladderFrameAdm`, with no
`sorry`, axiom, vacuous definition, trace-level `Presented` hypothesis, finite-fibre or
finite-width assumption, and no tuple index stated at any parameters. The contingency is
unchanged: if a statement does not close, mark the phase `[BLOCKED]` with the goal state recorded.

### Research Integration

- **Statability (supersedes F1 of the prior round).** F1 said the statement line was a residue of
  a deleted object, and it was: `truncate` is defined nowhere. The fix is not a substitute index
  but a different statement — the fibre equation over `D`. `hitOf (truncate B …)` is withdrawn
  from the record (Phase 1); `[Fintype Q]` is no longer reached through any clipping of the
  carrier, and the finiteness that `D` needs is finiteness of `Q × ClType φ × K`, a Finset the
  module constructs, not of the ladder carrier (which stays infinite — `Rlad_slice_infinite`).
- **F2 and F3 of the prior round are untouched and are now DISCHARGED BY THE PRESENTATION, not
  worked around.** F2 said a per-cell object must carry a SET of types per ladder state; `D` is
  exactly that set-valued datum, which is why a tuple index alone was reported as incomplete and
  not proposed. F3 said the `box`/`stab` acceptance clause presupposes a per-cell store; `certBox`
  is the global bit (`box_mem_tpOf_iff`) and `certStab` is rebuilt per `(q, κ)`
  (`stab_mem_tpOf_iff` is per cell) in Phase 9. The clause is never dropped from any statement.
- **F4 (forward-only structural liveness) stands, machine-checked and landed.** `gPast_isPath`,
  `gPast_pending_past`, `gPast_count` are the thirteenth wired probe's theorems: a ladder history
  can be pending at every past time, so `Count` discharges `ulive` forward and never `slive`
  backward. `LadderCons` replaces `ulive` only and RETAINS `slive` as `Realize.lean`'s `SLive`
  deferral-graph condition over `Q`'s `step` (Phase 10).
- **Finding 1 of the presentation decision (compiled): the certified chains of record are
  REGION-INTERIOR.** `coh`/`cohBi` require `pend` at BOTH endpoints, and no forward `Rlad` ray is
  pending forever (`exists_idle_of_rlad_ray`, `no_rlad_ray_of_pending_forever`), so no `Realizes`
  chain is the object projection of any `Rlad` history. The label-level sufficiency
  `realizes_of_certAdm_cohBi` is sufficiency for the interior of ONE region; it transfers to the
  region segments of a ladder history and never to the history itself. The relation this task
  states over is therefore the IDLE-EXTENDED `cohBi` (the two `pend` conjuncts dropped, `R_K` on
  the `K` component), and composition across idle runs is what (S) and (C') buy.
- **Finding 2: the shape of `K` is forced, and it is a carrier coordinate.**
  `K = (min c T_c, c mod P, min n T_n, n mod P, clip (n - c) [-B, B])`, each coordinate forced by
  a compiled mechanism. This is NOT the refuted tuple re-proposed: `K` does not factor `cellAt` on
  its own (that is precisely the refuted claim), `D` does; `K`'s parameters are OUTPUTS of the
  counter-lift lemma, never inputs exhibited from the object or from the letters.
- **Finding 3: exactness, and Route A is not entered.** `D` must be the ACTUAL realizable set:
  with `R ⊊ Real` the `stab` bits computed against `R` are wrong. `Real` is itself certified given
  constancy of `cellAt` on `K`-classes, and every certified set lies inside it, so the MAXIMUM
  certified set is `Real` and is computable by enumeration over `Finset (Q × ClType φ × K)` — a
  count of candidates, no bound of any kind. Nothing decides generalized-Büchi nonemptiness.
- **The gate table (820), carried as the licence and as the limit.** SEPARATION at gates 1, 2 and
  9's n-side half; COLLISION at both decision gates; `no_positionwise_lift` refutes the
  positionwise statement shape for EVERY finite `K`; `short_idle_threshold_refuted` is why `T_c`
  must come from the cascade bound (`iter_doubling`) and not from the formula alone. A gate
  probing one coordinate certifies one coordinate: nothing in the table proves (S) or (C').
- **The parameter sources (K1)-(K4), carried verbatim as Phase 9's contract.** (K1) `P`: a common
  multiple of the cycle lengths of the certificate graph restricted to saturated classes
  (`prodPreN_eventually_periodic` is the set-level form). (K2) `T_c`: at least the cascade bound —
  the largest region countdown a rigid (all-exact) past can force, exponential in the number of
  pinned regions by `iter_doubling` — and at least the semantic periodicity threshold. (K3)
  Ordering: `T_n ≥ T_c + 2ℓ₀ - 1` for `ℓ₀` the longest shortest path between saturated states, and
  `T_c ≥ 2 T_short + T_idle + 2`. (K4) `B`: at least `2 d_back + 1` for the formula's backward
  exactness depth, and at least `2` (gate 1).
- **The stale blocker artifact is retired, not followed.** `.blocker-research.json` (2026-10-11)
  recommends gating the gap-carrying candidate that `ladder-cell-index-obstructions.lean` has
  since refuted. Phase 1 corrects it; no dispatch is to read it as live.
- **What is NOT in question and is not re-proved:** the SET of cells of any regular ℤ-model is
  finite and bounded (`anchorCells_finite`, `anchorCells_ncard_le`). Both stay untouched.

### Prior Plan Reference

`plans/01_ladder-realization-blocked-probe.md` is the plan this one revises. Its Phases 2-6 are
reproduced below VERBATIM, `[COMPLETED]`, as the record of the round that landed the thirteenth
wired probe and corrected the records; their internal cross-references to the then-`[BLOCKED]`
Phase 1 (including Phase 6's "the plan file's Phase 1 heading still reads `[BLOCKED]`" line) are
historical statements about that round and are not instructions to this one. Its Phase 1 is
revised here: the obstruction it recorded is discharged at the gate level, so the phase becomes
the executable record-correction step that retires the deleted statement line.

### Roadmap Alignment

`specs/ROADMAP.md` names this task THE critical path, un-gated, over the idle-extended `cohBi` on
`Q × ClType φ × K`, and 763 (the lift and the `Decidable (PlusValidZTime φ)` corollary) as waiting
on it alone. ROADMAP.md is NOT edited by this plan — the orchestrate conclusion regenerates it.
The task's GUARDRAILS (a)-(e) are carried into every phase's verification: (a) closure-indexed
letters over the time axis, `box`/`stab` bits included; (b) infinite width, no fibre bound; (c) no
upper bound — every quantity named is a count; (d) zero debt — no Büchi/MSO lemma cited in place
of a proof, no cslib require; (e) if the landed form is forward-only, say so, with no
device-discrimination claim.

## Goals & Non-Goals

**Goals**:
(The identifier set equals the five theorem declarations of the Lean Challenge Statements block
below. That block's `abbrev` definitions are context, not goals: they pin by position the objects
Phases 8-9 define. No other identifier is backticked in this block, because the snapshot tool
reads every backticked token here as a Goal.)
- `ladderSound` — obligation (S): every admissible ladder history projects to a member of the maximum certified subset at its own counter class, with its own closure type.
- `ladderLift` — obligation (C') in pumping form: every bi-infinite certificate chain through a class lifts to an admissible ladder history through any representative of that class, with the same closure type at the origin.
- `ladderCons_localRun` — every ladder run projects to a certificate chain inside a consistent bundle.
- `cellAt_const_of_kappa_eq` — the factorization lemma for the counter quotient, as a COROLLARY: cells agree on counter-class-equal states.
- `ladderRealized` — the fibre equation: the cell at an admissible ladder state is exactly the fibre of the maximum certified subset at that state's class, for ALL φ, box and stab letters included.

**Non-Goals**:
- No tuple index stated as a candidate at any parameters; `K` stays a carrier coordinate. No
  seventh coordinate. No `truncate`, under any reading.
- No `sorry`, axiom, vacuous definition, trace-level `Presented` hypothesis, finite-fibre or
  finite-width assumption, capped ladder, or weakened statement under a filed name
  (`plan-compliance.md`, Statement Fidelity). The `box`/`stab` acceptance clause is never dropped
  to make a structure writable.
- Route A (deciding generalized-Büchi nonemptiness) is NOT entered; the decision record is the
  presentation-decision report and its verdict stands.
- No complexity claim and no upper bound: the enumeration over `Finset (Q × ClType φ × K)` is a
  count of candidates, and `T_c`, `T_n`, `P`, `B` are counts.
- `anchorCells_finite` and `anchorCells_ncard_le` are not touched, re-proved, or strengthened.
- No edit to `specs/ROADMAP.md`, to 763's description, or to any archived predecessor's records.
- R2 (the index-free, `box`/`stab`-free run-layer half under an honest name) stays declined: it
  would not reach the `box`/`stab` letters this record needs.
- `presented_modelOf`, `Realize.lean` and `Trace.lean` are not re-proved; `ladderFrame` (the
  instance-free frame beside `ladderFrameAdm`) is untouched.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 12 ((C'), the pumping completeness) does not close, and an implementer weakens it to the positionwise form to make it provable | H | M | `no_positionwise_lift` is COMPILED: the positionwise form is false for every finite `K`, so a positionwise `ladderLift` would be a false statement, not a weaker one. The Challenge block pins the pumping shape; the contingency is `[BLOCKED]` with the goal state recorded, never a narrowed statement |
| The certificate-layer promotion (Phase 8) drifts from the probe's compiled definitions, so a ported proof stops working for an unrelated reason | H | M | The probe files are compiled oracles: port definitions byte-for-byte, rename only to resolve namespace collisions, and record every rename in the module header. Phase 8's verification diffs each promoted definition against its probe source |
| `D` is built as an under-approximation (any certified `R`) rather than the MAXIMUM certified subset, silently breaking the `stab` case | H | M | Finding 3 is the reason the maximum is required; Phase 9's `Dmax` is defined as the maximum and its maximality is a proof obligation of that phase, verified before Phase 11 consumes it |
| An implementer re-derives `K`'s parameters from the object or from the letters alone | H | M | Mechanisms (4), (5), (6) each refuted exactly that; (K1)-(K4) name the three sources and Phase 9's verification requires each parameter's definition to cite its source and to be an output of the periodicity fixpoint, not an exhibited constant |
| Phase 9's `certStab` is left at the probe's granularity (fibre over `q` in `Q × ClType φ`) | H | M | F2(a)/`cell_ne`: that granularity is wrong for the ladder. Phase 9 rebuilds it per `(q, κ)`; Phase 14's stab-bearing fixture is what exercises it (gate 8 is SIDESTEPPED until then) |
| Scope: three new library modules plus a `RunLayer.lean` edit is more library surface than the filed FILE SCOPE anticipated | M | H | Deliberate and recorded: the filed scope predates the discovery that the certificate layer is probe-only. The split keeps each module portable and reviewable; `Files to modify` below is the harvest source and the postflight file-scope widening notice will fire — expected, not a defect |
| 763 shares the RaySummary library set and could collide | M | L | 761 and 763 serialize through the edge between them; 763 waits on 761 alone and is not dispatched concurrently |
| Cross-set collisions on the shared records: README and `check-module-invariants.sh` (744), `typst/generated/status.typ` (410) | M | M | All edits are appended rows or single-sentence amendments; collisions left to the admission gate as the dispatch says — no edge is added |
| A record edit re-introduces the deleted index or states a cost figure | M | M | Guardrail (c); Phases 1 and 15 grep every touched record for `truncate`, `Fin (B+1)`, `min c B`, `clip (n`, and require each occurrence to sit inside a sentence naming it as deleted, refuted or research-level |
| A full `lake build` with three new modules exceeds a foreground tool call | M | H | Route every build through `lake-build-guard.sh` with an explicit `--timeout`; detach as a shell-level background job and block with the bounded single-call idiom per `context/patterns/bounded-build-waiter.md` — never `Bash(run_in_background: true)` |
| `typst-status-counts.sh` (pre-commit) regenerates `status.typ` with a diff | L | H | Library declarations DO change here, so a diff is expected; commit it with the phase that caused it and record the fact in the summary |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 4, 5 | 2 |
| 3 | 6 | 3, 4, 5 |
| 4 | 7, 8 | 1 |
| 5 | 9 | 8 |
| 6 | 10 | 9 |
| 7 | 11 | 10 |
| 8 | 12 | 7, 11 |
| 9 | 13 | 12 |
| 10 | 14 | 13 |
| 11 | 15 | 14 |

Phases within the same wave can execute in parallel. Waves 1-3 are the completed round (the
thirteenth wired probe and the record corrections) and are not re-run. Wave 4 onward is this
round: Phase 7 (the pin lemma port) and Phase 8 (the certificate-layer promotion) are independent
of each other and both only need Phase 1's corrected statement line; Phase 12 needs the pin lemma
(Phase 7) as well as (S) (Phase 11), which is the one cross-wave edge that is not simply
sequential. Phase 15 is the final phase.

### Phase 1: Retire the Deleted Statement Line and Record the Discharge [NOT STARTED]

**Goal**: Make the task's own records say what is now true — the three declarations are statable
in presentation (a)'s fibre form, every declared edge is discharged, and the 2026-10-11 blocker
artifact recommends a refuted candidate — so that no later phase and no future dispatch reads a
withdrawn statement line or a dead route as live.

**Tasks**:
- [ ] Correct `specs/761_ladder_realization_theorem/.blocker-research.json`: its `solution_path`
      recommends gating the gap-carrying candidate refuted by
      `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`
      (`exhibited_form_refuted`, `exists_form_refuted`, `cell_succ_ne`). Replace the
      recommendation with the landed state: presentation (a), the counter-lift lemma licensed in
      pumping form, and this plan as the live route. Write it through `state-write.sh`; never
      hand-edit under a held mutex.
- [ ] Amend the task description in `specs/state.json` (via `update-task-status.sh` /
      `state-write.sh`, scoped by `select(.project_number == 761)`) so the STATEMENT paragraph
      names the fibre equation instead of `hitOf (truncate B …)`, and records that all six edges
      are discharged. Regenerate `specs/TODO.md` with `generate-todo.sh`; never hand-edit it.
- [ ] Amend the design of record
      (`specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md`, Sections
      A and C) with one paragraph each: the statement line is the fibre equation over `D`; the
      factorization lemma for `K` is its corollary. If the archived path is read-only by
      convention, record the amendment in `specs/761_ladder_realization_theorem/records/` instead
      and name that choice in the phase handoff.
- [ ] Re-compile the `## Lean Challenge Statements` block below standalone through the build
      guard and confirm it still reports exactly twelve `declaration uses 'sorry'` warnings and
      zero errors (it did at plan time). Take the snapshot:
      `bash .claude/scripts/lean-challenge-snapshot.sh 761 .` so `--check` is available to later
      phases — the absence of a snapshot was a named follow-up of the predecessor record.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: Every change is a record edit plus one standalone Lean elaboration; the
covering check is the Challenge block's own compile plus `check-task-references.sh`, and no
library module is touched, so nothing dearer applies.

**Scope Hypothesis**: Four files change (the blocker artifact, `state.json`, `TODO.md`, and one
design-of-record or records file) plus the snapshot manifest the snapshot tool writes. If the
Challenge block does not re-compile to exactly twelve sorry warnings and zero errors, that is a
plan deviation to raise before Phase 8 starts, not a block to edit around.

**Files to modify**:
- `specs/761_ladder_realization_theorem/.blocker-research.json` - recommendation replaced with the landed route
- `specs/state.json` - 761's description paragraph; `last_updated`
- `specs/TODO.md` - regenerated, never hand-edited
- `specs/archive/757_lplus_decidability_successor_task_set/followup-scope-spec.md` - one amendment paragraph in each of Sections A and C (or the records fallback named above)

**Verification**:
- `grep -rn 'truncate' specs/761_ladder_realization_theorem/.blocker-research.json specs/state.json` returns no occurrence outside a sentence naming it as withdrawn.
- The Challenge block compiles standalone: exit 0, twelve `declaration uses 'sorry'` warnings, zero errors.
- `bash .claude/scripts/check-task-references.sh` reports 0 unexempted occurrences outside `specs/`.
- `jq -S` equality of every `state.json` entry other than 761 against HEAD.

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

---

### Phase 7: Promote the Pin Lemma's Lift Half into `RunLayer.lean` [NOT STARTED]

**Goal**: Make the counter half of the lift available to the library. The gate-table probe proved
`drift_extension_of_pins` and `exists_rlad_hist_of_walk` generically in `Q`, `step`, `pend`, and
its own record names moving them into `RunLayer.lean` as the successor's choice; a library module
cannot import a probe, so the port happens here.

**Tasks**:
- [ ] Port `pinCands`, `mem_pinCands`, `walkPin`, `drift_extension_of_pins` and
      `exists_rlad_hist_of_walk` from `specs/evidence/seam-gluing-ray-product/counter-lift-gates.lean`
      into `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean`, verbatim in statement,
      under the module's existing namespace. Port the proofs; do not re-derive them.
- [ ] Keep the probe's copies in place and unchanged — the evidence gate compiles them and the
      probe is the oracle. Add a one-line comment at the library site naming the probe file as
      the origin.
- [ ] Add nothing else to `RunLayer.lean`: `Count`, `Drift`, `Rlad` and their existing lemmas are
      untouched.

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: The port changes a module every downstream RaySummary module imports, so
the covering check is a guarded scoped build of the dependent modules rather than a local
elaboration of `RunLayer.lean` alone.

**Scope Hypothesis**: Five declarations move; `RunLayer.lean` is the only library file touched in
this phase. If a ported proof needs a lemma the probe had locally and the library does not, port
that lemma too and name it in the handoff rather than weakening the statement.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` - the pin lemma's lift half, five declarations

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.RunLayer` exits 0 with 0 warnings.
- The two headline signatures match the probe's token-for-token (`diff` of the extracted signature text).
- `lean-sorry-census.sh` count 0 over the resolved source roots; `grep -rn '^axiom '` unchanged from baseline.
- `bash scripts/check-evidence-probes.sh` still exits 0 (the probe's own copies still compile).

---

### Phase 8: Promote the Certificate Layer into the Library [NOT STARTED]

**Goal**: Create `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean` carrying the
`K`-free part of the certificate layer, so that the ladder module has a library-side object to
state over. Everything promoted here exists as a compiled probe declaration; this is a port.

**Tasks**:
- [ ] Port `ClType φ` (the closure-type carrier), `locCoh`, `untlLink`, `snceLink`, `coh` and
      `cohBi` from `realizable-type-certificate.lean` and
      `certificate-sufficiency-dovetailing.lean`, keeping statements verbatim and recording every
      rename forced by a namespace collision in the module header.
- [ ] Define the IDLE-EXTENDED relation as its own definition beside `cohBi` — `coh`'s two `pend`
      conjuncts dropped — with a docstring citing `exists_idle_of_rlad_ray` /
      `no_rlad_ray_of_pending_forever` for why the all-pending relation cannot be the ladder's:
      the certified chains of record are region-interior.
- [ ] Port the `K`-free certificate predicates `certLoc`, `certBiInf`, `certFwd`, `certBwd`,
      `certBox` and the existential-fulfilment fixpoint (`euLfp`) with its discharge lemma, plus
      `Realizes` and the dovetailing theorem `exists_dovetail_chain` and the label-level
      sufficiency `realizes_of_certAdm_cohBi`.
- [ ] Record in the module header, in one paragraph, the REGION-INTERIOR reading: this layer is
      sufficiency for the interior of one region, it transfers to the region segments of a ladder
      history, and it never applies to the history itself. Do not state a ladder consequence here.
- [ ] Wire the module: add the import to `FormalSystem/Metalogic/Decidability/RaySummary.lean`,
      to `FormalSystem.lean`, and the C14 heredoc entry in `scripts/check-module-invariants.sh`.

**Timing**: 3 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: A new module enters the library's import graph and the invariant script's
C14 list, so the covering check is a guarded scoped build plus `check-module-invariants.sh`, not a
local elaboration.

**Scope Hypothesis**: One new module plus three wiring files. The promoted set is the `K`-free
part only; `certStab` and `certAdm` are deliberately NOT promoted here, because both change shape
once `K` enters (Phase 9).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean` - new module, the K-free certificate layer
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import
- `FormalSystem.lean` - one import
- `scripts/check-module-invariants.sh` - one C14 heredoc entry

**Verification**:
- Guarded scoped build of `FormalSystem.Metalogic.Decidability.RaySummary.Certificate` exits 0, 0 warnings.
- Each promoted definition diffs clean against its probe source modulo the recorded renames.
- `bash scripts/check-module-invariants.sh` exits 0; `bash .claude/scripts/verify-deploy.sh` exits 0.
- The header's region-interior paragraph names both compiled theorems by name.
- No `sorry`, no `axiom`, no vacuous-definition pattern (grep count 0).

---

### Phase 9: The Counter Quotient `K`, Its Parameters, and the Maximum Certified Subset [NOT STARTED]

**Goal**: Create `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean`: the
finite counter quotient `K` of the forced shape, its parameters as OUTPUTS of the periodicity
fixpoint per (K1)-(K4), `certStab` rebuilt per `(q, κ)`, `certAdm` over the full carrier, and `D`
as the MAXIMUM certified subset with its maximality proved.

**Tasks**:
- [ ] Define `K T_c T_n P B` as `Fin (T_c+1) × Fin (P+1) × Fin (T_n+1) × Fin (P+1) × Fin (2B+1)`
      and `κ` as `(min c T_c, c mod P, min n T_n, n mod P, clip (n - c) [-B, B])`, with a
      docstring stating that `K` is a CARRIER COORDINATE and never an index: `K` does not factor
      `cellAt` on its own, `D` does.
- [ ] Define `R_K`, the image of `Count`/`Drift` on classes, and prove it decidable.
- [ ] Define each parameter as an output, each citing its source: `P` from (K1), a common
      multiple of the cycle lengths of the certificate graph restricted to saturated classes,
      via the set-level periodicity form `prodPreN_eventually_periodic`; `T_c` from (K2), at
      least the cascade bound (`iter_doubling`) and at least the semantic periodicity threshold;
      `T_n` and the ordering from (K3); `B` from (K4). No parameter may be an exhibited constant
      of the object or of the letters — mechanisms (4), (5) and (6) each refuted exactly that.
- [ ] Rebuild `certStab` per `(q, κ)` (`stab_mem_tpOf_iff` is per cell, so the probe's fibre over
      `q` in `Q × ClType φ` is the wrong granularity for the ladder — F2(a), `cell_ne`), and
      define `certAdm` over `Q × ClType φ × K` as the conjunction of the promoted predicates with
      the rebuilt `certStab` and `certBox`.
- [ ] Define `D` as the MAXIMUM `certAdm`-certified subset and prove maximality: the union of
      certified sets is certified, so the maximum exists; `D` is computable by enumeration over
      `Finset (Q × ClType φ × K)` — state this as a count of candidates, never a bound.
- [ ] Wire the module (RaySummary.lean, FormalSystem.lean, C14 heredoc).

**Timing**: 2.5 hours

**Depends on**: 8

**Verification Tier**: interface

**Tier Justification**: A second new module enters the import graph and the C14 list, and `D`'s
maximality is consumed by Phases 11-13, so a guarded scoped build plus the invariant script is
the covering check.

**Scope Hypothesis**: One new module plus three wiring files; five `K` coordinates and four
parameters, each with a named source. If a parameter cannot be derived as an output and only an
exhibited constant closes it, STOP: that is the refuted shape, and the phase is `[BLOCKED]`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` - new module: K, kappa, R_K, parameters, certStab per (q, kappa), certAdm, D and its maximality
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import
- `FormalSystem.lean` - one import
- `scripts/check-module-invariants.sh` - one C14 heredoc entry

**Verification**:
- Guarded scoped build exits 0, 0 warnings; `check-module-invariants.sh` exits 0.
- Each of `P`, `T_c`, `T_n`, `B` has a docstring naming its (K1)-(K4) source and its compiled anchor.
- `D`'s maximality is a proved theorem in the module, not an assumption of a later phase.
- No occurrence of a tuple-index claim of the form `index x = index y → cellAt x = cellAt y` anywhere in the module (grep for `cellAt` in the module returns only docstring mentions).
- No `sorry`, no `axiom`, no vacuous-definition pattern (grep count 0).

---

### Phase 10: `LadderCons` and `ladderCons_localRun` [NOT STARTED]

**Goal**: Create `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` with the
consistency bundle and the local-run theorem — the ladder analogue of `Realize.lean`'s `Cons` and
`cons_localRun`, with the liveness correction the thirteenth probe compiled.

**Tasks**:
- [ ] State `LadderCons (φ) (lab) (step) (pend) (R) : Prop` as `certAdm … R ∧ R` maximal, with
      the `box`/`stab` letters PINNED: `lab q (□ψ)` one global bit (`box_mem_tpOf_iff`), the
      `stab` letter per `(q, κ)` (`stab_mem_tpOf_iff`). The acceptance clause is part of the
      structure and is never dropped to make it writable.
- [ ] Replace `ulive` by the ladder's structural liveness (`c` strictly decreases while pending,
      by `Count`) and RETAIN `slive` as `Realize.lean`'s `SLive` deferral-graph condition over
      `Q`'s `step`. Cite the thirteenth probe (`gPast_isPath`, `gPast_pending_past`,
      `gPast_count`) in the docstring for why the backward half is not replaceable, and say so in
      the forward-only wording guardrail (e) requires — with no device-discrimination claim.
- [ ] Prove `ladderCons_localRun`: the projection of every admissible ladder history is a
      certificate chain lying inside `R`. Reuse `Realize.lean`'s transferable parts
      (`UCoh`, `deferGraph`, `Disch`, `persist`, `SCoh`, `bwdDeferGraph`, `SLive`,
      `snce_iff_of_SCoh_SLive` on the `Q`-projection); do not re-prove `presented_modelOf`,
      `run_seam_state` or `isRun_of_chain_seam`, none of which transfer.
- [ ] Wire the module (RaySummary.lean, FormalSystem.lean, C14 heredoc,
      `KTypeSummaryAxiomTest.lean`).

**Timing**: 2 hours

**Depends on**: 9

**Verification Tier**: interface

**Tier Justification**: The third new module enters the import graph, the C14 list and the axiom
test, so the covering check is a guarded scoped build plus the invariant script and the axiom
test, not a local elaboration.

**Scope Hypothesis**: One new module plus four wiring files; two declarations in this phase
(`LadderCons`, `ladderCons_localRun`), the remaining three Goals land in Phases 11-13.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - new module: LadderCons and ladderCons_localRun
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import
- `FormalSystem.lean` - one import
- `scripts/check-module-invariants.sh` - one C14 heredoc entry
- `KTypeSummaryAxiomTest.lean` - the new module's axiom-profile entries

**Verification**:
- Guarded scoped build exits 0, 0 warnings.
- `ladderCons_localRun`'s signature matches the Challenge block token-for-token; `lean-challenge-snapshot.sh --check 761 .` reports no drift (advisory).
- `LadderCons` carries the `box` AND `stab` clauses; `slive` appears in the structure and `ulive` does not.
- No `sorry`, no `axiom`, no vacuous-definition pattern (grep count 0).

---

### Phase 11: Obligation (S) — `ladderSound` [NOT STARTED]

**Goal**: Prove that every admissible ladder history projects into `D`: types by the truth
clauses and fulfilment along the history, `box` by `box_mem_tpOf_iff`, `stab` by
`stab_mem_tpOf_iff` at lower `stab`-depth.

**Tasks**:
- [ ] Prove the projection is a certificate chain: local coherence and the `untl`/`snce` links
      along an actual history, with the counter classes following `R_K` by `Count`/`Drift`.
- [ ] Prove forward and backward fulfilment along the history (both arms stay EXISTENTIAL —
      `ULive`/`SLive` are the wrong strength, per the sufficiency record).
- [ ] Discharge the `box` clause globally and the `stab` clause per `(q, κ)` by induction on
      `stab`-nesting depth, treating lower-depth `box`/`stab` letters as letters of `(q, κ)`.
- [ ] Conclude membership in `D` from certifiedness of the projection plus `D`'s maximality
      (Phase 9).

**Timing**: 3 hours

**Depends on**: 10

**Verification Tier**: interface

**Tier Justification**: The theorem is consumed by Phases 12-13 through the module interface, and
its axiom profile must be read, so a guarded scoped build plus `#print axioms` is the covering
check.

**Scope Hypothesis**: One Goal declaration plus its supporting lemmas, all inside
`LadderRealize.lean`. If the `stab` induction needs constancy of `cellAt` on `K`-classes — which
is Phase 13's corollary and would be circular here — stop and record the circularity in the
handoff; the licensed shape puts the `stab` clause at LOWER depth precisely to avoid it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderSound and its supporting lemmas

**Verification**:
- Guarded scoped build exits 0, 0 warnings; `ladderSound`'s signature matches the Challenge block.
- `#print axioms ladderSound` shows no `sorryAx`, no custom axiom, no `native_decide`.
- The `stab` step cites `stab_mem_tpOf_iff` and the depth induction explicitly; no finite-fibre or finite-width hypothesis appears in the statement or in any lemma it uses.

---

### Phase 12: Obligation (C') — `ladderLift`, the Pumping Completeness [NOT STARTED]

**Goal**: Prove the lift in PUMPING form: for every bi-infinite certificate chain `ξ` and every
`(c, n)` in `ξ 0`'s class there is an admissible ladder history through `(q, c, n)` whose
projection is a certificate chain agreeing with `ξ` at the origin, with the same closure type
there. This is the open mathematics of the record and the one phase that is not costable.

**Tasks**:
- [ ] State the theorem in the pumping form of the Challenge block. The POSITIONWISE form is
      REFUTED for every finite `K` and every `κ` (`no_positionwise_lift`, compiled): a
      positionwise `ladderLift` would be false, so narrowing to it is not a weaker statement but
      a wrong one.
- [ ] Identify the rigid anchors of `ξ` (exact `c`, exact `n`, exact gap) and prove that
      saturated segments between anchors can be replaced by certificate paths of other lengths in
      the same residue class, preserving local coherence and fulfilment.
- [ ] Iterate the replacement until the pin lemma's inequalities hold, then apply
      `exists_rlad_hist_of_walk` and `drift_extension_of_pins` (Phase 7) to produce the history,
      and the label-level sufficiency (Phase 8) on the resulting walk.
- [ ] Compose across idle runs using the compiled arithmetic: `forward_window`
      (`|L - n| ≤ c + j`), `backward_constraint` (`n ∈ [c-1, c+2s+1]`), `region_doubling`
      (`L' ≤ 2L + j + 1`) and `doubling_attained`. These are cited, not re-proved.

**Timing**: NOT COSTABLE. The predecessors that attempted comparable rounds closed in ~1-1.6
hours against ~9-hour estimates, and both returned refutations rather than positive lemmas; no
estimate is offered here, and none is to be invented by the implementer.

**Depends on**: 7, 11

**Verification Tier**: full

**Tier Justification**: This is the final mathematical obligation and it touches the whole
RaySummary import chain through `RunLayer.lean`'s new declarations and the two new certificate
modules at once; no cheaper tier covers the cross-module surface the replacement argument spans.

**Scope Hypothesis**: One Goal declaration plus its supporting lemmas, all inside
`LadderRealize.lean`. If the chain-replacement argument needs a seventh counter observable — a
mechanism not inside `K` — that is a REFUTATION of the licensed shape and a complete, reportable
outcome, not a failure: record it with the separating pair as a compiled theorem and mark the
phase `[BLOCKED]`.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - ladderLift and its supporting lemmas

**Verification**:
- Guarded scoped build exits 0, 0 warnings; `ladderLift`'s signature matches the Challenge block token-for-token.
- `#print axioms ladderLift` shows no `sorryAx`, no custom axiom, no `native_decide`.
- No positionwise completeness clause is stated anywhere in the module (grep).
- If the phase closes `[BLOCKED]`: the goal state reached is recorded in the phase body and in the handoff, with no `sorry`, axiom, vacuous definition, trace-level hypothesis, or finite-fibre retreat anywhere in the tree.

---

### Phase 13: The Factorization Corollary and `ladderRealized` [NOT STARTED]

**Goal**: Land the two remaining Goals: `cellAt_const_of_kappa_eq` (the factorization lemma for
`K`, as a COROLLARY of (S) and (C'), never as a hypothesis) and `ladderRealized` (the fibre
equation) for ALL `φ`, `box` and `stab` letters included.

**Tasks**:
- [ ] Prove `cellAt_const_of_kappa_eq` by induction on `stab`-nesting depth from `ladderSound` and
      `ladderLift`: a type in the cell at `(q, c, n)` projects into `D` at `(q, κ (c, n))` by (S),
      and lifts back to a history through `(q, c', n')` by (C') when the classes agree.
- [ ] Prove `ladderRealized` as the fibre equation: `⊆` by (S), `⊇` by (C'). The world state is
      `(t, ⟨(q, c, n), h⟩)` on `ℤ × LadderState Q pend`; the `ℤ` component is invisible to `cellAt`
      (`cellAt_eq_cellAt`) but must be written.
- [ ] State nothing about `HitPresented`, `PlusValidZTime`, or any bound; the enumeration count
      stays a count.

**Timing**: 2 hours

**Depends on**: 12

**Verification Tier**: interface

**Tier Justification**: Both theorems are the module's public surface and 763 consumes them, so a
guarded scoped build plus the axiom profile is the covering check.

**Scope Hypothesis**: Two Goal declarations inside `LadderRealize.lean`; no other file changes in
this phase.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` - cellAt_const_of_kappa_eq and ladderRealized

**Verification**:
- Guarded scoped build exits 0, 0 warnings; both signatures match the Challenge block token-for-token.
- `#print axioms` on both shows no `sorryAx`, no custom axiom, no `native_decide`.
- `ladderRealized` quantifies over ALL `φ` with no `box`/`stab`-free side condition anywhere in its statement or hypotheses.
- `anchorCells_finite` and `anchorCells_ncard_le` are unchanged (`git diff` on `AnchorLayer.lean` is empty).

---

### Phase 14: Gate 8 — Exercise the `stab` Clause on a `stab`-Bearing Fixture [NOT STARTED]

**Goal**: Gate 8 has been SIDESTEPPED at every round because no fixture's closure has a `stab`
member. Build one and exercise the rebuilt per-`(q, κ)` `certStab`, so the acceptance clause is
tested and not merely present.

**Tasks**:
- [ ] Author `specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean`: a small object
      whose closure carries a `⊡` member, with the cell computed on both sides of a `κ`-equal
      pair and the `certStab` biconditional exercised at `(q, κ)` granularity.
- [ ] Record the verdict in the header — PASSED or a separating pair — with the same discipline
      the gate table uses: non-vacuity witnessed on both sides before any equality is claimed, and
      "a gate probing one coordinate certifies one coordinate".
- [ ] Wire the probe into `scripts/check-evidence-probes.sh` (one table row, one `WIRED` entry).

**Timing**: 1.5 hours

**Depends on**: 13

**Verification Tier**: local

**Tier Justification**: The probe lives outside every Lake target root and imports only landed
modules, so its own `lake env lean` run plus the evidence-gate run is the covering check; no
library module changes.

**Scope Hypothesis**: One new probe file and one evidence-script entry. The wired-probe count
rises by one from whatever the gate reports at the start of this phase — read the count, do not
assume it.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean` - new wired probe exercising gate 8
- `scripts/check-evidence-probes.sh` - one table row, one WIRED entry

**Verification**:
- `lake env lean specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean` through the build guard: exit 0, 0 errors, 0 warnings.
- `bash scripts/check-evidence-probes.sh` exits 0 and reports every wired probe PASS.
- The header states the verdict and the non-vacuity witnesses; no `native_decide`.

---

### Phase 15: Records, the Full Gate, and the Summary [NOT STARTED]

**Goal**: Make every record say what landed, run the full gate, and close the task.

**Tasks**:
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`: one paragraph for the three new
      modules and the realization result, in (W)'s own terms, with the `Last verified` date. Cite
      declaration names and `specs/evidence/...` paths only — never a `specs/{NNN}_` path (C9) and
      never "task N".
- [ ] `docs/theorem-index.md`: rows for `ladderRealized`, `cellAt_const_of_kappa_eq`,
      `ladderSound`, `ladderLift`, and the amended `ladderModel` row.
- [ ] Regenerate `typst/generated/status.typ` (the pre-commit hook will do it; commit the diff
      with this phase and record it).
- [ ] Run the full gate: guarded full `lake build`; `check-evidence-probes.sh`;
      `check-module-invariants.sh`; `readme-lint.sh`; `typst-sync-check.sh`; `verify-deploy.sh`;
      `check-task-references.sh`; `lean-sorry-census.sh`; the axiom count against baseline;
      `validate-artifact.sh` on this plan.
- [ ] Write `summaries/01_ladder-realization-presentation-a-summary.md` naming, for each of (S),
      (C'), (K1)-(K4) and gate 8, what was proved and what remains; state the forward-only
      liveness fact in guardrail (e)'s precise sense; name every quantity as a count.

**Timing**: 1.5 hours

**Depends on**: 14

**Verification Tier**: full

**Tier Justification**: Final phase.

**Scope Hypothesis**: Three record files plus the summary. If `typst-status-counts.sh` produces a
diff beyond `status.typ`, stop and inspect rather than committing it blind.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - one paragraph, Last verified date
- `docs/theorem-index.md` - four new rows, one amended row
- `typst/generated/status.typ` - regenerated by the pre-commit hook
- `specs/761_ladder_realization_theorem/summaries/01_ladder-realization-presentation-a-summary.md` - new summary

**Verification**:
- Full guarded `lake build` exits 0 with 0 `error:` across both captured streams.
- `check-evidence-probes.sh`, `check-module-invariants.sh`, `readme-lint.sh`, `typst-sync-check.sh`, `verify-deploy.sh` all exit 0.
- `lean-sorry-census.sh` count 0; vacuous-definition grep count 0; axiom count unchanged from the dispatch's starting commit.
- `check-task-references.sh` reports 0 unexempted occurrences outside `specs/`.
- No new `truncate` / `Fin (B+1)` / clipped-gap occurrence in any touched file outside a sentence naming it as deleted, refuted or research-level.
- `git status --short` shows no stray modified files outside this plan's `Files to modify` set.

## Lean Challenge Statements

The five `theorem` declarations are the Goals and carry `sorry` bodies. Everything above them is
supporting context declared with `abbrev`, which the snapshot tool (`lean-challenge-snapshot.sh`)
neither counts as a Goal nor rewrites — but it DOES swallow any non-`theorem` text that sits
between two `theorem` declarations into the preceding `:= sorry`, so every `abbrev` must precede
the first `theorem`. The `abbrev`s pin BY POSITION ONLY the objects Phases 8-9 define: `ClType`,
`typeOfCl`, `kappa`, `certAdm`, `certChain`, `Dmax` and `LadderCons` carry `sorry` bodies here and
real definitions there. `CK` is written out, because its five-coordinate shape is forced by the
compiled mechanisms and is part of the contract; its four parameters are OUTPUTS, which is why
they are universally quantified arguments at every use site and never exhibited constants.
Identifiers are ASCII for the snapshot tool's regex.

This block was compiled standalone at plan time through the build guard
(`lake env lean`): exit 0, zero errors, exactly twelve `declaration uses 'sorry'` warnings (seven
`abbrev`, five `theorem`).

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe761A

abbrev ClType (phi : PlusFormula) : Type := sorry

abbrev typeOfCl {phi : PlusFormula} : ClType phi -> Finset PlusFormula := sorry

abbrev CK (Tc Tn P B : Nat) : Type :=
  Fin (Tc + 1) × Fin (P + 1) × Fin (Tn + 1) × Fin (P + 1) × Fin (2 * B + 1)

abbrev kappa (Tc Tn P B : Nat) : Nat × Nat -> CK Tc Tn P B := sorry

abbrev certAdm {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (R : Set (Q × ClType phi × CK Tc Tn P B)) : Prop := sorry

abbrev certChain {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (xi : Int -> Q × ClType phi × CK Tc Tn P B) : Prop := sorry

abbrev Dmax {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat) : Set (Q × ClType phi × CK Tc Tn P B) := sorry

abbrev LadderCons {Q : Type} (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (R : Set (Q × ClType phi × CK Tc Tn P B)) : Prop := sorry

theorem ladderSound {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame) (z : Int)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q)
    (hs : (sigma.state z).2 = ⟨(q, c, n), h⟩) :
    exists T : ClType phi,
      typeOfCl T = tpOf (ladderModel step pend fwd bwd lab) phi sigma z ∧
      (q, T, kappa Tc Tn P B (c, n)) ∈ Dmax step pend lab phi Tc Tn P B := sorry

theorem ladderLift {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (xi : Int -> Q × ClType phi × CK Tc Tn P B)
    (hxi : certChain step pend lab phi Tc Tn P B xi)
    (hmem : forall t, xi t ∈ Dmax step pend lab phi Tc Tn P B)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q)
    (h0 : (xi 0).1 = q) (hk : (xi 0).2.2 = kappa Tc Tn P B (c, n)) :
    exists sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame,
      (sigma.state 0).2 = ⟨(q, c, n), h⟩ ∧
      tpOf (ladderModel step pend fwd bwd lab) phi sigma 0 = typeOfCl (xi 0).2.1 := sorry

theorem ladderCons_localRun {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (R : Set (Q × ClType phi × CK Tc Tn P B))
    (hR : LadderCons step pend lab phi Tc Tn P B R)
    (sigma : WorldHistory (ladderFrameAdm step pend fwd bwd).toTaskFrame)
    (xi : Int -> Q × ClType phi × CK Tc Tn P B)
    (hproj : forall t, (xi t).1 = (sigma.state t).2.1.1 ∧
      typeOfCl (xi t).2.1 = tpOf (ladderModel step pend fwd bwd lab) phi sigma t ∧
      (xi t).2.2 = kappa Tc Tn P B ((sigma.state t).2.1.2.1, (sigma.state t).2.1.2.2)) :
    certChain step pend lab phi Tc Tn P B xi ∧ forall t, xi t ∈ R := sorry

theorem cellAt_const_of_kappa_eq {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (q : Q) (c n c' n' : Nat) (h : c ∈ Adm pend q) (h' : c' ∈ Adm pend q)
    (hk : kappa Tc Tn P B (c, n) = kappa Tc Tn P B (c', n')) (t z : Int) :
    cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
      = cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c', n'), h'⟩) z := sorry

theorem ladderRealized {Q : Type} [Fintype Q] [Nonempty Q]
    (step : Q -> Q -> Bool) (pend : Q -> Bool) (lab : Q -> Atom -> Bool)
    (fwd : forall t x, exists y, RladAdm step pend t x y)
    (bwd : forall t x, exists y, RladAdm step pend (t - 1) y x)
    (phi : PlusFormula) (Tc Tn P B : Nat)
    (q : Q) (c n : Nat) (h : c ∈ Adm pend q) (t z : Int) :
    cellAt (ladderModel step pend fwd bwd lab) phi (t, ⟨(q, c, n), h⟩) z
      = {T | exists S : ClType phi, typeOfCl S = T ∧
          (q, S, kappa Tc Tn P B (c, n)) ∈ Dmax step pend lab phi Tc Tn P B} := sorry

end Probe761A
```

## Testing & Validation

- [ ] The three new library modules and the amended `RunLayer.lean` compile through the build
      guard with 0 errors and 0 warnings, scoped per phase and once in full at Phase 15.
- [ ] `lean-sorry-census.sh` count 0 over the resolved source roots; vacuous-definition grep
      count 0; `grep -rn '^axiom '` unchanged from the dispatch's starting commit.
- [ ] Per-theorem `#print axioms` on all five Goals: no `sorryAx`, no custom axiom, no
      `native_decide`.
- [ ] The five Goal signatures match the Lean Challenge Statements block token-for-token;
      `lean-challenge-snapshot.sh --check 761 .` reports no drift (ADVISORY — a drift finding is
      a signal to investigate, never an automatic verdict).
- [ ] `check-evidence-probes.sh` exits 0 with every wired probe PASS, including the new gate-8
      probe.
- [ ] `check-module-invariants.sh`, `readme-lint.sh`, `typst-sync-check.sh`, `verify-deploy.sh`,
      `check-task-references.sh` all exit 0.
- [ ] Guardrail read-through of every header and record paragraph: closure-indexed letters with
      `box`/`stab` bits included; infinite width and no fibre bound; every quantity a count;
      zero debt; the forward-only liveness fact in its precise sense with no
      device-discrimination claim.
- [ ] No tuple index stated at any parameters anywhere in the library (grep for an
      `index x = index y → cellAt x = cellAt y` shape returns nothing outside a docstring naming
      it as refuted).
- [ ] `anchorCells_finite` and `anchorCells_ncard_le` untouched (`git diff` on `AnchorLayer.lean`
      is empty).

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/Certificate.lean` (new — the K-free certificate layer, promoted from the probes)
- `FormalSystem/Metalogic/Decidability/RaySummary/CounterQuotient.lean` (new — K, kappa, R_K, the parameters, certStab per (q, kappa), certAdm, Dmax)
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderRealize.lean` (new — LadderCons, ladderCons_localRun, ladderSound, ladderLift, cellAt_const_of_kappa_eq, ladderRealized)
- `FormalSystem/Metalogic/Decidability/RaySummary/RunLayer.lean` (the pin lemma's lift half, five declarations)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean`, `FormalSystem.lean`, `KTypeSummaryAxiomTest.lean`, `scripts/check-module-invariants.sh` (wiring)
- `specs/evidence/seam-gluing-ray-product/ladder-stab-acceptance.lean` (new, wired — gate 8) and `scripts/check-evidence-probes.sh`
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `docs/theorem-index.md`, `typst/generated/status.typ`
- `specs/761_ladder_realization_theorem/.blocker-research.json` (corrected), `specs/state.json`, `specs/TODO.md`
- `specs/761_ladder_realization_theorem/summaries/01_ladder-realization-presentation-a-summary.md`
- This plan

## Rollback/Contingency

- Each phase is one to five files and commits per green substep; reverting a phase is reverting
  its commit(s). The three new modules are additive: removing a module's import from
  `RaySummary.lean`, `FormalSystem.lean` and the C14 heredoc, and deleting the file, restores the
  tree.
- If a promoted definition does not compile in the library (Phases 7-8), compare line by line
  against the probe — it is a compiled oracle. Do not re-derive the proof and do not substitute a
  different decomposition (`plan-compliance.md`). Port the missing helper rather than weakening
  the statement.
- **Phase 12 is the contingency point.** If `ladderLift` does not close, mark Phase 12
  `[BLOCKED]` with the goal state recorded, return `partial` with `requires_user_review: true`,
  and leave Phases 13-15 `[NOT STARTED]`. Never a `sorry`, an axiom, a vacuous definition, a
  trace-level `Presented` hypothesis, a finite-fibre or finite-width assumption, a capped ladder,
  or a positionwise restatement — the positionwise form is refuted, so it is not a weaker
  statement but a false one. A refutation found in the course of the attempt (a seventh
  observable the `K` of the forced shape cannot see) is a COMPLETE and successful outcome if it is
  landed as a compiled separating pair with non-vacuity witnessed on both sides.
- If Phase 9 cannot derive a parameter as an output of the periodicity fixpoint and only an
  exhibited constant closes it, that is the refuted shape: mark Phase 9 `[BLOCKED]` rather than
  exhibiting the constant. Mechanisms (4), (5) and (6) are each a refutation of exactly that move.
- If `state-write.sh` is refused three times on the `specs/.scope-lock` mutex, Phase 1 closes
  `[PARTIAL]` with the record edits committed and the `state.json` step named as the remainder;
  the description amendment is then applied by the next dispatch, never by hand.
- A rollback that would discard uncommitted work takes a snapshot first: see
  `context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
  out-of-scope override for a deliberate whole-tree case.
