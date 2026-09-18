# Implementation Plan: Close the world-history reach-through residue

- **Task**: 615 - Close world history reach-through residue
- **Status**: [IMPLEMENTING]
- **Effort**: 3 hours
- **Dependencies**: None (the three predecessor tasks in this topic are archived and complete)
- **Research Inputs**: specs/615_close_world_history_reach_through_residue/reports/01_close-reach-through-residue.md
- **Artifacts**: plans/01_close-reach-through-residue.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The seven-phase possible-world-index retarget is already executed; what survives is a 36-site
residue. One three-line accessor lemma closes 22 of those sites, two named layer-crossing defects
close two more, and the remaining 13 are disposed of by explicit triage. Research re-measured
every count against the live tree and machine-checked the lemma, both defect restatements, and two
representative call-site rewrites in a probe that elaborates with zero errors, so no phase below
rests on an unverified definitional-equality claim. Definition of done: `lake build FormalSystem`
exits 0, `#print axioms` on `validZTime_iff_validInt` and `truthAt_map` returns exactly
`[propext, Classical.choice, Quot.sound]`, and the triage of all 15 non-rewritten sites is
recorded in the implementation summary.

### Research Integration

Every phase below is a direct promotion of a recommendation in
`reports/01_close-reach-through-residue.md`: R1 to Phase 1, R2 to Phases 2-3, R3 to Phase 4, R5 to
Phase 5, R4 to Phase 6, and R6 (do not touch `WorldHistory.ext`) to the Non-Goals. Three research
findings shape the phase structure rather than merely informing it:

1. **The sweep is not purely textual.** Four `rw [WorldHistory.states_eq_state]` lines lose their
   rewrite target once the surrounding hypotheses are in `state` normal form. All four live in
   Metalogic files, which is why the sweep is split by directory rather than by site count: Phase 3
   carries every non-mechanical edit, Phase 2 carries none.
2. **Research corrected the site paths given in the task description.** The two defects are at
   `FormalSystem/Semantics/IntNormalForm.lean:282` and
   `FormalSystem/Semantics/Extension/Extension.lean:219` — same line numbers, different
   directories from the `Automation/` and `Metalogic/` paths the description names. Phase 4 uses
   the verified paths.
3. **Research found a 9th layer crossing** the prior `.val`-only audit could not see
   (`PeriodicExtension.lean:429`, in the `.property` direction). The triage in Phase 6 therefore
   covers 9 crossings, not the 8 the description anticipated.

### Prior Plan Reference

No prior plan. This is the first planning round for this task.

### Roadmap Alignment

`specs/ROADMAP.md` was consulted read-only; no `roadmap_path` was passed in the dispatch context
and no roadmap phases are included. Roadmap item 8 in the "already machine-checked, promotion
only" list is `569 retarget_semantics_to_possible_world_index`, the parent of this task's topic;
that item is already closed and this task retires the residue it left behind. No roadmap item is
completed or newly opened by this plan.

## Goals & Non-Goals

**Goals**:
- Add the `respects_task` accessor lemma to the world-history namespace in
  `FormalSystem/Semantics/PartialHistory.lean`, in the exact form the research probe elaborated.
- Rewrite all 22 hand-spelled dependent-projection call sites to use it, including the four
  `WorldHistory.states_eq_state` rewrite lines that stop finding their pattern afterwards.
- Fix the two named layer-crossing defects so neither a definition body nor a theorem statement
  opens the subtype.
- Dispose of the remaining 6 reach-throughs and 9 layer crossings explicitly, and record that
  triage in the implementation summary as a deliverable.
- Hold the axiom gate: no new axiom, no sorryAx dependency, no regression from the 2659-job green baseline.

**Non-Goals**:
- The `PossibleWorld` rename (503 binders plus the namespace). Blocked on settling whether H_F or
  the time-shift quotient W_F owns the name; `possible_worlds.tex:1046` makes them different
  objects and `:1050` licenses both names.
- Converting `WorldHistory` from a subtype to a flat structure. A real net win per research, but it
  relocates bridging rather than removing it and belongs in its own task.
- Deleting `WorldHistory.ext` (`PartialHistory.lean:433`). Zero call sites, but it carries
  `@[ext]`, so removing it silently changes what the `ext` tactic does on a world-history goal.
  Parked for the flat-structure task per research R6.
- Deleting or weakening `WorldHistory.states_eq_state`. It drops to zero explicit call sites after
  Phase 3 but remains a `@[simp]` lemma that may fire implicitly; an explicit-call-site count is
  not evidence of deadness for a simp lemma.
- Touching `PartialHistory.Extends` or introducing a world-history-level restatement of it. That is
  precisely the relocated bridging the predecessor research warned against.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A `simp` call silently depended on `states_eq_state` firing against a hypothesis the sweep moves into `state` form | M | M | The full `lake build FormalSystem` at each phase close is a complete detector; the 2659-job exit-0 baseline makes any regression attributable |
| The four `states_eq_state` `rw` lines are missed in a mechanical find-and-replace, producing confusing "motive is not type correct" errors | M | M | Enumerated by exact file and line in Phase 3; `grep -rn "states_eq_state" FormalSystem/` returns exactly six hits, two of which are the definition and its docstring |
| Deleting the `CoeOut` instance changes elaboration at a site no grep can find | M | L | Phase 5 is sequenced last, is its own one-line commit, and is preceded and followed by a full rebuild, so a revert is a one-line revert |
| The `PlusPasting` `_ _` placeholder form does not collapse as cleanly as the two probed sites | L | L | The two placeholder underscores simply disappear; if elaboration objects, the site falls back to the explicit form and the failure is caught by the Phase 2 module build, not deferred |
| `lean-lsp` remains unreachable, so no hover or goal inspection is available | L | M | Research already substituted full elaboration via `lake env lean` on a probe, which is stronger evidence than a hover; the same probe file is available for re-running any single-site question |
| Scope creep toward the rename or the flat-structure conversion | M | L | Both are named in Non-Goals with their own justifications, and the one deletion that would pull toward the second (`WorldHistory.ext`) is explicitly parked |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 2, 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel. Phases 2 and 3 own disjoint file sets
(`FormalSystem/Semantics/**` vs `FormalSystem/Metalogic/**`) and may be dispatched together.

### Phase 1: Add the world-history `respects_task` accessor [NOT STARTED]

- **Goal:** The single lemma that 22 call sites need exists in the library, in the exact form the
  research probe elaborated, and the tree still builds.
- **Tasks:**
  - [ ] Confirm no name collision before writing: `grep -rn "WorldHistory.respects_task" FormalSystem/`
        returns nothing, and `namespace WorldHistory` is opened only at `PartialHistory.lean:408`.
  - [ ] Insert the lemma into `FormalSystem/Semantics/PartialHistory.lean` immediately after
        `states_eq_state` (currently ends `:429`), inside the existing `namespace WorldHistory`:
        ```lean
        theorem respects_task (τ : WorldHistory F) (s t : F.Duration) :
            F.TaskRel (τ.state s) (t - s) (τ.state t) :=
          τ.val.respects_task s t (τ.property s) (τ.property t)
        ```
  - [ ] Give it a docstring naming it as the `respects_task` obligation read at the bundled `state`
        accessor, and recording that it is the sole sanctioned replacement for hand-spelling the
        dependent projection.
  - [ ] Do NOT mark it `@[simp]` — it proves a relation, not an equation.
  - [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`
  - [ ] Commit.
- **Timing:** 20 minutes
- **Depends on:** none
- **Verification Tier:** full
- **Files to modify:**
  - `FormalSystem/Semantics/PartialHistory.lean` - add `respects_task` after `states_eq_state`
- **Verification:**
  - `lake build FormalSystem` exits 0 with no new warnings attributable to the insertion.
  - `grep -n "theorem respects_task" FormalSystem/Semantics/PartialHistory.lean` returns the new line.

---

### Phase 2: Sweep the 9 Semantics-layer call sites [NOT STARTED]

- **Goal:** Every hand-spelled dependent projection under `FormalSystem/Semantics/` is replaced by
  the Phase 1 lemma. This phase carries no `states_eq_state` adjustments; every edit is a
  term-position drop-in.
- **Tasks:**
  - [ ] Apply `τ.val.respects_task a b (τ.property a) (τ.property b)` -> `τ.respects_task a b` at:
    - [ ] `FormalSystem/Semantics/IntNormalForm.lean:328`
    - [ ] `FormalSystem/Semantics/ShiftSet.lean:244`, `:335`
    - [ ] `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean:85`, `:86`, `:101`, `:104`
          (the `_ _` placeholder form — the two underscores simply disappear)
    - [ ] `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean:108`, `:110`
  - [ ] Build each touched module as it is edited, then commit that file as a green sub-step.
  - [ ] Close with `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`.
- **Timing:** 40 minutes
- **Depends on:** 1
- **Verification Tier:** local
- **Scope Hypothesis:** 9 sites across 4 files, per the research inventory re-measured today.
  Confirm at implementation time with
  `grep -rn '\.val\.respects_task' FormalSystem/Semantics/ --include=*.lean | grep -v Boneyard`
  before starting (expect 9) and again after (expect 0). A count other than 9 means the tree moved
  since research; re-derive the site list from the grep rather than trusting this phase's list.
- **Files to modify:**
  - `FormalSystem/Semantics/IntNormalForm.lean` - 1 site
  - `FormalSystem/Semantics/ShiftSet.lean` - 2 sites
  - `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean` - 4 sites
  - `FormalSystem/Semantics/PlusLanguage/PlusDeterminism.lean` - 2 sites
- **Verification:**
  - Per file: that module builds.
  - Phase close: `lake build FormalSystem` exits 0, and the `Semantics/`-scoped grep above returns 0.

---

### Phase 3: Sweep the 13 Metalogic-layer call sites and the four `states_eq_state` lines [NOT STARTED]

- **Goal:** Every hand-spelled dependent projection under `FormalSystem/Metalogic/` is replaced by
  the Phase 1 lemma, and the four rewrite lines that lose their pattern as a result are trimmed or
  deleted. This is the only non-mechanical part of the sweep.
- **Tasks:**
  - [ ] Apply the same substitution at:
    - [ ] `Metalogic/Independence/PastingIndependence.lean:156`
    - [ ] `Metalogic/Independence/ForwardDeterministicFrame.lean:269`, `:270`
    - [ ] `Metalogic/Independence/DriftHistories.lean:137`
    - [ ] `Metalogic/Independence/LoopingDuration.lean:83`
    - [ ] `Metalogic/Independence/RealTranslationFrame.lean:156`, `:163`
    - [ ] `Metalogic/Independence/CoNotPriorU.lean:371-372` (continuation line 372 folds away)
    - [ ] `Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean:648`, `:838`
    - [ ] `Metalogic/Algebraic/FlowFrame.lean:376`, `:381`
    - [ ] `Metalogic/Decidability/Verified/Bridge/RegionFrame.lean:336`
  - [ ] Apply the four rewrite-line adjustments in the same edits:
    - [ ] `ForwardDeterministicFrame.lean:271` — trim `rw [WorldHistory.states_eq_state, h] at hτr`
          to `rw [h] at hτr` (probe-confirmed: the trimmed form is the one that elaborates)
    - [ ] `FlowFrame.lean:377` — delete
    - [ ] `FlowFrame.lean:382` — delete
    - [ ] `RegionFrame.lean:338` — delete
  - [ ] Build each touched module as it is edited, then commit that file as a green sub-step.
  - [ ] Close with `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`.
- **Timing:** 50 minutes
- **Depends on:** 1
- **Verification Tier:** local
- **Scope Hypothesis:** 13 projection sites across 9 files, plus exactly 4 `states_eq_state`
  rewrite-line adjustments. Confirm before starting with
  `grep -rn '\.val\.respects_task' FormalSystem/Metalogic/ --include=*.lean | grep -v Boneyard`
  (expect 13) and `grep -rn "states_eq_state" FormalSystem/ --include=*.lean | grep -v Boneyard`
  (expect 6 hits: the 4 rewrite lines plus the definition at `PartialHistory.lean:428` and its
  docstring at `:419`). After the phase, the first grep returns 0 and the second returns exactly
  the 2 definitional hits.
- **Files to modify:**
  - `FormalSystem/Metalogic/Independence/PastingIndependence.lean` - 1 site
  - `FormalSystem/Metalogic/Independence/ForwardDeterministicFrame.lean` - 2 sites + trim `:271`
  - `FormalSystem/Metalogic/Independence/DriftHistories.lean` - 1 site
  - `FormalSystem/Metalogic/Independence/LoopingDuration.lean` - 1 site
  - `FormalSystem/Metalogic/Independence/RealTranslationFrame.lean` - 2 sites
  - `FormalSystem/Metalogic/Independence/CoNotPriorU.lean` - 1 site (two lines)
  - `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean` - 2 sites
  - `FormalSystem/Metalogic/Algebraic/FlowFrame.lean` - 2 sites + delete `:377`, `:382`
  - `FormalSystem/Metalogic/Decidability/Verified/Bridge/RegionFrame.lean` - 1 site + delete `:338`
- **Verification:**
  - Per file: that module builds. A "did not find instance of pattern" or "motive is not type
    correct" error at one of the four rewrite lines is the expected signal that its adjustment was
    missed, not a reason to revert the projection edit.
  - Phase close: `lake build FormalSystem` exits 0, and both greps above return their post-sweep counts.

---

### Phase 4: Fix the two layer-crossing defects [NOT STARTED]

- **Goal:** Neither a definition body nor a theorem statement opens the subtype. Both fixes are
  probe-verified `rfl`-equal / proof-term-identical, so no consumer adjusts.
- **Tasks:**
  - [ ] `FormalSystem/Semantics/IntNormalForm.lean:280-282`: replace the body
        `fun t => τ.val.states t (τ.property t)` with `τ.state`.
  - [ ] Re-check the three `rfl`/`@[simp]` lemmas that ride on the path accessor still close by
        `rfl`: `IntNormalForm.lean:322`, `Metalogic/Decidability/BiLasso/Extend.lean:89`,
        `Metalogic/Decidability/BiLasso/Basic.lean:276`.
  - [ ] `FormalSystem/Semantics/Extension/Extension.lean:218-220`: replace the statement
        `∃ τ : WorldHistory F, τ.val.states x (τ.property x) = w` with
        `∃ τ : WorldHistory F, τ.state x = w`. The proof term `exact ⟨τ, hext.agree x rfl⟩` is
        unchanged.
  - [ ] Confirm both consumers still compile untouched: `Extension/Extension.lean:235`
        (`hF_nonempty`) and `Semantics/Validity.lean:273` (`not_validOn_bot`); both destructure as
        `⟨τ, _⟩` and discard the witness.
  - [ ] Commit each fix as its own green sub-step.
  - [ ] Close with `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`.
- **Timing:** 25 minutes
- **Depends on:** 2
- **Verification Tier:** interface
- **Scope Hypothesis:** exactly 2 defect sites, and exactly 5 enumerated dependents (3 on the path
  accessor, 2 on the occurrence statement). Confirm the dependent set at implementation time with
  `grep -rn '\.path\b' FormalSystem/ --include=*.lean | grep -v Boneyard` and
  `grep -rn 'occurrence ' FormalSystem/ --include=*.lean | grep -v Boneyard`, discarding docstring
  prose hits. A dependent outside the enumerated set means the one-hop build below is insufficient
  and the phase falls back to a full build before closing.
- **Files to modify:**
  - `FormalSystem/Semantics/IntNormalForm.lean` - path accessor body at `:282`
  - `FormalSystem/Semantics/Extension/Extension.lean` - occurrence statement at `:219`
- **Verification:**
  - Both changed modules plus the five enumerated dependents build.
  - Phase close: `lake build FormalSystem` exits 0.
  - `grep -rnE '\.val\.(states|domain|respects_task|nonempty_domain|timeShift)' FormalSystem/ Tests/ --include=*.lean | grep -v Boneyard`
    now returns exactly 4 hits, all inside `PartialHistory.lean`.

---

### Phase 5: Delete the never-firing `CoeOut` instance [NOT STARTED]

- **Goal:** The one-line instance that exists to make subtype crossings invisible — and measurably
  never makes one invisible — is removed, so the codebase stops carrying a false signal that
  crossings are implicit.
- **Tasks:**
  - [ ] Re-confirm deadness immediately before deleting: no `↑τ` or `(τ : PartialHistory F)`
        ascription of a world history anywhere in the tree, and all nine layer crossings are spelled
        with an explicit `.val` or `.property`.
  - [ ] Delete `instance : CoeOut (WorldHistory F) (PartialHistory F) := ⟨Subtype.val⟩` and its
        docstring at `FormalSystem/Semantics/PartialHistory.lean:412-413`.
  - [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem`
  - [ ] Commit as its own single-purpose commit, so a revert is a one-line revert.
  - [ ] **If the build fails**: revert this commit, leave the instance in place, and record the
        finding in the summary as a reasoned exclusion. Do NOT chase the elaboration failure — it
        would mean an implicit crossing exists that grep cannot see, which is the flat-structure
        task's problem, not this one's.
- **Timing:** 20 minutes
- **Depends on:** 2, 3, 4
- **Verification Tier:** full
- **Scope Hypothesis:** the instance has exactly zero firing sites. This is the one assertion in
  this plan that a grep cannot fully confirm — instance resolution is not syntactically bounded —
  which is why the full build is the real confirmation and why the abort path above is written out
  rather than left to judgment.
- **Files to modify:**
  - `FormalSystem/Semantics/PartialHistory.lean` - delete the `CoeOut` instance at `:413`
- **Verification:**
  - `lake build FormalSystem` exits 0 with no new errors or warnings.
  - The commit touches exactly one file and removes at most 3 lines.

---

### Phase 6: Record the triage and hold the gate [NOT STARTED]

- **Goal:** The triage of every non-rewritten site is a recorded deliverable, and the task's stated
  VERIFY clause is demonstrated green rather than assumed.
- **Tasks:**
  - [ ] Run the final gate:
    - [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0
    - [ ] `#print axioms FormalSystem.Semantics.validZTime_iff_validInt` returns exactly
          `[propext, Classical.choice, Quot.sound]`
    - [ ] `#print axioms FormalSystem.Semantics.truthAt_map` returns exactly
          `[propext, Classical.choice, Quot.sound]`
    - [ ] No `sorryAx` in either, and no live `sorry` introduced in non-Boneyard `FormalSystem/`
  - [ ] Write the reach-through triage table into the implementation summary: 22 REWRITTEN
        (Phases 2-3), 4 KEEP (the definitional sites inside `PartialHistory.lean` — the `state`
        body at `:423`, the `states_eq_state` statement and proof at `:428`/`:429`, and the
        `timeShift` body at `:471` — these *are* the accessor API and are the only places the
        subtype may legitimately be opened), 2 FIXED (Phase 4).
  - [ ] Write the layer-crossing triage table into the summary: all 9 KEEP, with the reason stated
        once for the group — `PartialHistory.Extends` is a partial-history-layer relation, the
        Extension Theorem is out of scope, and no world-history-level restatement exists that is
        not the flat-structure refactor. The 9: `Extension/Extension.lean:172`,
        `Extension/PeriodicExtension.lean:159`, `:403`, `:429` (the `.property`-direction crossing
        the prior audit missed), `Decidability/BiLasso/Agreement.lean:114`, `:137`,
        `IntTransfer.lean:205`, `:235`, `PartialHistory.lean:433`.
  - [ ] Record the two parked items and why: `WorldHistory.ext` (zero call sites but `@[ext]`) and
        `states_eq_state` (zero explicit call sites but `@[simp]`), both deliberately retained.
  - [ ] Record the Phase 5 outcome (instance deleted, or reverted with the build evidence).
  - [ ] Commit.
- **Timing:** 25 minutes
- **Depends on:** 5
- **Verification Tier:** full
- **Scope Hypothesis:** 4 KEEP + 2 FIXED reach-throughs and 9 KEEP layer crossings, totalling the
  15 non-rewritten sites. Confirm the first group with the full-inventory grep from Phase 4's
  verification (expect exactly 4 surviving hits, all in `PartialHistory.lean`); the layer-crossing
  count is confirmed by re-running the research greps
  (`Extends [\w.']*\.val`, `PartialHistory\.(map|comap)`, and `.property` restricted to files
  containing `WorldHistory`).
- **Files to modify:**
  - `specs/615_close_world_history_reach_through_residue/summaries/01_close-reach-through-residue-summary.md` - triage tables
- **Verification:**
  - Both `#print axioms` outputs quoted verbatim in the summary.
  - Both triage tables present, with every one of the 15 non-rewritten sites named individually.

---

## Lean Challenge Statements

```lean
import FormalSystem.Semantics.PartialHistory

namespace FormalSystem.Semantics.WorldHistory

variable {F : TaskFrame}

theorem respects_task (τ : WorldHistory F) (s t : F.Duration) :
    F.TaskRel (τ.state s) (t - s) (τ.state t) := sorry

end FormalSystem.Semantics.WorldHistory
```

## Testing & Validation

- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem` exits 0
      (baseline: 2659 jobs, green today)
- [ ] `#print axioms FormalSystem.Semantics.validZTime_iff_validInt` -> `[propext, Classical.choice, Quot.sound]`
- [ ] `#print axioms FormalSystem.Semantics.truthAt_map` -> `[propext, Classical.choice, Quot.sound]`
- [ ] No `sorryAx` in either gate theorem; no live `sorry` added to non-Boneyard `FormalSystem/`
- [ ] `grep -rn '\.val\.respects_task' FormalSystem/ Tests/ --include=*.lean | grep -v Boneyard`
      returns 0
- [ ] `grep -rnE '\.val\.(states|domain|respects_task|nonempty_domain|timeShift)' FormalSystem/ Tests/ --include=*.lean | grep -v Boneyard`
      returns exactly 4 hits, all inside `FormalSystem/Semantics/PartialHistory.lean`
- [ ] `grep -rn "states_eq_state" FormalSystem/ --include=*.lean | grep -v Boneyard` returns exactly
      2 hits (the definition and its docstring)
- [ ] The probe at `specs/615_close_world_history_reach_through_residue/probes/01_respects-task-residue.lean`
      still elaborates: `lake env lean <probe>` exits 0

## Artifacts & Outputs

- `specs/615_close_world_history_reach_through_residue/plans/01_close-reach-through-residue.md` (this file)
- `specs/615_close_world_history_reach_through_residue/summaries/01_close-reach-through-residue-summary.md`
  (carrying both triage tables — a deliverable of this task, not a side note)
- Modified library files: `FormalSystem/Semantics/PartialHistory.lean` (+1 lemma, -1 instance),
  15 files carrying the sweep and the two defect fixes

## Rollback/Contingency

Each phase is its own commit (Phases 2 and 3 commit per file), so rollback is per-phase
`git revert` of committed work — no working-tree destruction is required or intended, and no
snapshot step is needed for the ordinary path.

- **Phase 5 fails to build**: revert that single one-line commit and record the `CoeOut` instance as
  a reasoned exclusion in the summary. The rest of the task stands on its own.
- **Phase 3 cannot be made green**: the four rewrite-line adjustments are the only plausible cause.
  Revert the offending file's commit only — the sweep is per-file and the files are independent.
- **Phase 1 breaks the build** (no mechanism for this is known; the lemma is additive and
  probe-verified): revert and stop. Every later phase depends on it, and no partial sweep is
  coherent without it.
- If an uncommitted working tree must be discarded for an unrelated reason, take a durable
  checkpoint first per `context/contracts/recovery.md`'s rollback rung; do not emit a bare
  reverting snapshot as a routine precaution.
