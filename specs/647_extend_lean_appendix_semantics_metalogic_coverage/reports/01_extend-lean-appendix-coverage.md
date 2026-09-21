# Research Report: Extend the Lean appendix to semantics, a derived theorem, the metalogic map, and the decision procedure

- **Task**: 647 - extend_lean_appendix_semantics_metalogic_coverage
- **Started**: 2026-09-21T14:02:20-07:00
- **Completed**: 2026-09-21T14:41:00-07:00
- **Effort**: ~40 minutes (verification-heavy; every name and signature re-derived from live source)
- **Dependencies**: None upstream. Task 648 and task 649 both depend on this task landing first (see Project Context).
- **Sources/Inputs**:
  - Lean source: `FormalSystem/Semantics/{TemporalOrder,TaskFrame,PartialHistory,TaskModel,Truth,TruthTransport}.lean`, `FormalSystem/ProofSystem/{Axioms,Derivation,DerivedAxioms}.lean`, `FormalSystem/Theorems/Perpetuity/Principles.lean`, `FormalSystem/Theorems/Propositional/Connectives.lean`, `FormalSystem/PlusLanguage/{Formula,PlusTruth}.lean`, `FormalSystem/Metalogic/{Soundness,StrongCompleteness,Compactness,SetConsequence,DiscreteNonCompactness,DedekindNonCompactness,Decidability,Conservativity}.lean`, `FormalSystem/Metalogic/Decidability/{DecisionProcedure,Correctness}.lean`, `FormalSystem/Metalogic/Conservativity/Plus.lean`, `FormalSystem/README.md`, `FormalSystem/MainResults.lean`
  - Live elaboration: `lake env lean` on five scratch probe files (outside `FormalSystem/` and `Tests/`)
  - Typst: `typst/chapters/ax-lean-appendix.typ`, `typst/chapters/{02-semantics,p2-decidability-practice,04-metalogic,05-theorems}.typ`, `typst/template.typ`, `typst/generated/status.typ`, `typst/sync-check-whitelist.txt`, `typst/SYNC-MAP.md`
  - Tooling: `scripts/typst-sync-check.sh`, `scripts/typst-status-counts.sh`, `scripts/typst-module-map.sh`, `.claude/scripts/typst-element-lint.sh`
  - Build config: `lean-toolchain`, `lakefile.toml`, `lake-manifest.json`
- **Artifacts**:
  - `specs/647_extend_lean_appendix_semantics_metalogic_coverage/reports/01_extend-lean-appendix-coverage.md`
- **Standards**: report-format.md, subagent-return.md, status-markers.md, artifact-formats.md

## Project Context

- **Upstream Dependencies**: none. The appendix file is self-contained; its only imports are `../template.typ` and `../generated/status.typ`.
- **Downstream Dependents**: task 648 (fixes defects outside the appendix; its item (1) renames the appendix title and must be applied once against the final file) and task 649 (defines one Lean code environment in `typst/template.typ` and migrates every chapter). Both are ordered after this task.
- **Alternative Paths**: none. The appendix is the only place in the book that teaches Lean reading.
- **Potential Extensions**: `typst/generated/status.typ` gains repository-scale figures (see Recommendation R6), which other chapters can then cite instead of hand-typing.

## Executive Summary

- **Every one of the ten coverage items is real and quotable.** All named declarations exist, and every signature was re-derived from live source and from `#check` output rather than transcribed. One name in the dispatch is wrong and one is under-qualified (see Findings, "Two name corrections").
- **Every candidate didactic snippet compiles.** Twenty examples covering the coercion, the subtype projections, a truth clause, the binder forms, `modal_search` on the MF instance, the four frame-class order facts, `DerivationTree.lift`, and `decide`'s default arguments elaborate with zero errors under `lake env lean` against the current library.
- **All four acceptance gates are green at baseline**, so any post-change failure is attributable: `typst compile` exit 0, `typst-sync-check.sh` PASS (3/3, 685 backtick candidates, 0 violations), `typst-element-lint.sh` PASS, and exactly one semicolon in the file (the permitted `apply DerivationTree.axiom; refine ?_`).
- **Only five new backtick spans need whitelisting**, and four of those are avoidable by choosing the source's own spelling. Sixty-nine candidate spans were tested against Check 1's resolution rule; the rest resolve unaided.
- **Item (10) is the only item that needs tooling work before prose.** `typst/generated/status.typ` carries no line count, file count, version pin or repository size, and `typst-sync-check.sh` Check 2 only asserts the eight scalar fields it names — new `#let` bindings drift silently unless Check 2's `scalar_fields`/`live_map` are extended alongside the generator.
- **Recommended shape: reorganize into twelve sections, not nine plus an appendix of additions**, with the new material threaded in dependency order and the existing `lean-appendix-*` labels preserved. Expect the file to roughly double, from 11 rendered pages to about 20-24, which argues for a four-to-six phase plan rather than one dispatch.

## Context & Scope

The task extends `typst/chapters/ax-lean-appendix.typ` (currently 440 lines, rendered pages 88-98 of a 107-page `BimodalReference.pdf`) so a reader can read the semantic layer, a derived theorem, the metalogic result map and the decision procedure in Lean, not only the syntax and proof system it covers today.

Research scope was: verify every name and signature named in the dispatch against live source, compile every didactic snippet that the new sections would carry, establish the baseline state of all four acceptance gates, determine the whitelist and generator deltas, and propose a section arc. Prose authoring is out of scope and belongs to implementation.

Constraints carried into every recommendation below: no prose semicolons; one sentence per source line; `#leansrc` excerpts verbatim up to whitespace with docstrings omitted and lines re-broken to at most 71 columns; didactic examples compiled first with `lake env lean` in a scratch file outside `FormalSystem/` and `Tests/`; existing labels stable; no task numbers and no `specs/` paths in the file.

## Findings

### Two name corrections

Both were caught by elaborating the dispatch's own names, and both change what implementation should write.

- **`FormalSystem.Metalogic.Conservativity.Plus.plusDerivable_ofFormula_iff` does not exist.** `#check` reports `Unknown identifier`. The declaration is at `FormalSystem/Metalogic/Conservativity/Plus/Forward.lean:98`, but that file opens `namespace FormalSystem.Metalogic.Conservativity` (line 54), not a nested `Plus`. The correct qualified name is `FormalSystem.Metalogic.Conservativity.plusDerivable_ofFormula_iff`. The directory is `Plus/`; the namespace is not.
- **`contraposition` is ambiguous and must be written qualified.** Two live declarations carry the name with identical statements: `FormalSystem.Theorems.Propositional.contraposition` (`Theorems/Propositional/Connectives.lean:312`) and `FormalSystem.Theorems.Perpetuity.contraposition` (`Theorems/Perpetuity/Principles.lean:115`). `perpetuity2` calls the second, its own namespace-local one. Item (4)'s prose should say `Perpetuity.contraposition` or name the namespace, exactly as the appendix's existing `Axiom.modal_t` convention (line 335) already requires for a clashing short name.

Everything else the dispatch names resolves as stated.

### Verified signature ledger

Re-derived from source, with `#check` output where the elaborated form differs from the written one. `#leansrc` labels take the **namespace**, not the file path, per `typst/template.typ:98`.

| Item | Declaration | `#leansrc` namespace | Source | Max source column |
|---|---|---|---|---|
| 1 | `TemporalOrder` (4 instance-bracket fields) | `FormalSystem.Semantics` | `Semantics/TemporalOrder.lean:83-93` | 51 |
| 1 | `CoeSort TemporalOrder Type` + `attribute [instance]` | `FormalSystem.Semantics` | `Semantics/TemporalOrder.lean:95-99` | 73 (re-break) |
| 1 | `FrameOver` (`WorldState`, `[worldNonempty]`, `PosRel`, `comp`, `serial`, `limit`, `saturation`) | `FormalSystem.Semantics` | `Semantics/TaskFrame.lean:768-850` | see note |
| 1 | `FrameOver.TaskRel` | `FormalSystem.Semantics` | `Semantics/TaskFrame.lean:882-883` | 74 (re-break) |
| 1 | `FrameOver.reflection` (theorem, not a field) | `FormalSystem.Semantics` | `Semantics/TaskFrame.lean:984-985` | 85 (re-break) |
| 1 | `TaskFrame` (`Duration : TemporalOrder`, `toFibre : FrameOver Duration`) | `FormalSystem.Semantics` | `Semantics/TaskFrame.lean:2093-2097` | 30 |
| 1 | `TaskFrame.WorldState` / `TaskFrame.TaskRel` accessors | `FormalSystem.Semantics` | `Semantics/TaskFrame.lean:2161,2167` | fits |
| 2 | `PartialHistory` (`domain`, `nonempty_domain`, `states`, `respects_task`) | `FormalSystem.Semantics` | `Semantics/PartialHistory.lean:126-153` | 98 (re-break) |
| 2 | `PartialHistory.IsTotal` | `FormalSystem.Semantics` | `Semantics/PartialHistory.lean:215` | 73 (re-break) |
| 2 | `PartialHistory.IsConvex` | `FormalSystem.Semantics` | `Semantics/PartialHistory.lean:276-277` | 96 (re-break) |
| 2 | `WorldHistory` (`{τ : PartialHistory F // τ.IsTotal}`) | `FormalSystem.Semantics` | `Semantics/PartialHistory.lean:411-412` | 44 |
| 2 | `WorldHistory.state` | `FormalSystem.Semantics` | `Semantics/PartialHistory.lean:424-425` | 65 |
| 2 | `TaskModel` (already excerpted at appendix line 253) | `FormalSystem.Semantics` | `Semantics/TaskModel.lean:53-60` | fits |
| 3 | `TruthAt` (six clauses) | `FormalSystem.Semantics` | `Semantics/Truth.lean:231-240` | 67 |
| 3 | `PlusFormula` (seven constructors, `stab` last) | `FormalSystem.PlusLanguage` | `PlusLanguage/Formula.lean:91-108` | fits |
| 3 | `PlusTruthAt` (seven clauses) | `FormalSystem.PlusLanguage` | `PlusLanguage/PlusTruth.lean:84-93` | 92 (re-break) |
| 4 | `perpetuity2` | `FormalSystem.Theorems.Perpetuity` | `Theorems/Perpetuity/Principles.lean:310-322` | 87 (re-break) |
| 4 | `perpetuity1` | `FormalSystem.Theorems.Perpetuity` | `Theorems/Perpetuity/Principles.lean:76-81` | fits |
| 4 | `Axiom.modal_future` (MF) | `FormalSystem.ProofSystem` | `ProofSystem/Axioms.lean:297` | fits |
| 5 | `Truth.truthAt_of_truthCorr` | `FormalSystem.Semantics` | `Semantics/TruthTransport.lean:122-125` | fits |
| 5 | `shiftCorr` | `FormalSystem.Semantics` | `Semantics/TruthTransport.lean:228-236` | fits |
| 5 | `TimeShift.timeShift_preserves_truth` | `FormalSystem.Semantics.TimeShift` | `Semantics/TruthTransport.lean:252-259` | 86 (re-break) |
| 5 | `modal_future_valid` | `FormalSystem.Metalogic` | `Metalogic/Soundness.lean:372-378` | 84 (re-break) |
| 6 | `DerivationTree.lift` | `FormalSystem.ProofSystem` | `ProofSystem/Derivation.lean:190-197` | 82 (re-break) |
| 6 | `FrameClass` + its `LE` instance | `FormalSystem.ProofSystem` | `ProofSystem/Axioms.lean:540-555` | 54 |
| 6 | `DerivationTree.height` | `FormalSystem.ProofSystem` | `ProofSystem/Derivation.lean:223-230` | fits |
| 7 | `soundness_dense` / `soundness_ztime` / `soundness_rtime` | `FormalSystem.Metalogic` | `Metalogic/Soundness.lean:1491,1530,1579` | re-break |
| 7 | `completeness_base/_dense/_ztime/_rtime` | `FormalSystem.Metalogic` | `Metalogic/StrongCompleteness.lean:890,1001,1119,784` | fits |
| 7 | `compactBase` / `compactDense` | `FormalSystem.Metalogic` | `Metalogic/Compactness.lean:190,196` | fits |
| 7 | `strongCompletenessBase` / `strongCompletenessDense` | `FormalSystem.Metalogic` | `Metalogic/Compactness.lean:208,217` | 61 |
| 7 | `StrongCompletenessBase` (the `Prop`-valued def) | `FormalSystem.Metalogic` | `Metalogic/SetConsequence.lean:403` | 71 |
| 7 | `notCompactZTime` / `notStrongCompletenessZTime` | `FormalSystem.Metalogic` | `Metalogic/DiscreteNonCompactness.lean:270,292` | 71 |
| 7 | `notCompactRTime` / `notStrongCompletenessRTime` | `FormalSystem.Metalogic` | `Metalogic/DedekindNonCompactness.lean:462,482` | fits |
| 9 | `DecisionResult` (four constructors) | `FormalSystem.Metalogic.Decidability` | `Metalogic/Decidability/DecisionProcedure.lean:80-90` | 65 |
| 9 | `decide` (three default arguments) | `FormalSystem.Metalogic.Decidability` | `Metalogic/Decidability/DecisionProcedure.lean:176-177` | 78 (already re-broken at `p2-decidability-practice.typ:78`) |
| 9 | `sound_of_isValid` | `FormalSystem.Metalogic.Decidability` | `Metalogic/Decidability/Correctness.lean:107-112` | 96 (re-break) |

Note on `FrameOver`: the structure spans lines 768-850 but is nearly all docstring. With docstrings omitted it is nine short lines, the widest being `limit : ∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ TaskFrame.reflect PosRel w y u) → u = w` (85 columns, needs a re-break).

"Re-break" above means the appendix's stated convention applies (lines re-broken to at most 71 columns); it is not a defect.

### What `#check` prints, and why item (1) matters

`#check @FormalSystem.Metalogic.soundness` elaborates to a type mentioning `(t : F.Duration.carrier)`, not `(t : F.Duration)`, and the same substitution appears in `timeShift_preserves_truth`, `soundness_rtime`, `PlusTruthAt` and every other duration-indexed signature. This is exactly the gap the dispatch names: the appendix's current soundness walkthrough (line 393) quotes the source's `(t : F.Duration)` and leaves `F.Duration.carrier` unexplained for any reader who runs `#check` themselves.

The mechanism is two declarations in `Semantics/TemporalOrder.lean`: `instance : CoeSort TemporalOrder Type := ⟨TemporalOrder.carrier⟩` (line 96), which lets a `TemporalOrder` be used where a type is expected, and `attribute [instance] TemporalOrder.addCommGroup TemporalOrder.linearOrder TemporalOrder.isOrderedAddMonoid TemporalOrder.nontrivial` (lines 98-99), which re-exports the four bracketed fields to instance synthesis. Together they are why `[DenselyOrdered F.Duration]` in `soundness_dense` elaborates at all and why it prints back as `[DenselyOrdered F.Duration.carrier]`.

The same re-export pattern appears one level down: `attribute [instance] FrameOver.worldNonempty` (`Semantics/TaskFrame.lean:853`) and `instance worldNonempty (F : TaskFrame)` (line 2164). `FrameOver`'s own docstring states the design reason for carrying nonemptiness as a field rather than as an instance binder on the structure, which is a ready-made didactic paragraph.

### Item-by-item verification notes

- **(1) Semantic structures.** `FrameOver`'s four axiom fields are stated over `TaskFrame.reflect PosRel`, not over `TaskRel`, and `FrameOver.TaskRel` is a plain (non-`@[reducible]`) `def` for a stated reason. `reflection` is a theorem at both levels (`FrameOver.reflection`, `TaskFrame.reflection`), derived from `eq_of_taskRel_zero` (*Limit*) and `nullity` (*Seriality* plus *Limit*) at zero and from `TaskFrame.reflect_reflection_of_ne` off zero. `nullity`, `eq_of_taskRel_zero`, `nullity_identity` and `forward_comp` are likewise theorems, not fields. The source spells the convention `FrameOver.TaskRel := TaskFrame.reflect PosRel` (line 794); prefer that exact spelling over `F.TaskRel := TaskFrame.reflect F.PosRel`, which needs a whitelist entry.
- **(2) Histories.** `respects_task` is stated **unconditionally**, with no `s ≤ t` guard, and the guarded form is derived as `respects_task_le`. `IsTotal` is `∀ t : F.Duration, τ.domain t` and its docstring explicitly says it is deliberately not Mathlib's `IsMax`. `IsTotal.isConvex` gives totality implies convexity in one line. `WorldHistory` is a `def`, not an `abbrev`, for a stated reason, and `states_eq_state` is the `@[simp]` lemma collapsing the dependent projection. `TaskModel`'s field is `valuation : F.WorldState → Atom → Prop`; the set-of-states reading is `{w | M.valuation w p}`, which compiles.
- **(3) Structural recursion.** `TruthAt` writes fully qualified constructor patterns (`Formula.atom p`), while `PlusTruthAt` writes the dot form (`.atom p`) — a free contrast for teaching dot-anonymous constructor notation. Guard-first order is confirmed: `| Formula.untl ψ φ => ∃ s, t < s ∧ TruthAt M τ s φ ∧ ∀ r, t < r → r < s → TruthAt M τ r ψ`, so the **first** argument is the guard and the **second** is the event, with strict `<` throughout. `PlusTruthAt`'s `stab` clause is `∀ σ : WorldHistory F, τ.state t = σ.state t → PlusTruthAt M σ t φ` — one clause added to six, which is precisely the "extend a language by one constructor" story.
- **(4) Derived theorem.** `perpetuity2` elaborates to `{fc : FrameClass} → (φ : Formula) → ⊢[fc] (▽φ).imp φ.diamond`, so the pretty-printer folds `sometimes` to `▽`. Its body is two lines: one `have` naming `perpetuity1 φ.neg`, one `exact Perpetuity.contraposition h1`. It depends on `[propext]` alone — the lightest axiom footprint of anything in the ledger, and a good contrast with the `[propext, Classical.choice, Quot.sound]` of the metalogic results. The MF instance `example (φ : Formula) : ⊢ φ.box.imp φ.allFuture.box := by modal_search` compiles.
- **(5) Semantic counterpart.** `timeShift_preserves_truth` is an `↔`, proved in six lines from `Truth.truthAt_of_truthCorr (shiftCorr M (y - x))` plus `add_sub_cancel`, with no bespoke induction. Its docstring states the key point ("no shift-closure hypothesis is required"). It depends on `[propext, Quot.sound]` — notably **no** `Classical.choice`. `modal_future_valid` is where soundness spends it: `Metalogic/Soundness.lean:1243` reads `| modal_future a0 => exact modal_future_valid a0`, and line 378 is the single `timeShift_preserves_truth` call.
- **(6) Functions on derivations.** `lift` is seven pattern-match arms; only `.axiom` does work (`le_trans h_fc h_le`), the other six recurse. The `FrameClass` `LE` instance gives `Base ≤ everything`, `Dense ≤ {Dense, RTime}`, `RTime ≤ RTime`, `ZTime ≤ ZTime`, and `Axioms.lean:580-588` already carries eight `by decide` order-shape regression `example`s that the appendix can mirror. `height` recurses on the same seven constructors.
- **(7) Metalogic map.** `WeakCompleteness fc` unfolds to `∀ ψ, ValidIn fc ψ → Derivable fc [] ψ`, and `ValidIn FrameClass.Base = Valid` holds **by `rfl`** (verified). So `completeness_base` and the appendix's existing `BXCanonical.completeness` excerpt state the same thing, which is worth saying rather than leaving as an apparent duplication. `strongCompletenessBase` is the one-line term proof the dispatch describes. The two refutation witnesses differ: `notCompactZTime`/`notStrongCompletenessZTime` use `archWitness ⟨"p", none⟩`, and `notCompactRTime`/`notStrongCompletenessRTime` use `dedWitness ⟨"q", none⟩` — `archWitness` does not port, because `Formula.next` is vacuous on a dense carrier. The compactness route is documented at length in `Metalogic/Compactness.lean`'s module docstring: index by `Ultraproduct.Idx Γ` (finite lists drawn from `Γ`), one witness per index via `ShiftSet.ofModel`, combine by `Ultraproduct.uShiftSet (idxUF Γ)`, pull truth back through `Ultraproduct.los_truthAt`. The single hypothesis `hpres` (frame condition survives the ultraproduct) is the whole of the class-dependence, and it is false at `.ZTime` and `.RTime` for the standard nonstandard-analysis reason.
- **(8) A name is not a proof.** The retirement section is `Metalogic/Decidability/Correctness.lean:192-231`, and it is unusually quotable. `validity_decidable (φ : Formula) : (⊨ φ) ∨ ¬(⊨ φ)` was proved by `exact Classical.em (⊨ φ)`; `validity_has_decision_procedure (φ : Formula) : ∃ decision : Bool, decision = true ↔ ⊨ φ` was `by_cases` on the truth value one is trying to compute. Both statements and both proofs are given verbatim in the section, so the appendix can quote the retired statements without any risk of misdescribing them.
- **(9) Decision procedure types.** `#check @Decidability.decide` prints `optParam ℕ 10 → optParam ℕ 1000 → optParam FrameClass FrameClass.Base`, which is the cleanest possible demonstration that `:=` in a binder means an optional parameter. `decide φ` and `decide φ 10 1000 .Base` both elaborate. The honest split the dispatch asks for is already drafted in source: what is established is in `Correctness.lean`'s "What has since landed" paragraph, what is open is in its "What is still owed" paragraph, which names `valid_iff_allClosed`, the fuel/termination side, the truth-lemma gate, and the two rules scheduled outside `allRulesForFC` (`serialityRule` and `timeLinearity`, stages 2 and 3 of `expandOnce`). The book states these as open at `@sec:fmp-resolution` and `@sec:decidability-practice`.
- **(10) Project overview.** The import-layer order is documented in `FormalSystem/README.md:276-315` as Layer 0 (`ForMathlib`, `Tactic`, `Syntax`, `ProofSystem`, `PlusLanguage`), Layer 1 `Semantics`, Layer 2 `Metalogic`, Layer 3 `Theorems`, Layer 4 `Automation`, Layer 5 `Examples`. The dispatch's list of six omits `PlusLanguage` from Layer 0, which is where the README puts it. The four proof systems map to `ProofSystem/` (TM over L), `MinusLanguage/` (TM⁻ over L⁻), `PlusLanguage/` (TM⁺ over L⁺), `StarLanguage/` (TM⋆ over L⋆), with `OpenLanguage/` a fifth, semantics-only component (no proof system). TM⁺ soundness is `plus_soundness_base/_dense/_ztime/_rtime` in `Metalogic/Conservativity/Plus/PlusSoundness.lean`, and conservativity over TM is `Conservativity.plusDerivable_ofFormula_iff` plus its four per-class corollaries. `Metalogic/Conservativity.lean`'s own module docstring is about the **TM⁻/TM** bridge, and it carries a prominent "THE FORWARD DIRECTION IS NOT OPEN WORK — DO NOT ATTEMPT IT" section; TM⁺ conservativity holds at all four classes and is the aggregator `Conservativity/Plus.lean`. Do not conflate the two.

### Version and scale figures (for item 10)

Measured, not transcribed. These are the values a generator extension should compute.

| Figure | Value | Derivation |
|---|---|---|
| Lean toolchain | `leanprover/lean4:v4.33.0-rc1` | `lean-toolchain` |
| Mathlib requested tag | `v4.33.0-rc1` | `lakefile.toml` `[[require]]` `rev` |
| Mathlib resolved commit | `79d0395a1825a6264ad5d269e35e60537518955e` | `lake-manifest.json` |
| `FormalSystem/` files / lines | 515 / 281,204 | `find`/`wc`; cross-checks against the 515 import lines in the generated root `FormalSystem.lean` |
| `Tests/` files / lines | 66 / 20,953 | `find`/`wc` |
| `BimodalTools/` files / lines | 27 / 14,862 | `find`/`wc` |
| `Boneyard/` files / lines (archived) | 169 / 91,983 | `find`/`wc`; report separately or not at all, never folded into a live figure |
| Git-tracked files | 1,336 | `git ls-files` |
| Axioms / rules / sorries | 29 / 7 / 0 outside `Boneyard/` | already in `typst/generated/status.typ` |

The `FormalSystem.lean` import-count cross-check is worth keeping in the generator: the root is produced by `lake exe mk_all --lib FormalSystem` and checked byte-for-byte by `--check`, so a mismatch between the import count and the file count is a real inconsistency, not a counting bug.

### Backtick resolution: the whitelist delta

Sixty-nine candidate spans were tested against Check 1's rule (single identifiers and paths resolve by grep over `FormalSystem/` and `BimodalTools/` excluding `Boneyard/`; multi-word spans need a literal grep match or a whitelist entry). Sixty-four resolve unaided, including every identifier in the ledger above and multi-word spans such as `valuation : F.WorldState → Atom → Prop`, `states : (t : F.Duration) → domain t → F.WorldState`, `{τ : PartialHistory F // τ.IsTotal}`, `∀ σ : WorldHistory F`, `h.minFrameClass ≤ fc`, `(⊨ φ) ∨ ¬(⊨ φ)`, `Decidable (⊨ φ)`, `isValid φ fc = true → ⊨ φ`, `strongCompleteness_of_compact compactBase completeness_base` and `⟨"p", none⟩`.

Five do not resolve:

| Span | Why | Cheapest fix |
|---|---|---|
| `searchDepth := 10` | source has `(searchDepth : Nat := 10)` | whitelist, or quote the full binder |
| `tableauFuel := 1000` | source has `(tableauFuel : Nat := 1000)` | whitelist, or quote the full binder |
| `Atom ⟨"p", none⟩` | source has the bare `⟨"p", none⟩` | write `⟨"p", none⟩` and name `Atom` separately |
| `F.TaskRel := TaskFrame.reflect F.PosRel` | source spells it `FrameOver.TaskRel := TaskFrame.reflect PosRel` | use the source spelling |
| `Base ≤ ZTime` | source writes `FrameClass.Base ≤ FrameClass.RTime` in its regression `example`s | write the qualified form |

So at most two genuine whitelist additions are needed (the two default-argument spans), and both are "generic syntax illustrations" under the dispatch's allowance. Add them under a new category comment such as `# --- Optional-parameter illustrations (source spells the full binder) ---`.

### Tooling: what Check 2 does and does not police

`typst-sync-check.sh` Check 2 regenerates `status.typ` live (via `typst-status-counts.sh --json`, which is build-free) and diffs it against the committed file — but only over a hard-coded list of eight scalar fields plus the `sorry-table` rows. Any new `#let` binding added to `status.typ` is **not** compared, so a stale line count or version pin would sit in the book indefinitely with the sync check green.

Two consequences for item (10):

1. The generator's `--json` branch must emit the new figures too, because `--json` is what Check 2 consumes and it must run without a build. The new figures are all filesystem and git reads, so this is compatible.
2. Check 2's `scalar_fields` list and `live_map` dict (`scripts/typst-sync-check.sh:213-226`) must gain the same keys in the same commit. Omitting this is the single most likely way for this task to ship a silently-rotting number.

`typst-module-map.sh` already computes per-file line counts and a total, but only over `FormalSystem/Automation/{Tactics,ProofSearch}/*.lean` plus `SuccessPatterns.lean`. It is a usable template for the counting loop, not a source for repository-wide figures.

### Baseline gate state

All green before any edit, so a post-change failure is attributable.

| Gate | Result |
|---|---|
| `typst compile --root .. BimodalReference.typ` | exit 0; two pre-existing `unknown font family: new computer modern sans` warnings from `thmbox` (task 648 item 9b owns these) |
| `scripts/typst-sync-check.sh` | PASS, 3/3 checks; Check 1 scanned 685 backtick candidates with 0 violations |
| `.claude/scripts/typst-element-lint.sh` on the appendix | PASS, 0 remarks |
| `grep ';'` on the appendix | one hit, line 285, the permitted `apply DerivationTree.axiom; refine ?_` |
| Rendered extent | appendix occupies pages 88-98 of 107 |

## Decisions

- **Quote `FormalSystem.Metalogic.Conservativity.plusDerivable_ofFormula_iff`**, not the dispatch's `...Conservativity.Plus.plusDerivable_ofFormula_iff`, which does not elaborate.
- **Write `contraposition` qualified** wherever item (4) mentions it, because two live declarations share the short name.
- **Include `PlusLanguage` in the import-layer list** for item (10), following `FormalSystem/README.md`'s own Layer 0, rather than the dispatch's six-directory list.
- **Prefer source spellings over whitelist entries** for the four avoidable spans above; add only the two default-argument spans to `typst/sync-check-whitelist.txt`.
- **Extend `typst-status-counts.sh` and `typst-sync-check.sh` Check 2 in the same change**, so no new figure can drift.
- **Do not rename the appendix title.** Task 648 item (1) owns the "Appendix A" decision and explicitly reserves that edit; keeping `<lean-appendix>` and every `lean-appendix-*` label stable is a hard constraint here.
- **Correct the `SYNC-MAP.md` entry fully while updating it.** The dispatch requires updating the dated appendix entry anyway, and that same entry is what task 648 item (2) flags for its stale "byte-exact" claim and its now-archived scratch-file path. Doing it once here is cheaper than doing it twice and removes an overlap.
- **Do not touch `p2-decidability-practice.typ`.** Its `DecisionResult` description is stale (it says `valid`/`invalid`/`timeout`; live source has four constructors), but task 648 item (4) already owns that fix, and this task's file scope is the appendix.

## Recommendations

Ordered by dependency, and sized so each is one agent run.

- **R1 — Section arc first, prose second.** Adopt a twelve-section arc that threads the new material in dependency order rather than appending it. Proposed, with existing labels unchanged and new ones marked *new*:

  1. `lean-appendix-what-is-lean` — unchanged.
  2. `lean-appendix-types-props` — unchanged.
  3. `lean-appendix-props-as-types` — unchanged.
  4. `lean-appendix-inductive` — unchanged (`Formula`, `DerivationTree`).
  5. `lean-appendix-structures` — extended: keep `Atom` and `TaskModel`, then add the binder triple (explicit `( )`, implicit `{ }`, instance `[ ]`) once, then instance-bracket **fields** and the `CoeSort` coercion on `TemporalOrder`, then `FrameOver` and `TaskFrame` with the `F.Duration` / `F.WorldState` / `F.TaskRel` accessors and the reflection convention.
  6. `lean-appendix-dependent-fields` *(new)* — dependent fields, subtypes, predicate-versus-structure: `PartialHistory`, `IsConvex`/`IsTotal`, `WorldHistory` and `.val`/`.property`, `WorldHistory.state`, the `TaskModel` valuation reading.
  7. `lean-appendix-recursion` *(new)* — definition by structural recursion: `TruthAt` clause by clause beside the `Formula` constructors, then `PlusFormula.stab` and the one added `PlusTruthAt` clause.
  8. `lean-appendix-tactics` — unchanged.
  9. `lean-appendix-derived-theorem` *(new)* — `perpetuity2` as a worked `def`, reusing `perpetuity1` and `Perpetuity.contraposition`, then the MF instance closed by `modal_search`.
  10. `lean-appendix-semantic-counterpart` *(new)* — `timeShift_preserves_truth` from `truthAt_of_truthCorr` at `shiftCorr`, `modal_future_valid`, and the soundness remark.
  11. `lean-appendix-derivations-as-data` *(new)* — `DerivationTree.lift`, the `FrameClass` order, `height`, and why derivations being data is load-bearing.
  12. `lean-appendix-conventions` — unchanged.
  13. `lean-appendix-lake` — extended with the import-layer order, the four proof systems and their directories, the version pins, and the scale figures.
  14. `lean-appendix-reading-source` — extended: directory tour (updated), the two worked statements (kept), a new metalogic result map as one table per frame class, a new decision-procedure subsection, and the extended Trust-Reading Practice carrying "a name is not a proof".

  Note the ordinal count is fourteen sections rather than twelve once the two existing trailing sections are counted; the point is that five are new and three are extended in place.

- **R2 — Compile the snippet set before writing a line of prose.** Every didactic example in the report's Tactic Survey table is already verified; implementation should re-run them plus any new ones in one scratch file outside `FormalSystem/` and `Tests/`, and record the file's location in the implementation summary (not in the appendix, which must carry no `specs/` path).

- **R3 — Re-break every wide excerpt to 71 columns and diff it against source.** Fifteen of the thirty-six ledger rows exceed 71 columns at the source's own line breaking. The appendix's convention permits re-breaking; the check is that the token sequence is unchanged.

- **R4 — Write the metalogic map as one table per frame class**, with columns *statement*, *declaration*, *status*. Four tables of four rows each (soundness, weak completeness, compactness, strong completeness) is clearer than one sixteen-row table, and it makes the Base/Dense-versus-ZTime/RTime asymmetry visible at a glance: proved at Base and Dense, machine-checked refutations at ZTime and RTime.

- **R5 — State the refutations as theorems, with their witnesses.** The dispatch's framing is correct and load-bearing: `notCompactZTime` is a theorem with a `¬` in its statement, not an absence of a proof. Name the two distinct witnesses and say why `archWitness` does not port.

- **R6 — Extend `scripts/typst-status-counts.sh` and Check 2 together.** Add `lean-toolchain-pin`, `mathlib-tag`, `mathlib-rev`, `formalsystem-file-count`, `formalsystem-line-count`, `tests-file-count`, `tests-line-count`, `tools-file-count`, `tools-line-count` (names illustrative) to both the `--json` payload and the emitted `status.typ`, and add the same keys to `scripts/typst-sync-check.sh`'s `scalar_fields` and `live_map`. Keep the string-valued fields out of the integer-only comparison path or widen the comparison to strings. Do this as its own phase, verified by deliberately perturbing one figure and confirming Check 2 fails.

- **R7 — Phrase every open item durably and cite the book.** The decision procedure's open converse should read as a standing statement about what is proved and what is not, and point at `@sec:fmp-resolution` and `@sec:decidability-practice`, never as a dated progress note. The same applies to the TM⁻/TM forward direction if the project overview mentions it.

- **R8 — Correct the `SYNC-MAP.md` entry rather than appending to it.** Replace the "byte-exact" claim with the appendix's own stated policy (verbatim up to whitespace, docstrings omitted, lines re-broken), drop the archived scratch-file path, and describe the new coverage.

- **R9 — Inspect rendered pages with `pdftoppm`.** Both `pdftoppm` and `pdfinfo` are on `PATH`. With the appendix roughly doubling in length, the failure modes to look for are wrapped code lines (the 8pt/71-column budget), `#leansrc` labels orphaned from their blocks (the file-local `sticky: true` override should prevent this, but the new sections add many more call sites), and code blocks colliding with the paragraphs around them.

- **R10 — Plan for four to six phases.** A reasonable cut: (a) sections 5-7, the semantic layer; (b) sections 9-11, the theorem/transport/derivation triple; (c) section 14's metalogic map and decision procedure; (d) the generator and Check 2 extension; (e) section 13's project overview consuming (d); (f) render inspection, `SYNC-MAP.md`, and the gate sweep. Each lands with all four gates green.

## Risks & Mitigations

- **Risk: a new figure in `status.typ` goes stale silently.** Check 2 compares only the fields it names. *Mitigation*: R6, and verify by perturbation rather than by inspection.
- **Risk: the appendix outgrows its own formatting block.** The file-local 8pt/71-column budget and `breakable: false` on code blocks were tuned for eleven pages and roughly a dozen snippets; the new sections roughly triple the snippet count. *Mitigation*: R3 and R9, and keep every `#leansrc` call site call-compatible with the current two-argument signature so task 649's template-level environment can swap in later without touching call sites.
- **Risk: label churn breaks cross-references.** `00-introduction.typ` references `@lean-appendix`, and `ax-machine-appendix.typ` is referenced from the appendix's last line. *Mitigation*: keep `lean-appendix` and every existing `lean-appendix-*` label byte-identical; only add new ones.
- **Risk: a prose semicolon slips in.** Fifteen-plus new paragraphs of technical prose is where semicolons breed, and the constraint is absolute outside the one macro body. *Mitigation*: make `grep -n ';' typst/chapters/ax-lean-appendix.typ | grep -v 'apply DerivationTree.axiom'` returning empty a per-phase gate, not a final one.
- **Risk: overlap with task 648 produces a double edit.** Both tasks touch `typst/SYNC-MAP.md` and the whitelist. *Mitigation*: the Decisions above assign the `SYNC-MAP` appendix entry and the whitelist additions to this task, and leave the appendix title, `p2-decidability-practice.typ` and `template.typ` to 648 and 649.
- **Risk: quoting `Metalogic/Conservativity.lean` invites the forward-direction conflation.** That module's docstring is about TM⁻/TM and carries a do-not-attempt warning; TM⁺ conservativity is a different, four-class-complete result in `Conservativity/Plus.lean`. *Mitigation*: item (10)'s prose should name both files and say which result lives where.
- **Risk: a reader runs `#check` and sees a type the appendix did not prepare them for.** This is the existing defect item (1) exists to close, and the new sections multiply the exposure (`F.Duration.carrier` appears in every duration-indexed signature). *Mitigation*: introduce the coercion in section 5, before any signature that would print it.

## Tactic Survey Results

This is a documentation task over a `typst/` file, so there are no open proof goals and no tactic portfolio to run against a goal. The applicable survey is snippet verification: every didactic example the new sections would carry was elaborated against the live library with `lake env lean`, in scratch files outside `FormalSystem/` and `Tests/`. All compiled with zero errors.

| Goal | Tactic / form | Result | Premises/Config |
|---|---|---|---|
| `⊢ φ.box.imp φ.allFuture.box` (the MF instance) | `modal_search` | success | default depth and node budget |
| `⊢[fc] φ.sometimes.imp φ.diamond` | term: `Perpetuity.perpetuity2 φ` | success | implicit `fc` inferred |
| `⊢[FrameClass.Dense] φ` from `⊢ φ` | term: `DerivationTree.lift (by decide) d` | success | `by decide` discharges `Base ≤ Dense` |
| `FrameClass.Base ≤ FrameClass.Dense` | `decide` | success | `DecidableRel` instance at `Axioms.lean:557` |
| `FrameClass.Base ≤ FrameClass.ZTime` | `decide` | success | same |
| `FrameClass.Dense ≤ FrameClass.RTime` | `decide` | success | same |
| `¬ (FrameClass.ZTime ≤ FrameClass.Dense)` | `decide` | success | same |
| `ValidIn FrameClass.Base = Valid` | `rfl` | success | definitional, not a simp lemma |
| `τ.val.states t (τ.property t) = τ.state t` | `rfl` | success | `WorldHistory.state` is the definitional unfolding |
| `TruthAt M τ t φ.box ↔ ∀ σ, TruthAt M σ t φ` | `Iff.rfl` | success | the box clause is definitional |
| `Set F.WorldState` from a valuation | term: `{w | M.valuation w p}` | success | set-builder over the `Prop`-valued field |
| `DecisionResult φ` | term: `decide φ` | success | all three default arguments elided |
| `DecisionResult φ` | term: `decide φ 10 1000 .Base` | success | same call, arguments supplied |
| `F.Duration.carrier` from `(t : F.Duration)` | term: `t` | success | `CoeSort` coercion, no annotation needed |

Kernel audits, read with `#print axioms` and relevant to what the appendix claims:

| Declaration | Axioms |
|---|---|
| `Theorems.Perpetuity.perpetuity2` | `[propext]` |
| `Semantics.TimeShift.timeShift_preserves_truth` | `[propext, Quot.sound]` |
| `Metalogic.completeness_base` | `[propext, Classical.choice, Quot.sound]` |
| `Metalogic.strongCompletenessBase` | `[propext, Classical.choice, Quot.sound]` |
| `Metalogic.notCompactZTime` | `[propext, Classical.choice, Quot.sound]` |
| `Metalogic.notStrongCompletenessRTime` | `[propext, Classical.choice, Quot.sound]` |
| `Metalogic.Decidability.sound_of_isValid` | `[propext, Classical.choice, Quot.sound]` |

No `sorryAx` anywhere in the set. The two light footprints (`perpetuity2`, `timeShift_preserves_truth`) are worth showing in the appendix beside the three-axiom standard set already quoted at line 427, because they make the point that the audit reports what a proof actually used rather than a fixed preamble.

## Context Extension Recommendations

- **Topic**: `typst/generated/status.typ` as the single source for cited figures.
  **Gap**: no context file records that a number cited in `typst/` must come from the generator, nor that `typst-sync-check.sh` Check 2 polices only an explicitly named field list. Both facts are discoverable only by reading two scripts.
  **Recommendation**: add a short note to the Lean context index (`.claude/context/project/lean4/`) or a `typst/README.md` section stating the generator-plus-Check-2 pairing rule: a new `#let` in `status.typ` without a matching `scalar_fields` entry is a silent-drift bug.

- **Topic**: `#leansrc` excerpt policy.
  **Gap**: the policy (verbatim up to whitespace, docstrings omitted, lines re-broken to 71 columns) lives only in the appendix's own file header, while `typst/SYNC-MAP.md` still describes an older "byte-exact" policy.
  **Recommendation**: state the policy once in `typst/README.md` and have both the appendix header and `SYNC-MAP.md` point at it. R8 removes the contradiction for this file; a shared statement prevents the next one.

## Appendix

### Probe files used

Five scratch files under the session scratchpad, each run with `lake env lean` from the repository root:

- `probe1.lean` — `#check @FormalSystem.Metalogic.soundness`, establishing that the elaborated type prints `F.Duration.carrier`.
- `probe2.lean` — eighteen `#check`s and six `example`s across items (1), (2), (4), (5), (6), (7), (9).
- `probe3.lean` — seven `#print axioms` calls plus the `PlusTruthAt` and `soundness_rtime` signatures; this is where `Conservativity.Plus.plusDerivable_ofFormula_iff` failed to resolve.
- `probe4.lean` — the completeness-family relationships, including `example : ValidIn FrameClass.Base = Valid := rfl`.
- `probe5.lean` — the twenty candidate didactic snippets of the Tactic Survey table, compiled as one file with zero errors.

### Resolution test method

Check 1's rule was reproduced directly rather than inferred: `grep -rqF --include=*.lean --exclude-dir=Boneyard -- "$span" FormalSystem BimodalTools`, matching `scripts/typst-sync-check.sh`'s `grep_lean` and its `LEAN_SRC_ROOTS` (line 46). Sixty-nine spans were tested in two batches, single identifiers and multi-word spans separately, since Check 1 treats them differently.

### Cross-reference targets available to the new sections

`@sec:truth`, `@sec:convex-histories` (`02-semantics.typ`); `@sec:frame-classes`, `@sec:conservative-extension` (`p2-frame-classes.typ`); `@sec:metalogic`, `@sec:completeness-theorems`, `@sec:dichotomy` (`04-metalogic.typ`); `@sec:decidability-practice`, `@sec:fmp-resolution` (`p2-decidability-practice.typ`); `@sec:perpetuity` (`05-theorems.typ`); plus `@sec:formulas`, `@sec:proof-theory`, `@sec:proof-automation`, `@sec:dataset-pipeline`, `@sec:decidability-frontier`, `@ch:vlach-blstar` already used by the file today.

### External references

- Theorem Proving in Lean 4, the Lean 4 documentation, and the Mathlib4 docs are already linked from the appendix's `lean-appendix-lake` section; no new external reference is needed for any of the ten items.
