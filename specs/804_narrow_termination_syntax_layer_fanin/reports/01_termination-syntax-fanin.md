# Research Report: Task #804

**Task**: 804 - Narrow the termination subtree's fan-in from the syntax layer
**Started**: 2026-11-13T19:26:59Z
**Completed**: 2026-11-13T22:19:51Z
**Effort**: ~3h research (probes, import-graph simulation, 94 shadow compiles)
**Dependencies**: None (task 803 already landed; its result changes the cost picture, see Context)
**Sources/Inputs**: - Codebase (import lines of the 25 termination modules and the Decidability spine below them); built oleans under `.lake/build/lib/lean` read by `run_cmd` probes (`Expr.getUsedConstants`, `env.header.moduleData`); shadow-root single-file compiles with the toolchain `lean`; `scripts/check-module-invariants.sh` header (gate inventory); `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md`. No Mathlib search tools were needed; no literature source is referenced by the task.
**Artifacts**: - specs/804_narrow_termination_syntax_layer_fanin/reports/01_termination-syntax-fanin.md; probes, the tested diff and raw compile results under specs/804_narrow_termination_syntax_layer_fanin/probes/
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- The fan-in is **mostly incidental**. The termination subtree's import closure holds 146 `FormalSystem` modules, 75 of them under `Semantics/`. Its declarations (types, definitions and proof terms) reach constants in only 15 of the non-Decidability ones, and none in `Semantics/`.
- One unused import line carries almost all of it: `import FormalSystem.Semantics` in `FormalSystem/Automation/ProofSearch/Core.lean`. `Core.lean` uses zero constants from any Semantics module, but `Closure.lean` imports `Core`, so every Semantics edit rebuilds `Closure`, `Saturation`, `Fuel` and all of `MintBound` (23 of 25 termination modules).
- The dependence on `ProofSystem/Axioms.lean` is **essential for 23 of 25 modules**. `ClosedBranch`/`ClosureReason.axiomNeg` carries a `DerivationTree` witness and `findClosure` calls `matchAxiom` over `Axiom`; `Fuel` and `MintBound` are stated over those types. No import change breaks that path.
- Recommended: four import-only narrowings (R1-R4, nine files, no statement touched). Together they cut the subtree's closure from 146 to 52 `FormalSystem` modules and take the termination subtree out of the rebuild set of every Semantics edit and of the `Syntax.lean` aggregator. All 89 modules whose import closure shrinks, plus the two restructured ones (`Axioms`, the new `FrameClass`), were compiled under the narrowed imports: 91 of 91 pass.
- For an edit to `Axioms.lean` itself the gain is small: 520 -> 519 rebuilt modules with R1-R4, 520 -> 516 if `FrameClass` is also relocated (R5, optional). That is the honest answer to the acceptance metric: the `Axioms.lean` path is essential.
- The first form of R1 failed its compile gate (`ring` and `Finset.max'` reached the subtree only through the Semantics aggregator); the revised form adds two explicit Mathlib imports and passes.

## Context & Scope

**Question.** Whether `FormalSystem/Metalogic/Decidability/Verified/Termination/` must sit downstream of the syntax, proof-system and semantics layers it currently imports, edge by edge, with declaration-level evidence.

**Scope.** The 25 termination modules (`SubformulaProperty`, `TimeTypeBound`, `Fuel`, `MintBound` and its 21 submodules) and the spine they import: `SignedFormula`, `Tableau`, `Closure`, `TraceCertificate`, `Saturation`, `Automation/ProofSearch/Core`, `Automation/SuccessPatterns`. Nothing was edited in the working tree; all experiments ran on copies in a scratch directory.

**The cost picture has changed since the task was written.** The task description's timings (SubformulaProperty 1103s, Tableau 476s, MintPotential 360s, Fuel 238s; 414 of 2848 jobs, 6354s) are CARRIED-UNVERIFIED from the task description; the build log they came from has since been overwritten. Task 803's evidence file reports SubformulaProperty at 2.7s-3.2s after its change (CARRIED-UNVERIFIED, source: `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md`). Measured here, single `lean` process per file on the shadow tree: SubformulaProperty 2-3s, Tableau 101-125s, Fuel 75s, MintBound.OrderingTimes 111s, MintBound.MintPotential 133s; `Fuel` plus all of `MintBound` 464s; the whole 34-module chain 585s. So the expensive part of the subtree is now `Fuel` + `MintBound`, which is exactly the part R1 detaches from Semantics.

**Method.**
1. Import graph: leading `import` lines, cross-checked against `env.header.moduleData` of the built oleans.
2. Declaration-level use: for every constant of a module, `Expr.getUsedConstants` over its type and its value, grouped by the declaring module of each used constant. Theorem values require `ci.value? (allowOpaque := true)`; see Risks.
3. Simulation: candidate import edits applied to the graph; rebuild sets computed as reverse closures over the 852 project modules (`FormalSystem`, `BimodalTest`, `BimodalTools`).
4. Compile gate: a shadow olean root (symlinks to every real olean, real files for the edited chain) with each affected module compiled by `lean --root -o` against it. The real `.lake` tree was never written (md5 of `Tableau.olean` and `Axioms.olean` unchanged afterwards).

## Findings

### Codebase Patterns

**Import paths from the subtree to the lower layers (current tree).**

```
SubformulaProperty -> Tableau -> SignedFormula -> Syntax.Formula
                                               -> ProofSystem (aggregator: Axioms, Derivation, Derivable, DerivedAxioms, LinearityDerivedFacts)
                   -> Syntax.SubformulaClosure.Closure
TimeTypeBound      -> SubformulaProperty
Fuel               -> TimeTypeBound
                   -> Saturation -> Closure -> Tableau
                                            -> Automation.ProofSearch.Core -> ProofSystem (aggregator)
                                                                           -> Semantics (aggregator, 37 imports, 75 modules transitively)
                                                                           -> Automation.SuccessPatterns -> Syntax (aggregator)
                                                                           -> Theorems.{Combinators, Perpetuity.Helpers, ConnectDerived, LinearityDerived}
                                 -> TraceCertificate -> Syntax (aggregator), ProofSystem (aggregator), SignedFormula, Closure
                                 -> Syntax.SubformulaClosure.Closure
MintBound.*        -> Fuel (and each other only)
```

**Edge classification.** "Uses" counts are occurrences of constants of the target module in the types and values of the source module's declarations (auto-generated matchers and equation lemmas included in the counts, excluded when naming examples).

| # | Edge | Declaration-level evidence | Class |
|---|------|----------------------------|-------|
| 1 | `SignedFormula` -> `Syntax.Formula` | 483 uses (`Formula`, its constructors); 30 of `Syntax.Atom` | Essential |
| 2 | `SignedFormula` -> `ProofSystem` (aggregator) | 0 uses of any `ProofSystem.*` constant; compiles with the import and its `open` removed | **Reducible** (drop) |
| 3 | `Tableau` -> (via 2) `ProofSystem.Axioms` | 84 uses, all `FrameClass`, its four constructors, `instLEFrameClass`, `instDecidableRelFrameClassLe`; no `Axiom` | Essential for `FrameClass` only; **reducible** to `ProofSystem.Axioms`, or to a `FrameClass` module if relocated |
| 4 | `Tableau` -> (via 2) `Derivation`, `Derivable`, `DerivedAxioms`, `LinearityDerivedFacts`, `Syntax.Context` | 0 uses | **Reducible** (falls out of 2) |
| 5 | `SubformulaProperty` -> `Tableau` | 2057 uses (`applyRule`, `isApplicable`, the `as*?` destructors) | Essential |
| 6 | `SubformulaProperty` -> `Syntax.SubformulaClosure.Closure` | 0 uses; the module works over `Decidability.Formula.subformulas` from `SignedFormula`; compiles without the import | **Reducible** (unused) |
| 7 | `TimeTypeBound` -> `SubformulaProperty` | uses its closure theorems; no lower-layer constant beyond `Syntax.Formula`/`Atom` | Essential |
| 8 | `Fuel` -> `Saturation` | 86 uses (`expandBranchWithFuel`, `BudgetedTableau`, `buildTableauAt`, `estimateBranchDifficulty`, `soundFuel`, `saturateBlocked`) | Essential |
| 9 | `Fuel`/`MintPotential` -> `Syntax.SubformulaClosure.Closure` (via `Saturation`) | `subformulaClosure` (20 + 2 uses), `self_mem_subformulaClosure`; `Saturation.soundFuel` is defined with it | Essential |
| 10 | `Saturation` -> `Closure` | 402 uses (`ClosedBranch`, `findClosure`, `ClosureReason`) | Essential |
| 11 | `Saturation` -> `TraceCertificate` | 64 uses (`TraceM`, in `expandBranchWithFuelTracedImpl`) | Essential |
| 12 | `Closure` -> `Automation.ProofSearch.Core` | `matchAxiom`, `matchMirror`, `matchPriorSZ` (3 each, in `checkAxiomNeg`) | Essential under the current definition of `findClosure` |
| 13 | `Closure` -> `ProofSystem.Axioms`, `ProofSystem.Derivation` | `Axiom` (7), `DerivationTree` (33), `DerivationTree.axiom` (3): `ClosureReason.axiomNeg` stores a `DerivationTree fc₀ [] φ` witness | Essential |
| 14 | `Core` -> `ProofSystem` (aggregator) | uses `Axioms` (111), `Derivation` (71), `DerivedAxioms` (13); 0 of `Derivable`, `LinearityDerivedFacts` | Essential for three modules; **reducible** to `Derivation` + `DerivedAxioms` |
| 15 | `Core` -> `Semantics` (aggregator) | 0 uses of any constant of any Semantics module; the only occurrence of `Semantics` in the file is the import line | **Reducible** (unused) |
| 16 | `Core` -> `Theorems.{Combinators, Perpetuity.Helpers, ConnectDerived, LinearityDerived}` | 17 uses; `matchAxiom`'s witnesses are built from them, and they are in the constant closure of `Fuel` (21 + 15 + 8 constants, plus `TemporalDerived`, `Propositional.*`) | Essential |
| 17 | `Core` -> `Automation.SuccessPatterns` -> `Syntax` (aggregator) | `SuccessPatterns` uses only `Syntax.Formula`; it compiles with `import FormalSystem.Syntax.Formula` | **Reducible** (narrow) |
| 18 | `TraceCertificate` -> `Syntax` (aggregator) | uses `Syntax.Formula` only (65) | **Reducible** (drop; arrives via `SignedFormula`) |
| 19 | `TraceCertificate` -> `ProofSystem` (aggregator) | 29 uses, all `FrameClass` | **Reducible** (drop; arrives via `Closure`) |
| 20 | `MintBound.*` -> lower layers | direct uses outside Decidability: `Syntax.Formula`/`Atom`, `FrameClass` (1076 occurrences, no other `ProofSystem` constant), `subformulaClosure` (2) | Essential, all inherited through `Fuel` |

**What the subtree actually reaches.** Transitive constant closure of all declarations of `Fuel` and of `MintBound.*`, outside Decidability: `Syntax.{Atom, Formula, Context, Subformulas, SubformulaClosure.Closure}`, `ProofSystem.{Axioms, Derivation, DerivedAxioms}`, `Automation.ProofSearch.Core` (`matchAxiom`, `matchMirror`, `matchPriorSZ`, `mirrorCandidate`), `Theorems.{Combinators, ConnectDerived, LinearityDerived, TemporalDerived, Propositional.Core, Propositional.Connectives}`. For `SubformulaProperty` and `TimeTypeBound`: `Syntax.Atom`, `Syntax.Formula`, `SignedFormula`, `Tableau` and nothing else (not even `FrameClass`). No constant of `Semantics/`, `PlusLanguage/`, `StarLanguage/`, `ForMathlib/`, `ProofSystem.Derivable`, `ProofSystem.LinearityDerivedFacts`, `Automation.SuccessPatterns`, or `Syntax.SubformulaClosure.{NestingDepth, TemporalFormulas, IteratedTemporal}` is reached, although all of them are in the import closure.

**Why the `Axioms.lean` path cannot be cut by imports.** `Fuel` and `MintBound` use `findClosure` opaquely (7 direct uses, no lemma about `checkAxiomNeg`), but they are stated over `ClosedBranch` (127 uses) and `expandBranchWithFuel`, whose types contain `ClosureReason`, hence `DerivationTree`, hence `Axiom`. Detaching them would mean parameterising the expansion engine over an abstract closure oracle and restating the termination theorems for the generic engine. That changes definitions the decision procedure runs and statements that are proved, which the task's non-goals exclude.

**Rebuild sets, before and after** (module counts out of 852 project modules; "Term." is how many of the 25 termination modules are in the set; computed on the import graph, not by timing a build):

| Edited file | Now | R1-R4 | R1-R5 | Term. now | Term. after |
|---|---|---|---|---|---|
| `ProofSystem/Axioms.lean` | 520 | 519 | 516 | 25 | 25 (23 with R5) |
| `ProofSystem/Derivation.lean` | 361 | 356 | 356 | 25 | 23 |
| `ProofSystem/Derivable.lean` | 354 | 349 | 349 | 25 | 23 |
| `ProofSystem/DerivedAxioms.lean` | 339 | 334 | 334 | 25 | 23 |
| `Syntax/Formula.lean` | 769 | 769 | 769 | 25 | 25 |
| `Syntax/Context.lean` | 544 | 538 | 538 | 25 | 23 |
| `Syntax/Subformulas.lean` | 298 | 284 | 284 | 25 | 23 |
| `Syntax/SubformulaClosure/Closure.lean` | 297 | 283 | 283 | 25 | 23 |
| `Syntax/SubformulaClosure/NestingDepth.lean` | 233 | 165 | 165 | 23 | 0 |
| `Syntax/SubformulaClosure/TemporalFormulas.lean` | 224 | 155 | 155 | 23 | 0 |
| `Syntax.lean` (aggregator) | 107 | 29 | 29 | 23 | 0 |
| `Semantics.lean` (aggregator) | 251 | 204 | 204 | 23 | 0 |
| `Semantics/Validity.lean` | 445 | 404 | 404 | 23 | 0 |
| `Semantics/Truth.lean` | 485 | 444 | 444 | 23 | 0 |
| `Semantics/TaskFrame.lean` | 561 | 520 | 520 | 23 | 0 |

The "23 -> 0" rows are `Fuel` + `MintBound` (464s of single-process compile, measured here) plus `Closure`, `Saturation`, `TraceCertificate`, `ProofExtraction`, `Verified/Decidable`, seven `Verified/Bridge` modules, three `Automation` modules and nine test modules: 47 modules leave the rebuild set of `Semantics.lean`. The "25 -> 23" rows are `SubformulaProperty` and `TimeTypeBound`, with `Tableau` (101-125s) and `SignedFormula` alongside them.

Across the whole subtree: modules whose edit rebuilds at least one termination module drop from 146 to 51 (Semantics 75 -> 0, Syntax 10 -> 5, ProofSystem 6 -> 4, PlusLanguage 6 -> 0, StarLanguage 4 -> 0, ForMathlib 3 -> 0); the external (Mathlib, Batteries, Lean) part of `Fuel`'s closure drops from 4126 to 3049 modules.

The batch in the task description touched `Axioms.lean`, `Semantics.lean` and Syntax modules together. An `Axioms.lean` edit alone still rebuilds everything, so that particular batch would not have been cheaper. The gain is for the more common batches that touch Semantics or the non-`Formula` Syntax modules without touching `Axioms.lean`.

### External Resources

- No Mathlib search was needed. Two Mathlib modules matter: `Mathlib.Tactic.Ring` (the `ring` tactic, used in `Fuel` and six `MintBound` modules; it also brings `norm_num`, used in `MintBound.PostBlocking`) and `Mathlib.Data.Finset.Max` (`Finset.max'`, `Finset.max'_mem`, `Finset.le_max'`, used in `MintBound.ClosureResidual` and `MintBound.LabelHeadroom`). Both currently reach the subtree only through `Core`'s Semantics import.
- Lake rebuilds a module when the olean of anything in its transitive import closure changes, regardless of which declarations are used. That is why an unused import is a real invalidation edge.

### Recommendations

- **R1 (highest value). Remove `import FormalSystem.Semantics` from `FormalSystem/Automation/ProofSearch/Core.lean`.** [VERIFIED: FAIL -- shadow compile of `Termination/Fuel.lean` against the narrowed `Core`: 8 errors, "unknown tactic" at the two `by ring` sites (lines 2198, 2470); then `MintBound/ClosureResidual.lean`: 4 errors, `Finset.max'` not in the environment; revised to: remove the import **and** add `import Mathlib.Tactic.Ring` to `Termination/Fuel.lean` and `import Mathlib.Data.Finset.Max` to `Termination/MintBound/ClosureResidual.lean`. Revised form re-run: all 34 chain modules and all 57 other modules whose import closure shrinks compile, 0 errors.]
- **R2. In `Decidability/SignedFormula.lean` remove `import FormalSystem.ProofSystem` and the line `open FormalSystem.ProofSystem`; in `Decidability/Tableau.lean` add `import FormalSystem.ProofSystem.Axioms`.** Takes `Tableau`, `SubformulaProperty`, `TimeTypeBound` out of the rebuild set of `Derivation`, `Derivable`, `DerivedAxioms`, `LinearityDerivedFacts` and `Syntax.Context`. [VERIFIED: PASS -- shadow compile of `SignedFormula`, `Tableau` (125s), `SubformulaProperty`, `TimeTypeBound` with exactly these imports, 0 errors]
- **R3. Narrow three aggregator imports:** `Decidability/TraceCertificate.lean` drops `import FormalSystem.Syntax` and `import FormalSystem.ProofSystem`; `Automation/SuccessPatterns.lean` replaces `import FormalSystem.Syntax` with `import FormalSystem.Syntax.Formula`; `Automation/ProofSearch/Core.lean` replaces `import FormalSystem.ProofSystem` with `import FormalSystem.ProofSystem.Derivation` and `import FormalSystem.ProofSystem.DerivedAxioms`. This is what produces the `Syntax.lean`, `NestingDepth`, `TemporalFormulas` rows of the table. [VERIFIED: PASS -- same shadow run as R1, all three files and everything downstream of them compile, 0 errors]
- **R4. Remove the unused `import FormalSystem.Syntax.SubformulaClosure.Closure` from `Termination/SubformulaProperty.lean`.** [VERIFIED: PASS -- shadow compile of `SubformulaProperty` and `TimeTypeBound` without it, 0 errors]
- **R5 (optional, default: defer). Relocate `FrameClass` to a new `FormalSystem/ProofSystem/FrameClass.lean`** (lines 427-552 of `Axioms.lean`: the docstring, the inductive, its `LE`/`DecidableRel`/`PartialOrder` instances, the order-shape `example`s; plus `FrameClass.base_le`, lines 632-640), imported by `Axioms.lean`; `Tableau.lean` then imports `ProofSystem.FrameClass` instead of `ProofSystem.Axioms`. Gain: an `Axioms.lean` edit stops rebuilding `SignedFormula`, `Tableau`, `SubformulaProperty`, `TimeTypeBound` (520 -> 516; about 110s of 585s chain compile). Cost: about 135 lines leave `Axioms.lean`, shifting every later line; 33 `Axioms.lean:NNN` citations at or after line 427 exist outside `specs/` and are gated by C20; a new module needs its README and inventory rows. This is the only change that moves the acceptance metric at all, and it moves it by 4 modules. [VERIFIED: PASS -- shadow compile of the new `FrameClass.lean` (imports `FormalSystem.Init`, `Mathlib.Order.Defs.PartialOrder`), the reduced `Axioms.lean`, `Tableau` importing only `ProofSystem.FrameClass`, and the full 34-module chain against real oleans of every other `Axioms` consumer, 0 errors. Not run: C20 citation gate, C24, README inventory.]
- **R6. Leave the `Closure` -> `Core` -> `Axioms`/`Derivation`/`Theorems` path as it is.** It is essential (edges 12, 13, 16). Do not abstract `findClosure` behind an interface: it would change definitions and proved statements for a path the measured evidence does not show to be the frequent one. [No compiled gate applicable]
- **Verification still owed by implementation.** The compile evidence above is 91 single-file shadow compiles (plus 3 for the R2 variant), not `lake build`. `lake build`, `check-module-invariants.sh` and the sorry count were not run against the change. `BimodalToolsTest` has no built oleans in this tree and was not covered; three of its files import the `Syntax`/`ProofSystem` aggregators directly and are unaffected by R1-R4, but any that reach Semantics names only through `Core` would need an explicit import. [No compiled gate applicable]

The exact diff that was compiled is `specs/804_narrow_termination_syntax_layer_fanin/probes/shadow-edits.diff` (it contains the R5 form of `Axioms.lean` and `Tableau.lean`; the R2 form of `Tableau.lean` is the one-line variant stated above).

## Decisions

- Classified an edge as reducible only when both hold: zero constants of the target reached at declaration level, and the source compiles without it. The constant probe alone is not sufficient (it cannot see tactic provenance, and it missed proof terms on the first pass).
- Treated `Closure`'s dependence on `Axiom`/`DerivationTree` as essential rather than proposing an interface, per the task's non-goals.
- Put the two new Mathlib imports at the files that need them (`Fuel`, `ClosureResidual`) instead of keeping a broad import in `Core`; `Fuel` is the root of the `MintBound` cone, so one `Mathlib.Tactic.Ring` import there covers all seven modules that use `ring`/`norm_num`.
- R5 is reported with its measured gain and left as optional; the import-only set R1-R4 stands on its own.

## Risks & Mitigations

- **Mathlib reaching the subtree transitively.** After R1 the cone below `Closure` loses 1077 external modules. Anything in the 89 affected modules that silently relied on them fails at compile time with "unknown tactic" or "unknown constant". Mitigation: all 89 were compiled; two imports were needed. Future additions in the cone that use a Mathlib tactic not otherwise imported will need an explicit import, which is ordinary hygiene.
- **Proof terms may elaborate differently.** With a smaller instance and simp-lemma environment, `simp`/`omega`/instance search can pick different routes (the graph simulation flagged `Saturation` and 15 termination modules as using Mathlib constants that leave their closure, yet all compile). Statements are unchanged; proof terms may differ. `#print axioms` baselines (C2, C14) should be re-checked by the implementation gate.
- **Shadow compile is not `lake build`.** Per-file timings are single-process and not comparable with Lake's `Built ... (Ns)` figures. Mitigation: the implementation phase runs the real build and the invariants harness.
- **R5 line shifts.** Covered above; use `scripts/reanchor-lean-citations.py` if R5 is taken.
- **Probe blind spot (fixed here).** `ConstantInfo.value?` returns `none` for every theorem on Lean v4.33.0-rc1 (0 of 212,953 theorems returned a value) unless called with `(allowOpaque := true)`. The first pass of every probe therefore ignored all proof terms. It was caught when a shadow compile failed on a constant the probe had not listed; all figures in this report are from the re-run with `allowOpaque := true`.
- **Concurrent work.** No file in the working tree was edited by this research; the only writes are under this task's `specs/` directory.

## Tactic Survey Results

- Not applicable (no tactic survey performed). No proof goal is under investigation; the only tactic-related finding is provenance: `ring` and `norm_num` reach the termination subtree through `Mathlib.Tactic.Ring`, which R1 makes an explicit import of `Fuel.lean`.

## Context Extension Recommendations

- **Topic**: Dependency probes and theorem values.
- **Gap**: `.claude/context/project/lean4/patterns/dependency-tracing.md` gives `(ci.value?.map Expr.getUsedConstants).getD #[]` in all of its probe shapes. On Lean v4.33.0-rc1 that expression yields nothing for theorems, so every shape silently skips proof terms and can report a clean result that is false.
- **Recommendation**: Change the recipe to `ci.value? (allowOpaque := true)`, and add a sanity line to each shape (count of theorems with a value must be non-zero). Edit the source store, not the deployed copy.
- **Topic**: Verifying import narrowing without a build.
- **Gap**: No documented way to test an import change against built oleans without touching `.lake`.
- **Recommendation**: Document the shadow-root pattern used here: symlink the library's olean directory into a scratch root, delete the links for the modules under test (never write through a symlink), put the scratch root first on `LEAN_PATH`, compile with `lean --root=<src mirror> -o <scratch olean>`. Note that the first search-path entry containing the package directory wins, so the scratch root must mirror the whole library.

## Appendix

- **Probes** (`specs/804_narrow_termination_syntax_layer_fanin/probes/`): `DirectUseProbe.lean` (per-module direct uses and the named constants), `ClosureProbe.lean` (transitive constant closure per module group), `WholeRepoUsesProbe.lean` (module graph and use table for all 852 modules), `simulate_import_edits.py` (rebuild sets and closure-loss check), `shadow-chain-results.txt` and `shadow-extras-results.txt` (raw per-module compile results, including the failed attempts), `shadow-edits.diff`.
- **Invocation**: probes ran as `lake env lean <probe>` (no build triggered; nothing under `.lake` written); shadow compiles used the toolchain `lean` binary under the environment captured from `lake env printenv`, at most 8 processes.
- **Sanity checks**: the closure-loss check reports 0 violations on the unedited graph; `Tableau.olean` and `Axioms.olean` md5 sums were identical before and after the shadow runs.
- **Counts**: 852 project modules in the built environment (757 under `FormalSystem`); 89 modules lose part of their import closure under R1-R5, plus `Axioms` (closure grows by one) and the new `FrameClass` module, giving the 91 compiled; the R2 variant added 3 more compiles.
