# Implementation Summary: Deduction Theorem Tactic

- **Task**: 189 - Deduction theorem tactic
- **Plan**: specs/189_deduction_theorem_tactic/plans/02_deduction-tactic-plan.md
- **Status**: Implemented (all 3 phases complete)
- **Session**: sess_1784042334_6ccc8d
- **Date**: 2026-07-14

## What Was Built

### Phase 1: Core lemmas (Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean)

- `deduction_converse {fc} (Γ A B) : Γ ⊢[fc] A.imp B → (A :: Γ) ⊢[fc] B` —
  **computable** (plain `def`, no `noncomputable` marker): weakening + head
  assumption + modus ponens, exactly per the report-02 sketch.
- `Derivable.deduction {fc Γ A B} : Derivable fc (A :: Γ) B → Derivable fc Γ (A.imp B)` —
  Prop-level deduction theorem, declared as
  `theorem _root_.Bimodal.ProofSystem.Derivable.deduction` so dot notation
  (`h.deduction`) resolves against the `Derivable` type's namespace.
  Verified via `lean_verify`: axioms are only `propext`, `Classical.choice`,
  `Quot.sound`.
- Added `import Bimodal.ProofSystem.Derivable` to DeductionTheorem.lean
  (`Derivable` was not transitively imported; no import cycle — Derivable.lean
  depends only on ProofSystem/Syntax).

### Phase 2: Tactic file (Theories/Bimodal/Automation/Tactics/Deduction.lean, new, 146 lines)

- `runDeductionTactic : TacticM Unit` — copied from the `mkOperatorKTactic`
  template (Helpers.lean:311-329): 3-app goal match
  `.app (.app (.app (.const ``DerivationTree _) _fc) _ctx) _fml` used ONLY as a
  guard for the error message, then `goal.apply (mkConst ``Bimodal.Metalogic.Core.deduction_theorem)`
  + `replaceMainGoal`. Because `apply` unifies at default transparency, goals
  stated as `Γ ⊢[fc] ψ.neg` (defeq to `ψ.imp bot`) work with no call-site
  normalization — validated by in-file smoke test and Tests 5/6/8/10/15.
- `deduction` / `deduction n` — single `syntax "deduction" (num)? : tactic` +
  `elab_rules` looping `runDeductionTactic` n times (default 1). Ordering
  documented: `⊢ A → B → C` after `deduction 2` gives `B :: A :: Γ ⊢ C`.
- `undischarge h` — macro expanding to
  `exact Bimodal.Metalogic.Core.deduction_theorem _ _ _ h`.
- Error paths (confirmed via `lean_run_code`, exact-matched in `#guard_msgs` tests):
  - non-derivability goal: `deduction: goal must be a derivability goal `Γ ⊢[fc] A → B`, got {goalType}`
  - non-implication formula: `deduction: goal formula is not an implication (expected `Γ ⊢[fc] A → B`, got {goalType})`
- Wiring: 1 import line in Commands.lean (Automation.lean already roots
  Commands, so the tactic is reachable library-wide; no root-file change needed).

### Phase 3: Tests (Tests/BimodalTest/Automation/DeductionTest.lean, new, 17 tests)

- Basic (1-2), iterated with head-ordering proof (3-4), **negation defeq
  load-bearing** (5-6), frame-class polymorphism at Dense and Discrete (7-8),
  `undischarge` (9-10), computable `deduction_converse` as plain `example`
  (11-12) + noncomputable round-trip (13), Prop-level `Derivable.deduction` via
  dot notation (14-15), failure modes via `#guard_msgs` (16-17).
- Registered in `Tests/BimodalTest.lean` root imports.

## Verification

| Check | Result |
|-------|--------|
| `lake build` (full, default target) | green (1753 jobs) |
| `lake build BimodalTest.Automation.DeductionTest` | green (677 jobs) |
| Sorries in modified files | 0 |
| Vacuous definitions | 0 |
| New axioms | 0 (only propext/Classical.choice/Quot.sound in closure) |
| `deduction_converse` computable | yes (plain `example` consumers compile) |
| Negation-defeq test without `unfold`/`show` | yes — Phase-2 fallback never needed |

## Plan Deviations

- **Phase 1 (altered)**: `Derivable.deduction` declared with
  `_root_.Bimodal.ProofSystem.` prefix (plan wrote bare `Derivable.deduction`,
  which inside `namespace Bimodal.Metalogic.Core` would not support dot
  notation). Added `import Bimodal.ProofSystem.Derivable` to
  DeductionTheorem.lean, which the plan did not anticipate.
- **Phase 2 (altered)**: used `goal.getType` (exactly as the
  `mkOperatorKTactic` template) instead of the plan's
  `withReducible <| goal.getType'`; and used the plan's sanctioned alternative
  `syntax (num)? + elab_rules` pattern instead of an `iterate`-based macro.
- **Phase 3 (altered)**: tests placed in NEW file
  `Tests/BimodalTest/Automation/DeductionTest.lean` instead of
  `TacticsTest.lean`, because TacticsTest.lean does not compile at baseline
  (~94 pre-existing error positions: stale `DerivationTree [] φ` applications
  predating the frame-class generalization plus noncomputability errors —
  verified on the unmodified tree). Repairing it is out of scope; flagged as a
  candidate follow-up task alongside task 193.

## Discovered Issue (follow-up candidate)

`Tests/BimodalTest/Automation/TacticsTest.lean` (and possibly other test
modules reachable from the `BimodalTest` root) is broken at baseline: `lake
build BimodalTest.Automation.TacticsTest` fails with ~94 error positions of the
form `DerivationTree [] φ` (fc argument missing after the frame-class
generalization) and `noncomputable` propagation errors. The default `lake
build` target (`Bimodal` lib) is unaffected. A dedicated test-suite repair task
is recommended.

## Files Modified

- `Theories/Bimodal/Metalogic/Core/DeductionTheorem.lean` (+~45 lines: import, docstring index, 2 declarations)
- `Theories/Bimodal/Automation/Tactics/Deduction.lean` (new, 146 lines)
- `Theories/Bimodal/Automation/Tactics/Commands.lean` (+1 import line)
- `Tests/BimodalTest/Automation/DeductionTest.lean` (new, 158 lines)
- `Tests/BimodalTest.lean` (+1 import line)
