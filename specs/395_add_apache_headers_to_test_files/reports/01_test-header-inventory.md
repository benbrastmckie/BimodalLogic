# Test-File Apache Header Inventory

**Task**: 395 — add_apache_headers_to_test_files
**Type**: lean4 (mechanical)
**Session**: sess_1785047501_b839c2_395

## Summary

All six investigation items are resolved. The file count (42) is confirmed, the complete
file→year table is below, and the verification script already satisfies its stated requirement
with no fix needed. A full dry-run of the transformation was simulated in a scratch tree and
passes `check-copyright-headers.sh --strict` at **42/42 conforming, exit 0**.

Three findings materially change the work list versus the task description and are called out
under "Corrections to the task description" — most importantly, the git-year command given in
the description produces the **wrong year for 25 of the 42 files**.

## 1. File count: 42 confirmed

`find Tests -name '*.lean' -type f | wc -l` → **42**. Matches the description exactly.

## 2. Complete file → year table

Years are the **rename-aware** creation year (`git log --follow --diff-filter=A`). See
"Corrections" item A for why `--follow` is required. Distribution: **25 files at 2025,
17 files at 2026**.

| # | File | Year | Action |
|---|------|------|--------|
| 1 | `Tests/BimodalTest/Automation/C5SmokeTest.lean` | 2026 | prepend |
| 2 | `Tests/BimodalTest/Automation/DeductionTest.lean` | 2026 | prepend |
| 3 | `Tests/BimodalTest/Automation/EdgeCaseTest.lean` | 2026 | prepend |
| 4 | `Tests/BimodalTest/Automation/FormulaMutatorTest.lean` | 2026 | prepend |
| 5 | `Tests/BimodalTest/Automation/InterestingnessTest.lean` | 2026 | prepend |
| 6 | `Tests/BimodalTest/Automation/LemmaDBTest.lean` | 2026 | prepend |
| 7 | `Tests/BimodalTest/Automation/NormalizationTest.lean` | 2026 | prepend |
| 8 | `Tests/BimodalTest/Automation/ProofFirstTests.lean` | 2026 | prepend |
| 9 | `Tests/BimodalTest/Automation/ProofSearchBenchmark.lean` | 2026 | prepend |
| 10 | `Tests/BimodalTest/Automation/ProofSearchTest.lean` | 2025 | prepend |
| 11 | `Tests/BimodalTest/Automation/TacticsTest.lean` | 2025 | prepend |
| 12 | `Tests/BimodalTest/Automation/TacticsTest_Simple.lean` | 2025 | prepend |
| 13 | `Tests/BimodalTest/Automation/WeakeningSearchTest.lean` | 2026 | prepend |
| 14 | `Tests/BimodalTest/Integration/AutomationProofSystemTest.lean` | 2025 | prepend |
| 15 | `Tests/BimodalTest/Integration/BimodalIntegrationTest.lean` | 2025 | prepend |
| 16 | `Tests/BimodalTest/Integration/ComplexDerivationTest.lean` | 2025 | prepend |
| 17 | `Tests/BimodalTest/Integration/EndToEndTest.lean` | 2025 | prepend |
| 18 | `Tests/BimodalTest/Integration/Helpers.lean` | 2025 | prepend |
| 19 | `Tests/BimodalTest/Integration/ProofSystemSemanticsTest.lean` | 2025 | prepend |
| 20 | `Tests/BimodalTest/Integration/TemporalIntegrationTest.lean` | 2025 | prepend |
| 21 | `Tests/BimodalTest.lean` | 2026 | prepend |
| 22 | `Tests/BimodalTest/Metalogic/PropDecideTest.lean` | 2026 | prepend |
| 23 | `Tests/BimodalTest/ProofSystem/AxiomsTest.lean` | 2025 | prepend |
| 24 | `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` | 2026 | prepend |
| 25 | `Tests/BimodalTest/ProofSystem/DerivationPropertyTest.lean` | 2025 | prepend |
| 26 | `Tests/BimodalTest/ProofSystem/DerivationTest.lean` | 2025 | prepend |
| 27 | `Tests/BimodalTest/Property/Generators.lean` | 2025 | prepend |
| 28 | `Tests/BimodalTest/Property.lean` | 2025 | prepend |
| 29 | `Tests/BimodalTest/Semantics/SemanticBenchmark.lean` | 2026 | prepend |
| 30 | `Tests/BimodalTest/Semantics/SemanticPropertyTest.lean` | 2025 | prepend |
| 31 | `Tests/BimodalTest/Semantics/TaskFrameTest.lean` | 2025 | prepend |
| 32 | `Tests/BimodalTest/Semantics/TruthTest.lean` | 2025 | prepend |
| 33 | `Tests/BimodalTest/Syntax/ContextTest.lean` | 2025 | prepend |
| 34 | `Tests/BimodalTest/Syntax/FormulaPropertyTest.lean` | 2025 | prepend |
| 35 | `Tests/BimodalTest/Syntax/FormulaTest.lean` | 2025 | prepend |
| 36 | `Tests/BimodalTest/Theorems/ModalS4Test.lean` | 2025 | prepend |
| 37 | `Tests/BimodalTest/Theorems/ModalS5Test.lean` | 2025 | prepend |
| 38 | `Tests/BimodalTest/Theorems/PerpetuityTest.lean` | 2025 | prepend |
| 39 | `Tests/BimodalTest/Theorems/PropositionalTest.lean` | 2025 | prepend |
| 40 | `Tests/BimodalTest/TraceCertificateTest.lean` | 2026 | **REPLACE lines 1-4** |
| 41 | `Tests/BimodalTest/TraceExporterE2ETest.lean` | 2026 | **REPLACE lines 1-4** |
| 42 | `Tests/BimodalTest/TraceExportTest.lean` | 2026 | **REPLACE lines 1-4** |

## 3. Existing `Copyright (c)` lines — description was wrong

The description asked to confirm this count is zero. **It is not zero.** Exactly three files
already carry a `^Copyright (c) ` line — the same three placeholder files:

```
Tests/BimodalTest/TraceCertificateTest.lean:1
Tests/BimodalTest/TraceExporterE2ETest.lean:1
Tests/BimodalTest/TraceExportTest.lean:1
```

The description's stronger claim — that Tests/ has **zero conforming** headers — is true.
Current checker baseline on `Tests`:

```
conforming: 0   nonconforming: 3   duplicate: 0   missing: 39   total: 42
```

The 3 nonconforming files are precisely the placeholder files; the other 39 have no copyright
text at all. This is exactly the double-header trap the description warns about: prepending to
those three would push `n_cop` to 2 and trip the duplicate bucket.

## 4. The three placeholder files (verbatim)

All three are byte-identical in their first 6 lines:

```
/-
Copyright (c) 2026 BimodalLogic contributors.
Released under the project's standard license.
-/

import Bimodal.Syntax
```

So the placeholder block occupies **lines 1–4**, with line 5 blank. The vague line the
description flags is line 3. Note the block has **no `Authors:` line**, and the holder is the
collective "BimodalLogic contributors" rather than the individual — both must change.

**Correct edit**: delete lines 1–4 and prepend the 5-line header. Line 5 (blank) is retained
and becomes the blank separator, matching convention. Do **not** delete line 5.

## 5. `scripts/check-copyright-headers.sh` — exists, and needs NO fix

The script exists at `scripts/check-copyright-headers.sh` (executable). The description's
requirement is **already implemented correctly**. At `scripts/check-copyright-headers.sh:66-72`:

```bash
# A stale/second copyright block anywhere in the file is a duplicate. Checked FIRST,
# because validating only the leading block would silently pass a double-headered file.
n_cop=$(grep -ci '^Copyright (c) ' "$f")
n_lic=$(grep -cF "$LICENSE_LINE" "$f")
if [ "$n_cop" -gt 1 ] || [ "$n_lic" -gt 1 ]; then
  duplicate=$((duplicate+1)); echo "$f" >>"$OUTDIR/duplicate.txt"; continue
fi
```

This counts across the **whole file** (no `head` restriction), runs **before** leading-block
validation, and `continue`s so a double-headered file can never fall through into the
conforming bucket. It also guards the license line the same way. **No modification required.**

The script's own header comments independently document the `linter.style.header` false
negative (`isInLibraryRoot` vs `srcDir := "Theories"`), corroborating the description.

## 6. Build and test status

**Build command**: `lake build BimodalTest` (the lakefile declares `testDriver := "BimodalTest"`,
so `lake test` routes here too).

**Current status: GREEN.** A full `lake build BimodalTest` completed during this research:
`Build completed successfully (1912 jobs)`, exit 0. Only linter warnings (unused simp args), no
errors. This is a trustworthy pre-change baseline.

### Caveat: 8 files are outside the build graph

`Tests/BimodalTest.lean` has only 33 `import` lines, so `lake build BimodalTest` compiles 34 of
the 42 modules. **8 files are never checked by the default build**:

| File | Builds standalone? |
|------|--------------------|
| `Tests/BimodalTest/Automation/FormulaMutatorTest.lean` | OK |
| `Tests/BimodalTest/Automation/InterestingnessTest.lean` | OK |
| `Tests/BimodalTest/Automation/ProofFirstTests.lean` | OK |
| `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` | **FAILS — 39 errors** |
| `Tests/BimodalTest/Semantics/SemanticBenchmark.lean` | **FAILS — 7 errors** |
| `Tests/BimodalTest/TraceCertificateTest.lean` | OK |
| `Tests/BimodalTest/TraceExporterE2ETest.lean` | OK |
| `Tests/BimodalTest/TraceExportTest.lean` | OK |

`DerivationBenchmark.lean` and `SemanticBenchmark.lean` are **already broken before any header
change** (unknown identifiers `mkTemporalNecessitation`, `mkWeak1`, …; `List.get!` removed from
core; `sorry`-dependent evaluation). These are pre-existing rot, **out of scope** for a header
task. The implementer must still header them, must **not** attempt to repair them, and must not
mistake their failure for header-induced breakage.

Since headers are block comments, no build impact is expected for any file.

## Corrections to the task description

### A. The prescribed git-year command yields the wrong year for 25 of 42 files

The description prescribes:

```
git log --diff-filter=A --format=%ad --date=format:%Y -- <path> | tail -1
```

Without `--follow`, this returns **2026 for all 42 files**, because every test file was moved
into `Tests/` by a single commit (`9d4a15c9b`, dated 2026-01-11, "move tests to Tests/"). That
commit is what `--diff-filter=A` sees; it is a move date, not a creation date.

The sibling `Theories/` work used the true creation year. Verified across all 279 headered
`Theories` files:

| Year source | Agreement with the committed header |
|-------------|-------------------------------------|
| `--follow --diff-filter=A` | **279 / 279** |
| plain `--diff-filter=A` | 248 / 279 |

Following the description literally would stamp 2026 on 25 files whose true creation year is
2025, diverging from the established convention. **Use `--follow`.** The table in section 2
already does.

### B. Prepending to the three placeholder files is caught, not silent

Worth stating plainly since the description worries about silence: the checker's duplicate
predicate *does* catch this. A prepend-instead-of-replace mistake lands the file in the
`duplicate` bucket and `--strict` exits 1. The guard is real and working.

## Exact format to apply

Verified byte-for-byte against the 279 `Theories` files (all 279 identical in shape) and
against the checker:

```
/-
Copyright (c) YYYY Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

```

- 5 header lines, then **one blank line**, then existing content.
- All 279 `Theories` files have `-/` on line 5 and a blank line 6 — 279/279. The checker does
  not enforce the blank line, but convention fidelity requires it.
- Holder is the individual, `Authors:` line is present, `/- -/` block form (not `--`).
- Header precedes any `import`. Note `Tests/BimodalTest.lean`, `Tests/BimodalTest/Property.lean`,
  and `Tests/BimodalTest/Integration/Helpers.lean` begin with `import` on line 1 — no
  module docstring to work around anywhere in the tree.

## Dry-run verification (already performed)

The complete transformation was applied to a scratch copy of `Tests/` (per-file `--follow`
years; replace-lines-1-4 for the three placeholders; prepend for the other 39), then checked:

```
conforming   : 42
nonconforming: 0
duplicate    : 0
missing      : 0
total        : 42
EXIT=0
```

The format and the per-file plan in this report are therefore confirmed to satisfy
`bash scripts/check-copyright-headers.sh --strict Tests` before implementation begins.

## Verification commands for the implementer

```bash
# Header gate (must exit 0, 42/42 conforming)
bash scripts/check-copyright-headers.sh --strict Tests

# Build gate (must stay green — this was green before the change)
lake build BimodalTest

# The 6 healthy out-of-graph modules (must stay green)
lake build BimodalTest.Automation.FormulaMutatorTest \
           BimodalTest.Automation.InterestingnessTest \
           BimodalTest.Automation.ProofFirstTests \
           BimodalTest.TraceCertificateTest \
           BimodalTest.TraceExporterE2ETest \
           BimodalTest.TraceExportTest

# Do NOT gate on these two — broken before this task, out of scope:
#   BimodalTest.ProofSystem.DerivationBenchmark
#   BimodalTest.Semantics.SemanticBenchmark
```

No new axioms, no `sorry`, no proof work: this task touches comment blocks only.
