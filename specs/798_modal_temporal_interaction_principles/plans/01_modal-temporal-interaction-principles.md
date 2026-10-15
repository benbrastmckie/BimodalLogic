# Implementation Plan: Task #798

- **Task**: 798 - Port the eleven unported modal-temporal interaction principles Pthm:11 -- Pthm:22 from the paper's companion cut file, together with the duality lemma P8 that two of their proofs consume
- **Status**: [COMPLETED]
- **Effort**: 3.5 hours
- **Dependencies**: None
- **Research Inputs**: `specs/798_modal_temporal_interaction_principles/reports/01_modal-temporal-interaction-principles.md`
- **Artifacts**: plans/01_modal-temporal-interaction-principles.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The eleven interaction principles the paper cut for internal redundancy are true, proved, and
absent from this tree; so is the duality P8 that two of their derivations consume. This plan
lands all of them, plus two reusable helpers the encoding forces, as proof-term `def`s in one
new module `FormalSystem/Theorems/Interaction.lean`, wires that module into both aggregators the
repository's invariant checks require, and records Pthm:17's existing home with a docstring
cross-reference rather than a restatement. Done means `lake build FormalSystem` green, zero new
`sorry` and zero new `axiom`, `scripts/check-module-invariants.sh` exit 0 with every generated
inventory current, and each new declaration carrying a docstring that names its cut-file label
and its derivation route.

### Research Integration

The report's four load-bearing findings are the plan's premises, and the central one was
**re-derived at plan time rather than carried**: a single `lean_run_code` probe of all sixteen
declarations, under the final names this plan commits to, returned `success: true` with **zero
diagnostics** (the report's probe carried one `longLine` warning; the wrapping below removes it).
The `## Lean Challenge Statements` block is therefore plan-time-verified, not
`CARRIED-UNVERIFIED`.

Carried into the phases below:

- **Siting** (report Decision 1): the new module, importing Perpetuity, ModalS5 and
  TemporalDerived. The only placement giving simultaneous access to the `iff` connective,
  `presentToSometimes` and the full P1--P6 stock, and the only one that keeps P8 computable.
- **P8's route and siting** (report Decision 2, and the user's answered decision in
  `.decisions.json`): definitional DNE/DNI in the new module, with a docstring citing the P7
  pair as the contrast and `fNegG`/`pNegH` as the precedent. The task description's "beside
  `temporalDualityNeg` … following their proof shape" is a departure the user has approved.
- **Pthm:18 by the cut file's own direct derivation** (report Decision 3), not the task
  description's 15+14 composition, which is the block's header redundancy note rather than its
  proof. The 15+14 observation is recorded in the docstring.
- **Pthm:16 by the cut file's own route** (P8, Pthm:15 at the negation, P7 at the boxed
  negation), not the cheaper `iffIntro` of Pthm:22 and Pthm:21, because the paper's route is the
  only consumer of Pthm:15 and of the existing P7 pair in the whole block. The verified
  alternative is noted in the docstring, not written.
- **No rewrite-lemma claim** (report's negative finding): the five collapsing biconditionals are
  derivability facts, not `Formula` identities, so they are not registrable in
  `Automation/Normalization.lean`'s `simp` sets and no decidability or normal-form module can
  consume them. The docstrings claim the *precedent* relation to the S5/S4 collapse
  biconditionals instead, and claim no consumer.

**Plan-time re-derivations and divergences from the report, all load-bearing:**

- **C33 is a gate the report did not reach, and it changes the phase order.** The root
  aggregator `FormalSystem.lean` must be byte-for-byte what `lake exe mk_all --lib FormalSystem`
  generates — one sorted import line per file under `FormalSystem/`. A new module therefore needs
  a line there as well as in `FormalSystem/Theorems.lean`. This plan consequently **rejects the
  report's "isolate the import edit in its own terminal phase" mitigation**: deferring the
  wiring would leave every intermediate commit C33-red. Both aggregator lines land in Phase 1,
  with the territory discipline (re-read immediately before editing, stage an explicit file list)
  carrying the contention mitigation instead.
- **The new module's sorted position was resolved at plan time**: `import
  FormalSystem.Theorems.Interaction` sits between `…GeneralizedNecessitation` and
  `…LinearityDerived` in `FormalSystem.lean`.
- **`boxToPast` does not collide with the needed TR mirror.** `Perpetuity/Helpers.lean` carries
  `boxToPast : ⊢ □φ → Hφ`; the helper this port needs is `□φ → H□φ`, a different statement. The
  new helper is named `temporalPastDerived`, mirroring `temporalFutureDerived`, and its proof
  mirrors `boxToPast`'s time-reflection `simp only` step exactly.
- **Two further gates checked at plan time, both clear.** C35 (citation-manifest byte-currency
  by recorded declaration span) cannot fire: neither `scripts/lean-citation-seeds.txt` nor
  `scripts/lean-citation-manifest.json` contains a single `Perpetuity` occurrence, so Phase 3's
  docstring edit shifts no recorded span. C20's third assertion is likewise clear: a repo-wide
  sweep outside `specs/**` finds **zero** `Principles.lean:NNN` citations.
- **C15 needs no new record row.** Its anchor regex is word-boundary-anchored, so `Pthm:11`
  does not match `thm:11` and the cut-file labels can be written verbatim in docstrings. The two
  paper anchors worth citing are `cor:tm-decidability` (a recorded manifest row) and `sub:Logic`
  (one of the six ungated `sub:` anchors).
- **All sixteen declarations will be left untagged**, including the two helpers — a deliberate
  departure from the tagged-helper precedent in `Perpetuity/Helpers.lean`. See Decisions.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context; no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- `notSometimesToAlwaysNeg` and `alwaysNegToNotSometimes` -- P8 in both directions, the genuinely
  absent duality two of the block's derivations consume
- `temporalPastDerived` and `boxToAlwaysBox` -- the two helpers the tree's encoding forces, each
  factored out because more than one principle consumes it
- `sometimesDiamondToDiamond`, `alwaysDiamondToDiamond`, `sometimesBoxIffBox`,
  `alwaysBoxIffBox`, `boxAlwaysIffAlwaysBox`, `diamondSometimesIffSometimesDiamond`,
  `boxAlwaysIffBox`, `diamondAlwaysToDiamond`, `diamondToDiamondSometimes`,
  `diamondIffDiamondSometimes`, `sometimesDiamondToDiamondSometimes`,
  `diamondSometimesToSometimesDiamond` -- the eleven unported principles, with Pthm:20's forward
  half exposed as its own declaration because Pthm:21 consumes it
- A docstring cross-reference on the existing P4 declaration recording that it is Pthm:17 of the
  cut block and the reverse half of Pthm:20 -- a cross-reference, not a restatement
- The block's internal dependency chain honoured rather than re-proved from the axioms, by the
  cut file's own routing
- Both aggregators wired, every generated inventory current, and the whole repository gate set
  green

**Non-Goals**:
- Any restatement of Pthm:17. `FormalSystem.Theorems.Perpetuity.perpetuity4` already proves it
  independently; the task's "Pthm:17 from Pthm:11 and Pthm:16" clause is therefore moot and no
  declaration is added for it.
- Any claim that the five biconditionals are rewrite lemmas, any `@[formula_unfold]` /
  `@[formula_fold]` registration, and any edit to `FormalSystem/Automation/**`,
  `FormalSystem/Metalogic/Decidability/**` or either normal-form module. Checked and negative:
  a derivability biconditional is not a `Formula` identity and no mechanism in this tree can
  consume one.
- Any `@[tmLemma]` attribute, on the principles or the helpers. See Decisions.
- Any edit to `FormalSystem/Theorems/Perpetuity/MonotonicityDuality.lean`. P8 is sited in the new
  module, per the user's answered decision; nothing beside the P7 pair changes.
- Any edit to `docs/reference/API_REFERENCE.md`, `docs/theorem-index.md`,
  `scripts/lean-citation-manifest.json` or `docs/reference/paper-definitions-of-record.md`. No
  gate requires a row in any of them for this addition, three of the four are in a concurrent
  sibling's declared file scope this cycle, and C15's second assertion constrains the
  theorem-index rows that already exist rather than requiring a new one. An API reference section
  for the new module is a reasonable later addition, recorded here as out of scope.
- Any proof-side change to an existing declaration. Phase 3 touches one docstring and no term.
- Any new axiom, any `sorry`, any `set_option` suppression, and any entry in
  `scripts/warning-budget.txt` -- a long line is fixed, never budgeted.
- Any `Tests/BimodalTest/` axiom pin for the new declarations, and any paper-side edit (the cut
  block's restoration in the paper repository is not this task's work).

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Aggregator contention: `FormalSystem.lean` and `FormalSystem/Theorems.lean` are shared touches across any task adding a module | H | L | Neither file is in sibling 801's declared file scope, and siblings 796/799/801 are all in their *plan* phase this cycle, which writes no `.lean`. Phase 1 re-reads each file immediately before editing, checks `git status --short`, stages an explicit two-file list, and STOPS and reports on any foreign uncommitted modification or foreign commit rather than proceeding |
| C33 red at an intermediate commit if the root aggregator line is deferred | H | H if deferred | Both aggregator lines land in Phase 1, before any commit; the sorted insertion position is pre-resolved and C33 is asserted in Phase 1's own verification |
| The generated module inventory in `FormalSystem/Theorems/README.md` (and the ancestor blocks in `FormalSystem/README.md` and `README.md`) goes stale the moment the new file exists, so `check-module-invariants.sh`'s INV group is red from Phase 1 until Phase 4 | M | H | Expected and declared, not discovered: each of Phases 1--3 asserts its *named* checks PASS and that the only FAIL group is INV, rather than asserting whole-script exit 0, which is unsatisfiable before Phase 4. Phase 4 regenerates with `--emit-inventory` and confirms with `--emit-inventory --check`. Never hand-edit a count column; never call the deprecated `scripts/readme-inventory.sh` shim |
| `typst/generated/status.typ` keys on whole-tree line counts, which every `.lean` addition moves, and the file is in sibling 801's declared file scope | M | H | Phase 4 owns it, via `bash scripts/typst-sync-check.sh --fix` (or `bash scripts/typst-status-counts.sh`), after re-reading and checking `git status --short`. If a commit-time staleness gate blocks earlier than Phase 4, regenerate and stage it with that same commit and say so in the summary rather than hand-patching a count |
| Unreachable-module trap: a module not transitively imported by `FormalSystem.lean` becomes a C6 known-unreachable live module and opts out of C24's `FormalSystem.Init` inheritance | M | L | The `FormalSystem.lean` line is mandatory, not cosmetic; Phase 1 asserts `lake exe checkInitImports` exits 0 and that C6's unreachable census does not name `Interaction.lean` |
| `alwaysToPresent` is ambiguous between the `Perpetuity` and `TemporalDerived` namespaces, and a full `open` of both breaks elaboration | M | M | Reproduce the probe's exact open list: `open FormalSystem.Theorems.Perpetuity` in full, and `open FormalSystem.Theorems.TemporalDerived (presentToSometimes)` selectively. This is the configuration both the research probe and the plan-time probe compiled under |
| A line over 100 characters trips the `longLine` linter, and a new file has no `warning-budget.txt` baseline | L | M | The plan-time probe is already wrapped to zero diagnostics; copy its wrapping. Fix any long line, never add a budget entry |
| A docstring line fires C34b by naming a capitalized constraint token beside a negation or consumption word | L | L | Write none of `Compositionality`, `Compositional`, `Seriality`, `Serial`, `Limit`, `Saturation`, `Saturated` on any new docstring line, and no `Constraints consumed:` marker |
| C17 counts the principles no other declaration consumes (Pthm:12, 14, 19, 21, 22 under the paper's Pthm:16 routing) as dead declarations | L | H | C17 is reporting-only and cannot fail a gate. Naming every new declaration in the module docstring's `## Main Theorems` inventory and in the README description cell keeps the count flat anyway, since both are inside C17's markdown scope |
| Everything in the new module is `noncomputable`, because the Perpetuity premises are | none | certain | Expected, not a defect: both probes compiled with all sixteen marked `noncomputable def`. Record it in the module docstring |
| A build failure lands in a file outside this task's scope | M | L | Treat it as possibly a sibling's in-flight edit: check `git status --short` and `git log` to confirm the work is not this task's own, then report rather than repair |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: New module, P8, the two helpers, and both aggregator lines [COMPLETED]

**Goal**: `FormalSystem/Theorems/Interaction.lean` exists, carries P8 in both directions and the
two helpers the eleven principles consume, and is reachable from the root aggregator so C33, C24
and C6 are all satisfied before anything else is written.

**Tasks**:
- [x] Create `FormalSystem/Theorems/Interaction.lean` with the repository's standard copyright
      header, the three imports (`FormalSystem.Theorems.Perpetuity`,
      `FormalSystem.Theorems.ModalS5`, `FormalSystem.Theorems.TemporalDerived`), namespace
      `FormalSystem.Theorems.Interaction`, and the probe's exact open list -- `Perpetuity` opened
      in full, `ModalS5 (iff)`, `Propositional (doubleNegation iffIntro)` and
      `TemporalDerived (presentToSometimes)` opened selectively
- [x] Write the module docstring: what the module holds (the cut block's interaction principles),
      that every declaration is `noncomputable` because the Perpetuity premises are, a
      `## Main Theorems` inventory naming all sixteen declarations with their cut-file labels, and
      a `## References` block in the normal form of `docs/development/REFERENCE_NORMAL_FORM.md`
      citing `[thomason1984]` §4, `[burgess1982]` §1.3, the paper anchors
      `cor:tm-decidability` and `sub:Logic`, and the module cross-references this port rests on
      (`FormalSystem/Syntax/Formula.lean`, `FormalSystem/Theorems/Perpetuity/Principles.lean`,
      `FormalSystem/Theorems/Perpetuity/MonotonicityDuality.lean`,
      `FormalSystem/Theorems/TemporalDerived.lean`, `FormalSystem/Theorems/ModalS5.lean`)
- [x] Add `notSometimesToAlwaysNeg` and `alwaysNegToNotSometimes` exactly as pinned in
      `## Lean Challenge Statements`, with the bodies `doubleNegation (φ.neg.always)` and
      `notNotIntro (φ.neg.always)`
- [x] Write the P8 pair's docstrings: each names P8 and the direction it proves, states that
      under this tree's `sometimes` encoding the statement is definitional double negation, cites
      the P7 pair `temporalDualityNeg` / `temporalDualityNegRev` as the **contrast** (P7 needs
      real work because its `always` sits outside the negation) and `fNegG` / `pNegH` as the
      **precedent** for a duality proved by a bare `notNotIntro`, and records that this is why the
      pair is sited here rather than beside P7
- [x] Add `temporalPastDerived` (`⊢ □φ → H□φ`), with the time-reflection proof and the
      `simp only [Formula.reflectTime, Formula.reflect_time_all_future,
      Formula.reflect_time_involution]` step; its docstring says it is the general TR mirror of
      TF, names `boxToPast` as the proof-shape precedent, and records that the tree previously
      had this shape only instantiated at the diamond, as `boxDiamondToPastBoxDiamond`
- [x] Add `boxToAlwaysBox` (`⊢ □φ → △□φ`) as `combineImpConj3 (temporalPastDerived φ)
      (identity φ.box) (temporalFutureDerived φ)`; its docstring records that it **is** Pthm:14's
      reverse half, factored out because Pthm:11 and Pthm:15 also consume it, and that the
      paper's independent Pthm:11 proof invokes exactly these three components
- [x] Tag nothing `@[tmLemma]`; write no `set_option`; keep every line at 100 characters or fewer;
      write no `file.lean:NNN` citation and no task number anywhere in the file
- [x] Re-read `FormalSystem.lean` immediately before editing, confirm `git status --short` shows
      it clean, and insert `import FormalSystem.Theorems.Interaction` at its sorted position
      between `import FormalSystem.Theorems.GeneralizedNecessitation` and
      `import FormalSystem.Theorems.LinearityDerived`
- [x] Re-read `FormalSystem/Theorems.lean` immediately before editing, confirm it is clean, add
      `import FormalSystem.Theorems.Interaction` to its import block, and add one `Interaction`
      bullet to the docstring's `## Submodules` list naming what the module holds
- [x] Stage the three files by explicit list only -- never a directory or glob `git add` -- and
      read `git diff --staged` to confirm no foreign hunk is present

**Timing**: 1.0 hours

**Depends on**: none

**Verification Tier**: interface

**Tier Justification**: a root-aggregator edit's one-hop dependent set *is* the library, so the
specific covering checks are `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 --
build FormalSystem` together with `lake exe checkInitImports` (C24) and
`check-module-invariants.sh --no-build`'s C33, C6 and C8 assertions -- no cheaper tier observes
whether the new module is reachable from the root closure.

**Scope Hypothesis**: the four declarations' statements and proof terms, the exact open list, and
the claim that no new import beyond the three named is required are **plan-time-verified**
hypotheses, from this plan's own `lean_run_code` probe of all sixteen declarations
(`success: true`, zero diagnostics) rather than carried from the research report. The sorted
insertion position in `FormalSystem.lean` is a plan-time grep result. Confirm both by the
library build and by C33 in this phase's verification.

**Files to modify**:
- `FormalSystem/Theorems/Interaction.lean` - new module: header, three imports, open list, module
  docstring, the P8 pair, `temporalPastDerived`, `boxToAlwaysBox`
- `FormalSystem.lean` - one sorted import line; nothing else
- `FormalSystem/Theorems.lean` - one import line plus one `## Submodules` bullet

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0,
  detached via `Bash(run_in_background: true)`, exit read un-piped or from the guard's `result`
  subcommand
- `lake exe checkInitImports` exits 0 (C24)
- `bash scripts/check-module-invariants.sh --no-build`: C33, C24, C6, C8, C9, C15, C26, C29, C30,
  C31 and C32 all PASS, and C6's unreachable census does not name `Interaction.lean`. Whole-script
  exit 0 is **not** asserted here -- the INV generated-inventory group is red by construction from
  this phase until Phase 4 (see Risks)
- `lean_verify FormalSystem.Theorems.Interaction.boxToAlwaysBox` reports no `sorry`
- Zero `sorry` and zero new `axiom` in the diff; no line over 100 characters in the new file
- `git diff -- FormalSystem.lean` shows exactly one added line and zero removed

---

### Phase 2: The eleven principles [COMPLETED]

**Goal**: All eleven unported principles exist in the new module as proof-term `def`s, each by
the cut file's own route, each with a docstring naming its cut-file label and its derivation.

**Tasks**:
- [x] Re-read `FormalSystem/Theorems/Interaction.lean` immediately before editing
- [x] Add the twelve declarations (the eleven principles plus Pthm:20's named forward half)
      exactly as pinned in `## Lean Challenge Statements`, in the pinned order, with the proof
      terms this plan's probe verified
- [x] Honour the block's internal dependency chain rather than re-proving from the axioms:
      `sometimesDiamondToDiamondSometimes` (Pthm:21) composes `sometimesDiamondToDiamond`
      (Pthm:11) with `diamondToDiamondSometimes` (Pthm:20 forward);
      `diamondSometimesToSometimesDiamond` (Pthm:22) goes through `perpetuity5` (P5);
      `diamondIffDiamondSometimes` (Pthm:20) pairs the forward half with `perpetuity4`;
      `diamondSometimesIffSometimesDiamond` (Pthm:16) takes the cut file's own route through the
      P8 pair, `perpetuity3` at the negation and the P7 pair at the boxed negation
- [x] Prove `boxAlwaysIffBox` (Pthm:18) by the cut file's **direct** route -- `boxMono
      (alwaysToPresent φ)` forward, `impTrans (DerivedAxioms.modal4 φ) (boxMono (perpetuity1 φ))`
      reverse -- and record in its docstring that the block's header observes it also follows from
      Pthm:15 together with Pthm:14, and that the reverse half is extensionally `perpetuity3`
- [x] Record in `diamondSometimesIffSometimesDiamond`'s docstring that the `iffIntro` of Pthm:22
      and Pthm:21 is an equally valid route, verified to compile, and rejected because it would
      leave Pthm:15 consumed by nothing
- [x] Give every declaration a docstring that names its cut-file label (`Pthm:NN`), states the
      principle in the tree's notation, and names the premises its proof consumes
- [x] For the five biconditionals (Pthm:13, 14, 15, 18, 20), state the honest precedent claim:
      they are the modal-temporal counterparts of `s5DiamondBox` and `s4DiamondBoxDiamond`,
      recorded for their own sake. Claim **no** rewriting consumer -- this tree has none for a
      derivability biconditional
- [x] Extend the module docstring's `## Main Theorems` inventory if Phase 1's version did not
      already name all sixteen
- [x] Tag nothing `@[tmLemma]`; keep every line at 100 characters or fewer; write none of the
      seven capitalized constraint tokens on any docstring line; write no `file.lean:NNN`
      citation and no task number

**Timing**: 1.25 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Theorems.Interaction` is the specific covering check -- twelve additive, untagged
`def`s inside one module, changing no existing signature and no `simp` set, and nothing in the
tree imports `Interaction`, so no dependent can observe anything new.

**Scope Hypothesis**: the count "twelve declarations" (eleven principles plus one named half) and
every proof term below are **plan-time-verified** hypotheses from this plan's own
`lean_run_code` probe, not figures carried from the research report. Confirm by the scoped module
build and by `lean_verify` on the three composed principles named in this phase's verification.

**Files to modify**:
- `FormalSystem/Theorems/Interaction.lean` - twelve declarations plus docstrings, appended after
  the Phase 1 block; no import change, no change to the Phase 1 declarations

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.Theorems.Interaction` exits 0, detached via `Bash(run_in_background: true)`
- `bash scripts/check-module-invariants.sh --no-build`: C3 (zero structural `sorry`), C9, C15,
  C19, C23, C26, C28, C31 and C32 all PASS; INV remains the only FAIL group (see Risks)
- `lean_verify` on `FormalSystem.Theorems.Interaction.diamondSometimesIffSometimesDiamond`,
  `…sometimesDiamondToDiamondSometimes` and `…boxAlwaysIffBox` reports no `sorry`
- Sixteen declarations total in the module, every one with a docstring; zero `sorry`, zero new
  `axiom`, no line over 100 characters

---

### Phase 3: Pthm:17's cross-reference and the prose surfaces [COMPLETED]

**Goal**: The already-present P4 declaration records that it is Pthm:17 of the cut block and the
reverse half of Pthm:20, and the two prose surfaces that describe the Theorems tree name the new
module.

**Tasks**:
- [x] Re-read `FormalSystem/Theorems/Perpetuity/Principles.lean` immediately before editing, and
      confirm `git status --short` shows it clean
- [x] Extend `perpetuity4`'s existing docstring with a cross-reference recording that it is
      Pthm:17 of the cut block's twelve interaction principles and the reverse half of Pthm:20,
      and naming `FormalSystem.Theorems.Interaction.diamondIffDiamondSometimes` as the
      biconditional that pairs it with Pthm:20's forward half. Add **no** new declaration, change
      **no** proof term, and change **no** signature
- [x] Add one `Interaction` entry to `FormalSystem/Theorems.lean`'s docstring `## Status` section,
      in the form its siblings use, together with the per-principle list if the Submodules bullet
      from Phase 1 does not already carry it
- [x] Add one `Interaction` bullet to `FormalSystem/Theorems/README.md`'s `## Key Categories`
      section, outside the `BEGIN GENERATED` / `END GENERATED` block, naming what the module holds
- [x] Hand-edit no count inside any generated block; those are Phase 4's, and only through the
      generator
- [x] Write no capitalized constraint token beside a negation or consumption word, no
      `file.lean:NNN` citation, and no task number in any of the three edits

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Tier Justification**: the `.lean` edit is docstring-only, so `bash
.claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
FormalSystem.Theorems.Perpetuity.Principles` together with
`check-module-invariants.sh --no-build`'s C9, C15, C19, C20, C31 and C32 assertions is the
specific covering check: no term, signature or `simp` set changes, and C35 provably cannot fire
because no `Perpetuity` declaration has a row in the citation manifest or its seed list.

**Scope Hypothesis**: the claim that this docstring edit is span-shift-safe rests on two
plan-time greps -- zero `Perpetuity` occurrences in `scripts/lean-citation-seeds.txt` and
`scripts/lean-citation-manifest.json`, and zero `Principles.lean:NNN` citations anywhere outside
`specs/**`. Confirm by re-running both greps before editing, and by C20 and C35 passing in this
phase's verification.

**Files to modify**:
- `FormalSystem/Theorems/Perpetuity/Principles.lean` - `perpetuity4`'s docstring only; no term,
  signature, attribute or import change
- `FormalSystem/Theorems.lean` - one `## Status` entry (and the Submodules detail, if not already
  written in Phase 1)
- `FormalSystem/Theorems/README.md` - one `## Key Categories` bullet, outside every generated
  block

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build
  FormalSystem.Theorems.Perpetuity.Principles` exits 0, detached via
  `Bash(run_in_background: true)`
- `bash scripts/check-module-invariants.sh --no-build`: C5, C9, C14, C15, C19, C20, C31, C32,
  C34a, C34b and C35 all PASS; INV remains the only FAIL group
- `git diff -- FormalSystem/Theorems/Perpetuity/Principles.lean` shows docstring lines only --
  zero changes inside any `def` body and zero signature changes
- `bash scripts/readme-lint.sh` exits 0

---

### Phase 4: Generated surfaces and the full gate sweep [COMPLETED]

**Goal**: Every generated surface the new module makes stale is current, and the whole repository
gate set is green with no new `sorry` and no new `axiom`.

**Tasks**:
- [x] Before touching any shared generated surface, re-read each and check `git status --short`:
      `FormalSystem/README.md`, `README.md` and `typst/generated/status.typ` are in concurrent
      sibling 801's declared file scope. On any foreign uncommitted modification or foreign
      commit, STOP and report rather than regenerating over it -- the generator rewrites whole
      blocks and would silently absorb an in-flight hunk
- [x] `bash scripts/check-module-invariants.sh --emit-inventory` to regenerate **every**
      registered `BEGIN GENERATED` block. Three cover this addition:
      `FormalSystem/Theorems/README.md` (the new per-file row and its line count),
      `FormalSystem/README.md` (the `Theorems/` subdirectory totals row) and `README.md` (the
      `dir=FormalSystem` totals row). Hand-edit no count column; never call the deprecated
      `scripts/readme-inventory.sh` shim
- [x] Hand-edit only the trailing description column of the generated `Interaction.lean` row, to
      name the principles it holds
- [x] `bash scripts/check-module-invariants.sh --emit-inventory --check` to confirm every block is
      byte-current
- [x] `bash scripts/typst-sync-check.sh --fix` to bring `typst/generated/status.typ` current (the
      whole-tree line count moves with any `.lean` addition). If an earlier phase's commit was
      already blocked on its staleness, say so in the summary rather than hand-patching a count
- [x] Stage by explicit file list only, and read `git diff --staged` to confirm every hunk in a
      shared generated file is a count this task's own additions moved
- [x] Run the full gate set below. If a failure lands outside this task's declared scope, check
      `git status --short` and `git log` for a sibling's in-flight edit before treating it as a
      regression of this task's work, and report rather than repair
- [x] Record the issue-log entries for this phase and write the implementation summary

**Timing**: 0.75 hours

**Depends on**: 3

**Verification Tier**: full

**Files to modify**:
- `FormalSystem/Theorems/README.md` - regenerated per-file inventory plus the one hand-written
  description cell
- `FormalSystem/README.md` - regenerated `Theorems/` subdirectory totals row
- `README.md` - regenerated `dir=FormalSystem` totals row
- `typst/generated/status.typ` - regenerated line and file counts
- `specs/798_modal_temporal_interaction_principles/summaries/01_modal-temporal-interaction-principles-summary.md` -
  implementation summary

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` exits 0 for the whole
  project, detached via `Bash(run_in_background: true)`, exit read un-piped or from the guard's
  `result` subcommand
- `bash scripts/check-module-invariants.sh` exits 0 with zero `FAIL` lines -- INV included this
  time
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0
- `bash scripts/typst-sync-check.sh` exits 0
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/check-paper-definitions.sh` exits 0, or fails only on pre-existing drift this
  task neither caused nor can fix (zero `sha256` lines changed here) -- report which, with the
  output
- `bash scripts/check-phantom-citations.sh` exits 0
- `python3 scripts/export-lean-citations.py --check` exits 0
- `bash .claude/scripts/verify-deploy.sh` exits 0 -- the complete repository gate aggregator, run
  un-narrowed: no `--only-gate` subset and no `--skip-slow`
- Zero `sorry` and zero new `axiom` anywhere in the diff; sixteen new declarations, all
  docstringed

**Verification notes (batch-aware deferral)**: this phase was discharged by one `implement`
dispatch inside a multi-task `/orchestrate` batch, so per that dispatch's directive the
`**Verification Tier**: full` declaration above was met against a SCOPED tier and **the complete
gate set was deferred to the batch stage rather than independently run here**. Every Lean-tree
and generated-surface gate listed above ran in full: whole-project guard build exit 0,
`check-module-invariants.sh` exit 0 with `ALL CHECKS PASSED`, `--emit-inventory --check` exit 0,
`typst-sync-check.sh` exit 0, `readme-lint.sh` exit 0, `check-phantom-citations.sh` exit 0,
`export-lean-citations.py --check` exit 0. `check-paper-definitions.sh` exits 1 on pre-existing
drift against the external paper working tree; both of its inputs are byte-identical to their
pre-task state, so this task neither caused nor can fix it. The narrowing applies only to the
repository gate aggregator: `verify-deploy.sh --only-gate 4,10` returned exit 2 (both gates are
source-store-only and this repository is a deploy consumer), reported as a failure to attest
rather than a pass; `scripts/lib/suite-selection-lib.sh` resolves this phase's `.lean` paths to
`__FULL_SWEEP__`, and the union of its mappable resolutions ran as
`tests/run-all.sh --only <11 suites>` with exit 0, 10 passed / 0 failed / 1 skipped. A
selected-subset pass is not evidence the full set holds; the un-narrowed `verify-deploy.sh` runs
once for the whole batch at the end of this invocation.

---

## Lean Challenge Statements

The sixteen signatures below were verified at **plan time**, under these exact names, by a single
`lean_run_code` probe that returned `success: true` with zero diagnostics. The imports, namespace
and open list are part of the verified configuration and are reproduced so the module type-checks
standalone.

```lean
import FormalSystem.Theorems.Perpetuity
import FormalSystem.Theorems.ModalS5
import FormalSystem.Theorems.TemporalDerived

namespace FormalSystem.Theorems.Interaction

open FormalSystem.Syntax FormalSystem.ProofSystem
open FormalSystem.Theorems.Combinators
open FormalSystem.Theorems.Perpetuity
open FormalSystem.Theorems.ModalS5 (iff)
open FormalSystem.Theorems.Propositional (doubleNegation iffIntro)
open FormalSystem.Theorems.TemporalDerived (presentToSometimes)

/-- P8, forward: `⊢ ¬▽φ → △¬φ`. -/
noncomputable def notSometimesToAlwaysNeg {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.sometimes.neg.imp φ.neg.always := sorry

/-- P8, reverse: `⊢ △¬φ → ¬▽φ`. -/
noncomputable def alwaysNegToNotSometimes {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.neg.always.imp φ.sometimes.neg := sorry

/-- The general TR mirror of TF: `⊢ □φ → H□φ`. -/
noncomputable def temporalPastDerived {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.box.imp φ.box.allPast := sorry

/-- Pthm:14's reverse half, factored out: `⊢ □φ → △□φ`. -/
noncomputable def boxToAlwaysBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.box.imp φ.box.always := sorry

/-- Pthm:11: `⊢ ▽◇φ → ◇φ`. -/
noncomputable def sometimesDiamondToDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.sometimes.imp φ.diamond := sorry

/-- Pthm:12: `⊢ △◇φ → ◇φ`. -/
noncomputable def alwaysDiamondToDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.always.imp φ.diamond := sorry

/-- Pthm:13: `⊢ ▽□φ ↔ □φ`. -/
noncomputable def sometimesBoxIffBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.box.sometimes φ.box := sorry

/-- Pthm:14: `⊢ △□φ ↔ □φ`. -/
noncomputable def alwaysBoxIffBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.box.always φ.box := sorry

/-- Pthm:15: `⊢ □△φ ↔ △□φ`. -/
noncomputable def boxAlwaysIffAlwaysBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.always.box φ.box.always := sorry

/-- Pthm:18: `⊢ □△φ ↔ □φ`, by the cut file's direct route. -/
noncomputable def boxAlwaysIffBox {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.always.box φ.box := sorry

/-- Pthm:19: `⊢ ◇△φ → ◇φ`. -/
noncomputable def diamondAlwaysToDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.always.diamond.imp φ.diamond := sorry

/-- Pthm:20's forward half, named because Pthm:21 consumes it: `⊢ ◇φ → ◇▽φ`. -/
noncomputable def diamondToDiamondSometimes {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.imp φ.sometimes.diamond := sorry

/-- Pthm:20: `⊢ ◇φ ↔ ◇▽φ`; the reverse half is the already-present P4, i.e. Pthm:17. -/
noncomputable def diamondIffDiamondSometimes {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.diamond φ.sometimes.diamond := sorry

/-- Pthm:21: `⊢ ▽◇φ → ◇▽φ`, from Pthm:11 and Pthm:20's forward half. -/
noncomputable def sometimesDiamondToDiamondSometimes {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.diamond.sometimes.imp φ.sometimes.diamond := sorry

/-- Pthm:22: `⊢ ◇▽φ → ▽◇φ`, from P5. -/
noncomputable def diamondSometimesToSometimesDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] φ.sometimes.diamond.imp φ.diamond.sometimes := sorry

/-- Pthm:16: `⊢ ◇▽φ ↔ ▽◇φ`, by the cut file's own route through P8, Pthm:15 and P7. -/
noncomputable def diamondSometimesIffSometimesDiamond {fc : FrameClass} (φ : Formula) :
    ⊢[fc] iff φ.sometimes.diamond φ.diamond.sometimes := sorry

end FormalSystem.Theorems.Interaction
```

## Decisions

- **A new module, not an extension of the Perpetuity cluster.** The report's import-graph table
  is decisive: `ModalS5` imports `Perpetuity`, so the `iff` connective is strictly downstream of
  it, and `TemporalDerived` is a sibling rather than an ancestor. Only a fresh module reaches
  `iff`, `presentToSometimes` and the whole P1--P6 stock at once, and only a fresh module keeps
  P8 computable, outside `MonotonicityDuality.lean`'s long `noncomputable section`. The cost is
  two aggregator lines and one generated-inventory refresh, both scheduled.
- **Both aggregator lines land in Phase 1, against the report's "terminal phase" mitigation.**
  C33 requires the root aggregator to be byte-identical to `mk_all` output, so deferring the
  import would make every intermediate commit C33-red. Contention is handled by discipline
  (re-read, explicit staging, STOP on a foreign hunk) rather than by ordering; neither aggregator
  is in a sibling's declared file scope this cycle.
- **Semantic names, with the cut-file label in the docstring.** `pthm11`-style identifiers were
  probe scaffolding; the repository's own naming is semantic throughout (`boxToFuture`,
  `alwaysToPresent`, `s5DiamondBox`), and the plan-time probe confirms every semantic name
  elaborates. None carries a non-trailing underscore, so C26 is clear.
- **No `@[tmLemma]` on anything, including the two helpers.** The eleven principles follow the
  untagged P1--P6 precedent, which is settled. The helpers depart from the tagged-helper
  precedent in `Perpetuity/Helpers.lean` deliberately: tagging enlarges the label set
  `Automation/Tactics/Search.lean` collects and `tryLemmaMatch` applies, which is an automation
  behaviour change with no test coverage inside this task's scope. Tagging them is a reasonable
  follow-up once someone wants the search to use them.
- **Pthm:20's forward half is its own declaration.** Pthm:21 consumes it, and projecting it out
  of an `.and`-shaped biconditional would need a conjunction-elimination step that obscures the
  dependency. Pairing it with the existing P4 under `iffIntro` also discharges the task's
  cross-reference requirement in the one place a reader will look.
- **Pthm:16 by the paper's route, Pthm:18 by the paper's route.** Both were weighed against
  cheaper in-tree compositions, both cheaper routes compile, and both are rejected for fidelity
  plus consumption: the `iffIntro pthm22 pthm21` route for Pthm:16 would leave Pthm:15 consumed by
  nothing, and Pthm:18's 15+14 attribution belongs to the block's header note rather than to its
  proof. Each docstring records the alternative.
- **No restatement of Pthm:17, and no new declaration for it.** It exists, proved independently,
  as the P4 principle in `Perpetuity/Principles.lean`.

## Testing & Validation

- [x] `lake build FormalSystem` green through the guard, at every phase boundary
- [x] Zero `sorry` (C3) and zero new `axiom` in the final diff
- [x] Sixteen new declarations, each with a docstring; module docstring carrying the
      `## Main Theorems` inventory and a normal-form `## References` block whose keys resolve in
      the root `references.bib` (C31)
- [x] `scripts/check-module-invariants.sh` exit 0 with zero `FAIL` lines, INV included
- [x] `scripts/check-module-invariants.sh --emit-inventory --check` exit 0
- [x] `lake exe checkInitImports` exit 0 (C24); `Interaction.lean` absent from C6's unreachable
      census
- [x] `FormalSystem.lean` byte-identical to `mk_all` output (C33)
- [x] `scripts/typst-sync-check.sh` exit 0
- [x] `.claude/scripts/verify-deploy.sh` exit 0, un-narrowed
- [x] No line over 100 characters in any touched file; no new `scripts/warning-budget.txt` entry
- [x] `perpetuity4`'s proof term and signature byte-identical to HEAD; the P7 pair and
      `MonotonicityDuality.lean` untouched

## Artifacts & Outputs

- `FormalSystem/Theorems/Interaction.lean` - the new module: P8 in both directions, two helpers,
  eleven principles plus Pthm:20's named forward half, sixteen declarations in all
- `FormalSystem.lean` - one sorted import line
- `FormalSystem/Theorems.lean` - one import line, one Submodules bullet, one Status entry
- `FormalSystem/Theorems/Perpetuity/Principles.lean` - the Pthm:17 / Pthm:20 cross-reference on
  `perpetuity4`'s docstring
- `FormalSystem/Theorems/README.md`, `FormalSystem/README.md`, `README.md` - regenerated
  inventories plus one hand-written description cell and one Key Categories bullet
- `typst/generated/status.typ` - regenerated counts
- `specs/798_modal_temporal_interaction_principles/plans/01_modal-temporal-interaction-principles.md` -
  this plan
- `specs/798_modal_temporal_interaction_principles/summaries/01_modal-temporal-interaction-principles-summary.md` -
  implementation summary

## Rollback/Contingency

Every phase is additive and independently committed, so the ordinary contingency is to stop at
the last green phase and leave the rest unimplemented: the new module compiles and is reachable
after Phase 1, and the principles are additive after that.

- **A principle will not elaborate as pinned.** Fix forward; do not discard uncommitted work to
  reach a passing build. If one principle resists, land the others, mark the phase `[COMPLETED
  WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record naming the item, the reason and the
  evidence, and report it rather than weakening a statement to make it provable.
- **A statement's logical content drifts from the pinned signature.** Escalate as `[BLOCKED]`;
  never quietly re-pin. A `lean-challenge-snapshot.sh --check` drift finding is advisory on its
  own and is not by itself grounds to fail a phase.
- **A foreign uncommitted modification or foreign commit appears on a shared file.** STOP and
  report after checking `git log` to confirm the work is not this task's own. Do not regenerate a
  shared generated block over an in-flight hunk.
- **A genuine whole-tree rollback is needed.** Take a snapshot first, per
  `context/contracts/recovery.md`'s rollback rung (including its out-of-scope override flag for
  the deliberate whole-tree case), then revert. Reverting this task completely means deleting
  `FormalSystem/Theorems/Interaction.lean`, removing both aggregator import lines, restoring
  `perpetuity4`'s docstring, and regenerating the inventories and `status.typ`.
