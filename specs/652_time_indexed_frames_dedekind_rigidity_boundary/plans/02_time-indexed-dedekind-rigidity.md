# Implementation Plan: Task #652

- **Task**: 652 - Define time-indexed task frames and prove the Dedekind-completeness rigidity boundary, with a compiled ℚ counterexample
- **Status**: [COMPLETED]
- **Effort**: 5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/652_time_indexed_frames_dedekind_rigidity_boundary/reports/01_time-indexed-dedekind-rigidity.md` (plus its two compiled-green probes under `probes/`)
- **Artifacts**: plans/02_time-indexed-dedekind-rigidity.md (this file), summaries/02_time-indexed-dedekind-rigidity-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Turn the `Rigidity.lean` scope note into theorems. Two new flat `Semantics/` modules are added:
`TimeIndexed.lean` carries the time-indexed frame structure at report 05's field names (shared
infrastructure the MF Theorem A will consume) together with the positive theorem — over a densely
ordered, Dedekind-complete time order, a time-indexed frame with finitely many states satisfying
*Limit* has only constant histories — and `TimeIndexedSharpness.lean` carries the two-state ℚ
witness that switches across `√2`, refuting both `Static` and `ConstantHistories`, plus the
duration-vs-time comparison docstring. The mathematics is already discovered and machine-checked:
the research probes elaborate with zero errors, zero warnings, and standard axioms only, so this
plan is transcription, hardening against `--wfail`, and gate wiring. Done means `lake build --wfail`
green, `check-module-invariants.sh` all-pass, `lake exe mk_all --lib FormalSystem --check` exit 0,
and `lean_verify` reporting no `sorryAx` on the two pinned theorems.

### Research Integration

The report supplies the module siting (R1), the structure verbatim at report 05's names (R2), the
positive theorem and its `IsLUB`-not-topology proof shape (R3), the ℚ witness (R4), the optional ℤ
witness (R5), the comparison table (R6), and the seven-item wiring checklist (R7). Three research
findings are load-bearing for phase design and are carried forward explicitly:

- **`linarith` is unavailable on `↑D`** (an ordered abelian group, not a field). Every inequality
  step in the positive theorem is an explicit `sub_lt_comm` / `sub_lt_iff_lt_add'` / `sub_neg` /
  `abs_sub_lt_iff` / `lt_add_of_pos_right` invocation. Copy the probe body; do not re-derive.
- **`--wfail` promotes two style linters to errors** on the natural draft: `linter.style.show`
  (a `show` that changes the goal must be `change`) and `linter.unusedSimpArgs`. The probes already
  use `change` and carry no unused simp argument; do not reintroduce either.
- **The positive theorem delivers `ConstantHistories`, not relation-level `Static`.** This is a
  correction to the task description's gloss "has only constant histories, i.e. is static", reported
  rather than silently weakened — see *Correction Carried Forward* below.

### Correction Carried Forward

The task description says the positive theorem shows the frame "has only constant histories, i.e.
is static". Those are two different claims and only the first is reachable without transposing the
whole `Semantics/Extension/` chain to absolute times (report 05 sizes that at ~1000 lines and does
not recommend it). The `Rigidity.lean` scope note itself says only "force constant histories" and is
therefore **accurate as written**; it is the task description's gloss that overshoots. This plan
states `constantHistories_of_lub` as the positive theorem and, rather than leaving the gap silent,
adds `static_of_lub_of_realized`, which reaches `Static` from two named, explicit extra hypotheses
(a reflexivity law and a realization law `R w x y u → ∃ τ ∈ Hist, τ x = w ∧ τ y = u`). The missing
ingredient thereby becomes a documented hypothesis instead of an absence.

### Prior Plan Reference

No prior plan. This is artifact round 2; round 1 produced the research report and probes only.

### Roadmap Alignment

No `roadmap_path` was provided in the dispatch context and no roadmap consultation was requested.

## Goals & Non-Goals

- **Goals**: `exists_uniform_radius_of_finite`, `locally_constant_of_finite`,
  `constantHistories_of_lub`, `static_of_lub_of_realized`
- **Goals (not challenge-pinned)**: the `TimeIndexed` structure and its predicate family (`Hist`,
  `Limit`, `Compositional`, `Serial`, `Converse`, `Static`, `ConstantHistories`, `Stationary`, `P`);
  the whole of `TimeIndexedSharpness.lean` (`belowCut`, `cut_not_rat`, `belowCut_mono`,
  `one_belowCut`, `two_not_belowCut`, `exists_radius`, `switchRel`, `qSwitchFrame`, the four
  condition theorems, `qSwitchFrame_not_static`, `switchHist`, `switchHist_mem`,
  `qSwitchFrame_not_constantHistories`) and the optional ℤ witness; the comparison docstring; the
  aggregator, README, generated-root, theorem-index and C14-baseline plumbing; the `Rigidity.lean`
  scope-note replacement. These are excluded from the challenge block because each depends on a
  `def` or `structure` whose body the snapshot matcher would erase.
- **Non-Goals**: Theorem A itself (report 05's R4, over ℤ-time); any `P = R` / Theorem A′
  transposition; any edit to `FormalSystem/Semantics/ShiftSet.lean`; any edit to `Rigidity.lean`
  beyond replacing its scope note with a cross-reference; any topology import or `OrderTopology`
  instance; any `ConditionallyCompleteLinearOrder` instance on a `TemporalOrder` carrier; a
  Saturation analogue; importing `Metalogic.Independence.rat_not_complete` into `Semantics/`; any
  hand edit to the generated `FormalSystem.lean`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer reaches for `linarith`/`omega` on `↑D` and stalls | H | M | `↑D` is an ordered abelian group, not a field. Transcribe the probe's explicit inequality lemmas verbatim from `probes/01_positive_theorem.lean` |
| `--wfail` turns `linter.style.show` / `linter.unusedSimpArgs` warnings into build failures | M | M | Use `change`, never `show`, where the goal changes; keep `simp_all [belowCut_mono hxy, belowCut_mono hyz]` at exactly two arguments (a third `belowCut_mono (hxy.trans hyz)` is flagged unused) |
| C14 baseline pair drifts out of order; exact-string comparison fails with a confusing diff | M | M | Add the two `#print axioms` lines and the two baseline rows at the same relative position, immediately after the existing `static_iff_uniformDwell` / `static_of_finite` rows, in one edit per heredoc |
| Siting the ℚ witness where `Metalogic/` can see it, creating a cycle with `rat_not_complete` | H | L | `Semantics/` never imports `Metalogic/`. Cite `rat_not_complete` in prose only; add no import for it |
| `Mathlib.NumberTheory.Real.Irrational` lands on the shared-infrastructure module and burdens the future Theorem A dependency path | M | M | Two-module split: the analysis import lives only in `TimeIndexedSharpness.lean` |
| `lake build --wfail` on a root-imported module is slow; a foreground build blocks the dispatch | M | H | Run detached per `context/project/lean4/operations/long-builds.md` and `context/patterns/bounded-build-waiter.md` — hard timeout, `kill -0` liveness on the captured PID, one waiter per log |
| A concurrent sibling task (655) edits the shared tree mid-build | M | M | Territory contract: re-read before editing, stage only this task's own hunks with explicit file lists, never a directory/glob `git add`, never `git-snapshot.sh` in reverting default mode; a failure outside this task's file scope may be a sibling's in-flight edit — check `git log` and report rather than "fixing" it |
| Report 05's field names (`W` / `nonempty` / `R`) get "corrected" to `FrameOver`'s (`WorldState` / `worldNonempty` / `PosRel`) | M | L | The divergence is deliberate and mandated, so R4 consumes the structure unchanged. Record the reason in the module docstring |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

### Phase 1: TimeIndexed.lean — structure, predicates, positive theorem [COMPLETED]

**Goal**: Create `FormalSystem/Semantics/TimeIndexed.lean` carrying the time-indexed frame
structure at report 05's field names and the Dedekind positive theorem, elaborating clean under
`--wfail` with standard axioms only.

**Tasks**:
- [x] Create `FormalSystem/Semantics/TimeIndexed.lean` with the Apache header block, then
      `import FormalSystem.Semantics.TaskFrame` and `import Mathlib.Algebra.Order.Group.Bounds`,
      then the `/-! ... -/` module docstring immediately after the imports (header-linter order).
- [x] Module docstring content: what a time-indexed frame is and how it differs from `FrameOver`;
      that the field names are report 05's and deliberately **not** `FrameOver`'s, so the MF
      frame-correspondence Theorem A consumes the structure unchanged; that Theorem A is the other
      intended consumer of this module; a pointer to `TimeIndexedSharpness.lean` for the comparison
      and the ℚ witness. Cite the manuscript by label or quotable phrase, never by line number.
      No task numbers anywhere in the file.
- [x] Declare `structure TimeIndexed (D : TemporalOrder)` with fields `W : Type`,
      `[nonempty : Nonempty W]`, `R : W → ↑D → ↑D → W → Prop`.
- [x] Declare the predicate family as `def`s on `TimeIndexed D` (matching the bare-relation-predicate
      idiom `TaskFrame.Compositional` / `Serial` / `Interpolates` already uses): `Hist`, `Limit`,
      `Compositional`, `Serial`, `Converse`, `Static`, `ConstantHistories`, `Stationary`, `P`.
      `Stationary` and `P` carry no theorem here; they exist because report 05 states Theorem A in
      terms of them. Say so in their docstrings.
- [x] Prove `exists_uniform_radius_of_finite`, transcribed from
      `probes/01_positive_theorem.lean` (contrapositive of `Limit` per state, then `Finset.inf'`
      over `univ`). Uses `push Not`, not `push_neg`.
- [x] Prove `locally_constant_of_finite` — instantiate the previous at `w := τ t`, feed it `hτ t s`.
- [x] Prove `constantHistories_of_lub` with the `IsLUB` sup argument, transcribed verbatim. No
      topology, no `ConditionallyCompleteLinearOrder` instance: Dedekind completeness enters as the
      repository's Prop-valued `h_lub` binder per `DurationClassification.lean`'s stated convention.
- [x] Prove `static_of_lub_of_realized` from `constantHistories_of_lub` plus the two named extra
      hypotheses (see *Correction Carried Forward*); ~4 lines.
- [x] Give each of the four theorems a `/-- -/` docstring carrying a `Paper: — (reason)` line in
      `Rigidity.lean`'s style (C15's second assertion), and record in the
      `constantHistories_of_lub` docstring the hypotheses the proof does **not** use:
      Compositionality, Seriality, Saturation, the converse convention, unboundedness, topology.
- [x] Build the module alone and confirm zero errors and zero warnings; run `#print axioms` on
      `constantHistories_of_lub` and confirm `[propext, Classical.choice, Quot.sound]`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: this phase is estimated at ~110 lines in exactly one new file,
`FormalSystem/Semantics/TimeIndexed.lean`, with no edit to any existing file. Confirm at
implementation time with `wc -l` on the created file and `git status --short` showing exactly one
untracked path; if either diverges (in particular if an existing file needed editing), record the
divergence in the progress file before proceeding.

*Scope-hypothesis outcome*: file count confirmed (exactly one new file, no existing file edited),
line count diverged — 298 lines against the ~110 estimate. The excess is entirely module- and
declaration-level docstring prose (the shared-infrastructure rationale, the not-consumed-hypothesis
record, and the two-hypothesis gap note the plan's *Correction Carried Forward* mandates); the Lean
content matches the probe line for line.

**Files to modify**:
- `FormalSystem/Semantics/TimeIndexed.lean` - new file (structure, nine predicate `def`s, four
  theorems)

**Verification**:
- `lake build FormalSystem.Semantics.TimeIndexed` (detached per the long-builds pattern) exits 0
  with no warnings under the repository's `--wfail` lint settings
- `#print axioms FormalSystem.Semantics.TimeIndexed.constantHistories_of_lub` reports
  `[propext, Classical.choice, Quot.sound]`; no `sorryAx`
- `grep -n "sorry" FormalSystem/Semantics/TimeIndexed.lean` returns nothing
- No occurrence of `linarith`, `omega`, or a goal-changing `show` in the file

---

### Phase 2: TimeIndexedSharpness.lean — the ℚ witness and the comparison [COMPLETED]

**Goal**: Create `FormalSystem/Semantics/TimeIndexedSharpness.lean` with the two-state ℚ frame
switching across `√2`, all four time-indexed frame conditions, refutations of both `Static` and
`ConstantHistories`, and the duration-vs-time comparison docstring (deliverable 4).

**Tasks**:
- [x] Create the file with the Apache header, `import FormalSystem.Semantics.TimeIndexed` and
      `import Mathlib.NumberTheory.Real.Irrational`, then the module docstring immediately after.
- [x] Module docstring: the `RigiditySharpness.lean`-style narrative, plus the 4-row comparison
      table (ℤ / ℚ ×ₗ ℚ / ℚ / ℝ against dense, Archimedean, Dedekind, duration-indexed outcome,
      time-indexed outcome) from the research report's R6. Call out the ℚ row as the entire point:
      it is the one order where the two boundaries disagree. State why in one sentence with
      `archimedean_of_lub` cited — over a duration *group* Dedekind completeness implies the
      Archimedean property, so the time-indexed hypothesis is strictly stronger; the duration-indexed
      proof chops a duration into finitely many sub-durations (Archimedean plus Compositionality)
      whereas the time-indexed proof has no duration to chop and must close a gap in the time line
      (Dedekind, no Compositionality). Cite `Metalogic.Independence.rat_not_complete` in prose as
      the order-level companion of this frame-level witness — **no import**; `Semantics/` never
      imports `Metalogic/`.
- [x] Also record in the docstring the mechanism `exists_radius` encodes: the dwell exists at every
      rational time but is not uniform in time — the radius returned at `x` shrinks to `0` as `x`
      approaches `√2`. That is exactly why `Limit` holds while rigidity fails.
- [x] Transcribe `belowCut`, `cut_not_rat`, `belowCut_mono`, `one_belowCut`, `two_not_belowCut`,
      `exists_radius` from `probes/02_rat_witness.lean`. `exists_radius` needs
      `rw [Rat.cast_abs, Rat.cast_sub]` before `exact_mod_cast` — plain `push_cast` does not reach
      inside `|·|` here.
- [x] Transcribe `switchRel` in its already-converse-symmetric shape (not forward-relation plus a
      reflection convention) and define `qSwitchFrame : TimeIndexed (TemporalOrder.of ℚ)` with
      `W := Bool`, `R := switchRel`. Use `TemporalOrder.of ℚ`, not a fresh `⟨ℚ⟩` bundler.
- [x] Prove `qSwitchFrame_converse`, `qSwitchFrame_serial`, `qSwitchFrame_limit`,
      `qSwitchFrame_compositional`. The compositional proof is `by_cases`×3, `cases w <;> cases v`,
      then `simp_all [belowCut_mono hxy, belowCut_mono hyz]` — exactly two simp arguments.
- [x] Prove `qSwitchFrame_not_static`; define `switchHist` (noncomputable, `open Classical in`),
      prove `switchHist_mem` and `qSwitchFrame_not_constantHistories`.
- [x] Add a `Paper: — (reason)` line to the `/-- -/` docstring of
      `qSwitchFrame_not_constantHistories` (it becomes a theorem-index row in Phase 4) and to any
      other declaration this phase puts on the ledger.
- [x] Rename probe identifiers to the library names throughout: `qSwitch` → `qSwitchFrame` and the
      `qSwitch_*` theorems → `qSwitchFrame_*`.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: this phase is estimated at ~140 lines in exactly one new file,
`FormalSystem/Semantics/TimeIndexedSharpness.lean`, with no edit to any existing file. Confirm with
`wc -l` and `git status --short`; record any divergence before proceeding.

**Files to modify**:
- `FormalSystem/Semantics/TimeIndexedSharpness.lean` - new file (cut predicate and its lemmas, the
  witness frame, six condition/refutation theorems, the comparison docstring)

**Verification**:
- `lake build FormalSystem.Semantics.TimeIndexedSharpness` exits 0, no warnings
- `#print axioms FormalSystem.Semantics.TimeIndexed.qSwitchFrame_not_constantHistories` reports
  `[propext, Classical.choice, Quot.sound]`
- `grep -n "sorry" FormalSystem/Semantics/TimeIndexedSharpness.lean` returns nothing
- `grep -n "Metalogic" FormalSystem/Semantics/TimeIndexedSharpness.lean` shows the prose citation
  only, never an `import` line
- The module docstring contains the 4-row comparison table and names both `√2`-over-ℚ and
  `ℚ ×ₗ ℚ` witnesses side by side

---

### Phase 3: The ℤ witness closing the sharpness square [COMPLETED]

**Goal**: Witness the `[DenselyOrdered ↑D]` hypothesis of the positive theorem, so that both of its
hypotheses are witnessed — the discipline `RigiditySharpness.lean` already follows for its own
theorem's two hypotheses.

**Tasks**:
- [x] Append to `FormalSystem/Semantics/TimeIndexedSharpness.lean` a second witness over
      `TemporalOrder.of ℤ`: `W = Bool`, relation
      `w = u ∨ (w = false ∧ u = true ∧ x < 0 ∧ 0 ≤ y) ∨ (the converse disjunct)`.
- [x] Prove its `Limit` (cheaply: `|s - t| < 1` forces `s = t` over ℤ) and that its switching
      history is non-constant, so the frame is not static. *(deviation: altered — `omega` and a
      flexible `simp` both failed on the carrier `↑(TemporalOrder.of ℤ)`, whose order and group
      instances are bundle projections that neither tactic matches syntactically; `omega` is now
      run on a `∀ a b : ℤ` helper and the history-membership proof is explicit `if_pos`/`if_neg`
      case work, which also clears the `linter.flexible` warning that `--wfail` would promote)*
- [x] Add a docstring sentence and a comparison-table cross-reference: ℤ is Dedekind-complete but
      not densely ordered, so density is the hypothesis this witness shows cannot be dropped, while
      the ℚ witness shows the same for Dedekind completeness.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: estimated at ~25 additional lines in the single existing file
`FormalSystem/Semantics/TimeIndexedSharpness.lean`. Confirm with `git diff --stat` on that one path.

**Files to modify**:
- `FormalSystem/Semantics/TimeIndexedSharpness.lean` - append the ℤ witness section

**Verification**:
- `lake build FormalSystem.Semantics.TimeIndexedSharpness` exits 0, no warnings, no `sorry`

**Contingency**: this phase is **additive and droppable**. The research report records it as the
planner's call and it affects no acceptance criterion. If it costs materially more than its estimate
or fights the `TemporalOrder.of ℤ` instance path, close it `[COMPLETED WITH EXCLUSIONS]` with the
reason recorded and continue to Phase 5 — nothing downstream depends on it beyond one optional
README/table cell.

---

### Phase 4: Replace the Rigidity.lean scope note with a cross-reference [COMPLETED]

**Goal**: Discharge the standing `## Scope note: time-indexed frames` section in
`Rigidity.lean`, replacing the "proved nowhere" note with a pointer to the two new modules.

**Tasks**:
- [x] Re-read `FormalSystem/Semantics/Correspondence/Rigidity.lean` immediately before editing
      (concurrent-sibling territory rule).
- [x] Replace the body of the `## Scope note: time-indexed frames` section with a cross-reference
      naming `FormalSystem.Semantics.TimeIndexed.constantHistories_of_lub` and
      `FormalSystem.Semantics.TimeIndexed.qSwitchFrame_not_constantHistories`, and the two module
      paths.
- [x] **Keep the phrase "force constant histories"**; do not upgrade it to "static". The note was
      accurate as written and the positive theorem concludes `ConstantHistories`, not `Static`.
      Mention `static_of_lub_of_realized` as the conditional relation-level corollary and name its
      extra hypotheses.
- [x] Add no import to `Rigidity.lean` — the cross-reference is prose only, so no new edge enters
      the import graph.
- [x] Confirm no other change to the file: this is the one edit to `Rigidity.lean` the task permits.

**Timing**: 0.25 hours

**Depends on**: 2

**Verification Tier**: prose

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/Rigidity.lean` - module docstring scope-note section only

**Verification**:
- `git diff FormalSystem/Semantics/Correspondence/Rigidity.lean` shows changed hunks lying entirely
  within the `/-! ... -/` module docstring, and nothing outside the scope-note section
- The diff contains no `import` line and no declaration change
- The replacement text contains the phrase "constant histories" and does not claim "static" of the
  positive theorem

---

### Phase 5: Gate wiring — aggregator, README, root, theorem index, C14 pins [COMPLETED]

**Goal**: Wire both new modules into every gate the repository enforces, so the full check suite
can run green.

**Tasks**:
- [x] `FormalSystem/Semantics.lean`: add `import FormalSystem.Semantics.TimeIndexed` and
      `import FormalSystem.Semantics.TimeIndexedSharpness`, and a `## Submodules` prose bullet for
      each, matching the existing bullets' register. *(deviation: altered — only the `TimeIndexed`
      import was added. Importing `TimeIndexedSharpness` here routes
      `Mathlib.NumberTheory.Real.Irrational`, and with it
      `Int.instConditionallyCompleteLinearOrder`, into every module downstream of this aggregator;
      `Metalogic/Decidability/Verified/Bridge/Embed.lean`'s `finOrderEmbInt` then elaborates
      through that instance and fails to compile as a computable definition. This was caught by
      the full `--wfail` build, not predicted. Both prose bullets are present and the excluded
      import is documented at the bullet and in the witness module's own `## Import discipline`
      section. The generated root imports the module directly, so reachability (C6), the INV row
      and the C14 pin are all unaffected — the root is a leaf and nothing inherits its instance
      environment.)*
- [x] `FormalSystem/Semantics/README.md`: add one `| File | Description |` row per module in the
      layering order (not alphabetical). The block is registered
      `<!-- INVENTORY: hand-maintained (dir=FormalSystem/Semantics) -->`, so edit the rows by hand;
      the `INV` check asserts a row for every live file and no row for anything else. Only if the
      check reports the block as generated does `bash scripts/check-module-invariants.sh
      --emit-inventory` apply (the old `readme-inventory.sh` is a deprecated shim).
- [x] Regenerate the library root: `lake exe mk_all --lib FormalSystem`. **Never hand-edit**
      `FormalSystem.lean`.
- [x] `docs/theorem-index.md`: add two rows, modelled on the two existing `Rigidity.lean` rows at
      the same location — one for `FormalSystem.Semantics.TimeIndexed.constantHistories_of_lub`,
      one for `FormalSystem.Semantics.TimeIndexed.qSwitchFrame_not_constantHistories`, each with
      `Paper: —` and `Axioms: pcq pinned:C14`.
- [x] `scripts/check-module-invariants.sh`: add the two `#print axioms` lines to the `C14LEAN`
      heredoc **and** the two matching `'…' depends on axioms: [propext, Classical.choice,
      Quot.sound]` rows to the `C14_BASELINE` heredoc, both immediately after the existing
      `static_iff_uniformDwell` / `static_of_finite` entries. The two heredocs are compared by
      **exact string equality** and must stay in the same order — edit each heredoc in a single
      edit so no intermediate half-updated state is committed.
- [x] Confirm C15's second assertion is satisfied: each newly ledger-listed declaration's own
      `/-- -/` block carries a `Paper: — (reason)` line (added in Phases 1-2; verify, do not
      re-add).
- [x] C24 needs no action: both modules reach `FormalSystem.Init` through `Semantics.TaskFrame`.
- [x] Re-read each shared file immediately before editing it and stage only this task's own hunks
      with an explicit file list — never `git add -A`, `git add .`, or a directory/glob pathspec.

**Timing**: 1 hour

**Depends on**: 3, 4

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts a five-file wiring set — `FormalSystem/Semantics.lean`,
`FormalSystem/Semantics/README.md`, `FormalSystem.lean` (generated), `docs/theorem-index.md`,
`scripts/check-module-invariants.sh` — and that the README inventory block is hand-maintained rather
than generated. Confirm both at implementation time: `git status --short` should show exactly these
five paths (plus the two new modules from Phases 1-3), and the `INV` check's own verdict decides the
hand-maintained question. If `check-module-invariants.sh` names a sixth gated file, add it and record
the divergence rather than skipping the gate.

*Scope-hypothesis outcome*: confirmed. `git status --short` showed exactly the five wiring paths
plus the two new modules and the `specs/**` artifacts; no sixth gated file appeared. The README
block is hand-maintained as asserted, so the rows were edited by hand and no `--emit-inventory`
run applied. `lake exe mk_all --lib FormalSystem` added the two root imports and exits non-zero
when it rewrites the file, which is its update convention, not a failure. The five-file set held,
but the aggregator's content diverged from the plan: see the deviation annotation on the first
checklist item.

**Files to modify**:
- `FormalSystem/Semantics.lean` - two imports plus two `## Submodules` bullets
- `FormalSystem/Semantics/README.md` - two inventory rows
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`, never hand-edited
- `docs/theorem-index.md` - two rows with C14 pins
- `scripts/check-module-invariants.sh` - two `C14LEAN` lines and two `C14_BASELINE` rows

**Verification**:
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `grep -c "TimeIndexed" FormalSystem.lean` shows both new modules imported by the root
- The `C14LEAN` and `C14_BASELINE` heredocs contain the two new entries in the same relative order
- `git diff --stat` lists exactly the files enumerated above

---

### Phase 6: Full gate run and acceptance [COMPLETED]

**Goal**: Run the repository's complete acceptance set and confirm every criterion in the task
description.

**Tasks**:
- [x] Run `lake build --wfail` detached, per `context/project/lean4/operations/long-builds.md` and
      `context/patterns/bounded-build-waiter.md`: hard timeout, writer liveness via `kill -0` on the
      captured PID (never `ps | grep` or `pgrep -f`), one waiter per log. Confirm exit 0 with zero
      warnings.
- [x] `lean_verify` on `FormalSystem.Semantics.TimeIndexed.constantHistories_of_lub` and on
      `FormalSystem.Semantics.TimeIndexed.qSwitchFrame_not_constantHistories`: standard axioms only,
      no `sorryAx`.
- [x] `bash scripts/check-module-invariants.sh` — all checks pass, C14 included (this is a
      hard stop, never a new baseline: if C14 diverges, fix the tree, do not rewrite the baseline).
- [x] `lake exe mk_all --lib FormalSystem --check` exits 0.
- [x] `grep -rn "sorry" FormalSystem/Semantics/TimeIndexed.lean
      FormalSystem/Semantics/TimeIndexedSharpness.lean` returns nothing.
- [x] Confirm no task-number reference reached any file outside `specs/**`
      (`.claude/rules/no-task-references-in-deliverables.md`), and that no docstring cites the
      manuscript by line number.
- [x] If a build failure arises in a file outside this task's file scope, check `git log` first: it
      may be concurrent sibling task 655's in-flight edit rather than a regression here. Report it;
      do not "fix" a sibling's file.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Files to modify**:
- None (verification only)

**Verification**:
- All five acceptance criteria above reported with their actual command output, not asserted

---

## Lean Challenge Statements

**Authoring note.** The snapshot tool's matcher recognizes `theorem|lemma|def|instance` followed by
a *simple* name, forces that body to `sorry`, and discards everything between the `:=` and the next
matched declaration. The block below is shaped so nothing is lost: `structure TimeIndexed` and the
four carriers written as `abbrev` are unmatched, so their bodies survive and they stay out of the
identifier set; no theorem name is dotted; no `end` follows the first theorem — both namespaces are
left open on purpose. Consequences for the implementer: **the library declares `Hist`, `Limit`,
`ConstantHistories` and `Static` with `def`**, alongside the five further predicates
(`Compositional`, `Serial`, `Converse`, `Stationary`, `P`) that no challenge-pinned theorem mentions;
all four theorems live in `FormalSystem.Semantics.TimeIndexed`. Binder names are immaterial; binder
types, hypotheses and conclusions are the contract. Everything in `TimeIndexedSharpness.lean` is
deliberately absent — the witness is a `def` whose body the matcher would erase.

```lean
import FormalSystem.Semantics.TaskFrame
import Mathlib.Algebra.Order.Group.Bounds

namespace FormalSystem.Semantics

/-- Challenge carrier; `structure` in the library. Field names are report 05's, deliberately
not `FrameOver`'s, so the MF frame-correspondence Theorem A consumes this unchanged. -/
structure TimeIndexed (D : TemporalOrder) where
  W : Type
  [nonempty : Nonempty W]
  R : W → ↑D → ↑D → W → Prop

namespace TimeIndexed

variable {D : TemporalOrder}

/-- Challenge carrier; `def` in the library. -/
abbrev Hist (G : TimeIndexed D) : Set (↑D → G.W) := {τ | ∀ x y, G.R (τ x) x y (τ y)}

/-- Challenge carrier; `def` in the library. The time-indexed analogue of `FrameOver.limit`,
with the radius re-centred at a time rather than at `0`. -/
abbrev Limit (G : TimeIndexed D) : Prop :=
  ∀ w u t, (∀ ε : ↑D, 0 < ε → ∃ s, |s - t| < ε ∧ G.R w t s u) → u = w

/-- Challenge carrier; `def` in the library. -/
abbrev ConstantHistories (G : TimeIndexed D) : Prop := ∀ τ ∈ G.Hist, ∀ x y, τ x = τ y

/-- Challenge carrier; `def` in the library. The relation-level collapse, the time-indexed
twin of `TaskFrame.Static`. -/
abbrev Static (G : TimeIndexed D) : Prop := ∀ w x y u, G.R w x y u ↔ w = u

theorem exists_uniform_radius_of_finite (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit)
    (w : G.W) (t : ↑D) :
    ∃ ε : ↑D, 0 < ε ∧ ∀ u s, |s - t| < ε → G.R w t s u → u = w := sorry

theorem locally_constant_of_finite (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit)
    {τ : ↑D → G.W} (hτ : τ ∈ G.Hist) (t : ↑D) :
    ∃ ε : ↑D, 0 < ε ∧ ∀ s, |s - t| < ε → τ s = τ t := sorry

theorem constantHistories_of_lub [DenselyOrdered ↑D]
    (hlub : ∀ s : Set ↑D, s.Nonempty → BddAbove s → ∃ c, IsLUB s c)
    (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit) : G.ConstantHistories := sorry

theorem static_of_lub_of_realized [DenselyOrdered ↑D]
    (hlub : ∀ s : Set ↑D, s.Nonempty → BddAbove s → ∃ c, IsLUB s c)
    (G : TimeIndexed D) [Finite G.W] (hlim : G.Limit)
    (hrefl : ∀ w x y, G.R w x y w)
    (hreal : ∀ w x y u, G.R w x y u → ∃ τ ∈ G.Hist, τ x = w ∧ τ y = u) :
    G.Static := sorry
```

## Testing & Validation

- [x] `lake build --wfail` exits 0 with zero warnings (run detached, bounded waiter)
- [x] `lean_verify FormalSystem.Semantics.TimeIndexed.constantHistories_of_lub` — standard axioms
      only, no `sorryAx`
- [x] `lean_verify FormalSystem.Semantics.TimeIndexed.qSwitchFrame_not_constantHistories` — standard
      axioms only, no `sorryAx`
- [x] `bash scripts/check-module-invariants.sh` — all checks pass (C8, C14, C15, C24, INV included)
- [x] `lake exe mk_all --lib FormalSystem --check` exits 0
- [x] No `sorry` in either new module
- [x] No task-number reference outside `specs/**`; no line-number manuscript citation in any
      docstring
- [x] `Rigidity.lean`'s diff is confined to the module docstring's scope-note section

## Artifacts & Outputs

- `FormalSystem/Semantics/TimeIndexed.lean` — the shared time-indexed frame structure, its predicate
  family, and the Dedekind positive theorem (deliverables 1 and 2)
- `FormalSystem/Semantics/TimeIndexedSharpness.lean` — the two-state ℚ witness across `√2`, the
  optional ℤ witness, and the comparison docstring (deliverables 3 and 4)
- `FormalSystem/Semantics.lean`, `FormalSystem/Semantics/README.md`, `FormalSystem.lean` (generated),
  `docs/theorem-index.md`, `scripts/check-module-invariants.sh` — gate wiring
- `FormalSystem/Semantics/Correspondence/Rigidity.lean` — scope note replaced by a cross-reference
- `specs/652_time_indexed_frames_dedekind_rigidity_boundary/summaries/02_*-summary.md` — execution
  summary, including the reported correction about `ConstantHistories` vs `Static`

## Rollback/Contingency

The work is additive: two new modules plus five wiring edits plus one docstring edit. Phases 1-3 are
new files and revert by deletion. Phase 5's wiring reverts per file — `git checkout` the four
hand-edited paths and re-run `lake exe mk_all --lib FormalSystem` to restore the generated root.
Phase 4's `Rigidity.lean` edit is a single docstring hunk.

If a genuine whole-tree rollback is needed, take a durable snapshot first per
`context/contracts/recovery.md`'s rollback rung — including its out-of-scope override flag, which
this scenario needs because the tree carries a concurrent sibling task's modifications. Do **not**
run `git-snapshot.sh` in its reverting default mode as a routine precaution; a defensive checkpoint
before risky work uses `--no-revert`.

If the positive theorem's statement turns out to need a stronger hypothesis than
`[DenselyOrdered ↑D]` plus `h_lub`, the compiled corrected statement is the deliverable: report it
in the summary and in the module docstring, never weaken silently. The same applies if the ℚ witness
fails a condition — the failure and its evidence are the deliverable.
