# Implementation Summary: Wave 0 hotfix

- **Task**: 518 — Wave 0 hotfix: simp loop, unbuilt modules, drifted documentation
- **Plan**: `specs/518_metalogic_hotfix_simp_loop_unbuilt_modules/plans/01_wave-0-hotfix-execution.md`
- **Research**: `specs/518_metalogic_hotfix_simp_loop_unbuilt_modules/reports/01_wave-0-hotfix-verification.md`
- **Phases**: 8 of 8 completed
- **Type**: lean4

## Outcome

All eight phases landed. The acceptance criteria are met on one combined tree:

| Acceptance check | Baseline at `HEAD` (`92b154ab2`) | After |
|---|---|---|
| `lake build` | exit 0 (2515 jobs) | **exit 0 (2521 jobs)** |
| `lake build BimodalTest` | exit 0 | **exit 0** |
| `bash scripts/check-module-invariants.sh` | 1 CHECK GROUP FAILED (**C6**) | **ALL CHECKS PASSED** |
| C6 | FAIL — 4 unreachable live modules unmanifested | **PASS — 0** |
| `example (a : Formula) : a.neg = a.neg := by simp` | `maximum recursion depth has been reached` | **compiles** |
| Drifted doc sites | 4 fronts wrong | **corrected, grep-confirmed** |

No `sorry` was introduced, no axiom was added, and no phase was blocked. Neither of the plan's
two contingency fallbacks (Phase 6 plain tag removal, Phase 7 full revert) was needed.

## What changed, by phase

**Phase 1 — README Dedekind strong-completeness status.** `README.md:167` said Dedekind strong
completeness was "**not stated**" and "*unproved* rather than refuted", asserting the tree
contains "no `CompactDedekind` definition and no refuting theorem". Both halves are false:
`Metalogic/SetConsequence.lean` defines `StrongCompletenessDedekind` and `CompactDedekind` (each
with a docstring already saying "This statement is false"), and
`Metalogic/DedekindNonCompactness.lean` proves `strongCompletenessDedekind_refuted` and
`dedekind_consequence_not_compact` sorry-free. Rewritten as **refuted**, matching the Discrete
bullet above it and `FormalSystem/Metalogic.lean:116-120`, with the Reynolds 1992 weak-only
observation preserved as the explanation rather than as evidence of an open question.
`README.md:240`'s forward reference "(open —" became "(refuted —".

**Phase 2 — `Formula` constructor tables.** Both `FormalSystem/README.md` operator tables listed
`Hφ | all_past φ` and `Gφ | all_future φ` as *primitive* (they are derived), omitted `untl` and
`snce` entirely, and named four identifiers that do not exist — the live names are camelCase
(`allPast`, `allFuture`, `somePast`, `someFuture`). Replaced with an explicit six-constructor
statement, a cross-reference to the top-level README's tables, and the camelCase name list.
`FormalSystem/Syntax/README.md:19` got the corrected six-constructor list **inline** rather than a
link, because top-level `README.md:32` says "5 primitive connectives" and omits `atom`.

**Phase 3 — typst `sorryAx` claims.** All six regions of `typst/FormalFoundations.typ` corrected.
The document asserted that `completeness` carries `sorryAx`, that the tree contains exactly one
structural `sorry`, that it lives in `countermodel_discrete`, that `countermodel_discrete` is in
`WeakCanonical/Transfer.lean`, and that it is dead code. Every one of those is false:
`lean_verify` and the C2/C14 baselines both report `[propext, Classical.choice, Quot.sound]` for
`completeness`; C3 measures zero structural `sorry` outside `Boneyard/`; `countermodel_discrete`
is at `WeakCanonical/GroupModel/CountermodelBase.lean:143`; and `BXCanonical/Completeness.lean:228`
calls it as the Base-frame discrete branch. `#theorem("Base-class completeness (outstanding)")`
became `#theorem("Weak completeness, base class")`, stated as established on the same footing as
its three siblings.

**Phase 4 — the `Bundle <-> Algebraic` cycle.** Deleted `fc_theorem_true_in_bundle_flow_model`
from `Metalogic/Bundle/LimitMCS.lean` — the sole carrier of the cycle, with zero consumers — along
with its docstring, its section header, its two now-dead `open` lines, and the
`import FormalSystem.Metalogic.Algebraic.FlowFrame` at `:8`. 33 lines, one file.
`Metalogic/README.md` was **not** edited: it already reads "exactly two" directory cycles, and
this deletion is what makes that true.

**Phase 5 — the four unreachable modules (the primary blocker).** Two imports added to
`FormalSystem/Metalogic.lean`: `Metalogic.Z1Countermodel` and `Metalogic.SpWitness`. That cleared
all four C6 entries — `Z1Countermodel` pulls `TMCompletenessReduction` and `LexCarrier`
transitively — with **zero** manifest edits, exactly as the research measured. C7's unreachable
count went 21 -> 17, reachable 468 -> 472, and `check-module-invariants.sh` went from
"1 CHECK GROUP(S) FAILED" to "ALL CHECKS PASSED". `Metalogic/Conservativity.lean:158-162`'s claim
that `tmCompleteDiscrete_refuted` and `not_bl_derivable_z1` are "now landed … machine-checked" is
now true of code `lake build` actually compiles.

**Phase 6 — the global simp loop.** The 21 unfold and 10 fold lemmas in
`Automation/Normalization.lean` are exact `rfl` inverses of each other; with both families
tagged `@[simp]`, plain `simp` rewrote in a cycle and died on any `Formula` goal. They now carry
`@[formula_unfold]` / `@[formula_fold]`, two simp sets declared in a new module,
`Automation/NormalizationAttr.lean`. The separate module is **required**, not stylistic:
`register_simp_attr`'s attribute is not usable in its own compilation unit. `modalNorm`,
`modalNormAt` and `modalNormAll` collapsed from a 21-name list to `simp only [formula_unfold]`.
Three untouched-by-design items: `normalizeFormula_id`'s `@[simp]` (the 32nd tag, not part of the
loop); `modalFold`, kept on its `←`-form because six of its entries have no `_fold` counterpart,
so `simp only [formula_fold]` would be a real behavioural change; and `propNorm`/`modalOpNorm`/
`temporalNorm`, each a proper sub-list that `[formula_unfold]` would over-normalize.

**Phase 7 — the Aesop rule set.** `Automation/AesopRules.lean`'s 21 rules were registered in
Aesop's **default** rule set, so plain `aesop` picked them up in every consumer of
`FormalSystem.Automation`. All 21 retagged into `(rule_sets := [TMLogic])`, with the rule set
declared in a new `Automation/AesopRuleSet.lean`. The module docstring at `:50-53`, which
documented the defect verbatim, was rewritten in the same change.

**Phase 8 — acceptance gate.** See the table above.

## Empirical probes run (not assumed)

- **`declare_aesop_rule_sets` import boundary** — the plan made this a mandatory pre-layout probe.
  Measured: declaring and using a rule set in one file fails with `no such rule set: 'TMLogicProbe'`,
  and Aesop's own error text says "Declared rule sets are not visible in the current file; they
  only become visible once you import the declaring file." The same caveat as `register_simp_attr`
  therefore **does** apply, and the plan's conditional second module was needed. Mathlib takes the
  same route (`Mathlib/Tactic/Bound/Init.lean`, `Mathlib/CategoryTheory/Category/Init.lean`). The
  two-module form was then probed and compiles clean.
- **Simp loop before/after** — a standalone `lake env lean` probe on
  `example (a : Formula) : a.neg = a.neg := by simp` exits 0, where research measured `maximum
  recursion depth has been reached` at `HEAD`. `simp only [formula_unfold]` and
  `simp only [formula_fold]` both resolve across the module boundary.
- **Aesop consumer blast radius** — the only live `aesop` tactic call anywhere in `FormalSystem/`
  or `Tests/` outside `AesopRules.lean`'s own docstring example is `ProofSystem/Derivable.lean:185`,
  and that file does not import `AesopRules`. No call site depended on the TM rules being in the
  default set, so the retag regresses no consumer.
- **typst** — `typst compile typst/FormalFoundations.typ` exits 0, and
  `bash scripts/typst-sync-check.sh` passes all three checks (backtick name resolution over 575
  candidates, `generated/status.typ` count freshness, machine-appendix freshness).

## Plan Deviations

- **Phase 2, Scope Hypothesis REFUTED.** The plan asserted the dead snake_case identifiers occur
  outside `specs/` in exactly two files. They occur in **seven**. Three are genuine documentation
  drift and were all fixed — the two planned files plus, unplanned,
  `FormalSystem/Metalogic/Core/README.md:114,118`, which cited `Formula.all_future` /
  `Formula.all_past` in a `lean` code block (corrected to `Formula.allFuture` / `Formula.allPast`,
  matching `Core/MCSProperties.lean:251,313`). The other four are **not** documentation drift and
  were deliberately left alone: `Automation/Normalization.lean`'s 37 hits are live constructors of
  a *different* type, `EnrichedFormula`; `Tests/BimodalTest/Semantics/SemanticBenchmark.lean` and
  `Tests/BimodalTest/ProofSystem/DerivationBenchmark.lean` are the two modules already manifested
  as known-broken / not compile-checked under C6, and repairing them is a code change outside a
  documentation hotfix; `Tests/BimodalTest/Syntax/FormulaTest.lean:99,104` are comments with no
  identifier use. **Consequence**: the plan's Testing & Validation line asking that
  `grep -rn -E 'all_past|all_future|some_past|some_future' … | grep -v specs/` return nothing
  cannot be met by that grep, because the pattern over-matches a live unrelated type. The E-03
  *documentation* scope is closed.
- **Phase 6, altered.** `NormalizationAttr.lean` carries a module docstring and per-attribute
  docstrings in addition to the header, `import Lean` and the two `register_simp_attr` lines; the
  plan said "**only**" those three. The docstrings record why the module must exist separately —
  the single fact a future reader is most likely to undo by mistake.
- **Phase 6, added.** Three now-false docstring sites in `Normalization.lean` were corrected in
  the same change, on the same reasoning the plan applies to `AesopRules.lean:50-53`: `:21`
  ("15 `_unfold` simp lemmas"), `:30` ("Fold-direction simp lemmas"), and `:169` ("Plain macro
  approach (no `registerSimpAttr` infrastructure needed)"), which the change makes exactly
  backwards.
- **Phase 7, added.** `AesopRules.lean:27-28`'s "This module defines the TMLogic rule set" was
  rewritten to say the module *populates* it and to point at `AesopRuleSet.lean` as the declaring
  module, for the same self-consistency reason.
- **Phase 1, verification criterion not literally met.** The plan asks that
  `grep -n -iE 'dedekind.*open|open.*dedekind' README.md` return no hit. It returns two: `:198`
  (whether the paper's BX_c should carry the density axioms) and `:245` (closed-form
  characterizations of `Mod (AxiomSet .Dedekind)`). Both are genuinely open questions unrelated to
  strong-completeness status, and both are correctly stated. Left as they are.

Scope Hypotheses for Phases 1, 3, 4, 5, 6 and 7 were each checked at implementation time and
**confirmed**; only Phase 2's was refuted. Each phase's hypothesis block in the plan was rewritten
in place to record the measured outcome.

## Non-Goals deliberately left undone

Recorded so the seven downstream tasks (517, 519, 520, 521, 522, 523, 529) inherit an accurate
picture:

1. **`FormalSystem/Semantics.lean` hygiene additions** — neither `Semantics.LexCarrier` nor
   `Semantics.BLSchemaValidity` was added. Neither is required for C6 (`BLSchemaValidity` is
   already reachable via `Metalogic/BaseLanguageSoundness.lean:10`; `LexCarrier` came in
   transitively through `Z1Countermodel`), and the `LexCarrier` addition carries real risk: it
   would put `SuccOrder`/`PredOrder` instances on `ℚ ×ₗ ℤ` plus four Mathlib order/algebra imports
   into the aggregator essentially every module imports, widening instance search tree-wide.
2. **Two `push_neg` deprecation warnings** at `Z1Countermodel.lean:101` and `:148`, now visible in
   the main build since Phase 5 wired the module in. Exactly two, as predicted; non-fatal.
   `push_neg` is deprecated in favour of `push Not`.
3. **A cycle-enumerating invariant check** — `check-module-invariants.sh` still has no check that
   derives the directory-cycle count from the import graph instead of relying on
   `Metalogic/README.md`'s hand-counted "exactly two". Phase 4 restored that number's accuracy but
   did not make it self-verifying.
4. **The six missing `_fold` lemmas** (`weak_future`, `weak_past`, `always`, `sometimes`,
   `strong_release`, `strong_trigger`) that would make `modalFold` symmetric and let it move to
   `simp only [formula_fold]`.
5. **The two known-broken benchmark modules** — `SemanticBenchmark.lean` and
   `DerivationBenchmark.lean` still reference dead `Formula.all_future`/`Formula.all_past`
   identifiers, which is why they are manifested as not-compile-checked under C6 (surfaced during
   Phase 2; see the deviation above).

## Files Modified

- `README.md`
- `FormalSystem/README.md`
- `FormalSystem/Syntax/README.md`
- `FormalSystem/Metalogic/Core/README.md`
- `typst/FormalFoundations.typ`
- `FormalSystem/Metalogic/Bundle/LimitMCS.lean`
- `FormalSystem/Metalogic.lean`
- `FormalSystem/Automation/Normalization.lean`
- `FormalSystem/Automation/AesopRules.lean`
- `Tests/BimodalTest/Automation/NormalizationTest.lean`
- `FormalSystem/Automation/NormalizationAttr.lean` (new)
- `FormalSystem/Automation/AesopRuleSet.lean` (new)
