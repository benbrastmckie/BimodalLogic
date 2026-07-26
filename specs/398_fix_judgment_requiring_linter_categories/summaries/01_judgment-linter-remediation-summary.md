# Implementation Summary: Judgment-Requiring Linter Category Remediation

- **Task**: 398 - fix_judgment_requiring_linter_categories
- **Status**: [COMPLETED]
- **Plan**: `specs/398_fix_judgment_requiring_linter_categories/plans/01_judgment-linter-remediation.md`
- **Research**: `specs/398_fix_judgment_requiring_linter_categories/reports/01_judgment-linter-categories-inventory.md`
- **Type**: lean4
- **Phases**: 9 of 9 completed

## Outcome

All six in-scope judgment-requiring linter categories are driven to zero across all 67 in-scope
T1+T2 files, and the one genuine `simpNF` finding is fixed. The build invariant held at every
checkpoint: 0 errors, exactly 1 live sorry at
`Theories/Bimodal/Metalogic/WeakCanonical/Transfer.lean:1227`.

### In-scope category counts (67-file sweep, `lake env lean -Dlinter.mathlibStandardSet=true`)

| Category | Baseline (raw warnings) | Baseline (distinct sites) | Final |
|----------|------------------------:|--------------------------:|------:|
| `linter.flexible` | 78 | 41 | **0** |
| `linter.style.show` | 10 | 10 | **0** |
| `linter.style.nativeDecide` | 4 | 4 | **0** |
| `linter.unusedTactic` | 2 | 2 | **0** |
| `linter.style.multiGoal` | 2 | 2 | **0** |
| `linter.style.openClassical` | 1 | 1 | **0** |
| `linter.style.longLine` | 0 | 0 | **0** (no regression) |
| `linter.defProp` (out of scope) | 3 | 3 | 3 (unchanged) |

### Declaration linters (`lake exe runLinter Bimodal`, in-scope modules)

| Category | Baseline | Final |
|----------|---------:|------:|
| `simpNF` genuine | 1 (`Derivable.ax`) | **0** |
| `simpNF LINTER FAILED` | 78 | 78 (accepted residual) |
| `unusedArguments` | 10 | 10 (accepted residual, by design) |

### Other invariants held

- `lake build`: 0 errors, 1875 jobs, at every phase boundary.
- Live sorry census: exactly one, `Transfer.lean:1227`, at every phase boundary.
- Deprecation warnings: 31 before, 31 after (the out-of-scope `push_neg` deprecations were
  deliberately left in place; their disappearance would have signalled out-of-scope edits).
- Per-file differential gate: every one of the 67 diffs is a pure deletion. **No category count
  increased anywhere.**
- No file under `Automation/` or `Boneyard/` was modified by this task.

## Phase Results

| Phase | Scope | Iterations to fixpoint | Result |
|-------|-------|-----------------------:|--------|
| 1 | Baseline capture + differential-gate harness | — | Confirmed 41 distinct flexible sites / 78 raw warnings, exactly as the research report predicted |
| 2 | 8 T1 files: 1 `show`, 9 flexible sites | 1 | Green |
| 3 | `Core/DeductionTheorem.lean`: 4 categories | 1 | Green |
| 4 | 4 Decidability files incl. `Saturation.lean` | 2 (`Saturation.lean`) | Green |
| 5 | `CountermodelExtraction.lean`, `FMP/Filtration.lean` | 1 | Green |
| 6 | `MaximalConsistent.lean`, `RestrictedMCS/Basic.lean` | 1 | Green |
| 7 | `SoundnessLemmas/FrameClassVariants.lean` | 1 | Green |
| 8 | `Derivable.ax` simpNF, isolated full-build gate | — | Green; **no revert needed** |
| 9 | Global sweep + residuals ledger | — | Green |

### Unmasking, as predicted

The research report's core finding — that the flexible-tactic inventory is a lower bound because
the linter reports only the *first* flexible tactic in a dependent chain — was confirmed exactly
once, in `Metalogic/Decidability/Saturation.lean`. Fixing the 8 inventoried sites there reduced
the raw warning count from 21 to 9 and surfaced 4 previously invisible sites (at pre-edit lines
1114, 1129, 1208, 1211). A second discovery pass cleared them. Every other file converged in a
single iteration. The predicted unmasked site in `DeductionTheorem.lean` was pre-applied from the
plan, so that file also converged in one pass.

### Line wrapping

Wrapping was performed as part of each edit, never deferred. The 100-character limit forced
explicit wrapping in `DeductionTheorem.lean` (nine occurrences of the six-lemma `simp only`
list), `Saturation.lean` (two sites, plus three `tac; tac; tac` one-liners split into separate
lines), and `CountermodelExtraction.lean` (two sites). Final `linter.style.longLine` count across
all 67 files: 0, unchanged from baseline.

## Files Modified

19 Lean sources, all under `Theories/Bimodal/`:

`Syntax/Atom.lean`, `ProofSystem/Axioms.lean`, `ProofSystem/Derivable.lean`,
`Semantics/TaskFrame.lean`, `Semantics/WorldHistory.lean`,
`Theorems/GeneralizedNecessitation.lean`, `Theorems/Perpetuity/Principles.lean`,
`Theorems/Propositional/Connectives.lean`, `Theorems/Propositional/Reasoning.lean`,
`Metalogic/Core/DeductionTheorem.lean`, `Metalogic/Core/MaximalConsistent.lean`,
`Metalogic/Core/RestrictedMCS/Basic.lean`,
`Metalogic/Decidability/CountermodelExtraction.lean`,
`Metalogic/Decidability/FMP/Filtration.lean`, `Metalogic/Decidability/Saturation.lean`,
`Metalogic/Decidability/SignedFormula.lean`,
`Metalogic/Decidability/Propositional/Decidable.lean`,
`Metalogic/Decidability/Propositional/PropForm.lean`,
`Metalogic/SoundnessLemmas/FrameClassVariants.lean`

Plus this summary and the plan file.

### Notable non-style improvement

The four `native_decide` to `decide` conversions in `Metalogic/Decidability/SignedFormula.lean`
(`:132 :138 :139 :144`) remove the Lean **compiler** from the trust base of the `LawfulBEq Sign`
and `ReflBEq Sign` instances. All four decide propositions over `Sign`, a two-constructor
inductive, so kernel-checked `decide` is trivially sufficient. This is a soundness-surface
reduction, not merely a style fix.

## Accepted Residuals

Total in-scope residuals: **88** (78 `simpNF LINTER FAILED` + 10 `unusedArguments`). Both
categories were settled before implementation began and were deliberately not edited.

### 1. 78 `simpNF LINTER FAILED` findings

Every one has the same body:

```
Tactic `simp` failed with a nested error:
maximum recursion depth has been reached
```

**Root cause**: `neg_unfold` at `Theories/Bimodal/Automation/Normalization.lean:69`

```lean
@[simp] theorem neg_unfold (φ : Formula) : φ.neg = φ.imp bot := rfl
```

Its right-hand side `φ.imp bot` is definitionally its own left-hand-side pattern
(`Formula.neg`, `Theories/Bimodal/Syntax/Formula.lean:121`), so `simp` loops. Because
`lake exe runLinter Bimodal` imports the whole library, this single lemma poisons `simp` for
every `Formula`-valued left-hand side.

**This is not a `maxRecDepth` setting problem.** In isolation these declarations are simp-normal
at the default depth, and raising the depth to 20000 does not help.

**Do not "fix" this by dropping `@[simp]` from `neg_unfold`.** Doing so converts these into
*real* `simpNF` reports that are still artifacts of the same simp set — the partial fix trades
one class of noise for another without addressing the cause.

`Automation/` is out of scope for this task. The correct remediation is a follow-up
Automation-scoped task that redesigns the normalization simp set.

Distribution of the 78 (in-scope modules only):

| Form | Count | Location |
|------|------:|----------|
| `#check` form | 35 | `Bimodal.ProofSystem.Axioms` (`sizeOf_spec` auto-lemmas) |
| `#check` form | 2 | `Bimodal.ProofSystem.Derivation` (`sizeOf_spec` auto-lemmas) |
| inline-error form | 22 | `Metalogic/WeakCanonical/Separation/Defs.lean` |
| inline-error form | 6 | `Semantics/Truth.lean` |
| inline-error form | 4 | `Syntax/Formula.lean` |
| inline-error form | 4 | `Syntax/SubformulaClosure/NestingDepth.lean` |
| inline-error form | 3 | `Syntax/BigConj.lean` |
| inline-error form | 2 | `Metalogic/Decidability/Propositional/Kalmar.lean` |

Note on the count: the research report cited **41** residuals here. That figure counts only the
inline-error form (22 + 6 + 4 + 4 + 3 + 2 = 41). `runLinter` also emits 37 in-scope
`LINTER FAILED` entries in `#check` form, for a true in-scope total of 78. Both forms have the
identical root cause above. Library-wide the count is 115.

### 2. 10 `unusedArguments` findings

| File | Lines | Declarations |
|------|-------|--------------|
| `Theories/Bimodal/FrameConditions/Soundness.lean` | 69, 84, 100, 119, 130, 142 | `soundness_linear`, `soundness_dense`, `soundness_discrete`, `axiom_base_valid_linear`, `axiom_dense_valid_fc`, `axiom_discrete_valid_fc` |
| `Theories/Bimodal/Metalogic/SoundnessLemmas/FrameClassVariants.lean` | 711, 752, 791, 853 | `prior_UZ_is_valid`, `prior_SZ_is_valid`, `z1_is_valid`, `z1_past_is_valid` |

Every one is an unused **typeclass instance** argument that is semantically load-bearing as API
documentation. `[LinearTemporalFrame D]`, `[DenseTemporalFrame D]`, and `[DiscreteTemporalFrame D]`
**are** the frame-class index — they are the entire reason `soundness_linear`, `soundness_dense`,
and `soundness_discrete` exist as three separate declarations rather than one. Removing them
collapses all three into a single `Metalogic.soundness` and destroys the frame-class-stratified
API. The `FrameClassVariants` instances (`[IsPredArchimedean D]`, `[IsSuccArchimedean D]`,
`[Nontrivial D]`) likewise document the discrete-order setting of the Prior-UZ/SZ lemmas.

Accepted as residuals by explicit decision; this is an API design property, not a linter chore.
`@[nolint unusedArguments]` was deliberately **not** added either — that is a separate,
user-visible API decision outside this task's scope.

### 3. Per-site residuals from Phases 2-8

**None.** Every linter suggestion applied cleanly. No proof broke, no suggestion had to be
reverted, and the Phase 8 `Derivable.ax` revert contingency was not triggered. The research
methodology's 21/21 success rate held, and extended to the 12 additional sites discovered during
implementation (28 flexible edits total across Phases 2-7, plus the 4 `native_decide`, 10 `show`,
2 `simp_wf` deletions, 1 `open Classical` deletion, and 1 attribute change).

## Plan Deviations

- None (implementation followed the plan).

Two clarifications that are corrections of stale figures rather than deviations:

1. The plan's Phase 8 verification criterion stated `simpNF` would drop "42 to 41". The measured
   in-scope pre-state was 78 `LINTER FAILED` + 1 genuine; the post-state is 78 `LINTER FAILED` +
   0 genuine. The substantive criterion — the genuine `Derivable.ax` finding is gone and nothing
   else moved — is met exactly. See the counting note in the residuals section above.
2. The plan's expected residual total of 51 rests on the same 41-vs-78 undercount; the accurate
   total is 88.

## Cross-Task Note

`Theories/Bimodal/FrameConditions/Soundness.lean` is also touched by the out-of-scope naming work
(`linter.defProp`, 3 findings). Territory between that task and this one is assigned **by
category, not by file**: this task made no edit to that file, and the 3 `linter.defProp` findings
there remain untouched and unchanged.

## Verification Commands

```bash
lake build                                                    # 0 errors, 1875 jobs
grep -rnE '^\s*sorry\s*$|:= *sorry|by sorry' --include=*.lean Theories/ Tests/ | grep -v Boneyard
lake env lean -Dlinter.mathlibStandardSet=true <file>          # per-file style/syntax linters
lake exe runLinter Bimodal                                     # declaration linters
```
