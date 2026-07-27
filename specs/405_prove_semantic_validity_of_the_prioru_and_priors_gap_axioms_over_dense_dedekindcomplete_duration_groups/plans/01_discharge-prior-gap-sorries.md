# Implementation Plan: Task #405

- **Task**: 405 - Prove semantic validity of the Prior-U and Prior-S gap axioms over dense Dedekind-complete duration groups
- **Status**: [IMPLEMENTING]
- **Effort**: 1.25 hours
- **Dependencies**: 391 (complete — supplied the strategic sorries and the settled binder-set decision)
- **Research Inputs**: `specs/405_prove_semantic_validity_of_the_prioru_and_priors_gap_axioms_over_dense_dedekindcomplete_duration_groups/reports/01_prior-gap-axiom-validity.md`
- **Artifacts**: plans/01_discharge-prior-gap-sorries.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, lean4.md, plan-compliance.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This is a **transcription-and-verify** plan, not a proof-discovery plan. Research did not merely
scope the work: it wrote both proofs, patched them into `FormalSystem/Metalogic/Soundness.lean`,
confirmed `lake build` green (1892 jobs), confirmed both lemmas free of `sorryAx`
(`#print axioms` → `[propext, Classical.choice, Quot.sound]`), confirmed the sorry-warning count
dropped by exactly 2, and then reverted the working tree. The verified proof text is reproduced
verbatim in report section 6.

The work is therefore: re-apply three known-good insertions into one contiguous region of one
file, rebuild to reconfirm, then repair the three stale prose blocks that the verification run
did not touch. Two phases, ~60 lines of Lean plus ~15 lines of prose.

### Research Integration

Verified against the report rather than assumed. Confirmations made while planning:

1. **The single-phase recommendation is real** — report section 10 states "A single-phase plan
   suffices… No decomposition beyond one phase is warranted — the proofs are already verified."
   This plan uses **two** phases, a deliberate refinement explained under "Phase count rationale"
   below; it is not a rejection of the finding.
2. **The archived proof artifact still exists and is exact.** `diff` of the current
   `Soundness.lean` against
   `/tmp/claude-1000/-home-benjamin-Projects-BimodalLogic/51024596-e6d9-4261-a34c-cf493ee4da52/scratchpad/Soundness.lean.proved`
   yields exactly three hunks: the `exists_isGLB_of_lub` insertion after :1457, and the two
   `sorry` → proof-body replacements at :1461 and :1472. Nothing else differs. The archived text
   is character-for-character identical to report sections 4, 6.2, and 6.3.
3. **The archive does NOT contain the prose repairs.** The verification run replaced only the
   `sorry`s. The `-- sorry: … follow-up: task 405.` docstring blocks and the "Four lemmas … the
   ONLY debt" section comment are untouched in the archived file. This is the concrete reason
   the prose work is its own phase: it has no pre-verified artifact behind it.
4. **Baseline sorry count confirmed**: `grep -c "^  sorry$" FormalSystem/Metalogic/Soundness.lean`
   returns 4. Target after this task: 2.

**Phase count rationale**: Phase 1 terminates at a fully green, independently committable
milestone (build passes, sorry count is 2, both lemmas axiom-clean). Under the commit-per-green-
substep mandate in `.claude/rules/git-workflow.md`, that milestone must be committed when it is
reached rather than held until prose cleanup finishes. Splitting makes that commit boundary
explicit. Both phases are far under the 2-hour cap.

### Prior Plan Reference

No prior plan for this task. The parent task 391 created these sorries as deliberate division
points; its summary
(`specs/391_frameclass_dedekind_scaffolding/summaries/01_frameclass-dedekind-scaffolding-summary.md`)
is the origin record and the source of the `rfl`-level swap fact that `axiom_dedekind_swap_valid`
already exploits. Nothing from it is copied here.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no roadmap phases were requested,
so no ROADMAP.md consultation was performed and no roadmap phases are included.

## Goals & Non-Goals

**Goals**:
- Discharge `prior_U_gap_valid` and `prior_S_gap_valid` in `FormalSystem/Metalogic/Soundness.lean`
  with the research-verified proof bodies.
- Add the one required new helper, `private theorem exists_isGLB_of_lub`, immediately above
  `prior_U_gap_valid`.
- Leave `lake build` green with both lemmas free of `sorryAx`.
- Drop the `Soundness.lean` sorry count from 4 to exactly 2.
- Leave the file's prose truthful: no comment may still claim debt that no longer exists.

**Non-Goals**:
- **Do NOT restate either lemma at `ValidDedekind`.** The proofs would support it (they use only
  `h_lub` and `LinearOrder D`), and it is still forbidden. Report section 5 records the settled
  reason: `soundness_dedekind` must target `ValidDedekindDense` because `Dense ≤ Dedekind` makes
  `Axiom.density` and `Axiom.dense_indicator` admissible in a `.Dedekind` derivation and both are
  false on `ℤ`, which satisfies every `ValidDedekind` binder
  (`Semantics/Validity.lean:209-224`, `Soundness.lean:1418-1425`). Both call sites
  (`:1577-1578`, `:1597-1599`) already expect `ValidDedekindDense`. This is settled — do not
  revisit, do not "simplify".
- Do not touch `sep_valid` or `sep_swap_valid` — task 406 owns those (see File Scope below).
- Do not touch `prior_UZ` / `prior_SZ` (`ProofSystem/Axioms.lean:315,:320`). Different axioms
  (`F(φ) → U(φ, ¬φ)` at `FrameClass.Discrete`), confusingly similar names. The `.Dedekind`
  dispatcher already discharges those arms as absurd.
- Do not add `Truth.and_iff` / `Truth.or_iff` characterisation lemmas — that is a broad
  `Semantics/Truth.lean` refactor touching every soundness lemma, out of scope.
- Do not build a generic time-reversal transfer lemma. The tree proves each dual individually
  (`DenseValidity.lean`'s nine `swap_axiom_*_valid`); Prior-S is proved directly, matching
  convention.
- Completeness (rational-flowed Prior/Sep model, Reynolds Theorems 4/5, Doets transfer,
  `completeness_dedekind`) is explicitly out of scope.

### File Scope (hard constraint)

**Only file modified: `FormalSystem/Metalogic/Soundness.lean`.** No new module, no import-block
change, no change to the build graph.

Task 406 concurrently owns `sep_valid` and `sep_swap_valid` in this same file. All edits here
must stay inside the Prior region so the two diffs land as disjoint hunks.

**Line-number correction — read this before editing.** The report's section 9 risk table cites
`sep_valid :1549` and `sep_swap_valid :1572`; those numbers are stale, and the delegation brief
repeats them. Verified against the file as it stands today:

| Anchor | Actual line |
|---|---|
| `/-! ### Strategic sorries:` section comment block | 1436-1447 (`-/` at :1447; "Four lemmas" at :1437) |
| Prior-U `-- sorry:` docstring block | 1452-1457 |
| `theorem prior_U_gap_valid` | 1458 (`sorry` at :1461) |
| Prior-S `-- sorry:` docstring block | 1465-1468 |
| `theorem prior_S_gap_valid` | 1469 (`sorry` at :1472) |
| `theorem sep_valid` (task 406 — DO NOT TOUCH) | 1482 |
| `theorem sep_swap_valid` (task 406 — DO NOT TOUCH) | 1505 |

Edit region for this task: **1436-1472**. Nearest task-406 territory is 10 lines below.
Prefer unique anchor text (`theorem prior_U_gap_valid`, `theorem prior_S_gap_valid`, the literal
comment strings) over line numbers when editing — if task 406 lands first, line numbers shift but
anchors do not.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Transcription typo silently changes a proof | H | M | Do not retype. Copy verbatim from report §4/§6.2/§6.3, or lift the three hunks from the archived `Soundness.lean.proved`. `lake build` catches any divergence immediately. |
| Edits stray into task 406's `sep_valid`/`sep_swap_valid` region | M | L | Edit region capped at :1436-1472; verify with `git diff` before commit that no hunk reaches :1482 or beyond. |
| Stale `-- sorry: … follow-up: task 405.` blocks left behind | M | M | Phase 2 is dedicated to exactly this; Phase 2 verification greps for the strings. Leaving them makes the tree claim debt that no longer exists. |
| Section comment still says "Four lemmas … the ONLY debt" | M | M | Phase 2 rewrites it to two. Wording must be chosen so task 406 can empty the section cleanly. |
| Temptation to generalize to `ValidDedekind` | M | L | Explicitly forbidden — Non-Goals above and report §5. |
| Archived `.proved` file in `/tmp` is garbage-collected before implementation | L | L | The report reproduces both bodies and the helper verbatim in §4/§6.2/§6.3; that is the primary source. The archive is a convenience only. |
| `set … with hA` unused-variable lint | L | L | `hA`/`hB` are unused. Did not warn in the verified run. If a warning appears, drop the `with hA` / `with hB` clause. Make no other change to the proof. |
| Merge conflict with task 406 in the same file | L | M | Disjoint hunks by construction. If a conflict arises, resolve by keeping both regions; neither task's hunks overlap the other's. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel. There is no parallelism here: Phase 2's
prose must describe the proofs Phase 1 lands, and its verification re-runs the build.

---

### Phase 1: Transcribe the verified proofs and rebuild [COMPLETED]

**Goal**: Both Prior gap sorries discharged, `lake build` green, `Soundness.lean` sorry count
down to 2, both lemmas free of `sorryAx`.

**Tasks**:
- [x] Insert `private theorem exists_isGLB_of_lub` immediately **above**
      `theorem prior_U_gap_valid` (i.e. after the Prior-U docstring block ending at :1457).
      Body verbatim from report §4 — the `isLUB_lowerBounds.mp` route. Note that `BddBelow B` is
      definitionally `(lowerBounds B).Nonempty` and is passed straight through as the
      nonemptiness argument. *(completed)*
- [x] Replace the `sorry` in `prior_U_gap_valid` (:1461) with the body verbatim from report §6.2.
      Do not alter the theorem statement — the existing statement is a verified-exact
      transcription of Reynolds 1992 p.168 line 114 (report §2's 8-row encoding check, all rows
      "exact"). *(completed)*
- [x] Replace the `sorry` in `prior_S_gap_valid` (:1472) with the body verbatim from report §6.3.
      Statement likewise unchanged (Reynolds line 116). Note the deliberate trichotomy-branch
      ordering asymmetry against the U case: in the past case `r < s` → `hw`, `r = s` → `hps`,
      `s < r` → `hguard`, because the `K⁻` interval lies to the left. *(completed)*
- [x] Confirm no edit reaches line :1482 (`theorem sep_valid`) or beyond. *(completed — `git diff -U0`
      hunks at old :1457/:1461/:1472 only; `sep_valid` untouched)*
- [x] Run `lake build` and confirm success. *(completed — 1892 jobs, exit 0)*
- [x] Confirm `#print axioms` on both lemmas returns `[propext, Classical.choice, Quot.sound]`
      — no `sorryAx`. *(completed via `lean_verify`; helper returns `[propext]`)*
- [x] Commit this green milestone before starting Phase 2. *(completed)*

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` — insert helper above :1458; replace `sorry` at :1461
  and :1472. Net ~+65 lines, all within :1458-1472 + insertion.

**Verification**:
- `lake build` completes successfully (expect ~1892 jobs).
- `grep -c "^  sorry$" FormalSystem/Metalogic/Soundness.lean` returns **2** (down from 4).
- `mcp__lean-lsp__lean_verify` (or `#print axioms`) on `FormalSystem.Metalogic.prior_U_gap_valid`
  and `FormalSystem.Metalogic.prior_S_gap_valid` shows no `sorryAx`.
- `git diff --stat` shows exactly one file changed.
- `git diff` shows no hunk touching `sep_valid` or `sep_swap_valid`.

---

### Phase 2: Repair the now-false prose [NOT STARTED]

**Goal**: No comment in the file claims debt that no longer exists. This phase has no
pre-verified artifact behind it — the research verification run did not touch these blocks.

**Tasks**:
- [ ] Rewrite the Prior-U `-- sorry:` docstring block (:1452-1457, anchored on
      `-- sorry: assumes the Prior-U gap axiom is semantically valid`) into proof-summary prose:
      cite Reynolds 1992 printed p.168, and state the construction — the supremum of the set of
      right endpoints of φ-intervals starting at `t`, which is Reynolds' "supremum-less non-empty
      proper initial segment" made concrete. Delete the `follow-up: task 405.` line.
- [ ] Rewrite the Prior-S `-- sorry:` docstring block (:1465-1468, anchored on
      `-- sorry: assumes the Prior-S gap axiom is semantically valid`) the same way, describing
      the infimum dual and naming `exists_isGLB_of_lub` as the bridge from the binder set's
      least-upper-bound hypothesis. Delete the `follow-up: task 405.` line.
- [ ] Update the section comment block (:1436-1447): "Four lemmas for three axioms" and "These
      four lemmas are the ONLY debt in the Dedekind soundness chain" must both become **two**
      (`sep_valid` and `sep_swap_valid` only). Choose wording that task 406 can delete outright
      when it empties the section, rather than wording it will have to surgically edit.
- [ ] Optionally add the informational note from report §5: the Prior gap axioms are in fact
      valid on *every* Dedekind-complete linear order (the proofs use no `DenselyOrdered`,
      `Nontrivial`, `AddCommGroup`, `IsOrderedAddMonoid`, or `ShiftClosed` hypothesis); the
      `DenselyOrdered` binder is present for chain consistency, not mathematical necessity.
      **This is a docstring note only — do not act on it by weakening the binder set.**
- [ ] Per `.claude/rules/no-task-references-in-deliverables.md`, the replacement prose MUST NOT
      cite task numbers. Cite durable anchors instead: Reynolds 1992 p.168, the lemma names, the
      file/section references.
- [ ] Re-run `lake build` (comment-only edits, but confirm nothing was broken).

**Timing**: 0.5 hours

**Depends on**: 1

**Files to modify**:
- `FormalSystem/Metalogic/Soundness.lean` — comment/docstring text only, within :1436-1472.

**Verification**:
- `grep -n "follow-up: task 405" FormalSystem/Metalogic/Soundness.lean` returns nothing.
- `grep -n "Four lemmas" FormalSystem/Metalogic/Soundness.lean` returns nothing.
- `grep -n "ONLY debt" FormalSystem/Metalogic/Soundness.lean` — if present, the surrounding text
  says two lemmas, and names `sep_valid` / `sep_swap_valid`.
- No task-number citations introduced (`grep -nE "task [0-9]+" FormalSystem/Metalogic/Soundness.lean`
  should show no new hits from this phase).
- `lake build` still green; sorry count still exactly 2.

---

## Testing & Validation

- [ ] `lake build` completes successfully.
- [ ] `grep -c "^  sorry$" FormalSystem/Metalogic/Soundness.lean` returns 2 — a drop of exactly
      2 from the task-391 exit baseline of 4. This is the DONE-WHEN criterion.
- [ ] The two remaining sorries are `sep_valid` and `sep_swap_valid` and nothing else.
- [ ] `#print axioms prior_U_gap_valid` → `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms prior_S_gap_valid` → `[propext, Classical.choice, Quot.sound]`.
- [ ] `#print axioms exists_isGLB_of_lub` → `[propext]`.
- [ ] Both lemma **statements** are unchanged from their pre-existing form (they are verified-
      exact transcriptions; a changed statement is a regression, not a fix).
- [ ] Both lemmas remain at `ValidDedekindDense`.
- [ ] `axiom_dedekind_valid` (:1577-1578) and `axiom_dedekind_swap_valid` (:1597-1599) still
      compile unchanged — neither needed modification.
- [ ] `git diff` confines all hunks to the Prior region; `sep_valid`/`sep_swap_valid` untouched.
- [ ] No new imports; import block unchanged.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Soundness.lean` — the only modified file:
  - new `private theorem exists_isGLB_of_lub` above `prior_U_gap_valid`
  - `prior_U_gap_valid` proved
  - `prior_S_gap_valid` proved
  - three prose blocks corrected
- Implementation summary at
  `specs/405_prove_semantic_validity_of_the_prioru_and_priors_gap_axioms_over_dense_dedekindcomplete_duration_groups/summaries/01_discharge-prior-gap-sorries-summary.md`
- Two commits: `task 405 phase 1: transcribe verified Prior gap proofs` and
  `task 405 phase 2: repair stale sorry-debt prose`.

## Rollback/Contingency

The change is a single-file, ~80-line, additive diff with no build-graph impact, so rollback is
cheap: revert the commits for this task. Nothing else in the tree depends on the change beyond
the two call sites, which already reference these lemmas by name and compile either way (with
`sorry` before, without after).

Contingencies:
- **A proof body fails to compile as transcribed.** Treat it as a transcription error first, not
  a mathematical error — the exact text is known to compile against this toolchain. Re-copy from
  report §6.2/§6.3 (or the archived `.proved` file) before attempting any repair. Only if a
  verbatim copy still fails should the step map in report §2 be used to reconstruct the argument.
- **`lake build` fails for an unrelated reason** (e.g. task 406 landed a broken intermediate
  state concurrently). Confirm by stashing this task's changes and rebuilding; do not attempt to
  fix another task's territory.
- **Phase 2 stalls on wording coordination with task 406.** Phase 1's commit already satisfies
  the DONE-WHEN criterion, so Phase 1 stands on its own; Phase 2 can be completed independently
  without reverting anything.
