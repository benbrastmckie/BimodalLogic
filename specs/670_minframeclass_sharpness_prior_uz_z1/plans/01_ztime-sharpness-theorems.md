# Implementation Plan: Task #670

- **Task**: 670 - Machine-check the MINIMALITY half of `Axiom.minFrameClass` for the two `.ZTime` axioms, `prior_UZ` and `z1`
- **Status**: [COMPLETED]
- **Effort**: 5.75 hours (3.75 hours for the mandated deliverable; 2 hours of clearly-marked optional strengthening)
- **Dependencies**: None
- **Research Inputs**: specs/670_minframeclass_sharpness_prior_uz_z1/reports/01_ztime-sharpness-countermodels.md
- **Artifacts**: plans/01_ztime-sharpness-theorems.md (this file), summaries/01_ztime-sharpness-theorems-summary.md
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

`Axiom.minFrameClass` (`FormalSystem/ProofSystem/Axioms.lean`) currently has a machine-checked
*upper* bound only (`axiom_validIn_min`, `Metalogic/Soundness.lean`); its *minimality* for the two
`.ZTime` axioms is carried solely by literature citations in docstrings. This plan lands one new
module, `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`, carrying nine named theorems
that prove `prior_UZ` and `z1` are not valid at `FrameClass.Base` — and, via the order fact that
`.Base` is the unique class strictly below `.ZTime`, that they are not valid at *any* class below
`.ZTime`. It then updates the `Axiom.minFrameClass` docstring and the two constructor docstrings to
cite those theorems alongside the existing literature, wires the module into the two aggregators,
updates the `Independence/` result ledgers, and runs one full rebuild plus the module-invariants
gate. Definition of done: the module is sorry-free, declares no `axiom`, measures
`[propext, Classical.choice, Quot.sound]`, the full gate set is green, and no docstring in
`FormalSystem/` still presents `.ZTime` minimality as merely cited.

### Research Integration

The research report supplies a **complete, already-elaborated module**: all ten declarations
(nine theorems plus a `noncomputable abbrev`, and two anonymous shape-pin `example`s) were run
end to end through `lean_run_code` against the built tree with zero errors, zero `sorry`, zero new
axiom declarations, and a measured axiom footprint identical to the set `MainResults.lean` pins.
The plan therefore treats the *mathematics* as settled and spends its phases on transcription
fidelity, import-graph wiring, documentation, and the repository gate set. Four research findings
shape the phase order directly:

- **The route is not the one the dispatch anticipated.** Neither `Z1Countermodel.lean` nor
  `MinusLanguageSoundness.lean` nor `Semantics/LexCarrier.lean` is needed. Both countermodels live
  on `translationFrame D` (`Semantics/Frames/Standard.lean`) with the
  `translationHist`/`translationModel`/`translation_realizes` atom-realisation layer from
  `Semantics/Correspondence/DurationFrames.lean`. The `tr_ne_untl` trap the dispatch warned about
  is sidestepped entirely, because nothing is transferred out of the L-minus language.
- **Non-discreteness, not non-Archimedean-ness, refutes both axioms.** Each fails over any dense
  carrier, so one generic lemma per axiom at an arbitrary `(D : TemporalOrder) [DenselyOrdered ↑D]`
  yields the `.Base` result at `D = ℚ`. Per the dispatch's explicit instruction the claim is not
  silently upgraded: the theorems say `.Base` (and "any densely ordered `D`" in the generic lemmas).
- **The `CoNotPriorU` obstruction does not bite.** It arises only because that theorem must
  *validate* `CO` while refuting `prior_U_gap`; a bare non-validity claim validates nothing. The
  verified proofs are in fact frame-level (`¬ F.ValidOn φ`), stronger than the model-fixed form the
  dispatch allowed for.
- **The `Axioms.lean` docstring edit forces a full-tree rebuild.** Lean invalidates on whole-file
  hash and `Axioms.lean` is transitively imported by essentially the whole tree. The phase order
  below therefore does all cheap, scoped verification *before* touching `Axioms.lean`, and budgets
  exactly one full rebuild afterwards.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the dispatch context; no ROADMAP.md consultation performed.

## Goals & Non-Goals

**Goals** (the identifier set this plan commits to proving, matching `## Lean Challenge Statements`
below):

- `eq_base_of_lt_ztime`
- `not_validOn_prior_UZ_dense`, `not_validOn_z1_dense`
- `not_validIn_base_prior_UZ`, `not_validIn_base_z1`
- `prior_UZ_minFrameClass_sharp`, `z1_minFrameClass_sharp`
- `not_derivable_base_prior_UZ`, `not_derivable_base_z1`
- Amend the Axiom.minFrameClass docstring, and the prior_UZ and z1 constructor docstrings, to cite
  the two sharpness theorems rather than literature alone.
- Keep the tree sorry-free and axiom-declaration-free, with the measured axiom set unchanged.

**Non-Goals**:

- The `.Dense` and `.RTime` tags (density, dense_indicator, prior_U_gap, sep). Per the dispatch's
  SCOPE clause these are recorded as observations for a follow-up task; see the section of that
  name below.
- Any transfer through `MinusLanguage`, `Z1Countermodel.lean`, `MinusLanguageSoundness.lean`, or
  the `ℚ ×ₗ ℤ` carrier.
- Any claim that the axioms are refutable specifically over ℚ, or over a non-Archimedean order,
  beyond what the written statements say.
- The compression/adequacy direction (a separate task), and any change whatever to the
  ModelChecker repository.
- A schematic `∀ φ` non-validity form: it is false (`prior_UZ ⊥` has an unsatisfiable antecedent and
  is Base-valid). The atomic instance is forced, not a convenience.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Formula transcription drift: the result is vacuous if the written formula is not the axiom's | H | M | The two anonymous shape-pin `example`s (`Axiom (…) := Axiom.prior_UZ φ` / `Axiom.z1 φ`) make the match a compiler obligation. Non-negotiable; they are part of Phase 1's deliverable, not decoration. |
| The `Axioms.lean` docstring edit triggers a full-tree rebuild | M | H (certain) | Order matters: Phases 1-2 verify the new module and its wiring with cheap scoped work *before* `Axioms.lean` is touched; Phase 3 batches every prose edit; Phase 4 spends the single budgeted full rebuild. Never a separate "documentation" rebuild afterwards. |
| A foreground `lake build` livelocks at the Bash timeout and banks no `.olean` progress | H | H if ignored | Every build runs detached via `Bash(run_in_background: true)` through `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build …`, waited on per `context/patterns/bounded-build-waiter.md` (hard timeout, `kill -0` on the captured PID, never `pgrep -f` on the waiter's own pattern). See `context/project/lean4/operations/long-builds.md`. |
| Gate C17 (dead-declaration scan): every new base identifier needs an occurrence outside its declaring line | M | M | Satisfied by the `Axioms.lean` docstring citations (Phase 3) plus the `Independence/README.md` ledger entry. Confirmed by the Phase 4 gate run, not assumed. |
| `Independence/README.md` carries a hand-written result count and a `<!-- BEGIN GENERATED: inventory … -->` block | M | H | Edit the prose ledger by hand (count and numbered entry and Key Results bullet); regenerate the block with `bash scripts/readme-inventory.sh`. Never hand-edit inside the generated markers. |
| `FormalSystem.lean` is generated by `lake exe mk_all --lib FormalSystem`, and `Metalogic/Independence.lean` lists its children explicitly | M | H | Both are Phase 2 tasks. Gate C4 checks import resolution, C24 the `FormalSystem.Init` path, C8 the aggregator convention. |
| Gate C14/C21/C27 coupling if the theorems are pinned in `MainResults.lean` | M | M | Deliberately isolated in optional Phase 6 with its own gate run, because it requires bumping the `FormalSystem/MainResults.lean` count in `scripts/debug-artifact-allowlist.txt` *and* adding matching lines to `C14_BASELINE` in `scripts/check-module-invariants.sh`. Skipping Phase 6 is fully compliant with the dispatch. |
| Gate C15 (paper anchors): an invented anchor fails | L | M | Cite `def:BX-z` only, per `docs/reference/paper-definitions-of-record.md`. Do not invent a sharpness anchor. |
| Name collision: `Metalogic/Conservativity/DenseObstructionTransfer.lean` already declares `qD` in `FormalSystem.Metalogic` | L | L | Use `ztimeSharpOrder` in `FormalSystem.Metalogic.Independence`. Do not reintroduce `qD`. |
| `push_neg` is deprecated in this toolchain | L | M | Use `push Not`, as the verified source does. |
| Task-number leakage into `FormalSystem/` | M | M | `.claude/rules/no-task-references-in-deliverables.md`: no docstring or comment added by this plan may cite a task number. Cite `def:BX-z`, theorem names, file paths, and the literature instead. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel. This plan is fully sequential: Phase 2 needs
the module Phase 1 writes, Phase 3's docstrings cite the theorems Phase 1 names, and Phase 4 spends
the one full rebuild every prior edit accumulates into.

### Phase 1: Author `ZTimeSharpness.lean` [COMPLETED]

**Goal**: The new module exists at `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean`,
elaborates with zero errors and zero `sorry`, declares no `axiom`, and measures
`[propext, Classical.choice, Quot.sound]` on the four headline results — verified without spending
a full-tree rebuild.

**Tasks**:
- [x] Create the file with the repository's four-line copyright block (copy the header shape from a
      sibling such as `Independence/LexIntWitness.lean` verbatim).
- [x] Write the `/-! … -/` module docstring. It must state: the result (the `.ZTime` tag of
      `Axiom.minFrameClass` is proved minimal, not merely upper-bounded, for `prior_UZ` and `z1`);
      that the countermodel is the translation frame over a densely ordered duration group, so what
      is refuted is *discreteness* and not the Archimedean property; that
      `Metalogic/Conservativity/DenseObstructionTransfer.lean` is the antecedent of the `z1`
      argument in the neighbouring L-minus language, so the two read as one story; that the
      `CoNotPriorU.lean` frame-versus-model obstruction does not apply, because a bare non-validity
      claim validates nothing; and, in prose, the consumer relationship to the ModelChecker
      adequacy argument about a permanent frame-class gap. Cite `def:BX-z` as the only paper anchor.
      Cite no task numbers (`.claude/rules/no-task-references-in-deliverables.md`).
- [x] Transcribe the imports and `open`/`namespace` preamble from the research report's Appendix A:
      `import FormalSystem.Semantics.Correspondence.DurationFrames`,
      `import FormalSystem.Metalogic.Soundness`; namespace `FormalSystem.Metalogic.Independence`.
- [x] Transcribe the two anonymous shape-pin `example`s, each with its own docstring explaining that
      it type-checks only if the transcribed formula is exactly the axiom constructor's.
- [x] Transcribe the nine theorems and the `noncomputable abbrev ztimeSharpOrder : TemporalOrder :=
      TemporalOrder.of ℚ`, giving every named declaration a docstring. Keep `push Not` (not
      `push_neg`) and keep the name `ztimeSharpOrder` (not `qD`).
- [x] Verify by `lean_run_code` on the exact file body: zero errors, zero `sorry`, plus
      `#print axioms` on `prior_UZ_minFrameClass_sharp`, `z1_minFrameClass_sharp`,
      `not_derivable_base_prior_UZ`, `not_derivable_base_z1`. Record the four measured lines for the
      Phase 4 audit note. Do not call `lean_diagnostic_messages` or `lean_file_outline` (blocked).
- [x] Commit (`task 670 phase 1: …` per `.claude/rules/git-workflow.md`), staging only this new file.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the phase asserts a declaration inventory of exactly 11 declarations — two
anonymous `example`s, nine theorems, one `noncomputable abbrev` — and that the research report's
Appendix A source elaborates unchanged against the current tree. Confirm at implementation time by
running Appendix A verbatim through `lean_run_code` *before* adding docstrings, and by counting the
declarations in the finished file; if the Appendix no longer elaborates (a tree change since the
research round), repair the proof rather than weakening the statement, and record the divergence.

**Files to modify**:
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` - new file; the whole deliverable.

**Verification**:
- `lean_run_code` on the module body reports no errors and no `sorry`.
- `grep -c 'sorry' ` on the file is 0, and `grep -c '^axiom '` is 0.
- The four `#print axioms` lines each read `[propext, Classical.choice, Quot.sound]`.
- Both shape-pin `example`s type-check, so both formulas are provably the axiom constructors'.

---

### Phase 2: Wire the module into both aggregators [COMPLETED]

**Goal**: The new module is reachable from the library root and from the `Independence` aggregator,
verified by a *scoped* build that is still cheap because `Axioms.lean` has not yet been touched.

**Tasks**:
- [x] Add `import FormalSystem.Metalogic.Independence.ZTimeSharpness` to
      `FormalSystem/Metalogic/Independence.lean` (that file lists its children explicitly; append
      in the file's existing thematic order rather than re-sorting it).
- [x] Regenerate the root aggregator: `lake exe mk_all --lib FormalSystem`. Confirm the resulting
      diff to `FormalSystem.lean` is exactly the one added import line — if `mk_all` rewrites more
      than that, stop and report rather than committing an unrelated regeneration.
- [x] Run a detached, guarded scoped build of the aggregator:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Metalogic.Independence`
      under `Bash(run_in_background: true)`; wait per `context/patterns/bounded-build-waiter.md`.
      This is the cheap window — only the new module needs elaborating.
- [x] Commit, staging the new module's two aggregator changes only.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: the phase asserts exactly two wiring sites
(`FormalSystem/Metalogic/Independence.lean` and the generated `FormalSystem.lean`). Confirm by
running `mk_all` and reading its diff, and by `grep -rn 'ZTimeSharpness' FormalSystem/` — every hit
outside the module itself must be one of those two aggregators.

**Files to modify**:
- `FormalSystem/Metalogic/Independence.lean` - one added import line.
- `FormalSystem.lean` - regenerated by `mk_all`; one added import line.

**Verification**:
- The scoped build of `FormalSystem.Metalogic.Independence` completes with no errors.
- `grep -n 'ZTimeSharpness' FormalSystem.lean FormalSystem/Metalogic/Independence.lean` shows one
  hit in each.

---

### Phase 3: Docstring and ledger updates (all prose, batched) [COMPLETED]

**Goal**: Every place in the tree that presents `.ZTime` minimality as a literature citation now
cites the sharpness theorems, and the `Independence/` result ledgers count the new result. All prose
edits land together so that the rebuild they force is spent exactly once, in Phase 4.

**Tasks**:
- [x] `FormalSystem/ProofSystem/Axioms.lean`, the `Axiom.minFrameClass` docstring: on the
      `ZTime (2 axioms: prior_UZ, z1)` line, state that this row is now *proved* minimal, not merely
      upper-bounded, and name `FormalSystem.Metalogic.Independence.prior_UZ_minFrameClass_sharp` and
      `…z1_minFrameClass_sharp`. Keep the existing upper-bound reference to `axiom_validIn_min`
      legible, and say explicitly that the other three rows remain upper-bound-only.
- [x] `Axioms.lean`, the `prior_UZ` constructor docstring: add the citation of
      `not_validIn_base_prior_UZ` alongside the existing Reynolds 1992 §10 / Venema (W) references.
      Keep the literature; add to it rather than replacing it.
- [x] `Axioms.lean`, the `z1` constructor docstring: same, citing `not_validIn_base_z1` alongside
      Doets 1987 Claim 10 / Reynolds 1994 §10.
- [x] `FormalSystem/Metalogic/Independence/README.md`: bump the hand-written result count by one,
      add the numbered result entry (the `.ZTime` row of `Axiom.minFrameClass` is proved minimal,
      naming the two `*_minFrameClass_sharp` theorems and the two `not_derivable_base_*`
      corollaries), and add the matching `## Key Results` bullet. Do not edit inside
      `<!-- BEGIN GENERATED: inventory … -->` / `<!-- END GENERATED -->`.
- [x] Regenerate the inventory block: `bash scripts/readme-inventory.sh`. Re-run it once more and
      confirm the second run produces no further diff (idempotence). *(deviation: altered — `scripts/readme-inventory.sh` is a pointer script that only prints the real invocation; the regeneration was run as `bash scripts/check-module-invariants.sh --emit-inventory`, which is what that script names. It rewrote four READMEs, not one: the new module's line count propagates into `FormalSystem/Metalogic/README.md`, `FormalSystem/README.md` and the root `README.md` generated blocks, so those three are committed with this phase as well. Second run reported "no generated inventory block needed a rewrite" — idempotent.)*
- [x] `FormalSystem/Metalogic/Independence.lean`, module docstring: add the new result to its own
      numbered list and bump its own count, preserving that file's existing numbering convention.
      Note that this file's count and the README's count already disagree with each other; do NOT
      attempt to reconcile the pre-existing discrepancy here (recorded as an observation below).
- [x] Re-read every edited hunk and confirm each lies wholly inside a docstring, comment, or
      markdown region — no edit may cross out of a comment boundary (the `prose` tier's blind spot).
- [x] Commit, staging exactly the five files above. *(deviation: altered — eight files, not five: the three extra are the propagated generated inventory blocks named in the deviation above.)*

**Timing**: 0.75 hours

**Depends on**: 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: the phase asserts five edit sites — three docstring regions inside
`Axioms.lean` (`Axiom.minFrameClass`, the `prior_UZ` constructor, the `z1` constructor), plus
`Independence/README.md` and `Independence.lean` — and that both ledger files carry hand-written
result counts. Confirm at implementation time by `grep -n 'Reynolds\|Doets\|minFrameClass'
FormalSystem/ProofSystem/Axioms.lean` and by reading each ledger's opening sentence; if a fourth
`Axioms.lean` site asserts `.ZTime` minimality from literature alone, amend it too and record the
divergence.

**Files to modify**:
- `FormalSystem/ProofSystem/Axioms.lean` - three docstrings; no code change.
- `FormalSystem/Metalogic/Independence/README.md` - prose ledger plus regenerated inventory block.
- `FormalSystem/Metalogic/Independence.lean` - module docstring only (its import line landed in Phase 2).

**Verification**:
- `git diff` for `Axioms.lean` touches only docstring lines (every changed hunk inside `/-- … -/`
  or `--` comment text).
- A second `bash scripts/readme-inventory.sh` run leaves the README unchanged.
- `grep -n 'minFrameClass_sharp' FormalSystem/ProofSystem/Axioms.lean` returns the two citations,
  which is also what discharges gate C17 for those names.
- No added line in any `FormalSystem/` file contains a task-number reference.

---

### Phase 4: One full rebuild and the full gate set [COMPLETED]

**Goal**: The whole tree rebuilds green after the `Axioms.lean` invalidation, the module-invariants
gate passes, and the axiom-footprint audit is unchanged — spending exactly one full rebuild.

**Tasks**:
- [x] Detached, guarded full build:
      `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` under
      `Bash(run_in_background: true)`, waited on per `context/patterns/bounded-build-waiter.md`
      (hard timeout, `kill -0` on the captured holder PID from the guard's own result record; never
      `pgrep -f` on the waiter's own pattern, and never a self-matching process scan). Use the
      passive progress checks in `context/project/lean4/operations/long-builds.md` if the wait
      approaches its bound.
- [x] Confirm the build log carries no `error`, no `declaration uses 'sorry'` warning, and that the
      existing `MainResults.lean` `#print axioms` audit lines still report
      `[propext, Classical.choice, Quot.sound]`.
- [x] Run `bash scripts/check-module-invariants.sh` in full. Read every finding; fix the tree, not
      the gate, unless the finding is specifically an allowlist/baseline coupling this plan
      introduced (Phase 6's territory). *(deviation: altered — the first run failed one check group, `INV` (2 stale generated inventory blocks), which is NOT among the eight gates this phase's Scope Hypothesis enumerated; the gate in fact reports 43 check groups. Cause: the Phase 3 `Independence.lean` docstring edit grew that file 123 → 133 lines after the inventory regeneration had run. Fixed the tree, not the gate, by re-running `--emit-inventory`; the re-run reports ALL CHECKS PASSED with GATE_EXIT=0.)*
- [x] Run the copyright-header check and any repo-level lints the gate script does not subsume.
- [x] Record in the implementation summary: the four measured `#print axioms` lines, the gate
      outcome, and the confirmation that the tree still has zero structural `sorry` and zero `axiom`
      declarations outside `Boneyard/`.
- [x] Carry the "Observations Recorded for Follow-Up" section of this plan into the implementation
      summary verbatim in substance, so the `.Dense`/`.RTime` sharpness gap is visible to whoever
      files the follow-up task.
- [x] Commit any gate-driven fixes; then commit the implementation summary.

**Timing**: 1.5 hours (mostly machine time)

**Depends on**: 3

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: the phase asserts that the relevant gates are C4 (import resolution), C8
(aggregator convention), C15 (paper anchors), C17 (dead declarations), C19 (module docstring), C23
(naming), C24 (`FormalSystem.Init` path) and C26 (no non-trailing underscore in `def`/`abbrev`
names), and that exactly one full rebuild is required. Confirm by running
`scripts/check-module-invariants.sh` in full and reading the actual check list it reports rather
than trusting this enumeration; if a gate not listed here fires, fix it and record it.

**Files to modify**:
- None expected. Any file touched here is a gate-driven repair, and must be reported as one.
  *(actual: three gate-driven repairs — `FormalSystem/Metalogic/README.md` and root `README.md` (stale generated inventory blocks, the `INV` failure above) and `FormalSystem/Metalogic/Independence/README.md` (its two `Last verified` stamps, which `scripts/readme-lint.sh` flagged STALE DATE as a direct consequence of this work's own edit). Committed as `task 670 phase 4: refresh generated inventory blocks and Independence README date`.)*
- `specs/670_minframeclass_sharpness_prior_uz_z1/summaries/01_*-summary.md` - the implementation summary.

**Verification**:
- Full `lake build` exits 0 with no `sorry` warning attributable to this work.
- `scripts/check-module-invariants.sh` exits 0.
- The measured axiom set for the four headline results is `[propext, Classical.choice, Quot.sound]`.

---

### Phase 5: Optional — strengthen from "minimal" to "`.ZTime` alone" [COMPLETED WITH EXCLUSIONS]

**Goal**: Upgrade the result from *minimality* to the strictly sharper statement that `ValidIn fc φ`
holds at `.ZTime` and at no other class, for both axioms.

This phase is **beyond the dispatch's stated deliverable and is optional**. Execute it only if
Phase 4 is green and budget remains. If it is not executed, close it as
`[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record naming the corollaries not
added, the reason (outside the dispatch's stated deliverable), and the evidence (this paragraph plus
the green Phase 4 gate). Skipping it is fully compliant.

**Tasks**:
- [ ] Add `¬ ValidIn FrameClass.Dense (…)` corollaries for both axioms. These reuse the *same*
      `ztimeSharpOrder` frame; `Sat .Dense` discharges as `⟨inferInstance, inferInstance⟩`. The
      research verified this working for `prior_UZ`.
- [ ] Add `¬ ValidIn FrameClass.RTime (…)` corollaries for both axioms at `D = realOrder`
      (`Metalogic/DedekindNonCompactness.lean`), discharging `TaskFrame.IsComplete`
      (`Semantics/FrameProperty.lean`) via `Real.exists_isLUB`.
- [ ] Optionally assemble a single `ValidIn fc φ ↔ fc = .ZTime` statement per axiom from the four
      negative results plus `axiom_validIn_min`.
- [ ] Extend the module docstring and the `Independence/README.md` entry to describe the stronger
      claim; re-run `scripts/readme-inventory.sh`.
- [ ] Add `¬ ValidIn FrameClass.Dense (…)` corollaries for both axioms. *(deviation: skipped — phase closed with exclusions)*
- [ ] Add `¬ ValidIn FrameClass.RTime (…)` corollaries for both axioms. *(deviation: skipped — phase closed with exclusions)*
- [ ] Assemble the `ValidIn fc φ ↔ fc = .ZTime` statements. *(deviation: skipped — phase closed with exclusions)*
- [ ] Extend the module docstring and README entry to the stronger claim. *(deviation: skipped — phase closed with exclusions)*
- [ ] Detached, guarded full build plus `scripts/check-module-invariants.sh`; commit. *(deviation: skipped — phase closed with exclusions)*

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `¬ ValidIn FrameClass.Dense` corollaries for `prior_UZ` and `z1` | Beyond the dispatch's stated deliverable, which asks only for non-Base-validity; the plan itself declares this phase optional and skipping it "fully compliant" | This phase's own opening paragraph; Phase 4 green (full build exit 0, gate run recorded in the summary) |
| `¬ ValidIn FrameClass.RTime` corollaries at `D = realOrder` | Same; additionally requires discharging `TaskFrame.IsComplete` via `Real.exists_isLUB`, unbudgeted work outside the deliverable | This phase's own opening paragraph; the dispatch's DELIVERABLE clause names only non-Base-validity |
| The `ValidIn fc φ ↔ fc = .ZTime` biconditional per axiom | Depends on the two excluded corollary families above; cannot be assembled without them | The phase's own task list marks it "Optionally" |
| Extension of the module docstring and `Independence/README.md` to the stronger claim | Would describe results that were not added; writing it would make the docstring false | The module docstring as landed states the `.Base` claim only, and explicitly declines to upgrade it |

The `.ZTime` minimality result the dispatch mandated is complete and machine-checked without this
phase. Recorded as a follow-up opportunity in the implementation summary.

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` - added corollaries, extended docstring.
- `FormalSystem/Metalogic/Independence/README.md` - ledger text.

**Verification**:
- New corollaries elaborate sorry-free with the unchanged axiom footprint.
- Full build and gate set green.

---

### Phase 6: Optional — pin the new results in `MainResults.lean` [COMPLETED WITH EXCLUSIONS]

**Goal**: The four headline results appear on the build-time axiom-audit page, so a future
regression in their axiom footprint is build-visible rather than merely discoverable.

This phase is **optional**; the dispatch requires only that the new work not regress the existing
audit, which Phase 4 confirms. It is isolated here because it couples three files whose baselines
must move together, and a partial edit fails gate C21. If it is not executed, close it as
`[COMPLETED WITH EXCLUSIONS]` with a `#### Reasoned Exclusions` record.

**Tasks**:
- [ ] Add `#print axioms` lines to `FormalSystem/MainResults.lean` for
      `FormalSystem.Metalogic.Independence.prior_UZ_minFrameClass_sharp`,
      `…z1_minFrameClass_sharp`, `…not_derivable_base_prior_UZ`, `…not_derivable_base_z1`
      (plus any Phase 5 headline, if Phase 5 landed), with the surrounding prose that page's
      existing sections use.
- [ ] Bump the `FormalSystem/MainResults.lean` debug-artifact count in
      `scripts/debug-artifact-allowlist.txt` to the value the gate actually measures. Do not compute
      the new number by arithmetic — run the gate, read the reported count, and set that.
- [ ] Add the matching expected lines to `C14_BASELINE` inside `scripts/check-module-invariants.sh`,
      since C21 requires every name on the main-results page be pinned by C2 or C14.
- [ ] Detached, guarded full build; then `scripts/check-module-invariants.sh` in full, confirming
      C14, C21 and C27 all pass together. If any one of the three fails, revert all three edits
      rather than leaving a partial pin.
- [ ] Commit the three files as one change. *(deviation: skipped — phase closed with exclusions)*

#### Reasoned Exclusions

| Item | Reason | Evidence |
|------|--------|----------|
| `#print axioms` lines in `FormalSystem/MainResults.lean` for the four headline results | Optional by the plan's own declaration; the dispatch requires only that the existing audit not regress, which Phase 4 confirmed | This phase's own opening paragraph; the Phase 4 build log carries 27 `depends on axioms` lines, every measured set within `{[propext], [propext, Classical.choice, Quot.sound]}` |
| Bumping the `FormalSystem/MainResults.lean` count in `scripts/debug-artifact-allowlist.txt` | Meaningless without the audit lines above; a partial pin fails gate C21 | The phase's own instruction to "revert all three edits rather than leaving a partial pin" |
| Adding the matching expected lines to `C14_BASELINE` in `scripts/check-module-invariants.sh` | Same coupling; all three files must move together or not at all | Same |
| Depends on Phase 5 | Phase 5 was itself closed with exclusions, so its headline results do not exist to pin | The Phase 5 `#### Reasoned Exclusions` record above |

The four results' axiom footprint is measured and recorded in the implementation summary via
`lean_verify`, so a regression remains discoverable; it is simply not build-visible on the
`MainResults.lean` page. Recorded as a follow-up opportunity in the summary.

**Timing**: 1 hour

**Depends on**: 5

**Verification Tier**: full

**Commit Mode**: atomic-batch

**Scope Hypothesis**: the phase asserts that `scripts/debug-artifact-allowlist.txt` currently
records a single count for `FormalSystem/MainResults.lean` (measured at plan time as
`FormalSystem/MainResults.lean 54`, against 27 existing `#print axioms` lines), and that
`C14_BASELINE` is the one baseline needing new lines. Confirm at implementation time by running the
gate before editing and reading the reported count and the failing-check names; the pre-edit
measurement is the authority, not the number written here.

**Files to modify**:
- `FormalSystem/MainResults.lean` - added `#print axioms` lines and surrounding prose.
- `scripts/debug-artifact-allowlist.txt` - the `MainResults.lean` count.
- `scripts/check-module-invariants.sh` - `C14_BASELINE` additions.

**Verification**:
- Full build green; `scripts/check-module-invariants.sh` exits 0 with C14, C21 and C27 all passing.
- The build log shows the four new audit lines reporting `[propext, Classical.choice, Quot.sound]`.

---

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.Correspondence.DurationFrames
import FormalSystem.Metalogic.Soundness

open FormalSystem FormalSystem.Syntax FormalSystem.Semantics FormalSystem.ProofSystem

namespace FormalSystem.Metalogic.Independence

theorem eq_base_of_lt_ztime {fc : FrameClass} (h : fc < FrameClass.ZTime) :
    fc = FrameClass.Base := sorry

theorem not_validOn_prior_UZ_dense (D : TemporalOrder) [DenselyOrdered (D : Type)] (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        ((Formula.atom p).someFuture.imp
          (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

theorem not_validOn_z1_dense (D : TemporalOrder) [DenselyOrdered (D : Type)] (p : Atom) :
    ¬ (translationFrame D).toTaskFrame.ValidOn
        (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
          ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

theorem not_validIn_base_prior_UZ (p : Atom) :
    ¬ ValidIn FrameClass.Base
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

theorem not_validIn_base_z1 (p : Atom) :
    ¬ ValidIn FrameClass.Base
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

theorem prior_UZ_minFrameClass_sharp (p : Atom) {fc : FrameClass} (hfc : fc < FrameClass.ZTime) :
    ¬ ValidIn fc ((Formula.atom p).someFuture.imp
      (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

theorem z1_minFrameClass_sharp (p : Atom) {fc : FrameClass} (hfc : fc < FrameClass.ZTime) :
    ¬ ValidIn fc (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
      ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

theorem not_derivable_base_prior_UZ (p : Atom) :
    ¬ Derivable FrameClass.Base []
      ((Formula.atom p).someFuture.imp
        (Formula.untl (Formula.atom p).neg (Formula.atom p))) := sorry

theorem not_derivable_base_z1 (p : Atom) :
    ¬ Derivable FrameClass.Base []
      (((Formula.atom p).allFuture.imp (Formula.atom p)).allFuture.imp
        ((Formula.atom p).allFuture.someFuture.imp (Formula.atom p).allFuture)) := sorry

end FormalSystem.Metalogic.Independence
```

The `noncomputable abbrev ztimeSharpOrder : TemporalOrder := TemporalOrder.of ℚ` and the two
anonymous shape-pin `example`s are part of the Phase 1 deliverable but are deliberately absent
here: this section pins *named theorem statements*, and neither an `abbrev` nor an anonymous
`example` is one.

## Testing & Validation

- [x] `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` elaborates with zero errors and
      zero `sorry`; `grep -c sorry` on it is 0.
- [x] The module declares no `axiom`; the tree still has zero `axiom` declarations outside
      `Boneyard/`.
- [x] Both shape-pin `example`s type-check, certifying that the refuted formulas are exactly
      `Axiom.prior_UZ φ`'s and `Axiom.z1 φ`'s.
- [x] `#print axioms` on `prior_UZ_minFrameClass_sharp`, `z1_minFrameClass_sharp`,
      `not_derivable_base_prior_UZ` and `not_derivable_base_z1` each reports
      `[propext, Classical.choice, Quot.sound]`.
- [x] Full `lake build` (detached, guarded) exits 0 after the `Axioms.lean` invalidation.
- [x] `bash scripts/check-module-invariants.sh` exits 0.
- [x] `bash scripts/readme-inventory.sh` is idempotent on `Independence/README.md`.
- [x] `grep -rn 'minFrameClass_sharp' FormalSystem/ProofSystem/Axioms.lean` returns the two new
      citations (also discharging C17 for those names).
- [x] No file added or edited under `FormalSystem/` contains a task-number reference.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Independence/ZTimeSharpness.lean` - new module; nine named theorems, one
  `abbrev`, two shape-pin `example`s.
- `FormalSystem/Metalogic/Independence.lean` - one added import; module-docstring ledger entry.
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`.
- `FormalSystem/ProofSystem/Axioms.lean` - three docstrings now citing the sharpness theorems.
- `FormalSystem/Metalogic/Independence/README.md` - prose ledger entry plus regenerated inventory.
- `specs/670_minframeclass_sharpness_prior_uz_z1/summaries/01_*-summary.md` - implementation summary
  carrying the axiom-footprint measurement, the gate outcome, and the follow-up observations.
- Optional (Phase 6 only): `FormalSystem/MainResults.lean`,
  `scripts/debug-artifact-allowlist.txt`, `scripts/check-module-invariants.sh`.

## Observations Recorded for Follow-Up

Recorded here rather than acted on, per the dispatch's SCOPE clause. The `.Dense` and `.RTime` rows
of `Axiom.minFrameClass` are unproved-sharp on exactly the same grounds as the `.ZTime` row this
plan closes, and the research found all four *cheaper* than the row being closed:

- `density` (`GGφ → Gφ`, `.Dense`): `validOn_dn_iff_denselyOrdered`
  (`Semantics/Correspondence/DurationFrames.lean`) is an *iff*; at `D = intOrder` (not densely
  ordered) its forward direction yields the `.Base` refutation nearly free.
- `dense_indicator` (`¬U(⊤,⊥)`, `.Dense`): `Semantics/Correspondence/Indicator.lean` proves
  `F ⊨ ¬X⊤ ↔ DenselyOrdered F.Duration` — the same one-step route.
- `prior_U_gap` and `sep` (`.RTime`): minimality here needs refutations at both `.Base` and
  `.Dense`, since both are strictly below `.RTime`. For `prior_U_gap`,
  `Independence/CoNotPriorU.lean`'s `priorUGapFormula_false` already refutes the formula in a model
  over the clock frame at ℚ — which is dense — so a single `¬ ValidOn` extraction plausibly
  discharges both classes at once. `sep` appears to have no existing witness.

Two further observations, neither in scope here:

- `FormalSystem/Metalogic/Independence.lean`'s module docstring and
  `Independence/README.md` already disagree about how many results the directory carries, and the
  README additionally uses the superseded class names `.Dedekind`/`.Discrete` where the code now
  says `.RTime`/`.ZTime`. This plan adds one entry to each ledger in that ledger's own convention
  and does not reconcile the pre-existing discrepancy.
- `Axioms.lean`'s `prior_UZ` docstring renders the axiom as `F(φ) → U(φ, ¬φ)` while the constructor
  is `φ.someFuture.imp (Formula.untl φ.neg φ)` — the `untl` arguments read in the opposite order.
  The shape-pin `example` protects this plan's theorems from the discrepancy; correcting the
  docstring prose is a separate, tiny fix.

Two context-extension recommendations from the research are also worth a follow-up: a note on the
`translationFrame`/`translationHist`/`translationModel`/`translation_realizes` countermodel kit
(including the two frames that silently *validate* the targets — `clockFrame`, periodic; the static
frame, time-invariant), and a paragraph recording that frame-level refutation is obstructed only
when a statement must simultaneously *validate* something on a valuation-rich flow.

## Rollback/Contingency

Every phase commits independently, so the ordinary contingency is `git revert` of the offending
commit — no working-tree discard is involved and no snapshot is required.

- **Phase 1-2 failure** (the module does not elaborate, or wiring breaks import resolution): the
  new file and the two aggregator lines are self-contained. Revert the phase commit; `Axioms.lean`
  has not been touched yet, so no full rebuild is owed.
- **Phase 3-4 failure** (a gate fires after the `Axioms.lean` invalidation): `git revert` the
  Phase 3 commit, which restores the docstrings and puts the tree back to the Phase 2 state; budget
  one more full rebuild to confirm green.
- **Phase 6 failure** (C14/C21/C27 disagree): revert all three coupled files together. A partial pin
  is worse than no pin.
- If an intentional rollback would discard *uncommitted* work, snapshot first per
  `context/contracts/recovery.md`'s rollback rung (including its out-of-scope override flag for the
  deliberate whole-tree case) before running any destructive git command.
- Worst case, the whole task reverts to a documentation-only state with no loss elsewhere: nothing
  in the tree depends on the new module, so removing it cannot break an existing result.
