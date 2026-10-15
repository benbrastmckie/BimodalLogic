# Implementation Plan: Task #792

- **Task**: 792 - Pin `lem:state-set` to the tree by discharging its remaining hypothesis
- **Status**: [IMPLEMENTING]
- **Effort**: 3.25 hours
- **Dependencies**: None
- **Research Inputs**: `specs/792_pin_lem_state_set_flow_frames/reports/01_pin-lem-state-set-flow-frames.md`
- **Artifacts**: plans/01_pin-lem-state-set-flow-frames.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The tree already carries every piece of mathematics `lem:state-set` asserts — `satSet`,
`plusTruthAt_iff_mem_satSet`, `plusValidOn_iff_satSet_univ` and `determined_of_orderFlow` — but
states all three results over two hypotheses, `OrderFlow F` (which *is* `def:flow`'s
order-isomorphism condition) and `StateOccurs F` (which the paper discharges by
`cor:occurrence`). The tree has `cor:occurrence` as `PartialHistory.occurrence` at
`[F.IsRegular]` and never composes the two, so no in-tree statement reads as the paper's lemma
does. This task composes them: one discharge theorem plus three `_of_isRegular` corollaries at
`[F.IsRegular] (h : OrderFlow F)` alone, the docstrings that let the paper cite them, and the
one gate unblock those citations require. Done means `lake build FormalSystem` green, zero new
`sorry`, `check-module-invariants.sh --no-build` exit 0 with C15 passing, the two choice-free
originals byte-identical, and `Independence/DeterminismUndefinable.lean` untouched.

### Research Integration

The report's four load-bearing findings are taken as the plan's premises, each already verified
rather than assumed: (1) all four deliverable declarations compile with **zero new imports** —
`FormalSystem.Semantics.Extension.Extension` is already in `StateSetTruth.lean`'s 53-module
transitive closure via `OrderTransfer → PlusLanguage.PlusValidity → Semantics.Validity`, so no
import line, no new module, no `FormalSystem.lean` regeneration (C33); (2)
`StateOccurs.of_isRegular` is `PartialHistory.occurrence` modulo argument order, proof
`fun w x => PartialHistory.occurrence F w x`; (3) the four new declarations report
`[propext, Classical.choice, Quot.sound]` while the originals stay at `[propext]` and
`[propext, Quot.sound]`, exactly as the dispatch's AXIOM NOTE predicts; (4) **C15 is a blocking
gate collision** — `def:flow`, `def:state-set` and `lem:state-set` have no row in either the
MANIFEST or the KNOWN-ANCHORS block of `docs/reference/paper-definitions-of-record.md`, so the
dispatch's required docstring citations fail C15 until rows exist. Phase 1 exists solely to
discharge that, before any docstring lands.

The report's recommendations R1-R9 are carried into the phases below essentially unchanged: R1
into Phase 2, R2/R3 into Phase 3, R4 into Phase 1, R5-R7 into Phases 3-4, R8 into Phase 5, R9
into every phase's verification.

**Plan-time re-derivations and divergences from the report, all load-bearing:**

- **The report's headline territory risk has cleared.** `docs/reference/paper-definitions-of-record.md`
  was in concurrent sibling task 756's declared `file_scope`; task 756 is now `completed` and
  the record file is clean in `git status`. Phase 1 needs no dependency edge and no
  serialization — only the ordinary re-read-immediately-before-editing discipline.
- **The paper has moved since the research dispatch.** Re-resolved at plan time:
  `def:state-set` 3424 → 3483, `def:flow` 3441 → 3500, `lem:state-set` 3447 → 3506,
  `cor:occurrence` 2919 → 2986, `prop:nomic-tense-free` 3654 → 3710. All five, plus
  `lem:nomic-occurrence` (3676), resolve to live, non-commented `\label{}`s — which is what
  `LIVE-UNPINNED` asserts. No line number appears anywhere in this plan's deliverables; cite by
  anchor name only.
- **Two further gates the report did not reach, both checked at plan time and both clear.** C35
  (`scripts/lean-citation-manifest.json` byte-currency by recorded declaration span) would fire
  on any docstring edit that shifts a seeded declaration's span: neither
  `scripts/lean-citation-seeds.txt` nor `scripts/lean-citation-manifest.json` contains a single
  occurrence of `StateSetTruth`, `OrderTransfer`, `satSet` or any of the three original theorem
  names, so the span shifts this task causes are invisible to it. C20's third assertion
  (a `file.lean:NNN` citation naming a declaration but landing outside its span) is likewise
  clear: a repo-wide sweep outside `specs/**` finds **zero** `StateSetTruth.lean:NNN` or
  `OrderTransfer.lean:NNN` citations.
- **C34b's trigger is line-scoped, not sentence-scoped**, and its constraint vocabulary is
  case-sensitive: `\b(Compositionality|Compositional|Seriality|Serial|Limit|Saturation|Saturated)\b`
  must co-occur **on one docstring line** with a negation or consumption word (those two
  alternations *are* case-insensitive) for the trigger to fire. The mitigation in Phases 2-4 is
  therefore exact rather than approximate: write none of those seven capitalized tokens on any
  new docstring line.
- **The record-row count rises from the report's 3 to 5.** The forward pointer in Phase 4 names
  `lem:nomic-occurrence`, and `lem:` *is* in C15's prefix set, so that anchor needs a row too;
  `prop:nomic-tense-free` gets one for consistency with the existing `prop:archimedean` row even
  though `prop:` is outside C15's prefix set. See Decisions.
- **The plan-time re-probe of the four pinned statements was blocked**, not skipped: `lean_run_code`
  returned "Imports are out of date and must be rebuilt" because concurrent sibling task 789
  holds uncommitted edits to `FormalSystem/Semantics/PartialHistory.lean` and five
  `FormalSystem/Semantics/Presheaf/*.lean` files, all inside this task's import closure. The
  `## Lean Challenge Statements` signatures below are therefore **carried** from the research
  report's two compiled `lean_run_code` probes, not re-derived here. Phases 2 and 3 carry the
  matching `**Scope Hypothesis**:` lines.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- `StateOccurs.of_isRegular`, `plusTruthAt_iff_mem_satSet_of_isRegular`,
  `plusValidOn_iff_satSet_univ_of_isRegular`, `determined_of_orderFlow_of_isRegular`
- Add five `LIVE-UNPINNED` KNOWN-ANCHORS rows (`def:flow`, `def:state-set`,
  `lem:nomic-occurrence`, `lem:state-set`, `prop:nomic-tense-free`) so every new docstring
  citation resolves under C15, pointer-only so `check-paper-definitions.sh` gains no hash
- Docstrings citing `def:flow` and `lem:state-set` by name, recording that these forms route
  through `cor:occurrence`, hence `thm:extension` and Zorn, and so carry `Classical.choice`
- A `StateSetTruth.lean` module-docstring note that (H2) is derivable for regular frames, with
  the two-hypothesis forms retained for their choice-free consumer
- A `StateSetTruth.lean` module-docstring forward pointer recording that
  `prop:nomic-tense-free` runs the same state-set induction over the tense-free fragment with a
  `Nomic` clause, for the nomic port to reuse
- Keep `FormalSystem/Metalogic/Independence/README.md`'s generated inventory current

**Non-Goals**:
- Any edit to `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean`. Its axiom pin
  and its claim that the generic argument is choice-free both remain true — adding a sibling
  theorem changes no existing declaration's axiom set — so the dispatch's instruction to leave
  it untouched is also the correct one.
- Any change to the two-hypothesis originals' signatures, proofs, or docstrings beyond the
  module-level docstring additions of Phase 4. Adding `[F.IsRegular]` to the file's existing
  `variable` line is specifically forbidden: it would re-sign the originals.
- A MANIFEST pin for any of the five anchors. Nothing in this task quotes the paper's text, so
  no `sha256:` commitment is incurred.
- A `Constraints consumed:` marker line, and the four capitalized constraint names it would
  otherwise be needed for.
- Re-encoding `satSet`'s `□` clause to the paper's `if |φ| = W then W else ∅` form. The
  ignoring-set form is a recorded decision with a stated reason (it keeps `Classical.choice` out
  of the *definition*), not drift.
- Any new module, any new import line, any `FormalSystem.lean` or aggregator change.
- Any edit to `docs/theorem-index.md` or `FormalSystem/Semantics/**`. C15's second assertion
  constrains the theorem-index rows that already exist; it does not require a row for a new
  declaration, so no row is added.
- Any **hand** edit to a shared generated surface. `README.md`, `FormalSystem/README.md` and
  `FormalSystem/Metalogic/README.md` are reached in Phase 5 only through
  `check-module-invariants.sh --emit-inventory`, which rewrites whole registered blocks; the
  count rows it moves are a mechanical consequence of the two `.lean` edits, not independent
  work. Three of them sit in concurrent sibling task 789's declared `file_scope` — see Risks.
- Any `Tests/BimodalTest/` axiom pin for the new corollaries. A reasonable later addition; out
  of scope here.
- Any edit to `possible_worlds.tex` — read-only input from another repository. Clearing its
  `% PORT:` comment and adding a `\leanproof{}` to `lem:state-set` is paper-side work.
- No nomic machinery. `StarLanguage/README.md` and `OpenLanguage/README.md` both record the
  nomic operator as a deliberate exclusion; deliverable (4) is a pure forward pointer with
  nothing to wire to.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer writes a docstring citation before Phase 1's rows exist, and C15 goes red | M | M | Phase ordering is the mitigation: Phase 1 is Wave 1 and every citing phase depends on it. Run `check-module-invariants.sh --no-build` immediately after the first docstring lands, not at phase end |
| A new docstring line names a capitalized constraint token beside a negation or consumption word, firing C34b | M | L | Write the AXIOM NOTE through `cor:occurrence`/`thm:extension`/Zorn vocabulary only, as `OrderTransfer.lean`'s existing (H2) docstring already does; the trigger needs one of seven capitalized tokens on the same line, so omitting all seven is sufficient |
| `[F.IsRegular]` is added to `StateSetTruth.lean`'s existing `variable` line, silently re-signing the two choice-free originals that `DeterminismUndefinable.lean` consumes | H | M | Phase 3 opens its own `section Regular … end Regular` with its own `variable` line; Phase 3's verification diffs the originals' signatures and asserts they are byte-identical |
| Sibling task 789's uncommitted edits to `Semantics/PartialHistory.lean` and `Semantics/Presheaf/*.lean` are in this task's import closure, so a build failure there looks like a 792 regression | M | H | Already observed at plan time (the blocked re-probe). Treat any failure in a file outside this task's four-file scope as possibly 789's in-flight edit; check `git status --short` and `git log` before assuming the code is wrong, and report rather than repair |
| Concurrent unguarded `lake` invocation collides with this task's build, losing it | M | M | Route every `lake` call through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- …`, detached via `Bash(run_in_background: true)`, with the guard's exit captured un-piped |
| The generated inventory in `Independence/README.md` goes stale by construction (both line counts change) and the INV check fails silently late | M | H | Phase 5 regenerates with `bash scripts/check-module-invariants.sh --emit-inventory` and confirms with `--emit-inventory --check`; never hand-edit the count column, and never call the deprecated `scripts/readme-inventory.sh` shim (it exits 2) |
| Phase 1's five-row insert disturbs a neighbouring row in a 50-row machine-parsed block | M | L | Insert five whole new lines at their alphabetical positions, modify no existing row, then `git diff` the file and confirm exactly five added lines and zero removed |
| `lean-challenge-snapshot.sh --check` reports drift against the carried signatures | L | M | Advisory only, per `plan-compliance.md`: a drift finding is never on its own grounds to fail a phase. A drift finding on the *logical content* of a pinned statement is escalated as `[BLOCKED]`, never quietly re-pinned |
| Shared generated surfaces collide with sibling 789: `README.md` and `FormalSystem/README.md` are in its declared `file_scope`, and `plan-file-scope-harvest.sh` additionally appends `typst/generated/status.typ` (also 789's) unconditionally for any `.lean`-touching plan | M | H | Accepted and declared, not engineered around — the harvester's own header records that two `.lean`-touching tasks really do fight the same generated surfaces and that serializing them is the correct outcome. Phase 5 is the only phase that reaches them, it reaches them only through the generator, and it re-reads plus checks `git status --short` on each first and STOPS on a foreign uncommitted modification. `status.typ` is expected byte-identical here (no axiom, rule, `sorry` or version-pin change), so the harvester's append is a conservative over-approximation for this task, confirmed by `typst-sync-check.sh` rather than assumed |
| Phase 5's `--emit-inventory` regenerates a block a sibling has edited in flight, absorbing its hunk silently | H | L | Whole-block regeneration is exactly where a silent absorb can happen, so the mitigation is ordering plus review: re-read and `git status --short` each shared README before regenerating, stage an explicit file list, and read `git diff --staged` to confirm every hunk is a count this task's own additions moved |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

### Phase 1: Record the five paper anchors (the C15 unblock) [COMPLETED]

**Goal**: Every anchor the later phases cite resolves against
`docs/reference/paper-definitions-of-record.md`, pointer-only, before any docstring cites it.

**Tasks**:
- [x] Re-read the `<!-- KNOWN-ANCHORS:BEGIN -->` … `<!-- KNOWN-ANCHORS:END -->` block immediately
      before editing, and confirm `git status --short` shows the file clean
- [x] Confirm all five anchors are still absent from BOTH the MANIFEST and the KNOWN-ANCHORS
      block (field-1 match on `def:flow`, `def:state-set`, `lem:nomic-occurrence`,
      `lem:state-set`, `prop:nomic-tense-free`)
- [x] Insert five `anchor|LIVE-UNPINNED|note` rows at their alphabetical positions inside the
      `LIVE-UNPINNED` group: `def:flow` and `def:state-set` between `def:BL-language` and
      `def:task-topology`; `lem:nomic-occurrence` and `lem:state-set` between
      `lem:history-time-shift-preservation` and `lem:time-reflection`;
      `prop:nomic-tense-free` between `prop:archimedean` and `sent:det`
- [x] Write each note pointer-only, naming the in-tree counterpart and ending with the block's
      existing "cited as a pointer, text never quoted" formula, on the
      `cor:no-characterization` / `app:drift` / `prop:archimedean` precedent. Add **no**
      MANIFEST row and **no** `sha256:` line for any of the five
- [x] `git diff -- docs/reference/paper-definitions-of-record.md` and confirm exactly five added
      lines, zero removed, zero modified

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `bash scripts/check-module-invariants.sh --no-build` reads this exact
block as C15's own resolution source, so it is the specific covering check for a single-file,
compile-surface-free edit; no MANIFEST row is added, so `check-paper-definitions.sh` gains no
hash to maintain.

**Scope Hypothesis**: the count "five rows" and the claim that all five anchors are absent from
both blocks are hypotheses carried from this plan's own plan-time resolution (field-1 greps over
the MANIFEST and KNOWN-ANCHORS blocks returned 0 for every one of the five, and the live
`\label{}` for each was resolved in `possible_worlds.tex`). Confirm by re-running those field-1
greps before inserting, and by the five-added/zero-removed diff check above.

**Files to modify**:
- `docs/reference/paper-definitions-of-record.md` - five `LIVE-UNPINNED` rows inside the
  `KNOWN-ANCHORS` block; no MANIFEST change, no sentinel change, no new dated section

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` exits 0 and C15 PASSES (the row count in
  its pass line rises by five)
- `bash scripts/check-paper-definitions.sh` exits 0, with no new drifted anchor
- `git diff --stat` on the record file shows `5 insertions(+), 0 deletions(-)`

---

### Phase 2: Discharge (H2) — `StateOccurs.of_isRegular` [COMPLETED]

**Goal**: `StateOccurs F` is derivable from the bundling class, so `def:flow`'s hypothesis set
is all that `lem:state-set`'s tree forms need.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Independence/OrderTransfer.lean` immediately before editing
- [x] In the existing `## (H2) — every state is occupied at every time` section, directly after
      `StateOccurs.state_image`, add
      `theorem StateOccurs.of_isRegular (F : TaskFrame) [F.IsRegular] : StateOccurs F := fun w x => PartialHistory.occurrence F w x`
- [x] Add **no** import line — `FormalSystem.Semantics.Extension.Extension` is already in this
      file's transitive closure; if the explicit `(F : TaskFrame)` binder does not shadow the
      ambient `variable {F : TaskFrame}` cleanly, fix the binder, never the imports
- [x] Write its docstring: it cites `cor:occurrence` by name, states that it routes through
      `thm:extension` and hence Zorn so this form carries `Classical.choice`, and names
      `StateOccurs` as the (H2) hypothesis it discharges
- [x] Write no capitalized `Compositionality`/`Compositional`/`Seriality`/`Serial`/`Limit`/
      `Saturation`/`Saturated` token on any line of that docstring, and no
      `Constraints consumed:` marker
- [x] Cite no `file.lean:NNN` location and no task number anywhere in the docstring

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.OrderTransfer`
is the specific covering check — the edit adds one theorem to one module and changes no existing
signature, so no dependent can observe anything new.

**Scope Hypothesis**: the proof term `fun w x => PartialHistory.occurrence F w x` and the claim
that no new import is needed are CARRIED from the research report's two compiled `lean_run_code`
probes; the plan-time re-probe was blocked by a stale import closure (see Research Integration).
Confirm by the scoped build in this phase's verification, and by `lean_hover_info` on
`PartialHistory.occurrence` for argument order before writing the term.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/OrderTransfer.lean` - one theorem plus docstring in the
  existing (H2) section; no import change, no change to `StateOccurs` or `StateOccurs.state_image`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.OrderTransfer`
  exits 0, detached via `Bash(run_in_background: true)`, exit read from the guard's `result`
  subcommand or an un-piped capture
- `bash scripts/check-module-invariants.sh --no-build` exits 0; C15, C34a, C34b, C9 and C20 all
  PASS *(deviation: altered — C15, C34a, C34b, C9 and C20 all PASS; whole-script exit is 1 on the
  INV generated-inventory group alone, which this plan regenerates in Phase 5, so exit 0 is
  unsatisfiable at this point in the sequence)*
- `lean_verify FormalSystem.Metalogic.Independence.StateOccurs.of_isRegular` reports
  `[propext, Classical.choice, Quot.sound]` and no `sorry`
- `git diff` shows no change to the `StateOccurs` definition or to `StateOccurs.state_image`

---

### Phase 3: The three `_of_isRegular` corollaries [COMPLETED]

**Goal**: `lem:state-set`'s three sentences exist in the tree at `[F.IsRegular] (h : OrderFlow F)`
alone, under names the paper can cite, with the two choice-free originals byte-identical.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Independence/StateSetTruth.lean` immediately before editing
- [x] Open a new trailing `section Regular` after `determined_of_orderFlow`, with its own
      `variable {F : TaskFrame} [LinearOrder F.WorldState] [F.IsRegular]` line, and close it with
      `end Regular` before `end FormalSystem.Metalogic.Independence` *(deviation: altered — the
      section carries no `variable` line; each of the three signatures writes its binders
      explicitly, exactly as `## Lean Challenge Statements` pins them. A second section-local
      `variable {F : TaskFrame} …` would shadow the file's ambient `F`, and the resulting
      signatures are identical either way. The originals are untouched regardless: the diff on
      this file is 63 insertions, 0 deletions)*
- [x] Do **not** touch the file's existing `variable {F : TaskFrame} [LinearOrder F.WorldState]`
      line — adding `[F.IsRegular]` there would re-sign the originals
- [x] Add `plusTruthAt_iff_mem_satSet_of_isRegular (h : OrderFlow F) (M : TaskModel F) (φ : PlusFormula)`,
      proved `plusTruthAt_iff_mem_satSet h (StateOccurs.of_isRegular F) M φ`
- [x] Add `plusValidOn_iff_satSet_univ_of_isRegular (h : OrderFlow F) (φ : PlusFormula)`, proved
      `plusValidOn_iff_satSet_univ h (StateOccurs.of_isRegular F) φ`
- [x] Add `determined_of_orderFlow_of_isRegular (h : OrderFlow F) (φ : PlusFormula)`, proved
      `determined_of_orderFlow h (StateOccurs.of_isRegular F) φ`
- [x] Keep the signatures exactly as `## Lean Challenge Statements` pins them; a drift finding on
      their logical content is escalated as `[BLOCKED]`, never quietly re-pinned
- [x] Each docstring cites `def:flow` and `lem:state-set` by name, says which of the lemma's
      three sentences it is, records that `[F.IsRegular] (h : OrderFlow F)` **is** `def:flow`'s
      hypothesis set with nothing left over, and states that the form routes through
      `cor:occurrence`, hence `thm:extension` and Zorn, so it carries `Classical.choice`
- [x] Tag none of the three `@[simp]`; write none of the seven capitalized constraint tokens on
      any docstring line; write no `Constraints consumed:` marker; cite no `file.lean:NNN`
      location and no task number
- [x] Add no import line

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.StateSetTruth`
is the specific covering check — three additive, untagged theorems inside a new `section` change
no existing signature and no `simp` set, so neither `DeterminismUndefinable.lean` nor
`Independence.lean` can observe anything new.

**Scope Hypothesis**: the three delegation proof terms, and the claim that each closes its goal
by term-mode application alone, are CARRIED from the research report's compiled `lean_run_code`
probes; the plan-time re-probe was blocked by a stale import closure. Confirm by the scoped
build in this phase's verification plus `lean_goal` at each `:=` before committing.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` - a new trailing `section Regular`
  with three theorems and their docstrings; no change to `satSet`, the `Clauses` section, the
  existing `variable` line, or the three original theorems

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.StateSetTruth`
  exits 0, detached and guarded as in Phase 2
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.DeterminismUndefinable`
  exits 0 — the consumer of the two-hypothesis forms still elaborates unchanged
- `git diff -- FormalSystem/Metalogic/Independence/StateSetTruth.lean` shows zero hunks inside
  `satSet`, `plusTruthAt_iff_mem_satSet`, `plusValidOn_iff_satSet_univ` or
  `determined_of_orderFlow`, and no change to the `variable` line at the start of the bridge
  section
- `lean_verify` on each of the three new names reports `[propext, Classical.choice, Quot.sound]`
  and no `sorry`; `lean_verify FormalSystem.Metalogic.Independence.plusTruthAt_iff_mem_satSet`
  still reports `[propext]` and
  `lean_verify FormalSystem.Metalogic.Independence.determined_of_orderFlow` still reports
  `[propext, Quot.sound]`
- `bash scripts/check-module-invariants.sh --no-build` exits 0; C15, C34a, C34b, C9, C20 and C33
  all PASS *(deviation: altered — all six named checks PASS; whole-script exit is 1 on the INV
  generated-inventory group alone, regenerated in Phase 5)*

---

### Phase 4: The two module-docstring records [IN PROGRESS]

**Goal**: `StateSetTruth.lean`'s module docstring states the current design — (H2) derivable for
regular frames, both hypothesis forms live for different reasons — and carries the nomic forward
pointer the nomic port will reuse.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Independence/StateSetTruth.lean` immediately before editing
- [ ] Add the three new corollary names to the module docstring's `## Main Results` list, each
      with a one-line gloss naming which sentence of `lem:state-set` it is
- [ ] Add the (H2) note, phrased as the **current design** and not as a change to it: (H2) is
      *derivable* for regular frames via `StateOccurs.of_isRegular`, and the two-hypothesis forms
      are retained because `Independence/DeterminismUndefinable.lean` discharges (H2) by explicit
      affine witnesses and so stays choice-free. Use no "is now", "no longer", "previously",
      "formerly" or any other phrasing relative to an unstated past
      (`.claude/rules/no-record-versioning-in-deliverables.md`)
- [ ] Add the nomic forward pointer to the `## References` section: `prop:nomic-tense-free` runs
      the same state-set induction over the tense-free fragment `{p_i, ⊥, →, □, Nomic}`, with `□`
      and `Nomic` sharing one clause and no temporal clauses at all; its `□` case consumes
      `cor:occurrence` and its `Nomic` case consumes `lem:nomic-occurrence`, which is
      `cor:occurrence` applied to the relativized frame; and no nomic machinery exists in this
      tree, which `StarLanguage/README.md` and `OpenLanguage/README.md` record as a deliberate
      exclusion
- [ ] Cite `def:flow`, `def:state-set` and `lem:state-set` by name in the `## References` list
      alongside the existing anchors
- [ ] Cite **no** task number anywhere (C9 asserts zero task-number citations under
      `FormalSystem/`, and `.claude/rules/no-task-references-in-deliverables.md` binds the whole
      repository outside `specs/**`); cite no `file.lean:NNN` location
- [ ] Write none of the seven capitalized constraint tokens on any new docstring line

**Timing**: 0.5 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: `bash scripts/check-module-invariants.sh --no-build` is the specific
covering check for this edit's whole risk surface (C15 anchor resolution, C34b's trigger, C9's
task-number assertion, C20's citation assertions), run together with the single-module scoped
build that confirms the `/-! -/` block still parses.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` - module docstring only: `## Main
  Results` entries, the (H2)-derivability note, and the `## References` additions

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` exits 0 with zero `FAIL` lines; C15, C34a,
  C34b, C9 and C20 all PASS
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.StateSetTruth`
  exits 0
- `grep -nE '\b(task|tasks) [0-9]+' FormalSystem/Metalogic/Independence/StateSetTruth.lean`
  returns nothing
- Diff read-through confirms every changed hunk lies inside the `/-! … -/` module docstring, and
  that no sentence phrases the design relative to an unstated past

---

### Phase 5: Inventory refresh, axiom confirmation, and the full gate sweep [NOT STARTED]

**Goal**: Every generated inventory block the two `.lean` edits make stale is current, the six
axiom profiles are confirmed against the implementer's own files rather than a probe, and the
whole repository gate set is green.

**Tasks**:
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory` to regenerate **every**
      registered `BEGIN GENERATED` block, not only the Independence one. Three ancestor blocks
      cover these edits: `FormalSystem/Metalogic/Independence/README.md` (per-file line counts),
      `FormalSystem/Metalogic/README.md` (the `Independence/` subdir files/lines totals row), and
      `README.md` (the `dir=FormalSystem rows=totals` row). `FormalSystem/README.md`'s block is
      `rows=loose` over the `FormalSystem/` top level, so it may not change — let the generator
      decide, and do not hand-edit a count in any of the four. Never call
      `scripts/readme-inventory.sh` (a deprecated shim that exits 2)
- [ ] Hand-edit only the trailing description column of the `OrderTransfer.lean` and
      `StateSetTruth.lean` rows in `FormalSystem/Metalogic/Independence/README.md` to name the
      new declarations, and extend the `plusTruthAt_iff_mem_satSet` bullet in that README's
      `## Key Results` section to name the three corollaries and the discharge theorem
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` to confirm every block
      is current
- [ ] `bash scripts/typst-sync-check.sh` to confirm `typst/generated/status.typ` is **not** stale.
      This task adds no axiom, no rule, no `sorry` and no version-pin change, so the regenerated
      counts are expected byte-identical; if the check disagrees, regenerate with
      `bash scripts/typst-status-counts.sh` and say so in the summary rather than hand-patching
- [ ] Re-confirm all six axiom profiles with `lean_verify` against the implemented files: the
      four new declarations at `[propext, Classical.choice, Quot.sound]`,
      `plusTruthAt_iff_mem_satSet` at `[propext]`, `determined_of_orderFlow` at
      `[propext, Quot.sound]`
- [ ] Before touching `README.md` or `FormalSystem/README.md`, re-read each and check
      `git status --short`: both are in concurrent sibling task 789's declared `file_scope`. If
      either carries a foreign uncommitted modification, STOP and report rather than regenerate
      over it — the generator rewrites whole blocks and would silently absorb a sibling's
      in-flight hunk
- [ ] Stage by explicit file list only — never a directory or glob `git add` — and review
      `git diff --staged` to confirm every hunk in a shared generated file is a count this task's
      own `.lean` additions moved
- [ ] Run the full gate set (below). If a failure lands in a file outside this task's declared
      scope, check `git status --short` and `git log` for a sibling's in-flight edit before
      treating it as a 792 regression, and report rather than repair
- [ ] Record the issue-log entries for this phase, and write the implementation summary

**Timing**: 1.0 hours

**Depends on**: 4

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Metalogic/Independence/README.md` - regenerated per-file inventory counts plus
  the two hand-written description cells and the `## Key Results` bullet
- `FormalSystem/Metalogic/README.md` - regenerated `Independence/` subdir files/lines totals row
- `README.md` - regenerated `dir=FormalSystem rows=totals` row
- `FormalSystem/README.md` - regenerated only if the generator's `rows=loose` block over the
  `FormalSystem/` top level actually changes; leave untouched otherwise
- `specs/792_pin_lem_state_set_flow_frames/summaries/01_pin-lem-state-set-flow-frames-summary.md` -
  implementation summary

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 for the whole
  project, detached via `Bash(run_in_background: true)`, exit read un-piped or from the guard's
  `result` subcommand
- `bash scripts/check-module-invariants.sh --no-build` exits 0 with zero `FAIL` lines
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- `bash scripts/check-paper-definitions.sh` exits 0
- `bash scripts/check-phantom-citations.sh` exits 0
- `bash scripts/readme-lint.sh` exits 0
- `python3 scripts/export-lean-citations.py --check` exits 0
- `bash .claude/scripts/verify-deploy.sh` exits 0 — the complete repository gate aggregator, run
  un-narrowed: no `--only-gate` subset and no `--skip-slow`
- Zero `sorry` and zero new `axiom` anywhere in the diff
- `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` is byte-identical to HEAD

---

## Lean Challenge Statements

The four signatures below are CARRIED from the research report's two compiled `lean_run_code`
probes; the plan-time re-probe returned "Imports are out of date and must be rebuilt" because a
concurrent sibling holds uncommitted edits inside this task's import closure (see Research
Integration). Each block declares explicit binders rather than relying on either target file's
ambient `variable` line, so the module type-checks standalone.

```lean
import FormalSystem.Metalogic.Independence.StateSetTruth

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.PlusLanguage

/-- (H2) discharged from the bundling class: `cor:occurrence`, hence Zorn. -/
theorem StateOccurs.of_isRegular (F : TaskFrame) [F.IsRegular] : StateOccurs F := sorry

/-- `lem:state-set`, first sentence: truth over a `def:flow` frame is state-set membership. -/
theorem plusTruthAt_iff_mem_satSet_of_isRegular {F : TaskFrame}
    [LinearOrder F.WorldState] [F.IsRegular] (h : OrderFlow F)
    (M : TaskModel F) (φ : PlusFormula) :
    ∀ (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t φ ↔ τ.state t ∈ satSet M.valuation φ := sorry

/-- `lem:state-set`, third sentence: `⊨_F φ` iff `|φ| = W` under every assignment. -/
theorem plusValidOn_iff_satSet_univ_of_isRegular {F : TaskFrame}
    [LinearOrder F.WorldState] [F.IsRegular] (h : OrderFlow F) (φ : PlusFormula) :
    F.PlusValidOn φ ↔ ∀ V : F.WorldState → Atom → Prop, satSet V φ = Set.univ := sorry

/-- `lem:state-set`, second sentence: *Determined* is valid over every `def:flow` frame. -/
theorem determined_of_orderFlow_of_isRegular {F : TaskFrame}
    [LinearOrder F.WorldState] [F.IsRegular] (h : OrderFlow F) (φ : PlusFormula) :
    F.PlusValidOn (.imp φ (.stab φ)) := sorry

end FormalSystem.Metalogic.Independence
```

## Decisions

- **Both new sites go in the two existing files; no new module.** The import closure already
  reaches `Extension.lean`, so a new module buys nothing and would cost a `FormalSystem.lean`
  regeneration (C33) and an aggregator change (C8).
- **The corollaries live in `StateSetTruth.lean`, not `OrderTransfer.lean`.** They mention
  `satSet` and `PlusValidOn`, which `OrderTransfer.lean` neither imports nor discusses, and the
  (H2)-derivability note belongs beside them.
- **Mechanical `_of_isRegular` suffixing over prettier names.** Each name greps straight back to
  the two-hypothesis original it specializes, the suffix is this tree's existing marker for
  "the bundling class discharged this" (`completion_of_isRegular`, `isRestriction_of_isRegular`),
  and the names match the `\leanproof{\texttt{Independence.…}}` convention the paper already
  uses at `app:drift` and `cor:no-characterization`. `determined_of_orderFlow_of_isRegular`'s
  double `_of_` is accepted as the price of mechanical derivability.
- **`StateOccurs.of_isRegular`, not `stateOccurs_of_isRegular`.** The dispatch names the former
  and the file already hosts `StateOccurs.state_image` in that namespace;
  `completion_of_isRegular` is the shape precedent, not the spelling precedent.
- **Five KNOWN-ANCHORS rows, not the report's three.** The three the dispatch's citations require
  (`def:flow`, `def:state-set`, `lem:state-set`), plus `lem:nomic-occurrence` because Phase 4's
  forward pointer names it and `lem:` is in C15's gated prefix set, plus `prop:nomic-tense-free`
  for consistency with the existing `prop:archimedean` row even though `prop:` is not gated. The
  marginal cost of the last two is one line each and zero hash commitments; the benefit is that
  the nomic port inherits two recorded anchors instead of re-deriving them.
- **Pointer-only `LIVE-UNPINNED` rows over MANIFEST pins.** A MANIFEST row would require a
  verbatim transcription plus a `sha256:` that `check-paper-definitions.sh` must then keep
  matching against a paper in another repository — and the paper moved between the research and
  plan dispatches, twice over, which is exactly that cost in evidence. Nothing here quotes the
  paper. Promote to a pin only if a later task starts quoting one verbatim.
- **No `Constraints consumed:` marker, achieved by writing none of the seven capitalized
  constraint tokens.** The AXIOM NOTE's content is cleaner stated through
  `cor:occurrence` → `thm:extension` → Zorn than through the constraints `step` consumes, it is
  the vocabulary `OrderTransfer.lean`'s existing (H2) docstring already uses, and `occurrence` —
  the declaration being specialized — carries no marker either. If a future author judges that
  naming two of the constraints materially improves a docstring, the remedy is one line copying
  `Extension.lean`'s full four-constraint marker verbatim; a marker omitting any of the four
  would then face C34a.
- **The paper's `□`-clause encoding is left alone.** `def:state-set`'s
  `|□φ| := W if |φ| = W else ∅` and `satSet`'s `{_w | ∀ v, v ∈ satSet V φ}` are extensionally
  equal, and the module docstring already records why the ignoring-set form was chosen. That is
  a recorded decision, not drift to repair.
- **Phase 1 proceeds on the shared tree rather than behind a dependency edge.** The record file's
  only declared claimant (task 756) has reached `completed` and the file is clean in git, so the
  report's serialization fallback is not needed.

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 for the
      whole project (the dispatch's headline constraint)
- [ ] Zero `sorry` and zero new `axiom` in the diff
- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0 with zero `FAIL` lines; C15,
      C34a, C34b, C9, C20, C33 and C35 all PASS
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- [ ] `bash scripts/check-paper-definitions.sh` exits 0, with no new drifted anchor and no new
      `sha256:` line in the record
- [ ] `bash scripts/check-phantom-citations.sh` exits 0
- [ ] `bash scripts/readme-lint.sh` exits 0
- [ ] `bash scripts/typst-sync-check.sh` exits 0
- [ ] `python3 scripts/export-lean-citations.py --check` exits 0
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0, un-narrowed
- [ ] `lean_verify` reports `[propext, Classical.choice, Quot.sound]` for all four new
      declarations, `[propext]` for `plusTruthAt_iff_mem_satSet`, and `[propext, Quot.sound]` for
      `determined_of_orderFlow`
- [ ] `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` is byte-identical to HEAD
- [ ] No docstring under `FormalSystem/` cites a task number or a `file.lean:NNN` location added
      by this task
- [ ] No new docstring line carries any of `Compositionality`, `Compositional`, `Seriality`,
      `Serial`, `Limit`, `Saturation`, `Saturated`

## Artifacts & Outputs

- `specs/792_pin_lem_state_set_flow_frames/plans/01_pin-lem-state-set-flow-frames.md` (this file)
- `docs/reference/paper-definitions-of-record.md` — five `LIVE-UNPINNED` KNOWN-ANCHORS rows
- `FormalSystem/Metalogic/Independence/OrderTransfer.lean` — `StateOccurs.of_isRegular`
- `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — the three `_of_isRegular`
  corollaries, the (H2)-derivability note, and the nomic forward pointer
- `FormalSystem/Metalogic/Independence/README.md` — refreshed inventory and `## Key Results`
- `FormalSystem/Metalogic/README.md`, `README.md`, and (conditionally) `FormalSystem/README.md` —
  regenerated inventory count rows only
- `specs/792_pin_lem_state_set_flow_frames/summaries/01_pin-lem-state-set-flow-frames-summary.md`

## Rollback/Contingency

Every phase is additive and commits independently, so the ordinary contingency is `git revert`
of the offending phase commit — no snapshot is required and none should be taken as a routine
start-of-phase precaution.

- **A phase's gate fails**: fix forward. Never discard uncommitted changes to reach a passing
  build (`.claude/rules/error-handling.md`).
- **Phase 2 or 3 will not elaborate as the carried signatures predict**: this is a Challenge
  statement discrepancy, so `plan-compliance.md` applies — mark the phase `[BLOCKED]`, record the
  goal state reached, and escalate. Do not substitute a different, more convenient statement, and
  do not quietly re-pin the Challenge block to match what compiled.
- **Phase 1's insert disturbs a neighbouring row**: `git checkout HEAD --` on the record file
  alone, before any later phase has touched it, then redo the insert line by line.
- **A genuine whole-tree rollback becomes necessary**: take the snapshot first, per
  `context/contracts/recovery.md`'s rollback rung (including its out-of-scope override flag) —
  never a bare reverting `git-snapshot.sh` as a precaution.
- **A build failure lands outside this task's four-file scope**: do not repair it. Check
  `git status --short` and `git log` for a concurrent sibling's in-flight edit, report it, and
  treat the failure as not necessarily this task's regression.
