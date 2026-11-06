# Implementation Plan: colourClock history bridge lemma

- **Task**: 860 - colourclock_history_bridge_lemma
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: None (no research report for this task; grounding re-derived at plan time
  by direct reads of `FormalSystem/Semantics/Frames/TranslationProduct.lean`,
  `FormalSystem/Semantics/TaskFrame.lean`, `FormalSystem/Semantics/PartialHistory.lean` and
  `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean`)
- **Artifacts**: plans/01_colourclock-history-bridge-lemma.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Compile the "every colour function is a history" step that `colourFibre`'s docstring currently
only states. Three layers: a `@[simp]` `colourClock_taskRel` bridge in `TranslationProduct.lean`
(the gap that blocked the step — `translationProduct` states such a bridge, `colourClock` does
not); a history constructor over `colourClock` taking a colour function and a clock offset, plus
the clock-shape lemma that makes the correspondence two-way; and, at `colourFibre` in
`OpenFutureUndefinable.lean`, the marker valuation and the compiled `hmarkers` discharge, applied
through a fixed-model variant of the reduction theorem so the enough-worlds condition becomes an
application rather than a hypothesis.

### Research Integration

No research report exists for this task. Plan-time reads established four load-bearing facts,
each cited by declaration name rather than `file:line`:

- `FrameOver.ofReflective` sets `WorldState := W` outright, so `(colourClock R …).WorldState` is
  `W × ↑D` definitionally and a history's state may be written as a literal pair — exactly as
  `liftH` already does for `FrameOver.translationProduct`.
- `FrameOver.ofReflectiveRegular_taskRel` is the generic bridge; `colourClock` never states its
  specialization, while `FrameOver.translationProduct_taskRel` does. That asymmetry, not a deep
  obstruction, is what left the step uncompiled.
- `WorldHistory.ofTotal F f h` with `h : ∀ s t, F.TaskRel (f s) (t - s) (f t)` is the sanctioned
  total-history constructor, and `WorldHistory.ext_state` the extensionality principle.
- `TaskFrame.Serial R` reads `∀ w x, 0 ≤ x → (∃ u, R w x u) ∧ (∃ v, R v x w)`. At `x = 0` its
  first conjunct plus `h0 : ∀ w u, R w 0 u → u = w` yields `R w 0 w`, which is the only fact the
  free-colour-function case needs beyond freeness itself.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

`specs/ROADMAP.md` lists this work in the L^▷ exploration stage, off both critical paths, and
directs re-pointing its scope at the landed Independence module before dispatch. This plan
follows that direction: the consumer is
`FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean`, not the probe file named in the
task description, whose content has since landed in that module.

## Goals & Non-Goals

**Goals**:

- `colourClock_taskRel` -- the `@[simp]` task-relation bridge `colourClock` is missing.
- `colourClock_clock_eq` -- the clock along any `colourClock` history is time plus a constant.
- `colourClock.ofColourFun`, `colourClock.ofColourFun_state` -- the history constructor from a
  colour function and a clock offset, with its state simp lemma.
- `colourClock.ofFreeColourFun`, `colourClock.ofFreeColourFun_state` -- the free-relation
  specialization in which the coherence hypothesis is discharged, so *every* colour function is a
  history.
- `markerValuation`, `markerModel` -- the intended valuation at `colourFibre`: `p` reads the
  first colour bit, `m` the second, every other atom false.
- `colourFibre.ofColourFun`, `colourFibre_hmarkers` -- the enough-worlds condition at
  `colourFibre` under `markerModel`, compiled.
- `ofut_not_plusDefinable_of_deltaProp_inexpressible_at` -- the fixed-model variant of the
  reduction theorem, whose `hmarkers` is required only at the one model `hinexpr` ranges over.
- `colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible` -- the reduction at
  `colourFibre` with `hmarkers` discharged by application, leaving `hinexpr` the single
  remaining hypothesis.

**Non-Goals**:

- Reopening the verdict (open-future not L⁺-definable at Base and Dense). It is settled on the
  written report and untouched here.
- Formalizing `hinexpr`. It stays the paper step of record.
- Editing `ofut_not_plusDefinable_of_deltaProp_inexpressible` itself. It is pinned by C14 and
  cited in `docs/theorem-index.md`; the fixed-model form is added beside it, not substituted for
  it.
- Updating `specs/859_qtime_open_future_definability_base_dense/probes/01_ofut-marker-gadget-and-nondefinability.lean`.
  Its content landed in `OpenFutureUndefinable.lean`, which is where the ROADMAP directs the
  scope; the probe is another task's specs artifact and stays as written.
- A round-trip theorem (`liftH_projH`'s analogue) at `colourClock`. `colourClock_clock_eq`
  supplies the only half the `hmarkers` discharge consumes.

## Correction Required by This Work

`ofut_not_plusDefinable_of_deltaProp_inexpressible`'s docstring, and `colourFibre`'s, both assert
that `hmarkers` "holds at `colourFibre D` for every temporal order `D`". Read against the literal
hypothesis, which quantifies over **every** `TaskModel` of the frame, that is false: a valuation
sending `markerAtom` to `False` at every state refutes it, since no history then carries the
marker future. The claim is true under the *intended* valuation only. This is why the plan adds
`markerModel` and a fixed-model variant rather than discharging the existing all-models
hypothesis, and why both docstrings must be corrected in Phase 3 rather than merely having
"stated, not compiled" struck from them.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `colourClock_taskRel` will not close by `FrameOver.ofReflectiveRegular_taskRel` because `colourClock`'s body introduces `Nonempty ↑D` via a local `haveI`, so the synthesized `Nonempty (W × ↑D)` at the statement site need not be syntactically the instance baked into the definition | H | M | Ladder, in order: (a) open the proof with the same `haveI : Nonempty ↑D := ⟨0⟩` before `exact FrameOver.ofReflectiveRegular_taskRel`; (b) `show (FrameOver.ofReflectiveRegular (W × ↑D) (prodRel R) … ).TaskRel a x b ↔ _` to force the elaborated head to match; (c) bypass the instance-keyed lemma entirely with `TaskFrame.reflect_restrict_iff (prodRel_reflection R hR)`, which `ofReflectiveRegular_taskRel` is itself defined as. `FrameOver.translationProduct_taskRel` closes by route (a)-equivalent means in the same file, so at least one rung is expected to land |
| If all three rungs fail, the only remaining fix is making `colourClock` take `[Nonempty ↑D]` as an instance argument, which changes its signature and `colourFibre`'s call site | H | L | That is an `interface`-class change outside this plan's decomposition. Per `.claude/rules/plan-compliance.md`, mark Phase 1 `[BLOCKED]` and escalate rather than substituting it |
| A new `@[simp]` lemma keyed on `colourClock` perturbs downstream proofs | M | L | The LHS head is `colourClock`, so it can only fire where that constant appears. Phase 1 enumerates the dependent set mechanically with `grep -rl 'colourClock\|colourFibre' FormalSystem/` and builds each hit |
| `dataAtom` and `markerAtom` must be provably distinct for `markerValuation` to read the two bits independently | M | M | Both are `Atom.mkBase` of distinct string literals; prove the disequality as a named `@[simp]` lemma in Phase 3 and feed it to the valuation's simp set, rather than relying on `decide` inside each proof |
| The C14 baseline pair is compared by exact string equality and in matching order | M | M | Phase 4 adds the `#print axioms` line to `C14LEAN` and the matching `'…' depends on axioms: …` line to `C14_BASELINE` at the *same relative position*, immediately after the existing `colourFibre_isRegular` entries in both heredocs, and re-runs `scripts/check-module-invariants.sh` to confirm |
| Sibling tasks are dispatched on the same working tree this cycle (889, 881, 837) | M | M | 889 and 881 declare disjoint file scopes; 837 declares none. Re-read each target file immediately before editing, stage only this task's own files by explicit path, and treat a build failure outside this plan's file list as possibly a sibling's in-flight edit |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is a single chain: each phase
consumes the declarations the previous one lands.

---

### Phase 1: The `colourClock` task-relation bridge [COMPLETED]

**Goal**: Give `colourClock` the `@[simp]` task-relation bridge that `translationProduct` already
has, so its task relation can be read off without unfolding the constructor.

**Tasks**:
- [x] Re-read `FormalSystem/Semantics/Frames/TranslationProduct.lean` around `colourClock` and
      `colourClock_isRegular` immediately before editing (sibling-concurrency discipline).
- [x] Add `colourClock_taskRel` directly after `colourClock_isRegular`, inside `section Bare`,
      with the signature pinned in `## Lean Challenge Statements` below.
- [x] Prove it, working the mitigation ladder in Risks in order; stop at the first rung that
      closes and record in the phase notes which rung was needed. *(no rung needed: a bare
      `FrameOver.ofReflectiveRegular_taskRel` term closed it, as `translationProduct_taskRel`
      does; the `haveI`, `show` and `reflect_restrict_iff` rungs were not reached)*
- [x] Add a docstring in the style of `FrameOver.translationProduct_taskRel`'s, noting that
      `ofReflective_taskRel` is deliberately not `@[simp]` and that each frame states its own
      bridge.
- [x] Add `colourClock_taskRel` to the `## Main Results` list in the module docstring.
- [x] Enumerate the dependent set: `grep -rl 'colourClock\|colourFibre' FormalSystem/`
      *(three Lean modules: `Semantics/Frames/TranslationProduct.lean`,
      `Metalogic/Independence/OpenFutureUndefinable.lean`, `Metalogic/Independence.lean`;
      two README.md files are prose only. Scope Hypothesis confirmed.)*
- [x] Build `FormalSystem.Semantics.Frames.TranslationProduct` and each enumerated dependent
      module, confirming no new error or warning.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: interface

**Tier Justification**: the edit introduces a new `@[simp]` lemma, whose rewrite surface reaches
every importer, so the covering check is `bash .claude/scripts/lake-build-guard.sh build
--timeout 1800 -- build FormalSystem.Semantics.Frames.TranslationProduct` followed by one guarded
build per module returned by `grep -rl 'colourClock\|colourFibre' FormalSystem/`.

**Scope Hypothesis**: the dependent set is expected to be small -- `TranslationProduct.lean` plus
`OpenFutureUndefinable.lean` and the aggregator modules that import them. Confirm at
implementation time by running the `grep -rl` above and building every path it returns; do not
assume the two-module figure.

**Files to modify**:
- `FormalSystem/Semantics/Frames/TranslationProduct.lean` - add `colourClock_taskRel` and its
  `## Main Results` entry

**Verification**:
- `colourClock_taskRel` elaborates with no `sorry`, error, or warning.
- The guarded scoped build of `FormalSystem.Semantics.Frames.TranslationProduct` exits 0.
- Every module named by `grep -rl 'colourClock\|colourFibre' FormalSystem/` builds green.

---

### Phase 2: Histories of `colourClock` from colour functions [COMPLETED]

**Goal**: Compile "a colour function with a clock offset is a history of `colourClock`", in a
general form carrying an explicit coherence hypothesis and a free-relation form in which that
hypothesis is discharged, together with the clock-shape lemma the `hmarkers` discharge needs.

**Tasks**:
- [x] Add a `/-! ### Histories of the colour clock -/` subsection after `colourClock_taskRel`.
- [x] Add `colourClock_zero_self`: `R w 0 w`, from `(hS w 0 le_rfl).1` and `h0`.
- [x] Add `colourClock_clock_eq`: for any `τ : WorldHistory (colourClock R hR hC hS h0).toTaskFrame`,
      `(τ.state t).2 = (τ.state 0).2 + t`, by `colourClock_taskRel` on `τ.respects_task 0 t`
      followed by `sub_zero` -- the direct analogue of `clock_eq`.
- [x] Add `colourClock.ofColourFun` via `WorldHistory.ofTotal _ (fun t => (f t, c + t))`,
      discharging the obligation with `colourClock_taskRel` plus `hf s t` and the abelian-group
      identity `c + t = (c + s) + (t - s)` (`abel`, as `liftH` does).
- [x] Add `@[simp] colourClock.ofColourFun_state`, proved by `rfl`.
- [x] Add `colourClock.ofFreeColourFun`, defined as `ofColourFun` with the coherence hypothesis
      supplied: `fun s t => if h : t - s = 0 then (by rw [h, sub_eq_zero.mp h]; exact
      colourClock_zero_self …) else hfree _ _ _ h` -- the zero case closing through
      `colourClock_zero_self` and `sub_eq_zero`, the nonzero case through `hfree`.
- [x] Add `@[simp] colourClock.ofFreeColourFun_state`, proved by `rfl`.
- [x] Add docstrings to each, and the five new names to the module docstring's
      `## Main Definitions` / `## Main Results` lists as appropriate.
- [x] Build the module.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: every declaration added here is new, with a head constant
(`colourClock.ofColourFun`, `colourClock.ofFreeColourFun`) that no existing proof can mention, so
nothing outside the edited module can be perturbed and `bash
.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Semantics.Frames.TranslationProduct` is the covering check.

**Scope Hypothesis**: six new declarations are asserted for this phase
(`colourClock_zero_self`, `colourClock_clock_eq`, `colourClock.ofColourFun`,
`colourClock.ofColourFun_state`, `colourClock.ofFreeColourFun`,
`colourClock.ofFreeColourFun_state`). Confirm at implementation time against the pinned
signatures in `## Lean Challenge Statements`; if a helper proves unnecessary or a seventh is
needed, record the deviation rather than silently adjusting the count.

**Files to modify**:
- `FormalSystem/Semantics/Frames/TranslationProduct.lean` - add the colour-function history
  subsection and its module-docstring entries

**Verification**:
- All six declarations elaborate with no `sorry`, error, or warning.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Frames.TranslationProduct`
  exits 0.
- `#print axioms` on `colourClock.ofFreeColourFun` reports no axiom beyond
  `[propext, Classical.choice, Quot.sound]`.

---

### Phase 3: `hmarkers` compiled at `colourFibre` [COMPLETED]

**Goal**: Define the intended marker valuation at `colourFibre`, discharge the enough-worlds
condition at it by applying Phase 2's constructor, and expose a reduction theorem at
`colourFibre` whose only remaining hypothesis is `hinexpr`.

**Tasks**:
- [x] Re-read `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` immediately before
      editing.
- [x] Beside `ofut_not_plusDefinable_of_deltaProp_inexpressible`, in the same `{F : TaskFrame}`
      variable scope, add `ofut_not_plusDefinable_of_deltaProp_inexpressible_at`: the fixed-model
      variant whose `hmarkers` and `hinexpr` are both stated at one given `M`. Its proof is the
      existing four-line proof with `M` fixed. Leave the existing theorem untouched.
- [x] In `section WitnessFrame`, add `markerAtom_ne_dataAtom` as a `@[simp]` disequality.
- [x] Add `markerValuation : MarkerColour × ↑D → Atom → Prop` reading the first bit at
      `dataAtom`, the second at `markerAtom`, and `False` elsewhere, and `markerModel` wrapping
      it as a `TaskModel (colourFibre D).toTaskFrame`.
- [x] Add `cRel_free`: `cRel (D := D) w d u` for `d ≠ 0`, immediate from `cRel`'s definition.
- [x] Add `colourFibre.ofColourFun` as `colourClock.ofFreeColourFun` instantiated at `cRel`, and
      `@[simp] colourFibre.ofColourFun_state`.
- [x] Add `colourFibre_hmarkers`: given `τ` and `t` with `¬ holds (markerModel D) τ t markerAtom`
      *(deviation: altered — the hypothesis BINDER is named `_hm`, not `hm`. Its TYPE is exactly
      as pinned in `## Lean Challenge Statements`, and the proposition proved is unchanged; the
      hypothesis is genuinely unused, since a marker-future witness exists at every `(τ, t)` of
      this frame, and Lean's `unusedVariables` linter emitted a `warning:` on `hm` that the
      phase's own "no warning" criterion forbids. Recorded as a deviation because the plan pins
      the signature text verbatim.)*,
      take `ρ := colourFibre.ofColourFun (fun s => if s ≤ t then (τ.state s).1
      else ((τ.state s).1.1, true)) ((τ.state 0).2)`. `AgreeUpTo` follows from
      `colourClock_clock_eq` at `colourFibre` plus the `if` branch; the marker-future conjunct is
      the second bit being `true` on the other branch.
- [x] Add `colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible`, applying
      `ofut_not_plusDefinable_of_deltaProp_inexpressible_at` at `markerModel D` with
      `colourFibre_hmarkers` supplied.
- [x] Correct both docstrings per `## Correction Required by This Work`: in
      `ofut_not_plusDefinable_of_deltaProp_inexpressible`'s, say that the condition holds at
      `colourFibre D` *under the marker valuation* `markerModel`, now compiled as
      `colourFibre_hmarkers`, and that the all-models form it states is strictly stronger and
      false at a valuation that never makes `m` true; in `colourFibre`'s, strike "stated rather
      than compiled here" and cite `colourFibre_hmarkers`.
- [x] Update the module docstring's bullet lists with the new names.
- [x] Build the module.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: the one new `@[simp]` lemma heads on `markerAtom`/`dataAtom`
disequality and the two `_state` lemmas head on brand-new constants, and no existing signature
changes, so `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Metalogic.Independence.OpenFutureUndefinable` covers the edit.

**Scope Hypothesis**: this phase asserts that `ofut_not_plusDefinable_of_deltaProp_inexpressible`
needs no edit to its statement or proof, only to its docstring. Confirm at implementation time by
checking that `ofut_not_plusDefinable_of_deltaProp_inexpressible_at` elaborates independently and
that the original declaration's `#print axioms` output is unchanged from the C14 baseline line
already recorded for it.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` - fixed-model reduction
  variant, marker valuation and model, `colourFibre` history constructor, `colourFibre_hmarkers`,
  the discharged reduction at `colourFibre`, and the two docstring corrections

**Verification**:
- All new declarations elaborate with no `sorry`, error, or warning.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence.OpenFutureUndefinable`
  exits 0.
- `#print axioms FormalSystem.Metalogic.Independence.colourFibre_hmarkers` and the same on
  `colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible` both report
  `[propext, Classical.choice, Quot.sound]` or a subset.
- Neither corrected docstring still contains the phrase "stated rather than compiled" or an
  unqualified "holds at `colourFibre D` for every temporal order".

---

### Phase 4: Index rows, C14 pinning, and the full gate [COMPLETED WITH EXCLUSIONS]

**Goal**: Earn the ledger rows for the two results worth pinning, wire their axiom baselines, and
close the task on the complete gate set.

**Tasks**:
- [x] Add two rows to `docs/theorem-index.md`, beside the existing `colourFibre_isRegular` row:
      one for `FormalSystem.Metalogic.Independence.colourFibre_hmarkers` (the enough-worlds
      condition at the four-colour clock frame under the marker valuation, compiled), one for
      `FormalSystem.Metalogic.Independence.colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible`
      (the reduction at `colourFibre` with the enough-worlds condition discharged, conditional on
      `hinexpr` alone). Both rows carry `—` in the Paper label column, `Base` is not the right
      Frame class here since both are class-generic over `D`, so use `—`.
- [x] Do not overstate: neither row may read as an unconditional non-definability verdict.
      `hinexpr` stays named as the remaining unformalized hypothesis in the second row's
      statement cell.
- [x] Add the matching `#print axioms` lines to the `C14LEAN` heredoc in
      `scripts/check-module-invariants.sh`, immediately after the existing
      `FormalSystem.Metalogic.Independence.colourFibre_isRegular` line.
- [x] Add the matching `'…' depends on axioms: …` lines to the `C14_BASELINE` heredoc at the same
      relative position, with the values measured in Phase 3 -- not guessed.
- [x] Extend the explanatory comment above the baseline (the paragraph naming
      `ofut_not_plusDefinable_of_deltaProp_inexpressible` and `colourFibre_isRegular`) to cover
      the two new entries.
- [x] Run `bash scripts/check-module-invariants.sh` and confirm C2, C14 and C20 pass.
      *(deviation: altered — C2, C14, C20 and C26 all pass, but the script EXITS 1 on a
      pre-existing, out-of-scope C16 `unusedArguments` finding on
      `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean:2136`, which is sibling
      task 889's own declared subject and territory. Two in-scope gate failures WERE found and
      fixed: a `simpNF` linter abort on `colourClock_taskRel` and four stale generated README
      inventory blocks, repaired with `--emit-inventory`. See the Reasoned Exclusions table.)*
- [x] Run the full unscoped guarded build and confirm exit 0 with no `sorry`, error, or warning.
- [x] Run the complete gate set: `bash .claude/scripts/verify-deploy.sh` *(deviation: deferred
      — the dispatch directive for this cycle replaces this phase's full tier with a scoped tier
      and defers the complete set to the batch stage. See the Reasoned Exclusions table.)*
- [x] Commit each green sub-step by explicit file path, never a directory or glob pathspec.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `docs/theorem-index.md` - two new ledger rows
- `scripts/check-module-invariants.sh` - two `C14LEAN` entries, two `C14_BASELINE` entries, and
  the extended narrative comment

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0, with no
  `sorry`, error, or warning anywhere in the output.
- `bash scripts/check-module-invariants.sh` exits 0, with C2, C14 and C20 all reported passing.
- `bash .claude/scripts/verify-deploy.sh` -- the complete gate set this repository aggregates --
  exits 0. No gate is narrowed by `--only-gate` and `--skip-slow` is not used: this is the
  plan's final phase and the full set is owed here.
- `grep -rn 'sorry' FormalSystem/Semantics/Frames/TranslationProduct.lean FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean`
  returns nothing outside prose.


#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `bash .claude/scripts/verify-deploy.sh` complete gate set | The dispatch directive for this cycle replaces this phase's `**Verification Tier**: full` with a SCOPED tier and defers the complete set to the batch stage, where it runs once for the whole batch and is attributed back by `modified_files`. Separately, no `verify-deploy.sh` gate and no `run-all.sh` suite covers ANY file this task touched: all are under `FormalSystem/`, `docs/`, `scripts/` or `typst/`, while those two harnesses check the deployed `.claude/` tree against `agent-system/extensions/` and run the agent system's own shell suites. A narrowing `--only-gate`/`--only` invocation would therefore have been a no-op rather than evidence. | The gates that DO cover these files were run: full guarded `lake build` (exit 0, 2957 jobs, zero `error:`, zero `warning:`), `scripts/check-module-invariants.sh` (C1 `lake build` and `lake build BimodalTest`, C2, C3 zero sorries, C14, C20, C26 all pass), `lake exe runLinter FormalSystem.Semantics.Frames.TranslationProduct` (passed), `scripts/typst-sync-check.sh --fix` (PASS). |
| `scripts/check-module-invariants.sh` exit 0 | Held at 1 by a PRE-EXISTING C16 `unusedArguments` finding on `LadderChain.lean:2136` (`mem_cellAt_of_shift_of_hasForwardSlack`, argument 23), outside this task's file scope and inside sibling task 889's. Clearing it would mean editing that file or `scripts/nolints.json`, both of which are 889's declared territory. | `LadderChain.lean` has a clean working tree and its last commit is task 850's, three commits before this task's first; the finding is absent from `scripts/nolints.json`; sibling 889 is `ladderchain_c16_unusedarguments_clear` with exactly that file scope. Every check this task's own files reach passes. |
| `simpNF` conformance of `colourClock_taskRel` | Batteries' `simpNF` env_linter adds every Prop-valued non-instance hypothesis of the lemma under test to the simp set by design (`simp [*]`, so a conditional simp lemma can apply to itself). This lemma's `hR` is the reflection condition `R w d u ↔ R u (-d) w`, an unconditional rewrite loop once `neg_neg` closes the cycle, so the linter aborts on maximum recursion depth without ever reaching a normal-form verdict. The declaration cannot conform while `colourClock` takes its four presentation conditions as explicit arguments, and `isCondition` exempts only instance-implicit binders. Resolved by the repository's documented permanent-exemption route rather than by weakening the pinned `@[simp]` statement. | `@[simp, nolint simpNF]` with the full reason at the attribute site plus a `scripts/nolint-attribute-allowlist.txt` entry; `lake exe runLinter FormalSystem.Semantics.Frames.TranslationProduct` then passes and C26 reports all 9 in-source `nolint` pairs allowlisted. |

---

## Lean Challenge Statements

```lean
import FormalSystem

namespace FormalSystem.Semantics

variable {D : TemporalOrder} {W : Type} (R : W → ↑D → W → Prop)

@[simp] theorem colourClock_taskRel [Finite W] [Nonempty W]
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (hC : TaskFrame.Compositional R)
    (hS : TaskFrame.Serial R) (h0 : ∀ w u, R w 0 u → u = w)
    (a : W × ↑D) (x : ↑D) (b : W × ↑D) :
    (colourClock R hR hC hS h0).TaskRel a x b ↔ R a.1 x b.1 ∧ b.2 = a.2 + x := sorry

theorem colourClock_zero_self (hS : TaskFrame.Serial R)
    (h0 : ∀ w u, R w 0 u → u = w) (w : W) : R w 0 w := sorry

theorem colourClock_clock_eq [Finite W] [Nonempty W]
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (hC : TaskFrame.Compositional R)
    (hS : TaskFrame.Serial R) (h0 : ∀ w u, R w 0 u → u = w)
    (τ : WorldHistory (colourClock R hR hC hS h0).toTaskFrame) (t : ↑D) :
    (τ.state t).2 = (τ.state 0).2 + t := sorry

def colourClock.ofColourFun [Finite W] [Nonempty W]
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (hC : TaskFrame.Compositional R)
    (hS : TaskFrame.Serial R) (h0 : ∀ w u, R w 0 u → u = w)
    (f : ↑D → W) (c : ↑D) (hf : ∀ s t : ↑D, R (f s) (t - s) (f t)) :
    WorldHistory (colourClock R hR hC hS h0).toTaskFrame := sorry

@[simp] theorem colourClock.ofColourFun_state [Finite W] [Nonempty W]
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (hC : TaskFrame.Compositional R)
    (hS : TaskFrame.Serial R) (h0 : ∀ w u, R w 0 u → u = w)
    (f : ↑D → W) (c : ↑D) (hf : ∀ s t : ↑D, R (f s) (t - s) (f t)) (t : ↑D) :
    (colourClock.ofColourFun R hR hC hS h0 f c hf).state t = (f t, c + t) := sorry

def colourClock.ofFreeColourFun [Finite W] [Nonempty W]
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (hC : TaskFrame.Compositional R)
    (hS : TaskFrame.Serial R) (h0 : ∀ w u, R w 0 u → u = w)
    (hfree : ∀ w (d : ↑D) u, d ≠ 0 → R w d u) (f : ↑D → W) (c : ↑D) :
    WorldHistory (colourClock R hR hC hS h0).toTaskFrame := sorry

@[simp] theorem colourClock.ofFreeColourFun_state [Finite W] [Nonempty W]
    (hR : ∀ w d u, R w d u ↔ R u (-d) w) (hC : TaskFrame.Compositional R)
    (hS : TaskFrame.Serial R) (h0 : ∀ w u, R w 0 u → u = w)
    (hfree : ∀ w (d : ↑D) u, d ≠ 0 → R w d u) (f : ↑D → W) (c : ↑D) (t : ↑D) :
    (colourClock.ofFreeColourFun R hR hC hS h0 hfree f c).state t = (f t, c + t) := sorry

end FormalSystem.Semantics

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Semantics MarkerGadget

variable {F : TaskFrame}

theorem ofut_not_plusDefinable_of_deltaProp_inexpressible_at (M : TaskModel F)
    (hmarkers : ∀ (τ : WorldHistory F) (t : F.Duration),
      ¬ holds M τ t markerAtom →
        ∃ ρ : WorldHistory F, AgreeUpTo τ ρ t ∧ ∀ s, t < s → holds M ρ s markerAtom)
    (hinexpr : ∀ ψ : PlusFormula, ∃ (τ : WorldHistory F) (t : F.Duration),
      ¬ holds M τ t markerAtom ∧ ¬ (DeltaProp M τ t ↔ PlusTruthAt M τ t ψ)) :
    ¬ OfutPlusDefinable F := sorry

section WitnessFrame

variable {D : TemporalOrder}

@[simp] theorem markerAtom_ne_dataAtom : markerAtom ≠ dataAtom := sorry

def markerValuation : MarkerColour × ↑D → Atom → Prop :=
  fun s a => (a = dataAtom ∧ s.1.1 = true) ∨ (a = markerAtom ∧ s.1.2 = true)

def markerModel (D : TemporalOrder) : TaskModel (colourFibre D).toTaskFrame :=
  { valuation := markerValuation }

theorem cRel_free (w : MarkerColour) (d : ↑D) (u : MarkerColour) (hd : d ≠ 0) :
    cRel (D := D) w d u := sorry

def colourFibre.ofColourFun (f : ↑D → MarkerColour) (c : ↑D) :
    WorldHistory (colourFibre D).toTaskFrame := sorry

@[simp] theorem colourFibre.ofColourFun_state (f : ↑D → MarkerColour) (c t : ↑D) :
    (colourFibre.ofColourFun f c).state t = (f t, c + t) := sorry

theorem colourFibre_hmarkers (τ : WorldHistory (colourFibre D).toTaskFrame) (t : ↑D)
    (hm : ¬ holds (markerModel D) τ t markerAtom) :
    ∃ ρ : WorldHistory (colourFibre D).toTaskFrame, AgreeUpTo τ ρ t ∧
      ∀ s, t < s → holds (markerModel D) ρ s markerAtom := sorry

theorem colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible
    (hinexpr : ∀ ψ : PlusFormula,
      ∃ (τ : WorldHistory (colourFibre D).toTaskFrame) (t : ↑D),
        ¬ holds (markerModel D) τ t markerAtom ∧
          ¬ (DeltaProp (markerModel D) τ t ↔ PlusTruthAt (markerModel D) τ t ψ)) :
    ¬ OfutPlusDefinable (colourFibre D).toTaskFrame := sorry

end WitnessFrame

end FormalSystem.Metalogic.Independence
```

These signatures are the contract. `markerValuation` and `markerModel` are given with bodies
because they are definitional choices rather than proof obligations; every other body is `sorry`
and is the implementation's work. Two signatures carry known elaboration risk and may need
adjustment at implementation time, which must be raised as a deviation rather than silently
applied: `colourClock_zero_self`'s `W` may require `[Nonempty W]` if the `variable` block's
instance binders are positioned differently than assumed, and `markerAtom_ne_dataAtom` may need
to be stated as `¬ (markerAtom = dataAtom)` depending on how `Atom.mkBase` injectivity is
exposed.

## Testing & Validation

- [x] Each phase's scoped guarded build exits 0, with no `sorry`, error, or warning.
- [x] The full unscoped guarded build exits 0 at Phase 4.
- [ ] `bash scripts/check-module-invariants.sh` exits 0 with C2, C14 and C20 passing, after the
      baseline pair is extended. *(deviation: altered — C2, C14, C20 and C26 pass and the
      baseline pair is extended, but the script exits 1 on a pre-existing out-of-scope C16
      finding in sibling task 889's territory. See Phase 4's Reasoned Exclusions.)*
- [ ] `bash .claude/scripts/verify-deploy.sh` exits 0 at Phase 4. *(deviation: deferred — the
      dispatch directive defers the complete gate set to the batch stage, and no gate of it
      covers any file this task touched. See Phase 4's Reasoned Exclusions.)*
- [x] Every new declaration's measured `#print axioms` value matches what the C14 baseline
      records for it -- measured, never transcribed from another declaration.
- [x] `docs/theorem-index.md` gains exactly two rows, neither of which claims an unconditional
      non-definability verdict.

## Artifacts & Outputs

- `FormalSystem/Semantics/Frames/TranslationProduct.lean` - `colourClock_taskRel`,
  `colourClock_zero_self`, `colourClock_clock_eq`, `colourClock.ofColourFun`,
  `colourClock.ofColourFun_state`, `colourClock.ofFreeColourFun`,
  `colourClock.ofFreeColourFun_state`
- `FormalSystem/Metalogic/Independence/OpenFutureUndefinable.lean` -
  `ofut_not_plusDefinable_of_deltaProp_inexpressible_at`, `markerAtom_ne_dataAtom`,
  `markerValuation`, `markerModel`, `cRel_free`, `colourFibre.ofColourFun`,
  `colourFibre.ofColourFun_state`, `colourFibre_hmarkers`,
  `colourFibre_ofut_not_plusDefinable_of_deltaProp_inexpressible`, plus two docstring corrections
- `docs/theorem-index.md` - two ledger rows
- `scripts/check-module-invariants.sh` - two C14 baseline entries, two `C14LEAN` entries, extended
  narrative comment
- `specs/860_colourclock_history_bridge_lemma/summaries/01_colourclock-history-bridge-lemma-summary.md`
  - implementation summary

## Rollback/Contingency

Every phase is additive: the only non-additive edits are the two docstring corrections in Phase 3
and the baseline-heredoc insertions in Phase 4. Reverting a phase therefore means deleting its
new declarations and restoring the two docstrings and the two heredoc insertions.

Take a durable, non-reverting checkpoint before Phase 3 and Phase 4 with
`bash .claude/scripts/git-snapshot.sh 860 --no-revert`; that form records the working tree
without touching it, which is what concurrent sibling dispatches on this same tree require.

If a genuine rollback becomes necessary -- a Phase 4 baseline edit that cannot be reconciled, for
instance -- follow `context/contracts/recovery.md`'s rollback rung for the exact
snapshot-then-revert invocation shape, including its out-of-scope override flag; do not improvise
a `git reset`/`git checkout` on a dirty tree.

If Phase 1's mitigation ladder is exhausted without closing `colourClock_taskRel`, no rollback is
needed: nothing has landed. Mark Phase 1 `[BLOCKED]`, record which rungs were tried and the exact
unification error, and escalate per `.claude/rules/plan-compliance.md` rather than changing
`colourClock`'s signature.
