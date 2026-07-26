# Implementation Plan: Task #396

- **Task**: 396 - correct_stale_sorry_claims_in_user_docs
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: `specs/396_correct_stale_sorry_claims_in_user_docs/reports/01_docs-staleness-sweep.md`; `specs/396_correct_stale_sorry_claims_in_user_docs/DECISION.md` (binding scope decision)
- **Artifacts**: plans/01_docs-staleness-corrections.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, no-task-references-in-deliverables.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

Correct every claim in `Theories/Bimodal/docs/` that misrepresents the proof status of the Lean
sources, per the full-sweep scope the user fixed in `DECISION.md`. The research report already
carries per-hit evidence and replacement text for all ten in-scope files, so this is a
transcription-and-consistency exercise, not a re-verification exercise. Two distinct treatments
apply and must not be confused: **STALE** claims (live status reports that are false) are
corrected to verified statements; **SCHEMATIC** blocks (pedagogical `sorry` code that reuses real
theorem names) are left intact and given a prose disclaimer. Definition of done: a re-grep of the
original staleness markers over `Theories/Bimodal/docs/` returns only hits that are either
verified-accurate or an intentionally-disclaimed schematic block, and `git status` shows zero
modified `.lean` files.

### Research Integration

All corrections derive from `reports/01_docs-staleness-sweep.md`, whose ground truth was
established by a green full `lake build` (1877 jobs, 0 errors, exactly 12 `sorry` warnings) and
per-theorem `lean_verify` axiom checks. The report's per-hit table supplies file:line, verdict,
evidence, and replacement text for each hit. This plan adds three things the report left open:
(a) a canonical status vocabulary (below) that every phase quotes verbatim so the ten files cannot
drift apart; (b) explicit removal-vs-correction rulings for the claims that cite nonexistent files
and theorems; (c) a resolution of the report's open `test-coverage.md` question.

### Prior Plan Reference

No prior plan. This is the first plan for this task.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no roadmap phases are included.

## Canonical Status Statements (quote verbatim)

Every phase MUST express the corresponding fact using these statements. Wording may be adapted to
the host document's register (table cell vs. prose), but the **facts and the file/theorem names
must not change between files**. Do not introduce a claim not on this list.

| ID | Canonical statement |
|----|---------------------|
| CS-1 | 12 `sorry` placeholders total, all in `Metalogic/`: `Bundle/SuccRelation.lean` x7, `Bundle/SuccExistence.lean` x3, `BXCanonical/Chronicle/ChronicleToCountermodel.lean` x1, `WeakCanonical/Transfer.lean` x1. None in `Examples/` or `Tests/`. |
| CS-2 | Soundness is fully proven and sorry-free, covering all 21 axiom schemas (17 base + 1 dense + 3 discrete). |
| CS-3 | `completeness_dense` and `completeness_discrete` are fully proven and sorryAx-free. The general Base-frame `completeness` theorem retains one residual `sorryAx` dependency through a deprecated dead-code pipeline (`WeakCanonical.countermodel_discrete`). |
| CS-4 | `perpetuity_1` through `perpetuity_6` are all fully proven and sorry-free (P1-P5 in `Theories/Bimodal/Theorems/Perpetuity/Principles.lean`, P6 in `.../Bridge.lean`). They are **not** registered as Aesop rules: no `@[aesop safe]` annotation anywhere references a `perpetuity_*` name. |
| CS-5 | `Theories/Bimodal/Examples/` contains exactly two files, `BimodalProofs.lean` and `TemporalStructures.lean`, both sorry-free. `ModalProofs.lean`, `TemporalProofs.lean`, and any `*Strategies.lean` do not exist. |
| CS-6 | `Automation/ProofSearch.lean` no longer exists as a single file; it is `Automation/ProofSearch/Core.lean` and `Automation/ProofSearch/Strategies.lean`, both compiled by the green full `lake build`. The historical build failure no longer reproduces. |
| CS-7 | `Theorems/ModalS4.lean` is sorry-free; all four of its theorems, including `s4_diamond_box_conj`, are fully proven. |
| CS-8 | `Metalogic/CompletenessTest.lean` does not exist anywhere in the tree. `Tests/BimodalTest/Theorems/PerpetuityTest.lean` and `.../PropositionalTest.lean` contain zero `sorry` uses. |

## Removal-vs-Correction Rulings (binding; not implementer discretion)

| Stale claim | Ruling | Rationale |
|---|---|---|
| `provable_iff_valid` uses `sorry` (`known-limitations.md:14`) | **Correct, do not remove the limitation.** Rewrite the description to CS-3, naming the real theorems. | The theorem name is phantom, but the underlying limitation (residual Base-frame proof debt) is real. Removing the limitation would overstate completeness. |
| `ModalProofs.lean` / `TemporalProofs.lean` / `*Strategies.lean` rows (`implementation-status.md:116-125`) | **Remove the rows.** Replace the whole Examples table with the two real files per CS-5. | The rows describe files that do not exist; there is nothing to correct them to. |
| `Bimodal/Examples/ModalProofs.lean` / `TemporalProofs.lean` bullets (`examples.md:959-960`) | **Correct in place**, substituting `BimodalProofs.lean` and `TemporalStructures.lean`. | The bullet list has a live purpose (pointing readers at source files); it needs the right names, not deletion. |
| `CompletenessTest.lean (3)` sorry rows (`known-limitations.md:87-89`) | **Replace the limitation body** with CS-8. | Same as above: the file is phantom. |
| Resolved limitations 2, 3, 4, 5 (`known-limitations.md`) | **Retain the heading number, append `(Resolved)` to the heading text, replace the body** with the corresponding canonical statement plus its evidence. Do NOT delete-and-renumber. | Renumbering would silently break any anchor or cross-reference into this document and erases the record of what was fixed. Stable numbering is the lower-risk ruling. |
| `test-coverage.md` sorry-audit numbers (lines 14, 109-126) | **Do not hand-edit the numbers. Add a superseded banner** immediately under the `**Version**:` line pointing to `known-limitations.md` for current status. | The report offered regeneration as an alternative, but `scripts/coverage-analysis.sh` does not exist in this repository (verified: `find . -name coverage-analysis.sh` returns nothing), so regeneration is not available. Hand-editing a script-generated snapshot would fight the next regeneration. |
| `**Proofs pending** (Tasks 132-135, 257)` (`implementation-status.md`, Completeness block) | **Drop the task-number citation** while rewriting the block to CS-3. | `.claude/rules/no-task-references-in-deliverables.md` forbids task-number citations outside `specs/**`; this line is being rewritten anyway. |

## In-Family Scope Extensions (beyond the report's literal per-hit table)

Two items are not separate rows in the report's per-hit table but are covered by evidence the
report already verified, and are in the same "documentation misrepresents proof/integration
status" defect class. They are included so the corrected files are not self-contradictory. Both
are named explicitly here rather than left to implementer judgment.

1. `implementation-status.md` Layer 4 rows: `` `ProofSearch.lean` | 🔶 | Has known issues `` and the
   `**Issues**: ProofSearch.lean has build errors` bullet. Corrected per CS-6, the same evidence
   that governs `troubleshooting.md:375` and `known-limitations.md:34-39`. Leaving these would
   have `implementation-status.md` asserting a build failure that the two files corrected in
   Phase 5 declare resolved.
2. `tactic-registry.md:60`: `` | `TMLogic` | TM-specific automation rules | 🚧 Partial (...) | ``.
   `Automation/AesopRules.lean:51-53` states verbatim that no separate `TMLogic` rule set is
   declared. Leaving this row would directly contradict the disclaimer Phase 6 adds to
   `tactic-development.md`.

## Goals & Non-Goals

**Goals**:
- Every STALE hit in the report's per-hit table is replaced with a statement traceable to the
  canonical status table above.
- Every SCHEMATIC hit retains its illustrative code verbatim and gains an explicit prose
  disclaimer naming the real, currently-proven theorems.
- The ten in-scope files agree with each other on soundness, completeness, perpetuity, sorry
  count, and ProofSearch status.
- Zero `.lean` files modified.

**Non-Goals**:
- Writing or repairing any Lean proof. No `.lean` file is touched, including to fix a sorry.
- The `Logos/Core/Automation/...` path and `Logos.*` import namespace that exist nowhere in the
  repository (`tactic-registry.md`, `examples.md`). Explicitly deferred to a separate follow-up
  per `DECISION.md`.
- Rewriting the rest of `tactic-registry.md`'s "Registered Rules" list. The report found that
  `modal_t_valid` / `modal_4_derivable` / `modal_b_derivable` are also absent from
  `AesopRules.lean` (real names: `axiom_modal_t`, `modal_t_forward`, ...). Correcting those
  requires first deriving the real registered-rule list, which the research did not do. Only the
  `perpetuity_*` line (a proof-status claim) and the `TMLogic` row are in scope. Flag for
  follow-up.
- Reconciling `reference/tactic-reference.md` against `tactic-registry.md`. Tactic-completion
  status, not proof status; flagged by the report as a separate concern.
- The formula strings in `implementation-status.md`'s perpetuity table (e.g. "P1 `□φ ↔ □◇□φ`")
  that do not match the real theorem statements. Only the **status column** is corrected; the
  statement column is left as-is and flagged for follow-up.
- Regenerating `test-coverage.md`'s coverage percentages or definition counts.
- Layer-completion percentages in `project-info/README.md` lines 20-22 (`~60%`, `~80%`, `~50%`)
  and the `SORRY_REGISTRY.md` / `../../../docs/` links in that file. Not proof-status claims and
  not verified by the research.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A phase replaces a false claim with an unverified inverse (e.g. flipping "In Progress" to "Complete" for the un-registered perpetuity Aesop rules) | H | M | The Canonical Status Statements table is the only permitted source of replacement facts, and CS-4 deliberately separates proof-status from integration-status. Any fact not on that table must not be asserted. |
| Phases run in parallel and the ten files drift into mutually inconsistent stories | M | M | Canonical statements are fixed in this plan before any phase runs; each phase quotes them rather than composing its own wording. Phase 7 cross-checks consistency. |
| An implementer "helpfully" fixes the `Logos/` namespace or writes a proof while in the file | M | M | Non-Goals are explicit; Phase 7 verifies `git status --porcelain -- '*.lean'` is empty and greps for `Logos/` churn in the diff. |
| A SCHEMATIC code block gets deleted or rewritten into a status claim | H | L | Each schematic phase states "insert prose only; the code block must be byte-identical before and after". Phase 7 verifies the six `perpetuity_*` stubs still exist in `architecture.md`. |
| Deleting resolved limitations breaks inbound anchors | L | M | The ruling table mandates heading-number retention with `(Resolved)` appended; no renumbering. |
| Hand-edited numbers in `test-coverage.md` conflict with a future script regeneration | M | M | Banner-only treatment; numbers untouched. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 3, 4, 5, 6 | -- |
| 2 | 7 | 1, 2, 3, 4, 5, 6 |

Phases within the same wave can execute in parallel. Phases 1-6 have disjoint file territory: no
file appears in more than one phase, so parallel execution is safe. All facts they need are fixed
in this plan, so no phase depends on another's output.

**File territory** (exclusive ownership per phase):

| Phase | Owns |
|-------|------|
| 1 | `Theories/Bimodal/docs/user-guide/architecture.md` |
| 2 | `Theories/Bimodal/docs/project-info/implementation-status.md` |
| 3 | `Theories/Bimodal/docs/project-info/known-limitations.md` |
| 4 | `Theories/Bimodal/docs/project-info/README.md`, `.../tactic-registry.md`, `.../test-coverage.md` |
| 5 | `Theories/Bimodal/docs/user-guide/troubleshooting.md`, `.../examples.md` |
| 6 | `Theories/Bimodal/docs/user-guide/tutorial.md`, `.../tactic-development.md` |
| 7 | none (read-only verification) |

---

### Phase 1: architecture.md - schematic disclaimer and metalogic status [NOT STARTED]

**Goal**: Disclaim the six-stub perpetuity code block without altering it, and correct the Layer 0
metalogic bullet.

**Tasks**:
- [ ] Insert a status-note callout immediately after the code fence that closes the perpetuity
      block (around line 237) and before the `#### Derivation Trees: Type vs Prop` heading. Content
      per CS-4, framed as: this section sketches the proof system from scratch for pedagogical
      purposes; the `sorry` placeholders above are illustrative, not a live status report.
- [ ] Verify the code block itself is unchanged: all six `theorem perpetuity_1 ... perpetuity_6
      ... := by sorry` lines must remain byte-identical. Do not delete, renumber, or convert them
      into status claims.
- [ ] Consider noting in the same callout that this file is a self-declared roadmap whose
      `Formula` type (6 constructors, `String` atoms) diverges from the real
      `Syntax/Formula.lean` type. This is what makes the block schematic rather than stale.
- [ ] Replace the Layer 0 bullet at line 1296, `"Partial metalogic: Soundness (5/8 axioms proven),
      completeness infrastructure defined"`, using CS-2 and CS-3. Both the "5/8" fraction and the
      "8 axioms" denominator are stale; the current count is 21 schemas.
- [ ] Leave the adjacent `"Complete proof system: TM with 8 axioms, 7 rules"` bullet alone unless
      the same 21-schema evidence plainly applies; if it is changed, it must use the CS-2 count.

**Timing**: 35 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/docs/user-guide/architecture.md` - insert one prose callout after the
  perpetuity code block; rewrite one bullet at line 1296.

**Verification**:
- `grep -c "by sorry" Theories/Bimodal/docs/user-guide/architecture.md` still counts the six
  perpetuity stubs plus any pre-existing others (count must not decrease).
- The new callout appears between the code fence and the `#### Derivation Trees` heading.
- No occurrence of "5/8" remains in the file.

---

### Phase 2: implementation-status.md - status tables [NOT STARTED]

**Goal**: Bring all five stale status rows plus the ProofSearch rows in line with the canonical
statements.

**Tasks**:
- [ ] Line 62: `` `Completeness.lean` | ⏸️ | Infrastructure only `` -> `🔶` with a note per CS-3.
- [ ] Rewrite the `**Completeness** (⏸️ On Hold)` prose block below it per CS-3, and delete the
      `**Proofs pending** (Tasks 132-135, 257)` line's task-number citation per the ruling table.
- [ ] Perpetuity table (lines ~76-85): change the P6 row from `🔶 | Axiomatized` to
      `✅ | Complete (Bridge.lean)`; change the section header `### Perpetuity (🔶 ~85%)` to
      `### Perpetuity (✅ 100%)`. Leave the formula-statement column untouched (Non-Goal).
- [ ] Change the `## Layer 3: Theorems (🔶 Partial)` header only if all its subsections now read
      complete; otherwise leave it. State the choice in the phase report.
- [ ] Line ~91: `` `ModalS4.lean` | 🔶 | Core theorems proven `` -> `✅` per CS-7.
- [ ] Layer 4 table: `` `ProofSearch.lean` | 🔶 | Has known issues `` -> the two real module paths
      with `✅` per CS-6; delete the `**Issues**: ProofSearch.lean has build errors` bullet
      (keep the "Bounded search timeout issues" bullet, which the research did not disprove).
- [ ] Examples section (lines ~116-125): replace the entire table and its header per CS-5. Header
      becomes `## Examples (✅ Complete)`; rows are `BimodalProofs.lean | ✅ | 0` and
      `TemporalStructures.lean | ✅ | 0`. Remove the "Example sorries are intentional pedagogical
      placeholders" note, which is now false.
- [ ] Overall Statistics table, `Known sorries | ~30` -> the CS-1 figure with the per-file
      breakdown.

**Timing**: 40 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/docs/project-info/implementation-status.md` - six edit sites.

**Verification**:
- No occurrence of `~30`, `ModalProofs`, `TemporalProofs`, `Strategies.lean`, or `Tasks 132-135`
  remains in the file.
- `grep -n "Axiomatized" ` returns nothing for the P6 row.

---

### Phase 3: known-limitations.md - resolved and misdescribed limitations [NOT STARTED]

**Goal**: Correct Limitation 1's phantom theorem name and mark Limitations 2-5 resolved without
renumbering.

**Tasks**:
- [ ] Limitation 1 (line ~14): replace `The provable_iff_valid theorem uses sorry` and the
      surrounding description with CS-3. Keep the limitation; only its description was wrong.
      Adjust the "Impact" bullets if they now overstate the gap.
- [ ] Limitation 2 (lines ~34-39, ProofSearch build issues): retitle heading with `(Resolved)`,
      replace body with CS-6.
- [ ] Limitation 3 (line ~66, `~24` sorries in Examples): retitle heading with `(Resolved)`,
      replace body with CS-5.
- [ ] Limitation 4 (lines ~87-89, test-suite sorries): retitle heading with `(Resolved)`,
      replace body with CS-8.
- [ ] Limitation 5 (lines ~103-107, Modal S4 partial): retitle heading with `(Resolved)`,
      replace body with CS-7.
- [ ] "What Works Well" list (line ~160): `✅ Perpetuity principles P1-P5` -> `P1-P6` per CS-4.
      If the list also implies Aesop registration, keep the CS-4 separation explicit.
- [ ] Do NOT delete any limitation heading and do NOT renumber. Preserve heading numbers 1-5.

**Timing**: 45 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/docs/project-info/known-limitations.md` - six edit sites.

**Verification**:
- Headings `## Limitation 1` through `## Limitation 5` all still present, in order.
- No occurrence of `provable_iff_valid`, `CompletenessTest`, or `~24` remains.
- Four headings carry `(Resolved)`.

---

### Phase 4: project-info cluster - README, tactic-registry, test-coverage [NOT STARTED]

**Goal**: Correct the two summary metrics in the project-info README, the perpetuity
registration line and TMLogic row in tactic-registry, and mark test-coverage superseded.

**Tasks**:
- [ ] `project-info/README.md` line 28: `Completeness: Infrastructure only (on hold)` -> CS-3
      (condensed to one line for the metrics list).
- [ ] `project-info/README.md` line 29: `Known Sorries: ~30 (mostly in examples and tests)` ->
      CS-1. The parenthetical is the inverse of the truth and must go.
- [ ] Leave `Total Lean Files: ~40`, `Soundness: Proven`, and the layer percentages above them
      alone (Non-Goals).
- [ ] `tactic-registry.md` line 68: replace
      `` `perpetuity_1` through `perpetuity_6` - Perpetuity principles (🚧 In Progress) `` with a
      formulation that separates proof status from Aesop-integration status per CS-4 — e.g.
      "theorems fully proven (sorry-free), not yet registered as Aesop safe rules (📋 Planned
      integration)". **Do not** flip this to a bare "✅ Complete": the theorems are proven but
      genuinely are not registered, so a bare Complete substitutes one false claim for another.
- [ ] `tactic-registry.md` line 60: the `TMLogic` rule-set row. Replace the `🚧 Partial` status
      with a statement that no separate `TMLogic` rule set is declared; `AesopRules.lean`
      registers into Aesop's default rule set (evidence: `Automation/AesopRules.lean:51-53`).
- [ ] Leave the rest of the "Registered Rules" list untouched (Non-Goal).
- [ ] `test-coverage.md`: insert a banner directly under the `**Version**: Baseline (initial
      measurement)` line reading, in substance: "Superseded — the sorry counts and module status
      below reflect a 2026-01-12 snapshot and are stale. `scripts/coverage-analysis.sh` is no
      longer present in this repository, so this report cannot currently be regenerated. For
      current proof status see `known-limitations.md` and `implementation-status.md`."
- [ ] Do NOT edit any number in `test-coverage.md`, including the `Sorry Placeholders | 5` row and
      the lines 109-126 audit table.

**Timing**: 35 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/docs/project-info/README.md` - two metric lines.
- `Theories/Bimodal/docs/project-info/tactic-registry.md` - two lines (60, 68).
- `Theories/Bimodal/docs/project-info/test-coverage.md` - one inserted banner, no numeric edits.

**Verification**:
- `git diff --stat -- Theories/Bimodal/docs/project-info/test-coverage.md` shows insertions only
  (no deletions beyond the inserted block's own context).
- No `~30` or `In Progress` remains in `README.md` / `tactic-registry.md:68`.

---

### Phase 5: user-guide stale claims - troubleshooting and examples [NOT STARTED]

**Goal**: Correct the ProofSearch build-failure entry and the completeness/file-name claims in
the user guide.

**Tasks**:
- [ ] `troubleshooting.md` line ~375: replace the "ProofSearch is blocked pending architecture
      changes" cause with CS-6. Either mark the entry resolved in place or convert it to a
      historical note; do not silently delete it, since a reader hitting an old error message
      needs to land somewhere.
- [ ] `examples.md` line ~949: replace "The current implementation in `Completeness.lean` has the
      scaffolding with placeholder `sorry`s" with CS-3.
- [ ] `examples.md` lines ~959-960: replace the `Bimodal/Examples/ModalProofs.lean` and
      `Bimodal/Examples/TemporalProofs.lean` bullets with `BimodalProofs.lean` and
      `TemporalStructures.lean` per CS-5 and the ruling table.
- [ ] Do NOT touch any `Logos/Core/Automation/...` path or `import Logos.*` line in `examples.md`
      (Non-Goal, deferred to a follow-up task).

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/docs/user-guide/troubleshooting.md` - one entry.
- `Theories/Bimodal/docs/user-guide/examples.md` - two edit sites.

**Verification**:
- No `ModalProofs.lean` or `TemporalProofs.lean` remains in `examples.md`.
- `grep -c "Logos" Theories/Bimodal/docs/user-guide/examples.md` is unchanged from before the
  phase.

---

### Phase 6: user-guide schematic disclaimers - tutorial and tactic-development [NOT STARTED]

**Goal**: Disclaim the two pedagogical `sorry` sections that reuse real theorem names, leaving
their code intact.

**Tasks**:
- [ ] `tutorial.md`: insert a status note after the perpetuity example (around line 401) and
      before the `### Extension Layers` heading, covering CS-2, CS-3, and CS-4 — the `sorry`
      placeholders in this section are pedagogical stand-ins for a from-scratch walkthrough; in
      the real library `soundness` is fully proven, `completeness_dense`/`completeness_discrete`
      are fully proven with only the general Base-frame case carrying residual debt, and
      `perpetuity_1`-`perpetuity_6` are all proven.
- [ ] `tutorial.md`: leave the anonymous `example ... sorry` blocks (around lines 208, 213)
      untouched. They collide with no real theorem name and the research classified them as
      needing no change.
- [ ] `tutorial.md`: the named `theorem soundness`, `theorem weak_completeness`,
      `theorem strong_completeness`, `theorem perpetuity_1`, `theorem perpetuity_2` blocks must
      remain byte-identical. Prose only.
- [ ] `tactic-development.md`: insert a status note immediately before the "Custom Rule Sets"
      example (around line 359) noting that the hypothetical `TMLogic` rule set is illustrative —
      the real `AesopRules.lean` registers into Aesop's default rule set with no separate
      `TMLogic` rule set declared (`AesopRules.lean:51-53`), and the perpetuity theorems are
      proven but not Aesop-registered (CS-4), cross-referencing `tactic-registry.md`.
- [ ] `tactic-development.md`: the `declare_aesop_rule_sets [TMLogic]` example code and the
      `theorem perpetuity_1`/`perpetuity_2 ... sorry` lines remain byte-identical.

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/docs/user-guide/tutorial.md` - one inserted callout.
- `Theories/Bimodal/docs/user-guide/tactic-development.md` - one inserted callout.

**Verification**:
- `git diff -- Theories/Bimodal/docs/user-guide/tutorial.md
  Theories/Bimodal/docs/user-guide/tactic-development.md` shows insertions only, zero deleted
  lines inside any fenced code block.

---

### Phase 7: Sweep verification [NOT STARTED]

**Goal**: Re-run the original staleness sweep and confirm every surviving hit is either verified
accurate or an intentionally-disclaimed schematic block.

**Tasks**:
- [ ] Re-run the research sweep grep:
      `grep -rniE "sorry|In Progress|NOT STARTED|PARTIAL|pending|infrastructure gap" Theories/Bimodal/docs/`
- [ ] Classify every hit into one of three buckets and record the classification: (a) ACCURATE —
      the claim matches the canonical statements; (b) DISCLAIMED SCHEMATIC — inside or adjacent to
      a code block that now carries a status note; (c) UNRESOLVED — anything else. Bucket (c) must
      be empty, or each entry must be explicitly attributable to a declared Non-Goal.
- [ ] Run targeted phantom-identifier greps over `Theories/Bimodal/docs/`; each must return zero
      hits: `provable_iff_valid`, `ModalProofs\.lean`, `TemporalProofs\.lean`,
      `CompletenessTest`, `~30`, `~24`, `5/8`.
- [ ] Cross-check consistency: grep the ten in-scope files for the sorry count and confirm every
      occurrence states 12 with the CS-1 breakdown (or does not state a count at all). Same check
      for completeness status (CS-3) and perpetuity status (CS-4).
- [ ] Confirm the six `perpetuity_*` stubs still exist in `architecture.md` and the named
      schematic theorems still exist in `tutorial.md` and `tactic-development.md`.
- [ ] Confirm zero `.lean` files modified: `git status --porcelain -- '*.lean'` must be empty, and
      `git diff --stat` must list only files under `Theories/Bimodal/docs/`.
- [ ] Confirm the deferred `Logos/` namespace issue was not touched: the `Logos` occurrence count
      in `examples.md` and `tactic-registry.md` is unchanged.
- [ ] Record any bucket-(c) residue and any newly discovered hit in the implementation summary
      rather than fixing it silently.

**Timing**: 30 minutes

**Depends on**: 1, 2, 3, 4, 5, 6

**Files to modify**:
- None. Read-only verification. If a defect is found, report it; a correction requires reopening
  the owning phase, not an edit from this phase.

**Verification**:
- All seven phantom-identifier greps return zero hits.
- `git status --porcelain -- '*.lean'` is empty.
- Every bucket-(c) entry is either empty or mapped to a declared Non-Goal.

---

## Testing & Validation

- [ ] `grep -rniE "sorry|In Progress|NOT STARTED|PARTIAL|pending|infrastructure gap" Theories/Bimodal/docs/`
      produces only ACCURATE or DISCLAIMED SCHEMATIC hits.
- [ ] Phantom identifiers absent: `provable_iff_valid`, `ModalProofs.lean`, `TemporalProofs.lean`,
      `CompletenessTest`, `~30`, `~24`, `5/8`.
- [ ] Sorry count stated consistently as 12 with the `Metalogic/` breakdown wherever a count
      appears.
- [ ] Completeness status stated consistently per CS-3 across `architecture.md`,
      `implementation-status.md`, `known-limitations.md`, `project-info/README.md`, `examples.md`.
- [ ] Perpetuity status stated per CS-4 with proof-status and Aesop-integration-status separated
      in `tactic-registry.md`.
- [ ] Six `perpetuity_*` schematic stubs intact in `architecture.md`; named schematic theorems
      intact in `tutorial.md` and `tactic-development.md`.
- [ ] `git status --porcelain -- '*.lean'` empty; `git diff --stat` confined to
      `Theories/Bimodal/docs/`.
- [ ] `test-coverage.md` diff is insertion-only.
- [ ] No task-number citation introduced into any file outside `specs/**`
      (`.claude/rules/no-task-references-in-deliverables.md`).

## Artifacts & Outputs

- `specs/396_correct_stale_sorry_claims_in_user_docs/plans/01_docs-staleness-corrections.md` (this file)
- `specs/396_correct_stale_sorry_claims_in_user_docs/summaries/01_docs-staleness-corrections-summary.md`
- Modified: `Theories/Bimodal/docs/user-guide/architecture.md`, `tutorial.md`,
  `tactic-development.md`, `troubleshooting.md`, `examples.md`
- Modified: `Theories/Bimodal/docs/project-info/README.md`, `implementation-status.md`,
  `known-limitations.md`, `tactic-registry.md`, `test-coverage.md`
- Follow-up items to surface in the summary (not created by this task): the `Logos/` namespace
  reconciliation; the `tactic-registry.md` "Registered Rules" name accuracy; the
  `tactic-reference.md` vs `tactic-registry.md` inconsistency; the perpetuity formula strings in
  `implementation-status.md`.

## Rollback/Contingency

Documentation-only and confined to ten files under `Theories/Bimodal/docs/`. Each phase is one
commit, so a defective phase reverts with `git revert` of that commit alone without disturbing the
other five. If a correction turns out to be itself unverified, the fallback is to revert that
specific edit and leave the original claim in place with a "status unverified" marker rather than
assert an unverified inverse — an outdated claim is a smaller defect than a confidently wrong new
one. No build, no `.lean` change, so there is no compilation state to restore.
