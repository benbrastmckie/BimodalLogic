# Implementation Plan: Task #691

- **Task**: 691 - Resolve c23 naming exemptions
- **Status**: [IMPLEMENTING]
- **Effort**: 2.25 hours
- **Dependencies**: None (tasks 685 and 693 have both landed; the research report's
  "sequence after 685/693" condition is satisfied)
- **Research Inputs**: specs/691_resolve_c23_naming_exemptions/reports/01_c23-naming-exemptions.md
- **Artifacts**: plans/01_c23-naming-exemptions.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

C23 is the sole red gate group in `scripts/check-module-invariants.sh`, failing on two
sub-assertions: 2 `Uppercase_x` names (`NM_nonneg`) and 11 outer-shadows-inner bare-declaration
pairs. Every one is a deliberate mirrored-API or sub-namespacing decision, so the fix is a
recorded exemption with inline reasoning — never a rename. This plan makes one substantive design
choice (exempt the **exact measured pairs** via a new `(base, outer_ns, inner_ns)` triple key
rather than blessing four bare names forever), then adds that mechanism, the 11 triples, the
`NM_nonneg` `UPPER_ALLOW` entry, and the comment restructuring the new exemption class requires.
No Lean source file is edited; the entire change lives in one script.

### Research Integration

Findings carried directly into the phases below:

- **Finding 1** — the scanner's `shadow[:10]` print cap hides the eleventh pair while reporting a
  count of 11. Phase 1 lifts that cap first, so the inventory is measured whole rather than
  inferred (this is also the origin of the task description's `mem_verts x3+`; the true
  `mem_verts` count is 4).
- **Finding 3** — the three exemption mechanisms are keyed differently. `UPPER_ALLOW` and
  `SHADOW_ALLOW` key on the **bare name**, so an entry disables that whole name bucket tree-wide
  and forever; only `FROZEN_PREFIX` is path-scoped. This is the one unrecorded design decision,
  resolved under **Decisions** below.
- **Finding 4** — `isValid` ("structure-member namesakes on distinct types: legitimate
  dot-notation") and `insertEnv` ("recorded as follow-up rather than done blind") are citable
  precedents, so no new justification vocabulary is needed.
- **Finding 5** — the `Uppercase_x` auto-exemption path is measurably closed for `NM_nonneg`:
  `NM` **is** a live declaration (so the "prefix names nothing live" class misses), `nonneg` is
  **not** a live base (so the name-capture auto-exemption does not fire), and `NM_` does not match
  `TENSE_PREFIX`. An explicit `UPPER_ALLOW` entry is the only route — and the existing
  `UPPER_ALLOW` comment describes a class this entry does not belong to, so Phase 3 must extend
  the comment or leave the file self-contradicting.
- **Finding 7** — line numbers in the report's table are volatile; the inventory must be
  re-measured at implementation time, and no exemption may be keyed on a line number.
- **Round 2 / Risks** — `scripts/typst-sync-check.sh` is red in the working tree on a stale
  count in `typst/generated/status.typ`. That is out of scope and must not be "fixed" here, nor
  mistaken for C23 fallout.

Independently re-confirmed while writing this plan (`bash scripts/check-module-invariants.sh
--no-build` at current HEAD): exactly two failing C23 sub-assertions, 2 `Uppercase_x` names and
11 shadow pairs, at exactly the namespaces and sites the report's table records, with no other
`FAIL` line anywhere in the scanner's output.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No roadmap path was supplied with this dispatch; no ROADMAP.md consultation performed.

## Goals & Non-Goals

**Goals**:
- All three C23 sub-assertions print `PASS`, with `scripts/check-module-invariants.sh` reporting
  zero failures overall.
- Every exemption added carries its reason **inline, beside the entry it exempts**, per the
  `ENFORCE_C23` guard comment's standing instruction ("Never flip it to 0; add a reasoned entry to
  the in-scanner exception set instead, where the reason is read alongside the name it exempts").
- The exemptions are **narrow**: a genuinely new, accidental collision on any of the same four
  base names is still reported after this change.
- `ENFORCE_C23` remains `1`.

**Non-Goals**:
- Renaming `NM_nonneg`, `decidableValidZTime`, `cohWindowLo`, `cohWindowHi`, or `mem_verts`, or
  editing any `.lean` file. The rename route is settled as inapplicable (structure fields cannot
  contain dots; `S.NM.nonneg` would resolve `nonneg` against `Int`; `decidableValidZTime`'s
  shadowing *is* the deliberate sub-namespacing that avoids a real environment clash).
- Removing or narrowing the existing `FROZEN_PREFIX` exemption (`Verified/Termination/`). Its
  comment says to delete it once that separate workstream lands; that is not this task's call.
- Repairing `scripts/typst-sync-check.sh` / `typst/generated/status.typ`.
- Introducing a live `nonneg` declaration to make the name-capture auto-exemption fire. Finding 5
  names this explicitly as a non-fix that must not be mistaken for a resolution.

## Decisions

**Exemption key: exact measured pairs, not bare names.** Finding 3 offers three options. This plan
chooses option 3 — extend the shadow scan with a `(base, outer_ns, inner_ns)` triple-keyed
exemption set — for three reasons:

1. A bare-name `SHADOW_ALLOW` entry for `mem_verts` does not record the four measured pairs; it
   **permanently disables the `mem_verts` bucket**, so a future accidental collision on that name
   is never reported. Same for `cohWindowLo`, `cohWindowHi`, `decidableValidZTime`. The triple key
   is the only option that exempts what was measured without absorbing a future regression.
2. It is keyed on namespaces, not line numbers, so it does not rot as the Decidability tree moves
   (Finding 7).
3. `FROZEN_PREFIX` is a poor fit: its recorded intent is *removable and in-flight*, which
   misdescribes a permanent mirrored-API decision.

Cost accepted: ~15 lines of new scanner capability plus 11 entries instead of 4. This is a
reversible, script-local choice requiring no user judgment — recorded here rather than escalated.

**Comment-hygiene constraint (easy to violate).** `scripts/check-module-invariants.sh` is outside
`specs/**`, so under `.claude/rules/no-task-references-in-deliverables.md` the inline reasons MUST
NOT cite task numbers ("task 691", "task 685", "tasks 685/693"). Cite durable anchors instead:
declaration names, namespace paths, file paths, and the existing `isValid` / `insertEnv` entries.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Exemption written too wide, silently absorbing a future collision | H | M | Triple key (Decisions); Phase 2 verifies narrowness with a synthetic fourth-namespace pair that must still be reported |
| Eleventh pair dropped again because the print cap hides it | M | M | Phase 1 lifts the cap *before* any exemption is written, and cross-checks printed rows against the reported count |
| Inline reason cites a task number, tripping the deliverables lint | M | M | Constraint stated in Decisions; Phase 4 runs `check-task-references.sh` explicitly |
| Line-number drift invalidates the entries | M | L | Nothing is keyed on line numbers; namespaces only |
| `typst-sync-check.sh` red state misread as C23 fallout or dragged into scope | L | M | Named a Non-Goal; Phase 4 compares against the Phase 1 baseline rather than expecting an all-green repo |
| Over-staging the commit (working tree carries unrelated modified files) | M | M | Phase 4 stages an explicit file list only — never `git add -A`, `.`, or a directory pathspec |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. Phases 2 and 3 edit adjacent regions of the
same file and are deliberately serialized rather than parallelized.

### Phase 1: Lift the output cap and re-measure the C23 inventory [COMPLETED]

**Goal**: Make the scanner print every shadow pair it counts, then capture a complete, current
baseline of the C23 red state (and of every other gate group's status) before any exemption is
written.

**Tasks**:
- [x] Read the C23 block of `scripts/check-module-invariants.sh` (the `# --- C23 additions:`
      section through `C23_STATUS=$?`), locating `UPPER`, `TENSE_PREFIX`, `UPPER_ALLOW`,
      `SHADOW_ALLOW`, `FROZEN_PREFIX`, the `shadow` pair loop, and the `shadow[:10]` print cap.
      *(completed)*
- [x] Replace the `for base, a, b in shadow[:10]:` truncation with the idiom the dupNamespace
      findings block a few lines above already uses: keep a printed cap, then emit
      `... and {len(shadow) - N} more` when the list is longer. Do not simply print all rows
      uncapped — match the surrounding convention. *(completed: reused the C26-style
      `if len(shadow) > 10: print(...)` tail rather than dupNamespace's own variant — same idiom,
      matches the block's existing `[:10]` cap)*
- [x] Run `bash scripts/check-module-invariants.sh --no-build` and save the full output to the
      scratchpad as the pre-fix baseline. *(completed: saved to scratchpad/baseline-phase1.txt)*
- [x] From that output, record the complete pair inventory as `(base, outer_ns, inner_ns)`
      triples — no line numbers — and confirm the printed row count now equals the reported count.
      *(completed: 10 printed + "... and 1 more"; 11th pair (mem_verts, SharingWindow,
      SharingWindow.BwdWalk) confirmed by direct grep of Window.lean)*
- [x] Record every other check group's PASS/FAIL status from the same run, so Phase 4 can prove no
      unrelated gate regressed. *(completed: only 2 FAIL lines in the whole run, both C23
      (Uppercase_x, shadowing); saved to scratchpad/baseline-statuses.txt)*

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Verification**:
- The scanner still runs to completion and its C23 sub-assertion lines are otherwise byte-identical
  to the pre-edit run (only the truncation tail differs).
- Printed shadow rows equal the reported shadow count.
- Baseline output file exists in the scratchpad.

**Scope Hypothesis**: 11 shadow pairs resolving to 11 distinct `(base, outer_ns, inner_ns)`
triples across 4 base names (`decidableValidZTime` x1, `cohWindowLo` x3, `cohWindowHi` x3,
`mem_verts` x4), plus 2 `NM_nonneg` sites, and C23 as the only failing group. Confirm by reading
the uncapped output of this phase's own re-run — do not carry the numbers over from the report or
from this plan. If the count differs, record the delta and adjust Phase 2's entry list before
writing it.

**Files to modify**:
- `scripts/check-module-invariants.sh` — replace the `shadow[:10]` print cap with a capped print
  plus an `... and N more` tail.

---

### Phase 2: Add the exact-pair shadow exemption [COMPLETED]

**Goal**: Introduce a `(base, outer_ns, inner_ns)`-keyed exemption set holding exactly the pairs
measured in Phase 1, with the reasoning inline and grouped by structural shape, so the shadow
sub-assertion passes without disabling any base-name bucket.

**Tasks**:
- [x] Add a new exemption set beside `SHADOW_ALLOW` — e.g. `SHADOW_PAIR_ALLOW`, a set of
      `(base, outer_ns, inner_ns)` tuples — with a block comment stating what it is for and,
      explicitly, how it differs from `SHADOW_ALLOW`: this set records *measured pairs*, so an
      unmeasured future collision on the same base name is still reported, whereas a
      `SHADOW_ALLOW` entry disables the bucket permanently. *(completed)*
- [x] Populate it with the triples from Phase 1, grouped into the three structural shapes with one
      inline reason per group:
      - `decidableValidZTime` (outer `..Decidability`, inner `..Decidability.Compression`) — the
        shadowing *is* the sub-namespacing deliberately chosen to avoid a genuine environment
        clash with the `..Decidability` declaration in `BiLasso/Assembly.lean`; collapsing it would
        recreate the clash it exists to avoid.
      - `cohWindowLo` / `cohWindowHi` (one outer in `BiLasso/Decide.lean`, three inner witness
        namespaces each) — one mirrored window API realized per witness family
        (`PlusSharingWitnessFamily`, `SharingWitnessFamily`, `SharingWindow`). The fan-out is the
        three families, not three independent naming decisions. Cite the `isValid` precedent:
        namesakes on distinct types reached by dot-notation.
      - `mem_verts` (two outers, `SharingWitnessFamily` and `SharingWindow`, each mirrored in its
        own `FwdWalk` and `BwdWalk` sub-namespaces) — a fully regular 2x2 grid; the regularity is
        itself the evidence that this is a mirrored API rather than a collision. Same `isValid`
        precedent. *(completed: 11 entries in 3 groups, matching the Phase 1 measured inventory)*
- [x] Apply the set inside the existing pair loop, at the same point `FROZEN_PREFIX` is tested:
      `continue` when `(base, a_ns, b_ns)` is in the set. Leave the `SHADOW_ALLOW` bare-name check
      and the `FROZEN_PREFIX` path check untouched. *(completed)*
- [x] Re-run `bash scripts/check-module-invariants.sh --no-build`; confirm the shadow
      sub-assertion now prints `PASS`. *(completed)*
- [x] **Narrowness check**: temporarily add a throwaway declaration (in a scratch copy of a Lean
      file, or by temporarily injecting a synthetic row into `decls2` in a scratch copy of the
      scanner — do not commit either) that creates a *new* pair on one of the four exempted base
      names from an unlisted namespace, and confirm the scanner still reports it. Revert the
      throwaway before proceeding. *(completed: injected two synthetic `decls2` rows on
      `mem_verts` from an unlisted namespace into a throwaway `scripts/.narrowness-test-691.sh`
      copy — placed inside `scripts/` so `REPO_ROOT` resolution stayed correct — confirmed the
      scanner still reported exactly that 1 synthetic pair as FAIL, then deleted the throwaway
      file; `git status --short scripts/` shows no trace of it afterward)*
- [x] Commit this green sub-step. *(completed)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Verification**:
- `PASS  C23  no outer-shadows-inner bare-declaration pair outside the recorded set`.
- The narrowness check reports the synthetic pair (proving the exemption did not disable the
  bucket), and the throwaway is fully reverted afterward — `git status --short` shows only
  `scripts/check-module-invariants.sh` among this task's changes.
- No inline comment added in this phase contains a task-number reference.

**Scope Hypothesis**: 11 tuple entries in 3 comment-grouped blocks, one file changed. Confirm
against Phase 1's measured triple list; if Phase 1 found a different set, the entry list follows
the measurement, not this plan.

**Files to modify**:
- `scripts/check-module-invariants.sh` — new `SHADOW_PAIR_ALLOW` set with grouped inline reasons;
  one added `continue` condition in the pair loop.

---

### Phase 3: Add the `NM_nonneg` UPPER_ALLOW entry and correct the class comment [COMPLETED]

**Goal**: Exempt the two `NM_nonneg` sites and restructure the `UPPER_ALLOW` comment so the set's
documented purpose actually covers the entries it holds.

**Tasks**:
- [x] Add `NM_nonneg` to `UPPER_ALLOW`. *(completed)*
- [x] Restructure the comment above `UPPER_ALLOW`. Today it reads "Prefixes that name no live
      declaration, so dot-namespacing them would invent one" — which describes the three existing
      entries but **not** `NM_nonneg`, where `NM` *is* live (`abbrev NM` in both
      `WitnessFamily/Sharing/Decide.lean` and `PlusWitnessFamily/Decide.lean`). Split it into two
      named classes: (a) the existing no-such-prefix class, and (b) a new class for a live prefix
      whose dot-form still cannot be written. *(completed)*
- [x] Write the class (b) reason inline against the measurement, with both obstacles:
      `NM_nonneg` is also a field of the `SharingWindow` structure (`WitnessFamily/Sharing/
      Window.lean`) and **structure fields cannot contain dots**; and `S.NM.nonneg` would resolve
      `nonneg` against the type of `S.NM`, which is `Int`, where no `Int.nonneg` exists. Note the
      sharpest site as evidence: `PlusWitnessFamily/Decide.lean`'s `NM_nonneg := S.NM_nonneg`,
      where the field and the theorem of the same name occur in one expression — so any rename
      must split the two in place. Record the blast radius (26 occurrences across 5 files) as the
      reason this is recorded rather than done blind, citing the `insertEnv` precedent.
      *(completed: re-measured with `grep -rn 'NM_nonneg' FormalSystem/ BimodalTools/` — 26
      occurrences across exactly 5 files, matching the plan's figure)*
- [x] Add a short note that the three recorded auto-exemption classes were each checked and miss
      here: `NM_` is not a `TENSE_PREFIX`; `NM` is live, so the no-such-prefix class does not
      apply; and `nonneg` is not a live base, so the name-capture auto-exemption does not fire —
      and that introducing a live `nonneg` to silence the check is a non-fix, not a resolution.
      *(completed)*
- [x] Re-run `bash scripts/check-module-invariants.sh --no-build`; confirm the `Uppercase_x`
      sub-assertion prints `PASS`. *(completed: also updated the PASS message's class list to
      name the new "live-prefix" class, per this phase's own Verification bullet)*
- [x] Commit this green sub-step. *(completed)*

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: exactly 2 reported `NM_nonneg` sites (`PlusWitnessFamily/Decide.lean` and
`WitnessFamily/Sharing/Decide.lean`), and a rename blast radius of 26 occurrences across 5 files.
Confirm the 2 sites from the scanner's own `Uppercase_x` output, and re-count the occurrences with
`grep -rn 'NM_nonneg' FormalSystem/ BimodalTools/` before writing that figure into the comment —
if it differs, write the measured number, not this one.

**Verification**:
- `PASS  C23  no Uppercase_x name outside the tense-operator, no-such-prefix and name-capture
  classes` (update this PASS message's class list if the restructured comment renames the
  classes, so message and comment agree).
- The comment above `UPPER_ALLOW` describes every entry the set now holds — no entry falls outside
  a documented class.
- No task-number reference in any added comment.

**Files to modify**:
- `scripts/check-module-invariants.sh` — `UPPER_ALLOW` gains `NM_nonneg`; the preceding comment is
  split into two documented classes; the corresponding `PASS` message updated if class names
  changed.

---

### Phase 4: Full gate run, baseline comparison, and final commit [NOT STARTED]

**Goal**: Prove C23 is green, that no other gate group regressed relative to the Phase 1 baseline,
and that the change is committed with a correctly scoped staging set.

**Tasks**:
- [ ] Run the complete `bash scripts/check-module-invariants.sh` (not just `--no-build`) and
      confirm zero failures and all three C23 sub-assertions `PASS`.
- [ ] Diff this run's per-group PASS/FAIL statuses against the Phase 1 baseline; confirm the only
      changes are the two C23 sub-assertions flipping red to green. Any other delta is
      investigated before the commit, not after.
- [ ] Confirm `ENFORCE_C23=${ENFORCE_C23:-1}` is unchanged and still `1`.
- [ ] Run `bash .claude/scripts/check-task-references.sh` (or grep the diff for `task [0-9]`) to
      confirm no task-number reference entered `scripts/check-module-invariants.sh`.
- [ ] Review `git status --short` and `git diff --staged`. Stage `scripts/check-module-invariants.sh`
      by explicit filename plus this task's `specs/691_.../` artifacts only. Do **not** stage
      `typst/generated/status.typ`, `ORGANISATION.md`, `scripts/measure-refactor-partitions.py`,
      or any other pre-existing working-tree modification, and do not use `git add -A`, `git add .`,
      or a directory/glob pathspec.
- [ ] Commit as `task 691: complete implementation`.
- [ ] Write the execution summary to
      `specs/691_resolve_c23_naming_exemptions/summaries/01_c23-naming-exemptions-summary.md`,
      recording the final triple inventory and the exemption-key decision.

**Timing**: 0.5 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: exactly two per-group status flips relative to the Phase 1 baseline (the
`Uppercase_x` and shadow sub-assertions), and a staged file set of one script plus this task's
`specs/691_.../` artifacts. Confirm by diffing the two saved scanner outputs and by reading
`git diff --staged --name-only` — not by assuming.

**Verification**:
- Full `check-module-invariants.sh` exits 0 with no `FAIL` line.
- Per-group status diff against the Phase 1 baseline shows only the two intended flips.
- `git diff --staged --name-only` lists only `scripts/check-module-invariants.sh` and this task's
  `specs/691_.../` artifacts.
- Summary file exists.

**Files to modify**:
- `specs/691_resolve_c23_naming_exemptions/summaries/01_c23-naming-exemptions-summary.md` — new.

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` exits 0; all three C23 sub-assertions `PASS`.
- [ ] Shadow-pair printing is no longer silently truncated: printed rows plus the `... and N more`
      tail account for the full reported count.
- [ ] Narrowness proven: a synthetic new pair on an exempted base name from an unlisted namespace
      is still reported (Phase 2), and the synthetic change is reverted.
- [ ] Every added exemption entry has its reason inline, beside the entry.
- [ ] `ENFORCE_C23` still `1`; `FROZEN_PREFIX` and the existing `SHADOW_ALLOW` entries untouched.
- [ ] No `.lean` file modified: `git diff --name-only` contains no `.lean` path.
- [ ] No task-number reference in `scripts/check-module-invariants.sh`.
- [ ] No unrelated gate group changed status versus the Phase 1 baseline.

## Artifacts & Outputs

- `scripts/check-module-invariants.sh` — uncapped-with-tail shadow printing; new
  `SHADOW_PAIR_ALLOW` triple-keyed exemption set with 11 entries in 3 reasoned groups;
  `UPPER_ALLOW` gains `NM_nonneg` with a restructured two-class comment.
- `specs/691_resolve_c23_naming_exemptions/plans/01_c23-naming-exemptions.md` — this plan.
- `specs/691_resolve_c23_naming_exemptions/summaries/01_c23-naming-exemptions-summary.md` —
  execution summary.
- Scratchpad: pre-fix and post-fix full scanner output, for the baseline comparison.

## Rollback/Contingency

The whole change is confined to one script and is committed per green sub-step, so reverting is
`git revert` of the relevant commit(s) — no Lean source, no generated artifact, and no build state
is involved, so nothing else depends on the change.

Contingencies:
- **Phase 1 finds a different pair inventory** (the tree moved): the measurement wins. Adjust
  Phase 2's entry list to the measured triples and record the delta in the summary.
- **The triple-key mechanism proves more invasive than expected** (e.g. the pair loop cannot cleanly
  see both namespaces at the exemption point): fall back to bare-name `SHADOW_ALLOW` entries for
  the four names, and state explicitly in each inline reason that the whole base-name bucket is
  being disabled and why that is acceptable — Finding 3's option 1 with its cost recorded rather
  than hidden. Note the fallback in the summary; do not take it silently.
- **A gate group other than C23 goes red mid-task**: it is out of scope (see the `typst-sync-check`
  Non-Goal). Record it and leave it; do not expand this task's edits to chase it.
