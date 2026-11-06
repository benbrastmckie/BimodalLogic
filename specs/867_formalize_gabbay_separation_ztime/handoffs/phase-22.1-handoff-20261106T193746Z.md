# Phase 22.1 Handoff — GHR 10.2.5's Precondition as Its Own Predicate

- **Status**: [COMPLETED]
- **Dispatch**: 17 (session sess_1793993028_251d86)
- **Plan**: `specs/867_formalize_gabbay_separation_ztime/plans/03_structural-route-measure-split.md`

## Immediate next action

Phase 22.2 (GHR Lemma 10.2.5 by structural recursion — `sepU`, with `isUTyped_sepU`,
`usTruth_sepU` and `isSeparated_sepU`). Its prerequisite is now landed: `IsUSingleType` is the
input hypothesis that recursion inducts on. Two transcription hazards the revision's own route
ruling names, carried forward verbatim so the next dispatch does not rediscover them:

1. The `snce` arm **crosses** its arguments: `snce ψ φ ↦ sepSnce A B (sepU φ) (sepU ψ)`, because
   `USForm.snce` takes guard first and event second while `sepSnce A B C F` takes event `C`
   first and guard `F` second. `usTruth_sepSnce`'s statement
   (`usTruth v t (USForm.snce F C) ↔ usTruth v t (sepSnce A B C F)`) is the authority. An
   uncrossed transcription typechecks and is wrong.
2. The `untl` arm is the identity (`untl ψ φ ↦ .untl ψ φ`): under `IsUSingleType` the only
   `untl` node is `untl B A`, so no decidable-equality test and no `sepU A B A = A` lemma is
   needed, and `IsUTyped.untl` applies to the returned node directly.

## Proof state

No open goals. Zero `sorry` across all resolved Lean source roots (`lean-sorry-census.sh`:
`sorry_count: 0`). Full unscoped guarded `lake build` green (exit 0, zero `error:`, 2961 jobs);
`.olean` newer than source for both touched modules.

## What landed

One new module, additive, exactly at the Scope Hypothesis (8 declarations, one docstring line in
an existing module, zero declaration changes anywhere):

- `FormalSystem/Metalogic/Expressiveness/SeparationZ/Hierarchy.lean` (169 lines):
  `IsUSingleType`, whose `snce` constructor **recurses** where `IsUTyped`'s demands `IsSOnly` of
  both arguments; the four Boolean closure lemmas `IsUSingleType.ofIsSOnly`, `.neg`, `.and`,
  `.or`; `isUSingleType_of_isUTyped`; and the two strictness witnesses
  `not_isUTyped_snce_untl` and `isUSingleType_snce_untl`.
- `NormalForm.lean`: one docstring addition at `IsUTyped` naming the weaker sibling and which
  lemma consumes which. `git diff` shows the change is inside the docstring and nowhere else.

## Key decisions

- The strictness is **proved, not asserted**: `S(⊥, U(A,B))` is accepted by `IsUSingleType` and
  refuted for `IsUTyped`, the refutation being `cases` on `IsUTyped.snce` followed by `cases` on
  the resulting `IsSOnly (USForm.untl B A)`, which has no applicable constructor. This is the
  plan's own specified shape, transcribed rather than re-derived.
- No `isSeparated_of_isUSingleType` was written, and the module docstring records that none can
  exist: a `snce` carrying an `untl` argument is not syntactically separated, which is the exact
  content of "strictly weaker". Producing the separated form is Phase 22.2's `sepU`.
- `IsUTyped` is untouched as a declaration. The ruling that an input position asking for a
  stronger predicate than the step needs is a defect was applied one predicate further out,
  rather than by weakening anything landed.
- The three `Paper: —` docstrings were reflowed so no docstring continuation line begins with
  the token `theorem`, which was producing three false hits in the declaration-counting grep the
  Scope Hypothesis asks for. The count is now exactly 8.

## Deviations

One, annotated inline on the final checklist item: three generated inventory blocks
(`README.md`, `FormalSystem/README.md`, `FormalSystem/Metalogic/README.md`) also required
regeneration, because the new module changes the per-directory file counts those blocks pin and
the phase's gates require `check-module-invariants.sh` green. Repaired through the sanctioned
`--emit-inventory` entry point. The same collision was recorded at Phase 21.

## Measured gates

- Scoped guarded build of `...SeparationZ.Hierarchy`: exit 0, zero `error:`, zero warnings.
- Full unscoped guarded `lake build`: exit 0, zero `error:`, 2961 jobs.
- `lean-sorry-census.sh`: `sorry_count: 0`.
- Vacuous-pattern grep: 1 hit, pre-existing at `FormalSystem/Examples/TemporalStructures.lean:495`
  (a `trivial` whose goal genuinely is `True`-shaped), in a file this phase does not touch.
- `axiom ` declarations: 14, unchanged from the Phase 21 baseline, none in a touched file.
- Axiom profiles, measured by `#print axioms` under `lake env lean`: **all eight** new
  declarations depend on no axioms at all.
- `check-module-invariants.sh`: ALL CHECKS PASSED (exit 0) after the inventory regeneration.
- `check-metalogic-cycles.sh`: exit 0, recorded cycle and upward import set unchanged.
- `typst-sync-check.sh --fix`: PASS (status.typ regenerated; module map and machine appendix
  already in sync).
- `lean-plan-compliance-check.sh`: `COMPLIANCE_CHECK: failed` — a measurement artifact, not a
  divergence. Its entire MISSING list is the task's end-state deliverables (`sepZ`,
  `sepZ_sepClauses`, `separationOver_ztime`, `trZ`, `openTruthAt_iff_trZ`,
  `openValidIn_ztime_iff_trZ`, `plusTruthAt_sepZ_iff`), produced by Phases 25-26 and reachable
  by no earlier phase. The verdict is identical against plan 01 and plan 03, so it is not
  attributable to this dispatch or to the revision. Recorded in `issues.jsonl` as a `tooling`
  issue; expect it on every remaining dispatch of this task until Phase 26 lands.
