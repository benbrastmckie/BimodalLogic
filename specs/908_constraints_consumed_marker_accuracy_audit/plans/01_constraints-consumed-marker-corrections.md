# Implementation Plan: Task #908

- **Task**: 908 - Audit the remaining "Constraints consumed: Compositionality, Seriality, Limit, Saturation" docstring lines against what each declaration's proof actually projects, and correct the over-reporting ones
- **Status**: [NOT STARTED]
- **Effort**: 10.5 hours
- **Dependencies**: None
- **Research Inputs**: specs/908_constraints_consumed_marker_accuracy_audit/reports/01_constraints-consumed-marker-audit.md
- **Artifacts**: plans/01_constraints-consumed-marker-corrections.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The classification is already settled: a compiled closure probe measured all 68 full-four
`Constraints consumed:` marker sites and found **28 over-reporting, 40 accurate**. This plan
executes the correction, not another audit. The work is not 28 docstring edits: `check-module-invariants.sh`
C34a is enforced and refuses a marker that omits a constraint its own binder supplies, so 22 of
the 28 need a binder-free twin landed in the same phase (or the binder removed) before the
corrected marker can pass the gate. The plan corrects the 28 in seven file-scoped phases ordered
by enabler dependency, leaves the 40 accurate sites untouched, and closes with a docs/gate phase
that re-derives C34a's group counts from the gate's own `PASS C34a` line.

### Research Integration

Findings taken as given from `reports/01_constraints-consumed-marker-audit.md`:

- The per-site verdicts and corrected marker lists (the report's two tables: 28 over-reporting,
  40 accurate) are the authority for *which* sites change and *to what*. Each corrected marker
  is the probe's transitive hit set spelled in the closed vocabulary.
- `REFERENCE_NORMAL_FORM.md` settles the marker's meaning against three in-source rationales
  (`ConeUnravelling.lean:876`, `Nomic/ZTime.lean:132`, `Presheaf/Path.lean:1168`) that define it
  as "what the binder supplies". Those three paragraphs are rewritten alongside their markers.
- Four of the 28 reach no constraint at all; their honest marker is `None` (verified admissible:
  `check-module-invariants.sh`'s marker parser maps the literal `None` to the empty set).
- The documented C34a group counts (7/18/2 in `MODULE_INVARIANTS.md` and
  `REFERENCE_NORMAL_FORM.md`) are stale; a live run reports 62/22/2 and will move again here.

Two of the report's recommendations were re-derived at plan-authoring time and **corrected**:

1. The report's enabler table marks `FrameOver.taskRel_eq_iter` as having no binder-free twin.
   It already has one — `taskRel_eq_iter_of_constraints` at
   `FormalSystem/Semantics/IntNormalForm.lean:259`, marker `Compositionality, Seriality, Limit`.
   The `ConeUnravelling.lean` phase therefore needs no new enabler twin.
2. The report's "the 22 do not need 22 twins" understates C34a. `delegates()` requires the
   delegate to be named in the *row's own* body, carry an **identical** marker list, and mention
   no bundling class anywhere in its span. A corrected binder-carrying row cannot borrow another
   row's twin; it needs one reachable from its own proof term. The enabler leverage is real but
   it reduces the *proof cost* of each twin, not the twin *count*. Sized here as ~19 per-site
   twins plus 3 enabler twins, across seven correction phases rather than four.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in this dispatch's delegation context; no roadmap phases are
included.

## Goals & Non-Goals

- **Goals**:
- `base_taskRel_eq_ofStepRel_of_constraints` -- the binder-free twin unlocking `ConeUnravelling.lean`'s one over-reporting site.
- `respects_of_isStepPath_of_constraints`, `isTotal_respects_iff_adjacent_of_constraints` -- the two binder-free enabler twins in `IntNormalForm.lean` unlocking the `Nomic/ZTime.lean` cluster.
- `ofGerm_of_serial_limit` -- the binder-free germ constructor unlocking the `Presheaf/Path.lean` cluster of 20.

Non-coded goals of this plan (not Lean identifiers, so deliberately not named above and not
pinned in `## Lean Challenge Statements`):

- Correct all 28 over-reporting marker lines to the probe's measured hit sets.
- Keep `check-module-invariants.sh` green (C34, C34a, C34b) at every phase boundary.
- Rewrite the three in-source rationale paragraphs that defend the full-four listing.
- Re-derive the C34a discharge-group counts in `MODULE_INVARIANTS.md` and
  `REFERENCE_NORMAL_FORM.md` from the gate's own output.

**Non-Goals**:

- Touching any of the 40 accurate sites. A blind sweep would be worse than the current state.
- Closing the `BUNDLERS` short-name gap (`NomicFrame.IsRegular` matching the four-field table).
  The report flags it as out of scope and worth filing separately; nothing in the 28 depends on it.
- Changing any public signature. Every binder-carrying original keeps its exact signature and
  becomes a one-line corollary; route 3 (unbundle in place, which moves call sites) is a fallback
  only, taken with an explicit in-phase note when route 2 is not available.
- Reclassifying anything. The probe's verdicts are inputs, not open questions.
- Introducing any `sorry`, axiom, or placeholder. A sorry-free path exists throughout.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A new twin's span mentions a bundling class (a `haveI : F.IsRegular`, an `IsRegular` in its signature), so `delegates()` rejects it and the corrected marker still fails C34a | H | M | Author every twin to take `TaskFrame.Compositional/Serial/Limit` hypotheses explicitly and name `IsRegular` nowhere in its span; the phase's `check-module-invariants.sh` run is the mechanical check |
| A twin's marker list differs by one token from the corollary's, so `delegates()` (which matches on list identity) does not fire | H | M | Write the two marker lines as one copy-paste; the gate run catches any drift immediately |
| Restructuring a `def` (`PathHom.id`, `Beh.ofGerm`, `PathHom.toPath`) adds an unfolding layer and breaks a downstream `rfl`/`simp` proof | M | M | `interface` tier on every def-touching phase, naming the module plus its enumerated direct dependents (`Presheaf.lean` for `Path.lean`; `Sheaf.lean`, `Ray.lean`, `Reflection.lean`, `Directed.lean`, `Presheaf.lean` for `Behavior.lean`); if an unfolding break appears, keep the original's body as the real definition and give the twin the delegating direction instead |
| Correcting a marker changes the global delegation index and silently removes a discharge another row depended on | M | L | Markers only ever move from full-four to a proper sublist, and an omitting row can only delegate to an identically-marked row, so no currently-discharged row can lose its delegate; verified per phase by the gate run, not assumed |
| A binder on one of the three `None` sites turns out to be needed for instance synthesis elsewhere in its signature, so route 1 (binder deletion) fails | M | M | Phase 6 runs a transplant probe per site before deleting; on failure it falls back to route 2 (twin plus delegating corollary) in the same phase |
| `typst-sync-check.sh` Check 2 drift blocks a phase commit | L | M | Every `.lean`-touching phase carries `typst/generated/status.typ` in its file list, runs `--counts-only` before committing, and re-stamps with `--fix` only when drift is reported |
| `TaskFrame`-level `nullity_identity_of_serial_limit` may not exist (only the `FrameOver` form was verified) | M | M | Phase 4's first step establishes the available TaskFrame-level route before writing the twin; if only the `FrameOver` form exists, route through `F.toFibre` explicitly rather than adding a new TaskFrame-level lemma |
| `Path.lean`'s recorded long-file ceiling is crossed by the twins this plan adds | M | **H** | This is expected, not avoided -- see "Long-file ceiling arithmetic" below. Each `Path.lean` phase raises `set_option linter.style.longFile` in step with the file's new length as part of that phase's own work |
| README generated-inventory blocks go stale because they carry a per-file **Lines** column | M | H | Every `.lean`-touching phase runs `bash scripts/check-module-invariants.sh --emit-inventory` and stages the affected READMEs; the ancestor-chain READMEs are already in each phase's file list |

### Long-file ceiling arithmetic

`FormalSystem/Semantics/Presheaf/Path.lean` records `set_option linter.style.longFile 1700` at
line 258 and is **1,554 lines** today (both measured at plan-authoring time). This plan's own
per-phase estimates for that file -- roughly 110 lines in Phase 5 (8 twins), 80 in Phase 6 (5
twins, offset slightly by 3 binder deletions), and 75 in Phase 7 (5 twins) -- sum to about
**1,819 lines**, which **crosses the recorded 1700 ceiling**. The plan does not claim otherwise
anywhere.

The contingency is the escape valve that governs this particular ceiling: `linter.style.longFile N`
is explicitly admissible under `check-module-invariants.sh` C30 as a *recorded length ceiling*
rather than a suppression (C30's own comment notes the linter itself keeps `N` tight), so each
`Path.lean` phase raises the baseline in step with that phase's new line count rather than
leaving it stale or deleting it. If a phase's growth turns out materially larger than estimated,
the fallback is to split `Path.lean` -- a structural change out of this task's scope, which would
be filed rather than attempted here.

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
| 7 | 7 | 6 |
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. The chain is fully sequential here by
design, not by accident: every `.lean`-touching phase carries `typst/generated/status.typ` in its
file list (the `typst-sync-check.sh` pre-commit gate's requirement), so two phases run in
parallel would contend for that one file. Phases 1, 2 and 4 are logically independent of each
other; the edges 1->2 and 3->4 exist solely to serialize that shared file.

---

### Phase 1: Marker-only corrections at the binder-free rows [NOT STARTED]

**Goal**: Correct the five over-reporting markers that carry no `[F.IsRegular]` binder, where
C34a's `omitted` set is empty whatever the marker says and the correction is a one-line edit.

**Tasks**:
- [ ] Re-confirm each site's current marker line and line number before editing (line numbers in this plan are plan-time, carried from the research report, and drift on every edit): `Nomic/Witnesses.lean` `NomicHierarchy.F2.lawful` (~512), `Nomic/Witnesses.lean` `nomic_hierarchy` (~626), `Nomic/ZTime.lean` `NomicFrame.ofStepFamily_isRegular` (~118), `Nomic/ZTime.lean` `NomicFrame.mem_lawHist_ofStepFamily_iff` (~152), `Nomic/ZTime.lean` `NomicFrame.lawHist_mono_of_le` (~167).
- [ ] Set the marker on `F2.lawful`, `nomic_hierarchy`, `mem_lawHist_ofStepFamily_iff` and `lawHist_mono_of_le` to `Constraints consumed: Compositionality, Seriality, Limit`.
- [ ] Set the marker on `ofStepFamily_isRegular` to `Constraints consumed: None`.
- [ ] Reconcile `ofStepFamily_isRegular`'s surrounding docstring, which currently records that each member's *Saturation* comes from `TaskFrame.saturation_of_finite`: that paragraph is about what the instance *produces*, not what it consumes, so keep the choice-dependence note and say so explicitly rather than deleting it.
- [ ] Edit the four `Compositionality, Seriality, Limit` markers as one batch so the delegating pair `mem_lawHist_ofStepFamily_iff` / `lawHist_mono_of_le` keeps list identity throughout.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` and stage the regenerated ancestor-chain READMEs (their inventory blocks carry a per-file **Lines** column, so any line-count change makes them stale).
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only`; re-stamp with `--fix` and stage `typst/generated/status.typ` only if drift is reported.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: 5 over-reporting sites in these two files carry no `[F.IsRegular]` binder, carried from `reports/01_constraints-consumed-marker-audit.md`'s 28-row table ("Binder: no" rows, minus the `NomicFour.lean` row which belongs to an accurate site). Confirm at implementation time by reading each declaration's signature for a bracketed `IsRegular` binder before editing its marker; a site that turns out to carry one moves to a route-2 phase instead of being corrected here.

**Tier Justification**: `suite_selection_select` over this phase's paths returns `__FULL_SWEEP__` (verified at plan time, not asserted), so no Gate 8 suite covers them; the covering checks are `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic` for the two touched modules and `bash scripts/check-module-invariants.sh`, which is the only check that reaches C34/C34a/C34b at all.

**Files to modify**:
- `FormalSystem/Semantics/Nomic/Witnesses.lean` - two marker lines corrected to `Compositionality, Seriality, Limit`
- `FormalSystem/Semantics/Nomic/ZTime.lean` - two marker lines corrected to the three-constraint list; one corrected to `None`; plus the production-vs-consumption clarification on the generated-family instance
- `FormalSystem/README.md` - regenerated inventory block (per-file line counts shift)
- `README.md` - regenerated inventory block (per-file line counts shift)
- `typst/generated/status.typ` - re-stamped only if `typst-sync-check.sh --counts-only` reports drift

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0, with `PASS C34a` and `PASS C34b` present in its output; a full `lake build` covers none of C34/C34a/C34b, so this run is not optional.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic` succeeds (exit status checked, not inferred from stdout).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- The five edited markers read exactly as specified; no other marker line in either file changed (`git diff` read-through).

---

### Phase 2: `ConeUnravelling.lean` -- twin plus delegating corollary [NOT STARTED]

**Goal**: Correct `base_taskRel_eq_ofStepRel` to `Compositionality, Seriality, Limit` and give it
a C34a delegation discharge, reusing the already-existing enabler twin.

**Tasks**:
- [ ] Confirm `FrameOver.taskRel_eq_iter_of_constraints` is present at `FormalSystem/Semantics/IntNormalForm.lean` with marker `Constraints consumed: Compositionality, Seriality, Limit` and no `IsRegular` mention in its span; this is the enabler and it already exists, so no new enabler twin is written here.
- [ ] Add `base_taskRel_eq_ofStepRel_of_constraints (F : FrameOver intOrder)` taking `hcomp : TaskFrame.Compositional F.TaskRel`, `hser : TaskFrame.Serial F.TaskRel`, `hlim : TaskFrame.Limit F.TaskRel`, concluding `F.TaskRel = ofStepRel F.step`, proved by the original's body with `F.taskRel_eq_iter` replaced by `F.taskRel_eq_iter_of_constraints hcomp hser hlim`.
- [ ] Mark the twin `Constraints consumed: Compositionality, Seriality, Limit` and verify its span names `IsRegular` nowhere.
- [ ] Reduce `base_taskRel_eq_ofStepRel` to the one-line corollary `F.base_taskRel_eq_ofStepRel_of_constraints F.comp F.serial F.limit`, keeping its signature byte-identical, and give it the identical corrected marker.
- [ ] Rewrite the rationale paragraph at `ConeUnravelling.lean` (~876) that states "the marker lists what the **binder supplies**" and that "this module deliberately has no such twin": both claims are now false. State instead that the twin exists and that the marker enumerates what the term reaches.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` and stage the regenerated ancestor-chain READMEs.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only`; re-stamp with `--fix` and stage `typst/generated/status.typ` only if drift is reported.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths (verified at plan time), so no Gate 8 suite covers them; the covering checks are `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling` (additive theorem plus a proof-term-only change to an existing theorem, so no signature leaves the module) and `bash scripts/check-module-invariants.sh` for C34a's delegation discharge.

**Files to modify**:
- `FormalSystem/Semantics/ConeUnravelling.lean` - adds the binder-free twin; reduces the original to a delegating corollary; corrects both markers; rewrites the ~876 rationale paragraph
- `FormalSystem/README.md` - regenerated inventory block
- `README.md` - regenerated inventory block
- `typst/generated/status.typ` - re-stamped only if `typst-sync-check.sh --counts-only` reports drift

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0; its `PASS C34a` line attributes `base_taskRel_eq_ofStepRel` to the delegation discharge group rather than the omit-nothing group.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.ConeUnravelling` succeeds (exit status checked).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- No `sorry` and no new axiom: `grep -n sorry` over the touched file is empty.

---

### Phase 3: `IntNormalForm.lean` enabler twins plus the `ZTime.lean` binder-carrying site [NOT STARTED]

**Goal**: Land the two binder-free enabler twins the `Nomic/ZTime.lean` cluster needs, and correct
`NomicFrame.mem_lawHist_iff_isStepPath` with a delegation discharge.

**Tasks**:
- [ ] Add `FrameOver.respects_of_isStepPath_of_constraints`, the binder-free form of `respects_of_isStepPath` (`IntNormalForm.lean` ~361), taking the three constraints explicitly and routing through `taskRel_eq_iter_of_constraints` in place of `taskRel_eq_iter`; mark it `Constraints consumed: Compositionality, Seriality, Limit`.
- [ ] Add `FrameOver.isTotal_respects_iff_adjacent_of_constraints`, the binder-free form of `isTotal_respects_iff_adjacent` (~414), with the same three hypotheses, its `←` direction routed through the new `respects_of_isStepPath_of_constraints`; mark it identically.
- [ ] Reduce `respects_of_isStepPath` and `isTotal_respects_iff_adjacent` to one-line corollaries of their twins, signatures byte-identical, each carrying the identical corrected marker.
- [ ] Correct `NomicFrame.mem_lawHist_iff_isStepPath` (`Nomic/ZTime.lean` ~139) to `Constraints consumed: Compositionality, Seriality, Limit` and re-point its body at `FrameOver.isTotal_respects_iff_adjacent_of_constraints` so the delegation discharge fires.
- [ ] Rewrite the rationale paragraph at `Nomic/ZTime.lean` (~132), which asserts that "no binder-free form of this statement exists" and that "a marker records what the declaration consumes, not what its proof emphasises": the first claim is now false and the second inverts the specification. Replace both with the `REFERENCE_NORMAL_FORM.md` reading.
- [ ] Verify neither new twin names `IsRegular` anywhere in its span.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` and stage the regenerated ancestor-chain READMEs.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only`; re-stamp with `--fix` and stage `typst/generated/status.typ` only if drift is reported.

**Timing**: 1.5 hours

**Depends on**: 2

**Verification Tier**: local

**Scope Hypothesis**: Two new enabler twins suffice for this cluster, on the hypothesis that `isTotal_respects_iff_adjacent`'s only binder-dependent callee is `respects_of_isStepPath` (read at plan time from its source body at `IntNormalForm.lean` ~414-420). Confirm at implementation time by compiling the twin: any further binder-dependent callee surfaces as an unsolved instance goal, and each one found needs its own binder-free form added in this same phase.

**Tier Justification**: `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths (verified at plan time), so no Gate 8 suite covers them; the covering checks are `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic.ZTime` (which pulls `IntNormalForm` transitively, and every change here is either additive or a proof-term-only change to a `Prop`-valued theorem, so no unfolding behaviour leaves the module) and `bash scripts/check-module-invariants.sh`.

**Files to modify**:
- `FormalSystem/Semantics/IntNormalForm.lean` - adds two binder-free enabler twins; reduces the two originals to delegating corollaries; four marker lines
- `FormalSystem/Semantics/Nomic/ZTime.lean` - corrects the binder-carrying site's marker; re-points its body at the new twin; rewrites the ~132 rationale paragraph
- `FormalSystem/README.md` - regenerated inventory block
- `README.md` - regenerated inventory block
- `typst/generated/status.typ` - re-stamped only if `typst-sync-check.sh --counts-only` reports drift

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0; `PASS C34a` lists `mem_lawHist_iff_isStepPath` under delegation.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Nomic.ZTime` succeeds (exit status checked).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `grep -n sorry` over both touched files is empty.

---

### Phase 4: `Presheaf/Behavior.lean` -- the binder-free germ constructor [NOT STARTED]

**Goal**: Land `Beh.ofGerm_of_serial_limit`, the enabler the whole `Presheaf/Path.lean` cluster
routes through, and reduce `Beh.ofGerm` to a delegating definition.

**Tasks**:
- [ ] Establish which binder-free nullity route is actually available at `TaskFrame` level: `FrameOver.nullity_identity_of_serial_limit` is confirmed present at `FormalSystem/Semantics/TaskFrame.lean:1323` taking `TaskFrame.Serial F.TaskRel` and `TaskFrame.Limit F.TaskRel`. If no `TaskFrame`-level wrapper exists, route through `F.toFibre` explicitly rather than adding a new lemma.
- [ ] Add `Beh.ofGerm_of_serial_limit (F : TaskFrame) (hser : TaskFrame.Serial F.TaskRel) (hlim : TaskFrame.Limit F.TaskRel) (w : F.WorldState) : Beh F 0`, the body of `ofGerm` with `(F.nullity_identity w w).mpr rfl` replaced by the binder-free route; mark it `Constraints consumed: Seriality, Limit`.
- [ ] Reduce `Beh.ofGerm` to `Beh.ofGerm_of_serial_limit F F.serial F.limit w`, signature byte-identical, and give it the identical marker.
- [ ] Confirm `Beh.germ_ofGerm` and `Beh.ofGerm_germ` still close by `rfl` / their existing proofs after the indirection; if either breaks, invert the direction (keep `ofGerm`'s body as the real definition and prove the twin equal to it) and record the inversion in place.
- [ ] Verify the twin's span names `IsRegular` nowhere.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` and stage the regenerated ancestor-chain READMEs, including the `Presheaf/` one.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only`; re-stamp with `--fix` and stage `typst/generated/status.typ` only if drift is reported.

**Timing**: 1.0 hours

**Depends on**: 3

**Verification Tier**: interface

**Tier Justification**: `Beh.ofGerm` is a `def`, so adding an indirection layer changes its unfolding behaviour for every `rfl`/`simp` proof downstream, which no single-module check covers; `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths (verified at plan time), so the covering check is a build of the changed module plus its four enumerated direct dependents (`Presheaf/Sheaf.lean`, `Presheaf/Ray.lean`, `Presheaf/Reflection.lean`, `Presheaf/Directed.lean`) via `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf`, plus `bash scripts/check-module-invariants.sh`.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Behavior.lean` - adds the binder-free germ constructor and reduces the original to a delegating definition; both carry the Seriality plus Limit marker
- `FormalSystem/Semantics/Presheaf/README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block
- `README.md` - regenerated inventory block
- `typst/generated/status.typ` - re-stamped only if `typst-sync-check.sh --counts-only` reports drift

**Verification**:
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf` succeeds, covering `Behavior.lean` and all four of its direct dependents plus the `Presheaf.lean` aggregator (exit status checked).
- `bash scripts/check-module-invariants.sh` exits 0.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `grep -n sorry` over the touched file is empty.

---

### Phase 5: `Presheaf/Path.lean` cluster A -- identity and category structure [NOT STARTED]

**Goal**: Correct the eight over-reporting sites that carry the category structure of `Path(F)`,
each with its own binder-free twin plus a delegating corollary.

**Tasks**:
- [ ] Add `PathHom.id_of_serial_limit` taking `hser`/`hlim` explicitly and building on `Beh.ofGerm_of_serial_limit`; mark it `Constraints consumed: Seriality, Limit`. Reduce `PathHom.id` to a delegating one-liner with the identical marker.
- [ ] Correct `PathHom.id_len` to `Seriality, Limit` with its own binder-free twin plus delegating corollary.
- [ ] Correct `PathHom.id_comp` and `PathHom.comp_id` to `Compositionality, Seriality, Limit`, each with a twin taking `hcomp`/`hser`/`hlim` and using `hcomp` in place of `F.comp` and the `id` twin in place of `PathHom.id F w`.
- [ ] Correct `PathCat.instCategory`, `PathCat.len`, `PathCat.len_map` and `PathCat.len_isDiscreteConduche` to `Compositionality, Seriality, Limit`, each with its own twin plus delegating corollary.
- [ ] For each pair, write the twin's marker and the corollary's marker as one copy-paste so `delegates()`' list-identity match cannot drift, and verify no twin's span names `IsRegular`.
- [ ] Raise `set_option linter.style.longFile` at `Path.lean` line ~258 to the next admissible baseline above the file's new length -- see "Long-file ceiling arithmetic" above; the file enters this phase at 1,554 lines against a recorded 1700.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` and stage the regenerated ancestor-chain READMEs, including the `Presheaf/` one.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only`; re-stamp with `--fix` and stage `typst/generated/status.typ` only if drift is reported.

**Timing**: 2.0 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: 8 sites in this cluster, taken from `reports/01_constraints-consumed-marker-audit.md`'s 28-row table (the `Path.lean` rows at ~422, ~450, ~459, ~491, ~706, ~720, ~729, ~908), each needing one twin. Confirm at implementation time by re-grepping `Path.lean` for the full-four marker string and matching against this list before editing; a site whose body already names an identically-marked binder-free declaration needs a marker edit only, no twin.

**Tier Justification**: `PathHom.id` and `PathCat.instCategory` are `def`s and an `instance`, so the added indirection changes unfolding and instance resolution for anything downstream; `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths (verified at plan time), so the covering check is `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf`, which builds `Path.lean` plus its one enumerated direct dependent `FormalSystem/Semantics/Presheaf.lean`, together with `bash scripts/check-module-invariants.sh`.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - adds eight binder-free twins; reduces eight originals to delegating corollaries; sixteen marker lines; raises the recorded long-file baseline
- `FormalSystem/Semantics/Presheaf/README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block
- `README.md` - regenerated inventory block
- `typst/generated/status.typ` - re-stamped only if `typst-sync-check.sh --counts-only` reports drift

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0; `PASS C34a` attributes all eight corrected sites to the delegation group.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf` succeeds (exit status checked).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `grep -n sorry` over the touched file is empty.

---

### Phase 6: `Presheaf/Path.lean` cluster B -- windows, `toPath`, and the three `None` sites [NOT STARTED]

**Goal**: Correct the eight sites in the adjacent-window and `toPath` cluster, including the three
whose honest marker is `None` and whose binder may be removable outright.

**Tasks**:
- [ ] Correct `Beh.ofAdjacentWindow`, `Beh.ofAdjacentWindow_states` and `beh_int_iff_adjacent_window` to `Compositionality, Seriality, Limit`, each with a binder-free twin plus delegating corollary.
- [ ] For each of `PathHom.toPathAux`, `PathHom.toPath` and `PathHom.toPath_length` (probe hits: none), run the transplant probe first -- replace `[F.IsRegular]` with no binder in a scratch copy and compile -- to decide whether the binder is removable or is still needed to elaborate a sibling instance argument. The probe proves the constraints are not *consumed*; it does not prove the binder is removable, which is why this step is a probe and not an assumption.
- [ ] Where the probe passes, delete the binder and set the marker to `Constraints consumed: None` (route 1: no binder means C34a's `omitted` set is empty). Where it fails, fall back to route 2 (twin plus delegating corollary, marker `None` on both) and record the fallback in place.
- [ ] Correct `PathHom.toPath_id` to `Seriality, Limit` and `PathHom.toPath_comp` to `Compositionality, Seriality, Limit`, each with its own twin plus delegating corollary.
- [ ] Rewrite the rationale paragraph at `Path.lean` (~1168), which states "the marker lists the whole bundle the binder supplies", to the `REFERENCE_NORMAL_FORM.md` reading.
- [ ] Verify no new twin's span names `IsRegular`.
- [ ] Raise `set_option linter.style.longFile` to the next admissible baseline above the file's new length if this phase's growth crosses the baseline Phase 5 left in place.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` and stage the regenerated ancestor-chain READMEs, including the `Presheaf/` one.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only`; re-stamp with `--fix` and stage `typst/generated/status.typ` only if drift is reported.

**Timing**: 2.0 hours

**Depends on**: 5

**Verification Tier**: interface

**Scope Hypothesis**: 8 sites in this cluster (the `Path.lean` rows at ~1081, ~1107, ~1119, ~1163, ~1196, ~1205, ~1230, ~1242 in the research report's 28-row table), of which 3 are route-1 binder-deletion candidates. Confirm at implementation time by re-grepping for the full-four marker string and by running the transplant probe on each of the three candidates; a failed probe moves that site to route 2 within this same phase rather than deferring it.

**Tier Justification**: deleting a binder from `PathHom.toPathAux`/`toPath` changes those declarations' signatures, and `toPath` is a `def` whose unfolding downstream proofs may rely on, so neither a diff read nor a single-module build covers it; `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths (verified at plan time), so the covering check is `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf` over `Path.lean` plus its one direct dependent, together with `bash scripts/check-module-invariants.sh`.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - five binder-free twins; three binder deletions (or route-2 fallbacks); eight corrected marker lines; the ~1168 rationale paragraph rewritten
- `FormalSystem/Semantics/Presheaf/README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block
- `README.md` - regenerated inventory block
- `typst/generated/status.typ` - re-stamped only if `typst-sync-check.sh --counts-only` reports drift

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0; the three `None`-marked sites appear in neither C34a violation list.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf` succeeds (exit status checked).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- Each binder deletion is justified by a recorded probe result, not by the probe's consumption verdict alone.
- `grep -n sorry` over the touched file is empty.

---

### Phase 7: `Presheaf/Path.lean` cluster C -- `ofStep`, `ofPath` and the path equivalence [NOT STARTED]

**Goal**: Correct the final five over-reporting sites in `Path.lean`, completing the 28.

**Tasks**:
- [ ] Correct `PathHom.ofStep`, `PathHom.ofPath`, `PathHom.ofPath_toPath`, `PathHom.toPath_ofPath` and `PathHom.pathEquiv` to `Compositionality, Seriality, Limit`, each with its own binder-free twin plus delegating corollary.
- [ ] Re-point each twin's body at the twins landed in Phases 5 and 6 (`PathHom.id_of_serial_limit`, the `toPath` twins) rather than at the binder-carrying originals, so no twin's span names `IsRegular`.
- [ ] Re-grep `Path.lean` for the full-four marker string and confirm zero remaining occurrences other than the docstring prose at `Presheaf/Worlds.lean:59`, which is a quotation of the form and not a marker.
- [ ] Raise `set_option linter.style.longFile` to the next admissible baseline above the file's final length.
- [ ] Run `bash scripts/check-module-invariants.sh --emit-inventory` and stage the regenerated ancestor-chain READMEs, including the `Presheaf/` one.
- [ ] Run `bash scripts/typst-sync-check.sh --counts-only`; re-stamp with `--fix` and stage `typst/generated/status.typ` only if drift is reported.

**Timing**: 1.5 hours

**Depends on**: 6

**Verification Tier**: interface

**Scope Hypothesis**: 5 sites remain in `Path.lean` after Phases 5 and 6 (the rows at ~1435, ~1453, ~1467, ~1528, ~1545 in the research report's 28-row table), bringing `Path.lean`'s total to 20 and the plan's to 28. Confirm at implementation time with a fresh `grep -c "Constraints consumed: Compositionality, Seriality, Limit, Saturation"` over `Path.lean`, which must read 5 before this phase and 0 after.

**Tier Justification**: `PathHom.ofStep` and `PathHom.ofPath` are `def`s and `pathEquiv` is an equivalence built from them, so the added indirection changes unfolding downstream; `suite_selection_select` returns `__FULL_SWEEP__` for this phase's paths (verified at plan time), so the covering check is `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf` over `Path.lean` plus its one direct dependent, together with `bash scripts/check-module-invariants.sh`.

**Files to modify**:
- `FormalSystem/Semantics/Presheaf/Path.lean` - five binder-free twins; five originals reduced to delegating corollaries; ten marker lines; the long-file baseline finalized
- `FormalSystem/Semantics/Presheaf/README.md` - regenerated inventory block
- `FormalSystem/README.md` - regenerated inventory block
- `README.md` - regenerated inventory block
- `typst/generated/status.typ` - re-stamped only if `typst-sync-check.sh --counts-only` reports drift

**Verification**:
- `bash scripts/check-module-invariants.sh` exits 0.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build FormalSystem.Semantics.Presheaf` succeeds (exit status checked).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0.
- `grep -c` for the full-four marker string in `Path.lean` reads 0.
- `grep -n sorry` over the touched file is empty.

---

### Phase 8: Re-derive the C34a counts, update the two specification documents, full gate [NOT STARTED]

**Goal**: Replace the stale C34a discharge-group counts in the two prose documents with figures
re-derived from the gate's own output, re-run the classification probe over all 68 sites, and
close the task on the complete gate set.

**Tasks**:
- [ ] Run the C34 block and capture its `PASS C34a` line verbatim; take the three discharge-group counts from that line rather than computing them by hand.
- [ ] Update the C34a/C34b row in `docs/development/MODULE_INVARIANTS.md` with the re-derived counts.
- [ ] Update the corresponding counts in `docs/development/REFERENCE_NORMAL_FORM.md`, and confirm its "What the line claims" and "Consumption is not elimination" sections still read correctly against the corrected tree (they are the authority this work applied; they should need no change).
- [ ] Re-run `specs/evidence/constraints-consumed-marker-audit/marker-consumption-probe.lean` via `lake env lean` against the rebuilt olean set and confirm every one of the 68 markers now matches its declaration's transitive hit set -- including that none of the 40 accurate sites moved.
- [ ] Confirm the 40 accurate sites are untouched: `git diff` over the whole task's commits shows no marker-line change in `NomicLanguage/`, `Nomic/Uniformity.lean`, `Nomic/Recovery.lean`, `Extension/`, `Presheaf/Directed.lean`, `Presheaf/Worlds.lean`, `Correspondence/RigidityReal.lean`, `Validity.lean`, or `ConeUnravelling.lean`'s three accurate rows.
- [ ] Run `bash scripts/typst-sync-check.sh --fix` and stage `typst/generated/status.typ` if drift is reported.
- [ ] Run the complete gate set.

**Timing**: 1.0 hours

**Depends on**: 7

**Verification Tier**: full

**Scope Hypothesis**: the two prose documents each state the C34a counts once, carried from `reports/01_constraints-consumed-marker-audit.md`'s observation that both say 7/18/2 while a live run said 62/22/2 at research time. Both figures are CARRIED-UNVERIFIED at plan time and deliberately not re-derived here: the post-correction counts cannot be known until Phases 1-7 land. Confirm at implementation time by grepping each document for every occurrence of the group counts before editing, and by taking the new figures from the gate's own `PASS C34a` line.

**Files to modify**:
- `docs/development/MODULE_INVARIANTS.md` - C34a/C34b row's discharge-group counts re-derived from the gate output
- `docs/development/REFERENCE_NORMAL_FORM.md` - the same counts where it restates them
- `typst/generated/status.typ` - re-stamped if `typst-sync-check.sh` reports drift

**Verification**:
- `bash .claude/scripts/verify-deploy.sh` -- the complete gate set, run in full with no `--skip-slow` and no `--only-gate` narrowing, exit status checked.
- `bash scripts/check-module-invariants.sh` exits 0 with `PASS C34`, `PASS C34a` and `PASS C34b`.
- `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project, final verification) succeeds.
- `bash scripts/typst-sync-check.sh` (all four checks) exits 0.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0, confirming every ancestor-chain README inventory block is in sync with the tree's final line counts.
- The probe re-run reports 0 mismatches across all 68 sites.
- `grep -rn "Constraints consumed: Compositionality, Seriality, Limit, Saturation" FormalSystem/` returns exactly the 40 accurate sites plus the one `Presheaf/Worlds.lean` prose quotation -- 41 lines, down from 69.
- No `sorry` and no new axiom anywhere in the task's diff.

---

## Lean Challenge Statements

The four enabler twins whose statements are fixed at plan time, in one fenced block so the
assembled Challenge module carries its imports and namespace nesting intact (the snapshot tool
concatenates multiple blocks in document order and keeps only the first block's header, which
would strand the later declarations). The block imports the three modules that will contain the
declarations, so it type-checks standalone at snapshot time -- before any of them lands. The ~19
per-site twins in Phases 5-7 are deliberately not
pinned here: each is a mechanical restatement of an existing declaration -- its signature is the
original's with `[F.IsRegular]` replaced by the explicit `TaskFrame.Compositional`/`Serial`/`Limit`
hypotheses the corrected marker names -- and pinning a signature not read at plan time would be
fabrication, not a contract. See `## Decisions`.

The germ constructor's return type is written `Presheaf.Beh F 0` because the snapshot tool
flattens inner `namespace` blocks out of the assembled module; the declaration itself lands
inside `FormalSystem.Semantics.Presheaf.Beh`, where the same type is spelled `Beh F 0`. The block
below was compiled against this project's own toolchain during plan authoring
(`lean-challenge-snapshot.sh 908 . --dry-run --compile` reports `compile: OK`), so all four
signatures are verified, not asserted.

```lean
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.Semantics.ConeUnravelling
import FormalSystem.Semantics.Presheaf.Behavior

namespace FormalSystem.Semantics

namespace FrameOver

theorem respects_of_isStepPath_of_constraints {F : FrameOver intOrder}
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) {f : ℤ → F.WorldState}
    (h : IsStepPath F f) (s t : ℤ) : F.TaskRel (f s) (t - s) (f t) := sorry

theorem isTotal_respects_iff_adjacent_of_constraints (F : FrameOver intOrder)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (f : ℤ → F.WorldState) :
    (∀ s t : ℤ, F.TaskRel (f s) (t - s) (f t)) ↔ IsStepPath F f := sorry

end FrameOver

theorem base_taskRel_eq_ofStepRel_of_constraints (F : FrameOver intOrder)
    (hcomp : TaskFrame.Compositional F.TaskRel) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) : F.TaskRel = ofStepRel F.step := sorry

def ofGerm_of_serial_limit (F : TaskFrame) (hser : TaskFrame.Serial F.TaskRel)
    (hlim : TaskFrame.Limit F.TaskRel) (w : F.WorldState) : Presheaf.Beh F 0 := sorry

end FormalSystem.Semantics
```

## Decisions

- **Route 2 (binder-free twin plus delegating corollary) is the default**, applied at every
  binder-carrying corrected site. It is the pattern of record named in `REFERENCE_NORMAL_FORM.md`,
  it is already instantiated in the tree, it keeps every public signature byte-identical so no
  call site moves, and it is the one route structurally guaranteed to satisfy C34a's `delegates()`
  predicate -- which matches on an identifier named in the row's *own* body carrying an
  *identical* marker and mentioning no bundling class.
- **Route 1 (binder deletion) is used only for the three `None` sites**, and only after a
  transplant probe confirms the binder is not needed for elaboration. The probe's consumption
  verdict is not evidence of removability; these are different questions.
- **Route 3 (unbundle in place) is a fallback only**, taken with an explicit in-phase note. It is
  honest and gate-clean but moves call sites, which route 2 avoids.
- **The specification wins over the three in-source rationales.** `REFERENCE_NORMAL_FORM.md` is
  the named authority for the marker form and defines it as what the elaborated proof term
  reaches; an at-site docstring is not a competing authority. All three paragraphs are rewritten.
- **The phase chain is fully sequential** despite Phases 1, 2 and 4 being logically independent:
  every `.lean`-touching phase carries `typst/generated/status.typ`, so parallel execution would
  contend for that one file.
- **`Path.lean`'s 20 sites are split across three phases**, not one, because the plan's phase
  ceiling is two hours and twenty twins do not fit inside it.
- **Only four Lean goals are pinned** in `## Lean Challenge Statements`. The per-site twins in
  Phases 5-7 derive their signatures mechanically from the originals they restate, and writing a
  pinned signature for a declaration whose source was not read at plan time would be fabrication.
  The four pinned enabler twins are the ones whose originals were read in source during plan
  authoring, so their statements are contracts rather than guesses.
- **No side-attributing marker form is used.** `source: ...; base: none` is inadmissible, and
  every corrected marker here is a plain sublist of the closed vocabulary.

## Testing & Validation

- [ ] `bash scripts/check-module-invariants.sh` exits 0 at every phase boundary, with `PASS C34`,
      `PASS C34a` and `PASS C34b` present. A full `lake build` covers none of the three.
- [ ] `bash .claude/scripts/lake-build-guard.sh build --timeout 1800 -- build` (full project)
      succeeds at Phase 8.
- [ ] `bash .claude/scripts/verify-deploy.sh` (complete gate set, unnarrowed) exits 0 at Phase 8.
- [ ] `bash scripts/typst-sync-check.sh` (all four checks) exits 0 at Phase 8.
- [ ] The retained probe at `specs/evidence/constraints-consumed-marker-audit/marker-consumption-probe.lean`
      re-runs clean: every one of the 68 markers matches its declaration's transitive hit set.
- [ ] The 40 accurate sites are byte-identical to their pre-task state.
- [ ] Zero `sorry`, zero new axiom, zero vacuous placeholder anywhere in the task's diff.

## Artifacts & Outputs

- Corrected marker lines at 28 sites across 6 files: `FormalSystem/Semantics/Nomic/Witnesses.lean`,
  `FormalSystem/Semantics/Nomic/ZTime.lean`, `FormalSystem/Semantics/ConeUnravelling.lean`,
  `FormalSystem/Semantics/Presheaf/Path.lean`, plus marker lines on the new twins in
  `FormalSystem/Semantics/IntNormalForm.lean` and `FormalSystem/Semantics/Presheaf/Behavior.lean`.
- Three enabler twins (`respects_of_isStepPath_of_constraints`,
  `isTotal_respects_iff_adjacent_of_constraints`, `Beh.ofGerm_of_serial_limit`) and roughly
  nineteen per-site twins, each with its binder-carrying original reduced to a one-line corollary.
- Three rewritten in-source rationale paragraphs.
- Re-derived C34a discharge-group counts in `docs/development/MODULE_INVARIANTS.md` and
  `docs/development/REFERENCE_NORMAL_FORM.md`.
- Re-stamped `typst/generated/status.typ`.
- `specs/908_constraints_consumed_marker_accuracy_audit/summaries/01_constraints-consumed-marker-corrections-summary.md`
  at completion.

## Rollback/Contingency

Each phase is one commit over a disjoint, declared file set, so reverting a single phase is a
`git revert` of that commit with no cross-phase entanglement -- except for the twin chains, where
a later phase's twins call an earlier phase's: reverting Phase 4 or 5 therefore requires reverting
the later `Path.lean` phases first, in reverse order.

A phase that cannot be completed as written on a `.lean` file is marked `[BLOCKED]` and raised,
per `rules/plan-compliance.md` -- the sanctioned deviation mechanism does not apply to `.lean`
files, so no silent substitution of a different route.

If a rollback must discard uncommitted work rather than revert a commit, take the snapshot first
per `context/contracts/recovery.md`'s rollback rung, which carries the exact invocation shape
including its out-of-scope override flag; do not emit a bare precautionary snapshot as a
start-of-phase checkpoint. For an ordinary defensive checkpoint before a risky twin
restructuring, use `bash .claude/scripts/git-snapshot.sh 908 --no-revert`, which is durable
without reverting the working tree.

Worst case, the whole task reverts cleanly: every change is additive (new twins) or confined to a
docstring line and a one-line proof body, with no public signature altered outside the three
probe-confirmed binder deletions in Phase 6.
