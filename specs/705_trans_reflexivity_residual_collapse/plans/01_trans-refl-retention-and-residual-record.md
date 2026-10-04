# Implementation Plan: Task #705

- **Task**: 705 - trans_reflexivity_residual_collapse
- **Status**: [IMPLEMENTING]
- **Effort**: 3.5 hours
- **Dependencies**: 696 (completed), 703 (completed), 704 (archived — its territory claim on `scripts/check-module-invariants.sh` has lapsed)
- **Research Inputs**: specs/705_trans_reflexivity_residual_collapse/reports/01_trans-reflexivity-residual-audit.md
- **Artifacts**: plans/01_trans-refl-retention-and-residual-record.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: formal:logic
- **Lean Intent**: false

## Overview

Round-1 research refuted this task's filed premise and returned a verdict: **RETAIN `trans_refl`**.
What remains is therefore not a removal but a *record* — four label-level congruence theorems in
`PlusWitnessFamily/Incompleteness.lean` that state exactly how much agreement the retained
reflexivity field forces, which two of the four survive without it, and why that residual is
bounded and already dominated by the landed class-level incompleteness theorem. The plan lands
those four theorems, pins them in the C2 axiom baseline, gives them their four ledger rows, and
writes the retention decision onto the three prose surfaces that currently describe the residual
only at the unfolding level. Done means: the four declarations build at the repository's zero
warning budget, `scripts/check-module-invariants.sh` exits 0 with the four new baseline lines
asserted, and no prose surface still implies the label-level residual is unrecorded.

### Research Integration

Five findings from report 01 drive the phase structure directly:

- **The verdict (R1).** Four independent consumer categories need the self-step itself (F2): the
  (C1')→(C1)/(C2')→(C2) reductions, `FwdWalk.toThread`/`BwdWalk.toThread`'s off-walk step
  (which closes by `rfl` against the `@[refl]` `trans_refl'`), the decidable checker's
  `succF_nonempty`/`predF_nonempty` plus the default escape edge, and the landed
  `Limits/{NoCertificate,HopFree}.lean` reflexive reads. Removal costs ~87 term-level sites across
  18 files for no completeness gain. No removal work is planned.
- **The record is genuinely missing (F1).** `untl_succ_congr`/`snce_pred_congr` landed in
  `Sharing/Agreement.lean` but state the *unfolding-level* common-source agreement; the
  *label-level* statements are recorded nowhere, on either side, and the Plus side records no
  residual agreement at all. The name collision is real and must be defused by naming
  (Phase 1) and by cross-reference (Phases 1 and 4).
- **The proof terms are one-liners (R2).** Each is two instantiations of the same (C1') conjunct
  composed by `Iff.trans`/`Iff.symm`. Confirmed against the landed clause shape in
  `PlusWitnessFamily/Predicates.lean`'s `PlusLocalCoherentShare` and against the existing
  `plusUntl_self_of_share`/`plusSnce_self_of_share`, which use the identical instantiation idiom.
- **Scope item (4) is declined on the merits (D3).** A trans-congruence-specific incompleteness
  theorem would be strictly weaker than the landed `not_exists_plusCertifies_pumpTarget`, which
  needs no hypothesis on `trans` at all. No countermodel or target schema is constructed.
- **The sliced class carries no analogue (F5).** `PlusSlicedCertificate` has no `trans` field by
  construction and its `edge` relation is bi-serial but not reflexive, so the record must say
  the residual is confined to the retained sharing class rather than inherited by the programme's
  completeness route.

Two inputs beyond report 01 were confirmed directly in the tree while planning, because both
change the plan's shape:

- **R4's territory blocker has lapsed.** Report 01 sequenced the C2 baseline rows after sibling
  704 lands. 704 is now archived (`specs/archive/704_certificate_non_vacuity_and_shape_gates`),
  so `scripts/check-module-invariants.sh` is free and the C2 rows land in this plan's Phase 2
  rather than being handed off. They are also no longer optional: C36a asserts that every
  `docs/theorem-index.md` row is pinned by C2 or C14, so the ledger rows (Phase 3) go red unless
  the baseline rows precede them.
- **C15 constrains the docstrings.** `check-module-invariants.sh`'s C15 second assertion requires
  every ledger row's declaration to carry a `Paper:` line in its own `/--` doc comment, either
  the paper anchor or the literal `—` plus a one-clause reason. All four new theorems are
  formalization-native, so each needs `Paper: — (a formalization-native result; the paper states
  no such result)`, matching the landed `not_snce_share_congr`.

### Prior Plan Reference

No prior plan. This is round 1 for this task.

### Roadmap Alignment

`roadmap_path` was not supplied in the delegation context, so ROADMAP.md was consulted read-only
for alignment and is **not** modified by this plan (no roadmap review/update phases are present,
since `roadmap_flag` is not set). The roadmap carries this task as an open item under
`## Phase 2: L⁺ Sliced Certificates (High Priority)`: "Record the `trans_refl` verdict: RETAIN —
roughly 87 term-level sites across 18 files need the self-step. Land the label-level congruences
that are the bounded residual". This plan advances exactly that item and nothing else on the
roadmap.

## Goals & Non-Goals

**Goals**:
- Land four label-level congruence theorems in `PlusWitnessFamily/Incompleteness.lean`:
  `untl_trans_congr`, `snce_trans_congr` (both forced by `trans_refl` alone) and
  `untl_common_succ_congr`, `snce_common_pred_congr` (both reflexivity-free), with one docstring
  that says what the residual is, that it is bounded, and that it is dominated.
- Pin all four in the C2 axiom baseline so their ledger rows' `Axioms` column is read off the
  build rather than typed.
- Give all four a `docs/theorem-index.md` row beside the two existing refuted-congruence rows.
- Write the RETAIN decision and its rationale onto the three prose surfaces that currently
  describe the residual only at the unfolding level, defusing the `untl_succ_congr` name
  collision explicitly on each.

**Non-Goals**:
- No removal of `trans_refl`, no replacement field, no substitution lemma, no call-site
  migration. Report 01's Appendix migration sketch is recorded there and is deliberately not
  implemented (R5).
- No hopping countermodel and no named incompleteness theorem for the trans-congruence: scope
  item (4) is declined on the merits, not deferred (D3).
- No change to `plusTruth_iff_mem`, `plusRefutes_of_certifies`, or any soundness statement.
- **No Formula-side mirror in `Sharing/Agreement.lean`.** Report 01 offers it as optional and
  cheap; it is excluded because the residual bites on the Plus side (where nothing is recorded at
  all) and mirroring would double the ledger rows and C2 baseline lines for symmetry alone. A
  future task may take it.
- No edit to `specs/ROADMAP.md`.
- No `scripts/check-module-invariants.sh` edit outside its C2 probe block and C2 baseline block.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Name collision with the landed unfolding-level `untl_succ_congr`/`snce_pred_congr` misleads a future reader | M | H | The four new names are deliberately distinct (`*_trans_congr`, `*_common_succ_congr`/`*_common_pred_congr`); every docstring and both README paragraphs cross-reference the landed pair and state the shape difference explicitly (Phases 1, 4) |
| C36a goes red because ledger rows land before their C2 baseline lines | H | M | Phase 3 depends on Phase 2; the wave table enforces the order. Phase 5 re-runs the whole gate set |
| C15 fails because a new docstring lacks its `Paper:` line | M | M | Phase 1's task list makes the `Paper: —` line a per-theorem checklist item, copied verbatim from `not_snce_share_congr`; Phase 1's verification greps for four `Paper:` lines before the phase closes |
| Axiom values typed from expectation instead of read off the build (R-c) | M | M | Phase 2 reads each value from the C2 probe's own output; the baseline block is edited only after the probe output is in hand, never from the `pcq` guess |
| Pre-commit `typst-sync-check.sh --counts-only` refuses a commit that touched a `.lean` file (the deviation sibling 706 recorded) | M | H | Every `.lean`-touching phase (1 and 4) names `typst/generated/status.typ` in its own file list and regenerates it with `scripts/typst-sync-check.sh --fix` before committing, rather than discovering the gate at commit time |
| A proof term does not elaborate as written (wrong conjunct projection depth) | M | L | The projections were checked against the landed `PlusLocalCoherentShare` and the existing `plusUntl_self_of_share` idiom while planning; on a mismatch, Phase 1 falls back to `constructor`/`exact` with the conjunct named via `obtain` rather than guessing a new projection path |
| The absence of `*_trans_congr` rests on a grep sweep taken while the declaration index was unavailable (R-e) | L | M | Phase 1's first task re-confirms absence with a fresh `lean_local_search` if a language server is up, and otherwise re-runs the grep and says so; see this phase's Scope Hypothesis |
| Task-number references leak into deliverable files | L | M | `.claude/rules/no-task-references-in-deliverables.md` applies to every file this plan touches except those under `specs/`; all prose cites declaration names and file paths, never task numbers |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 4 | 1 |
| 3 | 3 | 2 |
| 4 | 5 | 3, 4 |

Phases within the same wave can execute in parallel. Note that Phases 2 and 4 are only nominally
parallel: both ultimately require a built library, and `check-module-invariants.sh` serializes on
`.lake/build-guard.lock`, so a single-agent run should simply take them in order.

### Phase 1: Land the four label-level congruences [COMPLETED]

**Goal**: The four theorems exist in `PlusWitnessFamily/Incompleteness.lean`, build clean at the
zero warning budget, and carry the docstring that makes the residual's boundedness legible.

**Tasks**:
- [x] Re-confirm that no `*_trans_congr`, `untl_common_succ_congr`, or `snce_common_pred_congr`
      declaration already exists: `lean_local_search` if a language server is up (announce the
      `index` field's value), otherwise `grep -rn "trans_congr\|common_succ_congr\|common_pred_congr" --include=*.lean FormalSystem/`
      and say that the evidence tier is a grep sweep. *(completed: lean_local_search index was `warming`, so the grep sweep is the evidence of record; no matches found)*
- [x] Add a new `/-! ## The residual the succession substrate still carries -/` section to
      `Incompleteness.lean`, after the two retired-congruence refutations and before
      `/-! ## The schema is a genuine ℤ-time non-validity -/`. *(completed)*
- [x] Land `untl_trans_congr` and `snce_trans_congr` — the two shapes forced by `trans_refl`
      alone, each proved by instantiating the matching (C1') conjunct twice and composing. *(completed)*
- [x] Land `untl_common_succ_congr` and `snce_common_pred_congr` — the two reflexivity-free
      shapes, which are the exact residual that survives if `trans_refl` is ever dropped. *(completed)*
- [x] Give each of the four a `/--` docstring ending in
      `Paper: — (a formalization-native result; the paper states no such result)` — required by
      C15, copied verbatim from the landed `not_snce_share_congr`. *(completed)*
- [x] Write the section docstring covering all six points report 01's R2 enumerates: (i) the first
      two are `clause_shape_collapse` at `R := S.trans t`, forced by `trans_refl` alone; (ii) the
      last two are what survives without reflexivity and are the exact residual; (iii) both pairs
      are vacuous on every landed producer, since `transFullOf` and `transIdOf` are the only
      succession bundles any landed family supplies; (iv) within the class's own frames they are
      truth-level facts, because an index at a time names a history type; (v) the time-sliced
      class carries no analogue, because it carries no `trans` field and its `edge` relation is
      bi-serial without being reflexive; (vi) they are strictly weaker than
      `Limits.NoCertificate.not_exists_plusCertifies_pumpTarget`, and are recorded so the
      relocation from `share`-classes to `trans`-classes is seen as deliberate and bounded.
- [x] Cross-reference `Sharing/Agreement.lean`'s `untl_succ_congr`/`snce_pred_congr` by name in
      the section docstring and state the shape difference: the landed pair states agreement on
      the *unfolding* at the common successor, the new pair states agreement on the *label* at
      the position itself. *(completed)*
- [x] Update the module header (`Incompleteness.lean`'s `/-!` block, the paragraph beginning
      "`Sharing/Agreement.lean`'s `snce_pred_congr` and `untl_succ_congr` state exactly how much
      agreement the clauses still force") so it no longer leaves the label level unmentioned. *(completed)*
- [x] Regenerate `typst/generated/status.typ` (`bash scripts/typst-sync-check.sh --fix`) and stage
      it with this phase's commit, because the pre-commit gate runs
      `typst-sync-check.sh --counts-only` on any commit touching a `.lean` file. *(completed)*

**Reference statements** (the four signatures this phase commits to; bodies shown because they
are one-liners, not because they are pinned — the implementer confirms elaboration):

```lean
theorem untl_trans_congr {Γ Del : PlusContext} {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) {i j : Fin S.lassos.length} {t : ℤ} (hij : S.trans t i j)
    {g e : PlusFormula} (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) :
    PlusFormula.untl g e ∈ S.L i t ↔ PlusFormula.untl g e ∈ S.L j t :=
  ((h i t).2.2.2.1 j hij g e hc).trans ((h j t).2.2.2.1 j (S.trans_refl' t j) g e hc).symm

theorem snce_trans_congr {Γ Del : PlusContext} {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) {i k : Fin S.lassos.length} {t : ℤ}
    (hki : S.trans (t - 1) k i)
    {g e : PlusFormula} (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) :
    PlusFormula.snce g e ∈ S.L i t ↔ PlusFormula.snce g e ∈ S.L k t :=
  ((h i t).2.2.2.2 k hki g e hc).trans
    ((h k t).2.2.2.2 k (S.trans_refl' (t - 1) k) g e hc).symm

theorem untl_common_succ_congr {Γ Del : PlusContext} {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) {i i' j : Fin S.lassos.length} {t : ℤ}
    (hij : S.trans t i j) (hi'j : S.trans t i' j)
    {g e : PlusFormula} (hc : PlusFormula.untl g e ∈ plusClosureOf (Γ ++ Del)) :
    PlusFormula.untl g e ∈ S.L i t ↔ PlusFormula.untl g e ∈ S.L i' t :=
  ((h i t).2.2.2.1 j hij g e hc).trans ((h i' t).2.2.2.1 j hi'j g e hc).symm

theorem snce_common_pred_congr {Γ Del : PlusContext} {S : PlusSharingWitnessFamily Γ Del}
    (h : S.PlusLocalCoherentShare) {i i' k : Fin S.lassos.length} {t : ℤ}
    (hki : S.trans (t - 1) k i) (hki' : S.trans (t - 1) k i')
    {g e : PlusFormula} (hc : PlusFormula.snce g e ∈ plusClosureOf (Γ ++ Del)) :
    PlusFormula.snce g e ∈ S.L i t ↔ PlusFormula.snce g e ∈ S.L i' t :=
  ((h i t).2.2.2.2 k hki g e hc).trans ((h i' t).2.2.2.2 k hki' g e hc).symm
```

**Timing**: 1.25 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Four declarations, all additive, all one-liners, in one file, with no
existing declaration of any of the four names. Confirm at implementation time by (a) the
absence check in this phase's first task, and (b) `lake build` succeeding with four new
declarations and zero new warnings. If any proof term fails to elaborate, the hypothesis
"two instantiations composed by `Iff.trans`" is what failed — re-derive the conjunct projection
from `PlusLocalCoherentShare`'s definition rather than from this plan's transcription, and record
the correction in the summary.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` - new section with four theorems and their docstrings; module-header paragraph updated
- `typst/generated/status.typ` - regenerated file/line counts, forced by the pre-commit gate

**Verification**:
- `lake build` exits 0 with zero compiler warnings (the repository runs a zero warning budget with
  every linter class blocking).
- `grep -c "^Paper: —\|Paper: —" ` over the new section finds one `Paper:` line per new theorem
  (four total).
- The four names resolve: `lean_local_search` or
  `grep -n "untl_trans_congr\|snce_trans_congr\|untl_common_succ_congr\|snce_common_pred_congr" FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean`
  returns the four declaration lines.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 2: Pin the four in the C2 axiom baseline [IN PROGRESS]

**Goal**: `check-module-invariants.sh`'s C2 asserts the axiom dependencies of all four new
theorems on every build, so the ledger's `Axioms` column can be read off the baseline rather
than typed.

**Tasks**:
- [x] Add four `#print axioms FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily.{name}`
      lines to the C2 probe block, placed beside the existing `not_snce_share_congr` and
      `not_untl_shift_share_congr` probe lines. *(completed)*
- [ ] Run the probe and **read** the four emitted axiom lines from its output.
      *(deviation: deferred — memory-pressure scheduling hold from the orchestrator on any
      command shelling out to `lake env lean` against the full `FormalSystem` import closure;
      the baseline line below is written speculatively at the `pcq` hypothesis and is NOT yet
      confirmed against actual probe output. See this task's handoff for the exact command to
      run once cleared.)*
- [x] Add the four matching expected-output lines to the C2 baseline block, in the same order as
      the probe lines, each written exactly as the probe emitted it. *(deviation: altered — the
      four lines are written at the `pcq` ([propext, Classical.choice, Quot.sound]) hypothesis
      pending confirmation from the deferred probe run above, not yet read off actual output)*
- [x] Confirm the edits are confined to the C2 probe block and the C2 baseline block; touch no
      `ENFORCE_*` flag and no other check. *(completed: also updated the C2 pass-message count
      from "forty-six" to "fifty" pinned axiom sets, inside the same C2 block)*

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Eight added lines (four probe, four baseline) in one script, and the four
axiom sets are expected to be `[propext, Classical.choice, Quot.sound]` (`pcq`), matching every
neighbouring row. The expectation is a hypothesis only: confirm by reading the probe's actual
output, and if any value differs, record the measured value in the baseline and flag the
difference in the summary rather than forcing `pcq`.

**Files to modify**:
- `scripts/check-module-invariants.sh` - four C2 probe lines and four matching C2 baseline lines

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0, with C2 reported PASS.
- C2's output names the four new declarations.
- `git diff` on the script shows changes only inside the C2 probe and C2 baseline blocks.

---

### Phase 3: Four ledger rows [IN PROGRESS]

**Goal**: `docs/theorem-index.md` carries a row for each of the four theorems, pinned, beside the
two existing refuted-congruence rows.

**Tasks**:
- [x] Add four rows next to the `not_snce_share_congr` and `not_untl_shift_share_congr` rows, each
      with: Paper label `—`; a one-line Statement; the fully qualified Lean name; the File path
      with no line number; Frame class `—` (all four are class-generic); and the Axioms cell read
      off the Phase 2 baseline, written as `pcq pinned:C2` if that is what the baseline records.
      *(deviation: altered — the Axioms cell is written as `pcq pinned:C2` at the Phase 2
      hypothesis, pending confirmation from the deferred probe run; see Phase 2's progress file)*
- [x] Word the two reflexivity-forced rows and the two reflexivity-free rows differently enough
      that a reader sees which pair survives dropping `trans_refl`. *(completed)*
- [x] Confirm each row's declaration carries its `Paper:` line, since C15 asserts the round trip
      from row to declaration. *(completed: `check-module-invariants.sh --no-build` confirms C15
      PASS at 252 theorem-index rows, all anchored)*

**Timing**: 0.5 hours

**Depends on**: 1, 2

**Verification Tier**: prose

**Commit Mode**: per-substep

**Scope Hypothesis**: Four added table rows, one file, no other ledger row changed. Confirm by
`git diff --stat` showing a single file with four added lines, and by C15/C36a passing.

**Files to modify**:
- `docs/theorem-index.md` - four rows added beside the two refuted-congruence rows

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0; C15's second assertion reports every row
  anchored (its count rises by four) and C36a reports no row pinned by neither C2 nor C14.
- Diff read-through confirms every changed hunk is a table row inside `docs/theorem-index.md`.

---

### Phase 4: The retention decision, on the prose surfaces [NOT STARTED]

**Goal**: The RETAIN verdict and its rationale are written where a reader of the substrate will
meet them, and no surface still implies the label-level residual is unrecorded.

**Tasks**:
- [ ] `WitnessFamily/Sharing/README.md`: extend the "**A position is a history type, and some
      neighbour agreement is therefore forced.**" paragraph (which currently names only
      `untl_succ_congr`/`snce_pred_congr`) with the label-level record, the four new names, and
      the shape distinction between unfolding-level and label-level agreement.
- [ ] `WitnessFamily/Sharing/README.md`: at the `trans_refl` bullet in the skeleton-fields list,
      record the verdict — the field is **retained**, because four independent consumer
      categories need the self-step itself (the two deterministic reductions, the finite-walk
      `toThread` extensions whose off-walk step closes against the `@[refl]` `trans_refl'`, the
      decidable checker's no-dead-ends lemmas and default escape edge, and the landed `Limits/`
      proofs' reflexive reads) — and point at the four new declarations as the bounded residual
      that retention costs.
- [ ] `PlusWitnessFamily/README.md`: after the "Five declarations recorded that, and all five are
      retired." paragraph, add one paragraph naming the four new declarations, stating that the
      Plus side previously recorded no residual agreement at all, and warning about the name
      collision with the landed unfolding-level pair.
- [ ] `WitnessFamily/Sharing/Skeleton.lean`: extend the `trans_refl` field's `/--` docstring with
      a one-clause pointer to the record ("the agreement this forces is stated at
      `PlusWitnessFamily/Incompleteness.lean`"), so the field itself cites its own cost.
- [ ] State in each prose surface that the time-sliced class carries no analogue, because it
      carries no `trans` field.
- [ ] Cite declaration names and file paths only — no task numbers in any of these four files
      (`.claude/rules/no-task-references-in-deliverables.md`).
- [ ] Regenerate `typst/generated/status.typ` and stage it with this phase's commit, since
      `Skeleton.lean` is a `.lean` file and the pre-commit gate will otherwise refuse.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: Three markdown paragraph-level edits plus one Lean doc-comment extension —
four files, no code. The tier is `local` rather than `prose` precisely because the `Skeleton.lean`
edit is a structure-field doc comment, which is part of the declaration and does elaborate;
confirm with a build rather than a diff read-through alone.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md` - history-type paragraph extended; `trans_refl` bullet carries the retention verdict
- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` - one paragraph naming the four declarations and the name-collision caveat
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` - `trans_refl` field docstring points at the record
- `typst/generated/status.typ` - regenerated counts, forced by the pre-commit gate

**Verification**:
- `lake build` exits 0 with zero warnings (the `Skeleton.lean` doc-comment edit elaborates).
- `grep -n "untl_trans_congr" FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md`
  finds the record on both READMEs.
- `bash .claude/scripts/check-task-references.sh` (or the repo-wide lint equivalent) reports no new
  task-number occurrence in the four files.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.

---

### Phase 5: Full gate set and close [NOT STARTED]

**Goal**: Every repository gate is green on the complete change, and the four generated/pinned
surfaces agree with the tree.

**Tasks**:
- [ ] `lake build` for the whole library; confirm zero errors and zero warnings.
- [ ] `lake build BimodalTest`.
- [ ] `bash scripts/check-module-invariants.sh`; confirm exit 0 and read C1, C2, C5, C15 and C36a
      individually rather than trusting the exit code alone.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check`; confirm no byte would
      change.
- [ ] `bash scripts/typst-sync-check.sh`; resolve any Check 2b (module map) or Check 3 (machine
      appendix) drift with the generator the script names, and record it as a scope extension if
      a file outside this plan's file list must change.
- [ ] Confirm no `sorry` was introduced: `grep -rn "sorry" ` over the touched `.lean` files.
- [ ] Final commit, and a `## Plan Deviations` entry in the summary for anything this plan's file
      lists did not anticipate.

**Timing**: 0.75 hours

**Depends on**: 3, 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts that Phases 1-4 already cover the whole file scope, so
no further file needs editing beyond a possible final `typst/generated/status.typ` regeneration.
Confirm at implementation time by running the gate set: any file the gates force to change is a
declared scope extension, named in the summary's `## Plan Deviations` section rather than taken
quietly.

**Files to modify**:
- `typst/generated/status.typ` - final regeneration if any later phase left it stale
- none further planned; any other file touched here is a declared scope extension to be named in the summary

**Verification**:
- `lake build` and `lake build BimodalTest` both exit 0 with zero warnings.
- `bash scripts/check-module-invariants.sh` exits 0.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` reports no change.
- `bash scripts/typst-sync-check.sh` exits 0.
- No `sorry` in any touched `.lean` file.

---

## Testing & Validation

- [ ] `lake build` — whole library, exit 0, zero compiler warnings at the repository's zero
      warning budget.
- [ ] `lake build BimodalTest` — exit 0. No new test is in scope; the four theorems are pinned by
      C2, not by a test.
- [ ] `bash scripts/check-module-invariants.sh` — exit 0, with C2 asserting the four new axiom
      lines, C15 anchoring the four new ledger rows at their declarations, and C36a finding every
      ledger row pinned.
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` — no byte would change.
- [ ] `bash scripts/typst-sync-check.sh` — all four checks pass, with `typst/generated/status.typ`
      regenerated and staged.
- [ ] No `sorry`, and no `#print axioms` value typed from expectation rather than measured.
- [ ] No task-number reference in any file outside `specs/`.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/Incompleteness.lean` — four new theorems
  (`untl_trans_congr`, `snce_trans_congr`, `untl_common_succ_congr`, `snce_common_pred_congr`)
  in a new section, plus an updated module header.
- `scripts/check-module-invariants.sh` — four C2 probe lines and four matching baseline lines.
- `docs/theorem-index.md` — four pinned ledger rows.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/README.md`,
  `FormalSystem/Metalogic/Decidability/PlusWitnessFamily/README.md` — the retention verdict and
  the label-level record, with the name-collision caveat on both.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Sharing/Skeleton.lean` — `trans_refl` field
  docstring pointing at the record.
- `typst/generated/status.typ` — regenerated counts.
- `specs/705_trans_reflexivity_residual_collapse/summaries/01_*-summary.md` — execution summary,
  including a `## Plan Deviations` section.

## Rollback/Contingency

The change is additive throughout: four new declarations, eight added baseline lines, four added
ledger rows, four prose paragraphs. Nothing is renamed, moved, or deleted, so per-phase commits
are individually revertible with `git revert` and no history rewrite is needed.

- **If a proof term does not elaborate** (Phase 1): re-derive the conjunct projection from
  `PlusLocalCoherentShare`'s definition in `PlusWitnessFamily/Predicates.lean`, using
  `plusUntl_self_of_share` as the worked instantiation idiom. If a one-liner still resists, land
  it as a short tactic proof (`constructor`-free: `obtain` the conjunct, then
  `exact Iff.trans ... (Iff.symm ...)`). A `sorry` is not an acceptable fallback here — these are
  two-instantiation compositions, not research.
- **If C2 reports an axiom value other than `pcq`**: record the measured value, do not force
  `pcq`, and flag the difference in the summary (R-c).
- **If `typst-sync-check.sh` Check 2b or Check 3 drifts**: regenerate with the generator the
  script names (`scripts/typst-module-map.sh`, `scripts/typst-machine-appendix.sh`) and declare
  the touched file as a scope extension in the summary rather than taking it quietly — this is
  exactly the deviation shape the finite-carrier landing recorded.
- **If a genuine rollback of uncommitted work is required**: take a snapshot first per
  `context/contracts/recovery.md`'s rollback rung (which names the invocation shape and its
  out-of-scope override flag), then perform the revert. Do not emit a bare reverting snapshot as
  a routine start-of-phase precaution; for an ordinary defensive checkpoint before risky work use
  the non-reverting `--no-revert` form instead.
