# Implementation Plan: Cut the elaboration time of SubformulaProperty.lean

- **Task**: 803 - Cut the elaboration time of `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean`
- **Status**: [IMPLEMENTING]
- **Effort**: 15 hours
- **Dependencies**: None
- **Research Inputs**: `specs/803_cut_subformulaproperty_elaboration_time/reports/01_cut-subformulaproperty-elaboration-time.md`
- **Artifacts**: plans/01_cut-subformulaproperty-elaboration-time.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The module's 36 per-rule `applyRule_<rule>_closed` theorems each `unfold applyRule`, shred the
resulting 36-arm match with `repeat' split`, and then run an `all_goals (try simp_all only [...])`
cascade over the ~37 surviving goals. Profiling attributes 99.2 percent of the module's cost to
`simp` (14,988s cumulative across 1348 calls) and only 0.7 percent to all tactic execution
combined, so the file's own inline comments blaming `unfold`/`whnf` are wrong by two orders of
magnitude. The remedy is to rewrite each of the 36 proof bodies against the already-generated
per-arm equation lemmas `applyRule.eq_1 … applyRule.eq_38`, pinned behind named wrappers in
`Tableau.lean`, replacing the splitter cascade with a two-or-three-goal proof. Done when every
one of the 37 statements still typechecks verbatim, `check-module-invariants.sh` passes, sorry
count is zero, axiom profiles are unchanged, and the before/after per-declaration heartbeat
numbers are recorded as evidence.

### Research Integration

Integrated from `reports/01_cut-subformulaproperty-elaboration-time.md`:

- **Cost attribution is measured, not assumed.** `lake env lean -Dprofiler=true
  -Dprofiler.threshold=200`: `simp` 14,987.6s / `tactic execution` 108s / `type checking` 20.9s /
  `import` 1.55s. The heavy imports named in the task description contribute nothing to this
  module's own elaboration; they matter only as invalidation triggers, which this task does not
  need to solve.
- **The remedy is verified on three of the thirty-six cases**, spanning the three body shapes:
  `applyRule_andPos_closed` 882,487 -> 760 heartbeats, `applyRule_serialityRule_closed`
  2,084,589 -> 146, `applyRule_boxNeg_closed` 885,047 -> 27,178. The report records compiling
  scripts for the first two and the conversion shape for the third.
- **Measure in heartbeats, not wall-clock.** `#count_heartbeats` with `set_option Elab.async
  false` is load-independent and reproduced the file's own two recorded estimates to within 2
  percent. Without `Elab.async false` every count reads ~30 and the A/B is silently void.
- **Restructuring `applyRule` is ruled out by the profile**, not by caution: the dispatch cost it
  would remove is inside the 108s of tactic execution, and it would perturb call sites across the
  tree for under 1 percent of the total. `applyRule`'s definition is therefore out of scope.
- **R2 (named wrappers in `Tableau.lean`) is the plan's single most important risk control** and is
  scheduled before any conversion, so the generator-assigned `eq_N` numbering appears exactly once
  per rule.
- **R3 (the `mem_filterMap_sub` full-simp-set block) is a separate, second-tier phase**: it is what
  leaves `boxNeg` at 27,178 heartbeats after R1 and will dominate the post-R1 total across the ten
  fresh-witness theorems. R1 alone already clears the acceptance bar.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; no roadmap consultation performed.

## Goals & Non-Goals

- **Goals**:

- Reduce this module's elaboration cost substantially, with before/after per-declaration
  heartbeat numbers recorded as evidence rather than asserted.
- Convert the 36 per-rule proof bodies to `applyRule.eq_*` rewrites routed through named wrappers.
- Replace the 36 misleading `unfold`/`whnf` cost comments and the `NonAnalytic` section note with
  the measured attribution.
- Remove the 34 `set_option maxHeartbeats 1200000` and two `set_option maxHeartbeats 3000000`
  lines, so compiling at the 200,000 default is itself independent proof the reduction is real.

- **Non-Goals**:

- No change to any statement that is proved. All 36 per-rule signatures and
  `applyRule_subformula_closed`'s signature stay verbatim.
- No change to `applyRule`'s definition, nor to its arm order.
- Zero new `sorry`, zero new axiom dependency, no weakening of the termination argument.
- Not solving the invalidation-trigger problem (the module's imports of `Tableau` and
  `SubformulaClosure.Closure`). Import is 1.55s of this module's cost; restructuring the import
  graph is a different task.
- No edit to `applyRule_subformula_closed`'s 36 `exact`s — the assembly theorem is already cheap
  and needs no change.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `applyRule.eq_N` numbering shifts if `applyRule`'s arms are reordered or one is added (`z1Rule` already occupies two slots) | H | L | Phase 2 lands 37 named wrappers in `Tableau.lean` before any conversion, so the numbering appears once per rule. Failure mode is loud (`rw` fails, or the wrong rule appears in the goal), never silent. |
| Equation lemmas vanish from `Tableau.olean` because nothing triggers their generation | H | L | The Phase 2 wrappers force generation at the definition site, making their presence a compile-time fact rather than a side effect of other proofs. |
| `rw [applyRule.eq_38 …] <;> (intros; simp_all)` fails to discharge all 38 catch-all guards for some rule | M | M | Per-rule verification is intrinsic — the proof does not compile otherwise. Fall back to naming the contradicting hypothesis explicitly; the report records this branch succeeding for `andPos` (off-sign) and `boxNeg` (off-sign plus five off-pattern constructors). |
| A proof-body rewrite silently proves something weaker | H | L | The statements are untouched and `applyRule_subformula_closed` forces all 36 to typecheck at their declared types. Phase 1 captures `#print axioms` for all 37 declarations; Phase 9 re-runs and diffs. |
| A specific rule resists conversion after a bounded attempt | M | M | Per-rule fallback inside each conversion phase: leave that rule's existing body and ceiling in place, record it in the evidence table, and close the phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record. The acceptance bar is a measured reduction, which R1 on a subset still clears. |
| `simp only` lemma lists drift as goals change shape | L | M | Each converted body is smaller and its `simp only` list shorter than today's. Convert in per-section batches with a scoped guarded build per batch. |
| Build contention on a 24-core box with concurrent `lean` workers | M | H | Route every `lake` invocation through `bash .claude/scripts/lake-build-guard.sh build --timeout N -- …`; never bare `lake`. Read the verdict from the guard's own `result`, never a pipe exit code. |
| Wall-clock before/after is unreproducible and would make the evidence worthless | M | H | Heartbeats are the recorded evidence. Wall-clock is reported as context only, with the machine's core count and concurrent-worker state stated alongside. |
| Dropping the heartbeat ceilings too early makes a partially-converted file fail for an unrelated reason | M | M | Ceiling removal is Phase 8, after every conversion phase has closed green. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |
| 8 | 8 | 7 |
| 9 | 9 | 8 |

Phases within the same wave can execute in parallel. This plan is fully sequential by design:
Phases 3 through 8 all edit the same single file
(`FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean`) in disjoint
line ranges, and concurrent dispatch against one file is a write-collision hazard that the
disjointness does not remove.

---

### Phase 1: Baseline Evidence Capture [COMPLETED]

**Goal**: Record the pre-change axiom profiles, per-declaration heartbeat baselines, and the
literal types of the 38 equation lemmas, so every later phase has a fixed comparison point and
Phase 2 has the exact wrapper signatures it needs.

**Tasks**:

- [x] Create `specs/803_cut_subformulaproperty_elaboration_time/evidence/` and write
  `01_elaboration-baseline.md` into it.
- [x] Capture `#print axioms` for all 37 declarations in the module (the 36 per-rule theorems plus
  `applyRule_subformula_closed`) via a `lean_run_code` probe importing the module. Record the full
  output verbatim in the evidence file.
- [x] Record the pre-change `sorry` count for the two files in scope, asserted by content (the
  check-module-invariants C3 convention), not by line number.
- [x] Run the report's equation-lemma enumeration `run_cmd` (Appendix, "Enumerating the equation
  lemmas") and record the pretty-printed type of all 38 `applyRule.eq_N` constants verbatim. These
  types are Phase 2's input.
- [x] Capture `#count_heartbeats` baselines for the 36 per-rule theorems, with
  `set_option Elab.async false` mandatory in every probe. Record each number in a table keyed by
  rule name. Reuse the three already-measured values from the research report (`andPos` 882,487;
  `serialityRule` 2,084,589; `boxNeg` 885,047) only as cross-checks against freshly measured
  values, never as substitutes for them.
- [x] Record the machine context alongside the numbers: core count, whether other `lean` workers
  were live, and the guard invocation used.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: prose

**Tier Justification**: Every path this phase touches lies under `specs/**`
(`evidence/01_elaboration-baseline.md`), which no suite in `suite_selection_select` maps to and
which the task-reference lint exempts by design, so the honest covering check is the `prose` row's
diff read-through confirming the written file contains the four captured artifacts and no source
file was modified (`git status --short` shows no `.lean` path).

**Scope Hypothesis**: This phase asserts 36 per-rule theorems plus 1 assembly theorem (37
declarations), 38 equation lemmas, 34 `maxHeartbeats 1200000` lines and 2 `maxHeartbeats 3000000`
lines — all carried from `reports/01_cut-subformulaproperty-elaboration-time.md`. Confirm each
count mechanically before relying on it: count `^theorem applyRule_.*_closed` in the module, count
the `eq_N` constants the enumeration `run_cmd` actually finds (a `MISSING` line for any `N` is a
finding, not noise), and count the two `set_option maxHeartbeats` variants by grep. Record the
measured counts next to the carried ones in the evidence file and flag any disagreement.

**Files to modify**:

- `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md` - new
  file: axiom profiles for all 37 declarations, pre-change sorry count, the 38 equation-lemma
  types, the 36 heartbeat baselines, and the machine context

**Verification**:

- The evidence file exists and contains all five captured artifacts (axiom profiles, sorry count,
  38 equation-lemma types, 36 heartbeat baselines, machine context).
- `git status --short` lists no modified `.lean` file — this phase makes no source edit.
- Every heartbeat figure in the table was taken under `set_option Elab.async false`; any figure
  near 30 is evidence the option was missing, not a real measurement, and must be retaken.
- The three cross-check values agree with the research report's figures to within a few percent;
  a large divergence is a finding to record before proceeding, not a number to average away.

---

### Phase 2: Pin the Equation-Lemma Numbering Behind Named Wrappers [COMPLETED]

**Goal**: Add one named wrapper theorem per rule in `Tableau.lean`, next to `applyRule`, so the
generator-assigned `eq_N` numbering appears exactly once per rule and an arm reorder breaks one
line instead of thirty-six.

**Tasks**:

- [x] For each rule, write a wrapper beside `applyRule` in
  `FormalSystem/Metalogic/Decidability/Tableau.lean`, of the shape
  `theorem applyRule_<rule>_eq (sf : SignedFormula) (b : Branch) (ord : TimeOrdering)
  (hs : sf.sign = Sign.pos) : applyRule .<rule> sf b ord = <rhs> := applyRule.eq_N sf b ord hs`,
  taking `<rhs>` and the exact hypothesis list verbatim from Phase 1's recorded equation-lemma
  types. Omit the sign hypothesis for the two sign-agnostic rules (`serialityRule`,
  `timeLinearity`). *(deviation: altered — each wrapper is stated as `theorem applyRule_<rule>_arm_eq : type_of% @applyRule.eq_N := @applyRule.eq_N`, i.e. at exactly the generated type, instead of a hand-copied `<rhs>`; a hand-copied right-hand side would duplicate the ~760-line definition and compile fresh matchers. The suffix is `_arm_eq`, not `_eq`, because `applyRule_boxNeg_eq` and `applyRule_diamondPos_eq` already exist in `MintBound/MintPotential.lean` with different statements. 38 wrappers, not 37: `z1Rule` has two arms (`applyRule_z1Rule_arm_eq` = eq_31, `applyRule_z1Rule_offPattern_eq` = eq_32).)*
- [x] Add a wrapper for the catch-all (`applyRule_offArm_eq` or similar) wrapping
  `applyRule.eq_38`, since all 36 conversions route their off-arm branch through it. *(completed — `applyRule_offArm_eq`)*
- [x] Write a short comment block above the wrappers stating what they are for: the `eq_N`
  numbering is generator-assigned and tracks arm order, so downstream proofs must name the
  wrapper, never the raw `eq_N`. *(completed)*
- [x] Do not change `applyRule`'s definition, its arm order, or any existing declaration in
  `Tableau.lean`. The 177 recorded `applyRule` references and the file's own `unfold applyRule`
  proofs must be untouched. *(deviation: altered — no declaration changed, but the file's long-file baseline `set_option linter.style.longFile` was raised 3200 -> 3300: the 146 added lines took the file to 3243 lines and the linter warned.)*
- [x] Commit per green sub-step: the wrappers can be landed and built in groups rather than all at
  once. *(deviation: altered — landed as one commit; the wrappers are one generated block verified together in scratch before the edit.)*

**Timing**: 2 hours

**Depends on**: 1

**Verification Tier**: interface

**Tier Justification**: This phase adds public declarations to `Tableau.lean`, whose four direct
importers span other modules, so the covering check is the `interface` row's build of the changed
module plus its enumerated direct dependents:
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Tableau`
followed by the same guarded invocation for each of
`FormalSystem.Metalogic.Decidability.Closure`, `FormalSystem.Metalogic.Decidability`,
`FormalSystem.Metalogic.Decidability.Verified.RuleSpec`, and
`FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty`.

**Scope Hypothesis**: This phase asserts 37 wrappers (36 rules plus the catch-all) and exactly
four direct importers of `Tableau.lean`. The importer list was derived at plan time by
`grep -rln 'import FormalSystem.Metalogic.Decidability.Tableau$' FormalSystem/`; re-run that grep
at implementation time rather than trusting this list, since a module added since plan authoring
would be invisible to it. The wrapper count follows Phase 1's confirmed equation-lemma count.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/Tableau.lean` - add 37 named wrapper theorems beside
  `applyRule`, plus the comment block explaining the numbering-pin discipline; no existing
  declaration changed

**Verification**:

- Every wrapper compiles; the guarded scoped build of
  `FormalSystem.Metalogic.Decidability.Tableau` exits 0 (read the verdict from the guard's own
  `result`, never a pipe exit code).
- Each of the four enumerated direct importers builds green under its own guarded scoped build.
- `git diff` on `Tableau.lean` shows only additions — no hunk touches `applyRule`'s body, its arm
  order, or any pre-existing declaration.
- A spot-check `lean_hover_info` on two wrappers confirms the stated type matches the
  corresponding `eq_N` type recorded in Phase 1.

---

### Phase 3: Convert the Propositional Section (Decision Gate) [COMPLETED]

**Goal**: Convert the eight `Propositional` bodies to wrapper-routed `eq_N` rewrites and establish
whether the conversion shape generalizes beyond the report's three probes. This phase is the
plan's decision gate: its measured result decides whether Phases 4 through 6 proceed as written.

**Tasks**:

- [x] Convert, in file order, `applyRule_andPos_closed`, `applyRule_andNeg_closed`,
  `applyRule_orPos_closed`, `applyRule_orNeg_closed`, `applyRule_impPos_closed`,
  `applyRule_impNeg_closed`, `applyRule_negPos_closed`, `applyRule_negNeg_closed`. *(completed — all eight converted)*
- [x] Use the report's verified sign-only shape as the template (`cases hs : sf.sign`, `rw` the
  wrapper, `split`, `rw [asX?_eq_iff]`, `simp only [RuleResult.emitted, …] at hg`, `rcases`,
  `exact`), routing the off-sign branch through the catch-all wrapper. For the two rules carrying
  a formula pattern (`impPos`, `impNeg`), add the `match hf : sf.formula with` and hoist a
  `have off : … → g.formula ∈ C` so the off-pattern branch is written once, not six times. *(deviation: altered — the case analysis is `by_cases hs : sf.sign = .pos` (resp. `.neg`) rather than `cases hs : sf.sign`, so the off-sign guards of the catch-all close by `intros; contradiction` with no simp call at all. For `impPos`/`impNeg` the analysis is a single `by_cases h : sf.sign = … ∧ ∃ ψ χ, sf.formula = .imp ψ χ` rather than `match hf : sf.formula with` plus a hoisted `have off`: one `by_cases` already makes the off-arm branch appear exactly once, and its guards close by `first | contradiction | exact h ⟨‹_›, _, _, ‹_›⟩`.)*
- [x] Prefer `simp only` with an explicit lemma list throughout; do not introduce a new
  `simp_all` or a full simp set. *(completed — no `simp_all` and no full simp set in any of the eight)*
- [x] Replace each converted theorem's `-- unfold applyRule reduces the 36-arm match …` comment
  with the measured attribution and the new heartbeat figure for that declaration. *(completed)*
- [x] Leave every `set_option maxHeartbeats` line in place — removal is Phase 8. *(completed)*
- [x] Record a `#count_heartbeats` after-figure for each of the eight into the Phase 1 evidence
  file's table, under `set_option Elab.async false`. *(completed — 1,356 to 1,515 heartbeats each)*
- [x] Per-rule fallback: if a rule resists conversion after a bounded attempt, leave its existing
  body and ceiling in place, record it in the evidence table with what was tried, and close this
  phase `[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record naming the rule and
  citing the failing goal state as Evidence. *(completed — no fallback needed; gate criterion met 8 of 8)*
- [x] Commit per green sub-step: one commit per converted theorem, or per small group that builds
  green together. *(deviation: altered — one commit for the eight, which were verified together in scratch and by one full build)*

**Timing**: 2 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: Every edit is confined to one file with no externally visible signature
change (the eight statements are byte-identical before and after), so the covering check is the
`local` row's single-module build:
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty`.

**Scope Hypothesis**: This phase asserts the `Propositional` section contains exactly eight
per-rule theorems, carried from the plan-time reading of the module's declaration list. Confirm by
counting `^theorem applyRule_.*_closed` between the `section Propositional` and `end
Propositional` lines before converting, and reconcile against Phase 1's total of 36.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` - rewrite the
  eight `Propositional` proof bodies and their per-theorem cost comments; statements, `set_option`
  lines, and every other section untouched
- `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md` - append
  the eight after-figures to the heartbeat table

**Verification**:

- The guarded scoped build of
  `FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty` exits 0, verdict
  read from the guard's own `result`.
- `git diff` confirms all eight statement lines are unchanged — only bodies and comments differ.
- Eight after-figures are recorded, each taken under `set_option Elab.async false`, each strictly
  below its Phase 1 baseline.
- **Gate criterion**: at least six of the eight converted without falling back to the existing
  body. Meeting it means Phases 4 through 6 proceed as written. Missing it means the conversion
  shape does not generalize; record the measured result, and treat the remaining conversion phases
  as candidates for `[COMPLETED WITH EXCLUSIONS]` under the per-rule fallback rather than pressing
  on against evidence.

---

### Phase 4: Convert the NonAnalytic and PersistentUniversal Sections [NOT STARTED]

**Goal**: Convert the four `NonAnalytic` and six `PersistentUniversal` bodies, including the two
most expensive theorems in the file (`serialityRule`, `timeLinearity`), which are sign-agnostic and
need no case analysis at all.

**Tasks**:

- [ ] Convert `applyRule_boxTemporal_closed`, `applyRule_denseIndicatorClosure_closed`,
  `applyRule_serialityRule_closed`, `applyRule_timeLinearity_closed` using the report's verified
  sign-agnostic shape for the latter two (no `cases`, no off-arm branch).
- [ ] Convert `applyRule_boxPos_closed`, `applyRule_diamondNeg_closed`,
  `applyRule_allFuturePos_closed`, `applyRule_allPastPos_closed`,
  `applyRule_someFutureNeg_closed`, `applyRule_somePastNeg_closed`.
- [ ] Rewrite the per-theorem cost comment for each converted theorem with the measured
  attribution and its new heartbeat figure.
- [ ] Leave every `set_option maxHeartbeats` line in place, including the two `3000000` ceilings.
- [ ] Record a `#count_heartbeats` after-figure for each of the ten into the evidence file's table,
  under `set_option Elab.async false`.
- [ ] Apply the same per-rule fallback and `#### Reasoned Exclusions` rule as Phase 3.
- [ ] Commit per green sub-step.

**Timing**: 2 hours

**Depends on**: 3

**Verification Tier**: local

**Tier Justification**: Same single-file, statement-preserving edit class as Phase 3, so the
covering check is again
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty`.

**Scope Hypothesis**: This phase asserts four theorems in `NonAnalytic` and six in
`PersistentUniversal` (ten total), carried from the plan-time reading of the module. Confirm by
counting `^theorem applyRule_.*_closed` between each section's `section`/`end` pair before
converting, and reconcile the running total against Phase 1's 36.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` - rewrite the
  ten `NonAnalytic` and `PersistentUniversal` proof bodies and their per-theorem cost comments
- `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md` - append
  the ten after-figures

**Verification**:

- The guarded scoped build of the module exits 0, verdict read from the guard's own `result`.
- `git diff` confirms all ten statement lines are unchanged.
- Ten after-figures recorded under `set_option Elab.async false`, each strictly below its Phase 1
  baseline. `serialityRule` and `timeLinearity` are the two largest baselines in the file; their
  reductions are the phase's headline numbers and must be stated explicitly, not folded into a
  total.

---

### Phase 5: Convert the FrameClass Section [NOT STARTED]

**Goal**: Convert the eight `FrameClass` bodies, including `z1Rule` (whose rule occupies two
equation slots) and `orderTrichotomy` (whose guard is branch-side and carries the `TrichClosed`
hypothesis).

**Tasks**:

- [ ] Convert `applyRule_priorUZ_closed`, `applyRule_priorSZ_closed`, `applyRule_z1Rule_closed`,
  `applyRule_priorUGap_closed`, `applyRule_priorSGap_closed`, `applyRule_sepRule_closed`,
  `applyRule_densityRule_closed`, `applyRule_orderTrichotomy_closed`.
- [ ] For `z1Rule`, route through both of its wrappers (the two arms recorded as `eq_31`/`eq_32` in
  Phase 1) rather than assuming one covers the rule; confirm against Phase 1's recorded types which
  arm each wrapper pins.
- [ ] For `denseIndicatorClosure` and `densityRule`, which carry literal formula patterns, use the
  hoisted `have off : …` off-pattern shape from Phase 3.
- [ ] Rewrite the per-theorem cost comment for each converted theorem.
- [ ] Leave every `set_option maxHeartbeats` line in place.
- [ ] Record `#count_heartbeats` after-figures for all eight under `set_option Elab.async false`.
- [ ] Apply the same per-rule fallback and `#### Reasoned Exclusions` rule as Phase 3.
- [ ] Commit per green sub-step.

**Timing**: 2 hours

**Depends on**: 4

**Verification Tier**: local

**Tier Justification**: Same single-file, statement-preserving edit class as Phase 3, so the
covering check is again
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty`.

**Scope Hypothesis**: This phase asserts eight theorems in `FrameClass`, and that `z1Rule` is the
one rule occupying two equation slots. Confirm the theorem count by the section-bounded grep used
in Phases 3 and 4; confirm the two-slot claim against Phase 1's recorded equation-lemma types
rather than against the research report's table.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` - rewrite the
  eight `FrameClass` proof bodies and their per-theorem cost comments
- `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md` - append
  the eight after-figures

**Verification**:

- The guarded scoped build of the module exits 0, verdict read from the guard's own `result`.
- `git diff` confirms all eight statement lines are unchanged, `orderTrichotomy`'s `TrichClosed`
  hypothesis included.
- Eight after-figures recorded under `set_option Elab.async false`, each strictly below its Phase 1
  baseline.

---

### Phase 6: Convert the FreshWitness Section [NOT STARTED]

**Goal**: Convert the ten `FreshWitness` bodies — the hardest shape in the file, each with a
formula pattern and one or two propagation blocks routed through `mem_filterMap_sub`.

**Tasks**:

- [ ] Re-verify `applyRule_boxNeg_closed` in place first. The research report's `boxNeg` probe left
  two unsolved goals, diagnosed there as a probe artifact: the probe's `open` made
  `Formula.subformulas` ambiguous, and the unmodified script failed identically in the same run. In
  the module there is no such ambiguity, so this is the conversion that confirms or refutes that
  diagnosis. If it refutes it, stop and record the finding before converting the other nine.
- [ ] Convert `applyRule_diamondPos_closed`, `applyRule_allFutureNeg_closed`,
  `applyRule_allPastNeg_closed`, `applyRule_someFuturePos_closed`,
  `applyRule_somePastPos_closed`, `applyRule_untlPos_closed`, `applyRule_sncePos_closed`,
  `applyRule_untlNeg_closed`, `applyRule_snceNeg_closed`.
- [ ] Leave the shared `mem_filterMap_sub` sub-proof block exactly as it is — tightening it is
  Phase 7, measured separately so the two reductions do not blur together.
- [ ] Keep `set_option linter.unusedTactic false` on `untlNeg` and `snceNeg` for now; whether the
  rewritten scripts still need it is decided in Phase 8.
- [ ] Rewrite the per-theorem cost comment for each converted theorem.
- [ ] Record `#count_heartbeats` after-figures for all ten under `set_option Elab.async false`.
- [ ] Apply the same per-rule fallback and `#### Reasoned Exclusions` rule as Phase 3.
- [ ] Commit per green sub-step.

**Timing**: 2 hours

**Depends on**: 5

**Verification Tier**: local

**Tier Justification**: Same single-file, statement-preserving edit class as Phase 3, so the
covering check is again
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty`.

**Scope Hypothesis**: This phase asserts ten theorems in `FreshWitness` and that all ten share the
`mem_filterMap_sub` propagation block, both carried from
`reports/01_cut-subformulaproperty-elaboration-time.md`. Confirm the count by the section-bounded
grep used in Phases 3 through 5, and confirm the shared-block claim by grepping
`mem_filterMap_sub` within the section bounds — a theorem that does not reference it is outside
Phase 7's blast radius and must be noted as such.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` - rewrite the
  ten `FreshWitness` proof bodies and their per-theorem cost comments; `mem_filterMap_sub` itself
  untouched
- `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md` - append
  the ten after-figures

**Verification**:

- The guarded scoped build of the module exits 0, verdict read from the guard's own `result`.
- `git diff` confirms all ten statement lines are unchanged and `mem_filterMap_sub`'s own body is
  not in the diff.
- Ten after-figures recorded under `set_option Elab.async false`, each strictly below its Phase 1
  baseline. `boxNeg`'s figure is expected to remain the largest of the ten, since its residual cost
  lives in the still-untouched `mem_filterMap_sub` block.
- The `boxNeg` in-place result is stated explicitly as confirming or refuting the research report's
  probe-artifact diagnosis.

---

### Phase 7: Tighten the Fresh-Witness Propagation Block [NOT STARTED]

**Goal**: Convert the `mem_filterMap_sub` sub-proof's full simp set to `simp only` with an explicit
lemma list, which the research report identifies as the dominant residual cost across the ten
fresh-witness theorems after conversion.

**Tasks**:

- [ ] Locate the `simp_all [SignedFormula.pos, SignedFormula.neg, Formula.subformulas,
  Formula.self_mem_subformulas]` call inside the `mem_filterMap_sub` entry point and the
  fresh-witness bodies that invoke it. Note which is a full simp set (`simp_all [...]`) versus an
  explicit list (`simp_all only [...]`) — the report counts 48 of the latter and 11 of the former
  file-wide, and only the former are this phase's targets within the fresh-witness family.
- [ ] Convert each targeted call to `simp only [...] at <hyp>` with an explicit lemma list derived
  from the actual goal state, not guessed. Use `lean_goal` before and after each conversion.
- [ ] Do not change `mem_filterMap_sub`'s statement.
- [ ] Record a `#count_heartbeats` after-figure for each of the ten fresh-witness theorems a second
  time, so Phase 6's and Phase 7's contributions are separately attributable in the evidence table.
- [ ] If a targeted call cannot be converted without changing which goals close, leave it as a full
  simp set, record the goal-state evidence, and close the phase `[COMPLETED WITH EXCLUSIONS]` with
  a `#### Reasoned Exclusions` record. R1's reduction already clears the acceptance bar without
  this phase.
- [ ] Commit per green sub-step.

**Timing**: 1 hour

**Depends on**: 6

**Verification Tier**: local

**Tier Justification**: `mem_filterMap_sub` is a private helper used only within this module and
its statement is unchanged, so the covering check is the `local` row's single-module build:
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty`.

**Scope Hypothesis**: This phase asserts that `mem_filterMap_sub`'s full-simp-set block is the
dominant residual cost after Phase 6, carried from
`reports/01_cut-subformulaproperty-elaboration-time.md`'s R3 finding (which rests on `boxNeg`'s
27,178-heartbeat post-conversion figure). Confirm against Phase 6's ten measured after-figures
before doing the work: if the fresh-witness figures are already negligible, this phase's premise
has evaporated and it closes `[COMPLETED WITH EXCLUSIONS]` citing those figures. Also confirm
`mem_filterMap_sub` is used by all ten and by nothing outside the module
(`grep -rn 'mem_filterMap_sub' FormalSystem/`).

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` - convert the
  fresh-witness family's full-simp-set calls to explicit `simp only` lists; `mem_filterMap_sub`'s
  statement untouched
- `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md` - append
  the second round of fresh-witness after-figures, attributed to this phase

**Verification**:

- The guarded scoped build of the module exits 0, verdict read from the guard's own `result`.
- `git diff` confirms `mem_filterMap_sub`'s statement line is unchanged.
- Ten second-round after-figures recorded under `set_option Elab.async false`, each at or below its
  Phase 6 figure, with this phase's own contribution separately stated.

---

### Phase 8: Remove the Heartbeat Ceilings and Correct the Section Notes [NOT STARTED]

**Goal**: Delete the 34 `maxHeartbeats 1200000` and two `maxHeartbeats 3000000` lines so the module
compiles at the 200,000 default — independent, reviewable proof the reduction is real — and replace
the remaining module-level and section-level comments that still assert the wrong cost attribution.

**Tasks**:

- [ ] Delete every `set_option maxHeartbeats` line in the module, except on any declaration left
  unconverted under a per-rule fallback in Phases 3 through 7 (those keep their ceiling, and the
  exclusion record says so).
- [ ] Decide `set_option linter.unusedTactic false` on `untlNeg` and `snceNeg` by removing it and
  rebuilding: keep it only if the rewritten scripts still trip the linter.
- [ ] Replace the `Propositional` section's opening note (currently: "Each case unfolds the
  900-line `applyRule` match; the default heartbeat budget is not enough for the `whnf` work that
  costs, while the *memory* ceiling is what forces one rule per declaration") with the measured
  attribution.
- [ ] Replace the `NonAnalytic` section note asserting that `whnf` has to step past every earlier
  arm.
- [ ] Sweep the module for any surviving copy of the `-- unfold applyRule reduces the 36-arm
  match … about 0.9M heartbeats measured` comment and the `whnf` cost claim. The replacement text
  states what the profiler measured (`simp` 99.2 percent, all tactic execution 0.7 percent) and
  that the bodies now rewrite with pinned equation lemmas.
- [ ] Add a short note recording that the memory ceiling, not elaboration time, is what still
  forces one rule per declaration — that claim is independent of this task's finding and must not
  be deleted along with the wrong ones.
- [ ] Commit per green sub-step.

**Timing**: 1 hour

**Depends on**: 7

**Verification Tier**: local

**Tier Justification**: Removing a `set_option` and rewriting comments can only fail inside this
one module and changes no signature, so the covering check is the `local` row's single-module
build at the restored default budget:
`bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty`.

**Scope Hypothesis**: This phase asserts 34 `maxHeartbeats 1200000` lines, two `maxHeartbeats
3000000` lines, 36 copies of the misleading per-theorem comment, and one `NonAnalytic` section
note — all carried from `reports/01_cut-subformulaproperty-elaboration-time.md`. Confirm each by
grep against the working tree at the start of this phase (Phases 3 through 6 will already have
replaced the per-theorem comments, so the surviving count should be zero or the count of
fallback rules); a nonzero residue outside the fallback set is a missed edit, not a miscount.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` - delete all
  `set_option maxHeartbeats` lines (except on fallback declarations), resolve the two
  `linter.unusedTactic` options, and rewrite the `Propositional` and `NonAnalytic` section notes
  plus any surviving per-theorem cost comment

**Verification**:

- The guarded scoped build of the module exits 0 with no `maxHeartbeats` option present, verdict
  read from the guard's own `result`. This is the phase's primary evidence: compiling at the
  200,000 default is the reduction, stated independently of any heartbeat table.
- `grep -n 'maxHeartbeats' <module>` returns only lines on declarations named in a
  `#### Reasoned Exclusions` record, or nothing at all.
- `grep -n 'whnf\|0.9M heartbeats' <module>` returns no surviving wrong-attribution comment.
- The memory-ceiling claim survives in the rewritten notes; `git diff` confirms it was not deleted
  alongside the elaboration-time claims.

---

### Phase 9: Final Gate and Evidence Report [NOT STARTED]

**Goal**: Run the complete gate set, confirm every acceptance criterion with recorded evidence, and
assemble the before/after report.

**Tasks**:

- [ ] Run the full unscoped guarded build:
  `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build`, reading the verdict
  from the guard's own `result`.
- [ ] Run `bash scripts/check-module-invariants.sh` and require `ALL CHECKS PASSED` with exit
  status 0 — this is the repository's aggregate Lean gate and covers `lake build` exit 0 (C1), the
  `#print axioms` baseline for the flagship theorems (C2), zero structural `sorry` asserted by
  content (C3), and import resolution (C4).
- [ ] Re-capture `#print axioms` for all 37 declarations in the module plus the 37 new wrappers,
  and diff against Phase 1's recorded profiles. Any difference for any declaration fails this
  phase; `check-module-invariants.sh` C2 pins only the flagship theorems, so this per-declaration
  diff is a separate, non-redundant obligation.
- [ ] Confirm `sorry` count is zero in both edited files, asserted by content.
- [ ] Run `bash .claude/scripts/check-task-references.sh` over the two edited `.lean` deliverables
  and require exit status 0 — neither may carry a task-number reference, and the rewritten comments
  are the realistic place one would have crept in. Check the exit status, not only the output text.
- [ ] Run a fresh `-Dprofiler=true -Dprofiler.threshold=200` single-module profile through the
  guard and record the new `cumulative profiling times` block beside Phase 1's, with the machine
  context stated.
- [ ] Assemble the evidence file into its final form: the per-declaration before/after heartbeat
  table (37 rows, or fewer with the fallback set named), the two cumulative profiling blocks, the
  axiom-profile diff result, and the removed-ceiling fact.
- [ ] Record the aggregate reduction as a measured figure with its method named, never as a
  projection. The research report's "roughly 36M to roughly 0.4M" is a projection and must be
  labelled as such if it appears at all.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts 37 module declarations plus 37 wrappers (74 axiom
profiles to diff) and two edited `.lean` files. Both counts are inherited from Phases 1 and 2 as
confirmed there, not re-carried from the research report; re-derive them from the working tree
before the diff — count `^theorem applyRule_.*_closed` plus `applyRule_subformula_closed` in the
module, count the added wrappers in `Tableau.lean`, and take the edited-file list from
`git diff --name-only` against the task's base commit rather than from this plan. A declaration
left unconverted under a per-rule fallback still owes its axiom profile, so the diff set is 74
regardless of how many conversions landed.

**Files to modify**:

- `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md` -
  finalize into the complete before/after evidence record

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build` green, verdict from the
  guard's `result`.
- `bash scripts/check-module-invariants.sh` prints `ALL CHECKS PASSED` and exits 0.
- Per-declaration `#print axioms` diff against Phase 1 is empty for all 37 module declarations and
  the 37 wrappers.
- `sorry` count zero in both edited files, asserted by content.
- `bash .claude/scripts/check-task-references.sh` exits 0 over both edited `.lean` files.
- The evidence file carries a complete before/after heartbeat table and both cumulative profiling
  blocks, with the measured aggregate reduction stated and its method named.
- No `.claude/**` path and no source-store path is touched by this task, so `verify-deploy.sh`'s
  deploy gates have no surface here; the gate set named above is the complete applicable set for
  this task's two `.lean` deliverables and its `specs/**` evidence file. State this explicitly in
  the summary rather than leaving the omission unexplained.

---

## Lean Challenge Statements

This plan introduces **no new proved statement**, so the Challenge identifier set is empty, matching
the `- **Goals**:` block above, which names no identifiers. The 36 per-rule theorems and
`applyRule_subformula_closed` already exist and must survive byte-identical; the 37 wrappers added
in Phase 2 are `rfl`-style aliases whose right-hand sides are generator-produced and therefore not
determinable at plan-authoring time. Statement fidelity here is enforced by the unchanged-signature
check in every phase's verification and by the per-declaration axiom-profile diff in Phase 9, not
by a pinned Challenge module.

```lean
import FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty
-- Intentionally empty: this task changes proof bodies only. See the note above.
```

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Tableau` green (Phase 2).
- [ ] Guarded scoped build of each of `Tableau.lean`'s four direct importers green (Phase 2).
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty` green at the end of each of Phases 3 through 8.
- [ ] The same scoped build green with no `set_option maxHeartbeats` present (Phase 8).
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build` green (Phase 9).
- [ ] `bash scripts/check-module-invariants.sh` prints `ALL CHECKS PASSED`, exit 0 (Phase 9).
- [ ] Per-declaration `#print axioms` diff empty across all 37 module declarations and 37 wrappers (Phase 9).
- [ ] `sorry` count zero in both edited files, asserted by content (Phase 9).
- [ ] `bash .claude/scripts/check-task-references.sh` exits 0 over both edited `.lean` files (Phase 9).
- [ ] Every `#count_heartbeats` figure in the evidence file was taken with `set_option Elab.async false`.
- [ ] Every one of the 36 per-rule statements and `applyRule_subformula_closed`'s statement is byte-identical to its pre-change form.

## Artifacts & Outputs

- `specs/803_cut_subformulaproperty_elaboration_time/plans/01_cut-subformulaproperty-elaboration-time.md` (this file)
- `specs/803_cut_subformulaproperty_elaboration_time/evidence/01_elaboration-baseline.md` (before/after measurement record)
- `specs/803_cut_subformulaproperty_elaboration_time/summaries/01_cut-subformulaproperty-elaboration-time-summary.md` (at completion)
- Modified: `FormalSystem/Metalogic/Decidability/Tableau.lean` (37 added wrapper theorems)
- Modified: `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` (36 rewritten proof bodies, corrected comments, removed ceilings)

## Rollback/Contingency

Every phase commits per green sub-step, so the ordinary recovery is `git revert` of the specific
commits for the phase that regressed — no working-tree discard, and the per-phase commit
granularity means a single bad conversion costs one commit, not the whole task.

- **A single rule resists conversion**: do not revert. Use the per-rule fallback built into each
  conversion phase — leave that rule's existing body and ceiling in place, record it in the
  evidence table, and close the phase `[COMPLETED WITH EXCLUSIONS]` with a
  `#### Reasoned Exclusions` record. A measured reduction over the converted subset still satisfies
  the acceptance bar.
- **Phase 3's gate criterion fails** (fewer than six of eight converted cleanly): the conversion
  shape does not generalize. Stop, record the measured result, and treat Phases 4 through 6 under
  the same exclusion mechanism rather than pressing on. The landed Phase 2 wrappers are additive
  and harmless, so they need no revert.
- **Phase 7's premise evaporates** (fresh-witness figures already negligible after Phase 6): close
  it `[COMPLETED WITH EXCLUSIONS]` citing Phase 6's own measurements as Evidence.
- **The axiom-profile diff in Phase 9 is non-empty**: this is the one hard failure. Bisect by
  reverting conversion-phase commits until the diff clears, since an axiom change can only have
  come from a specific rewritten body.
- **Before any rollback that would discard uncommitted work**: follow
  `context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation shape,
  including its out-of-scope override flag. Never discard uncommitted changes to reach a passing
  build — fix forward instead.
