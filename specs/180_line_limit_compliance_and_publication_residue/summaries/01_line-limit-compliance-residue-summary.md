# Implementation Summary: Line-Limit Compliance and Publication Residue

- **Task**: 180 - line_limit_compliance_and_publication_residue
- **Status**: [COMPLETED]
- **Type**: lean4
- **Plan**: `specs/180_line_limit_compliance_and_publication_residue/plans/01_line-limit-compliance-residue.md`
- **Research**: `specs/180_line_limit_compliance_and_publication_residue/reports/01_line-limit-compliance-residue.md`
- **Phases**: 8 of 8 complete

## Outcome

The live Lean tree is at **zero** `linter.style.longLine` violations, measured by codepoint:
**598 → 0 across 65 files**. `lake build` is green at 1883 jobs and `lake build BimodalTest` at
1923 jobs, both exit 0 with zero errors. No proof changed, no declaration was renamed, no
`sorry` or `axiom` was added, and no linter was silenced.

The diff is `65 files changed, 1324 insertions(+), 598 deletions(-)` — the 598 deletions are
exactly the 598 offending lines, each replaced by the fragments it was broken into.

## Before / After

| Area | Files | Before | After |
|---|---|---|---|
| `FormalSystem/Automation/` | 20 | 327 | **0** |
| `Tests/` | 24 | 231 | **0** |
| `FormalSystem/` other | 21 | 40 | **0** |
| **Total** | **65** | **598** | **0** |

## Acceptance Criteria

| # | Criterion | Result |
|---|---|---|
| 1 | `count_long_lines.py` = 0 total / 0 files | **0 / 0** — and the *same unchanged script* still reports **598 / 65** against a throwaway worktree of the pre-task commit `b3accb114` |
| 2 | `lake build` green, ≥ 1883 jobs, exit 0, zero errors | **green, 1883, exit 0, 0 errors** |
| 3 | `lake build BimodalTest` green, ≥ 1923 jobs, exit 0, zero errors | **green, 1923, exit 0, 0 errors** |
| 4 | Live `sorry` = exactly 1, `countermodel_discrete`, located by content | **1**, `countermodel_discrete`, `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` |
| 5 | Declaration inventory unchanged vs baseline | unchanged (`gate.py check` → GATE PASSED) |
| 6 | Sibling-owned frozen categories unchanged **by equality** | all seven identical: `(deprecation)` 6, `(rintro-try-this)` 15, `(sorry)` 1, `linter.defProp` 10, `linter.dupNamespace` 13, `linter.unusedSimpArgs` 3, `linter.unusedVariables` 14 |

Plus the project's own gate, `bash scripts/check-module-invariants.sh`, exits 0 with B0 and
C1-C10 all passing.

Criterion 1's second half is the load-bearing half. A zero from a broken counter is
indistinguishable from a zero from a clean tree, and that is precisely how this task's inherited
harness would have failed. Running the finished counter against the pre-task tree and getting
598 back proves the counter reached zero because the tree changed.

## The Two Verified-No-Work Records

Both were **verified at completion, not performed**. Each is reported with a positive control so
it cannot pass vacuously (`tools/publication_invariants.py`).

**Copyright headers — 331/331, no work performed.** Every live `.lean` file carries a
`Copyright` line within its first three lines. The task description's "277 of 277" was simply an
older, smaller denominator: the invariant held throughout, the file count grew. The plan's own
"330/330" was likewise one short — see the scope correction below.

**Universe polymorphism — the empty set, no work performed.** Zero `universe` declarations in
the live tree. This finding only exists because the check strips comments first: a raw
`grep -E '^\s*universe\s'` returns **3** hits, and all three are line-wrapped English prose
inside docstrings —

- `FormalSystem/Metalogic/Decidability/CountermodelExtraction.lean:166`
- `FormalSystem/Metalogic/SoundnessLemmas/Core.lean:30`
- `FormalSystem/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/ExteriorNegationK.lean:369`

— each a sentence that happens to wrap onto a line beginning with the word "universe". Related
and also unchanged: `FormalSystem/Semantics/` uses `Type*` in 34 places across 5 files, and
`Semantics/Validity.lean:77,101` document a *deliberate* monomorphization ("Uses `Type` (not
`Type*`) to avoid universe level issues in proofs"). No work was manufactured here.

## Harness Repairs (Phase 1)

The archived harness at `specs/archive/400_.../tools/` was copied into task-owned space
(`specs/archive/` was never edited) and repaired. Unrepaired it matched **zero** records against
the current tree and reported a **vacuous zero** — success and total failure look identical.

| Defect | Repair |
|---|---|
| `REPO` computed as a fixed four-`dirname` chain | upward walk for `lakefile.lean`, raising if absent |
| `POS_RE` anchored on the pre-rename `Theories/` | `(?:FormalSystem\|Tests)/`, built once from a `LIVE_ROOTS` tuple so the two regexes cannot drift |
| `LAKE_POS_RE` same | same |
| `EXPECTED_SORRY_FILE` pointed at the old path | `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` |
| `lean_files()` walked only `Theories/` | delegates to the counter's own walk; raises on an empty result |
| `long_lines()` kept a second, exemption-free definition of the count | delegates to the one canonical counter |
| `IN_SCOPE` carried 20 sibling-owned categories | narrowed to `linter.style.longLine` alone; the rest moved to `OUT_OF_SCOPE_FROZEN` |
| `sweep.py` `STAGE_A`/`STAGE_B` also fixed 4 sibling-owned categories | `STAGE_A` emptied, `STAGE_B` = `['linter.style.longLine']` |
| a zero-record parse was silently accepted | `VacuousParse` + `assert_not_vacuous()`, wired into a new `lintlib.lint()` used by all six `sweep.py` call sites |

The vacuity guard was proven to fire, not merely written: re-running the census with the
archived `Theories/` regex parses 0 records from a 245-diagnostic log and raises.

New: `count_long_lines.py`, the single canonical codepoint counter, with the linter's `http`
and `import` exemptions transcribed from `Mathlib/Tactic/Linter/Style.lean`. Two other counting
methods were in circulation and both are wrong here — `awk 'length>100'` counts **bytes** in a
C locale (2116 against a true 598, this codebase being dense in `□ ◇ △ ▽ φ ψ → ⊥ ∈ ⟨⟩`), and
`lake build`'s `linter.style.longLine` category count is **always zero** because `lake build`
does not enable the Mathlib style linters.

## The String-Gap Breaker (Phase 2)

A trailing `\` inside a Lean string literal swallows the newline and the continuation line's
leading whitespace, so a literal can be split without changing its value. Mathlib's own
`longLine` linter suggests exactly this. Semantics were `#guard`-verified against this toolchain
**before** the fixer was written — the space preceding the `\` is preserved, so the breaker
splits *at* a space and keeps that space on the first line.

Measured over all 598 sites, old fixer vs new, same inputs:

| Area | Sites | Residual before | Residual after |
|---|---|---|---|
| `FormalSystem/` other | 40 | 0 | 0 (byte-identical output) |
| `FormalSystem/Automation/` | 327 | 52 | **2** |
| `Tests/` | 231 | 8 | **2** |
| **Total** | **598** | **60** | **4** |

Two hazards were found by testing rather than by reasoning, and both are now hard guards:

1. **A gap inside a `{…}` interpolation does not fail loudly.** `s!"x {f 1 \` / `2} y"`
   elaborates the `\` as Lean's `SDiff` set-difference operator, reading the antiquotation as
   `f 1 \ 2`. The toolchain reports `failed to synthesize SDiff (Nat → Nat)` — a *type* error at
   a distance, not a syntax error. In a less-constrained position it could pass unnoticed.
2. **Brace protection had to be computed over the whole line, not per string span.**
   `string_spans` cannot see through a nested string inside an antiquotation: on
   `s!"Max formulas: {if n == 0 then "unlimited" else toString n}"` it closes the span at the
   quote before `unlimited` and opens a fresh, apparently non-interpolated span after it — and
   the first implementation duly broke inside the real antiquotation.

Also refused: raw strings (`r"…"`, where `\` is no escape), the `throwError "… {x} …"`
implicit-interpolation family, a space followed by a run of whitespace (the gap would delete
it), and any position preceded by an odd run of backslashes. Round-trip equality is
`#guard`-checked in `tools/string_gap_roundtrip.lean` for three shapes: an escaped-quote JSON
literal, an `s!` interpolation, and a `throwError`-shape message.

## Hand-Fix Inventory

Mechanical sweeps took **581 of 598** sites (97%). The 17 hand-fixed sites fell into three
shapes, none of which was the string-heavy tail the research predicted — the string-gap breaker
had already absorbed that entirely.

| File | Sites | Shape |
|---|---|---|
| `FormalSystem/Automation/FormulaMutator.lean` | 6 | `pairs.filter (fun p => match … \| _ => false) \|>.length`; the only legal continuation starts at `\| _ => false`, which rule 8 forbids from landing left of its corresponding `\|`. Rewritten to match two hand-written siblings already present in the same declaration. |
| `Tests/BimodalTest/Automation/ProofFirstTests.lean` | 9 | structure instances and long applications. `{ a := …, b := … }` cannot be split with the continuation left of the first field's column; the fix is to put `{` last on its line. The same rule bit again one level down, on a nested `some { … }`. |
| `Tests/BimodalTest/Semantics/SemanticBenchmark.lean` | 6 | interpolated and JSON-emitting strings, a structure instance, three long applications |
| `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` | 3 | two long `def … : DerivationTree [] (…) :=` signatures, one JSON-emitting string |

## Two Findings Not Anticipated by the Plan

**Four `Tests/` files sit outside `lake build BimodalTest`.** `Tests/BimodalTest.lean` and
`scripts/module-invariants-manifest.txt` document this; it is a first-class property of the tree,
not something this task introduced. It matters because gating those files on `lake build
BimodalTest` would have been vacuous — that build never compiles them. Each was gated on what
actually covers it:

- `ProofFirstTests.lean` and `FormulaMutatorTest.lean` compile only in isolation (each pulls in
  an executable root defining `main`). Verified with `lake env lean`, and independently by
  `check-module-invariants.sh` **C6**. `ProofFirstTests.lean`'s twelve tests are `#eval` blocks
  that `throw` on failure, so a clean compile *is* the test run.
- `SemanticBenchmark.lean` and `DerivationBenchmark.lean` are manifested `broken:` — they do not
  compile at all (they pass `String` where `Atom` is now required). The mechanical sweep
  correctly refused both with `file had errors BEFORE sweep`. The honest invariant for them is
  that their pre-existing diagnostic multiset must not grow, and it did not: **byte-for-byte
  identical** before and after with line numbers normalised out — SemanticBenchmark 23
  diagnostics / 7 shapes, DerivationBenchmark 38 / 17.

**The live-file denominator is 331, not 330.** `check-module-invariants.sh` C7 counts one more
file than the harness did: the `lean_lib FormalSystem` root aggregator `FormalSystem.lean`,
which lives at the **repository root** rather than inside `FormalSystem/`, so walking the two
source directories silently omitted it. It carries zero violations, so no violation count in
this task changes — but a counter that is correct only because the file it forgot happened to be
clean is exactly the defect class Phase 1 exists to eliminate. `count_long_lines.py` now scans
it, `gate.py:lean_files()` delegates to that one walk rather than keeping a second notion of
"the live tree", and the baseline was re-derived against a worktree of the pre-task commit:
live files 330 → **331**, copyright 330/330 → **331/331**, `long_lines` unchanged at 598,
categories unchanged.

## Plan Deviations

- **Phase 1, `long_lines()` codepoint fix** — *altered*. `len()` was already over `str`, so
  codepoints were never the defect. The real defect was a second, exemption-free definition of
  the count that could silently disagree with the canonical counter; it now delegates.
- **Phase 2, interpolation handling** — *altered*, hardened twice beyond the plan after testing
  caught the first implementation misplacing a gap inside a real antiquotation (see above), plus
  two guards the plan did not call for (raw strings, `throwError`).
- **Phase 3, frozen harness copy** — *skipped*, not applicable. Phases ran sequentially in one
  agent, so Phase 2 was committed before Phase 3 began; there was no in-flight harness.
- **Phase 3, hand-fix declined sites** — *skipped*. The sweep applied 40/40 across 21/21 files
  with zero declines.
- **Phase 4, fixpoint loop** — *altered*. Added `sweep.py --allow-residual`, because the
  inherited gate reverts a whole file unless the in-scope category reaches zero, which would
  have cost `FormulaMutator.lean` its other 37 fixes for 6 irreducible sites. Errors and
  frozen-category drift still revert.
- **Phase 5, interpolated-log and JSON hand-fixes** — *skipped*, not reached. The string-gap
  breaker absorbed every one; `DatasetExport.lean`'s predicted 23-site residual came out at 0.
- **Phase 5, string round-trip check** — *vacuously satisfied and recorded as such*. The
  residual contained no string literals.
- **Phase 7, line comments and `#guard`/`example` hand-fixes** — *skipped*, none reached the
  residual.
- **Phase 7, rebuild `BimodalTest` after each file** — *altered*. That build covers none of the
  three residual files, so it would have been a vacuous gate; each was gated on what covers it
  (see above). `lake build BimodalTest` was still run at the end as a cross-check.

## Artifacts

- `specs/180_.../tools/` — task-owned repaired harness: `lintlib.py`, `fixers.py`, `sweep.py`,
  `gate.py`, `count_long_lines.py`, `publication_invariants.py`, `string_gap_roundtrip.lean`,
  re-derived `baseline_snapshot.json` / `baseline_categories.json`
- `specs/180_.../tools/logs/` — sweep completion logs (resume points), the two enumerated
  hand-fix inventories (`automation-residual.txt`, `tests-residual.txt`), the broken-benchmark
  diagnostic baselines, and `final-gate.txt`
- 65 reformatted `.lean` files across `FormalSystem/` and `Tests/`
- This summary

## Constraints Honoured

Nothing under `specs/archive/` was edited. No declaration was added, removed, or renamed and no
`def`→`theorem` conversion was made. No `sorry`, `axiom`, or `set_option … false` was added — the
line limit was met by breaking lines, never by silencing the linter. No sibling-owned linter
category moved in either direction. No `Boneyard` tree was touched (155 files, a further 512
violations, excluded from the build and out of scope). No task-number reference was written into
any `.lean` file or any deliverable outside `specs/**`, which
`check-module-invariants.sh` **C9** independently confirms ("zero task-number citations under
`FormalSystem/`").
