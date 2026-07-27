# Implementation Summary: FrameClass Dedekind Scaffolding

- **Task**: 391 - frameclass_dedekind_scaffolding
- **Type**: lean4
- **Plan**: `specs/391_frameclass_dedekind_scaffolding/plans/01_frameclass-dedekind-scaffolding.md`
- **Phases**: 8 of 8 completed
- **Status**: implemented, with declared strategic debt (3 sorries) and two material deviations
  flagged for review
- **Date**: 2026-07-27

---

## Outcome

All eight plan phases landed. `lake build` and `lake build BimodalTest` both exit 0.
`FrameClass` now carries a fourth constructor `.Dedekind` with a genuine `Base < Dense <
Dedekind` chain; Reynolds' three definable-gap axioms are `Axiom` constructors mapped to
`.Dedekind`; `ValidDedekind` / `ValidDedekindDense` and their bridges exist; and
`soundness_dedekind` typechecks with debt confined to exactly three named, documented lemmas.

The `Axiom` inductive went from 42 to 45 constructors.

### Verification results

| Check | Result |
|---|---|
| `lake build` | exit 0 |
| `lake build BimodalTest` | exit 0 |
| Sorry count | 4 = `SORRY_BASELINE` (1) + 3 planned |
| New sorries name | `prior_U_gap_valid` (`Soundness.lean:1451`), `prior_S_gap_valid` (`:1462`), `sep_valid` (`:1481`) |
| New `axiom` declarations | 0 |
| Vacuous definitions introduced | 0 |
| `#print axioms soundness_dedekind` | `[propext, sorryAx, Classical.choice, Quot.sound]` — sorries real and reached |
| `#print axioms valid_implies_validDedekind` | `[propext]` — sorry-free |
| `lake exe machine_appendix` | 45 axioms, 7 rules, 21 derived operators; coverage assertion passes |
| `lake exe benchmark_anchors` | `Axiom coverage: 45/45 constructors`, none missing |
| `scripts/typst-sync-check.sh` Check 2 (counts) | `MISMATCH_COUNT=0` |
| `scripts/typst-sync-check.sh` Check 3 (appendix, incl. 3A live recount = 45) | `MA_COUNT_MISMATCHES=0` |
| `scripts/typst-sync-check.sh` overall | exit 1 — **pre-existing**, see below |

### SORRY_BASELINE correction

The plan's baseline command `lake build 2>&1 | grep -c "declaration uses 'sorry'"` uses straight
quotes; Lean 4.33 emits backticks (``declaration uses `sorry` ``). The plan's literal command
reports `0` and would have masked any regression. With the corrected pattern,
**`SORRY_BASELINE = 1`** — the pre-existing `countermodel_discrete` sorry at
`FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1225`. Final count is 4, exactly
baseline + 3.

### typst-sync-check was already failing before this task

The plan's definition of done required `scripts/typst-sync-check.sh` green. It was **not green
at the pre-task commit** — verified by running it in a clean worktree at `833f249b0`, where it
exits 1 with `TOTAL_VIOLATIONS=20`, `MISMATCH_COUNT=6`. That criterion was unattainable as
written.

Measured effect of this task: violations `20 → 19`, mismatches `6 → 0`. A set-diff of the two
runs shows this task **removed 8 violations and added none**. The residual 19 are Check 1 prose
drift in `typst/chapters/**` — references to removed files (`Metalogic/ConservativeExtension/
Lifting.lean`, `Metalogic/DenseSoundness.lean`) and absent identifiers (`rabinovich_translate`,
`lift_derivation_qfree`) — all unrelated to this task and predating it.

---

## What Was Built

### Order and syntax layer

- `FrameClass.Dedekind` constructor; `LE` instance gains the single new arm `.Dense, .Dedekind`.
  `le_trans` (64 cases) closes with `trivial`; `le_antisymm` (16 cases) with
  `first | rfl | simp_all [LE.le]`. Eight `example`s pin the order shape as a regression guard.
- `Formula.kPlus` / `Formula.kMinus` (`K⁺A = ¬U(⊤,¬A)`, `K⁻A = ¬S(⊤,¬A)`) in
  `Syntax/Formula.lean`, both carrying the `kplusFormula` collision warning.
- `Axiom.prior_U_gap`, `Axiom.prior_S_gap`, `Axiom.sep` as a "Layer 9" block, each docstring
  citing Reynolds 1992 printed p.168 and each explicitly stating it is NOT `prior_UZ`/`prior_SZ`.
  Three `Axiom.minFrameClass` rows map them to `.Dedekind`.

### Semantic layer

- `ValidDedekind` (research Variant B, `DenselyOrdered`-free) and `ValidDedekindDense`.
- Bridges `valid_implies_validDedekind`, `valid_implies_validDedekindDense`,
  `validDedekindDense_of_validDedekind` — all sorry-free.
- `DedekindTemporalFrame` marker class + `SerialFrame` derivation instance + `mk'` +
  `of_conditionallyComplete`.

### Soundness layer

- `axiom_dedekind_valid` (45 enumerated cases), `axiom_dedekind_swap_valid`,
  `derivable_valid_and_swap_valid_dedekind`, `soundness_dedekind_valid`, `soundness_dedekind`.
  All sorry-free; the three strategic sorries live only in the three named lemma bodies.

### Blast radius actually repaired

`FrameClass` gaining a constructor broke **2** sites, not the 42 `simp [LE.le]` sites the plan
feared — those all survived unchanged. The `Axiom` inductive gaining 3 constructors broke 11
Metalogic sites and 12 Automation sites.

---

## Plan Deviations

Six deviations. Two are material and flagged for review; four are mechanical.

### 1. `sep_valid` is a conjunction, not a single `IsValid` (MATERIAL — review requested)

The plan's Phase 8 step "reuse `axiom_swap_valid_general` for `temporal_duality`" is **not
executable as written**. That lemma requires `h_fc : h.minFrameClass ≤ FrameClass.Base`; it is
free of the `DenselyOrdered` *instance* binder but not of the frame-class hypothesis, so it
cannot apply to an axiom whose `minFrameClass` is `.Dedekind`. The task description's claim that
it is "directly reusable" is incorrect.

Swap-validity therefore had to be established for Dedekind derivations. A `lake env lean` probe
(with a bogus-identifier control) established by `rfl` that `(prior_U_gap φ).swapTemporal` is
*definitionally* `prior_S_gap φ.swapTemporal` and symmetrically — so those two cover each
other — but that `(sep φ).swapTemporal` is the past-dual `Sep⁻`, not an instance of
`Axiom.sep`. A fourth semantic fact is genuinely required.

Options were (a) a fourth sorried lemma, exceeding the plan's declared three-sorry budget and
adding an unplanned division point, or (b) stating `sep_valid` as a conjunction over `sep φ` and
its swap — one lemma, one sorry, one division point. Chose (b): smaller deviation, budget held
at exactly three, and Reynolds discharges Sep together with its dual in the same deferred lemma
10 of his §7.

**Review question for the user**: is folding the `Sep⁻` obligation into `sep_valid` acceptable,
or should it be split into a separate fourth division point with its own follow-up task?

### 2. Two `scripts/` files repaired, outside the plan's declared file scope (MATERIAL)

`scripts/typst-status-counts.sh` computed `BASE_COUNT = AXIOM_COUNT - DENSE - DISCRETE` with no
Dedekind term, so it reported `base-count = 40` instead of `37` — a wrong published number
caused directly by this task. Added `DEDEKIND_ONLY_COUNT` and a `dedekind-only-count` field;
`scripts/typst-sync-check.sh` gained the matching `scalar_fields` entry.

Regenerating `status.typ` then surfaced a **pre-existing** latent bug: the checker's expected
`sorry-table` row label still named `ConservativeExtension/` and `Relational/`, which the
generator had already dropped when those subtrees were archived. The drift had been masked only
because the committed `status.typ` was stale (last stamped 2026-07-07). Corrected the label.
Regenerating also absorbed that pre-existing sorry-count drift (committed 43 → live 5).

### 3. Phase 8 dispatcher decomposition extended (altered)

Added `validDedekindDense_of_validDense`, `axiom_dedekind_swap_valid`, and
`derivable_valid_and_swap_valid_dedekind` beyond the plan's named declarations. Forced by
deviation 1; patterned on the tree's existing `derivable_valid_and_swap_valid_discrete`. All
sorry-free.

### 4. Seven further `Automation/` sites beyond the plan's four named lists (altered)

The plan named four independent name/coverage lists. Seven more carried a hard-coded `42` or an
axiom enumeration and would have silently under-covered: `ProofStepExtractor.lean`
(`Axiom.toName`, plus the action-space figure 49 → 52), `DatasetGenerator.lean`
(`extractAxiomName`), `MachineAppendixExport.lean` (`frameClassToString`),
`FormulaEnumerator.lean` (`instantiateAxiomWithWitness` indices 42-44 and `pickSchemaIdx`),
`ForwardProofGenerator.lean` (`schemaNames`, `Layer`, `schemaLayer`),
`TableauProofStepPipeline.lean` (`totalAxioms`), and `BenchmarkAnchors.lean`'s
`nonBaseAxiomNames` (5 → 8). Without the `FormulaEnumerator` / `ForwardProofGenerator`
additions, `lake exe benchmark_anchors` would have reported 42/45 coverage.

### 5. `FrameClassVariants.lean:925/:941` were a different error shape than predicted (altered)

Not missing-alternative errors but `Application type mismatch`. Both sit inside a
`by_cases hbase` whose catch-all is `| _ => exact absurd trivial hbase`, discharging via
`trivial : minFrameClass ≤ Base` — valid only for Base axioms. The three new constructors needed
explicit `absurd h_fc` arms placed before the catch-all. Same disposition, different mechanism.
The identical pattern recurred in the new `axiom_dedekind_swap_valid`.

### 6. `Metalogic/Decidability/TraceExport.lean` repaired (altered, outside plan scope)

`frameClassToJsonString` needed a `.Dedekind` arm. This module is **not** in the default
`lake build` target's import closure — it surfaced only under `lake build BimodalTest`. Worth
recording as a durable fact: a green `lake build` does not prove the `FrameClass` blast radius
is covered; the test target must be built too.

---

## Strategic Sorries (all planned, all tracked)

| Lemma | Location | Deferred because | Follow-up |
|---|---|---|---|
| `prior_U_gap_valid` | `Soundness.lean:1451` | Reynolds asserts validity over ℝ without proof (printed p.168); the argument is an open-ended supremum construction over the φ-region | task 405 |
| `prior_S_gap_valid` | `Soundness.lean:1462` | Infimum dual of the above; same unbounded attempt surface | task 405 |
| `sep_valid` (and its temporal dual) | `Soundness.lean:1481` | The primary source itself defers it — Reynolds printed p.168 defers validity in ℝ to lemma 10 of §7; turns on separability of ℝ | task 406 |

Each body carries the mandated three-part `-- sorry: assumes X; deferred because Y; follow-up:
task NNN` comment.

---

## Key Design Decisions Preserved

1. **`.Dedekind` sits strictly above `.Dense`** — primary-source grounded: Reynolds' US/R
   includes "axioms for density and no end points", and `K⁺⊤` normalises to the tree's
   `dense_indicator`. Docstrings note the identity holds after normalising `¬⊤` to `⊥`, not
   syntactically (`Formula.top.neg` is `(⊥ → ⊥) → ⊥`, not `⊥`) — a precision the plan's phrasing
   ("literally") overstated.
2. **`soundness_dedekind` targets `ValidDedekindDense`, not `ValidDedekind`** — `density` and
   `dense_indicator` are admissible at `.Dedekind` and both are false on `ℤ`, which is
   Dedekind-complete. Stated in three docstrings.
3. **`prior_UZ`/`prior_SZ` left byte-identical**; fresh constructors added.
4. **Fresh `Formula.kPlus`/`kMinus`**, not `Metalogic`'s `kplusFormula` (which carries an extra
   `¬P` conjunct).

---

## Files Modified

**Lean sources (17)**: `ProofSystem/Axioms.lean`, `Syntax/Formula.lean`,
`Semantics/Validity.lean`, `FrameConditions/FrameClass.lean`, `Metalogic/Soundness.lean`,
`Metalogic/SoundnessLemmas/{DenseValidity,FrameClassVariants}.lean`,
`Metalogic/Decidability/TraceExport.lean`, `Automation/{AxiomNames,BenchmarkAnchors,
DatasetGenerator,FormulaEnumerator,ForwardProofGenerator,MachineAppendixExport,ProofStepExport,
ProofStepExtractor,TableauProofStepPipeline}.lean`

**Scripts (2)**: `scripts/typst-status-counts.sh`, `scripts/typst-sync-check.sh`

**Generated (3)**: `typst/generated/machine-appendix.{jsonl,typ}`, `typst/generated/status.typ`

`FormalSystem/ProofSystem/Derivation.lean` was a confirmed **no-op**, exactly as the plan
predicted: the `:98` gate `h.minFrameClass ≤ fc` is generic in `fc`.

---

## Out of Scope (unchanged)

`completeness_dedekind` and all its prerequisites; construction of any Dedekind-complete
carrier; the semantic validity proofs deferred to tasks 405 and 406.
