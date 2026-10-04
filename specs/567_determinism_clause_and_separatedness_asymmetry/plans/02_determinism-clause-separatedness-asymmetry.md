# Implementation Plan: Determinism clause and separatedness asymmetry

- **Task**: 567 - Determinism clause and separatedness asymmetry
- **Status**: [IMPLEMENTING]
- **Effort**: 4 hours
- **Dependencies**: 563 (landed: the `Semantics/Presheaf/` cluster exists)
- **Research Inputs**: `specs/567_determinism_clause_and_separatedness_asymmetry/reports/02_determinism-clause-separatedness.md`, `specs/567_determinism_clause_and_separatedness_asymmetry/reports/01_retiming-invariance-definability-findings.md`
- **Artifacts**: plans/02_determinism-clause-separatedness-asymmetry.md (this file)
- **Standards**:
  - `.claude/context/formats/plan-format.md`
  - `.claude/context/standards/status-markers.md`
  - `.claude/rules/artifact-formats.md`
  - `.claude/rules/state-management.md`
  - `docs/development/REFERENCE_NORMAL_FORM.md`
  - `docs/development/MODULE_INVARIANTS.md`
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land the *Determinism* clause of `app:presheaf-dictionary` — `F` is deterministic iff every
restriction map of `Beh(F)` is injective — as a **theorem pair**: the clause itself as a
biconditional, and the asymmetry that separatedness of `Beh(F)` is strictly stronger than the
validity of *Determined* on `F`, refuted by this repository's own drift frame `F°`. Research
report 02 compiled the whole mathematical content against the live tree (two probes, exit 0, no
`sorry`), so this is a **siting, naming, docstring and gate task, not a proof-search task**. The
work splits across the `Presheaf/` cluster's `assert_not_exists` layering lock, because
`TaskFrame.SingletonClasses` and the drift frame both live above it. Definition of done: four
phases each ending with `lake build FormalSystem` green, no new `sorry`, and the module-invariant
gate set passing.

### Research Integration

- **The content is already proved.** `probes/01_determinism-clause.lean` compiles
  `separated_of_deterministic` (choice-free), the world-to-section bridge `secOf`/`secOf_states`,
  `singletonClasses_of_separated`, the biconditional, and `separated_strictly_stronger` at `F°`;
  `probes/02_cover-separated.lean` compiles cover-relative separatedness at no frame hypothesis.
  The phases below transcribe the probes into library modules; they do not re-discover proofs.
- **"Separatedness" is injectivity of every restriction map**, not cover-relative separatedness.
  Report 02 §4 settles this: the cover-relative reading is a theorem about *every* task frame
  (probe 02), so under that reading the §5.2.1 claim would be false. The injectivity reading makes
  it exactly right. Each new module says which sense is meant, in one sentence.
- **The declared single-file `file_scope` cannot hold the pair, and the obstruction is
  mechanical.** `Semantics/DeterministicBridge.lean` transitively imports
  `FormalSystem.ProofSystem.Axioms` (`PlusValidity → Validity → ValidityLayer →
  FrameClassValidity`), so a `Presheaf/` module importing it cannot carry the cluster's
  `assert_not_exists` lock; `F0`/`driftLinear`/`fzero_determined` sit under
  `Metalogic/Independence/`, far above `Semantics/`. The split mirrors the existing
  `PlusDeterminism` (choice-free) / `DeterministicBridge` (ZFC) precedent for
  `lem:deterministic-singleton`.
- **The open question is narrower than the task description states.** Report 02 §6:
  `deterministic_starDefinable` already gives a `BL⋆` characterization of determinism on regular
  frames, hence (composed with the clause) of separatedness, and
  `deterministic_not_plusDefinable` rules one out for `L⁺`. What survives is whether a
  **choice-free** characterization exists. The docstring poses that, and does not attack it.
- **Measured axiom profile** (probe 01, to be re-pinned in-tree): forward half
  `[propext, Quot.sound]`; section-level bridge `[propext]`; the biconditional and the `F°`
  witness `[propext, Classical.choice, Quot.sound]`.
- **Correction to report 02's gate note**: the report lists both `app:presheaf-dictionary` and
  `app:drift` as `DANGLING` rows. Checked against
  `docs/reference/paper-definitions-of-record.md`: `app:presheaf-dictionary` is `DANGLING`
  (line 2120), but `app:drift` is `LIVE-UNPINNED` (line 2103), cited as a pointer only. Phase 4
  must use the right marker for each — `DANGLING` for the dictionary anchor as `Behavior.lean`
  does, pointer-only for `app:drift` as `Ray.lean` does for `app:gluing`.

### Prior Plan Reference

No prior plan. Report 01 of this task is a prior advisory note, not a plan; its Recommendation 1
("establish which sense of separatedness is meant before planning") is discharged by report 02
§4 and is reflected in the docstring obligations of Phase 4.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no roadmap flag is set; `specs/ROADMAP.md`
was not consulted.

## Goals & Non-Goals

**Goals**:

- Land the *Determinism* clause as a biconditional and the separatedness asymmetry as a theorem
  pair, split across the `Presheaf/` layering lock.
- Declare exactly these identifiers: `Separated`, `states_eq_of_deterministic_sec`,
  `separated_of_deterministic`, `secOf`, `secOf_states`, `states_eq_of_separated`,
  `singletonClasses_of_separated`, `deterministic_iff_separated`, `driftSec`,
  `fzero_not_separated`, `separated_strictly_stronger`.
- Connect the clause to `states_eq_of_deterministic` through the world-to-section bridge, in
  prose and in proof, and route the converse through the existing
  `deterministic_of_singletonClasses` rather than a second Zorn argument.
- Record, in the module docstrings: the two senses of separatedness and which is meant; the
  warning that the pair is *not* the converse of the clause; the narrowed open question; the
  measured axiom lists with a prose provenance claim worded as `DriftHistories.lean` and
  `StarDeterminism.lean` already word theirs.
- Keep `lake build FormalSystem` green with no new `sorry` at the end of every phase.

**Non-Goals**:

- Settling whether a `BL⋆` formula characterizes separatedness **choice-freely**. Posed in the
  docstring, not attacked.
- Formalizing cover-relative separatedness (`cover_separated`, probe 02). It is unconditional and
  therefore not a dictionary clause; it appears in the docstring as the sense that is *not* at
  issue, with no declaration.
- Adopting Mathlib's `CategoryTheory.Sheaf`/`Presheaf` API (task 563's report already decided
  against it; nothing here touches that decision).
- Widening this task's declared `file_scope` to include the cluster aggregator
  `FormalSystem/Semantics/Presheaf.lean` or the generated library root `FormalSystem.lean`. Both
  one-line edits are made as shared touches under the dispatch's concurrency rules, not claimed as
  owned territory — which is why neither appears as a backticked path entry under any phase's
  **Files to modify** (that field is the `file_scope` harvest source).
- Any `git push`, PR, or branch operation.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The one-line import in `FormalSystem/Semantics/Presheaf.lean` is a shared touch across this categorical front; the collision gate cannot see it because the path is in no `file_scope` | H | M | Re-read the aggregator immediately before editing; stage only this task's own hunk (explicit path list, never a directory `git add`); re-run `lake build FormalSystem` after the edit. Sibling task 565 this cycle owns `Presheaf/Directed.lean` and will need the same line |
| Phase 2 touches `Semantics/DeterministicBridge.lean`, outside the declared scope, and could collide with a future task on that file | M | L | Phase 2 is a handful of lines. If contention appears, move both its declarations into Phase 3's module unchanged — recorded here so the fallback needs no re-research. The `.decisions.json` answer for this task already sanctions the siting |
| A reader takes `fzero_not_separated` for a counterexample to `separated_iff_deterministic` | M | M | Phase 4 states both converses in one paragraph: the clause's own converse is *true*; what fails is the converse of "validity of *Determined* ⇒ `Beh` separated" |
| `Classical.choice` on the `F°` witness invites a false "this needed Zorn" reading | M | M | Pin the measured axiom list beside a prose provenance claim worded as `DriftHistories.lean` and `StarDeterminism.lean` already word theirs: no appeal to `thm:extension` or `cor:occurrence`, hence no Zorn |
| Phase 3's module imports `Independence.StarDiscrimination`, which is heavy; elaboration is slow | M | H | Probe 01 elaborated the same import set inside the guard's budget. Route every build through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`, detached per `context/project/lean4/operations/long-builds.md` |
| The `rw`-against-a-`state_congr`-argument shape failed twice in research, the same way | L | H | Report 02's Tactic Survey: prefer `simpa using h`, or a `have e : ... := by simp` whose statement Lean has already normalized. Use `PartialHistory.states_eq_of_time_eq` as an explicit transport, never `rw`, for the two dependent time transports (`p + 0 = p`, `p + (r - p) = r`) |
| A new module silently falls outside the root closure (C24/C33) | M | M | Every new-file phase regenerates the root with `lake exe mk_all --lib FormalSystem` and runs `bash scripts/check-module-invariants.sh` before closing |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel. Phases 2 and 3 touch disjoint files (one
appends to `Semantics/DeterministicBridge.lean`; the other creates
`Metalogic/Independence/BehSeparatedness.lean` and touches the `Independence` aggregator and
README), so they may be run in either order or concurrently — but both consume Phase 1's
`Separated`.

---

### Phase 1: The clause below the lock [COMPLETED]

**Goal**: Create `FormalSystem/Semantics/Presheaf/Determinism.lean` carrying `Separated`, the
choice-free half of the clause, the world-to-section bridge, and the `SingletonClasses` content
written out without that name — everything the clause needs that is statable under the cluster's
`assert_not_exists` lock.

**Tasks**:

- [x] Create the module with the repository's copyright header (copy the four-line form from
  `FormalSystem/Semantics/Presheaf/Sheaf.lean`), importing exactly `FormalSystem.Init`,
  `FormalSystem.Semantics.Presheaf.Sheaf` and `FormalSystem.Semantics.Presheaf.Ray`. Do **not**
  import `Semantics.DeterministicBridge` — that import is what breaks the lock.
  *(deviation: altered — the stated three-import list is insufficient. `TaskFrame.Deterministic`
  is declared in `Semantics/FrameProperty.lean`, which none of the three reach, so the module
  failed to elaborate with "The environment does not contain
  `FormalSystem.Semantics.TaskFrame.Deterministic`" at both `separated_of_deterministic` and
  `states_eq_of_deterministic_sec`. Added `import FormalSystem.Semantics.FrameProperty`, which
  carries only `Semantics/TaskFrame.lean` plus two Mathlib order files and so does not break the
  lock — the `assert_not_exists` line still closes, and the full gate set passes. The probe got
  this name through its `Semantics.DeterministicBridge` import, which this module must not have.
  Same correction shape the plan's Phase 3 Scope Hypothesis already sanctions for
  `fzero_determined`; recorded, not silently widened.)*
- [x] Transcribe from `probes/01_determinism-clause.lean`, in `namespace
  FormalSystem.Semantics.Presheaf`: `Separated`, `states_eq_of_deterministic_sec`,
  `separated_of_deterministic`, `secOf`, `secOf_states`.
- [x] Add `states_eq_of_separated`: probe 01's `singletonClasses_of_separated` body, stated with
  `TaskFrame.SingletonClasses` unfolded (`∀ (τ σ : WorldHistory F) (x : F.Duration), τ.state x =
  σ.state x → ∀ y, τ.state y = σ.state y`), because the `SingletonClasses` *name* is behind the
  lock while its content is not.
- [x] Give every declaration a docstring (C19). Keep the module docstring minimal here — the
  conceptual prose, the two senses of separatedness and the `## References` block are Phase 4.
- [x] Close the file with `assert_not_exists FormalSystem.ProofSystem.Axiom
  FormalSystem.ProofSystem.DerivationTree`, matching the cluster's other four modules.
- [x] Pin the axiom profile in a comment or docstring line from a local `#print axioms` run:
  `states_eq_of_deterministic_sec [propext]`, `separated_of_deterministic [propext, Quot.sound]`,
  `states_eq_of_separated [propext, Quot.sound]`.
- [x] Re-read `FormalSystem/Semantics/Presheaf.lean` immediately before editing it (a sibling may
  have changed it this cycle), then add the one-line
  `import FormalSystem.Semantics.Presheaf.Determinism` in the existing alphabetical position and
  a `## Modules` bullet for it.
- [x] Regenerate the root aggregator: `lake exe mk_all --lib FormalSystem` (C33).
- [x] Regenerate `FormalSystem/Semantics/Presheaf/README.md`'s inventory block
  (`bash scripts/check-module-invariants.sh --emit-inventory`) and write the hand-authored
  description column for the new row.
- [x] Commit this phase's own hunks only — explicit path list, never a directory or glob `git add`.

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts four touched paths (one new module, the cluster
aggregator, the cluster README, the generated root). Confirm at implementation time with
`git status --short` before committing; if `mk_all` rewrites more of `FormalSystem.lean` than the
single new import line, stop and report rather than committing an unexplained root diff.

**Files to modify**:

- `FormalSystem/Semantics/Presheaf/Determinism.lean` - new module: `Separated`,
  `states_eq_of_deterministic_sec`, `separated_of_deterministic`, `secOf`, `secOf_states`,
  `states_eq_of_separated`; closes with the cluster `assert_not_exists` lock
- `FormalSystem/Semantics/Presheaf/README.md` - regenerated inventory row plus its hand-written
  description
- SHARED TOUCH, deliberately not written as an owned path entry (see Non-Goals): the cluster
  aggregator FormalSystem/Semantics/Presheaf.lean needs the one-line import plus one Modules
  bullet. The dispatch forbids widening this task's file_scope to include it, and the harvester
  reads only backticked path entries, so it is named here in prose on purpose. Re-read it
  immediately before editing and stage only this task's own hunk.
- SHARED TOUCH, same treatment and same reason: the generated library root FormalSystem.lean,
  rewritten by `lake exe mk_all --lib FormalSystem`. Every module-adding task on this front
  touches it, so it is a shared path, not owned territory.

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0.
- No new `sorry`: the C3 count is unchanged (still exactly one structural `sorry` repo-wide).
- `bash scripts/check-module-invariants.sh` exits 0 — in particular C4 (imports resolve), C8
  (one sibling aggregator), C9 (no task numbers under `FormalSystem/`), C19 (docstring coverage),
  C24 (`FormalSystem.Init` in the closure), C33 (root is byte-for-byte `mk_all` output), and the
  README generated-inventory staleness check.
- `#print axioms` on the three new theorems reports the profiles pinned above.

---

### Phase 2: The biconditional, above the lock [COMPLETED]

**Goal**: State the dictionary clause as a biconditional where `TaskFrame.SingletonClasses` is in
scope, beside the `lem:deterministic-singleton` biconditional it is the presheaf-side reading of.

**Tasks**:

- [x] Re-read `FormalSystem/Semantics/DeterministicBridge.lean` immediately before editing.
- [x] Add `import FormalSystem.Semantics.Presheaf.Determinism` to its import block. Confirm no
  cycle: the `Presheaf/` cluster imports only `Init` and `PartialHistory`, nothing from
  `PlusLanguage/` or `Extension/`.
- [x] Append `singletonClasses_of_separated : Presheaf.Separated F → F.SingletonClasses`, a
  one-line repackaging of Phase 1's `states_eq_of_separated` under the `SingletonClasses` name.
- [x] Append `deterministic_iff_separated (F : TaskFrame) [F.IsRegular] : F.Deterministic ↔
  Presheaf.Separated F`, oriented to match the file's existing
  `deterministic_iff_singletonClasses`, with the (⇐) half routed through
  `deterministic_of_singletonClasses` — no second Zorn argument.
- [x] Docstring both: the (⇒) half is choice-free, the (⇐) half is a theorem of **ZFC** via
  `thm:extension`; pin `[propext, Classical.choice, Quot.sound]` on the biconditional. Extend the
  module docstring's `## Main Results` list with the two new entries.
- [x] Commit this phase's own hunk only.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts a single touched file and "a handful of lines" (one
import, two declarations, two docstrings, two `## Main Results` entries). Confirm with
`git diff --stat` before committing; a diff substantially larger than that means the proof was
re-derived rather than repackaged, which is not this phase's job.

**Files to modify**:

- `FormalSystem/Semantics/DeterministicBridge.lean` - one import, `singletonClasses_of_separated`,
  `deterministic_iff_separated`, and the `## Main Results` docstring entries

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0.
- No new `sorry`.
- `bash scripts/check-module-invariants.sh` exits 0 (C4, C9, C19, C24 in particular; no new file,
  so C33 and the README blocks are untouched).
- `#print axioms FormalSystem.Semantics.deterministic_iff_separated` reports
  `[propext, Classical.choice, Quot.sound]`.
- **Contingency**: if `DeterministicBridge.lean` is contended, move both declarations verbatim
  into Phase 3's module and record the move in that module's docstring. No re-research needed.

---

### Phase 3: The asymmetry, at the repository's own drift frame [NOT STARTED]

**Goal**: Create `FormalSystem/Metalogic/Independence/BehSeparatedness.lean` carrying the
countermodel half of the theorem pair: `Beh F°` is not separated, while `F°` validates every
instance of *Determined*.

**Tasks**:

- [ ] Create the module with the standard copyright header, importing
  `FormalSystem.Metalogic.Independence.StarDiscrimination` (for `driftLinear`, which transitively
  brings `DriftFrame` and `DeterminismUndefinable`'s `fzero_determined`) and
  `FormalSystem.Semantics.Presheaf.Determinism` (for `Separated`). Verify the `fzero_determined`
  import path at implementation time rather than assuming transitivity; add
  `Independence.DeterminismUndefinable` explicitly if it does not come through.
- [ ] Transcribe from probe 01, in `namespace FormalSystem.Metalogic.Independence`: `driftSec`,
  `fzero_not_separated`, `separated_strictly_stronger`.
- [ ] Docstring each declaration, pinning `[propext, Classical.choice, Quot.sound]` on
  `fzero_not_separated` and `separated_strictly_stronger`. Keep the conceptual module prose for
  Phase 4.
- [ ] Re-read `FormalSystem/Metalogic/Independence.lean`, then add
  `import FormalSystem.Metalogic.Independence.BehSeparatedness` in the file's existing
  (dependency-ordered, not alphabetical) convention, after `StarDiscrimination`.
- [ ] Regenerate the root aggregator: `lake exe mk_all --lib FormalSystem`.
- [ ] Regenerate `FormalSystem/Metalogic/Independence/README.md`'s inventory block and write the
  new row's description.
- [ ] Commit this phase's own hunks only.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts four touched paths and the claim that
`StarDiscrimination` transitively supplies `fzero_determined`. Confirm the latter by compiling
the module with only the two stated imports; if it fails, add
`FormalSystem.Metalogic.Independence.DeterminismUndefinable` and note the correction in the
phase record rather than silently widening the import list.

**Files to modify**:

- `FormalSystem/Metalogic/Independence/BehSeparatedness.lean` - new module: `driftSec`,
  `fzero_not_separated`, `separated_strictly_stronger`
- `FormalSystem/Metalogic/Independence.lean` - one import line (no sibling task on this front owns
  this aggregator, so it is listed as an owned path, unlike the cluster aggregator)
- `FormalSystem/Metalogic/Independence/README.md` - regenerated inventory row plus description
- SHARED TOUCH, deliberately not written as an owned path entry (as in Phase 1): the generated
  library root FormalSystem.lean, rewritten by `lake exe mk_all --lib FormalSystem`.

**Verification**:

- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0.
- No new `sorry`.
- `bash scripts/check-module-invariants.sh` exits 0 (C4, C8, C9, C19, C24, C33, README inventory).
- `#print axioms` on both new theorems reports `[propext, Classical.choice, Quot.sound]`.

---

### Phase 4: Docstrings, references, and the open question [NOT STARTED]

**Goal**: Carry the four conceptual obligations into the two new modules' module-level docstrings,
add `## References` blocks in reference normal form, and run the full gate set over the finished
state.

**Tasks**:

- [ ] In `Presheaf/Determinism.lean`'s module docstring: state in one sentence that separatedness
  here is **injectivity of every restriction map**, and that the cover-relative sheaf-theoretic
  reading is unconditional on this site and is not what is at issue (report 02 §4, probe 02).
  Record that the forward half consumes only the germ at the offset, so injectivity of every
  restriction reduces to injectivity of the germ maps.
- [ ] In the same docstring: state the connection to `PlusLanguage.states_eq_of_deterministic` —
  the `Beh`-level statement is **not** an instance of it (that one is for *total* histories), it
  is the same three-step proof at `PartialHistory.respects_task`, and the two meet through
  `secOf`.
- [ ] In `Independence/BehSeparatedness.lean`'s module docstring: state both converses in one
  paragraph — the clause's own converse is *true* (`deterministic_iff_separated`), and what fails
  is the converse of "validity of *Determined* ⇒ `Beh` separated". A reader must not take
  `fzero_not_separated` for a counterexample to the clause.
- [ ] In the same docstring: record that validity of *Determined* is invariant under re-timing
  histories while separatedness is not — the drift frame is the translation flow re-timed, which
  is why it validates the schema without being deterministic. Cite
  `Independence/DeterminismUndefinable.lean`, never the probe.
- [ ] In the same docstring: word the provenance claim as `DriftHistories.lean` and
  `StarDeterminism.lean` already word theirs — no appeal to `thm:extension` or `cor:occurrence`,
  hence no Zorn — beside the measured axiom list, so the ambient `Classical.choice` is not read as
  a Zorn step.
- [ ] Pose the **narrowed** open question: `deterministic_starDefinable` makes `detPM` a `BL⋆`
  characterization of separatedness on regular frames, and `deterministic_not_plusDefinable` rules
  one out for `L⁺`; what is open is whether any **choice-free** characterization exists, which
  `StarDeterminism.lean`'s choice-dependence note suggests it does not. Pose, do not attack.
- [ ] Add `## References` blocks per `docs/development/REFERENCE_NORMAL_FORM.md`, keys resolving
  in the repository-root `references.bib` (`* [Author, *Title*][key]` form). Cite
  `app:presheaf-dictionary` with the **`DANGLING`** marker, as `Behavior.lean` does; cite
  `app:drift` as a **pointer only** (its record row is `LIVE-UNPINNED`, not `DANGLING` — see the
  Research Integration correction above), as `Ray.lean` does for `app:gluing`.
- [ ] No task numbers anywhere under `FormalSystem/` (C9); cite durable anchors — filenames,
  declaration names, paper anchors.
- [ ] Commit this phase's own hunks only.

**Timing**: 1 hour

**Depends on**: 2, 3

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that every edit lands inside a doc comment and that no
declaration body changes. Confirm by reading the diff through: every changed hunk must lie inside
a `/-!` or `/-- -/` region. A hunk outside one means the phase has crossed into code and must be
verified at tier `full` instead.

**Files to modify**:

- `FormalSystem/Semantics/Presheaf/Determinism.lean` - module docstring (two senses of
  separatedness, the `states_eq_of_deterministic` connection) and `## References`
- `FormalSystem/Metalogic/Independence/BehSeparatedness.lean` - module docstring (both converses,
  the re-timing observation, the provenance wording, the narrowed open question) and
  `## References`

**Verification**:

- Diff read-through confirms every changed hunk lies inside a doc comment; no declaration body
  changed.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0
  (doc comments do elaborate, so this is run despite the `prose` tier).
- `bash scripts/check-module-invariants.sh` exits 0, in particular C9 (no task-number citations),
  C15 (paper anchors resolve against `docs/reference/paper-definitions-of-record.md` with the
  right marker per anchor), C19 (docstring coverage) and C31 (every `## References` bib key
  resolves in the root `references.bib`).
- `bash scripts/check-paper-definitions.sh` exits 0.

---

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.Presheaf.Sheaf
import FormalSystem.Semantics.Presheaf.Ray
import FormalSystem.Semantics.DeterministicBridge
import FormalSystem.Metalogic.Independence.StarDiscrimination

namespace FormalSystem.Semantics.Presheaf

open FormalSystem FormalSystem.Semantics

variable {F : TaskFrame}

/-- Separatedness of `Beh F`: every restriction map of the behavior presheaf is injective. -/
def Separated (F : TaskFrame) : Prop := sorry

theorem states_eq_of_deterministic_sec (hD : F.Deterministic) {l : F.Duration}
    {σ τ : Beh F l} {t : F.Duration} (ht0 : 0 ≤ t) (htl : t ≤ l)
    (h : σ.val.states t (Beh.mem_dom σ ht0 htl) = τ.val.states t (Beh.mem_dom τ ht0 htl))
    (s : F.Duration) (hs0 : 0 ≤ s) (hsl : s ≤ l) :
    σ.val.states s (Beh.mem_dom σ hs0 hsl) = τ.val.states s (Beh.mem_dom τ hs0 hsl) := sorry

theorem separated_of_deterministic (hD : F.Deterministic) : Separated F := sorry

noncomputable def secOf (σ : WorldHistory F) (m l : F.Duration) (hl : 0 ≤ l) : Beh F l := sorry

theorem secOf_states (σ : WorldHistory F) (m l : F.Duration) (hl : 0 ≤ l) {z : F.Duration}
    (hz : (secOf σ m l hl).val.domain z) :
    (secOf σ m l hl).val.states z hz = σ.state (z + m) := sorry

theorem states_eq_of_separated (hS : Separated F) (τ σ : WorldHistory F) (x : F.Duration)
    (h : τ.state x = σ.state x) (y : F.Duration) : τ.state y = σ.state y := sorry

end FormalSystem.Semantics.Presheaf

namespace FormalSystem.Semantics

open FormalSystem FormalSystem.Semantics.Presheaf

theorem singletonClasses_of_separated {F : TaskFrame} (hS : Separated F) :
    F.SingletonClasses := sorry

theorem deterministic_iff_separated (F : TaskFrame) [F.IsRegular] :
    F.Deterministic ↔ Separated F := sorry

end FormalSystem.Semantics

namespace FormalSystem.Metalogic.Independence

open FormalSystem FormalSystem.Semantics FormalSystem.Semantics.Presheaf

noncomputable def driftSec (a : ℝ) (h1 : 1 ≤ a) (h2 : a ≤ 2) : Beh F0 1 := sorry

theorem fzero_not_separated : ¬ Separated F0 := sorry

theorem separated_strictly_stronger :
    (∀ φ : PlusLanguage.PlusFormula, F0.PlusValidOn (.imp φ (.stab φ))) ∧ ¬ Separated F0 := sorry

end FormalSystem.Metalogic.Independence
```

These signatures are transcribed from `probes/01_determinism-clause.lean`, which compiled under
the same four imports (exit 0, no `sorry`), with two deliberate departures: `Separated`'s body is
elided here (the probe's `∀ l p l' …, Function.Injective (Beh.restrict …)` is restored in Phase
1), and `states_eq_of_separated` is probe 01's `singletonClasses_of_separated` with
`TaskFrame.SingletonClasses` unfolded, because that name is behind the cluster's layering lock.

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits
  0 at the end of every phase (the task's stated hard constraint).
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build BimodalTest` exits 0
  at the end of Phase 4 (C1's second half).
- [ ] No new `sorry`: the repo-wide structural-`sorry` count is unchanged from its pre-task value
  at the end of every phase.
- [ ] `bash scripts/check-module-invariants.sh` exits 0 at the end of every phase; C1, C3, C4, C8,
  C9, C15, C19, C24, C31, C33 and the README generated-inventory checks are the ones this task can
  break.
- [ ] `bash scripts/check-paper-definitions.sh` exits 0.
- [ ] `#print axioms` measurements match the pinned profiles: `[propext]` for
  `states_eq_of_deterministic_sec`; `[propext, Quot.sound]` for `separated_of_deterministic` and
  `states_eq_of_separated`; `[propext, Classical.choice, Quot.sound]` for
  `deterministic_iff_separated`, `fzero_not_separated` and `separated_strictly_stronger`.
- [ ] `git status --short` before each commit shows only this task's own paths; no directory or
  glob `git add` was used.

## Artifacts & Outputs

- `FormalSystem/Semantics/Presheaf/Determinism.lean` (new) — the clause below the layering lock.
- `FormalSystem/Metalogic/Independence/BehSeparatedness.lean` (new) — the asymmetry and the
  countermodel half of the theorem pair.
- `FormalSystem/Semantics/DeterministicBridge.lean` (modified) — `singletonClasses_of_separated`
  and `deterministic_iff_separated`.
- `FormalSystem/Semantics/Presheaf.lean`, `FormalSystem/Metalogic/Independence.lean` (modified) —
  one aggregator import line each.
- `FormalSystem/Semantics/Presheaf/README.md`, `FormalSystem/Metalogic/Independence/README.md`
  (modified) — regenerated inventory rows plus hand-written descriptions.
- `FormalSystem.lean` (regenerated) — two new import lines from `lake exe mk_all`.
- `specs/567_determinism_clause_and_separatedness_asymmetry/summaries/02_*-summary.md` — the
  implementation summary, written at implement postflight.

## Rollback/Contingency

Each phase ends at a green, committed state, so the ordinary recovery is `git revert` of that
phase's commit — no working-tree discard, nothing to snapshot.

If uncommitted work must be discarded mid-phase, that is a genuine rollback: take the snapshot
first using the invocation shape in `.claude/context/contracts/recovery.md`'s rollback rung
(including its out-of-scope override flag if the discard must reach beyond this task's
`file_scope`), then run the destructive command. Do not emit a bare reverting
`git-snapshot.sh 567` as a routine start-of-phase checkpoint; for an ordinary defensive
checkpoint before risky work use the `--no-revert` form, which is durable without touching the
working tree.

Per-phase contingencies:

- **Phase 2 contended** (another writer on `Semantics/DeterministicBridge.lean`): move
  `singletonClasses_of_separated` and `deterministic_iff_separated` verbatim into Phase 3's
  module, which is already above the lock. No re-research needed; note the move in that module's
  docstring.
- **Aggregator clobbered by a sibling**: re-read the aggregator, re-apply only this task's single
  import line, re-run the build. Do not revert a sibling's line.
- **A foreign commit, foreign uncommitted modification, or a build you did not start** appears:
  stop and report after checking `git log` to confirm the work is not your own, per the dispatch's
  concurrency note — do not proceed and do not dismiss it as noise.
