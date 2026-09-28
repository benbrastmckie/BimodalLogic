# Implementation Plan: Stability Quantifier Collapse for the Branching Witness Frame

- **Task**: 684 - agreement_lemma_over_all_walks
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: 683 (state-sharing witness structure, completed — supplies `total_eq_thread`, `share_of_cls_eq`, `truth_iff_mem`)
- **Research Inputs**: `specs/684_agreement_lemma_over_all_walks/reports/01_agreement-lemma-over-all-walks.md`
- **Artifacts**: plans/01_stability-quantifier-collapse.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

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

### Prior Plan Reference

No prior plan. This is the task's first planning round.

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
- Leave the repository green under the full gate set, with `file_scope` in `specs/state.json`
  corrected to the files this task actually touches.

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

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The root `FormalSystem.lean` is in a concurrent sibling's declared file scope, but gate C33 requires it to be byte-for-byte `mk_all` output, so a new module cannot be landed without touching it | H | H | Phase 2 re-reads the file immediately before editing, regenerates it with `lake exe mk_all --lib FormalSystem` (a single sorted import line is the whole diff), commits **only that hunk**, and records the cross-territory touch in the orchestrator handoff. If a foreign modification or foreign commit to that file is observed, STOP and report rather than proceeding |
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
meaningful, and the records must reflect a green tree.

---

### Phase 1: Author `Sharing/Stability.lean` [NOT STARTED]

**Goal**: A single new module carrying the stability-quantifier collapse, its deterministic
cross-check, and the recurrence-freedom theorem — all sorry-free and elaborating — together with
a module docstring that records the (C5) statement and the three corrections the research round
established.

**Tasks**:

- [ ] Read both probes in full before writing anything:
      `specs/684_agreement_lemma_over_all_walks/probes/01_stab_quantifier_collapse.lean` and
      `.../probes/02_recurrence_free_frame.lean`. Both are `lake env lean` exit-0 and sorry-free;
      the proof scripts are to be transcribed, not re-derived.
- [ ] Create `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean` with the
      repository's copyright block (copy the four-line form from `Sharing/Histories.lean`), the
      imports `FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Agreement` and
      `FormalSystem.Semantics.HistoryMorphism`, and a `/-! ... -/` module docstring as the first
      command after the imports (Mathlib's header linter enforces that ordering).
- [ ] Write the module docstring to record, in this order: (a) that the agreement lemma over all
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
- [ ] Transcribe `StabQuant` (a `def`, PascalCase — gate C26 rejects snake_case `def` names) with
      its docstring.
- [ ] Transcribe `stabQuant_iff_share_class` with its proof script verbatim from probe 01,
      including the `rwa [show s + t = s' + t from by omega] at hmem` step. The research round
      recorded that the naive `subst` on `s' = s` fails here (it eliminates the wrong variable);
      do not "simplify" it back.
- [ ] Transcribe `stabQuant_iff_self_of_share_eq` (the deterministic cross-check) with its
      docstring noting the correspondence to `PlusLanguage.stab_iff_of_deterministic`.
- [ ] Transcribe `frame_recurrenceFree` from probe 02, keeping the explicit
      `have h : (s + a : ℤ) = (s + b : ℤ) := htime` ascription: the research round recorded that
      `omega` fails at that goal without it, because `Duration` is not syntactically `ℤ` there.
- [ ] Scan the finished file for task-number citations and remove any. Cite durable anchors only
      (declaration names, module paths). Gate C9 asserts zero task-number citations under
      `FormalSystem/`.
- [ ] Confirm the file elaborates sorry-free: `lake env lean` on the file, or
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Stability`
      once Phase 2 has wired it (before wiring, `lake env lean` on the path is the available
      route). Never a plain foreground `lake build`.
- [ ] Commit this green sub-step.

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

### Phase 2: Wire the module into the build graph [NOT STARTED]

**Goal**: The new module is reachable from both aggregators the repository's gates assert against,
with the cross-territory touch to the root aggregator made minimally and reported.

**Tasks**:

- [ ] Re-read `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` immediately before editing
      (a sibling may have changed it). It currently imports the nine `Sharing.*` modules on
      lines 14-22; add `import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Stability`
      in the position the existing ordering implies.
- [ ] **Territory check before touching the root aggregator.** `FormalSystem.lean` is inside a
      concurrent sibling's declared file scope. Re-read it immediately beforehand and run
      `git log --oneline -3 -- FormalSystem.lean`; if a foreign commit or a foreign uncommitted
      modification is present, STOP and report it rather than proceeding.
- [ ] Regenerate the root aggregator with `lake exe mk_all --lib FormalSystem` and confirm the
      diff is exactly one added sorted `import` line. Gate C33 compares this file byte-for-byte
      against `mk_all` output, so a new module under `FormalSystem/` cannot be landed without
      this step — it is not optional and not deferrable to the sibling.
- [ ] Stage and commit **only** the two hunks this phase produced — never a directory or glob
      pathspec, never `git add -A`, never `git commit -am`. Review with `git status --short` and
      `git diff --staged` first.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: Exactly two files change in this phase
(`FormalSystem/Metalogic/Decidability/WitnessFamily.lean` and `FormalSystem.lean`), one added
import line each. Confirm with `git diff --stat` before committing; if `mk_all` rewrites more than
one line of the root, stop and report rather than committing the wider diff.

**Files to modify**:

- `FormalSystem/Metalogic/Decidability/WitnessFamily.lean` — one added `import` line.
- `FormalSystem.lean` — one added sorted `import` line, produced by `mk_all`, not hand-written.
  Cross-territory: shared with a concurrent sibling; see the territory check above.

**Verification**:

- `git diff --stat` shows exactly two files and one added line each.
- The build of `FormalSystem.Metalogic.Decidability.WitnessFamily` succeeds through the guard
  script with an explicit `--timeout`.
- No file outside the two named above is staged.

---

### Phase 3: Full gate run and axiom audit [NOT STARTED]

**Goal**: The repository is green under its complete gate set with the new module in the build
graph, and the new theorems are confirmed to rest on the three standard axioms only.

**Tasks**:

- [ ] Run the full build through the guard:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build`, capturing to a log
      and following the bounded-build-waiter discipline (hard timeout, writer liveness via
      `kill -0` on the captured PID, one waiter per log).
- [ ] Run `bash scripts/check-module-invariants.sh` and read the result against these specific
      expectations: C1 (build), C3 (zero structural sorry), C4 (imports resolve), C9 (zero
      task-number citations under `FormalSystem/`), C24 (the new module transitively imports
      `FormalSystem.Init`), C26 (no snake_case `def`), C33 (root aggregator is byte-current) must
      all pass. C17's dead-declaration scan will likely report the new declarations as having no
      other occurrence — it is reporting-only and must not be "fixed" by adding a fake consumer.
- [ ] Run `bash scripts/check-copyright-headers.sh --strict FormalSystem` and confirm the new
      file passes.
- [ ] Audit the axioms of the three new theorems with `lean_verify` on the fully qualified names
      (`...SharingWitnessFamily.stabQuant_iff_share_class`, `...stabQuant_iff_self_of_share_eq`,
      `...frame_recurrenceFree`). Expect `{propext, Classical.choice, Quot.sound}` and no
      warnings, matching the landed `truth_iff_mem`.
- [ ] Re-audit `...SharingWitnessFamily.truth_iff_mem` as a regression check — it must still
      report the same three axioms and no warnings.
- [ ] If any gate fails, fix the cause; never flip an `ENFORCE_*` flag to quiet a failure.
- [ ] Commit the green gate run.

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that the eight gates named above are the ones this change
class can break, and that no new baseline file (`scripts/nolints.json`, the C14 axiom baselines,
`scripts/warning-budget.txt`) needs an entry — the new declarations appear on neither
`MainResults.lean` nor `Metalogic.lean`'s SORRY-FREE claim list, and the module is expected to
compile warning-free. Confirm by reading the actual gate output; if a baseline file does demand an
entry, record that as a finding rather than assuming the hypothesis held.

**Files to modify**:

- None expected. Any file this phase must change is a gate failure being fixed, and should be
  named in the phase record when it happens.

**Verification**:

- `lake build` exits 0 through the guard.
- `check-module-invariants.sh` exits 0.
- `check-copyright-headers.sh --strict FormalSystem` exits 0.
- All four axiom audits report `{propext, Classical.choice, Quot.sound}` with no warnings.

---

### Phase 4: Correct the task record and hand off the (C5) statement [NOT STARTED]

**Goal**: The task's recorded scope matches what it actually touched, and the downstream
stability-condition work has a precise, citable statement rather than a description to re-derive.

**Tasks**:

- [ ] Correct `file_scope` for this task in `specs/state.json`. The recorded value names the
      deterministic modules (`WitnessFamily/Agreement.lean`, `WitnessFamily/Basic.lean`,
      `WitnessFamily/README.md`, `WitnessFamily.lean`) — three of which this task must not touch
      at all. Replace it with the files actually in scope:
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean`,
      `FormalSystem/Metalogic/Decidability/WitnessFamily.lean`, `FormalSystem.lean`. Update the
      `file_scope` key only; do not replace the `artifacts` array (it is append-only with
      same-type supersession) and do not edit `TODO.md` directly.
- [ ] Write `specs/684_agreement_lemma_over_all_walks/handoff-c5-statement.md`: a short note
      naming (a) the exact (C5) `StabFaithful` statement,
      `stab φ ∈ L i u ↔ ∀ j, share u i j → φ ∈ L j u`; (b) `stabQuant_iff_share_class` as its
      soundness argument, with the module path; (c) `Sharing/Decide.lean`'s window congruence at
      line 237 and the `AtomCoherentAt` reduction as the decidability route, with `Formula.atom p`
      replaced by `stab φ`; (d) `stabQuant_iff_self_of_share_eq` as the deterministic
      cross-check; (e) the deferred `Sharing/README.md` announcement, which this task did not make
      because that file is the sibling's territory. Task numbers are permitted in this file — it
      is under `specs/**`.
- [ ] Record in the same note that the completeness-side failure mode does not transfer, and that
      the shared content with the completeness line is the histories characterization
      (`total_eq_thread`) only — so neither line should wait on the other.
- [ ] Commit the records.

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

- [ ] `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean` elaborates
      sorry-free.
- [ ] `lake build` exits 0 through `lake-build-guard.sh` with an explicit `--timeout`.
- [ ] `bash scripts/check-module-invariants.sh` exits 0, with C1/C3/C4/C9/C24/C26/C33 passing.
- [ ] `bash scripts/check-copyright-headers.sh --strict FormalSystem` exits 0.
- [ ] `lean_verify` on `stabQuant_iff_share_class`, `stabQuant_iff_self_of_share_eq` and
      `frame_recurrenceFree` each reports `{propext, Classical.choice, Quot.sound}`, no warnings.
- [ ] `lean_verify` on `truth_iff_mem` is unchanged from the research round's audit.
- [ ] No file under `WitnessFamily/` other than the aggregator, no file under `Sharing/` other than
      the new `Stability.lean`, and no file in a sibling's declared scope other than
      `FormalSystem.lean` was modified.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Stability.lean` (new module,
  ~200-280 lines, four declarations)
- One added import line in `FormalSystem/Metalogic/Decidability/WitnessFamily.lean`
- One added sorted import line in `FormalSystem.lean` (generated by `mk_all`)
- `specs/684_agreement_lemma_over_all_walks/handoff-c5-statement.md`
- Corrected `file_scope` for this task in `specs/state.json`
- An execution summary under `specs/684_agreement_lemma_over_all_walks/summaries/` at completion

## Rollback/Contingency

The change is strictly additive: one new module plus two one-line import additions. Reverting is
`git revert` of this task's commits, which restores both aggregators to their prior byte-for-byte
`mk_all`-consistent state and removes the module — no other declaration in the tree references it,
so nothing else breaks.

If a genuine rollback of uncommitted work becomes necessary mid-phase, take a snapshot first with
`bash .claude/scripts/git-snapshot.sh 684` (adding `--allow-out-of-scope` only for a deliberate
whole-tree rollback) before any destructive git command. Do **not** emit a bare, default-mode
`git-snapshot.sh` call as a routine checkpoint; a defensive checkpoint before risky work uses
`--no-revert`.

If Phase 2's territory check finds a foreign change to `FormalSystem.lean`, the contingency is to
stop and report — not to merge or overwrite. The module from Phase 1 is already committed and
green on its own; the wiring can be completed in a later dispatch once the sibling's edit has
landed.
