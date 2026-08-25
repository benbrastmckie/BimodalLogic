# Implementation Plan: Wire the BiLasso Decision Layer into the Live Tree

- **Task**: 474 - Wire the BiLasso decision layer into the live tree
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/474_wire_bilasso_decision_layer_into_live_tree/reports/01_wire-bilasso-into-build-graph.md`
- **Artifacts**: plans/01_wire-bilasso-decision-layer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

`FormalSystem/Metalogic/Decidability/BiLasso/` is 19 files, sorry-free, with oleans built — and
unreachable from every Lake target root, so `lake build` never compiles it and no project
accounting reflects it. This plan registers the re-export in `Decidability.lean`, retires the
corresponding manifest entries in the same commit (C6 fails if a manifest entry names a module
that has become reachable), lands the three already-compiled 469-era probes as one live module
`BiLasso/Assembly.lean`, and corrects every documentation claim that becomes false — including a
new honest `specs/ROADMAP.md` entry.

This is routine engineering. No mathematics is required and none is attempted: nothing here
touches the finite-model theorem `fmp`, which stays open.

### Research Integration

The research report re-measured every claim in the task description against the tree and closed
eight risks by measurement rather than argument. The findings this plan is built on:

- **The 15 / 4 / 1 manifest split is exact**, re-derived by replaying `check-module-invariants.sh`'s
  own reachability algorithm (`scripts/check-module-invariants.sh`, the `roots`/`seen` walk)
  against a graph with the new import spliced in. Unreachable modules go **37 -> 22**; the 15 that
  flip are exactly the aggregator plus its 14 imports.
- **The three probes merge into one module and compile clean.** The merged source is at
  `specs/474_wire_bilasso_decision_layer_into_live_tree/evidence/assembly-merged-verified.lean` —
  built with `lake env lean` during research: exit 0, no errors, no warnings, all five
  declarations at `[propext, Classical.choice, Quot.sound]`. Deliverable (3) is transcription,
  not authoring. Two duplicate copies of `not_validDiscrete_of_satAtState` and one primed variant
  collapse to a single declaration.
- **Wiring is inert downstream**, verified: all seven modules that transitively consume
  `Decidability.lean` were re-elaborated with the BiLasso layer injected into scope. Seven for
  seven, exit 0, zero errors. The nine new `Decidable` instances and
  `Basic.lean`'s `instInhabitedFin` perturb nothing.
- **A manifest comment, obeyed literally, breaks C6** — see the Critical Trap section below.

### The Critical Trap (read before editing the manifest)

`scripts/module-invariants-manifest.txt`'s final block currently ends with:

> ... **DELETE this line when the bi-lasso re-export lands and the modules above are wired in.**
> `BimodalTest.Metalogic.PeriodicExtensionAxiomTest`

**Do not obey that instruction.** Deleting that line fails C6 with *"1 unreachable live module(s)
absent from scripts/module-invariants-manifest.txt"*, because this task does not touch
`Tests/BimodalTest.lean` and `PeriodicExtensionAxiomTest` therefore stays unreachable. It cannot
be wired in by this task either: it imports `BiLasso.Orbit`, which the non-goals hold outside the
re-export. **The line stays; its comment gets rewritten** so the next reader is not trapped the
same way. This plan's KEEP instructions override that comment; an implementer must not "fix" the
comment back.

### Prior Plan Reference

No prior plan. This is the first plan for this task.

### Roadmap Alignment

`specs/ROADMAP.md` mentions BiLasso zero times (re-measured during research). This plan adds a
`### Bi-Lasso Decision Layer` subsection under `## Other Open Items` (line ~1561), immediately
beside `### FMP Truth Preservation (task 82, ...)`, which is already tagged "**Decidability track
only**". There is no heading literally named "the decidability front"; that anchor is the correct
reading of the task's instruction. The entry is orthogonal to line ~1731's standing exclusion of
decidability-based completeness as a path to the representation theorem, which is not to be
weakened.

## Goals & Non-Goals

**Goals**:

- One import of `FormalSystem.Metalogic.Decidability.BiLasso` in
  `FormalSystem/Metalogic/Decidability.lean`, so `lake build` compiles the layer.
- Exactly 15 manifest lines deleted in that same commit, with the four-module
  `Extend`/`Successor`/`Orbit`/`Agreement` cluster and the `PeriodicExtension` line kept.
- The three compiled probes landed as live theorems in a new
  `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean`, wired into `BiLasso.lean`.
- An honest `specs/ROADMAP.md` entry: landed sorry-free, model-checks a *given* presentation,
  performs **no** part of the finite-model step.
- Every documentation claim that becomes false on these commits corrected in the commit that
  falsifies it.

**Non-Goals**:

- Do not touch `BiLasso/{Extend,Successor,Orbit,Agreement}.lean` or their four manifest lines.
- Do not delete the `FormalSystem.Semantics.Extension.PeriodicExtension` manifest line (retiring
  it is a separate, independent edit).
- Do not delete the `BimodalTest.Metalogic.PeriodicExtensionAxiomTest` manifest line despite its
  own comment saying to.
- Do not attempt any part of the finite-model theorem `fmp`. Nothing here decides the logic.
- Do not describe BiLasso as covering the semantic finite model property, and do not claim
  choice-freedom anywhere.
- Do not disturb `Decidability.lean`'s `## Status` block, rewritten earlier this session by a
  documentation-correction task to make explicit that the soundness/completeness claims are
  Hilbert-system results rather than tableau results. This task adds one import line and one
  `## Submodules` bullet to that file and nothing else.
- Do not edit `Tests/BimodalTest.lean` or anything under `FMP/`.
- Do not remove the 469-era evidence probes from `specs/469_.../evidence/` (they are not
  registered in `scripts/check-evidence-probes.sh`, so nothing depends on their removal).

## Decision: commit sequencing (settled here, not at implementation time)

The research report left one question open: whether `Assembly.lean` lands before or with
registration, noting both are C6-clean. **Settled: registration first, Assembly second.**

Registering the layer first (Phase 1) makes `BiLasso.lean` reachable. `Assembly.lean` then lands
in Phase 2 already reachable through that aggregator, so it never needs a manifest entry at all.
This is strictly better than the report's suggested order, which would have added a manifest line
in one commit and deleted it in the next:

- Phase 1's manifest edit is **exactly the 15 deletions** the task specifies — not 16 — so the
  commit matches the acceptance criterion literally.
- No transient manifest entry is ever created, so no reader of the history sees a line that
  exists for one commit.
- Registration is the riskier edit (it is what could perturb downstream elaboration); doing it
  first surfaces that risk before any new source is written.

Both phases are still separate commits, and deliverable (3) still gets its own phase as the task
requires.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Implementer obeys the `PeriodicExtensionAxiomTest` "DELETE this line" comment | H | M | Called out three times in this plan (Critical Trap, Non-Goals, Phase 1 tasks). C6 catches it immediately if it happens: "1 unreachable live module(s) absent from manifest" |
| Implementer deletes the four `Extend`/`Successor`/`Orbit`/`Agreement` lines along with the 15 | H | M | Phase 1 gives the exact manifest line ranges to delete (86-94, 99-104) and the exact ranges to keep (95-98, 111, 134). C6 catches it: those four modules stay unreachable and would become unmanifested |
| Name collision once the whole library and BiLasso share one environment | H | L | **Closed by measurement (R1).** A file importing `FormalSystem` and `...Decidability.BiLasso` elaborates clean; `check` and `SatAtState` resolve unambiguously |
| New global instances perturb downstream elaboration | H | L | **Closed by measurement (R2).** All seven downstream consumers re-elaborated with BiLasso injected: 7/7 exit 0, zero errors |
| C2 flagship axiom baseline shifts | H | L | **No mechanism.** C2 measures four `BXCanonical` theorems; `#print axioms` on an elaborated theorem is scope-independent and nothing in the BiLasso cone is a dependency. Asserted at the gate regardless |
| C3 sorry count rises | H | L | **No mechanism.** All 15 modules are sorry-free and the merged Assembly source compiles sorry-free as measured. Asserted at every phase gate |
| Slow `#eval`/`example` blocks enter the main build | M | L | **Closed by measurement (R5).** The only `#eval`s are in `Successor.lean` (lines ~141-153), which stays unreachable. `Basic.lean`'s four `by decide` examples are already compiled today by C6's per-module build |
| Build time blows up | M | L | **Closed (R6).** Every BiLasso olean already exists and is unchanged. Only `Assembly.lean`, four aggregators, and seven test consumers rebuild |
| `Decidability.lean`'s `## Status` block gets reverted to pre-session wording | M | M | Explicit non-goal; Phase 1 restricts the edit to +1 import and +1 bullet, verified by reading `git diff` for that file before committing |
| Import cycle via `Semantics.Validity` | H | L | **Closed.** `Semantics/Validity.lean` imports only `Semantics.Truth`, `Semantics.Extension.Extension`, `Syntax.Context` and Mathlib; nothing under `Semantics/` imports `Metalogic/` except the unreachable `PeriodicExtension.lean` |
| `#print axioms` left in `Assembly.lean` emits info diagnostics on every build | L | M | Phase 2 explicitly drops the five `#print axioms` lines from the evidence file and records the measured sets in the module docstring instead (the convention `Check.lean` uses) |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Register the layer and retire its manifest block (atomic) [NOT STARTED]

**Goal**: `lake build` compiles the bi-lasso decision layer, the manifest no longer names any of
the 15 modules that just became reachable, and every prose claim falsified by that change is
rewritten — all in one commit.

**Tasks**:

- [ ] Record the baseline: `bash scripts/check-module-invariants.sh --no-build` and note C6's
      unreachable count (expected 37) and C3's sole-sorry line.
- [ ] Add `import FormalSystem.Metalogic.Decidability.BiLasso` to
      `FormalSystem/Metalogic/Decidability.lean`, at the end of the existing import block (after
      `...Verified.Decidable`).
- [ ] Add one `## Submodules` bullet to `FormalSystem/Metalogic/Decidability.lean` describing
      `BiLasso` as the bi-lasso decision layer: decides satisfiability of a formula at a state of
      a *given* `IntPresentation`; entry point `check`, correctness `check_correct`. Match the
      existing bullet style.
- [ ] **Change nothing else in `Decidability.lean`.** Its `## Status` block was rewritten earlier
      this session; read `git diff FormalSystem/Metalogic/Decidability.lean` before staging and
      confirm the diff is exactly one import line plus one bullet.
- [ ] In `scripts/module-invariants-manifest.txt`, delete **exactly these 15 module-path lines**
      (currently lines 86-94 and 99-104):
      `...BiLasso.Basic`, `.Unfold`, `.Periodic`, `.Annotation`, `.Examples`, `.TruthLemma`,
      `.Decide`, `.Enumerate`, `.SmallModel`, `.Realized`, `.GoodCycle`, `.Extraction`,
      `.BoxOracle`, `.Check`, and the aggregator line
      `FormalSystem.Metalogic.Decidability.BiLasso` itself.
- [ ] **KEEP**, untouched, the four lines currently at 95-98:
      `...BiLasso.Extend`, `...BiLasso.Successor`, `...BiLasso.Orbit`, `...BiLasso.Agreement`.
      That cluster is closed (grep-confirmed: `Agreement` has no importer anywhere; `Orbit` is
      imported only by `Agreement` and by the unreachable `PeriodicExtensionAxiomTest`; `Extend`
      and `Successor` only by `Orbit`) and belongs to the effective-periodic-extension work.
- [ ] **KEEP** the `FormalSystem.Semantics.Extension.PeriodicExtension` module-path line
      (currently 111). It has zero importers anywhere and stays unreachable regardless. Retiring
      it is a separate task.
- [ ] **KEEP** the `BimodalTest.Metalogic.PeriodicExtensionAxiomTest` module-path line (currently
      134) **despite its own comment instructing deletion** — see the Critical Trap section.
- [ ] Rewrite the bi-lasso block comment (currently lines 74-85): the layer is now registered in
      `Decidability.lean` and built by `lake build`; the four remaining lines in the block are the
      effective-periodic-extension cluster, which the re-export deliberately does not carry and
      which stays until that work wires itself in.
- [ ] Rewrite the `PeriodicExtensionAxiomTest` block comment (currently 129-133): remove the
      "DELETE this line when the bi-lasso re-export lands" instruction and replace it with the
      real reason the module stays unwired — it imports `BiLasso.Orbit`, which is outside the
      re-export and outside this task's scope.
- [ ] Correct the one stale clause in the `PeriodicExtension` block comment (currently 106-110),
      which justifies non-registration by "while the bi-lasso decision layer above is in flight" —
      a rationale that no longer holds. **Comment text only; the module-path line beneath it is
      not touched and not deleted.**
- [ ] Rewrite `FormalSystem/Metalogic/Decidability/BiLasso.lean`'s entire
      `## This aggregator is not itself imported` section. Every sentence in it becomes false on
      this commit. Replace it with a short section recording that the layer is registered in
      `Decidability.lean` and built by `lake build`, and that the four non-re-exported modules
      remain manifested for the C6 rot guard. Leave the `## Not re-exported here` section as is.
- [ ] Stage exactly these three files and commit as one commit.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts 15 manifest deletions at lines 86-94 and 99-104, 4 keeps
at 95-98, and that exactly 15 modules flip to reachable (37 -> 22). Confirm at implementation
time by (a) `git diff --stat scripts/module-invariants-manifest.txt` showing 15 deleted
module-path lines plus the comment rewrites, and (b) `check-module-invariants.sh` reporting
`all 22 unreachable live module(s) are manifested`. If the count is not 22, stop and re-derive
rather than adjusting the manifest to fit. The intermediate state (import added, manifest not yet
edited, or vice versa) is expected red — C6 fails in both directions — which is why this phase is
`atomic-batch`.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability.lean` — +1 import, +1 `## Submodules` bullet, nothing else
- `scripts/module-invariants-manifest.txt` — -15 module-path lines, 3 block comments rewritten
- `FormalSystem/Metalogic/Decidability/BiLasso.lean` — `## This aggregator is not itself imported`
  section rewritten

**Verification**:

- `lake build` exits 0
- `lake build BimodalTest` exits 0
- `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED, with:
  - C6: `all 22 unreachable live module(s) are manifested` (down from 37)
  - C6 reports no manifest entry naming a reachable module
  - C2: all four flagship axiom sets match baseline
  - C3: `sole structural sorry is in theorem countermodel_discrete (.../WeakCanonical/Transfer.lean)`
  - C5: markdown module paths still resolve
- `git diff --cached FormalSystem/Metalogic/Decidability.lean` shows exactly one import line and
  one bullet added, and no change inside the `## Status` block

---

### Phase 2: Land the three probes as `BiLasso/Assembly.lean` [NOT STARTED]

**Goal**: The three 469-era probes become live, machine-checked theorems in the build graph as one
module with five declarations, reachable through `BiLasso.lean` and therefore requiring no
manifest entry.

**Tasks**:

- [ ] Create `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` by transcribing
      `specs/474_wire_bilasso_decision_layer_into_live_tree/evidence/assembly-merged-verified.lean`.
      This source compiled clean during research (`lake env lean`, exit 0, no warnings) — it is
      drop-in modulo the header and docstring. **Do not re-author the proofs.**
- [ ] Add the standard Apache copyright header (match any sibling under `BiLasso/`).
- [ ] Add a module docstring in the house style: what the module assembles (given `fmp`, the
      route from `check` to `Decidable (ValidDiscrete φ)`), the five declaration names, and the
      measured axiom sets `[propext, Classical.choice, Quot.sound]`. State plainly that this
      module assumes `fmp` as a hypothesis and does not prove it, and that computability of the
      resulting instance is not choice-freedom — the two are different properties and only the
      first is claimed. `BiLasso/README.md` already records why no finite-carrier route can be
      choice-free (`wlem_of_spherical`); paraphrase, do not contradict.
- [ ] **Drop the five trailing `#print axioms` lines** from the evidence source. They would emit
      info diagnostics on every build. The measured sets belong in the docstring instead — the
      convention `Check.lean` uses.
- [ ] Keep the namespace `FormalSystem.Metalogic.Decidability` (matching `Check.lean` and the
      probes), **not** a `BiLasso` sub-namespace: `check`, `check_correct`, `SatAtState` and
      `IntPresentation` all live there. The five names were grep-confirmed unused in the tree.
- [ ] Add `import FormalSystem.Metalogic.Decidability.BiLasso.Assembly` to
      `FormalSystem/Metalogic/Decidability/BiLasso.lean`, after the `Check` import.
- [ ] Add a matching `## Submodules` bullet to `BiLasso.lean` for `Assembly`, naming the five
      declarations.
- [ ] **Do not add `Assembly` to the manifest.** It is reachable the moment `BiLasso.lean` imports
      it, and `BiLasso.lean` became reachable in Phase 1. C6 fails if a manifest entry names a
      reachable module.
- [ ] Measure the axiom sets independently: write a scratch file (outside the source tree)
      importing `FormalSystem.Metalogic.Decidability.BiLasso.Assembly` with `#print axioms` on all
      five names, run it with `lake env lean`, and confirm each prints
      `[propext, Classical.choice, Quot.sound]`. Record the output in the phase notes.
- [ ] Commit `Assembly.lean` and the `BiLasso.lean` change together.

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts one new file, five declarations
(`not_validDiscrete_of_satAtState`, `validDiscrete_iff_check`, `decidableValidDiscrete`,
`validDiscrete_iff_checkFamily`, `decidableValidDiscreteFamily`), and no manifest change. Confirm
by `grep -cE '^(theorem|def) ' FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` giving
5, and by `git diff scripts/module-invariants-manifest.txt` being empty for this phase.
`atomic-batch` is required because the intermediate state — `Assembly.lean` written but not yet
imported by `BiLasso.lean` — is a live module that is unreachable and unmanifested, which fails
C6.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` — **new**, five declarations
- `FormalSystem/Metalogic/Decidability/BiLasso.lean` — +1 import, +1 `## Submodules` bullet

**Verification**:

- `lake build` exits 0; `lake build BimodalTest` exits 0
- `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED, with C6 still at **22**
  unreachable (Assembly is reachable, so the count does not move), C2 baseline unchanged, C3 still
  the sole `countermodel_discrete` sorry
- The scratch `#print axioms` run prints `[propext, Classical.choice, Quot.sound]` for all five
  declarations
- `grep -n 'sorry' FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` returns nothing

---

### Phase 3: Correct `BiLasso/README.md` [NOT STARTED]

**Goal**: The layer's own README stops describing the assembly as retained evidence under
`specs/469_.../evidence/` and points at the live module.

**Tasks**:

- [ ] In `FormalSystem/Metalogic/Decidability/BiLasso/README.md`, rewrite the sentence in the
      `## What decidability of ValidDiscrete still needs` section that says the assembly and its
      converse "have been compiled sorry-free, and are retained under
      `specs/469_eliminate_the_bridge_filtration_into_intpresentation/evidence/`". Point instead
      at `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` and name the five
      declarations.
- [ ] Preserve the three "things this establishes" bullets that follow — they are still true and
      still measured.
- [ ] Do not weaken the `fmp` framing above it: `fmp` remains exactly one open theorem, its crux
      is box-faithfulness, and it is genuinely hard.
- [ ] Do not fix the pre-existing, unrelated line-count drift in the Modules table (`Check.lean`
      listed as 249 lines; it is 299) — out of scope, and noted here only so it is not mistaken
      for damage introduced by this task.
- [ ] Commit.

**Timing**: 30 minutes

**Depends on**: 2

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts a single stale pointer in one README section. Confirm at
implementation time with
`grep -n '469_eliminate_the_bridge_filtration' FormalSystem/Metalogic/Decidability/BiLasso/README.md`
returning nothing after the edit; if it returns other occurrences that are genuinely about the
469 refutation probes rather than the assembly, leave those and record the distinction.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` — assembly pointer -> live module

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` passes, with C5 green: the new path
  `FormalSystem.Metalogic.Decidability.BiLasso.Assembly` resolves (this README **is** C5-linted,
  unlike anything under `specs/`)
- Diff read-through confirms every changed hunk is prose

---

### Phase 4: Add the honest ROADMAP entry [NOT STARTED]

**Goal**: `specs/ROADMAP.md` accounts for the bi-lasso decision layer — for the first time — and
states its status without overclaiming.

**Tasks**:

- [ ] Add a `### Bi-Lasso Decision Layer` subsection under `## Other Open Items`, immediately
      beside `### FMP Truth Preservation`, which is already tagged "**Decidability track only**".
- [ ] Content, paraphrasing the wording already vetted in `BiLasso/README.md` rather than
      inventing new claims:
      - Landed sorry-free; 19 files; registered in the build graph as of this commit.
      - Decides truth of a formula at a state of a **given** `IntPresentation` — a finite graph on
        `Fin card` with a `Bool` valuation. Entry point `check` (`Check.lean`), correctness
        `check_correct`, plus a computing `Decidable` instance.
      - **It does not decide the logic.** Nothing in it quantifies over frames;
        `cor:tm-decidability` stays open.
      - **It performs no part of the finite-model step.** `exists_annot_of_truth` takes a
        `WorldHistory P.toTaskFrame` as input — it compresses histories *within* a presentation;
        it does not produce a presentation from an arbitrary countermodel.
      - What remains is exactly one theorem, `fmp`:
        `∀ ψ, ¬ ValidDiscrete ψ → ∃ P ∈ cands ψ, ∃ w, SatAtState P w ψ.neg` for computable
        `cands : Formula → List IntPresentation`. Its crux is box-faithfulness and it is
        genuinely hard.
      - Given `fmp`, the assembly to `Decidable (ValidDiscrete φ)` is now live and
        machine-checked: `validDiscrete_iff_checkFamily` / `decidableValidDiscreteFamily` in
        `BiLasso/Assembly.lean`.
      - Axioms: `[propext, Classical.choice, Quot.sound]`. No choice-freedom is claimed.
- [ ] **Do not write that BiLasso covers the semantic finite model property.**
- [ ] Do not weaken the standing exclusion (around line 1731) of decidability-based completeness
      as a path to the representation theorem. This entry is orthogonal to it.
- [ ] Commit.

**Timing**: 45 minutes

**Depends on**: 2

**Verification Tier**: prose

**Files to modify**:

- `specs/ROADMAP.md` — new `### Bi-Lasso Decision Layer` subsection under `## Other Open Items`

**Verification**:

- `grep -c 'BiLasso' specs/ROADMAP.md` is now non-zero (was 0)
- The subsection contains no claim that BiLasso proves, covers, or partially covers the finite
  model property, and no claim of choice-freedom
- Full harness green: `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED
  (`specs/ROADMAP.md` is under `specs/`, so C5's markdown module-path lint and C9's
  task-reference lint do not apply to it, but the harness is run as the task's closing gate)

---

## Testing & Validation

The task's acceptance criteria, each with the command that measures it:

- [ ] `lake build` exits 0
- [ ] `lake build BimodalTest` exits 0
- [ ] `bash scripts/check-module-invariants.sh` prints ALL CHECKS PASSED (C1, C2, C3, C6 among
      them)
- [ ] C6 reports **no manifest entry naming a reachable module** and
      `all 22 unreachable live module(s) are manifested` (down from 37)
- [ ] C3 reports the sole structural sorry as `theorem countermodel_discrete` in
      `FormalSystem/Metalogic/WeakCanonical/Transfer.lean`, and the count has not increased
- [ ] The five `Assembly.lean` declarations each measure `[propext, Classical.choice, Quot.sound]`
      via a scratch `#print axioms` file run with `lake env lean` — **no choice-freedom is
      promised**
- [ ] `git log --oneline` shows deliverables (1) and (2) in a **single** commit
- [ ] The four `Extend`/`Successor`/`Orbit`/`Agreement` manifest lines, the
      `FormalSystem.Semantics.Extension.PeriodicExtension` line, and the
      `BimodalTest.Metalogic.PeriodicExtensionAxiomTest` line are all still present

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/BiLasso/Assembly.lean` (new, 5 declarations, sorry-free)
- `FormalSystem/Metalogic/Decidability.lean` (+1 import, +1 bullet)
- `FormalSystem/Metalogic/Decidability/BiLasso.lean` (+1 import, +1 bullet, one section rewritten)
- `scripts/module-invariants-manifest.txt` (-15 module-path lines, 3 block comments rewritten)
- `FormalSystem/Metalogic/Decidability/BiLasso/README.md` (assembly pointer -> live module)
- `specs/ROADMAP.md` (new `### Bi-Lasso Decision Layer` subsection)
- `specs/474_wire_bilasso_decision_layer_into_live_tree/summaries/01_*-summary.md`

## Rollback/Contingency

Every phase is a single commit, so `git revert <sha>` reverts a phase cleanly and leaves the tree
green — the pre-task state is a fully passing harness at 37 unreachable modules.

- If Phase 1's gate fails on an unexpected downstream elaboration error (contradicting research
  finding R2), revert the commit, capture the failing module and error text, and treat it as a
  genuinely new finding rather than adjusting the manifest to hide it. Do **not** work around it
  by leaving the layer half-registered: the import and the manifest deletions must stay in step.
- If C6 reports a count other than 22, do not edit the manifest until the discrepancy is
  explained. The likely causes are (a) the four-module cluster deleted by mistake, (b) the
  `PeriodicExtensionAxiomTest` line deleted per its misleading comment, or (c) an unrelated
  concurrent edit elsewhere in the tree.
- No `sorry` is introduced, no axiom is added, and nothing is deferred, so there is no partial
  state that needs a follow-up task if the work stops between phases: Phases 1 and 2 each leave
  the harness green on their own, and Phases 3-4 are prose-only.
