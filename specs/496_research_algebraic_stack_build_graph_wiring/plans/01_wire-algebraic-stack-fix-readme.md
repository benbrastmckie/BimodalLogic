# Implementation Plan: Wire the Algebraic Stack into the Build Graph

- **Task**: 496 - research_algebraic_stack_build_graph_wiring
- **Status**: COMPLETED
- **Effort**: 2.75 hours
- **Dependencies**: None
- **Research Inputs**: `specs/496_research_algebraic_stack_build_graph_wiring/reports/01_algebraic-stack-build-graph-wiring.md`
- **Artifacts**: plans/01_wire-algebraic-stack-fix-readme.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research report reached a decisive recommendation — **option (a), re-wire** — and this plan
implements it rather than re-adjudicating it. One import line (`import
FormalSystem.Metalogic.Algebraic` in `FormalSystem/Metalogic.lean`) brings `LindenbaumQuotient`,
`BooleanStructure`, `InteriorOperators`, `UltrafilterMCS` and the aggregator itself into the Lake
build closure, at a measured cost of 5.3s elaboration and 948 KB of `.olean`. That single line
forces five now-stale entries out of `scripts/module-invariants-manifest.txt` in the same commit
(C6 fails if a manifest entry names a reachable module), so the code change is one atomic
two-file batch, not two independent edits.

The remaining four phases are documentation-correctness work: the `Algebraic/README.md`
overstatements the task named plus the further inaccuracies the audit found, the two stale claims
in `Metalogic/README.md`, and a note recording the adjudication where the elaboration hazard was
originally raised so the next reader of the Boneyard does not re-inherit an unqualified warning.

### Research Integration

The plan follows the report's evidence directly and does not re-open the settled question:

- **F4 (measured)** — the elaboration-conflict hazard does not reproduce. Variant B placed the
  whole algebraic stack *upstream* of `BXCanonical/Completeness.lean`, forced genuine
  re-elaboration of `Completeness`, `CompletenessDedekind` and `StrongCompleteness` (`Built`, not
  `Replayed`, in the log), and finished `rc=0` with zero errors. Variant A — the position this
  plan actually implements — is likewise green. **This plan therefore does not re-run the
  Variant B experiment**; Phase 1 verifies only the recommended wiring.
- **D2** — wire at `FormalSystem/Metalogic.lean`, not at `BXCanonical/Completeness.lean`. Both are
  green; the downstream position avoids falsely asserting that completeness depends on this
  algebra (F1: the four modules have zero consumers anywhere in the live tree).
- **D3** — import the aggregator, not the deepest leaf, so all five manifest lines clear and the
  aggregator itself becomes `lake build`-verified.
- **F9** — `scripts/module-invariants-manifest.txt` already documents the required move ("Wiring a
  module into the build graph means DELETING its line here"); C8 is unaffected because the
  aggregator file does not move, it merely acquires an importer.
- **F7 / F8** — the seven `Algebraic/README.md` corrections and the two `Metalogic/README.md`
  corrections are transcribed into Phases 2 and 3 as specified, including the two overstatements
  the task itself named.

The BiLasso wiring recorded in `FormalSystem/Metalogic/Decidability/BiLasso/README.md:225-232`
(one import added to `Decidability.lean`, manifest lines deleted in the same commit) is the
in-repo precedent for the exact shape of Phase 1.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was supplied in the delegation context, and no roadmap phases are included.
The report notes (D4, and its "Risks" row on `UltrafilterFrame`/`TenseS5Algebra`) that the STSA /
Jonsson–Tarski port is the downstream consumer this work unblocks; that port remains a separate
task and is explicitly out of scope here.

## Goals & Non-Goals

**Goals**:
- Bring all five `FormalSystem/Metalogic/Algebraic/` modules into the `lake build` closure via one
  import in `FormalSystem/Metalogic.lean`.
- Delete the five now-stale `scripts/module-invariants-manifest.txt` entries and rewrite the
  surrounding comment block, which currently explains at length why those modules are unreachable.
- Correct all seven documented overstatements/inaccuracies in
  `FormalSystem/Metalogic/Algebraic/README.md`, including the two the task named explicitly
  ("not optional"/"participates in the live proof", and "G and H are shown to be interior
  operators").
- Correct the two `FormalSystem/Metalogic/README.md` inaccuracies (stale "parametric" role labels;
  the aggregator rule that is already false at HEAD and the adjoining "no importer" claim).
- Record the adjudication in the Boneyard, scoped so the warning stays in force for the two files
  that were **not** tested.
- Leave `lake build` green and every `scripts/check-module-invariants.sh` check that passes today
  still passing.

**Non-Goals**:
- Re-running the Variant B adversarial experiment. It is already measured (F4); repeating it is
  not a gate on this change.
- Widening scope to `Core.lean`, `Bundle.lean` or `SoundnessLemmas.lean` (D4) — same manifest
  block, same shape, but each needs its own cycle analysis and none was tested.
- Recovering `UltrafilterFrame.lean` / `TenseS5Algebra.lean` from the Boneyard, or building them.
  They carry five sorries, were not built, and their hazard remains untested and in force.
- Re-litigating whether `Algebraic/` should be described as a "completeness route" at all. The
  directory's own flowchart already says "no completeness theorem is stated here", which makes the
  `Metalogic/README.md` route-table framing arguable — but the report flagged only the word
  "parametric", and this plan changes only what the report evidenced. Recorded as an observation
  for a future documentation pass.
- Adding `context/project/lean4/patterns/testing-archived-elaboration-hazards.md` (the report's
  Context Extension Recommendation). That is agent-system work under
  `agent-system/extensions/**`, a different source store and a different task type.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A red `lake build` caused by a *concurrent* task editing `FormalSystem/`, misattributed to this change | H | M | Phase 1 opens with a baseline build at HEAD **before** any edit and records its `rc`. A post-edit failure is attributable only if the baseline was green. Also capture `git status --short FormalSystem/` before and after. |
| Partial landing of the atomic batch leaves C6 red (import without manifest deletion, or the reverse) | H | M | Phase 1 is declared `Commit Mode: atomic-batch` over exactly two files. Intermediate per-file states are expected red and MUST NOT be committed. |
| README edits trip C5/C12, which scan `FormalSystem/**/*.md` for stale dotted and slash-form module paths | M | M | Every prose phase runs `bash scripts/check-module-invariants.sh --no-build` as its own verification, and Phase 5 re-runs the full gate. |
| The generic `Membership α (Ultrafilter α)` instance (`UltrafilterMCS.lean:63`) or the two `@[simp]` lemmas (`:537`, `:976`) interfere with elaboration somewhere not exercised today | M | L | Not observed in either measured variant (F4). Named here so a future breakage has a first suspect; scoping it (`scoped instance`) is the remedy if it ever bites. |
| Line numbers cited from the report (`:33`, `:154-158`, `:171`) have drifted | L | M | Every phase locates its edit sites by `grep` on the quoted text, never by line number. Line numbers in this plan are navigational hints only. |
| Future edits to these four modules now break the whole build rather than only C6 | L | H | Accept — this is the point of the change, not a side effect. That is what "verified by `lake build`" means. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 2, 3, 4 |

Phases within the same wave can execute in parallel. Wave 2's three phases touch disjoint files
(`Algebraic/README.md`; `Metalogic/README.md`; `Boneyard/UltrafilterFrame/README.md` +
`Boneyard/README.md`) and may be dispatched concurrently under territory contracts.

---

### Phase 1: Wire the Aggregator and Clear the Manifest [COMPLETED]

**Goal**: `FormalSystem.Metalogic.Algebraic` and its four children become reachable from the Lake
default target root, and `scripts/module-invariants-manifest.txt` stops claiming they are not.

**Tasks**:
- [x] Record the pre-edit baseline: `git status --short FormalSystem/ scripts/` (expect empty for
      these paths) and a detached baseline build (see Verification for the exact invocation).
      Record its `rc`. **If the baseline is not green, stop and report** — a pre-existing red tree
      makes this phase's result unattributable.
- [x] Add `import FormalSystem.Metalogic.Algebraic` to `FormalSystem/Metalogic.lean`, immediately
      after the existing `import FormalSystem.Metalogic.Conservativity` line (currently `:15`).
      One line. Do not reorder the existing imports.
- [x] Delete these five lines from `scripts/module-invariants-manifest.txt`:
      `FormalSystem.Metalogic.Algebraic` (currently `:29`) and
      `FormalSystem.Metalogic.Algebraic.{BooleanStructure,InteriorOperators,LindenbaumQuotient,UltrafilterMCS}`
      (currently `:51-54`). Delete only these five; leave `Core`, `Bundle`, `SoundnessLemmas`,
      `Bundle.Construction` and `SoundnessLemmas.CoValidity` untouched.
- [x] Rewrite the two comment blocks that now describe a state that no longer holds:
      - The first block (currently `:20-26`) lists the sibling aggregators as "deliberately have
        no importer". Three remain; `Algebraic` is no longer among them.
      - The second block (currently `:34-50`) must lose the `Algebraic/FlowFrame.lean`
        contrast-case paragraph (it no longer contrasts with anything, since all five files in
        that directory are now reachable), lose the "The four `Algebraic/` modules below" sentence,
        and have its coverage note's "these six" count corrected to the number of entries that
        actually remain in the block after deletion.
      - Preserve verbatim the two load-bearing sentences: the `DELETE a line here when...`
        instruction and the rot-guard rationale. They are what made this change correct.

**Timing**: 0.75 hours (including the detached build wait)

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

Declared file set (exactly two files, one objective):
- `FormalSystem/Metalogic.lean`
- `scripts/module-invariants-manifest.txt`

Either file alone leaves `check-module-invariants.sh` C6 red — the import without the deletion
makes five manifest entries name reachable modules; the deletion without the import leaves five
unreachable modules unmanifested. Intermediate per-file states are expected red and MUST NOT be
committed. Do not widen this batch beyond the two files above.

**Scope Hypothesis**: The plan asserts *exactly five* manifest lines and *exactly one* import
line. Confirm at implementation time, before editing:
`grep -n '^FormalSystem\.Metalogic\.Algebraic' scripts/module-invariants-manifest.txt` must return
exactly 5 lines, and
`grep -rn 'import FormalSystem\.Metalogic\.Algebraic$' FormalSystem/ --include=*.lean` must return
0 lines (no live importer yet). If either count differs, stop and report rather than adapting
silently.

**Files to modify**:
- `FormalSystem/Metalogic.lean` - add one import after `Conservativity`
- `scripts/module-invariants-manifest.txt` - delete five entries; rewrite two comment blocks

**Verification**:
- Detached build, per `context/project/lean4/operations/long-builds.md` — `Bash(run_in_background:
  true)`, never foreground:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`
  Must be `rc=0` with zero `error:` lines.
- Confirm the five modules genuinely entered the closure rather than replaying: the build log must
  show `Built FormalSystem.Metalogic.Algebraic` and `Built
  FormalSystem.Metalogic.Algebraic.{LindenbaumQuotient,BooleanStructure,InteriorOperators,UltrafilterMCS}`.
  (Expected marginal cost per F5: ~5.3s elaboration, 948 KB `.olean`.)
- `bash scripts/check-module-invariants.sh` must pass, with C6 reporting no stale entries and no
  unmanifested unreachable modules. Compare against the baseline run: every check green at HEAD
  must still be green.
- `git diff --staged` shows exactly the two declared files and no others.

---

### Phase 2: Correct `Algebraic/README.md` [COMPLETED]

**Goal**: `FormalSystem/Metalogic/Algebraic/README.md` states what the directory actually proves
and what actually consumes it.

**Tasks**:
- [x] **Header status** (`:3`) — replace "Active -- infrastructure consumed by the live
      completeness proof". Say two things instead: `FlowFrame.lean` is consumed by the live
      completeness proof, and the Boolean-algebra/ultrafilter layer is standalone sorry-free
      infrastructure with no current consumer, now covered by `lake build` (Phase 1).
- [x] **"Not optional" claim** (Purpose note, `:20-24`) — drop "This directory is **not** optional
      relative to it" and "so `Algebraic/` participates in the live proof rather than standing
      beside it" as directory-wide claims. Scope both to `FlowFrame.lean`.
- [x] **Importer list** (same note) — the list of four (`Completeness.lean`,
      `ChronicleToCountermodelBasic.lean`, `ChronicleMonadicBridge.lean`,
      `DiscreteCarrierProbe.lean`) is incomplete. There are **six** importers of
      `Algebraic.FlowFrame`; the two omitted are `Bundle/LimitMCS.lean` and
      `WeakCanonical/GroupModel/CountermodelBase.lean`. Note that the last two are not under
      `BXCanonical/`, so the sentence's "`BXCanonical` imports ..." framing needs widening, not
      just two more filenames appended.
- [x] **Interior-operators claim** (`:125`) — replace "G and H are shown to be interior operators
      using the T and 4 axioms" with what is actually proved: `boxInterior`
      (`InteriorOperators.lean:142`) is the only `InteriorOp`, assembled from `box_le_self`
      (`:101`), `box_monotone` (`:112`) and `box_idempotent` (`:130`); `H_monotone` (`:80`) is the
      only surviving G/H-family result. There is **no G operator on the quotient at all** — the
      quotient carries `boxQuot` (`LindenbaumQuotient.lean:289`), `hQuot` (`:296`) and `negQuot`
      (`:261`), and `gQuot` does not exist anywhere in the repository. The file's own module
      docstring (`InteriorOperators.lean:29-43`) already says this correctly and is the model to
      follow.
- [x] **Mathematical Overview step 3** (`:149-152`) — this passage repeats the same false claim in
      expanded form ("Show G and H are interior operators", with G-specific deflationary/monotone/
      idempotent bullets). Correct it in the same pass; leaving it would reinstate the error the
      previous bullet removes.
- [x] **Modules table row** (`:39`) — `InteriorOperators.lean` → "Box as interior operator; H
      monotonicity".
- [x] **Footer** (`:200`) — refresh `*Last updated: 2026-04-06*` to the current date.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: The report enumerates seven F7 items; this phase lists them plus the
Mathematical Overview passage found to repeat the interior-operator claim (eight edit sites). Confirm
at implementation time by re-reading the file end to end and by
`grep -n 'interior operator\|not.*optional\|participates in the live proof\|Last updated'
FormalSystem/Metalogic/Algebraic/README.md`; if a site listed here is absent, or an eighth
occurrence of a corrected claim survives the pass, report the discrepancy rather than closing the
phase.

**Files to modify**:
- `FormalSystem/Metalogic/Algebraic/README.md` - eight edit sites above

**Verification**:
- Diff read-through confirming every changed hunk is markdown prose with no compile surface.
- `grep -n 'G and H are shown to be interior operators\|not\*\* optional\|participates in the live
  proof' FormalSystem/Metalogic/Algebraic/README.md` returns nothing. *(verified; the scoped
  FlowFrame-only restatement was worded to avoid the retired phrase rather than to reuse it.)*
- `grep -c 'gQuot' FormalSystem/Metalogic/Algebraic/README.md` returns 0 — the correction must not
  introduce a name that does not exist. *(deviation: altered — the literal unanchored grep returns 1,
  because the corrected text names `negQuot`, which this same phase instructs be named and which
  contains `gQuot` as a substring. The word-anchored form `grep -c '\bgQuot'` returns 0, which is the
  criterion actually intended; verified.)*
- `bash scripts/check-module-invariants.sh --no-build` passes (C5/C12 scan markdown for stale
  dotted and slash-form module paths).

---

### Phase 3: Correct `Metalogic/README.md` [COMPLETED]

**Goal**: The parent README stops describing a deleted parametric stack and stops asserting an
aggregator rule that HEAD already violates.

**Tasks**:
- [x] **Route table row** (currently `:33`) — drop "Parametric" from the route label and remove
      "and a parametric canonical model" from the approach column. The parametric canonical stack
      was deleted (`6c3419a4f`) and `Algebraic.lean`'s own docstring says so. Describe what is
      there: the Lindenbaum–Tarski quotient algebra, the ultrafilter–MCS correspondence, and the
      flow-frame countermodel engine.
- [x] **Directory Inventory row** (currently `:171`) — same fix for the "Parametric/algebraic
      completeness route" role label.
- [x] **Aggregator rule** (currently `:154`) — "No existing file is edited to import an aggregator
      — that is how a genuine module-level cycle would appear" is already false at HEAD:
      `Metalogic.lean` imports `Decidability` (`:11`), `Independence` (`:12`), `BXCanonical`
      (`:13`) and `WeakCanonical` (`:14`), and after Phase 1 it imports `Algebraic` too. Restate
      the rule in its true narrow form: *do not import an aggregator whose own contents already
      reach the importing file* — that is the shape that creates a module-level cycle.
- [x] **"No importer" claim** (currently `:154-158`) — "Consequently `Core.lean`, `Bundle.lean`,
      `Algebraic.lean` and `SoundnessLemmas.lean` have no importer and lie outside every Lake
      target's import closure" becomes false for `Algebraic.lean` the moment Phase 1 lands. Reduce
      the list to the three that remain, and say that `Algebraic.lean` is now imported by
      `Metalogic.lean` and covered by `lake build` rather than by the C6 manifest.
- [x] Refresh the `*Last verified:*` footer date if the edits land on a later day.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: Four edit sites are asserted, at approximately `:33`, `:154`, `:154-158` and
`:171`. Line numbers are hints only — locate each by grepping its quoted text
(`grep -n 'Parametric\|No existing file is edited to import an aggregator\|have no importer'
FormalSystem/Metalogic/README.md`). If "Parametric" or "parametric" occurs at a site not listed
here, evaluate it against the same evidence and report the extra occurrence.

**Files to modify**:
- `FormalSystem/Metalogic/README.md` - four edit sites above

**Verification**:
- Diff read-through confirming every changed hunk is markdown prose.
- `grep -ni 'parametric' FormalSystem/Metalogic/README.md` returns nothing that asserts the
  deleted stack still exists.
- The file's own file/line counts (314 live files, the C7 rollup, the `Algebraic/` row's `5 |
  2,887`) are **unchanged** by this task — no `.lean` file is added or removed. Confirm they were
  not edited.
- `bash scripts/check-module-invariants.sh --no-build` passes.

---

### Phase 4: Record the Adjudication in the Boneyard [COMPLETED]

**Goal**: The next reader of the archived `UltrafilterFrame` subtree inherits a *scoped* warning,
not an unqualified one — without weakening it for the two files that were never tested.

**Tasks**:
- [x] Add a short note to `FormalSystem/Boneyard/UltrafilterFrame/README.md`, under or beside the
      "Why Archived" section, stating: the elaboration-conflict concern was tested against the four
      remaining `Metalogic/Algebraic/` modules and did **not** reproduce — an adversarial build
      importing the aggregator directly into `BXCanonical/Completeness.lean` re-elaborated
      `Completeness`, `CompletenessDedekind` and `StrongCompleteness` with `rc=0` and zero errors —
      and those four modules are now wired into the build graph.
- [x] State the scope limit in the same note, explicitly: the warning **remains in force** for
      `UltrafilterFrame.lean` and `TenseS5Algebra.lean` themselves. They carry five sorries, were
      not built, and were not part of the experiment. Anyone recovering them should re-run the
      adversarial (upstream-import) build with those files included before assuming the same clean
      result.
- [x] Mirror the qualification at the second location carrying the same claim:
      `FormalSystem/Boneyard/README.md` (the `### UltrafilterFrame` entry, currently `:377-379`,
      repeats "commented out from Algebraic.lean due to elaboration interference with
      BXCanonical/Completeness.lean rfl proofs" verbatim). A one-clause cross-reference to the
      subdirectory README is sufficient; do not duplicate the full note.
- [x] Cite the evidence by durable path — `specs/496_research_algebraic_stack_build_graph_wiring/reports/01_algebraic-stack-build-graph-wiring.md`
      — and **not** by task number. `.claude/rules/no-task-references-in-deliverables.md` blocks
      `task N` citations outside `specs/**`, and a `PreToolUse` hook enforces it. Note that both
      files already contain pre-existing task-number references; leave those alone rather than
      expanding this phase's scope, but do not add new ones.

**Timing**: 0.25 hours

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: Two files carry the elaboration-interference claim. Confirm with
`grep -rn 'elaboration interference\|elaboration conflict' FormalSystem/ --include=*.md`; if a
third location exists, qualify it in the same pass and note it in the summary.

**Files to modify**:
- `FormalSystem/Boneyard/UltrafilterFrame/README.md` - add the scoped adjudication note
- `FormalSystem/Boneyard/README.md` - one-clause cross-reference on the `UltrafilterFrame` entry

**Verification**:
- Diff read-through confirming markdown-only changes.
- The added text must contain both halves: the negative result for the four wired modules **and**
  the still-in-force warning for the two untested archived files. A note carrying only the first
  half is a regression, not a fix.
- `grep -nE '\b[Tt]asks?[ _#-][0-9]+' <the two files>` shows no *newly added* occurrence.
- `bash scripts/check-module-invariants.sh --no-build` passes (C11 checks archived import
  resolution; C5/C12 scan these READMEs too).

---

### Phase 5: Full Gate and Summary [COMPLETED]

**Goal**: Prove the acceptance criteria on the final tree, with all five phases' edits in place.

**Tasks**:
- [x] Re-run the detached full build on the final tree and confirm `rc=0`, zero `error:` lines.
- [x] Re-run `bash scripts/check-module-invariants.sh` (with build) and diff the check-by-check
      result against the baseline captured in Phase 1. Every check green at HEAD must still be
      green; no check may move from pass to fail, and no new `TODO` line may appear.
- [x] Confirm `git status --short` shows no unintended files and that the working tree contains
      only this task's declared file set plus `specs/**` artifacts.
- [x] Write the execution summary to
      `specs/496_research_algebraic_stack_build_graph_wiring/summaries/01_wire-algebraic-stack-fix-readme-summary.md`,
      recording the measured build result, the invariant-check comparison, and the observations
      this plan deliberately left out of scope (the D4 aggregator candidates `Core.lean`,
      `Bundle.lean`, `SoundnessLemmas.lean`; the "is `Algebraic/` a completeness route at all"
      question; the untested `UltrafilterFrame`/`TenseS5Algebra` hazard).

**Timing**: 0.5 hours

**Depends on**: 2, 3, 4

**Verification Tier**: full

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` detached, `rc=0`.
- `bash scripts/check-module-invariants.sh` passes with no regression against the Phase 1
  baseline.
- The summary file exists and is non-empty.

---

## Testing & Validation

- [x] `lake build` (via `lake-build-guard.sh`, detached) returns `rc=0` with zero `error:` lines
      on the final tree.
- [x] The build log shows all five `FormalSystem.Metalogic.Algebraic*` modules `Built`.
- [x] `bash scripts/check-module-invariants.sh` passes; C6 reports no stale entries, no phantom
      entries, and no unmanifested unreachable modules.
- [x] C8 still passes — the aggregator file did not move, it only acquired an importer.
- [x] No check that passes at HEAD today has regressed.
- [x] `grep` confirms the corrected claims are gone from all three READMEs and the corrected
      statements are present.
- [x] No new `task N`-shaped citation was introduced outside `specs/**`.

## Artifacts & Outputs

- `FormalSystem/Metalogic.lean` — one import line added
- `scripts/module-invariants-manifest.txt` — five entries deleted, two comment blocks rewritten
- `FormalSystem/Metalogic/Algebraic/README.md` — eight corrections
- `FormalSystem/Metalogic/README.md` — four corrections
- `FormalSystem/Boneyard/UltrafilterFrame/README.md` — scoped adjudication note
- `FormalSystem/Boneyard/README.md` — one-clause cross-reference
- `specs/496_research_algebraic_stack_build_graph_wiring/summaries/01_wire-algebraic-stack-fix-readme-summary.md`

## Rollback/Contingency

Every phase is independently revertible, and Phase 1 is the only one with a build surface.

- **If Phase 1's post-edit build is red**: first check the Phase 1 baseline. A red baseline means
  the failure predates this change (likely a concurrent task editing `FormalSystem/`) — stop,
  report, and do not commit. A green baseline with a red post-edit build would contradict the
  report's measured F4 result; capture the full error list, revert both files
  (`git checkout HEAD -- FormalSystem/Metalogic.lean scripts/module-invariants-manifest.txt` —
  safe only because the batch is uncommitted and its two files are the entire change), and report
  the contradiction rather than working around it. Do not run any destructive git command on a
  dirty tree without first running `bash .claude/scripts/git-snapshot.sh 496`.
- **If the doc phases need reverting**: they are prose-only and revert cleanly per file with no
  build impact.
- **Full rollback**: reverting the Phase 1 commit restores the pre-wiring state exactly — the five
  manifest lines return and the modules go back to C6-only coverage. Nothing else in the tree
  depends on the wiring, since the four modules have zero consumers (F1).
