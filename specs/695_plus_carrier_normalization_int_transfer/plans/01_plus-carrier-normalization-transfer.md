# Implementation Plan: L⁺ carrier normalization (`plusValidZTime_iff_plusValidInt`)

- **Task**: 695 - plus_carrier_normalization_int_transfer
- **Status**: [NOT STARTED]
- **Effort**: 2.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/695_plus_carrier_normalization_int_transfer/reports/01_plus-carrier-normalization-transfer.md`
- **Artifacts**: plans/01_plus-carrier-normalization-transfer.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Land `plusValidZTime_iff_plusValidInt` — the L⁺ twin of `Semantics.validZTime_iff_validInt` — as a
new module `FormalSystem/PlusLanguage/PlusIntTransfer.lean`, pinned in the C2 axiom baseline and
ledgered in `docs/theorem-index.md`, with zero sorries and no new axiom. **There is no mathematics
left to discover**: research compiled the entire route as a 111-line probe
(`specs/695_plus_carrier_normalization_int_transfer/probes/01_plus_int_transfer_probe.lean`) against
the built library with `lake env lean` — zero errors, zero warnings, zero sorries, axiom set
`[propext, Classical.choice, Quot.sound]` for both new theorems. This plan therefore spends its
phases on siting, docstrings and the gate-bookkeeping surface that a new `FormalSystem/` module
drags behind it, and treats the probe as the transcription source for the proof bodies.

The shape question the task description left open is decided here and not rediscovered mid-proof:
**a direct seven-case `plusTruthAt_map`, not a `PlusTruthCorr` structure** (see Goals, and D1 in the
research report). The reason is not proof length — the seven-case induction is paid either way,
because `PlusTruthAt` is a native recursion on `PlusFormula` and cannot delegate to
`Truth.truthAt_of_truthCorr` at any constructor except `atom`. It is that
`Semantics/TruthClauses.lean`'s stated extension contract forbids the generic home such a structure
would want ("**No recursor** … Nothing provable only by `induction φ` belongs here"), and the three
L⁺/L⋆ transports already landed in this tree (`plusTruthAt_timeShift`, `plus_invariance`,
`star_invariance`) are all direct inductions for exactly that reason. The `atom` case *does* reuse
the existing `alignedCorr` instance, written inline so the `Rel` projection reduces.

Definition of done: `lake build` green with zero sorries in the new module; the full (non-`--no-build`)
`scripts/check-module-invariants.sh` showing no NEW red beyond the inherited C28 failure recorded in
Phase 1's baseline; C2 reporting the widened pinned set; and the `docs/theorem-index.md` rows
resolving under C15's second assertion.

### Research Integration

Findings carried directly into phases:

- **The route is compiled, not conjectured.** Phase 1 transcribes the probe; it does not re-derive
  proofs. The `stab` case costs eight lines because `(FrameOver.map F e).toTaskFrame.WorldState` is
  *definitionally* `F.WorldState`, so both sides of the state-agreement side condition are the same
  equation in one type — no `HEq`, no transport, no world-state bijection.
- **Siting**: new module `FormalSystem/PlusLanguage/PlusIntTransfer.lean`, namespace
  `FormalSystem.PlusLanguage`, importing `FormalSystem.Semantics.IntTransfer` and
  `FormalSystem.PlusLanguage.PlusValidity`. Import direction verified acyclic (the transitive
  `FormalSystem.*` closure of `Semantics.IntTransfer` is 26 modules and contains no `PlusLanguage.*`).
  `PlusLanguage/README.md`'s "Syntax before semantics" section is the placement precedent: L⁺
  semantic modules live in `PlusLanguage/`, and only genuine two-family bridges stay at the
  `Semantics/` root.
- **C2's four coordinated edits** (Phase 2) and the **C15 second assertion's `Paper: — (reason)`
  obligation** (Phase 1 and Phase 3) are lifted verbatim from the report's gate survey.
- **D5 is resolved as "do it"** (Phase 2): the L-side twin `Semantics.validZTime_iff_validInt` is
  pinned by neither C2 nor C14 and has no ledger row. Pinning it alongside costs one extra line in
  each C2 heredoc, one extra index row and one `Paper:` line, and removes the drift where the L⁺
  twin is ledgered and the L twin it mirrors is not. Its axiom set was independently re-confirmed
  during planning as `[propext, Classical.choice, Quot.sound]`.
- **One bookkeeping obligation the research report did not name, confirmed during planning**:
  `scripts/measure-refactor-partitions.py`'s `LANGUAGE_FILE_LAYERS["PlusLanguage"]` table needs a
  `"PlusIntTransfer": 1` row, or `layer_of` *raises* and `scripts/check-metalogic-cycles.sh`'s
  syntax-before-semantics assertion fails naming the file. The table's own comment records this as
  deliberate ("A new file in a language directory needs a row here; without one `layer_of` raises"),
  and `PlusLanguage/README.md` restates it in bold. Phase 1 owns it.
- **A C9 trap, also added during planning**: C9 asserts zero task-number citations under
  `FormalSystem/`, `README.md` and `scripts/`. None of the new Lean prose, the C2 header clause, or
  the README rows may cite this task by number.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch and no ROADMAP.md was consulted.

## Goals & Non-Goals

**Goals**:

- `plusTruthAt_map`
- `PlusValidInt`
- `plusValidZTime_iff_plusValidInt`

**Non-Goals**:

- No `PlusTruthCorr` structure and no change to `Semantics/TruthTransport.lean` or
  `Semantics/TruthClauses.lean` — D1 retires that shape; `TruthClauses.lean`'s "No recursor"
  contract is read-only precedent here.
- No change to `Semantics/Frames/TranslationProduct.lean` — `plus_invariance` is the seven-case
  template, consulted read-only, not edited.
- No L⁺ decidability work. This task supplies the prerequisite carrier normalization only; nothing
  downstream of it is attempted.
- No repair of the pre-existing C28 red on `FormalSystem/Version.lean`, and no
  `warning-budget.py --update` run. That failure is committed at HEAD, outside this task's scope,
  and blessing it is a worse outcome than reporting it.
- No CI change. C2 does not run in CI (`--no-build` mode skips C1/C2/C6/C24, per
  `docs/development/CI_CD_PROCESS.md`'s "Known Not-in-CI Gaps"), so the new pin protects the full
  local gate only. Recorded, not fixed.

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.IntTransfer
import FormalSystem.PlusLanguage.PlusValidity

namespace FormalSystem.PlusLanguage

open FormalSystem.Syntax
open FormalSystem.Semantics

variable {D E : TemporalOrder}

theorem plusTruthAt_map {F : FrameOver D} [F.IsRegular]
    (e : ↑D ≃+o ↑E) (M : TaskModel F.toTaskFrame) (φ : PlusFormula) :
    ∀ (σ : WorldHistory F.toTaskFrame) (σ' : WorldHistory (FrameOver.map F e).toTaskFrame),
      Aligned e σ σ' →
      ∀ t : ↑D, (PlusTruthAt M σ t φ ↔ PlusTruthAt (TaskModel.map M e) σ' (e t) φ) := sorry

def PlusValidInt (φ : PlusFormula) : Prop := sorry

theorem plusValidZTime_iff_plusValidInt (φ : PlusFormula) :
    PlusValidZTime φ ↔ PlusValidInt φ := sorry

end FormalSystem.PlusLanguage
```

`PlusValidInt`'s real body (a `def`, not a theorem, so `sorry` above pins only its type) is the
binder-for-binder mirror of `Semantics.ValidInt`:

```
∀ (F : FrameOver intOrder) [F.IsRegular] (M : TaskModel F.toTaskFrame)
  (τ : WorldHistory F.toTaskFrame) (t : ℤ), PlusTruthAt M τ t φ
```

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C2's baseline is compared by exact whole-block string equality; a row appended to `AXIOM_BASELINE` but not `AX_SRC`, or at a different position, fails the gate with a confusing "diverged" message | H | M | Phase 2 edits both heredocs in one pass, at the same position and in the same order, then re-runs the full (non-`--no-build`) harness before committing. C14's header comment spells the contract out ("Edit them together, appending to both") and it holds for C2 identically |
| C15's second assertion fails because a new `docs/theorem-index.md` row's declaration carries no `Paper:` line | H | M | Both index rows' declarations get a `Paper: — (reason)` line whose value begins `— (`, copying `PlusValidity.lean`'s landed form. The L-side twin has no such line today, so Phase 3 adds one to `IntTransfer.lean` |
| C34b fires on `plusTruthAt_map` (it carries a bracketed `[F.IsRegular]` binder) because its docstring inherits `IntTransfer.lean`'s module prose about *Limit* / *Saturation* | M | M | Keep the tokens *Compositionality*, *Seriality*, *Limit*, *Saturation* out of all three declaration `/-- … -/` blocks. C34b's trigger is constraint vocabulary plus negation/consumption vocabulary in the declaration's own doc block; module-level `/-! … -/` prose is out of its scope, so any such discussion goes there |
| Missing `"PlusIntTransfer": 1` row in `measure-refactor-partitions.py` → `layer_of` raises, `check-metalogic-cycles.sh` fails | H | M | Phase 1 adds the row in the same commit as the new file and runs `bash scripts/check-metalogic-cycles.sh` as part of its own verification |
| Forgetting `lake exe mk_all --lib FormalSystem` → C33 red (byte-currency of the generated root, enforced and build-free) | M | M | Phase 1 regenerates the root in the same commit as the new file |
| `--emit-inventory` rewrites generated blocks in READMEs beyond this task's concern, and staging over-reaches | M | M | Phase 4 runs `--emit-inventory`, then `git status --short` and `git diff`, and stages only the paths whose inventory block actually moved because of the new file. Never `git add -A`, `git add .`, `git commit -am`, or a directory/glob pathspec (`.claude/rules/git-workflow.md`) |
| The pre-existing C28 red (`FormalSystem/Version.lean`, `linter.style.longLine`) is mistaken for a regression of this task's making, or "fixed" with `--update` | M | M | Phase 1 captures the pre-edit gate baseline to a scratch file *before* any edit and cites it in every later comparison. `Version.lean` is unmodified in the working tree, so the red is committed and inherited |
| A task-number citation lands under `FormalSystem/`, `scripts/` or `README.md` → C9 red | L | M | No task number appears in any new Lean prose, the C2 header clause, the index rows, or the README rows. Durable anchors only (declaration names, file paths) |
| Concurrent siblings (697–700) share this working tree this cycle | M | M | Their declared scopes (`scripts/typst-*.sh`, `typst/generated/status.typ`, `specs/state.json`, own task dirs) are disjoint from every path below except `specs/state.json`, which only status-sync writes. Re-read each file immediately before editing; commit only this task's own hunks; never run `git-snapshot.sh` in its reverting default mode; a build failure outside this task's file list may be a sibling's in-flight edit |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | — |
| 2 | 2, 3 | 1 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel. Phases 2 and 3 touch disjoint files
(`scripts/check-module-invariants.sh` versus `docs/theorem-index.md` +
`FormalSystem/Semantics/IntTransfer.lean`), which is why they share a wave.

### Phase 1: Land `PlusIntTransfer.lean` and make the build green [NOT STARTED]

**Goal**: The new module exists, compiles inside the library build graph with zero sorries, and
every mechanical registration a new `FormalSystem/` file requires is in place.

**Tasks**:

- [ ] Capture the pre-edit gate baseline before touching anything:
      `bash scripts/check-module-invariants.sh --no-build 2>&1 | tee <scratchpad>/695-gate-baseline.txt`,
      and record which checks are already red (C28 on `FormalSystem/Version.lean` is expected).
      This file is the reference for "no NEW red" in every later phase.
- [ ] Create `FormalSystem/PlusLanguage/PlusIntTransfer.lean`: the Apache copyright header and a
      module `/-! … -/` docstring shaped like `PlusValidity.lean`'s, then
      `import FormalSystem.Semantics.IntTransfer` / `import FormalSystem.PlusLanguage.PlusValidity`,
      `namespace FormalSystem.PlusLanguage`, `open FormalSystem.Syntax`,
      `open FormalSystem.Semantics`, `variable {D E : TemporalOrder}`.
- [ ] Transcribe the three declarations from the probe **verbatim**, in the order `plusTruthAt_map`,
      `PlusValidInt`, `plusValidZTime_iff_plusValidInt`. Keep the
      `(D := F.Duration) (E := intOrder) (F := F.toFibre)` ascriptions — Lean cannot invert
      `↑E ≟ ℤ` to recover `E := intOrder`, the same recorded reason `IntTransfer.lean` carries them.
      Drop the probe's `#print axioms` lines.
- [ ] Write the three declaration docstrings. `plusValidZTime_iff_plusValidInt`'s MUST contain a
      `Paper: — (…)` line whose value begins `— (`, copying `PlusValidity.lean`'s landed form
      (`Paper: — (formalization-native; …)`). Keep the tokens *Compositionality*, *Seriality*,
      *Limit* and *Saturation* out of all three `/-- … -/` blocks (C34b); any such discussion goes
      in the module-level `/-! … -/` header. Give `PlusValidInt` the eight-binder-collapse note
      `ValidInt`'s docstring carries. No task-number citation anywhere (C9).
- [ ] Add `"PlusIntTransfer": 1,` to `LANGUAGE_FILE_LAYERS["PlusLanguage"]` in
      `scripts/measure-refactor-partitions.py` (semantic half ⇒ layer 1).
- [ ] Add `import FormalSystem.PlusLanguage.PlusIntTransfer` to `FormalSystem/PlusLanguage.lean` and
      a bullet for it in that file's `## Semantic modules` list.
- [ ] Regenerate the library root: `lake exe mk_all --lib FormalSystem`, then confirm
      `FormalSystem.lean` gained exactly the one new import line.
- [ ] `lake build`, then confirm zero sorries in the new module and
      `#print axioms FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` /
      `... .plusTruthAt_map` both reporting `[propext, Classical.choice, Quot.sound]`.
- [ ] Commit (scoped: the new file, `PlusLanguage.lean`, `FormalSystem.lean`,
      `measure-refactor-partitions.py`).

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: full

**Scope Hypothesis**: the module is expected to be ~180–220 lines (proof bodies ~75 lines from the
probe, the rest docstrings), and the registration surface is expected to be exactly the four
non-`.lean`-module files listed above. Confirm at implementation time by `wc -l` on the new file and
by `git status --short` after the build: any fifth registration file that turns out to be needed is
a scope correction to report, not to absorb silently.

**Files to modify**:

- `FormalSystem/PlusLanguage/PlusIntTransfer.lean` - NEW: module docstring, `plusTruthAt_map`, `PlusValidInt`, `plusValidZTime_iff_plusValidInt`
- `FormalSystem/PlusLanguage.lean` - add the import line and a `## Semantic modules` bullet
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem` (one new import line)
- `scripts/measure-refactor-partitions.py` - add `"PlusIntTransfer": 1` to `LANGUAGE_FILE_LAYERS["PlusLanguage"]`

**Verification**:

- `lake build` exits 0 with no warning attributable to the new module.
- `grep -c sorry FormalSystem/PlusLanguage/PlusIntTransfer.lean` is 0.
- `#print axioms` on both new theorems reports `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/check-metalogic-cycles.sh` passes (this is what the layer row buys).
- `bash scripts/check-module-invariants.sh --no-build` shows C33 green and no NEW red against
  `<scratchpad>/695-gate-baseline.txt`.

---

### Phase 2: Pin both twins in the C2 axiom baseline [NOT STARTED]

**Goal**: `plusValidZTime_iff_plusValidInt` and its L-side mirror `Semantics.validZTime_iff_validInt`
are both pinned by C2, and C2 passes.

**Tasks**:

- [ ] Re-read `scripts/check-module-invariants.sh` immediately before editing (a sibling may have
      touched the tree).
- [ ] Append to the `AXIOM_BASELINE` heredoc, in this order, at the end of the block:
      `'FormalSystem.Semantics.validZTime_iff_validInt' depends on axioms: [propext, Classical.choice, Quot.sound]`
      then
      `'FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt' depends on axioms: [propext, Classical.choice, Quot.sound]`.
- [ ] Append the two matching `#print axioms` directives to the `AX_SRC` heredoc **in the same
      order and the same relative position**. The comparison is exact whole-block string equality,
      so the two heredocs' orders must agree.
- [ ] Change `pass C2 "all fourteen pinned axiom sets match baseline"` to `"all sixteen …"`.
      Re-check the two other `fourteen` occurrences in this script (the `lean_exe` root count and
      the elaboration-coverage note) and leave both alone — they are different subjects.
- [ ] Extend the C2 block's header prose with a clause for the two new rows (carrier normalization
      for L and L⁺: the reduction from arbitrary discrete duration carriers to `ℤ`, which any
      integer-indexed enumeration route rests on). No task-number citation (C9).
- [ ] Run the **full** harness (not `--no-build`) and confirm C2 passes with the widened set.
- [ ] Commit (scoped: `scripts/check-module-invariants.sh` only).

**Timing**: 30 minutes

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: exactly four coordinated edit sites in one file — the two heredocs, the
spelled-out count string, and the header prose. Confirm at implementation time with
`grep -n "fourteen\|sixteen" scripts/check-module-invariants.sh` (expect the count string changed
and the two unrelated occurrences untouched) and by reading the diff for symmetry between the two
heredocs.

**Files to modify**:

- `scripts/check-module-invariants.sh` - `AXIOM_BASELINE` + `AX_SRC` heredocs, the C2 pass-message count string, the C2 header prose

**Verification**:

- `bash scripts/check-module-invariants.sh` (full, with build) reports
  `PASS  C2  all sixteen pinned axiom sets match baseline`.
- No NEW red against `<scratchpad>/695-gate-baseline.txt`; C21 stays green (it only asserts that
  names on `MainResults.lean` are pinned, so widening the baseline cannot break it).

---

### Phase 3: Ledger both twins in `docs/theorem-index.md` [NOT STARTED]

**Goal**: Both carrier-normalization theorems have ledger rows, and C15's second assertion resolves
each row's `Paper:` anchor at its declaration.

**Tasks**:

- [ ] Re-read `docs/theorem-index.md` and `FormalSystem/Semantics/IntTransfer.lean` immediately
      before editing.
- [ ] Insert two rows into `### Decidability`, immediately **before** the
      `SharingSkeleton.total_eq_thread` row that opens the branching L⁺ stack (carrier normalization
      is that stack's prerequisite), L side first:
      - `| — | {statement} | \`FormalSystem.Semantics.validZTime_iff_validInt\` | \`FormalSystem/Semantics/IntTransfer.lean\` | ZTime | pcq pinned:C2 |`
      - `| — | {statement} | \`FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt\` | \`FormalSystem/PlusLanguage/PlusIntTransfer.lean\` | ZTime | pcq pinned:C2 |`
      Six cells exactly, with backticks around the Lean name and the file path and no line number in
      the File cell — C15's row regex requires that shape.
- [ ] Add a `Paper: — (…)` line to `validZTime_iff_validInt`'s existing `/-- … -/` block in
      `FormalSystem/Semantics/IntTransfer.lean`; it has none today, and without it the new L-side row
      is a hard C15 failure. The value must begin `— (` and give a one-clause reason (carrier
      normalization is formalization-native; the paper quantifies over its intended carrier and
      supplies no such reduction).
- [ ] Confirm `plusValidZTime_iff_plusValidInt`'s own `Paper:` line (written in Phase 1) satisfies
      the same shape.
- [ ] Commit (scoped: `docs/theorem-index.md`, `FormalSystem/Semantics/IntTransfer.lean`).

**Timing**: 25 minutes

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: exactly two new ledger rows and exactly one added `Paper:` line (the L⁺
declaration's was written in Phase 1). Confirm at implementation time by
`grep -c "pinned:C2" docs/theorem-index.md` before and after (expect +2) and
`grep -n "Paper:" FormalSystem/Semantics/IntTransfer.lean` (expect exactly one hit, at
`validZTime_iff_validInt`).

**Files to modify**:

- `docs/theorem-index.md` - two new rows in `### Decidability`, before the `SharingSkeleton.total_eq_thread` row
- `FormalSystem/Semantics/IntTransfer.lean` - add a `Paper: — (reason)` line to `validZTime_iff_validInt`'s docstring

**Verification**:

- `bash scripts/check-module-invariants.sh --no-build` reports both C15 assertions green (the second
  is a build-free python scan, so it runs in this mode).
- `lake build` still exits 0 — the `IntTransfer.lean` edit is confined to a doc comment, and this
  confirms it did not cross out of the comment boundary.
- No NEW red against `<scratchpad>/695-gate-baseline.txt`.

---

### Phase 4: Inventory and README bookkeeping, then the closing full gate [NOT STARTED]

**Goal**: Every generated and hand-maintained inventory surface knows about the new module, and the
full gate is green except for the inherited C28 red.

**Tasks**:

- [ ] `bash scripts/check-module-invariants.sh --emit-inventory`, then `git status --short` and
      `git diff` to see exactly which generated blocks moved.
- [ ] Replace the new row's `<!-- TODO: add description -->` placeholder in
      `FormalSystem/PlusLanguage/README.md`'s generated inventory block with a real one-line
      description (the generator preserves hand-written descriptions across regenerations, so this
      is written once and survives).
- [ ] Add a row for `PlusIntTransfer.lean` to `FormalSystem/PlusLanguage/README.md`'s separate,
      hand-maintained "What it carries" table in the `## Syntax before semantics` section.
- [ ] Stage **only** the inventory blocks whose content actually changed because of the new file
      (expected: `FormalSystem/PlusLanguage/README.md`, `FormalSystem/README.md`, `README.md` — each
      carries a generated `dir=`-scoped block the same run refreshes). Never `git add -A`,
      `git add .`, `git commit -am`, or a directory/glob pathspec.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` to confirm a further
      rewrite would change no byte.
- [ ] Run the **full** harness one final time and diff its output against
      `<scratchpad>/695-gate-baseline.txt`. The only red permitted is the inherited C28 finding on
      `FormalSystem/Version.lean`. Do **not** run `warning-budget.py --update`.
- [ ] Commit (scoped: the README/inventory paths only), then write the execution summary recording
      the zero-sorry/no-new-axiom result, the D5 decision, and the inherited C28 red as inherited.

**Timing**: 35 minutes

**Depends on**: 1, 2, 3

**Verification Tier**: full

**Scope Hypothesis**: three README files are expected to carry generated blocks that the
`--emit-inventory` run touches on account of the new module. This is a hypothesis, not a fact:
confirm with `git status --short` immediately after the run and stage only what actually moved. A
fourth touched file, or a touched file whose change is unrelated to the new module, is a signal to
stop and inspect (possibly a concurrent sibling's edit) rather than to stage.

**Files to modify**:

- `FormalSystem/PlusLanguage/README.md` - generated inventory row + description, and a row in the hand-maintained "What it carries" table
- `FormalSystem/README.md` - generated `dir=FormalSystem` inventory block refresh
- `README.md` - generated `dir=FormalSystem` inventory block refresh

**Verification**:

- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `bash scripts/check-module-invariants.sh` (full, with build): C2 sixteen rows, both C15 assertions
  green, C33 green, and no red other than the inherited C28 finding.
- `bash scripts/check-metalogic-cycles.sh` passes.
- `git log --oneline` shows one scoped commit per phase and no staged file outside this plan's
  enumerated paths.

## Testing & Validation

- [ ] `lake build` exits 0, with no new warning attributable to `PlusIntTransfer.lean`.
- [ ] Zero sorries in `FormalSystem/PlusLanguage/PlusIntTransfer.lean`.
- [ ] `#print axioms FormalSystem.PlusLanguage.plusValidZTime_iff_plusValidInt` and
      `#print axioms FormalSystem.PlusLanguage.plusTruthAt_map` each report exactly
      `[propext, Classical.choice, Quot.sound]` — no new axiom.
- [ ] Full `bash scripts/check-module-invariants.sh`: C2 passes at sixteen rows; C15's anchor half
      and its theorem-index half both pass; C33 passes; C16 raises no docBlame finding on the three
      new declarations; C34b does not fire on `plusTruthAt_map`; C9 reports no task-number citation.
- [ ] `bash scripts/check-metalogic-cycles.sh` passes (the `LANGUAGE_FILE_LAYERS` row).
- [ ] The only gate red at the end is the inherited C28 `FormalSystem/Version.lean` finding, present
      in `<scratchpad>/695-gate-baseline.txt` before any edit.

## Artifacts & Outputs

- `FormalSystem/PlusLanguage/PlusIntTransfer.lean` (new, ~180–220 lines)
- `FormalSystem/PlusLanguage.lean`, `FormalSystem.lean`,
  `scripts/measure-refactor-partitions.py` (registration)
- `scripts/check-module-invariants.sh` (C2 pin, sixteen rows)
- `docs/theorem-index.md` (two new `### Decidability` rows),
  `FormalSystem/Semantics/IntTransfer.lean` (one `Paper:` line)
- `FormalSystem/PlusLanguage/README.md`, `FormalSystem/README.md`, `README.md` (inventory)
- `specs/695_plus_carrier_normalization_int_transfer/summaries/01_*-summary.md`

**`file_scope` extension (D3)**: the task's declared `file_scope` names
`FormalSystem/Semantics/IntTransfer.lean`, `FormalSystem/Semantics/TruthTransport.lean`,
`FormalSystem/Semantics/Frames/TranslationProduct.lean`, `docs/theorem-index.md` and
`scripts/check-module-invariants.sh`. This plan **adds** the new module plus the registration and
inventory files above, and touches **neither** `TruthTransport.lean` **nor**
`TranslationProduct.lean` — the first is retired by D1, the second is read-only precedent.
`file_scope` is descriptive and not filesystem-validated (`.claude/rules/state-management.md`), so
this widening is routine and is recorded here deliberately rather than discovered at commit time.

## Rollback/Contingency

Each phase commits independently and scoped, so a bad phase is reverted by `git revert` of that one
commit — no working-tree discard is needed and none should be attempted. If an uncommitted
working-tree rollback does become necessary, take a snapshot first per
`.claude/context/contracts/recovery.md`'s rollback rung (including its `--allow-out-of-scope`
override for the deliberate whole-tree case) and only then run the destructive command; never emit a
bare default-mode `git-snapshot.sh` as a routine checkpoint.

Per-phase contingency:

- **Phase 1** fails to compile: the probe compiles against this same library, so a failure means a
  transcription error, not a mathematical gap. Diff the new file against
  `specs/695_plus_carrier_normalization_int_transfer/probes/01_plus_int_transfer_probe.lean` before
  attempting any proof repair.
- **Phase 2** C2 divergence: the failure message prints expected and actual blocks. Compare them
  line by line — a mismatch is an ordering or whitespace slip between the two heredocs, not a real
  axiom change, unless the actual block shows an axiom other than `propext`, `Classical.choice`,
  `Quot.sound`, in which case STOP and report rather than re-baselining.
- **Phase 3** C15 failure: the check names the declaration whose `Paper:` line is missing or
  malformed; the value must begin `— (`.
- **Phase 4**: if `--emit-inventory` touches files that have nothing to do with the new module,
  `git checkout` is *not* the remedy on a shared tree — leave them unstaged, report the observation,
  and commit only this task's hunks.
