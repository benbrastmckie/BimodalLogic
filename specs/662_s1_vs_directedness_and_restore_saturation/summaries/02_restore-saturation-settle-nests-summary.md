# Implementation Summary: Task #662

- **Task**: 662 - Settle whether plain S1 suffices or directedness is forced, search for a better
  fourth frame constraint, and otherwise restore Saturation as the def:frame constraint in place
  of Completion
- **Status**: [COMPLETED]
- **Started**: 2026-09-24
- **Completed**: 2026-09-24
- **Effort**: ~11 hours across two dispatch cycles
- **Dependencies**: 661 (completed), 659, 657 (completed)
- **Artifacts**: plans/02_restore-saturation-settle-nests.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

All ten plan phases are closed. The three questions the task posed are answered: the
`⇒`-directedness of `def:frame`'s fourth constraint is **not forced** over any carrier this
development instantiates, no candidate better than *Saturation* was found, and *Saturation* is
therefore kept as the constraint with *Completion* demoted to the derived condition `lem:step`
consumes. Every result the prior wave produced is retained and reread as a **sharpness result
about a definition worth keeping** rather than as an argument for replacing it.

Twenty-one declarations landed, all sorry-free and within `{propext, Classical.choice,
Quot.sound}`. No `FrameOver.IsRegular` field changed, so `def:frame`'s operative constraint was
*Saturation* throughout and no proof needed undoing. No manuscript file was touched.

### Answers to the three questions

**Question 1 — is `S₁ᵈ` forced, or would `S₁` suffice?** `S₁` suffices, over every carrier this
development instantiates. `PartialHistory.sInter_constraints_nonempty_of_countable` proves that
over any history with countably many times — automatic for `ℤ`-time and `ℚ`-time, since every
subset of `ℤ` or of `ℚ` is countable — the nest condition `S₁` buys exactly what `S₁ᵈ` buys at
`lem:step`. The plan's unverified sketch (that the segments are genuinely two-dimensional and so
cannot be a nest) is **refuted as an obstruction**: the two-dimensional index `A × Bᵒᵖ` collapses
to one dimension through the running extrema `A'(n) = max_{i ≤ n} a(i)` and
`B'(n) = min_{i ≤ n} b(i)`, and the diagonal `{Seg(τ(A' n), τ(B' n), …)}` is a cofinal nest. The
directedness is therefore kept on the **naturalness** criterion, not extracted from a theorem —
and that is a better position than the alternative, because the strengthening now has a stated
motivation instead of an unexamined one.

What this does **not** settle is the frame-level `S₁ → S₁ᵈ`, which stays open. Neither existing
`¬ Saturation` witness bears on it: both refute `S₁` as well (`SeparatingFrame.not_srel_nestSaturation`,
`RationalTwoOrigins.not_rel_nestSaturation`), which is a correction of a standing assumption.

**Question 2 — is anything better than *Saturation* available?** No. Two candidates were closed:

- *Completion* loses under the governing criterion. Its hypothesis clause **is**
  `def:world-history`'s clause verbatim (`completion_iff_coherentCompletion` machine-checks the
  identification), so stating it `Fib`-free removes the word and not the aboutness;
  `completion_iff_onePointExtension` makes it equivalent, under *Seriality* and *Limit*, to "the
  construction `thm:extension` performs succeeds", an axiom in the shape of its own theorem; and
  it forward-references, `def:frame` preceding `def:world-history`.
- The **fibers-only** weakening loses outright: `SeparatingFrame.srel_fiberSaturation` shows the
  separating frame satisfies it while failing *Saturation*, so dropping segments would weaken the
  constraint strictly. Segments are load bearing.

*Saturation* looks backward instead, to `def:task-relation`: `Fib` and `Seg` are the relation
repackaged as subsets, not new constructions. It also has genus membership with transferable
theory — `TaskFrame.nestSaturation_iff_sphericallyComplete` records by `Iff.rfl` that the nest
form *is* spherical completeness of the ball space of fibers and segments.

**Question 3 — the target architecture.** Realised, and it needed no field swap: `def:frame`
carries *Saturation*; `completion_of_isRegular` derives *Completion* in the bare form immediately
before `lem:step`; `extension_of_completion` takes *Completion* as an explicit hypothesis and
elaborates with no `[F.IsRegular]` binder at all, which is where the minimality is now recorded;
and a strictness remark citing `SeparatingFrame` carries the ball-space footnote.

## What Changed

- `FormalSystem/ForMathlib/Order/BallSpace.lean` — **new module** (Mathlib imports only):
  `Order.IsNest`, `Order.IsNest.exists_subset_inter` (the whole content of `S₁ᵈ → S₁`),
  `Order.SphericallyComplete`, `Order.HasCofinalNest`,
  `Order.sInter_nonempty_of_sphericallyComplete`. Registered under C8, C24 and C33 in the same
  phase, per the siting rule.
- `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.NestSaturation` (`S₁` over a bare
  relation), `nestSaturation_iff_sphericallyComplete` (genus membership, by `Iff.rfl`),
  `nestSaturation_of_saturation` (`S₁ᵈ → S₁`, machine-checked). Three `Paper:` lines normalised to
  the tree's backticked-anchor convention so C15 can match them.
- `FormalSystem/Semantics/Extension/Constraint.lean` — `fib_subset_fib_of_compositional`,
  `fib_subset_fib_of_compositional'` and `seg_subset_seg_of_compositional`, the monotonicity
  lemmas restated with the hypotheses they actually consume (*Compositionality*; plus *Limit*
  above `z`) and **no** `[F.IsRegular]`. `fib_subset_fib_of_le_of_le`, its primed mirror and
  `seg_subset_seg` demoted to one-line corollaries with statements and implicit-argument order
  unchanged, so no call site moved.
- `FormalSystem/Semantics/Extension/Completion.lean` — the nest section: `HasCofinalNest`,
  `sInter_constraints_nonempty_of_nestSaturation` (the reduction, an application of the
  `ForMathlib` lemma), `hasCofinalNest_of_countable` (the carrier discharge) and
  `sInter_constraints_nonempty_of_countable` (the headline), plus two `example` acceptance tests
  for `ℤ` and `ℚ`. Module docstring rewritten into the derived register with the strictness remark
  and the ball-space footnote.
- `FormalSystem/Semantics/Extension/{Step,Extension}.lean` — prose reversal and the
  elimination-site correction propagated across all eight unattributed occurrences.
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` — `SeparatingFrame.nest`,
  `not_srel_nestSaturation`, `RationalTwoOrigins.{phi_sq_lt_two, one_le_phi_add_two,
  not_rel_nestSaturation}`, `FiberSaturation` and `srel_fiberSaturation`.
- `docs/theorem-index.md`, four module READMEs, `FormalSystem/Semantics.lean` — index rows for
  every new declaration and the documentation layer moved into the derived register.
- `~/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/frame-constraint-landscape.md`
  — the resolved source store, never `.claude/`: the four-row strength table, the
  carrier-hypothesis pattern, and the `ForMathlib` siting rule with its four registration
  obligations. `index-entries.json` updated and re-validated.

## Decisions

- **The blocker's repair was taken as authorised, and its ground corrected everywhere it was
  asserted.** Phase 3's pinned Challenge signature rested on the claim that `F.reflection` is a
  `FrameOver` field needing no instance. That is false as measured — `FrameOver.reflection` and
  `TaskFrame.reflection` are derived theorems carrying `[F.IsRegular]`, each proved from *Limit* —
  and the signature it justified stated a false proposition, with a recorded two-state
  countermodel. The user authorised adding `(hlim : TaskFrame.Limit F.TaskRel)` to four pinned
  signatures and correcting the prose that asserted the refuted ground; both were applied.
- **Countability, not `Archimedean D`.** The carrier hypothesis is stated about the history's own
  domain, in the idiom of `NearestAt`. Mathlib has no Hölder embedding with which to discharge
  `Archimedean D`, and a condition on `D` smuggled into the frame would be the wrong shape anyway.
- **Unused instance binders removed rather than grandfathered.** `FiberSaturation` carried four
  unused instance arguments; `nolints.json` would have hidden them. They were deleted.

## Plan Deviations

- **Phase 3** altered: `(hlim : TaskFrame.Limit F.TaskRel)` added to four pinned Challenge
  signatures, under the recorded user authorisation. The phase Goal is preserved — *Limit* is a
  `def:frame` constraint and is not *Saturation*, so nothing downstream carries `[F.IsRegular]`
  and the `S₁`-sufficiency result stays non-vacuous.
- **Phase 4** altered: the new section was appended at the **end** of `Extension/Completion.lean`
  rather than immediately after the *Completion* material, so the module's
  `Completion → extension → discrete time` narrative is not interrupted. Siting only.
- **Phase 5** corrected: the discharge has **three** regimes in Lean, not the two the plan
  predicted. The extra one is `IsPaired`'s own stated side condition rather than a defect in it —
  the global collapse holds only for `z ∉ X`, and Lean's `Constraints` deliberately sites
  `def:constraints`'s `z ∈ D \ X` proviso at the use sites — so `z ∈ dom τ` is live and is
  discharged by the singleton nest `{Fib(τ(z), 0)}`. Per the Scope Hypothesis's own instruction
  the case was not added silently: the theorem's docstring enumerates all three and says why the
  prediction was two.
- **Phase 5** altered: `import Mathlib.Data.Rat.Denumerable` added, because the `ℚ` acceptance
  test needs the `Countable ℚ` instance and no existing import supplied it.
- **Phase 9** extended: `scripts/module-invariants-allowlist.txt` gained eleven entries. C5
  resolves a dotted name as a *file path*, so a `CapitalCase` declaration name is
  indistinguishable from a module path; the allowlist is that check's documented, permanent
  exemption. Eight of the eleven close the pre-existing C5 failure the prior cycle's handoff
  assigned to this phase.
- **Phase 9** extended: three `Paper:` lines in `TaskFrame.lean` normalised from
  `anchor (parenthetical)` to `` `anchor` ``, the form C15 requires and the tree's convention
  everywhere else; the parentheticals moved into the docstring bodies.

## Verification

- Build: **Success** — `lake build` exit 0, 2726 jobs, zero `error:` and zero `warning:` lines.
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots).
- Vacuous count: **0**.
- Axiom count: **unchanged** — no `axiom` declaration added; `#print axioms` on all eighteen
  pinned declarations reports only `propext`, `Classical.choice` and `Quot.sound`, several
  reporting fewer.
- Honesty gate: no theorem introduced by Phases 3, 4 or 5 carries `[F.IsRegular]`; the printed
  statements of `sInter_constraints_nonempty_of_nestSaturation`,
  `hasCofinalNest_of_countable` and `sInter_constraints_nonempty_of_countable` contain neither
  `IsRegular` nor `Saturation`.
- `bash scripts/check-module-invariants.sh` — **ALL CHECKS PASSED** (C5, C15, C16, C24, C30, C33
  and the generated inventory blocks included).
- `lake exe runLinter FormalSystem` — "Linting passed for FormalSystem."
- `lake exe checkInitImports` exit 0, with `FormalSystem.ForMathlib.Order.BallSpace` on the
  recorded C24 exception list; `grep -rn '^import FormalSystem' FormalSystem/ForMathlib/` empty.
- `bash scripts/readme-lint.sh`, `check-evidence-probes.sh`, `check-metalogic-cycles.sh`,
  `check-copyright-headers.sh` — all exit 0.
- `bash scripts/check-paper-definitions.sh` — exit 1, on **one pre-existing drifted anchor
  (`def:id`)** in a manuscript file no commit of this task touches.
  `git status --short docs/reference/paper-definitions-of-record.md` is empty, so no pinned anchor
  moved.
- Scope: `git diff --stat` across the task's commits touches only the files the plan enumerates,
  plus `scripts/module-invariants-allowlist.txt` (recorded above). No `typst/**` file and no
  `.claude/**` file appears.
- Sweeps: the advocacy grep over `FormalSystem/` and `docs/` returns nothing; every surviving
  "application site" occurrence is attributed to the paper; no region asserts `S₁ᵈ` is *strictly*
  stronger than `S₁`, and `TaskFrame.lean`'s "do not restore *strictly stronger*" instruction is
  byte-identical to its committed form.
- Files verified: Yes.

## Impacts

- `def:frame`'s fourth constraint is settled as *Saturation*, with a stated motivation for its
  `⇒`-directed form rather than an unexamined one. The tree and the manuscript agree; no
  manuscript pass is pending.
- The extension chain's own account of itself is now true: *Completion* is the derived condition,
  `extension_of_completion` is where the minimality lives, and `step` is the sole *elimination*
  site rather than the sole application site.
- `FormalSystem/ForMathlib/Order/BallSpace.lean` is upstreamable as it stands and is the first
  ball-space API in reach of any Mathlib-shaped tree.
- The monotonicity lemmas are now available off `[F.IsRegular]`, so any future result about the
  constraint family can be stated without silently assuming *Saturation*.

## Follow-ups

- **`S₁ → S₁ᵈ` is open** and is a recorded non-goal. A separator would need mismatched one-sided
  cofinal characters, hence a non-archimedean `D` of uncountable coinitiality; nothing in the
  development instantiates one, and neither existing witness bears on it.
- **The `ℝ`-time case of the carrier discharge** is not attempted: `ℝ`-time histories may have
  uncountable domains and would need a separate order-separability argument.
- **`def:id`** drifted against `docs/reference/paper-definitions-of-record.md` before this task and
  is untouched by it; it belongs to whoever owns that manuscript file.

## References

- `specs/662_s1_vs_directedness_and_restore_saturation/plans/02_restore-saturation-settle-nests.md`
- `specs/662_s1_vs_directedness_and_restore_saturation/reports/` — the research this plan revised
- `specs/662_s1_vs_directedness_and_restore_saturation/handoffs/phase-8-handoff-20260924105629.md`
- `~/.config/nvim/agent-system/extensions/formal/context/project/logic/domain/frame-constraint-landscape.md`
