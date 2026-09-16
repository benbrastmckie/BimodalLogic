# Implementation Plan: Task #579

- **Task**: 579 - Nest MinusLanguage/, PlusLanguage/, StarLanguage/ under Syntax/
- **Status**: [IMPLEMENTING]
- **Effort**: 5.25 hours
- **Dependencies**: None
- **Research Inputs**: specs/579_nest_minuslanguage_pluslanguage_starlang/reports/01_nest-language-family-under-syntax.md
- **Artifacts**: plans/01_nest-language-family-under-syntax.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Physically nest `FormalSystem/MinusLanguage/`, `FormalSystem/PlusLanguage/` and
`FormalSystem/StarLanguage/` under `FormalSystem/Syntax/`, so the language family is discoverable
from the base language, and close the boxdot-discoverability gap with a `Language family` section
in `FormalSystem/Syntax/README.md`. This is a module-path rename only: every declaration, proof
and namespace is preserved verbatim, so no `sorry` can be introduced and the C14 axiom baseline is
untouched. Done means `lake build` green, `scripts/check-module-invariants.sh` green (including
C8 extended to walk `FormalSystem/Syntax`), `scripts/readme-lint.sh` green, and a `git diff`
showing zero changes inside any proof term or tactic block.

### Research Integration

The research report (`reports/01_nest-language-family-under-syntax.md`) is integrated as follows,
and it corrects the dispatch description in four places that materially change the phase plan:

- **Blast radius is 41 import lines across 26 `.lean` files**, not the description's 24 files.
  Phase 2 is sized against the measured figure.
- **No import cycle exists** — the three trees depend on `Syntax` *leaf* modules
  (`Syntax.Atom`, `.Formula`, `.Context`), never the `FormalSystem.Syntax` aggregator — so the
  ADR-006 obstruction does not apply here.
- **Scope item 4 (C8) carries a hidden prerequisite.** Adding `"FormalSystem/Syntax"` to C8's
  `parent` tuple at `scripts/check-module-invariants.sh:947` makes C8 walk every Lean-bearing
  subdirectory of `Syntax/`, which today includes `SubformulaClosure/` — and
  `FormalSystem/Syntax/SubformulaClosure.lean` does not exist (confirmed: `Syntax/` holds
  `Atom.lean`, `BigConj.lean`, `Context.lean`, `Formula.lean`, `Subformulas.lean`, `README.md`,
  `SubformulaClosure/`). C8 is enforced by default (`ENFORCE_C8=${ENFORCE_C8:-1}`,
  `check-module-invariants.sh:510`), so item 4 alone turns a green C8 red. This is Phase 1.
- **Scope item 3's premise is false.** `FormalSystem/MinusLanguage/README.md` already exists;
  the actual defect is the stale `| MinusLanguage/ | No | ... (no README yet) |` row and the
  absent `StarLanguage/` row in `FormalSystem/README.md`'s Submodule Navigation table. Item 3 is
  reinterpreted accordingly in Phase 4. (The table's `ForMathlib/ | No` row was re-checked against
  the filesystem and is accurate — `FormalSystem/ForMathlib/` contains only `Order/` — so the
  dispatch's ForMathlib carve-out stands.)

Two further research decisions are adopted verbatim and are non-negotiable constraints on
Phase 2: **namespaces stay flat** (`FormalSystem.MinusLanguage`, not
`FormalSystem.Syntax.MinusLanguage`; renaming would touch 103 sites plus the C14 baseline), and
**`FormalSystem/Syntax.lean` must not import the three nested aggregators** (that would make the
15 bare `import FormalSystem.Syntax` consumers transitively elaborate `Theorems/` and
`Metalogic/Core/`; C8 does not require a parent-to-child aggregator import).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context. `specs/ROADMAP.md` exists
but contains no item naming `MinusLanguage/`, `PlusLanguage/`, `StarLanguage/`, or this nesting;
this task originates from `specs/reviews/review-2026-09-15.md` Finding H1, not from the roadmap.

## Goals & Non-Goals

**Goals**:
- `FormalSystem/{Minus,Plus,Star}Language/` and their three sibling aggregators live under
  `FormalSystem/Syntax/`, with file history preserved (`git mv`).
- All 41 `import FormalSystem.{Minus,Plus,Star}Language.*` lines resolve at the new paths;
  `lake build` is green.
- C8 enforces the aggregator convention on `FormalSystem/Syntax` subdirectories, with the
  `SubformulaClosure.lean` prerequisite in place so the extension lands green.
- `FormalSystem/Syntax/README.md` carries a `Language family` section that names `stab`/`⊡`
  explicitly, so a reader searching for boxdot finds `Syntax/PlusLanguage/` instead of
  re-deriving it.
- The documentation surface (C5 tokens, C12/C13 paths and links, readme-lint relative
  references, `FormalSystem/README.md` tables, the three generated inventory blocks) is
  consistent with the new layout.
- No theorem statement, proof term, tactic block, or namespace is changed.

**Non-Goals**:
- Renaming namespaces to match the new module depth (explicitly rejected; see Research
  Integration).
- Adding the nested aggregators to `FormalSystem/Syntax.lean` (explicitly rejected).
- Creating `FormalSystem/ForMathlib/README.md` or moving `ForMathlib/` (out of scope per the
  dispatch; the table row describing it is accurate as-is).
- Archiving `MinusLanguage/` or `StarLanguage/` to `Boneyard/` — the review established both fail
  the admission criteria and must stay live.
- Writing an ADR. ADR-006 declined a different, larger move (339 import lines, 137 files, a live
  cycle); the contrast is already recorded in the review.
- Any proof-content change, new axiom, or new `sorry`.

## Lean Challenge Statements

This plan commits to **no new or changed Lean declarations**. The `- **Goals**:` bullets above
name zero theorem identifiers, so the identifier set this section must match is empty, and no
```lean``` block is emitted. This is deliberate and is the correct content for a `lean4` plan
whose entire Lean-side change is module paths and import lines: pinning a statement here would
assert a declaration the plan has no business creating. Proof-level assurance comes from
`lake build` plus the explicit no-proof-content-change diff audit in Phase 7.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 3 (C8 parent tuple) executed before Phase 1 turns a green C8 red | M | M | Hard dependency: Phase 3 `Depends on: 2`, which depends on 1. Phase 1's verification explicitly re-runs C8 |
| Blanket `FormalSystem.MinusLanguage` -> `FormalSystem.Syntax.MinusLanguage` search-and-replace corrupts 103 namespace sites and the C14 `#print axioms` baseline | H | M | Phase 2 restricts rewriting to lines beginning `import `; Phase 4 restricts markdown rewriting to the 9 enumerated C5 tokens. Phase 7 greps for any surviving `namespace FormalSystem.Syntax.{Minus,Plus,Star}Language` and for `open`-line drift |
| Doc sweep left half-done: `lake build` green while C5/C12/C13 red | M | M | Phases 4/5/6 each carry their own gate run; no phase closes on `lake build` alone |
| Stale aggregator left at `FormalSystem/MinusLanguage.lean` — C8 does not check sibling-to-directory, so it would pass C8 | M | L | Phase 2 verification diffs `ls FormalSystem/*.lean` against the recorded pre-move listing; C4 catches the dangling imports |
| `git mv` not used, losing history for 14 files | L | M | Phase 2 mandates `git mv` in step text and verifies with `git status --short` showing `R` (rename) entries |
| Pre-existing `FAIL C13` misread as caused by this task | L | M | Baseline recorded below and in the research report; Phase 4 repairs it explicitly and separately-committed |
| Proof content silently altered by an editor-wide reformat | H | L | Phase 7 runs `git diff -M --stat` plus a content-preservation check that the moved files' bodies are byte-identical apart from `import` lines |

**Recorded baseline (measured 2026-09-15, before any change)**:

| Gate | Baseline |
|------|----------|
| `lake build` | PASS (2651 jobs, exit 0) |
| `scripts/check-module-invariants.sh --no-build` | **FAIL**, exit 1 — sole failure `C13: 2 unresolved relative markdown link(s)` |
| `scripts/readme-lint.sh` | PASS (56 READMEs, 0 missing, 0 broken references) |

**Decision on the pre-existing C13 failure** (recorded here rather than raised to the user): the
two dangling links are `README.md:336` and `docs/README.md:308`, both pointing at
`.github/workflows/docs.yml`, which commit `9bcbe9e41` renamed to `docs.yml.disabled`. The
dispatch's verify criterion is "`scripts/check-module-invariants.sh` passes", which is
unreachable while they stand. Phase 4 repairs them in a separate, separately-committed step
labelled as a pre-existing defect, so the task's own diff stays auditable. If strict scope
containment is preferred instead, the fallback is to leave them and assert "no *new* invariant
failures" against the baseline above — but the plan proceeds with the repair.

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 3, 6 |

Phases within the same wave can execute in parallel. Phases 3 and 4 touch disjoint files
(`scripts/check-module-invariants.sh` vs. markdown plus
`scripts/module-invariants-allowlist.txt`), so the wave-3 parallelism is a real territory split,
not a nominal one.

---

### Phase 1: SubformulaClosure aggregator prerequisite [COMPLETED]

**Goal**: Give `FormalSystem/Syntax/SubformulaClosure/` the sibling aggregator C8 will demand
once `FormalSystem/Syntax` joins its `parent` tuple, before anything moves.

**Tasks**:
- [x] Create `FormalSystem/Syntax/SubformulaClosure.lean` importing the four leaf modules
      (`Closure`, `NestingDepth`, `TemporalFormulas`, `IteratedTemporal`), with the standard
      copyright header and a module docstring matching the style of the other aggregators.
- [x] Repoint `FormalSystem/Syntax.lean`: replace its four
      `import FormalSystem.Syntax.SubformulaClosure.*` lines with the single
      `import FormalSystem.Syntax.SubformulaClosure`.
- [x] Confirm the new module is reachable (so C6/C7 do not report it as an unreachable module
      needing a manifest entry).

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: `SubformulaClosure/` is asserted to contain exactly four leaf modules
(`Closure.lean`, `IteratedTemporal.lean`, `NestingDepth.lean`, `TemporalFormulas.lean`) and to be
the only Lean-bearing subdirectory of `Syntax/` lacking a sibling aggregator. Confirm at
implementation time with `ls FormalSystem/Syntax/SubformulaClosure/` and
`for d in FormalSystem/Syntax/*/; do test -f "${d%/}.lean" || echo "missing: ${d%/}.lean"; done`
before writing the file.

**Files to modify**:
- `FormalSystem/Syntax/SubformulaClosure.lean` - NEW aggregator importing the four leaf modules
- `FormalSystem/Syntax.lean` - four leaf imports collapsed to one aggregator import

**Verification**:
- `lake build` exits 0. *(deviation: altered — verified with the scoped
  `lake build FormalSystem.Syntax` (guarded, detached; exit 0, 712 jobs) rather than a full
  `lake build`, because the concurrent task-580 dispatch has `FormalSystem/Semantics/` in an
  intermediate state. `FormalSystem.Syntax` does not import `FormalSystem.Semantics`, so the
  scoped build covers every module this phase can affect.)*
- `ENFORCE_C8=1 bash scripts/check-module-invariants.sh --no-build` shows `PASS C8` (still green;
  this phase does not yet extend the tuple). *(confirmed: PASS C8)*
- No new `sorry`: `grep -rn '\bsorry\b' FormalSystem/Syntax/SubformulaClosure.lean` is empty.

---

### Phase 2: The move [COMPLETED]

**EXEMPTION GRANTED** (Phase 2, 2026-09-15): this phase was briefly `[BLOCKED]` because 4 of
its 41 import lines live under `FormalSystem/Semantics/`, which the dispatch note placed
off-limits to protect a concurrent task-580 dispatch. The orchestrator granted a narrow
exemption for exactly those 4 import-prefix edits, recording that the "do not edit files under
FormalSystem/Semantics/" wording was an over-narrow territory guess authored before the 41-line
blast radius was known, and that lifting it restores this plan's own Phase 2 scope rather than
widening the task. The grant is recorded durably in
`specs/579_nest_minuslanguage_pluslanguage_starlang/.decisions.json`. Task 580 separately probed
and dropped its own planned `PlusTruth.lean` edit as unnecessary, so that line was uncontested.
Line-scoped `sed` was used regardless, and the diff on all four files shows exactly one prefix
change each and nothing else.

**Authorized and applied, exactly**:
- `FormalSystem/Semantics/MinusFrame.lean:7`, `MinusTruth.lean:8` — `import FormalSystem.Syntax.MinusLanguage.Formula`
- `FormalSystem/Semantics/PlusTruth.lean:8` — `import FormalSystem.Syntax.PlusLanguage.Formula`
- `FormalSystem/Semantics/StarTruth.lean:8` — `import FormalSystem.Syntax.StarLanguage.Formula`

Task 580's own import insertions (`Semantics.lean:26`, `Validity.lean:8`, `ShiftSet.lean:9`,
`Metalogic/Decidability/BiLasso/Unfold.lean:8`) were NOT touched by this task.

**Goal**: Relocate the three directories and their three aggregators under
`FormalSystem/Syntax/`, rewriting every import line, with proof content and namespaces byte-identical.

**Tasks**:
- [x] Record the pre-move listing: `ls FormalSystem/*.lean > /tmp/pre-move-aggregators.txt`.
- [x] `git mv FormalSystem/MinusLanguage FormalSystem/Syntax/MinusLanguage` (and likewise
      `PlusLanguage`, `StarLanguage`) — `git mv`, never `mv`, so rename detection preserves history.
- [x] `git mv FormalSystem/MinusLanguage.lean FormalSystem/Syntax/MinusLanguage.lean` (and
      likewise the other two aggregators).
- [x] Rewrite every `import FormalSystem.{Minus,Plus,Star}Language` line to
      `import FormalSystem.Syntax.{Minus,Plus,Star}Language`, restricted to lines beginning with
      `import ` — never a bare token replacement, which would corrupt `open` lines and
      fully-qualified references.
- [x] Repoint the three aggregator imports inside `FormalSystem/FormalSystem.lean` to the new
      paths. Do **not** add them to `FormalSystem/Syntax.lean`.
- [x] Confirm no stale `FormalSystem/{Minus,Plus,Star}Language.lean` remains at the root.
- [x] Update the `../`-relative links inside the moved READMEs that gained a directory level
      (`FormalSystem/Syntax/MinusLanguage/README.md`, `.../PlusLanguage/README.md`, and
      `.../StarLanguage/README.md` if it carries any).

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: 41 import lines across 26 `.lean` files, comprising 14 lines internal to the
three moved trees (11 files), 13 lines in the three sibling aggregators, and 14 lines in 12
external consumers; zero import-line hits under `Tests/`. Confirm before and after with
`grep -rn '^import FormalSystem\.\(Minus\|Plus\|Star\)Language' --include='*.lean' . | wc -l`
(expect 41 before, 0 before-form after) and
`grep -rn '^import FormalSystem\.Syntax\.\(Minus\|Plus\|Star\)Language' --include='*.lean' . | wc -l`
(expect 41 after). A different count is a signal to stop and re-measure, not to proceed.

**Commit-mode rationale**: the rename and the 41 import rewrites cannot be split into individually
green sub-steps — every intermediate state between the first `git mv` and the last import rewrite
is expected red under `lake build`. The batch is pre-declared here as exactly: the three
directories, the three sibling aggregators, the 26 import-bearing `.lean` files, and the moved
READMEs' relative links. It must not be widened at implementation time.

**Files to modify**:
- `FormalSystem/{Minus,Plus,Star}Language/**` - moved to `FormalSystem/Syntax/` (content verbatim)
- `FormalSystem/{Minus,Plus,Star}Language.lean` - moved to `FormalSystem/Syntax/` (imports repathed)
- `FormalSystem/FormalSystem.lean` - three aggregator imports repathed
- `FormalSystem/Metalogic/Conservativity/Backward.lean`,
  `FormalSystem/Metalogic/Conservativity/Plus/{AxiomValidity,PlusSoundness}.lean`,
  `FormalSystem/Metalogic/Conservativity/Star/{StarAxiomValidity,StarSoundness}.lean`,
  `FormalSystem/Metalogic/Deterministic/System.lean`,
  `FormalSystem/Metalogic/Independence/NaiveSystem.lean`,
  `FormalSystem/Semantics/{MinusFrame,MinusTruth,PlusTruth,StarTruth}.lean` - import lines only
- `FormalSystem/Syntax/{Minus,Plus,Star}Language/README.md` - `../` link depth

**Verification**:
- `lake build` exits 0.
- `bash scripts/check-module-invariants.sh --no-build` shows `PASS C4` (no dangling imports).
- `ls FormalSystem/*.lean` diffed against `/tmp/pre-move-aggregators.txt` shows exactly the three
  aggregators removed and nothing else.
- `git status --short` shows `R` rename entries for the moved files (history preserved).
- `grep -rn 'namespace FormalSystem\.Syntax\.\(Minus\|Plus\|Star\)Language' --include='*.lean' .`
  is empty — namespaces stayed flat.
- `grep -n 'Language' FormalSystem/Syntax.lean` shows no nested-aggregator import was added.

---

### Phase 3: Extend C8 to FormalSystem/Syntax [COMPLETED]

**Goal**: Make the aggregator convention machine-enforced on the newly nested directories.

**Tasks**:
- [x] Add `"FormalSystem/Syntax"` to the `parent` tuple at
      `scripts/check-module-invariants.sh:947` (`for parent in ("FormalSystem",
      "FormalSystem/Metalogic"):`).
- [x] Update C8's `pas()` message, which currently reads "every FormalSystem/ and Metalogic/
      subdirectory has exactly one sibling aggregator", so the reported scope matches what is
      actually walked.
- [x] Update the C8 explanatory comment block above the loop if it enumerates the parents.

**Timing**: 0.25 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: extending the tuple brings exactly four `Syntax/` subdirectories into C8's
scope — `MinusLanguage/`, `PlusLanguage/`, `StarLanguage/` (aggregators arriving with them in
Phase 2) and `SubformulaClosure/` (aggregator created in Phase 1). Confirm with
`for d in FormalSystem/Syntax/*/; do echo "$d -> $(test -f "${d%/}.lean" && echo ok || echo MISSING)"; done`
— all four must read `ok` before the tuple is edited.

**Files to modify**:
- `scripts/check-module-invariants.sh` - `parent` tuple, C8 pass message, C8 comment

**Verification**:
- `ENFORCE_C8=1 bash scripts/check-module-invariants.sh --no-build` reports `PASS C8` and no new
  `TODO C8` lines.
- The only remaining failure is the pre-existing `FAIL C13` (repaired in Phase 4), matching the
  recorded baseline. *(deviation: altered — this expectation assumed Phase 4 had already run, as
  the wave table places 3 and 4 in the same wave. Executing depth-first per the phase-closure
  contract, Phase 3 closed before Phase 4, so `FAIL C5` (11), `FAIL C12` (16) and `FAIL INV`
  were also open at this point — the expected post-move documentation debt that Phases 4 and 6
  own, not a regression. `PASS C8` with zero `TODO C8` lines, this phase's actual subject, was
  met. Note `C6` now PASSES: task 580 manifested its `TruthTransport` module.)*

---

### Phase 4: Documentation and path sweep [NOT STARTED]

**Goal**: Bring every gated documentation reference in line with the new layout, and repair the
pre-existing C13 failure so the dispatch's verify criterion is reachable.

**Tasks**:
- [ ] Rewrite the five module-shaped C5 tokens at `docs/development/MODULE_ORGANIZATION.md:301-305`
      (`FormalSystem.MinusLanguage.{Formula,Axioms,Derivation,Translation,AxiomDischarge}`) to
      `FormalSystem.Syntax.MinusLanguage.*`.
- [ ] Rewrite the bare module-reading tokens (`docs/reference/API_REFERENCE.md:791`, read as a
      module heading) to the new path.
- [ ] Add the namespace-reading tokens (`NOTATION.md:49`, `docs/theorem-index.md:43-45`,
      `docs/development/NAMING_CONVENTION_DEVIATION.md:291`) to
      `scripts/module-invariants-allowlist.txt`, following that file's existing
      one-comment-per-entry convention (it already carries `FormalSystem.StarLanguage.StarAxiom`
      and `.StarDerivationTree` for exactly this reason).
- [ ] Fix `FormalSystem/README.md`'s Submodule Navigation table: repath
      `[PlusLanguage/](PlusLanguage/README.md)` to `Syntax/PlusLanguage/README.md`, replace the
      stale `| MinusLanguage/ | No | ... (no README yet) |` row with a linked
      `Syntax/MinusLanguage/README.md` row, and add the missing `StarLanguage/` row. Leave the
      `ForMathlib/ | No` row as-is (verified accurate).
- [ ] Fix the Layer 0 table (`FormalSystem/README.md:251-256, 265-267`), which lists
      `PlusLanguage` as a root-level module.
- [ ] Sweep the remaining slash-shaped `FormalSystem/{Minus,Plus,Star}Language` path references in
      `docs/` and root `README.md` that C12/C13 and readme-lint Check 3 gate.
- [ ] **Separate commit, labelled as a pre-existing defect**: repair `README.md:336` and
      `docs/README.md:308` to point at `.github/workflows/docs.yml.disabled` (or drop the link and
      state that the workflow is disabled).

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: 9 C5 tokens resolve today and will not after the move (5 module-shaped at
`MODULE_ORGANIZATION.md:301-305`, 4 bare across `NOTATION.md`, `API_REFERENCE.md`,
`theorem-index.md`, `NAMING_CONVENTION_DEVIATION.md`); 106 slash-shaped references exist across 57
non-`specs/` files, of which only the C12/C13/readme-lint-gated subset must change. Confirm at
implementation time with
`grep -rn 'FormalSystem\.\(Minus\|Plus\|Star\)Language' --include='*.md' . | grep -v '^./specs/'`
and
`grep -rn 'FormalSystem/\(Minus\|Plus\|Star\)Language' --include='*.md' . | grep -v '^./specs/' | wc -l`,
then let the gate output — not the estimate — decide when the sweep is complete.

**Files to modify**:
- `docs/development/MODULE_ORGANIZATION.md` - five module tokens (lines ~301-305)
- `docs/reference/API_REFERENCE.md` - module heading token (line ~791)
- `scripts/module-invariants-allowlist.txt` - namespace-reading entries with comments
- `FormalSystem/README.md` - Submodule Navigation table, Layer 0 table
- `README.md`, `docs/README.md` - C13 workflow-link repair (separate commit)
- Remaining `docs/` files surfaced by the C12/C13/readme-lint runs

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` reports `PASS C5`, `PASS C12`, `PASS C13`.
- `bash scripts/readme-lint.sh` exits 0 with `Broken file references: 0`.
- `grep -rn 'FormalSystem\.\(Minus\|Plus\|Star\)Language' --include='*.md' . | grep -v '^./specs/'`
  returns only allowlisted namespace readings.
- The C13 repair is its own commit, so the nesting diff is auditable independently.

---

### Phase 5: Language-family discoverability section [NOT STARTED]

**Goal**: Write the documentation that actually closes the boxdot gap, and correct the two
adjacent stale claims that would otherwise contradict it.

**Tasks**:
- [ ] Add a `## Language family` section to `FormalSystem/Syntax/README.md` with the measured
      constructor-delta table: `Syntax/` L `Formula` (`atom`, `bot`, `imp`, `box`, `untl`, `snce`);
      `Syntax/MinusLanguage/` L⁻ `MinusFormula` (`atom`, `bot`, `imp`, `box`, `allPast`,
      `allFuture`); `Syntax/PlusLanguage/` L⁺ `PlusFormula` (L's six + `stab`/`⊡`);
      `Syntax/StarLanguage/` L⋆ `StarFormula` (L⁺'s seven + `timeStore`/`↑ⁱ`,
      `timeRecall`/`↓ⁱ`).
- [ ] State plainly that **L ⊂ L⁺ ⊂ L⋆ is the extension chain, and L⁻ is not an extension of L** —
      it is a sibling variant with `H`/`G` primitive in place of `untl`/`snce`, related by
      `tr : MinusFormula → Formula` in `Syntax/MinusLanguage/Translation.lean`. The review's
      "one extension hierarchy" phrasing is false and must not be reproduced in the very section
      written to fix a discoverability problem.
- [ ] Name `stab` and `⊡` (and the word "boxdot") explicitly, with a pointer to
      `Syntax/PlusLanguage/`, so a future reader searching for boxdot lands on the existing,
      sorry-free implementation instead of rebuilding it.
- [ ] Correct `FormalSystem/Syntax.lean`'s module docstring, which lists the primitives as
      `atom, bot, imp, box, allPast, allFuture` — contradicting `Syntax/Formula.lean`
      (`untl`/`snce`) and `FormalSystem/README.md:71`. This is the same operator-delta confusion
      the new section exists to fix.
- [ ] Update `docs/development/MODULE_ORGANIZATION.md` §2, which asserts "Namespaces mirror
      directory structure" and names `Bimodal` as the root namespace — both false of the current
      tree. State the real convention (a nested subdirectory keeps its component's namespace) and
      cite the two pre-existing examples, `Syntax/SubformulaClosure/Closure.lean` (declares
      `namespace FormalSystem.Syntax`) and `Metalogic/Conservativity/Plus/Forward.lean` (declares
      `namespace FormalSystem.Metalogic.Conservativity`), alongside the three newly nested trees.

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the four constructor sets are asserted as 6 / 6 / 7 / 9 constructors. Confirm
each against its `Formula.lean` (`grep -n '  | ' FormalSystem/Syntax/Formula.lean` and the three
nested `Formula.lean` files) before writing the table — a table that miscounts is worse than no
table, since this section is the discoverability fix.

**Files to modify**:
- `FormalSystem/Syntax/README.md` - new `## Language family` section
- `FormalSystem/Syntax.lean` - module docstring primitive list corrected
- `docs/development/MODULE_ORGANIZATION.md` - §2 namespace convention

**Verification**:
- `lake build` exits 0 (the `Syntax.lean` docstring is a compiled `/-! -/` block).
- `bash scripts/readme-lint.sh` exits 0.
- `grep -in 'boxdot\|stab\|⊡' FormalSystem/Syntax/README.md` returns the new section — the
  discoverability claim is checkable, not assumed.
- `bash scripts/check-module-invariants.sh --no-build` reports `PASS C5` (new tokens resolve or
  are allowlisted).

---

### Phase 6: Regenerate inventory blocks [NOT STARTED]

**Goal**: Bring the generated inventory blocks in line with the new tree.

**Tasks**:
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory`.
- [ ] Review the diff: `README.md:17` (`dir=FormalSystem rows=totals desc=no`),
      `FormalSystem/README.md:240` (`dir=FormalSystem rows=loose`, loses the three root-level
      aggregator rows), and `FormalSystem/Syntax/README.md:7` (`dir=FormalSystem/Syntax`, gains
      three subdirectory rows).
- [ ] While in `FormalSystem/Syntax/README.md`, fix the hand-written description column's
      `SubformulaClosure/ ... (3 files)` — there are 4. The count sits outside the generated
      region, which is why INV does not catch it.
- [ ] Verify with `bash scripts/check-module-invariants.sh --emit-inventory --check`.

**Timing**: 0.25 hours

**Depends on**: 5

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: exactly three generated inventory blocks change (the three enumerated
above). Confirm with
`grep -rn 'BEGIN GENERATED: inventory' --include='*.md' . | grep -v '^./specs/'` and by inspecting
`git diff --stat` after the emit — a fourth changed block means the emit touched something this
plan did not anticipate and must be reviewed before committing.

**Files to modify**:
- `README.md` - generated inventory block (totals)
- `FormalSystem/README.md` - generated inventory block (loose rows)
- `FormalSystem/Syntax/README.md` - generated inventory block plus the `(3 files)` description fix

**Verification**:
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports `PASS INV`.
- `git diff --stat` shows only the three expected files.

---

### Phase 7: Full gate and no-proof-change audit [NOT STARTED]

**Goal**: Prove the whole change is green and that not one character of proof content moved.

**Tasks**:
- [ ] `lake build` from clean.
- [ ] `bash scripts/check-module-invariants.sh` (full, with build) — every check green, including
      the extended C8 and the repaired C13.
- [ ] `bash scripts/readme-lint.sh`.
- [ ] No-proof-change audit: `git diff -M --stat` over the whole task branch; for each moved
      `.lean` file confirm the only changed lines begin with `import ` (e.g.
      `git diff -M -- 'FormalSystem/Syntax/MinusLanguage/*' | grep '^[+-]' | grep -v '^[+-][+-]' | grep -vc '^[+-]import '`
      should be 0 for every moved tree).
- [ ] `grep -rn '\bsorry\b' FormalSystem/ --include='*.lean' | grep -v Boneyard` — unchanged from
      baseline (C3 zero-sorry preserved by construction).
- [ ] Confirm the namespace surface is untouched:
      `git diff -M -- '*.lean' | grep '^[+-]namespace\|^[+-]open '` is empty.
- [ ] Record in the summary that C13's two-line repair was a pre-existing defect, not a
      consequence of the nesting, citing the recorded baseline.

**Timing**: 0.5 hours

**Depends on**: 3, 6

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- None (verification only)

**Verification**:
- `lake build` exits 0 with the expected job count.
- `bash scripts/check-module-invariants.sh` exits 0.
- `bash scripts/readme-lint.sh` exits 0.
- The proof-content and namespace diff audits above return empty.

---

## Testing & Validation

- [ ] `lake build` exits 0 (baseline: 2651 jobs, exit 0).
- [ ] `bash scripts/check-module-invariants.sh` exits 0 — an improvement on the recorded baseline,
      which is `FAIL C13`. In particular: C4 (import resolution), C5 (markdown module paths), C8
      (aggregator convention, now covering `FormalSystem/Syntax`), C12/C13 (paths and links), INV
      (generated inventories), and C14 (axiom baseline, expected untouched).
- [ ] `bash scripts/readme-lint.sh` exits 0 with 0 missing READMEs and 0 broken references.
- [ ] `Tests/BimodalTest/` builds and passes — zero import-line hits were measured there, so any
      failure indicates an unexpected `open`-resolution change and must be investigated, not
      patched over.
- [ ] Zero new `sorry`; zero new axioms; zero namespace renames.
- [ ] `git log --follow` on one moved file per tree returns its pre-move history.

## Artifacts & Outputs

- `FormalSystem/Syntax/{MinusLanguage,PlusLanguage,StarLanguage}/` - the three moved trees
- `FormalSystem/Syntax/{MinusLanguage,PlusLanguage,StarLanguage}.lean` - the three moved aggregators
- `FormalSystem/Syntax/SubformulaClosure.lean` - new prerequisite aggregator
- `FormalSystem/Syntax/README.md` - new `## Language family` section (the discoverability fix)
- `FormalSystem/README.md` - corrected Submodule Navigation and Layer 0 tables
- `scripts/check-module-invariants.sh` - C8 `parent` tuple extended
- `scripts/module-invariants-allowlist.txt` - namespace-reading C5 entries
- `docs/development/MODULE_ORGANIZATION.md` - repathed module tokens, corrected §2
- `specs/579_nest_minuslanguage_pluslanguage_starlang/summaries/01_*-summary.md` - execution summary

## Rollback/Contingency

Every phase is committed separately, and Phase 2 is a single pre-declared atomic batch, so
rollback is per-commit: `git revert` the offending commit. A full rollback of the nesting is
`git revert` of the Phase 2 commit followed by the Phase 3-6 documentation commits, in reverse
order; Phase 1's `SubformulaClosure.lean` aggregator is independently valuable and can be kept.
Because no proof content is touched, a revert can never leave a `sorry` or a broken proof behind —
the worst failure mode is a stale import path, which C4 catches immediately.

If `lake build` cannot be made green within Phase 2, do not partially revert: the phase's
atomic-batch declaration means the correct recovery is `git checkout` of the whole pre-move state
(after `bash .claude/scripts/git-snapshot.sh 579`) and a re-measure, not an incremental repair of
a half-moved tree.
