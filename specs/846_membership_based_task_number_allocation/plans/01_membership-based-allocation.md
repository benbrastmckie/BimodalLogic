# Implementation Plan: Task #846

- **Task**: 846 - membership_based_task_number_allocation
- **Status**: [IMPLEMENTING]
- **Effort**: 5.75 hours
- **Dependencies**: None (owning record 821 is research-only; no dependency edge, and no edge to
  751 by the deliberate decision recorded in the task description's Territory Note)
- **Research Inputs**: specs/846_membership_based_task_number_allocation/reports/01_membership-based-allocation.md
- **Artifacts**: plans/01_membership-based-allocation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md,
  source-store-deploy-boundary.md, no-task-references-in-deliverables.md,
  no-record-versioning-in-deliverables.md
- **Type**: meta
- **Lean Intent**: false

## Overview

Replace the max-based allocation bound in `state-write.sh`'s `--allocate-into` prefix and
`validate-state.sh`'s Check 12 with a membership-based bound, so the allocator issues the smallest
number not already in use that is strictly greater than the maximum ACTIVE `project_number`. The
two sites stop computing the bound independently: a new `scripts/lib/project-number-inuse.sh`
holds the single jq definition of the in-use set, the active max, the next free number, and a
number's location, and both scripts consume it. The counter-advance wrinkle is settled below in
favour of a derived number plus a regenerated cache, with the monotonic-advance assertion replaced
(not deleted) by a recording assertion plus in-mutex cache regeneration. All edits land in the
source store under `agent-system/extensions/core/**`; the deployed `.claude/**` tree is reached
only by `deploy-headless.sh`.

### Research Integration

The research report is consumed, not re-derived. Its load-bearing contributions to this plan:

- Every number in the defect narrative is confirmed against live state (active max 846, archive
  combined max 1054 carried by exactly `[949, 953, 992, 998, 1054]`, counter 1055, in-use set
  818 numbers). The "smallest unused from 1" trap sequence (`1, 2, 4, 5, 7, ...`) and the correct
  sequence (`847, 848, 849, ...`) are both confirmed.
- A third edit location inside `state-write.sh` exists beyond the jq allocation prefix: the
  bash-level counter-advance assertion (`ALLOC_PRE_COUNTER` vs. `ALLOC_POST_COUNTER`, strict `-le`
  refusal), with a second copy on the `--dry-run` preview path. Both are in scope for Phase 2.
- `scripts/test-state-write-concurrency.sh` (a sibling of `state-write.sh`, NOT under
  `scripts/tests/`) holds Cases 10-14, a dedicated `--allocate-into` suite. Case 12's expected
  outcome inverts under the corrected bound; Case 11's refusal survives but its asserted message
  text does not.
- `scripts/tests/test-validate-state.sh` Fixtures (c) and (g) invert for the same reason, and
  Fixture (g) is the live layer-agreement guard between the two sites.

Two findings this plan adds on top of the report, both measured during planning:

- No production caller of `--allocate-into` exists. `commands/task.md`, `commands/review.md` and
  `generate-todo.sh` all read `next_project_number` with a plain `jq -r`. That is what makes the
  counter's continued correctness as a readable value a requirement, and it is the decisive input
  to the design decision below.
- Five suites copy `state-write.sh` into a throwaway temp root alongside an explicit, hard-coded
  lib allow-list (`state-write.sh`, `task-lock.sh`, `generate-todo.sh`, `deploy-root-guard.sh`,
  `lib/common.sh`, `lib/task-lookup-lib.sh`). Adding a `source` line to `state-write.sh` without
  extending those allow-lists breaks all five immediately. Measured set:
  `scripts/test-state-write-concurrency.sh`, `scripts/test-state-write-large-payload.sh`,
  `scripts/test-state-write-regen-timing.sh`, `scripts/test-state-write-spill-names.sh`,
  `scripts/tests/test-orchestrate-cycle-plan.sh`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap context was provided in this dispatch, and no roadmap phases are required.

## Goals & Non-Goals

**Goals**:

- The allocator issues the smallest number not in the in-use set that is strictly greater than the
  maximum active `project_number`, running the dense sequence and skipping isolated in-use
  outliers as it reaches them.
- `Check 12` and the `--allocate-into` bound agree on one shared notion of "in use", held in one
  place rather than in two independently written expressions kept aligned by comment.
- An allocation that would issue an in-use number is refused with no write, naming the number and
  the array it is in use in.
- The counter-advance wrinkle is decided, implemented, and recorded in the deliverable with the
  rejected option stated on its own merits.
- The fail-closed posture, the mutex scope, the `specs/vault/**` exclusion, the archive's
  append-only status, and duplicate tolerance in the in-use collection are all preserved exactly.

**Non-Goals**:

- Relocating the five pre-reset archive rows to `specs/vault/**`. Rejected on its own merits in
  the task description; this plan does not revisit it.
- Renumbering, moving, or deleting any archived row.
- Any change to `--archive` or `--deep` mode behaviour.
- Any change to the allocator's mutex or concurrency design.
- The `/todo` vault threshold behaviour that keys off `next_project_number > 1000`. Independently
  gated, out of scope, and noted only so the two are not conflated.
- Hand-authoring anything under `.claude/**`.

## Design Decision: the Counter Stops Being the Allocation Authority

This settles the wrinkle the task description requires to be decided and recorded. It is a
planning judgment call between two workable approaches, not an open question.

**Decided**: option (b). `next_project_number` becomes a regenerable cache; the issued number is
derived from the in-use set on every allocation.

- The issued number is `pnum_next_free`: the smallest number absent from the in-use set and
  strictly greater than the maximum active `project_number`. It is never read from the counter.
- The counter is still validated fail-closed before any allocation: absent, non-numeric, or naming
  a number that is in use each raise the existing jq `error()`, surfacing as exit 3 with no write.
  No new exit-code plumbing.
- The monotonic-advance assertion is replaced, not deleted, by a two-part post-transform guard
  that still prevents the same number being re-issued on the next call:
  - **(i) Recording assertion**: the staged result's in-use set must contain the number just
    issued. A filter that consumes `$NAME` without recording it is refused (exit 3, no write).
    Under a derived allocator, an unrecorded issue is exactly the condition under which the next
    call re-derives the same number, so this is the direct successor to the old assertion's
    purpose rather than a weakening of it.
  - **(ii) Cache regeneration**: after the caller's transform, still inside the mutex and still
    before the atomic replace, `state-write.sh` re-derives `next_project_number` in the staged
    result from the staged in-use set. A landed allocation therefore cannot leave the counter
    naming an in-use number, and every plain `jq -r '.next_project_number'` reader keeps reading a
    correct value.

**Why (b)**: with the counter as authority, "allocating issues the smallest free number above the
active max" holds only after a hand repair of the counter, and lapses again the moment the counter
drifts. With the number derived, the property holds unconditionally and the counter cannot be a
correctness hazard. Derivation also makes the two sites' agreement a single shared expression
rather than two expressions and a comment.

**Rejected alternative, on its own merits**: keep `next_project_number` as the allocation
authority and replace the monotonic-advance assertion with the weaker "the counter is not left
naming an in-use number". This keeps the simplest possible mental model — the field names the
number the next allocation will issue — and needs no regeneration step at all. It is rejected
because it makes every caller compute the next free number itself: a caller's `$NAME + 1` lands on
an in-use number as soon as the dense sequence reaches an isolated outlier, so the membership
derivation would have to be duplicated in each caller, reintroducing precisely the drift that one
shared definition exists to remove.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A `source` line added to `state-write.sh` breaks the five suites that copy it into a temp root with a hard-coded lib allow-list | H | H | Phase 2 carries the allow-list sweep as a named sub-step with its own `grep` command; each suite fails loudly ("expected lib/... alongside this script"), never silently |
| Editing one bound site and not the other reintroduces the exact desync both header comments warn about | H | M | Phase 2 is a declared `atomic-batch` covering both sites in one commit; the shared lib removes the duplicated expression entirely; Fixture (g) stays as the live layer-agreement guard |
| A fixture fix that only updates message text leaves Case 12 / Fixture (c) / Fixture (g) asserting the wrong exit code | H | M | Phase 4 enumerates each inverting fixture with its in-use set and active max so the correct outcome is derived independently, not copied |
| `deploy-headless.sh` refuses or its gate fails while the two suites still assert the old behaviour | M | M | Contingency: swap Phases 3 and 4, realigning the suites against the source-store copies first and accepting Fixture (g) as a declared expected-red until the deploy lands |
| The derived allocator re-issues a number because a caller recorded the issue somewhere the in-use set does not read | H | L | Recording assertion (i) is defined against the same `pnum_inuse_set` the allocation reads, so "recorded" and "in use" are one predicate by construction |
| Cross-array duplicate `project_number` values in the real archive (24 reported by Check A6) break the in-use computation | M | M | The in-use collection is a jq object keyed by number: duplicate keys collapse silently, so duplicates are tolerated by construction with no error path |
| A hand edit lands under `.claude/**` and is wiped by the next deploy | M | L | Every edit path in every phase is a source-store path; Phase 3 is the only phase that touches `.claude/**`, and only via `deploy-headless.sh` |
| 751 turns out to edit `validate-state.sh` after all, with no edge to serialize it | M | L | Human coordination obligation per the task description: re-read the other's landed diff before implementing the later of the two |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel. This plan is a strict chain: each phase
changes the input the next one verifies against.

Source store resolution, used by every phase below:

```
SD=$(jq -r '.extensions.core.source_dir' .claude-extensions.json)
# -> /home/benjamin/.config/nvim/agent-system/extensions/core
```

`source_dir` is per-extension; a top-level `jq -r '.source_dir'` returns `null`, which must not be
read as the key being absent.

---

### Phase 1: Shared in-use definition library [COMPLETED]

**Goal**: One place defines "in use", the active max, the next free number, and a number's
location, so neither consumer computes a bound of its own.

**Tasks**:

- [x] Create `$SD/scripts/lib/project-number-inuse.sh`, following `lib/common.sh`'s stated
      contract: sets no shell options, never calls `exit`, leaks no state, signals a miss by an
      inert default rather than a non-zero status. *(completed: also discovered and fixed a
      heredoc-read exit-status hazard -- see deviation entry in phase 1's progress file)*
- [x] Export the shared jq source as readonly bash strings. The definitions take the live state
      document as input and the archive document as `$pnum_archive_doc`:
      - `pnum_active_numbers` — `[.active_projects[]?.project_number] | map(select(type == "number"))`
      - `pnum_archive_numbers` — the union of `archived_projects`, `abandoned_projects` and
        `completed_projects` numbers from `$pnum_archive_doc`
      - `pnum_inuse_set` — an object keyed by the number's string form, valued by the array name
        it was found in. An object collapses duplicate keys silently, which is what makes the
        collection a SET that tolerates the archive's cross-array duplicates without erroring.
      - `pnum_active_max` — `pnum_active_numbers | max // 0`
      - `pnum_next_free` — the smallest integer strictly greater than `pnum_active_max` whose
        string form is absent from `pnum_inuse_set`
      - `pnum_location($n)` — the array name holding `$n`, or `null`
      *(completed: all six verified directly against hand-built fixtures, including the trap
      case)*
- [x] Write the library's header comment to state, in its own words: that it is the single
      definition both `scripts/state-write.sh`'s `--allocate-into` bound and
      `scripts/validate-state.sh`'s `Check 12` consume; that `specs/vault/**` is deliberately
      outside the in-use set because vault operations recycle that number space; and that the set
      is keyed by number so duplicate rows across archive arrays are tolerated rather than
      refused. *(completed)*
- [x] Add `lib/project-number-inuse.sh` to `$SD/manifest.json`'s `provides.scripts` array, in the
      same `lib/`-prefixed form the existing entries use. *(completed)*
- [x] Do NOT wire either consumer in this phase. The library lands unreferenced and inert.
      *(completed: confirmed by scope -- only manifest.json and the new file changed)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Tier Justification**: `run-all.sh --only test-manifest-scripts-sync.sh` is the specific check
that covers a new entry in `provides.scripts`, and `bash -n` plus shellcheck cover the new file;
nothing consumes the library yet, so no cross-script surface is in play.

**Scope Hypothesis**: exactly one manifest entry and one new file are required, with no existing
file edited. Confirm by `git status --short` under the source store showing one new file plus
`manifest.json` and nothing else.

**Files to modify**:

- `$SD/scripts/lib/project-number-inuse.sh` — new file, shared jq definitions
- `$SD/manifest.json` — one new `provides.scripts` entry

**Verification**:

- `bash -n $SD/scripts/lib/project-number-inuse.sh` exits 0
- Sourcing the library in a subshell under `set -euo pipefail` leaves the shell's options and
  environment unchanged
- A direct jq probe of each definition against a hand-built fixture returns the expected values,
  including the trap case: against a fixture whose in-use set omits `1` and `2` but whose active
  max is `5`, `pnum_next_free` returns `6`, never `1`
- `bash .claude/scripts/tests/run-all.sh --only test-manifest-scripts-sync.sh` exits 0

---

### Phase 2: Rewire both bound sites onto the shared definition [NOT STARTED]

**Goal**: `Check 12` and the `--allocate-into` bound both become membership-based, both consume
the shared library, and the counter-advance assertion is replaced per the Design Decision above —
all in one commit, because changing one site alone is the desync both files' comments exist to
prevent.

**Tasks**:

- [ ] In `$SD/scripts/state-write.sh`: source `lib/project-number-inuse.sh` beside the existing
      `lib/common.sh` source.
- [ ] Rewrite the `alloc_prefix` construction so it binds the derived number: keep the archive
      slurp and the absent/non-numeric counter checks verbatim, replace the
      `$__alloc_ctr > $__alloc_combined_max` comparison with a membership test on the counter, and
      bind `$NAME` to `pnum_next_free` rather than to the counter. Drop the now-unused
      `$__alloc_archive_max` / `$__alloc_combined_max` bindings.
- [ ] Reword the allocation prefix's refusal message to a membership framing that names the number
      and where it is in use, and whose repair hint names the derived next free value.
- [ ] Replace the counter-advance assertion on BOTH the main path and the `--dry-run` preview path
      with the recording assertion from the Design Decision, and add the in-mutex cache
      regeneration step after the caller's transform and before the atomic replace. Keep the
      `[dry-run]` message prefix convention on the preview path.
- [ ] Update `state-write.sh`'s `--allocate-into` header comment block to describe the membership
      bound, the derived number, the regenerated cache, the replaced assertion, and the retained
      `specs/vault/**` exclusion — and to name `Check 12` and the shared library as what it now
      agrees with.
- [ ] In `$SD/scripts/validate-state.sh`: resolve and source the shared library using the same
      multi-candidate pattern the file already uses for `status-vocabulary.sh` and
      `file-scope-overlap.sh`.
- [ ] Rewrite `Check 12` to a single jq invocation over the live file with the archive supplied as
      a slurped argument (or an empty object when no sibling archive exists), FAILing when the
      counter is absent, non-numeric, or in use, and PASSing otherwise. Its FAIL text names the
      number, the array it is in use in, and the derived next free value as the repair target; its
      PASS text states that the counter names a free number.
- [ ] Update `Check 12`'s own header comment, the checks-inventory entry near the top of the file
      that summarises it, and the stale "exactly two jq invocations" cost note.
- [ ] Extend the lib allow-list and the pre-flight existence loop in every suite that copies
      `state-write.sh` into a temp root. Sweep for the set rather than trusting this list:
      `grep -rln 'cp .*state-write\.sh' "$SD/scripts/"`.

**Timing**: 1.75 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: the edit footprint is two production scripts plus five suites' lib
allow-lists. Confirm the suite count at implement time with
`grep -rln 'cp .*state-write\.sh' "$SD/scripts/"` and treat its output, not this list, as
authoritative.

**Tier Justification**: the two scripts' command-line surfaces are probed directly against a
throwaway temp root (an allocation issues the dense number; an in-use counter refuses exit 3 with
the target byte-identical; `Check 12` PASSes on a dense-counter fixture), which covers the bound
change end to end; the suites that would otherwise cover it still assert the max-based outcomes
and are realigned in Phase 4.

**Files to modify**:

- `$SD/scripts/state-write.sh` — lib source, allocation prefix, both assertion paths, cache
  regeneration, `--allocate-into` header comment
- `$SD/scripts/validate-state.sh` — lib resolution and source, `Check 12` body and messages,
  `Check 12` header comment, checks-inventory entry
- `$SD/scripts/test-state-write-concurrency.sh`,
  `$SD/scripts/test-state-write-large-payload.sh`,
  `$SD/scripts/test-state-write-regen-timing.sh`,
  `$SD/scripts/test-state-write-spill-names.sh`,
  `$SD/scripts/tests/test-orchestrate-cycle-plan.sh` — lib allow-list and existence loop only

**Verification**:

- `bash -n` and shellcheck clean on both edited production scripts
- Against a throwaway temp root fixture (active `[1, 2]`, archive holding `50` and `100`, counter
  `3`): the allocator exits 0 and issues `3`; a second allocation issues `4`; the staged counter
  is a free number afterwards
- Against a fixture whose archive holds an isolated outlier immediately above the active max: the
  allocator skips it and issues the next free number
- Against a fixture whose counter equals an active `project_number`: exit 3, the target
  byte-identical, and the message naming both the number and the array it is in use in
- Against a fixture whose filter consumes `$NAME` without recording it: exit 3 on both the main
  and `--dry-run` paths, target byte-identical
- `validate-state.sh` against a dense-counter fixture: exit 0 with a `Check 12` PASS line
- Declared expected-red at this phase's close: `test-validate-state.sh` and
  `test-state-write-concurrency.sh` still assert the max-based outcomes and text. They are not
  this phase's gate and are turned green in Phase 4.

---

### Phase 3: Deploy the corrected bound to the derived tree [NOT STARTED]

**Goal**: `.claude/**` carries the corrected scripts and the new library, by deploy rather than by
hand, so Phase 4's layer-agreement fixture exercises a current deployed allocator.

**Tasks**:

- [ ] Run `bash .claude/scripts/deploy-headless.sh` from the repository root.
- [ ] Confirm `.claude/scripts/lib/project-number-inuse.sh` exists in the deployed tree and that
      both deployed scripts carry the membership bound.
- [ ] Confirm no file under `.claude/**` differs from its source-store counterpart in a way that
      implies a hand edit.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: interface

**Scope Hypothesis**: three files propagate in this deploy (the new library and the two production
scripts), plus whatever unrelated source-store drift the deploy carries. Confirm by listing the
deploy's own reported changed-file set rather than assuming the count.

**Tier Justification**: `verify-deploy.sh`'s script-propagation gate is the specific check that
covers whether a manifest-listed script reached the derived tree; no logic changes in this phase,
so nothing below that surface is at risk.

**Files to modify**:

- `.claude/scripts/**` — by `deploy-headless.sh` only, never by hand

**Verification**:

- `deploy-headless.sh` exits 0
- `bash .claude/scripts/verify-deploy.sh` exits 0, or its findings are each accounted for as
  pre-existing and unrelated
- `diff` of each of the three affected files between source store and deployed tree reports no
  difference

---

### Phase 4: Realign and extend both test suites [NOT STARTED]

**Goal**: Every fixture asserts the membership bound, the four inverting fixtures assert their
corrected outcome rather than corrected text, and the trap case the task description warns about
is covered by a test of its own.

**Tasks**:

- [ ] `test-state-write-concurrency.sh` Case 11 (counter `2`, active `[1, 2]`): outcome is
      unchanged (exit 3, target byte-identical) because `2` is in use; update the asserted message
      substring to the membership text, which must name `2` and `active_projects`.
- [ ] `test-state-write-concurrency.sh` Case 12 (counter `3`, active max `2`, archive holding `50`
      and `100`): invert the expectation. `3` is absent from the in-use set and above the active
      max, so the allocation is valid — assert exit 0, the issued number `3`, and a free staged
      counter. Reframe the case's comment from "archive-aware refusal" to "an archive-held number
      above the issue point does not block an allocation".
- [ ] `test-state-write-concurrency.sh` Case 13: re-point at the replacement guard. A filter that
      consumes `$NAME` and does NOT record it must still be refused on both the main and
      `--dry-run` paths; update the asserted message to the recording assertion's text.
- [ ] `test-state-write-concurrency.sh`: add a new case for the trap — a fixture whose in-use set
      has low gaps (active `[3, 6]` with the counter free) must issue `7`, never `1`, `2`, `4` or
      `5`; and a fixture whose archive holds the number immediately above the active max must skip
      it and issue the one after.
- [ ] `test-state-write-concurrency.sh` Case 10: re-derive, do not assume. Two concurrent
      allocations from active `[1, 2]` issue `3` and `4`, leaving a staged counter of `5` — the
      same final value the case already asserts, so it should pass unchanged. Confirm rather than
      edit.
- [ ] `test-validate-state.sh` Fixture (b) (counter `781` equal to an active `project_number`):
      outcome unchanged (FAIL); update the asserted text to the membership framing and the repair
      value to the derived next free number.
- [ ] `test-validate-state.sh` Fixture (c) (counter `10`, active max `5`, archive holding `7` and
      `50`): invert to a PASS asserting the `Check 12` PASS line, since `10` is absent from
      `{5, 7, 50}` and above the active max. Rewrite the fixture comment to describe what it now
      proves: an archive-held number above the counter does not make the counter stale.
- [ ] `test-validate-state.sh` Fixture (d): re-derive. Counter `51` against the same archive is
      still a PASS, so it should pass unchanged — but it no longer proves what its comment claims
      (that (c) was the bound). Update its comment to the property it still proves.
- [ ] `test-validate-state.sh` Fixture (g): keep it as the layer-agreement guard and invert it.
      Running Fixture (c)'s shape through the deployed allocator must now succeed; assert exit 0
      and the issued number, and keep the comment's statement that the fixture exists to prove the
      two sites agree — now on an allocation outcome rather than a refusal.
- [ ] `test-validate-state.sh`: add a fixture for the trap at the validator layer — a state whose
      low numbers are free but whose counter sits just above a high active max must PASS, with the
      reported next free value being the dense one rather than the lowest free number overall.
- [ ] Re-confirm Fixtures (a) and (e) pass unchanged (counter above the active max with no
      archive; non-numeric counter).

**Timing**: 1.5 hours

**Depends on**: 3

**Verification Tier**: interface

**Scope Hypothesis**: four fixtures invert their outcome (Case 12; Fixtures (c), (g); plus Case 13
re-pointed at the replacement guard), three keep their outcome with new text (Case 11, Fixture
(b), Fixture (d)'s comment), and two new cases are added. Confirm each inversion by computing the
fixture's own in-use set and active max from its literal fixture JSON before editing the
assertion, not from this list.

**Tier Justification**: `run-all.sh --only` over the suites that copy or exercise the two edited
scripts — `test-validate-state.sh`, `test-state-write-concurrency.sh`,
`test-state-write-large-payload.sh`, `test-state-write-regen-timing.sh`,
`test-state-write-spill-names.sh`, `test-orchestrate-cycle-plan.sh`,
`test-manifest-scripts-sync.sh` — is the specific set that covers this change's blast radius; no
other suite reads the bound.

**Files to modify**:

- `$SD/scripts/test-state-write-concurrency.sh` — Cases 11, 12, 13 and one new case
- `$SD/scripts/tests/test-validate-state.sh` — Fixtures (b), (c), (d), (g) and one new fixture

**Verification**:

- `bash $SD/scripts/test-state-write-concurrency.sh` exits 0 with every case passing
- `bash $SD/scripts/tests/test-validate-state.sh` exits 0 with every fixture passing, Fixture (g)
  exercising the deployed allocator rather than info-SKIPping
- `bash .claude/scripts/tests/run-all.sh --only test-validate-state.sh,test-state-write-concurrency.sh,test-state-write-large-payload.sh,test-state-write-regen-timing.sh,test-state-write-spill-names.sh,test-orchestrate-cycle-plan.sh,test-manifest-scripts-sync.sh`
  exits 0
- The two suites are re-deployed and re-run against the deployed copies, so the source-store and
  deployed layers are both proven

---

### Phase 5: Live-state verification, counter repair, and the full gate [NOT STARTED]

**Goal**: The acceptance criteria are demonstrated against this repository's real state, the
counter is repaired to the dense value, the schema reference describes what the field now means,
and the complete gate set passes.

**Tasks**:

- [ ] Record the before-state: `bash .claude/scripts/validate-state.sh` and its exit code,
      `--archive` and its exit code, `--deep` and its exit code, and the live counter, active max,
      and derived next free value.
- [ ] Repair the counter to the derived dense value with a `state-write.sh` write under the mutex.
      Do not hand-edit `specs/state.json`.
- [ ] Demonstrate acceptance criterion 1 against live state without mutating it: a `--dry-run`
      allocation issues the dense number and a second preview issues the one after. Demonstrate
      criterion 2 the same way against a counter set to an in-use number in a copy of live state.
- [ ] Record the after-state: all three `validate-state.sh` exit codes again, with `Check 12`
      PASSing.
- [ ] Update `$SD/context/reference/state-management-schema.md`'s `next_project_number` field
      description to state that it is a regenerated cache of the next free number rather than an
      authority, and that the allocator derives the issued number from the in-use set. Keep the
      prose free of task numbers and of any narration of what the field used to be.
- [ ] Re-deploy so the context change reaches `.claude/**`.
- [ ] Confirm the archive is untouched: `git diff --stat` reports no change under
      `specs/archive/**`.

**Timing**: 1.25 hours

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: one state write (the counter) and one context file edit. Confirm by
`git status --short` showing `specs/state.json`, `specs/TODO.md` (regenerated), the schema
reference under the source store, and the deployed mirror — and nothing under `specs/archive/**`.

**Files to modify**:

- `specs/state.json` — the counter only, via `state-write.sh`
- `$SD/context/reference/state-management-schema.md` — the `next_project_number` field description
- `.claude/**` — by deploy only

**Verification**:

- `bash .claude/scripts/validate-state.sh` exits 0 both before and after, with both exit codes
  reported, and `Check 12` PASSes after the repair
- `bash .claude/scripts/validate-state.sh --archive` exits 0 before and after, both codes reported
- `bash .claude/scripts/validate-state.sh --deep` exits 0 before and after, both codes reported
- `bash .claude/scripts/tests/run-all.sh` exits 0 (full suite sweep)
- `bash .claude/scripts/verify-deploy.sh` exits 0
- `bash .claude/scripts/check-task-references.sh` and the record-versioning lint report no new
  findings in any edited file outside `specs/**`
- `git diff --stat specs/archive/` is empty

---

## Testing & Validation

- [ ] The allocator issues the smallest free number strictly above the active max, and a second
      allocation issues the next one after that
- [ ] An isolated in-use number immediately above the issue point is skipped, not blocked on
- [ ] A low free number is never issued while a higher active max exists
- [ ] An allocation whose counter names an in-use number is refused with exit 3, no write, and a
      message naming the number and its array
- [ ] A filter that consumes the allocated number without recording it is refused on both the main
      and `--dry-run` paths
- [ ] `Check 12` and the `--allocate-into` bound both consume the shared definition, and Fixture
      (g) proves they agree on a live allocation outcome
- [ ] `specs/vault/**` is still absent from the in-use computation
- [ ] Cross-array duplicate `project_number` values do not error the in-use computation
- [ ] `validate-state.sh` base, `--archive`, and `--deep` all exit 0 before and after
- [ ] The full `run-all.sh` sweep exits 0
- [ ] No archived row is renumbered, moved, or deleted

## Artifacts & Outputs

- `$SD/scripts/lib/project-number-inuse.sh` (new shared definition)
- `$SD/manifest.json` (one `provides.scripts` entry)
- `$SD/scripts/state-write.sh` (membership bound, derived number, replaced assertion, regenerated
  cache, updated header comment)
- `$SD/scripts/validate-state.sh` (membership `Check 12`, updated header comment and inventory
  entry)
- Five suites' lib allow-lists extended
- `$SD/scripts/test-state-write-concurrency.sh` and `$SD/scripts/tests/test-validate-state.sh`
  realigned and extended
- `$SD/context/reference/state-management-schema.md` (`next_project_number` field description)
- `specs/state.json` counter repaired to the dense value
- `.claude/**` refreshed by deploy
- A completion summary under `specs/846_membership_based_task_number_allocation/summaries/`

## Rollback/Contingency

- Every phase before Phase 5 is confined to the source store and the derived tree. Reverting is
  `git checkout` of the source-store commits followed by a re-deploy; no live task state is
  touched.
- Phase 5's only live mutation is the counter. Its prior value is recorded in the before-state
  capture at the top of the phase and can be restored with a single `state-write.sh` write.
- If `deploy-headless.sh` refuses in Phase 3, swap Phases 3 and 4: realign the suites against the
  source-store copies first, accept Fixture (g) as a declared expected-red until the deploy lands,
  then deploy and re-run it.
- If the recording assertion proves too strict for a legitimate caller shape discovered during
  implementation, the fallback is the rejected option recorded in the Design Decision above — the
  counter stays the authority with the weaker "not left naming an in-use number" assertion — and
  the deliverable's recorded decision must be rewritten to match what actually landed, with the
  then-rejected option stated on its own merits.
- Before any intentional rollback that would otherwise be blocked by the destructive-git guard,
  take a checkpoint with `bash .claude/scripts/git-snapshot.sh 846` first.
