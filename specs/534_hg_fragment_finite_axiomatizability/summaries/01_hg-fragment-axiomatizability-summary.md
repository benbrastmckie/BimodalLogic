# Implementation Summary: Task #534

- **Task**: 534 - H/G-fragment finite axiomatizability (TMFrag per frame class)
- **Status**: [COMPLETED]
- **Started**: 2026-09-22T06:26:34Z
- **Completed**: 2026-09-22T06:50:11Z
- **Effort**: ~25 minutes wall-clock (five phases, five phase commits)
- **Dependencies**: None
- **Artifacts**: plans/01_hg-fragment-axiomatizability.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Executed all five phases of the plan: a theorems-only extension calculus `MinusExt fc Ax` with
its soundness engine, the canonical per-class verdict record `FragmentAxiomatization.lean` (Σ_fc,
four soundness rows, two strictness rows, conditional completeness with the `ChainComplete`
hypothesis explicit and never asserted), a syntax-only L⁻ deduction layer with the four
`□`-globality derivations, and the wiring/ledger/docstring pass. Every new module builds
sorry-free inside the `Conservativity` aggregator and every gate is green.

## Per-class verdict

| Class | `TMFrag fc` = | Σ_fc | Machine-checked here | Literature-backed (not machine-checked) |
|---|---|---|---|---|
| `.Base` | TM⁻ + (Sp)/(DD) | `sigmaBase` | soundness `minusExt_sigmaBase_le_tmFrag`; strictness `tmMinus_lt_minusExt_sigmaBase` | completeness: Burgess 1984 §2.5 + §2.6 (+ discrete collapse onto ℚ ×ₗ ℤ) + boxed-disjunction intersection |
| `.Dense` | TM⁻_d | ∅ | soundness `minusExt_empty_le_tmFrag_dense` | completeness: Burgess 1984 §2.5 |
| `.ZTime` | TM⁻_z + Z1 | `sigmaZTime` | soundness `minusExt_sigmaZTime_le_tmFrag`; strictness `tmMinus_lt_minusExt_sigmaZTime` | completeness: Venema 2001 Thm 3.3 (survey-grade; Segerberg 1970 / Goldblatt not in corpus) |
| `.RTime` | TM⁻_r | ∅ | soundness `minusExt_empty_le_tmFrag_rtime` | completeness: Burgess 1984 §2.7, CO subsuming A7 on paper |

Verdict at every class: **finitely axiomatizable** over TM⁻ in L⁻. The conditional form
`minusExt_iff_tmFrag_of_chainComplete` (and four per-class corollaries) is the only Lean statement
of the completeness half; no declaration concludes `ChainComplete _ _`.

## Paper report-back (reworded footnote, verbatim from `FragmentAxiomatization.lean`'s Paper note)

The commented-out footnote in `possible_worlds.tex` (`sub:Logic`, after "TM⁻ owes its strength to
since and until") asserting that the Past/Future language admits no complete finite axiomatization
of the fragment is **not supportable** and should not be un-commented as drafted. It should be
reworded to: TM⁻ is incomplete at `.Base` and `.ZTime` (machine-checked:
`tmMinusCompleteBase_refuted`, `tmMinusCompleteZTime_refuted`); TM⁻ + (DD) and TM⁻_z + Z1 are
complete for all task frames and for ℤ-time respectively, and TM⁻_d, TM⁻_r are already complete —
by the classical H/G completeness results (Burgess 1984 §§2.5–2.7, Venema 2001 Thm 3.3) and the
universal-modality reduction, with the soundness halves machine-checked and the completeness halves
literature-backed. Since the fragment is r.e. through TM in any case, only the *finite*
axiomatizability claim carries content, and it is positive.

## What Changed

- `FormalSystem/Metalogic/Conservativity/MinusExt.lean` — Created: `MinusExt` (Prop-valued
  closure under MP/MN/TN/TR), `minusExt_of_derivable`, `minusExt_mono`, `minusExt_empty_iff`,
  `tmFrag_mp/mn/tn/reflectTime`, `minusExt_le_tmFrag`.
- `FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean` — Created: `sigmaBase`,
  `sigmaZTime`, `sigmaBase_le_tmFrag`, `sigmaZTime_le_tmFrag`, four `minusExt_*_le_tmFrag` rows,
  `tmMinus_lt_minusExt_sigmaBase/sigmaZTime`, `ChainValidIn`, `ChainComplete`,
  `tmFrag_chainValidIn`, `minusExt_iff_tmFrag_of_chainComplete` + four corollaries; module
  docstring is the canonical verdict record with the Paper note.
- `FormalSystem/Metalogic/Conservativity/MinusDeduction.lean` — Created: `deductionOfSubset`,
  `minusDeductionTheorem` (computable), `minusDeductionConverse`, `minusImpTrans`, `minusFlip`,
  `minusNotNotIntro`, `minusContrapos`, `minusDne`, `minusToDiamond`, `minusModalB`,
  `boxImpBoxBox`, `notBoxImpBoxNotBox`, `boxGlobalFuture`, `boxGlobalPast`,
  `notBoxGlobalFuture`, `notBoxGlobalPast`.
- `FormalSystem/Metalogic/Conservativity.lean`, `FormalSystem.lean` — three imports each (sorted);
  aggregator paragraph, module list and import-chain note extended.
- `FormalSystem/Metalogic/Conservativity/Fragment.lean` — "Why the fragment" section now points at
  the per-class pins instead of "open research not attempted".
- `FormalSystem/Metalogic/Conservativity/TMCompletenessReduction.lean` — preamble records Σ_fc;
  `.Dense`/`.RTime` rows gain "expected complete by classical theorem; not machine-checked";
  `.RTime` obstruction paragraph notes it is Doets-route-specific.
- `FormalSystem/Metalogic.lean` — SORRY-FREE fragment paragraph names the Σ_fc soundness rows.
- `FormalSystem/Metalogic/Conservativity/README.md` — inventory regenerated, three new
  descriptions, four Key Results bullets; `FormalSystem/Metalogic/README.md`,
  `FormalSystem/README.md`, `README.md` — generated inventory blocks only.
- `scripts/check-module-invariants.sh` — 11 C14 pins (both baseline pair halves).
- `docs/theorem-index.md` — 11 new rows after `tmMinus_lt_tmFrag_ztime`.

## Decisions

- Deduction theorem by **structural** recursion on a subset-generalized statement
  (`Γ' ⊢⁻ φ → Γ' ⊆ A :: Γ → Γ ⊢⁻ A → φ`) rather than the L side's height-based well-founded
  recursion: `MinusLanguage.DerivationTree` has no height lemmas, and the generalization makes the
  `weakening` case a direct recursive call. `MinusFormula` has `DecidableEq`, so the result is
  computable (no `noncomputable` marker needed; the Challenge signature is otherwise identical).
- Propositional combinators derived *through* the deduction theorem (context derivations
  discharged), which is what keeps them short; `minusModalB`/`boxImpBoxBox` mirror
  `Combinators.modalB`/`modal4` exactly. Five combinators were needed rather than the planned three
  (`minusFlip`, `minusNotNotIntro` in addition) — the plan named this count as a hypothesis.
- `FragmentAxiomatization.lean` imports `SpCountermodel` and `DenseObstructionTransfer` directly
  (only the aggregator imported them; no cycle, confirmed by `check-metalogic-cycles.sh`).
- The wide verdict table was replaced by a narrow table plus per-class bullets to satisfy the
  100-character line linter (the initial version produced five `longLine` warnings).

## Plan Deviations

- **Phase 4, module-creation item** altered: imports `FormalSystem.MinusLanguage.Derivation`
  directly rather than the `FormalSystem.MinusLanguage` aggregator, because the aggregator does
  import the semantic modules (its own docstring says so), which would contradict the phase's
  "syntax-only" verification bullet; annotated inline on the plan checklist.
- **Testing & Validation, challenge `--check` item** skipped: no Challenge manifest exists
  (`challenge/manifest.json` was never snapshotted at plan time), so the advisory drift check
  cannot run; the Goals-name compliance spot-check passed 18/18 instead.

## Verification

- Build: Success — full guarded `lake build`, guard exit 0, "Build completed successfully (2702
  jobs)", 0 `error:`, 0 `warning:`; every touched module's `.olean` newer than its source.
- Sorry count: 0 (`lean-sorry-census.sh` over all resolved roots).
- Vacuous count: 0 introduced. The repo-wide single-line grep has exactly one hit,
  `FormalSystem/Examples/TemporalStructures.lean:483` (`int_domain_universal … := trivial`), which
  is pre-existing at the base commit `572fc031e`, outside this task's scope, and a legitimate
  example theorem about a history whose domain is total — not a placeholder.
- Axiom count: 14 `^axiom ` lines, identical to the base commit (no new axioms).
- `lean_verify`: all Prop-valued Goals theorems = `[propext, Classical.choice, Quot.sound]`;
  the four `*Global*` derivations and `minusDeductionTheorem` = `[propext]`.
- `scripts/check-module-invariants.sh`: ALL CHECKS PASSED (C9, C14 incl. the 11 new pins, C23,
  C27, INV). `scripts/check-metalogic-cycles.sh`: PASS.
- Prohibition audit: `ChainComplete` occurs only in its `def`, as `(h : ChainComplete …)`
  hypotheses, and in prose; nothing concludes `TMMinusComplete _`, `Forward _`, or
  `TMFrag fc φ → MinusLanguage.Derivable fc [] φ`.
- Comparator gate: not requested (`compare_flag` absent); no `comparator` block recorded.
- Tests: N/A (no test files in scope; the acceptance `example`s live in the modules).
- Files verified: Yes

## Impacts

- `MinusExt` is a reusable closure operator: any future schema set can be tested for fragment
  soundness with one `minusExt_le_tmFrag` application.
- `ChainComplete fc Ax` is the precise proposition a future base-language canonical model must
  prove to turn the conditional completeness theorems unconditional; `tmFrag_chainValidIn` is the
  direction already closed.
- `minusDeductionTheorem` and the combinators give the L⁻ side a propositional layer for the first
  time; the four `□`-globality derivations are available to any TM⁻ development at every class.
- The status tables in `TMCompletenessReduction.lean`, `Fragment.lean`, `Metalogic.lean` and the
  Conservativity README now distinguish machine-checked soundness from literature-backed
  completeness explicitly.

## Follow-ups

- Paper: reword the `sub:Logic` footnote per the report-back above (PossibleWorlds repository not
  edited by this task).
- Optional: take the Challenge snapshot for this task so a future `--check` can run.
- Optional future task: a base-language canonical model discharging `ChainComplete` at `.Dense`
  (Sahlqvist canonicity for DN) — the cheapest of the four to make unconditional.

## References

- specs/534_hg_fragment_finite_axiomatizability/plans/01_hg-fragment-axiomatizability.md
- specs/534_hg_fragment_finite_axiomatizability/reports/01_hg-fragment-axiomatizability.md
- specs/534_hg_fragment_finite_axiomatizability/handoffs/ (five phase-end handoffs)
- FormalSystem/Metalogic/Conservativity/FragmentAxiomatization.lean (canonical verdict record)
