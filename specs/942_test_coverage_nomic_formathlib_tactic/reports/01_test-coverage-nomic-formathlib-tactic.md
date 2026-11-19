# Research Report: Task #942

**Task**: 942 - Add regression test coverage for three FormalSystem module groups that currently have none
**Started**: 2026-11-19T12:46:00-08:00
**Completed**: 2026-11-19T13:18:00-08:00
**Effort**: Research ~35 min; implementation estimate 2 phases (A: ~1.5h, B+C: ~1h)
**Dependencies**: None (territory overlap with open task 177 on `TacticsTest.lean` — avoided outright, see Decisions)
**Sources/Inputs**:
- Codebase (`FormalSystem/NomicLanguage/`, `FormalSystem/ForMathlib/`, `FormalSystem/Tactic/`, `Tests/BimodalTest/`, `lakefile.toml`, `scripts/check-module-invariants.sh`, `scripts/warning-budget.txt`, `scripts/c16-roots-baseline.txt`)
- `specs/reviews/review-2026-11-19.md` (source of record)
- lean-lsp MCP (`lean_run_code`, index `consulted` tier — compiled probes, not grep-only)
- No Mathlib search tool was needed: every candidate declaration is local

**Artifacts**:
- `specs/942_test_coverage_nomic_formathlib_tactic/reports/01_test-coverage-nomic-formathlib-tactic.md`

**Standards**: report-format.md, subagent-return.md

## Executive Summary

- **The gap is confirmed and the grep is clean.** Zero files under `Tests/` reference
  `NomicLanguage`, `NomicFormula`, `NomicValidity`, `NomicTruth`, `ForMathlib`, `BallSpace`,
  `PFilter`, `SimpleGraphAcyclic`, `InfiniteRamseyPairs` or `Sierpinski`. The single hit for
  `FormalSystem.Tactic` is prose in a comment (`NormalizationTest.lean:235`).
- **Both of the task description's suggested alternatives for (A) are structurally unavailable.**
  `ValidityLayerTest.lean` pins defeq against the generic `PointTruth`/`TaskFrame` validity layer,
  and `NomicTruth.lean`'s own docstring records why the nomic point `(τ : ↑D → F.World, x : ↑D)`
  over a `NomicFrame D` **cannot** instantiate that layer. `LanguageDerivationTest.lean` exercises
  proof systems, and `NomicLanguage` is a semantic-only component with no proof system. A new
  module is the only route for (A).
- **(C) is narrower than the review states, and probing it uncovered a live bug.**
  `NormalizationTest.lean` already exercises `formula_unfold`/`formula_fold` and
  `LemmaDBTest.lean` already reads `` Lean.labelled `tmLemma ``, so 3 of `Tactic/Attr.lean`'s 5
  declarations are covered already. Writing the probe for `Tactic/Meta.lean` found that
  **`buildContextExpr` throws unconditionally** (`mkAppM `` `List.nil `` with an explicit type
  argument), which hard-fails `modal_search` on any `□`-headed goal. The fix touches a
  `FormalSystem` declaration, which this task puts explicitly out of scope — flagged as a
  `user_decision`.
- **Recommended approach, all four pieces compiled green before being written down**:
  one new module `Tests/BimodalTest/Semantics/NomicLanguageTest.lean` for (A); one new module
  `Tests/BimodalTest/ForMathlib/SmokeTest.lean` for (B); two small folds into
  `NormalizationTest.lean` and `LemmaDBTest.lean` for (C) — neither needing a new import.
- **Two gates will bite a careless implementation**: C6 (a test module absent from
  `Tests/BimodalTest.lean` is an unreachable-module failure) and C16's `docBlame` ceiling (a new
  module has no baseline row, so *any* undocumented public declaration in it raises the count
  above zero and fails).

## Context & Scope

Researched: what shape of regression test the three untested module groups actually admit, where
each one belongs in the existing test tree, and which repository gates a new or extended test
module must satisfy.

Constraints honoured: no `FormalSystem` declaration, signature, import or proof was changed; no
coverage was raised on modules that already have tests; the 360 `sorry` occurrences were not
touched. The `buildContextExpr` defect was *measured*, not repaired.

## Findings

### Codebase Patterns

**The confirmed gap (grep over the whole test tree).**

| Identifier swept | Hits under `Tests/` |
|---|---|
| `NomicLanguage`, `NomicFormula`, `NomicValidity`, `NomicTruth` | 0 |
| `ForMathlib`, `BallSpace`, `PFilter`, `SimpleGraphAcyclic`, `InfiniteRamseyPairs`, `Sierpinski` | 0 |
| `FormalSystem.Tactic` | 1, prose only (`NormalizationTest.lean:235`) |
| `formula_unfold` / `formula_fold` (declared in `Tactic/Attr.lean`) | ~14 live tactic invocations in `NormalizationTest.lean` |
| `` `tmLemma `` (declared in `Tactic/Attr.lean`) | 1 live `Lean.labelled` read in `LemmaDBTest.lean` |
| `truth_norm`, `reflect_time_norm` (declared in `Tactic/Attr.lean`) | 0 |
| `extractDerivationGoal`, `formulaHead`, `lemmaConclusionHead`, `isNilContext`, `buildContextExpr` (`Tactic/Meta.lean`) | 0 |

**Per-language test pattern.** There is no `Tests/BimodalTest/{Language}/` directory. Every
language-variant test lives under `Tests/BimodalTest/Semantics/` or `Tests/BimodalTest/Syntax/`,
in one of two shapes:

1. `ValidityLayerTest.lean` — `example ... := rfl` defeq pins per language against the generic
   validity layer, plus a toy fifth language exercising the extension contract. Covers L, L⁻, L⁺,
   L⋆, L^▷, L^hybrid, L^quant. **NomicLanguage is the one absent language, and absent for a
   structural reason, not an oversight** (see Decisions).
2. `OpenLanguageAxiomTest.lean` / `HybridLanguageAxiomTest.lean` / `QuantLanguageAxiomTest.lean` —
   `#guard_msgs`-gated `#print axioms` blocks for the component's headline theorems, build-breaking
   if a profile moves. This is the precedent for a *semantic-only* language component, and
   `NomicLanguage` is semantic-only in exactly `OpenLanguage`'s sense (its aggregator docstring
   says so: "no proof system, no axiomatisation, no soundness or completeness claim").

**`NomicLanguage` surface available to a test.** `NomicFormula` (7 constructors, `DecidableEq`,
`Countable`, 12 derived operators, `ofFormula` + `ofFormula_injective`); `NomicModel`,
`NomicTruthAt` and 16 clause lemmas; `TenseFree`, `nomicSatSet`, `tenseFree_satSet_iff` and five
S5 schemata on the fragment; `NomicFrame.NomicValidOn`, `nomic_serial`,
`nomicValidOn_nomic_iff_box_of_uniform`; `four_validOn_iff_uniform`,
`nomic_iff_box_validOn_iff_uniform`, `not_four_nomicValid`. Concrete witness frames `F1`/`F2`/`F3`
over `intOrder` with finite carriers `W3`/`W3e` already exist in
`FormalSystem/Semantics/Nomic/Witnesses.lean`, so a test can build a real `NomicModel` and
evaluate truth at it. `F3.IsRegular` does **not** synthesize (`F3` is a plain `def`, so the
instance head is not syntactically `ofStepFamily …`); it must be bound with
`haveI : F3.IsRegular := NomicFrame.ofStepFamily_isRegular R3 R3.fwd R3.bwd`, exactly as
`NomicFour.lean` does.

**`ForMathlib` is exercised only transitively today.** Seven `FormalSystem` modules import a
`ForMathlib` file (`Semantics/TaskFrame.lean` → `BallSpace`, `Semantics/ConeUnravelling.lean` and
`Semantics/UniversalCover.lean` → `SimpleGraphAcyclic`, `Metalogic/Algebraic/UltrafilterMCS.lean`
→ `PFilter`, two `WeakCanonical` modules → `InfiniteRamseyPairs`,
`Semantics/Correspondence/RigidityReal.lean` → `Sierpinski`), so the declarations compile under
existing tests. What is missing — and what matters for an upstream PR — is a check that reaches
them *in isolation*, importing only `FormalSystem.ForMathlib`.

**`Tactic/Meta.lean` consumers.** `extractDerivationGoal` (4 call sites), `isNilContext` (3),
`formulaHead` (1), `lemmaConclusionHead` (1), `buildContextExpr` (2 — `Search.lean:475`
`tryModalK`, `Search.lean:527` `tryTemporalK`, both **outside** their `observing?` block, so an
exception propagates rather than being swallowed).

### Repository gates a new/extended test module must satisfy

| Gate | Obligation | Source |
|---|---|---|
| **C6** (unreachable-module rot guard) | Every new test module MUST be added to `Tests/BimodalTest.lean`. That file states "Every test module under `Tests/BimodalTest/` is imported above; none is excluded", and `scripts/module-invariants-manifest.txt` (the only alternative) is empty. | `scripts/check-module-invariants.sh`, `Tests/BimodalTest.lean` |
| **C16** second half (`docBlame` ceiling) | A new module has **no baseline row**, so its ceiling is 0. Give every new public declaration a docstring (or make it `private`). Also avoid `_` in declaration names (`defsWithUnderscore`) and tautological statements (`synTaut`). | `scripts/c16-roots-baseline.txt` ("Baseline total: 231 finding(s) across 15 root(s)"; 19 `BimodalTest` rows) |
| **C28** (warning budget) | "Baseline total: 0 warning(s) across 0 file(s)" — the tree is at a **zero warning budget**. `linter.hashCommand` is already off for the `BimodalTest` library via `lakefile.toml`; `linter.style.longLine` (100 chars) and the rest are blocking. | `scripts/warning-budget.txt`, `lakefile.toml` |
| Copyright header | Every file under `Tests/` carries the four-line Apache header; the checker is clean under `--strict Tests` today. | `scripts/check-copyright-headers.sh` |
| C9 / `no-task-references-in-deliverables` | No task-number citations in `.lean` files. | repo rules |
| **Not** a gate here | `Tests/BimodalTest.lean` is hand-maintained (unlike `FormalSystem.lean`, which C33 holds byte-current against a generator), so editing its import list by hand is correct. C14's axiom pins are a hardcoded headline set; a test's own `#print axioms` pins need no registration. | `scripts/check-module-invariants.sh` |

Measured detail on `longLine`: the existing `*AxiomTest.lean` files carry `/-- info: … -/`
expected-output lines of 104–133 characters and the warning budget is still zero, and my own
compiled drafts reproduced that (no `longLine` warning on any `/-- info: … -/` line, only on my
own over-long code lines). The `#guard_msgs` docstring shape is therefore safe as-is; ordinary
code lines must still be reflowed to 100.

### External Resources

None required. Every declaration named in this report is local to this repository; no Mathlib
search tool (leansearch / loogle / leanfinder / state_search) was consulted, because no new
Mathlib lemma is needed — all four recommended artifacts are built from declarations already in
the tree, and all four were compiled rather than guessed.

### Recommendations

Every recommendation below names a concrete artifact, and the Lean compiler is the gate that
decides whether that artifact is accepted, so each was run through `lean_run_code` against the
current tree **before** being written here.

- **(A) Add one new module `Tests/BimodalTest/Semantics/NomicLanguageTest.lean`** with four
  sections — syntax (`DecidableEq` `#guard`s, `ofFormula` pins, `ofFormula_injective` use), truth
  clauses (`NomicTruth.nomic_iff` / `box_iff` / `always_iff` / `diamond_iff` applied at an
  arbitrary `NomicFrame D`), a concrete-frame section (a `NomicModel F3` valuation, `nomic_serial`
  at `F3` under a `haveI` regularity instance, and axiom 4's failure at `F3` via
  `four_validOn_iff_uniform` + `F3.not_uniform`), and `#guard_msgs`-gated `#print axioms` profile
  pins for seven headline declarations. Place it under `Semantics/` beside
  `OpenLanguageAxiomTest.lean`, not in a new `Tests/BimodalTest/NomicLanguage/` directory — the
  tree has no per-language test directory, and the task asks to follow the existing pattern.
  [VERIFIED: PASS — the complete ~115-line draft compiled via `lean_run_code` with **zero
  errors**; the only diagnostics were three `linter.hashCommand` warnings on `#guard`, which the
  `BimodalTest` library suppresses by `weak.linter.hashCommand = false` in `lakefile.toml`. All
  seven `#guard_msgs` expected strings matched exactly — a mismatch is a compile error, so the
  pins are measured, not predicted.]

- **(A, measured input to the above) The seven axiom profiles to pin**, each `#print axioms`-measured
  on this toolchain:
  | Declaration | Profile |
  |---|---|
  | `FormalSystem.NomicLanguage.ofFormula_injective` | `[propext]` |
  | `FormalSystem.NomicLanguage.nomic_iff_box_of_uniform` | `[propext]` |
  | `FormalSystem.Semantics.nomicValidOn_nomic_iff_box_of_uniform` | `[propext]` |
  | `FormalSystem.Semantics.nomic_serial` | `[propext, Classical.choice, Quot.sound]` |
  | `FormalSystem.Semantics.four_validOn_iff_uniform` | `[propext, Classical.choice, Quot.sound]` |
  | `FormalSystem.Semantics.not_four_nomicValid` | `[propext, Classical.choice, Quot.sound]` |
  | `FormalSystem.NomicLanguage.tenseFree_satSet_iff` | `[propext, Classical.choice, Quot.sound]` |

  (`nomic_iff_box_validOn_iff_uniform` and `exists_refutation_of_not_uniform` also measure
  `[propext, Classical.choice, Quot.sound]` and may be pinned too.) These are worth pinning
  precisely because the modules' docstrings make the claims in prose — "choice-free … measures at
  `[propext]`" for `nomic_iff_box_of_uniform`, "a theorem of ZFC, not of ZF" for `nomic_serial` —
  and nothing in the tree checks them. [VERIFIED: PASS — all eleven profiles read directly off
  `#print axioms` via `lean_run_code`, and each docstring claim held.]

- **(B) Add one new module `Tests/BimodalTest/ForMathlib/SmokeTest.lean`** importing *only*
  `FormalSystem.ForMathlib`, with a `#check` per public declaration plus one minimal instantiating
  `example` per file: `Order.IsNest {Set.univ}` and `IsNest.exists_subset_inter` (BallSpace);
  `Order.PFilter.isProper_iff_bot_notMem` and `Order.PrimeFilter.mem_iff` (PFilter);
  `(⊥ : SimpleGraph ℕ).IsAcyclic` via `isAcyclic_of_rank_parent` with `rk = 0`, `par = id`
  (SimpleGraphAcyclic); `Nat.exists_strictMono_const_pair_colour` at `C := Bool`
  (InfiniteRamseyPairs); `Sierpinski.isOpen_locallyConstantLocus` and `const_of_countable_range` on
  a constant `ℝ → Bool` (Sierpinski). The isolated import is the whole point — it is what makes the
  check an upstream-PR artifact rather than an incidental by-product of the seven existing
  `FormalSystem` consumers. A single ~70-line module is the *lightweight* reading of the review's
  "a `#check`/`example` smoke test per file"; the over-built version it warns against would be one
  module per file. [VERIFIED: PASS — compiled via `lean_run_code`. First attempt surfaced two
  defects in my own draft (an `unnecessarySimpa` warning and a "No goals to be solved" in the
  Sierpinski level-set closedness proof); the corrected forms recorded above compiled with **zero
  diagnostics**.]

- **(C.1) Fold the two missing `Tactic/Attr.lean` simp-set checks into
  `Tests/BimodalTest/Automation/NormalizationTest.lean`** (545 lines), which is already the home of
  the `formula_unfold`/`formula_fold` checks and already names `FormalSystem/Tactic/Attr.lean` in
  its prose. Two `example`s suffice: a `TruthAt M τ t φ.neg ↔ ¬ TruthAt M τ t φ` goal closed by
  `simp only [truth_norm]`, and `(φ.neg).reflectTime = (φ.reflectTime).neg` closed by
  `simp only [reflect_time_norm]`. **No new import is required.** [VERIFIED: PASS — both `example`s
  compiled under `NormalizationTest.lean`'s exact two-import closure
  (`FormalSystem.Automation.Normalization` + `FormalSystem.Metalogic.Decidability.DecisionProcedure`)
  with zero diagnostics.]

- **(C.2) Fold the `Tactic/Meta.lean` usage probe into
  `Tests/BimodalTest/Automation/LemmaDBTest.lean`** (223 lines) rather than `TacticsTest.lean`:
  `LemmaDBTest.lean` already runs a `#eval show CoreM Unit from do` metaprogramming probe, its own
  header records that it exists precisely to stay out of `TacticsTest.lean`, and keeping out of
  `TacticsTest.lean` also keeps this task disjoint from open task 177's prose-only edits there. The
  probe: `#check` all five helpers, then one `TermElabM` block that elaborates
  `DerivationTree FrameClass.Base ([] : Context) (p.imp p)`, asserts `extractDerivationGoal`
  recognises it, `isNilContext` accepts its context, `formulaHead` reads `Formula.imp`, and
  `lemmaConclusionHead` reads `Formula.imp` off the `@[tmLemma]`-tagged
  `FormalSystem.Theorems.ModalS5.tBoxToDiamond`; plus a negative `MetaM` block asserting
  `extractDerivationGoal` and `isNilContext` both reject `mkConst ``Nat`. **No new import is
  required.** [VERIFIED: PASS — compiled under `LemmaDBTest.lean`'s exact single import
  (`FormalSystem.Automation.Tactics.Commands`) with zero diagnostics.]

- **(C.3) Do NOT assert anything about `buildContextExpr` beyond its `#check`** while the defect
  below is unresolved; a test that invokes it cannot pass, and a test written to expect the throw
  would launder the bug. [VERIFIED: FAIL — `buildContextExpr` throws on every input, so the
  natural round-trip assertion (`isNilContext (← buildContextExpr [])`) cannot be landed; revised
  to: `#check @buildContextExpr` only, with an in-file comment pointing at the defect, and the
  repair raised to the user as a scope question (see Decisions / Risks).]

- **(Both new modules) Add the import line to `Tests/BimodalTest.lean` in the same change** —
  `BimodalTest.Semantics.NomicLanguageTest` beside the other `Semantics.*` entries and
  `BimodalTest.ForMathlib.SmokeTest` as a new group. Omitting it is a C6 failure, not a cosmetic
  miss. [No compiled gate applicable — this is an import-list edit whose gate (C6) runs over the
  whole tree, not over a candidate artifact.]

- **(Both new modules) Docstring every new public declaration** (e.g. the `NomicModel F3`
  valuation and any atom abbreviations), because C16's `docBlame` ceiling for a module with no
  baseline row is zero. [No compiled gate applicable — `docBlame` is an `env_linter` sweep over
  built roots, not a predicate over a candidate artifact.]

## Decisions

- **(A) gets a new module; neither suggested extension point is usable.**
  `ValidityLayerTest.lean` pins `TaskFrame.XValidOn F φ = TaskFrame.GenericValidOn F φ` by `rfl`
  for each language. `NomicFrame.NomicValidOn` is defined over `NomicFrame D` with evaluation point
  `(τ : ↑D → F.World, x : ↑D)` and a box clause quantifying `∀ σ ∈ F.HF`; `NomicTruth.lean`'s
  "Why the clause layer is duplicated rather than instantiated" section records that `TruthEnv.T`'s
  `WorldHistory F` binder "cannot be met at all" for a non-uniform nomic frame. So the defeq those
  tests pin does not exist to be pinned. `LanguageDerivationTest.lean` builds `DerivationTree`
  terms in TM⁻/TM⁺/TM⋆; `NomicLanguage` has no proof system. New module it is.
- **(A) is placed under `Semantics/`, not in `Tests/BimodalTest/NomicLanguage/`.** The review
  suggested the latter; the tree has no per-language test directory at all, and the task asks to
  follow the existing pattern rather than invent a shape.
- **(C) is scoped to the genuinely-uncovered declarations**, not to all of `Tactic/`. Three of
  `Attr.lean`'s five declarations are already exercised; re-covering them would be the
  "raising coverage of modules that already have tests" the task excludes.
- **(C) hosts in `LemmaDBTest.lean` + `NormalizationTest.lean`, deliberately avoiding
  `TacticsTest.lean`.** The territory note allows disjoint edits there, but avoiding the file
  entirely removes the collision risk at no cost, and `LemmaDBTest.lean`'s own header records that
  metaprogramming probes were moved out of `TacticsTest.lean` on purpose.
- **The `buildContextExpr` defect is reported, not repaired.** Repairing it edits a `FormalSystem`
  declaration, which the task description places explicitly out of scope. Research cannot settle
  whether a one-line live-bug fix is in the spirit of that exclusion — that is a scope judgement
  for the user, so it is raised as a `user_decision` rather than decided here.

## Risks & Mitigations

- **Risk: `buildContextExpr` is dead-on-arrival and `modal_search` is broken on boxed goals.**
  Measured: `buildContextExpr`'s first statement is `mkAppM `` `List.nil `` #[formulaType]`, but
  `List.nil`'s type argument is implicit, so `mkAppM` raises
  `too many explicit arguments provided to @List.nil` on **every** call, including the empty list.
  Both consumers call it outside their `observing?` block, so
  `example : ⊢[FrameClass.Base] □(p → p) := by modal_search` fails with exactly that error.
  *Mitigation*: land (C) without invoking `buildContextExpr` (recommendation C.3), and raise the
  repair separately. Two repairs were compiled and both work, so the follow-up is cheap and
  pre-validated: `mkAppOptM `` `List.nil `` #[some formulaType]`, or
  `Lean.mkApp (Lean.mkConst `` `List.nil `` [Level.zero]) formulaType`. Both produce
  `[] : List Formula` and are accepted by `isNilContext`; the non-empty case round-trips too.
- **Risk: C6 failure from forgetting the `Tests/BimodalTest.lean` import.** *Mitigation*: treat the
  import-list edit as part of the same objective as the file creation, and run
  `bash scripts/check-module-invariants.sh --no-build` (which still runs C6's reachability half)
  before the phase-closing build.
- **Risk: C16 `docBlame` rise from an undocumented declaration in a new module.** *Mitigation*:
  docstring or `private` every new declaration; the ceiling for a module with no baseline row is 0.
- **Risk: an axiom profile drifts and the `#guard_msgs` block goes red.** This is the intended
  behaviour, and `OpenLanguageAxiomTest.lean`'s "When one of these guards fires" section already
  states the policy: update the expected block in the same commit as the change that moved it,
  never re-baseline on its own to turn a red build green. *Mitigation*: carry the same paragraph in
  the new module's docstring.
- **Risk: the zero warning budget turns a style slip into a gate failure.** *Mitigation*: keep
  code lines ≤ 100 chars (the `/-- info: … -/` expected-output exemption does not extend to code),
  and run the guarded build rather than bare `lake`:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest`.

## Tactic Survey Results

The tactic-discovery survey was run only where this task's artifacts actually needed a tactic;
nothing here is a proof-search problem, so the portfolio sweep (`aesop`/`omega`/`decide`/
`linarith`) was not applicable to most goals.

| Goal | Tactic | Result | Premises/Config |
|---|---|---|---|
| `TruthAt M τ t φ.neg ↔ ¬ TruthAt M τ t φ` | `simp only [truth_norm]` | success | the `truth_norm` set alone, no extra premises |
| `(φ.neg).reflectTime = (φ.reflectTime).neg` | `simp only [reflect_time_norm]` | success | the `reflect_time_norm` set alone |
| `Order.IsNest ({Set.univ} : Set (Set ℕ))` | `⟨⟨Set.univ, rfl⟩, by simp [IsChain, Set.Pairwise]⟩` | success | `IsChain`, `Set.Pairwise` |
| `(⊥ : SimpleGraph ℕ).Adj u v → _` (vacuous branch) | `absurd h (by simp)` | success | default simp set |
| `IsClosed (Sierpinski.levelSet (fun _ => c) a)`, `a = c` branch | `simp [Sierpinski.levelSet]` | success | unfolds to `IsClosed univ` |
| same, `a ≠ c` branch | `simp [Sierpinski.levelSet, Ne.symm hac]` | success | `simpa`/explicit `isClosed_empty` were **rejected** — "No goals to be solved" / `unnecessarySimpa` |
| `NomicTruth.*_iff` applications | direct term (`NomicTruth.nomic_iff M τ x φ`) | success | no tactic needed; the lemmas are `Iff.rfl`-shaped |
| `¬ TenseFree (NomicFormula.someFuture (.atom p))` | `intro h; cases h` | success | `TenseFree` has no constructor at `untl` |

`lean_hammer_premise` and `lean_state_search` were not used: no goal in this task is an open proof
obligation — every goal is either discharged by a named local lemma or by a one-line simp set.
Recursive decomposition (the APOLLO pattern) was not applicable for the same reason.

## Context Extension Recommendations

- **Topic**: The per-test-module gate checklist for this repository.
- **Gap**: Nothing in `context/project/lean4/` records that adding a test module under `Tests/`
  carries three non-obvious obligations — the `Tests/BimodalTest.lean` import (C6), the zero
  `docBlame` ceiling for a module with no `c16-roots-baseline.txt` row, and the zero warning
  budget with its `/-- info: … -/` `longLine` exemption. Each was discovered here by reading the
  gate scripts, and each is the kind of thing an implementation dispatch would otherwise discover
  as a red gate at phase end.
- **Recommendation**: Add `context/project/lean4/patterns/test-module-gate-checklist.md` capturing
  the table in "Repository gates a new/extended test module must satisfy" above, cross-referenced
  from `context/project/lean4/patterns/plan-authoring-gate-collisions.md`.

- **Topic**: Metaprogramming helpers are invisible to the build.
- **Gap**: `buildContextExpr` has been throwing on every call while compiling cleanly, because a
  `MetaM` helper's failure is a *runtime* failure of the elaborator, never a compile error. No
  existing context file warns that the "it builds, so it works" heuristic does not extend to
  `MetaM`/`TacticM` code, and that such code needs an executed `#eval` probe to be covered at all.
- **Recommendation**: Add a short section to
  `context/project/lean4/tools/mcp-tools-guide.md` (or a new
  `patterns/metaprogramming-coverage.md`) recording that metaprogramming helpers require an
  executed probe, with this `buildContextExpr` case as the worked example.

## Appendix

### Search queries and probes used

Grep sweeps (repository-local, no external search tool):
- `NomicLanguage|NomicFormula|NomicValidity|NomicTruth` over `Tests/`
- `ForMathlib|BallSpace|PFilter|SimpleGraphAcyclic|InfiniteRamseyPairs|Sierpinski` over `Tests/`
- `FormalSystem.Tactic`, `truth_norm|reflect_time_norm|formula_unfold|formula_fold|tmLemma` over `Tests/`
- `extractDerivationGoal|formulaHead|lemmaConclusionHead|isNilContext|buildContextExpr` over `FormalSystem/` and `Tests/`
- `import FormalSystem.ForMathlib` over `FormalSystem/`
- `awk 'length>100'` over the existing `*AxiomTest.lean` files (the `longLine` exemption measurement)

Compiled probes (`lean_run_code`, 9 runs):
1. `#print axioms` on 11 `NomicLanguage` declarations — all profiles recorded above.
2. The full ~115-line `NomicLanguageTest.lean` draft — zero errors.
3. The `ForMathlib` smoke draft, first attempt — 2 defects in my own draft, found and fixed.
4. The corrected `ForMathlib` fragments — zero diagnostics.
5. The `Tactic` smoke draft, first attempt — `Context` ambiguity under `open Lean Meta Elab Term`.
6. The `buildContextExpr` failure probe — throws on `[]` and on `[p]`; `modal_search` on a boxed
   goal fails with the same `AppBuilder` error.
7. Two candidate repairs for `buildContextExpr` — both produce `[] : List Formula` and round-trip.
8. Host-closure check A — the two `Attr.lean` examples under `NormalizationTest.lean`'s imports.
9. Host-closure check B — the `Meta.lean` probe under `LemmaDBTest.lean`'s single import.

### References

- `specs/reviews/review-2026-11-19.md` — source of record for the three findings
- `FormalSystem/NomicLanguage/README.md` and the five module docstrings — the component's recorded
  exclusions and choice-dependence claims
- `FormalSystem/NomicLanguage/NomicTruth.lean`, "Why the clause layer is duplicated rather than
  instantiated" — why `ValidityLayerTest.lean` cannot host (A)
- `Tests/BimodalTest/Semantics/OpenLanguageAxiomTest.lean` — the semantic-only-component test
  precedent, including its guard-fired policy paragraph
- `Tests/BimodalTest/Semantics/ValidityLayerTest.lean` — the generic validity-layer defeq pins and
  the toy fifth language
- `Tests/BimodalTest/Automation/LemmaDBTest.lean` — the existing metaprogramming-probe shape
- `scripts/check-module-invariants.sh` (C6, C14, C16, C24, C28, C33), `scripts/warning-budget.txt`,
  `scripts/c16-roots-baseline.txt`, `lakefile.toml`
