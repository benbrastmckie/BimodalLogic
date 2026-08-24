# Implementation Plan: Task #469

- **Task**: 469 - eliminate the bridge: filtration into IntPresentation
- **Status**: [IMPLEMENTING]
- **Effort**: 5.5 hours
- **Dependencies**: 470 (recorded in `state.json`; already terminal)
- **Research Inputs**: `specs/469_eliminate_the_bridge_filtration_into_intpresentation/reports/01_eliminate-the-bridge-verdict.md`
- **Artifacts**: plans/01_capture-verdict-and-followups.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The research dispatch already discharged every deliverable this task owes as *findings*: the
verdict (PROVABLE-HARD, with the bridge eliminated rather than proved), the constructive-line
accounting per half, the cost comparison against the tableau route, the §4(e) wiring statement,
and three separated follow-up specs. Two probes were compiled sorry-free under `evidence/`.

What remains is **capture, not discovery**. This task exists because a landed, sorry-free asset
(`Decidability/BiLasso/`) was invisible to a prior audit and to `ROADMAP.md`, so the project
priced decidability at "several person-years" while the asset sat unwired. A verdict that lives
only in `specs/469_…/reports/` reproduces exactly that failure mode. So the implementation phase
writes the load-bearing findings into the docstrings of the symbols they are about — every one of
which is inside the declared `file_scope` — and creates the three follow-up tasks that carry the
work forward. **No proof, statement, signature, or import changes anywhere.**

### Research Integration

Five findings from the report are load-bearing here and each gets a docstring home:

1. `filteredCharacteristicSet` lands in `Set (subformulaClosure φ)`, **not** `Finset`; both
   `subformulaClosure`-side finiteness and `FilteredWorld.finite` are `noncomputable`. The
   existing filtration world-space is therefore *not* already data-shaped — the review's stated
   ground for the cheap route is factually wrong (report §2 Gap 3, Correction A; §9.2).
2. Over ℤ the four `def:frame` axioms cost **exactly one obligation** (bi-seriality), because
   `TaskFrame.ofStep` discharges all seven `TaskFrame` fields; the "multi-month re-discharge"
   figure applies only to `D`-polymorphic frames (report §2 Correction B; §9.3).
3. `IntPresentation.val : Atom → Fin card → Bool` is a function on an `Infinite` type, so
   presentations cannot be enumerated at a cardinality bound; the formula-indexed candidate-list
   shape sidesteps this (report §9.5).
4. ℤ instantiates the entire `ValidDiscrete` binder bundle with **zero** instance work, so the
   soundness direction is free; only the completeness direction needs carrier normalization
   (report §4.1, §2 Gap 1).
5. The `Classical.choice` objection in `PeriodicExtension.lean` is scoped to *emitting an
   evaluable certificate*; it does not transfer to a setting where the classically produced
   presentation is only quantified over, never evaluated (report §3.3).

`FMP/` is confirmed syntactic (zero `TruthAt` across all six files) and contributes only
cardinality bookkeeping — recorded so "rebuild the filtration" is never mistaken for a refactor
of `FMP/`.

### Prior Plan Reference

No prior plan. `plans/` was empty at dispatch.

### Roadmap Alignment

`specs/ROADMAP.md` was not supplied in the delegation context and is **not** in this task's
declared `file_scope`. Measured: it mentions `BiLasso` zero times. Adding it is assigned to
follow-up task A (§Phase 5), which also owns the `Decidability.lean` import and the manifest
edit — the three belong in one commit per the manifest's own block comment. This plan does not
touch `ROADMAP.md`.

## Goals & Non-Goals

**Goals**:

- Re-confirm, at implementation time, every fact this plan asks the implementer to quote — none
  is carried forward as trusted.
- Write the five load-bearing findings into the docstrings of the symbols they concern, inside
  the declared `file_scope`, as comment-only edits.
- Record in `PeriodicExtension.lean`'s module doc that its `Classical.choice` objection is scoped
  to certificate emission — **without touching any of its theorems**.
- Create the three follow-up tasks (wiring; carrier normalization; the box-faithful small-model
  theorem) with their classification stated honestly and their dependency edges wired.
- Leave the build, the sorry count, and every module invariant exactly as found.

**Non-Goals** (each one is a scope boundary, not an oversight):

- **Do not prove `fmp`** — `¬ ValidDiscrete φ → ∃ P ∈ cands φ, ∃ w, SatAtState P w φ.neg`. The
  report classifies its crux (box-faithfulness) as OPEN MATHEMATICS, multi-month. It is
  follow-up task C and must not be started here under any framing.
- **Do not wire `BiLasso` into the live tree.** Wiring requires editing
  `FormalSystem/Metalogic/Decidability.lean` and `scripts/module-invariants-manifest.txt`, and
  **neither is in this task's declared `file_scope`**. The report recommends wiring "now"; this
  plan honours that by making it follow-up task A with `effort: small` and no dependencies, so it
  is immediately actionable — rather than by silently widening this task's file scope. If the
  orchestrator wants it inside 469, that is a scope decision to make explicitly.
- **Do not land the two `evidence/` probes as live theorems.** Same reason: they need a new module
  under `BiLasso/` plus a manifest line, and the manifest is out of scope. Assigned to task A.
- Do not edit the tableau tree (`Decidability/Verified/`), `ROADMAP.md`, or `specs/reviews/`.
- Do not change any `theorem`, `def`, `instance`, `structure`, or `import` line anywhere.
- Do not restate 468's "several person-years" as a measurement — the report is explicit that it
  is a judgment. Any docstring that mentions it must mark it as such or omit it.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A docstring cites "task A"/"task 474"/"task N" inside `FormalSystem/**` | H | H | `.claude/rules/no-task-references-in-deliverables.md` applies (only `specs/**` is exempt) and `hooks/validate-no-task-references.sh` is a **blocking** write-time gate — the write will simply fail. Cite durable anchors only: symbol names (`archimedean_of_lub`, `TaskFrame.ofStep`), file names, `check-module-invariants.sh` check IDs. Phase 6 runs `scripts/check-task-references.sh` as an explicit gate. |
| A comment edit breaks Lean elaboration (unbalanced `/-` … `-/`, a `/--` doc-comment detached from its declaration) | H | M | Per-file `lake build` of the touched module immediately after each edit (tier `local`), before moving to the next file. Never batch two files before a build. |
| The implementer drifts into proving the residue because the shape is now written down | H | M | Phase-level prohibition restated in Phases 2–4; Phase 6 gate asserts `git diff` contains zero non-comment hunks under `FormalSystem/**`. |
| `PeriodicExtension.lean`'s existing theorems get "improved" | M | L | Explicit task-description non-goal. Phase 4 is isolated precisely so its diff can be inspected alone; the phase's verification requires the diff be confined to the module docstring block. |
| Follow-up task numbers hardcoded and drift under concurrent task creation | M | M | Read `next_project_number` from `specs/state.json` at implementation time; never hardcode 474/475/476. Recorded as this plan's Scope Hypothesis on Phase 5. |
| `state.json` corrupted by a hand-rolled read-modify-write | H | L | All mutations go through `.claude/scripts/state-write.sh` (the single mutex-guarded writer) with `--regen-todo`; `validate-state.sh` afterward. |
| Duplicating prose that a file already carries | L | H | `IntNormalForm.lean` already carries the binder-fit finding verbatim and the report confirms it correct. Every phase greps for the finding before adding it and extends rather than duplicates. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4, 5 | 1 |
| 3 | 6 | 2, 3, 4, 5 |

Phases within the same wave can execute in parallel. Wave 2's four phases hold **disjoint file
territories**: Phase 2 owns three top-level `Semantics/` files, Phase 3 owns `Decidability/`,
Phase 4 owns `Semantics/Extension/PeriodicExtension.lean` alone, Phase 5 owns `specs/` only.

---

### Phase 1: Re-verify every fact this plan asks to be quoted [COMPLETED]

**Goal**: No claim reaches a docstring on the strength of the report alone. Re-run the checks and
record the results; if any check disagrees with the report, stop and report the divergence rather
than writing the report's version.

**Tasks**:
- [x] `scripts/check-module-invariants.sh --no-build` — record C2/C3/C6 pass state and the current
      structural-sorry inventory (expected: the sole sorry is `countermodel_discrete` in
      `WeakCanonical/Transfer.lean`).
- [x] `grep -rc TruthAt FormalSystem/Metalogic/Decidability/FMP/*.lean` — expect 0 in all six.
- [x] Read `FMP/FiniteModel.lean` at `filteredCharacteristicSet` and confirm its codomain is
      `Set (subformulaClosure phi)`, and that `FilteredWorld.finite` / the ambient finiteness
      instance are `noncomputable`.
- [x] Read `IntNormalForm.lean` at `TaskFrame.ofStep` and confirm the seven-field source table in
      its docstring, and that `serial` is the sole genuine obligation.
- [x] Read `IntPresentation.lean` at `structure IntPresentation` and confirm `val`'s type is
      `Atom → Fin card → Bool`; confirm `Atom` carries an `Infinite` instance.
- [x] Read `Validity.lean` at `ValidDiscrete` and record its exact binder bundle.
- [x] Enumerate the theorems of `DurationClassification.lean` and confirm no successor-based
      analogue of `archimedean_of_lub` exists.
- [x] Re-compile both probe files under `evidence/` with `lake env lean` and re-measure
      `#print axioms` on `not_validDiscrete_of_satAtState` and `validDiscrete_iff_checkFamily`.
- [x] `grep -v '^#' scripts/module-invariants-manifest.txt` and `grep '^import'
      FormalSystem/Metalogic/Decidability/BiLasso.lean` — confirm the 20 / 14 split the follow-up
      spec in Phase 5 depends on.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: This phase asserts specific counts inherited from the research report — six
`FMP/` files with zero `TruthAt`; 20 manifest entries in the BiLasso block; 14 imports in
`BiLasso.lean`, giving a 15-delete / 4-keep / 1-separate split; exactly one structural sorry
tree-wide; axiom set `[propext, Classical.choice, Quot.sound]` on both probes. Confirm each by
re-running the command named beside it. A divergence is a finding to report, not a number to
quietly adjust in the plan.

**Files to modify**: none (read and verify only).

**Phase 1 record** (measured 2026-08-24, tree at `3ff158bad`):

| Check | Command | Result |
|---|---|---|
| Structural sorries | `scripts/check-module-invariants.sh --no-build` | C3 PASS — sole sorry is `countermodel_discrete` (`WeakCanonical/Transfer.lean`). C6 PASS — 37 unreachable live modules, all manifested. C1/C2 skipped under `--no-build`. B0, C4, C5, C7–C10 PASS. |
| `TruthAt` in `FMP/` | `grep -rc TruthAt FormalSystem/Metalogic/Decidability/FMP/*.lean` | **0 in all six** files (`FiniteModel`, `ClosureMCS`, `Periodicity`, `TruthPreservation`, `Filtration`, `FMP`) |
| `filteredCharacteristicSet` codomain | read `FMP/FiniteModel.lean` | `Set (subformulaClosure phi)` — **not** `Finset`. `set_finite` and `FilteredWorld.finite` are both declared `noncomputable`. Report §2 Correction A **confirmed**. |
| `TaskFrame.ofStep` seven-field table | read `Semantics/IntNormalForm.lean` | Table present verbatim in `ofStep`'s docstring; `serial` marked "the one genuine obligation"; `limit` from `limit_of_succOrder`, `spherical` from `spherical_of_finite`. **Confirmed.** |
| `IntPresentation.val` | read `Decidability/IntPresentation.lean` | `val : Atom → Fin card → Bool`; `toTaskFrame := TaskFrame.ofStep P.stepRel P.fwd P.bwd`. `instance : Infinite Atom` at `Syntax/Atom.lean`. **Confirmed.** |
| `ValidDiscrete` binder bundle | read `Semantics/Validity.lean` | `[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D] [Nontrivial D]`. **Confirmed.** |
| `DurationClassification.lean` theorems | symbol enumeration | Exactly three: `archimedean_of_lub`, `complete_duration_discrete_or_dense`, `complete_not_dense_iso_int`. No successor-based analogue. **Confirmed.** |
| Probe recompile | `lake env lean` on each `evidence/*.lean` | All **three** compile sorry-free; `#print axioms` measures `[propext, Classical.choice, Quot.sound]` on `not_validDiscrete_of_satAtState`, `validDiscrete_iff_checkFamily`, `decidableValidDiscreteFamily`, `validDiscrete_iff_check`, `decidableValidDiscrete`. |
| Manifest arithmetic | `grep -v '^#' scripts/module-invariants-manifest.txt`; `grep '^import' BiLasso.lean` | 37 total manifest entries. BiLasso block = 18 `BiLasso.*` submodules + the `BiLasso` aggregator = 19, plus `FormalSystem.Semantics.Extension.PeriodicExtension` = 20. `BiLasso.lean` has **14** imports. Split **15 delete / 4 keep (`Extend`, `Successor`, `Orbit`, `Agreement`) / 1 separate (`PeriodicExtension`)**. **Confirmed.** |

**Divergences from the research report**: one, immaterial. The report's §4 speaks of "two probe
files"; `evidence/` in fact holds **three** (`soundness-half-probe.lean`,
`decidability-assembly-family-probe.lean`, `decidability-assembly-probe.lean` — the last being the
single-presentation variant the report names in §4.2 without counting it). All three compile
sorry-free at the same axiom set. No measurement contradicts the report; nothing in this plan is
adjusted as a result, except that follow-up task A is told to land **three** probe files.

**Verification**:
- Every bullet above has a recorded command and result.
- Any divergence from the report is written into the phase record before Wave 2 starts.

---

### Phase 2: Capture the carrier findings in `Semantics/` [NOT STARTED]

**Goal**: A reader arriving at `ValidDiscrete`, at the ℤ-normal-form machinery, or at the duration
classification learns — without leaving the file — which direction is free, which is open, and
what the named next lemma is.

**Tasks**:
- [ ] `FormalSystem/Semantics/Validity.lean`, at the `ValidDiscrete` docstring: record that ℤ
      instantiates this entire binder bundle with no instance work, so the *soundness* direction
      (a countermodel presented over ℤ refutes `ValidDiscrete`) needs no carrier lemma at all;
      and that only the *completeness* direction needs normalization of an arbitrary `D`.
- [ ] `FormalSystem/Semantics/IntNormalForm.lean`: first grep for the existing binder-fit finding —
      it is already present and confirmed correct, so **extend, do not restate**. Add: that
      `TaskFrame.ofStep` is what makes the four `def:frame` axioms cost exactly bi-seriality over
      ℤ, and that this pricing is available only over ℤ — a `D`-polymorphic frame has neither
      `limit_of_succOrder` nor `ofStep`, which is where the much larger figure comes from.
- [ ] `FormalSystem/Semantics/DurationClassification.lean`, near `archimedean_of_lub`: record that
      this is the **Dedekind branch only**, that the successor-based analogue is absent from the
      tree, and that the missing piece is precisely `Archimedean D` plus an `IsLeast {y | 0 < y}`
      witness derived from `[SuccOrder D] [PredOrder D] [IsSuccArchimedean D] [IsPredArchimedean D]
      [Nontrivial D]`, which is what
      `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` needs. Record the wrong
      turn explicitly: `orderIsoIntOfLinearSuccPredArch` fits the bundle but yields only `≃o`, and
      durations add.
- [ ] `lake build` each of the three modules individually, immediately after its own edit.

**Timing**: 1.0 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Validity.lean` — docstring at `ValidDiscrete` only
- `FormalSystem/Semantics/IntNormalForm.lean` — module/section docstring, extending the existing
  binder-fit note
- `FormalSystem/Semantics/DurationClassification.lean` — docstring at `archimedean_of_lub` and/or
  the module doc

**Verification**:
- `git diff` for these three files shows comment/docstring hunks only — no `theorem`, `def`,
  `instance`, or `import` line changed.
- Each module builds green on its own.
- No task-number reference appears in any added line.

---

### Phase 3: Capture the representation and FMP findings in `Decidability/` [NOT STARTED]

**Goal**: The three corrections that reorder the cost model — `Set` not `Finset`, `ofStep` makes
the axioms free over ℤ, `val` is not enumerable at a bound — live at the symbols they are about,
and `FMP/`'s actual contribution is stated so it is not mistaken for FMP coverage.

**Tasks**:
- [ ] `FormalSystem/Metalogic/Decidability/FMP/FiniteModel.lean`, at
      `filteredCharacteristicSet` / `filteredCharacteristicSet_injective`: record that the codomain
      is `Set (subformulaClosure phi)`, not `Finset`, and that the surrounding finiteness is
      `noncomputable` — so this space is `Prop`-shaped and is **not** a data-shaped starting point
      for a computable presentation.
- [ ] `FormalSystem/Metalogic/Decidability/FMP/FMP.lean`, near `mcs_finite_model_property` and
      `fmp_size_bound`: record that both are Lindenbaum-plus-cardinality statements about MCS
      membership, that neither mentions a model, a history, or a time, and that a *semantic* finite
      model property therefore needs a different world space, a non-permissive relation, and a
      truth lemma — none of which is a refactor of this directory. Cite the zero-`TruthAt`
      measurement.
- [ ] `FormalSystem/Metalogic/Decidability/FMP/README.md`: same point in prose, alongside the
      existing record that `refinedFilteredTaskRel` is universal at nonzero duration.
- [ ] `FormalSystem/Metalogic/Decidability/IntPresentation.lean`: at `structure IntPresentation`,
      record that `val : Atom → Fin card → Bool` is a function on an `Infinite` type, so
      presentations are not finite objects and cannot be enumerated at a cardinality bound without
      a valuation-restriction lemma that does not exist here; the workable shape is a
      formula-indexed candidate list whose valuation is read off a closure type. At `toTaskFrame`,
      record that it is literally `TaskFrame.ofStep P.stepRel P.fwd P.bwd`, hence bi-seriality is
      the sole frame obligation.
- [ ] `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean` (module doc, alongside the existing
      "does not decide the logic" paragraph) and/or `BiLasso/README.md`: record what the layer does
      **not** do — it compresses histories *within* a given presentation, its input is already a
      presentation, so it performs no part of the finite-model step; and record the single
      remaining obligation for decidability of `ValidDiscrete` in the shape the compiled probe
      established, naming `check_correct` as the final step rather than the far side of a transfer.
      Note that `instDecidableSatAtState` computes but is **not** choice-free — its measured axiom
      set is `[propext, Classical.choice, Quot.sound]` — and that `wlem_of_spherical` proves no
      finite-carrier frame with an arbitrarily shaped relation can be choice-free.
- [ ] `lake build` each touched Lean module individually, immediately after its own edit.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/FMP/FiniteModel.lean` — docstrings only
- `FormalSystem/Metalogic/Decidability/FMP/FMP.lean` — docstrings only
- `FormalSystem/Metalogic/Decidability/FMP/README.md` — prose
- `FormalSystem/Metalogic/Decidability/IntPresentation.lean` — docstrings only
- `FormalSystem/Metalogic/Decidability/BiLasso/Check.lean` and/or `BiLasso/README.md` — docstrings
  and prose only

**Verification**:
- `git diff` under `Decidability/` shows comment/docstring/markdown hunks only.
- Each touched module builds green on its own; `BiLasso/` modules still compile in isolation as
  C6 checks them.
- No new module, no new `import`, no manifest edit — the BiLasso block stays at its measured size.
- No task-number reference in any added line.

---

### Phase 4: Scope the `Classical.choice` objection in `PeriodicExtension.lean` [NOT STARTED]

**Goal**: The module docstring's objection is correct for what it is about and misleading when read
as a general claim. Record the scope boundary — and nothing else. This phase is isolated so its
diff can be read on its own against the task's explicit "does not touch `PeriodicExtension.lean`'s
existing theorems" non-goal.

**Tasks**:
- [ ] Read the module docstring block containing the "no bridge from the first to the second"
      paragraph.
- [ ] Append a scoping note, in that block only: the objection is about *emitting an evaluable
      certificate*, where a `Classical.choice`-produced presentation is worthless because the
      object must compute. It does not bite where the classically produced presentation is only
      quantified over and never evaluated. Record the second, sharper reason: `Fin n → Fin n →
      Bool` is a `Fintype` with `DecidableEq`, so a `step` defined via `Classical.dec` is *equal*
      to one of the finitely many enumerable functions — the existential and a computable
      enumeration meet without any extraction happening. Cite the compiled probe under this task's
      `evidence/` directory by filename.
- [ ] `lake build` the module.

**Timing**: 0.5 hours

**Depends on**: 1

**Verification Tier**: local

**Files to modify**:
- `FormalSystem/Semantics/Extension/PeriodicExtension.lean` — module docstring block only

**Verification**:
- `git diff` for this file is confined to lines inside the `/-! … -/` module docstring; zero
  changes at or below any `theorem` line. Confirm by inspecting the diff hunk headers.
- Module builds green.
- The file remains unreachable and its manifest line remains present and untouched.

---

### Phase 5: Create the three follow-up tasks [NOT STARTED]

**Goal**: The three pieces of remaining work exist as tasks with their classification stated
honestly and their dependency edges wired, so nothing depends on this report being re-read.

**Tasks**:
- [ ] Read `next_project_number` from `specs/state.json`; allocate three consecutive numbers from
      it. Do not hardcode.
- [ ] **Task A — wire the BiLasso layer into the live tree.** `task_type: lean4`,
      `topic: decidability`, `effort: small`, `dependencies: []`,
      `file_scope: [FormalSystem/Metalogic/Decidability.lean,
      FormalSystem/Metalogic/Decidability/BiLasso.lean,
      scripts/module-invariants-manifest.txt, specs/ROADMAP.md]`. Classification: **routine
      engineering**. Description must carry: add one import of the re-export to
      `Decidability.lean`; delete exactly the manifest lines for the modules `BiLasso.lean` imports
      plus the aggregator's own line, in the same commit (C6 fails if a manifest entry names a
      reachable module, and the manifest's own block comment forbids doing one without the other);
      **keep** the `Extend`/`Successor`/`Orbit`/`Agreement` lines — that cluster stays unreachable;
      **keep** the `PeriodicExtension` line, which is a separate block with its own rationale and
      a separate edit. Also: land the two compiled probes from this task's `evidence/` directory as
      live theorems, and add BiLasso to `ROADMAP.md`, which currently mentions it zero times.
      Acceptance: `scripts/check-module-invariants.sh` passes C1/C2/C3/C6.
- [ ] **Task B — carrier normalization: the successor-Archimedean transfer.** `task_type: lean4`,
      `topic: semantics`, `effort: medium`, `dependencies: []`,
      `file_scope: [FormalSystem/Semantics/DurationClassification.lean,
      FormalSystem/Semantics/IntNormalForm.lean, FormalSystem/Semantics/Validity.lean]`.
      Classification: **routine engineering with one genuine lemma** — small lemma, already-written
      route, mechanical but wide transport. Description: prove the successor-based analogue of
      `archimedean_of_lub` supplying `Archimedean D` and an `IsLeast {y | 0 < y}` witness so that
      `LinearOrderedAddCommGroup.int_orderAddMonoidIso_of_isLeast_pos` applies; then transport
      `TaskFrame`, `TaskModel`, `WorldHistory`, and `TruthAt` along `D ≃+o ℤ`, yielding
      `ValidDiscrete φ` iff `φ` holds in every ℤ-frame model. Record the wrong turn:
      `orderIsoIntOfLinearSuccPredArch` is order-only. Independently valuable — a prerequisite for
      anything reasoning about the discrete class.
- [ ] **Task C — the box-faithful small-model theorem.** `task_type: lean4`,
      `topic: decidability`, `effort: large`, `dependencies: [<Task B's number>]`,
      `file_scope: [FormalSystem/Metalogic/Decidability/TypeModel/,
      FormalSystem/Metalogic/Decidability/IntPresentation.lean]`. Classification: **OPEN
      MATHEMATICS, multi-month** — the description MUST say so in those terms and MUST NOT be
      re-described as engineering or merged into A or B. Description: build
      `cands : Formula → List IntPresentation` from the closure-type space (Hintikka-condition
      subsets of `subformulaClosure φ`, `step` from `LocalCoherent`'s `untl`/`snce` unfolding
      clauses, `val p X := decide (atom p ∈ X)`), including the iterated pruning to a maximal
      serial subgraph and the `Fin card` indexing; then prove `¬ ValidDiscrete φ → ∃ P ∈ cands φ,
      ∃ w, SatAtState P w φ.neg`. The crux is box-faithfulness: `box` truth is a global constant of
      its own model (`Truth.box_const`, `Extension.occurrence`), the source model's and the target
      presentation's box facts need not agree, and restricting to realized-type subgraphs does not
      close the gap because the subshift generated by realized edges properly contains the realized
      paths. Reuse `BiLasso/GoodCycle.lean`'s fulfilment machinery and `cycleBound`. Do not promise
      a choice-free result — `wlem_of_spherical` proves that impossible. **Literature gate, to run
      first and empowered to stop the task**: acquire Gabbay, Kurucz, Wolter, Zakharyaschev,
      *Many-Dimensional Modal Logics* (2003) and read its temporal-products chapter; if the
      two-dimensional `Until`/`Since` case is recorded as undecidable or FMP-free, report the task
      as refuted rather than attempting it. Do not begin before A and B are landed.
- [ ] Write all three through `.claude/scripts/state-write.sh --session-id
      sess_1787608533_153fad_469 --regen-todo`; create their task directories under `specs/`.
- [ ] `.claude/scripts/validate-state.sh` and confirm `TODO.md` regenerated with all three and with
      `next_project_number` advanced.

**Timing**: 1.0 hours

**Depends on**: 1

**Verification Tier**: local

**Scope Hypothesis**: Three tasks, at three consecutive numbers starting from the live
`next_project_number` (474 at plan time — **verify, do not assume**; a concurrent creation moves
it). Task A's manifest arithmetic (15 delete / 4 keep / 1 separate) is Phase 1's measurement, not
this plan's assertion; carry into A's description whatever Phase 1 actually measured.

**Files to modify**:
- `specs/state.json` — via `state-write.sh` only, never by hand
- `specs/TODO.md` — regenerated, never hand-edited
- `specs/{NNN}_{SLUG}/` — three new task directories

**Verification**:
- `validate-state.sh` passes.
- `jq` shows all three entries with `status: "not started"`, correct `task_type`, `topic`,
  `effort`, `file_scope`, and C depending on B.
- Task C's description contains the phrase "OPEN MATHEMATICS" and the literature gate.
- Nothing outside `specs/` was touched by this phase.

---

### Phase 6: Final gate [NOT STARTED]

**Goal**: The tree is exactly as found except for comments, prose, and `specs/`.

**Tasks**:
- [ ] Full `lake build` — green.
- [ ] `scripts/check-module-invariants.sh` — C1/C2/C3/C6 pass; the structural-sorry inventory and
      the unreachable-module count are unchanged from Phase 1's baseline.
- [ ] `scripts/lean-sorry-census.sh` (or the C3 output) — sorry count unchanged.
- [ ] `.claude/scripts/check-task-references.sh` — no task-number reference outside `specs/**`.
- [ ] `git diff --stat` reviewed: every hunk under `FormalSystem/**` is a comment, docstring, or
      markdown change. Assert zero changed lines that begin a `theorem`, `def`, `lemma`,
      `instance`, `structure`, `abbrev`, or `import`.
- [ ] `.claude/scripts/validate-artifact.sh` on this plan.
- [ ] Confirm the two non-goals held: no edit to `Decidability.lean`, to
      `scripts/module-invariants-manifest.txt`, to `ROADMAP.md`, or to any file under
      `Decidability/Verified/`; and no theorem in `PeriodicExtension.lean` changed.

**Timing**: 0.75 hours

**Depends on**: 2, 3, 4, 5

**Verification Tier**: full

**Files to modify**: none.

**Verification**:
- All seven bullets recorded with their command output.
- Any failure blocks task completion rather than being noted and passed.

---

## Testing & Validation

- [ ] `lake build` green, whole tree.
- [ ] `scripts/check-module-invariants.sh` C1/C2/C3/C6 pass, with the same sorry inventory and the
      same unreachable-module set as the Phase 1 baseline.
- [ ] `git diff` under `FormalSystem/**` is comment/prose only — mechanically asserted, not
      eyeballed.
- [ ] `.claude/scripts/check-task-references.sh` clean.
- [ ] `.claude/scripts/validate-state.sh` clean; three new tasks present with correct dependencies.
- [ ] Both `evidence/` probes still compile sorry-free at
      `[propext, Classical.choice, Quot.sound]`.

## Artifacts & Outputs

- Docstring capture across seven `file_scope` files plus two `README.md` files.
- Three follow-up tasks in `specs/state.json` and `specs/TODO.md`, with directories.
- This plan and the research report; the three compiled probes remain under `evidence/`.
- No new Lean module, no new theorem, no import or manifest change.

## Rollback/Contingency

Every edit is comment-only and every phase commits separately, so `git revert` of a single phase
commit is a clean rollback with no proof-state consequence. `specs/` changes roll back by
reverting the `state-write.sh` commit and re-running `generate-todo.sh`.

If Phase 1 finds a measurement that contradicts the report — most consequentially, if
`filteredCharacteristicSet` turns out to land in `Finset` after all, or if the manifest arithmetic
differs — stop, record the divergence, and do not write the report's version into a docstring. A
correction to the research report is a better outcome than a docstring that ossifies a wrong fact,
which is precisely the failure this task exists to undo.
