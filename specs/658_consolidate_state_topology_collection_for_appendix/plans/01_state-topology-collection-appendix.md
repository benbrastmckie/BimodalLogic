# Implementation Plan: Task #658

- **Task**: 658 - Consolidate the state-space topology into a library-grade, citable collection for the manuscript appendix
- **Status**: [NOT STARTED]
- **Effort**: 10.5 hours
- **Dependencies**: None blocking. MUST NOT run concurrently with the sibling open-questions task (Saturation for the two real witnesses; R0 without *Limit*) or with the frame-constraints audit task — all three touch `FormalSystem/Semantics/StateTopology.lean` and its `Counterexamples` sibling.
- **Research Inputs**: `specs/658_consolidate_state_topology_collection_for_appendix/reports/01_state-topology-collection-appendix.md` (plus the seed report `SEED.md` and the three compiled probe files under `probes/`)
- **Artifacts**: plans/01_state-topology-collection-appendix.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research round compiled every mathematical result this task needs against the live library,
so this is **transcription-plus-wiring work, not proof work**: the risk budget belongs to
docstrings, ledger rows, aggregator/README wiring and the zero-warning build, not to tactics.
Three probe files (`probes/GapA_TwoOrigins.lean`, `probes/GapB_Hedgehog.lean`,
`probes/FrameLevelAdditions.lean`) are sorry-free, axiom-clean transplant sources; the plan
promotes them, then closes the collection's real defect — **ledger coverage** — and produces the
headline deliverable, a durable appendix support table keyed by paper label and quotable phrase.

The two open mathematical questions (Gap C: *Saturation* for the two-origin and hedgehog
witnesses; Gap D: R0 without *Limit*) are **out of scope by construction**. Where the appendix
would depend on them, the support table records the dependency as `pending-sibling`.

### Research Integration

Findings that shape the phase structure:

- **Gaps A and B are closed as research results.** All 14 promotion declarations compiled against
  the live library with axioms exactly `[propext, Classical.choice, Quot.sound]`. The probe's
  `RTO` is character-identical to the library's `TwoOrigins.rel`; the probe's `'`-shims are the
  library's own definitions at `D := ℝ`. Implementation is mechanical re-siting.
- **Three frame-level declarations the appendix needs do not exist**, and all three compile:
  `FrameOver.isOpen_iff`, `FrameOver.r0Space_stateTopology` (today `𝒩_F`'s R0 at a frame is
  certified **only by an anonymous `example`**, which no citation can name — the sharpest
  citability gap in the collection), `FrameOver.iInter_cone_eq_singleton`. A fourth,
  `TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial`, states `app:topology-t1` exactly as
  the appendix drafts it, in one name.
- **The principal organizational defect is `docs/theorem-index.md` coverage, not module shape.**
  Five rows cover 1,849 lines; `def:task-topology` and `app:topology-r0` have zero rows between
  them. Research recommends **against** splitting `Counterexamples.lean`, **against** a `Funnel`
  namespace, and **against** renaming `nbhdTopology`/`coneTopology` — those decisions are adopted
  here and are Non-Goals below.
- **The Lean result is stronger than the ratified manuscript statement**:
  `t1Space_nbhdTopology_iff_limit` consumes no frame constraint at all, not even *Seriality*.
- **C15 round trip**: every theorem-index row requires a `Paper:` line in the declaration's own
  `/--` docstring. The probe docstrings carry none; the promotion must add them.
- **C17 synergy**: every promoted declaration is terminal (nothing else references it), so the
  dead-declaration census would list it — except that C17's occurrence corpus includes every
  non-`specs/` `.md` file, so the ledger rows suppress the census entries as a side effect. The
  promotion phases and the ledger phase are therefore planned as one arc.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch; ROADMAP.md was not consulted.

## Goals & Non-Goals

**Goals**:

- Close the promotion gap: the two-origin frame's cone-topology side, including `not_triangle`,
  the four cone-membership lemmas with explicit radii, `coneTopology_eq_nbhdTopology` and
  `not_t2Space_coneTopology`, plus the two frame-level wrappers the manuscript's register needs.
- Name the hedgehog inequality, in both the `≠` form and the stronger strict-fineness `<` form.
- Add the four missing frame-level/general declarations the refactored appendix will cite.
- Raise `docs/theorem-index.md` to citation granularity for the whole collection, including a
  "Notation and naming" row recording the `𝒯_F` symbol reassignment.
- Produce the appendix support table as a durable, citable repository document, with every
  uncertified manuscript statement flagged.
- Give the collection a front door (repository README surfaces) and a non-vacuous test witness.
- Keep every gate green: `lake build --wfail` over the library and `Tests/BimodalTest`,
  `check-module-invariants.sh` all checks pass, `lake exe mk_all --lib FormalSystem --check` exits 0.

**Non-Goals**:

- Editing `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`. The user
  rewrites the appendix; this task makes the collection citable.
- Reopening option (a). The manuscript defines the topology as the cone-neighbourhood topology
  and states `app:topology-t1` as a biconditional. Ratified; not revisited.
- Proving *Saturation* for the two-origin or hedgehog witnesses, or building the R0-without-*Limit*
  witness (sibling task).
- Splitting `Counterexamples.lean`, introducing a `Funnel` namespace, or renaming
  `nbhdTopology`/`coneTopology`. Research weighed and rejected all three.
- Any change that lets a topology-carrying module become reachable from
  `FormalSystem/Semantics.lean`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A promoted declaration lands a compiler warning; C28's budget is zero so `--wfail` fails | H | M | Prefix unused binders with `_` (one unused-binder warning was hit while drafting `FrameOver.iInter_cone_eq_singleton`); run the warning check per phase, not only at the end |
| A new ledger row breaks C15's round trip (missing `Paper:` line at the declaration) | H | M | Write `Paper:` lines as part of each promotion phase, before any row is added; use `—` plus a one-clause reason for formalization-native results, following `TwoOrigins.frame_not_t2Space`'s existing pattern |
| Import weight regresses; a `Preorder ℤ` diamond returns (has happened twice) | H | L | After every code phase assert that `grep -rn "import FormalSystem.Semantics.StateTopology" FormalSystem/` names only `Counterexamples.lean`, and that `FormalSystem/Semantics.lean` imports neither module; regenerate the root with `lake exe mk_all`, never by hand (C33 checks byte-currency) |
| Mathlib's `TopologicalSpace` order direction is written backwards in a docstring or table row | M | M | `t₁ ≤ t₂` means `t₁` is **finer**; so `coneTopology ≤ nbhdTopology` says `𝒯_F` is finer and the strict form is `coneTopology < nbhdTopology`. This cost one failed compile in research. Re-read every fineness sentence against this line |
| A new `docs/reference/` document breaks C12/C13 link resolution or sits unindexed | M | M | Add its `docs/reference/README.md` row in the same phase that creates it; resolve every relative link on disk before closing the phase |
| The support table drifts from the manuscript the user is rewriting independently | M | M | Key every row by paper label or quotable phrase, never by line number; the anchors `def:task-topology`, `app:topology-t1`, `app:topology-r0` are LIVE-UNPINNED in `docs/reference/paper-definitions-of-record.md` and resolve under C15 |
| A new test module drags topology instances into a widely-imported test aggregator | M | L | Keep the test witness a leaf module, for the same import-weight reason as the library modules |
| Concurrent edits from the sibling or audit task collide in the same two files | H | L | The dispatch forbids concurrency; confirm no other task is `implementing` against these files before starting |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3, 5 | 2 (for 3), 4 (for 5) |
| 4 | 6, 9 | 3, 5 |
| 5 | 7, 8 | 6 |
| 6 | 10 | all |

Phases within the same wave can execute in parallel. Phases 2 and 3 touch the same file and are
deliberately serialized; phases 4 and 5 likewise.

---

### Phase 1: Baseline Capture and Probe Re-Verification [NOT STARTED]

**Goal**: Establish the pre-state every later phase is measured against, and confirm the three
probe files still compile verbatim against the current HEAD before any file is edited.

**Tasks**:
- [ ] Confirm no sibling task is mid-implementation against `FormalSystem/Semantics/StateTopology.lean` or its `Counterexamples` sibling (`specs/state.json`)
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and record the pass line, the C19 docstring-coverage percentage and the C28 warning count
- [ ] Run `lake build --wfail` over the library and `Tests/BimodalTest` and record the result
- [ ] Record the import-weight baseline: `grep -rn "import FormalSystem.Semantics.StateTopology" FormalSystem/` (expected: `Counterexamples.lean` only) and confirm `FormalSystem/Semantics.lean` imports neither module
- [ ] Re-run each of the three probe files against the current tree and confirm zero errors, zero warnings, and axioms exactly `[propext, Classical.choice, Quot.sound]`
- [ ] Record the current `docs/theorem-index.md` topology row count and which declarations they name

**Timing**: 0.5 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: The report asserts exactly five existing topology rows in
`docs/theorem-index.md`, zero `sorry` in both modules, and `Counterexamples.lean` as the only
in-tree importer of `StateTopology.lean`. Confirm all three by direct grep at implementation
time; if any differs, record the drift before proceeding rather than assuming the report.

**Files to modify**: none (read-only baseline)

**Verification**:
- All three gate commands recorded with their actual output, not assumed
- All three probes compile clean; any probe that does not is repaired before Phase 2 opens

---

### Phase 2: Promote Gap A — the Two-Origin Cone-Topology Side [NOT STARTED]

**Goal**: Land the two-origin frame's cone-topology results in the library so the manuscript can
say that non-Hausdorffness is a property of the frame rather than an artefact of which topology
is chosen.

**Tasks**:
- [ ] Transplant from `probes/GapA_TwoOrigins.lean` into the `TwoOrigins` namespace of
      `FormalSystem/Semantics/StateTopology/Counterexamples.lean`: `not_triangle`,
      `o_mem_cone_o`, `p_mem_cone_o`, `o_mem_cone_p`, `p_mem_cone_p`,
      `isOpen_nbhdTopology_cone`, `coneTopology_eq_nbhdTopology`, `not_t2Space_coneTopology`
- [ ] Transplant the two frame-level wrappers `frame_coneTop_eq_stateTopology` and
      `frame_not_t2Space_coneTop` (these are what the appendix actually cites — they speak about
      a *frame*, matching the manuscript's register)
- [ ] Drop the probe's `'`-shims in favour of the library's own `Limit`, `nbhdTopology`,
      `coneTopology`, `Triangle`; use the library's `rel` rather than the probe's `RTO`
- [ ] Add a `Paper:` line to every new docstring — `—` plus a one-clause reason for the
      formalization-native results, following `TwoOrigins.frame_not_t2Space`'s existing pattern
- [ ] State in `not_triangle`'s docstring that it is the library's only witness that *Triangle*
      is **sufficient but not necessary** for cone-openness, naming
      `coneTopology_eq_nbhdTopology_of_triangle` as the sufficiency half
- [ ] Preserve the explicit radii (`min t (x-t)`, `x - |s-t|`, `x - t`) in
      `isOpen_nbhdTopology_cone`'s docstring; they are the quotable content

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Ten declarations are asserted for this phase (eight relation-level, two
frame-level). Confirm against `probes/GapA_TwoOrigins.lean`'s actual declaration list at
implementation time; the probe file, not this plan, is authoritative on the count.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` — ten new declarations in the
  `TwoOrigins` namespace, each with a docstring carrying a `Paper:` line

**Verification**:
- `lake build --wfail` green for the module; zero new warnings (C28 budget is zero)
- Zero `sorry`; `#print axioms` on each new declaration reports exactly
  `[propext, Classical.choice, Quot.sound]`
- Import-weight assertion still holds
- No line numbers and no task numbers anywhere in the new docstrings

---

### Phase 3: Close Gap B — Name the Hedgehog Inequality [NOT STARTED]

**Goal**: Turn the bracketed hedgehog fact into named declarations, in both the `≠` form the task
asks for and the stronger strict-fineness form research found.

**Tasks**:
- [ ] Transplant from `probes/GapB_Hedgehog.lean` into the `Hedgehog` namespace of the same
      module: `p_mem_cone_c`, `not_isOpen_nbhdTopology_singleton_c`,
      `coneTopology_ne_nbhdTopology`, `coneTopology_lt_nbhdTopology`
- [ ] Add `Paper:` lines to all four docstrings
- [ ] In the docstrings, state the fineness direction explicitly and correctly: in Mathlib's order
      `coneTopology rel < nbhdTopology rel` says `𝒯_F` is **strictly finer** than `𝒩_F`
- [ ] Cross-reference `isOpen_coneTopology_singleton_c` (the existing half of the bracket) from
      the new inequality's docstring, so a reader arrives at the pair

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: Four declarations are asserted. Confirm against `probes/GapB_Hedgehog.lean`
at implementation time.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology/Counterexamples.lean` — four new declarations in the
  `Hedgehog` namespace

**Verification**:
- `lake build --wfail` green for the module; zero new warnings
- Axiom profile `[propext, Classical.choice, Quot.sound]` on all four
- The fineness direction in every new docstring matches `coneTopology_le_nbhdTopology`'s
  statement, re-read rather than recalled

---

### Phase 4: Add the Missing Frame-Level and Draft-Form Declarations [NOT STARTED]

**Goal**: Complete the frame layer in exactly the places option (a) moves the appendix to, so
every appendix citation lands on a name in the frame register rather than on an anonymous
`example` or a reader-assembled argument.

**Tasks**:
- [ ] Add `FrameOver.isOpen_iff` — the replacement `def:task-topology`'s one-clause Open Sets
      definition at the frame level (`Iff.rfl`)
- [ ] Add `FrameOver.r0Space_stateTopology` — `app:topology-r0` under the new topology, named.
      Decide the fate of the anonymous `example` it supersedes: either replace it or demote it to
      a comment; do not leave two live certifications of the same fact without a note saying why
- [ ] Add `FrameOver.iInter_cone_eq_singleton` — the paper's equality form of *Limit* at a
      regular frame
- [ ] Add `TaskFrame.t1Space_nbhdTopology_iff_iInter_cone_of_serial` — `app:topology-t1` exactly
      as the appendix drafts it, under *Seriality* alone
- [ ] In the last docstring, record that the library's `t1Space_nbhdTopology_iff_limit` consumes
      **no** frame constraint, and that *Seriality* is needed only to upgrade the ⊆-half *Limit*
      to the paper's equality form — the appendix gains a sharper theorem for free
- [ ] Add `Paper:` lines to all four docstrings, with the real anchors where they exist
      (`def:task-topology`, `app:topology-r0`, `app:topology-t1`)
- [ ] Prefix any unused binder with `_` (the source of the one warning research hit)

**Timing**: 1.0 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Four declarations are asserted, three in `FrameOver` and one in
`TaskFrame`. Confirm against `probes/FrameLevelAdditions.lean` at implementation time.

**Files to modify**:
- `FormalSystem/Semantics/StateTopology.lean` — three declarations in the `FrameOver` section,
  one in the `TaskFrame` section; possible removal or demotion of the anonymous R0 `example`

**Verification**:
- `lake build --wfail` green; zero new warnings
- Axiom profile `[propext, Classical.choice, Quot.sound]` on all four
- Nothing under `FormalSystem/` newly imports this module

---

### Phase 5: Symbol-Correspondence Notes and the Formulation Bridges [NOT STARTED]

**Goal**: Make the Lean names readable from a manuscript that has reassigned `𝒯_F`, and make the
paper's closure-based R0/T1 definitions visibly match Mathlib's `R0Space`/`T1Space`.

**Tasks**:
- [ ] Add a symbol-correspondence paragraph to `StateTopology.lean`'s module header: the revised
      `def:task-topology`'s `𝒯_F` is Lean's `TaskFrame.nbhdTopology` / `FrameOver.stateTopology`;
      the footnote's superseded subbasis topology is Lean's `TaskFrame.coneTopology` /
      `FrameOver.coneTop`
- [ ] Mirror the correspondence in both topology `def` docstrings
- [ ] Record in the module header Mathlib's `TopologicalSpace` order convention (`t₁ ≤ t₂` means
      `t₁` is finer), with `coneTopology_le_nbhdTopology` as the worked example
- [ ] Record in the module header the deliberate namespace asymmetry — the funnel's declarations
      sit flat under `StateTopology.funnel_*` while the other two witnesses are nested under
      `StateTopology.TwoOrigins.*` / `StateTopology.Hedgehog.*` — and that this is a decision, not
      an oversight
- [ ] Add the R0 bridge: the paper's `w ∈ cl{u} ↔ u ∈ cl{w}` against Mathlib's `R0Space`, via
      `specializes_iff_mem_closure` — a one-line `theorem` if it is clean, otherwise an explicit
      docstring sentence naming the Mathlib lemma
- [ ] Add the milder T1 bridge: the paper's `cl{w} = {w}` against Mathlib's `T1Space`

**Timing**: 0.75 hours

**Depends on**: 4

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/StateTopology.lean` — module header, both topology `def` docstrings,
  and up to two new bridge declarations

**Verification**:
- `lake build --wfail` green; zero new warnings
- C32 passes: every relative markdown link inside the new `.lean` comments resolves on disk
- The correspondence paragraph names no line numbers and no task numbers
- If a bridge is stated as a declaration, its axiom profile is recorded

---

### Phase 6: Raise `docs/theorem-index.md` to Citation Granularity [NOT STARTED]

**Goal**: Fix the collection's principal defect. A manuscript reader follows a name; the ledger is
where names are looked up, and two of the three labels the appendix carries have no row at all.

**Tasks**:
- [ ] Add a "Notation and naming" row mapping the revised `def:task-topology`'s `𝒯_F` to
      `TaskFrame.nbhdTopology` / `FrameOver.stateTopology`, and the footnote's superseded topology
      to `TaskFrame.coneTopology` / `FrameOver.coneTop`
- [ ] Add ledger rows for the replacement `def:task-topology`
      (`nbhdTopology_isOpen_iff`, `FrameOver.isOpen_iff`) and for `app:topology-r0`
      (`FrameOver.r0Space_stateTopology`, `TaskFrame.r0Space_nbhdTopology_of_limit`)
- [ ] Add rows for `t1Space_nbhdTopology_iff_limit`, the new equality-form biconditional,
      `limit_eq_iff`, `FrameOver.iInter_cone_eq_singleton`,
      `continuous_nbhdTopology_of_history` / `FrameOver.continuous_of_history`,
      `coneTopology_le_nbhdTopology`, `limit_of_t1Space_coneTopology`, `funnel_saturation`,
      `funnel_one_way_pair`
- [ ] Add a row for every Gap A and Gap B promotion from Phases 2 and 3
- [ ] Use the exact row schema C15 enforces:
      `| {Paper label or —} | {Statement, one line} | \`{Fully qualified Lean name}\` | \`{File path, no line numbers}\` | {Frame class or —} | {Axioms} |`
- [ ] Use plain `pcq` unless pinning is deliberately wanted; pinning is a **paired** edit in
      `scripts/check-module-invariants.sh` (the expected-output heredoc and the `#print axioms`
      list) and must be done in both places or not at all
- [ ] Verify the C15 round trip: every row's declaration carries a `Paper:` line in its own `/--`
      docstring

**Timing**: 1.5 hours

**Depends on**: 3, 5

**Verification Tier**: local

**Scope Hypothesis**: Roughly twenty new rows are anticipated (the fourteen promotions plus the
enumerated general-layer results). The real target is coverage, not a count: at implementation
time, enumerate the declarations the appendix support table will cite and confirm each has a row,
rather than counting to twenty.

**Files to modify**:
- `docs/theorem-index.md` — one "Notation and naming" row plus the new ledger rows
- `scripts/check-module-invariants.sh` — only if a row is deliberately pinned, and then in both
  places

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` passes, C15 included
- Every new row's Lean name is fully qualified and its File column carries no line numbers
- Every axiom value matches what was recorded in Phases 2-5, not what was assumed

---

### Phase 7: Give the Collection a Front Door [NOT STARTED]

**Goal**: Make the collection reachable from the repository's public surfaces. Today it appears
only in `FormalSystem/Semantics/README.md`, which is a defect for a collection whose stated
purpose is to be cited from a published appendix.

**Tasks**:
- [ ] Add a short paragraph or row to `FormalSystem/README.md` naming the two topology modules and
      pointing at `docs/theorem-index.md`
- [ ] Add a row to `docs/reference/API_REFERENCE.md` for the topology API's entry points
- [ ] Add a mention in `docs/ARCHITECTURE.md`, including the import-weight rationale for why the
      modules stay out of `Semantics.lean`
- [ ] Extend `FormalSystem/Semantics/README.md`'s existing two rows to cover the promotions
- [ ] Keep every surface a pointer plus at most a five-row highlights table; `docs/theorem-index.md`
      remains the single per-theorem ledger

**Timing**: 1.0 hours

**Depends on**: 6

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/README.md`
- `docs/reference/API_REFERENCE.md`
- `docs/ARCHITECTURE.md`
- `FormalSystem/Semantics/README.md`

**Verification**:
- `bash scripts/check-module-invariants.sh --no-build` passes, including C5/C12/C13 path and link
  resolution and the README structure checks
- No surface contradicts the ledger; each carries a pointer to it
- No task numbers anywhere (these files are outside `specs/`)

---

### Phase 8: The Appendix Support Table [NOT STARTED]

**Goal**: The headline deliverable — a durable, citable document mapping every element the
refactored appendix will contain to the exact Lean declaration that certifies it, with its axiom
profile, and naming every statement the manuscript would assert that the library does not certify.

**Tasks**:
- [ ] Create the support table as a durable reference document under `docs/reference/`, keyed by
      paper label and quotable phrase — **never by line number**, so it survives the user's
      independent rewrite of the appendix
- [ ] Carry the six parts the research report establishes: the replacement `def:task-topology`;
      `app:topology-t1` as a biconditional; `app:topology-r0`; the new history-continuity lemma;
      the footnote recording the superseded subbasis topology with the four-state funnel; and the
      further results the collection now makes worth stating
- [ ] Use the required columns: Manuscript element | Statement | Certifying declaration | Axiom
      profile | Status
- [ ] Update every status the promotions changed: the Gap A and Gap B rows move from
      `to-promote` to `certified`, and the four frame-level rows from `to-state` to `certified`
- [ ] Carry the uncertified list verbatim in substance, with its five items: the over-claimed
      "the topology that makes worlds continuous paths"; the "T1 is inherited by finer topologies"
      reason; every claim that the two-origin or hedgehog witness is a *task frame*
      (`pending-sibling`); R0 without *Limit* (`pending-sibling`); and the paper-vs-Mathlib R0
      formulation gap — noting that Phase 5 closes the last one
- [ ] Record the two "not defects" notes: that the drafted `app:topology-t1` is weaker than what
      Lean proves, and that the `def:frame` gloss claim is interpretive rather than mathematical
- [ ] Add the document's row to `docs/reference/README.md` in this same phase
- [ ] Cross-link it from `docs/theorem-index.md` and from `StateTopology.lean`'s module header

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: local

**Files to modify**:
- `docs/reference/` — one new support-table document
- `docs/reference/README.md` — its index row
- `docs/theorem-index.md` — a cross-link
- `FormalSystem/Semantics/StateTopology.lean` — a module-header pointer

**Verification**:
- Every Lean name cited in the table resolves in the tree (grep each, do not assume)
- Every axiom profile matches what was recorded in Phases 1-5
- Every `pending-sibling` row names the dependency explicitly, so the user can see what is blocked
- `bash scripts/check-module-invariants.sh --no-build` passes, including C12/C13 link resolution
- No line numbers, no task numbers

---

### Phase 9: A Non-Vacuous Test Witness [NOT STARTED]

**Goal**: `Tests/BimodalTest/` contains zero references to the topology collection, so the
acceptance criterion "green over `Tests/BimodalTest`" is currently vacuous for it.

**Tasks**:
- [ ] Add a minimal test module under `Tests/BimodalTest/Semantics/` exercising the headline
      declarations: the biconditional, the R0 result, the history-continuity lemma, and one Gap A
      and one Gap B promotion
- [ ] Keep it a **leaf** module, for the same import-weight reason as the library modules
- [ ] Wire it into the test aggregator per the repository's aggregator convention (C8), and add
      its README row if the test tree requires one

**Timing**: 1.0 hours

**Depends on**: 3, 5

**Verification Tier**: interface

**Files to modify**:
- `Tests/BimodalTest/Semantics/` — one new test module
- the `Tests/BimodalTest` aggregator, and any README the test tree's conventions require

**Verification**:
- `lake build --wfail` green over `Tests/BimodalTest`; zero warnings
- C8 aggregator convention satisfied; C4 import resolution clean
- The new module is imported by nothing except the aggregator

---

### Phase 10: Full Gate Set, Wiring and Closeout [NOT STARTED]

**Goal**: Bring every gate green simultaneously and confirm no invariant regressed.

**Tasks**:
- [ ] Regenerate the library root with `lake exe mk_all --lib FormalSystem`, never by hand, and
      confirm `lake exe mk_all --lib FormalSystem --check` exits 0 (C33 checks byte-currency)
- [ ] Run `lake build --wfail` over the library and `Tests/BimodalTest`; confirm green and zero
      warnings against C28's zero budget
- [ ] Run `bash scripts/check-module-invariants.sh` in full (build half included) and confirm
      ALL CHECKS PASSED
- [ ] Re-assert the import-weight lever: `grep -rn "import FormalSystem.Semantics.StateTopology"
      FormalSystem/` names only `Counterexamples.lean`, and `FormalSystem/Semantics.lean` imports
      neither module
- [ ] Confirm zero `sorry` in both topology modules
- [ ] Read C17's dead-declaration report and confirm the promotions are absent from it, the ledger
      rows having supplied the occurrences
- [ ] Confirm C19 docstring coverage has not fallen below its floor
- [ ] Confirm no task numbers were introduced outside `specs/` and no `file:line` citation was
      introduced anywhere

**Timing**: 1.0 hours

**Depends on**: 2, 3, 4, 5, 6, 7, 8, 9

**Verification Tier**: full

**Files to modify**:
- `FormalSystem.lean` — regenerated only, never hand-edited

**Verification**:
- All four acceptance gates green, with their actual output recorded
- Every invariant that passed in Phase 1's baseline still passes
- Any check that moved (coverage percentage, warning count, census) is explained, not just noted

---

## Testing & Validation

- [ ] `lake build --wfail` green over the library and `Tests/BimodalTest`, zero warnings
- [ ] `bash scripts/check-module-invariants.sh` reports ALL CHECKS PASSED
- [ ] `lake exe mk_all --lib FormalSystem --check` exits 0
- [ ] Zero `sorry` in `StateTopology.lean` and `Counterexamples.lean`
- [ ] Every promoted and newly stated declaration has axiom profile
      `[propext, Classical.choice, Quot.sound]`
- [ ] Every new `docs/theorem-index.md` row satisfies C15's round trip (a `Paper:` line at the
      declaration)
- [ ] The import-weight lever holds: no new importer of either topology module under
      `FormalSystem/`, and `FormalSystem/Semantics.lean` imports neither
- [ ] Every Lean name cited in the appendix support table resolves in the tree
- [ ] No line-number citations and no task numbers outside `specs/`

## Artifacts & Outputs

- Fourteen promoted/newly stated Lean declarations across
  `FormalSystem/Semantics/StateTopology/Counterexamples.lean` and
  `FormalSystem/Semantics/StateTopology.lean`, plus up to two formulation-bridge declarations
- Symbol-correspondence and order-convention notes in `StateTopology.lean`'s module header and
  both topology `def` docstrings
- Extended `docs/theorem-index.md`: a "Notation and naming" row plus citation-granularity ledger
  rows for the whole collection
- A durable appendix support table under `docs/reference/`, indexed from
  `docs/reference/README.md` and cross-linked from the ledger and the module header
- Front-door coverage in `FormalSystem/README.md`, `docs/reference/API_REFERENCE.md`,
  `docs/ARCHITECTURE.md` and `FormalSystem/Semantics/README.md`
- A leaf test module under `Tests/BimodalTest/Semantics/`
- A regenerated `FormalSystem.lean`
- `specs/658_consolidate_state_topology_collection_for_appendix/summaries/01_*-summary.md`

## Rollback/Contingency

Every phase is independently shippable and green at its own boundary, and each is committed on
completion, so rollback is per-phase rather than whole-task: revert the offending phase's commit
and the tree returns to a gate-green state.

Specific contingencies:

- **A promotion fails to compile against HEAD** (Phase 1 catches this before any edit): the tree
  has drifted from the research round. Repair the probe against the live API before promoting;
  do not promote a block that has not compiled in this round.
- **A warning cannot be eliminated** (C28's budget is zero): prefer restructuring the declaration
  over raising the budget. Raising a warning budget is a separate decision with its own
  justification, not a workaround inside this task.
- **A ledger row cannot satisfy C15**: drop the row rather than weakening the check, and record
  the omission in the support table as an uncited declaration.
- **The import-weight assertion fails**: stop and revert immediately. A topology module reaching
  `Semantics.lean` has produced a `Preorder ℤ` diamond twice; this is the one failure mode worth
  halting the task for.
