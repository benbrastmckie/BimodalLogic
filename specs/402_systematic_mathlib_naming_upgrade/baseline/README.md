# Phase 1 baseline

Captured before any source file was modified. All numbers reproducible with `../tools/`.

## Build and invariants

| Item | Value | How measured |
|---|---|---|
| `lake build` | GREEN, 1884 jobs | `lake build` |
| Live `sorry` (outside `Boneyard/`) | 1, `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:1242` | `tools/check-sorry.sh` |
| Located by content | `theorem countermodel_discrete` | `tools/check-sorry.sh` |

`tools/check-sorry.sh` delegates to `.claude/scripts/lean-sorry-census.sh`, which strips nested
`/- -/` comments and string literals first. A plain `grep -rn '\bsorry\b'` over the same tree
returns **813** hits, almost all the word "sorry" inside prose ("sorry-free", "the sorry chain").
Any future check must use the census script, never grep. `Boneyard/` is excluded: nothing imports
it and it carries its own historical sorries.

## Linter baseline

`lake exe batteries/runLinter Bimodal`, parsed by `tools/runlinter.py`.

| Category | Masked (nolints.json present) | Unmasked (moved aside) |
|---|---|---|
| `defsWithUnderscore` | **1** | **861** |
| `unusedArguments` | 124 | 124 |
| `LINTER FAILED` | 115 | 115 |
| `docBlame` | 39 | 39 |
| `tacticDocs` | 4 | 4 |
| `structureInType` | 1 | 1 |
| total | 284 | 1144 |

- The single masked finding is `Bimodal.ProofSystem.temp_linearity_derivation`
  (`ProofSystem/LinearityDerivedFacts.lean:74`) - the known drift entry post-dating the
  860-entry suppression file.
- `scripts/nolints.json` (860 entries) was restored byte-identical after the unmasked run
  (md5 verified, `nolints.md5`).
- **Phase 8 compares against the unmasked column.** Any category other than
  `defsWithUnderscore` exceeding its value here is a regression from this migration.
- Accounting note: this tool breaks `LINTER FAILED` out of `simpNF` rather than folding it in,
  so the split is not comparable to figures quoted elsewhere. Phase 8 must diff *this* artifact
  with *this* tool.

## runlinter.py repair - postmortem constraint 12, verified

batteries pretty-prints `@Name` for declarations with implicit arguments. Measured against the
actual unmasked output:

    names recovered WITHOUT @ strip: 436
    names recovered WITH    @ strip: 861
    silently lost:                   425

Reproduces the research figure ("loses 425/861 if unstripped") exactly. Repaired regex:
`^@?([A-Za-z_À-￿«][^\s]*)`. The 861 flagged fully-qualified names are in `flagged-names.txt`
(861 lines, 861 unique).

## .ilean corpus

`tools/ilean.py`, schema v5, **0-indexed lines, 0-indexed UTF-16 code-unit columns** (verified
empirically: `Truth.ilean` records `TaskFrame` at line 94 col 82 and `src[94][82:91]` is exactly
`"TaskFrame"`).

| Item | Value |
|---|---|
| live `.ilean` files | 322 |
| stale `.ilean` files (module has no source) | 5 |
| reference entries | 26,325 |
| recorded ranges (all) | 207,188 |
| recorded ranges for project declarations | 126,076 |

The 5 stale files are exactly those research predicted, and were deleted in this phase:
`Bimodal.Automation.EFGameTactics`, `Bimodal.Metalogic.BXCanonical.BXCanonical`,
`Bimodal.Metalogic.Completeness`, `Bimodal.Metalogic.Metalogic`,
`Bimodal.Metalogic.WeakCanonical.WeakCanonical`.

`ilean.py` additionally *skips* any `.ilean` whose module has no source, so deletion is
belt-and-braces rather than load-bearing (postmortem constraint 11). Deleting these five
accomplishes what `lake clean && lake build` would have, for the purpose at hand, without
discarding an otherwise-valid 1884-job build. A full clean rebuild is unavoidable at Phase 2
anyway, since renaming the module root invalidates every artifact.

## Rewriter self-test - the Phase 1 acceptance bar

`python3 tools/rename.py --self-test`, over all 126,076 project-declaration ranges:

    exact suffix:     125843  (99.8152%)     [bar: >= 99.7%]
    mismatch taxonomy:
         133  keyword/anon-decl
          94  wildcard-_
           4  guillemet-escaped
           1  compiler-aux-decl
           1  binder-ascription-span
    PASS

- `wildcard-_` = 94 and `guillemet-escaped` = 4 reproduce the research counts exactly.
- `keyword/anon-decl` = 133 vs research's 92: a broader keyword set here, not a different
  phenomenon.
- Two singleton buckets were diagnosed rather than left `UNKNOWN`:
  - `compiler-aux-decl` - `...instDecidableEqPredsSigCex._aux_1`, a compiler-generated auxiliary
    with no source-level name. Never a rename target.
  - `binder-ascription-span` - `Syntax/SubformulaClosure/TemporalFormulas.lean:357`, where the
    recorded range covers the whole ascription `(serialityFormulas : Finset Formula)` so the
    identifier is span-**initial**. The suffix rule must refuse it; rewriting the trailing token
    would corrupt the ascribed type. The build catches any such site that matters.

**Parenthesized spans are handled, not rejected**, as the plan requires. Spans recorded as
`(.bot)`, `(Axiom.serial_future)`, `(.boxPos)` have balanced trailing `)` trimmed before the
suffix rule applies; this converted 14 rejections into correct edits and raised the rate from
99.8041% to 99.8152%.

Rejections stay rejections by design (postmortem constraint 8): the 94 wildcard `_` holes and
the keyword/anonymous sites are precisely the ranges a naive textual rewriter turns into
syntactically valid nonsense.

## UNVERIFIED claim 1 - the "20 active `cud` tokens": RESOLVED

**Verdict: all code, none in scope, no action required in Phase 7.1.**

There are **zero** bare `cud` tokens anywhere, in code or comments. The string occurs only inside
compound identifiers, all live code:

| Identifier | Occurrences | Kind |
|---|---|---|
| `cud_contains_theorems` | 14 | `theorem` (`Chronicle/ChronicleTypes.lean:258`) |
| `cud_modus_ponens` | 5 | `theorem` (`ChronicleTypes.lean:276`) |
| `cud_conj_closed` | 5 | `theorem` (`ChronicleTypes.lean:296`) |
| `cud_not_mem_is_sdc` | 4 | `theorem` |
| `h_cud`, `h_DC_cud`, `h_dc_cud`, `hB_cud`, `hD_cud` | 32 | local hypothesis binders |
| `BurgessR3Maximal_cud` | 1 | local binder |

None appears in the 861-name flagged set: the four declarations are `theorem`s, outside
`defsWithUnderscore`'s scope entirely, and local binders are never linted. `cud` ("closed under
deduction") needs no rename and no comment sweep.

## UNVERIFIED claim 2 - do the archived harnesses execute? RESOLVED

**Verdict: they execute and still parse the current tree correctly, but they are
reference-only here because they cannot recover declaration names.**

| Harness | Executes | Parses current output |
|---|---|---|
| `specs/archive/399_.../tools/runlinter.py` | yes | yes - reproduces all six category counts |
| `specs/archive/400_.../tools/runlinter.py` | yes | yes - reproduces all six category counts |
| `specs/archive/400_.../tools/gate.py` | yes (`--help`) | not exercised |
| `specs/archive/399_.../tools/sweep.py` | yes (`--help`) | not exercised |

Both archived `runlinter.py` copies return the exact category census above. Neither extracts
declaration **names** at all, and their `ROW` regex predates the `@` trap, so neither can drive
this migration. `tools/runlinter.py` supersedes them.
