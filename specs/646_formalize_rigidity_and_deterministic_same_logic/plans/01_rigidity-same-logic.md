# Implementation Plan: Task #646

- **Task**: 646 - Formalize rigidity (R2) and deterministic same-logic (R1)
- **Status**: [NOT STARTED]
- **Effort**: 5 hours
- **Dependencies**: None blocking. Imports `Semantics/ShiftSet.lean` read-only; independent of task 543 (which keeps R3, R4, Theorem B and every edit to `ShiftSet.lean`).
- **Research Inputs**: specs/646_formalize_rigidity_and_deterministic_same_logic/reports/01_rigidity-same-logic-research.md
- **Artifacts**: plans/01_rigidity-same-logic.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Both results are already proved, sorry-free, in the research report's Appendix (A.1 for R2, A.2
for R1, A.3 for the sharpness witnesses), elaborated by `lean_run_code` against the current tree
at `61b2dc82e`. This plan lands them as two new library modules plus one optional sibling,
`FormalSystem/Semantics/Correspondence/Rigidity.lean` (R2), `FormalSystem/Metalogic/Deterministic/
SameLogic.lean` (R1) and `FormalSystem/Semantics/Correspondence/RigiditySharpness.lean`, with the
aggregator, README, generated-inventory, root-file and theorem-ledger plumbing the repository's
gates require. Definition of done is the task's own acceptance bar: `lake build --wfail` green,
`lean_verify` on every headline returns `[propext, Classical.choice, Quot.sound]` (or a subset)
with no `sorryAx`, `bash scripts/check-module-invariants.sh` all-pass, and
`lake exe mk_all --lib FormalSystem --check` exit 0.

The work is transcription, not discovery. The one place the implementer must not "improve" the
scratch is the R1 helper: `fun _ _ _ => Iff.rfl` no longer closes the fibre goal (the fibre is
presented through `TaskFrame.reflect`); `fun w d u => S.fibre_taskRel w d u` does.

### Research Integration

- **R2 is true as stated and needs no stronger hypothesis** (research Decisions). Two honest
  refinements are carried into the statements and docstrings rather than the theorem being
  weakened: (i) the *biconditional* form of "static" consumes Seriality and the reflection law
  (for `w ⇒_x w` and negative durations); the collapse direction `w ⇒_x u → w = u` uses only
  interpolation and the dwell bound. (ii) The core chop lemma needs only `[Archimedean D]`,
  interpolation and a step bound below some `ε > 0`; density is consumed exactly once, to pass
  from the strict cone radius to a closed step bound. The plan therefore states the core lemma
  at the weaker hypothesis (`eq_of_rel_of_step`) and derives the paper-shaped biconditional as a
  corollary, which is what "state the theorem at the hypothesis the proof actually uses" asks.
- **R1 is stated against the existing `ValidDetIn` vocabulary** (`Metalogic/Deterministic/
  Validity.lean` already has `DetSat`, `ValidDetIn`, `ValidIn.toDet`), uniformly in the frame
  class, with the task description's raw `Valid φ ↔ ∀ deterministic F …` shape as the `.Base`
  corollary. The frame-predicate-general form underneath covers any predicate stable under
  `ShiftSet.ofModel`, which is what distinguishes this route from the completeness detour that
  `Engines.lean` + TM soundness already afford at the four tagged classes.
- **Tree drift from the roadmap report is already reconciled** in the research table: line
  numbers moved, `WorldHistory F` is now the total-history type (no `IsTotal`, no
  `Valid.of_forall_total`), `sat_ofModel_frame` lives in `Compactness.lean` and must not be
  imported for a two-token body (inline `cases fc <;> exact h`).
- **Sharpness witnesses compile** (research A.3): density cannot be dropped (`permissiveFrame`
  over any successor order, hence `ℤ`), and the Archimedean property cannot be dropped (a
  two-state frame over `ℚ ×ₗ ℚ`, which is `DenselyOrdered` and provably `¬ Archimedean`). They are
  included as Phase 3 because the paper's remarks claim exactly this sharpness and the task's
  point is to machine-check the claim before it enters the paper.
- **Anchor constraint (C15)**: the manuscript has no rigidity label and `app:rigidity` is not in
  the record; docstrings cite only `def:frame#Limit`, `def:frame#Compositionality`,
  `def:frame#Seriality`, `def:task-relation`, `def:deterministic`, `app:deterministic`,
  `def:logical-consequence`, `cor:saturation-finite`. R2 ledger rows use `Paper: —` with a
  one-clause reason.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found (`specs/ROADMAP.md` absent; no `roadmap_path` in the dispatch).

## Goals & Non-Goals

- **Goals**: `eq_of_rel_of_step`, `eq_of_rel_of_uniform_radius`, `static_iff_uniformDwell`,
  `uniformDwell_of_finite`, `static_of_finite`, `frame_deterministic`,
  `validOnFrames_iff_deterministic`, `validIn_iff_validDetIn`, `valid_iff_valid_deterministic`
- **Goals (not challenge-pinned)**: the Phase 3 sharpness module's `permissiveFrame_not_static`,
  `lexRatFrame_not_static`, `lexRat_not_archimedean`; the aggregator, README, inventory,
  root-file and ledger plumbing; a `Paper:` line on every ledger-row declaration. These are not
  listed in the challenge block because the witness frame is a `def` whose body the snapshot
  matcher would erase (see the authoring note under `## Lean Challenge Statements`).
- **Non-Goals**: R3 (T1-converse witness), R4 (Theorem A over ℤ-time), Theorem B, any edit to
  `Semantics/ShiftSet.lean`, any time-indexed-frame type or theorem (the Dedekind-completeness
  refinement enters as a docstring scope note only), Hölder's theorem or any topology import, an
  L⁺ corollary of R1 (erasure is truth-preserving only on deterministic frames, so none is
  available in general), and any hand edit to `FormalSystem.lean`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `--wfail` lint noise the scratch never saw (long lines, unused `rcases` binders, flexible `simp`, header-linter order) | M | M | Appendix text is pre-wrapped at 100 columns; header is copyright block, imports, `/-! -/` docstring, in that order; use `simp only` with explicit lemma lists (`galR_limit` already does); build each module scoped with `--wfail` before touching the aggregator |
| R1 helper regression: `Iff.rfl` fails against the reflect-presented fibre | H | L (known) | Use `fun w d u => S.fibre_taskRel w d u` verbatim; do not re-derive |
| Declaring `ShiftSet.frame_deterministic` outside `ShiftSet.lean` trips namespace/`open` friction | M | L | Declare it inside `namespace FormalSystem.Semantics … end` in `SameLogic.lean` **before** opening `FormalSystem.Metalogic.Deterministic` (this layout compiled in scratch); docstring notes it may relocate upstream later, without citing any task |
| C17 dead-declaration scan flags a headline with no consumer outside its file | M | M | Name every headline in its directory README `## Key Results` and in `docs/theorem-index.md`; helpers are consumed by later declarations in the same module |
| Ledger Axioms column is "generated from baselines, never typed" — new rows without a C14 pin are prose-only | M | M | Append the new headline `#print axioms` lines to the C14 baseline heredoc in `scripts/check-module-invariants.sh` in the same sub-step as the ledger rows (proposed file_scope addition); if that proves unsuitable, omit the ledger rows rather than type an unpinned Axioms cell |
| Concurrent sessions on `main` add a module and race the generated root | M | M | Regenerate `FormalSystem.lean` with `lake exe mk_all --lib FormalSystem` immediately before every commit that includes it, then `--check`; stage by explicit file path only |
| `Mathlib.Algebra.Order.Group.Prod` is absent from this checkout | L | L (known) | Use `Mathlib.Algebra.Order.Monoid.Prod` (already imported by `LexCarrier.lean`); prefer importing `FormalSystem.Semantics.LexCarrier` and inheriting its closure |
| `SuccOrder (TemporalOrder.of ℤ).carrier` does not synthesize by default | L | L (known) | State `permissiveFrame_not_static` generically over `(so : SuccOrder ↑D) (nm : NoMaxOrder ↑D)`; instantiate at `ℤ` only in a docstring or with `inferInstanceAs` |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1 |
| 3 | 4 | 1, 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel. Phases 1 and 2 share no source file; both
regenerate `FormalSystem.lean`, which `mk_all` produces idempotently from the tree, so if they run
in one worktree regenerate the root once more (and `--check`) before the commit that includes it.

### Phase 1: R2 core — `Semantics/Correspondence/Rigidity.lean` [NOT STARTED]

**Goal**: Land the rigidity theorem and its finite-carrier corollary as a new module, at the
hypothesis the proof actually uses, with the two refinements recorded in docstrings, wired into
its aggregator and directory README and the generated root.

**Tasks**:
- [ ] Create `FormalSystem/Semantics/Correspondence/Rigidity.lean` with the standard copyright
  block, imports `FormalSystem.Semantics.TaskFrame` and `Mathlib.Algebra.Order.Archimedean.Defs`
  (upgrade to `.Basic` only if `.Defs` proves insufficient for `exists_between`), then the `/-! -/`
  module docstring. No `import Mathlib`.
- [ ] Transcribe research Appendix A.1, in order, into `namespace FormalSystem.Semantics`:
  `TaskFrame.Static`, `TaskFrame.UniformDwell` (both `def`, cone-equality form `cone R w x₀ = {w}`),
  `TaskFrame.eq_of_rel_of_step` (`[Archimedean D]` only; choice-free),
  `TaskFrame.eq_of_rel_of_uniform_radius` (density enters here only), then in `namespace FrameOver`:
  `static_of_uniformDwell`, `uniformDwell_of_static`, `static_iff_uniformDwell` (headline),
  `uniformDwell_of_finite` (no order hypothesis; `[Finite F.WorldState]`, not `Fintype`),
  `static_of_finite` (headline). Use `theorem`, never `lemma`.
- [ ] Docstrings on every declaration (C19). The module docstring and the two headlines must:
  cite `def:frame#Limit`, `def:frame#Compositionality`, `def:frame#Seriality` by label or
  quotable phrase, never line number; record that the biconditional uses Seriality and the
  reflection law while the collapse direction uses only interpolation and the dwell bound; carry
  the report-04 scope note that for *time-indexed* frames the boundary is Dedekind completeness
  rather than the Archimedean property, as a remark only (no time-indexed frame type exists here
  and nothing about them is proved); flag the induction-on-`n` chop as a bookkeeping deviation
  from the source's minimal-`n` chain; contain no task numbers and no `app:rigidity`. Put a
  `Paper: — (the manuscript states no rigidity theorem; stated at the hypothesis the proof uses)`
  line on `static_iff_uniformDwell` and `static_of_finite` (C15 round trip for Phase 4's rows).
- [ ] Scoped build: `lake build --wfail FormalSystem.Semantics.Correspondence.Rigidity`; fix
  forward on any lint (long lines, unused binders) — never weaken a statement to silence a lint.
- [ ] `lean_verify` on `FormalSystem.Semantics.FrameOver.static_iff_uniformDwell` and
  `FormalSystem.Semantics.FrameOver.static_of_finite`: standard axioms only, no `sorryAx`.
  Record `eq_of_rel_of_step`'s `[propext, Quot.sound]` profile in its docstring only if
  `lean_verify` confirms it in-tree.
- [ ] Add `import FormalSystem.Semantics.Correspondence.Rigidity` and a one-line `## Modules`
  bullet to `FormalSystem/Semantics/Correspondence.lean`; add a `## Modules` table row
  (File | Lines | Description; the Lines cell is regenerated in Phase 4) and a `## Key Results`
  bullet naming both headlines to `FormalSystem/Semantics/Correspondence/README.md`. One sentence
  per row; do not paste the module docstring (C18).
- [ ] `lake exe mk_all --lib FormalSystem` then `lake exe mk_all --lib FormalSystem --check`
  (exit 0). Never hand-edit `FormalSystem.lean`.
- [ ] Commit per green sub-step (module green; aggregator + README + root green), staging by
  explicit path: the module, `Correspondence.lean`, `Correspondence/README.md`, `FormalSystem.lean`.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: 9 declarations, 160-260 lines including docstrings, 4 files touched
(module, aggregator, directory README, generated root). Confirm by counting declarations after
transcription and by `git status --short` before each commit; a deviation above 300 lines means
docstrings are duplicating the README and should be trimmed.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/Rigidity.lean` - new module (R2)
- `FormalSystem/Semantics/Correspondence.lean` - import line + `## Modules` bullet
- `FormalSystem/Semantics/Correspondence/README.md` - table row + `## Key Results` bullet
- `FormalSystem.lean` - regenerated by `mk_all`, never hand-edited

**Verification**:
- `lake build --wfail FormalSystem.Semantics.Correspondence.Rigidity` exits 0 with no warnings
- `lean_verify` on both headlines: axioms ⊆ `[propext, Classical.choice, Quot.sound]`, no `sorryAx`
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `grep -c "sorry" FormalSystem/Semantics/Correspondence/Rigidity.lean` is 0 outside comments

---

### Phase 2: R1 — `Metalogic/Deterministic/SameLogic.lean` [NOT STARTED]

**Goal**: Land the deterministic same-logic theorem, with its one-line helper, as a new module
stated against the tree's existing `ValidDetIn` vocabulary, wired into its aggregator, README
and the generated root — without touching `ShiftSet.lean`.

**Tasks**:
- [ ] Create `FormalSystem/Metalogic/Deterministic/SameLogic.lean` with the copyright block,
  imports `FormalSystem.Semantics.ShiftSet` and `FormalSystem.Metalogic.Deterministic.Validity`
  (`FrameProperty`'s `Deterministic` arrives through the latter's closure; do **not** import
  `FormalSystem.Metalogic.Compactness`), then the `/-! -/` module docstring.
- [ ] Transcribe research Appendix A.2 verbatim. Layout is load-bearing: first
  `namespace FormalSystem.Semantics … end FormalSystem.Semantics` holding
  `ShiftSet.frame_deterministic` with body
  `fun w d => TaskFrame.fib_subsingleton_of_functional (f := S.sh) (fun w d u => S.fibre_taskRel w d u) w d`;
  then `namespace FormalSystem.Metalogic.Deterministic` with the three opens and
  `validOnFrames_iff_deterministic` (frame-predicate-general, hypothesis `hP` stable under
  `ShiftSet.ofModel`), `validIn_iff_validDetIn` (headline; `hP := fun F M h => by cases fc <;> exact h`),
  `valid_iff_valid_deterministic` (headline; the task description's shape, minus the retired
  `τ.IsTotal` hypothesis, via `Valid`, `validIn_iff_validDetIn`, `ValidDetIn.apply`,
  `ValidDetIn.of_forall`).
- [ ] Docstrings on every declaration. The module docstring must say why this route is the
  deliverable although `Engines.lean` + TM soundness already yield `ValidDetIn fc φ → ValidIn fc φ`
  at the four tagged classes: it is semantic and per-model (each `(F, M, τ, t)` is matched by a
  deterministic `(F', M', τ', t)` agreeing on every formula), it does not route through
  Lindenbaum or canonical models, and its general form covers any `ofModel`-stable frame
  predicate. Cite `def:deterministic` and `app:deterministic` by label; note `frame_deterministic`
  is the fact the pure `reverse_repr ∘ forward_repr` composition was missing and may later
  relocate beside `reverse_repr` without renaming (no task citation). Put a
  `Paper: \`app:deterministic\`` line on both headlines.
- [ ] Scoped build: `lake build --wfail FormalSystem.Metalogic.Deterministic.SameLogic`; fix forward.
- [ ] `lean_verify` on `FormalSystem.Metalogic.Deterministic.validIn_iff_validDetIn` and
  `FormalSystem.Metalogic.Deterministic.valid_iff_valid_deterministic`: standard axioms only,
  no `sorryAx`.
- [ ] Add `import FormalSystem.Metalogic.Deterministic.SameLogic` to
  `FormalSystem/Metalogic/Deterministic.lean` and extend its module docstring by one clause; add
  a `SameLogic.lean` row (File | Role) and a `## Key Results` bullet naming both headlines to
  `FormalSystem/Metalogic/Deterministic/README.md`.
- [ ] `lake exe mk_all --lib FormalSystem` then `--check` (exit 0).
- [ ] Commit per green sub-step, staging by explicit path: the module, `Deterministic.lean`,
  `Deterministic/README.md`, `FormalSystem.lean`.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: interface

**Scope Hypothesis**: 4 declarations, 70-110 lines including docstrings, 4 files touched. Confirm
by declaration count and `git status --short`; `git diff --stat -- FormalSystem/Semantics/ShiftSet.lean`
must be empty at every commit (the non-edit is a hard constraint).

**Files to modify**:
- `FormalSystem/Metalogic/Deterministic/SameLogic.lean` - new module (R1 + helper)
- `FormalSystem/Metalogic/Deterministic.lean` - import line + docstring clause
- `FormalSystem/Metalogic/Deterministic/README.md` - table row + `## Key Results` bullet
- `FormalSystem.lean` - regenerated by `mk_all`

**Verification**:
- `lake build --wfail FormalSystem.Metalogic.Deterministic.SameLogic` exits 0 with no warnings
- `lean_verify` on both headlines: standard axioms only, no `sorryAx`
- `lake exe mk_all --lib FormalSystem --check` exits 0
- `git diff --quiet -- FormalSystem/Semantics/ShiftSet.lean` succeeds

---

### Phase 3: Sharpness witnesses — `Semantics/Correspondence/RigiditySharpness.lean` [NOT STARTED]

**Goal**: Make "the hypotheses of the rigidity theorem are sharp" a theorem rather than a remark:
density cannot be dropped, and the Archimedean property cannot be dropped, each by a compiled
witness stated against Phase 1's `TaskFrame.Static`.

**Tasks**:
- [ ] Decide and record the siting: a sibling module `RigiditySharpness.lean` keeps
  `Rigidity.lean` import-light (`TaskFrame` + `Archimedean.Defs` only). This is a planning
  choice, not the task's; the file is a proposed `file_scope` addition. If the implementer
  prefers one module, append the section to `Rigidity.lean` instead and add the two imports
  there — either is acceptable; do not do both.
- [ ] Create the module with imports `FormalSystem.Semantics.Correspondence.Rigidity`,
  `FormalSystem.Semantics.Frames.Standard`, `FormalSystem.Semantics.LexCarrier` (the latter
  supplies `Mathlib.Data.Prod.Lex`, `Mathlib.Algebra.Order.Monoid.Prod`,
  `Mathlib.Data.Rat.Cast.Order`; do not import `Mathlib.Algebra.Order.Group.Prod`, absent from
  this checkout), then the `/-! -/` module docstring.
- [ ] Transcribe research Appendix A.3 into a namespace (`FormalSystem.Semantics.Rigidity` or the
  implementer's equivalent) with C26-compliant, docstringed names:
  `permissiveFrame_not_static (so : SuccOrder ↑D) (nm : NoMaxOrder ↑D) : ¬ TaskFrame.Static (permissiveFrame D so nm).TaskRel`;
  `abbrev LexRat := ℚ ×ₗ ℚ`; `lexRatRel`; `lexRatRel_refl`, `lexRatRel_comp`, `lexRatRel_serial`,
  `lexRatRel_limit`; `noncomputable def lexRatFrame : FrameOver (TemporalOrder.of LexRat)` via
  `FrameOver.ofReflective … (TaskFrame.saturation_of_finite _)`;
  `lexRatFrame_not_static : ¬ TaskFrame.Static lexRatFrame.TaskRel`; `lexRat_fst_nsmul`;
  `lexRat_not_archimedean : ¬ Archimedean LexRat`; plus `example : DenselyOrdered LexRat := inferInstance`
  turned into a named `instance`-free `theorem` or left as an `example` if C17/C19 accept it.
- [ ] Docstrings: state which hypothesis each witness removes and why the other still holds
  (`ℤ` is Archimedean but not dense; `ℚ ×ₗ ℚ` is dense but not Archimedean); note
  `LexCarrier.lean`'s `not_archimedean` covers `α ×ₗ ℤ` only, which is why a fresh lemma exists.
  No task numbers.
- [ ] Scoped build with `--wfail`; fix forward (`galR_limit`'s case split already uses
  `simp only`; keep it).
- [ ] `lean_verify` on `permissiveFrame_not_static`, `lexRatFrame_not_static`,
  `lexRat_not_archimedean`: standard axioms only.
- [ ] Add the import and `## Modules` bullet to `Correspondence.lean`, a table row and a
  `## Key Results` bullet to `Correspondence/README.md`; `mk_all` + `--check`; commit per green
  sub-step by explicit path.

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: interface

**Scope Hypothesis**: ~11 declarations, 90-150 lines, 4 files touched. Confirm by count after
transcription. If the module exceeds 200 lines the docstrings are over-explaining; trim.

**Files to modify**:
- `FormalSystem/Semantics/Correspondence/RigiditySharpness.lean` - new module (proposed file_scope addition)
- `FormalSystem/Semantics/Correspondence.lean` - import line + bullet
- `FormalSystem/Semantics/Correspondence/README.md` - table row + Key Results bullet
- `FormalSystem.lean` - regenerated by `mk_all`

**Verification**:
- `lake build --wfail FormalSystem.Semantics.Correspondence.RigiditySharpness` exits 0
- `lean_verify` on the three named theorems: standard axioms only, no `sorryAx`
- `lake exe mk_all --lib FormalSystem --check` exits 0

---

### Phase 4: Parent READMEs, generated inventory, theorem ledger [NOT STARTED]

**Goal**: Bring every documentation surface that counts or lists these modules back into
agreement with the tree, and register the four headlines in the per-theorem ledger with a
machine pin.

**Tasks**:
- [ ] `FormalSystem/Semantics/README.md`: the hand-maintained `Correspondence/` row (currently
  "`Galois`, `Indicator`, `DurationFrames`, `FwdRec`, `FwdRecPeriodicity`, `FwdRecBridge` (6 files)")
  gains `Rigidity` and `RigiditySharpness` and the corrected count. This file carries no
  generated block, so it is a manual edit.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory` to rewrite the generated blocks
  (`FormalSystem/Metalogic/README.md`'s `Deterministic.lean` line count and `Deterministic/`
  subdir files/lines row; `FormalSystem/README.md` and `README.md` totals; the
  `Correspondence/README.md` Lines cells), then `--emit-inventory --check` (exit 0). Do not hand
  edit inside a `BEGIN GENERATED` block.
- [ ] `FormalSystem/Metalogic/README.md`: in the TM⁺ metatheory rows table (the
  `Deterministic/` block near "the logic of the deterministic frames coincides with …"), add one
  hand row: the logic of the deterministic frames coincides with the logic of all task frames,
  at every class — **landed** — `Deterministic/SameLogic.lean`. Replace the
  `<!-- TODO: add description -->` on the `Deterministic.lean` aggregator row only if it sits
  outside a generated block; otherwise leave it.
- [ ] `docs/theorem-index.md`: add rows, fully qualified Lean names, path only, no line numbers:
  - `—` | a task frame over a dense Archimedean order is static iff it has a uniform dwell time | `FormalSystem.Semantics.FrameOver.static_iff_uniformDwell` | `FormalSystem/Semantics/Correspondence/Rigidity.lean` | — | pcq
  - `—` | every task frame over such an order with finitely many world states is static | `FormalSystem.Semantics.FrameOver.static_of_finite` | same file | — | pcq
  - `app:deterministic` | deterministic task frames determine the same logic as all task frames, at every class | `FormalSystem.Metalogic.Deterministic.validIn_iff_validDetIn` | `FormalSystem/Metalogic/Deterministic/SameLogic.lean` | — | pcq
  - `app:deterministic` | the same at `.Base` in the paper's unbundled shape | `FormalSystem.Metalogic.Deterministic.valid_iff_valid_deterministic` | same file | Base | pcq
  The Axioms cell must match what `lean_verify` reported in Phases 1-2 (write it out literally if
  it is not exactly `pcq`).
- [ ] Pin those four declarations: append their `'<name>' depends on axioms: [...]` lines to the
  C14 baseline heredoc in `scripts/check-module-invariants.sh` (the block that pins the
  `docs/theorem-index.md` headline rows), so the Axioms column stays generated rather than
  typed. This file is a proposed `file_scope` addition. If the heredoc mechanism turns out to
  need more than an appended line per declaration, drop the four ledger rows instead of leaving
  them unpinned, and say so in the summary.
- [ ] Confirm the C15 round trip: each ledger-row declaration's docstring carries the `Paper:`
  line written in Phases 1-2 (`—` + reason for R2, `` `app:deterministic` `` for R1).
- [ ] Commit by explicit path: the two parent READMEs, the root READMEs the inventory touched,
  `docs/theorem-index.md`, `scripts/check-module-invariants.sh`.

**Timing**: 1 hour

**Depends on**: 1, 2, 3

**Verification Tier**: prose

**Scope Hypothesis**: 6 files touched (`Semantics/README.md`, `Metalogic/README.md`,
`FormalSystem/README.md`, `README.md`, `docs/theorem-index.md`, `scripts/check-module-invariants.sh`);
which of the root READMEs actually change is decided by `--emit-inventory`'s diff, not by this
list — confirm with `git status --short` and stage only what changed.

**Files to modify**:
- `FormalSystem/Semantics/README.md` - hand-maintained Correspondence/ file list and count
- `FormalSystem/Metalogic/README.md` - generated blocks (re-emitted) + one hand row in the metatheory table
- `FormalSystem/README.md`, `README.md` - generated totals (re-emitted, if changed)
- `docs/theorem-index.md` - four rows
- `scripts/check-module-invariants.sh` - four C14 baseline lines (proposed file_scope addition)

**Verification**:
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- Diff read-through: every changed hunk outside `.lean` files is prose/table text; no line numbers
  cited; no task numbers in any file outside `specs/`
- `grep -n "6 files" FormalSystem/Semantics/README.md` no longer matches the Correspondence row

---

### Phase 5: Full acceptance gate and summary [NOT STARTED]

**Goal**: Run the task's acceptance bar unabridged over the finished tree and write the
implementation summary.

**Tasks**:
- [ ] Regenerate the root one final time (`lake exe mk_all --lib FormalSystem`) in case a
  concurrent session added a module, then `--check` (exit 0).
- [ ] `lake build --wfail` (full library). Background it if it exceeds the tool timeout and wait
  per `context/patterns/bounded-build-waiter.md` (hard timeout, `kill -0` on the captured PID,
  one waiter per log). Fix forward on any warning; never discard uncommitted work to reach green.
- [ ] `lean_verify` on all four headlines (`static_iff_uniformDwell`, `static_of_finite`,
  `validIn_iff_validDetIn`, `valid_iff_valid_deterministic`) and the three sharpness theorems:
  every axiom set ⊆ `[propext, Classical.choice, Quot.sound]`, no `sorryAx`. Record the literal
  sets in the summary.
- [ ] `bash scripts/check-module-invariants.sh` — all checks pass (C2, C3, C9 no task numbers,
  C14 baselines incl. the new pins, C15 anchors + `Paper:` round trip, C17 dead declarations,
  C18 duplicated prose, C19 docstring floor, C23/C26 naming, C24 `FormalSystem.Init` reachability,
  C27 no in-file `#print axioms`, C33 root byte-equality). Fix forward per check; never add an
  allowlist entry to quiet a new failure.
- [ ] `bash scripts/check-task-references.sh` (or the equivalent C9 run) clean over the new files.
- [ ] `git diff --quiet -- FormalSystem/Semantics/ShiftSet.lean` succeeds against the pre-task
  baseline `61b2dc82e`.
- [ ] Write `specs/646_formalize_rigidity_and_deterministic_same_logic/summaries/01_rigidity-same-logic-summary.md`
  per summary-format.md: what landed, the two R2 refinements (Seriality/reflection in the
  biconditional; density used once), the R1 helper fix, the sharpness witnesses, literal axiom
  profiles, gate outputs, and any file_scope additions actually used.
- [ ] Final commit by explicit path; `task 646: complete implementation`.

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: full

**Files to modify**:
- `FormalSystem.lean` - final regeneration only if the tree changed
- `specs/646_formalize_rigidity_and_deterministic_same_logic/summaries/01_rigidity-same-logic-summary.md` - new

**Verification**:
- `lake build --wfail` exit 0, zero warnings
- `lean_verify` ×7 as above
- `bash scripts/check-module-invariants.sh` all PASS
- `lake exe mk_all --lib FormalSystem --check` exit 0

## Lean Challenge Statements

**Authoring note.** The snapshot tool's matcher recognizes `theorem|lemma|def|instance` followed
by a *simple* name, forces that body to `sorry`, and discards everything between the `:=` and the
next matched declaration. The block below is shaped so nothing is lost: the two carriers `Static`
and `UniformDwell` sit in the preamble as `abbrev` (unmatched, bodies survive, out of the
identifier set); no theorem name is dotted; no `namespace`/`end` follows the first theorem — the
final namespace is left open on purpose. Consequences for the implementer: **the library declares
`Static` and `UniformDwell` with `def`** in `FormalSystem.Semantics.TaskFrame`; the R2 theorems
live in `FormalSystem.Semantics.TaskFrame` (`eq_of_rel_of_*`) and `FormalSystem.Semantics.FrameOver`
(`static_iff_uniformDwell`, `uniformDwell_of_finite`, `static_of_finite`), the helper is
`FormalSystem.Semantics.ShiftSet.frame_deterministic`, and the three R1 theorems live in
`FormalSystem.Metalogic.Deterministic` — where the challenge writes every name undotted in one
open namespace. Binder names are immaterial; binder types, hypotheses and conclusions are the
contract. The Phase 3 sharpness witnesses are deliberately absent (their `def` frame would be
erased by the matcher).

```lean
import Mathlib.Algebra.Order.Archimedean.Basic
import FormalSystem.Semantics.TaskFrame
import FormalSystem.Semantics.ShiftSet
import FormalSystem.Metalogic.Deterministic.Validity

namespace FormalSystem.Semantics.TaskFrame

/-- Challenge carrier; `def` in the library. A relation is static when `w ⇒_x u` iff `w = u`. -/
abbrev Static {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {W : Type} (R : W → D → W → Prop) : Prop :=
  ∀ w x u, R w x u ↔ w = u

/-- Challenge carrier; `def` in the library. A uniform dwell time: some `x₀ > 0` with
`(w)_{x₀} = {w}` for every `w`. -/
abbrev UniformDwell {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    {W : Type} (R : W → D → W → Prop) : Prop :=
  ∃ x₀ : D, 0 < x₀ ∧ ∀ w, cone R w x₀ = {w}

end FormalSystem.Semantics.TaskFrame

namespace FormalSystem.Semantics

open FormalSystem.Syntax
open FormalSystem.Metalogic.Deterministic
open FormalSystem.ProofSystem (FrameClass)

theorem eq_of_rel_of_step {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    [Archimedean D] {W : Type} {R : W → D → W → Prop}
    (hint : TaskFrame.Interpolates R) {ε : D} (hε : 0 < ε)
    (hstep : ∀ w u y, 0 ≤ y → y ≤ ε → R w y u → u = w) :
    ∀ w u x, 0 ≤ x → R w x u → u = w := sorry

theorem eq_of_rel_of_uniform_radius {D : Type} [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] [DenselyOrdered D] [Archimedean D] {W : Type}
    {R : W → D → W → Prop} (hint : TaskFrame.Interpolates R)
    {x₀ : D} (hx₀ : 0 < x₀) (hrad : ∀ w u y, |y| < x₀ → R w y u → u = w) :
    ∀ w u x, 0 ≤ x → R w x u → u = w := sorry

theorem static_iff_uniformDwell {D : TemporalOrder} [DenselyOrdered ↑D] [Archimedean ↑D]
    (F : FrameOver D) :
    TaskFrame.Static F.TaskRel ↔ TaskFrame.UniformDwell F.TaskRel := sorry

theorem uniformDwell_of_finite {D : TemporalOrder} (F : FrameOver D) [Finite F.WorldState] :
    TaskFrame.UniformDwell F.TaskRel := sorry

theorem static_of_finite {D : TemporalOrder} [DenselyOrdered ↑D] [Archimedean ↑D]
    (F : FrameOver D) [Finite F.WorldState] : TaskFrame.Static F.TaskRel := sorry

theorem frame_deterministic {D : TemporalOrder} (S : ShiftSet D) : S.frame.Deterministic := sorry

theorem validOnFrames_iff_deterministic {P : TaskFrame → Prop}
    (hP : ∀ (F : TaskFrame) (M : TaskModel F), P F → P (ShiftSet.ofModel F M).frame)
    (φ : Formula) :
    ValidOnFrames P φ ↔ ValidOnFrames (fun F => P F ∧ F.Deterministic) φ := sorry

theorem validIn_iff_validDetIn (fc : FrameClass) (φ : Formula) :
    ValidIn fc φ ↔ ValidDetIn fc φ := sorry

theorem valid_iff_valid_deterministic (φ : Formula) :
    Valid φ ↔ ∀ (F : TaskFrame), F.Deterministic → ∀ (M : TaskModel F)
      (τ : WorldHistory F) (t : F.Duration), TruthAt M τ t φ := sorry
```

## Testing & Validation

- [ ] Per-phase scoped `lake build --wfail <module>` green before any aggregator edit
- [ ] `lean_verify` on the four headlines and three sharpness theorems: axioms ⊆ `[propext, Classical.choice, Quot.sound]`, no `sorryAx`
- [ ] `lake build --wfail` (full) green at Phase 5
- [ ] `bash scripts/check-module-invariants.sh` all PASS at Phase 5; `--emit-inventory --check` exit 0 at Phases 4 and 5
- [ ] `lake exe mk_all --lib FormalSystem --check` exit 0 after every root regeneration
- [ ] `git diff --quiet 61b2dc82e -- FormalSystem/Semantics/ShiftSet.lean` succeeds at every commit
- [ ] No task numbers in any new or edited file outside `specs/` (C9 / `check-task-references.sh`)
- [ ] No `app:rigidity` anywhere in the tree (`grep -rn "app:rigidity" FormalSystem docs` empty)

## Artifacts & Outputs

- `FormalSystem/Semantics/Correspondence/Rigidity.lean` (new; R2)
- `FormalSystem/Metalogic/Deterministic/SameLogic.lean` (new; R1 + helper)
- `FormalSystem/Semantics/Correspondence/RigiditySharpness.lean` (new; proposed file_scope addition)
- `FormalSystem/Semantics/Correspondence.lean`, `FormalSystem/Metalogic/Deterministic.lean` (aggregators)
- `FormalSystem/Semantics/Correspondence/README.md`, `FormalSystem/Metalogic/Deterministic/README.md`,
  `FormalSystem/Semantics/README.md`, `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md`,
  `README.md` (as the inventory diff dictates)
- `FormalSystem.lean` (regenerated by `mk_all`)
- `docs/theorem-index.md` (four rows) and `scripts/check-module-invariants.sh` (four C14 pins;
  proposed file_scope addition)
- `specs/646_formalize_rigidity_and_deterministic_same_logic/summaries/01_rigidity-same-logic-summary.md`
- plans/01_rigidity-same-logic.md (this file)

## Rollback/Contingency

- Every phase adds new files and makes additive edits to aggregators, READMEs and the ledger;
  nothing existing is renamed or re-typed. Fix forward is the first rung: a failing lint or gate
  is corrected in the new source, never silenced by weakening a statement, adding an allowlist
  entry, or discarding work.
- If a module cannot be made green within its phase, do not commit it: delete the new file,
  remove its import/bullet/row, re-run `lake exe mk_all --lib FormalSystem` and `--check`, and
  record the blocker in the summary with the verbatim goal and what was tried.
- If R2's statement were to fail in-tree despite the scratch (not expected), the corrected
  statement or a compiled counterexample **is** the deliverable per the task description — report
  it in the summary and the handoff, never weaken silently.
- A genuine rollback of committed work follows `context/contracts/recovery.md`'s rollback rung
  (snapshot via `git-snapshot.sh 646` with its out-of-scope override only for the deliberate
  whole-tree case), never a bare precautionary snapshot as a routine phase step.
