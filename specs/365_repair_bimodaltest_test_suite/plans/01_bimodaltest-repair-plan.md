# Implementation Plan: Repair BimodalTest Test Suite (Task 365)

- **Task**: 365 - Repair the BimodalTest test-suite root so `lake build BimodalTest` is fully green with zero sorries
- **Status**: [COMPLETED]
- **Effort**: 9-10 hours
- **Dependencies**: None (research complete)
- **Research Inputs**: specs/365_repair_bimodaltest_test_suite/reports/01_bimodaltest-repair-research.md
- **Artifacts**: plans/01_bimodaltest-repair-plan.md (this file)
- **Standards**: plan-format.md; status-markers.md; artifact-management.md; tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The `Tests/BimodalTest.lean` aggregate root and its ~21 transitively-imported modules fail to build
because eight distinct API-drift categories accumulated after several library refactors
(frame-class generalization of `DerivationTree`, axiom→derived-theorem migration, `TaskFrame`
type-parameterization, `deduction_theorem` relocation, automation-API changes). Because Lake skips
any module whose dependency failed to build, the first-wave errors mask a deeper fix-set; the true
scope is exposed only by fixing bottom-up and re-building. This plan brings the target fully green
with **zero sorries** by fixing the shared dependency first, de-risking the two possible-BLOCKED
items early, then applying the remaining category fixes in dependency-ordered waves — each phase
independently verifiable with a scoped `lake build`.

### Research Integration

Built directly on the research report's per-module fix map, 8 API-drift categories (A-H), and two
mechanical `DerivationTree` transforms. Key facts carried into this plan:
- `DerivationTree` first explicit arg is now `fc : FrameClass`; stale `DerivationTree [` becomes
  `DerivationTree FrameClass.Base [` (Cat A, 104 sites / 3 files).
- `.axiom` constructor gained trailing `h_fc : h.minFrameClass ≤ fc`; for base axioms this is
  discharged by `trivial` (`<;> trivial` in tactic form) — Cat B. **Caveat**: non-base axioms
  (`density`, `dense_indicator`, `prior_UZ`, `prior_SZ`, `z1`) need a real proof, so spot-check
  before blanket-appending.
- `Integration/Helpers.lean` is the shared dependency and is fixed first (Phase 1).
- Cat D (`temp_4`/`temp_k_dist` → `noncomputable` derived theorems; `temp_a`/`temp_l` with no found
  replacement) and `Property/Generators.lean` (parse + 24 instance-synthesis failures) are the two
  highest-risk items and are resolved early (Phase 2) with a documented quarantine fallback.
- Zero genuine `sorry` exists in imported files; the `#eval … depends on sorry` messages are
  `sorryAx` artifacts of an atom/String elaboration error that vanish once fixed (Cat E, Phase 7).
- 8 non-imported test files (FormulaMutatorTest, InterestingnessTest, ProofFirstTests,
  DerivationBenchmark, SemanticBenchmark, TraceCertificateTest, TraceExporterE2ETest,
  TraceExportTest) are out of scope for the green-build goal.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was provided in the delegation context and no roadmap phases were requested
(`roadmap_flag` unset). A `specs/ROADMAP.md` exists but is treated as read-only and is not modified
by this plan.

## Goals & Non-Goals

**Goals**:
- `lake build BimodalTest` completes fully green (all ~21 transitively-imported modules build).
- Zero `sorry` and zero `sorryAx` in the built target.
- `lake build` (whole project) confirms no regression introduced by the repair.
- Each phase independently verifiable via a scoped `lake build BimodalTest.<Module>`.
- Shared dependency (`Integration/Helpers.lean`) fixed before any dependent module.

**Non-Goals**:
- Fixing the 8 non-imported test files (FormulaMutatorTest, InterestingnessTest, ProofFirstTests,
  DerivationBenchmark, SemanticBenchmark, TraceCertificateTest, TraceExporterE2ETest,
  TraceExportTest) — candidates for a follow-up task.
- Adding new test coverage or refactoring test intent beyond what API drift requires.
- Modifying the main library (`Theories/Bimodal/`) except where a genuine library defect is the
  root cause; the library `Automation/` is confirmed sorry-free.
- Modifying `specs/ROADMAP.md`.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `temp_a` / `temp_l` axioms have no replacement | H | M | Phase 2 investigates first (library archaeology via `lean_local_search`/`loogle`). If truly removed, quarantine or excise only the specific broken constructs with an inline `NOTE:` and record in summary; do NOT insert `sorry`. Escalate [BLOCKED] only if quarantine would remove essential test intent. |
| `Property/Generators.lean` deep parse + 24 instance-synth failures (generator-API drift) | H | M | Phase 2 isolates it; if intractable within budget, quarantine the broken generator block (comment out / narrow to a buildable subset) with a documented `NOTE:`, keeping the module importable so the target still goes green. |
| Mechanical `.axiom` `trivial` append fails for a non-base axiom | M | M | Spot-check each `.axiom` site for `density`/`dense_indicator`/`prior_UZ`/`prior_SZ`/`z1`; supply `le_refl _` (or the matching non-Base proof) instead of `trivial` where needed (Phase 3/4). |
| Fixing a module exposes a new downstream wave (Lake skip behavior) | M | H | Re-run scoped `lake build` after each phase to surface the next wave; phase ordering is bottom-up so newly-exposed files are addressed in a later phase, not missed. |
| Category fixes overlap within a single file (a file needs A+B+D+G) causing churn | M | M | Phases are dependency-ordered so a file's later-category fixes land after its earlier-category fixes; verification is per-module green, not per-category, so a file is only declared done when all its categories are resolved. |
| Accidental library regression | M | L | Phase 8 runs whole-project `lake build`; keep edits scoped to `Tests/BimodalTest/`. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3, 6 | 1 (P3); 2 (P6) |
| 3 | 4, 5, 7 | 2, 3 (P4); 3 (P5); 3 (P7) |
| 4 | 8 | 4, 5, 6, 7 |

Phases within the same wave can execute in parallel (they touch disjoint modules).

---

### Phase 1: Shared foundation — Helpers.lean green [COMPLETED]

**Goal**: Fix the shared dependency `Integration/Helpers.lean` so all Integration downstream
modules become reachable by Lake.

**Tasks**:
- [x] Apply Cat A: `DerivationTree [` → `DerivationTree FrameClass.Base [` across Helpers.lean. *(completed — inserted FrameClass.Base into all 12 type-signature sites)*
- [x] Apply Cat B: append `trivial` to `DerivationTree.axiom` term calls; `<;> trivial` for tactic
      form. Spot-check for non-base axioms and substitute a real `h_fc` proof if any appear. *(deviation: altered — mk_axiom_deriv accepts an arbitrary Axiom whose minFrameClass is not necessarily Base, so return type changed to `DerivationTree h.minFrameClass [] φ` with proof `le_refl _` instead of a Base-fixed `trivial`)*
- [x] Add `noncomputable` / expected-type annotations if Cat F/H errors surface locally. *(deviation: altered — no Cat F/H errors surfaced, but line 49 had a Cat E atom/String mismatch fixed via `Formula.atom_s name`)*

**Timing**: 0.5-1 hour

**Depends on**: none

**Files to modify**:
- `Tests/BimodalTest/Integration/Helpers.lean` - Cat A (DTsig) + Cat B (.axiom)

**Verification**:
- `lake build BimodalTest.Integration.Helpers` green.
- No new `sorry`/`sorryAx` introduced.

---

### Phase 2: Risk spike — temp_a/temp_l resolution + Generators.lean [COMPLETED]

**Decision recorded (temp_a/temp_l)**:
- `temp_a`: replace `Axiom.temp_a φ` → `Axiom.connect_future φ`. The formula types are
  definitionally identical (`φ.imp (φ.some_past.all_future)` ≡ `φ.imp (Formula.all_future φ.some_past)`).
  Semantic uses of `temp_a_valid` remain valid and unchanged.
- `temp_l`: NO axiom or single derived-theorem replacement exists (`temp_l` was fully removed; it
  now requires a multi-step derivation). The project's own `AxiomsTest.lean` already established the
  convention of quarantining the derivation-level `temp_l` construct with an inline `NOTE` while
  keeping the semantic `temp_l_valid` test. Phase 4 applies this: derivation-level
  `DerivationTree.axiom [] φ (Axiom.temp_l p)` constructs are quarantined with a `NOTE` (never
  `sorry`), and semantic `temp_l_valid` references are kept.

**Goal**: De-risk the two possible-BLOCKED items early: (a) determine the replacement (or fallback)
for the removed `temp_a`/`temp_l` axioms, and (b) bring `Property/Generators.lean` green (or
quarantine its broken constructs). This unblocks the axiom-migration and TaskFrame phases with a
known-good recipe.

**Tasks**:
- [x] Library archaeology for `temp_a`/`temp_l`: search `Theories/Bimodal/` via `lean_local_search`,
      `loogle`, and git history for a rename or derived-theorem replacement. *(completed — temp_a ≡ connect_future axiom; temp_l fully removed, no single replacement)*
- [x] Record the decision: either the concrete replacement identifiers, or a documented quarantine
      plan. *(completed — see "Decision recorded" block above)*
- [x] `Property/Generators.lean`: apply Cat C and resolve parse-level + instance-synthesis failures. *(deviation: altered — root cause was Plausible generator-API drift (`Gen.oneOf` Array+pos, `Gen.resize` Nat→Nat fn, `Gen.choose` type+proof+subtype), `Formula.atom` needing `Atom` (used `atom_s`), non-constructor `all_past`/`all_future` Shrinkable patterns (rewrote to real constructors untl/snce), and instance self-reference (extracted standalone `genFormula`/`shrinkFormula`). Added `import Mathlib.Algebra.Order.Group.Int` for `TaskFrame Int`.)*
- [x] If Generators.lean proves intractable, quarantine the broken generator block. *(deviation: skipped for the Formula/TaskFrame generators (fully repaired); the `TaskModel` generator block + `TaskModelProxy` were quarantined with an inline NOTE — proxy lacks required `Repr`/`Shrinkable` and no `Testable` consumer quantifies over `TaskModel`.)*

**Timing**: 1.5-2 hours

**Depends on**: none

**Files to modify**:
- `Tests/BimodalTest/Property/Generators.lean` - Cat C + parse/instance repairs (or quarantine)
- (investigation output for `temp_a`/`temp_l`; no file edits required beyond notes)

**Verification**:
- `lake build BimodalTest.Property.Generators` green (with any quarantine documented).
- Written decision for `temp_a`/`temp_l` (replacement identifiers or quarantine plan) recorded for
  Phase 4.
- No `sorry`/`sorryAx` introduced.

---

### Phase 3: DerivationTree mechanical sweep (Cat A + B) [COMPLETED]

**Goal**: Apply the two mechanical `DerivationTree` transforms across all remaining DT-affected
modules, plus Cat F (`noncomputable`) and Cat H (fc type-annotation) fixes as they surface.

**Tasks**:
- [ ] Cat A across: `Automation/TacticsTest.lean`, `ProofSystem/DerivationTest.lean`,
      `Semantics/TruthTest.lean`, `Automation/ProofSearchBenchmark.lean`,
      `Integration/EndToEndTest.lean`, `Integration/ProofSystemSemanticsTest.lean`,
      `Integration/ComplexDerivationTest.lean`, `Integration/TemporalIntegrationTest.lean`,
      `Integration/BimodalIntegrationTest.lean`, `ProofSystem/DerivationPropertyTest.lean`,
      `Automation/TacticsTest_Simple.lean`.
- [ ] Cat B (.axiom `h_fc`): append `trivial` / `<;> trivial`; spot-check non-base axioms.
- [ ] Cat H: add expected-type annotations (`⊢ φ` / `(fc := FrameClass.Base)`) where `fc` synthesis
      fails; Cat F: add `noncomputable` where a def/example depends on a noncomputable derived theorem.
- [ ] Leave Cat D (gone-axiom) and Cat G (deduction) sites in these files for Phases 4/5; fix only
      DT/fc/noncomputable errors here.

**Timing**: 1.5-2 hours

**Depends on**: 1

**Files to modify**: the 11 modules listed above (DT/fc/noncomputable edits only).

**Verification**:
- Scoped `lake build` of each DT-only module that has no Cat D/G dependency goes green
  (e.g. `BimodalTest.Semantics.TruthTest`, `BimodalTest.Automation.TacticsTest`).
- Modules also needing Cat D/G may still error on those categories (expected — handled in 4/5); no
  new `sorry`/`sorryAx`.

---

### Phase 4: Axiom migration (Cat D + F) [COMPLETED]

**Goal**: Replace removed/migrated axioms with their derived-theorem equivalents and apply the
Phase 2 `temp_a`/`temp_l` decision, propagating `noncomputable` as required.

**Tasks**:
- [ ] Replace `Axiom.temp_4` → `temp_4_derived` and `Axiom.temp_k_dist` → `temp_k_dist_derived`
      (both `noncomputable`, in `Theorems/TemporalDerived.lean`).
- [ ] Apply the Phase 2 decision for `temp_a`/`temp_l` (replacement or documented quarantine).
- [ ] Cat F: mark affected `def`/`example` `noncomputable` where they now depend on a
      noncomputable derived theorem.
- [ ] Files: `ProofSystem/AxiomsTest.lean`, `Integration/ProofSystemSemanticsTest.lean`,
      `Integration/AutomationProofSystemTest.lean`, `Integration/ComplexDerivationTest.lean`,
      `Integration/TemporalIntegrationTest.lean`, `Integration/BimodalIntegrationTest.lean`,
      `ProofSystem/DerivationPropertyTest.lean`.

**Timing**: 1.5 hours

**Depends on**: 2, 3

**Files to modify**: the 7 modules listed above (Cat D + F edits).

**Verification**:
- `lake build` of each of the above modules green (assuming their Cat A/B/G fixes are also in place).
- `BimodalTest.Integration.ProofSystemSemanticsTest` and
  `BimodalTest.Integration.AutomationProofSystemTest` green.
- No `sorry`/`sorryAx` introduced.

---

### Phase 5: deduction_theorem relocation (Cat G) [COMPLETED]

**Goal**: Update the relocated `deduction_theorem` references to
`Bimodal.Metalogic.Core.deduction_theorem`, accounting for its new implicit `fc`.

**Tasks**:
- [ ] Replace `Bimodal.Metalogic.deduction_theorem` → `Bimodal.Metalogic.Core.deduction_theorem`
      (or `open Bimodal.Metalogic.Core`) across:
      `Theorems/PropositionalTest.lean`, `ProofSystem/DerivationTest.lean`,
      `Automation/DeductionTest.lean`, `Metalogic/PropDecideTest.lean`,
      `Theorems/PerpetuityTest.lean`.
- [ ] Supply expected-type annotation where the new implicit `fc` cannot be inferred (Cat H).

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**: the 5 modules listed above (Cat G + any Cat H).

**Verification**:
- `lake build BimodalTest.Theorems.PropositionalTest`,
  `BimodalTest.Automation.DeductionTest`, `BimodalTest.Metalogic.PropDecideTest`,
  `BimodalTest.Theorems.PerpetuityTest`, `BimodalTest.ProofSystem.DerivationTest` green.
- No `sorry`/`sorryAx` introduced.

---

### Phase 6: TaskFrame API remainder (Cat C) [COMPLETED]

**Goal**: Apply the `TaskFrame` API-drift fixes to the remaining semantics test modules using the
recipe established in Phase 2.

**Tasks**:
- [ ] `Semantics/TaskFrameTest.lean` and `Semantics/SemanticPropertyTest.lean`: `(T := …)` →
      `(D := …)`; field renames `nullity`→`nullity_identity`, `compositionality`→`forward_comp`;
      supply the new `converse` field and any missing `nullity_identity`/`forward_comp` obligations.
- [ ] Also fix `Syntax/ContextTest.lean` (minor unsolved goals) here since it is independent of the
      DT/axiom/deduction chains.

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Tests/BimodalTest/Semantics/TaskFrameTest.lean` - Cat C
- `Tests/BimodalTest/Semantics/SemanticPropertyTest.lean` - Cat C
- `Tests/BimodalTest/Syntax/ContextTest.lean` - unsolved-goals cleanup

**Verification**:
- `lake build BimodalTest.Semantics.TaskFrameTest`,
  `BimodalTest.Semantics.SemanticPropertyTest`, `BimodalTest.Syntax.ContextTest` green.
- No `sorry`/`sorryAx` introduced.

---

### Phase 7: Automation API + sorry-cascade fix (Cat E) [COMPLETED]

**Goal**: Update the `search` function call sites to the new API and fix the atom/String
elaboration error that inserts `sorryAx`, eliminating the `#eval … depends on sorry` cascade.

**Tasks**:
- [ ] `Automation/EdgeCaseTest.lean`: migrate `search` (result+stats) call sites to the new API;
      fix `atom`/`Decidable` issues. (The `modal_search`/`temporal_search`/`propositional_search`
      tactics are unchanged and stay as-is.)
- [ ] `Automation/ProofSearchTest.lean`: fix the `Formula.atom "s"` String-into-Atom-field mismatch
      that inserts `sorryAx`; resolve the `decide` failures. Confirm the `#eval`-depends-on-sorry
      messages disappear once the atom/String mismatch is corrected.

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Tests/BimodalTest/Automation/EdgeCaseTest.lean` - Cat E (search-fn API, atom/Decidable)
- `Tests/BimodalTest/Automation/ProofSearchTest.lean` - Cat E (atom/String sorry-cascade, decide)

**Verification**:
- `lake build BimodalTest.Automation.EdgeCaseTest`,
  `BimodalTest.Automation.ProofSearchTest` green.
- No `sorryAx` remains reachable from these modules.

---

### Phase 8: Final gate — full green + zero-sorry audit [COMPLETED]

**Goal**: Confirm the aggregate target is fully green with zero sorries and no whole-project
regression.

**Tasks**:
- [ ] `lake build BimodalTest` — fully green (all ~21 imported modules).
- [ ] `lake build` — whole project green (no regression).
- [ ] Audit for `sorry`/`sorryAx`: grep imported test files and confirm no genuine `sorry`; verify
      any Phase-2 quarantines are documented, not sorry-based.
- [ ] Record any module that could not be brought green (should be none; escalate [BLOCKED] only if
      a Phase-2 fallback removed essential test intent).

**Timing**: 0.5 hour

**Depends on**: 4, 5, 6, 7

**Files to modify**: none (verification only; small follow-up edits if the aggregate exposes a final
straggler).

**Verification**:
- `lake build BimodalTest` exits 0.
- `lake build` exits 0.
- Zero `sorry`/`sorryAx` in the built target.

---

## Testing & Validation

- [ ] `lake build BimodalTest.Integration.Helpers` green (Phase 1).
- [ ] `lake build BimodalTest.Property.Generators` green; `temp_a`/`temp_l` decision recorded (Phase 2).
- [ ] Scoped `lake build` green for each module as its phase completes (Phases 3-7).
- [ ] `lake build BimodalTest` fully green (Phase 8).
- [ ] `lake build` whole-project green — no regression (Phase 8).
- [ ] Zero `sorry` / `sorryAx` in imported test modules (Phase 8 audit).

## Artifacts & Outputs

- plans/01_bimodaltest-repair-plan.md (this file)
- summaries/01_bimodaltest-repair-summary.md (produced by /implement)
- Repaired modules under `Tests/BimodalTest/` (~21 imported files)
- specs/365_repair_bimodaltest_test_suite/.orchestrator-handoff.json (updated to plan-complete)

## Rollback/Contingency

- All edits are scoped to `Tests/BimodalTest/`; revert via `git checkout -- Tests/BimodalTest/` if a
  phase regresses (only when the working tree is otherwise clean or after a snapshot).
- If `temp_a`/`temp_l` or `Property/Generators.lean` cannot be resolved without discarding essential
  test intent, apply the documented quarantine (comment out the specific constructs with an inline
  `NOTE:`; never insert `sorry`) so the aggregate still builds green; escalate the module to
  [BLOCKED] for user review only if quarantine is unacceptable.
- Commit per-phase at each green scoped build so any single phase can be reverted independently
  without losing earlier progress.
