# Implementation Plan: Task #828

- **Task**: 828 - Metalogic upward-edge allowlist count drift (CI red on `main`)
- **Status**: [IMPLEMENTING]
- **Effort**: 1.0 hours
- **Dependencies**: None
- **Research Inputs**: specs/828_metalogic_upward_edge_allowlist_count_drift/reports/01_upward_edge_allowlist_count_drift.md
- **Artifacts**: plans/01_upward-edge-allowlist-count-drift.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

`bash scripts/check-metalogic-cycles.sh` exits 1 on `main`: assertion B finds one SURPLUS
upward import line (`FormalSystem.MinusLanguage.AxiomDischarge ->
FormalSystem.Theorems.LinearityDerived`) that is absent from the recorded `ALLOWLIST`. The edge
is a legitimate eighth member of the already-documented class (`AxiomDischarge` discharging L⁻
axioms through derived `Theorems/*` schemata), not a layering violation, so the fix is additive:
admit the entry to the allowlist AND correct every prose count that still narrates the set as
seven lines, in one atomic change across the four in-scope files. No `.lean` file changes.

The work is one implementation phase of mechanical, enumerated edits, followed by one
verification phase that runs the task's three named acceptance checks and sweeps for any
residual count the enumeration missed.

### Research Integration

The research report re-ran the failing script, confirmed the eight measured edges via
`python3 scripts/measure-refactor-partitions.py upward-edges`, confirmed that
`check-module-invariants.sh --no-build` is green and orthogonal, and enumerated the exact edit
sites. Three corrections/additions were established by independent re-verification during this
planning pass and are folded into Phase 1 below:

1. **Two live count sites the report's enumeration omitted**:
   `scripts/check-metalogic-cycles.sh:7` (`B. The library-wide UPWARD import set equals a
   recorded 7-line allowlist.`) and `docs/ARCHITECTURE.md:54` (the ASCII layer diagram's
   `── 7 lines ──┘` edge label). Both are live statements of the current count and must change.
2. **Line-number drift** against the report's citations: `ORGANISATION.md`'s second count is at
   `:53` (not `:52`) and its fenced-block comment at `:220` (not `:219`).
3. **A newly identified scope boundary** the report did not reach: `ORGANISATION.md:73-78` is a
   counterfactual snapshot table (`MinusLanguage` -> `Theorems` 7 at layers 0 and 1) whose own
   preamble already dates it ("The measurement immediately below was taken on the first three,
   before the others existed"). See Decisions below for why it is left unchanged.

The report's recommendation to keep the allowlist entry and all count edits in a single change
is adopted as Phase 1's `atomic-batch` commit mode.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; no ROADMAP.md consultation performed.

## Goals & Non-Goals

**Goals**:
- `bash scripts/check-metalogic-cycles.sh` exits 0 with assertion B passing on an 8-line allowlist.
- Every live statement of the upward-set count in the four in-scope files reads eight, not seven.
- `docs/ARCHITECTURE.md`'s enumerated theorem-name list includes `LinearityDerived`.
- `bash scripts/check-module-invariants.sh --no-build` remains green (unchanged by this work).

**Non-Goals**:
- Relocating or removing the `import FormalSystem.Theorems.LinearityDerived` line at
  `FormalSystem/MinusLanguage/AxiomDischarge.lean:16`. The edge is accepted, not fixed.
- Any change to `FormalSystem/**/*.lean`.
- Any change to `LAYERS` or `LANGUAGE_FILE_LAYERS` in `scripts/measure-refactor-partitions.py`:
  both already classify `AxiomDischarge` (layer 0) and `Theorems` (layer 2) correctly, which is
  precisely why the edge is *measured* as upward.
- Residual out-of-scope "7" mentions at `scripts/README.md:18` and in
  `docs/development/PUBLICATION_REFACTOR.md`. Neither file is in `FILE SCOPE` nor named by the
  acceptance line; the latter is a dated program record whose count was accurate when written.
- Eliminating the structural cause (a count hand-typed in N prose places rather than generated
  from `len(ALLOWLIST)`). That is a larger follow-up, noted by research, not this task.

## Decisions

- **`ORGANISATION.md:73-78` is left unchanged.** That table answers a counterfactual ("give all
  three language directories one layer *L*, and the upward set is non-empty for every *L*"), it
  is explicitly dated by its own preamble to a measurement taken before `OpenLanguage/`,
  `HybridLanguage/` and `QuantLanguage/` existed, and its rows carry co-dependent totals (`23`,
  `9`) and sibling terms (`language -> Semantics 14`) that cannot be re-derived by incrementing
  one cell — the measurement script exposes no single-layer-for-all-three mode to re-run it
  under. Bumping `7` to `8` there in isolation would make the row arithmetically inconsistent,
  which is worse than a correctly-dated historical figure. The acceptance criterion's wording
  ("no count anywhere ... still says **seven** upward lines") is satisfied: these cells say `7`
  inside a dated counterfactual, not "seven upward lines" as a live claim. If the implementer
  judges otherwise, the only defensible alternative is re-measuring the whole table, which is
  out of scope — flag it rather than hand-edit one cell.
- **Alphabetical insertion position is cosmetic, not functional.** `ALLOWLIST` is a `frozenset`
  comprehension, so literal ordering never affects behavior; `"LinearityDerived"` goes between
  `"GeneralizedNecessitation"` and `"Propositional.Core"` to honor the existing convention and
  keep the diff readable. Do not be surprised that the gate would pass with it anywhere.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A prose count is missed, leaving a stray "seven" the acceptance line checks for | M | M | Phase 1 works from the explicit per-line inventory below; Phase 2 re-runs the same `grep -nE` sweep that produced it and requires zero live hits |
| A must-not-change "seven"/"7" is edited by an over-broad `sed` (e.g. "seven language directories", "7 inference rules", "seven sibling aggregators") | M | M | The inventory names every forbidden site explicitly; edits are per-line and anchored on surrounding words, never a bare global `s/7/8/` |
| `docs/ARCHITECTURE.md:54`'s box-drawing diagram misaligns after the edit | L | L | `7` -> `8` is a one-character-for-one-character swap inside `── 7 lines ──┘`; column width is unchanged. Confirm by reading the rendered block, not by assuming |
| Phase 1 lands half the change (allowlist green, docs still seven), re-opening the same drift | H | L | Phase 1 is a declared `atomic-batch`: all four files in one commit, no per-file intermediate commit |
| The allowlist edit silently breaks another consumer | M | L | Research confirmed none of `check-module-invariants.sh`'s C1-C37 reads any in-scope file; Phase 2 runs it anyway as the named regression check |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Admit the eighth edge and correct every recorded count [COMPLETED]

**Goal**: One atomic change that adds `LinearityDerived` to the recorded allowlist and brings
every live count statement in the four in-scope files from seven to eight.

**Tasks**:
- [x] Re-run `bash scripts/check-metalogic-cycles.sh` and confirm it still exits 1 with the
      single `SURPLUS ... Theorems.LinearityDerived` line (establish the red baseline in this
      dispatch; do not inherit it from this plan). *(completed: confirmed red baseline exactly as described)*
- [x] Re-run `python3 scripts/measure-refactor-partitions.py upward-edges` and confirm eight
      edges, all `AxiomDischarge -> Theorems.*`. *(completed)*
- [x] Re-grep each line number in the inventory below before editing it; the file may have
      moved under this plan. The anchor text, not the number, is authoritative. *(completed: all line numbers matched the plan exactly)*
- [x] `scripts/check-metalogic-cycles.sh`: insert `    "LinearityDerived",` into the `ALLOWLIST`
      frozenset tuple (currently at `:192`-`:200`) between `"GeneralizedNecessitation"` and
      `"Propositional.Core"`. *(completed)*
- [x] `scripts/check-metalogic-cycles.sh`: four prose counts -> eight.
      `:7` `recorded 7-line allowlist` -> `8-line`;
      `:55` `THE ALLOWLIST HOLDS 7 LINES` -> `8 LINES`;
      `:56` `The same 7 lines were recorded` -> `8 lines`;
      `:186` `The recorded allowlist: 7 lines` -> `8 lines`. *(completed)*
- [x] `scripts/measure-refactor-partitions.py`: five prose counts -> eight.
      `:49` `7 import lines in total` -> `8`;
      `:51` `importing 7 Theorems modules` -> `8`;
      `:57` `recorded 7-line` -> `8-line`;
      `:175` `whose 7 imports of Theorems` -> `8`;
      `:179` `The 7 lines are recorded` -> `8 lines`.
      MUST NOT touch `:24`, `:59`, `:127` (all "the seven language directories"), `:79`, or the
      `LAYERS` / `LANGUAGE_FILE_LAYERS` tables. *(completed: forbidden lines verified untouched)*
- [x] `docs/ARCHITECTURE.md`: seven prose/diagram counts -> eight.
      `:54` diagram label `── 7 lines ──┘` -> `── 8 lines ──┘`;
      `:58` heading `seven lines` -> `eight lines`;
      `:60` `**seven**` -> `**eight**`;
      `:67` `the same seven lines` -> `eight lines`;
      `:71` `the seven lines are back` -> `eight lines`;
      `:186` `the one count on this page (the seven` -> `eight`;
      `:191` fenced-block comment `the 7 recorded lines` -> `8`.
      MUST NOT touch `:135` ("7 inference rules"). *(completed: line :135 verified untouched)*
- [x] `docs/ARCHITECTURE.md`: insert `LinearityDerived` into the parenthesized theorem-name list
      spanning `:61`-`:63`, between `GeneralizedNecessitation` and `Propositional.Core`; re-wrap
      the paragraph only if the inserted name pushes a line past the file's existing wrap width.
      *(completed: paragraph re-wrapped slightly to fit the inserted name)*
- [x] `ORGANISATION.md`: three prose counts -> eight.
      `:51` `**The measured upward set is 7 import lines**` -> `8 import lines`;
      `:53` `All 7 run from` -> `All 8 run from`;
      `:220` fenced-block comment `the recorded 7 AxiomDischarge lines` -> `8`.
      MUST NOT touch `:73`-`:78` (dated counterfactual table, see Decisions), `:75`, `:76`, or
      `:91` ("The seven sibling aggregators"). *(completed: forbidden lines verified untouched)*
- [x] Run `bash scripts/check-metalogic-cycles.sh` and confirm exit 0 with
      `PASS  upward import set is exactly the recorded 8 line(s)`. *(completed: exact message confirmed)*
- [x] Run `python3 scripts/measure-refactor-partitions.py upward-edges` once more and confirm it
      still reports the same eight edges (the prose edits touched its docstring, so a smoke run
      confirms no syntax damage). *(completed)*
- [x] Commit all four files together, one commit. *(completed)*

**Timing**: 0.6 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase asserts nineteen count-bearing lines (4 in
`check-metalogic-cycles.sh`, 5 in `measure-refactor-partitions.py`, 7 in `docs/ARCHITECTURE.md`,
3 in `ORGANISATION.md`) plus two insertions (the allowlist entry, the theorem-name list entry).
Confirm by re-running
`grep -nE 'seven|\b7\b|7-line|7 line' scripts/check-metalogic-cycles.sh scripts/measure-refactor-partitions.py docs/ARCHITECTURE.md ORGANISATION.md`
before editing and classifying each hit as in-scope or explicitly-forbidden against the lists
above; if the hit set differs from nineteen in-scope lines, reconcile the difference explicitly
rather than proceeding on this plan's number.

**Tier Justification**: `bash scripts/check-metalogic-cycles.sh` (exit 0, assertion B naming 8
recorded lines) plus `python3 scripts/measure-refactor-partitions.py upward-edges` execute both
edited executable files end-to-end, and the two remaining files are markdown with no executable
surface, so no build or cross-file interface is in this edit's blast radius.

**Files to modify**:
- `scripts/check-metalogic-cycles.sh` - add `"LinearityDerived"` to `ALLOWLIST`; four prose counts 7 -> 8
- `scripts/measure-refactor-partitions.py` - five docstring/comment counts 7 -> 8; data tables untouched
- `docs/ARCHITECTURE.md` - seven prose/diagram counts seven -> eight; insert `LinearityDerived` into the theorem-name list
- `ORGANISATION.md` - three prose counts 7 -> 8; counterfactual table at `:73`-`:78` untouched

**Verification**:
- `bash scripts/check-metalogic-cycles.sh` exits 0 and prints
  `PASS  upward import set is exactly the recorded 8 line(s)`, with assertions A and C still PASS.
- `python3 scripts/measure-refactor-partitions.py upward-edges` exits 0 and still lists the same
  eight `AxiomDischarge -> Theorems.*` edges.
- `git diff --staged` shows exactly four files and no `FormalSystem/**` path.

---

### Phase 2: Acceptance verification and residual-count sweep [COMPLETED]

**Goal**: Prove the three stated acceptance criteria hold, and prove no live "seven upward
lines" claim survives anywhere in the two documentation files the acceptance line names.

**Tasks**:
- [x] Re-run `bash scripts/check-metalogic-cycles.sh`; require exit 0. *(completed: exit 0)*
- [x] Run `bash scripts/check-module-invariants.sh --no-build`; require exit 0 and
      `ALL CHECKS PASSED`. Record the observed PASS count rather than asserting a number: the
      task description says 47, research measured 46 PASS lines plus one
      `INFO C36b skipped (--no-build)`. Either is acceptable; a FAIL is not.
      *(completed: exit 0, ALL CHECKS PASSED, 46 PASS + 1 INFO C36b skipped)*
- [x] Re-run the residual sweep
      `grep -nE 'seven|\b7\b|7-line|7 line' scripts/check-metalogic-cycles.sh scripts/measure-refactor-partitions.py docs/ARCHITECTURE.md ORGANISATION.md`
      and confirm every surviving hit is on the explicitly-forbidden list from Phase 1
      (`measure-refactor-partitions.py:24,59,79,127`; `docs/ARCHITECTURE.md:135`;
      `ORGANISATION.md:75,76,91`) and none is a live upward-set count.
      *(completed: 8 surviving hits, all on the forbidden list; docs/ARCHITECTURE.md's hit shifted
      to line 136 after the theorem-name insertion but is the same forbidden "7 inference rules"
      text)*
- [x] Run the repository's full gate set (see Verification below). If a gate fails for a reason
      traceable to Phase 1's edits, correct it in this phase; if it fails for a pre-existing
      reason unrelated to the four in-scope files, record that as a finding via
      `issue-record.sh` and do not expand scope to fix it.
      *(completed: `bash .claude/scripts/verify-deploy.sh` PASS, 15 checks, 0 failures)*
- [x] If and only if the sweep surfaces a missed live count, correct it and commit; otherwise
      this phase makes no edits and commits nothing. *(completed: sweep surfaced no missed count;
      no edits made, no commit for this phase)*

**Timing**: 0.4 hours

**Depends on**: 1

**Verification Tier**: full

**Files to modify**:
- none planned; corrective edits confined to the four Phase 1 files if the sweep surfaces a miss

**Verification**:
- The complete gate set for this repository: `bash .claude/scripts/verify-deploy.sh`, run
  unfiltered (not `--only-gate`), green.
- `bash scripts/check-metalogic-cycles.sh` exits 0.
- `bash scripts/check-module-invariants.sh --no-build` exits 0 with `ALL CHECKS PASSED`.
- The residual `grep -nE` sweep over all four files yields no live upward-set count stating
  seven, and every surviving hit is accounted for against the forbidden list.

---

## Testing & Validation

- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0; assertion B reports 8 recorded lines.
- [ ] `bash scripts/check-module-invariants.sh --no-build` exits 0, `ALL CHECKS PASSED`.
- [ ] `python3 scripts/measure-refactor-partitions.py upward-edges` exits 0, eight edges.
- [ ] No live count in `docs/ARCHITECTURE.md` or `ORGANISATION.md` states seven upward lines.
- [ ] `git diff` touches exactly the four in-scope files; no `FormalSystem/**` path appears.
- [ ] `bash .claude/scripts/verify-deploy.sh` green.

## Artifacts & Outputs

- Modified `scripts/check-metalogic-cycles.sh` (8-entry `ALLOWLIST`, four corrected counts)
- Modified `scripts/measure-refactor-partitions.py` (five corrected docstring/comment counts)
- Modified `docs/ARCHITECTURE.md` (seven corrected counts, `LinearityDerived` in the name list)
- Modified `ORGANISATION.md` (three corrected counts)
- `specs/828_metalogic_upward_edge_allowlist_count_drift/summaries/01_*-summary.md`

## Rollback/Contingency

All edits are additive-or-textual within four tracked files and no `.lean` file is touched, so
reverting is a single `git revert` of Phase 1's atomic commit — which restores the pre-existing
red gate, not a worse state.

Contingency if the eighth edge turns out NOT to be a legitimate member of the class (i.e. the
`Theorems.LinearityDerived` repointing at `AxiomDischarge.lean:16` was meant to be temporary):
abandon this plan's additive approach and instead relocate the import, which is a
`FormalSystem/**` change entirely outside this task's `FILE SCOPE` and warrants a new task
rather than a scope expansion here. Research examined all three usages (`:277`
`LinearityDerived.tempLinearityLegacyAt`; `:320`/`:324` `LinearityDerived.density`) and found
them substantively identical in kind to the other seven, so this contingency is not expected to
fire; if the implementer's own reading disagrees, stop and surface it rather than proceeding.
