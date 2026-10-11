# Implementation Plan: Task #760

- **Task**: 760 - Ladder model, admissibility set Adm, and the cell-stabilization lemma ladderCell_stabilizes over both counters (c, n)
- **Status**: [IMPLEMENTING] (revised; Phases 1-4 closed as landed, Phases 5-9 added for the R2 salvage)
- **Effort**: 10 hours (4 spent in Phases 1-4; ~6 remaining in Phases 5-9)
- **Dependencies**: 758 (logical, positive verdict re-read), 759 (serialization only, README)
- **Research Inputs**:
  - specs/760_ladder_model_cell_stabilization_lemma/reports/01_ladder-cell-stabilization-refuted.md (integrated in plan 01, carried forward)
  - specs/760_ladder_model_cell_stabilization_lemma/.blocker-research.json (the measured solution path A-E; the one new input since plan 01)
  - specs/760_ladder_model_cell_stabilization_lemma/.decisions.json (ruling R1, cycle 1; ruling R2, cycle 3)
- **Artifacts**: plans/02_land-salvaged-ladder-model.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan 01 executed ruling R1: the filed deliverables were machine-refuted (F1 — `ladderFrame`'s
seriality hypotheses are unsatisfiable on the full carrier `Q × ℕ × ℕ`; F2 — on the repaired
carrier the realized cells do not stabilize in the counter pair past any bound), so Phase 1 stayed
`[BLOCKED]` and Phases 2-4 landed only the obstruction: the twelfth wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`, its wiring into
`scripts/check-evidence-probes.sh`, and the records in the RaySummary README and
`docs/theorem-index.md`. That work is committed and its full gate set is green; it is carried
forward unchanged.

The user has now ruled R2 (decisions file, cycle 3): land the salvaged, machine-checked general
declarations in the library. This revision adds Phases 5-9, which transplant the eleven
declarations that already exist proved and fully general over `{Q} [Finite Q] [Nonempty Q]`
inside the probe into a new `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean`,
wire that module into the two aggregators, re-point the probe at the library so its refutation is
about the LANDED `ladderModel` rather than a private copy of it, add the C14 pins at the two
synchronized sites, and record the result in the theorem index and the README. **There are zero
new proof obligations**: every transplanted declaration depends only on `RunLayer.lean` (`Rlad`,
`Rlad_fwd`, `Rlad_bwd`, `Count`) and `ofSlicedStepFinBranch*`, re-proves nothing, and carries no
fixture. Definition of done: the eleven declarations compile inside the library, are reachable
from the library root, are axiom-pinned at both C14 sites, carry theorem-index rows, and the
README reads `Adm` as DEFINED rather than named-and-undefined — with the full gate set green and
no new debt of any kind.

### Research Integration

Newly integrated input: `.blocker-research.json` (cycle 3). There are no new research reports;
`reports/01_ladder-cell-stabilization-refuted.md` predates plan 01 and is already integrated
there. The findings this revision acts on:

- **The salvage block is already machine-checked and already general.** Eleven declarations
  inside the landed probe are stated over `{Q : Type} [Finite Q] [Nonempty Q]` with no fixture
  and no `Q = Bool` specialization: `no_fwd`, `no_bwd_of_idle`, `Adm`, `LadderState` and its
  `Nonempty` instance, `RladAdm`, `RladAdm_fwd`, `RladAdm_bwd`, `ladderFrameAdm`,
  `ladderFrameAdm_isRegular`, `ladderModel`. Transplanting them is a copy plus wiring, not a
  proof effort. (Measured in the probe at plan time: the eleven sit in the probe's first two
  `/-!` sections, above the `## The two-state object` section that begins the fixture.)
- **The type shape must be fixed en route.** A sliced frame's world state is `ℤ × W`, so a ladder
  state is `(t, ⟨(q, c, n), h⟩)`. The originally filed `cellAt … (q, c, n) z` does not typecheck;
  the probe's declarations already carry the correct shape and the transplant inherits it. The
  `ℤ` component is invisible to the valuation and to `cellAt` (`cellAt_eq_cellAt`) but must be
  written.
- **Two flagged decisions, resolved as the research itself recommends — not re-opened.**
  (i) The fixture-bound F2 statements (`cell_ne`, `exhibited_form_refuted`,
  `exists_form_refuted`, and their several hundred lines of `Q = Bool` support) stay in the
  evidence probe; only the general F1 negatives and the general construction land in the library.
  Rationale: no witness fixture belongs inside a library module.
  (ii) `ladderFrame` stays in `RunLayer.lean` instance-free and C14-pinned; `ladderFrameAdm` is
  added ALONGSIDE it in the new module rather than repairing it in place. An in-place repair, or
  a sigma over `Adm`, remain equally valid alternatives that this record does not take and does
  not foreclose.
- **The C14 pins live at two synchronized sites.** `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`
  carries `/-- info: … -/` + `#guard_msgs` + `#print axioms` blocks (the existing
  `ladderFrame`/`ladderFrame_isRegular`/`ladderFrame_step` blocks at the file's tail are the
  pattern to follow); `scripts/check-module-invariants.sh` carries the `C14_BASELINE` and
  `C14LEAN` heredocs, compared by exact string equality, which must list the same declarations in
  the same order and be edited together. A declaration `#print axioms` reports as
  `does not depend on any axioms` contributes a line to NEITHER heredoc (the grep filter drops
  it) and must not be given one — the script's own `StarLanguage.StarAxiom` note records this.
- **What was lost, stated precisely, and nothing more.** `anchorCells_finite` and
  `anchorCells_ncard_le` are untouched: the SET of cells is still finite and bounded. What the
  refutation removes is only the computable index of WHICH cell a ladder state has — the
  deadline-class factor, not the cells factor. No replacement index is proved anywhere; the
  candidate `(q, min c B', min n B', clip (n − c))` is research-level and is asserted nowhere in
  this plan's deliverables.

### Guardrails (binding on every phase; carried into Phase 5's docstring checklist verbatim)

- (a) **No replacement index may be asserted anywhere.** The candidate
  `(q, min c B', min n B', clip (n − c))` is unproved; stating it as the index would file an
  unproved claim.
- (b) **Do not overstate the damage.** `anchorCells_finite` and `anchorCells_ncard_le` are
  untouched. Only the computable index of which cell a ladder state has is lost.
- (c) **No upper bound and no complexity claim anywhere.** Every quantity is a COUNT, under the
  same sentence the tree already attaches to `anchorCells_ncard_le`.
- (d) **Zero debt.** No `sorry`, no `axiom`, no vacuous definition (`def X := True` and friends
  are prohibited and equivalent to `sorry`), no cslib `require`, no external Büchi/MSO citation
  in place of a proof. `[BLOCKED]` with the obstruction recorded in this plan file is the honest
  outcome if something cannot be done.
- (e) **Direction-neutrality where it applies.** The refuted statement is direction-neutral and
  the witness is forward-only, as every probe in this collection is; say so where it applies.
- **Durable anchors only outside `specs/**`.** No task-number reference in any Lean file, doc,
  script, or README touched here (`.claude/rules/no-task-references-in-deliverables.md`; C9 gates
  this under `FormalSystem/`, `README.md` and `scripts/`), and no record-versioning language
  (`.claude/rules/no-record-versioning-in-deliverables.md`): the deliverables state the current
  design only, never their own draft history. The new module does not say "previously",
  "no longer", or "the filed statement was"; it states what the declarations are.

### Explicitly Out of Scope: Phase E of the Solution Path

The solution path's **phase E** — amending the dependent successor records to delete the refuted
index `Q × Fin (B+1) × Fin (B+1)` and record it as an open sub-problem — is **not planned here**.
It is owned by a separate child record, so that two records do not implement the same work and
the dependent records are amended once, by the record that owns them. This plan therefore touches
no successor record's description, and asserts no replacement for the deleted index (guardrail
(a)).

### Prior Plan Reference

`plans/01_ladder-cell-refutation-probe.md` — Phase 1 `[BLOCKED]` (the refuted filed statement),
Phases 2-4 `[COMPLETED]` and committed (74db0b789, e68775371, c691f3dba). Those four phase bodies
are carried into this plan with their status markers, timestamps, and verification records intact.

### Roadmap Alignment

`specs/ROADMAP.md` was supplied to this dispatch. This revision lands no new mathematics and
claims no roadmap item: the salvage is the frame-scheme construction on the admissible carrier,
which sits under requirement (W)'s obligation (i) beside `ladderFrame`, and obligation (ii)'s
first lemma stays refuted and open. No roadmap settled decision is amended.

## Goals & Non-Goals

**Goals**:
(The identifier set equals the four `theorem` declarations of the Lean Challenge Statements block
below. The definitional deliverables — `Adm`, `LadderState`, `ladderState_nonempty`, `RladAdm`,
`ladderFrameAdm`, `ladderFrameAdm_isRegular`, `ladderModel` — appear in that block as
`sorry`-bodied `abbrev` context with their bodies written out as the contract, because
`lean-challenge-snapshot.sh` counts only `theorem` declarations as Goals; they are deliverables of
Phase 5 all the same and the module is incomplete without them.)
- `no_fwd` — the forward seriality hypothesis of `ladderFrame` is unsatisfiable for every nonempty object.
- `no_bwd_of_idle` — the backward seriality hypothesis is unsatisfiable for every object with an idle state.
- `RladAdm_fwd` — the admissible ladder relation is forward finitely branching for every finite object.
- `RladAdm_bwd` — and backward finitely branching.

**Non-Goals**:
- **No new mathematics and no new proof.** Every transplanted body is the probe's, verbatim
  except for the three named adaptations in Phase 5. Re-deriving a proof instead of copying it is
  a defect (`plan-compliance.md`).
- **No fixture in a library module.** `cell_ne`, `exhibited_form_refuted`, `exists_form_refuted`,
  `stepB`, `pendB`, `fwdB`, `bwdB`, `F`, `M`, `labB`, `phi`, `w1`, `w2` and the whole `Q = Bool`
  support block stay in the evidence probe (flagged decision (i)).
- **No edit to `RunLayer.lean`.** `ladderFrame`, `ladderFrame_isRegular` and `ladderFrame_step`
  keep their statements, their docstrings and their C14 pins; `ladderFrameAdm` lands alongside
  them (flagged decision (ii)). No in-place repair, no sigma-over-`Adm` variant.
- **No positive stabilization lemma, in any form.** Phase 1's goals stay refuted; nothing in the
  new module states, assumes, or gestures at a repaired positive lemma or a replacement index.
- **No bound and no complexity claim** (guardrail (c)); nothing about `HitPresented`, nothing
  about `PlusValidZTime` in any form; `anchorCells_ncard_le` untouched.
- **No amendment to any successor record** (phase E, out of scope above).
- **No new `#print axioms`, `#eval`, or `#check` line under `FormalSystem/`** — C27 gates debug
  artifacts there against an allow-list; the axiom pins live in the test module and the invariant
  script, which is exactly why those two sites exist.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The probe keeps private copies of the eleven, so `Probe760.cell_ne` refutes a textually identical COPY of `ladderModel` and not the landed one — the record would not be about the declaration the library carries | H | M | Phase 7 deletes the eleven from the probe and re-points its fixture at the library's declarations (the probe already `open`s the RaySummary namespace); the probe's three remaining `#print axioms` lines and its header are amended to cite `RaySummary/LadderModel.lean` |
| An implementer "improves" a transplanted proof, or re-derives one | H | M | Phase 5's tasks are copy operations with the probe as a compiled oracle; the Challenge block pins the four theorem statements; `plan-compliance.md` forbids substituting a decomposition |
| The two C14 heredocs drift apart, or a line is written for a declaration that reports no axioms | H | M | Phase 8 edits `C14_BASELINE` and `C14LEAN` in one substep, appends matched pairs at the same trailing position, and takes every expected string from an actual `#print axioms` run rather than from this plan |
| `FormalSystem.lean` is hand-edited and C33's byte-for-byte comparison fails | M | M | Phase 6 regenerates it with `lake exe mk_all --lib FormalSystem` and confirms the new line landed between `…RaySummary.HitOf` and `…RaySummary.Present` (code-point order: `H` < `L` < `P`); hand-editing it is prohibited by C33's own note |
| C17's dead-declaration scan flags a new declaration nothing names outside its declaring line | M | M | Every one of the eleven is named by Phase 8's pins, Phase 9's theorem-index rows, the README module row, or the probe's header; Phase 9 reads C17's output in the gate run and records the count |
| C15's second assertion fails: a theorem-index row whose declaration carries no anchor | M | M | Phase 5 gives each declaration that gets a row a `Paper: —` line plus a reason in its own docstring, mirroring `ladderFrame_isRegular`'s idiom |
| C34's constraint-independence check fires on a new bracketed-binder declaration whose docstring reads as a constraint claim | M | L | Phase 5 mirrors `RunLayer.lean`'s docstring idiom, which carries no `Constraints consumed:` marker and passes today; Phase 6's and Phase 9's runs of `check-module-invariants.sh` report C34's verdict and the census |
| The expected axiom sets in this plan are stale or wrong | M | M | Every axiom value here is an expectation to be re-derived, flagged by the Scope Hypothesis lines in Phases 8 and 9; the heredocs and the `#guard_msgs` blocks are written from observed output |
| Scope creep into phase E or into a replacement index | H | L | Guardrail (a) and the out-of-scope section; Phase 9's header read-through checks the new module and the amended README for any index claim |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 2 |
| 5 | 6 | 5 |
| 6 | 7, 8 | 6 |
| 7 | 9 | 4, 7, 8 |

Phases within the same wave can execute in parallel. Phases 1-4 are closed (Phase 1 `[BLOCKED]`,
Phases 2-4 `[COMPLETED]` and committed) and are re-run by nothing. Phase 1 is a pre-decided
decision gate whose goals are refuted theorems; it requires no work, it is `[BLOCKED]` by the
user's R1 ruling, and **it is never a prerequisite of any executable phase**, so the final
phase's transitivity obligation is discharged through Phase 4 (which depends on 2 and 3) and
through 7 and 8 (which depend on 6, which depends on 5). Phase 9 is the final phase: it is a
terminal node, it depends transitively on every phase except the blocked gate, and its full-gate
verification re-observes every earlier phase's measurement.

### Phase 1: The Filed Statement — ladderModel over ladderFrame, Adm, ladderCell_stabilizes [BLOCKED]

- **Blocked**: 2026-10-11
- **Blocking Reason**: Refuted by machine-checked proof, landed as the twelfth wired probe:
  (F1) `ladderFrame`'s `fwd` hypothesis is unsatisfiable for every object and `bwd` for every
  object with an idle state (`no_fwd`, `no_bwd_of_idle`), so no `TaskModel` over `ladderFrame`
  can ever be applied and `Adm` must restrict the carrier; (F2) on the repaired carrier,
  `cellAt (a, B, B+1) ≠ cellAt (a, B, B+2)` for every `B` on the two-state object (`cell_ne`),
  refuting the exhibited-`B` form (`exhibited_form_refuted`) and the `∃ B` fallback
  (`exists_form_refuted`) alike. The contingency the design record (Section A) names for this
  case is `[BLOCKED]`, never a sorry, axiom, vacuous definition, trace-level hypothesis, or
  capped ladder. The user ruled R1 on 2026-10-11 (decisions file, cycle 1).
- **Blocked by**: the successor design, which is a user decision and not an agent-researchable
  question. The user has since ruled **R2** (cycle 3) on the salvage half of that decision — land
  the sound general by-products in the library — which is what Phases 5-9 execute. The refuted
  statement itself is not thereby unblocked: no positive stabilization lemma and no replacement
  index exist, and this phase's four goals remain unprovable as filed.

**Goal**: The filed deliverables, verbatim from the dispatch — recorded here as the goals that
could not be met, for the `blockers[]` entry the implementation returns:
- `def ladderModel (step : Q → Q → Bool) (pend : Q → Bool) (fwd) (bwd) (lab : Q → Atom → Bool) : TaskModel (ladderFrame step pend fwd bwd).toTaskFrame`
- the admissibility set `Adm` — "which objects supply `ladderFrame`'s `fwd`/`bwd`; a pending state at `c = 0` needs a discharging successor"
- `theorem ladderCell_stabilizes (φ : PlusFormula) … : ∀ (q : Q) (c c' n n' : ℕ) (z : ℤ), (plusSubformulaClosure φ).card ≤ c → … → cellAt (ladderModel …) φ (q, c, n) z = cellAt (ladderModel …) φ (q, c', n') z`, with fallback `∃ B : ℕ, ∀ q c c' n n' z, B ≤ c → … → cellAt … = cellAt …`

**Tasks** (none executable; each item is refuted or forbidden — left unchecked deliberately):
- [ ] `ladderModel` over `ladderFrame` — constructible, never applicable (F1). Phase 5 lands
      `ladderModel` over `ladderFrameAdm`, on the admissible carrier, which is a DIFFERENT frame
      and is not this goal met.
- [ ] `Adm` as an object-side condition — forced to be a carrier restriction (F1). Phase 5 lands
      `Adm` as that carrier restriction, which is the README's phrase honoured, not this goal met.
- [ ] `ladderCell_stabilizes`, exhibited-bound form — false (`exhibited_form_refuted`).
- [ ] `ladderCell_stabilizes`, `∃ B` fallback — false (`exists_form_refuted`).

**What was tried**: the statement's truth was tested before any bound shape was costed; both
findings were proved as theorems in three guard-routed compile rounds. **Goal state reached**:
none of the four items is provable as filed. **What unblocks**: nothing inside this record. A
repaired positive lemma over a three-coordinate index carrying the clipped gap is research-level
and is not costable here; it is asserted nowhere (guardrail (a)).

**Timing**: 0 hours (no work; pre-decided)

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: This phase edits no file; its only measurement is the compiled probe,
already observed green at plan time, by Phase 2's port, and by every later gate run, so no
cheaper or dearer tier applies.

**Files to modify**:
- none planned — this phase edits no file; the obstruction is landed by Phases 2-4 and the
  salvage by Phases 5-9.

**Verification**:
- The wired probe compiles through the guard with exit 0 (re-observed by Phases 7 and 9).
- This phase heading still reads `[BLOCKED]` when the implementation returns; it is never
  re-marked `[COMPLETED]`, `[COMPLETED WITH EXCLUSIONS]`, or `[PARTIAL]` by the implementer.
  Closing the record is the user's decision — see Rollback/Contingency.

---

### Phase 2: Author the Wired Refutation Probe [COMPLETED]

- **Completed**: 2026-10-11 (commit 74db0b789)

**Goal**: Create `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` — the
mandated header followed by the prototype's declarations under `namespace Probe760` — compiling
under `lake env lean` with no `sorry`, no axiom, no vacuous definition, and the five Challenge
statements of plan 01 verbatim.

**Tasks**:
- [x] Port the compiled prototype into the probe, header first, with the three ASCII renames
      (`phi`, `w1`, `w2`) and no statement change.
- [x] Compile through the build guard: exit 0, zero errors, zero warnings, the five
      `#print axioms` lines.
- [x] Confirm zero `sorry`, zero `axiom`, zero vacuous-definition pattern.

**Outcome**: landed as the twelfth wired probe, 564 lines. `no_fwd`, `cell_ne`,
`exhibited_form_refuted`, `exists_form_refuted` at `[propext, Classical.choice, Quot.sound]`;
`no_bwd_of_idle` at `[propext]`.

**Timing**: 1.5 hours (spent)

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: The edit was confined to one new file outside the build graph, covered by
`bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`
with its exit status checked.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` - created (the twelfth probe)

**Verification** (observed): guard exit 0, 0 errors, 0 warnings, five `#print axioms` lines as
planned; zero `sorry`/`axiom`/vacuous-definition hits.

---

### Phase 3: Wire the Probe into the Evidence Gate [COMPLETED]

- **Completed**: 2026-10-11 (commit e68775371)

**Goal**: The probe is compiled by the evidence gate on every run, not only by hand.

**Tasks**:
- [x] Add the probe's table row and its `WIRED` entry to `scripts/check-evidence-probes.sh`.
- [x] Run the gate and confirm every wired probe compiles.

**Outcome**: `check-evidence-probes.sh` reports PASS, all 30 wired probes compile.

**Timing**: 0.5 hours (spent)

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: The edit was confined to one script's probe list, covered by
`bash scripts/check-evidence-probes.sh` with its exit status checked.

**Files to modify**:
- `scripts/check-evidence-probes.sh` - one table row, one `WIRED` entry

**Verification** (observed): `check-evidence-probes.sh` PASS, all 30 wired probe(s) compile.

---

### Phase 4: Record the Obstruction in the README and Theorem Index, Run the Full Gate, Return Blocked [COMPLETED]

- **Completed**: 2026-10-11 (commit c691f3dba)

**Goal**: The RaySummary README and `docs/theorem-index.md` describe the state after the
refutation, and the full gate set is green.

**Tasks**:
- [x] Amend the README's Evidence section with the twelfth probe's paragraph and the four
      sentences that misdescribed the state.
- [x] Amend the `ladderFrame_isRegular` row of `docs/theorem-index.md`.
- [x] Run the full gate set.

**Outcome**: full gate green — guarded `lake build` exit 0 (2840 jobs, 0 errors);
`check-evidence-probes.sh` PASS (30 wired); `check-module-invariants.sh` exit 0 (55 PASS, 0 FAIL;
C9, C14, C15 green); `readme-lint.sh` PASS; `typst-sync-check.sh` PASS; `verify-deploy.sh` exit 0;
`check-task-references.sh` exit 0 over every touched file.

**Timing**: 2 hours (spent)

**Depends on**: 2, 3

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - one Evidence paragraph, four amended sentences, `Last verified` date
- `docs/theorem-index.md` - one amended clause in the `ladderFrame_isRegular` row

**Verification** (observed): as recorded under Outcome; the single vacuous-grep hit is a
pre-existing baseline theorem in `FormalSystem/Examples/TemporalStructures.lean`, identical at the
pre-dispatch commit, and 0 were introduced.

---

### Phase 5: Author RaySummary/LadderModel.lean — Transplant the Eleven General Declarations [NOT STARTED]

**Goal**: `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` exists and builds,
carrying the eleven declarations copied from the probe with no proof re-derived and no fixture
admitted.

**Tasks**:
- [ ] Create the file with the repository's standard copyright header (four lines, as
      `RunLayer.lean` carries it) and `import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer`.
      **`AnchorLayer` is NOT imported**: no transplanted declaration mentions `cellAt`, so the
      import would be unused.
- [ ] Write the module docstring. It states: what the module lands (the admissible ladder carrier
      and the frame and model over it, beside `RunLayer.lean`'s `ladderFrame`, which stays
      instance-free); that `ladderFrame`'s own seriality hypotheses are unsatisfiable, with
      `no_fwd`/`no_bwd_of_idle` cited as the reason `Adm` restricts the CARRIER; that the carrier
      restriction exhibited here is one of several equally valid shapes (in-place repair of
      `ladderFrame`, or a sigma over `Adm`, are alternatives not taken); that the slice
      `LadderState Q pend` is still infinite; that `[Finite Q]` is on the OBJECT only; that no
      realization theorem is claimed and the run layer's phase 2 remains open, with the
      stabilization statement in the counter pair refuted by the wired probe
      `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`; and the guardrail
      sentences — no index is claimed for a ladder cell (guardrail (a)); `anchorCells_finite` and
      `anchorCells_ncard_le` are untouched, so the SET of cells is still finite and bounded and
      only the computable index of WHICH cell a ladder state has is absent (guardrail (b)); every
      quantity named is a COUNT and no upper bound or complexity bound is claimed (guardrail (c));
      the refuted statement is direction-neutral and the witness refuting it is forward-only, as
      every probe in this collection is (guardrail (e)); nothing about `HitPresented`, nothing
      about `PlusValidZTime` in any form. **No task-number reference and no record-versioning
      phrasing** anywhere in the file.
- [ ] Open `namespace FormalSystem.Metalogic.Decidability.RaySummary` and copy the eleven
      declarations from the probe **verbatim**, in the probe's own order, which compiles:
      `no_fwd`, `no_bwd_of_idle` → `Adm`, `LadderState`, the `Nonempty (LadderState Q pend)`
      instance, `RladAdm`, `RladAdm_fwd`, `RladAdm_bwd`, `ladderFrameAdm`,
      `ladderFrameAdm_isRegular`, `ladderModel`. Keep each keyword as the probe has it
      (`theorem` / `def` / `abbrev` / `instance`) and each body character-for-character.
- [ ] Apply exactly **three adaptations**, and no others. (1) Name the anonymous `Nonempty`
      instance `ladderState_nonempty`, so it has a durable anchor for the C14 pin and the
      dead-declaration scan rather than an auto-generated name. (2) Give every declaration a
      docstring (the probe's where it has one; a new one-line docstring in the probe's register
      where it does not), mirroring `RunLayer.lean`'s idiom, and carry `Paper: —` plus a reason on
      the four declarations that get theorem-index rows in Phase 9 (`no_fwd`, `no_bwd_of_idle`,
      `ladderFrameAdm_isRegular`, `ladderModel`) — C15's second assertion requires the anchor at
      the declaration. (3) Add a one-clause note in `Adm`'s docstring distinguishing it from the
      admissible-proposition family also written `Adm` in `FormalSystem/QuantLanguage/`, which is
      an unrelated parameter in another namespace.
- [ ] Confirm by reading the file: no `sorry`, no `axiom`, no `def X := True`-shaped definition,
      no `#print axioms`/`#eval`/`#check`/`dbg_trace` line (C27 gates those under
      `FormalSystem/`), no `set_option` of any kind, no fixture declaration (`stepB`, `pendB`,
      `fwdB`, `bwdB`, `F`, `M`, `labB`, `phi`, `w1`, `w2`, `cell_ne` and the rest stay in the
      probe).
- [ ] Build the module through the guard and read its verdict from the guard, not from a pipe.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: The edit creates one new module and changes no existing signature, so the
covering check is
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderModel`
with the guard's own exit status checked; the module is not yet in the root closure, so nothing
else can observe it.

**Commit Mode**: per-substep

**Scope Hypothesis**: Eleven transplanted declarations, zero new proof obligations, one new file
and no other file touched. Carried from `.blocker-research.json`, which names the eleven; confirm
at implementation time by diffing the new module's declaration signatures (text up to `:=`)
against the probe's same-named declarations and against the Lean Challenge Statements block below,
and by `git status --short` showing exactly one new path.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` - created; header, module docstring, and the eleven transplanted declarations

**Verification**:
- Guarded `lake build` of the module exits 0 with 0 errors and 0 warnings.
- `grep -c 'sorry\|^axiom\|:= True$\|:= trivial$'` over the new file is 0 (each pattern checked).
- Every declaration signature matches the probe's same-named declaration and the Challenge block.
- The file names no task number and carries no record-versioning phrasing.

---

### Phase 6: Wire the Module into the Two Aggregators [NOT STARTED]

**Goal**: The new module is reachable from `lake build` and from `import FormalSystem`, and both
aggregators describe it.

**Tasks**:
- [ ] Add `import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel` to
      `FormalSystem/Metalogic/Decidability/RaySummary.lean`, **after** the `RunLayer` import (the
      list is ordered by layering, not alphabetically, and this module depends on `RunLayer`).
- [ ] Add the matching `* RaySummary.LadderModel — …` bullet to that file's `## Modules` list, in
      the same register as the `RunLayer` bullet: what it lands, `[Finite Q]` on the object only,
      the infinite slice, no realization theorem, nothing about `PlusValidZTime`.
- [ ] Regenerate the library root with `lake exe mk_all --lib FormalSystem`. **Do not hand-edit
      `FormalSystem.lean`** — C33 compares it byte-for-byte against the generator's output.
      Confirm the single added line sits between `…RaySummary.HitOf` and `…RaySummary.Present`
      (code-point order on the dotted name). If the generator cannot be run, insert the one line
      at that sorted position and treat C33's verdict as the authority.
- [ ] Build the library root through the guard and read the guard's verdict.
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and check its exit status: C4
      (imports resolve), C5, C8 (aggregator convention), C33 (byte-current root) and the INV
      inventory-block check all run build-free.

**Timing**: 0.75 hours

**Depends on**: 5

**Verification Tier**: interface

**Tier Justification**: The edit changes two aggregators' import lists, whose direct dependent set
is the library root closure, so the covering checks are
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (exit status read from
the guard) together with `bash scripts/check-module-invariants.sh --no-build` for C4/C5/C8/C33;
Gate 8's shell-suite battery and the rest of `verify-deploy.sh` are not reached by an import-list
edit and run in Phase 9.

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly one added import line per aggregator and one added `## Modules`
bullet — three edits across two files, plus the generated root. Confirm with
`git diff --stat` showing two source files and `FormalSystem.lean`, and with C33 passing.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` - one import after `RunLayer`; one `## Modules` bullet
- `FormalSystem.lean` - regenerated; one import line between `…RaySummary.HitOf` and `…RaySummary.Present`

**Verification**:
- Guarded full `lake build` exits 0 with 0 errors.
- `check-module-invariants.sh --no-build` exits 0; C4, C5, C8, C33 and INV all PASS.
- `lake exe mk_all --lib FormalSystem --check` agrees with C33 (run when the Lake cache is warm;
  a disagreement means the scanner drifted, not that the tree is wrong).

---

### Phase 7: Re-point the Evidence Probe at the Library Declarations [NOT STARTED]

**Goal**: The probe's refutation is about the LANDED declarations, not about a private copy of
them: the eleven are deleted from the probe and its fixture consumes the library's.

**Tasks**:
- [ ] Add `import FormalSystem.Metalogic.Decidability.RaySummary.LadderModel` to the probe,
      beside its existing `RunLayer`/`AnchorLayer` imports.
- [ ] Delete the probe's own copies of the eleven declarations. The probe already carries
      `open FormalSystem.Metalogic.Decidability.RaySummary`, so `Adm`, `LadderState`, `RladAdm`,
      `ladderFrameAdm`, `ladderModel` and the `Nonempty` instance resolve to the library's without
      any other edit to the fixture.
- [ ] Amend the probe header: the general block it used to declare now lives in
      `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` and is cited rather than
      redefined; the probe states and proves the fixture-bound refutation (`cell_ne`,
      `exhibited_form_refuted`, `exists_form_refuted`) over the library's `ladderModel`. Keep every
      existing guardrail sentence in the header: the carrier-restriction-of-this-shape phrasing,
      the forward-only sentence, the paper-level status of the past-looking twin, the no-bound and
      no-finiteness sentences, `anchorCells_ncard_le` untouched, `RunLayer.lean` not edited, and
      no successor design chosen. **No task-number reference** anywhere in the file.
- [ ] Reduce the trailing `#print axioms` block to the three fixture-bound theorems
      (`Probe760.cell_ne`, `Probe760.exhibited_form_refuted`, `Probe760.exists_form_refuted`) and
      amend the header's axiom-foot sentence to match. `no_fwd` and `no_bwd_of_idle` are now pinned
      at the two C14 sites (Phase 8), which is where a library declaration's axiom foot belongs.
- [ ] Compile the probe through the guard and confirm the three remaining theorem statements are
      character-for-character what they were (they mention `Adm pendB true`, which now resolves to
      the library's `Adm` with the identical body, so no statement changes).
- [ ] Re-run `bash scripts/check-evidence-probes.sh` and check its exit status.

**Timing**: 1 hour

**Depends on**: 6

**Verification Tier**: local

**Tier Justification**: The edit is confined to one file outside the build graph, covered by
`bash scripts/check-evidence-probes.sh` (which compiles every wired probe) with its exit status
checked, plus the guarded `lake env lean` compile of the probe itself.

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Eleven declarations deleted from the probe, one import added, two
`#print axioms` lines removed, and the header's citation and axiom-foot sentences amended — one
file, and the probe's line count falls by roughly the eleven declarations' span (measured from the
probe's first two `/-!` sections at implementation time, not from this figure). The three
remaining theorem statements are unchanged; confirm by diffing their signatures (text up to `:=`)
against the pre-edit file.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` - delete the eleven general declarations, add the `LadderModel` import, amend the header's citation and axiom-foot sentences, reduce the `#print axioms` block to three lines

**Verification**:
- Guarded `lake env lean` on the probe: exit 0, 0 errors, 0 warnings, three `#print axioms` lines.
- `check-evidence-probes.sh` exits 0 and reports all wired probes compiling.
- The three fixture-bound theorem signatures are byte-identical to their pre-edit form.
- Zero `sorry`/`axiom`/vacuous-definition hits in the probe.

---

### Phase 8: C14 Pins at the Two Synchronized Sites [NOT STARTED]

**Goal**: Every landed declaration's axiom foot is machine-asserted, at both sites, from observed
output.

**Tasks**:
- [ ] Run `#print axioms` for each of the eleven fully qualified names against the built library
      and record the exact output text. **Every expected value below is an expectation, not a
      fact**: take the strings from this run.
- [ ] `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`: append one
      `/-- info: … -/` + `#guard_msgs in` + `#print axioms …` block per declaration, following the
      existing `ladderFrame`/`ladderFrame_isRegular`/`ladderFrame_step` blocks at the file's tail
      exactly, including the wrapped-continuation form (`[propext,\n Classical.choice,\n Quot.sound]`)
      the elaborator emits for long lines. Declarations reported as
      `does not depend on any axioms` use that form, as the existing `Drift`/`Count`/`Rlad` blocks
      do. Amend the file's own module-docstring inventory sentence to name the new module's
      declarations beside the ladder's.
- [ ] `scripts/check-module-invariants.sh`: append matched pairs to `C14_BASELINE` and `C14LEAN`
      **in the same trailing position in both heredocs, edited in one substep** — they are compared
      by exact string equality. Planned pairs: the four declarations Phase 9 gives theorem-index
      rows (`no_fwd`, `no_bwd_of_idle`, `ladderFrameAdm_isRegular`, `ladderModel`). A declaration
      the run reports as `does not depend on any axioms` contributes a line to NEITHER heredoc and
      must be left out of both — the script's own `StarLanguage.StarAxiom` note records why
      inventing a baseline line for it can never match.
- [ ] Extend the comment block above `C14_BASELINE` with one sentence naming the new pairs and what
      they pin, in that block's established register: the admissible-carrier construction beside
      `ladderFrame`, a profile and not a decision procedure, no realization theorem claimed, no
      complexity bound.
- [ ] Build the test module through the guard (the `#guard_msgs` blocks are checked at elaboration)
      and then run `bash scripts/check-module-invariants.sh`, checking its exit status and reading
      C14's verdict, C17's dead-declaration count and C34's census.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: interface

**Tier Justification**: The edit changes one test module and one gate script's baselines, whose
dependents are exactly those two sites, so the covering checks are
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest.Metalogic.KTypeSummaryAxiomTest`
and `bash scripts/check-module-invariants.sh` with its exit status checked (C14's `#print axioms`
half needs the build and runs there).

**Commit Mode**: atomic-batch

**Scope Hypothesis**: Eleven `#guard_msgs` blocks in the test module and four matched heredoc
pairs in the invariant script. Both counts are hypotheses: the heredoc count drops by one for each
of the four that reports no axioms, and the planned axiom values
(`[propext, Classical.choice, Quot.sound]` for the `ofSlicedStepFinBranch`-derived declarations,
`[propext]` for `no_bwd_of_idle`) are carried from `.blocker-research.json` and from plan 01's
re-derived axiom foot — confirm by running `#print axioms` before writing either site, and never
by copying a value from this plan.

**Files to modify**:
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` - one `#guard_msgs` + `#print axioms` block per newly pinned declaration; one amended module-docstring inventory sentence
- `scripts/check-module-invariants.sh` - matched pairs appended to `C14_BASELINE` and `C14LEAN` in the same position; one sentence added to the comment block above them

**Verification**:
- Guarded build of `BimodalTest.Metalogic.KTypeSummaryAxiomTest` exits 0 (a wrong expected string
  fails `#guard_msgs` at elaboration).
- `check-module-invariants.sh` exits 0 with C14 PASS; C9 PASS (no task-number citation under
  `scripts/`); C17's and C34's outputs read and recorded.
- The two heredocs list the same declarations in the same order (diff the two extracted name lists).

---

### Phase 9: Theorem Index and README Records, Full Gate, Return [NOT STARTED]

**Goal**: The landed declarations are indexed and described, the README reads `Adm` as DEFINED,
and the full gate set is green.

**Tasks**:
- [ ] `docs/theorem-index.md`: add four rows in the Decidability section, after the
      `ladderFrame_isRegular` row. Columns per that table's contract: `Paper label` `—`;
      one-line Statement; fully qualified `Lean name`; `File`
      `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` (path only, no line
      numbers); `Frame class` `ZTime`; `Axioms` the value Phase 8 observed with its `pinned:C14`
      token (`pcq pinned:C14`, or the literal set written out, e.g. `[propext] pinned:C14`).
      The four: `no_fwd` and `no_bwd_of_idle` (the landed frame's seriality hypotheses are
      unsatisfiable — the frame has no instances and `Adm` must restrict the carrier);
      `ladderFrameAdm_isRegular` (the regular frame on the admissible carrier, `[Finite Q]` on the
      object only, infinite slice); `ladderModel` (the model whose valuation reads the object
      component). Each row's **What it is not** clause: no realization theorem, nothing about
      `HitPresented`, nothing about `PlusValidZTime` in any form, no complexity bound, and no index
      of a ladder cell claimed — the stabilization statement in the counter pair is refuted by the
      wired probe (guardrails (a), (c)).
- [ ] `FormalSystem/Metalogic/Decidability/RaySummary/README.md`:
      - add the `LadderModel.lean` module-table row with its line count measured by `wc -l` and a
        description in the table's register;
      - amend the sentences that currently read `Adm` as named-and-undefined so it reads as
        DEFINED and landed in `LadderModel.lean`, keeping the statement that on the FULL carrier no
        object supplies `fwd`/`bwd` and that `Adm` is therefore a restriction of the CARRIER;
      - amend the twelfth-probe paragraph so the general block is described as landed in the
        library and cited by the probe, with the fixture-bound refutation still the probe's;
      - amend the `(W)` requirement row's run-layer sentence to name the admissible-carrier
        construction beside `ladderFrame`, leaving obligation (ii) BLOCKED and uncosted;
      - keep every no-bound, no-finiteness, count-not-complexity and forward-only sentence intact;
      - update `Last verified`.
- [ ] Confirm `RunLayer.lean` is untouched by this dispatch (`git diff --stat` names it nowhere):
      `ladderFrame` stays instance-free and C14-pinned by decision (ii).
- [ ] Header and doc read-through against the guardrails: no replacement index asserted anywhere
      (a); `anchorCells_finite`/`anchorCells_ncard_le` described as untouched and the loss confined
      to the computable index (b); no upper bound and no complexity claim (c); zero debt (d);
      direction-neutrality stated where it applies (e); no task number and no record-versioning
      phrasing outside `specs/**`.
- [ ] Run the complete gate set and check each exit status: the guarded full `lake build`;
      `bash scripts/check-evidence-probes.sh`; `bash scripts/check-module-invariants.sh`;
      `bash scripts/readme-lint.sh`; `bash scripts/check-module-invariants.sh --emit-inventory --check`;
      `bash scripts/typst-sync-check.sh`; `bash scripts/check-task-references.sh` scoped to every
      touched file; `bash .claude/scripts/verify-deploy.sh`.
- [ ] Return: Phases 5-9 `[COMPLETED]`, Phase 1 still `[BLOCKED]`, so the implementation returns
      `partial` with `requires_user_review: true` per the Lean agent's Escalation Protocol — never
      `implemented` — with a `user_decision` asking whether to close the record (see
      Rollback/Contingency).

**Timing**: 1.5 hours

**Depends on**: 4, 7, 8

**Verification Tier**: full

**Files to modify**:
- `docs/theorem-index.md` - four new rows in the Decidability section
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - one module-table row, the amended `Adm` sentences, the amended twelfth-probe paragraph, the amended `(W)` row sentence, `Last verified`

**Verification**:
- Guarded full `lake build` exits 0 with 0 errors; `verify-deploy.sh` exits 0.
- `check-module-invariants.sh` exits 0 with C9, C14, C15, C33 PASS and no new C17 or C34 finding
  attributable to this dispatch.
- `check-evidence-probes.sh`, `readme-lint.sh`, `typst-sync-check.sh`, and the inventory
  `--check` run all exit 0.
- `check-task-references.sh` exits 0 over every file this dispatch touched.
- `grep` counts for `sorry`, `axiom`, and the vacuous-definition patterns over the new and
  amended Lean files are 0; the axiom-count baseline is unchanged except for the newly pinned
  declarations.
- Read-through: every guardrail sentence present, no replacement index asserted, `RunLayer.lean`
  untouched.

## Lean Challenge Statements

The four `theorem` declarations are the Goals and carry `sorry` bodies. Everything above them is
supporting context declared with `abbrev`, which `lean-challenge-snapshot.sh` neither counts as a
Goal nor rewrites — but it DOES swallow any non-`theorem` text sitting between two `theorem`
declarations into the preceding `:= sorry`, so every `abbrev` precedes the first `theorem`. The
definitional bodies (`Adm`, the carrier, the `Nonempty` witness, the relation, the frame, the
model) are part of the contract and are written out; the module itself declares them with
`def`/`abbrev`/`instance` exactly as the probe does, and the `abbrev` form here is for the
Challenge module only. Identifiers are ASCII, as the tool's regex requires.

The block declares into the real namespace `FormalSystem.Metalogic.Decidability.RaySummary`, so
`--check` compares against the working tree's same-named declarations. It therefore typechecks
standalone **before** Phase 5 lands these declarations and clashes with them afterwards by
construction; that is expected and is not a drift finding.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

namespace FormalSystem.Metalogic.Decidability.RaySummary

abbrev Adm {Q : Type} (pend : Q → Bool) (q : Q) : Set ℕ := {c | pend q = false → c = 0}

abbrev LadderState (Q : Type) (pend : Q → Bool) : Type :=
  {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}

abbrev ladderState_nonempty {Q : Type} [Nonempty Q] (pend : Q → Bool) :
    Nonempty (LadderState Q pend) :=
  ⟨⟨(Classical.arbitrary Q, 0, 0), fun _ => rfl⟩⟩

abbrev RladAdm {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) :
    ℤ → LadderState Q pend → LadderState Q pend → Prop :=
  fun t x y => Rlad step pend t x.1 y.1

abbrev ladderFrameAdm {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) : FrameOver intOrder :=
  ofSlicedStepFinBranch (RladAdm step pend) (RladAdm_fwd step pend) (RladAdm_bwd step pend) fwd bwd

abbrev ladderFrameAdm_isRegular {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) :
    (ladderFrameAdm step pend fwd bwd).IsRegular :=
  ofSlicedStepFinBranch_isRegular _ _ _ _ _

abbrev ladderModel {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool) :
    TaskModel (ladderFrameAdm step pend fwd bwd).toTaskFrame :=
  ⟨fun (w : ℤ × LadderState Q pend) p => lab w.2.1.1 p = true⟩

theorem no_fwd {Q : Type} [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    ¬ ∀ t x, ∃ y, Rlad step pend t x y := sorry

theorem no_bwd_of_idle {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (q : Q) (hq : pend q = false) :
    ¬ ∀ t x, ∃ y, Rlad step pend (t - 1) y x := sorry

theorem RladAdm_fwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    FwdFinBranch (RladAdm step pend) := sorry

theorem RladAdm_bwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    BwdFinBranch (RladAdm step pend) := sorry

end FormalSystem.Metalogic.Decidability.RaySummary
```

## Testing & Validation

- [ ] The new module builds through the guard with 0 errors and 0 warnings, and the guarded full
      `lake build` exits 0 after the aggregator wiring.
- [ ] No `sorry`, `axiom`, or vacuous-definition pattern in any file this dispatch creates or
      amends (grep count 0 per pattern); the repository's axiom-count baseline is unchanged except
      for the newly pinned declarations.
- [ ] `FormalSystem.lean` is byte-current (C33 PASS) with the new import between
      `…RaySummary.HitOf` and `…RaySummary.Present`.
- [ ] The eleven landed declarations' signatures match the Lean Challenge Statements block and the
      probe's same-named pre-edit declarations (`lean-challenge-snapshot.sh --check 760 .` as an
      advisory drift check).
- [ ] The probe compiles, carries three `#print axioms` lines, defines none of the eleven, and
      `check-evidence-probes.sh` exits 0 with every wired probe compiling.
- [ ] `KTypeSummaryAxiomTest.lean` elaborates with every new `#guard_msgs` block satisfied, and the
      two C14 heredocs list the same declarations in the same order.
- [ ] `check-module-invariants.sh` exits 0 with C4, C5, C8, C9, C14, C15, C33 and INV PASS; C17's
      and C34's outputs recorded rather than assumed.
- [ ] `readme-lint.sh`, `typst-sync-check.sh`, `verify-deploy.sh` and
      `check-task-references.sh` (scoped to touched files) all exit 0.
- [ ] Guardrail read-through: no replacement index anywhere; `anchorCells_finite` and
      `anchorCells_ncard_le` described as untouched; no upper bound or complexity claim;
      direction-neutrality stated where it applies; `RunLayer.lean` untouched; no task number and
      no record-versioning phrasing outside `specs/**`.
- [ ] Phase 1 still `[BLOCKED]`; return status `partial` with `requires_user_review: true` and the
      close-the-record decision surfaced.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` (new — the eleven transplanted declarations)
- `FormalSystem/Metalogic/Decidability/RaySummary.lean` (one import, one `## Modules` bullet)
- `FormalSystem.lean` (regenerated)
- `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` (re-pointed at the library; eleven declarations removed)
- `Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (new `#guard_msgs` + `#print axioms` blocks)
- `scripts/check-module-invariants.sh` (matched C14 heredoc pairs, one comment sentence)
- `docs/theorem-index.md` (four new rows)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (module row, amended sentences, `Last verified`)
- `specs/760_ladder_model_cell_stabilization_lemma/summaries/02_land-salvaged-ladder-model-summary.md`
- This plan, with Phases 5-9 marked at the return and Phase 1 still `[BLOCKED]`

## Rollback/Contingency

- Each executable phase is one or two files and commits per green substep (Phases 7 and 8 are
  declared `atomic-batch`, so their intermediate per-file states are expected red and are not
  committed); reverting a phase is reverting its commit(s). Phases 1-4 are already committed and
  are not revisited.
- If Phase 5's transplant does not compile, the probe is the compiled oracle for every one of the
  eleven declarations: compare line by line. Do not re-derive a proof, substitute a different
  decomposition, or weaken a statement (`plan-compliance.md`).
- If Phase 6's wiring breaks the build in a module this dispatch did not touch, revert the two
  import lines and the regenerated root (the new module stays, unwired) rather than editing the
  broken module — an unwired module that compiles is a smaller, honest state.
- If Phase 7's re-pointing cannot be made to compile (an unexpected resolution clash between the
  library's declarations and the probe's fixture), the fallback is to keep the probe's own copies
  and record in the probe header that its refutation is about a copy of the library's
  construction, then mark Phase 7 `[BLOCKED]` and raise it. This is a worse record and is a
  fallback, not an equal option.
- If Phase 8 cannot make a `#guard_msgs` block or a heredoc pair match, the cause is almost always
  the expected string, not the tree: re-read the observed `#print axioms` output. Never retune a
  baseline to make a divergence disappear — C14's own text calls a divergence a HARD STOP, not a
  new baseline.
- Zero-debt contingency, binding everywhere (guardrail (d)): if any step cannot be completed as
  written, mark the phase `[BLOCKED]`, record what was tried and the goal state reached in this
  plan file, and return `partial`. Never a `sorry`, an `axiom`, a vacuous definition, a cslib
  `require`, or an external citation in place of a proof.
- **Phase 1 and closing the record.** Phase 1 is `[BLOCKED]` by the user's R1 ruling and its goals
  are refuted theorems; it is never "unblocked" inside this record and the implementer never
  re-marks it. Once Phases 5-9 are green the only question left is whether to close the record,
  and that is the user's: either Phase 1 is re-marked `[COMPLETED WITH EXCLUSIONS]` with a
  `#### Reasoned Exclusions` record whose Evidence column cites the wired probe's own
  machine-checked theorems, or it stays `[BLOCKED]` as the standing record of the obstruction. The
  implementation surfaces this as a `user_decision` and changes nothing on its own authority.
- The open sub-problem — what index, if any, a ladder cell has — is recorded and owned elsewhere.
  It is not asserted, costed, or re-derived here (guardrail (a)); the separate child record that
  owns phase E amends the dependent records.
