# Implementation Summary: Task #191 — Propositional Decision Procedure

- **Task**: 191 - Propositional decision procedure
- **Plan**: plans/02_reflection-kalmar-plan.md
- **Status**: Implemented — all 6 phases COMPLETED
- **Session**: sess_1784042334_6ccc8d

## Overview

Implemented a verified, reflective (proof-by-reflection) tautology prover for the
propositional fragment of TM bimodal logic, following the plan's reflect → check → apply
architecture (mirroring `Mathlib.Tactic.Ring`). All deliverables are sorry-free and depend
only on the project's standard axiom set (`propext`, `Classical.choice`, `Quot.sound`) — no
`native_decide`, no `Lean.ofReduceBool`, no new axioms.

## Phases Completed (6/6)

- **Phase 1** — `PropForm.lean` (227 lines): deep-embedded `PropForm` (Nat-indexed vars),
  computable `eval`/`vars`/`isTaut` (kernel-`decide`-able), `denote`, and the Kalmar-style
  characterization lemma `isTaut_iff_forall_eval`. Three `decide` smoke tests (Peirce, K,
  5-var tautology).
- **Phase 2** — `Kalmar.lean` prerequisites: the one new object-level lemma `neg_imp_intro`
  (via `ni` + `deduction_theorem` with head-elimination context ordering), `litDenote`/
  `litCtx` literal machinery, membership and context-agreement lemmas.
- **Phase 3** — `kalmar_step`: the main 3-way `imp`-case induction (the hard core),
  discharging all three subcases (`g` true, `f` false, `f` true ∧ `g` false) via `prop_s`,
  `efq_neg`, and `neg_imp_intro` respectively.
- **Phase 4** — Variable elimination (`elim_vars`, head-elimination via `deduction_theorem` +
  `classical_merge`) and the main theorems `tautology_derivable'`/`tautology_derivable`
  (Base) and their `⊢[fc]`/`|-![fc]` generalizations via `DerivationTree.lift`. Two in-file
  sanity examples (`A.imp(B.imp A)`, `(□A).imp(□A)`) via manual reification.
- **Phase 5** — `Decidable.lean` (242 lines): `isPropositional`, a fully computable `reify`
  (see deviation note below), the round-trip lemma `reify_denote`, the trivial-frame truth
  lemma `trivial_truth_iff`, the semantic completeness direction `derivable_tautology` (via
  the existing `Soundness.soundness` theorem — no tableau dependency), and
  `instDecidableDerivable` (hypothesis-carrying `def`). Concrete tautology/non-tautology
  smoke tests.
- **Phase 6** — `PropDecide.lean` (152 lines): the `prop_decide` tactic (reify → kernel
  `decide` → apply `tautology_derivable_fc'`/`tautology_derivable_fc`), handling all four
  goal shapes (`⊢ φ`, `⊢[fc] φ`, `|-! φ`, `|-![fc] φ`). `PropDecideTest.lean` (72 lines)
  exercises schematic goals (including opaque `box`/`untl`/`snce` subterms), frame-class
  goals, and concrete atom-only goals. Umbrella imports wired into
  `Metalogic/Decidability.lean`, `Automation.lean`, and `Tests/BimodalTest.lean`.

## Verification

- Full default-target `lake build`: **green** (1759/1759 jobs).
- Zero `sorry` in all task-191 files (verified via targeted grep and the project's
  sorry-census script, excluding unrelated pre-existing `Boneyard`/`WeakCanonical`/`Bundle`
  sorries from other tasks).
- Zero vacuous definitions (`:= True`/`trivial`/etc. patterns) — none found.
- Axiom count in `Theories/` unchanged from baseline (2, both pre-existing and unrelated to
  this task).
- `#print axioms` on every key theorem (`neg_imp_intro`, `kalmar_step`, `tautology_derivable`,
  `tautology_derivable_fc`, `reify_denote`, `derivable_tautology`, `instDecidableDerivable`,
  and `prop_decide`-produced test terms) shows only `[propext, Classical.choice, Quot.sound]`
  — no `Lean.ofReduceBool`, confirming the zero-`native_decide` constraint held throughout.
- `decide` (kernel-only) verified to close concrete `isTaut`/`reify`-based goals directly
  (see Phase 5 deviation note — this required a design fix from the plan's original
  `Finset.toList`-based approach).

## Plan Deviations

- **Phase 5, `reify`** (altered): the plan specified building the atom list via
  `p.atoms.toList` (`Finset Atom` → `List Atom`). `Finset.toList` is `noncomputable` in this
  Mathlib build, which blocked kernel `decide` on concrete `reify`-based `isTaut` checks
  entirely (confirmed empirically: `decide` got stuck unable to reduce past the
  `Finset.toList` call). Replaced with a custom computable, deduplicated
  `formulaAtomsList : Formula → List Atom` built by direct structural recursion (the same
  `dedup`-based pattern as `PropForm.vars` from Phase 1), making `reify` itself fully
  computable while leaving the round-trip lemma's statement and proof shape unchanged. This
  also makes `instDecidableDerivable` genuinely exercisable via `decide` on concrete
  formulas, which the original `Finset`-based design would not have supported.
- **Phase 5, `isPropositional`/`reify` naming** (altered): defined as plain functions
  (`isPropositional p`, `reify p`) rather than `Formula.isPropositional`/`Formula.reify`
  dot-notation members, since `Decidable.lean` lives in
  `Bimodal.Metalogic.Decidability.Propositional`, not `Formula`'s home namespace
  `Bimodal.Syntax` — dot notation resolves by the argument type's own namespace, so a
  same-name declaration in a different namespace would not be reachable via `p.isPropositional`.
- **Phase 5, trivial model parameters** (altered): used `D := Int` (the same type as `ℤ`;
  needed for local Mathlib instance imports `Mathlib.Algebra.Order.Group.Int`/
  `Mathlib.Data.Int.Basic` to resolve `IsOrderedAddMonoid`/`Nontrivial` in this project's
  import graph) and `WorldHistory.trivial` in place of `WorldHistory.universal_trivialFrame ()`
  — both denote the identical history on `trivial_frame` since `WorldState = Unit` there.
- No other deviations — Phases 1–4 and 6 followed the plan exactly, including the
  head-elimination context ordering strategy for `neg_imp_intro` and `elim_vars` (avoiding
  any context-permutation lemma), and the `Base`-then-`lift` strategy for frame-class
  generalization (no `classical_merge`/`kalmar_step` generality issue arose — both are used
  exactly at `Base` and the final result is lifted via `DerivationTree.lift
  (FrameClass.base_le fc)`).

## Artifacts

- `Theories/Bimodal/Metalogic/Decidability/Propositional/PropForm.lean` (new, 227 lines)
- `Theories/Bimodal/Metalogic/Decidability/Propositional/Kalmar.lean` (new, 291 lines)
- `Theories/Bimodal/Metalogic/Decidability/Propositional/Decidable.lean` (new, 242 lines)
- `Theories/Bimodal/Automation/Tactics/PropDecide.lean` (new, 152 lines)
- `Tests/BimodalTest/Metalogic/PropDecideTest.lean` (new, 72 lines)
- `Theories/Bimodal/Metalogic/Decidability.lean` (edited, +3 import lines)
- `Theories/Bimodal/Automation.lean` (edited, +1 import line)
- `Tests/BimodalTest.lean` (edited, +1 import line)
- `specs/191_propositional_decision_procedure/plans/02_reflection-kalmar-plan.md` (phase
  status markers updated to `[COMPLETED]`, all task checklist items checked, deviations
  annotated inline)
- `specs/191_propositional_decision_procedure/handoffs/phase-2-handoff-20260714.md`,
  `phase-4-handoff-20260714.md` (progressive checkpoint handoffs)

## Task 192 Pointer

`PropDecide.lean`'s module docstring documents the intended integration with a future
`tm_prove` dispatch tactic (task 192): route propositional-skeleton goals to `prop_decide`
first (cheap, complete for the propositional fragment), then fall back to `modal_search`/the
tableau decision procedure for goals with genuine modal/temporal structure.

## Not Done

Nothing — all 6 phases from the plan are complete. The plan's designated scope-cut candidate
(Phase 5) was fully implemented rather than cut, since the remaining effort budget permitted
a careful, sorry-free completion (with one necessary design fix — see deviations above).
