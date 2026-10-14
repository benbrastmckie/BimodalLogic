# Implementation Plan: Task #778

- **Task**: 778 - Record the modulus convention for the residue-carrying ladder index
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/778_residue_index_modulus_convention_record/reports/01_residue-index-modulus-convention.md
- **Artifacts**: plans/01_residue-index-modulus-convention.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is a record gap inside a settled negative result, not a proof gap. `ladderIndexRes T P B`
takes both residue coordinates modulo `P + 1`, so its `P` is a *modulus minus one*, while
`reachN_eventually_periodic` returns a *period* `p` with `1 ≤ p`; the two quantities share the
letter `P` and are not the same number. The plan records the convention by naming the modulus
(`m`, with `P := m - 1`, so an exhibited period `p` enters as `m := p`) and, in the same breath,
records that no refutation turns on the choice — `object_only_parameters_refuted` quantifies over
every `(T, P, B)` and `reach_period_refuted` holds for every modulus not divisible by `3`, so
both readings of the exhibited period `1` (moduli `1` and `2`) already fall. Every probe theorem
statement is left byte-for-byte unchanged.

The work is six small prose phases across two trees (the Lean library and the lean extension's
source store) plus one gate phase. No declaration is added, no theorem statement is touched, and
no proof obligation is created.

### Research Integration

The report's findings are adopted in full and were re-verified at plan time:

- The convention is dissolved by naming the modulus rather than by picking between `P := p` and
  `P := p - 1` — the recommended wording for `LadderModel.lean` is taken from the report's
  Recommendations section.
- The "both readings refuted" claim is grounded on `object_only_parameters_refuted` (every
  `(T, P, B)`) and `reach_period_refuted` (`¬ 3 ∣ (P + 1)`), **not** on the parity observable: the
  task description's justification via `cell_succ_ne` / `gate_parity_separates` has no compiled
  instance at countdown offset `3`, and this task bars adding one.
- A third site carries the gap beyond the two the task names: `RaySummary/README.md` asserts the
  convention is unrecorded. Landing the record without repairing that line would have the library
  README deny the record this task creates, so it is in scope as a correctness edit.
- Each reading degenerates on a different fixture (`m = 3` odd on `Qp` collides `c` with `c + 3`;
  `m = 1` on fixture B trivialises both residue coordinates and collapses the index to the
  already-refuted three-coordinate candidate), which forces `2 ≤ m` — exactly the `1 ≤ P`
  hypothesis the parity gate of that family already carries.
- `reachN_eventually_periodic` exhibits no canonical period at all: its `(T, P)` depends on the
  start set (period `2` from the pending singleton on `Qp`, period `1` from `univ`) and is
  satisfied by any multiple of a period, which is an independent reason the modulus cannot be read
  off the object.

**One finding extends the report.** The report itemized the `dominate` -> `multiple of`
sharpening for the source-store note alone. A plan-time grep found the same claim at eleven
further occurrences across six files: `LadderModel.lean:81`; `RaySummary/README.md:45,460,784`;
`docs/theorem-index.md:214-217` (four rows); `scripts/check-evidence-probes.sh:1013`; the probe
docstring at `:104`. `docs/theorem-index.md` declares itself authoritative over `README.md`
("If two of them disagree, this page is right"), so sharpening one site and not that ledger would
leave the declared-authoritative surface carrying the weaker claim. The sharpening is therefore
folded into each file-owning phase, with a residual-occurrence grep in the final phase as the
mechanical consistency check.

Note that `dominate` is **weaker than what is proved, not false**: a modulus that is a multiple of
`p` is necessarily `>= p`, so the existing clause states a true-but-understated necessary
condition. That is why the sharpening is a consistency obligation rather than a correctness
emergency, and why no phase blocks on it.

### Prior Plan Reference

No prior plan for this task. The originating task's plan and issue log were consulted through the
research report for implementation hazards only: the `check-module-invariants.sh` INV collision on
stale generated inventory blocks after a docstring-only edit to this same file, and a source-store
staging quirk on `index-entries.json`. Both are carried into Risks below with mitigations, and
both informed the effort estimate (gate reconciliation, not editing, dominates the cost).

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no roadmap flag is set, so no
roadmap phases are added and `specs/ROADMAP.md` is not edited. For the record, `ROADMAP.md`
line 20 carries the same understated `dominating` clause inside its Stage 1 batching comment;
it is listed as a Non-Goal below rather than silently left out.

## Goals & Non-Goals

**Goals**:
- State the modulus convention in the `LadderModel.lean` module docstring: `P + 1` is the modulus,
  an instantiation names `m` with `1 ≤ m` and sets `P := m - 1`, and an exhibited period `p`
  enters as `m := p`.
- State, in the same place, that no refutation turns on the convention, citing
  `object_only_parameters_refuted` and `reach_period_refuted` by name, and that `2 <= m` is forced.
- State the same convention in the lean extension's `ladder-counter-observables.md`, in its
  source store, extending the existing parameter-origin rule rather than adding a new file.
- Remove the three "unrecorded"/"no record fixes" assertions that the record falsifies
  (`RaySummary/README.md`, the source-store note, the probe docstring), replacing each with the
  reading-neutral form.
- Bring the `dominate` clause into one consistent wording across every deliverable surface that
  carries it.
- Leave every theorem statement in both probes byte-for-byte unchanged.

**Non-Goals**:
- No new Lean declaration, no new theorem, no proof. In particular, **no offset-3 parity theorem**:
  the generic ingredient exists (`phiP_mem_iff_of_mem_cell`) but the task bars adding it, and the
  compiled cover for modulus `3` is `object_only_parameters_refuted`.
- No seventh coordinate, no successor index candidate, no re-attempt at the positive factorization
  lemma. It stays open and asserted nowhere.
- No edit to any probe *statement* — only the two probes' docstrings, and only where the record
  makes the current prose false.
- No edit to `specs/ROADMAP.md` (operator-owned batching file; no roadmap flag on this dispatch).
- No hand-patch of anything under `.claude/**`. The deployed lean-extension copy of the note is
  already stale independently of this task; the source store is the edit target.
- No `deploy-headless.sh` run. A redeploy regenerates the whole gitignored tree across every
  extension, which is beyond this task's blast radius; the divergence is reported in the summary
  instead, as the operator's call.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Generated-inventory gate collision: the docstring grows `LadderModel.lean`, moving the `FormalSystem` totals in the machine-owned `README.md:19` block, so `check-module-invariants.sh`'s INV group fails. Observed once already on this exact file. | M | H | Expected, not a surprise. Phase 6 runs `check-module-invariants.sh`, regenerates with `--emit-inventory`, confirms idempotence with `--emit-inventory --check`, and commits the regenerated block in the same change. |
| The hand-maintained `\| LadderModel.lean \| 219 \|` row in `RaySummary/README.md` is covered by no gate (that table carries no `BEGIN GENERATED` markers), so a stale count ships green. | M | H | Phase 2 updates it from a fresh `wc -l` taken after Phase 1's edit is final, and Phase 6 re-checks the row against `wc -l` as an explicit criterion rather than trusting the earlier write. |
| Source-store staging hazard: a pre-existing uncommitted hunk in `index-entries.json` and a whole-file staging quirk in `git-commit-scoped.sh` were both recorded on the predecessor task. | M | M | Phase 3 re-reads `index-entries.json` immediately before editing, changes only the one `line_count`, and verifies the staged blob contains only that change via `git diff --staged` before committing. |
| Probe recompile cost: editing the probe docstring forces a `lake env lean` run over 1549 lines. | L | H | Phase 4 is late and independent; the run goes through `lake-build-guard.sh` detached, per the bounded-build-waiter pattern. |
| Concurrency: sibling task 716 is dispatched this same cycle on this same working tree. | M | M | Its declared `file_scope` (`PlusSlicedCertificate/*`, `scripts/certificate-witness-inventory.txt`) is disjoint from every path below. Still: re-read each file immediately before editing, stage explicit file lists only, never `git-snapshot.sh` in its reverting default mode, and treat a build failure outside this plan's scope as possibly a sibling's in-flight edit. |
| Deliverable wording rules: `LadderModel.lean`, both READMEs and `docs/theorem-index.md` are deliverables, so `no-record-versioning-in-deliverables.md` applies. | M | M | The new text states the convention in the present tense. The words "unrecorded", "previously", "formerly", "no longer" and "now recorded" must not appear in any new hunk; Phase 6 greps the diff for them. |
| Scope creep through the `dominate` sweep (12 occurrences, 7 files). | M | M | Bounded by an enumerated occurrence list fixed at plan time, folded into the phase that already owns each file, and checked mechanically in Phase 6. If any single site proves costlier than its phase's budget, the honest outcome is to record that site as excluded with its reason, not to leave two wordings unlabelled. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2, 4, 5 | 1 |
| 3 | 6 | 1, 2, 3, 4, 5 |

Phases within the same wave can execute in parallel.

### Phase 1: Record the convention in the `LadderModel.lean` docstring [COMPLETED]

**Goal**: The named deliverable's library half. The module docstring states the modulus
convention, states that no refutation turns on it, and carries the sharpened modulus clause.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` lines 70-90
      immediately before editing (sibling task dispatched this cycle).
- [x] Insert the convention into the residue-candidate paragraph, after the sentence naming the
      two refuted parameters (currently ending `...the period of the sub-object a formula that
      forbids a letter carves out).`). Content, wording the implementer's to finalise:
      the candidate's `P` is a modulus minus one, not a period — both residue coordinates are
      taken modulo `P + 1`, so an instantiation is fixed by naming the modulus `m` with `1 <= m`
      and setting `P := m - 1`, and a period `p` from `reachN_eventually_periodic` (which gives
      `1 <= p`) enters as `m := p`.
- [x] Add the convention-independence sentence: no refutation turns on the choice, because
      `object_only_parameters_refuted` quantifies over every `(T, P, B)` and
      `reach_period_refuted` holds for every modulus not divisible by `3`, so both readings of
      the exhibited period `1` fall (moduli `1` and `2`).
- [x] Add the forced lower bound: at `m = 1` both residue coordinates are constant and the index
      collapses to the three-coordinate candidate already refuted at the countdown coordinate, so
      `2 <= m` is forced — the hypothesis the parity gate of that family already carries.
- [x] Sharpen line 81's `the modulus must dominate every letter-definable sub-object period` to
      the multiple-of form, with the one-clause reason that `reach_period_refuted`'s hypothesis is
      divisibility (`¬ 3 ∣ (P + 1)`), not magnitude — a modulus of `100` exceeds `3` and is still
      refuted.
- [x] Confirm no new hunk contains "unrecorded", "previously", "formerly", "no longer", or
      "now recorded" (deliverable wording rule).
- [x] Record the post-edit `wc -l` of the file; Phase 2 consumes it.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The edit is expected to add roughly ten lines to one `/-! ... -/` module
docstring and to touch no declaration. Confirm at implementation time by reading
`git diff -- FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` and checking that
every changed hunk lies inside the docstring block and that the declaration count is unchanged.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderModel`
compiles the single edited module, which is the only surface a `/-! -/` docstring edit can break
(an unbalanced delimiter or a mis-nested backtick fails elaboration); nothing outside this module
sees a changed signature, so no dependent build is needed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` - module docstring only:
  convention recorded, convention-independence stated, `2 <= m` noted, `dominate` clause sharpened.

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.RaySummary.LadderModel`
  exits `0` (detached, per `context/patterns/bounded-build-waiter.md`).
- `git diff` on the file shows changed hunks inside the docstring only; no declaration added,
  removed, or renamed.
- The docstring names `object_only_parameters_refuted` and `reach_period_refuted` explicitly.
- `grep -nE 'unrecorded|previously|formerly|no longer|now recorded'` over the new hunks is empty.

---

### Phase 2: Reconcile `RaySummary/README.md` with the record [COMPLETED]

**Goal**: The library README stops asserting the convention is unrecorded, carries the sharpened
modulus clause at all three of its occurrences, and its hand-maintained `LadderModel.lean` row
matches the file's new line count.

**Tasks**:
- [x] Re-read the three target regions of
      `FormalSystem/Metalogic/Decidability/RaySummary/README.md` immediately before editing.
- [x] Replace the clause at line 781 — `both readings of period 1 under the unrecorded P versus
      P + 1 convention` — with the reading-neutral form: both readings of the exhibited period
      `1`, moduli `1` and `2`. State no claim about what is or is not on record.
- [x] Sharpen the `dominate` clause at line 784 (`the modulus dominating the period of every
      letter-definable sub-object`) to the multiple-of form.
- [x] Sharpen the `dominate` clause at line 460 (`must dominate every letter-definable sub-object
      period`) to the multiple-of form.
- [x] Sharpen the `dominate` clause inside the `LadderModel.lean` inventory row at line 45 to the
      multiple-of form.
- [x] Update the row's line count from the fresh `wc -l FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean`
      taken after Phase 1 (currently `219`). This table carries no `BEGIN GENERATED` markers, so
      no gate catches its drift.
- [x] Confirm no new hunk contains "unrecorded", "previously", "formerly", "no longer", or
      "now recorded".

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: Four occurrences are expected in this file (lines 45, 460, 781, 784, where
781 and 784 are adjacent sentences of one paragraph). Confirm at implementation time with
`grep -nE 'unrecorded|dominat' FormalSystem/Metalogic/Decidability/RaySummary/README.md` before
and after; the after-count for both patterns must be `0`.

**Tier Justification**: The edit is markdown-only with zero compile surface, and
`suite_selection_select` returns `__FULL_SWEEP__` for a consumer-tree doc outside `specs/**`
(sub-case (c)), so the covering checks are `bash .claude/scripts/verify-deploy.sh --only-gate 4 .`
for the task-reference lint plus a literal comparison of the row's written count against
`wc -l` on the Lean file — the one surface no repository gate covers.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - reading-neutral repair at 781,
  `dominate` sharpened at 45/460/784, `LadderModel.lean` row count refreshed.

**Verification**:
- `grep -n unrecorded FormalSystem/Metalogic/Decidability/RaySummary/README.md` is empty.
- `grep -nE 'dominat' FormalSystem/Metalogic/Decidability/RaySummary/README.md` is empty.
- The `| LadderModel.lean | N |` row's `N` equals
  `wc -l < FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean`.
- `bash .claude/scripts/verify-deploy.sh --only-gate 4 .` exits `0`.
- Diff read-through confirms every changed hunk is prose inside this markdown file.

---

### Phase 3: Record the convention in the lean extension's source store [COMPLETED WITH EXCLUSIONS]

**Goal**: The named deliverable's note half. `ladder-counter-observables.md` carries the
convention inside its existing parameter-origin rule, drops its own "unrecorded" clause, records
that `reachN_eventually_periodic` exhibits no canonical period, and its `index-entries.json`
`line_count` matches.

**Tasks**:
- [x] Re-resolve the lean extension's `source_dir` from `/home/benjamin/Projects/BimodalLogic/.claude-extensions.json`
      rather than trusting the path below (it is per-extension, not one global value). Expected:
      `/home/benjamin/.config/nvim/agent-system/extensions/lean`.
- [x] Re-read the note's lines 86-100 and 136-150 immediately before editing.
- [x] Replace the clause at lines 93-95 — `which covers BOTH readings of the exhibited period 1
      under the unrecorded P versus P + 1 instantiation convention (moduli 2 and 1)` — with the
      reading-neutral form that points at the parameter-origin rule and claims nothing about what
      is on record.
- [x] Extend the modulus bullet (lines 142-146) with the convention: `P + 1` is the modulus, an
      instantiation is specified by `m` with `P := m - 1` and an exhibited period `p` enters as
      `m := p`, and `2 <= m` is forced because `m = 1` trivialises both residue coordinates and
      collapses the index to the already-refuted three-coordinate candidate.
- [x] Sharpen the same bullet's `must dominate the period of every letter-definable sub-object` to
      the multiple-of form, with the one-clause reason that `reach_period_refuted` refutes every
      modulus `m` with `3 ∤ m`, including moduli larger than `3`.
- [x] Sharpen the trailing `The modulus must therefore dominate the period of every
      letter-definable sub-object` at the end of mechanism (5) (line ~96) to match.
- [x] Add one sentence to mechanism (5) or the gate-5 row: `reachN_eventually_periodic` exhibits
      no canonical period — its `(T, P)` depends on the start set (period `2` from the pending
      singleton on `Qp`, period `1` from `univ`) and is satisfied by any multiple of a period —
      which is a second, independent reason the modulus cannot be read off the object.
- [x] Re-read `index-entries.json` immediately before editing (a pre-existing uncommitted hunk was
      recorded there on the predecessor task) and update only the `line_count` for
      `project/lean4/domain/ladder-counter-observables.md` (currently `180`) to the note's new
      `wc -l`.
- [x] Verify the staged blob for `index-entries.json` contains only that one field change via
      `git diff --staged` in the source-store repository.

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: Three `dominat` occurrences and one `unrecorded` occurrence are expected in
the note, and exactly one `line_count` field in `index-entries.json`. Confirm at implementation
time with `grep -nE 'unrecorded|dominat'` on the note (after-count `0`) and
`grep -c '"line_count"' index-entries.json` scoped to the note's entry (exactly one changed line
in the diff).

**Tier Justification**: Both files are source-store markdown/JSON with no mapped suite
(`__FULL_SWEEP__`, sub-case (b)), so the covering check is
`bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim/agent-system/extensions/lean`
with an explicit `TARGET` at the resolved source store — the bare no-argument form would run both
gates' SKIP branch against this consumer repo and check nothing.

**Files to modify**:
- `<lean source_dir>/context/project/lean4/domain/ladder-counter-observables.md` - reading-neutral
  repair at 93-95, convention added to the modulus bullet, `dominate` sharpened at both sites,
  non-canonical-period sentence added.
- `<lean source_dir>/index-entries.json` - `line_count` for the note only.

**Verification**:
- `grep -nE 'unrecorded|dominat'` on the note is empty.
- The note's modulus bullet names `m`, `P := m - 1`, and `2 <= m`.
- `line_count` in `index-entries.json` equals `wc -l < <note>`.
- `python3 -m json.tool <index-entries.json> >/dev/null` confirms the file still parses.
- `git diff --staged -- index-entries.json` in the source-store repository shows exactly one
  changed line.
- `bash /home/benjamin/.config/nvim/agent-system/extensions/core/scripts/verify-deploy.sh --skip-slow --only-gate 3,4 /home/benjamin/.config/nvim/agent-system/extensions/lean`
  exits `0`.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `verify-deploy.sh --only-gate 3` (doc-lint) exiting `0` | The gate was already red at the source store before this edit, for ten foreign findings, and no dispatch from this repository can turn it green. The plan also named the wrong TARGET: the script requires a deploy-tree root, so the real target is `/home/benjamin/.config/nvim`, not the extension directory. | `check-extension-docs.sh` enumerates 10 findings: deployed-script content drift (`core`: `generate-todo.sh`, `tests/test-validate-state.sh`; `lean`: `lean-challenge-snapshot.sh`, `tests/test-lean-challenge-snapshot.sh`), two test fixtures absent from `provides.scripts`, and four `index-entries.json` `line_count` mismatches (`project/lean4/lean4-syntax.md`, `patterns/tactic-patterns.md`, `patterns/dependency-tracing.md`, `project/lean4/README.md`). None names `ladder-counter-observables.md` — positive evidence the `194` written here is correct. Gate 4 PASSES. |
| Committing the two source-store edits | `index-entries.json` carries a foreign uncommitted hunk (`project/lean4/README.md` `line_count` 30 -> 31) from another writer. Staging the file stages that hunk too, and `git commit -- <pathspec>` re-reads the working tree, so no scoped commit can exclude it. The territory contract says stop and report rather than commit a foreign hunk, and `specs/ROADMAP.md` already rules that source-store-bound work "commit[s] nothing it manages to write" from this repository. | `git -C /home/benjamin/.config/nvim diff -- agent-system/extensions/lean/index-entries.json` shows exactly two hunks: the foreign `30 -> 31` and this task's `180 -> 194`. The edits are complete and verified in place; only the commit is deferred to the operator. |

---

### Phase 4: Restate the probe docstring and the evidence-gate record [COMPLETED WITH EXCLUSIONS]

**Goal**: The probe's own `The P versus P + 1 convention` section names the convention instead of
declaring it unrecorded, keeps its convention-independence claim, and leaves every theorem
statement untouched. The transcribed record in `check-evidence-probes.sh` matches.

**Tasks**:
- [x] Re-read `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`
      lines 60-110 immediately before editing.
- [x] Rewrite the section at lines 66-72. The sentence `no record fixes whether the index is
      instantiated at P := period (modulus period + 1) or P := period - 1 (modulus period)` is
      false once Phase 1 lands; replace it with the convention (`P + 1` is the modulus; an
      instantiation names `m` and sets `P := m - 1`; an exhibited period `p` enters as `m := p`)
      and keep the existing `Nothing here chooses` sentence, which stays true: mechanism (4) is
      stated for all `P` and mechanism (5) for every `P` with `¬ 3 ∣ (P + 1)`.
- [x] Sharpen the `the modulus dominating the period of every letter-definable sub-object of the
      object` clause at line ~104 to the multiple-of form.
- [x] Sharpen the matching clause in the `scripts/check-evidence-probes.sh` comment block at
      line ~1013 (`dominating the period of every letter-definable sub-object`), preserving the
      block's column alignment. Line 1007's `both readings of period 1` needs no edit — it stays
      accurate under either reading.
- [x] Confirm, by diffing with `git diff -- specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`,
      that no `theorem`, `lemma`, `def`, `abbrev`, `example` or `#guard` line is touched.

**Timing**: 0.75 hours

**Depends on**: 1

**Scope Hypothesis**: Two prose regions in the probe (lines 66-72 and ~104) and one comment line
in the gate script. Confirm by diffing against a declaration-binder grep
(`grep -nE '^(theorem|lemma|def|abbrev|example|instance|#guard)' <probe>` before and after must
produce identical output).

**Verification Tier**: local

**Tier Justification**: `lake env lean specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`
elaborates the single edited file — the probe is standalone and imported by nothing, so there is
no dependent set — and `bash scripts/check-evidence-probes.sh` is the gate that owns both the
probe's wiring and the comment block being edited.

**Files to modify**:
- `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` - docstring only;
  convention section restated, `dominate` clause sharpened. No statement touched.
- `scripts/check-evidence-probes.sh` - the transcribed record comment at line ~1013 only.

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- env lean specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`
  exits `0` with no `sorry` and no error (detached, bounded waiter).
- `bash scripts/check-evidence-probes.sh` exits `0`.
- A declaration-binder grep over the probe produces byte-identical output before and after.
- `grep -n 'no record fixes' specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`
  is empty; `grep -n 'Nothing here chooses'` still matches.
- `grep -nE 'dominat' specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean scripts/check-evidence-probes.sh`
  is empty.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `bash scripts/check-evidence-probes.sh` exiting `0` | The gate exits `1` on four pre-existing probe compile failures that this task neither caused nor can repair within its scope. | `FAIL  4 of 33 wired probe(s) failed`, naming `seam-gluing-ray-product/{finite-graph-stab-summary, mosaic-germ-amalgamation, path-quantifier-alternation, backward-dual-asymmetric-fixture}`. `git status --short -- specs/evidence/` lists exactly one modified file, this task's own probe, and both `ladder-residue-index-refutation` and `ladder-cell-index-obstructions` report PASS in the same run. |

---

### Phase 5: Align the authoritative theorem ledger [COMPLETED]

**Goal**: `docs/theorem-index.md`, which declares itself authoritative over every other surface,
carries the same sharpened modulus clause as the module docstring it summarises.

**Tasks**:
- [x] Re-read the four affected rows of `docs/theorem-index.md` (lines 214-217: `no_fwd`,
      `no_bwd_of_idle`, `ladderFrameAdm_isRegular`, `ladderModel`) immediately before editing.
- [x] In each row, sharpen `the modulus must dominate every letter-definable sub-object period` to
      the multiple-of form, leaving every other clause of the row — including the Lean name, File,
      Frame class and Axioms columns — untouched.
- [x] Confirm the four rows remain single-line table rows (no inserted newline would survive the
      markdown table).
- [x] Confirm the Axioms column, which `check-module-invariants.sh` generates from pinned
      baselines, is unchanged in all four rows.

**Timing**: 0.5 hours

**Depends on**: 1

**Scope Hypothesis**: Exactly four occurrences, one per row, all with identical wording. Confirm
at implementation time with `grep -c 'modulus must dominate' docs/theorem-index.md` — expected `4`
before and `0` after — and with a row count that is unchanged.

**Verification Tier**: prose

**Tier Justification**: The edit is table-cell prose with zero compile surface, and
`bash scripts/check-module-invariants.sh` is the specific script that owns this file's pinned
columns, so it is the check that would catch any accidental damage to the Lean-name, File or
Axioms cells.

**Files to modify**:
- `docs/theorem-index.md` - the Statement cell of four rows only.

**Verification**:
- `grep -c 'modulus must dominate' docs/theorem-index.md` returns `0`.
- `grep -c 'multiple of the period of every letter-definable' docs/theorem-index.md` returns `4`.
- `bash scripts/check-module-invariants.sh` reports no new finding attributable to this file
  (an INV finding from Phase 1's line-count shift is expected and is Phase 6's to resolve).
- The file's total line count is unchanged.

---

### Phase 6: Full gate sweep, inventory reconciliation, and consistency check [IN PROGRESS]

**Goal**: Every repository gate is green, the machine-owned inventory block reflects
`LadderModel.lean`'s new size, and no deliverable surface is left carrying either the old
`dominate` wording or an "unrecorded" assertion.

**Tasks**:
- [ ] Run `bash scripts/check-module-invariants.sh`. An INV finding on the `README.md:19`
      `dir=FormalSystem rows=totals` block is the expected consequence of Phase 1's docstring
      growth, not a defect.
- [ ] Resolve it with `bash scripts/check-module-invariants.sh --emit-inventory`, then confirm
      idempotence with `bash scripts/check-module-invariants.sh --emit-inventory --check`
      (exits `0` when a further rewrite would change no byte).
- [ ] Re-run `bash scripts/check-module-invariants.sh` to green.
- [ ] Residual-occurrence sweep, the mechanical consistency check for the `dominate` sharpening:
      `grep -rnE 'modulus must dominate|modulus dominating|dominating the period|dominate every letter|dominate the period of every letter' --include=*.lean --include=*.md --include=*.sh .`
      with `.lake`, `.claude/`, `specs/ROADMAP.md` and the `specs/7*_*/` task-artifact trees
      excluded. Expected: empty. Any surviving site is either edited or recorded as an enumerated
      exclusion with its reason — not left silently split between two wordings.
- [ ] Unrecorded-assertion sweep:
      `grep -rn 'unrecorded' --include=*.lean --include=*.md .` with the same exclusions, plus the
      pre-existing unrelated `ExteriorConverterK.lean` / `ExteriorPinnedConverseK.lean` hits
      (`unrecorded-but-realizable on-fiber sub`, a different sense of the word and out of scope).
- [ ] Deliverable wording sweep over the whole diff:
      `git diff | grep -nE '^\+.*(previously|formerly|no longer|now recorded|supersedes)'` is
      empty.
- [ ] Full library build through the guard, detached and bounded.
- [ ] `bash scripts/check-evidence-probes.sh` to green.
- [ ] `bash .claude/scripts/verify-deploy.sh` to green.
- [ ] Record in the summary that the deployed `.claude/` copy of the note remains stale until an
      operator-run `deploy-headless.sh`, and that this task deliberately did not run one.

**Timing**: 0.75 hours

**Depends on**: 1, 2, 3, 4, 5

**Verification Tier**: full

**Files to modify**:
- `README.md` - the machine-owned `dir=FormalSystem rows=totals` inventory block only, via
  `--emit-inventory`. Never hand-edited.
- Any further generated inventory block the same regeneration rewrites.

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` exits `0` — the complete gate set, with no
  `--skip-slow` and no `--only-gate` narrowing, since this is the final phase.
- `bash scripts/check-module-invariants.sh` exits `0`.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits `0` (regeneration is
  idempotent, so no generated block is stale).
- `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build` exits `0`.
- `bash scripts/check-evidence-probes.sh` exits `0`.
- The residual-occurrence grep and the unrecorded-assertion grep both return empty (modulo the
  two enumerated out-of-scope `Exterior*K.lean` hits).
- `git diff` over the whole change adds no `theorem`, `lemma`, `def`, `abbrev` or `instance` line
  anywhere.

---

## Testing & Validation

- [ ] `LadderModel.lean` compiles and its docstring names the modulus `m`, the relation
      `P := m - 1`, the entry `m := p`, the bound `2 <= m`, and both
      `object_only_parameters_refuted` and `reach_period_refuted`.
- [ ] The source-store note's parameter-origin rule carries the same convention, and its
      `index-entries.json` `line_count` matches the note.
- [ ] No surface in the repository asserts that the convention is unrecorded.
- [ ] Every probe theorem statement is byte-for-byte unchanged; the probe elaborates clean with
      no `sorry`.
- [ ] One consistent wording of the modulus clause across every deliverable surface, verified by
      the Phase 6 grep rather than by inspection.
- [ ] `verify-deploy.sh`, `check-module-invariants.sh` and `check-evidence-probes.sh` all green.
- [ ] No new declaration anywhere; no change to `Adm`, `LadderState`, `RladAdm`, `ladderFrameAdm`
      or `ladderModel`.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/RaySummary/LadderModel.lean` - docstring record of the
  modulus convention and its convention-independence.
- `FormalSystem/Metalogic/Decidability/RaySummary/README.md` - reading-neutral narrative, refreshed
  module row.
- `docs/theorem-index.md` - four rows aligned to the sharpened modulus clause.
- `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean` - restated
  convention section, statements untouched.
- `scripts/check-evidence-probes.sh` - transcribed record comment aligned.
- `README.md` - regenerated `FormalSystem` inventory totals.
- `<lean source_dir>/context/project/lean4/domain/ladder-counter-observables.md` and
  `<lean source_dir>/index-entries.json` - the note half of the record.
- `specs/778_residue_index_modulus_convention_record/summaries/01_residue-index-modulus-convention-summary.md`
  - completion summary, stating the deployed-tree staleness as an operator item.

## Rollback/Contingency

Every edit is prose. No declaration, statement, signature or build target changes, so rollback is
a textual revert with no proof debt.

- Per-file revert: `git checkout HEAD -- <path>` is the natural undo, but it is a destructive
  operation on a dirty tree. Take `bash .claude/scripts/git-snapshot.sh 778 --no-revert` first as
  a defensive checkpoint; use the default reverting mode of that script only for a genuine,
  intentional rollback of the whole task.
- If Phase 1's build fails, the cause is a malformed `/-! -/` docstring delimiter or a mis-nested
  backtick. Revert that one file and re-apply the insertion in smaller hunks; nothing downstream
  has been touched yet, since Phases 2, 4 and 5 all depend on 1.
- If the Phase 6 inventory regeneration rewrites blocks beyond the `FormalSystem` totals, inspect
  the diff before committing: an unexpected block means another file's line count drifted outside
  this task, possibly a concurrent sibling's edit. Per the territory contract, stop and report
  rather than committing a foreign hunk.
- If the probe recompile in Phase 4 proves too costly to complete, that phase is independently
  revertible: restore the probe docstring and the gate-script comment, and record the exclusion
  with its reason. The cost of that exclusion is one inaccurate sentence inside a probe docstring,
  which the summary must name explicitly rather than leave implicit.
- The source-store edits (Phase 3) live in a different repository from the library edits and
  revert independently. A partial outcome — the library record landed and the note deferred, or
  the reverse — is recoverable and must be stated as such rather than reported as complete.
