# Research Report: Task #846

**Task**: 846 - membership_based_task_number_allocation
**Started**: 2026-11-03T00:00:00Z
**Completed**: 2026-11-03T00:00:00Z
**Effort**: low-medium
**Dependencies**: None (task 821, status researched, is the owning record this implements remedy
  (i) of; no dependency edge required since 821 is research-only and holds no artifacts to race)
**Sources/Inputs**: - Codebase (source store `agent-system/extensions/core/scripts/state-write.sh`,
  `validate-state.sh`, `scripts/tests/test-validate-state.sh`,
  `scripts/test-state-write-concurrency.sh`), live `specs/state.json` / `specs/archive/state.json`
  measurements, task 821's amended description
**Artifacts**: - this report
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Live measurement confirms every numeric claim in the dispatch: active max 846 (this task),
  archive max 1054 carried by exactly five rows (949, 953, 992, 998, 1054), 844-1054 otherwise
  empty, in-use set size 818, counter currently 1055. "Smallest unused number counting from 1"
  would issue 1, 2, 4, 5, 7, ... (confirmed) — the trap the dispatch warns against. "Smallest
  unused number strictly greater than active max" issues 847, 848, 849, ... (confirmed) — the
  correct spec.
- Two sites must change together: `state-write.sh`'s `--allocate-into` allocation prefix (a jq
  filter fragment built as a bash string around line 428-444) and `validate-state.sh`'s Check 12
  (around line 1128-1187). Each file's own header comment already names the other as the sibling
  that must stay in sync.
- A third, undocumented-by-the-dispatch site exists and must also be updated:
  `scripts/test-state-write-concurrency.sh` (sibling to `state-write.sh`, not under `scripts/tests/`)
  contains Cases 10-14, a dedicated `--allocate-into` test suite the dispatch's "no dedicated test
  file" note does not cover because it is not named `test-state-write.sh`. Case 11's fixture
  (counter literally equal to an in-use active number) should still refuse under the new bound, but
  its assertion text embeds the current max-based message and will fail unless updated. Case 12's
  fixture (counter 3, active max 2, archive holds 50 and 100) currently expects a refusal that the
  new membership-based bound would NOT produce — 3 is not in the in-use set {2, 50, 100} and is
  greater than the active max 2, so under the corrected spec this allocation is valid. This is the
  single highest-value concrete finding of this research pass: a naive edit of only the two sites
  the dispatch names would leave Case 12 red.
- `scripts/tests/test-validate-state.sh`'s Fixture (c)/(d)/(g) have the identical property: (c)'s
  shape (active max 5, counter 10, archive holds 7 and 50) is a membership-bound PASS, not the
  current FAIL, because 10 is not in {5, 7, 50}. Fixture (g) replays (c)'s shape through the
  deployed `state-write.sh --allocate-into` specifically to assert layer agreement with Check 12 —
  it will need the same corrected expectation, and continuing to assert layer agreement (rather
  than dropping the fixture) is how the two-site sync requirement stays test-enforced going
  forward.
- The counter-advance-assertion wrinkle the dispatch flags is real and independently confirmed by
  reading the mutex-scoped code (lines 595-601, 632-645): the assertion compares
  `ALLOC_POST_COUNTER` to `ALLOC_PRE_COUNTER` with a strict `-le` refusal, with no awareness of the
  bound's shape. Under the dense-sequence spec this assertion fires as a false refusal whenever
  the counter must move down to close a gap (e.g. from 1055 to 847). This is a `bash`-level
  comparison independent of the jq allocation prefix, so it is a true third edit site beyond the
  two the dispatch's header comments cross-reference — not a new site in the sense of needing a
  new sync comment, since it lives inside the same file as one of the two, but a third code
  location within that file that a change restricted to the `alloc_prefix` string alone would miss.

## Context & Scope

Researched: the exact code shape of the max-based bound in both sites named by the dispatch, live
verification of every repository-state number the dispatch's defect narrative depends on, and a
sweep for any OTHER site in the source store that asserts max-based allocation behavior and would
silently diverge from a two-site-only edit. Out of scope (per dispatch and per task 821's
guardrail, both already settled): relocating the five archive outliers to `specs/vault/`,
touching any archived row, and the allocator's own concurrency/mutex design (unaffected by this
change — the bound's membership test and the mutex are orthogonal).

## Findings

### Codebase Patterns

**Site 1 — `state-write.sh`'s `--allocate-into` allocation prefix** (source store path
`agent-system/extensions/core/scripts/state-write.sh`, resolved via
`jq -r '.extensions.core.source_dir' .claude-extensions.json` ->
`/home/benjamin/.config/nvim/agent-system/extensions/core`):

- The prefix is a bash string (`alloc_prefix`, built across several `+=`-style assignments
  starting at line 438) that becomes a jq `as`-binding chain prepended to the caller's own filter.
  It binds, in order: `$__alloc_archive_doc` (the sibling archive file, `[]` if absent),
  `$__alloc_archive_max` (max across `archived_projects`/`abandoned_projects`/`completed_projects`
  project_numbers), `$__alloc_active_max` (max across `.active_projects[].project_number`),
  `$__alloc_combined_max` (the greater of the two), then the counter read/type checks, then the
  single `error()`-raising comparison: `$__alloc_ctr > $__alloc_combined_max`.
- This whole computation happens inside the jq filter itself (not in bash), so the archive file is
  read via `--slurpfile` set up at lines 404-411, itself commented as resolved "inside the mutex"
  for the non-dry-run path.
- The header comment for the flag (lines 49-65) explicitly states the bound is "the identical
  combined max `scripts/validate-state.sh`'s Check 12 computes; the two must stay in sync" and
  that `specs/vault/**` is "deliberately excluded... see the allocation prefix's own comment,
  below, for the recycling rationale" — confirming both MUST-PRESERVE items from the dispatch are
  already load-bearing documented invariants, not incidental behavior.

**Site 2 — `validate-state.sh`'s Check 12** (same source store, lines ~1128-1197):

- Computes the identical archive-aware combined max independently in native jq (two separate
  invocations piped through `IFS=$'\t' read`), not shared code with `state-write.sh` — the sync
  obligation is between two independently-written computations, not a shared library call, which
  is exactly why the dispatch frames it as a correctness risk rather than a mechanical no-op.
  Confirmed no shared helper exists: `grep -rl "combined_max"` across the source store returns
  only `state-write.sh` and `validate-state.sh` themselves (plus their respective test files).
- Check 12's header (lines 182-189) names the test-enforcement mechanism directly:
  "`scripts/tests/test-validate-state.sh` fixture (g) asserts the two agree" — this is the
  mechanical backstop for the sync obligation and is the one most likely to need editing alongside
  the two production files.
- Immediately below Check 12 sits the project_number uniqueness check (promoted from the old
  `--deep`-only Check D1 into base mode in a prior change) — unrelated to this task's bound
  but confirms the base-mode check ordering the acceptance criteria rely on ("Check 12 and the
  `--allocate-into` bound agree... both cross-referencing header comments are updated").

**Site 3 (not named by the dispatch) — `scripts/test-state-write-concurrency.sh`**:

- Lives directly under `agent-system/extensions/core/scripts/` (a sibling of `state-write.sh`,
  NOT under `scripts/tests/`), which is why the dispatch's "there is no
  `scripts/tests/test-state-write.sh`" statement is literally true while still missing this file —
  it is in scope under the dispatch's broader "file scope... measured rather than assumed" framing
  even though it was not individually named.
- Its header (line 7) states "Cases 10-14 prove the `--allocate-into NAME` allocation primitive."
  Measured fixture values:
  - `reset_state_json` (the suite's shared fixture helper, lines 84-91) sets
    `next_project_number: 3`, `active_projects` = `[{1,...}, {2,...}]` (active max 2).
  - Case 11 sets the counter to 2 (equal to an already-active number) and asserts exit 3 plus the
    literal substring `"next_project_number (2) is not strictly greater than the in-use max (2"`.
    Under the corrected spec this case should STILL refuse (2 is in the in-use set), but the
    assertion's exact message substring is max-based phrasing that the corrected implementation
    will not produce verbatim unless the message text is deliberately kept compatible.
  - Case 12 adds a sibling archive with `archived_projects` max 50 and `completed_projects` max
    100, leaves the counter at 3 (active max 2), and asserts exit 3 plus
    `"next_project_number (3) is not strictly greater than the in-use max (100: active max 2, archive max 100)"`.
    Under the corrected membership spec, 3 is NOT in the in-use set `{1, 2, 50, 100}` and IS
    greater than the active max (2), so this allocation is valid and should exit 0 — the fixture's
    expected outcome inverts.
  - Case 13 tests the counter-advance assertion itself (a filter that reads `$new_num` without
    advancing `next_project_number`) and is independent of the bound's shape — should be unaffected.
  - Case 14 tests usage refusals (`--init` combination, invalid NAME, reserved namespace, NAME
    collision) — also independent of the bound's shape.

**Mirror findings in `scripts/tests/test-validate-state.sh`** (confirmed by direct read, lines
328-491):

- Fixture (a): counter 6, active max 5, no archive — PASS under both old and new spec (6 is
  unused and above active max). Unaffected.
- Fixture (b): counter 781 collides with an active project_number 781 — FAIL under both specs
  (781 is literally in use). Unaffected in outcome, though the FAIL message's "in-use max" framing
  would need to become a membership framing per acceptance criterion 3.
- Fixture (c): counter 10, active max 5, archive `archived_projects` max 7 and `completed_projects`
  max 50 — currently asserts FAIL naming "in-use max (50: active max 5, archive max 50 from
  completed_projects)". Under the corrected spec, 10 is not in `{5, 7, 50}` and is greater than
  active max 5, so this is a PASS, not a FAIL — the same inversion found in Case 12 above,
  confirming the pattern is systemic across both test files rather than a one-off.
- Fixture (d): counter 51, same archive as (c) — PASS under both specs (51 exceeds everything).
  Unaffected in outcome.
- Fixture (e): non-numeric counter — FAIL under both specs (type check, not bound-shape
  dependent). Unaffected.
- Fixture (g): literally replays fixture (c)'s shape through the DEPLOYED `state-write.sh
  --allocate-into` to assert it refuses "for the same reason validate-state.sh's Check 12 FAILs" —
  this is the live layer-agreement test the sync obligation depends on. It inherits fixture (c)'s
  inversion: after the fix, the deployed allocator should SUCCEED on this shape (issuing 10, since
  10 is unused and above the active max), and the fixture must assert exit 0 and the resulting
  state rather than a refusal — while still existing as a layer-agreement check (now asserting
  agreement on a PASS/allocation outcome instead of a FAIL/refusal one), not being deleted.

**Live repository measurement** (verifies the dispatch's defect narrative against current state,
not the figures as narrated):

| Quantity | Measured value |
|---|---|
| `active_projects[].project_number` max | 846 |
| `active_projects` count | 90 |
| Archive combined max (archived + abandoned + completed) | 1054 |
| Archive rows in 844-1054 | exactly `[949, 953, 992, 998, 1054]` |
| `next_project_number` (current, unrepaired) | 1055 |
| In-use set size (active ∪ archive, vault excluded) | 818 |
| Smallest unused numbers from 1 | `1, 2, 4, 5, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 22, ...` |
| Smallest unused numbers strictly above active max (846) | `847, 848, 849, 850, 851, ...` |
| `specs/vault/` contents | one prior round, `01-vault` |

All figures the dispatch narrated are confirmed by direct `jq` queries against the live
`specs/state.json` and `specs/archive/state.json`, not taken on trust.

### External Resources

Not applicable — this is a pure internal bash/jq fix with no external library or API surface.

## Decisions

- **The two-site cross-reference comments are the authoritative scope boundary, but the actual
  edit footprint is larger than two sites**: the counter-advance assertion in `state-write.sh`
  (bash-level `-le` comparison at line ~638, operating on `ALLOC_PRE_COUNTER`/`ALLOC_POST_COUNTER`
  captured at lines 600 and 638) is a third code location inside Site 1's own file that the
  `alloc_prefix` jq-string edit alone will not reach, and must be revisited together with whichever
  of the dispatch's two design-wrinkle options ((a) counter remains authority with a weakened
  assertion, or (b) counter becomes a derived cache) is chosen.
- **The repair-message text in both Check 12 and the allocation prefix's `error()` calls
  currently reads as max-based narration** ("is not strictly greater than the in-use max...")
  and both need rewording to a membership framing to satisfy acceptance criterion 3 ("both
  cross-referencing header comments are updated to describe the membership bound") — this extends
  past the header *comments* to the runtime *messages* the dispatch's acceptance criterion 2 also
  requires ("the message naming the number and where it is in use").
- **Four existing fixtures invert their expected outcome under the corrected spec**: Case 12 in
  `test-state-write-concurrency.sh`, and Fixtures (c) and (g) in `test-validate-state.sh` (Fixture
  (c)'s inversion propagates into (g), which replays (c)'s shape). These are not currently-passing
  tests that would merely need message-text updates — their PASS/FAIL expectation itself flips,
  making them the highest-risk regression surface for this change and the first fixtures an
  implementer should run after editing either site.
- Recorded for the implementer, not decided here (per the dispatch's own instruction that this is
  an implementation-phase decision): the counter-advance wrinkle's choice between (a) and (b).
  This research found no evidence favoring one over the other from the codebase alone — both are
  mechanically sound under the mutex's existing serialization — so the choice turns on taste
  (regenerable-cache simplicity vs. preserving "the counter" as a stateful value), which is
  exactly the kind of decision the dispatch asks to be recorded rather than researched further.

## Recommendations

1. Edit Site 1 (`state-write.sh`'s `alloc_prefix` construction, lines ~438-444) and Site 2
   (`validate-state.sh`'s Check 12, lines ~1147-1187) together in the same change, replacing the
   `$__alloc_ctr > $__alloc_combined_max` / `_c12_counter <= _c12_combined_max` comparisons with a
   membership test against the union of `active_projects`, `archived_projects`,
   `abandoned_projects`, and `completed_projects` project_numbers (vault excluded, unchanged), still
   guarded by "greater than active max" per the dispatch's corrected spec rather than a bare
   smallest-unused-from-1 scan.
2. Treat the counter-advance assertion (line ~638 of `state-write.sh`) as an explicit third
   sub-step of the Site 1 edit, not an afterthought: whichever of options (a)/(b) is chosen, the
   assertion's current unconditional `-le` refusal needs a replacement condition tied to "the
   counter is not left naming an in-use number" (option (a)'s own phrasing) or removed in favor of
   re-deriving the value on each call (option (b)).
3. Update both message-producing `error()`/`log_fail`/`log_pass` strings (not just header comments)
   in both sites to a membership framing, reusing the durable anchors already available
   (`next_project_number`, the project_number and its location) rather than combined-max language.
4. Before editing, snapshot the four fixtures whose expected outcome inverts (Case 12 in
   `test-state-write-concurrency.sh`; Fixtures (c) and (g) in `test-validate-state.sh`) so the
   implementation phase can diff old-vs-new expectations directly rather than re-deriving them;
   this report's Findings section above already states each one's exact current assertion text and
   why it inverts.
5. After the edit, run both `scripts/test-state-write-concurrency.sh` and
   `scripts/tests/test-validate-state.sh` against the source-store copy first (both suites already
   have source-store-first resolution logic for exactly this reason — see
   `test-validate-state.sh`'s `C12_VALIDATOR` resolution comment at lines 121-131), then deploy and
   re-run Fixture (g) against the deployed copy to confirm the two-site layer agreement the fixture
   exists to enforce.
6. Run `validate-state.sh` (no flags), `--archive`, and `--deep` against the live repository both
   before and after, reporting all three exit codes each time, per acceptance criteria 4 and 5 —
   `--archive` and `--deep` should be byte-for-byte unaffected since neither touches Check 12's
   code path (`--archive` replaces Checks 2-12 and the `--deep` block entirely; `--deep`'s own
   Check D1 was already moved out to base mode in a prior change and does not re-read the bound).

## Risks & Mitigations

- **Risk**: editing only the `alloc_prefix` jq string and Check 12's jq logic while missing the
  bash-level counter-advance assertion reintroduces a silent-refusal bug the moment the counter
  must move down to close a gap (e.g. 1055 -> 847). **Mitigation**: Recommendation 2 above calls
  this out as a mandatory third sub-step, not optional cleanup.
- **Risk**: an implementer trusts the dispatch's "no dedicated test file" note literally and skips
  `scripts/test-state-write-concurrency.sh` entirely, since its name does not match
  `test-state-write.sh`. **Mitigation**: this report names the file, its exact location (sibling
  of `state-write.sh`, not under `scripts/tests/`), and the two cases (11, 12) requiring attention,
  with Case 12's exact current assertion text quoted so it can be grepped for directly.
- **Risk**: a naive fixture fix only updates message-text assertions and misses that Case 12 and
  Fixture (c)/(g) need their PASS/FAIL *outcome* inverted, not just their message string updated —
  a surface-level "find and replace the old message text with the new one" edit would leave these
  three fixtures asserting the wrong exit code. **Mitigation**: Findings section states the exact
  in-use sets and active maxes for each fixture so the correct outcome can be verified
  independently of this report's own claim.
- **Risk**: the vault-trigger note in `state-management-schema.md` ("When `next_project_number` >
  1000, the /todo command initiates vault operation") could be read as blocking this change, since
  the live counter (1055) already exceeds 1000. **Mitigation**: this is an unrelated, independently
  gated `/todo` command behavior, not part of `--allocate-into` or Check 12, and is out of this
  task's scope; noted here only so the implementer does not conflate the two.

## Context Extension Recommendations

- **Topic**: `next_project_number`'s role under a membership-based bound.
- **Gap**: `.claude/context/reference/state-management-schema.md` line 66 currently documents
  `next_project_number` as simply "Next task number to assign," which is accurate under a
  max-based, counter-is-authority model but becomes ambiguous if design-wrinkle option (b)
  (counter as a regenerable cache, re-derived from the in-use set each allocation) is chosen.
- **Recommendation**: once the implementation phase settles the counter-advance wrinkle, the
  schema reference's field description for `next_project_number` should be updated to state
  whichever of (a)/(b) was chosen, so a future reader of the schema (not just the two scripts'
  header comments) understands what the field actually represents.

## Appendix

- Search queries / probes used: `jq -r '.extensions.core.source_dir' .claude-extensions.json`;
  `grep -rln "allocate-into\|combined_max\|_c12_\|__alloc_"` across the source store; direct reads
  of `state-write.sh` lines 1-120, 395-460, 590-650; `validate-state.sh` lines 170-200, 1125-1230;
  `test-validate-state.sh` lines 328-495; `test-state-write-concurrency.sh` Cases 10-14 and
  `reset_state_json`; live `jq` queries against `specs/state.json` and `specs/archive/state.json`
  for active max, archive max, in-use set cardinality, and the two "smallest unused" sequences
  (from 1, and from active-max+1).
- References: task 821 (`state_counter_archive_numbering_reconciliation`, status researched) —
  the owning record, consumed directly via its live `specs/state.json` description (no separate
  artifact file exists for it; its directory is empty and its `artifacts` field is `[]`, confirmed
  by direct listing).
