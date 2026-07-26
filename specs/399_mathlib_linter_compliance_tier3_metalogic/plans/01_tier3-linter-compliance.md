# Implementation Plan: Task #399

- **Task**: 399 - mathlib_linter_compliance_tier3_metalogic
- **Status**: [IMPLEMENTING]
- **Effort**: 21 hours
- **Dependencies**: None (coordinates with naming task 394 and deprecation task 400 by scope exclusion only)
- **Research Inputs**: `specs/399_mathlib_linter_compliance_tier3_metalogic/reports/01_tier3-linter-inventory.md`, plus machine baselines `baseline/{scope-tier3.txt, per-file-categories.json, style-warnings.json, runlinter-findings.json, parse-style-log.py}`
- **Artifacts**: plans/01_tier3-linter-compliance.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Bring the 174-file tier-3 Metalogic surface to Mathlib linter compliance by clearing **4,651
distinct edit sites** (not the 6,079 raw diagnostics) across a **142-file working set**
(32 files are already clean). 80.8% of the surface — 3,754 sites — is scripted with five fixers
that research validated to zero on scratch copies at 0 errors; 253 `linter.flexible` sites use a
validated bulk harvest/apply workflow; 244 sites are genuine judgment or authoring work; and 380
sites (`unusedArguments`, `unusedInstInType`) are accepted as ledgered API residuals following
the sibling task's precedent. Definition of done: every in-scope category absent from all 174
files under a **differential** per-file gate, `lake build` green at 0 errors, and exactly 1 live
sorry — unchanged — at `Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:1227`.

### Research Integration

Every phase boundary and site count below is taken from `baseline/per-file-categories.json`
rather than restated from prose. The findings that shape this plan:

- **`linter.style.show` is mechanical, not judgment.** 449 sites. The linter fires only on `show`
  invocations that changed the goal, and its own suggestion is a position-exact `show` → `change`
  token substitution, validated 166/166 across 4 files at 0 errors with zero collateral category
  movement. Hand-editing these is the single largest avoidable cost in the task.
- **Size by distinct sites, never raw counts.** `unusedDecidableInType` and `unusedFintypeInType`
  fire on the *same declaration* 173 times out of 185/175: summing (360) over-sizes by 92% versus
  unioning (187). Likewise `unusedTactic` ∪ `unreachableTactic` is 24 sites, not 44.
- **The `flexible` bulk workflow is validated end-to-end**: inject `?` at all flagged sites in a
  file → **one** elaboration harvests every `Try this` → apply → re-lint. On `UltrafilterMCS.lean`
  this took 41 raw / 14 sites → 0 with every other category byte-identical, 0 errors, using 3
  `lake` calls instead of ~42.
- **The gate must be differential.** 51 files retain `push_neg` deprecations and 87 retain
  `defsWithUnderscore` by design; a silence-based gate fails spuriously on all of them.
- **Two inherited lessons were re-tested and re-scoped.** The `emptyLine`-rises-after-wrapping
  hazard did **not** reproduce (36 → 36 after wrapping; 36 → 0 in one pass, no unmasking) — no
  iteration budget for it. `flexible` unmasking is real but milder here (1.45× raw/site collapse
  vs the sibling's 1.90×) — budget the extra fixpoint pass for ~6 concentrated files, not all 42.
- **`fix_long_lines.py` is worse here**: only 25.1% comma-applicability vs ~42% in tier-1/2, so a
  purpose-built last-space breaker is required. `fix_unused.py` is stale against v4.33 (its regex
  expects `unused variable \`x\``; Lean emits `Variable name \`x\` is not explicitly referenced.`)
  — but the `_`-prefix insertion is still scripted, validated 16/16, not hand-fixed.

### Prior Plan Reference

No prior plan. Effort calibration and the residual-acceptance precedent are inherited from the
completed tier-1/tier-2 sibling task, via the research report rather than a plan artifact.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:

- Clear all 3,754 mechanical sites (`longLine` 2,740, `show` 449, `unusedSimpArgs` 300,
  `unusedVariables` 152, `emptyLine` 113) with scripted, differentially-gated fixers.
- Clear all 253 `linter.flexible` sites to fixpoint across 42 files.
- Clear the 244-site judgment/authoring bucket: 68 rcases `unused name:`, 52 `docBlame`
  docstrings, 34 `unusedSectionVars`, 24 `unusedTactic` ∪ `unreachableTactic`, 18 `multiGoal`,
  17 `maxHeartbeats` justifications, 5 `classDefReducibility`, and 26 singletons including the
  one genuine `simpNF` finding at `NfEFold.lean:132`.
- Preserve the build invariant at every phase boundary: `lake build` 0 errors, exactly 1 live
  sorry at `Transfer.lean:1227`.
- Produce a written residual ledger for the 380 accepted sites and the 6 `simpNF LINTER FAILED`
  artifacts, so the acceptance is an explicit API decision rather than deferred work.

**Non-Goals**:

- **All naming work.** `linter.defProp` (35) and `linter.dupNamespace` (13) belong to naming task
  394, whose charter explicitly claims the def→theorem conversions as its own first phase. Record
  as out-of-scope, never as residuals of this task.
- **`runLinter defsWithUnderscore`** (572) — naming task 394.
- **`push_neg` deprecation warnings** (521) — deprecation task 400.
- **`Boneyard/`** (154 files, unbuilt and inert) and **`Automation/`** (36 files, excluded by
  charter). In particular, do not touch the looping `@[simp] neg_unfold` at
  `Automation/Normalization.lean:69` that is the root cause of the 6 `simpNF LINTER FAILED`
  artifacts observed in scope.
- **Altering the sorry count.** `countermodel_discrete` at `Transfer.lean:1227` is out of scope by
  charter and serves only as a build tripwire.
- **Editing the 380 residual signatures.** Removing `[DecidableEq α]`/`[Fintype α]` and the
  unused frame-class parameters would change 380 public signatures across the Kamp/EFGames API
  and risks proof breakage; the sibling task ruled the same category load-bearing.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Silence-based gate used instead of differential; every file "fails" on out-of-scope deprecations | H | M | Gate is a per-file **category-count** diff (Phase 1 harness). Pass = in-scope categories absent AND no other category's count increased AND `grep -cE ': error:'` is 0. Never grep for an empty log. |
| Phase sized by raw emission count (6,079) or by summed `unusedInstInType` (360) | H | M | Every phase in this plan is sized from `baseline/per-file-categories.json` distinct-site counts, restated inline. Union, never sum. |
| Line-breaking introduces silent reparses (`return`/`pure`/`throw`/`yield` left last on a line takes an optional argument) | H | L | Encoded as hard rules in the Phase 1 breaker (see "Line-breaking edit rules"); build gate catches survivors. Only 8 of 2,740 sites are code-with-trailing-comment. |
| `simp?` suggestions blind-zipped to `flexible` sites | H | M | Branching proofs elaborate a site twice with differing suggestions (observed 15-for-14). Reconcile by source position within the declaration and union the lemma lists; verify by elaboration, never by count. |
| Transcribed `simp only [...]` lists regress `longLine` | M | H | Phase 2 (`flexible`) runs **before** all `longLine` sweeps. 35 of the 42 flexible files also carry `longLine`. |
| `flexible` unmasking (new sites appear after fixing) | M | M | Per-file iterate to fixpoint; 253 is a lower bound. Extra pass budgeted for the 8 concentrated files (`PointInsertion` 23, `EANegation` 23, `VecEAClosure` 16, `UltrafilterMCS` 14, `GapDetection` 14, `EANegationClosure` 14, `NfDepth0Generalized` 14, `NEquivalence` 13). |
| Mathlib `fix_long_lines.py` / `fix_unused.py` used as-is | M | M | Both are recorded dead ends. Build a purpose-built breaker; `fix_unused.py` is stale against v4.33 phrasing. |
| `runLinter` run per file (it is a whole-library, ~7 min invocation) | M | M | Gate `docBlame`/`unusedArguments`/`simpNF` at phase boundaries only, diffing `baseline/runlinter-findings.json`. |
| Context exhaustion mid-phase on the 88-file Phase 4 | M | M | Phases carry an explicit file list; the fixer writes a per-file completion log so a successor resumes from the first unprocessed file. Commit at every green build. |
| Wrong build target used | L | L | Targets are `Bimodal.*`, **not** `Theories.Bimodal.*` (`srcDir := "Theories"`, `roots := #[\`Bimodal]`). |

### Line-breaking edit rules (binding on Phases 1-6)

These are not style preferences; each was caught by a build gate previously.

1. Never leave `return`, `pure`, `throw`, or `yield` as the last token on a line. In do-notation
   `return` takes an **optional** argument, so the wrap silently reparses instead of erroring.
2. Never wrap a trailing `--` comment as if it were code. Split it onto further comment lines.
3. Never place a docstring between an attribute and its declaration — that is a parse error.
4. Break at the last space before column 100; continuation indent +4.
5. Doc-comment and block-comment prose (456 sites, 16.6%) is rewrapped as prose, not as code.

### Differential gate (binding on all phases)

```bash
# per-file category census -- stable under the line renumbering every edit causes
lake env lean -Dlinter.mathlibStandardSet=true "$f" 2>&1 \
  | grep -oE 'set_option linter\.[a-zA-Z.]+' | sed 's/set_option //' | sort | uniq -c
```

Four in-scope things carry **no** `set_option linter.X false` footer and must be matched by
message text separately: the rcases `unused name:` warnings (68), the `Try this: intro …` rintro
suggestions (6), `warn.classDefReducibility` (5), and `declaration uses 'sorry'` (1 — this
doubles as the sorry-census tripwire).

**Invariant checked at every phase boundary**:

```bash
lake build                                          # 0 errors
grep -c "declaration uses 'sorry'" <sweep-output>   # must be exactly 1
```

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4, 5, 6 | 1, 2 |
| 4 | 7 | 4, 5, 6 |
| 5 | 8 | 7 |
| 6 | 9 | 8 |
| 7 | 10 | 9 |

Phases within the same wave can execute in parallel. Phases 2 and 3 are territory-disjoint
(`SharedWitness.lean` has zero `flexible` sites). Phases 4, 5, and 6 partition the remaining file
set disjointly and are safe for parallel dispatch under a territory contract.

**Dispatch mapping** (5-7 dispatches expected; phase boundaries are the resume points):
D1 = Phase 1 + Phase 3 · D2 = Phase 2 · D3 = Phase 4 · D4 = Phase 5 + Phase 6 ·
D5 = Phase 7 + Phase 8 · D6 = Phase 9 + Phase 10.

---

### Phase 1: Fixer toolkit, differential-gate harness, and pilot [COMPLETED]

**Goal**: Build the five validated fixers plus the differential gate, and prove them end-to-end on
two files whose exact before/after counts are already known from research.

**Tasks**:
- [x] Re-run the 174-file baseline sweep into this phase's own log; confirm it reproduces *(completed — logs/census-origin.json reconciles +0 on every style category)*
      `baseline/per-file-categories.json` (4,651 in-scope sites) and that `lake build` is green
      with exactly 1 `declaration uses 'sorry'`.
- [x] Implement the per-file differential gate exactly as specified above, including the four *(completed — tools/lintlib.py gate())*
      message-text-matched categories that carry no `set_option` footer.
- [x] Implement fixer `show`: position-exact `show` → `change` substitution at the reported *(completed — 6/6 on pilot 2)*
      `(line, col)`. Validated 166/166.
- [x] Implement fixer `unusedSimpArgs`: delete the argument at `(line, col)` up to the next *(completed — tools/fixers.py)*
      depth-0 `,` or `]`; collapse `simp []` → `simp`. Validated 45/45.
- [x] Implement fixer `unusedVariables`: insert `_` before the identifier at `(line, col)`. *(completed — tools/fixers.py)*
      Validated 16/16. Do **not** use Mathlib's `fix_unused.py` — it is stale against v4.33.
- [x] Implement fixer `emptyLine`: delete the flagged line. Validated → 0 in one pass. *(completed — 55/55 on pilots)*
- [x] Implement fixer `longLine`: purpose-built last-space breaker at column 100, continuation *(deviation: altered — added bracket-depth-aware break selection on top of the specified last-space rule; last-space alone produced valid but poor splits)*
      indent +4, enforcing all five line-breaking edit rules above. Do **not** use Mathlib's
      `fix_long_lines.py` (25.1% applicability here). Handle the three composition classes
      separately: 80.7% code, 16.6% block/doc-comment prose, 1.8% line comments; treat the 8
      code-with-trailing-comment sites as the documented hazard.
- [x] Make the fixer driver write a per-file completion log so an interrupted phase resumes from *(completed — logs/phase1.jsonl)*
      the first unprocessed file.
- [x] Apply the toolkit to the two pilot files and gate them: *(completed — 49 and 47 sites, both to zero warnings of any kind)*
      `Metalogic/Bundle/WitnessSeed.lean` (36 emptyLine + 13 longLine = 49 sites) and
      `Metalogic/Bundle/CanonicalTaskRelation.lean` (19 emptyLine + 20 longLine + 6 show = 45
      sites). Expected: both → 0 in-scope, 0 errors, no other category increased.
- [x] Record the 2 `simpNF LINTER FAILED` artifacts in `CanonicalTaskRelation.lean` as ledger *(completed — logs/ledger-notes.md)*
      entries; do not attempt to fix them.

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/WitnessSeed.lean` — 49 mechanical sites
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` — 45 mechanical sites
- Fixer/gate scripts under the task directory (not under `Theories/`)

**Verification**:
- Both pilot files show zero in-scope categories under the differential gate and no increase in
  any out-of-scope category.
- `lake build` 0 errors; sorry census exactly 1.
- Commit at green.

---

### Phase 2: `linter.flexible` — bulk harvest, apply, iterate to fixpoint [NOT STARTED]

**Goal**: Clear all 253 `flexible` sites across 42 files **before** any `longLine` sweep, so
transcribed `simp only` lists are wrapped afterward rather than regressing already-wrapped lines.

**Tasks**:
- [ ] For each of the 42 files, in per-file order: fix that file's `unusedSimpArgs` first (dead
      simp arguments shrink the lists `simp?` will regenerate), then run the bulk workflow.
- [ ] Bulk workflow per file: inject `?` after every flagged `simp` in a scratch copy (all sites
      at once) → `lake env lean <copy>` harvests all `Try this: simp only [...]` suggestions in
      **one** elaboration → substitute each suggestion for its original tactic (extent = from
      `(line, col)` to the next depth-0 `;` or closing bracket) → re-lint.
- [ ] **Reconcile, do not blind-zip.** The suggestion count can exceed the site count (15-for-14
      observed) because a site inside a branching proof elaborates more than once and can emit
      differing suggestions; union the lemma lists and verify by elaboration. Suggestion positions
      in the log are not co-located with the suggestion text — the `[apply]` payload is on the
      line after a bare `Try this:` whose position header may belong to an earlier diagnostic, so
      match by order within a declaration.
- [ ] Iterate to fixpoint per file (253 is a lower bound). Budget the extra pass for the 8
      concentrated files only: `PointInsertion` 23, `EANegation` 23, `VecEAClosure` 16,
      `UltrafilterMCS` 14, `GapDetection` 14, `EANegationClosure` 14, `NfDepth0Generalized` 14,
      `NEquivalence` 13.
- [ ] Leave the `longLine` sites in these files alone — Phases 4-6 own them.

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- 42 files carrying `linter.flexible`, 253 sites; 35 of them also carry `longLine` and are the
  reason for this ordering.

**Verification**:
- `flexible` = 0 in all 42 files under re-lint; every other category unchanged or lower.
- `lake build` 0 errors; sorry census exactly 1. Commit at green.

---

### Phase 3: `SharedWitness.lean` mechanical sweep [COMPLETED]

**Goal**: Clear the single largest file in the task — 15.7% of the whole surface — in isolation.

**Tasks**:
- [ ] `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean`
      (12,801 LOC): apply the fixers in per-file order `unusedSimpArgs` (59) → `show` (43) →
      `unusedVariables` (19) → `longLine` (583). No `flexible` and no `emptyLine` in this file,
      so it is territory-disjoint from Phase 2 and can run in parallel with it.
- [x] Gate differentially. Expected residuals in this file, untouched: 14 `unusedArguments`, *(completed — residuals exactly as predicted: 18 push_neg, 9 unusedInstInType(union), 1 whitespace)*
      9 `unusedInstInType`, 1 `docBlame`, 18 `push_neg` deprecations, 1 `whitespace` (Phase 7).
- [x] Because of the file's size, checkpoint and commit mid-file if the build is green. *(deviation: skipped — the whole file swept in one 27s pass, so no mid-file checkpoint was needed)*

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `.../Kamp/NfMultiAnchorBridge/SharedWitness.lean` — **704 mechanical sites**

**Verification**:
- All five mechanical categories = 0 in this file; no other category increased.
- `lake build` 0 errors; sorry census exactly 1. Commit at green.

---

### Phase 4: `WeakCanonical/Kamp/**` mechanical, remainder of subtree [NOT STARTED]

**Goal**: Clear the largest territory: 88 files (68 dirty), **1,359 mechanical sites**.

**Tasks**:
- [ ] Apply the toolkit file-by-file in per-file order `unusedSimpArgs` (68) → `show` (188) →
      `unusedVariables` (34) → `longLine` (1,069). `flexible` in this subtree was already cleared
      in Phase 2; do not re-run it.
- [ ] Territory contract: `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/**` **excluding**
      `NfMultiAnchorBridge/SharedWitness.lean` (Phase 3).
- [ ] Named hotspots to expect: `NfMultiAnchorBridge/Base.lean` (135 longLine),
      `NfMultiAnchorBridge/InteriorGateGeneralK.lean` (133 longLine),
      `NfMultiAnchorBridge/SubBracket2V.lean` (92 longLine).
- [ ] Do not touch `maxHeartbeats` (11 of the 17 live in `InteriorGateGeneralK.lean`) or
      `multiGoal` — Phase 7 owns them.
- [ ] Commit per green build; the per-file completion log makes this resumable.

**Timing**: 2.5 hours

**Depends on**: 1, 2

**Files to modify**:
- 88 files under `Theories/Bimodal/Metalogic/WeakCanonical/Kamp/`, minus `SharedWitness.lean`

**Verification**:
- All five mechanical categories = 0 across the 88 files; no other category increased.
- `lake build` 0 errors; sorry census exactly 1. Commit at green.

---

### Phase 5: `BXCanonical/**` + `Bundle/` + `Algebraic/` mechanical [NOT STARTED]

**Goal**: Clear 40 files (34 dirty), **810 mechanical sites**, including 57 of the remaining 58
`emptyLine` sites.

**Tasks**:
- [ ] Apply the toolkit in per-file order `unusedSimpArgs` (17) → `show` (123) →
      `unusedVariables` (35) → `longLine` (578) → **`emptyLine` last** (57), because `emptyLine`
      is position-driven and cheapest to re-derive after all other edits have moved lines.
- [ ] Territory contract: `Metalogic/BXCanonical/**` + `Metalogic/Bundle/` + `Metalogic/Algebraic/`,
      **excluding** the two Phase 1 pilot files (`Bundle/WitnessSeed.lean`,
      `Bundle/CanonicalTaskRelation.lean`), which should re-gate as no-ops.
- [ ] Named hotspot: `BXCanonical/Chronicle/CounterexampleElimination.lean` (108 longLine +
      74 show; its 16 `docBlame` are Phase 8).
- [ ] Do **not** touch `linter.defProp` (35) or `linter.dupNamespace` (13, all in
      `BXCanonical/Chronicle/ChronicleTypes.lean`) — reserved for naming task 394.
- [ ] Record the 4 `simpNF LINTER FAILED` artifacts in `Bundle/TemporalContent.lean` as ledger
      entries.

**Timing**: 2 hours

**Depends on**: 1, 2

**Files to modify**:
- 40 files under `Metalogic/{BXCanonical,Bundle,Algebraic}/`

**Verification**:
- All five mechanical categories = 0 across the territory; `defProp`/`dupNamespace` counts
  **unchanged** (they must not go down — that would mean Phase 5 trespassed on task 394).
- `lake build` 0 errors; sorry census exactly 1. Commit at green.

---

### Phase 6: `Expressiveness` + `EFGames` + `IntegerModel` + `WeakCanonical` top-level + umbrella [NOT STARTED]

**Goal**: Clear the last mechanical territory: 43 files (35 dirty), **787 mechanical sites**.

**Tasks**:
- [ ] Apply the toolkit in per-file order `unusedSimpArgs` (156) → `show` (89) →
      `unusedVariables` (64) → `longLine` (477) → `emptyLine` (1, in
      `IntegerModel/ReynoldsBridge.lean`).
- [ ] Territory contract: `Metalogic/WeakCanonical/{Expressiveness,EFGames,IntegerModel}/` +
      `Metalogic/WeakCanonical/` top-level files + the 7 umbrella modules + `Examples/`.
- [ ] Named hotspot: `Expressiveness/SplitPoint.lean` (188 longLine — the second-densest
      `longLine` file in the task).
- [ ] Do **not** touch `Expressiveness/CaseAnalysis.lean` lines 502-503 (68 rcases
      `unused name:` sites) — Phase 7 owns them. Its 16 `longLine` and 15 `unusedSimpArgs` are in
      scope here.

**Timing**: 2 hours

**Depends on**: 1, 2

**Files to modify**:
- 43 files across `Metalogic/WeakCanonical/{Expressiveness,EFGames,IntegerModel}/`,
  `Metalogic/WeakCanonical/` top level, the umbrella modules, and `Examples/`

**Verification**:
- All five mechanical categories = 0 across the territory; no other category increased.
- Full 174-file mechanical census = 0 (Phases 1, 3, 4, 5, 6 together cover all 3,754 sites).
- `lake build` 0 errors; sorry census exactly 1. Commit at green.

---

### Phase 7: Judgment sweep [NOT STARTED]

**Goal**: Clear the 186 remaining judgment sites (`docBlame` is Phase 8, residuals are Phase 9).

**Tasks**:
- [ ] **rcases `unused name:` — 68 sites**, all in `Expressiveness/CaseAnalysis.lean` lines
      502-503: two enormous `obtain` patterns with dozens of `_`/named binders. Emitted by
      `rcases` itself; **no `set_option` exists to silence it**. One focused edit to the two
      patterns; verify by elaboration.
- [ ] **`unusedSectionVars` — 34 sites**, 6 files: `AggregateOffDiagK1.lean` 14,
      `ExteriorNavFutK1.lean` 6, `TemporalCoherence.lean` 5, `ExteriorNavPastK1.lean` 5,
      `ParametricCanonical.lean` 3, `ParametricTruthLemma.lean` 1. Resolve with `include`/`omit`
      or signature restructuring — each is a semantic call, not a substitution.
- [ ] **`unusedTactic` ∪ `unreachableTactic` — 24 sites** (union, not 44), 4 files:
      `Decomposition.lean` 8, `StaviCompleteness.lean` 8, `NfDepth0Generalized.lean` 6,
      `SplitPoint.lean` 2. Delete the dead tactic; both linters clear together.
- [ ] **`style.multiGoal` — 18 sites**, 4 files: `NfDepth0Generalized.lean` 7,
      `SubBracket2V.lean` 5, `ChronicleToCountermodel.lean` 4, `GapDetection.lean` 2. Restructure
      with `·` focus dots or `case`.
- [ ] **`style.maxHeartbeats` — 17 sites**, 5 files: `InteriorGateGeneralK.lean` 11,
      `KampPrior.lean` 2, `ExteriorGateAssembleK.lean` 2, `SplitPoint.lean` 1,
      `EndIntervalConsumerK.lean` 1. Each requires **writing a justification comment**, not
      removing the option.
- [ ] **`classDefReducibility` — 5 sites**, 2 files: `@[instance_reducible]` decision per instance.
      Not a `linter.*` option, so not silenceable by the standard set — match by message text.
- [ ] **Singletons — 15 sites**: `openClassical` 3, `style.setOption` 2, `unnecessarySimpa` 2,
      genuine `simpNF` at `WeakCanonical/Kamp/NfEFold.lean:132` (`skipFin_zero_succ`, "Left-hand
      side simplifies from…") 1, `style.docString` 1, `style.whitespace` 1
      (in `SharedWitness.lean`), `unnecessarySeqFocus` 1, `synTaut` 1, plus the 6 rintro
      `Try this: intro …` suggestions matched by message text.
- [ ] **Ledger, do not fix**: the 6 `simpNF LINTER FAILED` artifacts
      (`Bundle/CanonicalTaskRelation.lean` ×2, `Bundle/TemporalContent.lean` ×4). Root cause is
      the looping `@[simp] neg_unfold` at `Automation/Normalization.lean:69`, which is out of
      scope. Do not touch it.

**Timing**: 2.5 hours

**Depends on**: 4, 5, 6

**Files to modify**:
- ~20 files, concentrated in `CaseAnalysis.lean`, `AggregateOffDiagK1.lean`,
  `InteriorGateGeneralK.lean`, `NfDepth0Generalized.lean`, `Decomposition.lean`,
  `StaviCompleteness.lean`

**Verification**:
- Per-file differential gate clean for all touched files, including the four message-text-matched
  categories.
- `lake exe runLinter Bimodal` diffed against `baseline/runlinter-findings.json`: `simpNF` genuine
  finding gone, `unusedTactic` findings gone, nothing new appeared.
- `lake build` 0 errors; sorry census exactly 1. Commit at green.

---

### Phase 8: `docBlame` — author 52 docstrings [NOT STARTED]

**Goal**: Genuine authoring work: 52 docstrings across 14 files.

**Tasks**:
- [ ] Write docstrings for all 52 flagged declarations. Distribution:
      `CounterexampleElimination.lean` 16, `CanonicalModel.lean` 11, `PointInsertion.lean` 6,
      `MonadicFO.lean` 4, then 2 each in `LindenbaumQuotient.lean`, `Construction.lean`,
      `Realization.lean`, `ConjInterleave.lean`, `VecEATranslation.lean`, and 1 each in
      `ExistsForallNF.lean`, `PriorInterface.lean`, `SharedWitness.lean`, `SubBracket2.lean`,
      `Transfer.lean`.
- [ ] Includes notation declarations (`«term_≈ₚ_»`, `«term⟦_⟧»`), which need prose describing the
      notation rather than the underlying definition.
- [ ] **Never place a docstring between an attribute and its declaration** — that is a parse error.
- [ ] Keep every new docstring line under 100 characters so this phase does not reintroduce
      `longLine` sites.

**Timing**: 2 hours

**Depends on**: 7

**Files to modify**:
- 14 files listed above

**Verification**:
- `lake exe runLinter Bimodal` diffed against `baseline/runlinter-findings.json`: `docBlame` in
  tier-3 goes 52 → 0; the 39 `Automation/` `docBlame` findings are **unchanged** (out of scope).
- Per-file differential gate shows no new `longLine`.
- `lake build` 0 errors; sorry census exactly 1. Commit at green.

---

### Phase 9: Residual decision and ledger [NOT STARTED]

**Goal**: Convert the 380 accepted sites from silent leftovers into an explicit, written API
decision.

**Tasks**:
- [ ] **Decision: accept as residuals**, following the completed sibling task's precedent, where
      the same category proved to be frame-class-indexing typeclass instances whose removal would
      collapse the stratified API. Accepting collapses judgment work from 640 → 260 sites and
      makes this task ~86% scripted; attempting the signature edits instead adds 2-3 dispatches
      and risks proof breakage across 380 public signatures.
- [ ] Write `specs/399_mathlib_linter_compliance_tier3_metalogic/RESIDUALS.md` covering:
      **`runLinter unusedArguments`** — 193 sites, 52 files (spot-checked
      `parametric_task_rel_*`, `parametric_canonical_truth_lemma`: the same `1 unused argument`
      frame-class/parameter pattern the sibling ruled load-bearing API documentation);
      **`unusedDecidableInType` ∪ `unusedFintypeInType`** — 187 sites (union, **not** the 360 raw
      sum), 33 files, `[DecidableEq α]`/`[Fintype α]` present in a signature but unused in the
      type, same family; **6 `simpNF LINTER FAILED` artifacts** with root cause named.
- [ ] Record the out-of-scope handoffs so a reader does not mistake them for this task's debt:
      `defProp` 35 and `dupNamespace` 13 → task 394; `defsWithUnderscore` 572 → task 394;
      `push_neg` deprecations 521 → task 400.
- [ ] State explicitly that this is a ledgered API decision, not deferred work: no `sorry` was
      introduced, no axiom added, no proof left partial.

**Timing**: 1 hour

**Depends on**: 8

**Files to modify**:
- `specs/399_mathlib_linter_compliance_tier3_metalogic/RESIDUALS.md` (new)

**Verification**:
- `lake exe runLinter Bimodal` diff shows `unusedArguments` and `unusedInstInType` **unchanged**
  from baseline (the decision is to accept, so any change means an unintended edit).
- Ledger file exists, is non-empty, and names every accepted category with its count and rationale.

---

### Phase 10: Global sweep and closeout [NOT STARTED]

**Goal**: Prove the whole 174-file surface against the recorded baseline in one pass.

**Tasks**:
- [ ] Full 174-file sweep with `-Dlinter.mathlibStandardSet=true`; produce a per-file category
      census and diff it against `baseline/per-file-categories.json`.
- [ ] Confirm every in-scope category is at 0 across all 174 files: `longLine`, `show`,
      `unusedSimpArgs`, `unusedVariables`, `emptyLine`, `flexible`, `unusedSectionVars`,
      `unusedTactic`/`unreachableTactic`, `multiGoal`, `maxHeartbeats`, `classDefReducibility`,
      `openClassical`, `setOption`, `unnecessarySimpa`, `docString`, `whitespace`,
      `unnecessarySeqFocus`, `synTaut`, genuine `simpNF`, rcases `unused name:`, rintro
      `Try this: intro`.
- [ ] Confirm every out-of-scope category is **unchanged, not reduced**: `push_neg` 521,
      `defsWithUnderscore` 572, `defProp` 35, `dupNamespace` 13. A reduction here means this task
      trespassed on task 394 or 400.
- [ ] `lake exe runLinter Bimodal` full diff against `baseline/runlinter-findings.json`:
      `docBlame` 52 → 0, `unusedArguments` 193 unchanged, `unusedInstInType` 187 unchanged,
      `simpNF` genuine 1 → 0, `LINTER FAILED` 6 unchanged.
- [ ] Final `lake build`: 0 errors, 1875 jobs, and exactly 1 `declaration uses 'sorry'` at
      `WeakCanonical/Transfer.lean:1227`.
- [ ] Write `summaries/01_tier3-linter-compliance-summary.md` with before/after category tables
      and a pointer to `RESIDUALS.md`.

**Timing**: 1.5 hours

**Depends on**: 9

**Files to modify**:
- `specs/399_mathlib_linter_compliance_tier3_metalogic/summaries/01_tier3-linter-compliance-summary.md`
  (new)

**Verification**:
- The three differential diffs above all pass.
- `lake build` green; sorry census exactly 1. Final commit.

---

## Testing & Validation

- [ ] `lake build` returns 0 errors at every phase boundary (targets are `Bimodal.*`, **not**
      `Theories.Bimodal.*`).
- [ ] `grep -c "declaration uses 'sorry'"` on the full sweep returns exactly **1** at every phase
      boundary, at `WeakCanonical/Transfer.lean:1227`. Never 0, never 2.
- [ ] Per-file differential gate passes for every touched file: in-scope categories absent AND no
      other category's count increased AND `grep -cE ': error:'` is 0.
- [ ] The four footer-less categories (rcases `unused name:`, rintro `Try this: intro`,
      `warn.classDefReducibility`, `declaration uses 'sorry'`) are matched by message text, not by
      the `set_option` grep.
- [ ] `lake exe runLinter Bimodal` (whole-library, ~7 min, exit code 1 by design) diffed against
      `baseline/runlinter-findings.json` at the Phase 7, 8, 9, and 10 boundaries only — never
      per file.
- [ ] Out-of-scope counts unchanged at close: `push_neg` 521, `defsWithUnderscore` 572,
      `defProp` 35, `dupNamespace` 13, `Automation/` `docBlame` 39, `LINTER FAILED` 6.
- [ ] Mechanical total reconciles: 49 + 45 (Phase 1) + 704 (Phase 3) + 1,359 (Phase 4) + 810
      (Phase 5) + 787 (Phase 6) = **3,754**.

## Artifacts & Outputs

- `specs/399_mathlib_linter_compliance_tier3_metalogic/plans/01_tier3-linter-compliance.md` (this file)
- `specs/399_mathlib_linter_compliance_tier3_metalogic/RESIDUALS.md` (Phase 9)
- `specs/399_mathlib_linter_compliance_tier3_metalogic/summaries/01_tier3-linter-compliance-summary.md` (Phase 10)
- Fixer and gate scripts under the task directory (Phase 1) — not under `Theories/`
- Per-phase before/after category censuses, retained for the differential diffs
- Modified sources: 142 files under `Theories/Bimodal/Metalogic/`, `Theories/Bimodal/Examples/`,
  and the 7 umbrella modules

## Rollback/Contingency

- Every phase commits only at a green build, so `git revert` of a phase commit restores a known-good
  state. Phases 3-6 partition the file set disjointly, so a single territory can be reverted without
  disturbing the others.
- If the `longLine` breaker mangles doc-comment prose (456 sites, the largest non-code class),
  revert that phase's commit and re-run with the breaker restricted to the 80.7% code class; treat
  the prose sites as a separate, hand-checked pass rather than iterating the script in place.
- If `flexible` fails to reach fixpoint on a concentrated file after two passes, revert that file
  and fall back to per-site `simp?` on it alone; do not let one file block the other 41.
- If any phase drives the sorry census off 1, that is a hard stop: revert the phase commit
  immediately rather than investigating forward. The sorry count is an invariant, not a metric.
- If `runLinter` shows `unusedArguments` or `unusedInstInType` moving, an unintended signature edit
  landed — revert and re-gate, since the accepted-residual decision depends on those counts being
  untouched.
