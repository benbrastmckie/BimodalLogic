# Implementation Plan: Task #728

- **Task**: 728 - Sweep and repair phantom declaration citations across task records and prose
- **Status**: [IMPLEMENTING]
- **Effort**: 7.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/728_sweep_phantom_declaration_citations/reports/01_phantom-citation-sweep.md
- **Artifacts**: plans/01_phantom-citation-residual-triage.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

The research dispatch for this task did not merely research — it performed and committed the
whole named sweep (commit `3bfb970e4`): it re-verified all eleven dispatch-named phantom
citations, repaired the two that survived, built the durable checker
`scripts/check-phantom-citations.sh`, and fixed incidental instances in three
`FormalSystem/**/README.md` files, `docs/reference/paper-definitions-of-record.md`, and six live
task descriptions in `specs/state.json`. This plan therefore covers **only what genuinely
remains**: confirming that landed work still holds, and discharging the one piece the research
report explicitly deferred — the untriaged body of checker findings in `docs/`, which the
dispatch's HARD CONSTRAINTS put squarely in scope ("Live task descriptions, `docs/` and
`specs/ROADMAP.md` are in scope").

The residual work splits cleanly by *why* a name is flagged, not by where it lives: genuine
phantom Lean declaration citations get repaired at their citing source; names that are real but
not defined here (Mathlib/Lean-core) or not Lean at all (bash arrays, lake targets, linter
option names, Python/exe names, illustrative documentation identifiers) get absorbed into the
checker's allowlists so a future clean run means something. Both halves are needed: repairing
without tuning leaves a 100-finding wall that nobody will read again, and tuning without
repairing hides real defects behind an allowlist.

### Research Integration

Key findings carried forward from `reports/01_phantom-citation-sweep.md`:

- Nine of the eleven dispatch-named instances were already repaired before the sweep ran; the
  remaining two (the refutation-core task's first paragraph, and the three `README.md` files)
  were repaired and committed by the research dispatch.
- The checker is built, committed, advisory-only (exit 0; `--strict` opt-in), and is the
  repository's **one** such checker. Task 726's own description explicitly disclaims ownership
  of it ("THE PHANTOM-CITATION CHECKER IS NOT THIS TASK'S").
- The report's own stated follow-up: "A full manual triage of all 105 is follow-up work, not
  performed in this dispatch". **That is this plan's primary body of work.**
- The report's recorded Decision 2 (`file_scope` unbuilt-destination flagging in
  `validate-state.sh`): recommend, do **not** implement — live incidence dropped from three
  entries to one, and that one is self-documented at its source. Confirmed here: this repo's
  `.claude-extensions.json` carries no resolvable `source_dir`, and no `agent-system/` source
  store exists on this machine, so a durable `.claude/scripts/` edit cannot be made at all. This
  stays a Non-Goal.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's context; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- Confirm, not re-do, the repairs the research dispatch landed in `3bfb970e4`, and confirm that
  the historical artifacts (`specs/*/reports/`, `specs/*/summaries/`, `specs/reviews/`) were left
  untouched by it.
- Triage every current `check-phantom-citations.sh` finding into one of four decided classes, in
  a durable ledger that survives a dispatch boundary.
- Repair every finding triaged as a genuine phantom or misattributed Lean declaration citation,
  at its citing source in `docs/`.
- Extend the checker's `ALLOWLIST` / `ROOT_DENYLIST` (and, where a whole class is better handled
  by the shape rule, the shape rule) so that every non-defect finding is absorbed with a written
  justification — never by suppressing an individual finding ad hoc.
- Leave a residual-findings record: for anything deliberately not absorbed and not repaired, say
  which finding and why.

**Non-Goals**:

- Writing any Lean, or creating any declaration to make a citation true (dispatch HARD
  CONSTRAINT).
- Editing `specs/*/reports/`, `specs/*/summaries/`, or `specs/reviews/*.md` — historical
  artifacts; a correction belongs elsewhere.
- Implementing `file_scope` unbuilt-destination flagging in `.claude/scripts/validate-state.sh`.
  The research report's Decision 2 recommends against it, and the deploy/source-store boundary
  makes it unlandable from here. The recommendation (WARN-only, alongside the existing Check 11)
  stands recorded in the report.
- Adding the `.claude/context/project/lean4/README.md` pointer to the checker that the report's
  Context Extension Recommendations suggest — same unlandable-deploy-tree reason.
- Touching `scripts/check-evidence-probes.sh`'s `WIRED_REPO` array. Its two dead entries are a
  real defect, but they are task 720's own Deliverable 2; repairing them here collides with that
  task's territory.
- Making the checker a blocking gate. It stays advisory (exit 0) with `--strict` opt-in.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Concurrent sibling dispatches (722, 726) are editing `specs/state.json` on this same tree | M | H | This plan touches **no** task description at all (see Phase 5 — the single `state.json` finding is a checker false positive absorbed by allowlist, not a description edit). Re-read any file immediately before editing; stage explicit file lists only, never a directory or glob; never run `git-snapshot.sh` in reverting mode |
| Allowlisting used as a shortcut past a real defect | H | M | Every allowlist addition carries an inline justification naming *what* the identifier actually is (bash array / lake target / Mathlib lemma / documentation example). Phase 6 re-reads the diff of the allowlist hunks against the Phase 2 ledger's class assignment |
| Over-correction: silently deleting prose rather than annotating a correction | M | M | Follow the research report's own practice — annotate the correction so a future reader sees both the error and its fix; strike a name only when nothing accurate replaces it |
| Bare-name matching is a documented false-negative source (`Foo.Bar.baz` cleared by any `baz`) | M | H | Phase 3/4 verify each *qualified* citation's namespace by hand (`grep -rn "^theorem baz\b\|^def baz\b"` then check the enclosing `namespace`), not just bare-name existence |
| Triage ledger lost to a dispatch boundary mid-triage | M | M | The ledger is a committed file under `specs/728_.../`, written incrementally and committed per green sub-step, not held in context |
| A name is absent today but is a legitimate *future target* of a live task | M | M | Restate as a target ("not yet landed; owned by …"), per the report's precedent for `allClosed_derivable`; do not strike it as a fabrication |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4, 5 | 2 |
| 4 | 6 | 3, 4, 5 |

Phases within the same wave can execute in parallel. Phases 3, 4 and 5 are parallel-safe because
their file territories are disjoint by construction: Phase 3 owns the three highest-density
`docs/` files, Phase 4 owns the remaining `docs/` files, Phase 5 owns
`scripts/check-phantom-citations.sh` alone. Phase 2 assigns every finding to exactly one of those
three territories; a finding that would cross a boundary is resolved in Phase 2, not at edit time.

---

### Phase 1: Confirm the landed sweep and establish the triage baseline [COMPLETED]

**Goal**: Establish that the research dispatch's committed repairs still hold on the current tree
and that nothing out of scope was touched, then capture the checker's current output as the
baseline every later phase measures against. This phase re-verifies; it does not repair.

**Tasks**:

- [x] Read `git show --stat 3bfb970e4` and confirm the commit touched only: three
      `FormalSystem/Metalogic/**/README.md` files, `docs/reference/paper-definitions-of-record.md`,
      `scripts/check-phantom-citations.sh` (new), `specs/state.json`, `specs/TODO.md`, and task
      728's own `reports/`, `.return-meta.json`, `metrics.jsonl`. Any `specs/*/reports/` or
      `specs/*/summaries/` path **other than 728's own new report**, or any `specs/reviews/` path,
      is a HARD-CONSTRAINT violation — stop and report it rather than proceeding. *(completed:
      confirmed, 10-file stat matches exactly, no out-of-scope historical artifact)*
- [x] Spot-re-verify three of the report's "already repaired" claims directly against the tree
      (not against the report's text): that no live task description asserts `verifyProof`, that
      the Greek `not_plusValidZTime_neg_Φ` spelling is the one cited, and that the frame-class
      constructors cited anywhere in a live description match `inductive FrameClass` in
      `FormalSystem/ProofSystem/Axioms.lean` (`Base`/`Dense`/`ZTime`/`RTime`). *(completed: all
      three hold — `verifyProof` only appears inside task 482's own withdrawal correction; the
      Latin "Phi" spelling appears only inside 728's own description quoting the historical
      finding, task 710's live description uses the Greek `Φ`; task 722's live description already
      states the correct four constructors and explicitly flags the old "Discrete and Dedekind"
      naming as superseded)*
- [x] Confirm checker singularity: `ls scripts/*.sh` plus a grep for any second phantom/citation
      sweep under `scripts/` and `.claude/scripts/`, and confirm task 726's live description still
      disclaims ownership of it. *(completed: `scripts/check-phantom-citations.sh` is the only
      phantom-citation checker; `scripts/export-lean-citations.py`/`reanchor-lean-citations.py`
      are a different, pre-existing line-anchor-drift tool, not a duplicate; task 726's
      description still contains "THE PHANTOM-CITATION CHECKER IS NOT THIS TASK'S")*
- [x] Run `bash scripts/check-phantom-citations.sh --verbose` and save the full output to the
      scratchpad **and** to `specs/728_sweep_phantom_declaration_citations/baseline-findings.txt`
      (committed, so a later dispatch can diff against it). *(completed)*
- [x] Record in the baseline file: the finding count, the distinct-candidate count, and the
      per-source-file site counts (`awk '/^    - /{print $2}' … | sort | uniq -c | sort -rn`).
      *(completed)*
- [x] Confirm the split that drives this plan's scope: how many findings cite `specs/state.json`,
      how many cite `specs/ROADMAP.md`, how many cite `docs/**`. *(completed: 1 / 0 / 130 across 32
      files — identical to the plan-time hypothesis within +2 candidate pairs of noise)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: At plan time the checker reported **105 findings over 1,026 distinct
candidate pairs**, with **1** site citing `specs/state.json` (`WIRED_REPO`), **0** citing
`specs/ROADMAP.md`, and **130** citing `docs/**` across **32** files — the three densest being
`docs/development/MODULE_INVARIANTS.md` (27), `docs/development/NAMING_CONVENTION_DEVIATION.md`
(16), `docs/development/PUBLICATION_REFACTOR.md` (9). These are hypotheses, not facts: siblings
722 and 726 are editing `specs/state.json` concurrently and may add or remove description
citations. Confirm by re-running the checker in this phase and writing the *measured* numbers into
`baseline-findings.txt`; if the state.json count has risen above 1, the new findings are in scope
for Phase 2 triage and must be added to the ledger.

**Files to modify**:

- `specs/728_sweep_phantom_declaration_citations/baseline-findings.txt` - new; committed baseline
  of checker output plus the measured counts

**Verification**:

- `3bfb970e4`'s file list contains no out-of-scope historical artifact.
- Baseline file exists, is non-empty, and its recorded counts match a fresh checker run.
- Exactly one phantom-citation checker exists in the repository.

---

### Phase 2: Triage every finding into four decided classes [COMPLETED]

**Goal**: Turn the baseline's undifferentiated finding list into a per-finding decision record,
so the three repair/tuning phases can execute without re-deriving judgment. Nothing is edited
outside the ledger in this phase.

**Tasks**:

- [x] Create `specs/728_sweep_phantom_declaration_citations/triage-ledger.md` with one row per
      finding: name, citing file(s), class, and a one-line justification. This is a working
      ledger, deliberately not a `report-format.md`/`plan-format.md` artifact. *(completed; also
      records two checker correctness bugs found and fixed mid-triage, re-dropping findings from
      105 to 94 before classifying — see the ledger's "Checker Fixes" section)*
- [x] Assign each finding exactly one class:
      - **`PHANTOM`** — a Lean declaration citation whose name (or whose namespace, for a
        qualified citation) is genuinely absent. Repaired in Phase 3 or 4.
      - **`UPSTREAM`** — a real Mathlib / Lean-core / metaprogramming name this repo cites but
        does not define (e.g. `MetaM`, `mkAppM`, `dbg_trace`, `register_simp_attr`,
        `CompactIccSpace`, `isOpen_inter`, `isOpen_sUnion`, `isOpen_univ`, `IsSuccArchimedean`,
        `IsPredArchimedean`, `specializes_iff_mem_closure`). Absorbed in Phase 5 via `ALLOWLIST`
        / `ROOT_DENYLIST`.
      - **`NOT-LEAN`** — not a Lean declaration at all: a bash array or sentinel (`WIRED_REPO`,
        `ENFORCE_C17`, `ENFORCE_C20`, `ENFORCE_C20_DECL`, `LANGUAGE_FILE_LAYERS`), a lake target
        or exe root (`defaultTargets`, `mk_all`, `BimodalLogic`, `BimodalTest`, `BimodalTools*`,
        `*Main`), a linter option name (`docBlame`, `docBlameTheorems`, `dupNamespace`,
        `noSorryInProofs`, `unusedDecidableInType`, `isBadNameWithUnderscore`), a Python/script
        identifier (`decl_spans`, `lean_citations.decl_spans`, `lean_debug_artifacts.mask`,
        `env_linter`, `resolve_env`, `dataset_generator`, `proof_extractor`, `comments_only`), or
        a suffix/name fragment (`_1`, `_2`, `_dedekind`, `_discrete`, `_mathlib`, `snake_case`,
        `theorem_name`). Absorbed in Phase 5.
      - **`EXAMPLE`** — an illustrative identifier inside naming/style/docstring/tactic-authoring
        documentation that was never meant as a claim about the tree. Absorbed in Phase 5, but
        **only after** verifying it is genuinely illustrative: a tactic or lemma named in
        `docs/project-info/tactic-registry.md`, `docs/reference/tactic-reference.md`, or
        `docs/user-guide/tactic-development.md` as *available* is a `PHANTOM`, not an `EXAMPLE`,
        if it has no implementation under `FormalSystem/Automation/`. Check `apply_axiom` (5
        sites), `modal_search` (3), `assumption_search`, `tacticModal_t`, `modal_4_tactic`
        individually against `FormalSystem/Automation/` before classing any of them. *(completed:
        all five are real — `apply_axiom`/`modal_t`/`undischarge` as `macro`, `assumption_search`/
        `propDecide` as `elab`, `modal_search`/`deduction` as `syntax`, none previously detected
        by `definition_exists`; `tacticModal_t` and `modal_4_tactic` classed `EXAMPLE` instead,
        each already correctly caveated in its own docs file)*
- [x] For every candidate `PHANTOM` whose citation is *qualified* (e.g. `TaskFrame.ValidOn`,
      `Semantics.Validity.valid_at_world`, `HasAttainedSUP.toHasFaithfulDedekindSUP`,
      `Axiom.minFrameClass`), check the bare name's enclosing `namespace` too — the checker's
      documented bare-name blind spot means a cleared name can still be a wrong-namespace
      citation, and a flagged name can be a renamed-but-live one. Record the live replacement in
      the ledger row when one exists. *(completed: `TaskFrame.ValidOn`, `HasAttainedSUP.
      toHasFaithfulDedekindSUP` and `Axiom.minFrameClass` turned out to be real, correctly
      qualified citations the checker's keyword branch simply couldn't see — fixed structurally
      rather than ledgered as PHANTOM; `Semantics.Validity.valid_at_world` remains genuinely
      absent under any namespace and is ledgered PHANTOM)*
- [x] Treat `docs/development/NAMING_CONVENTION_DEVIATION.md` as a special case and record the
      decision explicitly: its `ZTime`/`RTime` and `defsWithUnderscore` rows are a deliberate,
      labelled Old/New rename record, not an assertion that the old name is live (the research
      report already decided this). Decide in the ledger whether its 16 sites are absorbed by a
      per-name allowlist or by a source-scoped skip, and say which; do not edit the file to make
      the checker quiet. *(completed: per-name allowlist, each entry justified by the file's own
      scheme table; the file needs no edit)*
- [x] Partition the `PHANTOM` rows into Phase 3's territory (the three densest files) and
      Phase 4's territory (every other `docs/` file), writing the owning phase into each row so
      the two phases cannot collide. *(completed: zero PHANTOM rows cite Phase 3's three files;
      all 6 genuine PHANTOM repairs are Phase 4 territory — see the ledger's "Phase 3 / Phase 4
      Territory Split" section)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: The class names above are seeded from a plan-time sample of the 105
findings, not from a completed triage — the per-class membership lists are illustrative, and the
`PHANTOM`/`EXAMPLE` boundary for the tactic names is explicitly unresolved at plan time. Confirm
by classifying from the Phase 1 baseline file directly, and by checking every tactic name against
`FormalSystem/Automation/` before classing it; if the class counts differ materially from the
seeds, the ledger's measured counts win.

**Files to modify**:

- `specs/728_sweep_phantom_declaration_citations/triage-ledger.md` - new; one decided row per
  finding, with owning phase

**Verification**:

- Every finding in `baseline-findings.txt` appears in exactly one ledger row with exactly one
  class and a non-empty justification.
- No ledger row is classed `UPSTREAM`, `NOT-LEAN` or `EXAMPLE` without naming what the identifier
  actually is.
- Every `PHANTOM` row names an owning phase (3 or 4) and, where one exists, its live replacement.
- The `PHANTOM` territories of Phases 3 and 4 share no file.

---

### Phase 3: Repair phantom citations in the three highest-density docs files [COMPLETED]

**Goal**: Repair every ledger-`PHANTOM` citation in `docs/development/MODULE_INVARIANTS.md`,
`docs/development/NAMING_CONVENTION_DEVIATION.md` and `docs/development/PUBLICATION_REFACTOR.md`
— at the point of citation, by correcting to the live declaration, restating as a not-yet-landed
target, or striking the name.

**Tasks**:

- [x] Re-read each file immediately before editing it (concurrent siblings are live on this tree).
      *(no siblings this cycle — sole dispatch, confirmed at dispatch start)*
- [x] For each `PHANTOM` row owned by this phase, apply exactly one of: correct to the live
      declaration named in the ledger; restate as absent / not-yet-landed with the owner named;
      or strike the name where nothing accurate replaces it. Annotate the correction rather than
      silently deleting the sentence, per the research report's over-correction mitigation.
      *(completed: ZERO rows owned by this phase — the Phase 2 ledger's territory split confirmed
      no `PHANTOM` row cites any of this phase's three files. Re-ran the checker scoped to these
      three files' findings directly against the ledger: all 41 findings touching them are
      NOT-LEAN/UPSTREAM/OUT-OF-SCOPE-REAL/VERIFIED-FIELD/ALREADY-ACCURATE, none PHANTOM. No edit
      made to any of the three files.)*
- [x] Apply the `NAMING_CONVENTION_DEVIATION.md` decision from Phase 2 **without** rewriting its
      deliberate Old/New rename rows — if the ledger chose allowlist or source-scoped skip, this
      file may need no edit at all, and that is the expected outcome. *(completed: per-name
      allowlist per the Phase 2 decision; file needs no edit, confirmed)*
- [x] Verify each repair by grep before and after: the replacement name has a definition site
      (`grep -rn "^theorem X\b\|^def X\b\|^lemma X\b\|^abbrev X\b\|^structure X\b\|^inductive X\b"
      --include="*.lean" FormalSystem/`) and its enclosing namespace matches the qualified form
      written into the prose. *(N/A — no repairs in this phase's territory; applies in Phase 4)*
- [x] Add no task-number references to any `docs/` file (`rules/no-task-references-in-deliverables.md`
      — `docs/**` is outside the `specs/**` exemption). Cite durable anchors: filenames, section
      headings, declaration names. *(N/A — no edits made)*
- [x] Re-run `bash scripts/check-phantom-citations.sh --verbose` and confirm each repaired name
      dropped out of the findings list. *(completed: re-ran; findings count 90 (down from 94 after
      the macro/elab/syntax fallback also cleared `apply_axiom`/`assumption_search`/`modal_search`/
      `propDecide`); the 41 findings touching this phase's three files are unchanged from the
      Phase 2 ledger's disposition)*
- [x] Commit per green sub-step (per file repaired and re-verified), staging an explicit file
      list only. *(N/A — no file repairs to commit; this phase's own plan/progress updates are
      committed as its closing step)*

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: These three files are hypothesized to hold 52 of the 130 `docs/` citation
sites (27 / 16 / 9), of which an unknown subset is `PHANTOM` — plausibly a minority, since
`NAMING_CONVENTION_DEVIATION.md`'s 16 are expected to class as a deliberate rename record and
`PUBLICATION_REFACTOR.md`'s 9 lean toward `NOT-LEAN` tooling names. Confirm from the Phase 2
ledger's actual `PHANTOM` partition, not from these numbers; if this phase's `PHANTOM` count turns
out to be under five, fold the remainder of its budget into Phase 4 rather than padding it.

**Files to modify**:

- `docs/development/MODULE_INVARIANTS.md` - correct or restate phantom declaration citations
- `docs/development/NAMING_CONVENTION_DEVIATION.md` - only if the Phase 2 decision calls for an
  edit here; expected to need none
- `docs/development/PUBLICATION_REFACTOR.md` - correct or restate phantom declaration citations

**Verification**:

- Every `PHANTOM` row owned by this phase is marked resolved in the ledger with the action taken.
- Every name written as a correction has a confirmed definition site and a matching namespace.
- Checker re-run shows each repaired name gone, and no newly introduced finding.
- Diff read-through confirms every changed hunk is prose; no Lean file is touched.

---

### Phase 4: Repair phantom citations across the remaining docs files [COMPLETED]

**Goal**: Repair every ledger-`PHANTOM` citation in the `docs/` files not owned by Phase 3 —
the long tail of architecture ADRs, reference pages, project-info pages and user-guide pages.

**Tasks**:

- [x] Re-read each file immediately before editing it. *(done for each of the five files edited)*
- [x] Work the ledger rows owned by this phase in file order, applying the same three-way choice
      (correct / restate as absent / strike) and the same annotate-don't-delete discipline as
      Phase 3. *(completed: 6 genuine PHANTOM repairs across 5 files — see ledger "Phase 4 Repair
      Log")*
- [x] Give particular care to the frame-class and validity families, which the research report
      identified as the live propagation vector: `FrameClass.Dedekind`, `FrameClass.Discrete`,
      `soundness_dedekind`, `soundness_discrete`, `ValidDedekind`, `TaskFrame.ValidOn`,
      `TaskFrame.IsDiscrete`, `TaskFrame.IsComplete`, `TaskFrame.IsSuccArchDiscrete`,
      `valid_iff_allClosed`, `validity_decidable`, `validity_has_decision_procedure`,
      `consequence_completeness`, `Semantics.Validity.valid_at_world`. Resolve each against
      `inductive FrameClass` in `FormalSystem/ProofSystem/Axioms.lean` and the live
      `StrongCompleteness.lean` declarations, exactly as the research dispatch did for the three
      `README.md` files — do not carry a name forward on the strength of the text citing it.
      *(completed: of this whole list, only `consequence_completeness` and
      `Semantics.Validity.valid_at_world` were genuine PHANTOM and repaired; `FrameClass.Dedekind`/
      `Discrete`, `soundness_dedekind`/`discrete`, `ValidDedekind` were already correctly
      documented as renamed in NAMING_CONVENTION_DEVIATION.md; `TaskFrame.ValidOn`/`IsDiscrete`/
      `IsComplete` turned out to be real, qualified citations the checker's own detection gap had
      misreported — fixed structurally in Phase 2, not ledgered PHANTOM; `valid_iff_allClosed`/
      `validity_decidable`/`validity_has_decision_procedure` were already correctly documented in
      ADR-007 as OPEN/RETIRED, not live claims; `TaskFrame.IsSuccArchDiscrete` is part of the same
      already-accurate NAMING_CONVENTION_DEVIATION.md rename record)*
- [x] For the two long `PlusSlicedCertificate.FiniteCarrier.*` citations
      (`no_finite_carrier_sat'`, `not_plusValidZTime_neg_θ'`), determine whether the citing prose
      is asserting a landed declaration or naming a not-yet-landed target of a live task, and
      restate accordingly rather than striking. *(completed: both are landed, real theorems —
      `theorem no_finite_carrier_sat'`/`not_plusValidZTime_neg_θ'` in
      `PlusSlicedCertificate/Limits/FiniteCarrier.lean`. The citing prose in theorem-index.md
      already correctly asserts them as landed; the checker's pre-fix trailing-`\b` bug was the
      only reason they ever appeared as findings — fixed in Phase 2, no docs edit needed.)*
- [x] Add no task-number references to any `docs/` file. *(confirmed: none of the five edits
      references a task number — pre-edit-gate hook would have blocked it)*
- [x] Re-run the checker and confirm each repaired name dropped out. *(completed: `_dedekind`,
      `_discrete`, `consequence_completeness`, `temp_k_dist` fully dropped out — corrected to the
      live name with no old name left backticked. `modal_4_derivable`, `modal_b_derivable`,
      `necessitation_from_modal_k`, `not_setConsistent_of_setDerivable_bot`,
      `Semantics.Validity.valid_at_world` still appear, by design — the annotate-don't-delete
      repair keeps the now-corrected-but-still-absent old name backticked for traceability, so the
      checker (which flags any backticked absent name regardless of surrounding context) still
      reports it. These five join the ALLOWLIST in Phase 5 with a "post-repair, correctly
      annotated as absent" justification — see ledger.)*
- [x] Commit per green sub-step, explicit file lists only. *(committed below)*

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: This phase is hypothesized to own roughly 78 citation sites across roughly
29 `docs/` files (the 130-site total minus Phase 3's 52), again with only a subset classing as
`PHANTOM`. Confirm from the Phase 2 ledger partition. If the `PHANTOM` count in this territory
exceeds ~25 — enough to push past one agent run — split it at a file boundary and checkpoint with
`bash .claude/scripts/git-snapshot.sh 728 --no-revert` before continuing, rather than running
long.

**Files to modify**:

- `docs/theorem-index.md`, `docs/reference/API_REFERENCE.md`,
  `docs/architecture/ADR-007-Decidability-One-Directional.md`,
  `docs/architecture/ADR-008-FrameClass-Validity-Seam.md`,
  `docs/architecture/total-history-validity-decisions.md`,
  `docs/architecture/BFMCS_ARCHITECTURE.md`, `docs/reference/paper-definitions-of-record.md`,
  `docs/reference/state-topology-appendix-support.md`,
  `docs/reference/transcription-audit-surface.md`, `docs/project-info/implementation-status.md`,
  `docs/project-info/test-coverage.md`, `docs/project-info/known-limitations.md`, and the
  remaining long-tail `docs/**` files the Phase 2 ledger assigns here - correct or restate
  phantom declaration citations
- Any file in this list whose rows all class non-`PHANTOM` is left untouched; the list is the
  candidate territory, not a mandate to edit every entry

**Verification**:

- Every `PHANTOM` row owned by this phase is marked resolved in the ledger with the action taken.
- Every correction's name has a confirmed definition site and matching namespace.
- Checker re-run shows each repaired name gone, and no newly introduced finding.
- Diff read-through confirms every changed hunk is prose.

---

### Phase 5: Absorb non-defect findings into the checker's allowlists [COMPLETED]

**Goal**: Extend `scripts/check-phantom-citations.sh` so that every `UPSTREAM`, `NOT-LEAN` and
`EXAMPLE` finding is absorbed with a written justification, making a near-clean run meaningful
rather than aspirational. This phase owns that one file and no other.

**Tasks**:

- [x] Re-read the script's `ALLOWLIST` and `ROOT_DENYLIST` arrays and their surrounding header
      sections before editing, so additions land in the existing documented structure rather than
      beside it.
- [x] Add each `UPSTREAM` name to `ALLOWLIST` (or its namespace root to `ROOT_DENYLIST` where the
      whole root is upstream), grouped with a short inline comment naming the source — e.g.
      Mathlib order/topology lemmas, Lean metaprogramming (`MetaM`, `mkAppM`, `register_simp_attr`,
      `dbg_trace`/`dbgTrace`). *(completed: 13 names added to ALLOWLIST in one UPSTREAM-commented
      group)*
- [x] Add each `NOT-LEAN` name, grouped by what it actually is — bash sentinels and arrays, lake
      targets and `lean_exe` roots, `batteries/runLinter` option names, Python/script identifiers,
      name fragments — each group carrying one comment line that says so. `WIRED_REPO` belongs
      here: it is a bash array name quoted verbatim from `scripts/check-evidence-probes.sh` in a
      live task description, not a declaration claim, and it is the **only** finding citing
      `specs/state.json`. Absorbing it here is what satisfies the dispatch's "no live task
      description asserts a declaration that does not exist" without editing a description that
      two sibling dispatches are concurrently holding. *(completed: 5 sub-groups added — bash
      sentinels/arrays incl. `WIRED_REPO`, lake targets, linter options, Python identifiers, bare
      fragments/placeholders — plus a 6th group this phase's Phase 2 research surfaced that the
      original class list did not anticipate: OUT-OF-SCOPE-REAL names that are genuinely real Lean
      declarations under `BimodalTools/`/`scripts/`, outside this checker's documented
      `FormalSystem/`-only search root; see ledger. `WIRED_REPO` confirmed still the only finding
      citing `specs/state.json` throughout — now 0, since it is absorbed, and no sibling
      description was edited.)*
- [x] Add each `EXAMPLE` name only if Phase 2 confirmed it illustrative; any tactic name that
      turned out to have no implementation under `FormalSystem/Automation/` was reclassed
      `PHANTOM` and belongs to Phase 3/4 instead, not here. *(completed: 12 EXAMPLE names added,
      each independently confirmed illustrative — paper notation, teaching examples, a historical
      test artifact, naming-convention anti-patterns/illustrations; every tactic name with a real
      `macro`/`elab`/`syntax` implementation was instead fixed structurally via Phase 2's checker
      fallback 3, never allowlisted as EXAMPLE)*
- [x] Where a whole *class* is better handled structurally than name-by-name — a bare name
      fragment like `_1`/`_2`/`_dedekind` that the CANDIDATE SHAPE rule should never have
      admitted — prefer tightening the shape rule, and extend the header's CANDIDATE SHAPE
      section to describe the new exclusion. Do not change the exit-status contract: advisory
      exit 0 by default, `--strict` opt-in. *(completed differently from anticipated: the
      structural fix that mattered most was not a CANDIDATE SHAPE tightening but three
      `definition_exists` DETECTION fixes made in Phase 2 — qualified-prefix support, the
      primed/unprimed `\b` fix, and the macro/elab/syntax/notation fallback — which resolved far
      more findings (16: 12 dropped between the 105 and 94 baselines, plus 4 more via the fallback
      added later) than any single CANDIDATE SHAPE change would have. `BimodalTools` was added to
      `ROOT_DENYLIST` as the one shape-level structural fix in this phase, covering any future
      qualified `BimodalTools.X` citation. Exit-status contract unchanged: advisory 0 by default,
      `--strict` opt-in, confirmed below.)*
- [x] Update the header's LIMITATIONS section if any edit changes what a clean run means.
      *(completed in Phase 2: added a LIMITATIONS bullet documenting the structure-field detection
      non-generalization, so a clean run is correctly understood as "no untriaged finding", not
      "every citation mechanically verified down to field level")*
- [x] Re-run `bash scripts/check-phantom-citations.sh --verbose` after each group of additions and
      confirm the intended findings dropped and no genuine `PHANTOM` row was silenced by a
      too-broad allowlist entry — cross-check the surviving finding list against the ledger's
      `PHANTOM` rows. *(completed: single combined edit, re-run afterward — 0 findings; all 6
      Phase 4 PHANTOM repairs independently re-confirmed fixed, see ledger)*
- [x] Also run `bash scripts/check-phantom-citations.sh --strict` once and record its exit status
      and residual count, as the measured answer to "could this be a gate yet?". *(completed: exit
      0, 0 residual findings — this measured result, "yes, a clean --strict run is achievable
      today", is recorded in Phase 6's final verification rather than acted on here; making the
      checker a blocking gate is a declared Non-Goal of this plan)*
- [x] Commit per green sub-step (per group absorbed and re-verified). *(completed: one commit,
      since all groups landed together in a single verified-green edit)*

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: At plan time roughly 70-80 of the 105 findings look like `UPSTREAM`,
`NOT-LEAN` or `EXAMPLE` from their names alone — a guess, not a measurement, and the
`EXAMPLE`/`PHANTOM` boundary for the tactic names is specifically unresolved. Confirm from the
Phase 2 ledger's class counts. Confirm too that no allowlist entry silences a `PHANTOM` row, by
diffing the post-edit finding list against the ledger's `PHANTOM` partition rather than against
the raw finding count.

**Files to modify**:

- `scripts/check-phantom-citations.sh` - extend `ALLOWLIST` / `ROOT_DENYLIST` with grouped,
  justified entries; tighten CANDIDATE SHAPE where a whole class warrants it; update the header's
  CANDIDATE SHAPE and LIMITATIONS sections to match

**Verification**:

- `bash scripts/check-phantom-citations.sh` still exits 0 (advisory contract unchanged).
- `bash scripts/check-phantom-citations.sh --strict` exits 1 only if residual findings remain, and
  its residual count is recorded.
- `bash -n scripts/check-phantom-citations.sh` passes; `--help` still renders the header cleanly.
- No surviving finding is a ledger `PHANTOM` row, and no absorbed finding lacks a justification
  comment.
- `WIRED_REPO` no longer appears, and `specs/state.json` contributes zero findings.

---

### Phase 6: Final verification, residual record, and acceptance check [COMPLETED]

**Goal**: Close the task against the dispatch's four acceptance clauses, with measured evidence
for each, and record whatever remains deliberately unaddressed.

**Tasks**:

- [x] Re-run `bash scripts/check-phantom-citations.sh --verbose` and diff against
      `baseline-findings.txt`. Write the final state into the ledger: findings absorbed, findings
      repaired, findings residual. *(completed: 0 findings, down from the Phase 1 baseline's 105;
      6 repaired, 86 absorbed, 0 residual — see ledger "Phase 6" section)*
- [x] For every residual finding, record in the ledger which it is and why it was neither
      repaired nor absorbed — a residual with no reason is not acceptable closure. *(vacuous: 0
      residual findings, stated explicitly in the ledger rather than left implied)*
- [x] Confirm acceptance clause by clause, with the command that shows it. *(all four confirmed
      with command evidence — see ledger "Phase 6: Final Verification and Acceptance")*
- [x] Run the full gate set: `bash .claude/scripts/verify-deploy.sh`. Also run
      `bash .claude/scripts/validate-state.sh` and confirm 0 FAIL with only pre-existing WARNs,
      and `bash scripts/readme-lint.sh` if any `README.md` was touched. No Lean source was
      modified by this plan, so no `lake build` is required — state that explicitly rather than
      leaving it implied. *(completed: verify-deploy.sh PASS, 14 checks, 0 failures;
      validate-state.sh 0 FAIL, 17 pre-existing WARNs unrelated to this task; readme-lint.sh N/A,
      no README.md touched; lake build N/A, no .lean file touched)*
- [x] Record the two standing recommendations the research report made and this plan deliberately
      did not implement, so they are not silently dropped: the WARN-only `file_scope`
      unbuilt-destination check for `validate-state.sh` (blocked on an unresolvable `source_dir`),
      and the `.claude/context/project/lean4/README.md` pointer to the checker (same blocker).
      *(recorded in ledger)*
- [x] Final commit, explicit file list.

**Timing**: 1.0 hours

**Depends on**: 3, 4, 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:

- `specs/728_sweep_phantom_declaration_citations/triage-ledger.md` - final disposition per
  finding, residual record, acceptance evidence

**Verification**:

- `bash .claude/scripts/verify-deploy.sh` passes (the complete gate set for this repository).
- `bash .claude/scripts/validate-state.sh` reports 0 FAIL.
- Checker re-run's residual list is fully accounted for in the ledger.
- All four acceptance clauses are confirmed with the command output that shows each.
- `git diff --stat 3bfb970e4..HEAD` contains no out-of-scope historical artifact path.

---

## Testing & Validation

- [x] `bash scripts/check-phantom-citations.sh` exits 0; its residual finding count is recorded
      and every residual is justified in the ledger. *(0 findings; 0 residual)*
- [x] `bash scripts/check-phantom-citations.sh --strict` exit status recorded (the measured answer
      to whether this can become a gate yet). *(exit 0 — a clean strict run is achievable today;
      making it a gate stays a declared Non-Goal)*
- [x] `bash -n scripts/check-phantom-citations.sh` passes and `--help` renders. *(confirmed)*
- [x] Zero findings cite `specs/state.json`; zero cite `specs/ROADMAP.md`. *(confirmed — 0
      findings overall)*
- [x] Every name introduced as a correction has a confirmed definition site under
      `FormalSystem/**/*.lean` with a matching enclosing namespace. *(confirmed by grep for
      `consequence_completeness_base`/`_rtime`, `temporalKDistDerived`, `temporal4Derived`,
      `minus_soundness_ztime`/`_rtime`, `minus_not_derivable_nil_bot_ztime`,
      `SetConsistent.bot_not_mem`)*
- [x] `bash .claude/scripts/verify-deploy.sh` passes. *(14 checks, 0 failures)*
- [x] `bash .claude/scripts/validate-state.sh` reports 0 FAIL (pre-existing WARNs acceptable).
      *(0 FAIL, 17 pre-existing WARNs)*
- [x] No file under `specs/*/reports/`, `specs/*/summaries/` or `specs/reviews/` was modified,
      other than task 728's own artifacts. *(confirmed via `git diff --stat 3bfb970e4..HEAD`)*
- [x] No `docs/` or `scripts/` file gained a task-number reference. *(confirmed — the pre-edit
      gate hook would have blocked any such reference)*
- [x] No `.lean` file was modified. *(confirmed via per-commit `git log --name-only`)*

## Artifacts & Outputs

- `specs/728_sweep_phantom_declaration_citations/baseline-findings.txt` — committed checker
  baseline plus measured counts (Phase 1)
- `specs/728_sweep_phantom_declaration_citations/triage-ledger.md` — per-finding class, action,
  final disposition, residual record, acceptance evidence (Phases 2 and 6)
- Repaired `docs/**` prose citations (Phases 3 and 4)
- `scripts/check-phantom-citations.sh` with justified allowlist/shape extensions (Phase 5)
- An execution summary at `specs/728_sweep_phantom_declaration_citations/summaries/01_*-summary.md`

## Rollback/Contingency

Every phase commits per green sub-step, so rollback is per-commit `git revert` of the specific
phase commits — no snapshot-and-reset is needed, and none should be taken in reverting mode while
sibling dispatches 722 and 726 are live on this tree. For a defensive checkpoint before a large
long-tail edit batch in Phase 4, use `bash .claude/scripts/git-snapshot.sh 728 --no-revert`, which
is durable without touching the working tree.

Contingency by failure mode:

- **A repair turns out to need a Lean declaration created** — stop. That is a dispatch HARD
  CONSTRAINT violation. Restate the citation as a not-yet-landed target naming its owner, and
  record the gap in the ledger.
- **A ledger class turns out wrong mid-repair** — amend the ledger row first, then act on the
  amended class. The ledger is the decision record; an undocumented reclass is how this task's
  own defect class propagates.
- **A sibling dispatch's edit collides** — per the dispatch's territory note: if a foreign commit,
  a foreign uncommitted modification, or a build you did not start appears, check `git log` to
  confirm it is not your own work, then STOP and report rather than proceeding.
- **Phase 4's long tail overruns one agent run** — checkpoint with `--no-revert`, commit what is
  green, and mark the phase `[PARTIAL]` with the ledger rows still open; the ledger makes resumption
  mechanical.
