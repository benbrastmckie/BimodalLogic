# Research Report: Line-Limit Compliance and Publication Residue

- **Task**: 180 — line_limit_compliance_and_publication_residue
- **Type**: lean4
- **Date**: 2026-07-27
- **Session**: sess_1785141676_0da701
- **Status**: RESEARCHED

---

## Executive Summary

Everything in this report is measured, not inferred. Five findings materially change the task's
working picture:

1. **The violation count is 598, not 312**, and the distribution is not the one in the task
   description. `Automation/` holds 327; **`Tests/` holds 231 (39% of the work) and was never at
   zero**; `FormalSystem/` outside `Automation/` holds 40.
2. **The premise "ZERO violations anywhere outside `Automation/`" is false**, and was already
   false before the naming upgrade. Measured at the pre-rename commit, `Tests/` carried 242
   violations. The sibling tier-1/2/3 sweeps scoped themselves to `FormalSystem/`; `Tests/` was
   outside all of them.
3. **The predicted rename regression is real and quantified**: `FormalSystem/` non-`Automation/`
   went **4 → 40** across the naming upgrade (+36). Scope item (2) is confirmed, not speculative.
4. **The tooling is not at the path the task gives, and it is stale in four places.** It lives at
   `specs/archive/400_.../tools/`, and its path regexes and gate constants still say `Theories/`,
   which the rename removed. Left unrepaired, `lintlib.py` matches nothing and the harness
   **reports a vacuous zero** — the exact failure mode its own source comments warn about.
5. **Auto-fix applicability is 99.5%, not the ~25% the task anticipates.** The archived
   `fixers.py` is a purpose-built Lean line-breaker, not Mathlib's comma-splitter. I applied it to
   all 40 rename-induced regressions and ran `lake build`: **green, 1883 jobs, zero residual.**

Copyright headers and universe polymorphism are both verified as no-work, as the task expected.

---

## 1. Measured Current State

### 1.1 Measurement method (and a correctness warning)

The task suggests `awk 'length>100'`. **Do not use it unguarded.** Mathlib's `longLine` linter
compares `(fm.toPosition line.stopPos).column`, which is a **codepoint** count. In a C/POSIX
locale `awk` counts **bytes**, and this codebase is dense in multi-byte notation (`□ ◇ △ ▽ φ ψ →
⊥ ∈ ⟨⟩`):

| Metric | Count |
|---|---|
| Lines >100 **codepoints** (what the linter enforces) | **598** |
| Lines >100 **bytes** (naive `awk` in C locale) | 2116 |

A byte-based count overstates the work by 3.5x. All figures below are codepoint-based.

I also applied the linter's two real exemptions — lines containing `http` and `import` lines
(`Mathlib/Tactic/Linter/Style.lean:440-471`). **Neither fires anywhere in the live tree**, so the
raw codepoint count and the true violation count coincide at 598.

### 1.2 What "live tree" means here

`lakefile.lean` builds `FormalSystem` (root `FormalSystem`) and `BimodalTest` (root `BimodalTest`,
srcDir `Tests`). Both `Boneyard` trees are excluded from the build and documented as such in
`FormalSystem/FormalSystem.lean:33-37`. Live tree therefore =
`FormalSystem/**` minus `**/Boneyard/**`, plus `Tests/**`.

- 485 `.lean` files total on disk
- **330 live** files (288 under `FormalSystem/`, 42 under `Tests/`)
- 155 Boneyard files, carrying a further 512 violations that are **out of scope**

### 1.3 Current distribution — 598 violations across 65 files

| Area | Violations | Files |
|---|---:|---:|
| `FormalSystem/Automation/` | **327** | 20 |
| `Tests/` | **231** | 24 |
| `FormalSystem/` (other) | **40** | 21 |
| **Total** | **598** | **65** |

Top files:

| Count | File |
|---:|---|
| 83 | `FormalSystem/Automation/ProofStepExport.lean` |
| 73 | `Tests/BimodalTest/Automation/TacticsTest.lean` |
| 51 | `FormalSystem/Automation/DatasetGenerator.lean` |
| 43 | `FormalSystem/Automation/FormulaMutator.lean` |
| 41 | `FormalSystem/Automation/FormulaEnumerator.lean` |
| 30 | `FormalSystem/Automation/DatasetExport.lean` |
| 25 | `Tests/BimodalTest/ProofSystem/AxiomsTest.lean` |
| 22 | `Tests/BimodalTest/Automation/ProofSearchTest.lean` |
| 15 | `FormalSystem/Automation/ProofFirstBenchmark.lean` |
| 14 | `FormalSystem/Automation/Tactics/Commands.lean` |
| 13 | `FormalSystem/Automation/TableauProofStepPipeline.lean` |
| 13 | `Tests/BimodalTest/Theorems/PerpetuityTest.lean` |

The remaining 53 files hold 10 or fewer each; 22 files hold exactly 1.

### 1.4 The rename regression, quantified

Measured at `b7a2f6f88` ("task 402: complete research" — the last commit before the rename began)
against HEAD, both with identical codepoint methodology and identical Boneyard exclusion:

| Area | Pre-rename | Now | Δ |
|---|---:|---:|---:|
| `Automation/` | 453 | 327 | **−126** |
| `Tests/` | 242 | 231 | −11 |
| `FormalSystem/` (other) | **4** | **40** | **+36** |
| Total | 558 | 598 | +40 |

Two things follow:

- **Scope item (2) is confirmed.** The `FormalSystem/` non-`Automation/` tree went from
  effectively-clean (4) to 40. Renames such as `box_conj_iff → boxConjIff` lengthened use sites
  exactly as the task predicted. These 36 lines are a *regression*, and they are the cleanest,
  highest-value slice of the work.
- **The `Automation/` figure moved the other way.** The 312 in the task description is stale in
  both directions: the true pre-rename figure was 453, and the naming task's Part B rewrite
  reflowed `Automation/` down to 327 as a side effect.

The 4 pre-rename survivors (`ProofSystem.lean`, `InteriorGateGeneralK.lean`,
`SharedWitness/OrderGate.lean`, `SharedWitness/Carrier.lean`) are also still present, so the
"tiers took it to zero" claim was never exactly true for `FormalSystem/` either.

---

## 2. Violation Population Characterization

### 2.1 By content kind

| Kind | Count | % | Automation | Tests | FS-other |
|---|---:|---:|---:|---:|---:|
| Pure code (no string literal) | 261 | 44% | 176 | 55 | 30 |
| Code containing a string literal | 178 | 30% | 80 | 98 | 0 |
| Dominated by a long string literal | 123 | 21% | 65 | 58 | 0 |
| Line comment (`--`) | 21 | 4% | 2 | 19 | 0 |
| Docstring / block comment | 15 | 3% | 4 | 1 | 10 |

Only 36 lines (6%) are pure prose — the "safe to wrap" category is *small*. The bulk is code, and
**301 lines (50%) touch a string literal**, which is the genuinely hard subpopulation: the fixer
refuses to break inside a string span, so a line whose overflow is entirely inside one quoted
region has no legal break point.

`FS-other` is the benign extreme: 30 pure-code + 10 docstring lines, **zero string literals**.

### 2.2 By overage

| Chars beyond 100 | Count | % |
|---|---:|---:|
| 1–5 | 204 | 34% |
| 6–10 | 102 | 17% |
| 11–20 | 115 | 19% |
| 21–40 | 96 | 16% |
| 41+ | 81 | 14% |

Median overage 10; maximum 200. A third of all violations are within 5 characters of the limit —
these usually need a single break at an existing space and carry near-zero semantic risk.

---

## 3. Tooling Inventory

### 3.1 Location correction

The task points at `specs/400_clear_lean_v433_deprecation_warnings/tools/`. **That path does not
exist.** The task was archived. The tools are at:

```
specs/archive/400_clear_lean_v433_deprecation_warnings/tools/
```

A second, older copy (`lintlib.py`, `fixers.py` only) exists at
`specs/archive/399_mathlib_linter_compliance_tier3_metalogic/tools/`.

### 3.2 Contents

| File | Lines | Role |
|---|---:|---|
| `fixers.py` | 606 | Five mechanical fixers; `fix_long_line` + break engine is the relevant part |
| `sweep.py` | 263 | Per-file drive loop: lint → fix → re-lint → revert-on-regression |
| `lintlib.py` | 207 | `run_lint` / `parse` / `census` / differential `gate` |
| `gate.py` | 152 | End-state gate: errors, sorry-by-content, frozen categories, longLine, decl inventory |
| `runlinter.py` | 94 | Batch linter runner |
| `sites.py` | 48 | Site-list helpers |
| `baseline_snapshot.json` | 215 KB | Stale — pre-rename `Theories/` paths |

### 3.3 What `fix_long_line` actually does

`fixers.py:377-414` dispatches on line kind, then calls one of two breakers:

- **`break_prose`** (`:355`) — rewraps comment/docstring prose, preserving indent and re-emitting
  a `-- ` prefix for line comments.
- **`break_code`** (`:326`) — iterative break, continuation column
  `max(indent + 4, required_cont_col(...))`.

The break-point chooser `find_break` (`:264`) encodes exactly the hazards the task description
recites, each as a live guard:

| Guard | Site | Hazard prevented |
|---|---|---|
| `FORBIDDEN_TAIL` | `:24, :288` | `return`/`pure`/`throw`/`yield` last on a line silently reparses (optional arg in do-notation) |
| `GLUED_TAIL` | `:31, :301` | Continuation starting `at `/`with `/`using `/`:= ` closes the tactic block |
| `at_clause_spans` | `:145, :298` | Never break inside an `at h1 h2 ...` location clause |
| `required_cont_col` | `:186, :312` | Continuation inside a mid-line `by`/`do` block must clear the block's own column, not `indent+4` |
| `in_comment` bypass of `trailing_comment_index` | `:276-278` | `/--` and `-- ` both contain a literal `--`; a naive guard would refuse to wrap any comment |
| `string_spans` | `:48, :281` | Never break inside a string literal |
| `-/` orphan guard | `:300` | An indented lone `-/` makes `linter.style.docString` fire |

This is a Lean-aware breaker, which is why its applicability is nothing like Mathlib's
`scripts/fix_long_lines.py` (comma-splitting only).

### 3.4 Four staleness defects — must be repaired before use

| # | Location | Current | Required |
|---|---|---|---|
| 1 | `lintlib.py:25` `POS_RE` | `^(Theories/...)` | `^(FormalSystem/...\|Tests/...)` |
| 2 | `lintlib.py:29` `LAKE_POS_RE` | `(Theories/...)` | same correction |
| 3 | `gate.py:24` `EXPECTED_SORRY_FILE` | `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean` | `FormalSystem/Metalogic/WeakCanonical/Transfer.lean` |
| 4 | `gate.py:34` `lean_files()` | walks `REPO/Theories` | walk `REPO/FormalSystem` **and** `REPO/Tests` |

Plus a fifth, introduced by archival: `lintlib.py:21` computes `REPO` as four `dirname` levels up
from the tool file. From `specs/archive/400_.../tools/` that now resolves to
`…/BimodalLogic/specs`, not the repo root. It needs five levels (or an explicit anchor).

**Defect #1 is the dangerous one.** `lintlib.py:26-28` documents this precise failure: a regex
that matches nothing "reports vacuous zeros". Post-rename, no path begins `Theories/`, so an
unrepaired harness would declare success against an empty record set.

**Defect #4 is a scope gap, not just a bug**: `gate.py` walks only the theory tree, so it is blind
to `Tests/` — 231 violations, 39% of the work.

### 3.5 Measured auto-fix applicability

I ran `fix_long_line` in dry-run against all 598 live sites:

| Outcome | Count | % |
|---|---:|---:|
| Break applied | **595** | **99.5%** |
| Declined ("no legal break point") | 3 | 0.5% |
| Lines still >100 after one pass | 60 | 10% |

By area: `FS-other` 40/40 (100%), `Automation/` 326/327 (100%), `Tests/` 229/231 (99%).

So ~90% of sites are fully resolved by one mechanical pass; **~63 sites (60 residual + 3 declined)
need hand treatment** — roughly the inverse of the task's "expect to hand-fix three quarters".

### 3.6 Empirical validation (not just a dry run)

I applied the fixer for real to all 21 `FormalSystem/` non-`Automation/` files (the 40 rename
regressions), then built:

```
breaks applied: 40      residual >100: 0
lake build → Build completed successfully (1883 jobs)   EXIT=0
```

The working tree was then restored to its original content. This confirms the fixer emits
*compiling* Lean, not merely shorter lines, on the regression slice.

### 3.7 The residual 63

The 60 lines that survive a pass concentrate in string-heavy exporters:

| Count | File |
|---:|---|
| 23 | `FormalSystem/Automation/DatasetExport.lean` |
| 9 | `FormalSystem/Automation/TableauProofStepPipeline.lean` |
| 6 | `FormalSystem/Automation/DatasetGenerator.lean` |
| 6 | `FormalSystem/Automation/FormulaEnumerator.lean` |
| 3 | `FormalSystem/Automation/Tactics/Commands.lean` |
| 16 | tail across 10 files (≤2 each) |

Two shapes dominate:

- **Interpolated log strings** — e.g. `DatasetGenerator.lean:1304`
  `s!"Cache: {c.hits} hits, {c.misses} misses, {rateStr} hit rate, ..."` (116 chars). The spaces
  are all inside the string span, so no legal code break exists.
- **Embedded JSON schema literals** — `DatasetExport.lean` holds 23, e.g. a 129-char
  `"    {\"field\": \"formula_str\", \"format\": ...}"`.

Both are addressable, but by a technique `fixers.py` does not implement: Lean **string gaps** (a
trailing `\` inside a quotation continues the string on the next line, absorbing intervening
whitespace). The linter itself suggests this — `Style.lean:472-476` appends the string-gap hint
whenever the offending line contains a `"`. Adding a string-gap breaker to `fixers.py` would very
likely absorb most of the 63.

---

## 4. Verified No-Work Items

### 4.1 Copyright headers — CONFIRMED COMPLETE

Every one of the **330 live `.lean` files carries a `Copyright` line within its first three
lines. Zero missing.** (288/288 under `FormalSystem/`, 42/42 under `Tests/`.)

The task's "277 of 277" figure is simply an older, smaller denominator. The invariant holds; the
file count grew. **Record as verified. Do not re-add headers.**

### 4.2 Universe polymorphism — CONFIRMED EMPTY SET

- **Zero `universe` declarations** anywhere in the live tree. All 11 grep hits for `universe ` are
  English prose inside comments.
- `FormalSystem/Semantics/` uses `Type*` consistently — 34 occurrences.
- `FormalSystem/Semantics/Validity.lean:77` and `:101` both carry the explicit note
  *"Uses `Type` (not `Type*`) to avoid universe level issues in proofs"* — the deliberate
  monomorphization the prior research described, still documented in place.
- `FormalSystem/Metalogic/Decidability/CountermodelExtraction.lean:35` and
  `FormalSystem/Metalogic/SoundnessLemmas/Core.lean:30` document the same trade-off.

**Record as verified. Do not manufacture findings here.**

---

## 5. Verification Baseline

### 5.1 Build — currently green

```
lake build            → Build completed successfully (1883 jobs)   EXIT=0
lake build BimodalTest → Build completed successfully (1923 jobs)  EXIT=0
```

Pre-existing non-fatal noise: `linter.unusedVariables` warnings (e.g.
`DatasetGenerator.lean:2179`). These are sibling-owned and must be left **unchanged**.

### 5.2 Test invocation

`lakefile.lean:5` sets `testDriver := "BimodalTest"`, and `BimodalTest` is a `lean_lib`, not an
executable — `Tests/BimodalTest.lean` is a pure aggregator with **no `main`**. The suite is
**758 compile-time checks** (`#guard` / `example`) plus IO benchmark defs.

**Therefore `lake build BimodalTest` *is* the test run.** There is no separate execution step to
gate on, and `lake test` reduces to the same build.

### 5.3 The sole live `sorry`

A comment-stripped scan of the live tree finds **exactly one** `sorry`:

- **Declaration**: `countermodel_discrete`
- **File**: `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`
- **Line**: 1242 (drifts — locate by declaration name, never by line)

`gate.py:23` already encodes `EXPECTED_SORRY_DECL = 'countermodel_discrete'` and locates by
content; only its file constant needs the path correction from §3.4.

Note that a naive `grep -c sorry` over the live tree returns **287** — almost all of it prose in
docstrings ("sorry-free", "the sorry chain"). Any gate must strip comments first.

### 5.4 Proposed acceptance criteria

1. Live-tree codepoint violations = 0 (`FormalSystem/` non-Boneyard + `Tests/`).
2. `lake build` green, job count ≥ 1883, zero errors.
3. `lake build BimodalTest` green, job count ≥ 1923, zero errors.
4. Comment-stripped `sorry` count = 1, declaration `countermodel_discrete`.
5. Declaration inventory unchanged (`gate.py` `DECL_RE` census) — renames are out of scope.
6. Sibling-owned linter categories unchanged **by equality**, not merely "not increased".

---

## 6. Recommended Approach

The measured data supports a four-phase decomposition ordered by risk, each independently
buildable and committable.

**Phase 1 — repair the harness (blocking).** Fix the five staleness defects in §3.4, extend
`gate.py` to walk `Tests/`, and re-derive `baseline_snapshot.json`. Nothing downstream is
trustworthy until `lintlib.py` stops matching zero records.

**Phase 2 — the rename regression (40 sites, 21 files).** Already empirically validated end-to-end
in §3.6: fixer applies cleanly, residual 0, `lake build` green. This is the task's stated scope
item (2) and the highest-value slice.

**Phase 3 — `Automation/` (327 sites, 20 files).** Drive `sweep.py`'s per-file
lint → fix → re-lint → revert-on-regression loop. Expect ~50 residual sites, concentrated in
`DatasetExport.lean` (23) and `TableauProofStepPipeline.lean` (9).

**Phase 4 — `Tests/` (231 sites, 24 files).** Newly in scope and never swept before. Two thirds of
these lines touch string literals, so residual density is higher than `Automation/`. Gate on
`lake build BimodalTest`.

**Cross-cutting**: add a string-gap breaker to `fixers.py` (§3.7). It is the single change that
most reduces hand-fixing, and the linter's own message text specifies the technique.

### Zero-debt compliance

No step here requires `sorry`, and none is proposed. The sole live `sorry` is a pre-existing open
mathematical obligation in `countermodel_discrete`, explicitly out of scope and gated as an
*invariant to preserve* (count must remain exactly 1), not work to perform. No new axioms are
needed or suggested. This is mechanical source reformatting under a build gate throughout.

### Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| Harness reports vacuous zero from stale `Theories/` regex | **High if Phase 1 skipped** | Assert record count > 0 before trusting any census |
| A break silently reparses instead of erroring (do-notation `return`) | Low | `FORBIDDEN_TAIL` guard + `lake build` per file |
| Fixer edits drift a declaration name | Very low | `gate.py` declaration-inventory check |
| Trespass into sibling linter territory | Medium | Frozen-category equality check |
| String-heavy residual resists mechanical fixing | **Certain (~63 sites)** | String gaps; hand-fix the remainder |

---

## 7. Corrections to the Task Description

Recorded so the plan is built on measurement rather than the stale charter.

| Claim in task | Measured reality |
|---|---|
| "Automation/ carries 312 violations" | **327** (and was 453 pre-rename) |
| "ZERO violations anywhere outside Automation/" | **False.** `Tests/` 231, `FormalSystem/` other 40 |
| "Tiers took tier-1/2/3 to zero and hold them there" | 4 survivors pre-rename; `Tests/` never in any tier's scope |
| Tools at `specs/400_.../tools/` | Archived to `specs/archive/400_.../tools/` |
| "Mathlib's fixer measured 25.1%; expect to hand-fix three quarters" | Archived `fixers.py` (not Mathlib's) is **99.5%** applicable; hand-fix ~11% |
| "277 of 277 files carry Copyright" | **330 of 330** — invariant holds, denominator grew |
| Per-file counts (ProofStepExport 65, DatasetGenerator 51, …) | ProofStepExport **83**, DatasetGenerator 51, FormulaMutator 43, FormulaEnumerator 41, DatasetExport 30, ProofFirstBenchmark 15, Tactics/Commands 14, TableauProofStepPipeline 13 |
| `awk 'length>100'` as the counting method | Locale-dependent; counts **bytes** in C locale → 2116 vs. true 598 |

---

## 8. References

- `.lake/packages/mathlib/Mathlib/Tactic/Linter/Style.lean:420-483` — `longLine` linter: 100-char
  default, codepoint column, `http`/`import` exemptions, string-gap hint
- `specs/archive/400_clear_lean_v433_deprecation_warnings/tools/fixers.py:1-414` — break engine
  and the seven line-breaking guards
- `specs/archive/400_clear_lean_v433_deprecation_warnings/tools/lintlib.py:21-29` — `REPO`
  resolution and the two stale path regexes, with the vacuous-zero warning
- `specs/archive/400_clear_lean_v433_deprecation_warnings/tools/gate.py:1-40` — end-state gate
  contract; sorry-by-content rationale
- `lakefile.lean:1-20` — `FormalSystem` / `BimodalTest` targets, `testDriver`
- `FormalSystem/FormalSystem.lean:33-37` — both Boneyard trees excluded from the build
- `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1207-1242` — `countermodel_discrete`, the
  sole live `sorry`, with its open-obligation rationale
- `FormalSystem/Semantics/Validity.lean:77,101` — documented deliberate monomorphization
- Pre-rename baseline commit: `b7a2f6f88`
