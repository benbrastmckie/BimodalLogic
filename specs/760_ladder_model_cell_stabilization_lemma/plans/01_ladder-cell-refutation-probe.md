# Implementation Plan: Task #760

- **Task**: 760 - Ladder model, admissibility set Adm, and the cell-stabilization lemma ladderCell_stabilizes over both counters (c, n)
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: 758 (logical, positive verdict re-read), 759 (serialization only, README)
- **Research Inputs**: specs/760_ladder_model_cell_stabilization_lemma/reports/01_ladder-cell-stabilization-refuted.md
- **Artifacts**: plans/01_ladder-cell-refutation-probe.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The filed record asked for a library module `RaySummary/LadderModel.lean` carrying `ladderModel`
over `ladderFrame`, the admissibility set `Adm`, and the stabilization lemma
`ladderCell_stabilizes` over both ladder counters. Research refuted it by machine-checked
prototype, in both filed forms and at the root: `ladderFrame`'s seriality hypotheses are
unsatisfiable on the full carrier `Q × ℕ × ℕ` for every object (F1), and on the repaired
carrier the stabilization statement is false for every bound `B` on the two-state object (F2).
The user has ruled (decisions file, cycle 1): **R1** — mark the lemma `[BLOCKED]` per the design
record's own contingency, land only the obstruction, create no library module, and leave the
successor design to the user via `/revise` or `/spawn`.

This plan therefore has one pre-decided `[BLOCKED]` phase (the filed statement, with its
obstruction recorded) and three executable phases that land the obstruction exactly as the
collection's tenth and eleventh probes landed theirs: port the compiled prototype
(`prototype/ladder-cell-refutation-proto.lean`, 488 lines by `wc -l`, re-compiled at plan time
through the build guard: exit 0, zero warnings, the five `#print axioms` lines as the report
states) into the twelfth wired probe `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`;
wire it into `scripts/check-evidence-probes.sh`; amend the RaySummary README and the
`docs/theorem-index.md` row that now misdescribe the state; run the full gate. The implementer
ports proofs; nothing is discovered, and no file under `FormalSystem/` other than the README is
touched. Because a phase stays `[BLOCKED]`, the implementation returns `partial` with
`requires_user_review: true` per the Lean agent's Escalation Protocol — never `implemented` — so
the task's resting state holds the filed successor chain (761, 762, 763 depend on this record's
index, which no longer exists).

### Research Integration

- **F1 (uninstantiability), carried into the probe verbatim.** `Rlad` carries the source clause
  `pend x.1 = false → x.2.1 = 0`, so the idle state `(q, 1, 0)` has no `Rlad`-successor and no
  predecessor, and when every state is pending `(q, 0, 0)` has no successor (`Count true true`
  demands `c' + 1 = 0`). Hence `¬ ∀ t x, ∃ y, Rlad step pend t x y` for EVERY object (`no_fwd`,
  `[Nonempty Q]` only) and `¬ ∀ t x, ∃ y, Rlad step pend (t - 1) y x` for every object with an
  idle state (`no_bwd_of_idle`). Deliverable (i) of the filed record — `ladderModel : TaskModel
  (ladderFrame …).toTaskFrame` — is constructible but can never be applied; `ladderFrame`,
  `ladderFrame_isRegular`, `ladderFrame_step` and the ninth probe's `ladder_isRegular` are
  theorems about a frame with no instances (the unsatisfiable-hypothesis form, not a `def := True`
  vacuity — the definitions are meaningful).
- **The repair the probe uses, generic in the object**: `Adm pend q := {c | pend q = false → c = 0}`
  (the README's own phrase "an admissibility restriction `c ∈ Adm q` on the ladder's carrier"),
  the carrier `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}`, `RladAdm` as
  `Rlad` on the underlying triples, two-sided finite branching by pulling `Rlad_fwd`/`Rlad_bwd`
  back along `Subtype.val` (`Set.Finite.preimage` with `Subtype.val_injective.injOn`, one line
  each), `ladderFrameAdm` via `ofSlicedStepFinBranch`, regularity from
  `ofSlicedStepFinBranch_isRegular` unchanged, `ladderModel` reading the object component. On this
  carrier `fwd`/`bwd` become satisfiable object conditions, discharged for `Q = Bool` (`fwdB`,
  `bwdB`). The probe's header says "a carrier restriction of this shape", never "the carrier":
  repairing `ladderFrame` in place, or a sigma over `Adm`, are equally valid and are the user's
  call (report Risks; decision D5 — `RunLayer.lean` is not edited).
- **F2 (refutation), carried verbatim.** Object `Q = Bool`, `pendB = id`, `stepB ≡ true`, `labB`
  reading `p` at `true` and `r` at `false`; `phi := p U (r ∧ X(p ∧ X r))` with `X χ := ⊥ U χ`
  (strict `untl` makes `X` the next-time operator, `truth_X`); `|cl phi| = 12` (`#eval`, carried
  from the report — CARRIED-UNVERIFIED at plan time, not load-bearing: no closure cardinality is
  computed inside any proof, decision D3). For every `B`: `cellAt M phi (w1 B) 0 ≠ cellAt M phi
  (w2 B) 0` with `w1 B = (0, ⟨(true, B, B+1), _⟩)` and `w2 B = (0, ⟨(true, B, B+2), _⟩)`
  (`cell_ne`); the exhibited form at `c = c' = |cl phi|`, `n = |cl phi| + 1`, `n' = |cl phi| + 2`
  (`exhibited_form_refuted`); the `∃ B` form because the witness is uniform in `B`
  (`exists_form_refuted`). Mechanism: the current deadline forces the region to end at `z + c`;
  the next-deadline counter at that idle lies in `[n - c - 1, n + c + 1]`; the GAP `n - c` is
  observable — the next region has length exactly one on some history through `(a, B, B+1)` and
  length ≥ 2 on every history through `(a, B, B+2)`. `Count`'s idle clause `c' = n` is exactly
  what makes the difference visible; "`c, c', n, n' ≥ B`" bounds each counter, not their
  difference. T1's positive verdict does not transfer: `Node` is one-region and has no
  next-deadline counter.
- **Type-shape note the implementer must honour**: a sliced frame's world state is `ℤ × W`, so a
  ladder state is `(t, ⟨(q, c, n), h⟩)`; the ℤ component is invisible to the valuation and to
  `cellAt` (`cellAt_eq_cellAt`), but it must be written. The filed statement's `cellAt … (q, c, n) z`
  does not typecheck as written.
- **Lemma order to port** (prototype order, which compiles): `no_fwd`, `no_bwd_of_idle` →
  `Adm`, `LadderState`, its `Nonempty` instance, `RladAdm`, `RladAdm_fwd`, `RladAdm_bwd`,
  `ladderFrameAdm`, `ladderFrameAdm_isRegular`, `ladderModel` → `stepB`, `pendB`, `rlad_iff`,
  `count_tt/tf/ft/ff`, `fwdB`, `bwdB`, `F`, its regularity instance, `pA`, `rA`, `pA_ne_rA`,
  `labB`, `M` → `p`, `r`, `X`, `phi` → `hist_path`, `hist_of_path`, section `Along`
  (`state_eq`, `truth_p`, `truth_r`), `truth_X` → section `Neg` (`pending_run`, `idle_at`,
  `after_idle`, `after_pending`), `not_phi_of_gap_two` → `futPos`, `gPos`, `futPos_adm`,
  `gPos_adm`, `gPosA`, `futPos_step`, `gPos_isPath`, `gPos_natCast`, `phi_pos` → `w1`,
  `gPosA_zero`, `w2`, `phi_not_mem_of_mem_cell₂`, `exists_phi_mem_cell₁`, `cell_ne`, `w1_eq`,
  `exhibited_form_refuted`, `exists_form_refuted` → five `#print axioms`.
- **Three renames, everything else verbatim**: the prototype's `φ`, `w₁`, `w₂` become `phi`,
  `w1`, `w2` in the probe (and `w₁_eq` becomes `w1_eq`). Reason: `lean-challenge-snapshot.sh`'s
  declaration regex is ASCII-only (`[A-Za-z_][A-Za-z0-9_']*`), so a Unicode-named declaration
  either escapes the identifier cross-check or is truncated (`w₁` reads as `w`); the Challenge
  block below uses the ASCII names, and the probe must match it for statement fidelity. No
  statement changes.
- **Tactic hazards named for the implementer** (report Tactic Survey; both fixed in the
  prototype — port the calls verbatim): (1) `omega` does not see `<` on `F.Duration` — the
  `untl` witness is ascribed `(s' : ℤ)` as in the fixture's `truth_Xp` idiom; (2) `simp [Count]`
  on a hypothesis carrying a `Nat` cast rewrites `↑(i+1)` to `↑i + 1` and breaks `omega`'s atoms —
  the prototype uses `rw [count_tt] at h` with the four concrete-Boolean lemmas instead; (3)
  `simp only [Prod.mk.injEq]` does not see through the `F.WorldState` abbreviation — use
  `congrArg (fun w : ℤ × LadderState _ _ => w.2.1) h` and `Prod.ext rfl (Subtype.ext _)`.
- **Axiom foot** (re-derived at plan time): `no_fwd`, `cell_ne`, `exhibited_form_refuted`,
  `exists_form_refuted` at `[propext, Classical.choice, Quot.sound]`; `no_bwd_of_idle` at
  `[propext]`. `Classical.choice` enters through `ofSlicedStepFinBranch_mem_HF_iff`, as the
  eighth to tenth probes already note.
- **A second, past-looking refutation exists at paper level only** (`snce ⊤ r` separates
  `(a, B+2, B)` from `(a, B, B)` because `n < c - 1` forces a pending-forever past). It is NOT
  machine-checked and nothing depends on it; the header mentions it as unverified and the probe
  states the direction-neutral statement is refuted by a forward-only witness, as every probe in
  this collection is.
- **Why this breaks the filed successor chain** (header and README wording): H4 (761) and H6
  (763) read the stabilization lemma's conclusion as "the cell at `(q, c, n)` is a function of
  `(q, min c B, min n B)`" and build the index `Q × Fin (B+1) × Fin (B+1)` on it. That function
  does not exist; whatever replaces it carries at least the clipped gap `n - c`, and the
  realization theorem's per-cell hypothesis must be re-stated over it. `anchorCells_finite` and
  `anchorCells_ncard_le` are untouched: the SET of cells is still finite and bounded; what is
  lost is the computable index of WHICH cell a ladder state has. R3 (a repaired positive lemma
  over `(q, min c B', min n B', clip (n - c))`) is research-level, not costable, and NOT this
  task's deliverable — recorded so nobody re-derives it.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied to this dispatch, so ROADMAP.md was not consulted. The task's
GUARDRAILS (a)-(e) are carried into Phase 2's header checklist verbatim.

## Goals & Non-Goals

**Goals**:
(The identifier set equals the five theorem declarations of the Lean Challenge Statements block below — the five negative theorems of the research report; the block's abbrev definitions, including the four supporting facts the probe also proves, are context, not goals.)
- `no_fwd` — the forward seriality hypothesis of the landed frame is unsatisfiable for every nonempty object.
- `no_bwd_of_idle` — the backward seriality hypothesis is unsatisfiable for every object with an idle state.
- `cell_ne` — for every B the cells at (a, B, B+1) and (a, B, B+2) differ: the refutation, uniform in B.
- `exhibited_form_refuted` — the filed exhibited-bound form, at this object and the pending state, is false.
- `exists_form_refuted` — the filed fallback form with an existential bound is false.

**Non-Goals**:
- No library module: `RaySummary/LadderModel.lean` is NOT created; `RaySummary.lean`,
  `FormalSystem.lean`, `KTypeSummaryAxiomTest.lean`, the C14 heredocs in
  `scripts/check-module-invariants.sh` and `RunLayer.lean` are untouched (decision D5; R2 is the
  user's option by `/revise`).
- No proof of the filed lemma over the landed `ladderFrame`: it closes there ONLY by
  unsatisfiable hypotheses (F1), which is the vacuity the zero-debt gate exists to refuse.
- No sorry, axiom, vacuous definition, trace-level `Presented` hypothesis, capped ladder
  (`Probe750.capped_carrier_finite` shows that carrier finite — the shape `not_finite_width_fmp`
  refutes), or weakened statement under the same name (`plan-compliance.md`, Statement Fidelity).
- No successor design: the probe exhibits "a carrier restriction of this shape"; whether
  `ladderFrame` is repaired in place or beside, and what statement replaces the stabilization
  lemma for 761-763, is the user's decision (`/revise` or `/spawn`), already so ruled.
- No machine-checked past-direction refutation; no claim about `⊡(Pp)`; nothing about
  `HitPresented`, `PlusValidZTime`, or any complexity bound.
- No edit to `RunLayer.lean`'s docstrings (they describe `ladderFrame` as the constructor of
  obligation (i); its hypotheses are unsatisfiable) — outside R1's scope, recorded in the README
  amendment instead.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| An implementer "proves" the filed lemma over `ladderFrame` — it typechecks and closes by hypotheses nobody can supply | H | M | The Challenge statements are the negatives; Phase 1 is pre-marked `[BLOCKED]`; the probe header and README say in words that `fwd`/`bwd` over the full carrier are unsatisfiable and cite `no_fwd` |
| The implementer returns `implemented` because Phases 2-4 all closed, dropping the hold on 761-763 | H | M | Phase 4's last task and the Rollback section restate the Lean agent's Escalation Protocol: any `[BLOCKED]` phase forces `partial` + `requires_user_review: true`; plan-level Status becomes `[BLOCKED]` |
| The subtype carrier is read as THE design | M | M | Header language fixed in Phase 2's checklist ("a carrier restriction of this shape"); README amendment names in-place repair and a sigma over `Adm` as equally valid, unchosen |
| Port drift: the three renames (`phi`, `w1`, `w2`) ripple into a statement change | M | L | Renames are identifier-only; Phase 2 verification diffs the five headline statements against the Challenge block; `lean-challenge-snapshot.sh --check 760 .` is available as an advisory drift check |
| `lake env lean` on the probe fails because `RunLayer.olean`/`AnchorLayer.olean` are stale while another session rebuilds | M | L | Compile through `lake-build-guard.sh build … -- env lean FILE` (as the prototype was); if an import is reported missing, wait on `lake-build-guard.sh status` rather than start a competing build |
| Cross-set collisions: `scripts/check-evidence-probes.sh` (734, `[PARTIAL]`), README (744, not started; 759 if re-opened), `typst/generated/status.typ` (410) | L | L | All edits are appended rows/paragraphs or single-sentence amendments; `git status` on every target is clean at plan time; collisions left to the admission gate as the dispatch says — no edge is added |
| README or theorem-index sentence trips C9 (`check-module-invariants.sh`) or the task-reference lint | M | L | Cite only `specs/evidence/...` paths, declaration names and section headings — never `specs/760_…` (C9 matches `specs/[0-9]{3}_`) or "task N"; no record-versioning language ("no longer", "previously") in the amended sentences — state the current fact |
| `file_scope` drift: the filed scope names `LadderModel.lean` and the C14 files (untouched under R1) and omits the probe and the evidence script (touched) | L | H | `Files to modify` below is the harvest source; the postflight file-scope widening notice will fire for the two added paths — expected, not a defect; the unused filed entries are harmless |
| The evidence-gate run (30 files) exceeds a foreground tool call | L | M | Run detached with a bounded waiter per `context/patterns/bounded-build-waiter.md`; it is a sequence of `lake env lean` calls, not a `lake build` |
| `typst-status-counts.sh` (pre-commit) regenerates `status.typ` with a diff | L | L | No library declaration changes under R1, so no diff is expected; if the hook regenerates it, commit it with Phase 4 and record the fact in the summary |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel. Phase 1 is a pre-decided decision gate whose
measurement (the compiled prototype) was taken at research time and is re-taken by Phase 2's
port and Phase 4's gate run; it requires no work and is `[BLOCKED]` at plan time, so it is never
a prerequisite of any executable phase. Phases 2, 3, 4 are the contingency branch the design
record names for exactly this outcome and run strictly in sequence. Phase 4 is the final phase:
it depends transitively on 2 and 3, and its full-gate verification re-observes Phase 1's
measurement through the wired probe.

### Phase 1: The Filed Statement — ladderModel over ladderFrame, Adm, ladderCell_stabilizes [BLOCKED]

- **Blocked**: 2026-10-11
- **Blocking Reason**: Refuted by machine-checked prototype (`prototype/ladder-cell-refutation-proto.lean`,
  re-compiled at plan time, exit 0): (F1) `ladderFrame`'s `fwd` hypothesis is unsatisfiable for
  every object and `bwd` for every object with an idle state (`Probe760.no_fwd`,
  `Probe760.no_bwd_of_idle`), so no `TaskModel` over `ladderFrame` can be applied and `Adm` must
  restrict the carrier; (F2) on the repaired carrier, `cellAt (a, B, B+1) ≠ cellAt (a, B, B+2)`
  for every `B` on the two-state object (`Probe760.cell_ne`), refuting the exhibited-`B` form
  (`exhibited_form_refuted`) and the `∃ B` fallback (`exists_form_refuted`) alike. The
  contingency the design record (Section A) and the dispatch name for this case is `[BLOCKED]`,
  never a sorry, axiom, vacuous definition, trace-level hypothesis, or capped ladder. The user
  ruled R1 on 2026-10-11 (decisions file, cycle 1).
- **Blocked by**: a user decision on the successor design, not by any agent-researchable
  question — whether `ladderFrame` is repaired in place (outside this task's file scope; changes
  a C14-pinned declaration and the ninth probe) or beside it, and what statement replaces the
  stabilization lemma for the realization record (the plausible true index carries a third,
  clipped coordinate `n - c` — R3 of the report, research-level, not costable).

**Goal**: The filed deliverables, verbatim from the dispatch — recorded here as the goals that
could not be met, for the `blockers[]` entry the implementation returns:
- `def ladderModel (step : Q → Q → Bool) (pend : Q → Bool) (fwd) (bwd) (lab : Q → Atom → Bool) : TaskModel (ladderFrame step pend fwd bwd).toTaskFrame`
- the admissibility set `Adm` — "which objects supply `ladderFrame`'s `fwd`/`bwd`; a pending state at `c = 0` needs a discharging successor"
- `theorem ladderCell_stabilizes (φ : PlusFormula) … : ∀ (q : Q) (c c' n n' : ℕ) (z : ℤ), (plusSubformulaClosure φ).card ≤ c → (plusSubformulaClosure φ).card ≤ c' → (plusSubformulaClosure φ).card ≤ n → (plusSubformulaClosure φ).card ≤ n' → cellAt (ladderModel …) φ (q, c, n) z = cellAt (ladderModel …) φ (q, c', n') z`, with fallback `∃ B : ℕ, ∀ q c c' n n' z, B ≤ c → … → cellAt … = cellAt …`

**Tasks** (none executable; each item is refuted or forbidden — left unchecked deliberately):
- [ ] `ladderModel` over `ladderFrame` — constructible, never applicable (F1); the probe builds the model over the repaired carrier instead, as evidence only.
- [ ] `Adm` as an object-side condition — forced to be a carrier restriction (F1); defined in the probe, not in the library (R1).
- [ ] `ladderCell_stabilizes`, exhibited-bound form — false (`exhibited_form_refuted`).
- [ ] `ladderCell_stabilizes`, `∃ B` fallback — false (`exists_form_refuted`).

**What was tried**: the statement's truth was tested before any bound shape was costed (report
decision D1); both findings were proved as theorems in three guard-routed compile rounds. **Goal
state reached**: none of the four items is provable as filed; the three sound by-products
(`Adm`/`LadderState`/`RladAdm` with finite branching, `ladderFrameAdm`, `ladderModel`) exist as
probe declarations. **What unblocks**: the user's successor design via `/revise` (R2: land the
sound parts and the negative theorem in `LadderModel.lean`) or `/spawn` (a research-first record
for a repaired positive lemma, R3).

**Timing**: 0 hours (no work; pre-decided)

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: This phase edits no file; its only measurement is
`bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/760_ladder_model_cell_stabilization_lemma/prototype/ladder-cell-refutation-proto.lean`
exiting 0 with the five `#print axioms` lines, already observed at plan time and re-observed by
Phase 2's port, so nothing cheaper or dearer applies.

**Files to modify**:
- none planned — this phase edits no file; the obstruction is landed by Phases 2-4.

**Verification**:
- The prototype compiles through the guard with exit 0 and the five axiom lines (plan-time: done).
- This phase heading still reads `[BLOCKED]` when the implementation returns; it is never
  re-marked `[COMPLETED]`, `[COMPLETED WITH EXCLUSIONS]`, or `[PARTIAL]` by the implementer.

---

### Phase 2: Author the Wired Refutation Probe [COMPLETED]

**Goal**: Create `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` — the
mandated header followed by the prototype's declarations under `namespace Probe760` — compiling
under `lake env lean` with no `sorry`, no axiom, no vacuous definition, and the five Challenge
statements verbatim.

**Tasks**:
- [x] Write the header docstring (`/- … -/`, before the imports, modeled on
      `node-cell-stabilization.lean`'s), containing in this order:
      - Title line: "Probe 760 (requirement (W)'s run layer, phase 2, first statement, over a
        general finite object): NEGATIVE — the landed frame's seriality hypotheses are
        unsatisfiable, and on the repaired carrier realized cells do NOT stabilize in the pair of
        ladder counters past any bound."
      - **What was asked**: the filed statement in both forms (exhibited `B := |cl φ|` and
        `∃ B`), the filed `ladderModel` over `ladderFrame`, and `Adm` as named in the README.
      - **F1, the frame cannot be instantiated**: `Rlad`'s source clause; `(q, 1, 0)` idle has no
        successor and no predecessor; all-pending `(q, 0, 0)` has no successor; `no_fwd`
        (`[Nonempty Q]` only), `no_bwd_of_idle`; consequence for `ladderFrame`,
        `ladderFrame_isRegular`, `ladderFrame_step` and the ninth probe's `ladder_isRegular`
        (theorems about a frame with no instances — the unsatisfiable-hypothesis form, not a
        `def := True` vacuity); "the README's own phrase is the fix".
      - **The carrier restriction used here, one of several equally valid**: `Adm`,
        `LadderState`, `RladAdm`, finite branching by `Set.Finite.preimage` along `Subtype.val`,
        `ladderFrameAdm` via `ofSlicedStepFinBranch`, regularity unchanged, `ladderModel`; the
        slice `LadderState Q pend` is still infinite; `fwd`/`bwd` become genuine object
        conditions (`fwdB`, `bwdB` for `Q = Bool`). Say "a carrier restriction of this shape";
        name in-place repair of `ladderFrame` and a sigma over `Adm` as alternatives not chosen
        here.
      - **What it establishes (F2)**: the object, the formula `phi := p U (r ∧ X(p ∧ X r))`,
        `X χ := ⊥ U χ`; the three refutation statements verbatim (`cell_ne`,
        `exhibited_form_refuted`, `exists_form_refuted`); the mechanism (region end at `z + c`;
        first idle's `n ∈ [n - c - 1, n + c + 1]`; the gap `n - c` observable; `Count`'s idle
        clause `c' = n` is what exposes it; T1 does not transfer — `Node` has no next-deadline
        counter).
      - **Type-shape note**: ladder states are `(t, ⟨(q, c, n), h⟩)`; the ℤ component is
        invisible to `cellAt` but must be written.
      - **What a true statement would have to say** (one paragraph, no claim): the plausible
        index is `(q, min c B', min n B', clip (n - c) [-B', B'])` — three clipped coordinates,
        not two; not claimed sufficient here; research-level.
      - **What this probe does NOT say** (guardrails (a)-(e)): (a) cells are closure-indexed
        SETS over the time axis, never one bit per depth; (b) the slice `Q × ℕ × ℕ` is infinite
        (`Rlad_slice_infinite`) and so is `LadderState`; the refutation bounds nothing — it bounds
        neither the index nor the fibre, it refutes a claimed index; (c) no upper bound of any
        kind, no complexity bound — `|cl phi| = 12` is a count; (d) zero debt — no external
        lemma, no cslib require; (e) the statement is direction-neutral and the witness is
        forward-only, as every probe in this collection is; a past-looking twin (`snce ⊤ r` at
        `(a, B+2, B)` vs `(a, B, B)`) is paper-level and NOT machine-checked here. Also: nothing
        about `HitPresented`, `PlusValidZTime`, or the successor design; `anchorCells_finite` and
        `anchorCells_ncard_le` untouched (the SET of cells is still finite and bounded; what is
        lost is the computable index of which cell a ladder state has); `RunLayer.lean` is not
        edited.
      - Axiom foot sentence ("`no_fwd`, `cell_ne`, `exhibited_form_refuted`,
        `exists_form_refuted` carry `[propext, Classical.choice, Quot.sound]`; `no_bwd_of_idle`
        carries `[propext]`; `Classical.choice` enters through
        `ofSlicedStepFinBranch_mem_HF_iff`") and the compile line
        `lake env lean specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`.
- [x] Imports and opens exactly as the prototype: `RaySummary.RunLayer` and
      `RaySummary.AnchorLayer`; the two `open` lines; `namespace Probe760`.
- [x] Port the prototype's declarations in the order listed under Research Integration, keeping
      names and statements, with exactly three identifier renames: `φ` → `phi`, `w₁` → `w1`,
      `w₂` → `w2` (and `w₁_eq` → `w1_eq`). Keep every docstring and the section structure
      (`Along`, `Neg`). Nothing else changes.
- [x] Close with `end Probe760` and `#print axioms` for `Probe760.no_fwd`,
      `Probe760.no_bwd_of_idle`, `Probe760.cell_ne`, `Probe760.exhibited_form_refuted`,
      `Probe760.exists_form_refuted`.
- [x] Compile through the guard:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`.
- [x] `git add` the new file (the gate's "tracked, not merely present" rule — Phase 3 fails
      otherwise) and commit per the green-substep mandate.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The probe is ~560-600 lines (prototype 488 lines by `wc -l`, re-derived at
plan time, minus its 30-line research header, plus an 80-110 line probe header). Confirm with
`wc -l` on the written file; a figure outside 530-650 is a signal to re-check that nothing was
dropped or duplicated, not a defect in itself.

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`
(through the build guard) exiting 0 is the complete covering check — the file sits outside the
Lake build graph, nothing imports it, and it modifies no library module, so no other compilation
unit can be affected.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` - new probe file (header + ported proofs)

**Verification**:
- The guarded `lake env lean` exits 0 with zero `error` lines and zero `warning` lines; the five
  `#print axioms` lines read `[propext, Classical.choice, Quot.sound]` for `no_fwd`, `cell_ne`,
  `exhibited_form_refuted`, `exists_form_refuted` and `[propext]` for `no_bwd_of_idle`.
- `grep -nE "sorry|^axiom |:= (True|Unit|trivial|Trivial)\s*$" specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`
  prints nothing.
- The five Goal declarations appear with exactly the signatures in `## Lean Challenge Statements`
  (docstrings may precede them); `bash .claude/scripts/lean-challenge-snapshot.sh --check 760 .`
  is available as an advisory drift check.
- Header read-through confirms every item in the first task's checklist is present, including
  "a carrier restriction of this shape", the forward-only sentence, the paper-level status of the
  past-looking twin, and the no-bound sentence.
- `git ls-files --error-unmatch specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` exits 0.

---

### Phase 3: Wire the Probe into the Evidence Gate [NOT STARTED]

**Goal**: Register the probe in `scripts/check-evidence-probes.sh` so the gate compiles it on
every run, with a table row recording what it holds in place.

**Tasks**:
- [ ] Add a table row in the `# --- WIRED ---` comment table, directly after the
      `seam-gluing-ray-product/hit-presented-node` row (the row block ends at the line before
      `WIRED=(`), in the same two-column `# probe | decision` wrapped format, headed
      `NEGATIVE VERDICT (requirement (W)'s run layer, "(W): what landed and what did not",
      obligation (ii) item 1, over a general finite object)` and stating: `ladderFrame`'s
      `fwd`/`bwd` hypotheses are unsatisfiable on the full carrier `Q × ℕ × ℕ` for every object
      (`no_fwd`, `no_bwd_of_idle`), so `Adm` is a carrier restriction (here `{x // x.2.1 ∈ Adm
      pend x.1}`, one of several equally valid shapes) and `ladderFrame` has no instances; on the
      repaired carrier the stabilization of realized cells in the counter pair `(c, n)` is FALSE
      for every bound on the two-state object (`cell_ne`; `exhibited_form_refuted`,
      `exists_form_refuted`), mechanism: the gap `n - c` is observable through
      `p U (r ∧ X(p ∧ X r))` because `Count`'s idle clause reads `c' = n`; what it does NOT say
      (forward-only witness for a direction-neutral statement; the past-looking twin
      paper-level; no bound of any kind; no finiteness; nothing about `HitPresented` or
      `PlusValidZTime`; the successor design not chosen; `anchorCells_ncard_le` untouched).
      Axioms `[propext, Classical.choice, Quot.sound]` (`no_bwd_of_idle` `[propext]`). No task
      number anywhere in the row — durable anchors only.
- [ ] Append `"seam-gluing-ray-product/ladder-cell-refutation"` to the `WIRED=(` array
      immediately after `"seam-gluing-ray-product/hit-presented-node"`.
- [ ] `bash -n scripts/check-evidence-probes.sh` (syntax) and then run the gate detached with a
      bounded waiter (`context/patterns/bounded-build-waiter.md`).
- [ ] Commit the script edit.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: At plan time `WIRED` has 28 entries and `WIRED_REPO` 1 (counted with
`awk '/^WIRED=\(/,/^\)/' … | grep -c '^  "'`), so the gate's PASS line should read
`PASS  all 30 wired probe(s) compile` after the edit. Confirm by re-counting both arrays before
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
  `seam-gluing-ray-product/ladder-cell-refutation … PASS` and the final line
  `PASS  all 30 wired probe(s) compile` (the count per the Scope Hypothesis).
- `bash .claude/scripts/check-task-references.sh --quiet scripts/check-evidence-probes.sh` exits 0.
- `git diff --staged --stat` shows only `scripts/check-evidence-probes.sh` for this phase's commit.

---

### Phase 4: Record the Obstruction in the README and Theorem Index, Run the Full Gate, Return Blocked [NOT STARTED]

**Goal**: Amend the five sentences that now misdescribe the state (four in the RaySummary README,
one in `docs/theorem-index.md`), add the twelfth-probe paragraph to the README's Evidence
section, run the complete repository gate set, and return with Phase 1 still `[BLOCKED]`.

**Tasks**:
- [ ] In `FormalSystem/Metalogic/Decidability/RaySummary/README.md`, `## Evidence`, insert ONE
      paragraph directly after the "An eleventh wired probe, …" paragraph and before "The
      permanent computability witnesses are …", of the shape: "A twelfth wired probe,
      `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`, is the run layer's
      phase-2 first statement over a general finite object, gate-compiled, and its verdict is
      NEGATIVE in both halves: `ladderFrame`'s seriality hypotheses are unsatisfiable on the full
      carrier `Q × ℕ × ℕ` for every object (`Probe760.no_fwd`, `no_bwd_of_idle` — the idle state
      `(q, 1, 0)` has neither successor nor predecessor under `Rlad`'s source clause), so the
      admissibility set `Adm` is a restriction of the carrier (`{c | pend q = false → c = 0}`,
      realized there on the subtype `{x // x.2.1 ∈ Adm pend x.1}` with two-sided finite branching
      pulled back along `Subtype.val` — one of several equally valid shapes, in-place repair of
      `ladderFrame` among them) and `ladderFrame` has no instances; and on that carrier the
      realized cells `cellAt` do NOT stabilize in the pair of counters `(c, n)` past any bound:
      on the two-state object with `p U (r ∧ X(p ∧ X r))`, `X χ := ⊥ U χ`, the cells at
      `(a, B, B+1)` and `(a, B, B+2)` differ for every `B` (`cell_ne`; `exhibited_form_refuted`,
      `exists_form_refuted`), because the current deadline fixes the region's end and `Count`'s
      idle clause `c' = n` exposes the gap `n - c`. Every theorem at
      `[propext, Classical.choice, Quot.sound]` or less, citing `RunLayer.lean` and
      `AnchorLayer.lean` and re-proving nothing — forward-only witness for a direction-neutral
      statement, no bound of any kind claimed, no finiteness added, `anchorCells_finite` and
      `anchorCells_ncard_le` untouched; what is refuted is the claimed computable index
      `Q × Fin (B+1) × Fin (B+1)` of which cell a ladder state has, and the successor design is
      not chosen here." Durable anchors only: no task number, no `specs/760_…` path, no
      record-versioning language.
- [ ] Same README, "(W): what landed and what did not", item 1 of "Open: obligation (ii)":
      replace the sentence "The stabilization of realized type sets in `c` past a bound syntactic
      in `φ` is plausible, unproved, and is phase 2's FIRST statement; until it is proved phase 2
      has no cost figure, and if it fails the honest outcome is `[BLOCKED]`, never a finite-fibre
      retreat." with a sentence stating the current fact: that stabilization in the counter pair
      `(c, n)` past a bound syntactic in `φ` is REFUTED by the twelfth wired probe in both the
      exhibited-bound and `∃ B` forms (the gap `n - c` is observable), that phase 2 is therefore
      `[BLOCKED]` as this record's own contingency prescribes, that the plausible true index
      carries a third clipped coordinate `n - c` and is not claimed, and that the design decision
      is open. Keep the rest of the item (the `Presented` prohibition) unchanged.
- [ ] Same README, the sentence ending "…is an admissibility restriction `c ∈ Adm q` on the
      ladder's carrier, named here and not costed; …": amend minimally to record that
      `ladderFrame`'s `fwd`/`bwd` are unsatisfiable on the full carrier for every object
      (twelfth wired probe, `no_fwd`), that `Adm` is therefore a restriction of the CARRIER
      (`{c | pend q = false → c = 0}`), defined in that probe and not in the library, and still
      not costed.
- [ ] Same README, `## The verdict` table, row (W), the parenthesis "(soundness: a stabilization
      lemma in the deadline counter, unproved; completeness: (C)'s general row, open)": amend
      "unproved" to state that the stabilization lemma in the pair of counters is refuted by the
      twelfth wired probe and phase 2 is `[BLOCKED]` on the successor design.
- [ ] `docs/theorem-index.md`, the `ladderFrame_isRegular` row: amend the clause "(the run
      layer's phase 2, whose first lemma — the stabilization of realized type sets in the deadline
      counter — is unproved)" to state that the first lemma is refuted in the filed form by the
      wired probe `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` (the gap
      between the two counters is observable) and that the frame's seriality hypotheses are
      unsatisfiable on the full carrier, so the frame has no instances and `Adm` is a carrier
      restriction; keep the count-not-complexity sentence of the row untouched. Do not touch the
      row's Declaration, File, Frame class, or `pinned:C14` cells.
- [ ] Update the README's trailing `*Last verified: YYYY-MM-DD*` line to the implementation date.
- [ ] Run the final gate set (below), detached where the pattern requires, and record each exit
      status in the summary. If the pre-commit hook regenerates `typst/generated/status.typ`,
      commit it with this phase and say so in the summary.
- [ ] Commit the README and theorem-index edits; write the implementation summary per
      `summary-format.md`, naming Phase 1's obstruction and the user's R1 ruling.
- [ ] Return per the Lean agent's Escalation Protocol, because Phase 1 is `[BLOCKED]`: set the
      plan-level `- **Status**:` to `[BLOCKED]` with a `- **Blocked**:` date line; write
      `.return-meta.json` with `status: "partial"`, `requires_user_review: true`,
      `blocked_phase: 1`, and a `review_reason` naming the successor-design decision; write the
      handoff with `status: "partial"`, `phases_completed: 3`, `phases_total: 4`, and one
      `blockers[]` entry for Phase 1 carrying the three verbatim goal lines above, with
      `why_it_failed` stating that the goals are refuted theorems and the remaining choice is the
      user's (not researchable). NEVER return `implemented`.

**Timing**: 2 hours

**Depends on**: 2, 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly five amended sentences (four README, one theorem-index) plus one
new README paragraph and the `Last verified` line; confirm with `git diff --stat` showing only
`FormalSystem/Metalogic/Decidability/RaySummary/README.md` and `docs/theorem-index.md` (and
`typst/generated/status.typ` only if the hook regenerated it) and a README hunk count of 6.
`grep -c 'unproved' FormalSystem/Metalogic/Decidability/RaySummary/README.md` should drop by
exactly 2 (plan-time baseline: re-count before editing).

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - Evidence paragraph (new); item 1 of "(W): what landed and what did not"; the `Adm` sentence; the verdict-table (W) row parenthesis; `Last verified` date
- `docs/theorem-index.md` - the `ladderFrame_isRegular` row's "What it is not" clause
- `typst/generated/status.typ` - only if regenerated by the pre-commit hook (no diff expected)

**Verification** (the complete gate set — every command's exit status is checked, never only its
output):
- `bash .claude/scripts/lake-build-guard.sh build --timeout 600 -- env lean specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`
  exits 0 (re-run after all commits; five `#print axioms` lines as in Phase 2).
- `bash scripts/check-evidence-probes.sh` exits 0 with `PASS  all 30 wired probe(s) compile`.
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
- `bash .claude/scripts/lean-challenge-snapshot.sh --check 760 .` reports no drift (advisory).
- `git status --short` shows no stray modified files outside this plan's `Files to modify` set.
- The plan file's Phase 1 heading still reads `[BLOCKED]`; the return status is `partial`, not
  `implemented`.

## Lean Challenge Statements

The five `theorem` declarations are the Goals and carry `sorry` bodies. Everything above them
is supporting context declared with `abbrev`, which the snapshot tool (`lean-challenge-snapshot.sh`)
neither counts as a Goal nor rewrites — but it DOES swallow any non-`theorem` text that sits
between two `theorem` declarations into the preceding `:= sorry`, so every `abbrev` must precede
the first `theorem`. That ordering is why the four supporting facts the probe proves as theorems
(`RladAdm_fwd`, `RladAdm_bwd`, `fwdB`, `bwdB`) appear here as `sorry`-bodied `abbrev`s: they are
not Goals, their statements are pinned by position only, and the probe proves them in full. The
definitional bodies (`Adm`, the carrier, the object, the formula, the two states) are part of the
contract and are written out. The probe itself uses `def`/`theorem` for all of these, exactly as
the prototype does — the `abbrev` form is for the Challenge module only. Identifiers are ASCII
(`phi`, `w1`, `w2`) for the snapshot tool's regex; the probe uses the same names. This block was
assembled by the tool's `--dry-run` and compiled through the build guard at plan time.

```lean
import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability.RaySummary

namespace Probe760

abbrev Adm {Q : Type} (pend : Q → Bool) (q : Q) : Set ℕ := {c | pend q = false → c = 0}

abbrev LadderState (Q : Type) (pend : Q → Bool) : Type :=
  {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}

instance {Q : Type} [Nonempty Q] (pend : Q → Bool) : Nonempty (LadderState Q pend) :=
  ⟨⟨(Classical.arbitrary Q, 0, 0), fun _ => rfl⟩⟩

abbrev RladAdm {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) :
    ℤ → LadderState Q pend → LadderState Q pend → Prop :=
  fun t x y => Rlad step pend t x.1 y.1

-- Proved as theorems in the probe; `abbrev` here only so the snapshot tool keeps the ordering.
abbrev RladAdm_fwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    FwdFinBranch (RladAdm step pend) := sorry

abbrev RladAdm_bwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    BwdFinBranch (RladAdm step pend) := sorry

abbrev ladderFrameAdm {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) : FrameOver intOrder :=
  ofSlicedStepFinBranch (RladAdm step pend) (RladAdm_fwd step pend) (RladAdm_bwd step pend) fwd bwd

abbrev ladderModel {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool) :
    TaskModel (ladderFrameAdm step pend fwd bwd).toTaskFrame :=
  ⟨fun (w : ℤ × LadderState Q pend) p => lab w.2.1.1 p = true⟩

abbrev stepB : Bool → Bool → Bool := fun _ _ => true
abbrev pendB : Bool → Bool := fun q => q

-- Proved as theorems in the probe (the two-state object supplies both seriality conditions).
abbrev fwdB : ∀ t x, ∃ y, RladAdm stepB pendB t x y := sorry
abbrev bwdB : ∀ t x, ∃ y, RladAdm stepB pendB (t - 1) y x := sorry

abbrev F : FrameOver intOrder := ladderFrameAdm stepB pendB fwdB bwdB

abbrev pA : Atom := ⟨"p", none⟩
abbrev rA : Atom := ⟨"r", none⟩

abbrev labB : Bool → Atom → Bool := fun q a => if a = pA then q else if a = rA then !q else false

abbrev M : TaskModel F.toTaskFrame := ladderModel stepB pendB fwdB bwdB labB

abbrev p : PlusFormula := .atom pA
abbrev r : PlusFormula := .atom rA
abbrev X (χ : PlusFormula) : PlusFormula := .untl .bot χ
abbrev phi : PlusFormula := .untl p (r.and (X (p.and (X r))))

abbrev w1 (B : ℕ) : F.WorldState := ((0 : ℤ), ⟨(true, B, B + 1), fun h => by cases h⟩)
abbrev w2 (B : ℕ) : F.WorldState := ((0 : ℤ), ⟨(true, B, B + 2), fun h => by cases h⟩)

theorem no_fwd {Q : Type} [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    ¬ ∀ t x, ∃ y, Rlad step pend t x y := sorry

theorem no_bwd_of_idle {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (q : Q) (hq : pend q = false) :
    ¬ ∀ t x, ∃ y, Rlad step pend (t - 1) y x := sorry

theorem cell_ne (B : ℕ) : cellAt M phi (w1 B) 0 ≠ cellAt M phi (w2 B) 0 := sorry

theorem exhibited_form_refuted :
    ¬ ∀ (c c' n n' : ℕ), (plusSubformulaClosure phi).card ≤ c →
      (plusSubformulaClosure phi).card ≤ c' → (plusSubformulaClosure phi).card ≤ n →
      (plusSubformulaClosure phi).card ≤ n' →
      ∀ (hc : c ∈ Adm pendB true) (hc' : c' ∈ Adm pendB true),
        cellAt M phi ((0 : ℤ), ⟨(true, c, n), hc⟩) 0 =
          cellAt M phi ((0 : ℤ), ⟨(true, c', n'), hc'⟩) 0 := sorry

theorem exists_form_refuted :
    ¬ ∃ B : ℕ, ∀ (c c' n n' : ℕ), B ≤ c → B ≤ c' → B ≤ n → B ≤ n' →
      ∀ (hc : c ∈ Adm pendB true) (hc' : c' ∈ Adm pendB true),
        cellAt M phi ((0 : ℤ), ⟨(true, c, n), hc⟩) 0 =
          cellAt M phi ((0 : ℤ), ⟨(true, c', n'), hc'⟩) 0 := sorry

end Probe760
```

## Testing & Validation

- [ ] The probe compiles under the gate's own command (`lake env lean`, through the build guard)
      with 0 errors, 0 warnings, and the axiom foot `[propext, Classical.choice, Quot.sound]` on
      four `#print axioms` lines and `[propext]` on `no_bwd_of_idle`.
- [ ] No `sorry`, `axiom`, or vacuous-definition pattern in the probe (grep count 0).
- [ ] The five Goal declarations match the Lean Challenge Statements block exactly
      (`lean-challenge-snapshot.sh --check 760 .` as an advisory drift check).
- [ ] `check-evidence-probes.sh` reports 30 wired probes, all PASS.
- [ ] `check-module-invariants.sh`, `check-task-references.sh`, `readme-lint.sh`,
      `typst-sync-check.sh`, `verify-deploy.sh` and the guarded full `lake build` all exit 0.
- [ ] Header read-through: F1 and F2 both stated; "a carrier restriction of this shape"; the
      forward-only sentence; the paper-level status of the past-looking twin; the no-bound,
      no-finiteness, zero-debt sentences; `anchorCells_ncard_le` untouched; successor design not
      chosen.
- [ ] The README's `unproved` count dropped by exactly 2 and the theorem-index row's
      count-not-complexity sentence is unchanged.
- [ ] Phase 1 still `[BLOCKED]`; plan-level Status `[BLOCKED]`; return status `partial` with
      `requires_user_review: true`.

## Artifacts & Outputs

- `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` (new, tracked, wired — the twelfth probe)
- `scripts/check-evidence-probes.sh` (one table row, one `WIRED` entry)
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` (one Evidence paragraph, four amended sentences, `Last verified` date)
- `docs/theorem-index.md` (one amended clause in the `ladderFrame_isRegular` row)
- `specs/760_ladder_model_cell_stabilization_lemma/summaries/01_ladder-cell-refutation-probe-summary.md`
- This plan, with Phase 1 `[BLOCKED]` and plan-level Status `[BLOCKED]` at the return

## Rollback/Contingency

- Each executable phase is one or two files and commits per green substep; reverting a phase is
  reverting its commit(s). If Phase 3's gate run fails on the new entry, remove the entry and
  row (the probe file stays, unwired) rather than weakening any statement.
- If the port does not compile and the cause is not one of the three named hazards, STOP and
  compare against the prototype line by line — the prototype is a compiled oracle for every
  declaration (re-compiled at plan time, exit 0, zero warnings); do not re-derive proofs or
  substitute a different decomposition (`plan-compliance.md`).
- Phase 1 is `[BLOCKED]` by design and by the user's ruling; it is never "unblocked" inside this
  task. Any attempt to prove the filed lemma over `ladderFrame` — which succeeds only by
  unsatisfiable hypotheses — is a defect, not progress. If the implementer finds a statement in
  the Challenge block that does not close as written, the same rule applies: record the failure
  in the probe header as a further obstruction, mark Phase 2 `[BLOCKED]`, never a `sorry`, axiom,
  vacuous definition, or finite-fibre retreat.
- The successor design (R2: `/revise` to land `Adm`, `LadderState`, `RladAdm`, `ladderFrameAdm`,
  `ladderModel` and the negative theorem in `LadderModel.lean` with C14 pins and theorem-index
  rows; or R3: `/spawn` a research-first record for a repaired positive lemma over
  `(q, min c B', min n B', clip (n - c))`) is the user's, as already ruled; the implementation's
  `partial` return with `requires_user_review: true` is the hand-back point.
