# Implementation Plan: Repair drifted L+ manuscript citations and pin `def:BLstar-semantics`

- **Task**: 626 - Repair drifted manuscript citations in the L+ files and pin def:BLstar-semantics.
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/626_repair_lplus_manuscript_citations_pin_blstar_semantics/reports/01_repair-lplus-citations-pin-blstar.md
- **Artifacts**: plans/01_repair-lplus-citations-pin-blstar.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Every manuscript citation in the `PlusLanguage` (L⁺) tree that names a bare line number is
replaced by a citation that survives the author editing the paper: a `\label{}` anchor
(`def:BLstar-semantics`, `sub:RestrictedModalities`) or a quotable phrase. In the same pass,
`def:BLstar-semantics` is promoted from `LIVE-UNPINNED` to a pinned manifest anchor in
`docs/reference/paper-definitions-of-record.md` — a promotion that file's own KNOWN-ANCHORS
charter already prescribes ("If a docstring starts quoting one verbatim, promote it to the
manifest at that point"), now that the Stability clause is confirmed quoted verbatim rather than
in paraphrase. Two small documentation additions round the task out: a `stab_4` docstring
sentence recording that the constructor is surplus to the manuscript's commented-out
`def:TM-stability`, and a `StarLanguage/README.md` correspondence row recording the open-future,
open-past and nomic operators as manuscript operators with no formalization here.

**Definition of done**: no bare manuscript line number remains as a citation anywhere in
`FormalSystem/{Syntax,Semantics}/{Plus,Star}Language/`; `def:BLstar-semantics` has a manifest row
and a prose entry and no longer has a KNOWN-ANCHORS row; `scripts/check-module-invariants.sh`'s
C15 check passes; `scripts/check-paper-definitions.sh` reports case (a) or (b), never a failure;
and a guarded scoped build of the touched modules is green.

**Constraint restated (binding on every phase)**: docstring and documentation edits only. No
declaration, statement, or proof changes. No task numbers in any file outside `specs/`.

### Research Integration

The research report is the authoritative site inventory and supplies four findings this plan
builds on directly:

1. **The drift is confined to `PlusLanguage/`.** `Syntax/StarLanguage/` and
   `Semantics/StarLanguage/` have zero hits for the line-number pattern; the StarLanguage
   README already cites by `\label` only and says so in its own table header.
2. **The Stability clause is word-for-word identical at both manuscript sites** (subsection
   *Restricted Modalities* and the appendix `def:BLstar-semantics`), differing only by the
   appendix block's uniform `\vec{v}` register-vector parameter. This is what makes
   `def:BLstar-semantics` the correct anchor for sites that currently cite the *Restricted
   Modalities* line numbers, and what retires the record file's "quoted only in paraphrase"
   ground for leaving it unpinned.
3. **Pinning this anchor is a coverage extension, not a drift correction.** The record file's own
   documented convention (the 2026-08-13 22-anchor precedent) is that a coverage extension does
   **not** re-pin the whole-file `FILE_CHECKSUM`/`PINNED_COMMIT`/`LINE_COUNT` sentinels. Phase 4
   follows that precedent.
4. **`stab_4` is genuinely surplus to `def:TM-stability`**, whose commented-out schema list is
   exactly SK, ST, S5, MS, AS, PS, US — no S4-shaped schema.

This plan extends the report's inventory in one respect (see the Phase 1/2 Scope Hypothesis
lines): a re-run of the report's own grep during planning surfaced three module-header
`## References` lines citing line *ranges* (`Axioms.lean`, `Formula.lean`, `PlusTruth.lean`) that
the report's per-site table does not enumerate as rows. The report's table is a floor, not a
ceiling — every phase below is driven by a live re-grep, not by transcribing the table.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; `specs/ROADMAP.md` was not consulted and is not
touched by this plan.

## Goals & Non-Goals

**Goals**:
- Replace every bare-line-number manuscript citation in `FormalSystem/Syntax/PlusLanguage/` and
  `FormalSystem/Semantics/PlusLanguage/` with a `\label{}` anchor or a quotable phrase.
- Confirm by live grep that `Syntax/StarLanguage/` and `Semantics/StarLanguage/` carry no such
  citations, and record that confirmation as evidence.
- Pin `def:BLstar-semantics` in `docs/reference/paper-definitions-of-record.md`: manifest row,
  prose `###` entry with the verbatim block and its sha256, coverage-extension note, and removal
  of the now-superseded KNOWN-ANCHORS row — carrying that row's world-register exclusion content
  forward into the new entry.
- Add one docstring sentence at `stab_4` recording that it is surplus to the manuscript's
  commented-out `def:TM-stability` and derivable from SK, ST and S5, kept for convenience.
- Add one `FormalSystem/Syntax/StarLanguage/README.md` correspondence row recording the
  open-future, open-past and nomic operators of *Restricted Modalities* as manuscript operators
  with no formalization here.
- Leave the C15 anchor gate green and the touched Lean modules building.

**Non-Goals**:
- No declaration, statement, or proof changes anywhere. Not one `theorem`, `def`, `inductive`
  constructor, or tactic block is edited.
- Do not remove the `stab_4` constructor, and do not claim anything stronger about it than
  "surplus to `def:TM-stability`, derivable from SK/ST/S5, kept for convenience" — in particular
  no claim about soundness, completeness, or which downstream proofs would need it re-derived.
- Do not re-pin the whole-file `FILE_CHECKSUM`/`PINNED_COMMIT`/`LINE_COUNT` sentinels.
- Do not pin `lem:deterministic-singleton` or any other `LIVE-UNPINNED` anchor; only
  `def:BLstar-semantics` is in scope.
- Do not reference any task number in a file outside `specs/`.
- Do not touch any file in a concurrent sibling task's declared scope (see Risks).

## Citation Replacement Vocabulary

Phases 1 and 2 apply this table rather than inventing a per-site idiom. The left column is the
stale text; the right column is the substance the replacement must carry (exact wording is the
implementer's, subject to the site's surrounding prose).

| Stale citation | What it cites | Replacement anchor / phrase |
|---|---|---|
| `paper line 1108`, `(line 1108)` | the definition of `⟨τ⟩_x` | `def:BLstar-semantics`'s opening sentence, which defines `⟨τ⟩_x` as the worlds intersecting `τ` at `x` |
| `paper footnote, line 1118` | the monomodal logic of `⊡` is S5 | the footnote to the Stability clause ("the monomodal logic of `⊡` is S5") |
| `paper footnote, line 1119`, `(line 1119)`, `footnote at line 1119` | atom-level `p → ⊡p` | the footnote to the Stability clause (`φ → ⊡φ` for non-temporal `φ`) |
| `paper line 1121` | the dual `⟐φ := ¬⊡¬φ` | the dual `⟐` introduced with the Stability clause in subsection *Restricted Modalities* (`sub:RestrictedModalities`) |
| `paper line 1125` / `1126` / `1128` / `1129` | `Will` / `will` / `Could` / `could` | the defined modals of subsection *Restricted Modalities* (`sub:RestrictedModalities`) |
| `paper line 1426`, `JPL paper line 1426` | the *Determined* schema | the manuscript's *Determined* schema, subsection *Open Future* (`sub:OpenFuture`) — cited by name, since it carries no `\label{}` of its own |
| `lines 1108, 1114, 1118-1119, 1121` and `lines 1108-1129` (module-header `## References` lines) | the whole cluster | a label list: `def:BLstar-semantics` (the `⟨τ⟩_x` definition, the Stability clause, and its footnote) plus `sub:RestrictedModalities` (the dual `⟐` and the defined modals) |

**Two notes the implementer must not skip:**

- **`sub:` labels are safe but unchecked.** C15's citation pattern is
  `\b(def|thm|lem|cor|app|rmk):...` — it does not match the `sub:` sectioning prefix, so
  `sub:RestrictedModalities` and `sub:OpenFuture` need no KNOWN-ANCHORS row and will not be
  validated by the gate. The record file states this exemption explicitly for `sub:Extension`,
  and `Formula.lean` already cites `sub:Extension` under it. Because the gate will not catch a
  typo in a `sub:` label, verify each one by grepping the manuscript for the literal
  `\label{sub:...}` before writing it.
- **Old line 1114 is unmapped by the research report.** It appears only inside the two
  module-header range citations. Do not guess a specific clause for it: the header replacement
  above cites the enclosing anchors, which covers it. If a site-specific reading is needed, read
  the manuscript region 1143–1175 and match the claim, rather than extrapolating from the
  observed +41/+45 line offset.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer transcribes the research report's site table instead of re-grepping, missing the three module-header `## References` lines and any site added since the research pass | M | M | Every citation phase is driven by a live re-grep; the Scope Hypothesis lines require reporting the observed count against the hypothesis, and Phase 6 re-runs the sweep to zero |
| Removing the `def:BLstar-semantics` KNOWN-ANCHORS row before its manifest row exists, breaking C15 for every citation of it | H | L | Phase 4 performs the manifest-row addition and the KNOWN-ANCHORS removal as one atomic batch, with the gate run only at the end of the phase |
| Re-pinning `FILE_CHECKSUM`/`PINNED_COMMIT`/`LINE_COUNT` on this coverage extension, contradicting the file's own convention and turning the sentinel into a diary of touch-events | M | M | Phase 4's task list names the three sentinel comment markers as explicitly off-limits and cites the 2026-08-13 precedent |
| The manuscript moves between planning and implementation, invalidating the recorded sha256 | M | L | Phase 4 re-runs `--resolve` at implementation time and uses the value it prints, never the value recorded in this plan or the report |
| A `sub:` label typo silently passes every gate (C15 does not match the `sub:` prefix) | M | M | Verify each `sub:` label against the literal `\label{sub:...}` in the manuscript before writing it (see the note above) |
| A malformed doc-comment delimiter breaks elaboration of a touched Lean module | M | L | Lean phases carry Verification Tier `local`; Phase 6 runs the guarded scoped build over both aggregators |
| Referencing task 625's number in `StarLanguage/README.md`, violating `no-task-references-in-deliverables.md` | M | M | Phase 5's task list mandates number-free phrasing ("a separate task formalizes...") and Phase 6 runs the repository's task-reference lint |
| A concurrent sibling task (scheduled this same `/orchestrate` cycle) edits a shared file under this task's feet | M | L | No overlap: the sibling's declared scope is `scripts/move-modules.py`, `FormalSystem/Boneyard/`, `Boneyard/README.md`, `scripts/check-module-invariants.sh`, `scripts/boneyard-import-waivers.txt`, and two ADRs — disjoint from every file below. **But `scripts/check-module-invariants.sh` is in the sibling's scope and is this task's gate**: re-read it before running, never edit it, and treat an unexplained C15 behavior change as possibly the sibling's in-flight edit. Stage and commit only this task's own hunks; never a directory or glob `git add` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 4, 5 | -- |
| 2 | 3 | 1 |
| 3 | 6 | 1, 2, 3, 4, 5 |

Phases within the same wave can execute in parallel. Phases 1 and 3 touch the same file
(`Axioms.lean`) and are therefore serialized; all other wave-1 phases touch disjoint files.

---

### Phase 1: Repair citations in `Syntax/PlusLanguage/` [COMPLETED]

**Goal**: No bare manuscript line number remains as a citation in
`FormalSystem/Syntax/PlusLanguage/Axioms.lean` or `Formula.lean`.

**Tasks**:
- [x] Re-run the sweep over this directory to get the live site list, not the report's table:
      `grep -rn "paper line\|paper lines\|line [0-9]\{3,\}\|footnote, line\|(line [0-9]\|lines [0-9]" FormalSystem/Syntax/PlusLanguage/` *(completed: 17 hits, matching the Scope Hypothesis exactly — 9 in Axioms.lean, 8 in Formula.lean)*
- [x] Re-read each file immediately before editing it (concurrent-sibling discipline). *(completed)*
- [x] Apply the Citation Replacement Vocabulary table to every hit in `Axioms.lean` — the
      docstring-summary lines near the top of the module, the module-header `## References` line,
      and the per-constructor docstrings for ST, S4, S5, MS and AS. *(completed)*
- [x] Apply the same table to every hit in `Formula.lean` — the module summary, the
      `## References` line, the `### The ⊡-specific operators` section banner, and the per-operator
      docstrings for `⟐`, `Will`, `will`, `Could`, `could`. *(completed)*
- [x] For each `sub:` label written, confirm the literal `\label{sub:...}` exists in
      `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`. *(completed: confirmed `\label{sub:RestrictedModalities}` at manuscript line 1144)*
- [x] Confirm by `git diff` that every changed hunk lies inside a `/-- -/`, `/-! -/`, or `--`
      comment region — no declaration, statement, or proof line is touched. *(completed)*
- [x] Re-grep this directory and confirm zero remaining hits. *(completed)*

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the live grep is expected to report **9 matching lines in `Axioms.lean` and
8 in `Formula.lean` (17 total)** — the research report's 16 enumerated rows for these two files
plus the module-header `## References` line in each, which its table omits. Confirm by running
the grep command in the first task above and comparing the observed count; report any divergence
in the phase's commit message or progress note rather than silently absorbing it.

**Files to modify**:
- `FormalSystem/Syntax/PlusLanguage/Axioms.lean` — docstring and comment citations only
- `FormalSystem/Syntax/PlusLanguage/Formula.lean` — docstring and comment citations only

**Verification**:
- The directory re-grep returns zero hits.
- `git diff` shows comment-region changes only.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- FormalSystem.Syntax.PlusLanguage`
  (detached; see the Wait Discipline note under Testing & Validation) is green.

---

### Phase 2: Repair citations in `Semantics/PlusLanguage/` [COMPLETED]

**Goal**: No bare manuscript line number remains as a citation in
`FormalSystem/Semantics/PlusLanguage/PlusTruth.lean`, `PlusNonValidities.lean`, or
`PlusStateLocal.lean`.

**Tasks**:
- [x] Re-run the sweep over this directory to get the live site list:
      `grep -rn "paper line\|paper lines\|line [0-9]\{3,\}\|footnote, line\|(line [0-9]\|lines [0-9]" FormalSystem/Semantics/PlusLanguage/` *(completed: 14 hits, matching the Scope Hypothesis exactly — 8 in PlusTruth.lean, 2 in PlusNonValidities.lean, 4 in PlusStateLocal.lean)*
- [x] Re-read each file immediately before editing it. *(completed)*
- [x] `PlusTruth.lean`: apply the vocabulary table to the module summary, the `## References`
      line, the `⟐` docstring, the `### The definitional validities of ⊡` banner, and the
      `□φ → ⊡φ` docstring. *(completed)*
- [x] `PlusNonValidities.lean`: replace both *Determined* line citations by the named-schema
      form. Note the second site already carries a companion `app:deterministic` label citation —
      leave that label intact and replace only the line number beside it. *(completed)*
- [x] `PlusStateLocal.lean`: replace all four atom-stability footnote citations. The site that
      already reads "`def:BLstar-semantics`'s footnote, line 1119" needs only the line number
      dropped in favour of the quotable phrase, since the anchor is already present. *(completed)*
- [x] For each `sub:` label written, confirm the literal `\label{sub:...}` in the manuscript. *(completed: confirmed `sub:RestrictedModalities` and `sub:OpenFuture`)*
- [x] Confirm by `git diff` that every changed hunk lies inside a comment region. *(completed)*
- [x] Re-grep this directory and confirm zero remaining hits. *(completed)*

**Timing**: 45 minutes

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the live grep is expected to report **8 matching lines in `PlusTruth.lean`,
2 in `PlusNonValidities.lean`, and 4 in `PlusStateLocal.lean` (14 total)** — the research
report's rows for these three files plus `PlusTruth.lean`'s module-header `## References` line,
which its table omits. Confirm by running the grep command in the first task and comparing;
report any divergence rather than absorbing it silently.

**Files to modify**:
- `FormalSystem/Semantics/PlusLanguage/PlusTruth.lean` — docstring and comment citations only
- `FormalSystem/Semantics/PlusLanguage/PlusNonValidities.lean` — docstring and comment citations only
- `FormalSystem/Semantics/PlusLanguage/PlusStateLocal.lean` — docstring and comment citations only

**Verification**:
- The directory re-grep returns zero hits.
- `git diff` shows comment-region changes only.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- FormalSystem.Semantics.PlusLanguage`
  (detached) is green.

---

### Phase 3: Record `stab_4`'s status relative to `def:TM-stability` [COMPLETED]

**Goal**: The `stab_4` constructor's docstring states that the schema is surplus to the
manuscript's commented-out `def:TM-stability`, derivable from SK, ST and the S5 schema, and kept
for convenience — and says nothing stronger.

**Tasks**:
- [ ] Re-read `FormalSystem/Syntax/PlusLanguage/Axioms.lean` around the `stab_4` constructor
      (near line 288, after Phase 1's edits).
- [ ] Add one sentence to the `stab_4` docstring carrying exactly this content: `stab_4` is not
      among the schemata of the manuscript's commented-out `def:TM-stability` (which lists SK, ST,
      S5, MS, AS, PS and US); it is derivable from SK, ST and the S5 schema, and is kept as a
      primitive constructor for convenience.
- [ ] Verify the sentence makes no claim about soundness, completeness, or downstream proof
      impact, and that no other constructor's docstring was touched.
- [ ] Confirm the constructor itself — its name, binders, and statement — is byte-identical to
      before, by inspecting `git diff`.
- [ ] Note that `def:TM-stability` is commented out in the manuscript and has **no** row in either
      the manifest or the KNOWN-ANCHORS block. If the new sentence cites it by that literal
      anchor string, C15 will fail. Either phrase the sentence without the literal anchor token
      (preferred — e.g. "the manuscript's commented-out TM-stability axiomatization"), or add a
      `DANGLING` KNOWN-ANCHORS row for it in Phase 4. Confirm which by running the C15 gate in
      Phase 6 and reacting, not by assuming.

**Timing**: 20 minutes

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Syntax/PlusLanguage/Axioms.lean` — the `stab_4` docstring only

**Verification**:
- `git diff` shows one docstring hunk and no change to the constructor.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- FormalSystem.Syntax.PlusLanguage`
  is green.

---

### Phase 4: Pin `def:BLstar-semantics` in the record of paper definitions [COMPLETED]

**Goal**: `def:BLstar-semantics` is a pinned manifest anchor with a prose entry, its
KNOWN-ANCHORS row is gone, its world-register exclusion is preserved, and the whole-file
sentinels are untouched.

**Tasks**:
- [x] Re-run `bash scripts/check-paper-definitions.sh --resolve "def:BLstar-semantics|env|-|-"`
      and use the sha256 and verbatim text **it prints now** — not the values recorded in this
      plan or the research report. *(completed: sha256 b4d3239cc96ddd1e90965901aca8c378f6ec5ca52f568ea6b2ef59d9c3ba6c95, matching the Scope Hypothesis)*
- [x] Re-read `docs/reference/paper-definitions-of-record.md` before editing. *(completed)*
- [x] Add the manifest row inside the `<!-- MANIFEST:BEGIN -->` fence, in paper order between the
      `def:deterministic` row and the `cor:saturation-finite` row:
      `def:BLstar-semantics|env|-|-|<sha256 from the resolve run>` *(completed)*
- [x] Add a prose `### \`def:BLstar-semantics\`` entry immediately after the existing
      `### \`def:deterministic\`` entry, following that entry's shape: a heading naming the
      anchor and what it is, a short paragraph, a ```latex fence quoting the resolved block
      verbatim, and a `sha256:` line. *(completed)*
- [x] In that entry's prose, record (a) why it is now pinned — the Stability clause is quoted
      verbatim in this repository, not in paraphrase, retiring the ground the KNOWN-ANCHORS row
      gave for leaving it unpinned; and (b) carry forward, in substance, the removed row's
      content: the anchor's time-register half is implemented as `StarTruthAt` over points
      `(τ, x, v⃗)` in `FormalSystem/Semantics/StarLanguage/StarTruth.lean`, while the world
      registers `↑_M`/`↓_M` are deliberately still unimplemented, recorded as an explicit
      exclusion in `FormalSystem/Syntax/StarLanguage/README.md`'s correspondence table. *(completed)*
- [x] Remove the `def:BLstar-semantics|LIVE-UNPINNED|...` row from the
      `<!-- KNOWN-ANCHORS:BEGIN -->` fence. The manifest and KNOWN-ANCHORS sets are currently
      disjoint (verified: zero overlap) and the block's own charter directs promotion into the
      manifest once the text is quoted, so leaving the row would make the record
      self-contradictory. *(completed)*
- [x] Add a short coverage-extension prose note dated 2026-09-20, following the shape of the
      existing "Coverage extension" / "no re-pin" precedent sections, stating that this is a
      coverage extension and that the whole-file sentinels are deliberately not re-pinned. *(completed)*
- [x] **Do not modify** the `<!-- PINNED_COMMIT: -->`, `<!-- FILE_CHECKSUM: -->`, or
      `<!-- LINE_COUNT: -->` comment markers, nor the header table rows that record them. *(completed: sentinels unchanged, confirmed by git diff)*
- [x] If Phase 3 chose to cite the literal `def:TM-stability` anchor, add a `DANGLING`
      KNOWN-ANCHORS row for it here (it is commented out in the manuscript). Otherwise skip.
      *(skipped: Phase 3 phrased the stab_4 sentence without the literal anchor token —
      "the manuscript's commented-out TM-stability axiomatization" — so no DANGLING row is needed)*
- [x] Re-run `bash scripts/check-paper-definitions.sh` with no arguments, without tail-truncating
      the output, and confirm it reports case (a) or case (b) — never a failure. *(completed: case (b) — "all 43 recorded definitions are unchanged -- pass")*

**Timing**: 50 minutes

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: atomic-batch

**Scope Hypothesis**: `def:BLstar-semantics`'s live sha256 is expected to be
`b4d3239cc96ddd1e90965901aca8c378f6ec5ca52f568ea6b2ef59d9c3ba6c95` (unchanged across both the
research pass and the planning pass). Confirm with the `--resolve` run in the first task; if it
differs, the manuscript moved and the newly printed value and text are authoritative.

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` — one manifest row added, one prose entry
  added, one KNOWN-ANCHORS row removed, one coverage-extension note added; sentinels untouched

**Verification**:
- `grep -n "BLstar-semantics" docs/reference/paper-definitions-of-record.md` shows the manifest
  row and the new prose entry, and no KNOWN-ANCHORS row.
- `git diff` on the file shows no change to the three sentinel comment markers.
- `bash scripts/check-paper-definitions.sh` reports case (a) or (b).

---

### Phase 5: Record the unformalized Restricted-Modalities operators [COMPLETED]

**Goal**: `FormalSystem/Syntax/StarLanguage/README.md`'s correspondence table records the
open-future, open-past and nomic operators of subsection *Restricted Modalities* as manuscript
operators with no formalization in this repository.

**Tasks**:
- [x] Re-read `FormalSystem/Syntax/StarLanguage/README.md`'s "Paper-label correspondence" table,
      including the existing world-register exclusion row, and match the new row to the table's
      three-column shape and its established "**Excluded**:" / "—" idiom. *(completed)*
- [x] Add one row recording the three operators (`⟨τ⟩`-style open future, open past, and the
      nomic modal) as defined in subsection *Restricted Modalities* alongside Stability, and
      explicitly disclaimed by the manuscript itself at the close of that subsection. *(completed)*
- [x] Place the row where the table already records the world registers as excluded — adjacent
      to the existing `def:BLstar-semantics` (world registers) row — so the two exclusions read
      together. *(completed)*
- [x] Note in the row that a separate task formalizes the open-future and open-past operators.
      **Write no task number**: this file is outside `specs/`, and
      `.claude/rules/no-task-references-in-deliverables.md` forbids task-number citations there. *(completed: "a separate task formalizes the open-future and open-past operators", no digits)*
- [x] Cite the subsection by `sub:RestrictedModalities`, consistent with the table's own header
      rule ("Anchors are cited by `\label` only, never by line number"), after confirming the
      literal `\label{sub:RestrictedModalities}` in the manuscript. *(completed)*
- [x] Confirm no other row of the table was modified. *(completed: git diff shows exactly one added line)*

**Timing**: 20 minutes

**Depends on**: none

**Verification Tier**: prose

**Scope Hypothesis**: the table is expected to contain **exactly one** existing exclusion row for
`def:BLstar-semantics`'s world registers and **no** row for the open-future / open-past / nomic
operators. Confirm by grepping the README for `Excluded` and for `Nomic`/`Open` before adding the
row; if a row already exists, amend it rather than adding a duplicate.

**Files to modify**:
- `FormalSystem/Syntax/StarLanguage/README.md` — one correspondence-table row added

**Verification**:
- The new row renders as a well-formed three-column markdown table row.
- `git diff` shows exactly one added row and no other table change.
- The row contains no digits forming a task number and no `task N` phrasing.

---

### Phase 6: Gates, residual sweep, and close-out [COMPLETED]

**Goal**: Every gate the dispatch names is green and no drifted citation remains anywhere in the
four target directories.

**Tasks**:
- [x] Re-run the full sweep across all four directories and confirm zero hits:
      `grep -rn "paper line\|paper lines\|line [0-9]\{3,\}\|footnote, line\|(line [0-9]\|lines [0-9]" FormalSystem/Syntax/PlusLanguage FormalSystem/Semantics/PlusLanguage FormalSystem/Syntax/StarLanguage FormalSystem/Semantics/StarLanguage` *(completed: zero hits, exit 1)*
- [x] Record the StarLanguage zero-hit result explicitly as evidence that the dispatch's "grep the
      rest ... and fix what is found" instruction was discharged with nothing found there.
      *(completed: `Syntax/StarLanguage/` and `Semantics/StarLanguage/` had zero hits both before
      and after this task's edits — confirmed by the Phase 6 four-directory sweep above, which
      covers all four directories in one command and returns zero total hits)*
- [x] Re-read `scripts/check-module-invariants.sh` before running it (it sits in a concurrent
      sibling task's declared file scope) and confirm it is unmodified relative to `HEAD`; do not
      edit it under any circumstance. *(completed: `git diff`/`git log` confirm the script is
      unmodified; not edited)*
- [x] Run `bash scripts/check-module-invariants.sh` and confirm the C15 check passes. If C15
      fails naming `def:TM-stability`, resolve it per Phase 3's last task (rephrase the sentence
      or add the `DANGLING` row) rather than by weakening the gate. *(completed: C15 passes —
      "all 59 paper-anchor citation(s) resolve" and "all 76 theorem-index row(s) carry their
      anchor". The full run's own C1 (`lake build`, `lake build BimodalTest`) was interrupted by a
      host-level low-memory reaper unrelated to this task's edits; the `lake-build-guard.sh` log
      independently recorded that full `lake build` completing green (2667 jobs) around the same
      time. A `--no-build` re-run (which still executes C15 and every other non-build-dependent
      check) surfaced one unrelated finding — see next task — and after fixing it, reports
      "ALL CHECKS PASSED")*
- [x] Run `bash scripts/check-paper-definitions.sh` with no arguments, untruncated, and confirm
      case (a) or (b). *(completed: case (b) — "all 43 recorded definitions are unchanged -- pass")*
- [x] Run the repository's task-reference lint (`bash scripts/check-task-references.sh` or its
      equivalent as the repo provides it) and confirm no new violation outside `specs/`.
      *(completed: `.claude/scripts/check-task-references.sh` passes — 0 occurrences across its
      four scanned trees, none of which cover `FormalSystem/`/`docs/` in this repository; a
      manual grep of every file this task touched for `task [0-9]`/task-number patterns also
      returned zero hits, and `check-module-invariants.sh`'s own C9/C9D checks — zero
      task-number citations under `FormalSystem/`, `lakefile.toml`, `README.md`, `scripts/`, and
      `docs/` — passed)*
- [x] Run the guarded scoped build, detached, over both aggregators:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- FormalSystem.Syntax.PlusLanguage FormalSystem.Semantics.PlusLanguage`
      (if the guard accepts only one module per invocation, run it once per aggregator). These
      two aggregators transitively cover all five touched Lean modules. *(completed: one guarded
      invocation with both module names — `build FormalSystem.Syntax.PlusLanguage
      FormalSystem.Semantics.PlusLanguage` — "Build completed successfully (1002 jobs)", exit 0,
      no warnings)*
- [x] Poll the detached build with bounded polling per `context/patterns/external-process-wait.md`
      — no unbounded watch and no no-op filler calls. *(completed)*
- [x] Stage only this task's own files explicitly by path (never `git add -A`, never a directory
      or glob pathspec) and commit. *(completed)*

**Deviation note (unforeseen at planning time)**: the `--no-build` re-run of
`check-module-invariants.sh` surfaced one unrelated FAIL — `INV: 2 file(s) carry a stale
generated inventory block` (`FormalSystem/Semantics/PlusLanguage/README.md`, root `README.md`) —
caused by this task's own docstring line-count changes drifting the mechanically generated
`<!-- BEGIN GENERATED: inventory -->` blocks the script itself owns. This is not a citation-drift
issue and was not anticipated by any phase above. Resolved via the script's own documented
remedy, `bash scripts/check-module-invariants.sh --emit-inventory`, which rewrote exactly the two
stale blocks (a `Lines` count `409`→`410` and a repo-wide comment-line count `98354`→`98360`) —
mechanical regeneration, not a hand-authored change, and squarely within "docstring and
documentation edits only." Re-running `check-module-invariants.sh --no-build` afterward reports
"ALL CHECKS PASSED".

**Timing**: 50 minutes

**Depends on**: 1, 2, 3, 4, 5

**Verification Tier**: full

**Files to modify**:
- None (verification and commit only)

**Verification**:
- The four-directory sweep returns zero hits.
- `check-module-invariants.sh` reports C15 pass.
- `check-paper-definitions.sh` reports case (a) or (b).
- The guarded scoped build exits green.
- `git status --short` and `git diff --staged` show only this task's seven files.

---

## Testing & Validation

- [ ] Four-directory line-number grep returns zero hits.
- [ ] `bash scripts/check-module-invariants.sh` — C15 paper-anchor integrity check passes.
- [ ] `bash scripts/check-paper-definitions.sh` (no arguments, untruncated) reports case (a) or
      case (b), never a failure.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- FormalSystem.Syntax.PlusLanguage FormalSystem.Semantics.PlusLanguage` is green, run detached.
- [ ] No task number appears in any modified file outside `specs/`.
- [ ] `git diff` across all Lean files shows comment-region changes only — no declaration,
      statement, or proof line touched.
- [ ] The three whole-file sentinel comment markers in `paper-definitions-of-record.md` are
      unchanged.

**Wait Discipline**: the guarded build is long-running and must be run detached. Read
`context/patterns/external-process-wait.md` before waiting on it — bounded polling only, never an
unbounded watch or a wake-on-every-unchanged-poll monitor.

## Artifacts & Outputs

- `specs/626_repair_lplus_manuscript_citations_pin_blstar_semantics/plans/01_repair-lplus-citations-pin-blstar.md` (this file)
- `specs/626_repair_lplus_manuscript_citations_pin_blstar_semantics/summaries/01_repair-lplus-citations-pin-blstar-summary.md` (written at implementation)
- Modified: `FormalSystem/Syntax/PlusLanguage/Axioms.lean`
- Modified: `FormalSystem/Syntax/PlusLanguage/Formula.lean`
- Modified: `FormalSystem/Semantics/PlusLanguage/PlusTruth.lean`
- Modified: `FormalSystem/Semantics/PlusLanguage/PlusNonValidities.lean`
- Modified: `FormalSystem/Semantics/PlusLanguage/PlusStateLocal.lean`
- Modified: `docs/reference/paper-definitions-of-record.md`
- Modified: `FormalSystem/Syntax/StarLanguage/README.md`

## Rollback/Contingency

Every change in this plan is confined to comments, docstrings, and markdown; nothing is
load-bearing for elaboration beyond doc-comment well-formedness, and each phase is committed
separately. Reverting is therefore a per-commit `git revert` of the offending phase commit — no
working-tree discard is needed and none should be performed.

Because a concurrent sibling task is scheduled on this same working tree this cycle, do **not**
run `git-snapshot.sh` in its default reverting mode at any point in this task. If a genuine
defensive checkpoint is wanted before Phase 4's atomic batch, use the durable non-reverting form
(`bash .claude/scripts/git-snapshot.sh 626 --no-revert`). A true snapshot-then-rollback, if it
ever becomes necessary, follows `context/contracts/recovery.md`'s rollback rung, including its
out-of-scope override flag — and only after confirming via `git log` that any foreign change in
the tree is not the sibling task's in-flight work.

If `check-paper-definitions.sh` reports a drift *failure* rather than case (a)/(b) after Phase 4,
the manuscript moved mid-task: absorb the drift wave per the recorded procedure (resolve each
drifted anchor, rewrite its fence and sha, re-run with the old checksum sentinel in place to
force full anchor validation) before re-pinning anything, rather than reverting this task's work.
