# Implementation Summary: Task #662

- **Task**: 662 - Settle whether plain S1 suffices or directedness is forced, search for a better
  fourth frame constraint, and otherwise restore Saturation as the def:frame constraint in place
  of Completion
- **Status**: [BLOCKED]
- **Started**: 2026-09-24
- **Completed**: 2026-09-24 (dispatch closed at a blocked phase; task not complete)
- **Effort**: ~5 hours of the plan's 16.5
- **Dependencies**: 661 (completed), 659, 657 (completed)
- **Artifacts**: plans/02_restore-saturation-settle-nests.md
- **Standards**: summary-format.md, status-markers.md, artifact-management.md, tasks.md

## Overview

Four of the plan's ten phases are closed and committed: the general ball-space layer now exists
in `ForMathlib/`, the nest condition `S₁` is in the library with `S₁ᵈ → S₁` machine-checked, both
`¬ Saturation` witnesses are proved to refute `S₁` as well, the fibers-only candidate is closed
by a new sharpness theorem, and every in-`.lean` region that presented *Completion* as
`def:frame`'s proposed fourth constraint now presents it as the derived condition `lem:step`
consumes. Phase 3 is **[BLOCKED]**: its pinned Challenge signature for
`fib_subset_fib_of_compositional'` states a false proposition, which blocks Phases 4, 5, 6, 9
and 10 behind it.

## What Changed

- `FormalSystem/ForMathlib/Order/BallSpace.lean` — **new module** (Mathlib imports only):
  `Order.IsNest`, `Order.IsNest.exists_subset_inter` (the whole content of `S₁ᵈ → S₁`),
  `Order.SphericallyComplete`, `Order.HasCofinalNest`,
  `Order.sInter_nonempty_of_sphericallyComplete`
- `FormalSystem/ForMathlib.lean`, `scripts/CheckInitImportsMain.lean`, `FormalSystem.lean`,
  `FormalSystem/ForMathlib/README.md`, `FormalSystem/ForMathlib/Order/README.md`,
  `FormalSystem/README.md`, `README.md` — the new module's four registration obligations (C8,
  C24, C33, generated inventory blocks)
- `FormalSystem/Semantics/TaskFrame.lean` — `TaskFrame.NestSaturation` (`S₁`),
  `nestSaturation_iff_sphericallyComplete` (`Iff.rfl`, the genus membership),
  `nestSaturation_of_saturation` (`S₁ᵈ → S₁`); the `Saturation` ball-space docstring extended
  with the open converse, the directedness motivation, and the Hahn-group witness recipe; the
  *Completion* advocacy prose reversed to the derived register
- `FormalSystem/Semantics/StateTopology/ConstraintWitnesses.lean` —
  `RationalTwoOrigins.phi_sq_lt_two`, `.one_le_phi_add_two`, `.nest`, `.not_rel_nestSaturation`;
  `SeparatingFrame.nest`, `.not_srel_nestSaturation`; `SeparatingFrame.FiberSaturation`,
  `.mem_fib_srel`, `.natAbs_cast_rat`, `.srel_fiberSaturation`,
  `.not_fiberSaturation_imp_saturation`; four prose regions reversed; a `longFile` baseline
- `FormalSystem/Semantics/Extension/Constraint.lean` —
  `PartialHistory.fib_subset_fib_of_compositional`, with `fib_subset_fib_of_le_of_le` demoted to
  a one-line corollary (statement and implicit-argument order unchanged)

## Decisions

- **Question 1 stands as the plan settled it**: `S₁ᵈ` is kept. The tree now carries `S₁` beside
  it, `S₁ᵈ → S₁` machine-checked, and the converse recorded as open with the witness recipe.
- **Both witnesses refute `S₁`.** The plan committed only to the `SeparatingFrame` case and made
  the `RationalTwoOrigins` analogue opportunistic; both landed, so the correction is uniform and
  the module docstring says so.
- **Phase 8's proof route was changed** (recorded as a deviation on the plan's checklist item).
  `srel`'s fiber radii are integers, so a directed family has a member of **least** radius;
  minimality plus containment forces that member into every other. This subsumes the plan's
  degenerate `x = 0` case and needs no `sSup`/`sInf` over `ℝ`, so the phase's pre-authorised
  `[COMPLETED WITH EXCLUSIONS]` exit was not approached.
- **`unusedSectionVars` on the two new `TaskFrame` theorems** was closed with a scoped
  `omit [IsOrderedAddMonoid D] [Nontrivial D] in`, the file's own convention, never a blanket
  `set_option` (which invariant C30 forbids).

## Plan Deviations

- **Phase 3 is `[BLOCKED]`, not deviated from.** `.claude/rules/plan-compliance.md`'s Statement
  Fidelity section reserves a pinned-signature change for the user, so the correction was raised
  rather than applied. See **Follow-ups**.
- **Phase 8** altered: the internal proof route (least-radius, not `sSup`/`sInf` over `ℝ`). The
  statement and the phase's conclusion are the plan's.
- **Phase 2** altered: the `longFile` limit *was* crossed (scope hypothesis (b) disconfirmed), so
  the pre-authorised in-source baseline was added; and scope hypothesis (a) grew from 4 to 6
  committed declarations because the opportunistic fifth landed and brought its own `nest` with
  it.
- **Phase 7** altered: two rewritten prose lines exceeded the 100-character limit and were
  rewrapped. The elimination-site sweep found **5 hits, all attributed to the paper, all kept** —
  zero unattributed hits in these files, exactly as the plan predicted.
- **Phases 4, 5, 6, 9, 10**: not started, all blocked behind Phase 3.

## Verification

- Build: **Success** — full `lake build` exits 0 with zero `error:` and zero `warning:` lines
- Sorry count: **0** (`lean-sorry-census.sh` over the resolved source roots)
- Vacuous count: **0**
- Axiom count: **0 new axioms**; `#print axioms` on every declaration landed reports exactly
  `propext`, `Classical.choice`, `Quot.sound` (`Order.sInter_nonempty_of_sphericallyComplete`
  and `nestSaturation_iff_sphericallyComplete` need even fewer)
- Linters: every modified module silent under
  `lake env lean -D weak.linter.mathlibStandardSet=true -D autoImplicit=false`
- `grep -rn '^import FormalSystem' FormalSystem/ForMathlib/` returns nothing (the directory's
  hard dependency rule); `lake exe checkInitImports` exits 0
- `scripts/check-module-invariants.sh` — C8, C15, C24, C30, C33 and the inventory check pass
- `scripts/readme-lint.sh`, `check-evidence-probes.sh`, `check-metalogic-cycles.sh`,
  `check-copyright-headers.sh` — all exit 0
- `docs/reference/paper-definitions-of-record.md` unmodified; no `typst/**` and no `.claude/**`
  file touched by any commit
- The `TaskFrame.lean` "Do not restore *strictly stronger* here." sentence is byte-identical to
  its pre-task form, and the `strictly stronger` occurrence count is unchanged
- Files verified: Yes

### Two pre-existing gate failures, neither caused by this task

- `check-module-invariants.sh` **C5**: 8 unresolved module paths in
  `.claude/context/project/logic/domain/frame-constraint-landscape.md` — a gitignored deploy
  artifact written by the prior wave, whose table writes *declaration* names in module-path
  shape. The durable fix belongs in the source store
  (`<source_dir>/context/project/logic/domain/frame-constraint-landscape.md`) and is Phase 10's,
  which could not open.
- `check-paper-definitions.sh`: one recorded definition drifted, `def:id` — a footnote wording
  change in the manuscript. No manuscript file is touched by any commit of this task
  (`git diff --stat <base>..HEAD -- typst/` is empty), and no `def:frame` anchor moved.

## Impacts

- `Order.SphericallyComplete` and the cofinal-nest reduction are available to any consumer as
  general, upstreamable order theory; the project side reaches them through one import edge in
  the sanctioned direction.
- The claim that the existing witnesses bear on directedness is retired in the tree, in the
  witnesses' own module docstring and at both theorems.
- The fibers-only candidate for `def:frame`'s fourth constraint is closed with a compiled
  witness.

## Follow-ups

- **The one decision that unblocks Phases 3, 4, 5, 6, 9 and 10.** Authorize adding
  `(hlim : TaskFrame.Limit F.TaskRel)` beside the existing `hcomp` on four pinned Challenge
  signatures: `fib_subset_fib_of_compositional'`, `seg_subset_seg_of_compositional`,
  `hasCofinalNest_of_countable`, `sInter_constraints_nonempty_of_countable`. The plan's stated
  ground for omitting it — "`F.reflection` is a `FrameOver` field and needs no instance" — is
  false as measured: `FrameOver.reflection` and `TaskFrame.reflection` are derived theorems
  carrying `[F.IsRegular]`, each proved as `F.reflection_of_limit F.limit`, and the reflection
  law is definitional only off zero. A countermodel is recorded in the plan's Phase 3 BLOCKER
  block (`W = {p,q}`, `R₀ = {(p,p),(p,q),(q,q)}` at every nonneg duration — *Compositional* holds,
  the pinned inclusion fails, *Limit* fails as it must). The repair was verified to elaborate
  with no instance binder and no `sorry`. **The phase's Goal is fully preserved**: *Limit* is not
  *Saturation*, so nothing downstream carries `[F.IsRegular]` and the `S₁`-sufficiency result
  stays non-vacuous.
- The plan's `**Artifacts**` field still names `summaries/01_...`; this dispatch's artifact round
  is `02`, per its dispatch file.
- `FormalSystem/ForMathlib/Order/README.md`'s generated inventory row for `BallSpace.lean` still
  carries the `<!-- TODO: add description -->` placeholder that `PFilter.lean` also carries;
  filling both is Phase 9's narrative work.

## References

- `specs/662_s1_vs_directedness_and_restore_saturation/plans/02_restore-saturation-settle-nests.md`
  (Phase 3's `**BLOCKER**` block carries the countermodel and the exact repair)
- `specs/662_s1_vs_directedness_and_restore_saturation/reports/01_s1-vs-directedness-restore-saturation.md`
- `specs/662_s1_vs_directedness_and_restore_saturation/handoffs/`
- `.claude/rules/plan-compliance.md` (Statement Fidelity — why Phase 3 was blocked rather than
  repaired in place)
