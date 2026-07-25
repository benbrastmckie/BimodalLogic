# Implementation Summary: Mechanical Mathlib Linter Compliance (Tier 1 + Tier 2)

- **Task**: 293 - audit_and_fix_mathlib_linter_compliance
- **Plan**: `specs/293_audit_and_fix_mathlib_linter_compliance/plans/01_mechanical-linter-compliance.md`
- **Status**: All 13 phases COMPLETED
- **Type**: lean4
- **Toolchain**: Lean v4.33.0-rc1 (the top-level `CLAUDE.md` still says v4.27.0-rc1 and is stale;
  not edited, out of scope)

## Outcome

The in-scope mechanical diagnostic count for the 67 sorry-free modules went from **1,022 to 0**.
`lake build` finished at 0 errors with exactly 12 `declaration uses` warnings at the same 12
locations as the baseline, and every deliberately out-of-scope category is unchanged to the unit.

| Category | Before | After | Phase |
|---|---|---|---|
| `linter.style.emptyLine` | 508 | **0** | 10, 11, 12 |
| `linter.style.longLine` | 257 | **0** | 4, 5, 6 |
| `linter.unusedSimpArgs` | 223 | **0** | 2, 3 |
| `linter.unusedVariables` | 14 | **0** | 7 |
| `linter.style.maxHeartbeats` | 8 | **0** | 6 |
| `docBlame` (in scope) | 8 | **0** | 8 |
| `linter.style.docString` | 3 | **0** | 8 |
| `linter.style.whitespace` | 1 | **0** | 4 |
| **Total** | **1,022** | **0** | |

Plus two linter-invisible items: the dead `have bc` binding in
`Theorems/Perpetuity/Principles.lean` and eleven stale docstrings whose content contradicted the
proof they documented.

51 files changed: 697 insertions, 1,013 deletions. Thirteen commits, one per phase plus a Phase 9
addendum.

## Verification (Phase 13)

All logs are in `specs/293_audit_and_fix_mathlib_linter_compliance/baseline/`.

**In scope, now zero** — confirmed by re-sweeping all 67 files with
`lake env lean -Dlinter.mathlibStandardSet=true`, diffed against `style-before.log`.

**Out of scope, unchanged to the unit** — a drop here would have meant a phase exceeded scope:

| Category | Before | After | T1 | T2 |
|---|---|---|---|---|
| `linter.flexible` | 78 | 78 | 24 | 54 |
| `linter.style.show` | 10 | 10 | 1 | 9 |
| `linter.style.nativeDecide` | 4 | 4 | 0 | 4 |
| `linter.defProp` | 3 | 3 | 3 | 0 |
| `linter.unusedTactic` | 2 | 2 | 0 | 2 |
| `linter.style.multiGoal` | 2 | 2 | 0 | 2 |
| `linter.style.openClassical` | 1 | 1 | 0 | 1 |

**Declaration linter** (`lake exe runLinter Bimodal`): 1,328 → 1,319 findings.

- `docBlame` in scope 8 → 0; out of scope 91 → 91.
- `defsWithUnderscore` in scope **still exactly 239** (189 T1 + 50 T2), out of scope 663 → 663.
  No rename leaked in from the naming task's territory.
- `unusedArguments` in scope 11 → 10. This single drop is
  `Metalogic.Decidability.expandOnceWithApplied_tracedImpl`, and it is a direct consequence of the
  plan-mandated Phase 7 fix at that exact site: prefixing the unused `tracker` parameter with `_`
  satisfies `unusedVariables` and `unusedArguments` at once. Not scope creep — one edit, two
  linters. 8 `docBlame` + this 1 accounts for the full 1,328 → 1,319 delta.
- `simpNF` in scope 1 → 1.

**Build**: 0 errors. Exactly 12 `declaration uses`, at the same locations as before
(`Metalogic/Bundle/SuccRelation.lean` ×7, `Metalogic/Bundle/SuccExistence.lean` ×3,
`Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` ×1,
`Metalogic/WeakCanonical/Transfer.lean` ×1) — verified by diffing the per-file tallies, which are
identical.

**Deprecations**: 554 before, 554 after; `push_neg` 506 before, 506 after. Untouched, as required.

**Scope boundaries honored**: no declaration renamed; no `def` converted to a `theorem`; no
copyright header added or modified; no file under `Boneyard/`, `Automation/`, or T3 `Metalogic/`
appears in any diff.

## Tooling: what worked and what did not

Both Mathlib helper scripts were verified in Phase 1 and then **not used**.

- **`scripts/fix_unused.py` is stale against v4.33** — its regex expects ``unused variable `x` ``
  while the build log contains "Variable name \`x\` is not explicitly referenced" 167 times. The
  plan predicted this; confirmed and avoided.
- **`scripts/fix_long_lines.py` works as documented but barely applies here.** It cuts only at the
  last comma before column 100. Measured against the actual sites: 108 of 252 (**42%**), well
  below the ~64% the plan expected, and it reported "Fixed 0 long lines" on
  `Syntax/Formula.lean:174`. Its one test cut also split a doc-comment bullet mid-item. The
  comma-cuttable sites turned out to be concentrated in exactly the files that also carried
  `unusedSimpArgs` work, i.e. they were mostly `simp only [...]` lists.
- **`scripts/fix_unused_simp_args.py` was avoided on scope-safety grounds.** Its log-format
  assumption does hold (525 matches), but it consumes a whole build log and cannot be scoped per
  file, so correctness would have rested on filtering the log — with 302 out-of-scope T3 sites one
  bad filter away.

Two purpose-written helpers were used instead. Both re-derive diagnostics **per file** via
`lake env lean -Dlinter.mathlibStandardSet=true`, which makes reaching an out-of-scope file
structurally impossible rather than merely filtered against, and both verify the source text at
each reported position before editing it:

1. A simp-argument remover that removes exactly one adjacent separator, refuses to act when it
   cannot find one, and flags any edit that would produce an empty `simp only []`.
2. A line breaker that scores candidate break points by bracket depth, Mathlib-idiomatic
   head/tail tokens, string-literal and comment safety, and a hard never-last-token guard,
   indenting continuations proportionally to nesting depth. It broke 250 of the 257 long lines
   automatically; the 7 refusals were reported by name and hand-fixed.

## Four real defects, all caught by the gates

Worth recording because three of them would have been silent:

1. **`return` stranded at end of line** (Phase 5, `Saturation.lean:1602`). do-notation's `return`
   takes an *optional* argument, so `return\n  s!"..."` reparsed as a bare `return` plus a
   separate String statement — a PUnit/String type mismatch, not a parse error. Fixed, and the
   breaker now carries a `NEVER_LAST` guard (`return`, `pure`, `throw`, `yield`). A
   worktree-wide grep confirmed it was the only such site.
2. **Comment text turned into code** (Phase 6, `Core/RestrictedMCS/Basic.lean:352`). For a line
   whose code part was short but whose trailing `--` comment was long, the breaker wrapped the
   comment as if it were code, leaving a bare `¬SetConsistent ...` expression. The breaker now
   always splits a trailing comment onto further `-- ` lines. A targeted scan of **every line
   added across Phases 4-6** found no other orphaned comment fragment.
3. **Docstring inserted after an attribute** (Phase 8, `efq_axiom`). A docstring between
   `@[tm_lemma]` and `def` is a parse error; docstrings must precede attributes. The other seven
   sites were checked for the same shape.
4. **A regression introduced by this task's own earlier phase** (Phase 8). A Phase 6 line break
   pushed a closing `-/` onto its own indented line in `WeakCanonical/Separation/Defs.lean`,
   creating a NEW `linter.style.docString` finding — that file had zero at baseline. Found by
   re-deriving rather than trusting the plan's count of 3, and rewrapped.

## A measurement finding that matters for anyone repeating this

**The `emptyLine` diagnostic count is not a blank-line count.** T1 `emptyLine` read 489 at
baseline and 507 after Phase 4, even though **zero blank lines were added** —
`Perpetuity/Bridge.lean` still had exactly 209 and `Perpetuity/Principles.lean` exactly 169, and
the Phase 4 diff adds no blank line at all. Splitting a long line changes which blank lines fall
inside a command's syntactic span, so the same file's blank lines can enter and leave the linter's
view without the file's blank-line count changing.

Consequence: Phases 10-12 deleted **538** blank lines against a 508 baseline (215 + 219 + 104),
and the per-file numbers diverged from the plan (`Bridge.lean` 69 not 57, `Principles.lean` 46 not
41, `Core/DeductionTheorem.lean` 15 not 8, `Soundness.lean` 6 not 2), with two files appearing
that the plan did not list. Every phase drove from re-derived positions, which the plan's top risk
row required, and every deleted line was asserted blank before removal.

## Stale docstring audit (Phase 9)

Eleven false claims corrected, four genuine gaps deliberately preserved. The full (a)/(b)/(c)
classification of every claim-pattern hit is recorded in the plan file's Phase 9 notes. The
headline cases:

- `Theorems/Perpetuity/Principles.lean` documented `persistence` as "(ATTEMPTED)" with a
  "**BLOCKING ISSUE**: the step `◇φ → □◇φ` is NOT derivable from current axioms" and concluded
  "**Implementation Decision**: Axiomatize P5 for MVP". The proof's first line is
  `have m5 := modal_5 φ` — precisely that step — and P5 is not axiomatized anywhere.
- `Theorems/Propositional/Core.lean` documented `lce_imp` and `rce_imp` as "Requires full
  deduction theorem" with a "**Workaround**". Both are proven *by* the deduction theorem.
- `Theorems/ModalS5.lean` documented `s5_diamond_box_to_truth` as "Blocked on s5_diamond_box
  forward direction", with a Proof Strategy and Dependencies both naming a lemma the proof never
  uses.
- Kept as accurate: `WeakCanonical/Separation/KampTranslation.lean`'s BLOCKED note on the
  n-variable Fraisse game argument, and `Decidability/Saturation.lean`'s note that the
  `saturateBlocked` correctness theorems are not formalized and what each would require. These are
  real documentation of real gaps and were not deleted to make the audit look clean.

The plan's grep pattern missed two module-level status headings (`**Phase N ...**` form); a second
sweep found and fixed them, committed separately so Phases 10-12 stay revertible as a
pure-deletion unit.

## Residual inventory (for follow-up work)

Measured, not re-derived from the report. **100 style diagnostics** remain in the 67 files, all
deliberately out of scope:

| Category | T1 | T2 | Total | Why deferred |
|---|---|---|---|---|
| `linter.flexible` | 24 | 54 | 78 | Each site needs `simp?` run, its suggestion transcribed, and the proof re-verified |
| `linter.style.show` | 1 | 9 | 10 | Changes proof shape |
| `linter.style.nativeDecide` | 0 | 4 | 4 | Changes proof architecture |
| `linter.defProp` | 3 | 0 | 3 | Naming work (def→theorem) |
| `linter.unusedTactic` | 0 | 2 | 2 | Changes proof shape |
| `linter.style.multiGoal` | 0 | 2 | 2 | Changes proof shape |
| `linter.style.openClassical` | 0 | 1 | 1 | Changes proof architecture |

`linter.flexible` concentrates in `Decidability/Saturation.lean` (21), `Core/DeductionTheorem.lean`
(12), `ProofSystem/Axioms.lean` (9), `Propositional/Connectives.lean` (6),
`Core/RestrictedMCS/Basic.lean` (6), then a tail of 14 files with 4 or fewer.

Declaration-linter residue in the 67 files: `defsWithUnderscore` **239** (189 T1 + 50 T2),
`unusedArguments` **10**, `simpNF` **1**.

## Notes for dependent tasks

**Copyright headers**: `linter.style.header` reports **zero** hits in this repo, and that is a
false negative, not a clean bill of health. Mathlib's `isInLibraryRoot` looks for `./Bimodal.lean`
while the lakefile's `srcDir := "Theories"` puts the root at `Theories/Bimodal.lean`, so the
header linter silently no-ops here. It will not verify header work until that mismatch is
addressed. No header was touched by this task.

**Naming work**: `defsWithUnderscore` is at 239 in scope (902 project-wide) and was left exactly
as found, including the 3 `linter.defProp` def→theorem conversions that the research report had
recommended folding in here. The root cause is architectural: `DerivationTree` is `Type`-valued
(`ProofSystem/Derivation.lean`), so every derived theorem must be a `def`, and Mathlib demands
lowerCamelCase for defs.

**Working linter invocations on this toolchain** (all confirmed):

```
lake exe runLinter Bimodal                              # declaration linters; exits 1 by design
lake env lean -Dlinter.mathlibStandardSet=true <file>   # style/syntax linters, per file
set_option linter.all true                              # also works; the report's claim that it
                                                        # does not exist is wrong
```

## Plan Deviations

- **Phase 3, `Soundness.lean` site count**: altered — re-derivation found 162 unused simp
  arguments, not the plan's 161, making the in-scope total 191 rather than 190. Within the plan's
  own stated ±1 log-wrapping tolerance.
- **Phases 2-3, `fix_unused_simp_args.py`**: altered — replaced by a purpose-written per-file
  helper. Rationale in "Tooling" above: the Mathlib script cannot be scoped per file, so scope
  safety would have rested entirely on log filtering with 302 out-of-scope sites at risk.
- **Phases 4-6, `fix_long_lines.py`**: altered — replaced by a purpose-written breaker. The
  Mathlib script applies to only 42% of sites (measured) and mangles prose.
- **Phase 4, per-file build gate**: altered — the 22 scoped `lake build Bimodal.<Module>` calls
  were replaced by one full `lake build` after reviewing every diff hunk. All 88 breaks came from
  a single deterministic pass whose diff was inspected hunk-by-hunk first, and 22 scoped builds
  would have cost more than the single full build they gate. Phases 5, 6 and 10-12 likewise gated
  per phase rather than per file. Every phase gate was green before its commit; no phase was
  committed on an unverified build.
- **Phases 5, 6, 12, per-file counts**: altered — re-derived counts diverged from the plan's
  baseline numbers wherever an earlier phase had shortened or split lines in the same file (Phase
  5: 108 not 126; Phase 6: 41 not 42; Phase 12: 104 in 10 files, not 86 in 8). The plan's top risk
  row requires re-deriving positions per phase, so the re-derived numbers govern.
- **Phase 9, claim-pattern coverage**: altered — the plan's grep missed `**Phase N ...**`
  module-level status headings. A second sweep found two more false claims
  (`Theorems/ModalS4.lean:28`, `Theorems/ModalS5.lean:24`), fixed in a separate "phase 9 addendum"
  commit placed before Phases 11-12 so the blank-line deletions remain a pure-deletion unit.
- **Phase 6, Metalogic.lean status table**: altered — three rows exceeded 100 characters and a
  markdown table cannot wrap a cell, so the table was converted to a bulleted list. All status
  text, including the completeness sorry provenance and the exact axiom lists, is preserved
  verbatim. Same treatment for the axiom-classification table in
  `FrameConditions/Compatibility.lean` (Phase 4), where all 20 axiom names are preserved.
