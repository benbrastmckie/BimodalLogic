# Implementation Plan: Generalize the ZTime Decision Procedure to Finite Premises

- **Task**: 830 - Generalize `Compression.decidableValidZTime` from the empty-premise case to arbitrary finite premises
- **Status**: [IMPLEMENTING]
- **Effort**: 7.25 hours
- **Dependencies**: None
- **Research Inputs**: `specs/830_generalize_decidable_validztime_finite_premises/reports/01_generalize-finite-premise-decidability.md`, `specs/830_generalize_decidable_validztime_finite_premises/reports/01_verified-general-form.lean`
- **Artifacts**: plans/01_generalize-finite-premise-decidability.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The witness-family decision procedure currently decides `SemanticConsequenceIn FrameClass.ZTime Γ σ`
at `Γ = []` only (`decidableSemanticConsequenceNil`). Research wrote out all three enumerated
residue items in full and elaborated them sorry-free against the current tree, so this plan is a
transcription-and-siting exercise, not a derivation: the probe at
`reports/01_verified-general-form.lean` is the source text, and the work is to land it under the
live names, preserve the five pinned `φ`-indexed names as thin wrappers, and schedule the gate
collisions that a Lean line-count change forces. Done means: the general finite-premise criterion
and procedure are stated and proved sorry-free, `lake build` is green, each new headline
declaration pins to exactly `[propext, Classical.choice, Quot.sound]`, and
`scripts/check-module-invariants.sh` shows no regression against its pre-task baseline.

### Premise Re-Validation (Carried-Figure Discipline)

The dispatch carried forward the README caveat *"That residue is bounded and enumerated, and it
is unproved — the consequence-form normalization has never been written, so the general form is
not known to compile,"* with the instruction to treat residue item 1 as risk-bearing.

Checked against live state and the prior artifact during this dispatch:

- **The caveat text is still present verbatim in the tree** —
  `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md:114-129`, re-read this
  dispatch; it has not been edited since the research phase.
- **Its substance is discharged, not confirmed.** The research dispatch wrote the
  consequence-form normalization (`consequenceZTime_iff_consequenceInt`) and it compiled on the
  first attempt; all six probe declarations elaborate with zero diagnostics and four of them
  measure at exactly `[propext, Classical.choice, Quot.sound]`. Item 1 was the named risk and is
  no longer one. This plan therefore schedules the README correction (Phase 6) as required work,
  not as optional tidying.
- **One dispatch path assertion is wrong and is corrected here.**
  `FormalSystem/Metalogic/Decidability/WitnessFamily/Target.lean` does not exist (confirmed by
  directory listing this dispatch); `WitnessFamily.Target` lives in `Predicates.lean:115`. No
  phase below names the non-existent path.
- **The `[GKWZ] §6.5` / "no performance work" and "does not advance L+ Stage 1" constraints are
  carried unchanged** and appear in Non-Goals; nothing in this plan touches them.

### Research Integration

Four findings drive the phase structure:

1. Everything downstream of the entry point (`Refutes`, `refutes_of_certifies`,
   `joint_countermodel`, `exists_labelledLasso_of_history_realized`, `compressionBound`,
   `decidableCertifies`, `typeAtM`) is already stated at arbitrary `Γ Del`, so no phase touches it.
2. Residue item 2 is three lines, not a clause rewrite: `Target` is *already* general
   (`Predicates.lean:115-116`); only its discharge inside the compression theorem is
   `[]`-specific (`Family.lean:309`, `List.not_mem_nil`).
3. Residue item 3's only real obstacle was a computable universe list, solved by
   `closureList S := S.flatMap Formula.subformulas`; `Enumerate.lean` has no consumer outside
   `Assembly.lean`, so it can be generalized in place.
4. A second, four-line reduction route exists via `StrongCompleteness.lean:262`'s
   `semantic_deduction_in`, and the recorded claim that the tree lacks a context-conjunction
   deduction theorem is false as a conclusion (the literal "there is no `Context.conj`" half is
   true). Both routes land; the direct route is primary because only it yields a general-`Γ`
   criterion in the exported `WitnessFamily Γ [σ]` certificate shape.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no roadmap phases are added. The scope limit
stated in the task description stands: this strengthens the base-language result and does **not**
advance the L+ aim (`Decidable (PlusValidZTime φ)`), because `ValidZTime` is stated for
`FormalSystem.Syntax.Formula`, which carries no stability operator.

## Goals & Non-Goals

**Goals**:

- `ConsequenceInt` — the consequence analogue of `ValidInt`, the carrier quantifier collapsed to `ℤ`.
- `consequenceZTime_iff_consequenceInt` — residue item 1: the consequence-form carrier normalization.
- `candsCtx` — the computable candidate list at arbitrary `Γ Del` (residue item 3's head).
- `exists_witnessFamily_of_not_consequence` — the compression theorem at arbitrary finite premises.
- `consequence_iff_noCertifiedCandidate` — the decision criterion at arbitrary finite premises.
- `decidableSemanticConsequenceZTime` — the decision procedure, direct route.
- `decidableSemanticConsequenceZTimeReduction` — the same result via `semantic_deduction_in`.

**Non-Goals**:

- Any advance on the L+ aim. `ValidZTime` has no stability operator; nothing here reaches Stage 1.
- A usable executable. `candsCtx Γ [σ]` is at least as large as `cands φ`; [GKWZ] §6.5's
  EXPSPACE-hardness lower bound for `PTL × S5` makes the cost the literature's own. No
  performance work is filed.
- A multi-conclusion (`Del` with more than one formula) headline result. The enumeration
  generalizes in `Del` too, but `SemanticConsequenceIn` is single-conclusion, so the headline
  statements are at `Del = [σ]`. Do not add a multi-conclusion form speculatively.
- Re-deriving `decidableDerivableZTime` (already landed in `ZTimeProvability.lean:105`).
- Renaming or restating any pinned declaration: `exists_witnessFamily_of_not_validZTime`,
  `validZTime_iff_noCertifiedCandidate`, `Compression.decidableValidZTime` and
  `decidableSemanticConsequenceNil` keep their current names and statements.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `.githooks/pre-commit` blocks every `.lean`-staging commit whose `typst/generated/status.typ` counts are stale | H | H | Every phase that stages a `.lean` file runs `lake build && bash scripts/typst-sync-check.sh --fix` and stages `typst/generated/status.typ` in the same commit; the file is declared in each such phase's `Files to modify`. Deferring to a reconciliation phase is not available — the hook is blocking. |
| C26 (`check-module-invariants.sh`) flags a `def` whose last name component has a non-trailing underscore | M | H | The research-suggested name `decidableSemanticConsequenceZTime_reduction` would fail C26. Phase 5 mandates `decidableSemanticConsequenceZTimeReduction`. Every other new `def` name (`closureList`, `closureSubsetsOfCtx`, `rawLabelledLassosCtx`, `IsLabelledLassoCtx`, `boundedLassosCtx`, `candsCtx`, `ConsequenceInt`, `decidableSemanticConsequenceZTime`) is already lowerCamelCase/UpperCamelCase and clean. |
| `check-metalogic-cycles.sh` Assertion B asserts set EQUALITY, so it fails on *surplus* upward edges — a correct new import can turn it red | M | M | Phase 5 adds `import FormalSystem.Metalogic.StrongCompleteness` to `ZTimeProvability.lean`. That phase runs the script and, if the new edge is surplus, extends the allowlist in the same phase; `scripts/check-metalogic-cycles.sh` is in that phase's file scope. |
| CI builds with `--wfail`, so any linter warning is a hard failure | M | M | The probe's own measurement applies: `simp only [ConsequenceInt, not_forall]` is the correct step-0 form; adding `Classical.not_imp` draws an unused-simp-argument warning and must not be included. Each phase treats warnings and errors identically when judging green. |
| Territory collision on `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` with concurrent task 817 | M | M | Phase 6 re-reads that file immediately before editing, edits only the one `Compression/Enumerate.lean` module-table row at line ~97, and stages that file by explicit path with no directory or glob add. If a foreign uncommitted modification is observed, stop and report per the dispatch's concurrency note rather than proceeding. |
| Generalization accidentally introduces `noncomputable` on an enumeration `def` | M | L | `closureList` avoids `Finset.toList` by construction and the probe's `boundedLassosC`/`candsC` compiled as plain `def`s. No phase may add the `noncomputable` modifier to any `Enumerate.lean` declaration; Phase 1's verification checks for its absence. |
| Rename from the probe's `C` suffix to `Ctx` introduces a transcription slip | L | M | The rename is mechanical and total (`...C` → `...Ctx` on six declarations plus one instance). Phase 1 verifies by module build, not by eye. The suffix `C` is avoided deliberately: `Compression/Cycle.lean` already uses a `C` suffix (`cycleBoundC`) with an unrelated meaning. |
| `check-module-invariants.sh` reports pre-existing findings unrelated to this task | L | M | Every criterion below is stated as a delta against the pre-task baseline captured in Phase 1, never as an absolute zero or an absolute exit 0. A gate whose only failures are pre-existing and outside this task's file scope is a recorded PASS with the findings enumerated. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2, 5 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |
| 4 | 6 | 1, 2, 3, 4, 5 |

Phases within the same wave are independent in the dependency graph. **They are not in practice
parallelizable here**: every Lean-editing phase must stage the shared generated file
`typst/generated/status.typ` in its own commit (see Risks), so wave members must still run one at
a time. The wave table records dependency structure, not an execution licence.

---

### Phase 1: Generalize the enumeration in `Enumerate.lean` [COMPLETED]

**Goal**: Residue item 3. Introduce the computable context-indexed enumeration universe and the
five context-indexed enumeration declarations, and re-express the existing `φ`-indexed names as
thin wrappers with their signatures unchanged.

**Tasks**:
- [x] Capture the pre-task gate baseline for later delta comparisons: run
      `bash scripts/check-module-invariants.sh` and record its findings verbatim in the phase
      notes before making any edit. This baseline is what every later "no regression" criterion
      is measured against.
- [x] Add `closureList (S : Context) : List Formula := S.flatMap Formula.subformulas` and
      `mem_closureList : ψ ∈ closureList S ↔ ψ ∈ closureOf S`, transcribed from the probe
      (lines 59-63).
- [x] Add the context-indexed declarations, transcribed from the probe with the probe's `C`
      suffix renamed to `Ctx` throughout: `closureSubsetsOfCtx`, `closureSubsetsOfCtx_sub`,
      `mem_closureSubsetsOfCtx`, `rawLabelledLassosCtx`, `mem_rawLabelledLassosCtx`,
      `length_of_mem_rawLabelledLassosCtx`, `IsLabelledLassoCtx`, `instDecIsLabelledLassoCtx`,
      `boundedLassosCtx`, `mem_boundedLassosCtx`, `boundedLassosCtx_sound`, `candsCtx`,
      `mem_candsCtx_of_bounded`.
- [x] Re-express the five existing `φ`-indexed definitions as wrappers over the `Ctx` forms,
      leaving each signature character-for-character unchanged:
      `closureSubsetsOf φ := closureSubsetsOfCtx [] [φ]`, and likewise for `rawLabelledLassos`,
      `IsLabelledLasso`, `boundedLassos`, `cands`; re-derive `mem_cands_of_bounded` from
      `mem_candsCtx_of_bounded` rather than keeping its current proof body.
- [x] Confirm no declaration added or edited in this phase carries the `noncomputable` modifier.
- [x] Run `lake build && bash scripts/typst-sync-check.sh --fix`, stage
      `typst/generated/status.typ` with the edited `.lean` file, and commit the two together.

**Timing**: 1.5 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase assumes `Enumerate.lean`'s six enumeration declarations have no
consumer outside `Compression/Assembly.lean` (research found no other `*.lean` reference; the
`cands=` strings in `Tests/BimodalTest/Metalogic/Decidability/RegionGateProbe.lean` belong to an
unrelated `candidateGrid` probe). Confirm at implementation time with
`grep -rn 'closureSubsetsOf\|rawLabelledLassos\|IsLabelledLasso\|boundedLassos\|cands\b' --include=*.lean .`
before re-expressing any name; if a third consumer appears, keep the `φ` wrappers' signatures
unchanged regardless — that is what makes the hypothesis non-load-bearing.

**Tier Justification**: `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly`
builds the edited module together with its only one-hop dependent, which is the whole blast
radius once the `φ`-indexed signatures are preserved; `suite_selection_select` returns
`__FULL_SWEEP__` for these paths, so no shell-suite subset is claimed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Enumerate.lean` - add `closureList`/`mem_closureList` and the thirteen `Ctx` declarations; re-express the five `φ`-indexed definitions and `mem_cands_of_bounded` as wrappers
- `typst/generated/status.typ` - regenerated `formalsystem-line-count`; the pre-commit hook blocks this phase's commit otherwise

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly` exits 0 with
  zero diagnostics, warnings included (CI runs `--wfail`; a warning is a failure).
- `grep -n 'noncomputable' FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Enumerate.lean`
  returns no new match relative to the pre-edit file.
- The five `φ`-indexed signatures are byte-identical to their pre-edit form (`git diff` shows the
  change confined to each definition's body).
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before committing.
- `bash scripts/check-module-invariants.sh` reports no finding naming this phase's touched files
  that is absent from the baseline captured in this phase's first task.

---

### Phase 2: Add the consequence-form carrier normalization to `Family.lean` [COMPLETED]

**Goal**: Residue item 1 — the risk-bearing item the README caveat named. Land `ConsequenceInt`
and `consequenceZTime_iff_consequenceInt` in `Family.lean`, directly above the compression
theorem that will consume them.

**Tasks**:
- [x] Transcribe `ConsequenceInt` and `consequenceZTime_iff_consequenceInt` from the probe
      (lines 19-45) into `Family.lean`, sited immediately before the compression theorem.
- [x] Give `consequenceZTime_iff_consequenceInt` a doc comment ending in a
      `Paper: — (formalization-native; ...)` line, matching the shape at `Assembly.lean:110`, so
      the Phase 6 theorem-index row satisfies C15.
- [x] Confirm no new `import` line is needed: `truthAt_map`, `intIso`, `aligned_map` and the
      `sat_intro` macro all come from `FormalSystem.Semantics.IntTransfer`, which `Family.lean:9`
      already imports. If a build error says otherwise, stop and report rather than widening the
      `Compression/` subtree's dependency surface.
- [x] Run `lake build && bash scripts/typst-sync-check.sh --fix`, stage
      `typst/generated/status.typ` with `Family.lean`, and commit the two together.

**Timing**: 1 hour

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Tier Justification**: The phase only adds two new declarations to `Family.lean` and changes no
existing signature, so `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Family`
covers the entire blast radius; `suite_selection_select` returns `__FULL_SWEEP__` for these
paths, so no shell-suite subset is claimed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` - add `ConsequenceInt` and `consequenceZTime_iff_consequenceInt` above the compression theorem
- `typst/generated/status.typ` - regenerated `formalsystem-line-count`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Family` exits 0 with
  zero diagnostics, warnings included.
- `lake env lean` reports `#print axioms FormalSystem.Metalogic.Decidability.consequenceZTime_iff_consequenceInt`
  as exactly `[propext, Classical.choice, Quot.sound]`.
- `git diff FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` shows no
  change to the module's `import` block.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before committing.

---

### Phase 3: Generalize the compression theorem [COMPLETED]

**Goal**: Residue item 2 plus the compression theorem at arbitrary `Γ`. Land
`exists_witnessFamily_of_not_consequence`, and keep the pinned
`exists_witnessFamily_of_not_validZTime` with its current statement by deriving it from the
general form.

**Tasks**:
- [x] Add `exists_witnessFamily_of_not_consequence` to `Family.lean`, transcribed from the probe
      (lines 186 onward), with a doc comment carrying a `Paper: —` line for C15.
- [x] Apply the two edits the research measured, and no others: step 0 becomes
      `rw [consequenceZTime_iff_consequenceInt]` followed by
      `simp only [ConsequenceInt, not_forall]` — do **not** add `Classical.not_imp`, which is
      unnecessary and draws an unused-simp-argument warning that `--wfail` turns into a CI
      failure; and `htgt`'s first component becomes the mirror of the conclusion clause beside
      it, built from `WitnessFamily.premise_mem_closure` (`Predicates.lean:136`) and
      `mem_typeAtM.mpr`, replacing the `fun γ hγ => absurd hγ (List.not_mem_nil)` at the current
      `Family.lean:309`.
- [x] Re-express `exists_witnessFamily_of_not_validZTime` as a derivation from the general form
      at `Γ = []`, routing through `semanticConsequenceIn_nil_iff` (`Family.lean:118`). Its
      statement, name and doc comment stay unchanged — it is pinned in `docs/theorem-index.md`
      under C14.
- [x] Run `lake build && bash scripts/typst-sync-check.sh --fix`, stage
      `typst/generated/status.typ` with `Family.lean`, and commit the two together.

**Timing**: 1.5 hours

**Depends on**: 1, 2

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the 180-line compression proof generalizes with exactly
two edits, every other line unchanged modulo `[] [φ] ↦ Γ [σ]`. Confirm by diffing the landed
theorem against the probe's `exists_witnessFamily_of_not_consequence` body; if a third edit turns
out to be required, record it in the phase notes rather than silently absorbing it, since the
"exactly two" figure is what the research measured and what Phase 6's README rewrite will assert.

**Tier Justification**: `exists_witnessFamily_of_not_validZTime` changes from a direct proof to a
derived one, and its only one-hop consumer is `Assembly.lean`, so
`lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly` covers the
blast radius; `suite_selection_select` returns `__FULL_SWEEP__` for these paths, so no
shell-suite subset is claimed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` - add `exists_witnessFamily_of_not_consequence`; re-derive `exists_witnessFamily_of_not_validZTime` from it
- `typst/generated/status.typ` - regenerated `formalsystem-line-count`

**Verification**:
- `lake build FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly` exits 0 with
  zero diagnostics, warnings included.
- `#print axioms FormalSystem.Metalogic.Decidability.exists_witnessFamily_of_not_consequence`
  reports exactly `[propext, Classical.choice, Quot.sound]`.
- `exists_witnessFamily_of_not_validZTime`'s statement is byte-identical to its pre-edit form
  (`git diff` confines the change to the proof body).
- No `sorry` appears in the edited file: `grep -n 'sorry' <file>` returns nothing.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before committing.

---

### Phase 4: Land the criterion and the direct-route procedure in `Assembly.lean` [COMPLETED]

**Goal**: The task's headline deliverable by the direct route —
`consequence_iff_noCertifiedCandidate` and `decidableSemanticConsequenceZTime` — with the three
pinned declarations in this module left intact.

**Tasks**:
- [x] Add `consequence_iff_noCertifiedCandidate` and `decidableSemanticConsequenceZTime`,
      transcribed from the probe (lines 368-387), with `candsC` renamed to `candsCtx`.
- [x] Give each a doc comment ending in a `Paper: — (formalization-native; ...)` line, matching
      `Assembly.lean:110` and `:144`, so the Phase 6 theorem-index rows satisfy C15.
- [x] Keep `decidableSemanticConsequenceZTime` a plain `def`, never an `instance`: a global
      `Decidable` instance would change instance resolution repository-wide, for the reason this
      module's header already gives for `Compression.decidableValidZTime`. Confirm it elaborates
      without a `noncomputable` modifier.
- [x] Re-express `decidableSemanticConsequenceNil` as the `Γ = []` specialization of the new
      procedure, leaving its name and signature unchanged, and replace its now-false docstring
      paragraph ("The non-empty-premise case is unproved here… none of them yet written") with
      a pointer to the general form.
- [x] Leave `validZTime_iff_noCertifiedCandidate` and `Compression.decidableValidZTime`
      untouched — both are pinned under C14 in `docs/theorem-index.md`.
- [x] Run `lake build && bash scripts/typst-sync-check.sh --fix`, stage
      `typst/generated/status.typ` with `Assembly.lean`, and commit the two together.

**Timing**: 1 hour

**Depends on**: 3

**Verification Tier**: interface

**Commit Mode**: per-substep

**Tier Justification**: `decidableSemanticConsequenceNil` is re-expressed, and `Assembly.lean`'s
one-hop dependent is `ZTimeProvability.lean`, so
`lake build FormalSystem.Metalogic.ZTimeProvability` covers the blast radius;
`suite_selection_select` returns `__FULL_SWEEP__` for these paths, so no shell-suite subset is
claimed.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` - add `consequence_iff_noCertifiedCandidate` and `decidableSemanticConsequenceZTime`; re-express `decidableSemanticConsequenceNil` and correct its docstring
- `typst/generated/status.typ` - regenerated `formalsystem-line-count`

**Verification**:
- `lake build FormalSystem.Metalogic.ZTimeProvability` exits 0 with zero diagnostics, warnings
  included.
- `#print axioms` on `consequence_iff_noCertifiedCandidate` and on
  `decidableSemanticConsequenceZTime` each reports exactly
  `[propext, Classical.choice, Quot.sound]`.
- `decidableSemanticConsequenceZTime` is declared with `def` and carries no `noncomputable`
  modifier (`grep -n 'def decidableSemanticConsequenceZTime' <file>`).
- `validZTime_iff_noCertifiedCandidate` and `Compression.decidableValidZTime` are unchanged in
  `git diff`.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before committing.

---

### Phase 5: Land the reduction-route corollary in `ZTimeProvability.lean` [NOT STARTED]

**Goal**: The cheapest honest statement of the headline result, via `semantic_deduction_in`,
sited where the decidability results are already composed with completeness.

**Tasks**:
- [ ] Add `import FormalSystem.Metalogic.StrongCompleteness` to `ZTimeProvability.lean`. Site the
      corollary here, not in `Compression/`: importing `StrongCompleteness` into `Compression/`
      would pull `Soundness.lean` and `BXCanonical/CompletenessDedekind.lean` into a subdirectory
      whose README is explicit about keeping its dependency surface minimal, whereas
      `ZTimeProvability.lean` already imports `Soundness` and `BXCanonical.Completeness`.
- [ ] Add the corollary under the name `decidableSemanticConsequenceZTimeReduction` — **not** the
      research report's `decidableSemanticConsequenceZTime_reduction`, whose non-trailing
      underscore in a `def` name fails `check-module-invariants.sh` C26 (`theorem` is exempt from
      C26; `def` is not). Body as in the research report: `letI := Compression.decidableValidZTime (Γ.foldr Formula.imp σ)`
      then `decidable_of_iff (ValidZTime (Γ.foldr Formula.imp σ)) (semantic_deduction_in Γ σ).symm`.
- [ ] Give it a doc comment ending in a `Paper: —` line for C15, and state in that comment what
      distinguishes the two routes: the reduction route's candidate objects are
      `WitnessFamily [] [Γ.foldr Formula.imp σ]`, which fold the premises into the conclusion
      formula, so only the direct route delivers a general-`Γ` criterion in the exported
      `Γ`/`Δ` certificate shape.
- [ ] Run `bash scripts/check-metalogic-cycles.sh`. Assertion B asserts set EQUALITY, so it fails
      on surplus as well as deficit: if the new import produces a surplus upward edge, extend the
      allowlist in `scripts/check-metalogic-cycles.sh` **in this same phase**, never deferred.
- [ ] Run `lake build && bash scripts/typst-sync-check.sh --fix`, stage
      `typst/generated/status.typ` with the edited files, and commit together.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: interface

**Commit Mode**: per-substep

**Tier Justification**: The edit adds a library-level import edge, which only an import-graph
check observes, so the covering pair is `lake build FormalSystem.Metalogic.ZTimeProvability`
together with `bash scripts/check-metalogic-cycles.sh`; `suite_selection_select` returns
`__FULL_SWEEP__` for these paths, so no shell-suite subset is claimed.

**Files to modify**:
- `FormalSystem/Metalogic/ZTimeProvability.lean` - add the `StrongCompleteness` import and `decidableSemanticConsequenceZTimeReduction`
- `scripts/check-metalogic-cycles.sh` - extend the Assertion B allowlist if and only if the new import produces a surplus upward edge; this file exists and is edited only on that condition, otherwise left untouched
- `typst/generated/status.typ` - regenerated `formalsystem-line-count`

**Verification**:
- `lake build FormalSystem.Metalogic.ZTimeProvability` exits 0 with zero diagnostics, warnings
  included.
- `#print axioms FormalSystem.Metalogic.decidableSemanticConsequenceZTimeReduction` reports
  exactly `[propext, Classical.choice, Quot.sound]`.
- `bash scripts/check-metalogic-cycles.sh` exits 0.
- `bash scripts/check-module-invariants.sh` reports no C26 finding naming any declaration added
  by this task, measured against the Phase 1 baseline.
- `bash scripts/typst-sync-check.sh --counts-only` exits 0 before committing.

---

### Phase 6: Reconcile the documentation record and run the full gate set [NOT STARTED]

**Goal**: Retire the residue narrative wherever it is recorded, correct the false
deduction-theorem conclusion, register the new headline declarations in the theorem index, and
close the task against the complete gate set.

**Tasks**:
- [ ] Rewrite `Compression/README.md`'s "General finite-premise consequence" bullet
      (lines 114-129, confirmed present verbatim this dispatch): the residue is discharged, the
      general form compiles, and the sentence concluding that the tree lacks a context-conjunction
      deduction theorem is replaced by the correct statement — there is no `Context.conj`, but
      `StrongCompleteness.lean:262`'s `semantic_deduction_in` supplies the iterated-implication
      form, so the reduction route is available too. If the bullet's text has moved or been
      rewritten by another writer before this phase runs, locate it by its heading
      ("## What is out of scope") rather than by line number, and report the discrepancy.
- [ ] Rewrite `Assembly.lean`'s "## Scope: no premises, and no stability modal" section
      (lines 53-70) the same way. The stability-modal half of that section is unaffected and
      stays. The section heading itself should no longer say "no premises".
- [ ] Update `Family.lean`'s header (lines 14-17), which states the compression result at
      `[] [φ]` only, to state it at arbitrary `Γ Del` with the `[] [φ]` case named as the pinned
      specialization.
- [ ] Re-read `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` immediately before
      editing (it is in concurrent task 817's declared file scope), then update only the
      `Compression/Enumerate.lean` and `Compression/Assembly.lean` module-table rows near
      line 97 to name the new declarations. Stage that file by explicit path. If a foreign
      uncommitted modification or foreign commit is observed, stop and report rather than
      proceeding.
- [ ] Add `docs/theorem-index.md` rows under `### Decidability` for
      `consequenceZTime_iff_consequenceInt`, `exists_witnessFamily_of_not_consequence`,
      `consequence_iff_noCertifiedCandidate`, `decidableSemanticConsequenceZTime` and
      `decidableSemanticConsequenceZTimeReduction`, following the existing row shape with
      `pcq pinned:C14`. Each row's declaration must already carry the `Paper:` line added in
      Phases 2-5, or C15 fails.
- [ ] Regenerate the module-inventory blocks: `bash scripts/check-module-invariants.sh --emit-inventory`,
      then verify with `--emit-inventory --check`. Stage `README.md` and
      `FormalSystem/Metalogic/README.md` if they changed.
- [ ] Run `lake build && bash scripts/typst-sync-check.sh --fix` and stage
      `typst/generated/status.typ` with the edited `.lean` files.
- [ ] Run the full gate set and record the result against the Phase 1 baseline.

**Timing**: 1.5 hours

**Depends on**: 1, 2, 3, 4, 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: This phase asserts the residue/deduction-theorem claim is recorded at
exactly four sites — `Compression/README.md:114-129`, `Assembly.lean:53-70`, `Family.lean:14-17`
and `WitnessFamily/README.md:~97`. A repo-wide grep this dispatch for `Context.conj` found one
live occurrence (`Assembly.lean:58`), consistent with that inventory. Confirm at implementation
time with `grep -rn 'Context.conj\|finite-premise\|not known to compile\|unproved' FormalSystem/ docs/`
before declaring the reconciliation complete; `specs/reviews/review-2026-11-02.md` also carries
the claim but is a `specs/**` historical record and is deliberately left unedited.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/README.md` - rewrite the "General finite-premise consequence" out-of-scope bullet; correct the deduction-theorem conclusion
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` - rewrite the "Scope: no premises" header section
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` - restate the module header at arbitrary `Γ Del`
- `FormalSystem/Metalogic/Decidability/WitnessFamily/README.md` - update the two module-table rows; re-read immediately before editing (concurrent task 817 territory)
- `docs/theorem-index.md` - add five rows under `### Decidability`
- `README.md` - regenerated module-inventory block, if changed
- `FormalSystem/Metalogic/README.md` - regenerated module-inventory block, if changed
- `typst/generated/status.typ` - regenerated `formalsystem-line-count`

**Verification**:
- `lake build` exits 0 for the whole library with zero diagnostics, warnings included.
- `bash scripts/check-module-invariants.sh` reports no finding naming any file this task touched
  that is absent from the Phase 1 baseline; any remaining findings are pre-existing and are
  enumerated in the phase notes.
- `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- `bash scripts/typst-sync-check.sh` exits 0 on the full, bare invocation (CI's authoritative
  backstop, not just `--counts-only`).
- `bash scripts/check-metalogic-cycles.sh` exits 0.
- `bash .claude/scripts/verify-deploy.sh` is run and its findings are reported split into those
  naming this task's touched files and the tree's standing baseline; only the first category is a
  blocker.
- `grep -rn 'sorry' FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/` returns no
  match introduced by this task.
- `#print axioms` on all five new headline declarations reports exactly
  `[propext, Classical.choice, Quot.sound]`.

---

## Lean Challenge Statements

```lean
import FormalSystem.Metalogic.Decidability.WitnessFamily.Compression.Assembly
import FormalSystem.Metalogic.StrongCompleteness

open FormalSystem.Syntax
open FormalSystem.Semantics

namespace FormalSystem.Metalogic.Decidability

def ConsequenceInt (Γ : Context) (φ : Formula) : Prop := sorry

theorem consequenceZTime_iff_consequenceInt (Γ : Context) (φ : Formula) :
    SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ φ ↔ ConsequenceInt Γ φ := sorry

def candsCtx (Γ Del : Context) : List (WitnessFamily Γ Del) := sorry

theorem exists_witnessFamily_of_not_consequence (Γ : Context) (σ : Formula)
    (h : ¬ SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ σ) :
    ∃ (W : WitnessFamily Γ [σ]) (t : ℤ),
      (∀ Λ ∈ W.lassos,
        Λ.back.length ≤ compressionBound Γ [σ] ∧
        Λ.mid.length ≤ compressionBound Γ [σ] ∧
        Λ.fwd.length ≤ compressionBound Γ [σ]) ∧
      W.lassos.length ≤ (closureOf (Γ ++ [σ])).card + 1 ∧
      (∃ S : Finset Formula, S ⊆ closureOf (Γ ++ [σ]) ∧ W.bx = fun χ => decide (χ ∈ S)) ∧
      0 ≤ t ∧ t ≤ (compressionBound Γ [σ] : ℤ) ∧
      W.Certifies t := sorry

theorem consequence_iff_noCertifiedCandidate (Γ : Context) (σ : Formula) :
    SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ σ ↔
      ∀ W ∈ candsCtx Γ [σ], ∀ t ∈ Finset.Icc (0 : ℤ) (compressionBound Γ [σ] : ℤ),
        ¬ W.Certifies t := sorry

def decidableSemanticConsequenceZTime (Γ : Context) (σ : Formula) :
    Decidable (SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ σ) := sorry

end FormalSystem.Metalogic.Decidability

namespace FormalSystem.Metalogic

def decidableSemanticConsequenceZTimeReduction (Γ : Context) (σ : Formula) :
    Decidable (SemanticConsequenceIn ProofSystem.FrameClass.ZTime Γ σ) := sorry

end FormalSystem.Metalogic
```

## Decisions

- **`ConsequenceInt` and its normalization are sited in `Family.lean`, not in
  `Semantics/IntTransfer.lean` beside `ValidInt`.** Siting it beside `ValidInt` would be more
  symmetric, but `Family.lean` is the only consumer and already imports `IntTransfer`, so the
  local siting leaves the `Compression/` subtree's dependency surface and the C2-pinned
  `IntTransfer.lean` both untouched. If a second consumer ever appears, promoting the definition
  to `IntTransfer.lean` is a mechanical move.
- **The probe's `C` suffix is renamed to `Ctx` on arrival.** The promotion is therefore *not*
  verbatim, and Phase 1 mandates the renames explicitly. `C` is avoided because
  `Compression/Cycle.lean` already uses that suffix with an unrelated meaning (`cycleBoundC`),
  and `Ctx` says what the index actually is.
- **The `φ`-indexed names survive as wrappers rather than being deleted.** `cands`,
  `validZTime_iff_noCertifiedCandidate`, `exists_witnessFamily_of_not_validZTime` and
  `Compression.decidableValidZTime` are pinned in `docs/theorem-index.md` under C14; keeping
  their statements fixed means the pinned-name set does not churn and the C14 rows need no edit.
- **Both routes land.** The direct route is the primary deliverable because only it produces a
  general-`Γ` criterion whose candidates are `WitnessFamily Γ [σ]` — the shape the certificate
  layer exists to export, with `Γ` and `Δ` named separately. The reduction route is four lines
  and is worth having beside it; it is not a substitute.
- **The false recorded claim is corrected rather than worked around.** It has already propagated
  from `Assembly.lean` into `Compression/README.md`, into `specs/reviews/review-2026-11-02.md`,
  and into this task's own description. Phase 6 corrects the live sites; the `specs/**` review
  record is historical and is left as written.

## Testing & Validation

- [ ] `lake build` green for the whole library, zero diagnostics including warnings (CI runs
      `--wfail`, so a warning is a failure).
- [ ] Each of the five new headline declarations measures at exactly
      `[propext, Classical.choice, Quot.sound]` under `#print axioms`.
- [ ] No `sorry` introduced anywhere under
      `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/` or in
      `FormalSystem/Metalogic/ZTimeProvability.lean`.
- [ ] No `noncomputable` modifier on any `Enumerate.lean` declaration or on
      `decidableSemanticConsequenceZTime`.
- [ ] `bash scripts/check-module-invariants.sh` shows no regression against the Phase 1 baseline
      (delta, not absolute zero).
- [ ] `bash scripts/check-module-invariants.sh --emit-inventory --check` exits 0.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 on the full bare invocation.
- [ ] `bash scripts/check-metalogic-cycles.sh` exits 0.
- [ ] The five pinned C14 declarations' statements are unchanged in `git diff`.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Enumerate.lean` — context-indexed
  enumeration plus `φ`-indexed wrappers.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Family.lean` — `ConsequenceInt`,
  `consequenceZTime_iff_consequenceInt`, `exists_witnessFamily_of_not_consequence`.
- `FormalSystem/Metalogic/Decidability/WitnessFamily/Compression/Assembly.lean` —
  `consequence_iff_noCertifiedCandidate`, `decidableSemanticConsequenceZTime`.
- `FormalSystem/Metalogic/ZTimeProvability.lean` — `decidableSemanticConsequenceZTimeReduction`.
- Documentation reconciliation: `Compression/README.md`, `WitnessFamily/README.md`,
  `docs/theorem-index.md`, and the regenerated `README.md` /
  `FormalSystem/Metalogic/README.md` inventory blocks.
- `typst/generated/status.typ` — regenerated count, staged with every Lean-editing commit.
- `specs/830_generalize_decidable_validztime_finite_premises/summaries/01_generalize-finite-premise-decidability-summary.md`
  at completion.

## Rollback/Contingency

The phases are independently committed and each is green on its own, so the ordinary contingency
is to stop after the last green phase and report, rather than to revert. Specifically:

- **If a phase's build goes red and cannot be made green**, mark that phase `[PARTIAL]` or
  `[BLOCKED]`, leave the preceding phases' commits in place, and report the specific item that
  blocked it. Per the task description, reporting the blocking item *is* an acceptable outcome;
  forcing later items around an earlier failure is not.
- **If residue item 1 (Phase 2) fails against expectation**, stop there. Phases 3-4 depend on it
  and must not be attempted around it. Phase 5's reduction route is independent and may still
  land on its own, which would be a partial but real deliverable.
- **If a genuine working-tree rollback is needed**, take a snapshot first — see
  `context/contracts/recovery.md`'s rollback rung for the exact `git-snapshot.sh` invocation
  shape, including its out-of-scope override flag — then perform the revert. Do not emit a bare
  reverting `git-snapshot.sh` as a routine start-of-phase checkpoint; an ordinary defensive
  checkpoint uses `--no-revert`.
- **If a foreign commit or foreign uncommitted modification is observed** in this task's file
  scope (concurrent siblings 714, 817, 818, 821, 832 are live this cycle), stop and report after
  checking `git log` to confirm the work is not this task's own, rather than reverting or
  proceeding.
