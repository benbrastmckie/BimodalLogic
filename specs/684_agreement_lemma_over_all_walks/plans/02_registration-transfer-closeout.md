# Implementation Plan (Revision 2): Stability Quantifier Collapse for the Branching Witness Frame

- **Task**: 684 - agreement_lemma_over_all_walks
- **Status**: [COMPLETED]
- **Effort**: 3 hours
- **Dependencies**: 683 (state-sharing witness structure, completed — supplies `total_eq_thread`, `share_of_cls_eq`, `truth_iff_mem`). Registration hand-off to 690 (see Phase 2's Registration Transfer); the hand-off does not block this task's closure.
- **Research Inputs**: `specs/684_agreement_lemma_over_all_walks/reports/01_agreement-lemma-over-all-walks.md`
- **Artifacts**: plans/02_registration-transfer-closeout.md (this file), superseding plans/01_stability-quantifier-collapse.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false


## Revision Note (this round)

This revision changes exactly one thing about the previous plan: **Phase 2's root-aggregator half
is resolved by transfer rather than by execution here.** It carries no new research; its input is
a user decision recorded in `specs/684_agreement_lemma_over_all_walks/.decisions.json` (cycle 5):

> Transfer registration to task 690 Phase 22 (amended to declare a repository-wide regeneration).
> Task 684 does NOT run `mk_all`. Close 684 as complete-modulo-registration: Phase 2 is
> resolved-by-transfer, not by execution here.

Consequences, and nothing beyond them:

- Phase 2 moves `[BLOCKED]` -> `[COMPLETED WITH EXCLUSIONS]`, with a `#### Reasoned Exclusions`
  record naming the one excluded item (the generated import line) and a `#### Registration
  Transfer` record naming its new owner. `FormalSystem.lean` leaves this phase's `Files to
  modify`.
- Phase 3 moves `[PARTIAL]` -> `[COMPLETED WITH EXCLUSIONS]`: its residual was the non-green gate
  run, of which C33 is now transferred and every other failing group is attributed to a
  predecessor or a concurrent task, with no gate citing this task's module. Its attribution table
  is re-measured live rather than carried forward.
- Phases 1 and 4 are preserved verbatim. Both were `[COMPLETED]` and nothing here touches them.
- No file under `FormalSystem/` is edited by this revision. A concurrent task is actively writing
  there.

**Plan-level `[COMPLETED]` means**: every phase of this plan is terminal and no dispatch of this
task has remaining work. It does **not** assert a globally green gate run — C33 is red at this
writing and clears only when task 690's Phase 22 regenerates the root aggregator.

## Overview

The research round established, by axiom audit against the compiled repository rather than by
prose, that this task's literal deliverable — the agreement (truth) lemma over all walks of the
branching witness structure, **box case included** — is already landed and green as
`SharingWitnessFamily.truth_iff_mem` (`Sharing/Agreement.lean:211`), delivered by dependency 683
in the same round. What genuinely remains is the stability (`⊡`) case, and the research round
proved it compiled-live in two probes under this task's own directory.

This plan therefore does not re-prove the box case. It transcribes the two sorry-free probes into
a single new module, `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean`,
wires it into the build graph, and runs the repository's full gate set over the result. The
mathematical content is settled; the risk in this plan is entirely engineering — the build-graph
wiring touches a file inside a concurrent sibling's declared territory, and the module's prose
must satisfy the repository's zero-task-number gate.

This scoping is the answer the user gave at the prior cycle's decision point
(`specs/684_agreement_lemma_over_all_walks/.decisions.json`): re-scope to land
`stabQuant_iff_share_class` and `frame_recurrenceFree` as a new `Sharing/Stability.lean`, and hand
the resulting (C5) statement to the sibling stability-condition work.


**Outcome of this plan, as revised.** The mathematics landed in full: `Sharing/Stability.lean` is
committed at `b3955b837`, sorry-free, axiom-clean, and in the build graph via
`WitnessFamily.lean:23`. The engineering risk the Overview above anticipated — that the wiring
touches a file inside a concurrent task's territory — materialized, and materialized larger than
budgeted: the root aggregator had drifted by 17 modules before this task began, 9 of them the
predecessor's. Rather than have this task regenerate a file it did not drift and cannot bound
while another task is still adding to it, registration is transferred to the task that owns every
registration file. This task closes complete-modulo-registration.

### Research Integration

Every finding below is carried from the research report and shapes a phase:

- **Finding 1** (box case already landed, axiom-clean) — removes the largest phase this task's
  description implied. No phase re-proves `truth_iff_mem`; Phase 3 re-audits it only as a
  regression check.
- **Finding 2** (the collapse, compiled-live) — is Phase 1's content verbatim. The history
  quantifier of the stability clause does **not** range over walks on this frame: it collapses to
  a finite quantifier over the `share`-class of the present index, with the right-hand side
  ranging over `Fin S.lassos.length`. Both directions consume exactly the lemmas the `box` case
  already consumes (`total_eq_thread`, `share_of_cls_eq`, `Thread.const`).
- **Finding 3** ((C5) `StabFaithful` is decidable for free) — is recorded in Phase 1's module
  docstring as the statement the downstream stability-condition work adopts, and is the reason
  Phase 4 exists rather than the condition itself being built here.
- **Finding 4** (the frame is recurrence-free, and `plusValidIn_iff_recurrenceFree` licenses the
  time-stamped carrier) — is Phase 1's second theorem plus the docstring paragraph that closes off
  the "recurrence-freedom is a restriction" objection before a reviewer raises it.
- **Finding 5** (the completeness-side failure mode does NOT transfer) — is a correction to this
  task's own description, recorded as decisions D4/D6 in the module header. The plan explicitly
  forbids adopting the "certificate-side limit-closure schema" framing: the certificate's
  counterpart to a limit-closure schema is a decided least fixpoint, already landed in
  `Sharing/Fulfil.lean`.
- **Finding 6** (scope defect) — is why Phase 4 corrects `file_scope` in `specs/state.json`: the
  recorded value names the **deterministic** modules, which the predecessor's standing
  "ADD ALONGSIDE, DO NOT REPLACE" constraint forbids editing.

- **Revision input (no new research report)** — this round integrates no new research
  artifact. `reports/01_agreement-lemma-over-all-walks.md` remains the sole research input; the
  only new input is the cycle-5 decision in `.decisions.json`, whose effect is confined to
  Phase 2's disposition and Phase 3's residual.

### Prior Plan Reference

`specs/684_agreement_lemma_over_all_walks/plans/01_stability-quantifier-collapse.md` —
this plan's round-1 predecessor, preserved for history. Phases 1 and 4 are carried over
verbatim; Phases 2 and 3 are revised per the Revision Note above. No phase was added and
none removed.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context, so `specs/ROADMAP.md` was not consulted
as a plan input and no roadmap phases are included. A read-only scan found no roadmap item naming
the branching witness device or the stability condition, so this plan advances no tracked roadmap
entry and none needs updating.

## Goals & Non-Goals

**Goals**:

- Land `stabQuant_iff_share_class` — the stability quantifier collapses, on the branching frame,
  to a finite quantifier over one `share`-class — as a sorry-free, axiom-clean theorem in the
  build graph.
- Land `frame_recurrenceFree` — `SharingWitnessFamily.frame.toTaskFrame.RecurrenceFree` — in the
  same module, together with the docstring paragraph citing `plusValidIn_iff_recurrenceFree` as
  the licence that makes recurrence-freedom cost no refuting power.
- Land the deterministic cross-check `stabQuant_iff_self_of_share_eq`, which pins the branching
  device as the minimal extension at which `⊡` stops collapsing to its argument.
- Record the (C5) `StabFaithful` statement, its soundness argument and its decidability route in
  the module docstring, in a form the downstream stability-condition work can cite rather than
  re-derive.
- Leave this task's own contribution green and attributable: no failing gate group citing
  `Sharing/Stability.lean`, with `file_scope` in `specs/state.json` corrected to the files this
  task actually touches. A globally green gate set is explicitly **not** a goal of this plan —
  see Phase 3's Reasoned Exclusions.

**Non-Goals**:

- Re-proving `SharingWitnessFamily.truth_iff_mem` or any part of the box case. It is landed and
  axiom-clean (Finding 1).
- Any L-plus (`PlusFormula`) re-indexing of the certificate, any L-plus closure layer, and any
  definition of the (C5) `StabFaithful` predicate itself. That substrate work belongs to the
  sibling stability-condition task, which declares `Sharing/Predicates.lean`,
  `Sharing/README.md`, `PlusLanguage/Formula.lean` and `PlusLanguage/PlusTruth.lean`. This plan
  writes none of those four files.
- Editing any module of the **deterministic** witness device (`WitnessFamily/Agreement.lean`,
  `WitnessFamily/Basic.lean`, `WitnessFamily/README.md`). The predecessor's standing
  "ADD ALONGSIDE, DO NOT REPLACE" constraint forbids it, and `Sharing/README.md` records the
  invariant that nothing under `Sharing/` edits its parent.
- Editing `Sharing/README.md` to announce the new module. That file is a concurrent sibling's
  declared territory; the announcement is deferred and recorded in Phase 4's handoff note.
- Editing `docs/theorem-index.md` or `FormalSystem/Metalogic/Decidability.lean`. Both are a
  different concurrent sibling's declared territory, and no gate requires either for a new module.
- Adopting any "certificate-side limit-closure schema" framing (Finding 5 / decision D6).
- **Editing the root aggregator `FormalSystem.lean`, or running `lake exe mk_all --lib FormalSystem`,
  under any dispatch.** Added by this revision. The repository-wide regeneration belongs to task
  690's Phase 22, which owns every registration file and is still adding modules to the same
  aggregator. See Phase 2's Registration Transfer record.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The root `FormalSystem.lean` is in a concurrent task's declared file scope, but gate C33 requires it to be byte-for-byte `mk_all` output, so a new module cannot be landed without touching it | H | H | **This risk fired.** The territory check ran and failed open, and the drift turned out to be repository-wide (17 modules) rather than this task's one line. Resolution: the root-aggregator edit is transferred out of this task entirely — see Phase 2's Reasoned Exclusions and Registration Transfer records. This task writes no byte of `FormalSystem.lean` under any dispatch. |
| A task-number citation ("task 683", "task 690") leaks into the new module's prose | M | M | Gate C9 fails the build on exactly this. Phase 1 uses durable anchors only — declaration names, module paths, `Sharing/README.md` — and Phase 3's gate run is the mechanical backstop |
| The merged module's imports are wrong: probe 01 imports `Sharing.Agreement`, probe 02 imports `Sharing.Histories` + `Semantics.HistoryMorphism` | L | M | Phase 1 imports `Sharing.Agreement` (which transitively supplies `Histories`) plus `Semantics.HistoryMorphism`, then confirms by elaboration; gates C4 and C24 catch a resolution or `Init`-reachability failure |
| The two probes were written against separate namespaces/variable blocks and do not merge cleanly | L | M | Both probes already share `namespace FormalSystem.Metalogic.Decidability` / `namespace SharingWitnessFamily` and `variable {Γ Del : Context}`. Phase 1 verifies the merged file elaborates before any other work |
| Gate C17's dead-declaration scan flags the three new theorems (nothing cites them yet) | L | H | C17 is reporting-only in this repository (no `ENFORCE_C17` flag); it never affects the exit code. No action needed, but Phase 3 should not mistake the INFO line for a failure |
| A reader takes "the box case was the obstruction" from this task's title and re-imports the superseded framing into the module | M | M | Phase 1's module header states the correction (decisions D1/D4/D6) once, positively, and does not repeat the superseded framing |
| A concurrent sibling lands an edit to `WitnessFamily.lean` or `FormalSystem.lean` mid-phase and an unexpected build failure appears outside this task's files | M | L | Treat a failure outside this task's own file set as possibly a sibling's in-flight edit, not necessarily a regression; check `git log` before concluding, and report rather than "fixing" a foreign file |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel. This plan is strictly sequential: the module
must elaborate before it can be wired in, it must be wired in before the full gate set is
meaningful, and the records must reflect the tree's actual, attributed state.

---

### Phase 1: Author `Sharing/Stability.lean` [COMPLETED]

**Goal**: A single new module carrying the stability-quantifier collapse, its deterministic
cross-check, and the recurrence-freedom theorem — all sorry-free and elaborating — together with
a module docstring that records the (C5) statement and the three corrections the research round
established.

**Tasks**:

- [x] Read both probes in full before writing anything:
      `specs/684_agreement_lemma_over_all_walks/probes/01_stab_quantifier_collapse.lean` and
      `.../probes/02_recurrence_free_frame.lean`. Both are `lake env lean` exit-0 and sorry-free;
      the proof scripts are to be transcribed, not re-derived.
- [x] Create `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean` with the
      repository's copyright block (copy the four-line form from `Sharing/Histories.lean`), the
      imports `FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Agreement` and
      `FormalSystem.Semantics.HistoryMorphism`, and a `/-! ... -/` module docstring as the first
      command after the imports (Mathlib's header linter enforces that ordering).
- [x] Write the module docstring to record, in this order: (a) that the agreement lemma over all
      walks including the box case is `SharingWitnessFamily.truth_iff_mem` in
      `Sharing/Agreement.lean` and is not re-proved here; (b) the collapse and why it holds —
      the stability clause never inspects the formula, so its quantifier shape is expressible at
      `Formula`; (c) the (C5) `StabFaithful` statement
      `stab φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u`, with the note that it reads only `rep u`
      and `L · u` and is therefore decided by `Sharing/Decide.lean`'s existing one-time window
      reduction, with no analogue of the relative-decidability gap that governs the other
      conditions; (d) the recurrence-freedom licence, citing
      `FormalSystem.Semantics.plusValidIn_iff_recurrenceFree` by name; (e) that the
      completeness-side failure mode (a trace postponing an inevitability forever) and its
      limit-closure cure do **not** transfer to the certificate side, because fulfilment here is
      an assumed and checked hypothesis decided by `Sharing/Fulfil.lean`'s least fixpoint, not a
      derived one.
- [x] Transcribe `StabQuant` (a `def`, PascalCase — gate C26 rejects snake_case `def` names) with
      its docstring.
- [x] Transcribe `stabQuant_iff_share_class` with its proof script verbatim from probe 01,
      including the `rwa [show s + t = s' + t from by omega] at hmem` step. The research round
      recorded that the naive `subst` on `s' = s` fails here (it eliminates the wrong variable);
      do not "simplify" it back.
- [x] Transcribe `stabQuant_iff_self_of_share_eq` (the deterministic cross-check) with its
      docstring noting the correspondence to `PlusLanguage.stab_iff_of_deterministic`.
- [x] Transcribe `frame_recurrenceFree` from probe 02, keeping the explicit
      `have h : (s + a : ℤ) = (s + b : ℤ) := htime` ascription: the research round recorded that
      `omega` fails at that goal without it, because `Duration` is not syntactically `ℤ` there.
- [x] Scan the finished file for task-number citations and remove any. Cite durable anchors only
      (declaration names, module paths). Gate C9 asserts zero task-number citations under
      `FormalSystem/`.
- [x] Confirm the file elaborates sorry-free: `lake env lean` on the file, or
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Stability`
      once Phase 2 has wired it (before wiring, `lake env lean` on the path is the available
      route). Never a plain foreground `lake build`.
- [x] Commit this green sub-step.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: The merged module is estimated at 200-280 lines (probe 01 is ~110 lines,
probe 02 ~50, plus an expanded module docstring), and the new declarations are exactly four:
`StabQuant`, `stabQuant_iff_share_class`, `stabQuant_iff_self_of_share_eq`, `frame_recurrenceFree`.
Confirm at implementation time with `wc -l` on the finished file and by reading back the
declaration list; if the count or the declaration set differs, say so in the phase record rather
than silently adopting the new number.

**Scope Hypothesis Outcome**: Declaration set held exactly — `StabQuant`,
`stabQuant_iff_share_class`, `stabQuant_iff_self_of_share_eq`, `frame_recurrenceFree`, four and no
more. Line count came in at **174**, below the 200-280 estimate: the two probes' own preamble
comments (which the estimate counted) were replaced by a single module docstring rather than added
to it. Nothing was omitted — every proof script was transcribed verbatim.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean` — new file; the
  entire content of this phase.

**Verification**:

- The file elaborates with exit 0 and no `sorry`.
- `grep -n "sorry" FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean`
  returns nothing outside prose.
- The four declarations above are present with the names given.
- No task-number citation appears anywhere in the file.
- No file outside this task's scope was touched (`git status --short`).

---

### Phase 2: Wire the module into the build graph [COMPLETED WITH EXCLUSIONS]

**Goal**: The new module is reachable from the aggregator this task owns, and the root-aggregator
half — which turned out to be a repository-wide regeneration rather than this task's one-line
addition — is transferred to the task that owns the registration files.

**Tasks**:

- [x] Re-read `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` immediately before editing
      (a sibling may have changed it). It currently imports the nine `Sharing.*` modules on
      lines 14-22; add `import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Stability`
      in the position the existing ordering implies.
- [x] **Territory check before touching the root aggregator.** *(deviation: check RAN and FAILED OPEN — a foreign uncommitted modification to `FormalSystem.lean` was found; stopped as the plan directs)* `FormalSystem.lean` is inside a
      concurrent sibling's declared file scope. Re-read it immediately beforehand and run
      `git log --oneline -3 -- FormalSystem.lean`; if a foreign commit or a foreign uncommitted
      modification is present, STOP and report it rather than proceeding.
- [~] **EXCLUDED — resolved by transfer, not by execution here.** Regenerate the root aggregator
      with `lake exe mk_all --lib FormalSystem`. This task does **not** run `mk_all`. See the
      Reasoned Exclusions record below and the Registration Transfer section that follows it.
- [x] *(deviation: altered — one hunk, not two; the root-aggregator hunk was never produced, and under this revision never will be)* Stage and commit **only** the hunks this phase produced — never a directory or glob
      pathspec, never `git add -A`, never `git commit -am`. Review with `git status --short` and
      `git diff --staged` first.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| The one generated `import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Stability` line in the root aggregator `FormalSystem.lean` | Writing it requires running `lake exe mk_all --lib FormalSystem`, which is not a one-line operation on this tree: it is a repository-wide regeneration of drift this task did not create and cannot bound. This phase's own Scope Hypothesis mandates STOP-and-report if `mk_all` rewrites more than one line, and it does. Ownership of the regeneration is transferred to the concurrent task that owns every registration file (`FormalSystem.lean`, `Decidability.lean`, `PlusLanguage.lean`, `docs/theorem-index.md`) and that is still adding modules to the same aggregator; it is that task's Phase 22. | C33 reports **17** modules absent from the root, not 1. Attribution by module path: 9 to the predecessor task (`Sharing/{Agreement,Basic,Decide,Frame,Fulfil,Histories,Predicates,Specialize,Thread}`), 1 to this task (`Sharing/Stability`), the remainder to the concurrent registration-owning task (`Sharing/{Skeleton,Window}`, `PlusWitnessFamily/{Basic,Closure,Decide,Examples,Predicates}`, `PlusLanguage/Subformulas`). The drift **predates this task**: `git show d139659eb:FormalSystem.lean \| grep -c Sharing` returns `0`, and `d139659eb` precedes every commit of this task (`642e5a55e`, `b3955b837`). The count is still rising as the concurrent task lands modules — it was 11 at the prior dispatch, 16 at this revision's dispatch, and 17 when re-measured live during this revision — which is itself the argument that the regeneration belongs to the task still writing, not to this one. |
| Nothing else. The excluded set is exactly the one line above. | — | `git diff --stat` across this task's two commits shows exactly `Sharing/Stability.lean` (new, 174 lines) and one added import line in `WitnessFamily.lean`. |

**Admission test**: the exclusion is a user decision recorded in
`specs/684_agreement_lemma_over_all_walks/.decisions.json` (cycle 5), not a stuck attempt (1); it
names exactly one enumerated item (2); the reason is stated (3) and evidenced by live gate output
and a `git show` against a pre-task commit (4); and nothing remains for a future dispatch **of
this task** to pick up (5). On condition 5 the honest caveat is that the line itself is not
discarded — it is re-homed into another task's declared scope, where it is that task's own
planned work rather than a follow-up tracked against this one. This task will not revisit it.

#### Registration Transfer

- **Transferred to**: task 690's Phase 22 (`Registration, module invariants, and documentation`),
  in `specs/690_stability_condition_over_branching_frame/plans/01_stability-condition-branching-frame.md`.
  That phase already owns `FormalSystem.lean`, `Decidability.lean`, `PlusLanguage.lean` and
  `docs/theorem-index.md`, and its R1 risk row already names the territory overlap with this task.
- **What that phase must do for C33 to clear**: a single repository-wide
  `lake exe mk_all --lib FormalSystem`, which picks up this task's `Sharing.Stability` alongside
  the predecessor's nine and its own modules in one regeneration. Registering only its own modules
  leaves C33 red.
- **Transfer verified landed.** Task 690's Phase 22 task list now reads *"Regenerate
  `FormalSystem.lean`'s import list with `lake exe mk_all --lib FormalSystem`. **This regeneration
  is REPOSITORY-WIDE and is EXPECTED TO BE WIDE**"*, and enumerates the missing modules by
  attribution — including, explicitly, *"1 transferred here from the stability-condition-at-
  `Formula` task, which closes as complete-modulo-registration on the same user decision:
  `WitnessFamily/Sharing/Stability`"*. The receiving phase therefore names this task's module and
  declares the wide scope; the transfer is accepted on both sides, not merely asserted on this
  one. (That plan also records that `mk_all` is not declared in `lakefile.toml` and resolves
  through Mathlib at `.lake/packages/mathlib/.lake/build/bin/mk_all`.)
- **Count drift is expected, not a discrepancy**: task 690's Phase 22 cites 16 missing modules;
  C33 re-measured live during this revision reports 17. The count rises as that task lands
  modules, and its phase text already covers *"all of them plus whatever the remaining phases of
  this task add"*. No reconciliation is needed.
- **Nothing in this task's mathematics depends on it**: `Sharing/Stability.lean` is reachable from
  `FormalSystem.Metalogic.Decidability.WitnessFamily` (its `import` line is committed at
  `b3955b837`), which `FormalSystem.lean` already imports, so the module is in the build graph and
  compiles today. Only C33's byte-for-byte assertion about the generated root is outstanding.

**Prohibited workarounds** (unchanged, and now permanent for this task): do NOT hand-write the
import line into `FormalSystem.lean`, do NOT run `mk_all` from this task under any dispatch, and
do NOT use `sorry` or a vacuous placeholder anywhere.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: The original hypothesis — exactly two files change, one added import line
each — **FAILED on the root-aggregator half**, and the Reasoned Exclusions record above is that
hypothesis's closing act. The surviving hypothesis is one file
(`FormalSystem/Metalogic/Decidability/WitnessFamily.lean`), one added import line, which held.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — one added `import` line. Landed at
  `b3955b837`.
- ~~`FormalSystem.lean`~~ — removed from this phase's scope by the transfer above. This task
  writes no byte of the root aggregator.

**Verification**:

- `git diff --stat` over this phase's commit shows exactly one file and one added line.
- `grep -n 'Sharing.Stability' FormalSystem/Metalogic/Decidability/WitnessFamily.lean` returns the
  import line (confirmed live: line 23).
- No file outside the one named above is staged.
- C33 is **not** a verification criterion for this phase any more; it is task 690 Phase 22's.

---

### Phase 3: Full gate run and axiom audit [COMPLETED WITH EXCLUSIONS]

**Goal**: The repository's gate set is run with the new module in the build graph, every failing
group is attributed, and the new theorems are confirmed to rest on the three standard axioms only.

**Tasks**:

- [x] Run the full build through the guard:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, capturing to a log
      and following the bounded-build-waiter discipline (hard timeout, writer liveness via
      `kill -0` on the captured PID, one waiter per log).
- [x] Run `bash scripts/check-module-invariants.sh` and read the result against these specific
      expectations: C1 (build), C3 (zero structural sorry), C4 (imports resolve), C9 (zero
      task-number citations under `FormalSystem/`), C24 (the new module transitively imports
      `FormalSystem.Init`), C26 (no snake_case `def`) must all pass. C17's dead-declaration scan
      will likely report the new declarations as having no other occurrence — it is reporting-only
      and must not be "fixed" by adding a fake consumer.
- [x] Run `bash scripts/check-copyright-headers.sh --strict FormalSystem` and confirm the new
      file passes.
- [x] Audit the axioms of the three new theorems with `lean_verify` on the fully qualified names
      (`...SharingWitnessFamily.stabQuant_iff_share_class`, `...stabQuant_iff_self_of_share_eq`,
      `...frame_recurrenceFree`). Expect `{propext, Classical.choice, Quot.sound}` and no
      warnings, matching the landed `truth_iff_mem`.
- [x] Re-audit `...SharingWitnessFamily.truth_iff_mem` as a regression check — it must still
      report the same three axioms and no warnings.
- [x] *(deviation: altered — one gate failure was this task's to fix and was fixed (`linter.style.show`, C28); the remaining failing groups are pre-existing or concurrent-sibling, itemized below, and fixing a sibling's in-flight file is exactly what the territory contract forbids)* If any gate fails, fix the cause; never flip an `ENFORCE_*` flag to quiet a failure.
- [x] *(deviation: altered — the gate run is not green; the evidence and the attribution are committed instead)* Commit the green gate run.

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| A globally green `check-module-invariants.sh` exit 0 | Every failing group is caused by a predecessor's landed code or a concurrent task's in-flight code, and none cites this task's module. The territory contract forbids this task from editing a sibling's in-flight file, so a global green is not achievable from inside this task at any dispatch. | Re-measured live during this revision: the failing groups are C5, C6, INV, C16, C23 (x2), C28, C29, C33. `bash scripts/check-module-invariants.sh 2>&1 \| grep -i Stability` returns **nothing** — no gate cites `Sharing/Stability.lean`. The attribution table below itemizes ownership per group. |
| C33 specifically | Transferred to task 690 Phase 22. See Phase 2's Registration Transfer record. | Phase 2 Reasoned Exclusions, above. |

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserted that eight named gates were the ones this change class
could break, and that no new baseline file needed an entry.

**Scope Hypothesis Outcome — the hypothesis FAILED, in this task's favour**: the phase assumed
C33 could break and that a corrective `mk_all` would add one line. In fact **C33 was already
failing before this dispatch**: `git show d139659eb:FormalSystem.lean | grep -c Sharing` returns
**0** — the root aggregator listed none of the nine predecessor `Sharing.*` modules. A corrective
`mk_all` is therefore a repository-wide repair of pre-existing drift, not the one-line addition
this plan budgeted, and it is not a repair this task can bound while a concurrent task is still
adding modules to the same file. That is the finding the Phase 2 transfer acts on.

No baseline file needed an entry for this module, as hypothesized — with one exception the
hypothesis got wrong in the other direction: `scripts/warning-budget.txt` has a **zero** baseline
and disposition `linter.style.show blocking`, and the probe's `show` tactic tripped it. Fixed by
`change`, in-phase, and C28 no longer names this module.

**Gate attribution** (re-measured live at this revision; 9 failing groups):

| Gate | Cited location | Whose |
|------|----------------|-------|
| C5 | unresolved module path in non-specs markdown (`Sharing/README.md`) | concurrent sibling, in-flight |
| C6 | 6 unreachable live modules absent from the manifest | concurrent sibling, in-flight |
| INV | 4 stale generated inventory blocks | stale from all three concurrent tasks' new modules |
| C16 | env_linter findings beyond `scripts/nolints.json` | concurrent sibling, in-flight |
| C23 | 2 `Uppercase_x` names; 7 outer-shadows-inner pairs | predecessor + sibling, pre-existing |
| C28 | compiler-warning count above `scripts/warning-budget.txt` | concurrent sibling, in-flight |
| C29 | 2 unreasoned `set_option linter.* false` | predecessor, pre-existing |
| C33 | 17 modules absent from the root | 9 predecessor + 1 this task + 7 sibling; transferred (Phase 2) |

Not one failing group is caused by `Sharing/Stability.lean`'s content, and no gate output names
the file. C1 (`lake build` exits 0), C3, C4, C9, C24, C26 and C9D all pass, and C9 confirms zero
task-number citations under `FormalSystem/`.

**Evidence of this task's own green state**, captured at commit `b3955b837` before the sibling
edits landed: full `lake build` through `lake-build-guard.sh --timeout 1800`, guard exit 0,
"Build completed successfully (2753 jobs)", zero `error:` and zero `warning:` lines;
`check-copyright-headers.sh --strict FormalSystem` exit 0; all four axiom audits
`{propext, Classical.choice, Quot.sound}` with no warnings. Re-verified after the sibling's
`Sharing/Skeleton.lean` + `Sharing/Basic.lean` refactor landed at `7eb4897a3`: scoped build of
`FormalSystem.Metalogic.Decidability.WitnessFamily` through the guard, exit 0, 1489 jobs, 0
errors, 0 warnings. At this revision the module is still committed and unmodified at `b3955b837`
with a `sorry` count of 0.

**Files to modify**:

- None. Any file this phase changed was a gate failure being fixed and is named in the record
  above (`Sharing/Stability.lean`'s `show` -> `change`, for C28).

**Verification**:

- `lake build` exits 0 through the guard — **met** (b3955b837 / 7eb4897a3 evidence above).
- `check-copyright-headers.sh --strict FormalSystem` exits 0 — **met**.
- All four axiom audits report `{propext, Classical.choice, Quot.sound}` with no warnings — **met**.
- `check-module-invariants.sh` exits 0 — **excluded**, per the Reasoned Exclusions record above.
  The substitute criterion, which is met, is: no failing gate group cites this task's module.

---

### Phase 4: Correct the task record and hand off the (C5) statement [COMPLETED]

**Goal**: The task's recorded scope matches what it actually touched, and the downstream
stability-condition work has a precise, citable statement rather than a description to re-derive.

**Tasks**:

- [x] Correct `file_scope` for this task in `specs/state.json`. The recorded value names the
      deterministic modules (`WitnessFamily/Agreement.lean`, `WitnessFamily/Basic.lean`,
      `WitnessFamily/README.md`, `WitnessFamily.lean`) — three of which this task must not touch
      at all. Replace it with the files actually in scope:
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean`,
      `FormalSystem/Metalogic/Decidability/WitnessFamily.lean`, `FormalSystem.lean`. Update the
      `file_scope` key only; do not replace the `artifacts` array (it is append-only with
      same-type supersession) and do not edit `TODO.md` directly.
- [x] Write `specs/684_agreement_lemma_over_all_walks/handoff-c5-statement.md`: a short note
      naming (a) the exact (C5) `StabFaithful` statement,
      `stab φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u`; (b) `stabQuant_iff_share_class` as its
      soundness argument, with the module path; (c) `Sharing/Decide.lean`'s window congruence at
      line 237 and the `AtomCoherentAt` reduction as the decidability route, with `Formula.atom p`
      replaced by `stab φ`; (d) `stabQuant_iff_self_of_share_eq` as the deterministic
      cross-check; (e) the deferred `Sharing/README.md` announcement, which this task did not make
      because that file is the sibling's territory. Task numbers are permitted in this file — it
      is under `specs/**`.
- [x] Record in the same note that the completeness-side failure mode does not transfer, and that
      the shared content with the completeness line is the histories characterization
      (`total_eq_thread`) only — so neither line should wait on the other.
- [x] Commit the records.

**Timing**: 0.25 hours

**Depends on**: 3

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:

- `specs/state.json` — `file_scope` for this task only.
- `specs/684_agreement_lemma_over_all_walks/handoff-c5-statement.md` — new file.

**Verification**:

- `jq '.active_projects[] | select(.project_number==684) | .file_scope' specs/state.json` returns
  the three-file list above.
- The `artifacts` array for this task still contains its report entry.
- The handoff note names all five items and cites declarations by name, not by description alone.

## Testing & Validation

- [x] `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean` elaborates
      sorry-free.
- [x] `lake build` exits 0 through `lake-build-guard.sh` with an explicit `--timeout`.
- [x] `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0.
- [x] `lean_verify` on `stabQuant_iff_share_class`, `stabQuant_iff_self_of_share_eq` and
      `frame_recurrenceFree` each reports `{propext, Classical.choice, Quot.sound}`, no warnings.
- [x] `lean_verify` on `truth_iff_mem` is unchanged from the research round's audit.
- [x] No file under `WitnessFamily/` other than the aggregator, and no file under `Sharing/` other
      than the new `Stability.lean`, was modified. No file in a concurrent task's declared scope
      was modified at all — including `FormalSystem.lean`, which this revision removes from scope.
- [x] `bash scripts/check-module-invariants.sh`: C1, C3, C4, C9, C24, C26 and C9D pass, and no
      failing gate group cites `Sharing/Stability.lean`.
- [ ] **Deferred to task 690 Phase 22 — not a criterion of this task**: C33 passes
      (`FormalSystem.lean` byte-current against `lake exe mk_all --lib FormalSystem`).

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean` (new module, 174
  lines, four declarations) — landed
- One added import line in `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — landed
- ~~One added sorted import line in `FormalSystem.lean`~~ — transferred to task 690 Phase 22
- `specs/684_agreement_lemma_over_all_walks/handoff-c5-statement.md` — landed
- Corrected `file_scope` for this task in `specs/state.json` — landed. Note that `file_scope`
  still lists `FormalSystem.lean`; it is descriptive/anticipated and is not mutated by
  status-sync, so leaving it is harmless, but a reader should take Phase 2's Registration
  Transfer as authoritative over it.
- `specs/684_agreement_lemma_over_all_walks/summaries/01_stability-quantifier-collapse-summary.md`
  — landed

## Rollback/Contingency

The change is strictly additive: one new module plus one one-line import addition. Reverting is
`git revert` of this task's two commits (`642e5a55e`, `b3955b837`), which removes the module and
restores `WitnessFamily.lean` — no other declaration in the tree references it, so nothing else
breaks. The root aggregator is untouched by this task, so a revert cannot destabilize it.

If a genuine rollback of uncommitted work becomes necessary, take a snapshot first with
`bash .claude/scripts/git-snapshot.sh 684` (adding `--allow-out-of-scope` only for a deliberate
whole-tree rollback) before any destructive git command. Do **not** emit a bare, default-mode
`git-snapshot.sh` call as a routine checkpoint; a defensive checkpoint before risky work uses
`--no-revert`.

**Contingency if the transfer does not land**: if task 690's Phase 22 completes without
regenerating the root aggregator repository-wide, C33 stays red with this task's `Sharing.Stability`
among the missing modules. The correct response is a new task owning the repository-wide
regeneration — not a re-opening of this one, whose Phase 2 exclusion is decided. Whoever observes
that state should first check task 690's Phase 22 wording against the caveat recorded in this
plan's Registration Transfer section.
