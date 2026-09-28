# Implementation Plan: Task #687

- **Task**: 687 - Cross repo citation audit gating
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: 688 (completed)
- **Research Inputs**: specs/687_cross_repo_citation_audit_gating/reports/01_cross-repo-citation-audit-gating.md
- **Artifacts**: plans/01_cross-repo-citation-gating.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Close the cited side of the cross-repository citation gap: widen the generated citation
manifest's seed list so the declarations the consuming adequacy argument actually cites are
protected by the enforced C35 freshness invariant, and record every correction the consuming
table owes — including a second, previously unrecorded drift cluster — name-keyed and
line-number-free, on this side where it can be kept honest. Nothing under
`~/Projects/ModelChecker` is written; that repository's table correction is proposed here by
mechanical lookup, not reached across for. Done means: the seed list covers the `ShiftSet.lean`
declarations §4.1 of the consuming document cites, the regenerated manifest is byte-current,
`docs/reference/transcription-audit-surface.md` carries both the second drift cluster and an
explicit hand-off block for the three unreached residue rows, and the full build-free invariants
pass is green.

### Research Integration

The research report (`reports/01_cross-repo-citation-audit-gating.md`) is integrated as follows:

- **Finding 1** (the +38 drift reconfirmed at 263/274/289/300, manifest byte-current, sorry
  counts still 0) is treated as a *hypothesis to re-confirm at implementation time*, per the task
  description's own "re-verify before editing" instruction — Phase 1 re-runs it rather than
  copying the numbers forward.
- **Finding 2** (a second drift cluster: six of nine `ShiftSet.lean` citations in the consuming
  document's §4.1 proof-mapping table now name the wrong declaration, traced to commit
  `ef4707035`, at declarations the 53-name seed list does not cover) is the substance of Phases 2
  and 3. It is folded into this task rather than split out, on the research report's own reasoning:
  same failure mode, same consuming document, same mechanism gap.
- **Finding 3** (the 24-row / 27-declaration residue is *already fully recorded* in
  `docs/reference/transcription-audit-surface.md`, rows 3/20/24 being the three the consuming
  audit does not reach, with row 24 conditional on which time-shift statement is cited) means no
  residue *content* needs drafting. Phase 4 only makes those three rows hand-off-shaped.
- **Finding 4** (no cross-repository counterpart exists; the consuming side has a
  `BIMODAL_LOGIC_PATH` convention a future consumer would reuse) becomes a named, deferred
  proposal in Phase 4 — deliberately not implemented, being outside this repository's reach.
- **Recommendation 1** selects **seed-list extension** over authoring a new cross-repository
  script. This plan adopts that choice; see Risks for why the alternative is deferred rather than
  rejected.

### Prior Plan Reference

No prior plan. This is artifact round 01 for this task.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch. `specs/ROADMAP.md` exists and was consulted
opportunistically; it carries no item about cross-repository citation gating, the citation
manifest, or the consuming repository's adequacy argument. No roadmap review/update phases are
included, and ROADMAP.md is not written by this plan.

## Goals & Non-Goals

**Goals**:
- Re-verify, against today's tree rather than against the research report's snapshot, the four
  corrected ZTimeSharpness lines, the sorry-count claim, and the second drift cluster's extent.
- Extend `scripts/lean-citation-seeds.txt` to cover the `ShiftSet.lean` declarations the consuming
  document's §4.1 table cites but C35 does not yet protect, and regenerate
  `scripts/lean-citation-manifest.json` from it.
- Record the second drift cluster in `docs/reference/transcription-audit-surface.md`'s
  "Corrections the consuming table owes" table, in the same "what is wrong / declarations
  involved / what to do" shape, resolved against the manifest and free of line numbers.
- Make the three unreached residue rows (3, 20, 24 — with row 24's conditional framing preserved)
  copy-ready for the consuming audit's own §4.2, without overstating row 24 as a flat omission.
- Record the "consuming side consumes the manifest" option as a named, deferred, cross-repository
  proposal rather than silently dropping the second half of the task description's instruction.

**Non-Goals**:
- Writing, patching, or PRing anything under `~/Projects/ModelChecker`. The table correction
  belongs there; this task proposes it, never applies it.
- Building the consuming-side manifest-consumer gate. Named and deferred (Phase 4), not built.
- Changing any residue *content* in `docs/reference/transcription-audit-surface.md` — the 24-row /
  27-declaration table is correct as landed and its counts must not move.
- Any Lean source edit. No file under `FormalSystem/` is touched.
- Re-anchoring this repository's own internal `file.lean:NNN` citations (C20's job, already gated).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The research report's line numbers (263/274/289/300) or the second cluster's spans have drifted again since the report was written | M | M | Phase 1 re-derives every number from the exporter and the live tree before any edit; no number is carried forward from the report into a file |
| A newly seeded name fails to resolve, or resolves ambiguously, turning the enforced C35 red | H | M | The exporter exits non-zero with a per-name diagnostic; Phase 2 runs it before committing and treats a non-resolving name as a finding (rename or typo) to fix, never as a name to drop silently |
| Committing the extended seed list without the regenerated manifest leaves C35 red mid-phase | H | M | Phase 2 is declared `atomic-batch` over exactly `{seeds, manifest}` — the intermediate seeds-only state is expected red and is not committed |
| New prose in `transcription-audit-surface.md` introduces a `file.lean:NNN` citation, tripping the enforced C20 tier 2 (that file is publication-facing scope) | H | L | Every correction row is name-keyed and points at the manifest; Phase 3 and Phase 4 each run a targeted `\.lean:[0-9]+` grep over the file before committing, and Phase 5's full pass is the backstop |
| The instance-shaped declarations (`fibre_isRegular`, `frame_isRegular`) or the attribute-prefixed `@[reducible] def fibre`/`frame` resolve differently than plain theorems | M | L | `scripts/lib/lean_citations.py` already matches `instance` and walks back past `@[...]` attribute lines; Phase 2 confirms per name from the exporter's own output rather than assuming |
| Scope creep into implementing the `~/Projects/ModelChecker`-side consumer | M | M | Explicitly a Non-Goal and a deferred proposal (Phase 4); the task's `file_scope` contains no path outside this repository |
| The recorded corrections go stale again before the consuming repository acts | M | M | Follow the existing convention: point at "resolve against the manifest" rather than hard-coding any line number, exactly as the existing corrections table already does |
| A docs count elsewhere (`docs/reference/README.md`, `docs/development/MODULE_INVARIANTS.md`) contradicts the edited page — both are outside this task's `file_scope` | L | L | Phase 5 checks them read-only; the 24/27 residue counts do not move, so no edit is expected. If one is genuinely needed, record it as an out-of-scope finding rather than editing outside `file_scope` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phase 2 needs
Phase 1's re-derived name set, Phase 3 must resolve its rows against Phase 2's regenerated
manifest, and Phases 3 and 4 both edit `docs/reference/transcription-audit-surface.md`, so they
are ordered rather than parallelised.

### Phase 1: Re-verify the measured facts against today's tree [COMPLETED]

**Goal**: Replace every number and name inherited from the research report with one derived from
the live tree, so no later phase writes a figure it did not itself measure.

**Tasks**:
- [x] Run `python3 scripts/export-lean-citations.py --check`; record the exit status and whether
      the committed manifest is byte-current before any edit. *(completed: exit 0, "53 seeded
      name(s) resolved", byte-current)*
- [x] From the manifest (not from the report), read the current keyword lines for
      `not_validIn_base_prior_UZ`, `not_validIn_base_z1`, `prior_UZ_minFrameClass_sharp`,
      `z1_minFrameClass_sharp`, and note whether they still equal 263/274/289/300. *(completed:
      confirmed unchanged — 263/274/289/300)*
- [x] Re-measure `grep -c sorry` for `FormalSystem/Semantics/ShiftSet.lean`,
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Agreement.lean`,
      `.../WitnessFamily/Decide.lean`, `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`.
      *(completed: all four still 0)*
- [x] Re-read `~/Projects/ModelChecker/code/src/model_checker/theory_lib/bimodal/docs/ADEQUACY.md`
      §4.1 and §4.2 **read-only** and enumerate every `ShiftSet.lean:NNN` citation it currently
      carries, with the declaration each row names. *(completed: 9 ShiftSet.lean citations plus
      one WitnessFamily/Std.lean citation in the same row, enumerated)*
- [x] For each such declaration, resolve its current span from the live tree (a scratch seed probe
      under the session scratchpad, never under `scripts/`) and classify each citation as
      lands-in-named-declaration / wrong-declaration / field-citation / correct-but-loose.
      *(completed: 8 wrong-declaration-class, 3 correct-but-loose — diverges from the research
      report's "six of nine"; see scratchpad classification)*
- [x] Write the resulting name list and classification to the session scratchpad as the input
      Phase 2 and Phase 3 consume. *(completed: phase1-classification.md in session scratchpad)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: the research report asserts four corrected lines (263, 274, 289, 300), a
sorry count of 0 at four files, and "six of nine" `ShiftSet.lean` §4.1 citations naming the wrong
declaration plus one further wrong-declaration hit on a second file:line. Every one of these is a
hypothesis. Confirm by the measurements above; if any differs, use the measured value and note
the divergence in the phase's commit message — do not silently reconcile to the report.

**Files to modify**:
- None. This phase is read-only; its output is a scratchpad note, not a repository file.

**Verification**:
- `python3 scripts/export-lean-citations.py --check` exit status recorded.
- `git status --porcelain` shows no change under `scripts/` or `docs/` attributable to this phase.
- No file under `~/Projects/ModelChecker` is modified (`git -C ~/Projects/ModelChecker status
  --porcelain` unchanged from its pre-phase state).

---

### Phase 2: Extend the seed list and regenerate the manifest [COMPLETED]

**Goal**: Bring the declarations the consuming §4.1 table cites under C35's protection, so a
future drift at those names fails here rather than rotting silently over there.

**Tasks**:
- [x] Add the Phase-1-confirmed `ShiftSet.lean` declaration names to
      `scripts/lean-citation-seeds.txt` under a new `##` group whose comment states, in the file's
      existing voice, that these are the §4.1 proof-mapping citations and that they were already
      wrong when seeded (so a reader does not mistake seeding for repair). *(completed)*
- [x] Expected candidate set from research, to be confirmed not assumed:
      `FormalSystem.Semantics.ShiftSet.shRel_saturation`,
      `FormalSystem.Semantics.ShiftSet.fibre_isRegular`,
      `FormalSystem.Semantics.ShiftSet.frame_isRegular`,
      `FormalSystem.Semantics.ShiftSet.forward_repr`,
      `FormalSystem.Semantics.ShiftSet.total_eq_orbit`, plus the parent declarations behind the
      `fibre`/`frame`/`ShiftTruth` citations and the `ShiftSet#sep` field row (field rows use the
      `Parent.Name#field` form). `shRel_comp` and `shRel_serial` are **already** seeded — do not
      duplicate them. *(completed: all 9 confirmed and added, exactly as expected)*
- [x] Run `python3 scripts/export-lean-citations.py` to regenerate
      `scripts/lean-citation-manifest.json`. *(completed: 63 seeded name(s) resolved)*
- [x] If any name exits non-zero as UNRESOLVED or AMBIGUOUS, fix the seed line (it is a rename or
      a typo) rather than removing the name; re-run until exit 0. *(completed: no name required a
      fix — all 10 additions resolved on the first run)*
- [x] Re-run `python3 scripts/export-lean-citations.py --check` and confirm exit 0 (byte-current).
      *(completed: exit 0)*
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and confirm C35 reports PASS.
      *(completed: PASS C35, and the full gate run is ALL CHECKS PASSED)*
- [x] Commit seed list and manifest together as one objective. *(completed)*
- [x] *(deviation: altered — added a tenth name, `FormalSystem.Semantics.Truth.box_const`, beyond
      the plan's nine-name expected set. Phase 1's re-verification found the §4.1 Lemma-3 row's
      second file:line citation (`WitnessFamily/Std.lean:101`) does not merely land on the wrong
      line but names the wrong file entirely for `box_const` — its real location is
      `TruthTransport.lean:310`. Seeding it is required for Phase 3's own verification clause
      ("every declaration named in the new row(s) appears in the manifest"), since the
      corrections table must name `box_const` to describe this citation's failure.)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase asserts a specific enumerated name set and an implied new seed
count (53 plus the additions). Both are hypotheses. Confirm by the exporter's own exit status and
by re-reading the regenerated manifest's entry count; record the actual post-change count in the
commit message rather than asserting the projected one. Note that the seed-file *header* carries
no hard-coded count and must not gain one.

**Files to modify**:
- `scripts/lean-citation-seeds.txt` - add one `##` group with the confirmed §4.1 declaration names
  and a comment explaining why they belong here.
- `scripts/lean-citation-manifest.json` - regenerated, never hand-edited.

**Verification**:
- `python3 scripts/export-lean-citations.py --check` exits 0.
- `bash scripts/check-module-invariants.sh --no-build` reports `PASS C35`.
- `git diff --staged` shows exactly the two declared files; the manifest diff is additive at the
  new names and otherwise unchanged (a manifest diff at an *untouched* name means something else
  drifted and is a finding, not noise).

---

### Phase 3: Record the second drift cluster in the corrections table [COMPLETED]

**Goal**: Give the consuming repository a mechanical, name-keyed correction for the §4.1
`ShiftSet.lean` citations, in the same shape it already has for the original four.

**Tasks**:
- [x] Add one or more rows to the "Corrections the consuming table owes" table in
      `docs/reference/transcription-audit-surface.md`, matching the existing
      "What is wrong | Declarations involved | What to do" column shape and voice. *(completed:
      three new rows added)*
- [x] State the failure plainly: these citations land in the *previous* declaration (a docstring
      or body above the target), which is the same defect class as the +38 drift but older —
      traced to commit `ef4707035` — and was invisible because nothing in either repository read
      these particular citations. *(completed: confirmed via `git show ef4707035` that a docstring
      block was inserted above the cluster, causing a uniform +9-line shift — all nine ShiftSet.lean
      citations in §4.1 drifted by the same amount, not a mix of unrelated shifts)*
- [x] Distinguish the genuinely wrong-declaration rows from the correct-but-loose ones
      (`total_eq_orbit`, the `sep` field citation) so the consuming side is not sent to repair
      rows that are already sound. *(completed; `sh_surj`'s loose citation was already recorded in
      the pre-existing table and is not duplicated)*
- [x] Write no `file.lean:NNN` anywhere: every row cites names and says "take the locations from
      the manifest", consistent with the table's existing opening paragraph. *(completed)*
- [x] Add a short sentence to that section's preamble noting the seed list now covers these names,
      so the *next* drift at them fails C35 here — and that seeding does not retroactively repair
      what the consuming document currently cites. *(completed)*
- [x] Targeted lint before commit: `grep -nE '\.lean:[0-9]+' docs/reference/transcription-audit-surface.md`
      returns nothing new. *(completed: zero matches)*

**Timing**: 1 hour

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase assumes the corrections table's existing five rows and its
column shape are unchanged, and that the residue table's 24-row / 27-declaration counts are not
touched. Confirm by reading the file before editing and by `git diff` after: the diff must be
additive within the corrections section (plus at most the preamble sentence), with zero lines
changed inside the residue table.

**Files to modify**:
- `docs/reference/transcription-audit-surface.md` - new correction row(s) for the second drift
  cluster, plus one preamble sentence about the extended seed coverage.

**Verification**:
- `grep -nE '\.lean:[0-9]+' docs/reference/transcription-audit-surface.md` yields no new hit.
- `git diff -- docs/reference/transcription-audit-surface.md` touches no line of the residue table
  (rows 1-24) and no residue count.
- Every declaration named in the new row(s) appears in `scripts/lean-citation-manifest.json`.

---

### Phase 4: Hand-off block for the three unreached rows, and the deferred cross-repo proposal [NOT STARTED]

**Goal**: Make rows 3, 20 and 24 copy-ready for the consuming audit without restating them, and
record the "consuming side consumes the manifest" option as a named proposal instead of an
unfinished half of the task.

**Tasks**:
- [ ] Extend the existing "The three rows the consuming audit does not reach" section with an
      explicit hand-off framing: what the consuming §4.2 should add for each of rows 3, 20 and 24,
      keyed by name, with the paper anchor each already carries.
- [ ] Preserve row 24's conditional framing exactly. The consuming document's §4.2 already records
      `app:auto_existence` as "not needed: Corollary 2.1 derives it" — a reasoned position, not an
      omission. Say so, and frame row 24 as "reachable only if the general time-shift lemma is
      cited rather than the instantiated one", never as a flat gap.
- [ ] Add a short, clearly delineated subsection recording the deferred proposal: a consuming-side
      check that reads `scripts/lean-citation-manifest.json` from a local checkout (reusing that
      repository's existing `BIMODAL_LOGIC_PATH` resolution convention, skipping cleanly when no
      checkout is present, mirroring its `_lean_check.py` skip discipline) and cross-checks its own
      `file.lean:NNN` citations against it. State plainly that it is not implemented here and why:
      it is that repository's work, outside this task's `file_scope`.
- [ ] Add a sentence to the C35 header comment in `scripts/check-module-invariants.sh` recording
      that the gate's coverage is now the seeded set *plus* the §4.1 cluster, and pointing at
      `docs/reference/transcription-audit-surface.md` for the corrections the consuming side owes.
      Comment text only — no behavioural change, no `ENFORCE_C35` default change.
- [ ] Update the `*Last verified:*` line at the foot of
      `docs/reference/transcription-audit-surface.md` to the implementation date.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase assumes the C35 header edit is comment-only and that
`ENFORCE_C35`'s default stays `1`. Confirm with `git diff -- scripts/check-module-invariants.sh`:
every changed line must begin with `#`, and the `ENFORCE_C35=${ENFORCE_C35:-1}` line must be
untouched.

**Files to modify**:
- `docs/reference/transcription-audit-surface.md` - hand-off framing for rows 3/20/24, the deferred
  cross-repository proposal subsection, refreshed `*Last verified:*` date.
- `scripts/check-module-invariants.sh` - C35 header comment only.

**Verification**:
- `bash -n scripts/check-module-invariants.sh` exits 0.
- `git diff -- scripts/check-module-invariants.sh` shows comment lines only; `ENFORCE_C35` default
  unchanged.
- `grep -nE '\.lean:[0-9]+' docs/reference/transcription-audit-surface.md` yields no new hit.
- The row-24 text contains the conditional framing and does not describe `app:auto_existence` as
  a plain omission.

---

### Phase 5: Full gate and close-out [NOT STARTED]

**Goal**: Prove the change is green under the repository's own gates and that nothing outside
`file_scope` was touched or left contradicted.

**Tasks**:
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and confirm a non-zero-free pass,
      with C5, C12, C13, C20 and C35 all PASS.
- [ ] If time and tree state permit, run the full `bash scripts/check-module-invariants.sh` (with
      build) once; if the build half is impractical in this session, record that explicitly rather
      than claiming a pass that was not taken.
- [ ] Confirm `git status --porcelain` shows changes only under the task's declared `file_scope`
      (`scripts/lean-citation-seeds.txt`, `scripts/lean-citation-manifest.json`,
      `scripts/check-module-invariants.sh`, `docs/reference/transcription-audit-surface.md`) plus
      `specs/**`.
- [ ] Confirm `git -C ~/Projects/ModelChecker status --porcelain` is unchanged — the
      coordinate-rather-than-edit boundary held.
- [ ] Read-only cross-check that `docs/reference/README.md` and
      `docs/development/MODULE_INVARIANTS.md` (both **outside** `file_scope`) are not left
      contradicting the edited page. The 24/27 residue counts do not move, so no edit is expected;
      if one is genuinely needed, record it as an out-of-scope finding in the summary rather than
      editing it.
- [ ] Write the execution summary at `specs/687_cross_repo_citation_audit_gating/summaries/01_*-summary.md`.

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `specs/687_cross_repo_citation_audit_gating/summaries/01_cross-repo-citation-gating-summary.md` -
  execution summary (new).

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` exits 0.
- `git status --porcelain` confines changes to `file_scope` plus `specs/**`.
- `git -C ~/Projects/ModelChecker status --porcelain` is unchanged.

---

## Testing & Validation

- [ ] `python3 scripts/export-lean-citations.py --check` exits 0 (manifest byte-current).
- [ ] `python3 scripts/export-lean-citations.py --stdout` resolves every seeded name, including
      every newly added one, with no UNRESOLVED or AMBIGUOUS entry.
- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0, with `PASS C35`.
- [ ] `PASS C20` — no `file.lean:NNN` citation introduced into publication-facing scope by the
      documentation edits.
- [ ] `PASS C12` / `PASS C13` — every path and relative link added to
      `docs/reference/transcription-audit-surface.md` resolves.
- [ ] `bash -n scripts/check-module-invariants.sh` exits 0.
- [ ] The residue table's 24-row / 27-declaration counts are byte-identical before and after.
- [ ] No file under `~/Projects/ModelChecker` is modified at any point.

## Artifacts & Outputs

- `scripts/lean-citation-seeds.txt` — extended with the §4.1 `ShiftSet.lean` declaration group.
- `scripts/lean-citation-manifest.json` — regenerated; the authoritative line-numbered view.
- `docs/reference/transcription-audit-surface.md` — second drift cluster recorded in the
  corrections table; rows 3/20/24 made hand-off-shaped; deferred cross-repository proposal
  recorded; `*Last verified:*` refreshed.
- `scripts/check-module-invariants.sh` — C35 header comment updated (comment only).
- `specs/687_cross_repo_citation_audit_gating/summaries/01_cross-repo-citation-gating-summary.md` —
  execution summary.
- **Not produced, deliberately**: any change under `~/Projects/ModelChecker`, and any
  consuming-side manifest-consumer script. Both are recorded as proposals.

## Rollback/Contingency

Each phase commits independently and the change set is four files plus `specs/**`, so the ordinary
contingency is `git revert` of the offending phase commit — no working-tree rollback is needed.

If a genuine working-tree rollback is required (for example a regenerated manifest that cannot be
reconciled), take a snapshot first per `context/contracts/recovery.md`'s rollback rung —
`bash .claude/scripts/git-snapshot.sh 687`, adding `--allow-out-of-scope` only for the deliberate
whole-tree case — and only then run the destructive command. Do not emit a bare default-mode
snapshot as a routine start-of-phase checkpoint; a defensive, non-reverting checkpoint before
risky work uses `--no-revert`.

Phase-specific contingencies:
- **Phase 2**: if a seeded name cannot be made to resolve, revert the seed addition *and* the
  manifest together (they are one atomic-batch objective) and record the unresolvable name as a
  finding — a name that will not resolve is a rename this repository made and never propagated,
  which is itself the kind of defect this task exists to surface.
- **Phase 3/4**: documentation-only; `git checkout HEAD -- docs/reference/transcription-audit-surface.md`
  restores the landed version, subject to the dirty-tree guard above.
