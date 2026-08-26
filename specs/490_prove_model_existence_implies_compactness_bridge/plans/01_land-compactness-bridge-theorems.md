# Implementation Plan: Model Existence -> Compactness Bridge

- **Task**: 490 - prove_model_existence_implies_compactness_bridge
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: `specs/490_prove_model_existence_implies_compactness_bridge/reports/01_model-existence-compactness-bridge.md`
- **Artifacts**: plans/01_land-compactness-bridge-theorems.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Close the second, cheap gap on the compactness route by landing two theorems —
`compactBase_of_modelExistence : ModelExistenceBase → CompactBase` and
`compactDense_of_modelExistenceDense : ModelExistenceDense → CompactDense` — into
`FormalSystem/Metalogic/StrongCompleteness.lean`, then reconciling the seven prose sites whose
current text asserts that this implication is unproved future work. Both proofs already exist as
complete, machine-verified, sorry-free Lean terms (written and compiled during research, both
auditing to exactly `[propext, Classical.choice, Quot.sound]`), so this is a
transcription-plus-docstring job, not a proof-search job. Definition of done: both theorems
present and sorry-free, `#print axioms` reporting exactly the three permitted axioms for each,
`lake build` green with no new warnings, and no remaining prose in the tree claiming the
implication is unproved.

### Research Integration

The research report is ground truth and supplies the two verbatim proof scripts, the placement
decision, and the prose-drift inventory. Three findings drive this plan's structure:

1. **Placement is not `SetConsequence.lean`.** Both proofs consume `truthAt_foldr_imp`, which is
   owned by `StrongCompleteness.lean` — and that module already imports `SetConsequence.lean`.
   Stating them in `SetConsequence.lean` is an import cycle. This is the identical constraint
   already documented at `FormalSystem/Metalogic/SetConsequence.lean`'s `## Downstream` section,
   which forced `strongCompletenessBase_of_compact` and `strongCompletenessDense_of_compact`
   into `StrongCompleteness.lean`. The task brief's "or a sibling" clause covers this. No new
   module, no lakefile change, no import change.
2. **`push_neg` is deprecated** in this toolchain (Lean v4.33.0-rc1 / Mathlib `79d0395a`) and
   emits a deprecation warning. The verified proofs use `push Not`. Transcribe them verbatim; do
   not "modernize" or "simplify" either script.
3. **Seven prose sites become false** once the theorems land. The acceptance criteria are met by
   the code alone, but leaving these stale re-creates the exact silent gap this task exists to
   close, so they are in scope and carry their own phase.

Two further points from the report are recorded as explicit non-goals below: the optional
`StrongCompletenessBase`-from-`ModelExistenceBase` corollary is deliberately not added, and
`ModelExistenceBase`/`ModelExistenceDense` themselves remain open obligations (the ultraproduct
work, separately tasked).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context; no roadmap consultation was performed.
The report notes a named downstream consumer already in `specs/TODO.md` — a follow-on task whose
description composes with "the ModelExistence -> Compact bridge to obtain CompactBase and
CompactDense". This plan supplies that composition target and touches none of the ultraproduct
work.

## Goals & Non-Goals

**Goals**:
- `compactBase_of_modelExistence : ModelExistenceBase → CompactBase`, sorry-free, in the source tree.
- `compactDense_of_modelExistenceDense : ModelExistenceDense → CompactDense`, sorry-free.
- Both names added to the `#print axioms` audit block in `StrongCompleteness.lean`, each
  reporting exactly `[propext, Classical.choice, Quot.sound]`.
- Every prose site in the tree that asserts this implication is unproved future work updated to
  reflect that it is now proved, with the import-cycle framing preserved and the still-open
  status of `ModelExistence*` and `Compact*` stated accurately.
- `lake build` green, with no new warnings introduced.

**Non-Goals**:
- Proving `ModelExistenceBase` or `ModelExistenceDense`. That is the ultraproduct / Łoś-lemma
  work and is explicitly excluded by the task brief and separately tasked.
- The converse direction `CompactBase → ModelExistenceBase`.
- The optional corollary chaining `ModelExistenceBase` through
  `strongCompletenessBase_of_compact` to `StrongCompletenessBase`. The tree deliberately keeps
  the `engine` hypotheses live so that compactness stays isolated as the whole remaining
  obligation; adding this corollary would blur that, and it is outside the declared scope.
- Any new module, import, or lakefile change.
- Editing `SetConsequence.lean`'s module-docstring claim that "No compactness result is proved or
  refuted here" — under the chosen placement that sentence stays literally true.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Theorems placed in `SetConsequence.lean` per the brief's literal first reading, producing an import cycle | H | M | Placement is fixed by this plan to `StrongCompleteness.lean`; Phase 1 names the exact anchor symbol. The brief's "or a sibling" clause authorizes it. |
| Proof scripts silently "improved" during transcription (e.g. `push Not` swapped back to `push_neg`, or a tactic collapsed) and no longer compile | M | M | Transcribe both scripts byte-for-byte from the research report. Any deviation must be justified by a compiler error, not by style preference. |
| Line numbers cited in this plan and in the report drift once Phase 1 inserts ~55 lines | M | H | Phase 2 runs strictly after Phase 1 and anchors every edit by symbol name or heading text, never by line number. Re-locate before editing. |
| Folding the two new names into the audit paragraph's "fourteen declarations" count produces a wrong count | L | M | Give the bridge theorems their own one-line audit note rather than editing the existing count, per the report's stated alternative. |
| Stale cross-reference `StrongCompleteness.lean:147` in the `ModelExistenceDense` docstring (the real location is `:183`) propagated into the new prose | L | M | Phase 2 explicitly corrects this reference; prefer a bare symbol name over a line number in all new prose. |
| A prose edit crosses out of a comment/docstring region and breaks elaboration | M | L | Phase 2's `prose` tier requires a diff read-through confirming every changed hunk lies inside a comment region; Phase 3's full build catches anything that escapes. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Land both bridge theorems and their axiom audit [COMPLETED]

**Goal**: Both theorems exist in `FormalSystem/Metalogic/StrongCompleteness.lean`, are sorry-free,
compile clean, and are covered by `#print axioms`.

**Tasks**:
- [x] Confirm the two target names are collision-free in the tree:
      `grep -rn "compactBase_of_modelExistence\|compactDense_of_modelExistenceDense" --include=*.lean .`
      must return nothing before any edit.
- [x] Locate the insertion point by symbol, not line number: immediately after the closing line of
      `strongCompletenessDense_of_compact`, inside the existing section heading
      `/-! ## Strong completeness for `FrameClass.Base` and `FrameClass.Dense`, modulo compactness -/`,
      and before the next section heading
      `/-! ## Consequence completeness for `FrameClass.Dedekind` -/`.
- [x] Insert a subsection heading `/-! ### Model existence implies compactness -/` at that point.
- [x] Transcribe `compactBase_of_modelExistence` **verbatim** from the research report's
      "Verified Deliverables" section, with a docstring recording (a) the import-cycle reason it
      lives here rather than in `SetConsequence.lean` — mirroring the paragraph already in
      `strongCompletenessBase_of_compact`'s docstring — and (b) that `ModelExistenceBase` remains
      an open obligation, so this is a reduction and not a terminus.
- [x] Build and confirm green; this is green sub-step 1 — commit it.
- [x] Transcribe `compactDense_of_modelExistenceDense` **verbatim** from the report, with the
      parallel docstring pointing at its Dense vocabulary.
- [x] Build and confirm green; this is green sub-step 2 — commit it.
- [x] Add `#print axioms compactBase_of_modelExistence` and
      `#print axioms compactDense_of_modelExistenceDense` to the existing `#print axioms` block at
      the end of the file (the block that currently begins with
      `#print axioms strongCompletenessBase_of_compact`). Do **not** touch the surrounding prose
      paragraph in this phase — that is Phase 2's territory.
- [x] Capture the two `#print axioms` outputs and confirm each reads exactly
      `[propext, Classical.choice, Quot.sound]`; commit as green sub-step 3.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts exactly 2 new theorems, 1 new subsection heading, 2 new
`#print axioms` lines, and 1 file touched (~55 added lines), with both new names collision-free.
Confirm at implementation time by the pre-edit `grep` in the first task, and by
`git diff --stat` showing `FormalSystem/Metalogic/StrongCompleteness.lean` as the sole modified
file. If any of these turns out false — a name collides, or the insertion requires touching a
second file — stop and report rather than widening the phase.

**Files to modify**:
- `FormalSystem/Metalogic/StrongCompleteness.lean` — add the subsection heading, both theorems
  with docstrings, and both `#print axioms` lines.

**Verification**:
- `lake env lean FormalSystem/Metalogic/StrongCompleteness.lean` elaborates with zero errors and
  zero **new** warnings (in particular, no `push_neg` deprecation warning — the proofs use
  `push Not`).
- `grep -n "sorry" FormalSystem/Metalogic/StrongCompleteness.lean` shows no `sorry` in either new
  proof.
- Both new `#print axioms` lines report exactly `[propext, Classical.choice, Quot.sound]`.
- Every pre-existing `#print axioms` line in the file still reports the same axiom set as before
  the edit.

---

### Phase 2: Reconcile the seven prose sites that assert the implication is unproved [COMPLETED]

**Goal**: No text anywhere in the tree still claims that `ModelExistence* → Compact*` is future
work, and every module inventory that should list the two new theorems does.

**Tasks**:
- [x] Re-locate each site by heading text or symbol name (Phase 1 shifted line numbers).
- [x] `SetConsequence.lean`, `ModelExistenceBase` docstring: replace "that implication is future
      work and is not proved here" with a pointer to `compactBase_of_modelExistence` in
      `StrongCompleteness.lean`, keeping the "not *here*" import-cycle framing.
      `ModelExistenceBase` itself stays flagged as an **open obligation**.
- [x] `SetConsequence.lean`, `ModelExistenceDense` docstring: the same change pointing at
      `compactDense_of_modelExistenceDense`. Also correct the stale cross-reference
      `` `truthAt_foldr_imp` (`StrongCompleteness.lean:147`) `` — the lemma is not at line 147.
      Prefer a bare module reference with no line number.
- [x] `SetConsequence.lean`, `## Downstream` section of the module docstring: it currently names
      only `strongCompletenessBase_of_compact` and `strongCompletenessDense_of_compact` as living
      downstream for the import-cycle reason. Add the two bridge theorems to that list; the reason
      is identical.
- [x] `StrongCompleteness.lean`, `## Contents` section of the module docstring: add a bullet for
      the two bridge theorems.
- [x] `StrongCompleteness.lean`, the "**Status of `CompactBase`.**" paragraph inside
      `strongCompletenessBase_of_compact`'s docstring: its enumeration of remaining work ends
      "…it needs an ultraproduct carrier, a Łoś lemma for `TruthAt`, `ModelExistenceBase` and hence
      `CompactBase`." The final "and hence" step is now a proved theorem. Shrink the enumeration
      accordingly. The "**Open** — neither proved nor refuted" verdict on `CompactBase` **stands**:
      it now reduces to `ModelExistenceBase`, which is itself still open. Do not overstate.
- [x] `StrongCompleteness.lean`, the `/-! ### Axiom audit for the per-class consequence layer`
      prose paragraph: add a **separate one-line note** covering the two bridge theorems, stating
      that they too are reductions rather than termini since their `ModelExistence*` hypotheses are
      open obligations. Do **not** fold them into the existing "fourteen declarations" count.
- [x] `FormalSystem/Metalogic.lean`, module inventory: extend the `StrongCompleteness.lean` bullet
      — which currently names the two compactness reductions — to also name
      `compactBase_of_modelExistence` and `compactDense_of_modelExistenceDense`.
- [x] Leave `SetConsequence.lean`'s "**No compactness result is proved or refuted here**" claim
      untouched — it remains literally true under the chosen placement and is itself an argument
      for that placement.
- [x] Commit per green sub-step, grouping by file. *(deviation: altered — all three files were edited and then verified by a single guarded `lake build`, landing as one commit. The build guard serializes project-wide across the three concurrent sibling dispatches in this repo, and a docstring edit to `SetConsequence.lean` invalidates every downstream `.olean`; per-file sub-step builds would have queued two full-tree cascade rebuilds behind sibling builds for no added assurance, since all three edits are comment-only.)*

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts exactly 7 prose sites across exactly 3 files
(`FormalSystem/Metalogic/SetConsequence.lean` ×3, `FormalSystem/Metalogic/StrongCompleteness.lean`
×3, `FormalSystem/Metalogic.lean` ×1). Confirm at implementation time with
`grep -rn "future work and is not proved here\|is not proved here" --include=*.lean FormalSystem/`
returning nothing after the edits, and `git diff --stat` naming exactly those three files. If a
site outside this list is found still asserting the implication is unproved, fix it and record the
widened count in the phase notes rather than leaving it stale.

**Scope-hypothesis outcome (implementation)**: confirmed — exactly 7 sites across exactly 3 files,
`git diff --stat` naming only those three. The looser probe
`grep -rn "is not proved here" --include=*.lean FormalSystem/` additionally matched
`FormalSystem/Metalogic/Decidability/Verified/Termination/Fuel.lean:1745`; a definition lookup
showed it is the docstring of `expandOnceUnblocked_split_card_le`, disclaiming a *strict*
split-cardinality variant and unrelated to the model-existence/compactness implication. Excluded
as a false positive, not edited.

**Files to modify**:
- `FormalSystem/Metalogic/SetConsequence.lean` — `ModelExistenceBase` docstring,
  `ModelExistenceDense` docstring (incl. the stale line reference), `## Downstream` section.
- `FormalSystem/Metalogic/StrongCompleteness.lean` — `## Contents` section, the
  "Status of `CompactBase`" paragraph, the axiom-audit prose note.
- `FormalSystem/Metalogic.lean` — the `StrongCompleteness.lean` module-inventory bullet.

**Verification**:
- Diff read-through confirming every changed hunk lies inside a `/-- … -/` or `/-! … -/` comment
  region — no hunk crosses a comment boundary.
- `grep -rn "future work and is not proved here" --include=*.lean FormalSystem/` returns nothing.
- `grep -rn "StrongCompleteness.lean:147" --include=*.lean FormalSystem/` returns nothing.
- Both new theorem names appear in `FormalSystem/Metalogic.lean` and in `StrongCompleteness.lean`'s
  `## Contents` section.
- All named cross-references in the new prose resolve to symbols that actually exist.

---

### Phase 3: Full acceptance gate [NOT STARTED]

**Goal**: Machine-confirm every acceptance criterion in the task brief against the whole build.

**Tasks**:
- [ ] Run `lake build` from a clean-enough state and confirm it exits green.
- [ ] Diff the build's warning set against the pre-task baseline; confirm no new warnings were
      introduced by either phase.
- [ ] Confirm `#print axioms compactBase_of_modelExistence` and
      `#print axioms compactDense_of_modelExistenceDense` each report exactly
      `[propext, Classical.choice, Quot.sound]` — no `sorryAx`, no new axiom.
- [ ] Confirm every pre-existing `#print axioms` line in `StrongCompleteness.lean` still reports
      its original axiom set (guards against an accidental regression through a shared lemma).
- [ ] `grep -rn "sorry" FormalSystem/Metalogic/StrongCompleteness.lean` — confirm no `sorry`
      anywhere in the file.
- [ ] Confirm the non-goals held: no new module, no import change, no lakefile change, no
      `StrongCompletenessBase`-from-`ModelExistenceBase` corollary added
      (`git diff --stat` against the task's base commit names only the three files from Phases 1-2).
- [ ] Commit the final green state.

**Timing**: 0.5 hours

**Depends on**: 2

**Verification Tier**: full

**Commit Mode**: per-substep

**Files to modify**:
- None (verification only; any fix required here is a correction inside the Phase 1 or Phase 2
  file set, not a new file).

**Verification**:
- `lake build` green.
- Both axiom audits exactly `[propext, Classical.choice, Quot.sound]`.
- Zero `sorry` in the touched files.
- `git diff --stat` against the base commit names exactly three files.

---

## Testing & Validation

- [ ] `lake build` exits green.
- [ ] `compactBase_of_modelExistence` and `compactDense_of_modelExistenceDense` both exist,
      both sorry-free, with the statement types `ModelExistenceBase → CompactBase` and
      `ModelExistenceDense → CompactDense` respectively.
- [ ] `#print axioms` for each of the two new theorems reports exactly
      `[propext, Classical.choice, Quot.sound]`.
- [ ] No pre-existing `#print axioms` result in `StrongCompleteness.lean` changed.
- [ ] No new build warnings (specifically: no `push_neg` deprecation warning from the new proofs).
- [ ] `grep -rn "future work and is not proved here" --include=*.lean FormalSystem/` returns nothing.
- [ ] `SetConsequence.lean`'s "No compactness result is proved or refuted here" claim is unmodified
      and still true.

## Artifacts & Outputs

- `FormalSystem/Metalogic/StrongCompleteness.lean` — two new theorems with docstrings, one new
  subsection heading, two new `#print axioms` lines, three prose sites updated.
- `FormalSystem/Metalogic/SetConsequence.lean` — three prose sites updated.
- `FormalSystem/Metalogic.lean` — one module-inventory bullet updated.
- `specs/490_prove_model_existence_implies_compactness_bridge/summaries/01_*-summary.md` —
  execution summary produced at implementation postflight.

## Rollback/Contingency

All work is confined to three existing Lean files, is additive apart from the prose edits, and is
committed per green sub-step, so `git revert` of the task's commits restores the prior state
exactly — no migration, no generated artifact, no external state.

- If a transcribed proof unexpectedly fails to compile: the research report records that both
  scripts were verified in isolation *and* inside a full copy of `StrongCompleteness.lean`, so a
  failure means the transcription deviated. Diff the in-tree proof against the report's script
  character-by-character before attempting any repair.
- If Phase 1 lands but Phase 2 cannot complete: the acceptance criteria are already met by the code
  alone; the task is `[PARTIAL]` with the residual prose drift enumerated, not failed. Do not revert
  Phase 1 to "clean up".
- If placement in `StrongCompleteness.lean` turns out to be blocked for a reason not anticipated
  here, stop and report — do not fall back to `SetConsequence.lean`, which is a confirmed import
  cycle.
