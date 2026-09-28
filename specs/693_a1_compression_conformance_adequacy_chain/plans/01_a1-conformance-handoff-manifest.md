# Implementation Plan: Task #693

- **Task**: 693 - A1 compression conformance adequacy chain
- **Status**: [IMPLEMENTING]
- **Effort**: 2.5 hours
- **Dependencies**: None blocking. Concurrent sibling task 685 owns
  `FormalSystem/Metalogic/Decidability/WitnessFamily/{Decide,Closure}.lean`,
  `WitnessFamily/README.md`, `WitnessFamily.lean` and `docs/theorem-index.md`; every phase below
  is scoped away from all five paths.
- **Research Inputs**: `specs/693_a1_compression_conformance_adequacy_chain/reports/01_a1-compression-conformance.md`
- **Artifacts**: plans/01_a1-conformance-handoff-manifest.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The research phase settled the verdict: obligation A1 of the upstream bimodal adequacy chain is
**partially discharged** — `exists_witnessFamily_of_not_validZTime` proves A1's full content,
including the `f(|C|)` bound, at `WitnessFamily [] [φ]` only, while the chain consumes the general
`Γ ⊨ Δ` form. The conditional deliverable (update the cross-repository record) therefore does not
fire as an edit to the companion repository, which this task must not touch. What remains is
bounded, non-mathematical work in this repository plus a hand-off: record the upstream row text
where the upstream task system can consume it, correct two in-repository documentation sites whose
"needs a context-conjunction deduction theorem" claim overstates the obstruction, and put the
twenty-three declarations this conformance argument turns on under the C35 citation manifest so
future line drift fails a gate instead of rotting silently.

Definition of done: the hand-off note exists with row text citing declarations by fully qualified
name only; the three over-stated passages read what Finding 2c establishes; `scripts/lean-citation-seeds.txt`
carries the validated block, `scripts/lean-citation-manifest.json` is regenerated (never
hand-edited), C35 is green, the full gate passes, and the work is committed in this task's own
hunks. No Lean statement changes.

### Research Integration

- **Verdict (Findings 1–4)** is the content of the hand-off note: A1 partially discharged, the
  residue named **A1-Γ** as its own obligation, A3 newly live-and-open (not vacuous, not
  discharged), verified-absence a theorem at restricted scope but not a practical replacement for
  trusting Z3 UNSAT. Phase 1 transcribes the report's Recommendation 1 row text verbatim rather
  than re-deriving it.
- **Finding 2c** is the content of Phase 2: the deduction theorem is needed only for the
  *reduction* route (`Γ ⊨ σ` via `⊨ ⋀Γ → σ`); the direct route's residue is three enumerated
  items, because `Refutes`, `refutes_of_certifies`, `joint_countermodel`,
  `exists_labelledLasso_of_history_realized`, `compressionBound` and all four `Decidable`
  instances are already stated at arbitrary `Γ Del`.
- **Finding 5a/5c** is the content of Phase 3: zero relevant declarations are currently seeded, and
  a 23-name block was dry-run resolved (exit 0, 86/86) against a scratchpad seed copy, with
  `LabelledLasso` and `LabelledLasso.lab` corrected to sit directly in
  `FormalSystem.Metalogic.Decidability` rather than nested under `WitnessFamily`.
- **Findings 4 and 5b** supply the caveats the hand-off note must carry with the claim: measured
  candidate counts (`|C| = 2` gives `B = 20`, ≈`2^360` candidates), no `lean_exe` enumerator, and
  the already-drifted upstream line citations (`joint_countermodel` now resolves at
  `Agreement.lean:248`, not `:232`).

### Prior Plan Reference

No prior plan. This is round 1.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no `specs/ROADMAP.md` was consulted.

## Goals & Non-Goals

**Goals**:

- Produce `specs/693_a1_compression_conformance_adequacy_chain/handoff-a1-adequacy-rows.md`: the
  A1 / A1-Γ / A3 row text plus the accompanying-edit list for the upstream repository's own task
  system, citing declarations by fully qualified name with no line numbers.
- Correct the over-stated "needs a context-conjunction deduction theorem" claim at every site in
  `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/` that carries it, so the
  documented obstruction matches Finding 2c.
- Append the validated 23-name seed block to `scripts/lean-citation-seeds.txt`, regenerate
  `scripts/lean-citation-manifest.json` with `scripts/export-lean-citations.py`, and keep C35 green.
- Leave the full gate (`scripts/check-module-invariants.sh`) passing and commit in this task's own
  hunks.

**Non-Goals**:

- **Any edit to the ModelChecker repository.** It is a separate repository with its own task
  system; the row text is handed off, not applied. This holds even though the current upstream A1
  row is now factually wrong in both directions.
- **Any Lean statement change** (settled by the recorded decision). Specifically excluded:
  research Recommendation 4 (a named `def`/`theorem` in `Compression/Extract.lean` for the bound's
  factorization through `|C|`), Recommendation 5's strengthening of
  `exists_witnessFamily_of_not_validZTime`'s lasso-count conjunct to
  `≤ (boxedPart (closureOf ([] ++ [φ]))).card + 1`, and Recommendation 5's padding lemma
  (Finding 3e). All three are real work; none is this task's.
- **Closing A1-Γ.** The general `Γ ⊨ Δ` re-parameterization (Finding 2c's three residue items) is
  the substantive follow-on and is out of scope here.
- **Seeding `WitnessFamily/Decide.lean`'s `scan_forward`/`scan_backward`.** That file is in sibling
  task 685's declared file scope; coordinate rather than racing it.
- **Adding `.claude/context/project/lean4/patterns/cross-repo-obligation-conformance.md`** (the
  report's Context Extension Recommendation). That is a source-store change under
  `.claude-extensions.json`'s `source_dir`, i.e. `/meta` work, not a change to this repository's
  own deliverables.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Docstring edits shift `Compression/Assembly.lean` line numbers *after* the manifest is regenerated, turning C35 red | H | H if mis-ordered | Hard ordering: Phase 2 (docstring edits) completes before Phase 3 (regeneration). Four of the new seed names resolve into `Compression/Assembly.lean` (`validZTime_iff_noCertifiedCandidate`, `Compression.decidableValidZTime`, `semanticConsequenceIn_nil_iff`, `decidableSemanticConsequenceNil`), so regenerating first guarantees a stale manifest. |
| Sibling task 685's in-flight edits shift a line in a file holding a seeded declaration, making the regenerated manifest stale at commit time | M | L | No manifest entry currently resolves into any of 685's five paths (verified: current 63 entries span `WitnessFamily/Std.lean`, `Independence/ZTimeSharpness.lean`, `ProofSystem/Axioms.lean` and eight `Semantics/` files — none of `Decide.lean`, `Closure.lean`, `WitnessFamily.lean`). Re-run C35 immediately before the commit in Phase 4. If a foreign commit or foreign uncommitted modification appears, STOP and report per `context/contracts/territory.md` rather than regenerating over it. |
| The corrected docstrings over-claim in the other direction — Finding 2c is a read of signatures, not a completed proof | M | M | The corrected prose must say the residue is *bounded and enumerated*, naming the three items, and must not assert that the general form compiles or that the re-parameterization is proved. The consequence-form carrier normalization was never written. |
| A prose gate trips on the new text: C9 (no task numbers under `FormalSystem/`), C20 (no `file.lean:NNN` citations in publication scope), C31 (References bibkeys), C32 (relative markdown links in `.lean` comments) | M | M | Cite by fully qualified name only in the Lean and README edits; introduce no new bibkeys or relative links; keep task numbers out of everything outside `specs/**`. Phase 4 runs the full gate, not the `--no-build` subset. |
| The manifest is hand-edited to make C35 pass | H | L | `scripts/lean-citation-manifest.json` is generated. The only sanctioned repair is `python3 scripts/export-lean-citations.py`; the manifest's own `note` field and C35's failure message both say so. |
| The hand-off note goes stale before the upstream repository applies it | L | M | Row text cites fully qualified names with one file path for orientation and zero line numbers; Phase 3 puts those names under C35 so future drift fails a gate here. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |

Phases within the same wave can execute in parallel. Phase 1 writes only under `specs/`; Phase 2
writes only under `FormalSystem/.../Compression/`, so the two waves-1 phases share no file.

### Phase 1: Write the upstream adequacy-row hand-off note [COMPLETED]

**Goal**: Put the A1 / A1-Γ / A3 row text and its accompanying-edit list where the upstream
repository's task system can consume it, without editing that repository.

**Tasks**:
- [x] Create `specs/693_a1_compression_conformance_adequacy_chain/handoff-a1-adequacy-rows.md`,
      following the shape of `specs/684_agreement_lemma_over_all_walks/handoff-c5-statement.md`
      (title, **From** / **To** block, then sections).
- [x] Transcribe the three replacement rows from the report's Recommendation 1 verbatim: the
      revised **A1** row (partially discharged, empty-premise single-conclusion instance), the new
      **A1-Γ** row (open, and the form (ADEQ) consumes), and the revised **A3** row (no longer
      vacuous — live and open).
- [x] Record the four accompanying upstream edits the same pass should make: `ADEQUACY.md`
      section 7.1's "A1 is recorded as open" paragraph and its `exists_annot_of_truth` rejection
      subsection; section 7.1's condition (i)/(ii) status; `TRUST_PIPELINE.md`'s A-component table
      A1 and A3 rows, including that its A3 row states the wrong (magnitude) form and must become
      the representability form (Finding 3f); and `TRUST_PIPELINE.md`'s "In the Lean development"
      verified-absence row, paired with the measured candidate counts and the absent `lean_exe`.
- [x] Record the citation-convention hand-off (Recommendation 2): the fourteen `WitnessFamily/`
      and `Compression/` citations should move to `name` + manifest once Phase 3 lands, and
      `joint_countermodel` has already drifted from the cited anchor.
- [x] State explicitly at the top that the ModelChecker repository was not and must not be edited
      from here, and that the note is copy for that repository's own task system.
- [x] Carry the two honesty caveats with the claims they qualify: verified absence is a theorem at
      restricted scope but not a practical replacement for trusting Z3 UNSAT (different
      quantifiers, no executable), and the A1-Γ residue is "bounded, not open-ended" with no effort
      estimate promised.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Commit Mode**: per-substep

**Files to modify**:
- `specs/693_a1_compression_conformance_adequacy_chain/handoff-a1-adequacy-rows.md` - new file;
  the cross-repository hand-off copy.

**Verification**:
- The file exists and is non-empty.
- `grep -nE '\.(lean|md|py):[0-9]+' specs/693_a1_compression_conformance_adequacy_chain/handoff-a1-adequacy-rows.md`
  returns no hit inside the proposed row text (a `file.lean:NNN` anchor is exactly the failure mode
  this note exists to stop; the one permitted mention of a stale anchor is the Recommendation-2
  drift record, which must be labelled as such).
- Every declaration named in the row text appears as a fully qualified name.
- Read-through confirms the note nowhere instructs anyone to edit the ModelChecker repository from
  this repository.

---

### Phase 2: Correct the over-stated obstruction passages in `Compression/` [COMPLETED]

**Goal**: Make the documented obstruction to the general finite-premise case match Finding 2c —
the deduction theorem is needed for the reduction route only, and the direct route's residue is
three enumerated items — without changing any Lean statement.

**Tasks**:
- [x] Re-read each target passage immediately before editing (sibling-concurrency discipline):
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`'s module-header
      "Scope: no premises, and no stability modal" section, the same file's
      `decidableSemanticConsequenceNil` docstring, and
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md`'s "What is out of
      scope" first bullet.
- [x] Rewrite each to say: the context-conjunction deduction theorem is what the *reduction* route
      (`Γ ⊨ σ` via `⊨ ⋀Γ → σ`) needs and the tree has none; the *direct* route needs no such
      theorem, because `SemanticConsequenceIn` unfolds to local consequence at a point and
      `Refutes`, `WitnessFamily.refutes_of_certifies`, `WitnessFamily.joint_countermodel`,
      `exists_labelledLasso_of_history_realized`, `compressionBound` and the four `Decidable`
      instances are already stated at arbitrary `Γ Del`.
- [x] Enumerate the three genuinely `Γ = []`-specific residue items in the rewritten prose: the
      entry point's carrier normalization (`validZTime_iff_validInt`'s consequence analogue, built
      on `truthAt_map` at a fixed aligned triple), `Target`'s premise clause, and
      `Enumerate.lean`'s φ-specialization of `closureSubsetsOf` / `rawLabelledLassos` /
      `IsLabelledLasso` / `boundedLassos` / `cands`.
- [x] State the residue as bounded-and-unproved, not as done: the consequence-form normalization
      was never written, so the prose must not claim the general form compiles.
- [x] Keep the unchanged neighbours intact: the stability-modal `⊡` scope sentence, the
      "bound is a grid" section, the [GKWZ] EXPSPACE note, and the axiom paragraph.
- [x] Cite by fully qualified or unambiguous declaration name only — no `file.lean:NNN` anchors, no
      task numbers (C9 forbids them under `FormalSystem/`), no new relative markdown links.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the claim to correct occupies **three passages across two files** —
`Compression/Assembly.lean` (module-header scope section, and the `decidableSemanticConsequenceNil`
docstring) and `Compression/README.md` ("What is out of scope"). The recorded decision speaks of
"the two over-stated docstrings", meaning the two files; the mechanical count is three passages.
Confirm at implementation time with
`grep -rn "deduction theorem" FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/`
before editing and again after: the after-count must be the same three lines (or their
replacements) with no site left carrying the over-stated form, and no fourth site discovered.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` - two comment
  passages; no declaration, signature or proof term touched.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md` - the "What is out of
  scope" general-finite-premise bullet.

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly` succeeds
  (a mangled `/-- ... -/` delimiter is the one way a docstring edit breaks elaboration).
- `git diff -- FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` shows
  every changed hunk inside a comment region; no `def`, `theorem`, `instance` or proof line
  changed.
- `grep -rn "deduction theorem" FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/`
  shows the Scope-Hypothesis count with every remaining occurrence scoped to the reduction route.
- `bash scripts/check-module-invariants.sh --no-build` passes (fast structural pass: C9, C20, C31,
  C32 all read this prose). *(deviation: altered — the gate does not exit 0 on this working tree,
  but introduces no failure attributable to this phase. Evidenced by running the same `--no-build`
  gate in two throwaway `git worktree` checkouts: at `29522e6b8` (before either task's
  implementation work) C23's two Uppercase_x hits and eleven outer-shadows-inner pairs already
  FAIL, so both are pre-existing; at `90949ec03` (sibling task 685's phase-1 commit, none of this
  phase's edits present) `INV` stale-inventory and `C33` not-the-generated-root already FAIL too,
  so both are the sibling's. C9, C20, C31 and C32 — the four checks that read this phase's prose —
  all PASS. Comment-only edits cannot create a shadowing pair, an Uppercase_x name, or a
  declaration census change.)*

---

### Phase 3: Add the validated seed block and regenerate the citation manifest [NOT STARTED]

**Goal**: Put the twenty-three declarations this conformance argument turns on under C35, so a
future rename or move fails a gate in this repository instead of rotting silently in a consuming
document.

**Tasks**:
- [ ] Re-read `scripts/lean-citation-seeds.txt` and confirm it still carries 63 resolvable names
      and no `Compression` entry.
- [ ] Append the report's validated block verbatim, preserving its two `##` group comments
      ("Certificate conditions (C1)-(C4)" and "Compression: the A1 candidate") so the generated
      manifest's `group` field stays meaningful, and keeping `LabelledLasso` and `LabelledLasso.lab`
      at `FormalSystem.Metalogic.Decidability.*` (they are **not** nested under `WitnessFamily`).
- [ ] Add no name that resolves into sibling-owned `WitnessFamily/Decide.lean` or `Closure.lean`.
- [ ] Run `python3 scripts/export-lean-citations.py` (regenerate; never hand-edit the manifest).
- [ ] Run `bash scripts/check-module-invariants.sh --no-build` and confirm C35 reports the manifest
      byte-current.
- [ ] Confirm the regenerated manifest's diff is confined to the new entries plus the
      `total`/`resolved`/`seed_list` bookkeeping, and that no pre-existing entry's line numbers
      moved for a reason this task cannot explain (an unexplained move is the sibling-edit signal;
      STOP and report rather than committing over it).

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the block adds **23 names**, taking the seed list from 63 to 86, and the
dry run resolved **86 of 86** with zero unresolved. Confirm at implementation time from
`python3 scripts/export-lean-citations.py`'s own output ("N seeded name(s) resolved") and from
`python3 -c` on the regenerated manifest's `total`/`resolved` fields; both must read 86. A shortfall
means a name moved since the research dry run — resolve it by name, never by deleting the seed.

**Files to modify**:
- `scripts/lean-citation-seeds.txt` - append the 23-name block with its two group comments.
- `scripts/lean-citation-manifest.json` - regenerated output, not hand-edited.

**Verification**:
- `python3 scripts/export-lean-citations.py` exits 0 and reports 86 resolved, 0 unresolved.
- `bash scripts/check-module-invariants.sh --no-build` passes with C35 green.
- `git diff --stat -- scripts/` shows exactly the two files.
- Spot-check that the new entries' `file` fields land where expected (`Compression/{Extract,Family,
  Enumerate,Assembly,Cycle}.lean`, `WitnessFamily/{Predicates,Agreement,Basic}.lean`) and that none
  lands in `WitnessFamily/{Decide,Closure}.lean`.

---

### Phase 4: Full gate, scoped commit, and task wrap-up [NOT STARTED]

**Goal**: Leave the repository green on the complete gate set and commit this task's own hunks
only, on a shared working tree with a concurrent sibling.

**Tasks**:
- [ ] Run `bash scripts/check-module-invariants.sh` (full pass, including the build-dependent
      C1/C2/C6/C16/C24/C25 and C14's `#print axioms` half).
- [ ] Re-run the C35 half immediately before staging, so a sibling commit landing mid-phase cannot
      leave a stale manifest committed.
- [ ] `git status --short` and `git diff --staged` review; stage by explicit file list only — never
      `git add -A`, `git add .`, a directory pathspec, or `git commit -am`.
- [ ] Commit the five paths of this task's work: `scripts/lean-citation-seeds.txt`,
      `scripts/lean-citation-manifest.json`,
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`,
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md`, and the
      `specs/693_a1_compression_conformance_adequacy_chain/` artifacts (report, plan, hand-off note,
      summary), with the `task 693: ...` message convention and the session ID in the body.
- [ ] If a foreign commit, a foreign uncommitted modification, or a build not started by this task
      is observed — after `git log` confirms the work is not this task's own — STOP and report
      rather than proceeding.
- [ ] Record in the execution summary the four follow-ons this plan deliberately excludes, so they
      can be spawned as their own tasks: A1-Γ (the general `Γ ⊨ Δ` re-parameterization), the named
      `f`-factorization declaration, the lasso-count strengthening plus padding lemma, and the
      `cross-repo-obligation-conformance.md` context file under the source store.

**Timing**: 0.5 hours

**Depends on**: 1, 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the commit is expected to touch **five paths** (two under `scripts/`, two
under `Compression/`, plus the `specs/693_.../` artifact set). Confirm with `git status --short`
before staging; any sixth modified path outside this list is either a sibling's in-flight edit
(STOP and report) or scope creep (exclude it from the commit).

**Files to modify**:
- None beyond the phases above; this phase gates and commits.

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0.
- `git diff --staged --stat` lists exactly this task's paths and nothing else.
- `git log -1 --stat` after the commit confirms the same, with the `task 693:` message and session
  ID present.

---

## Lean Challenge Statements

**None.** This plan introduces no Lean declaration and changes no Lean statement, so the identifier
set named under `- **Goals**:` is empty and this section's identifier set is empty to match. Phase
2's only `.lean` edit is confined to comment regions of
`FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean`. The section is
present because the plan's `task_type` is `lean4`, per plan-format.md's conditional-section rule.

## Testing & Validation

- [ ] `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly` succeeds
      after the docstring edits.
- [ ] `python3 scripts/export-lean-citations.py` exits 0, reporting 86 resolved and 0 unresolved.
- [ ] `bash scripts/check-module-invariants.sh --no-build` passes after Phase 2 and again after
      Phase 3 (C9, C20, C31, C32, C35 are the checks this work can move).
- [ ] `bash scripts/check-module-invariants.sh` (full) passes in Phase 4.
- [ ] `grep -rn "deduction theorem" FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/`
      leaves no site asserting the obstruction unconditionally.
- [ ] No `file.lean:NNN` anchor appears in the hand-off note's proposed row text.
- [ ] `git diff` over `FormalSystem/` shows comment-region hunks only — no declaration, signature
      or proof term changed anywhere.

## Artifacts & Outputs

- `specs/693_a1_compression_conformance_adequacy_chain/plans/01_a1-conformance-handoff-manifest.md`
  (this plan).
- `specs/693_a1_compression_conformance_adequacy_chain/handoff-a1-adequacy-rows.md` (Phase 1: the
  cross-repository hand-off copy — A1 / A1-Γ / A3 rows plus accompanying edits).
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` (Phase 2: two
  corrected comment passages).
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md` (Phase 2: corrected
  "What is out of scope" bullet).
- `scripts/lean-citation-seeds.txt` (Phase 3: +23 names, 63 -> 86).
- `scripts/lean-citation-manifest.json` (Phase 3: regenerated, C35 green).
- `specs/693_a1_compression_conformance_adequacy_chain/summaries/01_*-summary.md` (Phase 4: the
  execution summary, including the four excluded follow-ons).

## Rollback/Contingency

Every change here is documentation, a seed list, or generated output; nothing alters a proof term,
so rollback is cheap and needs no snapshot in the ordinary case.

- **Phase 3 contingency — C35 red after regeneration.** Do not hand-edit
  `scripts/lean-citation-manifest.json`; that is what C35 exists to catch. Re-run
  `python3 scripts/export-lean-citations.py`. If it still disagrees, the cause is a line shift in a
  file holding a seeded declaration — check `git log`/`git status` for a sibling edit first. If the
  shift is this task's own (Phase 2 edited `Compression/Assembly.lean`), simply regenerate after
  the edits settle. If it is a sibling's, STOP and report.
- **Phase 3 contingency — a seed name fails to resolve.** Re-anchor by name
  (`python3 scripts/reanchor-lean-citations.py --by-name --files <target>`) or drop that one name
  from the block with a recorded reason. Never delete a name to make a gate green without saying so.
- **Phase 2 contingency — a gate trips on the new prose.** Revert that single passage with
  `git checkout -- <path>` only if the working tree is otherwise clean for that path, then rewrite
  it; the passages are independent, so one bad rewrite does not force the others back.
- **Whole-task revert.** Because all four phases commit independently, `git revert <sha>` on the
  offending commit is the route. A working-tree rollback that would discard uncommitted changes
  requires the snapshot-then-rollback recipe first — see `context/contracts/recovery.md`'s rollback
  rung for the exact invocation, including its out-of-scope override flag; do not emit a bare
  default-mode `git-snapshot.sh` as a routine precaution.
