# Implementation Plan: Task #643

- **Task**: 643 - Citation gates: bibkeys, links and line anchors
- **Status**: [COMPLETED]
- **Effort**: 9 hours
- **Dependencies**: None
- **Research Inputs**: specs/643_citation_gates_bibkeys_links_and_line_anchors/reports/01_citation-gates-bibkeys-links.md
- **Artifacts**: plans/01_citation-gates-bibkeys-links.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: general
- **Lean Intent**: false

## Overview

Three citation-normal-form defect classes (dangling `[bibkey]`, broken relative markdown links
inside `.lean` docstrings, and `file.lean:NNN` anchors pointing at the *wrong* declaration rather
than at nothing) survived the docstring-and-citation normalisation sweep because no standing gate
reads them. This plan adds two new enforced checks to `scripts/check-module-invariants.sh` (C31
bibkeys, C32 docstring links), adds a third reporting-then-gated sub-assertion to C20 that
cross-checks a citation carrying a declaration name against the declaration span actually at that
line, pins the re-anchor tool's already-existing `--recompute` idempotency with a re-runnable
selftest, and converts the worst-shifted files' citations to name-carrying form while recording
the tree-wide residual honestly. Done means: harness green on the current tree; each new check
observed to FAIL with a non-zero script exit on its injected negative case and to PASS again after
revert; `--recompute` run twice giving an empty second diff, asserted by a command rather than
narrated; residual name-less citation count printed at every gate; `MODULE_INVARIANTS.md` rows and
a `REFERENCE_NORMAL_FORM.md` pointer landed.

### Research Integration

The research report is unusually load-bearing here and three of its findings change the shape of
the work rather than merely informing it:

- **Deliverable (4) is substantially already delivered.** `scripts/reanchor-lean-citations.py`
  already has an idempotent `--recompute` mode (built during the normalisation sweep's own repair
  of the double-run mistake). Research reproduced the exact double-shift against a disposable
  clone, ran `--recompute` once (repaired 72 citations across 19 citers), then again (0 changes).
  Phase 3 therefore *pins and documents* an existing property with a selftest plus its one known
  blind spot, and does not build a new mechanism. The dispatch's alternative phrasing
  ("or the cited declaration's name") is deliberately **not** implemented as a second alignment
  mechanism: no failure case for the existing one is known. See Risks.
- **A naive markdown-link regex over `.lean` files is unusable.** `\[..\]\(..\)` finds 80 matches
  of which 72 are inline math notation (`[z_0, z_1](x, y)`) in the `Kamp/NfMultiAnchorBridge/`
  subtree. A path-shaped filter on the target is load-bearing, not polish: without it C32's very
  first run is a wall of false positives and the check is never trusted again. Filtered, the true
  current state is 8 links, all resolving.
- **"The declaration actually at that line" cannot mean the exact `theorem` keyword line.**
  `PriorExpressivenessDense.lean:91` cites `KPlusFaithful.lean:479` and `:524` for two named
  theorems declared at 480 and 530 — line 479 is the closing `-/` of the first's own docstring,
  line 524 is *inside* the second's. Both are correct citations. C20's new sub-assertion must
  resolve a **declaration span** (leading doc comment through end of body), or its first run turns
  every loosely-anchored citation in the tree red.

Research also confirms the tree is currently clean on every dimension the two new checks measure
(0 dangling bibkeys, 0 broken docstring links after filtering, C20 tier 1 at its recorded 1028/0
baseline), which is what lets C31 and C32 ship **enforced from the outset** with no soft period,
on this repository's own stated precedent ("C12, C13, C14 and C15 ship enforced, with no flags,
because the work that cleared their debt landed in the same change that added them").

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` provided in the dispatch context; `specs/ROADMAP.md` was not consulted and no
roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- `C31`: every `[key]` cited inside a `## References` / `### References` block under
  `FormalSystem/`, `BimodalTools/`, `Tests/` resolves in the repository-root `references.bib`;
  gated. Plus an advisory (never gated) report of `references.bib` entries cited by no `.lean`
  **and** no `.typ` file, honouring both citation syntaxes.
- `C32`: every relative markdown link inside a `.lean` docstring resolves on disk relative to the
  citing file; gated, with a path-shaped target filter.
- Both new checks exclude `Boneyard/` via the shared `scripts/lib/live_walk.py` walker, and state
  explicitly in their header comments and docs rows that the `sub:` anchor prefix is out of scope.
- `reanchor-lean-citations.py --selftest` gains a third probe asserting the double-run →
  `--recompute` → second-`--recompute`-is-a-no-op sequence mechanically, plus an explicit fixture
  for the known blind spot (a citer line content-edited in the same batch).
- C20 gains a third assertion: a citation carrying an adjacent declaration name is checked against
  the **declaration span** at that line; and the harness prints the tree-wide residual count of
  name-less `file.lean:NNN` citations at every gate.
- The three named worst-shift files' citations are converted to name-carrying form, with the
  per-file residual recorded rather than driven to zero.
- `MODULE_INVARIANTS.md` rows for C31, C32 and C20's third assertion; a pointer from
  `REFERENCE_NORMAL_FORM.md` and new rows in its §5 recorded-baselines table.

**Non-Goals**:

- Converting all 1028 `file.lean:NNN` citations to name-carrying form. The dispatch explicitly
  authorises sizing this honestly; the mechanism plus the three named files is the deliverable and
  the residual is recorded.
- Building a declaration-name-alignment fallback inside `--recompute`. Not needed for the stated
  acceptance criterion (see Research Integration); re-opened only if implementation surfaces a
  concrete failure of the existing content-alignment mechanism.
- Widening C31 to the ~81 inline-prose bibkey mentions outside `## References` blocks. The normal
  form deliberately does not govern those.
- Repairing `readme-lint.sh`'s 21 known-red broken references or `typst-sync-check.sh`'s 9 Check-1
  violations. Both are recorded baselines of a separate item and must stay unchanged.
- Any change to `readme-lint.sh`. Deliverable (7)'s pointer at `MODULE_INVARIANTS.md` settles that
  both new checks are wired into `check-module-invariants.sh`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C32 false-positives on inline math notation (`[z_0, z_1](x, y)`) make the check untrustworthy on its first run | H | H (certain without the filter) | Path-shaped target filter is a Phase 2 acceptance criterion, not an optimisation: require a conservative path-token grammar (word chars, `.`, `/`, `-`, no whitespace/comma) **and** at least one `/` or a recognised extension. Assert the filtered count is 8-and-resolving before wiring the gate |
| C20's declaration-span definition chosen too strictly fails correct, already-in-tree citations | H | M | Span = start of the declaration's own leading `/--`/`/-!` doc comment (walking back past `@[...]` attributes, reusing C15's second-assertion logic) through the end of its body. `PriorExpressivenessDense.lean:91 -> KPlusFaithful.lean:479, :524` is the pinned regression fixture: both must resolve |
| Docstring edits in Phase 5 change line counts and re-stale other citations into the same files | H | M | Prefer line-count-neutral edits; run `--recompute` (never a second Δ pass) at the end of the phase if any edit changes a line count; re-run C20 tier 1 before the phase closes and assert the 1028-resolvable / 0-unverifiable baseline is intact |
| The advisory "unused bib entries" half under-counts because Typst cites `@key`, not `[key]` | M | H (certain if only one syntax is scanned) | Union two regexes (Lean `[key]`, Typst `@key`) before the `comm`; assert the reported unused count drops below the 55 a single-syntax scan produces |
| The `unverifiable` citation count rises silently behind a PASS line | M | L | `REFERENCE_NORMAL_FORM.md` §5 already states `unverifiable` is not a pass. Every phase's verification asserts the *resolvable* count (1028) and the unverifiable count (0) explicitly |
| A new check silently passes on everything (the failure mode worse than no check) | H | M | Per-check deliberate negative test with **both** the printed `FAIL` line and a non-zero script exit observed, then revert and re-observe `PASS` plus exit 0 — this repo's standing protocol, not a special requirement here |
| Sibling tasks 614, 637, 644 edit the shared tree this same cycle | M | M | Declared file scope does not overlap any sibling's. Re-read every file immediately before editing; stage explicit file lists only (never a directory or glob pathspec); treat an unexpected failure outside this task's scope as possibly a sibling's in-flight edit and report rather than "fix" it |
| `--recompute`'s blind spot (a citer line content-edited in the same batch is left un-repaired) is mistaken for a bug during Phase 3 | L | M | Phase 3 encodes it as an explicit, asserted, *documented* fixture outcome — a known limitation with a test, not a silent gap |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 4 |
| 5 | 6 | 1, 2, 3, 4, 5 |

Phases within the same wave can execute in parallel. Phases 1, 2 and 4 all edit
`scripts/check-module-invariants.sh` and are therefore serialised against each other; Phase 3
touches only `scripts/reanchor-lean-citations.py` and is genuinely independent of Phase 1.

---

### Phase 1: C31 — bibkey resolution check [COMPLETED]

**Goal**: Every `[key]` cited inside a `## References` / `### References` block under
`FormalSystem/`, `BimodalTools/` and `Tests/` resolves in the repository-root `references.bib`,
gated; plus an advisory report of bib entries cited by nothing.

**Tasks**:

- [x] Re-read `scripts/check-module-invariants.sh` immediately before editing (sibling-territory
      discipline). *(completed)*
- [x] Add `ENFORCE_C31=${ENFORCE_C31:-1}` to the flag block near the top of the script, with the
      same "enforced from the outset, never flip to 0" comment C20/C21/C24 carry. *(completed)*
- [x] Implement C31 as a `python3` heredoc block placed after C30 and before the C9-DOCS block,
      matching the surrounding `pas`/`bad`/`inf`/`soft`/`note` helper idiom and the
      `C31_STATUS=$?` / `FAILURES=$((FAILURES + 1))` wiring. *(completed)*
- [x] Walk `.lean` files through `scripts/lib/live_walk.py`'s `live_files`, never a re-implemented
      Boneyard exclusion. *(completed)*
- [x] Locate each `## References` / `### References` heading inside a doc comment and compute its
      extent (next heading of equal-or-higher level, or end of the doc comment); scan for
      `[key]`-shaped citations **inside block interiors only**. *(completed)*
- [x] Gated half: every block-scoped key must resolve against `^@[a-z]+\{<key>,` in
      `references.bib`. Report each dangling key as `citer:line -> [key]`. *(completed)*
- [x] Advisory half (INFO, never gated, never touches `FAILURES`): entries in `references.bib`
      cited by no `.lean` (`[key]`) and no `.typ` (`@key`) file — **two regexes unioned**, per the
      Typst finding. *(completed: measured 11 unused of 77; a Lean-only scan reports 55)*
- [x] Header comment states: scope (`FormalSystem/`, `BimodalTools/`, `Tests/`), `Boneyard/`
      excluded, `sub:` anchors out of scope, inline-prose bibkeys deliberately out of scope, and
      why the advisory half needs two syntaxes. *(completed)*
- [x] Deliberate negative test: inject a dangling key into one `## References` block, observe both
      `FAIL C31` **and** a non-zero script exit; revert; observe `PASS C31` and exit 0. *(completed: thomason1984 -> thomason1985 in PlusLimitClosure.lean gave FAIL C31 + exit 1; revert gave PASS + exit 0)*
- [x] Commit the green result. *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: research measured 22 distinct block-scoped bibkeys (all resolving), 77
`references.bib` entries, and ~55 apparently-unused entries under a single-syntax scan. Confirm at
implementation time by running the new check and comparing its printed counts against these
numbers; the advisory unused count is expected to fall below 55 once the Typst `@key` syntax is
unioned in. Treat any divergence as a finding to record, not a number to force.

**Files to modify**:

- `scripts/check-module-invariants.sh` — new `ENFORCE_C31` flag, new C31 block, header-comment
  check list entry, companion-files list entry if any.

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` prints `PASS C31` and the harness exit code
  is 0.
- The injected-dangling-key negative test produced `FAIL C31` and a non-zero exit, and the revert
  restored `PASS` and exit 0. Both observations recorded.
- No other check's line changed (C15/C20 in particular still PASS with their recorded counts).

---

### Phase 2: C32 — docstring markdown-link check [COMPLETED]

**Goal**: Every relative markdown link inside a `.lean` docstring resolves on disk relative to the
citing file, gated, with the load-bearing path-shaped filter that keeps inline math notation out.

**Tasks**:

- [x] Re-read `scripts/check-module-invariants.sh` immediately before editing. *(completed)*
- [x] Add `ENFORCE_C32=${ENFORCE_C32:-1}` alongside `ENFORCE_C31`, same comment idiom. *(completed)*
- [x] Implement C32 as a `python3` heredoc block directly after C31, walking `.lean` files through
      `live_walk.live_files`. *(completed)*
- [x] Restrict matching to **doc-comment regions** (`/--` … `-/`, `/-!` … `-/`), not whole-file
      text — a link in a `--` line comment is still documentation and is in scope; a bracket-paren
      pair in code is not. *(completed: comment text read through a new comments_only view added to scripts/lib/lean_debug_artifacts.py, the scan C27/C29/C30 already mask with)*
- [x] Apply the path-shaped filter before treating a match as a link: target must match a
      conservative path-token grammar (word characters, `.`, `/`, `-`; no whitespace, no comma)
      **and** contain at least one `/` or end in a recognised extension. Skip
      `http://`/`https://`/`mailto:`/`#` targets and strip any `#fragment`, as C13 already does. *(completed)*
- [x] Resolve the target relative to the **citing file's own directory**, and reuse C13's
      `git check-ignore` guard so a target that exists only because it is gitignored is reported
      broken (resolves locally, fails on CI). *(completed)*
- [x] Header comment records: the 72-false-positive measurement, why the filter is load-bearing and
      not polish, `Boneyard/` exclusion, and `sub:` anchors out of scope. *(completed: measured 82 raw matches / 71 inline mathematics / 3 external / 8 path-shaped, against the research figure of 80 / 72 / 8)*
- [x] Deliberate negative test: inject a broken relative link (e.g. a stale `Logos/Core/...` path)
      into one `.lean` docstring, observe `FAIL C32` **and** a non-zero script exit; revert;
      observe `PASS C32` and exit 0. *(completed: Commands.lean -> Logos/Core/Automation/Commands.lean in Tactics/Search.lean gave FAIL C32 + exit 1; revert gave PASS + exit 0)*
- [x] Commit the green result. *(completed)*

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: research measured 80 naive matches / 72 false positives, collapsing to 8
real links (all currently resolving, all in `FormalSystem/Automation/Tactics/Search.lean`,
`.../UserTactics.lean`, `FormalSystem/Tactic/Meta.lean`) once the path-shaped filter is applied.
Confirm by printing the filtered link count on the first run and checking it against 8; a
materially larger number means the filter is too loose and must be tightened before the gate is
wired, and a materially smaller one means it is too tight and is hiding real links.

**Files to modify**:

- `scripts/check-module-invariants.sh` — new `ENFORCE_C32` flag, new C32 block, header-comment
  check list entry.

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` prints `PASS C32` with a filtered link
  count consistent with the Scope Hypothesis; harness exit 0.
- Negative test produced `FAIL C32` + non-zero exit; revert restored `PASS` + exit 0. Both
  recorded.
- Zero findings reported from the `Kamp/NfMultiAnchorBridge/` subtree (the false-positive source).

---

### Phase 3: `--recompute` idempotency selftest and its blind-spot fixture [COMPLETED]

**Goal**: Turn the manually-verified `--recompute` idempotency into a re-runnable, asserted
property, and encode the one known blind spot as a tested, documented limitation.

**Tasks**:

- [x] Re-read `scripts/reanchor-lean-citations.py` immediately before editing. *(completed)*
- [x] Add `selftest 3: double-run then --recompute` to the existing `selftest()` function,
      following selftest 2's snapshot/restore discipline exactly (snapshot every citer it will
      touch; restore in a `finally`; skip cleanly when the working tree carries modified `.lean`
      files, as selftests 1 and 2 already do). *(completed)*
- [x] The probe sequence, mirroring the reproduction research performed by hand: insert 3 padding
      lines into the probe file's leading docstring → run the Δ pass over it **twice** → assert the
      doubled shift is observed (`+6` where `+3` is correct) → run `recompute()` → assert every
      citation is back at exactly `+3` → run `recompute()` again → assert it reports 0 citation
      lines across 0 citer files. *(completed: observed 72 citations at +6, then 72 lines across 19 citers recomputed to +3, then 0 across 0)*
- [x] Add `selftest 4: recompute's content-edit blind spot` — a citer line that is *also*
      content-edited in the same batch as the double-shift is asserted to be left **un-repaired**,
      with the printed line naming it as the tool's stated refuse-rather-than-guess behaviour.
      This asserts the documented limitation; it is not a failure. *(completed: ChronicleMonadicBridge.lean:769 left at +6, the 71 others repaired to +3)*
- [x] Update the module docstring's usage block and `recompute()`'s own docstring to name both new
      selftests. *(completed)*
- [x] Run `python3 scripts/reanchor-lean-citations.py --selftest` on a clean tree; all four probes
      green; confirm the tree is byte-identical afterwards (`git status --porcelain` clean). *(completed: exit 0, all four probes green, only the tool itself modified afterwards)*
- [x] Commit the green result. *(completed)*

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: research measured the probe file
(`FormalSystem/Metalogic/Expressiveness/Kamp/KPlusFaithful.lean`) as carrying 72 citations across
19 citer files, and observed `recomputed 72 citation line(s) across 19 citer file(s)` followed by
`recomputed 0 ... across 0 ...`. Confirm these exact counts at implementation time from the
selftest's own output; if the counts have drifted (a sibling task or an intervening commit changed
the file), the assertion must be on the *property* (second run is a no-op) rather than on the
literal numbers.

**Files to modify**:

- `scripts/reanchor-lean-citations.py` — `selftest()` gains probes 3 and 4; module and
  `recompute()` docstrings updated.

**Verification**:

- `python3 scripts/reanchor-lean-citations.py --selftest` exits 0 with all four probes reporting
  green.
- The second `--recompute` inside probe 3 reports `0 citation line(s) across 0 citer file(s)` —
  the dispatch's "empty second diff" acceptance criterion, now asserted by a command.
- `git status --porcelain` is clean after the selftest run (every probe restored what it touched).

---

### Phase 4: C20 third assertion — declaration-span cross-check [COMPLETED]

**Goal**: A `file.lean:NNN` citation carrying an adjacent declaration name is checked against the
declaration span actually containing that line; the tree-wide residual count of name-less
citations is printed at every gate.

**Tasks**:

- [x] Re-read `scripts/check-module-invariants.sh` immediately before editing. *(completed)*
- [x] Add a third assertion to the existing C20 block (same block, same `CITE` regex, same
      `resolve()` — **reuse, never re-derive**, or the two resolvers will silently diverge on an
      ambiguous basename). *(completed: the reading itself lives in a new scripts/lib/lean_citations.py, imported by C20 and by the re-anchor tool; C20 passes it its own CITE and resolve)*
- [x] Extract the adjacent declaration name from a citation site: a backtick-quoted identifier
      immediately preceding the `(File.lean:NNN` parenthetical, widened to recognise a name stated
      earlier in the same sentence (the `PriorExpressivenessDense.lean:91` shape). A citation with
      no recoverable name is **residual**, not a failure. *(completed: name chain = backticked identifiers immediately before the citation; any name in the sentence can PASS, only the chain can FAIL)*
- [x] Implement declaration-span resolution in the target file: locate the named declaration using
      C15's second-assertion logic (comment-depth-aware `code[]` mask, `DECL` regex, walk backward
      past `@[...]` attributes to the leading `/--`), then extend forward to the span's end (next
      top-level declaration, or end of file). Span start = the doc comment's opening line. *(completed)*
- [x] A named citation PASSES when its line falls anywhere inside the named declaration's span;
      FAILS when the line falls inside a *different* declaration's span; is reported
      **unverifiable** (INFO, not a failure) when the name resolves to no declaration in the target
      file or to several — never guessed. *(completed)*
- [x] Print the tree-wide residual as a `TODO C20` line: `N of M file.lean:NNN citations carry no
      declaration name`, on the `ENFORCE_C16_ROOTS` / `ENFORCE_C9_DOCS` precedent — visible at
      every gate, never holding the gate hostage. *(completed: measured 164 of 1028 name-less)*
- [x] Gate the named-citation assertion under `ENFORCE_C20_DECL=${ENFORCE_C20_DECL:-1}` if the
      tree is clean on first run; if it is not, ship reporting-only with the flag defaulted to 0,
      record the measured count, and say so explicitly in the phase's completion note rather than
      widening the span definition until it goes green. *(deviation: altered — first run was NOT clean: 327 named citations (310 + 17 continuations) already land outside the declaration they name. Shipped ENFORCED against a recorded baseline scripts/c20-declaration-baseline.txt (the scripts/nolints.json model) rather than report-only, so a new mismatch fails today; the span definition was not widened)*
- [x] Pin `PriorExpressivenessDense.lean:91 -> KPlusFaithful.lean:479, :524` as the regression
      case: both must resolve under the chosen span definition. *(completed: both lines resolve, and the case is pinned inside the block)*
- [x] Deliberate negative test: retarget one name-carrying citation to a line inside a *different*
      declaration's span (the double-shift shape C20 tier 1 cannot see), observe `FAIL` and a
      non-zero script exit; revert; observe `PASS` and exit 0. *(completed: first attempt on the pinned citation did NOT fail — it has no name chain, so retargeting made it residual (877 -> 876 named), a recorded limit of the design; KMinusFaithfulRendering.lean:85 retargeted 393 -> 300 gave FAIL C20 + exit 1; revert gave PASS + exit 0)*
- [x] Commit the green result. *(completed)*

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: 1028 resolvable `file.lean:NNN` citations tree-wide with 0 unverifiable
(C20's own recorded baseline); of the three named worst-shift files, 38 of 72, 15 of 27 and 0 of 2
citations already carry an adjacent declaration name under a narrow backtick-adjacency measure —
itself a conservative undercount, since the widened extraction above should recognise more.
Confirm all five numbers from the new assertion's own printed output at implementation time;
record the measured name-carrying and residual counts rather than assuming the research figures
still hold.

**Files to modify**:

- `scripts/check-module-invariants.sh` — C20 block gains a third assertion, a residual-count
  `TODO` line, and (conditionally) an `ENFORCE_C20_DECL` flag; C20's header comment documents the
  span definition and why the exact-`theorem`-line reading was rejected.

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` prints all three C20 assertions; tier 1
  still reports 1028 resolvable / 0 unverifiable; harness exit 0.
- The pinned `:479` / `:524` regression case resolves (does not fail).
- Negative test produced a `FAIL` line **and** a non-zero exit; revert restored `PASS` and exit 0.
- The residual `TODO` line prints a concrete count.

---

### Phase 5: Convert the worst-shifted files' citations to name-carrying form [COMPLETED]

**Goal**: Convert citations into the three named worst-shift files to name-carrying form and record
the per-file residual honestly, as the dispatch explicitly authorises.

**Tasks**:

- [x] Enumerate, from Phase 4's own output, every name-less citation pointing into
      `FormalSystem/Syntax/Formula.lean`, `FormalSystem/Theorems/DerivedAxioms.lean` and
      `FormalSystem/Metalogic/Expressiveness/Kamp/KPlusFaithful.lean`, grouped by citer file. *(completed: confirmed set was NOT the hypothesised ~48: Formula.lean 3 mismatched + 10 name-less, KPlusFaithful.lean 1 name-less, and the plan's Theorems/DerivedAxioms.lean is not a citation target at all (the tree cites ProofSystem/DerivedAxioms.lean: 1 pass, 1 unverifiable))*
- [x] Re-read each citer file immediately before editing it. *(completed)*
- [x] For each, add the declaration name that the cited line actually falls within (as resolved by
      Phase 4's span logic), keeping the `file.lean:NNN` anchor alongside the name — the citation
      becomes checkable, it does not lose its pointer. *(deviation: altered — scope widened from the three named files to every named mismatch in the tree, because Phase 4 found the defect is tree-wide: one --by-name pass re-pointed 315 citations across 68 citer files, 1 collapsed continuation and 1 false positive were fixed by hand, and 9 name-less citations into Formula.lean / KPlusFaithful.lean were given names)*
- [x] Prefer line-count-neutral edits. If any edit changes a line count in a cited file, run
      `python3 scripts/reanchor-lean-citations.py --recompute` **once** at the end of the batch —
      never a second Δ pass, never interleaved with the edits. *(completed: every edit is line-count-neutral (git diff --numstat shows equal insertions and deletions for all 69 .lean files), so no --recompute was needed)*
- [x] Leave a citation whose span cannot be resolved unambiguously **unconverted** and count it in
      the residual; do not guess a name. *(completed: 10 mismatches whose name chain singles out no declaration stay on scripts/c20-declaration-baseline.txt; 2 citations of the form `Formula.kPlus P` stay name-less)*
- [x] Record the per-file residual (name-less citations remaining) and the tree-wide residual in
      the phase's completion note, for the summary to carry forward. *(completed: per-file name-less residual: Formula.lean 2 of 29, KPlusFaithful.lean 0 of 81, ProofSystem/DerivedAxioms.lean 0 of 2 (1 unverifiable); tree-wide 155 of 1028 name-less, 40 unverifiable, 10 recorded mismatches)*
- [x] After the batch: `bash scripts/check-module-invariants.sh --no-build` green, C20 tier 1 still
      1028 resolvable / 0 unverifiable, C19 coverage still above its floor. *(completed: exit 0; tier 1 1028 / 0; C19 94.01%)*
- [x] Commit the green result. *(completed)*

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the conversion set is hypothesised as 34 (72 − 38) + 12 (27 − 15) + 2
(2 − 0) ≈ 48 citations across roughly 20 citer files, against a tree-wide total of 1028. Confirm
the real set from Phase 4's printed residual breakdown before starting, not from these figures.
If the confirmed set materially exceeds this estimate, convert the highest-count citer files first
and close the phase as `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` table
naming the unconverted remainder and its evidence — driving 1028 to zero is explicitly out of
scope.

**Files to modify**:

- Citer `.lean` files under `FormalSystem/` carrying citations into the three named targets
  (the precise list is Phase 4's output, not a plan-time assertion).
- Possibly `FormalSystem/Syntax/Formula.lean`, `FormalSystem/Theorems/DerivedAxioms.lean`,
  `FormalSystem/Metalogic/Expressiveness/Kamp/KPlusFaithful.lean` themselves, where they cite each
  other.

**Verification**:

- Every converted citation is name-carrying and passes Phase 4's span assertion.
- C20 tier 1 unchanged at 1028 resolvable / 0 unverifiable — the conversion re-staled nothing.
- Per-file and tree-wide residual counts recorded.
- `bash scripts/check-module-invariants.sh --no-build` exit 0.

---

### Phase 6: Documentation rows, pointers, and full acceptance run [COMPLETED]

**Goal**: Land the `MODULE_INVARIANTS.md` rows and the `REFERENCE_NORMAL_FORM.md` pointer, and
run the build-inclusive harness for the final acceptance evidence.

**Tasks**:

- [x] Re-read `docs/development/MODULE_INVARIANTS.md` and
      `docs/development/REFERENCE_NORMAL_FORM.md` immediately before editing. *(completed)*
- [x] Add `| C31 (enforced) | ... |` and `| C32 (enforced) | ... |` rows to
      `MODULE_INVARIANTS.md`'s `## What It Checks` table, in that file's established
      what-it-checks / why-it-exists voice: name the historical evidence (the two bibkeys that
      dangled undetected, the 37 broken docstring links of which 16 were stale `Logos/Core/`
      paths), the `Boneyard/` exclusion, the `sub:`-out-of-scope note, and — for C32 — why the
      path-shaped filter is load-bearing. *(completed)*
- [x] Extend the existing C20 row to describe the third (declaration-span) assertion and the
      residual `TODO` line, including why "the declaration at that line" is a *span* and not the
      exact keyword line. *(deviation: altered — MODULE_INVARIANTS.md had no C20 row to extend, so a C20 row covering all three assertions was added)*
- [x] Add a paragraph to `MODULE_INVARIANTS.md`'s `## Adding a Check` section recording each new
      check's deliberate negative test — what was injected, that both the `FAIL` line and the
      non-zero exit were observed, and that the revert restored `PASS` and exit 0 — matching the
      C15/C24/C25/C26 entries already there. *(completed)*
- [x] Update `MODULE_INVARIANTS.md`'s header check-list and the harness's own header comment so
      both enumerate C31 and C32. *(deviation: altered — MODULE_INVARIANTS.md carries no header check list; the harness's own header comment was updated in Phases 1, 2 and 4)*
- [x] Add the pointer from `REFERENCE_NORMAL_FORM.md`: §2 "Bibliographic" gains "C31 gates this"
      beside its existing `comm` one-liner; §2 "Module cross-reference" and §4 gain the C20
      third-assertion and `--selftest` probe-3/4 references; §4's "The tool is not idempotent"
      paragraph is corrected to distinguish the Δ pass (not idempotent) from `--recompute`
      (idempotent, now asserted by selftest 3). *(completed)*
- [x] Add rows to `REFERENCE_NORMAL_FORM.md` §5's recorded-baselines table: C31 (0 dangling, N
      advisory unused), C32 (0 broken, N filtered links), C20 third assertion (0 mismatched named
      citations, N residual name-less). *(completed)*
- [x] Run `bash scripts/check-module-invariants.sh` (build-inclusive) and record the result. *(completed: exit 0, ALL CHECKS PASSED; lake build 2651 jobs green)*
- [x] Run `bash scripts/readme-lint.sh` and `bash scripts/typst-sync-check.sh`; confirm their
      recorded baselines (21 broken references; 9 Check-1 violations; 0 on Checks 2/2b/3) are
      unchanged — this task must not move them in either direction. *(completed: 21 broken references; 9 Check-1 violations; 0 on Checks 2/2b/3 — all unchanged)*
- [x] Commit. *(completed)*

**Timing**: 1.5 hours

**Depends on**: 1, 2, 3, 4, 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the baseline numbers written into `REFERENCE_NORMAL_FORM.md` §5 are asserted
values that a future sweep will hold constant, so each must be taken from the final harness run's
own output in this phase — never copied forward from this plan or from the research report.

**Files to modify**:

- `docs/development/MODULE_INVARIANTS.md` — C31/C32 rows, extended C20 row, `Adding a Check`
  negative-test paragraphs, header check list.
- `docs/development/REFERENCE_NORMAL_FORM.md` — §2 and §4 pointers, §4 idempotency correction, §5
  baseline rows.
- `scripts/check-module-invariants.sh` — header comment check list (C31, C32; C20 third
  assertion).

**Verification**:

- `bash scripts/check-module-invariants.sh` (build-inclusive) exits 0 with `ALL CHECKS PASSED`.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports zero byte changes
  (the `INV` baseline).
- `readme-lint.sh` and `typst-sync-check.sh` baselines unchanged.
- No task-number reference appears in any file outside `specs/**` (the deliverables here are
  `docs/**` and `scripts/**`, both bound by the no-task-references rule; cite durable anchors such
  as `REFERENCE_NORMAL_FORM.md` or a check ID instead).

---

## Testing & Validation

- [x] `bash scripts/check-module-invariants.sh --no-build` exits 0 after every phase. *(completed)*
- [x] `bash scripts/check-module-invariants.sh` (build-inclusive) exits 0 with `ALL CHECKS PASSED`
      at the close. *(completed)*
- [x] C31 observed to FAIL (line **and** non-zero exit) on an injected dangling bibkey, and to PASS
      again after revert. *(completed)*
- [x] C32 observed to FAIL (line **and** non-zero exit) on an injected broken relative link, and to
      PASS again after revert. *(completed)*
- [x] C20's third assertion observed to FAIL (line **and** non-zero exit) on a citation retargeted
      into a different declaration's span — the double-shift shape tier 1 cannot see — and to PASS
      again after revert. *(completed)*
- [x] `python3 scripts/reanchor-lean-citations.py --selftest` exits 0 with all four probes green;
      probe 3's second `--recompute` reports 0 citation lines across 0 citer files. *(completed)*
- [x] C20 tier 1 still reports 1028 resolvable citations and 0 unverifiable. *(completed)*
- [x] Residual name-less citation count recorded — per file for the three named targets, and
      tree-wide. *(completed)*
- [x] `readme-lint.sh` (21 broken references) and `typst-sync-check.sh` (9 Check-1 violations; 0 on
      Checks 2/2b/3) baselines unchanged. *(completed)*
- [x] `--emit-inventory --check` reports zero byte changes. *(completed)*

## Artifacts & Outputs

- `plans/01_citation-gates-bibkeys-links.md` (this file)
- `summaries/01_citation-gates-bibkeys-links-summary.md` (at completion)
- `scripts/check-module-invariants.sh` — C31, C32, C20 third assertion, residual `TODO` line,
  `ENFORCE_C31` / `ENFORCE_C32` (and conditionally `ENFORCE_C20_DECL`) flags
- `scripts/reanchor-lean-citations.py` — `--selftest` probes 3 and 4
- `docs/development/MODULE_INVARIANTS.md` — C31/C32 rows, extended C20 row, negative-test record
- `docs/development/REFERENCE_NORMAL_FORM.md` — §2/§4 pointers, §4 idempotency correction, §5
  baseline rows
- Converted citer `.lean` files under `FormalSystem/` (Phase 5; exact list is Phase 4's output)

## Rollback/Contingency

Each phase commits only when its own verification is green, so the rollback unit is a phase, not
the task. Recovery ladder, in order:

1. **Fix forward.** A failing new check on the current tree is either a real defect (fix the
   citation) or a too-strict check (fix the check). Never flip an `ENFORCE_` flag to 0 to make a
   gate pass — `MODULE_INVARIANTS.md` names that prohibition explicitly, and it is the single most
   likely wrong turn in this task.
2. **Narrow the phase.** If Phase 4's span definition cannot be made green on the current tree,
   ship the assertion reporting-only with its flag defaulted to 0, record the measured count, and
   say so — do not widen the span until the count reaches zero, which would produce a check that
   passes on everything. If Phase 5's confirmed conversion set materially exceeds its hypothesis,
   close the phase `[COMPLETED WITH EXCLUSIONS]` with the required `#### Reasoned Exclusions`
   table.
3. **Revert the phase's commit.** `git revert <sha>` for a committed phase; this leaves history
   intact and is safe on a shared working tree carrying sibling tasks' in-flight edits.
4. **Snapshot-then-rollback**, only for a genuine whole-tree rollback of uncommitted work. Take
   the snapshot first — see `context/contracts/recovery.md`'s rollback rung for the exact
   invocation shape, including its out-of-scope override flag — and only then run the destructive
   command. For an ordinary defensive checkpoint before the riskiest step (Phase 5's multi-file
   citer edits), use the non-reverting `--no-revert` checkpoint form instead; see
   `context/patterns/checkpoint-before-overflow.md`.

A dirty working tree on this cycle may carry a sibling task's edits (614, 637, 644). Never run a
whole-tree destructive command to recover this task's phase; revert this task's own commit or
re-edit this task's own files.
