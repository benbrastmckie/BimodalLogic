# Implementation Plan: Time reflection for BL and the semantic form of thm:TR-valid

- **Task**: 796 - Prove lem:time-reflection for BL and the semantic form of thm:TR-valid by instantiating the generic anti-isomorphism transport at the reflected model
- **Status**: [NOT STARTED]
- **Effort**: 3.5 hours
- **Dependencies**: None blocking. Shares `FormalSystem/Semantics/TaskFrame.lean` with task 617 (idempotent, see Risks); shares `typst/generated/status.typ` with task 801 (see Risks)
- **Research Inputs**: `specs/796_time_reflection_bl_tr_valid_anti_iso/reports/01_time-reflection-bl-tr-valid.md`
- **Artifacts**: plans/01_time-reflection-bl-tr-valid.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Both paper anchors are already reachable from pieces the repository holds in two places that have
never been connected: the generic order-reversing transport `Truth.truthAt_of_truthAntiIso` in
`FormalSystem/Semantics/TruthTransport.lean`, and the frame-reversal machinery in
`FormalSystem/OpenLanguage/OpenReversal.lean`, which sits above it in the import graph and is
therefore invisible to it. This plan does the layering move that lets the former see the latter,
instantiates the transport at the reflected model to get `lem:time-reflection` for the base
language, and derives the validity-level consequence `thm:TR-valid` at every frame class. Done
means: eleven new declarations compiled sorry-free, the frame/model/transport reversal story
promoted out of `OpenLanguage/` into `Semantics/`, the decision on
`derivable_valid_and_reflect_time_validIn` recorded in its docstring, and the full repository
gate set green.

### Research Integration

The research report compiled every target declaration during research via `lean_run_code`
probes against the committed `.olean` tree — zero diagnostics, no `sorry`, no proof search — and
reproduced each verified source verbatim. Implementation is therefore transcription plus siting,
not discovery. Three findings this plan builds on directly:

- **The dispatch's `atom := rfl` is wrong.** The goal sits at `t` on one side and `- -t` on the
  other; it closes by `change` + `rw [neg_neg]`, the same two-step `openTruthAt_rev`'s own `atom`
  arm already uses.
- **`WorldHistory.rev`'s `abel` step must become `rwa [neg_sub_neg]`.** `abel` is unavailable at
  the TaskModel/PartialHistory import level (probe: `unknown tactic`); `neg_sub_neg` compiles at
  both that level and the `TruthTransport` level, so the substitution is made unconditionally and
  removes a latent siting constraint.
- **The frame-class closure is unconditional, so `validIn_reflectTime` needs no closure
  hypothesis.** All four `FrameClass` tags are closed under `rev` because `F.rev.Duration` is
  `F.Duration` by `rfl`. The generality lives one level down in `validOnFrames_reflectTime`,
  which takes the closure as an argument and is what reaches the two non-tag predicates
  `ValidComplete` and `ValidQTime`.

Two consequences the report did not identify, found while planning and carried here as named
steps:

- `FormalSystem/Semantics/TaskFrame.lean` is 2896 lines under `set_option
  linter.style.longFile 2900`. The ~70-line frame-level promotion does not fit; the ceiling must
  be raised to 3000 with its justification comment extended (Phase 1).
- Adding one module under `FormalSystem/` raises the tree's `.lean` file count 689 -> 690, which
  stales two generated, gated artifacts: the library root `FormalSystem.lean`
  (`check-module-invariants.sh` C33) and `typst/generated/status.typ`'s pinned
  `formalsystem-file-count` (`typst-sync-check.sh` Check 2). Both are regenerated, not
  hand-edited (Phases 2 and 6).

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the dispatch context; no ROADMAP consultation was performed.

## Goals & Non-Goals

**Goals**:
- `revHistEquiv`
- `revAntiIso`
- `truthAt_rev`
- `FrameClass.Sat.rev`
- `validOn_rev_iff`
- `validOnFrames_reflectTime`
- `validIn_reflectTime`
- `validIn_reflectTime_iff`
- `valid_reflectTime`
- `validComplete_reflectTime`
- `validQTime_reflectTime`

**Non-Goals**:
- **Collapsing `derivable_valid_and_reflect_time_validIn`.** Decision (3) is *leave as is, with a
  cross-reference docstring*; see "Decisions Carried From Research" below. A real collapse needs a
  replacement single-valued `derivable_validIn` recursion with a fresh termination proof plus a
  rewiring of `soundness_in`, `soundness_validIn` and
  `Metalogic/Independence/CoarsenedModels.lean`, and it would falsify three sibling layers'
  docstrings. Raise it as its own task.
- **Re-deriving `openTruthAt_rev` from `truthAt_rev`.** `OpenReversal.lean`'s docstring already
  records why `TruthAntiIso` cannot serve L^▷: the `▷`/`◁`/`⊡` clauses quantify over a *class* of
  histories, which an atom-level `TruthAntiIso` does not transport. The two inductions stay
  separate.
- **Merging with the presheaf Reflection clause.** Task 617 is the categorical packaging of the
  same involution and is independent: cross-reference only.
- **Editing `/home/benjamin/Philosophy/Papers/PossibleWorlds/JPL/possible_worlds.tex`.** The
  `% PORT:` markers at lines 3973 (`lem:time-reflection`) and 4003 (`thm:TR-valid`) are NOT
  cleared by this task. The user has recorded this decision twice — once for task 791 and again
  for task 793 (`specs/793_after_operator_negation_equivalence/.decisions.json`, cycle 3,
  2026-10-14T22:11:54Z: "keep all paper edits out of scope. Implement agents touch ONLY this
  repository"). Implementation MUST NOT write to any path outside
  `/home/benjamin/Projects/BimodalLogic`; the paper-side clearance is reported as
  deferred-to-user, not as incomplete work.
- Moving `TaskModel.rev` to `TaskModel.lean` or `WorldHistory.rev` to `PartialHistory.lean`. Both
  were probed and do work, but keeping the model/history/transport story in one new module avoids
  churning two more widely-imported files.
- Touching `docs/reference/paper-definitions-of-record.md` or
  `scripts/lean-citation-manifest.json` (task 801's territory; the manifest is generated by
  `scripts/export-lean-citations.py` and must never be hand-edited).

## Decisions Carried From Research

| Item | Decision | Where it is recorded in the tree |
|------|----------|----------------------------------|
| (3) `derivable_valid_and_reflect_time_validIn` | Leave as is; add a cross-reference docstring naming `Semantics.validIn_reflectTime` as the paper's own route, recording that `validIn_reflectTime (axiom_validIn_min ax)` alone proves `axiom_reflect_time_validIn_min`, and that the per-axiom dispatch is retained deliberately as an independent re-derivation | `FormalSystem/Metalogic/Soundness.lean`, Phase 5 |
| (4) promotion | Promote in three pieces: frame level to `Semantics/TaskFrame.lean`, model/history/transport to a new `Semantics/Reversal.lean`, validity level into `Semantics/Validity.lean` and `Semantics/FrameClassValidity.lean`. No cycle; splitting the validity level off is exactly what keeps `Reversal.lean` G-15-guard-clean and therefore reachable from task 617's Presheaf cluster | Phases 1-4 |
| `validIn_reflectTime`'s shape | No closure hypothesis (all four tags are closed); `validOnFrames_reflectTime` is the primitive carrying the closure argument, mirroring the existing `ValidOnFrames.mono` / `ValidIn.mono` pairing in the same file | Phase 4 |

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Territory collision with task 617 on `FormalSystem/Semantics/TaskFrame.lean` — its Phase A specifies the same promotion of the same declarations into the same file | M | M | Phase 1 begins by re-reading `TaskFrame.lean` and treating the promotion as **idempotent**: if the block is already present, verify it matches (including `@[reducible]`) and move on rather than duplicating. The two designs agree, including on the destination file, so neither needs to change. 617 was not dispatched this cycle |
| Territory collision with task 801 on `typst/generated/status.typ` (its declared `file_scope`) | M | M | Phase 6 re-reads the file immediately beforehand, regenerates it mechanically via `scripts/typst-status-counts.sh` (it is generated, never hand-authored), and stages that one path explicitly. If a foreign uncommitted modification or a foreign commit to it is observed, STOP and report per the dispatch's concurrency note rather than regenerating over it |
| `@[reducible]` on `TaskFrame.rev` is silently load-bearing — dropping it in the move breaks `revHistEquiv.invFun`, `WorldHistory.rev_surjective` and `validIn_reflectTime`'s final step, all of which need `F.rev.rev = F` by `rfl` at reducible transparency | H | L | Named as an explicit check in Phase 1's task list and in Testing & Validation |
| Wide rebuild: `TaskFrame.lean` is ~2896 lines and imported by almost everything downstream, so Phase 1 triggers a near-full rebuild | M | H | Budget for it rather than be surprised. Use guarded scoped builds per phase and reserve the unscoped full build for Phase 6, per `context/project/lean4/operations/long-builds.md`. Every `lake` call goes through `lake-build-guard.sh`, detached, with an explicit `--timeout` |
| An `instance` and a `@[simp]` lemma become visible much earlier: `FrameOver.rev_isRegular` moves to the base of the semantics layer, `WorldHistory.rev_state` to just above `TruthTransport` | M | L | Both are keyed on a `.rev` head, so instance search and `simp` engage only on goals already mentioning reversal. Task 617's probe already compiled the promoted instance inside the Presheaf cluster, the most instance-sensitive consumer in the tree |
| Raising `linter.style.longFile` in `TaskFrame.lean` is read as parking unrelated material (the existing comment says "Not for parking unrelated material") | L | M | The promoted block *is* frame-level material about `FrameOver`/`TaskFrame`, which is that file's subject. Phase 1 extends the existing justification comment with that reason in the established style, rather than silently bumping the number |
| G-15 guard regression: a promoted module reaching `ProofSystem` would fire a consumer's `assert_not_exists` | H | L | `Reversal.lean` imports `FormalSystem.Semantics.TruthTransport` and nothing else, and carries the G-15 guard verbatim. Research probe 7 compiled the whole Phase-2 module content with the full guard in force. `Truth.lean`'s and `TaskFrame.lean`'s guards are untouched because no new import is added to either |
| A gate fails for a pre-existing, unrelated reason and is mistaken for a regression | M | M | Phase 6 records each gate's exit status individually. `check-paper-definitions.sh` is known to exit 1 on ten anchors already drifted before this task began; run it without tail-truncation, read the complete `--- anchor:` list, and report an inherited failure as inherited with its output, never silently dropped |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 1, 2, 3, 4, 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Promote the frame level into Semantics/TaskFrame.lean [NOT STARTED]

**Goal**: `FrameOver.rev` and its regularity instance, the two task-relation lemmas, the
involution facts and `@[reducible] TaskFrame.rev` live at the base of the semantics layer, where
both this task's `Reversal.lean` and task 617's Presheaf cluster can see them.

**Tasks**:
- [ ] Re-read `FormalSystem/Semantics/TaskFrame.lean` and
      `FormalSystem/OpenLanguage/OpenReversal.lean` in full immediately beforehand (concurrent
      siblings are live on this tree, and task 617 may have landed the same promotion)
- [ ] **Idempotency check**: if the `FrameOver.rev` block is already present in `TaskFrame.lean`,
      verify it matches the source being moved — in particular that `TaskFrame.rev` still carries
      `@[reducible]` — and skip the insert, proceeding to the deletion step
- [ ] Insert into `TaskFrame.lean`, in a `/-! ## The converse frame -/` section, the block
      currently at `OpenReversal.lean:72-142`: `FrameOver.rev`, the
      `instance FrameOver.rev_isRegular`, `FrameOver.rev_taskRel`, `FrameOver.rev_taskRel_neg`,
      `FrameOver.rev_rev`, `@[reducible] def TaskFrame.rev`, `TaskFrame.rev_rev` — docstrings
      verbatim, `@[reducible]` preserved
- [ ] Raise `set_option linter.style.longFile 2900` to `3000` and extend the existing
      justification comment above it with one clause in the established style, naming the
      converse-frame block and why it belongs beside the `def:frame` constraint predicates it is
      proved against. No task-number citation (C9 gates those under `FormalSystem/`)
- [ ] Delete the moved declarations from `OpenReversal.lean`'s `namespace FormalSystem.Semantics`
      block, leaving `TaskModel.rev`, `TaskModel.rev_rev`, `WorldHistory.rev`,
      `WorldHistory.rev_state`, `WorldHistory.rev_rev_hist` and `WorldHistory.rev_surjective` in
      place. The deletion is in this same commit: two live declarations of the same name in the
      same namespace do not compile
- [ ] Stage `FormalSystem/Semantics/TaskFrame.lean` and
      `FormalSystem/OpenLanguage/OpenReversal.lean` as an explicit two-path list, never a
      directory or glob add

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase asserts that the block to move is `OpenReversal.lean:72-142`
(~71 lines), that `TaskFrame.lean` is currently 2896 lines against a `longFile` ceiling of 2900,
and that the post-move length therefore lands near 2966 and needs the ceiling at 3000. The line
span and both numbers were measured at plan-authoring time by `wc -l` and by reading
`TaskFrame.lean:284`, not carried from the research report (which does not mention the ceiling).
Confirm at implementation time by re-measuring with `wc -l` after the edit and by reading the
build's own `longFile` verdict: Mathlib's linter also complains when the ceiling is set
*higher* than the file needs, so 3000 is correct only if the final length exceeds 2900.

**Files to modify**:
- `FormalSystem/Semantics/TaskFrame.lean` - receives the converse-frame block; `longFile` ceiling 2900 -> 3000 with an extended justification comment
- `FormalSystem/OpenLanguage/OpenReversal.lean` - the same seven declarations deleted

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 2400 -- build FormalSystem.Semantics.TaskFrame`
  exits 0 (detached via `Bash(run_in_background: true)`, un-piped exit capture)
- `bash .claude/scripts/lake-build-guard.sh build --timeout 2400 -- build FormalSystem.OpenLanguage.OpenReversal`
  exits 0 — this is the closure over the moved declarations' every consumer
- `wc -l FormalSystem/Semantics/TaskFrame.lean` and the `longFile` verdict agree: no
  `file too long` and no `limit is too large` diagnostic
- `grep -n '@\[reducible\] def TaskFrame.rev' FormalSystem/Semantics/TaskFrame.lean` matches —
  the attribute survived the move
- `grep -c 'FrameOver.rev' FormalSystem/OpenLanguage/OpenReversal.lean` shows no surviving
  declaration (references in docstrings are expected and are rewritten in Phase 5)

**Tier Justification**: the seven declarations keep their names, namespace and statements and only
change module home, so the covering check is the guarded scoped build of
`FormalSystem.OpenLanguage.OpenReversal` — the module that previously declared them and whose
import closure contains every consumer — together with the changed base module itself; no
repository-level gate surface is touched by a same-name, same-namespace relocation.

---

### Phase 2: New module Semantics/Reversal.lean -- model, history, and the anti-isomorphism [NOT STARTED]

**Goal**: `lem:time-reflection` for BL (`truthAt_rev`) exists, in a new G-15-guard-clean module
that imports `FormalSystem.Semantics.TruthTransport` and nothing else.

**Tasks**:
- [ ] Re-read `FormalSystem/OpenLanguage/OpenReversal.lean`,
      `FormalSystem/Semantics/TruthTransport.lean`, `FormalSystem/Semantics.lean` and
      `FormalSystem/Semantics/README.md` immediately beforehand
- [ ] Create `FormalSystem/Semantics/Reversal.lean`: the four-line copyright header in the
      established style, `import FormalSystem.Semantics.TruthTransport` as the sole import, a
      module docstring (`# ...`, `## Main Definitions`, `## Tags`) as the first command after the
      imports, and the G-15 guard copied verbatim from `TruthTransport.lean:44-45`:
      `assert_not_exists FormalSystem.ProofSystem.Axiom FormalSystem.ProofSystem.DerivationTree
      FormalSystem.ProofSystem.Derivable FormalSystem.ProofSystem.FrameClass`
- [ ] Move into it, from `OpenReversal.lean:144-173`: `TaskModel.rev`, `TaskModel.rev_rev`,
      `WorldHistory.rev`, `@[simp] WorldHistory.rev_state`, `WorldHistory.rev_rev_hist`,
      `WorldHistory.rev_surjective` — with `rwa [show (-s : F.Duration) - -t = t - s by abel]`
      replaced by `rwa [neg_sub_neg] at this` in `WorldHistory.rev`'s `respects_task` obligation
- [ ] Add `revHistEquiv`, `revAntiIso` and `truthAt_rev` as recorded under
      `## Lean Challenge Statements` below, with `revAntiIso.atom` proved by `change` +
      `rw [neg_neg]` (**not** `rfl`) and `truthAt_rev` closed by the bare
      `Truth.truthAt_of_truthAntiIso (revAntiIso M) φ τ t`
- [ ] Delete the six moved declarations from `OpenReversal.lean` and add
      `import FormalSystem.Semantics.Reversal` there (same commit, for the same duplicate-name
      reason as Phase 1)
- [ ] Register the module: add `import FormalSystem.Semantics.Reversal` to
      `FormalSystem/Semantics.lean` in its existing position-by-layer ordering, with a matching
      module-doc entry in that file's docstring list
- [ ] Regenerate the library root: `lake exe mk_all --lib FormalSystem`, then confirm
      `FormalSystem.lean` gained exactly one sorted `import FormalSystem.Semantics.Reversal` line
      and nothing else (`check-module-invariants.sh` C33 gates this byte-for-byte)
- [ ] Add one `| Reversal.lean | ... |` row to `FormalSystem/Semantics/README.md`, following the
      `TruthTransport.lean` row's shape, and refresh that file's `*Last verified:*` date
- [ ] Stage the explicit six-path list; never a directory or glob add

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: atomic-batch

**Scope Hypothesis**: this phase asserts **nine** declarations in the new module (six moved, three
new) and that the whole content compiles against `import FormalSystem.Semantics.TruthTransport`
alone with the full G-15 guard in force. Both figures are carried from the research report's
probes 1, 6 and 7 (`reports/01_time-reflection-bl-tr-valid.md`, "Verified deliverable (1)" and
Recommendations Phase 2) rather than re-derived here, because re-deriving means re-running the
compiled probes, which is the implementation step itself. Confirm at implementation time by the
scoped build plus `grep -c '^\(def\|theorem\|@\[simp\] theorem\)' ` on the new file.

**Files to modify**:
- `FormalSystem/Semantics/Reversal.lean` - **new**; copyright header, module docstring, G-15 guard, the nine declarations
- `FormalSystem/OpenLanguage/OpenReversal.lean` - six declarations deleted; `import FormalSystem.Semantics.Reversal` added
- `FormalSystem/Semantics.lean` - import line plus module-doc entry
- `FormalSystem.lean` - regenerated by `lake exe mk_all --lib FormalSystem`
- `FormalSystem/Semantics/README.md` - one table row; `Last verified` date refreshed

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Reversal`
  exits 0
- `bash .claude/scripts/lake-build-guard.sh build --timeout 2400 -- build FormalSystem.OpenLanguage.OpenReversal`
  exits 0
- `lean_verify FormalSystem.Semantics.truthAt_rev` reports no `sorryAx` and no axiom beyond
  `[propext, Classical.choice, Quot.sound]`
- The G-15 guard is present in `Reversal.lean` and the module's import list is the single line
  `import FormalSystem.Semantics.TruthTransport`
- `bash scripts/check-copyright-headers.sh` exits 0
- `git diff -- FormalSystem.lean` shows exactly one added line

**Tier Justification**: the new module enters the build graph through the `Semantics.lean`
aggregator and the regenerated library root, and six declarations change module home, so the
covering check is the guarded scoped build of `FormalSystem.OpenLanguage.OpenReversal` — the
enumerated direct dependent that previously declared all six — plus the new module itself.

---

### Phase 3: FrameClass.Sat.rev into Semantics/FrameClassValidity.lean [NOT STARTED]

**Goal**: every frame class is closed under reversal, stated beside the sibling `Sat` lemmas.

**Tasks**:
- [ ] Re-read `FormalSystem/Semantics/FrameClassValidity.lean` immediately beforehand
- [ ] Add `FrameClass.Sat.rev` beside `FrameClass.Sat.isRegular` and `FrameClass.Sat.anti`, inside
      the `FormalSystem.ProofSystem` namespace that file already declares and already documents as
      a deliberate namespace exception
- [ ] Prove it exactly as recorded in research: `haveI := h.isRegular; cases fc` with
      `exact inferInstance` on the `.Base` arm and `exact ⟨inferInstance, h.2⟩` on each of
      `.Dense`, `.ZTime`, `.RTime`
- [ ] Docstring it with the reason the closure is unconditional: `F.rev.Duration = F.Duration` by
      `rfl`, so each tag's own conjunct transfers unchanged, and regularity comes from the
      promoted `FrameOver.rev_isRegular` instance
- [ ] Stage the single path

**Timing**: 0.25 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts **four** `cases fc` arms, i.e. that `FrameClass` has
exactly the four constructors `Base`, `Dense`, `ZTime`, `RTime`. Re-derived at plan-authoring time
from `FormalSystem/ProofSystem/Axioms.lean:486-491`, not carried. Confirm at implementation time
by the build: a missing arm is a non-exhaustive-match error, an extra arm an unused-alternative
error.

**Files to modify**:
- `FormalSystem/Semantics/FrameClassValidity.lean` - one additive theorem beside `Sat.isRegular` / `Sat.anti`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.FrameClassValidity`
  exits 0
- `lean_verify FormalSystem.ProofSystem.FrameClass.Sat.rev` reports no `sorryAx`

**Tier Justification**: one additive theorem at the end of one module, changing no existing
declaration or signature, fully covered by the guarded scoped build of
`FormalSystem.Semantics.FrameClassValidity` named above.

---

### Phase 4: The validity level into Semantics/Validity.lean [NOT STARTED]

**Goal**: `thm:TR-valid` exists — at every frame class, in both directions, and at the two
non-tag validity predicates.

**Tasks**:
- [ ] Re-read `FormalSystem/Semantics/Validity.lean` immediately beforehand
- [ ] Add `import FormalSystem.Semantics.Reversal` to its import block. No cycle:
      `Reversal.lean` imports only `TruthTransport.lean`, which `Validity.lean` already imports
      at line 8
- [ ] Site the new block after `ValidIn.mono` (currently `Validity.lean:491`), the existing home
      of the structural validity lemmas
- [ ] Add `validOn_rev_iff`, with the backward arm going through
      `obtain ⟨τ, rfl⟩ := WorldHistory.rev_surjective τ'` and `rw [neg_neg] at key`, mirroring
      `openValidOn_rev_iff` arm for arm
- [ ] Add `validOnFrames_reflectTime` as the primitive carrying the `rev`-closure argument, then
      `validIn_reflectTime` as its instance at `fc.Sat` via
      `validOnFrames_reflectTime (fun _ => FrameClass.Sat.rev) h`, mirroring the existing
      `ValidOnFrames.mono` / `ValidIn.mono` pairing in the same file
- [ ] Add `validIn_reflectTime_iff` (forward arm by `rwa [Formula.reflect_time_involution]`) and
      `valid_reflectTime`
- [ ] Add `validComplete_reflectTime` and `validQTime_reflectTime`, each through
      `validOnFrames_reflectTime` with a local `⟨inferInstance, h.2⟩` closure under
      `haveI := h.1` — these are the two predicates no `FrameClass` tag denotes, which
      `validIn_reflectTime` cannot reach
- [ ] Docstring each with its paper anchor: `validOn_rev_iff` and `truthAt_rev` as
      `lem:time-reflection`, the `reflectTime` family as `thm:TR-valid`, and the frame-class form
      with the paper's own reason ("the reflected frame sharing its temporal order",
      `thm:TM-soundness`)
- [ ] Stage the single path

**Timing**: 0.5 hours

**Depends on**: 2, 3

**Verification Tier**: interface

**Scope Hypothesis**: this phase asserts **seven** new declarations and that `ValidComplete` /
`ValidQTime` are `ValidOnFrames (fun F => F.IsRegular ∧ F.IsComplete)` and
`ValidOnFrames (fun F => F.IsRegular ∧ F.IsQTime)` respectively — the shape the two extra
instances depend on. The count is this plan's own; the unfolding is carried from the research
report's probe 8 (`#print ValidComplete` / `#print ValidQTime`). Confirm at implementation time by
`#print`-ing both again before writing the two closure lemmas, and by the build.

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` - one new import; seven additive declarations after `ValidIn.mono`

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 2400 -- build FormalSystem.Semantics.Validity`
  exits 0
- `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build FormalSystem` exits 0 —
  the closure over every dependent of `Validity.lean`, which is the new import edge's blast radius
- `lean_verify` on all seven new declarations: no `sorryAx`, no axiom beyond
  `[propext, Classical.choice, Quot.sound]`
- A compiled probe confirms the decision-(3) availability claim still holds:
  `example {φ : Formula} (ax : Axiom φ) : ValidIn ax.minFrameClass φ.reflectTime :=
  validIn_reflectTime (axiom_validIn_min ax)` elaborates

**Tier Justification**: this phase adds an import edge into `Validity.lean`, a module nearly
everything downstream consumes, so the covering check is the guarded build of the `FormalSystem`
library target named above — the enumerated dependent set of a module at that depth is the library
itself, and nothing outside the Lean compile surface is touched.

---

### Phase 5: Record the decisions in the docstrings [NOT STARTED]

**Goal**: the soundness-collapse decision and the completed promotion are recorded where a reader
of the tree finds them, and no docstring still describes the pre-promotion layout.

**Tasks**:
- [ ] Re-read `FormalSystem/Metalogic/Soundness.lean` (around 1252-1340),
      `FormalSystem/OpenLanguage/OpenReversal.lean`'s module docstring and
      `FormalSystem/OpenLanguage.lean` (around line 55) immediately beforehand
- [ ] On `derivable_valid_and_reflect_time_validIn`, extend the docstring to record decision (3):
      that the paper's own soundness proof routes the TR rule through `thm:TR-valid` rather than a
      per-axiom dispatch; that `Semantics.validIn_reflectTime` is now that argument in the tree and
      `validIn_reflectTime (axiom_validIn_min ax)` alone proves `axiom_reflect_time_validIn_min`;
      and that the per-axiom dispatch is retained deliberately — as an independent re-derivation of
      the same validities, and because three sibling language layers mirror this recursion arm for
      arm. State the current design only, with no draft-history or supersession framing
- [ ] Add the matching back-reference on `axiom_reflect_time_validIn_min`
- [ ] Rewrite `OpenReversal.lean`'s module-docstring **Siting** paragraph, which currently states
      the promotion has not happened, and its `/-!` note at lines 65-67; the `OpenLanguage`
      namespace contents (the class swaps, `openTruthAt_rev`, `openValidOn_rev_iff`,
      `openValid_reflectTime`) stay untouched and unchanged in statement
- [ ] Rewrite `FormalSystem/OpenLanguage.lean`'s `OpenLanguage.OpenReversal` entry, which
      currently credits that module with `FrameOver.rev` / `TaskFrame.rev` / `TaskModel.rev` /
      `WorldHistory.rev`, to name only what the module still declares
- [ ] Stage the explicit three-path list

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: local

**Scope Hypothesis**: this phase asserts **three** files and four edit sites, located at
`Soundness.lean:1252-1335` (`axiom_reflect_time_validIn_min` through
`derivable_valid_and_reflect_time_validIn`), `OpenReversal.lean:62-67` (the namespace note) plus
its module-docstring Siting paragraph, and `OpenLanguage.lean:55` (the `OpenReversal` entry). The
`Soundness.lean` span is carried from the research report's References section; the other two were
re-derived at plan-authoring time by reading the files. Confirm at implementation time by
re-reading each site before editing — the line numbers will have shifted if a sibling touched
these files — and locate by declaration name and heading text, never by line number alone.

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` - docstring on `derivable_valid_and_reflect_time_validIn`; back-reference on `axiom_reflect_time_validIn_min`
- `FormalSystem/OpenLanguage/OpenReversal.lean` - module docstring Siting paragraph and the namespace note rewritten
- `FormalSystem/OpenLanguage.lean` - the `OpenReversal` module-doc entry rewritten

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build FormalSystem.Metalogic.Soundness`
  exits 0, and the same for `-- build FormalSystem.OpenLanguage`
- `bash scripts/readme-lint.sh` exits 0 (check 3: no broken relative file reference introduced by
  the rewritten entries)
- No `% PORT:`-style marker, task-number citation, or version/supersession language was added:
  `bash scripts/check-module-invariants.sh` C9 and C32 are read in Phase 6's run

**Tier Justification**: the edits are confined to docstrings, but Lean docstrings are part of the
declarations they attach to and do compile, so `prose`'s diff read-through is not a covering check;
the guarded scoped builds of `FormalSystem.Metalogic.Soundness` and `FormalSystem.OpenLanguage`
named above are, and no signature anywhere changes.

---

### Phase 6: Full verification and generated-artifact reconciliation [NOT STARTED]

**Goal**: the complete repository gate set is green, the two generated count artifacts are
current, and every claim this plan makes has been observed rather than assumed.

**Tasks**:
- [ ] Re-read `typst/generated/status.typ` immediately beforehand. **Task 801 declares this path
      in its `file_scope` and was dispatched this same cycle.** If a foreign uncommitted
      modification or a foreign commit to it is present — confirmed against `git log` as not this
      task's own work — STOP and report it rather than regenerating over it
- [ ] Regenerate it: `bash scripts/typst-status-counts.sh`. The `.lean` file count under
      `FormalSystem/` goes 689 -> 690, so the committed `formalsystem-file-count = 689` is stale
      and `typst-sync-check.sh` Check 2 fails until this runs. The file is generated, never
      hand-authored; stage that one path explicitly
- [ ] Run each gate below individually and record its exit status. A gate that fails for an
      unrelated, pre-existing reason is reported as such with its output, never silently dropped
      from the list
- [ ] Report the paper-side `% PORT:` clearance (`possible_worlds.tex:3973` and `:4003`) as
      deferred-to-user per the Non-Goals, naming the two line numbers and the two theorem names
      that discharge them, so the paper's owner can clear them without re-deriving anything

**Timing**: 0.75 hours

**Depends on**: 1, 2, 3, 4, 5

**Verification Tier**: full

**Scope Hypothesis**: this phase asserts that the gate list below is the complete one for this
change class, and that the `.lean` file count under `FormalSystem/` is 689 before this task and
690 after. Both counts were measured at plan-authoring time (`find FormalSystem -name '*.lean' |
wc -l` = 689; `typst/generated/status.typ:32` pins `formalsystem-file-count = 689`). Confirm at
implementation time by re-measuring both and by running every listed gate, recording each exit
status individually.

**Files to modify**:
- `typst/generated/status.typ` - regenerated by `scripts/typst-status-counts.sh` (file count 689 -> 690, plus the commit stamp)

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 3600 -- build` exits 0 (full project,
  detached, un-piped exit capture), and the same for `-- build BimodalTest`,
  `-- build BimodalTools`, `-- build BimodalToolsTest`
- No new `sorry` and no new axiom: `lean_verify` on all eleven new declarations reports no
  `sorryAx` and nothing beyond `[propext, Classical.choice, Quot.sound]`
- `bash scripts/check-module-invariants.sh` exits 0 — with C33 (library root byte-current), C24
  (every module reaches `FormalSystem.Init`), C4/C5 (imports and module-shaped markdown paths
  resolve), C8 (aggregator convention), C9 (zero task-number citations) and C32 (relative
  markdown links in `.lean` comments) read explicitly in its output
- `bash scripts/check-copyright-headers.sh` exits 0
- `bash scripts/readme-lint.sh` exits 0
- `bash scripts/typst-sync-check.sh` exits 0
- `bash scripts/check-paper-definitions.sh` — run **without** tail-truncation, so a drift list
  longer than the terminal is not hidden; the complete `--- anchor:` list is read and any failure
  cross-checked against the ten anchors already drifted before this task began
- `bash scripts/check-phantom-citations.sh` exits 0
- `bash .claude/scripts/verify-deploy.sh` exits 0 — the complete aggregated gate set for the
  repository, named here in full per the `full` tier

---

## Lean Challenge Statements

These are the research-verified signatures, transcribed from the report's compiled probes 1-3.
The block is written to type-check against the tree **as it stands before Phase 1** (the probes
imported `FormalSystem.OpenLanguage.OpenReversal` plus `FormalSystem.Semantics.Validity` and
compiled with zero diagnostics), so a snapshot taken from this plan is a trusted pin independent
of the layering move. After Phase 2 the same statements resolve through
`FormalSystem.Semantics.Reversal` instead; the statements themselves do not change.

```lean
import FormalSystem.OpenLanguage.OpenReversal
import FormalSystem.Semantics.Validity

open FormalSystem.Syntax

namespace FormalSystem.Semantics

/-- Reversal of world histories as an equivalence `H_F ≃ H_{F⁻}` -- the paper's bijection
`τ ↦ τ⁻`, packaged in the form `TruthAntiIso.hist` requires. -/
def revHistEquiv (F : TaskFrame) : WorldHistory F ≃ WorldHistory F.rev := sorry

/-- The reversal anti-isomorphism: `dur` is negation, `hist` is the reversal involution,
`atom` holds because the two models share their valuation. -/
def revAntiIso {F : TaskFrame} (M : TaskModel F) : TruthAntiIso M M.rev := sorry

/-- `lem:time-reflection` for BL. -/
theorem truthAt_rev {F : TaskFrame} (M : TaskModel F) (τ : WorldHistory F) (t : F.Duration)
    (φ : Formula) : TruthAt M τ t φ ↔ TruthAt M.rev τ.rev (-t) φ.reflectTime := sorry

/-- Frame-level form: `φ` is valid on `F` exactly when its reflection is valid on `F⁻`. -/
theorem validOn_rev_iff (F : TaskFrame) (φ : Formula) :
    F.rev.ValidOn φ.reflectTime ↔ F.ValidOn φ := sorry

/-- Generic frame-predicate form: validity over any `rev`-closed class of frames is closed
under reflection. -/
theorem validOnFrames_reflectTime {P : TaskFrame → Prop} {φ : Formula}
    (hP : ∀ F : TaskFrame, P F → P F.rev) (h : ValidOnFrames P φ) :
    ValidOnFrames P φ.reflectTime := sorry

/-- `thm:TR-valid`, frame-class form. -/
theorem validIn_reflectTime {fc : ProofSystem.FrameClass} {φ : Formula} (h : ValidIn fc φ) :
    ValidIn fc φ.reflectTime := sorry

/-- The involution form: what a caller reasoning from a reflected formula back wants. -/
theorem validIn_reflectTime_iff {fc : ProofSystem.FrameClass} {φ : Formula} :
    ValidIn fc φ.reflectTime ↔ ValidIn fc φ := sorry

/-- `thm:TR-valid`. -/
theorem valid_reflectTime {φ : Formula} (h : Valid φ) : Valid φ.reflectTime := sorry

/-- `thm:TR-valid` at `ValidComplete`, which no `FrameClass` tag denotes. -/
theorem validComplete_reflectTime {φ : Formula} (h : ValidComplete φ) :
    ValidComplete φ.reflectTime := sorry

/-- `thm:TR-valid` at `ValidQTime`, which no `FrameClass` tag denotes. -/
theorem validQTime_reflectTime {φ : Formula} (h : ValidQTime φ) :
    ValidQTime φ.reflectTime := sorry

end FormalSystem.Semantics

namespace FormalSystem.ProofSystem

open FormalSystem.Semantics

/-- **Every frame class is closed under reversal**, because the reflected frame shares its
temporal order. -/
theorem FrameClass.Sat.rev {fc : FrameClass} {F : TaskFrame} (h : fc.Sat F) :
    fc.Sat F.rev := sorry

end FormalSystem.ProofSystem
```

## Testing & Validation

- [ ] All eleven new declarations compile and pass `lean_verify` with no `sorryAx` and no axiom
      beyond `[propext, Classical.choice, Quot.sound]`
- [ ] `TaskFrame.rev` still carries `@[reducible]` after the promotion — it is load-bearing for
      `revHistEquiv.invFun`, `WorldHistory.rev_surjective` and `validIn_reflectTime`'s final step,
      all of which need `F.rev.rev = F` by `rfl` at reducible transparency
- [ ] `FormalSystem/Semantics/Reversal.lean` imports `FormalSystem.Semantics.TruthTransport` and
      nothing else, and carries the G-15 `assert_not_exists` guard verbatim
- [ ] The `assert_not_exists` guards in `Semantics/Truth.lean`, `Semantics/TruthTransport.lean`
      and `Semantics/TaskFrame.lean` all remain satisfied — no new import was added to any of them
- [ ] `WorldHistory.rev`'s `respects_task` obligation closes by `rwa [neg_sub_neg] at this`, not
      by `abel`
- [ ] `revAntiIso.atom` is proved by `change` + `rw [neg_neg]`, not `rfl`
- [ ] Guarded full builds of `FormalSystem`, `BimodalTest`, `BimodalTools`, `BimodalToolsTest`
      exit 0
- [ ] `check-module-invariants.sh`, `check-copyright-headers.sh`, `readme-lint.sh`,
      `typst-sync-check.sh`, `check-phantom-citations.sh`, `verify-deploy.sh` all exit 0;
      `check-paper-definitions.sh` run untruncated and any failure cross-checked against the
      pre-existing drift set
- [ ] `FormalSystem.lean` is byte-current with `lake exe mk_all --lib FormalSystem` (C33) and
      `typst/generated/status.typ` records `formalsystem-file-count = 690`
- [ ] Nothing outside `/home/benjamin/Projects/BimodalLogic` was written
- [ ] `openTruthAt_rev`, `openValidOn_rev_iff` and `openValid_reflectTime` are unchanged in
      statement, and `OpenReversal.lean`'s `OpenLanguage`-namespace contents are untouched
- [ ] `derivable_valid_and_reflect_time_validIn` is unchanged in statement and proof, and carries
      the decision-(3) cross-reference docstring

## Artifacts & Outputs

- `FormalSystem/Semantics/Reversal.lean` (new) — `TaskModel.rev`, `WorldHistory.rev` and the
  reversal anti-isomorphism transport; `truthAt_rev` is `lem:time-reflection` for BL
- `FormalSystem/Semantics/TaskFrame.lean` — the promoted converse-frame block
- `FormalSystem/Semantics/Validity.lean` — the `thm:TR-valid` family
- `FormalSystem/Semantics/FrameClassValidity.lean` — `FrameClass.Sat.rev`
- `FormalSystem/OpenLanguage/OpenReversal.lean`, `FormalSystem/OpenLanguage.lean`,
  `FormalSystem/Semantics.lean`, `FormalSystem/Semantics/README.md`, `FormalSystem.lean` —
  reconciled dependents and registration
- `FormalSystem/Metalogic/Soundness.lean` — the decision-(3) docstrings
- `typst/generated/status.typ` — regenerated counts
- `specs/796_time_reflection_bl_tr_valid_anti_iso/summaries/01_time-reflection-bl-tr-valid-summary.md`
  — on completion, including the deferred paper-side `% PORT:` clearance report

## Rollback/Contingency

Each phase is one commit, so the ordinary rollback is `git revert` of the phase commits in
reverse order — Phase 6 first, Phase 1 last — which needs no working-tree discard and is safe
under the concurrent siblings on this tree.

If a phase must be abandoned mid-edit with uncommitted changes present, take a durable,
non-reverting checkpoint first — `bash .claude/scripts/git-snapshot.sh 796 --no-revert` — and
only then attempt any discard; for a genuine whole-tree rollback see
`context/contracts/recovery.md`'s rollback rung for the exact invocation shape, including its
out-of-scope override flag. Never run `git-snapshot.sh` in its reverting default mode while
siblings are live on this tree (dispatch concurrency note, item 3).

Phase-specific contingencies:

- **Phase 1 cannot land because task 617 already promoted a divergent block.** The two designs
  agree on the declarations and the destination file, so divergence would mean 617 changed its
  own design. Mark the phase `[BLOCKED]`, record what differs, and raise it — do not reconcile
  two designs silently.
- **A promoted `instance` or `@[simp]` lemma causes an unexpected downstream failure.** Fix
  forward by scoping the attribute, not by discarding the promotion; if no forward fix is found,
  Phases 2-4 can still proceed with the frame level left in `OpenReversal.lean` at the cost of
  `Reversal.lean` becoming unreachable from task 617's Presheaf cluster — record that as a
  reasoned exclusion with its evidence rather than as a silent descope.
- **`typst/generated/status.typ` is contended by task 801.** Leave it unregenerated, report
  `typst-sync-check.sh` Check 2 as a known, named stale-count failure with the two counts
  (689 committed, 690 actual), and let whichever task commits last regenerate it. Do not edit the
  pinned number by hand.
