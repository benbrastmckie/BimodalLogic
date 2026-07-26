# Tier-3 Metalogic Linter Compliance — Re-Derived Inventory and Phase Design

- **Task**: 399 — mathlib_linter_compliance_tier3_metalogic
- **Type**: lean4
- **Session**: sess_1785074764_351b3f_399
- **Date measured**: 2026-07-26, working tree at `2cbc1b66e` (clean)
- **Toolchain**: Lean v4.33.0-rc1, Mathlib tag `v4.33.0-rc1` (resolved `79d0395a`)

Machine-readable baselines written alongside this report:

| File | Contents |
|------|----------|
| `../baseline/scope-tier3.txt` | The 174 in-scope file paths |
| `../baseline/per-file-categories.json` | Per-file, per-category **distinct-site** counts |
| `../baseline/style-warnings.json` | All 5,254 style warnings as `[file, line, col, category, message]` |
| `../baseline/runlinter-findings.json` | All 1,304 `runLinter` findings as `[linter, file, line, message]` |
| `../baseline/parse-style-log.py` | The parser that produced the above |

---

## 0. Verified starting state

| Invariant | Value |
|-----------|-------|
| `lake build` | **0 errors, 1875 jobs, green** |
| Live sorries | **exactly 1** — `WeakCanonical/Transfer.lean:1227` (`countermodel_discrete`), confirmed by a `declaration uses 'sorry'` warning appearing exactly once across the whole 174-file sweep |
| Files under `Boneyard/` | 154 (unbuilt, excluded) |
| Files under `Automation/` | 36 (excluded by charter) |

All three staleness corrections in the dispatch brief are confirmed against fresh measurement.

---

## 1. Scope re-derivation and delta against the stale 166 / 6,136

Scope = `Theories/Bimodal/**/*.lean` minus `Boneyard/` minus `Automation*` minus the 67 files
already handled by the tier-1/tier-2 pass (`specs/293_.../baseline/scope.txt`).

```
431 total .lean under Theories/Bimodal
-154 Boneyard/
- 36 Automation/
=241 lintable
- 67 tier-1 + tier-2 (already at zero)
=174 TIER-3 SCOPE
```

**174 files, not 166.** The extra 8 are the umbrella modules the earlier count omitted
(`Bimodal.lean`, `Syntax.lean`, `Semantics.lean`, `ProofSystem.lean`, `Theorems.lean`,
`FrameConditions.lean`, `Examples.lean`, plus `Metalogic/Metalogic.lean`'s siblings). Of the 174,
**165 are under `Metalogic/`**, 2 under `Examples/`, 7 are umbrella files. Total 129,799 LOC.

**32 of the 174 files are already clean** (zero in-scope sites). The real working set is **142 files**.

### Diagnostic delta

| Measure | Stale figure | Re-derived | Delta |
|---------|-------------:|-----------:|------:|
| Files | 166 | 174 | +8 |
| Total diagnostics (all categories, raw) | ~6,136 | 6,079 | −57 |
| — of which style warnings (`-Dlinter.mathlibStandardSet=true`) | — | 5,254 | |
| — of which declaration findings (`runLinter Bimodal`) | — | 825 | |
| **In-scope distinct edit sites** | *never measured* | **4,651** | |

The ~6,136 figure survived the Boneyard archival essentially intact, which is expected: the
archival moved sorry-bearing *declarations*, and only one whole file. The number that actually
matters for planning — **4,651 distinct edit sites** — is 24% below the raw diagnostic count, and
is the number every phase estimate below is built on.

### docBlame: the description's "~83 remain" is wrong

Measured: **52 docBlame findings in tier-3**, across 14 files. Tier-1/tier-2 docBlame is **0**,
confirming the predecessor's 8 → 0 claim. The remaining 39 project-wide findings are in
`Automation/` (out of scope). 91 − 39 − 0 = 52. ✔

---

## 2. Distinct-site inventory (the number to plan against)

The brief's methodology inheritance is confirmed but its shape differs from tier-1/tier-2. In
tier-3, **only `linter.flexible` multi-emits**; every other style category emits exactly once per
`(file, line, col)`. The other big collapse is a *cross-category* one that tier-1/tier-2 never
saw: `unusedDecidableInType` and `unusedFintypeInType` fire at the **same declaration** 173 times
out of 185/175, so 360 raw warnings are **187 edit sites**.

### In scope for this task — 4,651 sites

| Category | Raw | **Sites** | Files | Bucket |
|----------|----:|----------:|------:|--------|
| `linter.style.longLine` | 2740 | **2740** | 124 | M |
| `linter.style.show` | 449 | **449** | 60 | M |
| `linter.unusedSimpArgs` | 300 | **300** | 37 | M |
| `linter.flexible` | 366 | **253** | 42 | S |
| `runLinter unusedArguments` | 193 | **193** | 52 | J |
| `unusedDecidableInType` ∪ `unusedFintypeInType` | 360 | **187** | 33 | J |
| `linter.unusedVariables` | 152 | **152** | 39 | M |
| `linter.style.emptyLine` | 113 | **113** | 9 | M |
| rcases `unused name:` (core, no linter option) | 68 | **68** | 1 | J |
| `runLinter docBlame` | 52 | **52** | 14 | J |
| `linter.unusedSectionVars` | 34 | **34** | 6 | J |
| `linter.unusedTactic` ∪ `linter.unreachableTactic` | 44 | **24** | 4 | J |
| `linter.style.multiGoal` | 18 | **18** | 4 | J |
| `linter.style.maxHeartbeats` | 17 | **17** | 5 | J |
| `runLinter simpNF` — `LINTER FAILED` artifacts | 6 | **6** | 2 | (accept) |
| `warn.classDefReducibility` | 5 | **5** | 2 | J |
| `linter.style.openClassical` | 3 | **3** | 3 | J |
| `linter.style.setOption`, `unnecessarySimpa` | 4 | **4** | 2 | M/J |
| `docString`, `whitespace`, `unnecessarySeqFocus`, `synTaut`, genuine `simpNF` | 4 | **4** | 4 | J |
| **TOTAL** | | **4,651** | 142 | |

`unusedTactic` and `unreachableTactic` overlap at 20 of 20 positions — deleting the dead tactic
clears both, so the union is 24 sites, not 44.

### Deliberately out of scope (record, do not touch)

| Category | Count | Owner |
|----------|------:|-------|
| `runLinter defsWithUnderscore` | 572 | naming task (394) |
| `push_neg` deprecations | 521 | deprecation task (400) |
| `linter.defProp` | 35 | naming task (394) — its charter explicitly claims the def→theorem conversions |
| `linter.dupNamespace` | 13 | naming task (394) — all in `BXCanonical/Chronicle/ChronicleTypes.lean`, fix is a namespace/rename decision |

**Scope-boundary recommendation**: leave `defProp` to 394. Its charter names the 39 project-wide
`defProp` declarations as "the unambiguously-safe subset, do this first regardless of route," and
35 of those 39 live here. Doing them in this task would collide head-on with 394's first phase.

### Genuine `simpNF` and the known trap

The brief's simpNF trap is confirmed and *smaller here than feared*. Tier-3 has **7** simpNF
findings total: 6 `LINTER FAILED` artifacts (`Bundle/CanonicalTaskRelation.lean` ×2,
`Bundle/TemporalContent.lean` ×4) and **1 genuine** —
`WeakCanonical/Kamp/NfEFold.lean:132` (`skipFin_zero_succ`, "Left-hand side simplifies from…").
The `neg_unfold`-poisoned bulk (78 in-scope entries) is entirely in tier-1/tier-2, already ledgered
by the sibling task. Fix the one genuine finding; document the 6.

---

## 3. Distribution — where the work actually is

| Group | Files | Dirty | Mechanical | Semi-auto | Judgment | Total |
|-------|------:|------:|-----------:|----------:|---------:|------:|
| `WeakCanonical/Kamp/**` | 89 | 71 | 2066 | 76 | 332 | **2474** |
| `BXCanonical/Chronicle/` | 8 | 8 | 514 | 35 | 38 | 587 |
| `WeakCanonical/Expressiveness/` | 5 | 4 | 287 | 3 | 100 | 390 |
| `WeakCanonical/EFGames/` | 8 | 8 | 189 | 43 | 67 | 299 |
| `WeakCanonical/IntegerModel/` | 6 | 6 | 177 | 23 | 22 | 222 |
| `Bundle/` | 12 | 9 | 186 | 0 | 19 | 205 |
| `WeakCanonical/` (top) | 14 | 12 | 126 | 32 | 28 | 186 |
| `Algebraic/` | 9 | 9 | 106 | 18 | 16 | 140 |
| `BXCanonical/` (top) | 7 | 6 | 73 | 3 | 13 | 89 |
| `BXCanonical/Quasimodel/` | 5 | 3 | 20 | 18 | 4 | 42 |
| umbrella + `Examples/` | 9 | 5 | 9 | 2 | 0 | 11 |
| `BXCanonical/Filtration/` | 1 | 1 | 5 | 0 | 1 | 6 |
| **TOTAL** | 174 | 142 | **3758 (80.8%)** | **253** | **640** | **4651** |

Per-file distribution: median 17 sites, mean 33, max 729. Buckets: 32 files at 0, 55 at 1–9,
44 at 10–29, 25 at 30–59, 10 at 60–99, **8 at 100+**.

### The eight 100+ files (these drive phase sizing)

| Sites | File | LOC | Composition |
|------:|------|----:|-------------|
| 729 | `WeakCanonical/Kamp/NfMultiAnchorBridge/SharedWitness.lean` | 12,801 | longLine 583, unusedSimpArgs 59, show 43, unusedVars 19, unusedArgs 14, instInType 9 |
| 214 | `BXCanonical/Chronicle/CounterexampleElimination.lean` | 3,493 | longLine 108, show 74, docBlame 16 |
| 202 | `WeakCanonical/Expressiveness/SplitPoint.lean` | 4,713 | longLine 188 |
| 157 | `WeakCanonical/Kamp/NfMultiAnchorBridge/Base.lean` | 2,102 | longLine 135, unusedArgs 13 |
| 152 | `WeakCanonical/Kamp/NfMultiAnchorBridge/InteriorGateGeneralK.lean` | — | longLine 133, maxHeartbeats 11 |
| 125 | `BXCanonical/Chronicle/PointInsertion.lean` | — | longLine 88, flexible 23, docBlame 6 |
| 109 | `WeakCanonical/Kamp/NfMultiAnchorBridge/SubBracket2V.lean` | — | longLine 92, instInType 9 |
| 102 | `WeakCanonical/Expressiveness/CaseAnalysis.lean` | — | rcases-unused-name 68, longLine 16, unusedSimpArgs 15 |

`SharedWitness.lean` alone is 15.7% of the entire task. It must be its own phase.

---

## 4. Mechanical vs judgment — settled empirically, not by assertion

I did not classify by intuition. For each candidate category I built the scripted fix, applied it
to a scratch copy, elaborated it, and diffed the per-category counts. **No source file was
mutated.** Scratch-copy equivalence was verified first: a byte-identical copy of
`Bundle/WitnessSeed.lean` in `/tmp` produced exactly the same category counts as the in-tree file,
confirming `lake env lean` resolves imports by module name regardless of file location.

### MECHANICAL — validated to zero, 0 errors, no collateral category movement

| Category | Fix | Validation | Result |
|----------|-----|-----------|--------|
| `style.show` | textual `show` → `change` at the reported `(line, col)` | 4 files, **166/166 sites**: `CounterexampleElimination` 74, `SharedWitness` 43, `Prop42NegationGeneral` 32, `GapDetection` 17 | show → 0, **0 errors**, every other category byte-identical |
| `unusedSimpArgs` | delete the argument at `(line, col)` up to the next depth-0 `,`/`]`; collapse `simp []` → `simp` | `EFGames/CustomGame.lean`, **45/45 sites** | 45 → 0, 0 errors, no other category moved |
| `unusedVariables` | insert `_` before the identifier at `(line, col)` | `Algebraic/BooleanStructure.lean` + `EFGames/CustomGame.lean`, **16/16** | → 0, 0 errors |
| `style.emptyLine` | delete the flagged line | `Bundle/WitnessSeed.lean` 36, `Bundle/CanonicalTaskRelation.lean` 19 | → 0 in **one pass**, no unmasking |
| `style.longLine` | break at the last space before col 100, continuation indent +4 | `WitnessSeed` 13/13, `CanonicalTaskRelation` 20/20 | → 0, 0 errors |

**`linter.style.show` is the headline reclassification.** The sibling task treated its 10 `show`
sites as judgment-requiring and hand-edited them. In tier-3 the linter fires only on `show`
invocations that *changed* the goal, and its own suggested replacement (`change`) is a
position-exact token substitution. 166 of 166 succeeded. That moves 449 sites — 9.7% of the task
— out of the judgment bucket.

### SEMI-AUTOMATED — validated end-to-end at file granularity

`linter.flexible`, 253 sites in 42 files. The sibling task did these one at a time. I validated a
**bulk per-file workflow** on `Algebraic/UltrafilterMCS.lean` (41 raw warnings, 14 distinct sites):

1. Inject `?` after every flagged `simp` in a scratch copy — all 14 at once.
2. `lake env lean <copy>` — **one** elaboration harvests all 15 `Try this: simp only [...]`
   suggestions, 0 errors.
3. Substitute each suggestion for its original tactic (extent = from `(line, col)` to the next
   depth-0 `;` or closing bracket).
4. Re-lint.

Differential result:

```
before:  41 linter.flexible   3 emptyLine  16 longLine   3 show
after:    0                    3 emptyLine  16 longLine   3 show      errors: 0
```

`flexible` → 0, **every other category unchanged**, three `lake` invocations for the whole file
instead of ~42.

Two caveats found while doing it:
- The suggestion stream comes out in source order but **the count can exceed the site count**
  (15 suggestions for 14 sites here). A site inside a branching proof elaborates more than once
  and can emit *differing* suggestions that must be reconciled (typically by unioning the lemma
  lists). Do not blind-zip; reconcile.
- Suggestion positions in the log are not co-located with the suggestion text — the `[apply]`
  payload is on the line after a bare `Try this:` whose position header may belong to an earlier
  diagnostic. Match by order within a declaration, then verify by elaboration.

### JUDGMENT / AUTHORING — 640 sites

| Category | Sites | Nature | Recommendation |
|----------|------:|--------|----------------|
| `unusedArguments` | 193 | Signature change with call-site blast radius | **Accept as residual with a ledger**, matching the sibling's precedent for its 10. Spot-checked messages (`parametric_task_rel_*`, `parametric_canonical_truth_lemma`) are the same `1 unused argument` frame-class/parameter pattern the sibling ruled load-bearing API documentation. |
| `unusedDecidableInType` ∪ `unusedFintypeInType` | 187 | `[DecidableEq α]` / `[Fintype α]` present in a signature but unused *in the type*. Same family as above. | **Accept as residual**, or a separate task. Removing them changes 187 public signatures across the Kamp/EFGames API. |
| rcases `unused name:` | 68 | All in `WeakCanonical/Expressiveness/CaseAnalysis.lean`, lines 502–503 — two enormous `obtain` patterns with dozens of `_`/named binders. Emitted by `rcases` itself, **no `set_option` exists to silence it**. | One focused edit to those two patterns. Verify by elaboration. |
| `docBlame` | 52 | Writing docstrings for 52 declarations across 14 files (`CounterexampleElimination` 16, `CanonicalModel` 11, `PointInsertion` 6). Includes notation declarations (`«term_≈ₚ_»`, `«term⟦_⟧»`). | Genuine authoring. One dedicated phase. |
| `unusedSectionVars` | 34 | `include`/`omit` or signature restructuring | Mechanical-ish but each is a semantic call. |
| `unusedTactic` ∪ `unreachableTactic` | 24 | Dead tactics (`'simp [Fin.ext_iff]' tactic does nothing` + `never executed` at the same position) | Delete; verify. Low risk. |
| `style.multiGoal` | 18 | Proof restructuring (`·` focus dots / `case`) | Judgment, small. |
| `style.maxHeartbeats` | 17 | Requires **writing a justification comment** for each `set_option maxHeartbeats` | Authoring, small; 11 of the 17 are in `InteriorGateGeneralK.lean`. |
| `classDefReducibility` | 5 | `@[instance_reducible]` decision on 5 instances | Judgment; not a `linter.*` option so not silenceable by the standard set. |
| `openClassical`, `setOption`, `synTaut`, `docString`, `whitespace`, `unnecessarySeqFocus`, `unnecessarySimpa`, genuine `simpNF` | 15 | Singletons | Sweep together in one phase. |

If `unusedArguments` + `unusedInstInType` are accepted as residuals (**380 sites, 8.2%**), the
judgment bucket collapses from 640 to **260**, and the task becomes ~86% scripted.

---

## 5. Differential-gate harness — validated on tier-3

The sibling's gate design transfers unchanged and I confirmed it on tier-3 files. Category
extraction from the note lines is stable under the line renumbering every edit causes:

```bash
lake env lean -Dlinter.mathlibStandardSet=true "$f" 2>&1 \
  | grep -oE 'set_option linter\.[a-zA-Z.]+' | sed 's/set_option //' | sort | uniq -c
```

**Pass condition** (per file): targeted in-scope categories absent, AND no other category's count
increased, AND `grep -cE ': error:'` is 0.

Three tier-3-specific amendments, all evidence-driven:

1. **A silence-based gate is impossible here and must not be attempted.** Every deprecation-bearing
   file keeps its `push_neg` warnings (521 of them, 51 files) and 87 files keep
   `defsWithUnderscore` findings. The gate must be differential.
2. **The note-line grep misses four things** that must be counted separately, because they carry no
   `set_option linter.X false` footer: the rcases `unused name:` warnings (68), the
   `Try this: intro …` rintro suggestions (6), `warn.classDefReducibility` (5), and
   `declaration uses 'sorry'` (1 — this one doubles as the sorry-census tripwire). Match these by
   message text.
3. **`runLinter` cannot be run per file.** `docBlame`, `unusedArguments`, and `simpNF` come only
   from `lake exe runLinter Bimodal`, which is a whole-library run (~7 min, exit code 1 by design).
   Gate those at phase boundaries only, using
   `../baseline/runlinter-findings.json` as the differential baseline.

Sorry-census tripwire, cheap and exact:

```bash
grep -c "declaration uses 'sorry'" <sweep-output>   # must stay at exactly 1
```

---

## 6. Which of the inherited lessons actually bite in tier-3

Assessed against measurement, not restated.

| Lesson | Verdict in tier-3 | Evidence |
|--------|-------------------|----------|
| **1. `emptyLine` count rises after line-wrapping** | **DOES NOT BITE.** Never reproduced. | Wrapped all 13 long lines in `WitnessSeed.lean` with zero blank lines added or removed: `emptyLine` stayed at exactly 36, blank-line count 89 → 89. Independently, deleting the 36 flagged blank lines took `emptyLine` 36 → 0 in **one pass** with no unmasking. Combined wrap+delete on `CanonicalTaskRelation.lean` took `{emptyLine 19, longLine 20}` → `{}` in one pass, 0 errors. Tier-3's `emptyLine` is confined to 9 files, 113 sites, all in `Bundle/` and `Algebraic/` — a small, well-behaved corner. Still re-derive positions rather than trusting numbers, but do not budget iteration cycles for this. |
| **2. `fix_unused.py` is stale** | **CONFIRMED and irrelevant.** All 152 `unusedVariables` messages here are the v4.33 phrasing `Variable name \`x\` is not explicitly referenced.` Don't run the Mathlib script — but don't hand-fix either: the `_`-prefix insertion is scripted and validated 16/16. |
| **3. `fix_long_lines.py` only cuts at commas** | **BITES HARDER THAN IN TIER-1/2.** Only **687 of 2740 sites (25.1%)** have a comma before column 100, versus the ~42% reported earlier. The script is applicable to a quarter of the surface and mangles prose. **However**: 1,878 of 2,740 sites (68.5%) exceed the limit by ≤10 characters, and a naive last-space break succeeded 33/33 across two files with 0 errors. The right tool is a purpose-built breaker, not Mathlib's script. Composition: 80.7% code, 16.6% inside block/doc comments, 1.8% line comments, 0.6% comment delimiters, 0.3% code-with-trailing-comment. The 456 doc-comment sites are prose rewrapping — safe but not code-aware; the 8 code+trailing-comment sites are the documented hazard. |
| **4. Line-breaking hazards (`return`/`pure`/`throw`/`yield` last on line; trailing `--`; docstring between attribute and declaration)** | **LOW EXPOSURE.** These are do-notation and metaprogramming shapes; tier-3 Metalogic is proof code. Only 8 of 2,740 sites are `code+trailing-comment`. Keep the guards in the breaker, but this will not be a cost driver. |
| **5. `linter.flexible` unmasking** | **BITES, BUT LESS.** In tier-3 the raw→site collapse is 366 → 253 (1.45×), versus the sibling's 78 → 41 (1.90×). Emission distribution: 190 sites emit once, 31 twice, 23 three times, 4 four times, 3 five times, 2 seven times. Unmasking did **not** occur in the one file I took to completion (`UltrafilterMCS.lean`, 14 sites → 0 flexible, no new sites). The sibling saw it in 1 of 21 files, the one with the highest concentration. **Per-file iteration to fixpoint is still mandatory** — 253 is a lower bound — but budget one extra pass for the ~6 highest-concentration files, not for all 42. Concentration: `PointInsertion` 23, `SharedWitness`-adjacent `EANegation` 23, `VecEAClosure` 16, `NfDepth0Generalized` 14, `EANegationClosure` 14, `GapDetection` 14, `UltrafilterMCS` 14, `NEquivalence` 13. |
| **6. `longLine` regression from transcribing `simp?` verbatim** | **REAL BUT MANAGEABLE.** 0 of 14 suggestions in `UltrafilterMCS.lean` exceeded 100 chars (they were short — `simp only [Set.mem_insert_iff] at hL`). But `NfDepth0Generalized.lean` mixes 24 longLine with 14 flexible, and the sibling measured nine-lemma `simp only` lists in `DeductionTheorem.lean`. **Sequence flexible BEFORE the longLine sweep in any file that has both** (17 such files), so wrapping cleans up after transcription rather than being regressed by it. |
| **7. simpNF `LINTER FAILED` noise from `neg_unfold`** | **BARELY BITES HERE.** Only 6 of the 115 library-wide `LINTER FAILED` entries land in tier-3. Document and move on, exactly as instructed. Do not touch `Automation/Normalization.lean:69`. |

**New hazard not in the inherited list**: `unusedDecidableInType` and `unusedFintypeInType` are the
same declaration 173 times out of 185/175. Any plan that adds their raw counts (360) rather than
their union (187) will over-size that phase by 92%.

---

## 7. Recommended phase decomposition

Ordering constraints, all evidence-backed:

- **`flexible` before `longLine`, per file.** Transcribed `simp only` lists regress line length.
- **`unusedSimpArgs` before `flexible`** where both occur: removing dead simp arguments shrinks
  the lists that `simp?` will regenerate.
- **`emptyLine` last within a file** — it is position-driven and cheapest to re-derive after all
  other edits have moved lines.
- **`docBlame` / `unusedArguments` / `simpNF` gate only at phase boundaries** (whole-library
  `runLinter`, ~7 min).
- **Nothing touches `defProp` or `dupNamespace`** — reserved for task 394.

| Phase | Scope | Sites | Gate |
|-------|-------|------:|------|
| **1** | Build and pilot the five validated fixers + the differential-gate harness. Re-run the 174-file baseline sweep into the phase's own log. Prove the fixers on the 5 pilot files already validated in this report. | ~150 | Per-file differential; `lake build` green; sorry census = 1 |
| **2** | `SharedWitness.lean` alone (12,801 LOC, 583 longLine + 59 unusedSimpArgs + 43 show + 19 unusedVars) | 713 | Per-file differential + `lake build` |
| **3** | `WeakCanonical/Kamp/**` mechanical, remainder of the subtree (88 files) | ~1,350 | Per-file differential + `lake build` |
| **4** | `BXCanonical/**` + `Bundle/` + `Algebraic/` mechanical (42 files; includes all 113 `emptyLine`) | ~900 | Per-file differential + `lake build` |
| **5** | `WeakCanonical/{Expressiveness, EFGames, IntegerModel, top-level}` + umbrella files, mechanical (33 files; includes `SplitPoint.lean`'s 188 longLine) | ~790 | Per-file differential + `lake build` |
| **6** | `linter.flexible`, all 42 files, harvest→apply→verify, **iterate to fixpoint per file** | 253+ | Per-file differential; re-lint until `flexible` = 0 |
| **7** | Small judgment sweep: unusedTactic∪unreachable 24, multiGoal 18, maxHeartbeats 17 (write justifications), unusedSectionVars 34, classDefReducibility 5, openClassical 3, setOption 2, unnecessarySimpa 2, synTaut 1, genuine simpNF (`NfEFold.lean:132`) 1, docString 1, whitespace 1, seqFocus 1, rcases-unused-name 68 (`CaseAnalysis.lean` lines 502–503) | 178 | Per-file differential + `lake build` + `runLinter` diff |
| **8** | `docBlame`: author 52 docstrings across 14 files | 52 | `runLinter` differential |
| **9** | Decision + ledger for `unusedArguments` (193) and `unusedInstInType` (187). **Recommended: accept as residuals with a written rationale**, per the sibling's precedent. | 380 | `runLinter` differential shows no change; ledger written |
| **10** | Global 174-file sweep, residual ledger, final `lake build` + `runLinter` | — | Full differential vs `../baseline/*.json` |

### How many dispatches

**Realistically 5 to 7**, on this reasoning:

- Phases 1–5 (the 3,758-site mechanical bulk) are script-driven with a per-file gate. The
  bottleneck is elaboration wall-clock, not agent reasoning: ~1.8 s per file warm, so a 90-file
  sweep with three verify rounds is under 10 minutes of compute. **2 dispatches** — one to build
  and prove the fixers (P1+P2), one to run P3–P5 — is achievable. Budget **3** if the longLine
  breaker needs a second iteration on the 456 doc-comment sites.
- Phase 6 (`flexible`) is **1 dispatch**. At ~3 `lake` invocations per file × 42 files, plus
  fixpoint iteration on the ~6 concentrated files, this is comfortably one agent run.
- Phases 7–8 are **1 dispatch** together (178 mechanical-ish sites + 52 docstrings).
- Phases 9–10 are **1 dispatch** if the residual decision is *accept*. If the signature edits are
  attempted instead, add **2–3 dispatches** and expect proof breakage across 380 public signatures.

**Commit at every phase boundary.** Phases 2–5 partition the file set disjointly and can be
territory-contracted for parallel dispatch if `--team` is used; phases 6–10 are sequential.

### What would make this go wrong

1. **Sizing the mechanical bulk by raw diagnostic count (6,079) instead of sites (4,651)**, or by
   raw `unusedInstInType` (360) instead of union (187). Over-sizes by 30–92%.
2. **Hand-editing the `show` sites.** 449 of them. The sibling hand-edited its 10 and that was
   correct at that scale; at this scale it is the difference between one dispatch and four. The
   `show` → `change` substitution is validated 166/166.
3. **Running `runLinter` per file.** It is a whole-library invocation. Gate it at phase boundaries.
4. **Expecting a silent file.** 51 files keep `push_neg` deprecations, 87 keep
   `defsWithUnderscore`, 11 keep `defProp`. The gate is differential or it is broken.
5. **Wrapping long lines before fixing `flexible`** in the 17 files that have both.

---

## 8. Zero-debt compliance

Nothing in this report proposes deferring work with `sorry`, introducing an axiom, or tolerating a
partial proof. The one live sorry (`Transfer.lean:1227`) is out of scope by charter and is used
here only as a build tripwire: the sweep must continue to report exactly one
`declaration uses 'sorry'`. Every recommended fix was validated by actual elaboration on a scratch
copy at 0 errors before being recommended. The two accept-as-residual recommendations
(`unusedArguments`, `unusedInstInType`) are explicit, ledgered API decisions carried over from an
already-completed sibling task — not deferred work.

## 9. Method note

No source file under `Theories/` was modified during this research. Every experiment ran on a copy
in the session scratchpad; scratch-copy lint equivalence was verified first. `git status` is clean
apart from this task's `specs/` artifacts.
