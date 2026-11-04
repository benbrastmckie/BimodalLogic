# Implementation Plan: Task #833

- **Task**: 833 - Land the definability biconditional `⊡φ ↔ ▷◁φ` in OpenLanguage, with its ledger and README rows
- **Status**: [COMPLETED]
- **Effort**: 2.5 hours
- **Dependencies**: None declared. Shared-file serialization against 761 and 763 on `docs/theorem-index.md` (overlap gate; see Risks R4)
- **Research Inputs**: specs/833_stab_definable_from_open_modals/reports/01_stab-definable-from-open-modals.md
- **Artifacts**: plans/01_stab-definable-from-open-modals.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Transcribe six already-compiled declarations from probe 05 of task 559 into
`FormalSystem/OpenLanguage/`, landing `⊡φ ↔ ▷◁φ ↔ ◁▷φ` as library results instead of a probe:
four pointwise results in `OpenTruth.lean` and both implications as `OpenValid` in
`OpenValidity.lean`. Then land the three documentation surfaces the task owns — the component
README's per-file descriptions and paper-label correspondence row, the regenerated inventory
block, and six rows in `docs/theorem-index.md`. Definition of done: the unscoped guarded build is
green, each of the six declarations measures exactly its pinned axiom set (choice-free), and both
gate scripts hold at their re-measured baselines on a per-check reading.

This is a transcription task, not a proof search. The proof exists, compiles against the
repository's own oleans at exit 0 with no warnings, and must be landed unweakened.

### Research Integration

The research report settles every open question the dispatch left and corrects two of its claims:

- **The mirror route is structurally unavailable, not a style choice.** `OpenReversal.lean`
  imports `OpenValidity.lean`, which imports `OpenTruth.lean`, so routing `stab_iff_opast_ofut`
  through `openValid_reflectTime` would be an import cycle from both named modules. Independently,
  `openValid_reflectTime` is validity-level and `stab_iff_opast_ofut` is pointwise. The probe's
  direct proof is the only route, and no landed docstring may imply the reversal alternative
  exists here (report D2). This retires the dispatch's "implementer's call" framing.
- **A C15 obligation absent from the dispatch.** Every `docs/theorem-index.md` row's named
  declaration must carry a `Paper:` line in its own `/--` doc comment, or C15's second assertion
  fails with "doc comment carries no `Paper:` line". All six declarations need one (report R3).
  The sibling ordering theorems carry none because they have no ledger rows.
- **The ledger's axiom vocabulary has no `p` or `pq` token.** `pcq` abbreviates exactly
  `[propext, Classical.choice, Quot.sound]`; anything else is written out literally. The cells are
  therefore literal `[propext]` and `[propext, Quot.sound]`, with no `pinned:` token — C2/C14
  pinning is out of scope per the dispatch, and 87 existing unpinned rows are the precedent
  (report R4, D4).
- **Both gate baselines were re-measured and one dispatch note is stale.**
  `check-metalogic-cycles.sh` now exits **0** (the task-828 condition is resolved);
  `check-module-invariants.sh` exits **1** at a *different*, unmentioned pre-existing C16 finding
  in `LadderChain.lean` (761/836 territory). Verification is asserted per-check, never by exit
  code (report D6, Risks R1/R2).
- **House style in `OpenValidity.lean` is `OpenValid.of_forall_regular`**, verified
  axiom-identical to the probe's raw lambda, which also sidesteps the dispatch's `_hF`
  unused-binder question entirely (report R2, D3).
- **The optional `OpenClasses.lean` corollary is omitted** (report R7, D5). Its statement is
  verified provable and recorded in the research report, including the `paste_agreeFrom`-not-`.2`
  gotcha, so a later task with a real consumer does not re-derive it. No consumer exists today
  and a theorem with no consumer is not worth an INV row.
- **No new import and no new file anywhere.** `paste`, `paste_agreeUpTo` and `paste_agreeFrom`
  already resolve in both landing sites under the existing `open FormalSystem.PlusLanguage`. No
  `LANGUAGE_FILE_LAYERS` row is owed.
- **No name collisions**: all six identifiers have zero occurrences across `FormalSystem/`,
  `Tests/` and `docs/`.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the dispatch context; ROADMAP.md was not consulted and is not
modified by this plan.

## Goals & Non-Goals

- **Goals**:
  - Land in `FormalSystem/OpenLanguage/OpenTruth.lean`, unweakened, the four pointwise results
    `stab_to_ofut_opast`, `ofut_opast_to_stab`, `stab_iff_ofut_opast` and
    `stab_iff_opast_ofut`.
  - Land in `FormalSystem/OpenLanguage/OpenValidity.lean` both implications as validities:
    `openValid_stab_imp_ofut_opast` and `openValid_ofut_opast_imp_stab`.
  - Preserve the measured axiom budget exactly — choice-free throughout, no declaration picking
    up Classical choice on transcription.
  - Land the three documentation surfaces: the component README's per-file descriptions and its
    paper-label correspondence row, the regenerated inventory block, and six rows in the
    repository's single theorem ledger at docs/theorem-index.md.
- **Non-Goals**:
  - No proof system, no axiom, no derivation-tree constructor, in L^▷ or in L⁺. Everything landed
    here is a semantic theorem about `OpenTruthAt`.
  - No gap-closure claim of any kind. This supplies no limit-closure principle.
  - No claim that the open-future modal is undefinable in L⁺ — that question is open and belongs
    to another task.
  - No new file under `FormalSystem/OpenLanguage/`, and therefore no
    `LANGUAGE_FILE_LAYERS` row.
  - No class-level corollary in `OpenClasses.lean` (no consumer; see Research Integration).
  - No axiom-set pinning in `scripts/check-module-invariants.sh` — deliberately out of scope, and
    declaring that script would add a second contention point with the Stage 1 critical path.
  - No fix for the pre-existing C16 finding in `LadderChain.lean`, and no
    `lake exe runLinter --update`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A declaration picks up `Classical.choice` on transcription | H | L | Phase 4 measures each of the six against its pinned set and treats any choice dependence as a regression, not a new baseline. The likely cause would be routing the `←` half through something other than `paste`; Phase 1's task list forbids that explicitly |
| C15 fails late, after the Lean work looks finished, because the six declarations lack `Paper:` doc-comment lines | M | H without mitigation | Write the `Paper: — (reason)` line in the SAME edit as each declaration (Phases 1-2), never as a documentation afterthought, and grep C15 as soon as the ledger rows land (Phase 3) |
| The dispatch's stale `check-metalogic-cycles.sh` note waves through a genuine new import edge | H | L | Phase 4 inverts the dispatch's guidance per the re-measured baseline: exit 0 is required, and any nonzero exit is a NEW failure. This task adds no import at all, so a graph regression would be surprising |
| `check-module-invariants.sh` exits 1 at a pre-existing C16 finding and is read as this task's failure (or its failure masks a real one) | M | H | Assert per-check, not by exit code: INV, C2 and both C15 assertions must stay PASS, and the C16 finding list must stay byte-identical (one finding, `mem_cellAt_of_shift_of_hasForwardSlack`). Do not run `lake exe runLinter --update` |
| Hand-editing a Lines cell inside the README's generated inventory block | M | M | Phase 3 edits Description cells only — which the generator carries through verbatim — then regenerates counts via `--emit-inventory` and re-checks for byte-stability. Hand-editing a Lines cell is exactly the drift INV exists to catch |
| `docs/theorem-index.md` contention with 761 (`[IMPLEMENTING]`) and 763 | M | M | Run this task in a cycle of its own, or after 761/763's current cycle, never concurrently. The overlap gate's serialization is correct and must not be worked around. The edit here is six appended rows in the `### L^▷` section, far from 761/763's `RaySummary` rows |
| Scope creep into gap-closure or undefinability language in a docstring | M | M | Every docstring states the product structure of `⟨τ⟩_x` and nothing more. No sentence may suggest `plus_incomplete_base` is affected, that `blc` becomes a theorem, that an `LC_n`-style schema is no longer required, or that the open-future modal is L⁺-undefinable |
| Unguarded `lake` collision losing a build | L | L | Route every build through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- …`; never bare `lake`. Treat an unexplained failure during concurrent work as possible guard bypass before assuming a regression here |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 1, 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phase 2's
bodies delegate to Phase 1's pointwise theorems, and Phase 3's inventory regeneration needs both
files' final line counts.

### Phase 1: The four pointwise results in `OpenTruth.lean` [COMPLETED]

**Goal**: Land `stab_to_ofut_opast`, `ofut_opast_to_stab`, `stab_iff_ofut_opast` and
`stab_iff_opast_ofut` in `OpenTruth.lean`, transcribed unweakened from probe 05, each carrying a
C15-satisfying `Paper:` doc-comment line.

**Tasks**:
- [ ] Open a new section immediately after the existing `/-! ## The strength ordering … -/` block
      and before the file's closing `end FormalSystem.OpenLanguage`, headed
      `/-! ## `⊡` is definable: `⊡φ ↔ ▷◁φ ↔ ◁▷φ` -/`. Do not disturb the three existing ordering
      theorems.
- [ ] Transcribe `stab_to_ofut_opast` verbatim from the probe — no `[F.IsRegular]` instance, no
      added hypothesis. The body is the two class inclusions at the point:
      `intro σ hup ρ hfrom; exact h ρ ((hup t le_rfl).trans (hfrom t le_rfl))`.
- [ ] Transcribe `ofut_opast_to_stab` verbatim — `[F.IsRegular]`, one `paste`, with
      `paste_agreeUpTo` and `paste_agreeFrom`. **Do not route this through anything other than
      `paste`**: that is what keeps it choice-free, and a different route is the predicted cause
      of a `Classical.choice` regression.
- [ ] Transcribe `stab_iff_ofut_opast` as the anonymous-constructor pairing of the two above.
- [ ] Transcribe `stab_iff_opast_ofut` with the probe's direct `constructor` proof (the same
      paste with the two histories exchanged, via `hs.symm`). Do **not** route it through
      `openValid_reflectTime`: that is an import cycle from this module, and it is
      validity-level where this statement is pointwise.
- [ ] Give each of the four a `/-- … -/` doc comment ending in a `Paper:` line whose value starts
      with `— (`, modelled on `hnOpen_openValid` in `OpenOckhamist.lean`. The reason clause is
      formalization-native: the manuscript sets the restricted modals aside and states no such
      equation.
- [ ] In `stab_iff_opast_ofut`'s doc comment, state that the proof is direct and **omit the
      probe's parenthetical** offering the `openValid_reflectTime` route — that route does not
      exist from this module, and a docstring claiming it was available and declined is a defect.
- [ ] Add a bullet to the module docstring's `## Main Results` list naming the definability
      equation and the four identifiers, in the style of the existing strength-ordering bullet.
- [ ] Run the scoped guarded build and confirm green with no new warnings.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Four new declarations plus one section heading plus one `## Main Results`
bullet, all additive, in one file; the file is 288 lines at plan time (carried from the research
report's measurement of `FormalSystem/OpenLanguage/OpenTruth.lean`, re-derived by the README's
generated inventory row). Confirm at implementation time by `git diff --stat` on that one path
showing insertions only and no deletions outside the `## Main Results` bullet list, and by
`lean_verify` resolving exactly four new fully-qualified names.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.OpenLanguage.OpenTruth` covers this edit, because the phase adds declarations to one
module and changes no existing declaration's name, type, arity or argument order, so no call site
outside this file can be affected.

**Files to modify**:
- `FormalSystem/OpenLanguage/OpenTruth.lean` - append the definability section (four
  declarations with `Paper:` doc comments) and extend the module docstring's `## Main Results`
  list

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.OpenLanguage.OpenTruth` exits 0 with no new warnings.
- `lean_verify` resolves `FormalSystem.OpenLanguage.stab_to_ofut_opast` at `[propext]` and the
  other three at `[propext, Quot.sound]`. Any `Classical.choice` stops the phase as `[BLOCKED]`.
- `grep -c 'sorry' FormalSystem/OpenLanguage/OpenTruth.lean` is 0.
- Each of the four doc comments contains a line matching `^\s*Paper: — \(`.

---

### Phase 2: Both implications as `OpenValid` in `OpenValidity.lean` [COMPLETED]

**Goal**: Land `openValid_stab_imp_ofut_opast` and `openValid_ofut_opast_imp_stab` beside the
existing `openValid_stab_of_box` / `openValid_ofut_of_stab` / `openValid_opast_of_stab` block, in
that block's house style.

**Tasks**:
- [ ] Open a new section after the existing `/-! ## The strength ordering … -/` block and before
      the file's closing `end FormalSystem.OpenLanguage`, headed to match Phase 1's.
- [ ] State `openValid_stab_imp_ofut_opast` as
      `OpenValid (imp (stab φ) (ofut (opast φ)))` with body
      `OpenValid.of_forall_regular fun _ _ M τ t h => stab_to_ofut_opast M τ t φ h`, matching all
      three siblings in the block.
- [ ] State `openValid_ofut_opast_imp_stab` as
      `OpenValid (imp (ofut (opast φ)) (stab φ))` with body
      `OpenValid.of_forall_regular fun _ _ M τ t h => ofut_opast_to_stab M τ t φ h`. The adapter
      is where `FrameClass.Base.Sat F` is consumed and `[F.IsRegular]` registered, so no `_hF`
      binder is introduced and the file stays warning-free.
- [ ] Give both a `/-- … -/` doc comment ending in a `Paper: — (…)` line, as in Phase 1. State
      that the `←` half holds over every regular task frame and nothing further.
- [ ] Add a bullet to the module docstring's `## Main Results` list naming the two identifiers and
      the definability equation.
- [ ] Run the scoped guarded build and confirm green with no new warnings.

**Timing**: 0.25 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Two new declarations plus one section heading plus one `## Main Results`
bullet, all additive, in one file; the file is 229 lines at plan time (carried from the research
report's measurement of `FormalSystem/OpenLanguage/OpenValidity.lean`, re-derived by the README's
generated inventory row). Confirm at implementation time by `git diff --stat` on that one path
showing insertions only and by `lean_verify` resolving exactly two new fully-qualified names.

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.OpenLanguage.OpenValidity` covers this edit, because the phase adds declarations to
one module whose only new dependency is Phase 1's already-built `OpenTruth` and changes no
existing signature.

**Files to modify**:
- `FormalSystem/OpenLanguage/OpenValidity.lean` - append the two `OpenValid` declarations with
  `Paper:` doc comments and extend the module docstring's `## Main Results` list

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.OpenLanguage.OpenValidity` exits 0 with no new warnings (in particular, no
  unused-binder warning).
- `lean_verify` resolves `FormalSystem.OpenLanguage.openValid_stab_imp_ofut_opast` at
  `[propext]` and `FormalSystem.OpenLanguage.openValid_ofut_opast_imp_stab` at
  `[propext, Quot.sound]`.
- `grep -c 'sorry' FormalSystem/OpenLanguage/OpenValidity.lean` is 0.
- Both doc comments contain a line matching `^\s*Paper: — \(`.

---

### Phase 3: The three documentation surfaces [COMPLETED]

**Goal**: Land the component README's descriptions and correspondence row, the regenerated
inventory block, and six ledger rows in `docs/theorem-index.md`, with INV and both C15 assertions
holding.

**Tasks**:
- [ ] In `FormalSystem/OpenLanguage/README.md`'s generated inventory block, hand-edit the
      **Description cells only** of the `OpenTruth.lean` and `OpenValidity.lean` rows to name the
      new identifiers, appended to each cell's existing ordering clause. **Do not touch any Lines
      cell** — the generator owns those, and hand-editing one is exactly the drift INV catches.
- [ ] Add one row to the README's `## Paper-label correspondence` table, immediately after the
      existing `app:gluing` (two histories) row it extends. Paper anchor cell:
      `` `app:gluing` (two histories), operator form ``. Claim cell: the operator-level
      consequence, `⊡φ ↔ ▷◁φ ↔ ◁▷φ` on every regular task frame — `⟨τ⟩_x` is the product of the
      open pasts and the open futures, read at the level of the modals. Lean cell: all six
      identifiers with their files, closing with **formalization-native**, labelled exactly as
      the sibling formalization-native rows are (the manuscript sets the restricted modals aside
      and states no such equation). Introduce no new paper anchor, so C15's first assertion is
      unaffected.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` to let the generator rewrite
      the per-file line counts, then `bash scripts/check-module-invariants.sh --emit-inventory
      --check` and confirm byte-stability.
- [ ] Append six rows to the `### L^▷ — the open-future and open-past language` section of
      `docs/theorem-index.md`, one per declaration, in the declaration order of Phases 1-2.
- [ ] Each ledger row: Paper label `—`; a one-line Statement; a **fully qualified** Lean name
      (`FormalSystem.OpenLanguage.…` — a bare identifier is not a row key); File path with no
      line number; Frame class `Base`; Axioms written **literally** with no `pinned:` token —
      `[propext]` for `stab_to_ofut_opast` and `openValid_stab_imp_ofut_opast`, and
      `[propext, Quot.sound]` for the other four. Never `pcq`, never `p`, never `pq`.
- [ ] In `stab_to_ofut_opast`'s Statement cell, record that the `→` half needs no frame axiom.
      This is where that fact belongs: the Frame class column reads `Base` for all six rows per
      the dispatch's explicit instruction, which is true of all six and keeps the block uniform,
      so the Statement cell carries the sharper fact for the one row that is class-generic.
- [ ] Run `bash scripts/check-module-invariants.sh 2>&1 | grep -E 'INV|C15'` immediately and
      confirm INV and both C15 assertions PASS. A C15 failure naming a declaration that "carries
      no `Paper:` line" means a Phase 1/2 doc comment is missing its line — fix it there.

**Timing**: 0.75 hours

**Depends on**: 1, 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: Six appended ledger rows, two edited README Description cells, one appended
README correspondence row, and generator-rewritten line counts for two inventory rows — carried
from the research report's measurements (the `### L^▷` section at `docs/theorem-index.md`; the 93
paper anchors and 313 existing theorem-index rows C15 asserts over). Confirm at implementation
time by `git diff --stat` showing exactly the two declared paths, by the diff of the inventory
block touching only Lines and Description cells, and by C15's two PASS lines reporting counts
raised by the expected amounts.

**Tier Justification**: `bash scripts/check-module-invariants.sh` covers this edit through its INV
assertion (every generated inventory block is current) and both C15 assertions (every paper-anchor
citation resolves; every theorem-index row carries its anchor at the declaration), which together
check all three surfaces this phase touches; both paths are markdown with no compile or
elaboration surface, so the tier table's diff read-through is the rest.

**Files to modify**:
- `FormalSystem/OpenLanguage/README.md` - Description cells of two inventory rows (Lines cells
  regenerated by the generator, never by hand); one new paper-label correspondence row extending
  the `app:gluing` (two histories) row
- `docs/theorem-index.md` - six new rows in the `### L^▷` section

**Verification**:
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports the block
  byte-stable.
- `bash scripts/check-module-invariants.sh 2>&1 | grep -E 'INV|C15'` shows INV PASS and both C15
  assertions PASS, with the row count raised by six.
- Diff read-through confirming every changed hunk lies in prose/table content, that no inventory
  Lines cell was hand-edited, and that no cell claims gap closure, limit closure, or
  L⁺-undefinability of the open-future modal.
- Every new ledger row's Lean name is fully qualified, and no new row's Axioms cell contains
  `pcq`, `Classical`, `p ` alone, `pq`, or a `pinned:` token.

---

### Phase 4: Full verification and axiom audit [COMPLETED]

**Goal**: Establish on the whole repository that the six declarations are landed, choice-free at
their pinned sets, sorry-free, and that both gate scripts hold at their re-measured baselines.

**Tasks**:
- [ ] Run the unscoped guarded build: `bash .claude/scripts/lake-build-guard.sh build --timeout
      1800 -- build`. Never bare `lake`. Read the verdict from the guard's own exit status or its
      `result` subcommand, never from a pipe's exit code.
- [ ] Measure axioms on each of the six fully-qualified names with `lean_verify` (or
      `#print axioms`), and compare against the pinned sets: `[propext]` for
      `FormalSystem.OpenLanguage.stab_to_ofut_opast` and
      `FormalSystem.OpenLanguage.openValid_stab_imp_ofut_opast`; `[propext, Quot.sound]` for
      `ofut_opast_to_stab`, `stab_iff_ofut_opast`, `stab_iff_opast_ofut` and
      `openValid_ofut_opast_imp_stab`.
- [ ] A declaration measuring `Classical.choice` is a **regression, not a new baseline**: stop,
      mark the phase `[BLOCKED]`, and report. Do not record the wider set in the ledger and do not
      proceed.
- [ ] Run `bash scripts/check-module-invariants.sh` and assert **per-check**, not by exit code:
      INV PASS, C2 PASS, C15 (paper-anchor citations) PASS, C15 (theorem-index rows carry their
      anchor at the declaration) PASS, and the C16 finding list byte-identical to baseline — one
      finding, `mem_cellAt_of_shift_of_hasForwardSlack` in
      `FormalSystem/Metalogic/Decidability/RaySummary/LadderChain.lean`. The script's exit 1 is
      that pre-existing finding (761/836 territory) and is not this task's to fix. Do **not** run
      `lake exe runLinter --update`.
- [ ] Run `bash scripts/check-metalogic-cycles.sh` and require **exit 0** with
      `PASS upward import set is exactly the recorded 8 line(s)`. This inverts the dispatch's
      stale note: the task-828 condition is resolved, so any nonzero exit here is a NEW failure,
      and this task adds no import at all. Investigate rather than wave through; do not fix 828
      from this task.
- [ ] Confirm zero `sorry` and zero vacuous definitions across the touched tree:
      `grep -rn 'sorry' FormalSystem/OpenLanguage/` returns nothing, and no landed declaration
      has a body of the `:= True` / `:= trivial` / `:= Unit` shape.
- [ ] Re-read all six landed doc comments and the two README cells once more against the
      not-in-scope list: no sentence may suggest `plus_incomplete_base` is affected, that `blc`
      becomes a theorem, that an `LC_n`-style schema is no longer required, or that the
      open-future modal is L⁺-undefinable.
- [ ] Run `bash .claude/scripts/validate-artifact.sh
      specs/833_stab_definable_from_open_modals/plans/01_stab-definable-from-open-modals.md plan`
      and confirm no errors.

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: Six declarations across two `.lean` files and three documentation surfaces
across two markdown files, with baseline gate readings carried from the research report
(`check-metalogic-cycles.sh` exit 0; `check-module-invariants.sh` exit 1 at exactly one C16
finding; the scoped `FormalSystem.OpenLanguage` build green at 1210 jobs). Confirm at
implementation time by re-running each named command in this phase and comparing against those
figures rather than trusting them.

**Files to modify**:
- none planned - this phase runs verification commands only and edits no file; any repair it
  triggers is made in the phase that owns the file (Phase 1, 2 or 3)

**Verification**:
This phase's complete gate set for this task's surfaces, all of which must be observed green in
this dispatch and none of which may be trusted on sight:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` — unscoped, exit 0.
- `lean_verify` on all six fully-qualified names, each matching its pinned axiom set above, with
  no `Classical.choice` anywhere.
- `bash scripts/check-module-invariants.sh` — INV, C2 and both C15 assertions PASS; C16 finding
  list byte-identical to the one-finding baseline.
- `bash scripts/check-metalogic-cycles.sh` — exit 0.
- Zero `sorry`, zero vacuous definitions.
- `bash .claude/scripts/validate-artifact.sh` on this plan — no errors.

`bash .claude/scripts/verify-deploy.sh` aggregates the agent-system deploy gates, every one of
which is scoped to `.claude/**` or the resolved source store. No path in any phase's
`Files to modify` block lies in either tree, so that aggregator has zero touched surface in this
task and its selected-subset forms would all reach the zero-check-under-filter condition. The
commands above are therefore the complete applicable gate set, stated in full rather than
narrowed; nothing is deferred past this phase.

---

## Lean Challenge Statements

```lean
import FormalSystem.OpenLanguage

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage.OpenFormula
open FormalSystem.Semantics

variable {F : TaskFrame}

theorem stab_to_ofut_opast (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula) (h : OpenTruthAt M τ t (.stab φ)) :
    OpenTruthAt M τ t (.ofut (.opast φ)) := sorry

theorem ofut_opast_to_stab [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : OpenFormula) (h : OpenTruthAt M τ t (.ofut (.opast φ))) :
    OpenTruthAt M τ t (.stab φ) := sorry

theorem stab_iff_ofut_opast [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : OpenFormula) :
    OpenTruthAt M τ t (.stab φ) ↔ OpenTruthAt M τ t (.ofut (.opast φ)) := sorry

theorem stab_iff_opast_ofut [F.IsRegular] (M : TaskModel F) (τ : WorldHistory F)
    (t : F.Duration) (φ : OpenFormula) :
    OpenTruthAt M τ t (.stab φ) ↔ OpenTruthAt M τ t (.opast (.ofut φ)) := sorry

theorem openValid_stab_imp_ofut_opast (φ : OpenFormula) :
    OpenValid (imp (stab φ) (ofut (opast φ))) := sorry

theorem openValid_ofut_opast_imp_stab (φ : OpenFormula) :
    OpenValid (imp (ofut (opast φ)) (stab φ)) := sorry

end FormalSystem.OpenLanguage
```

These six signatures are the contract. They are the probe's statements verbatim, except that the
two `OpenValid` statements are respelled in `OpenValidity.lean`'s house style
(`imp (stab φ) (ofut (opast φ))` under `open ... OpenFormula`) rather than the probe's
dot-notation `(OpenFormula.stab φ).imp (.ofut (.opast φ))`. The two spellings are the same term
and were compiled side by side at identical axiom sets; this is a spelling choice, not a
statement change. Adding a hypothesis, specialising a binder, or dropping an `[F.IsRegular]`
instance to any of these is a plan-compliance violation (see `.claude/rules/plan-compliance.md`,
Statement Fidelity) and must be escalated as `[BLOCKED]`, never silently substituted.

## Testing & Validation

- [ ] Unscoped guarded build green; no new warnings in either edited `.lean` file.
- [ ] All six declarations resolve under their fully-qualified names and measure exactly their
      pinned axiom sets — choice-free throughout.
- [ ] Zero `sorry`; zero vacuous definitions.
- [ ] `check-module-invariants.sh`: INV, C2 and both C15 assertions PASS; C16 unchanged from its
      one-finding baseline.
- [ ] `check-metalogic-cycles.sh`: exit 0.
- [ ] `--emit-inventory --check` reports the README's generated block byte-stable.
- [ ] No statement anywhere in the landed text claims gap closure, limit closure, or
      L⁺-undefinability of the open-future modal; no proof-system or axiom constructor added.

## Artifacts & Outputs

- `FormalSystem/OpenLanguage/OpenTruth.lean` — four pointwise declarations with `Paper:` doc
  comments; extended `## Main Results`.
- `FormalSystem/OpenLanguage/OpenValidity.lean` — two `OpenValid` declarations with `Paper:` doc
  comments; extended `## Main Results`.
- `FormalSystem/OpenLanguage/README.md` — two edited inventory Description cells, regenerated
  Lines cells, one new paper-label correspondence row.
- `docs/theorem-index.md` — six new rows in the `### L^▷` section.
- `specs/833_stab_definable_from_open_modals/summaries/01_stab-definable-from-open-modals-summary.md`
  — implementation summary at completion.

## Rollback/Contingency

Every phase is purely additive: four declarations, two declarations, six ledger rows, one
correspondence row, two Description cells. Reverting any phase is deleting its own appended block,
and nothing existing is rewritten except the generator-owned Lines cells (restored by re-running
`bash scripts/check-module-invariants.sh --emit-inventory`).

- **A phase fails its scoped build**: fix forward in the same file. Never discard uncommitted
  changes to reach a passing build.
- **An axiom regression (Phase 1, 2 or 4)**: mark the phase `[BLOCKED]` and report. The predicted
  cause is routing the `←` half through something other than `paste`; re-check that body against
  the probe before anything else. Do not re-baseline the wider axiom set and do not weaken a
  statement to make it compile.
- **A statement cannot be landed as written in `## Lean Challenge Statements`**: mark the phase
  `[BLOCKED]` and raise it, per `.claude/rules/plan-compliance.md`. Do not substitute a weaker
  same-named statement, and do not edit the recorded Challenge to match what compiled.
- **A genuine working-tree rollback becomes necessary**: take the snapshot first, per
  `.claude/context/contracts/recovery.md`'s rollback rung, and only then run the destructive
  command. Do not emit a bare precautionary snapshot as a routine start-of-phase step; an
  ordinary defensive checkpoint uses `bash .claude/scripts/git-snapshot.sh 833 --no-revert`.
- **The overlap gate defers this task against 761/763**: that is correct behaviour on
  `docs/theorem-index.md` and must not be worked around. Wait for a clear cycle.
