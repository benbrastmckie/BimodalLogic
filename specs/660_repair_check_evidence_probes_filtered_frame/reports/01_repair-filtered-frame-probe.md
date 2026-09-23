# Research Report: Repair the filtered-frame-is-universal evidence probe

- **Task**: 660 - Repair check-evidence-probes.sh: phase7-filtered-frame-is-universal does not compile
- **Started**: 2026-09-23T00:00:00Z
- **Completed**: 2026-09-23T00:00:00Z
- **Effort**: ~1 hour research; implementation estimated under 30 minutes
- **Dependencies**: None (task 661 depends on this one; run 660 to completion first)
- **Sources/Inputs**:
  - Codebase: `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`,
    `scripts/check-evidence-probes.sh`
  - Codebase: `FormalSystem/Semantics/TaskFrame.lean`,
    `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean`,
    `FormalSystem/Metalogic/Decidability/FMP/FiniteModel.lean`,
    `FormalSystem/Semantics/IntNormalForm.lean`
  - Compiler evidence: `lake env lean` runs on the probe and on three candidate repairs
  - Prior artifact: `specs/657_audit_frame_constraints_history_restriction/plans/01_promote-completion-restriction-independence.md`
    (the exclusion row that surfaced this failure)
- **Artifacts**:
  - `specs/660_repair_check_evidence_probes_filtered_frame/reports/01_repair-filtered-frame-probe.md`
- **Standards**: report-format.md, subagent-return.md

## Executive Summary

- The gate's single failure is reproduced at HEAD: `bash scripts/check-evidence-probes.sh`
  reports `FAIL 1 of 5`, with the other four wired probes and the one deferred probe behaving
  exactly as documented. Nothing else in the gate needs touching.
- The root cause is now pinned to an exact compiler diagnostic, and it is **not** the cited-lemma
  drift the task description leads with. Swapping `ofReflective_taskRel_eq` for
  `ofReflectiveRegular_taskRel_eq` cannot work, because the probe's `simp` first *unfolds*
  `RefinedFilteredTaskFrame`, and the resulting unfolded application is not type-correct at the
  `implicit` transparency level that `rw`/`simp` matching uses.
- The precise defect: `TaskFrame.limit_of_permissive` is declared with the **unfolded** return
  type `∀ w u, (∀ x, 0 < x → ∃ y, |y| < x ∧ R w y u) → u = w` rather than `TaskFrame.Limit R`,
  so the auto-generated `RefinedFilteredTaskFrame._proof_4` carries that unfolded type while
  `ofReflectiveRegular` expects `TaskFrame.Limit (refinedFilteredTaskRel D phi)`. The sibling
  proofs `_proof_2`, `_proof_3`, `_proof_5` carry the folded `Compositional`/`Serial`/`Saturation`
  types and are fine. `TaskFrame.Limit` is a semireducible `def`, so the gap is invisible to
  matching.
- The repair is therefore neither a rewrite nor a restatement: **stop unfolding the frame**. The
  library already publishes the bridge the probe should cite —
  `RefinedFilteredTaskFrame.rel_iff` (`Filtration.lean:359`), which states
  `(RefinedFilteredTaskFrame D phi).TaskRel w d u ↔ (d ≠ 0 ∨ w = u)`.
- A three-line term-mode repair using that bridge was written and compiled: `lake env lean`
  exits 0 with **zero errors and zero warnings**, and all three probe statements stay
  byte-identical. This satisfies the gate's no-weakening rule literally — only the proofs change.
- No `sorry`, no new axiom, and no library change is required. A sorry-free path exists and is
  verified.

## Context & Scope

`scripts/check-evidence-probes.sh` compile-checks five Lean files under `specs/evidence/` that
sit outside the Lake build graph, so `lake build` never sees them. One,
`bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`, stopped compiling and the gate
cannot exit 0.

The probe records a design obstruction for the bi-lasso decision layer: the finite filtered
frame's one-step relation is universal, so the frame carries no dynamics — which is why the layer
presents frames rather than filtering. The script's own failure banner forbids deleting the probe
or weakening its statements to make the gate pass, so the repair must preserve all three
`example` statements exactly and change only how they are proved.

Scope of this research: identify the true cause, identify a sorry-free repair, and verify that
repair compiles. Out of scope: the deferred probe
`spike-untl-unfolding-and-fwd-obstruction` (deliberately unwired pending frame-class uniformity
work) and the four passing probes.

## Findings

### Codebase Patterns

- **The frame stack.** `FiniteFilteredTaskFrame` (`FiniteModel.lean:172`) is a `FiniteFrameOver`
  whose `toFrameOver` field is `RefinedFilteredTaskFrame D phi`, definitionally
  (`FiniteFilteredTaskFrame.taskRel_eq`, `FiniteModel.lean:193`, proved by `rfl`).
  `RefinedFilteredTaskFrame` (`Filtration.lean:292`) is built by
  `FrameOver.ofReflectiveRegular` over `refinedFilteredTaskRel D phi`, which is
  `if d = 0 then w = u else True` (`Filtration.lean:269`).
- **The constructor split.** Task 656 split `FrameOver.ofReflective` into `ofReflective` (data
  only) and `ofReflectiveRegular` (data plus the four `def:frame` constraint proofs, consumed by
  the `instIsRegularOfReflective` auto-instance) — `TaskFrame.lean:1252-1291`. The probe was last
  edited by task 609 (`git log` on the probe file), before that split, which is why it still
  cites the `ofReflective`-flavoured `ofReflective_taskRel_eq`.
- **The library's documented convention for these bridges.** `ofReflective_taskRel`'s docstring
  (`TaskFrame.lean:1300-1306`) states explicitly that the lemma is *not* `@[simp]` because "its
  left-hand side is well typed only up to unfolding `ofReflective` … which `simp` cannot see
  through", and directs that "each frame built this way states its own `@[simp]` bridge
  instead". The probe is a direct violation of that instruction: it unfolds the frame inside
  `simp` rather than citing the frame's own bridge.
- **The filtered frame's own bridge already exists.** `RefinedFilteredTaskFrame.rel_iff`
  (`Filtration.lean:359`) is exactly that per-frame bridge:
  `∀ w d u, (RefinedFilteredTaskFrame D phi).TaskRel w d u ↔ (d ≠ 0 ∨ w = u)`. It is proved via
  `FrameOver.ofReflectiveRegular_taskRel.trans`, i.e. by *term application* at default
  transparency, which is precisely why it succeeds where the probe's `rw`/`simp` cannot. It is
  the lemma the four downstream axiom theorems (`RefinedFilteredTaskFrame_serial`,
  `_interpolates`, `_limit`, `_saturation`) already route through.

### Root Cause (compiler-confirmed)

Running the probe at HEAD produces three `unsolved goals` errors, one per `example`, each leaving
a goal of the shape

`(FrameOver.ofReflectiveRegular (FilteredWorld phi) (refinedFilteredTaskRel intOrder phi) ⋯ ⋯ ⋯ ⋯ ⋯).TaskRel w 1 u`

plus `unusedSimpArgs` warnings naming `FrameOver.ofReflective_taskRel_eq` — the cited lemma never
fires. Substituting `ofReflectiveRegular_taskRel` / `ofReflectiveRegular_taskRel_eq` leaves the
identical goal and the identical "unused simp argument" warning, confirming the task
description's claim that the obvious substitution does not fix it.

Forcing the rewrite explicitly (`unfold`, then `rw [FrameOver.ofReflectiveRegular_taskRel]`)
surfaces the mechanism in full:

- `rw` reports `Did not find an occurrence of the pattern`, and then:
  `Note: The target expression is not type-correct under the 'implicit' transparency level…`
- `Full error: Application type mismatch: The argument RefinedFilteredTaskFrame._proof_4 intOrder phi`
  has type `∀ (w u : FilteredWorld phi), (∀ (x : intOrder.carrier), 0 < x → ∃ y, |y| < x ∧ refinedFilteredTaskRel intOrder phi w y u) → u = w`
  but is expected to have type `TaskFrame.Limit (refinedFilteredTaskRel intOrder phi)`.

Inspecting the five auto-generated proofs directly confirms the asymmetry:

| aux proof | recorded type | folded? |
|---|---|---|
| `_proof_1` (reflection `hR`) | `∀ w d u, refinedFilteredTaskRel … ↔ refinedFilteredTaskRel … (-d) w` | n/a (that is the stated shape) |
| `_proof_2` (`hcomp`) | `TaskFrame.Compositional (refinedFilteredTaskRel D phi)` | yes |
| `_proof_3` (`hser`) | `TaskFrame.Serial (refinedFilteredTaskRel D phi)` | yes |
| `_proof_4` (`hlim`) | `∀ w u, (∀ x, 0 < x → ∃ y, \|y\| < x ∧ refinedFilteredTaskRel D phi w y u) → u = w` | **no** |
| `_proof_5` (`hsat`) | `TaskFrame.Saturation (refinedFilteredTaskRel D phi)` | yes |

The reason is upstream and deliberate: `TaskFrame.Limit` (`TaskFrame.lean:714`) is a
semireducible `def` whose docstring records that the name "is *definitionally* the old shape" and
that `limit_of_succOrder`, `limit_of_shift` and the class helpers "are stated in that shape
unchanged". `TaskFrame.limit_of_permissive` (`TaskFrame.lean:1804`) accordingly returns the
unfolded shape, while `comp_of`, `serial_of_permissive` and `saturation_of_permissive` return
their folded named predicates. So `_proof_4` alone comes out unfolded, and any match that must
re-typecheck the `ofReflectiveRegular` application under reducible/implicit transparency fails.

### Scope of the Defect Beyond This Probe

This is a general property of every `ofReflectiveRegular`-built frame whose `hlim` argument comes
from `limit_of_permissive`, `limit_of_succOrder` or `limit_of_shift` — which is most of them
(`RegionFrame.lean:190`, `FlowFrame.lean:166`, `ForwardDeterministicFrame.lean:185`,
`LimitClosureFrame.lean:192`, and others). No library code is affected in practice, because every
in-library site follows the documented convention of stating a named bridge lemma proved by term
application instead of rewriting into an unfolded frame body. The probe is the only site that
broke the convention, and it is the only site that fails.

### Verified Repair

The following compiles under `lake env lean` with **exit 0, no errors, no warnings** (verified as
a standalone file with the probe's exact imports, opens, and statements):

- Probe A: `(RefinedFilteredTaskFrame.rel_iff intOrder phi w 1 u).mpr (Or.inl one_ne_zero)`
- Probe B: `fun n => (RefinedFilteredTaskFrame.rel_iff intOrder phi (f n) 1 (f (n + 1))).mpr (Or.inl one_ne_zero)`
- Probe C: `(RefinedFilteredTaskFrame.rel_iff intOrder phi w d u).mpr (Or.inl hd)`

Each is a term-mode proof, so no tactic-level transparency question arises. The defeq steps it
relies on are all already named library facts: `FiniteFilteredTaskFrame.taskRel_eq` (`rfl`),
`FiniteFilteredTaskFrame.worldState_eq` (`rfl`), and `FrameOver.step_def` (`Iff.rfl`). The three
`example` signatures are unchanged character-for-character from the current probe.

Two alternatives were tested against the same statements. A tactic-mode variant
(`show (RefinedFilteredTaskFrame intOrder phi).TaskRel w 1 u; exact FrameOver.ofReflectiveRegular_taskRel.mpr …`)
also compiles, and is a viable fallback. The `simp`-with-corrected-lemma variant does **not**
compile, as predicted.

### Baseline Gate State

`bash scripts/check-evidence-probes.sh` at HEAD:

```
phase3-scan-bound-is-false                       PASS
phase7-filtered-frame-is-universal               FAIL (does not compile)
phase12-check-not-compositional                  PASS
phase10-origin-anchoring-obstruction             PASS
mixed-sign-composition-obstruction               PASS
spike-untl-unfolding-and-fwd-obstruction         SKIP (deferred)
FAIL  1 of 5 wired probe(s) failed   (exit 1)
```

Repairing the one file is sufficient for the gate to exit 0. No script change is needed.

## Decisions

- **Repair the probe, not the library.** Changing `TaskFrame.limit_of_permissive` (and its two
  siblings) to return `TaskFrame.Limit R` would also fix the probe and would make `_proof_4`
  fold, but it contradicts an explicit, reasoned docstring decision at `TaskFrame.lean:700-706`
  and touches a helper used by at least five frames across `Metalogic/`. That is a
  disproportionate blast radius for a probe repair, and it belongs to a separate task if it is
  wanted at all.
- **Cite `RefinedFilteredTaskFrame.rel_iff`, not `ofReflectiveRegular_taskRel_eq`.** The former
  is the library's own designated per-frame bridge, is already the route the four axiom theorems
  take, and is stable against future changes to the constructor split. The latter would require
  the probe to keep naming the constructor, which is exactly the coupling that broke it when task
  656 renamed it.
- **Use term mode, not tactic mode.** The failure is a transparency-level matching failure inside
  tactics; a term-mode proof sidesteps the entire class of problem and produces a file with no
  warnings, including no `unusedSimpArgs` noise.
- **No restatement of the obstruction.** The task description offered "restatement of the probe
  against the regular constructor" as an option. It is not needed and is not recommended: the
  statements are correct as written and the gate's no-weakening rule is best honoured by leaving
  them untouched.

## Recommendations

Prioritized, single-phase; the whole repair is one file.

1. **Replace the three tactic blocks in
   `specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean` with the
   verified term-mode proofs above.** Leave the imports, the three `open` lines, the three
   `example` signatures, and all three explanatory comments exactly as they are.
2. **Update the probe's inline comments only if they name the broken citation.** They currently do
   not, so most likely nothing to do; confirm during implementation.
3. **Verify with `lake env lean specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`**
   expecting exit 0 with empty output (no warnings), then
   **`bash scripts/check-evidence-probes.sh`** expecting `PASS all 5 wired probe(s) compile` and
   exit 0.
4. **Do not run `lake build`** as an acceptance gate for this task — the probe is outside the
   build graph and no library file changes, so a full build proves nothing about this repair. A
   build is only warranted if recommendation 5 is taken up.
5. **Optional follow-up, separate task (do not do it here):** consider whether
   `TaskFrame.limit_of_permissive` / `limit_of_succOrder` / `limit_of_shift` should be restated
   with return type `TaskFrame.Limit R`. It would remove a latent trap for every future
   `ofReflectiveRegular` call site, but it reverses a documented decision and should be argued on
   its own merits, with the `TaskFrame.lean:700-706` docstring updated to match.

## Risks & Mitigations

- **Risk: a future frame-API change breaks the probe again.** Mitigation: citing
  `RefinedFilteredTaskFrame.rel_iff` binds the probe to a named, docstring-blessed library lemma
  that the four axiom theorems also depend on, so a change that breaks the probe now also breaks
  in-library theorems and will be caught by `lake build` rather than only by this out-of-graph
  gate.
- **Risk: the repair is read as weakening the obstruction.** Mitigation: the three `example`
  statements are unchanged character-for-character; only proof terms differ. The implementation
  summary should say so explicitly and show the diff is confined to proof bodies.
- **Risk: `RefinedFilteredTaskFrame.rel_iff` is not `@[simp]`, so a future contributor reaching
  for `simp` hits the same wall.** Mitigation: add a short comment in the probe naming the
  transparency reason and pointing at `TaskFrame.lean`'s `ofReflective_taskRel` docstring. Low
  cost, and it converts a repeat incident into a one-line read.
- **Risk: the latent unfolded-`Limit` trap (recommendation 5) is left open.** Accepted for this
  task. It causes no live failure anywhere in `FormalSystem/`, and closing it is a library-wide
  change that would make this repair non-minimal and would contradict a documented decision
  without a task that owns that argument.

## Tactic Survey Results

Candidates were tested by compiling standalone files with the probe's exact statements
(`lake env lean`), rather than via `lean_multi_attempt`, because the goals only exist after the
file's own imports elaborate.

| Goal | Tactic / term | Result | Premises/Config |
|------|---------------|--------|-----------------|
| Probe A: `(FiniteFilteredTaskFrame intOrder phi).toFrameOver.step w u` | `simp [FrameOver.step, FiniteFilteredTaskFrame, RefinedFilteredTaskFrame, ofReflective_taskRel_eq, refinedFilteredTaskRel]` (current) | fail — unsolved goals; cited lemma unused | as written in the probe |
| Probe A | same `simp`, with `ofReflectiveRegular_taskRel` substituted | fail — identical unsolved goal, lemma still unused | the "obvious fix" |
| Probe A | `unfold …; rw [FrameOver.ofReflectiveRegular_taskRel]` | fail — pattern not found; diagnostic names `_proof_4` type mismatch | this is the diagnostic that pinned the cause |
| Probe A | `(RefinedFilteredTaskFrame.rel_iff intOrder phi w 1 u).mpr (Or.inl one_ne_zero)` | **success**, no warnings | term mode |
| Probe A | `show (RefinedFilteredTaskFrame intOrder phi).TaskRel w 1 u; exact FrameOver.ofReflectiveRegular_taskRel.mpr (by simp [refinedFilteredTaskRel])` | success | viable fallback |
| Probe B: `IsStepPath … f` | `fun n => (RefinedFilteredTaskFrame.rel_iff intOrder phi (f n) 1 (f (n+1))).mpr (Or.inl one_ne_zero)` | **success**, no warnings | term mode |
| Probe C: `(FiniteFilteredTaskFrame intOrder phi).TaskRel w d u`, `hd : d ≠ 0` | `(RefinedFilteredTaskFrame.rel_iff intOrder phi w d u).mpr (Or.inl hd)` | **success**, no warnings | term mode |

Full three-example repair compiled together: exit 0, empty output.

## Context Extension Recommendations

- **Topic**: unfolded-vs-folded constraint predicates at `ofReflectiveRegular` call sites.
- **Gap**: nothing in `.claude/context/project/lean4/` records that unfolding a frame built by
  `FrameOver.ofReflectiveRegular` inside `simp`/`rw` is a dead end, nor why. The knowledge
  currently lives only in the `ofReflective_taskRel` docstring, which a contributor debugging a
  failing `simp` has no reason to open.
- **Recommendation**: add a short pattern note (for example
  `.claude/context/project/lean4/patterns/frame-bridge-lemmas.md`) stating the rule — cite the
  frame's own named `TaskRel` bridge lemma; never unfold the constructor — with this incident as
  the worked example and the `_proof_4` diagnostic quoted.

## Appendix

- Diagnostic commands run (all from the repository root):
  - `lake env lean specs/evidence/bi-lasso-decision-layer/phase7-filtered-frame-is-universal.lean`
  - `bash scripts/check-evidence-probes.sh`
  - `lake env lean` on three scratch candidate files containing the probe's statements
  - `#check @RefinedFilteredTaskFrame._proof_1` … `_proof_5` (auto-generated aux declarations;
    used for diagnosis only, never cited in a repair — the `linter.auxLemma` warning is correct
    that they are unstable across refactors)
- Key declaration sites:
  - `FormalSystem/Semantics/TaskFrame.lean:714` — `TaskFrame.Limit`
  - `FormalSystem/Semantics/TaskFrame.lean:1252` — `FrameOver.ofReflective`
  - `FormalSystem/Semantics/TaskFrame.lean:1270` — `FrameOver.ofReflectiveRegular`
  - `FormalSystem/Semantics/TaskFrame.lean:1310` — `FrameOver.ofReflectiveRegular_taskRel`
  - `FormalSystem/Semantics/TaskFrame.lean:1804` — `TaskFrame.limit_of_permissive`
  - `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean:269` — `refinedFilteredTaskRel`
  - `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean:292` — `RefinedFilteredTaskFrame`
  - `FormalSystem/Metalogic/Decidability/FMP/Filtration.lean:359` — `RefinedFilteredTaskFrame.rel_iff`
  - `FormalSystem/Metalogic/Decidability/FMP/FiniteModel.lean:172` — `FiniteFilteredTaskFrame`
  - `FormalSystem/Semantics/IntNormalForm.lean:182` — `FrameOver.step`
  - `FormalSystem/Semantics/IntNormalForm.lean:274` — `IsStepPath`
- Literature: none referenced by this task; the Literature Extraction Protocol does not apply.
